--------------------------------------------------------
--  DDL for Package Body IBY_PSON_CUSTOMIZER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_PSON_CUSTOMIZER_PKG" AS
/*$Header: ibypsonb.pls 120.3.12010000.1 2009/12/02 09:25:05 pschalla noship $*/

--
-- This procedure can be used for customizing PSON
--
  PROCEDURE Get_Custom_Tangible_Id
            (
            p_app_short_name    IN fnd_application.application_short_name%TYPE,
	    p_trxn_extn_id      IN iby_fndcpt_tx_extensions.trxn_extension_id%TYPE,
            x_cust_pson        OUT NOCOPY VARCHAR2,
            x_msg              OUT NOCOPY VARCHAR2
            )
  IS

  BEGIN
    -- by default this procdeure returns x_msg as CUST_PSON_NO
    -- and x_cust_pson as NULL
    x_msg := G_CUST_PSON_NO;
    x_cust_pson := NULL;

    --
    -- Implent custom code here to retun customized PSON
    -- and set x_msg as CUST_PSON_YES
    -- ORDER_ID,TRXN_REF_NUMBER1 and TRXN_REF_NUMBER2 can be
    -- queried from the table IBY_FNDCPT_TX_EXTENSIONS using TRXN_EXTENSION_ID
    /*
    Example# 1
      x_cust_pson:= p_app_short_name || p_trxn_extn_id;
      x_msg := G_CUST_PSON_YES;

    Example# 2
      x_cust_pson:= p_app_short_name || '_' || p_trxn_extn_id;
      x_msg := G_CUST_PSON_YES;

    */



    -- End custom code

  END Get_Custom_Tangible_Id;


END IBY_PSON_CUSTOMIZER_PKG;

/
