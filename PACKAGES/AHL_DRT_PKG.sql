--------------------------------------------------------
--  DDL for Package AHL_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_DRT_PKG" AUTHID CURRENT_USER AS
/* $Header: AHLDRTPS.pls 120.0.12010000.1 2018/06/04 22:15:05 sracha noship $ */

-- DRC procedure for entity type : HR
-- Does validation of HR person by validating all usages within cMRO
-- and passes back the out variable containing errors/warnings
PROCEDURE AHL_HR_DRC(PERSON_ID       IN NUMBER,
                     RESULT_TBL      OUT NOCOPY PER_DRT_PKG.RESULT_TBL_TYPE);

-- DRC procedure for entity type : FND
-- Does validation of FND userid by validating all usages within cMRO
-- and passes back the out variable containing errors/warnings
PROCEDURE AHL_FND_DRC(PERSON_ID      IN NUMBER,
                      RESULT_TBL     OUT NOCOPY PER_DRT_PKG.RESULT_TBL_TYPE);

-- DRC procedure for entity type : TCA
-- Does validation of TCA partyid by validating all usages within cMRO
-- and passes back the out variable containing errors/warnings
PROCEDURE AHL_TCA_DRC(PERSON_ID      IN NUMBER,
                      RESULT_TBL     OUT NOCOPY PER_DRT_PKG.RESULT_TBL_TYPE);

END AHL_DRT_PKG;

/
