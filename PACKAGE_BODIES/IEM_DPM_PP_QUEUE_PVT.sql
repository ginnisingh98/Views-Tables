--------------------------------------------------------
--  DDL for Package Body IEM_DPM_PP_QUEUE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_DPM_PP_QUEUE_PVT" AS
/* $Header: iemvdpmb.pls 120.1 2005/10/19 16:47:19 liangxia noship $ */

-- file name: iemvqueb.pls
--
-- Purpose: EMTA runtime queue management
--
-- MODIFICATION HISTORY
-- Person      Date         Comments
--  Liang Xia   8/01/2005   Created
-- ---------   ------  ------------------------------------------

-- Enter procedure, function bodies as shown below
G_PKG_NAME CONSTANT varchar2(30) :='IEM_DPM_QUEUE_PVT ';
G_created_updated_by   NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('USER_ID')) ;
G_LAST_UPDATE_LOGIN    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('LOGIN_ID') ) ;

  Procedure get_folder_work_list(
                 p_api_version_number  IN   NUMBER,
 		  	     p_init_msg_list       IN   VARCHAR2 := null,
		    	 p_commit              IN   VARCHAR2 := null,
                 x_folder_work_list    OUT  NOCOPY folder_worklist_tbl,
                 x_return_status	   OUT  NOCOPY VARCHAR2,
  		  	     x_msg_count	       OUT	NOCOPY NUMBER,
	  	  	     x_msg_data	           OUT	NOCOPY VARCHAR2
    )
	is
	l_api_name        		VARCHAR2(255):='get_folder_work_list';
	l_api_version_number 	NUMBER:=1.0;
    l_seq_id		        NUMBER;

    l_return_status         VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER := 0;
    l_msg_data              VARCHAR2(2000);

 	x						number;
	l_total 				number;
	l_available				number;
	l_folder_list    		folder_worklist_tbl;
	l_folder_type 			varchar2(1);


	cursor c_folder_types is
		   select  folder_type, count(*) total from iem_migration_details
		   where folder_status='R'
		   group by folder_type
		   order by decode(folder_type,'H',1,
	 	   	  					 	   'N',2,
								 	   'Q',3,
								 	   'I',4,
								 	   'D',5,
								  	       0 ) desc;

	cursor c_folder_details( p_type varchar2) is
		   select a.email_account_id,a.email_user||'@'||a.domain as user_name,
		   		  a.email_password,b.dns_name, b.port, c.migration_id, c.folder_name
		   from iem_email_accounts a, iem_email_servers b, iem_migration_details c,
		   		 iem_server_groups d, iem_email_server_types e
		   where  ( c.folder_status='R' )
		   		 and c.folder_type= p_type and c.email_account_id=a.email_account_id
				 and a.server_group_id=d.server_group_id
				 and d.server_group_id=b.server_group_id and b.server_type_id=e.email_server_type_id
				 and upper(e.email_server_type)='IMAP';


	cursor c_agent_folder_details( p_type varchar2) is
		   select c.email_account_id,a.email_user||'@'||a.domain as user_name,
		   		  a.email_password,d.dns_name, d.port, c.migration_id, c.folder_name
		   from iem_agent_accounts a, iem_email_accounts b,
		   		 iem_migration_details c, iem_email_servers d, iem_server_groups e,
				 iem_email_server_types f
		   where ( c.folder_status='R' )
		   		  and c.folder_type= p_type and c.email_account_id=a.email_account_id
				  and c.agent_account_id=a.agent_account_id
				  and b.server_group_id=e.server_group_id
				  and b.email_account_id = a.email_account_id
				  and d.server_type_id=f.email_server_type_id
				  and upper(f.email_server_type)='IMAP';

BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT		get_folder_work_list_PVT;

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

    -- first update the Flder_status for all finished account
	update iem_migration_details a set a.folder_status='D', a.last_update_date=sysdate, a.msg_download_count=
							(select count(*) from iem_migration_store_temp
				 		 			where dp_status='D' and migration_id = a.migration_id)
		  where a.folder_status='R' and a.msg_record_count =
		   					  ( (select count(*) from iem_migration_store_temp
				 		 	  	where dp_status='D' and migration_id = a.migration_id)
		   		  		 		 +
			 	   		   	  ( select count(*) from iem_migration_store_temp
				   	 	 		where dp_status='E' and migration_id = a.migration_id));

	update iem_migration_details a set a.last_update_date=sysdate, a.msg_download_count=
							(select count(*) from iem_migration_store_temp
				 		 			where dp_status='D' and migration_id = a.migration_id)
		  where a.folder_status='R';

	x := 1;
    FOR v_folder_types IN c_folder_types LOOP
		l_total := v_folder_types.total;

		if ( l_total > 0 ) then
		    l_folder_type :=  v_folder_types.folder_type;

			--getting folder details for this type
		    if ( l_folder_type='I' or l_folder_type='D' ) then

			   FOR v_agent_folder_details IN c_agent_folder_details(l_folder_type) LOOP

			   	   select count(*) into l_available from iem_migration_store_temp
				   		  		   where migration_id=v_agent_folder_details.migration_id
								   and mig_status<>'E' and dp_status is null;

			   	   if ( l_available > 0 ) then
				   	  l_folder_list(x).migration_id := v_agent_folder_details.migration_id;
    			   	  l_folder_list(x).email_acct_id := v_agent_folder_details.email_account_id;
    			   	  l_folder_list(x).folder_type := l_folder_type;
    			   	  l_folder_list(x).folder_name := v_agent_folder_details.folder_name;
    			   	  l_folder_list(x).user_name   := v_agent_folder_details.user_name;
    			   	  l_folder_list(x).password := v_agent_folder_details.email_password;
    			   	  l_folder_list(x).server_name := v_agent_folder_details.dns_name;
				   	  l_folder_list(x).port := v_agent_folder_details.port;
				   	  x := x + 1;

				   	  if ( x > 10 ) then
				   	  	 exit;
				   	  end if;

				   end if;

		       END LOOP;
			   if ( x > 1 ) then
			   	  exit;
			   end if;
			else
			   FOR v_folder_details IN c_folder_details(l_folder_type) LOOP

				   select count(*) into l_available from iem_migration_store_temp
				   		  		   where migration_id=v_folder_details.migration_id
								   and mig_status<>'E' and dp_status is null;

				   if ( l_available > 0 ) then

				   	  l_folder_list(x).migration_id := v_folder_details.migration_id;
    			   	  l_folder_list(x).email_acct_id := v_folder_details.email_account_id;
    			   	  l_folder_list(x).folder_type := l_folder_type;
    			   	  l_folder_list(x).folder_name := v_folder_details.folder_name;
    			   	  l_folder_list(x).user_name   := v_folder_details.user_name;
    			   	  l_folder_list(x).password := v_folder_details.email_password;
    			   	  l_folder_list(x).server_name := v_folder_details.dns_name;
				   	  l_folder_list(x).port := v_folder_details.port;
				   	  x := x + 1;

				   if ( x > 10 ) then
				   	  exit;
				   end if;

				   end if;

		       END LOOP;

			   if ( x > 1 ) then
			   	  exit;
			   end if;
			end if;

   		end if;

    END LOOP;

	x_folder_work_list := l_folder_list;
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
	ROLLBACK TO get_folder_work_list_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get

			( p_count => x_msg_count,
              p_data  => x_msg_data
			);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   ROLLBACK TO get_folder_work_list_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
              p_data  =>      x_msg_data
			);

   WHEN OTHERS THEN
	ROLLBACK TO get_folder_work_list_PVT;
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

 END get_folder_work_list;


 Procedure get_msg_work_list(
                 p_api_version_number  IN   NUMBER,
 		  	     p_init_msg_list       IN   VARCHAR2 := null,
		    	 p_commit              IN   VARCHAR2 := null,
				 p_batch			   IN   NUMBER,
				 p_migration_id		   IN 	NUMBER,
				 x_mail_ids            OUT  NOCOPY JTF_NUMBER_TABLE,
                 x_message_ids         OUT  NOCOPY JTF_NUMBER_TABLE,
                 x_msg_uids            OUT  NOCOPY JTF_NUMBER_TABLE,
                 x_subjects            OUT  NOCOPY jtf_varchar2_Table_2000,
				 x_rfc_msgids          OUT  NOCOPY jtf_varchar2_Table_300,
                 x_return_status	   OUT  NOCOPY VARCHAR2,
  		  	     x_msg_count	       OUT	NOCOPY NUMBER,
	  	  	     x_msg_data	           OUT	NOCOPY VARCHAR2
    ) is

	l_api_name        		VARCHAR2(255):='get_msg_work_list';
	l_api_version_number 	NUMBER:=1.0;
    l_seq_id		        NUMBER;

    l_return_status         VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER := 0;
    l_msg_data              VARCHAR2(2000);

    l_queue_rec		iem_migration_store_temp%rowtype;
	l_batch			number;
	i 				number;
	l_mail_ids  JTF_NUMBER_TABLE := jtf_number_Table();
	l_msg_uids  	JTF_NUMBER_TABLE := jtf_number_Table();
	l_subjects		jtf_varchar2_Table_2000 := jtf_varchar2_Table_2000();
	l_message_ids		JTF_NUMBER_TABLE := jtf_number_Table();
	l_rfc_msgids	jtf_varchar2_Table_300 := jtf_varchar2_Table_300();

	e_nowait	EXCEPTION;
	PRAGMA	EXCEPTION_INIT(e_nowait, -54);

BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT		get_msg_work_list_PVT;

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


   i := 1;

   for y in ( select mail_id
			  from iem_migration_store_temp
			  where migration_id=p_migration_id and mig_status<>'E'and dp_status is null
			  order by creation_date asc  )
   loop

		BEGIN

	        select * into l_queue_rec from iem_migration_store_temp
	        where migration_id=p_migration_id and mig_status<>'E' and dp_status is null
				  and mail_id=y.mail_id
			FOR UPDATE NOWAIT;

			   l_mail_ids.extend(1);
			   l_message_ids.extend(1);
			   l_msg_uids.extend(1);
			   l_subjects.extend(1);
			   l_rfc_msgids.extend(1);

			   l_mail_ids(i) := l_queue_rec.mail_id;
			   l_message_ids(i) := l_queue_rec.message_id;
        	   l_msg_uids(i) := l_queue_rec.msg_uid;
        	   l_subjects(i) := l_queue_rec.subject;
			   l_rfc_msgids(i) := l_queue_rec.RFC822_message_id;

			 update iem_migration_store_temp set dp_status ='A', last_update_date=sysdate
				   where migration_id=p_migration_id and mail_id=l_queue_rec.mail_id;

			i := i + 1;

        EXCEPTION when e_nowait then
		    null;
        when others then
			 null;
        END;

	 	if ( i > p_batch ) then
     	  exit;
	 	end if;

  end loop;

  	x_mail_ids := l_mail_ids;
    x_message_ids  := l_message_ids ;
    x_msg_uids := l_msg_uids;
	x_subjects := l_subjects;
	x_rfc_msgids := l_rfc_msgids;

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
	ROLLBACK TO get_msg_work_list_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get

			( p_count => x_msg_count,
              p_data  => x_msg_data
			);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   ROLLBACK TO get_msg_work_list_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
              p_data  =>      x_msg_data
			);

   WHEN OTHERS THEN
	ROLLBACK TO get_msg_work_list_PVT;
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
END;


 Procedure log_batch_error(
                 p_api_version_number  IN   NUMBER,
 		  	     p_init_msg_list       IN   VARCHAR2 := null,
		    	 p_commit              IN   VARCHAR2 := null,
				 p_migration_id		   IN 	NUMBER,
				 p_mail_ids            IN   JTF_NUMBER_TABLE,
				 p_error               IN   VARCHAR2,
                 x_return_status	   OUT  NOCOPY VARCHAR2,
  		  	     x_msg_count	       OUT	NOCOPY NUMBER,
	  	  	     x_msg_data	           OUT	NOCOPY VARCHAR2
    ) is

	l_api_name        		VARCHAR2(255):='log_batch_error';
	l_api_version_number 	NUMBER:=1.0;
    l_seq_id		        NUMBER;

    l_return_status         VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER := 0;
    l_msg_data              VARCHAR2(2000);

	i 				number;
	l_error			IEM_MIGRATION_STORE_TEMP.error_text%type;


BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT		log_batch_error_PVT;

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

   l_error := substr(p_error,1,1000);

   For i in  1..p_mail_ids.count loop

   	   update iem_migration_store_temp set dp_status='E', error_text=l_error
   	   		  where mail_id=p_mail_ids(i);

   end loop;

   update iem_migration_details set status='E', status_text=l_error
   		  where migration_id=p_migration_id;


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
	ROLLBACK TO log_batch_error_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get

			( p_count => x_msg_count,
              p_data  => x_msg_data
			);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   ROLLBACK TO log_batch_error_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
              p_data  =>      x_msg_data
			);

   WHEN OTHERS THEN
	ROLLBACK TO log_batch_error_PVT;
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
END;


END IEM_DPM_PP_QUEUE_PVT;

/
