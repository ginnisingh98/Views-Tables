--------------------------------------------------------
--  DDL for Package Body IEM_MS_MSGMETA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_MS_MSGMETA_PVT" AS
/* $Header: iemvhdrb.pls 120.2 2005/08/24 15:59:31 appldev noship $ */
--
--
-- Purpose: Mantain message store header tables
--
-- MODIFICATION HISTORY
-- Person      Date         Comments
--  Liang Xia   10/5/2004    Created
--  Liang Xia   10/16/2004   Redefined interface of create_headers
--  Liang Xia   12/16/2004   Fixed problem when extheader value length larger than 256
--  Liang Xia   08/18/2005   Changed create_msg_meta to accept message_id for DPM
--		  					 trucate headers to fit into schema.
-- ---------   ------  ------------------------------------------


-- Enter procedure, function bodies as shown below
G_PKG_NAME CONSTANT varchar2(30) :='IEM_MS_MSGMETA_PVT ';
G_created_updated_by   NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('USER_ID')) ;
G_LAST_UPDATE_LOGIN    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('LOGIN_ID') ) ;

PROCEDURE create_msg_meta (
                 p_api_version_number  IN   NUMBER,
		 p_init_msg_list       IN   VARCHAR2 := null,
		 p_commit              IN   VARCHAR2 := null,
            	 P_subject             IN   VARCHAR2,
		 p_sent_date   	       IN   VARCHAR2, --DATE,
                 p_priority            IN   VARCHAR2,
                 p_msg_id              IN   VARCHAR2,
                 p_UID                 IN   NUMBER,
                 p_x_mailer            IN   varchar2,
                 p_language            IN   varchar2,
                 p_content_type        IN   varchar2,
                 p_organization        IN   varchar2,
		 p_message_size	       IN   NUMBER,
                 p_email_account       IN   NUMBER,
		 p_from		       IN   varchar2,
		 p_to		       IN   varchar2,
		 p_cc		       IN   varchar2,
		 p_reply_to	       IN   varchar2,
		 p_message_id	   in 	NUMBER,
                 x_ref_key             OUT NOCOPY varchar2,
                 x_return_status	   OUT  NOCOPY VARCHAR2,
  		  	     x_msg_count	       OUT	NOCOPY NUMBER,
	  	  	     x_msg_data	           OUT	NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='create_item_tag';
	l_api_version_number 	NUMBER:=1.0;
    l_seq_id		        NUMBER;

    l_return_status         VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER := 0;
    l_msg_data              VARCHAR2(2000);

    l_subject               VARCHAR2(2000);
  	l_sent_date   	        VARCHAR2(60);
	l_to   	        		VARCHAR2(2000);
	l_cc   	        		VARCHAR2(2000);
	l_reply_to   	        VARCHAR2(256);
	l_from					VARCHAR2(2000);
	l_CONTENT_TYPE			VARCHAR2(256);
	l_ORGANIZATION 			VARCHAR2(256);
	l_LANGUAGE				VARCHAR2(256);

    l_recieved_date         DATE := sysdate;
    l_priority              VARCHAR2(256);
    l_size                  NUMBER;
    l_rfcmsg_id             VARCHAR2(256);
    l_UID                   NUMBER;
    l_system_flag           VARCHAR2(256);
    l_x_mailer              VARCHAR2(256);

BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT		create_item_tag_PVT;

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

   --begins here

    --get next sequential number for msg_meta_id
   	--SELECT iem_ms_mimemsgs_s1.nextval
	if ( p_message_id = -1 ) then
   	   SELECT iem_ms_base_headers_s1.nextval
	   INTO l_seq_id
	   FROM dual;
	else
		l_seq_id := p_message_id;
	end if;

	l_subject := substr(p_subject, 1, 2000);
	l_sent_date := substr(p_sent_date, 1, 60);
	l_cc := substr(p_cc, 1, 2000);
	l_to := substr(p_to, 1, 2000);
	l_reply_to := substr(p_reply_to, 1, 256);
	l_from := substr(p_from, 1, 2000);
	l_rfcmsg_id := substr(p_msg_id, 1, 256);
	l_priority := substr(p_priority, 1, 256);
	l_CONTENT_TYPE := substr(p_content_type, 1, 256);
	l_ORGANIZATION := substr(p_organization, 1, 256);
	 l_x_mailer := substr(p_x_mailer, 1, 256);
	 l_LANGUAGE := substr(p_language, 1, 256);


	INSERT INTO IEM_MS_BASE_HEADERS
	(
	MESSAGE_ID,
	EMAIL_ACCOUNT_ID,
	SUBJECT,
    	SENT_DATE,
    	RECEIVED_DATE,
 	FROM_STR,
	TO_STR,
	CC_STR,
	REPLY_TO_STR,
    	PRIORITY,
    	RFC822_MESSAGE_ID,
    	MESSAGE_UID,
    	MAILER,
    	LANGUAGE,
    	CONTENT_TYPE,
    	ORGANIZATION,
	MESSAGE_SIZE,
    	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN
	)
	VALUES
	(
	l_seq_id,
	p_email_account,
	l_subject,
	l_sent_date,
    	sysdate,
	l_from,
	l_to,
	l_cc ,
	l_reply_to,
    	l_priority,
    	l_rfcmsg_id,
    	p_uid,
    	l_x_mailer,
    	l_language,
    	l_content_type,
    	l_organization,
	p_message_size,
    decode(G_created_updated_by,null,-1,G_created_updated_by),
	sysdate,
    decode(G_created_updated_by,null,-1,G_created_updated_by),
    sysdate,
    decode(G_LAST_UPDATE_LOGIN,null,-1,G_LAST_UPDATE_LOGIN)
	);

    -- Standard Check Of p_commit.
    IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;
    x_ref_key := l_seq_id;

    -- Standard callto get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
			( p_count =>  x_msg_count,
                 	p_data  =>    x_msg_data
			);

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO create_item_tag_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get

			( p_count => x_msg_count,
              p_data  => x_msg_data
			);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   ROLLBACK TO create_item_tag_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
              p_data  =>      x_msg_data
			);

   WHEN OTHERS THEN
	ROLLBACK TO create_item_tag_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
	IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
    	FND_MSG_PUB.Add_Exc_Msg
	    	(	G_PKG_NAME ,
	    		l_api_name
	    	);
	END IF;

	FND_MSG_PUB.Count_And_Get
    		( p_count         	=>      x_msg_count,
        	p_data          	=>      x_msg_data

    		);

 END	create_msg_meta;



PROCEDURE create_headers(
                 p_api_version_number  IN   NUMBER,
 		  	     p_init_msg_list       IN   VARCHAR2 := null,
		    	 p_commit              IN   VARCHAR2 := null,
                 p_msg_meta_id         IN  jtf_varchar2_Table_100,
                 p_name_tbl            IN  jtf_varchar2_Table_300,
  	             p_value_tbl           IN  jtf_varchar2_Table_2000,
                 x_return_status	   OUT  NOCOPY VARCHAR2,
  		  	     x_msg_count	       OUT	NOCOPY NUMBER,
	  	  	     x_msg_data	           OUT	NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):= 'create_headers';
	l_api_version_number 	NUMBER:=1.0;
    l_seq_id		        NUMBER;

    l_return_status         VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER := 0;
    l_msg_data              VARCHAR2(2000);

    --l_seq_id    number;
    l_msg_meta_id           NUMBER;
	--l_name               VARCHAR2(256);
    l_name                  VARCHAR2(60);
  	l_value   	        VARCHAR2(2000);
	--l_value    				VARCHAR2(256);
    l_type                  VARCHAR2(100);

BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT		create_sender_recipient_PVT;

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

   --begins here
    FOR i IN p_msg_meta_id.FIRST..p_msg_meta_id.LAST LOOP

       SELECT iem_ms_EXTHDRS_s1.nextval
	   INTO l_seq_id
	   FROM dual;

        l_msg_meta_id := p_msg_meta_id(i);
        l_name := substr( p_name_tbl(i),1,59);
        l_value := substr( p_value_tbl(i), 1, 1999 );

	    INSERT INTO IEM_MS_EXTHDRS
	    (
	       EXT_HEADER_ID,
            MESSAGE_ID,
	        NAME,
        	value,
        	CREATED_BY,
          CREATION_DATE,
          LAST_UPDATED_BY,
	       LAST_UPDATE_DATE,
	       LAST_UPDATE_LOGIN
	        )
	    VALUES
	        (
	        l_seq_id,
	         l_msg_meta_id,
             	l_name,
             	l_value,
            decode(G_created_updated_by,null,-1,G_created_updated_by),
	        sysdate,
            decode(G_created_updated_by,null,-1,G_created_updated_by),
            sysdate,
            decode(G_LAST_UPDATE_LOGIN,null,-1,G_LAST_UPDATE_LOGIN)
	    );
    end loop;

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

   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO create_sender_recipient_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get

			( p_count => x_msg_count,
              p_data  => x_msg_data
			);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   ROLLBACK TO create_sender_recipient_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
              p_data  =>      x_msg_data
			);

   WHEN OTHERS THEN
	ROLLBACK TO create_sender_recipient_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
	IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
    	FND_MSG_PUB.Add_Exc_Msg
	    	(	G_PKG_NAME ,
	    		l_api_name
	    	);
	END IF;

	FND_MSG_PUB.Count_And_Get
    		( p_count         	=>      x_msg_count,
        	p_data          	=>      x_msg_data

    		);

 END	create_headers;

PROCEDURE create_string_msg_body(
                 p_api_version_number  IN   NUMBER,
		 p_init_msg_list       IN   VARCHAR2,
		 p_commit              IN   VARCHAR2,
                 p_message_id          IN   NUMBER,
                 p_part_type           IN   varchar2,
                 p_msg_body            IN  jtf_varchar2_Table_2000,
                 x_return_status       OUT  NOCOPY VARCHAR2,
  	  	 x_msg_count	       OUT	NOCOPY NUMBER,
	  	 x_msg_data	       OUT	NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):= 'create_string_msg_body';
	l_api_version_number 	NUMBER:=1.0;
    l_seq_id		        NUMBER;

    l_return_status         VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER := 0;
    l_msg_data              VARCHAR2(2000);

    l_msg_meta_id           NUMBER;
    l_name                  VARCHAR2(256);
  	l_value   	            VARCHAR2(2000);
    l_type                  VARCHAR2(30);

    l_EMCMSG_PART_ID   number;
BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT		create_sender_recipient_PVT;

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

   --begins here

    FOR i IN p_msg_body.FIRST..p_msg_body.LAST LOOP

        l_value := p_msg_body(i);

	    INSERT INTO IEM_MS_MSGBODYS
	    (
            	MESSAGE_ID,
	        ORDER_ID,
	        VALUE,
           	TYPE,
            CREATED_BY,
	        CREATION_DATE,
            LAST_UPDATED_BY,
	        LAST_UPDATE_DATE,
	        LAST_UPDATE_LOGIN
	        )
	    VALUES
	        (
	         p_message_id,
	         i,
          	 l_value,
           	 p_part_type,

           decode(G_created_updated_by,null,-1,G_created_updated_by),
            sysdate,
            decode(G_created_updated_by,null,-1,G_created_updated_by),
           sysdate,
           decode(G_LAST_UPDATE_LOGIN,null,-1,G_LAST_UPDATE_LOGIN)
	    );
    end loop;

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

   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO create_sender_recipient_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get

			( p_count => x_msg_count,
              p_data  => x_msg_data
			);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   ROLLBACK TO create_sender_recipient_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
              p_data  =>      x_msg_data
			);

   WHEN OTHERS THEN
	ROLLBACK TO create_sender_recipient_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
	IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
    	FND_MSG_PUB.Add_Exc_Msg
	    	(	G_PKG_NAME ,
	    		l_api_name
	    	);
	END IF;

	FND_MSG_PUB.Count_And_Get
    		( p_count         	=>      x_msg_count,
        	p_data          	=>      x_msg_data

    		);

 END	create_string_msg_body;

PROCEDURE insert_preproc_wrapper (
                 p_api_version_number  IN   NUMBER,
 		  	     p_init_msg_list       IN   VARCHAR2 := null,
		    	 p_commit              IN   VARCHAR2 := null,
            	 p_msg_id              IN   NUMBER,
  				 p_acct_id   	       IN   NUMBER,
                 p_priority            IN   NUMBER,
                 x_return_status	   OUT  NOCOPY VARCHAR2,
  		  	     x_msg_count	       OUT	NOCOPY NUMBER,
	  	  	     x_msg_data	           OUT	NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='insert_preproc_wrapper';
	l_api_version_number 	NUMBER:=1.0;
    l_seq_id		        NUMBER;

    l_return_status         VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER := 0;
    l_msg_data              VARCHAR2(2000);

    l_received_date         DATE := sysdate;

BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT		insert_preproc_wrapper_PVT;

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

   --begins here

    --get next sequential number for msg_meta_id
   -- select to_date(recieved_date) into l_received_date from iem_base_headers where base_header_id = p_msg_id;


    IEM_RT_PREPROC_EMAILS_PVT.create_item(
        p_api_version_number => 1.0,
        p_init_msg_list=>'F' ,
        p_commit=>'F'       ,
        p_message_id=>p_msg_id,
        p_email_account_id =>p_acct_id,
        p_priority => p_priority,
        p_received_date=>l_received_date,
        x_return_status => l_return_status,
        x_msg_count => l_msg_count,
        x_msg_data => l_msg_data);

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

   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO insert_preproc_wrapper_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get

			( p_count => x_msg_count,
              p_data  => x_msg_data
			);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   ROLLBACK TO insert_preproc_wrapper_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
              p_data  =>      x_msg_data
			);

   WHEN OTHERS THEN
	ROLLBACK TO insert_preproc_wrapper_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
	IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
    	FND_MSG_PUB.Add_Exc_Msg
	    	(	G_PKG_NAME ,
	    		l_api_name
	    	);
	END IF;

	FND_MSG_PUB.Count_And_Get
    		( p_count         	=>      x_msg_count,
        	p_data          	=>      x_msg_data

    		);

 END	insert_preproc_wrapper;

/*
PROCEDURE create_message_part (
                 p_api_version_number  IN   NUMBER,
 		  	     p_init_msg_list       IN   VARCHAR2 := null,
		    	 p_commit              IN   VARCHAR2 := null,
            	 p_msg_id              IN   NUMBER,
  				 p_part_id   	       IN   NUMBER,
                 p_part_type           IN   VARCHAR2,
				 p_part_name           IN   VARCHAR2,
				 p_part_data           IN   BLOB,
				 p_part_charset        IN   VARCHAR2,
                 x_return_status	   OUT  NOCOPY VARCHAR2,
  		  	     x_msg_count	       OUT	NOCOPY NUMBER,
	  	  	     x_msg_data	           OUT	NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='insert_preproc_wrapper';
	l_api_version_number 	NUMBER:=1.0;
    l_seq_id		        NUMBER;

    l_return_status         VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER := 0;
    l_msg_data              VARCHAR2(2000);

    l_received_date         DATE := sysdate;

BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT		insert_preproc_wrapper_PVT;

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

   --begins here

    --get next sequential number for msg_meta_id

	   INSERT INTO IEM_MS_MSGPARTS
      		 (MESSAGE_ID, PART_ID, PART_TYPE, PART_NAME, PART_DATA, PART_CHARSET,
      		  CREATED_BY , CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN)
       VALUES ( p_msg_id, p_part_id, p_part_type, p_part_name, EMPTY_BLOB(),  p_part_charset,
	   		  -1, SYSDATE, -1, SYSDATE, -1);

	   SELECT PART_DATA FROM IEM_MS_MSGPARTS
       WHERE MESSAGE_ID=p_msg_id and PART_ID=p_part_id and PART_TYPE=p_part_type
	   		  and PART_NAME=p_part_name FOR UPDATE;


	   UPDATE IEM_MS_MSGPARTS SET PART_DATA = p_part_data, LAST_UPDATE_DATE = SYSDATE
       WHERE MESSAGE_ID=p_msg_id AND PART_ID=p_part_id AND PART_TYPE =p_part_type
	   AND PART_NAME = p_part_name;


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

   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO insert_preproc_wrapper_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get

			( p_count => x_msg_count,
              p_data  => x_msg_data
			);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   ROLLBACK TO insert_preproc_wrapper_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
              p_data  =>      x_msg_data
			);

   WHEN OTHERS THEN
	ROLLBACK TO insert_preproc_wrapper_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
	IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
    	FND_MSG_PUB.Add_Exc_Msg
	    	(	G_PKG_NAME ,
	    		l_api_name
	    	);
	END IF;

	FND_MSG_PUB.Count_And_Get
    		( p_count         	=>      x_msg_count,
        	p_data          	=>      x_msg_data

    		);

 END create_message_part;

*/

END IEM_MS_MSGMETA_PVT ;

/
