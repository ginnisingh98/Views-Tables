--------------------------------------------------------
--  DDL for Package WSH_WMS_SYNC_TMP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_WMS_SYNC_TMP_PKG" AUTHID CURRENT_USER AS
/* $Header: WSHWSYTS.pls 120.0 2005/05/26 17:09:15 appldev noship $ */


  --
  --
  --
  --
  PROCEDURE MERGE
  (
    p_sync_tmp_rec      IN          wsh_glbl_var_strct_grp.sync_tmp_rec_type,
    x_return_status     OUT NOCOPY  VARCHAR2
  );
  --
  --
  PROCEDURE MERGE_BULK
  (
    p_sync_tmp_recTbl   IN          wsh_glbl_var_strct_grp.sync_tmp_recTbl_type,
    x_return_status     OUT NOCOPY  VARCHAR2,
    p_operation_type    IN          VARCHAR2 DEFAULT NULL
  );
  --
  --

END WSH_WMS_SYNC_TMP_PKG;

 

/
