#!/usr/bin/env roseus

(require :unittest "lib/llib/unittest.l")
(init-unit-test)

(load "package://fetcheus/fetch-interface.l")

(setq *ri* (instance fetch-interface :init))
(setq *fetch* (fetch))
(send *fetch* :reset-pose)


(deftest test-fetch-state-worldcoords ()
  (let ((coords (send *ri* :state :worldcoords "base_link")))
    (assert coords (format nil "failed to get :state :worldcoords" coords))))

(deftest test-fetch-moveit ()
  (let (tm-0 tm-1)
    (setq tm-0 (ros::time-now))
    (while (null (send *ri* :angle-vector #f(0 0 0 0 0 0 0 0 0 0))))
    (send *ri* :wait-interpolation)
    (setq tm-1 (ros::time-now))
    (ros::ros-info "time for duration ~A" (send (ros::time- tm-1 tm-0) :to-sec))
    (assert (> (send (ros::time- tm-1 tm-0) :to-sec) 3) "collsion avoidance motion is too fast")

    (setq tm-0 (ros::time-now))
    (while (null (send *ri* :angle-vector (send *fetch* :reset-pose) 2000)))
    (send *ri* :wait-interpolation)
    (setq tm-1 (ros::time-now))
    (ros::ros-info "time for duration ~A" (send (ros::time- tm-1 tm-0) :to-sec))
    (assert (> (send (ros::time- tm-1 tm-0) :to-sec) 3) "collsion avoidance motion is too fast")

    (setq tm-0 (ros::time-now))
    (while (null (send *ri* :angle-vector #f(0 0 0 0 0 0 0 0 0 0))))
    (send *ri* :wait-interpolation)
    (setq tm-1 (ros::time-now))
    (ros::ros-info "time for duration ~A" (send (ros::time- tm-1 tm-0) :to-sec))
    (assert (> (send (ros::time- tm-1 tm-0) :to-sec) 3) "collsion avoidance motion is too fast")

    (setq tm-0 (ros::time-now))
    (while (null (send *ri* :angle-vector (send *fetch* :reset-pose) 2000 :use-torso t)))
    (send *ri* :wait-interpolation)
    (setq tm-1 (ros::time-now))
    (ros::ros-info "time for duration ~A" (send (ros::time- tm-1 tm-0) :to-sec))
    (assert (> (send (ros::time- tm-1 tm-0) :to-sec) 3) "collsion avoidance motion is too fast")
    ))

(deftest test-fetch-moveit-angle-vector-start-time ()
  (let (tm-0 tm-1 tm-diff)
    (send *ri* :angle-vector (send *fetch* :reset-pose))
    (send *ri* :wait-interpolation)
    (send *fetch* :rarm :move-end-pos #f(50 0 0) :world)
    (send *ri* :angle-vector (send *fetch* :angle-vector) 2000 nil 4)
    (setq tm-0 (ros::time-now))
    (send *ri* :wait-interpolation)
    (setq tm-1 (ros::time-now))
    (setq tm-diff (send (ros::time- tm-1 tm-0) :to-sec))
    (ros::ros-info "time for duration ~A" tm-diff)
    (assert (> tm-diff 4.5) (format nil "start-time is ignored. Traj finishes at ~A" tm-diff))
    (assert (< tm-diff 8) (format nil "start-time is considered multiple times. Traj finishes at ~A" tm-diff))
    (send *ri* :angle-vector (send *fetch* :reset-pose) 2000 nil 4 :start-offset-time 0)
    (setq tm-0 (ros::time-now))
    (send *ri* :wait-interpolation)
    (setq tm-1 (ros::time-now))
    (setq tm-diff (send (ros::time- tm-1 tm-0) :to-sec))
    (ros::ros-info "time for duration ~A" tm-diff)
    (assert (< tm-diff 4) (format nil "start-offset-time cannot overwrite start-time. Traj finishes at ~A" tm-diff))
    ))

(deftest test-fetch-moveit-angle-vector-sequence-start-time ()
  (let (avs tm-0 tm-1 tm-diff)
    (send *ri* :angle-vector (send *fetch* :reset-pose))
    (send *ri* :wait-interpolation)
    (push (send *fetch* :rarm :move-end-pos #f(50 0 0) :world) avs)
    (push (send *fetch* :rarm :move-end-pos #f(50 0 0) :world) avs)
    (setq avs (reverse avs))
    (send *ri* :angle-vector-sequence avs 2000 nil 4)
    (setq tm-0 (ros::time-now))
    (send *ri* :wait-interpolation)
    (setq tm-1 (ros::time-now))
    (setq tm-diff (send (ros::time- tm-1 tm-0) :to-sec))
    (ros::ros-info "time for duration ~A" tm-diff)
    (assert (> tm-diff 4.5) (format nil "start-time is ignored. Traj finishes at ~A" tm-diff))
    (assert (< tm-diff 8) (format nil "start-time is considered multiple times. Traj finishes at ~A" tm-diff))
    (send *ri* :angle-vector-sequence avs 2000 nil 4 :start-offset-time 0)
    (setq tm-0 (ros::time-now))
    (send *ri* :wait-interpolation)
    (setq tm-1 (ros::time-now))
    (setq tm-diff (send (ros::time- tm-1 tm-0) :to-sec))
    (ros::ros-info "time for duration ~A" tm-diff)
    (assert (< tm-diff 4) (format nil "start-offset-time cannot overwrite start-time. Traj finishes at ~A" tm-diff))
    ))

(run-all-tests)
(exit)
