--------------------------------------------------------
--  DDL for Package Body MSD_CL_LOADERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_CL_LOADERS" AS -- body
/* $Header: MSDCLLDB.pls 120.5 2007/11/05 13:35:48 vrepaka ship $ */
  -- ========= Global Parameters ===========

   -- User Environment --
   v_current_date               DATE:= sysdate;
   v_current_user               NUMBER;
   v_applsys_schema             VARCHAR2(32);
   v_monitor_request_id         NUMBER;
   v_request_id                 NumTblTyp:= NumTblTyp(0);
   v_ctl_file                   VarcharTblTyp:= VarcharTblTyp(0);
   v_dat_file                   VarcharTblTyp:= VarcharTblTyp(0);
   v_bad_file                   VarcharTblTyp:= VarcharTblTyp(0);
   v_dis_file                   VarcharTblTyp:= VarcharTblTyp(0);
   v_dat_file_path              VARCHAR2(1000):='';
   v_path_seperator             VARCHAR2(5):= '/';
   v_ctl_file_path              VARCHAR2(1000):= '';

   v_task_pointer               NUMBER:= 0;

   v_debug                      boolean := FALSE;

  -- =========== Private Functions =============

   PROCEDURE LOG_MESSAGE( pBUFF  IN  VARCHAR2)
   IS
   BEGIN
     IF fnd_global.conc_request_id > 0  THEN
         FND_FILE.PUT_LINE( FND_FILE.LOG, pBUFF);
     ELSE
         null;
         --DBMS_OUTPUT.PUT_LINE( pBUFF);
     END IF;
   EXCEPTION
     WHEN OTHERS THEN
        RETURN;
   END LOG_MESSAGE;

-- =====Local Procedures =========

   PROCEDURE GET_FILE_NAMES(  pDataFileName   VARCHAR2, pCtlFileName VARCHAR2)
   IS
   lv_file_name_length            NUMBER:= 0;
   lv_bad_file_name               VARCHAR2(1000):= '';
   lv_dis_file_name               VARCHAR2(1000):= '';

   BEGIN
		v_ctl_file.EXTEND;
		v_dat_file.EXTEND;
		v_bad_file.EXTEND;
		v_dis_file.EXTEND;

            v_task_pointer:= v_task_pointer + 1;

        	lv_file_name_length:= instr(pDataFileName, '.', -1);

	  	IF lv_file_name_length = 0 then

	  		lv_bad_file_name:= pDataFileName ||'.bad';
	  		lv_dis_file_name:= pDataFileName ||'.dis';

	  	ELSE

	  		lv_bad_file_name:= substr(pDataFileName, 1, lv_file_name_length)||'bad';
	  		lv_dis_file_name:= substr(pDataFileName, 1, lv_file_name_length)||'dis';

	  	END IF;

	     	v_ctl_file(v_task_pointer):= v_ctl_file_path || pCtlFileName;
		v_dat_file(v_task_pointer):= v_dat_file_path || pDataFileName;
		v_bad_file(v_task_pointer):= v_dat_file_path || lv_bad_file_name;
		v_dis_file(v_task_pointer):= v_dat_file_path || lv_dis_file_name;

		IF v_debug THEN
			LOG_MESSAGE('v_ctl_file('||v_task_pointer||'): '||v_ctl_file(v_task_pointer));
			LOG_MESSAGE('v_dat_file('||v_task_pointer||'): '||v_dat_file(v_task_pointer));
			LOG_MESSAGE('v_bad_file('||v_task_pointer||'): '||v_bad_file(v_task_pointer));
			LOG_MESSAGE('v_dis_file('||v_task_pointer||'): '||v_dis_file(v_task_pointer));
		END IF;

   END GET_FILE_NAMES;

   FUNCTION is_request_status_running RETURN NUMBER
   IS
      l_call_status      boolean;
      l_phase            varchar2(80);
      l_status           varchar2(80);
      l_dev_phase        varchar2(80);
      l_dev_status       varchar2(80);
      l_message          varchar2(2048);

      l_request_id       NUMBER;

   BEGIN

	l_request_id:= FND_GLOBAL.CONC_REQUEST_ID;

      l_call_status:= FND_CONCURRENT.GET_REQUEST_STATUS
                              ( l_request_id,
                                NULL,
                                NULL,
                                l_phase,
                                l_status,
                                l_dev_phase,
                                l_dev_status,
                                l_message);

      IF l_call_status=FALSE THEN
         LOG_MESSAGE( l_message);
         RETURN SYS_NO;
      END IF;

      IF l_dev_phase='RUNNING' THEN
         RETURN SYS_YES;
      ELSE
         RETURN SYS_NO;
      END IF;

   END is_request_status_running;

   FUNCTION active_loaders RETURN NUMBER IS
      l_call_status      boolean;
      l_phase            varchar2(80);
      l_status           varchar2(80);
      l_dev_phase        varchar2(80);
      l_dev_status       varchar2(80);
      l_message          varchar2(2048);
      l_request_id       NUMBER;
	l_active_loaders	 NUMBER:= 0 ;

   BEGIN

      FOR lc_i IN 1..(v_request_id.COUNT) LOOP

          l_request_id:= v_request_id(lc_i);

          l_call_status:= FND_CONCURRENT.GET_REQUEST_STATUS
                              ( l_request_id,
                                NULL,
                                NULL,
                                l_phase,
                                l_status,
                                l_dev_phase,
                                l_dev_status,
                                l_message);

           IF l_call_status=FALSE THEN
              LOG_MESSAGE( l_message);
           END IF;

           IF l_dev_phase IN ( 'PENDING','RUNNING') THEN
              l_active_loaders:= l_active_loaders + 1;
           END IF;

       END LOOP;

       RETURN l_active_loaders;

   END active_loaders;

   FUNCTION LAUNCH_LOADER( ERRBUF                      OUT NOCOPY VARCHAR2,
	                     RETCODE			       OUT NOCOPY NUMBER)
   RETURN NUMBER IS

   lv_request_id		NUMBER;
   lv_parameters		VARCHAR2(2000):= '';

   BEGIN

        lv_request_id:=  FND_REQUEST.SUBMIT_REQUEST(
                             'MSC',
                             'MSCSLD', /* loader program called */
                             NULL,  -- description
                             NULL,  -- start date
                             FALSE, -- TRUE,
   				     v_ctl_file(v_task_pointer),
		                 v_dat_file(v_task_pointer),
				     v_dis_file(v_task_pointer),
				     v_bad_file(v_task_pointer),
				     null,
				     '10000000'); -- NUM_OF_ERRORS
       COMMIT;

       IF lv_request_id = 0 THEN
          FND_MESSAGE.SET_NAME('MSC', 'MSC_PP_LAUNCH_LOADER_FAIL');
          ERRBUF:= FND_MESSAGE.GET;
          LOG_MESSAGE( ERRBUF);
          RETCODE:= G_ERROR;
	    RETURN -1;
       ELSE
         FND_MESSAGE.SET_NAME('MSC', 'MSC_PP_LOADER_REQUEST_ID');
         FND_MESSAGE.SET_TOKEN('REQUEST_ID', lv_request_id);
         LOG_MESSAGE(FND_MESSAGE.GET);
       END IF;

	RETURN lv_request_id;
   EXCEPTION
   WHEN OTHERS THEN
         LOG_MESSAGE( SQLERRM);
	   RETURN -1;
   END LAUNCH_LOADER;

-- ===============================================================
   PROCEDURE LAUNCH_MONITOR( ERRBUF          OUT NOCOPY VARCHAR2,
                 RETCODE                     OUT NOCOPY NUMBER,
                 p_instance_id               IN  NUMBER DEFAULT NULL,
                 p_timeout                   IN  NUMBER,
                 p_path_separator            IN  VARCHAR2 DEFAULT '/',
                 p_ctl_file_path             IN  VARCHAR2,
                 p_directory_path            IN  VARCHAR2,
                 p_total_worker_num          IN  NUMBER,
                 p_calendars                 IN  VARCHAR2 DEFAULT NULL,
                 p_workday_patterns          IN  VARCHAR2 DEFAULT NULL,
                 p_shift_times               IN  VARCHAR2 DEFAULT NULL,
                 p_calendar_exceptions       IN  VARCHAR2 DEFAULT NULL,
                 p_shift_exceptions          IN  VARCHAR2 DEFAULT NULL,
                 p_demand_class              IN  VARCHAR2 DEFAULT NULL,
                 p_trading_partners          IN  VARCHAR2 DEFAULT NULL,
                 p_trading_partner_sites     IN  VARCHAR2 DEFAULT NULL,
                 p_price_list                IN  VARCHAR2 DEFAULT NULL,
                 p_category_set              IN  VARCHAR2 DEFAULT NULL,
                 p_items                     IN  VARCHAR2 DEFAULT NULL,
                 p_item_categories           IN  VARCHAR2 DEFAULT NULL,
                 p_bom_headers               IN  VARCHAR2 DEFAULT NULL,
                 p_bom_components            IN  VARCHAR2 DEFAULT NULL,
                 p_uom                       IN  VARCHAR2 DEFAULT NULL,
                 p_uom_conv                  IN  VARCHAR2 DEFAULT NULL,
                 p_currency_conv             IN  VARCHAR2 DEFAULT NULL,
                 p_setup_parameters          IN  VARCHAR2 DEFAULT NULL,
                 p_fiscal_cal                IN  VARCHAR2 DEFAULT NULL,
                 p_composite_cal             IN  VARCHAR2 DEFAULT NULL,
                 p_level_value               IN  VARCHAR2 DEFAULT NULL,
                 p_level_associations        IN  VARCHAR2 DEFAULT NULL,
                 p_booking_data              IN  VARCHAR2 DEFAULT NULL,
                 p_shipment_data             IN  VARCHAR2 DEFAULT NULL,
                 p_mfg_forecast              IN  VARCHAR2 DEFAULT NULL,
                 p_cs_data                   IN  VARCHAR2 DEFAULT NULL,
                 p_level_org_asscns          IN  VARCHAR2 DEFAULT NULL,
                 p_item_relationships        IN  VARCHAR2 DEFAULT NULL,
                 p_sales_history             IN  VARCHAR2 DEFAULT NULL,
				 p_auto_run_download         IN  NUMBER   DEFAULT NULL,
		 p_install_base_history      IN  VARCHAR2 DEFAULT NULL,
		 p_fld_ser_usg_history       IN  VARCHAR2 DEFAULT NULL,
		 p_dpt_rep_usg_history       IN  VARCHAR2 DEFAULT NULL,
		 p_ser_part_ret_history      IN  VARCHAR2 DEFAULT NULL,
		 p_failure_rates             IN  VARCHAR2 DEFAULT NULL,
                 p_prd_ret_history           IN  VARCHAR2 DEFAULT NULL,
                 p_forecast_data             IN  VARCHAR2 DEFAULT NULL)
   IS

   lc_i                 PLS_INTEGER;

   lv_process_time      NUMBER:= 0;
   lv_check_point       NUMBER:= 0;
   lv_request_id        NUMBER:= -1;
   lv_start_time        DATE;

   lv_active_loaders    NUMBER:=0;

   EX_PROCESS_TIME_OUT EXCEPTION;

   BEGIN
-- ===== Switch on debug based on MRP: Debug Profile

        v_debug := FND_PROFILE.VALUE('MRP_DEBUG') = 'Y';

-- print the parameters coming in

   IF v_debug THEN
    LOG_MESSAGE('p_timeout: '||p_timeout);
    LOG_MESSAGE('p_path_separator: '||p_path_separator);
    LOG_MESSAGE('p_ctl_file_path: '||p_ctl_file_path);
    LOG_MESSAGE('p_directory_path: '||p_directory_path);
    LOG_MESSAGE('p_total_worker_num: '||p_total_worker_num);
    LOG_MESSAGE('p_calendars: '||p_calendars);
    LOG_MESSAGE('p_workday_patterns: '||p_workday_patterns);
    LOG_MESSAGE('p_shift_times:'||p_shift_times);
    LOG_MESSAGE('p_calendar_exceptions:'||p_calendar_exceptions);
    LOG_MESSAGE('p_shift_exceptions:'||p_shift_exceptions);
    LOG_MESSAGE('p_setup_parameters:'||p_setup_parameters);
    LOG_MESSAGE('p_bom_headers: '||p_bom_headers);
    LOG_MESSAGE('p_bom_components: '||p_bom_components);
    LOG_MESSAGE('p_items: '||p_items);
    LOG_MESSAGE('p_category_set : '||p_category_set);
    LOG_MESSAGE('p_item_categories: '||p_item_categories);
    LOG_MESSAGE('p_trading_partners: '||p_trading_partners);
    LOG_MESSAGE('p_trading_partner_sites: '||p_trading_partner_sites);
    LOG_MESSAGE('p_level_value: '||p_level_value);
    LOG_MESSAGE('p_level_associations: '||p_level_associations);
    LOG_MESSAGE('p_booking_data: '||p_booking_data);
    LOG_MESSAGE('p_shipment_data: '||p_shipment_data);
    LOG_MESSAGE('p_mfg_forecast: '||p_mfg_forecast);
    LOG_MESSAGE('p_price_list: '||p_price_list);
    -- LOG_MESSAGE('p_item_list_price: '||p_item_list_price);
    LOG_MESSAGE('p_cs_data: '||p_cs_data);
    LOG_MESSAGE('p_item_relationships: '||p_item_relationships);
    LOG_MESSAGE('p_level_org_asscns: '||p_level_org_asscns);
    LOG_MESSAGE('p_currency_conv: '||p_currency_conv);
    LOG_MESSAGE('p_uom : '||p_uom);
    LOG_MESSAGE('p_uom_conv: '||p_uom_conv);
    LOG_MESSAGE('p_fiscal_cal: '||p_fiscal_cal);
    LOG_MESSAGE('p_composite_cal: '||p_composite_cal);
    LOG_MESSAGE('p_demand_class : '||p_demand_class);
    LOG_MESSAGE('p_sales_history : '||p_sales_history);
    LOG_MESSAGE('p_install_base_history : '||p_install_base_history);
    LOG_MESSAGE('p_fld_ser_usg_history : '||p_fld_ser_usg_history);
    LOG_MESSAGE('p_dpt_rep_usg_history : '||p_dpt_rep_usg_history);
    LOG_MESSAGE('p_ser_part_ret_history : '||p_ser_part_ret_history);
    LOG_MESSAGE('p_failure_rates : '||p_failure_rates);
    LOG_MESSAGE('p_prd_ret_history : '||p_prd_ret_history);
    LOG_MESSAGE('p_forecast_data : '||p_forecast_data);

     END IF;

-- get the ctl file path. If last character is not path seperator add it

       v_path_seperator:= p_path_separator;

       v_ctl_file_path := p_ctl_file_path;

        IF v_ctl_file_path IS NOT NULL THEN
                IF SUBSTR(v_ctl_file_path,-1,1) = v_path_seperator then
                        v_ctl_file_path:= v_ctl_file_path;
                ELSE
                        v_ctl_file_path:= v_ctl_file_path || v_path_seperator;
                END IF;
        END IF;

-- ===== Assign the data file directory path to a global variable ===========

-- If last character is not path seperator, add it. User may specify the path in the
-- file name itself. Hence, if path is null, do not add seperator

	IF p_directory_path IS NOT NULL THEN
	  	IF SUBSTR(p_directory_path,-1,1) = v_path_seperator then
	      	v_dat_file_path:= p_directory_path;
	  	ELSE
			v_dat_file_path:= p_directory_path || v_path_seperator;
	  	END IF;
	END IF;

-- ===== create the Control, Data, Bad, Discard Files lists ==================
	IF p_calendars IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_calendars, pCtlFileName => 'MSC_ST_CALENDARS.ctl');
	END IF;

	IF p_workday_patterns IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_workday_patterns, pCtlFileName => 'MSC_ST_WORKDAY_PATTERNS.ctl');
	END IF;

	IF p_shift_times IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_shift_times, pCtlFileName => 'MSC_ST_SHIFT_TIMES.ctl');
	END IF;

	IF p_calendar_exceptions IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_calendar_exceptions, pCtlFileName => 'MSC_ST_CALENDAR_EXCEPTIONS.ctl');
	END IF;

	IF p_shift_exceptions IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_shift_exceptions, pCtlFileName => 'MSC_ST_SHIFT_EXCEPTIONS.ctl');
	END IF;

        IF p_setup_parameters IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_setup_parameters, pCtlFileName => 'MSD_ST_SETUP_PARAMETERS.ctl');
	END IF;

        IF p_bom_headers IS NOT NULL THEN
                GET_FILE_NAMES( pDataFileName => p_bom_headers, pCtlFileName => 'MSC_ST_BOMS.ctl');
        END IF;

        IF p_bom_components IS NOT NULL THEN
                GET_FILE_NAMES( pDataFileName => p_bom_components, pCtlFileName => 'MSC_ST_BOM_COMPONENTS.ctl');
        END IF;

	IF p_items IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_items, pCtlFileName => 'MSC_ST_SYSTEM_ITEMS.ctl');
	END IF;

	IF p_category_set IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_category_set, pCtlFileName => 'MSC_ST_CATEGORY_SETS.ctl');
	END IF;

	IF p_item_categories IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_item_categories, pCtlFileName => 'MSC_ST_ITEM_CATEGORIES.ctl');
	END IF;

	IF p_trading_partners IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_trading_partners, pCtlFileName => 'MSC_ST_TRADING_PARTNERS.ctl');
	END IF;

	IF p_trading_partner_sites IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_trading_partner_sites, pCtlFileName => 'MSC_ST_TRADING_PARTNER_SITES.ctl');
	END IF;

	IF p_level_value IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_level_value, pCtlFileName => 'MSD_ST_LEVEL_VALUES.ctl');
	END IF;

	IF p_level_associations IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_level_associations, pCtlFileName => 'MSD_ST_LEVEL_ASSOCIATIONS.ctl');
	END IF;

	IF p_booking_data IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_booking_data, pCtlFileName => 'MSD_ST_BOOKING_DATA.ctl');
	END IF;

	IF p_shipment_data IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_shipment_data, pCtlFileName => 'MSD_ST_SHIPMENT_DATA.ctl');
	END IF;

	IF p_mfg_forecast IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_mfg_forecast, pCtlFileName => 'MSD_ST_MFG_FORECAST.ctl');
	END IF;

	IF p_price_list IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_price_list, pCtlFileName => 'MSD_ST_PRICE_LIST.ctl');
	END IF;
/*
	IF p_item_list_price IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_item_list_price, pCtlFileName => 'MSD_ST_ITEM_LIST_PRICE.ctl');
	END IF;
*/
	IF p_cs_data IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_cs_data, pCtlFileName => 'MSD_ST_CS_DATA.ctl');
	END IF;

	IF p_item_relationships IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_item_relationships, pCtlFileName => 'MSD_ST_ITEM_RELATIONSHIPS.ctl');
	END IF;

	IF p_level_org_asscns IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_level_org_asscns, pCtlFileName => 'MSD_ST_LEVEL_ORG_ASSCNS.ctl');
	END IF;

	IF p_currency_conv IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_currency_conv, pCtlFileName => 'MSD_ST_CURRENCY_CONVERSIONS.ctl');
	END IF;

	IF p_uom IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_uom, pCtlFileName => 'MSC_ST_UNITS_OF_MEASURE.ctl');
	END IF;

	IF p_uom_conv IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_uom_conv, pCtlFileName => 'MSD_ST_UOM_CONVERSIONS.ctl');
	END IF;

	IF p_fiscal_cal IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_fiscal_cal, pCtlFileName => 'MSD_ST_TIME.ctl');
	END IF;

        IF p_composite_cal IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_composite_cal, pCtlFileName => 'MSD_ST_COMPOSITE_CALENDARS.ctl');
	END IF;

        IF p_demand_class IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_demand_class, pCtlFileName => 'MSC_ST_DEMAND_CLASSES.ctl');
	END IF;

	IF p_sales_history IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_sales_history, pCtlFileName => 'T_SRC_SALES_TMPL.ctl');
	END IF;

	IF p_install_base_history IS NOT NULL THEN
		GET_FILE_NAMES( pDataFileName => p_install_base_history, pCtlFileName => 'MSD_DEM_INS_BASE_HISTORY.ctl');
	END IF;

       IF p_dpt_rep_usg_history IS NOT NULL THEN
      	GET_FILE_NAMES( pDataFileName => p_dpt_rep_usg_history, pCtlFileName => 'MSD_DEM_DPT_REP_USG_HISTORY.ctl');
       END IF;

     IF p_fld_ser_usg_history IS NOT NULL THEN
   	GET_FILE_NAMES( pDataFileName => p_fld_ser_usg_history, pCtlFileName => 'MSD_DEM_FLD_SER_USG_HISTORY.ctl');
       END IF;

	 IF p_ser_part_ret_history IS NOT NULL THEN
   	GET_FILE_NAMES( pDataFileName => p_ser_part_ret_history, pCtlFileName => 'MSD_DEM_SRP_RETURN_HISTORY.ctl');
       END IF;

	 IF p_failure_rates IS NOT NULL THEN
   	GET_FILE_NAMES( pDataFileName => p_failure_rates, pCtlFileName => 'MSC_ITEM_FAILURE_RATES.ctl');
       END IF;

	 IF p_prd_ret_history IS NOT NULL THEN
   	GET_FILE_NAMES( pDataFileName => p_prd_ret_history, pCtlFileName => 'MSD_DEM_RETURN_HISTORY.ctl');
       END IF;

	 IF p_forecast_data IS NOT NULL THEN
   	GET_FILE_NAMES( pDataFileName => p_forecast_data, pCtlFileName => 'MSD_DP_SCENARIO_ENTRIES.ctl');
	 END IF;

      v_request_id.EXTEND(v_task_pointer);

      v_task_pointer:= 0;

  -- ============ Lauch the Loaders here ===============

     LOOP

	IF active_loaders < p_total_worker_num THEN

            EXIT WHEN is_request_status_running <> SYS_YES;

		IF v_task_pointer < (v_ctl_file.LAST - 1)  THEN

		   v_task_pointer:= v_task_pointer + 1;

		   lv_request_id:= LAUNCH_LOADER (ERRBUF        => ERRBUF,
					       RETCODE       => RETCODE);

		   IF lv_request_id <> -1 THEN
			v_request_id(v_task_pointer):= lv_request_id;
		   END IF;

                ELSIF active_loaders = 0 THEN

                   EXIT;

               ELSE

                  select (SYSDATE- START_TIME) into lv_process_time from dual;

                  IF lv_process_time > p_timeout/1440.0 THEN Raise EX_PROCESS_TIME_OUT;  END IF;

                      DBMS_LOCK.SLEEP( 5);

                  END IF;

	ELSE
   -- ============= Check the execution time ==============

         select (SYSDATE- START_TIME) into lv_process_time from dual;

         IF lv_process_time > p_timeout/1440.0 THEN Raise EX_PROCESS_TIME_OUT;  END IF;

         DBMS_LOCK.SLEEP( 5);

	END IF;

      END LOOP;

     lv_check_point:= 3;

     IF RETCODE= G_ERROR THEN RETURN; END IF;

   EXCEPTION

      WHEN EX_PROCESS_TIME_OUT THEN

         ROLLBACK;

         FND_MESSAGE.SET_NAME('MSC', 'MSC_TIMEOUT');
         ERRBUF:= FND_MESSAGE.GET;
         RETCODE:= G_ERROR;
         LOG_MESSAGE( ERRBUF);

      WHEN others THEN

         ROLLBACK;

         ERRBUF := SQLERRM;
         RETCODE:= G_ERROR;
         LOG_MESSAGE( ERRBUF);

   END LAUNCH_MONITOR;

END MSD_CL_LOADERS;

/
