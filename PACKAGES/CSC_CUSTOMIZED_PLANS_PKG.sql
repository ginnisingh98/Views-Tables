--------------------------------------------------------
--  DDL for Package CSC_CUSTOMIZED_PLANS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSC_CUSTOMIZED_PLANS_PKG" AUTHID CURRENT_USER as
/* $Header: csctcups.pls 115.14 2002/11/25 06:10:09 bhroy ship $ */
-- Start of Comments
-- Package name     : CSC_CUSTOMIZED_PLANS_PKG
-- Purpose          : Table handler package to insert and delete rows from
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

PROCEDURE Insert_Row(
          px_ID                    IN OUT NOCOPY NUMBER,
		p_plan_id                IN     NUMBER,
		p_party_id               IN     NUMBER,
		p_cust_account_id        IN     NUMBER   := NULL,
		p_request_id             IN     NUMBER   := NULL,
		p_program_application_id IN     NUMBER   := NULL,
		p_program_id             IN     NUMBER   := NULL,
		p_program_update_date    IN     DATE     := NULL,
		p_plan_status_code       IN     VARCHAR2 := NULL);


-- For the delete row any one of the parameters should be specified.
PROCEDURE Delete_Row(
          p_ID                     IN     NUMBER   := NULL,
		p_plan_id                IN     NUMBER   := NULL,
		p_party_id               IN     NUMBER   := NULL);

End CSC_CUSTOMIZED_PLANS_PKG;

 

/
