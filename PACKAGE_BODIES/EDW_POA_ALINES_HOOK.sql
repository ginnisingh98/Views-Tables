--------------------------------------------------------
--  DDL for Package Body EDW_POA_ALINES_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_POA_ALINES_HOOK" as
/*$Header: poahkalb.pls 115.13 2002/01/25 14:02:33 pkm ship    $ */

function Pre_Fact_Collect(p_object_name varchar2) return boolean  is
 begin
   EDW_OWB_COLLECTION_UTIL.write_to_log_file('Entering Agreement Pre Fact Hook Procedure');

   IF (fnd_profile.value('POA_DNB_HOOKS') = 'N') THEN
      EDW_OWB_COLLECTION_UTIL.write_to_log_file('Updating Staging Table to reference UNSPSC Dimension');

      Update POA_EDW_ALINES_FSTG Fact
      set UNSPSC_FK =
          (select Com.Function
           from EdW_Item_ItemRev_LTC IRev,
               EdW_Item_ItemOrg_LTC IOrg,
                POA_DNB_ITEMS Com
           where ((Fact.Item_Revision_FK = IRev.Item_Revision_PK) and
                  (Com.Item_PK = IOrg.Item_Number_FK) and
                 (IOrg.Item_Org_PK = IRev.Item_Org_FK)))
      where ((Fact.Collection_Status = 'READY') and
             (Fact.Item_Revision_FK IN
                      (select IRev.Item_Revision_PK
                       from EdW_Item_ItemRev_LTC IRev,
                            EdW_Item_ItemOrg_LTC IOrg,
                            POA_DNB_ITEMS Com
                       where (Com.Item_PK = IOrg.Item_Number_FK) and
                             (IOrg.Item_Org_PK = IRev.Item_Org_FK))));

      EDW_OWB_COLLECTION_UTIL.write_to_log_file('Updating Staging Tables to reference DUNS and SIC Code Dimension');
      Update POA_EDW_ALINES_FSTG Fact
      set (DUNS_FK, SIC_CODE_FK)  =
          (select Com.DUNS, Com.SIC_Code
          from POA_DNB_TRD_PRTNR Com
          where (Fact.Supplier_Site_FK = Com.Trading_Partner_PK))
      where ((Fact.Collection_Status = 'READY') and
             (Fact.Supplier_Site_FK IN (select Trading_Partner_PK
                                        from POA_DNB_TRD_PRTNR)));
     ELSE
      EDW_OWB_COLLECTION_UTIL.write_to_log_file('DNB is disabled');
     END IF;

     return true;
end Pre_Fact_Collect;

END EDW_POA_ALINES_HOOK;


/
