--------------------------------------------------------
--  DDL for Package MSD_CL_LOADERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_CL_LOADERS" AUTHID CURRENT_USER AS -- specification
/* $Header: MSDCLLDS.pls 120.5 2007/11/05 13:22:28 vrepaka ship $ */

  ----- ARRAY DATA TYPE --------------------------------------------------

   TYPE NumTblTyp IS TABLE OF NUMBER;
   TYPE VarcharTblTyp IS TABLE OF VARCHAR2(1000);

  ----- CONSTANTS --------------------------------------------------------

   SYS_YES                      CONSTANT NUMBER := 1;
   SYS_NO                       CONSTANT NUMBER := 2;

   G_SUCCESS                    CONSTANT NUMBER := 0;
   G_WARNING                    CONSTANT NUMBER := 1;
   G_ERROR                      CONSTANT NUMBER := 2;


   -- ============ Task Control ================

   PIPE_TIME_OUT         CONSTANT NUMBER := 30;      -- 30 secs
   START_TIME            DATE;



   -- ================== Worker Status ===================

    OK                    		CONSTANT NUMBER := 1;
    FAIL                  		CONSTANT NUMBER := 0;

   --  ================= Procedures ====================
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
                 p_forecast_data             IN  VARCHAR2 DEFAULT NULL);



END MSD_CL_LOADERS;

/
