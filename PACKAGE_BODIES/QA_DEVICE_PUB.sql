--------------------------------------------------------
--  DDL for Package Body QA_DEVICE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_DEVICE_PUB" AS
/* $Header: qadvpubb.pls 120.5.12010000.2 2009/04/30 07:50:24 skolluku ship $ */

--
-- Safe Globals
--
g_user_name_cache  fnd_user.user_name%TYPE := NULL;
g_user_id_cache    NUMBER;
g_pkg_name         CONSTANT VARCHAR2(30):= 'qa_device_pub';

--
-- General utility functions
--

FUNCTION get_user_id(p_name IN VARCHAR2) RETURN NUMBER IS
--
-- Decode user name from fnd_user table.
--
    id NUMBER;

    CURSOR user_cursor IS
        SELECT user_id
        FROM fnd_user
        WHERE user_name = p_name;
BEGIN
    IF p_name IS NULL THEN
        RETURN nvl(fnd_global.user_id, -1);
    END IF;

    --
    -- It is very common for the same user to call the
    -- APIs successively.
    --
    IF g_user_name_cache = p_name THEN
        RETURN g_user_id_cache;
    END IF;

    OPEN user_cursor;
    FETCH user_cursor INTO id;
    IF user_cursor%NOTFOUND THEN
        CLOSE user_cursor;
        RETURN -1;
    END IF;
    CLOSE user_cursor;

    g_user_name_cache := p_name;
    g_user_id_cache := id;

    RETURN id;
END get_user_id;


PROCEDURE set_device_data(
    p_api_version               IN  NUMBER,
    p_init_msg_list             IN  VARCHAR2,
    p_validation_level          IN  NUMBER,
    p_user_name                 IN  VARCHAR2,
    p_device_source             IN  VARCHAR2,
    p_device_name               IN  VARCHAR2,
    p_device_data               IN  VARCHAR2,
    p_device_event_time         IN  DATE,
    p_quality_code              IN  NUMBER,
    p_commit                    IN  VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2,
    x_return_status             OUT NOCOPY VARCHAR2) IS

  	l_api_version               NUMBER := 1.0;
  	l_user_id                   NUMBER;
  	l_api_name          CONSTANT VARCHAR2(30)   := 'set_device_data';

BEGIN

  	-- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call(
        l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
        RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
        fnd_msg_pub.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    l_user_id := get_user_id(p_user_name);
    IF l_user_id = -1 THEN
        fnd_message.set_name('QA', 'QA_API_INVALID_USER');
        fnd_msg_pub.add();
        raise fnd_api.g_exc_error;
    END IF;

		UPDATE qa_device_data_values
    SET event_data = p_device_data,
      event_time = systimestamp,
      event_generation_time = p_device_event_time,
      quality_code = p_quality_code,
      last_updated_by = l_user_id,
      last_update_login = l_user_id,
      last_update_date = sysdate
    WHERE device_name = p_device_name
     AND device_source = p_device_source;

		IF sql%rowcount = 0 THEN
      fnd_message.set_name('QA', 'QA_DEV_INSERT_FAILED');
   		fnd_message.set_token('DEVNAME',p_device_name);
      fnd_msg_pub.add();
      raise fnd_api.g_exc_error;
    END IF;

		IF fnd_api.to_boolean(p_commit) THEN
        COMMIT;
    END IF;
EXCEPTION

    WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;
        fnd_msg_pub.count_and_get(
            p_count => x_msg_count,
            p_data  => x_msg_data
        );

     WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get(
            p_count => x_msg_count,
            p_data  => x_msg_data
        );

     WHEN others THEN
     		fnd_message.set_name('QA', 'QA_DEV_INSERT_FAILED');
     		fnd_message.set_token('DEVNAME',p_device_name);
        fnd_msg_pub.add();
        x_return_status := fnd_api.g_ret_sts_error;
        fnd_msg_pub.count_and_get(
            p_count => x_msg_count,
            p_data  => x_msg_data
        );

END set_device_data;



PROCEDURE set_device_data_bulk(
    p_api_version               IN  NUMBER,
    p_init_msg_list             IN  VARCHAR2,
    p_validation_level          IN  NUMBER,
    p_user_name                 IN  VARCHAR2,
    p_device_source             IN  VARCHAR2,
    p_device_name               IN  VARCHAR2_TABLE,
    p_device_data               IN  VARCHAR2_TABLE,
    p_device_event_time         IN  DATE_TABLE,
    p_quality_code              IN  NUMBER_TABLE,
    p_commit                    IN  VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2,
    x_return_status             OUT NOCOPY VARCHAR2) IS

  	l_api_version               NUMBER := 1.0;
  	l_user_id                   NUMBER;
  	l_api_name          CONSTANT VARCHAR2(30)   := 'set_device_data_bulk';

  	l_err_device_names          VARCHAR2(2000) := NULL;

BEGIN

		 -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call(
        l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
        RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
        fnd_msg_pub.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    l_user_id := get_user_id(p_user_name);
    IF l_user_id = -1 THEN
        fnd_message.set_name('QA', 'QA_API_INVALID_USER');
        fnd_msg_pub.add();
        raise fnd_api.g_exc_error;
    END IF;

    -- Check if data for all devices has been passed.
    IF p_device_name.COUNT <> p_device_data.COUNT
      OR p_device_name.COUNT <> p_device_event_time.COUNT
      OR p_device_name.COUNT <> p_quality_code.COUNT THEN
    	  fnd_message.set_name('QA', 'QA_DEV_INCOMPLETE_DATA');
        fnd_msg_pub.add();
        raise fnd_api.g_exc_error;
    END IF;

		FORALL i IN p_device_name.FIRST..p_device_name.LAST SAVE EXCEPTIONS
		 UPDATE qa_device_data_values
		 SET event_data = p_device_data(i),
  		 event_time = systimestamp,
  		 event_generation_time = p_device_event_time(i),
  		 quality_code = p_quality_code(i),
  		 last_updated_by = l_user_id,
  		 last_update_login = l_user_id,
  		 last_update_date = sysdate
		 WHERE device_name = p_device_name(i)
 		  AND device_source = p_device_source;

		FOR cntr IN p_device_name.FIRST..p_device_name.LAST
		LOOP
			IF sql%bulk_rowcount(cntr) = 0 THEN
        IF l_err_device_names IS NULL THEN
        	l_err_device_names := p_device_name(cntr);
        ELSE
        	l_err_device_names := l_err_device_names || ',' || p_device_name(cntr);
        END IF;
			END IF;
		END LOOP;

		IF fnd_api.to_boolean(p_commit) THEN
        COMMIT;
    END IF;

    IF l_err_device_names IS NOT NULL THEN
    	fnd_message.set_name('QA', 'QA_DEV_INSERT_FAILED');
     	fnd_message.set_token('DEVNAME',l_err_device_names);
      fnd_msg_pub.add();
      raise fnd_api.g_exc_error;
    END IF;
EXCEPTION

    WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;
        fnd_msg_pub.count_and_get(
            p_count => x_msg_count,
            p_data  => x_msg_data
        );

     WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get(
            p_count => x_msg_count,
            p_data  => x_msg_data
        );

     WHEN others THEN
     	  FOR err_cntr IN 1..SQL%BULK_EXCEPTIONS.COUNT LOOP
     	  	IF l_err_device_names IS NULL THEN
     	  		l_err_device_names := p_device_name(SQL%BULK_EXCEPTIONS(err_cntr).ERROR_INDEX);
     	  	ELSE
     	  		l_err_device_names := l_err_device_names || ',' || p_device_name(SQL%BULK_EXCEPTIONS(err_cntr).ERROR_INDEX);
     	  	END IF;
     	  END LOOP;
     		fnd_message.set_name('QA', 'QA_DEV_INSERT_FAILED');
     		fnd_message.set_token('DEVNAME',l_err_device_names);
        fnd_msg_pub.add();
        x_return_status := fnd_api.g_ret_sts_error;
        fnd_msg_pub.count_and_get(
            p_count => x_msg_count,
            p_data  => x_msg_data
        );

END set_device_data_bulk;


PROCEDURE add_device_info_bulk(
    p_api_version               IN  NUMBER,
    p_init_msg_list             IN  VARCHAR2,
    p_validation_level          IN  NUMBER,
    p_user_name                 IN  VARCHAR2,
    p_device_source             IN  VARCHAR2,
    p_device_name               IN  VARCHAR2_TABLE,
    p_device_desc               IN  VARCHAR2000_TABLE,
    p_expiration                IN  NUMBER_TABLE,
    p_commit                    IN  VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2,
    x_return_status             OUT NOCOPY VARCHAR2) IS

  	l_api_version               NUMBER := 1.0;
  	l_user_id                   NUMBER;
  	l_api_name          CONSTANT VARCHAR2(30)   := 'add_device_info_bulk';
  	exists_count                NUMBER;
BEGIN

	  -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call(
        l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
        RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
        fnd_msg_pub.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    l_user_id := get_user_id(p_user_name);
    IF l_user_id = -1 THEN
        fnd_message.set_name('QA', 'QA_API_INVALID_USER');
        fnd_msg_pub.add();
        raise fnd_api.g_exc_error;
    END IF;

    -- Check if data for all devices has been passed.
    IF p_device_name.COUNT <> p_device_desc.COUNT OR p_device_name.COUNT <> p_expiration.COUNT THEN
    	  fnd_message.set_name('QA', 'QA_DEV_INCOMPLETE_DATA');
        fnd_msg_pub.add();
        raise fnd_api.g_exc_error;
    END IF;

    --
    -- Bug 7661085
    -- Trimming the length of the elapsed time to 15 characters.
    -- skolluku
    --
    FORALL i IN p_device_name.FIRST..p_device_name.LAST SAVE EXCEPTIONS
     UPDATE qa_device_info
      SET enabled_flag = 1,
          description = p_device_desc(i),
          elapsed_time = to_number(substr(p_expiration(i), 1, 15)),
          last_updated_by = l_user_id,
  		    last_update_login = l_user_id,
  		    last_update_date = sysdate
  	WHERE device_name = p_device_name(i)
  	 AND sensor_alias = p_device_source;

    --
    -- Bug 7661085
    -- Trimming the length of the elapsed time to 15 characters.
    -- skolluku
    --
  	FOR cntr IN p_device_name.FIRST..p_device_name.LAST LOOP
  	  IF SQL%BULK_ROWCOUNT(cntr) = 0 THEN
  	    -- Insert device if it does not exist.
  	    INSERT INTO qa_device_info(
  	         device_id,
  	         device_name,
  	         description,
  	         sensor_alias,
  	         elapsed_time,
  	         override_flag,
  	         enabled_flag,
  	         created_by,
  	         creation_date,
  	         last_update_login,
  	         last_update_date,
  	         last_updated_by)
        VALUES(
             qa_device_info_s.nextval,
             p_device_name(cntr),
             p_device_desc(cntr),
             p_device_source,
             to_number(substr(p_expiration(cntr), 1, 15)),
             2,
             1,
             l_user_id,
             sysdate,
             l_user_id,
             sysdate,
             l_user_id);
      END IF;

      SELECT COUNT(device_name)
    	INTO exists_count
    	FROM qa_device_data_values
    	WHERE device_name = p_device_name(cntr)
     	 AND device_source = p_device_source;

      IF exists_count = 0 THEN
       --Insert a new row for the device in QA_DEVICE_DATA_VALUES table if it is not already present.
       INSERT INTO qa_device_data_values(
	       device_name,
	       device_source,
	       event_data,
	       event_time,
	       event_generation_time,
	       quality_code,
	       created_by,
	       creation_date,
	       last_update_login,
	       last_update_date,
	       last_updated_by)
	     VALUES(
	       p_device_name(cntr),
	       p_device_source,
	       '-1',
	       systimestamp,
	       sysdate,
	       -1,
	       l_user_id,
	       sysdate,
	       l_user_id,
	       sysdate,
	       l_user_id);
      END IF;
  	END LOOP;


		IF fnd_api.to_boolean(p_commit) THEN
        COMMIT;
    END IF;

EXCEPTION

    WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;
        fnd_msg_pub.count_and_get(
            p_count => x_msg_count,
            p_data  => x_msg_data
        );

     WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get(
            p_count => x_msg_count,
            p_data  => x_msg_data
        );

END add_device_info_bulk;


PROCEDURE delete_device_info_bulk(
    p_api_version               IN  NUMBER,
    p_init_msg_list             IN  VARCHAR2,
    p_validation_level          IN  NUMBER,
    p_user_name                 IN  VARCHAR2,
    p_device_source             IN  VARCHAR2,
    p_device_name               IN  VARCHAR2_TABLE,
    p_commit                    IN  VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2,
    x_return_status             OUT NOCOPY VARCHAR2) IS

  	l_api_version               NUMBER := 1.0;
  	l_user_id                   NUMBER;
  	l_api_name          CONSTANT VARCHAR2(30)   := 'delete_device_info_bulk';

  	l_init_msg_list             VARCHAR2(10);
  	l_validation_level          NUMBER;
  	l_commit                    VARCHAR2(10);

BEGIN

	  -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call(
        l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
        RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean(p_init_msg_list) THEN
        fnd_msg_pub.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := fnd_api.g_ret_sts_success;

    l_user_id := get_user_id(p_user_name);
    IF l_user_id = -1 THEN
        fnd_message.set_name('QA', 'QA_API_INVALID_USER');
        fnd_msg_pub.add();
        raise fnd_api.g_exc_error;
    END IF;

    --Disable all required devices
    FORALL i IN p_device_name.FIRST..p_device_name.LAST SAVE EXCEPTIONS
     UPDATE qa_device_info
     SET enabled_flag = 2,
         last_updated_by = l_user_id,
  		   last_update_login = l_user_id,
  		   last_update_date = sysdate
     WHERE device_name = p_device_name(i)
      AND sensor_alias = p_device_source;

    --Remove corresponding row from qa_device_data_values
    FORALL i IN p_device_name.FIRST..p_device_name.LAST SAVE EXCEPTIONS
     DELETE FROM qa_device_data_values
     WHERE device_name = p_device_name(i)
      AND device_source = p_device_source;

		IF fnd_api.to_boolean(p_commit) THEN
        COMMIT;
    END IF;

EXCEPTION

    WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;
        fnd_msg_pub.count_and_get(
            p_count => x_msg_count,
            p_data  => x_msg_data
        );

     WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get(
            p_count => x_msg_count,
            p_data  => x_msg_data
        );

END delete_device_info_bulk;


END qa_device_pub;

/
