--------------------------------------------------------
--  DDL for Package Body JTF_FM_OCM_REQUEST_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_FM_OCM_REQUEST_GRP" AS
/* $Header: jtfgfmob.pls 120.0 2005/05/11 08:14:37 appldev ship $*/
G_PKG_NAME    CONSTANT VARCHAR2(100) := 'jtf.plsql.jtfgfmob.JTF_FM_OCM_REQUEST_GRP';
G_FILE_NAME   CONSTANT VARCHAR2(12) := 'jtfgfmob.pls';



/**

**/

FUNCTION IS_REQ_ETSL(p_string VARCHAR2) RETURN BOOLEAN
IS
x_result BOOLEAN := FALSE;
BEGIN
IF(upper(p_string) = 'E' OR  upper(p_string) = 'T'  OR  upper(p_string) = 'S'  OR upper(p_string) = 'L')
THEN
	x_result := TRUE;
END IF;
return x_result;

END IS_REQ_ETSL;


FUNCTION IS_MED_EPF(p_string VARCHAR2) RETURN BOOLEAN
IS
x_result BOOLEAN := FALSE;
BEGIN
IF(INSTR(upper(p_string), 'E')> 0  OR  INSTR(upper(p_string), 'P')>0  OR  INSTR(upper(p_string) , 'F') > 0 )
THEN
	x_result := TRUE;
END IF;
return x_result;

END IS_MED_EPF;


PROCEDURE GET_TEST_XML
(
     p_party_id               IN  JTF_FM_REQUEST_GRP.G_NUMBER_TBL_TYPE ,
     p_email                  IN  JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE ,
     p_fax                    IN  JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE ,
	 p_printer                IN  JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE ,
     p_content_xml            IN  VARCHAR2,
	 x_return_status          OUT NOCOPY VARCHAR2,
	 x_test_xml               OUT NOCOPY VARCHAR2

)
IS
	l_api_name             CONSTANT VARCHAR2(30) := 'GET_TEST_XML';
	l_api_version          CONSTANT NUMBER := 1.0;
	l_full_name            CONSTANT VARCHAR2(100) := G_PKG_NAME ||'.'|| l_api_name;
	--
	l_Error_Msg            VARCHAR2(2000);
	--
	l_index                BINARY_INTEGER;
	l_printer_count        INTEGER;
	l_fax_count            INTEGER;
	l_file_path_count      INTEGER;
	l_email_count          INTEGER;
	l_message              VARCHAR2(32767);


BEGIN

   -- Initialize API return status to success
   	x_return_status := FND_API.G_RET_STS_SUCCESS;

  	l_message := '<items>' || p_content_xml || '</items>';

   	JTF_FM_UTL_V.PRINT_MESSAGE('Creating Batch XML ..',JTF_FM_UTL_V.G_LEVEL_STATEMENT,l_full_name);
    l_index := 0;
      		-- Get the greatest index of the last entry in all the address tables.
    IF l_index < p_fax.LAST THEN
   		l_index := p_fax.LAST;
	END IF;
    IF l_index < p_email.LAST THEN
   		l_index := p_email.LAST;
    END IF;
	IF l_index < p_printer.LAST THEN
   		l_index := p_printer.LAST;
    END IF;
    JTF_FM_UTL_V.PRINT_MESSAGE (to_char(l_index),JTF_FM_UTL_V.G_LEVEL_STATEMENT,l_full_name);

    IF (l_index = 0) THEN
        l_Error_Msg := 'Must pass batch address list';
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             		FND_MESSAGE.set_name('JTF', 'JTF_FM_API_MISSING_BATCH_LIST');
               		FND_MSG_PUB.Add;
        END IF;
           	RAISE  FND_API.G_EXC_ERROR;
    ELSE

		l_message := l_message||'<batch><list>';
        JTF_FM_UTL_V.PRINT_MESSAGE('Getting the greatest value ..'||TO_CHAR(l_index),
	    JTF_FM_UTL_V.G_LEVEL_STATEMENT,l_full_name);
        FOR i IN 1..l_index LOOP
           	-- Check if atleast one destination address has been passed
         	IF( p_email.EXISTS(i)  OR p_fax.EXISTS(i)  OR p_printer.EXISTS(i)) THEN
            		-- For each table check if the record exists.
			--If yes then add it to the XML
                l_message := l_message||'<party ';
                IF p_party_id.EXISTS(i) THEN
               		l_message := l_message || 'id= "'||to_char(p_party_id(i))||'"> ';
               	ELSE
                 	l_message := l_message || '>';
                END IF;
                 	l_message := l_message||'<media_type>';
                IF p_email.EXISTS(i) THEN
	           		l_message := l_message||'<email>'||p_email(i)||'</email>';
                END IF;
                IF p_fax.EXISTS(i) THEN
	           		l_message := l_message||'<fax>'||p_fax(i)||'</fax>';
                END IF;
			    IF p_printer.EXISTS(i) THEN
               		l_message := l_message||'<printer>'||p_printer(i)||'</printer>';
                END IF;

			    l_message := l_message||'</media_type></party>';


          	END IF;
         END LOOP;
	     IF l_index > 0 THEN
		    l_message := l_message||'</list>';
	     END IF;

		 l_message := l_message||'</batch>';

    END IF;
	     x_test_xml := l_message;

	     -- Success message
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
     THEN
       FND_MESSAGE.Set_Name('JTF', 'JTF_FM_API_SUCCESS_MESSAGE');
       FND_MESSAGE.Set_Token('ARG1', l_full_name);
       FND_MSG_PUB.Add;
     END IF;




END;






PROCEDURE create_fulfillment
(
 	p_init_msg_list        		IN	   VARCHAR2 := FND_API.G_FALSE,
	p_api_version          		IN 	   NUMBER,
	p_commit		        IN	   VARCHAR2 := FND_API.G_FALSE,
        p_order_header_rec       	IN  	   JTF_Fulfillment_PUB.ORDER_HEADER_REC_TYPE,
	p_order_line_tbl         	IN  	   JTF_Fulfillment_PUB.ORDER_LINE_TBL_TYPE,
        p_fulfill_electronic_rec        IN 	   JTF_FM_OCM_REQUEST_GRP.FULFILL_ELECTRONIC_REC_TYPE,
        p_request_type         		IN  	   VARCHAR2,
	x_return_status		        OUT 	   NOCOPY VARCHAR2,
	x_msg_count		        OUT 	   NOCOPY NUMBER,
	x_msg_data		        OUT 	   NOCOPY VARCHAR2,
	x_order_header_rec	        OUT NOCOPY ASO_ORDER_INT.order_header_rec_type,
  x_request_history_id     		OUT NOCOPY NUMBER
)
IS

	l_api_name			CONSTANT VARCHAR2(30)	:= 'create_fulfillment';
	l_full_name            		CONSTANT VARCHAR2(100) := G_PKG_NAME ||'.'|| l_api_name;
	l_api_version   		CONSTANT NUMBER 	:= 1.0;
	l_init_msg_list 	  		 VARCHAR2(2) := FND_API.G_FALSE;
	l_content_xml   			 VARCHAR2(10000);
	l_content_xml1   			 VARCHAR2(1000);
	l_bind_var      			JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
	l_bind_val      			JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
	l_bind_var_type 			JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
	l_content_id    			NUMBER;
	l_per_user_history  			VARCHAR2(2);
	l_subject       			VARCHAR2(255);
	l_quantity      			NUMBER := 1;
	l_return_status  			VARCHAR2(200);
	l_request_id    			NUMBER;
	l_request_history_id   			NUMBER;
	l_msg_data      			VARCHAR2(1000);
	l_Error_Msg     			VARCHAR2(1000);
	l_msg_count    			 	NUMBER;
	l_commit		    		VARCHAR2(2) := FND_API.G_FALSE;
	l_total        				NUMBER;
	l_var_media_type 			VARCHAR2(30);
	l_printer_val  				VARCHAR2(250) := null;
	l_fax_val      				VARCHAR2(250):= null;
	l_email_val    				VARCHAR2(250):= null;
	l_extended_header 			VARCHAR2(32767) ;
	l_message  			        VARCHAR2(32767);
	l_content_nm                VARCHAR2(1) := null;
	x_test_xml                  VARCHAR2(32767);

	l_fm_pvt_rec     JTF_FM_UTL_V.FM_PVT_REC_TYPE;

	BEGIN
         --dbms_output.put_line('In create Fulfillment API');

	   JTF_FM_UTL_V.PRINT_MESSAGE('BEGIN' || l_full_name,JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name);
      -- Standard Start of API savepoint
	    SAVEPOINT	create_fulfillment;
    	    -- Standard call to check for call compatibility.
    	    IF NOT FND_API.Compatible_API_Call
	    (
	    	l_api_version,
                p_api_version,
                l_api_name, G_PKG_NAME )
	    THEN
      	    	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    	    END IF;

	    -- Initialize message list if p_init_msg_list is set to TRUE.
    	    IF FND_API.to_Boolean( p_init_msg_list )
	    THEN
      		FND_MSG_PUB.initialize;
    	    END IF;

    		--  Initialize API return status to success
		-- API body
    IF (upper(p_fulfill_electronic_rec.request_type) = 'P') THEN
      		-- call physical fulfillment
      		JTF_Fulfillment_PUB.create_fulfill_physical
            	(p_init_msg_list => p_init_msg_list,
             	 p_api_version   => p_api_version,
            	 p_commit        => p_commit,
             	 x_return_status => x_return_status,
             	 x_msg_count     => x_msg_count,
            	 x_msg_data      => x_msg_data,
                 p_order_header_rec => p_order_header_rec,
             	 p_order_line_tbl   => p_order_line_tbl,
            	 x_order_header_rec => x_order_header_rec,
            	 x_request_history_id => x_request_history_id
            	);
      	IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
		THEN
         		RAISE FND_API.G_EXC_ERROR;
      	END IF;
    ELSIF (IS_REQ_ETSL(p_fulfill_electronic_rec.request_type)) THEN


    		x_return_status := FND_API.G_RET_STS_SUCCESS;
    		l_bind_var := JTF_FM_REQUEST_GRP.L_VARCHAR_TBL;
    		l_bind_val := JTF_FM_REQUEST_GRP.L_VARCHAR_TBL;
    		l_bind_var_type := JTF_FM_REQUEST_GRP.L_VARCHAR_TBL;

		IF LENGTH(p_fulfill_electronic_rec.media_types) >3 THEN
		    l_Error_Msg := null;
	   		l_Error_Msg := 'Invalid media type specified. Only allowed values are ';
	   		l_Error_Msg := l_ERROR_Msg || 'EPF,EFP,FEP,FPE,PEF,PFE,EP,EF,E,PE,PF,P,FE,FP,F';
			JTF_FM_UTL_V.PRINT_MESSAGE(l_Error_msg, JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);
         	JTF_FM_UTL_V.HANDLE_ERROR('JTF_FM_API_CF_INVALID_MEDIA');
         	RAISE  FND_API.G_EXC_ERROR;

		ELSE
				  IF (IS_MED_EPF(p_fulfill_electronic_rec.media_types)) THEN

		    IF ( INSTR(upper(p_fulfill_electronic_rec.media_types),'P')  > 0) THEN

	           l_var_media_type := 'PRINTER,';

               IF p_fulfill_electronic_rec.printer.EXISTS(1) THEN
		          l_printer_val := p_fulfill_electronic_rec.printer(1);
		       ELSE
			      IF p_fulfill_electronic_rec.request_type = 'S'  THEN
			 	     l_Error_Msg := 'Chosen Media is Print but missing print address';
			 	     JTF_FM_UTL_V.PRINT_MESSAGE(l_Error_msg, JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);
         	         JTF_FM_UTL_V.HANDLE_ERROR('JTF_FM_API_MISSING_PRINT_ADDR');
                     RAISE  FND_API.G_EXC_ERROR;
			      ELSE--for mass requests
			         l_printer_val := 'Query';
		          END IF;
		       END IF;

             END IF;

            IF  (INSTR(upper(p_fulfill_electronic_rec.media_types), 'F' ) > 0) THEN
	            l_var_media_type := l_var_media_type || 'FAX,';
		        IF p_fulfill_electronic_rec.fax.EXISTS(1) THEN
		           l_fax_val := p_fulfill_electronic_rec.fax(1);
	            ELSE
		           IF p_fulfill_electronic_rec.request_type = 'S'   THEN
                      l_Error_Msg := 'Chosen Media is FAX but missing FAX address';
   			 	      JTF_FM_UTL_V.PRINT_MESSAGE(l_Error_msg, JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);
         	          JTF_FM_UTL_V.HANDLE_ERROR('JTF_FM_API_MISSING_FAX_ADDR');
                      RAISE  FND_API.G_EXC_ERROR;
			       ELSE -- no need of fax address for mass requests
		 	          l_fax_val := 'Query';
		           END IF;
		        END IF;

	        END IF;

            IF((INSTR(upper(p_fulfill_electronic_rec.media_types),'E')>0)
	          OR p_fulfill_electronic_rec.media_types IS NULL
             OR p_fulfill_electronic_rec.media_types= FND_API.G_MISS_CHAR) THEN
                l_var_media_type := l_var_media_type ||'EMAIL';
		       IF p_fulfill_electronic_rec.email.EXISTS(1) THEN
		           l_email_val := p_fulfill_electronic_rec.email(1);
		       ELSE
	                IF p_fulfill_electronic_rec.request_type = 'S' THEN

                       l_Error_Msg := 'Chosen Media is Email but missing email address';
                       JTF_FM_UTL_V.PRINT_MESSAGE(l_Error_msg, JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);
        	           JTF_FM_UTL_V.HANDLE_ERROR('JTF_FM_API_MISSING_EMAIL_ADDR');
                       RAISE  FND_API.G_EXC_ERROR;
			        ELSE
			            l_email_val := 'Query';
		            END IF;
		       END IF;


            END IF;
		ELSE  -- Means media is not E or P or F
		    l_Error_Msg := null;
	   		l_Error_Msg := 'Invalid media type specified. Only allowed values are ';
	   		l_Error_Msg := l_ERROR_Msg || 'EPF,EFP,FEP,FPE,PEF,PFE,EP,EF,E,PE,PF,P,FE,FP,F';
			JTF_FM_UTL_V.PRINT_MESSAGE(l_Error_msg, JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,l_full_name);
         	JTF_FM_UTL_V.HANDLE_ERROR('JTF_FM_API_CF_INVALID_MEDIA');
         	RAISE  FND_API.G_EXC_ERROR;


		END IF;


	END IF ;-- End IF(p_fulfill_electronic_rec.media_types.LENGTH >3) THEN



      	IF(p_fulfill_electronic_rec.extended_header IS  NULL) THEN
   			JTF_FM_UTL_V.PRINT_MESSAGE('Extended header is null',JTF_FM_UTL_V.G_LEVEL_STATEMENT,l_full_name);
       		l_extended_header := FND_API.G_MISS_CHAR;
      	ELSE
       		l_extended_header := p_fulfill_electronic_rec.extended_header;
      	END IF;

	  	/**
			internally three apis are called
	  		start request is called first
	  	**/

      		JTF_FM_REQUEST_GRP.start_request
		(
			p_api_version      => l_api_version,
                     	p_init_msg_list    => l_init_msg_list,
                     	x_return_status    => x_return_status,
                     	x_msg_count        => l_msg_count,
                     	x_msg_data         => l_msg_data,
                     	x_request_id       => x_request_history_id
                );
     	JTF_FM_UTL_V.PRINT_MESSAGE('Start_Request Return Status is ' || x_return_status,
		JTF_FM_UTL_V.G_LEVEL_STATEMENT,l_full_name);

	  	IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      	  	RAISE FND_API.G_EXC_ERROR;
      	END IF;

	  	JTF_FM_UTL_V.PRINT_MESSAGE('Inside ocm pkg request id is ' || to_char(x_request_history_id),
					    JTF_FM_UTL_V.G_LEVEL_STATEMENT,l_full_name);
      		l_total := p_fulfill_electronic_rec.bind_names.count;
      		FOR i IN 1..l_total LOOP
	       	  l_bind_var(i) := p_fulfill_electronic_rec.bind_names(i);
       		  l_bind_val(i) := p_fulfill_electronic_rec.bind_values(i);
       	  	  l_bind_var_type(i) := 'VARCHAR2';
      		END LOOP;

	      l_content_id := p_fulfill_electronic_rec.template_id;
	      JTF_FM_UTL_V.PRINT_MESSAGE('Inside ocm pkg l_content_id is ' || to_char(l_content_id),
	      JTF_FM_UTL_V.G_LEVEL_STATEMENT,l_full_name);

	      /**
	   	just before calling send request we will insert a record into
   	   	history table. Reason. GET_ATTACH_FILE_ID AND GET_FILE_ID in jtfgfmob.pls should
   	   	know about REQUEST_TYPE 'T'
   	   	other details in GET_ATTACH_FILE_ID and GET_FILE_ID
	      **/
      	 IF (upper(p_fulfill_electronic_rec.request_type) = 'T') THEN
    	  	  JTF_FM_UTL_V.PRINT_MESSAGE('THE REQUEST TYPE IS TEST',JTF_FM_UTL_V.G_LEVEL_STATEMENT,l_full_name);
          	  INSERT INTO JTF_FM_TEST_REQUESTS (REQUEST_ID) VALUES (x_request_history_id);
      	 END IF;

	  /********************************************************
	  Following modifications were made for Label but
	  the design is not finalized yet 8-27-03.  .
	  This is subject to change


	  *********************************************************/
	      IF(upper(p_fulfill_electronic_rec.request_type) = 'L') THEN
		      l_content_nm := 'L';
		  END IF;

	      /**
	  	 get content xml is called after calling start request
		 this prepares the content related xml

		 for single request
		 p_email,p_file_path,,p_fax should change
	      **/

      	      JTF_FM_REQUEST_GRP.GET_CONTENT_XML
                     (p_api_version      => p_api_version,
                      x_return_status    => x_return_status,
                      x_msg_count        => x_msg_count,
                      x_msg_data         => x_msg_data,
                      p_content_id       => l_content_id,
                      p_content_nm       => l_content_nm,
                      p_document_type    => 'htm',
                      p_quantity         => l_quantity,
                      p_media_type       => l_var_media_type,
                      p_printer          => l_printer_val,
                      p_email            => l_email_val,
                      p_file_path        => null,
                      p_fax              => l_fax_val,
                      p_user_note        => 'USER NOTE',
                      p_content_type     => 'QUERY',
                      p_bind_var         => l_bind_var,
                      p_bind_val         => l_bind_val,
                      p_bind_var_type    => l_bind_var_type,
                      p_request_id       => x_request_history_id,
                      x_content_xml      => l_content_xml1,
                      p_content_source   => 'ocm',
                      p_version          => p_fulfill_electronic_rec.version_id
              );

	      JTF_FM_UTL_V.PRINT_MESSAGE('Get_Content_XML Return Status is ' || x_return_status,
	      				  JTF_FM_UTL_V.G_LEVEL_STATEMENT,l_full_name);

     	 l_content_xml := l_content_xml1;

     	 IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
     		RAISE   FND_API.G_EXC_ERROR;
     	 END IF;

	     IF(upper(p_fulfill_electronic_rec.log_user_ih) = 'Y') THEN
         	l_per_user_history := FND_API.G_TRUE;
   	     ELSE
       		l_per_user_history := FND_API.G_FALSE;
   	     END IF;

	     IF(length(p_fulfill_electronic_rec.subject) > 250) THEN
         	l_subject  := substrb(p_fulfill_electronic_rec.subject,1,250);
     	 ELSE
         	l_subject  := p_fulfill_electronic_rec.subject;
     	 END IF;

	     /**
	 	if the request type is 'T', then call the submit test request
	     **/
      	    IF upper(p_fulfill_electronic_rec.request_type) = 'T' THEN
             	GET_TEST_XML
           		     (p_party_id           => p_fulfill_electronic_rec.party_id,
            		 p_email              => p_fulfill_electronic_rec.email,
            	 	 p_fax                => p_fulfill_electronic_rec.fax,
			         p_printer            => p_fulfill_electronic_rec.printer,
            		 p_content_xml        => l_content_xml,
					 x_return_status      => l_return_status,
					 x_test_xml           => x_test_xml

            		) ;
			JTF_FM_UTL_V.PRINT_MESSAGE('GET_TEST_XML Return Status is ' || x_return_status,
						   JTF_FM_UTL_V.G_LEVEL_STATEMENT,l_full_name);
           	    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
			    THEN
		               RAISE FND_API.G_EXC_ERROR;
           	    END IF;

      	   END IF;


           -- Check if the agent wants detailed history
       IF l_per_user_history = FND_API.G_FALSE THEN
    		l_fm_pvt_rec.party_id := -229929;
	   END IF;

	   /**
		   	  set all the values for the record type based on the
			  parameters passed into CREATE_FULFILLMENT
	   **/
	   /**
	   	  identify if it it is a single or a mass request
	   **/
	   IF(upper(p_fulfill_electronic_rec.request_type) = 'S')THEN

	   	   l_fm_pvt_rec.queue := 'S';
		   l_message :=l_content_xml;
	   ELSIF(upper(p_fulfill_electronic_rec.request_type) = 'T') THEN
	       l_fm_pvt_rec.queue := 'B';
		   l_message := x_test_xml;
		   l_fm_pvt_rec.preview := 'TEST';
	   ELSE --assuming the only other case is mass
	   	   l_fm_pvt_rec.queue := 'M';
		   -- check if content_source is 'ocm', else throw error
		   -- Mass request is supported only for OCM contents
		   -- Proceed
	       IF(INSTR(l_content_xml,'query_id') >0)
	       THEN
			JTF_FM_UTL_V.PRINT_MESSAGE('Item has a valid query OCM Repository',
				JTF_FM_UTL_V.G_LEVEL_STATEMENT,l_full_name);
			  IF upper(p_fulfill_electronic_rec.request_type) = 'L' THEN
			     l_message := '<items>' || l_content_xml || '</items><batch><label/></batch>';
			  ELSE
			     l_message := '<items>' || l_content_xml || '</items><batch><mass/></batch>';
		      END IF;
	       ELSE
	 	        -- throw error, item should have a query assoc for mass requests
			l_Error_Msg := 'Content must have a valid query associated with it.';
			JTF_FM_UTL_V.HANDLE_ERROR('JTF_FM_API_MISSING_OCM_QUERY',l_content_id);
                	RAISE  FND_API.G_EXC_ERROR;
	       END IF;
	   END IF;
	   l_fm_pvt_rec.priority := 1.0;
   	   l_fm_pvt_rec.content_xml := l_message;
	   l_fm_pvt_rec.request_id :=  x_request_history_id ;
	   l_fm_pvt_rec.doc_id := 1.0;
	   l_fm_pvt_rec.doc_ref := 'UNSET';
  	   JTF_FM_UTL_V.FM_SUBMIT_REQ_V1
  	   (
		   	p_api_version ,
		    p_init_msg_list,
			p_commit,
			x_return_status,
			x_msg_count,
			x_msg_data,
			p_fulfill_electronic_rec,
			l_fm_pvt_rec
	   );
	   JTF_FM_UTL_V.PRINT_MESSAGE('Submit_Mass_Request Return Status is ' || x_return_status,
	   			       JTF_FM_UTL_V.G_LEVEL_STATEMENT,l_full_name);
       IF(l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           	RAISE FND_API.G_EXC_ERROR;
   	   END IF;

	   IF(upper(p_fulfill_electronic_rec.request_type) = 'T') THEN

	      UPDATE JTF_FM_REQUEST_HISTORY_ALL
          SET request_type = 'T'
          WHERE hist_req_id = x_request_history_id;
	   END IF;


  ELSE
  	   l_Error_Msg := 'Invalid request type specified. Only allowed values are ';
	   l_Error_Msg := l_ERROR_Msg || 'E,P or T';
       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
       THEN
            FND_MESSAGE.set_name('JTF', 'JTF_FM_API_INVALID_REQTYPE');
            FND_MSG_PUB.Add;
       END IF; -- IF FND_MSG_PUB.check_msg_level
         RAISE  FND_API.G_EXC_ERROR;
  END IF; -- end if electronic fulfillment

  -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data  => x_msg_data );


  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO create_fulfillment;
	   x_return_status := FND_API.G_RET_STS_ERROR ;
	   FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data  => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR
    THEN
	    ROLLBACK TO create_fulfillment;
	    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	   FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data  => x_msg_data );

    WHEN OTHERS
    THEN
	ROLLBACK TO create_fulfillment;
    	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
       	    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name);
	END IF;
	FND_MSG_PUB.Count_And_Get( p_count => x_msg_count, p_data => x_msg_data );

  END CREATE_FULFILLMENT;
END JTF_FM_OCM_REQUEST_GRP;

/
