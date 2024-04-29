--------------------------------------------------------
--  DDL for Package Body IEO_QUEUE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEO_QUEUE" AS
/* $Header: ieogqnb.pls 115.3 2002/12/27 01:09:08 edwang noship $ */

     l_schema varchar2(30);
     l_status varchar2(1);
     l_industry varchar2(1);

BEGIN
	IF (fnd_installation.get_app_info('IEO',l_status, l_industry, l_schema))
	THEN
		IEO_QUEUE.queue_name_1 := l_schema||'.'||'IEO_ICSM_QUEUE_1';
		IEO_QUEUE.queue_name_2 := l_schema||'.'||'IEO_ICSM_QUEUE_2';
	ELSE
		raise_application_error(-20000,'Failed to get information for product '|| 'IEO');
	END IF;
    --dbms_output.put_line('QueueName'|| IEO_QUEUE.queue_name_1);
    --dbms_output.put_line('QueueName'|| IEO_QUEUE.queue_name_2);
END;

/
