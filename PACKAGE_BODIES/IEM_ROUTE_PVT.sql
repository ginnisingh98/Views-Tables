--------------------------------------------------------
--  DDL for Package Body IEM_ROUTE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_ROUTE_PVT" AS
/* $Header: iemvroub.pls 120.0 2005/06/02 13:41:41 appldev noship $ */

--
--
-- Purpose: Mantain route related operations
--
-- MODIFICATION HISTORY
-- Person      Date         Comments
--  Liang Xia   4/24/2001    Created
--  Liang Xia   6/7/2001     added checking duplication on IEM_ROUTES.name for PROCEDURE
--                           create_item_routes and update_item_route
--                           added updating priority in IEM_ACCOUNT_ROUTES for delete_item_batch
--  Liang Xia   6/7/2002     added validation for dynamic Route
--  Liang Xia   11/6/2002    release the validation for ALL_EMAILS and fixed part of "No MISS.." GSCC warning.
--  Liang Xia   12/2/2002    Fixed PLSQL standard: "No MISS.." "NOCOPY" GSCC warning.
--  Liang Xia   12/06/2004   Changed for 115.11 schema: iem_mstemail_account
-- ---------   ------  ------------------------------------------

-- Enter procedure, function bodies as shown below
G_PKG_NAME CONSTANT varchar2(30) :='IEM_ROUTE_PVT ';
G_ROUTE_ID varchar2(30) ;
G_created_updated_by   NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('USER_ID')) ;

G_LAST_UPDATE_LOGIN    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('LOGIN_ ID') ) ;

PROCEDURE delete_acct_route_by_acct
             (p_api_version_number      IN  NUMBER,
              P_init_msg_list           IN  VARCHAR2 := null,
              p_commit                  IN  VARCHAR2 := null,
              p_email_account_id        IN  NUMBER,
              x_return_status           OUT NOCOPY VARCHAR2,
              x_msg_count               OUT NOCOPY NUMBER,
              x_msg_data                OUT NOCOPY VARCHAR2)
IS
    i                       INTEGER;
    l_api_name		        varchar2(30):='delete_acct_route_by_acct';
    l_api_version_number    number:=1.0;

    IEM_ROUTE_NOT_DELETED     EXCEPTION;
BEGIN

    --Standard Savepoint
    SAVEPOINT delete_acct_route_by_acct;

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
            DELETE
            FROM IEM_ACCOUNT_ROUTES
            WHERE email_account_id = p_email_account_id;


    --Standard check of p_commit
    IF FND_API.to_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;

    FND_MSG_PUB.Count_And_Get
  			( p_count => x_msg_count,p_data => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
  	     ROLLBACK TO delete_acct_route_by_acct;
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get

  			( p_count => x_msg_count,p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   ROLLBACK TO delete_acct_route_by_acct;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,p_data => x_msg_data);


   WHEN OTHERS THEN
	  ROLLBACK TO delete_acct_route_by_acct;
      x_return_status := FND_API.G_RET_STS_ERROR;
	  IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);

      END IF;
	  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count	,p_data	=> x_msg_data);

END delete_acct_route_by_acct;


PROCEDURE delete_item_batch
             (p_api_version_number      IN  NUMBER,
              P_init_msg_list           IN  VARCHAR2 := null,
              p_commit                  IN  VARCHAR2 := null,
              p_route_ids_tbl           IN  jtf_varchar2_Table_100,
              x_return_status           OUT NOCOPY VARCHAR2,
              x_msg_count               OUT NOCOPY NUMBER,
              x_msg_data                OUT NOCOPY VARCHAR2)
IS
    i                       INTEGER;
    l_api_name		        varchar2(30):='delete_item_batch';
    l_api_version_number    number:=1.0;

    CURSOR  acct_id_cursor( l_route_id IN NUMBER )  IS
            select email_account_id from iem_account_routes where route_id = l_route_id;

    IEM_ROUTE_NOT_DELETED     EXCEPTION;
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
    FORALL i IN p_route_ids_tbl.FIRST..p_route_ids_tbl.LAST
            DELETE
            FROM IEM_ROUTES

            WHERE route_id = p_route_ids_tbl(i);


    if SQL%NOTFOUND then
        raise IEM_ROUTE_NOT_DELETED;
    end if;

    --Delete the accounts, rules associated with this route
   if ( p_route_ids_tbl.count <> 0 ) then

     FOR i IN p_route_ids_tbl.FIRST..p_route_ids_tbl.LAST LOOP

        -- update priority after delete an account_route

        FOR acct_id IN acct_id_cursor(p_route_ids_tbl(i))  LOOP
               Update iem_account_routes set priority=priority-1

		  			           where  email_account_id=acct_id.email_account_id and priority > (Select priority from iem_account_routes
					           where route_id=p_route_ids_tbl(i)  and email_account_id = acct_id.email_account_id);
        END LOOP;

        DELETE
        FROM IEM_ACCOUNT_ROUTES
        WHERE route_id = p_route_ids_tbl(i);


        DELETE

        FROM IEM_ROUTE_RULES
        WHERE route_id=p_route_ids_tbl(i);
     END LOOP;

   end if;

    --Standard check of p_commit
    IF FND_API.to_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;


EXCEPTION

   WHEN IEM_ROUTE_NOT_DELETED THEN
        ROLLBACK TO delete_item_batch;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('IEM', 'IEM_ROUTE_NOT_DELETED');

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

PROCEDURE create_item_wrap (

                p_api_version_number        IN   NUMBER,
                p_init_msg_list             IN   VARCHAR2 := null,
                p_commit                    IN   VARCHAR2 := null,
                p_route_name                IN   VARCHAR2,
     	        p_route_description         IN   VARCHAR2:= null,
                p_route_boolean_type_code   IN   VARCHAR2,
                p_proc_name                 IN   VARCHAR2 := null,
                p_all_email                 IN   VARCHAR2 := null,
                p_rule_key_typecode_tbl     IN  jtf_varchar2_Table_100,
                p_rule_operator_typecode_tbl IN  jtf_varchar2_Table_100,
                p_rule_value_tbl            IN  jtf_varchar2_Table_300,
                x_return_status             OUT NOCOPY VARCHAR2,
                x_msg_count                 OUT NOCOPY NUMBER,
                x_msg_data                  OUT NOCOPY VARCHAR2 ) is


  l_api_name            VARCHAR2(255):='create_item_wrap';
  l_api_version_number  NUMBER:=1.0;

  l_route_id            IEM_ROUTES.ROUTE_ID%TYPE;
  l_route_rule_id       IEM_ROUTE_RULES.ROUTE_RULE_ID%TYPE;
  l_return_type         VARCHAR2(30);


  l_userid    		    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('USER_ID')) ;
  l_login    		    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('LOGIN_ID')) ;

  l_return_status       VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
  l_msg_count           NUMBER := 0;
  l_msg_data            VARCHAR2(2000);

  logMessage   VARCHAR2(2000);


  IEM_ROUTE_NOT_CREATED EXCEPTION;
  IEM_ROUTE_RULE_NOT_CREATED EXCEPTION;

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT  create_item_wrap;

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
    /*
    FND_LOG_REPOSITORY.init(null,null);

    if fnd_log.test(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_ROUTE_PVT.CREATE_ITEM_WRAP.START') then
        logMessage := '[create item is called!]';
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_ROUTE_PVT.CREATE_ITEM_WRAP.START', logMessage);
    end if;
    */
    --Now call the create_item() to create the acccount
    if ( p_route_boolean_type_code = 'DYNAMIC' ) then
        l_return_type := p_rule_key_typecode_tbl(1);
    else
        l_return_type := FND_API.G_MISS_CHAR;
    end if;

      iem_route_pvt.create_item_routes (
                  p_api_version_number=>p_api_version_number,
                  p_init_msg_list  => p_init_msg_list,
      		      p_commit	   => FND_API.G_FALSE,
  				  p_name => p_route_name,
  				  p_description	=> p_route_description,
  				  p_boolean_type_code	=>p_route_boolean_type_code,
                  p_proc_name => p_proc_name,
                  p_all_email => p_all_email,
                  p_return_type => l_return_type,
                  x_return_status =>l_return_status,
                  x_msg_count   => l_msg_count,
                  x_msg_data => l_msg_data);


   if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then

        raise IEM_ROUTE_NOT_CREATED;
   end if;


   --Getting the newly created email account id
   l_route_id := G_ROUTE_ID;

  -- dbms_output.put_line('route id :  '||l_route_id);

  if p_rule_key_typecode_tbl.count > 0 then
   FOR i IN p_rule_key_typecode_tbl.FIRST..p_rule_key_typecode_tbl.LAST loop

        iem_route_pvt.create_item_route_rules (


                         p_api_version_number=>p_api_version_number,
         		  	     p_init_msg_list  => p_init_msg_list,
        		    	 p_commit	   => p_commit,
          				 p_route_id => l_route_id,
          				 p_key_type_code	=> p_rule_key_typecode_tbl(i),
          				 p_operator_type_code	=> p_rule_operator_typecode_tbl(i),
                         p_value =>p_rule_value_tbl(i),
                         x_return_status =>l_return_status,
                         x_msg_count   => l_msg_count,
                         x_msg_data => l_msg_data);


        if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
            raise IEM_ROUTE_RULE_NOT_CREATED;
        end if;
   end loop;
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
         WHEN IEM_ROUTE_NOT_CREATED THEN
      	     ROLLBACK TO create_item_wrap;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);


        WHEN IEM_ROUTE_RULE_NOT_CREATED THEN

      	     ROLLBACK TO create_item_wrap;
            FND_MESSAGE.SET_NAME('IEM','IEM_ROUTE_RULE_NOT_CREATED');
            FND_MSG_PUB.Add;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);


        WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO create_item_wrap;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,p_data => x_msg_data);


        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

            ROLLBACK TO create_item_wrap;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

        WHEN OTHERS THEN
            ROLLBACK TO create_item_wrap;
            x_return_status := FND_API.G_RET_STS_ERROR;
            IF  FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
                FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME , l_api_name);
            END IF;

            FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );

END create_item_wrap;



PROCEDURE create_item_routes (
                 p_api_version_number  IN   NUMBER,
 		  	     p_init_msg_list       IN   VARCHAR2 := null,
		    	 p_commit              IN   VARCHAR2 := null,
            	 p_name                IN   VARCHAR2,
  				 p_description	       IN   VARCHAR2:= null,
         		 p_boolean_type_code   IN   VARCHAR2,
                 p_proc_name           IN   VARCHAR2 := null,
                 p_all_email           IN   VARCHAR2 := null,
                 p_return_type         IN   VARCHAR2 := null,
                 x_return_status	   OUT  NOCOPY VARCHAR2,
  		  	     x_msg_count	       OUT	NOCOPY NUMBER,
	  	  	     x_msg_data	           OUT	NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='create_item_routes';
	l_api_version_number 	NUMBER:=1.0;
    l_seq_id		        NUMBER;
    l_proc_name             VARCHAR2(256);
    l_name_count            NUMBER;
    l_all_email             VARCHAR2(1);
    l_description           VARCHAR2(256);
    l_return_status        VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER := 0;
    l_msg_data              VARCHAR2(2000);

    IEM_ADMIN_ROUTE_DUP_NAME    EXCEPTION;
    l_IEM_INVALID_PROCEDURE     EXCEPTION;
    IEM_ADM_NO_PROCEDURE_NAME   EXCEPTION;

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
    select count(*) into l_name_count from iem_routes where UPPER(name) = UPPER(p_name);

    if l_name_count > 0 then
      raise IEM_ADMIN_ROUTE_DUP_NAME;
    end if;

    if p_all_email is null or p_all_email = FND_API.G_MISS_CHAR then
        l_all_email := 'N';
    elsif ( p_all_email <> 'N' and p_all_email<>'Y') then
        l_all_email := 'N';
    else
        l_all_email := p_all_email;
    end if;

    if ( p_boolean_type_code = 'DYNAMIC' ) then
        if p_proc_name is null or p_proc_name = FND_API.G_MISS_CHAR then
            raise IEM_ADM_NO_PROCEDURE_NAME;
        else
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
        end if;
    else
        l_proc_name := null;
    end if;

    if p_description=FND_API.G_MISS_CHAR then
        l_description := null;
    else
        l_description := p_description;
    end if;

    --get next sequential number for route_id
   	SELECT IEM_ROUTES_s1.nextval
	INTO l_seq_id
	FROM dual;

    G_ROUTE_ID := l_seq_id;

	INSERT INTO IEM_ROUTES
	(
	ROUTE_ID,
	NAME,
	DESCRIPTION,
	BOOLEAN_TYPE_CODE,
    PROCEDURE_NAME,
    all_email,
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
    l_proc_name,
    l_all_email,
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
    WHEN l_IEM_INVALID_PROCEDURE THEN
	 ROLLBACK TO create_item_routes_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN IEM_ADMIN_ROUTE_DUP_NAME THEN
	   ROLLBACK TO create_item_routes_PVT;
     FND_MESSAGE.SET_NAME('IEM','IEM_ADMIN_ROUTE_DUP_NAME');
     FND_MSG_PUB.Add;
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN IEM_ADM_NO_PROCEDURE_NAME THEN
	   ROLLBACK TO create_item_routes_PVT;
     FND_MESSAGE.SET_NAME('IEM','IEM_ADM_NO_PROCEDURE_NAME');
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

 END	create_item_routes;

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



PROCEDURE create_item_route_rules (
                 p_api_version_number   IN   NUMBER,
 		  	     p_init_msg_list        IN   VARCHAR2 := null,
		    	 p_commit	            IN   VARCHAR2 := null,
  				 p_route_id             IN   NUMBER,
  				 p_key_type_code	    IN   VARCHAR2,
  				 p_operator_type_code	IN   VARCHAR2,
                 p_value                IN   VARCHAR2,
                 x_return_status	    OUT NOCOPY VARCHAR2,
  		  	     x_msg_count	        OUT NOCOPY NUMBER,
	  	  	     x_msg_data	            OUT	NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='create_item_route_rules';
	l_api_version_number 	NUMBER:=1.0;

	l_seq_id		number;

   --IEM_INVALID_DATE_FORMAT EXCEPTION;

BEGIN
  -- Standard Start of API savepoint

  SAVEPOINT		create_item_route_rules_PVT;
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


   	SELECT IEM_ROUTE_RULES_s1.nextval
	INTO l_seq_id
	FROM dual;



	INSERT INTO IEM_ROUTE_RULES
	(

	ROUTE_RULE_ID,
	ROUTE_ID,
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
	p_route_id,
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
	       ROLLBACK TO create_item_route_rules_PVT;

            x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get
			(    p_count => x_msg_count,
            	 p_data  =>      x_msg_data
			);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	       ROLLBACK TO create_item_route_rules_PVT;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            FND_MSG_PUB.Count_And_Get

			(    p_count => x_msg_count,
              	 p_data  =>      x_msg_data
			);


   WHEN OTHERS THEN
	       ROLLBACK TO create_item_route_rules_PVT;
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
 END	create_item_route_rules;



PROCEDURE create_item_account_routes (
                 p_api_version_number     IN NUMBER,
 		  	     p_init_msg_list          IN VARCHAR2 := null,
		    	 p_commit	              IN VARCHAR2 := null,
                 p_email_account_id       IN NUMBER,
  				 p_route_id               IN NUMBER,
  				 p_destination_group_id	  IN NUMBER,
                 p_default_grp_id         IN NUMBER,
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
	SELECT IEM_ACCOUNT_ROUTES_s1.nextval
	INTO l_seq_id
	FROM dual;

	INSERT INTO IEM_ACCOUNT_ROUTES

	(
	ROUTE_ID,
	EMAIL_ACCOUNT_ID,
    ACCOUNT_ROUTE_ID,

    DESTINATION_GROUP_ID,
    DEFAULT_GROUP_ID,
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
   p_route_id,
   p_email_account_id,
   l_seq_id,
   p_destination_group_id,
   p_default_grp_id,
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

 END	create_item_account_routes;

--update iem_routes, update iem_route_rules, insert iem_route_rules
PROCEDURE update_item_wrap (p_api_version_number    IN   NUMBER,
 	                         p_init_msg_list        IN   VARCHAR2 := null,
	                         p_commit	            IN   VARCHAR2 := null,
	                         p_route_id             IN   NUMBER,
  	                         p_name                 IN   VARCHAR2:= null,
  	                         p_ruling_chain	        IN   VARCHAR2:= null,
                             p_description          IN   VARCHAR2:= null,
                             p_procedure_name       IN   VARCHAR2:= null,
                             p_all_emails           IN   VARCHAR2:= null,
                             --below is the data for update
                             p_update_rule_ids_tbl IN  jtf_varchar2_Table_100,
                             p_update_rule_keys_tbl IN  jtf_varchar2_Table_100,
  	                         p_update_rule_operators_tbl IN  jtf_varchar2_Table_100,
                             p_update_rule_values_tbl IN  jtf_varchar2_Table_300,
                             --below is the data for insert
                             p_new_rule_keys_tbl IN  jtf_varchar2_Table_100,
  	                         p_new_rule_operators_tbl IN  jtf_varchar2_Table_100,
                             p_new_rule_values_tbl IN  jtf_varchar2_Table_300,
                             --below is the data to be removed
                             p_remove_rule_ids_tbl IN  jtf_varchar2_Table_100,
                             x_return_status         OUT NOCOPY VARCHAR2,
                             x_msg_count             OUT NOCOPY NUMBER,
                             x_msg_data              OUT NOCOPY VARCHAR2 )is

    l_api_name              VARCHAR2(255):='update_item_wrap';
    l_api_version_number    NUMBER:=1.0;

    l_return_status         VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER := 0;
    l_msg_data              VARCHAR2(2000);

    IEM_NO_ROUTE_UPDATE         EXCEPTION;
    IEM_NO_RULE_UPDATE          EXCEPTION;

    IEM_RULE_NOT_DELETED        EXCEPTION;
    IEM_ROUTE_RULE_NOT_CREATED  EXCEPTION;
    IEM_ADMIN_ROUTE_NO_RULE     ExcePTION;
    l_IEM_FAIL_TO_CALL          EXCEPTION;

    l_route                 NUMBER;
    l_rule_count            NUMBER;
    l_proc_name             VARCHAR2(256);
    l_return_type           VARCHAR2(30);
    l_description           VARCHAR2(256);
BEGIN
-- Standard Start of API savepoint
SAVEPOINT  update_item_wrap;

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


--check if the route_id exist before update
  select count(*) into l_route from iem_routes where route_id = p_route_id;

  if l_route < 1 then
    raise IEM_NO_ROUTE_UPDATE;
  end if;

--Dynamic route validation
    if ( p_ruling_chain =  'DYNAMIC' ) then
        l_proc_name := LTRIM(RTRIM( p_procedure_name ) );
        l_return_type := p_update_rule_keys_tbl(1);
        --validation goes here
    else
        l_proc_name := FND_API.G_MISS_CHAR;
        l_return_type := FND_API.G_MISS_CHAR;
    end if;

--update iem_routes table
   if p_description is null then
        l_description := FND_API.G_MISS_CHAR;
   elsif l_description = FND_API.G_MISS_CHAR then
        l_description := null;
   else
        l_description := p_description;
   end if;
    iem_route_pvt.update_item_route(
                                p_api_version_number => l_api_version_number,
                    	  	    p_init_msg_list => FND_API.G_FALSE,
   	                            p_commit => FND_API.G_FALSE,
			                   p_route_id => p_route_id,
  			                   p_name => p_name,
                               p_all_emails => p_all_emails,
  			                   p_description	=>l_description,
  			                   p_ruling_chain	=>p_ruling_chain,
                               p_proc_name => l_proc_name,
                               p_return_type => l_return_type,
                               x_return_status => l_return_status,
                               x_msg_count => l_msg_count,
                               x_msg_data => l_msg_data);


   if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
        raise l_IEM_FAIL_TO_CALL;
   end if;


  --update iem_route_rules table
  if ( p_update_rule_ids_tbl.count <>0 ) then

   FOR i IN p_update_rule_ids_tbl.FIRST..p_update_rule_ids_tbl.LAST   loop
      iem_route_pvt.update_item_rule(p_api_version_number => l_api_version_number,
                      	  	    p_init_msg_list => FND_API.G_FALSE,
	                            p_commit => FND_API.G_FALSE,
  			                   p_route_rule_id => p_update_rule_ids_tbl(i),
  			                   p_key_type_code	=>p_update_rule_keys_tbl(i),
  			                   p_operator_type_code	=>p_update_rule_operators_tbl(i),
                               p_value => p_update_rule_values_tbl(i),

                               x_return_status => l_return_status,
                               x_msg_count => l_msg_count,
                               x_msg_data => l_msg_data);

      if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
          raise IEM_NO_RULE_UPDATE;
      end if;
  end loop;
end if;


    -- update by deleting rules from iem_route_rules table
if ( p_remove_rule_ids_tbl.count <> 0 ) then
    FORALL i IN p_remove_rule_ids_tbl.FIRST..p_remove_rule_ids_tbl.LAST
        DELETE
        FROM IEM_ROUTE_RULES
        WHERE route_rule_id = p_remove_rule_ids_tbl(i);

    if SQL%NOTFOUND then
        raise IEM_RULE_NOT_DELETED;
    end if;
end if;

 if ( p_new_rule_keys_tbl.count <> 0 ) then
    FOR i IN p_new_rule_keys_tbl.FIRST..p_new_rule_keys_tbl.LAST   LOOP
         iem_route_pvt.create_item_route_rules (p_api_version_number=>p_api_version_number,
                                 		  	     p_init_msg_list  => p_init_msg_list,
                                		    	 p_commit	   => p_commit,
                                  				 p_route_id => p_route_id,
                                  				 p_key_type_code	=> p_new_rule_keys_tbl(i),
                                  				 p_operator_type_code	=> p_new_rule_operators_tbl(i),

                                                 p_value =>p_new_rule_values_tbl(i),

                                                x_return_status =>l_return_status,
                                                x_msg_count   => l_msg_count,
                                                x_msg_data => l_msg_data);

        if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
            raise IEM_ROUTE_RULE_NOT_CREATED;
        end if;
     END LOOP;
  end if;

     -- check if exist at least one rule for each route

    select count(*) into l_rule_count from iem_route_rules where route_id = p_route_id;

    if  p_all_emails<>'Y' then
        if l_rule_count < 1 then
            raise IEM_ADMIN_ROUTE_NO_RULE;
        end if;
    end if;

    commit work;

    EXCEPTION
        WHEN l_IEM_FAIL_TO_CALL THEN
      	   ROLLBACK TO update_item_wrap;
          -- FND_MESSAGE.SET_NAME('IEM','IEM_NO_ROUTE_UPDATE');

         --  FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

        WHEN IEM_NO_ROUTE_UPDATE THEN
      	   ROLLBACK TO update_item_wrap;
            FND_MESSAGE.SET_NAME('IEM','IEM_NO_ROUTE_UPDATE');

            FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        WHEN IEM_NO_RULE_UPDATE THEN
      	   ROLLBACK TO update_item_wrap;
           FND_MESSAGE.SET_NAME('IEM','IEM_NO_RULE_UPDATE');
           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

        WHEN IEM_RULE_NOT_DELETED THEN

      	   ROLLBACK TO update_item_wrap;
           FND_MESSAGE.SET_NAME('IEM','IEM_RULE_NOT_DELETED');
           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR ;

          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

        WHEN IEM_ROUTE_RULE_NOT_CREATED THEN
      	   ROLLBACK TO update_item_wrap;
           FND_MESSAGE.SET_NAME('IEM','IEM_ROUTE_RULE_NOT_CREATED');
           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);


         WHEN IEM_ADMIN_ROUTE_NO_RULE THEN
      	   ROLLBACK TO update_item_wrap;
           FND_MESSAGE.SET_NAME('IEM','IEM_ADMIN_ROUTE_NO_RULE');
           FND_MSG_PUB.Add;

           x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

        WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO update_item_wrap;
            x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,p_data => x_msg_data);


        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO update_item_wrap;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);


        WHEN OTHERS THEN
            ROLLBACK TO update_item_wrap;
            x_return_status := FND_API.G_RET_STS_ERROR;
            IF  FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
              FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME , l_api_name);
            END IF;


            FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );

END update_item_wrap;

PROCEDURE update_item_route (
                 p_api_version_number   IN   NUMBER,
    	  	     p_init_msg_list        IN   VARCHAR2 := null,
    	    	 p_commit	            IN   VARCHAR2 := null,
    			 p_route_id             IN   NUMBER,
    			 p_name                 IN   VARCHAR2:= null,
    			 p_description	        IN   VARCHAR2:= null,
                 p_all_emails           IN   VARCHAR2:= null,
                 p_proc_name	        IN   VARCHAR2:= null,
                 p_return_type          IN   VARCHAR2:= null,
    			 p_ruling_chain	        IN   VARCHAR2:= null,
			     x_return_status	    OUT	NOCOPY VARCHAR2,
  		  	     x_msg_count	        OUT NOCOPY NUMBER,
	  	  	     x_msg_data	            OUT	NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='update_item_route';
	l_api_version_number 	NUMBER:=1.0;
    l_return_status        VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER := 0;
    l_msg_data              VARCHAR2(2000);
    l_proc_name             VARCHAR2(256);
    l_name_count                NUMBER;
    IEM_ADMIN_ROUTE_DUP_NAME    EXCEPTION;
    IEM_ADMIN_ROUTE_NO_PROC     EXCEPTION;
    l_IEM_INVALID_PROCEDURE     EXCEPTION;
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

    select count(*) into l_name_count from iem_routes where UPPER(name) = UPPER(p_name) and route_id <> p_route_id;


    if l_name_count > 0 then
      raise IEM_ADMIN_ROUTE_DUP_NAME;
    end if;

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

	update IEM_ROUTES
	set
           name=decode(p_name,null,name,p_name),
	       description=decode(p_description,FND_API.G_MISS_CHAR,null,null,description,p_description),
	       boolean_type_code=decode(p_ruling_chain,null,boolean_type_code,p_ruling_chain),
           procedure_name=decode(l_proc_name,FND_API.G_MISS_CHAR,null,null,procedure_name,l_proc_name),
           all_email=decode(p_all_emails,FND_API.G_MISS_CHAR,null,null,all_email,p_all_emails),
           LAST_UPDATED_BY = decode(G_created_updated_by,null,-1,G_created_updated_by),
           LAST_UPDATE_DATE = sysdate,
           LAST_UPDATE_LOGIN = decode(G_LAST_UPDATE_LOGIN,null,-1,G_LAST_UPDATE_LOGIN)

	where route_id=p_route_id;

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

    WHEN IEM_ADMIN_ROUTE_DUP_NAME THEN
	   ROLLBACK TO update_item_route;
        FND_MESSAGE.SET_NAME('IEM','IEM_ADMIN_ROUTE_DUP_NAME');
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

END	update_item_route;


PROCEDURE update_item_rule
                (p_api_version_number       IN  NUMBER,
     	  	     p_init_msg_list            IN  VARCHAR2 := null,
    	    	 p_commit	                IN  VARCHAR2 := null,
                 p_route_rule_id            IN  NUMBER   := null,
      			 p_key_type_code            IN  VARCHAR2:= null,
      			 p_operator_type_code	    IN  VARCHAR2:= null,
      			 p_value	                IN   VARCHAR2:= null,
			      x_return_status	        OUT	NOCOPY VARCHAR2,
  		  	      x_msg_count	            OUT NOCOPY NUMBER,
	  	  	      x_msg_data	            OUT	NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='update_item_rule';
	l_api_version_number 	NUMBER:=1.0;

     l_rule                 NUMBER;

     IEM_NO_RULE_UPDATE     EXCEPTION;
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
  select count(*) into l_rule from iem_route_rules

  where route_rule_id = p_route_rule_id;

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



	update IEM_ROUTE_RULES
	set
           key_type_code=decode(p_key_type_code,null,key_type_code,p_key_type_code),
	       operator_type_code=decode(p_operator_type_code,null,operator_type_code,p_operator_type_code),
	       value=decode(p_value,null,value,p_value),
           LAST_UPDATED_BY = decode(G_created_updated_by,null,-1,G_created_updated_by),
           LAST_UPDATE_DATE = sysdate,
           LAST_UPDATE_LOGIN = decode(G_LAST_UPDATE_LOGIN,null,-1,G_LAST_UPDATE_LOGIN)
	where route_rule_id=p_route_rule_id;



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



PROCEDURE create_wrap_account_routes (
                     p_api_version_number   IN   NUMBER,
        		  	 p_init_msg_list        IN   VARCHAR2 := null,
        		     p_commit	            IN   VARCHAR2 := null,
                     p_email_account_id     IN   NUMBER,
      				 p_route_id             IN   NUMBER,
      				 p_destination_group_id	IN   NUMBER,
                     p_default_grp_id       IN   NUMBER,
                     p_enabled_flag         IN   VARCHAR2,
                     p_priority             IN   NUMBER,
                     x_return_status	    OUT NOCOPY VARCHAR2,
      		  	     x_msg_count	        OUT NOCOPY NUMBER,
    	  	  	     x_msg_data 	        OUT	NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='create_item_account_routes';
	l_api_version_number 	NUMBER:=1.0;

    l_route         number;

    l_account       number;


    l_return_status         VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER := 0;
    l_msg_data              VARCHAR2(2000);

    IEM_ADMIN_ROUTE_NOT_EXIST      EXCEPTION;
    IEM_ADMIN_ACCOUNT_NOT_EXIST    EXCEPTION;
    IEM_ACCOUNT_ROUTE_NOT_UPDATED   EXCEPTION;
BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT		create_wrap_account_routes_PVT;

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
    select count(*) into l_route from iem_routes
        where route_id = p_route_id;

    if l_route < 1 then

        raise IEM_ADMIN_ROUTE_NOT_EXIST;
    end if;

    -- check if the account_id exist in iem_email_accounts

    select count(*) into l_account from iem_mstemail_accounts
        where email_account_id = p_email_account_id;

    if l_account < 1 then
        raise IEM_ADMIN_ACCOUNT_NOT_EXIST;
    end if;



    iem_route_pvt.create_item_account_routes(
                              p_api_version_number =>p_api_version_number,
                              p_init_msg_list => p_init_msg_list,
                              p_commit => p_commit,


                              p_route_id =>p_route_id,
                              p_email_account_id =>p_email_account_id,
                              p_destination_group_id => p_destination_group_id,
                              p_default_grp_id => p_default_grp_id,
                              p_enabled_flag => p_enabled_flag,
                              p_priority => p_priority,


                              x_return_status =>l_return_status,
                              x_msg_count   => l_msg_count,
                              x_msg_data => l_msg_data);

  if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
          raise IEM_ACCOUNT_ROUTE_NOT_UPDATED;

  end if;


  --dbms_output.put_line('after insert : ');
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
    WHEN IEM_ADMIN_ROUTE_NOT_EXIST THEN
      	   ROLLBACK TO create_wrap_account_routes_PVT;
           FND_MESSAGE.SET_NAME('IEM','IEM_ADMIN_ROUTE_NOT_EXIST');

           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN IEM_ADMIN_ACCOUNT_NOT_EXIST THEN
      	   ROLLBACK TO create_wrap_account_routes_PVT;
           FND_MESSAGE.SET_NAME('IEM','IEM_ADMIN_ACCOUNT_NOT_EXIST');
           FND_MSG_PUB.Add;

           x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN IEM_ACCOUNT_ROUTE_NOT_UPDATED THEN

      	   ROLLBACK TO create_wrap_account_routes_PVT;
           FND_MESSAGE.SET_NAME('IEM','IEM_ACCOUNT_ROUTE_NOT_UPDATED');
           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN FND_API.G_EXC_ERROR THEN
	       ROLLBACK TO create_wrap_account_routes_PVT;
            x_return_status := FND_API.G_RET_STS_ERROR ;

            FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data

			);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	       ROLLBACK TO create_wrap_account_routes_PVT;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);


   WHEN OTHERS THEN
	       ROLLBACK TO create_wrap_account_routes_PVT;

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

 END	create_wrap_account_routes;

PROCEDURE update_account_routes(p_api_version_number    IN   NUMBER,
 	  	            p_init_msg_list         IN   VARCHAR2 := null,
	    	        p_commit	            IN   VARCHAR2 := null,
                    p_route_id              IN   NUMBER,
			        p_email_account_id      IN   NUMBER,
  			        p_destination_grp_id    IN   VARCHAR2:= null,
  			        p_default_grp_id	    IN   VARCHAR2:= null,
  			        p_enabled_flag	        IN   VARCHAR2:= null,
  			        p_priority	            IN   VARCHAR2:= null,
                    x_return_status	        OUT	NOCOPY VARCHAR2,
  		  	        x_msg_count	            OUT	NOCOPY NUMBER,
	  	  	        x_msg_data	            OUT	NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='update_account_routes';
	l_api_version_number 	NUMBER:=1.0;
	l_route_cnt 	NUMBER;
    l_acct_cnt      NUMBER;
     l_LAST_UPDATED_BY    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('USER_ID')) ;
     l_LAST_UPDATE_DATE    DATE:=SYSDATE;
     l_LAST_UPDATE_LOGIN    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('LOGIN_ ID')) ;

    IEM_ADM_G_MISS_FOR_NOTNULL EXCEPTION;

BEGIN
-- Standard Start of API savepoint
SAVEPOINT		update_account_routes_PVT;
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
IF p_route_id <> FND_API.G_MISS_NUM THEN
	Select count(*) into l_route_cnt from iem_routes
	where route_id=p_route_id;


	IF l_route_cnt = 0 then
		FND_MESSAGE.SET_NAME('IEM','IEM_ADMIN_ROUTE_NOT_EXIST');

		APP_EXCEPTION.RAISE_EXCEPTION;
	END IF;
END IF;

IF p_email_account_id <> FND_API.G_MISS_NUM THEN
	/*Check For Existing DB Server Group Id */

	Select count(*) into l_acct_cnt from iem_mstemail_accounts
	where email_account_id=p_email_account_id;


	IF l_acct_cnt = 0 then
		FND_MESSAGE.SET_NAME('IEM','IEM_ADMIN_ACCOUNT_NOT_EXIST');
		APP_EXCEPTION.RAISE_EXCEPTION;

	END IF;
END IF;

    if ( p_destination_grp_id = FND_API.G_MISS_CHAR ) Then
        raise IEM_ADM_G_MISS_FOR_NOTNULL;
    elsif ( p_default_grp_id = FND_API.G_MISS_CHAR ) then
        raise IEM_ADM_G_MISS_FOR_NOTNULL;
    elsif ( p_enabled_flag = FND_API.G_MISS_CHAR) then
         raise IEM_ADM_G_MISS_FOR_NOTNULL;
    elsif ( p_priority = FND_API.G_MISS_CHAR) then
         raise IEM_ADM_G_MISS_FOR_NOTNULL;
    end if;


if ((p_email_account_id <> FND_API.G_MISS_NUM) and (p_route_id <> FND_API.G_MISS_NUM)) then
	update IEM_ACCOUNT_ROUTES
	set
            destination_group_id = decode(p_destination_grp_id,null,destination_group_id,p_destination_grp_id),
	        default_group_id =decode(p_default_grp_id,null,default_group_id,p_default_grp_id),
	        enabled_flag=decode(p_enabled_flag,null,enabled_flag,p_enabled_flag),
	        priority=decode(p_priority,null,priority,p_priority),
           LAST_UPDATED_BY = decode(G_created_updated_by,null,-1,G_created_updated_by),
           LAST_UPDATE_DATE = sysdate,
           LAST_UPDATE_LOGIN = decode(G_LAST_UPDATE_LOGIN,null,-1,G_LAST_UPDATE_LOGIN)
     where route_id = p_route_id and email_account_id = p_email_account_id;
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
    WHEN IEM_ADM_G_MISS_FOR_NOTNULL THEN
      	   ROLLBACK TO update_account_routes_PVT;
           FND_MESSAGE.SET_NAME('IEM','IEM_ADM_G_MISS_FOR_NOTNULL');
           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO update_account_routes_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get

			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO update_account_routes_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	ROLLBACK TO update_account_routes_PVT;

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

 END	update_account_routes;



PROCEDURE delete_acct_route_batch
     (p_api_version_number      IN  NUMBER,
      P_init_msg_list           IN  VARCHAR2 := null,
      p_commit                  IN  VARCHAR2 := null,
      p_route_ids_tbl           IN  jtf_varchar2_Table_100,
      p_account_id              IN  NUMBER,
      x_return_status           OUT NOCOPY VARCHAR2,
      x_msg_count               OUT NOCOPY NUMBER,
      x_msg_data                OUT NOCOPY VARCHAR2)
IS
    i       INTEGER;
    l_api_name		varchar2(30):='delete_acct_route_batch';
    l_api_version_number number:=1.0;

    IEM_ACCOUNT_ROUTE_NOT_DELETED     EXCEPTION;

BEGIN

--Standard Savepoint

    SAVEPOINT delete_acct_route_batch;

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
 if ( p_route_ids_tbl.count <> 0 ) then

     FOR i IN p_route_ids_tbl.FIRST..p_route_ids_tbl.LAST LOOP



        -- update priority after delete an account_route
        Update iem_account_routes set priority=priority-1
					           where email_account_id=p_account_id and priority > (Select priority from iem_account_routes
					           where route_id=p_route_ids_tbl(i) and  email_account_id=p_account_id);

        DELETE
        FROM IEM_ACCOUNT_ROUTES
        WHERE route_id = p_route_ids_tbl(i) and email_account_id = p_account_id;

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
   WHEN IEM_ACCOUNT_ROUTE_NOT_DELETED THEN
        ROLLBACK TO delete_acct_route_batch;


        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('IEM', 'IEM_ACCOUNT_ROUTE_NOT_DELETED');
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

   WHEN FND_API.G_EXC_ERROR THEN
	   ROLLBACK TO delete_acct_route_batch;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	   ROLLBACK TO delete_acct_route_batch;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,p_data => x_msg_data);

   WHEN OTHERS THEN
	  ROLLBACK TO delete_acct_route_batch;
      x_return_status := FND_API.G_RET_STS_ERROR;
	  IF 	FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        		FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);
      END IF;

	  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count	,p_data	=> x_msg_data);


END delete_acct_route_batch;



-- to update and delete new tuples in iem_account_routes
PROCEDURE update_wrap_account_routes
                (p_api_version_number   IN   NUMBER,
 		  	     p_init_msg_list        IN   VARCHAR2 := null,
		    	 p_commit	            IN   VARCHAR2 := null,
                 p_email_account_id     IN NUMBER,
  				 p_route_ids_tbl        IN  jtf_varchar2_Table_100,
  				 p_upd_dest_ids_tbl     IN  jtf_varchar2_Table_100,

                 p_upd_default_ids_tbl  IN  jtf_varchar2_Table_100,
                 p_upd_enable_flag_tbl  IN  jtf_varchar2_Table_100,
                 --p_upd_priority_tbl IN  jtf_varchar2_Table_100,

                 p_delete_route_ids_tbl IN  jtf_varchar2_Table_100,

                 x_return_status        OUT NOCOPY VARCHAR2,
  		  	     x_msg_count	        OUT NOCOPY NUMBER,
	  	  	     x_msg_data	            OUT	NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='update_wrap_account_routes';

	l_api_version_number 	NUMBER:=1.0;


    l_return_status         VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;

    l_msg_count             NUMBER := 0;
    l_msg_data              VARCHAR2(2000);

    IEM_ACCOUNT_ROUTE_NOT_DELETED    EXCEPTION;
    IEM_ACCOUNT_ROUTE_NOT_UPDATED   EXCEPTION;
BEGIN
-- Standard Start of API savepoint
SAVEPOINT		update_wrap_acct_routes_1_PVT;

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

    -- update first

if ( p_route_ids_tbl.count <> 0 ) then
  FOR i IN p_route_ids_tbl.FIRST..p_route_ids_tbl.LAST LOOP

        iem_route_pvt.update_account_routes (p_api_version_number =>p_api_version_number,
                             p_init_msg_list => FND_API.G_FALSE,
                             p_commit => FND_API.G_TRUE,


                             p_route_id =>  p_route_ids_tbl(i),
                             p_email_account_id => p_email_account_id,
                             p_destination_grp_id => p_upd_dest_ids_tbl(i),
                             p_default_grp_id =>p_upd_default_ids_tbl(i),
                             p_enabled_flag =>  p_upd_enable_flag_tbl(i),


                               x_return_status =>l_return_status,
                              x_msg_count   => l_msg_count,
                              x_msg_data => l_msg_data);

        if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then

            raise IEM_ACCOUNT_ROUTE_NOT_UPDATED;
        end if;
    END LOOP;
end if;

SAVEPOINT		update_wrap_acct_routes_2_PVT;

if ( p_route_ids_tbl.count <> 0 ) then

   -- FOR i IN p_route_ids_tbl.FIRST..p_route_ids_tbl.LAST LOOP
        iem_route_pvt.delete_acct_route_batch
             (p_api_version_number   =>  p_api_version_number,
              P_init_msg_list   => FND_API.G_FALSE,

              p_commit       => FND_API.G_TRUE,
              p_route_ids_tbl =>  p_delete_route_ids_tbl,
              p_account_id => p_email_account_id,
              x_return_status =>  l_return_status,
              x_msg_count   =>   l_msg_count,
              x_msg_data    =>    l_msg_data) ;
        if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
            raise IEM_ACCOUNT_ROUTE_NOT_DELETED;
        end if;

  --  END LOOP;
end if;
--	dbms_output.put_line('route_id : ' || p_route_id);

--	dbms_output.put_line('Destination_group_id: ' || p_email_account_id);




--dbms_output.put_line('after insert : ');
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

    WHEN IEM_ACCOUNT_ROUTE_NOT_UPDATED THEN
      	   ROLLBACK TO update_wrap_acct_routes_1_PVT;
           FND_MESSAGE.SET_NAME('IEM','IEM_ACCOUNT_ROUTE_NOT_UPDATED');
           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR ;

          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN IEM_ACCOUNT_ROUTE_NOT_DELETED THEN
      	   ROLLBACK TO update_wrap_acct_routes_2_PVT;
           FND_MESSAGE.SET_NAME('IEM','IEM_ACCOUNT_ROUTE_NOT_DELETED');
           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO update_wrap_acct_routes_2_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data


			);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO update_wrap_acct_routes_2_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);

   WHEN OTHERS THEN
	ROLLBACK TO update_wrap_acct_routes_2_PVT;
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



 END	update_wrap_account_routes;
   -- Enter further code below as specified in the Package spec.

END IEM_ROUTE_PVT; -- Package Body IEM_ROUTE_PVT

/
