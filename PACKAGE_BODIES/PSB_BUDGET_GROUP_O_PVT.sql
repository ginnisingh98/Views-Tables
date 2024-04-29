--------------------------------------------------------
--  DDL for Package Body PSB_BUDGET_GROUP_O_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_BUDGET_GROUP_O_PVT" AS
/* $Header: PSBWBGOB.pls 120.2 2005/07/13 11:32:45 shtripat ship $ */


PROCEDURE DELETE_ROW (
  p_api_version         in number,
  p_init_msg_list       in varchar2 := fnd_api.g_false,
  p_commit              in varchar2 := fnd_api.g_false,
  p_validation_level    in number := fnd_api.g_valid_level_full,
  p_return_status       OUT  NOCOPY varchar2,
  p_msg_count           OUT  NOCOPY number,
  p_msg_data            OUT  NOCOPY varchar2,
  p_budget_group_id     in number
) AS

BEGIN

  PSB_Budget_Groups_PVT.Delete_Review_Group(
  p_api_version,
  p_init_msg_list,
  p_commit,
  p_validation_level,
  p_return_status,
  p_msg_count,
  p_msg_data,
  p_budget_group_id
  );

END Delete_Row ;



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
  p_mode                         in varchar2
  ) AS

BEGIN


  PSB_Budget_Groups_PVT.UPDATE_ROW (
   p_api_version,
   p_init_msg_list,
   p_commit,
   p_validation_level,
   p_return_status,
   p_msg_count,
   p_msg_data,
   p_budget_group_id,
   p_name,
   p_short_name,
   p_root_budget_group,
   p_parent_budget_group_id,
   p_root_budget_group_id,
   p_ps_account_position_set_id,
   p_nps_account_position_set_id,
   p_budget_group_category_set_id,
   p_effective_start_date,
   p_effective_end_date,
   p_freeze_hierarchy_flag,
   p_description,
   p_set_of_books_id,
   p_business_group_id,
   p_num_proposed_years,
   p_narrative_description,
   p_budget_group_type,
   p_organization_id,
   p_request_id,
   p_segment1_type,
   p_segment2_type,
   p_segment3_type,
   p_segment4_type,
   p_segment5_type,
   p_segment6_type,
   p_segment7_type,
   p_segment8_type,
   p_segment9_type,
   p_segment10_type,
   p_segment11_type,
   p_segment12_type,
   p_segment13_type,
   p_segment14_type,
   p_segment15_type,
   p_segment16_type,
   p_segment17_type,
   p_segment18_type,
   p_segment19_type,
   p_segment20_type,
   p_segment21_type,
   p_segment22_type,
   p_segment23_type,
   p_segment24_type,
   p_segment25_type,
   p_segment26_type,
   p_segment27_type,
   p_segment28_type,
   p_segment29_type,
   p_segment30_type,
   p_attribute1,
   p_attribute2,
   p_attribute3,
   p_attribute4,
   p_attribute5,
   p_attribute6,
   p_attribute7,
   p_attribute8,
   p_attribute9,
   p_attribute10,
   p_context,
   p_mode);

END Update_Row ;

END PSB_Budget_Group_O_PVT ;

/
