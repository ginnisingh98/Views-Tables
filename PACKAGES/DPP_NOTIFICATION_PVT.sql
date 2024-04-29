--------------------------------------------------------
--  DDL for Package DPP_NOTIFICATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."DPP_NOTIFICATION_PVT" AUTHID CURRENT_USER AS
/* $Header: dppvnots.pls 120.8 2008/04/10 07:10:01 sdasan noship $ */

TYPE message_tokens_rec_type IS RECORD
(
message_token_name  VARCHAR2(240),
message_token_value  VARCHAR2(4000)
);
TYPE message_tokens_tbl_type IS TABLE OF message_tokens_rec_type INDEX BY BINARY_INTEGER;


---------------------------------------------------------------------
-- PROCEDURE
--    Create_FormattedOutput
--
-- PURPOSE
--    Create Formatted Output
--
-- PARAMETERS
--
-- NOTES
--    1.
--    2.
----------------------------------------------------------------------

PROCEDURE Create_FormattedOutput
     (p_api_version          IN NUMBER,
      p_init_msg_list        IN VARCHAR2 := FND_API.G_FALSE,
      p_commit               IN VARCHAR2 := FND_API.G_FALSE,
      p_validation_level     IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status        OUT NOCOPY VARCHAR2,
      x_msg_count            OUT NOCOPY NUMBER,
      x_msg_data             OUT NOCOPY VARCHAR2,
      p_execution_detail_id  IN NUMBER,
      p_user_id              IN NUMBER,
      p_process_code         IN VARCHAR2,
      p_input_xml            IN CLOB,
      p_notif_language       IN VARCHAR2,
      p_notif_territory      IN VARCHAR2,
      x_request_id           OUT NOCOPY NUMBER);

---------------------------------------------------------------------
-- PROCEDURE
--    Select_Message
--
-- PURPOSE
--    Select Message
--
-- PARAMETERS
--
-- NOTES
--    1.
--    2.
----------------------------------------------------------------------

PROCEDURE Select_Message_Text
     (x_return_status           OUT NOCOPY VARCHAR2,
      x_msg_count               OUT NOCOPY NUMBER,
      x_msg_data                OUT NOCOPY VARCHAR2,
      p_message_name            IN VARCHAR2,
      p_application_short_name  IN VARCHAR2,
      p_language_code           IN VARCHAR2,
      p_message_token           IN MESSAGE_TOKENS_TBL_TYPE,
      x_message_type            OUT NOCOPY VARCHAR2,
      x_message_category        OUT NOCOPY VARCHAR2,
      x_message_text            OUT NOCOPY VARCHAR2,
      x_message_severity        OUT NOCOPY VARCHAR2);

---------------------------------------------------------------------
-- PROCEDURE
--    Get_FormattedOutput
--
-- PURPOSE
--    Get Formatted Output
--
-- PARAMETERS
--
-- NOTES
--    1.
--    2.
----------------------------------------------------------------------

PROCEDURE Get_FormattedOutput(
      p_api_version          IN NUMBER,
      p_init_msg_list        IN VARCHAR2 := FND_API.G_FALSE,
      p_commit               IN VARCHAR2 := FND_API.G_FALSE,
      p_validation_level     IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status        OUT NOCOPY VARCHAR2,
      x_msg_count            OUT NOCOPY NUMBER,
      x_msg_data             OUT NOCOPY VARCHAR2,
      p_execution_detail_id  IN NUMBER,
      x_output_type          OUT NOCOPY VARCHAR2,
      x_formatted_output     OUT NOCOPY BLOB);

END DPP_NOTIFICATION_PVT;

/
