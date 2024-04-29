--------------------------------------------------------
--  DDL for Package Body HXC_GET_NAME
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_GET_NAME" AS
/* $Header: hxcgetnm.pkb 120.2 2005/10/04 06:20:27 nissharm noship $ */
--
-- ----------------------------------------------------------------------------+
-- |-----------------------------< get_name >---------------------------------|
-- ----------------------------------------------------------------------------+
FUNCTION get_name
  (p_person_id             in number) Return varchar2 is

  l_full_name  per_people_x.full_name%type;

  Cursor c_person is
   Select ppx.full_name
   from per_people_x ppx
   where person_id = p_person_id;

BEGIN

  /* Select ppx.full_name into l_full_name
   from per_people_x ppx
   where ppx.person_id = p_person_id;*/

   if c_person%ISOPEN then
   close c_person;
   end if;

   open c_person;
   fetch c_person into l_full_name;

   RETURN l_full_name;

   close c_person;

END get_name;

END hxc_get_name;

/
