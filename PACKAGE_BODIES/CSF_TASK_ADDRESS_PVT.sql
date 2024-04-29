--------------------------------------------------------
--  DDL for Package Body CSF_TASK_ADDRESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSF_TASK_ADDRESS_PVT" AS
/* $Header: CSFVTADB.pls 120.23.12010000.25 2010/03/11 08:54:51 ppillai ship $ */
  g_debug_enabled         varchar2(1);
  g_debug_level   NUMBER;
   TYPE REF_CURSOR IS REF CURSOR;
   PROCEDURE dbgl (p_msg_data VARCHAR2);

   PROCEDURE put_stream (p_handle IN NUMBER, p_msg_data IN VARCHAR2);

   PROCEDURE show_messages (p_msg_data VARCHAR2);

   PROCEDURE success_log_info (
      p_api_version        IN              NUMBER,
      p_init_msg_list      IN              VARCHAR2,
      p_commit             IN              VARCHAR2,
      p_validation_level   IN              NUMBER,
      p_task_rec           IN              task_rec_type,
      x_return_status      OUT NOCOPY      VARCHAR2,
      x_msg_count          OUT NOCOPY      NUMBER,
      x_msg_data           OUT NOCOPY      VARCHAR2
   );

  procedure init_package is
    begin
      g_debug_enabled  := nvl(fnd_profile.value('AFLOG_ENABLED'), 'N');
      g_debug_level := nvl(fnd_profile.value('AFLOG_LEVEL'), fnd_log.level_event);
    END init_package;

  procedure debug(p_message varchar2, p_module varchar2, p_level number) is
   begin
    IF g_debug_enabled = 'Y' AND p_level >= g_debug_level THEN
      IF fnd_file.log > 0 THEN
        IF p_message = ' ' THEN
          fnd_file.put_line(fnd_file.log, '');
        ELSE
          fnd_file.put_line(fnd_file.log, rpad(p_module, 20) || ': ' || p_message);
        END IF;
      ELSE
        fnd_log.string(p_level, 'csf.plsql.CSF_TASK_ADDRESS_PVT.' || p_module, p_message);
      END IF;
    END IF;
    --dbms_output.put_line(rpad(p_module, 20) || ': ' || p_message);
  END debug;

   PROCEDURE update_geometry (p_location_id IN NUMBER)
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      UPDATE hz_locations
         SET geometry = NULL
       WHERE location_id = p_location_id;

      COMMIT;
   END;

   PROCEDURE validate_address (
      errbuf         OUT NOCOPY      VARCHAR2,
      retcode        OUT NOCOPY      VARCHAR2,
      p_start_date   in              varchar2 default null,
      p_end_date     in              varchar2 default null,
      p_unstamped_only   in              varchar2 default 'Yes'
   )
   IS
      l_api_name      CONSTANT VARCHAR2 (30)      := 'VALIDATE_ADDRESS';
      l_api_version   CONSTANT NUMBER             := 1.0;
      -- predefined error codes for concurrent programs
      l_rc_succ       CONSTANT NUMBER             := 0;
      l_rc_warn       CONSTANT NUMBER             := 1;
      l_rc_err        CONSTANT NUMBER             := 2;
      -- predefined error buffer output strings (replaced by translated messages)
      l_msg_succ               VARCHAR2 (80);
      l_msg_warn               VARCHAR2 (80);
      l_msg_err                VARCHAR2 (80);
      --
      -- the date range
      --
      l_start_date             DATE;
      l_end_date               DATE;
      --
      -- date format mask for output message
      --
      l_fmt                    VARCHAR2 (100);
      i                        NUMBER;
      l_result                 VARCHAR2 (30);
      l_locus                  MDSYS.SDO_GEOMETRY;
      l_validated_flag         VARCHAR2 (30);
      l_task_rec               task_rec_type;
      l_task_rec_tbl           task_rec_tbl_type;
      l_return_status          VARCHAR2 (1);
      l_msg_count              NUMBER;
      l_msg_data               VARCHAR2 (2000);
      x_app_name               VARCHAR2 (32767);
      x_msg_name               VARCHAR2 (32767);
      l_time_zone_check        BOOLEAN;
      l_timezone_id            VARCHAR2 (80);

      CURSOR c_timezone_check (p_timezone_id NUMBER)
      IS
         SELECT NAME
           FROM fnd_timezones_vl
          WHERE timezone_code = p_timezone_id;
   BEGIN
      -- Initialize message list
      fnd_msg_pub.initialize;
      -- get termination messages
      fnd_message.set_name ('CSF', 'CSF_GST_DONE_SUCC');
      l_msg_succ := fnd_message.get;
      fnd_message.set_name ('CSF', 'CSF_GST_DONE_WARN');
      l_msg_warn := fnd_message.get;
      fnd_message.set_name ('CSF', 'CSF_GST_DONE_ERR');
      l_msg_err := fnd_message.get;
      -- Initialize API return status to success
      retcode := l_rc_succ;
      errbuf := l_msg_succ;
      -- API body
      fnd_message.set_name ('CSF', 'CSF_FIND_INVALID_ADDRESS');
      l_msg_data := fnd_message.get;
      put_stream (g_output, l_msg_data);

      --
      -- start date defaults to today (truncated)
      -- later converted back to server timezone
      -- e.g. client timezone is CET (GMT+1)
      --      server timezone is PST (GMT-8)
      --      If it is 6-Aug 06:00 for the client, then it is 5-Aug 21:00 for the
      --      server, and trunc(sysdate) will give 5-Aug instead of 6-Aug.  Hence
      --      we need to convert to client timezone before truncating.
      --      When the parameter *is* specified, in the same case it will already
      --      read 6-aug-2003.
      --
      IF p_start_date IS NULL
      THEN
         l_start_date :=
                     TRUNC (csf_timezones_pvt.date_to_client_tz_date (SYSDATE));
         -- convert to server timezone
         l_start_date :=
                        csf_timezones_pvt.date_to_server_tz_date (l_start_date);
      ELSE
         -- all fnd_date converts to server timezone so need for conversion
         l_start_date := fnd_date.canonical_to_date (p_start_date);
      END IF;

      --
      -- end date defaults to same day as start date (also truncated)
      --
      IF p_end_date IS NULL
      THEN
         l_end_date := l_start_date + 15;
      ELSE
         l_end_date := fnd_date.canonical_to_date (p_end_date);
      END IF;

      --
      -- get date format
      l_fmt := fnd_profile.VALUE ('ICX_DATE_FORMAT_MASK');

      IF l_fmt IS NULL
      THEN
         l_fmt := 'dd-MON-yyyy';
      END IF;

      --
      -- feedback the date range
      fnd_message.set_name ('CSF', 'CSF_AUTO_COMMIT_DATE_RANGE');
      fnd_message.set_token ('P_START_DATE', TO_CHAR (l_start_date, l_fmt));
      fnd_message.set_token ('P_END_DATE', TO_CHAR (l_end_date, l_fmt));
      put_stream (g_output, fnd_message.get);
      --
      -- finally convert the date range to server timezone before processing
      --
      l_start_date := csf_timezones_pvt.date_to_server_tz_date (l_start_date);
      l_end_date := csf_timezones_pvt.date_to_server_tz_date (l_end_date);
      retrieve_data (p_api_version           => 1.0,
                     p_init_msg_list         => fnd_api.g_false,
                     p_commit                => fnd_api.g_false,
                     p_validation_level      => fnd_api.g_valid_level_full,
                     p_start_date            => l_start_date,
                     p_end_date              => l_end_date,
                     x_task_rec_tbl          => l_task_rec_tbl,
                     x_return_status         => l_return_status,
                     x_msg_count             => l_msg_count,
                     x_msg_data              => l_msg_data,
                     p_unstamped_only        => p_unstamped_only
                    );

      IF l_return_status <> fnd_api.g_ret_sts_success
      THEN
         fnd_message.set_name ('CSF', 'CSF_RETRIEVE_DATA_ERROR');
         l_msg_data := fnd_message.get;
         put_stream (g_log, l_msg_data);
         RAISE fnd_api.g_exc_error;
      END IF;

      IF l_task_rec_tbl.COUNT > 0
      THEN
         i := l_task_rec_tbl.FIRST;

         WHILE i IS NOT NULL
         LOOP
            l_task_rec := l_task_rec_tbl (i);

          /*  IF l_task_rec.timezone_id IS NULL
            THEN
               l_time_zone_check := FALSE;
            ELSE
               OPEN c_timezone_check (l_task_rec.timezone_id);

               FETCH c_timezone_check
                INTO l_timezone_id;

               IF l_timezone_id IS NOT NULL
               THEN
                  l_time_zone_check := TRUE;
               ELSE
                  l_time_zone_check := FALSE;
               END IF;

               CLOSE c_timezone_check;
            END IF;

            IF l_time_zone_check
            THEN */

               csf_resource_address_pvt.resolve_address
                              (p_api_version        => 1.0,
                               p_init_msg_list      => fnd_api.g_false,
                               p_country            => NVL (l_task_rec.country,
                                                            '_'
                                                           ),
                               p_state              => NVL (l_task_rec.state,
                                                            '_'
                                                            ),
                               p_city               => NVL (l_task_rec.city,
                                                            '_'
					         	    ),
        		       p_county             => NVL (l_task_rec.county,
                                                             '_'
				 		 	    ),
                               p_province           => NVL (l_task_rec.province,
                                                             '_'
							    ),
                               p_postalcode         => NVL
                                                          (l_task_rec.postal_code,
                                                           '_'
                                                           ),
                               p_address1           => NVL (l_task_rec.address1,
                                                            '_'
                                                            ),
                               p_address2           => NVL (l_task_rec.address2,
                                                            '_'
                                                            ),
                               p_address3           => NVL (l_task_rec.address3,
                                                            '_'
                                                           ),
                               p_address4           => NVL (l_task_rec.address4,
                                                            '_'
                                                           ),
                               p_building_num       => '_',
                               p_alternate          => '_',
                               p_location_id        => NVL
                                                          (l_task_rec.location_id,
                                                           -1
                                                          ),
                               p_country_code       => NVL
                                                          (l_task_rec.country_code,
                                                           '_'
                                                          ),
                               x_return_status      => l_return_status,
                               x_msg_count          => l_msg_count,
                               x_msg_data           => l_msg_data,
                               x_geometry           => l_locus,
                               p_update_address     => 'F'
                              );

               if l_return_status <> fnd_api.g_ret_sts_success
               then
				  update_geometry (l_task_rec.location_id);
                  fnd_message.set_name ('CSF', 'CSF_RESOLVE_ADDRESS_ERROR');
                  fnd_message.set_token ('RETURN_STATUS', l_return_status);
                  fnd_message.set_token ('LOCATION_ID', l_task_rec.location_id);
                  l_msg_data := fnd_message.get;
                  put_stream (g_log, l_msg_data);
                  l_task_rec.validated_flag := g_valid_false;
                  l_task_rec.override_flag := g_valid_false;
                  log_info (p_api_version           => 1.0,
                            p_init_msg_list         => fnd_api.g_false,
                            p_commit                => fnd_api.g_true,
                            p_validation_level      => fnd_api.g_valid_level_full,
                            p_task_rec              => l_task_rec,
                            x_return_status         => l_return_status,
                            x_msg_count             => l_msg_count,
                            x_msg_data              => l_msg_data
                           );

                  IF l_return_status <> fnd_api.g_ret_sts_success
                  THEN
                     fnd_message.set_name ('CSF', 'CSF_LOG_INFO_ERROR');
                     fnd_message.set_token ('LOCATION_ID',
                                            l_task_rec.location_id
                                           );
                     fnd_message.set_token ('RETURN_STATUS', l_return_status);
                     l_msg_data := fnd_message.get;
                     put_stream (g_log, l_msg_data);
                     put_stream (g_output, l_msg_data);
                     RAISE fnd_api.g_exc_error;
                  END IF;
	       ELSIF l_return_status = fnd_api.g_ret_sts_success
	       THEN
                  l_task_rec.validated_flag := g_valid_true;
                  l_task_rec.override_flag := g_valid_true;
                  success_log_info (p_api_version           => 1.0,
                                    p_init_msg_list         => fnd_api.g_false,
                                    p_commit                => fnd_api.g_true,
                                    p_validation_level      => fnd_api.g_valid_level_full,
                                    p_task_rec              => l_task_rec,
                                    x_return_status         => l_return_status,
                                    x_msg_count             => l_msg_count,
                                    x_msg_data              => l_msg_data
                                   );
                  IF l_return_status <> fnd_api.g_ret_sts_success
                  THEN
                     fnd_message.set_name ('CSF', 'CSF_LOG_INFO_ERROR');
                     fnd_message.set_token ('LOCATION_ID', l_task_rec.location_id);
                     fnd_message.set_token ('RETURN_STATUS', l_return_status);
                     l_msg_data := fnd_message.get;
                     put_stream (g_log, l_msg_data);
                     put_stream (g_output, l_msg_data);
                     RAISE fnd_api.g_exc_error;
                  END IF;
               END IF;                                        -- resolve_address
      /*      ELSE                                      -- l_Time_zone_check false
               update_geometry (l_task_rec.location_id);
               l_return_status := fnd_api.g_ret_sts_unexp_error;
               fnd_message.set_name ('CSF', 'CSF_TIME_ZONE_ERROR');
               fnd_message.set_token ('RETURN_STATUS', l_return_status);
               fnd_message.set_token ('LOCATION_ID', l_task_rec.location_id);
               log_info (p_api_version           => 1.0,
                         p_init_msg_list         => fnd_api.g_false,
                         p_commit                => fnd_api.g_true,
                         p_validation_level      => fnd_api.g_valid_level_full,
                         p_task_rec              => l_task_rec,
                         x_return_status         => l_return_status,
                         x_msg_count             => l_msg_count,
                         x_msg_data              => l_msg_data
                        );

               IF l_return_status <> fnd_api.g_ret_sts_success
               THEN
                  fnd_message.set_name ('CSF', 'CSF_LOG_INFO_ERROR');
                  fnd_message.set_token ('LOCATION_ID', l_task_rec.location_id);
                  fnd_message.set_token ('RETURN_STATUS', l_return_status);
                  l_msg_data := fnd_message.get;
                  put_stream (g_log, l_msg_data);
                  put_stream (g_output, l_msg_data);
                  RAISE fnd_api.g_exc_error;
               END IF;
           END IF;                                         -- l_Time_zone_check */

            i := l_task_rec_tbl.NEXT (i);
         END LOOP;
      ELSIF l_task_rec_tbl.COUNT = 0
      THEN
         fnd_message.set_name ('CSF', 'CSF_NO_DATA_TOPROCESS');
         l_msg_data := fnd_message.get;
         put_stream (g_log, l_msg_data);
      END IF;

      put_stream (g_log, l_msg_succ);
      put_stream (g_output, l_msg_succ);
      -- End of API body

      -- Standard call to get message count and return the message info if the count is 1
      fnd_msg_pub.count_and_get (p_count => l_msg_count, p_data => l_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         retcode := l_rc_err;
         errbuf := l_msg_err;
         fnd_msg_pub.count_and_get (p_count      => l_msg_count,
                                    p_data       => l_msg_data
                                   );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         retcode := l_rc_err;
         errbuf := l_msg_err;
         fnd_msg_pub.count_and_get (p_count      => l_msg_count,
                                    p_data       => l_msg_data
                                   );
      WHEN OTHERS
      THEN
         retcode := l_rc_err;
         errbuf := l_msg_err;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count      => l_msg_count,
                                    p_data       => l_msg_data);
   END validate_address;


   procedure form_task_address_query(
                       p_dataset 		            in varchar2,
                       p_start_date  	          in date,
                       p_end_date 	            in date,
                       i                        in out nocopy number,
                       x_task_rec_tbl           in out nocopy task_rec_tbl_type,
                       p_task_address_cursor    in out nocopy ref_cursor,
                       p_unstamped_only         IN VARCHAR2 DEFAULT 'Yes' )
   IS
   l_api_name      CONSTANT VARCHAR2 (30) := 'form_task_address_query';
   l_query VARCHAR2(4000);

   TYPE task_address_rec_type IS RECORD (
      task_id             jtf_tasks_b.task_id%TYPE,
      task_number         jtf_tasks_b.task_number%TYPE,
      location_id         hz_locations.location_id%TYPE,
      address_style       hz_locations.address_style%TYPE,
      address1            hz_locations.address1%TYPE,
      address2            hz_locations.address2%TYPE,
      address3            hz_locations.address3%TYPE,
      address4            hz_locations.address4%type,
      city                hz_locations.city%TYPE,
      postal_code         hz_locations.postal_code%TYPE,
      county              hz_locations.county%TYPE,
      state               hz_locations.state%TYPE,
      province            hz_locations.province%TYPE,
      country             hz_locations.country%TYPE,
      country_code        VARCHAR2 (30),
      timezone_id         hz_locations.timezone_id%type
   );

   i_retrieve_task_data task_address_rec_type;
   BEGIN
    l_query := 'SELECT t.task_id,
                t.task_number,
                l.location_id,
                l.address_style,
                l.address1,
                l.address2,
                l.address3,
                l.address4,
                l.city,
                l.postal_code,
                l.county,
                l.state,
                l.province,
                tl.territory_short_name country,
                l.country country_code,
                l.timezone_id
           FROM jtf_tasks_b t,
                jtf_task_types_b tt,
                hz_locations l,
                fnd_territories_tl tl,
                jtf_task_statuses_vl jts,
                csf_sdm_ctry_profiles' || p_dataset || ' cp,
                csf_spatial_ctry_mappings cm
          WHERE tt.task_type_id = t.task_type_id
            AND t.location_id is not null
            AND l.location_id = t.location_id
            AND tl.territory_code = l.country
            and cp.country_code_a3 = cm.spatial_country_code
            and cm.hr_country_code = l.country
	        AND tl.language = ''US''
            AND t.source_object_type_code = ''SR''
            AND t.deleted_flag <> ''Y''
            AND tt.rule = ''DISPATCH''
            AND t.task_status_id = jts.task_status_id
            AND NVL (jts.schedulable_flag, ''N'') = ''Y''
            AND t.planned_start_date BETWEEN Trunc(:1) AND Trunc(:2) + .99998';

     if(p_unstamped_only = 'Yes')
     then
      l_query := l_query || ' AND l.geometry IS NULL';
     end if;

    l_query := l_query || ' UNION
         SELECT t.task_id,
                t.task_number,
                l.location_id,
                l.address_style,
                l.address1,
                l.address2,
                l.address3,
                l.address4,
                l.city,
                l.postal_code,
                l.county,
                l.state,
                l.province,
                tl.territory_short_name country,
                l.country country_code,
                l.timezone_id
           FROM jtf_tasks_b t,
                jtf_task_types_b tt,
                hz_party_sites hps,
                hz_locations l,
                fnd_territories_tl tl,
                jtf_task_statuses_vl jts,
                csf_sdm_ctry_profiles' || p_dataset || ' cp,
                csf_spatial_ctry_mappings cm
          WHERE tt.task_type_id = t.task_type_id
            AND t.address_id is not null
            AND t.address_id = hps.party_site_id
            AND l.location_id = hps.location_id
            and cp.country_code_a3 = cm.spatial_country_code
            and cm.hr_country_code = l.country
            AND tl.territory_code = l.country
            AND tl.language = ''US''
            AND t.source_object_type_code = ''SR''
            AND t.deleted_flag <> ''Y''
            AND tt.rule = ''DISPATCH''
            AND t.task_status_id = jts.task_status_id
            AND NVL (jts.schedulable_flag, ''N'') = ''Y''
            AND t.planned_start_date BETWEEN Trunc(:3) AND Trunc(:4) + .99998';

        if(p_unstamped_only = 'Yes')
         then
          l_query := l_query || ' AND l.geometry IS NULL';
         end if;

	OPEN p_task_address_cursor FOR l_query USING p_start_date, p_end_date, p_start_date, p_end_date;
        LOOP
             FETCH p_task_address_cursor INTO i_retrieve_task_data;
             EXIT WHEN p_task_address_cursor%NOTFOUND;
              x_task_rec_tbl (i).task_id := i_retrieve_task_data.task_id;
              x_task_rec_tbl (i).task_number := i_retrieve_task_data.task_number;
              x_task_rec_tbl (i).location_id := i_retrieve_task_data.location_id;
              x_task_rec_tbl (i).address1 :=
                                          UPPER (i_retrieve_task_data.address1);
              x_task_rec_tbl (i).address2 :=
                                          UPPER (i_retrieve_task_data.address2);
              x_task_rec_tbl (i).address3 :=
                                          UPPER (i_retrieve_task_data.address3);
              x_task_rec_tbl (i).address4 :=
                                          UPPER (i_retrieve_task_data.address4);
              x_task_rec_tbl (i).address_style :=
                                     UPPER (i_retrieve_task_data.address_style);
              x_task_rec_tbl (i).postal_code :=
                                       UPPER (i_retrieve_task_data.postal_code);
              x_task_rec_tbl (i).city := UPPER (i_retrieve_task_data.city);
              x_task_rec_tbl (i).province :=
                                          UPPER (i_retrieve_task_data.province);
              x_task_rec_tbl (i).state := UPPER (i_retrieve_task_data.state);
              x_task_rec_tbl (i).county := UPPER (i_retrieve_task_data.county);
              x_task_rec_tbl (i).country := UPPER (i_retrieve_task_data.country);
              x_task_rec_tbl (i).country_code :=
                                      UPPER (i_retrieve_task_data.country_code);
              x_task_rec_tbl (i).timezone_id :=
                                      upper (i_retrieve_task_data.timezone_id);
              i := i + 1;
          END LOOP;
  CLOSE p_task_address_cursor;
  EXCEPTION
     WHEN OTHERS
      THEN
		debug('CSF_TASK_ADDRESS_PVT.form_task_address_query: Error = ' || SQLERRM, l_api_name, fnd_log.level_error);
 END form_task_address_query;

PROCEDURE retrieve_data (
      p_api_version        IN              NUMBER,
      p_init_msg_list      IN              VARCHAR2,
      p_commit             IN              VARCHAR2,
      p_validation_level   IN              NUMBER,
      p_start_date         IN              DATE DEFAULT NULL,
      p_end_date           IN              DATE  DEFAULT NULL,
      x_task_rec_tbl       OUT NOCOPY      task_rec_tbl_type,
      x_return_status      OUT NOCOPY      VARCHAR2,
      x_msg_count          OUT NOCOPY      NUMBER,
      x_msg_data           out nocopy      varchar2,
      p_unstamped_only     IN              VARCHAR2 DEFAULT 'Yes'
   )
   IS
      l_api_name      CONSTANT VARCHAR2 (30) := 'RETRIEVE_DATA';
      l_api_version   CONSTANT NUMBER        := 1.0;
      i                        number;
      l_task_rec               task_rec_type;
  	  task_address_cursor ref_cursor;
      l_mds_enabled		varchar2(10);

	  cursor mdsListCur is
		select distinct spatial_dataset from csf_spatial_ctry_mappings;

   BEGIN
      -- Standard check for call compatibility
      IF NOT fnd_api.compatible_api_call (l_api_version,
                                          p_api_version,
                                          l_api_name,
                                          g_pkg_name
                                         )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      -- Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      -- API body
      i := 1;


	l_mds_enabled:= fnd_profile.value('CSF_SPATIAL_MULTIDATASET_ENABLED');
	--If Single dataset, select tasks which belongs to that dataset
  --If Multi dataset, select tasks which belongs to datasets listed in csf_spatial_ctry_mappings
	if( l_mds_enabled = 'N' or l_mds_enabled is null)
	then
 		 form_task_address_query('',
                              p_start_date,
                              p_end_date,
                              i,
                              x_task_rec_tbl,
                              task_address_cursor,
                              p_unstamped_only);
	ELSE
		FOR mdsList IN mdsListCur
		loop
			form_task_address_query(mdslist.spatial_dataset,
                              p_start_date,
                              p_end_date,
                              i,
                              x_task_rec_tbl,
                              task_address_cursor,
                              p_unstamped_only);
		END LOOP;
	END IF;

      -- Standard check of p_commit
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Standard call to get message count and return the message info if the count is 1
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
		debug('CSF_TASK_ADDRESS_PVT.retrieve_data: Unexpected Error = ' || x_msg_data, l_api_name, fnd_log.level_error);
      WHEN OTHERS
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data);
		debug('CSF_TASK_ADDRESS_PVT.retrieve_data: Unexpected Error = ' || x_msg_data, l_api_name, fnd_log.level_error);
   END retrieve_data;

/*
    Utility procedure to fetch the locus for a location id.
    returns the locus given the location_id from the hz locations table
*/
   PROCEDURE get_geometry (
      p_api_version        IN              NUMBER,
      p_init_msg_list      IN              VARCHAR2,
      p_commit             IN              VARCHAR2,
      p_validation_level   IN              NUMBER,
      p_location_id        IN              hz_locations.location_id%TYPE,
      x_locus              OUT NOCOPY      hz_locations.geometry%TYPE,
      x_return_status      OUT NOCOPY      VARCHAR2,
      x_msg_count          OUT NOCOPY      NUMBER,
      x_msg_data           OUT NOCOPY      VARCHAR2
   )
   IS
      l_api_name      CONSTANT VARCHAR2 (30) := 'GET_GEOMETRY';
      l_api_version   CONSTANT NUMBER        := 1.0;

      CURSOR l_check_locus_csr (l_location_id hz_locations.location_id%TYPE)
      IS
         SELECT geometry
           FROM hz_locations
          WHERE location_id = l_location_id;
   BEGIN
      -- Standard check for call compatibility
      IF NOT fnd_api.compatible_api_call (l_api_version,
                                          p_api_version,
                                          l_api_name,
                                          g_pkg_name
                                         )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      -- Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      -- API body
      BEGIN
         OPEN l_check_locus_csr (p_location_id);

         FETCH l_check_locus_csr
          INTO x_locus;

         CLOSE l_check_locus_csr;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            CLOSE l_check_locus_csr;
         WHEN OTHERS
         THEN
            CLOSE l_check_locus_csr;

            RAISE fnd_api.g_exc_unexpected_error;
      END;

      -- End of API body

      -- Standard check of p_commit
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Standard call to get message count and return the message info if the count is 1
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
      WHEN OTHERS
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data);
   END get_geometry;

--    This function is used to check if the geometry is null.
--
--    returns:
--        FALSE if the geometry is null or any of the components are null.
--        TRUE otherwise
   FUNCTION is_geometry_null (p_locus IN MDSYS.SDO_GEOMETRY)
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN (   (p_locus IS NULL)
              OR (p_locus.sdo_srid IS NULL)
              OR (p_locus.sdo_elem_info IS NULL)
              OR (p_locus.sdo_ordinates IS NULL)
             );
   END is_geometry_null;

--    This function is used to check if the geometry is valid.
--    returns :
--        'Y' if the geometry is valid ,
--        'N' otherwise
   PROCEDURE is_geometry_valid (
      p_api_version        IN              NUMBER,
      p_init_msg_list      IN              VARCHAR2,
      p_commit             IN              VARCHAR2,
      p_validation_level   IN              NUMBER,
      p_locus              IN              hz_locations.geometry%TYPE,
      x_result             OUT NOCOPY      VARCHAR2,
      x_return_status      OUT NOCOPY      VARCHAR2,
      x_msg_count          OUT NOCOPY      NUMBER,
      x_msg_data           OUT NOCOPY      VARCHAR2
   )
   IS
      l_api_name      CONSTANT VARCHAR2 (30) := 'IS_GEOMETRY_VALID';
      l_api_version   CONSTANT NUMBER        := 1.0;
   BEGIN
      -- Standard check for call compatibility
      IF NOT fnd_api.compatible_api_call (l_api_version,
                                          p_api_version,
                                          l_api_name,
                                          g_pkg_name
                                         )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      -- Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      -- API body
      x_result := g_valid_false;
      /*
          Returns :
              'TRUE' on success ,
              'FALSE' otherwise
      */
      csf_locus_pub.verify_locus (p_api_version        => 1.0,
                                  p_locus              => p_locus,
                                  x_msg_count          => x_msg_count,
                                  x_msg_data           => x_msg_data,
                                  x_result             => x_result,
                                  x_return_status      => x_return_status
                                 );

      IF (x_result = 'TRUE')
      THEN
         x_result := g_valid_true;
      ELSE
         x_result := g_valid_false;
      END IF;

      x_return_status := fnd_api.g_ret_sts_success;

      -- End of API body

      -- Standard check of p_commit
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Standard call to get message count and return the message info if the count is 1
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
      WHEN OTHERS
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data);
   END is_geometry_valid;

    PROCEDURE get_error_detail (
      p_api_version        IN              NUMBER,
      p_init_msg_list      IN              VARCHAR2,
      p_commit             IN              VARCHAR2,
      p_validation_level   IN              NUMBER,
      p_task_rec           IN              task_rec_type,
      x_error              OUT NOCOPY      VARCHAR2,
      x_error_detail       OUT NOCOPY      VARCHAR2,
      x_return_status      OUT NOCOPY      VARCHAR2,
      x_msg_count          OUT NOCOPY      NUMBER,
      x_msg_data           OUT NOCOPY      VARCHAR2
   )
   IS
      l_api_name      CONSTANT VARCHAR2 (30)   := 'GET_ERROR_DETAIL';
      l_api_version   CONSTANT NUMBER          := 1.0;
      l_tmp                    VARCHAR2 (2000);
      l_place                  VARCHAR2 (250);
      l_flag                   VARCHAR2 (1);

      CURSOR l_place_csr (l_place_name VARCHAR2, l_parent_level NUMBER)
      IS
         SELECT NAME
           FROM csf_lf_places p, csf_lf_names n, csf_lf_place_names pn
          WHERE n.name_id = pn.name_id
            AND pn.place_id = p.place_id
            AND NAME = l_place_name
            AND p.place_parent_level = l_parent_level;

      l_uk_city  VARCHAR2(1000);
      l_dataset_profile_value VARCHAR2(1000);
      l_place_country VARCHAR2(1000);
      l_place_state VARCHAR2(1000);
      l_place_city VARCHAR2(1000);
      l_place_zip  VARCHAR2(1000);
      l_spatail_dataset VARCHAR2(10) := '';

      TYPE REF_CURSOR IS REF CURSOR;
      process_cursor REF_CURSOR;

         l_country VARCHAR2(100);
      CURSOR ctry_hr_to_spatial IS
       SELECT SPATIAL_COUNTRY_NAME,spatial_dataset
       FROM CSF_SPATIAL_CTRY_MAPPINGS
       WHERE HR_COUNTRY_NAME = p_task_rec.country;

   BEGIN
      -- Standard check for call compatibility
      IF NOT fnd_api.compatible_api_call (l_api_version,
                                          p_api_version,
                                          l_api_name,
                                          g_pkg_name
                                         )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      -- Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;


      open ctry_hr_to_spatial;
  fetch ctry_hr_to_spatial into l_country,  l_spatail_dataset;
  close ctry_hr_to_spatial;

  IF (l_country is null) THEN
    l_country := p_task_rec.country;
    END IF;

    l_dataset_profile_value  := fnd_profile.value('CSF_SPATIAL_MULTIDATASET_ENABLED');
    IF (l_dataset_profile_value = 'N' OR l_dataset_profile_value IS NULL ) THEN
       l_dataset_profile_value := '';
    ELSE
       l_dataset_profile_value :=  l_spatail_dataset;
    END IF;

      l_uk_city :='   SELECT cln.NAME
           FROM csf_lf_names'||l_dataset_profile_value||' cln,
           csf_lf_place_names'||l_dataset_profile_value||' clpn,
           csf_lf_places'||l_dataset_profile_value||' clp
          WHERE cln.name_id = clpn.name_id
            AND clpn.place_id = clp.place_id
            AND clp.place_parent_level NOT IN (-1, 0)
            AND UPPER (cln.NAME) = UPPER ('''||p_task_rec.city||''')';

       l_place_country :='         SELECT n.NAME
           FROM csf_lf_places'||l_dataset_profile_value||' p,
           csf_lf_place_names'||l_dataset_profile_value||' pn,
           csf_lf_names'||l_dataset_profile_value||' n
          WHERE n.NAME = UPPER ('''||l_country||''')
            AND pn.name_id = n.name_id
            AND p.place_id = pn.place_id
            AND p.place_parent_level = -1';

      l_place_state :=' SELECT n.NAME
           FROM csf_lf_names'||l_dataset_profile_value||' n,
                csf_lf_place_names'||l_dataset_profile_value||' pn,
                (SELECT     place_id
                       FROM csf_lf_places'||l_dataset_profile_value||'
                 CONNECT BY PRIOR place_id = parent_place_id
                 START WITH place_id IN (
                               SELECT pn.place_id
                                 FROM csf_lf_names'||l_dataset_profile_value||' n,
                                 csf_lf_place_names'||l_dataset_profile_value||' pn
                                WHERE n.NAME = UPPER ('''|| l_country||''')
                                  AND pn.name_id = n.name_id)) p
          WHERE pn.place_id = p.place_id
            AND n.name_id = pn.name_id
            AND n.NAME = UPPER ('''||p_task_rec.state||''')';


      -- API body
      IF p_task_rec.country_code = 'GB'
      THEN
         BEGIN
            l_tmp := NULL;

            OPEN process_cursor FOR l_uk_city;

            FETCH process_cursor
             INTO l_tmp;

            IF l_tmp IS NULL AND trim(p_task_rec.city) <> '_'
            THEN
               fnd_message.set_name ('CSF', 'CSF_CITY_NOT_FOUND_ERROR');
               fnd_message.set_token ('CITY', p_task_rec.city);
               fnd_message.set_token ('COUNTRY', p_task_rec.country);
               x_error := fnd_message.get;
               x_error_detail := x_error_detail || ' ' || x_error;
            END IF;

            CLOSE process_cursor;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               CLOSE process_cursor;
            WHEN OTHERS
            THEN
               CLOSE process_cursor;

               RAISE fnd_api.g_exc_unexpected_error;
         END;
      ELSE

	 BEGIN
            l_tmp := NULL;

            OPEN process_cursor FOR l_place_country;

            FETCH process_cursor
             INTO l_tmp;

            IF l_tmp IS NULL AND trim(p_task_rec.country) <> '_'
            THEN
               fnd_message.set_name ('CSF', 'CSF_COUNTRY_NOT_FOUND_ERROR');
               fnd_message.set_token ('COUNTRY', p_task_rec.country);
               x_error := fnd_message.get;
               x_error_detail := x_error_detail || ' ' || x_error;
            END IF;

            CLOSE process_cursor;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               CLOSE process_cursor;
            WHEN OTHERS
            THEN
               CLOSE process_cursor;

               RAISE fnd_api.g_exc_unexpected_error;
         END;

         BEGIN
            l_tmp := NULL;

            OPEN process_cursor FOR l_place_state;

            FETCH process_cursor
             INTO l_tmp;

            IF l_tmp IS NULL AND trim(p_task_rec.state) <> '_' AND trim(p_task_rec.country) <> '_'
            THEN
               fnd_message.set_name ('CSF', 'CSF_STATE_NOT_FOUND_ERROR');
               fnd_message.set_token ('STATE', p_task_rec.state);
               fnd_message.set_token ('COUNTRY', p_task_rec.country);
               x_error := fnd_message.get;
               x_error_detail := x_error_detail || ' ' || x_error;
            END IF;

            CLOSE process_cursor;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               CLOSE process_cursor;
            WHEN OTHERS
            THEN
               CLOSE process_cursor;

               RAISE fnd_api.g_exc_unexpected_error;
         END;

         BEGIN
            l_tmp := NULL;

            l_flag := NULL;

            IF p_task_rec.state IS NOT NULL AND trim(p_task_rec.state) <> '_'
            THEN
               l_place := p_task_rec.state;
               l_flag := 'S';
            ELSE
               l_place := l_country;
               l_flag := NULL;
            END IF;

           l_place_city :='        SELECT n.NAME
           FROM csf_lf_names'||l_dataset_profile_value||'  n,
                csf_lf_place_names'||l_dataset_profile_value||'  pn,
                (SELECT     place_id
                       FROM csf_lf_places'||l_dataset_profile_value||'
                      WHERE place_parent_level IN (1, 8)
                 CONNECT BY PRIOR place_id = parent_place_id
                 START WITH place_id IN (
                               SELECT pn.place_id
                                 FROM csf_lf_names'||l_dataset_profile_value||'  n,
                                 csf_lf_place_names'||l_dataset_profile_value||'  pn
                                WHERE n.NAME = UPPER ('''||l_place||''')
                                  AND pn.name_id = n.name_id)) p
           WHERE pn.place_id = p.place_id
            AND n.name_id = pn.name_id
            AND n.NAME = UPPER ('''||p_task_rec.city||''')';

	    OPEN process_cursor FOR l_place_city;

            FETCH process_cursor
             INTO l_tmp;

            IF l_tmp IS NULL
            THEN
               IF l_flag = 'S' AND trim(p_task_rec.state) <> '_' AND trim(p_task_rec.city) <> '_'
               THEN
                  fnd_message.set_name ('CSF',
                                        'CSF_CITY_NOT_FOUND_ERROR_STATE');
                  fnd_message.set_token ('CITY', p_task_rec.city);
                  fnd_message.set_token ('STATE', p_task_rec.state);
               ELSIF trim(p_task_rec.country) <> '_' AND trim(p_task_rec.city) <> '_'
               THEN
                  fnd_message.set_name ('CSF', 'CSF_CITY_NOT_FOUND_ERROR');
                  fnd_message.set_token ('CITY', p_task_rec.city);
                  fnd_message.set_token ('COUNTRY', p_task_rec.country);
               END IF;

               x_error := fnd_message.get;
               x_error_detail := x_error_detail || ' ' || x_error;
            END IF;

            CLOSE process_cursor;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               CLOSE process_cursor;
            WHEN OTHERS
            THEN
               CLOSE process_cursor;

               RAISE fnd_api.g_exc_unexpected_error;
         END;

         BEGIN
            l_tmp := NULL;

            IF p_task_rec.city IS NOT NULL AND trim(p_task_rec.city) <> '_'
            THEN
               l_place := p_task_rec.city;
               l_flag := 'C';
            ELSIF p_task_rec.state IS NOT NULL AND trim(p_task_rec.state) <> '_'
            THEN
               l_place := p_task_rec.state;
               l_flag := 'S';
            ELSE
               l_place := l_country;
               l_flag := NULL;
            END IF;

       l_place_zip := 'SELECT pc.postal_code
       FROM csf_lf_postcodes'||l_dataset_profile_value||' pc,
                csf_lf_place_postcs'||l_dataset_profile_value||' ppc,
                csf_lf_place_names'||l_dataset_profile_value||' pn,
                csf_lf_names'||l_dataset_profile_value||' n
          WHERE pc.postal_code_id = ppc.postal_code_id
            AND ppc.place_id = pn.place_id
            AND pn.name_id = n.name_id
	    AND pc.postal_code = '''||p_task_rec.postal_code||'''
            AND EXISTS (
                   SELECT     1
                         FROM csf_lf_places'||l_dataset_profile_value||'
                        WHERE place_id IN (
                                 SELECT clpn.place_id
                                   FROM csf_lf_names'||l_dataset_profile_value||' cln,
                                        csf_lf_place_names'||l_dataset_profile_value||' clpn
                                  WHERE cln.NAME = '''||l_place||'''
                                    AND cln.name_id = clpn.name_id)
                   CONNECT BY place_id = PRIOR parent_place_id
                   START WITH place_id = pn.place_id)';

           OPEN process_cursor FOR l_place_zip;

           FETCH process_cursor
             INTO l_tmp;

            IF l_tmp IS NULL
            THEN
                IF l_flag = 'C'  AND trim(p_task_rec.postal_code) <> '_' AND trim (p_task_rec.city) <> '_'
                THEN
                  fnd_message.set_name ('CSF',
                                           'CSF_ZIP_NOT_FOUND_ERROR_CITY'
                                          );
                  fnd_message.set_token ('ZIP', p_task_rec.postal_code);
                  fnd_message.set_token ('CITY', p_task_rec.city);
                  x_error := fnd_message.get;
                  x_error_detail := x_error_detail || ' ' || x_error;
               ELSIF l_flag = 'S'  AND trim(p_task_rec.postal_code) <> '_' AND trim (p_task_rec.state) <> '_'
               THEN
                  fnd_message.set_name ('CSF',
                                           'CSF_ZIP_NOT_FOUND_ERROR_STATE'
                                          );
                  fnd_message.set_token ('ZIP', p_task_rec.postal_code);
                  fnd_message.set_token ('STATE', p_task_rec.state);
                  x_error := fnd_message.get;
                  x_error_detail := x_error_detail || ' ' || x_error;
               ELSIF  trim(p_task_rec.postal_code) <> '_' AND trim (p_task_rec.country) <> '_'
               THEN
                  fnd_message.set_name ('CSF', 'CSF_ZIP_NOT_FOUND_ERROR');
                  fnd_message.set_token ('ZIP', p_task_rec.postal_code);
                  fnd_message.set_token ('COUNTRY', p_task_rec.country);
                  x_error := fnd_message.get;
                  x_error_detail := x_error_detail || ' ' || x_error;
               END IF;
            END IF;
	    CLOSE process_cursor;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               CLOSE process_cursor;
            WHEN OTHERS
            THEN
               CLOSE process_cursor;

               RAISE fnd_api.g_exc_unexpected_error;
         END;
      END IF;

      -- Added for LF enhancement of Forced accuracy
        DECLARE
        l_exp_accuracy_level VARCHAR2(5) DEFAULT '0';
        BEGIN

            fnd_message.set_name ('CSF', 'CSF_ADDRESS_ACC_FACTOR_ERROR');
            l_exp_accuracy_level := fnd_profile.VALUE('CSF_LOC_ACC_LEVELS');
            l_exp_accuracy_level := NVL(l_exp_accuracy_level,'0');
            IF (l_exp_accuracy_level = '0')
            THEN
              fnd_message.set_token ('ACCURACY','zip code or city level accuracy');
            END IF;
            IF (l_exp_accuracy_level = '1')
            THEN
              fnd_message.set_token ('ACCURACY','street level accuracy');
            END IF;
            IF (l_exp_accuracy_level = '2')
            THEN
              fnd_message.set_token ('ACCURACY','building number level accuracy');
            END IF;
            x_error := fnd_message.get;
            x_error_detail := x_error_detail || ' ' || x_error;

         END;
         -- Enhancement Code ends here

      -- End of API body

      -- Standard check of p_commit
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Standard call to get message count and return the message info if the count is 1
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
      WHEN OTHERS
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data);
   END get_error_detail;

   PROCEDURE log_info (
      p_api_version        IN              NUMBER,
      p_init_msg_list      IN              VARCHAR2,
      p_commit             IN              VARCHAR2,
      p_validation_level   IN              NUMBER,
      p_task_rec           IN              task_rec_type,
      x_return_status      OUT NOCOPY      VARCHAR2,
      x_msg_count          OUT NOCOPY      NUMBER,
      x_msg_data           OUT NOCOPY      VARCHAR2
   )
   IS
      l_api_name      CONSTANT VARCHAR2 (30)                    := 'LOG_INFO';
      l_api_version   CONSTANT NUMBER                           := 1.0;
      l_msg_data               VARCHAR2 (32767);
      l_error                  VARCHAR2 (2000);
      l_error_detail           VARCHAR2 (2000);

      CURSOR c_check_ext_locations (l_task_id csf_ext_locations.task_id%TYPE)
      IS
         SELECT task_id
           FROM csf_ext_locations
          WHERE task_id = l_task_id;

      l_location_id            hz_locations.location_id%TYPE;
      l_task_id                csf_ext_locations.task_id%TYPE;
   BEGIN
      -- Standard check for call compatibility
      IF NOT fnd_api.compatible_api_call (l_api_version,
                                          p_api_version,
                                          l_api_name,
                                          g_pkg_name
                                         )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      -- Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      -- API body
      fnd_message.set_name ('CSF', 'CSF_INVALID_TASK_INFO');
      fnd_message.set_token ('TASK_ID', p_task_rec.task_id);
      fnd_message.set_token ('TASK_NUMBER', p_task_rec.task_number);
      fnd_message.set_token ('CITY', p_task_rec.city);
      fnd_message.set_token ('POSTAL_CODE', p_task_rec.postal_code);
      fnd_message.set_token ('COUNTY', p_task_rec.county);
      fnd_message.set_token ('STATE', p_task_rec.state);
      fnd_message.set_token ('COUNTRY', p_task_rec.country);
      l_msg_data := fnd_message.get;
      put_stream (g_log, l_msg_data);
      put_stream (g_output, l_msg_data);

      IF l_location_id IS NULL
      THEN
         l_location_id := p_task_rec.location_id;
      END IF;

      BEGIN
         OPEN c_check_ext_locations (p_task_rec.task_id);

         FETCH c_check_ext_locations
          INTO l_task_id;

         CLOSE c_check_ext_locations;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            CLOSE c_check_ext_locations;
         WHEN OTHERS
         THEN
            CLOSE c_check_ext_locations;
      END;

      get_error_detail (p_api_version           => 1.0,
                        p_init_msg_list         => fnd_api.g_false,
                        p_commit                => fnd_api.g_false,
                        p_validation_level      => fnd_api.g_valid_level_full,
                        p_task_rec              => p_task_rec,
                        x_error                 => l_error,
                        x_error_detail          => l_error_detail,
                        x_return_status         => x_return_status,
                        x_msg_count             => x_msg_count,
                        x_msg_data              => x_msg_data
                       );

      IF x_return_status <> fnd_api.g_ret_sts_success
      THEN
         fnd_message.set_name ('CSF', 'CSF_GET_ERROR_DETAIL_ERROR');
         fnd_message.set_token ('LOCATION_ID', p_task_rec.location_id);
         fnd_message.set_token ('RETURN_STATUS', x_return_status);
         l_msg_data := fnd_message.get;
         put_stream (g_log, l_msg_data);
         put_stream (g_output, l_msg_data);
      END IF;

      IF l_error IS NULL
      THEN
         fnd_message.set_name ('CSF', 'CSF_ADDRESS_INVALID_INFO');
         l_error := fnd_message.get;
      END IF;

      IF l_error_detail IS NULL
      THEN
         fnd_message.set_name ('CSF', 'CSF_NO_ADDRESS_ENTERED_ERROR');
         l_error_detail := fnd_message.get;
      END IF;

      IF l_task_id IS NULL
      THEN
         csf_locations_pkg.insert_row_ext
                    (p_csf_ext_location_id         => l_location_id,
                     p_last_update_date            => SYSDATE,
                     p_last_updated_by             => NVL (fnd_global.user_id,
                                                           -1
                                                          ),
                     p_creation_date               => SYSDATE,
                     p_created_by                  => NVL (fnd_global.user_id,
                                                           -1
                                                          ),
                     p_last_update_login           => NVL
                                                         (fnd_global.conc_login_id,
                                                          -1
                                                         ),
                     p_request_id                  => NVL
                                                         (fnd_global.conc_request_id,
                                                          -1
                                                         ),
                     p_program_application_id      => NVL
                                                         (fnd_global.prog_appl_id,
                                                          -1
                                                         ),
                     p_program_id                  => NVL
                                                         (fnd_global.conc_program_id,
                                                          -1
                                                         ),
                     p_program_update_date         => SYSDATE,
                     p_task_id                     => p_task_rec.task_id,
                     p_location_id                 => p_task_rec.location_id,
                     p_validated_flag              => p_task_rec.validated_flag,
                     p_override_flag               => p_task_rec.override_flag,
                     p_log_detail_short            => l_error,
                     p_log_detail_long             => l_error_detail
                    );
      ELSE
         csf_locations_pkg.update_row_ext
                    (p_csf_ext_location_id         => p_task_rec.location_id,
                     p_last_update_date            => SYSDATE,
                     p_last_updated_by             => NVL (fnd_global.user_id,
                                                           -1
                                                          ),
                     p_last_update_login           => NVL
                                                         (fnd_global.conc_login_id,
                                                          -1
                                                         ),
                     p_request_id                  => NVL
                                                         (fnd_global.conc_request_id,
                                                          -1
                                                         ),
                     p_program_application_id      => NVL
                                                         (fnd_global.prog_appl_id,
                                                          -1
                                                         ),
                     p_program_id                  => NVL
                                                         (fnd_global.conc_program_id,
                                                          -1
                                                         ),
                     p_program_update_date         => SYSDATE,
                     p_location_id                 => p_task_rec.location_id,
                     p_validated_flag              => p_task_rec.validated_flag,
                     p_override_flag               => p_task_rec.override_flag,
                     p_log_detail_short            => l_error,
                     p_log_detail_long             => l_error_detail
                    );
      END IF;

      -- End of API body

      -- Standard check of p_commit
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Standard call to get message count and return the message info if the count is 1
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
      WHEN OTHERS
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data);
   END log_info;
--
-- Added for bug 7571215

  PROCEDURE get_error_detail (
      p_api_version        IN              NUMBER,
      p_init_msg_list      IN              VARCHAR2,
      p_country_code       IN              VARCHAR2,
      p_country            IN              VARCHAR2,
      p_state              IN              VARCHAR2,
      p_city               IN              VARCHAR2,
      p_postal_code        IN              VARCHAR2,
      x_error_detail       OUT NOCOPY      VARCHAR2
   )
   IS
      l_api_name      CONSTANT VARCHAR2 (30)   := 'GET_ERROR_DETAIL';
      l_api_version   CONSTANT NUMBER          := 1.0;
      l_tmp                    VARCHAR2 (2000);
      l_place                  VARCHAR2 (250);
      l_flag                   VARCHAR2 (1);
      x_error                  VARCHAR2 (100);

      CURSOR l_place_csr (l_place_name VARCHAR2, l_parent_level NUMBER)
      IS
         SELECT NAME
           FROM csf_lf_places p, csf_lf_names n, csf_lf_place_names pn
          WHERE n.name_id = pn.name_id
            AND pn.place_id = p.place_id
            AND NAME = l_place_name
            AND p.place_parent_level = l_parent_level;

      l_uk_city  VARCHAR2(1000);
      l_dataset_profile_value VARCHAR2(1000);
      l_place_country VARCHAR2(1000);
      l_place_state VARCHAR2(1000);
      l_place_city VARCHAR2(1000);
      l_place_zip  VARCHAR2(1000);

      TYPE REF_CURSOR IS REF CURSOR;
      process_cursor REF_CURSOR;
      l_spatial_dataset VARCHAR2(10);
      l_country VARCHAR2(100);
      CURSOR ctry_hr_to_spatial IS
         SELECT SPATIAL_COUNTRY_NAME, spatial_dataset
         FROM CSF_SPATIAL_CTRY_MAPPINGS
         WHERE HR_COUNTRY_NAME = upper(p_country);


   BEGIN
      -- Standard check for call compatibility
      IF NOT fnd_api.compatible_api_call (l_api_version,
                                          p_api_version,
                                          l_api_name,
                                          g_pkg_name
                                         )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

    l_dataset_profile_value  := fnd_profile.value('CSF_SPATIAL_MULTIDATASET_ENABLED');

     open ctry_hr_to_spatial;
     fetch ctry_hr_to_spatial into l_country, l_spatial_dataset;
      close ctry_hr_to_spatial;

  IF (l_country is null) THEN
    l_country := p_country;
    END IF;

    IF (l_dataset_profile_value = 'N' OR l_dataset_profile_value IS NULL ) THEN
       l_dataset_profile_value := '';
    ELSE
       l_dataset_profile_value := l_spatial_dataset;
    END IF;

      l_uk_city :='   SELECT cln.NAME
           FROM csf_lf_names'||l_dataset_profile_value||' cln,
           csf_lf_place_names'||l_dataset_profile_value||' clpn,
           csf_lf_places'||l_dataset_profile_value||' clp
          WHERE cln.name_id = clpn.name_id
            AND clpn.place_id = clp.place_id
            AND clp.place_parent_level NOT IN (-1, 0)
            AND UPPER (cln.NAME) = UPPER ('''||p_city||''')';

       l_place_country :='         SELECT n.NAME
           FROM csf_lf_places'||l_dataset_profile_value||' p,
           csf_lf_place_names'||l_dataset_profile_value||' pn,
           csf_lf_names'||l_dataset_profile_value||' n
          WHERE n.NAME = UPPER ('''||l_country||''')
            AND pn.name_id = n.name_id
            AND p.place_id = pn.place_id
            AND p.place_parent_level = -1';

      l_place_state :=' SELECT n.NAME
           FROM csf_lf_names'||l_dataset_profile_value||' n,
                csf_lf_place_names'||l_dataset_profile_value||' pn,
                (SELECT     place_id
                       FROM csf_lf_places'||l_dataset_profile_value||'
                 CONNECT BY PRIOR place_id = parent_place_id
                 START WITH place_id IN (
                               SELECT pn.place_id
                                 FROM csf_lf_names'||l_dataset_profile_value||' n,
                                 csf_lf_place_names'||l_dataset_profile_value||' pn
                                WHERE n.NAME = UPPER ('''|| l_country||''')
                                  AND pn.name_id = n.name_id)) p
          WHERE pn.place_id = p.place_id
            AND n.name_id = pn.name_id
            AND n.NAME = UPPER ('''||p_state||''')';


      -- Initialize API return status to success
      -- x_return_status := fnd_api.g_ret_sts_success;
      -- API body
     IF p_country_code = 'GB'
      THEN
         BEGIN
            l_tmp := NULL;

            OPEN process_cursor FOR l_uk_city;

            FETCH process_cursor
             INTO l_tmp;

            IF l_tmp IS NULL AND trim(p_city) <> '_'
            THEN
               fnd_message.set_name ('CSF', 'CSF_CITY_NOT_FOUND_ERROR');
               fnd_message.set_token ('CITY', p_city);
               fnd_message.set_token ('COUNTRY', p_country);
               x_error := fnd_message.get;
               x_error_detail := x_error_detail || ' ' || x_error;
            END IF;

            CLOSE process_cursor;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               CLOSE process_cursor;
            WHEN OTHERS
            THEN
               CLOSE process_cursor;

               RAISE fnd_api.g_exc_unexpected_error;
         END;
      ELSE

	 BEGIN
            l_tmp := NULL;

            OPEN process_cursor FOR l_place_country;

            FETCH process_cursor
             INTO l_tmp;

            IF l_tmp IS NULL AND trim(p_country) <> '_'
            THEN
               fnd_message.set_name ('CSF', 'CSF_COUNTRY_NOT_FOUND_ERROR');
               fnd_message.set_token ('COUNTRY', p_country);
               x_error := fnd_message.get;
               x_error_detail := x_error_detail || ' ' || x_error;
            END IF;

            CLOSE process_cursor;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               CLOSE process_cursor;
            WHEN OTHERS
            THEN
               CLOSE process_cursor;

               RAISE fnd_api.g_exc_unexpected_error;
         END;

         BEGIN
            l_tmp := NULL;

            OPEN process_cursor FOR l_place_state;

            FETCH process_cursor
             INTO l_tmp;

            IF l_tmp IS NULL AND trim(p_country) <> '_'  AND trim(p_state) <> '_'
            THEN
               fnd_message.set_name ('CSF', 'CSF_STATE_NOT_FOUND_ERROR');
               fnd_message.set_token ('STATE', p_state);
               fnd_message.set_token ('COUNTRY', p_country);
               x_error := fnd_message.get;
               x_error_detail := x_error_detail || ' ' || x_error;
            END IF;

            CLOSE process_cursor;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               CLOSE process_cursor;
            WHEN OTHERS
            THEN
               CLOSE process_cursor;

               RAISE fnd_api.g_exc_unexpected_error;
         END;

         BEGIN
            l_tmp := NULL;

            l_flag := NULL;

            IF p_state IS NOT NULL AND trim(p_state) <> '_'
            THEN
               l_place := p_state;
               l_flag := 'S';
            ELSE
               l_place := l_country;
               l_flag := NULL;
            END IF;

            l_place_city := '        SELECT n.NAME
           FROM csf_lf_names'||l_dataset_profile_value||'  n,
                csf_lf_place_names'||l_dataset_profile_value||'  pn,
                (SELECT     place_id
                       FROM csf_lf_places'||l_dataset_profile_value||'
                      WHERE place_parent_level IN (1, 8)
                 CONNECT BY PRIOR place_id = parent_place_id
                 START WITH place_id IN (
                               SELECT pn.place_id
                                 FROM csf_lf_names'||l_dataset_profile_value||'  n,
                                 csf_lf_place_names'||l_dataset_profile_value||'  pn
                                WHERE n.NAME = UPPER ('''||l_place||''')
                                  AND pn.name_id = n.name_id)) p
          WHERE pn.place_id = p.place_id
            AND n.name_id = pn.name_id
            AND n.NAME = UPPER ('''||p_city||''')';

	    OPEN process_cursor FOR l_place_city;

            FETCH process_cursor
            INTO l_tmp;

            IF l_tmp IS NULL
            THEN
               IF l_flag = 'S' AND trim(p_state) <> '_' AND trim(p_city) <> '_'
               THEN
                  fnd_message.set_name ('CSF',
                                        'CSF_CITY_NOT_FOUND_ERROR_STATE');
                  fnd_message.set_token ('CITY', p_city);
                  fnd_message.set_token ('STATE', p_state);
               ELSIF  trim(p_country) <> '_' AND trim(p_city) <> '_'
                THEN
                    fnd_message.set_name ('CSF', 'CSF_CITY_NOT_FOUND_ERROR');
                    fnd_message.set_token ('CITY', p_city);
                    fnd_message.set_token ('COUNTRY', p_country);
               END IF;

               x_error := fnd_message.get;
               x_error_detail := x_error_detail || ' ' || x_error;
            END IF;

            CLOSE process_cursor;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               CLOSE process_cursor;
            WHEN OTHERS
            THEN
               CLOSE process_cursor;

               RAISE fnd_api.g_exc_unexpected_error;
         END;

         BEGIN
            l_tmp := NULL;

            IF p_city IS NOT NULL AND trim(p_city) <> '_'
            THEN
               l_place := p_city;
               l_flag := 'C';
            ELSIF p_state IS NOT NULL AND trim(p_state) <> '_'
            THEN
               l_place := p_state;
               l_flag := 'S';
            ELSE
               l_place := l_country;
               l_flag := NULL;
            END IF;

            l_place_zip := 'SELECT pc.postal_code
       FROM csf_lf_postcodes'||l_dataset_profile_value||' pc,
                csf_lf_place_postcs'||l_dataset_profile_value||' ppc,
                csf_lf_place_names'||l_dataset_profile_value||' pn,
                csf_lf_names'||l_dataset_profile_value||' n
          WHERE pc.postal_code_id = ppc.postal_code_id
            AND ppc.place_id = pn.place_id
            AND pn.name_id = n.name_id
	    AND pc.postal_code = '''||p_postal_code||'''
            AND EXISTS (
                   SELECT     1
                         FROM csf_lf_places'||l_dataset_profile_value||'
                        WHERE place_id IN (
                                 SELECT clpn.place_id
                                   FROM csf_lf_names'||l_dataset_profile_value||' cln,
                                        csf_lf_place_names'||l_dataset_profile_value||' clpn
                                  WHERE cln.NAME = UPPER('''||l_place||''')
                                    AND cln.name_id = clpn.name_id)
                   CONNECT BY place_id = PRIOR parent_place_id
                   START WITH place_id = pn.place_id)';

            OPEN process_cursor FOR l_place_zip;

	    FETCH process_cursor
            INTO l_tmp;

            IF l_tmp IS NULL
            THEN
                IF l_flag = 'C' AND trim(p_postal_code) <> '_' AND
                trim (p_city) <> '_'
                THEN
                  fnd_message.set_name ('CSF',
                                           'CSF_ZIP_NOT_FOUND_ERROR_CITY'
                                          );
                  fnd_message.set_token ('ZIP', p_postal_code);
                  fnd_message.set_token ('CITY', p_city);
                  x_error := fnd_message.get;
                  x_error_detail := x_error_detail || ' ' || x_error;
               ELSIF l_flag = 'S'  AND trim(p_postal_code) <> '_' AND
                trim (p_state) <> '_'
               THEN
                  fnd_message.set_name ('CSF',
                                           'CSF_ZIP_NOT_FOUND_ERROR_STATE'
                                          );
                  fnd_message.set_token ('ZIP', p_postal_code);
                  fnd_message.set_token ('STATE', p_state);
                  x_error := fnd_message.get;
                  x_error_detail := x_error_detail || ' ' || x_error;
               ELSIF  trim(p_postal_code) <> '_' AND
                trim (p_country) <> '_'
               THEN
                  fnd_message.set_name ('CSF', 'CSF_ZIP_NOT_FOUND_ERROR');
                  fnd_message.set_token ('ZIP', p_postal_code);
                  fnd_message.set_token ('COUNTRY', p_country);
                  x_error := fnd_message.get;
                  x_error_detail := x_error_detail || ' ' || x_error;
               END IF;
            END IF;
	    CLOSE process_cursor;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               CLOSE process_cursor;
            WHEN OTHERS
            THEN
               CLOSE process_cursor;

               RAISE fnd_api.g_exc_unexpected_error;
         END;
      END IF;

      -- Added for LF enhancement of Forced accuracy
        DECLARE
        l_exp_accuracy_level VARCHAR2(5) DEFAULT '0';
        BEGIN

            fnd_message.set_name ('CSF', 'CSF_ADDRESS_ACC_FACTOR_ERROR');
            l_exp_accuracy_level := fnd_profile.VALUE('CSF_LOC_ACC_LEVELS');
            l_exp_accuracy_level := NVL(l_exp_accuracy_level,'0');
            IF (l_exp_accuracy_level = '0')
            THEN
              fnd_message.set_token ('ACCURACY','zip code or city level accuracy');
            END IF;
            IF (l_exp_accuracy_level = '1')
            THEN
              fnd_message.set_token ('ACCURACY','street level accuracy');
            END IF;
            IF (l_exp_accuracy_level = '2')
            THEN
              fnd_message.set_token ('ACCURACY','building number level accuracy');
            END IF;
            x_error := fnd_message.get;
            x_error_detail := x_error_detail || ' ' || x_error;

         END;
         -- Enhancement Code ends here

      -- End of API body
      EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         NULL;
      WHEN OTHERS
      THEN
         NULL;
  END get_error_detail;

-- End of addition
   PROCEDURE validate_task_data (
      p_api_version        IN              NUMBER,
      p_init_msg_list      IN              VARCHAR2,
      p_commit             IN              VARCHAR2,
      p_validation_level   IN              NUMBER,
      p_invalid_task_id    IN              jtf_tasks_b.task_id%TYPE,
      p_location_id        IN              hz_locations.location_id%TYPE,
      p_address1           IN              hz_locations.address1%TYPE,
      p_address2           IN              hz_locations.address2%TYPE,
      p_address3           IN              hz_locations.address3%TYPE,
      p_address4           IN              hz_locations.address4%TYPE,
      p_city               IN              hz_locations.city%TYPE,
      p_postal_code        IN              hz_locations.postal_code%TYPE,
      p_state              IN              hz_locations.state%TYPE,
      p_province           IN              hz_locations.province%TYPE,
      p_county             IN              hz_locations.county%TYPE,
      p_country            IN              hz_locations.country%TYPE,
      p_timezone_id        IN              hz_locations.timezone_id%TYPE,
      x_result             OUT NOCOPY      VARCHAR2,
      x_return_status      OUT NOCOPY      VARCHAR2,
      x_msg_count          OUT NOCOPY      NUMBER,
      x_msg_data           OUT NOCOPY      VARCHAR2
   )
   IS
      l_api_name      CONSTANT VARCHAR2 (30)            := 'VALIDATE_TASK_DATA';
      l_api_version   CONSTANT NUMBER                       := 1.0;
      l_locus                  hz_locations.geometry%TYPE;
      l_country_code           hz_locations.country%TYPE;
      l_time_zone_check        BOOLEAN;
      l_timezone_id            VARCHAR2 (80);

      CURSOR c_timezone_check (p_timezone_id NUMBER)
      IS
         SELECT NAME
           FROM hz_timezones_vl
          WHERE timezone_id = p_timezone_id;

      CURSOR c_country_code (p_country hz_locations.country%TYPE)
      IS
         SELECT ftt.territory_code country_code
           FROM fnd_territories_tl ftt
          WHERE UPPER (ftt.territory_short_name) = UPPER (p_country)
            AND ftt.language = 'US';

   BEGIN
      -- Standard check for call compatibility
      IF NOT fnd_api.compatible_api_call (l_api_version,
                                          p_api_version,
                                          l_api_name,
                                          g_pkg_name
                                         )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      -- Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      x_result := g_valid_true;

      -- API body
      BEGIN
         OPEN c_country_code (p_country);

         FETCH c_country_code
          INTO l_country_code;

         CLOSE c_country_code;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            CLOSE c_country_code;
         WHEN OTHERS
         THEN
            CLOSE c_country_code;
      END;

    /*  OPEN c_timezone_check (p_timezone_id);

      FETCH c_timezone_check
       INTO l_timezone_id;

      IF l_timezone_id IS NULL
      THEN
         fnd_message.set_name ('CSF', 'CSF_TIME_ZONE_ERROR');
         fnd_msg_pub.add_detail ();
         RAISE fnd_api.g_exc_error;
      END IF;

      CLOSE c_timezone_check; */

      csf_resource_address_pvt.resolve_address
                                        (p_api_version        => 1.0,
                                         p_init_msg_list      => fnd_api.g_false,
                                         p_country            => NVL (p_country,
                                                                      '_'
                                                                     ),
                                         p_state              => NVL (p_state,
                                                                      '_'
                                                                     ),
                                         p_city               => NVL (p_city,
                                                                      '_'
                                                                     ),
                                         p_postalcode         => NVL
                                                                    (p_postal_code,
                                                                     '_'
                                                                    ),
                                         p_address1           => NVL
                                                                    (p_address1,
                                                                     '_'
                                                                    ),
                                         p_address2           => NVL
                                                                    (p_address2,
                                                                     '_'
                                                                    ),
                                         p_address3           => NVL
                                                                    (p_address3,
                                                                     '_'
                                                                    ),
                                         p_address4           => NVL
                                                                    (p_address4,
                                                                     '_'
                                                                    ),
                                         p_building_num       => '_',
                                         p_alternate          => '_',
                                         p_location_id        => NVL
                                                                    (p_location_id,
                                                                     -1
                                                                    ),
                                         p_country_code       => NVL
                                                                    (l_country_code,
                                                                     '_'
                                                                    ),
                                         p_province          =>  NVL
                                                                    (p_province,
                                                                     '_'
                                                                   ),
                                         x_return_status      => x_return_status,
                                         x_msg_count          => x_msg_count,
                                         x_msg_data           => x_msg_data,
                                         x_geometry           => l_locus,
                                         p_update_address     => 'T'
                                        );


      IF x_return_status = fnd_api.g_ret_sts_success
      THEN
         x_result := g_valid_true;
      ELSE
         x_result := g_valid_false;
        /* fnd_message.set_name ('CSF', 'CSF_RESOLVE_ADDRESS_ERROR');
         fnd_message.set_token ('LOCATION_ID', p_location_id);
         fnd_message.set_token ('RETURN_STATUS', x_return_status);
         fnd_msg_pub.add_detail ();*/
         -- Added for Bug 7571215
           get_error_detail (
              p_api_version        => 1.0,
              p_init_msg_list      => fnd_api.g_false,
              p_country_code   => NVL(l_country_code,'_'),
              p_country        => NVL (p_country,'_'),
              p_state          => NVL (p_state,'_'),
              p_city           => NVL (p_city,'_'),
              p_postal_code    => NVL (p_postal_code,'_'),
              x_error_detail   => x_msg_data
           );
           RAISE fnd_api.g_exc_error;
      END IF;

      -- End of API body

      -- Standard check of p_commit
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Standard call to get message count and return the message info if the count is 1
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         x_return_status := fnd_api.g_ret_sts_error;
         x_result := fnd_api.g_false;
         IF x_msg_data IS NULL
         THEN
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
          END IF;
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_result := fnd_api.g_false;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
      WHEN OTHERS
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_result := fnd_api.g_false;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data);
   END validate_task_data;

   FUNCTION is_task_address_valid (p_task_id IN jtf_tasks_b.task_id%TYPE)
      RETURN BOOLEAN
   IS
      CURSOR l_check_address_csr (l_task_id jtf_tasks_b.task_id%TYPE)
      IS
         SELECT task_id
           FROM csf_validate_tasks_v
          WHERE task_id = l_task_id AND validated_flag = 'N';

      l_task_id   jtf_tasks_b.task_id%TYPE;
   BEGIN
      BEGIN
         OPEN l_check_address_csr (p_task_id);

         FETCH l_check_address_csr
          INTO l_task_id;

         CLOSE l_check_address_csr;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            CLOSE l_check_address_csr;
         WHEN OTHERS
         THEN
            CLOSE l_check_address_csr;
      END;

      RETURN (l_task_id IS NULL);
   END is_task_address_valid;

   PROCEDURE update_task_address (
      p_api_version        IN              NUMBER,
      p_init_msg_list      IN              VARCHAR2,
      p_commit             IN              VARCHAR2,
      p_validation_level   IN              NUMBER,
      p_location_id        IN              hz_locations.location_id%TYPE,
      p_address1           IN              hz_locations.address1%TYPE,
      p_address2           IN              hz_locations.address2%TYPE,
      p_address3           IN              hz_locations.address3%TYPE,
      p_address4           IN              hz_locations.address4%TYPE,
      p_city               IN              hz_locations.city%TYPE,
      p_postal_code        IN              hz_locations.postal_code%TYPE,
      p_state              IN              hz_locations.state%TYPE,
      p_province           IN              hz_locations.province%TYPE,
      p_county             IN              hz_locations.county%TYPE,
      p_country            IN              hz_locations.country%TYPE,
      p_validated_flag     IN              csf_ext_locations.validated_flag%TYPE,
      p_override_flag      IN              csf_ext_locations.override_flag%TYPE,
      p_timezone_id        IN              hz_locations.timezone_id%TYPE,
      x_return_status      OUT NOCOPY      VARCHAR2,
      x_msg_count          OUT NOCOPY      NUMBER,
      x_msg_data           OUT NOCOPY      VARCHAR2
   )
   IS
      l_api_name      CONSTANT VARCHAR2 (30)           := 'UPDATE_TASK_ADDRESS';
      l_api_version   CONSTANT NUMBER                                    := 1.0;
      l_short_msg              csf_ext_locations.log_detail_short%TYPE;
      l_long_msg               csf_ext_locations.log_detail_long%TYPE;
      l_country_code           hz_locations.country%TYPE;
      l_country                hz_locations.country%TYPE;
      CURSOR c_country_code (p_country hz_locations.country%TYPE)
      IS
         SELECT ftt.territory_code country_code
           FROM fnd_territories_tl ftt
          WHERE UPPER (ftt.territory_short_name) = UPPER (p_country)
            AND ftt.language = 'US';
   BEGIN
      -- Standard check for call compatibility
      IF NOT fnd_api.compatible_api_call (l_api_version,
                                          p_api_version,
                                          l_api_name,
                                          g_pkg_name
                                         )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      -- Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;

      -- API body
	  IF upper(p_country) = 'US VIRGIN ISLANDS'
      THEN
          l_country := 'VIRGIN ISLANDS, U.S.';
      ElSIF upper(p_country) = 'MACEDONIA'
      THEN
          l_country := 'MACEDONIA, THE FORMER YUGOSLAV REPUBLIC OF';
      ELSIF upper(p_country) = 'SLOVAK REPUBLIC'
      THEN
          l_country := 'SLOVAKIA';
      ELSIF upper(p_country) = 'RUSSIA'
      THEN
          l_country := 'RUSSIAN FEDERATION';
      ELSIF upper(p_country) = 'VATICAN CITY'
      THEN
          l_country := 'HOLY SEE (VATICAN CITY STATE)';
      ELSIF upper(p_country) = 'LUXEMBURG'
      THEN
          l_country := 'LUXEMBOURG';
      ELSE
          l_country := upper(p_country);
      END IF;

      IF p_location_id IS NOT NULL
      THEN
         BEGIN
            OPEN c_country_code (l_country);

            FETCH c_country_code
             INTO l_country_code;

            CLOSE c_country_code;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               CLOSE c_country_code;
            WHEN OTHERS
            THEN
               CLOSE c_country_code;
         END;

         csf_locations_pkg.update_row_hz
                     (p_last_update_date            => SYSDATE,
                      p_last_updated_by             => NVL (fnd_global.user_id,
                                                            -1
                                                           ),
                      p_last_update_login           => NVL
                                                          (fnd_global.conc_login_id,
                                                           -1
                                                          ),
                      p_request_id                  => NVL
                                                          (fnd_global.conc_request_id,
                                                           -1
                                                          ),
                      p_program_application_id      => NVL
                                                          (fnd_global.prog_appl_id,
                                                           -1
                                                          ),
                      p_program_id                  => NVL
                                                          (fnd_global.conc_program_id,
                                                           -1
                                                          ),
                      p_program_update_date         => SYSDATE,
                      p_address1                    => p_address1,
                      p_address2                    => p_address2,
                      p_address3                    => p_address3,
                      p_address4                    => p_address4,
                      p_city                        => p_city,
                      p_postal_code                 => p_postal_code,
                      p_county                      => p_county,
                      p_state                       => p_state,
                      p_province                    => p_province,
                      p_country                     => l_country_code,
                      p_validated_flag              => p_validated_flag,
                      p_location_id                 => p_location_id,
                      p_timezone_id                 => p_timezone_id
                     );

         IF p_validated_flag = g_valid_true
         THEN
            fnd_message.set_name ('CSF', 'CSF_ADDRESS_VALIDATED_INFO');
            l_short_msg := fnd_message.get;
            fnd_message.set_name ('CSF', 'CSF_ADDRESS_VALIDATED_INFO');
            l_long_msg := fnd_message.get;
         END IF;

         IF p_override_flag = g_valid_true
         THEN
            fnd_message.set_name ('CSF', 'CSF_ADDRESS_OVERRIDDEN_INFO');
            l_short_msg := fnd_message.get;
            fnd_message.set_name ('CSF', 'CSF_ADDRESS_OVERRIDDEN_INFO');
            l_long_msg := fnd_message.get;
         END IF;

         csf_locations_pkg.update_row_ext
                     (p_csf_ext_location_id         => p_location_id,
                      p_last_update_date            => SYSDATE,
                      p_last_updated_by             => NVL (fnd_global.user_id,
                                                            -1
                                                           ),
                      p_last_update_login           => NVL
                                                          (fnd_global.conc_login_id,
                                                           -1
                                                          ),
                      p_request_id                  => NVL
                                                          (fnd_global.conc_request_id,
                                                           -1
                                                          ),
                      p_program_application_id      => NVL
                                                          (fnd_global.prog_appl_id,
                                                           -1
                                                          ),
                      p_program_id                  => NVL
                                                          (fnd_global.conc_program_id,
                                                           -1
                                                          ),
                      p_program_update_date         => SYSDATE,
                      p_location_id                 => p_location_id,
                      p_validated_flag              => p_validated_flag,
                      p_override_flag               => p_override_flag,
                      p_log_detail_short            => l_short_msg,
                      p_log_detail_long             => l_long_msg
                     );
      END IF;

      -- End of API body

      -- Standard check of p_commit
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Standard call to get message count and return the message info if the count is 1
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
      WHEN OTHERS
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data);
   END update_task_address;

   PROCEDURE dbgl (p_msg_data VARCHAR2)
   IS
      i       PLS_INTEGER;
      l_msg   VARCHAR2 (300);
   BEGIN
      i := 1;

      LOOP
         l_msg := SUBSTR (p_msg_data, i, 255);
         EXIT WHEN l_msg IS NULL;

         EXECUTE IMMEDIATE g_debug_p
                     USING l_msg;

         i := i + 255;
      END LOOP;
   END dbgl;

   PROCEDURE put_stream (p_handle IN NUMBER, p_msg_data IN VARCHAR2)
   IS
   BEGIN
      IF p_handle = 0
      THEN
         dbgl (p_msg_data);
      ELSIF p_handle = -1
      THEN
         IF g_debug
         THEN
            dbgl (p_msg_data);
         END IF;
      ELSE
         fnd_file.put_line (p_handle, p_msg_data);
      END IF;
   END put_stream;

   PROCEDURE show_messages (p_msg_data VARCHAR2)
   IS
      l_msg_count   NUMBER;
      l_msg_data    VARCHAR2 (2000);
   BEGIN
      IF p_msg_data IS NOT NULL
      THEN
         put_stream (g_output, p_msg_data);
         put_stream (g_log, p_msg_data);
      END IF;

      fnd_msg_pub.count_and_get (fnd_api.g_false, l_msg_count, l_msg_data);

      IF l_msg_count = 1
      THEN
         put_stream (g_output, l_msg_data);
         put_stream (g_log, l_msg_data);
      END IF;

      put_stream (g_output,
                  fnd_msg_pub.get (fnd_msg_pub.g_last, fnd_api.g_false)
                 );
      fnd_msg_pub.RESET;

      LOOP
         l_msg_data := fnd_msg_pub.get_detail (p_encoded => fnd_api.g_false);
         EXIT WHEN l_msg_data IS NULL;
         put_stream (g_log, l_msg_data);
      END LOOP;
   END show_messages;

   PROCEDURE success_log_info (
      p_api_version        IN              NUMBER,
      p_init_msg_list      IN              VARCHAR2,
      p_commit             IN              VARCHAR2,
      p_validation_level   IN              NUMBER,
      p_task_rec           IN              task_rec_type,
      x_return_status      OUT NOCOPY      VARCHAR2,
      x_msg_count          OUT NOCOPY      NUMBER,
      x_msg_data           OUT NOCOPY      VARCHAR2
   )
   IS
      l_api_name      CONSTANT VARCHAR2 (30)                    := 'SUCCESS_LOG_INFO';
      l_api_version   CONSTANT NUMBER                           := 1.0;
      l_msg_data               VARCHAR2 (32767);
      l_error                  VARCHAR2 (2000);
      l_error_detail           VARCHAR2 (2000);

      CURSOR c_check_ext_locations (l_location_id csf_ext_locations.location_id%TYPE)
      IS
         SELECT task_id
           FROM csf_ext_locations
          WHERE location_id = l_location_id
	    AND validated_flag = 'N'
	    AND override_flag = 'N';

      l_location_id            csf_ext_locations.location_id%TYPE;
      l_task_id                csf_ext_locations.task_id%TYPE;
   BEGIN
      -- Standard check for call compatibility
      IF NOT fnd_api.compatible_api_call (l_api_version,
                                          p_api_version,
                                          l_api_name,
                                          g_pkg_name
                                         )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      -- Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      -- API body

      BEGIN
         OPEN c_check_ext_locations (p_task_rec.location_id);

         FETCH c_check_ext_locations
          INTO l_task_id;

         CLOSE c_check_ext_locations;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            CLOSE c_check_ext_locations;
         WHEN OTHERS
         THEN
            CLOSE c_check_ext_locations;
      END;

      IF l_task_id IS NOT NULL
      THEN
         csf_locations_pkg.update_row_ext
                    (p_csf_ext_location_id         => p_task_rec.location_id,
                     p_last_update_date            => SYSDATE,
                     p_last_updated_by             => NVL (fnd_global.user_id,
                                                           -1
                                                          ),
                     p_last_update_login           => NVL
                                                         (fnd_global.conc_login_id,
                                                          -1
                                                         ),
                     p_request_id                  => NVL
                                                         (fnd_global.conc_request_id,
                                                          -1
                                                         ),
                     p_program_application_id      => NVL
                                                         (fnd_global.prog_appl_id,
                                                          -1
                                                         ),
                     p_program_id                  => NVL
                                                         (fnd_global.conc_program_id,
                                                          -1
                                                         ),
                     p_program_update_date         => SYSDATE,
                     p_location_id                 => p_task_rec.location_id,
                     p_validated_flag              => p_task_rec.validated_flag,
                     p_override_flag               => p_task_rec.override_flag,
                     p_log_detail_short            => NULL,
                     p_log_detail_long             => NULL
                    );
      END IF;

      -- End of API body

      -- Standard check of p_commit
      IF fnd_api.to_boolean (p_commit)
      THEN
         COMMIT WORK;
      END IF;

      -- Standard call to get message count and return the message info if the count is 1
      fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );
      WHEN OTHERS
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data);
   END success_log_info;
-- This procedure used by Change Invalid address to get the counrty code
-- and place id
   procedure get_country_details(
      p_country      IN             VARCHAR2,
      place_id       OUT NOCOPY     VARCHAR2,
      country_code   OUT NOCOPY     VARCHAR2)
   is
      TYPE country_refcur IS REF CURSOR;
      ref_cur        country_refcur;
      sql_stmt_str  VARCHAR2(1000);
       l_data_set_name        VARCHAR2(40);
   BEGIN

      l_data_set_name  := fnd_profile.value('CSF_SPATIAL_MULTIDATASET_ENABLED');
      IF (l_data_set_name = 'N' OR l_data_set_name IS NULL ) THEN
       l_data_set_name := '';
      ELSE
        BEGIN
          l_data_set_name := '';
          sql_stmt_str := 'select spatial_dataset from csf_spatial_ctry_mappings
                         WHERE spatial_country_name = ''' || upper(p_country)|| '''';
          OPEN ref_cur FOR sql_stmt_str;
          FETCH ref_cur INTO l_data_set_name;
          CLOSE ref_cur;
        EXCEPTION
         WHEN NO_DATA_FOUND THEN
           l_data_set_name := '';
        END;
      END IF;

      sql_stmt_str := 'SELECT PLACE_ID, COUNTRY_CODE_A3 FROM csf_sdm_ctry_profiles'||l_data_set_name||'
                      WHERE country_name = ''' || upper(p_country)|| '''';
      OPEN ref_cur FOR sql_stmt_str;
      FETCH ref_cur INTO place_id,country_code;
      CLOSE ref_cur;
    END;
-- This procedure used by Change Invalid address to get the counrty code for United Kingdom
   procedure get_country_details_GBR(
      p_city      IN              VARCHAR2,
      p_country   IN              VARCHAR2,
      place_id    OUT NOCOPY      VARCHAR2)
   is
      TYPE country_refcur IS REF CURSOR;
      c_countryfromcity        country_refcur;
      ref_cur     country_refcur;
      sql_stmt_str  VARCHAR2(1000);
       l_data_set_name        VARCHAR2(40);
   BEGIN

      l_data_set_name  := fnd_profile.value('CSF_SPATIAL_MULTIDATASET_ENABLED');
      IF (l_data_set_name = 'N' OR l_data_set_name IS NULL ) THEN
       l_data_set_name := '';
      ELSE
        BEGIN
          l_data_set_name := '';
          sql_stmt_str := 'select spatial_dataset from csf_spatial_ctry_mappings
                         WHERE spatial_country_name = ''' || upper(p_country)|| '''';
          OPEN ref_cur FOR sql_stmt_str;
          FETCH ref_cur INTO l_data_set_name;
          CLOSE ref_cur;
        EXCEPTION
         WHEN NO_DATA_FOUND THEN
           l_data_set_name := '';
        END;
      END IF;

      sql_stmt_str := 'SELECT DISTINCT place_id
			                   FROM csf_lf_places'||l_data_set_name||
                       ' WHERE place_parent_level = -1 START WITH place_id IN
							              (SELECT pn.place_id
                               FROM csf_lf_names'||l_data_set_name|| ' n,
                                    csf_lf_place_names'||l_data_set_name||' pn
                              WHERE n.name_id = pn.name_id
                                AND n.name = ''' || upper(p_city)|| ''' )
                      CONNECT BY PRIOR parent_place_id = place_id';
      OPEN c_countryfromcity FOR sql_stmt_str;
      FETCH c_countryfromcity INTO place_id;
      CLOSE c_countryfromcity;
    END;

begin
  init_package;
end csf_task_address_pvt;


/
