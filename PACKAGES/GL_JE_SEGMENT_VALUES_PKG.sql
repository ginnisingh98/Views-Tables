--------------------------------------------------------
--  DDL for Package GL_JE_SEGMENT_VALUES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_JE_SEGMENT_VALUES_PKG" AUTHID CURRENT_USER as
/* $Header: glijesvs.pls 120.7 2005/05/05 01:10:30 kvora ship $ */

--
-- Package
--   GL_JE_SEGMENT_VALUES_PKG
-- Purpose
--   Table handler for gl_je_segment_values table.
-- History
--   11-APR-02  D J Ogg          Created
--

  -- Procedure
  --   insert_segment_values
  -- Purpose
  --   Insert all the distinct balancing and management segment
  --   values for the selected header into the GL_JE_SEGMENT_VALUES table.
  -- History
  --   06/21/01    O Monnier      Created
  -- Arguments
  --   x_je_header_id     The journal to be used
  -- Example
  --   gl_je_segment_values_pkg.insert_segment_values( 1234 );
  -- Notes
  --
  FUNCTION insert_segment_values( x_je_header_id       NUMBER )
  RETURN NUMBER;


  -- Procedure
  --   insert_segment_values
  -- Purpose
  --   Insert the distinct balancing and management segment
  --   values if needed for the selected header and line into
  --   the GL_JE_SEGMENT_VALUES table.
  -- History
  --   06/21/01    O Monnier      Created
  -- Arguments
  --   x_je_header_id     The journal to be used
  --   x_je_line_num      The line to be used
  -- Example
  --   gl_je_segment_values_pkg.insert_segment_values( 1234, 10);
  -- Notes
  --
  FUNCTION insert_segment_values( x_je_header_id       NUMBER,
                                  x_je_line_num        NUMBER,
				  x_user_id	       NUMBER,
				  x_login_id	       NUMBER)
  RETURN NUMBER;


  -- Procedure
  --   insert_batch_segment_values
  -- Purpose
  --   Insert the distinct balancing and management segment
  --   values for the selected batch into
  --   the GL_JE_SEGMENT_VALUES table.
  -- History
  --   06/21/01    O Monnier      Created
  -- Arguments
  --   x_je_batch_id     The batch to be used
  -- Example
  --   gl_je_segment_values_pkg.insert_batch_segment_values( 12345 );
  -- Notes
  --
  FUNCTION insert_batch_segment_values( x_je_batch_id       NUMBER )
  RETURN NUMBER;


  --
  -- Procedure
  --   insert_ccid_segment_values
  -- Purpose
  --   Adds the bsv and msv row if they don't already exist for a new
  --   ccid.
  -- History
  --   11-APR-02  D. J. Ogg    Created
  -- Arguments
  --   header_id                     Journal header id
  --   ccid                          Code combination id
  PROCEDURE insert_ccid_segment_values(
			header_id				NUMBER,
			ccid					NUMBER,
                        user_id					NUMBER,
			login_id				NUMBER);


  -- Procedure
  --   delete_segment_values
  -- Purpose
  --   Delete all the distinct balancing and management segment
  --   values for the selected header in the GL_JE_SEGMENT_VALUES table.
  -- History
  --   06/21/01    O Monnier      Created
  -- Arguments
  --   x_je_header_id      The journal to be used
  -- Example
  --   gl_je_segment_values_pkg.delete_segment_values( 1234 );
  -- Notes
  --
  FUNCTION delete_segment_values( x_je_header_id       NUMBER )
  RETURN NUMBER;

  -- Procedure
  --   delete_batch_segment_values
  -- Purpose
  --   Delete the distinct balancing and management segment
  --   values for the selected batch in
  --   the GL_JE_SEGMENT_VALUES table.
  -- History
  --   06/21/01    O Monnier      Created
  -- Arguments
  --   x_je_batch_id     The batch to be used
  -- Example
  --   gl_je_segment_values_pkg.delete_batch_segment_values( 12345 );
  -- Notes
  --
  FUNCTION delete_batch_segment_values( x_je_batch_id       NUMBER )
  RETURN NUMBER;

  -- Procedure
  --   cleanup_segment_values
  -- Purpose
  --   Removes any bsv or msv rows that are no longer necessary for this
  --   journal.
  -- History
  --   11-APR-02  D. J. Ogg    Created
  -- Arguments
  --   header_id                     Journal header id
  PROCEDURE cleanup_segment_values(
			header_id				NUMBER);

  -- Procedure
  --   insert_alc_segment_values
  -- Purpose
  --   Insert the distinct balancing and management segment
  --   values for the ALC journals in the selected posting run into
  --   the GL_JE_SEGMENT_VALUES table.
  --   This routine is designed to be only called by Posting.
  -- History
  --   06/23/03    K Vora       Created
  -- Arguments
  --   x_prun_id        The posting run id to be used
  -- Example
  --   gl_je_segment_values_pkg.insert_alc_segment_values( 12345 );
  -- Notes
  --
  FUNCTION insert_alc_segment_values( x_prun_id            NUMBER,
                                      x_last_updated_by    NUMBER,
                                      x_last_update_login  NUMBER )
  RETURN NUMBER;

  -- Procedure
  --   insert_gen_line_segment_values
  -- Purpose
  --   Insert the distinct balancing and management segment
  --   values for the generated lines in a primary journal being posted.
  --   This routine is designed to be only called by Posting.
  -- History
  --   06/23/03    K Vora       Created
  -- Arguments
  --   x_je_header_id       The header to be used
  --   x_from_je_line_num   The line number from which to process
  -- Example
  --   gl_je_segment_values_pkg.insert_gen_line_segment_values( 12345 );
  -- Notes
  --
  FUNCTION insert_gen_line_segment_values( x_je_header_id       NUMBER,
                                           x_from_je_line_num   NUMBER,
                                           x_last_updated_by    NUMBER,
                                           x_last_update_login  NUMBER )
  RETURN NUMBER;

  -- Procedure
  --   insert_sl_segment_values
  -- Purpose
  --   Insert the distinct balancing and management segment
  --   values for the SL journals in the selected posting run into
  --   the GL_JE_SEGMENT_VALUES table.
  --   This routine is designed to be only called by Posting.
  -- History
  --   06/23/03    K Vora       Created
  -- Arguments
  --   x_prun_id        The posting run id to be used
  -- Example
  --   gl_je_segment_values_pkg.insert_sl_segment_values( 12345 );
  -- Notes
  --
  FUNCTION insert_sl_segment_values( x_prun_id            NUMBER,
                                     x_last_updated_by    NUMBER,
                                     x_last_update_login  NUMBER )
  RETURN NUMBER;

END GL_JE_SEGMENT_VALUES_PKG;

 

/
