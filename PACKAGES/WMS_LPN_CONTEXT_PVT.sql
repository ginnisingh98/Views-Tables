--------------------------------------------------------
--  DDL for Package WMS_LPN_CONTEXT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_LPN_CONTEXT_PVT" AUTHID CURRENT_USER AS
/* $Header: WMSLCNPS.pls 115.1 2002/03/23 11:34:12 pkm ship       $ */

-- This functions simply returns the context of the lpn after it has been
-- pick dropped. This function will be called by
-- wms_task_dispatch_gen.pick_drop API. This function was essential
-- because of the lpn context of 11 'picked' that was introduced in
-- 'G'. This version of the file should ONLY go to customers on
-- patchset 'F'. For the next version, this function will return the
-- context of 'picked'. That version will be used only by customers
-- G and above.

FUNCTION return_pick_drop_lpn_context RETURN NUMBER;

END wms_lpn_context_pvt;

 

/
