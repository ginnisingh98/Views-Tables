--------------------------------------------------------
--  DDL for Package Body EDW_SICM_SIC_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_SICM_SIC_HOOK" AS
/* $Header: FIISICHB.pls 120.0 2002/08/24 05:01:13 appldev noship $ */

  FUNCTION POST_DIM_COLLECT(p_object_name varchar2) RETURN BOOLEAN IS
    CURSOR c_sic  IS
       Select SIC_CODE_PK from EDW_SICM_SIC_LSTG
       where Update_Fact_Flag = 'Y';
  BEGIN

      -- Update AP Facts
      FOR lsic in c_sic  LOOP
           -- Updating FII_AP_HOLD_DATA_F
           Update FII_AP_HOLD_DATA_F Fact
           set (SIC_CODE_FK_KEY) =
                (select SIC.SIC_CODE_PK_KEY
                 from EDW_SICM_SIC_LTC SIC
                 where (lsic.SIC_CODE_PK  = SIC.SIC_CODE_PK))
           where (Fact.Supplier_FK_Key IN
                  (select TPartner_Loc_PK_Key
                   from POA_DNB_SIC_CODE Com,
                        POA_DNB_TRD_PRTNR dnb,
                        EDW_TPRT_TPARTNER_LOC_LTC TPrt
                   where ((lsic.SIC_CODE_PK  = Com.SIC_CODE) and
                          (dnb.SIC_CODE = Com.SIC_CODE) and
                          (TPrt.TPartner_Loc_PK = dnb.Trading_Partner_PK))));

           -- Updating FII_AP_INV_ON_HOLD_F
           Update FII_AP_INV_ON_HOLD_F Fact
           set (SIC_CODE_FK_KEY) =
                (select SIC.SIC_CODE_PK_KEY
                 from EDW_SICM_SIC_LTC SIC
                 where (lsic.SIC_CODE_PK  = SIC.SIC_CODE_PK))
           where (Fact.Supplier_FK_Key IN
                  (select TPartner_Loc_PK_Key
                   from POA_DNB_SIC_CODE Com,
                        POA_DNB_TRD_PRTNR dnb,
                        EDW_TPRT_TPARTNER_LOC_LTC TPrt
                   where ((lsic.SIC_CODE_PK  = Com.SIC_CODE) and
                          (dnb.SIC_CODE = Com.SIC_CODE) and
                          (TPrt.TPartner_Loc_PK = dnb.Trading_Partner_PK))));

           -- Updating FII_AP_INV_LINES_F
           Update FII_AP_INV_LINES_F Fact
           set (SIC_CODE_FK_KEY) =
                (select SIC.SIC_CODE_PK_KEY
                 from EDW_SICM_SIC_LTC SIC
                 where (lsic.SIC_CODE_PK  = SIC.SIC_CODE_PK))
           where (Fact.Supplier_FK_Key IN
                  (select TPartner_Loc_PK_Key
                   from POA_DNB_SIC_CODE Com,
                        POA_DNB_TRD_PRTNR dnb,
                        EDW_TPRT_TPARTNER_LOC_LTC TPrt
                   where ((lsic.SIC_CODE_PK  = Com.SIC_CODE) and
                          (dnb.SIC_CODE = Com.SIC_CODE) and
                          (TPrt.TPartner_Loc_PK = dnb.Trading_Partner_PK))));

           -- Updating FII_AP_INV_PAYMTS_F
           Update FII_AP_INV_PAYMTS_F Fact
           set (SIC_CODE_FK_KEY) =
                (select SIC.SIC_CODE_PK_KEY
                 from EDW_SICM_SIC_LTC SIC
                 where (lsic.SIC_CODE_PK  = SIC.SIC_CODE_PK))
           where (Fact.Supplier_FK_Key IN
                  (select TPartner_Loc_PK_Key
                   from POA_DNB_SIC_CODE Com,
                        POA_DNB_TRD_PRTNR dnb,
                        EDW_TPRT_TPARTNER_LOC_LTC TPrt
                   where ((lsic.SIC_CODE_PK  = Com.SIC_CODE) and
                          (dnb.SIC_CODE = Com.SIC_CODE) and
                          (TPrt.TPartner_Loc_PK = dnb.Trading_Partner_PK))));

           -- Updating FII_AP_SCH_PAYMTS_F
           Update FII_AP_SCH_PAYMTS_F Fact
           set (SIC_CODE_FK_KEY) =
                (select SIC.SIC_CODE_PK_KEY
                 from EDW_SICM_SIC_LTC SIC
                 where (lsic.SIC_CODE_PK  = SIC.SIC_CODE_PK))
           where (Fact.Supplier_FK_Key IN
                  (select TPartner_Loc_PK_Key
                   from POA_DNB_SIC_CODE Com,
                        POA_DNB_TRD_PRTNR dnb,
                        EDW_TPRT_TPARTNER_LOC_LTC TPrt
                   where ((lsic.SIC_CODE_PK  = Com.SIC_CODE) and
                          (dnb.SIC_CODE = Com.SIC_CODE) and
                          (TPrt.TPartner_Loc_PK = dnb.Trading_Partner_PK))));
        END LOOP;

      return POA_SIC_CODE_HOOK.POST_DIM_COLLECT(p_object_name);

  END POST_DIM_COLLECT;

END EDW_SICM_SIC_HOOK;

/
