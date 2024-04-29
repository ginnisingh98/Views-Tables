--------------------------------------------------------
--  DDL for Package Body WMS_LPN_CONTEXT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_LPN_CONTEXT_PVT" AS
/* $Header: WMSLCNPB.pls 115.2 2002/03/25 10:23:08 pkm ship       $ */

--  Global constant holding the package name

G_PKG_NAME    CONSTANT VARCHAR2(30) := 'wms_lpn_context_pvt';

-- This functions simply returns the context of the lpn after it has been
-- pick dropped. This function will be called by
-- wms_task_dispatch_gen.pick_drop API. This function was essential
-- because of the lpn context of 11 'picked' that was introduced in
-- 'G'. This version of the file should ONLY go to customers on
-- patchset 'G' or above. For customers on patchset 'F', use version
-- 115.1 of this file

FUNCTION return_pick_drop_lpn_context RETURN NUMBER IS

BEGIN

   RETURN wms_container_pub.lpn_context_picked;

END return_pick_drop_lpn_context;

END wms_lpn_context_pvt;


/
