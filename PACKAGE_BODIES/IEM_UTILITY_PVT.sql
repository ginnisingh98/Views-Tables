--------------------------------------------------------
--  DDL for Package Body IEM_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_UTILITY_PVT" as
/* $Header: iemutilb.pls 120.2.12010000.2 2009/08/07 09:27:55 lkullamb ship $*/
G_PKG_NAME		varchar2(100):='IEM_UTILITY_PVT';
PROCEDURE GetEmailAccountList(p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
				 x_account_tbl	out nocopy email_account_tbl,
			      x_return_status	OUT NOCOPY	VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY	   NUMBER,
	  	  	      x_msg_data	OUT NOCOPY	VARCHAR2) IS
	l_api_version_number	number:=1.0;
	l_api_name		varchar2(30):='GetEmailAccountList';
	cursor c1 is select email_account_id,from_name from iem_mstemail_accounts where deleted_flag<>'Y'
	order by from_name;
	i	number:=0;
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
	i:=0;
	for v1 in c1 loop
		i:=i+1;
		x_account_tbl(i).email_account_id:=v1.email_account_id;
		x_account_tbl(i).account_name:=v1.from_name;
	end loop;
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

END GetEmailAccountList;

PROCEDURE GetClassLists(p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
				 p_email_account_id	in number,
				 x_class_tbl	out nocopy email_class_tbl,
			      x_return_status	OUT NOCOPY	VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY	   NUMBER,
	  	  	      x_msg_data	OUT NOCOPY	VARCHAR2) IS
	l_api_version_number	number:=1.0;
	l_api_name		varchar2(30):='GetEmailAccountList';
	cursor c1 is
		select a.route_classification_id,b.name from iem_account_route_class a,iem_route_classifications b
    		where a.route_classification_id=b.route_classification_id and a.enabled_flag='Y'
    		and a.email_account_id=p_email_account_id
		order by 2;

	i	number:=0;
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
	i:=0;
	for v1 in c1 loop
		i:=i+1;
		x_class_tbl(i).rt_classification_id:=v1.route_classification_id;
		x_class_tbl(i).name:=v1.name;
	end loop;
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
end GetClassLists;
FUNCTION gettimezone(p_date in date,
				p_resource_id	in number) return varchar2 IS
	l_client_tz_id		number;
	l_status			varchar2(10);
	l_msg_count		number;
	l_msg_data		varchar2(200);
	l_date			date;
	x_date			varchar2(200);
	l_user_id			number;
	l_time_format		varchar2(100);
	l_format				varchar2(100);
begin
--add if condition for changing CherrPick view in UWQ,12.1.2 project
     if p_resource_id>0 then
     begin
	select user_id into l_user_id from JTF_RS_RESOURCE_EXTNS
	where resource_id=p_resource_id;
	l_client_tz_id :=to_number(fnd_profile.value_specific('CLIENT_TIMEZONE_ID',l_user_id));
	l_time_format :=fnd_profile.value_specific('ICX_DATE_FORMAT_MASK',l_user_id);
	l_format:=l_time_format||' '||'HH24:MI:SS';
	    HZ_TIMEZONE_PUB.Get_Time(1.0,'F', 0, l_client_tz_id, p_date,
					 l_date, l_status, l_msg_count, l_msg_data);
	x_date:=to_char(l_date,l_format);
	return(x_date);
	exception when others then
	x_date:=to_char(p_date,'DD-MON-YYYY HH24:MI:SS');
      end;
     else
	l_client_tz_id :=to_number(fnd_profile.value_specific('CLIENT_TIMEZONE_ID'));
	l_time_format :=fnd_profile.value_specific('ICX_DATE_FORMAT_MASK');
	l_format:=l_time_format||' '||'HH24:MI:SS';
	    HZ_TIMEZONE_PUB.Get_Time(1.0,'F', 0, l_client_tz_id, p_date,
					 l_date, l_status, l_msg_count, l_msg_data);
	x_date:=to_char(l_date,l_format);
  end if;
		return(x_date);
end gettimezone;
end IEM_UTILITY_PVT ;

/
