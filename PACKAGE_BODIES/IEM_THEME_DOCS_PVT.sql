--------------------------------------------------------
--  DDL for Package Body IEM_THEME_DOCS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_THEME_DOCS_PVT" as
/* $Header: iemvthdb.pls 115.3 2002/12/06 00:07:57 sboorela shipped $*/
G_PKG_NAME CONSTANT varchar2(30) :='IEM_THEME_DOCS_PVT ';

PROCEDURE create_item (p_account_intent_doc_id         IN NUMBER,
			p_theme_id            IN  NUMBER,
		      x_return_status OUT NOCOPY VARCHAR2
			 ) is
	l_CREATED_BY    		NUMBER:=-1;
     l_LAST_UPDATED_BY    	NUMBER:=-1 ;
     l_LAST_UPDATE_LOGIN      NUMBER:=-1 ;

BEGIN
   x_return_status := 'S';
INSERT INTO IEM_THEME_DOCS (
ACCOUNT_INTENT_DOC_ID,
THEME_ID       ,
CREATED_BY           ,
CREATION_DATE        ,
LAST_UPDATED_BY      ,
LAST_UPDATE_DATE     ,
LAST_UPDATE_LOGIN
)
VALUES
(
p_account_intent_doc_id   ,
p_theme_id,
decode(l_CREATED_BY,null,-1,l_CREATED_BY),
sysdate,
decode(l_LAST_UPDATED_BY,null,-1,l_LAST_UPDATED_BY),
sysdate,
decode(l_LAST_UPDATE_LOGIN,null,-1,l_LAST_UPDATE_LOGIN)
 );

EXCEPTION
   WHEN OTHERS THEN
       x_return_status := 'E' ;
END	create_item;

END IEM_THEME_DOCS_PVT ;

/
