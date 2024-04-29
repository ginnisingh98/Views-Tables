--------------------------------------------------------
--  DDL for Package Body IEM_TEMP_STORES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_TEMP_STORES_PVT" as
/* $Header: iemvmigb.pls 120.1 2005/07/07 16:57:15 appldev noship $ */

G_PKG_NAME CONSTANT varchar2(30) :='iem_temp_stores_pvt ';

PROCEDURE create_item (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
			p_message_id			   IN  NUMBER,
			p_email_account_id          IN  NUMBER,
			p_folder_name			in varchar2,
			p_from_str			in varchar2,
			p_rfc822				in varchar2,
			p_reply_to			in varchar2,
			p_to					in varchar2,
			p_cc					in varchar2,
			p_bcc				in varchar2,
			p_sent_date			in varchar2,
			p_subject                  IN  varchar2,
			p_message_size             IN  number,
			p_mig_status                  IN  varchar2,
			p_mig_error_text		IN DATE,
			p_message_text				in varchar2,
			p_message_content		in BLOB,
		     x_return_status	OUT NOCOPY VARCHAR2,
  		 	x_msg_count	      OUT	NOCOPY NUMBER,
		     x_msg_data	OUT NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='create_item';
	l_api_version_number 	NUMBER:=1.0;
	l_seq_id		number;
	l_grp_cnt		number;
	l_message_id		number;

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
   /*
INSERT INTO iem_temp_stores (
MESSAGE_ID           ,
email_account_id       ,
FOLDER_NAME,
FROM_STR	,
RFC822_MESSAGE_ID,
REPLY_TO_STR	,
TO_STR		,
CC_STR		,
BCC_STR		,
SENT_DATE	,
SUBJECT		,
MESSAGE_SIZE	,
MIG_STATUS	,
MIG_ERROR_TEXT	,
MESSAGE_TEXT	,
MESSAGE_CONTENT
)
VALUES
(
p_message_id,
p_email_account_id,
p_FOLDER_NAME,
p_FROM_STR	,
p_RFC822,
p_REPLY_TO ,
p_TO		,
p_CC		,
p_BCC		,
p_SENT_DATE	,
p_SUBJECT		,
p_MESSAGE_SIZE	,
p_MIG_STATUS	,
p_MIG_ERROR_TEXT	,
p_MESSAGE_TEXT	,
p_MESSAGE_CONTENT
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
*/
 END	create_item;

PROCEDURE delete_item (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
				 p_message_id	in number,
			      x_return_status	OUT NOCOPY	VARCHAR2,
  		  	      x_msg_count	      OUT	 NOCOPY   NUMBER,
	  	  	      x_msg_data	OUT NOCOPY	VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='delete_item';
	l_api_version_number 	NUMBER:=1.0;

BEGIN
null;
/*
-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call (l_api_version_number,
				    p_api_version_number,
				    l_api_name,
				    G_PKG_NAME)
THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
	delete from iem_temp_stores
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
*/
 END	delete_item;
END iem_temp_stores_pvt ;

/
