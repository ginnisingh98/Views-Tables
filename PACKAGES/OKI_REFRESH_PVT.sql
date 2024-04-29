--------------------------------------------------------
--  DDL for Package OKI_REFRESH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKI_REFRESH_PVT" AUTHID CURRENT_USER AS
/* $Header: OKIRRFHS.pls 115.18 2003/11/25 10:18:39 kbajaj ship $ */

-- GLOBAL VARIABLES

    g_request_id               oki.oki_refreshs.request_id%TYPE;
    g_program_application_id   oki.oki_refreshs.PROGRAM_APPLICATION_ID%TYPE;
    g_program_id               oki.oki_refreshs.PROGRAM_ID%TYPE;
    g_program_update_date      oki.oki_refreshs.PROGRAM_UPDATE_DATE%TYPE;


FUNCTION get_conversion_rate( p_curr_date DATE
                               ,p_from_currency IN VARCHAR2
					,p_to_currency IN VARCHAR2
					) RETURN NUMBER;

-- PRAGMA RESTRICT_REFERENCES (get_conversion_rate, WNDS);


--
-- update the table that holds the last refresh date
--
PROCEDURE update_oki_refresh( p_object_name IN  VARCHAR2
                            , x_retcode     OUT NOCOPY VARCHAR2
                            , p_job_run_id  IN  NUMBER DEFAULT NULL ) ;
--
-- Procedure to refresh the latest conversion rates from gl table to oki schema
--
PROCEDURE refresh_daily_rates(errbuf OUT NOCOPY VARCHAR2
                             ,retcode OUT NOCOPY VARCHAR2);

--
-- Procedure to refresh the sales header denormalized table
--
PROCEDURE refresh_sales_k_hdrs(errbuf OUT NOCOPY VARCHAR2
                              ,retcode OUT NOCOPY VARCHAR2);

--
-- Procedure to refresh the address denormalized table
--
PROCEDURE refresh_addrs(errbuf OUT NOCOPY VARCHAR2
                       ,retcode OUT NOCOPY VARCHAR2);

--
-- Procedure to refresh the sold item lines denormalized table
--
PROCEDURE refresh_sold_itm_lines(errbuf OUT NOCOPY VARCHAR2
                                ,retcode OUT NOCOPY VARCHAR2);

--
-- Procedure to refresh the covered product lines denormalized table
--
PROCEDURE refresh_cov_prd_lines(errbuf OUT NOCOPY VARCHAR2
                               ,retcode OUT NOCOPY VARCHAR2);

--
-- Procedure to refresh the expired lines denormalized table
--
PROCEDURE refresh_expired_lines(errbuf OUT NOCOPY VARCHAR2
                               ,retcode OUT NOCOPY VARCHAR2);

--
-- Procedure to refresh the salesrep denormalized table
--
PROCEDURE refresh_k_salesreps(errbuf OUT NOCOPY VARCHAR2
                             ,retcode OUT NOCOPY VARCHAR2);

PROCEDURE refresh_k_conv_rates(errbuf OUT NOCOPY VARCHAR2
                             ,retcode OUT NOCOPY VARCHAR2);

--
-- Procedure to create a oki_job_runs record
--
PROCEDURE job_start(  p_job_start_date IN  DATE
                    , x_errbuf         OUT NOCOPY VARCHAR2
                    , x_retcode        OUT NOCOPY VARCHAR2 ) ;
--
-- Procedure to update a oki_job_runs record
--
PROCEDURE job_end(  x_errbuf         OUT NOCOPY VARCHAR2
                  , x_retcode        OUT NOCOPY VARCHAR2 ) ;

--
-- Procedure to fast refresh the sales header denormalized table
--
PROCEDURE fast_sales_k_hdrs(  x_errbuf  OUT NOCOPY VARCHAR2
                            , x_retcode OUT NOCOPY VARCHAR2 ) ;

--
-- Procedure to fast refresh the sold item lines denormalized table
--
PROCEDURE fast_sold_itm_lines(  x_errbuf  OUT NOCOPY VARCHAR2
                              , x_retcode OUT NOCOPY VARCHAR2 ) ;

--
-- Procedure to fast refresh the covered product lines denormalized table
--
PROCEDURE fast_cov_prd_lines(  x_errbuf  OUT NOCOPY VARCHAR2
                             , x_retcode OUT NOCOPY VARCHAR2 ) ;

--
-- Procedure to fast refresh the expired lines denormalized table
--
PROCEDURE fast_expired_lines(  x_errbuf  OUT NOCOPY VARCHAR2
                             , x_retcode OUT NOCOPY VARCHAR2 ) ;

--
-- Procedure to fast refresh the contract salesrep denormalized table
--
PROCEDURE fast_k_salesreps(  x_errbuf  OUT NOCOPY VARCHAR2
                           , x_retcode OUT NOCOPY VARCHAR2 ) ;

--
-- Procedure to fast refresh the contract addresses denormalized table
--
PROCEDURE fast_addrs(  x_errbuf  OUT NOCOPY VARCHAR2
                     , x_retcode OUT NOCOPY VARCHAR2 ) ;

--
-- Procedure to handle the first time fast refresh load
--
PROCEDURE initial_job_check(  x_errbuf  OUT NOCOPY VARCHAR2
                            , x_retcode OUT NOCOPY VARCHAR2 ) ;

--
-- Procedure to bring contract pricing rules rand quote to contact information
-- into OKI schema
--
PROCEDURE refresh_k_pricing_rules(  x_errbuf  OUT NOCOPY VARCHAR2
                                  , x_retcode OUT NOCOPY VARCHAR2 ) ;

--
-- Procedure to bring contract pricing rules rand quote to contact information into OKI schema
-- for only those contracts whose data has changed between last full or fast refresh and rundate
--
PROCEDURE fast_k_pricing_rules(  x_errbuf  OUT NOCOPY VARCHAR2
                               , x_retcode OUT NOCOPY VARCHAR2 ) ;

--
-- Procedure to update Top line price_negotiated amount with
-- sum of covered product line amounts for service contracts.
--
PROCEDURE update_service_line(  x_errbuf  OUT NOCOPY VARCHAR2
  					     , x_retcode OUT NOCOPY VARCHAR2 ) ;

--
-- Procedure to update Top line price_negotiated amount with
-- sum of covered product line amounts for service contracts.
-- for only those contracts whose data has changed between last full or fast refresh and rundate
--
PROCEDURE fast_update_service_line(  x_errbuf  OUT NOCOPY VARCHAR2
  						     , x_retcode OUT NOCOPY VARCHAR2 ) ;

--Procedure to load the job_run_dtl with contracts with currency conversion rate
--information during inital load

PROCEDURE initial_load_job_run_dtl(  p_job_run_id          IN  NUMBER
                                   , p_job_curr_start_date IN  DATE
                                   , p_job_curr_end_date   IN  DATE
                                   , x_retcode OUT NOCOPY VARCHAR2);
--Procedure to kick the job start during inital load

PROCEDURE initial_load_job_start(x_errbuf OUT NOCOPY VARCHAR2
                                ,x_retcode OUT NOCOPY VARCHAR2);

END OKI_REFRESH_PVT ;

 

/
