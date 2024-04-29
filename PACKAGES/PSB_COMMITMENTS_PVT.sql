--------------------------------------------------------
--  DDL for Package PSB_COMMITMENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSB_COMMITMENTS_PVT" AUTHID CURRENT_USER AS
/* $Header: PSBVWCLS.pls 120.2 2005/07/13 11:30:41 shtripat ship $ */

/* ----------------------------------------------------------------------- */

  --    API name        : Create_Commitment_Line_Items
  --    Pre-reqs        : FND_API, FND_MESSAGE
  --                    .
  --    Version : Current version       1.0
  --              Initial version       1.0
  --              Created 01/26/2000 by Shweta Jain
  --
  --    Create Line Items from the Commitment Budgetary Control system for a
  --    specific worksheet during the budget preparation process. This process
  --    should extract account balances from Commitment Budgetary Control and
  --    create them for a specific worksheet in PSB. Input parameters include
  --    p_worksheet_id which identifies the budget preparation worksheet
  --    header in PSB

PROCEDURE Create_Commitment_Line_Items
( p_api_version       IN   NUMBER,
  p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit            IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_msg_count         OUT  NOCOPY  NUMBER,
  p_msg_data          OUT  NOCOPY  VARCHAR2,
  p_worksheet_id      IN   NUMBER
);

/* ----------------------------------------------------------------------- */

  --    API name        : Post_Commitment_Worksheet
  --    Pre-reqs        : FND_API, FND_MESSAGE
  --                    .
  --    Version : Current version       1.0
  --              Initial version       1.0
  --              Created 01/26/2000 by Shweta Jain
  --
  --    Post the worksheet created during the budget preparation process to
  --    the Commitment Budgetary Control system. This process should post the
  --    estimate account balances that were projected in PSB to Commitment
  --    Budgetary Control system. Input parameters include p_worksheet_id which
  --    identifies the budget preparation worksheet header in PSB

PROCEDURE Post_Commitment_Worksheet
( p_api_version       IN   NUMBER,
  p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit            IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_msg_count         OUT  NOCOPY  NUMBER,
  p_msg_data          OUT  NOCOPY  VARCHAR2,
  p_worksheet_id      IN   NUMBER
);

/* ----------------------------------------------------------------------- */

  --    API name        : Create_Commitment_Revisions
  --    Pre-reqs        : FND_API, FND_MESSAGE
  --                    .
  --    Version : Current version       1.0
  --              Initial version       1.0
  --              Created 03/06/2000 by Shweta Jain
  --
  --    Create revisions from the Commitment Budgetary Control system for
  --    mass-entry budget revisions. This process should populate a specific
  --    budget revision in PSB with the commitment account balances, process
  --    parameters and perform a funds check if required. Input parameters
  --    include p_budget_revision_id which identifies the budget revision
  --    header in PSB

PROCEDURE Create_Commitment_Revisions
( p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  p_budget_revision_id  IN      NUMBER
);

/* ----------------------------------------------------------------------- */

  --    API name        : Post_Commitment_Revisions
  --    Pre-reqs        : FND_API, FND_MESSAGE
  --                    .
  --    Version : Current version       1.0
  --              Initial version       1.0
  --              Created 03/06/2000 by Shweta Jain
  --
  --    Post approved budget revisions to the Commitment Budgetary Control
  --    system. This process should update the commitment account balances
  --    with the budget revision changes and perform a funds reservation.
  --    Input parameters include p_budget_revision_id which identifies
  --    the budget revision header in PSB

PROCEDURE Post_Commitment_Revisions
( p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  p_budget_revision_id  IN      NUMBER
);

/* ----------------------------------------------------------------------- */

  --    API name        : Commitment_Funds_Check
  --    Pre-reqs        : FND_API, FND_MESSAGE
  --                    .
  --    Version : Current version       1.0
  --              Initial version       1.0
  --
  --    Check Funds Availability for a budget revision from the Commitment
  --    Budgetary Control system. Input parameters include p_budget_revision_id
  --    which identifies the budget revision header in PSB

PROCEDURE Commitment_Funds_Check
( p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  p_budget_revision_id  IN      NUMBER
);

/* ----------------------------------------------------------------------- */

/* ----------------------------------------------------------------------- */

  --    API name        : Commitment_Funds_Check
  --    Pre-reqs        : FND_API, FND_MESSAGE
  --                    .
  --    Version : Current version       1.0
  --              Initial version       1.0
  --    Created 06/29/2000 by Shweta Jain
  --    Function returns value based on CC setup for CBC

FUNCTION Is_Cbc_Enabled
( p_set_of_books_id IN NUMBER
) RETURN BOOLEAN;

END PSB_COMMITMENTS_PVT;

 

/
