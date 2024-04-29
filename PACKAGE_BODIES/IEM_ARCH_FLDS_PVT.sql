--------------------------------------------------------
--  DDL for Package Body IEM_ARCH_FLDS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_ARCH_FLDS_PVT" as
/* $Header: iemaflvb.pls 120.1 2005/09/07 12:15:24 appldev ship $ */

G_PKG_NAME CONSTANT varchar2(30) :='IEM_ARCH_FLDS_PVT ';

PROCEDURE create_item (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
			p_email_account_id  IN  NUMBER,
			p_folder	   IN  VARCHAR2,
			p_CREATED_BY  IN  NUMBER,
          	p_CREATION_DATE  IN  DATE,
         		p_LAST_UPDATED_BY  IN  NUMBER ,
          	p_LAST_UPDATE_DATE  IN  DATE,
          	p_LAST_UPDATE_LOGIN  IN  NUMBER ,
  		 	x_folder_id	      OUT	NOCOPY NUMBER,
		     x_return_status	OUT NOCOPY VARCHAR2,
  		 	x_msg_count	      OUT	NOCOPY NUMBER,
	  	  	x_msg_data	OUT	NOCOPY VARCHAR2
			 ) is
	l_api_name        		VARCHAR2(255):='create_item';
	l_api_version_number 	NUMBER:=1.0;
	l_seq_id				NUMBER;
	l_fld_id				NUMBER;
	l_oes_ret_code				NUMBER;
	l_arch_folder			VARCHAR2(128);
	l_ret_status			VARCHAR2(10);
	l_out_text			VARCHAR2(500);
	FOLDER_CREATE_ERROR		EXCEPTION;

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
   SAVEPOINT IEM_ARCHFLD_PVT;
   select iem_archived_folders_s1.nextval into l_seq_id from dual;
   select nvl(max(FOLDER_SEQ_NUM),0)+1
   INTO l_fld_id
   FROM IEM_ARCHIVED_FOLDERS
   where email_account_id=p_email_account_id
   and FOLDER_NAME=p_folder;
   l_arch_folder:='Arch'||p_email_account_id||p_folder||l_fld_id;
INSERT INTO IEM_ARCHIVED_FOLDERS
(ARCH_FOLDER_ID,
 ARCH_FOLDER_NAME,
 FOLDER_NAME,
 FOLDER_SEQ_NUM,
 EMAIL_ACCOUNT_ID,
 ARCH_FOLDER_STATUS,
 CREATED_BY,
 CREATION_DATE,
 LAST_UPDATED_BY,
 LAST_UPDATE_DATE,
 LAST_UPDATE_LOGIN)
VALUES
(l_seq_id,
l_arch_folder,
p_folder,
l_fld_id,
p_email_account_id,
'I',							-- In used
decode(p_CREATED_BY,null,-1,p_CREATED_BY),
sysdate,
decode(p_LAST_UPDATED_BY,null,-1,p_LAST_UPDATED_BY),
sysdate,
decode(p_LAST_UPDATE_LOGIN,null,-1,p_LAST_UPDATE_LOGIN));
x_folder_id:=l_seq_id;
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
   WHEN FOLDER_CREATE_ERROR THEN
	x_return_status := FND_API.G_RET_STS_ERROR ;
	 rollback to IEM_ARCHFLD_PVT;
    FND_MESSAGE.Set_Name('IEM', 'IEM_ARCH_OES_FLD_CREATE_ERROR');
  	FND_MESSAGE.Set_Token('CODE',l_oes_ret_code);
    FND_MSG_PUB.Add;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR ;
				rollback to IEM_ARCHFLD_PVT;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
				rollback to IEM_ARCHFLD_PVT;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
				rollback to IEM_ARCHFLD_PVT;
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
END IEM_ARCH_FLDS_PVT ;

/
