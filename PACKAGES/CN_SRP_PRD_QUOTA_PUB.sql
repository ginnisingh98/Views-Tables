--------------------------------------------------------
--  DDL for Package CN_SRP_PRD_QUOTA_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_SRP_PRD_QUOTA_PUB" AUTHID CURRENT_USER AS
  /*$Header: cnvspdbs.pls 120.2 2005/10/27 16:05:19 mblum noship $*/
/*#
 * This procedure distributes the target for a plan element across the periods
 *  for which the plan element has been defined for a given salesperson.
 * @rep:scope public
 * @rep:product CN
 * @rep:displayname Salesperson Period Quotas Distribution
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CN_COMP_PLANS
 */

-- period quota
TYPE srp_prd_quota_rec_type IS RECORD
  (
     PERIOD_NAME       CN_PERIOD_STATUSES.PERIOD_NAME%TYPE := FND_API.G_MISS_CHAR,
     PERIOD_TARGET     NUMBER := FND_API.G_MISS_NUM,
     PERIOD_PAYMENT    NUMBER := FND_API.G_MISS_NUM,
     PERFORMANCE_GOAL  NUMBER := FND_API.G_MISS_NUM
  );


TYPE srp_prd_quota_tbl_type IS
   TABLE OF srp_prd_quota_rec_type INDEX BY BINARY_INTEGER ;

/*#
 * This procedure distributes the target for a plan element across the periods
 *  for which the plan element has been defined for a given salesperson.
 * @param p_api_version API Version
 * @param p_init_msg_list Initialize Message List
 * @param p_commit Commit after update
 * @param p_validation_level Validation Level
 * @param x_return_status Status of the update operation
 * @param x_msg_count Number of error messages returned
 * @param x_msg_data Error messages
 * @param p_salesrep_name The salesperson for whom the target is to be distributed
 * @param p_employee_number The employee number of the salesperson
 * @param p_role_name The role to which the salesperson is assigned during the periods for which the user is distributing the targets
 * @param p_cp_name The compensation plan that is assigned to the salesperson and which contains the plan element for which the user would like to distribute target
 * @param p_srp_plan_start_date The start date of the compensation plan assignment to the salesrep
 * @param p_srp_plan_end_date The end date of the compensation plan assignment to the salesrep
 * @param p_pe_name The plan element for which the target has to be distributed
 * @param p_target_amount The target amount that has to be distributed across the periods
 * @param p_fixed_amount The fixed amount that has to be distributed for the periods
 * @param p_performance_goal The performance goal that has to be distributed for the periods
 * @param p_even_distribute The configuration parameter used to choose between even distribution and user configurable distribution. Y = even, N = user configurable
 * @param p_srp_prd_quota_tbl Record of type prd_quota_tbl_type to store the user configured distribution if p_even_distribute is set to N
 * @param p_org_id Organization ID
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Salesperson Period Quotas Distribution
 */

PROCEDURE Distribute_Srp_Prd_Quota
(       p_api_version              IN   NUMBER   := CN_API.G_MISS_NUM,
        p_init_msg_list            IN   VARCHAR2 := CN_API.G_FALSE,
        p_commit                   IN   VARCHAR2 := CN_API.G_FALSE,
        p_validation_level         IN   NUMBER   := CN_API.G_VALID_LEVEL_FULL,
        p_salesrep_name            IN   CN_SALESREPS.NAME%TYPE,
        p_employee_number          IN   CN_SALESREPS.EMPLOYEE_NUMBER%TYPE,
        p_role_name                IN   CN_ROLES.NAME%TYPE,
        p_cp_name                  IN   CN_COMP_PLANS.NAME%TYPE,
        p_srp_plan_start_date      IN   CN_SRP_PLAN_ASSIGNS.START_DATE%TYPE,
        p_srp_plan_end_date        IN   CN_SRP_PLAN_ASSIGNS.END_DATE%TYPE,
        p_pe_name                  IN   CN_QUOTAS.NAME%TYPE,
        p_target_amount            IN   CN_SRP_QUOTA_ASSIGNS.target%TYPE,
        p_fixed_amount             IN   CN_SRP_QUOTA_ASSIGNS.payment_amount%TYPE,
        p_performance_goal         IN   CN_SRP_QUOTA_ASSIGNS.performance_goal%TYPE,
        p_even_distribute          IN   VARCHAR2,
        p_srp_prd_quota_tbl        IN   srp_prd_quota_tbl_type,
        p_org_id                   IN   NUMBER := NULL,
        x_return_status            OUT NOCOPY VARCHAR2,
        x_msg_count                OUT NOCOPY NUMBER,
        x_msg_data                 OUT NOCOPY VARCHAR2

  );




 END CN_SRP_PRD_QUOTA_PUB;

 

/
