--------------------------------------------------------
--  DDL for Package Body IEM_CONFIGURATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_CONFIGURATION_PUB" as
/* $Header: iempcfgb.pls 115.3 2002/12/04 01:22:44 chtang noship $*/

G_PKG_NAME CONSTANT varchar2(30) :='IEM_CONFIGURATION_PUB ';

PROCEDURE GetConfiguration(ERRBUF		VARCHAR2,
		   ERRRET		VARCHAR2,
			p_api_version_number    IN   NUMBER := 1,
 		        p_init_msg_list  IN   VARCHAR2 := FND_API.G_FALSE,
		        p_commit	    IN   VARCHAR2 := FND_API.G_TRUE
				 ) IS
		l_api_name        		VARCHAR2(255):='GetConfiguration';
		l_api_version_number 	NUMBER:=1.0;
 		l_call_status             BOOLEAN;
 		l_count			NUMBER:=0;
 		l_counter		NUMBER:=0;
 		l_counter1		NUMBER:=0;
 		l_return_status		varchar2(20);
		l_msg_count		number;
		l_msg_data		varchar2(300);
		l_Error_Message           VARCHAR2(2000);
		l_profile_value		varchar2(200);
		l_account_name		varchar(500);
		l_server_group_rec		IEM_SERVER_GROUPS%ROWTYPE;
		l_db_server_rec			IEM_DB_SERVERS%ROWTYPE;
		l_db_connection_rec		IEM_DB_CONNECTIONS%ROWTYPE;
		l_email_server_rec		IEM_EMAIL_SERVERS%ROWTYPE;
		l_email_account_rec		IEM_EMAIL_ACCOUNTS%ROWTYPE;
		l_classification_rec		IEM_CLASSIFICATIONS%ROWTYPE;
		l_theme_rec			IEM_THEMES%ROWTYPE;
		l_agent_account_rec		IEM_AGENT_ACCOUNTS%ROWTYPE;
		Cursor csr_server_group is select * from iem_server_groups;
		Cursor csr_db_server is select * from iem_db_servers;
		Cursor csr_db_connection is select * from iem_db_connections;
		Cursor csr_email_server is select * from iem_email_servers;
		Cursor csr_email_account is select * from iem_email_accounts;
		Cursor csr_classification is select * from iem_classifications;
		Cursor csr_agent_account is select * from iem_agent_accounts;
		CURSOR csr_theme( l_classification_id IN NUMBER )  IS
            		select * from iem_themes where classification_id = l_classification_id ;


BEGIN
-- Standard Start of API savepoint
SAVEPOINT		GetConfiguration_PUB;
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
     l_Error_Message := '--------------eMail Center Configuration Details --------------';
     fnd_file.put_line(fnd_file.log, l_Error_Message);

     -- Server Group
     select count(*) into l_count from iem_server_groups;

     l_Error_Message := '*** SERVER GROUP (IEM_SERVER_GROUPS) Total # of rows: ' || l_count || ' *** ';
     fnd_file.put_line(fnd_file.log, l_Error_Message);

     fnd_file.put_line(fnd_file.log, 'row_id, server_group_id, group_name');


    	OPEN csr_server_group;

		LOOP
			FETCH csr_server_group INTO l_server_group_rec;
				EXIT WHEN csr_server_group%NOTFOUND;

    				fnd_file.put_line(fnd_file.log, l_counter || ', ' || l_server_group_rec.server_group_id || ', ' || l_server_group_rec.group_name);
    				l_counter := l_counter + 1;

		END LOOP;
  	close csr_server_group;

     -- Database Server
     select count(*) into l_count from iem_db_servers;
     l_counter := 0;

     fnd_file.put_line(fnd_file.log, '   ');  -- blank lines
     l_Error_Message := '*** Database Server (IEM_DB_SERVERS) Total # of rows: ' || l_count || ' *** ';
     fnd_file.put_line(fnd_file.log, l_Error_Message);

     fnd_file.put_line(fnd_file.log, 'row_id, db_server_id, db_name, hostname, port, protocol, sid, service_name, server_group_id, rt_availability, email_node, admin_user');

    	OPEN csr_db_server;

		LOOP
			FETCH csr_db_server INTO l_db_server_rec;
				EXIT WHEN csr_db_server%NOTFOUND;

    				fnd_file.put_line(fnd_file.log, l_counter || ', ' || l_db_server_rec.db_server_id || ', ' || l_db_server_rec.db_name || ', ' ||
    				l_db_server_rec.hostname || ', ' || l_db_server_rec.port || ', ' || l_db_server_rec.protocol || ', ' || l_db_server_rec.sid ||
    				', ' || l_db_server_rec.service_name || ', ' || l_db_server_rec.server_group_id || ', ' || l_db_server_rec.rt_availability ||
    				', ' || l_db_server_rec.email_node || ', ' || l_db_server_rec.admin_user);

				l_counter := l_counter + 1;

		END LOOP;
  	close csr_db_server;

      -- Database Connection
     select count(*) into l_count from iem_db_connections;
     l_counter := 0;

     fnd_file.put_line(fnd_file.log, '   ');  -- blank lines
     l_Error_Message := '*** Database Connection (IEM_DB_CONNECTIONS) Total # of rows: ' || l_count || ' *** ';
     fnd_file.put_line(fnd_file.log, l_Error_Message);


     fnd_file.put_line(fnd_file.log, 'row_id, db_connection_id, db_link, db_username, db_server_id, is_admin');

    	OPEN csr_db_connection;

		LOOP
			FETCH csr_db_connection INTO l_db_connection_rec;
				EXIT WHEN csr_db_connection%NOTFOUND;

    				fnd_file.put_line(fnd_file.log, l_counter || ', ' || l_db_connection_rec.db_connection_id || ', ' ||
    				l_db_connection_rec.db_link || ', ' || l_db_connection_rec.db_username || ', ' || l_db_connection_rec.db_server_id || ', ' ||
    				l_db_connection_rec.is_admin);

				l_counter := l_counter + 1;

		END LOOP;
  	close csr_db_connection;

     -- Email Server
     select count(*) into l_count from iem_email_servers;
     l_counter := 0;

     fnd_file.put_line(fnd_file.log, '   ');  -- blank lines
     l_Error_Message := '*** EMAIL SERVER (IEM_EMAIL_SERVERS) Total # of rows: ' || l_count || ' *** ';
     fnd_file.put_line(fnd_file.log, l_Error_Message);

     fnd_file.put_line(fnd_file.log, 'row_id, email_server_id, server_name, dns_name, ip_address, port, server_type_id, rt_availability, server_group_id');

    	OPEN csr_email_server;

		LOOP
			FETCH csr_email_server INTO l_email_server_rec;
				EXIT WHEN csr_email_server%NOTFOUND;

    				fnd_file.put_line(fnd_file.log, l_counter || ', ' || l_email_server_rec.email_server_id || ', ' ||
    				l_email_server_rec.server_name || ', ' || l_email_server_rec.dns_name  || ', ' || l_email_server_rec.ip_address || ', ' ||
    				l_email_server_rec.port || ', ' || l_email_server_rec.server_type_id || ', ' || l_email_server_rec.rt_availability || ', ' ||
    				l_email_server_rec.server_group_id );

				l_counter := l_counter + 1;

		END LOOP;
  	close csr_email_server;

     -- Email Account
     select count(*) into l_count from iem_email_accounts;
     l_counter := 0;

     fnd_file.put_line(fnd_file.log, '   ');  -- blank lines
     l_Error_Message := '*** EMAIL ACCOUNT (IEM_EMAIL_ACCOUNTS) Total # of rows: ' || l_count || ' *** ';
     fnd_file.put_line(fnd_file.log, l_Error_Message);

     fnd_file.put_line(fnd_file.log, 'row_id, email_account_id, account_name, email_user, domain, db_server_id, server_group_id, acct_language, reply_to_address, from_name, intent_enabled, custom_enabled');

    	OPEN csr_email_account;

		LOOP
			FETCH csr_email_account INTO l_email_account_rec;
				EXIT WHEN csr_email_account%NOTFOUND;

    				fnd_file.put_line(fnd_file.log, l_counter || ', ' || l_email_account_rec.email_account_id || ', ' ||
    				l_email_account_rec.account_name || ', ' || l_email_account_rec.email_user || ', ' || l_email_account_rec.domain || ', ' ||
    				l_email_account_rec.db_server_id || ', ' || l_email_account_rec.server_group_id || ', ' || l_email_account_rec.acct_language ||
    				', ' || l_email_account_rec.reply_to_address || ', ' || l_email_account_rec.from_name || ', ' ||
    				l_email_account_rec.intent_enabled || ', ' || l_email_account_rec.custom_enabled);

				l_counter := l_counter + 1;

		END LOOP;
  	close csr_email_account;

  	 -- Intent
     select count(*) into l_count from iem_classifications;
     l_counter := 0;

     fnd_file.put_line(fnd_file.log, '   ');  -- blank lines
     l_Error_Message := '*** INTENT (IEM_CLASSIFICATIONS) Total # of rows: ' || l_count || ' *** ';
     fnd_file.put_line(fnd_file.log, l_Error_Message);

     fnd_file.put_line(fnd_file.log, 'row_id, classification_id, account_name, classification, created_by, creation_date, last_updated_by, last_update_date');

    	OPEN csr_classification;

		LOOP
			FETCH csr_classification INTO l_classification_rec;
				EXIT WHEN csr_classification%NOTFOUND;

				select email_user||'@'||domain as account_name into l_account_name from iem_email_accounts where email_account_id= l_classification_rec.email_account_id;

				fnd_file.put_line(fnd_file.log, '   ');  -- blank lines
				fnd_file.put_line(fnd_file.log, 'INTENT : ' || l_counter || ', ' || l_classification_rec.classification_id || ', ' ||
    					l_account_name || ', ' ||  l_classification_rec.classification || ', ' ||
    					l_classification_rec.created_by || ', ' ||  l_classification_rec.creation_date || ', ' ||
    					l_classification_rec.last_updated_by || ', ' ||  l_classification_rec.last_update_date);

					l_counter := l_counter + 1;
					l_counter1 := 0;

					-- Keyword
     				select count(*) into l_count from iem_themes where classification_id=l_classification_rec.classification_id;

				l_Error_Message := '      *** KEYWORD (IEM_THEMES) Total # of rows: ' || l_count || ' *** ';
     				fnd_file.put_line(fnd_file.log, l_Error_Message);

     				fnd_file.put_line(fnd_file.log, '      row_id, theme_id, theme, score, query_response, created_by, creation_date, last_updated_by, last_update_date');


				FOR l_theme_rec IN csr_theme(l_classification_rec.classification_id)  LOOP

    					fnd_file.put_line(fnd_file.log, '              ' || l_counter1 || ', ' || l_theme_rec.theme_id || ', ' || l_theme_rec.theme ||
    					', ' || l_theme_rec.score || ', ' || l_theme_rec.query_response || ', ' ||
    					l_theme_rec.created_by || ', ' ||  l_theme_rec.creation_date || ', ' ||
    					l_theme_rec.last_updated_by || ', ' ||  l_theme_rec.last_update_date);

					l_counter1 := l_counter1 + 1;

				END LOOP;

		END LOOP;
  	close csr_classification;

     -- Agent Account
     select count(*) into l_count from iem_agent_accounts;
     l_counter := 0;

     fnd_file.put_line(fnd_file.log, '   ');  -- blank lines
     l_Error_Message := '*** AGENT ACCOUNT (IEM_AGENT_ACCOUNTS) Total # of rows: ' || l_count || ' *** ';
     fnd_file.put_line(fnd_file.log, l_Error_Message);

     fnd_file.put_line(fnd_file.log, 'row_id, email_account_id, account_name, email_user, domain, db_server_id, server_group_id, acct_language, reply_to_address, from_name, intent_enabled, custom_enabled');

    	OPEN csr_agent_account;

		LOOP
			FETCH csr_agent_account INTO l_agent_account_rec;
				EXIT WHEN csr_agent_account%NOTFOUND;

    				fnd_file.put_line(fnd_file.log, l_counter || ', ' || l_agent_account_rec.agent_account_id || ', ' ||
    				l_agent_account_rec.email_account_id || ', ' || l_agent_account_rec.account_name || ', ' || l_agent_account_rec.email_user ||
    				', ' || l_agent_account_rec.domain || ', ' || l_agent_account_rec.reply_to_address || ', ' || l_agent_account_rec.from_address ||
    				 ', ' || l_agent_account_rec.resource_id || ', ' || l_agent_account_rec.signature || ', ' || l_agent_account_rec.user_name ||
    				 ', ' || l_agent_account_rec.from_name);

				l_counter := l_counter + 1;

		END LOOP;
  	close csr_agent_account;

        -- eMC Profile Values
        fnd_file.put_line(fnd_file.log, '   ');  -- blank lines
     	l_Error_Message := '*** eMail Center Profile Values *** ';
        fnd_file.put_line(fnd_file.log, l_Error_Message);

     	iem_parameters_pvt.select_profile (p_api_version_number =>1.0,
 		          p_init_msg_list => FND_API.G_FALSE,
		          p_commit => FND_API.G_FALSE,
  			  p_profile_name  => 'IEM_ACCOUNT_SENDER_NAME',
  			  x_profile_value => l_profile_value,
             		  x_return_status => l_return_status,
  		  	  x_msg_count => l_msg_count,
	  	  	  x_msg_data=> l_msg_data);

	l_Error_Message := 'IEM_ACCOUNT_SENDER_NAME : ' || l_profile_value;
     	fnd_file.put_line(fnd_file.log, l_Error_Message);

     	iem_parameters_pvt.select_profile (p_api_version_number =>1.0,
 		          p_init_msg_list => FND_API.G_FALSE,
		          p_commit => FND_API.G_FALSE,
  			  p_profile_name  => 'IEM_CACHE_UPDATE_FREQ',
  			  x_profile_value => l_profile_value,
             		  x_return_status => l_return_status,
  		  	  x_msg_count => l_msg_count,
	  	  	  x_msg_data=> l_msg_data);

	l_Error_Message := 'IEM_CACHE_UPDATE_FREQ : ' || l_profile_value;
     	fnd_file.put_line(fnd_file.log, l_Error_Message);

	iem_parameters_pvt.select_profile (p_api_version_number =>1.0,
 		          p_init_msg_list => FND_API.G_FALSE,
		          p_commit => FND_API.G_FALSE,
  			  p_profile_name  => 'IEM_DEFAULT_CUSTOMER_ID',
  			  x_profile_value => l_profile_value,
             		  x_return_status => l_return_status,
  		  	  x_msg_count => l_msg_count,
	  	  	  x_msg_data=> l_msg_data);

	l_Error_Message := 'IEM_DEFAULT_CUSTOMER_ID : ' || l_profile_value;
     	fnd_file.put_line(fnd_file.log, l_Error_Message);

     	iem_parameters_pvt.select_profile (p_api_version_number =>1.0,
 		          p_init_msg_list => FND_API.G_FALSE,
		          p_commit => FND_API.G_FALSE,
  			  p_profile_name  => 'IEM_DEFAULT_CUSTOMER_NUMBER',
  			  x_profile_value => l_profile_value,
             		  x_return_status => l_return_status,
  		  	  x_msg_count => l_msg_count,
	  	  	  x_msg_data=> l_msg_data);

	l_Error_Message := 'IEM_DEFAULT_CUSTOMER_NUMBER : ' || l_profile_value;
     	fnd_file.put_line(fnd_file.log, l_Error_Message);

     	iem_parameters_pvt.select_profile (p_api_version_number =>1.0,
 		          p_init_msg_list => FND_API.G_FALSE,
		          p_commit => FND_API.G_FALSE,
  			  p_profile_name  => 'IEM_DEFAULT_RESOURCE_NUMBER',
  			  x_profile_value => l_profile_value,
             		  x_return_status => l_return_status,
  		  	  x_msg_count => l_msg_count,
	  	  	  x_msg_data=> l_msg_data);

	l_Error_Message := 'IEM_DEFAULT_RESOURCE_NUMBER : ' || l_profile_value;
     	fnd_file.put_line(fnd_file.log, l_Error_Message);

     	iem_parameters_pvt.select_profile (p_api_version_number =>1.0,
 		          p_init_msg_list => FND_API.G_FALSE,
		          p_commit => FND_API.G_FALSE,
  			  p_profile_name  => 'IEM_INTENT_RESPONSE_NUM',
  			  x_profile_value => l_profile_value,
             		  x_return_status => l_return_status,
  		  	  x_msg_count => l_msg_count,
	  	  	  x_msg_data=> l_msg_data);

	l_Error_Message := 'IEM_INTENT_RESPONSE_NUM : ' || l_profile_value;
     	fnd_file.put_line(fnd_file.log, l_Error_Message);

     	iem_parameters_pvt.select_profile (p_api_version_number =>1.0,
 		          p_init_msg_list => FND_API.G_FALSE,
		          p_commit => FND_API.G_FALSE,
  			  p_profile_name  => 'IEM_KNOWLEDGE_BASE',
  			  x_profile_value => l_profile_value,
             		  x_return_status => l_return_status,
  		  	  x_msg_count => l_msg_count,
	  	  	  x_msg_data=> l_msg_data);

	l_Error_Message := 'IEM_KNOWLEDGE_BASE : ' || l_profile_value;
     	fnd_file.put_line(fnd_file.log, l_Error_Message);

     	iem_parameters_pvt.select_profile (p_api_version_number =>1.0,
 		          p_init_msg_list => FND_API.G_FALSE,
		          p_commit => FND_API.G_FALSE,
  			  p_profile_name  => 'IEM_SRVRPROC_APENABLE',
  			  x_profile_value => l_profile_value,
             		  x_return_status => l_return_status,
  		  	  x_msg_count => l_msg_count,
	  	  	  x_msg_data=> l_msg_data);

	l_Error_Message := 'IEM_SRVRPROC_APENABLE : ' || l_profile_value;
     	fnd_file.put_line(fnd_file.log, l_Error_Message);

	iem_parameters_pvt.select_profile (p_api_version_number =>1.0,
 		          p_init_msg_list => FND_API.G_FALSE,
		          p_commit => FND_API.G_FALSE,
  			  p_profile_name  => 'IEM_SRVR_ARES',
  			  x_profile_value => l_profile_value,
             		  x_return_status => l_return_status,
  		  	  x_msg_count => l_msg_count,
	  	  	  x_msg_data=> l_msg_data);

	l_Error_Message := 'IEM_SRVR_ARES : ' || l_profile_value;
     	fnd_file.put_line(fnd_file.log, l_Error_Message);

     	iem_parameters_pvt.select_profile (p_api_version_number =>1.0,
 		          p_init_msg_list => FND_API.G_FALSE,
		          p_commit => FND_API.G_FALSE,
  			  p_profile_name  => 'IEM_SRVR_AROUTE',
  			  x_profile_value => l_profile_value,
             		  x_return_status => l_return_status,
  		  	  x_msg_count => l_msg_count,
	  	  	  x_msg_data=> l_msg_data);

	l_Error_Message := 'IEM_SRVR_AROUTE : ' || l_profile_value;
     	fnd_file.put_line(fnd_file.log, l_Error_Message);


	iem_parameters_pvt.select_profile (p_api_version_number =>1.0,
 		          p_init_msg_list => FND_API.G_FALSE,
		          p_commit => FND_API.G_FALSE,
  			  p_profile_name  => 'IEM_SRVR_ASRUPD',
  			  x_profile_value => l_profile_value,
             		  x_return_status => l_return_status,
  		  	  x_msg_count => l_msg_count,
	  	  	  x_msg_data=> l_msg_data);

	l_Error_Message := 'IEM_SRVR_ASRUPD : ' || l_profile_value;
     	fnd_file.put_line(fnd_file.log, l_Error_Message);

	iem_parameters_pvt.select_profile (p_api_version_number =>1.0,
 		          p_init_msg_list => FND_API.G_FALSE,
		          p_commit => FND_API.G_FALSE,
  			  p_profile_name  => 'IEM_SRVR_SRST',
  			  x_profile_value => l_profile_value,
             		  x_return_status => l_return_status,
  		  	  x_msg_count => l_msg_count,
	  	  	  x_msg_data=> l_msg_data);

	l_Error_Message := 'IEM_SRVR_SRST : ' || l_profile_value;
     	fnd_file.put_line(fnd_file.log, l_Error_Message);


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO GetConfiguration_PUB;
        FND_MESSAGE.SET_NAME('IEM','IEM_COLLECTCONFIG_EXEC_ERROR');
        l_Error_Message := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, l_Error_Message);
        l_call_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_Error_Message);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO GetConfiguration_PUB;
        FND_MESSAGE.SET_NAME('IEM','IEM_COLLECTCONFIG_UNXPTD_ERR');
        l_Error_Message := FND_MESSAGE.GET;
        fnd_file.put_line(fnd_file.log, l_Error_Message);
        l_call_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_Error_Message);
   WHEN OTHERS THEN
	ROLLBACK TO GetConfiguration_PUB;
        FND_MESSAGE.SET_NAME('IEM','IEM_COLLECTCONFIG_OTHER_ERR');
        l_Error_Message := SQLERRM;
        fnd_file.put_line(fnd_file.log, l_Error_Message);
        l_call_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_Error_Message);

 END GetConfiguration;


END IEM_CONFIGURATION_PUB ;

/
