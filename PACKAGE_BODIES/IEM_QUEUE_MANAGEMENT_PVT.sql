--------------------------------------------------------
--  DDL for Package Body IEM_QUEUE_MANAGEMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_QUEUE_MANAGEMENT_PVT" as
/* $Header: iemvqumb.pls 120.4.12010000.2 2008/10/16 09:23:46 shramana ship $*/
G_PKG_NAME		varchar2(100):='IEM_QUEUE_MANAGEMENT_PVT';
PROCEDURE search_messages_in_queue (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 := NULL,
		    	      p_commit	    IN   VARCHAR2 := NULL,
			      p_email_account_id in number,
			      p_classification_id in number,
			      p_subject		in	varchar2 :=NULL,
			      p_customer_name   in	varchar2 :=NULL,
			      p_sender_name	in	varchar2 :=NULL,
			      p_sent_date_from 	in	varchar2 :=NULL,
			      p_sent_date_to	in	varchar2 :=NULL,
			      p_sent_date_format in	varchar2 :=NULL,
			      p_group_id	 in	number,
			      p_sort_column	IN	number:=5,
			      p_sort_state	IN	varchar2 :=NULL,
			      x_message_tbl out nocopy message_tbl,
			      x_return_status	OUT	NOCOPY VARCHAR2,
  		  	      x_msg_count	OUT	NOCOPY   NUMBER,
	  	  	      x_msg_data	OUT	NOCOPY VARCHAR2) IS

	l_api_name        	VARCHAR2(255):='search_messages_in_queue';
	l_api_version_number 	NUMBER:=1.0;
	Type get_message_rec is REF CURSOR ;
	email_dtl_cur		get_message_rec;
	l_post_mdts		iem_queue_management_pvt.temp_message_type;
	l_party_name		hz_parties.party_name%type;
	l_string		varchar2(32767):='';
	l_query_string1		varchar2(15000):='';
	l_query_string2		varchar2(15000):='';
	l_sort_column           varchar2(500):='received_date'; -- default
	l_sort_order			varchar2(20):='desc'; -- default
	l_order_by		varchar2(500):='';
	l_classification_string varchar2(1000);
	l_subject_string	varchar2(1000);
	l_customer_string1	varchar2(1000);
	l_customer_string2 	varchar2(1000);
	l_sender_string 	varchar2(1000);
	l_received_date_to_string 	varchar2(1000);
	l_received_date_from_string varchar2(1000);
	l_close_string		varchar2(200);
	l_current_user    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('USER_ID')) ;
	l_agent_account_id NUMBER;
	l_all_groups		varchar2(400);

	l_index		number := 1;
	l_count		number;

	l_message_id   iem_rt_proc_emails.message_id%type;
        l_email_account_id iem_rt_proc_emails.email_account_id%type;
        l_sender_name iem_rt_proc_emails.from_address%type;
        l_subject iem_rt_proc_emails.subject%type;
        l_classification_name iem_route_classifications.name%type;
        l_customer_name hz_parties.party_name%type;
        l_received_date varchar2(500);
        l_real_received_date  iem_rt_proc_emails.received_date%type;
        l_message_uid iem_rt_proc_emails.message_id%type;
        l_group_name	jtf_rs_groups_tl.group_name%type;

	l_cursorID INTEGER;
   	l_dummy INTEGER;
BEGIN
	SAVEPOINT search_message_pvt;
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

	-- detemine sort column
	if (p_sort_column = 0) then
		l_sort_column := 'from_address';
	elsif (p_sort_column = 1) then
		l_sort_column := 'subject';
	elsif (p_sort_column = 2) then
		l_sort_column := 'classification_name';
	elsif (p_sort_column = 3) then
		l_sort_column := 'customer_name';
	elsif (p_sort_column = 4) then
		l_sort_column := 'group_name';
	else
		l_sort_column := 'real_received_date';
	end if;


	-- determine sort state
	if (p_sort_state = 'ascending') then
		l_sort_order := 'desc';
	else
		l_sort_order := 'asc';
	end if;

	if (l_sort_column = 'real_received_date') then
		l_order_by := ' order by ' || l_sort_column || ' ' || l_sort_order;
	else
		l_order_by := ' order by UPPER(' || l_sort_column || ') ' || l_sort_order || ', real_received_date asc';
	end if;

	l_all_groups := FND_MESSAGE.GET_STRING('IEM', 'IEM_ALL_GROUPS');

	if (p_customer_name is not null and p_group_id = 0) then

		l_query_string1 := 'select a.message_id, a.email_account_id, a.from_address, a.subject, b.name as classification_name,
		c.party_name as customer_name,
		to_char(a.received_date, ''MM/DD/RRRR HH24:MI:SS'') as received_date, a.received_date as real_received_date, a.message_id,
		replace(a.group_id, a.group_id, :all_groups) as group_name
		from iem_rt_proc_emails a, iem_route_classifications b, hz_parties c
		where a.resource_id = 0 and a.email_account_id=:email_account_id
 		and a.rt_classification_id=b.route_classification_id and a.customer_id=c.party_id and a.group_id=0 ';

		l_customer_string2 := ' and UPPER(c.party_name) like UPPER(:customer_name)';
		l_query_string1 := l_query_string1 || l_customer_string2;

	elsif (p_customer_name is not null and p_group_id <> -1) then

 		l_query_string1 := 'select a.message_id, a.email_account_id, a.from_address, a.subject, b.name as classification_name,
		c.party_name as customer_name, to_char(a.received_date, ''MM/DD/RRRR HH24:MI:SS'') as received_date, a.received_date as real_received_date, a.message_id, d.group_name
		from iem_rt_proc_emails a, iem_route_classifications b, hz_parties c, jtf_rs_groups_tl d
		where a.resource_id = 0 and a.email_account_id=:email_account_id
 		and a.rt_classification_id=b.route_classification_id and a.customer_id=c.party_id
 		and a.group_id=d.group_id and d.language=userenv(''LANG'') and d.group_id=:group_id';

		l_customer_string2 := ' and UPPER(c.party_name) like UPPER(:customer_name)';
		l_query_string1 := l_query_string1 || l_customer_string2;

	elsif (p_customer_name is not null and p_group_id = -1) then

		l_query_string1 := 'select a.message_id, a.email_account_id, a.from_address, a.subject, b.name as classification_name,
		c.party_name as customer_name,
		to_char(a.received_date, ''MM/DD/RRRR HH24:MI:SS'') as received_date, a.received_date as real_received_date, a.message_id,
		decode(a.group_id, 0, :all_groups, ( select group_name from jtf_rs_groups_tl where language=userenv(''LANG'') and group_id= a.group_id) ) as group_name
		from iem_rt_proc_emails a, iem_route_classifications b, hz_parties c
		where a.resource_id = 0 and a.email_account_id=:email_account_id
 		and a.rt_classification_id=b.route_classification_id and a.customer_id=c.party_id ';

		l_customer_string2 := ' and UPPER(c.party_name) like UPPER(:customer_name)';
		l_query_string1 := l_query_string1 || l_customer_string2;

 	elsif (p_customer_name is null and p_group_id = 0) then

		l_query_string1 := 'select a.message_id, a.email_account_id, a.from_address, a.subject, b.name as classification_name,
		decode(a.customer_id, -1, '''', 0, '''', (select party_name from hz_parties where party_id=a.customer_id) ) as customer_name,
		to_char(a.received_date, ''MM/DD/RRRR HH24:MI:SS'') as received_date, a.received_date as real_received_date, a.message_id,
		replace(a.group_id, a.group_id, :all_groups) as group_name
		from iem_rt_proc_emails a, iem_route_classifications b
		where a.resource_id = 0 and a.email_account_id=:email_account_id
 		and a.rt_classification_id=b.route_classification_id
 		and a.group_id=0';
 	elsif (p_customer_name is null and p_group_id <> -1) then

 		l_query_string1 := 'select a.message_id, a.email_account_id, a.from_address, a.subject, b.name as classification_name,
		decode(a.customer_id, -1, '''', 0, '''', (select party_name from hz_parties where party_id=a.customer_id) ) as customer_name,
		to_char(a.received_date, ''MM/DD/RRRR HH24:MI:SS'') as received_date, a.received_date as real_received_date, a.message_id, d.group_name
		from iem_rt_proc_emails a, iem_route_classifications b, jtf_rs_groups_tl d
		where a.resource_id = 0 and a.email_account_id=:email_account_id
 		and a.rt_classification_id=b.route_classification_id
 		and a.group_id=d.group_id and d.language=userenv(''LANG'') and d.group_id=:group_id';
 	else

 		l_query_string1 := 'select a.message_id, a.email_account_id, a.from_address, a.subject, b.name as classification_name,
		decode(a.customer_id, -1, '''', 0, '''', (select party_name from hz_parties where party_id=a.customer_id) ) as customer_name,
		to_char(a.received_date, ''MM/DD/RRRR HH24:MI:SS'') as received_date, a.received_date as real_received_date, a.message_id,
		decode(a.group_id, 0, :all_groups, ( select group_name from jtf_rs_groups_tl where language=userenv(''LANG'') and group_id= a.group_id) ) as group_name
		from iem_rt_proc_emails a, iem_route_classifications b
		where a.resource_id = 0 and a.email_account_id=:email_account_id
 		and a.rt_classification_id=b.route_classification_id';
 	end if;

	-- detemine query string
	if (p_classification_id <> -1) then

		l_classification_string := ' and a.rt_classification_id=:classification_id';
		l_query_string1 := l_query_string1 || l_classification_string;
	end if;
	if (p_subject is not null) then

		l_subject_string := ' and UPPER(a.subject) like UPPER(:subject)';
		l_query_string1 := l_query_string1 || l_subject_string;
	end if;
	if (p_sender_name is not null) then

		l_sender_string := ' and UPPER(a.from_address) like UPPER(:sender_name)';
		l_query_string1 := l_query_string1 || l_sender_string;
	end if;
	if (p_sent_date_to is not null) then

		l_received_date_to_string := ' and a.received_date < to_date(:received_date_to, :received_date_format)';
	 	l_query_string1 := l_query_string1 || l_received_date_to_string;
	end if;
	if (p_sent_date_from is not null) then

		l_received_date_from_string := ' and a.received_date > to_date(:received_date_from, :received_date_format)';
	 	l_query_string1 := l_query_string1 || l_received_date_from_string;
	end if;

	l_close_string := l_order_by;
	l_string := l_query_string1 || l_close_string;

 	l_cursorID := DBMS_SQL.OPEN_CURSOR;
	DBMS_SQL.PARSE(l_cursorID, l_string, DBMS_SQL.native);

	if (p_classification_id <> -1) then
		DBMS_SQL.BIND_VARIABLE(l_cursorID, ':classification_id', p_classification_id);
	end if;
	if (p_subject is not null) then
		DBMS_SQL.BIND_VARIABLE(l_cursorID, ':subject', p_subject);
	end if;
	if (p_sender_name is not null) then
		DBMS_SQL.BIND_VARIABLE(l_cursorID, ':sender_name', p_sender_name);
	end if;
	if (p_sent_date_to is not null) then
		DBMS_SQL.BIND_VARIABLE(l_cursorID, ':received_date_to', p_sent_date_to);
		DBMS_SQL.BIND_VARIABLE(l_cursorID, ':received_date_format', p_sent_date_format);
	end if;
	if (p_sent_date_from is not null) then
		DBMS_SQL.BIND_VARIABLE(l_cursorID, ':received_date_from', p_sent_date_from);
		DBMS_SQL.BIND_VARIABLE(l_cursorID, ':received_date_format', p_sent_date_format);
	end if;
	if (p_customer_name is not null) then
		DBMS_SQL.BIND_VARIABLE(l_cursorID, ':customer_name', p_customer_name);
	end if;
	if (p_group_id <> -1 and p_group_id <> 0) then
		DBMS_SQL.BIND_VARIABLE(l_cursorID, ':group_id', p_group_id);
	else
		DBMS_SQL.BIND_VARIABLE(l_cursorID, ':all_groups', l_all_groups);
	end if;

	DBMS_SQL.BIND_VARIABLE(l_cursorID, ':email_account_id', p_email_account_id);

	DBMS_SQL.DEFINE_COLUMN(l_cursorID, 1, l_message_id);
	DBMS_SQL.DEFINE_COLUMN(l_cursorID, 2, l_email_account_id);
	DBMS_SQL.DEFINE_COLUMN(l_cursorID, 3, l_sender_name, 256);
	DBMS_SQL.DEFINE_COLUMN(l_cursorID, 4, l_subject, 2000);
	DBMS_SQL.DEFINE_COLUMN(l_cursorID, 5, l_classification_name, 30);
	DBMS_SQL.DEFINE_COLUMN(l_cursorID, 6, l_customer_name, 360);
	DBMS_SQL.DEFINE_COLUMN(l_cursorID, 7, l_received_date, 500);
	DBMS_SQL.DEFINE_COLUMN(l_cursorID, 8, l_real_received_date);
	DBMS_SQL.DEFINE_COLUMN(l_cursorID, 9, l_message_uid);
	DBMS_SQL.DEFINE_COLUMN(l_cursorID, 10, l_group_name, 60);

	l_dummy := DBMS_SQL.EXECUTE(l_cursorID);


LOOP
--    IF (DBMS_SQL.FETCH_ROWS(l_cursorID) = 0 or l_index >500) THEN
     IF (DBMS_SQL.FETCH_ROWS(l_cursorID) = 0) THEN
        EXIT;
     END IF;

     DBMS_SQL.COLUMN_VALUE(l_cursorID, 1, l_message_id);
     DBMS_SQL.COLUMN_VALUE(l_cursorID, 2, l_email_account_id);
     DBMS_SQL.COLUMN_VALUE(l_cursorID, 3, l_sender_name);
     DBMS_SQL.COLUMN_VALUE(l_cursorID, 4, l_subject);
     DBMS_SQL.COLUMN_VALUE(l_cursorID, 5, l_classification_name);
     DBMS_SQL.COLUMN_VALUE(l_cursorID, 6, l_customer_name);
     DBMS_SQL.COLUMN_VALUE(l_cursorID, 7, l_received_date);
     DBMS_SQL.COLUMN_VALUE(l_cursorID, 8, l_real_received_date);
     DBMS_SQL.COLUMN_VALUE(l_cursorID, 9, l_message_uid);
     DBMS_SQL.COLUMN_VALUE(l_cursorID, 10, l_group_name);

		x_message_tbl(l_index).message_id := l_message_id;
		x_message_tbl(l_index).email_account_id := l_email_account_id;
		x_message_tbl(l_index).sender_name := l_sender_name;
		x_message_tbl(l_index).subject := l_subject;
	 	x_message_tbl(l_index).sent_date :=l_received_date;
	 	x_message_tbl(l_index).real_received_date :=l_real_received_date;
		x_message_tbl(l_index).classification_name := l_classification_name;
		x_message_tbl(l_index).customer_name := l_customer_name;
		x_message_tbl(l_index).message_uid := l_message_uid;
		x_message_tbl(l_index).group_name := l_group_name;

	--	l_current_user := 1000691;

		Begin
			select a.agent_id into l_agent_account_id from iem_agents a, jtf_rs_resource_extns b
			where a.resource_id=b.resource_id and b.user_id=l_current_user and a.email_account_id=l_post_mdts.email_account_id;
		Exception
		  	WHEN NO_DATA_FOUND THEN
		  		l_agent_account_id := 0;
		End;

		x_message_tbl(l_index).agent_account_id := l_agent_account_id;

		l_index := l_index + 1;


END LOOP;

DBMS_SQL.CLOSE_CURSOR(l_cursorID);

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
	ROLLBACK TO search_message_pvt;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO search_message_pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	ROLLBACK TO search_message_pvt;
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
    		(p_count         	=>      x_msg_count,
        	p_data          	=>      x_msg_data
    		);

END search_messages_in_queue;

PROCEDURE get_total_count_in_queue (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 := NULL,
		    	      p_commit	    IN   VARCHAR2 := NULL,
			      p_email_account_id in number,
			      p_classification_id in number,
			      p_subject		in	varchar2 :=NULL,
			      p_customer_name   in	varchar2 :=NULL,
			      p_sender_name	in	varchar2 :=NULL,
			      p_sent_date_from 	in	varchar2 :=NULL,
			      p_sent_date_to	in	varchar2 :=NULL,
			      p_sent_date_format in	varchar2 :=NULL,
			      p_group_id	 in	number,
			      x_message_count   out     NOCOPY number,
			      x_return_status	OUT	NOCOPY VARCHAR2,
  		  	      x_msg_count	OUT	NOCOPY NUMBER,
	  	  	      x_msg_data	OUT	NOCOPY VARCHAR2) IS

	l_api_name        	VARCHAR2(255):='get_total_count_in_queue';
	l_api_version_number 	NUMBER:=1.0;
	Type get_message_rec is REF CURSOR ;
	email_dtl_cur		get_message_rec;
	l_post_mdts		iem_queue_management_pvt.temp_message_type;
	l_classification_name   iem_route_classifications.name%type;
	l_party_name		hz_parties.party_name%type;
	l_received_date		varchar2(500);
	l_string		varchar2(32767):='';
	l_query_string1		varchar2(15000):='';
	l_query_string2		varchar2(15000):='';
	l_classification_string varchar2(1000);
	l_subject_string	varchar2(1000);
	l_customer_string1	varchar2(1000);
	l_customer_string2 	varchar2(1000);
	l_sender_string 	varchar2(1000);
	l_received_date_to_string 	varchar2(1000);
	l_received_date_from_string varchar2(1000);
	l_close_string		varchar2(200);
	l_current_user    NUMBER:=TO_NUMBER (FND_PROFILE.VALUE('USER_ID')) ;
	l_agent_account_id NUMBER;
	l_message_count		NUMBER;

	l_index		number := 1;
	l_count		number;
	l_subject	varchar2(240);
	l_customer_name	varchar2(360);
	l_sender_name	varchar2(128);

	l_cursorID INTEGER;
   	l_dummy INTEGER;
BEGIN

	SAVEPOINT get_total_count_pvt;
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

	if (p_customer_name is not null and p_group_id <> -1) then
 		l_query_string1 := 'select count(*)
		from iem_rt_proc_emails a, iem_route_classifications b, hz_parties c
		where a.resource_id = 0 and a.email_account_id=:email_account_id
 		and a.rt_classification_id=b.route_classification_id and a.customer_id=c.party_id
 		and a.group_id=:group_id';

		l_customer_string2 := ' and UPPER(c.party_name) like UPPER(:customer_name)';
		l_query_string1 := l_query_string1 || l_customer_string2;

	elsif (p_customer_name is not null and p_group_id = -1) then
		l_query_string1 := 'select count(*)
		from iem_rt_proc_emails a, iem_route_classifications b, hz_parties c
		where a.resource_id = 0 and a.email_account_id=:email_account_id
 		and a.rt_classification_id=b.route_classification_id and a.customer_id=c.party_id ';

		l_customer_string2 := ' and UPPER(c.party_name) like UPPER(:customer_name)';
		l_query_string1 := l_query_string1 || l_customer_string2;

 	elsif (p_customer_name is null and p_group_id <> -1) then
 		l_query_string1 := 'select count(*)
		from iem_rt_proc_emails a, iem_route_classifications b
		where a.resource_id = 0 and a.email_account_id=:email_account_id
 		and a.rt_classification_id=b.route_classification_id
 		and a.group_id=:group_id';
 	else
 		l_query_string1 := 'select count(*)
		from iem_rt_proc_emails a, iem_route_classifications b
		where a.resource_id = 0 and a.email_account_id=:email_account_id
 		and a.rt_classification_id=b.route_classification_id';
 	end if;

	-- detemine query string
	if (p_classification_id <> -1) then
		l_classification_string := ' and a.rt_classification_id=:classification_id';
		l_query_string1 := l_query_string1 || l_classification_string;
	end if;
	if (p_subject is not null) then
		l_subject_string := ' and UPPER(a.subject) like UPPER(:subject)';
		l_query_string1 := l_query_string1 || l_subject_string;
	end if;
	if (p_sender_name is not null) then
		l_sender_string := ' and UPPER(a.from_address) like UPPER(:sender_name)';
		l_query_string1 := l_query_string1 || l_sender_string;
	end if;
	if (p_sent_date_to is not null) then
		l_received_date_to_string := ' and a.received_date < to_date(:received_date_to, :received_date_format)';
	 	l_query_string1 := l_query_string1 || l_received_date_to_string;
	end if;
	if (p_sent_date_from is not null) then
		l_received_date_from_string := ' and a.received_date > to_date(:received_date_from, :received_date_format)';
	 	l_query_string1 := l_query_string1 || l_received_date_from_string;
	end if;

	l_string := l_query_string1;

	l_cursorID := DBMS_SQL.OPEN_CURSOR;
	DBMS_SQL.PARSE(l_cursorID, l_string, DBMS_SQL.native);

	if (p_classification_id <> -1) then
		DBMS_SQL.BIND_VARIABLE(l_cursorID, ':classification_id', p_classification_id);
	end if;
	if (p_subject is not null) then
		DBMS_SQL.BIND_VARIABLE(l_cursorID, ':subject', p_subject);
	end if;
	if (p_sender_name is not null) then
		DBMS_SQL.BIND_VARIABLE(l_cursorID, ':sender_name', p_sender_name);
	end if;
	if (p_sent_date_to is not null) then
		DBMS_SQL.BIND_VARIABLE(l_cursorID, ':received_date_to', p_sent_date_to);
		DBMS_SQL.BIND_VARIABLE(l_cursorID, ':received_date_format', p_sent_date_format);
	end if;
	if (p_sent_date_from is not null) then
		DBMS_SQL.BIND_VARIABLE(l_cursorID, ':received_date_from', p_sent_date_from);
		DBMS_SQL.BIND_VARIABLE(l_cursorID, ':received_date_format', p_sent_date_format);
	end if;
	if (p_customer_name is not null) then
		DBMS_SQL.BIND_VARIABLE(l_cursorID, ':customer_name', p_customer_name);
	end if;
	if (p_group_id <> -1) then
		DBMS_SQL.BIND_VARIABLE(l_cursorID, ':group_id', p_group_id);
	end if;

	DBMS_SQL.BIND_VARIABLE(l_cursorID, ':email_account_id', p_email_account_id);

	DBMS_SQL.DEFINE_COLUMN(l_cursorID, 1, l_message_count);

	l_dummy := DBMS_SQL.EXECUTE(l_cursorID);

    	IF DBMS_SQL.FETCH_ROWS(l_cursorID) <> 0 THEN
     		DBMS_SQL.COLUMN_VALUE(l_cursorID, 1, l_message_count);
     		x_message_count := l_message_count;
    	 END IF;


DBMS_SQL.CLOSE_CURSOR(l_cursorID);
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
	ROLLBACK TO get_total_count_pvt;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO get_total_count_pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	ROLLBACK TO get_total_count_pvt;
      	x_return_status := FND_API.G_RET_STS_ERROR;
	IF FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME,
    	    			l_api_name
	    		);
		END IF;
	FND_MSG_PUB.Count_And_Get
    		(p_count         	=>      x_msg_count,
        	p_data          	=>      x_msg_data
    		);

END get_total_count_in_queue;



PROCEDURE show_agent_list (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 := NULL,
		    	      p_commit	    IN   VARCHAR2 := NULL,
			      p_email_account_id in number,
			      p_sort_column	IN	number,
			      p_sort_state	IN	varchar2,
			      x_resource_count out nocopy resource_count_tbl,
			      x_return_status	OUT	NOCOPY VARCHAR2,
  		  	      x_msg_count	OUT	NOCOPY   NUMBER,
	  	  	      x_msg_data	OUT	NOCOPY VARCHAR2) IS

l_api_name        	VARCHAR2(255):='show_agent_list';
l_api_version_number 	NUMBER:=1.0;
l_index		number := 1;
l_count		number;
l_resource_name varchar2(720);
l_last_login_time varchar2(500);
l_real_last_login_time date;
l_resource_id 	number;
l_fetched_emails number;
l_string		varchar2(32767):='';
l_string2		varchar2(32767):='';
l_order_by		varchar2(500):='';
l_sort_column           varchar2(500):='resource_name'; -- default
l_sort_order			varchar2(20):='asc'; -- default
Type get_message_rec is REF CURSOR ;
email_dtl_cur		get_message_rec;

l_cursorID INTEGER;
l_dummy INTEGER;

BEGIN

	SAVEPOINT show_agent_list_pvt;
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

	-- determine sort state
	if (p_sort_state = 'ascending') then
		l_sort_order := 'desc';
	else
		l_sort_order := 'asc';
	end if;

	l_cursorID := DBMS_SQL.OPEN_CURSOR;

	if (p_sort_column = 2) then

    		l_string := 'select resource_id, resource_name, last_login_time, real_last_login_time from (
    			select a.resource_id, concat(concat(rs.source_last_name, '', ''), rs.source_first_name) as resource_name,
			to_char(max(c.begin_date_time), ''MM/DD/RRRR HH24:MI:SS'') as last_login_time, max(c.begin_date_time) as real_last_login_time
			from iem_agents a, jtf_rs_resource_extns rs, ieu_sh_sessions c
			where a.resource_id = rs.resource_id and a.resource_id=c.resource_id
			and a.email_account_id =:email_account_id and c.application_id=680
            		and trunc(sysdate) between trunc(nvl(rs.start_date_active, sysdate))
    			and trunc(nvl(rs.end_date_active, sysdate))
            		and rs.user_id in
            		( select respgrp.user_id from fnd_user_resp_groups respgrp, fnd_user fu, fnd_responsibility resp
            		where respgrp.user_id = fu.user_id
            		and respgrp.responsibility_id=resp.responsibility_id and resp.application_id=680
            		and (resp.responsibility_key = ''EMAIL_CENTER_SUPERVISOR'' or resp.responsibility_key = ''IEM_SA_AGENT'')
            		and trunc(sysdate) between trunc(nvl(respgrp.start_date, sysdate))
    			and trunc(nvl(respgrp.end_date, sysdate))
            		and trunc(sysdate) between trunc(nvl(fu.start_date, sysdate))
    			and trunc(nvl(fu.end_date, sysdate))
            		)
            		and rs.resource_id in ( select unique rel.role_resource_id from jtf_rs_role_relations rel where
            		rel.role_id in (28, 29, 30) and rel.delete_flag = ''N''
            		and rel.role_resource_type = ''RS_INDIVIDUAL''
            		and trunc(sysdate) between trunc(nvl(rel.start_date_active, sysdate))
      	     		and trunc(nvl(rel.end_date_active, sysdate)) ) ';

     	l_string2 := ' group by a.resource_id, rs.source_last_name, rs.source_first_name
    			 union all
    			select a.resource_id, concat(concat(rs.source_last_name, '', ''), rs.source_first_name) as resource_name
			, '''' as last_login_time, to_date('''', ''dd-mon-yy'') as real_last_login_time
			from iem_agents a, jtf_rs_resource_extns rs
			where a.resource_id = rs.resource_id and a.email_account_id = :email_account_id
            		and trunc(sysdate) between trunc(nvl(rs.start_date_active, sysdate))
    			and trunc(nvl(rs.end_date_active, sysdate))
           		and rs.user_id in
            		( select respgrp.user_id from fnd_user_resp_groups respgrp, fnd_user fu, fnd_responsibility resp
            		where respgrp.user_id = fu.user_id
            		and respgrp.responsibility_id=resp.responsibility_id and resp.application_id=680
            		and (resp.responsibility_key = ''EMAIL_CENTER_SUPERVISOR'' or resp.responsibility_key = ''IEM_SA_AGENT'')
            		and trunc(sysdate) between trunc(nvl(respgrp.start_date, sysdate))
    			and trunc(nvl(respgrp.end_date, sysdate))
            		and trunc(sysdate) between trunc(nvl(fu.start_date, sysdate))
    			and trunc(nvl(fu.end_date, sysdate))
            		)
            		and rs.resource_id in ( select unique rel.role_resource_id from jtf_rs_role_relations rel where
            		rel.role_id in (28, 29, 30) and rel.delete_flag = ''N''
            		and rel.role_resource_type = ''RS_INDIVIDUAL''
            		and trunc(sysdate) between trunc(nvl(rel.start_date_active, sysdate))
      	     		and trunc(nvl(rel.end_date_active, sysdate)) )
	 		and a.resource_id not in
    			(select a.resource_id from iem_agents a, ieu_sh_sessions b where b.application_id=680 and
    			a.resource_id=b.resource_id and a.email_account_id =:email_account_id ) ) order by real_last_login_time ';

    			l_string := l_string || l_string2 || l_sort_order;

		DBMS_SQL.PARSE(l_cursorID, l_string, DBMS_SQL.native);

		DBMS_SQL.BIND_VARIABLE(l_cursorID, ':email_account_id', p_email_account_id);

		DBMS_SQL.DEFINE_COLUMN(l_cursorID, 1, l_resource_id);
		DBMS_SQL.DEFINE_COLUMN(l_cursorID, 2, l_resource_name, 722);
		DBMS_SQL.DEFINE_COLUMN(l_cursorID, 3, l_last_login_time, 128);
		DBMS_SQL.DEFINE_COLUMN(l_cursorID, 4, l_real_last_login_time);

		l_dummy := DBMS_SQL.EXECUTE(l_cursorID);

		LOOP
    			IF (DBMS_SQL.FETCH_ROWS(l_cursorID) = 0) THEN
        			EXIT;
    			END IF;

     			DBMS_SQL.COLUMN_VALUE(l_cursorID, 1, l_resource_id);
     			DBMS_SQL.COLUMN_VALUE(l_cursorID, 2, l_resource_name);
     			DBMS_SQL.COLUMN_VALUE(l_cursorID, 3, l_last_login_time);
     			DBMS_SQL.COLUMN_VALUE(l_cursorID, 4, l_real_last_login_time);

	 	     select count(*) into l_fetched_emails from iem_rt_proc_emails a
	 	     where a.email_account_id=p_email_account_id and a.queue_status is null and a.resource_id = l_resource_id;

	 	     x_resource_count(l_index).resource_id :=l_resource_id;
	 	     x_resource_count(l_index).resource_name := l_resource_name;
	 	     x_resource_count(l_index).email_count := l_fetched_emails;
	 	     x_resource_count(l_index).last_login_time := l_last_login_time;

	 	     l_index := l_index + 1;
 		END LOOP;

 	else
   		--  p_sort_column=0 or 1

   		if (p_sort_column = 1) then
			l_sort_column := 'fetched_emails';
		else
			l_sort_column := 'resource_name';
		end if;

		if (l_sort_column = 'fetched_emails') then
			l_order_by := ' order by ' || l_sort_column || ' ' || l_sort_order;
		else
			l_order_by := ' order by UPPER(' || l_sort_column || ') ' || l_sort_order;
		end if;

		l_string := 'select resource_id, fetched_emails, resource_name from
			( SELECT agact.resource_id, count(*) fetched_emails, concat(concat(rs.source_last_name, '',''), rs.source_first_name) as resource_name
			from iem_agents agact, iem_rt_proc_emails pm, jtf_rs_resource_extns rs
            		 WHERE pm.resource_id=agact.resource_id
			and agact.resource_id = rs.resource_id
            		and pm.email_account_id=agact.email_account_id and pm.queue_status is null
			and agact.email_account_id=:email_account_id
            		and trunc(sysdate) between trunc(nvl(rs.start_date_active, sysdate))
    			and trunc(nvl(rs.end_date_active, sysdate))
            		and rs.user_id in
            		( select respgrp.user_id from fnd_user_resp_groups respgrp, fnd_user fu, fnd_responsibility resp
            		where respgrp.user_id = fu.user_id
            		and respgrp.responsibility_id=resp.responsibility_id and resp.application_id=680
            		and (resp.responsibility_key = ''EMAIL_CENTER_SUPERVISOR'' or resp.responsibility_key = ''IEM_SA_AGENT'')
            		and trunc(sysdate) between trunc(nvl(respgrp.start_date, sysdate))
    			and trunc(nvl(respgrp.end_date, sysdate))
            		and trunc(sysdate) between trunc(nvl(fu.start_date, sysdate))
    			and trunc(nvl(fu.end_date, sysdate))
            		)
            		and rs.resource_id in ( select unique rel.role_resource_id from jtf_rs_role_relations rel where
           		 rel.role_id in (28, 29, 30) and rel.delete_flag = ''N''
            		and rel.role_resource_type = ''RS_INDIVIDUAL''
            		and trunc(sysdate) between trunc(nvl(rel.start_date_active, sysdate))
      	     		and trunc(nvl(rel.end_date_active, sysdate)) )
		 	group by agact.resource_id, rs.source_last_name, rs.source_first_name ';

	l_string2 := ' union all SELECT agact.resource_id, 0, concat(concat(rs.source_last_name, '', ''), rs.source_first_name) as resource_name
			from iem_agents agact, jtf_rs_resource_extns rs
			WHERE  agact.resource_id = rs.resource_id
			and agact.email_account_id=:email_account_id
            		and trunc(sysdate) between trunc(nvl(rs.start_date_active, sysdate))
    			and trunc(nvl(rs.end_date_active, sysdate))
            		and rs.user_id in
            		( select respgrp.user_id from fnd_user_resp_groups respgrp, fnd_user fu, fnd_responsibility resp
            		where respgrp.user_id = fu.user_id
            		and respgrp.responsibility_id=resp.responsibility_id and resp.application_id=680
            		and (resp.responsibility_key = ''EMAIL_CENTER_SUPERVISOR'' or resp.responsibility_key = ''IEM_SA_AGENT'')
            		and trunc(sysdate) between trunc(nvl(respgrp.start_date, sysdate))
    			and trunc(nvl(respgrp.end_date, sysdate))
            		and trunc(sysdate) between trunc(nvl(fu.start_date, sysdate))
    			and trunc(nvl(fu.end_date, sysdate))
            		)
            		and rs.resource_id in ( select unique rel.role_resource_id from jtf_rs_role_relations rel where
            		rel.role_id in (28, 29, 30) and rel.delete_flag = ''N''
            		and rel.role_resource_type = ''RS_INDIVIDUAL''
            		and trunc(sysdate) between trunc(nvl(rel.start_date_active, sysdate))
      	     		and trunc(nvl(rel.end_date_active, sysdate)) )
 			and agact.resource_id not in (select pm.resource_id from iem_rt_proc_emails pm
 			where pm.email_account_id=:email_account_id and pm.queue_status is null) ) ';

			l_string := l_string || l_string2 || l_order_by;

		DBMS_SQL.PARSE(l_cursorID, l_string, DBMS_SQL.native);

		DBMS_SQL.BIND_VARIABLE(l_cursorID, ':email_account_id', p_email_account_id);

		DBMS_SQL.DEFINE_COLUMN(l_cursorID, 1, l_resource_id);
		DBMS_SQL.DEFINE_COLUMN(l_cursorID, 2, l_fetched_emails);
		DBMS_SQL.DEFINE_COLUMN(l_cursorID, 3, l_resource_name, 722);

		l_dummy := DBMS_SQL.EXECUTE(l_cursorID);

		LOOP
    			IF (DBMS_SQL.FETCH_ROWS(l_cursorID) = 0) THEN
        			EXIT;
    			END IF;

     			DBMS_SQL.COLUMN_VALUE(l_cursorID, 1, l_resource_id);
     			DBMS_SQL.COLUMN_VALUE(l_cursorID, 2, l_fetched_emails);
     			DBMS_SQL.COLUMN_VALUE(l_cursorID, 3, l_resource_name);

		   select to_char(max(begin_date_time), 'MM/DD/RRRR HH24:MI:SS') into l_last_login_time
	 	    from ieu_sh_sessions where application_id=680 and resource_id=l_resource_id;

	 	    x_resource_count(l_index).resource_id :=l_resource_id;
	 	    x_resource_count(l_index).resource_name := l_resource_name;
	 	    x_resource_count(l_index).email_count := l_fetched_emails;
	 	    x_resource_count(l_index).last_login_time := l_last_login_time;

	 	    l_index := l_index + 1;

 		END LOOP;
 	end if; -- if p_sort_column=2

 	DBMS_SQL.CLOSE_CURSOR(l_cursorID);

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
	ROLLBACK TO show_agent_list_pvt;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO show_agent_list_pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	ROLLBACK TO show_agent_list_pvt;
      	x_return_status := FND_API.G_RET_STS_ERROR;
	IF FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME,
    	    			l_api_name
	    		);
		END IF;
	FND_MSG_PUB.Count_And_Get
    		(p_count         	=>      x_msg_count,
        	p_data          	=>      x_msg_data
    		);


END show_agent_list;

PROCEDURE show_resource_group_list (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2,
		    	      p_commit	    IN   VARCHAR2,
			      p_email_account_id in number,
			      p_sort_column	IN	number,
			      p_sort_state	IN	varchar2,
			      x_resource_group_count out nocopy resource_group_count_tbl,
			      x_return_status	OUT	NOCOPY VARCHAR2,
  		  	      x_msg_count	OUT	NOCOPY   NUMBER,
	  	  	      x_msg_data	OUT	NOCOPY VARCHAR2) IS

l_api_name        	VARCHAR2(255):='show_resource_group_list';
l_api_version_number 	NUMBER:=1.0;
l_index		number := 1;
l_count		number;
l_group_name varchar2(720);
l_group_id 	number;
l_email_count 	number;
l_agent_count	number;
l_email_account_id varchar2(30);
l_string		varchar2(32767):='';
l_order_by		varchar2(500):='';
l_sort_column           varchar2(500):='group_name'; -- default
l_sort_order			varchar2(20):='asc'; -- default
Type get_message_rec is REF CURSOR ;
email_dtl_cur		get_message_rec;

l_cursorID INTEGER;
l_dummy INTEGER;

BEGIN
	SAVEPOINT show_resource_group_list_pvt;
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

	-- determine sort state
	if (p_sort_state = 'ascending') then
		l_sort_order := 'desc';
	else
		l_sort_order := 'asc';
	end if;

	if (p_email_account_id is not null) then
		l_email_account_id := to_char(p_email_account_id);
	end if;

	l_cursorID := DBMS_SQL.OPEN_CURSOR;

	if (p_sort_column = 1) then

  		l_string := 'select group_id, group_name, email_count from(
  				select f.group_id, e.group_name, count(*) as email_count from iem_rt_proc_emails f, jtf_rs_groups_vl e where
  				trunc(sysdate) between trunc(nvl(e.start_date_active, sysdate))
      	        		and trunc(nvl(e.end_date_active, sysdate))
  				and f.group_id=e.group_id and  f.resource_id=0 and f.email_account_id=:email_account_id and f.group_id in (
  				select unique c.group_id from
				jtf_rs_group_members c, iem_agents d, jtf_rs_group_usages gu
				 where
				c.delete_flag = ''N'' and c.resource_id = d.resource_id and d.email_account_id =:l_email_account_id
                		and c.group_id = gu.group_id and gu.usage = ''CALL''
            			 ) group by f.group_id, e.group_name
  				union all
  				select unique e.group_id, group_name, 0 from
				jtf_rs_group_members c, iem_agents d, jtf_rs_groups_vl e,
                		jtf_rs_group_usages gu where
				c.group_id = e.group_id
				and c.delete_flag = ''N'' and c.resource_id = d.resource_id and d.email_account_id =:l_email_account_id
				and trunc(sysdate) between trunc(nvl(e.start_date_active, sysdate))
      	        		and trunc(nvl(e.end_date_active, sysdate))
      	        		and c.group_id = gu.group_id and gu.usage = ''CALL''
                 		and e.group_id not in (
 					select unique group_id from iem_rt_proc_emails where email_account_id=:email_account_id
 				 	and group_id<>0 and resource_id=0)
  				) order by email_count ';

  		l_string := l_string || l_sort_order;

		DBMS_SQL.PARSE(l_cursorID, l_string, DBMS_SQL.native);

		DBMS_SQL.BIND_VARIABLE(l_cursorID, ':email_account_id', p_email_account_id);
		DBMS_SQL.BIND_VARIABLE(l_cursorID, ':l_email_account_id', l_email_account_id);
		DBMS_SQL.BIND_VARIABLE(l_cursorID, ':l_email_account_id', l_email_account_id);
		DBMS_SQL.BIND_VARIABLE(l_cursorID, ':email_account_id', p_email_account_id);

		DBMS_SQL.DEFINE_COLUMN(l_cursorID, 1, l_group_id);
		DBMS_SQL.DEFINE_COLUMN(l_cursorID, 2, l_group_name, 60);
		DBMS_SQL.DEFINE_COLUMN(l_cursorID, 3, l_email_count);

		l_dummy := DBMS_SQL.EXECUTE(l_cursorID);

		LOOP

    			IF (DBMS_SQL.FETCH_ROWS(l_cursorID) = 0) THEN
        			EXIT;
    			END IF;

     			DBMS_SQL.COLUMN_VALUE(l_cursorID, 1, l_group_id);
     			DBMS_SQL.COLUMN_VALUE(l_cursorID, 2, l_group_name);
     			DBMS_SQL.COLUMN_VALUE(l_cursorID, 3, l_email_count);

		    -- Start changes for bug no. 7418671
		    --select count(*) into l_agent_count from jtf_rs_roles_tl a, jtf_rs_role_relations b, jtf_rs_group_members c, iem_agents d
 		    --where a.role_id in (28, 29, 30) and a.language = USERENV ('LANG') and a.role_id = b.role_id and b.delete_flag = 'N'
 		    --and b.role_resource_id = c.resource_id and c.delete_flag = 'N' and c.resource_id = d.resource_id
 		    --and d.email_account_id = l_email_account_id and c.group_id = l_group_id;
		    SELECT count(*) into l_agent_count
		    FROM jtf_rs_group_members c, iem_agents d
		    WHERE  c.resource_id IN
			(select b.role_resource_id from jtf_rs_role_relations b
			 where b.role_resource_id=c.resource_id and b.role_id IN (28,29,30)
			 AND b.delete_flag='N'
			 AND TRUNC(sysdate) BETWEEN TRUNC(NVL(b.start_date_active, sysdate))
			 AND TRUNC(NVL(b.end_date_active, sysdate)))
		    AND c.delete_flag      = 'N'
		    AND c.resource_id      = d.resource_id
		    AND d.email_account_id = l_email_account_id
		    AND c.group_id         = l_group_id;
		   -- End changes for bug no. 7418671

	 	     x_resource_group_count(l_index).group_id :=l_group_id;
	 	     x_resource_group_count(l_index).group_name := l_group_name;
		     x_resource_group_count(l_index).agent_count := l_agent_count;
	 	     x_resource_group_count(l_index).email_count := l_email_count;

	 	     l_index := l_index + 1;
 		END LOOP;
 	else
   		--  p_sort_column=0 or 2

   		if (p_sort_column = 2) then
			l_sort_column := 'agent_count';
		else
			l_sort_column := 'group_name';
		end if;

		if (l_sort_column = 'agent_count') then
			l_order_by := ' order by ' || l_sort_column || ' ' || l_sort_order;
		else
			l_order_by := ' order by UPPER(' || l_sort_column || ') ' || l_sort_order;
		end if;

 		-- Start changes for bug no. 7418671
		--l_string := 'select e.group_id, e.group_name, count(*) agent_count from
                --		jtf_rs_role_relations b, jtf_rs_group_members c, iem_agents d, jtf_rs_groups_vl e, jtf_rs_resource_extns res, jtf_rs_group_usages gu
                --    		where b.delete_flag = ''N'' and b.role_id in (28, 29, 30)
                --		and b.role_resource_id = c.resource_id and c.group_id = e.group_id
                --        	and c.resource_id=res.resource_id
                --       	and c.group_id = gu.group_id
                --        	and gu.usage = ''CALL''
                --		and trunc(sysdate) between trunc(nvl(b.start_date_active, sysdate))
      	        --         	and trunc(nvl(b.end_date_active, sysdate))
                --  		and trunc(sysdate) between trunc(nvl(e.start_date_active, sysdate))
      	        --        	and trunc(nvl(e.end_date_active, sysdate))
                --        	and trunc(sysdate) between trunc(nvl(res.start_date_active, sysdate))
      	        --         	and trunc(nvl(res.end_date_active, sysdate))
                --         	and c.delete_flag = ''N''
                --		and c.resource_id = d.resource_id and d.email_account_id = :l_email_account_id
		--		group by e.group_id, e.group_name ';
		l_string := 'SELECT e.group_id, e.group_name, COUNT(*) agent_count
				 FROM jtf_rs_group_members c, iem_agents d, jtf_rs_groups_vl e, jtf_rs_resource_extns res, jtf_rs_group_usages gu
				 WHERE c.group_id = e.group_id AND c.resource_id = res.resource_id
				 AND c.group_id = gu.group_id
				 AND c.resource_id in
					(select b.role_resource_id from jtf_rs_role_relations b
					 where b.role_resource_id=c.resource_id and b.role_id IN (28,29,30) and b.delete_flag=''N''
					 AND TRUNC(sysdate) BETWEEN TRUNC(NVL(b.start_date_active, sysdate))
					 AND TRUNC(NVL(b.end_date_active, sysdate)))
			         AND gu.usage = ''CALL''
			         AND c.delete_flag = ''N''
				 AND c.resource_id = d.resource_id
			         AND TRUNC(sysdate) BETWEEN TRUNC(NVL(e.start_date_active, sysdate))
				 AND TRUNC(NVL(e.end_date_active, sysdate))
				 AND TRUNC(sysdate) BETWEEN TRUNC(NVL(res.start_date_active, sysdate))
				 AND TRUNC(NVL(res.end_date_active, sysdate))
				 AND d.email_account_id = :l_email_account_id
				 GROUP BY e.group_id,e.group_name ';
		-- End changes for bug no. 7418671


 		l_string := l_string || l_order_by;

 		DBMS_SQL.PARSE(l_cursorID, l_string, DBMS_SQL.native);

		DBMS_SQL.BIND_VARIABLE(l_cursorID, ':l_email_account_id', l_email_account_id);

		DBMS_SQL.DEFINE_COLUMN(l_cursorID, 1, l_group_id);
		DBMS_SQL.DEFINE_COLUMN(l_cursorID, 2, l_group_name, 60);
		DBMS_SQL.DEFINE_COLUMN(l_cursorID, 3, l_agent_count);

		l_dummy := DBMS_SQL.EXECUTE(l_cursorID);

		LOOP
    			IF (DBMS_SQL.FETCH_ROWS(l_cursorID) = 0) THEN
        			EXIT;
    			END IF;

     			DBMS_SQL.COLUMN_VALUE(l_cursorID, 1, l_group_id);
     			DBMS_SQL.COLUMN_VALUE(l_cursorID, 2, l_group_name);
     			DBMS_SQL.COLUMN_VALUE(l_cursorID, 3, l_agent_count);

		     select count(*) into l_email_count from iem_rt_proc_emails where resource_id=0
		     and email_account_id=p_email_account_id and group_id=l_group_id;

	 	     x_resource_group_count(l_index).group_id :=l_group_id;
	 	     x_resource_group_count(l_index).group_name := l_group_name;
	 	     x_resource_group_count(l_index).agent_count := l_agent_count;
	 	     x_resource_group_count(l_index).email_count := l_email_count;

	 	    l_index := l_index + 1;

 		END LOOP;
 	end if; -- if p_sort_column=1

 	DBMS_SQL.CLOSE_CURSOR(l_cursorID);


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
	ROLLBACK TO show_resource_group_list_pvt;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO show_resource_group_list_pvt;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	ROLLBACK TO show_resource_group_list_pvt;
      	x_return_status := FND_API.G_RET_STS_ERROR;
	IF FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME,
    	    			l_api_name
	    		);
		END IF;
	FND_MSG_PUB.Count_And_Get
    		(p_count         	=>      x_msg_count,
        	p_data          	=>      x_msg_data
    		);


END show_resource_group_list;

end IEM_QUEUE_MANAGEMENT_PVT ;

/
