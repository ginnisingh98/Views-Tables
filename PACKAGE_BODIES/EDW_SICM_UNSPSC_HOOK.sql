--------------------------------------------------------
--  DDL for Package Body EDW_SICM_UNSPSC_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_SICM_UNSPSC_HOOK" AS
/* $Header: FIISPSHB.pls 120.1 2003/06/11 07:01:09 sgautam ship $ */

  FUNCTION POST_DIM_COLLECT(p_object_name varchar2) RETURN BOOLEAN IS
    CURSOR c_items  IS
       Select Function_PK from EDW_SPSC_FUNCTION_LSTG
       where Update_Fact_Flag = 'Y';
    begin
       -- Update all AP Facts
       FOR litem in c_items  LOOP
           -- Modified for bug 2971509
	     Update FII_AP_INV_LINES_F Fact
           set (UNSPSC_FK_Key) =
               (select UNSPSC.Function_PK_Key
                from EDW_SPSC_FUNCTION_LTC UNSPSC
                where (litem.Function_PK = UNSPSC.Function_PK))
           where (Fact.Item_FK_Key IN
                  (select IRev.Item_Revision_PK_Key
                   from POA_DNB_ITEMS Com,
                        EdW_Item_ItemRev_LTC IRev,
                        EdW_Item_ItemOrg_LTC IOrg
                   where ((litem.Function_PK = Com.Function) and
                          (Com.Item_PK = IOrg.Item_Number_FK) and
                          (IOrg.Item_Org_PK = IRev.Item_Org_FK))));

        END LOOP;

  return true;
end Post_Dim_Collect;

END EDW_SICM_UNSPSC_HOOK;

/
