--------------------------------------------------------
--  DDL for Package Body IEM_TAGPROCESS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_TAGPROCESS_PUB" AS
/* $Header: iemptagb.pls 120.2 2006/06/27 14:36:41 pkesani noship $ */

--
--
-- Purpose: Maintain Tag Process
--
-- MODIFICATION HISTORY
-- Person      Date         Comments
--  Liang Xia  3/24/2002    Created
--  Liang Xia  11/18/2002   Modified getEncryptId() to return null
--                          for Acknowledgement account.
--  Liang Xia  12/6/2002    Fixed GSCC warning: NOCOPY, no G_MISS...
--  Liang Xia  01/15/2003   Fixed bug 2752169:changed jtf_rs_resource_members_vl to jtf_rs_resource_members
--  Liang Xia  09/18/2003   Fixed bug 3130813: added validation on User-responsibility, and end_date_active for
--                          JTF_RS_GROUPS_B, jtf_rs_role_relations, jtf_group_members,
--  Liang Xia   09/24/2003  add extra validation on isValidAgent with GROUP usage ='CALL' (Call Center)
--  Liang Xia  08/13/2004   Modified getTagValue to reuse tag based on
--                          profile IEM_REPROCESS_ALL_TAGS
--  Liang Xia  12/22/2004   Fixed bug 4079440. Init of IEM_REPROCESS_ALL_TAGS should act as 'N'
--  Liang Xia  04/06/2005   Fixed GSCC sql.46 ( bug 4256769 )
--  Liang Xia  05/31/2005   115.11 schema change compliance ( merged 115.12 with 115.10.11510.7 )
--  Liang Xia  06/02/2005   Fixed GSCC sql.46 according to bug 4289628
--  PKESANI    05/20/2006   For Bug 5195496, change the SQL to look for responsibility_key
--                          instead of responsibility_id.
--  PKESANI    06/27/2006   For Bug 5143181, changed the SQL in isValidAgent Function,
--                          To look into IEM_AGENTS instead of IEM_AGENT_ACCOUNTS.
-- ---------   ------  -----------------------------------------

-- Enter procedure, function bodies as shown below

PROCEDURE getEncryptId(
        P_Api_Version_Number 	  IN NUMBER,
	   P_Init_Msg_List  		  IN VARCHAR2     := null,
	   P_Commit    			  IN VARCHAR2     := null,
	   p_email_account_id	      IN iem_mstemail_accounts.email_account_id%type,
	   p_agent_id                IN NUMBER,
	  p_interaction_id          IN NUMBER,
	   p_biz_keyVal_tab          IN keyVals_tbl_type,
	   x_encrypted_id	          OUT  NOCOPY VARCHAR2,
	   x_msg_count   		      OUT  NOCOPY NUMBER,
	   x_return_status  		  OUT  NOCOPY VARCHAR2,
	   x_msg_data   			  OUT  NOCOPY VARCHAR2)
    -- Standard Start of API savepoint
 IS
    l_api_name              VARCHAR2(255):='getEncryptId';
    l_api_version_number    NUMBER:=1.0;

    l_strings       varchar2(2000):=null;
    l_encripted_id  VARCHAR2(20);
    l_keyVal_tbl    IEM_ENCRYPT_TAGS_PVT.email_tag_tbl;
    l_token         varchar2(30):=null;
    l_indx          binary_integer;
    l_temp_key      varchar2(30);
    l_temp_value    varchar2(256);

    l_key_value     keyVals_tbl_type;

    l_select_csr         INTEGER;
    l_temp               varchar2(256);
    l_query_result       varchar2(256);--iem_tag_keys.value%type;
    l_dummy                  INTEGER;
    l_account_flag      varchar2(1);

    v_ErrorCode NUMBER;
    v_ErrorText varchar2(200);
    errorMessage varchar2(2000);
    logMessage varchar2(2000);

    l_return_status         VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER := 0;
    l_msg_data              VARCHAR2(2000);

	l_log_enabled  BOOLEAN := false;
	l_exception_log BOOLEAN :=false;

    IEM_CREATE_ENCRYPTEDTAG_FAILED  EXCEPTION;

    cursor c_tags ( p_account_id iem_mstemail_accounts.email_account_id%type)
    is
    select a.tag_id, a.tag_type_code, a.value
        from iem_tag_keys a, iem_account_tag_keys b
        where a.tag_key_id = b.tag_key_id and b.email_account_id = p_account_id;

BEGIN
    SAVEPOINT getEncryptId_PUB;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
           p_api_version_number,
           l_api_name,
           G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- API begins

	l_log_enabled := FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL;

	l_exception_log:= FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL;


	if l_log_enabled  then
        logMessage := '[p_email_account_ID=' || to_char(p_email_account_ID) || '][p_Agent_Id='|| to_char(p_Agent_Id)||'][p_interaction_id='|| to_char(p_interaction_id)||']';
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_TAGPROCESS_PUB.getEncryptId.START', logMessage);
    end if;

   -- discontinued since 115.11
   -- select account_flag into l_account_flag from iem_email_accounts
   --     where email_account_id = p_email_account_id;

   -- IF email account is Acknowledgement, return null for x_encrypted_id
   -- Shipped in MP-Q (115.9)
   /* if l_account_flag = 'A' then

        if l_log_enabled  then
            logMessage := '[Email account is Acknowledgement account for p_email_account_id='||to_char(p_email_account_id)||'.Return null for x_encrypted_id]';
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_TAGPROCESS_PUB.getEncryptId', logMessage);
        end if;
        x_encrypted_id := null;
   else
   */
   --Start geting business tag and customerized tags here
   for i in 1..p_biz_keyVal_tab.count loop
        l_keyVal_tbl(i).email_tag_key := p_biz_keyVal_tab(i).key ;
        l_keyVal_tbl(i).email_tag_value :=p_biz_keyVal_tab(i).value;
   end loop;

   l_indx := p_biz_keyVal_tab.count + 1;

    l_key_value(1).key := 'IEMNEMAILACCOUNTID';
    l_key_value(1).value := TO_CHAR( p_email_account_ID );
    l_key_value(1).datatype := 'N';
    l_key_value(2).key := 'IEMNAGENTID';
    l_key_value(2).value := TO_CHAR(p_Agent_Id);
    l_key_value(2).datatype := 'N';
    l_key_value(3).key := 'IEMNINTERACTIONID';
    l_key_value(3).value := TO_CHAR(p_interaction_id);
    l_key_value(3).datatype := 'N';

   --Get all the customer defined tags in the system
   For v_tags in c_tags ( p_email_account_ID) Loop

        l_temp_key :=  v_tags.tag_id ;
        l_temp_value := v_tags.value;

        if v_tags.tag_type_code = 'FIXED' then
            l_keyVal_tbl(l_indx).email_tag_key := 'IEMS'||v_tags.tag_id;
            l_keyVal_tbl(l_indx).email_tag_value := v_tags.value;
            l_indx := l_indx + 1;

        elsif v_tags.tag_type_code = 'QUERY' then
             l_temp := null;

              -- Begin QUERY processing
              BEGIN
              l_select_csr := DBMS_SQL.OPEN_CURSOR;
              DBMS_SQL.PARSE(l_select_csr, l_temp_value, DBMS_SQL.native);
              DBMS_SQL.DEFINE_COLUMN(l_select_csr, 1, l_query_result, 256);
              l_dummy := DBMS_SQL.EXECUTE(l_select_csr);

              -- fetch the first result if there is any
                IF DBMS_SQL.FETCH_ROWS(l_select_csr) = 0 THEN
      	             l_temp := null;
                ELSE
                    DBMS_SQL.COLUMN_VALUE(l_select_csr, 1, l_query_result);
                    l_temp := l_query_result;

                    -- check if there are more than 1 rows selected.
                    IF DBMS_SQL.FETCH_ROWS(l_select_csr) <> 0 THEN
                        if l_log_enabled  then
                            logMessage := '[ERROR (too many rows selected) when execute query for keyId: '||v_tags.tag_id ||']';
                            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_TAGPROCESS_PUB.getEncryptId', logMessage);
                        end if;
                        -- dbms_output.put_line('Too many rows are selected');
      	                 l_temp := null;
                    END IF;
                end if;

                -- Close the cursor
                DBMS_SQL.CLOSE_CURSOR(l_select_csr);

                 -- Insert data in key-value pair table
                l_keyVal_tbl(l_indx).email_tag_key := 'IEMS'||v_tags.tag_id;
                l_keyVal_tbl(l_indx).email_tag_value := l_temp;
                l_indx := l_indx + 1;

           EXCEPTION
          	 WHEN OTHERS THEN
                 DBMS_SQL.CLOSE_CURSOR(l_select_csr);

                  if l_log_enabled  then
                      logMessage := '[ERROR (Other exception) when execute query for keyId: '||v_tags.tag_id||'. Error:' ||sqlerrm||']';
                      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_TAGPROCESS_PUB.getEncryptId', logMessage);
                  end if;

                 --DBMS_OUTPUT.put_line('OTHER exception happened when execute the query');

                  -- Insert data in key-value pair table
                  l_keyVal_tbl(l_indx).email_tag_key := 'IEMS'||v_tags.tag_id;
                  l_keyVal_tbl(l_indx).email_tag_value := l_temp;
                  l_indx := l_indx + 1;
           END; -- end of QUERY processing

        elsif v_tags.tag_type_code = 'PROCEDURE' then
            l_temp := null;

            -- begin PROCEDURE processing
            BEGIN
                IEM_TAG_RUN_PROC_PVT.run_Procedure(
                            p_api_version_number    =>P_Api_Version_Number,
                            p_init_msg_list         => FND_API.G_FALSE,
                            p_commit                => P_Commit,
                            p_procedure_name        => l_temp_value,
                            p_key_value             => l_key_value,
                            x_result                => l_temp,
                            x_return_status         =>l_return_status,
                            x_msg_count             => l_msg_count,
                            x_msg_data              => l_msg_data);

                if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
                    --dbms_output.put_line('Failed to get tag value from procedure '||l_temp_value);

                    if l_log_enabled  then
                        logMessage := '[ERROR when execute procedure for keyId: '||v_tags.tag_id ||']';
                        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_TAGPROCESS_PUB.getEncryptId', logMessage);
                    end if;
                end if;

                -- Insert data in key-value pair table
                l_keyVal_tbl(l_indx).email_tag_key := 'IEMS'||v_tags.tag_id;
                l_keyVal_tbl(l_indx).email_tag_value := l_temp;
                l_indx := l_indx + 1;
             EXCEPTION
          	     WHEN OTHERS THEN
                   -- dbms_output.put_line('OTHER exception happened when execute the procedure ' || SUBSTR (SQLERRM , 1 , 100));

                    if l_log_enabled  then
                        logMessage := '[ERROR (Others) when execute procedure for keyId: '||v_tags.tag_id ||'. error:'||sqlerrm||']';
                        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_TAGPROCESS_PUB.getEncryptId', logMessage);
                    end if;

                    -- Insert data in key-value pair table
                    l_keyVal_tbl(l_indx).email_tag_key := 'IEMS'||v_tags.tag_id;
                    l_keyVal_tbl(l_indx).email_tag_value := l_temp;
                    l_indx := l_indx + 1;
             END; -- end of PROCEDURE processing

        end if;
   end Loop;


    IEM_ENCRYPT_TAGS_PVT.create_item(
                 p_api_version_number  => P_Api_Version_Number,
 		  	     p_init_msg_list       => FND_API.G_FALSE,
		    	 p_commit              => P_Commit,
            	 p_agent_id            => p_agent_id,
                 p_interaction_id             => p_interaction_id,
                 p_email_tag_tbl       => l_keyVal_tbl,
                 x_encripted_id        => l_encripted_id,
                 x_token               => l_token,
                 x_return_status       => l_return_status,
  		  	     x_msg_count           => x_msg_count,
	  	  	     x_msg_data            => x_msg_data
			 );
    if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
        --dbms_output.put_line('Failed in Create_item: IEM_ENCRYPT_TAGS_PVT ');
        raise IEM_CREATE_ENCRYPTEDTAG_FAILED;
    end if;

    /*
    dbms_output.put_line('key' ||' = '|| 'IEMNAGENTID' );
    dbms_output.put_line('    value' ||' = '||p_agent_id );
    dbms_output.put_line('key' ||' = '|| 'IEMNINTERACTIONID' );
    dbms_output.put_line('    value' ||' = '||p_interaction_id);

    for j in 1..l_keyVal_tbl.count loop
         dbms_output.put_line('key' ||' = '|| l_keyVal_tbl(j).email_tag_key );
         dbms_output.put_line('    value' ||' = '||l_keyVal_tbl(j).email_tag_value );
    end loop;
    */

    -- Return encrypted_id
    x_encrypted_id := l_encripted_id||l_token;

   --  end if;

    if l_log_enabled  then
        logMessage := '[RETURN Encrypted Id= ' || x_encrypted_id||']';
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_TAGPROCESS_PUB.getEncryptId', logMessage);
     end if;

     -- Standard Check Of p_commit.
	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;

    -- Standard callto get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
			( p_count =>  x_msg_count,
              p_data  =>    x_msg_data
			);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO getEncryptId_PUB;
        x_return_status := FND_API.G_RET_STS_ERROR;
        if l_log_enabled  then
            logMessage := '[No data found for p_email_account_id= '||p_email_account_id||'.]';
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_TAGPROCESS_PUB.getEncryptId', logMessage);
        end if;

    WHEN IEM_CREATE_ENCRYPTEDTAG_FAILED THEN
        ROLLBACK TO getEncryptId_PUB;
        x_return_status := FND_API.G_RET_STS_ERROR ;

        if l_log_enabled  then
            logMessage := '[Failed to create data in IEM_ENCRYPTED_TAGS table. ]';
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_TAGPROCESS_PUB.getEncryptId', logMessage);
        end if;

    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO getEncryptId_PUB;
       x_return_status := FND_API.G_RET_STS_ERROR ;

        if l_exception_log  then
            logMessage := '[FND_API.G_EXC_ERROR in getEncryptId ]';
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'IEM.PLSQL.IEM_TAGPROCESS_PUB.getEncryptId', logMessage);
        end if;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO getEncryptId_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        if l_exception_log then
            logMessage := '[FND_API.G_EXC_UNEXPECTED_ERROR in getEncryptId]';
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'IEM.PLSQL.IEM_TAGPROCESS_PUB.getEncryptId', logMessage);
        end if;
    WHEN OTHERS THEN

        ROLLBACK TO getEncryptId_PUB;
                x_return_status := FND_API.G_RET_STS_ERROR;

        if l_exception_log then
            logMessage := '[OTHER exception in getEncryptId]';
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'IEM.PLSQL.IEM_TAGPROCESS_PUB.getEncryptId', logMessage);
        end if;

END getEncryptId;


PROCEDURE IEM_STAMP_ENCRYPTED_TAG(
        P_Api_Version_Number 	  IN NUMBER,
        P_Init_Msg_List  		  IN VARCHAR2     := null,
        P_Commit    			  IN VARCHAR2     := null,
        p_encrypted_id	          IN NUMBER,
        p_message_id              IN NUMBER,
        x_msg_count   		      OUT NOCOPY NUMBER,
        x_return_status  		  OUT NOCOPY VARCHAR2,
        x_msg_data   			  OUT NOCOPY VARCHAR2)
    -- Standard Start of API savepoint
 IS
    l_api_name              VARCHAR2(255):='IEM_STAMP_ENCRYPTED_TAG';
    l_api_version_number    NUMBER:=1.0;

    l_strings       varchar2(2000):=null;

    v_ErrorCode NUMBER;
    v_ErrorText varchar2(200);
    errorMessage varchar2(2000);
    logMessage varchar2(2000);

    l_len       NUMBER := 0;
    l_token_in  VARCHAR2(20) := '';
    l_token_out     VARCHAR2(20);
    l_encrypt_char  VARCHAR2(150);
    l_encrypt_num   NUMBER(15);
    l_temp      number;

    l_return_status         VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER := 0;
    l_msg_data              VARCHAR2(2000);
	l_log_enabled  BOOLEAN := false;
	l_exception_log BOOLEAN :=false;

    IEM_FAILED_TO_STAMP_TAG EXCEPTION;
    IEM_TOKEN_NOT_MATCH      EXCEPTION;
    IEM_INVALID_ENCRYPTED_ID    EXCEPTION;

BEGIN
    SAVEPOINT IEM_STAMP_ENCRYPTED_TAG;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
           p_api_version_number,
           l_api_name,
           G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- API begins
    l_log_enabled := FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    l_exception_log:= FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL;


    IEM_ENCRYPT_TAGS_PVT.update_item_on_mess_id (
                 p_api_version_number  => P_Api_Version_Number,
 		  	     p_init_msg_list       => FND_API.G_FALSE,
		    	 p_commit              => P_Commit,
            	 p_encrypted_id        => p_encrypted_id,
                 p_message_id          => p_message_id,
                 x_return_status       => l_return_status,
  		  	     x_msg_count           => x_msg_count,
	  	  	     x_msg_data            => x_msg_data
			 );

    if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
        raise IEM_FAILED_TO_STAMP_TAG;
    end if;

    if l_log_enabled then
        logMessage := '[TAG IS STAMPED]';
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_TAGPROCESS_PUB.IEM_STAMP_ENCRYPTED_TAG', logMessage);
    end if;

     -- Standard Check Of p_commit.
	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;


    -- Standard callto get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
			( p_count =>  x_msg_count,
              p_data  =>    x_msg_data
			);

EXCEPTION
    WHEN IEM_INVALID_ENCRYPTED_ID THEN
        --dbms_output.put_line('IEM_INVALID_ENCRYPTED_ID');
        ROLLBACK TO IEM_STAMP_ENCRYPTED_TAG;
        x_return_status := FND_API.G_RET_STS_ERROR ;

        if l_log_enabled then
            logMessage := '[The encrypted id is invalid because length is too short.]';
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_TAGPROCESS_PUB.IEM_STAMP_ENCRYPTED_TAG', logMessage);
        end if;
    WHEN NO_DATA_FOUND THEN
        --dbms_output.put_line('The encrypted Id is invalid because no data found or no security token stored.');
        ROLLBACK TO IEM_STAMP_ENCRYPTED_TAG;
        x_return_status := FND_API.G_RET_STS_ERROR ;

        if l_log_enabled then
            logMessage := '[The encrypted Id is invalid because no data found or no security token stored.]';
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_TAGPROCESS_PUB.IEM_STAMP_ENCRYPTED_TAG', logMessage);
        end if;

     WHEN IEM_TOKEN_NOT_MATCH THEN
        --dbms_output.put_line('IEM_TOKEN_NOT_MATCH');
        ROLLBACK TO IEM_STAMP_ENCRYPTED_TAG;
        x_return_status := FND_API.G_RET_STS_ERROR ;

        if l_log_enabled then
            logMessage := '[The token is not match with security token.]';
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_TAGPROCESS_PUB.IEM_STAMP_ENCRYPTED_TAG', logMessage);
        end if;

    WHEN IEM_FAILED_TO_STAMP_TAG THEN
        ROLLBACK TO IEM_STAMP_ENCRYPTED_TAG;
        --dbms_output.put_line('IEM_STAMP_ENCRYPTED_TAG');
        x_return_status := FND_API.G_RET_STS_ERROR ;

        if l_log_enabled then
            logMessage := '[FAILED to STAMP TAG]';
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_TAGPROCESS_PUB.IEM_STAMP_ENCRYPTED_TAG', logMessage);
        end if;

    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO IEM_STAMP_ENCRYPTED_TAG;
       x_return_status := FND_API.G_RET_STS_ERROR ;
        if l_exception_log then
            logMessage := '[FND_API.G_EXC_ERROR happened]';
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'IEM.PLSQL.IEM_TAGPROCESS_PUB.IEM_STAMP_ENCRYPTED_TAG', logMessage);
        end if;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO IEM_STAMP_ENCRYPTED_TAG;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        if l_exception_log then
            logMessage := '[FND_API.G_EXC_UNEXPECTED_ERROR happened]';
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'IEM.PLSQL.IEM_TAGPROCESS_PUB.IEM_STAMP_ENCRYPTED_TAG', logMessage);
        end if;
    WHEN OTHERS THEN
        ROLLBACK TO IEM_STAMP_ENCRYPTED_TAG;
        x_return_status := FND_API.G_RET_STS_ERROR;

        if l_exception_log then
            logMessage := '[Other exception happended in IEM_STAMP_ENCRYPTED_TAG: ' ||sqlerrm||']';
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'IEM.PLSQL.IEM_TAGPROCESS_PUB.IEM_STAMP_ENCRYPTED_TAG', logMessage);
        end if;
END IEM_STAMP_ENCRYPTED_TAG;

PROCEDURE getTagValues(
        P_Api_Version_Number 	  IN NUMBER,
        P_Init_Msg_List  		  IN VARCHAR2     := null,
        P_Commit    			  IN VARCHAR2     := null,
        p_encrypted_id            IN VARCHAR2,
        p_message_id              IN NUMBER,
        x_key_value               OUT  NOCOPY keyVals_tbl_type,
        x_msg_count   		      OUT  NOCOPY NUMBER,
        x_return_status  		  OUT  NOCOPY VARCHAR2,
        x_msg_data   			  OUT  NOCOPY VARCHAR2)
    -- Standard Start of API savepoint
 IS
    l_api_name              VARCHAR2(255):='getTagValues';
    l_api_version_number    NUMBER:=1.0;

    l_encrypted_id          VARCHAR2(256);
    l_keyVal_tab	       keyVals_tbl_type;
    l_agent_id              number := null;
    l_interaction_id        number := null;
    i               number := 1;

    v_ErrorCode NUMBER;
    v_ErrorText varchar2(200);
    errorMessage varchar2(2000);
    logMessage varchar2(2000);

    l_len       NUMBER := 0;
    l_token_in  VARCHAR2(20) := '';
    l_token_out     VARCHAR2(20);
    l_encrypt_char  VARCHAR2(150);
    l_encrypt_num   NUMBER(15);
    l_mess_id   number;
     l_reuse_tag VARCHAR2(20) := '';

    l_return_status         VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER := 0;
    l_msg_data              VARCHAR2(2000);
	l_log_enabled  BOOLEAN := false;
	l_exception_log BOOLEAN :=false;

	IEM_TOKEN_NOT_MATCH      EXCEPTION;
    IEM_INVALID_ENCRYPTED_ID    EXCEPTION;
    IEM_FAILED_TO_STAMP_TAG     EXCEPTION;
    IEM_ENCRYPTED_ID_ALREADY_USED EXCEPTION;
    IEM_FAIL_DUPLICAT_REC_REUSETAG EXCEPTION;

  cursor c_key_val (p_encrypted_id iem_encrypted_tags.encrypted_id%type)
  is
  select
    a.key,
    a.value
  from
    iem_encrypted_tag_dtls a
  where
    a.encrypted_id = p_encrypted_id;
BEGIN
    SAVEPOINT getTagValues_PUB;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
           p_api_version_number,
           l_api_name,
           G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- API begins

    l_log_enabled := FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    l_exception_log:= FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL;


    if l_log_enabled then
    logMessage := '[Input Enrypted_ID=' || p_encrypted_id || ' p_message_id=' || p_message_id ||']';
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_TAGPROCESS_PUB.getTagValues.START', logMessage);
    end if;

   l_encrypted_id := LTRIM(RTRIM(p_encrypted_id));

    l_len := length(l_encrypted_id);
    if l_len < 10 then
       -- dbms_output.put_line('Too short!');
        raise IEM_INVALID_ENCRYPTED_ID;
    else
        l_token_in := SUBSTR(l_encrypted_id, l_len-4, 5);
        l_encrypt_char := SUBSTR(l_encrypted_id, 1, l_len-5);
    end if;

    --Security check
    begin
        l_encrypt_num := TO_NUMBER( l_encrypt_char );
        select token into l_token_out from iem_encrypted_tags where encrypted_id = l_encrypt_num;

    exception
        when others then
            raise IEM_TOKEN_NOT_MATCH;
    end;

     if l_token_in <> l_token_out then
            raise IEM_TOKEN_NOT_MATCH;
     end if;

     -- Check whether this encrypted_id already been used by other message or not
     select message_id into l_mess_id from iem_encrypted_tags where encrypted_id = l_encrypt_num;

    l_reuse_tag := FND_PROFILE.VALUE_SPECIFIC('IEM_REPROCESS_ALL_TAGS');

    -- If reuse tag is not set and tag has been used
    if ( l_reuse_tag is null or l_reuse_tag <> 'Y' ) and ( l_mess_id is not null ) then
            raise IEM_ENCRYPTED_ID_ALREADY_USED;

    -- If profile value of reuse tag is set and tag is used
    -- Duplicate tag records and stamp with new msg_id, and return key_val
    elsif ( l_reuse_tag = 'Y' ) and ( l_mess_id is not null )then

        IEM_ENCRYPT_TAGS_PVT.duplicate_tags(
                 p_api_version_number  => P_Api_Version_Number,
                    p_init_msg_list       => FND_API.G_FALSE,
                p_commit              => P_Commit,
                 p_encrypted_id        => l_encrypt_num,
                 p_message_id          => p_message_id,
                 x_return_status       => l_return_status,
                    x_msg_count           => x_msg_count,
                    x_msg_data            => x_msg_data
                );

            if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
                    --dbms_output.put_line('ERROR when calling IEM_ENCRYPT_TAGS_PVT.duplicate_tags ');
                    raise IEM_FAIL_DUPLICAT_REC_REUSETAG;
            end if;

    -- Following cases to stamp msg_id and return key_val when
    -- 1) l_reuse_tag <> 'Y' ) and ( l_mess_id is null )
    -- or
    -- 2) l_reuse_tag = 'Y' ) and ( l_mess_id is null )
    else
   --Stamping the message_id with the encrypted_id
      IEM_TAGPROCESS_PUB.IEM_STAMP_ENCRYPTED_TAG
                            ( p_api_version_number => l_api_version_number,
                              p_init_msg_list => FND_API.G_FALSE,
                              p_commit =>FND_API.G_FALSE,
                              p_encrypted_id => l_encrypt_num,
                              p_message_Id=>p_message_id,
                              x_return_status =>l_return_status,
                              x_msg_count   => l_msg_count,
                              x_msg_data => l_msg_data);

        if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
            raise IEM_FAILED_TO_STAMP_TAG;
        end if;

    end if;

    SELECT  agent_id, interaction_id
	   INTO  l_agent_id, l_interaction_id
	   FROM iem_encrypted_tags
	   WHERE encrypted_id = l_encrypt_num;

    -- Get eMail Center system Tags
    l_keyVal_tab(1).key := 'IEMNAGENTID';
    l_keyVal_tab(1).value := l_agent_id;
    l_keyVal_tab(1).datatype := 'N';

    l_keyVal_tab(2).key := 'IEMNINTERACTIONID';
    l_keyVal_tab(2).value := l_interaction_id;
    l_keyVal_tab(2).datatype := 'N';

    -- Get BIZ system Tags and Custom Tags
    For v_key_val in c_key_val (l_encrypt_num ) Loop
        l_keyVal_tab(i+2).key := v_key_val.key ;
        l_keyVal_tab(i+2).value := v_key_val.value ;
        l_keyVal_tab(i+2).datatype :=SUBSTR(v_key_val.key, 4, 1);
        i := i+1;
    end loop;

    -- Log returned key-val.
    if l_log_enabled then
            logMessage := '[ Returned Key-val total = ' || l_keyVal_tab.COUNT|| ' ]';
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_TAGPROCESS_PUB.GETTAGVALUES_ON_MSGID', logMessage);
    end if;

    FOR x in 1..l_keyVal_tab.COUNT LOOP
        if l_log_enabled then
            logMessage := '[ key= ' || l_keyVal_tab(x).key || ' ] [ value= '|| l_keyVal_tab(x).value ||' ]';
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_TAGPROCESS_PUB.GETTAGVALUES_ON_MSGID', logMessage);
        end if;
 	END LOOP;

    -- Return key-val pairs
    x_key_value := l_keyVal_tab;

     -- Standard Check Of p_commit.
	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;


    -- Standard callto get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
			( p_count =>  x_msg_count,
              p_data  =>    x_msg_data
			);

EXCEPTION
    WHEN IEM_FAIL_DUPLICAT_REC_REUSETAG THEN
        --dbms_output.put_line('Failed to stamp tag');
        ROLLBACK TO getTagValues_PUB;
        x_return_status := FND_API.G_RET_STS_SUCCESS ;

        if l_log_enabled then
            logMessage := '[ERROR when calling IEM_ENCRYPT_TAGS_PVT.duplicate_tags]';
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_TAGPROCESS_PUB.getTagValues', logMessage);
        end if;

    WHEN IEM_FAILED_TO_STAMP_TAG THEN
        --dbms_output.put_line('Failed to stamp tag');
        ROLLBACK TO getTagValues_PUB;
        x_return_status := FND_API.G_RET_STS_SUCCESS ;

        if l_log_enabled then
            logMessage := '[FAILED to STAMP TAG]';
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_TAGPROCESS_PUB.GETTAGVALUES', logMessage);
        end if;

    WHEN IEM_ENCRYPTED_ID_ALREADY_USED THEN
        -- dbms_output.put_line('This encrypted id is already used by another message');
        ROLLBACK TO getTagValues_PUB;
        x_return_status := FND_API.G_RET_STS_SUCCESS ;

        if l_log_enabled then
            logMessage := '[The encrypted ID already has been stamped with other message.]';
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_TAGPROCESS_PUB.GETTAGVALUES', logMessage);
        end if;

    WHEN IEM_INVALID_ENCRYPTED_ID THEN
        ROLLBACK TO getTagValues_PUB;
        x_return_status := FND_API.G_RET_STS_SUCCESS ;

        if l_log_enabled then
            logMessage := '[The encrypted id is invalid because length is too short.]';
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_TAGPROCESS_PUB.GETTAGVALUES', logMessage);
        end if;
    WHEN NO_DATA_FOUND THEN
        --dbms_output.put_line('The encrypted Id is invalid because no data found or no security token stored.');
        ROLLBACK TO getTagValues_PUB;
        x_return_status := FND_API.G_RET_STS_SUCCESS ;

        if l_log_enabled then
            logMessage := '[The encrypted Id is invalid because no data found or no security token stored.]';
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_TAGPROCESS_PUB.GETTAGVALUES', logMessage);
        end if;

     WHEN IEM_TOKEN_NOT_MATCH THEN
        ROLLBACK TO getTagValues_PUB;
            --dbms_output.put_line('TOKEN_NOT_MATCH');
        x_return_status := FND_API.G_RET_STS_SUCCESS ;

        if l_log_enabled then
            logMessage := '[The token is not match with security token.]';
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_TAGPROCESS_PUB.GETTAGVALUES', logMessage);
        end if;


    WHEN FND_API.G_EXC_ERROR THEN

        ROLLBACK TO getTagValues_PUB;
       x_return_status := FND_API.G_RET_STS_ERROR ;
        if l_exception_log then
            logMessage := '[FND_API.G_EXC_ERROR in GETTAGVALUES]';
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'IEM.PLSQL.IEM_TAGPROCESS_PUB.GETTAGVALUES', logMessage);
        end if;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO getTagValues_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        if l_exception_log then
            logMessage := '[FND_API.G_EXC_UNEXPECTED_ERROR in GETTAGVALUES]';
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'IEM.PLSQL.IEM_TAGPROCESS_PUB.GETTAGVALUES', logMessage);
        end if;
    WHEN OTHERS THEN
        ROLLBACK TO getTagValues_PUB;
                x_return_status := FND_API.G_RET_STS_ERROR;

         if l_exception_log then
            logMessage := '[Other exception happened in GETTAGVALUES:' || sqlerrm || ']';
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'IEM.PLSQL.IEM_TAGPROCESS_PUB.GETTAGVALUES', logMessage);
        end if;
END getTagValues;


PROCEDURE getTagValues_on_MsgId(
        P_Api_Version_Number 	  IN NUMBER,
        P_Init_Msg_List  		  IN VARCHAR2     := null,
        P_Commit    			  IN VARCHAR2     := null,
        p_message_id              IN NUMBER,
        x_key_value               OUT NOCOPY keyVals_tbl_type,
        x_encrypted_id            OUT NOCOPY VARCHAR2,
        x_msg_count   		      OUT NOCOPY NUMBER,
        x_return_status  		  OUT NOCOPY VARCHAR2,
        x_msg_data   			  OUT NOCOPY VARCHAR2)
    -- Standard Start of API savepoint
 IS
    l_api_name              VARCHAR2(255):='getTagValues_on_MsgId';
    l_api_version_number    NUMBER:=1.0;


    l_keyVal_tab        keyVals_tbl_type ;
    l_agent_id      number := null;
    l_interaction_id       number := null;
    i               number :=1;

    v_ErrorCode NUMBER;
    v_ErrorText varchar2(200);
    errorMessage varchar2(2000);
    logMessage varchar2(2000);
    l_encrypted_id varchar2(20);
    l_token varchar(20);

    l_return_status         VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER := 0;
    l_msg_data              VARCHAR2(2000);
	l_log_enabled  BOOLEAN := false;
	l_exception_log BOOLEAN :=false;

    IEM_TOKEN_NOT_MATCH      EXCEPTION;
    IEM_INVALID_ENCRYPTED_ID    EXCEPTION;

  cursor c_key_val (p_msg_id iem_encrypted_tags.message_id%type)
  is
  select
    a.key,
    a.value
  from
    iem_encrypted_tag_dtls a, iem_encrypted_tags b
  where
    a.encrypted_id=b.encrypted_id and b.message_id = p_msg_id;
BEGIN
    SAVEPOINT getTagValues_on_MsgId_PUB;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
           p_api_version_number,
           l_api_name,
           G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- API begins
    l_log_enabled := FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    l_exception_log:= FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    if l_log_enabled then
    logMessage := '[Message_id passed in =' || p_message_id || ']';
    FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_TAGPROCESS_PUB.getTagValues_on_MsgId.START', logMessage);
    end if;


    SELECT  agent_id, interaction_id, encrypted_id, token
	INTO  l_agent_id, l_interaction_id, l_encrypted_id, l_token
	FROM iem_encrypted_tags
	WHERE message_Id = p_message_id;

    --First get system tags: agent_id, interaction_id
    l_keyVal_tab(1).key := 'IEMNAGENTID';
    l_keyVal_tab(1).value := l_agent_id;
    l_keyVal_tab(1).datatype := 'N';

    l_keyVal_tab(2).key := 'IEMNINTERACTIONID';
    l_keyVal_tab(2).value := l_interaction_id;
    l_keyVal_tab(2).datatype := 'N';

    --Then get Custom get and apps bix tags
    For v_key_val in c_key_val (p_message_id ) Loop
        l_keyVal_tab(i+2).key := v_key_val.key ;
        l_keyVal_tab(i+2).value := v_key_val.value ;
        l_keyVal_tab(i+2).datatype := SUBSTR(v_key_val.key, 4, 1);
        i := i+1;
    end loop;

    -- Log returned key-val.
    if l_log_enabled then
            logMessage := '[ Returned Key-val total = ' || l_keyVal_tab.COUNT|| ' EncryptedID = ' ||l_encrypted_id || l_token||' ]';
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_TAGPROCESS_PUB.GETTAGVALUES_ON_MSGID', logMessage);
    end if;

    if l_log_enabled then
            logMessage := '[ Returned Key-val total = ' || l_keyVal_tab.COUNT|| ' ]';
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_TAGPROCESS_PUB.GETTAGVALUES_ON_MSGID', logMessage);
    end if;

    FOR x in 1..l_keyVal_tab.COUNT LOOP
        if l_log_enabled then
            logMessage := '[ key= ' || l_keyVal_tab(x).key || ' ] [ value= '|| l_keyVal_tab(x).value ||' ]';
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_TAGPROCESS_PUB.GETTAGVALUES_ON_MSGID', logMessage);
        end if;
 	END LOOP;

    x_key_value := l_keyVal_tab;
    x_encrypted_id := l_encrypted_id || l_token;


     -- Standard Check Of p_commit.
	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;

    -- Standard callto get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
			( p_count =>  x_msg_count,
              p_data  =>    x_msg_data
			);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        --dbms_output.put_line('The message id is not stamped.');
        ROLLBACK TO getTagValues_on_MsgId_PUB;
        x_return_status := FND_API.G_RET_STS_SUCCESS ;

        if l_log_enabled then
            logMessage := '[The message id is not stamped.There is not corresponding tags for this message.No Key_val returned.]';
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_TAGPROCESS_PUB.GETTAGVALUES_ON_MSGID', logMessage);
        end if;

    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO getTagValues_on_MsgId_PUB;
       x_return_status := FND_API.G_RET_STS_ERROR ;

        if l_exception_log then
            logMessage := '[FND_API.G_EXC_ERROR happened in GETTAGVALUES_ON_MSGID.No Key_val returned.]';
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'IEM.PLSQL.IEM_TAGPROCESS_PUB.GETTAGVALUES_ON_MSGID', logMessage);
        end if;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO getTagValues_on_MsgId_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        if l_exception_log then
            logMessage := '[FND_API.G_EXC_UNEXPECTED_ERROR happened in GETTAGVALUES_ON_MSGID.No Key_val returned.]';
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'IEM.PLSQL.IEM_TAGPROCESS_PUB.GETTAGVALUES_ON_MSGID', logMessage);
        end if;
    WHEN OTHERS THEN

        ROLLBACK TO getTagValues_on_MsgId_PUB;
        x_return_status := FND_API.G_RET_STS_ERROR;

        if l_exception_log then
            logMessage := '[Other exception happend in GETTAGVALUES_ON_MSGID.'||sqlerrm||']';
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'IEM.PLSQL.IEM_TAGPROCESS_PUB.GETTAGVALUES_ON_MSGID', logMessage);
        end if;
END getTagValues_on_MsgId;

function isValidAgent( p_agent_id number, p_email_acct_id number)
return boolean
is

l_asso_count number;
l_role_count number;
l_grp_count number;
l_user_resp number;

begin
    select count(*) into l_asso_count from iem_agents where resource_id=p_agent_id and email_account_id=p_email_acct_id;
    if l_asso_count < 1 then
        return false;
    end if;

    select count(*) into l_role_count from jtf_rs_role_relations a, jtf_rs_roles_vl b
    where a.role_resource_id=p_agent_id and a.role_id=b.role_id
        and b.role_type_code='ICENTER'
        and a.delete_flag='N'
        and a.START_DATE_ACTIVE< sysdate and ( a.END_DATE_ACTIVE>sysdate or a.END_DATE_ACTIVE is null);
    if l_role_count < 1 then
        return false;
    end if;

     select count(*) into l_grp_count from jtf_rs_group_members a, JTF_RS_GROUPS_B b, JTF_RS_GROUP_USAGES c
     where a.group_id = b.group_id
            and a.resource_id = p_agent_id
            and a.delete_flag = 'N'
            and b.START_DATE_ACTIVE< sysdate
            and ( b.END_DATE_ACTIVE>sysdate or b.END_DATE_ACTIVE is null)
            and b.group_id = c.group_id
            and c.usage = 'CALL';

     if l_grp_count < 1 then
        return false;
     end if;

    select count(a.user_id) into l_user_resp from jtf_rs_resource_extns a ,
        fnd_user_resp_groups b, fnd_user c, fnd_responsibility resp
        where a.resource_id = p_agent_id
        and a.START_DATE_ACTIVE< sysdate and ( a.END_DATE_ACTIVE>sysdate or a.END_DATE_ACTIVE is null)
        and a.user_id=b.user_id
        and b.START_DATE< sysdate and ( b.END_DATE>sysdate or b.END_DATE is null)
--        and ( b.responsibility_id = 23720 or b.responsibility_id = 23107 )
        and ( b.responsibility_id = resp.responsibility_id and resp.application_id=680)
        and ( resp.responsibility_key = 'EMAIL_CENTER_SUPERVISOR' or resp.responsibility_key='IEM_SA_AGENT')
        and b.user_id = c.user_id
        and c.START_DATE< sysdate and ( c.END_DATE>sysdate or c.END_DATE is null);

     if l_user_resp < 1 then
        return false;
     end if;

     return true;
end;

END IEM_TAGPROCESS_PUB;

/
