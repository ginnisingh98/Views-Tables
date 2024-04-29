--------------------------------------------------------
--  DDL for Package Body OTA_TIMEZONE_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TIMEZONE_UPGRADE" AS
   /* $Header: ottznupg.pkb 120.10 2006/09/04 11:38:45 niarora noship $ */
  l_upgrade_name constant VARCHAR2(30) := 'OTTZUPG';
  log_type_i constant VARCHAR2(30) := 'I';
  -- log type is Information
  log_type_n constant VARCHAR2(30) := 'N';
  -- log type is Internal
  log_type_e constant VARCHAR2(30) := 'E';
  -- log type is Error
  l_time_zone ota_events.timezone%TYPE;
  l_primary_venue ota_events.location_id%TYPE;
  l_loc_id ota_suppliable_resources.location_id%TYPE;
  l_trng_center_id ota_suppliable_resources.training_center_id%TYPE;
  l_err_msg VARCHAR2(2000);
  l_err VARCHAR2(2000);
  l_err_code VARCHAR2(72);
  l_msg VARCHAR2(200);
  l_others_msg VARCHAR2(200);
  l_default_msg VARCHAR2(200) := 'Value for the Default timezone is missing';

  FUNCTION get_location_tz(l_location_id IN ota_suppliable_resources.location_id%TYPE)
  RETURN VARCHAR2
  IS

  l_time_zone ota_events.timezone%TYPE;

  CURSOR csr_loc_tz(loc_id NUMBER) IS
  SELECT timezone_code
  FROM hr_locations
  WHERE location_id = loc_id;
  BEGIN

    OPEN csr_loc_tz(l_location_id);

    FETCH csr_loc_tz
    INTO l_time_zone;

    IF csr_loc_tz % NOTFOUND THEN
      l_time_zone := NULL;
    END IF;

    CLOSE csr_loc_tz;

    RETURN l_time_zone;
  END;

  PROCEDURE validate_proc_for_tz_upg(do_upg OUT nocopy VARCHAR2)
  IS
  ota_application_id constant NUMBER := 810;
  ota_status_installed constant VARCHAR2(2) := 'I';
  l_installed fnd_product_installations.status%TYPE;

  CURSOR csr_ota_installed IS
  SELECT fpi.status
  FROM fnd_product_installations fpi
  WHERE fpi.application_id = ota_application_id;

  l_do_submit VARCHAR2(10) := 'FALSE';
  l_raise_error boolean := FALSE;
  l_status VARCHAR2(1) := 'N';
  BEGIN

    OPEN csr_ota_installed;

    FETCH csr_ota_installed
    INTO l_installed;

    IF NOT(l_installed = ota_status_installed) THEN
      l_do_submit := 'FALSE';
    END IF;

    CLOSE csr_ota_installed;

    pay_core_utils.get_upgrade_status(NULL,   'OTATZUPG',   l_status,   l_raise_error);

    IF l_status <> 'Y' THEN
      l_do_submit := 'TRUE';
    END IF;

    do_upg := l_do_submit;
  END validate_proc_for_tz_upg;

  PROCEDURE get_location_trngcenter_id(l_supplied_resource_id IN ota_suppliable_resources.supplied_resource_id%TYPE,
  									l_location_id OUT nocopy ota_suppliable_resources.location_id%TYPE,
									   l_trng_center_id OUT nocopy ota_suppliable_resources.training_center_id%TYPE)
IS
  BEGIN
    SELECT location_id,
      training_center_id
    INTO l_location_id,
      l_trng_center_id
    FROM ota_suppliable_resources
    WHERE supplied_resource_id = l_supplied_resource_id;

  EXCEPTION
  WHEN others THEN
    l_location_id := NULL;
    l_trng_center_id := NULL;
  END get_location_trngcenter_id;

  PROCEDURE write_log(msg IN VARCHAR2) IS
  BEGIN
    fnd_file.PUT_LINE(fnd_file.LOG,   msg);
  END write_log;

  PROCEDURE upd_classic_data(p_event_id ota_events.event_id%TYPE,
  					p_event_type ota_events.event_type%TYPE,
					 p_public_event_flag ota_events.public_event_flag%TYPE,
					 l_upgrade_id NUMBER)
 IS
  --bug 5157917

  CURSOR csr_lrnr_acc IS
  SELECT 1
  FROM ota_event_associations
  WHERE event_id = p_event_id;

  v_pblc_evt_flg VARCHAR2(10) := 'Y';
  v_dummy NUMBER;
  -- bug 5157917
  BEGIN
    l_msg := 'Error occurred while upgrading the timezone of events';

    -----***************
    -- Upgrade OM Events
    -- 1) set book_independent_flag to N iff null
    -- 2) Maximum_internal_attendees to 0 for price basis in 'C' or 'O'
    -- Update TIMEZONE for iLearning imported events to
    -- the corresponding APPS (FND_TIMEZONES_VL) timezone code.

    UPDATE ota_events
    SET book_independent_flag = nvl(book_independent_flag,   'N'),
      secure_event_flag = nvl(secure_event_flag,   'N'),
      maximum_internal_attendees = decode(price_basis,   'C',   0,   'O',   0,   maximum_internal_attendees),
      timezone = decode(offering_id,   NULL,   timezone,   ota_classic_upgrade.get_apps_timezone(timezone))
    WHERE event_id = p_event_id;
    ------*************** bug 5157917
    -- Upgrade Events
    -- 1) set public_event_flag to Y iff null and no learner access exists
    -- 2) set public_event_flag to N iff null and learner access exists.

    IF p_event_type = 'SELFPACED'
     AND p_public_event_flag IS NULL THEN

      OPEN csr_lrnr_acc;
      FETCH csr_lrnr_acc
      INTO v_dummy;

      IF csr_lrnr_acc % FOUND THEN
        v_pblc_evt_flg := 'N';
      END IF;

      CLOSE csr_lrnr_acc;

      UPDATE ota_events
      SET public_event_flag = v_pblc_evt_flg
      WHERE event_id = p_event_id;
    END IF;

    ------*************** bug 5157917

    EXCEPTION
    WHEN others THEN
      l_err_msg := nvl(SUBSTR(sqlerrm,   1,   2000),   l_msg);
      ota_classic_upgrade.add_log_entry(p_table_name => 'OTA_EVENTS',
      							p_business_group_id => NULL,
							p_source_primary_key => p_event_id,
							p_object_value => l_upgrade_name,
							p_message_text => l_err_msg,
							p_upgrade_id => l_upgrade_id,
							p_process_date => sysdate,
							p_log_type => log_type_e,
							p_upgrade_name => l_upgrade_name);
      ota_timezone_upgrade.l_upgrade_status := FALSE;
      write_log(l_err_msg);
    END;

    FUNCTION get_msg_text(l_msg_name IN VARCHAR2) RETURN VARCHAR2 IS l_msg_text VARCHAR2(2000);

    CURSOR csr_msg(msg_name VARCHAR2) IS
    SELECT message_text
    FROM fnd_new_messages
    WHERE message_name = TRIM(SUBSTR(msg_name,   instr(msg_name,   ':',   1,   1) + 1,
    			 (decode(instr(msg_name,   ':',   1,   2),   0,   LENGTH(msg_name),
			 instr(msg_name,   ':',   1,   2) -1) -instr(msg_name,   ':'))))
     AND language_code = userenv('LANG');
    BEGIN

      OPEN csr_msg(l_msg_name);

      FETCH csr_msg
      INTO l_msg_text;

      IF csr_msg % NOTFOUND THEN
        l_msg_text := NULL;
      END IF;

      CLOSE csr_msg;

      RETURN l_msg_text;
    END;

    FUNCTION get_primary_venue_id(l_event_id IN ota_resource_bookings.event_id%TYPE)
    RETURN NUMBER
    IS
    l_primary_venue ota_suppliable_resources.supplied_resource_id%TYPE;

    CURSOR csr_pri_ven(p_event_id NUMBER) IS
    SELECT resbkng.supplied_resource_id
    FROM ota_resource_bookings resbkng
    WHERE resbkng.event_id = p_event_id
     AND resbkng.primary_venue_flag = 'Y';
    BEGIN

      OPEN csr_pri_ven(l_event_id);

      FETCH csr_pri_ven
      INTO l_primary_venue;

      IF csr_pri_ven % NOTFOUND THEN
        l_primary_venue := NULL;
      END IF;

      CLOSE csr_pri_ven;

      RETURN l_primary_venue;
    END get_primary_venue_id;

    FUNCTION get_primary_venue_tz(l_primary_venue IN ota_suppliable_resources.supplied_resource_id%TYPE)
    RETURN VARCHAR2
    IS
    l_time_zone ota_events.timezone%TYPE;

    CURSOR csr_pri_ven_tz(p_pri_ven NUMBER) IS
    SELECT loc.timezone_code
    FROM ota_suppliable_resources res,
      hr_locations loc
    WHERE supplied_resource_id = p_pri_ven
     AND res.location_id = loc.location_id;
    BEGIN

      OPEN csr_pri_ven_tz(l_primary_venue);

      FETCH csr_pri_ven_tz
      INTO l_time_zone;

      IF csr_pri_ven_tz % NOTFOUND THEN
        l_time_zone := NULL;
      END IF;

      CLOSE csr_pri_ven_tz;

      RETURN l_time_zone;
    END get_primary_venue_tz;

    FUNCTION get_trngcenter_tz(l_trainning_center IN ota_suppliable_resources.training_center_id%TYPE)
    RETURN VARCHAR2
    IS
    l_time_zone ota_events.timezone%TYPE;

    CURSOR csr_trgctr_tz(trg_cen_id NUMBER) IS
    SELECT loc.timezone_code

    FROM hr_locations loc,
      hr_all_organization_units org
    WHERE loc.location_id = org.location_id
     AND org.organization_id = trg_cen_id;
    BEGIN

      OPEN csr_trgctr_tz(l_trainning_center);

      FETCH csr_trgctr_tz
      INTO l_time_zone;

      IF csr_trgctr_tz % NOTFOUND THEN
        l_time_zone := NULL;
      END IF;

      CLOSE csr_trgctr_tz;

      RETURN l_time_zone;
    END get_trngcenter_tz;

   /* PROCEDURE upd_res_bkng(p_res_bkng_id IN NUMBER,   p_obj_ver_number IN OUT nocopy NUMBER,
   				p_time_zone IN VARCHAR2,   l_upgrade_id IN NUMBER)
IS
    l_msg VARCHAR2(200) := 'Error occurred while upgrading the timezone of resource bookings';
    BEGIN
      ota_trb_upd.upd(p_effective_date => TRUNC(sysdate),
      				p_resource_booking_id => p_res_bkng_id,
				p_object_version_number => p_obj_ver_number,
				p_timezone_code => p_time_zone);

    EXCEPTION
    WHEN others THEN
      l_err := SUBSTR(sqlerrm,   1,   2000);

      IF l_err LIKE '%OTA%' THEN
        l_err_msg := get_msg_text(l_err);
      ELSE
        l_err_msg := nvl(l_err,   l_msg);
      END IF;

      ota_classic_upgrade.add_log_entry(p_table_name => 'OTA_RESOURCE_BOOKINGS',
      								p_business_group_id => NULL,
								p_source_primary_key => p_res_bkng_id,
								p_object_value => l_upgrade_name,
								p_message_text => l_err_msg,
								p_upgrade_id => l_upgrade_id,
								p_process_date => sysdate,
								p_log_type => log_type_e,
								p_upgrade_name => l_upgrade_name);
      ota_timezone_upgrade.l_upgrade_status := FALSE;
      write_log('Resource_booking_id: ' || p_res_bkng_id);
      write_log(l_err_msg);

      BEGIN

        UPDATE ota_resource_bookings
        SET timezone_code = p_time_zone
        WHERE resource_booking_id = p_res_bkng_id
         AND object_version_number = p_obj_ver_number
         AND timezone_code IS NULL;

      EXCEPTION
      WHEN others THEN
        l_err_msg := nvl(SUBSTR(sqlerrm,   1,   2000),   l_msg);
        ota_classic_upgrade.add_log_entry(p_table_name => 'OTA_RESOURCE_BOOKINGS',
								p_business_group_id => NULL,
								p_source_primary_key => p_res_bkng_id,
								p_object_value => l_upgrade_name,
								p_message_text => l_err_msg,
								p_upgrade_id => l_upgrade_id,
								p_process_date => sysdate,
								p_log_type => log_type_e,
								p_upgrade_name => l_upgrade_name);
        ota_timezone_upgrade.l_upgrade_status := FALSE;
        write_log('Resource_booking_id: ' || p_res_bkng_id);
        write_log(l_err_msg);
      END;
    END;*/

    PROCEDURE upd_event_bkng(p_event_id NUMBER,   p_time_zone VARCHAR2,   l_upgrade_id NUMBER)
    AS
    CURSOR csr_event_sess IS
    SELECT event_id
    FROM ota_events
    WHERE event_id = p_event_id OR parent_event_id = p_event_id
     AND timezone IS NULL;

    CURSOR csr_event_res_bkng(p_event_id NUMBER) IS
    SELECT resource_booking_id,
      object_version_number
    FROM ota_resource_bookings
    WHERE event_id = p_event_id
     AND timezone_code IS NULL;
    BEGIN
      l_msg := 'Error occurred while upgrading the timezone of events';

      -- * FOR event_sess_row IN csr_event_sess
      -- * LOOP
      BEGIN

        UPDATE ota_events
        SET timezone = p_time_zone -- * WHERE event_id = event_sess_row.event_id
        WHERE(event_id = p_event_id OR parent_event_id = p_event_id)
         AND timezone IS NULL -- Added for bug#5110735
        AND event_type IN('SCHEDULED',   'SESSION',   'SELFPACED','DEVELOPMENT','PROGRAMME');

      EXCEPTION
      WHEN others THEN
        l_err_msg := nvl(SUBSTR(sqlerrm,   1,   2000),   l_msg);
        ota_classic_upgrade.add_log_entry(p_table_name => 'OTA_events',
								p_business_group_id => NULL,
								p_source_primary_key => p_event_id,   -- * event_sess_row.event_id,
        							p_object_value => l_upgrade_name,
								p_message_text => l_err_msg,
								p_upgrade_id => l_upgrade_id,
								p_process_date => sysdate,
								p_log_type => log_type_e,
								p_upgrade_name => l_upgrade_name);
        ota_timezone_upgrade.l_upgrade_status := FALSE;
        write_log(l_err_msg);
      END;

      /*FOR row_event_res_bkng IN csr_event_res_bkng (event_sess_row.event_id)
             LOOP
                upd_res_bkng (row_event_res_bkng.resource_booking_id,
                              row_event_res_bkng.object_version_number,
                              l_time_zone,
                              l_upgrade_id
                             );
             END LOOP;*/
      UPDATE ota_resource_bookings
      SET timezone_code = p_time_zone
      WHERE event_id in (SELECT event_id
                        FROM ota_events
                        WHERE event_id = p_event_id OR parent_event_id = p_event_id)
       AND timezone_code IS NULL;
      -- * event_sess_row.event_id and timezone_code IS NULL;
      -- * END LOOP;
    END;

    PROCEDURE upd_class_frm_bkng(p_event_id NUMBER,   p_time_zone VARCHAR2,   l_upgrade_id NUMBER)
    AS
    CURSOR csr_cls_frm_res_bkng IS
    SELECT resource_booking_id,
      object_version_number
    FROM ota_resource_bookings
    WHERE forum_id IN
      (SELECT forum_id
       FROM ota_frm_obj_inclusions
       WHERE object_type = 'E'
       AND object_id = p_event_id)
    AND timezone_code IS NULL;
    BEGIN

      /* FOR row_cls_frm_res_bkng IN csr_cls_frm_res_bkng
          LOOP
             upd_res_bkng (row_cls_frm_res_bkng.resource_booking_id,
                           row_cls_frm_res_bkng.object_version_number,
                           l_time_zone,
                           l_upgrade_id
                          );
          END LOOP;*/

      UPDATE ota_resource_bookings
      SET timezone_code = p_time_zone
      WHERE forum_id IN
        (SELECT forum_id
         FROM ota_frm_obj_inclusions
         WHERE object_type = 'E'
         AND object_id = p_event_id)
      AND timezone_code IS NULL;
    END;

    PROCEDURE upd_class_chats_bkng(p_event_id NUMBER,   p_time_zone VARCHAR2,   l_upgrade_id NUMBER)
    AS
    CURSOR csr_chats(p_event_id NUMBER) IS
    SELECT chat_id
    FROM ota_chat_obj_inclusions
    WHERE object_id = p_event_id
     AND primary_flag = 'Y'
     AND object_type = 'E';

    CURSOR csr_cls_cha_res_bkng(p_chat_id NUMBER) IS
    SELECT resource_booking_id,
      object_version_number
    FROM ota_resource_bookings
    WHERE chat_id = p_chat_id
     AND timezone_code IS NULL;
    BEGIN
      l_msg := 'Error occurred while upgrading the timezone of class chats';

      FOR chats_row IN csr_chats(p_event_id)
      LOOP
        BEGIN

          UPDATE ota_chats_b
          SET timezone_code = p_time_zone
          WHERE chat_id = chats_row.chat_id
           AND timezone_code IS NULL;

        EXCEPTION
        WHEN others THEN
          l_err_msg := nvl(SUBSTR(sqlerrm,   1,   2000),   l_msg);
          ota_classic_upgrade.add_log_entry(p_table_name => 'OTA_chats_b',
	  							  p_business_group_id => NULL,
								  p_source_primary_key => chats_row.chat_id,
								  p_object_value => l_upgrade_name,
								  p_message_text => l_err_msg,
								  p_upgrade_id => l_upgrade_id,
								  p_process_date => sysdate,
								  p_log_type => log_type_e,
								  p_upgrade_name => l_upgrade_name);
          ota_timezone_upgrade.l_upgrade_status := FALSE;
          write_log(l_err_msg);
        END;

        /* FOR row_cls_cha_res_bkng IN csr_cls_cha_res_bkng (chats_row.chat_id)
             LOOP
                upd_res_bkng (row_cls_cha_res_bkng.resource_booking_id,
                              row_cls_cha_res_bkng.object_version_number,
                              l_time_zone,
                              l_upgrade_id
                             );
             END LOOP;*/

        UPDATE ota_resource_bookings
        SET timezone_code = p_time_zone
        WHERE chat_id = chats_row.chat_id
         AND timezone_code IS NULL;

      END LOOP;
    END;

    PROCEDURE upd_cat_chat_bkng(p_default_timezone IN VARCHAR2,   l_upgrade_id IN NUMBER)
    IS
    CURSOR csr_cat_chat_bkng IS
    SELECT chat_id
    FROM ota_chat_obj_inclusions
    WHERE primary_flag = 'Y'
     AND object_type = 'C';

    CURSOR csr_cat_chat_res_bkng(p_chat_id NUMBER) IS
    SELECT resource_booking_id,
      object_version_number
    FROM ota_resource_bookings
    WHERE chat_id = p_chat_id
     AND timezone_code IS NULL;
    BEGIN
      l_others_msg := 'Error occurred while upgrading the timezone of category chats ';

      IF p_default_timezone IS NULL THEN
        ota_classic_upgrade.add_log_entry(p_table_name => 'ota_chats_b',
								p_business_group_id => NULL,
								p_source_primary_key => -1,
								p_object_value => 'Timezone',
								p_message_text => l_default_msg,
								p_upgrade_id => l_upgrade_id,
								p_process_date => sysdate,
								p_log_type => log_type_i,
								p_upgrade_name => l_upgrade_name);
        ota_timezone_upgrade.l_upgrade_status := FALSE;
        write_log(l_default_msg);
      ELSE
        l_time_zone := p_default_timezone;

        FOR cat_chat_bkng_row IN csr_cat_chat_bkng
        LOOP
          BEGIN

            UPDATE ota_chats_b
            SET timezone_code = l_time_zone
            WHERE chat_id = cat_chat_bkng_row.chat_id
             AND timezone_code IS NULL;

          EXCEPTION
          WHEN others THEN
            l_err_msg := nvl(SUBSTR(sqlerrm,   1,   2000),   l_others_msg);
            ota_classic_upgrade.add_log_entry(p_table_name => 'ota_chats_b',
	    							   p_business_group_id => NULL,
								   p_source_primary_key => cat_chat_bkng_row.chat_id,
								   p_object_value => l_upgrade_name,
								   p_message_text => l_err_msg,
								   p_upgrade_id => l_upgrade_id,
								   p_process_date => sysdate,
								   p_log_type => log_type_e,
								   p_upgrade_name => l_upgrade_name);
            ota_timezone_upgrade.l_upgrade_status := FALSE;
            write_log(l_err_msg);
          END;

          /* FOR row_cat_chat_res_bkng IN
                   csr_cat_chat_res_bkng (cat_chat_bkng_row.chat_id)
                LOOP
                   upd_res_bkng (row_cat_chat_res_bkng.resource_booking_id,
                                 row_cat_chat_res_bkng.object_version_number,
                                 l_time_zone,
                                 l_upgrade_id
                                );
                END LOOP;*/

          UPDATE ota_resource_bookings
          SET timezone_code = l_time_zone
          WHERE chat_id = cat_chat_bkng_row.chat_id
           AND timezone_code IS NULL;

        END LOOP;
      END IF;

    EXCEPTION
    WHEN others THEN
      l_err_code := SQLCODE;
      l_err_msg := nvl(SUBSTR(sqlerrm,   1,   2000),   l_others_msg);
      ota_classic_upgrade.add_log_entry(p_table_name => 'Dummy',
      								p_business_group_id => NULL,
								p_source_primary_key => l_err_code,
								p_object_value => l_upgrade_name,
								p_message_text => l_err_msg,
								p_upgrade_id => l_upgrade_id,
								p_process_date => sysdate,
								p_log_type => log_type_e,
								p_upgrade_name => l_upgrade_name);
      ota_timezone_upgrade.l_upgrade_status := FALSE;
      write_log(l_err_msg);
    END upd_cat_chat_bkng;

    PROCEDURE upd_cat_frm_bkng(p_default_timezone IN VARCHAR2,   l_upgrade_id IN NUMBER)
    IS
    CURSOR csr_cat_frm_res_bkng IS
    SELECT resource_booking_id,
      object_version_number
    FROM ota_resource_bookings
    WHERE forum_id IN
      (SELECT forum_id
       FROM ota_frm_obj_inclusions
       WHERE primary_flag = 'Y'
       AND object_type = 'C')
    AND timezone_code IS NULL;
    BEGIN
      l_msg := 'Error occurred while upgrading timezone of category forum resource booking';

      IF p_default_timezone IS NULL THEN
        ota_classic_upgrade.add_log_entry(p_table_name => 'OTA_RESOURCE_BOOKINGS',
								 p_business_group_id => NULL,
								 p_source_primary_key => l_upgrade_id,
								 p_object_value => 'Timezone',
								 p_message_text => l_default_msg,
								 p_upgrade_id => l_upgrade_id,
								 p_process_date => sysdate,
								 p_log_type => log_type_i,
								 p_upgrade_name => l_upgrade_name);
        l_upgrade_status := FALSE;
        write_log(l_default_msg);
      ELSE
        l_time_zone := p_default_timezone;

        /*FOR row_cat_frm_res_bkng IN csr_cat_frm_res_bkng
             LOOP
                upd_res_bkng (row_cat_frm_res_bkng.resource_booking_id,
                              row_cat_frm_res_bkng.object_version_number,
                              l_time_zone,
                              l_upgrade_id
                             );
             END LOOP;*/

        UPDATE ota_resource_bookings
        SET timezone_code = l_time_zone
        WHERE forum_id IN
          (SELECT forum_id
           FROM ota_frm_obj_inclusions
           WHERE primary_flag = 'Y'
           AND object_type = 'C')
        AND timezone_code IS NULL;
      END IF;

    EXCEPTION
    WHEN others THEN
      l_err_code := SQLCODE;
      l_err_msg := nvl(SUBSTR(sqlerrm,   1,   2000),   l_msg);
      ota_classic_upgrade.add_log_entry(p_table_name => 'OTA_RESOURCE_BOOKINGS',
      							   p_business_group_id => NULL,
							   p_source_primary_key => -1,
							   p_object_value => l_upgrade_name,
							   p_message_text => l_err_msg,
							   p_upgrade_id => l_upgrade_id,
							   p_process_date => sysdate,
							   p_log_type => log_type_e,
							   p_upgrade_name => l_upgrade_name);
      l_upgrade_status := FALSE;
      write_log(l_err_msg);
    END upd_cat_frm_bkng;

    PROCEDURE upd_class_ses_res_bkng(p_default_timezone IN VARCHAR2,   l_upgrade_id IN NUMBER)
    IS

    CURSOR csr_class_ses_res_bkng IS
    SELECT event_id,
      location_id,
      training_center_id,
      timezone,
      event_type,
      public_event_flag
    FROM ota_events;
    BEGIN
      FOR class_ses_res_bkng_row IN csr_class_ses_res_bkng
      LOOP
        l_time_zone := NULL;
        l_primary_venue := NULL;
        upd_classic_data(class_ses_res_bkng_row.event_id,
				class_ses_res_bkng_row.event_type,
				class_ses_res_bkng_row.public_event_flag,
				 l_upgrade_id);
        -- Modified for bug#5110735

        IF class_ses_res_bkng_row.event_type IN('SCHEDULED',   'SELFPACED',   'DEVELOPMENT',   'PROGRAMME')
	THEN

          IF class_ses_res_bkng_row.timezone IS NULL THEN
            l_primary_venue := get_primary_venue_id(class_ses_res_bkng_row.event_id);

            IF(l_time_zone IS NULL
             AND l_primary_venue IS NOT NULL) THEN
              l_time_zone := get_primary_venue_tz(l_primary_venue);
            END IF;

            IF(l_time_zone IS NULL
             AND class_ses_res_bkng_row.location_id IS NOT NULL) THEN
              l_time_zone := get_location_tz(class_ses_res_bkng_row.location_id);
            END IF;

            IF(l_time_zone IS NULL
             AND class_ses_res_bkng_row.training_center_id IS NOT NULL) THEN
              l_time_zone := get_trngcenter_tz(class_ses_res_bkng_row.training_center_id);
            END IF;

            IF(l_time_zone IS NULL) THEN

              IF p_default_timezone IS NULL THEN
                ota_classic_upgrade.add_log_entry(p_table_name => 'OTA_EVENTS',
									p_business_group_id => NULL,
									p_source_primary_key => class_ses_res_bkng_row.event_id,
									p_object_value => 'Timezone',
									p_message_text => l_default_msg,
									p_upgrade_id => l_upgrade_id,
									p_process_date => sysdate,
									p_log_type => log_type_i,
									p_upgrade_name => l_upgrade_name);
                ota_timezone_upgrade.l_upgrade_status := FALSE;
                write_log(l_default_msg);
              ELSE
                l_time_zone := p_default_timezone;
              END IF;

            END IF;

          ELSE
            l_time_zone := class_ses_res_bkng_row.timezone;
          END IF;

          IF l_time_zone IS NOT NULL THEN
            upd_event_bkng(class_ses_res_bkng_row.event_id,   l_time_zone,   l_upgrade_id);
            upd_class_chats_bkng(class_ses_res_bkng_row.event_id,   l_time_zone,   l_upgrade_id);
            upd_class_frm_bkng(class_ses_res_bkng_row.event_id,   l_time_zone,   l_upgrade_id);
          END IF;

        END IF;

      END LOOP;

    EXCEPTION
    WHEN others THEN
      l_err_code := SQLCODE;
      l_err_msg := nvl(SUBSTR(sqlerrm,   1,   2000),   l_msg);
      ota_classic_upgrade.add_log_entry(p_table_name => 'Dummy',
      							p_business_group_id => NULL,
							p_source_primary_key => l_err_code,
							p_object_value => l_upgrade_name,
							p_message_text => l_err_msg,
							p_upgrade_id => l_upgrade_id,
							p_process_date => sysdate,
							p_log_type => log_type_e,
							p_upgrade_name => l_upgrade_name);
      ota_timezone_upgrade.l_upgrade_status := FALSE;
      write_log(l_err_msg);
    END upd_class_ses_res_bkng;

    PROCEDURE upd_ind_res_bookings(p_default_timezone IN VARCHAR2,   l_upgrade_id IN NUMBER)
    IS
    CURSOR csr_ind_res_bookings IS
    SELECT supplied_resource_id
    FROM ota_resource_bookings
    WHERE event_id IS NULL
     AND forum_id IS NULL
     AND chat_id IS NULL
     AND timezone_code IS NULL
    GROUP BY supplied_resource_id;

    CURSOR csr_ind_res_bkng(p_res_id NUMBER) IS
    SELECT resource_booking_id,
      object_version_number
    FROM ota_resource_bookings
    WHERE supplied_resource_id = p_res_id
     AND timezone_code IS NULL;
    BEGIN
      l_msg := 'Error occurred while upgrading the timezone of independent resources';

      FOR ind_res_bookings_row IN csr_ind_res_bookings
      LOOP
        l_time_zone := NULL;
        l_trng_center_id := NULL;
        l_loc_id := NULL;
        get_location_trngcenter_id(ind_res_bookings_row.supplied_resource_id,   l_loc_id,   l_trng_center_id);

        IF(l_time_zone IS NULL
         AND l_loc_id IS NOT NULL) THEN
          l_time_zone := get_location_tz(l_loc_id);
        END IF;

        IF(l_time_zone IS NULL
         AND l_trng_center_id IS NOT NULL) THEN
          l_time_zone := get_trngcenter_tz(l_trng_center_id);
        END IF;

        IF(l_time_zone IS NULL) THEN

          IF p_default_timezone IS NULL THEN
            ota_classic_upgrade.add_log_entry(p_table_name => 'OTA_RESOURCE_BOOKINGS',
	    							p_business_group_id => NULL,
								p_source_primary_key => ind_res_bookings_row.supplied_resource_id,
								p_object_value => 'Timezone',
								p_message_text => l_default_msg,
								p_upgrade_id => l_upgrade_id,
								p_process_date => sysdate,
								p_log_type => log_type_i,
								p_upgrade_name => l_upgrade_name);
            ota_timezone_upgrade.l_upgrade_status := FALSE;
            write_log(l_default_msg);
          ELSE
            l_time_zone := p_default_timezone;
          END IF;

        END IF;

        /*FOR row_ind_res_bkng IN
                csr_ind_res_bkng (ind_res_bookings_row.supplied_resource_id)
             LOOP
                upd_res_bkng (row_ind_res_bkng.resource_booking_id,
                              row_ind_res_bkng.object_version_number,
                              l_time_zone,
                              l_upgrade_id
                             );
             END LOOP;*/

        UPDATE ota_resource_bookings
        SET timezone_code = l_time_zone
        WHERE supplied_resource_id = ind_res_bookings_row.supplied_resource_id
         AND timezone_code IS NULL;

      END LOOP;

    EXCEPTION
    WHEN others THEN
      l_err_code := SQLCODE;
      l_err_msg := nvl(SUBSTR(sqlerrm,   1,   2000),   l_msg);
      ota_classic_upgrade.add_log_entry(p_table_name => 'Dummy',
      								p_business_group_id => NULL,
								p_source_primary_key => l_err_code,
								p_object_value => l_upgrade_name,
								p_message_text => l_err_msg,
								p_upgrade_id => l_upgrade_id,
								p_process_date => sysdate,
								p_log_type => log_type_e,
								p_upgrade_name => l_upgrade_name);
      ota_timezone_upgrade.l_upgrade_status := FALSE;
      write_log(l_err_msg);
    END upd_ind_res_bookings;

    PROCEDURE run_timezone_upgrade(errbuf OUT nocopy VARCHAR2,   retcode OUT nocopy VARCHAR2)
    IS
    l_upgrade_id NUMBER(9);
    l_loop_counter number(6):=0;
    p_default_timezone VARCHAR2(30) := ota_timezone_util.get_server_timezone_code;


    CURSOR get_resource_bookings IS
     SELECT trb.supplied_resource_id,
     trb.chat_id,
     trb.forum_id,
     trb.required_date_from,
     trb.required_date_to,
     trb.required_end_time,
     trb.required_start_time,
     trb.resource_booking_id,
     trb.timezone_code,
     trb.book_entire_period_flag,
     res.resource_type
     FROM ota_resource_bookings trb,ota_suppliable_resources res
     WHERE trb.status = 'C'
     and res.resource_type in ('T','V')
     and trb.required_date_to >=(trunc(sysdate)-14)
     and trb.supplied_resource_id=res.supplied_resource_id
    order by resource_booking_id;


    BEGIN
      ota_timezone_upgrade.l_upgrade_status := TRUE;
      SELECT MAX(upgrade_id)
      INTO l_upgrade_id
      FROM ota_upgrade_log
      WHERE upgrade_name = l_upgrade_name;

      IF l_upgrade_id IS NULL THEN
        l_upgrade_id := 1;
      ELSE
        l_upgrade_id := l_upgrade_id + 1;
      END IF;

      l_others_msg := 'Some error occurred while running the Timezone upgrade process';
      write_log('Starting Timezone Upgrade Concurrent Process');
      write_log('Upgrading events and their resources');
      upd_class_ses_res_bkng(p_default_timezone,   l_upgrade_id);
      write_log('Upgrading Category chats and resources booked against them');
      upd_cat_chat_bkng(p_default_timezone,   l_upgrade_id);
      write_log('Upgrading Category Forum resource bookings');
      upd_cat_frm_bkng(p_default_timezone,   l_upgrade_id);
      write_log('Upgrading Independent resource bookings.');
      upd_ind_res_bookings(p_default_timezone,   l_upgrade_id);



      COMMIT;

      FOR get_resource_bookings_row IN get_resource_bookings
      LOOP


	/*
	The check double resource booking will execute only if the resource type is trainer and it is not
	booked to a forum or a chat or the resource type is a venue.
	*/
        IF((get_resource_bookings_row.resource_type = 'T')
         AND(get_resource_bookings_row.chat_id IS NOT NULL OR get_resource_bookings_row.forum_id IS NOT NULL)) THEN
          NULL;
        Elsif get_resource_bookings_row.resource_type = 'T' or get_resource_bookings_row.resource_type = 'V' then
          BEGIN
           if  ota_trb_api_procedures.check_double_booking(get_resource_bookings_row.supplied_resource_id,
	    											get_resource_bookings_row.required_date_from,
												get_resource_bookings_row.required_start_time,
												get_resource_bookings_row.required_date_to,
												get_resource_bookings_row.required_end_time,
												get_resource_bookings_row.resource_booking_id,
												get_resource_bookings_row.book_entire_period_flag,
												 get_resource_bookings_row.timezone_code,
												 get_resource_bookings_row.resource_booking_id)
												 then
        fnd_message.set_name('OTA','OTA_13395_TRB_RES_DOUBLEBOOK');
         fnd_message.raise_error;
	 end if;

          EXCEPTION
          WHEN others THEN
            l_err_code := SQLCODE;
            l_err_msg := SUBSTR(sqlerrm,   1,   2000);
            if l_err_msg like '%OTA%' then
            l_err_msg := get_msg_text(l_err_msg);
            else
            l_err_msg:=nvl(l_err_msg,l_others_msg);
            end if;

            ota_classic_upgrade.add_log_entry(p_table_name => 'OTA_RESOURCE_BOOKINGS',
	    							p_business_group_id => NULL,
								p_source_primary_key => get_resource_bookings_row.resource_booking_id,
								p_object_value => l_upgrade_name,
								p_message_text => l_err_msg,
								p_upgrade_id => l_upgrade_id,
								p_process_date => sysdate,
								p_log_type => log_type_e,
								p_upgrade_name => l_upgrade_name);
            write_log('Resource_booking_id: ' || get_resource_bookings_row.resource_booking_id);
            write_log(l_err_msg);
	ota_timezone_upgrade.l_upgrade_status := FALSE;
          END;
        END IF;
	l_loop_counter:=l_loop_counter+1;
       if l_loop_counter >=1000 then
        l_loop_counter:=0;
        ota_classic_upgrade.add_log_entry(p_table_name => 'Dummy',
	    							p_business_group_id => NULL,
								p_source_primary_key => get_resource_bookings_row.resource_booking_id,
								p_object_value => l_upgrade_name,
								p_message_text => 'Records checked for the double booking validation',
								p_upgrade_id => l_upgrade_id,
								p_process_date => sysdate,
								p_log_type => log_type_i,
								p_upgrade_name => l_upgrade_name);
        commit;
        end if;
      END LOOP;



     IF ota_timezone_upgrade.l_upgrade_status = FALSE THEN
        write_log('Errors have been encountered during this Upgrade process');
      ELSE
        write_log('No errors have been encountered during this Upgrade process');
      END IF;

    EXCEPTION
    WHEN others THEN
      l_err_code := SQLCODE;
      l_err_msg := nvl(SUBSTR(sqlerrm,   1,   2000),   l_others_msg);
      ota_classic_upgrade.add_log_entry(p_table_name => 'Dummy',
      								p_business_group_id => NULL,
								p_source_primary_key => l_err_code,
								p_object_value => l_upgrade_name,
								p_message_text => l_err_msg,
								p_upgrade_id => l_upgrade_id,
								p_process_date => sysdate,
								p_log_type => log_type_e,
								p_upgrade_name => l_upgrade_name);

      write_log(l_err_msg);
    END run_timezone_upgrade;

  END ota_timezone_upgrade;


/
