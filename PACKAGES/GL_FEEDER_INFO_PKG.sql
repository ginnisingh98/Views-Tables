--------------------------------------------------------
--  DDL for Package GL_FEEDER_INFO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_FEEDER_INFO_PKG" AUTHID CURRENT_USER AS
/* $Header: glapfps.pls 120.3.12010000.1 2008/07/28 13:21:17 appldev ship $ */
--
-- Package
--   gl_feeder_info_pkg
-- Purpose
--   To implement a dummy package that will overwrite by other product.
-- History
--   15-SEP-94	ERumanan	Created.
--

  --
  -- Procedure
  --   get_enc_id_and_name
  -- Purpose
  --   Gets encumbrance id and name
  -- History
  --   01-SEP-94  ERumanan  Created
  -- Example
  --   gl_feeder_info_pkg.get_enc_id_and_name( req_id, po_id, req_name,
  --     po_name, oth_name );
  -- Notes
  --
  PROCEDURE get_enc_id_and_name( x_req_id   IN OUT NOCOPY NUMBER,
	                         x_po_id    IN OUT NOCOPY NUMBER,
	                         x_req_name IN OUT NOCOPY VARCHAR2,
                                 x_po_name  IN OUT NOCOPY VARCHAR2,
	                         x_oth_name IN OUT NOCOPY VARCHAR2);

END gl_feeder_info_pkg;

/
