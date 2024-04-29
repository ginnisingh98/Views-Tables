--------------------------------------------------------
--  DDL for Package Body CSF_GPS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSF_GPS_PUB" AS
  /* $Header: CSFPGPSB.pls 120.0.12010000.16 2010/03/10 10:56:06 anangupt noship $ */

  g_pkg_name           CONSTANT VARCHAR2(30) := 'CSF_GPS_PUB';
  g_level_cp_output    CONSTANT NUMBER       := fnd_log.level_unexpected + 1;
  g_epoch              CONSTANT DATE         := to_date('01-01-1970', 'DD-MM-YYYY');
  g_counter            NUMBER  := 0;

  PROCEDURE debug(p_message VARCHAR2, p_module VARCHAR2, p_level NUMBER, p_indent NUMBER) IS
  BEGIN
    IF p_level = g_level_cp_output AND fnd_file.output > 0 THEN
      fnd_file.put_line(fnd_file.output, p_message);
    END IF;

    IF     NVL(fnd_profile.value('AFLOG_ENABLED'), 'N') = 'Y'
       AND p_level >= NVL(fnd_profile.value('AFLOG_LEVEL'), 1)
    THEN
      IF fnd_file.log > 0 THEN
        IF p_message = ' ' THEN
          fnd_file.put_line(fnd_file.log, '');
        ELSE
          fnd_file.put_line(fnd_file.log, rpad(p_module, 20) || ': ' || p_message);
        END IF;
      END IF;
      IF ( p_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
      THEN
        fnd_log.string(p_level, 'csf.plsql.CSF_GPS_PUB.' || p_module, p_message);
      END IF;
    END IF;
    --dbms_output.put_line(rpad(p_module, 20) || ': ' || p_message);
  END debug;

  FUNCTION is_gps_enabled RETURN VARCHAR2 IS
    l_enabled VARCHAR2(1);
    CURSOR c_vendors IS
      SELECT DECODE(COUNT(*), 0, 'N', 'Y')
        FROM csf_gps_vendors_b WHERE enabled = 'Y';
  BEGIN
    OPEN c_vendors;
    FETCH c_vendors INTO l_enabled;
    CLOSE c_vendors;

    RETURN l_enabled;
  END is_gps_enabled;

  FUNCTION get_gps_label(
      p_device_id     NUMBER     DEFAULT NULL
    , p_resource_id   NUMBER     DEFAULT NULL
    , p_resource_type VARCHAR2   DEFAULT NULL
    , p_date          DATE       DEFAULT NULL
    )
    RETURN VARCHAR2 IS
    --
    l_label csf_gps_devices.device_tag%TYPE;
    --
    CURSOR c_device_label IS
      SELECT device_tag
        FROM csf_gps_devices
       WHERE device_id = p_device_id;
    --
    CURSOR c_resource_device_label IS
      SELECT device_tag
        FROM csf_gps_device_assignments a
           , csf_gps_devices d
       WHERE a.resource_id = p_resource_id
         AND a.resource_type = p_resource_type
         AND NVL(p_date, SYSDATE) BETWEEN a.start_date_active AND NVL(a.end_date_active, SYSDATE + 1);
  BEGIN
    IF p_device_id IS NOT NULL THEN
      OPEN c_device_label;
      FETCH c_device_label INTO l_label;
      CLOSE c_device_label;
    ELSIF p_resource_id IS NOT NULL THEN
      OPEN c_resource_device_label;
      FETCH c_resource_device_label INTO l_label;
      CLOSE c_resource_device_label;
    END IF;

    RETURN l_label;
  END;

  FUNCTION get_vendor_name(p_vendor_id NUMBER)
    RETURN VARCHAR2 IS
    --
    l_label csf_gps_vendors_tl.vendor_name%TYPE;
    CURSOR c_vendors IS
      SELECT vendor_name
        FROM csf_gps_vendors_vl
       WHERE vendor_id = p_vendor_id;
  BEGIN
    OPEN c_vendors;
    FETCH c_vendors INTO l_label;
    CLOSE c_vendors;

    RETURN l_label;
  END;

  PROCEDURE get_location(
      p_device_id                  IN        NUMBER    DEFAULT NULL
    , p_resource_id                IN        NUMBER    DEFAULT NULL
    , p_resource_type              IN        VARCHAR2  DEFAULT NULL
    , p_date                       IN        DATE      DEFAULT NULL
    , x_feed_time                 OUT NOCOPY DATE
    , x_status_code               OUT NOCOPY VARCHAR2
    , x_latitude                  OUT NOCOPY NUMBER
    , x_longitude                 OUT NOCOPY NUMBER
    , x_speed                     OUT NOCOPY NUMBER
    , x_direction                 OUT NOCOPY VARCHAR2
    , x_parked_time               OUT NOCOPY NUMBER
    , x_address                   OUT NOCOPY VARCHAR2
    , x_creation_date             OUT NOCOPY DATE
    , x_device_tag                OUT NOCOPY VARCHAR2
    , x_status_code_meaning       OUT NOCOPY VARCHAR2
    ) IS
    c_location_cursor SYS_REFCURSOR;

     CURSOR c_status_lookup IS
     SELECT NVL(meaning, 'UNKNOWN')
       FROM fnd_lookups
      WHERE lookup_type = 'CSF_GPS_DEVICE_STATUSES'
        AND lookup_code = 'UNKNOWN';
  BEGIN
    IF p_device_id IS NOT NULL THEN
      OPEN c_location_cursor FOR
        SELECT l.vendor_feed_time
             , l.status
             , trunc(l.latitude, 3)
             , trunc(l.longitude, 3)
             , l.speed
             , l.direction
             , l.parked_time
             , l.address
             , d.device_tag
             , (
                  SELECT NVL(fl.meaning, stmap.internal_status_code) FROM fnd_lookups fl, csf_gps_vendor_status_maps stmap
                  WHERE fl.lookup_type = 'CSF_GPS_DEVICE_STATUSES' AND fl.lookup_code = stmap.internal_status_code AND stmap.vendor_status_code = l.status
               ) status_code_meaning
             , l.creation_date
          FROM csf_gps_location_feeds l
             , csf_gps_devices d
         WHERE d.device_id = p_device_id
           AND l.device_id = d.device_id
--           AND (
--                    p_date IS NULL AND l.creation_date > SYSDATE - 1
--                 OR p_date BETWEEN (l.creation_date - 1) AND (l.creation_date + 1)
--               )
         ORDER BY ABS(NVL(p_date, l.creation_date) - l.creation_date) ASC, l.creation_date DESC;
    ELSE
      OPEN c_location_cursor FOR
        SELECT l.vendor_feed_time
             , l.status
             , trunc(l.latitude, 3)
             , trunc(l.longitude, 3)
             , l.speed
             , l.direction
             , l.parked_time
             , l.address
             , d.device_tag
             , (
                  SELECT NVL(fl.meaning, stmap.internal_status_code) FROM fnd_lookups fl, csf_gps_vendor_status_maps stmap
                  WHERE fl.lookup_type = 'CSF_GPS_DEVICE_STATUSES' AND fl.lookup_code = stmap.internal_status_code AND stmap.vendor_status_code = l.status
               ) status_code_meaning
             , l.creation_date
          FROM csf_gps_location_feeds l
             , csf_gps_device_assignments a
             , csf_gps_devices d
         WHERE a.resource_id = p_resource_id
           AND a.resource_type = p_resource_type
           AND a.device_id = l.device_id
           AND d.device_id = a.device_id
--           AND (
--                    p_date IS NULL AND l.creation_date > SYSDATE - 1
--                 OR p_date BETWEEN (l.creation_date - 1) AND (l.creation_date + 1)
--                    AND p_date BETWEEN a.start_date_active AND NVL(a.end_date_active, SYSDATE+1)
--               )
         ORDER BY ABS(NVL(p_date, l.creation_date) - l.creation_date) ASC, l.creation_date DESC;
    END IF;

    FETCH c_location_cursor INTO
        x_feed_time
      , x_status_code
      , x_latitude
      , x_longitude
      , x_speed
      , x_direction
      , x_parked_time
      , x_address
      , x_device_tag
      , x_status_code_meaning
      , x_creation_date
      ;
    CLOSE c_location_cursor;

    IF x_latitude IS NULL OR x_longitude IS NULL THEN
      x_longitude := -9999;
      x_latitude  := -9999;
    END IF;
    IF x_status_code_meaning IS NULL AND x_device_tag IS NOT NULL THEN
       OPEN c_status_lookup;
      FETCH c_status_lookup INTO x_status_code_meaning;
      CLOSE c_status_lookup;
    END IF;
  END get_location;

  FUNCTION get_location (
      p_device_id                  IN        NUMBER    DEFAULT NULL
    , p_resource_id                IN        NUMBER    DEFAULT NULL
    , p_resource_type              IN        VARCHAR2  DEFAULT NULL
    , p_date                       IN        DATE      DEFAULT NULL
    )
    RETURN MDSYS.SDO_POINT_TYPE IS
    l_feed_time            csf_gps_location_feeds.vendor_feed_time%TYPE;
    l_status_code          csf_gps_location_feeds.status%TYPE;
    l_latitude             csf_gps_location_feeds.latitude%TYPE;
    l_longitude            csf_gps_location_feeds.longitude%TYPE;
    l_speed                csf_gps_location_feeds.speed%TYPE;
    l_direction            csf_gps_location_feeds.direction%TYPE;
    l_parked_time          csf_gps_location_feeds.parked_time%TYPE;
    l_address              csf_gps_location_feeds.address%TYPE;
    l_creation_date        csf_gps_location_feeds.creation_date%TYPE;
    l_device_tag           csf_gps_devices.device_tag%TYPE;
    l_status_code_meaning  fnd_lookups.meaning%TYPE;
  BEGIN
    get_location(
        p_device_id              => p_device_id
      , p_resource_id            => p_resource_id
      , p_resource_type          => p_resource_type
      , p_date                   => p_date
      , x_feed_time              => l_feed_time
      , x_status_code            => l_status_code
      , x_latitude               => l_latitude
      , x_longitude              => l_longitude
      , x_speed                  => l_speed
      , x_direction              => l_direction
      , x_parked_time            => l_parked_time
      , x_address                => l_address
      , x_creation_date          => l_creation_date
      , x_device_tag             => l_device_tag
      , x_status_code_meaning    => l_status_code_meaning
      );

    RETURN MDSYS.SDO_POINT_TYPE(l_longitude, l_latitude, 0);

  END get_location;

  PROCEDURE save_location_feeds(
      p_api_version                IN        NUMBER
    , p_init_msg_list              IN        VARCHAR2
    , p_commit                     IN        VARCHAR2
    , x_return_status             OUT NOCOPY VARCHAR2
    , x_msg_data                  OUT NOCOPY VARCHAR2
    , x_msg_count                 OUT NOCOPY NUMBER
    , p_count                      IN        NUMBER
    , p_device_id_tbl              IN        jtf_number_table
    , p_feed_time_tbl              IN        jtf_date_table
    , p_status_tbl                 IN        jtf_varchar2_table_100
    , p_lat_tbl                    IN        jtf_number_table
    , p_lng_tbl                    IN        jtf_number_table
    , p_speed_tbl                  IN        jtf_number_table
    , p_dir_tbl                    IN        jtf_varchar2_table_100
    , p_parked_time_tbl            IN        jtf_number_table
    , p_address_tbl                IN        jtf_varchar2_table_300
    ) IS
    l_api_name        CONSTANT VARCHAR2(30) := 'SAVE_LOCATION_FEEDS';
  BEGIN
    SAVEPOINT csf_save_location_feeds;

    -- Check for API Compatibility
    IF NOT fnd_api.compatible_api_call(1.0, p_api_version, l_api_name, g_pkg_name) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize Message Stack if required
    IF p_init_msg_list = fnd_api.g_true THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Initialize Return Status
    x_return_status := fnd_api.g_ret_sts_success;

    FORALL i IN 1..p_count
      INSERT INTO csf_gps_location_feeds(
            location_feed_id
          , device_id
          , creation_date
          , vendor_feed_time
          , status
          , latitude
          , longitude
          , speed
          , direction
          , parked_time
          , address
          )
        VALUES (
            csf_gps_location_feeds_s.NEXTVAL
          , p_device_id_tbl(i)
          , SYSDATE
          , p_feed_time_tbl(i)
          , p_status_tbl(i)
          , p_lat_tbl(i)
          , p_lng_tbl(i)
          , p_speed_tbl(i)
          , p_dir_tbl(i)
          , p_parked_time_tbl(i)
          , p_address_tbl(i)
          );

    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(p_data => x_msg_data, p_count => x_msg_count);
      ROLLBACK TO csf_save_location_feeds;
  END save_location_feeds;

  /***************************************************************************************
   *                                                                                     *
   *                               Purging Routines                                      *
   *                                                                                     *
   ***************************************************************************************/

  PROCEDURE purge_res_device_feeds(
      p_device_id         NUMBER
    , p_device_tag        VARCHAR2
    , p_start_date        DATE
    , p_end_date          DATE
    , p_indent            NUMBER
    ) IS
    l_api_name        CONSTANT VARCHAR2(30) := 'PURGE_RES_DEVICE_FEEDS';
  BEGIN
    fnd_message.set_name('CSF', 'CSF_GPS_PURGING_DEVICE_LOCS');
    fnd_message.set_token('DEVICE_TAG', p_device_tag);
    debug(fnd_message.get, l_api_name, g_level_cp_output, p_indent);

    DELETE csf_gps_location_feeds
     WHERE device_id = p_device_id
       AND creation_date BETWEEN p_start_date AND p_end_date;
    g_counter := g_counter + SQL%ROWCOUNT;
    fnd_message.set_name('CSF', 'CSF_GPS_PURGE_DEL_ROWS_STATS');
    fnd_message.set_token('COUNT', SQL%ROWCOUNT);
    debug(fnd_message.get, l_api_name, g_level_cp_output, p_indent + 4);
  END purge_res_device_feeds;

  PROCEDURE purge_res_location_feeds(
      p_resource_id       NUMBER
    , p_resource_type     VARCHAR2
    , p_start_date        DATE
    , p_end_date          DATE
    , p_indent            NUMBER
    ) IS
    l_api_name        CONSTANT VARCHAR2(30) := 'PURGE_RES_LOCATION_FEEDS';
    l_res_info csf_resource_pub.resource_rec_type;
  BEGIN
    l_res_info := csf_resource_pub.get_resource_info(p_resource_id, p_resource_type);

    fnd_message.set_name('CSF', 'CSF_GPS_PURGING_RES_LOCS');
    fnd_message.set_token('RESOURCE', l_res_info.resource_name || '(' || csf_resource_pub.get_resource_type_name(l_res_info.resource_type) || ', ' || l_res_info.resource_number || ')');
    debug(fnd_message.get, l_api_name, g_level_cp_output, p_indent);

    DELETE csf_gps_location_feeds
     WHERE device_id IN (
             SELECT device_id
               FROM csf_gps_device_assignments
              WHERE resource_id = p_resource_id
                AND resource_type = p_resource_type
                AND start_date_active < p_end_date
                AND NVL(end_date_active, SYSDATE) > p_start_date
           )
       AND creation_date BETWEEN p_start_date AND p_end_date;
    g_counter := g_counter + SQL%ROWCOUNT;
    fnd_message.set_name('CSF', 'CSF_GPS_PURGE_DEL_ROWS_STATS');
    fnd_message.set_token('COUNT', SQL%ROWCOUNT);
    debug(fnd_message.get, l_api_name, g_level_cp_output, p_indent + 4);
  END purge_res_location_feeds;

  PROCEDURE purge_location_feeds(
      errbuf                      OUT NOCOPY VARCHAR2
    , retcode                     OUT NOCOPY VARCHAR2
    , p_vendor_id                  IN        NUMBER    DEFAULT NULL
    , p_device_id                  IN        NUMBER    DEFAULT NULL
    , p_device_assignment_id       IN        NUMBER    DEFAULT NULL
    , p_territory_id               IN        NUMBER    DEFAULT NULL
    , p_resource_type              IN        VARCHAR2  DEFAULT NULL
    , p_resource_id                IN        NUMBER    DEFAULT NULL
    , p_start_date                 IN        VARCHAR2  DEFAULT NULL
    , p_end_date                   IN        VARCHAR2  DEFAULT NULL
    , p_num_days                   IN        NUMBER    DEFAULT NULL
    ) IS
     l_api_name        CONSTANT VARCHAR2(30) := 'PURGE_LOCATION_FEEDS';
     l_start_date      DATE;
     l_end_date        DATE;

     --
     CURSOR c_vendors IS
       SELECT vendor_id, vendor_name
         FROM csf_gps_vendors_vl;
     --
     CURSOR c_vendor_devices(v_vendor_id NUMBER) IS
       SELECT device_id, device_tag
         FROM csf_gps_devices
        WHERE vendor_id = v_vendor_id;
     --
     CURSOR c_territory_resources IS
       SELECT resource_id, resource_type
         FROM jtf_terr_rsc_all
        WHERE terr_id = p_territory_id;

     l_datetime_format fnd_profile_option_values.profile_option_value%TYPE;

  BEGIN
    fnd_message.set_name('CSF', 'CSF_GPS_PURGE_CP_STARTED');
    debug(fnd_message.get, l_api_name, g_level_cp_output, 0);

    IF p_num_days IS NULL THEN
      IF p_start_date IS NOT NULL THEN
        l_start_date := fnd_date.canonical_to_date(p_start_date);
      ELSE
        l_start_date := SYSDATE-8;
      END IF;

      IF p_end_date IS NOT NULL THEN
        l_end_date := fnd_date.canonical_to_date(p_end_date);
      ELSE
        l_end_date := TRUNC(SYSDATE-1);
      END IF;
    ELSE
      l_start_date := SYSDATE - trunc(p_num_days);
      l_end_date   := SYSDATE;
    END IF;

    l_datetime_format := fnd_profile.value('ICX_DATE_FORMAT_MASK');
    IF  l_datetime_format IS NULL THEN
       l_datetime_format := 'DD-MM-YYYY HH24:MI';
    ELSE
       l_datetime_format := l_datetime_format || ' HH24:MI';
    END IF;
    fnd_message.set_name('CSF', 'CSF_GPS_PURGE_DATE_RANGE');
    fnd_message.set_token('START_DATE', to_char(l_start_date, l_datetime_format));
    fnd_message.set_token('END_DATE', to_char(l_end_date, l_datetime_format));
    debug(fnd_message.get, l_api_name, g_level_cp_output, 0);

    SAVEPOINT csf_gps_loc_purge;

    IF p_vendor_id IS NOT NULL THEN
      --
      -- Purging the Locations of all the Devices attached to the Vendor
      --
      fnd_message.set_name('CSF', 'CSF_GPS_PURGING_VENDOR_LOCS');
      fnd_message.set_token('VENDOR', get_vendor_name(p_vendor_id));
      debug(fnd_message.get, l_api_name, g_level_cp_output, 0);

      FOR v_device IN c_vendor_devices(p_vendor_id) LOOP
        purge_res_device_feeds(v_device.device_id, v_device.device_tag, l_start_date, l_end_date, 4);
      END LOOP;
    ELSIF p_device_id IS NOT NULL THEN
      --
      -- Purging the Locations of the Device
      --
      purge_res_device_feeds(p_device_id, get_gps_label(p_device_id), l_start_date, l_end_date, 0);
    ELSIF p_device_assignment_id IS NOT NULL THEN
      --
      -- Purging the Locations of the Device Assignment
      --
      fnd_message.set_name('CSF', 'CSF_GPS_PURGING_ASSIGN_LOCS');
      debug(fnd_message.get, l_api_name, g_level_cp_output, 0);

      DELETE csf_gps_location_feeds
       WHERE device_id IN (
               SELECT device_id
                 FROM csf_gps_device_assignments
                WHERE device_assignment_id = p_device_assignment_id
                  AND start_date_active < l_end_date
                  AND NVL(end_date_active, SYSDATE) > l_start_date
             )
         AND creation_date BETWEEN l_start_date AND l_end_date;
      g_counter := g_counter + SQL%ROWCOUNT;
      fnd_message.set_name('CSF', 'CSF_GPS_PURGE_DEL_ROWS_STATS');
      fnd_message.set_token('COUNT', SQL%ROWCOUNT);
      debug(fnd_message.get, l_api_name, g_level_cp_output, 4);
    ELSIF p_resource_id IS NOT NULL THEN
      purge_res_location_feeds(p_resource_id, p_resource_type, l_start_date, l_end_date, 0);
    ELSIF p_territory_id IS NOT NULL THEN
      FOR v_res IN c_territory_resources LOOP
        purge_res_location_feeds(v_res.resource_id, v_res.resource_type, l_start_date, l_end_date, 4);
      END LOOP;
    ELSE
      FOR v_vendor IN c_vendors LOOP
        fnd_message.set_name('CSF', 'CSF_GPS_PURGING_VENDOR_LOCS');
        fnd_message.set_token('VENDOR', v_vendor.vendor_name);
        debug(fnd_message.get, l_api_name, g_level_cp_output, 0);

        FOR v_device IN c_vendor_devices(v_vendor.vendor_id) LOOP
          purge_res_device_feeds(v_device.device_id, v_device.device_tag, l_start_date, l_end_date, 4);
        END LOOP;
      END LOOP;
    END IF;

    fnd_message.set_name('CSF', 'CSF_GPS_PURGE_CP_COMPLETED');
    fnd_message.set_token('COUNT', g_counter);
    debug(fnd_message.get, l_api_name, g_level_cp_output, 0);

    COMMIT;
    g_counter := 0;
    retcode := 0;
    fnd_message.set_name('CSF', 'CSF_CP_DONE_SUCCESS');
    errbuf := fnd_message.get;
  EXCEPTION
    WHEN OTHERS THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      retcode := 2;
      g_counter := 0;
      fnd_message.set_name('CSF', 'CSF_CP_DONE_ERROR');
      errbuf := fnd_message.get;
      ROLLBACK TO csf_gps_loc_purge;
  END purge_location_feeds;

  PROCEDURE add_language IS
  BEGIN
    DELETE FROM csf_gps_vendors_tl t
     WHERE NOT EXISTS (SELECT NULL FROM csf_gps_vendors_b b WHERE b.vendor_id = t.vendor_id);

    UPDATE csf_gps_vendors_tl cgvt
       SET (cgvt.vendor_name, cgvt.description) = (
               SELECT cgvtl.vendor_name, cgvtl.description
                 FROM csf_gps_vendors_tl cgvtl
                WHERE cgvtl.vendor_id = cgvt.vendor_id
                  AND cgvtl.language = cgvt.source_lang
             )
     WHERE (cgvt.vendor_id, cgvt.language) IN (
               SELECT subt.vendor_id, subt.language
                 FROM csf_gps_vendors_tl subb, csf_gps_vendors_tl subt
                WHERE subb.vendor_id = subt.vendor_id
                  AND subb.language = subt.source_lang
                  AND (
                          subb.vendor_name <> subt.vendor_name
                       OR subb.description <> subt.description
                       OR (subb.description IS NULL AND subt.description IS NOT NULL)
                       OR (subb.description IS NOT NULL AND subt.description IS NULL)
                      )
             );

    INSERT INTO csf_gps_vendors_tl (
        vendor_id
      , vendor_name
      , description
      , created_by
      , creation_date
      , last_updated_by
      , last_update_date
      , last_update_login
      , language
      , source_lang
      )
      SELECT cgvt.vendor_id
           , cgvt.vendor_name
           , cgvt.description
           , cgvt.created_by
           , cgvt.creation_date
           , cgvt.last_updated_by
           , cgvt.last_update_date
           , cgvt.last_update_login
           , l.language_code
           , cgvt.source_lang
        FROM csf_gps_vendors_tl cgvt
           , fnd_languages l
       WHERE l.installed_flag IN ('I', 'B')
         AND cgvt.language = userenv('LANG')
         AND NOT EXISTS (
               SELECT NULL
                 FROM csf_gps_vendors_tl t
                WHERE t.vendor_id  = cgvt.vendor_id
                  AND t.language = l.language_code
               );
  END add_language;
END csf_gps_pub;

/
