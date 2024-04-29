--------------------------------------------------------
--  DDL for Package AS_MC_REPORTING_CURR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_MC_REPORTING_CURR_PKG" AUTHID CURRENT_USER as
/* $Header: asxtmrcs.pls 115.2 2002/11/06 00:54:49 appldev ship $ */
-- Start of Comments
-- Package name     : AS_MC_REPORTING_CURR_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_FROM_CURRENCY    VARCHAR2,
          p_END_DATE_ACTIVE    DATE,
          p_REPORTING_CURRENCY    VARCHAR2,
          p_START_DATE_ACTIVE    DATE,
          px_SETUP_CURRENCY_ID   IN OUT NUMBER,
          p_SECURITY_GROUP_ID    NUMBER);

PROCEDURE Update_Row(
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_FROM_CURRENCY    VARCHAR2,
          p_END_DATE_ACTIVE    DATE,
          p_REPORTING_CURRENCY    VARCHAR2,
          p_START_DATE_ACTIVE    DATE,
          p_SETUP_CURRENCY_ID    NUMBER,
          p_SECURITY_GROUP_ID    NUMBER);

PROCEDURE Lock_Row(
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_FROM_CURRENCY    VARCHAR2,
          p_END_DATE_ACTIVE    DATE,
          p_REPORTING_CURRENCY    VARCHAR2,
          p_START_DATE_ACTIVE    DATE,
          p_SETUP_CURRENCY_ID    NUMBER,
          p_SECURITY_GROUP_ID    NUMBER);

PROCEDURE Delete_Row(
    p_SETUP_CURRENCY_ID  NUMBER);
End AS_MC_REPORTING_CURR_PKG;

 

/
