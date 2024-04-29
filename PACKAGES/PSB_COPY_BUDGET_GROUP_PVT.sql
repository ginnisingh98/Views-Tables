--------------------------------------------------------
--  DDL for Package PSB_COPY_BUDGET_GROUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_COPY_BUDGET_GROUP_PVT" AUTHID CURRENT_USER AS
/* $Header: PSBWBGCS.pls 120.2 2005/07/13 11:32:07 shtripat ship $ */


PROCEDURE Copy_Budget_Group
( p_api_version          IN     NUMBER ,
  p_init_msg_list        IN     VARCHAR2 := FND_API.G_FALSE,
  p_commit               IN     VARCHAR2 := FND_API.G_FALSE,
  p_validation_level     IN     NUMBER  :=  FND_API.G_VALID_LEVEL_FULL,
  p_src_budget_group_id  IN     NUMBER,
  p_curr_budget_group_id IN     NUMBER,
  p_return_status        OUT  NOCOPY    VARCHAR2,
  p_msg_count            OUT  NOCOPY    NUMBER,
  p_msg_data             OUT  NOCOPY    VARCHAR2
);


END PSB_COPY_BUDGET_GROUP_PVT;

 

/
