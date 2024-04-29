--------------------------------------------------------
--  DDL for Package CSC_PLAN_ASSIGNMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSC_PLAN_ASSIGNMENT_PKG" AUTHID CURRENT_USER as
/* $Header: cscvengs.pls 120.0 2005/05/30 15:52:54 appldev noship $ */
-- Start of Comments
-- Package name     : CSC_PLAN_ASSIGNMENT_PKG
-- Purpose          : Plan defnitions by itself are dummy entities in the system, and
--                    means nothing until it is associated to customer(s). This association
--                    is done by the procedures and function defined in this package spec.
--                    These procedures evaluate the results of the customer profile checks
--                    for each customer and its account, compares it with the plan criteria,
--                    and if met, stores the association of the plan and the customer.
-- History          :
-- MM-DD-YYYY    NAME          MODIFICATIONS
-- 12-09-1999    dejoseph      Created.
-- 01-03-2000    dejoseph      'Arcs'ed in for third code freeze. (10-JAN-2000)
-- 01-31-2000    dejoseph      'Arcs'ed in for fourth code freeze. (07-FEB-2000)
-- 02-13-2000    dejoseph      'Arcs'ed on for fifth code freeze. (21-FEB-2000)
-- 02-28-2000    dejoseph      'Arcs'ed on for sixth code freeze. (06-MAR-2000)
-- 04-10-2000    dejoseph      Removed reference to cust_account_org in lieu of TCA's
--                             decision to drop column org_id from hz_cust_accounts.
--
-- 04-28-2000    dejoseph      Replace reference to jtf_cust_accounts_v with jtf_cust_accounts_all_v.
-- 05-11-2000	 dmontefa      Added the 'OUT NOCOPY ' parameters, x_errbuf, x_retcode
-- 08-09-2000    dejoseph      Included a parameter in procedure add_remove_plan_check. Generally
--                             modified engine to run for all plans and parties if no parameters
--                             are specified. Fix to bug # 1372050.
-- 01-30-2002    dejoseph      Included the dbdrv command for DB driver generation.
--                             Made the following change to clean up the Plans engine to
--                             1. Function as intended and 2. Perform efficiently.
--                             Ref. Bug #s - 2030164, 1745488
-- 03-15-2002    dejoseph      Added the checkfile command
-- 11-12-2002	 bhroy		NOCOPY changes made
-- 11-28-2002	 bhroy		FND_API.G_MISS_XXX defaults removed
--
-- NOTE             :
-- End of Comments
--

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;

/**************************** TYPE DEFNITIONS ****************************/

TYPE CSC_PARTY_ACCT_REC_TYPE IS RECORD (
	  PARTY_ID                    NUMBER,
	  CUST_ACCOUNT_ID             NUMBER);

TYPE CSC_PARTY_ACCT_TBL_TYPE       IS TABLE OF CSC_PARTY_ACCT_REC_TYPE
							INDEX BY BINARY_INTEGER;
G_MISS_PARTY_ACCT_TBL              CSC_PARTY_ACCT_TBL_TYPE;

TYPE CSC_NUM_TBL_TYPE              IS TABLE OF NUMBER
							INDEX BY BINARY_INTEGER;
G_EMPTY_NUM_TBL                    CSC_NUM_TBL_TYPE;

TYPE CSC_CHAR_TBL_TYPE             IS TABLE OF VARCHAR2(240)
							INDEX BY BINARY_INTEGER;
G_EMPTY_CHAR_TBL                   CSC_CHAR_TBL_TYPE;

TYPE CSC_PARTY_ID_TBL_TYPE         IS TABLE OF NUMBER
					          INDEX BY BINARY_INTEGER;
G_EMPTY_PARTY_ID_TBL               CSC_PARTY_ID_TBL_TYPE;

TYPE CSC_PLAN_ID_TBL_TYPE          IS TABLE OF NUMBER
                                   INDEX BY BINARY_INTEGER;
G_EMPTY_PLAN_ID_TBL                CSC_PLAN_ID_TBL_TYPE;

TYPE CSC_CUST_ID_TBL_TYPE          IS TABLE OF NUMBER
                                   INDEX BY BINARY_INTEGER;
G_EMPTY_CUST_ID_TBL                CSC_CUST_ID_TBL_TYPE;

TYPE CSC_DATE_TBL_TYPE             IS TABLE OF DATE
                                   INDEX BY BINARY_INTEGER;
G_EMPTY_DATE_TBL                   CSC_DATE_TBL_TYPE;

TYPE CSC_CHECK_ID_TBL_TYPE         IS TABLE OF NUMBER
                                   INDEX BY BINARY_INTEGER;
G_EMPTY_CHECK_ID_TBL               CSC_CHECK_ID_TBL_TYPE;

/************************** END TYPE DEFNITIONS ***************************/

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name: RUN_PLAN_ENGINE
   --   Type    : Private
   --   Pre-Req :
   --   Function: Invokes the plan engine. The plan engine can be invoked
   --   when any of the three scenarios occur.
   --   1> Invoked from the customer profile engine.(when profile engine is
   --      executed).
   --   2> Invoked when plan defnitions change;
   --   3> Invoked when a party or party account is added/deleted
   --   Depending on the passed in parameters the appropiate procedure is
   --   executed to make/break the customer to plan association.
   --   Parameters:
   --   IN
   --       p_plan_id                 IN   NUMBER  Optional Default = NULL
   --       p_check_id                IN   NUMBER  Optional Default = NULL
   --       p_party_id                IN   NUMBER  Optional Default = NULL
   --       p_cust_account_id         IN   NUMBER  Optional Default = NULL
   --       x_errbuf                  OUT   NOCOPY VARCHAR2
   --       x_retcode                 OUT   NOCOPY NUMBER
   --
   --   Version : Current version 1.0
   --
   --   End of Comments
   --
PROCEDURE RUN_PLAN_ENGINE (
    X_ERRBUF			        OUT  NOCOPY VARCHAR2,
    X_RETCODE			        OUT  NOCOPY NUMBER,
    P_PLAN_ID                    IN   NUMBER       := NULL,
    P_CHECK_ID                   IN   NUMBER       := NULL,
    P_PARTY_ID                   IN   NUMBER       := NULL,
    P_CUST_ACCOUNT_ID            IN   NUMBER       := NULL );

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name: RUN_WITH_PLAN_ID
   --   Type    : Private
   --   Pre-Req :
   --   Function: Calls add_remove_plan_check with passed in plan_id.
   --   Parameters:
   --   IN
   --       P_PLAN_ID                 IN   NUMBER
   --
   --   OUT NOCOPY
   --       X_RETURN_STATUS           OUT  NOCOPY VARCHAR2
   --   Version : Current version 1.0
   --
   --   End of Comments
   --
PROCEDURE RUN_WITH_PLAN_ID (
   P_PLAN_ID                     IN   NUMBER,
   X_RETURN_STATUS               OUT  NOCOPY VARCHAR2 );

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name: RUN_WITH_CHECK_ID
   --   Type    : Private
   --   Pre-Req :
   --   Function: Calls add_remove_plan_check with passed in check_id.
   --   Parameters:
   --   IN
   --       P_CHECK_ID                IN   NUMBER
   --
   --
   --   OUT NOCOPY
   --       X_RETURN_STATUS           OUT  NOCOPY VARCHAR2
   --   Version : Current version 1.0
   --
   --   End of Comments
   --
PROCEDURE RUN_WITH_CHECK_ID (
   P_CHECK_ID                   IN   NUMBER,
   X_RETURN_STATUS              OUT  NOCOPY VARCHAR2 );

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name: RUN_WITH_PARTY_ID
   --   Type    : Private
   --   Pre-Req :
   --   Function: Calls add_remove_plan_check with passed in party_id.
   --   Parameters:
   --   IN
   --       P_PARTY_ID                IN   NUMBER
   --
   --       X_RETURN_STATUS           OUT  NOCOPY VARCHAR2
   --   Version : Current version 1.0
   --
   --   End of Comments
   --
PROCEDURE RUN_WITH_PARTY_ID (
   P_PARTY_ID                   IN   NUMBER,
   X_RETURN_STATUS              OUT  NOCOPY VARCHAR2 );

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name: RUN_WITH_ACCOUNT_ID
   --   Type    : Private
   --   Pre-Req :
   --   Function: Calls add_remove_plan_check with passed in account_id.
   --   Parameters:
   --   IN
   --       P_CUST_ACCOUNT_ID         IN   NUMBER
   --
   --   OUT NOCOPY
   --       X_RETURN_STATUS           OUT   NOCOPY VARCHAR2
   --   Version : Current version 1.0
   --
   --   End of Comments
   --
PROCEDURE RUN_WITH_ACCOUNT_ID (
   P_CUST_ACCOUNT_ID            IN   NUMBER,
   X_RETURN_STATUS              OUT  NOCOPY VARCHAR2 );

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name: RUN_WITH_PLAN_PARTY
   --   Type    : Private
   --   Pre-Req :
   --   Function: Calls add_remove_plan_check with passed in plan_id and
   --             party_id.
   --   Parameters:
   --   IN
   --       P_PLAN_ID                 IN   NUMBER
   --       P_PARTY_ID                IN   NUMBER
   --
   --   OUT NOCOPY
   --       X_RETURN_STATUS           OUT   NOCOPY VARCHAR2
   --   Version : Current version 1.0
   --
   --   End of Comments
   --
PROCEDURE RUN_WITH_PLAN_PARTY (
   P_PLAN_ID                    IN   NUMBER,
   P_PARTY_ID                   IN   NUMBER,
   X_RETURN_STATUS              OUT  NOCOPY VARCHAR2 );

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name: RUN_WITH_PLAN_ACCOUNT
   --   Type    : Private
   --   Pre-Req :
   --   Function: Calls add_remove_plan_check with passed in plan_id and
   --             account_id.
   --   Parameters:
   --   IN
   --       P_PLAN_ID                 IN   NUMBER
   --       P_CUST_ACCOUNT_ID         IN   NUMBER
   --
   --   OUT NOCOPY
   --       X_RETURN_STATUS           OUT  NOCOPY  VARCHAR2
   --   Version : Current version 1.0
   --
   --   End of Comments
   --
PROCEDURE RUN_WITH_PLAN_ACCOUNT (
   P_PLAN_ID                    IN   NUMBER,
   P_CUST_ACCOUNT_ID            IN   NUMBER,
   X_RETURN_STATUS              OUT  NOCOPY VARCHAR2 );

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name: RUN_WITH_CHECK_PARTY
   --   Type    : Private
   --   Pre-Req :
   --   Function: Calls add_remove_plan_check with passed in check_id and
   --             party_id.
   --   Parameters:
   --   IN
   --       P_CHECK_ID                IN   NUMBER
   --       P_PARTY_ID                IN   NUMBER
   --
   --   OUT NOCOPY
   --       X_RETURN_STATUS           OUT   NOCOPY VARCHAR2
   --   Version : Current version 1.0
   --
   --   End of Comments
   --
PROCEDURE RUN_WITH_CHECK_PARTY (
   P_CHECK_ID                   IN   NUMBER,
   P_PARTY_ID                   IN   NUMBER,
   X_RETURN_STATUS              OUT  NOCOPY VARCHAR2 );

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name: RUN_WITH_CHECK_ACCOUNT
   --   Type    : Private
   --   Pre-Req :
   --   Function: Calls add_remove_plan_check with passed in check_id and
   --             account_id.
   --   Parameters:
   --   IN
   --       P_CHECK_ID                IN   NUMBER
   --       P_CUST_ACCOUNT_ID         IN   NUMBER
   --
   --   OUT NOCOPY
   --       X_RETURN_STATUS           OUT  NOCOPY  VARCHAR2
   --   Version : Current version 1.0
   --
   --   End of Comments
   --
PROCEDURE RUN_WITH_CHECK_ACCOUNT (
   P_CHECK_ID                   IN   NUMBER,
   P_CUST_ACCOUNT_ID            IN   NUMBER,
   X_RETURN_STATUS              OUT  NOCOPY VARCHAR2 );

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name: RUN_WITH_ALL
   --   Type    : Private
   --   Pre-Req :
   --   Function: Calls add_remove_plan_check with all plans and their
   --             coresponding check results for all parties and accoutns.
   --   Parameters:
   --   IN
   --     NONE
   --   OUT NOCOPY
   --       X_RETURN_STATUS           OUT  NOCOPY  VARCHAR2
   --   Version : Current version 1.0
   --
   --   End of Comments
   --
PROCEDURE RUN_WITH_ALL (
   X_RETURN_STATUS              OUT  NOCOPY VARCHAR2 );

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name: ADD_REMOVE_PLAN_CHECK
   --   Type    : Private
   --   Pre-Req :
   --   Function: Given the plan criteria, and the profile check result for each
   --             customer,  this  procedure  determines whether the customer is
   --             eligible for  the  plan or  not.  If eligible, the customer is
   --             assigned  the plan throught the ADD_CUST_PLANS procedure, else
   --             the cust.- plan association is delete by the DELETE_CUST_PLANS
   --             procedure.
   --   Parameters:
   --   IN
   --       P_PLAN_ID_TBL             IN   CSC_PLAN_ID_TBL_TYPE   Required
   --       P_RELATIONAL_OPERATOR_TBL IN   CSC_CHAR_TBL_TYPE      Required
   --       P_CRITERIA_VALUE_LOW_TBL  IN   CSC_CHAR_TBL_TYPE      Required
   --       P_CRITERIA_VALUE_HIGH_TBL IN   CSC_CHAR_TBL_TYPE      Required
   --       P_START_DATE_ACTIVE_TBL   IN   CSC_DATE_TBL_TYPE      Required
   --       P_END_DATE_ACTIVE_TBL     IN   CSC_DATE_TBL_TYPE      Required
   --       P_PARTY_ID_TBL            IN   CSC_PARTY_ID_TBL_TYPE  Required
   --       P_CUST_ID_TBL             IN   CSC_CUST_ID_TBL_TYPE   Required
   --       P_VALUE_TBL               IN   CSC_CHAR_TBL_TYPE      Required
   --
   --   OUT NOCOPY
   --       X_RETURN_STATUS           OUT  NOCOPY  VARCHAR2
   --   Version : Current version 1.0
   --
   --   End of Comments
   --
PROCEDURE ADD_REMOVE_PLAN_CHECK (
    P_PLAN_ID_TBL                IN   CSC_PLAN_ID_TBL_TYPE :=
							   G_EMPTY_PLAN_ID_TBL,
    P_RELATIONAL_OPERATOR_TBL    IN   CSC_CHAR_TBL_TYPE :=
							   G_EMPTY_CHAR_TBL,
    P_CRITERIA_VALUE_LOW_TBL     IN   CSC_CHAR_TBL_TYPE :=
							   G_EMPTY_CHAR_TBL,
    P_CRITERIA_VALUE_HIGH_TBL    IN   CSC_CHAR_TBL_TYPE :=
							   G_EMPTY_CHAR_TBL,
    P_START_DATE_ACTIVE_TBL      IN   CSC_DATE_TBL_TYPE :=
							   G_EMPTY_DATE_TBL,
    P_END_DATE_ACTIVE_TBL        IN   CSC_DATE_TBL_TYPE :=
							   G_EMPTY_DATE_TBL,
    P_USE_FOR_CUST_ACCOUNT_TBL   IN   CSC_CHAR_TBL_TYPE :=
							   G_EMPTY_CHAR_TBL,
    P_PARTY_ID_TBL               IN   CSC_PARTY_ID_TBL_TYPE :=
							   G_EMPTY_PARTY_ID_TBL,
    P_CUST_ID_TBL                IN   CSC_CUST_ID_TBL_TYPE :=
							   G_EMPTY_CUST_ID_TBL,
    P_VALUE_TBL                  IN   CSC_CHAR_TBL_TYPE :=
							   G_EMPTY_CHAR_TBL,
    X_RETURN_STATUS              OUT  NOCOPY VARCHAR2 );

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name: Add_Cust_Plans
   --   Type    : Private
   --   Pre-Req :
   --   Function: Creates record(s) in CSC_CUST_PLANS for those customers who are
   --             eligible for the plan.
   --   Note    : Use BULK INSERTS rather that individual inserts through the API.
   --   Parameters:
   --   IN
   --       p_plan_id_tbl             IN   CSC_PLAN_ID_TBL_TYPE
   --       p_start_date_active_tbl   IN   CSC_DATE_TBL_TYPE
   --       p_end_date_active_tbl     IN   CSC_DATE_TBL_TYPE
   --       p_party_id_tbl            IN   CSC_PARTY_ID_TBL_TYPE
   --       p_cust_id_tbl             IN   CSC_CUST_ID_TBL_TYPE
   --
   --   OUT NOCOPY :
   --       x_return_status           OUT  NOCOPY  VARCHAR2
   --   Version : Current version 1.0
   --
   --   End of Comments
   --

PROCEDURE ADD_CUST_PLANS (
    P_PLAN_ID_TBL                IN   CSC_PLAN_ID_TBL_TYPE,
    P_START_DATE_ACTIVE_TBL      IN   CSC_DATE_TBL_TYPE,
    P_END_DATE_ACTIVE_TBL        IN   CSC_DATE_TBL_TYPE,
    P_PARTY_ID_TBL               IN   CSC_PARTY_ID_TBL_TYPE,
    P_CUST_ID_TBL                IN   CSC_CUST_ID_TBL_TYPE,
    X_RETURN_STATUS              OUT  NOCOPY VARCHAR2 );

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name: Delete_Cust_Plans
   --   Type    : Private
   --   Pre-Req :
   --   Function: Deletes records from CSC_CUST_PLANS, if customers are no more
   --             eligible for that plan.
   --   Note    : Use BULK DELETES rather that individual deletes through the API.
   --   Parameters:
   --   IN
   --       p_plan_id_tbl             IN   CSC_PLAN_ID_TBL_TYPE
   --       p_party_id_tbl            IN   CSC_PARTY_ID_TBL_TYPE
   --       p_cust_id_tbl             IN   CSC_CUST_ID_TBL_TYPE
   --
   --   OUT NOCOPY :
   --       x_return_status           OUT  NOCOPY  VARCHAR2
   --   Version : Current version 1.0
   --
   --   End of Comments
   --
PROCEDURE DELETE_CUST_PLANS (
    P_PLAN_ID_TBL                IN   CSC_PLAN_ID_TBL_TYPE,
    P_PARTY_ID_TBL               IN   CSC_PARTY_ID_TBL_TYPE,
    P_CUST_ID_TBL                IN   CSC_CUST_ID_TBL_TYPE,
    X_RETURN_STATUS              OUT  NOCOPY VARCHAR2 );

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name: VALIDATE_COMPARE_ARGUMENTS
   --   Type    : Private
   --   Pre-Req :
   --   Function: The relational operator forms the basis of the check to be
   --             performed between the profile result and the plan criteria
   --             values. The relational operator can have the following
   --             valid values:
   --             =,<>,>, <, >=, <=, IN, NOT IN, LIKE, NOT LIKE, BETWEEN,
   --             NOT BETWEEN, IS NULL and IS NOT NULL.
   --             For the  following  relational  operators it is required that
   --             BOTH, criteria value low and high ARE SPECIFIED. ie. BETWEEN
   --             and NOT BETWEEN.
   --             For  the  following relational operators, BOTH the criteria
   --             values, high and low SHOULD NOT be specified. ie. IS NULL,
   --             IS NOT NULL.
   --             For all  other operators, ie. =,  <>, >, <, >=, <=, IN, NOT IN,
   --             LIKE and NOT LIKE, ONLY  criteria  value  low should be
   --             specified and criteria value high should be NULL.
   --             This procedure does these validations.
   --   Note    :
   --   Parameters:
   --   IN
   --       P_RELATIONAL_OPERATOR     IN   VARCHAR2
   --       P_CRITERIA_VALUE_LOW      IN   VARCHAR2
   --       P_CRITERIA_VALUE_HIGH     IN   VARCHAR2
   --
   --   OUT NOCOPY :
   --       X_RETURN_STATUS           OUT  NOCOPY  VARCHAR2
   --   Version : Current version 1.0
   --
   --   End of Comments
   --
PROCEDURE VALIDATE_COMPARE_ARGUMENTS (
    P_RELATIONAL_OPERATOR        IN   VARCHAR2,
    P_CRITERIA_VALUE_LOW         IN   VARCHAR2,
    P_CRITERIA_VALUE_HIGH        IN   VARCHAR2,
    X_RETURN_STATUS              OUT  NOCOPY VARCHAR2 );

END CSC_PLAN_ASSIGNMENT_PKG;

 

/
