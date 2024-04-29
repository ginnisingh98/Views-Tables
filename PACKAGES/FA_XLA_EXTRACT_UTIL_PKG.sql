--------------------------------------------------------
--  DDL for Package FA_XLA_EXTRACT_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_XLA_EXTRACT_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: FAXLAXUS.pls 120.4.12010000.4 2009/10/29 12:45:39 bridgway ship $ */



----------------------------------------------------------------------------------
-- Global Variables - public to stub programs
--
--------------------------------------------------------------------------------
G_trx_exists            boolean := false;
G_inter_trx_exists      boolean := false;
G_dep_exists            boolean := false;
G_def_exists            boolean := false;

G_fin_trx_exists        boolean := false;
G_xfr_trx_exists        boolean := false;
G_dist_trx_exists       boolean := false;
G_ret_trx_exists        boolean := false;
G_res_trx_exists        boolean := false;
G_deprn_exists          boolean := false;
G_rollback_deprn_exists boolean := false;

G_alc_enabled           boolean := false;
G_group_enabled         boolean := false;
G_sorp_enabled          boolean := false;

--------------------------------------------------------------------------------
--
-- Main Locking program
--  This is the stub called from the locking_status subscription routine
--
--------------------------------------------------------------------------------

PROCEDURE lock_assets
            (p_book_type_code  varchar2,
             p_ledger_id       number);

--------------------------------------------------------------------------------
--
-- Main UnLocking program
--  This is the stub called from the locking_status subscription routine
--
--------------------------------------------------------------------------------

PROCEDURE unlock_assets
            (p_book_type_code  varchar2,
             p_ledger_id       number);


--------------------------------------------------------------------------------
--
-- Main nonaccountable events program
--  This is the stub called from the preaccounting subscription routine
--
--------------------------------------------------------------------------------

PROCEDURE update_nonaccountable_events
              (p_book_type_code   varchar2,
               p_process_category varchar2,
               p_ledger_id        number);

--------------------------------------------------------------------------------
--
-- Main Extraction program
--  This is the stub called from the extract_status subscription routine
--
--------------------------------------------------------------------------------

PROCEDURE extract (p_accounting_mode  IN VARCHAR2);

--------------------------------------------------------------------------------

END fa_xla_extract_util_pkg;

/
