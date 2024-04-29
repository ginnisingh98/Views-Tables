--------------------------------------------------------
--  DDL for Package Body QA_LOCATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_LOCATION" AS
/* $Header: qlthrb.plb 120.0 2005/05/24 18:25:10 appldev noship $ */

PROCEDURE qa_predel_validation (p_location_id in number) IS
    --
    -- final is the eventual dynamic SQL.  I am being extremely
    -- conservative here to make use of the array variation of
    -- dbms_sql.parse procedure.  This becomes needed if the no. of
    -- collection plans that contain Location is more than 1,600
    -- or so.
    --
    final dbms_sql.varchar2s;
    l_most_common varchar2(30);
    loc_code hr_locations_all.location_code%TYPE;  -- Incoming Location Code
    c integer;                   -- Cursor
    n integer;                   -- No. of rows returned
    l_status integer;

    --
    -- Completely modified to take advantage of the new
    -- qa_char_indexes_pkg.  Part of Bug 3930666.
    -- bso Tue Apr  5 17:50:48 PDT 2005
    --

BEGIN

    hr_utility.set_location('QA_LOCATION.QA_PREDEL_VALIDATION', 1);

    --
    -- Bug 3930666.  Construct the decode statement
    -- using the efficient qa_char_indexes_pkg.
    --
    l_status := qa_char_indexes_pkg.construct_decode_function(
        qa_ss_const.LOCATION, 'QR.', l_most_common, final);

    IF l_status = qa_char_indexes_pkg.ERR_ELEMENT_NOT_IN_USE THEN
        -- Great!  Element not in use, simply return.
        RETURN;

    ELSIF l_status < 0 THEN
        -- Extremely unusual
        hr_utility.set_message(250, 'QA_LOC_RESULTS');
        hr_utility.raise_error;

    ELSE
        -- Start the search process.
        --
        -- Find the location code for the given location_id
        --
        select location_code into loc_code
        from hr_locations_all
        where location_id = p_location_id;

        --
        -- Bug 3930666.  Use bind variable to prevent error
        -- when single-quote appears in loc_code.
        --
        -- Coding is greatly simplified using
        -- qa_char_indexes_pkg which returns a DECODE
        -- function such as DECODE(qr.plan_id, 111, qr.CHARACTER1,
        -- 112, qr.CHARACTER2, qr.CHARACTER4) or a simple
        -- qr.CHARACTER1 if all reside in the same column.
        -- All we need to do is to prefix this function with
        -- a SELECT from qa_results to check if the input
        -- loc_code (:2 below) is present.
        --
        -- bso Tue Apr  5 17:52:17 PDT 2005
        --

        final(0) := 'SELECT 1 FROM qa_plan_chars qpc, qa_results qr
            WHERE qpc.char_id = :1 AND qpc.plan_id = qr.plan_id AND :2 = ';

        c := dbms_sql.open_cursor;
        dbms_sql.parse(c, final, 0, final.last, false, dbms_sql.native);
        dbms_sql.bind_variable(c, ':1', qa_ss_const.LOCATION);
        dbms_sql.bind_variable(c, ':2', loc_code);
        n := dbms_sql.execute_and_fetch(c);
        dbms_sql.close_cursor(c);

        --
        -- n = 1 means yes it is being used, so we
        -- veto the deletion by raising an exception.
        --
        if n = 1 then
            hr_utility.set_message(250, 'QA_LOC_RESULTS');
            hr_utility.raise_error;
        end if;
    END IF;

END qa_predel_validation;

END qa_location;

/
