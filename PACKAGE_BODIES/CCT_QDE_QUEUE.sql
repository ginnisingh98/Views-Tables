--------------------------------------------------------
--  DDL for Package Body CCT_QDE_QUEUE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CCT_QDE_QUEUE" AS
/* $Header: cctqdqnb.pls 115.1 2003/09/30 17:39:07 svinamda noship $ */

     l_schema varchar2(30);
     l_status varchar2(1);
     l_industry varchar2(1);

BEGIN
	IF (fnd_installation.get_app_info('CCT',l_status, l_industry, l_schema))
	THEN
		CCT_QDE_QUEUE.queue_name := l_schema||'.'||'CCT_QDE_RESPONSE_QUEUE';
	ELSE
		raise_application_error(-20000,'Failed to get information for product '|| 'CCT');
	END IF;
    --dbms_output.put_line('QueueName'|| CCT_QDE_QUEUE.queue_name);
END;


/
