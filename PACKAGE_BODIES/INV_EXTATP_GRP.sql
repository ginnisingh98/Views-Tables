--------------------------------------------------------
--  DDL for Package Body INV_EXTATP_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_EXTATP_GRP" AS
/* $Header: INVGEAPB.pls 120.2 2005/09/20 14:08:40 ichoudhu ship $ */

--
-- Package
--   INV_EXTATP_GRP
-- Purpose
--   External ATP. This function calls the external
--   procedure which will eventually contain the system integrator's
--   code, contained in INV_EXTATP_CALL.External_Atp
-- History
--   07/01/97	rmanjuna           created
--   07/29/97   nsriniva           added functions to support APS integration
--   06/16/99   mpuvathi modifications to the routing cursor in Check_ATP_ATO
--
-- Note
-- 1. Convetion followed for return values of functions :
--  	a. Success is 0
--	b. Failure is 1
--	c. Warning is 2

-- Variables used in this package
v_config_item_id   NUMBER;
v_config_qty       NUMBER;
v_config_item      VARCHAR2(40);

FUNCTION Check_ATP_ATO(
	row_id IN rowid,
	ato_exists OUT NOCOPY VARCHAR2,
	V_Bom_Table IN OUT NOCOPY INV_EXTATP_GRP.Bom_Tab_Typ,
	V_Routing_Table IN OUT NOCOPY INV_EXTATP_GRP.Routing_Tab_Typ)
RETURN BOOLEAN
IS
BEGIN
    return(TRUE);
END Check_ATP_ATO;

FUNCTION Call_ATP(	group_id      number,
			insert_flag   number,
			partial_flag  number,
			mrp_status    number,
			schedule_flag number,
			session_id    number,
			err_message   IN OUT NOCOPY varchar2,
			err_translate IN OUT NOCOPY number)
RETURN NUMBER is
BEGIN
      return(INV_EXTATP_GRP.G_ALL_SUCCESS);
End Call_ATP;

END INV_EXTATP_GRP;

/
