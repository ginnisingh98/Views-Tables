--------------------------------------------------------
--  DDL for Package IBY_PSON_CUSTOMIZER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_PSON_CUSTOMIZER_PKG" AUTHID CURRENT_USER AS
/*$Header: ibypsons.pls 120.3.12010000.1 2009/12/02 09:24:39 pschalla noship $*/

------------------------------------------------------------------------
-- I. Constant Declarations
------------------------------------------------------------------------

 G_CUST_PSON_YES      CONSTANT VARCHAR2(10) := 'YES';
 G_CUST_PSON_NO       CONSTANT VARCHAR2(30) := 'NO';

------------------------------------------------------------------------------
-- II.  API Signatures
------------------------------------------------------------------------------


  -- 1. Get_Custom_Tangible_Id
  --
  --   API name        : Get_Custom_Tangible_Id
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Creates customized PSON
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --
  PROCEDURE Get_Custom_Tangible_Id
            (
            p_app_short_name    IN fnd_application.application_short_name%TYPE,
	    p_trxn_extn_id      IN iby_fndcpt_tx_extensions.trxn_extension_id%TYPE,
            x_cust_pson        OUT NOCOPY VARCHAR2,
            x_msg              OUT NOCOPY VARCHAR2
            );

END IBY_PSON_CUSTOMIZER_PKG;

/
