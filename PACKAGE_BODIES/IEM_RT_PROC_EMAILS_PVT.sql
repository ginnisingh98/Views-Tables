--------------------------------------------------------
--  DDL for Package Body IEM_RT_PROC_EMAILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_RT_PROC_EMAILS_PVT" as
/* $Header: iemrprcb.pls 120.0 2005/06/02 13:55:37 appldev noship $*/
G_PKG_NAME CONSTANT varchar2(30) :='iem_rt_proc_emails_pvt ';

PROCEDURE create_item (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
				p_message_id IN NUMBER,
				p_email_account_id  IN NUMBER,
				p_priority  IN NUMBER ,
				p_agent_id  IN NUMBER,
				p_group_id  IN NUMBER,
				p_sent_date IN varchar2,
				p_received_date in date,
				p_rt_classification_id in number,
				p_customer_id    in number,
				p_contact_id    in number,
				p_relationship_id    in number,
				p_interaction_id in number,
				p_ih_media_item_id  in number,
				p_msg_status  in varchar2,
				p_mail_proc_status in varchar2,
				p_mail_item_status in varchar2,
				p_category_map_id in number,
				p_rule_id		in number,
				p_subject		in varchar2,
				p_sender_address	in varchar2,
				p_from_agent_id	in number,
		     x_return_status	OUT NOCOPY VARCHAR2,
  		 	x_msg_count	      OUT	NOCOPY NUMBER,
	  	  	x_msg_data	OUT	NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='create_item';
	l_api_version_number 	NUMBER:=1.0;
	l_seq_id		number;
	l_grp_cnt		number;
 	l_CREATED_BY  number:=TO_NUMBER (FND_PROFILE.VALUE('USER_ID'));
     l_LAST_UPDATED_BY number:= TO_NUMBER (FND_PROFILE.VALUE('USER_ID'));
     l_LAST_UPDATE_LOGIN	number:=TO_NUMBER (FND_PROFILE.VALUE('LOGIN_ID')) ;

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
-- Initialize message list if p_init_msg_list is set to TRUE.
   IF p_init_msg_list ='T'
   THEN
     FND_MSG_PUB.initialize;
   END IF;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

INSERT INTO IEM_RT_PROC_EMAILS (
MESSAGE_ID           ,
EMAIL_ACCOUNT_ID    ,
PRIORITY             ,
resource_id,
GROUP_ID,
SENT_DATE            ,
RECEIVED_DATE,
RT_CLASSIFICATION_ID,
CUSTOMER_ID          ,
CONTACT_ID          ,
RELATIONSHIP_ID          ,
IH_INTERACTION_ID,
IH_MEDIA_ITEM_ID    ,
MSG_STATUS       ,
MAIL_ITEM_STATUS,
MAIL_PROC_STATUS,
CATEGORY_MAP_ID,
RULE_ID,
SUBJECT              ,
from_address          ,
from_resource_id,
CREATED_BY          ,
CREATION_DATE       ,
LAST_UPDATED_BY     ,
LAST_UPDATE_DATE    ,
LAST_UPDATE_LOGIN   ,
ATTRIBUTE1          ,
ATTRIBUTE2          ,
ATTRIBUTE3          ,
ATTRIBUTE4          ,
ATTRIBUTE5          ,
ATTRIBUTE6          ,
ATTRIBUTE7        ,
ATTRIBUTE8        ,
ATTRIBUTE9        ,
ATTRIBUTE10       ,
ATTRIBUTE11       ,
ATTRIBUTE12       ,
ATTRIBUTE13       ,
ATTRIBUTE14       ,
ATTRIBUTE15
)
VALUES
(
p_message_id,
p_email_account_id ,
p_priority  ,
p_agent_id ,
p_group_id ,
p_sent_date,
p_received_date,
p_rt_classification_id,
p_customer_id   ,
p_contact_id   ,
p_relationship_id   ,
p_interaction_id,
p_ih_media_item_id ,
p_msg_status ,
p_mail_item_status,
p_mail_proc_status,
p_category_map_id,
p_rule_id,
p_subject ,
p_sender_address ,
p_from_agent_id,
decode(l_CREATED_BY,null,-1,l_CREATED_BY),
sysdate,
decode(l_LAST_UPDATED_BY,null,-1,l_LAST_UPDATED_BY),
sysdate,
decode(l_LAST_UPDATE_LOGIN,null,-1,l_LAST_UPDATE_LOGIN),
null,
null,
null,
null,
null,
null,
null,
null,
null,
null,
null,
null,
null,
null,
null
 );

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

 END	create_item;

PROCEDURE delete_item (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
				 p_message_id	in number,
			      x_return_status	OUT	NOCOPY VARCHAR2,
  		  	      x_msg_count	      OUT	NOCOPY    NUMBER,
	  	  	      x_msg_data	OUT NOCOPY 	VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='delete_item';
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
-- Initialize message list if p_init_msg_list is set to TRUE.
   IF p_init_msg_list ='T'
   THEN
     FND_MSG_PUB.initialize;
   END IF;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
	delete from IEM_POST_MDTS
	where message_id=p_message_id;

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
	ROLLBACK TO delete_item_PVT;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO delete_item_PVT;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	ROLLBACK TO delete_item_PVT;
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

 END	delete_item;
END iem_rt_proc_emails_pvt ;

/
