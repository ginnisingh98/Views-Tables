--------------------------------------------------------
--  DDL for Package PO_INTERFACE_ERRORS_UTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_INTERFACE_ERRORS_UTL" AUTHID CURRENT_USER AS
/* $Header: PO_INTERFACE_ERRORS_UTL.pls 120.0 2005/07/20 10:54 bao noship $ */


PROCEDURE init_errors_tbl;

PROCEDURE add_to_errors_tbl
( p_err_type IN VARCHAR2,
  p_err_rec IN PO_INTERFACE_ERRORS%ROWTYPE
);

PROCEDURE flush_errors_tbl;

FUNCTION get_error_count RETURN NUMBER;

END PO_INTERFACE_ERRORS_UTL;

 

/
