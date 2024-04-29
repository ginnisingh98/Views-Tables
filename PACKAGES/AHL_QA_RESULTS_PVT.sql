--------------------------------------------------------
--  DDL for Package AHL_QA_RESULTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_QA_RESULTS_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVQARS.pls 115.3 2002/12/02 23:42:47 jeli noship $ */

TYPE qa_results_rec_type IS RECORD
(
  CHAR_ID         NUMBER, -- QA_CHARS.char_id
  RESULT_VALUE    VARCHAR2(2000), -- User Entered value
  RESULT_ID       NUMBER -- Future Use ( if IDs need to be submitted )
);

TYPE qa_results_tbl_type IS TABLE OF qa_results_rec_type INDEX BY BINARY_INTEGER;

TYPE occurrence_rec_type IS RECORD
(
  ELEMENT_COUNT   NUMBER,
  OCCURRENCE      NUMBER -- QA_RESULTS.occurrence
);

TYPE occurrence_tbl_type IS TABLE OF occurrence_rec_type INDEX BY BINARY_INTEGER;

TYPE qa_context_rec_type IS RECORD
(
  NAME            VARCHAR2(30), -- Name of the attribute ( ahl_wo_id )
  VALUE           VARCHAR2(2000) -- Value of the attribute (String value )
);

TYPE qa_context_tbl_type IS TABLE OF qa_context_rec_type INDEX BY BINARY_INTEGER;

-- Start of Comments
-- Procedure name              : submit_qa_results
-- Type                        : Private
-- Pre-reqs                    :
-- Function                    :
-- Parameters                  :
--
-- Standard IN  Parameters :
--      p_api_version               NUMBER   Required
--      p_init_msg_list             VARCHAR2 Default  FND_API.G_FALSE
--      p_commit                    VARCHAR2 Default  FND_API.G_FALSE
--      p_validation_level          NUMBER   Default  FND_API.G_VALID_LEVEL_FULL
--      p_default                   VARCHAR2 Default  FND_API.G_TRUE
--      p_module_type               VARCHAR2 Default  NULL
--
-- Standard OUT Parameters :
--      x_return_status             VARCHAR2 Required
--      x_msg_count                 NUMBER   Required
--      x_msg_data                  VARCHAR2 Required
--
-- submit_qa_results IN parameters:
--      p_plan_id            NUMBER              Required
--      p_organization_id    NUMBER              Required
--      p_transaction_no     NUMBER              Required
--      p_specification_id   NUMBER              Default NULL
--      p_results_tbl        qa_results_tbl_type Required
--      p_context_tbl        qa_context_tbl_type Required
--      p_result_commit_flag NUMBER              Default 0
--      p_id_or_value        VARCHAR2            Default 'VALUE'
--
-- submit_qa_results IN OUT parameters:
--      p_x_collection_id    NUMBER
--      p_x_occurrence_tbl   occurrence_tbl_type
--
-- submit_qa_results OUT parameters:
--      None.
--
--
-- Version :
--          Current version        1.0
--
-- End of Comments

PROCEDURE submit_qa_results
(
 p_api_version        IN            NUMBER     := 1.0,
 p_init_msg_list      IN            VARCHAR2   := FND_API.G_TRUE,
 p_commit             IN            VARCHAR2   := FND_API.G_FALSE,
 p_validation_level   IN            NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_default            IN            VARCHAR2   := FND_API.G_FALSE,
 p_module_type        IN            VARCHAR2   := NULL,
 x_return_status      OUT NOCOPY    VARCHAR2,
 x_msg_count          OUT NOCOPY    NUMBER,
 x_msg_data           OUT NOCOPY    VARCHAR2,
 p_plan_id            IN            NUMBER,
 p_organization_id    IN            NUMBER,
 p_transaction_no     IN            NUMBER,
 p_specification_id   IN            NUMBER     := NULL,
 p_results_tbl        IN            qa_results_tbl_type,
 p_hidden_results_tbl IN            qa_results_tbl_type,
 p_context_tbl        IN            qa_context_tbl_type,
 p_result_commit_flag IN            NUMBER,
 p_id_or_value        IN            VARCHAR2 := 'VALUE',
 p_x_collection_id    IN OUT NOCOPY NUMBER,
 p_x_occurrence_tbl   IN OUT NOCOPY occurrence_tbl_type
);

PROCEDURE get_char_lov_sql
(
 p_api_version          IN   NUMBER     := 1.0,
 p_init_msg_list        IN   VARCHAR2   := FND_API.G_TRUE,
 p_commit               IN   VARCHAR2   := FND_API.G_FALSE,
 p_validation_level     IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_default              IN   VARCHAR2   := FND_API.G_FALSE,
 p_module_type          IN   VARCHAR2   := NULL,
 x_return_status        OUT NOCOPY VARCHAR2,
 x_msg_count            OUT NOCOPY NUMBER,
 x_msg_data             OUT NOCOPY VARCHAR2,
 p_plan_id              IN   NUMBER,
 p_char_id              IN   NUMBER,
 p_organization_id      IN   NUMBER,
 p_user_id              IN   NUMBER := NULL,
 p_depen1               IN   VARCHAR2 := NULL,
 p_depen2               IN   VARCHAR2 := NULL,
 p_depen3               IN   VARCHAR2 := NULL,
 p_value                IN   VARCHAR2 := NULL,
 x_char_lov_sql         OUT NOCOPY VARCHAR2
);

PROCEDURE get_qa_plan
(
 p_api_version          IN   NUMBER     := 1.0,
 p_init_msg_list        IN   VARCHAR2   := FND_API.G_TRUE,
 p_commit               IN   VARCHAR2   := FND_API.G_FALSE,
 p_validation_level     IN   NUMBER     := FND_API.G_VALID_LEVEL_FULL,
 p_default              IN   VARCHAR2   := FND_API.G_FALSE,
 p_module_type          IN   VARCHAR2   := NULL,
 x_return_status        OUT NOCOPY VARCHAR2,
 x_msg_count            OUT NOCOPY NUMBER,
 x_msg_data             OUT NOCOPY VARCHAR2,
 p_organization_id      IN   NUMBER,
 p_transaction_number   IN   NUMBER,
 p_col_trigger_value    IN   VARCHAR2,
 x_plan_id              OUT NOCOPY NUMBER
);

END AHL_QA_RESULTS_PVT;

 

/
