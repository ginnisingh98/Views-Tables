--------------------------------------------------------
--  DDL for Package Body IEM_MAILITEM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_MAILITEM_PUB" as
/* $Header: iemclntb.pls 120.4.12010000.4 2009/08/28 07:10:31 shramana ship $*/
G_PKG_NAME		varchar2(100):='IEM_MAILITEM_PUB';
PROCEDURE GetMailItemCount (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
				 p_resource_id in number,
				 p_tbl	in t_number_table:=NULL,
				 x_email_count out NOCOPY email_count_tbl,
			      x_return_status	OUT	NOCOPY VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY NUMBER,
	  	  	      x_msg_data	OUT NOCOPY	VARCHAR2)

			IS
				 l_tbl	t_number_table:=t_number_table();
				i_tbl	jtf_number_table:=jtf_number_table();
CURSOR c1 IS
 	SELECT a.EMAIL_ACCOUNT_ID,a.RT_CLASSIFICATION_ID,
	b.USER_NAME,c.name,count(*) Total,
	nvl(max(sysdate-a.received_date)*24*60,0) wait_time
 	FROM iem_rt_proc_emails a,iem_mstemail_accounts b,
	iem_route_classifications c,iem_agents d
	WHERE a.resource_id=0
	and a.email_account_id=b.email_account_id
	and a.rt_classification_id=c.route_classification_id
	AND a.email_account_id=d.email_account_id
	AND d.resource_id=p_resource_id
	AND a.group_id in (select * from TABLE(cast(i_tbl as jtf_number_table)))
	and a.message_id not in (select message_id from iem_reroute_hists where agent_id=p_resource_id)
 	GROUP by a.email_account_id,a.rt_classification_id,b.USER_NAME,c.name;
CURSOR c_11 IS
 	SELECT a.EMAIL_ACCOUNT_ID,a.RT_CLASSIFICATION_ID,
	b.USER_NAME,c.name,count(*) Total,
	nvl(max(sysdate-a.received_date)*24*60,0) wait_time
 	FROM iem_rt_proc_emails a,iem_mstemail_accounts b,
	iem_route_classifications c,iem_agents d
	WHERE a.resource_id=0
	and a.email_account_id=b.email_account_id
	and a.rt_classification_id=c.route_classification_id
	AND a.email_account_id=d.email_account_id
	AND d.resource_id=p_resource_id
	AND (a.group_id in (select group_id from jtf_rs_group_members where resource_id=p_resource_id
					and delete_flag<>'Y')
		or (a.group_id=0))
	and a.message_id not in (select message_id from iem_reroute_hists where agent_id=p_resource_id)
 	GROUP by a.email_account_id,a.rt_classification_id,b.USER_NAME,c.name;
Cursor c2 IS
	select a.email_account_id,a.rt_classification_id,
	b.USER_NAME,c.name,Count(*) Total,
	nvl(max(sysdate-a.received_date)*24*60,0) wait_time,
     max(decode(a.mail_item_status,'A',1,'N',1,'T',1,0)) email_status
 	FROM iem_rt_proc_emails a,iem_mstemail_accounts b,
	iem_route_classifications c
	WHERE a.resource_id=p_resource_id
	and a.email_account_id=b.email_account_id
	and a.rt_classification_id=c.route_classification_id
	and a.queue_status is null
 	GROUP by a.email_account_id,a.rt_classification_id,b.USER_NAME,c.name;

	l_email_account_id		number;
	l_rt_classification_id		number;
	l_where	varchar2(500);
	l_index		number:=1;
	l_api_version_number	number:=1.0;
	l_api_name		varchar2(30):='GetMailItemCount';
	x_act_tbl  t_number_table:=t_number_table() ;
	x_rt_class_tbl  t_number_table:=t_number_table() ;
	x_rt_class_name_tbl  jtf_varchar2_table_100:=jtf_varchar2_table_100() ;
	x_acct_name_tbl  jtf_varchar2_table_100:=jtf_varchar2_table_100() ;
	x_count  t_number_table:=t_number_table() ;
	x_wait_time  t_number_table:=t_number_table() ;
	l_ret_status		varchar2(10);
	l_msg_count		number;
	l_msg_data		varchar2(500);
	l_acq_wait	number;
	l_match		number:=0;
	l_acq_count		number;
	l_count			number;
	IEM_NO_DATA		EXCEPTION;
	NOT_A_VALID_AGENT	EXCEPTION;
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

	select count(*) into l_count
	from jtf_rs_group_members
	where resource_id=p_resource_id
	and delete_flag<>'Y';
IF l_count>0 then		-- It is a valid agent should get queue message if any
	IF p_tbl is null then
	open c_11;
	fetch c_11 bulk collect into x_act_tbl,x_rt_class_tbl,x_acct_name_tbl,x_rt_class_name_tbl,x_count,x_wait_time;
	close c_11;
	ELSE
		l_tbl:=p_tbl;
  FOR j in l_tbl.FIRST..l_tbl.LAST LOOP
	i_tbl.extend;
	i_tbl(j):=l_tbl(j);
  END LOOP;
	open c1;
	fetch c1 bulk collect into x_act_tbl,x_rt_class_tbl,x_acct_name_tbl,x_rt_class_name_tbl,x_count,x_wait_time;
	close c1;
 END IF;
END IF;	 -- End of  It is a valid agent should get queue message if any
IF x_act_tbl.count>0 THEN
	for l_index in x_act_tbl.FIRST..x_act_tbl.LAST LOOP
		x_email_count(l_index).email_account_id:=x_act_tbl(l_index);
		x_email_count(l_index).rt_classification_id:=x_rt_class_tbl(l_index);
x_email_count(l_index).rt_classification_name:=x_rt_class_name_tbl(l_index);
	x_email_count(l_index).email_account_name:=x_acct_name_tbl(l_index);
		x_email_count(l_index).email_que_count:=x_count(l_index);
		x_email_count(l_index).email_acq_count:=0;
	x_email_count(l_index).email_max_qwait:=x_wait_time(l_index);
	x_email_count(l_index).email_max_await:=0;
	x_email_count(l_index).email_status:=0;
    end loop;
	FOR v2 IN c2 LOOP
		l_match:=0;
		FOR l_index IN x_email_count.FIRST..x_email_count.LAST LOOP
	IF (v2.email_account_id=x_email_count(l_index).email_account_id)
		AND
     (v2.rt_classification_id=x_email_count(l_index).rt_classification_id) THEN
   	l_match:=1;
	x_email_count(l_index).email_acq_count:=v2.total;
	x_email_count(l_index).email_max_await:=v2.wait_time;
	x_email_count(l_index).email_status:=v2.email_status;
	END IF;
	EXIT when l_match=1;
  END LOOP;
	IF l_match=0 THEN	-- Add New Record
		l_index:=x_email_count.count+1;
		x_email_count(l_index).email_account_id:=v2.email_account_id;
		x_email_count(l_index).rt_classification_id:=v2.rt_classification_id;
x_email_count(l_index).rt_classification_name:=v2.name;
	x_email_count(l_index).email_account_name:=v2.USER_NAME;
		x_email_count(l_index).email_que_count:=0;
		x_email_count(l_index).email_acq_count:=v2.total;
	x_email_count(l_index).email_max_qwait:=0;
	x_email_count(l_index).email_max_await:=v2.wait_time;
	x_email_count(l_index).email_status:=v2.email_status;
	END IF;
END LOOP;		-- End of Main Loop
ELSE
	FOR v2 in c2 LOOP
		l_index:=x_email_count.count+1;
		x_email_count(l_index).email_account_id:=v2.email_account_id;
		x_email_count(l_index).rt_classification_id:=v2.rt_classification_id;
x_email_count(l_index).rt_classification_name:=v2.name;
	x_email_count(l_index).email_account_name:=v2.USER_NAME;
		x_email_count(l_index).email_que_count:=0;
		x_email_count(l_index).email_acq_count:=v2.total;
	x_email_count(l_index).email_max_qwait:=0;
	x_email_count(l_index).email_max_await:=v2.wait_time;
	x_email_count(l_index).email_status:=v2.email_status;
	END LOOP;
END IF;
	if x_email_count.count=0 THEN
		raise IEM_NO_DATA;
	end if;
	commit;
-- Standard Check Of p_commit.
	IF p_commit='T' THEN
		COMMIT WORK;
	END IF;
-- Standard callto get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
			( p_count =>  x_msg_count,
                 	p_data  =>    x_msg_data
			);
EXCEPTION

WHEN NOT_A_VALID_AGENT THEN
	ROLLBACK TO select_mail_count_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
	 FND_MESSAGE.SET_NAME('IEM', 'IEM_UNRECOGNIZED_AGENT');
	 FND_MSG_PUB.ADD;
	 FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
   WHEN IEM_NO_DATA THEN
	 ROLLBACK TO select_mail_count_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR ;
	 FND_MESSAGE.SET_NAME('IEM', 'IEM_NO_DATA');
	 FND_MSG_PUB.ADD;
	 FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
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

END GetMailItemCount;

PROCEDURE GetMailItemCount (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
				p_resource_id in number,
				p_tbl	in t_number_table:=NULL,
				p_email_account_id in number,
				x_class_bin	out NOCOPY class_count_tbl,
			     x_return_status	OUT NOCOPY VARCHAR2,
  		  	     x_msg_count	      OUT NOCOPY	   NUMBER,
	  	  	     x_msg_data	OUT NOCOPY	VARCHAR2)

			IS
				 l_tbl	t_number_table:=t_number_table();
				i_tbl	jtf_number_table:=jtf_number_table();
CURSOR c1 IS
 	SELECT a.RT_CLASSIFICATION_ID,b.name,COUNT(*) TOTAL
 	FROM iem_rt_proc_emails a,iem_route_classifications b
	where a.email_account_id=p_email_account_id
	and a.resource_id =0
	and a.rt_classification_id=b.route_classification_id
	AND a.group_id in (select * from TABLE(cast(i_tbl as jtf_number_table)))
 	GROUP by a.rt_classification_id,b.name;
	l_index		number:=1;
	l_api_version_number	number:=1.0;
	l_api_name		varchar2(30):='GetMailItemCount';
	x_rt_class_tbl  t_number_table:=t_number_table() ;
	x_rt_class_name_Tbl  jtf_varchar2_table_100:=jtf_varchar2_table_100() ;
	x_count  t_number_table:=t_number_table() ;
	l_ret_status		varchar2(10);
	l_msg_count		number;
	l_msg_data		varchar2(500);
	IEM_NO_DATA		EXCEPTION;
begin
-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call (l_api_version_number,
				    p_api_version_number,
				    l_api_name,
				    G_PKG_NAME)
THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
SAVEPOINT select_item_PVT;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   BEGIN
	IF p_tbl.count=0 then
		IEM_MAILITEM_PUB.getGroupDetails(p_api_version_number=>1.0,
				 p_init_msg_list=>'F',
				 p_commit=>'F',
				 p_resource_id	=>p_resource_id,
			    	 x_tbl	=>l_tbl,
			      x_return_status=>l_ret_status	,
  		  	      x_msg_count=>l_msg_count,
	  	  	      x_msg_data=>l_msg_data);
	ELSE
		l_tbl:=p_tbl;
	END IF;
 EXCEPTION WHEN OTHERS THEN
		IEM_MAILITEM_PUB.getGroupDetails(p_api_version_number=>1.0,
				 p_init_msg_list=>'F',
				 p_commit=>'F',
				 p_resource_id	=>p_resource_id,
			    	 x_tbl	=>l_tbl,
			      x_return_status=>l_ret_status	,
  		  	      x_msg_count=>l_msg_count,
	  	  	      x_msg_data=>l_msg_data);
	IF l_tbl.count=0 THEN
		RAISE IEM_NO_DATA;
	END IF;
 END;
  FOR j in l_tbl.FIRST..l_tbl.LAST LOOP
	i_tbl.extend;
	i_tbl(j):=l_tbl(j);
  END LOOP;
	open c1;
	fetch c1 bulk collect into x_rt_class_tbl,x_rt_class_name_Tbl,x_count;
	close c1;
	IF x_rt_class_tbl.count=0 THEN
		RAISE IEM_NO_DATA;
	END IF;
	FOR l_index in x_rt_class_tbl.FIRST..x_rt_class_tbl.LAST LOOP
		x_class_bin(l_index).rt_classification_id:=x_rt_class_tbl(l_index);
	x_class_bin(l_index).rt_classification_name:=x_rt_class_name_TbL(l_index);
		x_class_bin(l_index).email_count:=x_count(l_index);
    END LOOP;

-- Standard Check Of p_commit.
	IF p_commit='T' THEN
		COMMIT WORK;
	END IF;
-- Standard callto get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
			( p_count =>  x_msg_count,
                 	p_data  =>    x_msg_data
			);
EXCEPTION
   WHEN IEM_NO_DATA THEN
	 ROLLBACK TO select_item_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR ;
	 FND_MESSAGE.SET_NAME('IEM', 'IEM_NO_DATA');
	 FND_MSG_PUB.ADD;
	 FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO select_item_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO select_item_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	ROLLBACK TO select_item_PVT;
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

END GetMailItemCount;

PROCEDURE GetMailItemCount (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
				p_email_account_id in number,
				x_class_bin	out NOCOPY class_count_tbl,
			     x_return_status	OUT NOCOPY VARCHAR2,
  		  	     x_msg_count	      OUT NOCOPY	   NUMBER,
	  	  	     x_msg_data	OUT NOCOPY	VARCHAR2)

			IS
 cursor c2 is select a.rt_classification_id,b.name,count(*) total
 from iem_rt_proc_emails a,iem_route_classifications b
 where a.email_account_id=p_email_account_id
 and a.resource_id=0
 and a.rt_classification_id=b.route_classification_id
 group by rt_classification_id,b.name;
	l_index		number:=1;
	l_api_version_number	number:=1.0;
	l_api_name		varchar2(30):='GetMailItemCount';
	x_rt_class_tbl  t_number_table:=t_number_table() ;
	x_rt_class_name_Tbl  jtf_varchar2_table_100:=jtf_varchar2_table_100() ;
	x_count  t_number_table:=t_number_table() ;
	IEM_NO_DATA		EXCEPTION;
begin
-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call (l_api_version_number,
				    p_api_version_number,
				    l_api_name,
				    G_PKG_NAME)
THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
SAVEPOINT select_item_PVT;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
	open c2;
	fetch c2 bulk collect into x_rt_class_tbl,x_rt_class_name_Tbl,x_count;
	close c2;
	IF x_rt_class_tbl.count=0 THEN
		RAISE IEM_NO_DATA;
	END IF;
	FOR l_index in x_rt_class_tbl.FIRST..x_rt_class_tbl.LAST LOOP
		x_class_bin(l_index).rt_classification_id:=x_rt_class_tbl(l_index);
	x_class_bin(l_index).rt_classification_name:=x_rt_class_name_TbL(l_index);
		x_class_bin(l_index).email_count:=x_count(l_index);
    END LOOP;

-- Standard Check Of p_commit.
	IF p_commit='T' THEN
		COMMIT WORK;
	END IF;
-- Standard callto get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
			( p_count =>  x_msg_count,
                 	p_data  =>    x_msg_data
			);
EXCEPTION
   WHEN IEM_NO_DATA THEN
	 ROLLBACK TO select_item_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR ;
	 FND_MESSAGE.SET_NAME('IEM', 'IEM_NO_DATA');
	 FND_MSG_PUB.ADD;
	 FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO select_item_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO select_item_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	ROLLBACK TO select_item_PVT;
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

END GetMailItemCount;

PROCEDURE GetMailItemCount (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
				 p_resource_id in number,
				 p_tbl	in t_number_table:=NULL,
				 p_email_account_id in number,
				 p_classification_id in number,
				 x_count		out nocopy number,
			      x_return_status	OUT NOCOPY	VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY	   NUMBER,
	  	  	      x_msg_data	OUT NOCOPY	VARCHAR2) IS
	l_api_version_number	number:=1.0;
	l_api_name		varchar2(30):='GetMailItemCount';
	l_tbl	t_number_table:=t_number_table();
	i_tbl	jtf_number_table:=jtf_number_table();
	l_ret_status		varchar2(10);
	l_msg_count		number;
	l_msg_data		varchar2(500);
	IEM_NO_DATA		EXCEPTION;
	begin
-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call (l_api_version_number,
				    p_api_version_number,
				    l_api_name,
				    G_PKG_NAME)
THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
SAVEPOINT select_item_PVT;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
	BEGIN
	IF p_tbl.count=0 then
		IEM_MAILITEM_PUB.getGroupDetails(p_api_version_number=>1.0,
				 p_init_msg_list=>'F',
				 p_commit=>'F',
				 p_resource_id	=>p_resource_id,
			    	 x_tbl	=>l_tbl,
			      x_return_status=>l_ret_status	,
  		  	      x_msg_count=>l_msg_count,
	  	  	      x_msg_data=>l_msg_data);
	ELSE
		l_tbl:=p_tbl;
	END IF;
 EXCEPTION WHEN OTHERS THEN
		IEM_MAILITEM_PUB.getGroupDetails(p_api_version_number=>1.0,
				 p_init_msg_list=>'F',
				 p_commit=>'F',
				 p_resource_id	=>p_resource_id,
			    	 x_tbl	=>l_tbl,
			      x_return_status=>l_ret_status	,
  		  	      x_msg_count=>l_msg_count,
	  	  	      x_msg_data=>l_msg_data);
	IF l_tbl.count=0 THEN
		RAISE IEM_NO_DATA;
	END IF;
 END;
  FOR j in l_tbl.FIRST..l_tbl.LAST LOOP
	i_tbl.extend;
	i_tbl(j):=l_tbl(j);
  END LOOP;
 	select COUNT(*)
	INTO x_count
 	from iem_rt_proc_emails
	where email_account_id=p_email_account_id
	and rt_classification_id=p_classification_id
 	and resource_id=0
	and group_id in (select * from TABLE(cast(i_tbl as jtf_number_table)));
	IF x_count=0 THEN
		RAISE IEM_NO_DATA;
	END IF;
-- Standard Check Of p_commit.
	IF p_commit='T' THEN
		COMMIT WORK;
	END IF;
-- Standard callto get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
			( p_count =>  x_msg_count,
                 	p_data  =>    x_msg_data
			);
EXCEPTION
   WHEN IEM_NO_DATA THEN
	 ROLLBACK TO select_item_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR ;
	 FND_MESSAGE.SET_NAME('IEM', 'IEM_NO_DATA');
	 FND_MSG_PUB.ADD;
	 FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO select_item_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO select_item_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	ROLLBACK TO select_item_PVT;
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

     end GetMailItemcount;

-- Return POST MDT and TAg KEy values . Called by EMC Client

PROCEDURE GetMailItem (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
				p_resource_id in number,
				p_tbl	in t_number_table:=NULL,
				p_rt_classification in number,
				p_account_id in number,
				x_email_data out NOCOPY  iem_rt_proc_emails%rowtype,
				x_tag_key_value	OUT  NOCOPY keyVals_tbl_type,
				x_encrypted_id		OUT NOCOPY VARCHAR2,
		     	x_return_status	OUT NOCOPY	VARCHAR2,
  		     	x_msg_count	      OUT NOCOPY	   NUMBER,
	  	     	x_msg_data	OUT NOCOPY	VARCHAR2) IS
	Type get_message_rec is REF CURSOR ;
	email_dtl_cur		get_message_rec;
	l_id		number;
	l_index	number;
	l_date	date;
	l_api_version_number	number:=1.0;
	l_api_name		varchar2(30):='GetMailItem';
	l_tbl	t_number_table:=t_number_table();
	i_tbl	jtf_number_table:=jtf_number_table();
	l_ret_status		varchar2(10);
	l_where			varchar2(255);
	l_string			varchar2(32000):='';
	l_msg_count		number;
	l_count		number;
	l_msg_data		varchar2(500);
	l_encrypted_id		varchar2(500);
	IEM_NO_DATA		EXCEPTION;
	l_tag_key_value	IEM_TAGPROCESS_PUB.keyVals_tbl_type;
 	l_interaction_rec        JTF_IH_PUB.interaction_rec_type;
	e_nowait	EXCEPTION;
	PRAGMA	EXCEPTION_INIT(e_nowait, -54);
	l_time		number;
BEGIN
-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call (l_api_version_number,
				    p_api_version_number,
				    l_api_name,
				    G_PKG_NAME)
THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
SAVEPOINT select_data_PVT;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
IF (p_tbl is null) and  (nvl(p_account_id,FND_API.G_MISS_NUM)<> FND_API.G_MISS_NUM) and
(nvl(p_rt_classification,FND_API.G_MISS_NUM)<> FND_API.G_MISS_NUM)  THEN
	  OPEN email_dtl_cur FOR
'select /*FIRST_ROWS*/ * from iem_rt_proc_emails p where message_id not in (select message_id from iem_reroute_hists where resource_id=:res1 ) and  email_account_id=:id
and rt_classification_id=:rt
and resource_id=0
and ( p.group_id = 0
      or exists (
         select null
         from   jtf_rs_group_members gm
         where  resource_id=:res
         and    gm.group_id = p.group_id
         and    delete_flag <>''Y''
         )
    )
order by received_date for update skip locked'
using p_resource_id,p_account_id,p_rt_classification,p_resource_id;
 LOOP
	BEGIN
		FETCH email_dtl_cur into x_email_data;
		EXIT;
	EXCEPTION when e_nowait then
		null;
	WHEN OTHERS then
		null;
	END;
 END LOOP;
	close email_dtl_cur;
ELSE
	  OPEN email_dtl_cur FOR
'select /*FIRST_ROWS*/ * from iem_rt_proc_emails p where message_id not in (select message_id from iem_reroute_hists where resource_id=:res1 ) and  email_account_id=:id
and resource_id=0
and ( p.group_id = 0
      or exists (
         select null
         from   jtf_rs_group_members gm
         where  resource_id=:res
         and    gm.group_id = p.group_id
         and    delete_flag <>''Y''
         )
    )
order by received_date for update skip locked'
using p_resource_id,p_account_id,p_resource_id;
 LOOP
	BEGIN
		FETCH email_dtl_cur into x_email_data;
		EXIT;
	EXCEPTION when e_nowait then
		null;
	WHEN OTHERS then
		null;
	END;
 END LOOP;
	close email_dtl_cur;
END IF;
IF x_email_data.message_id IS NOT NULL THEN
	l_tag_key_value.delete;
IEM_TAGPROCESS_PUB.getTagValues_on_MsgId(
        P_Api_Version_Number=>1.0,
        p_message_id => x_email_data.message_id,
        x_key_value=>l_tag_key_value,
	   x_encrypted_id=>l_encrypted_id,
        x_msg_count=>l_msg_count,
        x_return_status=>l_ret_status,
        x_msg_data =>l_msg_data);
		l_index:=1;
IF l_tag_key_value.count>0 THEN
	x_encrypted_id:=l_encrypted_id;
FOR i in l_tag_key_value.FIRST..l_tag_key_value.LAST LOOP
	x_tag_key_value(l_index).key:=l_tag_key_value(i).key;
	x_tag_key_value(l_index).value:=l_tag_key_value(i).value;
	x_tag_key_value(l_index).datatype:=l_tag_key_value(i).datatype;
	l_index:=l_index+1;
END LOOP;
END IF;
	UPDATE iem_rt_proc_emails
	set resource_id=p_resource_id,
	queue_status='G'
	where message_id=x_email_data.message_id ;
		IF x_email_data.ih_interaction_id is not null then		-- updating interaction with resource id
			l_interaction_rec.interaction_id:=x_email_data.ih_interaction_id;
			l_interaction_rec.resource_id:=p_resource_id;
     		JTF_IH_PUB.Update_Interaction( p_api_version     => 1.0,
                                  p_resp_appl_id    => TO_NUMBER(FND_PROFILE.VALUE('RESP_APPL_ID')),
                                  p_resp_id         => TO_NUMBER(FND_PROFILE.VALUE('RESP_ID')),
                         		p_user_id		  =>nvl(TO_NUMBER (FND_PROFILE.VALUE('USER_ID')),-1),
							p_login_id	  =>TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),
                                  x_return_status   => l_ret_status,
                                  x_msg_count       => l_msg_count,
                                  x_msg_data        => l_msg_data,
                                  p_interaction_rec => l_interaction_rec
                                 );
		END IF;
	commit;
ELSE
	RAISE IEM_NO_DATA;
END IF;
-- Standard Check Of p_commit.
	IF p_commit='T' THEN
		COMMIT WORK;
	END IF;
-- Standard callto get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
			( p_count =>  x_msg_count,
                 	p_data  =>    x_msg_data
			);
EXCEPTION
   WHEN IEM_NO_DATA THEN
	 ROLLBACK TO select_data_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR ;
	 FND_MESSAGE.SET_NAME('IEM', 'IEM_NO_DATA');
	 FND_MSG_PUB.ADD;
	 FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO select_data_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO select_data_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
	WHEN NO_DATA_FOUND THEN
		null;
   WHEN OTHERS THEN
	ROLLBACK TO select_data_PVT;
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

end GetMailItem;
PROCEDURE DisposeMailItem (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
				 p_message_id	in number,
		     	x_return_status	OUT NOCOPY	VARCHAR2,
  		     	x_msg_count	      OUT NOCOPY	   NUMBER,
	  	     	x_msg_data	OUT NOCOPY	VARCHAR2) IS
	l_api_name        		VARCHAR2(255):='DisposeMailItem';
	l_api_version_number 	NUMBER:=1.0;
	l_media_rec	JTF_IH_PUB.media_rec_type;
	l_media_data	JTF_IH_MEDIA_ITEMS%ROWTYPE;
	l_ret_status	varchar2(10);
	l_msg_data	varchar2(300);
	l_msg_count	number;
	l_media_id	number;

BEGIN
-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call (l_api_version_number,
				    p_api_version_number,
				    l_api_name,
				    G_PKG_NAME)
THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
SAVEPOINT dispose_mail_item_PVT;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   BEGIN			-- Close the Media Item
	SELECT IH_MEDIA_ITEM_ID into l_media_id
	FROM iem_rt_proc_emails
	WHERE MESSAGE_ID=p_message_id;
	SELECT * into l_media_data
	FROM JTF_IH_MEDIA_ITEMS
	WHERE MEDIA_ID=l_media_id;
    l_media_rec.media_id := l_media_id;
    l_media_rec.source_id := l_media_data.source_id;
	l_media_rec.direction:= l_media_data.direction;
    l_media_rec.start_date_time := l_media_data.start_date_time;
    l_media_rec.media_item_type := l_media_data.media_item_type;
    l_media_rec.media_item_ref := l_media_data.media_item_ref;
    l_media_rec.media_data := l_media_data.media_data;
  JTF_IH_PUB.Close_MediaItem( 1.0,
						'T',
						'F',
						TO_NUMBER(FND_PROFILE.VALUE('RESP_APPL_ID')),
						TO_NUMBER(FND_PROFILE.VALUE('RESP_ID')),
						nvl(TO_NUMBER (FND_PROFILE.VALUE('USER_ID')),-1),
						TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),
						l_ret_status,
						l_msg_count,
						l_msg_data,
						l_media_rec);
	EXCEPTION WHEN OTHERS THEN
			NULL;
	END ;
	DELETE FROM iem_rt_proc_emails
	WHERE MESSAGE_ID=p_message_id;
	delete from iem_reroute_hists
	where message_id=p_message_id;
	delete from iem_kb_results where message_id=p_message_id;
	delete from iem_email_classifications where message_id=p_message_id;
	delete from iem_comp_rt_stats where type='WORKFLOW' and param=to_char(p_message_id);

	/*
     delete from iem_encrypted_tags
	where message_id=p_message_id;
	*/
-- Standard Check Of p_commit.
	IF p_commit='T' THEN
		COMMIT WORK;
	END IF;
-- Standard callto get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
			( p_count =>  x_msg_count,
                 	p_data  =>    x_msg_data
			);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO dispose_mail_item_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO dispose_mail_item_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	ROLLBACK TO dispose_mail_item_PVT;
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

 END	DisposeMailItem;

PROCEDURE getGroupDetails(p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
				 p_resource_id	in number,
			    	x_tbl	out NOCOPY  t_number_table,
		     	x_return_status	OUT NOCOPY	VARCHAR2,
  		     	x_msg_count	      OUT NOCOPY	   NUMBER,
	  	     	x_msg_data	OUT NOCOPY	VARCHAR2) IS

	l_api_name        		VARCHAR2(255):='getGroupDetails';
	l_api_version_number 	NUMBER:=1.0;
	NOT_A_VALID_AGENT		EXCEPTION;
BEGIN
-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call (l_api_version_number,
				    p_api_version_number,
				    l_api_name,
				    G_PKG_NAME)
THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
SAVEPOINT getgroupdetails_PVT;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
select group_id bulk collect into x_tbl
from jtf_rs_group_members
where resource_id=p_resource_id
and delete_flag<>'Y';
IF x_tbl.count=0 then
	raise NOT_A_VALID_AGENT;
END IF;
x_tbl.extend;
x_tbl(x_tbl.count):=0;
-- Standard Check Of p_commit.
	IF p_commit='T' THEN
		COMMIT WORK;
	END IF;
-- Standard callto get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
			( p_count =>  x_msg_count,
                 	p_data  =>    x_msg_data
			);
EXCEPTION
WHEN NOT_A_VALID_AGENT THEN
	ROLLBACK TO getgroupdetails_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
	 FND_MESSAGE.SET_NAME('IEM', 'IEM_UNRECOGNIZED_AGENT');
	 FND_MSG_PUB.ADD;
	 FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO getgroupdetails_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO getgroupdetails_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	ROLLBACK TO getgroupdetails_PVT;
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
END getGroupDetails;

PROCEDURE UpdateMailItem (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
				p_email_data in  iem_rt_proc_emails%rowtype,
		     	x_return_status	OUT NOCOPY	VARCHAR2,
  		     	x_msg_count	      OUT NOCOPY	   NUMBER,
	  	     	x_msg_data	OUT NOCOPY	VARCHAR2) IS

	l_api_name        		VARCHAR2(255):='UpdateMailItem';
	l_api_version_number 	NUMBER:=1.0;
     l_LAST_UPDATED_BY    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('USER_ID')) ;
     l_LAST_UPDATE_DATE    DATE:=SYSDATE;
     l_LAST_UPDATE_LOGIN    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('LOGIN_ ID')) ;

BEGIN
-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call (l_api_version_number,
				    p_api_version_number,
				    l_api_name,
				    G_PKG_NAME)
THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
SAVEPOINT update_item_PVT;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   UPDATE iem_rt_proc_emails
   SET
		resource_id         =p_email_data.resource_id,
		PRIORITY            =p_email_data.priority,
		MSG_STATUS      =p_email_data.msg_status,
		SUBJECT             =p_email_data.subject,
		SENT_DATE           =p_email_data.sent_date,
		CUSTOMER_ID         =p_email_data.customer_id,
		CONTACT_ID         =p_email_data.CONTACT_ID,
		RELATIONSHIP_ID          =p_email_data.RELATIONSHIP_ID,
		RECEIVED_DATE		=p_email_data.received_date,
		MAIL_ITEM_STATUS    =p_email_data.mail_item_status,
          LAST_UPDATE_DATE = sysdate,
          LAST_UPDATED_BY = decode(l_LAST_UPDATED_BY,null,-1,l_LAST_UPDATED_BY),
          LAST_UPDATE_LOGIN =decode(l_LAST_UPDATE_LOGIN,null,-1,l_LAST_UPDATE_LOGIN),
     ATTRIBUTE1 =p_email_data.attribute1,
     ATTRIBUTE2 =p_email_data.attribute2,
     ATTRIBUTE3 =p_email_data.attribute3,
     ATTRIBUTE4 = p_email_data.attribute4,
     ATTRIBUTE5 = p_email_data.attribute5,
     ATTRIBUTE6 = p_email_data.attribute6,
     ATTRIBUTE7 = p_email_data.attribute7,
     ATTRIBUTE8 = p_email_data.attribute8,
     ATTRIBUTE9 = p_email_data.attribute9,
     ATTRIBUTE10 =p_email_data.attribute10,
     ATTRIBUTE11 = p_email_data.attribute11,
     ATTRIBUTE12 = p_email_data.attribute12,
     ATTRIBUTE13 = p_email_data.attribute13,
     ATTRIBUTE14 = p_email_data.attribute14,
     ATTRIBUTE15 = p_email_data.attribute15
WHERE message_id=p_email_data.message_id;

	IF p_commit='T' THEN
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

 END	UpdateMailItem;

PROCEDURE getMailItemInfo(p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
				 p_message_id	in number,
				 p_account_id		in number,
				 p_agent_id		in number,
				x_email_data out NOCOPY iem_rt_proc_emails%rowtype,
		     	x_return_status	OUT NOCOPY	VARCHAR2,
  		     	x_msg_count	      OUT	 NOCOPY   NUMBER,
	  	     	x_msg_data	OUT NOCOPY	VARCHAR2) IS

	l_api_name        		VARCHAR2(255):='GetMailItemInfo';
	l_api_version_number 	NUMBER:=1.0;
BEGIN
-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call (l_api_version_number,
				    p_api_version_number,
				    l_api_name,
				    G_PKG_NAME)
THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
SAVEPOINT get_mail_iteminfo_pvt;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
IF p_agent_id<>0 THEN		-- Not a supervisor mode
BEGIN
	SELECT *
	INTO x_email_data
	FROM iem_rt_proc_emails
	WHERE   message_id=p_message_id;
EXCEPTION WHEN NO_DATA_FOUND THEN
	 FND_MESSAGE.SET_NAME('IEM', 'IEM_NO_DATA');
	 FND_MSG_PUB.ADD;
	 FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
	 raise;
END;
ELSE					-- Supervisor Mode
BEGIN
	SELECT *
	INTO x_email_data
	FROM iem_rt_proc_emails
	WHERE   message_id=p_message_id;
EXCEPTION WHEN NO_DATA_FOUND THEN
	 FND_MESSAGE.SET_NAME('IEM', 'IEM_NO_DATA');
	 FND_MSG_PUB.ADD;
	 FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
	 raise;
END;
END IF;


-- Standard callto get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
			( p_count =>  x_msg_count,
                 	p_data  =>    x_msg_data
			);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO get_mail_iteminfo_pvt;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO get_mail_iteminfo_pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	ROLLBACK TO get_mail_iteminfo_pvt;
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
END getmailiteminfo;
PROCEDURE getEmailHeaders(p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
				 p_resource_id	in number,
				 p_email_account_id		in number,
				 p_display_size	in NUMBER,
				 p_page_count	in NUMBER,
				 p_sort_by	in VARCHAR2,
				 p_sort_order	in number,
				 x_total_message	out NOCOPY number,
				x_acq_email_data out NOCOPY  acq_email_info_tbl,
		     	x_return_status	OUT NOCOPY	VARCHAR2,
  		     	x_msg_count	      OUT NOCOPY	   NUMBER,
	  	     	x_msg_data	OUT NOCOPY	VARCHAR2) IS

	l_api_name        		VARCHAR2(255):='getEmailHeaders';
	l_api_version_number 	NUMBER:=1.0;
	Type get_data is REF CURSOR;-- RETURN acq_email_info_tbl;
	email_cur		get_data;
	l_counter		number:=0;
	l_order_by		varchar2(255);
	l_sort_order		varchar2(100);
	l_where			varchar2(255);
	l_temp_tbl		acq_email_info_tbl;
	l_start_index		number:=0;
	l_first_index		number:=0;
	l_last_index			number:=0;
	l_expire			varchar2(1):='N';
     l_status_type		varchar2(40):='IEM_MESSAGE_STATUS_TYPE';

BEGIN
-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call (l_api_version_number,
				    p_api_version_number,
				    l_api_name,
				    G_PKG_NAME)
THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
SAVEPOINT getemailheaders_pvt;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   select decode(p_sort_order,0,'ASC','DESC')
   into l_sort_order
   from dual;
   IF p_sort_by = FND_API.G_MISS_CHAR  OR p_sort_by='D' THEN
    l_order_by:=' Order BY to_date(substr(a.sent_Date,1,20),''DD-MON-YYYY HH24:MI:SS'') '||l_sort_order;
   ELSIF p_sort_by='S' THEN
	l_order_by:='ORDER BY a.subject '||l_sort_order||',to_date(substr(a.sent_Date,1,20),''DD-MON-YYYY HH24:MI:SS'') '||l_sort_order;
   ELSIF p_sort_by='C' THEN
	l_order_by:='ORDER BY c.NAME '||l_sort_order||',to_date(substr(a.sent_Date,1,20),''DD-MON-YYYY HH24:MI:SS'') '||l_sort_order;
   ELSIF p_sort_by='F' THEN
	l_order_by:='ORDER BY a.from_address '||l_sort_order||',to_date(substr(a.sent_Date,1,20),''DD-MON-YYYY HH24:MI:SS'') '||l_sort_order;
   ELSIF p_sort_by='T' THEN
	l_order_by:='ORDER BY d.description '||l_sort_order||',to_date(substr(a.sent_Date,1,20),''DD-MON-YYYY HH24:MI:SS'') '||l_sort_order;
   ELSIF p_sort_by='R' THEN
	l_order_by:='ORDER BY read_status '||l_sort_order||',to_date(substr(a.sent_Date,1,20),''DD-MON-YYYY HH24:MI:SS'') '||l_sort_order;
   END IF;
   x_total_message:=0;
   OPEN email_cur FOR
   'SELECT a.message_id,a.rt_classification_id,c.name,b.rt_media_item_id,
    b.rt_interaction_id,
    a.email_account_id,a.message_flag,a.from_address,a.subject,a.priority,a.msg_status,
    to_char(to_date(substr(a.sent_Date,1,20),''DD-MON-YYYY HH24:MI:SS''),''MM/DD/RRRR HH24:MI:SS''),a.mail_item_status,
   -- to_char(to_date(substr(a.sent_Date,5,length(a.sent_Date)-13)||substr(a.sent_date,25,4),''Mon DD hh24:mi:ssyyyy''),''MM/DD/RRRR HH24:MI:SS''),a.mail_item_status,
    a.from_resource_id,
    decode(a.mail_item_status,''R'',1,''S'',1,0) read_status,d.description
    FROM iem_rt_proc_emails a,
	  IEM_RT_MEDIA_ITEMS b,
    IEM_ROUTE_CLASSIFICATIONS c,
    FND_LOOKUPS d
    WHERE A.RT_CLASSIFICATION_ID=C.ROUTE_CLASSIFICATION_ID AND B.EXPIRE=:expire AND A.MESSAGE_ID=B.MESSAGE_ID and a.resource_id=:id and a.email_account_id=:account_id and
    substr(a.mail_item_status,1,1)=d.lookup_code and d.lookup_type=:status_type '||l_order_by
    using l_expire,p_resource_id,p_email_account_id,l_status_type;
    l_temp_tbl.delete;
    l_counter:=1;
    LOOP
 	   FETCH email_cur  INTO l_temp_tbl(l_counter);
    	   EXIT WHEN email_cur%NOTFOUND;
	   l_counter:=l_counter+1;
    END LOOP;
    CLOSE email_cur;
  IF l_temp_tbl.count>0  THEN	-- Data Selected Now implement Display Logic
	x_total_message:=l_temp_tbl.count;
	IF p_display_size=FND_API.G_MISS_NUM THEN
		x_acq_email_data:=l_temp_tbl;	-- Return all data
					--incase of null display size
	ELSE
		IF p_page_count<>FND_API.G_MISS_NUM THEN
		l_first_index:=p_page_count*p_display_size - p_display_size+1;
		l_last_index:=p_page_count*p_display_size;
		ELSIF p_page_count=FND_API.G_MISS_NUM THEN
			l_first_index:=1;
			l_last_index:=p_display_size;
		END IF;
		IF l_last_index > x_total_message THEN
		  l_last_index:=x_total_message;
		END IF;
		FOR l_index in l_first_index..l_last_index LOOP
			x_acq_email_data(l_index):=l_temp_tbl(l_index);
		END LOOP;
     END IF;
   END IF;
	IF p_commit='T' THEN
		COMMIT WORK;
	END IF;

-- Standard callto get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
			( p_count =>  x_msg_count,
                 	p_data  =>    x_msg_data
			);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO getemailheaders_pvt;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO getemailheaders_pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	ROLLBACK TO getemailheaders_pvt;
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
END getEmailHeaders;
-- 12.1.3 development  Cherry Picking
PROCEDURE getUnreadEmailHeaders(p_api_version_number    IN		NUMBER,
 		  	        p_init_msg_list		IN		VARCHAR2 ,
		    	        p_commit		IN		VARCHAR2 ,
			        p_email_account_id	IN		number,
				p_display_size		IN		NUMBER,
				p_page_count		IN		NUMBER,
				p_sort_by		IN		VARCHAR2,
				p_sort_order		IN		number,
				x_total_message		OUT NOCOPY	number,
				x_queue_email_data	OUT NOCOPY	queue_email_info_tbl,
		     	        x_return_status		OUT NOCOPY	VARCHAR2,
     		     		x_msg_count		OUT NOCOPY	NUMBER,
	  	     		x_msg_data		OUT NOCOPY	VARCHAR2) IS

	l_api_name        		VARCHAR2(255):='getUnreadEmailHeaders';
	l_api_version_number 		NUMBER:=1.0;
	Type get_data is REF CURSOR;-- RETURN queue_email_info_tbl;
	email_cur			get_data;
	l_counter			number:=0;
	l_order_by			varchar2(255);
	l_sort_order			varchar2(100);
	l_where				varchar2(255);
	l_temp_tbl			queue_email_info_tbl;
	l_start_index			number:=0;
	l_first_index			number:=0;
	l_last_index			number:=0;
	l_expire			varchar2(1):='N';
        l_status_type			varchar2(40):='IEM_MESSAGE_STATUS_TYPE';
	l_all_groups			varchar2(40):=FND_MESSAGE.GET_STRING('IEM', 'IEM_ALL_GROUPS');
	l_service_request		varchar2(40):=FND_MESSAGE.GET_STRING('IEM','IEM_SERVICE_REQUEST');
	l_sr_id				varchar2(40):='IEMNBZTSRVSRID';

BEGIN
-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call (l_api_version_number,
				    p_api_version_number,
				    l_api_name,
				    G_PKG_NAME)
THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
SAVEPOINT getunreademailheaders_pvt;
   x_return_status := FND_API.G_RET_STS_SUCCESS;


   select decode(p_sort_order,0,'ASC','DESC')
   into l_sort_order
   from dual;

   IF p_sort_by = FND_API.G_MISS_CHAR  OR p_sort_by='D' THEN
    l_order_by:=' Order BY to_date(substr(a.sent_Date,1,20),''DD-MON-YYYY HH24:MI:SS'') '||l_sort_order;
   ELSIF p_sort_by='S' THEN
	l_order_by:='ORDER BY a.subject '||l_sort_order||',to_date(substr(a.sent_Date,1,20),''DD-MON-YYYY HH24:MI:SS'') '||l_sort_order;
   ELSIF p_sort_by='CL' THEN
	l_order_by:='ORDER BY c.NAME '||l_sort_order||',to_date(substr(a.sent_Date,1,20),''DD-MON-YYYY HH24:MI:SS'') '||l_sort_order;
   ELSIF p_sort_by='F' THEN
	l_order_by:='ORDER BY a.from_address '||l_sort_order||',to_date(substr(a.sent_Date,1,20),''DD-MON-YYYY HH24:MI:SS'') '||l_sort_order;
   ELSIF p_sort_by='C' THEN
	l_order_by:='ORDER BY p.party_name '||l_sort_order||',to_date(substr(a.sent_Date,1,20),''DD-MON-YYYY HH24:MI:SS'') '||l_sort_order;
   ELSIF p_sort_by='RG' THEN
	l_order_by:='ORDER BY group_name '||l_sort_order||',to_date(substr(a.sent_Date,1,20),''DD-MON-YYYY HH24:MI:SS'') '||l_sort_order;
   ELSIF p_sort_by='SO' THEN
	l_order_by:='ORDER BY source '||l_sort_order||',to_date(substr(a.sent_Date,1,20),''DD-MON-YYYY HH24:MI:SS'') '||l_sort_order;
   ELSIF p_sort_by='NU' THEN
	l_order_by:='ORDER BY source_number '||l_sort_order||',to_date(substr(a.sent_Date,1,20),''DD-MON-YYYY HH24:MI:SS'') '||l_sort_order;
   END IF;
   x_total_message:=0;
   OPEN email_cur FOR

    'SELECT a.message_id,a.rt_classification_id,c.name,
    a.email_account_id,a.from_address,a.subject,
    to_char(to_date(substr(a.sent_Date,1,20),''DD-MON-YYYY HH24:MI:SS''),''MM/DD/RRRR HH24:MI:SS''),
    a.from_resource_id,
    p.party_name, p.party_id, a.contact_id,
    replace(a.group_id, a.group_id, :all_groups) as group_name,
    decode(  (SELECT decode(DTLS.value,null,0,DTLS.value) FROM IEM_ENCRYPTED_TAG_DTLS DTLS, IEM_ENCRYPTED_TAGS TAG
              WHERE DTLS.key = :sr_id
              and DTLS.encrypted_id = TAG.encrypted_id
              and TAG.message_id = a.message_id),null,null,:l_service_request) source,
    (SELECT incident_number FROM CS_INCIDENTS_ALL_B WHERE incident_id =
	(SELECT decode(DTLS.value,null,0,DTLS.value) FROM IEM_ENCRYPTED_TAG_DTLS DTLS, IEM_ENCRYPTED_TAGS TAG
	    WHERE DTLS.key = ''IEMNBZTSRVSRID''
	    and DTLS.encrypted_id = TAG.encrypted_id
	    and TAG.message_id = a.message_id)
    )source_number
    from iem_rt_proc_emails a , IEM_ROUTE_CLASSIFICATIONS c,
    FND_LOOKUPS d , HZ_PARTIES p
    where a.RT_CLASSIFICATION_ID=c.ROUTE_CLASSIFICATION_ID
    and a.resource_id=0
    and a.email_account_id=:account_id
    and substr(a.mail_item_status,1,1)=d.lookup_code
    and d.lookup_type=:status_type
    and a.customer_id = p.party_id (+) ' ||l_order_by
    using l_all_groups,l_sr_id,l_service_request,p_email_account_id,l_status_type;
    l_temp_tbl.delete;
    l_counter:=1;
    LOOP
 	   FETCH email_cur  INTO l_temp_tbl(l_counter);
    	   EXIT WHEN email_cur%NOTFOUND;
	   l_counter:=l_counter+1;
    END LOOP;
    CLOSE email_cur;
  IF l_temp_tbl.count>0  THEN	-- Data Selected Now implement Display Logic
	x_total_message:=l_temp_tbl.count;
	IF p_display_size=FND_API.G_MISS_NUM THEN

		x_queue_email_data:=l_temp_tbl;	-- Return all data
					--incase of null display size
	ELSE

		IF p_page_count<>FND_API.G_MISS_NUM THEN
		l_first_index:=p_page_count*p_display_size - p_display_size+1;
		l_last_index:=p_page_count*p_display_size;
		ELSIF p_page_count=FND_API.G_MISS_NUM THEN
			l_first_index:=1;
			l_last_index:=p_display_size;
		END IF;
		IF l_last_index > x_total_message THEN
		  l_last_index:=x_total_message;
		END IF;
		FOR l_index in l_first_index..l_last_index LOOP
			x_queue_email_data(l_index):=l_temp_tbl(l_index);
		END LOOP;
     END IF;
   END IF;

	IF p_commit='T' THEN
		COMMIT WORK;
	END IF;
-- Standard callto get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
			( p_count =>  x_msg_count,
                 	p_data  =>    x_msg_data
			);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO getunreademailheaders_pvt;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO getunreademailheaders_pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
     ROLLBACK TO getunreademailheaders_pvt;
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
END getUnreadEmailHeaders;
-- End 12.1.3
PROCEDURE GetQueueItemData (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
				p_message_id in number,
				p_from_agent_id in number,
				p_to_agent_id in number,
				p_mail_item_status in varchar2,
				x_email_data out NOCOPY iem_rt_proc_emails%rowtype,
				x_tag_key_value	OUT NOCOPY keyVals_tbl_type,
				x_encrypted_id		OUT NOCOPY VARCHAR2,
		     	x_return_status	OUT NOCOPY	VARCHAR2,
  		     	x_msg_count	      OUT NOCOPY	   NUMBER,
	  	     	x_msg_data	OUT NOCOPY	VARCHAR2) IS
	l_api_version_number	number:=1.0;
	l_api_name		varchar2(30):='GetQueueItemData';
	l_tag_key_value	IEM_TAGPROCESS_PUB.keyVals_tbl_type;
	l_msg_count		number;
	l_msg_data		varchar2(500);
	l_ret_status		varchar2(50);
	l_encrypted_id		varchar2(500);
	l_index			number;
BEGIN
-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call (l_api_version_number,
				    p_api_version_number,
				    l_api_name,
				    G_PKG_NAME)
THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
SAVEPOINT select_data_PVT;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   SELECT * INTO x_email_data
   FROM iem_rt_proc_emails
   WHERE message_id=p_message_id
   AND resource_id=0 for update;
	update iem_rt_proc_emails
	set from_resource_id=p_from_agent_id,
	    resource_id=p_to_agent_id,
	    mail_item_status=p_mail_item_status
	    where message_id=p_message_id;
	l_tag_key_value.delete;
IEM_TAGPROCESS_PUB.getTagValues_on_MsgId(
        P_Api_Version_Number=>1.0,
        p_message_id => x_email_data.message_id,
        x_key_value=>l_tag_key_value,
	   x_encrypted_id=>l_encrypted_id,
        x_msg_count=>l_msg_count,
        x_return_status=>l_ret_status,
        x_msg_data =>l_msg_data);
		l_index:=1;
IF l_tag_key_value.count>0 THEN
	x_encrypted_id:=l_encrypted_id;
FOR i in l_tag_key_value.FIRST..l_tag_key_value.LAST LOOP
	x_tag_key_value(l_index).key:=l_tag_key_value(i).key;
	x_tag_key_value(l_index).value:=l_tag_key_value(i).value;
	x_tag_key_value(l_index).datatype:=l_tag_key_value(i).datatype;
	l_index:=l_index+1;
END LOOP;
END IF;
	IF p_commit='T' THEN
		COMMIT WORK;
	END IF;
-- Standard callto get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
			( p_count =>  x_msg_count,
                 	p_data  =>    x_msg_data
			);
EXCEPTION
   WHEN NO_DATA_FOUND THEN
	 ROLLBACK TO select_data_PVT;
      x_return_status := 'N';
	 FND_MESSAGE.SET_NAME('IEM', 'IEM_NO_DATA');
	 FND_MSG_PUB.ADD;
	 FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO select_data_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO select_data_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	ROLLBACK TO select_data_PVT;
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
end GetQueueItemData;
PROCEDURE GetMailItem (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
				p_resource_id in number,
				p_tbl	in t_number_table:=NULL,
				p_rt_classification in number,
				p_account_id in number,
				x_email_data out NOCOPY  iem_rt_proc_emails%rowtype,
		     	x_return_status	OUT NOCOPY	VARCHAR2,
  		     	x_msg_count	      OUT NOCOPY	   NUMBER,
	  	     	x_msg_data	OUT NOCOPY	VARCHAR2) IS
begin
	null;
end GetMailitem;

PROCEDURE GetMailItem(p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
				p_resource_id in number,
				p_acct_rt_class_id in number,
				x_email_data out NOCOPY  iem_rt_proc_emails%rowtype,
		     	x_return_status	OUT NOCOPY	VARCHAR2,
  		     	x_msg_count	      OUT NOCOPY	   NUMBER,
	  	     	x_msg_data	OUT NOCOPY	VARCHAR2) IS
begin
	null;
end;
PROCEDURE ResolvedMessage (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
				 p_message_id	in number,
				 p_action_flag		in  varchar2,
			      x_return_status	OUT NOCOPY	VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY	   NUMBER,
	  	  	      x_msg_data	OUT NOCOPY	VARCHAR2) IS
	l_msg_rec		iem_rt_proc_emails%rowtype;
	l_header_rec		iem_ms_base_headers%rowtype;
	l_msg_text		iem_ms_msgbodys.value%type;
	l_ret_status		varchar2(10);
	l_msg_data		varchar2(1000);
	l_msg_count		number;
	l_out_message_id		number;
	l_top_intent		iem_classifications.classification%type;
	insert_arch_dtl_error	EXCEPTION;
	cursor c1 is select a.classification,b.score from
	iem_classifications a,iem_email_classifications b
	where b.message_id=p_message_id
	and a.classification_id=b.classification_id
	order by score asc;
	l_api_version_number	number:=1.0;
	l_api_name		varchar2(30):='ResolvedMessage';
	l_media_rec	JTF_IH_PUB.media_rec_type;
	l_media_data	JTF_IH_MEDIA_ITEMS%ROWTYPE;
	ERROR_CLOSING_MEDIA		EXCEPTION;
	BEGIN
-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call (l_api_version_number,
				    p_api_version_number,
				    l_api_name,
				    G_PKG_NAME)
THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
SAVEPOINT select_data_PVT;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
	select * into l_msg_rec from iem_rt_proc_emails
	where message_id=p_message_id;
   -- Close The Media Item
   BEGIN
	SELECT * into l_media_data
	FROM JTF_IH_MEDIA_ITEMS
	WHERE MEDIA_ID=l_msg_rec.ih_media_item_id;
    l_media_rec.media_id := l_media_data.media_id;
    l_media_rec.source_id := l_media_data.source_id;
	l_media_rec.direction:= l_media_data.direction;
    l_media_rec.start_date_time := l_media_data.start_date_time;
    l_media_rec.media_item_type := l_media_data.media_item_type;
    l_media_rec.media_item_ref := l_media_data.media_item_ref;
    l_media_rec.media_data := l_media_data.media_data;
  JTF_IH_PUB.Close_MediaItem( 1.0,
						'T',
						'F',
						TO_NUMBER(FND_PROFILE.VALUE('RESP_APPL_ID')),
						TO_NUMBER(FND_PROFILE.VALUE('RESP_ID')),
						nvl(TO_NUMBER (FND_PROFILE.VALUE('USER_ID')),-1),
						TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),
						l_ret_status,
						l_msg_count,
						l_msg_data,
						l_media_rec);
	EXCEPTION WHEN OTHERS THEN
		raise ERROR_CLOSING_MEDIA;
	END ;
	select * into l_header_rec from iem_ms_base_headers
	where message_id=p_message_id;
	select value into l_msg_text from iem_ms_msgbodys
	where message_id=p_message_id and rownum=1;
	for v1 in c1 loop
		l_top_intent:=v1.classification;
		exit;
	end loop;
	-- Insert Record into IEM_ARCH_MSG_DTLS
	IEM_ARCH_MSGDTLS_PVT.create_item(
		P_API_VERSION_NUMBER=>1.0,
 		P_INIT_MSG_LIST=>'F',
 		P_COMMIT=>'F',
 		P_message_id=>p_message_id,
		p_inbound_message_id=>null,
 		P_EMAIL_ACCOUNT_ID=>l_msg_rec.email_account_id,
 		P_MAILPROC_STATUS=>p_action_flag,
 		P_RT_CLASSIFICATION_ID=>l_msg_rec.rt_classification_id,
 		P_MAIL_TYPE=>0,
 		P_FROM_STR=>l_header_rec.from_str,
 		P_REPLY_TO_STR=>l_header_rec.reply_to_str,
 		P_TO_STR=>l_header_rec.to_str,
		P_CC_STR=>l_header_rec.cc_str,
		P_BCC_STR=>null,
 		P_SENT_DATE=>l_msg_rec.sent_date,
 		P_RECEIVED_DATE=>l_msg_rec.received_date,
 		P_SUBJECT=>l_msg_rec.subject,
 		P_AGENT_ID=>l_msg_rec.resource_id,
 		P_GROUP_ID=>l_msg_rec.group_id,
 		P_IH_MEDIA_ITEM_ID=>l_msg_rec.ih_media_item_id,
 		P_CUSTOMER_ID=>l_msg_rec.customer_id,
 		P_MESSAGE_SIZE=>null,
 		P_CONTACT_ID=>l_msg_rec.contact_id,
 		P_RELATIONSHIP_ID=>l_msg_rec.relationship_id,
 		P_TOP_INTENT=>l_top_intent,
 		P_MESSAGE_TEXT=>l_msg_text,
    		p_ATTRIBUTE1   =>null,
    		p_ATTRIBUTE2   =>null,
    		p_ATTRIBUTE3   =>null,
    		p_ATTRIBUTE4   =>null,
    		p_ATTRIBUTE5   =>null,
    		p_ATTRIBUTE6   =>null,
    		p_ATTRIBUTE7   =>null,
    		p_ATTRIBUTE8   =>null,
    		p_ATTRIBUTE9   =>null,
    		p_ATTRIBUTE10  =>null,
    		p_ATTRIBUTE11  =>null,
    		p_ATTRIBUTE12  =>null,
    		p_ATTRIBUTE13  =>null,
    		p_ATTRIBUTE14  =>null,
    		p_ATTRIBUTE15  =>null,
		x_message_id=>l_out_message_id,
 		X_RETURN_STATUS=>l_ret_status,
 		X_MSG_COUNT=>l_msg_count,
		 X_MSG_DATA=>l_msg_data);
	IF l_ret_status<>'S' THEN
		raise insert_arch_dtl_error;
	END IF;
	-- Delete All RUN TIME DATA and MESSAGE DATA FROM PRIMARY STORE
	delete from iem_rt_proc_emails where message_id=p_message_id;
	delete from iem_email_classifications where message_id=p_message_id;
	delete from iem_kb_results where message_id=p_message_id;
	delete from iem_ms_base_headers where message_id=p_message_id;
	delete from iem_ms_msgbodys where message_id=p_message_id;
	delete from iem_ms_msgparts where message_id=p_message_id;
	delete from iem_ms_exthdrs where message_id=p_message_id;

	-- Insert the MIME Message into Archived Message Stores
	insert into iem_arch_msgs(message_id,message_content,created_by,creation_date,last_updated_by,last_update_date,last_update_login)
	(
	select message_id,mime_msg,created_by,creation_date,last_updated_by,last_update_date,last_update_login from iem_ms_mimemsgs where message_id=p_message_id and draft_flag=0);
	delete from iem_ms_mimemsgs where message_id=p_message_id;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
	 ROLLBACK TO resolve_data_pvt;
      x_return_status := 'N';
	 FND_MESSAGE.SET_NAME('IEM', 'IEM_NO_DATA');
	 FND_MSG_PUB.ADD;
	 FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO resolve_data_pvt;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO resolve_data_pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
  WHEN ERROR_CLOSING_MEDIA THEN
	ROLLBACK TO resolve_data_pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN OTHERS THEN
	ROLLBACK TO resolve_data_pvt;
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
	end ResolvedMessage;
end IEM_MAILITEM_PUB ;

/
