--------------------------------------------------------
--  DDL for Package PSB_BUDGET_ACCOUNT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_BUDGET_ACCOUNT_PVT" AUTHID CURRENT_USER AS
/* $Header: PSBVMBAS.pls 120.3 2004/08/16 11:31:59 viraghun ship $ */

PROCEDURE Populate_Budget_Accounts
(
  p_api_version               IN       NUMBER ,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE ,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  p_return_status             OUT  NOCOPY      VARCHAR2 ,
  p_msg_count                 OUT  NOCOPY      NUMBER   ,
  p_msg_data                  OUT  NOCOPY      VARCHAR2 ,
  --
  p_set_of_books_id           IN       NUMBER   := FND_API.G_MISS_NUM ,
  p_account_set_id            IN       NUMBER   := FND_API.G_MISS_NUM ,
  -- bug no 3573740
  p_full_maintainence_flag	  IN	   VARCHAR2  := 'N'
);


PROCEDURE Populate_Budget_Accounts_CP
(
  errbuf                      OUT  NOCOPY      VARCHAR2,
  retcode                     OUT  NOCOPY      VARCHAR2,
  --
  p_set_of_books_id           IN       NUMBER   := FND_API.G_MISS_NUM ,
  p_account_set_id            IN       NUMBER   := FND_API.G_MISS_NUM ,
  -- bug no 3573740
  p_full_maintainence_flag	  IN	   VARCHAR2 := 'N'
);

/* Bug 3247574 Start */

PROCEDURE Validate_Worksheet_CP
(
  errbuf                      OUT  NOCOPY     VARCHAR2,
  retcode                     OUT  NOCOPY     VARCHAR2,
  p_worksheet_id              IN       NUMBER
);

PROCEDURE Validate_Worksheet
(
  p_api_version               IN       NUMBER ,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE ,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  p_return_status             OUT  NOCOPY      VARCHAR2 ,
  p_msg_count                 OUT  NOCOPY      NUMBER   ,
  p_msg_data                  OUT  NOCOPY      VARCHAR2 ,
  p_worksheet_id              IN       NUMBER           ,
  p_msg_wrt_mode	          IN       VARCHAR2
);

/* Bug 3247574 End */

END PSB_Budget_Account_PVT;

 

/
