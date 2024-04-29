--------------------------------------------------------
--  DDL for Package Body PSB_WORKSHEET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_WORKSHEET_PVT" AS
/* $Header: PSBPWCMB.pls 120.10 2005/11/14 11:51:55 viraghun ship $ */

  G_PKG_NAME CONSTANT   VARCHAR2(30):= 'PSB_WORKSHEET_PVT';

/* ----------------------------------------------------------------------- */

PROCEDURE Create_WS_Line_Items
( p_api_version       IN   NUMBER,
  p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit            IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_msg_count         OUT  NOCOPY  NUMBER,
  p_msg_data          OUT  NOCOPY  VARCHAR2,
  p_worksheet_id      IN   NUMBER
) IS

  l_api_name          CONSTANT VARCHAR2(30)   := 'Create_WS_Line_Items';
  l_api_version       CONSTANT NUMBER         := 1.0;

BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT     Create_WS_Line_Items_Pvt;


  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;


  -- Initialize message list if p_init_msg_list is set to TRUE.

  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;


  -- Call Private Function

  PSB_WORKSHEET.Create_WS_Line_Items
     (p_api_version => 1.0,
      p_return_status => p_return_status,
      p_worksheet_id => p_worksheet_id);


  -- Standard check of p_commit.

  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;


  -- Standard call to get message count and if count is 1, get message info.

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);

EXCEPTION

   when FND_API.G_EXC_ERROR then
     rollback to Create_WS_Line_Items_Pvt;
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     rollback to Create_WS_Line_Items_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when OTHERS then
     rollback to Create_WS_Line_Items_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END Create_WS_Line_Items;

/* ----------------------------------------------------------------------- */

PROCEDURE Delete_WS_Line_Items
( p_api_version       IN   NUMBER,
  p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit            IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_msg_count         OUT  NOCOPY  NUMBER,
  p_msg_data          OUT  NOCOPY  VARCHAR2,
  p_worksheet_id      IN   NUMBER,
  p_global_worksheet  IN   VARCHAR2 := FND_API.G_TRUE
) IS

  l_api_name          CONSTANT VARCHAR2(30)   := 'Delete_WS_Line_Items';
  l_api_version       CONSTANT NUMBER         := 1.0;

BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT     Delete_WS_Line_Items_Pvt;


  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;


  -- Initialize message list if p_init_msg_list is set to TRUE.

  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;


  -- Call Private Function

  PSB_WORKSHEET.Delete_WS_Line_Items
     (p_api_version => 1.0,
      p_return_status => p_return_status,
      p_worksheet_id => p_worksheet_id,
      p_global_worksheet => p_global_worksheet);


  -- Standard check of p_commit.

  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;


  -- Standard call to get message count and if count is 1, get message info.

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);

EXCEPTION

   when FND_API.G_EXC_ERROR then
     rollback to Delete_WS_Line_Items_Pvt;
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     rollback to Delete_WS_Line_Items_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when OTHERS then
     rollback to Delete_WS_Line_Items_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END Delete_WS_Line_Items;

/* ----------------------------------------------------------------------- */

PROCEDURE Create_Worksheet
( p_api_version                       IN   NUMBER,
  p_init_msg_list                     IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit                            IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level                  IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status                     OUT  NOCOPY  VARCHAR2,
  p_msg_count                         OUT  NOCOPY  NUMBER,
  p_msg_data                          OUT  NOCOPY  VARCHAR2,
  p_budget_group_id                   IN   NUMBER,
  p_budget_calendar_id                IN   NUMBER,
  p_worksheet_type                    IN   VARCHAR2 := 'O',
  p_name                              IN   VARCHAR2,
  p_description                       IN   VARCHAR2,
  p_ws_creation_complete              IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_stage_set_id                      IN   NUMBER,
  p_current_stage_seq                 IN   NUMBER := FND_API.G_MISS_NUM,
  p_global_worksheet_id               IN   NUMBER := FND_API.G_MISS_NUM,
  p_global_worksheet_flag             IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_global_worksheet_option           IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_local_copy_flag                   IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_copy_of_worksheet_id              IN   NUMBER := FND_API.G_MISS_NUM,
  p_freeze_flag                       IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_budget_by_position                IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_use_revised_element_rates         IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_num_proposed_years                IN   NUMBER := FND_API.G_MISS_NUM,
  p_num_years_to_allocate             IN   NUMBER := FND_API.G_MISS_NUM,
  p_rounding_factor                   IN   NUMBER := FND_API.G_MISS_NUM,
  p_gl_cutoff_period                  IN   DATE := FND_API.G_MISS_DATE,
  p_budget_version_id                 IN   NUMBER := FND_API.G_MISS_NUM,
  p_gl_budget_set_id                  IN   NUMBER := FND_API.G_MISS_NUM,
  p_include_stat_balance              IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_include_trans_balance             IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_include_adj_period                IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_data_extract_id                   IN   NUMBER := FND_API.G_MISS_NUM,
  p_parameter_set_id                  IN   NUMBER := FND_API.G_MISS_NUM,
  p_constraint_set_id                 IN   NUMBER := FND_API.G_MISS_NUM,
  p_allocrule_set_id                  IN   NUMBER := FND_API.G_MISS_NUM,
  p_date_submitted                    IN   DATE := FND_API.G_MISS_DATE,
  p_submitted_by                      IN   NUMBER := FND_API.G_MISS_NUM,
  p_attribute1                        IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute2                        IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute3                        IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute4                        IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute5                        IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute6                        IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute7                        IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute8                        IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute9                        IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute10                       IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_context                           IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_create_non_pos_line_items         IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_apply_element_parameters          IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_apply_position_parameters         IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_create_positions                  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_create_summary_totals             IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_apply_constraints                 IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_flex_mapping_set_id               IN   NUMBER := FND_API.G_MISS_NUM,
  p_include_gl_commit_balance         IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_include_gl_oblig_balance          IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_include_gl_other_balance          IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_include_cbc_commit_balance        IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_include_cbc_oblig_balance         IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_include_cbc_budget_balance        IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_federal_ws_flag                   IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  /* bug no 4725091 */
  p_include_gl_forwd_balance          IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_worksheet_id                      OUT  NOCOPY  NUMBER
) IS

  l_api_name                   CONSTANT VARCHAR2(30)   := 'Create_Worksheet';
  l_api_version                CONSTANT NUMBER         := 1.0;

BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT     Create_Worksheet_Pvt;


  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;


  -- Initialize message list if p_init_msg_list is set to TRUE.

  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;


  -- Call Private Function

  PSB_WORKSHEET.Create_Worksheet
     (p_api_version => 1.0,
      p_validation_level => p_validation_level,
      p_return_status => p_return_status,
      p_budget_group_id => p_budget_group_id,
      p_budget_calendar_id => p_budget_calendar_id,
      p_worksheet_type => p_worksheet_type,
      p_name => p_name,
      p_description => p_description,
      p_ws_creation_complete => p_ws_creation_complete,
      p_stage_set_id => p_stage_set_id,
      p_current_stage_seq => p_current_stage_seq,
      p_global_worksheet_id => p_global_worksheet_id,
      p_global_worksheet_flag => p_global_worksheet_flag,
      p_global_worksheet_option => p_global_worksheet_option,
      p_local_copy_flag => p_local_copy_flag,
      p_copy_of_worksheet_id => p_copy_of_worksheet_id,
      p_freeze_flag => p_freeze_flag,
      p_budget_by_position => p_budget_by_position,
      p_use_revised_element_rates => p_use_revised_element_rates,
      p_num_proposed_years => p_num_proposed_years,
      p_num_years_to_allocate => p_num_years_to_allocate,
      p_rounding_factor => p_rounding_factor,
      p_gl_cutoff_period => p_gl_cutoff_period,
      p_budget_version_id => p_budget_version_id,
      p_gl_budget_set_id => p_gl_budget_set_id,
      p_include_stat_balance => p_include_stat_balance,
      p_include_trans_balance => p_include_trans_balance,
      p_include_adj_period => p_include_adj_period,
      p_data_extract_id => p_data_extract_id,
      p_parameter_set_id => p_parameter_set_id,
      p_constraint_set_id => p_constraint_set_id,
      p_allocrule_set_id => p_allocrule_set_id,
      p_date_submitted => p_date_submitted,
      p_submitted_by => p_submitted_by,
      p_attribute1 => p_attribute1,
      p_attribute2 => p_attribute2,
      p_attribute3 => p_attribute3,
      p_attribute4 => p_attribute4,
      p_attribute5 => p_attribute5,
      p_attribute6 => p_attribute6,
      p_attribute7 => p_attribute7,
      p_attribute8 => p_attribute8,
      p_attribute9 => p_attribute9,
      p_attribute10 => p_attribute10,
      p_context => p_context,
      p_worksheet_id => p_worksheet_id,
      p_create_non_pos_line_items => p_create_non_pos_line_items,
      p_apply_element_parameters  => p_apply_element_parameters,
      p_apply_position_parameters => p_apply_position_parameters,
      p_create_positions          => p_create_positions,
      p_create_summary_totals     => p_create_summary_totals,
      p_apply_constraints         => p_apply_constraints,
      p_flex_mapping_set_id       => p_flex_mapping_set_id,
      p_include_gl_commit_balance => p_include_gl_commit_balance,
      p_include_gl_oblig_balance  => p_include_gl_oblig_balance,
      p_include_gl_other_balance  => p_include_gl_other_balance,
      p_include_cbc_commit_balance => p_include_cbc_commit_balance,
      p_include_cbc_oblig_balance => p_include_cbc_oblig_balance,
      p_include_cbc_budget_balance => p_include_cbc_budget_balance,
      /* For Bug 3157960, added the federal ws flag */
      p_federal_ws_flag => p_federal_ws_flag,
      /* bug no 4725091 */
      p_include_gl_forwd_balance => p_include_gl_forwd_balance);

  -- Standard check of p_commit.

  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;


  -- Standard call to get message count and if count is 1, get message info.

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);

EXCEPTION

   when FND_API.G_EXC_ERROR then
     rollback to Create_Worksheet_Pvt;
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     rollback to Create_Worksheet_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when OTHERS then
     rollback to Create_Worksheet_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END Create_Worksheet;

/* ----------------------------------------------------------------------- */

PROCEDURE Update_Worksheet
( p_api_version                       IN   NUMBER,
  p_init_msg_list                     IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit                            IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level                  IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status                     OUT  NOCOPY  VARCHAR2,
  p_msg_count                         OUT  NOCOPY  NUMBER,
  p_msg_data                          OUT  NOCOPY  VARCHAR2,
  p_worksheet_id                      IN   NUMBER,
  p_worksheet_type                    IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_description                       IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_ws_creation_complete              IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_global_worksheet_id               IN   NUMBER := FND_API.G_MISS_NUM,
  p_current_stage_seq                 IN   NUMBER := FND_API.G_MISS_NUM,
  p_local_copy_flag                   IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_copy_of_worksheet_id              IN   NUMBER := FND_API.G_MISS_NUM,
  p_freeze_flag                       IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_use_revised_element_rates         IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  /* Bug # 3083970 */
  p_num_proposed_years                IN   NUMBER := FND_API.G_MISS_NUM,
  p_rounding_factor                   IN   NUMBER := FND_API.G_MISS_NUM,
  /* End bug */
  p_date_submitted                    IN   DATE := FND_API.G_MISS_DATE,
  p_submitted_by                      IN   NUMBER := FND_API.G_MISS_NUM,
  p_attribute1                        IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute2                        IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute3                        IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute4                        IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute5                        IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute6                        IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute7                        IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute8                        IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute9                        IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_attribute10                       IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_context                           IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_create_non_pos_line_items         IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_apply_element_parameters          IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_apply_position_parameters         IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_create_positions                  IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_create_summary_totals             IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_apply_constraints                 IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_include_gl_commit_balance         IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_include_gl_oblig_balance          IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_include_gl_other_balance          IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_include_cbc_commit_balance        IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_include_cbc_oblig_balance         IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_include_cbc_budget_balance        IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  /* For Bug No. 2312657 : Start */
  p_gl_cutoff_period                  IN   DATE := NULL,
  p_gl_budget_set_id                  IN   NUMBER := NULL,
  /* For Bug No. 2312657 : End */
  p_federal_ws_flag                   IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  /* bug no 4725091 */
  p_include_gl_forwd_balance          IN   VARCHAR2 := FND_API.G_MISS_CHAR
) IS

  l_api_name                   CONSTANT VARCHAR2(30)   := 'Update_Worksheet';
  l_api_version                CONSTANT NUMBER         := 1.0;

BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT     Update_Worksheet_Pvt;


  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;


  -- Initialize message list if p_init_msg_list is set to TRUE.

  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;


  -- Call Private Function

  PSB_WORKSHEET.Update_Worksheet
     (p_api_version => 1.0,
      p_validation_level => p_validation_level,
      p_return_status => p_return_status,
      p_worksheet_id => p_worksheet_id,
      p_worksheet_type => p_worksheet_type,
      p_description => p_description,
      p_ws_creation_complete => p_ws_creation_complete,
      p_global_worksheet_id => p_global_worksheet_id,
      p_current_stage_seq => p_current_stage_seq,
      p_local_copy_flag => p_local_copy_flag,
      p_copy_of_worksheet_id => p_copy_of_worksheet_id,
      p_freeze_flag => p_freeze_flag,
      p_use_revised_element_rates => p_use_revised_element_rates,
      /* Bug # 3083970 */
      p_num_proposed_years => p_num_proposed_years,
      p_rounding_factor => p_rounding_factor,
      /* End bug */
      p_date_submitted => p_date_submitted,
      p_submitted_by => p_submitted_by,
      p_attribute1 => p_attribute1,
      p_attribute2 => p_attribute2,
      p_attribute3 => p_attribute3,
      p_attribute4 => p_attribute4,
      p_attribute5 => p_attribute5,
      p_attribute6 => p_attribute6,
      p_attribute7 => p_attribute7,
      p_attribute8 => p_attribute8,
      p_attribute9 => p_attribute9,
      p_attribute10 => p_attribute10,
      p_context => p_context,
      p_create_non_pos_line_items => p_create_non_pos_line_items,
      p_apply_element_parameters  => p_apply_element_parameters,
      p_apply_position_parameters => p_apply_position_parameters,
      p_create_positions          => p_create_positions,
      p_create_summary_totals     => p_create_summary_totals,
      p_apply_constraints         => p_apply_constraints,
      p_include_gl_commit_balance => p_include_gl_commit_balance,
      p_include_gl_oblig_balance  => p_include_gl_oblig_balance,
      p_include_gl_other_balance  => p_include_gl_other_balance,
      p_include_cbc_commit_balance => p_include_cbc_commit_balance,
      p_include_cbc_oblig_balance => p_include_cbc_oblig_balance,
      p_include_cbc_budget_balance => p_include_cbc_budget_balance,
     /* For Bug No. 2312657 : Start */
      p_gl_cutoff_period           => p_gl_cutoff_period,
      p_gl_budget_set_id           => p_gl_budget_set_id,
      /* For Bug No. 2312657 : End */
      /* For Bug No. 3157960, added federal_ws_flag */
      p_federal_ws_flag            => p_federal_ws_flag,
      /* bug no 4725091 */
      p_include_gl_forwd_balance   => p_include_gl_forwd_balance
      );

  -- Standard check of p_commit.

  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;


  -- Standard call to get message count and if count is 1, get message info.

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);

EXCEPTION

   when FND_API.G_EXC_ERROR then
     rollback to Update_Worksheet_Pvt;
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     rollback to Update_Worksheet_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   when OTHERS then
     rollback to Update_Worksheet_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END Update_Worksheet;

/* ----------------------------------------------------------------------- */

PROCEDURE Delete_Worksheet
( p_api_version    IN   NUMBER,
  p_init_msg_list  IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit         IN   VARCHAR2 := FND_API.G_FALSE,
  p_return_status  OUT  NOCOPY  VARCHAR2,
  p_msg_count      OUT  NOCOPY  NUMBER,
  p_msg_data       OUT  NOCOPY  VARCHAR2,
  p_worksheet_id   IN   NUMBER
) IS

  l_api_name       CONSTANT VARCHAR2(30)   := 'Delete_Worksheet';
  l_api_version    CONSTANT NUMBER         := 1.0;

BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT     Delete_Worksheet_Pvt;


  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;


  -- Initialize message list if p_init_msg_list is set to TRUE.

  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;


  -- Call Private Function

  PSB_WORKSHEET.Delete_Worksheet
     (p_api_version => 1.0,
      p_return_status => p_return_status,
      p_worksheet_id => p_worksheet_id);


  -- Standard check of p_commit.

  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;


  -- Standard call to get message count and if count is 1, get message info.

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);

EXCEPTION

   when FND_API.G_EXC_ERROR then
     rollback to Delete_Worksheet_Pvt;
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then
     rollback to Delete_Worksheet_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when OTHERS then
     rollback to Delete_Worksheet_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


END Delete_Worksheet;

/* ----------------------------------------------------------------------- */

PROCEDURE Apply_Constraints
( p_api_version               IN   NUMBER,
  p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN   NUMBER  :=  FND_API.G_VALID_LEVEL_NONE,
  p_return_status             OUT  NOCOPY  VARCHAR2,
  p_msg_count                 OUT  NOCOPY  NUMBER,
  p_msg_data                  OUT  NOCOPY  VARCHAR2,
  p_validation_status         OUT  NOCOPY  VARCHAR2,
  p_worksheet_id              IN   NUMBER,
  p_budget_group_id           IN   NUMBER := FND_API.G_MISS_NUM,
  p_flex_code                 IN   NUMBER := FND_API.G_MISS_NUM,
  p_func_currency             IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_global_worksheet_id       IN   NUMBER := FND_API.G_MISS_NUM,
  p_constraint_set_id         IN   NUMBER := FND_API.G_MISS_NUM,
  p_constraint_set_name       IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_constraint_set_threshold  IN   NUMBER := FND_API.G_MISS_NUM,
  p_budget_calendar_id        IN   NUMBER := FND_API.G_MISS_NUM,
  p_data_extract_id           IN   NUMBER := FND_API.G_MISS_NUM,
  p_business_group_id         IN   NUMBER := FND_API.G_MISS_NUM,
  p_budget_by_position        IN   VARCHAR2 := FND_API.G_MISS_CHAR
) IS

  l_api_name                  CONSTANT VARCHAR2(30)   := 'Apply_Constraints';
  l_api_version               CONSTANT NUMBER         := 1.0;

BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT     Apply_Constraints_Pvt;


  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;

  end if;


  -- Initialize message list if p_init_msg_list is set to TRUE.

  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;


  -- Call Private Function

  PSB_WORKSHEET.Apply_Constraints
     (p_api_version => 1.0,
      p_validation_level => p_validation_level,
      p_return_status => p_return_status,
      p_validation_status => p_validation_status,
      p_worksheet_id => p_worksheet_id,
      p_budget_group_id => p_budget_group_id,
      p_flex_code => p_flex_code,
      p_func_currency => p_func_currency,
      p_global_worksheet_id => p_global_worksheet_id,
      p_constraint_set_id => p_constraint_set_id,
      p_constraint_set_name => p_constraint_set_name,
      p_constraint_set_threshold => p_constraint_set_threshold,
      p_budget_calendar_id => p_budget_calendar_id,
      p_data_extract_id => p_data_extract_id,
      p_business_group_id => p_business_group_id,
      p_budget_by_position => p_budget_by_position);


  -- Standard check of p_commit.

  if FND_API.to_Boolean (p_commit) then
    commit work;
  end if;


  -- Standard call to get message count and if count is 1, get message info.

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);

EXCEPTION

   when FND_API.G_EXC_ERROR then
     rollback to Apply_Constraints_Pvt;
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then
     rollback to Apply_Constraints_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when OTHERS then
     rollback to Apply_Constraints_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


END Apply_Constraints;

/* ----------------------------------------------------------------------- */

PROCEDURE Validate_Entity_Set
( p_api_version        IN   NUMBER,
  p_init_msg_list      IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level   IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status      OUT  NOCOPY  VARCHAR2,
  p_msg_count          OUT  NOCOPY  NUMBER,
  p_msg_data           OUT  NOCOPY  VARCHAR2,
  p_data_extract_id    IN   NUMBER,
  p_parameter_set_id   IN   NUMBER,
  p_constraint_set_id  IN   NUMBER
) IS

  l_api_name           CONSTANT VARCHAR2(30)   := 'Validate_Entity_Set';
  l_api_version        CONSTANT NUMBER         := 1.0;

BEGIN

  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;

  end if;


  -- Initialize message list if p_init_msg_list is set to TRUE.

  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;


  -- Call Private Function

  PSB_WORKSHEET.Validate_Entity_Set
     (p_api_version => 1.0,
      p_validation_level => p_validation_level,
      p_return_status => p_return_status,
      p_data_extract_id => p_data_extract_id,
      p_parameter_set_id => p_parameter_set_id,
      p_constraint_set_id => p_constraint_set_id);


  -- Standard call to get message count and if count is 1, get message info.

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);

EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when OTHERS then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


END Validate_Entity_Set;

/* ----------------------------------------------------------------------- */

PROCEDURE Delete_WPL
( p_api_version       IN   NUMBER,
  p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_msg_count         OUT  NOCOPY  NUMBER,
  p_msg_data          OUT  NOCOPY  VARCHAR2,
  p_worksheet_id      IN   NUMBER,
  p_position_line_id  IN   NUMBER
) IS

  l_api_name          CONSTANT VARCHAR2(30)   := 'Delete_WPL';
  l_api_version       CONSTANT NUMBER         := 1.0;

BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT     Delete_WPL_Pvt;

  -- Standard call to check for call compatibility.

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;

  end if;


  -- Initialize message list if p_init_msg_list is set to TRUE.

  if FND_API.to_Boolean (p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;


  -- Call Private Function

  PSB_WORKSHEET.Delete_WPL
     (p_api_version => 1.0,
      p_validation_level => p_validation_level,
      p_return_status => p_return_status,
      p_worksheet_id => p_worksheet_id,
      p_position_line_id => p_position_line_id);


  -- Standard call to get message count and if count is 1, get message info.

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);

EXCEPTION

   when FND_API.G_EXC_ERROR then
     rollback to Delete_WPL_Pvt;
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when FND_API.G_EXC_UNEXPECTED_ERROR then
     rollback to Delete_WPL_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   when OTHERS then
     rollback to Delete_WPL_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     end if;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


END Delete_WPL;

/*===========================================================================+
 |                   PROCEDURE Create_Worksheet_Line_Items_CP                |
 +===========================================================================*/
--
-- This is the execution file for the concurrent program 'Create Worksheet
-- Line Items '
--
PROCEDURE Create_Worksheet_Line_Items_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2  ,
  retcode                     OUT  NOCOPY      VARCHAR2  ,
  --
  p_worksheet_id              IN       NUMBER
)
IS
  l_api_name       CONSTANT VARCHAR2(30)   := 'Create_Worksheet_Line_Items_CP';
  l_api_version    CONSTANT NUMBER         :=  1.0 ;
  --
  l_error_api_name          VARCHAR2(2000);
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;
  l_msg_index_out           NUMBER;
  l_name                    VARCHAR2(80);
  l_data_extract_id         NUMBER;

  l_validation_status       VARCHAR2(1) ;
  l_rep_req_id              NUMBER;
  l_reqid                   NUMBER;

  -- Bug 3458191: Add a new variable for caching
  l_global_worksheet_id     NUMBER;

  /* Bug 3458191: Comment out the following since they are longer used.
  l_root_budget_group_id    NUMBER;
  l_account_set_id          NUMBER;

  cursor c_BG is
    select nvl(b.data_extract_id, b.global_data_extract_id) data_extract_id,
           nvl(a.root_budget_group_id, a.budget_group_id) root_budget_group_id
      from PSB_BUDGET_GROUPS_V a,
           PSB_WORKSHEETS_V b
     where a.budget_group_id = b.budget_group_id
       and b.worksheet_id = p_worksheet_id;
  */

BEGIN

  /* Bug 3458191 start: Get the global worksheet id and data extract id */
  SELECT nvl(global_worksheet_id, worksheet_id) global_worksheet_id,
         data_extract_id
  INTO   l_global_worksheet_id,
         l_data_extract_id
  FROM   psb_worksheets
  WHERE  worksheet_id = p_worksheet_id;

  -- Do not need to query if it's a global worksheet
  IF p_worksheet_id <> l_global_worksheet_id THEN
    SELECT data_extract_id INTO l_data_extract_id
    FROM   psb_worksheets
    WHERE  worksheet_id = l_global_worksheet_id ;
  END IF;
  /* Bug 3458191 end */

  /* Bug 3458191: Comment out the following calls because they are called in
     Validate_Accounts_CP

  for c_BG_Rec in c_BG loop
    l_data_extract_id := c_BG_Rec.data_extract_id;
    l_root_budget_group_id := c_BG_Rec.root_budget_group_id;
  end loop;

  PSB_BUDGET_ACCOUNT_PVT.Populate_Budget_Accounts
     (p_api_version       =>  1.0,
      p_init_msg_list     =>  FND_API.G_TRUE,
      p_commit            =>  FND_API.G_TRUE,
      p_return_status     =>  l_return_status,
      p_msg_count         =>  l_msg_count,
      p_msg_data          =>  l_msg_data,
      p_account_set_id    =>  l_account_set_id
      );

  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    raise FND_API.G_EXC_ERROR;
  end if;

  PSB_BUDGET_GROUPS_PVT.Val_Budget_Group_Hierarchy
     (p_api_version   => 1.0,
      p_init_msg_list => FND_API.G_TRUE,
      p_return_status => l_return_status,
      p_msg_count     => l_msg_count,
      p_msg_data      => l_msg_data,
      p_budget_group_id     => l_root_budget_group_id,
      p_validate_ranges     => FND_API.G_FALSE,
      p_check_missing_acct  => FND_API.G_FALSE);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    raise FND_API.G_EXC_ERROR;
  end if;
  */

  PSB_BUDGET_POSITION_PVT.Populate_Budget_Positions
     (p_api_version       =>  1.0,
      p_commit            =>  FND_API.G_TRUE,
      p_return_status     =>  l_return_status,
      p_msg_count         =>  l_msg_count,
      p_msg_data          =>  l_msg_data,
      p_data_extract_id   =>  l_data_extract_id
      );

  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    raise FND_API.G_EXC_ERROR;
  end if;

  -- Validate data consistency for all Positions

  PSB_POSITIONS_PVT.Position_WS_Validation
    (p_api_version          => 1.0,
     p_return_status        => l_return_status,
     p_msg_count            => l_msg_count,
     p_msg_data             => l_msg_data,
     p_worksheet_id         => p_worksheet_id,
     p_validation_status    => l_validation_status
    );

  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    raise FND_API.G_EXC_ERROR;
  end if;

  if l_validation_status <> FND_API.G_RET_STS_SUCCESS THEN
    -- submit concurrent request for error report
    -- waiting for correction to error messages report

    l_rep_req_id := Fnd_Request.Submit_Request
		       (application   => 'PSB'                          ,
			program       => 'PSBRPERR'                     ,
			description   => 'Position Worksheet Exception Report',
			start_time    =>  NULL                          ,
			sub_request   =>  FALSE                         ,
			argument1     =>  'POSITION_WORKSHEET_EXCEPTION',
			argument2     =>  p_worksheet_id,
			argument3     =>  l_reqid
		      );
    --
    if l_rep_req_id = 0 then
    --
    fnd_message.set_name('PSB', 'PSB_FAIL_TO_SUBMIT_REQUEST');
    --
    end if;

  end if;

  PSB_WORKSHEET_PVT.Create_WS_Line_Items
     (p_api_version   => 1.0,
      p_return_status => l_return_status,
      p_msg_count     => l_msg_count,
      p_msg_data      => l_msg_data,
      p_worksheet_id  => p_worksheet_id);

  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    raise FND_API.G_EXC_ERROR;
  end if;

  PSB_MESSAGE_S.Print_Success;
  retcode := 0 ;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     --
     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
			       p_print_header =>  FND_API.G_TRUE );
     retcode := 2 ;
     COMMIT WORK ;
     --
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     --
     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE );
     retcode := 2 ;
     COMMIT WORK ;
     --
   WHEN OTHERS THEN
     --
     IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
      --
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,
			       l_api_name  ) ;
     END IF ;
     --
     l_return_status := FND_API.G_RET_STS_ERROR;

     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				 p_print_header =>  FND_API.G_TRUE );
     --
     retcode := 2 ;
     COMMIT WORK ;
     --
END Create_Worksheet_Line_Items_CP;


/*===========================================================================+
 |                   PROCEDURE Validate_Accounts_CP                             |
 +===========================================================================*/
--
-- This is the execution file for the concurrent program 'Validate Accounts'
--
PROCEDURE Validate_Accounts_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2  ,
  retcode                     OUT  NOCOPY      VARCHAR2  ,
  --
  p_worksheet_id              IN       NUMBER
)
IS
  l_api_name       CONSTANT VARCHAR2(30)   := 'Validate_Accounts_CP';
  l_api_version    CONSTANT NUMBER         :=  1.0 ;
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;
  l_root_budget_group_id    NUMBER;

  -- Bug 3458191
  l_set_of_books_id         NUMBER;

BEGIN

  -- Bug 3458191: Retrieve root budget group id, and set of books id
  SELECT bg.budget_group_id,
         bg.set_of_books_id
    INTO l_root_budget_group_id,
         l_set_of_books_id
    FROM psb_budget_groups bg
   WHERE bg.budget_group_id =
         (SELECT nvl(bg1.root_budget_group_id, bg1.budget_group_id) root_budget_group_id
            FROM psb_worksheets ws, psb_budget_groups bg1
           WHERE bg1.budget_group_id = ws.budget_group_id
                 and ws.worksheet_id = p_worksheet_id);

  PSB_Budget_Account_PVT.Populate_Budget_Accounts
  (
    p_api_version       =>  1.0                         ,
    p_init_msg_list     =>  FND_API.G_TRUE              ,
    p_commit            =>  FND_API.G_FALSE             ,
    p_validation_level  =>  FND_API.G_VALID_LEVEL_FULL  ,
    p_return_status     =>  l_return_status             ,
    p_msg_count         =>  l_msg_count                 ,
    p_msg_data          =>  l_msg_data                  ,
    -- Bug 3458191: Pass set of books id
    p_set_of_books_id   =>  l_set_of_books_id
  );

  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    raise FND_API.G_EXC_ERROR;
  end if;

  PSB_BUDGET_GROUPS_PVT.Val_Budget_Group_Hierarchy
  (
    p_api_version   => 1.0,
    p_init_msg_list => FND_API.G_TRUE,
    p_return_status => l_return_status,
    p_msg_count     => l_msg_count,
    p_msg_data      => l_msg_data,
    p_budget_group_id     => l_root_budget_group_id,
    p_validate_ranges     => FND_API.G_FALSE,
    p_check_missing_acct  => FND_API.G_FALSE
  );

  if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    raise FND_API.G_EXC_ERROR;
  end if;

  PSB_MESSAGE_S.Print_Success;
  retcode := 0 ;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     --
     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				 p_print_header =>  FND_API.G_TRUE );
     retcode := 2 ;
     COMMIT WORK ;
     --
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     --
     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE );
     retcode := 2 ;
     COMMIT WORK ;
     --
  WHEN OTHERS THEN

      --
     IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
      --
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,
			       l_api_name  ) ;
     END IF ;
     --
     l_return_status := FND_API.G_RET_STS_ERROR;

     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				 p_print_header =>  FND_API.G_TRUE );
     --
     retcode := 2 ;
     COMMIT WORK ;
     --
END Validate_Accounts_CP;


/*===========================================================================+
 |                   PROCEDURE Pre_Create_WS_Lines_CP                             |
 +===========================================================================*/
--
-- This is the execution file for the concurrent program 'Pre_Create_WS_Lines'
--
PROCEDURE Pre_Create_WS_Lines_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2  ,
  retcode                     OUT  NOCOPY      VARCHAR2  ,
  --
  p_worksheet_id              IN       NUMBER
)
IS
  l_api_name       CONSTANT VARCHAR2(30)   := 'Pre_Create_Line_Items';
  l_api_version    CONSTANT NUMBER         :=  1.0 ;
  --
  l_return_status           VARCHAR2(1) ;

BEGIN

    PSB_WORKSHEET.Pre_Create_Line_Items
     (p_api_version       => 1.0,
      p_return_status     => l_return_status,
      p_worksheet_id      => p_worksheet_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      raise FND_API.G_EXC_ERROR;
    end if;

  PSB_MESSAGE_S.Print_Success;
  retcode := 0 ;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
     --
     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				 p_print_header =>  FND_API.G_TRUE );
     retcode := 2 ;
     COMMIT WORK ;
     --
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     --
     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE );
     retcode := 2 ;
     COMMIT WORK ;
     --
  WHEN OTHERS THEN

      --
     IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
      --
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,
			       l_api_name  ) ;
     END IF ;
     --
     l_return_status := FND_API.G_RET_STS_ERROR;

     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				 p_print_header =>  FND_API.G_TRUE );
     --
     retcode := 2 ;
     COMMIT WORK ;
     --
END Pre_Create_WS_Lines_CP;

/*===========================================================================+
 |                   PROCEDURE Create_Acct_Line_Items_CP                      |
 +===========================================================================*/
--
-- This is the execution file for the concurrent program 'Create Account
-- Line Items '
--
PROCEDURE Create_Acct_Line_Items_CP
(
  errbuf                             OUT  NOCOPY      VARCHAR2  ,
  retcode                            OUT  NOCOPY      VARCHAR2  ,
  --
  p_create_non_pos_line_items        IN       VARCHAR2,
  p_worksheet_id                     IN       NUMBER
)
IS
  l_api_name       CONSTANT VARCHAR2(30)   := 'Create_Acct_Line_Items_CP';
  l_api_version    CONSTANT NUMBER         :=  1.0 ;
  --
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;

/* Bug No 2550186 Start */
  l_msg_buf                 VARCHAR2(2000);
/* Bug No 2550186 End */

BEGIN
  --If the Flag is 'N' then do not process at all
  IF p_create_non_pos_line_items = 'Y' then

    -- Bug 3458191: Make g_worksheet_creation_flag to TRUE for ws caching
    PSB_WORKSHEET.g_ws_creation_flag := TRUE;

    PSB_WORKSHEET.Create_Acct_Line_Items
     (p_api_version       => 1.0,
      p_return_status     => l_return_status,
      p_worksheet_id      => p_worksheet_id);

    -- Bug 3458191: Reset g_worksheet_creation_flag to FALSE
    PSB_WORKSHEET.g_ws_creation_flag := FALSE;

    if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      raise FND_API.G_EXC_ERROR;
    end if;

  END IF;

/* Bug No 2550186 Start */
    -- Count total number of messages.
    l_msg_count := FND_MSG_PUB.Count_Msg;

    if l_msg_count > 0 then
       FND_MESSAGE.Set_Name('PSB', 'PSB_PROGRAM_WARNING_HEADER');
       l_msg_buf  := FND_Message.Get;
       FND_FILE.Put_Line(FND_FILE.LOG, l_msg_buf);

       PSB_MESSAGE_S.Print_Error ( p_mode         =>  FND_FILE.LOG,
				   p_print_header =>  FND_API.G_FALSE);
    end if;
/* Bug No 2550186 End */

  PSB_MESSAGE_S.Print_Success;

/* Bug No 2550186 Start */
  if l_msg_count > 0 then
     FND_MESSAGE.Set_Name('PSB', 'PSB_SUCCESS_WARNING_HEADER');
     l_msg_buf  := FND_Message.Get;
     FND_FILE.Put_Line(FND_FILE.OUTPUT, l_msg_buf);
  end if;
/* Bug No 2550186 End */

  retcode := 0 ;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
     --
    PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				 p_print_header =>  FND_API.G_TRUE );
    retcode := 2 ;
    COMMIT WORK ;
    --
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     --
    PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE );
    retcode := 2 ;
    COMMIT WORK ;
    --
  WHEN OTHERS THEN

    --
    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
    --
    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,
			       l_api_name  ) ;
    END IF ;
     --
    l_return_status := FND_API.G_RET_STS_ERROR;

    PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				 p_print_header =>  FND_API.G_TRUE );
    --
    retcode := 2 ;
    COMMIT WORK ;
    --
END Create_Acct_Line_Items_CP;

/*===========================================================================+
 |                   PROCEDURE Create_Pos_Line_Items_CP                      |
 +===========================================================================*/
--
-- This is the execution file for the concurrent program 'Create Position
-- Line Items '
--
PROCEDURE Create_Pos_Line_Items_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2  ,
  retcode                     OUT  NOCOPY      VARCHAR2  ,
  --
  p_create_positions          IN       VARCHAR2  ,
  p_worksheet_id              IN       NUMBER
)
IS
  l_api_name       CONSTANT VARCHAR2(30)   := 'Create_Pos_Line_Items_CP';
  l_api_version    CONSTANT NUMBER         :=  1.0 ;
  --
  l_return_status           VARCHAR2(1) ;

BEGIN

  IF p_create_positions = 'Y' THEN

    PSB_WORKSHEET.Create_Pos_Line_Items
     (p_api_version       => 1.0,
      p_return_status     => l_return_status,
      p_worksheet_id      => p_worksheet_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      raise FND_API.G_EXC_ERROR;
    end if;

  ELSE

    NULL;

  END IF;

  PSB_MESSAGE_S.Print_Success;
  retcode := 0 ;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
     --
     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				 p_print_header =>  FND_API.G_TRUE );
     retcode := 2 ;
     COMMIT WORK ;
     --
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     --
     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE );
     retcode := 2 ;
     COMMIT WORK ;
     --
  WHEN OTHERS THEN

     --
     IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
     --
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,
			       l_api_name  ) ;
     END IF ;
     --
     l_return_status := FND_API.G_RET_STS_ERROR;

     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				 p_print_header =>  FND_API.G_TRUE );
     --
     retcode := 2 ;
     COMMIT WORK ;
     --

END Create_Pos_Line_Items_CP;

/*===========================================================================+
 |                   PROCEDURE Apply_Acct_Constraints_CP                      |
 +===========================================================================*/
--
-- This is the execution file for the concurrent program 'Apply Account
-- Constraints '
--
PROCEDURE Apply_Acct_Constraints_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2  ,
  retcode                     OUT  NOCOPY      VARCHAR2  ,
  --
  p_apply_constraints         IN       VARCHAR2  ,
  p_worksheet_id              IN       NUMBER
)
IS
  l_api_name       CONSTANT VARCHAR2(30)   := 'Apply_Acct_Constraints_CP';
  l_api_version    CONSTANT NUMBER         :=  1.0 ;
  l_validation_status       VARCHAR2(1);
  --
  l_return_status           VARCHAR2(1) ;

BEGIN

  IF p_apply_constraints = 'Y' THEN

    PSB_WORKSHEET.Apply_Acct_Constraints
     (p_api_version       => 1.0,
      p_return_status     => l_return_status,
      p_worksheet_id      => p_worksheet_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      raise FND_API.G_EXC_ERROR;
    end if;

  ELSE

    NULL;

  END IF;

  PSB_MESSAGE_S.Print_Success;
  retcode := 0 ;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
     --
     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				 p_print_header =>  FND_API.G_TRUE );
     retcode := 2 ;
     COMMIT WORK ;
     --
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     --
     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE );
     retcode := 2 ;
     COMMIT WORK ;
     --
  WHEN OTHERS THEN

     --
     IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
     --
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,
			       l_api_name  ) ;
     END IF ;
     --
     l_return_status := FND_API.G_RET_STS_ERROR;

     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				 p_print_header =>  FND_API.G_TRUE );
     --
     retcode := 2 ;
     COMMIT WORK ;
     --

END Apply_Acct_Constraints_CP;


/*===========================================================================+
 |                   PROCEDURE Apply_Pos_Constraints_CP                      |
 +===========================================================================*/
--
-- This is the execution file for the concurrent program 'Apply Position
-- Constraints '
--
PROCEDURE Apply_Pos_Constraints_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2  ,
  retcode                     OUT  NOCOPY      VARCHAR2  ,
  --
  p_apply_constraints         IN       VARCHAR2  ,
  p_worksheet_id              IN       NUMBER
)
IS
  l_api_name       CONSTANT VARCHAR2(30)   := 'Apply_Pos_Constraints_CP';
  l_api_version    CONSTANT NUMBER         :=  1.0 ;
  l_validation_status       VARCHAR2(1);
  --
  l_return_status           VARCHAR2(1) ;

BEGIN
  IF p_apply_constraints = 'Y' THEN

    PSB_WORKSHEET.Apply_Pos_Constraints
     (p_api_version       => 1.0,
      p_return_status     => l_return_status,
      p_worksheet_id      => p_worksheet_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      raise FND_API.G_EXC_ERROR;
    end if;

  ELSE

    NULL;

  END IF;

  PSB_MESSAGE_S.Print_Success;
  retcode := 0 ;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     --
     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				 p_print_header =>  FND_API.G_TRUE );
     retcode := 2 ;
     COMMIT WORK ;
     --
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     --
     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE );
     retcode := 2 ;
     COMMIT WORK ;
     --
  WHEN OTHERS THEN

     --
     IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
     --
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,
			       l_api_name  ) ;
     END IF ;
     --
     l_return_status := FND_API.G_RET_STS_ERROR;

     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				 p_print_header =>  FND_API.G_TRUE );
     --
     retcode := 2 ;
     COMMIT WORK ;
     --

END Apply_Pos_Constraints_CP;


/*===========================================================================+
 |                   PROCEDURE Apply_Elem_Constraints_CP                     |
 +===========================================================================*/
--
-- This is the execution file for the concurrent program 'Apply Element
-- Constraints '
--
PROCEDURE Apply_Elem_Constraints_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2  ,
  retcode                     OUT  NOCOPY      VARCHAR2  ,
  --
  p_apply_constraints         IN       VARCHAR2  ,
  p_worksheet_id              IN       NUMBER
)
IS
  l_api_name       CONSTANT VARCHAR2(30)   := 'Apply_Elem_Constraints_CP';
  l_api_version    CONSTANT NUMBER         :=  1.0 ;
  l_validation_status       VARCHAR2(1);
  --
  l_return_status           VARCHAR2(1) ;

BEGIN

  IF p_apply_constraints = 'Y' THEN

    PSB_WORKSHEET.Apply_Elem_Constraints
     (p_api_version       => 1.0,
      p_return_status     => l_return_status,
      p_worksheet_id      => p_worksheet_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      raise FND_API.G_EXC_ERROR;
    end if;

  ELSE

    NULL;

  END IF;

  PSB_MESSAGE_S.Print_Success;
  retcode := 0 ;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     --
     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				 p_print_header =>  FND_API.G_TRUE );
     retcode := 2 ;
     COMMIT WORK ;
     --
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     --
     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE );
     retcode := 2 ;
     COMMIT WORK ;
     --
  WHEN OTHERS THEN

     --
     IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
     --
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,
			       l_api_name  ) ;
     END IF ;
     --
     l_return_status := FND_API.G_RET_STS_ERROR;

     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				 p_print_header =>  FND_API.G_TRUE );
     --
     retcode := 2 ;
     COMMIT WORK ;
     --

END Apply_Elem_Constraints_CP;

/*===========================================================================+
 |                   PROCEDURE Post_Create_WS_Lines_CP                             |
 +===========================================================================*/
--
-- This is the execution file for the concurrent program 'Post_Create_WS_Lines'
--
PROCEDURE Post_Create_WS_Lines_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2  ,
  retcode                     OUT  NOCOPY      VARCHAR2  ,
  --
  p_worksheet_id              IN       NUMBER
)
IS
  l_api_name       CONSTANT VARCHAR2(30)   := 'Post_Create_WS_Lines_CP';
  l_api_version    CONSTANT NUMBER         :=  1.0 ;
  --
  l_return_status           VARCHAR2(1) ;

BEGIN

    PSB_WORKSHEET.Post_Create_Line_Items
     (p_api_version       => 1.0,
      p_return_status     => l_return_status,
      p_worksheet_id      => p_worksheet_id);

    if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      raise FND_API.G_EXC_ERROR;
    end if;

  PSB_MESSAGE_S.Print_Success;
  retcode := 0 ;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     --
     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				 p_print_header =>  FND_API.G_TRUE );
     retcode := 2 ;
     COMMIT WORK ;
     --
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     --
     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				p_print_header =>  FND_API.G_TRUE );
     retcode := 2 ;
     COMMIT WORK ;
     --
  WHEN OTHERS THEN

      --
     IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
      --
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,
			       l_api_name  ) ;
     END IF ;
     --
     l_return_status := FND_API.G_RET_STS_ERROR;

     PSB_MESSAGE_S.Print_Error ( p_mode         => FND_FILE.LOG ,
				 p_print_header =>  FND_API.G_TRUE );
     --
     retcode := 2 ;
     COMMIT WORK ;
     --
END Post_Create_WS_Lines_CP;

/* ----------------------------------------------------------------------- */

END PSB_WORKSHEET_PVT;

/
