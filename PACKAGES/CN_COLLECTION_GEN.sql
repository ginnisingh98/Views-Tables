--------------------------------------------------------
--  DDL for Package CN_COLLECTION_GEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_COLLECTION_GEN" AUTHID CURRENT_USER AS
-- $Header: cncogens.pls 120.5 2007/09/26 19:51:22 apink ship $


--
-- Function Name
--   isParallelEnabled
-- Purpose
--   Check profile to see if Parallel DML needs to be used or not
-- History
--   10-JUL-07         Krish        Created
--

FUNCTION isParallelEnabled return boolean;
--
-- Function Name
--   get_org_append_id
-- Purpose
--   returns the user org_id preceded by an underscore, e.g. _204
-- History
--   31-MAR-00         Dave Maskell        Created
--
FUNCTION get_org_append
   RETURN VARCHAR2;
PROCEDURE set_org_id(p_org_id IN NUMBER);
PROCEDURE unset_org_id;

--
-- Procedure Name
--   collection_pkg
-- Purpose
--   This procedure generates any collection package.
-- History
--   17-MAR-00		Dave Maskell		Created
--
PROCEDURE collection_pkg (
	debug_pipe	VARCHAR2,
	debug_level	NUMBER := 1,
	x_table_map_id	cn_table_maps.table_map_id%TYPE,
	x_org_id IN NUMBER);

--
-- Procedure Name
--   collection_install
-- Purpose
--   This procedure installs the generated collection package(s)
--   for the chosen data source (table_map).
--   IF p_test = 'Y' then '_TEST' is appended to the end of the
--   package name. This allows you to test creation without overwriting
--   the live package.
-- History
--   17-MAR-00		Dave Maskell		Created
--
PROCEDURE Collection_install(
                 x_errbuf        OUT NOCOPY VARCHAR2,
                 x_retcode       OUT NOCOPY NUMBER,
	            p_table_map_id  IN  cn_table_maps.table_map_id%TYPE,
			     p_test          IN  VARCHAR2 := 'N',
				 x_org_id IN NUMBER);

PROCEDURE generate_collect_conc(
        errbuf OUT NOCOPY VARCHAR2,
        retcode OUT NOCOPY NUMBER,
        p_org_id NUMBER);

END cn_collection_gen;



/
