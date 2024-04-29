--------------------------------------------------------
--  DDL for Package EAM_ESTIMATE_ASSOCIATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_ESTIMATE_ASSOCIATIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: EAMTESAS.pls 120.0.12010000.1 2008/11/22 00:20:59 fli noship $ */
-- Start of Comments
-- Package name     : EAM_ESTIMATE_ASSOCIATIONS_PKG
-- Purpose          : Spec of package EAM_ESTIMATE_ASSOCIATIONS_PKG
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE INSERT_ROW(
          px_ESTIMATE_ASSOCIATION_ID  IN OUT NOCOPY NUMBER,
          p_ORGANIZATION_ID                         NUMBER,
          p_ESTIMATE_ID                             NUMBER,
          p_CU_ID                                   NUMBER,
          p_CU_QTY                                  NUMBER,
          p_ACCT_CLASS_CODE                         VARCHAR2,
          p_ACTIVITY_ID                             NUMBER,
          p_ACTIVITY_QTY                            NUMBER,
          p_DIFFICULTY_ID                           NUMBER,
          p_RESOURCE_MULTIPLIER                     NUMBER,
          p_CREATION_DATE                           DATE,
          p_CREATED_BY                              NUMBER,
          p_LAST_UPDATE_DATE                        DATE,
          p_LAST_UPDATED_BY                         NUMBER,
          p_LAST_UPDATE_LOGIN                       NUMBER
          );

PROCEDURE UPDATE_ROW(
          p_ESTIMATE_ASSOCIATION_ID                 NUMBER,
          p_ORGANIZATION_ID                         NUMBER,
          p_ESTIMATE_ID                             NUMBER,
          p_CU_ID                                   NUMBER,
          p_CU_QTY                                  NUMBER,
          p_ACCT_CLASS_CODE                         VARCHAR2,
          p_ACTIVITY_ID                             NUMBER,
          p_ACTIVITY_QTY                            NUMBER,
          p_DIFFICULTY_ID                           NUMBER,
          p_RESOURCE_MULTIPLIER                     NUMBER,
          p_CREATION_DATE                           DATE,
          p_CREATED_BY                              NUMBER,
          p_LAST_UPDATE_DATE                        DATE,
          p_LAST_UPDATED_BY                         NUMBER,
          p_LAST_UPDATE_LOGIN                       NUMBER
          );

PROCEDURE LOCK_ROW(
          p_ESTIMATE_ASSOCIATION_ID                 NUMBER,
          p_ORGANIZATION_ID                         NUMBER,
          p_ESTIMATE_ID                             NUMBER,
          p_CU_ID                                   NUMBER,
          p_CU_QTY                                  NUMBER,
          p_ACCT_CLASS_CODE                         VARCHAR2,
          p_ACTIVITY_ID                             NUMBER,
          p_ACTIVITY_QTY                            NUMBER,
          p_DIFFICULTY_ID                           NUMBER,
          p_RESOURCE_MULTIPLIER                     NUMBER,
          p_CREATION_DATE                           DATE,
          p_CREATED_BY                              NUMBER,
          p_LAST_UPDATE_DATE                        DATE,
          p_LAST_UPDATED_BY                         NUMBER,
          p_LAST_UPDATE_LOGIN                       NUMBER
          );

PROCEDURE DELETE_ROW(
          p_ESTIMATE_ASSOCIATION_ID                 NUMBER
          );

END EAM_ESTIMATE_ASSOCIATIONS_PKG;

/
