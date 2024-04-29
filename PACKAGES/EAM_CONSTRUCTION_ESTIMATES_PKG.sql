--------------------------------------------------------
--  DDL for Package EAM_CONSTRUCTION_ESTIMATES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_CONSTRUCTION_ESTIMATES_PKG" AUTHID CURRENT_USER AS
/* $Header: EAMTCESS.pls 120.0.12010000.2 2008/12/09 21:07:37 devijay noship $ */
-- Start of Comments
-- Package name     : EAM_CONSTRUCTION_ESTIMATES_PKG
-- Purpose          : Spec of package EAM_CONSTRUCTION_ESTIMATES_PKG
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE INSERT_ROW(
          px_ESTIMATE_ID            IN OUT NOCOPY NUMBER,
          p_ORGANIZATION_ID         NUMBER,
          p_ESTIMATE_NUMBER         VARCHAR2,
          p_ESTIMATE_DESCRIPTION    VARCHAR2,
          p_GROUPING_OPTION         NUMBER,
          p_PARENT_WO_ID            NUMBER,
          p_CREATE_PARENT_WO_FLAG   VARCHAR2,
          p_CREATION_DATE           DATE,
          p_CREATED_BY              NUMBER,
          p_LAST_UPDATE_DATE        DATE,
          p_LAST_UPDATED_BY         NUMBER,
          p_LAST_UPDATE_LOGIN       NUMBER,
          p_ATTRIBUTE_CATEGORY      VARCHAR2,
          p_ATTRIBUTE1              VARCHAR2,
          p_ATTRIBUTE2              VARCHAR2,
          p_ATTRIBUTE3              VARCHAR2,
          p_ATTRIBUTE4              VARCHAR2,
          p_ATTRIBUTE5              VARCHAR2,
          p_ATTRIBUTE6              VARCHAR2,
          p_ATTRIBUTE7              VARCHAR2,
          p_ATTRIBUTE8              VARCHAR2,
          p_ATTRIBUTE9              VARCHAR2,
          p_ATTRIBUTE10             VARCHAR2,
          p_ATTRIBUTE11             VARCHAR2,
          p_ATTRIBUTE12             VARCHAR2,
          p_ATTRIBUTE13             VARCHAR2,
          p_ATTRIBUTE14             VARCHAR2,
          p_ATTRIBUTE15             VARCHAR2
          );

PROCEDURE UPDATE_ROW(
          p_ESTIMATE_ID             NUMBER,
          p_ORGANIZATION_ID         NUMBER,
          p_ESTIMATE_NUMBER         VARCHAR2,
          p_ESTIMATE_DESCRIPTION    VARCHAR2,
          p_GROUPING_OPTION         NUMBER,
          p_PARENT_WO_ID            NUMBER,
          p_CREATE_PARENT_WO_FLAG   VARCHAR2,
          p_CREATION_DATE           DATE,
          p_CREATED_BY              NUMBER,
          p_LAST_UPDATE_DATE        DATE,
          p_LAST_UPDATED_BY         NUMBER,
          p_LAST_UPDATE_LOGIN       NUMBER,
          p_ATTRIBUTE_CATEGORY      VARCHAR2,
          p_ATTRIBUTE1              VARCHAR2,
          p_ATTRIBUTE2              VARCHAR2,
          p_ATTRIBUTE3              VARCHAR2,
          p_ATTRIBUTE4              VARCHAR2,
          p_ATTRIBUTE5              VARCHAR2,
          p_ATTRIBUTE6              VARCHAR2,
          p_ATTRIBUTE7              VARCHAR2,
          p_ATTRIBUTE8              VARCHAR2,
          p_ATTRIBUTE9              VARCHAR2,
          p_ATTRIBUTE10             VARCHAR2,
          p_ATTRIBUTE11             VARCHAR2,
          p_ATTRIBUTE12             VARCHAR2,
          p_ATTRIBUTE13             VARCHAR2,
          p_ATTRIBUTE14             VARCHAR2,
          p_ATTRIBUTE15             VARCHAR2
          );

PROCEDURE LOCK_ROW(
          p_ESTIMATE_ID             NUMBER,
          p_ORGANIZATION_ID         NUMBER,
          p_ESTIMATE_NUMBER         VARCHAR2,
          p_ESTIMATE_DESCRIPTION    VARCHAR2,
          p_GROUPING_OPTION         NUMBER,
          p_PARENT_WO_ID            NUMBER,
          p_CREATE_PARENT_WO_FLAG   VARCHAR2,
          p_CREATION_DATE           DATE,
          p_CREATED_BY              NUMBER,
          p_LAST_UPDATE_DATE        DATE,
          p_LAST_UPDATED_BY         NUMBER,
          p_LAST_UPDATE_LOGIN       NUMBER,
          p_ATTRIBUTE_CATEGORY      VARCHAR2,
          p_ATTRIBUTE1              VARCHAR2,
          p_ATTRIBUTE2              VARCHAR2,
          p_ATTRIBUTE3              VARCHAR2,
          p_ATTRIBUTE4              VARCHAR2,
          p_ATTRIBUTE5              VARCHAR2,
          p_ATTRIBUTE6              VARCHAR2,
          p_ATTRIBUTE7              VARCHAR2,
          p_ATTRIBUTE8              VARCHAR2,
          p_ATTRIBUTE9              VARCHAR2,
          p_ATTRIBUTE10             VARCHAR2,
          p_ATTRIBUTE11             VARCHAR2,
          p_ATTRIBUTE12             VARCHAR2,
          p_ATTRIBUTE13             VARCHAR2,
          p_ATTRIBUTE14             VARCHAR2,
          p_ATTRIBUTE15             VARCHAR2
          );

PROCEDURE DELETE_ROW(
          p_ESTIMATE_ID             NUMBER
          );

END EAM_CONSTRUCTION_ESTIMATES_PKG;

/
