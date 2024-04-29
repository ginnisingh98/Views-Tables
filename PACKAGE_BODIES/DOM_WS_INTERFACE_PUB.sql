--------------------------------------------------------
--  DDL for Package Body DOM_WS_INTERFACE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DOM_WS_INTERFACE_PUB" AS
/*$Header: DOMPITFB.pls 120.8.12010000.2 2009/04/20 14:33:38 nrayi ship $ */

-- ------------------------------------------------------------
-- -------------- Global variables and constants --------------
-- ------------------------------------------------------------
   G_PKG_NAME                CONSTANT  VARCHAR2(30) := 'DOM_WS_INTERFACE_PUB';
   G_CURRENT_USER_ID                   NUMBER       :=  FND_GLOBAL.USER_ID;
   G_CURRENT_LOGIN_ID                  NUMBER       :=  FND_GLOBAL.LOGIN_ID;
   G_DOM_INTERFACE_JSP                 VARCHAR2(80) :=  '/OA_HTML/DOMInterface.jsp';

-- ---------------------------------------------------------------------
   -- For debugging purposes.
   PROCEDURE mdebug (msg IN varchar2) IS
     BEGIN
      --dd_debug('DOM WS INTERFACE ' || msg);
      --dbms_output.put_line('DOM WS INTERFACE :' || msg);
      null;
     END mdebug;
-- ---------------------------------------------------------------------


procedure call_dom_interface_jsp
(
  p_param_query_string  IN VARCHAR2
  ,x_return_status	     OUT	NOCOPY VARCHAR2
  ,x_msg_count		       OUT	NOCOPY NUMBER
  ,x_msg_data		         OUT	NOCOPY VARCHAR2
)
IS

	 l_proxy varchar2(80);
   l_request		UTL_HTTP.REQ;
   l_response		UTL_HTTP.RESP;
   l_name		VARCHAR2(255);
   l_value		VARCHAR2(1023);
   v_msg		VARCHAR2(80);
   v_url		VARCHAR2(32767) := '/';
   l_api_name  varchar2(80):='call_dom_interface_jsp';

   cookies		UTL_HTTP.COOKIE_TABLE;
   my_session_id	BINARY_INTEGER;
   secure		VARCHAR2(1);
   proxy		VARCHAR2(250);
   -- For bug 8401333
   l_count NUMBER ;
   l_profile_option_value VARCHAR2(240);
   -- For bug 8401333


BEGIN
    -- For bug 8401333
    SELECT profile_option_value INTO l_profile_option_value FROM fnd_profile_option_values WHERE profile_option_id =
    (select profile_option_id FROM fnd_profile_options WHERE profile_option_name = 'EGO_ENABLE_PLM')
    AND LEVEL_ID =10001 AND LEVEL_VALUE=0;

    IF (l_profile_option_value = '1') THEN
      SELECT Count(*) INTO l_count FROM dom_repositories WHERE protocol = 'WEBSERVICES';

       IF(l_count > 0) THEN
       -- For bug 8401333

	   SELECT profile_option_value INTO proxy
	   FROM fnd_profile_option_values vl ,  FND_PROFILE_OPTIONS pr
		WHERE vl.profile_option_id = pr.profile_option_id
		AND pr.PROFILE_OPTION_NAME = 'WEB_PROXY_HOST';

	--proxy := 'http://www-proxy.us.oracle.com';


    UTL_HTTP.Set_Response_Error_Check ( enable => true );

    UTL_HTTP.Set_Detailed_Excp_Support ( enable => true );

/*
    UTL_HTTP.Set_Proxy (
        proxy => proxy,
        no_proxy_domains => '');
        */

        v_url := fnd_profile.value('APPS_FRAMEWORK_AGENT');
--        v_url := 'http://qapache.us.oracle.com:6482';

        v_url := v_url || G_DOM_INTERFACE_JSP||'?'||p_param_query_string;

    l_request := Utl_Http.Begin_Request (
                    url => v_url,
                    method => 'POST',
                    http_version => 'HTTP/1.1'
                );


    l_response := UTL_HTTP.Get_Response ( r => l_request );
    FOR i IN 1..UTL_HTTP.Get_Header_Count ( r => l_response )
        LOOP
          UTL_HTTP.Get_Header (
          r => l_response,
          n => i,
          name => l_name,
          value => l_value );
        END LOOP;
        BEGIN
        LOOP
          UTL_HTTP.Read_Text (
          r => l_response,
          data => v_msg );

        END LOOP;
        EXCEPTION WHEN UTL_HTTP.End_Of_Body then null;
      END;

      UTL_HTTP.End_Response ( r => l_response );

      x_return_status := FND_API.G_RET_STS_SUCCESS;


      FND_MSG_PUB.Count_And_Get
        (  	p_count        =>      x_msg_count,
            p_data         =>      x_msg_data
        );

	END IF;

        END IF;
      EXCEPTION
          /*
            The exception handling illustrates the use of "pragma-ed" exceptions
            like Utl_Http.Http_Client_Error. In a realistic example, the program
            would use these when it coded explicit recovery actions.
            Request_Failed is raised for all exceptions after calling
            Utl_Http.Set_Detailed_Excp_Support ( enable=>false )

            And it is NEVER raised after calling with enable=>true
          */
          WHEN UTL_HTTP.Request_Failed THEN
            mdebug ( 'Request_Failed: ' || Utl_Http.Get_Detailed_Sqlerrm );
          /* raised by URL http://xxx.oracle.com/ */
          WHEN UTL_HTTP.Http_Server_Error THEN
            mdebug ( 'Http_Server_Error: ' || Utl_Http.Get_Detailed_Sqlerrm );
          /* raised by URL /xxx */
          when UTL_HTTP.Http_Client_Error THEN
            mdebug ( 'Http_Client_Error: ' || Utl_Http.Get_Detailed_Sqlerrm );
          /* code for all the other defined exceptions you can recover from */

           WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO DOM_ADD_OFO_GROUP_MEMBER;
            mdebug('.  CREATE_RELATIONSHIP:  Ending : Returning ''FND_API.G_EXC_ERROR''');
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MSG_PUB.Count_And_Get
                (  	p_count        =>      x_msg_count,
                    p_data         =>      x_msg_data
                );
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
             ROLLBACK TO EGO_CREATE_RELATIONSHIP;
                 mdebug('.  CREATE_RELATIONSHIP:  Ending : Returning ''FND_API.G_EXC_UNEXPECTED_ERROR''');
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            FND_MSG_PUB.Count_And_Get
                (  	p_count        =>      x_msg_count,
                    p_data         =>      x_msg_data
                );
        WHEN OTHERS THEN
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            IF 	FND_MSG_PUB.Check_Msg_Level
                (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
            THEN
                    FND_MSG_PUB.Add_Exc_Msg
                        (	G_PKG_NAME,
                            l_api_name
                    );
            END IF;
            FND_MSG_PUB.Count_And_Get
                (  	p_count        =>      x_msg_count,
                    p_data         =>      x_msg_data
                );
            mdebug (SQLERRM);


END;



----------------------------------------------------------------------------
-- A. Add_OFO_Group_Member
----------------------------------------------------------------------------

procedure Add_OFO_Group_Member (
   p_api_version	IN	NUMBER,
   p_init_msg_list	IN	VARCHAR2,
   p_commit		IN	VARCHAR2,
   p_group_id      	IN	NUMBER,
   p_member_id      	IN	NUMBER,
   x_return_status	OUT	NOCOPY VARCHAR2,
   x_msg_count		OUT	NOCOPY NUMBER,
   x_msg_data		OUT	NOCOPY VARCHAR2
   ) IS
    ------------------------------------------------------------------------
    -- Start OF comments
    -- API name  : Add_OFO_Group_Member
    -- TYPE      : Public
    -- Pre-reqs  : None
    -- FUNCTION  : Add a member to the corresponding OFO Group.
    --
    --
    -- Parameters:
    --     IN    : p_api_version		IN  NUMBER	(required)
    --			API Version of this procedure
    --             p_init_msg_level	IN  VARCHAR2	(optional)
    --                  DEFAULT = FND_API.G_FALSE
    --                  Indicates whether the message stack needs to be cleared
    --             p_commit		IN  VARCHAR2	(optional)
    --                  DEFAULT = FND_API.G_FALSE
    --                  Indicates whether the data should be committed
    --             p_group_id		IN  NUMBER	(required)
    --			Group to which the member is being added
    --			Eg., A Group
    --             p_member_id	IN  VARCHAR2	(required)
    --			Member which is to be added
    --			Eg., PERSON
    --
    --     OUT   : x_return_status	OUT  NUMBER
    --			Result of all the operations
    --                    FND_API.G_RET_STS_SUCCESS if success
    --                    FND_API.G_RET_STS_ERROR if error
    --                    FND_API.G_RET_STS_UNEXP_ERROR if unexpected error
    --             x_msg_count		OUT  NUMBER
    --			number of messages in the message list
    --             x_msg_data		OUT  VARCHAR2
    --			  if number of messages is 1, then this parameter
    --			contains the message itself
    --
    -- Called From:
    --    ego_party_pub.add_group_member
    --
    -- Version: Current Version 1.0
    -- Previous Version :  None
    -- Notes  :
    --
    -- END OF comments
    ------------------------------------------------------------------------

     l_Sysdate			   DATE		:= Sysdate;

     l_api_name		CONSTANT   VARCHAR2(30)	:= 'Add_OFO_Group_Member';
     -- On addition of any Required parameters the major version needs
     -- to change i.e. for eg. 1.X to 2.X.
     -- On addition of any Optional parameters the minor version needs
     -- to change i.e. for eg. X.6 to X.7.
     l_api_version	CONSTANT    NUMBER 	:= 1.0;

     -- General variables

     l_success		BOOLEAN;       --boolean for descr. flex valiation

     l_group_name   VARCHAR2(100);
     l_member_name  VARCHAR2(100); --my wild assumed length
     l_logged_in    VARCHAR2(100);
     l_name		VARCHAR2(255);
     l_value		VARCHAR2(1023);
     v_msg		VARCHAR2(80);


     l_param_query_string  VARCHAR2(2000);

     CURSOR user_info is
	SELECT USER_NAME FROM fnd_user WHERE person_party_id = p_member_id;

  BEGIN
    -- Standard Start of API savepoint
    mdebug('.  ADD_OFO_GROUP_MEMBER:  ADD_OFO_GROUP_MEMBER .....1...... ');
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                          p_api_version,
					  l_api_name,
					  G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize API message list if necessary.
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( NVL(p_init_msg_list, 'F') ) THEN
    	FND_MSG_PUB.initialize;
    END IF;

    mdebug(' in DOM WS interface ' || p_group_id || ' ' || p_member_id);

    SELECT GROUP_NAME INTO l_group_name FROM EGO_GROUPS_V WHERE GROUP_ID = p_group_id;

    --SELECT MEMBER_USER_NAME INTO l_member_name FROM EGO_GROUP_MEMBERS_V WHERE GROUP_ID = p_group_id AND  MEMBER_PERSON_ID = p_member_id;
    --SELECT USER_NAME INTO l_member_name FROM fnd_user WHERE person_party_id = p_member_id;
    --SELECT USER_NAME INTO l_logged_in FROM FND_USER WHERE USER_ID = G_CURRENT_USER_ID;

    FOR info_rec IN user_info LOOP
	    l_member_name := info_rec.USER_NAME;
	    SELECT us.user_name INTO l_logged_in
	    FROM hz_parties hz, fnd_user us
	    WHERE hz.created_by =   us.USER_ID
	    AND party_id = p_group_id;


	    mdebug ( 'l_group_name : ' || l_group_name );
	    mdebug ( 'l_member_name : ' || l_member_name );
	    mdebug ( 'l_logged_in : ' || l_logged_in );

	    l_param_query_string:='opName=addUserToGroup&groupName=' || l_group_name || '&memberName=' || l_member_name || '&loggedInUser=' || l_logged_in;
	    call_dom_interface_jsp
	    (
	      p_param_query_string  =>l_param_query_string
	      ,x_return_status	     =>x_return_status
	      ,x_msg_count		       =>x_msg_count
	      ,x_msg_data		         =>x_msg_data
	    );

    END LOOP;

END Add_OFO_Group_Member;

--------------------------------------------------------------
procedure Update_Files_Document_Status (
   p_api_version	      IN	NUMBER,
   p_service_url        IN	VARCHAR2,
   p_document_id      	IN	NUMBER,
   p_status           	IN	VARCHAR2,
   p_login_user_name    IN	VARCHAR2,
   x_return_status	    OUT	NOCOPY VARCHAR2,
   x_msg_count		      OUT	NOCOPY NUMBER,
   x_msg_data		        OUT	NOCOPY VARCHAR2
   )
   IS

   l_api_name		CONSTANT   VARCHAR2(30)	:= 'Update_Files_Document_Status';
   -- On addition of any Required parameters the major version needs
   -- to change i.e. for eg. 1.X to 2.X.
   -- On addition of any Optional parameters the minor version needs
   -- to change i.e. for eg. X.6 to X.7.
   l_api_version	CONSTANT    NUMBER 	:= 1.0;

   -- General variables

   l_success		BOOLEAN;
   l_param_query_string  VARCHAR2(2000);

  BEGIN
    -- Standard Start of API savepoint
    IF NOT FND_API.Compatible_API_Call (l_api_version,p_api_version,l_api_name,G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    l_param_query_string:='opName=updateDocStatus&docId='||p_document_id||'&status='||p_status||'&serviceUrl='||p_service_Url||'&loggedInUser='||p_login_user_name;
    call_dom_interface_jsp
    (
      p_param_query_string  =>l_param_query_string
      ,x_return_status	     =>x_return_status
      ,x_msg_count		       =>x_msg_count
      ,x_msg_data		         =>x_msg_data
    );

END Update_Files_Document_Status;

--------------------------------------------------------------

procedure Grant_Attachments_OCSRole (
   p_api_version	    IN	NUMBER,
   p_service_url        IN	VARCHAR2,
   p_family_id      	IN	NUMBER,
   p_role           	IN	VARCHAR2,
   p_user_name          IN	VARCHAR2,
   p_user_login         IN	VARCHAR2,
   x_return_status	    OUT	NOCOPY VARCHAR2,
   x_msg_count		      OUT	NOCOPY NUMBER,
   x_msg_data		        OUT	NOCOPY VARCHAR2
   )
   IS


   l_api_name		CONSTANT   VARCHAR2(30)	:= 'Grant_Attachments_OCSRole';
   -- On addition of any Required parameters the major version needs
   -- to change i.e. for eg. 1.X to 2.X.
   -- On addition of any Optional parameters the minor version needs
   -- to change i.e. for eg. X.6 to X.7.
   l_api_version	CONSTANT    NUMBER 	:= 1.0;

   -- General variables

   l_success		BOOLEAN;
   l_param_query_string  VARCHAR2(2000);

  BEGIN

    -- Standard Start of API savepoint
    IF NOT FND_API.Compatible_API_Call (l_api_version,p_api_version,l_api_name,G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

--    code_debug('YSIREESH: User id: '+FND_PROFILE.Value('USER_ID'));
    l_param_query_string:='opName=grantAttachmentsOCSRole&familyId='||p_family_id||'&role='||p_role||'&serviceUrl=' || p_service_url || '&userToRole='||p_user_name||'&loggedInUser='||p_user_login;
    call_dom_interface_jsp
    (
      p_param_query_string  =>l_param_query_string
      ,x_return_status	     =>x_return_status
      ,x_msg_count		       =>x_msg_count
      ,x_msg_data		         =>x_msg_data
    );

END Grant_Attachments_OCSRole;

procedure Remove_Attachments_OCSRole (
   p_api_version	    IN	NUMBER,
   p_service_url        IN	VARCHAR2,
   p_family_id      	IN	NUMBER,
   p_role           	IN	VARCHAR2,
   p_user_name          IN	VARCHAR2,
   p_user_login         IN	VARCHAR2,
   x_return_status	    OUT	NOCOPY VARCHAR2,
   x_msg_count		      OUT	NOCOPY NUMBER,
   x_msg_data		        OUT	NOCOPY VARCHAR2
   )
   IS

   l_api_name		CONSTANT   VARCHAR2(30)	:= 'Remove_Attachments_OCSRole';
   -- On addition of any Required parameters the major version needs
   -- to change i.e. for eg. 1.X to 2.X.
   -- On addition of any Optional parameters the minor version needs
   -- to change i.e. for eg. X.6 to X.7.
   l_api_version	CONSTANT    NUMBER 	:= 1.0;

   -- General variables

   l_success		BOOLEAN;
   l_param_query_string  VARCHAR2(2000);

  BEGIN
    -- Standard Start of API savepoint
    IF NOT FND_API.Compatible_API_Call (l_api_version,p_api_version,l_api_name,G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    l_param_query_string:='opName=grantAttachmentsOCSRole&familyId='||p_family_id||'&role='||p_role||'&serviceUrl=' || p_service_url || '&userToRole='||p_user_name||'&loggedInUser='||p_user_login||'&addOrRemove=REMOVE';
    call_dom_interface_jsp
    (
      p_param_query_string  =>l_param_query_string
      ,x_return_status	     =>x_return_status
      ,x_msg_count		       =>x_msg_count
      ,x_msg_data		         =>x_msg_data
    );

END Remove_Attachments_OCSRole;




END DOM_WS_INTERFACE_PUB;

/
