--------------------------------------------------------
--  DDL for Package Body JTF_MSG_CONC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_MSG_CONC" as
/* $Header: JTFCNCPB.pls 115.6 2002/09/05 18:39:50 sosubram ship $ */

-----------------------------------------------------------------------
 G_PKJ_NAME        CONSTANT	VARCHAR2(25) := 'JTF_MSG_CONC';

Procedure CRM_PUBLISHER( errbuf         Out     varchar2,
                         retcode        Out     number,
                         p_queue_name   In      varchar2
                                                := 'JTF_STAGING_MSG_QUEUE'
                       ) AS
BEGIN

   CRM_PUBLISHER_JAVA(errbuf, retcode, p_queue_name);

END CRM_PUBLISHER;

Procedure CRM_PUBLISHER_JAVA( errbuf		Out	varchar2,
      	    		      retcode           Out	number,
	    		      p_queue_name	In      varchar2
		       ) as Language JAVA
   NAME 'oracle.apps.jtf.jmh.publisher.CRMPublisher.run(java.lang.String[],
					       		int[],
					       		java.lang.String)';


Procedure CRM_SUBSCRIBER( errbuf	Out	varchar2,
	    		  retcode       Out	number,
	    		  p_queue_names	In      varchar2
		       ) as Language JAVA
   NAME 'oracle.apps.jtf.jmh.subscriber.CRMSubscriber.run(java.lang.String[],
					       		  int[],
					                  java.lang.String)';

/*    CRMSubsciber.run( retBuffer, retCode, queueNames)  */


END JTF_MSG_CONC;

/
