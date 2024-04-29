--------------------------------------------------------
--  DDL for Package Body AMV_QUEUE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMV_QUEUE" AS
/* $Header: amvvaqib.pls 115.2 2000/04/11 23:12:10 pkm ship      $ */
 l_schema varchar2(30);
 l_status varchar2(1);
 l_industry varchar2(1);
begin
   if (FND_INSTALLATION.get_app_info('AMV', l_status, l_industry, l_schema))
   then
	AMV_QUEUE.queue_name := l_schema||'.'||'AMV_MATCHING_QUEUE';
	AMV_QUEUE.queue_table_name := l_schema||'.'||'AMV_MATCHING_QUEUE_TBL';
   else
   	raise_application_error(-20000,
				'Failed to get information for product '||
				 'AMV');
  end if;
end;

/
