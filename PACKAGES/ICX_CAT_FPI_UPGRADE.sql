--------------------------------------------------------
--  DDL for Package ICX_CAT_FPI_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_CAT_FPI_UPGRADE" AUTHID CURRENT_USER AS
/* $Header: ICXUPGIS.pls 120.0.12010000.2 2008/08/02 14:38:16 kkram ship $*/

gUpgradeUserId	PLS_INTEGER := -9;

gUpgradePhaseId PLS_INTEGER := -9;
CREATE_PURCHASING_PHASE PLS_INTEGER := -20;


PROCEDURE setLog (pLogLevel	IN NUMBER,
		  pLogFile	IN VARCHAR2);
PROCEDURE startLog;
PROCEDURE EndLog;
PROCEDURE setCommitSize (pCommitSize	IN NUMBER);

FUNCTION getOldPrimaryCategoryId(pRtItemId	IN NUMBER) RETURN NUMBER;
FUNCTION getPrimaryCategoryId(pRtItemId		IN NUMBER) RETURN NUMBER;
PROCEDURE cleanupJobTables;

FUNCTION isAlreadyUpgraded RETURN NUMBER;
PROCEDURE upgrade;
PROCEDURE upgradeFavoriteList;
PROCEDURE rollbackUpgrade;
PROCEDURE updateRequestId;

END ICX_CAT_FPI_UPGRADE;

/
