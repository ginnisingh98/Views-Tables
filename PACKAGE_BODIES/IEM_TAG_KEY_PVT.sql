--------------------------------------------------------
--  DDL for Package Body IEM_TAG_KEY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_TAG_KEY_PVT" AS
/* $Header: iemvtagb.pls 120.0 2005/06/02 14:17:25 appldev noship $ */

--
--
-- Purpose: Mantain email tag related operations
--
-- MODIFICATION HISTORY
-- Person      Date         Comments
--  Liang Xia   3/20/2002    Created
--  Liang Xia   5/14/2002    added more validation on Key ID
--  Liang Xia   12/05/2002   Fixed plsql GSCC warning: NOCOPY, No G_MISS..
--  Liang Xia   01/21/2003   Adding additional check to email processing rule when deleting tag
--  Liang Xia   12/04/2004   changed to iem_mstemail_accounts for 115.11 schema compliance
-- ---------   ------  ------------------------------------------

-- Enter procedure, function bodies as shown below
G_PKG_NAME CONSTANT varchar2(30) :='IEM_TAG_KEY_PVT ';
G_created_updated_by   NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('USER_ID')) ;
G_LAST_UPDATE_LOGIN    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('LOGIN_ID') ) ;

PROCEDURE delete_item_batch
             (p_api_version_number      IN  NUMBER,
              P_init_msg_list           IN  VARCHAR2 := null,
              p_commit                  IN  VARCHAR2 := null,
              p_tagKey_ids_tbl          IN  jtf_varchar2_Table_100,
              x_return_status           OUT NOCOPY VARCHAR2,
              x_msg_count               OUT NOCOPY NUMBER,
              x_msg_data                OUT NOCOPY VARCHAR2)
IS
    i                       INTEGER;
    l_api_name		        varchar2(30):='delete_item_batch';
    l_api_version_number    number:=1.0;

    l_tag_name              varchar2(256);
    l_used_tag_name         varchar2(2000);
    l_route_count           number;
    l_class_count           number;
    l_emailproc_count       number;

    IEM_TAG_NOT_DELETED     EXCEPTION;
BEGIN

    --Standard Savepoint
    SAVEPOINT delete_item_batch;

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
    if ( p_tagKey_ids_tbl.count <> 0 ) then

    FOR i IN p_tagKey_ids_tbl.FIRST..p_tagKey_ids_tbl.LAST LOOP
            l_route_count := 0;
            l_class_count := 0;

            select count(*) into l_route_count
            from iem_tag_keys a, iem_route_rules b
            where a.tag_key_id=p_tagKey_ids_tbl(i) and upper('IEMS'||a.tag_id) = UPPER(b.key_type_code);

            select count(*) into l_class_count
            from iem_tag_keys a, iem_route_class_rules b
            where a.tag_key_id=p_tagKey_ids_tbl(i) and upper('IEMS'||a.tag_id) = UPPER(b.key_type_code);

            select count(*) into l_emailproc_count
            from iem_tag_keys a, iem_emailproc_rules b
            where a.tag_key_id=p_tagKey_ids_tbl(i) and upper('IEMS'||a.tag_id) = UPPER(b.key_type_code);

            if (l_route_count > 0 ) or (l_class_count > 0 ) or ( l_emailproc_count > 0 ) then
                select tag_name into l_tag_name from iem_tag_keys where tag_key_id = p_tagKey_ids_tbl(i);
                l_used_tag_name := l_used_tag_name||l_tag_name||', ' ;
            else
                DELETE
                FROM IEM_TAG_KEYS
                WHERE TAG_KEY_ID = p_tagKey_ids_tbl(i);

                if SQL%NOTFOUND then
                    raise IEM_TAG_NOT_DELETED;
                end if;

                DELETE
                FROM IEM_ACCOUNT_TAG_KEYS
                WHERE TAG_KEY_ID = p_tagKey_ids_tbl(i);
            end if;

    END LOOP;

    --Delete the accounts, tags associated with this tag
   --if ( p_tagKey_ids_tbl.count <> 0 ) then
   /*  FOR i IN p_tagKey_ids_tbl.FIRST..p_tagKey_ids_tbl.LAST LOOP

        DELETE
        FROM IEM_ACCOUNT_TAG_KEYS
        WHERE TAG_KEY_ID = p_tagKey_ids_tbl(i);

     END LOOP;
     */
   end if;

    --add names of un_deleted tags into message
    if l_used_tag_name is not null  then
        l_used_tag_name := RTRIM(l_used_tag_name, ', ');
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('IEM', 'IEM_ADMIN_TAG_NOT_DELETED');
        FND_MESSAGE.SET_TOKEN('TAG', l_used_tag_name);
        FND_MSG_PUB.ADD;
       /* FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
              p_data  =>      x_msg_data
			);
        */
     end if;

    --Standard check of p_commit
    IF FND_API.to_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;
            FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
              p_data  =>      x_msg_data
			);

EXCEPTION

   WHEN IEM_TAG_NOT_DELETED THEN
        ROLLBACK TO delete_item_batch;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('IEM', 'IEM_TAG_NOT_DELETED');

        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

   WHEN FND_API.G_EXC_ERROR THEN
  	     ROLLBACK TO delete_item_batch;
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get
  			( p_count => x_msg_count,p_data => x_msg_data);


   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   ROLLBACK TO delete_item_batch;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,p_data => x_msg_data);


   WHEN OTHERS THEN
	  ROLLBACK TO delete_item_batch;
      x_return_status := FND_API.G_RET_STS_ERROR;
	  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);
      END IF;

	  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count	,p_data	=> x_msg_data);

END delete_item_batch;


PROCEDURE delete_acct_tag_on_acct_ID
             (p_api_version_number      IN  NUMBER,
              P_init_msg_list           IN  VARCHAR2 := null,
              p_commit                  IN  VARCHAR2 := null,
              p_email_acct_id           IN  iem_mstemail_accounts.email_account_id%type,
              x_return_status           OUT NOCOPY VARCHAR2,
              x_msg_count               OUT NOCOPY NUMBER,
              x_msg_data                OUT NOCOPY VARCHAR2)
IS
    i                       INTEGER;
    l_api_name		        varchar2(30):='delete_acct_tag_on_acct_ID';
    l_api_version_number    number:=1.0;

    l_acct_id               number;

    IEM_TAG_NOT_DELETED     EXCEPTION;
BEGIN

    --Standard Savepoint
    SAVEPOINT delete_association_on_acct_ID;

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
    l_acct_id := LTRIM(RTRIM(p_email_acct_id));
    delete from iem_account_tag_keys where email_account_id = l_acct_id;

    --Standard check of p_commit
    IF FND_API.to_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;


EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
  	     ROLLBACK TO delete_acct_tag_on_acct_ID;
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get
  			( p_count => x_msg_count,p_data => x_msg_data);


   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   ROLLBACK TO delete_acct_tag_on_acct_ID;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,p_data => x_msg_data);


   WHEN OTHERS THEN
	  ROLLBACK TO delete_acct_tag_on_acct_ID;
      x_return_status := FND_API.G_RET_STS_ERROR;
	  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);
      END IF;

	  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count	,p_data	=> x_msg_data);

END delete_acct_tag_on_acct_ID;

PROCEDURE create_item_tag (
                 p_api_version_number  IN   NUMBER,
 		  	     p_init_msg_list       IN   VARCHAR2 := null,
		    	 p_commit              IN   VARCHAR2 := null,
            	 p_key_id              IN   VARCHAR2,
  				 p_key_name   	       IN   VARCHAR2,
         		 p_type_type_code      IN   VARCHAR2,
                 p_value               IN   VARCHAR2,
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

    l_name_count            NUMBER;
    l_id_count              NUMBER;
    l_id_count_rt           NUMBER;
    l_id_count_cls          NUMBER;
    l_cursorid              NUMBER;
    l_key_id                VARCHAR2(30);
    l_key_id_temp           VARCHAR2(30);
    l_key_name              VARCHAR2(50);
    l_value                 VARCHAR2(256);
    l_error_text            varchar2(2000);

    IEM_TAG_DUP_KEY_NAME    EXCEPTION;
    IEM_TAG_DUP_KEY_ID      EXCEPTION;
    l_invalid_query         EXCEPTION;
    l_IEM_INVALID_PROCEDURE EXCEPTION;
    IEM_ADM_G_MISS_FOR_NOTNULL EXCEPTION;
    IEM_TAG_NAME_VALUE_KEY_NULL EXCEPTION;

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
   --Valid no Null passed in for NOT_NULL parameters
    if ( p_key_name is null or p_value is null or p_key_id is null ) then
        raise IEM_TAG_NAME_VALUE_KEY_NULL;
    elsif ( p_key_name=FND_API.G_MISS_CHAR or p_value=FND_API.G_MISS_CHAR or p_key_id=FND_API.G_MISS_CHAR ) then
        raise IEM_ADM_G_MISS_FOR_NOTNULL;
    end if;

    l_key_name := LTRIM(RTRIM(p_key_name));
    l_value := LTRIM(RTRIM(p_value));
    l_key_id_temp := LTRIM(RTRIM(p_key_id));
    l_key_id := 'IEMS'||l_key_id_temp;

   --check duplicate value for attribute Name, ID
    select count(*) into l_name_count from iem_tag_keys where UPPER(tag_name) = UPPER(l_key_name);
    if l_name_count > 0 then
      raise IEM_TAG_DUP_KEY_NAME;
    end if;

    select count(*) into l_id_count from iem_tag_keys where UPPER(tag_id) = UPPER(l_key_id_temp);
    if l_id_count > 0 then
      raise IEM_TAG_DUP_KEY_ID;
    end if;

    SELECT count(*) into l_id_count_rt from FND_LOOKUPS WHERE upper(lookup_code)=upper(l_key_id) and enabled_flag = 'Y' AND NVL(start_date_active, SYSDATE) <= SYSDATE AND NVL(end_date_active, SYSDATE)   >= SYSDATE  AND lookup_type = 'IEM_KEY_TYPE_CODE';
    if l_id_count_rt > 0 then
      raise IEM_TAG_DUP_KEY_ID;
    end if;

    SELECT count(*) into l_id_count_cls from FND_LOOKUPS
    WHERE upper(lookup_code)=upper(l_key_id) and enabled_flag = 'Y'
    AND NVL(start_date_active, SYSDATE) <= SYSDATE AND NVL(end_date_active, SYSDATE)   >= SYSDATE  AND lookup_type = 'IEM_CLASS_KEY_TYPE_CODE';
    if l_id_count_cls > 0 then
      raise IEM_TAG_DUP_KEY_ID;
    end if;

   /*
    if (l_key_id='IEMNAGENTID' or l_key_id='IEMNINTERACTIONID' or
        l_key_id='IEMNBZTSRVSRID' or l_key_id='IEMNCUSTOMERID' or l_key_id='IEMNCONTACTID' or l_key_id='IEMNEMAILACCOUNTID')
    then
            raise IEM_TAG_DUP_KEY_ID;
    end if;
     */

    -- Valid 'QUERY' type and 'PROCEDURE' type
    if p_type_type_code = 'QUERY' then
        IF p_value is NOT NULL THEN
            BEGIN
                l_cursorid := DBMS_SQL.OPEN_CURSOR;
                DBMS_SQL.PARSE(l_cursorid, l_value, DBMS_SQL.V7);

            EXCEPTION
                WHEN OTHERS THEN
                    fnd_message.set_name ('IEM', 'IEM_TAG_INVALID_QUERY');
                    l_error_text := SUBSTR (SQLERRM , 1 , 240);
                    FND_MESSAGE.SET_TOKEN('ERROR_TEXT',l_error_text);
                    FND_MSG_PUB.add;
                    DBMS_SQL.CLOSE_CURSOR(l_cursorid);
                RAISE l_invalid_query;
            END;
        END IF;
    elsif p_type_type_code = 'PROCEDURE' then
        IF p_value is NOT NULL THEN
            IEM_TAG_RUN_PROC_PVT.validProcedure(
                 p_api_version_number  => P_Api_Version_Number,
 		  	     p_init_msg_list       => FND_API.G_FALSE,
		    	 p_commit              => P_Commit,
                 p_ProcName            => l_value,
                 x_return_status       => l_return_status,
  		  	     x_msg_count           => l_msg_count,
	  	  	     x_msg_data            => l_msg_data
			 );
            if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
                raise l_IEM_INVALID_PROCEDURE;
            end if;

        END IF;
    end if;

    --get next sequential number for route_id
   	SELECT IEM_TAG_KEYS_s1.nextval
	INTO l_seq_id
	FROM dual;

   -- G_ROUTE_ID := l_seq_id;

	INSERT INTO IEM_TAG_KEYS
	(
	TAG_KEY_ID,
	TAG_ID,
	TAG_NAME,
    TAG_TYPE_CODE,
    VALUE,
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
	l_key_id_temp,
	l_key_name,
	p_type_type_code,
    l_value,
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
    WHEN l_invalid_query THEN
	 ROLLBACK TO create_item_tag_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN l_IEM_INVALID_PROCEDURE THEN
	 ROLLBACK TO create_item_tag_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN IEM_TAG_NAME_VALUE_KEY_NULL THEN
	 ROLLBACK TO create_item_tag_PVT;
     FND_MESSAGE.SET_NAME('IEM','IEM_TAG_NAME_VALUE_KEY_NULL');
     FND_MSG_PUB.Add;
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN IEM_ADM_G_MISS_FOR_NOTNULL THEN
	 ROLLBACK TO create_item_tag_PVT;
     FND_MESSAGE.SET_NAME('IEM','IEM_ADM_G_MISS_FOR_NOTNULL');
     FND_MSG_PUB.Add;
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN IEM_TAG_DUP_KEY_NAME THEN
	 ROLLBACK TO create_item_tag_PVT;
     FND_MESSAGE.SET_NAME('IEM','IEM_TAG_DUP_KEY_NAME');
     FND_MSG_PUB.Add;
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN IEM_TAG_DUP_KEY_ID THEN
	 ROLLBACK TO create_item_tag_PVT;
     FND_MESSAGE.SET_NAME('IEM','IEM_TAG_DUP_KEY_ID');
     FND_MSG_PUB.Add;
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

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

 END	create_item_tag;

 --transfer string containing elements seperated by ; to table
 FUNCTION varChar_to_table ( inString    IN   VARCHAR2 )
        return key_tbl_type
       is
    l_indx number:=0;
   l_temp varchar2(200);
    l_rem varchar2(2000);
    l_table key_tbl_type;
    i BINARY_INTEGER :=1;
 BEGIN
    l_rem := inString ;

    loop
        l_indx := INSTR(l_rem, ';');
        if (l_indx <> 0)then
            l_temp := SUBSTR( l_rem, 1, l_indx-1 );
            l_rem := SUBSTR( l_rem, l_indx+1);
            l_table(i) := l_temp;
            i := i + 1;
        else
            exit;
        end if;
    end loop;

    return l_table;

END    varChar_to_table;




PROCEDURE create_item_account_tags (
                 p_api_version_number     IN NUMBER,
 		  	     p_init_msg_list          IN VARCHAR2 := null,
		    	 p_commit	              IN VARCHAR2 := null,
                 p_email_account_id       IN NUMBER,
  				 p_tag_key_id             IN NUMBER,
                 x_return_status	      OUT NOCOPY VARCHAR2,
  		  	     x_msg_count	          OUT NOCOPY NUMBER,
	  	  	     x_msg_data	              OUT NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='create_item_account_tags';
	l_api_version_number 	NUMBER:=1.0;
    l_seq_id        number;

    l_count         number;
    IEM_TAG_KEY_ID_NOT_EXIST    EXCEPTION;
    IEM_TAG_ACCT_ID_NOT_EXIST   EXCEPTION;

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT		create_item_account_tags_PVT;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (l_api_version_number,
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

    --valid tag_key_id
    select count(*) into l_count from iem_tag_keys where tag_key_id = p_tag_key_id;
    if l_count < 1 then
        raise IEM_TAG_KEY_ID_NOT_EXIST;
    end if;

    --valid account_id
   select count(*) into l_count from iem_mstemail_accounts where email_account_id = p_email_account_id;
    if l_count < 1 then
        raise IEM_TAG_ACCT_ID_NOT_EXIST;
    end if;

--actual API begins here
	SELECT IEM_ACCOUNT_TAG_KEYS_s1.nextval
	INTO l_seq_id
	FROM dual;

	INSERT INTO IEM_ACCOUNT_TAG_KEYS
	(
	ACCOUNT_TAG_KEY_ID,
	EMAIL_ACCOUNT_ID,
    TAG_KEY_ID,
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
   p_email_account_id,
   p_tag_key_id,
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

-- Standard Check Of p_commit
IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
END IF;

-- Standard callto get message count and if count is 1, get message info.
 FND_MSG_PUB.Count_And_Get
			( p_count =>  x_msg_count,
           	  p_data  =>    x_msg_data
			);

EXCEPTION
    WHEN IEM_TAG_KEY_ID_NOT_EXIST THEN
      	   ROLLBACK TO create_item_account_tags_PVT;
           FND_MESSAGE.SET_NAME('IEM','IEM_TAG_KEY_ID_NOT_EXIST');
           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

     WHEN IEM_TAG_ACCT_ID_NOT_EXIST THEN
      	   ROLLBACK TO create_item_account_tags_PVT;
           FND_MESSAGE.SET_NAME('IEM','IEM_TAG_ACCT_ID_NOT_EXIST');
           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

   WHEN FND_API.G_EXC_ERROR THEN
	   ROLLBACK TO create_item_account_tags_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
            	p_data  =>      x_msg_data
			);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   ROLLBACK TO create_item_account_tags_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
              p_data  =>      x_msg_data
			);

   WHEN OTHERS THEN
	ROLLBACK TO create_item_account_tags_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
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

 END	create_item_account_tags;


PROCEDURE update_acct_tag_wrap (p_api_version_number     IN   NUMBER,
 	                         p_init_msg_list         IN   VARCHAR2 := null,
	                         p_commit	             IN   VARCHAR2 := null,
  	                         p_account_id	         IN   NUMBER,
                             p_in_key_id             IN   VARCHAR2:= null,
                             p_out_key_id            IN   VARCHAR2 := null,
                             x_return_status         OUT  NOCOPY VARCHAR2,
                             x_msg_count             OUT  NOCOPY NUMBER,
                             x_msg_data              OUT  NOCOPY VARCHAR2 )is

    l_api_name              VARCHAR2(255):='update_acct_tag_wrap';
    l_api_version_number    NUMBER:=1.0;

    l_return_status         VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER := 0;
    l_msg_data              VARCHAR2(2000);

    IEM_ACCT_TAG_NOT_UPD        EXCEPTION;
    IEM_NO_RULE_UPDATE          EXCEPTION;

    l_in_tab            key_tbl_type ;
    l_out_tab           key_tbl_type ;
    l_count             number;
    l_tag_key_id        iem_tag_keys.tag_key_id%type :=0;

    l_temp              varchar2(256);
BEGIN
-- Standard Start of API savepoint
SAVEPOINT  update_acct_tag_wrap;

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

--API Body
      l_in_tab := IEM_TAG_KEY_PVT.varChar_to_table(p_in_key_id);
      l_out_tab := IEM_TAG_KEY_PVT.varChar_to_table(p_out_key_id);

      --delete association based on OUT list
      for i in 1..l_out_tab.count() loop
        delete from iem_account_tag_keys a where a.email_account_id=p_account_id and a.tag_key_id =
               (select  b.tag_key_id from iem_tag_keys b where UPPER(b.tag_id) = UPPER(l_out_tab(i)) );
      end loop;

      --add association based on IN list
      for j in 1..l_in_tab.count() loop
        select count(*) into l_count from iem_account_tag_keys a, iem_tag_keys b
                                    where a.email_account_id=p_account_id and a.tag_key_id=b.tag_key_id and b.tag_id=l_in_tab(j);

        if l_count=0 then
            select tag_key_id into l_tag_key_id from iem_tag_keys where UPPER(tag_id) = UPPER(l_in_tab(j));

            create_item_account_tags (
                 p_api_version_number     => l_api_version_number,
 		  	     p_init_msg_list          => FND_API.G_FALSE,
		    	 p_commit	              => FND_API.G_FALSE,
                 p_email_account_id       => p_account_id,
  				 p_tag_key_id             => l_tag_key_id,
                 x_return_status          => l_return_status,
                 x_msg_count              => l_msg_count,
                 x_msg_data               => l_msg_data);

            if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
                raise IEM_ACCT_TAG_NOT_UPD;
            end if;

        end if;

      end loop;

    -- Standard Check Of p_commit.
	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;


    EXCEPTION
        WHEN NO_DATA_FOUND THEN
	    ROLLBACK TO update_acct_tag_wrap;
        FND_MESSAGE.SET_NAME('IEM','IEM_ACCT_TAG_NOT_EXIST');
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

        WHEN IEM_ACCT_TAG_NOT_UPD THEN
	    ROLLBACK TO update_acct_tag_wrap;
        FND_MESSAGE.SET_NAME('IEM','IEM_ACCT_TAG_NOT_UPD');
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

        WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO update_acct_tag_wrap;
            x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,p_data => x_msg_data);


        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO update_acct_tag_wrap;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);


        WHEN OTHERS THEN
            ROLLBACK TO update_acct_tag_wrap;
            x_return_status := FND_API.G_RET_STS_ERROR;
            IF  FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
              FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME , l_api_name);
            END IF;


            FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );

END update_acct_tag_wrap;


PROCEDURE update_item_tag_key (
                 p_api_version_number       IN   NUMBER,
    	  	     p_init_msg_list            IN   VARCHAR2 := null,
    	    	 p_commit	                IN   VARCHAR2 := null,
    			 p_tag_key_id               IN   NUMBER,
                 p_key_id                   IN   VARCHAR2:= null,
    			 p_key_name                 IN   VARCHAR2:= null,
                 p_type_type_code           IN   VARCHAR2:= null,
    			 p_value	                IN   VARCHAR2:= null,
			     x_return_status	        OUT	 NOCOPY VARCHAR2,
  		  	     x_msg_count	            OUT	 NOCOPY NUMBER,
	  	  	     x_msg_data	                OUT	 NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='update_item_tag_key';
	l_api_version_number 	NUMBER:=1.0;
    l_return_status         VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER := 0;
    l_msg_data              VARCHAR2(2000);

    l_name_count            NUMBER;
    l_id_count              NUMBER;
    l_cursorid              NUMBER;
    l_error_text            varchar2(2000);

    IEM_TAG_DUP_KEY_NAME        EXCEPTION;
    IEM_TAG_DUP_KEY_ID          EXCEPTION;
    l_invalid_query             EXCEPTION;
    l_IEM_INVALID_PROCEDURE     EXCEPTION;
    IEM_ADM_G_MISS_FOR_NOTNULL EXCEPTION;
BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT		update_item_tag_key;

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

   -- Valid g_miss
   if ( p_key_id=FND_API.G_MISS_CHAR or p_key_name=FND_API.G_MISS_CHAR
        or p_type_type_code=FND_API.G_MISS_CHAR or p_value=FND_API.G_MISS_CHAR) then
        raise  IEM_ADM_G_MISS_FOR_NOTNULL;
   end if;

    --check duplicate key name
    select count(*) into l_name_count from iem_tag_keys where UPPER(tag_name) = UPPER(p_key_name) and tag_key_id <> p_tag_key_id;

    if l_name_count > 0 then
      raise IEM_TAG_DUP_KEY_NAME;
    end if;

    --check duplicate key Id
    select count(*) into l_id_count from iem_tag_keys where UPPER(tag_id) = UPPER(p_key_id) and tag_key_id <> p_tag_key_id;

    if l_id_count > 0 then
      raise IEM_TAG_DUP_KEY_ID;
    end if;

     -- Valid 'QUERY' type and 'PROCEDURE' type
    if p_type_type_code = 'QUERY' then
        IF p_value is NOT NULL THEN
            BEGIN
                l_cursorid := DBMS_SQL.OPEN_CURSOR;
                DBMS_SQL.PARSE(l_cursorid, p_value, DBMS_SQL.V7);

            EXCEPTION
                WHEN OTHERS THEN
                    fnd_message.set_name ('IEM', 'IEM_TAG_INVALID_QUERY');
                    l_error_text := SUBSTR (SQLERRM , 1 , 240);
                    FND_MESSAGE.SET_TOKEN('ERROR_TEXT',l_error_text);
                    FND_MSG_PUB.add;
                    DBMS_SQL.CLOSE_CURSOR(l_cursorid);
                RAISE l_invalid_query;
            END;
        END IF;
    elsif p_type_type_code = 'PROCEDURE' then
        IF p_value is NOT NULL THEN
            IEM_TAG_RUN_PROC_PVT.validProcedure(
                 p_api_version_number  => P_Api_Version_Number,
 		  	     p_init_msg_list       => FND_API.G_FALSE,
		    	 p_commit              => P_Commit,
                 p_ProcName            => p_value,
                 x_return_status       => l_return_status,
  		  	     x_msg_count           => l_msg_count,
	  	  	     x_msg_data            => l_msg_data
			 );
            if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
                raise l_IEM_INVALID_PROCEDURE;
            end if;

        END IF;
    end if;


	update IEM_TAG_KEYS
	set
           --tag_id=decode(p_key_id,FND_API.G_MISS_CHAR,tag_id,p_key_id),
	       tag_name=decode(p_key_name,null,tag_name,p_key_name),
	       tag_type_code=decode(p_type_type_code,null,tag_type_code,p_type_type_code),
           value=decode(p_value,null,tag_type_code,p_value),
           LAST_UPDATED_BY = decode(G_created_updated_by,null,-1,G_created_updated_by),
           LAST_UPDATE_DATE = sysdate,
           LAST_UPDATE_LOGIN = decode(G_LAST_UPDATE_LOGIN,null,-1,G_LAST_UPDATE_LOGIN)
	where tag_key_id=p_tag_key_id;

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

    WHEN l_invalid_query THEN
	 ROLLBACK TO update_item_tag_key;
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN l_IEM_INVALID_PROCEDURE THEN
	 ROLLBACK TO update_item_tag_key;
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN IEM_ADM_G_MISS_FOR_NOTNULL THEN
	    ROLLBACK TO update_item_tag_key;
        FND_MESSAGE.SET_NAME('IEM','IEM_ADM_G_MISS_FOR_NOTNULL');
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN IEM_TAG_DUP_KEY_NAME THEN
	    ROLLBACK TO update_item_tag_key;
        FND_MESSAGE.SET_NAME('IEM','IEM_TAG_DUP_KEY_NAME');
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN IEM_TAG_DUP_KEY_ID THEN
	    ROLLBACK TO update_item_tag_key;
        FND_MESSAGE.SET_NAME('IEM','IEM_TAG_DUP_KEY_ID');
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

   WHEN FND_API.G_EXC_ERROR THEN
	   ROLLBACK TO update_item_tag_key;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
               	p_data  =>      x_msg_data
			);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   ROLLBACK TO update_item_tag_key;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
            	p_data  =>      x_msg_data
			);

   WHEN OTHERS THEN

	ROLLBACK TO update_item_tag_key;
      x_return_status := FND_API.G_RET_STS_ERROR;
	IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME,
    	    			l_api_name
	    		);
	END IF;
	FND_MSG_PUB.Count_And_Get

    		( p_count         	=>      x_msg_count ,
        	p_data          	=>      x_msg_data

    		);

END	update_item_tag_key;


END IEM_TAG_KEY_PVT; -- Package Body IEM_TAG_KEY_PVT

/
