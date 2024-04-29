--------------------------------------------------------
--  DDL for Package AST_SEARCH_RESULT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AST_SEARCH_RESULT_PVT" AUTHID CURRENT_USER AS
/* $Header: astlsgns.pls 115.3 2002/02/06 11:20:25 pkm ship      $ */
-- Start of Comments - astlsgns.pls
-- Package name     : AST_SEARCH_RESULT_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name:SEARCH_RESULT_REC_TYPE
--   -------------------------------------------------------
--   Parameters:
--
--    Required:
--    Defaults:
--
--   End of Comments

TYPE SEARCH_RESULT_REC_TYPE IS RECORD
(
       version_number             NUMBER := FND_API.G_MISS_NUM,
       created_by                 NUMBER := FND_API.G_MISS_NUM,
       creation_date              DATE := FND_API.G_MISS_DATE,
       last_updated_by            NUMBER := FND_API.G_MISS_NUM,
       last_update_date           DATE := FND_API.G_MISS_DATE,
       last_update_login          NUMBER := FND_API.G_MISS_NUM,
       search_type                VARCHAR2(30) := FND_API.G_MISS_CHAR,
       primary_id                 NUMBER := FND_API.G_MISS_NUM,
       secondary_id               NUMBER := FND_API.G_MISS_NUM
);

G_MISS_SEARCH_RESULT_REC          SEARCH_RESULT_REC_TYPE;
TYPE  SEARCH_RESULT_TBL_TYPE      IS TABLE OF SEARCH_RESULT_REC_TYPE
                                    INDEX BY BINARY_INTEGER;
G_MISS_SEARCH_RESULT_TBL          SEARCH_RESULT_TBL_TYPE;
GLB_SEARCH_RESULT_TBL             SEARCH_RESULT_TBL_TYPE;
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_search_result
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 2.0
--
--   End of Comments
--
FUNCTION GET_SEARCH_RESULT_REC
RETURN AST_SEARCH_RESULT_PVT.SEARCH_RESULT_REC_TYPE;

PROCEDURE CREATE_SEARCH_RESULT(
    P_Api_Version_Number       IN   NUMBER,
    P_Init_Msg_List            IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                   IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level         IN   NUMBER
                               := FND_API.G_VALID_LEVEL_FULL,
    P_Search_Result_Rec        IN   SEARCH_RESULT_REC_TYPE
                               := G_MISS_search_result_REC,
    X_Return_Status            OUT  VARCHAR2,
    X_Msg_Count                OUT  NUMBER,
    X_Msg_Data                 OUT  VARCHAR2
    );

PROCEDURE GET_SEARCH_RESULT(
    P_Api_Version_Number       IN   NUMBER,
    P_Init_Msg_List            IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                   IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level         IN   NUMBER
                               := FND_API.G_VALID_LEVEL_FULL,
    p_count                    IN   NUMBER,
    x_Search_Result_Rec        OUT   SEARCH_RESULT_REC_TYPE,
    X_Return_Status            OUT  VARCHAR2,
    X_Msg_Count                OUT  NUMBER,
    X_Msg_Data                 OUT  VARCHAR2
    );

PROCEDURE DELETE_SEARCH_RESULT(
    P_Api_Version_Number       IN   NUMBER,
    P_Init_Msg_List            IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                   IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level         IN   NUMBER
                               := FND_API.G_VALID_LEVEL_FULL,
    X_Return_Status            OUT  VARCHAR2,
    X_Msg_Count                OUT  NUMBER,
    X_Msg_Data                 OUT  VARCHAR2
    );

TYPE party_id_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE party_contact_id_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE opportunity_id_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE sales_lead_id_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE event_id_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE campaign_id_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE quote_id_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE collateral_id_tbl IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

glb_party_id_tbl          party_id_tbl;
glb_party_contact_id_tbl  party_contact_id_tbl;
glb_opportunity_id_tbl    opportunity_id_tbl;
glb_sales_lead_tbl        sales_lead_id_tbl;
glb_event_id_tbl          event_id_tbl;
glb_campaign_id_tbl       campaign_id_tbl;
glb_quote_id_tbl          quote_id_tbl;
glb_collateral_id_tbl     collateral_id_tbl;

PROCEDURE add_party_id(
  p_api_version         IN NUMBER := 1.0,
  p_init_msg_list       IN VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT VARCHAR2,
  x_msg_count           OUT NUMBER,
  x_msg_data            OUT VARCHAR2,
  p_search_type         IN VARCHAR2,
  p_party_id_tbl        IN party_id_tbl,
  x_glb_count           OUT NUMBER
);

PROCEDURE get_party_id(
  p_api_version          IN NUMBER := 1.0,
  p_init_msg_list        IN VARCHAR2 := FND_API.G_FALSE,
  p_commit               IN VARCHAR2 := FND_API.G_FALSE,
  p_validation_level     IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status        OUT VARCHAR2,
  x_msg_count            OUT NUMBER,
  x_msg_data             OUT VARCHAR2,
  p_search_type          IN VARCHAR2,
  x_party_id_tbl         OUT party_id_tbl,
  x_glb_count            OUT NUMBER
);

End AST_search_result_PVT;

 

/
