--------------------------------------------------------
--  DDL for Package Body IEM_SERVER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_SERVER_PUB" as
/* $Header: iempsvrb.pls 120.0 2005/06/02 13:43:05 appldev noship $ */

G_PKG_NAME CONSTANT varchar2(30) :='IEM_SERVER_PUB ';

PROCEDURE Get_EmailServer_List (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
			      p_SERVER_ID  IN NUMBER	,
			      p_SERVER_TYPE	IN VARCHAR2,
			      x_return_status OUT NOCOPY VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY    NUMBER,
	  	  	      x_msg_data OUT NOCOPY VARCHAR2,
 			      x_Email_Svr_tbl  OUT NOCOPY  EMAILSVR_tbl_type)
			 IS
			 l_email_svr_index	number:=1;
cursor in_server is
       SELECT distinct
               in_host,
               in_port
       from iem_mstemail_accounts    ;

cursor out_server is
       SELECT distinct
               out_host,
               out_port
       from iem_mstemail_accounts    ;
	l_api_name        		VARCHAR2(255):='Get_EmailServer_List';
	l_api_version_number 	NUMBER:=1.0;

BEGIN
-- Standard Start of API savepoint
SAVEPOINT		Get_EmailServer_List_PUB;
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
IF  p_server_type='IMAP' then
FOR v1  IN  in_server LOOP
   x_Email_Svr_tbl(l_email_svr_index).server_name:=v1.in_host;
   x_Email_Svr_tbl(l_email_svr_index).active:='Y';
   x_Email_Svr_tbl(l_email_svr_index).port:=v1.in_port;
   l_email_svr_index:=l_email_svr_index+1;
END LOOP;
ELSIF p_server_type='SMTP' THEN
FOR v1  IN  out_server LOOP
   x_Email_Svr_tbl(l_email_svr_index).server_name:=v1.out_host;
   x_Email_Svr_tbl(l_email_svr_index).active:='Y';
   x_Email_Svr_tbl(l_email_svr_index).port:=v1.out_port;
   l_email_svr_index:=l_email_svr_index+1;
END LOOP;
END IF;
-- Standard Check Of p_commit.
	IF FND_API.To_Boolean(p_commit) THEN
		COMMIT WORK;
	END IF;
-- Standard callto get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
			( p_count =>      x_msg_count,
                 p_data  =>      x_msg_data
			);
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
	ROLLBACK TO Get_EmailServer_List_PUB;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count =>      x_msg_count,
                 p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO Get_EmailServer_List_PUB;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count =>      x_msg_count,
                 p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	ROLLBACK TO Get_EmailServer_List_PUB;
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
    		(  	p_count         	=>      x_msg_count     	,
        		p_data          	=>      x_msg_data
    		);

 END Get_EmailServer_List;

END IEM_SERVER_PUB ;

/
