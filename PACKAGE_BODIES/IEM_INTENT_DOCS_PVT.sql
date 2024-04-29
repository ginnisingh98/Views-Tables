--------------------------------------------------------
--  DDL for Package Body IEM_INTENT_DOCS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_INTENT_DOCS_PVT" as
/* $Header: iemvdocb.pls 115.3 2002/12/05 23:49:45 sboorela shipped $*/
G_PKG_NAME CONSTANT varchar2(30) :='IEM_INTENT_DOCS_PVT ';

PROCEDURE create_item (p_classification_id         IN NUMBER,
			p_email_account_id            IN  NUMBER,
			p_query_response               IN  VARCHAR2,
			x_doc_seq_no		 OUT NOCOPY NUMBER,
		      x_return_status OUT NOCOPY VARCHAR2
			 ) is
	l_seq_id				NUMBER;
	l_CREATED_BY    		NUMBER:=-1;
     l_LAST_UPDATED_BY    	NUMBER:=-1 ;
     l_LAST_UPDATE_LOGIN      NUMBER:=-1 ;

BEGIN
   x_return_status := 'S';
select iem_account_intent_docs_s1.nextval into l_seq_id
from dual;
INSERT INTO IEM_ACCOUNT_INTENT_DOCS (
ACCOUNT_INTENT_DOC_ID,
CLASSIFICATION_ID    ,
EMAIL_ACCOUNT_ID     ,
QUERY_RESPONSE       ,
CREATED_BY           ,
CREATION_DATE        ,
LAST_UPDATED_BY      ,
LAST_UPDATE_DATE     ,
LAST_UPDATE_LOGIN
)
VALUES
(
l_seq_id   ,
p_classification_id,
p_EMAIL_ACCOUNT_ID   ,
p_query_response     ,
decode(l_CREATED_BY,null,-1,l_CREATED_BY),
sysdate,
decode(l_LAST_UPDATED_BY,null,-1,l_LAST_UPDATED_BY),
sysdate,
decode(l_LAST_UPDATE_LOGIN,null,-1,l_LAST_UPDATE_LOGIN)
 );

	x_doc_seq_no:=l_seq_id;
EXCEPTION
   WHEN OTHERS THEN
       x_return_status := 'E' ;
END	create_item;

PROCEDURE delete_item (p_account_intent_doc_id	in number,
			      x_return_status OUT NOCOPY VARCHAR2
			 ) is

BEGIN
   x_return_status := 'E';

   delete from IEM_ACCOUNT_INTENT_DOCS
   where account_intent_doc_id=p_account_intent_doc_id;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := 'E';
 END	delete_item;
END IEM_INTENT_DOCS_PVT ;

/
