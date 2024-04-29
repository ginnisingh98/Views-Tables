--------------------------------------------------------
--  DDL for Package Body QA_PERFORMANCE_TEMP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_PERFORMANCE_TEMP_PKG" AS
/* $Header: qatempb.pls 120.1 2005/06/09 07:58:38 appldev  $ */


    --
    -- Utility function to parse a comma-separated list of
    -- integers into a number array.  Return the no. of
    -- elements parsed.
    --
    FUNCTION parse_integers(
        p_ids VARCHAR2,
        x_ids OUT NOCOPY dbms_sql.number_table)
        RETURN NUMBER IS

        separator CONSTANT VARCHAR2(1) := ',';
        n INTEGER;
        l_start INTEGER;
        l_comma INTEGER;
        l_length INTEGER;

    BEGIN
        n := 0;
        l_start := 1;
        l_length := length(p_ids);

        --
        -- Keeping l_start position and l_comma position
        -- variables avoids an unnecessary copy of the
        -- input variable for maximum memory performance.
        -- The following WHILE also covers the case where
        -- input p_ids is NULL, thus l_length is null and
        -- condition is not matched.
        --
        WHILE l_start <= l_length LOOP
            n := n + 1;
            l_comma := instr(p_ids, separator, l_start);
            IF l_comma > 0 THEN      -- a comma is found
                x_ids(n) := substr(p_ids, l_start, l_comma-l_start);
                l_start := l_comma+1;
            ELSE                     -- final case
                x_ids(n) := substr(p_ids, l_start);
                EXIT;
            END IF;
        END LOOP;

        RETURN n;

    END parse_integers;

    --
    -- Parse the input ID list (comma-separated) and
    -- insert each individual IDs into the temp table.
    --
    -- The input p_id_list must be a list of comma-separated
    -- integer IDs.
    --
    PROCEDURE add_ids(p_key VARCHAR2, p_id_list VARCHAR2) IS
    --
    -- Parse the ID list into an array of integers.
    -- Then use bulk operation to insert all values
    -- to the temp table.  The order is immaterial
    -- because an IN operation does not care.
    --
        l_ids dbms_sql.number_table;
    BEGIN

        IF parse_integers(p_id_list, l_ids) > 0 THEN
            FORALL i IN l_ids.FIRST .. l_ids.LAST
                INSERT INTO qa_performance_temp (key, id)
                VALUES (p_key, l_ids(i));
        END IF;

    END add_ids;


    --
    -- A simple purge API to delete the IN list values
    -- for a particular key.
    --
    PROCEDURE purge(p_key VARCHAR2) IS

    BEGIN
        --
        -- This is a full table scan operation but we
        -- do not foresee any issue because this is
        -- a temp table and there is not more than
        -- a few dozen rows maximum at any time.
        -- bso  Sat Apr 16 14:31:23 PDT 2005
        --
        DELETE FROM qa_performance_temp
        WHERE key = p_key;
    END purge;


    --
    -- Since the above are being called often from pld
    -- it is more performing to create a wrapper for
    -- purge and add with once server call.
    --
    PROCEDURE purge_and_add_ids(
        p_key VARCHAR2,
        p_id_list VARCHAR2) IS

    BEGIN
         purge(p_key);
         add_ids(p_key, p_id_list);
    END purge_and_add_ids;




   -- Bug 4345779. Audits project.
   -- Added the following methods.
   -- srhariha. Wed Jun  1 12:13:02 PDT 2005.

  PROCEDURE add_names(p_key VARCHAR2, p_names dbms_sql.VARCHAR2_TABLE) IS

    BEGIN

     IF p_names IS NOT NULL THEN
       FORALL i IN p_names.FIRST .. p_names.LAST
         INSERT INTO qa_performance_temp (key, name)
         VALUES (p_key, p_names(i));
     END IF;

  END add_names;



  PROCEDURE purge_and_add_names(p_key VARCHAR2, p_names dbms_sql.VARCHAR2_TABLE) IS

   BEGIN
        purge(p_key);
        add_names(p_key,p_names);

  END purge_and_add_names;

  -- End 4345779.

END qa_performance_temp_pkg;

/
