--------------------------------------------------------
--  DDL for Package ASO_BI_APPR_FACT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_BI_APPR_FACT_PVT" AUTHID CURRENT_USER AS
 /* $Header: asovbiaps.pls 115.1 2003/11/06 09:57:31 rkoratag noship $ */


  Procedure Appr_Init_Load ;
  Procedure Rul_Init_load ;
  Procedure Appr_Incremental_Load;
  Procedure Rul_Incremental_load;

END ASO_BI_APPR_FACT_PVT ;

 

/
