--------------------------------------------------------
--  DDL for Package AP_WEB_UPLOAD_ACCUM_MILES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_UPLOAD_ACCUM_MILES_PKG" AUTHID CURRENT_USER AS
/* $Header: apwacmus.pls 120.1 2006/07/26 23:08:25 krmenon noship $ */

   g_DebugSwitch      VARCHAR2(1) := 'N';

   PROCEDURE UploadAccumulatedMiles ( P_ErrorBuffer   OUT NOCOPY VARCHAR2,
                                      P_ReturnCode    OUT NOCOPY NUMBER,
                                      P_DataFile      IN VARCHAR2,
                                      P_OrgId         IN NUMBER,
                                      P_PeriodId      IN NUMBER,
                                      P_UOM           IN VARCHAR2,
                                      P_DebugSwitch   IN VARCHAR2);

END AP_WEB_UPLOAD_ACCUM_MILES_PKG; -- Package spec

 

/
