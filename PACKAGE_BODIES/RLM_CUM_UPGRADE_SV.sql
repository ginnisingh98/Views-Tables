--------------------------------------------------------
--  DDL for Package Body RLM_CUM_UPGRADE_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RLM_CUM_UPGRADE_SV" AS
/* $Header: RLMCMUPB.pls 120.0 2005/05/26 17:13:34 appldev noship $ */

--
l_DEBUG NUMBER := NVL(fnd_profile.value('RLM_DEBUG_MODE'),-1);
--
/*=============================================================================

PACKAGE NAME: 		rlm_cum_upgrade_sv


DESCRIPTION:		Upgrade API

CLIENT/SERVER:		Server

LIBRARY NAME:		None

OWNER:			MPAREKH

PROCEDURE/FUNCTION: 	UpgradeCumHistory


=============================================================================*/



/*=============================================================================

PROCEDURE NAME: UpgradeCumHistory

DESCRIPTION:


PARAMETERS:
=============================================================================*/

-- Procedure UpgradeCumHistory

PROCEDURE UpgradeCumHistory
 IS

v_ReturnStatus BOOLEAN;


BEGIN

  IF (l_debug <> -1) THEN
     rlm_core_sv.start_debug;
     rlm_core_sv.dpush(C_SDEBUG,'UpgradeCumHistory');
     rlm_core_sv.dpop(C_DEBUG,'Reset cum completed');
     rlm_core_sv.stop_debug;
  END IF;

END UpgradeCumHistory;

END RLM_CUM_UPGRADE_SV;

/
