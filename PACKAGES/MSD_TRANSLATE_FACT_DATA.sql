--------------------------------------------------------
--  DDL for Package MSD_TRANSLATE_FACT_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_TRANSLATE_FACT_DATA" AUTHID CURRENT_USER AS
/* $Header: msdtfcts.pls 120.3 2005/12/06 22:59:05 sjagathe noship $ */

   SYS_YES               CONSTANT NUMBER := 1;    /* Bug# 4615390 ISO */
   SYS_NO                CONSTANT NUMBER := 2;    /* Bug# 4615390 ISO */

   /* Bug# 4747555 */
   C_ALL                 CONSTANT NUMBER := 1;


TYPE a_forecast_designator_type   IS TABLE OF msd_mfg_forecast.forecast_designator%TYPE;
TYPE a_item_type   IS TABLE OF msd_mfg_forecast.item%TYPE;
TYPE a_inv_org_type   IS TABLE OF msd_mfg_forecast.inv_org%TYPE;
TYPE a_customer_type   IS TABLE OF msd_mfg_forecast.customer%TYPE;
TYPE a_sales_channel_type   IS TABLE OF msd_mfg_forecast.sales_channel%TYPE;
TYPE a_ship_to_loc_type   IS TABLE OF msd_mfg_forecast.ship_to_loc%TYPE;
TYPE a_user_defined1_type   IS TABLE OF msd_mfg_forecast.user_defined1%TYPE;
TYPE a_user_defined2_type   IS TABLE OF msd_mfg_forecast.user_defined2%TYPE;
TYPE a_bucket_type_type   IS TABLE OF msd_mfg_forecast.bucket_type%TYPE;
TYPE a_forecast_date_type   IS TABLE OF msd_mfg_forecast.forecast_date%TYPE;
TYPE a_rate_end_date_type   IS TABLE OF msd_mfg_forecast.rate_end_date%TYPE;
TYPE a_original_quantity_type   IS TABLE OF msd_mfg_forecast.original_quantity%TYPE;
TYPE a_current_quantity_type   IS TABLE OF msd_mfg_forecast.current_quantity%TYPE;
TYPE a_sr_inv_org_pk_type   IS TABLE OF msd_mfg_forecast.sr_inv_org_pk%TYPE;
TYPE a_sr_item_pk_type   IS TABLE OF msd_mfg_forecast.sr_item_pk%TYPE;
TYPE a_sr_customer_pk_type   IS TABLE OF msd_mfg_forecast.sr_customer_pk%TYPE;
TYPE a_sr_sales_channel_pk_type   IS TABLE OF msd_mfg_forecast.sr_sales_channel_pk%TYPE;
TYPE a_sr_ship_to_loc_pk_type   IS TABLE OF msd_mfg_forecast.sr_ship_to_loc_pk%TYPE;
TYPE a_sr_user_defined1_pk_type   IS TABLE OF msd_mfg_forecast.sr_user_defined1_pk%TYPE;
TYPE a_sr_user_defined2_pk_type   IS TABLE OF msd_mfg_forecast.sr_user_defined2_pk%TYPE;
TYPE a_prd_level_id_type          IS TABLE OF msd_mfg_forecast.prd_level_id%TYPE;

procedure translate_shipment_data(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        p_source_table      IN  VARCHAR2,
                        p_dest_table        IN  VARCHAR2,
                        p_instance_id       IN  NUMBER,
                        p_from_date         IN  DATE,
                        p_to_date           IN  DATE,
                        p_new_refresh_num   IN  NUMBER,
                        p_delete_flag       IN  VARCHAR2,
                        p_collect_ISO       IN  NUMBER   DEFAULT SYS_NO,             /* Bug# 4615390 ISO, Bug# 4865396 */
                        p_order_type_flag   IN  NUMBER   DEFAULT C_ALL,              /* Bug# 4747555*/
                        p_order_type_ids    IN  VARCHAR2 DEFAULT NULL);

procedure translate_booking_data(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        p_source_table      IN  VARCHAR2,
                        p_dest_table        IN  VARCHAR2,
                        p_instance_id       IN  NUMBER,
                        p_from_date         IN  DATE,
                        p_to_date           IN  DATE,
                        p_new_refresh_num   IN  NUMBER,
                        p_delete_flag       IN  VARCHAR2,
                        p_collect_ISO       IN  NUMBER   DEFAULT SYS_NO,             /* Bug# 4615390 ISO, Bug# 4865396 */
                        p_order_type_flag   IN  NUMBER   DEFAULT C_ALL,              /* Bug# 4747555*/
                        p_order_type_ids    IN  VARCHAR2 DEFAULT NULL);

procedure translate_uom_conversion(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        p_source_table      IN  VARCHAR2,
                        p_dest_table        IN  VARCHAR2,
                        p_instance_id       IN  NUMBER,
                        p_new_refresh_num   IN  NUMBER) ;

procedure translate_currency_conversion(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        p_source_table      IN  VARCHAR2,
                        p_dest_table        IN  VARCHAR2,
                        p_instance_id       IN  NUMBER,
			p_from_date         IN  DATE,
                        p_to_date           IN  DATE);

procedure translate_opportunities_data(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        p_source_table      IN  VARCHAR2,
                        p_dest_table        IN  VARCHAR2,
                        p_instance_id       IN  NUMBER,
			p_from_date	    IN  DATE,
			p_to_date	    IN  DATE) ;

procedure translate_sales_forecast(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        p_source_table      IN  VARCHAR2,
                        p_dest_table        IN  VARCHAR2,
                        p_instance_id       IN  NUMBER,
			p_fcst_desg         IN  VARCHAR2,
		        p_from_date         IN  DATE,
                        p_to_date           IN  DATE);

procedure translate_mfg_forecast(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        p_source_table      IN  VARCHAR2,
                        p_dest_table        IN  VARCHAR2,
                        p_instance_id       IN  NUMBER,
                        p_fcst_desg         IN  VARCHAR2,
                        p_new_refresh_num   IN  NUMBER,
                        p_delete_flag       IN  VARCHAR2);

procedure translate_pricing_data(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        p_source_table      IN  VARCHAR2,
                        p_dest_table        IN  VARCHAR2,
                        p_instance_id       IN  NUMBER,
                        p_price_list        IN  VARCHAR2,
                        p_new_refresh_num   IN  NUMBER);


PROCEDURE mfg_post_process( errbuf              OUT NOCOPY VARCHAR2,
                            retcode             OUT NOCOPY VARCHAR2,
			    p_instance          IN  VARCHAR2,
			    p_designator        IN  VARCHAR2,
                            p_new_refresh_num   IN  NUMBER);


PROCEDURE populate_calendar(	errbuf              OUT NOCOPY VARCHAR2,
				retcode             OUT NOCOPY VARCHAR2,
				p_instance          IN  VARCHAR2,
                                p_new_refresh_num   IN  NUMBER,
				p_table_name        IN  VARCHAR2);



FUNCTION Is_Post_Process_Required(	errbuf              OUT NOCOPY VARCHAR2,
					retcode             OUT NOCOPY VARCHAR2,
					p_instance          IN  VARCHAR2,
					p_designator        IN  VARCHAR2 ) return BOOLEAN;


PROCEDURE CLEAN_FACT_DATA(	errbuf              OUT NOCOPY VARCHAR2,
				retcode             OUT NOCOPY VARCHAR2,
		                p_table_name        IN  VARCHAR2);

END MSD_TRANSLATE_FACT_DATA;

 

/
