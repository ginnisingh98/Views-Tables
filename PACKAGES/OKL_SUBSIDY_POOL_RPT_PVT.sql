--------------------------------------------------------
--  DDL for Package OKL_SUBSIDY_POOL_RPT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_SUBSIDY_POOL_RPT_PVT" AUTHID CURRENT_USER AS
 /* $Header: OKLRSIOS.pls 120.3 2007/01/09 12:36:48 udhenuko noship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME                     CONSTANT VARCHAR2(200) := 'OKL_SUBSIDY_POOL_RPT_PVT';
  G_API_TYPE                     CONSTANT VARCHAR2(30)  := '_PVT';
  G_APP_NAME                     CONSTANT   VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_EXCEPTION_HALT_VALIDATION    EXCEPTION;

  TYPE okl_sub_pool_rec IS RECORD (
       id                     okl_subsidy_pools_b.id%TYPE := OKL_API.G_MISS_NUM,
       subsidy_pool_name      okl_subsidy_pools_b.subsidy_pool_name%TYPE := OKL_API.G_MISS_CHAR,
       pool_type_code         okl_subsidy_pools_b.pool_type_code%TYPE := OKL_API.G_MISS_CHAR,
       currency_code          okl_subsidy_pools_b.currency_code%TYPE := OKL_API.G_MISS_CHAR,
       currency_conversion_type okl_subsidy_pools_b.currency_conversion_type%TYPE := OKL_API.G_MISS_CHAR,
       reporting_pool_limit   okl_subsidy_pools_b.reporting_pool_limit%TYPE := OKL_API.G_MISS_NUM,
       effective_from_date    okl_subsidy_pools_b.effective_from_date%TYPE := OKL_API.G_MISS_DATE);
  TYPE subsidy_pool_tbl_type IS TABLE OF okl_sub_pool_rec INDEX BY BINARY_INTEGER;

    --To hold the amounts for the subsidy pool
  TYPE pool_dtl_rec_type IS RECORD (
         reporting_limit         VARCHAR2(2000) := NULL,
         total_budget            VARCHAR2(2000) := NULL,
         remaining_balance       VARCHAR2(2000) := NULL,
         error_message           VARCHAR2(4000) := NULL);

  -- Variables for XML Publisher Report input parameters
  P_POOL_ID     okl_subsidy_pools_b.id%TYPE;
  P_DATE        VARCHAR2(120);
  P_PERCENT     NUMBER;
  P_REMAINING   NUMBER;
  P_CURRENCY    okl_subsidy_pools_b.currency_code%TYPE;
  P_DAYS        NUMBER;
  P_FROM_DATE   VARCHAR2(120);
  P_TO_DATE     VARCHAR2(120);
  P_END_DATE    VARCHAR2(120);

  -------------------------------------------------------------------------------
  -- PROCEDURE POOL_ASSOC_REPORT
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : POOL_ASSOC_REPORT
  -- Description     : Procedure for Subsidy pool association Report Generation
  -- Business Rules  :
  -- Parameters      : required parameters are p_pool_name
  -- Version         : 1.0
  -- History         : 08-Mar-2005 ABINDAL created
  -- End of comments
  -------------------------------------------------------------------------------

  PROCEDURE  POOL_ASSOC_REPORT(x_errbuf    OUT NOCOPY VARCHAR2,
                               x_retcode   OUT NOCOPY NUMBER,
                               p_pool_id IN  okl_subsidy_pools_b.id%TYPE,
                               p_date IN  VARCHAR2);


  -------------------------------------------------------------------------------
  -- PROCEDURE POOL_RECONC_REPORT
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : POOL_RECONC_REPORT
  -- Description     : Procedure for Subsidy pool reconciliation Report Generation
  -- Business Rules  :
  -- Parameters      : required parameters are p_pool_name
  -- Version         : 1.0
  -- History         : 08-Mar-2005 ABINDAL created
  -- End of comments
  -------------------------------------------------------------------------------

  PROCEDURE  POOL_RECONC_REPORT(x_errbuf    OUT NOCOPY VARCHAR2,
                                x_retcode   OUT NOCOPY NUMBER,
                                p_pool_id IN  okl_subsidy_pools_b.id%TYPE,
                                p_from_date IN  VARCHAR2,
                                p_to_date   IN  VARCHAR2);



  -------------------------------------------------------------------------------
  -- PROCEDURE POOL_ATLIMIT_REPORT
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : POOL_ATLIMIT_REPORT
  -- Description     : Procedure for Subsidy pool association Report Generation
  -- Business Rules  :
  -- Parameters      : parameter p_currency is required if p_remaining is entered.
  -- Version         : 1.0
  -- History         : 08-Mar-2005 ABINDAL created
  -- End of comments
  -------------------------------------------------------------------------------

  PROCEDURE  POOL_ATLIMIT_REPORT(x_errbuf   OUT NOCOPY VARCHAR2,
                                 x_retcode    OUT NOCOPY NUMBER,
                                 p_percent    IN   NUMBER,
                                 p_remaining  IN   NUMBER,
                                 p_currency   IN   okl_subsidy_pools_b.currency_code%TYPE,
                                 p_end_date   IN   VARCHAR2,
                                 p_days       IN   NUMBER );

  -------------------------------------------------------------------------------
  -- FUNCTION XML_POOL_ASSOC_REPORT
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : XML_POOL_ASSOC_REPORT
  -- Description     : FUNCTION for Subsidy pool association Report Generation for
  --                   XML Publisher
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 03-Jan-2007 UDHENUKO created.
  -- End of comments
  -------------------------------------------------------------------------------
  FUNCTION  XML_POOL_ASSOC_REPORT RETURN BOOLEAN;

  ---------------------------------------------------------------------------
  -- FUNCTION xml_print_atlimit_detail
  ---------------------------------------------------------------------------
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : xml_print_atlimit_detail
  -- Description     : To insert the At-Limit subsidy pool detail into the
  --                   Global Temporary Table for XML Publisher.
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 03-Jan-2007 UDHENUKO created.
  -- End of comments
  ---------------------------------------------------------------------------
  FUNCTION xml_print_atlimit_detail RETURN BOOLEAN;

  -------------------------------------------------------------------------------
  -- FUNCTION XML_POOL_RECONC_REPORT
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : XML_POOL_RECONC_REPORT
  -- Description     : FUNCTION for Subsidy pool reconciliation Report Generation
  --                   in XML Publisher
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 03-Jan-2007 UDHENUKO created.
  -- End of comments
  -------------------------------------------------------------------------------

  FUNCTION  XML_POOL_RECONC_REPORT RETURN BOOLEAN;
END okl_subsidy_pool_rpt_pvt;

/
