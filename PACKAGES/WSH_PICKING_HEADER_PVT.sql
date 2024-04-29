--------------------------------------------------------
--  DDL for Package WSH_PICKING_HEADER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_PICKING_HEADER_PVT" AUTHID CURRENT_USER AS
/* $Header: WSHPKHVS.pls 115.0 99/07/16 08:19:32 porting ship $ */
  PROCEDURE consolidate_pld (picking_header_id 	IN  NUMBER,
			     ret_status 	OUT NUMBER,
			     msg		OUT VARCHAR2);
  -- ret_val  0 fail, 1 success

END wsh_picking_header_pvt;

 

/
