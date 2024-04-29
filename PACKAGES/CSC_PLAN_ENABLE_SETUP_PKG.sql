--------------------------------------------------------
--  DDL for Package CSC_PLAN_ENABLE_SETUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSC_PLAN_ENABLE_SETUP_PKG" AUTHID CURRENT_USER as
/* $Header: csctepls.pls 115.6 2002/12/03 08:17:29 bhroy ship $ */
-- Start of Comments
-- Package name     : CSC_PLAN_ENABLE_SETUP_PKG
-- Purpose          : Table handler package to perform inserts, update, deletes and lock
--                    row operations on CSC_PLAN_ENABLE_SETUP table.
-- History          :
-- MM-DD-YYYY    NAME          MODIFICATIONS
-- 01-13-2000    dejoseph      Created.
-- 01-31-2000    dejoseph      'Arcs'ed in for fourth code freeze. (07-FEB-2000)
-- 02-13-2000    dejoseph      'Arcs'ed on for fifth code freeze. (21-FEB-2000)
-- 02-28-2000    dejoseph      'Arcs'ed on for sixth code freeze. (06-MAR-2000)
-- 11-12-2002	 bhroy		NOCOPY changes made
-- 12-03-2002	 bhroy		Added check-in comments, WHENEVER OSERROR EXIT FAILURE ROLLBACK
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          P_FUNCTION_ID               IN  NUMBER,
          P_START_DATE_ACTIVE         IN  DATE,
          P_END_DATE_ACTIVE           IN  DATE,
          P_ON_INSERT_ENABLE_FLAG     IN  VARCHAR2,
          P_ON_UPDATE_ENABLE_FLAG     IN  VARCHAR2,
          P_CUSTOM1_ENABLE_FLAG       IN  VARCHAR2,
          P_CUSTOM2_ENABLE_FLAG       IN  VARCHAR2,
          P_CREATION_DATE             IN  DATE,
          P_LAST_UPDATE_DATE          IN  DATE,
          P_CREATED_BY                IN  NUMBER,
          P_LAST_UPDATED_BY           IN  NUMBER,
          P_LAST_UPDATE_LOGIN         IN  NUMBER,
          P_ATTRIBUTE1                IN  VARCHAR2 := NULL,
          P_ATTRIBUTE2                IN  VARCHAR2 := NULL,
          P_ATTRIBUTE3                IN  VARCHAR2 := NULL,
          P_ATTRIBUTE4                IN  VARCHAR2 := NULL,
          P_ATTRIBUTE5                IN  VARCHAR2 := NULL,
          P_ATTRIBUTE6                IN  VARCHAR2 := NULL,
          P_ATTRIBUTE7                IN  VARCHAR2 := NULL,
          P_ATTRIBUTE8                IN  VARCHAR2 := NULL,
          P_ATTRIBUTE9                IN  VARCHAR2 := NULL,
          P_ATTRIBUTE10               IN  VARCHAR2 := NULL,
          P_ATTRIBUTE11               IN  VARCHAR2 := NULL,
          P_ATTRIBUTE12               IN  VARCHAR2 := NULL,
          P_ATTRIBUTE13               IN  VARCHAR2 := NULL,
          P_ATTRIBUTE14               IN  VARCHAR2 := NULL,
          P_ATTRIBUTE15               IN  VARCHAR2 := NULL,
          P_ATTRIBUTE_CATEGORY        IN  VARCHAR2 := NULL,
		X_ENABLE_SETUP_ID           OUT NOCOPY NUMBER,
		X_OBJECT_VERSION_NUMBER     OUT NOCOPY NUMBER);

PROCEDURE Update_Row(
          P_ENABLE_SETUP_ID           IN  NUMBER,
          P_FUNCTION_ID               IN  NUMBER      := NULL,
          P_START_DATE_ACTIVE         IN  DATE        := NULL,
          P_END_DATE_ACTIVE           IN  DATE        := NULL,
          P_ON_INSERT_ENABLE_FLAG     IN  VARCHAR2    := NULL,
          P_ON_UPDATE_ENABLE_FLAG     IN  VARCHAR2    := NULL,
          P_CUSTOM1_ENABLE_FLAG       IN  VARCHAR2    := NULL,
          P_CUSTOM2_ENABLE_FLAG       IN  VARCHAR2    := NULL,
          P_LAST_UPDATE_DATE          IN  DATE        := NULL,
          P_LAST_UPDATED_BY           IN  NUMBER      := NULL,
          P_LAST_UPDATE_LOGIN         IN  NUMBER      := NULL,
          P_ATTRIBUTE1                IN  VARCHAR2    := NULL,
          P_ATTRIBUTE2                IN  VARCHAR2    := NULL,
          P_ATTRIBUTE3                IN  VARCHAR2    := NULL,
          P_ATTRIBUTE4                IN  VARCHAR2    := NULL,
          P_ATTRIBUTE5                IN  VARCHAR2    := NULL,
          P_ATTRIBUTE6                IN  VARCHAR2    := NULL,
          P_ATTRIBUTE7                IN  VARCHAR2    := NULL,
          P_ATTRIBUTE8                IN  VARCHAR2    := NULL,
          P_ATTRIBUTE9                IN  VARCHAR2    := NULL,
          P_ATTRIBUTE10               IN  VARCHAR2    := NULL,
          P_ATTRIBUTE11               IN  VARCHAR2    := NULL,
          P_ATTRIBUTE12               IN  VARCHAR2    := NULL,
          P_ATTRIBUTE13               IN  VARCHAR2    := NULL,
          P_ATTRIBUTE14               IN  VARCHAR2    := NULL,
          P_ATTRIBUTE15               IN  VARCHAR2    := NULL,
          P_ATTRIBUTE_CATEGORY        IN  VARCHAR2    := NULL,
		P_OBJECT_VERSION_NUMBER   IN  NUMBER,
		X_OBJECT_VERSION_NUMBER   OUT NOCOPY NUMBER);

PROCEDURE Lock_Row(
          P_ENABLE_SETUP_ID           IN  NUMBER,
          P_OBJECT_VERSION_NUMBER     IN  NUMBER);

PROCEDURE Delete_Row(
          P_ENABLE_SETUP_ID           IN  NUMBER,
          P_OBJECT_VERSION_NUMBER     IN  NUMBER);

End CSC_PLAN_ENABLE_SETUP_PKG;

 

/
