--------------------------------------------------------
--  DDL for Package Body IEM_PP_QUEUE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_PP_QUEUE_PVT" AS
/* $Header: iemvqueb.pls 120.5.12010000.2 2009/03/16 10:12:21 sanjrao ship $ */

-- file name: iemvqueb.pls
--
-- Purpose: EMTA runtime queue management
--
-- MODIFICATION HISTORY
-- Person      Date         Comments
--  Liang Xia   3/20/2003    Created
--  Liang Xia   01/29/2004   Enlarged the size of name, value in create_headers.
--  Liang Xia   10/13/2004   Added x_subject for get_queue_rec
--  Liang Xia   11/02/2004   get Action from queue
--  Liang Xia   01/20/2005   Added expunge_queue
--  Liang Xia   05/20/2005   changed signature of expunge_queue
--  Liang Xia   05/20/2005   changed signature of create_pp_queue by adding RFC822_msgID
--		  					 received_date
--  Liang Xia   07/25/2005   Remove queue data without delay, batch operation
--  Ranjan      11/17/2005  Restrict RFC822 to varchar2(256) while inserting bug 6633789
-- ---------   ------  ------------------------------------------

-- Enter procedure, function bodies as shown below
G_PKG_NAME CONSTANT varchar2(30) :='IEM_PP_QUEUE_PVT ';
G_created_updated_by   NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('USER_ID')) ;
G_LAST_UPDATE_LOGIN    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('LOGIN_ID') ) ;

PROCEDURE create_pp_queue (
                 p_api_version_number  IN   NUMBER,
 		  	     p_init_msg_list       IN   VARCHAR2 := null,
		    	 p_commit              IN   VARCHAR2 := null,
            	 p_msg_uid             IN   NUMBER,
  				 p_email_acct_id       IN   NUMBER,
                 p_subject             IN   VARCHAR2,
                 p_from                IN   varchar2,
                 p_size                IN   NUMBER,
                 p_flag                IN   VARCHAR2,
    			 p_retry_count		IN  NUMBER,
				 p_attach_name_tbl	IN JTF_VARCHAR2_TABLE_300,
				 p_attach_size_tbl	IN JTF_VARCHAR2_TABLE_300,
    			 p_attach_type_tbl	IN JTF_VARCHAR2_TABLE_300,
                 p_rfc822_msgId        IN   VARCHAR2,
                 p_received_date       IN   DATE,
    			 x_return_status	   OUT  NOCOPY VARCHAR2,
  				 x_msg_count	       OUT	NOCOPY NUMBER,
				 x_msg_data	           OUT	NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='create_pp_queue';
	l_api_version_number 	NUMBER:=1.0;
    l_seq_id		        NUMBER;

    l_return_status         VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER := 0;
    l_msg_data              VARCHAR2(2000);
    i				INTEGER;
    l_action    number :=1;


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
   	SELECT IEM_RT_PP_QUEUES_s1.nextval
	INTO l_seq_id
	FROM dual;

	INSERT INTO IEM_RT_PP_QUEUES
	(
	EMAIL_ID,
	MSG_UID,
	EMAIL_ACCOUNT_ID,
    SUBJECT,
    FROM_ADDRESS,
    MSG_SIZE ,
    FLAG,
    RETRY_COUNT,
    ACTION,
	RFC822_MESSAGE_ID,
	RECEIVED_DATE,
    CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN
	)
	VALUES
	(
	l_seq_id,
	p_msg_uid,
	p_email_acct_id,
	p_subject,
    p_from,
    p_size,
    p_flag,
    p_retry_count,
    l_action,
	substr(p_rfc822_msgId,1,256),   -- Fix for bug 6633789
	p_received_date,
    decode(G_created_updated_by,null,-1,G_created_updated_by),
	sysdate,
    decode(G_created_updated_by,null,-1,G_created_updated_by),
    sysdate,
    decode(G_LAST_UPDATE_LOGIN,null,-1,G_LAST_UPDATE_LOGIN)
	);

    if (p_attach_name_tbl.FIRST is not null) then

 	FOR i in p_attach_name_tbl.FIRST..p_attach_name_tbl.LAST LOOP

	INSERT INTO IEM_RT_PP_QUEUE_DTLS
	(
	EMAIL_ID,
	ATTACHMENT_NAME,
	ATTACHMENT_SIZE,
    	ATTACHMENT_TYPE,
    	CREATED_BY,
     CREATION_DATE,
    LAST_UPDATED_BY,
   	LAST_UPDATE_DATE,
   	LAST_UPDATE_LOGIN
	)
	VALUES
	(
	l_seq_id,
	p_attach_name_tbl(i),
	decode(p_attach_size_tbl(i), null, 0, to_number(p_attach_size_tbl(i))),
	p_attach_type_tbl(i),
	decode(G_created_updated_by,null,-1,G_created_updated_by),
    sysdate,
   	decode(G_created_updated_by,null,-1,G_created_updated_by),
   	sysdate,
   	decode(G_LAST_UPDATE_LOGIN,null,-1,G_LAST_UPDATE_LOGIN)
	);


    END LOOP;


   end if;  -- FIRST is not null

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

 END create_pp_queue;


Procedure get_queue_rec(
                 p_api_version_number  IN   NUMBER,
 		  	     p_init_msg_list       IN   VARCHAR2 := null,
		    	 p_commit              IN   VARCHAR2 := null,
                 x_pp_queue_id         OUT  NOCOPY NUMBER,
                 x_msg_uid             OUT  NOCOPY NUMBER,
                 x_subject             OUT  NOCOPY VARCHAR2,
                 x_acct_id             OUT  NOCOPY NUMBER,
                 x_action              OUT  NOCOPY NUMBER,
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

    l_queue_rec		iem_rt_pp_queues%rowtype;

	e_nowait	EXCEPTION;
	PRAGMA	EXCEPTION_INIT(e_nowait, -54);
BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT		get_queue_rec_PVT;

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

	for x in ( select email_id
 	from IEM_RT_PP_QUEUES
    where flag = 'N' and retry_count < 5
 	order by creation_date)
    LOOP
        BEGIN
	        select * into l_queue_rec from IEM_RT_PP_QUEUES
	        where email_id=x.email_id and flag = 'N' FOR UPDATE NOWAIT;
     	    exit;
        EXCEPTION when e_nowait then
		    null;
        when others then
		    null ;
        END;
    END LOOP;


    IF ( l_queue_rec.email_id is not null and l_queue_rec.msg_uid is not null
        and l_queue_rec.email_account_id is not null ) then

        update IEM_RT_PP_QUEUES set flag ='A', retry_count=retry_count+1 where email_id=l_queue_rec.email_id;

        x_pp_queue_id := l_queue_rec.email_id;
        x_msg_uid :=l_queue_rec.msg_uid;
        x_acct_id := l_queue_rec.email_account_id;
        x_subject := l_queue_rec.subject;
        x_action := l_queue_rec.action;
    END IF;

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
	ROLLBACK TO get_queue_rec_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get

			( p_count => x_msg_count,
              p_data  => x_msg_data
			);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   ROLLBACK TO get_queue_rec_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
              p_data  =>      x_msg_data
			);

   WHEN OTHERS THEN
	ROLLBACK TO get_queue_rec_PVT;
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

PROCEDURE expunge_queue (
                 p_api_version_number  IN   NUMBER,
 		  	     p_init_msg_list       IN   VARCHAR2 := null,
		    	 p_commit              IN   VARCHAR2 := null,
				 p_acct_id			   IN   VARCHAR2,
				 x_return_status	   OUT  NOCOPY VARCHAR2,
  				 x_msg_count	       OUT	NOCOPY NUMBER,
				 x_msg_data	           OUT	NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='expunge_queue';
	l_api_version_number 	NUMBER:=1.0;
    l_seq_id		        NUMBER;

    l_return_status         VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER := 0;
    l_msg_data              VARCHAR2(2000);

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

   -- Changed the Query to delete all records with 'Q' status as well( to clean up iem_rt_pp_queues table)
   -- for the bug 7494127, since those messages with status 'Q' are not present in Inbox.
   --Delete the records with 'X', which would allow the DP to enqueue the message again.
	delete IEM_RT_PP_QUEUE_DTLS where email_id in
	( select email_id from iem_rt_pp_queues where flag in ('S','Q','X')
			  and email_account_id=p_acct_id );
        delete IEM_RT_PP_QUEUES where flag in ('S','Q','X') and email_account_id=p_acct_id ;

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

 END expunge_queue;


 Procedure get_queue_recs(
                 p_api_version_number  IN   NUMBER,
 		  	     p_init_msg_list       IN   VARCHAR2 := null,
		    	 p_commit              IN   VARCHAR2 := null,
				 p_batch			   IN   NUMBER,
                 x_pp_queue_ids        OUT  NOCOPY JTF_NUMBER_TABLE,
                 x_msg_uids            OUT  NOCOPY JTF_NUMBER_TABLE,
                 x_subjects            OUT  NOCOPY jtf_varchar2_Table_2000,
                 x_acct_id             OUT  NOCOPY NUMBER,
                 x_actions             OUT  NOCOPY JTF_NUMBER_TABLE,
				 x_rfc_msgids          OUT  NOCOPY jtf_varchar2_Table_300,
                 x_return_status	   OUT  NOCOPY VARCHAR2,
  		  	     x_msg_count	       OUT	NOCOPY NUMBER,
	  	  	     x_msg_data	           OUT	NOCOPY VARCHAR2
    ) is

	l_api_name        		VARCHAR2(255):='get_queue_recs';
	l_api_version_number 	NUMBER:=1.0;
    l_seq_id		        NUMBER;

    l_return_status         VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER := 0;
    l_msg_data              VARCHAR2(2000);

    l_queue_rec		iem_rt_pp_queues%rowtype;
	l_batch			number;
	i 				number;
	l_pp_queue_ids  JTF_NUMBER_TABLE := jtf_number_Table();
	l_msg_uids  	JTF_NUMBER_TABLE := jtf_number_Table();
	l_subjects		jtf_varchar2_Table_2000 := jtf_varchar2_Table_2000();
	l_actions		JTF_NUMBER_TABLE := jtf_number_Table();
	l_rfc_msgids	jtf_varchar2_Table_300 := jtf_varchar2_Table_300();
	l_acct_id		number;

	e_nowait	EXCEPTION;
	PRAGMA	EXCEPTION_INIT(e_nowait, -54);

BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT		get_queue_rec_PVT;

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
   for y in ( select  email_account_id, count(*) total,
  	  	   	 nvl(max(sysdate-creation_date),0) wait_time
 			 from IEM_RT_PP_QUEUES
    		 where flag = 'N' and retry_count < 5
 	 		 group by  email_account_id order by wait_time desc )
   loop

	 l_acct_id := y.email_account_id;

	 FOR x in ( select email_id
 	 	from IEM_RT_PP_QUEUES
    	where flag = 'N' and retry_count < 5 and email_account_id=y.email_account_id
 		order by creation_date)
     LOOP

		BEGIN
	        select * into l_queue_rec from IEM_RT_PP_QUEUES
	        where email_id=x.email_id and flag = 'N' FOR UPDATE NOWAIT;

			   l_pp_queue_ids.extend(1);
			   l_msg_uids.extend(1);
			   l_subjects.extend(1);
			   l_actions.extend(1);
			   l_rfc_msgids.extend(1);

			   l_pp_queue_ids(i) := l_queue_rec.email_id;
        	   l_msg_uids(i) := l_queue_rec.msg_uid;
        	   l_subjects(i) := l_queue_rec.subject;
        	   l_actions(i) := l_queue_rec.action;
			   l_rfc_msgids(i) := l_queue_rec.RFC822_message_id;

			update IEM_RT_PP_QUEUES set flag ='A', retry_count=retry_count+1
				   where email_id=l_queue_rec.email_id;

			i := i + 1;

			if ( i > p_batch ) then
     	       exit;
			end if;

        EXCEPTION when e_nowait then
		    null;
        when others then
			 null;
        END;

     END LOOP;

	 if ( i > 1 ) then
	    exit;
	 end if;

  end loop;

  	x_acct_id := l_acct_id;
    x_pp_queue_ids := l_pp_queue_ids;
    x_msg_uids := l_msg_uids;
	x_subjects := l_subjects;
    x_actions := l_actions;
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
	ROLLBACK TO get_queue_rec_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get

			( p_count => x_msg_count,
              p_data  => x_msg_data
			);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   ROLLBACK TO get_queue_rec_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
              p_data  =>      x_msg_data
			);

   WHEN OTHERS THEN
	ROLLBACK TO get_queue_rec_PVT;
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


PROCEDURE mark_flags (
                 p_api_version_number  IN   NUMBER,
 		  	     p_init_msg_list       IN   VARCHAR2 := null,
		    	 p_commit              IN   VARCHAR2 := null,
				 p_flag			   	   IN   VARCHAR2,
				 p_queue_ids		   IN   jtf_varchar2_Table_100,
				 x_return_status	   OUT  NOCOPY VARCHAR2,
  				 x_msg_count	       OUT	NOCOPY NUMBER,
				 x_msg_data	           OUT	NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='mark_flags';
	l_api_version_number 	NUMBER:=1.0;
    l_seq_id		        NUMBER;
	l_count					NUMBER;

    l_return_status         VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER := 0;
    l_msg_data              VARCHAR2(2000);

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
   For j in  1..p_queue_ids.count loop

	   select count(*) into l_count from iem_rt_pp_queues
		   where EMAIL_ID= p_queue_ids(j) and retry_count > 4;

		if ( l_count > 0 ) then
   	   	   update iem_rt_pp_queues set flag=p_flag where EMAIL_ID= p_queue_ids(j);
		else
	   		   update iem_rt_pp_queues set flag='N' where EMAIL_ID= p_queue_ids(j);
        end if;

   end loop;

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

 END mark_flags;

 PROCEDURE reset_data (
                 p_api_version_number  IN   NUMBER,
 		  	     p_init_msg_list       IN   VARCHAR2 := null,
		    	 p_commit              IN   VARCHAR2 := null,
				 x_return_status	   OUT  NOCOPY VARCHAR2,
  				 x_msg_count	       OUT	NOCOPY NUMBER,
				 x_msg_data	           OUT	NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='reset_data';
	l_api_version_number 	NUMBER:=1.0;
    l_seq_id		        NUMBER;
	l_count					NUMBER;

    l_return_status         VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count             NUMBER := 0;
    l_msg_data              VARCHAR2(2000);

BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT		reset_data_PVT;

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
   update iem_rt_pp_queues set flag='N' where flag='A' and retry_count<=4;

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

 END reset_data;

END IEM_PP_QUEUE_PVT;

/
