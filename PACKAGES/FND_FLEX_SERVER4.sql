--------------------------------------------------------
--  DDL for Package FND_FLEX_SERVER4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_FLEX_SERVER4" AUTHID CURRENT_USER AS
/* $Header: AFFFSV4S.pls 120.1.12010000.2 2017/02/13 22:31:10 tebarnes ship $ */


/* ------------------------------------------------------------------------- */
/*			Internal functions.				     */
/*	These functions are only used within flex and are not to be used     */
/*	by anyone else.  The functions are not supported in any manner	     */
/*	and their arguments and functionality are subject to change 	     */
/*	without notice.						 	     */
/* ------------------------------------------------------------------------  */

PROCEDURE descval_engine
  (user_apid	   IN  NUMBER,
   user_resp	   IN  NUMBER,
   userid	   IN  NUMBER,
   flex_app_sname  IN  VARCHAR2,
   desc_flex_name  IN  VARCHAR2,
   val_date	   IN  DATE,
   invoking_mode   IN  VARCHAR2,
   allow_nulls	   IN  BOOLEAN,
   update_table	   IN  BOOLEAN,
   ignore_active   IN  BOOLEAN,
   concat_segs	   IN  VARCHAR2,
   vals_not_ids	   IN  BOOLEAN,
   use_column_def  IN  BOOLEAN,
   column_def	   IN  FND_FLEX_SERVER1.ColumnDefinitions,
   rowid_in	   IN  ROWID,
   alt_tbl_name    IN  VARCHAR2,
   data_field_name IN  VARCHAR2,
   srs_appl_id     IN  NUMBER DEFAULT NULL,
   srs_req_id      IN  NUMBER DEFAULT NULL,
   srs_pgm_id      IN  NUMBER DEFAULT NULL,
   nvalidated	   OUT nocopy NUMBER,
   displayed_vals  OUT nocopy FND_FLEX_SERVER1.ValueArray,
   stored_vals	   OUT nocopy FND_FLEX_SERVER1.ValueArray,
   segment_ids	   OUT nocopy FND_FLEX_SERVER1.ValueIdArray,
   descriptions	   OUT nocopy FND_FLEX_SERVER1.ValueDescArray,
   desc_lengths	   OUT nocopy FND_FLEX_SERVER1.NumberArray,
   seg_colnames	   OUT nocopy FND_FLEX_SERVER1.TabColArray,
   seg_coltypes	   OUT nocopy FND_FLEX_SERVER1.CharArray,
   segment_types   OUT nocopy FND_FLEX_SERVER1.SegFormats,
   displayed_segs  OUT nocopy FND_FLEX_SERVER1.DisplayedSegs,
   seg_delimiter   OUT nocopy VARCHAR2,
   v_status	   OUT nocopy NUMBER,
   seg_codes	   OUT nocopy VARCHAR2,
   err_segnum	   OUT nocopy NUMBER);

/* ------------------------------------------------------------------------ */

-- Utilities for initializing column definition structures.
--

  PROCEDURE init_coldef(column_defn OUT nocopy FND_FLEX_SERVER1.ColumnDefinitions);

  PROCEDURE init_colvals(column_vals OUT nocopy FND_FLEX_SERVER1.ColumnValues);

/* ------------------------------------------------------------------------ */

END fnd_flex_server4;

/
