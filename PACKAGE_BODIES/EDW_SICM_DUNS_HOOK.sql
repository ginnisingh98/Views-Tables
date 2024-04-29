--------------------------------------------------------
--  DDL for Package Body EDW_SICM_DUNS_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_SICM_DUNS_HOOK" AS
/* $Header: FIIDUNHB.pls 120.1 2003/07/01 06:27:47 sgautam ship $ */

  FUNCTION POST_DIM_COLLECT(p_object_name varchar2) RETURN BOOLEAN IS
    CURSOR c_duns is
    select DUNS.DUNS_NUM_PK_KEY DUNS_NUM_PK_KEY,
	   Tprt.TPartner_Loc_PK_Key TPartner_Loc_PK_Key
    from EDW_DUNS_NUMBER_LSTG lstg,
         EDW_DUNS_NUMBER_LTC DUNS,
	 POA_DNB_TRD_PRTNR Com,
	 EDW_TPRT_TPARTNER_LOC_LTC Tprt
    where lstg.Update_Fact_Flag = 'Y'
    AND   lstg.DUNS_NUM_PK=DUNS.DUNS_NUM_PK
    AND   lstg.DUNS_NUM_PK=Com.DUNS
    AND   Tprt.Tpartner_Loc_PK = Com.TRADING_PARTNER_PK;

    begin

      -- Update AP Facts
       FOR lduns in c_duns  LOOP
           -- Updating FII_AP_HOLD_DATA_F
           Update FII_AP_HOLD_DATA_F Fact
	   set DUNS_FK_KEY = lduns.DUNS_NUM_PK_KEY
	   where Fact.Supplier_FK_Key = lduns.TPartner_Loc_PK_Key;


           -- Updating FII_AP_INV_ON_HOLD_F
           Update FII_AP_INV_ON_HOLD_F Fact
	   set DUNS_FK_KEY = lduns.DUNS_NUM_PK_KEY
	   where Fact.Supplier_FK_Key = lduns.TPartner_Loc_PK_Key;



           -- Updating FII_AP_INV_LINES_F
	   Update FII_AP_INV_LINES_F Fact
	   set DUNS_FK_KEY = lduns.DUNS_NUM_PK_KEY
	   where Fact.Supplier_FK_Key = lduns.TPartner_Loc_PK_Key;



           -- Updating FII_AP_INV_PAYMTS_F
	   Update FII_AP_INV_PAYMTS_F Fact
	   set DUNS_FK_KEY = lduns.DUNS_NUM_PK_KEY
	   where Fact.Supplier_FK_Key = lduns.TPartner_Loc_PK_Key;



           -- Updating FII_AP_SCH_PAYMTS_F
	   Update FII_AP_SCH_PAYMTS_F Fact
	   set DUNS_FK_KEY = lduns.DUNS_NUM_PK_KEY
	   where Fact.Supplier_FK_Key = lduns.TPartner_Loc_PK_Key;


        END LOOP;

  return true;
end Post_Dim_Collect;

END  EDW_SICM_DUNS_HOOK;


/
