--------------------------------------------------------
--  DDL for Package RLM_CUM_UPGRADE_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RLM_CUM_UPGRADE_SV" AUTHID CURRENT_USER AS
/* $Header: RLMCMUPS.pls 120.0 2005/05/26 17:09:04 appldev noship $ */
/*=============================================================================

PACKAGE NAME: 		rlm_cum_upgrade_sv


DESCRIPTION:		Upgrade API

CLIENT/SERVER:		Server

LIBRARY NAME:		None

OWNER:			MPAREKH




=============================================================================*/

-- Globals

C_SDEBUG	NUMBER := rlm_core_sv.C_LEVEL6;
C_DEBUG		NUMBER := rlm_core_sv.C_LEVEL7;



/*=============================================================================

PROCEDURE NAME: UpgradeCumHistory

DESCRIPTION:


PARAMETERS:
=============================================================================*/

-- Procedure UpgradeCumHistory

PROCEDURE UpgradeCumHistory	;




END RLM_CUM_UPGRADE_SV;
 

/
