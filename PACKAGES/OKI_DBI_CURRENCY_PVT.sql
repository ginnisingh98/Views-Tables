--------------------------------------------------------
--  DDL for Package OKI_DBI_CURRENCY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKI_DBI_CURRENCY_PVT" AUTHID CURRENT_USER AS
/* $Header: OKIRICUS.pls 120.0 2005/05/25 17:58:41 appldev noship $ */

  g_chr_id              NUMBER ;
  g_conversion_date     DATE ;
  g_trx_func_rate       NUMBER ;
  g_func_global_rate    NUMBER ;
  g_func_sglobal_rate    NUMBER ;
  g_trx_rate_type       VARCHAR2(30) ;

  FUNCTION get_conversion_date
  (   p_chr_id         IN NUMBER
   ,  p_curr_code      IN VARCHAR2
   ,  p_func_curr_code IN VARCHAR2
   ,  p_creation_date  IN DATE
  ) RETURN DATE PARALLEL_ENABLE;

  FUNCTION get_conversion_date
  (   p_chr_id         IN NUMBER
   ,  p_curr_code      IN VARCHAR2
   ,  p_func_curr_code IN VARCHAR2
   ,  p_creation_date  IN DATE
   ,  p_conversion_date      IN  DATE
   ,  p_conversion_type      IN VARCHAR2
   ,  p_trx_func_rate  in NUMBER
    ) RETURN DATE PARALLEL_ENABLE;

  FUNCTION get_dbi_global_rate
  (   p_chr_id         IN NUMBER
   ,  p_curr_code      IN VARCHAR2
   ,  p_func_curr_code IN VARCHAR2
   ,  p_creation_date  IN DATE
   ,  p_conversion_date      IN  DATE
   ,  p_conversion_type      IN VARCHAR2
   ,  p_trx_func_rate  in NUMBER
  ) RETURN NUMBER PARALLEL_ENABLE ;

  FUNCTION get_dbi_sglobal_rate
  (   p_chr_id         IN NUMBER
   ,  p_curr_code      IN VARCHAR2
   ,  p_func_curr_code IN VARCHAR2
   ,  p_creation_date  IN DATE
   ,  p_conversion_date      IN  DATE
   ,  p_conversion_type      IN VARCHAR2
   ,  p_trx_func_rate  in NUMBER
  ) RETURN NUMBER PARALLEL_ENABLE;

  FUNCTION get_trx_func_rate
  (   p_chr_id         IN NUMBER
   ,  p_curr_code      IN VARCHAR2
   ,  p_func_curr_code IN VARCHAR2
   ,  p_creation_date  IN DATE
   ,  p_conversion_date      IN  DATE
   ,  p_conversion_type      IN VARCHAR2
   ,  p_trx_func_rate  in NUMBER
  ) RETURN NUMBER PARALLEL_ENABLE;

  FUNCTION get_trx_rate_type
  (   p_chr_id         IN NUMBER
   ,  p_curr_code      IN VARCHAR2
   ,  p_func_curr_code IN VARCHAR2
   ,  p_creation_date  IN DATE
   ,  p_conversion_date      IN  DATE
   ,  p_conversion_type      IN VARCHAR2
   ,  p_trx_func_rate  in NUMBER
  ) RETURN VARCHAR2 PARALLEL_ENABLE ;

Function get_conversion_rate ( p_chr_id         IN NUMBER
                            , p_curr_code      IN VARCHAR2
                            , p_func_curr_code IN VARCHAR2
                            , p_creation_date  IN DATE
                            , p_conv_date  IN  DATE
			    , p_conv_type IN VARCHAR2
			    , p_trx_func_rate in NUMBER
   ) RETURN DATE PARALLEL_ENABLE;

FUNCTION get_dbi_global_rate_init
  (   p_chr_id         IN NUMBER
   ,  p_curr_code      IN VARCHAR2
   ,  p_func_curr_code IN VARCHAR2
   ,  p_creation_date  IN DATE
   , p_conv_date  IN  DATE
   , p_conv_type IN VARCHAR2
   , p_trx_func_rate in NUMBER
  ) RETURN NUMBER PARALLEL_ENABLE;


FUNCTION get_dbi_sglobal_rate_init
  (   p_chr_id         IN NUMBER
   ,  p_curr_code      IN VARCHAR2
   ,  p_func_curr_code IN VARCHAR2
   ,  p_creation_date  IN DATE
   , p_conv_date  IN  DATE
   , p_conv_type IN VARCHAR2
   , p_trx_func_rate in NUMBER
  ) RETURN NUMBER PARALLEL_ENABLE;

FUNCTION get_trx_func_rate_init
  (   p_chr_id         IN NUMBER
   ,  p_curr_code      IN VARCHAR2
   ,  p_func_curr_code IN VARCHAR2
   ,  p_creation_date  IN DATE
   , p_conv_date  IN  DATE
   , p_conv_type IN VARCHAR2
   , p_trx_func_rate in NUMBER
  ) RETURN NUMBER PARALLEL_ENABLE;

 FUNCTION get_trx_rate_type_init
  (   p_chr_id         IN NUMBER
   ,  p_curr_code      IN VARCHAR2
   ,  p_func_curr_code IN VARCHAR2
   ,  p_creation_date  IN DATE
   , p_conv_date  IN  DATE
   , p_conv_type IN VARCHAR2
   , p_trx_func_rate in NUMBER
  ) RETURN VARCHAR2 PARALLEL_ENABLE;

FUNCTION get_annualization_factor(p_start_date   DATE,
                                  p_end_date     DATE )	RETURN NUMBER PARALLEL_ENABLE ;

END OKI_DBI_CURRENCY_PVT ;

 

/
