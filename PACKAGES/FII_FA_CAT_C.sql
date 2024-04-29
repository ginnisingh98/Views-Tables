--------------------------------------------------------
--  DDL for Package FII_FA_CAT_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_FA_CAT_C" AUTHID CURRENT_USER AS
/* $Header: FIIFACATS.pls 120.1 2005/10/30 05:05:59 appldev noship $ */

TYPE num_tbl  IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE v30_tbl  IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
TYPE date_tbl IS TABLE OF DATE INDEX BY BINARY_INTEGER;


-- ---------------------------------------------------------------
-- Public procedures and Functions;
-- ---------------------------------------------------------------

------------------------------------------------------------------
-- FUNCTION NEW_CAT_IN_FA
------------------------------------------------------------------
FUNCTION NEW_CAT_IN_FA RETURN BOOLEAN;

-----------------------------------------------------------------
-- PROCEDURE MAIN
-----------------------------------------------------------------
PROCEDURE Main (errbuf             IN OUT  NOCOPY VARCHAR2,
                retcode            IN OUT  NOCOPY VARCHAR2,
                pmode              IN             VARCHAR2);

END FII_FA_CAT_C;

 

/
