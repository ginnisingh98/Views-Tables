--------------------------------------------------------
--  DDL for Package ASO_FFM_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_FFM_INT" AUTHID CURRENT_USER as
/* $Header: asoiffms.pls 120.1 2005/06/29 12:33:26 appldev ship $ */
-- Start of Comments
-- Package name     : ASO_FFM_INT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

--   Record Type:
--	FFM_REQUEST_REC_TYPE
--	FFM_CONTENT_REC_TYPE

-- Priority Levels of the fulfillment requests.
-- Lower number represents higher priority
G_PRIORITY_HIGHEST 		  	CONSTANT    NUMBER := 1;
G_PRIORITY_SPECIALITY_FLAG 	CONSTANT    NUMBER := 6;
G_PRIORITY_REGULAR 			CONSTANT    NUMBER := 7;
G_PRIORITY_BATCH_REQUEST 	CONSTANT    NUMBER := 8;

TYPE FFM_REQUEST_REC_TYPE IS RECORD
(
	template_id		NUMBER := NULL,
	subject			VARCHAR2(250) := FND_API.G_MISS_CHAR,
	party_id		NUMBER,
	user_id			NUMBER,
	priority		NUMBER := G_PRIORITY_REGULAR,
	source_code_id		NUMBER := FND_API.G_MISS_NUM,
	source_code		VARCHAR2(250) := FND_API.G_MISS_CHAR,
	object_type		VARCHAR2(250) := FND_API.G_MISS_CHAR,
	object_id		NUMBER := FND_API.G_MISS_NUM,
	order_id		NUMBER := FND_API.G_MISS_NUM,
	server_id		NUMBER,
	queue_response		VARCHAR2(250) := FND_API.G_FALSE
);


TYPE FFM_CONTENT_REC_TYPE IS RECORD
(
	content_id		NUMBER,
	content_name		VARCHAR2(250),
	document_type		VARCHAR2(250),
	quantity		NUMBER := 1,
	media_type		VARCHAR2(250),
	printer			VARCHAR2(250) := NULL,
	email			VARCHAR2(250) := NULL,
	fax			VARCHAR2(250) := NULL,
	file_path		VARCHAR2(250) := NULL,
	user_note		VARCHAR2(250) := FND_API.G_MISS_CHAR,
	content_type		VARCHAR2(250)
);

TYPE  FFM_Content_Tbl_Type      IS TABLE OF FFM_Content_Rec_Type
                                    INDEX BY BINARY_INTEGER;

TYPE FFM_BIND_REC_TYPE IS RECORD
(
	content_index		NUMBER,
	bind_var		VARCHAR2(1000),
	bind_val		VARCHAR2(1000),
	bind_var_type		VARCHAR2(1000)
);

TYPE FFM_Bind_Tbl_Type IS TABLE OF FFM_BIND_REC_TYPE
				     INDEX BY BINARY_INTEGER;


PROCEDURE Submit_FFM_Request(
    P_Api_Version_Number	IN	NUMBER,
    p_Init_Msg_List		IN	VARCHAR2 := FND_API.G_FALSE,
    p_Commit			IN	VARCHAR2 := FND_API.G_FALSE,
    p_validation_Level		IN	NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_ffm_request_rec		IN	FFM_REQUEST_REC_TYPE,
    p_ffm_content_tbl		IN	FFM_CONTENT_TBL_TYPE,
    p_bind_tbl			IN	FFM_Bind_Tbl_Type,
    X_Request_ID	 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
    X_Return_Status             OUT NOCOPY /* file.sql.39 change */  	VARCHAR2,
    X_Msg_Count                 OUT NOCOPY /* file.sql.39 change */  	NUMBER,
    X_Msg_Data                  OUT NOCOPY /* file.sql.39 change */  	VARCHAR2);

End ASO_FFM_INT;

 

/
