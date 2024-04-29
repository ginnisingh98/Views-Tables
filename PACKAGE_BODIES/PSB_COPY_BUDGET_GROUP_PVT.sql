--------------------------------------------------------
--  DDL for Package Body PSB_COPY_BUDGET_GROUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_COPY_BUDGET_GROUP_PVT" AS
/* $Header: PSBWBGCB.pls 120.2 2005/07/13 11:32:02 shtripat ship $ */


  PROCEDURE Copy_Budget_Group
  ( p_api_version          IN   NUMBER,
    p_init_msg_list        IN   VARCHAR2 := FND_API.G_FALSE,
    p_commit               IN   VARCHAR2 := FND_API.G_FALSE,
    p_validation_level     IN   NUMBER  :=  FND_API.G_VALID_LEVEL_FULL,
    p_src_budget_group_id  IN   NUMBER,
    p_curr_budget_group_id IN   NUMBER,
    p_return_status        OUT  NOCOPY  VARCHAR2,
    p_msg_count            OUT  NOCOPY  NUMBER,
    p_msg_data             OUT  NOCOPY  VARCHAR2
  ) AS

  BEGIN

    PSB_Budget_Groups_PVT.Copy_Budget_Group
    (p_api_version,
     p_init_msg_list,
     p_commit,
     p_validation_level,
     p_src_budget_group_id,
     p_curr_budget_group_id,
     p_return_status,
     p_msg_count,
     p_msg_data
    );

  END;

END PSB_COPY_BUDGET_GROUP_PVT ;

/
