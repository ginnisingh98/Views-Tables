--------------------------------------------------------
--  DDL for Package Body EDW_POA_UNSPSC_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_POA_UNSPSC_HOOK" as
/*$Header: poahkunb.pls 115.5 2002/01/24 17:54:37 pkm ship    $ */
function Post_Dim_Collect(p_object_name varchar2) return boolean is
    CURSOR c_items  IS
       Select Function_PK from EDW_SPSC_FUNCTION_LSTG
       where Update_Fact_Flag = 'Y';
    begin
   EDW_OWB_COLLECTION_UTIL.write_to_log_file('Entering UNSPSC Post Dimension Hook Procedure');

   IF (fnd_profile.value('POA_DNB_HOOKS') = 'N') THEN
       EDW_OWB_COLLECTION_UTIL.write_to_log_file('Updating Existing POA facts  to reference UNSPSC Dimension');

       FOR litem in c_items  LOOP
           -- Update all facts

           -- Updating Distribution fact
           Update POA_EDW_PO_DIST_F Fact
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

           -- Update Receiving Fact
           Update POA_EDW_RCV_TXNS_F Fact
           set (UNSPSC_FK_Key) =
               (select UNSPSC.Function_PK_Key
                from EDW_SPSC_FUNCTION_LTC UNSPSC
                where (litem.Function_PK = UNSPSC.Function_PK))
           where (Fact.Item_Revision_FK_Key IN
                  (select IRev.Item_Revision_PK_Key
                   from POA_DNB_ITEMS Com,
                        EdW_Item_ItemRev_LTC IRev,
                        EdW_Item_ItemOrg_LTC IOrg
                   where ((litem.Function_PK = Com.Function) and
                          (Com.Item_PK = IOrg.Item_Number_FK) and
                          (IOrg.Item_Org_PK = IRev.Item_Org_FK))));

           -- Update PO Agreement Lines
           Update POA_EDW_ALINES_F Fact
           set (UNSPSC_FK_Key) =
               (select UNSPSC.Function_PK_Key
                from EDW_SPSC_FUNCTION_LTC UNSPSC
                where (litem.Function_PK = UNSPSC.Function_PK))
           where (Fact.Item_Revision_FK_Key IN
                  (select IRev.Item_Revision_PK_Key
                   from POA_DNB_ITEMS Com,
                        EdW_Item_ItemRev_LTC IRev,
                        EdW_Item_ItemOrg_LTC IOrg
                   where ((litem.Function_PK = Com.Function) and
                          (Com.Item_PK = IOrg.Item_Number_FK) and
                          (IOrg.Item_Org_PK = IRev.Item_Org_FK))));


           -- Update Cutomer Measure Fact
           Update POA_EDW_CSTM_MSR_F Fact
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


           -- Update Supplier Performance
           Update POA_EDW_SUP_PERF_F Fact
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

   EDW_OWB_COLLECTION_UTIL.write_to_log_file('Updated Existing POA Facts');

        -- Call AP to update its Facts
   EDW_OWB_COLLECTION_UTIL.write_to_log_file('Updating FII Facts');

        return EDW_SICM_UNSPSC_HOOK.Post_Dim_Collect(p_object_name);
  ELSE
    EDW_OWB_COLLECTION_UTIL.write_to_log_file('DNB is disabled');
  END IF;

  return true;
end Post_Dim_Collect;

END EDW_POA_UNSPSC_HOOK;


/
