--------------------------------------------------------
--  DDL for Package Body IEM_ENCRYPT_TAGS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_ENCRYPT_TAGS_PVT" AS
/* $Header: iemvencb.pls 120.1 2005/08/29 17:38:11 appldev noship $ */

--
--
-- Purpose: Mantain Encrypted Tags
--
-- MODIFICATION HISTORY
-- Person      Date         Comments
--  Liang Xia   02/25/2002    Created
--  Liang Xia   10/24/2002    Added reset_tag API
--  Liang Xia   12/05/2002    Fixed GSCC warning: NOCOPY, no G_MISS...
--  Liang Xia   07/22/2004    Added duplicate_tags for reuse tag
--  Liang Xia  06/02/2005   Fixed GSCC sql.46 according to bug 4289628
--  Liang Xia  08/29/2005   Change Ramdom number generation using fnd_crypto
-- ---------   ------  ------------------------------------------

-- Enter procedure, function bodies as shown below
G_PKG_NAME CONSTANT varchar2(30) :='IEM_ENCRYPT_TAG_PVT ';
G_created_updated_by   NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('USER_ID')) ;
G_LAST_UPDATE_LOGIN    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('LOGIN_ ID') ) ;
g_encrypted_id         NUMBER := 0;

PROCEDURE create_item (
                 p_api_version_number  IN   NUMBER,
 		  	     p_init_msg_list       IN   VARCHAR2 := null,
		    	 p_commit              IN   VARCHAR2 := null,
            	 p_agent_id            IN   number,
                 p_interaction_id      IN   number,
                 p_email_tag_tbl       IN   email_tag_tbl,
                 x_encripted_id        OUT  NOCOPY number,
                 x_token               OUT  NOCOPY VARCHAR2,
                 x_return_status	   OUT  NOCOPY VARCHAR2,
  		  	     x_msg_count	       OUT	NOCOPY NUMBER,
	  	  	     x_msg_data	           OUT	NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='create_item';
	l_api_version_number 	NUMBER:=1.0;
    l_return_status         VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER := 0;
    l_msg_data              VARCHAR2(2000);
    l_seq_id		        NUMBER;

    l_key                   VARCHAR(256);
    l_val                   VARCHAR(256);
    l_token                 VARCHAR2(15) := '';
    l_ram                   VARCHAR2(256) :='';
    l_ram_len               NUMBER :=0;
    l_temp                  NUMBER :=0;

    logMessage              varchar2(2000);
    IEM_AGENT_INTERACTION_ID_NULL    EXCEPTION;


BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT		create_item_PVT;

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
    if (p_agent_id is NULL or p_interaction_id is NULL ) then
        raise IEM_AGENT_INTERACTION_ID_NULL;
    end if;

    --Get random number and shorten it for 5 digits
    DBMS_RANDOM.INITIALIZE ( 8726527 );
    --l_ram := TO_CHAR( ABS(DBMS_RANDOM.Random) );
	select to_char(fnd_crypto.randomnumber) into l_ram from dual;

    l_ram_len := LENGTH( l_ram );
    if l_ram_len < 5 then
        l_token := SUBSTR( l_ram, 1, l_ram_len );
        l_temp := l_ram_len;

        for l_ram_len in l_temp..4 loop
            l_token := l_token || '0';
        end loop;
    else
        l_token := SUBSTR( l_ram, 1, 5 );
    end if;

    --DBMS_RANDOM.TERMINATE;

    --get next sequential number
   	SELECT IEM_ENCRYPTED_TAGS_s1.nextval
	INTO l_seq_id
	FROM dual;

    g_encrypted_id := l_seq_id;


	INSERT INTO IEM_ENCRYPTED_TAGS
	(
	ENCRYPTED_ID,
	MESSAGE_ID,
	AGENT_ID,
	INTERACTION_ID,
    TOKEN,
	ATTRIBUTE1,
	ATTRIBUTE2,
	ATTRIBUTE3,
	ATTRIBUTE4,
	ATTRIBUTE5,
	ATTRIBUTE6,
	ATTRIBUTE7,
	ATTRIBUTE8,
	ATTRIBUTE9,
	ATTRIBUTE10,
	ATTRIBUTE11,
	ATTRIBUTE12,
	ATTRIBUTE13,
	ATTRIBUTE14,
	ATTRIBUTE15,
    ATTRIBUTE_CATEGORY,
    CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN
	)
	VALUES
	(
	l_seq_id,
	null,
	p_agent_id,
	p_interaction_id,
    l_token,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    decode(G_created_updated_by,null,-1,G_created_updated_by),
	sysdate,
    decode(G_created_updated_by,null,-1,G_created_updated_by),
    sysdate,
    decode(G_LAST_UPDATE_LOGIN,null,-1,G_LAST_UPDATE_LOGIN)
	);

    if p_email_tag_tbl.count <> 0  then
	   FOR i in p_email_tag_tbl.FIRST..p_email_tag_tbl.LAST LOOP
            l_key := p_email_tag_tbl(i).email_tag_key;
            l_val := p_email_tag_tbl(i).email_tag_value;

            if l_key is not null then
                 IEM_ENCRYPT_TAGS_PVT.create_encrypted_tag_dtls(
                              p_api_version_number    =>P_Api_Version_Number,
                              p_init_msg_list         => FND_API.G_FALSE,
                              p_commit                => P_Commit,
                              p_key	    => l_key,
                              p_val     => l_val,
                              x_return_status =>l_return_status,
                              x_msg_count   => l_msg_count,
                              x_msg_data => l_msg_data);
            else
                if( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
                logMessage := '[Miss creating key-val in Encypted tag details table since Key is null.]';
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_ENCRYPTED_TAGS_PVT.CREATE_ITEM', logMessage);
            end if;
            end if;

	   END LOOP;
    end if;

    x_encripted_id := l_seq_id;
    x_token := l_token;

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
    WHEN IEM_AGENT_INTERACTION_ID_NULL THEN
      	     ROLLBACK TO create_item_PVT;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO create_item_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;

       FND_MSG_PUB.Count_And_Get

			( p_count => x_msg_count,
              p_data  => x_msg_data
			);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   ROLLBACK TO create_item_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
              p_data  =>      x_msg_data
			);

   WHEN OTHERS THEN
	ROLLBACK TO create_item_PVT;
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
 END	create_item;



PROCEDURE delete_item_by_msg_id
             (p_api_version_number      IN  NUMBER,
              P_init_msg_list           IN  VARCHAR2 := null,
              p_commit                  IN  VARCHAR2 := null,
              p_message_id              IN  NUMBER,
              x_return_status           OUT NOCOPY VARCHAR2,
              x_msg_count               OUT NOCOPY NUMBER,
              x_msg_data                OUT NOCOPY VARCHAR2)
IS
    l_api_name		        varchar2(30):='delete_item_by_msg_id_PVT';
    l_api_version_number    number:=1.0;
    logMessage              varchar2(2000);
    l_encpt_id              number;
    l_msg_id                number;
    l_debug                 boolean;
    IEM_MSG_ID_NOT_FOUND     EXCEPTION;
    IEM_NO_ENCRYPTEID_FOR_MSGID EXCEPTION;
BEGIN

    --Standard Savepoint
    SAVEPOINT delete_item_by_msg_id_PVT;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version_number,
        p_api_version_number,
        l_api_name,
        G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --Initialize the message list if p_init_msg_list is set to TRUE
    If FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --Initialize API status return
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Actual API starts here
    FND_LOG_REPOSITORY.init(null,null);

    l_debug := FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL;


    l_msg_id := LTRIM(RTRIM(p_message_id));

    select ENCRYPTED_ID into l_encpt_id from iem_encrypted_tags where message_id = l_msg_id;

    DELETE
    FROM IEM_ENCRYPTED_TAGS
    WHERE message_id = l_msg_id;

    if SQL%NOTFOUND then
       -- dbms_output.put_line('Delete encypted_tag no msg found!');
        raise IEM_MSG_ID_NOT_FOUND;
    end if;

    DELETE
    FROM IEM_ENCRYPTED_TAG_DTLS
    WHERE ENCRYPTED_ID = l_encpt_id;

    if SQL%NOTFOUND then
        null;
    end if;

    if l_debug then
        logMessage := '[Success deleting: MSG_ID = ' || p_message_id ||' from encrypted tag table! ]';
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_ENCRYPTED_TAGS_PVT.DELETE_ITEM_BY_MSG_ID', logMessage);
    end if;

    --Standard check of p_commit
    IF FND_API.to_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;

    FND_MSG_PUB.Count_And_Get
  			( p_count => x_msg_count,p_data => x_msg_data);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
      	    ROLLBACK TO delete_item_by_msg_id_PVT;
             --dbms_output.put_line('IEM_NO_ENCRYPTEID_FOR_MSGID!');
            x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
            if l_debug then
                logMessage := '[Not delete (no encrypted tag found)- trying to delete Encrypted tag with MSG_ID = ' || p_message_id ||']';
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_ENCRYPTED_TAGS_PVT.DELETE_ITEM_BY_MSG_ID', logMessage);
            end if;

    WHEN IEM_MSG_ID_NOT_FOUND THEN
      	    ROLLBACK TO delete_item_by_msg_id_PVT;
           -- dbms_output.put_line('IEM_MSG_ID_NOT_FOUND!');
            x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

            if l_debug then
                logMessage := '[Not delete (MSG_ID not found) - trying to delete Encrypted tag with MSG_ID = ' || p_message_id ||']';
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_ENCRYPTED_TAGS_PVT.DELETE_ITEM_BY_MSG_ID', logMessage);
            end if;

    WHEN FND_API.G_EXC_ERROR THEN
  	     ROLLBACK TO delete_item_by_msg_id_PVT;
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get
  			( p_count => x_msg_count,p_data => x_msg_data);

         if l_debug then
                logMessage := '[FND_API.G_EXC_ERROR - trying to delete Encrypted tag with MSG_ID = ' || p_message_id ||']';
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_ENCRYPTED_TAGS_PVT.DELETE_ITEM_BY_MSG_ID', logMessage);
         end if;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   ROLLBACK TO delete_item_by_msg_id_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,p_data => x_msg_data);

      if l_debug then
          logMessage := '[FND_API.G_EXC_UNEXPECTED_ERROR in - trying to delete Encrypted tag with MSG_ID = ' || p_message_id ||']';
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_ENCRYPTED_TAGS_PVT.DELETE_ITEM_BY_MSG_ID', logMessage);
      end if;
   WHEN OTHERS THEN
	  ROLLBACK TO delete_item_by_msg_id_PVT;
      --dbms_output.put_line('Other error in delete_item_on_msg_id ' ||SUBSTR (SQLERRM , 1 , 100));
      x_return_status := FND_API.G_RET_STS_ERROR;
	  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);
      END IF;
	  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count	,p_data	=> x_msg_data);

      if l_debug then
          logMessage := '[Failed (Other exception) - trying to delete Encrypted tag with MSG_ID = ' || p_message_id ||']';
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_ENCRYPTED_TAGS_PVT.DELETE_ITEM_BY_MSG_ID', logMessage);
      end if;
END delete_item_by_msg_id;


PROCEDURE update_item_on_mess_id (
                 p_api_version_number   IN   NUMBER,
    	  	     p_init_msg_list        IN   VARCHAR2 := null,
    	    	 p_commit	            IN   VARCHAR2 := null,
                 p_encrypted_id         IN   NUMBER,
    			 p_message_id           IN   NUMBER,
			     x_return_status	    OUT	NOCOPY VARCHAR2,
  		  	     x_msg_count	        OUT	NOCOPY NUMBER,
	  	  	     x_msg_data	            OUT	NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='update_item_on_mess_id';
	l_api_version_number 	NUMBER:=1.0;
    IEM_MSG_ID_NULL    EXCEPTION;
    IEM_ENCRYPTED_ID_NOT_FOUND    EXCEPTION;
    IEM_INVALID_MSG_ID            EXCEPTION;

BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT		update_item_on_mess_id;

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

    if p_message_id is null then
        raise IEM_MSG_ID_NULL;
    end if;

    -- valid msg_id
    --select(*) into l_count from iem_post_mdts where msg_id = p_message_id;

    --if l_count < 1 then
    --    raise IEM_INVALID_MSG_ID;
    --end if;


	update IEM_ENCRYPTED_TAGS
	set
           message_id=p_message_id,
           LAST_UPDATED_BY = decode(G_created_updated_by,null,-1,G_created_updated_by),
           LAST_UPDATE_DATE = sysdate,
           LAST_UPDATE_LOGIN = decode(G_LAST_UPDATE_LOGIN,null,-1,G_LAST_UPDATE_LOGIN)
	where encrypted_id = p_encrypted_id;

    if SQL%NOTFOUND then
        --dbms_output.put_line('failed Update encypted_tags table');
        raise IEM_ENCRYPTED_ID_NOT_FOUND;
    end if;

    -- Standard Check Of p_commit.
	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;

    -- Standard callto get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
			(    p_count =>  x_msg_count,
                p_data  =>    x_msg_data
			);
EXCEPTION
    WHEN IEM_MSG_ID_NULL THEN
      	     ROLLBACK TO update_item_on_mess_id;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN IEM_ENCRYPTED_ID_NOT_FOUND THEN
            --dbms_output.put_line('IEM_ENCRYPTED_ID_NOT_FOUND');
      	     ROLLBACK TO update_item_on_mess_id;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN FND_API.G_EXC_ERROR THEN
    --dbms_output.put_line('FND_API.G_EXC_ERROR');
	   ROLLBACK TO update_item_on_mess_id;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
               	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   --dbms_output.put_line('G_EXC_UNEXPECTED_ERROR');
	   ROLLBACK TO update_item_on_mess_id;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
            	p_data  =>      x_msg_data
            );
   WHEN OTHERS THEN
   --dbms_output.put_line('Exception in update encypted_tag tabel happened ' || SUBSTR (SQLERRM , 1 , 240));
	ROLLBACK TO update_item_on_mess_id;
      x_return_status := FND_API.G_RET_STS_ERROR;
	IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
            		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		     );
	END IF;
	FND_MSG_PUB.Count_And_Get
    		( p_count         	=>      x_msg_count ,
        	p_data          	=>      x_msg_data
    		);

END	update_item_on_mess_id;



PROCEDURE create_encrypted_tag_dtls (
                 p_api_version_number  IN   NUMBER,
 		  	     p_init_msg_list       IN   VARCHAR2 := null,
		    	 p_commit              IN   VARCHAR2 := null,
            	 p_key                 IN   VARCHAR2,
                 p_val                 IN   VARCHAR2,
                 x_return_status	   OUT  NOCOPY VARCHAR2,
  		  	     x_msg_count	       OUT	NOCOPY NUMBER,
	  	  	     x_msg_data	           OUT	NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='create_encrypted_tag_dtls';
	l_api_version_number 	NUMBER:=1.0;
    l_seq_id		        NUMBER;
    l_key                   VARCHAR2(256) := '';
    l_val                   VARCHAR2(256) :='';
    l_temp                  NUMBER :=0;
    l_debug                 Boolean ;
    IEM_TAG_KEY_NULL    EXCEPTION;

BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT		create_encrypted_tag_dtls_PVT;

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
    if (p_key is NULL) then
        raise IEM_TAG_KEY_NULL;
    end if;

    l_key := LTRIM(RTRIM(p_key));
    l_val := LTRIM(RTRIM(p_val));

    --get next sequential number
   	SELECT IEM_ENCRYPTED_TAG_DTLS_S1.nextval
	INTO l_seq_id
	FROM dual;

	INSERT INTO IEM_ENCRYPTED_TAG_DTLS
	(
	ENCRYPTED_TAG_DTL_ID,
	KEY,
	VALUE,
    ENCRYPTED_ID,
	ATTRIBUTE1,
	ATTRIBUTE2,
	ATTRIBUTE3,
	ATTRIBUTE4,
	ATTRIBUTE5,
	ATTRIBUTE6,
	ATTRIBUTE7,
	ATTRIBUTE8,
	ATTRIBUTE9,
	ATTRIBUTE10,
	ATTRIBUTE11,
	ATTRIBUTE12,
	ATTRIBUTE13,
	ATTRIBUTE14,
	ATTRIBUTE15,
    ATTRIBUTE_CATEGORY,
    CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN
	)
	VALUES
	(
	l_seq_id,
	l_key,
	l_val,
	g_encrypted_id,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
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

    -- Standard callto get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
			( p_count =>  x_msg_count,
                 	p_data  =>    x_msg_data
			);
EXCEPTION
    WHEN IEM_TAG_KEY_NULL THEN
      	     ROLLBACK TO create_encrypted_tag_dtls_PVT;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO create_encrypted_tag_dtls_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;

       FND_MSG_PUB.Count_And_Get

			( p_count => x_msg_count,
              p_data  => x_msg_data
			);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   ROLLBACK TO create_encrypted_tag_dtls_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
              p_data  =>      x_msg_data
			);

   WHEN OTHERS THEN
	ROLLBACK TO create_encrypted_tag_dtls_PVT;
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
 END	;

 PROCEDURE reset_tag
             (p_api_version_number      IN  NUMBER,
              P_init_msg_list           IN  VARCHAR2 := null,
              p_commit                  IN  VARCHAR2 := null,
              p_message_id              IN  NUMBER,
              x_return_status           OUT NOCOPY VARCHAR2,
              x_msg_count               OUT NOCOPY NUMBER,
              x_msg_data                OUT NOCOPY VARCHAR2)
IS
    l_api_name		        varchar2(30):='reset_tag_PVT';
    l_api_version_number    number:=1.0;
    logMessage              varchar2(2000);
    l_encpt_id              number;
    l_msg_id                number;
    l_debug                 Boolean ;
    IEM_MSG_ID_NOT_FOUND     EXCEPTION;
    IEM_NO_ENCRYPTEID_FOR_MSGID EXCEPTION;
BEGIN

    --Standard Savepoint
    SAVEPOINT reset_tag_PVT;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version_number,
        p_api_version_number,
        l_api_name,
        G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --Initialize the message list if p_init_msg_list is set to TRUE
    If FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --Initialize API status return
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Actual API starts here
    FND_LOG_REPOSITORY.init(null,null);

    l_debug := FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ;


    l_msg_id := LTRIM(RTRIM(p_message_id));

    update iem_encrypted_tags set message_id = null where message_id = l_msg_id;

    if l_debug then
        logMessage := '[Success reset: MSG_ID = ' || p_message_id ||' from encrypted tag table! ]';
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_ENCRYPTED_TAGS_PVT.DELETE_ITEM_BY_MSG_ID', logMessage);
    end if;

    --Standard check of p_commit
    IF FND_API.to_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;

    FND_MSG_PUB.Count_And_Get
  			( p_count => x_msg_count,p_data => x_msg_data);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
      	    ROLLBACK TO reset_tag_PVT;
             --dbms_output.put_line('IEM_NO_ENCRYPTEID_FOR_MSGID!');
            x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
            if l_debug then
                logMessage := '[Not delete (no encrypted tag found)- trying to delete Encrypted tag with MSG_ID = ' || p_message_id ||']';
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_ENCRYPTED_TAGS_PVT.DELETE_ITEM_BY_MSG_ID', logMessage);
            end if;

    WHEN FND_API.G_EXC_ERROR THEN
  	     ROLLBACK TO reset_tag_PVT;
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get
  			( p_count => x_msg_count,p_data => x_msg_data);

         if l_debug then
                logMessage := '[FND_API.G_EXC_ERROR - trying to delete Encrypted tag with MSG_ID = ' || p_message_id ||']';
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_ENCRYPTED_TAGS_PVT.DELETE_ITEM_BY_MSG_ID', logMessage);
         end if;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   ROLLBACK TO reset_tag_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,p_data => x_msg_data);

      if l_debug then
          logMessage := '[FND_API.G_EXC_UNEXPECTED_ERROR in - trying to delete Encrypted tag with MSG_ID = ' || p_message_id ||']';
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_ENCRYPTED_TAGS_PVT.DELETE_ITEM_BY_MSG_ID', logMessage);
      end if;
   WHEN OTHERS THEN
	  ROLLBACK TO reset_tag_PVT;
      --dbms_output.put_line('Other error in delete_item_on_msg_id ' ||SUBSTR (SQLERRM , 1 , 100));
      x_return_status := FND_API.G_RET_STS_ERROR;
	  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);
      END IF;
	  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count	,p_data	=> x_msg_data);

      if l_debug then
          logMessage := '[Failed (Other exception) - trying to delete Encrypted tag with MSG_ID = ' || p_message_id ||']';
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_ENCRYPTED_TAGS_PVT.DELETE_ITEM_BY_MSG_ID', logMessage);
      end if;
END ;

   -- Enter further code below as specified in the Package spec.
PROCEDURE duplicate_tags
             (p_api_version_number      IN  NUMBER,
              P_init_msg_list           IN  VARCHAR2 := null,
              p_commit                  IN  VARCHAR2 := null,
              p_encrypted_id            IN  NUMBER,
              p_message_id              IN  NUMBER,
              x_return_status           OUT NOCOPY VARCHAR2,
              x_msg_count               OUT NOCOPY NUMBER,
              x_msg_data                OUT NOCOPY VARCHAR2)
IS
    l_api_name		        varchar2(30):='duplicate_tags_PVT';
    l_api_version_number    number:=1.0;
    logMessage              varchar2(2000);
    l_encpt_id              number;
    l_msg_id                number;
    l_debug                 boolean;
    l_seq_id                number;
    l_seq_dtl_id            number;

    l_encypted_rec          IEM_ENCRYPTED_TAGS%ROWTYPE;
  cursor c_tag_dtls (p_encypted_id iem_encrypted_tag_dtls.encrypted_id%type)
  is
  select key, value from iem_encrypted_tag_dtls where encrypted_id = p_encypted_id;


    IEM_MSG_ID_NOT_FOUND     EXCEPTION;
    IEM_NO_ENCRYPTEID_FOR_MSGID EXCEPTION;
BEGIN

    --Standard Savepoint
    SAVEPOINT delete_item_by_msg_id_PVT;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version_number,
        p_api_version_number,
        l_api_name,
        G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --Initialize the message list if p_init_msg_list is set to TRUE
    If FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --Initialize API status return
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Actual API starts here
    FND_LOG_REPOSITORY.init(null,null);

    l_debug := FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ;

    select * into l_encypted_rec from IEM_ENCRYPTED_TAGS where ENCRYPTED_ID=p_encrypted_id;

   	SELECT IEM_ENCRYPTED_TAGS_S1.nextval
	INTO l_seq_id
	FROM dual;

    --l_encypted_rec.ENCRYPTED_ID := l_seq_id;
    --l_encypted_rec.MESSAGE_ID := p_message_id;
    --l_encypted_rec.CREATION_DATE := SYSDATE;
    --l_encypted_rec.LAST_UPDATE_DATE := SYSDATE;

    insert into IEM_ENCRYPTED_TAGS
    	(
	ENCRYPTED_ID,
	MESSAGE_ID,
	AGENT_ID,
	INTERACTION_ID,
    TOKEN,
	ATTRIBUTE1,
	ATTRIBUTE2,
	ATTRIBUTE3,
	ATTRIBUTE4,
	ATTRIBUTE5,
	ATTRIBUTE6,
	ATTRIBUTE7,
	ATTRIBUTE8,
	ATTRIBUTE9,
	ATTRIBUTE10,
	ATTRIBUTE11,
	ATTRIBUTE12,
	ATTRIBUTE13,
	ATTRIBUTE14,
	ATTRIBUTE15,
    ATTRIBUTE_CATEGORY,
    CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN
	)
     values
	(
	l_seq_id,
	p_message_id,
	l_encypted_rec.agent_id,
	l_encypted_rec.interaction_id,
    l_encypted_rec.token,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    decode(G_created_updated_by,null,-1,G_created_updated_by),
	sysdate,
    decode(G_created_updated_by,null,-1,G_created_updated_by),
    sysdate,
    decode(G_LAST_UPDATE_LOGIN,null,-1,G_LAST_UPDATE_LOGIN)
	);

    For v_rec in c_tag_dtls ( p_encrypted_id ) Loop
    --get next sequential number
   	SELECT IEM_ENCRYPTED_TAG_DTLS_S1.nextval
	INTO l_seq_dtl_id
	FROM dual;

	INSERT INTO IEM_ENCRYPTED_TAG_DTLS
	(
	ENCRYPTED_TAG_DTL_ID,
	KEY,
	VALUE,
    ENCRYPTED_ID,
	ATTRIBUTE1,
	ATTRIBUTE2,
	ATTRIBUTE3,
	ATTRIBUTE4,
	ATTRIBUTE5,
	ATTRIBUTE6,
	ATTRIBUTE7,
	ATTRIBUTE8,
	ATTRIBUTE9,
	ATTRIBUTE10,
	ATTRIBUTE11,
	ATTRIBUTE12,
	ATTRIBUTE13,
	ATTRIBUTE14,
	ATTRIBUTE15,
    ATTRIBUTE_CATEGORY,
    CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN
	)
	VALUES
	(
	l_seq_dtl_id,
	v_rec.key,
	v_rec.value,
	l_seq_id,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    decode(G_created_updated_by,null,-1,G_created_updated_by),
	sysdate,
    decode(G_created_updated_by,null,-1,G_created_updated_by),
    sysdate,
    decode(G_LAST_UPDATE_LOGIN,null,-1,G_LAST_UPDATE_LOGIN)
	);

    end loop;

    --Standard check of p_commit
    IF FND_API.to_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;

    FND_MSG_PUB.Count_And_Get
  			( p_count => x_msg_count,p_data => x_msg_data);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
      	    ROLLBACK TO delete_item_by_msg_id_PVT;
             --dbms_output.put_line('IEM_NO_ENCRYPTEID_FOR_MSGID!');
            x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
            if l_debug then
                logMessage := '[No Data found when duplicate tag records! ]';
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_ENCRYPTED_TAGS_PVT.DUPLICATE_TAGS', logMessage);
            end if;


    WHEN FND_API.G_EXC_ERROR THEN
  	     ROLLBACK TO delete_item_by_msg_id_PVT;
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get
  			( p_count => x_msg_count,p_data => x_msg_data);

         if l_debug then
                logMessage := '[FND_API.G_EXC_ERROR - trying to delete Encrypted tag with MSG_ID = ' || p_message_id ||']';
                FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_ENCRYPTED_TAGS_PVT.DUPLICATE_TAGS', logMessage);
         end if;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   ROLLBACK TO delete_item_by_msg_id_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,p_data => x_msg_data);

      if l_debug then
          logMessage := '[FND_API.G_EXC_UNEXPECTED_ERROR in - trying to delete Encrypted tag with MSG_ID = ' || p_message_id ||']';
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_ENCRYPTED_TAGS_PVT.DUPLICATE_TAGS', logMessage);
      end if;
   WHEN OTHERS THEN
	  ROLLBACK TO delete_item_by_msg_id_PVT;
      --dbms_output.put_line('Other error in delete_item_on_msg_id ' ||SUBSTR (SQLERRM , 1 , 100));
      x_return_status := FND_API.G_RET_STS_ERROR;
	  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);
      END IF;
	  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count	,p_data	=> x_msg_data);

      if l_debug then
          logMessage := '[Failed (Other exception) - trying to delete Encrypted tag with MSG_ID = ' || p_message_id ||']';
          FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_ENCRYPTED_TAGS_PVT.DUPLICATE_TAGS', logMessage);
      end if;
END duplicate_tags;

END IEM_ENCRYPT_TAGS_PVT; -- Package Body IEM_ENCRYPT_TAGS_PVT

/
