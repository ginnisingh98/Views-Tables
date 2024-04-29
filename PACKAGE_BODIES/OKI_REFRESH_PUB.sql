--------------------------------------------------------
--  DDL for Package Body OKI_REFRESH_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKI_REFRESH_PUB" AS
/* $Header: OKIPRFHB.pls 115.12 2003/11/25 11:22:56 kbajaj ship $ */

--
-- Procedure to refresh the latest conversion rates from gl table to oki schema
--
PROCEDURE refresh_daily_rates(errbuf OUT NOCOPY VARCHAR2
                             ,retcode OUT NOCOPY VARCHAR2) IS
BEGIN
   OKI_REFRESH_PVT.refresh_daily_rates(errbuf, retcode);
END refresh_daily_rates;

--
-- Procedure to refresh the denormalized header table
--
PROCEDURE refresh_sales_k_hdrs(errbuf OUT NOCOPY VARCHAR2
                              ,retcode OUT NOCOPY VARCHAR2) IS
BEGIN
   oki_refresh_pvt.refresh_sales_k_hdrs(errbuf, retcode);
END refresh_sales_k_hdrs;

--
-- Procedure to refresh the addresses table
--
PROCEDURE refresh_addrs(errbuf OUT NOCOPY VARCHAR2
                       ,retcode OUT NOCOPY VARCHAR2) IS
BEGIN
   oki_refresh_pvt.refresh_addrs(errbuf, retcode);
END refresh_addrs;

--
-- Procedure to refresh the sold item lines table
--
PROCEDURE refresh_sold_itm_lines(errbuf OUT NOCOPY VARCHAR2
                                ,retcode OUT NOCOPY VARCHAR2) IS
BEGIN
   oki_refresh_pvt.refresh_sold_itm_lines(errbuf, retcode);
END refresh_sold_itm_lines;

--
-- Procedure to refresh the covered product lines table
--
PROCEDURE refresh_cov_prd_lines(errbuf OUT NOCOPY VARCHAR2
                                ,retcode OUT NOCOPY VARCHAR2) IS
BEGIN
   oki_refresh_pvt.refresh_cov_prd_lines(errbuf, retcode);
END refresh_cov_prd_lines;

--
-- Procedure to refresh the expired lines table
--
PROCEDURE refresh_expired_lines(errbuf OUT NOCOPY VARCHAR2
                               ,retcode OUT NOCOPY VARCHAR2) IS
BEGIN
   oki_refresh_pvt.refresh_expired_lines(errbuf, retcode);
END refresh_expired_lines;

--
-- Procedure to refresh the contract salesreps table
--
PROCEDURE refresh_k_salesreps(errbuf OUT NOCOPY VARCHAR2
                             ,retcode OUT NOCOPY VARCHAR2) IS
BEGIN
   oki_refresh_pvt.refresh_k_salesreps(errbuf, retcode);
END refresh_k_salesreps;


PROCEDURE refresh_k_conv_rates(errbuf OUT NOCOPY VARCHAR2
                             ,retcode OUT NOCOPY VARCHAR2) IS
BEGIN
   oki_refresh_pvt.refresh_k_conv_rates(errbuf, retcode);
END refresh_k_conv_rates;

--
-- Procedure to start the setup for the fast refresh process
--
PROCEDURE job_start(  x_errbuf        OUT NOCOPY VARCHAR2
                    , x_retcode       OUT NOCOPY VARCHAR2
                    , p_job_start_date IN  VARCHAR2 ) IS

  l_job_start_date DATE := NULL ;
BEGIN
  l_job_start_date := fnd_conc_date.string_to_date(p_job_start_date );

  oki_refresh_pvt.job_start(
        p_job_start_date => l_job_start_date
      , x_errbuf         => x_errbuf
      , x_retcode        => x_retcode ) ;
END job_start ;

--
-- Procedure to complete the setup for the fast refresh process
--
PROCEDURE job_end(  x_errbuf        OUT NOCOPY VARCHAR2
                  , x_retcode       OUT NOCOPY VARCHAR2 ) IS
BEGIN
   oki_refresh_pvt.job_end(
        x_errbuf         => x_errbuf
      , x_retcode        => x_retcode ) ;
END job_end ;

--
-- Procedure to fast refresh the sales header denormalized table
--
PROCEDURE fast_sales_k_hdrs(  x_errbuf  OUT NOCOPY VARCHAR2
                            , x_retcode OUT NOCOPY VARCHAR2 ) IS
BEGIN
   oki_refresh_pvt.fast_sales_k_hdrs(
        x_errbuf         => x_errbuf
      , x_retcode        => x_retcode ) ;
END fast_sales_k_hdrs ;

--
-- Procedure to fast refresh the sold item lines denormalized table
--
PROCEDURE fast_sold_itm_lines(  x_errbuf  OUT NOCOPY VARCHAR2
                              , x_retcode OUT NOCOPY VARCHAR2 ) IS
BEGIN
   oki_refresh_pvt.fast_sold_itm_lines(
        x_errbuf         => x_errbuf
      , x_retcode        => x_retcode ) ;
END fast_sold_itm_lines ;

--
-- Procedure to fast refresh the covered product lines denormalized table
--
PROCEDURE fast_cov_prd_lines(  x_errbuf  OUT NOCOPY VARCHAR2
                             , x_retcode OUT NOCOPY VARCHAR2 ) IS
BEGIN
   oki_refresh_pvt.fast_cov_prd_lines(
        x_errbuf         => x_errbuf
      , x_retcode        => x_retcode ) ;
END fast_cov_prd_lines ;

--
-- Procedure to fast refresh the expired lines denormalized table
--
PROCEDURE fast_expired_lines(  x_errbuf  OUT NOCOPY VARCHAR2
                             , x_retcode OUT NOCOPY VARCHAR2 ) IS
BEGIN
   oki_refresh_pvt.fast_expired_lines(
        x_errbuf         => x_errbuf
      , x_retcode        => x_retcode ) ;
END fast_expired_lines ;

--
-- Procedure to fast refresh the contract salesrep denormalized table
--
PROCEDURE fast_k_salesreps(  x_errbuf  OUT NOCOPY VARCHAR2
                           , x_retcode OUT NOCOPY VARCHAR2 ) IS
BEGIN
   oki_refresh_pvt.fast_k_salesreps(
        x_errbuf         => x_errbuf
      , x_retcode        => x_retcode ) ;
END fast_k_salesreps ;

--
-- Procedure to fast refresh the addresses denormalized table
--
PROCEDURE fast_addrs(  x_errbuf  OUT NOCOPY VARCHAR2
                     , x_retcode OUT NOCOPY VARCHAR2 ) IS
BEGIN
   oki_refresh_pvt.fast_addrs(
        x_errbuf         => x_errbuf
      , x_retcode        => x_retcode ) ;
END fast_addrs ;

--
-- Procedure to handle the first time fast refresh load
--
PROCEDURE initial_job_check(  x_errbuf  OUT NOCOPY VARCHAR2
                            , x_retcode OUT NOCOPY VARCHAR2 ) IS
BEGIN
   oki_refresh_pvt.initial_job_check(
        x_errbuf         => x_errbuf
      , x_retcode        => x_retcode ) ;
END initial_job_check ;

--
-- Procedure to bring contract pricing rules rand quote to contact information
-- into OKI schema
--
PROCEDURE refresh_k_pricing_rules(  x_errbuf  OUT NOCOPY VARCHAR2
                                  , x_retcode OUT NOCOPY VARCHAR2 ) IS
BEGIN
   oki_refresh_pvt.refresh_k_pricing_rules( x_errbuf         => x_errbuf
                                          , x_retcode        => x_retcode ) ;
END refresh_k_pricing_rules ;

--
-- Procedure to bring contract pricing rules rand quote to contact information into OKI schema
-- for only those contracts whose data has changed between last full or fast refresh and rundate
--
PROCEDURE fast_k_pricing_rules(  x_errbuf  OUT NOCOPY VARCHAR2
						 , x_retcode OUT NOCOPY VARCHAR2 ) IS
BEGIN

    oki_refresh_pvt.fast_k_pricing_rules(  x_errbuf  =>x_errbuf
			           			 , x_retcode =>x_retcode );
END fast_k_pricing_rules;

--
-- Procedure to update Top line price_negotiated amount with
-- sum of covered product line amounts for service contracts.
--
PROCEDURE update_service_line(  x_errbuf  OUT NOCOPY VARCHAR2
						, x_retcode OUT NOCOPY VARCHAR2 )IS
BEGIN
    oki_refresh_pvt.update_service_line(  x_errbuf  => x_errbuf
							     , x_retcode => x_retcode );
END update_service_line;

--
-- Procedure to update Top line price_negotiated amount with
-- sum of covered product line amounts for service contracts.
-- for only those contracts whose data has changed between last full or fast refresh and rundate
--
PROCEDURE fast_update_service_line(  x_errbuf  OUT NOCOPY VARCHAR2
						     , x_retcode OUT NOCOPY VARCHAR2 ) IS
BEGIN
   oki_refresh_pvt. fast_update_service_line(  x_errbuf  => x_errbuf
							          , x_retcode => x_retcode );
END fast_update_service_line;

--
--
--
--
--Procedure to load the job_run_dtl with contracts with currency conversion rate
--information during inital load
PROCEDURE initial_load_job_run_dtl(  p_job_run_id          IN  NUMBER
                                   , p_job_curr_start_date IN  DATE
                                   , p_job_curr_end_date   IN  DATE
                                   ,x_retcode OUT NOCOPY VARCHAR2) IS
 BEGIN
   oki_refresh_pvt.initial_load_job_run_dtl(  p_job_run_id
                                            , p_job_curr_start_date
                                            , p_job_curr_end_date
                                            , x_retcode );
END  initial_load_job_run_dtl;


--Procedure to kick the job start during inital load

PROCEDURE initial_load_job_start(x_errbuf OUT NOCOPY VARCHAR2
                                  ,x_retcode OUT NOCOPY VARCHAR2) IS
BEGIN
   oki_refresh_pvt.initial_load_job_start(  x_errbuf  => x_errbuf
        						          ,x_retcode => x_retcode );
END  initial_load_job_start;


END OKI_REFRESH_PUB;

/
