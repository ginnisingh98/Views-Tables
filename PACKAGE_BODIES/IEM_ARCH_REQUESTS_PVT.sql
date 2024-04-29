--------------------------------------------------------
--  DDL for Package Body IEM_ARCH_REQUESTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_ARCH_REQUESTS_PVT" as
/* $Header: iemarqvb.pls 115.0 2003/08/20 21:37:35 sboorela noship $ */

G_PKG_NAME CONSTANT varchar2(30) :='IEM_ARCH_REQUESTS_PVT ';

PROCEDURE create_item (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
			p_request_id	in number,
			p_arch_criteria	   IN  VARCHAR2,
			p_email_account_id          IN  NUMBER,
			p_folder_name               IN  VARCHAR2,
			p_request			IN VARCHAR2,
			p_arch_folder_id	IN NUMBER,
			p_arch_count		IN NUMBER,
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
INSERT INTO IEM_ARCH_REQUESTS
(REQUEST_ID,
 ARCH_CRITERIA,
 EMAIL_ACCOUNT_ID,
 FOLDER_NAME,
 ARCH_FOLDER_ID,
 ARCH_COUNT,
 STATUS,
 REQUEST_TYPE,
 CREATED_BY,
 CREATION_DATE,
 LAST_UPDATED_BY,
 LAST_UPDATE_DATE,
 LAST_UPDATE_LOGIN)
VALUES
(p_request_id,
p_arch_criteria,
p_email_account_id,
p_folder_name,
p_arch_folder_id,
p_arch_count,
'S',
p_request,
decode(p_CREATED_BY,null,-1,p_CREATED_BY),
sysdate,
decode(p_LAST_UPDATED_BY,null,-1,p_LAST_UPDATED_BY),
sysdate,
decode(p_LAST_UPDATE_LOGIN,null,-1,p_LAST_UPDATE_LOGIN));
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

PROCEDURE update_item(p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
				 p_request_id	in number,
				 p_arch_folder_id	in number,
				 p_arch_count	in number,
				 p_arch_size	in number,
				 p_status		in varchar2,
				 p_comment	in varchar2,
			      x_return_status	OUT	NOCOPY VARCHAR2,
  		  	      x_msg_count	      OUT	 NOCOPY   NUMBER,
	  	  	      x_msg_data	OUT	NOCOPY VARCHAR2) IS

	l_api_name        		VARCHAR2(255):='update_item';
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
	update iem_arch_requests
	set arch_count=decode(p_arch_count,null,arch_count,p_arch_count),
	arch_size=decode(p_arch_size,null,arch_size,p_arch_size),
	status=p_status,
	arch_comment=decode(p_comment,null,arch_comment,p_comment)
    where request_id=p_request_id and arch_folder_id=p_arch_folder_id;

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

 END	update_item;

END IEM_ARCH_REQUESTS_PVT ;

/
