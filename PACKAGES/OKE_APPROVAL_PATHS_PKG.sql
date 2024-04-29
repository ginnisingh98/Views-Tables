--------------------------------------------------------
--  DDL for Package OKE_APPROVAL_PATHS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_APPROVAL_PATHS_PKG" AUTHID CURRENT_USER AS
/* $Header: OKEAPVPS.pls 120.1 2005/06/02 12:04:08 appldev  $ */

--
-- Table Handler Procedures
--
PROCEDURE INSERT_ROW
( X_ROWID                   IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2
, X_APPROVAL_PATH_ID        IN OUT NOCOPY /* file.sql.39 change */ NUMBER
, X_SIGNATURE_REQUIRED_FLAG IN     VARCHAR2
, X_SIGNATORY_ROLE_ID       IN     NUMBER
, X_NAME                    IN     VARCHAR2
, X_DESCRIPTION             IN     VARCHAR2
, X_START_DATE_ACTIVE       IN     DATE
, X_END_DATE_ACTIVE         IN     DATE
, X_CREATION_DATE           IN     DATE
, X_CREATED_BY              IN     NUMBER
, X_LAST_UPDATE_DATE        IN     DATE
, X_LAST_UPDATED_BY         IN     NUMBER
, X_LAST_UPDATE_LOGIN       IN     NUMBER
, X_RECORD_VERSION_NUMBER   IN OUT NOCOPY /* file.sql.39 change */ NUMBER
);

PROCEDURE LOCK_ROW
( X_APPROVAL_PATH_ID        IN     NUMBER
, X_RECORD_VERSION_NUMBER   IN     NUMBER
);

PROCEDURE UPDATE_ROW
( X_APPROVAL_PATH_ID        IN     NUMBER
, X_SIGNATURE_REQUIRED_FLAG IN     VARCHAR2
, X_SIGNATORY_ROLE_ID       IN     NUMBER
, X_NAME                    IN     VARCHAR2
, X_DESCRIPTION             IN     VARCHAR2
, X_START_DATE_ACTIVE       IN     DATE
, X_END_DATE_ACTIVE         IN     DATE
, X_LAST_UPDATE_DATE        IN     DATE
, X_LAST_UPDATED_BY         IN     NUMBER
, X_LAST_UPDATE_LOGIN       IN     NUMBER
, X_RECORD_VERSION_NUMBER   OUT NOCOPY /* file.sql.39 change */    NUMBER
);

PROCEDURE DELETE_ROW
( X_APPROVAL_PATH_ID        IN     NUMBER
);

PROCEDURE LOAD_ROW
( X_APPROVAL_PATH_ID        IN     NUMBER
, X_NAME                    IN     VARCHAR2
, X_DESCRIPTION             IN     VARCHAR2
, X_SIGNATURE_REQUIRED_FLAG IN     VARCHAR2
, X_SIGNATORY_ROLE_ID       IN     NUMBER
, X_START_DATE_ACTIVE       IN     DATE
, X_END_DATE_ACTIVE         IN     DATE
, X_LAST_UPDATE_DATE        IN     DATE
, X_LAST_UPDATED_BY         IN     NUMBER
, X_CUSTOM_MODE             IN     VARCHAR2
);

PROCEDURE TRANSLATE_ROW
( X_APPROVAL_PATH_ID        IN     NUMBER
, X_NAME                    IN     VARCHAR2
, X_DESCRIPTION             IN     VARCHAR2
, X_LAST_UPDATE_DATE        IN     DATE
, X_LAST_UPDATED_BY         IN     NUMBER
, X_CUSTOM_MODE             IN     VARCHAR2
);

PROCEDURE ADD_LANGUAGE;

--
-- Utility Functions and Procedures
--
FUNCTION Approval_Steps
( ApprovalPath         IN  NUMBER
) RETURN VARCHAR2;

PROCEDURE Next_Approval_Step
( ApprovalSteps        IN  VARCHAR2
, LastApprovalSeq      IN  NUMBER
, ApprovalSeq          OUT NOCOPY /* file.sql.39 change */ NUMBER
, ApproverRole         OUT NOCOPY /* file.sql.39 change */ NUMBER
);

END OKE_APPROVAL_PATHS_PKG;

 

/
