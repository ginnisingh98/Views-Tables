--------------------------------------------------------
--  DDL for Package Body GMO_SETUP_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMO_SETUP_GRP" AS
/* $Header: GMOGSTPB.pls 120.3 2005/08/05 04:18 rahugupt noship $ */


--This function would check if GMO is enabled or not.

FUNCTION IS_GMO_ENABLED RETURN VARCHAR2

IS

BEGIN
	if (FND_PROFILE.VALUE('GMO_ENABLED_FLAG') = GMO_CONSTANTS_GRP.YES) then
		return GMO_CONSTANTS_GRP.YES;
	else
		return GMO_CONSTANTS_GRP.NO;
	end if;

END IS_GMO_ENABLED;

-- this function would check if gmo device functionality is enabled
FUNCTION IS_DEVICE_FUNC_ENABLED RETURN VARCHAR2

IS

BEGIN
	if (IS_GMO_ENABLED = GMO_CONSTANTS_GRP.YES) then
		if (FND_PROFILE.VALUE('GMO_DEVICE_INTG_MODE') in ('AUTO', 'BOTH')) then
			return GMO_CONSTANTS_GRP.YES;
		else
			return GMO_CONSTANTS_GRP.NO;
		end if;
	else
		 return GMO_CONSTANTS_GRP.NO;
	end if;
END;

END GMO_SETUP_GRP;

/
