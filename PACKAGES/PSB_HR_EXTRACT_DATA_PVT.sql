--------------------------------------------------------
--  DDL for Package PSB_HR_EXTRACT_DATA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_HR_EXTRACT_DATA_PVT" AUTHID CURRENT_USER AS
/* $Header: PSBVHRXS.pls 115.9 2003/07/18 12:56:16 vbellur ship $ */

g_block_str varchar2(2500);
g_ldcursor number;
g_psb_num_dist number;

TYPE g_ldcostmap_rec_type IS RECORD
     (gl_code_combination_id       NUMBER,
       project_id                  NUMBER,
       task_id                     NUMBER,
       award_id                    NUMBER,
       expenditure_organization_id NUMBER,
       expenditure_type            VARCHAR2(30),
       percent                     NUMBER(5,2),
       effective_start_date        DATE,
       effective_end_date          DATE,
       --UTF8 changes for Bug No : 2615261
       description                 psb_cost_distributions_i.description%TYPE
     );

 TYPE g_ldcostmap_tbl_type is TABLE OF g_ldcostmap_rec_type
       INDEX BY BINARY_INTEGER;

g_psb_rec g_ldcostmap_tbl_type;

Cursor G_Employee_Details(p_person_id in number) is
   Select first_name , last_name
     from per_all_people
    where person_id = p_person_id;

Cursor G_Position_Details(p_position_id in number) is
   Select name
     from per_all_positions
    where position_id = p_position_id;

PROCEDURE Init(p_date in OUT  NOCOPY date);

PROCEDURE Get_Position_Information
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
  p_id_flex_num         IN      NUMBER,
  p_date                IN      DATE,
  p_business_group_id   IN      NUMBER,
  p_set_of_books_id     IN      NUMBER

);

PROCEDURE Get_Employee_Information
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
  p_date                IN      DATE,
  p_business_group_id   IN      NUMBER,
  p_set_of_books_id     IN      NUMBER,
  p_copy_defaults_flag  IN      VARCHAR2,
  p_copy_salary_flag    IN      VARCHAR2
);

PROCEDURE Get_Salary_Information
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

PROCEDURE Get_Costing_Information
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
  p_date                IN      DATE,
  p_business_group_id   IN      NUMBER,
  p_set_of_books_id     IN      NUMBER
);


PROCEDURE Get_Attributes
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

PROCEDURE Get_Employee_Attributes
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
  p_date                IN      DATE,
  p_business_group_id   IN      NUMBER,
  p_set_of_books_id     IN      NUMBER
);

PROCEDURE Update_Reentry
( p_api_version         IN    NUMBER,
  p_return_status       OUT  NOCOPY   VARCHAR2,
  p_msg_count           OUT  NOCOPY   NUMBER,
  p_msg_data            OUT  NOCOPY   VARCHAR2,
  p_data_extract_id     IN    NUMBER,
  p_extract_method      IN    VARCHAR2,
  p_process             IN    VARCHAR2,
  p_restart_id          IN    NUMBER
) ;

PROCEDURE Check_Reentry
( p_api_version         IN    NUMBER,
  p_return_status       OUT  NOCOPY   VARCHAR2,
  p_msg_count           OUT  NOCOPY   NUMBER,
  p_msg_data            OUT  NOCOPY   VARCHAR2,
  p_data_extract_id     IN    NUMBER,
  p_process             IN    VARCHAR2,
  p_status              OUT  NOCOPY   VARCHAR2,
  p_restart_id          OUT  NOCOPY   NUMBER
) ;

PROCEDURE Reentrant_Process
( p_api_version         IN    NUMBER,
  p_return_status       OUT  NOCOPY   VARCHAR2,
  p_msg_count           OUT  NOCOPY   NUMBER,
  p_msg_data            OUT  NOCOPY   VARCHAR2,
  p_data_extract_id     IN    NUMBER,
  p_extract_method      IN    VARCHAR2,
  p_process             IN    VARCHAR2
);

PROCEDURE Final_Process;

PROCEDURE Get_LD_Schedule
  ( p_api_version           IN    NUMBER,
    p_init_msg_list         IN    VARCHAR2 := FND_API.G_FALSE,
    p_commit                IN    VARCHAR2 := FND_API.G_FALSE,
    p_validation_level      IN    NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_return_status         OUT  NOCOPY   VARCHAR2,
    p_msg_count             OUT  NOCOPY   NUMBER,
    p_msg_data              OUT  NOCOPY   VARCHAR2,
    p_assignment_id         IN    NUMBER,
    p_date                  IN    DATE,
    p_effective_start_date  IN    DATE,
    p_effective_end_date    IN    DATE,
    p_chart_of_accounts_id  IN    NUMBER,
    p_data_extract_id       IN    NUMBER,
    p_business_group_id     IN    NUMBER,
    p_set_of_books_id       IN    NUMBER,
    p_mode                  IN    VARCHAR2 := 'D');

PROCEDURE Validate_Attribute_Mapping
  ( p_api_version           IN    NUMBER,
    p_init_msg_list         IN    VARCHAR2 := FND_API.G_FALSE,
    p_commit                IN    VARCHAR2 := FND_API.G_FALSE,
    p_validation_level      IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    p_return_status         OUT  NOCOPY   VARCHAR2,
    p_msg_count             OUT  NOCOPY   NUMBER,
    p_msg_data              OUT  NOCOPY   VARCHAR2,
    p_business_group_id     IN    NUMBER,
    p_attribute_type_id     IN    NUMBER,
    p_definition_structure  IN    VARCHAR2 ,
    p_definition_table      IN    VARCHAR2 ,
    p_definition_column     IN    VARCHAR2
  );

FUNCTION get_debug RETURN VARCHAR2;
FUNCTION get_segment_val (pseg_num  varchar2,
		pcost_allocation_keyflex_id  number)
	 RETURN VARCHAR2;

FUNCTION Is_LD_Enabled
( p_business_group_id IN NUMBER
) RETURN BOOLEAN;

END PSB_HR_EXTRACT_DATA_PVT;

 

/
