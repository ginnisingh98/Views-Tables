--------------------------------------------------------
--  DDL for Package EDR_ISIGN_CHECKLIST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDR_ISIGN_CHECKLIST_PVT" AUTHID CURRENT_USER AS
/* $Header: EDRVISCS.pls 120.0.12000000.1 2007/01/18 05:56:24 appldev ship $ */

-- --------------------------------------
-- API name 	: IS_CHECKLIST_REQUIRED
-- Type		: Private
-- Pre-reqs	: None
-- procedue	: return Y/N based on checklsit steup and if Y, returns checlist name and checklist version
-- Parameters
-- IN	      :	p_event_name   	VARCHAR2	event name, eg oracle.apps.gmi.item.create
--			p_event_key	VARCHAR2	event key, eg ItemNo3125
-- OUT	:	x_isRequired_checklist	VARCHAR2	Checklist status
-- OUT	:	x_checklist_name		VARCHAR2	Checklist Name
-- OUT	:	x_checklist_ver   	VARCHAR2	Checklist Version

-- ---------------------------------------


PROCEDURE IS_CHECKLIST_REQUIRED  (
	p_event_name 	       	IN 	varchar2,
	p_event_key	 	            IN   	varchar2,
	x_isRequired_checklist 	      OUT 	NOCOPY VARCHAR2,
      x_checklist_name              OUT   NOCOPY VARCHAR2,
      x_checklist_ver               OUT   NOCOPY VARCHAR2);

-- --------------------------------------
-- API name 	: IS_CHECKLIST_PRESENT
-- Type		: Private
-- Pre-reqs	: None
-- procedue	: Procedure will notify if checklist is availalb for a given file_id
-- Parameters
-- IN	      :	p_file_id   		NUMBER	file_id of iSign
-- OUT	:	x_checklist_status	VARCHAR2	Checklist Status
--                                              	Y - Checklist Present
--                                              	N - Checklist not avalable
-- ---------------------------------------


PROCEDURE IS_CHECKLIST_PRESENT  (
       	                        p_file_id	       	IN 	NUMBER,
		                        x_checklist_Status      OUT   NOCOPY VARCHAR2);


-- --------------------------------------
-- API name 	: ATTACH_CHECKLIST
-- Type		: Public
-- Pre-reqs	: None
-- procedue	: Procedure to Attach checklist to evidence store entity if available
-- Parameters
-- IN	      :	p_file_id   	NUMBER	file_id of iSign
-- OUT	:	x_return_status	VARCHAR2	Attachment Status
--                                              S - Successful
--                                              E - Error
-- ---------------------------------------


PROCEDURE ATTACH_CHECKLIST  (
	p_file_id		       	IN 	NUMBER,
	x_return_Status               OUT   NOCOPY VARCHAR2);


-- --------------------------------------
-- API name 	: DELETE_CHECKLIST
-- Type		: Public
-- Pre-reqs	: None
-- procedue	: Procedure to delete checklist attachemtn for a given iSign File
-- Parameters
-- IN	      :	p_file_id   	NUMBER	file_id of iSign
-- OUT	:	x_return_status	VARCHAR2	Delete Status
--                                              S - Successful
--                                              E - Error
-- ---------------------------------------


PROCEDURE DELETE_CHECKLIST  (
	p_file_id		       	IN 	NUMBER,
	x_return_Status               OUT   NOCOPY VARCHAR2);



END EDR_ISIGN_CHECKLIST_PVT;


 

/
