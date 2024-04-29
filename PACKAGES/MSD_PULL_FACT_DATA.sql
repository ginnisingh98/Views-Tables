--------------------------------------------------------
--  DDL for Package MSD_PULL_FACT_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_PULL_FACT_DATA" AUTHID CURRENT_USER AS
/* $Header: msdpfcts.pls 120.3 2005/12/07 07:31:07 sjagathe noship $ */


procedure pull_fact_data(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2) ;

procedure pull_shipment_data(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2);

procedure pull_booking_data(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2);

procedure pull_uom_conversion(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2) ;

procedure pull_currency_conversion(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2) ;

/*
procedure pull_opportunities_data(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        p_comp_refresh      IN  VARCHAR2) ;

procedure pull_sales_forecast(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2) ;
*/

procedure pull_mfg_forecast(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2) ;

procedure pull_pricing_data(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2) ;

procedure pull_events(
                     errbuf              OUT NOCOPY VARCHAR2,
                     retcode             OUT NOCOPY VARCHAR2) ;

END MSD_PULL_FACT_DATA;

 

/
