--------------------------------------------------------
--  DDL for Package GL_AUTO_ALLOC_BHD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_AUTO_ALLOC_BHD_PKG" AUTHID CURRENT_USER as
/* $Header: glialhds.pls 120.3 2005/05/05 00:59:05 kvora ship $ */

--
-- Package
--   GL_AUTO_ALLOC_BHD_PKG
-- Purpose
--   To implement various data caculation needed for the
--   gl_auto_alloc_bat_hist_det table
-- History
--   10-19-98  K Chang          Created.
--

  --
  -- Procedure
  --   populate_fields
  -- Purpose
  --   Gets all of the data necessary for post-query
  -- History
  --   19-OCT-98  K. Chang    Created
  -- Arguments
  --   p_request_id	 	The auto allocation concurrent request id
  --   s_number			The sequence in which batch is to be
  --				generated for allocation sets
  --   requset_id		The request ID for each concurrrent request
  --				submitted for a batch in allocation set
  -- Notes
  --
  PROCEDURE  populate_fields(p_request_id 		IN NUMBER,
			     s_number 			IN NUMBER,
                             request_id			IN OUT NOCOPY	NUMBER);


END GL_AUTO_ALLOC_BHD_PKG;

 

/
