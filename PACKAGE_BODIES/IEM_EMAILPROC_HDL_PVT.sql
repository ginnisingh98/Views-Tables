--------------------------------------------------------
--  DDL for Package Body IEM_EMAILPROC_HDL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_EMAILPROC_HDL_PVT" AS
/* $Header: iemvprob.pls 120.0.12010000.2 2009/07/11 16:52:07 lkullamb ship $ */
--
--
-- Purpose: Mantain IEM_EMAILPROCS, IEM_EMAILPROC_RULES, IEM_ACCOUNT_EMAILPROCS, IEM_ACTIONS, IEM_ACTION_DTLS
-- related operations
--
-- MODIFICATION HISTORY
-- Person      Date         Comments
--  Liang Xia   8/12/2002    Created
-- ---------   ------  ------------------------------------------

-- Enter procedure, function bodies as shown below
G_PKG_NAME CONSTANT varchar2(30) :='IEM_EMAILPROC_HDL_PVT ';
G_ROUTE_ID varchar2(30) ;
G_EMAILPROC_ID varchar2(30);
G_created_updated_by   NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('USER_ID')) ;

G_LAST_UPDATE_LOGIN    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('LOGIN_ ID') ) ;




 --function to create cannonical function
 FUNCTION displayDT_to_canonical ( displayDT    IN   VARCHAR2 )
        return VARCHAR2
       is
       user_mask varchar2(265) := 'DD-MON-YYYY';

       canonicalMask varchar2(265) := 'YYYYMMDD';
 BEGIN
    RETURN to_char( to_date( displayDT, user_mask), canonicalMask);
 EXCEPTION

    WHEN OTHERS THEN
    RETURN (NULL);
END    displayDT_to_canonical;





PROCEDURE create_item_account_emailprocs (
                 p_api_version_number     IN NUMBER,
 		  	     p_init_msg_list          IN VARCHAR2 := null,
		    	 p_commit	              IN VARCHAR2 := null,
                 p_email_account_id       IN NUMBER,
  				 p_emailproc_id           IN NUMBER,
                 p_enabled_flag           IN VARCHAR2,
                 p_priority               IN NUMBER,
                 x_return_status	      OUT NOCOPY VARCHAR2,
  		  	     x_msg_count	          OUT NOCOPY NUMBER,
	  	  	     x_msg_data	              OUT NOCOPY VARCHAR2

			 ) is
	l_api_name        		VARCHAR2(255):='create_item_account_routes';
	l_api_version_number 	NUMBER:=1.0;
    l_seq_id        number;

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT		create_item_acct_routes_PVT;

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

--actual API begins here
	SELECT IEM_ACCOUNT_EMAILPROCS_s1.nextval
	INTO l_seq_id
	FROM dual;

	INSERT INTO IEM_ACCOUNT_EMAILPROCS
	(
	EMAILPROC_ID,
	EMAIL_ACCOUNT_ID,
    ACCOUNT_EMAILPROC_ID,
	ENABLED_FLAG,
    PRIORITY,
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
   p_emailproc_id,
   p_email_account_id,
   l_seq_id,
   p_enabled_flag,
   p_priority,
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
   WHEN FND_API.G_EXC_ERROR THEN

	ROLLBACK TO create_item_acct_routes_PVT;

       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
            	p_data  =>      x_msg_data
			);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO create_item_acct_routes_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,

                 	p_data  =>      x_msg_data
			);


   WHEN OTHERS THEN
	ROLLBACK TO create_item_acct_routes_PVT;
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

    		( p_count         	=>      x_msg_count     	,
        	p_data          	=>      x_msg_data
    		);

 END	create_item_account_emailprocs;


PROCEDURE update_item_emailproc (
                 p_api_version_number    IN   NUMBER,
    	  	     p_init_msg_list    IN   VARCHAR2 := null,
    	    	 p_commit	        IN   VARCHAR2 := null,
    			 p_emailproc_id     IN   NUMBER,
    			 p_name             IN   VARCHAR2:= null,
                 p_description	    IN   VARCHAR2:= null,
                 p_ruling_chain	    IN   VARCHAR2:= null,
                 p_all_email	    IN   VARCHAR2:= null,
                 p_rule_type	    IN   VARCHAR2:= null,
			     x_return_status	OUT	NOCOPY VARCHAR2,
  		  	     x_msg_count	    OUT	NOCOPY NUMBER,
	  	  	     x_msg_data	        OUT	NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='update_item_emailproc';
	l_api_version_number 	NUMBER:=1.0;
    l_return_status        VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER := 0;
    l_msg_data              VARCHAR2(2000);
    l_proc_name             VARCHAR2(256);
    l_name_count                NUMBER;
    IEM_ADM_DUP_NAME            EXCEPTION;
    IEM_ADMIN_ROUTE_NO_PROC     EXCEPTION;
    l_IEM_INVALID_PROCEDURE     EXCEPTION;
    IEM_ADM_G_MISS_FOR_NOTNULL  EXCEPTION;
BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT		update_item_route;

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

   --check duplicate value for attribute Name
    select count(*) into l_name_count
    from iem_emailprocs
    where UPPER(name) = UPPER(p_name) and rule_type=p_rule_type and emailproc_id <> p_emailproc_id;

    if l_name_count > 0 then
      raise IEM_ADM_DUP_NAME;
    end if;

/*
    if p_ruling_chain = 'DYNAMIC' then
        if ( p_proc_name is null ) then
            raise IEM_ADMIN_ROUTE_NO_PROC;
        else
           l_proc_name := LTRIM(RTRIM(p_proc_name));
           if ( l_proc_name = '') then
                raise IEM_ADMIN_ROUTE_NO_PROC;

            else
               --validation goes here.
                IEM_ROUTE_RUN_PROC_PVT.validProcedure(
                     p_api_version_number  => P_Api_Version_Number,
     		  	     p_init_msg_list       => FND_API.G_FALSE,
    		    	 p_commit              => P_Commit,
                     p_ProcName            => l_proc_name,
                     p_return_type         => p_return_type,
                     x_return_status       => l_return_status,
      		  	     x_msg_count           => l_msg_count,
    	  	  	     x_msg_data            => l_msg_data
    			 );
                if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
                    raise l_IEM_INVALID_PROCEDURE;
                end if;
            end if;
        end if;

    end if;
*/

    if ( p_name = FND_API.G_MISS_CHAR ) then
        raise IEM_ADM_G_MISS_FOR_NOTNULL;
    elsif ( p_ruling_chain = FND_API.G_MISS_CHAR ) then
        raise IEM_ADM_G_MISS_FOR_NOTNULL;
    elsif ( p_all_email = FND_API.G_MISS_CHAR ) then
        raise IEM_ADM_G_MISS_FOR_NOTNULL;
    elsif ( p_rule_type = FND_API.G_MISS_CHAR ) then
       raise IEM_ADM_G_MISS_FOR_NOTNULL;
    end if;

	update IEM_EMAILPROCS
	set
           name=decode(p_name,null,name,p_name),
	       description=decode(p_description,FND_API.G_MISS_CHAR,null,null,description,p_description),
	       boolean_type_code=decode(p_ruling_chain,null,boolean_type_code,p_ruling_chain),
           all_email=decode(p_all_email,null,all_email,p_all_email),
           rule_type=decode(p_rule_type,null, rule_type, p_rule_type),
           LAST_UPDATED_BY = decode(G_created_updated_by,FND_API.G_MISS_CHAR,-1,G_created_updated_by),
           LAST_UPDATE_DATE = sysdate,
           LAST_UPDATE_LOGIN = decode(G_LAST_UPDATE_LOGIN,FND_API.G_MISS_CHAR,-1,G_LAST_UPDATE_LOGIN)

	where emailproc_id=p_emailproc_id;

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
    WHEN l_IEM_INVALID_PROCEDURE THEN
	 ROLLBACK TO update_item_route;
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN IEM_ADM_G_MISS_FOR_NOTNULL THEN
	   ROLLBACK TO update_item_route;
        FND_MESSAGE.SET_NAME('IEM','IEM_ADM_G_MISS_FOR_NOTNULL');
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN IEM_ADM_DUP_NAME THEN
	   ROLLBACK TO update_item_route;
        FND_MESSAGE.SET_NAME('IEM','IEM_ADM_DUP_NAME');
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN IEM_ADMIN_ROUTE_NO_PROC THEN
	   ROLLBACK TO update_item_route;
        FND_MESSAGE.SET_NAME('IEM','IEM_ADMIN_ROUTE_NO_PROC');
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

   WHEN FND_API.G_EXC_ERROR THEN
	   ROLLBACK TO update_item_route;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get


			( p_count => x_msg_count,
               	p_data  =>      x_msg_data
			);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   ROLLBACK TO update_item_route;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
            	p_data  =>      x_msg_data
			);


   WHEN OTHERS THEN

	ROLLBACK TO update_item_route;
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

    		( p_count         	=>      x_msg_count     	,
        	p_data          	=>      x_msg_data

    		);

END	update_item_emailproc;


PROCEDURE update_item_rule (p_api_version_number    IN   NUMBER,
     	  	     p_init_msg_list            IN   VARCHAR2 := null,
    	    	 p_commit	                IN   VARCHAR2 := null,
                 p_emailproc_rule_id        IN   NUMBER,
      			 p_key_type_code            IN   VARCHAR2:= null,
      			 p_operator_type_code	    IN   VARCHAR2:= null,
      			 p_value	                IN   VARCHAR2:= null,
			      x_return_status	        OUT NOCOPY VARCHAR2,
  		  	      x_msg_count	            OUT NOCOPY NUMBER,
	  	  	      x_msg_data	            OUT	NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='update_item_rule';
	l_api_version_number 	NUMBER:=1.0;

     l_rule                 NUMBER;

     IEM_NO_RULE_UPDATE     EXCEPTION;
     IEM_ADM_G_MISS_FOR_NOTNULL EXCEPTION;
     --IEM_INVALID_DATE_FORMAT EXCEPTION;
BEGIN
  -- Standard Start of API savepoint

  SAVEPOINT		update_item_rule;
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

  -- check if the route_id exist in iem_routes
  select count(*) into l_rule from iem_emailproc_rules
  where emailproc_rule_id = p_emailproc_rule_id;

  if l_rule < 1 then
    raise IEM_NO_RULE_UPDATE;
  end if;


/*
  -- translate display date format to canonical date
   if ( substrb(p_key_type_code, 4, 1) = 'D' )then

        l_value := displayDT_to_canonical(p_value);


        if ( l_value is NULL ) then
            RAISE IEM_INVALID_DATE_FORMAT;
        end if;
   else
        l_value := p_value;
   end if;
*/

    if ( p_key_type_code = FND_API.G_MISS_CHAR ) then
        raise IEM_ADM_G_MISS_FOR_NOTNULL;
    elsif ( p_operator_type_code = FND_API.G_MISS_CHAR ) then
        raise IEM_ADM_G_MISS_FOR_NOTNULL;
    elsif ( p_value = FND_API.G_MISS_CHAR ) then
        raise IEM_ADM_G_MISS_FOR_NOTNULL;
    end if;

	update IEM_EMAILPROC_RULES
	set
           key_type_code=decode(p_key_type_code,null,key_type_code,p_key_type_code),
	       operator_type_code=decode(p_operator_type_code,null,operator_type_code,p_operator_type_code),
	       value=decode(p_value,null,value,p_value),
           LAST_UPDATED_BY = decode(G_created_updated_by,null,-1,G_created_updated_by),
           LAST_UPDATE_DATE = sysdate,
           LAST_UPDATE_LOGIN = decode(G_LAST_UPDATE_LOGIN,null,-1,G_LAST_UPDATE_LOGIN)
	where emailproc_rule_id=p_emailproc_rule_id;

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
    WHEN IEM_NO_RULE_UPDATE THEN
    	   ROLLBACK TO update_item_rule;
       FND_MESSAGE.SET_NAME('IEM','IEM_NO_RULE_UPDATE');

       FND_MSG_PUB.Add;
       x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN IEM_ADM_G_MISS_FOR_NOTNULL THEN
    	   ROLLBACK TO update_item_rule;
       FND_MESSAGE.SET_NAME('IEM','IEM_ADM_G_MISS_FOR_NOTNULL');

       FND_MSG_PUB.Add;
       x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
/*
    WHEN IEM_INVALID_DATE_FORMAT THEN
    	   ROLLBACK TO update_item_rule;
       FND_MESSAGE.SET_NAME('IEM','IEM_INVALID_DATE_FORMAT');
       FND_MSG_PUB.Add;
       x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
*/
   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO update_item_rule;

       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get

			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO update_item_rule;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN

	ROLLBACK TO update_item_rule;

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
    		( p_count         	=>      x_msg_count     	,
        	p_data          	=>      x_msg_data


    		);

 END	update_item_rule;




PROCEDURE update_account_emailprocs
                (p_api_version_number       IN  NUMBER,
 	  	        p_init_msg_list             IN  VARCHAR2 := null,
	    	    p_commit	                IN  VARCHAR2 := null,
                p_emailproc_id              IN  NUMBER,
			    p_email_account_id          IN  NUMBER,
  			    p_enabled_flag	            IN  VARCHAR2:= NULL,
  			    p_priority	                IN  VARCHAR2:= NULL,
                x_return_status	            OUT	NOCOPY VARCHAR2,
  		  	    x_msg_count	                OUT NOCOPY NUMBER,
	  	  	    x_msg_data	                OUT NOCOPY VARCHAR2
			 ) is
    l_api_name        		VARCHAR2(255):='update_account_emailprocs';
	l_api_version_number 	NUMBER:=1.0;
	l_emailproc_cnt 	NUMBER;
    l_acct_cnt      NUMBER;
     l_LAST_UPDATED_BY    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('USER_ID')) ;
     l_LAST_UPDATE_DATE    DATE:=SYSDATE;
     l_LAST_UPDATE_LOGIN    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('LOGIN_ ID')) ;
    l_enabled_flag          VARCHAR2(1);

BEGIN
-- Standard Start of API savepoint
SAVEPOINT		update_account_emailprocs_PVT;
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

-- 	Check For Existing IEM Server Group

	Select count(*) into l_emailproc_cnt from iem_emailprocs
	where emailproc_id=p_emailproc_id;

	IF l_emailproc_cnt = 0 then
		FND_MESSAGE.SET_NAME('IEM','IEM_ADM_EMAILPROC_NOT_EXIST');
		APP_EXCEPTION.RAISE_EXCEPTION;
	END IF;

	--Changed for 115.11 schema: iem_mstemail_accounts
	Select count(*) into l_acct_cnt from iem_mstemail_accounts
	where email_account_id=p_email_account_id;

	IF l_acct_cnt = 0 then
		FND_MESSAGE.SET_NAME('IEM','IEM_ADMIN_ACCOUNT_NOT_EXIST');
		APP_EXCEPTION.RAISE_EXCEPTION;
	END IF;

    if (p_enabled_flag is null ) then
 	    update IEM_ACCOUNT_EMAILPROCS
        set
	       priority=decode(p_priority,null,priority,p_priority),
           LAST_UPDATED_BY = decode(G_created_updated_by,null,-1,G_created_updated_by),
           LAST_UPDATE_DATE = sysdate,
           LAST_UPDATE_LOGIN = decode(G_LAST_UPDATE_LOGIN,null,-1,G_LAST_UPDATE_LOGIN)
        where emailproc_id = p_emailproc_id and email_account_id = p_email_account_id;
    elsif(p_enabled_flag = FND_API.G_MISS_CHAR ) then
	    update IEM_ACCOUNT_EMAILPROCS
        set
	       enabled_flag='N',
	       priority=decode(p_priority,null,priority,p_priority),
           LAST_UPDATED_BY = decode(G_created_updated_by,null,-1,G_created_updated_by),
           LAST_UPDATE_DATE = sysdate,
           LAST_UPDATE_LOGIN = decode(G_LAST_UPDATE_LOGIN,null,-1,G_LAST_UPDATE_LOGIN)
        where emailproc_id = p_emailproc_id and email_account_id = p_email_account_id;
    elsif (p_enabled_flag = 'Y' or p_enabled_flag = 'N' ) then
	    update IEM_ACCOUNT_EMAILPROCS
        set
  	       enabled_flag=p_enabled_flag,
	       priority=decode(p_priority,null,priority,p_priority),
           LAST_UPDATED_BY = decode(G_created_updated_by,null,-1,G_created_updated_by),
           LAST_UPDATE_DATE = sysdate,
           LAST_UPDATE_LOGIN = decode(G_LAST_UPDATE_LOGIN,null,-1,G_LAST_UPDATE_LOGIN)
        where emailproc_id = p_emailproc_id and email_account_id = p_email_account_id;
    else
 		FND_MESSAGE.SET_NAME('IEM','IEM_ACCT_EMLPROC_INVLD_ENABLED');
		APP_EXCEPTION.RAISE_EXCEPTION;
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

   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO update_account_emailprocs_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get

			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO update_account_emailprocs_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	ROLLBACK TO update_account_emailprocs_PVT;

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
    		( p_count         	=>      x_msg_count,
        	p_data          	=>      x_msg_data

    		);

 END	update_account_emailprocs;




   -- Enter further code below as specified in the Package spec.


PROCEDURE create_item_emailprocs (
                 p_api_version_number  IN   NUMBER,
 		  	     p_init_msg_list       IN   VARCHAR2 := null,
		    	 p_commit              IN   VARCHAR2 := null,
            	 p_name                IN   VARCHAR2,
  				 p_description	       IN   VARCHAR2:= null,
         		 p_boolean_type_code   IN   VARCHAR2,
                 P_rule_type           IN   VARCHAR2,
                 p_all_email           IN   VARCHAR2,
                 x_emailproc_id        OUT  NOCOPY NUMBER,
                 x_return_status	   OUT  NOCOPY VARCHAR2,
  		  	     x_msg_count	       OUT	NOCOPY NUMBER,
	  	  	     x_msg_data	           OUT	NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='create_item_routes';
	l_api_version_number 	NUMBER:=1.0;
    l_seq_id		        NUMBER;
    l_proc_name             VARCHAR2(256);
    l_name_count            NUMBER;

    l_return_status        VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER := 0;
    l_msg_data              VARCHAR2(2000);

    l_all_email             VARCHAR2(1);
    l_description           VARCHAR2(256);
    IEM_ADM_DUP_NAME    EXCEPTION;
    l_IEM_INVALID_PROCEDURE     EXCEPTION;

BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT		create_item_routes_PVT;

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

   --check duplicate value for attribute Name
    select count(*) into l_name_count from iem_emailprocs where rule_type=p_rule_type and UPPER(name) = UPPER(p_name);

    if l_name_count > 0 then
      raise IEM_ADM_DUP_NAME;
    end if;

    if ( p_all_email = FND_API.G_MISS_CHAR ) or ( p_all_email is null ) then
        l_all_email := 'N';
    else
        l_all_email := p_all_email;
    end if;

    if ( p_description = FND_API.G_MISS_CHAR ) or ( p_description is null ) then
        l_description := null;
    else
        l_description := LTRIM(RTRIM(p_description));
    end if;

/*
    if ( p_boolean_type_code = 'DYNAMIC' ) then
         l_proc_name := LTRIM(RTRIM( p_proc_name ) );
         --validation goes here.
            IEM_ROUTE_RUN_PROC_PVT.validProcedure(
                 p_api_version_number  => P_Api_Version_Number,
 		  	     p_init_msg_list       => FND_API.G_FALSE,
		    	 p_commit              => P_Commit,
                 p_ProcName            => l_proc_name,
                 p_return_type         => p_return_type,
                 x_return_status       => l_return_status,
  		  	     x_msg_count           => l_msg_count,
	  	  	     x_msg_data            => l_msg_data
			 );
            if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
                raise l_IEM_INVALID_PROCEDURE;
            end if;
    else
        l_proc_name := null;
    end if;
*/
    --get next sequential number for route_id
   	SELECT IEM_EMAILPROCS_s1.nextval
	INTO l_seq_id
	FROM dual;

	INSERT INTO IEM_EMAILPROCS
	(
	EMAILPROC_ID,
	NAME,
	DESCRIPTION,
	BOOLEAN_TYPE_CODE,
    ALL_EMAIL,
    RULE_TYPE,
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
	p_name,
	l_description,
	p_boolean_type_code,
    l_all_email,
    P_RULE_TYPE,
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

    x_emailproc_id := l_seq_id;

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
    WHEN l_IEM_INVALID_PROCEDURE THEN
	 ROLLBACK TO create_item_routes_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN IEM_ADM_DUP_NAME THEN
	   ROLLBACK TO create_item_routes_PVT;
     FND_MESSAGE.SET_NAME('IEM','IEM_ADM_DUP_NAME');
     FND_MSG_PUB.Add;
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO create_item_routes_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;

       FND_MSG_PUB.Count_And_Get

			( p_count => x_msg_count,
              p_data  => x_msg_data
			);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   ROLLBACK TO create_item_routes_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
              p_data  =>      x_msg_data
			);


   WHEN OTHERS THEN

	ROLLBACK TO create_item_routes_PVT;
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

 END	create_item_emailprocs;


PROCEDURE create_item_emailproc_rules (
                 p_api_version_number   IN   NUMBER,
 		  	     p_init_msg_list        IN   VARCHAR2 := null,
		    	 p_commit	            IN   VARCHAR2 := null,
  				 p_emailproc_id         IN   NUMBER,
  				 p_key_type_code	    IN   VARCHAR2,
  				 p_operator_type_code	IN   VARCHAR2,
                 p_value                IN VARCHAR2,
                 x_return_status	    OUT NOCOPY VARCHAR2,
  		  	     x_msg_count	        OUT	NOCOPY NUMBER,
	  	  	     x_msg_data	            OUT	NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='create_item_emailproc_rules';
	l_api_version_number 	NUMBER:=1.0;

	l_seq_id		number;

   --IEM_INVALID_DATE_FORMAT EXCEPTION;

BEGIN
  -- Standard Start of API savepoint

  SAVEPOINT		create_emailproc_rules_PVT;
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



/*
  -- translate display date format to canonical date
   if ( substrb(p_key_type_code, 4, 1) = 'D' )then

        l_value := displayDT_to_canonical(p_value);


        if ( l_value is NULL ) then
            RAISE IEM_INVALID_DATE_FORMAT;
        end if;
   else

        l_value := p_value;
   end if;
  */


   	SELECT IEM_EMAILPROC_RULES_s1.nextval
	INTO l_seq_id
	FROM dual;

	INSERT INTO IEM_EMAILPROC_RULES
	(
	EMAILPROC_RULE_ID,
	EMAILPROC_ID,
	KEY_TYPE_CODE,
	OPERATOR_TYPE_CODE,
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
	p_emailproc_id,
	p_key_type_code,
	p_operator_type_code,
    p_value,
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
   WHEN FND_API.G_EXC_ERROR THEN
   	       ROLLBACK TO create_emailproc_rules_PVT;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get
			(    p_count => x_msg_count,
            	 p_data  =>      x_msg_data
			);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	       ROLLBACK TO create_emailproc_rules_PVT;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            FND_MSG_PUB.Count_And_Get
			(    p_count => x_msg_count,
              	 p_data  =>      x_msg_data
			);

   WHEN OTHERS THEN
	       ROLLBACK TO create_emailproc_rules_PVT;
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
    		(     p_count         	=>      x_msg_count 	,
        	      p_data          	=>      x_msg_data
    		);
 END	create_item_emailproc_rules;

PROCEDURE create_item_actions (
                 p_api_version_number     IN NUMBER,
 		  	     p_init_msg_list          IN VARCHAR2 := null,
		    	 p_commit	              IN VARCHAR2 := null,
  				 p_emailproc_id           IN NUMBER,
                 p_action_name            IN VARCHAR2,
                 x_action_id              OUT NOCOPY NUMBER,
                 x_return_status	      OUT NOCOPY VARCHAR2,
  		  	     x_msg_count	          OUT NOCOPY NUMBER,
	  	  	     x_msg_data	              OUT NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='create_item_actions';
	l_api_version_number 	NUMBER:=1.0;
    l_seq_id        number;

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT		create_item_actions_PVT;

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

--actual API begins here
	SELECT IEM_ACTIONS_s1.nextval
	INTO l_seq_id
	FROM dual;

	INSERT INTO IEM_ACTIONS
	(
    ACTION_ID,
	EMAILPROC_ID,
	ACTION,
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
   p_emailproc_id,
   p_action_name,
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

    x_action_id := l_seq_id;

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

	ROLLBACK TO create_item_actions_PVT;

       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
            	p_data  =>      x_msg_data
			);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO create_item_actions_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,

                 	p_data  =>      x_msg_data
			);


   WHEN OTHERS THEN
	ROLLBACK TO create_item_actions_PVT;
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

    		( p_count         	=>      x_msg_count     	,
        	p_data          	=>      x_msg_data
    		);

 END	create_item_actions;

PROCEDURE create_item_action_dtls (
                 p_api_version_number   IN   NUMBER,
 		  	     p_init_msg_list    IN  VARCHAR2 := null,
		    	 p_commit	        IN  VARCHAR2 := null,
  				 p_action_id        IN  NUMBER,
  				 p_param1	        IN  VARCHAR2,
  				 p_param2	        IN  VARCHAR2,
  				 p_param3	        IN  VARCHAR2,
                 p_param_tag        IN  VARCHAR2,
                 x_return_status	OUT NOCOPY VARCHAR2,
  		  	     x_msg_count	    OUT NOCOPY NUMBER,
	  	  	     x_msg_data	        OUT	NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='create_item_action_dtls';
	l_api_version_number 	NUMBER:=1.0;
    l_seq_id        number;

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT		create_item_action_dtls_pvt;

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

--actual API begins here
	SELECT IEM_ACTION_DTLS_s1.nextval
	INTO l_seq_id
	FROM dual;

	INSERT INTO IEM_ACTION_DTLS
	(
    ACTION_DTL_ID,
	ACTION_ID,
	PARAMETER1,
    PARAMETER2,
    PARAMETER_TAG,
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
	LAST_UPDATE_LOGIN,
        PARAMETER3
	)
   VALUES
   (
   l_seq_id,
   p_action_id,
   p_param1,
   p_param2,
   p_param_tag,
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
   decode(G_LAST_UPDATE_LOGIN,null,-1,G_LAST_UPDATE_LOGIN),
   p_param3
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
   WHEN FND_API.G_EXC_ERROR THEN

	ROLLBACK TO create_item_action_dtls_pvt;

       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
            	p_data  =>      x_msg_data
			);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO create_item_action_dtls_pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,

                 	p_data  =>      x_msg_data
			);


   WHEN OTHERS THEN
	ROLLBACK TO create_item_action_dtls_pvt;
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

    		( p_count         	=>      x_msg_count     	,
        	p_data          	=>      x_msg_data
    		);

 END	create_item_action_dtls;


PROCEDURE delete_acct_emailproc_batch
     (p_api_version_number      IN  NUMBER,
      P_init_msg_list           IN  VARCHAR2 := null,
      p_commit                  IN  VARCHAR2 := null,
      p_emailproc_ids_tbl       IN  jtf_varchar2_Table_100,
      p_account_id              IN NUMBER,
      p_rule_type               IN VARCHAR2,
      x_return_status   OUT NOCOPY VARCHAR2,
      x_msg_count       OUT NOCOPY NUMBER,
      x_msg_data        OUT NOCOPY VARCHAR2)
IS
    i       INTEGER;
    l_api_name		varchar2(30):='delete_acct_emailproc_batch';
    l_api_version_number number:=1.0;


BEGIN

--Standard Savepoint

SAVEPOINT delete_acct_emailproc_batch;

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
 if ( p_emailproc_ids_tbl.count <> 0 ) then

     FOR i IN p_emailproc_ids_tbl.FIRST..p_emailproc_ids_tbl.LAST LOOP

        -- update priority after delete an account_emailproc
        Update iem_account_emailprocs set priority=priority-1
        where email_account_id=p_account_id
            and priority >
               (Select priority from iem_account_emailprocs
			    where emailproc_id=p_emailproc_ids_tbl(i)
                and  email_account_id=p_account_id)
            and emailproc_id in
                ( select emailproc_id from iem_emailprocs
                where rule_type= p_rule_type);

        DELETE
        FROM IEM_ACCOUNT_EMAILPROCS
        WHERE emailproc_id = p_emailproc_ids_tbl(i) and email_account_id = p_account_id;

   END LOOP;
end if;



--if SQL%NOTFOUND then
--        raise IEM_ACCOUNT_ROUTE_NOT_DELETED;
--end if;

--Standard check of p_commit
IF FND_API.to_Boolean(p_commit) THEN
    COMMIT WORK;
END IF;


EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
	   ROLLBACK TO delete_acct_emailproc_batch;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	   ROLLBACK TO delete_acct_emailproc_batch;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,p_data => x_msg_data);

   WHEN OTHERS THEN
	  ROLLBACK TO delete_acct_emailproc_batch;
      x_return_status := FND_API.G_RET_STS_ERROR;
	  IF 	FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        		FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);
      END IF;

	  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count	,p_data	=> x_msg_data);


END delete_acct_emailproc_batch;

END IEM_EMAILPROC_HDL_PVT ;

/
