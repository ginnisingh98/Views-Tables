--------------------------------------------------------
--  DDL for Package Body MSD_DEM_UPDATE_LEVEL_CODES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_DEM_UPDATE_LEVEL_CODES" AS
/* $Header: msddemupdlvb.pls 120.0.12010000.6 2009/04/15 11:36:00 sjagathe ship $ */


procedure update_code(errbuf              OUT NOCOPY VARCHAR2,
                      retcode             OUT NOCOPY VARCHAR2,
                      p_instance_id        IN  NUMBER,
                      p_level              IN VARCHAR2,
                      p_dest_table_name		 IN VARCHAR2,
                      p_dest_column_name   IN VARCHAR2,
                      p_src_coulmn_name    IN VARCHAR2)

as

l_stmt varchar2(4000);

begin

		msd_dem_common_utilities.log_message('Updating Memeber Codes in Sales Data for ' || p_level );
		msd_dem_common_utilities.log_debug('Updating Memeber Codes in Sales Data' || p_level );

		l_stmt := null;

		dbms_output.put_line(p_dest_table_name || p_dest_column_name || p_src_coulmn_name || p_instance_id);

		if p_level = 'SITE' then

			msd_dem_query_utilities.get_query(retcode, l_stmt, 'MSD_DEM_LEVEL_UPDATE', p_instance_id);

			l_stmt := replace(l_stmt, 'DEST_TABLE', p_dest_table_name);
			l_stmt := replace(l_stmt, 'DEST_COLUMN', p_dest_column_name);
			l_stmt := replace(l_stmt, 'SRC_COLUMN', p_src_coulmn_name);

		end if;

		msd_dem_common_utilities.log_debug('Executed Statement: ');
		msd_dem_common_utilities.log_debug(l_stmt);

		msd_dem_common_utilities.log_debug('Start Time: ' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS') );
		execute immediate l_stmt using p_instance_id;
		msd_dem_common_utilities.log_debug('End Time: ' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS') );

		commit;

		retcode := 0;

		exception
			when others then
				errbuf  := substr(SQLERRM,1,150);
				msd_dem_common_utilities.log_message(errbuf);
				msd_dem_common_utilities.log_debug(errbuf);
				retcode := -1;

end;


   /*
    * This procedure converts the level code format from descriptive to integer format based upon the
    * given parameters.
    * If p_convert_type = 1, then change from new to old (descriptive)
    * If p_convert_type = 2, then change from old to new
    */
   PROCEDURE CONVERT_SITE_CODE (
   					errbuf              	OUT NOCOPY 	VARCHAR2,
                    retcode             	OUT NOCOPY 	VARCHAR2,
                    p_sr_instance_id        IN  		NUMBER,
                    p_level              	IN 			VARCHAR2,
                    p_dest_table_name		IN 			VARCHAR2,
                    p_dest_column_name   	IN 			VARCHAR2,
                    p_convert_type    		IN 			NUMBER)
   IS

      x_sql				VARCHAR2(4000)	:= NULL;
      x_num_rows		NUMBER			:= 0;
      x_instance_type	NUMBER			:= NULL;

   BEGIN

      msd_dem_common_utilities.log_debug('Entering msd_dem_update_level_codes.convert_site_code' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS'));

      msd_dem_common_utilities.log_message ('Logging Parameters received - ');
      msd_dem_common_utilities.log_message ('Instance - ' || to_char(p_sr_instance_id));
      msd_dem_common_utilities.log_message ('Level - ' || p_level);
      msd_dem_common_utilities.log_message ('Table Name - ' || p_dest_table_name);
      msd_dem_common_utilities.log_message ('Column Name - ' || p_dest_column_name);
      msd_dem_common_utilities.log_message ('p_convert_type (1=new to old, 2 - old to new) - ' || to_char(p_convert_type));

      EXECUTE IMMEDIATE 'SELECT instance_type FROM msc_apps_instances WHERE instance_id = ' || to_char(p_sr_instance_id)
         INTO x_instance_type;

      IF (p_level = 'SITE')
      THEN

         msd_dem_common_utilities.log_debug ('Entering SITE level');

         IF (p_convert_type = 1)
         THEN

            msd_dem_common_utilities.log_debug ('Convert from new to old - Building update query ');

            x_sql := 'UPDATE ' || p_dest_table_name || ' t '
                     || ' SET t.' || p_dest_column_name || ' = ('
                     ||                                        ' SELECT substrb(mtp_site.partner_name,   1,   50) '
                     ||                                        '        || '':'' || mtil.sr_cust_account_number '
                     ||                                        '        || '':'' || mtps_site.location '
                     ||                                        '        || '':'' || mtps_site.operating_unit_name '
                     ||                                        '        || decode( mtp_site.customer_type, ''I'', decode(mtp_app_org.partner_name, NULL, NULL, '':'' || mtp_app_org.partner_name), NULL) '
                     ||                                        ' FROM msc_tp_site_id_lid mtsil, '
                     ||                                        '      msc_tp_id_lid mtil, '
                     ||                                        '      msc_trading_partner_sites mtps_site, '
                     ||                                        '      msc_trading_partners mtp_site, '
                     ||                                        '      msc_location_associations mla, '
                     ||                                        '      msc_trading_partners mtp_app_org '
                     ||                                        ' WHERE mtsil.sr_instance_id = ' || to_char(p_sr_instance_id)
                     ||                                        '    AND mtsil.sr_tp_site_id = to_number(substr(t.' || p_dest_column_name || ', instr(t.' || p_dest_column_name || ', ''::'') + 2)) '
                     ||                                        '    AND mtsil.partner_type = 2 '
                     ||                                        '    AND mtsil.tp_site_id = mtps_site.partner_site_id '
                     ||                                        '    AND mtsil.sr_instance_id = mtil.sr_instance_id '
                     ||                                        '    AND mtsil.sr_cust_acct_id = mtil.sr_tp_id '
                     ||                                        '    AND mtil.partner_type = 2 '
                     ||                                        '    AND mtps_site.partner_id = mtp_site.partner_id '
                     ||                                        '    AND mtps_site.partner_type = 2 '
                     ||                                        '    AND mtp_site.partner_type = 2 '
                     ||                                        '    AND mla.sr_instance_id(+) = mtsil.sr_instance_id '
                     ||                                        '    AND mla.partner_site_id(+) = mtsil.tp_site_id '
                     ||                                        '    AND mtp_app_org.sr_tp_id(+) = mla.organization_id '
                     ||                                        '    AND mtp_app_org.sr_instance_id(+) = mla.sr_instance_id '
                     ||                                        '    AND mtp_app_org.partner_type(+) = 3 )'
                     || ' WHERE t.' || p_dest_column_name || ' <> ''' || msd_dem_sr_util.get_null_code || ''''
                     || '    AND t.' || p_dest_column_name || ' LIKE ''' || to_char(p_sr_instance_id) || '::%''';

            msd_dem_common_utilities.log_debug ('The query is - ');
            msd_dem_common_utilities.log_debug (x_sql);

            msd_dem_common_utilities.log_debug('Start Time: ' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS') );
		    EXECUTE IMMEDIATE x_sql;
		    x_num_rows := SQL%ROWCOUNT;
            msd_dem_common_utilities.log_message ('Number of rows updated - ' || to_char(x_num_rows));
            msd_dem_common_utilities.log_debug ('Number of rows updated - ' || to_char(x_num_rows));
		    msd_dem_common_utilities.log_debug('End Time: ' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS') );

		    COMMIT;

		 ELSIF (p_convert_type = 2)
		 THEN

		    msd_dem_common_utilities.log_debug ('Convert from old to new - Building update query ');

		    x_sql := 'UPDATE ' || p_dest_table_name || ' t '
                     || ' SET t.' || p_dest_column_name || ' = nvl(('
                     ||                                        ' SELECT ''' || to_char(p_sr_instance_id) || ''' || ''::'' || mtsil.sr_tp_site_id '
                     ||                                        ' FROM msc_trading_partners mtp, '
                     ||                                        '      msc_tp_id_lid mtil, '
                     ||                                        '      msc_trading_partner_sites mtps, '
                     ||                                        '      msc_tp_site_id_lid mtsil '
                     ||                                        ' WHERE  mtp.partner_type = 2 '
                     ||                                        '    AND replace(substrb(mtp.partner_name, 1, 50), '''''''', '''') = substr(t.' || p_dest_column_name || ',1,instr(t.' || p_dest_column_name ||','':'') - 1 ) '
                     ||                                        '    AND mtil.partner_type = mtp.partner_type '
                     ||                                        '    AND mtil.sr_instance_id = ' || to_char(p_sr_instance_id)
                     ||                                        '    AND mtil.tp_id = mtp.partner_id '
                     ||                                        '    AND nvl(mtil.sr_cust_account_number, ''###'') = nvl(substr(t.' || p_dest_column_name || ', instr(t.' || p_dest_column_name || ', '':'') +1, instr(t.'
                                                                                                         || p_dest_column_name || ', '':'', 1, 2)  - instr(t.' || p_dest_column_name || ', '':'', 1, 1) -1), ''###'') '
                     ||                                        '    AND mtps.partner_type = mtp.partner_type '
                     ||                                        '    AND mtps.partner_id = mtp.partner_id '
                     ||                                        '    AND replace(mtps.location, '''''''', '''')  = substr(t.' || p_dest_column_name || ', instr(t.' || p_dest_column_name || ', '':'', 1, 2) +1, instr(t.'
                                                                                                         || p_dest_column_name || ', '':'', 1, 3)  - instr(t.' || p_dest_column_name || ', '':'', 1, 2) -1) ';

            IF (x_instance_type IN (1,2,4))
            THEN
            x_sql := x_sql ||                                  '    AND mtps.tp_site_code = ''SHIP_TO''';
            END IF;

            x_sql := x_sql ||                                  '    AND replace(nvl(mtps.operating_unit_name, ''###''), '''''''', '''') = nvl(substr(t.' || p_dest_column_name || ', instr(t.' || p_dest_column_name || ', '':'', 1, 3) + 1, '
                     ||                                        '        decode (instr(t.' || p_dest_column_name || ', '':'', 1, 4), 0, length(t.' || p_dest_column_name || ') + 1, instr(t.' || p_dest_column_name || ', '':'', 1, 4)) - '
                     ||                                        '                instr(t.' || p_dest_column_name || ', '':'', 1, 3) - 1), ''###'') '
                     ||                                        '    AND mtsil.partner_type = mtps.partner_type '
                     ||                                        '    AND mtsil.sr_instance_id = ' || to_char(p_sr_instance_id)
                     ||                                        '    AND mtsil.tp_site_id = mtps.partner_site_id '
                     ||                                        '    AND nvl(mtsil.sr_cust_acct_id, -1) = nvl(mtil.sr_tp_id, -1) AND rownum < 2), t.' || p_dest_column_name || ' ) '
                     || ' WHERE t.' || p_dest_column_name || ' <> ''' || msd_dem_sr_util.get_null_code || ''''
                     || '    AND t.' || p_dest_column_name || ' LIKE ''%:%:%:%''';

            msd_dem_common_utilities.log_debug ('The query is - ');
            msd_dem_common_utilities.log_debug (x_sql);

            msd_dem_common_utilities.log_debug('Start Time: ' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS') );
		    EXECUTE IMMEDIATE x_sql;
		    x_num_rows := SQL%ROWCOUNT;
            msd_dem_common_utilities.log_message ('Number of rows updated - ' || to_char(x_num_rows));
            msd_dem_common_utilities.log_debug ('Number of rows updated - ' || to_char(x_num_rows));
		    msd_dem_common_utilities.log_debug('End Time: ' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS') );

		    COMMIT;

		    /* For Supplier Sites */
		    msd_dem_common_utilities.log_debug ('Convert from old to new - Building update query ');
		    x_sql := 'UPDATE ' || p_dest_table_name || ' t '
                     || ' SET t.' || p_dest_column_name || ' = nvl(('
                     ||                                        ' SELECT to_char(mtps.partner_site_id) '
                     ||                                        ' FROM msc_trading_partners mtp, '
                     ||                                        '      msc_trading_partner_sites mtps '
                     ||                                        ' WHERE  mtp.partner_type = 1 '
                     ||                                        '    AND replace(mtp.partner_name, '''''''', '''') = substr(t.' || p_dest_column_name || ',1,instr(t.' || p_dest_column_name ||','':'') - 1 ) '
                     ||                                        '    AND mtps.partner_type = 1 '
                     ||                                        '    AND mtps.partner_id = mtp.partner_id '
                     ||                                        '    AND replace(mtps.tp_site_code, '''''''', '''') = substr(t.' || p_dest_column_name || ', instr(t.' || p_dest_column_name || ', '':'') + 1, '
                     ||                                                                                                 'length(t.' || p_dest_column_name || ') - instr(t.' || p_dest_column_name || ', '':'')) '
                     ||                                        '    AND rownum < 2), t.' || p_dest_column_name || ' ) '
                     || ' WHERE t.' || p_dest_column_name || ' <> ''' || msd_dem_sr_util.get_null_code || ''''
                     || '    AND t.' || p_dest_column_name || ' LIKE ''%:%''';

            msd_dem_common_utilities.log_debug ('The query is - ');
            msd_dem_common_utilities.log_debug (x_sql);

            msd_dem_common_utilities.log_debug('Start Time: ' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS') );
		    EXECUTE IMMEDIATE x_sql;
		    x_num_rows := SQL%ROWCOUNT;
            msd_dem_common_utilities.log_message ('Number of rows updated - ' || to_char(x_num_rows));
            msd_dem_common_utilities.log_debug ('Number of rows updated - ' || to_char(x_num_rows));
		    msd_dem_common_utilities.log_debug('End Time: ' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS') );

		    COMMIT;

         END IF;

         msd_dem_common_utilities.log_debug ('Exiting SITE level');


      ELSIF (p_level = 'ACCOUNT')
      THEN


         msd_dem_common_utilities.log_debug ('Entering ACCOUNT level');

         IF (p_convert_type = 1)
         THEN

            msd_dem_common_utilities.log_debug ('Convert from new to old - Building update query ');

         ELSIF (p_convert_type = 2)
         THEN

            msd_dem_common_utilities.log_debug ('Convert from old to new - Building update query ');

            x_sql := 'UPDATE ' || p_dest_table_name || ' t '
                     || ' SET t.' || p_dest_column_name || ' = nvl(('
                     ||                                        ' SELECT to_char(mtp.partner_id) || ''::'' || replace(mtil.sr_cust_account_number, '''''''', '''') '
                     ||                                        ' FROM msc_trading_partners mtp, '
                     ||                                        '      msc_tp_id_lid mtil '
                     ||                                        ' WHERE  mtp.partner_type = 2 '
                     ||                                        '    AND replace(substrb(mtp.partner_name, 1, 50), '''''''', '''') = substr(t.' || p_dest_column_name || ',1,instr(t.' || p_dest_column_name ||','':'') - 1 ) '
                     ||                                        '    AND mtil.sr_instance_id = ' || to_char(p_sr_instance_id)
                     ||                                        '    AND mtil.tp_id = mtp.partner_id '
                     ||                                        '    AND replace(nvl(mtil.sr_cust_account_number, ''###''), '''''''', '''') = nvl(substr(t.' || p_dest_column_name || ', instr(t.' || p_dest_column_name || ', '':'') + 1, '
                     ||                                                                                                 'length(t.' || p_dest_column_name || ') - instr(t.' || p_dest_column_name || ', '':'')), ''###'') '
                     ||                                        '    AND rownum < 2), t.' || p_dest_column_name || ' ) '
                     || ' WHERE t.' || p_dest_column_name || ' <> ''' || msd_dem_sr_util.get_null_code || ''''
                     || '    AND t.' || p_dest_column_name || ' LIKE ''%:%''';

            msd_dem_common_utilities.log_debug ('The query is - ');
            msd_dem_common_utilities.log_debug (x_sql);

            msd_dem_common_utilities.log_debug('Start Time: ' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS') );
		    EXECUTE IMMEDIATE x_sql;
		    x_num_rows := SQL%ROWCOUNT;
            msd_dem_common_utilities.log_message ('Number of rows updated - ' || to_char(x_num_rows));
            msd_dem_common_utilities.log_debug ('Number of rows updated - ' || to_char(x_num_rows));
		    msd_dem_common_utilities.log_debug('End Time: ' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS') );

		    COMMIT;

         END IF;

         msd_dem_common_utilities.log_debug ('Exiting ACCOUNT level');


      ELSIF (p_level = 'CUSTOMER')
      THEN

         msd_dem_common_utilities.log_debug ('Entering CUSTOMER level');

         IF (p_convert_type = 1)
         THEN

            msd_dem_common_utilities.log_debug ('Convert from new to old - Building update query ');

         ELSIF (p_convert_type = 2)
         THEN

            msd_dem_common_utilities.log_debug ('Convert from old to new - Building update query ');

            x_sql := 'UPDATE ' || p_dest_table_name || ' t '
                     || ' SET t.' || p_dest_column_name || ' = nvl(('
                     ||                                        ' SELECT to_char(mtp.partner_id) '
                     ||                                        ' FROM msc_trading_partners mtp '
                     ||                                        ' WHERE mtp.partner_type = 2 '
                     ||                                        '    AND replace(substrb(mtp.partner_name, 1, 50), '''''''', '''') = t.' || p_dest_column_name || ' AND rownum < 2 ), t.' || p_dest_column_name || ' ) '
                     || ' WHERE t.' || p_dest_column_name || ' <> ''' || msd_dem_sr_util.get_null_code || '''';

            msd_dem_common_utilities.log_debug ('The query is - ');
            msd_dem_common_utilities.log_debug (x_sql);

            msd_dem_common_utilities.log_debug('Start Time: ' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS') );
		    EXECUTE IMMEDIATE x_sql;
		    x_num_rows := SQL%ROWCOUNT;
            msd_dem_common_utilities.log_message ('Number of rows updated - ' || to_char(x_num_rows));
            msd_dem_common_utilities.log_debug ('Number of rows updated - ' || to_char(x_num_rows));
		    msd_dem_common_utilities.log_debug('End Time: ' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS') );

		    COMMIT;

         END IF;

         msd_dem_common_utilities.log_debug ('Exiting CUSTOMER level');

      ELSIF (p_level = 'SUPPLIER')
      THEN

         msd_dem_common_utilities.log_debug ('Entering SUPPLIER level');

         IF (p_convert_type = 1)
         THEN

            msd_dem_common_utilities.log_debug ('Convert from new to old - Building update query ');

         ELSIF (p_convert_type = 2)
         THEN

            msd_dem_common_utilities.log_debug ('Convert from old to new - Building update query ');

            x_sql := 'UPDATE ' || p_dest_table_name || ' t '
                     || ' SET t.' || p_dest_column_name || ' = nvl(('
                     ||                                        ' SELECT to_char(mtp.partner_id) '
                     ||                                        ' FROM msc_trading_partners mtp '
                     ||                                        ' WHERE mtp.partner_type = 1 '
                     ||                                        '    AND replace(mtp.partner_name, '''''''', '''') = t.' || p_dest_column_name || ' AND rownum < 2 ), t.' || p_dest_column_name || ' ) '
                     || ' WHERE t.' || p_dest_column_name || ' <> ''' || msd_dem_sr_util.get_null_code || '''';

            msd_dem_common_utilities.log_debug ('The query is - ');
            msd_dem_common_utilities.log_debug (x_sql);

            msd_dem_common_utilities.log_debug('Start Time: ' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS') );
		    EXECUTE IMMEDIATE x_sql;
		    x_num_rows := SQL%ROWCOUNT;
            msd_dem_common_utilities.log_message ('Number of rows updated - ' || to_char(x_num_rows));
            msd_dem_common_utilities.log_debug ('Number of rows updated - ' || to_char(x_num_rows));
		    msd_dem_common_utilities.log_debug('End Time: ' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS') );

		    COMMIT;

         END IF;

         msd_dem_common_utilities.log_debug ('Exiting SUPPLIER level');

      ELSIF (p_level = 'TRADING PARTNER ZONE')
      THEN

         msd_dem_common_utilities.log_debug ('Entering TRADING PARTNER ZONE level');

         IF (p_convert_type = 1)
         THEN

            msd_dem_common_utilities.log_debug ('Convert from new to old - Building update query ');

         ELSIF (p_convert_type = 2)
         THEN

            msd_dem_common_utilities.log_debug ('Convert from old to new - Building update query ');

            x_sql := 'UPDATE ' || p_dest_table_name || ' t '
                     || ' SET t.' || p_dest_column_name || ' = nvl(('
                     ||                                        ' SELECT to_char(mtp.partner_id) || replace(substr(t.' || p_dest_column_name || ', instr(t.' || p_dest_column_name || ', '':''), '
                     ||                                                                             ' length(t.' || p_dest_column_name || ') - instr(t.' || p_dest_column_name || ', '':'') + 1 ), '':'', ''::'') '
                     ||                                        ' FROM msc_trading_partners mtp '
                     ||                                        ' WHERE mtp.partner_type = 2 '
                     ||                                        '    AND replace(substrb(mtp.partner_name, 1, 50), '''''''', '''') = substr(t.' || p_dest_column_name || ',1,instr(t.' || p_dest_column_name ||','':'') - 1 ) '
                     ||                                        '    AND rownum < 2 ), t.' || p_dest_column_name || ' ) '
                     || ' WHERE t.' || p_dest_column_name || ' <> ''' || msd_dem_sr_util.get_null_code || ''''
                     || '    AND t.' || p_dest_column_name || ' LIKE ''%:%:%''';

            msd_dem_common_utilities.log_debug ('The query is - ');
            msd_dem_common_utilities.log_debug (x_sql);

            msd_dem_common_utilities.log_debug('Start Time: ' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS') );
		    EXECUTE IMMEDIATE x_sql;
		    x_num_rows := SQL%ROWCOUNT;
            msd_dem_common_utilities.log_message ('Number of rows updated - ' || to_char(x_num_rows));
            msd_dem_common_utilities.log_debug ('Number of rows updated - ' || to_char(x_num_rows));
		    msd_dem_common_utilities.log_debug('End Time: ' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS') );

		    COMMIT;

         END IF;

         msd_dem_common_utilities.log_debug ('Exiting TRADING PARTNER ZONE level');

      END IF;


      msd_dem_common_utilities.log_debug('Exiting msd_dem_update_level_codes.convert_site_code' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS'));

   EXCEPTION
      WHEN OTHERS THEN
         errbuf := substr(SQLERRM,1,150);
         retcode := -1;

         msd_dem_common_utilities.log_message ('Exception(1): msd_dem_update_level_codes.convert_site_code - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
         msd_dem_common_utilities.log_message (errbuf);
	     RETURN;

   END CONVERT_SITE_CODE;


   /*
    * This procedure updates the level codes from descriptive to id format. The levels are -
    * SITE, ACCOUNT, CUSTOMER, SUPPLIER, TRADING PARTNER ZONE
    *
    * This is an upgrade procedure hence proper backup of the Demantra Schema must be taken
    * before running this procedure.
    *
    * This procedure must be run once for each instance for which data is available inside
    * Demantra.
    *
    * This procedure creates a backup copy of the tables before updating them.
    *
    * The Demantra Application Server should be down when the procedure is run.
    *
    * Once the procedure has finished, bring up the Demantra Application Server and verify data.
    *
    * Run Data Load and verify data.
    *
    * This procedure should be run with MSD_DEM: Debug Mode set to Yes.
    *
    */
    PROCEDURE UPGRADE_GEO_LEVEL_CODES (
    				errbuf              	OUT NOCOPY 	VARCHAR2,
                    retcode             	OUT NOCOPY 	VARCHAR2,
                    p_sr_instance_id        IN  		NUMBER)
    IS

       x_sql				VARCHAR2(4000)	:= NULL;
       x_dem_schema			VARCHAR2(100)	:= NULL;
       x_is_present			NUMBER			:= NULL;
       x_bk_table_name	    VARCHAR2(100)	:= NULL;
       x_ret_val			BOOLEAN			:= NULL;

       x_errbuf				VARCHAR2(4000)	:= NULL;
       x_retcode			VARCHAR2(1000)	:= NULL;

    BEGIN

    msd_dem_common_utilities.log_debug('Exiting msd_dem_update_level_codes.upgrade_geo_level_codes' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS'));

    /*** Validation - START ***/

    /* Exit with Warning if profile MSD_DEM: Debug Mode is set to no */
    IF (nvl(fnd_profile.value('MSD_DEM_DEBUG_MODE'), 'N') <> 'Y')
    THEN
       errbuf := 'Profile MSD_DEM: Debug Mode is set to No. Please set this profile to Yes. Exiting normally without any processing.';
       retcode := 1;
       msd_dem_common_utilities.log_message ('Warning(1): msd_dem_update_level_codes.upgrade_geo_level_codes - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
       msd_dem_common_utilities.log_message ('Profile MSD_DEM: Debug Mode is set to No. Please set this profile to Yes. Exiting normally without any processing.');
       RETURN;
    ELSE
       msd_dem_common_utilities.log_debug ('Debug Profile is set to Yes');
    END IF;

    /* Get the Demantra Schema Name and verify that the five tables are present or not */
    x_dem_schema := upper(fnd_profile.value('MSD_DEM_SCHEMA'));
    msd_dem_common_utilities.log_message ('The Demantra schema is - ' || x_dem_schema);

    EXECUTE IMMEDIATE ' SELECT count(1) FROM dba_objects WHERE owner = ''' || x_dem_schema || ''' and object_name IN (''T_EP_SITE'', ''T_EP_EBS_ACCOUNT'', ''T_EP_EBS_CUSTOMER'', ''T_EP_EBS_TP_ZONE'', ''T_EP_EBS_SUPPLIER'') '
                        || ' AND object_type = ''TABLE'''
       INTO x_is_present;

    IF (x_is_present <> 5)
    THEN

       errbuf := 'One or more of the following are missing ''T_EP_SITE'', ''T_EP_EBS_ACCOUNT'', ''T_EP_EBS_CUSTOMER'', ''T_EP_EBS_TP_ZONE'', ''T_EP_EBS_SUPPLIER''';
       retcode := -1;
       msd_dem_common_utilities.log_message ('Error(1): msd_dem_update_level_codes.upgrade_geo_level_codes - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
       msd_dem_common_utilities.log_message ('One or more of the following are missing ''T_EP_SITE'', ''T_EP_EBS_ACCOUNT'', ''T_EP_EBS_CUSTOMER'', ''T_EP_EBS_TP_ZONE'', ''T_EP_EBS_SUPPLIER''');
       RETURN;

    END IF;

    /* Verify that the profile MSD_DEM: Use new Site code format is set to No */
    IF (nvl(fnd_profile.value('MSD_DEM_SITE_CODE_FORMAT'), 2) = 1)
    THEN

       errbuf := 'The profile MSD_DEM: Use new Site code format is already set to Yes. This procedure should not be run.';
       retcode := -1;
       msd_dem_common_utilities.log_message ('Error(2): msd_dem_update_level_codes.upgrade_geo_level_codes - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
       msd_dem_common_utilities.log_message ('The profile MSD_DEM: Use new Site code format is already set to Yes. This procedure should not be run.');
       RETURN;

    END IF;

    /*** Validation - END ***/


    /*** Create Backup Tables - START ***/

    /* SITE */
    x_bk_table_name := 'MSD_BK_SITE_' || to_char(sysdate, 'ddmmyyhh24miss');
    msd_dem_common_utilities.log_message ('Backup table for SITE is - ' || x_bk_table_name);

    x_sql := 'CREATE TABLE ' || x_bk_table_name
                                || ' AS SELECT * FROM ' || x_dem_schema || '.T_EP_SITE';

    msd_dem_common_utilities.log_debug ('The query is - ');
    msd_dem_common_utilities.log_debug (x_sql);

    msd_dem_common_utilities.log_debug('Start Time: ' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS') );
	EXECUTE IMMEDIATE x_sql;
    msd_dem_common_utilities.log_debug('End Time: ' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS') );
    msd_dem_common_utilities.log_message('Created table ' || x_bk_table_name);


    /* ACCOUNT */
    x_bk_table_name := 'MSD_BK_ACCOUNT_' || to_char(sysdate, 'ddmmyyhh24miss');
    msd_dem_common_utilities.log_message ('Backup table for ACCOUNT is - ' || x_bk_table_name);

    x_sql := 'CREATE TABLE ' || x_bk_table_name
                                || ' AS SELECT * FROM ' || x_dem_schema || '.T_EP_EBS_ACCOUNT';

    msd_dem_common_utilities.log_debug ('The query is - ');
    msd_dem_common_utilities.log_debug (x_sql);

    msd_dem_common_utilities.log_debug('Start Time: ' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS') );
	EXECUTE IMMEDIATE x_sql;
    msd_dem_common_utilities.log_debug('End Time: ' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS') );
    msd_dem_common_utilities.log_message('Created table ' || x_bk_table_name);


    /* CUSTOMER */
    x_bk_table_name := 'MSD_BK_CUSTOMER_' || to_char(sysdate, 'ddmmyyhh24miss');
    msd_dem_common_utilities.log_message ('Backup table for CUSTOMER is - ' || x_bk_table_name);

    x_sql := 'CREATE TABLE ' || x_bk_table_name
                                || ' AS SELECT * FROM ' || x_dem_schema || '.T_EP_EBS_CUSTOMER';

    msd_dem_common_utilities.log_debug ('The query is - ');
    msd_dem_common_utilities.log_debug (x_sql);

    msd_dem_common_utilities.log_debug('Start Time: ' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS') );
	EXECUTE IMMEDIATE x_sql;
    msd_dem_common_utilities.log_debug('End Time: ' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS') );
    msd_dem_common_utilities.log_message('Created table ' || x_bk_table_name);


    /* TRADING PARTNER ZONE */
    x_bk_table_name := 'MSD_BK_TPZONE_' || to_char(sysdate, 'ddmmyyhh24miss');
    msd_dem_common_utilities.log_message ('Backup table for TRADING PARTNER ZONE is - ' || x_bk_table_name);

    x_sql := 'CREATE TABLE ' || x_bk_table_name
                                || ' AS SELECT * FROM ' || x_dem_schema || '.T_EP_EBS_TP_ZONE';

    msd_dem_common_utilities.log_debug ('The query is - ');
    msd_dem_common_utilities.log_debug (x_sql);

    msd_dem_common_utilities.log_debug('Start Time: ' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS') );
	EXECUTE IMMEDIATE x_sql;
    msd_dem_common_utilities.log_debug('End Time: ' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS') );
    msd_dem_common_utilities.log_message('Created table ' || x_bk_table_name);


    /* SUPPLIER */
    x_bk_table_name := 'MSD_BK_SUPPLIER_' || to_char(sysdate, 'ddmmyyhh24miss');
    msd_dem_common_utilities.log_message ('Backup table for SUPPLIER is - ' || x_bk_table_name);

    x_sql := 'CREATE TABLE ' || x_bk_table_name
                                || ' AS SELECT * FROM ' || x_dem_schema || '.T_EP_EBS_SUPPLIER';

    msd_dem_common_utilities.log_debug ('The query is - ');
    msd_dem_common_utilities.log_debug (x_sql);

    msd_dem_common_utilities.log_debug('Start Time: ' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS') );
	EXECUTE IMMEDIATE x_sql;
    msd_dem_common_utilities.log_debug('End Time: ' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS') );
    msd_dem_common_utilities.log_message('Created table ' || x_bk_table_name);


    /*** Create Backup Tables - END ***/


    /*** Update Level codes - START ***/

    /* SITE */
    convert_site_code (
    			x_errbuf,
    			x_retcode,
    			p_sr_instance_id,
    			'SITE',
    			x_dem_schema || '.T_EP_SITE',
    			'SITE',
    			2);
    IF(x_retcode = -1)
    THEN

       errbuf := x_errbuf;
       retcode := -1;
       msd_dem_common_utilities.log_message ('Error(3): msd_dem_update_level_codes.upgrade_geo_level_codes - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
       msd_dem_common_utilities.log_message ('Error while updating SITE level code');
       RETURN;

    END IF;


    /* ACCOUNT */
    convert_site_code (
    			x_errbuf,
    			x_retcode,
    			p_sr_instance_id,
    			'ACCOUNT',
    			x_dem_schema || '.T_EP_EBS_ACCOUNT',
    			'EBS_ACCOUNT',
    			2);
    IF(x_retcode = -1)
    THEN

       errbuf := x_errbuf;
       retcode := -1;
       msd_dem_common_utilities.log_message ('Error(3): msd_dem_update_level_codes.upgrade_geo_level_codes - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
       msd_dem_common_utilities.log_message ('Error while updating ACCOUNT level code');
       RETURN;

    END IF;


    /* CUSTOMER */
    convert_site_code (
    			x_errbuf,
    			x_retcode,
    			p_sr_instance_id,
    			'CUSTOMER',
    			x_dem_schema || '.T_EP_EBS_CUSTOMER',
    			'EBS_CUSTOMER',
    			2);
    IF(x_retcode = -1)
    THEN

       errbuf := x_errbuf;
       retcode := -1;
       msd_dem_common_utilities.log_message ('Error(3): msd_dem_update_level_codes.upgrade_geo_level_codes - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
       msd_dem_common_utilities.log_message ('Error while updating CUSTOMER level code');
       RETURN;

    END IF;


    /* TRADING PARTNER ZONE */
    convert_site_code (
    			x_errbuf,
    			x_retcode,
    			p_sr_instance_id,
    			'TRADING PARTNER ZONE',
    			x_dem_schema || '.T_EP_EBS_TP_ZONE',
    			'EBS_TP_ZONE',
    			2);
    IF(x_retcode = -1)
    THEN

       errbuf := x_errbuf;
       retcode := -1;
       msd_dem_common_utilities.log_message ('Error(3): msd_dem_update_level_codes.upgrade_geo_level_codes - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
       msd_dem_common_utilities.log_message ('Error while updating TRADING PARTNER ZONE level code');
       RETURN;

    END IF;


    /* SUPPLIER */
    convert_site_code (
    			x_errbuf,
    			x_retcode,
    			p_sr_instance_id,
    			'SUPPLIER',
    			x_dem_schema || '.T_EP_EBS_SUPPLIER',
    			'EBS_SUPPLIER',
    			2);
    IF(x_retcode = -1)
    THEN

       errbuf := x_errbuf;
       retcode := -1;
       msd_dem_common_utilities.log_message ('Error(3): msd_dem_update_level_codes.upgrade_geo_level_codes - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
       msd_dem_common_utilities.log_message ('Error while updating SUPPLIER level code');
       RETURN;

    END IF;


    /*** Update Level codes - END ***/


    /* Set Profile MSD_DEM_SITE_CODE_FORMAT to Yes */
    x_ret_val := fnd_profile.save('MSD_DEM_SITE_CODE_FORMAT', 1, 'SITE');
    COMMIT;
    msd_dem_common_utilities.log_message ('Profile MSD_DEM_SITE_CODE_FORMAT has been set to Yes at the SITE level.');

    msd_dem_common_utilities.log_debug('Exiting msd_dem_update_level_codes.upgrade_geo_level_codes' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS'));

    EXCEPTION
      WHEN OTHERS THEN
         errbuf := substr(SQLERRM,1,150);
         retcode := -1;

         msd_dem_common_utilities.log_message ('Exception(1): msd_dem_update_level_codes.upgrade_geo_level_codes - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
         msd_dem_common_utilities.log_message (errbuf);

    END UPGRADE_GEO_LEVEL_CODES;

END MSD_DEM_UPDATE_LEVEL_CODES;


/
