--------------------------------------------------------
--  DDL for Package PQH_DE_GRADE_COMPUTE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_GRADE_COMPUTE" AUTHID CURRENT_USER As
/* $Header: pqhgrdco.pkh 115.2 2002/12/10 06:09:40 vevenkat noship $ */
 Procedure PQH_DE_WC_COMPUTE
 (p_Wrkplc_Vldtn_Ver_Id In  Number,
  P_Business_Group_Id   In  Number,
  P_WC_Grade	        Out NOCOPY Varchar2,
  P_Wc_Case_group       Out NOCOPY Varchar2);

 Procedure PQH_DE_CS_COMPUTE
 (P_GVNumber             In  Number,
  P_CS_Grade	         Out NOCOPY Number  ,
  p_cs_Grdnam            Out NOCOPY Varchar2);

 Function Lookup_Meaning
 (P_Lookup_Type In Varchar2,
  P_Lookup_Code In Varchar2)
  Return Varchar2;

 Function Unfreeze
 (P_Wrkplc_Vldtn_vern_Id In Number)
  Return Varchar2;
 End;

 

/
