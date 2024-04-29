--------------------------------------------------------
--  DDL for Package PSB_BUDGET_GROUPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_BUDGET_GROUPS_PVT" AUTHID CURRENT_USER AS
 /* $Header: PSBVBGPS.pls 120.2 2005/07/13 11:23:27 shtripat ship $ */

PROCEDURE INSERT_ROW (
  p_api_version                  in number,
  p_init_msg_list                in varchar2 := fnd_api.g_false,
  p_commit                       in varchar2 := fnd_api.g_false,
  p_validation_level             in number := fnd_api.g_valid_level_full,
  p_return_status                OUT  NOCOPY varchar2,
  p_msg_count                    OUT  NOCOPY number,
  p_msg_data                     OUT  NOCOPY varchar2,
  p_rowid                        in OUT  NOCOPY varchar2,
  p_budget_group_id              in number,
  p_name                         in varchar2,
  p_short_name                   in varchar2,
  p_root_budget_group            in varchar2,
  p_parent_budget_group_id       in number,
  p_root_budget_group_id         in number,
  p_ps_account_position_set_id   in number,
  p_nps_account_position_set_id  in number,
  p_budget_group_category_set_id in number,
  p_effective_start_date         in date,
  p_effective_end_date           in date,
  p_freeze_hierarchy_flag        in varchar2,
  p_description                  in varchar2,
  p_set_of_books_id              in number,
  p_business_group_id            in number,
  p_num_proposed_years           in number,
  p_narrative_description        in varchar2,
  p_budget_group_type            in varchar2,
  p_organization_id              in number,
  p_request_id                   in number,
  p_segment1_type                in number,
  p_segment2_type                in number,
  p_segment3_type                in number,
  p_segment4_type                in number,
  p_segment5_type                in number,
  p_segment6_type                in number,
  p_segment7_type                in number,
  p_segment8_type                in number,
  p_segment9_type                in number,
  p_segment10_type               in number,
  p_segment11_type               in number,
  p_segment12_type               in number,
  p_segment13_type               in number,
  p_segment14_type               in number,
  p_segment15_type               in number,
  p_segment16_type               in number,
  p_segment17_type               in number,
  p_segment18_type               in number,
  p_segment19_type               in number,
  p_segment20_type               in number,
  p_segment21_type               in number,
  p_segment22_type               in number,
  p_segment23_type               in number,
  p_segment24_type               in number,
  p_segment25_type               in number,
  p_segment26_type               in number,
  p_segment27_type               in number,
  p_segment28_type               in number,
  p_segment29_type               in number,
  p_segment30_type               in number,
  p_attribute1                   in varchar2,
  p_attribute2                   in varchar2,
  p_attribute3                   in varchar2,
  p_attribute4                   in varchar2,
  p_attribute5                   in varchar2,
  p_attribute6                   in varchar2,
  p_attribute7                   in varchar2,
  p_attribute8                   in varchar2,
  p_attribute9                   in varchar2,
  p_attribute10                  in varchar2,
  p_context                      in varchar2,
  p_mode                         in varchar2 default 'R'
  );

PROCEDURE LOCK_ROW (
  p_api_version                  in number,
  p_init_msg_list                in varchar2 := FND_API.G_FALSE,
  p_commit                       in varchar2 := FND_API.G_FALSE,
  p_validation_level             in number :=  FND_API.G_VALID_LEVEL_FULL,
  p_return_status                OUT  NOCOPY varchar2,
  p_msg_count                    OUT  NOCOPY number,
  p_msg_data                     OUT  NOCOPY varchar2,
  p_lock_row                     OUT  NOCOPY varchar2,
  p_budget_group_id              in number,
  p_name                         in varchar2,
  p_short_name                   in varchar2,
  p_root_budget_group            in varchar2,
  p_parent_budget_group_id       in number,
  p_root_budget_group_id         in number,
  p_ps_account_position_set_id   in number,
  p_nps_account_position_set_id  in number,
  p_budget_group_category_set_id in number,
  p_effective_start_date         in date,
  p_effective_end_date           in date,
  p_freeze_hierarchy_flag        in varchar2,
  p_description                  in varchar2,
  p_set_of_books_id              in number,
  p_business_group_id            in number,
  p_num_proposed_years           in number,
  p_narrative_description        in varchar2,
  p_budget_group_type            in varchar2,
  p_organization_id              in number,
  p_request_id                   in number,
  p_segment1_type                in number,
  p_segment2_type                in number,
  p_segment3_type                in number,
  p_segment4_type                in number,
  p_segment5_type                in number,
  p_segment6_type                in number,
  p_segment7_type                in number,
  p_segment8_type                in number,
  p_segment9_type                in number,
  p_segment10_type               in number,
  p_segment11_type               in number,
  p_segment12_type               in number,
  p_segment13_type               in number,
  p_segment14_type               in number,
  p_segment15_type               in number,
  p_segment16_type               in number,
  p_segment17_type               in number,
  p_segment18_type               in number,
  p_segment19_type               in number,
  p_segment20_type               in number,
  p_segment21_type               in number,
  p_segment22_type               in number,
  p_segment23_type               in number,
  p_segment24_type               in number,
  p_segment25_type               in number,
  p_segment26_type               in number,
  p_segment27_type               in number,
  p_segment28_type               in number,
  p_segment29_type               in number,
  p_segment30_type               in number,
  p_attribute1                   in varchar2,
  p_attribute2                   in varchar2,
  p_attribute3                   in varchar2,
  p_attribute4                   in varchar2,
  p_attribute5                   in varchar2,
  p_attribute6                   in varchar2,
  p_attribute7                   in varchar2,
  p_attribute8                   in varchar2,
  p_attribute9                   in varchar2,
  p_attribute10                  in varchar2,
  p_context                      in varchar2
);


PROCEDURE UPDATE_ROW (
  p_api_version                  in number,
  p_init_msg_list                in varchar2 := fnd_api.g_false,
  p_commit                       in varchar2 := fnd_api.g_false,
  p_validation_level             in number   := fnd_api.g_valid_level_full,
  p_return_status                OUT  NOCOPY varchar2,
  p_msg_count                    OUT  NOCOPY number,
  p_msg_data                     OUT  NOCOPY varchar2,
  p_budget_group_id              in number,
  p_name                         in varchar2,
  p_short_name                   in varchar2,
  p_root_budget_group            in varchar2,
  p_parent_budget_group_id       in number,
  p_root_budget_group_id         in number,
  p_ps_account_position_set_id   in number,
  p_nps_account_position_set_id  in number,
  p_budget_group_category_set_id in number,
  p_effective_start_date         in date,
  p_effective_end_date           in date,
  p_freeze_hierarchy_flag        in varchar2,
  p_description                  in varchar2,
  p_set_of_books_id              in number,
  p_business_group_id            in number,
  p_num_proposed_years           in number,
  p_narrative_description        in varchar2,
  p_budget_group_type            in varchar2,
  p_organization_id              in number,
  p_request_id                   in number,
  p_segment1_type                in number,
  p_segment2_type                in number,
  p_segment3_type                in number,
  p_segment4_type                in number,
  p_segment5_type                in number,
  p_segment6_type                in number,
  p_segment7_type                in number,
  p_segment8_type                in number,
  p_segment9_type                in number,
  p_segment10_type               in number,
  p_segment11_type               in number,
  p_segment12_type               in number,
  p_segment13_type               in number,
  p_segment14_type               in number,
  p_segment15_type               in number,
  p_segment16_type               in number,
  p_segment17_type               in number,
  p_segment18_type               in number,
  p_segment19_type               in number,
  p_segment20_type               in number,
  p_segment21_type               in number,
  p_segment22_type               in number,
  p_segment23_type               in number,
  p_segment24_type               in number,
  p_segment25_type               in number,
  p_segment26_type               in number,
  p_segment27_type               in number,
  p_segment28_type               in number,
  p_segment29_type               in number,
  p_segment30_type               in number,
  p_attribute1                   in varchar2,
  p_attribute2                   in varchar2,
  p_attribute3                   in varchar2,
  p_attribute4                   in varchar2,
  p_attribute5                   in varchar2,
  p_attribute6                   in varchar2,
  p_attribute7                   in varchar2,
  p_attribute8                   in varchar2,
  p_attribute9                   in varchar2,
  p_attribute10                  in varchar2,
  p_context                      in varchar2,
  p_mode                         in varchar2 default 'R'
  );

PROCEDURE ADD_ROW (
  p_api_version                  in number,
  p_init_msg_list                in varchar2 := fnd_api.g_false,
  p_commit                       in varchar2 := fnd_api.g_false,
  p_validation_level             in number   := fnd_api.g_valid_level_full,
  p_return_status                OUT  NOCOPY varchar2,
  p_msg_count                    OUT  NOCOPY number,
  p_msg_data                     OUT  NOCOPY varchar2,
  p_rowid                        in OUT  NOCOPY varchar2,
  p_budget_group_id              in number,
  p_name                         in varchar2,
  p_short_name                   in varchar2,
  p_root_budget_group            in varchar2,
  p_parent_budget_group_id       in number,
  p_root_budget_group_id         in number,
  p_ps_account_position_set_id   in number,
  p_nps_account_position_set_id  in number,
  p_budget_group_category_set_id in number,
  p_effective_start_date         in date,
  p_effective_end_date           in date,
  p_freeze_hierarchy_flag        in varchar2,
  p_description                  in varchar2,
  p_set_of_books_id              in number,
  p_business_group_id            in number,
  p_num_proposed_years           in number,
  p_narrative_description        in varchar2,
  p_budget_group_type            in varchar2,
  p_organization_id              in number ,
  p_request_id                   in number,
  p_segment1_type                in number,
  p_segment2_type                in number,
  p_segment3_type                in number,
  p_segment4_type                in number,
  p_segment5_type                in number,
  p_segment6_type                in number,
  p_segment7_type                in number,
  p_segment8_type                in number,
  p_segment9_type                in number,
  p_segment10_type               in number,
  p_segment11_type               in number,
  p_segment12_type               in number,
  p_segment13_type               in number,
  p_segment14_type               in number,
  p_segment15_type               in number,
  p_segment16_type               in number,
  p_segment17_type               in number,
  p_segment18_type               in number,
  p_segment19_type               in number,
  p_segment20_type               in number,
  p_segment21_type               in number,
  p_segment22_type               in number,
  p_segment23_type               in number,
  p_segment24_type               in number,
  p_segment25_type               in number,
  p_segment26_type               in number,
  p_segment27_type               in number,
  p_segment28_type               in number,
  p_segment29_type               in number,
  p_segment30_type               in number,
  p_attribute1                   in varchar2,
  p_attribute2                   in varchar2,
  p_attribute3                   in varchar2,
  p_attribute4                   in varchar2,
  p_attribute5                   in varchar2,
  p_attribute6                   in varchar2,
  p_attribute7                   in varchar2,
  p_attribute8                   in varchar2,
  p_attribute9                   in varchar2,
  p_attribute10                  in varchar2,
  p_context                      in varchar2,
  p_mode                         in varchar2 default 'R'
);

PROCEDURE DELETE_ROW (
  p_api_version         in number,
  p_init_msg_list       in varchar2 := fnd_api.g_false,
  p_commit              in varchar2 := fnd_api.g_false,
  p_validation_level    in number := fnd_api.g_valid_level_full,
  p_return_status       OUT  NOCOPY varchar2,
  p_msg_count           OUT  NOCOPY number,
  p_msg_data            OUT  NOCOPY varchar2,
  p_budget_group_id     in number,
  p_delete              OUT  NOCOPY varchar2
);

PROCEDURE Delete_Review_Group(
  p_api_version         in number,
  p_init_msg_list       in varchar2 := fnd_api.g_false,
  p_commit              in varchar2 := fnd_api.g_false,
  p_validation_level    in number := fnd_api.g_valid_level_full,
  p_return_status       OUT  NOCOPY varchar2,
  p_msg_count           OUT  NOCOPY number,
  p_msg_data            OUT  NOCOPY varchar2,
  p_budget_group_id     in number
);

PROCEDURE Copy_Budget_Group
( p_api_version          IN     NUMBER,
  p_init_msg_list        IN     VARCHAR2 := FND_API.G_FALSE,
  p_commit               IN     VARCHAR2 := FND_API.G_FALSE,
  p_validation_level     IN     NUMBER  :=  FND_API.G_VALID_LEVEL_FULL,
  p_src_budget_group_id  IN     NUMBER,
  p_curr_budget_group_id IN     NUMBER,
  p_return_status        OUT  NOCOPY    VARCHAR2,
  p_msg_count            OUT  NOCOPY    NUMBER,
  p_msg_data             OUT  NOCOPY    VARCHAR2
);
 /* ----------------------------------------------------------------------- */

  --    API name        : Check_Budget_Group_Freeze
  --    Type            : Private
  --    Pre-reqs        : FND_API, FND_MESSAGE
  --    Parameters      :
  --    IN              : p_api_version             IN   NUMBER    Required
  --                      p_init_msg_list           IN   VARCHAR2  Optional
  --                             Default = FND_API.G_FALSE
  --                      p_validation_level        IN   NUMBER    Optional
  --                             Default = FND_API.G_VALID_LEVEL_NONE
  --                      p_budget_group_id         IN   NUMBER    Required
  --                    .
  --    OUT  NOCOPY             : p_return_status           OUT  NOCOPY  VARCHAR2(1)
  --                    p_msg_count                 OUT  NOCOPY  NUMBER
  --                    p_msg_data                  OUT  NOCOPY  VARCHAR2(2000)
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 05/27/1997 by Supriyo Ghosh
  --                            Modified 06/25/1997 by Supriyo Ghosh
  --
  --    Notes   : Validate Budget Hierarchy Freeze

PROCEDURE Check_Budget_Group_Freeze
( p_api_version       IN   NUMBER,
  p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_msg_count         OUT  NOCOPY  NUMBER,
  p_msg_data          OUT  NOCOPY  VARCHAR2,
  p_budget_group_id   IN   NUMBER
);

/* ----------------------------------------------------------------------- */

  --    API name        : Val_Budget_Group_Hierarchy
  --    Type            : Private
  --    Pre-reqs        : FND_API, FND_MESSAGE
  --    Parameters      :
  --    IN              : p_api_version             IN   NUMBER    Required
  --                      p_init_msg_list           IN   VARCHAR2  Optional
  --                             Default = FND_API.G_FALSE
  --                      p_commit                  IN   VARCHAR2  Optional
  --                             Default = FND_API.G_FALSE
  --                      p_validation_level        IN   NUMBER    Optional
  --                             Default = FND_API.G_VALID_LEVEL_NONE
  --                      p_budget_group_id         IN   NUMBER    Required
  --                      p_budget_by_position      IN   VARCHAR2  Optional
  --                             Default = 'N'
  --                      p_validate_ranges         IN   VARCHAR2  Optional
  --                             Default = FND_API.G_TRUE
  --                      p_force_freeze            IN   VARCHAR2  Optional
  --                             Default = 'N'
  --                    .
  --    OUT  NOCOPY             : p_return_status           OUT  NOCOPY  VARCHAR2(1)
  --                    p_msg_count                 OUT  NOCOPY  NUMBER
  --                    p_msg_data                  OUT  NOCOPY  VARCHAR2(2000)
  --                    .
  --    Version : Current version       1.0
  --                      Initial version       1.0
  --                            Created 05/27/1997 by Supriyo Ghosh
  --                            Modified 06/25/1997 by Supriyo Ghosh
  --
  --    Notes   : Validate Budget Group Hierarchy for any root Budget Group

PROCEDURE Val_Budget_Group_Hierarchy
( p_api_version         IN   NUMBER,
  p_init_msg_list       IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status       OUT  NOCOPY  VARCHAR2,
  p_msg_count           OUT  NOCOPY  NUMBER,
  p_msg_data            OUT  NOCOPY  VARCHAR2,
  p_budget_group_id     IN   NUMBER,
  p_budget_by_position  IN   VARCHAR2 := 'N',
  p_validate_ranges     IN   VARCHAR2 := FND_API.G_TRUE,
  p_force_freeze        IN   VARCHAR2 := 'N',
  p_check_missing_acct  IN   VARCHAR2 := FND_API.G_TRUE
);

/* ----------------------------------------------------------------------- */

PROCEDURE Account_Overlap_Validation
( p_api_version       IN   NUMBER,
  p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit            IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_msg_count         OUT  NOCOPY  NUMBER,
  p_msg_data          OUT  NOCOPY  VARCHAR2,
  p_budget_group_id   IN   NUMBER
);

PROCEDURE Account_Overlap_Validation_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2,
  retcode                     OUT  NOCOPY      VARCHAR2,
  --
  p_budget_group_id           IN       NUMBER
);
PROCEDURE Val_Budget_Group_Hierarchy_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2,
  retcode                     OUT  NOCOPY      VARCHAR2,
  --
  p_budget_group_id           IN       NUMBER  ,
  p_force_freeze              IN       VARCHAR2
);

PROCEDURE DELETE_ROW_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2,
  retcode                     OUT  NOCOPY      VARCHAR2,
  --
  p_budget_group_id           IN       NUMBER
);

PROCEDURE Validate_Budget_Group_Org
( p_api_version       IN   NUMBER,
  p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_msg_count         OUT  NOCOPY  NUMBER,
  p_msg_data          OUT  NOCOPY  VARCHAR2,
  p_top_budget_group_id   IN   NUMBER
);

/* ----------------------------------------------------------------------- */
/*For Bug No : 2230514 Start*/
--FUNCTION Get_Debug RETURN VARCHAR2;
/*For Bug No : 2230514 End*/
/* ----------------------------------------------------------------------- */


END PSB_BUDGET_GROUPS_PVT;

 

/
