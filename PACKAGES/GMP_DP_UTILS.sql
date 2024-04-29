--------------------------------------------------------
--  DDL for Package GMP_DP_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMP_DP_UTILS" AUTHID CURRENT_USER as
/* $Header: GMPDPUTS.pls 120.1 2005/09/08 06:56:32 rpatangy noship $ */

PROCEDURE opm_forecast_interface (
    errbuf       OUT NOCOPY varchar2,
    retcode      OUT NOCOPY varchar2,
    pforecast    IN VARCHAR2,
    porg_id      IN number ,
    p_user_id    IN number ) ;

PROCEDURE truncate_forecast_names(
  errbuf              OUT NOCOPY VARCHAR2,
  retcode             OUT NOCOPY VARCHAR2,
  p_user_id           IN NUMBER) ;

END gmp_dp_utils;

 

/
