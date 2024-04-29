--------------------------------------------------------
--  DDL for Package Body PSB_COMMITMENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_COMMITMENTS_PVT" AS
/* $Header: PSBVWCLB.pls 120.2 2005/07/13 11:30:35 shtripat ship $ */

  G_PKG_NAME CONSTANT   VARCHAR2(30):= 'PSB_COMMITMENTS_PVT';
  g_dbug      VARCHAR2(2000);

  TYPE TokNameArray IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;

  -- TokValArray contains values for all tokens

  TYPE TokValArray IS TABLE OF VARCHAR2(1000) INDEX BY BINARY_INTEGER;
  -- Number of Message Tokens

  no_msg_tokens       NUMBER := 0;

  -- Message Token Name

  msg_tok_names       TokNameArray;

  -- Message Token Value

  msg_tok_val         TokValArray;

/*==========================================================================+
 |                           Private Procedures                             |
 +==========================================================================*/
  PROCEDURE message_token
  ( tokname IN  VARCHAR2,
    tokval  IN  VARCHAR2
  );

  PROCEDURE add_message
  ( appname  IN  VARCHAR2,
    msgname  IN  VARCHAR2
  );

/*==========================================================================+
 |                       PROCEDURE Create_Commitment_Line_Items             |
 +==========================================================================*/

PROCEDURE Create_Commitment_Line_Items
( p_api_version       IN   NUMBER,
  p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit            IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_msg_count         OUT  NOCOPY  NUMBER,
  p_msg_data          OUT  NOCOPY  VARCHAR2,
  p_worksheet_id      IN   NUMBER
) IS

  l_api_name          CONSTANT VARCHAR2(30)   := 'Create_Commitment_Line_Items';
  l_api_version       CONSTANT NUMBER         := 1.0;
  l_plsql_block       VARCHAR2(200);
  l_init_msg_list     VARCHAR2(30) := FND_API.G_FALSE;
  l_commit            VARCHAR2(30) := FND_API.G_FALSE;
  l_validation_level  VARCHAR2(30) := FND_API.G_VALID_LEVEL_FULL;
  l_return_status     VARCHAR2(1);
  l_msg_count         NUMBER;
  l_msg_data          VARCHAR2(2000);
  l_set_of_books_id   NUMBER;
  l_cbc_enabled       BOOLEAN;

  CURSOR C_Root_Set_Of_Books IS
  SELECT nvl(pbg.root_set_of_books_id,  pbg.set_of_books_id)
    FROM psb_budget_groups_v pbg,
	 psb_worksheets pw
   WHERE pbg.budget_group_id = pw.budget_group_id
     AND pw.worksheet_id = p_worksheet_id;

BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT     Create_Commit_Line_Items_Pvt;

  -- Standard call to check for call compatibility.

  IF NOT FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.

  IF FND_API.to_Boolean (p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  OPEN C_Root_Set_Of_Books;
  FETCH C_Root_Set_Of_Books INTO l_set_of_books_id;
  CLOSE  C_Root_Set_Of_Books;

  --Determine if CBC is enabled

  l_cbc_enabled := IS_CBC_Enabled(l_set_of_books_id);

  --Dynamic sql call to the IGC package API to determine if CBC is

  IF l_cbc_enabled THEN
  BEGIN

    l_plsql_block :='BEGIN IGC_PSB_Commitments_Pvt.Create_Commitment_Line_Items (:l_api_version, :l_init_msg_list, :l_commit, :l_validation_level, :l_return_status, :l_msg_count, :l_msg_data, :l_worksheet_id); END;';

    EXECUTE IMMEDIATE l_plsql_block USING IN l_api_version, IN l_init_msg_list,
					IN l_commit, IN l_validation_level,
					OUT l_return_status, OUT l_msg_count,
					OUT l_msg_data, IN p_worksheet_id;

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  END;
  END IF;

  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard check of p_commit.

  IF FND_API.to_Boolean (p_commit) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info.

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK to Create_Commit_Line_Items_Pvt;
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK to Create_Commit_Line_Items_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   WHEN OTHERS THEN
     ROLLBACK to Create_Commit_Line_Items_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     END IF;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END Create_Commitment_Line_Items;

/*==========================================================================+
 |                       PROCEDURE Post_Commitment_Worksheet                |
 +==========================================================================*/

PROCEDURE Post_Commitment_Worksheet
( p_api_version       IN   NUMBER,
  p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
  p_commit            IN   VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status     OUT  NOCOPY  VARCHAR2,
  p_msg_count         OUT  NOCOPY  NUMBER,
  p_msg_data          OUT  NOCOPY  VARCHAR2,
  p_worksheet_id      IN   NUMBER
) IS

  l_api_name          CONSTANT VARCHAR2(30)   := 'Post_Commitment_Worksheet';
  l_api_version       CONSTANT NUMBER         := 1.0;
  l_plsql_block       VARCHAR2(200);
  l_init_msg_list     VARCHAR2(30) := FND_API.G_FALSE;
  l_commit            VARCHAR2(30) := FND_API.G_FALSE;
  l_validation_level  VARCHAR2(30) := FND_API.G_VALID_LEVEL_FULL;
  l_return_status     VARCHAR2(1);
  l_msg_count         NUMBER;
  l_msg_data          VARCHAR2(2000);
  l_set_of_books_id   NUMBER;
  l_cbc_enabled       BOOLEAN;

  CURSOR C_Root_Set_Of_Books IS
  SELECT nvl(pbg.root_set_of_books_id,  pbg.set_of_books_id)
    FROM psb_budget_groups_v pbg,
	 psb_worksheets pw
   WHERE pbg.budget_group_id = pw.budget_group_id
     AND pw.worksheet_id = p_worksheet_id;

BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT     Post_Commitment_Worksheet_Pvt;


  -- Standard call to check for call compatibility.

  IF NOT FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.

  IF FND_API.to_Boolean (p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  OPEN C_Root_Set_Of_Books;
  FETCH C_Root_Set_Of_Books INTO l_set_of_books_id;
  CLOSE  C_Root_Set_Of_Books;

  --Determine if CBC is enabled

  l_cbc_enabled := IS_CBC_Enabled(l_set_of_books_id);

  --Dynamic sql call to the IGC package API to determine if CBC is

  IF l_cbc_enabled THEN
  BEGIN

    l_plsql_block := 'BEGIN IGC_PSB_Commitments_Pvt.Post_Commitment_Worksheet (:l_api_version, :l_init_msg_list, :l_commit, :l_validation_level, :l_return_status, :l_msg_count, :l_msg_data, :l_worksheet_id); END;';

    EXECUTE IMMEDIATE l_plsql_block USING IN l_api_version, IN l_init_msg_list,
					  IN l_commit, IN l_validation_level,
					  OUT l_return_status, OUT l_msg_count,
					  OUT l_msg_data, IN p_worksheet_id;

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --

  END;
  END IF;

  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard check of p_commit.

  IF FND_API.to_Boolean (p_commit) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info.

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK to Post_Commitment_Worksheet_Pvt;
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK to Post_Commitment_Worksheet_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   WHEN OTHERS THEN
     ROLLBACK to Post_Commitment_Worksheet_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     END IF;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END Post_Commitment_Worksheet;

/*==========================================================================+
 |                       PROCEDURE Create_Commitment_Revisions              |
 +==========================================================================*/

PROCEDURE Create_Commitment_Revisions
( p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  p_budget_revision_id  IN      NUMBER
) IS

  l_api_name         CONSTANT VARCHAR2(30)   := 'Create_Commitment_Revisions';
  l_api_version      CONSTANT NUMBER         := 1.0;
  l_plsql_block       VARCHAR2(200);
  l_init_msg_list     VARCHAR2(30) := FND_API.G_FALSE;
  l_commit            VARCHAR2(30) := FND_API.G_FALSE;
  l_validation_level  VARCHAR2(30) := FND_API.G_VALID_LEVEL_FULL;
  l_return_status     VARCHAR2(1);
  l_msg_count         NUMBER;
  l_msg_data          VARCHAR2(2000);
  l_set_of_books_id   NUMBER;
  l_cbc_enabled       BOOLEAN;

  CURSOR C_Root_Set_Of_Books IS
  SELECT nvl(pbg.root_set_of_books_id,  pbg.set_of_books_id)
    FROM psb_budget_groups_v pbg,
	 psb_budget_revisions pbr
   WHERE pbg.budget_group_id = pbr.budget_group_id
     AND pbr.budget_revision_id = p_budget_revision_id;

BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT     Create_Revisions_Pvt;


  -- Standard call to check for call compatibility.

  IF not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.

  IF FND_API.to_Boolean (p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  OPEN C_Root_Set_Of_Books;
  FETCH C_Root_Set_Of_Books INTO l_set_of_books_id;
  CLOSE  C_Root_Set_Of_Books;

  --Determine if CBC is enabled

  l_cbc_enabled := IS_CBC_Enabled(l_set_of_books_id);

  --Dynamic sql call to the IGC package API to determine if CBC is
  IF l_cbc_enabled THEN
  BEGIN

    l_plsql_block := 'BEGIN IGC_PSB_Commitments_Pvt.Create_Commitment_Revisions (:l_api_version, :l_init_msg_list, :l_commit, :l_validation_level, :l_return_status, :l_msg_count, :l_msg_data, :l_budget_revision_id); END;';

    EXECUTE IMMEDIATE l_plsql_block USING IN l_api_version, IN l_init_msg_list,
					  IN l_commit, IN l_validation_level,
					  OUT l_return_status, OUT l_msg_count,
					  OUT l_msg_data, IN p_budget_revision_id;

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --
  END;
  END IF;

  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard check of p_commit.

  IF FND_API.to_Boolean (p_commit) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info.

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);


EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK to Create_Revisions_Pvt;
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK to Create_Revisions_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   WHEN OTHERS THEN
     ROLLBACK to Create_Revisions_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     END IF;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);
END Create_Commitment_Revisions;

/*==========================================================================+
 |                       PROCEDURE Post_Commitment_Revisions                |
 +==========================================================================*/

PROCEDURE Post_Commitment_Revisions
( p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  p_budget_revision_id  IN      NUMBER
) IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'Post_Commitment_Revisions';
  l_api_version         CONSTANT NUMBER       := 1.0;
  l_plsql_block       VARCHAR2(200);
  l_init_msg_list     VARCHAR2(30) := FND_API.G_FALSE;
  l_commit            VARCHAR2(30) := FND_API.G_FALSE;
  l_validation_level  VARCHAR2(30) := FND_API.G_VALID_LEVEL_FULL;
  l_return_status     VARCHAR2(1);
  l_msg_count         NUMBER;
  l_msg_data          VARCHAR2(2000);
  l_set_of_books_id   NUMBER;
  l_cbc_enabled       BOOLEAN;

  CURSOR C_Root_Set_Of_Books IS
  SELECT nvl(pbg.root_set_of_books_id,  pbg.set_of_books_id)
    FROM psb_budget_groups_v pbg,
	 psb_budget_revisions pbr
   WHERE pbg.budget_group_id = pbr.budget_group_id
     AND pbr.budget_revision_id = p_budget_revision_id;

BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT     Post_Commitment_Revisions_Pvt;


  -- Standard call to check for call compatibility.

  IF not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.

  IF FND_API.to_Boolean (p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  OPEN C_Root_Set_Of_Books;
  FETCH C_Root_Set_Of_Books INTO l_set_of_books_id;
  CLOSE  C_Root_Set_Of_Books;

  --Determine if CBC is enabled

  l_cbc_enabled := IS_CBC_Enabled(l_set_of_books_id);

  --Dynamic sql call to the IGC package API to determine if CBC is
  IF l_cbc_enabled THEN
  BEGIN

    l_plsql_block := 'BEGIN IGC_PSB_Commitments_Pvt.Post_Commitment_Revisions (:l_api_version, :l_init_msg_list, :l_commit, :l_validation_level, :l_return_status, :l_msg_count, :l_msg_data, :l_budget_revision_id); END;';

    EXECUTE IMMEDIATE l_plsql_block USING IN l_api_version, IN l_init_msg_list,
					  IN l_commit, IN l_validation_level,
					  OUT l_return_status, OUT l_msg_count,
					  OUT l_msg_data, IN p_budget_revision_id;

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  END;
  END IF;

  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard check of p_commit.

  IF FND_API.to_Boolean (p_commit) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info.

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);


EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK to Post_Commitment_Revisions_Pvt;
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK to Post_Commitment_Revisions_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   WHEN OTHERS THEN
     ROLLBACK to Post_Commitment_Revisions_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     END IF;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END Post_Commitment_Revisions;

/*==========================================================================+
 |                       PROCEDURE Commitment_Funds_Check                   |
 +==========================================================================*/

PROCEDURE Commitment_Funds_Check
( p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status       OUT  NOCOPY     VARCHAR2,
  p_msg_count           OUT  NOCOPY     NUMBER,
  p_msg_data            OUT  NOCOPY     VARCHAR2,
  p_budget_revision_id  IN      NUMBER
) IS

  l_api_name            CONSTANT VARCHAR2(30) := 'Commitment_Funds_Check';
  l_api_version         CONSTANT NUMBER       := 1.0;
  l_plsql_block         VARCHAR2(200);
  l_init_msg_list       VARCHAR2(30) := FND_API.G_FALSE;
  l_commit              VARCHAR2(30) := FND_API.G_FALSE;
  l_validation_level    VARCHAR2(30) := FND_API.G_VALID_LEVEL_FULL;
  l_return_status       VARCHAR2(1);
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(2000);
  l_set_of_books_id     NUMBER;
  l_cbc_enabled         BOOLEAN;

  CURSOR C_Root_Set_Of_Books IS
  SELECT nvl(pbg.root_set_of_books_id,  pbg.set_of_books_id)
    FROM psb_budget_groups_v pbg,
	 psb_budget_revisions pbr
   WHERE pbg.budget_group_id = pbr.budget_group_id
     AND pbr.budget_revision_id = p_budget_revision_id;

BEGIN

  -- Standard Start of API savepoint

  SAVEPOINT     Commitment_Funds_Check_Pvt;


  -- Standard call to check for call compatibility.

  IF not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.

  IF FND_API.to_Boolean (p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  OPEN C_Root_Set_Of_Books;
  FETCH C_Root_Set_Of_Books INTO l_set_of_books_id;
  CLOSE  C_Root_Set_Of_Books;

  --Determine if CBC is enabled

  l_cbc_enabled := IS_CBC_Enabled(l_set_of_books_id);

  --Dynamic sql call to the IGC package API to determine if CBC is
  IF l_cbc_enabled THEN
  BEGIN

    l_plsql_block := 'BEGIN IGC_PSB_Commitments_Pvt.Commitment_Funds_Check (:l_api_version, :l_init_msg_list, :l_commit, :l_validation_level, :l_return_status, :l_msg_count, :l_msg_data, :l_budget_revision_id); END;';

    EXECUTE IMMEDIATE l_plsql_block USING IN l_api_version, IN l_init_msg_list,
					  IN l_commit, IN l_validation_level,
					  OUT l_return_status, OUT l_msg_count,
					  OUT l_msg_data, IN p_budget_revision_id;

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --
  END;
  END IF;

  -- Initialize API return status to success

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Standard check of p_commit.

  IF FND_API.to_Boolean (p_commit) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info.

  FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
			     p_data  => p_msg_data);


EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK to Commitment_Funds_Check_Pvt;
     p_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);


   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK to Commitment_Funds_Check_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

   WHEN OTHERS THEN
     ROLLBACK to Commitment_Funds_Check_Pvt;
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
				l_api_name);
     END IF;

     FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
				p_data  => p_msg_data);

END Commitment_Funds_Check;

/*-------------------------------------------------------------------------*/

FUNCTION Is_Cbc_Enabled
( p_set_of_books_id IN NUMBER
) RETURN BOOLEAN
IS
  l_plsql_block        VARCHAR2(100);
  l_cbc_enabled        VARCHAR2(1);

BEGIN

  --Dynamic sql statement to find whether CBC is enabled

  l_plsql_block := 'BEGIN :cbc_enabled := IGC_PSB_COMMITMENTS_PVT.IS_Cbc_Enabled(:sob); END;';
  EXECUTE IMMEDIATE l_plsql_block USING OUT l_cbc_enabled, IN p_set_of_books_id;

  if FND_API.to_Boolean(l_cbc_enabled) then
    return TRUE;
  else
    return FALSE;
  end if;

  EXCEPTION
  WHEN OTHERS THEN
    Add_Message('PSB', 'PSB_CBC_ENABLED_STATUS');
    RETURN FALSE;

END Is_Cbc_Enabled;

/* ----------------------------------------------------------------------- */

-- Add Token and Value to the Message Token array

PROCEDURE message_token(tokname IN VARCHAR2,
			tokval  IN VARCHAR2) IS

BEGIN

  if no_msg_tokens is null then
    no_msg_tokens := 1;
  else
    no_msg_tokens := no_msg_tokens + 1;
  end if;

  msg_tok_names(no_msg_tokens) := tokname;
  msg_tok_val(no_msg_tokens) := tokval;

END message_token;

/* ----------------------------------------------------------------------- */

-- Define a Message Token with a Value and set the Message Name

-- Calls FND_MESSAGE server package to set the Message Stack. This message is
-- retrieved by the calling program.

PROCEDURE add_message(appname IN VARCHAR2,
		      msgname IN VARCHAR2) IS

  i  BINARY_INTEGER;

BEGIN

  if ((appname is not null) and
      (msgname is not null)) then

    FND_MESSAGE.SET_NAME(appname, msgname);

    if no_msg_tokens is not null then
      for i in 1..no_msg_tokens loop
	FND_MESSAGE.SET_TOKEN(msg_tok_names(i), msg_tok_val(i));
      end loop;
    end if;

    FND_MSG_PUB.Add;

  end if;

  -- Clear Message Token stack

  no_msg_tokens := 0;

END add_message;

/* ----------------------------------------------------------------------- */

END PSB_COMMITMENTS_PVT;

/
