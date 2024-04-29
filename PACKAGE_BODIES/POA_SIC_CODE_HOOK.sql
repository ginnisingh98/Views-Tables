--------------------------------------------------------
--  DDL for Package Body POA_SIC_CODE_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_SIC_CODE_HOOK" as
/*$Header: poahkscb.pls 115.3 2002/01/24 17:54:32 pkm ship    $ */

function Post_Dim_Collect(p_object_name varchar2) return boolean IS
    CURSOR c_sic  IS
       Select SIC_CODE_PK from EDW_SICM_SIC_LSTG
       where Update_Fact_Flag = 'Y';
    begin
   EDW_OWB_COLLECTION_UTIL.write_to_log_file('Entering SIC Code Post Dimension Hook Procedure');

   IF (fnd_profile.value('POA_DNB_HOOKS') = 'N') THEN
       EDW_OWB_COLLECTION_UTIL.write_to_log_file('Updating Exiting POA Facts to reference SIC Code Dimension');

       FOR lsic in c_sic  LOOP
           -- Update all facts

           -- Updating PO Contract Lines
           Update POA_EDW_ALINES_F Fact
           set (SIC_CODE_FK_KEY) =
                (select SIC.SIC_CODE_PK_KEY
                 from EDW_SICM_SIC_LTC SIC
                 where (lsic.SIC_CODE_PK  = SIC.SIC_CODE_PK))
           where (Fact.Supplier_Site_FK_Key IN
                  (select TPartner_Loc_PK_Key
                   from POA_DNB_SIC_CODE Com,
                        POA_DNB_TRD_PRTNR dnb,
                        EDW_TPRT_TPARTNER_LOC_LTC TPrt
                   where ((lsic.SIC_CODE_PK  = Com.SIC_CODE) and
                          (dnb.SIC_CODE = Com.SIC_CODE) and
                          (TPrt.TPartner_Loc_PK = dnb.Trading_Partner_PK))));


             -- Updating PO Contract
           Update POA_EDW_CONTRACT_F Fact
           set (SIC_CODE_FK_KEY) =
                (select SIC.SIC_CODE_PK_KEY
                 from EDW_SICM_SIC_LTC SIC
                 where (lsic.SIC_CODE_PK  = SIC.SIC_CODE_PK))
           where (Fact.Supplier_Site_FK_Key IN
                  (select TPartner_Loc_PK_Key
                   from POA_DNB_SIC_CODE Com,
                        POA_DNB_TRD_PRTNR dnb,
                        EDW_TPRT_TPARTNER_LOC_LTC TPrt
                   where ((lsic.SIC_CODE_PK  = Com.SIC_CODE) and
                          (dnb.SIC_CODE = Com.SIC_CODE) and
                          (TPrt.TPartner_Loc_PK = dnb.Trading_Partner_PK))));


             -- Updating Custom Measure
           Update POA_EDW_CSTM_MSR_F Fact
           set (SIC_CODE_FK_KEY) =
                (select SIC.SIC_CODE_PK_KEY
                 from EDW_SICM_SIC_LTC SIC
                 where (lsic.SIC_CODE_PK  = SIC.SIC_CODE_PK))
           where (Fact.Supplier_Site_FK_Key IN
                  (select TPartner_Loc_PK_Key
                   from POA_DNB_SIC_CODE Com,
                        POA_DNB_TRD_PRTNR dnb,
                        EDW_TPRT_TPARTNER_LOC_LTC TPrt
                   where ((lsic.SIC_CODE_PK  = Com.SIC_CODE) and
                          (dnb.SIC_CODE = Com.SIC_CODE) and
                          (TPrt.TPartner_Loc_PK = dnb.Trading_Partner_PK))));


             -- Updating PO Distributions
           Update POA_EDW_PO_DIST_F Fact
           set (SIC_CODE_FK_KEY) =
                (select SIC.SIC_CODE_PK_KEY
                 from EDW_SICM_SIC_LTC SIC
                 where (lsic.SIC_CODE_PK  = SIC.SIC_CODE_PK))
           where (Fact.Supplier_Site_FK_Key IN
                  (select TPartner_Loc_PK_Key
                   from POA_DNB_SIC_CODE Com,
                        POA_DNB_TRD_PRTNR dnb,
                        EDW_TPRT_TPARTNER_LOC_LTC TPrt
                   where ((lsic.SIC_CODE_PK  = Com.SIC_CODE) and
                          (dnb.SIC_CODE = Com.SIC_CODE) and
                          (TPrt.TPartner_Loc_PK = dnb.Trading_Partner_PK))));


             -- Updating Recieving
           Update POA_EDW_RCV_TXNS_F Fact
           set (SIC_CODE_FK_KEY) =
                (select SIC.SIC_CODE_PK_KEY
                 from EDW_SICM_SIC_LTC SIC
                 where (lsic.SIC_CODE_PK  = SIC.SIC_CODE_PK))
           where (Fact.Supplier_Site_FK_Key IN
                  (select TPartner_Loc_PK_Key
                   from POA_DNB_SIC_CODE Com,
                        POA_DNB_TRD_PRTNR dnb,
                        EDW_TPRT_TPARTNER_LOC_LTC TPrt
                   where ((lsic.SIC_CODE_PK  = Com.SIC_CODE) and
                          (dnb.SIC_CODE = Com.SIC_CODE) and
                          (TPrt.TPartner_Loc_PK = dnb.Trading_Partner_PK))));


             -- Updating Supplier Performance
           Update POA_EDW_SUP_PERF_F Fact
           set (SIC_CODE_FK_KEY) =
                (select SIC.SIC_CODE_PK_KEY
                 from EDW_SICM_SIC_LTC SIC
                 where (lsic.SIC_CODE_PK  = SIC.SIC_CODE_PK))
           where (Fact.Supplier_Site_FK_Key IN
                  (select TPartner_Loc_PK_Key
                   from POA_DNB_SIC_CODE Com,
                        POA_DNB_TRD_PRTNR dnb,
                        EDW_TPRT_TPARTNER_LOC_LTC TPrt
                   where ((lsic.SIC_CODE_PK  = Com.SIC_CODE) and
                          (dnb.SIC_CODE = Com.SIC_CODE) and
                          (TPrt.TPartner_Loc_PK = dnb.Trading_Partner_PK))));

        END LOOP;

       EDW_OWB_COLLECTION_UTIL.write_to_log_file('Updated POA Facts');
  ELSE
       EDW_OWB_COLLECTION_UTIL.write_to_log_file('DNB is disabled');
  END IF;

  return true;
end Post_Dim_Collect;

END POA_SIC_CODE_HOOK;


/
