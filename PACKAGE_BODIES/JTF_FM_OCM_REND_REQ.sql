--------------------------------------------------------
--  DDL for Package Body JTF_FM_OCM_REND_REQ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_FM_OCM_REND_REQ" AS
/* $Header: jtfgfmrb.pls 120.6 2005/10/25 07:19:27 gjoby noship $*/

G_PKG_NAME  CONSTANT VARCHAR2(100) := 'jtf.plsql.jtfgfmrb.JTF_FM_OCM_REND_REQ';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'jtfgfmrb.pls';


--Global Variables
G_MIME_TBL  JTF_VARCHAR2_TABLE_100 :=
  JTF_VARCHAR2_TABLE_100(
    'TEXT/HTML',
    'TEXT/PLAIN',
    'APPLICATION/PDF',
    'APPLICATION/RTF',
    'APPLICATION/X-RTF',
    'TEXT/RICHTEXT');

/**

**/

FUNCTION IS_REQ_ETSL(p_string VARCHAR2) RETURN BOOLEAN
IS
x_result BOOLEAN := FALSE;
BEGIN
  IF (upper(p_string) = 'E' OR  upper(p_string) = 'T'  OR  upper(p_string) = 'S'
  OR upper(p_string) = 'L')
THEN
	x_result := TRUE;
END IF;
return x_result;

END IS_REQ_ETSL;


FUNCTION IS_MED_EPF(p_string VARCHAR2) RETURN BOOLEAN
IS
x_result BOOLEAN := FALSE;
BEGIN
  IF(INSTR(upper(p_string), 'E')> 0  OR  INSTR(upper(p_string), 'P')>0  OR
  INSTR(upper(p_string) , 'F') > 0 )
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
  p_media                  IN  VARCHAR2,
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

	    IF ( INSTR(upper(p_media),'P')  > 0) THEN
		   IF NOT p_printer.EXISTS(1) THEN
		      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             	 FND_MESSAGE.set_name('JTF', 'JTF_FM_API_TEST_MISS_PRINT_ADD');
               		FND_MSG_PUB.Add;
              END IF;
           	  RAISE  FND_API.G_EXC_ERROR;
		   END IF;
	    END IF;
		IF ( INSTR(upper(p_media),'E')  > 0) THEN
		   IF NOT p_email.EXISTS(1) THEN
		      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             	 FND_MESSAGE.set_name('JTF', 'JTF_FM_API_TEST_MISS_EMAIL_ADD');
               		FND_MSG_PUB.Add;
              END IF;
           	  RAISE  FND_API.G_EXC_ERROR;
		   END IF;
	    END IF;
		IF ( INSTR(upper(p_media),'F')  > 0) THEN
		   IF NOT p_fax.EXISTS(1) THEN
		      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
             	 FND_MESSAGE.set_name('JTF', 'JTF_FM_API_TEST_MISS_FAX_ADD');
               		FND_MSG_PUB.Add;
              END IF;
           	  RAISE  FND_API.G_EXC_ERROR;
		   END IF;
	    END IF;


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

			    IF p_printer.EXISTS(i) THEN
               		l_message := l_message||'<printer>'||p_printer(i)||'</printer>';
                END IF;
				IF p_email.EXISTS(i) THEN
	           		l_message := l_message||'<email>'||p_email(i)||'</email>';
                END IF;
                IF p_fax.EXISTS(i) THEN
	           		l_message := l_message||'<fax>'||p_fax(i)||'</fax>';
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
		 --SPLIT_LINE(x_test_xml,80);

	     -- Success message
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
     THEN
       FND_MESSAGE.Set_Name('JTF', 'JTF_FM_API_SUCCESS_MESSAGE');
       FND_MESSAGE.Set_Token('ARG1', l_full_name);
       FND_MSG_PUB.Add;
     END IF;




END;


PROCEDURE INSERT_REQUEST_CONTENTS(
   p_request_id  IN NUMBER,
   p_content_id  IN NUMBER,
   p_content_number IN NUMBER,
   p_content_name   IN VARCHAR2,
   p_content_type   IN VARCHAR2,
   p_document_type  IN VARCHAR2,
   p_body           IN VARCHAR2,
   p_user_note      IN VARCHAR2,
   p_quantity       IN NUMBER,
   p_media_type     IN VARCHAR2,
   p_content_source IN VARCHAR2,
   p_file_id        IN NUMBER
)
IS
   l_api_name CONSTANT VARCHAR2(30) := 'INSERT_REQUEST_CONTENTS';
   l_full_name CONSTANT VARCHAR2(2000) := G_PKG_NAME || '.' || l_api_name;


BEGIN
    JTF_FM_UTL_V.PRINT_MESSAGE('Begin PROCEDURE INSERT_REQUEST_CONTENTS',  JTF_FM_UTL_V.G_LEVEL_PROCEDURE, l_full_name);


   INSERT INTO JTF_FM_REQUEST_CONTENTS (
   REQUEST_ID,
   CONTENT_ID,
   CONTENT_NUMBER,
   CONTENT_NAME,
   CONTENT_TYPE,
   DOCUMENT_TYPE,
   BODY,
   USER_NOTES,
   QUANTITY,
   CREATED_BY,
   CREATION_DATE,
   LAST_UPDATED_BY,
   LAST_UPDATE_DATE,
   LAST_UPDATE_LOGIN,
   MEDIA_TYPE,
   CONTENT_SOURCE,
   FND_FILE_ID)
   VALUES (
   p_request_id ,
   p_content_id,
   p_content_number,
   p_content_name,
   p_content_type,
   p_document_type,
   p_body,
   p_user_note,
   p_quantity ,
   FND_GLOBAL.USER_ID ,
   SYSDATE ,
   FND_GLOBAL.USER_ID ,
   SYSDATE,
   FND_GLOBAL.LOGIN_ID ,
   p_media_type ,
   p_content_source ,
   p_file_id );


       JTF_FM_UTL_V.PRINT_MESSAGE('End PROCEDURE INSERT_REQUEST_CONTENTS',  JTF_FM_UTL_V.G_LEVEL_PROCEDURE, l_full_name);

EXCEPTION
    WHEN OTHERS
    THEN
		JTF_FM_UTL_V.PRINT_MESSAGE('UNEXPECTED ERROR IN PROCEDURE INSERT_REQUEST_CONTENTS', JTF_FM_UTL_V.G_LEVEL_PROCEDURE, l_full_name);

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END INSERT_REQUEST_CONTENTS;





FUNCTION GET_FILE_NAME (
   p_file_id  IN NUMBER
   )
RETURN  VARCHAR2
IS
l_file_name VARCHAR2(256);
l_api_name CONSTANT VARCHAR2(30) := 'GET_FILE_NAME';
l_full_name CONSTANT VARCHAR2(2000) := G_PKG_NAME || '.' || l_api_name;

BEGIN
     JTF_FM_UTL_V.PRINT_MESSAGE('BEGIN' || l_full_name , JTF_FM_UTL_V.G_LEVEL_PROCEDURE, l_full_name);
     JTF_FM_UTL_V.PRINT_MESSAGE('File Id' || p_file_id, JTF_FM_UTL_V.G_LEVEL_PROCEDURE, l_full_name);
    -- Bug Fix # 3769865 (removed Userenv Lang condition)
    SELECT FILE_NAME into l_file_name from fnd_lobs where file_id = p_file_id ;

	 JTF_FM_UTL_V.PRINT_MESSAGE('END function ',  JTF_FM_UTL_V.G_LEVEL_PROCEDURE, l_full_name);

	RETURN l_file_name;

  EXCEPTION
    WHEN NO_DATA_FOUND
	THEN
            --l_Error_Msg := 'Could not find queue_names in the database';
	  JTF_FM_UTL_V.Handle_ERROR('JTF_FM_API_FILENAME_NOTFOUND',to_char(p_file_id));

      JTF_FM_UTL_V.PRINT_MESSAGE('END' || l_full_name, JTF_FM_UTL_V.G_LEVEL_PROCEDURE, l_full_name);


END GET_FILE_NAME;

/***
  p_citem_id is required only for "TEST" requests
**/
FUNCTION GET_FILE_ID
(
  p_citem_ver_id    IN VARCHAR2,
  p_citem_id        IN VARCHAR2,
  p_request_id      IN NUMBER
)
RETURN VARCHAR2 IS

  file_id NUMBER;
  l_api_name CONSTANT VARCHAR2(30) := 'GET_FILE_ID';
  l_full_name CONSTANT VARCHAR2(2000) := G_PKG_NAME || '.' || l_api_name;
  l_req_count NUMBER  := 0;

CURSOR get_file_query1_c is
      SELECT attachment_file_id
      FROM
        ibc_content_items b,
        ibc_citem_versions_vl a
      WHERE
        b.live_citem_version_id = a.citem_version_id
      AND
        b.content_item_id = p_citem_id;

CURSOR get_file_query2_c is
        SELECT attachment_file_id
        FROM ibc_citem_versions_vl a,
          (SELECT MAX(version_number) version_number
          FROM ibc_citem_versions_b
          WHERE content_item_id=p_citem_id) b
        WHERE
        a.content_item_id = p_citem_id AND
        a.version_number  = b.version_number;


BEGIN

  JTF_FM_UTL_V.PRINT_MESSAGE('BEGIN' || l_full_name,
    JTF_FM_UTL_V.G_LEVEL_PROCEDURE, l_full_name);

  -- First we need to determine whether this is a test request or a
  -- normal request, as the rules for determining the file id are different.

  SELECT DISTINCT COUNT(REQUEST_ID) INTO l_req_count FROM JTF_FM_TEST_REQUESTS
  WHERE REQUEST_ID = p_request_id ;

  BEGIN
    IF l_req_count > 0 THEN

      OPEN get_file_query1_c;
      FETCH get_file_query1_c INTO file_id;

      IF (get_file_query1_c%NOTFOUND) THEN
        OPEN get_file_query2_c;
        FETCH get_file_query2_c INTO file_id;
        IF (get_file_query2_c%NOTFOUND) THEN
           CLOSE get_file_query1_c;
           CLOSE get_file_query2_c ;
           RAISE NO_DATA_FOUND;
        END IF;
        CLOSE get_file_query2_c ;
      END IF;

      CLOSE get_file_query1_c;

      -- dbms_output.put_line('Attachment_file_id in live version is ' ||
      --  file_id);

      --**********************************************************************
      -- The following code recommended by OCM team to allow for test
      -- requests where user has uploaded an inprogress attachment where
      -- it wouldn't be approved yet.  Reference bug4398752

      --- EXCEPTION WHEN NO_DATA_FOUND THEN

        -- User can also add attachment on the fly by browsing
        -- the filesystem.  This attachment is created in "INPROGRESS"
        -- status which the above SQL won't find.
        -- So get the latest version of this attachment.

        --        SELECT attachment_file_id INTO file_id
        --        FROM ibc_citem_versions_vl a,
        --          (SELECT MAX(version_number) version_number
        --          FROM ibc_citem_versions_b
        --          WHERE content_item_id=p_citem_id) b
        --        WHERE
        --        a.content_item_id = p_citem_id AND
        --        a.version_number  = b.version_number;

        --dbms_output.put_line('attachment_file_id is not yet approved ' ||
        --  file_id);

        -- end OCM code.  Reference bug4398752
        --********************************************************************

    ELSE

      --First get the approved CITEM_VER_ID for the given content ID.

		  SELECT ATTACH_FID INTO file_id FROM ibc_citems_v
      WHERE CITEM_VER_ID = p_citem_ver_id AND item_status = 'APPROVED'
		  and LANGUAGE = USERENV('LANG');

    END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        JTF_FM_UTL_V.PRINT_MESSAGE('JTF_FM_OCM_ATTACH_ABS',
          JTF_FM_UTL_V.G_LEVEL_PROCEDURE, l_full_name);
		    JTF_FM_UTL_V.HANDLE_ERROR('JTF_FM_OCM_ATTACH_ABS', p_citem_ver_id);
		    RAISE FND_API.G_EXC_ERROR;
  END;

  JTF_FM_UTL_V.PRINT_MESSAGE('END' || l_full_name,
    JTF_FM_UTL_V.G_LEVEL_PROCEDURE, l_full_name);
  RETURN file_id;

END GET_FILE_ID;

FUNCTION IS_KNOWN_MIME_TYPE(mime_type VARCHAR2)
RETURN Boolean IS
known_mime boolean := false ;
counter NUMBER := 0;
tbl_count NUMBER :=0 ;
BEGIN
     tbl_count := G_MIME_TBL.COUNT;
	 --dbms_output.put_line('tbl count is :' || tbl_count);
	LOOP
         EXIT WHEN tbl_count = counter;
		 counter := counter + 1;
		  --dbms_output.put_line('counter is ' || counter);
		  --dbms_output.put_line('G_MIME_TBL of counter is ' || G_MIME_TBL(counter));

	   IF (mime_type= G_MIME_TBL(counter)) THEN
	      known_mime := true;
	   END IF;
	END LOOP;
	--dbms_output.put_line('Returning known mime' );
	RETURN known_mime;
END IS_KNOWN_MIME_TYPE;



--------------------------------------------------------------
-- PROCEDURE
--    GET_AND_INSERT_REQUEST_DETAILS
-- DESCRIPTION
--    Constructs the XML based on the media type and inserts the req details
--    JTF_FM_REQUEST_CONTENTS table
--
--
-- HISTORY
--    11/11/03  sxkrishn Create.
--

---------------------------------------------------------------

PROCEDURE GET_AND_INSERT_REQUEST_DETAILS(
    p_request_id         IN NUMBER,
    p_content_id         IN NUMBER,
	p_user_note          IN VARCHAR2,
    p_quantity           IN NUMBER,
    p_media_type         IN VARCHAR2,
	p_query_id           IN NUMBER,
	p_email_format       IN VARCHAR2,
	p_version            IN NUMBER,
	p_content_nm         IN VARCHAR2,
    rendition_file_names IN JTF_VARCHAR2_TABLE_300,
    rendition_mime_names IN JTF_VARCHAR2_TABLE_100,
    rendition_mime_types IN JTF_VARCHAR2_TABLE_100,
	rendition_file_ids   IN JTF_NUMBER_TABLE,
	x_rend_xml           OUT NOCOPY VARCHAR2,
	x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER,
    x_msg_data           OUT NOCOPY VARCHAR2
)
IS
  l_api_name CONSTANT varchar2(30) := 'GET_AND_INSERT_REQUEST_DETAILS';
  l_full_name CONSTANT varchar2(2000) := G_PKG_NAME || '.' || l_api_name;
  att_count NUMBER := 0;
  x_html VARCHAR2(32767) ;
  counter NUMBER := 0;
  html_file_id NUMBER := 0;
  l_count_total NUMBER := 1;
  rend_count NUMBER := 0;
  text_file_id NUMBER := 0;
  pdf_file_id NUMBER := 0;
  rtf_file_id NUMBER := 0;
  html_flag BOOLEAN := false;
  text_flag BOOLEAN := false;
  pdf_mime_name VARCHAR2(100);
  rtf_mime_name VARCHAR2(100);
  html_mime_name VARCHAR2(100);
  text_mime_name VARCHAR2(100);
  a              VARCHAR2(1) := '';
  l_file_name    VARCHAR2(250);




BEGIN
  JTF_FM_UTL_V.PRINT_MESSAGE('GET_AND_INSERT_REQUEST_DETAILS  name = ' ,JTF_FM_UTL_V.G_LEVEL_PROCEDURE, l_full_name);
  JTF_FM_UTL_V.PRINT_MESSAGE('THE REQUEST ID IS  name = '|| p_request_id,JTF_FM_UTL_V.G_LEVEL_PROCEDURE, l_full_name);
    IF rendition_file_ids IS NOT NULL THEN
	  att_count := rendition_file_ids.COUNT;
	   JTF_FM_UTL_V.PRINT_MESSAGE('att_count size is ' || att_count,JTF_FM_UTL_V.G_LEVEL_PROCEDURE, l_full_name);
	   x_html := '<files> ' || a;

        LOOP
            EXIT WHEN att_count = counter;
            counter := counter + 1;

            --DBMS_OUTPUT.PUT_LINE('Rendition Mime Names = ' || rendition_mime_names(counter));

			--DBMS_OUTPUT.PUT_LINE('------------------------------------------------');

			JTF_FM_UTL_V.PRINT_MESSAGE('Rendition File ID = ' || rendition_file_ids(counter),JTF_FM_UTL_V.G_LEVEL_PROCEDURE, l_full_name);
            JTF_FM_UTL_V.PRINT_MESSAGE('Rendition File name = ' || rendition_file_names(counter),JTF_FM_UTL_V.G_LEVEL_PROCEDURE, l_full_name);
            JTF_FM_UTL_V.PRINT_MESSAGE('Rendition Mime Types = ' || rendition_mime_types(counter),JTF_FM_UTL_V.G_LEVEL_PROCEDURE, l_full_name);
            JTF_FM_UTL_V.PRINT_MESSAGE('Rendition Mime Names = ' || rendition_mime_names(counter),JTF_FM_UTL_V.G_LEVEL_PROCEDURE, l_full_name);

			JTF_FM_UTL_V.PRINT_MESSAGE('------------------------------------------------',JTF_FM_UTL_V.G_LEVEL_PROCEDURE ,l_full_name);
			IF UPPER(rendition_mime_types(counter)) = G_MIME_TBL(1) THEN
			    html_file_id := rendition_file_ids(counter);
				html_mime_name := rendition_mime_names(counter);
				IF l_count_total = 0 THEN
				   l_count_total := l_count_total +1;
				END IF;
				rend_count := rend_count + 1;
		    END IF;
	        IF UPPER(rendition_mime_types(counter)) = G_MIME_TBL(2) THEN
			    text_file_id := rendition_file_ids(counter);
				text_mime_name := rendition_mime_names(counter);
				IF l_count_total = 0 THEN
				   l_count_total := l_count_total +1;
				END IF;
				rend_count := rend_count + 1;
		    END IF;
			IF UPPER(rendition_mime_types(counter)) = G_MIME_TBL(3) THEN
			    pdf_file_id := rendition_file_ids(counter);
				pdf_mime_name := rendition_mime_names(counter);
				IF l_count_total = 0 THEN
				   l_count_total := l_count_total +1;
				END IF;
				rend_count := rend_count + 1;
		    END IF;
			IF UPPER(rendition_mime_types(counter)) = G_MIME_TBL(4) THEN
			    rtf_file_id := rendition_file_ids(counter);
				rtf_mime_name := rendition_mime_names(counter);
				IF l_count_total = 0 THEN
				   l_count_total := l_count_total +1;
				END IF;
				rend_count := rend_count + 1;
		    END IF;
			IF UPPER(rendition_mime_types(counter)) = G_MIME_TBL(5) THEN
			    rtf_file_id := rendition_file_ids(counter);
				rtf_mime_name := rendition_mime_names(counter);
				IF l_count_total = 0 THEN
				   l_count_total := l_count_total +1;
				END IF;
				rend_count := rend_count + 1;
		    END IF;
			IF UPPER(rendition_mime_types(counter)) = G_MIME_TBL(6) THEN
			    rtf_file_id := rendition_file_ids(counter);
				rtf_mime_name := rendition_mime_names(counter);
				IF l_count_total = 0 THEN
				   l_count_total := l_count_total +1;
				END IF;
				rend_count := rend_count + 1;
		    END IF;

        END LOOP;

	    IF rend_count = 0 THEN
	        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
               FND_MESSAGE.set_name('JTF', 'JTF_FM_OCM_CONTENT_VER_ABS');
               FND_MESSAGE.Set_Token('ARG1',p_content_id);
			   FND_MESSAGE.Set_Token('ARG2',p_version);
               FND_MSG_PUB.Add;
            END IF;
            RAISE  FND_API.G_EXC_ERROR;

	    END IF;

		-- Now begin construction of XML and insert into request contents
		x_html := x_html || '<file ' || a;

		-- Following changes were made for Labels
	    IF p_content_nm = 'L' THEN
		   x_html := x_html || ' body = "label" ' ;
		ELSE
		    x_html := x_html || ' body = "merge" ';
		END IF;

				-- Attach the query now
	   IF p_query_id <> 0 THEN
		  x_html := x_html || ' query_id ="' || p_query_id || '"' || a;
	   END IF;




		IF (INSTR(p_media_type, 'P') > 0) THEN
		    IF(rtf_file_id <> 0) THEN
			    -- Add the rtf id here
				x_html := x_html || ' rtf_id ="' || rtf_file_id || '"' || a;
				l_file_name := GET_FILE_NAME(rtf_file_id);
				INSERT_REQUEST_CONTENTS(
                  p_request_id,
                  p_content_id,
                  l_count_total,
                  l_file_name,
                  rtf_mime_name,
                  G_MIME_TBL(4),
                  'Y',
                  p_user_note,
                  p_quantity,
                  p_media_type,
                  'ocm' ,
                  rtf_file_id);
			ELSIF(pdf_file_id <> 0) THEN
			    -- Add the pdf id here
				 x_html := x_html || ' pdf_id ="' || pdf_file_id || '"' || a;
				 l_file_name := GET_FILE_NAME(pdf_file_id);
				INSERT_REQUEST_CONTENTS(
                  p_request_id,
                  p_content_id,
                  l_count_total,
                  l_file_name,
                  pdf_mime_name,
                  G_MIME_TBL(3),
                  'Y',
                  p_user_note,
                  p_quantity,
                  p_media_type,
                  'ocm' ,
                  pdf_file_id);
			ELSIF(html_file_id <> 0) THEN
			    -- Add the html id here
				html_flag := true;
				 x_html := x_html || ' id = "' || html_file_id || '" ' || a;
				  l_file_name := GET_FILE_NAME(html_file_id);
				INSERT_REQUEST_CONTENTS(
                  p_request_id,
                  p_content_id,
                  l_count_total,
                  l_file_name,
                  html_mime_name,
                  G_MIME_TBL(1),
                  'Y',
                  p_user_note,
                  p_quantity,
                  p_media_type,
                  'ocm' ,
                  html_file_id);
			ELSIF(text_file_id <> 0) THEN
			    -- Add the text if here
				text_flag := true;
				x_html := x_html || ' txt_id ="' || text_file_id || '"' || a;
				 l_file_name := GET_FILE_NAME(text_file_id);
				INSERT_REQUEST_CONTENTS(
                  p_request_id,
                  p_content_id,
                  l_count_total,
                  l_file_name,
                  text_mime_name,
                  G_MIME_TBL(2),
                  'Y',
                  p_user_note,
                  p_quantity,
                  p_media_type,
                  'ocm' ,
                  text_file_id);
		    ELSE
			    -- Throw Error
				IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                   FND_MESSAGE.set_name('JTF', 'JTF_FM_OCM_CONTENT_VER_ABS');
                   FND_MESSAGE.Set_Token('ARG1',p_content_id);
			       FND_MESSAGE.Set_Token('ARG2',p_version);
                   FND_MSG_PUB.Add;
                END IF;
                RAISE  FND_API.G_EXC_ERROR;
			END IF;
		END IF;

		IF (INSTR(p_media_type, 'E') > 0 OR INSTR(p_media_type, 'F') > 0) THEN
		  IF html_file_id = 0 AND text_file_id = 0 THEN
		      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                  FND_MESSAGE.set_name('JTF', 'JTF_FM_API_TXT_HTML_ABS');
                  FND_MESSAGE.Set_Token('ARG1',p_content_id);
			      FND_MESSAGE.Set_Token('ARG2',p_version);
                  FND_MSG_PUB.Add;
               END IF;
               RAISE  FND_API.G_EXC_ERROR;

		  END IF;

		   IF JTF_FM_UTL_V.IS_FLD_VALID(p_email_format) THEN
		      IF(upper(p_email_format) = 'BOTH') THEN
			     IF NOT (html_flag) THEN
				    -- add html
					html_flag := true;
					x_html := x_html || ' id = "' || html_file_id || '" ' || a;
					l_file_name := GET_FILE_NAME(html_file_id);
				    INSERT_REQUEST_CONTENTS(
                               p_request_id,
                               p_content_id,
                               l_count_total,
                               l_file_name,
                               html_mime_name,
                               G_MIME_TBL(1),
                               'Y',
                               p_user_note,
                               p_quantity,
                               p_media_type,
                               'ocm' ,
                               html_file_id);
				 END IF;
				 IF NOT(text_flag) THEN
				    -- add text
					text_flag := true;
					x_html := x_html || ' txt_id ="' || text_file_id || '"' || a;
				 END IF;
			  ELSIF(upper(p_email_format) = 'TEXT') THEN
			     IF NOT(text_flag) THEN
				    -- add text
					text_flag := true;
					x_html := x_html || ' txt_id ="' || text_file_id || '"' || a;
					l_file_name := GET_FILE_NAME(text_file_id);
				    INSERT_REQUEST_CONTENTS(
                               p_request_id,
                               p_content_id,
                               l_count_total,
                               l_file_name,
                               text_mime_name,
                               G_MIME_TBL(2),
                               'Y',
                               p_user_note,
                               p_quantity,
                               p_media_type,
                               'ocm' ,
                               text_file_id);
				 END IF;
			  ELSE
			      IF NOT (html_flag) THEN
				    -- add html
					html_flag := true;
					x_html := x_html || ' id = "' || html_file_id || '" ' || a;
					l_file_name := GET_FILE_NAME(html_file_id);
				    INSERT_REQUEST_CONTENTS(
                               p_request_id,
                               p_content_id,
                               l_count_total,
                               l_file_name,
                               html_mime_name,
                               G_MIME_TBL(1),
                               'Y',
                               p_user_note,
                               p_quantity,
                               p_media_type,
                               'ocm' ,
                               html_file_id);
				  END IF;
			  END IF;




		   ELSE  -- ELSE IF JTF_FM_UTL_V.IS_FLD_VALID(p_email_format))
		       -- Get html rendition

			    IF NOT (html_flag) THEN
				    -- add html
				  html_flag := true;
				  x_html := x_html || ' id = "' || html_file_id || '" ' || a;
				  l_file_name := GET_FILE_NAME(html_file_id);
				  INSERT_REQUEST_CONTENTS(
                             p_request_id,
                             p_content_id,
                             l_count_total,
                             l_file_name,
                             html_mime_name,
                             G_MIME_TBL(1),
                             'Y',
                             p_user_note,
                             p_quantity,
                             p_media_type,
                             'ocm' ,
                             html_file_id);

			    ELSIF NOT(text_flag) THEN
				    -- add text
				  text_flag := true;
				  x_html := x_html || ' txt_id ="' || text_file_id || '"' || a;
				  l_file_name := GET_FILE_NAME(text_file_id);
				INSERT_REQUEST_CONTENTS(
                  p_request_id,
                  p_content_id,
                  l_count_total,
                  l_file_name,
                  text_mime_name,
                  G_MIME_TBL(2),
                  'Y',
                  p_user_note,
                  p_quantity,
                  p_media_type,
                  'ocm' ,
                  text_file_id);

			   -- else get text rendition
			   ELSE
			   --else throw error
			     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                    FND_MESSAGE.set_name('JTF', 'JTF_FM_API_TXT_HTML_ABS');
                    FND_MESSAGE.Set_Token('ARG1',p_content_id);
			        FND_MESSAGE.Set_Token('ARG2',p_version);
                    FND_MSG_PUB.Add;
                 END IF;
                 RAISE  FND_API.G_EXC_ERROR;

		       END IF; -- End IF Not(html_flag
		 END IF;--END IF(JTF_FM_UTL_V.IS_FLD_VALID

		END IF; -- IF (INSTR(p_media_type, 'E') > 0 OR INSTR(p_media_type, 'F') > 0)
	x_html := x_html ||    ' content_no = "1" ' ||a;
	x_html := x_html || '></file>' ||a; -- End

	x_rend_xml := x_html;


	ELSE  -- Means there were no renditions available
	--else throw error
			   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                  FND_MESSAGE.set_name('JTF', 'JTF_FM_OCM_CONTENT_VER_ABS');
                  FND_MESSAGE.Set_Token('ARG1',p_content_id);
			      FND_MESSAGE.Set_Token('ARG2',p_version);
                  FND_MSG_PUB.Add;
               END IF;
               RAISE  FND_API.G_EXC_ERROR;

	END IF;



EXCEPTION

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR
   THEN

      --x_citem_name := NULL;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.g_false,
                                 p_count => x_msg_count,
                                 p_data  => x_msg_data
                                );
      JTF_FM_UTL_V.GET_ERROR_MESSAGE(x_msg_data);

   WHEN FND_API.G_EXC_ERROR
   THEN

      --x_citem_name := NULL;
      x_return_status := FND_API.G_RET_STS_ERROR;

      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.g_false,
                                 p_count => x_msg_count,
                                 p_data  => x_msg_data
                                );
      JTF_FM_UTL_V.GET_ERROR_MESSAGE(x_msg_data);

   WHEN OTHERS
   THEN

      --x_citem_name := NULL;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      JTF_FM_UTL_V.ADD_ERROR_MESSAGE (l_api_name, SQLERRM);

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg('JTF_FM_OCM_REND_REQ', G_PKG_NAME );
      END IF; -- IF FND_MSG_PUB.Check_Msg_Level

      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.g_false,
                                 p_count => x_msg_count,
                                 p_data  => x_msg_data
                                );
      JTF_FM_UTL_V.GET_ERROR_MESSAGE(x_msg_data);

        for i in 0..x_msg_count loop
            JTF_FM_UTL_V.PRINT_MESSAGE(FND_MSG_PUB.get(i,FND_API.G_FALSE),JTF_FM_UTL_V.G_LEVEL_PROCEDURE  ,'JTF_FM_REQUEST_GRP.GET_OCM_REND_DETAILS');

        end loop;




END GET_AND_INSERT_REQUEST_DETAILS;




--------------------------------------------------------------
-- PROCEDURE
--    GET_OCM_REND_DETAILS
-- DESCRIPTION
--    Queries IBC_CITEM_ADMIN_GRP.get_item to get details on Content Id passed
--
--
-- HISTORY
--    10/29/02  sxkrishn Create.
--    Need to figure out whether Query is attached to the document

---------------------------------------------------------------


PROCEDURE GET_OCM_REND_DETAILS
(
  p_content_id            IN NUMBER,
  p_request_id            IN NUMBER,
  p_user_note             IN VARCHAR2,
  p_quantity              IN NUMBER,
  p_media_type            IN VARCHAR2,
  p_version               IN NUMBER,
  p_content_nm            IN VARCHAR2,
  p_email_format          IN VARCHAR2,
  x_citem_name            OUT NOCOPY VARCHAR2,
  x_query_id              OUT NOCOPY NUMBER ,
  x_html                  OUT NOCOPY VARCHAR2 ,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2

)
IS
  content_item_id        NUMBER;
  citem_name             VARCHAR2(240);
  citem_version          NUMBER;
  dir_node_id            NUMBER;
  dir_node_name          VARCHAR2(240);
  dir_node_code          VARCHAR2(100);
  item_status            VARCHAR2(30);
  version_status         VARCHAR2(30);
  version_number         NUMBER;
  citem_description      VARCHAR2(32767);
  ctype_code             VARCHAR2(32767);
  ctype_name             VARCHAR2(32767);
  start_date             DATE;
  end_date               DATE;
  owner_resource_id      NUMBER;
  owner_resource_type    VARCHAR2(100);
  reference_code         VARCHAR2(100);
  trans_required         VARCHAR2(1);
  parent_item_id         NUMBER;
  locked_by              NUMBER;
  wd_restricted          VARCHAR2(32767);
  attach_file_id         NUMBER;
  attach_file_name       VARCHAR2(256);
  object_version_number  NUMBER;
  created_by             NUMBER;
  creation_date          DATE;
  last_updated_by        NUMBER;
  last_update_date       DATE;
  attribute_type_codes   JTF_VARCHAR2_TABLE_100 DEFAULT NULL;
  attribute_type_names   JTF_VARCHAR2_TABLE_300 DEFAULT NULL;
  attributes             JTF_VARCHAR2_TABLE_32767 DEFAULT NULL;
  component_citems       JTF_NUMBER_TABLE DEFAULT NULL;
  component_attrib_types JTF_VARCHAR2_TABLE_100 DEFAULT NULL;
  component_citem_names  JTF_VARCHAR2_TABLE_300 DEFAULT NULL;
  component_owner_ids    JTF_NUMBER_TABLE DEFAULT NULL;
  component_owner_types  JTF_VARCHAR2_TABLE_100 DEFAULT NULL;
  component_sort_orders  JTF_NUMBER_TABLE DEFAULT NULL;
  componenet_owner_types JTF_VARCHAR2_TABLE_100 DEFAULT NULL;

  -- New GET ITEM Params

  attach_file_ids        NUMBER;

  attach_mime_type       VARCHAR2(32767) DEFAULT NULL;
  attach_mime_name       VARCHAR2(32767) DEFAULT NULL;
  component_citem_ver_ids  JTF_NUMBER_TABLE DEFAULT NULL;
  -- End New Params
  return_status          VARCHAR2(1);
  msg_count              NUMBER;
  msg_data               VARCHAR2(32767);
  x_item_version_id      NUMBER;

  counter                NUMBER := 0;
  att_count              NUMBER;
  comp_count             NUMBER;
  l_query_id             NUMBER;

  l_count_total          NUMBER :=1;

  x_rend_xml             VARCHAR2(32767);


  x_attach_file_name     VARCHAR2(250) := '';
  x_attach_file_id       NUMBER;
  a                      VARCHAR2(1) := '';
  query_flag             VARCHAR2(1) := 'N';
  x_query_file_id        NUMBER := 0;
  x_temp_file_id         NUMBER;
  l_req_count            NUMBER := 0;
  l_api_name             CONSTANT varchar2(30) := 'GET_OCM_REND_DETAILS';
  l_full_name            CONSTANT varchar2(2000) :=
                                  G_PKG_NAME || '.' || l_api_name;
  x_file_id              NUMBER ;
  l_file_name            VARCHAR2(256);
  html_file_id           NUMBER ;
  text_file_id           NUMBER ;
  pdf_file_id            NUMBER;
  rtf_file_id            NUMBER;
  x_attach_xml           VARCHAR2(32767);
  x_delv_xml             VARCHAR2(32767);

  rend_count             NUMBER := 0;
  l_doc_type             VARCHAR2(100);
  l_file_type            VARCHAR2(100);
  l_userEnvLang          VARCHAR2(256) := USERENV('LANG');
  rendition_file_ids     JTF_NUMBER_TABLE DEFAULT NULL;
  rendition_file_names   JTF_VARCHAR2_TABLE_300 DEFAULT NULL;
  rendition_mime_types   JTF_VARCHAR2_TABLE_100 DEFAULT NULL;
  rendition_mime_names   JTF_VARCHAR2_TABLE_100 DEFAULT NULL;
  default_rendition      NUMBER;

  keywords               JTF_VARCHAR2_TABLE_100 DEFAULT NULL;


BEGIN

  JTF_FM_UTL_V.PRINT_MESSAGE('BEGIN' || l_full_name,
    JTF_FM_UTL_V.G_LEVEL_PROCEDURE, l_full_name);

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;


  -- Query to detemine if this  is a test account as the rules for determining
  -- content item versions differ between test requests and regular requests

  SELECT DISTINCT COUNT(REQUEST_ID) INTO l_req_count FROM JTF_FM_TEST_REQUESTS
    WHERE REQUEST_ID = p_request_id ;


  BEGIN

    IF l_req_count > 0 THEN

      JTF_FM_UTL_V.PRINT_MESSAGE('IT IS A TEST REQUEST:  THE COUNT IS ' ||
        l_req_count, JTF_FM_UTL_V.G_LEVEL_PROCEDURE,
        'JTF_FM_REQUEST_GRP.GET_OCM_REND_DETAILS');

      -- This is a test request, so the next thing to determine is if there
      -- was a version passed into the call.  If so, we use it, othewise
      -- we need to determine what the version is so we can find the FND_LOBS
      -- file_id.

      IF (p_version IS NOT NULL AND p_version <> FND_API.G_MISS_NUM) THEN

        x_item_version_id := p_version;

      ELSE

        -- Comment via email from sri.rangarajan@oracle.com
        -- *******************************************************************
        -- For a test request, I think the calling program should always
        -- pass the version number, it is possible that the user might be
        -- updating a version which is not the latest version, although we
        -- display only "Live Version" or "Latest version" in the coverletter
        -- summary UI, there could be a situation when two users are
        -- concurrently updating the same cover letter - one picks the live
        -- version to update and the other picks the latest version.
        --
        -- All and all this SQL would work in all cases except the one I
        -- outlined above.
        -- *******************************************************************
        -- The following gets the max version regardless of any status;
        -- item_status or version_status

        SELECT MAX(CITEM_VER_ID) INTO x_item_version_id
        FROM IBC_CITEMS_V
        WHERE CITEM_ID = TO_NUMBER(p_content_id)
        AND LANGUAGE = USERENV('LANG') ;

      END IF;

    ELSE

      -- This isn't a test request...

	    IF (p_version IS NOT NULL AND p_version <> FND_API.G_MISS_NUM) THEN

		    x_item_version_id := p_version;

	    ELSE

        -- When no version is passed in, we should use the live version.
        -- **** Query provided and approved by OCM in bug 4398752 ****
        SELECT live_citem_version_id INTO x_item_version_id
          FROM ibc_content_items
          WHERE content_item_id = p_content_id;

	    END IF;

    END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        JTF_FM_UTL_V.PRINT_MESSAGE(
          'Content is either not present in OCM or is not approved' ||
          p_content_id, JTF_FM_UTL_V.G_LEVEL_PROCEDURE, l_full_name);

        JTF_FM_UTL_V.HANDLE_ERROR('JTF_FM_OCM_NOTAPP_OR_ABS', p_content_id);
		    RAISE FND_API.G_EXC_ERROR;
  END;



  JTF_FM_UTL_V.PRINT_MESSAGE('Before calling IBC_CITEM_ADMIN_GRP.get_item',
    JTF_FM_UTL_V.G_LEVEL_PROCEDURE, l_full_name);


	BEGIN

	  IBC_CITEM_ADMIN_GRP.get_trans_item(
      x_item_version_id
      ,l_UserEnvLang
      ,FND_API.G_TRUE  -- p_skip_security added as per bug # 3409965
      ,FND_API.G_TRUE
      ,IBC_CITEM_ADMIN_GRP.G_API_VERSION_DEFAULT
      ,content_item_id
      ,citem_name
      ,citem_version
      ,dir_node_id
      ,dir_node_name
      ,dir_node_code
      ,item_status
      ,version_status
      ,citem_description
      ,ctype_code
      ,ctype_name
      ,start_date
      ,end_date
      ,owner_resource_id
      ,owner_resource_type
      ,reference_code
      ,trans_required
      ,parent_item_id
      ,locked_by
      ,wd_restricted
      ,attach_file_id
      ,attach_file_name
      ,attach_mime_type
      ,attach_mime_name
      ,rendition_file_ids
      ,rendition_file_names
      ,rendition_mime_types
      ,rendition_mime_names
      ,default_rendition
      ,object_version_number
      ,created_by
      ,creation_date
      ,last_updated_by
      ,last_update_date
      ,attribute_type_codes
      ,attribute_type_names
      ,attributes
      ,component_citems
      ,component_citem_ver_ids
      ,component_attrib_types
      ,component_citem_names
      ,component_owner_ids
      ,componenet_owner_types
      ,component_sort_orders
      ,keywords
      ,return_status
      ,msg_count
      ,msg_data);

    EXCEPTION
      WHEN OTHERS THEN
        JTF_FM_UTL_V.PRINT_MESSAGE('JTF_FM_EXCEPTION_IN_GET_ITEM name = '
          ||x_item_version_id, JTF_FM_UTL_V.G_LEVEL_PROCEDURE, l_full_name);

        JTF_FM_UTL_V.HANDLE_ERROR('JTF_FM_EXCEPTION_IN_GET_ITEM',
          x_item_version_id);

        RAISE FND_API.G_EXC_ERROR;

  END;

  if (return_status <> FND_API.G_RET_STS_SUCCESS) then

    JTF_FM_UTL_V.PRINT_MESSAGE('JTF_FM_GET_TRANS_ITEM_FAIL name = '||
      p_content_id, JTF_FM_UTL_V.G_LEVEL_PROCEDURE, l_full_name);
    JTF_FM_UTL_V.HANDLE_ERROR('JTF_FM_GET_TRANS_ITEM_FAIL', p_content_id);

    RAISE FND_API.G_EXC_ERROR;

  else

    JTF_FM_UTL_V.PRINT_MESSAGE('IN GET_OCM_REND_DETAILS  name = '||citem_name,
      JTF_FM_UTL_V.G_LEVEL_PROCEDURE, l_full_name);
    JTF_FM_UTL_V.PRINT_MESSAGE('THE REQUEST ID IS name = '|| p_request_id,
      JTF_FM_UTL_V.G_LEVEL_PROCEDURE, l_full_name);

    counter := 0;

    -- Starting to process the returns from get_trans_item()

    IF component_citems IS NOT NULL THEN

      comp_count := component_citems.COUNT;

      JTF_FM_UTL_V.PRINT_MESSAGE('com count '||
        comp_count, JTF_FM_UTL_V.G_LEVEL_PROCEDURE, l_full_name);

      LOOP

        EXIT WHEN comp_count = counter;
        counter := counter + 1;

        JTF_FM_UTL_V.PRINT_MESSAGE('component citems = ' ||
          component_citems(counter),JTF_FM_UTL_V.G_LEVEL_PROCEDURE,
          l_full_name);
        JTF_FM_UTL_V.PRINT_MESSAGE('component_attrib_types = ' ||
          component_attrib_types(counter),JTF_FM_UTL_V.G_LEVEL_PROCEDURE,
          l_full_name);
        JTF_FM_UTL_V.PRINT_MESSAGE('component_citem_names = ' ||
          component_citem_names(counter),JTF_FM_UTL_V.G_LEVEL_PROCEDURE,
          l_full_name);

        -- Check if this is a QUERY

        IF component_attrib_types(counter) = 'QUERY' THEN

          x_query_file_id :=
            GET_FILE_ID(
              TO_NUMBER(component_citem_ver_ids(counter)),
              component_citems(counter),
              p_request_id);

        ELSIF component_attrib_types(counter) = 'ATTACHMENT' THEN

          x_temp_file_id :=
            GET_FILE_ID(
              TO_NUMBER(component_citem_ver_ids(counter)),
              component_citems(counter),
              p_request_id);

          -- For the attachment, need to determine whether RTF, PDF,
          -- HTML, or text

          IF (JTF_FM_UTL_V.CONFIRM_RTF(x_temp_file_id)) THEN

            l_doc_type := G_MIME_TBL(4);
            l_file_type := ' rtf_id ="';

          ELSIF(JTF_FM_UTL_V.CONFIRM_PDF(x_temp_file_id)) THEN

            l_doc_type := G_MIME_TBL(3);
            l_file_type := ' pdf_id ="';

          ELSIF(JTF_FM_UTL_V.CONFIRM_TEXT_HTML(x_temp_file_id)) THEN

            l_doc_type := G_MIME_TBL(2);
            l_file_type := ' id ="';

          ELSE

            l_doc_type := G_MIME_TBL(1);
            l_file_type := ' id = "';

          END IF;

          l_count_total := l_count_total +1;

          -- Now build the XML string for this component

          x_attach_xml := x_attach_xml ||
            '<file ' || l_file_type || x_temp_file_id  || '" ' || a;
          x_attach_xml := x_attach_xml ||
            ' body = "no" ' || a;
          x_attach_xml := x_attach_xml ||
            ' content_no = "' || l_count_total  || '" ' ||a;
          x_attach_xml := x_attach_xml || '></file>';


				 --SPLIT_LINE(x_attach_xml,80);

         l_file_name := GET_FILE_NAME(x_temp_file_id);

         INSERT_REQUEST_CONTENTS(
            p_request_id,
            p_content_id,
            l_count_total,
            l_file_name,
            'ATTACHMENT',
            l_doc_type,
            'N',
            p_user_note,
            p_quantity,
            p_media_type,
            'ocm' ,
            x_temp_file_id);

        END IF;

			  JTF_FM_UTL_V.PRINT_MESSAGE('x_html :' || x_html,
          JTF_FM_UTL_V.G_LEVEL_PROCEDURE, l_full_name);
        JTF_FM_UTL_V.PRINT_MESSAGE('----------------------------------------',
          JTF_FM_UTL_V.G_LEVEL_PROCEDURE, l_full_name);
      END LOOP;

    END IF;

    GET_AND_INSERT_REQUEST_DETAILS(
      p_request_id,
      p_content_id,
      p_user_note,
      p_quantity,
      p_media_type,
      x_query_file_id,
      p_email_format,
      p_version,
      p_content_nm,
      rendition_file_names,
      rendition_mime_names,
      rendition_mime_types,
      rendition_file_ids ,
      x_rend_xml,
      return_status,
      msg_count,
      msg_data);

    IF (return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
		END IF;


    --Now add attachment xml and delv xml to this

	  x_html := x_rend_xml || x_attach_xml ;
	  x_html := x_html || '</files>' || a;
	  --SPLIT_LINE(x_html,80);
  end if;

  DELETE FROM JTF_FM_TEST_REQUESTS WHERE REQUEST_ID = p_request_id;

  JTF_FM_UTL_V.PRINT_MESSAGE('End GET_OCM_REND_DETAILS',
    JTF_FM_UTL_V.G_LEVEL_PROCEDURE, l_full_name);

  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      x_citem_name := NULL;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.g_false,
                                 p_count => x_msg_count,
                                 p_data  => x_msg_data
                                );
      JTF_FM_UTL_V.GET_ERROR_MESSAGE(x_msg_data);

    WHEN FND_API.G_EXC_ERROR THEN

      x_citem_name := NULL;
      x_return_status := FND_API.G_RET_STS_ERROR;

      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.g_false,
                                 p_count => x_msg_count,
                                 p_data  => x_msg_data
                                );
      JTF_FM_UTL_V.GET_ERROR_MESSAGE(x_msg_data);

   WHEN OTHERS THEN

      x_citem_name := NULL;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      JTF_FM_UTL_V.ADD_ERROR_MESSAGE (l_api_name, SQLERRM);

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg('JTF_FM_OCM_REND_REQ', G_PKG_NAME );
      END IF; -- IF FND_MSG_PUB.Check_Msg_Level

      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.g_false,
                                 p_count => x_msg_count,
                                 p_data  => x_msg_data
                                );
      JTF_FM_UTL_V.GET_ERROR_MESSAGE(x_msg_data);

      for i in 0..x_msg_count loop

        JTF_FM_UTL_V.PRINT_MESSAGE(FND_MSG_PUB.get(i,FND_API.G_FALSE),
          JTF_FM_UTL_V.G_LEVEL_PROCEDURE,
          'JTF_FM_REQUEST_GRP.GET_OCM_REND_DETAILS');

      end loop;

END GET_OCM_REND_DETAILS;



PROCEDURE GET_RENDITION_XML
(
    p_api_version           IN  NUMBER,
    p_init_msg_list         IN  VARCHAR2 ,
    p_commit                IN  VARCHAR2 ,
    p_validation_level      IN  NUMBER ,
    x_return_status         OUT NOCOPY  VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    p_content_id            IN  NUMBER,
    p_content_nm            IN  VARCHAR2 ,
    p_quantity              IN  NUMBER ,
    p_media_type            IN  VARCHAR2,
    p_printer               IN  VARCHAR2 ,
    p_email                 IN  VARCHAR2 ,
    p_fax                   IN  VARCHAR2 ,
    p_bind_var              IN JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE ,
    p_bind_val              IN JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE ,
    p_bind_var_type         IN JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE ,
    p_request_id            IN NUMBER,
    x_content_xml           OUT NOCOPY VARCHAR2,
	p_version               IN NUMBER,
	p_email_format          IN VARCHAR2
) IS
l_api_name                  CONSTANT VARCHAR2(30) := 'GET_REND_XML';
l_api_version               CONSTANT NUMBER := 1.0;
l_full_name                 CONSTANT VARCHAR2(2000) := G_PKG_NAME ||'.'|| l_api_name;
--
l_user_id                   NUMBER := -1;
l_login_user_id             NUMBER := -1;
l_login_user_status         NUMBER;
l_Error_Msg                 VARCHAR2(2000);
--
l_message                   VARCHAR2(32767) := '';
l_temp                      NUMBER := 0;
l_count                     NUMBER := 0;
l_destination               VARCHAR2(200) := NULL;
l_content_nm                VARCHAR2(200);
l_meaning                   VARCHAR2(200);
l_query_id                  NUMBER;
l_media                     VARCHAR2(30);
--
b                           VARCHAR2(1);
c                           VARCHAR2(1);
a                           VARCHAR2(2);


x_citem_name                VARCHAR2(250);
x_html                      VARCHAR2(2000);
x_query_id                  NUMBER;
p_user_note                 VARCHAR2(30) := 'USER_NOTE';
--
-- Moved all cursors to JTF_FM_UTILITY PACKAGE

BEGIN

	  JTF_FM_UTL_V.PRINT_MESSAGE('BEGIN' || l_full_name,  JTF_FM_UTL_V.G_LEVEL_PROCEDURE, l_full_name);

   -- Standard begin of API savepoint
   SAVEPOINT  Content_XML;

    -- Select end-of-line character from dual
   /*   select chr(13) cr, chr(10) lf into b, c from dual;
    a:= b||c; */
    a := '';

    -- Check for API version compatibility
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME)
   THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF; -- NOT FND_API.Compatible_API_Call

   --Initialize message list if p_init_msg_list is TRUE.
   IF FND_API.To_Boolean (p_init_msg_list)
   THEN
      FND_MSG_PUB.initialize;
   END IF; -- FND_API.To_Boolean

   -- Debug Message
   IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
   THEN
      FND_MESSAGE.Set_Name('JTF','JTF_FM_API_DEBUG_MESSAGE');
      FND_MESSAGE.Set_Token('ARG1',l_full_name||': Start');
      FND_MSG_PUB.Add;
   END IF; -- FND_MSG_PUB.Check_Msg_level

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Check if Content_id parameter is NULL. Content_id represents the
    -- unique identifier for getting the document from MES tables
    IF (p_content_id IS NULL)
    THEN
       l_Error_Msg := 'Must pass p_content_id parameter';
	     JTF_FM_UTL_V.PRINT_MESSAGE('Must pass p_content_id parameter ' ,JTF_FM_UTL_V.G_LEVEL_PROCEDURE, l_full_name);


       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
       THEN
          FND_MESSAGE.set_name('JTF', 'JTF_FM_API_MISSING_CONTENT_ID');
          FND_MSG_PUB.Add;
       END IF; -- IF FND_MSG_PUB.check_msg_level

       RAISE  FND_API.G_EXC_ERROR;

   -- check if the media_type paramater is NULL. No point in processing a
   -- request without a media_type
    ELSIF (p_media_type IS NULL) -- IF (p_media_type IS NULL)
    THEN
        l_Error_Msg := 'Must pass p_media_type parameters';
		JTF_FM_UTL_V.PRINT_MESSAGE('Must pass p_media_type parameter '  ,JTF_FM_UTL_V.G_LEVEL_PROCEDURE, l_full_name);

        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('JTF', 'JTF_FM_API_MISSING_MEDIA_TYPE');
           FND_MSG_PUB.Add;
        END IF; -- IF FND_MSG_PUB.check_msg_level

        RAISE  FND_API.G_EXC_ERROR;
    --    Must pass a request_type

    ELSIF (p_request_id IS NULL) -- IF (p_request_id IS NULL)
    THEN
        l_Error_Msg := 'Must pass p_request_id parameters';
		JTF_FM_UTL_V.PRINT_MESSAGE('Must pass p_request_id parameter '  ,JTF_FM_UTL_V.G_LEVEL_PROCEDURE, l_full_name);

        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
         FND_MESSAGE.set_name('JTF', 'JTF_FM_API_MISSING_REQUEST_ID');
           FND_MSG_PUB.Add;
      END IF;   -- IF _FND_MSG_PUB.check_msg_level

       RAISE  FND_API.G_EXC_ERROR;
    ELSE -- IF (p_content_id IS NULL)

      -- Start forming the XML Request for the content

        l_message := '<item>'||a;

        l_message := l_message||' <media_type>'||a;

        -- Identify the media types requested
        IF (INSTR(p_media_type, 'PRINTER') > 0)
        THEN
           IF p_printer = FND_API.G_MISS_CHAR
           THEN
               l_message := l_message||'<printer>'||null||'</printer> '||a;
           ELSE -- IF p_printer
               l_message := l_message||'<printer>'||p_printer||'</printer> '||a;
           END IF; -- IF p_printer

            l_destination := l_destination ||', '|| p_printer;
            l_temp := l_temp + 1;
        END IF; -- IF (INSTR(p_media_type,

        IF (INSTR(p_media_type, 'EMAIL') > 0)
        THEN
           IF p_email = FND_API.G_MISS_CHAR
           THEN
               l_message := l_message||'<email>'||null||'</email> '||a;
           ELSE   -- IF p_email
               l_message := l_message||'<email>'||p_email||'</email> '||a;
           END IF; -- IF p_email

            l_destination := l_destination ||', '|| p_email;
            l_temp := l_temp + 1;
         END IF;   -- IF (INSTR(p_media_type

         IF (INSTR(p_media_type, 'FAX') > 0)
         THEN
            IF p_fax = FND_API.G_MISS_CHAR
            THEN
               l_message := l_message||'<fax>'||null||'</fax> '||a;
            ELSE   -- IF p_fax
               l_message := l_message||'<fax>'||p_fax||'</fax> '||a;
            END IF; -- IF p_fax

            l_destination := l_destination ||', '|| p_fax;
            l_temp := l_temp + 1;
         END IF; -- IF (INSTR(p_media_type

        -- Check if atleast one valid media type has been specified
      IF (l_temp = 0)
      THEN
           l_Error_Msg := 'Invalid media type specified. Allowed media_types are EMAIL, FAX, PRINTER';
		 JTF_FM_UTL_V.PRINT_MESSAGE('Invalid media type specified. Allowed media_types are EMAIL, FAX, PRINTER'  ,JTF_FM_UTL_V.G_LEVEL_PROCEDURE, l_full_name);

         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('JTF', 'JTF_FM_API_INVALID_MEDIATYPE');
                FND_MSG_PUB.Add;
         END IF; -- IF FND_MSG_PUB.check_msg_level

         RAISE  FND_API.G_EXC_ERROR;

      END IF; -- IF (l_temp = 0)

        l_message := l_message||'</media_type> '||a;

      -- New XML code added by sxkrishn 10-25-02
	  	 JTF_FM_UTL_V.PRINT_MESSAGE('Right after media has been formed'  ,JTF_FM_UTL_V.G_LEVEL_PROCEDURE, l_full_name);






	    l_message := l_message||'<item_content id="'|| p_content_id || '" '||a;

        l_message := l_message||' quantity="'||to_char(p_quantity)||'" user_note="User_Note"  source ="ocm" '||a;
		IF p_version <> FND_API.G_MISS_NUM THEN
		   l_message := l_message||' version_id="'||p_version ||'"'||a;
		END IF;
		l_message := l_message||'>' || a;


        l_media := JTF_FM_UTL_V.GET_MEDIA(l_message);
		--dbms_output.PUT_LINE('media type is :' || l_media);


	    -- Assuming that this call will be made only for OCM contents
	     GET_OCM_REND_DETAILS(p_content_id,
                             p_request_id,
							 p_user_note,
							 p_quantity,
							 l_media,
							 p_version,
							 p_content_nm,
							 p_email_format,
                             x_citem_name ,
							 x_query_id,
                             x_html,
                             x_return_status ,
                             x_msg_count ,
                             x_msg_data
                             );
			IF(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
			   	 JTF_FM_UTL_V.PRINT_MESSAGE('Item present in OCM Repository'  ,JTF_FM_UTL_V.G_LEVEL_PROCEDURE, l_full_name);

			   l_message := l_message|| x_html;
			ELSIF(x_return_status = FND_API.G_RET_STS_ERROR) THEN
			       RAISE  FND_API.G_EXC_ERROR;
			ELSE
			        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;

			  JTF_FM_UTL_V.PRINT_MESSAGE('Item NOT present in OCM Repository',JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name);
			END IF;



         IF (p_bind_var.count <> 0) THEN
		      l_message := l_message||'<bind> '||a;
			  l_message := l_message||'<record> '||a;
            FOR i IN 1..p_bind_var.count LOOP

                     l_message := l_message||'<bind_var bind_type="'
                                  ||JTF_FM_REQUEST_GRP.REPLACE_TAG(p_bind_var_type(i));
                     l_message := l_message||'" bind_object="'
                                  ||JTF_FM_REQUEST_GRP.REPLACE_TAG(p_bind_var(i))||'" > '
                                  ||JTF_FM_REQUEST_GRP.REPLACE_TAG(p_bind_val(i))||'</bind_var>'||a;

            END LOOP;   -- FOR i IN
			  l_message := l_message||'</record> '||a;
			  l_message := l_message||'</bind> '||a;
         END IF; -- IF (p_bind_var.count

	  l_message := l_message||'</item_content> '||a;
      l_message := l_message||'</item> '||a;

	   --dbms_output.put_line('created the XML');
      -- End of the XML Request

      --SPLIT_LINE(l_message,80);

      x_content_xml := l_message;

   END IF; -- IF (p_content_id IS NULL)

   -- Success message
   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
      FND_MESSAGE.Set_Name('JTF', 'JTF_FM_API_SUCCESS_MESSAGE');
      FND_MESSAGE.Set_Token('ARG1', l_full_name);
      FND_MSG_PUB.Add;
   END IF; -- IF FND_MSG_PUB.Check_Msg_Level

   --Standard check of commit

   IF FND_API.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
   END IF; -- IF FND_API.To_Boolean

   -- Debug Message
   IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      FND_MESSAGE.Set_Name('FFM','JTF_FM_API_DEBUG_MESSAGE');
      FND_MESSAGE.Set_Token('ROW',l_full_name||': End');
      FND_MSG_PUB.Add;
   END IF; -- IF FND_MSG_PUB.Check_Msg_level

   --Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.g_false,
                              p_count => x_msg_count,
                              p_data  => x_msg_data
                             );

   EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Content_XML;
      x_content_xml := NULL;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       JTF_FM_UTL_V.ADD_ERROR_MESSAGE (l_api_name, l_Error_Msg);
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.g_false,
                                 p_count => x_msg_count,
                                 p_data  => x_msg_data
                                );
      JTF_FM_UTL_V.GET_ERROR_MESSAGE(x_msg_data);

   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Content_XML;
      x_content_xml := NULL;
      x_return_status := FND_API.G_RET_STS_ERROR;
      JTF_FM_UTL_V.ADD_ERROR_MESSAGE (l_api_name, l_Error_Msg);
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.g_false,
                                 p_count => x_msg_count,
                                 p_data  => x_msg_data
                                );
      JTF_FM_UTL_V.GET_ERROR_MESSAGE(x_msg_data);

   WHEN OTHERS THEN
      ROLLBACK TO Content_XML;
      x_content_xml := NULL;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      JTF_FM_UTL_V.ADD_ERROR_MESSAGE (l_api_name, SQLERRM);

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg
         (G_PKG_NAME, l_api_name);
      END IF; -- IF FND_MSG_PUB.Check_Msg_Level

      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.g_false,
                                 p_count => x_msg_count,
                                 p_data  => x_msg_data
                                );
      JTF_FM_UTL_V.GET_ERROR_MESSAGE(x_msg_data);

      JTF_FM_UTL_V.PRINT_MESSAGE('END ' || l_full_name , JTF_FM_UTL_V.G_LEVEL_PROCEDURE, l_full_name);

END Get_RENDITION_XML;






PROCEDURE create_fulfillment_rendition
(
 	p_init_msg_list        		IN	   VARCHAR2 := FND_API.G_FALSE,
	p_api_version          		IN 	   NUMBER,
	p_commit		            IN	   VARCHAR2 := FND_API.G_FALSE,
    p_order_header_rec       	IN     JTF_Fulfillment_PUB.ORDER_HEADER_REC_TYPE,
	p_order_line_tbl         	IN     JTF_Fulfillment_PUB.ORDER_LINE_TBL_TYPE,
    p_fulfill_electronic_rec    IN 	   JTF_FM_OCM_REQUEST_GRP.FULFILL_ELECTRONIC_REC_TYPE,
    p_request_type         		IN     VARCHAR2,
	x_return_status		        OUT    NOCOPY VARCHAR2,
	x_msg_count		            OUT    NOCOPY NUMBER,
	x_msg_data		            OUT    NOCOPY VARCHAR2,
	x_order_header_rec	        OUT    NOCOPY ASO_ORDER_INT.order_header_rec_type,
    x_request_history_id     	OUT    NOCOPY NUMBER
)
IS

	l_api_name			        CONSTANT VARCHAR2(30)	:= 'create_fulfillment_rendition';
	l_full_name            		CONSTANT VARCHAR2(100) := G_PKG_NAME ||'.'|| l_api_name;
	l_api_version   		    CONSTANT NUMBER 	:= 1.0;
	l_init_msg_list 	  		VARCHAR2(2) := FND_API.G_FALSE;
	l_validation_level          NUMBER := FND_API.G_VALID_LEVEL_FULL;
	l_content_xml   			VARCHAR2(32767);
	l_content_xml1   			VARCHAR2(32767);
	l_bind_var      			JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
	l_bind_val      			JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
	l_bind_var_type 			JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
	l_content_id    			NUMBER;
	l_per_user_history  		VARCHAR2(2);
	l_subject       			VARCHAR2(255);
	l_quantity      			NUMBER := 1;
	l_return_status  			VARCHAR2(200);
	l_request_id    			NUMBER;
	l_request_history_id   		NUMBER;
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

	-- If loggin is set at the highest level, record the in params to the API
	JTF_FM_UTL_V.PRINT_MESSAGE('In params-Create_fulfillment Rendition' || l_full_name,JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name);
	JTF_FM_UTL_V.PRINT_MESSAGE('template_id: ' || p_fulfill_electronic_rec.template_id,JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name);
	JTF_FM_UTL_V.PRINT_MESSAGE('version_id: ' || p_fulfill_electronic_rec.version_id,JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name);
	JTF_FM_UTL_V.PRINT_MESSAGE('object_type: ' || p_fulfill_electronic_rec.object_type,JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name);
	JTF_FM_UTL_V.PRINT_MESSAGE('object_id: ' || p_fulfill_electronic_rec.object_id,JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name);
	JTF_FM_UTL_V.PRINT_MESSAGE('source_code: ' || p_fulfill_electronic_rec.source_code,JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name);
	JTF_FM_UTL_V.PRINT_MESSAGE('source_code_id: ' || p_fulfill_electronic_rec.source_code_id,JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name);
	JTF_FM_UTL_V.PRINT_MESSAGE('requestor_type: ' || p_fulfill_electronic_rec.requestor_type,JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name);
	JTF_FM_UTL_V.PRINT_MESSAGE('requestor_id: ' || p_fulfill_electronic_rec.requestor_id,JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name);
	JTF_FM_UTL_V.PRINT_MESSAGE('server_group: ' || p_fulfill_electronic_rec.server_group,JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name);
	JTF_FM_UTL_V.PRINT_MESSAGE('schedule_date: ' || p_fulfill_electronic_rec.schedule_date,JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name);
	JTF_FM_UTL_V.PRINT_MESSAGE('media_types: ' || p_fulfill_electronic_rec.media_types,JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name);
	JTF_FM_UTL_V.PRINT_MESSAGE('archive: ' || p_fulfill_electronic_rec.archive,JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name);
	JTF_FM_UTL_V.PRINT_MESSAGE('log_user_ih: ' || p_fulfill_electronic_rec.log_user_ih,JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name);
	JTF_FM_UTL_V.PRINT_MESSAGE('request_type: ' || p_fulfill_electronic_rec.request_type,JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name);
	JTF_FM_UTL_V.PRINT_MESSAGE('language_code: ' || p_fulfill_electronic_rec.language_code,JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name);
	JTF_FM_UTL_V.PRINT_MESSAGE('profile_id: ' || p_fulfill_electronic_rec.profile_id,JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name);
	JTF_FM_UTL_V.PRINT_MESSAGE('order_id: ' || p_fulfill_electronic_rec.order_id,JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name);
	JTF_FM_UTL_V.PRINT_MESSAGE('collateral_id: ' || p_fulfill_electronic_rec.collateral_id,JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name);
	JTF_FM_UTL_V.PRINT_MESSAGE('subject: ' || p_fulfill_electronic_rec.subject,JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name);

	-- Following have been commented out as they may exceed the limits set:
	--JTF_FM_UTL_V.PRINT_MESSAGE('party_id: ' || p_fulfill_electronic_rec.party_id,JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name);
	--JTF_FM_UTL_V.PRINT_MESSAGE('email: ' || p_fulfill_electronic_rec.email,JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name);
	--JTF_FM_UTL_V.PRINT_MESSAGE('fax: ' || p_fulfill_electronic_rec.fax,JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name);
	--JTF_FM_UTL_V.PRINT_MESSAGE('printer: ' || p_fulfill_electronic_rec.printer,JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name);
	--JTF_FM_UTL_V.PRINT_MESSAGE('bind_values: ' || p_fulfill_electronic_rec.bind_values,JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name);
	--JTF_FM_UTL_V.PRINT_MESSAGE('bind_names: ' || p_fulfill_electronic_rec.bind_names,JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name);
	--JTF_FM_UTL_V.PRINT_MESSAGE('extended_header: ' || p_fulfill_electronic_rec.extended_header,JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name);

	JTF_FM_UTL_V.PRINT_MESSAGE('email_text: ' || p_fulfill_electronic_rec.email_text,JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name);
	JTF_FM_UTL_V.PRINT_MESSAGE('content_name: ' || p_fulfill_electronic_rec.content_name,JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name);
	JTF_FM_UTL_V.PRINT_MESSAGE('content_type: ' || p_fulfill_electronic_rec.content_type,JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name);
	JTF_FM_UTL_V.PRINT_MESSAGE('stop_list_bypass: ' || p_fulfill_electronic_rec.stop_list_bypass,JTF_FM_UTL_V.G_LEVEL_PROCEDURE,l_full_name);




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
			JTF_FM_UTL_V.PRINT_MESSAGE(l_Error_msg, JTF_FM_UTL_V.G_LEVEL_PROCEDURE, l_full_name);
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
			 	     JTF_FM_UTL_V.PRINT_MESSAGE(l_Error_msg, JTF_FM_UTL_V.G_LEVEL_PROCEDURE, l_full_name);
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
   			 	      JTF_FM_UTL_V.PRINT_MESSAGE(l_Error_msg, JTF_FM_UTL_V.G_LEVEL_PROCEDURE, l_full_name);
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
                       JTF_FM_UTL_V.PRINT_MESSAGE(l_Error_msg, JTF_FM_UTL_V.G_LEVEL_PROCEDURE, l_full_name);
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
			JTF_FM_UTL_V.PRINT_MESSAGE(l_Error_msg, JTF_FM_UTL_V.G_LEVEL_PROCEDURE, l_full_name);
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
   	   	history table. Reason. GET_FILE_ID  should
   	   	know about REQUEST_TYPE 'T'
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

         ***********/
		 GET_RENDITION_XML(
		  l_api_version,
		  l_init_msg_list ,
          l_commit  ,
          l_validation_level ,
		  l_return_status,
          l_msg_count,
          l_msg_data,
          l_content_id,
          l_content_nm,
          l_quantity,
          l_var_media_type,
          l_printer_val,
          l_email_val,
          l_fax_val,
          l_bind_var,
          l_bind_val,
          l_bind_var_type,
          x_request_history_id,
          l_content_xml1,
          p_fulfill_electronic_rec.version_id,
		  nvl(p_fulfill_electronic_rec.email_format,'BOTH')
		  );

	      JTF_FM_UTL_V.PRINT_MESSAGE('Get_Rendition_XML  Return Status is ' || l_return_status,
	      				  JTF_FM_UTL_V.G_LEVEL_STATEMENT,l_full_name);

     	 l_content_xml := l_content_xml1;

     	 IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
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
					 p_media              => p_fulfill_electronic_rec.media_types,
            		 p_content_xml        => l_content_xml,
					 x_return_status      => l_return_status,
					 x_test_xml           => x_test_xml

            		) ;
			JTF_FM_UTL_V.PRINT_MESSAGE('GET_TEST_XML Return Status is ' || l_return_status,
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

  END CREATE_FULFILLMENT_RENDITION;
END JTF_FM_OCM_REND_REQ;

/
