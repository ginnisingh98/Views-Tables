--------------------------------------------------------
--  DDL for Package Body INV_EXTATP_CALL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_EXTATP_CALL" AS
/* $Header: INVEATPB.pls 120.1 2005/06/11 07:58:06 appldev  $ */

--
-- Package
--   INV_EXTATP_CALL
-- Purpose
--   Real Call to External ATP systems
--      v_error_code : INV_EXTATP_GRP.G_ALL_SUCCESS for success,
--                     INV_EXTATP_GRP.G_RETURN_ERROR for failure.
--      v_error_translate : TRUE if Oracle is to translate the message
--                          FALSE if Oracle is to simply display message
--      v_error_message : the name of the message in Oracle
--                        message dictionary if it is to be translated
--                        by calling code. Message text to be displayed
--                        to user if v_error_translate flag is FALSE.
--
-- History
--   09/04/96	nsriniva		Created
--
  PROCEDURE EXTERNAL_ATP(V_Atp_Table IN OUT NOCOPY /* file.sql.39 change */ INV_EXTATP_GRP.Atp_Group_Tab_Typ,
			 V_Bom_Table IN OUT NOCOPY /* file.sql.39 change */ INV_EXTATP_GRP.Bom_Tab_Typ,
			 V_Rtg_Table IN OUT NOCOPY /* file.sql.39 change */ INV_EXTATP_GRP.Routing_Tab_Typ,
		         V_Error_Code OUT NOCOPY /* file.sql.39 change */ number,
			 V_Error_Message OUT NOCOPY /* file.sql.39 change */ varchar2,
			 V_Error_Translate OUT NOCOPY /* file.sql.39 change */ boolean) IS
  BEGIN

	 -- External systems should put their call in here
	 v_error_message := '';
	 v_error_code := INV_EXTATP_GRP.G_ALL_SUCCESS;
	 v_error_translate := TRUE;

      return;
  EXCEPTION
    WHEN OTHERS THEN
      v_error_code := INV_EXTATP_GRP.G_RETURN_ERROR;
	 v_error_message := 'INV_EXTATP_CALL.Atp'|| substr(sqlerrm,1,100);
	 return;
  END EXTERNAL_ATP;

END INV_EXTATP_CALL;

/
