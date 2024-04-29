--------------------------------------------------------
--  DDL for Package PSB_POSITIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_POSITIONS_PVT" AUTHID CURRENT_USER AS
/* $Header: PSBVPOSS.pls 120.8 2005/10/14 16:27:30 matthoma ship $ */


--
-- Global Variables for Views
--
g_worksheet_id         NUMBER ;
g_start_date           DATE ;
g_end_date             DATE ;
g_select_date          DATE ;
g_worksheet_flag       VARCHAR2(1) := 'N';
g_distr_percent_total  NUMBER; -- 1308558

--
-- Functions/Procedures to intialize and return global values
--

PROCEDURE Initialize_View ( p_worksheet_id in number,
			    p_start_date   in date,
			    p_end_date     in date,
			    p_select_date  in date := fnd_api.g_miss_date);

PROCEDURE Define_Worksheet_Values (
	    p_api_version               in number,
	    p_init_msg_list             in varchar2 := fnd_api.g_false,
	    p_commit                    in varchar2 := fnd_api.g_false,
	    p_validation_level          in number   := fnd_api.g_valid_level_full,
	    p_return_status             OUT  NOCOPY varchar2,
	    p_msg_count                 OUT  NOCOPY number,
	    p_msg_data                  OUT  NOCOPY varchar2,
	    p_worksheet_id              in number,
	    p_position_id               in number,
	    p_pos_effective_start_date  in date  := FND_API.G_MISS_DATE,
	    p_pos_effective_end_date    in date  := FND_API.G_MISS_DATE,
	    p_budget_source             in varchar2:= FND_API.G_MISS_CHAR,
	    p_out_worksheet_id          OUT  NOCOPY number,
	    p_out_start_date            OUT  NOCOPY date,
	    p_out_end_date              OUT  NOCOPY date);


FUNCTION Get_Start_Date RETURN DATE;
     pragma RESTRICT_REFERENCES  ( Get_START_DATE, WNDS, WNPS );

FUNCTION Get_End_Date RETURN DATE;
     pragma RESTRICT_REFERENCES  ( Get_END_DATE, WNDS, WNPS );

FUNCTION Get_Select_Date RETURN DATE;
     pragma RESTRICT_REFERENCES  ( Get_SELECT_DATE, WNDS, WNPS );

FUNCTION Get_Worksheet_Flag RETURN varchar2;
     pragma RESTRICT_REFERENCES  ( Get_WORKSHEET_FLAG, WNDS, WNPS );

FUNCTION Get_Worksheet_ID RETURN NUMBER;
     pragma RESTRICT_REFERENCES  ( Get_WORKSHEET_ID, WNDS, WNPS );

--
-- Table Handlers
--

PROCEDURE Insert_Row (
  p_api_version          in number,
  p_init_msg_list        in varchar2 := fnd_api.g_false,
  p_commit               in varchar2 := fnd_api.g_false,
  p_validation_level     in number   := fnd_api.g_valid_level_full,
  p_return_status        OUT  NOCOPY varchar2,
  p_msg_count            OUT  NOCOPY number,
  p_msg_data             OUT  NOCOPY varchar2,
  p_rowid                in OUT  NOCOPY varchar2,
  p_position_id          in number,
  -- de by org
  p_organization_id      in number := NULL,
  p_data_extract_id      in number,
  p_position_definition_id in number,
  p_hr_position_id       in number,
  p_hr_employee_id       in number := fnd_api.g_miss_num ,
  p_business_group_id    in number,
  p_budget_group_id      in number := fnd_api.g_miss_num ,
  p_effective_start_date in date,
  p_effective_end_date   in date,
  p_set_of_books_id      in number,
  p_vacant_position_flag in varchar2,
  p_availability_status in varchar2 := fnd_api.g_miss_char ,
  p_transaction_id      in number   := fnd_api.g_miss_num ,
  p_transaction_status  in varchar2 := fnd_api.g_miss_char ,
  p_new_position_flag   in varchar2 := fnd_api.g_miss_char ,
  p_attribute1          in varchar2,
  p_attribute2          in varchar2,
  p_attribute3          in varchar2,
  p_attribute4          in varchar2,
  p_attribute5          in varchar2,
  p_attribute6          in varchar2,
  p_attribute7          in varchar2,
  p_attribute8          in varchar2,
  p_attribute9          in varchar2,
  p_attribute10         in varchar2,
  p_attribute11         in varchar2,
  p_attribute12         in varchar2,
  p_attribute13         in varchar2,
  p_attribute14         in varchar2,
  p_attribute15         in varchar2,
  p_attribute16         in varchar2,
  p_attribute17         in varchar2,
  p_attribute18         in varchar2,
  p_attribute19         in varchar2,
  p_attribute20         in varchar2,
  p_attribute_category  in varchar2,
  p_name                in varchar2,
  p_mode                in varchar2 default 'R'
  );
--
--
--

PROCEDURE LOCK_ROW (
  p_api_version          in number,
  p_init_msg_list        in varchar2 := fnd_api.g_false,
  p_commit               in varchar2 := fnd_api.g_false,
  p_validation_level     in number   := fnd_api.g_valid_level_full,
  p_return_status        OUT  NOCOPY varchar2,
  p_msg_count            OUT  NOCOPY number,
  p_msg_data             OUT  NOCOPY varchar2,
  p_row_locked           OUT  NOCOPY varchar2,
  p_position_id          in number,
  p_data_extract_id      in number,
  p_position_definition_id in number,
  p_hr_position_id       in number,
  p_business_group_id    in number,
  p_effective_start_date in date,
  p_effective_end_date   in date,
  p_set_of_books_id      in number,
  p_vacant_position_flag in varchar2,
  p_attribute1          in varchar2,
  p_attribute2          in varchar2,
  p_attribute3          in varchar2,
  p_attribute4          in varchar2,
  p_attribute5          in varchar2,
  p_attribute6          in varchar2,
  p_attribute7          in varchar2,
  p_attribute8          in varchar2,
  p_attribute9          in varchar2,
  p_attribute10         in varchar2,
  p_attribute11         in varchar2,
  p_attribute12         in varchar2,
  p_attribute13         in varchar2,
  p_attribute14         in varchar2,
  p_attribute15         in varchar2,
  p_attribute16         in varchar2,
  p_attribute17         in varchar2,
  p_attribute18         in varchar2,
  p_attribute19         in varchar2,
  p_attribute20         in varchar2,
  p_attribute_category  in varchar2,
  p_name                in varchar2
);

--
--
--
PROCEDURE Update_Row (
  p_api_version          in number,
  p_init_msg_list        in varchar2 := fnd_api.g_false,
  p_commit               in varchar2 := fnd_api.g_false,
  p_validation_level     in number   := fnd_api.g_valid_level_full,
  p_return_status        OUT  NOCOPY varchar2,
  p_msg_count            OUT  NOCOPY number,
  p_msg_data             OUT  NOCOPY varchar2,
  p_position_id          in number,
  --de by org
  p_organization_id      in number := NULL,
  p_data_extract_id      in number,
  p_position_definition_id in number,
  p_hr_position_id       in number,
  p_hr_employee_id       in number := fnd_api.g_miss_num ,
  p_business_group_id    in number,
  p_budget_group_id      in number := fnd_api.g_miss_num ,
  p_effective_start_date in date,
  p_effective_end_date   in date,
  p_set_of_books_id      in number,
  p_vacant_position_flag in varchar2,
  p_availability_status in varchar2 := fnd_api.g_miss_char ,
  p_transaction_id      in number   := fnd_api.g_miss_num ,
  p_transaction_status  in varchar2 := fnd_api.g_miss_char ,
  p_new_position_flag   in varchar2 := fnd_api.g_miss_char ,
  p_attribute1          in varchar2,
  p_attribute2          in varchar2,
  p_attribute3          in varchar2,
  p_attribute4          in varchar2,
  p_attribute5          in varchar2,
  p_attribute6          in varchar2,
  p_attribute7          in varchar2,
  p_attribute8          in varchar2,
  p_attribute9          in varchar2,
  p_attribute10         in varchar2,
  p_attribute11         in varchar2,
  p_attribute12         in varchar2,
  p_attribute13         in varchar2,
  p_attribute14         in varchar2,
  p_attribute15         in varchar2,
  p_attribute16         in varchar2,
  p_attribute17         in varchar2,
  p_attribute18         in varchar2,
  p_attribute19         in varchar2,
  p_attribute20         in varchar2,
  p_attribute_category  in varchar2,
  p_name                in varchar2,
  p_mode                in varchar2 default 'R'

  );
--
--
--
PROCEDURE ADD_ROW (
  p_api_version          in number,
  p_init_msg_list        in varchar2 := fnd_api.g_false,
  p_commit               in varchar2 := fnd_api.g_false,
  p_validation_level     in number   := fnd_api.g_valid_level_full,
  p_return_status        OUT  NOCOPY varchar2,
  p_msg_count            OUT  NOCOPY number,
  p_msg_data             OUT  NOCOPY varchar2,
  p_rowid                in OUT  NOCOPY varchar2,
  p_position_id          in number,
  p_organization_id      in number,
  p_data_extract_id      in number,
  p_position_definition_id in number,
  p_hr_position_id       in number,
  p_business_group_id    in number,
  p_effective_start_date in date,
  p_effective_end_date   in date,
  p_set_of_books_id      in number,
  p_vacant_position_flag in varchar2,
  p_attribute1          in varchar2,
  p_attribute2          in varchar2,
  p_attribute3          in varchar2,
  p_attribute4          in varchar2,
  p_attribute5          in varchar2,
  p_attribute6          in varchar2,
  p_attribute7          in varchar2,
  p_attribute8          in varchar2,
  p_attribute9          in varchar2,
  p_attribute10         in varchar2,
  p_attribute11         in varchar2,
  p_attribute12         in varchar2,
  p_attribute13         in varchar2,
  p_attribute14         in varchar2,
  p_attribute15         in varchar2,
  p_attribute16         in varchar2,
  p_attribute17         in varchar2,
  p_attribute18         in varchar2,
  p_attribute19         in varchar2,
  p_attribute20         in varchar2,
  p_attribute_category  in varchar2,
  p_name                in varchar2,
  p_mode                in varchar2 default 'R'

  );
--
--
--
PROCEDURE Delete_Row (
  p_api_version         in number,
  p_init_msg_list       in varchar2 := fnd_api.g_false,
  p_commit              in varchar2 := fnd_api.g_false,
  p_validation_level    in number   := fnd_api.g_valid_level_full,
  p_return_status       OUT  NOCOPY varchar2,
  p_msg_count           OUT  NOCOPY number,
  p_msg_data            OUT  NOCOPY varchar2,
  p_position_id         in number
);
--
PROCEDURE Delete_Assignments (
  p_api_version       in   number,
  p_init_msg_list     in   varchar2 := fnd_api.g_false,
  p_commit            in   varchar2 := fnd_api.g_false,
  p_validation_level  in   number   := fnd_api.g_valid_level_full,
  p_return_status     OUT  NOCOPY  varchar2,
  p_msg_count         OUT  NOCOPY  number,
  p_msg_data          OUT  NOCOPY  varchar2,
  p_worksheet_id      in   number
 );
--
--
PROCEDURE Delete_Assignment_Employees (
  p_api_version       in   number,
  p_init_msg_list     in   varchar2 := fnd_api.g_false,
  p_commit            in   varchar2 := fnd_api.g_false,
  p_validation_level  in   number   := fnd_api.g_valid_level_full,
  p_return_status     OUT  NOCOPY  varchar2,
  p_msg_count         OUT  NOCOPY  number,
  p_msg_data          OUT  NOCOPY  varchar2,
  p_data_extract_id   in   number
 );
--
-- Modify_assignment used for insert/modify assignments
--
PROCEDURE Modify_Assignment
( p_api_version           in number,
  p_init_msg_list         in varchar2 := fnd_api.g_false,
  p_commit                in varchar2 := fnd_api.g_false,
  p_validation_level      in number   := fnd_api.g_valid_level_full,
  p_return_status         OUT  NOCOPY varchar2,
  p_msg_count             OUT  NOCOPY number,
  p_msg_data              OUT  NOCOPY varchar2,
  p_position_assignment_id  in OUT  NOCOPY  number,
  p_data_extract_id       in number,
  p_worksheet_id          in number,
  p_position_id           in number,
  p_assignment_type       in varchar2,
  p_attribute_id          in number,
  p_attribute_value_id    in number,
  p_attribute_value       in varchar2,
  p_pay_element_id        in number,
  p_pay_element_option_id in number,
  p_effective_start_date  in date,
  p_effective_end_date    in date,
  p_element_value_type    in varchar2,
  p_element_value         in number,
  p_currency_code         in varchar2,
  p_pay_basis             in varchar2,
  p_employee_id           in number,
  p_primary_employee_flag in varchar2,
  p_global_default_flag   in varchar2,
  p_assignment_default_rule_id in number,
  p_modify_flag           in varchar2,
  p_rowid                 in OUT  NOCOPY varchar2,
  p_mode                  in varchar2 default 'R'
);
--
--
--
PROCEDURE Validate_Salary
( p_api_version          in number,
  p_init_msg_list        in varchar2 := fnd_api.g_false,
  p_commit               in varchar2 := fnd_api.g_false,
  p_validation_level     in number   := fnd_api.g_valid_level_full,
  p_return_status        OUT  NOCOPY varchar2,
  p_msg_count            OUT  NOCOPY number,
  p_msg_data             OUT  NOCOPY varchar2,
  p_worksheet_id         in number,
  p_position_id          in number,
  p_effective_start_date in date,
  p_effective_end_date   in date,
  p_pay_element_id       in number,
  p_data_extract_id      in number,
  p_rowid                in varchar2
);

--added the parameter p_validation_mode as part of bug fix 3247574

PROCEDURE Position_WS_Validation
( p_api_version          in number,
  p_init_msg_list        in varchar2 := fnd_api.g_false,
  p_commit               in varchar2 := fnd_api.g_false,
  p_validation_level     in number   := fnd_api.g_valid_level_full,
  p_return_status        OUT  NOCOPY varchar2,
  p_msg_count            OUT  NOCOPY number,
  p_msg_data             OUT  NOCOPY varchar2,
  p_worksheet_id         in number  ,
  p_validation_status    OUT  NOCOPY varchar2,
  p_validation_mode      IN VARCHAR2 DEFAULT NULL
);
--
--
-- 1308558 Mass Position Assignment Rules Enhancement
-- added the extra parameter p_ruleset_id for passing the
-- id for the default ruleset
PROCEDURE Create_Default_Assignments
( p_api_version          IN   NUMBER,
  p_init_msg_list        IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit               IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level     IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_return_status        OUT  NOCOPY  VARCHAR2,
  p_msg_count            OUT  NOCOPY  NUMBER,
  p_msg_data             OUT  NOCOPY  VARCHAR2,
  p_worksheet_id         IN   NUMBER := FND_API.G_MISS_NUM,
  p_data_extract_id      IN   NUMBER,
  p_position_id          IN   NUMBER := FND_API.G_MISS_NUM,
  p_position_start_date  IN   DATE := FND_API.G_MISS_DATE,
  p_position_end_date    IN   DATE := FND_API.G_MISS_DATE,
  p_ruleset_id           IN   NUMBER := NULL
);
--
--
--
FUNCTION Rev_Check_Allowed
( p_api_version               IN  NUMBER,
  p_validation_level          IN  NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_startdate_pp              IN DATE,
  p_enddate_cy                IN DATE,
  p_worksheet_id              IN NUMBER,
  p_position_budget_group_id  IN  NUMBER
) RETURN VARCHAR2;



FUNCTION get_debug RETURN VARCHAR2;

/* Start Bug 3422919 */

FUNCTION get_employee_id
( p_data_extract_id     IN NUMBER := NULL,
  p_worksheet_id        IN NUMBER := NULL,
  p_position_id         IN NUMBER := NULL
) RETURN NUMBER;
PRAGMA   RESTRICT_REFERENCES(get_employee_id,WNDS,WNPS);

FUNCTION get_employee_number
( p_data_extract_id     IN NUMBER := NULL,
  p_worksheet_id        IN NUMBER := NULL,
  p_position_id         IN NUMBER := NULL
) RETURN VARCHAR2;
PRAGMA   RESTRICT_REFERENCES(get_employee_number,WNDS,WNPS);

FUNCTION get_employee_name
( p_data_extract_id     IN NUMBER := NULL,
  p_worksheet_id        IN NUMBER := NULL,
  p_position_id         IN NUMBER := NULL
) RETURN VARCHAR2;
PRAGMA   RESTRICT_REFERENCES(get_employee_name,WNDS,WNPS);

FUNCTION get_job_name
( p_data_extract_id     IN NUMBER := NULL,
  p_worksheet_id        IN NUMBER := NULL,
  p_position_id         IN NUMBER := NULL
) RETURN VARCHAR2;
PRAGMA   RESTRICT_REFERENCES(get_job_name,WNDS,WNPS);

/* End Bug 3422919 */

/* Bug 4273099 made the following api public */
-- Bug 4545909 added the parameter p_worksheet_id
PROCEDURE Apply_Position_Default_Rules
( p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status               OUT  NOCOPY     VARCHAR2,
  x_msg_count                   OUT  NOCOPY     NUMBER,
  x_msg_data                    OUT  NOCOPY     VARCHAR2,
  p_position_assignment_id      IN OUT  NOCOPY  NUMBER,
  p_data_extract_id             IN      NUMBER,
  p_position_id                 IN      NUMBER,
  p_assignment_type             IN      VARCHAR2,
  p_attribute_id                IN      NUMBER,
  p_attribute_value_id          IN      NUMBER,
  p_attribute_value             IN      VARCHAR2,
  p_pay_element_id              IN      NUMBER,
  p_pay_element_option_id       IN      NUMBER,
  p_effective_start_date        IN      DATE,
  p_effective_end_date          IN      DATE,
  p_element_value_type          IN      VARCHAR2,
  p_element_value               IN      NUMBER,
  p_currency_code               IN      VARCHAR2,
  p_pay_basis                   IN      VARCHAR2,
  p_employee_id                 IN      NUMBER,
  p_primary_employee_flag       IN      VARCHAR2,
  p_global_default_flag         IN      VARCHAR2,
  p_assignment_default_rule_id  IN      NUMBER,
  p_modify_flag                 IN      VARCHAR2,
  p_mode                        IN      VARCHAR2 := 'R' ,
  p_worksheet_id                IN      NUMBER DEFAULT NULL
);

END PSB_POSITIONS_PVT ;

 

/
