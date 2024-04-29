--------------------------------------------------------
--  DDL for Package Body IEM_REROUTING_HISTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_REROUTING_HISTS_PVT" as
/* $Header: iemvrehb.pls 115.1 2002/12/06 00:20:22 sboorela shipped $*/
G_PKG_NAME CONSTANT varchar2(30) :='IEM_REROUTING_HISTS_PVT ';

PROCEDURE create_item (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
			p_message_id		IN   NUMBER,
			p_agent_id   IN  NUMBER,
			p_CREATED_BY  IN  NUMBER,
          	p_CREATION_DATE  IN  DATE,
         		p_LAST_UPDATED_BY  IN  NUMBER ,
          	p_LAST_UPDATE_DATE  IN  DATE,
          	p_LAST_UPDATE_LOGIN  IN  NUMBER ,
         		p_ATTRIBUTE1   IN VARCHAR2,
          	p_ATTRIBUTE2   IN VARCHAR2,
          	p_ATTRIBUTE3   IN VARCHAR2,
          	p_ATTRIBUTE4   IN VARCHAR2,
          	p_ATTRIBUTE5   IN VARCHAR2,
          	p_ATTRIBUTE6   IN VARCHAR2,
          	p_ATTRIBUTE7   IN VARCHAR2,
          	p_ATTRIBUTE8   IN VARCHAR2,
          	p_ATTRIBUTE9   IN VARCHAR2,
          	p_ATTRIBUTE10  IN  VARCHAR2,
          	p_ATTRIBUTE11  IN  VARCHAR2,
          	p_ATTRIBUTE12  IN  VARCHAR2,
          	p_ATTRIBUTE13  IN  VARCHAR2,
          	p_ATTRIBUTE14  IN  VARCHAR2,
          	p_ATTRIBUTE15  IN  VARCHAR2,
		      x_return_status	OUT NOCOPY VARCHAR2,
  		 	 x_msg_count	      OUT	NOCOPY NUMBER,
	  	  	 x_msg_data	OUT	NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='create_item';
	l_api_version_number 	NUMBER:=1.0;
	l_seq_id		number;
	l_grp_cnt		number;

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
select iem_reroute_hists_s1.nextval into l_seq_id from dual;
INSERT INTO IEM_REROUTE_HISTS (
reroute_id,
MESSAGE_ID           ,
AGENT_ID    ,
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
l_seq_id,
p_message_id,
p_agent_id,
decode(p_CREATED_BY,null,-1,p_CREATED_BY),
sysdate,
decode(p_LAST_UPDATED_BY,null,-1,p_LAST_UPDATED_BY),
sysdate,
decode(p_LAST_UPDATE_LOGIN,null,-1,p_LAST_UPDATE_LOGIN),
p_ATTRIBUTE1,
p_ATTRIBUTE2,
p_ATTRIBUTE3,
p_ATTRIBUTE4,
p_ATTRIBUTE5,
p_ATTRIBUTE6,
p_ATTRIBUTE7,
p_ATTRIBUTE8,
p_ATTRIBUTE9,
p_ATTRIBUTE10,
p_ATTRIBUTE11,
p_ATTRIBUTE12,
p_ATTRIBUTE13,
p_ATTRIBUTE14,
p_ATTRIBUTE15
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
			     x_return_status	OUT NOCOPY VARCHAR2,
  		  	      x_msg_count	      OUT	NOCOPY   NUMBER,
	  	  	      x_msg_data	OUT NOCOPY	VARCHAR2
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
   x_return_status := FND_API.G_RET_STS_SUCCESS;
-- Initialize message list if p_init_msg_list is set to TRUE.
   IF p_init_msg_list ='T'
   THEN
     FND_MSG_PUB.initialize;
   END IF;
	delete from IEM_REROUTE_HISTS
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
END IEM_REROUTING_HISTS_PVT ;

/
