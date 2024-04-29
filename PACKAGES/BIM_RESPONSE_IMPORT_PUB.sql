--------------------------------------------------------
--  DDL for Package BIM_RESPONSE_IMPORT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIM_RESPONSE_IMPORT_PUB" AUTHID CURRENT_USER AS
/* $Header: bimpmris.pls 120.1 2005/06/14 15:29:33 appldev  $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          BIM_Response_IMPORT_PUB
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================

-- Default number of records fetch per call


TYPE response_hdr_rec_type IS RECORD
(
    source_code               Varchar2(100),
    response_country          Varchar2(30),
    response_create_date      Date,
    response_source           Varchar2(30),
    landing_pad_hits          Number,
    survey_completed          Number
);


TYPE response_grade_rec IS RECORD
(   response_grade VARCHAR2(30),
    response_grade_count NUMBER
);

TYPE response_grade_table_type IS TABLE OF response_grade_rec INDEX BY BINARY_INTEGER;

TYPE response_invalid_rec_type IS RECORD
(   invalid_reason    VARCHAR2(30),
    invalid_responses        NUMBER
);
TYPE response_invalid_table_type IS TABLE OF response_invalid_rec_type INDEX BY BINARY_INTEGER;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Import_Responses
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number        IN   NUMBER     Optional Default  := 1.0
--       p_init_msg_list             IN   VARCHAR2   Optional  Default := FND_API_G_FALSE
--       p_commit                    IN   VARCHAR2   Optional  Default := FND_API.G_FALSE
--       p_validation_level          IN   NUMBER     Optional  Default := FND_API.G_VALID_LEVEL_FULL
--       p_interface_header_id       IN   NUMBER
--       p_commit                    IN   VARCHAR2   Optional  Default := FND_API.G_FALSE
--       p_validation_level          IN   NUMBER     Optional  Default := FND_API.G_VALID_LEVEL_FULL
--       p_interface_header_id       IN   NUMBER
--       p_response_hdr_rec          IN   response_hdr_rec_type,
--       p_response_grade_table      IN   response_grade_table_type,
--       p_response_invalid_table    IN   response_invalid_table_type,



--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2

--   End of Comments
--   ==============================================================================
--

PROCEDURE IMPORT_RESPONSES(
    p_api_version_number                 IN    NUMBER       :=    1.0,
    p_init_msg_list                      IN    VARCHAR2     :=    FND_API.G_FALSE,
    p_commit                             IN    VARCHAR2     := FND_API.G_FALSE,
    p_validation_level                   IN    NUMBER       :=  FND_API.G_VALID_LEVEL_FULL,
    p_response_hdr_rec                   IN    response_hdr_rec_type,
    p_response_grade_table               IN    response_grade_table_type,
    p_response_invalid_table             IN    response_invalid_table_type,
    x_return_status                      OUT   NOCOPY VARCHAR2,
    x_msg_count                          OUT   NOCOPY NUMBER,
    x_msg_data                           OUT   NOCOPY VARCHAR2);


END BIM_Response_IMPORT_PUB;

 

/
