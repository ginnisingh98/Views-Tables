--------------------------------------------------------
--  DDL for Package Body AHL_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_DRT_PKG" AS
/* $Header: AHLDRTPB.pls 120.0.12010000.2 2018/06/09 01:13:40 sracha noship $ */

  G_debug         CONSTANT VARCHAR2(1)  := NVL(fnd_profile.value('AFLOG_ENABLED'), 'N');
  G_pkg_name      CONSTANT VARCHAR2(30) := 'AHL_DRT_PKG';
  G_module_prefix CONSTANT VARCHAR2(50) := 'ahl.plsql.' || G_pkg_name || '.';

-- DRC procedure for entity type : HR
-- Does validation of input HR person by validating all usages within cMRO
-- and passes back the out variable containing errors/warnings
PROCEDURE AHL_HR_DRC(PERSON_ID       IN NUMBER,
                     RESULT_TBL      OUT NOCOPY PER_DRT_PKG.RESULT_TBL_TYPE)
IS
BEGIN
  NULL;

END AHL_HR_DRC;


-- DRC procedure for entity type : FND
-- Does validation of input FND userid by validating all usages within cMRO
-- and passes back the out variable containing errors/warnings
PROCEDURE AHL_FND_DRC(PERSON_ID      IN NUMBER,
                      RESULT_TBL     OUT NOCOPY PER_DRT_PKG.RESULT_TBL_TYPE)
IS
BEGIN
  NULL;

END AHL_FND_DRC;


-- DRC procedure for entity type : TCA
-- Does validation of input TCA partyid by validating all usages within cMRO
-- and passes back the out variable containing errors/warnings
PROCEDURE AHL_TCA_DRC(PERSON_ID      IN NUMBER,
                      RESULT_TBL     OUT NOCOPY PER_DRT_PKG.RESULT_TBL_TYPE)
IS
BEGIN
  NULL;

END AHL_TCA_DRC;

END AHL_DRT_PKG;

/
