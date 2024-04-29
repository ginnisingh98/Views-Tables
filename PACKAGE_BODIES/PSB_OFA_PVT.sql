--------------------------------------------------------
--  DDL for Package Body PSB_OFA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_OFA_PVT" as
/* $Header: PSBVFA1B.pls 115.4 2002/11/22 07:38:55 pmamdaba ship $ */
------------------------------------------------------------------------------------------
Procedure Set_Flex_Seg_Desc(p_code_combination_id in varchar2, p_segment in varchar2,p_coa_id in varchar2) IS
  lv_return   boolean;
  lv_ccid_num number;
  lv_seg_num  number;
  lv_coa_id   number;
Begin
  lv_ccid_num := TO_NUMBER(p_code_combination_id);
  lv_coa_id := TO_NUMBER(p_coa_id);
  select TO_NUMBER(TRANSLATE(p_segment, 'SEGMENT', '0'))
    into lv_seg_num
    from dual;
  lv_return := FND_FLEX_KEYVAL.validate_ccid('SQLGL', 'GL#', lv_coa_id, lv_ccid_num);
  description := FND_FLEX_KEYVAL.segment_description(lv_seg_num);
End;

Function Get_Flex_Seg_Desc return varchar2 IS
  lv_return_text varchar2(150);
Begin
  Return description;
End;

END PSB_OFA_PVT;

/
