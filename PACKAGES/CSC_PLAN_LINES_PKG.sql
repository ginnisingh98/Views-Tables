--------------------------------------------------------
--  DDL for Package CSC_PLAN_LINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSC_PLAN_LINES_PKG" AUTHID CURRENT_USER as
/* $Header: csctplns.pls 115.12 2002/11/25 08:18:03 bhroy ship $ */
-- Start of Comments
-- Package name     : CSC_PLAN_LINES_PKG
-- Purpose          : Table handler package to performs Inserts, Updates, Deletes and Lock
--                    row operations on the CSC_PLAN_LINES table.
-- History          :
-- MM-DD-YYYY    NAME          MODIFICATIONS
-- 10-21-1999    dejoseph      Created.
-- 12-08-1999    dejoseph      'Arcs'ed in for first code freeze.
-- 12-21-1999    dejoseph      'Arcs'ed in for second code freeze.
-- 01-03-2000    dejoseph      'Arcs'ed in for third code freeze. (10-JAN-2000)
-- 01-31-2000    dejoseph      'Arcs'ed in for fourth code freeze. (07-FEB-2000)
-- 02-13-2000    dejoseph      'Arcs'ed on for fifth code freeze. (21-FEB-2000)
-- 02-28-2000    dejoseph      'Arcs'ed on for sixth code freeze. (06-MAR-2000)
--
-- 08-17-2001    dejoseph      Made the following changes for 11.5.6 to cater to the seeding
--                             of Relationship Plans. Ref Bug # 1895567.
--                             - Added proc load_row to be called for the .lct file (cscpllns.lct)
--                             - added parameter p_application_id to procedure insert_row and
--                               update_row.
-- 11-12-2002	bhroy		NOCOPY changes made
-- 11-25-2002	bhroy		FND_API defaults removed, added WHENEVER OSERROR EXIT FAILURE ROLLBACK
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_LINE_ID              IN OUT NOCOPY  NUMBER,
          p_PLAN_ID               IN      NUMBER,
          p_CONDITION_ID          IN      NUMBER,
          p_CREATION_DATE         IN      DATE,
          p_LAST_UPDATE_DATE      IN      DATE,
          p_CREATED_BY            IN      NUMBER,
          p_LAST_UPDATED_BY       IN      NUMBER,
          p_LAST_UPDATE_LOGIN     IN      NUMBER,
          p_ATTRIBUTE1            IN      VARCHAR2,
          p_ATTRIBUTE2            IN      VARCHAR2,
          p_ATTRIBUTE3            IN      VARCHAR2,
          p_ATTRIBUTE4            IN      VARCHAR2,
          p_ATTRIBUTE5            IN      VARCHAR2,
          p_ATTRIBUTE6            IN      VARCHAR2,
          p_ATTRIBUTE7            IN      VARCHAR2,
          p_ATTRIBUTE8            IN      VARCHAR2,
          p_ATTRIBUTE9            IN      VARCHAR2,
          p_ATTRIBUTE10           IN      VARCHAR2,
          p_ATTRIBUTE11           IN      VARCHAR2,
          p_ATTRIBUTE12           IN      VARCHAR2,
          p_ATTRIBUTE13           IN      VARCHAR2,
          p_ATTRIBUTE14           IN      VARCHAR2,
          p_ATTRIBUTE15           IN      VARCHAR2,
          p_ATTRIBUTE_CATEGORY    IN      VARCHAR2,
	  p_APPLICATION_ID        IN      NUMBER    := NULL,
          X_OBJECT_VERSION_NUMBER OUT NOCOPY     NUMBER);

PROCEDURE Update_Row(
          p_LINE_ID                IN   NUMBER,
          p_PLAN_ID                IN   NUMBER,
          p_CONDITION_ID           IN   NUMBER,
          p_CREATION_DATE          IN   DATE,
          p_LAST_UPDATE_DATE       IN   DATE,
          p_CREATED_BY             IN   NUMBER,
          p_LAST_UPDATED_BY        IN   NUMBER,
          p_LAST_UPDATE_LOGIN      IN   NUMBER,
          p_ATTRIBUTE1             IN   VARCHAR2,
          p_ATTRIBUTE2             IN   VARCHAR2,
          p_ATTRIBUTE3             IN   VARCHAR2,
          p_ATTRIBUTE4             IN   VARCHAR2,
          p_ATTRIBUTE5             IN   VARCHAR2,
          p_ATTRIBUTE6             IN   VARCHAR2,
          p_ATTRIBUTE7             IN   VARCHAR2,
          p_ATTRIBUTE8             IN   VARCHAR2,
          p_ATTRIBUTE9             IN   VARCHAR2,
          p_ATTRIBUTE10            IN   VARCHAR2,
          p_ATTRIBUTE11            IN   VARCHAR2,
          p_ATTRIBUTE12            IN   VARCHAR2,
          p_ATTRIBUTE13            IN   VARCHAR2,
          p_ATTRIBUTE14            IN   VARCHAR2,
          p_ATTRIBUTE15            IN   VARCHAR2,
          p_ATTRIBUTE_CATEGORY     IN   VARCHAR2,
	  p_APPLICATION_ID         IN   NUMBER    := NULL,
          X_OBJECT_VERSION_NUMBER  OUT NOCOPY  NUMBER);

PROCEDURE Lock_Row(
          p_LINE_ID                IN   NUMBER,
          p_PLAN_ID                IN   NUMBER,
          p_CONDITION_ID           IN   NUMBER,
          p_CREATION_DATE          IN   DATE,
          p_LAST_UPDATE_DATE       IN   DATE,
          p_CREATED_BY             IN   NUMBER,
          p_LAST_UPDATED_BY        IN   NUMBER,
          p_LAST_UPDATE_LOGIN      IN   NUMBER,
          p_ATTRIBUTE1             IN   VARCHAR2,
          p_ATTRIBUTE2             IN   VARCHAR2,
          p_ATTRIBUTE3             IN   VARCHAR2,
          p_ATTRIBUTE4             IN   VARCHAR2,
          p_ATTRIBUTE5             IN   VARCHAR2,
          p_ATTRIBUTE6             IN   VARCHAR2,
          p_ATTRIBUTE7             IN   VARCHAR2,
          p_ATTRIBUTE8             IN   VARCHAR2,
          p_ATTRIBUTE9             IN   VARCHAR2,
          p_ATTRIBUTE10            IN   VARCHAR2,
          p_ATTRIBUTE11            IN   VARCHAR2,
          p_ATTRIBUTE12            IN   VARCHAR2,
          p_ATTRIBUTE13            IN   VARCHAR2,
          p_ATTRIBUTE14            IN   VARCHAR2,
          p_ATTRIBUTE15            IN   VARCHAR2,
          p_ATTRIBUTE_CATEGORY     IN   VARCHAR2,
          p_OBJECT_VERSION_NUMBER  IN   NUMBER);

PROCEDURE Delete_Row(
          p_LINE_ID        IN   NUMBER,
          p_plan_id        IN   NUMBER);

PROCEDURE LOAD_ROW (
   P_LINE_ID                IN   NUMBER,
   P_PLAN_ID                IN   NUMBER,
   P_CONDITION_ID           IN   NUMBER,
   P_LAST_UPDATE_DATE       IN   DATE,
   P_LAST_UPDATED_BY        IN   NUMBER,
   P_CREATED_BY             IN   NUMBER,
   P_LAST_UPDATE_LOGIN      IN   NUMBER,
   P_ATTRIBUTE1             IN   VARCHAR2 := NULL,
   P_ATTRIBUTE2             IN   VARCHAR2 := NULL,
   P_ATTRIBUTE3             IN   VARCHAR2 := NULL,
   P_ATTRIBUTE4             IN   VARCHAR2 := NULL,
   P_ATTRIBUTE5             IN   VARCHAR2 := NULL,
   P_ATTRIBUTE6             IN   VARCHAR2 := NULL,
   P_ATTRIBUTE7             IN   VARCHAR2 := NULL,
   P_ATTRIBUTE8             IN   VARCHAR2 := NULL,
   P_ATTRIBUTE9             IN   VARCHAR2 := NULL,
   P_ATTRIBUTE10            IN   VARCHAR2 := NULL,
   P_ATTRIBUTE11            IN   VARCHAR2 := NULL,
   P_ATTRIBUTE12            IN   VARCHAR2 := NULL,
   P_ATTRIBUTE13            IN   VARCHAR2 := NULL,
   P_ATTRIBUTE14            IN   VARCHAR2 := NULL,
   P_ATTRIBUTE15            IN   VARCHAR2 := NULL,
   P_ATTRIBUTE_CATEGORY     IN   VARCHAR2 := NULL,
   P_OBJECT_VERSION_NUMBER  OUT NOCOPY  NUMBER,
   P_APPLICATION_ID         IN   NUMBER,
   P_OWNER                  IN   VARCHAR2 );

End CSC_PLAN_LINES_PKG;

 

/
