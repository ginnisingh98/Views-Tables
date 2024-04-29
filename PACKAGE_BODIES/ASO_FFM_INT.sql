--------------------------------------------------------
--  DDL for Package Body ASO_FFM_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_FFM_INT" as
/* $Header: asoiffmb.pls 120.1 2005/06/29 12:33:23 appldev ship $ */
-- Start of Comments
-- Package name     : ASO_FFM_INT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'ASO_FFM_INT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asoiffmb.pls';

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
    X_Msg_Data                  OUT NOCOPY /* file.sql.39 change */  	VARCHAR2)
IS
    l_api_name                CONSTANT VARCHAR2(30) := 'Submit_FFM_Request';
    l_api_version_number      CONSTANT NUMBER   := 1.0;

    l_bind_var_tbl		JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
    l_bind_val_tbl		JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
    l_bind_var_type_tbl		JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
    l_index			NUMBER;
    l_content_xml		VARCHAR2(2000) := '';
    l_tmp_content_xml		VARCHAR2(2000);
BEGIN
    SAVEPOINT Submit_FFM_Request_INT;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                       	             p_api_version_number,
                                     l_api_name,
                                     G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    JTF_FM_REQUEST_GRP.Start_Request(
		p_api_version		=> 1.0,
		p_init_msg_list		=> FND_API.G_FALSE,
		p_commit		=> FND_API.G_FALSE,
		X_Return_Status         => x_Return_Status,
		X_Msg_Count             => x_Msg_Count,
		X_Msg_Data              => x_Msg_Data,
		X_request_id		=> x_request_id);

    IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    FOR i IN 1..p_ffm_content_tbl.count LOOP
	l_bind_var_tbl := JTF_FM_REQUEST_GRP.L_VARCHAR_TBL;
	l_bind_val_tbl := JTF_FM_REQUEST_GRP.L_VARCHAR_TBL;
	l_bind_var_type_tbl := JTF_FM_REQUEST_GRP.L_VARCHAR_TBL;
	l_index := 1;
	FOR j IN 1..p_bind_tbl.count LOOP
	    IF p_bind_tbl(j).content_index = i THEN
		l_bind_var_tbl(l_index) := p_bind_tbl(j).bind_var;
		l_bind_val_tbl(l_index) := p_bind_tbl(j).bind_val;
		l_bind_var_type_tbl(l_index) := p_bind_tbl(j).bind_var_type;
		l_index := l_index+1;
	    END IF;
	END LOOP;
	JTF_FM_REQUEST_GRP.Get_Content_XML(
		p_api_version		=> 1.0,
		p_init_msg_list		=> FND_API.G_FALSE,
		p_commit		=> FND_API.G_FALSE,
		p_validation_level	=> p_validation_level,
		p_content_id		=> p_ffm_content_tbl(i).content_id,
		p_content_nm		=> p_ffm_content_tbl(i).content_name,
		p_document_type		=> p_ffm_content_tbl(i).document_type,
		p_quantity		=> p_ffm_content_tbl(i).quantity,
		p_media_type		=> p_ffm_content_tbl(i).media_type,
		p_printer		=> p_ffm_content_tbl(i).printer,
		p_email			=> p_ffm_content_tbl(i).email,
		p_fax			=> p_ffm_content_tbl(i).fax,
		p_file_path		=> p_ffm_content_tbl(i).file_path,
		p_user_note		=> p_ffm_content_tbl(i).user_note,
		p_content_type		=> p_ffm_content_tbl(i).content_type,
		p_bind_var		=> l_bind_var_tbl,
		p_bind_val		=> l_bind_val_tbl,
		p_bind_var_type		=> l_bind_var_type_tbl,
		p_request_id		=> x_request_id,
		x_content_xml		=> l_tmp_content_xml,
		X_Return_Status         => x_Return_Status,
		X_Msg_Count             => x_Msg_Count,
		X_Msg_Data              => x_Msg_Data);
	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;
	IF (length(l_content_xml)+length(l_tmp_content_xml)) > 2000 THEN
	    x_return_status := FND_API.G_RET_STS_ERROR;
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
                  FND_MESSAGE.Set_Name('ASO', 'ASO_API_CONTENT_XML_TOO_LONG');
                  FND_MSG_PUB.ADD;
            END IF;
            RAISE FND_API.G_EXC_ERROR;
	END IF;
	l_content_xml := l_content_xml||l_tmp_content_xml;
    END LOOP;
    JTF_FM_REQUEST_GRP.Submit_Request(
		p_api_version		=> 1.0,
		p_init_msg_list		=> FND_API.G_FALSE,
		p_commit		=> FND_API.G_FALSE,
		p_validation_level	=> p_validation_level,
		p_template_id		=> p_ffm_request_rec.template_id,
		p_subject		=> p_ffm_request_rec.subject,
		p_party_id		=> p_ffm_request_rec.party_id,
		p_user_id		=> p_ffm_request_rec.user_id,
		p_priority		=> p_ffm_request_rec.priority,
		p_source_code_id	=> p_ffm_request_rec.source_code_id,
		p_source_code		=> p_ffm_request_rec.source_code,
		p_object_type		=> p_ffm_request_rec.object_type,
		p_object_id		=> p_ffm_request_rec.object_id,
		p_order_id		=> p_ffm_request_rec.order_id,
		p_server_id		=> p_ffm_request_rec.server_id,
		p_queue_response	=> p_ffm_request_rec.queue_response,
		p_content_xml		=> l_content_xml,
		p_request_id		=> x_request_id,
		X_Return_Status         => x_Return_Status,
		X_Msg_Count             => x_Msg_Count,
		X_Msg_Data              => x_Msg_Data);
    IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Standard check for p_commit
    IF FND_API.to_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;




      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_INT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_INT
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_INT
		  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
END Submit_FFM_Request;

End ASO_FFM_INT;

/
