--------------------------------------------------------
--  DDL for Package GL_JOURNAL_IMPORT_TAX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_JOURNAL_IMPORT_TAX_PKG" AUTHID CURRENT_USER AS
/* $Header: glujitxs.pls 120.1 2005/05/05 01:40:42 kvora noship $ */
--
-- Name
--   gl_journal_import_tax_pkg
-- Purpose
--   to include all server side procedures and packages for
--   journal import taxes details processing
-- Notes
--
-- History
--   08/19/03	V Treiger	Created
--
--
-- Procedures
-- Name
--   Update_taxes
-- Purpose
--   wrapper to run procedure move_taxes_srs from SRS
-- Arguments
--   p_batch_name - Batch Name
PROCEDURE Update_taxes(errbuf OUT NOCOPY VARCHAR2,retcode OUT NOCOPY VARCHAR2,p_batch_name IN VARCHAR2);
--
--
-- Name
--  move_taxes_srs
-- Purpose
--   moves taxes details in SRS
-- Arguments
--   p_batch_id - Batch Id
PROCEDURE move_taxes_srs(p_batch_id IN NUMBER);
--
-- Name
--  move_taxes_hook
-- Purpose
--   moves taxes details in Journal Import hook
-- Arguments
--   p_batch_id - Batch Id
PROCEDURE move_taxes_hook(p_batch_id IN NUMBER);
-- Name
--   process_batch_list
-- Purpose
--   process separator delimited batch list by calling move_taxes
-- Arguments
--   batch_ids - List of Batch Ids
--   separator - Batch Id separator
PROCEDURE process_batch_list(p_batch_ids  IN VARCHAR2, p_separator  IN VARCHAR2);
END GL_JOURNAL_IMPORT_TAX_PKG;

 

/
