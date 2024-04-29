--------------------------------------------------------
--  DDL for Package Body PER_ZA_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ZA_UTILITY_PKG" AS
/* $Header: pezautly.pkb 120.4 2005/08/17 10:47:27 nragavar noship $ */
/* Copyright (c) Oracle Corporation 2002. All rights reserved. */
/*
   PRODUCT
      Oracle Human Resources - ZA Utility Package
   NAME
      pezautly.pkb

   DESCRIPTION
      .

   PUBLIC FUNCTIONS
      per_za_table_meaning
         Function returns value from the specific user table for the
         specified business group.  Function uses the passed Effective date
         else it picks up from Fnd_Sessions Table for fetching from the
         date tracked User table rows and User table column values.
         References:
            PER_ZA_LEARNERSHIP_AGREEMENT_V

   PRIVATE FUNCTIONS
      <none>
   NOTES
      .

   MODIFICATION HISTORY
   Person        Date        Version Bug     Comments
   ------------- ----------- ------- ------- -------------------------------
   Nageswara     24/06/2005  115.4   4346970 Added new procedure insert_rr_value
   J.N. Louw     22/11/2002  115.5   2224332 Updated maintain_ipv_links
   J.N. Louw     07/11/2002  115.4   2224332 Added maintain_ipv_links
                                             insert_ipv_link
                                             insert_ee_value
   L. Kloppers   17/10/2002  115.3           Added PROCEDURE za_term_cat_update
                                             as a dummy for initial Core HR testing
   L. Kloppers   06/05/2002  115.2   2266156 Added Exception handling to
                                             FUNCTION get_table_value
   L. Kloppers   02/05/2002  115.1   2266156 Added overloaded version of
                                             FUNCTION get_table_value
   J.N. Louw     25/04/2002  115.0   2266156 New version of the package
                                             For previous history see
                                             pezatbme.pkh

*/

----------------------------------------------------------------------------
-- Package Global Value
----------------------------------------------------------------------------
g_leg_code   varchar2(2) := 'ZA';
g_Legislation_Code varchar2(2);
g_cached           boolean := FALSE;
g_effective_date   date    := null;

-------------------------------------------------------------------------------
-- ZA_TERM_CAT_UPDATE
-------------------------------------------------------------------------------
PROCEDURE za_term_cat_update (
          p_existing_leaving_reason IN hr_lookups.lookup_code%TYPE
        , p_seeded_leaving_reason   IN hr_lookups.lookup_code%TYPE
   )
AS
-------------------------------------------------------------------------------
BEGIN --                          MAIN                                       --
-------------------------------------------------------------------------------
   hr_utility.set_location('per_za_utility_pkg.za_term_cat_update',1);
   hr_utility.set_location('per_za_utility_pkg.za_term_cat_update',2);

EXCEPTION
   WHEN OTHERS THEN
      hr_utility.set_location('per_za_utility_pkg.za_term_cat_update',3);
      hr_utility.set_message(801,'Sql Err Code: '||TO_CHAR(SQLCODE));
      hr_utility.raise_error;
-------------------------------------------------------------------------------
END za_term_cat_update;


----------------------------------------------------------------------------
-- PER_ZA_TABLE_MEANING
----------------------------------------------------------------------------
FUNCTION per_za_table_meaning (
           p_table_name        in varchar2
         , p_column            in varchar2
         , p_value             in varchar2
         , p_business_group_id in number
         , p_effective_date    in date
         ) RETURN VARCHAR2
AS
   l_effective_date    date;
   l_meaning           varchar2(80);
BEGIN
    -- Use either the supplied date, or the date from fnd_sessions
    --
    if (p_effective_date is null) then
        if (g_effective_date is null) then
            begin
                select effective_date
                into   g_effective_date
                from   fnd_sessions
                where  session_id = userenv('sessionid');
            end;
        end if;
        l_effective_date := g_effective_date;
    else
        l_effective_date := p_effective_date;
    end if;
    --
    -- get the legislation code for the specified
    -- business group
    begin
        if g_cached = FALSE THEN
          select legislation_code
          into   g_Legislation_Code
          from   per_business_groups
          where  business_group_id = P_Business_Group_id;
          g_cached := TRUE;
        end if;
    end;


    --Fetch the Table Meaning for the specific User Table
    --for the specified Business group id.
    begin
        select  pur.row_low_range_or_name
        into    l_meaning
        from    pay_user_column_instances_f        puci,
                pay_user_columns                   puc ,
                pay_user_rows_f                    pur ,
                pay_user_tables                    put
   where   put.user_table_name              = p_table_name
        and     puc.user_table_id                = put.user_table_id
        and     pur.user_table_id                = put.user_table_id
        and     puci.user_row_id                 = pur.user_row_id
        and     puci.user_column_id              = puc.user_column_id
        and     puc.user_column_name             = p_column
        and     puci.value           = p_value
        and     l_effective_date  between pur.effective_start_date
   and     pur.effective_end_date
        and     l_effective_date  between puci.effective_start_date
   and     puci.effective_end_date
        and     nvl (puci.business_group_id, P_Business_Group_id)
        = P_Business_Group_id
        and     nvl (puci.legislation_code, g_Legislation_Code)
        = g_Legislation_Code;
        exception
        when no_data_found then
            l_meaning := null;
    end;

    return l_meaning;
END per_za_table_meaning;

----------------------------------------------------------------------------
-- CHK_ENTRY_IN_LOOKUP
----------------------------------------------------------------------------
FUNCTION chk_entry_in_lookup (
    p_lookup_type    IN  hr_leg_lookups.lookup_type%TYPE
  , p_entry_val      IN  hr_leg_lookups.meaning%TYPE
  , p_effective_date IN  hr_leg_lookups.start_date_active%TYPE
  , p_message        OUT NOCOPY VARCHAR2
  ) RETURN VARCHAR2
AS

   CURSOR c_entry_in_lookup IS
   select 'X'
     from hr_leg_lookups hll
    where hll.LOOKUP_TYPE  = p_lookup_type
      and hll.meaning      = p_entry_val
      and hll.enabled_flag = 'Y'
      and p_effective_date between nvl(hll.start_date_active, p_effective_date)
                               and nvl(hll.end_date_active, p_effective_date);
   CURSOR c_lookup_values IS
   select hll.meaning
     from hr_leg_lookups hll
    where hll.LOOKUP_TYPE  = p_lookup_type
      and hll.enabled_flag = 'Y'
      and p_effective_date between nvl(hll.start_date_active, p_effective_date)
                               and nvl(hll.end_date_active, p_effective_date)
    order by hll.lookup_code;

   l_found_value_in_lookup VARCHAR2(1);
   -- There is 255 character limit on the error screen
   l_msg                   VARCHAR2(255) := ' ';

BEGIN
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
   hr_utility.set_location('per_za_utility_pkg.chk_entry_in_lookup',1);

   -- Check if the value exists in the lookup
   OPEN c_entry_in_lookup;
      hr_utility.set_location('per_za_utility_pkg.chk_entry_in_lookup',2);

      FETCH c_entry_in_lookup INTO l_found_value_in_lookup;
      IF c_entry_in_lookup%FOUND THEN
         hr_utility.set_location('per_za_utility_pkg.chk_entry_in_lookup',3);
         l_found_value_in_lookup := 'Y';
      ELSE
         hr_utility.set_location('per_za_utility_pkg.chk_entry_in_lookup',4);
         l_found_value_in_lookup := 'N';
      END IF;
   CLOSE c_entry_in_lookup;

   hr_utility.set_location('per_za_utility_pkg.chk_entry_in_lookup',5);

   -- If the value did not exist, create a message with all the
   -- possible value in the lookup
   IF l_found_value_in_lookup = 'N' THEN
      hr_utility.set_location('per_za_utility_pkg.chk_entry_in_lookup',6);

      FOR v_lookup_values IN c_lookup_values LOOP
         l_msg := l_msg||', '||v_lookup_values.meaning;
      END LOOP;

      hr_utility.set_location('per_za_utility_pkg.chk_entry_in_lookup',7);

      l_msg := substr(l_msg,3,215);
      l_msg := 'Value must be one of the following: '||l_msg;

   END IF;

   hr_utility.set_location('per_za_utility_pkg.chk_entry_in_lookup',8);

   -- Setup Out variables and Return statements
   p_message := l_msg;
   RETURN l_found_value_in_lookup;

EXCEPTION
   WHEN OTHERS THEN
      IF c_entry_in_lookup%ISOPEN THEN
         CLOSE c_entry_in_lookup;
      END IF;
      hr_utility.set_location('per_za_utility_pkg.chk_entry_in_lookup',9);
      hr_utility.trace('Sql error code: '||TO_CHAR(SQLCODE));
      hr_utility.trace('Sql error msg: '||SUBSTR(SQLERRM(SQLCODE), 1, 100));
      hr_utility.raise_error;

END chk_entry_in_lookup;


----------------------------------------------------------------------------
-- GET_TABLE_VALUE
----------------------------------------------------------------------------
FUNCTION get_table_value (
     p_table_name        IN VARCHAR2
   , p_col_name          IN VARCHAR2
   , p_row_value         IN VARCHAR2
   , p_effective_date    IN DATE
   ) RETURN VARCHAR2
AS
   l_effective_date    date;
   l_range_or_match    pay_user_tables.range_or_match%type;
   l_table_id          pay_user_tables.user_table_id%type;
   l_value             pay_user_column_instances_f.value%type;

begin
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
   --
   -- Use either the supplied date, or the date from fnd_sessions
   --
   if (p_effective_date is null) then
      begin
         hr_utility.set_location ('hruserdt.get_table_value', 1);
         select effective_date
           into l_effective_date
           from fnd_sessions
          where session_id = userenv('sessionid');
      end;
   else
      l_effective_date := p_effective_date;
   end if;
   --
   -- get the type of query to be performed, either range or match
   --
   hr_utility.set_location ('hruserdt.get_table_value', 3);
   select tab.range_or_match
        , tab.user_table_id
     into l_range_or_match
        , l_table_id
     from pay_user_tables tab
    where upper(tab.user_table_name) = upper(p_table_name)
      and tab.legislation_code       = g_leg_code;
   --
   if (l_range_or_match = 'M') then       -- matched
      begin
         hr_utility.set_location ('hruserdt.get_table_value', 4);
         select CINST.value
           into l_value
           from pay_user_column_instances_f        CINST
              , pay_user_columns                   C
              , pay_user_rows_f                    R
              , pay_user_tables                    TAB
          where TAB.user_table_id                = l_table_id
            and C.user_table_id                  = TAB.user_table_id
            and C.legislation_code               = g_leg_code
            and upper (C.user_column_name)       = upper (p_col_name)
            and CINST.user_column_id             = C.user_column_id
            and R.user_table_id                  = TAB.user_table_id
            and l_effective_date           between R.effective_start_date
                                               and R.effective_end_date
            and R.legislation_code                 = g_leg_code
            and decode
                 ( TAB.user_key_units
                 , 'D', to_char(fnd_date.canonical_to_date(p_row_value))
                 , 'N', p_row_value
                 , 'T', upper (p_row_value)
                 , null
                 )                           = decode
                                                     ( TAB.user_key_units
                                                     , 'D', to_char(fnd_date.canonical_to_date(R.row_low_range_or_name))
                                                     , 'N', R.row_low_range_or_name
                                                     , 'T', upper (R.row_low_range_or_name)
                                                     , null
                                                     )
            and CINST.user_row_id                = R.user_row_id
            and l_effective_date           between CINST.effective_start_date
                                               and CINST.effective_end_date
            and CINST.legislation_code           = g_leg_code;
         --
      return l_value;

      exception

            when NO_DATA_FOUND then

                 return l_value;

      end;
   else                                   -- range
      begin
         hr_utility.set_location ('hruserdt.get_table_value', 5);
         select CINST.value
           into l_value
           from pay_user_column_instances_f        CINST
              , pay_user_columns                   C
              , pay_user_rows_f                    R
              , pay_user_tables                    TAB
          where TAB.user_table_id                = l_table_id
            and C.user_table_id                  = TAB.user_table_id
            and C.legislation_code               = g_leg_code
            and upper (C.user_column_name)       = upper (p_col_name)
            and CINST.user_column_id             = C.user_column_id
            and R.user_table_id                  = TAB.user_table_id
            and l_effective_date           between R.effective_start_date
                                               and R.effective_end_date
            and R.legislation_code               = g_leg_code
            and fnd_number.canonical_to_number (p_row_value)
                                           between fnd_number.canonical_to_number (R.row_low_range_or_name)
                                               and fnd_number.canonical_to_number (R.row_high_range)
            and TAB.user_key_units               = 'N'
            and CINST.user_row_id                = R.user_row_id
            and l_effective_date           between CINST.effective_start_date
                                               and CINST.effective_end_date
            and CINST.legislation_code           = g_leg_code;
         --
      return l_value;

      exception

            when NO_DATA_FOUND then

                 return l_value;

      end;
   end if;

end get_table_value;

----------------------------------------------------------------------------
-- GET_TABLE_VALUE  Overloaded version to select for a Business Group
-- The function is meant for selecting from a Legislative User Table, with
-- Legislative Columns, but User (or Business Group) Rows and Values
----------------------------------------------------------------------------
FUNCTION get_table_value (
     p_table_name        IN VARCHAR2
   , p_col_name          IN VARCHAR2
   , p_row_value         IN VARCHAR2
   , p_effective_date    IN DATE
   , p_business_group_id IN VARCHAR2
   ) RETURN VARCHAR2
AS
   l_effective_date    date;
   l_range_or_match    pay_user_tables.range_or_match%type;
   l_table_id          pay_user_tables.user_table_id%type;
   l_value             pay_user_column_instances_f.value%type;

begin
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
   --
   -- Use either the supplied date, or the date from fnd_sessions
   --
   if (p_effective_date is null) then
      begin
         hr_utility.set_location ('hruserdt.get_table_value', 1);
         select effective_date
           into l_effective_date
           from fnd_sessions
          where session_id = userenv('sessionid');
      end;
   else
      l_effective_date := p_effective_date;
   end if;
   --
   -- get the type of query to be performed, either range or match
   --
   hr_utility.set_location ('hruserdt.get_table_value', 3);
   select tab.range_or_match
        , tab.user_table_id
     into l_range_or_match
        , l_table_id
     from pay_user_tables tab
    where upper(tab.user_table_name) = upper(p_table_name)
      and tab.legislation_code       = g_leg_code;
   --
   if (l_range_or_match = 'M') then       -- matched
      begin
         hr_utility.set_location ('hruserdt.get_table_value', 4);
         select CINST.value
           into l_value
           from pay_user_column_instances_f        CINST
              , pay_user_columns                   C
              , pay_user_rows_f                    R
              , pay_user_tables                    TAB
          where TAB.user_table_id                = l_table_id
            and C.user_table_id                  = TAB.user_table_id
            and C.legislation_code               = g_leg_code
            and upper (C.user_column_name)       = upper (p_col_name)
            and CINST.user_column_id             = C.user_column_id
            and R.user_table_id                  = TAB.user_table_id
            and l_effective_date           between R.effective_start_date
                                               and R.effective_end_date
            and R.business_group_id              = p_business_group_id
            and decode
                 ( TAB.user_key_units
                 , 'D', to_char(fnd_date.canonical_to_date(p_row_value))
                 , 'N', p_row_value
                 , 'T', upper (p_row_value)
                 , null
                 )                           = decode
                                                     ( TAB.user_key_units
                                                     , 'D', to_char(fnd_date.canonical_to_date(R.row_low_range_or_name))
                                                     , 'N', R.row_low_range_or_name
                                                     , 'T', upper (R.row_low_range_or_name)
                                                     , null
                                                     )
            and CINST.user_row_id                = R.user_row_id
            and l_effective_date           between CINST.effective_start_date
                                               and CINST.effective_end_date
            and CINST.business_group_id         = p_business_group_id;
         --
      return l_value;

      exception

            when NO_DATA_FOUND then

                 return l_value;

      end;
   else                                   -- range
      begin
         hr_utility.set_location ('hruserdt.get_table_value', 5);
         select CINST.value
           into l_value
           from pay_user_column_instances_f        CINST
              , pay_user_columns                   C
              , pay_user_rows_f                    R
              , pay_user_tables                    TAB
          where TAB.user_table_id                = l_table_id
            and C.user_table_id                  = TAB.user_table_id
            and C.legislation_code               = g_leg_code
            and upper (C.user_column_name)       = upper (p_col_name)
            and CINST.user_column_id             = C.user_column_id
            and R.user_table_id                  = TAB.user_table_id
            and l_effective_date           between R.effective_start_date
                                               and R.effective_end_date
            and R.business_group_id             = p_business_group_id
            and fnd_number.canonical_to_number (p_row_value)
                                           between fnd_number.canonical_to_number (R.row_low_range_or_name)
                                               and fnd_number.canonical_to_number (R.row_high_range)
            and TAB.user_key_units               = 'N'
            and CINST.user_row_id                = R.user_row_id
            and l_effective_date           between CINST.effective_start_date
                                               and CINST.effective_end_date
            and CINST.business_group_id         = p_business_group_id;
         --
      return l_value;

      exception

            when NO_DATA_FOUND then

                 return l_value;

      end;
   end if;

end get_table_value;

-------------------------------------------------------------------------------
-- insert_ipv_link
-- This procedure handles the insert of values into pay_link_input_values_f
-------------------------------------------------------------------------------
PROCEDURE insert_ipv_link (
   p_effective_start_date IN pay_link_input_values_f.effective_start_date%TYPE
 , p_effective_end_date   IN pay_link_input_values_f.effective_end_date%TYPE
 , p_element_link_id      IN pay_link_input_values_f.element_link_id%TYPE
 , p_input_value_id       IN pay_link_input_values_f.input_value_id%TYPE
 , p_costed_flag          IN pay_link_input_values_f.costed_flag%TYPE
 , p_default_value        IN pay_link_input_values_f.default_value%TYPE
 , p_max_value            IN pay_link_input_values_f.max_value%TYPE
 , p_min_value            IN pay_link_input_values_f.min_value%TYPE
 , p_warning_or_error     IN pay_link_input_values_f.warning_or_error%TYPE
 )
AS
   ------------
   -- Variables
   ------------
   l_link_input_pk pay_link_input_values_f.link_input_value_id%TYPE;

-------------------------------------------------------------------------------
BEGIN --                          MAIN                                       --
-------------------------------------------------------------------------------
   hr_utility.set_location('per_za_utility_pkg.insert_ipv_link',1);
   -- get link_input_value_id from the sequence
   SELECT pay_link_input_values_s.nextval
     INTO l_link_input_pk
     FROM dual;
   hr_utility.set_location('per_za_utility_pkg.insert_ipv_link',2);
   INSERT
     INTO pay_link_input_values_f
        ( link_input_value_id
        , effective_start_date
        , effective_end_date
        , element_link_id
        , input_value_id
        , costed_flag
        , default_value
        , max_value
        , min_value
        , warning_or_error
        , last_update_date
        , last_updated_by
        , last_update_login
        , created_by
        , creation_date
        )
   VALUES
        ( l_link_input_pk
        , p_effective_start_date
        , p_effective_end_date
        , p_element_link_id
        , p_input_value_id
        , p_costed_flag
        , p_default_value
        , p_max_value
        , p_min_value
        , p_warning_or_error
        , sysdate
        , -1
        , -1
        , -1
        , sysdate
        );
   hr_utility.set_location('per_za_utility_pkg.insert_ipv_link',3);

EXCEPTION
   WHEN OTHERS THEN
      hr_utility.set_location('per_za_utility_pkg.insert_ipv_link',4);
      hr_utility.trace('Sql error code: '||TO_CHAR(SQLCODE));
      hr_utility.trace('Sql error msg: ' ||SUBSTR(SQLERRM(SQLCODE), 1, 100));
      hr_utility.raise_error;

-------------------------------------------------------------------------------
END insert_ipv_link;

-------------------------------------------------------------------------------
-- insert_ee_value
-------------------------------------------------------------------------------
PROCEDURE insert_ee_value (
  p_effective_start_date IN pay_element_entry_values_f.effective_start_date%TYPE
, p_effective_end_date   IN pay_element_entry_values_f.effective_end_date%TYPE
, p_input_value_id       IN pay_element_entry_values_f.input_value_id%TYPE
, p_element_entry_id     IN pay_element_entry_values_f.element_entry_id%TYPE
, p_screen_entry_value   IN pay_element_entry_values_f.screen_entry_value%TYPE
 )
AS
   ------------
   -- Variables
   ------------
   l_entry_value_pk pay_element_entry_values_f.element_entry_value_id%TYPE;

-------------------------------------------------------------------------------
BEGIN --                          MAIN                                       --
-------------------------------------------------------------------------------
   hr_utility.set_location('per_za_utility_pkg.insert_ee_value',1);
   -- Get the element_entry_value_id from the sequence
   SELECT pay_element_entry_values_s.nextval
     INTO l_entry_value_pk
     FROM dual;
   hr_utility.set_location('per_za_utility_pkg.insert_ee_value',2);
   -- Insert a new row using the sequence value
   INSERT
     INTO pay_element_entry_values_f
        ( element_entry_value_id
        , effective_start_date
        , effective_end_date
        , input_value_id
        , element_entry_id
        , screen_entry_value
        )
   VALUES
        ( l_entry_value_pk
        , p_effective_start_date
        , p_effective_end_date
        , p_input_value_id
        , p_element_entry_id
        , p_screen_entry_value
        );

   hr_utility.set_location('per_za_utility_pkg.insert_ee_value',3);

EXCEPTION
   WHEN OTHERS THEN
      hr_utility.set_location('per_za_utility_pkg.insert_ee_value',4);
      hr_utility.trace('Sql error code: '||TO_CHAR(SQLCODE));
      hr_utility.trace('Sql error msg: ' ||SUBSTR(SQLERRM(SQLCODE), 1, 100));
      hr_utility.raise_error;
-------------------------------------------------------------------------------
END insert_ee_value;

-------------------------------------------------------------------------------
-- elm_link_start_date
-------------------------------------------------------------------------------
FUNCTION elm_link_start_date (
   p_element_link_id IN pay_element_links_f.element_link_id%TYPE
   )
RETURN pay_element_links_f.effective_start_date%TYPE AS
   ---------
   -- Cursor
   ---------
   CURSOR c_start_date(
      p_elm_lnk_id IN pay_element_links_f.element_link_id%TYPE
      )
   IS
      select min(pel.effective_start_date)
        from pay_element_links_f pel
       where pel.element_link_id = p_elm_lnk_id;

   ------------
   -- Variables
   ------------
   l_min_eff_start_date pay_element_links_f.effective_start_date%TYPE;

-------------------------------------------------------------------------------
BEGIN --                  MAIN                                               --
-------------------------------------------------------------------------------
   hr_utility.set_location('per_za_utility_pkg.elm_link_start_date',1);

   OPEN c_start_date(p_element_link_id);
   FETCH c_start_date INTO l_min_eff_start_date;
   CLOSE c_start_date;

   hr_utility.set_location('per_za_utility_pkg.elm_link_start_date',2);
   RETURN l_min_eff_start_date;

EXCEPTION
   WHEN OTHERS THEN
      hr_utility.set_location('per_za_utility_pkg.elm_link_start_date',3);
      IF c_start_date%ISOPEN THEN
         hr_utility.set_location('per_za_utility_pkg.elm_link_start_date',4);
         CLOSE c_start_date;
      END IF;
      hr_utility.set_location('per_za_utility_pkg.elm_link_start_date',5);
      hr_utility.trace('Sql error code: '||TO_CHAR(SQLCODE));
      hr_utility.trace('Sql error msg: ' ||SUBSTR(SQLERRM(SQLCODE), 1, 100));
      hr_utility.raise_error;
-------------------------------------------------------------------------------
END elm_link_start_date;

-------------------------------------------------------------------------------
-- elm_link_end_date
-------------------------------------------------------------------------------
FUNCTION elm_link_end_date (
   p_element_link_id IN pay_element_links_f.element_link_id%TYPE
   )
RETURN pay_element_links_f.effective_end_date%TYPE AS
   ---------
   -- Cursor
   ---------
   CURSOR c_end_date(
      p_elm_lnk_id IN pay_element_links_f.element_link_id%TYPE
      )
   IS
      select max(pel.effective_end_date)
        from pay_element_links_f pel
       where pel.element_link_id = p_elm_lnk_id;

   ------------
   -- Variables
   ------------
   l_max_eff_end_date pay_element_links_f.effective_end_date%TYPE;

-------------------------------------------------------------------------------
BEGIN --                  MAIN                                               --
-------------------------------------------------------------------------------
   hr_utility.set_location('per_za_utility_pkg.elm_link_end_date',1);

   OPEN c_end_date(p_element_link_id);
   FETCH c_end_date INTO l_max_eff_end_date;
   CLOSE c_end_date;

   hr_utility.set_location('per_za_utility_pkg.elm_link_end_date',2);
   RETURN l_max_eff_end_date;

EXCEPTION
   WHEN OTHERS THEN
      hr_utility.set_location('per_za_utility_pkg.elm_link_end_date',3);
      IF c_end_date%ISOPEN THEN
         hr_utility.set_location('per_za_utility_pkg.elm_link_end_date',4);
         CLOSE c_end_date;
      END IF;
      hr_utility.set_location('per_za_utility_pkg.elm_link_end_date',5);
      hr_utility.trace('Sql error code: '||TO_CHAR(SQLCODE));
      hr_utility.trace('Sql error msg: ' ||SUBSTR(SQLERRM(SQLCODE), 1, 100));
      hr_utility.raise_error;
-------------------------------------------------------------------------------
END elm_link_end_date;

-------------------------------------------------------------------------------
-- maintain_ipv_links
-------------------------------------------------------------------------------
PROCEDURE maintain_ipv_links
AS
   ---------
   -- Cursor
   ---------
   CURSOR c_input_values
   IS
      select
             piv.effective_start_date
           , piv.effective_end_date
           , pel.element_link_id
           , piv.input_value_id
           , piv.default_value
           , piv.max_value
           , piv.min_value
           , piv.warning_or_error
        from
             pay_element_links_f      pel
           , pay_input_values_f       piv
           , pay_element_types_f      pet
       where
             pet.element_type_id      = pel.element_type_id
         and pet.element_type_id      = piv.element_type_id
         and pet.legislation_code     = 'ZA'
         and pet.business_group_id    is null
         and pel.effective_end_date   between piv.effective_start_date
                                          and piv.effective_end_date
         and pel.effective_end_date   between pet.effective_start_date
                                          and pet.effective_end_date
         and pel.effective_end_date =
           ( select max(pel2.effective_end_date)
               from pay_element_links_f  pel2
              where pel2.element_link_id = pel.element_link_id
           )
         and not exists
           ( select
                    null
               from
                    pay_link_input_values_f   pli
              where
                    pli.element_link_id       = pel.element_link_id
                and pli.input_value_id        = piv.input_value_id
                and pli.effective_start_date >=
                  ( select min(pel2.effective_start_date)
                      from pay_element_links_f  pel2
                     where pel2.element_link_id = pli.element_link_id
                  )
                and pli.effective_end_date   <=
                  ( select max(pel2.effective_end_date)
                      from pay_element_links_f  pel2
                     where pel2.element_link_id = pli.element_link_id
                  )
            );

   ---------
   -- Cursor
   ---------
   CURSOR c_element_entries(
      p_element_link_id IN pay_element_links_f.element_link_id%TYPE
      )
   IS
      select pee.effective_start_date effective_start_date
           , pee.effective_end_date   effective_end_date
           , pee.element_entry_id     element_entry_id
        from pay_element_entries_f    pee
       where pee.element_link_id      = p_element_link_id;

   ------------
   -- Variables
   ------------
   l_ipv_link_start_date pay_element_links_f.effective_start_date%TYPE;
   l_ipv_link_end_date   pay_element_links_f.effective_end_date%TYPE;

-------------------------------------------------------------------------------
BEGIN --                          MAIN                                       --
-------------------------------------------------------------------------------
------------------------------------------
--   hr_utility.trace_on(null,'perlegza_sql');
------------------------------------------
   hr_utility.set_location('per_za_utility_pkg.maintain_ipv_links',1);
   <<non_linked_input_values>>
   FOR v_input_value IN c_input_values LOOP
      hr_utility.trace('Input Value ID: '||TO_CHAR(v_input_value.input_value_id));

      l_ipv_link_start_date := greatest( elm_link_start_date(v_input_value.element_link_id)
                                       , v_input_value.effective_start_date);

      l_ipv_link_end_date   := least( elm_link_end_date(v_input_value.element_link_id)
                                    , v_input_value.effective_end_date);

      -- Insert a link for any non linked input values where
      -- an element exists
      insert_ipv_link (
         p_effective_start_date => l_ipv_link_start_date
       , p_effective_end_date   => l_ipv_link_end_date
       , p_element_link_id      => v_input_value.element_link_id
       , p_input_value_id       => v_input_value.input_value_id
       , p_costed_flag          => 'N'
       , p_default_value        => v_input_value.default_value
       , p_max_value            => v_input_value.max_value
       , p_min_value            => v_input_value.min_value
       , p_warning_or_error     => v_input_value.warning_or_error
       );

      <<non_entered_input_values>>
      FOR v_entry IN c_element_entries (
                        p_element_link_id => v_input_value.element_link_id
                        )
      LOOP
         hr_utility.trace('Element Entry ID: '||TO_CHAR(v_entry.element_entry_id));
         -- Create a NULL entry for every element entry
         insert_ee_value (
            p_effective_start_date => v_entry.effective_start_date
          , p_effective_end_date   => v_entry.effective_end_date
          , p_input_value_id       => v_input_value.input_value_id
          , p_element_entry_id     => v_entry.element_entry_id
          , p_screen_entry_value   => NULL
          );

      END LOOP non_entered_input_values;
   END LOOP non_linked_input_values;

   hr_utility.set_location('per_za_utility_pkg.maintain_ipv_links',2);

EXCEPTION
   WHEN OTHERS THEN
      hr_utility.set_location('per_za_utility_pkg.maintain_ipv_links',3);
      hr_utility.trace('Sql error code: '||TO_CHAR(SQLCODE));
      hr_utility.trace('Sql error msg: ' ||SUBSTR(SQLERRM(SQLCODE), 1, 100));
      hr_utility.raise_error;
------------------------
--   hr_utility.trace_off;
------------------------
-------------------------------------------------------------------------------
END maintain_ipv_links;
----------------------------------------------------------------------------

-- -------------------------------------------------------------------------------------------
  -- Return the ID for a given context.
  -- -------------------------------------------------------------------------------------------
  --
  FUNCTION get_context_id(p_context_name VARCHAR2) RETURN NUMBER IS
    --
    --
    -- Return the ID for a given context.
    --
    CURSOR csr_context(p_context_name VARCHAR2) IS
      SELECT context_id
      FROM   ff_contexts
      WHERE  context_name = p_context_name;
    --
    --
    -- Local variables.
    --
    l_context_id NUMBER;
    --
  BEGIN
    --
    hr_utility.set_location('Entering: ' || 'per_za_utility_pkg.get_context_id', 10);
    --
    OPEN csr_context(p_context_name);
    FETCH csr_context INTO l_context_id;
    CLOSE csr_context;
    --
    hr_utility.set_location('Leaving: ' || 'per_za_utility_pkg.get_context_id', 20);
    --
    RETURN l_context_id;
    --
  END get_context_id;


----------------------------------------------------------------------------
-- Procedure inserts input value for a perticular run result and input value
----------------------------------------------------------------------------

PROCEDURE insert_rr_value (
 p_input_value_id        IN pay_input_values_f.input_value_id%TYPE
,p_run_result_id         IN pay_run_results.run_result_id%TYPE
,p_result_value          IN pay_run_result_values.result_value%TYPE
 )
AS
   ------------
   -- Variable
   ------------
   rec_exists number;

   l_clar_no_con	number;
   l_Dir_no_con		varchar2(60);
   l_clar_no		number;
   l_Dir_no		varchar2(60);
   l_input_value_name   pay_input_values_f.name%TYPE;


   -- Cursors

   Cursor cur_run_res_con is
      select  prr.ASSIGNMENT_ACTION_ID
              ,prr.ELEMENT_ENTRY_ID
	      ,peef.ASSIGNMENT_ID
      from    pay_run_results prr
	      ,pay_element_entries_f peef
      where   prr.element_entry_id = peef.element_entry_id
      and     prr.run_result_id = p_run_result_id;

   cur_run_res_con_rec cur_run_res_con%ROWTYPE;
-------------------------------------------------------------------------------
BEGIN --                          MAIN                                       --
-------------------------------------------------------------------------------
   hr_utility.set_location('per_za_utility_pkg.insert_rr_value',1);

   l_clar_no_con := get_context_id('SOURCE_NUMBER');
   l_Dir_no_con  := get_context_id('SOURCE_TEXT');


   open cur_run_res_con;
   fetch cur_run_res_con into cur_run_res_con_rec;

       select pivf.name
       into   l_input_value_name
       from   pay_input_values_f pivf
       where  pivf.INPUT_VALUE_ID = p_input_value_id
       and    rownum = 1;

       hr_utility.set_location('per_za_utility_pkg.insert_rr_value',2);

             insert into pay_run_result_values (
		INPUT_VALUE_ID
	       ,RUN_RESULT_ID
	       ,RESULT_VALUE)
	     (select
		p_input_value_id
		,p_run_result_id
		,p_result_value
	      from dual
	      where not exists ( select null
                                 from   pay_run_result_values
                                 where  INPUT_VALUE_ID = p_input_value_id
                                 and    run_result_id = p_run_result_id
			       )
	      );

	    if l_input_value_name = 'Tax Directive Number' then
                pay_za_rules.get_source_text_context
                  (cur_run_res_con_rec.assignment_action_id
                   ,cur_run_res_con_rec.element_entry_id
                   ,l_Dir_no);

                if l_Dir_no is not null then
			INSERT INTO pay_action_contexts
			(assignment_action_id
			,assignment_id
			,context_id
			,context_value)
			(select cur_run_res_con_rec.assignment_action_id
			        ,cur_run_res_con_rec.assignment_id
			        ,l_Dir_no_con
			        ,l_dir_no
			 from   dual
			 where  not exists (select null
			                    from   pay_action_contexts
					    where  assignment_action_id = cur_run_res_con_rec.assignment_action_id
					    and    assignment_id = cur_run_res_con_rec.assignment_id
					    and    context_id    = l_Dir_no_con
					    and    context_value = l_dir_no )
			);
		end if;
            elsif l_input_value_name = 'Clearance Number'  then

                pay_za_rules.get_source_number_context
                 (cur_run_res_con_rec.assignment_action_id
                  ,cur_run_res_con_rec.element_entry_id
                  ,l_clar_no);

		if l_clar_no is not null then
			INSERT INTO pay_action_contexts
			(assignment_action_id
			,assignment_id
			,context_id
			,context_value)
			(select cur_run_res_con_rec.assignment_action_id
			        ,cur_run_res_con_rec.assignment_id
			        ,l_clar_no_con
			        ,l_clar_no
			 from   dual
			 where  not exists (select null
			                    from   pay_action_contexts
					    where  assignment_action_id = cur_run_res_con_rec.assignment_action_id
					    and    assignment_id = cur_run_res_con_rec.assignment_id
					    and    context_id    = l_clar_no_con
					    and    context_value = l_clar_no )
			);
                 end if;
	    end if;
	    --

   if cur_run_res_con%ISOPEN then
      close cur_run_res_con;
   end if;
   hr_utility.set_location('per_za_utility_pkg.insert_rr_value',3);

EXCEPTION
   WHEN OTHERS THEN
      hr_utility.set_location('per_za_utility_pkg.insert_rr_value',4);
      hr_utility.trace('Sql error code: '||TO_CHAR(SQLCODE));
      hr_utility.trace('Sql error msg: ' ||SUBSTR(SQLERRM(SQLCODE), 1, 100));
      hr_utility.raise_error;
---------------------------------------------------------------------------
END insert_rr_value;
---------------------------------------------------------------------------


END per_za_utility_pkg;
---------------------------------------------------------------------------

/
