--------------------------------------------------------
--  DDL for Package CONVERT_TEST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CONVERT_TEST" AUTHID CURRENT_USER AS
/* $Header: WMSCGUGS.pls 120.1 2005/06/15 14:12:09 appldev  $ */
PROCEDURE INVMSISB(
		   l_organization_id 	IN  	NUMBER,
		    USER_NAME           IN      VARCHAR2,
		    PASSWORD            IN      VARCHAR2,
		    x_return_status	OUT NOCOPY 	VARCHAR2,
		    x_msg_count       	OUT NOCOPY 	NUMBER,
		    x_msg_data        	OUT NOCOPY 	VARCHAR2);


PROCEDURE INVMPSSB(
                   l_organization_id   IN      NUMBER,
                   USER_NAME           IN      VARCHAR2,
		   PASSWORD            IN      VARCHAR2,
                   x_return_status     OUT NOCOPY     VARCHAR2,
                   x_msg_count         OUT NOCOPY     NUMBER,
                   x_msg_data          OUT NOCOPY     VARCHAR2);


PROCEDURE INVMPSB(
		  l_organization_id   IN      NUMBER,
		  USER_NAME           IN      VARCHAR2,
		  PASSWORD            IN      VARCHAR2,
		  x_return_status     OUT NOCOPY     VARCHAR2,
		  x_msg_count         OUT NOCOPY     NUMBER,
		  x_msg_data          OUT NOCOPY     VARCHAR2);


PROCEDURE INVMOQSB(
		   l_organization_id   IN  	NUMBER,
		   USER_NAME           IN      VARCHAR2,
  		   PASSWORD            IN      VARCHAR2,
		   x_return_status     OUT NOCOPY 	VARCHAR2,
		   x_msg_count         OUT NOCOPY 	NUMBER,
		   x_msg_data          OUT NOCOPY 	VARCHAR2);



PROCEDURE INVMMTSB(
		   l_organization_id 	IN  	NUMBER,
		   USER_NAME           IN      VARCHAR2,
		   PASSWORD            IN      VARCHAR2,
		   x_return_status	  	OUT NOCOPY 	VARCHAR2,
		   x_msg_count       	OUT NOCOPY 	NUMBER,
		   x_msg_data        	OUT NOCOPY 	VARCHAR2);




PROCEDURE INS_ERROR (
		      p_table_name         IN   VARCHAR2,
		      p_ROWID  	   IN  	VARCHAR2,
		      p_org_id             IN   NUMBER,
		      p_error_msg	   IN   VARCHAR2,
                      p_proc_name          IN   VARCHAR2
		    );

PROCEDURE LAUNCH_UPGRADE ;




END CONVERT_TEST;

 

/
