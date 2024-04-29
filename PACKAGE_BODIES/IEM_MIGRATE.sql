--------------------------------------------------------
--  DDL for Package Body IEM_MIGRATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_MIGRATE" as
/* $Header: iemmigrb.pls 120.2 2005/08/22 11:18:27 appldev ship $ */

G_PKG_NAME CONSTANT varchar2(30) :='IEM_MIGRATE ';
PROCEDURE START_PROCESS(
		   p_api_version_number in number,
 		   p_init_msg_list  IN   VARCHAR2 ,
	    	   p_commit	    IN   VARCHAR2 ,
		   x_return_status	OUT NOCOPY varchar2
			 	) IS
BEGIN
	null;
END	 START_PROCESS;
end IEM_MIGRATE;

/
