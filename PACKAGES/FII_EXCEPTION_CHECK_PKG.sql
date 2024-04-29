--------------------------------------------------------
--  DDL for Package FII_EXCEPTION_CHECK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_EXCEPTION_CHECK_PKG" AUTHID CURRENT_USER AS
/* $Header: FIIGLECS.pls 120.1 2005/10/30 05:13:18 appldev noship $ */

----------------------------------------
-- function check_slg_setup
--
-- Check if there is any source ledger(s) setup for DBI.
-- If yes, return 0.
-- If  no, return 1, and print a message to the concurrent program output file.
----------------------------------------
FUNCTION check_slg_setup RETURN NUMBER;

FUNCTION detect_unmapped_local_vs( p_dim_short_name VARCHAR2 ) RETURN NUMBER;

END FII_EXCEPTION_CHECK_PKG;

 

/
