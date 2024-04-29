--------------------------------------------------------
--  DDL for Package GL_CONC_CONTROL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_CONC_CONTROL_PKG" AUTHID CURRENT_USER AS
/*  $Header: glicurcs.pls 120.2 2003/04/24 01:28:06 djogg ship $ */
--
-- Package
--   GL_CONC_CONTROL_PKG
-- Purpose
--   To create GL_CONC_CONTROL_PKG package.
-- History
--   12.01.93   E. Rumanang   Created
--

  --
  -- Procedure
  --   insert_conc_ledger
  -- Purpose
  --   Insert rows into GL_CONCURRENCY_CONTROL table for the new
  --   created ledger.
  -- History
  --   12.01.93   E. Rumanang   Created
  -- Arguments
  --   x_ledger_id          The id of the new ledger.
  --   x_last_update_date	The who's last_update_date.
  --   x_last_updated_by	The who's last_updated_by.
  --   x_creation_date		The who's creation_date.
  --   x_created_by		The who's created_by.
  --   x_last_update_login	The who's last_update_login.
  -- Example
  --   GL_CONC_CONTROL_PKG.insert_conc_ledger(
  --     :block.ledger_id, :block.last_update_date,
  --     :block.last_updated_by, :block.creation_date,
  --     :block.created_by, :block.last_update_login );
  -- Notes
  --
  PROCEDURE insert_conc_ledger(
    x_ledger_id                 NUMBER,
    x_last_update_date          DATE,
    x_last_updated_by           NUMBER,
    x_creation_date             DATE,
    x_created_by                NUMBER,
    x_last_update_login         NUMBER );


  --
  -- Procedure
  --   insert_conc_subs
  -- Purpose
  --   Insert rows into GL_CONCURRENCY_CONTROL table for the new
  --   created subsidiaries.
  -- History
  --   12.04.96   M. Demirkol   Created
  -- Arguments
  --   x_subsidiary_id		The id of the new subsidiary.
  --   x_last_update_date	The who's last_update_date.
  --   x_last_updated_by	The who's last_updated_by.
  --   x_creation_date		The who's creation_date.
  --   x_created_by		The who's created_by.
  --   x_last_update_login	The who's last_update_login.
  -- Example
  --   GL_CONC_CONTROL_PKG.insert_conc_subs(
  --     :block.subsidiary_id, :block.last_update_date,
  --     :block.last_updated_by, :block.creation_date,
  --     :block.created_by, :block.last_update_login );
  -- Notes
  --
  PROCEDURE insert_conc_subs(
    x_subsidiary_id             NUMBER,
    x_last_update_date          DATE,
    x_last_updated_by           NUMBER,
    x_creation_date             DATE,
    x_created_by                NUMBER,
    x_last_update_login         NUMBER );


END GL_CONC_CONTROL_PKG;

 

/
