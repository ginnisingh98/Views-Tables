--------------------------------------------------------
--  DDL for Package PSB_HR_POPULATE_DATA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_HR_POPULATE_DATA_PVT" AUTHID CURRENT_USER AS
/* $Header: PSBVHRPS.pls 120.6 2005/10/27 16:09:58 matthoma ship $ */

/*-------------------------------------------------------------*/
/* Define Global Variables for the Incremental Extract Process */

g_psb_budget_group_id   NUMBER;
g_psb_worksheet_id      NUMBER;
g_psb_current_form      VARCHAR2(20);
g_psb_data_extract_id   NUMBER;
g_psb_business_group_id NUMBER;
g_psb_application_id    NUMBER;
g_psb_org_id            NUMBER;
g_psb_revision_start_date            DATE;
g_psb_revision_end_date              DATE;

/* start bug 4153562 */
-- This global variable is set in the
-- populate_position_assignments API.
g_extract_method        VARCHAR2(30);
/* end bug 4153562 */

/* start bug 4213882 */
g_pop_assignment        VARCHAR2(1);
/* end bug 4213882 */


Procedure set_global(g_var_name IN varchar2,
		     g_var_value IN varchar2);

Function  get_global(g_var_name IN varchar2) return varchar2;

Procedure Insert_Position_Txn_Info
(
 p_position_transaction_id        in number ,
 p_action_date                    in date ,
 p_position_id                    in number ,
 p_availability_status_id         in number ,
 p_business_group_id              in number ,
 p_entry_step_id                  in number ,
 p_entry_grade_rule_id            in number ,
 p_job_id                         in number ,
 p_location_id                    in number ,
 p_organization_id                in number ,
 p_pay_freq_payroll_id            in number ,
 p_position_definition_id         in number ,
 p_prior_position_id              in number ,
 p_relief_position_id             in number ,
 p_entry_grade_id                 in number ,
 p_successor_position_id          in number ,
 p_supervisor_position_id         in number ,
 p_amendment_date                 in date ,
 p_amendment_recommendation       in varchar2 ,
 p_amendment_ref_number           in varchar2 ,
 p_avail_status_prop_end_date     in date ,
 p_bargaining_unit_cd             in varchar2 ,
 p_comments                       in long ,
 p_country1                       in varchar2 ,
 p_country2                       in varchar2 ,
 p_country3                       in varchar2 ,
 p_current_job_prop_end_date      in date ,
 p_current_org_prop_end_date      in date ,
 p_date_effective                 in date ,
 p_date_end                       in date ,
 p_earliest_hire_date             in date ,
 p_fill_by_date                   in date ,
 p_frequency                      in varchar2 ,
 p_fte                            in number ,
 p_location1                      in varchar2 ,
 p_location2                      in varchar2 ,
 p_location3                      in varchar2 ,
 p_max_persons                    in number ,
 p_name                           in varchar2 ,
 p_other_requirements             in varchar2 ,
 p_overlap_period                 in number ,
 p_overlap_unit_cd                in varchar2 ,
 p_passport_required              in varchar2 ,
 p_pay_term_end_day_cd            in varchar2 ,
 p_pay_term_end_month_cd          in varchar2 ,
 p_permanent_temporary_flag       in varchar2 ,
 p_permit_recruitment_flag        in varchar2 ,
 p_position_type                  in varchar2 ,
 p_posting_description            in varchar2 ,
 p_probation_period               in number ,
 p_probation_period_unit_cd       in varchar2 ,
 p_relocate_domestically          in varchar2 ,
 p_relocate_internationally       in varchar2 ,
 p_replacement_required_flag      in varchar2 ,
 p_review_flag                    in varchar2 ,
 p_seasonal_flag                  in varchar2 ,
 p_security_requirements          in varchar2 ,
 p_service_minimum                in varchar2 ,
 p_term_start_day_cd              in varchar2 ,
 p_term_start_month_cd            in varchar2 ,
 p_time_normal_finish             in varchar2 ,
 p_time_normal_start              in varchar2 ,
 p_transaction_status             in varchar2 ,
 p_travel_required                in varchar2 ,
 p_working_hours                  in number ,
 p_works_council_approval_flag    in varchar2 ,
 p_work_any_country               in varchar2 ,
 p_work_any_location              in varchar2 ,
 p_work_period_type_cd            in varchar2 ,
 p_work_schedule                  in varchar2 ,
 p_work_term_end_day_cd           in varchar2 ,
 p_work_term_end_month_cd         in varchar2 ,
 p_proposed_fte_for_layoff        in  number,
 p_proposed_date_for_layoff       in  date,
 p_information1                   in varchar2 ,
 p_information2                   in varchar2 ,
 p_information3                   in varchar2 ,
 p_information4                   in varchar2 ,
 p_information5                   in varchar2 ,
 p_information6                   in varchar2 ,
 p_information7                   in varchar2 ,
 p_information8                   in varchar2 ,
 p_information9                   in varchar2 ,
 p_information10                  in varchar2 ,
 p_information11                  in varchar2 ,
 p_information12                  in varchar2 ,
 p_information13                  in varchar2 ,
 p_information14                  in varchar2 ,
 p_information15                  in varchar2 ,
 p_information16                  in varchar2 ,
 p_information17                  in varchar2 ,
 p_information18                  in varchar2 ,
 p_information19                  in varchar2 ,
 p_information20                  in varchar2 ,
 p_information21                  in varchar2 ,
 p_information22                  in varchar2 ,
 p_information23                  in varchar2 ,
 p_information24                  in varchar2 ,
 p_information25                  in varchar2 ,
 p_information26                  in varchar2 ,
 p_information27                  in varchar2 ,
 p_information28                  in varchar2 ,
 p_information29                  in varchar2 ,
 p_information30                  in varchar2 ,
 p_information_category           in varchar2 ,
 p_attribute1                     in varchar2 ,
 p_attribute2                     in varchar2 ,
 p_attribute3                     in varchar2 ,
 p_attribute4                     in varchar2 ,
 p_attribute5                     in varchar2 ,
 p_attribute6                     in varchar2 ,
 p_attribute7                     in varchar2 ,
 p_attribute8                     in varchar2 ,
 p_attribute9                     in varchar2 ,
 p_attribute10                    in varchar2 ,
 p_attribute11                    in varchar2 ,
 p_attribute12                    in varchar2 ,
 p_attribute13                    in varchar2 ,
 p_attribute14                    in varchar2 ,
 p_attribute15                    in varchar2 ,
 p_attribute16                    in varchar2 ,
 p_attribute17                    in varchar2 ,
 p_attribute18                    in varchar2 ,
 p_attribute19                    in varchar2 ,
 p_attribute20                    in varchar2 ,
 p_attribute21                    in varchar2 ,
 p_attribute22                    in varchar2 ,
 p_attribute23                    in varchar2 ,
 p_attribute24                    in varchar2 ,
 p_attribute25                    in varchar2 ,
 p_attribute26                    in varchar2 ,
 p_attribute27                    in varchar2 ,
 p_attribute28                    in varchar2 ,
 p_attribute29                    in varchar2 ,
 p_attribute30                    in varchar2 ,
 p_attribute_category             in varchar2 ,
 p_object_version_number          in number ,
 p_effective_date                 in date ,
 p_pay_basis_id                   in number ,
 p_supervisor_id                  in number
);

PROCEDURE Update_Position_Txn_Info
(p_position_transaction_id     in NUMBER,
 p_action_date                 in DATE ,
 p_position_id                 in NUMBER,
 p_availability_status_id      in NUMBER,
 p_business_group_id           in NUMBER,
 p_entry_step_id               in NUMBER,
 p_entry_grade_rule_id         in NUMBER,
 p_job_id                      in NUMBER,
 p_location_id                 in NUMBER,
 p_organization_id             in NUMBER,
 p_pay_freq_payroll_id         in NUMBER,
 p_position_definition_id      in NUMBER,
 p_entry_grade_id              in NUMBER,
 p_bargaining_unit_cd          in VARCHAR2,
 p_date_effective              in DATE,
 p_date_end                    in DATE,
 p_earliest_hire_date          in DATE,
 p_frequency                   in VARCHAR2,
 p_fte                         in NUMBER,
 p_name                        in VARCHAR2,
 p_position_type               in VARCHAR2,
 p_transaction_status          in VARCHAR2,
 p_working_hours               in NUMBER,
 p_pay_basis_id_o              in number ,
 p_object_version_number       in NUMBER,
 p_effective_date              in DATE
);


PROCEDURE Insert_Position_Info
(p_position_id                in NUMBER ,
 p_effective_start_date       in DATE   ,
 p_effective_end_date         in DATE   ,
 p_availability_status_id     in NUMBER ,
 p_business_group_id          in NUMBER ,
 p_entry_step_id              in NUMBER ,
 p_entry_grade_rule_id        in NUMBER ,
 p_job_id                     in NUMBER ,
 p_location_id                in NUMBER ,
 p_organization_id            in NUMBER ,
 p_position_definition_id     in NUMBER ,
 p_position_transaction_id    in NUMBER ,
 p_entry_grade_id             in NUMBER ,
 p_bargaining_unit_cd         in VARCHAR2 ,
 p_date_effective             in DATE   ,
 p_date_end                   in DATE   ,
 p_earliest_hire_date         in DATE   ,
 p_fill_by_date               in DATE   ,
 p_frequency                  in VARCHAR2  ,
 p_working_hours              in NUMBER,
 p_fte                        in NUMBER    ,
 p_name                       in VARCHAR2  ,
 p_position_type              in VARCHAR2  ,
 p_pay_basis_id               in NUMBER    ,
 p_object_version_number      in NUMBER
);

PROCEDURE Update_Position_Info
(p_position_id                in NUMBER ,
 p_effective_start_date       in DATE   ,
 p_effective_end_date         in DATE   ,
 p_availability_status_id     in NUMBER ,
 p_business_group_id_o        in NUMBER ,
 p_entry_step_id              in NUMBER ,
 p_entry_grade_rule_id        in NUMBER ,
 p_job_id_o                   in NUMBER ,
 p_location_id                in NUMBER ,
 p_organization_id_o          in NUMBER ,
 p_position_definition_id     in NUMBER ,
 p_position_transaction_id    in NUMBER ,
 p_entry_grade_id             in NUMBER ,
 p_bargaining_unit_cd         in VARCHAR2 ,
 p_date_effective             in DATE   ,
 p_date_end                   in DATE   ,
 p_earliest_hire_date         in DATE   ,
 p_fill_by_date               in DATE   ,
 p_frequency                  in VARCHAR2  ,
 p_working_hours              in NUMBER,
 p_fte                        in NUMBER    ,
 p_name                       in VARCHAR2  ,
 p_position_type              in VARCHAR2  ,
 p_pay_basis_id               in NUMBER    ,
 p_object_version_number      in NUMBER ,
 p_effective_date             in DATE
);
/*-------------------------------------------------------------*/


TYPE gl_distribution_rec_type is RECORD
(ccid                 NUMBER,
 project_id           NUMBER,
 task_id              NUMBER,
 award_id             NUMBER,
 expenditure_type     VARCHAR2(30),
 expenditure_org_id   NUMBER,
 description          VARCHAR2(185),
 distr_percent        NUMBER,
 effective_start_date DATE,
 effective_end_date   DATE,
 exist_flag           VARCHAR2(1));

TYPE gl_distribution_tbl_type IS TABLE OF gl_distribution_rec_type
    INDEX BY BINARY_INTEGER;

Cursor G_Employee_Details(p_person_id in number) is
   Select first_name , last_name
     from psb_employees_i
    where hr_employee_id = p_person_id;

Cursor G_Position_Details(p_position_id in number) is
   Select name
     from psb_positions
    where position_id = p_position_id;

PROCEDURE Populate_Position_Information
( p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  p_data_extract_id     IN      NUMBER,
  -- de by org
  p_extract_by_org      IN      VARCHAR2,
  p_extract_method      IN      VARCHAR2,
  p_business_group_id   IN      NUMBER,
  p_set_of_books_id     IN      NUMBER
);

PROCEDURE Populate_Employee_Information
( p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  p_data_extract_id     IN      NUMBER,
  -- de by org
  p_extract_by_org      IN      VARCHAR2,
  p_extract_method      IN      VARCHAR2,
  p_business_group_id   IN      NUMBER,
  p_set_of_books_id     IN      NUMBER
);

PROCEDURE Populate_Element_Information
( p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  p_data_extract_id     IN      NUMBER,
  p_extract_method      IN      VARCHAR2,
  p_business_group_id   IN      NUMBER,
  p_set_of_books_id     IN      NUMBER
);

PROCEDURE Populate_Costing_Information
( p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  p_data_extract_id     IN      NUMBER,
  -- de by org
  p_extract_by_org      IN      VARCHAR2,
  p_extract_method      IN      VARCHAR2,
  p_business_group_id   IN      NUMBER
);

PROCEDURE Populate_Attribute_Values
( p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  p_data_extract_id     IN      NUMBER,
  p_extract_method      IN      VARCHAR2,
  p_business_group_id   IN      NUMBER
);

PROCEDURE Populate_Pos_Assignments
( p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  p_data_extract_id     IN      NUMBER,
  -- de by org
  p_extract_by_org      IN      VARCHAR2,
  p_extract_method      IN      VARCHAR2,
  p_business_group_id   IN      NUMBER,
  p_set_of_books_id     IN      NUMBER
);

/* Bug 4649730 reverted back the changes done for MPA as
   the following api will be called only
   as part of Extract process */
PROCEDURE Apply_Defaults
( p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  p_data_extract_id     IN      NUMBER,
  p_extract_method      IN      VARCHAR2
);


FUNCTION get_debug RETURN VARCHAR2;

END PSB_HR_POPULATE_DATA_PVT;

 

/
