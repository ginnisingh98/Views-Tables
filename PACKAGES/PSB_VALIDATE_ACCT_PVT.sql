--------------------------------------------------------
--  DDL for Package PSB_VALIDATE_ACCT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_VALIDATE_ACCT_PVT" AUTHID CURRENT_USER AS
/* $Header: PSBVVACS.pls 120.2 2005/07/13 11:30:24 shtripat ship $ */

/* ----------------------------------------------------------------------- */

  --    API name        : Validate_Code_Combination
  --    Type            : Private <Implementation>
  --    Pre-reqs        : FND_API, FND_MESSAGE
  --    Parameters      :
  --    IN              : p_api_version            IN   NUMBER   Required
  --                      p_validation_level       IN   NUMBER   Optional
  --                             Default = FND_API.G_VALID_LEVEL_NONE
  --                      p_budget_group_id        IN   NUMBER   Required
  --                      p_concatenated_segments  IN   VARCHAR2 Required
  --                      p_budget_group_id        IN   NUMBER   Required
  --                      p_startdate_pp           IN   DATE     Required
  --                      p_enddate_cy             IN   DATE     Required
  --                      p_set_of_books_id        IN   NUMBER   Required
  --                      p_flex_code              IN   NUMBER   Required
  --                      p_concatenated_segments  IN   VARCHAR2 Required
  --    OUT  NOCOPY             : p_return_status          OUT  NOCOPY  VARCHAR2(1)
  --    OUT  NOCOPY             : p_budget_group_id        OUT  NOCOPY  NUMBER
  --    OUT  NOCOPY             : p_out_ccid               OUT  NOCOPY  NUMBER
  --
  --    Version : Current version       1.0
  --              Initial version       1.0
  --              Created 08/28/1997 by L Sekar
  --
  --    Notes           : Validates code combination or ccid for a given budget group
  --                      If valid new cc, creates records in Budget Accounts table
  --                      for the account set that belong the budget group

PROCEDURE Validate_Account
(
  p_api_version                 IN      NUMBER,
  p_init_msg_list               IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                      IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level            IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status              OUT  NOCOPY      VARCHAR2,
  p_msg_count                  OUT  NOCOPY      NUMBER,
  p_msg_data                   OUT  NOCOPY      VARCHAR2,
  --
  p_parent_budget_group_id      IN      NUMBER,
  p_startdate_pp                IN      DATE,
  p_enddate_cy                  IN      DATE,
  p_set_of_books_id             IN      NUMBER,
  p_flex_code                   IN      NUMBER,
  p_create_budget_account       IN      VARCHAR2 := FND_API.G_FALSE,
  p_concatenated_segments       IN      VARCHAR2 := FND_API.G_MISS_CHAR,
  p_worksheet_id                IN      NUMBER := FND_API.G_MISS_NUM,
  p_in_ccid                     IN      NUMBER := FND_API.G_MISS_NUM,
  p_out_ccid                    OUT  NOCOPY     NUMBER,
  p_budget_group_id             OUT  NOCOPY     NUMBER
);

END PSB_VALIDATE_ACCT_PVT;

 

/
