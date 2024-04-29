--------------------------------------------------------
--  DDL for Package CSC_CUST_PLANS_AUDIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSC_CUST_PLANS_AUDIT_PKG" AUTHID CURRENT_USER as
/* $Header: csctcpas.pls 120.0 2005/05/30 15:48:36 appldev noship $ */
-- Start of Comments
-- Package name     : CSC_CUST_PLANS_AUDIT_PKG
-- Purpose          : To insert records into CSC_CUST_PLANS_AUDIT table. Wheneven an operation is
--                    is done on the CSC_CUST_PLANS table, a record is inserted into the
--                    CSC_CUST_PLANS_AUDIT table. The PLAN_STATUS_CODE keeps track of what
--                    operation is performed on the CSC_CUST_PLANS table.
--                    ie. APPLIED, ENABLED, DISABLED
--                    NOTE : There is an update, lock and a delete handler available for this table,
--                           but only for future use.
-- History          :
-- MM-DD-YYYY    NAME          MODIFICATIONS
-- 10-29-1999    dejoseph      Created.
-- 12-08-1999    dejoseph      'Arcs'ed in for first code freeze.
-- 12-21-1999    dejoseph      'Arcs'ed in for second code freeze.
-- 01-03-2000    dejoseph      'Arcs'ed in for third code freeze. (10-JAN-2000)
-- 01-31-2000    dejoseph      'Arcs'ed in for fourth code freeze. (07-FEB-2000)
-- 02-13-2000    dejoseph      'Arcs'ed on for fifth code freeze. (21-FEB-2000)
-- 02-28-2000    dejoseph      'Arcs'ed on for sixth code freeze. (06-MAR-2000)
-- 04-10-2000    dejoseph      Removed reference to cust_account_org in lieu of TCA's
--                             decision to drop column org_id from hz_cust_accounts.
-- 10-23-2000    dejoseph      Changed the IN OUT NOCOPY parameter px_plan_audit_id to an
--                             OUT NOCOPY parameter x_plan_audit_id. Fix to bug # 1467071
-- 11-12-2002	 bhroy		NOCOPY changes made
-- 12-03-2002	 bhroy		Added check-in comments WHENEVER OSERROR EXIT FAILURE ROLLBACK
--

-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row (
          --px_PLAN_AUDIT_ID          IN OUT  NOCOPY NUMBER,
          p_PLAN_ID                 IN      NUMBER,
          p_PARTY_ID                IN      NUMBER,
          p_CUST_ACCOUNT_ID         IN      NUMBER,
          --p_CUST_ACCOUNT_ORG        IN      NUMBER,
          p_PLAN_STATUS_CODE        IN      VARCHAR2,
          p_REQUEST_ID              IN      NUMBER,
          p_PROGRAM_APPLICATION_ID  IN      NUMBER,
          p_PROGRAM_ID              IN      NUMBER,
          p_PROGRAM_UPDATE_DATE     IN      DATE,
          p_CREATION_DATE           IN      DATE,
          p_LAST_UPDATE_DATE        IN      DATE,
          p_CREATED_BY              IN      NUMBER,
          p_LAST_UPDATED_BY         IN      NUMBER,
          p_LAST_UPDATE_LOGIN       IN      NUMBER,
          p_ATTRIBUTE1              IN      VARCHAR2,
          p_ATTRIBUTE2              IN      VARCHAR2,
          p_ATTRIBUTE3              IN      VARCHAR2,
          p_ATTRIBUTE4              IN      VARCHAR2,
          p_ATTRIBUTE5              IN      VARCHAR2,
          p_ATTRIBUTE6              IN      VARCHAR2,
          p_ATTRIBUTE7              IN      VARCHAR2,
          p_ATTRIBUTE8              IN      VARCHAR2,
          p_ATTRIBUTE9              IN      VARCHAR2,
          p_ATTRIBUTE10             IN      VARCHAR2,
          p_ATTRIBUTE11             IN      VARCHAR2,
          p_ATTRIBUTE12             IN      VARCHAR2,
          p_ATTRIBUTE13             IN      VARCHAR2,
          p_ATTRIBUTE14             IN      VARCHAR2,
          p_ATTRIBUTE15             IN      VARCHAR2,
          p_ATTRIBUTE_CATEGORY      IN      VARCHAR2,
		x_PLAN_AUDIT_ID           OUT NOCOPY    NUMBER);

PROCEDURE Update_Row(
          p_PLAN_AUDIT_ID            IN  NUMBER,
          p_PLAN_ID                  IN  NUMBER,
          p_PARTY_ID                 IN  NUMBER,
          p_CUST_ACCOUNT_ID          IN  NUMBER,
          --p_CUST_ACCOUNT_ORG         IN  NUMBER,
          p_PLAN_STATUS_CODE         IN  VARCHAR2,
          p_REQUEST_ID               IN  NUMBER,
          p_PROGRAM_APPLICATION_ID   IN  NUMBER,
          p_PROGRAM_ID               IN  NUMBER,
          p_PROGRAM_UPDATE_DATE      IN  DATE,
          p_LAST_UPDATE_DATE         IN  DATE,
          p_LAST_UPDATED_BY          IN  NUMBER,
          p_LAST_UPDATE_LOGIN        IN  NUMBER,
          p_ATTRIBUTE1               IN  VARCHAR2,
          p_ATTRIBUTE2               IN  VARCHAR2,
          p_ATTRIBUTE3               IN  VARCHAR2,
          p_ATTRIBUTE4               IN  VARCHAR2,
          p_ATTRIBUTE5               IN  VARCHAR2,
          p_ATTRIBUTE6               IN  VARCHAR2,
          p_ATTRIBUTE7               IN  VARCHAR2,
          p_ATTRIBUTE8               IN  VARCHAR2,
          p_ATTRIBUTE9               IN  VARCHAR2,
          p_ATTRIBUTE10              IN  VARCHAR2,
          p_ATTRIBUTE11              IN  VARCHAR2,
          p_ATTRIBUTE12              IN  VARCHAR2,
          p_ATTRIBUTE13              IN  VARCHAR2,
          p_ATTRIBUTE14              IN  VARCHAR2,
          p_ATTRIBUTE15              IN  VARCHAR2,
          p_ATTRIBUTE_CATEGORY       IN  VARCHAR2 );

PROCEDURE Lock_Row(
          p_PLAN_AUDIT_ID          IN  NUMBER,
          p_PLAN_ID                IN  NUMBER,
          p_PARTY_ID               IN  NUMBER,
          p_CUST_ACCOUNT_ID        IN  NUMBER,
          --p_CUST_ACCOUNT_ORG       IN  NUMBER,
          p_PLAN_STATUS_CODE       IN  VARCHAR2,
          p_REQUEST_ID             IN  NUMBER,
          p_PROGRAM_APPLICATION_ID IN  NUMBER,
          p_PROGRAM_ID             IN  NUMBER,
          p_PROGRAM_UPDATE_DATE    IN  DATE,
          p_CREATION_DATE          IN  DATE,
          p_LAST_UPDATE_DATE       IN  DATE,
          p_CREATED_BY             IN  NUMBER,
          p_LAST_UPDATED_BY        IN  NUMBER,
          p_LAST_UPDATE_LOGIN      IN  NUMBER,
          p_ATTRIBUTE1             IN  VARCHAR2,
          p_ATTRIBUTE2             IN  VARCHAR2,
          p_ATTRIBUTE3             IN  VARCHAR2,
          p_ATTRIBUTE4             IN  VARCHAR2,
          p_ATTRIBUTE5             IN  VARCHAR2,
          p_ATTRIBUTE6             IN  VARCHAR2,
          p_ATTRIBUTE7             IN  VARCHAR2,
          p_ATTRIBUTE8             IN  VARCHAR2,
          p_ATTRIBUTE9             IN  VARCHAR2,
          p_ATTRIBUTE10            IN  VARCHAR2,
          p_ATTRIBUTE11            IN  VARCHAR2,
          p_ATTRIBUTE12            IN  VARCHAR2,
          p_ATTRIBUTE13            IN  VARCHAR2,
          p_ATTRIBUTE14            IN  VARCHAR2,
          p_ATTRIBUTE15            IN  VARCHAR2,
          p_ATTRIBUTE_CATEGORY     IN  VARCHAR2,
          p_OBJECT_VERSION_NUMBER  IN  NUMBER);

PROCEDURE Delete_Row(
       p_PLAN_AUDIT_ID  NUMBER);

End CSC_CUST_PLANS_AUDIT_PKG;

 

/
