--------------------------------------------------------
--  DDL for Package Body IEX_SEND_FFM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_SEND_FFM_PVT" as
/* $Header: iexvffmb.pls 120.4 2004/10/28 20:30:24 clchang ship $ */
-- Start of Comments
-- Package name     : IEX_SEND_FFM_PVT
-- Purpose          : Calling Fulfillement
-- NOTE             :
-- History          :
--      03/20/2001 CLCHANG  Created.
-- END of Comments


G_PKG_NAME  CONSTANT VARCHAR2(30):= 'IEX_SEND_FFM_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'iexvffmb.pls';



--   Validation
-- **************************
--PG_DEBUG NUMBER(2) := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));
PG_DEBUG NUMBER ;

PROCEDURE Validate_Media_Type
(
    P_Init_Msg_List              IN   VARCHAR2   ,
    P_Content_Tbl                IN   IEX_SEND_FFM_PVT.CONTENT_TBL_TYPE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
)
IS
    l_api_name                  	   CONSTANT VARCHAR2(30) := 'Validate Media_Type';
    l_Content_tbl                    IEX_SEND_FFM_PVT.CONTENT_TBL_TYPE ;
    l_content_id				   NUMBER;
    l_media_type				   VARCHAR2(30);
    l_email					   VARCHAR2(1000) ;
    l_printer				   VARCHAR2(1000) ;
    l_file_path				   VARCHAR2(1000) ;
    l_fax					   VARCHAR2(1000) ;
    l_msg_count 				   NUMBER ;
    l_msg_data 				   VARCHAR2(1000);
    l_return_status 			   VARCHAR2(1000);
    l_Cnt                              NUMBER;
    errmsg                        VARCHAR2(32767);

BEGIN

    l_content_tbl := p_content_tbl;

      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      iex_dunning_pvt.WriteLog('iexvffmb.pls:Validate Media Type');

      l_Cnt := l_content_tbl.count;
      iex_dunning_pvt.WriteLog('iexvffmb.pls:l_cnt='||l_cnt);
      for i in 1..l_cnt loop
         iex_dunning_pvt.WriteLog('Validate_Media_Type: i:'||i );
         l_media_type := l_content_tbl(i).media_type;
         l_email := l_content_tbl(i).email;
         l_printer := l_content_tbl(i).printer;
         l_file_path := l_content_tbl(i).file_path;
         l_fax := l_content_tbl(i).fax;
         iex_dunning_pvt.WriteLog('Validate_Media_Type: media_type:'||l_media_type );
         iex_dunning_pvt.WriteLog('Validate_Media_Type: email:'||l_email );
         iex_dunning_pvt.WriteLog('Validate_Media_Type: printer:'||l_printer );
         iex_dunning_pvt.WriteLog('Validate_Media_Type: fax:'||l_fax );
         --
         if (l_media_type = 'EMAIL' and l_email is null) OR
            (l_media_type = 'PRINTER' and l_printer is null) OR
            (l_media_type = 'FAX' and l_fax is null) OR
            (l_media_type = 'FILE' and l_file_path is null)
         then
               --dbms_output.put_line('found!');
               iex_dunning_pvt.WriteLog('Validate_Media_Type: no media type');
--               IF PG_DEBUG < 10  THEN
               IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                  IEX_DEBUG_PUB.LogMessage('Validate_Media_Type: ' || 'iexvffmb.pls:missing media_type');
               END IF;
               FND_MESSAGE.Set_Name('IEX', 'API_FAIL_SEND_FFM');
               FND_MESSAGE.Set_Token ('INFO', ' no media_type');
               FND_MSG_PUB.Add;
	       -- Begin - Andre Araujo - 09/30/2004- Remove obsolete logging
               /* IEX_CONC_REQUEST_MSG_PKG.Log_Error(
                        P_Concurrent_Request_ID => FND_GLOBAL.CONC_REQUEST_ID,
                        P_Procedure_name        => 'IEX_SEND_FFM_PVT.VALIDATE_MEDIA_TYPE',
                        P_MESSAGE               => 'NO MEDIA_TYPE'); */
		-- End - Andre Araujo - 09/30/2004- Remove obsolete logging
               raise FND_API.G_EXC_ERROR;
         end if;
      end loop;


      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
               x_return_status := FND_API.G_RET_STS_ERROR;
               FND_MSG_PUB.Count_And_Get
                   (  p_count          =>   x_msg_count,
                      p_data           =>   x_msg_data
                    );
              iex_dunning_pvt.WriteLog('iexvffmb:Validate:Exc Exception');
              errmsg := SQLERRM;
              iex_dunning_pvt.WriteLog('iexvffmb:Validate:error='||errmsg);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
               x_return_status := FND_API.G_RET_STS_ERROR;
               FND_MSG_PUB.Count_And_Get
                   (  p_count          =>   x_msg_count,
                      p_data           =>   x_msg_data
                    );
              iex_dunning_pvt.WriteLog('iexvffmb:Validate:UnExc Exception');
              errmsg := SQLERRM;
              iex_dunning_pvt.WriteLog('iexvffmb:Validate:error='||errmsg);

          WHEN OTHERS THEN
               x_return_status := FND_API.G_RET_STS_ERROR;
               FND_MSG_PUB.Count_And_Get
                   (  p_count          =>   x_msg_count,
                      p_data           =>   x_msg_data
                    );
              iex_dunning_pvt.WriteLog('iexvffmb:Validate:Other Exception');
              errmsg := SQLERRM;
              iex_dunning_pvt.WriteLog('iexvffmb:Validate:error='||errmsg);


END Validate_MEDIA_TYPE;




--   Calling FFM APIs
-- **************************

PROCEDURE Send_FFM(
    P_Api_Version_Number     IN  NUMBER,
    P_Init_Msg_List          IN  VARCHAR2   ,
    P_Commit                 IN  VARCHAR2   ,
    P_Content_NM             IN  VARCHAR2,
    P_User_id                IN  NUMBER,
    P_Server_id              IN  NUMBER,
    P_Party_id               IN  NUMBER,
    P_Subject                IN  VARCHAR2,
    P_Content_tbl            IN  IEX_SEND_FFM_PVT.CONTENT_TBL_TYPE,
    p_bind_var 		     IN  JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE,
    p_bind_var_type 	     IN  JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE,
    p_bind_val 		     IN  JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE,
    --p_bind_cnt_tbl           IN  IEX_SEND_FFM_PVT.BIND_CNT_TBL,
/*
    P_Content_ID             IN  NUMBER,
    P_Media_Type             IN  VARCHAR2,
    P_Request_Type           IN  VARCHAR2,
    P_User_Note              IN  VARCHAR2,
    P_Document_Type          IN  VARCHAR2,
    P_Email                  IN  VARCHAR2,
    P_Printer                IN  VARCHAR2,
    P_File_Path              IN  VARCHAR2,
    P_Fax                    IN  VARCHAR2,
*/
    X_Request_ID             OUT NOCOPY NUMBER,
    X_Return_Status          OUT NOCOPY VARCHAR2,
    X_Msg_Count              OUT NOCOPY NUMBER,
    X_Msg_Data               OUT NOCOPY VARCHAR2
    )
 IS

    l_api_name         	   CONSTANT VARCHAR2(30) := 'IEXVFFMB';
    l_api_version				   NUMBER := 1.0;
    l_commit				   VARCHAR2(5) ;
    --
    l_Content_tbl         IEX_SEND_FFM_PVT.CONTENT_TBL_TYPE ;
    l_content_id				   NUMBER;
    l_media_type				   VARCHAR2(30);
    l_request_type		         VARCHAR2(30);
    l_user_note				   VARCHAR2(1000);
    l_document_type			   VARCHAR2(100);
    l_bind_var 				   JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
    l_bind_var_type 			   JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
    l_bind_val 				   JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
    --l_bind_cnt_tbl                     IEX_SEND_FFM_PVT.BIND_CNT_TBL := p_bind_cnt_tbl;
    --l_bind_cnt                         NUMBER;
    --l_bind_total                       NUMBER;
    l_email					   VARCHAR2(1000) ;
    l_printer				   VARCHAR2(1000) ;
    l_file_path				   VARCHAR2(1000) ;
    l_fax					   VARCHAR2(1000) ;
    --
    l_content_nm				   NUMBER ;
    l_party_id				   NUMBER ;
    l_user_id				   NUMBER ;
    l_server_id				   NUMBER ;
    l_subject				   VARCHAR2(1000) ;
    --
    l_request_id 				   NUMBER ;
    l_msg_count 				   NUMBER ;
    l_msg_data 				   VARCHAR2(1000);
    l_return_status 			   VARCHAR2(1000);
    l_one_content_xml 			   VARCHAR2(1000);
    l_content_xml 			   VARCHAR2(32767);

BEGIN

      -- Standard Start of API savepoint
      SAVEPOINT SEND_FFM_PUB;

      l_content_tbl := p_content_tbl;
    l_content_nm			  := TO_NUMBER(p_content_nm);
    l_party_id				  := p_party_id;
    l_user_id				    := p_user_id;
    l_server_id				  := p_server_id;
    l_subject				    := p_subject;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME )
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


	 -- Debug Message
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LogMessage('iexvffmb.pls:SEND_FFM');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************
	 /*
      IF FND_GLOBAL.User_Id IS NULL
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              AS_UTILITY_PVT.Set_Message(
                  p_msg_level     => FND_MSG_PUB.G_MSG_LVL_ERROR,
                  p_msg_name      => 'UT_CANNOT_GET_PROFILE_VALUE',
                  p_token1        => 'PROFILE',
                  p_token1_value  => 'USER_ID');

          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;
      */

      -- Debug message

      -- Invoke validation procedures
      --- Validate Data
      Validate_Media_Type
      (
 		p_Init_Msg_List => p_init_msg_list,
                p_content_tbl => l_content_tbl,
		x_return_status => l_return_status,
		x_msg_count => l_msg_count,
		x_msg_data => l_msg_data
      );

      IF l_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          -- Begin - Andre Araujo - 09/30/2004- Remove obsolete logging
          /* IEX_CONC_REQUEST_MSG_PKG.Log_Error(
                        P_Concurrent_Request_ID => FND_GLOBAL.CONC_REQUEST_ID,
                        P_Procedure_name        => 'IEX_SEND_FFM_PVT.SEND_FFM',
                        P_MESSAGE               => 'NO MEDIA_TYPE'); */
          -- End - Andre Araujo - 09/30/2004- Remove obsolete logging
--          IF PG_DEBUG < 10  THEN
          IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
             IEX_DEBUG_PUB.LogMessage('iexvffmb.pls:SEND_FFM : NO MEDIA_TYPE');
          END IF;
		x_msg_count := l_msg_count;
		x_msg_data := l_msg_data;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Debug message
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LogMessage('iexvffmb.pls:SEND_FFM: Start Request');
      END IF;

      -- Start the fulfillment request. The output request_id must be passed
      -- to all subsequent calls made for this request.
      JTF_FM_REQUEST_GRP.STart_Request
      (
 		p_api_version => l_api_version,
		x_return_status => l_return_status,
		x_msg_count => l_msg_count,
		x_msg_data => l_msg_data,
		x_request_id => l_request_id
      );

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            --dbms_output.put_line('no request id');
            --FND_MESSAGE.Set_Name('IEX', 'IEX_NO_REQUEST_ID');
            --FND_MSG_PUB.ADD;
            --msg
	    -- Begin - Andre Araujo - 09/30/2004- Remove obsolete logging
            /* IEX_CONC_REQUEST_MSG_PKG.Log_Error(
                        P_Concurrent_Request_ID => FND_GLOBAL.CONC_REQUEST_ID,
                        P_Procedure_name        => 'IEX_SEND_FFM_PVT.VALIDATE_MEDIA_TYPE',
                        P_MESSAGE               => 'ERROR To Start_Request;'); */
	    -- End - Andre Araujo - 09/30/2004- Remove obsolete logging
            x_msg_count := l_msg_count;
            x_msg_data := l_msg_data;
--            IF PG_DEBUG < 10  THEN
            IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
               IEX_DEBUG_PUB.LogMessage('iexvffmb.pls:SEND_FFM: no request id');
            END IF;
            FND_MESSAGE.Set_Name('IEX', 'API_FAIL_SEND_FFM');
            FND_MESSAGE.Set_Token ('INFO', 'not get request_id');
            FND_MSG_PUB.Add;
            RAISE FND_API.G_EXC_ERROR;
      END IF;



--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LogMessage('iexvffmb.pls:SEND_FFM: RequestId='||l_request_id);
      END IF;
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LogMessage('iexvffmb.pls:SEND_FFM: Get XML');
      END IF;

    /*===========================================================
       content_id here is item_id in db
       we need to make sure the item_id has file_id in fnd_lobs
       see the following query condition
       from jtf_amv_items_vl fm,
            jtf_fm_amv_attach_vl fm2,
            fnd_lobs fnd
      where fm.application_id = 695 <our application_id>
        and fm.item_id = fm2.ATTACHMENT_USED_BY_ID
        and fnd.file_id = fm2.file_id
      order by fm.content_type_id, fm.item_id
     ==========================================================*/
    /*===========================================================
      DATA is for Collateral - Content_type_id=10;
      QUERY is for MasterDoc(Cover Letter) - Content_type_id=20;
     ===========================================================*/

      -- This call gets the XML string for the content(Master Document) with
	-- the parameters as defined above;
      -- Only one Content_XML for one Request;

      --l_bind_total := 0; -- total bind_var for this request
      for i in 1..l_content_nm loop

         BEGIN
         l_content_id :=  l_content_tbl(i).content_id;
         l_request_type := l_content_tbl(i).request_type;
         l_media_type := l_content_tbl(i).media_type;
         l_document_type := l_content_tbl(i).document_type;
         --
         l_user_note := l_content_tbl(i).user_note;
         l_email := l_content_tbl(i).email;
         l_printer := l_content_tbl(i).printer;
         l_file_path := l_content_tbl(i).file_path;
         l_fax := l_content_tbl(i).fax;
         --
--         IF PG_DEBUG < 10  THEN
         IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            IEX_DEBUG_PUB.LogMessage('iexvffmb.pls:SEND_FFM: Content_id:'||l_content_id);
         END IF;

         -- support multi bind variables for each content;
         -- 11.5.7 enhancement
         -- l_bind_var := p_bind_var;
         -- so the whole set of p_bind_var will pass to each contect;
         -- suppose ffm engine will choose the matched bind var based on the contect query;
         --dbms_output.put_line('in iexvffmb:'||p_bind_var.count ||';'||p_bind_var(1)||';'||p_bind_Val(1)||';'||p_bind_var_type(1) );
         --
         -- it's for the oldest test;
        /*
         l_bind_cnt := l_bind_cnt_tbl(i);
         dbms_output.put_line(i || ';bind_cnt=' || l_bind_cnt);
         if l_bind_cnt > 0 then
            for j in 1..l_bind_cnt loop
                l_bind_var(j) := p_bind_var(l_bind_total+j);
                l_bind_var_type(j) := p_bind_var_type(l_bind_total+j);
                l_bind_val(j) := p_bind_val(l_bind_total+j);
            end loop;
         end if;
        */
         --
         -- for 11.5.6
         -- only support one bind variable for each content;
        /*
         l_bind_var(1) := p_bind_var(i);
         l_bind_var_type(1) := p_bind_var_type(i);
         l_bind_val(1) := p_bind_val(i);
        */
         --
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               -- it's possible that l_content_nm is wrong!
               --dbms_output.put_line('no data found!');
               --FND_MESSAGE.Set_Name('IEX', 'API_FAIL_SEND_FFM');
               --FND_MSG_PUB.Add;
               -- Begin - Andre Araujo - 09/30/2004- Remove obsolete logging
               /* IEX_CONC_REQUEST_MSG_PKG.Log_Error(
                        P_Concurrent_Request_ID => FND_GLOBAL.CONC_REQUEST_ID,
                        P_Procedure_name        => 'IEX_SEND_FFM_PVT.SEND_FFM',
                        P_MESSAGE               => 'ERROR To GET_CONTENT;NO_DATA_FOUND;'); */
               -- End - Andre Araujo - 09/30/2004- Remove obsolete logging
--               IF PG_DEBUG < 10  THEN
               IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                  IEX_DEBUG_PUB.LogMessage('iexvffmb.pls:SEND_FFM: no data found');
               END IF;
               FND_MESSAGE.Set_Name('IEX', 'API_FAIL_SEND_FFM');
               FND_MESSAGE.Set_Token ('INFO', 'error to get_Content:no_data_found');
               FND_MSG_PUB.Add;
               RAISE FND_API.G_EXC_ERROR;
            WHEN OTHERS THEN
	       -- Begin - Andre Araujo - 09/30/2004- Remove obsolete logging
               /* IEX_CONC_REQUEST_MSG_PKG.Log_Error(
                        P_Concurrent_Request_ID => FND_GLOBAL.CONC_REQUEST_ID,
                        P_Procedure_name        => 'IEX_SEND_FFM_PVT.SEND_FFM',
                        P_MESSAGE               => 'ERROR To GET_CONTENT;'); */
               -- End - Andre Araujo - 09/30/2004- Remove obsolete logging
--               IF PG_DEBUG < 10  THEN
               IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                  IEX_DEBUG_PUB.LogMessage('iexvffmb.pls:SEND_FFM:error to get_content');
               END IF;
               FND_MESSAGE.Set_Name('IEX', 'API_FAIL_SEND_FFM');
               FND_MESSAGE.Set_Token ('INFO', 'error to get_content');
               FND_MSG_PUB.Add;
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END;

--         IF PG_DEBUG < 10  THEN
         IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            IEX_DEBUG_PUB.LogMessage('iexvffmb.pls:SEND_FFM:Get Content XML');
         END IF;

    	   JTF_FM_REQUEST_GRP.Get_Content_XML (
 		p_api_version     => l_api_version,
		p_content_id      => l_content_id,
	 	--p_content_nm    => l_content_nm,
	 	p_document_type   => l_document_type,
	 	p_media_type      => l_media_type,
		p_printer         => l_printer,
		p_email           => l_email,
		p_file_path       => l_file_path,
		p_fax             => l_fax,
		p_user_note       => l_user_note,
	 	p_content_type    => l_request_type,
		p_bind_var        => p_bind_var, --l_bind_var,
		p_bind_val        => p_bind_val, --l_bind_val,
		p_bind_var_type   => p_bind_var_type, --l_bind_var_type,
		p_request_id      => l_request_id,
		x_return_status   => l_return_status,
		x_msg_count       => l_msg_count,
		x_msg_data        => l_msg_data,
		x_content_xml     => l_one_content_xml );


         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             --DBMS_OUTPUT.PUT_LINE('Message Data: '||l_msg_data);
             --msg
--             IF PG_DEBUG < 10  THEN
             IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                IEX_DEBUG_PUB.LogMessage('iexvffmb.pls:SEND_FFM:Error to Get Content XML');
             END IF;
             --
             x_msg_data := l_msg_data;
             x_msg_count := l_msg_count;
             --
             -- Begin - Andre Araujo - 09/30/2004- Remove obsolete logging
/*             IEX_CONC_REQUEST_MSG_PKG.Log_Error(
                        P_Concurrent_Request_ID => FND_GLOBAL.CONC_REQUEST_ID,
                        P_Procedure_name        => 'IEX_SEND_FFM_PVT.SEND_FFM',
                        P_MESSAGE               => 'ERROR To GET_XML;');

             IEX_CONC_REQUEST_MSG_PKG.Log_Error(
                        P_Concurrent_Request_ID => FND_GLOBAL.CONC_REQUEST_ID,
                        P_Procedure_name        => 'IEX_SEND_FFM_PVT.SEND_FFM',
                        P_MESSAGE               => 'ERROR REQUEST_ID:'|| l_request_id
					|| ' l_msg_data= ' || l_msg_data); */
	      -- End - Andre Araujo - 09/30/2004- Remove obsolete logging

              FND_MESSAGE.Set_Name('IEX', 'API_FAIL_SEND_FFM');
              FND_MESSAGE.Set_Token ('INFO', 'error to get_content_XML');
              FND_MSG_PUB.Add;

              RAISE FND_API.G_EXC_ERROR;
         END IF;

         --clchang added for bug 3807829 08/04/2004
         --keep the content xml to trace
         IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            IEX_DEBUG_PUB.LogMessage('iexvffmb.pls:SEND_FFM: XML='||l_one_content_xml);
         END IF;
         --end clchang added for bug 3807829 08/04/2004

         --l_bind_total := l_bind_total + l_bind_cnt;
         -- Only one content_xml for one request
         l_content_xml := l_content_xml || l_one_content_xml;

         --dbms_output.put_line(i||':get xml status=' ||l_return_status);
--         IF PG_DEBUG < 10  THEN
         IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
            IEX_DEBUG_PUB.LogMessage('iexvffmb.pls:SEND_FFM: Get One Content XML!');
         END IF;

      END LOOP;

--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LogMessage('iexvffmb.pls:SEND_FFM: Get all Content XML!');
      END IF;


      -- Debug Message
      --dbms_output.put_line('summit request...');
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LogMessage('iexvffmb.pls:SEND_FFM: Submit Request');
      END IF;

	-- Submit the fulfillment request
      JTF_FM_REQUEST_GRP.Submit_Request
      ( 	p_api_version      => l_api_version,
		p_commit           => l_commit,
		x_return_status    => l_return_status,
		x_msg_count        => l_msg_count,
		x_msg_data         => l_msg_data,
		p_subject          => l_subject,
		p_party_id         => l_party_id,
		p_user_id          => l_user_id,
                p_server_id        => l_server_id,
		p_queue_response   => FND_API.G_TRUE,
	  	p_content_xml      => l_content_xml,
	  	p_request_id       => l_request_id    );

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          --msg
          -- Begin - Andre Araujo - 09/30/2004- Remove obsolete logging
/*          IEX_CONC_REQUEST_MSG_PKG.Log_Error(
                        P_Concurrent_Request_ID => FND_GLOBAL.CONC_REQUEST_ID,
                        P_Procedure_name        => 'IEX_SEND_FFM_PVT.SEND_FFM',
                        P_MESSAGE               => 'ERROR To SUBMIT_REQUEST;');

          IEX_CONC_REQUEST_MSG_PKG.Log_Error(
                        P_Concurrent_Request_ID => FND_GLOBAL.CONC_REQUEST_ID,
                        P_Procedure_name        => 'IEX_SEND_FFM_PVT.SEND_FFM',
                        P_MESSAGE               => 'ERROR REQUEST_ID:'|| l_request_id ||
                                                   ' l_msg_data= ' || l_msg_data); */
          -- End - Andre Araujo - 09/30/2004- Remove obsolete logging

--          IF PG_DEBUG < 10  THEN
          IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
             IEX_DEBUG_PUB.LogMessage('iexvffmb.pls:SEND_FFM: Error to Submit Request');
          END IF;
          --
          x_msg_data := l_msg_data;
          x_msg_count := l_msg_count;
          FND_MESSAGE.Set_Name('IEX', 'API_FAIL_SEND_FFM');
          FND_MESSAGE.Set_Token ('INFO', 'error to submit_request');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      x_request_id := l_request_id;
      --msg
      -- Begin - Andre Araujo - 09/30/2004- Remove obsolete logging
      /*
      IEX_CONC_REQUEST_MSG_PKG.Log_Error(
                P_Concurrent_Request_ID => FND_GLOBAL.CONC_REQUEST_ID,
                P_Procedure_name        => 'IEX_SEND_FFM_PVT.SEND_FFM',
                P_MESSAGE               => 'REQUEST_ID:'|| l_request_id); */
      -- End - Andre Araujo - 09/30/2004- Remove obsolete logging
--      IF PG_DEBUG < 10  THEN
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
         IEX_DEBUG_PUB.LogMessage('iexvffmb.pls:SEND_FFM: Submit Request! request_id='||l_request_id);
      END IF;

      --
      -- END of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Debug Message

      -- Standard call to get message count and IF count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
--               IF PG_DEBUG < 10  THEN
               IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                  IEX_DEBUG_PUB.LogMessage('iexvffmb.pls:SEND_FFM: Exc_Error:'|| SQLERRM);
               END IF;
               ROLLBACK TO SEND_FFM_PUB;
               x_return_status := FND_API.G_RET_STS_ERROR;
               FND_MSG_PUB.Count_And_Get
               (  p_count          =>   x_msg_count,
                  p_data           =>   x_msg_data
               );

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
--               IF PG_DEBUG < 10  THEN
               IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                  IEX_DEBUG_PUB.LogMessage('iexvffmb.pls:SEND_FFM: UnExc_Error:'||SQLERRM);
               END IF;
               ROLLBACK TO SEND_FFM_PUB;
               x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
               FND_MSG_PUB.Count_And_Get
               (  p_count          =>   x_msg_count,
                  p_data           =>   x_msg_data
               );

          WHEN OTHERS THEN
--               IF PG_DEBUG < 10  THEN
               IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
                  IEX_DEBUG_PUB.LogMessage('iexvffmb.pls:SEND_FFM: Other_Error:'||SQLERRM);
               END IF;
               ROLLBACK TO SEND_FFM_PUB;
               x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
               FND_MSG_PUB.Count_And_Get
               (  p_count          =>   x_msg_count,
                  p_data           =>   x_msg_data
                );

END Send_FFM;


BEGIN
  PG_DEBUG  := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

END IEX_SEND_FFM_PVT;

/
