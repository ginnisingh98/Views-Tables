--------------------------------------------------------
--  DDL for Package Body PSB_BUDGET_GROUP_D_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_BUDGET_GROUP_D_PVT" AS
/* $Header: PSBWBGDB.pls 120.2 2005/07/13 11:32:13 shtripat ship $ */


/* ----------------------------------------------------------------------- */

PROCEDURE Delete_Budget_Group(
  p_api_version                  in number,
  p_init_msg_list                in varchar2 := FND_API.G_FALSE,
  p_commit                       in varchar2 := FND_API.G_FALSE,
  p_validation_level             in number :=  FND_API.G_VALID_LEVEL_FULL,
  p_return_status                OUT  NOCOPY varchar2,
  p_msg_count                    OUT  NOCOPY number,
  p_msg_data                     OUT  NOCOPY varchar2,
  p_budget_group_id              in number,
  p_delete                       OUT  NOCOPY varchar2)
AS

BEGIN

    PSB_Budget_Groups_Pvt.DELETE_ROW (
     p_api_version,
     p_init_msg_list,
     p_commit,
     p_validation_level,
     p_return_status,
     p_msg_count,
     p_msg_data,
     p_budget_group_id,
     p_delete) ;

END Delete_Budget_Group;


END PSB_Budget_Group_D_PVT ;

/
