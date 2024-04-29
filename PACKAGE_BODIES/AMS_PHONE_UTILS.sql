--------------------------------------------------------
--  DDL for Package Body AMS_PHONE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_PHONE_UTILS" AS
/*  $Header: amsvlphb.pls 115.8 2002/11/22 08:55:46 jieli ship $ */
--
--  Copyright (c) 2001 by Oracle Corporation
--
--  NAME
--    ams_phone_utils_body.sql - Functions to retrieve a desired phone number
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
-- get_phone_number
--
-- This function returns the phone number for the specified PARTY_ID and
-- preferred order.
--
-- Arguments:     number        (Party ID)
--                number        (Perferred order)
--
-- Returns:       varchar2      (Phone Number)
--
AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

FUNCTION get_phone(p_party_id in number, p_phone_pref_order in number)
RETURN varchar2
IS
  -- Get records
  cursor phones (c_party_id number) is
  select phone_number
  from hz_contact_points
  where owner_table_id = c_party_id
    and owner_table_name = 'HZ_PARTIES'
  order by creation_date;

  -- Party id
  n_party_id           number  := p_party_id;

  -- Phone number preferred order number
  n_phone_pref_order   number  := p_phone_pref_order;

  -- Phone Number
  n_phone_number       varchar2(60);

BEGIN

OPEN phones(n_party_id);

-- Loop only the desired number of times
--  or until out of records
for x in 1..n_phone_pref_order loop

     FETCH phones into n_phone_number;
     EXIT WHEN x = n_phone_pref_order + 1 OR phones%NOTFOUND;

end loop;

-- If we ran out of records, then return null
--  otherwise, return the phone number
if phones%NOTFOUND then
   return null;
else
   return n_phone_number;
end if;

CLOSE phones;

END get_phone;

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
RETURN varchar2
IS
  -- Get records
  cursor phones (c_party_id number) is
  select raw_phone_number
  from hz_contact_points
  where owner_table_id = c_party_id
    and owner_table_name = 'HZ_PARTIES'
  order by creation_date;

  -- Party id
  n_party_id           number  := p_party_id;

  -- Phone number preferred order number
  n_phone_pref_order   number  := p_phone_pref_order;

  -- Phone Number
  n_phone_number       varchar2(60);

BEGIN

OPEN phones(n_party_id);

-- Loop only the desired number of times
--  or until out of records
for x in 1..n_phone_pref_order loop

     FETCH phones into n_phone_number;
     EXIT WHEN x = n_phone_pref_order + 1 OR phones%NOTFOUND;

end loop;

-- If we ran out of records, then return null
--  otherwise, return the phone number
if phones%NOTFOUND then
   return null;
else
   return n_phone_number;
end if;

CLOSE phones;

END get_raw_phone;

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
RETURN date
IS
  -- Get records
  cursor phones (c_party_id number) is
  select creation_date
  from hz_contact_points
  where owner_table_id = c_party_id
    and owner_table_name = 'HZ_PARTIES'
  order by creation_date;

  -- Party id
  n_party_id           number  := p_party_id;

  -- Phone number preferred order number
  n_phone_pref_order   number  := p_phone_pref_order;

  -- Creation Date
  n_cr8_date           date;


BEGIN

OPEN phones(n_party_id);

-- Loop only the desired number of times
--  or until out of records
for x in 1..n_phone_pref_order loop

     FETCH phones into n_cr8_date;
     EXIT WHEN x = n_phone_pref_order + 1 OR phones%NOTFOUND;

end loop;

-- If we ran out of records, then return null
--  otherwise, return the creation date
if phones%NOTFOUND then
   return null;
else
   return n_cr8_date;
end if;

CLOSE phones;

END get_creation_date;

END ams_phone_utils;

/
