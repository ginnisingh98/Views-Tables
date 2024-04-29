--------------------------------------------------------
--  DDL for Package Body PA_PROJECT_STATUS_CONTROLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJECT_STATUS_CONTROLS_PKG" as
/* $Header: PASTACTB.pls 120.1 2005/06/30 12:33:04 appldev noship $ */
-- Start of Comments
-- Package name     : PA_PROJECT_STATUS_CONTROLS_PKG
-- Purpose          : Table handler for PA_PROJECT_STATUS_CONTROLS
-- History          : 14-JUL-2000 Mohnish       Created
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'PA_PROJECT_STATUS_CONTROLS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'PASTATCB.pls';

PROCEDURE Delete_Row(
    p_PROJECT_STATUS_CODE  VARCHAR2)
 IS
 BEGIN
   DELETE FROM PA_PROJECT_STATUS_CONTROLS
    WHERE PROJECT_STATUS_CODE = p_PROJECT_STATUS_CODE;
   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;
 EXCEPTION
   When NO_DATA_FOUND then
   null;
 END Delete_Row;

End PA_PROJECT_STATUS_CONTROLS_PKG;

/
