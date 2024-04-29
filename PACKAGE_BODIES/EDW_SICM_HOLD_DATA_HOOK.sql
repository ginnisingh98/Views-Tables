--------------------------------------------------------
--  DDL for Package Body EDW_SICM_HOLD_DATA_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_SICM_HOLD_DATA_HOOK" as
/*$Header: FIIAHDHB.pls 120.0 2002/08/24 04:40:19 appldev noship $ */

FUNCTION Pre_Fact_Collect(p_object_name varchar2) RETURN BOOLEAN IS
begin
  -- Update DUNS
  Update FII_AP_HOLD_DATA_FSTG Fact
  set (DUNS_FK, SIC_CODE_FK) =
      (select Com.DUNS, Com.SIC_Code
       from POA_DNB_TRD_PRTNR Com
       where (Fact.Supplier_FK = Com.Trading_Partner_PK))
  where (Fact.Supplier_FK IN (select Trading_Partner_PK
                              from POA_DNB_TRD_PRTNR));
  return true;
end  Pre_Fact_Collect;

END  EDW_SICM_HOLD_DATA_HOOK;


/