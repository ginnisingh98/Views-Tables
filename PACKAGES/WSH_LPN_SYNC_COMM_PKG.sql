--------------------------------------------------------
--  DDL for Package WSH_LPN_SYNC_COMM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_LPN_SYNC_COMM_PKG" AUTHID CURRENT_USER AS
/* $Header: WSHLSCMS.pls 120.1 2005/11/16 11:14:37 rvishnuv noship $ */


  --
  --
  --
  --
  -- This procedure is used to synchronize the updates and actions on LPNs in WSH
  -- to WMS
  PROCEDURE SYNC_LPNS_TO_WMS
  (
    p_in_rec             IN             WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_in_rec_type,
    x_return_status      OUT NOCOPY     VARCHAR2,
    x_out_rec            OUT NOCOPY     WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_out_rec_type
  );

  --
  -- This procedure is used to synchronize the updates on LPNs in WSH
  -- to WMS due to proration logic
  PROCEDURE SYNC_PRORATED_LPNS_TO_WMS
  (
    p_in_rec             IN             WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_in_rec_type,
    x_return_status      OUT NOCOPY     VARCHAR2,
    x_out_rec            OUT NOCOPY     WSH_GLBL_VAR_STRCT_GRP.lpn_sync_comm_out_rec_type
  );

END WSH_LPN_SYNC_COMM_PKG;

 

/
