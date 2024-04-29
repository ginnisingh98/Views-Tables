--------------------------------------------------------
--  DDL for Package PON_EMD_PAYMENT_TYPES_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_EMD_PAYMENT_TYPES_UTIL" AUTHID CURRENT_USER AS
/* $Header: ponemdutils.pls 120.0.12010000.2 2010/03/17 09:40:04 puppulur noship $ */

PROCEDURE Insert_Row(
                      X_PAYMENT_TYPE_CODE      IN VARCHAR2,
                      X_ORG_ID                 IN NUMBER,
                      X_NAME                   IN VARCHAR2,
                      X_DESCRIPTION            IN VARCHAR2,
                      X_START_DATE_ACTIVE      IN DATE,
                      X_END_DATE_ACTIVE        IN DATE,
                      X_ENABLED_FLAG           IN VARCHAR2,
                      X_RECEIPT_METHOD_ID      IN NUMBER,
                      X_REFUND_PAYMENT_METHOD  IN VARCHAR2,
                      X_CREATION_DATE          IN VARCHAR2,
                      X_CREATED_BY             IN NUMBER,
                      X_LAST_UPDATE_DATE       IN DATE,
                      X_LAST_UPDATED_BY        IN NUMBER,
                      X_LAST_UPDATE_LOGIN      IN NUMBER,
                      X_REQUEST_ID             IN NUMBER,
                      X_PROGRAM_APPLICATION_ID IN NUMBER,
                      X_PROGRAM_ID			       IN NUMBER,
                      X_PROGRAM_UPDATE_DATE		 IN DATE
                      );

PROCEDURE  Update_Row(
                      X_PAYMENT_TYPE_CODE      IN VARCHAR2,
                      X_ORG_ID                 IN NUMBER,
                      X_NAME                   IN VARCHAR2,
                      X_DESCRIPTION            IN VARCHAR2,
                      X_START_DATE_ACTIVE      IN DATE,
                      X_END_DATE_ACTIVE        IN DATE,
                      X_ENABLED_FLAG           IN VARCHAR2,
                      X_RECEIPT_METHOD_ID      IN NUMBER,
                      X_REFUND_PAYMENT_METHOD  IN VARCHAR2,
                      X_LAST_UPDATE_DATE       IN DATE,
                      X_LAST_UPDATED_BY        IN NUMBER,
                      X_LAST_UPDATE_LOGIN      IN NUMBER,
                      X_REQUEST_ID             IN NUMBER,
                      X_PROGRAM_APPLICATION_ID IN NUMBER,
                      X_PROGRAM_ID			       IN NUMBER,
                      X_PROGRAM_UPDATE_DATE		 IN DATE
                      );

PROCEDURE Translate_Row(
                        X_PAYMENT_TYPE_CODE IN VARCHAR2,
                        X_ORG_ID            IN NUMBER,
                        X_NAME              IN VARCHAR2,
                        X_DESCRIPTION       IN VARCHAR2,
                        X_OWNER             IN VARCHAR2
                       );

PROCEDURE LOAD_ROW(
                    X_PAYMENT_TYPE_CODE      IN VARCHAR2,
                    X_ORG_ID                 IN NUMBER,
                    X_OWNER                  IN VARCHAR2,
                    X_NAME                   IN VARCHAR2,
                    X_DESCRIPTION            IN VARCHAR2,
                    X_START_DATE_ACTIVE      IN DATE,
                    X_END_DATE_ACTIVE        IN DATE,
                    X_ENABLED_FLAG           IN VARCHAR2,
                    X_RECEIPT_METHOD_ID      IN NUMBER,
                    X_REFUND_PAYMENT_METHOD  IN VARCHAR2,
                    X_LAST_UPDATE_DATE       IN DATE,
                    X_LAST_UPDATED_BY        IN NUMBER,
                    X_LAST_UPDATE_LOGIN      IN NUMBER,
                    X_REQUEST_ID             IN NUMBER,
                    X_PROGRAM_APPLICATION_ID IN NUMBER,
                    X_PROGRAM_ID	           IN NUMBER,
                    X_PROGRAM_UPDATE_DATE    IN DATE
                    );

PROCEDURE add_language;

END PON_EMD_PAYMENT_TYPES_UTIL;

/
