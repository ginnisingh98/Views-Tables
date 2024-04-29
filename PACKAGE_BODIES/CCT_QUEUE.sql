--------------------------------------------------------
--  DDL for Package Body CCT_QUEUE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CCT_QUEUE" AS
/* $Header: cctgqnb.pls 120.0 2005/06/02 09:35:58 appldev noship $ */

     l_schema varchar2(30);
     l_status varchar2(1);
     l_industry varchar2(1);

BEGIN
	IF (fnd_installation.get_app_info('CCT',l_status, l_industry, l_schema))
	THEN
		CCT_QUEUE.queue_name := l_schema||'.'||'CCT_IBME_QUEUE';
	ELSE
		raise_application_error(-20000,'Failed to get information for product '|| 'CCT');
	END IF;
    --dbms_output.put_line('QueueName'|| CCT_QUEUE.queue_name);
END;

/
