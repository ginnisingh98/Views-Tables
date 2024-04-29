--------------------------------------------------------
--  DDL for Package Body CSC_PLAN_ASSIGNMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSC_PLAN_ASSIGNMENT_PKG" as
/* $Header: cscvengb.pls 120.2 2006/04/06 22:33:00 vshastry noship $ */
-- Start of Comments
-- Package name     : CSC_PLAN_ASSIGNMENT_PKG
-- Purpose          : Plan defnitions by itself are dummy entities in the system, and
--                    means nothing until it is associated to customer(s). This association
--                    is done by the procedures and function defined in this package body.
--                    These procedures evaluate the results of the customer profile checks
--                    for each customer and its account, compares it with the plan criteria,
--                    and if met, stores the association of the plan and the customer.
-- History          :
-- MM-DD-YYYY    NAME          MODIFICATIONS
-- 12-16-1999    dejoseph      Created.
-- 01-03-2000    dejoseph      'Arcs'ed in for third code freeze. (10-JAN-2000)
-- 01-25-2000    dejoseph      Added where condition in the NOT EXISTS sub query of the bulk
--                             insert into CSC_CUST_PLANS. ie cust_account_id and org.
-- 01-31-2000    dejoseph      'Arcs'ed in for fourth code freeze. (07-FEB-2000)
-- 02-13-2000    dejoseph      'Arcs'ed on for fifth code freeze. (21-FEB-2000)
-- 02-28-2000    dejoseph      'Arcs'ed on for sixth code freeze. (06-MAR-2000)
-- 03-28-2000    dejoseph      Removed references to CUST_ACCOUNT_ID and ORG_ID from all
--                             'where' clauses. ie. and   nvl(cust_account_org,0) =
--                             nvl(p_cust_account_org, nvl(cust_account_org,0) )
--                             Replaced call to HZ_CUST_ACCOUNT_ALL to HZ_CUST_ACCOUNTS.
-- 04-10-2000    dejoseph      Following TCA changes done:
--                             - Replaced references to HZ_ tables with JTF_ views.
--                             - Removed all references to org_id and cust_account_org.
--
-- 04-28-2000    dejoseph      Replaced reference to jtf_cust_accounts_v with jtf_cust_accounts_all_v;
-- 05-11-2000	 dmontefa      Added the 'OUT NOCOPY ' parameters, x_errbuf, x_retcode
-- 08-09-2000    dejoseph      Modified engine to run for all plans and parties if no parameters
--                             are specified. Fix to bug # 1372050.
-- 09-26-2001    dejoseph      Made the following changes for 11.5.6: Ref bug# 1745488.
--                             - Changed value of COMMIT_TIME from 25 to 1000;
--                             - Included check to avoid plans being assigned to the wrong level;
--                               ie. Account level plans being assigned to parties and vice-versa.
-- 01-30-2002    dejoseph      Included the dbdrv command for DB driver generation.
--                             Made the following change to clean up the Plans engine to
--                             1. Function as intended and 2. Perform efficiently.
--                             Deleted the following procedures:
--                             - RUN_PLAN_ENGINE -- overloaded proc. that accepts sql tables
--                             - VALIDATE_PARAMETERS
--                             - VALIDATE_PLAN_ID
--                             - VALIDATE_PARTY_ID
--                             - VALIDATE_CUST_ID_ORG
--                             - GET_PARTIES
--                             - GET_CUSTOMER_ACCOUNTS
--                             - GET_PLANS_AT_PARTY_LEVEL
--                             - GET_PLANS_AT_CUST_ACCT_LEVEL
--                             - UPDATE_CUST_PLANS
--                             - SELECT_CUST_PLAN_REC_EXISTS
--                             Introduced the following procedures:
--                             - RUN_WITH_ACCOUNT_ID
--                             - RUN_WITH_PLAN_PARTY
--                             - RUN_WITH_PLAN_ACCOUNT
--                             - RUN_WITH_CHECK_PARTY
--                             - RUN_WITH_CHECK_ACCOUNT
--                             - RUN_WITH_ALL
--                             Modified the cursor to join the plans header table and the check
--                             results table, instead of selecting the plans first and then
--                             selecting the results.
--                             Ref. Bug #s - 2030164, 1745488
-- 03-14-2002    dejoseph      - Corrected spelling mistake of the log message. Ref bug# 2232926
--                             - Introduced new variable 'g_mesg_line' which stores single lines
--                               of error text that is inserted into the log file as new lines.
--                             - Generated meaningful error message into the log file when an invalid
--                               set of parameters is given to the engine. Ref bug# 2250086.
--                             - Corrected where clause in cursor get_details that had:
--                                where b.cust_account_id = b.cust_account_id    to
--                                where b.cust_account_id is not null
-- 03-15-2002    dejoseph      Added the checkfile command
-- 11-12-2002	 bhroy		NOCOPY changes made
-- 11-28-2002	 bhroy		FND_API.G_MISS_XXX defaults removed
-- 07-11-2005    tpalaniv       Bug 4628149 Changing all the procedures to include
--                              the bulk limit in the fetch statement
-- 07-04-2006    vshastry      Bug 5073490  Added loop in all the procedures using bulk collect with limit
-- 07-04-2006    vshastry      Bug 5073490  closing the cursors out of the loop
-- NOTE             :
-- End of Comments
--

-- **** LIST OF GLOBAL VARIABLE AND CONSTANTS USED IN THE PACKAGE BODY *****

G_PKG_NAME                CONSTANT VARCHAR2(30)  := 'CSC_PLAN_ASSIGNMENT_PKG';
G_FILE_NAME               CONSTANT VARCHAR2(12)  := 'cscvengb.pls';
G_COMMIT_TIME             CONSTANT NUMBER        := 1000;
					 -- no. of recs that are inserted into CSC_CUST_PLANS
G_ERRBUF		                    VARCHAR2(2000) := NULL;
					 -- the error text from SQLERRM
G_MESG                             VARCHAR2(2000); -- message into log files.
G_MESG_LINE                        VARCHAR2(2000); -- has single lines of error text

-- The following tables stores the column values of all the plans that
-- a customer satisfies. It has an 'add' in its name to denote that these
-- plans need to be added to this customer in the CSC_CUST_PLANS table.
G_PLAN_ID_ADD_TBL                  CSC_PLAN_ID_TBL_TYPE;
G_PARTY_ID_ADD_TBL                 CSC_PARTY_ID_TBL_TYPE;
G_CUST_ID_ADD_TBL                  CSC_CUST_ID_TBL_TYPE;
G_START_DATE_ACTIVE_ADD_TBL        CSC_DATE_TBL_TYPE;
G_END_DATE_ACTIVE_ADD_TBL          CSC_DATE_TBL_TYPE;
G_ADD_IDX                          NUMBER := 0; -- index for add tables

-- The following tables stores plan and customer information, when a
-- customer no longer satisfies a plan criteria. It has a 'del' to its
-- name to denote that these rows need to be deleted from CSC_CUST_PLANS
-- table.
G_PLAN_ID_DEL_TBL                  CSC_PLAN_ID_TBL_TYPE;
G_PARTY_ID_DEL_TBL                 CSC_PARTY_ID_TBL_TYPE;
G_CUST_ID_DEL_TBL                  CSC_CUST_ID_TBL_TYPE;
G_DEL_IDX                          NUMBER := 0; -- index for delete tables



-- *********  END DECLARATION OF GLOBAL VARIABLES AND CONSTANTS. **************

/************* OVERVIEW OF HOW THE PLAN ENGINE CAN BE EXECUTED ****************

1> Given a list of plan_id(s) this is what should be done:
   - get the profile variables and plan levels (either party or account level)
	associated with each of those plans from the plan headers table
	csc_plan_headers_b.
   - if the plan is at party level then
      - for each of those profile variables (check_ids), get the result for all
	   parties (only, not accounts) from the results table.
   - else if the plan is at account level then
	 - for each of those profile variables (check_ids), get the result for all
	   accounts (only, not parties) from the results table.
   - compare the result of each party or account, with the plan criteria.
   - associate the plan if the party/account is eligible for it.
2> Given a list of check id(s) this is what should be done:
   - get the results for each party or account for each of those check_ids from
	the results table.
   - get all the plans and their criteria (relational_operator,criteria_value_low
	and high) that are defined with the given check_ids.
   - compare the results of each party/account with the plan criteria.
   - associate the plan if the party/account is eligible for it.
3> Given a list of party_id(s) or account(s) this is what should be done:
   - get the results and check_ids for each of the given parties or accounts from
	the results table.
   - get all the plans and their criteria (relational_operator, criteria_value_low
	and high) for each of the returned back check_ids.
   - compare the results of each party/account with the plan criteria.
   - associate the plan if the party/account is elIgible for it.

********************************************************************************/

PROCEDURE RUN_PLAN_ENGINE (
   X_ERRBUF			        OUT  NOCOPY VARCHAR2,
   X_RETCODE			        OUT  NOCOPY NUMBER ,
   P_PLAN_ID                    IN   NUMBER       := NULL,
   P_CHECK_ID                   IN   NUMBER       := NULL,
   P_PARTY_ID                   IN   NUMBER       := NULL,
   P_CUST_ACCOUNT_ID            IN   NUMBER       := NULL )
IS
   l_call               NUMBER; -- see comments below

   l_return_status      VARCHAR2(1); -- used to return a success of failure
				     -- status

   /*
   l_plan_id_tbl        CSC_PLAN_ID_TBL_TYPE  := G_EMPTY_PLAN_ID_TBL;
   l_check_id_tbl       CSC_CHECK_ID_TBL_TYPE := G_EMPTY_CHECK_ID_TBL;
   l_party_id_tbl       CSC_PARTY_ID_TBL_TYPE := G_EMPTY_PARTY_ID_TBL;
   l_cust_id_tbl        CSC_CUST_ID_TBL_TYPE  := G_EMPTY_CUST_ID_TBL;
   */


BEGIN
   -- l_call is used to determine which procedure to call, depending on what
   -- parameters are passed; The legend for l_call is as follows:
   --   1 => Engine called with plan id
   --   2 => Engine called with check id
   --   3 => Engine called with party id
   --   4 => Engine called with account id
   --  12 => Engine called with plan id and check id
   --  13 => Engine called with plan id and party id
   --  14 => Engine called with plan id and account id
   --  23 => Engine called with check id and party id
   --  24 => Engine called with check id and account id
   --  34 => Engine called with party id and account id
   -- 123 => Engine called with plan id, check id and party id
   -- 124 => Engine called with plan id, check id and account id
   -- 134 => Engine called with plan id, party id and account id
   -- 234 => Engine called with check id, party id and account id
   --1234 => Engine called with plan id, check id, party id and account id
   --   0 => Engine called with no parameters.

   l_call := 0;  -- initialize l_call to no parameters passed.

   IF ( p_plan_id IS NOT NULL ) THEN
      l_call := 1;
   END IF;

   IF ( p_check_id IS NOT NULL ) THEN
      if ( l_call = 1 ) then
	 l_call := 12;
      else
	 l_call := 2;
      end if;
   END IF;

   IF ( p_party_id IS NOT NULL ) THEN
      if ( l_call = 1 ) then
	 l_call := 13;
      elsif ( l_call = 2 ) then
	 l_call := 23;
      elsif ( l_call = 12 ) then
	 l_call := 123;
      else
	 l_call := 3;
     end if;
   END IF;

   IF ( p_cust_account_id IS NOT NULL ) THEN
      if ( l_call = 1 ) then
	 l_call := 14;
      elsif ( l_call = 2 ) then
	 l_call := 24;
      elsif ( l_call = 3 ) then
	 l_call := 34;
      elsif ( l_call = 12 ) then
	 l_call := 124;
      elsif ( l_call = 13 ) then
	 l_call := 134;
      elsif ( l_call = 23 ) then
	 l_call := 234;
      elsif ( l_call = 123 ) then
	 l_call := 1234;
      else
	 l_call := 4;
      end if;
   END IF;

  -- because of the dependency between
  --      i) checks and plans  (a plan can be tied to only one check)
  -- and ii) party and account (an account can be tied to only one party)
  -- the call to the required procedure depending on the input parameters are
  -- sometimes redundant. For eg. the call to run the engine with only the plan id
  -- parameter will be made for the following cases:
  --     i) user enters a specific plan id
  --    ii) user enters a specific plan id and check id
  -- Similarily there are other cases as well. The following call out logic is based
  -- on the above example.

   if ( l_call = 1 OR l_call =  12 ) then
      -- exec. run_with_plan_id with a single plan_id
      run_with_plan_id(
	 p_plan_id           => p_plan_id,
	 x_return_status     => l_return_status);

   elsif ( l_call = 2 ) then
      -- get all the plan details that share this same check_id
      -- exec. run_with_plan_id with a list of theses plan_ids
      -- run_with_check_id;  -- same proc. as just giving a plan id
      run_with_check_id (
	 p_check_id          => p_check_id,
	 x_return_status     => l_return_status);

   elsif ( l_call = 3 ) then
      -- get all the plan details at party_level only
      -- get the coresponding results for the single party_id
      run_with_party_id (
	 p_party_id          => p_party_id,
	 x_return_status     => l_return_status);

   elsif ( l_call = 4 OR l_call = 34 ) then
      -- get all the plan details at account level only
      -- get the results for given account for the given check_id
      run_with_account_id (
	 p_cust_account_id   => p_cust_account_id,
	 x_return_status     => l_return_status);

   elsif ( l_call = 13 OR l_call = 123 ) then
      -- get the plan details for the given plan_id. the plan should
      --     be at party level, else throw an error message
      -- get the results for the given party for the given check_id
      run_with_plan_party (
	 p_plan_id           => p_plan_id,
	 p_party_id          => p_party_id,
	 x_return_status     => l_return_status);

   elsif ( l_call = 14 OR l_call = 124 OR l_call = 134 OR l_call = 1234 ) then
      -- get the plan details for the given plan_id. the plan should
      --     be at account level, else throw an error message
      -- get the results for the given account for the given check_id
      run_with_plan_account (
	 p_plan_id           => p_plan_id,
	 p_cust_account_id   => p_cust_account_id,
	 x_return_status     => l_return_status);

   elsif ( l_call = 23  ) then
      -- get all the plans details that share this same check_id at
      --     party level only
      -- get the results for the given party id
      run_with_check_party (
	 p_check_id          => p_check_id,
	 p_party_id          => p_party_id,
	 x_return_status     => l_return_status);

   elsif ( l_call = 24 OR l_call = 234  ) then
      -- get all the plan details that share this same check_id at
      --     account level only
      -- get the results for the given account_id
      run_with_check_account (
	 p_check_id          => p_check_id,
	 p_cust_account_id   => p_cust_account_id,
	 x_return_status     => l_return_status);

   elsif ( l_call = 0 ) then
      -- get all plan details
      -- get all party results
      run_with_all (
	 x_return_status     => l_return_status);

   end if;

   IF (g_errbuf is not null) THEN
      x_errbuf  := G_ERRBUF;
      x_retcode := 2;
   ELSE
      x_errbuf  := '';
      x_retcode := 0;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      g_mesg   := sqlcode || ' ' || sqlerrm;
      fnd_file.put_line(fnd_file.log, g_mesg);
      G_ERRBUF := g_mesg;

END RUN_PLAN_ENGINE;

-- The following procedure will be executed when
-- 1. User enters a plan_id

PROCEDURE RUN_WITH_PLAN_ID (
   P_PLAN_ID                IN  NUMBER,
   X_RETURN_STATUS          OUT NOCOPY VARCHAR2 )
IS
   -- get the plan details and the coresponding check results
   -- NOTE: Get the check results according to the level of the plan. ie. get
   --       account level results only if the plan is defined for account level.
   cursor get_details is
   select a.plan_id,              a.profile_check_id,     a.relational_operator,
          a.criteria_value_low,   a.criteria_value_high,  a.start_date_active,
	  a.end_date_active,      a.use_for_cust_account,
	  b.party_id,             b.cust_account_id,      b.value
   from   csc_plan_headers_b a,
	  csc_prof_check_results b
   where  a.profile_check_id      = b.check_id
   and    a.plan_id               = p_plan_id
   and    a.customized_plan       = 'N'
   and ( (     a.use_for_cust_account = 'N'
	   and b.cust_account_id is null  )
      OR (     a.use_for_cust_account = 'Y'
	   and b.cust_account_id  is not null ) )
   and    sysdate between nvl(a.start_date_active, sysdate )
		      and nvl(a.end_date_active,   sysdate );

-- local variable declaration
   l_check_name                       VARCHAR2(240);

   l_plan_id_tbl                      CSC_PLAN_ID_TBL_TYPE;
   l_check_id_tbl                     CSC_CHECK_ID_TBL_TYPE;
   l_relational_operator_tbl          CSC_CHAR_TBL_TYPE;
   l_criteria_value_low_tbl           CSC_CHAR_TBL_TYPE;
   l_criteria_value_high_tbl          CSC_CHAR_TBL_TYPE;
   l_start_date_active_tbl            CSC_DATE_TBL_TYPE;
   l_end_date_active_tbl              CSC_DATE_TBL_TYPE;
   l_use_for_cust_account_tbl         CSC_CHAR_TBL_TYPE;

   l_party_id_tbl                     CSC_PARTY_ID_TBL_TYPE;
   l_cust_id_tbl                      CSC_CUST_ID_TBL_TYPE;
   l_value_tbl                        CSC_CHAR_TBL_TYPE;
BEGIN

   open get_details;
Loop
   fetch get_details
   bulk collect into
      l_plan_id_tbl             , l_check_id_tbl,             l_relational_operator_tbl ,
      l_criteria_value_low_tbl  , l_criteria_value_high_tbl , l_start_date_active_tbl,
      l_end_date_active_tbl     , l_use_for_cust_account_tbl, l_party_id_tbl,
      l_cust_id_tbl             , l_value_tbl LIMIT 2000;   /* Bug 4628148: Included the limit */

   if ( l_plan_id_tbl.count = 0 ) then
      g_mesg := 'Given request parameters did not retrieve any records to be processed. ' ||
		'Please enter a valid set of parameters.';
      G_ERRBUF := g_mesg;
      g_mesg_line := 'Causes:';
      fnd_file.put_line(fnd_file.log, g_mesg_line);
      g_mesg := g_mesg || g_mesg_line;
      g_mesg_line := '- Specified plan is either customized or has expired.';
      fnd_file.put_line(fnd_file.log, g_mesg_line);
      g_mesg := g_mesg || g_mesg_line;
      g_mesg_line := '- Profile results for the check associated to the specified plan ' ||
		     'have not been populated.';
      fnd_file.put_line(fnd_file.log, g_mesg_line);
      g_mesg := g_mesg || g_mesg_line;
      g_mesg_line := 'Action';
      fnd_file.put_line(fnd_file.log, g_mesg_line);
      g_mesg := g_mesg || g_mesg_line;
      g_mesg_line := '- Specify plans that are not customized and have not expired.';
      fnd_file.put_line(fnd_file.log, g_mesg_line);
      g_mesg := g_mesg || g_mesg_line;
      g_mesg_line := '- Run the Profile Engine to populate the results for the check ' ||
		     'name associated to the specified plan.';
      fnd_file.put_line(fnd_file.log, g_mesg_line);
      g_mesg := g_mesg || g_mesg_line;
   else
      -- call the procedure to make/break the customer - plan association
      add_remove_plan_check (
         P_PLAN_ID_TBL                => l_plan_id_tbl,
         P_RELATIONAL_OPERATOR_TBL    => l_relational_operator_tbl,
         P_CRITERIA_VALUE_LOW_TBL     => l_criteria_value_low_tbl,
         P_CRITERIA_VALUE_HIGH_TBL    => l_criteria_value_high_tbl,
         P_START_DATE_ACTIVE_TBL      => l_start_date_active_tbl,
         P_END_DATE_ACTIVE_TBL        => l_end_date_active_tbl,
         P_USE_FOR_CUST_ACCOUNT_TBL   => l_use_for_cust_account_tbl,
         P_PARTY_ID_TBL               => l_party_id_tbl,
         P_CUST_ID_TBL                => l_cust_id_tbl,
         P_VALUE_TBL                  => l_value_tbl,
         X_RETURN_STATUS              => x_return_status );
   end if;

   Exit when get_details%NOTFOUND;
End Loop;
close get_details;

EXCEPTION
   WHEN OTHERS THEN
      g_mesg := sqlcode || ' ' || sqlerrm;
      fnd_file.put_line(fnd_file.log, g_mesg);
      G_ERRBUF := g_mesg;

END RUN_WITH_PLAN_ID; -- end for main begin of run_with_plan_id


-- The following procedure will be executed when
-- 1. User enters a check_id

PROCEDURE RUN_WITH_CHECK_ID (
   P_CHECK_ID               IN  NUMBER,
   X_RETURN_STATUS          OUT NOCOPY VARCHAR2 )
IS
   -- get the plan details and the coresponding check results
   -- NOTE: Get the check results according to the level of the plan. ie. get
   --       account level results only if the plan is defined for account level.
   cursor get_details is
   select a.plan_id,              a.profile_check_id,     a.relational_operator,
          a.criteria_value_low,   a.criteria_value_high,  a.start_date_active,
	  a.end_date_active,      a.use_for_cust_account,
	  b.party_id,             b.cust_account_id,      b.value
   from   csc_plan_headers_b a,
	  csc_prof_check_results b
   where  a.profile_check_id      = b.check_id
   and    a.profile_check_id      = p_check_id
   and    a.customized_plan       = 'N'
   and ( (     a.use_for_cust_account = 'N'
	   and b.cust_account_id is null  )
      OR (     a.use_for_cust_account = 'Y'
	   and b.cust_account_id  is not null ) )
   and    sysdate between nvl(a.start_date_active, sysdate )
		      and nvl(a.end_date_active,   sysdate );

-- local variable declaration
   l_check_name                       VARCHAR2(240);

   l_plan_id_tbl                      CSC_PLAN_ID_TBL_TYPE;
   l_check_id_tbl                     CSC_CHECK_ID_TBL_TYPE;
   l_relational_operator_tbl          CSC_CHAR_TBL_TYPE;
   l_criteria_value_low_tbl           CSC_CHAR_TBL_TYPE;
   l_criteria_value_high_tbl          CSC_CHAR_TBL_TYPE;
   l_start_date_active_tbl            CSC_DATE_TBL_TYPE;
   l_end_date_active_tbl              CSC_DATE_TBL_TYPE;
   l_use_for_cust_account_tbl         CSC_CHAR_TBL_TYPE;

   l_party_id_tbl                     CSC_PARTY_ID_TBL_TYPE;
   l_cust_id_tbl                      CSC_CUST_ID_TBL_TYPE;
   l_value_tbl                        CSC_CHAR_TBL_TYPE;
BEGIN

   open get_details;
Loop
   fetch get_details
   bulk collect into
      l_plan_id_tbl             , l_check_id_tbl,             l_relational_operator_tbl ,
      l_criteria_value_low_tbl  , l_criteria_value_high_tbl , l_start_date_active_tbl,
      l_end_date_active_tbl     , l_use_for_cust_account_tbl, l_party_id_tbl,
      l_cust_id_tbl             , l_value_tbl LIMIT 2000;  /* Bug 4628148: Included limit clause */

   if ( l_plan_id_tbl.count = 0 ) then
      g_mesg := 'Given request parameters did not retrieve any records to be processed. ' ||
		'Please enter a valid set of parameters.';
      G_ERRBUF := g_mesg;
      g_mesg_line := 'Causes:';
      fnd_file.put_line(fnd_file.log, g_mesg_line);
      g_mesg := g_mesg || g_mesg_line;
      g_mesg_line := '- Plans for the specified check are either customized or have expired.';
      fnd_file.put_line(fnd_file.log, g_mesg_line);
      g_mesg := g_mesg || g_mesg_line;
      g_mesg_line := '- Profile results for the specified check have not been populated.';
      fnd_file.put_line(fnd_file.log, g_mesg_line);
      g_mesg := g_mesg || g_mesg_line;
      g_mesg_line := 'Action';
      fnd_file.put_line(fnd_file.log, g_mesg_line);
      g_mesg := g_mesg || g_mesg_line;
      g_mesg_line := '- Specify checks associated to plans that are not customized and have not expired.';
      fnd_file.put_line(fnd_file.log, g_mesg_line);
      g_mesg := g_mesg || g_mesg_line;
      g_mesg_line := '- Run the Profile Engine to populate the results for the specified check.';
      fnd_file.put_line(fnd_file.log, g_mesg_line);
      g_mesg := g_mesg || g_mesg_line;
   else
      -- call the procedure to make/break the customer - plan association
      add_remove_plan_check (
         P_PLAN_ID_TBL                => l_plan_id_tbl,
         P_RELATIONAL_OPERATOR_TBL    => l_relational_operator_tbl,
         P_CRITERIA_VALUE_LOW_TBL     => l_criteria_value_low_tbl,
         P_CRITERIA_VALUE_HIGH_TBL    => l_criteria_value_high_tbl,
         P_START_DATE_ACTIVE_TBL      => l_start_date_active_tbl,
         P_END_DATE_ACTIVE_TBL        => l_end_date_active_tbl,
         P_USE_FOR_CUST_ACCOUNT_TBL   => l_use_for_cust_account_tbl,
         P_PARTY_ID_TBL               => l_party_id_tbl,
         P_CUST_ID_TBL                => l_cust_id_tbl,
         P_VALUE_TBL                  => l_value_tbl,
         X_RETURN_STATUS              => x_return_status );
   end if;

   Exit when get_details%NOTFOUND;
End Loop;
close get_details;

EXCEPTION
   WHEN OTHERS THEN
      g_mesg := sqlcode || ' ' || sqlerrm;
      fnd_file.put_line(fnd_file.log, g_mesg);
      G_ERRBUF := g_mesg;

END RUN_WITH_CHECK_ID; -- end for main begin of run_with_plan_id


-- The following procedure will be executed when
-- 1. User enters a party_id

PROCEDURE RUN_WITH_PARTY_ID (
   P_PARTY_ID               IN  NUMBER,
   X_RETURN_STATUS          OUT NOCOPY VARCHAR2 )
IS

   cursor get_details is
   select a.plan_id,              a.profile_check_id,     a.relational_operator,
          a.criteria_value_low,   a.criteria_value_high,  a.start_date_active,
	  a.end_date_active,      a.use_for_cust_account,
	  b.party_id,             b.cust_account_id,      b.value
   from   csc_plan_headers_b a,
	  csc_prof_check_results b
   where  a.profile_check_id      = b.check_id
   and    a.customized_plan       = 'N'
   and    b.party_id              = p_party_id
   and    b.cust_account_id      is NULL
   and    a.use_for_cust_account  = 'N'
   and    sysdate between nvl(a.start_date_active, sysdate )
		      and nvl(a.end_date_active,   sysdate );

-- local variable declaration
   l_check_name                       VARCHAR2(240);

   l_plan_id_tbl                      CSC_PLAN_ID_TBL_TYPE;
   l_check_id_tbl                     CSC_CHECK_ID_TBL_TYPE;
   l_relational_operator_tbl          CSC_CHAR_TBL_TYPE;
   l_criteria_value_low_tbl           CSC_CHAR_TBL_TYPE;
   l_criteria_value_high_tbl          CSC_CHAR_TBL_TYPE;
   l_start_date_active_tbl            CSC_DATE_TBL_TYPE;
   l_end_date_active_tbl              CSC_DATE_TBL_TYPE;
   l_use_for_cust_account_tbl         CSC_CHAR_TBL_TYPE;

   l_party_id_tbl                     CSC_PARTY_ID_TBL_TYPE;
   l_cust_id_tbl                      CSC_CUST_ID_TBL_TYPE;
   l_value_tbl                        CSC_CHAR_TBL_TYPE;
BEGIN
   open get_details;
Loop
   fetch get_details
   bulk collect into
      l_plan_id_tbl             , l_check_id_tbl,             l_relational_operator_tbl ,
      l_criteria_value_low_tbl  , l_criteria_value_high_tbl , l_start_date_active_tbl,
      l_end_date_active_tbl     , l_use_for_cust_account_tbl, l_party_id_tbl,
      l_cust_id_tbl             , l_value_tbl LIMIT 2000;  /* Bug 4628148 : Included Limit clause */

   if ( l_plan_id_tbl.count = 0 ) then
      g_mesg := 'Given request parameters did not retrieve any records to be processed. ' ||
		'Please enter a valid set of parameters.';
      G_ERRBUF := g_mesg;
      g_mesg_line := 'Causes:';
      fnd_file.put_line(fnd_file.log, g_mesg_line);
      g_mesg := g_mesg || g_mesg_line;
      g_mesg_line := '- All plans have expired.';
      fnd_file.put_line(fnd_file.log, g_mesg_line);
      g_mesg := g_mesg || g_mesg_line;
      g_mesg_line := '- Profile results for the specified party have not been populated.';
      fnd_file.put_line(fnd_file.log, g_mesg_line);
      g_mesg := g_mesg || g_mesg_line;
      g_mesg_line := 'Action';
      fnd_file.put_line(fnd_file.log, g_mesg_line);
      g_mesg := g_mesg || g_mesg_line;
      g_mesg_line := '- Verify that there are active plans. (ie. end date of plans are a future date)';
      fnd_file.put_line(fnd_file.log, g_mesg_line);
      g_mesg := g_mesg || g_mesg_line;
      g_mesg_line := '- Run the Profile Engine to populate the results for the specified party.';
      fnd_file.put_line(fnd_file.log, g_mesg_line);
      g_mesg := g_mesg || g_mesg_line;
   else
      -- call the procedure to make/break the customer - plan association
      add_remove_plan_check (
         P_PLAN_ID_TBL                => l_plan_id_tbl,
         P_RELATIONAL_OPERATOR_TBL    => l_relational_operator_tbl,
         P_CRITERIA_VALUE_LOW_TBL     => l_criteria_value_low_tbl,
         P_CRITERIA_VALUE_HIGH_TBL    => l_criteria_value_high_tbl,
         P_START_DATE_ACTIVE_TBL      => l_start_date_active_tbl,
         P_END_DATE_ACTIVE_TBL        => l_end_date_active_tbl,
         P_USE_FOR_CUST_ACCOUNT_TBL   => l_use_for_cust_account_tbl,
         P_PARTY_ID_TBL               => l_party_id_tbl,
         P_CUST_ID_TBL                => l_cust_id_tbl,
         P_VALUE_TBL                  => l_value_tbl,
         X_RETURN_STATUS              => x_return_status );
   end if;

   Exit when get_details%NOTFOUND;
End Loop;
close get_details;

EXCEPTION
   WHEN OTHERS THEN
      g_mesg := sqlcode || ' ' || sqlerrm;
      fnd_file.put_line(fnd_file.log, g_mesg);
      G_ERRBUF := g_mesg;

END RUN_WITH_PARTY_ID;


-- The following procedure will be executed when
-- 1. User enters an account_id

PROCEDURE RUN_WITH_ACCOUNT_ID (
   P_CUST_ACCOUNT_ID            IN   NUMBER,
   X_RETURN_STATUS              OUT  NOCOPY VARCHAR2 )
IS

   cursor get_details is
   select a.plan_id,              a.profile_check_id,     a.relational_operator,
          a.criteria_value_low,   a.criteria_value_high,  a.start_date_active,
	  a.end_date_active,      a.use_for_cust_account,
	  b.party_id,             b.cust_account_id,      b.value
   from   csc_plan_headers_b a,
	  csc_prof_check_results b
   where  a.profile_check_id      = b.check_id
   and    a.customized_plan       = 'N'
   and    b.cust_account_id       = p_cust_account_id
   and    a.use_for_cust_account  = 'Y'
   and    sysdate between nvl(a.start_date_active, sysdate )
		      and nvl(a.end_date_active,   sysdate );

-- local variable declaration
   l_check_name                       VARCHAR2(240);

   l_plan_id_tbl                      CSC_PLAN_ID_TBL_TYPE;
   l_check_id_tbl                     CSC_CHECK_ID_TBL_TYPE;
   l_relational_operator_tbl          CSC_CHAR_TBL_TYPE;
   l_criteria_value_low_tbl           CSC_CHAR_TBL_TYPE;
   l_criteria_value_high_tbl          CSC_CHAR_TBL_TYPE;
   l_start_date_active_tbl            CSC_DATE_TBL_TYPE;
   l_end_date_active_tbl              CSC_DATE_TBL_TYPE;
   l_use_for_cust_account_tbl         CSC_CHAR_TBL_TYPE;

   l_party_id_tbl                     CSC_PARTY_ID_TBL_TYPE;
   l_cust_id_tbl                      CSC_CUST_ID_TBL_TYPE;
   l_value_tbl                        CSC_CHAR_TBL_TYPE;
BEGIN
   open get_details;
Loop
   fetch get_details
   bulk collect into
      l_plan_id_tbl             , l_check_id_tbl,             l_relational_operator_tbl ,
      l_criteria_value_low_tbl  , l_criteria_value_high_tbl , l_start_date_active_tbl,
      l_end_date_active_tbl     , l_use_for_cust_account_tbl, l_party_id_tbl,
      l_cust_id_tbl             , l_value_tbl LIMIT 2000;  /* Bug 4628148: Included limit clause */

   if ( l_plan_id_tbl.count = 0 ) then
      g_mesg := 'Given request parameters did not retrieve any records to be processed. ' ||
		'Please enter a valid set of parameters.';
      G_ERRBUF := g_mesg;
      g_mesg_line := 'Causes:';
      fnd_file.put_line(fnd_file.log, g_mesg_line);
      g_mesg := g_mesg || g_mesg_line;
      g_mesg_line := '- All plans have expired.';
      fnd_file.put_line(fnd_file.log, g_mesg_line);
      g_mesg := g_mesg || g_mesg_line;
      g_mesg_line := '- Profile results for the specified account have not been populated.';
      fnd_file.put_line(fnd_file.log, g_mesg_line);
      g_mesg := g_mesg || g_mesg_line;
      g_mesg_line := 'Action';
      fnd_file.put_line(fnd_file.log, g_mesg_line);
      g_mesg := g_mesg || g_mesg_line;
      g_mesg_line := '- Verify that there are active plans. (ie. end date of plans are a future date)';
      fnd_file.put_line(fnd_file.log, g_mesg_line);
      g_mesg := g_mesg || g_mesg_line;
      g_mesg_line := '- Run the Profile Engine to populate the results for the specified account.';
      fnd_file.put_line(fnd_file.log, g_mesg_line);
      g_mesg := g_mesg || g_mesg_line;
   else
      -- call the procedure to make/break the customer - plan association
      add_remove_plan_check (
         P_PLAN_ID_TBL                => l_plan_id_tbl,
         P_RELATIONAL_OPERATOR_TBL    => l_relational_operator_tbl,
         P_CRITERIA_VALUE_LOW_TBL     => l_criteria_value_low_tbl,
         P_CRITERIA_VALUE_HIGH_TBL    => l_criteria_value_high_tbl,
         P_START_DATE_ACTIVE_TBL      => l_start_date_active_tbl,
         P_END_DATE_ACTIVE_TBL        => l_end_date_active_tbl,
         P_USE_FOR_CUST_ACCOUNT_TBL   => l_use_for_cust_account_tbl,
         P_PARTY_ID_TBL               => l_party_id_tbl,
         P_CUST_ID_TBL                => l_cust_id_tbl,
         P_VALUE_TBL                  => l_value_tbl,
         X_RETURN_STATUS              => x_return_status );
   end if;

   Exit when get_details%NOTFOUND;
End Loop;
close get_details;


EXCEPTION
   WHEN OTHERS THEN
      g_mesg := sqlcode || ' ' || sqlerrm;
      fnd_file.put_line(fnd_file.log, g_mesg);
      G_ERRBUF := g_mesg;

END RUN_WITH_ACCOUNT_ID;



-- The following procedure will be executed when
-- 1. User enters a plan_id and party_id
-- 2. User enters a plan_id, check_id and a party_id

PROCEDURE RUN_WITH_PLAN_PARTY (
   P_PLAN_ID                IN  NUMBER,
   P_PARTY_ID               IN  NUMBER,
   X_RETURN_STATUS          OUT NOCOPY VARCHAR2 )
IS

   cursor get_details is
   select a.plan_id,              a.profile_check_id,     a.relational_operator,
          a.criteria_value_low,   a.criteria_value_high,  a.start_date_active,
	  a.end_date_active,      a.use_for_cust_account,
	  b.party_id,             b.cust_account_id,      b.value
   from   csc_plan_headers_b a,
	  csc_prof_check_results b
   where  a.profile_check_id      = b.check_id
   and    a.plan_id               = p_plan_id
   and    a.customized_plan       = 'N'
   and    b.party_id              = p_party_id
   and    b.cust_account_id      is NULL
   and    a.use_for_cust_account  = 'N'
   and    sysdate between nvl(a.start_date_active, sysdate )
		      and nvl(a.end_date_active, sysdate ) ;

-- local variable declaration
   l_check_name                       VARCHAR2(240);

   l_plan_id_tbl                      CSC_PLAN_ID_TBL_TYPE;
   l_check_id_tbl                     CSC_CHECK_ID_TBL_TYPE;
   l_relational_operator_tbl          CSC_CHAR_TBL_TYPE;
   l_criteria_value_low_tbl           CSC_CHAR_TBL_TYPE;
   l_criteria_value_high_tbl          CSC_CHAR_TBL_TYPE;
   l_start_date_active_tbl            CSC_DATE_TBL_TYPE;
   l_end_date_active_tbl              CSC_DATE_TBL_TYPE;
   l_use_for_cust_account_tbl         CSC_CHAR_TBL_TYPE;

   l_party_id_tbl                     CSC_PARTY_ID_TBL_TYPE;
   l_cust_id_tbl                      CSC_CUST_ID_TBL_TYPE;
   l_value_tbl                        CSC_CHAR_TBL_TYPE;
BEGIN

   open get_details;
Loop
   fetch get_details
   bulk collect into
      l_plan_id_tbl             , l_check_id_tbl,             l_relational_operator_tbl ,
      l_criteria_value_low_tbl  , l_criteria_value_high_tbl , l_start_date_active_tbl,
      l_end_date_active_tbl     , l_use_for_cust_account_tbl, l_party_id_tbl,
      l_cust_id_tbl             , l_value_tbl LIMIT 2000;  /* Bug 4628148: Included Limit clause */

   if ( l_plan_id_tbl.count = 0 ) then
      g_mesg := 'Given request parameters did not retrieve any records to be processed. ' ||
		'Please enter a valid set of parameters.';
      G_ERRBUF := g_mesg;
      g_mesg_line := 'Causes:';
      fnd_file.put_line(fnd_file.log, g_mesg_line);
      g_mesg := g_mesg || g_mesg_line;
      g_mesg_line := '- Specified plan is either customized or has expired.';
      fnd_file.put_line(fnd_file.log, g_mesg_line);
      g_mesg := g_mesg || g_mesg_line;
      g_mesg_line := '- Specified plan is an account level plan.';
      fnd_file.put_line(fnd_file.log, g_mesg_line);
      g_mesg := g_mesg || g_mesg_line;
      g_mesg_line := '- Profile results for the specified party and/or check of the ' ||
		     'specified plan have not been populated.';
      fnd_file.put_line(fnd_file.log, g_mesg_line);
      g_mesg := g_mesg || g_mesg_line;
      g_mesg_line := 'Action';
      fnd_file.put_line(fnd_file.log, g_mesg_line);
      g_mesg := g_mesg || g_mesg_line;
      g_mesg_line := '- Specify plans that are not customized and have not expired.';
      fnd_file.put_line(fnd_file.log, g_mesg_line);
      g_mesg := g_mesg || g_mesg_line;
      g_mesg_line := '- Specify plans that are not account level plans when specifing a party together.';
      fnd_file.put_line(fnd_file.log, g_mesg_line);
      g_mesg := g_mesg || g_mesg_line;
      g_mesg_line := '- Run the Profile Engine to populate the results for the specified ' ||
		     'party and/or check of the specified plan.';
      fnd_file.put_line(fnd_file.log, g_mesg_line);
      g_mesg := g_mesg || g_mesg_line;
   else
      -- call the procedure to make/break the customer - plan association
      add_remove_plan_check (
         P_PLAN_ID_TBL                => l_plan_id_tbl,
         P_RELATIONAL_OPERATOR_TBL    => l_relational_operator_tbl,
         P_CRITERIA_VALUE_LOW_TBL     => l_criteria_value_low_tbl,
         P_CRITERIA_VALUE_HIGH_TBL    => l_criteria_value_high_tbl,
         P_START_DATE_ACTIVE_TBL      => l_start_date_active_tbl,
         P_END_DATE_ACTIVE_TBL        => l_end_date_active_tbl,
         P_USE_FOR_CUST_ACCOUNT_TBL   => l_use_for_cust_account_tbl,
         P_PARTY_ID_TBL               => l_party_id_tbl,
         P_CUST_ID_TBL                => l_cust_id_tbl,
         P_VALUE_TBL                  => l_value_tbl,
         X_RETURN_STATUS              => x_return_status );
   end if;

   Exit when get_details%NOTFOUND;
End Loop;
close get_details;

EXCEPTION
   WHEN OTHERS THEN
      g_mesg := sqlcode || ' ' || sqlerrm;
      fnd_file.put_line(fnd_file.log, g_mesg);
      G_ERRBUF := g_mesg;

END RUN_WITH_PLAN_PARTY;

-- The following procedure will be executed when
-- 1. User enters a plan_id and account_id
-- 2. User enters a plan_id, check_id and account_id
-- 3. User enters a plan_id, party_id and account_id
-- 4. User enters a plan_id, check_id, party_id and account_id

PROCEDURE RUN_WITH_PLAN_ACCOUNT (
   P_PLAN_ID                IN  NUMBER,
   P_CUST_ACCOUNT_ID        IN  NUMBER,
   X_RETURN_STATUS          OUT NOCOPY VARCHAR2 )
IS
   cursor get_details is
   select a.plan_id,              a.profile_check_id,     a.relational_operator,
          a.criteria_value_low,   a.criteria_value_high,  a.start_date_active,
	  a.end_date_active,      a.use_for_cust_account,
	  b.party_id,             b.cust_account_id,      b.value
   from   csc_plan_headers_b a,
	  csc_prof_check_results b
   where  a.profile_check_id      = b.check_id
   and    a.plan_id               = p_plan_id
   and    a.customized_plan       = 'N'
   and    b.cust_account_id       = p_cust_account_id
   and    a.use_for_cust_account  = 'Y'
   and    sysdate between nvl(a.start_date_active, sysdate )
		      and nvl(a.end_date_active, sysdate ) ;

-- local variable declaration
   l_check_name                       VARCHAR2(240);

   l_plan_id_tbl                      CSC_PLAN_ID_TBL_TYPE;
   l_check_id_tbl                     CSC_CHECK_ID_TBL_TYPE;
   l_relational_operator_tbl          CSC_CHAR_TBL_TYPE;
   l_criteria_value_low_tbl           CSC_CHAR_TBL_TYPE;
   l_criteria_value_high_tbl          CSC_CHAR_TBL_TYPE;
   l_start_date_active_tbl            CSC_DATE_TBL_TYPE;
   l_end_date_active_tbl              CSC_DATE_TBL_TYPE;
   l_use_for_cust_account_tbl         CSC_CHAR_TBL_TYPE;

   l_party_id_tbl                     CSC_PARTY_ID_TBL_TYPE;
   l_cust_id_tbl                      CSC_CUST_ID_TBL_TYPE;
   l_value_tbl                        CSC_CHAR_TBL_TYPE;
BEGIN

   open get_details;
Loop
   fetch get_details
   bulk collect into
      l_plan_id_tbl             , l_check_id_tbl,             l_relational_operator_tbl ,
      l_criteria_value_low_tbl  , l_criteria_value_high_tbl , l_start_date_active_tbl,
      l_end_date_active_tbl     , l_use_for_cust_account_tbl, l_party_id_tbl,
      l_cust_id_tbl             , l_value_tbl LIMIT 2000; /* Bug 4628148: Included Limit clause */

   if ( l_plan_id_tbl.count = 0 ) then
      g_mesg := 'Given request parameters did not retrieve any records to be processed. ' ||
		'Please enter a valid set of parameters.';
      G_ERRBUF := g_mesg;
      g_mesg_line := 'Causes:';
      fnd_file.put_line(fnd_file.log, g_mesg_line);
      g_mesg := g_mesg || g_mesg_line;
      g_mesg_line := '- Specified plan is either customized or has expired.';
      fnd_file.put_line(fnd_file.log, g_mesg_line);
      g_mesg := g_mesg || g_mesg_line;
      g_mesg_line := '- Specified plan is not an account level plan.';
      fnd_file.put_line(fnd_file.log, g_mesg_line);
      g_mesg := g_mesg || g_mesg_line;
      g_mesg_line := '- Profile results for the specified account and/or check of the ' ||
		     'specified plan have not been populated.';
      fnd_file.put_line(fnd_file.log, g_mesg_line);
      g_mesg := g_mesg || g_mesg_line;
      g_mesg_line := 'Action';
      fnd_file.put_line(fnd_file.log, g_mesg_line);
      g_mesg := g_mesg || g_mesg_line;
      g_mesg_line := '- Specify plans that are not customized and have not expired.';
      fnd_file.put_line(fnd_file.log, g_mesg_line);
      g_mesg := g_mesg || g_mesg_line;
      g_mesg_line := '- Specify plans that are account level plans when specifing an account together.';
      fnd_file.put_line(fnd_file.log, g_mesg_line);
      g_mesg := g_mesg || g_mesg_line;
      g_mesg_line := '- Run the Profile Engine to populate the results for the ' ||
		     'specified account and/or check of the specified plan.';
      fnd_file.put_line(fnd_file.log, g_mesg_line);
      g_mesg := g_mesg || g_mesg_line;
   else
      -- call the procedure to make/break the customer - plan association
      add_remove_plan_check (
         P_PLAN_ID_TBL                => l_plan_id_tbl,
         P_RELATIONAL_OPERATOR_TBL    => l_relational_operator_tbl,
         P_CRITERIA_VALUE_LOW_TBL     => l_criteria_value_low_tbl,
         P_CRITERIA_VALUE_HIGH_TBL    => l_criteria_value_high_tbl,
         P_START_DATE_ACTIVE_TBL      => l_start_date_active_tbl,
         P_END_DATE_ACTIVE_TBL        => l_end_date_active_tbl,
         P_USE_FOR_CUST_ACCOUNT_TBL   => l_use_for_cust_account_tbl,
         P_PARTY_ID_TBL               => l_party_id_tbl,
         P_CUST_ID_TBL                => l_cust_id_tbl,
         P_VALUE_TBL                  => l_value_tbl,
         X_RETURN_STATUS              => x_return_status );
   end if;

   Exit when get_details%NOTFOUND;
End Loop;
close get_details;

EXCEPTION
   WHEN OTHERS THEN
      g_mesg := sqlcode || ' ' || sqlerrm;
      fnd_file.put_line(fnd_file.log, g_mesg);
      G_ERRBUF := g_mesg;

END RUN_WITH_PLAN_ACCOUNT;

-- The following procedure will be executed when
-- 1. User enters a check_id and party_id

PROCEDURE RUN_WITH_CHECK_PARTY (
   P_CHECK_ID               IN  NUMBER,
   P_PARTY_ID               IN  NUMBER,
   X_RETURN_STATUS          OUT NOCOPY VARCHAR2 )
IS
   cursor get_details is
   select a.plan_id,              a.profile_check_id,     a.relational_operator,
          a.criteria_value_low,   a.criteria_value_high,  a.start_date_active,
	  a.end_date_active,      a.use_for_cust_account,
	  b.party_id,             b.cust_account_id,      b.value
   from   csc_plan_headers_b a,
	  csc_prof_check_results b
   where  a.profile_check_id      = b.check_id
   and    a.profile_check_id      = p_check_id
   and    a.customized_plan       = 'N'
   and    b.party_id              = p_party_id
   and    b.cust_account_id       is null
   and    a.use_for_cust_account  = 'N'
   and    sysdate between nvl(a.start_date_active, sysdate )
		      and nvl(a.end_date_active, sysdate ) ;

-- local variable declaration
   l_check_name                       VARCHAR2(240);

   l_plan_id_tbl                      CSC_PLAN_ID_TBL_TYPE;
   l_check_id_tbl                     CSC_CHECK_ID_TBL_TYPE;
   l_relational_operator_tbl          CSC_CHAR_TBL_TYPE;
   l_criteria_value_low_tbl           CSC_CHAR_TBL_TYPE;
   l_criteria_value_high_tbl          CSC_CHAR_TBL_TYPE;
   l_start_date_active_tbl            CSC_DATE_TBL_TYPE;
   l_end_date_active_tbl              CSC_DATE_TBL_TYPE;
   l_use_for_cust_account_tbl         CSC_CHAR_TBL_TYPE;

   l_party_id_tbl                     CSC_PARTY_ID_TBL_TYPE;
   l_cust_id_tbl                      CSC_CUST_ID_TBL_TYPE;
   l_value_tbl                        CSC_CHAR_TBL_TYPE;
BEGIN

   open get_details;
Loop
   fetch get_details
   bulk collect into
      l_plan_id_tbl             , l_check_id_tbl,             l_relational_operator_tbl ,
      l_criteria_value_low_tbl  , l_criteria_value_high_tbl , l_start_date_active_tbl,
      l_end_date_active_tbl     , l_use_for_cust_account_tbl, l_party_id_tbl,
      l_cust_id_tbl             , l_value_tbl LIMIT 2000; /* Bug 4628148: Included Limit clause */

   if ( l_plan_id_tbl.count = 0 ) then
      g_mesg := 'Given request parameters did not retrieve any records to be processed. ' ||
		'Please enter a valid set of parameters.';
      G_ERRBUF := g_mesg;
      g_mesg_line := 'Causes:';
      fnd_file.put_line(fnd_file.log, g_mesg_line);
      g_mesg := g_mesg || g_mesg_line;
      g_mesg_line := '- Plans for the specified check are either customized or have expired.';
      fnd_file.put_line(fnd_file.log, g_mesg_line);
      g_mesg := g_mesg || g_mesg_line;
      g_mesg_line := '- Plans for the specified check are account level plans.';
      fnd_file.put_line(fnd_file.log, g_mesg_line);
      g_mesg := g_mesg || g_mesg_line;
      g_mesg_line := '- Profile results for the specified check and/or party have not been populated.';
      fnd_file.put_line(fnd_file.log, g_mesg_line);
      g_mesg := g_mesg || g_mesg_line;
      g_mesg_line := 'Action';
      fnd_file.put_line(fnd_file.log, g_mesg_line);
      g_mesg := g_mesg || g_mesg_line;
      g_mesg_line := '- Specify checks associated to plans that are not customized and have not expired.';
      fnd_file.put_line(fnd_file.log, g_mesg_line);
      g_mesg := g_mesg || g_mesg_line;
      g_mesg_line := '- Specify checks associated to plans that are not at account level.';
      fnd_file.put_line(fnd_file.log, g_mesg_line);
      g_mesg := g_mesg || g_mesg_line;
      g_mesg_line := '- Run the Profile Engine to populate the results for the ' ||
		     'specified party and/or specified check.';
      fnd_file.put_line(fnd_file.log, g_mesg_line);
      g_mesg := g_mesg || g_mesg_line;
   else
      -- call the procedure to make/break the customer - plan association
      add_remove_plan_check (
         P_PLAN_ID_TBL                => l_plan_id_tbl,
         P_RELATIONAL_OPERATOR_TBL    => l_relational_operator_tbl,
         P_CRITERIA_VALUE_LOW_TBL     => l_criteria_value_low_tbl,
         P_CRITERIA_VALUE_HIGH_TBL    => l_criteria_value_high_tbl,
         P_START_DATE_ACTIVE_TBL      => l_start_date_active_tbl,
         P_END_DATE_ACTIVE_TBL        => l_end_date_active_tbl,
         P_USE_FOR_CUST_ACCOUNT_TBL   => l_use_for_cust_account_tbl,
         P_PARTY_ID_TBL               => l_party_id_tbl,
         P_CUST_ID_TBL                => l_cust_id_tbl,
         P_VALUE_TBL                  => l_value_tbl,
         X_RETURN_STATUS              => x_return_status );
   end if;

   Exit when get_details%NOTFOUND;
End Loop;
close get_details;

EXCEPTION
   WHEN OTHERS THEN
      g_mesg := sqlcode || ' ' || sqlerrm;
      fnd_file.put_line(fnd_file.log, g_mesg);
      G_ERRBUF := g_mesg;

END RUN_WITH_CHECK_PARTY;


-- The following procedure will be executed when
-- 1. User enters a check_id and account_id
-- 2. User enters a check_id, party_id and account_id

PROCEDURE RUN_WITH_CHECK_ACCOUNT (
   P_CHECK_ID               IN  NUMBER,
   P_CUST_ACCOUNT_ID        IN  NUMBER,
   X_RETURN_STATUS          OUT NOCOPY VARCHAR2 )
IS
   cursor get_details is
   select a.plan_id,              a.profile_check_id,     a.relational_operator,
          a.criteria_value_low,   a.criteria_value_high,  a.start_date_active,
	  a.end_date_active,      a.use_for_cust_account,
	  b.party_id,             b.cust_account_id,      b.value
   from   csc_plan_headers_b a,
	  csc_prof_check_results b
   where  a.profile_check_id      = b.check_id
   and    a.profile_check_id      = p_check_id
   and    a.customized_plan       = 'N'
   and    b.cust_account_id       = p_cust_account_id
   and    a.use_for_cust_account  = 'Y'
   and    sysdate between nvl(a.start_date_active, sysdate )
		      and nvl(a.end_date_active, sysdate ) ;

-- local variable declaration
   l_check_name                       VARCHAR2(240);

   l_plan_id_tbl                      CSC_PLAN_ID_TBL_TYPE;
   l_check_id_tbl                     CSC_CHECK_ID_TBL_TYPE;
   l_relational_operator_tbl          CSC_CHAR_TBL_TYPE;
   l_criteria_value_low_tbl           CSC_CHAR_TBL_TYPE;
   l_criteria_value_high_tbl          CSC_CHAR_TBL_TYPE;
   l_start_date_active_tbl            CSC_DATE_TBL_TYPE;
   l_end_date_active_tbl              CSC_DATE_TBL_TYPE;
   l_use_for_cust_account_tbl         CSC_CHAR_TBL_TYPE;

   l_party_id_tbl                     CSC_PARTY_ID_TBL_TYPE;
   l_cust_id_tbl                      CSC_CUST_ID_TBL_TYPE;
   l_value_tbl                        CSC_CHAR_TBL_TYPE;
BEGIN

   open get_details;
Loop
   fetch get_details
   bulk collect into
      l_plan_id_tbl             , l_check_id_tbl,             l_relational_operator_tbl ,
      l_criteria_value_low_tbl  , l_criteria_value_high_tbl , l_start_date_active_tbl,
      l_end_date_active_tbl     , l_use_for_cust_account_tbl, l_party_id_tbl,
      l_cust_id_tbl             , l_value_tbl LIMIT 2000; /* Bug 4628148: Included Limit clause */

   if ( l_plan_id_tbl.count = 0 ) then
      g_mesg := 'Given request parameters did not retrieve any records to be processed. ' ||
		'Please enter a valid set of parameters.';
      G_ERRBUF := g_mesg;
      g_mesg_line := 'Causes:';
      fnd_file.put_line(fnd_file.log, g_mesg_line);
      g_mesg := g_mesg || g_mesg_line;
      g_mesg_line := '- Plans for the specified check are either customized or have expired.';
      fnd_file.put_line(fnd_file.log, g_mesg_line);
      g_mesg := g_mesg || g_mesg_line;
      g_mesg_line := '- Plans for the specified check are not account level plans.';
      fnd_file.put_line(fnd_file.log, g_mesg_line);
      g_mesg := g_mesg || g_mesg_line;
      g_mesg_line := '- Profile results for the specified check and/or account have not been populated.';
      fnd_file.put_line(fnd_file.log, g_mesg_line);
      g_mesg := g_mesg || g_mesg_line;
      g_mesg_line := 'Action';
      fnd_file.put_line(fnd_file.log, g_mesg_line);
      g_mesg := g_mesg || g_mesg_line;
      g_mesg_line := '- Specify checks associated to plans that are not customized and have not expired.';
      fnd_file.put_line(fnd_file.log, g_mesg_line);
      g_mesg := g_mesg || g_mesg_line;
      g_mesg_line := '- Specify checks associated to plans that are at account level.';
      fnd_file.put_line(fnd_file.log, g_mesg_line);
      g_mesg := g_mesg || g_mesg_line;
      g_mesg_line := '- Run the Profile Engine to populate the results for the ' ||
		     'specified account and/or specified check.';
      fnd_file.put_line(fnd_file.log, g_mesg_line);
      g_mesg := g_mesg || g_mesg_line;
   else
      -- call the procedure to make/break the customer - plan association
      add_remove_plan_check (
         P_PLAN_ID_TBL                => l_plan_id_tbl,
         P_RELATIONAL_OPERATOR_TBL    => l_relational_operator_tbl,
         P_CRITERIA_VALUE_LOW_TBL     => l_criteria_value_low_tbl,
         P_CRITERIA_VALUE_HIGH_TBL    => l_criteria_value_high_tbl,
         P_START_DATE_ACTIVE_TBL      => l_start_date_active_tbl,
         P_END_DATE_ACTIVE_TBL        => l_end_date_active_tbl,
         P_USE_FOR_CUST_ACCOUNT_TBL   => l_use_for_cust_account_tbl,
         P_PARTY_ID_TBL               => l_party_id_tbl,
         P_CUST_ID_TBL                => l_cust_id_tbl,
         P_VALUE_TBL                  => l_value_tbl,
         X_RETURN_STATUS              => x_return_status );
   end if;

   Exit when get_details%NOTFOUND;
End Loop;
close get_details;

EXCEPTION
   WHEN OTHERS THEN
      g_mesg := sqlcode || ' ' || sqlerrm;
      fnd_file.put_line(fnd_file.log, g_mesg);
      G_ERRBUF := g_mesg;

END RUN_WITH_CHECK_ACCOUNT;

-- The following procedure will be executed when
-- 1. No parameters are specified

PROCEDURE RUN_WITH_ALL (
   X_RETURN_STATUS          OUT NOCOPY VARCHAR2 )
IS
   -- get all plan details; the following logic is followed to get check results
   -- > if the plan is at party level, then get only all the party level results for
   --   that plan's check id;
   -- > if the plan is at account level, then get only all the account level results
   --   for that plan's check id;
   cursor get_details is
   select a.plan_id,              a.profile_check_id,     a.relational_operator,
          a.criteria_value_low,   a.criteria_value_high,  a.start_date_active,
	  a.end_date_active,      a.use_for_cust_account,
	  b.party_id,             b.cust_account_id,      b.value
   from   csc_plan_headers_b a,
	  csc_prof_check_results b
   where  a.profile_check_id      = b.check_id
   and    a.customized_plan       = 'N'
   and  (   ( a.use_for_cust_account = 'N' and
	      b.cust_account_id is null )
	 OR ( a.use_for_cust_account = 'Y' and
              b.cust_account_id is not null )  )
   and    sysdate between nvl(a.start_date_active, sysdate )
		      and nvl(a.end_date_active, sysdate ) ;

-- local variable declaration
   l_check_name                       VARCHAR2(240);

   l_plan_id_tbl                      CSC_PLAN_ID_TBL_TYPE;
   l_check_id_tbl                     CSC_CHECK_ID_TBL_TYPE;
   l_relational_operator_tbl          CSC_CHAR_TBL_TYPE;
   l_criteria_value_low_tbl           CSC_CHAR_TBL_TYPE;
   l_criteria_value_high_tbl          CSC_CHAR_TBL_TYPE;
   l_start_date_active_tbl            CSC_DATE_TBL_TYPE;
   l_end_date_active_tbl              CSC_DATE_TBL_TYPE;
   l_use_for_cust_account_tbl         CSC_CHAR_TBL_TYPE;

   l_party_id_tbl                     CSC_PARTY_ID_TBL_TYPE;
   l_cust_id_tbl                      CSC_CUST_ID_TBL_TYPE;
   l_value_tbl                        CSC_CHAR_TBL_TYPE;
BEGIN

   open get_details;
Loop
   fetch get_details
   bulk collect into
      l_plan_id_tbl             , l_check_id_tbl,             l_relational_operator_tbl ,
      l_criteria_value_low_tbl  , l_criteria_value_high_tbl , l_start_date_active_tbl,
      l_end_date_active_tbl     , l_use_for_cust_account_tbl, l_party_id_tbl,
      l_cust_id_tbl             , l_value_tbl LIMIT 2000;   /* Bug 4628148: Included Bulk Limit */

   if ( l_plan_id_tbl.count = 0 ) then
      g_mesg := 'Given request parameters did not retrieve any records to be processed. ' ||
		'Please enter a valid set of parameters.';
      G_ERRBUF := g_mesg;
      g_mesg_line := 'Causes:';
      fnd_file.put_line(fnd_file.log, g_mesg_line);
      g_mesg := g_mesg || g_mesg_line;
      g_mesg_line := '- All plans have expired.';
      fnd_file.put_line(fnd_file.log, g_mesg_line);
      g_mesg := g_mesg || g_mesg_line;
      g_mesg_line := '- Profile results have not been populated.';
      fnd_file.put_line(fnd_file.log, g_mesg_line);
      g_mesg := g_mesg || g_mesg_line;
      g_mesg_line := 'Action';
      fnd_file.put_line(fnd_file.log, g_mesg_line);
      g_mesg := g_mesg || g_mesg_line;
      g_mesg_line := '- Verify that there are active plans. (ie. end date of plans are a future date)';
      fnd_file.put_line(fnd_file.log, g_mesg_line);
      g_mesg := g_mesg || g_mesg_line;
      g_mesg_line := '- Run the Profile Engine to populate all results.';
      fnd_file.put_line(fnd_file.log, g_mesg_line);
      g_mesg := g_mesg || g_mesg_line;
   else
      -- call the procedure to make/break the customer - plan association
      add_remove_plan_check (
         P_PLAN_ID_TBL                => l_plan_id_tbl,
         P_RELATIONAL_OPERATOR_TBL    => l_relational_operator_tbl,
         P_CRITERIA_VALUE_LOW_TBL     => l_criteria_value_low_tbl,
         P_CRITERIA_VALUE_HIGH_TBL    => l_criteria_value_high_tbl,
         P_START_DATE_ACTIVE_TBL      => l_start_date_active_tbl,
         P_END_DATE_ACTIVE_TBL        => l_end_date_active_tbl,
         P_USE_FOR_CUST_ACCOUNT_TBL   => l_use_for_cust_account_tbl,
         P_PARTY_ID_TBL               => l_party_id_tbl,
         P_CUST_ID_TBL                => l_cust_id_tbl,
         P_VALUE_TBL                  => l_value_tbl,
         X_RETURN_STATUS              => x_return_status );
   end if;

   Exit when get_details%NOTFOUND;
End Loop;
close get_details;

EXCEPTION
   WHEN OTHERS THEN
      g_mesg := sqlcode || ' ' || sqlerrm;
      fnd_file.put_line(fnd_file.log, g_mesg);
      G_ERRBUF := g_mesg;

END RUN_WITH_ALL;


-- The following procedure checks if a party's or account's check results
-- satisfies a plan criteria or not and respectively inserts or deletes
-- the party/account to plan association
PROCEDURE ADD_REMOVE_PLAN_CHECK(
   P_PLAN_ID_TBL                IN   CSC_PLAN_ID_TBL_TYPE,
   P_RELATIONAL_OPERATOR_TBL    IN   CSC_CHAR_TBL_TYPE ,
   P_CRITERIA_VALUE_LOW_TBL     IN   CSC_CHAR_TBL_TYPE ,
   P_CRITERIA_VALUE_HIGH_TBL    IN   CSC_CHAR_TBL_TYPE ,
   P_START_DATE_ACTIVE_TBL      IN   CSC_DATE_TBL_TYPE ,
   P_END_DATE_ACTIVE_TBL        IN   CSC_DATE_TBL_TYPE ,
   P_USE_FOR_CUST_ACCOUNT_TBL   IN   CSC_CHAR_TBL_TYPE ,
   P_PARTY_ID_TBL               IN   CSC_PARTY_ID_TBL_TYPE ,
   P_CUST_ID_TBL                IN   CSC_CUST_ID_TBL_TYPE ,
   P_VALUE_TBL                  IN   CSC_CHAR_TBL_TYPE ,
   X_RETURN_STATUS              OUT  NOCOPY VARCHAR2 )
IS
   l_assign_plan                      VARCHAR2(1) := NULL;

   -- The following tables stores the column values of all the plans that
   -- a customer satisfies. It has an 'add' in its name to denote that these
   -- plans need to be added to this customer in the CSC_CUST_PLANS table.
   L_PLAN_ID_ADD_TBL                  CSC_PLAN_ID_TBL_TYPE;
   L_PARTY_ID_ADD_TBL                 CSC_PARTY_ID_TBL_TYPE;
   L_CUST_ID_ADD_TBL                  CSC_CUST_ID_TBL_TYPE;
   L_START_DATE_ACTIVE_ADD_TBL        CSC_DATE_TBL_TYPE;
   L_END_DATE_ACTIVE_ADD_TBL          CSC_DATE_TBL_TYPE;
   L_ADD_IDX                          NUMBER := 0; -- index for add tables

   -- The following tables stores plan and customer information, when a
   -- customer no longer satisfies a plan criteria. It has a 'del' to its
   -- name to denote that these rows need to be deleted from CSC_CUST_PLANS
   -- table.
   L_PLAN_ID_DEL_TBL                  CSC_PLAN_ID_TBL_TYPE;
   L_PARTY_ID_DEL_TBL                 CSC_PARTY_ID_TBL_TYPE;
   L_CUST_ID_DEL_TBL                  CSC_CUST_ID_TBL_TYPE;
   L_DEL_IDX                          NUMBER := 0; -- index for delete tables

BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   FOR i in 1..p_plan_id_tbl.count
   LOOP
      validate_compare_arguments (
         P_RELATIONAL_OPERATOR        =>  p_relational_operator_tbl(i),
         P_CRITERIA_VALUE_LOW         =>  p_criteria_value_low_tbl(i),
         P_CRITERIA_VALUE_HIGH        =>  p_criteria_value_high_tbl(i),
         X_RETURN_STATUS              =>  x_return_status );

      if ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
         g_mesg := 'Plan criteria not defined correctly for plan_id = ' || p_plan_id_tbl(i);
         fnd_file.put_line(fnd_file.log, g_mesg);
      end if;

      IF ( x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
         if ( p_relational_operator_tbl(i) = '=' ) then
            begin
            if ( to_number(p_value_tbl(i)) = to_number(p_criteria_value_low_tbl(i)) ) then
               l_assign_plan := 'T';
            else
               l_assign_plan := 'F';
            end if;
            exception
               when others then
               if ( p_value_tbl(i) = p_criteria_value_low_tbl(i) ) then
                  l_assign_plan := 'T';
               else
                  l_assign_plan := 'F';
               end if;
            end;
         elsif ( p_relational_operator_tbl(i) = '<>' ) then
            begin
            if ( to_number(p_value_tbl(i)) <> to_number(p_criteria_value_low_tbl(i)) ) then
               l_assign_plan := 'T';
            else
               l_assign_plan := 'F';
            end if;
            exception
               when others then
               if ( p_value_tbl(i) <> p_criteria_value_low_tbl(i) ) then
                  l_assign_plan := 'T';
               else
                  l_assign_plan := 'F';
               end if;
            end;
         elsif ( p_relational_operator_tbl(i) = '<' ) then
            begin
            if ( to_number(p_value_tbl(i)) < to_number(p_criteria_value_low_tbl(i)) ) then
               l_assign_plan := 'T';
            else
               l_assign_plan := 'F';
            end if;
            exception
               when others then
               if ( p_value_tbl(i) < p_criteria_value_low_tbl(i) ) then
                  l_assign_plan := 'T';
               else
                  l_assign_plan := 'F';
               end if;
            end;
         elsif ( p_relational_operator_tbl(i) = '>' ) then
            begin
            if ( to_number(p_value_tbl(i)) > to_number(p_criteria_value_low_tbl(i)) ) then
               l_assign_plan := 'T';
            else
               l_assign_plan := 'F';
            end if;
            exception
               when others then
               if ( p_value_tbl(i) > p_criteria_value_low_tbl(i) ) then
                  l_assign_plan := 'T';
               else
                  l_assign_plan := 'F';
               end if;
            end;
         elsif ( p_relational_operator_tbl(i) = '<=' ) then
            begin
            if ( to_number(p_value_tbl(i)) <= to_number(p_criteria_value_low_tbl(i)) ) then
               l_assign_plan := 'T';
            else
               l_assign_plan := 'F';
            end if;
            exception
               when others then
               if ( p_value_tbl(i) <= p_criteria_value_low_tbl(i) ) then
                  l_assign_plan := 'T';
               else
                  l_assign_plan := 'F';
               end if;
           end;
         elsif ( p_relational_operator_tbl(i) = '>=' ) then
            begin
            if ( to_number(p_value_tbl(i)) >= to_number(p_criteria_value_low_tbl(i)) ) then
               l_assign_plan := 'T';
            else
               l_assign_plan := 'F';
            end if;
            exception
               when others then
               if ( p_value_tbl(i) >= p_criteria_value_low_tbl(i) ) then
                  l_assign_plan := 'T';
               else
                  l_assign_plan := 'F';
               end if;
            end;
         elsif ( p_relational_operator_tbl(i) = 'LIKE' ) then
            if ( instr(p_criteria_value_low_tbl(i), p_value_tbl(i)) = 0 ) then
               l_assign_plan := 'T';
            else
               l_assign_plan := 'F';
            end if;
         elsif ( p_relational_operator_tbl(i) = 'NOT LIKE' ) then
            if ( instr(p_criteria_value_low_tbl(i), p_value_tbl(i)) <> 0 ) then
               l_assign_plan := 'T';
            else
               l_assign_plan := 'F';
            end if;
         elsif ( p_relational_operator_tbl(i) = 'BETWEEN' ) then
            if ( p_value_tbl(i) >= p_criteria_value_low_tbl(i) and
                 p_value_tbl(i) <= p_criteria_value_high_tbl(i) ) then
               l_assign_plan := 'T';
            else
               l_assign_plan := 'F';
            end if;
         elsif ( p_relational_operator_tbl(i) = 'NOT BETWEEN' ) then
            if ( p_value_tbl(i) < p_criteria_value_low_tbl(i) and
                 p_value_tbl(i) > p_criteria_value_high_tbl(i) ) then
               l_assign_plan := 'T';
            else
               l_assign_plan := 'F';
            end if;
         elsif ( p_relational_operator_tbl(i) = 'IS NULL' ) then
            if ( p_value_tbl(i) IS NULL ) then
               l_assign_plan := 'T';
            else
               l_assign_plan := 'F';
            end if;
         elsif ( p_relational_operator_tbl(i) = 'IS NOT NULL' ) then
            if ( p_value_tbl(i) IS NOT NULL ) then
               l_assign_plan := 'T';
            else
               l_assign_plan := 'F';
            end if;
         else
            -- set message that the relational operator is invalid and raise an error.
            l_assign_plan := 'F';
            g_mesg := 'Invalid relational operator for plan_id = ' || p_plan_id_tbl(i);
            fnd_file.put_line(fnd_file.log, g_mesg);
         END IF;

         if ( l_assign_plan = 'T' ) then
            L_ADD_IDX                              := L_ADD_IDX + 1;
            L_PLAN_ID_ADD_TBL(L_ADD_IDX)           := p_plan_id_tbl(i);
            L_START_DATE_ACTIVE_ADD_TBL(L_ADD_IDX) := p_start_date_active_tbl(i);
            L_END_DATE_ACTIVE_ADD_TBL(L_ADD_IDX)   := p_end_date_active_tbl(i);
            L_PARTY_ID_ADD_TBL(L_ADD_IDX)          := p_party_id_tbl(i);
            L_CUST_ID_ADD_TBL(L_ADD_IDX)           := p_cust_id_tbl(i);
         else
            L_DEL_IDX                              := L_DEL_IDX + 1;
            L_PLAN_ID_DEL_TBL(L_DEL_IDX)           := p_plan_id_tbl(i);
            L_PARTY_ID_DEL_TBL(L_DEL_IDX)          := p_party_id_tbl(i);
            L_CUST_ID_DEL_TBL(L_DEL_IDX)           := p_cust_id_tbl(i);
         end if;

         IF ( L_DEL_IDX >= G_COMMIT_TIME ) THEN
            DELETE_CUST_PLANS (
               P_PLAN_ID_TBL            =>  L_PLAN_ID_DEL_TBL,
               P_PARTY_ID_TBL           =>  L_PARTY_ID_DEL_TBL,
               P_CUST_ID_TBL            =>  L_CUST_ID_DEL_TBL,
               X_RETURN_STATUS          =>  x_return_status );

            if ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
               -- generate message in stack.
               -- raise exception
               g_mesg := 'Delete of customer to plan association failed.';
               fnd_file.put_line(fnd_file.log, g_mesg);
               -- RAISE FND_API.G_EXC_ERROR;
            end if;

            L_DEL_IDX := 0;
            L_PLAN_ID_DEL_TBL.DELETE;
            L_PARTY_ID_DEL_TBL.DELETE;
            L_CUST_ID_DEL_TBL.DELETE;
         END IF; -- if L_del_idx = g_commit_time

         IF ( L_ADD_IDX >= G_COMMIT_TIME ) THEN
            ADD_CUST_PLANS (
               p_plan_id_tbl            => L_PLAN_ID_ADD_TBL,
               p_start_date_active_tbl  => L_START_DATE_ACTIVE_ADD_TBL,
               p_end_date_active_tbl    => L_END_DATE_ACTIVE_ADD_TBL,
               p_party_id_tbl           => L_PARTY_ID_ADD_TBL,
               p_cust_id_tbl            => L_CUST_ID_ADD_TBL,
               x_return_status          => x_return_status );

            if ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
               -- generate message in stack.
               -- raise exception
               g_mesg := 'Insert of new customer to plan association failed.';
               fnd_file.put_line(fnd_file.log, g_mesg);
               -- RAISE FND_API.G_EXC_ERROR;
            end if;

            L_ADD_IDX := 0;
            L_PLAN_ID_ADD_TBL.DELETE;
            L_START_DATE_ACTIVE_ADD_TBL.DELETE;
            L_END_DATE_ACTIVE_ADD_TBL.DELETE;
            L_PARTY_ID_ADD_TBL.DELETE;
            L_CUST_ID_ADD_TBL.DELETE;
         END IF; -- if L_add_idx >= g_commit_time
      END IF; -- if x_return_status = FND_API.G_RET_STS_SUCCESS
   END LOOP; -- for i in 1..l_plan_id_sel_tbl.count

   IF ( L_DEL_IDX > 0 ) THEN
      DELETE_CUST_PLANS (
         P_PLAN_ID_TBL            =>  L_PLAN_ID_DEL_TBL,
         P_PARTY_ID_TBL           =>  L_PARTY_ID_DEL_TBL,
         P_CUST_ID_TBL            =>  L_CUST_ID_DEL_TBL,
         X_RETURN_STATUS          =>  x_return_status );

         L_DEL_IDX := 0;
         if ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
            -- generate message in stack.
            -- raise exception
            g_mesg := 'Delete of customer to plan association failed.';
            fnd_file.put_line(fnd_file.log, g_mesg);
            -- RAISE FND_API.G_EXC_ERROR;
         end if;
   END IF; -- if g_del_id > 0

   IF ( L_ADD_IDX > 0 ) THEN
      ADD_CUST_PLANS (
         p_plan_id_tbl            => L_PLAN_ID_ADD_TBL,
         p_start_date_active_tbl  => L_START_DATE_ACTIVE_ADD_TBL,
         p_end_date_active_tbl    => L_END_DATE_ACTIVE_ADD_TBL,
         p_party_id_tbl           => L_PARTY_ID_ADD_TBL,
         p_cust_id_tbl            => L_CUST_ID_ADD_TBL,
         x_return_status          => x_return_status );
         if ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
            -- generate message in stack.
            -- raise exception
            g_mesg := 'Insert of new customer to plan association failed.';
            fnd_file.put_line(fnd_file.log, g_mesg);
            -- RAISE FND_API.G_EXC_ERROR;
         end if;
   END IF; -- if L_add_idx > 0

END ADD_REMOVE_PLAN_CHECK;

-- depending on the relational operator, the plan criteria_valu_low and high should or should not be
-- specified. This procedure performs this validation.
PROCEDURE VALIDATE_COMPARE_ARGUMENTS (
    P_RELATIONAL_OPERATOR        IN   VARCHAR2,
    P_CRITERIA_VALUE_LOW         IN   VARCHAR2,
    P_CRITERIA_VALUE_HIGH        IN   VARCHAR2,
    X_RETURN_STATUS              OUT  NOCOPY VARCHAR2 )
IS
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   IF ( p_relational_operator =  '='      OR
	   p_relational_operator =  '<>'     OR
	   p_relational_operator =  '>'      OR
	   p_relational_operator =  '<'      OR
	   p_relational_operator =  '>='     OR
	   p_relational_operator =  '<='     OR
	   p_relational_operator =  'IN'     OR
	   p_relational_operator =  'NOT IN' OR
	   p_relational_operator =  'LIKE'   OR
	   p_relational_operator =  'NOT LIKE' )
   THEN
	 if ( p_criteria_value_low IS NULL OR p_criteria_value_high IS NOT NULL ) then
	    g_mesg := 'Invalid arguments. Cannot perform comparison between check results and ' ||
			    'plan criteria. Check the relational operator, low value and high value.';
         fnd_file.put_line(fnd_file.log, g_mesg);
	    x_return_status := FND_API.G_RET_STS_ERROR;
      end if;
   ELSIF ( p_relational_operator =  'BETWEEN' OR
           p_relational_operator =  'NOT BETWEEN' )
   THEN
	 if ( p_criteria_value_low IS NULL OR p_criteria_value_high IS NULL ) then
	    g_mesg := 'Invalid arguments. Cannot perform comparison between check results and ' ||
			    'plan criteria. Check the relational operator, low value and high value.';
         fnd_file.put_line(fnd_file.log, g_mesg);
	    x_return_status := FND_API.G_RET_STS_ERROR;
      end if;
   ELSIF ( p_relational_operator =  'IS NULL'  OR
		 p_relational_operator =  'IS NOT NULL' )
   THEN
	 if ( p_criteria_value_low IS NOT NULL OR p_criteria_value_high IS NOT NULL ) then
	    g_mesg := 'Invalid arguments. Cannot perform comparison between check results and ' ||
			    'plan criteria. Check the relational operator, low value and high value.';
         fnd_file.put_line(fnd_file.log, g_mesg);
	    x_return_status := FND_API.G_RET_STS_ERROR;
      end if;
   END IF;
END VALIDATE_COMPARE_ARGUMENTS;

PROCEDURE ADD_CUST_PLANS (
    P_PLAN_ID_TBL                IN   CSC_PLAN_ID_TBL_TYPE,
    P_START_DATE_ACTIVE_TBL      IN   CSC_DATE_TBL_TYPE,
    P_END_DATE_ACTIVE_TBL        IN   CSC_DATE_TBL_TYPE,
    P_PARTY_ID_TBL               IN   CSC_PARTY_ID_TBL_TYPE,
    P_CUST_ID_TBL                IN   CSC_CUST_ID_TBL_TYPE,
    X_RETURN_STATUS              OUT  NOCOPY VARCHAR2 )
IS
   l_api_name                CONSTANT VARCHAR2(30) := 'ADD_CUST_PLANS';
   l_api_version_number      CONSTANT NUMBER       := 1.0;

   -- Dates to track the start and end time of the bulk insert into CSC_CUST_PLANS.
   -- These are then used as a filter in the bulk insert of the AUDIT table.
   l_ins_start_date                   DATE;
   l_ins_end_date                     DATE;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT ADD_CUST_PLANS_PVT;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- ******************************************************************
   -- Validate Environment
   -- ******************************************************************
   IF FND_GLOBAL.User_Id IS NULL THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         FND_MESSAGE.Set_Name(CSC_CORE_UTILS_PVT.G_APP_SHORTNAME, 'UT_CANNOT_GET_PROFILE_VALUE');
         FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   select sysdate
   into   l_ins_start_date
   from   sys.dual;

   FORALL i in 1..p_plan_id_tbl.count
      INSERT INTO csc_cust_plans (
         CUST_PLAN_ID,                   PLAN_ID,                PARTY_ID,
         CUST_ACCOUNT_ID,                START_DATE_ACTIVE,
         END_DATE_ACTIVE,                MANUAL_FLAG,            PLAN_STATUS_CODE,
         REQUEST_ID,                     PROGRAM_APPLICATION_ID, PROGRAM_ID,
         PROGRAM_UPDATE_DATE,            LAST_UPDATE_DATE,       CREATION_DATE,
         LAST_UPDATED_BY,                CREATED_BY,             LAST_UPDATE_LOGIN,
         ATTRIBUTE1,                     ATTRIBUTE2,             ATTRIBUTE3,
         ATTRIBUTE4,                     ATTRIBUTE5,             ATTRIBUTE6,
         ATTRIBUTE7,                     ATTRIBUTE8,             ATTRIBUTE9,
         ATTRIBUTE10,                    ATTRIBUTE11,            ATTRIBUTE12,
         ATTRIBUTE13,                    ATTRIBUTE14,            ATTRIBUTE15,
         ATTRIBUTE_CATEGORY,             OBJECT_VERSION_NUMBER )
      SELECT
	    CSC_CUST_PLANS_S.NEXTVAL,       p_plan_id_tbl(i),       p_party_id_tbl(i),
	    p_cust_id_tbl(i),               p_start_date_active_tbl(i),
	    p_end_date_active_tbl(i),       'N',                    CSC_CORE_UTILS_PVT.APPLY_PLAN,
	    NULL,                           NULL,                   NULL,
	    NULL,                           sysdate,                sysdate,
	    FND_GLOBAL.USER_ID,             FND_GLOBAL.USER_ID,     FND_GLOBAL.CONC_LOGIN_ID,
	    NULL,                           NULL,                   NULL,
	    NULL,                           NULL,                   NULL,
	    NULL,                           NULL,                   NULL,
	    NULL,                           NULL,                   NULL,
	    NULL,                           NULL,                   NULL,
	    NULL,                           1
      FROM  SYS.DUAL
	 WHERE NOT EXISTS ( select 1
					from   csc_cust_plans
					where  plan_id                  = p_plan_id_tbl(i)
					and    party_id                 = p_party_id_tbl(i)
					and    nvl(cust_account_id, 0)  = nvl(p_cust_id_tbl(i), 0)
				    );

   select sysdate
   into   l_ins_end_date
   from   sys.dual;

   FORALL i in 1..p_party_id_tbl.count
	 INSERT INTO csc_cust_plans_audit (
         PLAN_AUDIT_ID,           PLAN_ID,                   PARTY_ID,
         CUST_ACCOUNT_ID,         PLAN_STATUS_CODE,
         REQUEST_ID,              PROGRAM_APPLICATION_ID,    PROGRAM_ID,
         PROGRAM_UPDATE_DATE,     LAST_UPDATE_DATE,          CREATION_DATE,
         LAST_UPDATED_BY,         CREATED_BY,                LAST_UPDATE_LOGIN,
         ATTRIBUTE1,              ATTRIBUTE2,                ATTRIBUTE3,
         ATTRIBUTE4,              ATTRIBUTE5,                ATTRIBUTE6,
         ATTRIBUTE7,              ATTRIBUTE8,                ATTRIBUTE9,
         ATTRIBUTE10,             ATTRIBUTE11,               ATTRIBUTE12,
         ATTRIBUTE13,             ATTRIBUTE14,               ATTRIBUTE15,
         ATTRIBUTE_CATEGORY,      OBJECT_VERSION_NUMBER )
      SELECT
	    CSC_CUST_PLANS_AUDIT_S.NEXTVAL, p_plan_id_tbl(i),   p_party_id_tbl(i),
	    p_cust_id_tbl(i),        CSC_CORE_UTILS_PVT.APPLY_PLAN,
	    NULL,                    NULL,                      NULL,
	    NULL,                    SYSDATE,                   SYSDATE,
	    FND_GLOBAL.USER_ID,      FND_GLOBAL.USER_ID,        FND_GLOBAL.CONC_LOGIN_ID,
	    NULL,                    NULL,                      NULL,
	    NULL,                    NULL,                      NULL,
	    NULL,                    NULL,                      NULL,
	    NULL,                    NULL,                      NULL,
	    NULL,                    NULL,                      NULL,
	    NULL,                    1
      FROM SYS.DUAL
	 WHERE EXISTS ( select 1
				 from   csc_cust_plans
				 where  plan_id  = p_plan_id_tbl(i)
				 and    party_id = p_party_id_tbl(i)
				 and    creation_date between l_ins_start_date and l_ins_end_date);

EXCEPTION
   WHEN OTHERS THEN
	 g_mesg := sqlcode || ' ' || sqlerrm;
      fnd_file.put_line(fnd_file.log, g_mesg);
	 G_ERRBUF := g_mesg;

END ADD_CUST_PLANS;

PROCEDURE DELETE_CUST_PLANS (
    P_PLAN_ID_TBL                IN   CSC_PLAN_ID_TBL_TYPE,
    P_PARTY_ID_TBL               IN   CSC_PARTY_ID_TBL_TYPE,
    P_CUST_ID_TBL                IN   CSC_CUST_ID_TBL_TYPE,
    X_RETURN_STATUS              OUT  NOCOPY VARCHAR2 )
IS
   l_api_name                CONSTANT VARCHAR2(30) := 'DELETE_CUST_PLANS';
   l_api_version_number      CONSTANT NUMBER       := 1.0;

   l_plan_id_tbl                      CSC_PLAN_ID_TBL_TYPE;
   l_party_id_tbl                     CSC_PARTY_ID_TBL_TYPE;
   l_cust_id_tbl                      CSC_CUST_ID_TBL_TYPE;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT DELETE_CUST_PLANS_PVT;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- ******************************************************************
   -- Validate Environment
   -- ******************************************************************
   IF FND_GLOBAL.User_Id IS NULL THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         FND_MESSAGE.Set_Name(CSC_CORE_UTILS_PVT.G_APP_SHORTNAME, 'UT_CANNOT_GET_PROFILE_VALUE');
         FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   FORALL i in 1..P_PLAN_ID_TBL.COUNT
	 DELETE FROM csc_cust_plans
	 WHERE  plan_id                 = p_plan_id_tbl(i)
	 AND    party_id                = p_party_id_tbl(i)
	 AND    nvl(cust_account_id,0)  = nvl(p_cust_id_tbl(i), nvl(cust_account_id,0) )
	 AND    manual_flag             = 'N'
   RETURNING plan_id, party_id, cust_account_id
   BULK COLLECT INTO  l_plan_id_tbl, l_party_id_tbl, l_cust_id_tbl;

   FORALL i in 1..l_party_id_tbl.count
	 INSERT INTO csc_cust_plans_audit (
         PLAN_AUDIT_ID,           PLAN_ID,                   PARTY_ID,
         CUST_ACCOUNT_ID,         PLAN_STATUS_CODE,
         REQUEST_ID,              PROGRAM_APPLICATION_ID,    PROGRAM_ID,
         PROGRAM_UPDATE_DATE,     LAST_UPDATE_DATE,          CREATION_DATE,
         LAST_UPDATED_BY,         CREATED_BY,                LAST_UPDATE_LOGIN,
         ATTRIBUTE1,              ATTRIBUTE2,                ATTRIBUTE3,
         ATTRIBUTE4,              ATTRIBUTE5,                ATTRIBUTE6,
         ATTRIBUTE7,              ATTRIBUTE8,                ATTRIBUTE9,
         ATTRIBUTE10,             ATTRIBUTE11,               ATTRIBUTE12,
         ATTRIBUTE13,             ATTRIBUTE14,               ATTRIBUTE15,
         ATTRIBUTE_CATEGORY,      OBJECT_VERSION_NUMBER )
      SELECT
	    CSC_CUST_PLANS_AUDIT_S.NEXTVAL, l_plan_id_tbl(i),   l_party_id_tbl(i),
	    l_cust_id_tbl(i),        CSC_CORE_UTILS_PVT.REMOVE_PLAN,
	    NULL,                    NULL,                      NULL,
	    NULL,                    SYSDATE,                   SYSDATE,
	    FND_GLOBAL.USER_ID,      FND_GLOBAL.USER_ID,        FND_GLOBAL.CONC_LOGIN_ID,
	    NULL,                    NULL,                      NULL,
	    NULL,                    NULL,                      NULL,
	    NULL,                    NULL,                      NULL,
	    NULL,                    NULL,                      NULL,
	    NULL,                    NULL,                      NULL,
	    NULL,                    1
      FROM SYS.DUAL;

EXCEPTION
   WHEN OTHERS THEN
	 g_mesg := sqlcode || ' ' || sqlerrm;
      fnd_file.put_line(fnd_file.log, g_mesg);
	 G_ERRBUF := g_mesg;

END DELETE_CUST_PLANS;


END CSC_PLAN_ASSIGNMENT_PKG;

/
