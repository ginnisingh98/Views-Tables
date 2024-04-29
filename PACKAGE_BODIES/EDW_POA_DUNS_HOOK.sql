--------------------------------------------------------
--  DDL for Package Body EDW_POA_DUNS_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_POA_DUNS_HOOK" as
/*$Header: poahkdnb.pls 115.4 2002/01/24 17:54:25 pkm ship    $ */

function Post_Dim_Collect(p_object_name varchar2) return boolean is
    CURSOR c_duns  IS
       Select DUNS_NUM_PK from EDW_DUNS_NUMBER_LSTG
       where Update_Fact_Flag = 'Y';
    begin
   EDW_OWB_COLLECTION_UTIL.write_to_log_file('Entering  Duns Post Dimension Hook rocedure');

   IF (fnd_profile.value('POA_DNB_HOOKS') = 'N') THEN
       EDW_OWB_COLLECTION_UTIL.write_to_log_file('Updating Exisiting POA Facts to refer to DUNS Dimension');

       FOR lduns in c_duns  LOOP
           -- Update all facts

           -- Updating PO Contract Lines
           Update POA_EDW_ALINES_F Fact
           set (DUNS_FK_KEY) =
                (select DUNS.DUNS_NUM_PK_KEY
                 from EDW_DUNS_NUMBER_LTC DUNS
                 where (lduns.DUNS_NUM_PK  = DUNS.DUNS_NUM_PK))
           where (Fact.Supplier_Site_FK_Key IN
                  (select TPartner_Loc_PK_Key
                   from POA_DNB_TRD_PRTNR Com,
                        EDW_TPRT_TPARTNER_LOC_LTC TPrt
                   where ((lduns.DUNS_NUM_PK  = Com.DUNS) and
                          (TPrt.TPartner_Loc_PK = Com.TRADING_PARTNER_PK))));


             -- Updating PO Contract
           Update POA_EDW_CONTRACT_F Fact
           set (DUNS_FK_KEY) =
                (select DUNS.DUNS_NUM_PK_KEY
                 from EDW_DUNS_NUMBER_LTC DUNS
                 where (lduns.DUNS_NUM_PK  = DUNS.DUNS_NUM_PK))
           where (Fact.Supplier_Site_FK_Key IN
                  (select TPartner_Loc_PK_Key
                   from POA_DNB_TRD_PRTNR Com,
                        EDW_TPRT_TPARTNER_LOC_LTC TPrt
                   where ((lduns.DUNS_NUM_PK  = Com.DUNS) and
                          (TPrt.TPartner_Loc_PK = Com.TRADING_PARTNER_PK))));

             -- Updating Custom Measure
           Update POA_EDW_CSTM_MSR_F Fact
           set (DUNS_FK_KEY) =
                (select DUNS.DUNS_NUM_PK_KEY
                 from EDW_DUNS_NUMBER_LTC DUNS
                 where (lduns.DUNS_NUM_PK  = DUNS.DUNS_NUM_PK))
           where (Fact.Supplier_Site_FK_Key IN
                  (select TPartner_Loc_PK_Key
                   from POA_DNB_TRD_PRTNR Com,
                        EDW_TPRT_TPARTNER_LOC_LTC TPrt
                   where ((lduns.DUNS_NUM_PK  = Com.DUNS) and
                          (TPrt.TPartner_Loc_PK = Com.TRADING_PARTNER_PK))));

             -- Updating PO Distributions
           Update POA_EDW_PO_DIST_F Fact
           set (DUNS_FK_KEY) =
                (select DUNS.DUNS_NUM_PK_KEY
                 from EDW_DUNS_NUMBER_LTC DUNS
                 where (lduns.DUNS_NUM_PK  = DUNS.DUNS_NUM_PK))
           where (Fact.Supplier_Site_FK_Key IN
                  (select TPartner_Loc_PK_Key
                   from POA_DNB_TRD_PRTNR Com,
                        EDW_TPRT_TPARTNER_LOC_LTC TPrt
                   where ((lduns.DUNS_NUM_PK  = Com.DUNS) and
                          (TPrt.TPartner_Loc_PK = Com.TRADING_PARTNER_PK))));

             -- Updating Recieving
           Update POA_EDW_RCV_TXNS_F Fact
           set (DUNS_FK_KEY) =
                (select DUNS.DUNS_NUM_PK_KEY
                 from EDW_DUNS_NUMBER_LTC DUNS
                 where (lduns.DUNS_NUM_PK  = DUNS.DUNS_NUM_PK))
           where (Fact.Supplier_Site_FK_Key IN
                  (select TPartner_Loc_PK_Key
                   from POA_DNB_TRD_PRTNR Com,
                        EDW_TPRT_TPARTNER_LOC_LTC TPrt
                   where ((lduns.DUNS_NUM_PK  = Com.DUNS) and
                          (TPrt.TPartner_Loc_PK = Com.TRADING_PARTNER_PK))));

             -- Updating Supplier Performance
           Update POA_EDW_SUP_PERF_F Fact
           set (DUNS_FK_KEY) =
                (select DUNS.DUNS_NUM_PK_KEY
                 from EDW_DUNS_NUMBER_LTC DUNS
                 where (lduns.DUNS_NUM_PK  = DUNS.DUNS_NUM_PK))
           where (Fact.Supplier_Site_FK_Key IN
                  (select TPartner_Loc_PK_Key
                   from POA_DNB_TRD_PRTNR Com,
                        EDW_TPRT_TPARTNER_LOC_LTC TPrt
                   where ((lduns.DUNS_NUM_PK  = Com.DUNS) and
                          (TPrt.TPartner_Loc_PK = Com.TRADING_PARTNER_PK))));

        END LOOP;
   EDW_OWB_COLLECTION_UTIL.write_to_log_file('Updated POA Facts');
   EDW_OWB_COLLECTION_UTIL.write_to_log_file('Updating FII Facts to refer to DUNS Dimension');
        -- Call AP to update its Facts
        return EDW_SICM_DUNS_HOOK.Post_Dim_Collect(p_object_name);
  ELSE
      EDW_OWB_COLLECTION_UTIL.write_to_log_file('DNB is disabled');
  END IF;

  return true;
end Post_Dim_Collect;

END EDW_POA_DUNS_HOOK;


/
