--------------------------------------------------------
--  DDL for Package JTF_MSG_CONC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_MSG_CONC" AUTHID CURRENT_USER as
/* $Header: JTFCNCPS.pls 115.6 2002/09/05 18:39:41 sosubram ship $ */

-----------------------------------------------------------------------
 G_PKJ_NAME        CONSTANT	VARCHAR2(25) := 'JTF_MSG_CONC';

Procedure CRM_PUBLISHER( errbuf         Out     varchar2,
                         retcode        Out     number,
                         p_queue_name   In      varchar2
                                                := 'JTF_STAGING_MSG_QUEUE'
                       );

Procedure CRM_PUBLISHER_JAVA( errbuf         Out     varchar2,
                              retcode        Out     number,
                              p_queue_name   In      varchar2
                            );


Procedure CRM_SUBSCRIBER( errbuf	Out	varchar2,
	    		  retcode       Out	number,
	    		  p_queue_names	In      varchar2
			);


END JTF_MSG_CONC;

 

/
