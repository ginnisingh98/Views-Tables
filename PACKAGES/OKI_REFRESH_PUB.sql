--------------------------------------------------------
--  DDL for Package OKI_REFRESH_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKI_REFRESH_PUB" AUTHID CURRENT_USER AS
/* $Header: OKIPRFHS.pls 115.12 2003/11/25 11:22:45 kbajaj ship $ */
--
-- Procedure to refresh the latest conversion rates from gl table to oki schema
--
PROCEDURE refresh_daily_rates(errbuf OUT NOCOPY VARCHAR2
                             ,retcode OUT NOCOPY VARCHAR2);

--
-- Procedure to refresh the denormalized header table
--
PROCEDURE refresh_sales_k_hdrs(errbuf OUT NOCOPY VARCHAR2
                              ,retcode OUT NOCOPY VARCHAR2);

--
-- Procedure to refresh the addresses table
--
PROCEDURE refresh_addrs(errbuf OUT NOCOPY VARCHAR2
                       ,retcode OUT NOCOPY VARCHAR2);

--
-- Procedure to refresh the sold item lines table
--
PROCEDURE refresh_sold_itm_lines(errbuf OUT NOCOPY VARCHAR2
                                ,retcode OUT NOCOPY VARCHAR2);

--
-- Procedure to refresh the covered product lines table
--
PROCEDURE refresh_cov_prd_lines(errbuf OUT NOCOPY VARCHAR2
                               ,retcode OUT NOCOPY VARCHAR2);

--
-- Procedure to refresh the expired lines denormalized table
--
PROCEDURE refresh_expired_lines(errbuf OUT NOCOPY VARCHAR2
                               ,retcode OUT NOCOPY VARCHAR2);

--
-- Procedure to refresh the contract salesreps table
--
PROCEDURE refresh_k_salesreps(errbuf OUT NOCOPY VARCHAR2
                             ,retcode OUT NOCOPY VARCHAR2);

PROCEDURE refresh_k_conv_rates(errbuf OUT NOCOPY VARCHAR2
                             ,retcode OUT NOCOPY VARCHAR2);

--
-- Procedure to start the setup for the fast refresh process
--
PROCEDURE job_start(  x_errbuf         OUT NOCOPY VARCHAR2
                    , x_retcode        OUT NOCOPY VARCHAR2
                    , p_job_start_date IN  VARCHAR2 ) ;

--
-- Procedure to complete the setup for the fast refresh process
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
-- Procedure to fast refresh the contract salesreps denormalized table
--
PROCEDURE fast_k_salesreps(  x_errbuf  OUT NOCOPY VARCHAR2
                           , x_retcode OUT NOCOPY VARCHAR2 ) ;

--
-- Procedure to fast refresh the addresses denormalized table
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
                                   , x_retcode OUT NOCOPY VARCHAR2 );

--Procedure to load the job_run_dtl with contracts with currency conversion rate
--information during inital load

PROCEDURE initial_load_job_run_dtl(  p_job_run_id          IN  NUMBER
                                   , p_job_curr_start_date IN  DATE
                                   , p_job_curr_end_date   IN  DATE
                                   ,x_retcode OUT NOCOPY VARCHAR2);
--Procedure to kick the job start during inital load

PROCEDURE initial_load_job_start( x_errbuf          OUT NOCOPY VARCHAR2
                               , x_retcode         OUT NOCOPY VARCHAR2 );
END OKI_REFRESH_PUB;

 

/
