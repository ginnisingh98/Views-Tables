--------------------------------------------------------
--  DDL for Package IGS_GE_INS_SLE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_GE_INS_SLE" AUTHID CURRENT_USER AS
/* $Header: IGSGE05S.pls 115.5 2002/11/29 00:32:10 nsidana ship $ */

  --
  --
  TYPE log_entry_typ_rec IS RECORD
  (
  s_log_type IGS_GE_S_LOG_ENTRY.S_LOG_TYPE%TYPE,
  sl_key IGS_GE_S_LOG.KEY%TYPE,
  sle_key IGS_GE_S_LOG_ENTRY.KEY%TYPE,
  sle_message_name IGS_GE_S_LOG_ENTRY.MESSAGE_NAME%TYPE,
  text IGS_GE_S_LOG_ENTRY.TEXT%TYPE);
  --
  --
  TYPE t_log_entry_typ IS TABLE OF
  IGS_GE_INS_SLE.log_entry_typ_rec
  INDEX BY BINARY_INTEGER;
  --
  --
  t_log_entry t_log_entry_typ;
  --
  --
  t_log_entry_blank t_log_entry_typ;
  --
  --
  r_log_entry log_entry_typ_rec;
  --
  --
  gv_cntr BINARY_INTEGER;
  --
  -- Insert into IGS_GE_S_LOG_ENTRY from a pl/sql table.
  PROCEDURE GENP_INS_SLE(
  p_creation_dt IN OUT NOCOPY DATE )
;
  --
  -- To insert entry into PL/SQL table to allow log entries after rollback
  PROCEDURE GENP_SET_LOG_ENTRY(
  p_s_log_type IN VARCHAR2 ,
  p_sl_key IN VARCHAR2 ,
  p_sle_key IN VARCHAR2 ,
  p_sle_message_name IN VARCHAR2 ,
  p_text IN VARCHAR2 )
;
  --
  -- Initialise pl/sql table when creating IGS_GE_S_LOG_ENTRY records.
  PROCEDURE GENP_SET_LOG_CNTR
;
END IGS_GE_INS_SLE;

 

/
