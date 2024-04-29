--------------------------------------------------------
--  DDL for Package CS_COUNTERS_EXT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_COUNTERS_EXT_PVT" AUTHID CURRENT_USER AS
/* $Header: csxvctes.pls 120.1 2005/07/25 14:03:12 appldev ship $ */

-- ---------------------------------------------------------
-- Declare Data Types
-- ---------------------------------------------------------
TYPE DFF_Rec_Type IS RECORD
(
	context				VARCHAR2(30)	:= FND_API.G_MISS_CHAR,
	attribute1			VARCHAR2(150)	:= FND_API.G_MISS_CHAR,
	attribute2			VARCHAR2(150)	:= FND_API.G_MISS_CHAR,
	attribute3			VARCHAR2(150)	:= FND_API.G_MISS_CHAR,
	attribute4			VARCHAR2(150)	:= FND_API.G_MISS_CHAR,
	attribute5			VARCHAR2(150)	:= FND_API.G_MISS_CHAR,
	attribute6			VARCHAR2(150)	:= FND_API.G_MISS_CHAR,
	attribute7			VARCHAR2(150)	:= FND_API.G_MISS_CHAR,
	attribute8			VARCHAR2(150)	:= FND_API.G_MISS_CHAR,
	attribute9			VARCHAR2(150)	:= FND_API.G_MISS_CHAR,
	attribute10			VARCHAR2(150)	:= FND_API.G_MISS_CHAR,
	attribute11			VARCHAR2(150)	:= FND_API.G_MISS_CHAR,
	attribute12			VARCHAR2(150)	:= FND_API.G_MISS_CHAR,
	attribute13			VARCHAR2(150)	:= FND_API.G_MISS_CHAR,
	attribute14			VARCHAR2(150)	:= FND_API.G_MISS_CHAR,
	attribute15			VARCHAR2(150)	:= FND_API.G_MISS_CHAR
);

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  VALIDATE_FORMULA_CTR
--   Type    :  Private
--   Pre-Req :  None
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_counter_id              IN   NUMBER     Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--       x_valid_flag              OUT  VARCHAR2  Returns 'Y' or 'N'
--
--   Version : Current version 1.0
--   Description :
--      This API is used to check if counter formula is valid and has all the bind variable available.
--      This API tries to compute formula value with default value 100 for each bind variable
--   End of Comments
--
PROCEDURE VALIDATE_FORMULA_CTR
(
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_validation_level	IN	VARCHAR2	DEFAULT FND_API.G_VALID_LEVEL_FULL,
	x_return_status		OUT	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_counter_id		IN	NUMBER,
	x_valid_flag		OUT     NOCOPY VARCHAR2
);

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  VALIDATE_GRPOP_CTR
--   Type    :  Private
--   Pre-Req :  None
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_counter_id              IN   NUMBER     Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--       x_valid_flag              OUT  VARCHAR2  Returns 'Y' or 'N'
--
--   Version : Current version 1.0
--   Description :
--      This API is used to check if group operation counter is valid and filters have correct syntex.
--      This API tries to compute group operation counter with dummy values if it successfully computes the
--      value then returns valid = 'Y' else returns 'N'.
--   End of Comments
--
PROCEDURE VALIDATE_GRPOP_CTR
(
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_commit			IN	VARCHAR2	DEFAULT FND_API.G_FALSE,
	p_validation_level	IN	VARCHAR2	DEFAULT FND_API.G_VALID_LEVEL_FULL,
	x_return_status		OUT	NOCOPY VARCHAR2,
	x_msg_count		OUT	NOCOPY NUMBER,
	x_msg_data		OUT	NOCOPY VARCHAR2,
	p_counter_id		IN	NUMBER,
	x_valid_flag		OUT     NOCOPY VARCHAR2
);

PROCEDURE Check_Reqd_Param
(
	p_var1          IN      NUMBER,
	p_param_name    IN      VARCHAR2,
	p_api_name      IN      VARCHAR2
);


PROCEDURE Check_Reqd_Param
(
	p_var1          IN      VARCHAR2,
	p_param_name    IN      VARCHAR2,
	p_api_name      IN      VARCHAR2
);


PROCEDURE Check_Reqd_Param
(
	p_var1          IN      DATE,
	p_param_name    IN      VARCHAR2,
	p_api_name      IN      VARCHAR2
);

FUNCTION Is_StartEndDate_Valid
(
	p_st_dt                 IN      DATE,
	p_end_dt                        IN      DATE,
	p_stack_err_msg IN      BOOLEAN DEFAULT TRUE
) RETURN BOOLEAN;

FUNCTION Is_Flag_YorNorNull
(
	p_flag                  IN      VARCHAR2,
	p_stack_err_msg IN      BOOLEAN DEFAULT TRUE
) RETURN BOOLEAN;

PROCEDURE Is_DescFlex_Valid
(
	p_api_name                      IN      VARCHAR2,
	p_appl_short_name               IN      VARCHAR2       := 'CS',
	p_desc_flex_name                IN      VARCHAR2,
	p_seg_partial_name              IN      VARCHAR2,
	p_num_of_attributes             IN      NUMBER,
	p_seg_values                    IN      DFF_Rec_Type,
	p_stack_err_msg         IN      BOOLEAN := TRUE
);

--  Procedure   : Validate_Desc_Flex
--  Description : Validate descriptive flexfield information. Verify that none
--                of the values are invalid, disabled, expired or not
--                available for the current user because of value security
--                rules.
--  Parameters  :
--  IN          : p_api_name            IN      VARCHAR2(30)    Required
--                      Name of the calling API (used for messages)
--                p_appl_short_name     IN      VARCHAR2(30)    Optional
--                      Application short name of the descriptive flexfield
--                p_desc_flex_name      IN      VARCHAR2(30)    Required
--                      Name of the descriptive flexfield
--                p_column_name1-15     IN      VARCHAR2(30)    Required
--                      Names of the 15 descriptive flexfield columns
--                p_column_value1-15    IN      VARCHAR2(150)   Required
--                      Values of the 15 descriptive flexfield segments
--                p_context_value       IN      VARCHAR2(30)    Required
--                      Value of the descriptive flexfield structure defining
--                      column
--                p_resp_appl_id        IN      NUMBER          Optional
--                      Application identifier
--                p_resp_id             IN      NUMBER          Optional
--                      Responsibility identifier
--  OUT         : x_return_status       OUT     VARCHAR2(1)
--                      FND_API.G_RET_STS_SUCCESS       => values are valid
--                      FND_API.G_RET_STS_ERROR         => values are invalid
------------------------------------------------------------------------------

PROCEDURE Validate_Desc_Flex
  ( p_api_name          IN      VARCHAR2,
    p_appl_short_name   IN      VARCHAR2 DEFAULT 'CS',
    p_desc_flex_name    IN      VARCHAR2,
    p_column_name1      IN      VARCHAR2,
    p_column_name2      IN      VARCHAR2,
    p_column_name3      IN      VARCHAR2,
    p_column_name4      IN      VARCHAR2,
    p_column_name5      IN      VARCHAR2,
    p_column_name6      IN      VARCHAR2,
    p_column_name7      IN      VARCHAR2,
    p_column_name8      IN      VARCHAR2,
    p_column_name9      IN      VARCHAR2,
    p_column_name10     IN      VARCHAR2,
    p_column_name11     IN      VARCHAR2,
    p_column_name12     IN      VARCHAR2,
    p_column_name13     IN      VARCHAR2,
    p_column_name14     IN      VARCHAR2,
    p_column_name15     IN      VARCHAR2,
    p_column_value1     IN      VARCHAR2,
    p_column_value2     IN      VARCHAR2,
    p_column_value3     IN      VARCHAR2,
    p_column_value4     IN      VARCHAR2,
    p_column_value5     IN      VARCHAR2,
    p_column_value6     IN      VARCHAR2,
    p_column_value7     IN      VARCHAR2,
    p_column_value8     IN      VARCHAR2,
    p_column_value9     IN      VARCHAR2,
    p_column_value10    IN      VARCHAR2,
    p_column_value11    IN      VARCHAR2,
    p_column_value12    IN      VARCHAR2,
    p_column_value13    IN      VARCHAR2,
    p_column_value14    IN      VARCHAR2,
    p_column_value15    IN      VARCHAR2,
    p_context_value     IN      VARCHAR2,
    p_resp_appl_id      IN      NUMBER   := NULL,
    p_resp_id           IN      NUMBER   := NULL,
    x_return_status     OUT NOCOPY  VARCHAR2 );

END CS_COUNTERS_EXT_PVT;

 

/
