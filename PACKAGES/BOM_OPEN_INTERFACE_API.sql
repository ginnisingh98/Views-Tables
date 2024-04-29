--------------------------------------------------------
--  DDL for Package BOM_OPEN_INTERFACE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_OPEN_INTERFACE_API" AUTHID CURRENT_USER AS
/* $Header: BOMPBOIS.pls 120.1 2005/06/20 01:14:31 appldev ship $ */
/***************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMPBOIS.pls
--
--  DESCRIPTION
--
--     Spec of package Bom_Open_Interface_Api
--
--  NOTES
--
--  HISTORY
--
--  22-NOV-02   Vani Hymavathi   Initial Creation
--  01-JUN-05   Bhavnesh Patel   Added Batch Id
***************************************************************************/

--import for null batch id
FUNCTION Import_BOM
(org_id	IN	NUMBER ,
all_org	IN	NUMBER:=1,
user_id	IN	NUMBER:=-1,
login_id	IN	NUMBER:=-1,
prog_appid	IN	NUMBER:=-1,
prog_id	IN	NUMBER:=-1,
req_id	IN	NUMBER:=-1,
del_rec_flag  IN	NUMBER:=1,
err_text	IN OUT NOCOPY	VARCHAR2)
return integer;

--import for given batch id
FUNCTION Import_BOM
(org_id	IN	NUMBER ,
all_org	IN	NUMBER:=1,
user_id	IN	NUMBER:=-1,
login_id	IN	NUMBER:=-1,
prog_appid	IN	NUMBER:=-1,
prog_id	IN	NUMBER:=-1,
req_id	IN	NUMBER:=-1,
del_rec_flag  IN	NUMBER:=1,
err_text	IN OUT NOCOPY	VARCHAR2,
p_batch_id  IN	NUMBER)
return integer;

End;

 

/
