--------------------------------------------------------
--  DDL for Package Body EDW_SICM_INV_LINES_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_SICM_INV_LINES_HOOK" as
/*$Header: FIIAILHB.pls 120.1 2003/07/24 06:37:05 sgautam ship $ */

FUNCTION Pre_Fact_Collect(p_object_name varchar2) RETURN BOOLEAN IS
begin
  -- Update DUNS
  Update FII_AP_INV_LINES_FSTG Fact
  set (DUNS_FK, SIC_CODE_FK) =
      (select Com.DUNS, Com.SIC_Code
       from POA_DNB_TRD_PRTNR Com
       where (Fact.Supplier_FK = Com.Trading_Partner_PK))
  where ((Fact.Collection_Status = 'READY') and
      (Fact.Supplier_FK IN (select Trading_Partner_PK
                              from POA_DNB_TRD_PRTNR)));

 -- Update UNSPSC
 --Bug 3046583
 /* Changed the logic to use data from level tables
   (EdW_Item_ItemRev_LTC,EdW_Item_ItemOrg_LTC)
    rather than star table (EDW_TIME_M) for updating
    Invoice Lines Fact with UNSPC information. */

   Update FII_AP_INV_LINES_FSTG Fact
   set UNSPSC_FK =
      (select Com.Function
       from EdW_Item_ItemRev_LTC IRev,
            EdW_Item_ItemOrg_LTC IOrg,
            POA_DNB_ITEMS Com
       where ((Fact.Item_FK = IRev.Item_Revision_PK) and
              (IOrg.Item_Org_PK=IRev.Item_Org_FK) and
              (IOrg.Item_Number_FK = Com.Item_PK)))
   where ((Fact.Collection_Status = 'READY') and
       (Fact.Item_FK IN (select IRev.Item_Revision_PK
                           from EdW_Item_ItemRev_LTC IRev,
                                EdW_Item_ItemOrg_LTC IOrg,
                                POA_DNB_ITEMS Com
                           where (IOrg.Item_Number_FK = Com.Item_PK) and
			         (IOrg.Item_Org_PK=IRev.Item_Org_FK))));

  return true;
end  Pre_Fact_Collect;
END EDW_SICM_INV_LINES_HOOK;


/
