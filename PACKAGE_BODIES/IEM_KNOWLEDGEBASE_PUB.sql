--------------------------------------------------------
--  DDL for Package Body IEM_KNOWLEDGEBASE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_KNOWLEDGEBASE_PUB" as
/* $Header: iemvknbb.pls 120.2 2005/12/27 17:27:52 sboorela noship $ */

G_PKG_NAME CONSTANT varchar2(30) :='IEM_KnowledgeBase_PUB ';

PROCEDURE Get_SuggResponse (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
			      p_EMAIL_ACCOUNT_ID  IN NUMBER,
                     p_MESSAGE_ID  IN VARCHAR2,
                     p_CLASSIFICATION_ID  IN NUMBER,
			      x_return_status OUT NOCOPY VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY    NUMBER,
	  	  	      x_msg_data OUT NOCOPY VARCHAR2,
 			      x_Email_SuggResp_tbl  OUT NOCOPY EMSGRESP_tbl_type
			 ) IS
	l_api_name        		VARCHAR2(255):='Get_SuggResponse';
	l_api_version_number 	NUMBER:=1.0;
	l_index		number:=1;
	l_stat		varchar2(100);
	l_out_text	varchar2(1000);
	cursor kb_results_csr is
	SELECT 	DOCUMENT_ID,
			SCORE,
			KB_REPOSITORY_NAME,
			KB_CATEGORY_NAME,
			DOCUMENT_TITLE,
			URL,
			DOC_LAST_MODIFIED_DATE
	FROM IEM_KB_RESULTS
	WHERE (EMAIL_ACCOUNT_ID = p_EMAIL_ACCOUNT_ID)
	AND   (MESSAGE_ID = p_MESSAGE_ID)
	AND classification_id = p_CLASSIFICATION_ID;
BEGIN
-- Standard Start of API savepoint
SAVEPOINT		Get_SuggResponse_PUB;
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
   for c_kb_rec in kb_results_csr
   LOOP
   x_Email_SuggResp_tbl(l_index).document_id:=c_kb_rec.document_id;
   x_Email_SuggResp_tbl(l_index).score:=c_kb_rec.score;
   x_Email_SuggResp_tbl(l_index).kb_repository_name:=c_kb_rec.kb_repository_name;
   x_Email_SuggResp_tbl(l_index).kb_category_name:=c_kb_rec.kb_category_name;
   x_Email_SuggResp_tbl(l_index).document_title:=c_kb_rec.document_title;
   x_Email_SuggResp_tbl(l_index).url:=c_kb_rec.url;
  x_Email_SuggResp_tbl(l_index).document_last_modified_date:=c_kb_rec.doc_last_modified_date;
   l_index:=l_index+1;
   END LOOP;
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
	ROLLBACK TO Get_SuggResponse_PUB;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count =>      x_msg_count,
                 p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO Get_SuggResponse_PUB;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count =>      x_msg_count,
                 p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	ROLLBACK TO Get_SuggResponse_PUB;
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

 END Get_SuggResponse;

PROCEDURE Get_KBCategories (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
			      p_EMAIL_ACCOUNT_ID  IN NUMBER,
                     p_LEVEL  IN NUMBER := 1,
			      x_return_status OUT NOCOPY VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY    NUMBER,
	  	  	      x_msg_data OUT NOCOPY VARCHAR2,
 			      x_KB_Cat_tbl  OUT NOCOPY KBCAT_tbl_type
			 ) IS
	CURSOR kb_cat_csr(p_cat_id number) IS
	SELECT
		display_name,
		is_repository,
		kb_category_id,
		kb_parent_category_id,
		category_order
	FROM IEM_KB_CATEGORIES
	WHERE LEVEL=p_LEVEL
	CONNECT BY PRIOR kb_category_id=kb_parent_category_id
	START WITH kb_category_id= p_cat_id;
	CURSOR kb_catid_csr is
		SELECT kb_category_id FROM IEM_EMAIL_CATEGORY_MAPS
		WHERE EMAIL_ACCOUNT_ID=p_EMAIL_ACCOUNT_ID;

	l_api_name        		VARCHAR2(255):='Get_KBCategories';
	l_api_version_number 	NUMBER:=1.0;
	l_cat_index	number:=1;

BEGIN
--Standard Start of API savepoint
SAVEPOINT		Get_KBCategories_PUB;
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
   /*
-- Populating The pl/sql Table With some dummy Data
   x_KB_Cat_tbl(1).display_name:='Category Display Name';
   x_KB_Cat_tbl(1).is_repository:='N';
   x_KB_Cat_tbl(1).category_id:=1001;
   x_KB_Cat_tbl(1).parent_cat_id:=1000;
   x_KB_Cat_tbl(1).category_order:=1;
*/
	x_KB_Cat_tbl.Delete;
	BEGIN
		FOR l_kb_catid_rec IN kb_catid_csr
		LOOP
		   OPEN kb_cat_csr(l_kb_catid_rec.kb_category_id);
		   LOOP
		   FETCH kb_cat_csr
		   INTO x_KB_cat_tbl(l_cat_index);
		   EXIT WHEN kb_cat_csr%NOTFOUND;
			l_cat_index:=l_cat_index+1;
			END LOOP;
			CLOSE kb_cat_csr;
		END LOOP;

	EXCEPTION
	WHEN OTHERS THEN NULL;
	END;
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
	ROLLBACK TO Get_KBCategories_PUB;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count =>      x_msg_count,
                 p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO Get_KBCategories_PUB;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count =>      x_msg_count,
                 p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	ROLLBACK TO Get_KBCategories_PUB;
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

END GET_KBCategories;

PROCEDURE Delete_ResultsCache ( p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
			      p_EMAIL_ACCOUNT_ID  IN NUMBER,
                     p_MESSAGE_ID  IN VARCHAR2,
			      x_return_status OUT NOCOPY VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY    NUMBER,
	  	  	      x_msg_data OUT NOCOPY VARCHAR2) IS
	l_api_name        		VARCHAR2(255):='Delete_ResultsCache';
	l_api_version_number 	NUMBER:=1.0;

BEGIN
--Standard Start of API savepoint
SAVEPOINT		Delete_ResultsCache_PUB;
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
   DELETE FROM IEM_KB_RESULTS
   WHERE email_account_id=p_email_account_id
   and message_id=p_message_id;
   DELETE FROM IEM_email_classifications
   WHERE email_account_id=p_email_account_id
   and message_id=p_message_id;

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
	ROLLBACK TO Delete_Resultscache_PUB;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count =>      x_msg_count,
                 p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO Delete_Resultscache_PUB;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count =>      x_msg_count,
                 p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	ROLLBACK TO Delete_Resultscache_PUB;
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
END Delete_ResultsCache ;

-- THIS API IS NOT BEING CALLED NOW, MAY BE USEFUL LATER Currently
--get_suggresponse api is serving the purpose

PROCEDURE Get_KB_SuggResponse (p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
			      p_EMAIL_ACCOUNT_ID  IN NUMBER,
                     p_MESSAGE_ID  IN VARCHAR2,
				 p_CLASSIFICATION_ID  IN NUMBER,
			      x_return_status OUT NOCOPY VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY    NUMBER,
	  	  	      x_msg_data OUT NOCOPY VARCHAR2,
 			      x_Email_SuggResp_tbl  OUT NOCOPY EMSGRESP_tbl_type
			 ) IS
	l_api_name        		VARCHAR2(255):='Get_KB_SuggResponse';
	l_api_version_number 	NUMBER:=1.0;
	l_index		number:=1;
	l_stat		varchar2(100);
	l_out_text	varchar2(1000);
	cursor kb_results_csr is
	SELECT 	DOCUMENT_ID,
			SCORE,
			KB_REPOSITORY_NAME,
			KB_CATEGORY_NAME,
			DOCUMENT_TITLE,
			URL,
			DOC_LAST_MODIFIED_DATE
	FROM IEM_KB_RESULTS
	WHERE (EMAIL_ACCOUNT_ID = p_EMAIL_ACCOUNT_ID)
	AND   (MESSAGE_ID = p_MESSAGE_ID)
	AND classification_id = p_CLASSIFICATION_ID;
BEGIN
-- Standard Start of API savepoint
SAVEPOINT		Get_SuggResponse_PUB;
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
--	iem_mailpreproc_pub.iem_wf_specificsearch(p_message_id,p_email_account_id,p_classification_id,l_stat,l_out_text);
   for c_kb_rec in kb_results_csr
   LOOP
   x_Email_SuggResp_tbl(l_index).document_id:=c_kb_rec.document_id;
   x_Email_SuggResp_tbl(l_index).score:=c_kb_rec.score;
   x_Email_SuggResp_tbl(l_index).kb_repository_name:=c_kb_rec.kb_repository_name;
   x_Email_SuggResp_tbl(l_index).kb_category_name:=c_kb_rec.kb_category_name;
   x_Email_SuggResp_tbl(l_index).document_title:=c_kb_rec.document_title;
   x_Email_SuggResp_tbl(l_index).url:=c_kb_rec.url;
  x_Email_SuggResp_tbl(l_index).document_last_modified_date:=c_kb_rec.doc_last_modified_date;
   l_index:=l_index+1;
   END LOOP;
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
	ROLLBACK TO Get_SuggResponse_PUB;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count =>      x_msg_count,
                 p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO Get_SuggResponse_PUB;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count =>      x_msg_count,
                 p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	ROLLBACK TO Get_SuggResponse_PUB;
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

 END Get_KB_SuggResponse;
-- This API is to be called for 11.5.6 New Flow .

PROCEDURE Get_SuggResponse_dtl(p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
			      p_EMAIL_ACCOUNT_ID  IN NUMBER,
                     p_MESSAGE_ID  IN VARCHAR2,
                     p_CLASSIFICATION_ID  IN NUMBER,
			      x_return_status OUT NOCOPY VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY    NUMBER,
	  	  	      x_msg_data OUT NOCOPY VARCHAR2,
 			      x_Email_SuggResp_tbl  OUT NOCOPY EMSGRESP_tbl_type) IS

	l_api_name        		VARCHAR2(255):='Get_SuggResponse_dtl';
	l_api_version_number 	NUMBER:=1.0;
	l_index		number:=1;
	l_stat		varchar2(100);
	l_out_text	varchar2(1000);
   l_category_id     AMV_SEARCH_PVT.amv_number_varray_type:=AMV_SEARCH_PVT.amv_number_varray_type();
   l_repos		varchar2(100);
   l_action		varchar2(100) ;
   l_search_type		varchar2(100) ;
   l_doc_count		number;
   l_rule_id		number;
   l_cat_counter		number;
	cursor kb_results_csr is
	SELECT 	a.DOCUMENT_ID,(select count(*) from iem_doc_usage_stats where kb_doc_id=a.document_id) rank,
			a.SCORE,
			a.KB_REPOSITORY_NAME,
			a.KB_CATEGORY_NAME,
			a.DOCUMENT_TITLE,
			a.URL,
			a.DOC_LAST_MODIFIED_DATE
	FROM IEM_KB_RESULTS a
	WHERE (a.EMAIL_ACCOUNT_ID = p_EMAIL_ACCOUNT_ID)
	AND   (a.MESSAGE_ID = p_MESSAGE_ID)
	AND a.classification_id = p_CLASSIFICATION_ID
	order by 2 desc,1 desc;
cursor c1 is select parameter1, parameter2 from iem_actions a, iem_action_dtls b
where a.emailproc_id=l_rule_id and a.action_id=b.action_id ;
l_doc_counter		number;
BEGIN
-- Standard Start of API savepoint
SAVEPOINT		Get_SuggResponse_PUB;
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
   select count(*) into l_doc_count
   from iem_kb_results
   WHERE EMAIL_ACCOUNT_ID = p_EMAIL_ACCOUNT_ID
   AND   MESSAGE_ID = p_MESSAGE_ID
   AND classification_id = p_CLASSIFICATION_ID;
   IF l_doc_count=0 then				-- No document has retrieved .

		select rule_id
		into l_rule_id
		from iem_rt_proc_emails where message_id=p_message_id;
	BEGIN
		select action into l_action from
		iem_actions where emailproc_id=l_rule_id;
	     l_search_type:=substr(l_action,15,length(l_action));
				if l_search_type='MES' THEN
					l_repos:='MES';
				elsif l_search_type='KM' THEN
					l_repos:='SMS';
				elsif l_search_type='BOTH' THEN
					l_repos:='ALL';
				end if;
				   l_cat_counter:=1;
				   FOR v1 in c1 LOOP
			 		IF v1.parameter1 <> to_char(-1)  then
							l_category_id.extend;
					l_category_id(l_cat_counter):=v1.parameter1;
							l_cat_counter:=l_cat_counter+1;
					END IF;
				  END LOOP;
	EXCEPTION
			when others then
					null;
			end;
	IEM_EMAIL_PROC_PVT.IEM_WF_SPECIFICSEARCH(
    					p_message_id  ,
    					p_email_account_id ,
    					p_classification_id,
					l_category_id,
					l_repos,
    					l_stat ,
    					l_out_text);
	commit;
  END IF;				-- end if for if doc_count=0
  	l_doc_counter:=1;
   for c_kb_rec in kb_results_csr
   LOOP
   x_Email_SuggResp_tbl(l_index).document_id:=c_kb_rec.document_id;
   x_Email_SuggResp_tbl(l_index).score:=c_kb_rec.score;
   x_Email_SuggResp_tbl(l_index).kb_repository_name:=c_kb_rec.kb_repository_name;
   x_Email_SuggResp_tbl(l_index).kb_category_name:=c_kb_rec.kb_category_name;
   x_Email_SuggResp_tbl(l_index).document_title:=c_kb_rec.document_title;
   x_Email_SuggResp_tbl(l_index).url:=c_kb_rec.url;
  x_Email_SuggResp_tbl(l_index).document_last_modified_date:=c_kb_rec.doc_last_modified_date;
   l_index:=l_index+1;
   l_doc_counter:=l_doc_counter+1;
   EXIT when l_doc_counter>10;
   END LOOP;
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
	ROLLBACK TO Get_SuggResponse_PUB;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count =>      x_msg_count,
                 p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO Get_SuggResponse_PUB;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count =>      x_msg_count,
                 p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	ROLLBACK TO Get_SuggResponse_PUB;
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

 END Get_SuggResponse_dtl;

-- This API is introduced in 11.5.0/MP-R. This will be called for showing alternate suggested response
-- Documents.
PROCEDURE Get_SuggResponse_dtl(p_api_version_number    IN   NUMBER,
 		  	      p_init_msg_list  IN   VARCHAR2 ,
		    	      p_commit	    IN   VARCHAR2 ,
			      p_EMAIL_ACCOUNT_ID  IN NUMBER,
                     p_MESSAGE_ID  IN VARCHAR2,
			      x_return_status OUT NOCOPY VARCHAR2,
  		  	      x_msg_count	      OUT NOCOPY    NUMBER,
	  	  	      x_msg_data OUT NOCOPY VARCHAR2,
 			      x_Email_SuggResp_tbl  OUT NOCOPY EMSGRESP_tbl_type
			 				) IS
	l_api_name        		VARCHAR2(255):='Get_SuggResponse_dtl';
	l_api_version_number 	NUMBER:=1.0;
	l_index		number:=1;
	l_stat		varchar2(100);
	l_out_text	varchar2(1000);
	cursor kb_results_csr is
	SELECT 	DOCUMENT_ID,
			SCORE,
			KB_REPOSITORY_NAME,
			KB_CATEGORY_NAME,
			DOCUMENT_TITLE,
			URL,
			DOC_LAST_MODIFIED_DATE
	FROM IEM_KB_RESULTS
	WHERE (EMAIL_ACCOUNT_ID = p_EMAIL_ACCOUNT_ID)
	AND   (MESSAGE_ID = p_MESSAGE_ID)
	order by score desc;
BEGIN
-- Standard Start of API savepoint
SAVEPOINT		Get_SuggResponse_PUB;
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
   for c_kb_rec in kb_results_csr
   LOOP
   x_Email_SuggResp_tbl(l_index).document_id:=c_kb_rec.document_id;
   x_Email_SuggResp_tbl(l_index).score:=c_kb_rec.score;
   x_Email_SuggResp_tbl(l_index).kb_repository_name:=c_kb_rec.kb_repository_name;
   x_Email_SuggResp_tbl(l_index).kb_category_name:=c_kb_rec.kb_category_name;
   x_Email_SuggResp_tbl(l_index).document_title:=c_kb_rec.document_title;
   x_Email_SuggResp_tbl(l_index).url:=c_kb_rec.url;
  x_Email_SuggResp_tbl(l_index).document_last_modified_date:=c_kb_rec.doc_last_modified_date;
   l_index:=l_index+1;
   END LOOP;
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
	ROLLBACK TO Get_SuggResponse_PUB;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count =>      x_msg_count,
                 p_data  =>      x_msg_data
			);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	ROLLBACK TO Get_SuggResponse_PUB;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
			( p_count =>      x_msg_count,
                 p_data  =>      x_msg_data
			);
   WHEN OTHERS THEN
	ROLLBACK TO Get_SuggResponse_PUB;
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

 END Get_SuggResponse_dtl;
END IEM_KnowledgeBase_PUB ;

/
