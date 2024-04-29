--------------------------------------------------------
--  DDL for Package CSC_PLAN_HEADERS_B_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSC_PLAN_HEADERS_B_PKG" AUTHID CURRENT_USER as
/* $Header: csctrlps.pls 115.18 2002/11/25 07:54:55 bhroy ship $ */
-- Start of Comments
-- Package name     : CSC_PLAN_HEADERS_B_PKG
-- Purpose          : Table handler for CSC_PLAN_HEADER_B. Contains procedure to INSERT,
--                    UPDATE, DISABLE, LOCK records in CSC_PLAN_HEADER_B table.
-- History          :
-- MM-DD-YYYY    NAME          MODIFICATIONS
-- 10-14-1999    dejoseph      Created.
-- 12-08-1999    dejoseph      'Arcs'ed in for first code freeze.
-- 12-21-1999    dejoseph      'Arcs'ed in for second code freeze.
-- 01-03-2000    dejoseph      'Arcs'ed in for third code freeze. (10-JAN-2000)
-- 01-31-2000    dejoseph      'Arcs'ed in for fourth code freeze. (07-FEB-2000)
-- 02-13-2000    dejoseph      'Arcs'ed on for fifth code freeze. (21-FEB-2000)
-- 02-28-2000    dejoseph      'Arcs'ed on for sixth code freeze. (06-MAR-2000)
-- 04-05-2000    dejoseph      Added ADD_LANGUAGE procedure. This proc. is used to
--                             restore data integrity to a corrupted base/translation
--                             pair and also called from $CSC_TOP/admin/sql/CSCNLADD.sql
--                             and $CSC_TOP/sql/CSCNLINS.sql to do inserts into the TL
--                             tables when a new languages is added in the database.
-- 11-08-2000    madhavan      Added procedures TRANSLATE_ROW and LOAD_ROW. Fix to
--                             bug # 1491195. (load_row is added now itself to follow
--                             standards and to take care of future requirements to add
--                             Relationship Plans' seed data)
-- 01-18-2001    dejoseph      Added parameter "P_NAME" to procedure TRANSLATE_ROW.
-- 08-17-2001    dejoseph      Made the following changes for 11.5.6 to cater to seeding
--                             Relationship Plans: Reference bug # 1895567
--                             - Added p_application_id in procedure insert_row
--                             - Added p_application_id in procedure update_row
--                             - Performed check (if l_user_id = 1, then seeded_flag = Y)
--                               in procedure insert_row, update_row and load_row.
--                             - In procedure translate_row, changed data type of start and
--                               end_date_active to varchar2 from date. The conversion to
--                               date is done here as it cannot be done in the .lct file.
-- 02-18-2002    dejoseph      Added changes to uptake new functionality for 11.5.8.
--                             Ct. / Agent facing application
--                             - Added new IN parameter END_USER_TYPE
--                             Added the dbdrv command.
-- 05-23-2002    dejoseph      Added checkfile syntax.
-- 11-12-2002	 bhroy		NOCOPY changes made
-- 11-25-2002	 bhroy		FND_API default removed, added WHENEVER OSERROR EXIT FAILURE ROLLBACK
--
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_PLAN_ID                 IN OUT NOCOPY NUMBER,
          p_ORIGINAL_PLAN_ID         IN     NUMBER,
          p_PLAN_GROUP_CODE          IN     VARCHAR2,
          p_START_DATE_ACTIVE        IN     DATE,
          p_END_DATE_ACTIVE          IN     DATE,
          p_USE_FOR_CUST_ACCOUNT     IN     VARCHAR2,
          p_END_USER_TYPE            IN     VARCHAR2 := NULL,
          p_CUSTOMIZED_PLAN          IN     VARCHAR2,
          p_PROFILE_CHECK_ID         IN     NUMBER,
          p_RELATIONAL_OPERATOR      IN     VARCHAR2,
          p_CRITERIA_VALUE_HIGH      IN     VARCHAR2,
          p_CRITERIA_VALUE_LOW       IN     VARCHAR2,
          p_CREATION_DATE            IN     DATE,
          p_LAST_UPDATE_DATE         IN     DATE,
          p_CREATED_BY               IN     NUMBER,
          p_LAST_UPDATED_BY          IN     NUMBER,
          p_LAST_UPDATE_LOGIN        IN     NUMBER,
          p_ATTRIBUTE1               IN     VARCHAR2,
          p_ATTRIBUTE2               IN     VARCHAR2,
          p_ATTRIBUTE3               IN     VARCHAR2,
          p_ATTRIBUTE4               IN     VARCHAR2,
          p_ATTRIBUTE5               IN     VARCHAR2,
          p_ATTRIBUTE6               IN     VARCHAR2,
          p_ATTRIBUTE7               IN     VARCHAR2,
          p_ATTRIBUTE8               IN     VARCHAR2,
          p_ATTRIBUTE9               IN     VARCHAR2,
          p_ATTRIBUTE10              IN     VARCHAR2,
          p_ATTRIBUTE11              IN     VARCHAR2,
          p_ATTRIBUTE12              IN     VARCHAR2,
          p_ATTRIBUTE13              IN     VARCHAR2,
          p_ATTRIBUTE14              IN     VARCHAR2,
          p_ATTRIBUTE15              IN     VARCHAR2,
          p_ATTRIBUTE_CATEGORY       IN     VARCHAR2,
          P_DESCRIPTION              IN     VARCHAR2,
          P_NAME                     IN     VARCHAR2,
	  P_APPLICATION_ID           IN     NUMBER    := NULL,
          X_OBJECT_VERSION_NUMBER    OUT NOCOPY    NUMBER );

PROCEDURE Update_Row(
          p_PLAN_ID                  IN   NUMBER,
          p_ORIGINAL_PLAN_ID         IN   NUMBER,
          p_PLAN_GROUP_CODE          IN   VARCHAR2,
          p_START_DATE_ACTIVE        IN   DATE,
          p_END_DATE_ACTIVE          IN   DATE,
          p_USE_FOR_CUST_ACCOUNT     IN   VARCHAR2,
          p_END_USER_TYPE            IN   VARCHAR2 := NULL,
          p_CUSTOMIZED_PLAN          IN   VARCHAR2,
          p_PROFILE_CHECK_ID         IN   NUMBER,
          p_RELATIONAL_OPERATOR      IN   VARCHAR2,
          p_CRITERIA_VALUE_HIGH      IN   VARCHAR2,
          p_CRITERIA_VALUE_LOW       IN   VARCHAR2,
          p_LAST_UPDATE_DATE         IN   DATE,
          p_LAST_UPDATED_BY          IN   NUMBER,
          p_LAST_UPDATE_LOGIN        IN   NUMBER,
          p_ATTRIBUTE1               IN   VARCHAR2,
          p_ATTRIBUTE2               IN   VARCHAR2,
          p_ATTRIBUTE3               IN   VARCHAR2,
          p_ATTRIBUTE4               IN   VARCHAR2,
          p_ATTRIBUTE5               IN   VARCHAR2,
          p_ATTRIBUTE6               IN   VARCHAR2,
          p_ATTRIBUTE7               IN   VARCHAR2,
          p_ATTRIBUTE8               IN   VARCHAR2,
          p_ATTRIBUTE9               IN   VARCHAR2,
          p_ATTRIBUTE10              IN   VARCHAR2,
          p_ATTRIBUTE11              IN   VARCHAR2,
          p_ATTRIBUTE12              IN   VARCHAR2,
          p_ATTRIBUTE13              IN   VARCHAR2,
          p_ATTRIBUTE14              IN   VARCHAR2,
          p_ATTRIBUTE15              IN   VARCHAR2,
          p_ATTRIBUTE_CATEGORY       IN   VARCHAR2,
          P_DESCRIPTION              IN   VARCHAR2,
          P_NAME                     IN   VARCHAR2,
	  P_APPLICATION_ID           IN   NUMBER    := NULL,
          X_OBJECT_VERSION_NUMBER    OUT NOCOPY  NUMBER );

PROCEDURE Lock_Row(
   p_PLAN_ID                  IN   NUMBER,
   p_OBJECT_VERSION_NUMBER    IN   NUMBER );

PROCEDURE Disable_Row(
          P_PLAN_ID                  IN   NUMBER);

PROCEDURE ADD_LANGUAGE;

PROCEDURE TRANSLATE_ROW(
   p_plan_id       IN   NUMBER,
   p_name          IN   VARCHAR2,
   p_description   IN   VARCHAR2,
   p_owner         IN   VARCHAR2) ;

PROCEDURE LOAD_ROW (
   p_PLAN_ID                  IN   NUMBER,
   p_ORIGINAL_PLAN_ID         IN   NUMBER,
   p_PLAN_GROUP_CODE          IN   VARCHAR2,
   p_START_DATE_ACTIVE        IN   VARCHAR2,
   p_END_DATE_ACTIVE          IN   VARCHAR2,
   p_USE_FOR_CUST_ACCOUNT     IN   VARCHAR2,
   p_END_USER_TYPE            IN   VARCHAR2 := NULL,
   p_CUSTOMIZED_PLAN          IN   VARCHAR2,
   p_PROFILE_CHECK_ID         IN   NUMBER,
   p_RELATIONAL_OPERATOR      IN   VARCHAR2,
   p_CRITERIA_VALUE_HIGH      IN   VARCHAR2,
   p_CRITERIA_VALUE_LOW       IN   VARCHAR2,
   p_LAST_UPDATE_DATE         IN   DATE,
   p_LAST_UPDATED_BY          IN   NUMBER,
   p_LAST_UPDATE_LOGIN        IN   NUMBER,
   p_ATTRIBUTE1               IN   VARCHAR2  := NULL,
   p_ATTRIBUTE2               IN   VARCHAR2  := NULL,
   p_ATTRIBUTE3               IN   VARCHAR2  := NULL,
   p_ATTRIBUTE4               IN   VARCHAR2  := NULL,
   p_ATTRIBUTE5               IN   VARCHAR2  := NULL,
   p_ATTRIBUTE6               IN   VARCHAR2  := NULL,
   p_ATTRIBUTE7               IN   VARCHAR2  := NULL,
   p_ATTRIBUTE8               IN   VARCHAR2  := NULL,
   p_ATTRIBUTE9               IN   VARCHAR2  := NULL,
   p_ATTRIBUTE10              IN   VARCHAR2  := NULL,
   p_ATTRIBUTE11              IN   VARCHAR2  := NULL,
   p_ATTRIBUTE12              IN   VARCHAR2  := NULL,
   p_ATTRIBUTE13              IN   VARCHAR2  := NULL,
   p_ATTRIBUTE14              IN   VARCHAR2  := NULL,
   p_ATTRIBUTE15              IN   VARCHAR2  := NULL,
   p_ATTRIBUTE_CATEGORY       IN   VARCHAR2  := NULL,
   P_DESCRIPTION              IN   VARCHAR2,
   P_NAME                     IN   VARCHAR2,
   X_OBJECT_VERSION_NUMBER    OUT NOCOPY  NUMBER,
   P_APPLICATION_ID           IN   NUMBER    := NULL,
   P_OWNER                    IN   VARCHAR2);

End CSC_PLAN_HEADERS_B_PKG;

 

/
