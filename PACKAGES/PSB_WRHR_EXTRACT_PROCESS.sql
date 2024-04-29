--------------------------------------------------------
--  DDL for Package PSB_WRHR_EXTRACT_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_WRHR_EXTRACT_PROCESS" AUTHID CURRENT_USER AS
/* $Header: PSBWHRCS.pls 120.9 2005/11/07 05:55:43 masethur ship $ */

PROCEDURE Perform_Data_Extract
( p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER  :=  FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  p_data_extract_id     IN      NUMBER
);

PROCEDURE Interface_Purge
 (p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER  :=  FND_API.G_VALID_LEVEL_FULL,
  /* Start bug #4386374 */
  p_data_extract_id             IN      NUMBER := null, -- Fixed for bug#4683895
  p_populate_interface_flag     IN      VARCHAR2 := null,-- Fixed for bug#4683895
  /* End bug #4386374 */
  p_return_status    OUT     NOCOPY     VARCHAR2,
  p_msg_count        OUT     NOCOPY     NUMBER,
  p_msg_data         OUT     NOCOPY     VARCHAR2
 );

PROCEDURE Perform_Data_Extract_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2,
  retcode                     OUT  NOCOPY      VARCHAR2,
  --
  p_data_extract_id           IN       NUMBER
);

/* 1308558. Mass Position Assignment Rules Enhancement.
   added an extra input parameter p_ruleset_id for passing
   the id for the default ruleset */
PROCEDURE Assign_Position_Defaults_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2,
  retcode                     OUT  NOCOPY      VARCHAR2,
  --
  p_data_extract_id            IN      NUMBER    ,
  p_request_set_flag           IN      VARCHAR2 := 'N', -- Fix for bug 4683895
  p_ruleset_id                 IN      NUMBER   := NULL -- Fix for bug 4683895

);

PROCEDURE Pre_Create_Extract_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2,
  retcode                     OUT  NOCOPY      VARCHAR2,
  --
  p_data_extract_id           IN       NUMBER
);


PROCEDURE Copy_Attributes_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2,
  retcode                     OUT  NOCOPY      VARCHAR2,
  --
  p_copy_defaults_flag         IN      VARCHAR2  ,
  p_copy_defaults_status       IN      VARCHAR2  ,
  p_copy_data_extract_id       IN      NUMBER,
  p_data_extract_method        IN      VARCHAR2,
  p_data_extract_id            IN      NUMBER
);

Procedure Copy_Elements_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2  ,
  retcode                     OUT  NOCOPY      VARCHAR2  ,
  --
  p_copy_defaults_flag         IN      VARCHAR2  ,
  p_copy_defaults_status       IN      VARCHAR2  ,
  p_copy_data_extract_id       IN      NUMBER,
  p_copy_salary_flag           IN      VARCHAR2,
  p_data_extract_method        IN      VARCHAR2,
  p_data_extract_id            IN      NUMBER
);

Procedure Copy_Position_Sets_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2  ,
  retcode                     OUT  NOCOPY      VARCHAR2  ,
  --
  p_copy_defaults_flag         IN      VARCHAR2  ,
  p_copy_defaults_status       IN      VARCHAR2  ,
  p_copy_data_extract_id       IN      NUMBER,
  p_data_extract_method        IN      VARCHAR2,
  p_data_extract_id            IN      NUMBER
);

Procedure Copy_Default_Rules_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2  ,
  retcode                     OUT  NOCOPY      VARCHAR2  ,
  --
  p_copy_defaults_flag         IN      VARCHAR2  ,
  p_copy_defaults_status       IN      VARCHAR2  ,
  p_copy_data_extract_id       IN      NUMBER,
  p_data_extract_method        IN      VARCHAR2,
  p_data_extract_id            IN      NUMBER
);

Procedure Populate_Positions_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2  ,
  retcode                     OUT  NOCOPY      VARCHAR2  ,
  --
  p_populate_interface_flag    IN      VARCHAR2  ,
  p_populate_interface_status  IN      VARCHAR2  ,
  p_populate_data_flag         IN      VARCHAR2  ,
  p_populate_data_status       IN      VARCHAR2  ,
  p_data_extract_method        IN      VARCHAR2  ,
  p_req_data_as_of_date        IN      DATE      ,
  p_position_id_flex_num       IN      NUMBER    ,
  p_business_group_id          IN      NUMBER    ,
  p_set_of_books_id            IN      NUMBER    ,
  p_data_extract_id            IN      NUMBER    ,
  -- de by org
  p_extract_by_org             IN      VARCHAR2 := 'N'
);

Procedure Populate_Elements_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2  ,
  retcode                     OUT  NOCOPY      VARCHAR2  ,
  --
  p_populate_interface_flag    IN      VARCHAR2  ,
  p_populate_interface_status  IN      VARCHAR2  ,
  p_populate_data_flag         IN      VARCHAR2  ,
  p_populate_data_status       IN      VARCHAR2  ,
  p_data_extract_method        IN      VARCHAR2  ,
  p_req_data_as_of_date        IN      DATE      ,
  p_business_group_id          IN      NUMBER    ,
  p_set_of_books_id            IN      NUMBER    ,
  p_data_extract_id            IN      NUMBER
);

Procedure Populate_Employees_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2  ,
  retcode                     OUT  NOCOPY      VARCHAR2  ,
  --
  p_populate_interface_flag    IN      VARCHAR2  ,
  p_populate_interface_status  IN      VARCHAR2  ,
  p_populate_data_flag         IN      VARCHAR2  ,
  p_populate_data_status       IN      VARCHAR2  ,
  p_data_extract_method        IN      VARCHAR2  ,
  p_business_group_id          IN      NUMBER    ,
  p_set_of_books_id            IN      NUMBER    ,
  p_req_data_as_of_date        IN      DATE      ,
  p_copy_defaults_flag         IN      VARCHAR2  ,
  p_copy_salary_flag           IN      VARCHAR2  ,
  p_data_extract_id            IN      NUMBER    ,
  -- de by org
  p_extract_by_org             IN      VARCHAR2 := 'N'
);

Procedure Populate_Attributes_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2  ,
  retcode                     OUT  NOCOPY      VARCHAR2  ,
  --
  p_populate_interface_flag    IN      VARCHAR2  ,
  p_populate_interface_status  IN      VARCHAR2  ,
  p_populate_data_flag         IN      VARCHAR2  ,
  p_populate_data_status       IN      VARCHAR2  ,
  p_data_extract_method        IN      VARCHAR2  ,
  p_req_data_as_of_date        IN      DATE      ,
  p_business_group_id          IN      NUMBER    ,
  p_set_of_books_id            IN      NUMBER    ,
  p_data_extract_id            IN      NUMBER
);

Procedure Populate_Cost_Distributions_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2  ,
  retcode                     OUT  NOCOPY      VARCHAR2  ,
  --
  p_populate_interface_flag    IN      VARCHAR2  ,
  p_populate_interface_status  IN      VARCHAR2  ,
  p_populate_data_flag         IN      VARCHAR2  ,
  p_populate_data_status       IN      VARCHAR2  ,
  p_data_extract_method        IN      VARCHAR2  ,
  p_business_group_id          IN      NUMBER    ,
  p_set_of_books_id            IN      NUMBER    ,
  p_req_data_as_of_date        IN      DATE      ,
  p_data_extract_id            IN      NUMBER    ,
  -- de by org
  p_extract_by_org	       IN      VARCHAR2 := 'N'
);

Procedure Populate_Pos_Assignments_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2  ,
  retcode                     OUT  NOCOPY      VARCHAR2  ,
  --
  p_populate_interface_flag    IN      VARCHAR2  ,
  p_populate_interface_status  IN      VARCHAR2  ,
  p_populate_data_flag         IN      VARCHAR2  ,
  p_populate_data_status       IN      VARCHAR2  ,
  p_data_extract_method        IN      VARCHAR2  ,
  p_business_group_id          IN      NUMBER    ,
  p_set_of_books_id            IN      NUMBER    ,
  p_req_data_as_of_date        IN      DATE      ,
  p_data_extract_id            IN      NUMBER    ,
  -- de by org
  p_extract_by_org             IN      VARCHAR2 := 'N'
);

Procedure Validate_Extract_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2  ,
  retcode                     OUT  NOCOPY      VARCHAR2  ,
  --
  p_validate_data_flag         IN      VARCHAR2  ,
  p_validate_data_status       IN      VARCHAR2  ,
  p_data_extract_method        IN      VARCHAR2  ,
  p_req_data_as_of_date        IN      DATE      ,
  p_business_group_id          IN      NUMBER    ,
  p_data_extract_id            IN      NUMBER
);

Procedure Post_Extract_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2  ,
  retcode                     OUT  NOCOPY      VARCHAR2  ,
  --
  p_copy_defaults_flag         IN      VARCHAR2  ,
  p_populate_interface_flag    IN      VARCHAR2  ,
  p_populate_data_flag         IN      VARCHAR2  ,
  p_validate_data_flag         IN      VARCHAR2  ,
  p_data_extract_id            IN      NUMBER
);

FUNCTION get_debug RETURN VARCHAR2;

-- de by org

PROCEDURE Insert_Organizations
(
 p_api_version         IN   NUMBER,
 p_init_msg_list       IN   VARCHAR2 := FND_API.G_FALSE,
 p_commit              IN   VARCHAR2 := FND_API.G_FALSE,
 p_validation_level    IN   NUMBER   :=  FND_API.G_VALID_LEVEL_FULL,
 p_data_extract_id     IN   NUMBER,
 p_as_of_date          IN   DATE,
 p_business_group_id   IN   NUMBER,
 p_return_status       OUT  NOCOPY     VARCHAR2,
 p_msg_count           OUT  NOCOPY     NUMBER,
 p_msg_data            OUT  NOCOPY     VARCHAR2
 );

PROCEDURE Submit_Data_Extract
(
  p_api_version               IN     NUMBER,
  p_init_msg_list             IN     VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN     VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status             OUT  NOCOPY    VARCHAR2,
  p_msg_count                 OUT  NOCOPY    NUMBER,
  p_msg_data                  OUT  NOCOPY    VARCHAR2,
  p_data_extract_id           IN     NUMBER,
  p_data_extract_method       IN     VARCHAR2,
  p_req_data_as_of_date       IN     DATE,
  p_business_group_id         IN     NUMBER,
  p_set_of_books_id           IN     NUMBER,
  p_copy_defaults_flag        IN     VARCHAR2,
  p_copy_defaults_extract_id  IN     NUMBER,
  p_copy_defaults_status      IN     VARCHAR2,
  p_populate_interface_flag   IN     VARCHAR2,
  p_populate_interface_status IN     VARCHAR2,
  p_populate_data_flag        IN     VARCHAR2,
  p_populate_data_status      IN     VARCHAR2,
  p_validate_data_flag        IN     VARCHAR2,
  p_validate_data_status      IN     VARCHAR2,
  p_position_id_flex_num      IN     NUMBER,
  p_request_id                OUT  NOCOPY    NUMBER
);

/* Bug No. 1308558 Start */
PROCEDURE Create_Default_Rule_Set
( x_return_status     OUT NOCOPY VARCHAR2,
  x_msg_count         OUT NOCOPY NUMBER,
  x_msg_data          OUT NOCOPY VARCHAR2,
  x_msg_init_list     IN         VARCHAR2 := FND_API.G_TRUE,
  p_commit            IN         VARCHAR2 := FND_API.G_FALSE,
  p_api_version       IN         NUMBER,
  p_data_extract_id   IN         NUMBER,
  p_rule_set_name     IN         VARCHAR2
);
/* Bug No. 1308558 End */

/* Bug No. 1308558 Start */
PROCEDURE Create_Default_Rule_Set_CP
( errbuf                OUT  NOCOPY  VARCHAR2,
  retcode               OUT  NOCOPY  VARCHAR2,
  p_data_extract_id     IN           NUMBER,
  p_rule_set_name       IN           VARCHAR2
);
/* Bug No. 1308558 End */


END PSB_WRHR_EXTRACT_PROCESS;

 

/
