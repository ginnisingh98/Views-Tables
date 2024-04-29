--------------------------------------------------------
--  DDL for Package AD_PARALLEL_UPDATES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AD_PARALLEL_UPDATES_PKG" AUTHID CURRENT_USER as
-- $Header: adprupds.pls 120.2.12010000.1 2008/07/25 08:05:11 appldev ship $

  --
  -- update types
  --
  --        ROWID_RANGE : use range of rowids when updating
  --  ID_RANGE_BY_ROWID : use range of IDs and selectively update by rowids
  --           ID_RANGE : use range of IDs when updating

  ROWID_RANGE                CONSTANT INTEGER := 1;
  ID_RANGE_BY_ROWID          CONSTANT INTEGER := 2;
  ID_RANGE                   CONSTANT INTEGER := 3;
  ID_RANGE_SUB_RANGE         CONSTANT INTEGER := 4;
  ID_RANGE_SUB_RANGE_SQL     CONSTANT INTEGER := 5;
  ID_RANGE_SCAN_EQUI_ROWSETS CONSTANT INTEGER := 6;

  --
  -- mode for processed rows
  --   PRESERVE_PROCESSED_UNITS : do not delete processed rows, just mark them
  --                              as processed
  --   DELETE_PROCESSED_UNITS   : delete units that are processed
  --                              (applicable for ROWID_RANGE only)
  --
  PRESERVE_PROCESSED_UNITS  CONSTANT INTEGER := 1;
  DELETE_PROCESSED_UNITS    CONSTANT INTEGER := 2;

procedure initialize_rowid_range
           (X_update_type  in number,
            X_owner        in varchar2,
            X_table        in varchar2,
            X_script       in varchar2,
            X_worker_id    in number,
            X_num_workers  in number,
            X_batch_size   in number,
            X_debug_level  in number,
            X_processed_mode in number);

procedure initialize_rowid_range
           (X_update_type  in number,
            X_owner        in varchar2,
            X_table        in varchar2,
            X_script       in varchar2,
            X_worker_id    in number,
            X_num_workers  in number,
            X_batch_size   in number,
            X_debug_level  in number);

procedure initialize_id_range
           (X_update_type  in number,
            X_owner        in varchar2,
            X_table        in varchar2,
            X_script       in varchar2,
            X_ID_column    in varchar2,
            X_worker_id    in number,
            X_num_workers  in number,
            X_batch_size   in number,
            X_debug_level  in number,
            X_SQL_Stmt     in varchar2 default NULL,
            X_Begin_ID     in number   default NULL,
            X_End_ID       in number   default NULL);

procedure processed_rowid_range
           (X_rows_processed  in  number,
            X_last_rowid      in  rowid);

procedure processed_id_range
           (X_rows_processed   in  number,
            X_last_id          in  number);

procedure get_rowid_range_wrapper
           (X_start_rowid  out nocopy rowid,
            X_end_rowid    out nocopy rowid,
            X_any_rows     out nocopy integer,
            X_num_rows     in         number  default NULL,
            X_restart      in         integer default 0);

procedure get_rowid_range
           (X_start_rowid  out nocopy rowid,
            X_end_rowid    out nocopy rowid,
            X_any_rows     out nocopy boolean,
            X_num_rows     in         number  default NULL,
            X_restart      in         boolean default FALSE);

procedure get_id_range
           (X_start_id   out nocopy number,
            X_end_id     out nocopy number,
            X_any_rows   out nocopy boolean,
            X_num_rows   in         number  default NULL,
            X_restart    in         boolean default FALSE);

procedure purge_processed_units
           (X_owner        in varchar2 default NULL,
            X_table        in varchar2 default NULL,
            X_script       in varchar2 default NULL);

--
-- Procedure Delete_Update_Information
--
--   Deletes rows associated with an update from AD tables so that the update
--   is eligible for reprocessing
--
--   This procedure does an implicit commit of the transaction.
--
--   THIS API IS INTENDED TO BE USED ONLY IN CERTAIN SITUATIONS. DO NOT
--   ARBITRARILY CALL THIS API.
--

procedure delete_update_information(
            X_update_type  in number,
            X_owner        in varchar2,
            X_table        in varchar2,
            X_script       in varchar2);

--
-- ReInitialize_After_Table_Reorg
--
-- This procedure is only applicable for ROWID_RANGE processing.
--
-- It marks the update for reprocessing if it partially done and data in the
-- driving table has been reorganized
--
procedure ReInitialize_After_Table_Reorg(
            X_owner        in varchar2 default NULL,
            X_table        in varchar2 default NULL,
            X_script       in varchar2 default NULL);

end;

/
