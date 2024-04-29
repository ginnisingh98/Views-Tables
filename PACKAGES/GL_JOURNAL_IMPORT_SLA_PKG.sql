--------------------------------------------------------
--  DDL for Package GL_JOURNAL_IMPORT_SLA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_JOURNAL_IMPORT_SLA_PKG" AUTHID CURRENT_USER as
/* $Header: glujisls.pls 120.2 2005/05/05 01:40:28 kvora ship $ */

--
-- Package
--   GL_JOURNAL_IMPORT_SLA_PKG
-- Purpose
--   To implement various logic needed for SLA to interact with
--   Journal Import
-- History
--   15-NOV-02	D. J. Ogg	Created
--

  --
  -- Procedure
  --   delete_batches
  -- Purpose
  --   Rolls back a successful Journal Import run for SLA.  Note
  --   that this routine only works when run for a batch that was
  --   created by Journal Import where the Journal Import request
  --   was submitted by SLA.
  -- History
  --   15-NOV-02	D. J. Ogg	Created
  -- Arguments
  --   x_je_source_name		Source of data that was imported
  --   x_group_id		Group id of data that was imported
  -- Example
  --   gl_journal_import_sla_pkg.delete_batches('Payables', 1001);
  -- Notes
  --
  PROCEDURE delete_batches(x_je_source_name  VARCHAR2,
			   x_group_id        NUMBER);

  --
  -- Procedure
  --   keep_batches
  -- Purpose
  --   Rolls back a successful Journal Import run for SLA.  Note
  --   that this routine only works when run for a batch that was
  --   created by Journal Import where the Journal Import request
  --   was submitted by SLA.
  -- History
  --   15-NOV-02	D. J. Ogg	Created
  -- Arguments
  --   x_je_source_name		Source of data that was imported
  --   x_group_id		Group id of data that was imported
  --   start_posting            Indicates whether or not posting should
  --                            be started if possible.
  --   data_access_set_id       Data access set to be used during Posting
  --   req_id                   Request id of the posting run
  --                            (0 if Posting wasn't submitted or was not
  --                            submitted successfully)
  -- Example
  --   gl_journal_import_sla_pkg.keep_batches('Payables',1001,FALSE,1,reqid);
  -- Notes
  --
  PROCEDURE keep_batches(x_je_source_name             VARCHAR2,
		         x_group_id                   NUMBER,
                         start_posting                BOOLEAN,
                         data_access_set_id           NUMBER,
                         req_id            OUT NOCOPY NUMBER);

END GL_JOURNAL_IMPORT_SLA_PKG;

 

/
