--------------------------------------------------------
--  DDL for Package Body IEM_DBLINK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_DBLINK_PVT" as
/* $Header: iemvdblb.pls 115.38 2004/04/08 21:12:05 chtang shipped $*/

G_PKG_NAME CONSTANT varchar2(30) :='IEM_DBLINK_PVT ';

-- Start of Comments
--  API name   : create_link
--  Type  :    Private
--  Function   : This procedure create a record in the table IEM_DB_CONNECTIONS
--  Pre-reqs   :    None.
--  Parameters :
--   IN
--  p_api_version_number      IN NUMBER Required
--  p_init_msg_list IN VARCHAR2
--  p_commit   IN VARCHAR2
--  p_db_glname IN   VARCHAR2,
--  p_db_username   IN   VARCHAR2,
--  p_db_password   IN   VARCHAR2,
--  p_db_server_id IN   NUMBER,
--  p_is_admin      IN   VARCHAR2
--
--   OUT
--   x_return_status     OUT  VARCHAR2
--   x_msg_count    OUT  NUMBER
--   x_msg_data     OUT  VARCHAR2
--
--   Version   : 1.0
--   Notes          :
--
-- End of comments
-- **********************************************************


PROCEDURE create_link (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  	IN   VARCHAR2 := FND_API.G_FALSE,
		    	      p_commit	    		IN   VARCHAR2 := FND_API.G_FALSE,
  				 p_db_server_id 	IN   NUMBER,
                     p_db_glname	 	IN VARCHAR2,
                     p_db_username 	IN VARCHAR2,
                     p_db_password 	IN VARCHAR2,
                     p_is_admin	 	IN VARCHAR2,
                	 x_return_status OUT NOCOPY VARCHAR2,
  		    	 	 x_msg_count	     OUT NOCOPY NUMBER,
	  	    		 x_msg_data	 OUT NOCOPY VARCHAR2
			 ) is
			 TYPE LinkCur Is REF CURSOR;
	l_api_name        		VARCHAR2(255):='create_link';
	l_api_version_number 	NUMBER:=1.0;
	l_v_id				NUMBER;
	l_num				NUMBER;
	l_count				NUMBER;
	l_dblink_count			number;
	l_is_admin			VARCHAR2(20);
	l_iem_server_rec		IEM_DB_SERVERS%ROWTYPE;
	l_statement			VARCHAR2(2000);
	l_statement1			VARCHAR2(2000) := 'none';
	l_global_name			VARCHAR2(240);
	l_glname				VARCHAR2(240);
	l_search_string			VARCHAR2(240);
	l_grp_cnt 			NUMBER;
	l_link_count			NUMBER;
	l_link_cur			LinkCur;
	l_db_password			VARCHAR2(255);
	l_schema_owner			VARCHAR2(30);
    oes_not_found		EXCEPTION;
    link_not_correct		EXCEPTION;
    db_name_invalid_a     EXCEPTION;
    db_name_invalid_spc     EXCEPTION;
    db_name_invalid     EXCEPTION;
    glname_invalid    EXCEPTION;
    login_denied      EXCEPTION;
    password_invalid    EXCEPTION;
    user_invalid     EXCEPTION;
    duplicate_db_link	EXCEPTION;
    protocol_invalid	EXCEPTION;
    sid_invalid	EXCEPTION;
    tns_no_listener		EXCEPTION;
    host_invalid		EXCEPTION;
    host_invalid1		EXCEPTION;
    db_conn_desc_invalid	EXCEPTION;
    db_link_exist		EXCEPTION;

    PRAGMA  EXCEPTION_INIT(db_name_invalid_a , -002083);
    PRAGMA  EXCEPTION_INIT(db_name_invalid_spc , -00933);
    PRAGMA  EXCEPTION_INIT(db_name_invalid , -0911);
    PRAGMA  EXCEPTION_INIT(glname_invalid, -01729);
    PRAGMA  EXCEPTION_INIT(login_denied , -01017);
    PRAGMA  EXCEPTION_INIT(password_invalid , -00988);
    PRAGMA  EXCEPTION_INIT(user_invalid , -06561);
    PRAGMA  EXCEPTION_INIT(duplicate_db_link , -02011);
    PRAGMA  EXCEPTION_INIT(protocol_invalid , -12538);
    PRAGMA  EXCEPTION_INIT(sid_invalid , -12505);
    PRAGMA  EXCEPTION_INIT(tns_no_listener , -12541);
    PRAGMA  EXCEPTION_INIT(host_invalid , -12535);
    PRAGMA  EXCEPTION_INIT(host_invalid1 , -12545);
    PRAGMA  EXCEPTION_INIT(db_conn_desc_invalid , -02019);

BEGIN
-- Standard Start of API savepoint
-- SAVEPOINT		CREATE_LINK_PVT;
-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call (l_api_version_number,
				    p_api_version_number,
				    l_api_name,
				    G_PKG_NAME)
THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
-- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
     FND_MSG_PUB.initialize;
   END IF;
-- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

IF (p_db_server_id = 0 or p_db_server_id = NULL) THEN
	raise oes_not_found;
END IF;

select oracle_username into l_schema_owner from fnd_oracle_userid where read_only_flag = 'U';

select count(*) into l_dblink_count from iem_db_connections where db_username=p_db_username and db_server_id=p_db_server_id;

if (l_dblink_count <> 0) then
	raise db_link_exist;
end if;

IF lower(p_db_username) <> 'apps' THEN
   select * INTO l_iem_server_rec from IEM_DB_SERVERS where DB_SERVER_ID = p_db_server_id;

   l_v_id := DBMS_SQL.OPEN_CURSOR;

   IF (p_db_username = 'oo') THEN

	select CONCAT(l_iem_server_rec.service_name, '@appsto_oo') into l_glname from DUAL;

	l_search_string := l_iem_server_rec.service_name || '%' || '@appsto_oo';
	select count(*)into l_link_count from all_db_links where upper(owner)=upper(l_schema_owner) and db_link like UPPER(l_search_string);

	if (l_link_count <> 0) then
		l_statement1 := 'DROP DATABASE LINK ' || l_glname;
	end if;

     l_statement := 'CREATE DATABASE LINK '||l_glname ||
	   ' CONNECT TO '||p_db_username||' IDENTIFIED BY '||p_db_password||
	   ' USING ''(DESCRIPTION=(ADDRESS=(PROTOCOL='||l_iem_server_rec.protocol||
	   ')(HOST='||l_iem_server_rec.hostname||
	   ')(PORT='||l_iem_server_rec.port ||
	   '))(CONNECT_DATA=(SID='||l_iem_server_rec.sid ||
	   ')))''';

   ELSIF (p_db_username = 'oraoffice') THEN

     select CONCAT(l_iem_server_rec.service_name, '@appsto_ora') into l_glname from DUAL;

     l_search_string := l_iem_server_rec.service_name || '%' || '@appsto_ora';
     select count(*)into l_link_count from all_db_links where upper(owner)=upper(l_schema_owner) and db_link like UPPER(l_search_string);

     if (l_link_count <> 0) then
		l_statement1 := 'DROP DATABASE LINK ' || l_glname;
     end if;

     l_statement := 'CREATE DATABASE LINK '||l_glname ||
	   ' CONNECT TO '||p_db_username||' IDENTIFIED BY '||p_db_password||
	   ' USING ''(DESCRIPTION=(ADDRESS=(PROTOCOL='||l_iem_server_rec.protocol||
	   ')(HOST='||l_iem_server_rec.hostname||
	   ')(PORT='||l_iem_server_rec.port ||
	   '))(CONNECT_DATA=(SID='||l_iem_server_rec.sid ||
	   ')))''';
   END IF;

	if (l_statement1 <> 'none') then
		DBMS_SQL.PARSE(l_v_id, l_statement1, DBMS_SQL.native);
		l_num := DBMS_SQL.EXECUTE(l_v_id);
	end if;

	DBMS_SQL.PARSE(l_v_id, l_statement, DBMS_SQL.native);
	l_num := DBMS_SQL.EXECUTE(l_v_id);
	DBMS_SQL.CLOSE_CURSOR(l_v_id);

	-- check if db link created successfully oherwise drop the link
--	l_v_id := DBMS_SQL.OPEN_CURSOR;
	l_statement := 'SELECT global_name FROM global_name@'||l_glname;
	OPEN l_link_cur for l_statement;
	LOOP
		FETCH l_link_cur INTO l_global_name;
		EXIT WHEN l_link_cur%notfound;
	END LOOP;
	close l_link_cur;
END IF;

	IF (p_db_username = 'oo') then
		l_is_admin :='A';
		l_db_password := p_db_password;
	ELSIF (p_db_username = 'oraoffice') then
		l_is_admin :='P';
		l_db_password := p_db_password;
	else
		l_is_admin :='O';
		l_db_password := 'welcome';
	end if;

	IF (l_glname IS NULL) THEN
		l_glname:=p_db_glname;
	END IF;

-- Standard Start of API savepoint
SAVEPOINT		CREATE_LINK_PVT;

	select count(*) into l_count from iem_db_connections where UPPER(db_link) = UPPER(l_glname) and db_server_id = p_db_server_id;

	if lower(l_global_name) <> lower(l_iem_server_rec.service_name) then
		raise link_not_correct;
	elsif l_count > 0 then
		raise duplicate_db_link;
	else
		IEM_DB_CONNECTIONS_PVT.create_item(
			p_api_version_number => 1.0,
			p_db_link => l_glname,
			p_db_username => p_db_username,
			p_db_password => l_db_password,
			p_db_server_id => p_db_server_id,
			p_is_admin => l_is_admin,
			x_msg_count => x_msg_count,
			x_return_status => x_return_status,
			x_msg_data => x_msg_data);
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
   WHEN oes_not_found THEN
	   FND_MESSAGE.SET_NAME('IEM','IEM_SSS_OES_NOT_FOUND');
	   FND_MSG_PUB.Add;
	   x_return_status := FND_API.G_RET_STS_ERROR ;
	   FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
   -- database link creation cannot be rolled back, it must be dropped manually
   WHEN link_not_correct THEN

   	  select count(*) into l_count from all_db_links where upper(owner)=upper(l_schema_owner) and UPPER(db_link) = UPPER(l_glname);

   	  if l_count <> 0 then
		l_v_id := DBMS_SQL.OPEN_CURSOR;
		l_statement := 'DROP DATABASE LINK '||l_glname;
		DBMS_SQL.PARSE(l_v_id, l_statement, DBMS_SQL.native);
		l_num := DBMS_SQL.EXECUTE(l_v_id);
		DBMS_SQL.CLOSE_CURSOR(l_v_id);
	  end if;
	  -- ROLLBACK TO CREATE_LINK_PVT;
	   FND_MESSAGE.SET_NAME('IEM','IEM_SSS_GLNAME_INVALID');
	   FND_MSG_PUB.Add;
	   x_return_status := FND_API.G_RET_STS_ERROR ;
	   FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

 WHEN db_name_invalid_a THEN

     	  select count(*) into l_count from all_db_links where upper(owner)=upper(l_schema_owner) and UPPER(db_link) = UPPER(l_glname);

   	  if l_count <> 0 then
		l_v_id := DBMS_SQL.OPEN_CURSOR;
		l_statement := 'DROP DATABASE LINK '||l_glname;
		DBMS_SQL.PARSE(l_v_id, l_statement, DBMS_SQL.native);
		l_num := DBMS_SQL.EXECUTE(l_v_id);
		DBMS_SQL.CLOSE_CURSOR(l_v_id);
	  end if;

   --     ROLLBACK TO CREATE_LINK_PVT;
	    FND_MESSAGE.SET_NAME('IEM','IEM_SSS_GLNAME_INVALID');
	    FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR ;
	    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
   WHEN db_name_invalid THEN
     	  select count(*) into l_count from all_db_links where upper(owner)=upper(l_schema_owner) and UPPER(db_link) = UPPER(l_glname);

   	  if l_count <> 0 then
		l_v_id := DBMS_SQL.OPEN_CURSOR;
		l_statement := 'DROP DATABASE LINK '||l_glname;
		DBMS_SQL.PARSE(l_v_id, l_statement, DBMS_SQL.native);
		l_num := DBMS_SQL.EXECUTE(l_v_id);
		DBMS_SQL.CLOSE_CURSOR(l_v_id);
	  end if;

   --     ROLLBACK TO CREATE_LINK_PVT;
	    FND_MESSAGE.SET_NAME('IEM','IEM_SSS_PSWD_GLNAME_INVALID');
	    FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR ;
	    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
   WHEN db_name_invalid_spc THEN
     	  select count(*) into l_count from all_db_links where upper(owner)=upper(l_schema_owner) and UPPER(db_link) = UPPER(l_glname);

   	  if l_count <> 0 then
		l_v_id := DBMS_SQL.OPEN_CURSOR;
		l_statement := 'DROP DATABASE LINK '||l_glname;
		DBMS_SQL.PARSE(l_v_id, l_statement, DBMS_SQL.native);
		l_num := DBMS_SQL.EXECUTE(l_v_id);
		DBMS_SQL.CLOSE_CURSOR(l_v_id);
	  end if;

   --     ROLLBACK TO CREATE_LINK_PVT;
	    FND_MESSAGE.SET_NAME('IEM','IEM_SSS_GLNAME_INVALID');
	    FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR ;
	    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

   WHEN glname_invalid THEN

     	  select count(*) into l_count from all_db_links where upper(owner)=upper(l_schema_owner) and UPPER(db_link) = UPPER(l_glname);

   	  if l_count <> 0 then
		l_v_id := DBMS_SQL.OPEN_CURSOR;
		l_statement := 'DROP DATABASE LINK '||l_glname;
		DBMS_SQL.PARSE(l_v_id, l_statement, DBMS_SQL.native);
		l_num := DBMS_SQL.EXECUTE(l_v_id);
		DBMS_SQL.CLOSE_CURSOR(l_v_id);
	  end if;

   --     ROLLBACK TO CREATE_LINK_PVT;
	    FND_MESSAGE.SET_NAME('IEM','IEM_SSS_GLNAME_INVALID');
	    FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR ;
	    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN login_denied THEN
     	  select count(*) into l_count from all_db_links where upper(owner)=upper(l_schema_owner) and UPPER(db_link) = UPPER(l_glname);

   	  if l_count <> 0 then
		l_v_id := DBMS_SQL.OPEN_CURSOR;
		l_statement := 'DROP DATABASE LINK '||l_glname;
		DBMS_SQL.PARSE(l_v_id, l_statement, DBMS_SQL.native);
		l_num := DBMS_SQL.EXECUTE(l_v_id);
		DBMS_SQL.CLOSE_CURSOR(l_v_id);
	  end if;

    --    ROLLBACK TO CREATE_LINK_PVT;
	    FND_MESSAGE.SET_NAME('IEM','IEM_DBLINK_LOGIN_DENIED');
	    FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR ;
	    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

   WHEN password_invalid THEN
     	  select count(*) into l_count from all_db_links where upper(owner)=upper(l_schema_owner) and UPPER(db_link) = UPPER(l_glname);

   	  if l_count <> 0 then
		l_v_id := DBMS_SQL.OPEN_CURSOR;
		l_statement := 'DROP DATABASE LINK '||l_glname;
		DBMS_SQL.PARSE(l_v_id, l_statement, DBMS_SQL.native);
		l_num := DBMS_SQL.EXECUTE(l_v_id);
		DBMS_SQL.CLOSE_CURSOR(l_v_id);
	  end if;

    --    ROLLBACK TO CREATE_LINK_PVT;
	    FND_MESSAGE.SET_NAME('IEM','IEM_DBLINK_LOGIN_DENIED');
	    FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR ;
	    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

   WHEN user_invalid THEN
     	  select count(*) into l_count from all_db_links where upper(owner)=upper(l_schema_owner) and UPPER(db_link) = UPPER(l_glname);

   	  if l_count <> 0 then
		l_v_id := DBMS_SQL.OPEN_CURSOR;
		l_statement := 'DROP DATABASE LINK '||l_glname;
		DBMS_SQL.PARSE(l_v_id, l_statement, DBMS_SQL.native);
		l_num := DBMS_SQL.EXECUTE(l_v_id);
		DBMS_SQL.CLOSE_CURSOR(l_v_id);
	  end if;

    --    ROLLBACK TO CREATE_LINK_PVT;
	    FND_MESSAGE.SET_NAME('IEM','IEM_DBLINK_LOGIN_DENIED');
	    FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR ;
	    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

   WHEN duplicate_db_link THEN

    -- don't drop database link as rollback as this drop the links for the existing link.
    --    ROLLBACK TO CREATE_LINK_PVT;
	    FND_MESSAGE.SET_NAME('IEM','IEM_DUPLICATE_DB_LINK');
	    FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR ;
	    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN db_link_exist THEN

    -- don't drop database link as rollback as this drop the links for the existing link.
    --    ROLLBACK TO CREATE_LINK_PVT;
	    FND_MESSAGE.SET_NAME('IEM','IEM_DUPLICATE_DB_LINK');
	    FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR ;
	    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

   WHEN protocol_invalid THEN
     	  select count(*) into l_count from all_db_links where upper(owner)=upper(l_schema_owner) and UPPER(db_link) = UPPER(l_glname);

   	  if l_count <> 0 then
		l_v_id := DBMS_SQL.OPEN_CURSOR;
		l_statement := 'DROP DATABASE LINK '||l_glname;
		DBMS_SQL.PARSE(l_v_id, l_statement, DBMS_SQL.native);
		l_num := DBMS_SQL.EXECUTE(l_v_id);
		DBMS_SQL.CLOSE_CURSOR(l_v_id);
	  end if;

    --    ROLLBACK TO CREATE_LINK_PVT;
	    FND_MESSAGE.SET_NAME('IEM','IEM_SSS_PROTOCOL_NOT_VALID');
	    FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR ;
	    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
   WHEN sid_invalid THEN
     	  select count(*) into l_count from all_db_links where upper(owner)=upper(l_schema_owner) and UPPER(db_link) = UPPER(l_glname);

   	  if l_count <> 0 then
		l_v_id := DBMS_SQL.OPEN_CURSOR;
		l_statement := 'DROP DATABASE LINK '||l_glname;
		DBMS_SQL.PARSE(l_v_id, l_statement, DBMS_SQL.native);
		l_num := DBMS_SQL.EXECUTE(l_v_id);
		DBMS_SQL.CLOSE_CURSOR(l_v_id);
	  end if;

    --    ROLLBACK TO CREATE_LINK_PVT;
	    FND_MESSAGE.SET_NAME('IEM','IEM_SSS_SID_NOT_VALID');
	    FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR ;
	    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
   WHEN tns_no_listener THEN
     	  select count(*) into l_count from all_db_links where upper(owner)=upper(l_schema_owner) and UPPER(db_link) = UPPER(l_glname);

   	  if l_count <> 0 then
		l_v_id := DBMS_SQL.OPEN_CURSOR;
		l_statement := 'DROP DATABASE LINK '||l_glname;
		DBMS_SQL.PARSE(l_v_id, l_statement, DBMS_SQL.native);
		l_num := DBMS_SQL.EXECUTE(l_v_id);
		DBMS_SQL.CLOSE_CURSOR(l_v_id);
	  end if;

    --    ROLLBACK TO CREATE_LINK_PVT;
	    FND_MESSAGE.SET_NAME('IEM','IEM_SSS_TNS_NO_LISTENER');
	    FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR ;
	    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
  WHEN host_invalid THEN
     	  select count(*) into l_count from all_db_links where upper(owner)=upper(l_schema_owner) and UPPER(db_link) = UPPER(l_glname);

   	  if l_count <> 0 then
		l_v_id := DBMS_SQL.OPEN_CURSOR;
		l_statement := 'DROP DATABASE LINK '||l_glname;
		DBMS_SQL.PARSE(l_v_id, l_statement, DBMS_SQL.native);
		l_num := DBMS_SQL.EXECUTE(l_v_id);
		DBMS_SQL.CLOSE_CURSOR(l_v_id);
	  end if;

    --    ROLLBACK TO CREATE_LINK_PVT;
	    FND_MESSAGE.SET_NAME('IEM','IEM_SSS_HOST_INVALID');
	    FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR ;
	    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

  WHEN host_invalid1 THEN
     	  select count(*) into l_count from all_db_links where upper(owner)=upper(l_schema_owner) and UPPER(db_link) = UPPER(l_glname);

   	  if l_count <> 0 then
		l_v_id := DBMS_SQL.OPEN_CURSOR;
		l_statement := 'DROP DATABASE LINK '||l_glname;
		DBMS_SQL.PARSE(l_v_id, l_statement, DBMS_SQL.native);
		l_num := DBMS_SQL.EXECUTE(l_v_id);
		DBMS_SQL.CLOSE_CURSOR(l_v_id);
	  end if;

    --    ROLLBACK TO CREATE_LINK_PVT;
	    FND_MESSAGE.SET_NAME('IEM','IEM_SSS_HOST_INVALID');
	    FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR ;
	    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

  WHEN db_conn_desc_invalid THEN
     	  select count(*) into l_count from all_db_links where upper(owner)=upper(l_schema_owner) and UPPER(db_link) = UPPER(l_glname);

   	  if l_count <> 0 then
		l_v_id := DBMS_SQL.OPEN_CURSOR;
		l_statement := 'DROP DATABASE LINK '||l_glname;
		DBMS_SQL.PARSE(l_v_id, l_statement, DBMS_SQL.native);
		l_num := DBMS_SQL.EXECUTE(l_v_id);
		DBMS_SQL.CLOSE_CURSOR(l_v_id);
	  end if;

    --    ROLLBACK TO CREATE_LINK_PVT;
	    FND_MESSAGE.SET_NAME('IEM','IEM_SSS_DBCONN_DESC_INVALID');
	    FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR ;
	    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

   WHEN FND_API.G_EXC_ERROR THEN
     	  select count(*) into l_count from all_db_links where upper(owner)=upper(l_schema_owner) and UPPER(db_link) = UPPER(l_glname);

   	  if l_count <> 0 then
		l_v_id := DBMS_SQL.OPEN_CURSOR;
		l_statement := 'DROP DATABASE LINK '||l_glname;
		DBMS_SQL.PARSE(l_v_id, l_statement, DBMS_SQL.native);
		l_num := DBMS_SQL.EXECUTE(l_v_id);
		DBMS_SQL.CLOSE_CURSOR(l_v_id);
	  end if;

  	ROLLBACK TO CREATE_LINK_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     	  select count(*) into l_count from all_db_links where upper(owner)=upper(l_schema_owner) and UPPER(db_link) = UPPER(l_glname);

   	  if l_count <> 0 then
		l_v_id := DBMS_SQL.OPEN_CURSOR;
		l_statement := 'DROP DATABASE LINK '||l_glname;
		DBMS_SQL.PARSE(l_v_id, l_statement, DBMS_SQL.native);
		l_num := DBMS_SQL.EXECUTE(l_v_id);
		DBMS_SQL.CLOSE_CURSOR(l_v_id);
	  end if;

	ROLLBACK TO CREATE_LINK_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
              	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
-- bugfixed for #1921152 Aug 6, 2001

 --   if SQLCODE <> -06561 then -- invalid user and password

	  select count(*) into l_count from all_db_links where upper(owner)=upper(l_schema_owner) and UPPER(db_link) = UPPER(l_glname);

   	  if l_count <> 0 then
		l_v_id := DBMS_SQL.OPEN_CURSOR;
		l_statement := 'DROP DATABASE LINK '||l_glname;
		DBMS_SQL.PARSE(l_v_id, l_statement, DBMS_SQL.native);
		l_num := DBMS_SQL.EXECUTE(l_v_id);
		DBMS_SQL.CLOSE_CURSOR(l_v_id);
	  end if;

 --   end if;
 --  ROLLBACK TO CREATE_LINK_PVT;
	--   FND_MESSAGE.SET_NAME('IEM','IEM_LINK_LOGIN_DENIED');
	--   FND_MSG_PUB.Add;
	   x_return_status := FND_API.G_RET_STS_ERROR ;
	   FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
	IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
   	    		(	G_PKG_NAME,
   	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		( p_count         	=>      x_msg_count,
       	p_data          	=>      x_msg_data
    		);

END create_link;

-- Start of Comments
--  API name 	: delete_link
--  Type	: 	Private
--  Function	: This procedure delete a record in the table IEM_DB_CONNECTIONS
--  Pre-reqs	: 	None.
--  Parameters	:
--	IN
--  p_api_version_number    	IN NUMBER	Required
--  p_init_msg_list	IN VARCHAR2
--  p_commit	IN VARCHAR2
--  p_db_connection_id	in numbe
--
--	OUT
--   x_return_status	OUT	VARCHAR2
--	x_msg_count	OUT	NUMBER
--	x_msg_data	OUT	VARCHAR2
--
--	Version	: 1.0
--	Notes		:
--
-- End of comments
-- **********************************************************

PROCEDURE delete_link (p_api_version_number  IN   NUMBER,
 		  	      p_init_msg_list  		IN   VARCHAR2,
		    	      p_commit	    			IN   VARCHAR2,
			 	 p_db_connection_id 	IN   NUMBER,
			      x_return_status	 OUT NOCOPY VARCHAR2,
  		  	      x_msg_count	       OUT NOCOPY    NUMBER,
	  	  	      x_msg_data		 OUT NOCOPY VARCHAR2
			 ) is
			 TYPE LinkCur Is REF CURSOR;
	l_api_name        		VARCHAR2(255):='delete_link';
	l_api_version_number 	NUMBER:=1.0;
	l_dblink				VARCHAR2(128);
	l_iem_dbconn_rec		IEM_DB_CONNECTIONS%ROWTYPE;
	l_v_id				NUMBER;
	l_num				NUMBER;
	l_statement			VARCHAR2(2000);
	link_does_not_exist		EXCEPTION;
	l_grp_cnt 			NUMBER;
	l_link_cur			LinkCur;
    PRAGMA  EXCEPTION_INIT(link_does_not_exist , -02024);
BEGIN
-- Standard Start of API savepoint
--SAVEPOINT		delete_link_pvt;
-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call (l_api_version_number,
				    p_api_version_number,
				    l_api_name,
				    G_PKG_NAME)
THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
-- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
     FND_MSG_PUB.initialize;
   END IF;
-- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Standard Start of API savepoint
   -- SAVEPOINT		delete_link_pvt;

   select * INTO l_iem_dbconn_rec from IEM_DB_CONNECTIONS where DB_CONNECTION_ID = p_db_connection_id;
--   select db_link into l_dblink from iem_db_connections where db_connection_id = p_db_connection_id;

IF (l_iem_dbconn_rec.is_admin <> 'O') then

   l_v_id := DBMS_SQL.OPEN_CURSOR;

   l_statement := 'DROP DATABASE LINK '||l_iem_dbconn_rec.db_link;

	DBMS_SQL.PARSE(l_v_id, l_statement, DBMS_SQL.native);

	l_num := DBMS_SQL.EXECUTE(l_v_id);

	DBMS_SQL.CLOSE_CURSOR(l_v_id);

END IF;
-- Standard Start of API savepoint
SAVEPOINT		delete_link_pvt;
	-- check if db link dropped successfully
	IEM_DB_CONNECTIONS_PVT.delete_item(
			p_api_version_number => 1.0,
			p_db_conn_id => p_db_connection_id,
			x_msg_count => x_msg_count,
			x_return_status => x_return_status,
			x_msg_data => x_msg_data);

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
   WHEN link_does_not_exist THEN
        --bugfix 1944746-----------
        -- If the link does not exist, remove from iem_db_connection directly to avoid garbage data

       IEM_DB_CONNECTIONS_PVT.delete_item(
			p_api_version_number => 1.0,
			p_db_conn_id => p_db_connection_id,
			x_msg_count => x_msg_count,
			x_return_status => x_return_status,
			x_msg_data => x_msg_data);

-- Standard Check Of p_commit.
	   IF FND_API.To_Boolean(p_commit) THEN
		  COMMIT WORK;
	   END IF;
       --end bugfix1944746---------------------
   WHEN FND_API.G_EXC_ERROR THEN
	  ROLLBACK TO delete_link_pvt;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
              p_data  => x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	  ROLLBACK TO delete_link_pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  => x_msg_data
			);
   WHEN OTHERS THEN
	   FND_MESSAGE.SET_NAME('IEM','IEM_LINK_DOES_NOT_EXIST');
	   FND_MSG_PUB.Add;
	   x_return_status := FND_API.G_RET_STS_ERROR ;
	   --FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
	   --ROLLBACK TO delete_link_pvt;
      --x_return_status := FND_API.G_RET_STS_ERROR;
	   IF FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	   THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
	   END IF;
	   FND_MSG_PUB.Count_And_Get
    		( p_count         	=>      x_msg_count     	,
        	p_data          	=>      x_msg_data
    		);

END delete_link;

END IEM_DBLINK_PVT;

/
