--------------------------------------------------------
--  DDL for Package Body EDW_POA_CONTRACT_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_POA_CONTRACT_HOOK" as
/*$Header: poahkctb.pls 115.11 2002/01/24 17:54:22 pkm ship    $ */
function Pre_Fact_Collect(p_object_name varchar2) return boolean  is
 begin
   EDW_OWB_COLLECTION_UTIL.write_to_log_file('Entering Contract  Pre Fact Hook Procedure');
   IF (fnd_profile.value('POA_DNB_HOOKS') = 'N') THEN
     EDW_OWB_COLLECTION_UTIL.write_to_log_file('Updating Staging Table to reference DUNS and SIC Code Dimension');

     Update POA_EDW_CONTRACT_FSTG Fact
     set (DUNS_FK, SIC_CODE_FK) =
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

END EDW_POA_CONTRACT_HOOK;


/
