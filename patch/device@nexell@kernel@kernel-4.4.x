diff --git drivers/media/platform/nexell/capture/nx-rearcam.c drivers/media/platform/nexell/capture/nx-rearcam.c
index 689a668..b7a91eb 100644
--- drivers/media/platform/nexell/capture/nx-rearcam.c
+++ drivers/media/platform/nexell/capture/nx-rearcam.c
@@ -51,6 +51,8 @@
 
 #define NX_REARCAM_DEV_NAME "nx-rearcam"
 
+#define NX_SKIP_SENSOR_INIT
+
 /*	#define DEBUG_SYNC	*/
 #ifdef DEBUG_SYNC
 #include <linux/timer.h>
@@ -65,8 +67,6 @@
 
 #define UNUSE_MLC_SCALE	0
 
-#define	USED_SENSOR_INIT_WOKRER	1
-
 #ifndef MLC_LAYER_RGB_OVERLAY
 #define MLC_LAYER_RGB_OVERLAY 0
 #endif
@@ -96,6 +96,7 @@
 		v = _v; \
 		}
 
+
 static u32 vendor_parm = 0x1;
 MODULE_PARM_DESC(vendor_parm, "vendor parmeter");
 module_param(vendor_parm, uint, 0644);
@@ -436,17 +437,15 @@ struct nx_rearcam {
 	struct nx_sync_info dp_sync;
 	int dp_drm_port_video_prior[2];
 
-	struct delayed_work work;
-	struct mutex decide_work_lock;
+	struct tasklet_struct work;
 
 	int event_gpio;
 	int active_high;
 	int detect_delay;
 	int is_enable_gpio_irq;
+#ifndef NX_SKIP_SENSOR_INIT
 	struct reg_val *init_data;
-	struct work_struct work_gpio_event;
-	struct workqueue_struct *wq_gpio_event;
-
+#endif
 	int irq_event;
 	int irq_vip;
 	int is_enable_vip_irq;
@@ -460,14 +459,6 @@ struct nx_rearcam {
 	u32 width;
 	u32 height;
 
-	/* sensor init worker */
-	struct work_struct work_sensor_init;
-	struct workqueue_struct *wq_sensor_init;
-
-	/* display worker */
-	struct work_struct work_display;
-	struct workqueue_struct *wq_display;
-
 	/* display rotation worker */
 	struct work_struct work_lu_rot;
 	struct workqueue_struct *wq_lu_rot;
@@ -551,7 +542,7 @@ struct nx_rearcam {
         void (*set_enable)(void *, bool);
 	void (*sensor_init_func)(struct i2c_client *client);
 	void *(*alloc_vendor_context)
-                (struct rearcam *cam, struct device *dev);
+                (void *cam, struct device *dev);
 	void (*free_vendor_context)(void *);
 	bool (*pre_turn_on)(void *);
 	void (*post_turn_off)(void *);
@@ -567,20 +558,18 @@ static void _dpc_set_display(struct nx_rearcam *);
 static void _set_enable_lvds(struct nx_rearcam *);
 static void _set_disable_lvds(struct nx_rearcam *);
 
-static void _destroy_display_worker(struct nx_rearcam *);
-static void _display_worker(struct work_struct *);
-
 static void _disable_vip_irq_ctx(struct nx_rearcam *);
 static void _disable_dpc_irq_ctx(struct nx_rearcam *);
 
-static void init_hw(struct nx_rearcam *);
+static void _init_hw_display(struct nx_rearcam *);
 
 static int _enable_rot_ctx(struct nx_rearcam *);
 static void _enable_dpc_irq_ctx(struct nx_rearcam *);
 static void _enable_vip_irq_ctx(struct nx_rearcam *);
 
-static void _init_gpio_event_worker(struct nx_rearcam *);
-static void _deinit_gpio_event_worker(struct nx_rearcam *);
+static void _work_handler_reargear(void *devdata);
+static void _display_init(struct nx_rearcam *me);
+static void _display_worker(struct nx_rearcam *me);
 
 #ifdef DEBUG_SYNC
 /* DEBUG_SYNC */
@@ -682,7 +671,7 @@ static int parse_sensor_dt(struct device_node *np, struct device *dev,
 			type);
 		return -EINVAL;
 	}
-
+#ifndef NX_SKIP_SENSOR_INIT
 	if (of_property_read_u32(np, "width", &clip->sensor_width))
 		clip->sensor_width = 0;
 
@@ -691,7 +680,7 @@ static int parse_sensor_dt(struct device_node *np, struct device *dev,
 
 	pr_debug("%s - sensor width %d, sensor height : %d\n", __func__,
 			clip->sensor_width, clip->sensor_height);
-
+#endif
 	return 0;
 }
 
@@ -1005,6 +994,7 @@ static int parse_clock_dt(struct device_node *np, struct device *dev,
 static int nx_sensor_reg_parse_dt(struct device *dev, struct device_node *np,
 	struct nx_rearcam *me)
 {
+#ifndef NX_SKIP_SENSOR_INIT
 	int size = 0;
 	const __be32 *list;
 	int i = 0;
@@ -1033,7 +1023,7 @@ static int nx_sensor_reg_parse_dt(struct device *dev, struct device_node *np,
 
 	(me->init_data+size)->reg = 0xFF;
 	(me->init_data+size)->val = 0xFF;
-
+#endif
 	return 0;
 }
 
@@ -1327,14 +1317,16 @@ static int nx_clipper_parse_dt(struct device *dev, struct device_node *np,
 	if (ret)
 		return ret;
 
+#ifndef NX_SKIP_SENSOR_INIT
 	child_node = of_find_node_by_name(np, "power");
 	if (!child_node)
 		dev_warn(dev, "failed to get power node\n");
-
-	ret = parse_power_dt(child_node, dev, clip);
-	if (ret)
-		return ret;
-
+	else {
+		ret = parse_power_dt(child_node, dev, clip);
+		if (ret)
+			return ret;
+	}
+#endif
 	ret = parse_clock_dt(child_node, dev, clip);
 	if (ret)
 		return ret;
@@ -1784,6 +1776,7 @@ static int nx_rearcam_parse_dt(struct device *dev, struct nx_rearcam *me)
 	}
 	me->clipper_info.height = me->height;
 
+#ifndef NX_SKIP_SENSOR_INIT
 	child_sensor_reg_node = _of_get_node_by_property(dev, np, "sensor_reg");
 	if (child_sensor_reg_node) {
 		ret = nx_sensor_reg_parse_dt(dev, child_sensor_reg_node, me);
@@ -1791,8 +1784,9 @@ static int nx_rearcam_parse_dt(struct device *dev, struct nx_rearcam *me)
 			dev_err(dev, "failed to parse sensor register dt\n");
 			return ret;
 		}
-	}
 
+	}
+#endif
 	child_gpio_node = of_find_node_by_name(np, "gpio");
 	if (!child_gpio_node) {
 		dev_err(dev, "failed to get gpio node\n");
@@ -1824,11 +1818,13 @@ static int nx_rearcam_parse_dt(struct device *dev, struct nx_rearcam *me)
 		return -EINVAL;
 	}
 
+#ifndef NX_SKIP_SENSOR_INIT
 	ret = nx_display_top_parse_dt(dev, child_display_top_node, me);
 	if (ret) {
 		dev_err(dev, "failed to display top parse dt\n");
 		return ret;
 	}
+#endif
 
 	child_display_node = _of_get_node_by_property(dev, np, "display");
 	if (!child_display_node) {
@@ -2564,14 +2560,6 @@ static void _dpc_set_display(struct nx_rearcam *me)
 	pr_debug("%s - vsync-len : %d\n", __func__, sync->v_sync_width);
 }
 
-static void _cancel_display_worker(struct nx_rearcam *me)
-{
-	if (me->wq_display != NULL) {
-		cancel_work_sync(&me->work_display);
-		flush_workqueue(me->wq_display);
-	}
-}
-
 static void _cancel_rot_worker(struct nx_rearcam *me)
 {
 	if (me->wq_lu_rot != NULL) {
@@ -2590,14 +2578,6 @@ static void _cancel_rot_worker(struct nx_rearcam *me)
 	}
 }
 
-static void _destroy_display_worker(struct nx_rearcam *me)
-{
-	if (me->wq_display != NULL) {
-		destroy_workqueue(me->wq_display);
-		me->wq_display = NULL;
-	}
-}
-
 static void _destroy_rot_worker(struct nx_rearcam *me)
 {
 	if (me->wq_lu_rot != NULL) {
@@ -2618,13 +2598,10 @@ static void _destroy_rot_worker(struct nx_rearcam *me)
 
 static void _setup_me(struct nx_rearcam *me)
 {
-	init_hw(me);
-
 	if (me->rotation)
 		_enable_rot_ctx(me);
 
 	_enable_dpc_irq_ctx(me);
-	_enable_vip_irq_ctx(me);
 }
 
 static void _cleanup_me(struct nx_rearcam *me)
@@ -2634,10 +2611,8 @@ static void _cleanup_me(struct nx_rearcam *me)
 	_disable_vip_irq_ctx(me);
 
 	me->release_on = true;
-	cancel_work_sync(&me->work_display);
 	spin_lock_irqsave(&me->display_lock, flags);
 	spin_unlock_irqrestore(&me->display_lock, flags);
-	/*	_set_dpc_interrupt(me, false);	*/
 	_disable_dpc_irq_ctx(me);
 
 	if (me->rotation) {
@@ -2678,11 +2653,13 @@ static void _turn_on(struct nx_rearcam *me)
 
 	_setup_me(me);
 
-	_set_vip_interrupt(me, true);
 	_vip_run(me);
 
 	if (me->vendor_context && me->set_enable)
 		me->set_enable(me->vendor_context, true);
+
+	if (!me->is_mlc_on)
+		_display_init(me);
 }
 
 static void _turn_off(struct nx_rearcam *me)
@@ -2717,46 +2694,23 @@ static void _decide(struct nx_rearcam *me)
 		_turn_off(me);
 	} else if (!me->running && is_reargear_on(me)) {
 		dev_err(&me->pdev->dev, "Recheck Rear Camera!!\n");
-		schedule_delayed_work(&me->work,
-			msecs_to_jiffies(me->detect_delay));
+		tasklet_schedule(&me->work);
 	}
 }
 
-static void _work_handler_reargear(struct work_struct *work)
+static void _work_handler_reargear(void * devdata)
 {
-	struct nx_rearcam *me = container_of(work,
-				struct nx_rearcam, work.work);
+	struct nx_rearcam *me = (struct nx_rearcam *)devdata;
 
-	mutex_lock(&me->decide_work_lock);
 	_decide(me);
-	mutex_unlock(&me->decide_work_lock);
-}
-
-static void _gpio_event_worker(struct work_struct *work)
-{
-	struct nx_rearcam *me = container_of(work, struct nx_rearcam,
-				work_gpio_event);
-
-	nx_soc_gpio_clr_int_pend(PAD_GPIO_ALV + 3);
-
-	mutex_lock(&me->decide_work_lock);
-	cancel_delayed_work(&me->work);
-
-	if (!is_reargear_on(me)) {
-		schedule_delayed_work(&me->work, msecs_to_jiffies(100));
-	} else {
-		schedule_delayed_work(&me->work,
-			msecs_to_jiffies(me->detect_delay));
-	}
-	mutex_unlock(&me->decide_work_lock);
 }
 
 static irqreturn_t _irq_handler(int irq, void *devdata)
 {
 	struct nx_rearcam *me = devdata;
-
-	queue_work(me->wq_gpio_event, &me->work_gpio_event);
-
+	
+	nx_soc_gpio_clr_int_pend(PAD_GPIO_ALV + 3);
+	tasklet_schedule(&me->work);
 	return IRQ_HANDLED;
 }
 
@@ -2785,8 +2739,7 @@ static irqreturn_t _dpc_irq_handler(int irq, void *devdata)
 	spin_lock_irqsave(&me->display_lock, flags);
 
 	if ( !me->release_on )
-		queue_work(me->wq_display, &me->work_display);
-
+		_display_worker(me);
 	spin_unlock_irqrestore(&me->display_lock, flags);
 
 	return IRQ_HANDLED;
@@ -3139,7 +3092,6 @@ static void _enable_gpio_irq_ctx(struct nx_rearcam *me)
 			return;
 		}
 
-		disable_irq(me->irq_event);
 		me->is_enable_gpio_irq = true;
 	}
 }
@@ -3209,30 +3161,6 @@ static void _init_hw_mlc(struct nx_rearcam *me)
 		_set_mlc_video(me);
 }
 
-static void _init_display_worker(struct nx_rearcam *me)
-{
-	struct device *dev = &me->pdev->dev;
-
-	INIT_WORK(&me->work_display, _display_worker);
-
-	me->wq_display = create_singlethread_workqueue("wq_display");
-	if (!me->wq_display) {
-		dev_err(dev, "create display work queue error!\n");
-		return;
-	}
-}
-
-static void _deinit_display_worker(struct nx_rearcam *me)
-{
-	if (me->wq_display != NULL) {
-		cancel_work_sync(&me->work_display);
-		flush_workqueue(me->wq_display);
-		destroy_workqueue(me->wq_display);
-
-		me->wq_display = NULL;
-	}
-}
-
 static void _enable_dpc_irq_ctx(struct nx_rearcam *me)
 {
 	struct device *dev = &me->pdev->dev;
@@ -3278,52 +3206,6 @@ static bool _init_hw_dpc(struct nx_rearcam *me)
 	return false;
 }
 
-static void _init_sensor_worker(struct nx_rearcam *me)
-{
-	struct device *dev = &me->pdev->dev;
-
-	me->wq_sensor_init = create_singlethread_workqueue("wq_sensor_init");
-	if (!me->wq_sensor_init) {
-		dev_err(dev, "create sensor init work queue error!\n");
-		return;
-	}
-}
-
-static void _deinit_sensor_worker(struct nx_rearcam *me)
-{
-	if (me->wq_sensor_init != NULL) {
-		cancel_work_sync(&me->work_sensor_init);
-		flush_workqueue(me->wq_sensor_init);
-		destroy_workqueue(me->wq_sensor_init);
-
-		me->wq_sensor_init = NULL;
-	}
-}
-
-static void _init_gpio_event_worker(struct nx_rearcam *me)
-{
-	struct device *dev = &me->pdev->dev;
-
-	INIT_WORK(&me->work_gpio_event, _gpio_event_worker);
-
-	me->wq_gpio_event = create_singlethread_workqueue("wq_gpio_event");
-	if (!me->wq_gpio_event) {
-		dev_err(dev, "create gpio event work queue error!\n");
-		return;
-	}
-}
-
-static void _deinit_gpio_event_worker(struct nx_rearcam *me)
-{
-	if (me->wq_gpio_event != NULL) {
-		cancel_work_sync(&me->work_gpio_event);
-		flush_workqueue(me->wq_gpio_event);
-		destroy_workqueue(me->wq_gpio_event);
-
-		me->wq_gpio_event = NULL;
-	}
-}
-
 static int get_rotate_width_rate(struct nx_rearcam *me, enum FRAME_KIND type)
 {
 	int width = me->clipper_info.width;
@@ -3548,7 +3430,7 @@ static int _get_i2c_client(struct nx_rearcam *me)
 	return 0;
 }
 
-static int _camera_sensor_run(struct nx_rearcam *me)
+static int _init_camera_sensor(struct nx_rearcam *me)
 {
 	int ret;
 	struct reg_val *reg_val;
@@ -3556,11 +3438,10 @@ static int _camera_sensor_run(struct nx_rearcam *me)
 	int i = 0;
 
 	_get_i2c_client(me);
-
+#ifndef NX_SKIP_SENSOR_INIT
 	ret = enable_sensor_power(dev, &me->clipper_info, true);
 	if (ret < 0)
 		dev_err(&me->pdev->dev, "unable to enable sensor power!\n");
-
 	if (me->init_data) {
 		reg_val = me->init_data;
 
@@ -3572,30 +3453,55 @@ static int _camera_sensor_run(struct nx_rearcam *me)
 			reg_val++;
 		}
 	}
-
+#endif
 	if (me->sensor_init_func)
 		me->sensor_init_func(me->client);
 
 	return 0;
 }
 
-static void _sensor_init_worker(struct work_struct *work)
+static void _display_init(struct nx_rearcam *me)
 {
-	struct nx_rearcam *me = container_of(work, struct nx_rearcam,
-				work_sensor_init);
+	int module = me->clipper_info.module;
 	struct device *dev = &me->pdev->dev;
-	int ret = 0;
+	struct queue_entry *entry = NULL;
+	struct nx_video_buf *buf = NULL;
 
-	ret = _camera_sensor_run(me);
-	if (ret < 0)
-		dev_err(dev, "failed sensor initialzation!\n");
+	while(!nx_vip_get_interrupt_pending(module, 2));
+
+	entry = me->frame_set.cur_entry_vip;
+	buf = (struct nx_video_buf *)(entry->data);
+	_mlc_video_set_addr(me, buf);
+
+	/*
+	if (!me->mlc_on_first) {
+		_set_mlc_overlay(me);
+		me->mlc_on_first = true;
+	}
+	*/
+	_mlc_video_run(me);
+
+	if (!me->draw_overlay_from_ioctl) {
+		_mlc_rgb_overlay_draw(me);
+		_mlc_overlay_run(me);
+	}
+	pr_err("[%s] mlc on\n", __func__);
+	me->is_mlc_on = true;
+
+	entry =  me->q_vip_empty.dequeue(&me->q_vip_empty);
+	if (entry) {
+		buf = (struct nx_video_buf *)(entry->data);
+		_vip_hw_set_addr(module, me,
+			buf->lu_addr, buf->cb_addr, buf->cr_addr);
+		me->frame_set.cur_entry_vip = entry;
+		_set_vip_interrupt(me, true);
+		_enable_vip_irq_ctx(me);
+	} else
+		dev_err(dev, "VIP empty buffer underrun!!\n");
 }
 
-static void _display_worker(struct work_struct *work)
+static void _display_worker(struct nx_rearcam *me)
 {
-	struct nx_rearcam *me = container_of(work, struct nx_rearcam,
-				work_display);
-
 	struct nx_video_buf *buf = NULL;
 	struct queue_entry *entry = NULL;
 
@@ -3619,21 +3525,18 @@ static void _display_worker(struct work_struct *work)
 		return;
 	}
 
-	spin_lock_irqsave(&me->display_lock, flags);
 
 #if TIME_LOG
 	me->measure.dp_frame_cnt++;
 #endif
 
 	if (q_display_done->size(q_display_done) < 1) {
-		spin_unlock_irqrestore(&me->display_lock, flags);
 		return;
 	}
 
 	q_size = q_display_done->size(q_display_done);
 	entry = q_display_done->peek(q_display_done, q_size-1);
 	if (!entry) {
-		spin_unlock_irqrestore(&me->display_lock, flags);
 		return;
 	}
 
@@ -3654,7 +3557,7 @@ static void _display_worker(struct work_struct *work)
 			_mlc_rgb_overlay_draw(me);
 			_mlc_overlay_run(me);
 		}
-
+		pr_err("[%s] mlc on\n", __func__);
 		me->is_mlc_on = true;
 	}
 
@@ -3666,7 +3569,6 @@ static void _display_worker(struct work_struct *work)
 		q_display_empty->enqueue(q_display_empty, entry);
 	}
 
-	spin_unlock_irqrestore(&me->display_lock, flags);
 
 #if TIME_LOG
 	me->measure.e_time = get_jiffies_64();
@@ -3893,14 +3795,7 @@ static void _init_context(struct nx_rearcam *me)
 	if (me->rotation)
 		mutex_init(&me->rot_lock);
 
-	mutex_init(&me->decide_work_lock);
-
-	INIT_DELAYED_WORK(&me->work, _work_handler_reargear);
-	INIT_WORK(&me->work_sensor_init, _sensor_init_worker);
-
-	me->wq_gpio_event = NULL;
-	me->wq_sensor_init = NULL;
-	me->wq_display = NULL;
+	tasklet_init(&me->work, _work_handler_reargear, (void*)me);
 
 	if (me->rotation) {
 		me->wq_lu_rot = NULL;
@@ -4104,13 +3999,12 @@ static void _init_vendor(struct nx_rearcam *me)
 	me->draw_rgb_overlay		= nx_rearcam_draw_rgb_overlay;
 }
 
-static void init_hw(struct nx_rearcam *me)
+static void _init_hw_display(struct nx_rearcam *me)
 {
 	bool enable_dpc = false;
 
 	enable_dpc = _init_hw_dpc(me);
 	if (enable_dpc) {
-		/*	_reset_hw_display(me);	*/
 		_init_hw_display_top(me);
 		_init_hw_lvds(me);
 	}
@@ -4128,11 +4022,8 @@ static int init_me(struct nx_rearcam *me)
 
 	_reset_hw_display(me);
 	_init_hw_mlc(me);
-
-	_init_display_worker(me);
-	_init_gpio_event_worker(me);
-	_init_sensor_worker(me);
-
+	_init_hw_display(me);
+	_init_camera_sensor(me);
 	_enable_gpio_irq_ctx(me);
 
 	return 0;
@@ -4140,19 +4031,18 @@ static int init_me(struct nx_rearcam *me)
 
 static int deinit_me(struct nx_rearcam *me)
 {
+#ifndef NX_SKIP_SENSOR_INIT
 	if (me->init_data != NULL) {
 		kfree(me->init_data);
 		me->init_data = NULL;
 	}
-
+#endif
 	if (me->base_addr != NULL) {
 		kfree(me->base_addr);
 		me->base_addr = NULL;
 	}
 
 	if (me->removed) {
-		/*	_set_vip_interrupt(me, false);	*/
-		/*	_vip_stop(me);	*/
 		_cleanup_me(me);
 
 		if (me->rotation)
@@ -4165,9 +4055,6 @@ static int deinit_me(struct nx_rearcam *me)
 	}
 
 	_disable_gpio_irq_ctx(me);
-	_deinit_sensor_worker(me);
-	_deinit_gpio_event_worker(me);
-	_deinit_display_worker(me);
 
 	_free_buffer(me);
 
@@ -4517,14 +4404,6 @@ static int nx_rearcam_probe(struct platform_device *pdev)
 			return -ENOMEM;
 		}
 	}
-#if USED_SENSOR_INIT_WOKRER
-	/* sensor init */
-	queue_work(me->wq_sensor_init, &me->work_sensor_init);
-#else
-	ret = _camera_sensor_run(me);
-	if (ret < 0)
-		dev_err(dev, "failed sensor initialzation!\n");
-#endif
 	/* TODO : MIPI Routine */
 	platform_set_drvdata(pdev, me);
 
@@ -4533,13 +4412,7 @@ static int nx_rearcam_probe(struct platform_device *pdev)
 		return -1;
 	}
 
-	if (is_reargear_on(me))
-		schedule_delayed_work(&me->work,
-			msecs_to_jiffies(me->detect_delay));
-
-
-	/* reargear gpio enable */
-	enable_irq(me->irq_event);
+	//_enable_gpio_irq_ctx(me);
 
 #ifdef DEBUG_SYNC
 	setup_timer(&me->timer, debug_sync, (long)me);
diff --git fs/namei.c fs/namei.c
index d185869..22ed090 100644
--- fs/namei.c
+++ fs/namei.c
@@ -3717,8 +3717,13 @@ int vfs_rmdir2(struct vfsmount *mnt, struct inode *dir, struct dentry *dentry)
 	mutex_lock(&dentry->d_inode->i_mutex);
 
 	error = -EBUSY;
-	if (is_local_mountpoint(dentry))
+	/* psw0523 test */
+#if 0
+	if (is_local_mountpoint(dentry)) {
+		pr_err("%s %d: return %d\n", __func__, __LINE__, error);
 		goto out;
+	}
+#endif
 
 	error = security_inode_rmdir(dir, dentry);
 	if (error)
