--------------------------------------------------------
--  DDL for Package Body CSD_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_DRT_PKG" AS
/* $Header: csddrtpb.pls 120.0.12010000.1 2018/04/26 01:23:37 swai noship $ */

L_PACKAGE      VARCHAR2(100) := 'CSD_DRT_PKG';


PROCEDURE CSD_TCA_DRC(PERSON_ID       IN NUMBER,
                      RESULT_TBL OUT NOCOPY PER_DRT_PKG.RESULT_TBL_TYPE) IS

BEGIN

    NULL;

END CSD_TCA_DRC;



PROCEDURE CSD_HR_DRC(PERSON_ID       IN NUMBER,
                      RESULT_TBL OUT NOCOPY PER_DRT_PKG.RESULT_TBL_TYPE) IS
BEGIN

    NULL;

END CSD_HR_DRC;



PROCEDURE CSD_FND_DRC(PERSON_ID       IN NUMBER,
                      RESULT_TBL OUT NOCOPY PER_DRT_PKG.RESULT_TBL_TYPE) IS
BEGIN

     NULL;

END CSD_FND_DRC;

END CSD_DRT_PKG;

/
