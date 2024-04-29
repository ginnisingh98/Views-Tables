--------------------------------------------------------
--  DDL for Package Body IEM_ARCH_DTLS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_ARCH_DTLS_PVT" as
/* $Header: iemardvb.pls 115.0 2003/08/20 21:38:37 sboorela noship $ */

G_PKG_NAME CONSTANT varchar2(30) :='IEM_ARCH_DTLS_PVT ';

PROCEDURE create_item (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
			p_request_id	in number,
			p_source_message_id	   IN  jtf_varchar2_Table_100,
			p_CREATED_BY  IN  NUMBER,
          	p_CREATION_DATE  IN  DATE,
         		p_LAST_UPDATED_BY  IN  NUMBER ,
          	p_LAST_UPDATE_DATE  IN  DATE,
          	p_LAST_UPDATE_LOGIN  IN  NUMBER ,
		     x_return_status	OUT NOCOPY VARCHAR2,
  		 	x_msg_count	      OUT	NOCOPY NUMBER,
	  	  	x_msg_data	OUT	NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='create_item';
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
   SAVEPOINT  IEM_ARCH_DTL_PVT;
   FOR i in p_source_message_id.FIRST..p_source_message_id.LAST LOOP
   IF p_source_message_id(i) is not null then
INSERT INTO IEM_ARCHIVED_DTLS
(REQUEST_ID,
 SOURCE_MESSAGE_ID,
 CREATED_BY,
 CREATION_DATE,
 LAST_UPDATED_BY,
 LAST_UPDATE_DATE,
 LAST_UPDATE_LOGIN)
VALUES
(p_request_id,
p_source_message_id(i),
decode(p_CREATED_BY,null,-1,p_CREATED_BY),
sysdate,
decode(p_LAST_UPDATED_BY,null,-1,p_LAST_UPDATED_BY),
sysdate,
decode(p_LAST_UPDATE_LOGIN,null,-1,p_LAST_UPDATE_LOGIN));
END IF;
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
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR ;
	  rollback to IEM_ARCH_DTL_PVT;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	  rollback to IEM_ARCH_DTL_PVT;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
	  rollback to IEM_ARCH_DTL_PVT;
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
END IEM_ARCH_DTLS_PVT ;

/
