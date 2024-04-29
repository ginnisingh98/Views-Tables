--------------------------------------------------------
--  DDL for Package GCS_LEX_MAP_GL_APPLY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_LEX_MAP_GL_APPLY_PKG" AUTHID CURRENT_USER AS
/* $Header: gcsgllxs.pls 115.5 2003/10/15 18:46:00 mikeward noship $ */
--
-- Package
--   gcs_lex_map_gl_apply_pkg
-- Purpose
--   Package procedures for Lexical Mapping API for GL Interface. This
--   is used for an SRS request.
-- History
--   29-MAY-03	M Ward		Created
--

  --
  -- Procedure
  --   Apply_Transformation
  -- Purpose
  --   Applies the mapping specified to a GL Interface table listed in
  --   GL_INTERFACE_CONTROL, affecting rows with the given Group ID. This may
  --   also automatically run Journal Import following a successful transform,
  --   with options for creating summary journals and importing descriptive
  --   flexfields specified in the parameters.
  -- Arguments
  --   p_rule_set_id	ID of the Lexical Mapping to apply.
  --   p_source		Source of the rows to affect in the interface table.
  --   p_group_id	Group ID of the rows to affect in the interface table.
  --   p_auto_ji	Automatically kick off Journal Import.
  --   p_create_sum_jou	Create Summary Journals option for JI.
  --   p_import_dff	Import Descriptive Flexfields option for JI.
  -- Example
  --   GCS_LEX_MAP_GL_APPLY_PKG.Apply_Transformation
  --     (err_buf, ret_code, 111, 10000, 'Consolidation', 'Y', 'N', 'N')
  -- Notes
  --
  PROCEDURE Apply_Transformation(	x_errbuf	OUT NOCOPY VARCHAR2,
					x_retcode	OUT NOCOPY VARCHAR2,
					p_rule_set_id		NUMBER,
					p_source		VARCHAR2,
					p_group_id		NUMBER,
					p_auto_ji		VARCHAR2,
					p_create_sum_jou	VARCHAR2,
					p_import_dff		VARCHAR2);

END GCS_LEX_MAP_GL_APPLY_PKG;

 

/
