--------------------------------------------------------
--  DDL for Package CN_CALC_SUBMISSION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_CALC_SUBMISSION_PUB" AUTHID CURRENT_USER AS
/* $Header: cnpcsbs.pls 120.2 2005/08/08 10:03:05 ymao noship $ */
/*#
 * This package provides the APIs for creating and updating a calculation submission batch.
 * @rep:scope public
 * @rep:product CN
 * @rep:displayname Create/Update Calculation Submission Batch
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CN_COMP_PLANS
 */

-- Comments for datatype, global constant or variables

TYPE salesrep_rec_type IS RECORD
  (   employee_number      cn_salesreps.employee_number%TYPE := FND_API.G_MISS_CHAR,
      type                 cn_salesreps.type%TYPE :=  FND_API.G_MISS_CHAR,
      hierarchy_flag       cn_calc_submission_entries.hierarchy_flag%TYPE := 'N'
      );


TYPE salesrep_tbl_type IS TABLE OF salesrep_rec_type
  INDEX BY BINARY_INTEGER;

TYPE plan_element_tbl_type IS TABLE OF cn_quotas.name%TYPE
  INDEX BY BINARY_INTEGER;

TYPE app_user_resp_rec_type IS RECORD
  (  user_name         fnd_user.user_name%TYPE  := FND_API.G_MISS_CHAR,
     responsibility_name fnd_responsibility_vl.responsibility_name%TYPE := FND_API.G_MISS_CHAR
     );

g_miss_app_user_resp_rec  app_user_resp_rec_type;
g_miss_salesrep_tbl       salesrep_tbl_type;
g_miss_pe_tbl             plan_element_tbl_type;

-- calc submission batch record type
TYPE calc_submission_rec_type IS RECORD
  ( batch_name               cn_calc_submission_batches.name%TYPE             := FND_API.G_MISS_CHAR,
    start_date               cn_calc_submission_batches.start_date%TYPE       := FND_API.G_MISS_DATE,
    end_date                 cn_calc_submission_batches.end_date%TYPE         := FND_API.G_MISS_DATE,
    calculation_type         cn_calc_submission_batches.calc_type%TYPE        := FND_API.G_MISS_CHAR,
    salesrep_option          cn_calc_submission_batches.salesrep_option%TYPE  := FND_API.G_MISS_CHAR,
    entire_hierarchy         cn_calc_submission_batches.hierarchy_flag%TYPE   := FND_API.G_MISS_CHAR,
    concurrent_calculation   cn_calc_submission_batches.concurrent_flag%TYPE  := FND_API.G_MISS_CHAR,
    incremental_calculation  cn_calc_submission_batches.intelligent_flag%TYPE := FND_API.G_MISS_CHAR,
    interval_type            cn_interval_types.name%type                      := FND_API.G_MISS_CHAR,
    org_id                   cn_calc_submission_batches.org_id%TYPE           := NULL,
    attribute_category   cn_comp_plans.attribute_category%TYPE := FND_API.G_MISS_CHAR,
    attribute1           cn_comp_plans.attribute1%TYPE         := FND_API.G_MISS_CHAR,
    attribute2           cn_comp_plans.attribute2%TYPE         := FND_API.G_MISS_CHAR,
    attribute3           cn_comp_plans.attribute3%TYPE         := FND_API.G_MISS_CHAR,
    attribute4           cn_comp_plans.attribute4%TYPE         := FND_API.G_MISS_CHAR,
    attribute5           cn_comp_plans.attribute5%TYPE         := FND_API.G_MISS_CHAR,
    attribute6           cn_comp_plans.attribute6%TYPE         := FND_API.G_MISS_CHAR,
    attribute7           cn_comp_plans.attribute7%TYPE         := FND_API.G_MISS_CHAR,
    attribute8           cn_comp_plans.attribute8%TYPE         := FND_API.G_MISS_CHAR,
    attribute9           cn_comp_plans.attribute9%TYPE         := FND_API.G_MISS_CHAR,
    attribute10          cn_comp_plans.attribute10%TYPE        := FND_API.G_MISS_CHAR,
    attribute11          cn_comp_plans.attribute11%TYPE        := FND_API.G_MISS_CHAR,
    attribute12          cn_comp_plans.attribute12%TYPE        := FND_API.G_MISS_CHAR,
    attribute13          cn_comp_plans.attribute13%TYPE        := FND_API.G_MISS_CHAR,
    attribute14          cn_comp_plans.attribute14%TYPE        := FND_API.G_MISS_CHAR,
    attribute15          cn_comp_plans.attribute15%TYPE        := FND_API.G_MISS_CHAR
  );

-- Global variable that represent missing values.
g_miss_calc_submission_rec calc_submission_rec_type;

-- Start of Comments
-- API name 	: Create_Calc_Submission
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Used to create a new calculation submission batch with passed_in
--                salesreps/ passed_in bonus plan elements
--                And submit the calculation after all validations are successful
-- Desc 	: Procedure to create a new calculation submission batch with passed_in
--                salesreps/ passed_in bonus plan elements
-- Parameters	:
-- IN		:  p_api_version       IN NUMBER      Require
-- 		   p_init_msg_list     IN VARCHAR2    Optional
-- 		   	Default = FND_API.G_FALSE
-- 		   p_commit	       IN VARCHAR2    Optional
-- 		       	Default = FND_API.G_FALSE
-- 		   p_validation_level  IN NUMBER      Optional
-- 		       	Default = FND_API.G_VALID_LEVEL_FULL
-- OUT		:  x_return_status     OUT	      VARCHAR2(1)
-- 		   x_msg_count	       OUT	      NUMBER
-- 		   x_msg_data	       OUT	      VARCHAR2(2000)
-- IN		:  p_calc_submission_rec     IN       calc_submission_rec_type
--                 p_app_user_resp_rec       IN       app_user_resp_rec_type
--                 p_salesrep_tbl            IN       salesrep_tbl_type
--                 p_bonus_pe_tbl            IN       plan_element_tbl_type
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- Notes
--
--
-- Description :
--               Create Calc Submission is a Public Package which allows us to create
-- the calculation submission batch.
------------------+
-- p_calc_submission_rec Input parameter
--   batch_name       calculation submission batch name,                            Mandatory
--                    Should uniquely identify the batch
--   start_date       start date                                                    Mandatory
--                    Must be within opened period
--   end_date         end date    must be within opened period                      Mandatory
--                    Must be within opened period
--   calculation_type type of calculation                                           Mandatory
--                    Valid values: COMMISSION/BONUS
--   salesrep_option  salesrep option                                               Mandatory
--                    Valid values: ALL_REPS/USER_SPECIFY/REPS_IN_NOTIFY_LOG
--                    IF calc_type = BONUS , REPS_IN_NOTIFY_LOG is not valid.
--   entire_hierarchy entire hierarchy or not                                       Mandatory
--                    Valid values: Y/N
--                    IF salesrep_option = ALL_REPS or REPS_IN_NOTIFY_LOG,
--                       hierarchy_flag should be 'N'.
--   concurrent_calculation  concurrent calculation or not ( Y/N )                  Mandatory
--                    Valid values: Y/N
--   incremental_calculation incremental calculation or not ( Y/N)                  Mandatory
--                    Valid values: Y/N
--                    IF salesrep_option = REPS_IN_NOTIFY_LOG,
--                       intelligent_flag should be 'Y'.
--   interval_type    interval type for bonus plan elements                         Optional
--                    Valid values:  PERIOD/QUARTER/YEAR/ALL
--                    Mandatory when calc_type = 'BONUS'
--
--
-- p_app_user_resp_rec IN parameter                                                 Optional
--                    Information required to submit concurrent calculation
--                    Valid when concurrent_calculation = 'Y'
--                      user_name should be a valid application user name.
--                      responsibility_name should be a valid responsibility name
--
-- p_salesrep_tbl IN parameter
--                   list of salesreps' employee number /employee type              Optional
--                   Valid when salesrep_option = 'USER_SPECIFY'
--                      salesrep_rec_type.employee number    can not be missing or null
--                      salesrep_rec_type.type               can not be missing or null
--                      Sales persons listed currently have or previously had
--                          compensation plan assigned.
--
-- p_bonus_pe_tbl IN parameter
--                   list of bonus plan elements' name                                 Optional
--                   Valid when calc_type = BONUS
--                     Plan elements listed should be 'BONUS' type and their interval type should
--                         match the value of p_calc_submission_rec.interval_type
--                         or if p_calc_submission_rec.interval_type = 'ALL', then their interval
--                         type can be any of 'PERIOD'/'QUARTER'/'YEAR'
--
--
-- Special Notes:
--     IF p_commit is not fnd_api.g_true, then the calculation will not be submitted even if all
--     the validations are successful.
--
------------------------+
-- End of comments

/*#
 * This procedure creates a new calculation submission batch with the given specifications.
 * @param p_api_version API version
 * @param p_init_msg_list Initialize message list (default F)
 * @param p_commit Commit flag (default F). If p_commit is not fnd_api.g_true, then the calculation will not be submitted even if all of the validations are successful.
 * @param p_validation_level Validation level (default Full)
 * @param x_return_status Return status
 * @param x_msg_count Number of messages returned
 * @param x_msg_data Contents of message if x_msg_count = 1
 * @param p_calc_submission_rec This is the contents of calculation submission record
 * @param p_app_user_resp_rec This is the information required to submit concurrent calculation. It is valid when concurrent_calculation = Y. User_name should be a valid application user name.
 * @param p_salesrep_tbl This is a list of salesreps' employee number and employee type. It is valid when salesrep_option = USER SPECIFY. salesrep_rec_type.employee number cannot be missing or null.
 * salesrep_rec_type.type cannot be missing or null. Salespeople listed currently have or previously had a compensation plan assigned.
 * @param p_bonus_pe_tbl This is a list of bonus plan elements. It is valid when calc_type = BONUS. Plan elements listed should be BONUS type and their interval type should match the value of p_calc_submission_rec.interval_type.
 * Or, if p_calc_submission_rec.interval_type = ALL, then the interval type can be PERIOD, QUARTER, or YEAR.
 * @param x_loading_status Loading status
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Calculation Submission Batch
 */

PROCEDURE Create_Calc_Submission
  (
   p_api_version        IN    NUMBER,
   p_init_msg_list      IN    VARCHAR2 := FND_API.G_FALSE,
   p_commit	        IN    VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT   NOCOPY VARCHAR2,
   x_msg_count	        OUT   NOCOPY NUMBER,
   x_msg_data	        OUT   NOCOPY VARCHAR2,
   p_calc_submission_rec  IN  calc_submission_rec_type := g_miss_calc_submission_rec,
   p_app_user_resp_rec    IN  app_user_resp_rec_type                := g_miss_app_user_resp_rec,
   p_salesrep_tbl         IN  salesrep_tbl_type                     := g_miss_salesrep_tbl,
   p_bonus_pe_tbl         IN  plan_element_tbl_type                 := g_miss_pe_tbl,
   x_loading_status     OUT   NOCOPY VARCHAR2
   );

-- Start of Comments
-- API name 	: Update_Calc_Submission
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Used to update a calculation submission batch with passed_in
--                salesreps/ passed_in bonus plan elements
--                And submit the calculation after all validations are successful
-- Desc 	: Procedure to update calculation submission batch with passed_in
--                salesreps/ passed_in bonus plan elements
-- Parameters	:
-- IN		:  p_api_version       IN NUMBER      Require
-- 		   p_init_msg_list     IN VARCHAR2    Optional
-- 		   	Default = FND_API.G_FALSE
-- 		   p_commit	       IN VARCHAR2    Optional
-- 		       	Default = FND_API.G_FALSE
-- 		   p_validation_level  IN NUMBER      Optional
-- 		       	Default = FND_API.G_VALID_LEVEL_FULL
-- OUT		:  x_return_status     OUT	      VARCHAR2(1)
-- 		   x_msg_count	       OUT	      NUMBER
-- 		   x_msg_data	       OUT	      VARCHAR2(2000)
-- IN		:  p_calc_submission_rec     IN       calc_submission_rec_type
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- Notes
--
-- Description	: This procedure is used to update a calculation submission
-- Notes	:
--
--   p_calc_submission_rec_old                           Mandatory
--                old calculation submission batch must be found based
--                    on p_calc_submission_rec_old.batch_name
--                If the old calculation submission batch is either completed or
--                or in progress, then it can not be updated.
--   p_calc_submission_rec_new                           Mandatory
--                all the validation rules in create_calc_submission holds here
--
--  p_app_user_resp_rec IN parameter                     Optional
--                    Information required to submit concurrent calculation
--                    Valid when concurrent_calculation = 'Y'
--                      user_name should be a valid application user name.
--                      responsibility_name should be a valid responsibility name
--
--   p_salesrep_tbl IN parameter                         Optional
--                   list of salesreps' employee number /employee type
--                   Valid when salesrep_option = 'USER_SPECIFY'
--                      salesrep_rec_type.employee number    can not be missing or null
--                      salesrep_rec_type.type               can not be missing or null
--                      Sales persons listed currently have or previously had
--                          compensation plan assigned.
--   p_salesrep_tbl_action                               Mandatory
--                Valid Values: ADD/DELETE
--                either add the listed sales persons to table or delete the listed
--                       sales persons from the table.
--                if the sales person already exists or there are duplicates in p_salesrep_tbl,
--                  give out a message without failing the call
--   p_bonus_pe_tbl IN parameter                         Optional
--                   list of bonus plan elements' name
--                   Valid when calc_type = BONUS
--                     Plan elements listed should be 'BONUS' type and their interval type should
--                         match the value of p_calc_submission_rec.interval_type
--                         or if p_calc_submission_rec.interval_type = 'ALL', then their interval
--                         type can be any of 'PERIOD'/'QUARTER'/'YEAR'
--   p_bonus_pe_tbl_action                               Mandatory
--                Valid Values: ADD/DELETE
--                either add the listed bonus plan elements to table or delete the listed
--                       bonus plan elements from the table.
--                if the plan element already exists or there are duplicates in p_bonus_pe_tbl,
--                  give out a message without failing the call
--
-- Special Notes:
--     IF p_commit is not fnd_api.g_true, then the calculation will not be submitted even if all
--     the validations are successful.
--
--
-- End of comments
------------------------+
-- End of comments

/*#
 * This procedure updates a calculation submission batch with the given specifications.
 * @param p_api_version API version
 * @param p_init_msg_list Initialize message list (default F)
 * @param p_commit Commit flag (default F). If p_commit is not fnd_api.g_true, then the calculation will not be submitted even if all of the validations are successful.
 * @param p_validation_level Validation level (default 100)
 * @param x_return_status Return status
 * @param x_msg_count Number of messages returned
 * @param x_msg_data Contents of message if x_msg_count = 1
 * @param p_calc_submission_rec_old The old calculation submission batch must be found based on p_calc_submission_rec_old.batch_name. If the old calculation submission batch is either completed or in progress, then it cannot be updated.
 * @param p_calc_submission_rec_new Content of calculation submission record
 * @param p_app_user_resp_rec This is the information required to submit concurrent calculation. It is valid when concurrent_calculation = Y. User_name should be a valid application user name.
 * @param p_salesrep_tbl This is a list of salesreps' employee number and employee type. It is valid when salesrep_option = USER SPECIFY. salesrep_rec_type.employee number cannot be missing or null.
 * salesrep_rec_type.type cannot be missing or null. Salespeople listed currently have or previously had a compensation plan assigned.
 * @param p_salesrep_tbl_action Valid Values: ADD/DELETE. ADD adds the listed salespeople to the table. If the salesperson already exists or there are duplicates in p_salesrep_tbl, it displays a message without failing the call.
 * DELETE deletes the listed salespeople from the table.
 * @param p_bonus_pe_tbl This is a list of bonus plan elements. It is valid when calc_type = BONUS. Plan elements listed should be BONUS type and their interval type should match the value of p_calc_submission_rec.interval_type.
 * Or, if p_calc_submission_rec.interval_type = ALL, then the interval type can be PERIOD, QUARTER, or YEAR.
 * @param p_bonus_pe_tbl_action Valid Values: ADD/DELETE. ADD adds the listed bonus plan elements to the table. If the plan element already exists or there are duplicates in p_bonus_pe_tbl, it displays a message without failing the call.
 * DELETE deletes the listed bonus plan elements from the table.
 * @param x_loading_status Loading status
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Calculation Submission Batch
 */
PROCEDURE Update_Calc_Submission
  (
   p_api_version        IN    NUMBER,
   p_init_msg_list      IN    VARCHAR2 := FND_API.G_FALSE,
   p_commit	        IN    VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT   NOCOPY VARCHAR2,
   x_msg_count	        OUT   NOCOPY NUMBER,
   x_msg_data	        OUT   NOCOPY VARCHAR2,
   p_calc_submission_rec_old      IN    calc_submission_rec_type := g_miss_calc_submission_rec,
   p_calc_submission_rec_new      IN    calc_submission_rec_type := g_miss_calc_submission_rec,
   p_app_user_resp_rec    IN  app_user_resp_rec_type                := g_miss_app_user_resp_rec,
   p_salesrep_tbl         IN  salesrep_tbl_type                     := g_miss_salesrep_tbl,
   p_salesrep_tbl_action  IN    VARCHAR2,
   p_bonus_pe_tbl         IN  plan_element_tbl_type                 := g_miss_pe_tbl,
   p_bonus_pe_tbl_action  IN    VARCHAR2,
   x_loading_status     OUT   NOCOPY VARCHAR2
   );

END cn_calc_submission_pub;

 

/
