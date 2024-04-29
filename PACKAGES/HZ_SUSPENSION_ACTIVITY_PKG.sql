--------------------------------------------------------
--  DDL for Package HZ_SUSPENSION_ACTIVITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_SUSPENSION_ACTIVITY_PKG" AUTHID CURRENT_USER as
/* $Header: ARHSATTS.pls 120.2 2005/10/30 03:54:57 appldev ship $*/
-- Start of Comments
-- Package name     : HZ_SUSPENSION_ACTIVITY_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          p_SUSPENSION_ACTIVITY_ID   NUMBER,
          p_ACTION_EFFECTIVE_ON_DATE    DATE,
          p_ACTION_REASON    VARCHAR2,
          p_ACTION_TYPE    VARCHAR2,
          p_SITE_USE_ID    NUMBER,
          p_CUST_ACCOUNT_ID    NUMBER,
          p_NOTICE_METHOD    VARCHAR2,
          p_NOTICE_RECEIVED_CONFIRMATION    VARCHAR2,
          p_NOTICE_SENT_DATE    DATE,
          p_NOTICE_TYPE    VARCHAR2,
          p_BEGIN_DATE    DATE,
          p_END_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_WH_UPDATE_DATE    DATE);

PROCEDURE Update_Row(
          p_SUSPENSION_ACTIVITY_ID    NUMBER,
          p_ACTION_EFFECTIVE_ON_DATE    DATE,
          p_ACTION_REASON    VARCHAR2,
          p_ACTION_TYPE    VARCHAR2,
          p_SITE_USE_ID    NUMBER,
          p_CUST_ACCOUNT_ID    NUMBER,
          p_NOTICE_METHOD    VARCHAR2,
          p_NOTICE_RECEIVED_CONFIRMATION    VARCHAR2,
          p_NOTICE_SENT_DATE    DATE,
          p_NOTICE_TYPE    VARCHAR2,
          p_BEGIN_DATE    DATE,
          p_END_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_WH_UPDATE_DATE    DATE);

PROCEDURE Lock_Row(
          p_SUSPENSION_ACTIVITY_ID    NUMBER,
          p_ACTION_EFFECTIVE_ON_DATE    DATE,
          p_ACTION_REASON    VARCHAR2,
          p_ACTION_TYPE    VARCHAR2,
          p_SITE_USE_ID    NUMBER,
          p_CUST_ACCOUNT_ID    NUMBER,
          p_NOTICE_METHOD    VARCHAR2,
          p_NOTICE_RECEIVED_CONFIRMATION    VARCHAR2,
          p_NOTICE_SENT_DATE    DATE,
          p_NOTICE_TYPE    VARCHAR2,
          p_BEGIN_DATE    DATE,
          p_END_DATE    DATE,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_REQUEST_ID    NUMBER,
          p_PROGRAM_APPLICATION_ID    NUMBER,
          p_PROGRAM_ID    NUMBER,
          p_PROGRAM_UPDATE_DATE    DATE,
          p_WH_UPDATE_DATE    DATE);

PROCEDURE Delete_Row(
    p_SUSPENSION_ACTIVITY_ID  NUMBER);
End HZ_SUSPENSION_ACTIVITY_PKG;

 

/
