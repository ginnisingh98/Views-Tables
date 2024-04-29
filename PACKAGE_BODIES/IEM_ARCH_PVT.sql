--------------------------------------------------------
--  DDL for Package Body IEM_ARCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_ARCH_PVT" as
/* $Header: iemarcpb.pls 120.7 2005/10/18 11:37:20 rtripath ship $ */

G_PKG_NAME CONSTANT varchar2(30) :='IEM_ARCH_PVT ';
-- Create a Request in the System for archiving or purging.

PROCEDURE submit_request(p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
      		p_message_id IN  jtf_varchar2_Table_100,
			p_folder	   IN  VARCHAR2,
			p_email_account_id in number,
			p_search_criteria in varchar2,
			p_request_type in varchar2,
			x_request_id	OUT NOCOPY NUMBER,
		     x_return_status	OUT NOCOPY VARCHAR2,
  		 	x_msg_count	      OUT	NOCOPY NUMBER,
	  	  	x_msg_data	OUT	NOCOPY VARCHAR2
			 ) IS
	l_api_name        		VARCHAR2(255):='submit_request';
	l_api_version_number 	NUMBER:=1.0;
	l_seq_id				NUMBER;
	l_ret_status			varchar2(10);
	l_msg_count			number;
	l_msg_data			varchar2(500);
	l_arch_folder_id		number;
	l_arch_count		number;
	ERROR_CREATING_DTL_REQUESTS	EXCEPTION;
	ERROR_CREATING_FLD_REQUESTS	EXCEPTION;
	ERROR_CREATING_REQUESTS	EXCEPTION;

BEGIN
-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call (l_api_version_number,
				    p_api_version_number,
				    l_api_name,
				    G_PKG_NAME)
THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   SAVEPOINT SUBMIT_REQUEST_PVT;
   -- Create a New Request Id
   IF p_message_id.count>0 THEN		--There are messages to process
   select iem_arch_requests_s1.nextval into l_seq_id from dual;

-- Creating the Source message ids in the archive details table
	IEM_ARCH_DTLS_PVT. create_item (p_api_version_number=>1.0 ,
                     p_init_msg_list=>'F'  ,
                     p_commit=>'F'     ,
               p_request_id =>l_seq_id,
               p_source_message_id =>p_message_id,
      		p_CREATED_BY    =>TO_NUMBER (FND_PROFILE.VALUE('USER_ID')),
               p_CREATION_DATE  =>sysdate,
          	p_LAST_UPDATED_BY    =>TO_NUMBER (FND_PROFILE.VALUE('USER_ID')),
               p_LAST_UPDATE_DATE    =>sysdate,
               p_LAST_UPDATE_LOGIN    =>TO_NUMBER (FND_PROFILE.VALUE('LOGIN_ID')),
               x_return_status=>l_ret_status,
               x_msg_count=>l_msg_count,
               x_msg_data=>l_msg_data
                );
	IF l_ret_status<>'S' then
		raise ERROR_CREATING_DTL_REQUESTS;
     END IF;
		l_arch_count:=p_message_id.count;

   --Finally Create a request in the archive request table
IEM_ARCH_REQUESTS_PVT.create_item (p_api_version_number=>1.0  ,
                     p_init_msg_list=>'F'  ,
                     p_commit=>'F',
               p_request_id=>l_seq_id   ,
               p_arch_criteria=>p_search_criteria,
               p_email_account_id=>p_email_account_id,
               p_folder_name=>p_folder ,
			p_arch_folder_id=>l_arch_folder_id,
			p_arch_count=>l_arch_count,
			p_request=>p_request_type,
      		p_CREATED_BY    =>TO_NUMBER (FND_PROFILE.VALUE('USER_ID')),
               p_CREATION_DATE  =>sysdate,
          	p_LAST_UPDATED_BY    =>TO_NUMBER (FND_PROFILE.VALUE('USER_ID')),
               p_LAST_UPDATE_DATE    =>sysdate,
               p_LAST_UPDATE_LOGIN    =>TO_NUMBER (FND_PROFILE.VALUE('LOGIN_ID')),
               x_return_status=>l_ret_status,
               x_msg_count=>l_msg_count,
               x_msg_data=>l_msg_data
                );
	IF l_ret_status<>'S' then
		raise ERROR_CREATING_REQUESTS;
     END IF;
		x_request_id:=l_seq_id;
   END IF;

-- Standard Check Of p_commit.
	IF p_commit='T' THEN
		COMMIT WORK;
	END IF;
EXCEPTION
   WHEN ERROR_CREATING_DTL_REQUESTS THEN
	  rollback to SUBMIT_REQUEST_PVT;
           x_return_status := FND_API.G_RET_STS_ERROR ;
           FND_MESSAGE.SET_NAME('IEM','IEM_ARCH_DTL_SUBMIT_REQ_ERROR');
           FND_MSG_PUB.Add;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN ERROR_CREATING_REQUESTS THEN
	  rollback to SUBMIT_REQUEST_PVT;
           x_return_status := FND_API.G_RET_STS_ERROR ;
           FND_MESSAGE.SET_NAME('IEM','IEM_ARCH_REQUEST_ERROR');
           FND_MSG_PUB.Add;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_ERROR THEN
	  rollback to SUBMIT_REQUEST_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	  rollback to SUBMIT_REQUEST_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	  rollback to SUBMIT_REQUEST_PVT;
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

 END	submit_request;
-- Processing Api for archiving.

-- To be called by concurrent manager for procesing

PROCEDURE process_request(p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
			p_request_id in number,
			p_request_type in varchar2,
		     x_return_status	OUT NOCOPY VARCHAR2,
  		 	x_msg_count	      OUT	NOCOPY NUMBER,
	  	  	x_msg_data	OUT	NOCOPY VARCHAR2
			 ) IS
	l_api_name        		VARCHAR2(255):='process_request';
	l_api_version_number 	NUMBER:=1.0;
	l_seq_id				NUMBER;
	l_email_account_id		NUMBER;
	l_folder				VARCHAR2(100);
	l_ret_status			varchar2(10);
	l_out_text			varchar2(500);
	m_out_text			varchar2(500);
	l_arch_folder_id		number;
	l_arch_count			number;
	l_milcs_type			number;
BEGIN
-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call (l_api_version_number,
				    p_api_version_number,
				    l_api_name,
				    G_PKG_NAME)
THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF p_request_type='P' THEN
			l_milcs_type:=47;
  END IF;

    IF l_milcs_type is not null then
	IEM_ARCH_PVT.CREATE_MLCS(p_request_id=>p_request_id	,
				  p_milcs_type=>l_milcs_type ,			-- '46'Email Archived
  		 		x_ret_status=>l_ret_status,		-- '47' Email Purged
	  	  		x_out_text=>m_out_text);
	END IF;

	select count(*) into l_arch_count
	from iem_archived_dtls
	where request_id=p_request_id
	and nvl(media_id,1)>0;			--	ignoring data with no media id info where media id=0
								-- If media id is null we should not ignore as it might be due to
								-- some processing error like move or delete message error
	IF l_arch_count=0 THEN
		update iem_Arch_Requests
		set status='C'
		where Request_id=p_request_id;
		update iem_archived_folders
		set arch_folder_status='O'
		where arch_folder_id=l_arch_Folder_id;
    ELSE
		update iem_Arch_Requests
		set status='E',
		arch_comment=nvl(l_out_text,' ')||nvl(m_out_text,' ')
		where Request_id=p_request_id;
	END IF;
-- Standard Check Of p_commit.
	IF p_commit='T' THEN
		COMMIT WORK;
	END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
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

 END	process_request;
-- Cancel an existing request
PROCEDURE cancel_request(p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
			p_request_id in number,
		     x_return_status	OUT NOCOPY VARCHAR2,
  		 	x_msg_count	      OUT	NOCOPY NUMBER,
	  	  	x_msg_data	OUT	NOCOPY VARCHAR2
			 ) IS
	l_api_name        		VARCHAR2(255):='delete_request';
	l_api_version_number 	NUMBER:=1.0;
	l_arch_folder			IEM_ARCHIVED_FOLDERS.ARCH_FOLDER_NAME%TYPE;
	l_arch_folder_id		IEM_ARCHIVED_FOLDERS.ARCH_FOLDER_ID%TYPE;
	l_email_account_id		IEM_EMAIL_ACCOUNTS.EMAIL_ACCOUNT_ID%TYPE;
	l_ret_status			varchar2(10);
	l_out_text			varchar2(500);
	ERROR_FOLDER_DELETION	EXCEPTION;
	ERROR_CANCEL_REQUEST	EXCEPTION;
	l_oes_ret_code			number;
	l_req_type			iem_arch_requests.request_type%type;

BEGIN
-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call (l_api_version_number,
				    p_api_version_number,
				    l_api_name,
				    G_PKG_NAME)
THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   delete from IEM_ARCH_REQUESTS
   where request_id=p_request_id;
   delete from IEM_ARCHIVED_DTLS
   where request_id=p_request_id;
-- Standard Check Of p_commit.
	IF p_commit='T' THEN
		COMMIT WORK;
	END IF;
-- MAde changes to return request type instead of a success status to make it more easy in UI
       x_return_status := l_req_type;
EXCEPTION
   WHEN NO_DATA_FOUND THEN		-- Not a Valid Request to cancell Do Nothing
   	null;
   WHEN ERROR_FOLDER_DELETION THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MESSAGE.SET_NAME('IEM','IEM_ARCH_OES_FLD_DELETE_ERROR');
  	   FND_MESSAGE.Set_Token('CODE',l_oes_ret_code);
       FND_MSG_PUB.Add;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data );
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR||p_request_id ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN ERROR_CANCEL_REQUEST THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MESSAGE.SET_NAME('IEM','IEM_ARCH_CANCEL_ERROR');
  	   FND_MESSAGE.Set_Token('ERROR_STRING',l_oes_ret_code);
       FND_MSG_PUB.Add;
		FND_MSG_PUB.Count_And_Get
    		( p_count         	=>      x_msg_count     	,
        	p_data          	=>      x_msg_data
    		);
   WHEN OTHERS THEN
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

 END	cancel_request;

-- Return the Folder message count, Last archived date and action required flag
PROCEDURE get_folder_dtl(
			p_email_account_id	   IN  NUMBER,
			p_folder		IN VARCHAR2,
			p_date	IN varchar2,
			p_date_format	IN varchar2,
			x_count	OUT NOCOPY NUMBER,
			x_msg_table	OUT NOCOPY jtf_number_table,
			x_arch_date		OUT NOCOPY  VARCHAR2,
			x_action_flg		OUT NOCOPY VARCHAR2,	--Y/N
			x_action_desc		OUT NOCOPY VARCHAR2,	--Y/N
  		 	x_ret_status	      OUT	NOCOPY VARCHAR2,
	  	  	x_out_text	OUT	NOCOPY VARCHAR2) IS

 l_ret			number;
 l_count			number;
 l_proc_count			number;
 l_arch_date		varchar2(100);
 l_from 		varchar2(100):=null;
l_msg_count		number;
l_msg_data		varchar2(500);
l_action_flg		varchar2(10);
l_date			date;
cursor c1 is
 select message_id
 from iem_arch_msgdtls where
 email_account_id=p_email_account_id and mailproc_Status=substr(p_folder,1,1)
 and received_date<l_date;
cursor c2 is
 select message_id
 from iem_arch_msgdtls where
 email_account_id=p_email_account_id and mailproc_Status=substr(p_folder,1,1)
 and creation_date<l_date;
ERROR_FOLDER_COUNT	EXCEPTION;
BEGIN
	select to_date(p_date,p_date_format) into l_date from dual;
	BEGIN
	select to_char(max(creation_date),p_date_format)
	into x_arch_date
	from iem_arch_requests
	where email_account_id=p_email_account_id
	and folder_name=p_folder and status ='C';
	EXCEPTION WHEN OTHERS THEN
		x_arch_date:=null;
	END;

	select count(*) into x_count
	from iem_arch_msgdtls where
	email_account_id=p_email_account_id and mailproc_Status=substr(p_folder,1,1);
	if substr(p_folder,1,1)='S' then
	open c2;
		fetch c2 bulk collect into x_msg_table;
	close c2;
	select count(*) into l_count
 	from iem_arch_msgdtls where
 	email_account_id=p_email_account_id and mailproc_Status=substr(p_folder,1,1)
 	and creation_date<l_date;
	else
		open c1;
	fetch c1 bulk collect into x_msg_table;
	close c1;
	end if;
	l_count:=x_msg_table.count;
		select count(*) into l_proc_count
		from iem_arch_requests
		where email_account_id=p_email_account_id
		and folder_name=p_folder
		and status in ('S','E','P');
		IF l_proc_count=0 and l_count>0 then
			 l_action_flg:='Y';
		ELSE
			l_action_flg:='N';
		END IF;
			select meaning into x_action_desc
			from fnd_lookups
			where lookup_type='IEM_ARCH_STATUS'
			and lookup_code=l_action_flg;
			x_action_flg:=l_action_flg;
		x_ret_status:='S';
EXCEPTION WHEN OTHERS THEN
	x_ret_status:='E';
           FND_MESSAGE.SET_NAME('IEM','IEM_ARCH_ORACLE_ERROR');
           FND_MSG_PUB.Add;
END get_folder_dtl;

PROCEDURE PROC_REQUESTS(ERRBUF OUT NOCOPY		VARCHAR2,
		   ERRRET OUT NOCOPY		VARCHAR2,
		   p_api_version_number in number:= 1.0) IS
 cursor c1 is
	select request_id,request_type from iem_arch_Requests
	where status='S'
	order by creation_date for update;
l_ret_status varchar2(10);
l_msg_data varchar2(1000);
l_msg_count number;
l_request_id number;
l_req_type		varchar2(10);
l_proc_flag	varchar2(1):='T';
BEGIN
	LOOP			-- Outer Loop
		l_proc_flag:='F';
	for v1 in c1 LOOP
		update iem_arch_Requests
		set status='I'
		where request_id=v1.request_id;
		l_request_id:=v1.request_id;
		l_req_type:=v1.request_type;
		l_proc_flag:='T';
		EXIT;
	END LOOP;
		commit;
		IF l_proc_flag='T' THEN
IEM_ARCH_PVT.process_request(p_api_version_number=>1.0,
 		  	      p_init_msg_list=>'F',
		    	      p_commit=>'F',
      		p_request_id=>l_request_id ,
			p_request_type=>l_req_type,
		     x_return_status=>l_ret_status	,
  		 	x_msg_count=>l_msg_count,
	  	  	x_msg_data=>l_msg_data);
		END IF;
	EXIT when l_proc_flag='F';
	END LOOP;					--End of outer Loop
end PROC_REQUESTS;
PROCEDURE CREATE_MLCS(p_request_id	in number,
				  p_milcs_type in number,
  		 		x_ret_status	      OUT	NOCOPY VARCHAR2,
	  	  		x_out_text	OUT	NOCOPY VARCHAR2) IS
 IH_EXCEPTION		EXCEPTION;
 	l_media_lc_rec 		JTF_IH_PUB.media_lc_rec_type;
	l_ret_status			varchar2(10);
	l_msg_count			number;
	l_msg_data			varchar2(500);
	l_milcs_id			number;
 cursor c1 is select a.ih_media_item_id,b.source_message_id from iem_arch_msgdtls a,iem_archived_dtls b
 where b.request_id=p_request_id
 and a.message_id=b.source_message_id;
 l_type_id			number;
begin
	FOR v1 IN c1 LOOP
  l_media_lc_rec.media_id :=v1.ih_media_item_id ;
  l_media_lc_rec.milcs_type_id := p_milcs_type;
  l_media_lc_rec.start_date_time := sysdate;
  l_media_lc_rec.handler_id := 680;
  l_media_lc_rec.type_type := 'Email, Inbound';

  			JTF_IH_PUB.Add_MediaLifeCycle( 1.0,
						'T',
						'F',
						TO_NUMBER(FND_PROFILE.VALUE('RESP_APPL_ID')),
						TO_NUMBER(FND_PROFILE.VALUE('RESP_ID')),
						nvl(TO_NUMBER (FND_PROFILE.VALUE('USER_ID')),-1),
						TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),
						l_ret_status,
						l_msg_count,
						l_msg_data,
						l_media_lc_rec,
						l_milcs_id);

					if l_ret_status<>'S' then
						update iem_archived_dtls
						set error_summary='Error While Creating MLCS'
						where request_id=p_request_id  and source_message_id=v1.source_message_id;
						x_out_text:='Error While Creating MLCS';
					else
						delete from iem_archived_dtls where request_id=p_request_id
						and source_message_id=v1.source_message_id;
						delete from iem_arch_msgs where message_id=v1.source_message_id;
						delete from iem_arch_msgdtls where message_id=v1.source_message_id;
					end if;
					-- Update the MLCS with ENDDATE TIME
					l_media_lc_rec.milcs_id:=l_milcs_id;
  			JTF_IH_PUB.Update_MediaLifeCycle( 1.0,
						'T',
						'F',
						TO_NUMBER(FND_PROFILE.VALUE('RESP_APPL_ID')),
						TO_NUMBER(FND_PROFILE.VALUE('RESP_ID')),
						nvl(TO_NUMBER (FND_PROFILE.VALUE('USER_ID')),-1),
						TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),
						l_ret_status,
						l_msg_count,
						l_msg_data,
						l_media_lc_rec);
					if l_ret_status<>'S' then
						update iem_archived_dtls
						set error_summary='Error While Updating MLCS'
						where request_id=p_request_id  and source_message_id=v1.source_message_id;
						x_out_text:='Error While Updating MLCS';
					end if;
		END LOOP;
					x_ret_status:='S';
EXCEPTION
		when OTHERS THEN
			x_out_text:='An Error Occured while Creating MLCS '||sqlerrm;
			x_ret_status:='E';
 END CREATE_MLCS;
END IEM_ARCH_PVT ;

/
