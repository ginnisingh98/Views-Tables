--------------------------------------------------------
--  DDL for Package Body WMS_CAROUSEL_INTEGRATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_CAROUSEL_INTEGRATION_PKG" AS
/* $Header: WMSCSPBB.pls 120.4 2005/10/17 03:58:36 simran noship $ */

   PROCEDURE sync_device_request (
      p_request_id      IN              NUMBER,
      p_device_id       IN              NUMBER,
      p_resubmit_flag   IN              VARCHAR2,
      x_status_code     OUT NOCOPY      VARCHAR2,
      x_status_msg      OUT NOCOPY      VARCHAR2,
      x_device_status   OUT NOCOPY      VARCHAR2
   )
   IS
   BEGIN
      -- Verify access
      x_status_code := 'S';

      /* we can not really verify access here because we do not know employee_id
      wms_carousel_integration_pvt.verify_access
          (
           p_device_id,
           p_employee_id,
           x_status_code,
           x_device_status
          );
      */
      -- Allowed ?
      IF x_status_code = 'S'
      THEN
         -- Process the request
         wms_carousel_integration_pvt.process_request (p_request_id,
                                                       x_status_code,
                                                       x_status_msg,
                                                       x_device_status
                                                      );
      END IF;

      -- Update the WMS with the status
      wms_device_integration_pub.update_request
                                              (p_request_id       => p_request_id,
                                               p_device_id        => p_device_id,
                                               p_status_code      => x_status_code,
                                               p_status_msg       => x_device_status
                                              );
   END;

   --
   --
   PROCEDURE sync_device (
      p_organization_id   IN              NUMBER,
      p_device_id         IN              NUMBER,
      p_employee_id       IN              NUMBER,
      p_sign_on_flag      IN              VARCHAR2,
      x_status_code       OUT NOCOPY      VARCHAR2,
      x_device_status     OUT NOCOPY      VARCHAR2
   )
   IS
      l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
   BEGIN
      -- Singing on or off ?
      x_status_code := FND_API.G_RET_STS_SUCCESS;
      IF p_sign_on_flag = 'Y'
      THEN
         IF (l_debug > 0) THEN
           wms_carousel_integration_pvt.LOG (p_device_id, 'Employee (' || p_employee_id || ') logged on');
         END IF;
      ELSIF p_sign_on_flag = 'N'
      THEN
         IF (l_debug > 0) THEN
           wms_carousel_integration_pvt.LOG (p_device_id, 'Employee (' || p_employee_id || ') logged off');
         END IF;
      ELSE
         x_status_code := 'E';
         x_device_status := 'Invalid p_sing_on_flag';
      END IF;
   END;

   --
   --
   PROCEDURE pipe_listener_loop (p_job IN NUMBER, p_zone IN VARCHAR2, p_device_id in NUMBER, p_pipe_name IN VARCHAR2)
   IS
      v_switch   VARCHAR2 (16);
      l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      LOOP
         -- Get pipe listener switch value
         v_switch :=
            NVL
               (wms_carousel_integration_pvt.get_config_parameter
                                            (p_name      => 'PIPE_LISTENER_SWITCH',
                                             p_sequence_id      => p_device_id
                                            ),
                'OFF'
               );
         EXIT WHEN v_switch = 'OFF';
         IF (l_debug > 0) THEN
           wms_carousel_integration_pvt.LOG
             ( p_device_id, 'Calling receive_pipe_listener. p_zone='
              || p_zone
              || ', p_pipe_name='
              || p_pipe_name
              || ', p_job='
              || p_job
             );
         END IF;
         -- Call the listener
         -- Bug# 4666748
         -- wms_carousel_integration_pvt.receive_pipe_listener (p_zone, p_device_id, p_pipe_name);
      END LOOP;
      COMMIT;
   END;

   --
   --
   PROCEDURE submit_pipe_listeners(p_device_id IN NUMBER)
   IS
      -- Cursor for receive pipes
      CURSOR c_receive_pipes(p_primary_device IN NUMBER)
      IS
         SELECT d.device_id, d.subinventory_code
           FROM wms_devices_b d
           WHERE d.device_id = p_primary_device;

      v_job     INTEGER;
      job_str   VARCHAR2 (1024);
      v_pipename VARCHAR2(50);
      l_primary_device NUMBER;
      l_dummy NUMBER;
      l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
         v_pipename := wms_carousel_integration_pvt.get_config_parameter
                                            (p_name      => 'PIPE_NAME',
                                             p_sequence_id      => p_device_id
                                            );

     IF (v_pipename IS NULL) THEN
      -- No PIPE_NAME config parameter created for the device. Hence create a default one
      -- 4311016
      v_pipename := p_device_id;
      l_primary_device := p_device_id;
      INSERT INTO WMS_CAROUSEL_CONFIGURATION
	(
	CAROUSEL_CONFIGURATION_ID
	,CONFIG_NAME
	,CONFIG_VALUE
	,SEQUENCE_ID
	,ACTIVE_IND
	,LAST_UPDATE_DATE
	,LAST_UPDATED_BY
	,CREATION_DATE
	,CREATED_BY
	,LAST_UPDATE_LOGIN
	)
      VALUES
        (WMS_CAROUSEL_CONFIGURATION_S.NEXTVAL
	,'PIPE_NAME'
	,v_pipename
	,p_device_id
	,'Y'
	,SYSDATE
	,fnd_global.user_id
	,SYSDATE
	,fnd_global.user_id
	,fnd_global.login_id
	);
        IF (l_debug > 0) THEN
           wms_carousel_integration_pvt.LOG (p_device_id, 'No PIPE_NAME parameter defined for device ('
					  || p_device_id || ')! Hence created one with value='
					  || v_pipename
                                          );
        END IF;
     ELSE
	-- Get the first device in the group
	SELECT MIN(SEQUENCE_ID) into l_primary_device FROM WMS_CAROUSEL_CONFIGURATION
	WHERE CONFIG_NAME = 'PIPE_NAME'
	AND CONFIG_VALUE = v_pipename;
     END IF;

      --4311016
      v_pipename := 'IN_'||v_pipename;

      -- Start up listeners
      FOR v_cfg IN c_receive_pipes(l_primary_device)
      LOOP
	BEGIN
		select 1 INTO l_dummy from (
		 SELECT job,what, (substr(what, instr(what,'''',-1,2)+1, (instr(what,'''',-1,1) - instr(what,'''',-1,2) - 1))) pipe_name
		   FROM user_jobs
		  WHERE UPPER (what) LIKE '%WMS_CAROUSEL_INTEGRATION_PKG.PIPE_LISTENER_LOOP%')
		where pipe_name = v_pipename;
		IF (l_debug > 0) THEN
		  WMS_CAROUSEL_INTEGRATION_PVT.LOG (v_cfg.device_id, 'Job already exists:'
						   || ' ID='
						   || v_job
						   || ', Pipe='
						   || v_pipename
						   || ', Subinventory='
						   || v_cfg.subinventory_code
						  );
                END IF;
	EXCEPTION
	WHEN NO_DATA_FOUND THEN
		 -- Submit a job
		 DBMS_JOB.submit (job            => v_job,
				  what           => 'begin null; end;',
				  next_date      => SYSDATE,
				  INTERVAL       => 'sysdate + (10/(24*3600))'
				 );
		 job_str :=
		       'WMS_CAROUSEL_INTEGRATION_PKG.PIPE_LISTENER_LOOP('
		    || v_job
		    || ',''' || v_cfg.subinventory_code || ''''
		    || ',' || v_cfg.device_id
		    || ',''' || v_pipename || ''');';

		 DBMS_JOB.what (v_job, job_str);

		 IF (l_debug > 0) THEN
		   WMS_CAROUSEL_INTEGRATION_PVT.LOG (v_cfg.device_id, 'New Job Created:'
						   || ' ID='
						   || v_job
						   || ', Pipe='
						   || v_pipename
						   || ', Subinventory='
						   || v_cfg.subinventory_code
						  );
                 END IF;
	END;
      END LOOP;
      COMMIT;
   END;

   PROCEDURE start_job(p_device_id IN NUMBER)
   IS
      -- Cursor for receive pipes
      CURSOR c_pipe_listeners (p_pipe_name IN VARCHAR2)
      IS
        select distinct * from (
         SELECT job,what, (substr(what, instr(what,'''',-1,2)+1, (instr(what,'''',-1,1) - instr(what,'''',-1,2) - 1))) pipe_name
           FROM user_jobs
          WHERE UPPER (what) LIKE '%WMS_CAROUSEL_INTEGRATION_PKG.PIPE_LISTENER_LOOP%')
        where pipe_name = nvl(p_pipe_name, pipe_name);

      v_pipename VARCHAR2(50);
      l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
     IF (p_device_id IS NOT NULL) THEN
         v_pipename :=
            NVL
               (wms_carousel_integration_pvt.get_config_parameter
                                            (p_name      => 'PIPE_NAME',
                                             p_sequence_id      => p_device_id
                                            ),
                'PIPE_NAME_' || p_device_id
               );
     END IF;
      -- Start jobs
      FOR v_job IN c_pipe_listeners(v_pipename)
      LOOP
         -- Start the job
         DBMS_JOB.broken(v_job.job,false,null);
         IF (l_debug > 0) THEN
           wms_carousel_integration_pvt.LOG ( p_device_id,  'Job Started:'
                                           || ' ID='
                                           || v_job.job
                                           || ', Pipe='
                                           || v_job.pipe_name
                                          );
         END IF;
      END LOOP;

      COMMIT;
   END;

   PROCEDURE stop_job(p_device_id IN NUMBER)
   IS
      -- Cursor for receive pipes
      CURSOR c_pipe_listeners (p_pipe_name IN VARCHAR2)
      IS
        select * from (
         SELECT job,what, (substr(what, instr(what,'''',-1,2)+1, (instr(what,'''',-1,1) - instr(what,'''',-1,2) - 1))) pipe_name
           FROM user_jobs
          WHERE UPPER (what) LIKE '%WMS_CAROUSEL_INTEGRATION_PKG.PIPE_LISTENER_LOOP%')
        where pipe_name = nvl(p_pipe_name, pipe_name);

      v_pipename VARCHAR2(50) := NULL;
      l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
     IF (p_device_id IS NOT NULL) THEN
         v_pipename :=
            NVL
               (wms_carousel_integration_pvt.get_config_parameter
                                            (p_name      => 'PIPE_NAME',
                                             p_sequence_id      => p_device_id
                                            ),
                'PIPE_NAME_' || p_device_id
               );
     END IF;
      -- Stop jobs
      FOR v_job IN c_pipe_listeners(v_pipename)
      LOOP
         -- Stop the job
         DBMS_JOB.broken(v_job.job,true,null);
         IF (l_debug > 0) THEN
           wms_carousel_integration_pvt.LOG ( p_device_id,  'Job Stopped:'
                                           || ' ID='
                                           || v_job.job
                                           || ', Pipe='
                                           || v_job.pipe_name
                                          );
         END IF;
      END LOOP;

      COMMIT;
   END;
   --
   --
   PROCEDURE remove_pipe_listeners
   IS
      -- Cursor for receive pipes
      CURSOR c_pipe_listeners
      IS
         SELECT job, what
           FROM user_jobs
          WHERE UPPER (what) LIKE '%WMS_CAROUSEL_INTEGRATION_PKG.PIPE_LISTENER_LOOP%';

      l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      -- Remove jobs
      FOR v_job IN c_pipe_listeners
      LOOP
         -- Remove the job
         DBMS_JOB.remove (v_job.job);
         IF (l_debug > 0) THEN
           wms_carousel_integration_pvt.LOG ( NULL,  'Job Removed:'
                                           || ' ID='
                                           || v_job.job
                                           || ', what='
                                           || v_job.what
                                          );
         END IF;
      END LOOP;
      COMMIT;
   END;

   PROCEDURE recreate_pipe_listeners
   IS
     CURSOR C_PIPE_DEVICES IS SELECT SEQUENCE_ID FROM WMS_CAROUSEL_CONFIGURATION
     WHERE CONFIG_NAME = 'PIPE_NAME';
   BEGIN
      remove_pipe_listeners;
      FOR v_job IN C_PIPE_DEVICES
      LOOP
        submit_pipe_listeners(v_job.SEQUENCE_ID);
      END LOOP;
   END;

   --
   --
   PROCEDURE START_PIPE_LISTENERS(p_device_id IN NUMBER DEFAULT NULL)
   IS
      v_pipename VARCHAR2(50);
      l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      IF (p_device_id IS NULL) THEN
	-- Switch on all listeners
	UPDATE WMS_CAROUSEL_CONFIGURATION c
	SET c.CONFIG_VALUE = 'ON'
	WHERE c.CONFIG_NAME = 'PIPE_LISTENER_SWITCH';
        IF (l_debug > 0) THEN
	  wms_carousel_integration_pvt.LOG (null,'All Pipe Listeners Switched ON');
        END IF;
      ELSE
	v_pipename :=
	NVL
	(wms_carousel_integration_pvt.get_config_parameter
				    (p_name      => 'PIPE_NAME',
				     p_sequence_id      => p_device_id
				    ),
	'PIPE_NAME_' || p_device_id
	);
	-- Switch on
	UPDATE WMS_CAROUSEL_CONFIGURATION c
	SET c.CONFIG_VALUE = 'ON'
	WHERE c.CONFIG_NAME = 'PIPE_LISTENER_SWITCH'
	AND SEQUENCE_ID IN (SELECT SEQUENCE_ID FROM wms_carousel_configuration WHERE CONFIG_VALUE = v_pipename);
        IF (l_debug > 0) THEN
	  wms_carousel_integration_pvt.LOG (p_device_id,'Pipe Listener Switched ON: Pipe=IN_' || v_pipename);
        END IF;
      END IF;
      start_job(p_device_id);
      COMMIT;
   END;

   --
   --
   PROCEDURE STOP_PIPE_LISTENERS(p_device_id IN NUMBER DEFAULT NULL)
   IS
      v_pipename VARCHAR2(50);
      l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      IF (p_device_id IS NULL) THEN
	-- Switch off all listeners
	UPDATE WMS_CAROUSEL_CONFIGURATION c
	SET c.CONFIG_VALUE = 'OFF'
	WHERE c.CONFIG_NAME = 'PIPE_LISTENER_SWITCH';
        IF (l_debug > 0) THEN
	  WMS_CAROUSEL_INTEGRATION_PVT.LOG (null,'All Pipe Listeners Switched OFF');
        END IF;
      ELSE
	v_pipename :=
	NVL
	(wms_carousel_integration_pvt.get_config_parameter
				    (p_name      => 'PIPE_NAME',
				     p_sequence_id      => p_device_id
				    ),
	'PIPE_NAME_' || p_device_id
	);
	-- Switch off
	UPDATE WMS_CAROUSEL_CONFIGURATION c
	SET c.CONFIG_VALUE = 'OFF'
	WHERE c.CONFIG_NAME = 'PIPE_LISTENER_SWITCH'
	AND SEQUENCE_ID IN (SELECT SEQUENCE_ID FROM WMS_CAROUSEL_CONFIGURATION WHERE CONFIG_VALUE = v_pipename);
        IF (l_debug > 0) THEN
	  WMS_CAROUSEL_INTEGRATION_PVT.LOG (p_device_id,'Pipe Listener Switched OFF: Pipe=IN_' || v_pipename);
        END IF;
      END IF;
      stop_job(p_device_id);
      COMMIT;
   END;
--
   PROCEDURE SIGN_OFF_USER(p_organization_id IN NUMBER,
			p_device_id IN NUMBER,
			p_emp_id IN NUMBER,
			x_return_status OUT NOCOPY VARCHAR2
   )
   IS
		CURSOR c_tasks IS
			SELECT  1 FROM WMS_DISPATCHED_TASKS wdt
			WHERE	organization_id 	 = p_organization_id
			AND device_id			 = p_device_id
			AND PERSON_ID           = p_emp_id
			AND status = 9;
		l_dummy NUMBER;
                l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
		PRAGMA AUTONOMOUS_TRANSACTION;
	BEGIN
                --wms_carousel_integration_pvt.LOG ( p_device_id,  'In SIGN_OFF_USER Org=' || p_organization_id || ',employee (' || p_emp_id || ') from device_id (' || p_device_id || ')');
		x_return_status := 'S';
		Open c_tasks;
		Fetch c_tasks into l_dummy;
		IF (c_tasks%NOTFOUND) THEN
                  IF (l_debug > 0) THEN
	            wms_carousel_integration_pvt.LOG ( p_device_id,  'Signing off employee (' || p_emp_id || ') from device_id (' || p_device_id || ')');
                  END IF;

		  DELETE FROM wms_device_assignment_temp WHERE device_id = p_device_id and EMPLOYEE_ID = p_emp_id;
  		  COMMIT;
		ELSE
                  IF (l_debug > 0) THEN
	            wms_carousel_integration_pvt.LOG ( p_device_id,  'Failed signing off employee (' || p_emp_id || ') from device_id (' || p_device_id || ')');
                  END IF;
		  x_return_status := 'A';
		END IF;
		CLOSE c_tasks;
   END;
--
END WMS_CAROUSEL_INTEGRATION_PKG;

/
