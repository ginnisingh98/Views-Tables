--------------------------------------------------------
--  DDL for Package CSC_PROF_MODULE_GROUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSC_PROF_MODULE_GROUPS_PKG" AUTHID CURRENT_USER as
/* $Header: csctpmgs.pls 115.14 2002/12/09 08:43:06 agaddam ship $ */
-- Start of Comments
-- Package name     : CSC_PROF_MODULE_GROUPS_PKG
-- Purpose          :
-- History          :
--  03 Nov 00 axsubram Added load_row for NLS (# 1487333)
--  26 Nov 02 JAmose  Addition of NOCOPY and the Removal of Fnd_Api.G_MISS*
--                    from the definition for the performance reason
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_MODULE_GROUP_ID   IN OUT NOCOPY NUMBER,
          p_FORM_FUNCTION_ID    NUMBER,
          p_FORM_FUNCTION_NAME  VARCHAR2,
          p_RESPONSIBILITY_ID    NUMBER,
          p_RESP_APPL_ID    NUMBER,
          p_PARTY_TYPE          VARCHAR2,
          p_GROUP_ID            NUMBER,
          p_DASHBOARD_GROUP_FLAG    VARCHAR2,
          p_CURRENCY_CODE       VARCHAR2,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY     NUMBER,
          p_CREATION_DATE       DATE,
          p_CREATED_BY          NUMBER,
          p_LAST_UPDATE_LOGIN   NUMBER,
          p_SEEDED_FLAG         VARCHAR2,
          p_APPLICATION_ID      NUMBER,
          p_DASHBOARD_GROUP_ID  NUMBER);

PROCEDURE Update_Row(
          p_MODULE_GROUP_ID     NUMBER,
          p_FORM_FUNCTION_ID    NUMBER,
          p_FORM_FUNCTION_NAME  VARCHAR2,
          p_RESPONSIBILITY_ID    NUMBER,
          p_RESP_APPL_ID    NUMBER,
          p_PARTY_TYPE          VARCHAR2,
          p_GROUP_ID            NUMBER,
          p_DASHBOARD_GROUP_FLAG    VARCHAR2,
          p_CURRENCY_CODE       VARCHAR2,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY     NUMBER,
          p_LAST_UPDATE_LOGIN   NUMBER,
          p_SEEDED_FLAG         VARCHAR2,
          p_APPLICATION_ID      NUMBER,
          p_DASHBOARD_GROUP_ID  NUMBER);

PROCEDURE Lock_Row(
          p_MODULE_GROUP_ID     NUMBER,
          p_FORM_FUNCTION_ID    NUMBER,
          p_FORM_FUNCTION_NAME  VARCHAR2,
          p_RESPONSIBILITY_ID    NUMBER,
          p_RESP_APPL_ID    NUMBER,
          p_PARTY_TYPE          VARCHAR2,
          p_GROUP_ID            NUMBER,
          p_DASHBOARD_GROUP_FLAG    VARCHAR2,
          p_CURRENCY_CODE       VARCHAR2,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY     NUMBER,
          p_CREATION_DATE       DATE,
          p_CREATED_BY          NUMBER,
          p_LAST_UPDATE_LOGIN   NUMBER,
          p_SEEDED_FLAG         VARCHAR2,
          p_APPLICATION_ID      NUMBER,
          p_DASHBOARD_GROUP_ID  NUMBER);

PROCEDURE Delete_Row(
    p_MODULE_GROUP_ID  NUMBER);

PROCEDURE Load_Row(
          p_MODULE_GROUP_ID     NUMBER,
          p_FORM_FUNCTION_ID    NUMBER,
          p_FORM_FUNCTION_NAME  VARCHAR2,
          p_RESPONSIBILITY_ID    NUMBER := NULL,
          p_RESP_APPL_ID    NUMBER := NULL,
          p_PARTY_TYPE          VARCHAR2,
          p_GROUP_ID            NUMBER,
          p_DASHBOARD_GROUP_FLAG    VARCHAR2,
          p_CURRENCY_CODE       VARCHAR2,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY     NUMBER,
          p_LAST_UPDATE_LOGIN   NUMBER,
          p_SEEDED_FLAG         VARCHAR2,
          p_APPLICATION_ID      NUMBER,
          p_DASHBOARD_GROUP_ID  NUMBER,
       	  P_Owner	        VARCHAR2);

End CSC_PROF_MODULE_GROUPS_PKG;

 

/
