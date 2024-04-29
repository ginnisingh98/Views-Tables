--------------------------------------------------------
--  DDL for Package Body IEM_SUGG_DOC_RANK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_SUGG_DOC_RANK_PVT" as
/* $Header: iemvsugb.pls 115.1 2004/03/10 00:10:06 rtripath noship $ */

G_PKG_NAME CONSTANT varchar2(30) :='IEM_SUGG_DOC_RANK_PVT ';

PROCEDURE create_item (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
			p_outbound_msg_stats_id	in number,
			p_message_id	   IN  number,
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
	l_class_id			number;
	l_rank				number;
	l_sugg_id				number;
	cursor c_top5 is
	select * from (select document_id,document_title,kb_repository_name from iem_kb_results
	where message_id=p_message_id and classification_id=l_class_id order by to_number(score) desc)
	where rownum<=5;
	cursor c_rest_doc is
	select document_id,document_title,kb_repository_name from iem_kb_results
	where message_id=p_message_id and
	(document_id,document_title,kb_repository_name) not in
	(
	select * from (select document_id,document_title,kb_repository_name from iem_kb_results
	where message_id=p_message_id and classification_id=l_class_id order by to_number(score) desc)
	where rownum<=5);

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
   SAVEPOINT  IEM_SUGG_PVT;
 select *  into l_class_id
 from (select classification_id from iem_email_classifications
 where message_id=p_message_id order by score desc)
 where rownum=1;
	l_rank:=0;
   FOR v1 in c_top5 LOOP
	l_rank:=l_rank+1;
	select IEM_SUGG_DOC_DTLS_S1.nextval into l_sugg_id
	from dual;
INSERT INTO IEM_SUGG_DOC_DTLS
  (DOC_SUGG_ID		,
   OUTBOUND_MSG_STATS_ID  ,
   KB_DOC_ID	,
   KB_DOC_RANK	,
   KB_DOC_TITLE,
   REPOSITORY,
   CREATED_BY,
 CREATION_DATE,
 LAST_UPDATED_BY,
 LAST_UPDATE_DATE,
 LAST_UPDATE_LOGIN)
VALUES
(l_sugg_id,
p_outbound_msg_stats_id,
v1.document_id,
l_rank,
v1.document_title,
v1.kb_repository_name,
decode(p_CREATED_BY,null,-1,p_CREATED_BY),
sysdate,
decode(p_LAST_UPDATED_BY,null,-1,p_LAST_UPDATED_BY),
sysdate,
decode(p_LAST_UPDATE_LOGIN,null,-1,p_LAST_UPDATE_LOGIN));
END LOOP;
--Next Create the Rest records with rank 5+
	l_rank:=6;
   FOR v2 in c_rest_doc LOOP
	select IEM_SUGG_DOC_DTLS_S1.nextval into l_sugg_id
	from dual;
INSERT INTO IEM_SUGG_DOC_DTLS
  (DOC_SUGG_ID		,
   OUTBOUND_MSG_STATS_ID  ,
   KB_DOC_ID	,
   KB_DOC_RANK	,
   KB_DOC_TITLE,
   REPOSITORY,
   CREATED_BY,
 CREATION_DATE,
 LAST_UPDATED_BY,
 LAST_UPDATE_DATE,
 LAST_UPDATE_LOGIN)
VALUES
(l_sugg_id,
p_outbound_msg_stats_id,
v2.document_id,
l_rank,
v2.document_title,
v2.kb_repository_name,
decode(p_CREATED_BY,null,-1,p_CREATED_BY),
sysdate,
decode(p_LAST_UPDATED_BY,null,-1,p_LAST_UPDATED_BY),
sysdate,
decode(p_LAST_UPDATE_LOGIN,null,-1,p_LAST_UPDATE_LOGIN));
END LOOP;
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
	  rollback to IEM_SUGG_PVT;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	  rollback to IEM_SUGG_PVT;
       FND_MSG_PUB.Count_And_Get
			( p_count => x_msg_count,
                 	p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
	  rollback to IEM_SUGG_PVT;
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
END IEM_SUGG_DOC_RANK_PVT ;

/
