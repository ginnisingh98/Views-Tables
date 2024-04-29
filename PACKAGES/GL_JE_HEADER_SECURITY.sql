--------------------------------------------------------
--  DDL for Package GL_JE_HEADER_SECURITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_JE_HEADER_SECURITY" AUTHID CURRENT_USER AS
/* $Header: gluhdsvs.pls 120.3 2003/04/24 01:38:16 djogg noship $ */

--
-- PUBLIC FUNCTIONS
--

  -- Procedure
  --   check_header_valid_lsv
  -- Purpose
  --   Return 'Y' if all the ledger segment values (balancing and managment)
  --   are valid for the given header and a date or 'N' otherwise.
  --   If no date is provided, the date is ignored.
  -- Returned value meanings
  --   'N' - invalid segment values
  --   'Y' - valid segment values
  -- History
  --   06/21/01    O Monnier      Created
  -- Arguments
  --   x_je_header_id     The journal to be checked
  --   x_edate            The date used to check the access
  -- Example
  --   gl_je_header_security.check_header_valid_lsv( 12345, SYSDATE );
  -- Notes
  --
  FUNCTION check_header_valid_lsv ( x_je_header_id       IN NUMBER,
                                    x_edate              IN DATE)  RETURN VARCHAR2;

  -- Procedure
  --   check_header_write_all
  -- Purpose
  --   Check both the valid ledger segment values and whether the user has
  --   write access to the header. The valid ledger segment values are
  --   checked first, then if they are valid, we check the access of the
  --   user to the header.
  --
  -- Returned value meanings
  --   'Z' - invalid segment values for the ledger
  --   'N' - valid segment values, no write access
  --   'Y' - valid segment values, write access
  --   If no date is provided, the date is ignored.
  -- History
  --   06/21/01    O Monnier      Created
  -- Arguments
  --   x_access_set_id    The access set id to be used
  --   x_je_header_id     The journal to be checked
  --   x_edate            The date used to check the validity
  -- Example
  --   gl_je_header_security.check_header_write_all( 12345, SYSDATE );
  -- Notes
  --
  FUNCTION check_header_write_all ( x_access_set_id    IN NUMBER,
                                    x_je_header_id     IN NUMBER,
                                    x_edate            IN DATE)  RETURN VARCHAR2;

END gl_je_header_security;

 

/
