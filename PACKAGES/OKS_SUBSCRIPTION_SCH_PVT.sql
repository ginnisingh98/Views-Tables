--------------------------------------------------------
--  DDL for Package OKS_SUBSCRIPTION_SCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_SUBSCRIPTION_SCH_PVT" AUTHID CURRENT_USER AS
/* $Header: OKSSBSHS.pls 120.0 2005/05/25 17:37:15 appldev noship $ */


  -- GLOBAL VARIABLES
  -------------------------------------------------------------------------------
  G_PKG_NAME	                       CONSTANT VARCHAR2(200) := 'OKS_SUBSCRIPTION_SCH';
  G_APP_NAME_OKS	               CONSTANT VARCHAR2(3)   :=  'OKS';
  G_APP_NAME_OKC	               CONSTANT VARCHAR2(3)   :=  'OKC';
  -------------------------------------------------------------------------------


  -- GLOBAL_MESSAGE_CONSTANTS
  ---------------------------------------------------------------------------------------------
  G_TRUE                       CONSTANT VARCHAR2(1)   :=  OKC_API.G_TRUE;
  G_FALSE                      CONSTANT VARCHAR2(1)   :=  OKC_API.G_FALSE;
  G_RET_STS_SUCCESS		 CONSTANT VARCHAR2(1)   :=  OKC_API.G_RET_STS_SUCCESS;
  G_RET_STS_ERROR		       CONSTANT VARCHAR2(1)   :=  OKC_API.G_RET_STS_ERROR;
  G_RET_STS_UNEXP_ERROR        CONSTANT VARCHAR2(1)   :=  OKC_API.G_RET_STS_UNEXP_ERROR;
  G_UNEXPECTED_ERROR           CONSTANT VARCHAR2(30) := 'OKS_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN              CONSTANT VARCHAR2(30) := 'SQLerrm';
  G_SQLCODE_TOKEN              CONSTANT VARCHAR2(30) := 'SQLcode';
  G_REQUIRED_VALUE      CONSTANT VARCHAR2(30):=OKC_API.G_REQUIRED_VALUE;
  G_COL_NAME_TOKEN      CONSTANT VARCHAR2(30):=OKC_API.G_COL_NAME_TOKEN;
  ---------------------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION 	EXCEPTION;


TYPE var_Type Is Record
(
     num_item       VARCHAR2(5)
);
Type var_tbl is TABLE of var_Type index by binary_integer;

TYPE del_type Is Record
(
   Delivery_date   date,
   start_date      date,
   end_date        date
);

Type del_tbl is TABLE of del_type index by binary_integer;

TYPE pattern_type Is Record
(
   yr_pattern        Varchar2(500),
   mth_pattern       Varchar2(500),
   week_pattern      Varchar2(500),
   wday_pattern      Varchar2(500),
   day_pattern       Varchar2(500)
);


Type pattern_tbl is TABLE of pattern_type index by binary_integer;



Procedure Calc_Delivery_date
(
      p_start_dt	       IN    date
,     p_end_dt                 IN    date
,     p_offset_dy              IN    NUMBER
,     p_freq                   IN    Varchar2
,     p_pattern_tbl            IN    pattern_tbl
,     x_delivery_tbl           OUT   NOCOPY del_tbl
,     x_return_status          OUT   NOCOPY Varchar2
);

FUNCTION GET_WD_DATE(mmyyyy IN VARCHAR2,
                       week  IN NUMBER,
                       dow   IN NUMBER) RETURN DATE;


end OKS_SUBSCRIPTION_SCH_PVT;

 

/
