--------------------------------------------------------
--  DDL for Package QA_PERFORMANCE_TEMP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_PERFORMANCE_TEMP_PKG" AUTHID CURRENT_USER AS
/* $Header: qatemps.pls 120.1 2005/06/09 07:54:49 appldev  $ */

    --
    -- This is a package that will be used as a table
    -- handler or utility for accessing the
    -- qa_performance_temp global temp table.  This
    -- table is used mainly for SQL Bind Compliance.
    -- When there is an IN list where we do not know
    -- of the no. of binds in advance (for example,
    -- this happens a lot in transaction integration,
    -- when we do not know the no. of applicable plans
    -- during design time), then the values to be
    -- bound would be inserted into this temp table.
    -- The original SQL is rewritten to use an IN
    -- sub-select query.  See info in the SQL Bind
    -- Compliance FAQ:
    -- http://www-apps.us.oracle.com/atg/plans/r1159/sqlbindfaq.htm
    --
    -- bso Sat Apr 16 14:24:56 PDT 2005
    --

    --
    -- Utility function to parse a comma-separated list of
    -- integers into a number array.  Return the no. of
    -- elements parsed.  Can be re-used by any other logic.
    --
    -- The incoming p_ids should be a comma-separated list
    -- of integers.  In the event of double commas, such as
    -- '1,2,,3,4' a NULL element will occur in position 3 of
    -- the returned array as expected.  In case of one single
    -- leading comma, such as ',1,2,3'.  It will be ignored
    -- and an array of 3 elements will be returned.
    --
    FUNCTION parse_integers(
        p_ids VARCHAR2,
        x_ids OUT NOCOPY dbms_sql.number_table)
        RETURN NUMBER;

    --
    -- Parse the input ID list (comma-separated) and
    -- insert each individual IDs into the temp table.
    --
    PROCEDURE add_ids(p_key VARCHAR2, p_id_list VARCHAR2);

    --
    -- A simple purge API to delete the IN list values
    -- for a particular key.
    --
    PROCEDURE purge(p_key VARCHAR2);

    --
    -- Since the above are being called often from pld
    -- it is more performing to create a wrapper for
    -- purge and add with once server call.
    --
    PROCEDURE purge_and_add_ids(p_key VARCHAR2, p_id_list VARCHAR2);


   -- Bug 4345779. Audits project.
   -- Added the following methods.
   -- srhariha. Wed Jun  1 12:13:02 PDT 2005.

   PROCEDURE purge_and_add_names(p_key VARCHAR2, p_names dbms_sql.VARCHAR2_TABLE);


   -- End 4345779. Audits project.
END qa_performance_temp_pkg;

 

/
