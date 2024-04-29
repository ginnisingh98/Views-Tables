--------------------------------------------------------
--  DDL for Package INV_EXTATP_CALL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_EXTATP_CALL" AUTHID CURRENT_USER AS
/* $Header: INVEATPS.pls 120.1 2005/06/11 08:01:09 appldev  $ */

--
-- Package
--   INV_EXTATP_CALL
-- Purpose
--   Real Call to External ATP systems
-- History
--   09/04/96	nsriniva		Created
--
  PROCEDURE EXTERNAL_ATP(V_Atp_Table IN OUT NOCOPY /* file.sql.39 change */ INV_EXTATP_GRP.Atp_Group_Tab_Typ,
			 V_Bom_Table IN OUT NOCOPY /* file.sql.39 change */ INV_EXTATP_GRP.Bom_Tab_Typ,
			 V_Rtg_Table IN OUT NOCOPY /* file.sql.39 change */ INV_EXTATP_GRP.Routing_Tab_Typ,
		         V_Error_Code OUT NOCOPY /* file.sql.39 change */ number,
			 V_Error_Message OUT NOCOPY /* file.sql.39 change */ varchar2,
			 V_Error_Translate OUT NOCOPY /* file.sql.39 change */ boolean);

END INV_EXTATP_CALL;

 

/
