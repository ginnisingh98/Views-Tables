--------------------------------------------------------
--  DDL for Package AMS_PHONE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_PHONE_UTILS" AUTHID CURRENT_USER as
/*  $Header: amsvlphs.pls 115.7 2002/11/22 08:55:47 jieli ship $  */
--
--  Copyright (c) 2001 by Oracle Corporation
--
--  NAME
--    ams_phone_utils_spec.sql - Functions to retrieve a desired phone number
--                               based on order of creation date.
--
--  DESCRIPTION
--    These functions return the phone number for the desired preferred
--    order based on the order of creation date.
--
--  NOTES
--    This is to statisfy the Advanced Outbound requirements to see phone
--    numbers 1 through 6 and because the HZ tables can not handle this
--    type of quering at it's present state.
--
--  REQUIREMENTS
--     This package MUST be created with the authority of the definer.
--          (authid definer)
--     All variables passed in must start with:   p_
--     All out variables must start with:         x_
--
--------------------------------------------------------------------------------
--  FUNCTIONS:
--     get_phone                   - Return the phone number
--     get_raw_phone               - Return the raw phone number
--     get_creation_date           - Return the creation date
--
--  PROCEDURES:
--     None at this time
--
--  PRIVATE FUNCTIONS/PROCEDURES:
--     None at this time
--
--------------------------------------------------------------------------------
--  MODIFIED   (MM/DD/YYYY)   DESCRIPTION
--  jmanzell    02/14/2001    Initial creation
--
--------------------------------------------------------------------------------
-------------     FUNCTIONS     ------------------------------------------------
--------------------------------------------------------------------------------

--
-- get_phone
--
-- This function returns the phone number for the specified PARTY_ID and
-- preferred order.
--
-- Arguments:     number        (Party ID)
--                number        (Perferred order)
--
-- Returns:       varchar2      (Phone Number)
--
FUNCTION get_phone(p_party_id in number, p_phone_pref_order in number)
RETURN varchar2;

--
-- get_raw_phone
--
-- This function returns the raw phone number for the specified PARTY_ID
-- and preferred order.
--
-- Arguments:     number        (Party ID)
--                number        (Perferred order)
--
-- Returns:       varchar2      (Raw Phone Number)
--
FUNCTION get_raw_phone(p_party_id in number, p_phone_pref_order in number)
RETURN varchar2;

--
-- get_creation_date
--
-- This function returns the creation date for the specified PARTY_ID and
-- preferred order.
--
-- Arguments:     number        (Party ID)
--                number        (Perferred order)
--
-- Returns:       date          (Creation Date)
--
FUNCTION get_creation_date(p_party_id in number, p_phone_pref_order in number)
RETURN date;
END ams_phone_utils;

 

/
