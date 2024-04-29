--------------------------------------------------------
--  DDL for Package MSD_COLLECT_FACT_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_COLLECT_FACT_DATA" AUTHID CURRENT_USER AS
/* $Header: msdcfcts.pls 120.3 2005/12/06 23:10:55 sjagathe noship $ */

   /* Bug# 4615390 ISO */
   /* Bug# 4747555 */
   SYS_YES               CONSTANT NUMBER := 1;
   SYS_NO                CONSTANT NUMBER := 2;

/* Public Procedures */

procedure collect_fact_data(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        p_instance_id       IN  NUMBER,
                        p_from_date         IN  VARCHAR2,
                        p_to_date           IN  VARCHAR2,
			p_fcst_desg	    IN  VARCHAR2,
                        p_price_list        IN  VARCHAR2 );


procedure collect_shipment_data(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        p_instance_id       IN  NUMBER,
                        p_from_date         IN  VARCHAR2,
                        p_to_date           IN  VARCHAR2,
                        p_collect_ISO       IN NUMBER DEFAULT SYS_NO,                  /* Bug# 4615390 ISO, Bug# 4865396 */
                        p_collect_all_order_types IN NUMBER   DEFAULT SYS_YES,         /* Bug# 4747555*/
                        p_include_order_types     IN VARCHAR2 DEFAULT NULL,
                        p_exclude_order_types     IN VARCHAR2 DEFAULT NULL) ;

procedure collect_booking_data(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        p_instance_id       IN  NUMBER,
                        p_from_date         IN  VARCHAR2,
                        p_to_date           IN  VARCHAR2,
		        p_collect_ISO       IN NUMBER DEFAULT SYS_NO,                  /* Bug# 4615390 ISO, Bug# 4865396 */
                        p_collect_all_order_types IN NUMBER   DEFAULT SYS_YES,         /* Bug# 4747555*/
                        p_include_order_types     IN VARCHAR2 DEFAULT NULL,
                        p_exclude_order_types     IN VARCHAR2 DEFAULT NULL) ;

procedure collect_uom_conversion(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        p_instance_id       IN  NUMBER);

procedure collect_currency_conversion(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        p_instance_id       IN  NUMBER,
                        p_from_date         IN  VARCHAR2,
                        p_to_date           IN  VARCHAR2) ;

/* procedure collect_opportunities_data(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        p_instance_id       IN  NUMBER,
			p_from_date	    IN  VARCHAR2,
			p_to_date	    IN  VARCHAR2) ;

procedure collect_sales_forecast(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        p_instance_id       IN  NUMBER,
                        p_from_date         IN  VARCHAR2,
                        p_to_date           IN  VARCHAR2) ;
*/

procedure collect_mfg_forecast(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        p_instance_id       IN  NUMBER,
                        p_fcst_desg	    IN  VARCHAR2) ;

procedure collect_pricing_data(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        p_instance_id       IN  NUMBER,
                        p_price_list	    IN  VARCHAR2) ;

procedure purge_facts(
                      errbuf              OUT NOCOPY VARCHAR2,
                      retcode             OUT NOCOPY VARCHAR2,
                      p_instance_id       IN  NUMBER);


/* Private functions */
function get_purge_sql(p_table VARCHAR2, p_instance_id NUMBER) RETURN VARCHAR2;

END MSD_COLLECT_FACT_DATA;

 

/
