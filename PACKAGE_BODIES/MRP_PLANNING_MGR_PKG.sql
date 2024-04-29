--------------------------------------------------------
--  DDL for Package Body MRP_PLANNING_MGR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_PLANNING_MGR_PKG" AS
/* $Header: MRPLMGRB.pls 115.0 99/07/16 12:29:55 porting ship $ */

PROCEDURE Delete_All_Messages IS
BEGIN

  DELETE FROM mrp_scheduler_messages;

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
	null;

END Delete_All_Messages;

END MRP_PLANNING_MGR_PKG;

/
