--------------------------------------------------------
--  DDL for Package JTF_MESSAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_MESSAGE" AUTHID CURRENT_USER as
/* $Header: JTFQMSGS.pls 115.3 2002/02/14 05:47:40 appldev ship $ */

-----------------------------------------------------------------------
 G_PKJ_NAME        CONSTANT	VARCHAR2(25) := 'JTF_Message';

Procedure Queue_Message( p_prod_code		varchar2,
	    		 p_bus_obj_code		varchar2,
	    		 p_bus_obj_name		varchar2 := FND_API.G_MISS_CHAR,
			 p_correlation		varchar2,
	    		 p_message		CLOB	);


END JTF_Message;

 

/
