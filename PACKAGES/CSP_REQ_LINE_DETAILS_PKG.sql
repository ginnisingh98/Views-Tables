--------------------------------------------------------
--  DDL for Package CSP_REQ_LINE_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_REQ_LINE_DETAILS_PKG" AUTHID CURRENT_USER as
/* $Header: csptrlds.pls 120.0.12010000.2 2011/05/27 10:05:24 vmandava ship $ */
-- Start of Comments
-- Package name     : CSP_REQ_LINE_DETAILS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

TYPE internal_user_hooks_rec IS RECORD
(REQ_LINE_DETAIL_ID NUMBER ,
 REQUIREMENT_LINE_ID   NUMBER ,
 CREATED_BY    NUMBER ,
 CREATION_DATE    DATE ,
 LAST_UPDATED_BY    NUMBER ,
 LAST_UPDATE_DATE    DATE ,
 LAST_UPDATE_LOGIN    NUMBER ,
 SOURCE_TYPE VARCHAR2(30) ,
 SOURCE_ID NUMBER);

user_hook_rec  CSP_REQ_LINE_DETAILS_PKG.internal_user_hooks_rec;

PROCEDURE Insert_Row(
          px_REQ_LINE_DETAIL_ID   IN OUT NOCOPY NUMBER,
          p_REQUIREMENT_LINE_ID   NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_SOURCE_TYPE VARCHAR2,
          p_SOURCE_ID NUMBER,
          p_DML_MODE VARCHAR2 DEFAULT NULL);

PROCEDURE Update_Row(
          px_REQ_LINE_DETAIL_ID   IN OUT NOCOPY NUMBER,
          p_REQUIREMENT_LINE_ID   NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_SOURCE_TYPE VARCHAR2,
          p_SOURCE_ID NUMBER,
          p_DML_MODE VARCHAR2 DEFAULT NULL);

PROCEDURE Lock_Row(
          px_REQ_LINE_DETAIL_ID   IN OUT NOCOPY NUMBER,
          p_REQUIREMENT_LINE_ID   NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_SOURCE_TYPE VARCHAR2,
          p_SOURCE_ID NUMBER
          );

PROCEDURE Delete_Row(
    px_REQ_LINE_DETAIL_ID  NUMBER,
    p_DML_MODE VARCHAR2 DEFAULT NULL);
End CSP_REQ_LINE_DETAILS_PKG;

/
