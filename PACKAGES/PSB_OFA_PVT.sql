--------------------------------------------------------
--  DDL for Package PSB_OFA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_OFA_PVT" AUTHID CURRENT_USER as
/* $Header: PSBVFA1S.pls 115.4 2002/11/22 07:39:00 pmamdaba ship $ */
------------------------------------------------------------------------------------------
  description VARCHAR2(60);
  Procedure Set_Flex_Seg_Desc(p_code_combination_id in varchar2, p_segment in varchar2, p_coa_id in varchar2);

  Function Get_Flex_Seg_Desc return varchar2;
  pragma RESTRICT_REFERENCES (Get_Flex_Seg_Desc, WNDS, WNPS );

END PSB_OFA_PVT;

 

/
