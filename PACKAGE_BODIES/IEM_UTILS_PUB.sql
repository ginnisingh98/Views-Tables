--------------------------------------------------------
--  DDL for Package Body IEM_UTILS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_UTILS_PUB" as
/* $Header: iemputlb.pls 120.1 2006/09/01 22:28:25 rtripath noship $*/

G_PKG_NAME CONSTANT varchar2(30) :='IEM_UTILS_PUB';

PROCEDURE show_all_accounts (p_api_version_number    	IN   	NUMBER,
 		  	     p_init_msg_list  		IN   	VARCHAR2 := FND_API.G_FALSE,
		    	     p_commit	    		IN   	VARCHAR2 := FND_API.G_FALSE,
		  	     x_email_account_tbl 	OUT NOCOPY 	iem_utils_pub.email_account_tbl,
		  	     x_return_status		OUT NOCOPY 	VARCHAR2,
  		    	     x_msg_count	      	OUT NOCOPY 	NUMBER,
	  	    	     x_msg_data			OUT NOCOPY	VARCHAR2)
	  	    	      is
	l_api_name        		VARCHAR2(255):='show_all_accounts';
	l_api_version_number 	NUMBER:=1.0;
	l_account_id_tbl  jtf_number_table:=jtf_number_table();
	l_account_name_tbl  jtf_varchar2_table_100:=jtf_varchar2_table_100();
	l_email_user_tbl  jtf_varchar2_table_100:=jtf_varchar2_table_100();
	l_domain_tbl  jtf_varchar2_table_100:=jtf_varchar2_table_100();
	l_index		number:=1;

BEGIN
-- Standard Start of API savepoint
SAVEPOINT		showAccount;
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

   select email_account_id, account_name, email_user, domain bulk collect into l_account_id_tbl, l_account_name_tbl, l_email_user_tbl, l_domain_tbl from iem_email_accounts
   where upper(email_user)<>upper('intent') and upper(email_user)<>upper('acknowledgements') order by upper(email_user) ||'@'||upper(domain) asc;

  for l_index in l_account_id_tbl.FIRST..l_account_id_tbl.LAST LOOP
		x_email_account_tbl(l_index).email_account_id:=l_account_id_tbl(l_index);
		x_email_account_tbl(l_index).account_name:=l_account_name_tbl(l_index);
		x_email_account_tbl(l_index).email_user:=l_email_user_tbl(l_index);
		x_email_account_tbl(l_index).domain:=l_domain_tbl(l_index);
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
	ROLLBACK TO update_item_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO update_item_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	ROLLBACK TO update_item_PVT;
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

 END;

PROCEDURE Get_Mailcount_by_days (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
				 p_duration in number,
				 p_resource_id in number,
				 x_email_count out NOCOPY email_status_count_tbl,
			      x_return_status	OUT NOCOPY	VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY	   NUMBER,
	  	  	      x_msg_data	OUT NOCOPY	VARCHAR2) IS
cursor c1 is select distinct resource_id from iem_rt_proc_emails
where resource_id>0;
l_agent_id		number;
cursor c_new is select ih_media_item_id from iem_rt_proc_emails
where resource_id=l_agent_id and mail_item_status in ('A','N','T');
cursor c_read is select ih_media_item_id from iem_rt_proc_emails
where resource_id=l_agent_id and mail_item_status in ('R','S');
l_counter		number;
l_new_count		number;
l_read_count		number;
l_api_name		varchar2(50):='Get_Mailcount_by_days';
l_api_version_number	number:=1.0;
l_time			date;
BEGIN
-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call (l_api_version_number,
				    p_api_version_number,
				    l_api_name,
				    G_PKG_NAME)
THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
SAVEPOINT select_mail_count_pvt;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
l_counter:=1;
IF p_resource_id=0	THEN -- for ALL resources
for v1 in c1 loop
	l_new_count:=0;
	l_read_count:=0;
	l_agent_id:=v1.resource_id;
	FOR v2 in c_new LOOP
	select max(start_date_time) into l_time
	from jtf_ih_media_item_lc_segs
	where media_id=v2.ih_media_item_id;
	IF l_time <= (sysdate-p_duration/24) THEN
		l_new_count:=l_new_count+1;
	END IF;
	END LOOP;

	FOR v3 in c_read LOOP
	select max(start_date_time) into l_time
	from jtf_ih_media_item_lc_segs
	where media_id=v3.ih_media_item_id;
	IF l_time <= (sysdate-p_duration/24) THEN
		l_read_count:=l_read_count+1;
	END IF;
	END LOOP;
		x_email_count(l_counter).resource_id:=v1.resource_id;
		x_email_count(l_counter).new_count:=l_new_count;
		x_email_count(l_counter).read_count:=l_read_count;
		l_counter:=l_counter+1;
end loop;
ELSE
	l_agent_id:=p_resource_id;
	l_new_count:=0;
	l_read_count:=0;
	FOR v2 in c_new LOOP
	select max(start_date_time) into l_time
	from jtf_ih_media_item_lc_segs
	where media_id=v2.ih_media_item_id;
	IF l_time <= (sysdate-p_duration/24) THEN
		l_new_count:=l_new_count+1;
	END IF;
	END LOOP;

	FOR v3 in c_read LOOP
	select max(start_date_time) into l_time
	from jtf_ih_media_item_lc_segs
	where media_id=v3.ih_media_item_id;
	IF l_time <= (sysdate-p_duration/24) THEN
		l_read_count:=l_read_count+1;
	END IF;
	END LOOP;
		x_email_count(l_counter).resource_id:=p_resource_id;
		x_email_count(l_counter).new_count:=l_new_count;
		x_email_count(l_counter).read_count:=l_read_count;
END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO select_mail_count_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO select_mail_count_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	ROLLBACK TO select_mail_count_PVT;
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

END Get_Mailcount_by_days ;

PROCEDURE Get_Mailcount_by_MILCS (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
				 p_duration in number,
				 p_resource_id in number,
				 p_tbl	in t_number_table,
				 x_email_count out NOCOPY email_count_tbl,
			      x_return_status	OUT NOCOPY	VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY	   NUMBER,
	  	  	      x_msg_data	OUT NOCOPY	VARCHAR2) IS

l_counter		number;
l_new_count_1		number;
l_api_name		varchar2(50):='Get_Mailcount_by_MILCS';
l_api_version_number	number:=1.0;
l_resource_id		number;
l_milcs_id		number;
	i_tbl	jtf_number_table:=jtf_number_table();
cursor c1 is select distinct resource_id from iem_rt_proc_emails
where resource_id>0;
BEGIN
-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call (l_api_version_number,
				    p_api_version_number,
				    l_api_name,
				    G_PKG_NAME)
THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
SAVEPOINT select_mail_count_pvt;
   x_return_status := FND_API.G_RET_STS_SUCCESS;



  FOR j in p_tbl.FIRST..p_tbl.LAST LOOP
	i_tbl.extend;
	l_milcs_id:=p_tbl(j).milcs_id;
	i_tbl(j):=l_milcs_id;
  END LOOP;
  l_counter:=1;
IF p_resource_id=0 THEN
  FOR v1 in c1 loop
 	SELECT count(*)
	into l_new_count_1
 	FROM iem_rt_proc_emails a
	WHERE resource_id=v1.resource_id
	and a.ih_media_item_id in
	(select  media_id from jtf_ih_media_item_lc_segs
	WHERE milcs_type_id in (select * from TABLE(cast(i_tbl as jtf_number_table)))
	AND resource_id=v1.resource_id and (sysdate-start_date_time)*24>=p_duration);
	IF l_new_count_1>0 THEN
		x_email_count(l_counter).resource_id:=v1.resource_id;
		x_email_count(l_counter).count:=l_new_count_1;
		l_counter:=l_counter+1;
	END IF;
END LOOP;
ELSE
 	SELECT count(*)
	into l_new_count_1
 	FROM iem_rt_proc_emails
	WHERE resource_id=p_resource_id
	and ih_media_item_id in
	(select distinct media_id from jtf_ih_media_item_lc_segs
	where milcs_type_id in (select * from TABLE(cast(i_tbl as jtf_number_table)))
	and resource_id=p_resource_id and (sysdate-start_date_time)*24>=p_duration);
		x_email_count(l_counter).resource_id:=p_resource_id;
		x_email_count(l_counter).count:=l_new_count_1;
END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO select_mail_count_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO select_mail_count_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	ROLLBACK TO select_mail_count_PVT;
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

END Get_Mailcount_by_MILCS ;

END IEM_UTILS_PUB;

/
