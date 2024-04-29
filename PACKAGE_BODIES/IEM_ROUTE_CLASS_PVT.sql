--------------------------------------------------------
--  DDL for Package Body IEM_ROUTE_CLASS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_ROUTE_CLASS_PVT" AS
/* $Header: iemvclxb.pls 120.4 2006/06/19 14:33:40 pkesani ship $ */
--
--
-- Purpose: Mantain route classification related operations
--
-- MODIFICATION HISTORY
-- Person      Date         Comments
--  Liang Xia   5/27/2001    added functions
--  Liang Xia   6/20/2001    added creating folder on OES when association between email account and classifcation is created
--  Liang Xia   11/2/2001    Fixed bug 2086532
--  Liang Xia   12/21/2001   Fixed bug 2160160
--  Mina Tang   01/17/2002   Added TNS No Listener Exception to delete_folder()
--  Liang Xia   01/28/2002   Fixed bug 2193385
--  Liang Xia   03/25/2002   Fixed Bug 2279835, 2279824
--  KBeagle     07/10/2002   Fix for bug 2456742
--  Liang Xia   11/11/2002   Added functions for dynamic classifications (shipped MP-Q)
--  Kris Beagle 12/17/2002   Fix for bug 2713006 ICFP-Q:F: ERROR HANDLING: OES LISTENER IS DOWN, ASSOCIATE CLASSIFICATION W/ ACCT.
--  Kris Beagle 01/11/2005   Updated for 11i compliance
--  Mina Tang	07/26/2005   Implemented soft-delete for R12
--  PKESANI     02/16/2006   Removed the where clause "and active_flag='Y'" for bug fix of 4945889
--                           The change would allow add/delete operations on inactive accounts.
--                           For Bug 4945916 - Corrected the Save point from
--                           update_account_class to update_account_class_PVT.
--  PKESANI     05/23/2006   Changed the code to get the count of emails with
--                           the classification, that is to be deleted.
--                           changed it from iem_post_mdts to iem_rt_proc_emails table.
-- ---------   ------  ------------------------------------------
   -- Enter procedure, function bodies as shown below
G_PKG_NAME CONSTANT varchar2(30) :='IEM_ROUTE_CLASS_PVT ';

G_CLASS_ID varchar2(30) ;

G_created_updated_by   NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('USER_ID')) ;

G_LAST_UPDATE_LOGIN    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('LOGIN_ ID') ) ;

TYPE t_AcctIdTable  is TABLE of iem_account_route_class.email_account_id%TYPE INDEX BY BINARY_INTEGER;


  PROCEDURE getRouteClassifications(
                p_api_version_number        IN  NUMBER,
                P_init_msg_list             IN  VARCHAR2 := null,
                p_commit                    IN  VARCHAR2 := null,

                emailAccountId              IN  NUMBER,
                routeClassifications        OUT NOCOPY t_routeClassification,
                numberOfClassifications     OUT NOCOPY NUMBER,
                x_return_status             OUT NOCOPY VARCHAR2,
                x_msg_count                 OUT NOCOPY NUMBER,
                x_msg_data                  OUT NOCOPY VARCHAR2)
    IS
        i       INTEGER;
        l_api_name		varchar2(30):='getRouteClassifications';
        l_api_version_number number:=1.0;

   BEGIN

    --Standard Savepoint

    SAVEPOINT getRouteClassifications;

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

    routeClassifications(1) := 'Gold';

    routeClassifications(2):= 'Silver';
    routeClassifications(3) := 'Bronze';


    numberOfClassifications := 3;


    EXCEPTION

        WHEN FND_API.G_EXC_ERROR THEN
	        ROLLBACK TO getRouteClassifications;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get

			( p_count => x_msg_count,p_data => x_msg_data);

       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    	   ROLLBACK TO getRouteClassifications;
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;


           FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,p_data => x_msg_data);

       WHEN OTHERS THEN
    	  ROLLBACK TO getRouteClassifications;
          x_return_status := FND_API.G_RET_STS_ERROR;
    	  IF 	FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN

            		FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);
          END IF;
    	  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count	,p_data	=> x_msg_data);
    END;


 PROCEDURE delete_item_batch
             (p_api_version_number      IN  NUMBER,
              P_init_msg_list           IN  VARCHAR2 := null,
              p_commit                  IN  VARCHAR2 := null,
              p_class_ids_tbl           IN  jtf_varchar2_Table_100,
              x_return_status           OUT NOCOPY VARCHAR2,
              x_msg_count               OUT NOCOPY NUMBER,
              x_msg_data                OUT NOCOPY VARCHAR2)
IS
    i                       INTEGER;
    l_api_name		        varchar2(30):='delete_item_batch';

    l_api_version_number    number:=1.0;
    l_count                 NUMBER;
    l_return_status         varchar(10);
    l_data                  varchar2(255);
    v_AcctIdTable           t_AcctIdTable;

    l_undeleted_class_name_1    varchar2(30);

    l_undeleted_class_name      varchar2(3000);

    l_count_msg_postmdt     number := 0;

    logMessage              varchar2(200);

    CURSOR  acct_id_cursor( l_classification_id IN NUMBER )  IS
        select unique email_account_id from iem_account_route_class where route_classification_id = l_classification_id;


     IEM_RT_CLASS_NOT_DELETED     EXCEPTION;
    --IEM_UNEXPT_ERR_DELETE_FOLDER EXCEPTION;
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

   if ( p_class_ids_tbl.count <> 0 ) then

     FOR i IN p_class_ids_tbl.FIRST..p_class_ids_tbl.LAST LOOP

        -- Commented out from R12
	-- select count(*) into l_count_msg_postmdt from iem_post_mdts where rt_classification_id=p_class_ids_tbl(i);

	select count(*) into l_count_msg_postmdt from iem_rt_proc_emails where rt_classification_id=p_class_ids_tbl(i);

        if l_count_msg_postmdt <> 0 then
              select name into l_undeleted_class_name_1 from iem_route_classifications where route_classification_id=p_class_ids_tbl(i);
              l_undeleted_class_name := l_undeleted_class_name||l_undeleted_class_name_1||', ';
        else

          --First delete classification folder for all the email account that assoicated with this classification
          --iem_route_class_pvt.delete_folder_on_classId(p_api_version_number =>p_api_version_number,
          --                      p_init_msg_list => p_init_msg_list,
          --                      p_commit => p_init_msg_list,
          --                      p_classification_id =>p_class_ids_tbl(i),
          --                      x_return_status =>l_return_status,
          --                      x_msg_count   => l_count,
          --                      x_msg_data => l_data);


          --if (l_return_status = FND_API.G_RET_STS_ERROR) then

          --    select name into l_undeleted_class_name_1 from iem_route_classifications where route_classification_id=p_class_ids_tbl(i);

           --   l_undeleted_class_name := l_undeleted_class_name||l_undeleted_class_name_1||', ';

          --elsif (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
          --    raise IEM_UNEXPT_ERR_DELETE_FOLDER;

          --else
                -- then update priority in iem_account_route_class before deleting an account_route
                FOR acct_id IN acct_id_cursor(p_class_ids_tbl(i))  LOOP
                    /*
                    if fnd_log.test(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_ROUTE_PUB.ROUTE.START') then

                        logMessage := '[account id ' || to_char(i)||'is
                        : ' || to_char(acct_id.email_account_id) || ']';

                        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_ROUTE_CLASS_PVT.delete_item_batch.START', logMessage);
                    end if;
                    */
                    Update iem_account_route_class ac set ac.priority=ac.priority-1
        					           where ac.email_account_id=acct_id.email_account_id and ac.priority > (Select be.priority from iem_account_route_class be
        					           where be.route_classification_id=p_class_ids_tbl(i) and be.email_account_id = acct_id.email_account_id);
                    commit;
                END LOOP;

                --finially delete from IEM_ROUTE_CLASSIFICATIONS, IEM_ACCOUNT_ROUTE_CLASS and IEM_ROUTE_CLASSIFICATIONS
                UPDATE IEM_ROUTE_CLASSIFICATIONS
		SET DELETED_FLAG='Y'
                WHERE route_classification_id = p_class_ids_tbl(i);

                DELETE
                FROM IEM_ROUTE_CLASS_RULES
                WHERE route_classification_id = p_class_ids_tbl(i);

                DELETE
                FROM IEM_ACCOUNT_ROUTE_CLASS
                WHERE route_classification_id = p_class_ids_tbl(i);
                commit;

          --end if;

        end if;

     END LOOP;

   end if;

    --add names of un_deleted classifications into message
    if l_undeleted_class_name is not null  then
        l_undeleted_class_name := RTRIM(l_undeleted_class_name, ', ');
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('IEM', 'IEM_RT_CLASS_FAILED_DEL_CLASS');
        FND_MESSAGE.SET_TOKEN('CLASSIFICATION', l_undeleted_class_name);
        FND_MSG_PUB.ADD;
    end if;


    --Standard check of p_commit
    IF FND_API.to_Boolean(p_commit) THEN
        COMMIT WORK;
    END IF;

    FND_MSG_PUB.Count_And_Get
    			( p_count => x_msg_count,
                  p_data  =>  x_msg_data
    			);



EXCEPTION

   --WHEN IEM_UNEXPT_ERR_DELETE_FOLDER THEN
   --     ROLLBACK TO delete_item_batch;
   --     x_return_status := FND_API.G_RET_STS_ERROR;
        --FND_MESSAGE.SET_NAME('IEM', 'IEM_UNEXPT_ERR_DELETE_FOLDER');
        --FND_MSG_PUB.ADD;
   --     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);


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

                p_class_name                IN   VARCHAR2,
     	        p_class_description         IN   VARCHAR2:= null,
                p_class_boolean_type_code   IN   VARCHAR2,
                p_proc_name                 IN   VARCHAR2 := null,

                p_rule_key_typecode_tbl     IN  jtf_varchar2_Table_100,
                p_rule_operator_typecode_tbl IN  jtf_varchar2_Table_100,
                p_rule_value_tbl            IN  jtf_varchar2_Table_300,

                x_return_status             OUT NOCOPY VARCHAR2,
                x_msg_count                 OUT NOCOPY NUMBER,
                x_msg_data                  OUT NOCOPY VARCHAR2 ) is

  l_api_name            VARCHAR2(255):='create_item_wrap';

  l_api_version_number  NUMBER:=1.0;

  l_class_id            IEM_ROUTE_CLASSIFICATIONS.ROUTE_CLASSIFICATION_ID%TYPE;
  l_class_rule_id       IEM_ROUTE_CLASS_RULES.ROUTE_CLASS_RULE_ID%TYPE;
  l_return_type         VARCHAR2(30);

  l_userid    		    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('USER_ID')) ;
  l_login    		    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('LOGIN_ID')) ;

  l_return_status       VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
  l_msg_count           NUMBER := 0;

  l_msg_data            VARCHAR2(2000);


  IEM_RT_CLASS_NOT_CREATED EXCEPTION;
  IEM_RT_CLASS_RULE_NOT_CREATED EXCEPTION;

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
    --API Body
    /*
    FND_LOG_REPOSITORY.init(null,null);

    if fnd_log.test(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_ROUTE_CLASS_PVT.CREATE_ITEM_WRAP.START') then
        logMessage := '[create item is called!]';
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_ROUTE_CLASS_PVT.CREATE_ITEM_WRAP.START', logMessage);
    end if;
    */
    --Now call the create_item() to create the acccount
    if ( p_class_boolean_type_code = 'DYNAMIC' ) then
        l_return_type := p_rule_key_typecode_tbl(1);
    else
        l_return_type := FND_API.G_MISS_CHAR;
    end if;

    --Now call the create_item() to create the acccount
      iem_route_class_pvt.create_item_class (

                  p_api_version_number=>p_api_version_number,
                  p_init_msg_list  => p_init_msg_list,
      		      p_commit	   => p_commit,
  				  p_name => p_class_name,
  				  p_description	=> p_class_description,
  				  p_boolean_type_code	=>p_class_boolean_type_code,
                  p_proc_name  => p_proc_name,
                  p_return_type => l_return_type,
                  x_return_status =>l_return_status,
                  x_msg_count   => l_msg_count,

                  x_msg_data => l_msg_data);

   if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
        raise IEM_RT_CLASS_NOT_CREATED;

   end if;



   --Getting the newly created email account id
   l_class_id := G_CLASS_ID;

   --dbms_output.put_line('route id :  '||l_route_id);

   FOR i IN p_rule_key_typecode_tbl.FIRST..p_rule_operator_typecode_tbl.LAST loop


        iem_route_class_pvt.create_item_class_rules (
                         p_api_version_number=>p_api_version_number,
         		  	     p_init_msg_list  => p_init_msg_list,
        		    	 p_commit	   => p_commit,
          				 p_class_id => l_class_id,
          				 p_key_type_code	=> p_rule_key_typecode_tbl(i),
          				 p_operator_type_code	=> p_rule_operator_typecode_tbl(i),
                         p_value =>p_rule_value_tbl(i),
                         x_return_status =>l_return_status,
                         x_msg_count   => l_msg_count,
                         x_msg_data => l_msg_data);



        if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then

            raise IEM_RT_CLASS_RULE_NOT_CREATED;

        end if;
   end loop;

   EXCEPTION
         WHEN IEM_RT_CLASS_NOT_CREATED THEN
      	     ROLLBACK TO create_item_wrap;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

        WHEN IEM_RT_CLASS_RULE_NOT_CREATED THEN
      	     ROLLBACK TO create_item_wrap;
            FND_MESSAGE.SET_NAME('IEM','IEM_RT_CLASS_RULE_NOT_CREATED');
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

PROCEDURE create_item_class (
                 p_api_version_number  IN   NUMBER,
 		  	     p_init_msg_list       IN   VARCHAR2 := null,
		    	 p_commit              IN   VARCHAR2 := null,
            	 p_name                IN   VARCHAR2,
  				 p_description	       IN   VARCHAR2:= null,
         		 p_boolean_type_code   IN   VARCHAR2,
                 p_is_sss              IN   VARCHAR2 := null,
                 p_proc_name           IN   VARCHAR2 := null,
                 p_return_type         IN   VARCHAR2 := null,
                 x_return_status	   OUT  NOCOPY VARCHAR2,
  		  	     x_msg_count	       OUT	NOCOPY NUMBER,
	  	  	     x_msg_data	           OUT	NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='create_item_class';
	l_api_version_number 	NUMBER:=1.0;
    l_seq_id		        NUMBER;
    l_description           VARCHAR2(256);
    l_proc_name             VARCHAR2(256);
    l_return_status        VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER := 0;
    l_msg_data              VARCHAR2(2000);
    l_name_count                NUMBER;
    IEM_RT_CLASS_DUP_NAME       EXCEPTION;
    IEM_ADM_NO_PROCEDURE_NAME   EXCEPTION;
    l_IEM_INVALID_PROCEDURE     EXCEPTION;
BEGIN
  -- Standard Start of API savepoint

  SAVEPOINT		create_item_class_PVT;


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
    select count(*) into l_name_count from iem_route_classifications where UPPER(name) = UPPER(p_name) and deleted_flag='N';

    if l_name_count > 0 then
      raise IEM_RT_CLASS_DUP_NAME;
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

    IF FND_API.To_Boolean( p_is_sss ) THEN
         G_CLASS_ID := 0;
    ELSE
        --get next sequential number for route_id
       	SELECT IEM_ROUTE_CLASSIFICATIONS_s1.nextval
    	INTO l_seq_id
    	FROM dual;

        G_CLASS_ID := l_seq_id;
    END IF;

	INSERT INTO IEM_ROUTE_CLASSIFICATIONS
	(
	ROUTE_CLASSIFICATION_ID,
	NAME,
	DESCRIPTION,
	BOOLEAN_TYPE_CODE,
    procedure_name,
    deleted_flag,
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
	G_CLASS_ID,
	p_name,
	l_description,
	p_boolean_type_code,
    l_proc_name,
    'N',
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
	 ROLLBACK TO create_item_class_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN IEM_RT_CLASS_DUP_NAME THEN
	   ROLLBACK TO create_item_class_PVT;
     FND_MESSAGE.SET_NAME('IEM','IEM_RT_CLASS_DUP_NAME');
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
	ROLLBACK TO create_item_class_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;

       FND_MSG_PUB.Count_And_Get


			( p_count => x_msg_count,
              p_data  => x_msg_data
			);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   ROLLBACK TO create_item_class_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
              p_data  =>      x_msg_data
			);




   WHEN OTHERS THEN
	ROLLBACK TO create_item_class_PVT;
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

 END	create_item_class;

PROCEDURE create_item_class_rules (
                 p_api_version_number    IN   NUMBER,
 		  	     p_init_msg_list  IN   VARCHAR2 := null,
		    	 p_commit	    IN   VARCHAR2 := null,

  				 p_class_id IN   NUMBER,
  				 p_key_type_code	IN   VARCHAR2,
  				 p_operator_type_code	IN   VARCHAR2,
                 p_value IN VARCHAR2,

                 x_return_status	OUT NOCOPY VARCHAR2,
  		  	     x_msg_count	    OUT	NOCOPY NUMBER,
	  	  	     x_msg_data	        OUT	NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='create_item_route_rules';
	l_api_version_number 	NUMBER:=1.0;
	l_seq_id		number;


   --IEM_INVALID_DATE_FORMAT EXCEPTION;

BEGIN

  -- Standard Start of API savepoint
  SAVEPOINT		create_item_class_rules_PVT;

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



   	SELECT IEM_ROUTE_CLASS_RULES_s1.nextval
	INTO l_seq_id
	FROM dual;




	INSERT INTO IEM_ROUTE_CLASS_RULES
	(
	ROUTE_CLASS_RULE_ID,
	ROUTE_CLASSIFICATION_ID,
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

	p_class_id,
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
	       ROLLBACK TO create_item_class_rules_PVT;
            x_return_status := FND_API.G_RET_STS_ERROR ;


            FND_MSG_PUB.Count_And_Get

			(    p_count => x_msg_count,
            	 p_data  =>      x_msg_data
			);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	       ROLLBACK TO create_item_class_rules_PVT;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            FND_MSG_PUB.Count_And_Get
			(    p_count => x_msg_count,
              	 p_data  =>      x_msg_data
			);




   WHEN OTHERS THEN
	       ROLLBACK TO create_item_class_rules_PVT;
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
 END	create_item_class_rules;


--update iem_routes, update iem_route_rules, insert iem_route_rules
PROCEDURE update_item_wrap (p_api_version_number    IN   NUMBER,
 	                         p_init_msg_list        IN   VARCHAR2 := null,
	                         p_commit	            IN   VARCHAR2 := null,
	                         p_class_id             IN   NUMBER ,
  	                         p_name                 IN   VARCHAR2:= null,
  	                         p_ruling_chain	        IN   VARCHAR2:= null,
                             p_description          IN   VARCHAR2:= null,
                             p_procedure_name       IN   VARCHAR2:= null,
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
    l_proc_name             VARCHAR2(256);
    l_return_type           VARCHAR2(30);
    IEM_NO_RT_CLASS_UPDATE      EXCEPTION;
    IEM_NO_RULE_UPDATE          EXCEPTION;
    IEM_RULE_NOT_DELETED        EXCEPTION;

    IEM_RT_CLS_RULE_NOT_CREATED  EXCEPTION;
    IEM_RT_CLS_NO_RULE          EXCEPTION;
    l_class                 NUMBER;
    l_rule_count            NUMBER;

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
  select count(*) into l_class from iem_route_classifications where route_classification_id = p_class_id;


  if l_class < 1 then
    raise IEM_NO_RT_CLASS_UPDATE;
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
    iem_route_class_pvt.update_item_class(
                                p_api_version_number => l_api_version_number,
                    	  	    p_init_msg_list => FND_API.G_FALSE,
   	                            p_commit => FND_API.G_FALSE,
			                    p_class_id => p_class_id,
  			                    p_description	=>p_description,
  			                    p_ruling_chain	=>p_ruling_chain,
                                p_proc_name => l_proc_name,
                                p_return_type => l_return_type,
                               x_return_status => l_return_status,
                               x_msg_count => l_msg_count,
                               x_msg_data => l_msg_data);

   if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
    raise IEM_NO_RT_CLASS_UPDATE;
   end if;



  --update iem_route_rules table

  if ( p_update_rule_ids_tbl.count <>0 ) then

   FOR i IN p_update_rule_ids_tbl.FIRST..p_update_rule_ids_tbl.LAST   loop
      iem_route_class_pvt.update_item_rule(p_api_version_number => l_api_version_number,
                      	  	    p_init_msg_list => FND_API.G_FALSE,
	                            p_commit => FND_API.G_FALSE,


  			                   p_route_class_rule_id => p_update_rule_ids_tbl(i),
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
        FROM IEM_ROUTE_CLASS_RULES
        WHERE route_class_rule_id = p_remove_rule_ids_tbl(i);



    if SQL%NOTFOUND then

        raise IEM_RULE_NOT_DELETED;

    end if;
end if;

 if ( p_new_rule_keys_tbl.count <> 0 ) then
    FOR i IN p_new_rule_keys_tbl.FIRST..p_new_rule_keys_tbl.LAST LOOP
         iem_route_class_pvt.create_item_class_rules (p_api_version_number=>p_api_version_number,
                                 		  	     p_init_msg_list  => p_init_msg_list,
                                		    	 p_commit	   => p_commit,
                                  				 p_class_id => p_class_id,
                                  				 p_key_type_code	=> p_new_rule_keys_tbl(i),
                                  				 p_operator_type_code	=> p_new_rule_operators_tbl(i),


                                                 p_value =>p_new_rule_values_tbl(i),

                                                x_return_status =>l_return_status,
                                                x_msg_count   => l_msg_count,
                                                x_msg_data => l_msg_data);

        if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
            raise IEM_RT_CLS_RULE_NOT_CREATED;
        end if;
     END LOOP;
  end if;


     -- check if exist at least one rule for each route
     select count(*) into l_rule_count from iem_route_class_rules where route_classification_id = p_class_id;



       if l_rule_count < 1 then
          raise IEM_RT_CLS_NO_RULE;
       end if;

  -- Standard Check Of p_commit.
    IF FND_API.To_Boolean(p_commit) THEN
  		COMMIT WORK;
    END IF;


    EXCEPTION
        WHEN IEM_NO_RT_CLASS_UPDATE THEN
      	   ROLLBACK TO update_item_wrap;


           FND_MESSAGE.SET_NAME('IEM','IEM_NO_RT_CLASS_UPDATE');
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


        WHEN IEM_RT_CLS_RULE_NOT_CREATED THEN
      	   ROLLBACK TO update_item_wrap;
           FND_MESSAGE.SET_NAME('IEM','IEM_RT_CLS_RULE_NOT_CREATED');
           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR ;

          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);


         WHEN IEM_RT_CLS_NO_RULE THEN
      	   ROLLBACK TO update_item_wrap;
           FND_MESSAGE.SET_NAME('IEM','IEM_RT_CLS_NO_RULE');

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

PROCEDURE update_item_class (
                 p_api_version_number   IN   NUMBER,
    	  	     p_init_msg_list        IN   VARCHAR2 := null,
    	    	 p_commit	            IN   VARCHAR2 := null,
    			 p_class_id             IN   NUMBER ,
                 p_proc_name	        IN   VARCHAR2:= null,
                 p_return_type          IN   VARCHAR2:= null,
    			 p_description	        IN   VARCHAR2:= null,
    			 p_ruling_chain	        IN   VARCHAR2:= null,
			     x_return_status	    OUT	NOCOPY VARCHAR2,
  		  	     x_msg_count	        OUT NOCOPY NUMBER,
	  	  	     x_msg_data	            OUT	NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='update_item_class';
	l_api_version_number 	NUMBER:=1.0;
    l_return_status         VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER := 0;
    l_msg_data              VARCHAR2(2000);
    l_proc_name             VARCHAR2(256);
    l_name_count            NUMBER;
    l_description           VARCHAR2(256);
    l_ruling_chain          VARCHAR2(30);
    IEM_RT_CLASS_DUP_NAME    EXCEPTION;
    l_IEM_INVALID_PROCEDURE  EXCEPTION;
    IEM_ADMIN_ROUTE_NO_PROC  EXCEPTION;

BEGIN
  -- Standard Start of API savepoint

  SAVEPOINT		update_item_class;

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
   /* select count(*) into l_name_count from iem_route_classifications where UPPER(name) = UPPER(p_name) and route_classification_id <> p_class_id;



    if l_name_count > 0 then
      raise IEM_RT_CLASS_DUP_NAME;
    end if;
*/

    if p_ruling_chain = 'DYNAMIC' then
        if ( p_proc_name = FND_API.G_MISS_CHAR ) then
            raise IEM_ADMIN_ROUTE_NO_PROC;
        elsif ( p_proc_name is null ) then
            raise IEM_ADMIN_ROUTE_NO_PROC;
          -- l_proc_name := FND_API.G_MISS_CHAR;
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

    if ( p_description = FND_API.G_MISS_CHAR ) then
        l_description := null;
    --elsif ( p_description is null )then
    --   l_description := FND_API.G_MISS_CHAR;
    else
        l_description := ltrim(rtrim(p_description));
    end if;

    if ( p_ruling_chain = FND_API.G_MISS_CHAR ) then
        l_ruling_chain := null;
    --elsif ( p_ruling_chain is null )then
    --    l_ruling_chain := FND_API.G_MISS_CHAR;
    else
        l_ruling_chain := ltrim(rtrim(p_ruling_chain));
    end if;

	update IEM_ROUTE_CLASSIFICATIONS
	set
	       description=decode(l_description,FND_API.G_MISS_CHAR,description,l_description),
	       boolean_type_code=decode(l_ruling_chain,FND_API.G_MISS_CHAR,boolean_type_code,l_ruling_chain),
           procedure_name=decode(l_proc_name,FND_API.G_MISS_CHAR,procedure_name,l_proc_name),
           LAST_UPDATED_BY = decode(G_created_updated_by,null,-1,G_created_updated_by),
           LAST_UPDATE_DATE = sysdate,
           LAST_UPDATE_LOGIN = decode(G_LAST_UPDATE_LOGIN,null,-1,G_LAST_UPDATE_LOGIN)
	where route_classification_id=p_class_id;

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
	 ROLLBACK TO update_item_class;
     x_return_status := FND_API.G_RET_STS_ERROR ;
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN IEM_ADMIN_ROUTE_NO_PROC THEN
	   ROLLBACK TO update_item_class;
        FND_MESSAGE.SET_NAME('IEM','IEM_ADMIN_ROUTE_NO_PROC');
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN IEM_RT_CLASS_DUP_NAME THEN
	   ROLLBACK TO update_item_class;
        FND_MESSAGE.SET_NAME('IEM','IEM_RT_CLASS_DUP_NAME');
        FND_MSG_PUB.Add;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);



   WHEN FND_API.G_EXC_ERROR THEN
	   ROLLBACK TO update_item_class;

       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
               	p_data  =>      x_msg_data
			);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   ROLLBACK TO update_item_class;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get

			( p_count => x_msg_count,

            	p_data  =>      x_msg_data

			);

   WHEN OTHERS THEN
	ROLLBACK TO update_item_class;
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

END	update_item_class;



PROCEDURE update_item_rule (p_api_version_number    IN   NUMBER,
     	  	     p_init_msg_list  IN   VARCHAR2 := null,
    	    	 p_commit	    IN   VARCHAR2 := null,

                 p_route_class_rule_id IN NUMBER ,
      			 p_key_type_code IN   VARCHAR2:= null,
      			 p_operator_type_code	IN   VARCHAR2:=null,
      			 p_value	IN   VARCHAR2:=null,

			      x_return_status	OUT	NOCOPY VARCHAR2,
  		  	      x_msg_count	    OUT NOCOPY NUMBER,
	  	  	      x_msg_data	    OUT	NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='update_item_rule';
	l_api_version_number 	NUMBER:=1.0;

     l_rule                 NUMBER;

     IEM_NO_RULE_UPDATE     EXCEPTION;
     IEM_RULE_KEY_OP_VAL_NULL EXCEPTION;
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

  select count(*) into l_rule from iem_route_class_rules
  where route_class_rule_id = p_route_class_rule_id;

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
       raise IEM_RULE_KEY_OP_VAL_NULL;

   elsif ( p_operator_type_code = FND_API.G_MISS_CHAR ) then
       raise IEM_RULE_KEY_OP_VAL_NULL;

   elsif ( p_value = FND_API.G_MISS_CHAR ) then
       raise IEM_RULE_KEY_OP_VAL_NULL;
   end if;

    update IEM_ROUTE_CLASS_RULES
	set

           key_type_code=decode(p_key_type_code,null,key_type_code,p_key_type_code),
	       operator_type_code=decode(p_operator_type_code,null,operator_type_code,p_operator_type_code),
	       value=decode(p_value,null,value,p_value),
           LAST_UPDATED_BY = decode(G_created_updated_by,null,-1,G_created_updated_by),
           LAST_UPDATE_DATE = sysdate,

           LAST_UPDATE_LOGIN = decode(G_LAST_UPDATE_LOGIN,null,-1,G_LAST_UPDATE_LOGIN)
	where route_class_rule_id=p_route_class_rule_id;


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
    WHEN IEM_RULE_KEY_OP_VAL_NULL THEN
    	   ROLLBACK TO update_item_rule;
       FND_MESSAGE.SET_NAME('IEM','IEM_RULE_KEY_OP_VAL_NULL');
       FND_MSG_PUB.Add;
       x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

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



PROCEDURE create_wrap_acct_rt_class (
                     p_api_version_number    IN   NUMBER,
        		  	 p_init_msg_list     IN   VARCHAR2 := null,
        		     p_commit	       IN   VARCHAR2 := null,
                     p_email_account_id IN NUMBER,

      				 p_class_id IN   NUMBER,
                     p_enabled_flag IN VARCHAR2,
                     p_priority IN NUMBER,

                     x_return_status	OUT NOCOPY VARCHAR2,
      		  	     x_msg_count	    OUT NOCOPY NUMBER,
    	  	  	     x_msg_data	        OUT	NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='create_item_account_routes';

	l_api_version_number 	NUMBER:=1.0;


    l_class         number;

    l_account       number;

    l_return_status         VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER := 0;
    l_msg_data              VARCHAR2(2000);
    l_class_name            VARCHAR(30);
    l_class_name1            VARCHAR(31);


    IEM_RT_CLASS_NO_DATA      EXCEPTION;
    IEM_ADMIN_ACCOUNT_NOT_EXIST    EXCEPTION;
    IEM_RT_ClASS_ACCT_NOT_UPDATED   EXCEPTION;
    IEM_RT_ClASS_FAIL_CREAT_FOLDER  EXCEPTION;


BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT		create_wrap_acct_rt_class_PVT;

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
    select count(*) into l_class from iem_route_classifications

        where route_classification_id = p_class_id;

    if l_class < 1 then
        raise IEM_RT_CLASS_NO_DATA;
    end if;


    -- ***** Changed from iem_email_accounts ==> iem_mstemail_accounts for 11i compliance *****
    -- check if the account_id exist in iem_mstemail_accounts
    -- removed the where clause "and active_flag='Y'" for bug fix of 4945889
    select count(*) into l_account from iem_mstemail_accounts
        where email_account_id = p_email_account_id  and deleted_flag='N';

    if l_account < 1 then
        raise IEM_ADMIN_ACCOUNT_NOT_EXIST;

    end if;


    iem_route_class_pvt.create_item_account_class(

                              p_api_version_number =>p_api_version_number,
                              p_init_msg_list => p_init_msg_list,

                              p_commit => FND_API.G_FALSE,
                              p_class_id =>p_class_id,
                              p_email_account_id =>p_email_account_id,
                              p_enabled_flag => p_enabled_flag,
                              p_priority => p_priority,


                              x_return_status =>l_return_status,
                              x_msg_count   => l_msg_count,

                              x_msg_data => l_msg_data);

  if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
          raise IEM_RT_ClASS_ACCT_NOT_UPDATED;
  end if;

  select name into l_class_name from iem_route_classifications where route_classification_id = p_class_id;

  if ( l_class_name is null ) then
    l_class_name1 := null;

  else
    l_class_name1 := '/'||l_class_name;

  end if;

  -- ***** Remove for 11i compliance *****
  --iem_route_class_pvt.create_folder(p_api_version_number =>p_api_version_number,
  --                            p_init_msg_list => p_init_msg_list,
  --                            p_commit => FND_API.G_FALSE,
  --                            p_email_account_id =>p_email_account_id,
  --                            p_classification_name => l_class_name1,
  --                            x_return_status =>l_return_status,
  --                            x_msg_count   => l_msg_count,
  --                            x_msg_data => l_msg_data);
  -- if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then

  --      raise IEM_RT_ClASS_FAIL_CREAT_FOLDER;

  --  end if;

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
    WHEN IEM_RT_ClASS_FAIL_CREAT_FOLDER THEN
      	   ROLLBACK TO create_wrap_acct_rt_class_PVT;
           --FND_MESSAGE.SET_NAME('IEM','IEM_RT_ClASS_FAIL_CREAT_FOLDER');
           --FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN IEM_RT_CLASS_NO_DATA THEN
      	   ROLLBACK TO create_wrap_acct_rt_class_PVT;
           FND_MESSAGE.SET_NAME('IEM','IEM_RT_CLASS_NO_DATA');


           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN IEM_ADMIN_ACCOUNT_NOT_EXIST THEN
      	   ROLLBACK TO create_wrap_acct_rt_class_PVT;
           FND_MESSAGE.SET_NAME('IEM','IEM_ADMIN_ACCOUNT_NOT_EXIST');
           FND_MSG_PUB.Add;

           x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);


    WHEN IEM_RT_ClASS_ACCT_NOT_UPDATED THEN

      	   ROLLBACK TO create_wrap_acct_rt_class_PVT;
           FND_MESSAGE.SET_NAME('IEM','IEM_RT_ClASS_ACCT_NOT_UPDATED');
           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN FND_API.G_EXC_ERROR THEN
	       ROLLBACK TO create_wrap_acct_rt_class_PVT;
            x_return_status := FND_API.G_RET_STS_ERROR ;

            FND_MSG_PUB.Count_And_Get

			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data

			);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	       ROLLBACK TO create_wrap_acct_rt_class_PVT;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);



   WHEN OTHERS THEN
	       ROLLBACK TO create_wrap_acct_rt_class_PVT;

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

 END	create_wrap_acct_rt_class;



PROCEDURE create_item_account_class (
                 p_api_version_number     IN NUMBER,

 		  	     p_init_msg_list          IN VARCHAR2 := NULL,
		    	 p_commit	              IN VARCHAR2 := NULL,
                 p_email_account_id       IN NUMBER,
  				 p_class_id               IN NUMBER,


                 p_enabled_flag           IN VARCHAR2,
                 p_priority               IN NUMBER,
                 x_return_status	      OUT NOCOPY VARCHAR2,
  		  	     x_msg_count	          OUT NOCOPY NUMBER,
	  	  	     x_msg_data	              OUT NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='create_item_account_class';

	l_api_version_number 	NUMBER:=1.0;
    l_seq_id        number;

BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT		create_item_acct_class_PVT;



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
	SELECT IEM_ACCOUNT_ROUTE_CLASS_s1.nextval
	INTO l_seq_id
	FROM dual;

	INSERT INTO IEM_ACCOUNT_ROUTE_CLASS

	(
	ROUTE_CLASSIFICATION_ID,

	EMAIL_ACCOUNT_ID,

    ACCOUNT_ROUTE_CLASS_ID,
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
   p_class_id,
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
	ROLLBACK TO create_item_acct_class_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
            	p_data  =>      x_msg_data
			);


   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO create_item_acct_class_PVT;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get

			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);

   WHEN OTHERS THEN
	ROLLBACK TO create_item_acct_class_PVT;
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

 END	create_item_account_class;




-- to update and delete new tuples in iem_account_routes

PROCEDURE update_wrap_account_class (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 := null,
		    	  p_commit	    IN   VARCHAR2 := null,

                 p_email_account_id IN NUMBER,
  				 p_class_ids_tbl IN  jtf_varchar2_Table_100,
                 p_upd_enable_flag_tbl IN  jtf_varchar2_Table_100,
                 --p_upd_priority_tbl IN  jtf_varchar2_Table_100,

                 p_delete_class_ids_tbl IN  jtf_varchar2_Table_100,

                 x_return_status	OUT NOCOPY VARCHAR2,
  		  	     x_msg_count	    OUT NOCOPY NUMBER,
	  	  	     x_msg_data	        OUT	NOCOPY VARCHAR2

			 ) is
	l_api_name        		VARCHAR2(255):='update_wrap_account_class';
	l_api_version_number 	NUMBER:=1.0;

    l_return_status         VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER := 0;
    l_msg_data              VARCHAR2(2000);

    MY_EXCEPTION EXCEPTION;

    IEM_ACCOUNT_CLASS_NOT_DELETED  EXCEPTION;
    IEM_RT_CLASS_ACCT_NOT_UPDATE   EXCEPTION;
BEGIN
-- Standard Start of API savepoint
SAVEPOINT		update_wrap_acct_class_1_PVT;
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
 if ( p_class_ids_tbl.count <> 0 ) then
  FOR i IN p_class_ids_tbl.FIRST..p_class_ids_tbl.LAST LOOP
        iem_route_class_pvt.update_account_class (p_api_version_number =>p_api_version_number,
                             p_init_msg_list => p_init_msg_list,

                             p_commit => FND_API.G_TRUE,

                             p_class_id =>  p_class_ids_tbl(i),
                             p_email_account_id => p_email_account_id,
                             p_enabled_flag =>  p_upd_enable_flag_tbl(i),
                             --p_priority => p_upd_priority_tbl(i),

                              x_return_status =>l_return_status,
                              x_msg_count   => l_msg_count,

                              x_msg_data => l_msg_data);
        if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
            raise IEM_RT_CLASS_ACCT_NOT_UPDATE;

        end if;
    END LOOP;
end if;

--SAVEPOINT		update_wrap_acct_class_2_PVT;

if ( p_delete_class_ids_tbl.count <> 0 ) then
        iem_route_class_pvt.delete_acct_class_batch
             (p_api_version_number   =>  p_api_version_number,
              P_init_msg_list   => p_init_msg_list,

              p_commit       => FND_API.G_TRUE,
              p_class_ids_tbl =>  p_delete_class_ids_tbl,

              p_account_id => p_email_account_id,
              x_return_status =>  l_return_status,
              x_msg_count   =>   l_msg_count,
              x_msg_data    =>    l_msg_data) ;
        if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
            raise MY_EXCEPTION;
        end if;
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
    WHEN MY_EXCEPTION THEN
            IF FND_API.To_Boolean(p_commit) THEN
		      COMMIT WORK;
            END IF;

      	   --ROLLBACK TO update_wrap_acct_class_2_PVT;
           --FND_MESSAGE.SET_NAME('IEM','MY_EXCEPTION');
           --FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN IEM_RT_CLASS_ACCT_NOT_UPDATE THEN
      	   ROLLBACK TO update_wrap_acct_class_1_PVT;
           FND_MESSAGE.SET_NAME('IEM','IEM_RT_CLASS_ACCT_NOT_UPDATE');
           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN IEM_ACCOUNT_CLASS_NOT_DELETED THEN
      	   ROLLBACK TO update_wrap_acct_class_2_PVT;


           FND_MESSAGE.SET_NAME('IEM','IEM_ACCOUNT_CLASS_NOT_DELETED');
           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO update_wrap_acct_class_1_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;

       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);



   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO update_wrap_acct_class_1_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);


   WHEN OTHERS THEN
	ROLLBACK TO update_wrap_acct_class_1_PVT;

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


 END	update_wrap_account_class;


PROCEDURE update_account_class(p_api_version_number    IN   NUMBER,
 	  	          p_init_msg_list  IN   VARCHAR2 := null,
	    	      p_commit	    IN   VARCHAR2 := null,
                  p_class_id    IN  NUMBER ,
			      p_email_account_id IN NUMBER,
  			      p_enabled_flag	IN   VARCHAR2:= null,
  			      p_priority	IN   VARCHAR2:= null,
                  x_return_status	OUT	NOCOPY VARCHAR2,
  		  	      x_msg_count	    OUT	NOCOPY NUMBER,
	  	  	      x_msg_data	    OUT	NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='update_account_class';
	l_api_version_number 	NUMBER:=1.0;
	l_class_cnt 	NUMBER;
    l_acct_cnt      NUMBER;

     l_LAST_UPDATED_BY    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('USER_ID')) ;
     l_LAST_UPDATE_DATE    DATE:=SYSDATE;
     l_LAST_UPDATE_LOGIN    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('LOGIN_ ID')) ;

IEM_RT_CLASS_NO_DATA        EXCEPTION;

IEM_ADMIN_ACCOUNT_NOT_EXIST EXCEPTION;

BEGIN
-- Standard Start of API savepoint
SAVEPOINT		update_account_class_PVT;
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
IF p_class_id <> FND_API.G_MISS_NUM THEN
	Select count(*) into l_class_cnt from iem_route_classifications
	where route_classification_id=p_class_id;

	IF l_class_cnt = 0 then
        raise IEM_RT_CLASS_NO_DATA;
	END IF;
END IF;


IF p_email_account_id <> FND_API.G_MISS_NUM THEN

    -- removed the where clause "and active_flag='Y'" for bug fix of 4945889

	Select count(*) into l_acct_cnt from iem_mstemail_accounts
	where email_account_id=p_email_account_id and deleted_flag='N' ;

	IF l_acct_cnt = 0 then
		raise IEM_ADMIN_ACCOUNT_NOT_EXIST;

	END IF;
END IF;

if ((p_email_account_id <> FND_API.G_MISS_NUM) and (p_class_id <> FND_API.G_MISS_NUM)) then

	update IEM_ACCOUNT_ROUTE_CLASS
	set
	       enabled_flag=decode(p_enabled_flag,FND_API.G_MISS_CHAR,enabled_flag,p_enabled_flag),
	       priority=decode(p_priority,null,priority,p_priority),
           LAST_UPDATED_BY = decode(G_created_updated_by,null,-1,G_created_updated_by),
           LAST_UPDATE_DATE = sysdate,
           LAST_UPDATE_LOGIN = decode(G_LAST_UPDATE_LOGIN,null,-1,G_LAST_UPDATE_LOGIN)
     where route_classification_id = p_class_id and email_account_id = p_email_account_id;


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

    WHEN IEM_RT_CLASS_NO_DATA THEN
      	   ROLLBACK TO update_account_class_PVT;

           FND_MESSAGE.SET_NAME('IEM','IEM_RT_CLASS_NO_DATA');
           FND_MSG_PUB.Add;
           x_return_status := FND_API.G_RET_STS_ERROR ;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN IEM_ADMIN_ACCOUNT_NOT_EXIST THEN
      	   ROLLBACK TO update_account_class_PVT;
           FND_MESSAGE.SET_NAME('IEM','IEM_ADMIN_ACCOUNT_NOT_EXIST');
           FND_MSG_PUB.Add;

           x_return_status := FND_API.G_RET_STS_ERROR ;

          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO update_account_class_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO update_account_class_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;


       FND_MSG_PUB.Count_And_Get

			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	ROLLBACK TO update_account_class_PVT;
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

 END	update_account_class;

PROCEDURE delete_acct_class_batch
     (p_api_version_number     IN  NUMBER,

      P_init_msg_list   IN  VARCHAR2 := null,
      p_commit          IN  VARCHAR2 := null,
      p_class_ids_tbl IN  jtf_varchar2_Table_100,

      p_account_id      IN NUMBER,
      x_return_status   OUT NOCOPY VARCHAR2,
      x_msg_count       OUT NOCOPY NUMBER,
      x_msg_data        OUT NOCOPY VARCHAR2)
IS
    i       INTEGER;
    l_api_name		varchar2(30):='delete_acct_class_batch';

    l_api_version_number number:=1.0;
    l_return_status varchar2(30);

    l_undeleted_class_name  varchar2(2000);
    l_undeleted_class_name_1 varchar2(30);

    l_count_msg_postmdt number := 0;


    IEM_ACCOUNT_CLASS_NOT_DELETED     EXCEPTION;
BEGIN

--Standard Savepoint
    SAVEPOINT delete_acct_class_batch;

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
 if ( p_class_ids_tbl.count <> 0 ) then

     FOR i IN p_class_ids_tbl.FIRST..p_class_ids_tbl.LAST LOOP
--pkesani--
--	select count(*) into l_count_msg_postmdt from iem_post_mdts where rt_classification_id=p_class_ids_tbl(i) and email_account_id = p_account_id;
	select count(*) into l_count_msg_postmdt from iem_rt_proc_emails where rt_classification_id=p_class_ids_tbl(i) and email_account_id = p_account_id;

	if l_count_msg_postmdt <> 0 then
              select name into l_undeleted_class_name_1 from iem_route_classifications where route_classification_id=p_class_ids_tbl(i);
              l_undeleted_class_name := l_undeleted_class_name||l_undeleted_class_name_1||', ';
        else

          -- ***** Removed for 11i compliance *****
          --delete the classification folder in OES first
          --iem_route_class_pvt.delete_folder(p_api_version_number =>p_api_version_number,
          --                      p_init_msg_list => p_init_msg_list,
          --                      p_commit => FND_API.G_FALSE,
          --                      p_email_account_id =>p_account_id,
          --                      p_class_id => p_class_ids_tbl(i),
          --                      x_return_status =>l_return_status,
          --                      x_msg_count   => x_msg_count,
          --                      x_msg_data => x_msg_data);

          --if ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
          --    raise FND_API.G_EXC_UNEXPECTED_ERROR;
          --elsif (l_return_status = FND_API.G_RET_STS_ERROR) then
          --    select name into l_undeleted_class_name_1 from iem_route_classifications where route_classification_id=p_class_ids_tbl(i);
          --    l_undeleted_class_name := l_undeleted_class_name||l_undeleted_class_name_1||', ';
          --else

            -- update priority before delete an account_classification association
            Update iem_account_route_class set priority=priority-1
    					           where  email_account_id = p_account_id and priority > (Select priority from iem_account_route_class
    					           where route_classification_id=p_class_ids_tbl(i) and  email_account_id=p_account_id);

            DELETE
            FROM IEM_ACCOUNT_ROUTE_CLASS
            WHERE route_classification_id = p_class_ids_tbl(i) and email_account_id = p_account_id;

            if SQL%NOTFOUND then
              raise IEM_ACCOUNT_CLASS_NOT_DELETED;
            end if;

          --end if;

        end if;

   END LOOP;
end if;


--add names of un_deleted classifications into message
if l_undeleted_class_name is not null  then
    l_undeleted_class_name := RTRIM(l_undeleted_class_name, ', ');
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('IEM', 'IEM_RT_CLASS_FAILED_DEL_FOLDER');

    FND_MESSAGE.SET_TOKEN('CLASSIFICATION', l_undeleted_class_name);
    FND_MSG_PUB.ADD;
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

   WHEN IEM_ACCOUNT_CLASS_NOT_DELETED THEN
        ROLLBACK TO delete_acct_class_batch;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('IEM', 'IEM_ACCOUNT_CLASS_NOT_DELETED');
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

   WHEN FND_API.G_EXC_ERROR THEN

	   ROLLBACK TO delete_acct_class_batch;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   ROLLBACK TO delete_acct_class_batch;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,p_data => x_msg_data);


   WHEN OTHERS THEN
	  ROLLBACK TO delete_acct_class_batch;

      x_return_status := FND_API.G_RET_STS_ERROR;
	  IF 	FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        		FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);
      END IF;

	  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count	,p_data	=> x_msg_data);

 END delete_acct_class_batch;

-- ***** Remove for 11i compliance *****
/*
PROCEDURE delete_folder_on_classId
     (p_api_version_number     IN  NUMBER,
      P_init_msg_list   IN  VARCHAR2 := null,
      p_commit          IN  VARCHAR2 := null,
      p_classification_id IN  NUMBER,
      x_return_status   OUT NOCOPY VARCHAR2,
      x_msg_count       OUT NOCOPY NUMBER,
      x_msg_data        OUT NOCOPY VARCHAR2)
IS
	l_api_name        		VARCHAR2(255):='delete_folder_on_classId';
	l_api_version_number 	NUMBER:=1.0;
    l_seq_id		        NUMBER;
    l_return_status         varchar2(30);



    CURSOR  acct_id_cursor( l_classification_id IN NUMBER )  IS
        select unique email_account_id from iem_account_route_class where route_classification_id = l_classification_id;

     MY_EXCP_MSG_IN_FOLDER     EXCEPTION;
     IEM_UNEXPT_ERR_DELETE_FOLDER EXCEPTION;

BEGIN
  --Standard Savepoint
      SAVEPOINT delete_folder_on_classId;
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


  --actuall API starts here
  FOR acct_id IN acct_id_cursor( p_classification_id )  LOOP
        --  ***** Remove for 11i compliance ***
        --iem_route_class_pvt.delete_folder(p_api_version_number =>p_api_version_number,
        --                      p_init_msg_list => p_init_msg_list,
        --                      p_commit => FND_API.G_FALSE,
        --                      p_email_account_id =>acct_id.email_account_id,
        --                      p_class_id => p_classification_id,
        --                      x_return_status =>l_return_status,
        --                      x_msg_count   => x_msg_count,
        --                      x_msg_data => x_msg_data);


        --if (l_return_status = FND_API.G_RET_STS_ERROR) then

        --    RAISE MY_EXCP_MSG_IN_FOLDER;
        --elsif (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
        --    RAISE IEM_UNEXPT_ERR_DELETE_FOLDER ;
        --end if;
  END LOOP;

   --Standard check of p_commit
  IF FND_API.to_Boolean(p_commit) THEN
      COMMIT WORK;
  END IF;


  FND_MSG_PUB.Count_And_Get
  			( p_count => x_msg_count,

                p_data  => x_msg_data
  			);

EXCEPTION
   WHEN MY_EXCP_MSG_IN_FOLDER THEN
        ROLLBACK TO delete_folder_on_classId;
        x_return_status := FND_API.G_RET_STS_ERROR;

        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);


   WHEN IEM_UNEXPT_ERR_DELETE_FOLDER THEN
        ROLLBACK TO delete_folder_on_classId;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        --FND_MESSAGE.SET_NAME('IEM', 'IEM_UNEXPT_ERR_DELETE_FOLDER');

        --FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

   WHEN FND_API.G_EXC_ERROR THEN
	   ROLLBACK TO delete_folder_on_classId;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,p_data => x_msg_data);


   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   ROLLBACK TO delete_folder_on_classId;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,p_data => x_msg_data);


   WHEN OTHERS THEN
	  ROLLBACK TO delete_folder_on_classId;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	  IF 	FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        		FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);
      END IF;


	  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count	,p_data	=> x_msg_data);

 END delete_folder_on_classId;

*/
-- ***** Remove for 11i compliance *****
/*
PROCEDURE create_folder (
                 p_api_version_number  IN   NUMBER,
 		  	     p_init_msg_list       IN   VARCHAR2 := null,
		    	 p_commit              IN   VARCHAR2 := null,
            	 p_email_account_id    IN   NUMBER,
  				 p_classification_name IN   VARCHAR2,

                 x_return_status	   OUT NOCOPY VARCHAR2,
  		  	     x_msg_count	       OUT NOCOPY NUMBER,
	  	  	     x_msg_data	           OUT NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='create_folder';
	l_api_version_number 	NUMBER:=1.0;
    l_seq_id		        NUMBER;


    TYPE email_acct_Rec IS RECORD (
            email_user      iem_email_accounts.email_user%TYPE,
            domain          iem_email_accounts.domain%TYPE,
            email_password  iem_email_accounts.email_password%TYPE);


    l_email_acct_Rec        email_acct_Rec;

    l_db_server_id           NUMBER;

    l_stat                  varchar2(10);
    l_str                   varchar2(200);
    l_ret                   number;

    l_count                 NUMBER;
    l_data                  varchar2(255);
    l_im_link               varchar2(200);
    l_db_link               varchar2(100);

    l_im_link1              varchar2(200);
    l_folder                varchar2(50);
    IEM_ADMIN_ACCOUNT_NOT_EXIST   EXCEPTION;
    IEM_DB_LINK_NOT_AVAILABLE     EXCEPTION;
    tns_no_listener                 EXCEPTION;
    looking_up_object			EXCEPTION;
    PRAGMA    EXCEPTION_INIT(tns_no_listener, -12541);
    PRAGMA    EXCEPTION_INIT(looking_up_object, -04052);

BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT		create_folder_PVT;


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
    select DB_SERVER_ID
            INTO    l_db_server_id
            FROM    IEM_EMAIL_ACCOUNTS
            WHERE   email_account_id = p_email_account_id;

    IEM_DB_CONNECTIONS_PVT.select_item(
                p_api_version_number => 1.0,

                p_db_server_id => l_db_server_id,

                p_is_admin => 'P',
                    x_db_link => l_im_link1,
                    x_return_status =>  l_stat,
                    x_msg_count     => l_count,
                    x_msg_data      => l_data );

    if (l_stat <> FND_API.G_RET_STS_SUCCESS) then

        RAISE IEM_DB_LINK_NOT_AVAILABLE;
    end if;

    select email_user, domain, email_password into l_email_acct_Rec from iem_email_accounts
        where email_account_id = p_email_account_id;

     if SQL%NOTFOUND then
       raise IEM_ADMIN_ACCOUNT_NOT_EXIST;
     end if;



    IF l_im_link1 is null then
        l_im_link := null;
    ELSE
        l_im_link := '@'||l_im_link1;
    END IF;

    l_str := 'begin :l_ret:=im_api.authenticate'||l_im_link||'(:a_user, :a_domain, :a_password); end;';
    EXECUTE IMMEDIATE l_str using OUT l_ret,l_email_acct_Rec.email_user, l_email_acct_Rec.domain, l_email_acct_Rec.email_password;

    IF l_ret=0 THEN
        x_return_status := FND_API.G_RET_STS_SUCCESS;
    ELSE


        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    --now create the folder named by classification name
    l_folder := p_classification_name;
    --dbms_output.put_line('++the p_classification_name is '||l_folder);

    l_str := 'begin :l_ret:=im_api.createfolder'||l_im_link||'(:a_folder);end;';
    EXECUTE IMMEDIATE l_str using OUT l_ret, l_folder;
    IF l_ret=0 THEN
        x_return_status := FND_API.G_RET_STS_SUCCESS;
    ELSE
        x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;



--Standard check of p_commit
IF FND_API.to_Boolean(p_commit) THEN
    COMMIT WORK;
END IF;
FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
              p_data  =>      x_msg_data
			);
EXCEPTION
   WHEN IEM_DB_LINK_NOT_AVAILABLE THEN
        ROLLBACK TO create_folder_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        --FND_MESSAGE.SET_NAME('IEM', 'IEM_DB_LINK_NOT_AVAILABLE');
        --FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
   WHEN IEM_ADMIN_ACCOUNT_NOT_EXIST THEN
        ROLLBACK TO create_folder_PVT;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('IEM', 'IEM_ADMIN_ACCOUNT_NOT_EXIST');

        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

   WHEN tns_no_listener THEN
        ROLLBACK TO create_folder_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('IEM', 'IEM_ADMIN_TNS_NO_LISTENER');
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

   WHEN looking_up_object THEN
        ROLLBACK TO create_folder_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('IEM', 'IEM_ADMIN_LOOKING_UP_OBJECT');
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);


   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO create_folder_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;

       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
              p_data  => x_msg_data

			);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	   ROLLBACK TO create_folder_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
              p_data  =>      x_msg_data
			);

   WHEN OTHERS THEN
	ROLLBACK TO create_folder_PVT;

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

 END	create_folder;

*/
-- ***** Remove for 11i compliance ***
/*
PROCEDURE delete_folder (
                 p_api_version_number  IN   NUMBER,
 		  	     p_init_msg_list       IN   VARCHAR2 := null,
		    	 p_commit              IN   VARCHAR2 := null,
            	 p_email_account_id    IN   NUMBER,
  				 p_class_id            IN   NUMBER,
                 x_return_status	   OUT NOCOPY VARCHAR2,
  		  	     x_msg_count	       OUT NOCOPY NUMBER,
	  	  	     x_msg_data	           OUT NOCOPY VARCHAR2
			 ) is

     TYPE email_acct_Rec IS RECORD (
            email_user      iem_email_accounts.email_user%TYPE,

            domain          iem_email_accounts.domain%TYPE,
            email_password  iem_email_accounts.email_password%TYPE);

    l_email_acct_Rec        email_acct_Rec;
	l_api_name        		VARCHAR2(255):='delete_folder';
	l_api_version_number 	NUMBER:=1.0;

    l_seq_id		        NUMBER;

    l_db_server_id           NUMBER;

    l_stat                  varchar2(10);
    l_str                   varchar2(200);
    l_ret                   number;

    l_count                 NUMBER;
    l_data                  varchar2(255);
    l_im_link               varchar2(200);
    l_db_link               varchar2(100);
    l_im_link1              varchar2(200);

    l_folder                varchar2(50);
    l_message               IEM_IM_WRAPPERS_PVT.msg_table;
    l_folderid              number;
    IEM_ACCT_ID_NOT_EXIST           EXCEPTION;
    IEM_ADMIN_DB_CONNECTION_FAILED  EXCEPTION;
    tns_no_listener		    EXCEPTION;
    PRAGMA    EXCEPTION_INIT(tns_no_listener, -12541);
BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT		delete_folder_PVT;



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
    select DB_SERVER_ID
            INTO    l_db_server_id
            FROM    IEM_EMAIL_ACCOUNTS
            WHERE   email_account_id = p_email_account_id;


    IEM_DB_CONNECTIONS_PVT.select_item(
                p_api_version_number => 1.0,

                p_db_server_id => l_db_server_id,
                p_is_admin => 'P',
                    x_db_link => l_im_link1,
                    x_return_status =>  l_stat,
                    x_msg_count     => l_count,
                    x_msg_data      => l_data );

   if ( l_stat <> FND_API.G_RET_STS_SUCCESS ) then
        raise IEM_ADMIN_DB_CONNECTION_FAILED;
   end if;



    select email_user, domain, email_password into l_email_acct_Rec from iem_email_accounts
        where email_account_id = p_email_account_id;

     if SQL%NOTFOUND then

       raise IEM_ACCT_ID_NOT_EXIST;

     end if;

    IF l_im_link1 is null then
        l_im_link := null;
    ELSE
        l_im_link := '@'||l_im_link1;
    END IF;

    l_str := 'begin :l_ret:=im_api.authenticate'||l_im_link||'(:a_user, :a_domain, :a_password); end;';
    EXECUTE IMMEDIATE l_str using OUT l_ret, l_email_acct_Rec.email_user, l_email_acct_Rec.domain,l_email_acct_Rec.email_password;

    IF l_ret=0 THEN


        x_return_status := FND_API.G_RET_STS_SUCCESS;
    ELSE
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    END IF;

    --get folder name
    select name into l_folder from iem_route_classifications where route_classification_id = p_class_id;
    l_folder := '/'||l_folder;

    --check if the folder is empty
    l_ret := IEM_IM_WRAPPERS_PVT.openfolder(l_folder, l_im_link, l_message);

    -- TO DELETE the FOLDER


    -- if the folder does not exist, do nothing return success.
    -- Else if no message in the folder, delete the folder, return status.
    -- otherwise return error (when there are message in the folder).
    IF l_ret=0 THEN --if the folder exist

        IF l_message.COUNT = 0 THEN --if there is no message in the folder
            l_str := 'begin :l_ret:=im_api.getfolderid'||l_im_link||'(:a_path,:a_folderid);end;';
            EXECUTE IMMEDIATE l_str using OUT l_ret, l_folder, IN OUT l_folderid;

            IF l_ret=0 THEN
                l_str:='begin :l_ret:=im_api.deletefolder'||l_im_link||'(:a_folder);end;';

                EXECUTE IMMEDIATE l_str using OUT l_ret, l_folder;

                IF l_ret=0 THEN
                    x_return_status := FND_API.G_RET_STS_SUCCESS;
                ELSE
                    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                END IF;
            ELSE
                x_return_status := FND_API.G_RET_STS_SUCCESS;
            END IF;
        ELSE
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

    ELSE
        x_return_status := FND_API.G_RET_STS_SUCCESS;

    END IF;

--Standard check of p_commit
IF FND_API.to_Boolean(p_commit) THEN
   COMMIT WORK;
END IF;

FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
              p_data  => x_msg_data
			);
EXCEPTION
   WHEN IEM_ADMIN_DB_CONNECTION_FAILED THEN
        ROLLBACK TO delete_folder_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        --FND_MESSAGE.SET_NAME('IEM', 'IEM_ADMIN_DB_CONNECT');
        --FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

   WHEN IEM_ACCT_ID_NOT_EXIST THEN
        ROLLBACK TO delete_folder_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MESSAGE.SET_NAME('IEM', 'IEM_ACCT_ID_NOT_EXIST');
       FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

   WHEN tns_no_listener THEN
        ROLLBACK TO delete_folder_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MESSAGE.SET_NAME('IEM', 'IEM_ADMIN_TNS_NO_LISTENER');
       FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);


   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO delete_folder_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;


       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
              p_data  => x_msg_data

			);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   ROLLBACK TO delete_folder_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
              p_data  =>      x_msg_data

			);


   WHEN OTHERS THEN
	ROLLBACK TO delete_folder_PVT;

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
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

 END	delete_folder;

*/

--delete class folder first, then delete association of class and email account
PROCEDURE delete_association_on_acctId
     (p_api_version_number     IN  NUMBER,
      P_init_msg_list   IN  VARCHAR2 := null,
      p_commit          IN  VARCHAR2 := null,
      p_email_account_id IN  NUMBER,

      x_return_status   OUT NOCOPY VARCHAR2,
      x_msg_count       OUT NOCOPY NUMBER,
      x_msg_data        OUT NOCOPY VARCHAR2)

IS
	l_api_name        		VARCHAR2(255):='delete_association_on_acctId';
	l_api_version_number 	NUMBER:=1.0;
    l_seq_id		        NUMBER;
    l_return_status         varchar2(30);


    CURSOR  class_id_cursor( l_account_id IN NUMBER )  IS
        select unique route_classification_id from iem_account_route_class where email_account_id = l_account_id;

     MY_EXCP_MSG_IN_FOLDER     EXCEPTION;
     IEM_UNEXPT_ERR_DELETE_FOLDER EXCEPTION;
     l_count_msg_postmdt        number := 0;

BEGIN

  --Standard Savepoint
      SAVEPOINT delete_association_on_acctId;
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

  --actuall API starts here
  --FOR class_id IN class_id_cursor( p_email_account_id )  LOOP

   --     select count(*) into l_count_msg_postmdt from iem_post_mdts where rt_classification_id=class_id.route_classification_id and rt_classification_id<>0 and email_account_id=p_email_account_id;

    --    if l_count_msg_postmdt <> 0 then
    --        RAISE MY_EXCP_MSG_IN_FOLDER;
    --    end if;

        --iem_route_class_pvt.delete_folder(p_api_version_number =>p_api_version_number,
        --                      p_init_msg_list => p_init_msg_list,
        --                      p_commit => FND_API.G_FALSE,
        --                      p_email_account_id =>p_email_account_id,
        --                      p_class_id => class_id.route_classification_id,
        --                      x_return_status =>l_return_status,
        --                      x_msg_count   => x_msg_count,
        --                      x_msg_data => x_msg_data);

        --if (l_return_status = FND_API.G_RET_STS_ERROR) then
        --    RAISE MY_EXCP_MSG_IN_FOLDER;
        --elsif (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
        --    RAISE IEM_UNEXPT_ERR_DELETE_FOLDER;
        --end if;
  --END LOOP;

  --finially delete association of classifcations with this email account

  delete from iem_account_route_class where email_account_id = p_email_account_id;


   --Standard check of p_commit
  IF FND_API.to_Boolean(p_commit) THEN
      COMMIT WORK;
  END IF;

  FND_MSG_PUB.Count_And_Get
  			( p_count => x_msg_count,
                p_data  => x_msg_data
  			);

EXCEPTION


   WHEN MY_EXCP_MSG_IN_FOLDER THEN
        ROLLBACK TO delete_association_on_acctId;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

   WHEN IEM_UNEXPT_ERR_DELETE_FOLDER THEN
        ROLLBACK TO delete_association_on_acctId;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('IEM', 'IEM_UNEXPT_ERR_DELETE_FOLDER');
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

   WHEN FND_API.G_EXC_ERROR THEN


	   ROLLBACK TO delete_association_on_acctId;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,p_data => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   ROLLBACK TO delete_association_on_acctId;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,p_data => x_msg_data);

   WHEN OTHERS THEN
	  ROLLBACK TO delete_association_on_acctId;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	  IF 	FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        		FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME , l_api_name);
      END IF;

	  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count	,p_data	=> x_msg_data);

 END delete_association_on_acctId;

END IEM_ROUTE_CLASS_PVT; -- Package Body IEM_ROUTE_CLASS_PVT

/
