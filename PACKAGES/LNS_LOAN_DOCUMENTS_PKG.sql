--------------------------------------------------------
--  DDL for Package LNS_LOAN_DOCUMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."LNS_LOAN_DOCUMENTS_PKG" AUTHID CURRENT_USER AS
/* $Header: LNS_LNDOC_TBLH_S.pls 120.0.12010000.2 2009/05/25 10:24:13 gparuchu ship $ */

/* Insert_Row procedure */
PROCEDURE Insert_Row(
        X_DOCUMENT_ID                   IN OUT NOCOPY NUMBER
        ,P_SOURCE_ID                    IN NUMBER
        ,P_SOURCE_TABLE                 IN VARCHAR2
        ,P_DOCUMENT_TYPE                IN VARCHAR2
        ,P_VERSION                      IN NUMBER
        ,P_DOCUMENT_XML                 IN CLOB
        ,P_CREATION_DATE                IN DATE         DEFAULT NULL
        ,P_CREATED_BY                   IN NUMBER       DEFAULT NULL
        ,P_LAST_UPDATE_DATE             IN DATE         DEFAULT NULL
        ,P_LAST_UPDATED_BY              IN NUMBER       DEFAULT NULL
        ,P_LAST_UPDATE_LOGIN            IN NUMBER       DEFAULT NULL
        ,P_PROGRAM_UPDATE_DATE          IN DATE         DEFAULT NULL
        ,P_PROGRAM_APPLICATION_ID       IN NUMBER       DEFAULT NULL
        ,P_PROGRAM_ID                   IN NUMBER       DEFAULT NULL
        ,P_REQUEST_ID                   IN NUMBER       DEFAULT NULL
        ,P_OBJECT_VERSION_NUMBER        IN NUMBER
	,P_REASON                       IN VARCHAR2     DEFAULT NULL
);

/* Update_Row procedure */
PROCEDURE Update_Row(
        X_DOCUMENT_ID                   IN OUT NOCOPY NUMBER
        ,P_SOURCE_ID                    IN NUMBER
        ,P_SOURCE_TABLE                 IN VARCHAR2
        ,P_DOCUMENT_TYPE                IN VARCHAR2
        ,P_VERSION                      IN NUMBER
        ,P_DOCUMENT_XML                 IN CLOB
        ,P_CREATION_DATE                IN DATE         DEFAULT NULL
        ,P_CREATED_BY                   IN NUMBER       DEFAULT NULL
        ,P_LAST_UPDATE_DATE             IN DATE         DEFAULT NULL
        ,P_LAST_UPDATED_BY              IN NUMBER       DEFAULT NULL
        ,P_LAST_UPDATE_LOGIN            IN NUMBER       DEFAULT NULL
        ,P_PROGRAM_UPDATE_DATE          IN DATE         DEFAULT NULL
        ,P_PROGRAM_APPLICATION_ID       IN NUMBER       DEFAULT NULL
        ,P_PROGRAM_ID                   IN NUMBER       DEFAULT NULL
        ,P_REQUEST_ID                   IN NUMBER       DEFAULT NULL
        ,P_OBJECT_VERSION_NUMBER        IN NUMBER
        ,P_REASON                       IN VARCHAR2     DEFAULT NULL
);

END LNS_LOAN_DOCUMENTS_PKG;


/
