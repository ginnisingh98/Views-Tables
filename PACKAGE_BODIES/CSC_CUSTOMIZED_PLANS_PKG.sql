--------------------------------------------------------
--  DDL for Package Body CSC_CUSTOMIZED_PLANS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSC_CUSTOMIZED_PLANS_PKG" as
/* $Header: csctcupb.pls 115.15 2002/11/25 06:12:33 bhroy ship $ */
-- Start of Comments
-- Package name     : CSC_CUSTOMIZED_PLANS_PKG
-- Purpose          : Table handler package to insert and delete rows in
--                    CSC_CUSTOMIZED_PLANS table.
-- History          :
-- DD-MM-YYYY    NAME          MODIFICATIONS
-- 11-04-1999    dejoseph      Created.
-- 12-08-1999    dejoseph      'Arcs'ed in for first code freeze.
-- 12-21-1999    dejoseph      'Arcs'ed in for second code freeze.
-- 01-03-2000    dejoseph      'Arcs'ed in for third code freeze. (10-JAN-2000)
-- 01-31-2000    dejoseph      'Arcs'ed in for fourth code freeze. (07-FEB-2000)
-- 02-13-2000    dejoseph      'Arcs'ed on for fifth code freeze. (21-FEB-2000)
-- 02-28-2000    dejoseph      'Arcs'ed on for sixth code freeze. (06-MAR-2000)
-- 04-10-2000    dejoseph      Removed reference to cust_account_org in lieu of TCA's
--                             decision to drop column org_id from hz_cust_accounts.
-- 02-07-2001    dejoseph      Added parameters to the insert_row procedures to record
--                             ac/party merge concurrent request information.
-- 08-29-2001    dejoseph      Removed parameter party_status from procedure insert_row. This
--                             column does not exist in the database. The merge status will
--                             be determined from PLAN_STATUS_CODE.
-- 11-12-2002	bhroy		NOCOPY changes made
-- 11-25-2002	bhroy		FND_API default changes made, added check file comments and WHENEVER OSERROR EXIT FAILURE ROLLBACK
-- NOTE             :
-- End of Comments


G_PKG_NAME  CONSTANT VARCHAR2(30) := 'CSC_CUSTOMIZED_PLANS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csctcupb.pls';

PROCEDURE Insert_Row(
          px_ID                    IN OUT NOCOPY NUMBER,
          p_PLAN_ID                IN     NUMBER,
          p_PARTY_ID               IN     NUMBER,
		p_cust_account_id        IN     NUMBER,
		p_request_id             IN     NUMBER,
		p_program_application_id IN     NUMBER,
		p_program_id             IN     NUMBER,
		p_program_update_date    IN     DATE,
		p_plan_status_code       IN     VARCHAR2)
IS
   CURSOR C2 IS
	 SELECT CSC_CUSTOMIZED_PLANS_S.nextval
	 FROM sys.dual;
BEGIN
   OPEN C2;
   FETCH C2 INTO px_ID;
   CLOSE C2;

   INSERT INTO CSC_CUSTOMIZED_PLANS(
        ID,
        PLAN_ID,
        PARTY_ID ,
	   CUST_ACCOUNT_ID ,
	   REQUEST_ID,
	   PROGRAM_APPLICATION_ID,
	   PROGRAM_ID,
	   PROGRAM_UPDATE_DATE,
	   PLAN_STATUS_CODE )
   VALUES (
        px_ID,
        p_PLAN_ID,
        p_PARTY_ID,
        p_cust_account_id,
	   p_request_id,
	   p_program_application_id,
	   p_program_id,
	   p_program_update_date,
	   p_plan_status_code );

End Insert_Row;


PROCEDURE Delete_Row(
          P_ID                     IN     NUMBER,
	     P_PLAN_ID                IN     NUMBER,
	     P_PARTY_ID               IN     NUMBER)
IS
BEGIN
   if ( P_ID IS NOT NULL OR P_ID <> FND_API.G_MISS_NUM ) THEN
      DELETE FROM CSC_CUSTOMIZED_PLANS
      WHERE  ID = p_ID;
   elsif ( P_PLAN_ID IS NOT NULL OR P_PLAN_ID <> FND_API.G_MISS_NUM ) THEN
	 IF ( P_PARTY_ID IS NOT NULL OR P_PARTY_ID <> FND_API.G_MISS_NUM ) THEN
	    DELETE FROM CSC_CUSTOMIZED_PLANS
	    WHERE  PLAN_ID  = P_PLAN_ID
	    AND    PARTY_ID = P_PARTY_ID;
      ELSE
	    DELETE FROM CSC_CUSTOMIZED_PLANS
	    WHERE  PLAN_ID = P_PLAN_ID;
      END IF;
   else
	 DELETE FROM CSC_CUSTOMIZED_PLANS
	 WHERE PARTY_ID = P_PARTY_ID;
   end if;

   If (SQL%NOTFOUND) then
       RAISE NO_DATA_FOUND;
   End If;

END Delete_Row;

End CSC_CUSTOMIZED_PLANS_PKG;

/
