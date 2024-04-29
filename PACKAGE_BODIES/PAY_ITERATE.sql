--------------------------------------------------------
--  DDL for Package Body PAY_ITERATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ITERATE" as
/* $Header: pyiterat.pkb 120.6.12010000.1 2008/07/27 22:56:35 appldev ship $ */
--                               TYPES
--
-- The table types are just simple tables or various types. The records
-- are composite types of tables that contain a size (sz) to hold the
-- number of data items currently stored in the table. Data items are
-- stored in the tables within the records contiguously from 1 to sz.
--==================================================================
  TYPE varchar_1_tbl  IS TABLE OF VARCHAR(1)  INDEX BY binary_integer;
  TYPE boolean_tbl IS TABLE OF BOOLEAN INDEX BY binary_integer;
--
  TYPE entry_rec IS RECORD
  (
    entry_id                    number_tbl,
    high_value                  number_tbl,
    low_value                   number_tbl,
    high_value_result           number_tbl,
    low_value_result            number_tbl,
    guess_value                 number_tbl,
    target_value                number_tbl,
    inter_mode                  number_tbl,
    sz                  INTEGER
  );
--
  g_entry_list  entry_rec;
  g_asg_id      per_assignments_f.assignment_id%type;
  g_asg_act_id      pay_assignment_actions.assignment_action_id%type;
--
  G_INTER_MODE_INIT number := 0;
  G_INTER_MODE_HIGH number := 1;
  G_INTER_MODE_LOW  number := 2;
  G_INTER_MODE_NORM number := 3;
--
/*
    Procedure: get_entry_position

    Description:

     This procedure searches for an already existing entry in the table
     if it finds it then it returns the position otherwise return the
     next free position.

*/
procedure get_entry_position (p_entry_id  in            number,
                              p_found     out   nocopy  boolean,
                              p_entry_loc out   nocopy  number
                             ) is
position  number;
begin
--
   position := 1;
--
   p_found := FALSE;
   if g_entry_list.sz = 0 then
     p_entry_loc := 1;
     return;
   end if;
--
   while (p_found = FALSE AND position <= g_entry_list.sz) loop
--
     if p_entry_id = g_entry_list.entry_id(position) then
       p_found := TRUE;
       p_entry_loc := position;
       return;
     end if;
--
     position := position+1;
   end loop;
--
   /* OK we dropped through must be new */
--
   p_entry_loc := position;
   return;
end;
--
/*
    Procedure: initialise_amount

    Description:

     This procedure is used for initialisation with just the
     target value is known.

*/
function initialise_amount (
                     p_bg_id         in number,
                     p_entry_id      in number,
                     p_assignment_action_id  in number default null,
                     p_target_value  in number default null
                     ) return number is
l_high_gross number;
begin
    l_high_gross := p_target_value * pay_iterate.get_high_gross_factor(p_bg_id);
--
    return pay_iterate.initialise (p_entry_id      => p_entry_id,
				   p_assignment_action_id => p_assignment_action_id,
                                   p_high_value    => l_high_gross,
                                   p_low_value     => p_target_value,
                                   p_target_value  => p_target_value
                                  );
end initialise_amount;

/*
    Procedure: initialise

    Description:

     This procedure is used to set up the high and low values for an
     element entry.

*/
function initialise (p_entry_id      in number,
                      p_assignment_action_id in number default null,
                      p_high_value    in number,
                      p_low_value     in number,
                      p_target_value  in number default null
                     ) return number is
found     boolean;
entry_loc number;
l_asg_id  pay_element_entries_f.assignment_id%type;
begin
--
 if p_assignment_action_id is null
 then
    select distinct assignment_id
      into l_asg_id
      from pay_element_entries_f
     where element_entry_id = p_entry_id;
--
    if (l_asg_id <> g_asg_id) then
      g_entry_list.entry_id.delete;
      g_entry_list.high_value.delete;
      g_entry_list.low_value.delete;
      g_entry_list.high_value_result.delete;
      g_entry_list.low_value_result.delete;
      g_entry_list.guess_value.delete;
      g_entry_list.target_value.delete;
      g_entry_list.inter_mode.delete;
      g_entry_list.sz := 0;
    end if;
--
    g_asg_id := l_asg_id;
 else
  if (p_assignment_action_id <> g_asg_act_id) then
      g_entry_list.entry_id.delete;
      g_entry_list.high_value.delete;
      g_entry_list.low_value.delete;
      g_entry_list.high_value_result.delete;
      g_entry_list.low_value_result.delete;
      g_entry_list.guess_value.delete;
      g_entry_list.target_value.delete;
      g_entry_list.inter_mode.delete;
      g_entry_list.sz := 0;
    end if;

  g_asg_act_id := p_assignment_action_id;

 end if;
--
--
    get_entry_position(p_entry_id, found, entry_loc);
--
    if found = FALSE then
      g_entry_list.entry_id(entry_loc) := p_entry_id;
      g_entry_list.sz := g_entry_list.sz +1;
    end if;
--
    g_entry_list.guess_value(entry_loc)        := NULL;
    g_entry_list.high_value_result(entry_loc)  := NULL;
    g_entry_list.low_value_result(entry_loc)   := NULL;
    g_entry_list.high_value(entry_loc)         := p_high_value;
    g_entry_list.low_value(entry_loc)          := p_low_value;
    g_entry_list.target_value(entry_loc)       := p_target_value;
    g_entry_list.inter_mode(entry_loc)         := G_INTER_MODE_INIT;
--
    return 0;
end initialise;
--
/*
    Procedure: get_binary_guess

    Description:

     This performs a binary chop based on the mode that is sent in from
     the parameters

*/
function get_binary_guess (p_entry_id in number,
                           p_mode     in varchar2) return number is
found     boolean;
entry_loc number;
begin
--
   /* Find the entry in the PL/SQL table */
   get_entry_position(p_entry_id, found, entry_loc);
   if found = false then
      return 0;
   end if;
--
   g_entry_list.inter_mode(entry_loc) := G_INTER_MODE_NORM;
   /* Do we need to increase the guess value? */
   if p_mode = 'REDUCE' then
--
     if g_entry_list.guess_value(entry_loc) is not NULL then
--
        g_entry_list.high_value(entry_loc) :=
                        g_entry_list.guess_value(entry_loc);
     end if;
--
        g_entry_list.guess_value(entry_loc) :=
            g_entry_list.low_value(entry_loc) +
                 ((g_entry_list.high_value(entry_loc) -
                      g_entry_list.low_value(entry_loc))/2);
     return g_entry_list.guess_value(entry_loc);
--
   else
     if p_mode = 'INCREASE' then
        if g_entry_list.guess_value(entry_loc) is not NULL then
--
           g_entry_list.low_value(entry_loc) :=
                        g_entry_list.guess_value(entry_loc);
        end if;
--

        g_entry_list.guess_value(entry_loc) :=
            g_entry_list.low_value(entry_loc) +
                 ((g_entry_list.high_value(entry_loc) -
                      g_entry_list.low_value(entry_loc))/2);
        return g_entry_list.guess_value(entry_loc);
     end if;
   end if;
--
end get_binary_guess;
--
/*
    Name : calc_inter_value

    Description:  This function returns the next guess value for iterative
                  looping. The formula is based on the interpolation
                  mathmatical solutions formula:-

            x = a.f(b) - b.f(a)
                ---------------
                  f(b) - f(a)

*/
function calc_inter_value (a in number,
                           fa in number,
                           b in number,
                           fb in number)
return number is
--
div_number number;
res_number number;
begin
--
    div_number := fb - fa;
    res_number := (a * fb) - (b * fa);
    -- avoid division by zero issue
    if (div_number <> 0) then
       res_number := res_number / div_number;
    end if;
    return res_number;
end calc_inter_value;
--
/*
    Name : get_interpolation_guess

    Description:  This function performs the interpolation guessing algorithm.
                  The algorithm basically finds the point on a curve (equation
                  unknown) that intersects the y axis.
                  In this procedure the x axis is the value that we are trying
                  to find, the y axis is the distance away from the value that
                  we are trying to reach.

                  For example:-

                         In a Net to Gross calculation, then the x axis is
                         could be the gross value (this is the value we're
                         guessing), the y axis is the distance from the
                         required Net value, Calculated Net - Required Net.

*/
function get_interpolation_guess (p_entry_id in number,
                                  p_result   in number default null)
return number is
found     boolean;
entry_loc number;
begin
--
   /* Find the entry in the PL/SQL table */
   get_entry_position(p_entry_id, found, entry_loc);
--
   /* Go get the high value */
   if g_entry_list.inter_mode(entry_loc) = G_INTER_MODE_INIT then
       g_entry_list.high_value_result(entry_loc) := g_entry_list.high_value_result(entry_loc) - g_entry_list.target_value(entry_loc);
       g_entry_list.low_value_result(entry_loc) := g_entry_list.low_value_result(entry_loc) - g_entry_list.target_value(entry_loc);
       g_entry_list.target_value(entry_loc) := 0;
       g_entry_list.inter_mode(entry_loc) :=G_INTER_MODE_HIGH;
       return g_entry_list.high_value(entry_loc);
   end if;
--
   /* Go get the low value */
   if g_entry_list.inter_mode(entry_loc) = G_INTER_MODE_HIGH then
       g_entry_list.high_value_result(entry_loc) := p_result - g_entry_list.target_value(entry_loc);
       g_entry_list.inter_mode(entry_loc) := G_INTER_MODE_LOW;
       return g_entry_list.low_value(entry_loc);
   end if;
--
   if g_entry_list.inter_mode(entry_loc) = G_INTER_MODE_LOW then
       g_entry_list.low_value_result(entry_loc) :=
                        p_result - g_entry_list.target_value(entry_loc);
       g_entry_list.inter_mode(entry_loc) := G_INTER_MODE_NORM;
--
       /* OK make the first guess */
       g_entry_list.guess_value(entry_loc) :=
             calc_inter_value(
                  g_entry_list.low_value(entry_loc),
                  g_entry_list.low_value_result(entry_loc),
                  g_entry_list.high_value(entry_loc),
                  g_entry_list.high_value_result(entry_loc)
                             );
       return g_entry_list.guess_value(entry_loc);
   end if;
--
   if g_entry_list.inter_mode(entry_loc) = G_INTER_MODE_NORM then
--
     /* If the result returned is greater than the target then
        replace the previous higher value
     */
     if p_result > g_entry_list.target_value(entry_loc) then
        if g_entry_list.low_value_result(entry_loc) >
                     g_entry_list.target_value(entry_loc) then
--
           g_entry_list.low_value(entry_loc) :=
                         g_entry_list.guess_value(entry_loc);
           g_entry_list.low_value_result(entry_loc):=
                         p_result - g_entry_list.target_value(entry_loc);
        else
           g_entry_list.high_value(entry_loc) :=
                         g_entry_list.guess_value(entry_loc);
           g_entry_list.high_value_result(entry_loc):=
                         p_result - g_entry_list.target_value(entry_loc);
        end if;
     else
        if g_entry_list.low_value_result(entry_loc) <
                     g_entry_list.target_value(entry_loc) then
--
           g_entry_list.low_value(entry_loc) :=
                         g_entry_list.guess_value(entry_loc);
           g_entry_list.low_value_result(entry_loc):=
                         p_result - g_entry_list.target_value(entry_loc);
        else
           g_entry_list.high_value(entry_loc) :=
                         g_entry_list.guess_value(entry_loc);
           g_entry_list.high_value_result(entry_loc):=
                         p_result - g_entry_list.target_value(entry_loc);
        end if;
     end if;
--
     /* Now recalculate */
       g_entry_list.guess_value(entry_loc) :=
             calc_inter_value(
                  g_entry_list.low_value(entry_loc),
                  g_entry_list.low_value_result(entry_loc),
                  g_entry_list.high_value(entry_loc),
                  g_entry_list.high_value_result(entry_loc)
                             );
     return round(g_entry_list.guess_value(entry_loc),2);
   end if;
end get_interpolation_guess;
--
function is_first_setting (p_entry_id in number,
                           p_assignment_action_id in number default null)
return number is
found     boolean;
entry_loc number;
begin
--
   if p_assignment_action_id is not null
   then

      if (p_assignment_action_id <> g_asg_act_id) then
         g_entry_list.entry_id.delete;
         g_entry_list.high_value.delete;
         g_entry_list.low_value.delete;
         g_entry_list.high_value_result.delete;
         g_entry_list.low_value_result.delete;
         g_entry_list.guess_value.delete;
         g_entry_list.target_value.delete;
         g_entry_list.inter_mode.delete;
         g_entry_list.sz := 0;
      end if;

      g_asg_act_id := p_assignment_action_id;
   end if;
--
   /* Find the entry in the PL/SQL table */
   get_entry_position(p_entry_id, found, entry_loc);
--
   /* If not found assume first run */
   if (found = FALSE) then
      return 1;
   end if;
--
   if (g_entry_list.inter_mode(entry_loc) = G_INTER_MODE_INIT) then
     return 1;
   end if;
   return 0;
--
end is_first_setting;
--
function is_amount_set (p_entry_id in number,
                        p_assignment_action_id in number default null)
return number is
found     boolean;
entry_loc number;
begin
--
   if p_assignment_action_id is not null
   then

      if (p_assignment_action_id <> g_asg_act_id) then
         g_entry_list.entry_id.delete;
         g_entry_list.high_value.delete;
         g_entry_list.low_value.delete;
         g_entry_list.high_value_result.delete;
         g_entry_list.low_value_result.delete;
         g_entry_list.guess_value.delete;
         g_entry_list.target_value.delete;
         g_entry_list.inter_mode.delete;
         g_entry_list.sz := 0;
      end if;

      g_asg_act_id := p_assignment_action_id;
   end if;
--
   /* Find the entry in the PL/SQL table */
   get_entry_position(p_entry_id, found, entry_loc);
--
   if (found = TRUE) then
     return 1;
   end if;
   return 0;
--
end is_amount_set;
--
function get_high_value (p_entry_id in number)
return number is
found     boolean;
entry_loc number;
begin
--
   /* Find the entry in the PL/SQL table */
   get_entry_position(p_entry_id, found, entry_loc);
--
   return g_entry_list.high_value(entry_loc);
end get_high_value;
--
function get_target_value (p_entry_id in number)
return number is
found     boolean;
entry_loc number;
begin
--
   /* Find the entry in the PL/SQL table */
   get_entry_position(p_entry_id, found, entry_loc);
--
   return g_entry_list.target_value(entry_loc);
end get_target_value;
--
function get_low_value (p_entry_id in number)
return number is
found     boolean;
entry_loc number;
begin
--
   /* Find the entry in the PL/SQL table */
   get_entry_position(p_entry_id, found, entry_loc);
--
   return g_entry_list.low_value(entry_loc);
end get_low_value;
--
/*
    Name : get_high_gross_factor

    Description:  This function is used by the iterative Fast Formula to
                  calculate the high gross factor, which is then used
                  to derive the initial high gross value.

*/
function get_high_gross_factor (p_bg_id in number)
return number is
--
l_statem          varchar2(2000);  -- used with dynamic pl/sql
sql_cursor        integer;
l_rows            integer;
--
l_leg_code        per_business_groups.legislation_code%type;
l_flag            pay_legislation_rules.rule_mode%type;
l_found           boolean;
l_factor          number;
--
begin
--
   select legislation_code
     into l_leg_code
     from per_business_groups_perf
    where business_group_id = p_bg_id;
--
   pay_core_utils.get_legislation_rule(p_legrul_name   => 'ITERATE_DYN_HI_GRS_FACTOR',
                                       p_legislation   => l_leg_code,
                                       p_legrul_value  => l_flag,
                                       p_found         => l_found
                                      );
--
  if (l_found = FALSE ) then
     l_factor := 2;
  else
     l_factor := fnd_number.canonical_to_number(l_flag);
  end if;
--
  return l_factor;
--
--
end get_high_gross_factor;
--
/* The following functions are used by loader scripts to load Run Type details
*/
-----------------------------------------------------------------------------
 /* Name    : up_run_type
  Purpose   : Uploads the Run Type definition.
  Arguments :
  Notes     :
 */
-----------------------------------------------------------------------------
PROCEDURE up_run_type (p_rt_id                number
                      ,p_rt_name              varchar2
                      ,p_effective_start_date date
                      ,p_effective_end_date   date
                      ,p_legislative_code     varchar2
                      ,p_business_group       varchar2
                      ,p_shortname            varchar2
                      ,p_method               varchar2
                      ,p_rt_name_tl           varchar2
                      ,p_shortname_tl         varchar2
                      ,p_eof_number           number
		      ,p_srs_flag             varchar2  default 'Y'
		      ,p_run_information_category   varchar2  default null
		      ,p_run_information1	      varchar2  default null
		      ,p_run_information2	      varchar2  default null
		      ,p_run_information3	      varchar2  default null
		      ,p_run_information4	      varchar2  default null
		      ,p_run_information5	      varchar2  default null
		      ,p_run_information6	      varchar2  default null
		      ,p_run_information7	      varchar2  default null
		      ,p_run_information8	      varchar2  default null
		      ,p_run_information9	      varchar2  default null
		      ,p_run_information10	      varchar2  default null
		      ,p_run_information11	      varchar2  default null
		      ,p_run_information12	      varchar2  default null
		      ,p_run_information13	      varchar2  default null
		      ,p_run_information14	      varchar2  default null
		      ,p_run_information15	      varchar2  default null
		      ,p_run_information16	      varchar2  default null
		      ,p_run_information17	      varchar2  default null
		      ,p_run_information18	      varchar2  default null
		      ,p_run_information19	      varchar2  default null
		      ,p_run_information20	      varchar2  default null
		      ,p_run_information21	      varchar2  default null
		      ,p_run_information22	      varchar2  default null
		      ,p_run_information23	      varchar2  default null
		      ,p_run_information24	      varchar2  default null
		      ,p_run_information25	      varchar2  default null
		      ,p_run_information26	      varchar2  default null
		      ,p_run_information27	      varchar2  default null
		      ,p_run_information28	      varchar2  default null
		      ,p_run_information29	      varchar2  default null
		      ,p_run_information30	      varchar2  default null
                      )
   is
--
-- 3 cursors for getting existing row, one for each mode.
--
cursor u_row_exists
is
select run_type_id
,      run_type_name
,      shortname
,      srs_flag
,      run_information_category
,      run_information1
,      run_information2
,      run_information3
,      run_information4
,      run_information5
,      run_information6
,      run_information7
,      run_information8
,      run_information9
,      run_information10
,      run_information11
,      run_information12
,      run_information13
,      run_information14
,      run_information15
,      run_information16
,      run_information17
,      run_information18
,      run_information19
,      run_information20
,      run_information21
,      run_information22
,      run_information23
,      run_information24
,      run_information25
,      run_information26
,      run_information27
,      run_information28
,      run_information29
,      run_information30
,      legislation_code
,      business_group_id
,      effective_start_date
,      effective_end_date
,      object_version_number
from   pay_run_types_f
where  run_type_name = p_rt_name
and    business_group_id = (select pbg.business_group_id
                            from   per_business_groups pbg
                            where  upper(pbg.name) = upper(p_business_group))
and    legislation_code is null;
--
cursor s_row_exists
is
select run_type_id
,      run_type_name
,      shortname
,      srs_flag
,      run_information_category
,      run_information1
,      run_information2
,      run_information3
,      run_information4
,      run_information5
,      run_information6
,      run_information7
,      run_information8
,      run_information9
,      run_information10
,      run_information11
,      run_information12
,      run_information13
,      run_information14
,      run_information15
,      run_information16
,      run_information17
,      run_information18
,      run_information19
,      run_information20
,      run_information21
,      run_information22
,      run_information23
,      run_information24
,      run_information25
,      run_information26
,      run_information27
,      run_information28
,      run_information29
,      run_information30
,      legislation_code
,      business_group_id
,      effective_start_date
,      effective_end_date
,      object_version_number
from   pay_run_types_f
where  run_type_name = p_rt_name
and    legislation_code = p_legislative_code
and    business_group_id is null;
--
cursor g_row_exists
is
select run_type_id
,      run_type_name
,      shortname
,      srs_flag
,      run_information_category
,      run_information1
,      run_information2
,      run_information3
,      run_information4
,      run_information5
,      run_information6
,      run_information7
,      run_information8
,      run_information9
,      run_information10
,      run_information11
,      run_information12
,      run_information13
,      run_information14
,      run_information15
,      run_information16
,      run_information17
,      run_information18
,      run_information19
,      run_information20
,      run_information21
,      run_information22
,      run_information23
,      run_information24
,      run_information25
,      run_information26
,      run_information27
,      run_information28
,      run_information29
,      run_information30
,      legislation_code
,      business_group_id
,      effective_start_date
,      effective_end_date
,      object_version_number
from   pay_run_types_f prt
where  run_type_name = p_rt_name
and    business_group_id is null
and    legislation_code is null;
--
cursor get_bg_id
is
select business_group_id
from   per_business_groups
where  upper(name) = upper(p_business_group);
--
l_mode         varchar2(30) := 'USER';
l_rt_id        number;
l_rt_nm        varchar2(80);
l_shrtnm       varchar2(30);
l_srs_flag     varchar2(30);
l_run_information_category varchar2(30);
l_run_information1   varchar2(150);
l_run_information2   varchar2(150);
l_run_information3   varchar2(150);
l_run_information4   varchar2(150);
l_run_information5   varchar2(150);
l_run_information6   varchar2(150);
l_run_information7   varchar2(150);
l_run_information8   varchar2(150);
l_run_information9   varchar2(150);
l_run_information10   varchar2(150);
l_run_information11   varchar2(150);
l_run_information12   varchar2(150);
l_run_information13   varchar2(150);
l_run_information14   varchar2(150);
l_run_information15   varchar2(150);
l_run_information16   varchar2(150);
l_run_information17   varchar2(150);
l_run_information18   varchar2(150);
l_run_information19   varchar2(150);
l_run_information20   varchar2(150);
l_run_information21   varchar2(150);
l_run_information22   varchar2(150);
l_run_information23   varchar2(150);
l_run_information24   varchar2(150);
l_run_information25   varchar2(150);
l_run_information26   varchar2(150);
l_run_information27   varchar2(150);
l_run_information28   varchar2(150);
l_run_information29   varchar2(150);
l_run_information30   varchar2(150);
l_esd          date;
l_eed          date;
l_lc           varchar2(30);
l_bg           number;
l_ovn          number;
l_out_rt_id    number;
l_out_esd      date;
l_out_eed      date;
l_out_ovn      number;
--
-------------------------------------------
-- procedure insert_row
-------------------------------------------
procedure insert_row is
--
begin
--
hr_startup_data_api_support.enable_startup_mode(l_mode);
--
  if l_mode <> 'USER' then
    hr_startup_data_api_support.delete_owner_definitions;
    hr_startup_data_api_support.create_owner_definition('PAY');
  end if;
--
-- call insert api. End date will be EOT for now, will be updated
-- later if it should be anything other than eot.
--
  pay_run_type_api.create_run_type
               (p_effective_date        => p_effective_start_date
             --  ,p_language_code         => 'US'
               ,p_run_type_name         => p_rt_name
               ,p_run_method            => p_method
               ,p_business_group_id     => l_bg
               ,p_legislation_code      => p_legislative_code
               ,p_shortname             => p_shortname
               ,p_srs_flag              => p_srs_flag
	       ,p_run_information_category    => p_run_information_category
	       ,p_run_information1		=> p_run_information1
	       ,p_run_information2		=> p_run_information2
	       ,p_run_information3		=> p_run_information3
	       ,p_run_information4		=> p_run_information4
	       ,p_run_information5		=> p_run_information5
	       ,p_run_information6		=> p_run_information6
	       ,p_run_information7		=> p_run_information7
	       ,p_run_information8		=> p_run_information8
	       ,p_run_information9		=> p_run_information9
	       ,p_run_information10		=> p_run_information10
	       ,p_run_information11		=> p_run_information11
	       ,p_run_information12		=> p_run_information12
	       ,p_run_information13		=> p_run_information13
	       ,p_run_information14		=> p_run_information14
	       ,p_run_information15		=> p_run_information15
	       ,p_run_information16		=> p_run_information16
	       ,p_run_information17		=> p_run_information17
	       ,p_run_information18		=> p_run_information18
	       ,p_run_information19		=> p_run_information19
	       ,p_run_information20		=> p_run_information20
	       ,p_run_information21		=> p_run_information21
	       ,p_run_information22		=> p_run_information22
	       ,p_run_information23		=> p_run_information23
	       ,p_run_information24		=> p_run_information24
	       ,p_run_information25		=> p_run_information25
	       ,p_run_information26		=> p_run_information26
	       ,p_run_information27		=> p_run_information27
	       ,p_run_information28		=> p_run_information28
	       ,p_run_information29		=> p_run_information29
	       ,p_run_information30		=> p_run_information30
               ,p_run_type_id           => l_out_rt_id
               ,p_effective_start_date  => l_out_esd
               ,p_effective_end_date    => l_out_eed
               ,p_object_version_number => l_out_ovn
               );
  --
  -- cache the new details
  --
  select run_type_id
  ,      run_type_name
  ,      shortname
  ,      srs_flag
  ,      run_information_category
  ,      run_information1
  ,      run_information2
  ,      run_information3
  ,      run_information4
  ,      run_information5
  ,      run_information6
  ,      run_information7
  ,      run_information8
  ,      run_information9
  ,      run_information10
  ,      run_information11
  ,      run_information12
  ,      run_information13
  ,      run_information14
  ,      run_information15
  ,      run_information16
  ,      run_information17
  ,      run_information18
  ,      run_information19
  ,      run_information20
  ,      run_information21
  ,      run_information22
  ,      run_information23
  ,      run_information24
  ,      run_information25
  ,      run_information26
  ,      run_information27
  ,      run_information28
  ,      run_information29
  ,      run_information30
  ,      legislation_code
  ,      business_group_id
  ,      effective_start_date
  ,      effective_end_date
  ,      object_version_number
  ,      l_mode
  into   rec_uploaded
  from   pay_run_types_f
  where  run_type_id = l_out_rt_id;
  --
end insert_row;
-------------------------------------------
-- procedure zap_insert
--
-- zap_insert indicates that the row being uploaded already exists on the
-- new db, but that it is a new datetracked row from the ldt, i.e. it is the
-- first time this row has been updated. There may well be further
-- datetracked rows for this row (handled by update_row), so the effective end
-- date is left as eot.
--
-------------------------------------------
procedure zap_insert(p_rt_id number) is
--
cursor chk_for_children
is
select run_type_usage_id
,      object_version_number
,      business_group_id
,      legislation_code
,      effective_start_date
from   pay_run_type_usages_f
where  parent_run_type_id = l_rt_id;
--
cursor chk_for_tl_children
is
select 1
from   pay_run_types_f_tl
where  run_type_id = l_rt_id;
--
cursor get_prods(p_sess number)
is
select product_short_name
from hr_owner_definitions
where session_id = p_sess;
--
cursor get_langs
is
select l.language_code
from   fnd_languages l
where  l.installed_flag in ('I','B')
and    exists (select null
               from pay_run_types_f_tl rtt
               where rtt.run_type_id = p_rt_id
               and rtt.language = l.language_code);

l_sess number;
l_ch_rtu_id number;
l_ch_ovn    number;
l_ch_bg     number;
l_ch_leg    varchar2(30);
l_ch_esd    date;
l_tl_exists number;
--
begin
--
hr_startup_data_api_support.enable_startup_mode(l_mode);
--
  if l_mode <> 'USER' then
    hr_startup_data_api_support.delete_owner_definitions;
    hr_startup_data_api_support.create_owner_definition('PAY');
  end if;
--
-- remove check_for_children as going to do a direct delete, not an api delete.
-- children will be temporarily orphaned, til the row is reinserted with
-- original id
--
hr_utility.trace('l_rt_id: '||to_char(l_rt_id));
hr_utility.trace('eff start date: '||to_char(p_effective_start_date,'dd-mon-yyyy'));
--
-- first get the original run_type_id
--
pay_prt_ins.set_base_key_value(p_rt_id);
--
-- now delete the row
--
  delete from pay_run_types_f
  where  run_type_id = p_rt_id;
  --
  --
  -- also need to delete the tl table row, as if one exists for a partic
  -- run_type_id it will not insert another, hence updates will not get made
  --
  for each_row in get_langs loop
    delete from pay_run_types_f_tl
    where  run_type_id = p_rt_id
    and    language = each_row.language_code;
  end loop;
  --
  -- also need to delete the row in hr_application_ownerships, else will get
  -- a unique contraint error
  --
  l_sess := nvl(hr_startup_data_api_support.g_startup_session_id
               ,hr_startup_data_api_support.g_session_id);
  --
  for each_row in get_prods(l_sess) loop
   delete from hr_application_ownerships
   where  key_name     = 'RUN_TYPE_ID'
   and    key_value    = p_rt_id
   and    product_name = each_row.product_short_name;
  end loop;
  --
  pay_run_type_api.create_run_type
               (p_effective_date        => p_effective_start_date
               ,p_run_type_name         => p_rt_name
               ,p_run_method            => p_method
               ,p_business_group_id     => l_bg
               ,p_legislation_code      => p_legislative_code
               ,p_shortname             => p_shortname
               ,p_srs_flag              => p_srs_flag
	       ,p_run_information_category    => p_run_information_category
	       ,p_run_information1		=> p_run_information1
	       ,p_run_information2		=> p_run_information2
	       ,p_run_information3		=> p_run_information3
	       ,p_run_information4		=> p_run_information4
	       ,p_run_information5		=> p_run_information5
	       ,p_run_information6		=> p_run_information6
	       ,p_run_information7		=> p_run_information7
	       ,p_run_information8		=> p_run_information8
	       ,p_run_information9		=> p_run_information9
	       ,p_run_information10		=> p_run_information10
	       ,p_run_information11		=> p_run_information11
	       ,p_run_information12		=> p_run_information12
	       ,p_run_information13		=> p_run_information13
	       ,p_run_information14		=> p_run_information14
	       ,p_run_information15		=> p_run_information15
	       ,p_run_information16		=> p_run_information16
	       ,p_run_information17		=> p_run_information17
	       ,p_run_information18		=> p_run_information18
	       ,p_run_information19		=> p_run_information19
	       ,p_run_information20		=> p_run_information20
	       ,p_run_information21		=> p_run_information21
	       ,p_run_information22		=> p_run_information22
	       ,p_run_information23		=> p_run_information23
	       ,p_run_information24		=> p_run_information24
	       ,p_run_information25		=> p_run_information25
	       ,p_run_information26		=> p_run_information26
	       ,p_run_information27		=> p_run_information27
	       ,p_run_information28		=> p_run_information28
	       ,p_run_information29		=> p_run_information29
	       ,p_run_information30		=> p_run_information30
               ,p_run_type_id           => l_out_rt_id
               ,p_effective_start_date  => l_out_esd
               ,p_effective_end_date    => l_out_eed
               ,p_object_version_number => l_out_ovn
               );
--
hr_utility.trace('AFTER ZAP CREATE');
  --
  -- set the uploaded cache
  --
  select run_type_id
  ,      run_type_name
  ,      shortname
  ,      srs_flag
  ,      run_information_category
  ,      run_information1
  ,      run_information2
  ,      run_information3
  ,      run_information4
  ,      run_information5
  ,      run_information6
  ,      run_information7
  ,      run_information8
  ,      run_information9
  ,      run_information10
  ,      run_information11
  ,      run_information12
  ,      run_information13
  ,      run_information14
  ,      run_information15
  ,      run_information16
  ,      run_information17
  ,      run_information18
  ,      run_information19
  ,      run_information20
  ,      run_information21
  ,      run_information22
  ,      run_information23
  ,      run_information24
  ,      run_information25
  ,      run_information26
  ,      run_information27
  ,      run_information28
  ,      run_information29
  ,      run_information30
  ,      legislation_code
  ,      business_group_id
  ,      effective_start_date
  ,      effective_end_date
  ,      object_version_number
  ,      l_mode
  into   rec_uploaded
  from   pay_run_types_f
  where  run_type_id = l_out_rt_id;
--
end zap_insert;
-------------------------------------------
-- procedure update_row
--
-- If multiple datatrack rows exist in the ldt for one particular row, multiple
-- updates will have to be done achieve the dt history. The effective_end_date
-- is left at eot. If eot is not the final end date of the dt row it will be
-- set to the correct date by set_end_date.
--
-------------------------------------------
procedure update_row is
--
begin
--
hr_startup_data_api_support.enable_startup_mode(l_mode);
--
  if l_mode <> 'USER' then
    hr_startup_data_api_support.delete_owner_definitions;
    hr_startup_data_api_support.create_owner_definition('PAY');
  end if;
--
  pay_run_type_api.update_run_type
               (p_effective_date        => p_effective_start_date
               ,p_datetrack_update_mode => 'UPDATE'
               ,p_run_type_id           => rec_uploaded.rt_id
               ,p_object_version_number => rec_uploaded.rt_ovn
               ,p_business_group_id     => l_bg
               ,p_legislation_code      => p_legislative_code
               ,p_shortname             => p_shortname
               ,p_srs_flag              => p_srs_flag
	       ,p_run_information_category    => p_run_information_category
	       ,p_run_information1		=> p_run_information1
	       ,p_run_information2		=> p_run_information2
	       ,p_run_information3		=> p_run_information3
	       ,p_run_information4		=> p_run_information4
	       ,p_run_information5		=> p_run_information5
	       ,p_run_information6		=> p_run_information6
	       ,p_run_information7		=> p_run_information7
	       ,p_run_information8		=> p_run_information8
	       ,p_run_information9		=> p_run_information9
	       ,p_run_information10		=> p_run_information10
	       ,p_run_information11		=> p_run_information11
	       ,p_run_information12		=> p_run_information12
	       ,p_run_information13		=> p_run_information13
	       ,p_run_information14		=> p_run_information14
	       ,p_run_information15		=> p_run_information15
	       ,p_run_information16		=> p_run_information16
	       ,p_run_information17		=> p_run_information17
	       ,p_run_information18		=> p_run_information18
	       ,p_run_information19		=> p_run_information19
	       ,p_run_information20		=> p_run_information20
	       ,p_run_information21		=> p_run_information21
	       ,p_run_information22		=> p_run_information22
	       ,p_run_information23		=> p_run_information23
	       ,p_run_information24		=> p_run_information24
	       ,p_run_information25		=> p_run_information25
	       ,p_run_information26		=> p_run_information26
	       ,p_run_information27		=> p_run_information27
	       ,p_run_information28		=> p_run_information28
	       ,p_run_information29		=> p_run_information29
	       ,p_run_information30		=> p_run_information30
               ,p_effective_start_date  => l_out_esd
               ,p_effective_end_date    => l_out_eed
               );
  --
  -- cache the latest uploaded row
  --
  select run_type_id
  ,      run_type_name
  ,      shortname
  ,      srs_flag
  ,      run_information_category
  ,      run_information1
  ,      run_information2
  ,      run_information3
  ,      run_information4
  ,      run_information5
  ,      run_information6
  ,      run_information7
  ,      run_information8
  ,      run_information9
  ,      run_information10
  ,      run_information11
  ,      run_information12
  ,      run_information13
  ,      run_information14
  ,      run_information15
  ,      run_information16
  ,      run_information17
  ,      run_information18
  ,      run_information19
  ,      run_information20
  ,      run_information21
  ,      run_information22
  ,      run_information23
  ,      run_information24
  ,      run_information25
  ,      run_information26
  ,      run_information27
  ,      run_information28
  ,      run_information29
  ,      run_information30
  ,      legislation_code
  ,      business_group_id
  ,      effective_start_date
  ,      effective_end_date
  ,      object_version_number
  ,      l_mode
  into   rec_uploaded
  from   pay_run_types_f
  where  run_type_id = rec_uploaded.rt_id
  and    effective_start_date = l_out_esd
  and    effective_end_date = l_out_eed;
  --
end update_row;
-------------------------------------------
-- procedure SET_END_DATE
--
-- SET_END_DATE is used to set the end date of updated or newly inserted rows
-- that are not set to the end of time.
-- First check if any child rows exist. If they do, then ZAP them, so that the
-- parent row can be end date deleted. If the children should still exist,
-- they will be reinserted as part of the run type usage upload.
--
-------------------------------------------
procedure set_end_date is
--
cursor chk_for_children
is
select run_type_usage_id
,      object_version_number
,      business_group_id
,      legislation_code
from   pay_run_type_usages_f
where  parent_run_type_id = rec_uploaded.rt_id
and    effective_end_date >= g_to_be_uploaded_eed;
--
cursor chk_for_tl_children
is
select 1
from   pay_run_types_f_tl
where  run_type_id = rec_uploaded.rt_id;
--
l_ch_rtu_id number;
l_ch_ovn    number;
l_ch_bg     number;
l_ch_leg    varchar2(30);
l_tl_exists number;
--
begin
--
hr_startup_data_api_support.enable_startup_mode(l_mode);
--
  if l_mode <> 'USER' then
    hr_startup_data_api_support.delete_owner_definitions;
    hr_startup_data_api_support.create_owner_definition('PAY');
  end if;
--
open  chk_for_children;
fetch chk_for_children into l_ch_rtu_id, l_ch_ovn, l_ch_bg, l_ch_leg;
if chk_for_children%FOUND then
--
  close chk_for_children;
  for each_child in chk_for_children loop
  --
    pay_run_type_usage_api.delete_run_type_usage
     (p_effective_date        => g_to_be_uploaded_eed
     ,p_datetrack_delete_mode => 'ZAP'
     ,p_run_type_usage_id     => each_child.run_type_usage_id
     ,p_object_version_number => each_child.object_version_number
     ,p_business_group_id     => each_child.business_group_id
     ,p_legislation_code      => each_child.legislation_code
     ,p_effective_start_date  => l_out_esd
     ,p_effective_end_date    => l_out_eed
     );
  end loop;
else
  close chk_for_children;
end if;
--
open  chk_for_tl_children;
fetch chk_for_tl_children into l_tl_exists;
if    chk_for_tl_children%FOUND then
  close chk_for_tl_children;
  pay_rtt_del.del_tl(p_run_type_id => rec_uploaded.rt_id);
else
  close chk_for_tl_children;
end if;
--
-- now delete the run type
--
  pay_run_type_api.delete_run_type
        (p_effective_date        => g_to_be_uploaded_eed
        ,p_datetrack_delete_mode => 'DELETE'
        ,p_run_type_id           => rec_uploaded.rt_id
        ,p_object_version_number => rec_uploaded.rt_ovn
        ,p_business_group_id     => rec_uploaded.rt_bg
        ,p_legislation_code      => rec_uploaded.rt_leg_code
        ,p_effective_start_date  => l_out_esd
        ,p_effective_end_date    => l_out_eed
        );
--
end set_end_date;
--
--
BEGIN -- up_run_type
--
-- Set the mode
--
If p_business_group IS NOT NULL then
   if p_legislative_code IS NULL THEN
     l_mode := 'USER';
     --
     -- get the bg id
     --
     open  get_bg_id;
     fetch get_bg_id into l_bg;
     close get_bg_id;
   else
     -- raise error cannot have leg and bg populated
     null;
   end if;
else -- bg is null
  if p_legislative_code is NOT NULL then
    l_mode := 'STARTUP';
  else
    l_mode := 'GENERIC';
  end if;
end if;
--
-- Is the new row part of the same dt record as the last uploaded row?
--
IF p_eof_number = 1 then
IF p_rt_id <> g_old_rt_id then
--
-- this is a new upload row. Check to see if the previous uploaded record's
-- effective end date was eot. If not update the row to whatever the end
-- date should be.
--
  if g_to_be_uploaded_eed <> hr_api.g_eot then
  --
    if l_call_set_end_date then
      hr_utility.trace('before SET_END_DATE');
      set_end_date;
      hr_utility.trace('after SET_END_DATE');
    else
      null;
    end if;
  else
    -- clear down prev_upload_rec;
    null;
  end if;
--
-- Cache the row to be upload
--
  g_to_be_uploaded_eed := p_effective_end_date;
  --
  g_old_rt_id := p_rt_id;
  --
  -- clear down the uploaded row, as now on new row
  --
  rec_uploaded.rt_id        := '';
  rec_uploaded.rt_name      := '';
  rec_uploaded.rt_shortname := '';
  rec_uploaded.rt_srs_flag  := '';
  rec_uploaded.rt_run_information_category := '';
  rec_uploaded.rt_run_information1 :='';
  rec_uploaded.rt_run_information2 :='';
  rec_uploaded.rt_run_information3 :='';
  rec_uploaded.rt_run_information4 :='';
  rec_uploaded.rt_run_information5 :='';
  rec_uploaded.rt_run_information6 :='';
  rec_uploaded.rt_run_information7 :='';
  rec_uploaded.rt_run_information8 :='';
  rec_uploaded.rt_run_information9 :='';
  rec_uploaded.rt_run_information10 :='';
  rec_uploaded.rt_run_information11 :='';
  rec_uploaded.rt_run_information12 :='';
  rec_uploaded.rt_run_information13 :='';
  rec_uploaded.rt_run_information14 :='';
  rec_uploaded.rt_run_information15 :='';
  rec_uploaded.rt_run_information16 :='';
  rec_uploaded.rt_run_information17 :='';
  rec_uploaded.rt_run_information18 :='';
  rec_uploaded.rt_run_information19 :='';
  rec_uploaded.rt_run_information20 :='';
  rec_uploaded.rt_run_information21 :='';
  rec_uploaded.rt_run_information22 :='';
  rec_uploaded.rt_run_information23 :='';
  rec_uploaded.rt_run_information24 :='';
  rec_uploaded.rt_run_information25 :='';
  rec_uploaded.rt_run_information26 :='';
  rec_uploaded.rt_run_information27 :='';
  rec_uploaded.rt_run_information28 :='';
  rec_uploaded.rt_run_information29 :='';
  rec_uploaded.rt_run_information30 :='';
  rec_uploaded.rt_leg_code  := '';
  rec_uploaded.rt_bg        := '';
  rec_uploaded.rt_esd       := '';
  rec_uploaded.rt_eed       := '';
  rec_uploaded.rt_ovn       := '';
  rec_uploaded.rt_mode      := '';
--
-- Does the same row already exist on the db?
--
  if l_mode = 'USER' then
hr_utility.trace('p_rt_name: '||p_rt_name);
    open u_row_exists;
    fetch u_row_exists into l_rt_id, l_rt_nm, l_shrtnm, l_srs_flag
			   ,l_run_information_category, l_run_information1,
			   l_run_information2
			   ,l_run_information3, l_run_information4,
			   l_run_information5
			   ,l_run_information6, l_run_information7,
			   l_run_information8
			   ,l_run_information9, l_run_information10,
			   l_run_information11
			   ,l_run_information12, l_run_information13,
			   l_run_information14
			   ,l_run_information15, l_run_information16,
			   l_run_information17
			   ,l_run_information18, l_run_information19,
			   l_run_information20
			   ,l_run_information21, l_run_information22,
			   l_run_information23
			   ,l_run_information24, l_run_information25,
			   l_run_information26
			   ,l_run_information27, l_run_information28,
			   l_run_information29
                           ,l_run_information30, l_lc, l_bg, l_esd, l_eed,
			   l_ovn;
    IF u_row_exists%NOTFOUND then
hr_utility.trace('l_rt_id: '||to_char(l_rt_id));
      close u_row_exists;
      insert_row;
    ELSE -- this row does already exist
    --
    -- see if any changes have been made
    --
--
      if l_rt_nm <> p_rt_name
      or nvl(l_shrtnm,'NULL_VALUE') <> nvl(p_shortname,'NULL_VALUE')
      or nvl(l_srs_flag,'NULL_VALUE') <> nvl(p_srs_flag,'NULL_VALUE')
      or nvl(l_run_information_category,'NULL_VALUE')
         <> nvl(p_run_information_category,'NULL_VALUE')
      or nvl(l_run_information1,'NULL_VALUE')
         <> nvl(p_run_information1,'NULL_VALUE')
      or nvl(l_run_information2,'NULL_VALUE')
         <> nvl(p_run_information2,'NULL_VALUE')
      or nvl(l_run_information3,'NULL_VALUE')
         <> nvl(p_run_information3,'NULL_VALUE')
      or nvl(l_run_information4,'NULL_VALUE')
         <> nvl(p_run_information4,'NULL_VALUE')
      or nvl(l_run_information5,'NULL_VALUE')
         <> nvl(p_run_information5,'NULL_VALUE')
      or nvl(l_run_information6,'NULL_VALUE')
         <> nvl(p_run_information6,'NULL_VALUE')
      or nvl(l_run_information7,'NULL_VALUE')
         <> nvl(p_run_information7,'NULL_VALUE')
      or nvl(l_run_information8,'NULL_VALUE')
         <> nvl(p_run_information8,'NULL_VALUE')
      or nvl(l_run_information9,'NULL_VALUE')
         <> nvl(p_run_information9,'NULL_VALUE')
      or nvl(l_run_information10,'NULL_VALUE')
         <> nvl(p_run_information10,'NULL_VALUE')
      or nvl(l_run_information11,'NULL_VALUE')
         <> nvl(p_run_information11,'NULL_VALUE')
      or nvl(l_run_information12,'NULL_VALUE')
         <> nvl(p_run_information12,'NULL_VALUE')
      or nvl(l_run_information13,'NULL_VALUE')
         <> nvl(p_run_information13,'NULL_VALUE')
      or nvl(l_run_information14,'NULL_VALUE')
         <> nvl(p_run_information14,'NULL_VALUE')
      or nvl(l_run_information15,'NULL_VALUE')
         <> nvl(p_run_information15,'NULL_VALUE')
      or nvl(l_run_information16,'NULL_VALUE')
         <> nvl(p_run_information16,'NULL_VALUE')
      or nvl(l_run_information17,'NULL_VALUE')
         <> nvl(p_run_information17,'NULL_VALUE')
      or nvl(l_run_information18,'NULL_VALUE')
         <> nvl(p_run_information18,'NULL_VALUE')
      or nvl(l_run_information19,'NULL_VALUE')
         <> nvl(p_run_information19,'NULL_VALUE')
      or nvl(l_run_information20,'NULL_VALUE')
         <> nvl(p_run_information20,'NULL_VALUE')
      or nvl(l_run_information21,'NULL_VALUE')
         <> nvl(p_run_information21,'NULL_VALUE')
      or nvl(l_run_information22,'NULL_VALUE')
         <> nvl(p_run_information22,'NULL_VALUE')
      or nvl(l_run_information23,'NULL_VALUE')
         <> nvl(p_run_information23,'NULL_VALUE')
      or nvl(l_run_information24,'NULL_VALUE')
         <> nvl(p_run_information24,'NULL_VALUE')
      or nvl(l_run_information25,'NULL_VALUE')
         <> nvl(p_run_information25,'NULL_VALUE')
      or nvl(l_run_information26,'NULL_VALUE')
         <> nvl(p_run_information26,'NULL_VALUE')
      or nvl(l_run_information27,'NULL_VALUE')
         <> nvl(p_run_information27,'NULL_VALUE')
      or nvl(l_run_information28,'NULL_VALUE')
         <> nvl(p_run_information28,'NULL_VALUE')
      or nvl(l_run_information29,'NULL_VALUE')
         <> nvl(p_run_information29,'NULL_VALUE')
      or nvl(l_run_information30,'NULL_VALUE')
         <> nvl(p_run_information30,'NULL_VALUE')
      or l_esd <> p_effective_start_date then
      --
hr_utility.trace('before zap l_rt_id: '||to_char(l_rt_id));
        zap_insert(l_rt_id);
        --
      else
      --
      -- check if just end date has changed
      --
        if l_eed <> p_effective_end_date then
        --
        -- don't actually have to update the row, as it is the same
        -- as an existing row except for the end date, which will be set
        -- using 'SET_END_DATE' later. So cache the values for later use.
        --
          rec_uploaded.rt_id        := l_rt_id;
          rec_uploaded.rt_name      := l_rt_nm;
          rec_uploaded.rt_shortname := l_shrtnm;
          rec_uploaded.rt_srs_flag  := l_srs_flag;
	  rec_uploaded.rt_run_information_category :=
				l_run_information_category;
	  rec_uploaded.rt_run_information1 := l_run_information1;
	  rec_uploaded.rt_run_information2 := l_run_information2;
	  rec_uploaded.rt_run_information3 := l_run_information3;
	  rec_uploaded.rt_run_information4 := l_run_information4;
	  rec_uploaded.rt_run_information5 := l_run_information5;
	  rec_uploaded.rt_run_information6 := l_run_information6;
	  rec_uploaded.rt_run_information7 := l_run_information7;
	  rec_uploaded.rt_run_information8 := l_run_information8;
	  rec_uploaded.rt_run_information9 := l_run_information9;
	  rec_uploaded.rt_run_information10 := l_run_information10;
	  rec_uploaded.rt_run_information11 := l_run_information11;
	  rec_uploaded.rt_run_information12 := l_run_information12;
	  rec_uploaded.rt_run_information13 := l_run_information13;
	  rec_uploaded.rt_run_information14 := l_run_information14;
	  rec_uploaded.rt_run_information15 := l_run_information15;
	  rec_uploaded.rt_run_information16 := l_run_information16;
	  rec_uploaded.rt_run_information17 := l_run_information17;
	  rec_uploaded.rt_run_information18 := l_run_information18;
	  rec_uploaded.rt_run_information19 := l_run_information19;
	  rec_uploaded.rt_run_information20 := l_run_information20;
	  rec_uploaded.rt_run_information21 := l_run_information21;
	  rec_uploaded.rt_run_information22 := l_run_information22;
	  rec_uploaded.rt_run_information23 := l_run_information23;
	  rec_uploaded.rt_run_information24 := l_run_information24;
	  rec_uploaded.rt_run_information25 := l_run_information25;
	  rec_uploaded.rt_run_information26 := l_run_information26;
	  rec_uploaded.rt_run_information27 := l_run_information27;
	  rec_uploaded.rt_run_information28 := l_run_information28;
	  rec_uploaded.rt_run_information29 := l_run_information29;
	  rec_uploaded.rt_run_information30 := l_run_information30;
          rec_uploaded.rt_leg_code  := l_lc;
          rec_uploaded.rt_bg        := l_bg;
          rec_uploaded.rt_esd       := l_esd;
          rec_uploaded.rt_eed       := l_eed;
          rec_uploaded.rt_ovn       := l_ovn;
          rec_uploaded.rt_mode      := l_mode;
        else
          l_call_set_end_date := false;
        end if;
      end if;
      --
    close u_row_exists;
    END IF; -- does row already exist for u_row_exists
    --
  elsif l_mode = 'STARTUP' then
    open s_row_exists;
    fetch s_row_exists into l_rt_id, l_rt_nm, l_shrtnm, l_srs_flag
			   ,l_run_information_category, l_run_information1,
			   l_run_information2
			   ,l_run_information3, l_run_information4,
			   l_run_information5
			   ,l_run_information6, l_run_information7,
			   l_run_information8
			   ,l_run_information9, l_run_information10,
			   l_run_information11
			   ,l_run_information12, l_run_information13,
			   l_run_information14
			   ,l_run_information15, l_run_information16,
			   l_run_information17
			   ,l_run_information18, l_run_information19,
			   l_run_information20
			   ,l_run_information21, l_run_information22,
			   l_run_information23
			   ,l_run_information24, l_run_information25,
			   l_run_information26
			   ,l_run_information27, l_run_information28,
			   l_run_information29
                           ,l_run_information30, l_lc, l_bg, l_esd, l_eed,
			   l_ovn;
    IF s_row_exists%NOTFOUND then
      close s_row_exists;
      insert_row;
    ELSE -- this row does already exist
    --
    -- see if any changes have been made
    --
     if l_rt_nm <> p_rt_name
      or nvl(l_shrtnm,'NULL_VALUE') <> nvl(p_shortname,'NULL_VALUE')
      or nvl(l_srs_flag,'NULL_VALUE') <> nvl(p_srs_flag,'NULL_VALUE')
      or nvl(l_run_information_category,'NULL_VALUE')
         <> nvl(p_run_information_category,'NULL_VALUE')
      or nvl(l_run_information1,'NULL_VALUE')
         <> nvl(p_run_information1,'NULL_VALUE')
      or nvl(l_run_information2,'NULL_VALUE')
         <> nvl(p_run_information2,'NULL_VALUE')
      or nvl(l_run_information3,'NULL_VALUE')
         <> nvl(p_run_information3,'NULL_VALUE')
      or nvl(l_run_information4,'NULL_VALUE')
         <> nvl(p_run_information4,'NULL_VALUE')
      or nvl(l_run_information5,'NULL_VALUE')
         <> nvl(p_run_information5,'NULL_VALUE')
      or nvl(l_run_information6,'NULL_VALUE')
         <> nvl(p_run_information6,'NULL_VALUE')
      or nvl(l_run_information7,'NULL_VALUE')
         <> nvl(p_run_information7,'NULL_VALUE')
      or nvl(l_run_information8,'NULL_VALUE')
         <> nvl(p_run_information8,'NULL_VALUE')
      or nvl(l_run_information9,'NULL_VALUE')
         <> nvl(p_run_information9,'NULL_VALUE')
      or nvl(l_run_information10,'NULL_VALUE')
         <> nvl(p_run_information10,'NULL_VALUE')
      or nvl(l_run_information11,'NULL_VALUE')
         <> nvl(p_run_information11,'NULL_VALUE')
      or nvl(l_run_information12,'NULL_VALUE')
         <> nvl(p_run_information12,'NULL_VALUE')
      or nvl(l_run_information13,'NULL_VALUE')
         <> nvl(p_run_information13,'NULL_VALUE')
      or nvl(l_run_information14,'NULL_VALUE')
         <> nvl(p_run_information14,'NULL_VALUE')
      or nvl(l_run_information15,'NULL_VALUE')
         <> nvl(p_run_information15,'NULL_VALUE')
      or nvl(l_run_information16,'NULL_VALUE')
         <> nvl(p_run_information16,'NULL_VALUE')
      or nvl(l_run_information17,'NULL_VALUE')
         <> nvl(p_run_information17,'NULL_VALUE')
      or nvl(l_run_information18,'NULL_VALUE')
         <> nvl(p_run_information18,'NULL_VALUE')
      or nvl(l_run_information19,'NULL_VALUE')
         <> nvl(p_run_information19,'NULL_VALUE')
      or nvl(l_run_information20,'NULL_VALUE')
         <> nvl(p_run_information20,'NULL_VALUE')
      or nvl(l_run_information21,'NULL_VALUE')
         <> nvl(p_run_information21,'NULL_VALUE')
      or nvl(l_run_information22,'NULL_VALUE')
         <> nvl(p_run_information22,'NULL_VALUE')
      or nvl(l_run_information23,'NULL_VALUE')
         <> nvl(p_run_information23,'NULL_VALUE')
      or nvl(l_run_information24,'NULL_VALUE')
         <> nvl(p_run_information24,'NULL_VALUE')
      or nvl(l_run_information25,'NULL_VALUE')
         <> nvl(p_run_information25,'NULL_VALUE')
      or nvl(l_run_information26,'NULL_VALUE')
         <> nvl(p_run_information26,'NULL_VALUE')
      or nvl(l_run_information27,'NULL_VALUE')
         <> nvl(p_run_information27,'NULL_VALUE')
      or nvl(l_run_information28,'NULL_VALUE')
         <> nvl(p_run_information28,'NULL_VALUE')
      or nvl(l_run_information29,'NULL_VALUE')
         <> nvl(p_run_information29,'NULL_VALUE')
      or nvl(l_run_information30,'NULL_VALUE')
         <> nvl(p_run_information30,'NULL_VALUE')
      or l_esd <> p_effective_start_date then
      --
        zap_insert(l_rt_id);
        --
      else
      --
      -- check if just end date has changed
      --
        if l_eed <> p_effective_end_date then
        --
        -- don't actually have to update the row, as it is the same
        -- as an existing row except for the end date, which will be set
        -- using 'SET_END_DATE' later. So cache the values for later use.
        --
          rec_uploaded.rt_id        := l_rt_id;
          rec_uploaded.rt_name      := l_rt_nm;
          rec_uploaded.rt_shortname := l_shrtnm;
          rec_uploaded.rt_srs_flag  := l_srs_flag;
	  rec_uploaded.rt_run_information_category :=
				l_run_information_category;
	  rec_uploaded.rt_run_information1 := l_run_information1;
	  rec_uploaded.rt_run_information2 := l_run_information2;
	  rec_uploaded.rt_run_information3 := l_run_information3;
	  rec_uploaded.rt_run_information4 := l_run_information4;
	  rec_uploaded.rt_run_information5 := l_run_information5;
	  rec_uploaded.rt_run_information6 := l_run_information6;
	  rec_uploaded.rt_run_information7 := l_run_information7;
	  rec_uploaded.rt_run_information8 := l_run_information8;
	  rec_uploaded.rt_run_information9 := l_run_information9;
	  rec_uploaded.rt_run_information10 := l_run_information10;
	  rec_uploaded.rt_run_information11 := l_run_information11;
	  rec_uploaded.rt_run_information12 := l_run_information12;
	  rec_uploaded.rt_run_information13 := l_run_information13;
	  rec_uploaded.rt_run_information14 := l_run_information14;
	  rec_uploaded.rt_run_information15 := l_run_information15;
	  rec_uploaded.rt_run_information16 := l_run_information16;
	  rec_uploaded.rt_run_information17 := l_run_information17;
	  rec_uploaded.rt_run_information18 := l_run_information18;
	  rec_uploaded.rt_run_information19 := l_run_information19;
	  rec_uploaded.rt_run_information20 := l_run_information20;
	  rec_uploaded.rt_run_information21 := l_run_information21;
	  rec_uploaded.rt_run_information22 := l_run_information22;
	  rec_uploaded.rt_run_information23 := l_run_information23;
	  rec_uploaded.rt_run_information24 := l_run_information24;
	  rec_uploaded.rt_run_information25 := l_run_information25;
	  rec_uploaded.rt_run_information26 := l_run_information26;
	  rec_uploaded.rt_run_information27 := l_run_information27;
	  rec_uploaded.rt_run_information28 := l_run_information28;
	  rec_uploaded.rt_run_information29 := l_run_information29;
	  rec_uploaded.rt_run_information30 := l_run_information30;
          rec_uploaded.rt_leg_code  := l_lc;
          rec_uploaded.rt_bg        := l_bg;
          rec_uploaded.rt_esd       := l_esd;
          rec_uploaded.rt_eed       := l_eed;
          rec_uploaded.rt_ovn       := l_ovn;
          rec_uploaded.rt_mode      := l_mode;
        else
          l_call_set_end_date := false;
        end if;
      end if;
      --
    close s_row_exists;
    END IF; -- does row already exist for s_row_exists
    --
  else -- l_mode = GENERIC
    open  g_row_exists;
    fetch g_row_exists into l_rt_id, l_rt_nm, l_shrtnm, l_srs_flag
			   ,l_run_information_category, l_run_information1,
			   l_run_information2
			   ,l_run_information3, l_run_information4,
			   l_run_information5
			   ,l_run_information6, l_run_information7,
			   l_run_information8
			   ,l_run_information9, l_run_information10,
			   l_run_information11
			   ,l_run_information12, l_run_information13,
			   l_run_information14
			   ,l_run_information15, l_run_information16,
			   l_run_information17
			   ,l_run_information18, l_run_information19,
			   l_run_information20
			   ,l_run_information21, l_run_information22,
			   l_run_information23
			   ,l_run_information24, l_run_information25,
			   l_run_information26
			   ,l_run_information27, l_run_information28,
			   l_run_information29
                           ,l_run_information30, l_lc, l_bg, l_esd, l_eed,
			   l_ovn;
    IF g_row_exists%NOTFOUND then
      close g_row_exists;
      insert_row;
    ELSE -- this row does already exist
    --
    -- see if any changes have been made
    --
     if l_rt_nm <> p_rt_name
      or nvl(l_shrtnm,'NULL_VALUE') <> nvl(p_shortname,'NULL_VALUE')
      or nvl(l_srs_flag,'NULL_VALUE') <> nvl(p_srs_flag,'NULL_VALUE')
      or nvl(l_run_information_category,'NULL_VALUE')
         <> nvl(p_run_information_category,'NULL_VALUE')
      or nvl(l_run_information1,'NULL_VALUE')
         <> nvl(p_run_information1,'NULL_VALUE')
      or nvl(l_run_information2,'NULL_VALUE')
         <> nvl(p_run_information2,'NULL_VALUE')
      or nvl(l_run_information3,'NULL_VALUE')
         <> nvl(p_run_information3,'NULL_VALUE')
      or nvl(l_run_information4,'NULL_VALUE')
         <> nvl(p_run_information4,'NULL_VALUE')
      or nvl(l_run_information5,'NULL_VALUE')
         <> nvl(p_run_information5,'NULL_VALUE')
      or nvl(l_run_information6,'NULL_VALUE')
         <> nvl(p_run_information6,'NULL_VALUE')
      or nvl(l_run_information7,'NULL_VALUE')
         <> nvl(p_run_information7,'NULL_VALUE')
      or nvl(l_run_information8,'NULL_VALUE')
         <> nvl(p_run_information8,'NULL_VALUE')
      or nvl(l_run_information9,'NULL_VALUE')
         <> nvl(p_run_information9,'NULL_VALUE')
      or nvl(l_run_information10,'NULL_VALUE')
         <> nvl(p_run_information10,'NULL_VALUE')
      or nvl(l_run_information11,'NULL_VALUE')
         <> nvl(p_run_information11,'NULL_VALUE')
      or nvl(l_run_information12,'NULL_VALUE')
         <> nvl(p_run_information12,'NULL_VALUE')
      or nvl(l_run_information13,'NULL_VALUE')
         <> nvl(p_run_information13,'NULL_VALUE')
      or nvl(l_run_information14,'NULL_VALUE')
         <> nvl(p_run_information14,'NULL_VALUE')
      or nvl(l_run_information15,'NULL_VALUE')
         <> nvl(p_run_information15,'NULL_VALUE')
      or nvl(l_run_information16,'NULL_VALUE')
         <> nvl(p_run_information16,'NULL_VALUE')
      or nvl(l_run_information17,'NULL_VALUE')
         <> nvl(p_run_information17,'NULL_VALUE')
      or nvl(l_run_information18,'NULL_VALUE')
         <> nvl(p_run_information18,'NULL_VALUE')
      or nvl(l_run_information19,'NULL_VALUE')
         <> nvl(p_run_information19,'NULL_VALUE')
      or nvl(l_run_information20,'NULL_VALUE')
         <> nvl(p_run_information20,'NULL_VALUE')
      or nvl(l_run_information21,'NULL_VALUE')
         <> nvl(p_run_information21,'NULL_VALUE')
      or nvl(l_run_information22,'NULL_VALUE')
         <> nvl(p_run_information22,'NULL_VALUE')
      or nvl(l_run_information23,'NULL_VALUE')
         <> nvl(p_run_information23,'NULL_VALUE')
      or nvl(l_run_information24,'NULL_VALUE')
         <> nvl(p_run_information24,'NULL_VALUE')
      or nvl(l_run_information25,'NULL_VALUE')
         <> nvl(p_run_information25,'NULL_VALUE')
      or nvl(l_run_information26,'NULL_VALUE')
         <> nvl(p_run_information26,'NULL_VALUE')
      or nvl(l_run_information27,'NULL_VALUE')
         <> nvl(p_run_information27,'NULL_VALUE')
      or nvl(l_run_information28,'NULL_VALUE')
         <> nvl(p_run_information28,'NULL_VALUE')
      or nvl(l_run_information29,'NULL_VALUE')
         <> nvl(p_run_information29,'NULL_VALUE')
      or nvl(l_run_information30,'NULL_VALUE')
         <> nvl(p_run_information30,'NULL_VALUE')
      or l_esd <> p_effective_start_date then
      --
        zap_insert(l_rt_id);
        --
      else
      --
      -- check if just end date has changed
      --
        if l_eed <> p_effective_end_date then
        --
        -- don't actually have to update the row, as it is the same
        -- as an existing row except for the end date, which will be set
        -- using 'SET_END_DATE' later. So cache the values for later use.
        --
          rec_uploaded.rt_id        := l_rt_id;
          rec_uploaded.rt_name      := l_rt_nm;
          rec_uploaded.rt_shortname := l_shrtnm;
          rec_uploaded.rt_srs_flag  := l_srs_flag;
	  rec_uploaded.rt_run_information_category :=
				l_run_information_category;
	  rec_uploaded.rt_run_information1 := l_run_information1;
	  rec_uploaded.rt_run_information2 := l_run_information2;
	  rec_uploaded.rt_run_information3 := l_run_information3;
	  rec_uploaded.rt_run_information4 := l_run_information4;
	  rec_uploaded.rt_run_information5 := l_run_information5;
	  rec_uploaded.rt_run_information6 := l_run_information6;
	  rec_uploaded.rt_run_information7 := l_run_information7;
	  rec_uploaded.rt_run_information8 := l_run_information8;
	  rec_uploaded.rt_run_information9 := l_run_information9;
	  rec_uploaded.rt_run_information10 := l_run_information10;
	  rec_uploaded.rt_run_information11 := l_run_information11;
	  rec_uploaded.rt_run_information12 := l_run_information12;
	  rec_uploaded.rt_run_information13 := l_run_information13;
	  rec_uploaded.rt_run_information14 := l_run_information14;
	  rec_uploaded.rt_run_information15 := l_run_information15;
	  rec_uploaded.rt_run_information16 := l_run_information16;
	  rec_uploaded.rt_run_information17 := l_run_information17;
	  rec_uploaded.rt_run_information18 := l_run_information18;
	  rec_uploaded.rt_run_information19 := l_run_information19;
	  rec_uploaded.rt_run_information20 := l_run_information20;
	  rec_uploaded.rt_run_information21 := l_run_information21;
	  rec_uploaded.rt_run_information22 := l_run_information22;
	  rec_uploaded.rt_run_information23 := l_run_information23;
	  rec_uploaded.rt_run_information24 := l_run_information24;
	  rec_uploaded.rt_run_information25 := l_run_information25;
	  rec_uploaded.rt_run_information26 := l_run_information26;
	  rec_uploaded.rt_run_information27 := l_run_information27;
	  rec_uploaded.rt_run_information28 := l_run_information28;
	  rec_uploaded.rt_run_information29 := l_run_information29;
	  rec_uploaded.rt_run_information30 := l_run_information30;
          rec_uploaded.rt_leg_code  := l_lc;
          rec_uploaded.rt_bg        := l_bg;
          rec_uploaded.rt_esd       := l_esd;
          rec_uploaded.rt_eed       := l_eed;
          rec_uploaded.rt_ovn       := l_ovn;
          rec_uploaded.rt_mode      := l_mode;
        else
          l_call_set_end_date := false;
        end if;
      end if;
      --
      close g_row_exists;
    END IF; -- does row already exist for g_row_exists
  end if; -- what mode in
  --
ELSE -- p_rt_id is same as g_old_rt_id so same dt row
--
-- update the g_to_be_uploaded_eed value
--
  g_to_be_uploaded_eed := p_effective_end_date;
  --
  -- get row which should still be in uploaded_rec and compare with row
  -- being uploaded
  --
  if rec_uploaded.rt_name <> p_rt_name
  or rec_uploaded.rt_shortname <> p_shortname
  or rec_uploaded.rt_srs_flag  <> p_srs_flag
  or rec_uploaded.rt_run_information_category <> p_run_information_category
  or rec_uploaded.rt_run_information1 <> rec_uploaded.rt_run_information1
  or rec_uploaded.rt_run_information2 <> rec_uploaded.rt_run_information2
  or rec_uploaded.rt_run_information3 <> rec_uploaded.rt_run_information3
  or rec_uploaded.rt_run_information4 <> rec_uploaded.rt_run_information4
  or rec_uploaded.rt_run_information5 <> rec_uploaded.rt_run_information5
  or rec_uploaded.rt_run_information6 <> rec_uploaded.rt_run_information6
  or rec_uploaded.rt_run_information7 <> rec_uploaded.rt_run_information7
  or rec_uploaded.rt_run_information8 <> rec_uploaded.rt_run_information8
  or rec_uploaded.rt_run_information9 <> rec_uploaded.rt_run_information9
  or rec_uploaded.rt_run_information10 <> rec_uploaded.rt_run_information10
  or rec_uploaded.rt_run_information11 <> rec_uploaded.rt_run_information11
  or rec_uploaded.rt_run_information12 <> rec_uploaded.rt_run_information12
  or rec_uploaded.rt_run_information13 <> rec_uploaded.rt_run_information13
  or rec_uploaded.rt_run_information14 <> rec_uploaded.rt_run_information14
  or rec_uploaded.rt_run_information15 <> rec_uploaded.rt_run_information15
  or rec_uploaded.rt_run_information16 <> rec_uploaded.rt_run_information16
  or rec_uploaded.rt_run_information17 <> rec_uploaded.rt_run_information17
  or rec_uploaded.rt_run_information18 <> rec_uploaded.rt_run_information18
  or rec_uploaded.rt_run_information19 <> rec_uploaded.rt_run_information19
  or rec_uploaded.rt_run_information20 <> rec_uploaded.rt_run_information20
  or rec_uploaded.rt_run_information21 <> rec_uploaded.rt_run_information21
  or rec_uploaded.rt_run_information22 <> rec_uploaded.rt_run_information22
  or rec_uploaded.rt_run_information23 <> rec_uploaded.rt_run_information23
  or rec_uploaded.rt_run_information24 <> rec_uploaded.rt_run_information24
  or rec_uploaded.rt_run_information25 <> rec_uploaded.rt_run_information25
  or rec_uploaded.rt_run_information26 <> rec_uploaded.rt_run_information26
  or rec_uploaded.rt_run_information27 <> rec_uploaded.rt_run_information27
  or rec_uploaded.rt_run_information28 <> rec_uploaded.rt_run_information28
  or rec_uploaded.rt_run_information29 <> rec_uploaded.rt_run_information29
  or rec_uploaded.rt_run_information30 <> rec_uploaded.rt_run_information30
  or rec_uploaded.rt_esd <> p_effective_start_date
  or rec_uploaded.rt_eed <> p_effective_end_date then
  --
    update_row;
  end if;
  --
END IF; -- p_rt_id same as g_old_rt_id
else -- p_eof_number = 2
--
-- This indicates the final ldt row has been uploaded, just need to check
-- to see if the previous uploaded record's effective end date was eot.
-- If not update the row to whatever the end date should be.
--
  if g_to_be_uploaded_eed <> hr_api.g_eot then
    set_end_date;
    --update_row('SET_END_DATE');
  end if;
end if;
--
END up_run_type;
-----------------------------------------------------------------------------
 /* Name    : up_run_type_usage
  Purpose   : Uploads the Run Type Usage definition.
  Arguments :
  Notes     :
 */
-----------------------------------------------------------------------------
PROCEDURE up_run_type_usage(p_rtu_id               number
                           ,p_parent_run_type_name varchar2
                           ,p_child_run_type_name  varchar2
                           ,p_child_leg_code       varchar2
                           ,p_child_bg             varchar2
                           ,p_effective_start_date date
                           ,p_effective_end_date   date
                           ,p_legislation_code     varchar2
                           ,p_business_group       varchar2
                           ,p_sequence             number
                           ,p_rtu_eof_number       number
                           )
IS
--
-- 3 cursors for getting existing row, one for each mode.
--
cursor u_row_exists(p_parent_rt_id number
                   ,p_child_rt_id number)
is
select run_type_usage_id
,      parent_run_type_id
,      child_run_type_id
,      sequence
,      legislation_code
,      business_group_id
,      effective_start_date
,      effective_end_date
,      object_version_number
from   pay_run_type_usages_f
where  parent_run_type_id = p_parent_rt_id
and    child_run_type_id = p_child_rt_id
and    business_group_id = (select pbg.business_group_id
                                  from per_business_groups pbg
                                  where upper(pbg.name) = p_business_group)
and    legislation_code is null;
--
cursor s_row_exists(p_parent_rt_id number
                   ,p_child_rt_id number)
is
select run_type_usage_id
,      parent_run_type_id
,      child_run_type_id
,      sequence
,      legislation_code
,      business_group_id
,      effective_start_date
,      effective_end_date
,      object_version_number
from   pay_run_type_usages_f
where  parent_run_type_id = p_parent_rt_id
and    child_run_type_id = p_child_rt_id
and    legislation_code = p_legislation_code
and    business_group_id is null;
--
cursor g_row_exists(p_parent_rt_id number
                   ,p_child_rt_id number)
is
select run_type_usage_id
,      parent_run_type_id
,      child_run_type_id
,      sequence
,      legislation_code
,      business_group_id
,      effective_start_date
,      effective_end_date
,      object_version_number
from   pay_run_type_usages_f
where  parent_run_type_id = p_parent_rt_id
and    child_run_type_id = p_child_rt_id
and    business_group_id is null
and    legislation_code is null;
--
cursor get_bg_id(p_bg_name varchar2)
is
select business_group_id
from   per_business_groups
where  UPPER(name) = upper(p_bg_name);
--
cursor get_parent_id (p_bg_id number)
is
select prt.run_type_id
from   pay_run_types_f prt
where  prt.run_type_name = p_parent_run_type_name
and    p_effective_start_date between prt.effective_start_date
                                  and prt.effective_end_date
and    ((p_business_group is not null
and      prt.business_group_id = p_bg_id)
or      (p_legislation_code is not null
and      prt.legislation_code = p_legislation_code)
or      (p_business_group      is null
and      p_legislation_code    is null
and      prt.business_group_id is null
and      prt.legislation_code  is null));
--
cursor get_child_rt_id(p_bg_id number)
is
select prt.run_type_id
from   pay_run_types_f prt
where  prt.run_type_name = p_child_run_type_name
and    p_effective_start_date between prt.effective_start_date
                                  and prt.effective_end_date
and    ((p_child_bg is not null
and      prt.business_group_id = p_bg_id)
or      (p_child_leg_code is not null
and      prt.legislation_code = p_child_leg_code)
or      (p_child_bg            is null
and      p_legislation_code    is null
and      prt.business_group_id is null
and      prt.legislation_code  is null));
--
cursor chk_valid_seq(p_par_id number
                    ,p_sequence_num number
                    ,p_eff_st_date date)
is
select run_type_usage_id
from   pay_run_type_usages_f
where  parent_run_type_id = p_par_id
and    sequence = p_sequence_num
and    p_eff_st_date between effective_start_date
                         and effective_end_date;
--
l_mode         varchar2(30) := 'USER';
l_rtu_id       number;
l_par_rt_id    number;
l_ch_rt_id     number;
l_seq          number;
l_esd          date;
l_eed          date;
l_lc           varchar2(30);
l_bg           number;
l_ch_bg        number;
l_ovn          number;
l_out_rtu_id    number;
l_out_esd      date;
l_out_eed      date;
l_out_ovn      number;
--
l_valid_seq number := 0;
-------------------------------------------
-- procedure insert_row
-------------------------------------------
procedure insert_row is
--
begin
--
hr_startup_data_api_support.enable_startup_mode(l_mode);
--
  if l_mode <> 'USER' then
    hr_startup_data_api_support.delete_owner_definitions;
    hr_startup_data_api_support.create_owner_definition('PAY');
  end if;
--
-- call insert api. End date will be EOT for now, will be updated
-- later if it should be anything other than eot.
--
  pay_run_type_usage_api.create_run_type_usage
               (p_effective_date        => p_effective_start_date
               ,p_parent_run_type_id    => l_par_rt_id
               ,p_child_run_type_id     => l_ch_rt_id
               ,p_sequence              => p_sequence
               ,p_business_group_id     => l_bg
               ,p_legislation_code      => p_legislation_code
               ,p_run_type_usage_id     => l_out_rtu_id
               ,p_effective_start_date  => l_out_esd
               ,p_effective_end_date    => l_out_eed
               ,p_object_version_number => l_out_ovn
               );
  --
  -- cache the new details
  --
  select run_type_usage_id
  ,      parent_run_type_id
  ,      child_run_type_id
  ,      sequence
  ,      legislation_code
  ,      business_group_id
  ,      effective_start_date
  ,      effective_end_date
  ,      object_version_number
  ,      l_mode
  into   rec_rtu_uploaded
  from   pay_run_type_usages_f
  where  run_type_usage_id = l_out_rtu_id;
  --
end insert_row;
-------------------------------------------
-- procedure zap_insert
--
-- zap_insert indicates that the row being uploaded already exists on the
-- new db, but that it is a new datetracked row from the ldt, i.e. it is the
-- first time this row has been updated. There may well be further
-- datetracked rows for this row (handled by update_row), so the effective end
-- date is left as eot.
--
-------------------------------------------
procedure zap_insert(p_rtu_id number) is
--
begin
--
hr_startup_data_api_support.enable_startup_mode(l_mode);
--
  if l_mode <> 'USER' then
    hr_startup_data_api_support.delete_owner_definitions;
    hr_startup_data_api_support.create_owner_definition('PAY');
  end if;
--
-- in order to update an existing row, need to purge the existing row
-- then insert a new row.
--
hr_utility.trace('l_rtu_id: '||to_char(l_rtu_id));
hr_utility.trace('eff start date: '||to_char(p_effective_start_date,'dd-mon-yyyy'));
--
-- use delete rather than api delete to bypass validation
--
delete from pay_run_type_usages_f
where  run_type_usage_id = p_rtu_id;
--
  if l_valid_seq <> 0 then
  --
  delete from pay_run_type_usages_f
  where  run_type_usage_id = l_valid_seq;
  end if;
  --
  pay_run_type_usage_api.create_run_type_usage
               (p_effective_date        => p_effective_start_date
               ,p_parent_run_type_id    => l_par_rt_id
               ,p_child_run_type_id     => l_ch_rt_id
               ,p_sequence              => p_sequence
               ,p_business_group_id     => l_bg
               ,p_legislation_code      => p_legislation_code
               ,p_run_type_usage_id     => l_out_rtu_id
               ,p_effective_start_date  => l_out_esd
               ,p_effective_end_date    => l_out_eed
               ,p_object_version_number => l_out_ovn
               );
--
hr_utility.trace('AFTER ZAP CREATE');
  --
  -- set the uploaded cache
  --
  select run_type_usage_id
  ,      parent_run_type_id
  ,      child_run_type_id
  ,      sequence
  ,      legislation_code
  ,      business_group_id
  ,      effective_start_date
  ,      effective_end_date
  ,      object_version_number
  ,      l_mode
  into   rec_rtu_uploaded
  from   pay_run_type_usages_f
  where  run_type_usage_id = l_out_rtu_id;
--
end zap_insert;
-------------------------------------------
-- procedure update_row
--
-- If multiple datatrack rows exist in the ldt for one particular row, multiple
-- updates will have to be done achieve the dt history. The effective_end_date
-- is left at eot. If eot is not the final end date of the dt row it will be
-- set to the correct date by set_end_date.
--
-------------------------------------------
procedure update_row is
--
begin
--
hr_startup_data_api_support.enable_startup_mode(l_mode);
--
  if l_mode <> 'USER' then
    hr_startup_data_api_support.delete_owner_definitions;
    hr_startup_data_api_support.create_owner_definition('PAY');
  end if;
--
  pay_run_type_usage_api.update_run_type_usage
               (p_effective_date        => p_effective_start_date
               ,p_datetrack_update_mode => 'UPDATE'
               ,p_run_type_usage_id     => rec_rtu_uploaded.rtu_id
               ,p_object_version_number => rec_rtu_uploaded.rtu_ovn
               ,p_sequence              => p_sequence
               ,p_business_group_id     => l_bg
               ,p_legislation_code      => p_legislation_code
               ,p_effective_start_date  => l_out_esd
               ,p_effective_end_date    => l_out_eed
               );
  --
  -- cache the lastest uploaded row
  --
  select run_type_usage_id
  ,      parent_run_type_id
  ,      child_run_type_id
  ,      sequence
  ,      legislation_code
  ,      business_group_id
  ,      effective_start_date
  ,      effective_end_date
  ,      object_version_number
  ,      l_mode
  into   rec_rtu_uploaded
  from   pay_run_type_usages_f
  where  run_type_usage_id = rec_rtu_uploaded.rtu_id
  and    effective_start_date = l_out_esd
  and    effective_end_date = l_out_eed;
  --
end update_row;
-------------------------------------------
-- procedure SET_END_DATE
--
-- SET_END_DATE is used to set the end date of updated or newly inserted rows
-- that are not set to the end of time.
--
-------------------------------------------
procedure set_end_date is
--
begin
--
hr_startup_data_api_support.enable_startup_mode(l_mode);
--
  if l_mode <> 'USER' then
    hr_startup_data_api_support.delete_owner_definitions;
    hr_startup_data_api_support.create_owner_definition('PAY');
  end if;
--
-- delete the run type usage
--
  pay_run_type_usage_api.delete_run_type_usage
        (p_effective_date        => g_rtu_to_be_uploaded_eed
        ,p_datetrack_delete_mode => 'DELETE'
        ,p_run_type_usage_id     => rec_rtu_uploaded.rtu_id
        ,p_object_version_number => rec_rtu_uploaded.rtu_ovn
        ,p_business_group_id     => rec_rtu_uploaded.rtu_bg
        ,p_legislation_code      => rec_rtu_uploaded.rtu_leg_code
        ,p_effective_start_date  => l_out_esd
        ,p_effective_end_date    => l_out_eed
        );
--
end set_end_date;
--
BEGIN -- up_run_type_usage
--
-- Set the mode
--
If p_business_group IS NOT NULL then
   if p_legislation_code IS NULL THEN
     l_mode := 'USER';
     --
     -- get the bg id
     --
     open  get_bg_id(p_business_group);
     fetch get_bg_id into l_bg;
     close get_bg_id;
   else
     -- raise error cannot have leg and bg populated
     null;
   end if;
else -- bg is null
  if p_legislation_code is NOT NULL then
    l_mode := 'STARTUP';
  else
    l_mode := 'GENERIC';
  end if;
end if;
--
-- Get the parent_run_type_id and child_run_type_id for the names that have
-- been passed through.
--
OPEN  get_parent_id(l_bg);
FETCH get_parent_id into l_par_rt_id;
CLOSE get_parent_id;
hr_utility.trace('l_par_rt_id: '||to_char(l_par_rt_id));
--
OPEN  get_bg_id(p_child_bg);
FETCH get_bg_id into l_ch_bg;
CLOSE get_bg_id;
hr_utility.trace('l_ch_bg: '||to_char(l_ch_bg));
--
OPEN  get_child_rt_id(l_ch_bg);
FETCH get_child_rt_id into l_ch_rt_id;
CLOSE  get_child_rt_id;
hr_utility.trace('l_ch_rt_id: '||to_char(l_ch_rt_id));
--
-- Is the new row the end of file row (rtu_eof_number = 2) ?
-- Is the new row part of the same dt record as the last uploaded row?
--
IF p_rtu_eof_number = 1 then
IF p_rtu_id <> g_old_rtu_id then
--
-- this is a new upload row. Check to see if the previous uploaded record's
-- effective end date was eot. If not update the row to whatever the end
-- date should be.
--
  if g_rtu_to_be_uploaded_eed <> hr_api.g_eot then
  --
    if l_call_rtu_set_end_date then
      hr_utility.trace('before SET_END_DATE');
      set_end_date;
      hr_utility.trace('after SET_END_DATE');
    else
      null;
    end if;
  else
    -- clear down prev_upload_rec;
    null;
  end if;
--
-- Cache the row to be upload
--
  g_rtu_to_be_uploaded_eed := p_effective_end_date;
  --
  g_old_rtu_id := p_rtu_id;
  --
  -- clear down the uploaded row, as now on new row
  --
  rec_rtu_uploaded.rtu_id           := '';
  rec_rtu_uploaded.rtu_parent_rt_id := '';
  rec_rtu_uploaded.rtu_child_rt_id  := '';
  rec_rtu_uploaded.rtu_sequence     := '';
  rec_rtu_uploaded.rtu_leg_code     := '';
  rec_rtu_uploaded.rtu_bg           := '';
  rec_rtu_uploaded.rtu_esd          := '';
  rec_rtu_uploaded.rtu_eed          := '';
  rec_rtu_uploaded.rtu_ovn          := '';
  rec_rtu_uploaded.rtu_mode         := '';
--
-- Does the same row already exist on the db?
--
  if l_mode = 'USER' then
    open u_row_exists(l_par_rt_id, l_ch_rt_id);
    fetch u_row_exists into l_rtu_id, l_par_rt_id, l_ch_rt_id, l_seq
                          , l_lc, l_bg, l_esd, l_eed, l_ovn;
    IF u_row_exists%NOTFOUND then
      close u_row_exists;
      insert_row;
    ELSE -- this row does already exist
    --
    -- see if any changes have been made
    --
      if l_seq <> p_sequence
      or l_esd <> p_effective_start_date then
      --
        zap_insert(l_rtu_id);
        --
      else
      --
      -- check if just end date has changed
      --
        if l_eed <> p_effective_end_date then
        --
        -- don't actually have to update the row, as it is the same
        -- as an existing row except for the end date, which will be set
        -- using 'SET_END_DATE' later. So cache the values for later use.
        --
          rec_rtu_uploaded.rtu_id           := l_rtu_id;
          rec_rtu_uploaded.rtu_parent_rt_id := l_par_rt_id;
          rec_rtu_uploaded.rtu_child_rt_id  := l_ch_rt_id;
          rec_rtu_uploaded.rtu_leg_code     := l_lc;
          rec_rtu_uploaded.rtu_bg           := l_bg;
          rec_rtu_uploaded.rtu_esd          := l_esd;
          rec_rtu_uploaded.rtu_eed          := l_eed;
          rec_rtu_uploaded.rtu_ovn          := l_ovn;
          rec_rtu_uploaded.rtu_mode         := l_mode;
        else
          --
          -- Row already exists and no columns have changed, so set_end_date
          -- does not need to be called. Set a flag to indicate this.
          --
          l_call_rtu_set_end_date := false;
        end if;
      end if;
      --
    close u_row_exists;
    END IF; -- does row already exist for u_row_exists
    --
  elsif l_mode = 'STARTUP' then
    open s_row_exists(l_par_rt_id, l_ch_rt_id);
    fetch s_row_exists into l_rtu_id, l_par_rt_id, l_ch_rt_id, l_seq
                          , l_lc, l_bg, l_esd, l_eed, l_ovn;
    IF s_row_exists%NOTFOUND then
      hr_utility.trace('this row does not exist');
      close s_row_exists;
      insert_row;
    ELSE -- this row does already exist
    hr_utility.trace('this row does exist');
    --
    -- see if any changes have been made
    --
      if l_seq <> p_sequence
      or l_esd <> p_effective_start_date then
      --
        if l_seq <> p_sequence then
        --
        -- check to see if there exists a row with this sequence and this
        -- parent id. If there is then get the rtu_id and also zap this row,
        -- so that the new row can be inserted.
        --
          open chk_valid_seq(l_par_rt_id, p_sequence, p_effective_start_date);
          fetch chk_valid_seq into l_valid_seq;
            if chk_valid_seq%FOUND then
              -- this sequence/parent_id exists, so store the rtu_id for zapping
              close chk_valid_seq;
            else
             -- sequence/parent_id does not exist so not extra zap to do,
             -- continue  with the insert
             null;
            end if;
            --
        end if;
        hr_utility.trace('this row does exist - before zap');
        zap_insert(l_rtu_id);
      else
      --
      -- check if just end date has changed
      --
        if l_eed <> p_effective_end_date then
        hr_utility.trace('this row does exist - eed changed');
        --
        --
        -- don't actually have to update the row, as it is the same
        -- as an existing row except for the end date, which will be set
        -- using 'SET_END_DATE' later. So cache the values for later use.
        --
          rec_rtu_uploaded.rtu_id           := l_rtu_id;
          rec_rtu_uploaded.rtu_parent_rt_id := l_par_rt_id;
          rec_rtu_uploaded.rtu_child_rt_id  := l_ch_rt_id;
          rec_rtu_uploaded.rtu_sequence     := l_seq;
          rec_rtu_uploaded.rtu_leg_code     := l_lc;
          rec_rtu_uploaded.rtu_bg           := l_bg;
          rec_rtu_uploaded.rtu_esd          := l_esd;
          rec_rtu_uploaded.rtu_eed          := l_eed;
          rec_rtu_uploaded.rtu_ovn          := l_ovn;
          rec_rtu_uploaded.rtu_mode         := l_mode;
        else
          --
          -- Row already exists and no columns have changed, so set_end_date
          -- does not need to be called. Set a flag to indicate this.
          --
          hr_utility.trace('row exists - no changes');
          l_call_rtu_set_end_date := false;
        end if;
      end if;
      --
    close s_row_exists;
    END IF; -- does row already exist for u_row_exists
    --
  else -- l_mode = GENERIC
    open  g_row_exists(l_par_rt_id, l_ch_rt_id);
    fetch g_row_exists into l_rtu_id, l_par_rt_id, l_ch_rt_id, l_seq
                          , l_lc, l_bg, l_esd, l_eed, l_ovn;
    IF g_row_exists%NOTFOUND then
      close g_row_exists;
      insert_row;
    ELSE -- this row does already exist
    --
    -- see if any changes have been made
    --
      if l_seq <> p_sequence
      or l_esd <> p_effective_start_date then
      --
        zap_insert(l_rtu_id);
      else
      --
      -- check if just end date has changed
      --
        if l_eed <> p_effective_end_date then
        --
        -- don't actually have to update the row, as it is the same
        -- as an existing row except for the end date, which will be set
        -- using 'SET_END_DATE' later. So cache the values for later use.
        --
          rec_rtu_uploaded.rtu_id           := l_rtu_id;
          rec_rtu_uploaded.rtu_parent_rt_id := l_par_rt_id;
          rec_rtu_uploaded.rtu_child_rt_id  := l_ch_rt_id;
          rec_rtu_uploaded.rtu_sequence     := l_seq;
          rec_rtu_uploaded.rtu_leg_code     := l_lc;
          rec_rtu_uploaded.rtu_bg           := l_bg;
          rec_rtu_uploaded.rtu_esd          := l_esd;
          rec_rtu_uploaded.rtu_eed          := l_eed;
          rec_rtu_uploaded.rtu_ovn          := l_ovn;
          rec_rtu_uploaded.rtu_mode         := l_mode;
        else
          --
          -- Row already exists and no columns have changed, so set_end_date
          -- does not need to be called. Set a flag to indicate this.
          --
          l_call_rtu_set_end_date := false;
        end if;
      end if;
      --
      close g_row_exists;
    END IF; -- does row already exist for g_row_exists
  end if; -- what mode in
  --
ELSE -- p_rtu_id is same as g_old_rtu_id so same dt row
--
-- update the g_rtu_to_be_uploaded_eed value
--
  g_rtu_to_be_uploaded_eed := p_effective_end_date;
  --
  -- get row which should still be in uploaded_rec and compare with row
  -- being uploaded
  --
  if rec_rtu_uploaded.rtu_parent_rt_id <> l_par_rt_id
  or rec_rtu_uploaded.rtu_child_rt_id  <>l_ch_rt_id
  or rec_rtu_uploaded.rtu_esd <> p_effective_start_date
  or rec_rtu_uploaded.rtu_eed <> p_effective_end_date then
  --
    update_row;
  end if;
  --
END IF; -- p_rtu_id same as g_old_rtu_id
else -- p_eof_number = 2
--
-- This indicates the final ldt row has been uploaded, just need to check
-- to see if the previous uploaded record's effective end date was eot.
-- If not update the row to whatever the end date should be.
--
  if g_rtu_to_be_uploaded_eed <> hr_api.g_eot then
    set_end_date;
  end if;
end if;
--
END up_run_type_usage;
-----------------------------------------------------------------------------
-- PROCEDURE translate_row
-----------------------------------------------------------------------------
PROCEDURE translate_row(p_base_rt_name  varchar2
                       ,p_rt_leg_code   varchar2
                       ,p_rt_bg         varchar2
                       ,p_rt_name_tl    varchar2
                       ,p_shortname_tl  varchar2
                       )
is
--
cursor get_business_group_id
is
select business_group_id
from   per_business_groups
where upper(name) = p_rt_bg;
--
cursor get_run_type_id(p_bg_id number)
is
select run_type_id
from   pay_run_types_f
where  run_type_name = p_base_rt_name
and    nvl(business_group_id, -1) = nvl(p_bg_id, -1)
and    nvl(legislation_code, 'CORE') = nvl(p_rt_leg_code, 'CORE');
--
l_bg_id number;
l_rt_id number;
--
BEGIN
if p_rt_bg is not null then
  open  get_business_group_id;
  fetch get_business_group_id into l_bg_id;
  close get_business_group_id;
end if;
--
open  get_run_type_id(l_bg_id);
fetch get_run_type_id into l_rt_id;
close get_run_type_id;
hr_utility.trace('rt id is: '||to_char(l_rt_id));
--
  pay_rtt_upd.upd_tl(p_language_code => userenv('LANG')
                    ,p_run_type_id   => l_rt_id
                    ,p_run_type_name => p_rt_name_tl
                    ,p_shortname     => p_shortname_tl
                    );
END translate_row;
-----------------------------------------------------------------------------
 /* Name    : up_run_type_org_method
  Purpose   : Uploads the Organisation Payment Method for Run Type.
  Arguments :
  Notes     :
 */
   procedure up_run_type_org_method (
                           p_rt_opm_id            number,
                           p_rt_name              varchar2,
                           p_opm_name             varchar2,
                           p_effective_start_date date,
                           p_effective_end_date   date,
                           p_priority             number,
                           p_percentage           number,
                           p_amount               number,
                           p_business_group       varchar2,
                           p_rt_bg                varchar2,
                           p_rt_lc                varchar2,
                           p_eof_number           number
                         )
   is
   --
   l_bg_id       number;
   l_lc          varchar2(30);
   l_rt_id       number;
   l_opm_id      number;
   --
   l_rom_id      number;
   l_ovn         number;
   l_esd         date;
   l_eed         date;
   l_out_rom_id  number;
   l_out_ovn     number;
   l_out_esd     date;
   l_out_eed     date;
   --
   l_error       EXCEPTION;
   --
   cursor c_row_exists is
     select run_type_org_method_id
     ,      object_version_number
     ,      effective_start_date
     ,      effective_end_date
     from   pay_run_type_org_methods_f
     where  run_type_id = l_rt_id
     and    org_payment_method_id = l_opm_id
     and    business_group_id = l_bg_id;
   --
   procedure zap_insert_rom is
   --
   begin
   --
     hr_startup_data_api_support.enable_startup_mode('USER');
     --
     pay_run_type_org_method_api.delete_run_type_org_method(
       p_effective_date         => p_effective_start_date
      ,p_datetrack_delete_mode  => 'ZAP'
      ,p_run_type_org_method_id => l_rom_id
      ,p_object_version_number  => l_ovn
      ,p_effective_start_date   => l_esd
      ,p_effective_end_date     => l_eed);
     --
     hr_startup_data_api_support.enable_startup_mode('USER');
     --
     pay_run_type_org_method_api.create_run_type_org_method(
       p_effective_date         => p_effective_start_date
      ,p_run_type_id            => l_rt_id
      ,p_org_payment_method_id  => l_opm_id
      ,p_priority               => p_priority
      ,p_percentage             => p_percentage
      ,p_amount                 => p_amount
      ,p_business_group_id      => l_bg_id
      ,p_run_type_org_method_id => l_out_rom_id
      ,p_object_version_number  => l_out_ovn
      ,p_effective_start_date   => l_out_esd
      ,p_effective_end_date     => l_out_eed);
   --
   end;
   --
   procedure insert_rom is
   --
   begin
   --
     hr_startup_data_api_support.enable_startup_mode('USER');
     --
     pay_run_type_org_method_api.create_run_type_org_method(
       p_effective_date         => p_effective_start_date
      ,p_run_type_id            => l_rt_id
      ,p_org_payment_method_id  => l_opm_id
      ,p_priority               => p_priority
      ,p_percentage             => p_percentage
      ,p_amount                 => p_amount
      ,p_business_group_id      => l_bg_id
      ,p_run_type_org_method_id => l_out_rom_id
      ,p_object_version_number  => l_out_ovn
      ,p_effective_start_date   => l_out_esd
      ,p_effective_end_date     => l_out_eed);
   --
   end;
   --
   procedure update_rom is
   --
   begin
   --
     hr_startup_data_api_support.enable_startup_mode('USER');
     --
     pay_run_type_org_method_api.update_run_type_org_method(
       p_effective_date          => p_effective_start_date
      ,p_datetrack_update_mode   => 'UPDATE'
      ,p_run_type_org_method_id  => g_rom_rec.new_rom_id
      ,p_object_version_number   => g_rom_rec.ovn
      ,p_priority                => p_priority
      ,p_percentage              => p_percentage
      ,p_amount                  => p_amount
      ,p_business_group_id       => l_bg_id
      ,p_effective_start_date    => l_out_esd
      ,p_effective_end_date      => l_out_eed);
   --
   end;
   --
   procedure end_date_rom is
   --
   begin
   --
     hr_startup_data_api_support.enable_startup_mode('USER');
     --
     pay_run_type_org_method_api.delete_run_type_org_method(
       p_effective_date         => g_rom_rec.old_eed
      ,p_datetrack_delete_mode  => 'DELETE'
      ,p_run_type_org_method_id => g_rom_rec.new_rom_id
      ,p_object_version_number  => g_rom_rec.ovn
      ,p_effective_start_date   => g_rom_rec.new_esd
      ,p_effective_end_date     => g_rom_rec.new_eed);
   --
   end;
   --
   Begin  -- <Main Begin>
   --
   if p_eof_number = 1 then  -- if this is not the last row to be uploaded
   --
     hr_utility.set_location('pay_iterate.up_run_type_org_method',10);
     --
     -- get the business group id
     --
     select business_group_id
     ,      legislation_code
     into   l_bg_id
     ,      l_lc
     from   per_business_groups
     where  UPPER(name) = p_business_group;
     --
     hr_utility.set_location('pay_iterate.up_run_type_org_method',20);
     --
     -- Get the run type id
     --
     select prt.run_type_id
     into   l_rt_id
     from   pay_run_types_f prt
     where  UPPER(prt.run_type_name) = p_rt_name
     and    p_effective_start_date between prt.effective_start_date
                                   and     prt.effective_end_date
     and    ((p_rt_bg is not null
     and    prt.business_group_id = l_bg_id)
     or     (p_rt_lc is not null
     and    prt.legislation_code = p_rt_lc)
     or     (p_rt_bg is null
     and    p_rt_lc is null
     and    prt.business_group_id is null
     and    prt.legislation_code is null));
     --
     hr_utility.set_location('pay_iterate.up_run_type_org_method',30);
     --
     -- get the org payment method id
     --
     select popm.org_payment_method_id
     into   l_opm_id
     from   pay_org_payment_methods_f popm
     where  UPPER(popm.org_payment_method_name) = p_opm_name
     and    p_effective_start_date between popm.effective_start_date
                                   and     popm.effective_end_date
     and    popm.business_group_id = l_bg_id;
     --
     hr_utility.set_location('pay_iterate.up_run_type_org_method',40);
     --
     open c_row_exists;
     fetch c_row_exists into l_rom_id, l_ovn, l_esd, l_eed;
     --
     if c_row_exists%found then
     --
       if (l_rom_id <> g_rom_rec.new_rom_id) then
         zap_insert_rom;
       elsif (p_rt_opm_id = g_rom_rec.old_rom_id) then
         update_rom;
       else
         raise l_error;
       end if;
     --
     else
       insert_rom;
     end if;
     --
     close c_row_exists;
     --
     if ((p_rt_opm_id <> g_rom_rec.old_rom_id)
     and (g_rom_rec.old_eed <> hr_api.g_eot)) then
       end_date_rom;
     end if;
     --
     g_rom_rec.old_rom_id := p_rt_opm_id;
     g_rom_rec.new_rom_id := l_out_rom_id;
     g_rom_rec.ovn        := l_out_ovn;
     g_rom_rec.old_esd    := p_effective_start_date;
     g_rom_rec.new_esd    := l_out_esd;
     g_rom_rec.old_eed    := p_effective_end_date;
     g_rom_rec.new_eed    := l_out_eed;
     --
     hr_utility.set_location('pay_iterate.up_run_type_org_method',70);
   --
   else
     if g_rom_rec.old_eed <> hr_api.g_eot then
       end_date_rom;
     end if;
   end if;
   --
   EXCEPTION
   --
   WHEN l_error THEN
     hr_utility.set_message(801, 'HR_33700_LEG_USER_ROW_EXISTS');
     hr_utility.raise_error;
   --
   end up_run_type_org_method;
--
 /* Name    : up_element_type_usage
  Purpose   : Uploads the Element Type Usage.
  Arguments :
  Notes     :
 */
   procedure up_element_type_usage (
                           p_etu_id               number,
                           p_rt_name              varchar2,
                           p_element_name         varchar2,
                           p_effective_start_date date,
                           p_effective_end_date   date,
                           p_business_group       varchar2,
                           p_legislative_code     varchar2,
                           p_rt_bg_name           varchar2,
                           p_rt_leg_code          varchar2,
                           p_et_bg_name           varchar2,
                           p_et_leg_code          varchar2,
			   p_inclusion_flag	  varchar2,
			   p_usage_type		  varchar2,
                           p_eof_number           number
                                   ) is
   --
   l_mode       varchar2(30) := 'USER';
   --
   l_etu_id     number;
   l_ovn        number;
   l_lc         varchar2(30);
   l_bg_id      number;
   l_esd        date;
   l_eed        date;
   --
   l_in_rt_id   number;
   l_in_et_id   number;
   l_in_bg_id   number;
   l_in_lc      varchar2(30);
   --
   l_out_etu_id number;
   l_out_ovn    number;
   l_out_esd    date;
   l_out_eed    date;
   --
   cursor c_row_exists_user is
     select element_type_usage_id
     ,      object_version_number
     ,      legislation_code
     ,      business_group_id
     ,      effective_start_date
     ,      effective_end_date
     from   pay_element_type_usages_f
     where  run_type_id = l_in_rt_id
     and    element_type_id = l_in_et_id
     and    ((business_group_id = l_in_bg_id)
     or     (legislation_code = l_in_lc)
     or     (business_group_id is null
     and    legislation_code is null));
   --
   cursor c_row_exists_startup is
     select element_type_usage_id
     ,      object_version_number
     ,      legislation_code
     ,      business_group_id
     ,      effective_start_date
     ,      effective_end_date
     from   pay_element_type_usages_f
     where  run_type_id = l_in_rt_id
     and    element_type_id = l_in_et_id
     and    ((business_group_id in (select business_group_id
                                   from per_business_groups
                                   where legislation_code = p_legislative_code))
     or     (legislation_code = p_legislative_code)
     or     (business_group_id is null
     and    legislation_code is null));
     --
     cursor c_row_exists_generic is
     select element_type_usage_id
     ,      object_version_number
     ,      legislation_code
     ,      business_group_id
     ,      effective_start_date
     ,      effective_end_date
     from   pay_element_type_usages_f
     where  run_type_id = l_in_rt_id
     and    element_type_id = l_in_et_id;
   --
   procedure insert_etu is
   --
   begin
   --
     hr_startup_data_api_support.enable_startup_mode(l_mode);
     --
     if l_mode <> 'USER' then
       hr_startup_data_api_support.delete_owner_definitions;
       hr_startup_data_api_support.create_owner_definition('PAY');
     end if;
     --
     pay_element_type_usage_api.create_element_type_usage(
       p_effective_date        => p_effective_start_date
      ,p_run_type_id           => l_in_rt_id
      ,p_element_type_id       => l_in_et_id
      ,p_inclusion_flag       => p_inclusion_flag
      ,p_business_group_id     => l_in_bg_id
      ,p_legislation_code      => p_legislative_code
      ,p_usage_type	       => p_usage_type
      ,p_element_type_usage_id => l_out_etu_id
      ,p_object_version_number => l_out_ovn
      ,p_effective_start_date  => l_out_esd
      ,p_effective_end_date    => l_out_eed);
   --
   end;
   --
   procedure end_date_etu is
   --
   begin
   --
     hr_startup_data_api_support.enable_startup_mode(g_etu_rec.l_mode);
     --
     if l_mode <> 'USER' then
       hr_startup_data_api_support.delete_owner_definitions;
       hr_startup_data_api_support.create_owner_definition('PAY');
     end if;
     --
     pay_element_type_usage_api.delete_element_type_usage(
       p_effective_date        => g_etu_rec.old_eed
      ,p_datetrack_delete_mode => 'DELETE'
      ,p_element_type_usage_id => g_etu_rec.new_etu_id
      ,p_object_version_number => g_etu_rec.ovn
      ,p_effective_start_date  => g_etu_rec.new_esd
      ,p_effective_end_date    => g_etu_rec.new_eed);
   --
   end;
   --
   procedure zap_insert_etu is
   --
   begin
   --
     hr_startup_data_api_support.enable_startup_mode(l_mode);
     --
     if l_mode <> 'USER' then
       hr_startup_data_api_support.delete_owner_definitions;
       hr_startup_data_api_support.create_owner_definition('PAY');
     end if;
     --
     pay_element_type_usage_api.delete_element_type_usage(
       p_effective_date        => p_effective_start_date
      ,p_datetrack_delete_mode => 'ZAP'
      ,p_element_type_usage_id => l_etu_id
      ,p_object_version_number => l_ovn
      ,p_effective_start_date  => l_esd
      ,p_effective_end_date    => l_eed);
     --
     hr_startup_data_api_support.enable_startup_mode(l_mode);
     --
     if l_mode <> 'USER' then
       hr_startup_data_api_support.delete_owner_definitions;
       hr_startup_data_api_support.create_owner_definition('PAY');
     end if;
     --
     pay_element_type_usage_api.create_element_type_usage(
       p_effective_date        => p_effective_start_date
      ,p_run_type_id           => l_in_rt_id
      ,p_element_type_id       => l_in_et_id
      ,p_inclusion_flag        => p_inclusion_flag
      ,p_business_group_id     => l_in_bg_id
      ,p_legislation_code      => p_legislative_code
      ,p_usage_type	       => p_usage_type
      ,p_element_type_usage_id => l_out_etu_id
      ,p_object_version_number => l_out_ovn
      ,p_effective_start_date  => l_out_esd
      ,p_effective_end_date    => l_out_eed);
   --
   end;
   --
   procedure update_etu is
   --
   begin
   --
    hr_startup_data_api_support.enable_startup_mode(l_mode);
     --
     if l_mode <> 'USER' then
       hr_startup_data_api_support.delete_owner_definitions;
       hr_startup_data_api_support.create_owner_definition('PAY');
     end if;
     --
     pay_element_type_usage_api.update_element_type_usage(
       p_effective_date        => p_effective_start_date
      ,p_datetrack_update_mode => 'UPDATE'
      ,p_inclusion_flag	       => p_inclusion_flag
      ,p_element_type_usage_id => l_etu_id
      ,p_object_version_number => l_ovn
      ,p_business_group_id     => l_in_bg_id
      ,p_legislation_code      => p_legislative_code
      ,p_usage_type	       => p_usage_type
      ,p_effective_start_date  => l_out_esd
      ,p_effective_end_date    => l_out_eed);
   --
   end;
   --
   procedure exists_error is
   --
   begin
   --
     if l_mode = 'STARTUP' then
     --
       hr_utility.set_message(801, 'HR_33699_USER_ROW_EXISTS');
       hr_utility.raise_error;
     --
     else
     --
       hr_utility.set_message(801, 'HR_33700_LEG_USER_ROW_EXISTS');
       hr_utility.raise_error;
     --
     end if;
   --
   end exists_error;
   --
   Begin  -- <Main Begin>
   --
   if p_eof_number = 1 then
     --
     -- Set the mode in which the api will be called.
     --
     if p_business_group IS NOT NULL then
       l_mode := 'USER';
     elsif p_legislative_code IS NOT NULL then
       l_mode := 'STARTUP';
     else
       l_mode := 'GENERIC';
     end if;
     --
     -- Get the business group id
     --
     if p_business_group is not null then
     --
       select business_group_id
       ,      legislation_code
       into   l_in_bg_id
       ,      l_in_lc
       from   per_business_groups
       where  UPPER(name) = p_business_group;
     --
     end if;
     --
     -- Get the run_type_id
     --
     select prt.run_type_id
     into   l_in_rt_id
     from   pay_run_types_f prt
     where  UPPER(prt.run_type_name) = p_rt_name
     and    p_effective_start_date between prt.effective_start_date
                                   and     prt.effective_end_date
     and    ((p_rt_bg_name is not null
     and    prt.business_group_id = l_in_bg_id)
     or     (p_rt_leg_code is not null
     and    prt.legislation_code = p_rt_leg_code)
     or     (p_rt_bg_name is null
     and    p_rt_leg_code is null
     and    prt.business_group_id is null
     and    prt.legislation_code is null));
     --
     -- Get the element_type_id
     --
     select pet.element_type_id
     into   l_in_et_id
     from   pay_element_types_f pet
     where  UPPER(pet.element_name) = p_element_name
     and    p_effective_start_date between pet.effective_start_date
                                   and     pet.effective_end_date
     and    ((p_et_bg_name is not null
     and    pet.business_group_id = l_in_bg_id)
     or     (p_et_leg_code is not null
     and    pet.legislation_code = p_et_leg_code)
     or     (p_et_bg_name is null
     and    p_et_leg_code is null
     and    pet.business_group_id is null
     and    pet.legislation_code is null));
     --
     -- Begin upload of element type usages
     --
     if l_mode = 'USER' then
     --
       open c_row_exists_user;
       fetch c_row_exists_user into l_etu_id, l_ovn, l_lc, l_bg_id, l_esd, l_eed;
       --
       if c_row_exists_user%found then
       --
         if ((l_etu_id = g_etu_rec.new_etu_id)
         and (p_etu_id = g_etu_rec.old_etu_id)) then
           update_etu;
         elsif ((l_bg_id is not null) and (l_in_bg_id = l_bg_id)) then
           zap_insert_etu;
         else
           exists_error;
         end if;
       --
       else
         insert_etu;
       end if;
       --
       close c_row_exists_user;
     --
     elsif l_mode = 'STARTUP' then
     --
       open c_row_exists_startup;
       fetch c_row_exists_startup into l_etu_id, l_ovn, l_lc, l_bg_id, l_esd, l_eed;
       --
       if c_row_exists_startup%found then
       --
         if ((l_etu_id = g_etu_rec.new_etu_id)
         and (p_etu_id = g_etu_rec.old_etu_id)) then
           update_etu;
         elsif ((l_lc is not null) and (l_lc = p_legislative_code)) then
           zap_insert_etu;
         else
           exists_error;
         end if;
       --
       else
         insert_etu;
       end if;
       --
       close c_row_exists_startup;
     --
     else
     --
       open c_row_exists_generic;
       fetch c_row_exists_generic into l_etu_id, l_ovn, l_lc, l_bg_id, l_esd, l_eed;
       --
       if c_row_exists_generic%found then
       --
         if ((l_etu_id = g_etu_rec.new_etu_id)
         and (p_etu_id = g_etu_rec.old_etu_id)) then
           update_etu;
         elsif ((l_lc is null) and (l_bg_id is null)) then
           zap_insert_etu;
         else
           exists_error;
         end if;
       --
       else
         insert_etu;
       end if;
       --
       close c_row_exists_generic;
     --
     end if;
     --
     if ((p_etu_id <> g_etu_rec.old_etu_id)
     and (g_etu_rec.old_eed <> hr_api.g_eot)) then
       end_date_etu;
     end if;
     --
     g_etu_rec.old_etu_id := p_etu_id;
     g_etu_rec.new_etu_id := l_out_etu_id;
     g_etu_rec.ovn        := l_out_ovn;
     g_etu_rec.old_esd    := p_effective_start_date;
     g_etu_rec.new_esd    := l_out_esd;
     g_etu_rec.old_eed    := p_effective_end_date;
     g_etu_rec.new_eed    := l_out_eed;
     g_etu_rec.l_mode     := l_mode;
   --
   else
   --
     if g_etu_rec.old_eed <> hr_api.g_eot then
       end_date_etu;
     end if;
   --
   end if;
   --
   end up_element_type_usage;
-------------------------------------------------------------------------
-- Function order_cumulative
-- Description: This is called by the download section of pycoiter.lct
--              when downloading entity PAY_RUN_TYPE. Cumulative run types
--              can now have child run types which are themselves cumulative.
--              The child run types need to be downloaded before the parent
--              run types to enable the upload to work correctly. This fuction
--              determines which run types with run_method of 'C' are also child
--              run types, and assigns an order value of 'D'. The download
--              sql, in the lct file, is ordered alphabetically in decending
--              order, so 'D' will be downloaded before 'C', and hence uploaded
--              before 'C'.
-------------------------------------------------------------------------
function order_cumulative (p_run_type_name     in varchar2
                          ,p_business_grp_name in varchar2
                          ,p_legislation_code  in varchar2)
return VARCHAR2 is
--
cursor get_bg_id (p_bg_name varchar2)
is
select pbg.business_group_id
from   per_business_groups pbg
where  pbg.name = p_bg_name;
--
cursor csr_child_cumulative(p_leg_code varchar2
                           ,p_bg       number
                           ,p_rt_name  varchar2)
is
select prt.run_type_name
,      prt.run_method
from   pay_run_types_f prt
,      pay_run_type_usages_f rtu
where  prt.run_method = 'C'
and    nvl(prt.legislation_code, 'NULL') = nvl(p_leg_code, 'NULL')
and    nvl(prt.business_group_id, -1) = nvl(p_bg, -1)
and    prt.run_type_name = p_rt_name
and    prt.run_type_id = rtu.child_run_type_id;
--
l_bg         per_business_groups.business_group_id%type;
l_rt_name    pay_run_types_f.run_type_name%type;
l_rt_method  pay_run_types_f.run_method%type;
l_meth_order varchar2(2);
--
begin
hr_utility.set_location('Entering: pay_iterate.order_cumulative',5);
if p_business_grp_name is not null then
  open  get_bg_id(p_business_grp_name);
  fetch get_bg_id into l_bg;
  close get_bg_id;
else
  l_bg := '';
end if;
--
open  csr_child_cumulative(p_legislation_code, l_bg, p_run_type_name);
fetch csr_child_cumulative into l_rt_name, l_rt_method;
if csr_child_cumulative%notfound then
  hr_utility.set_location('pay_iterate.order_cumulative',10);
  close csr_child_cumulative;
  l_meth_order := 'C';
else
  hr_utility.set_location('pay_iterate.order_cumulative',15);
  close csr_child_cumulative;
  l_meth_order := 'D';
end if;
--
return l_meth_order;
end order_cumulative;
--
begin
  /* initialise. */
--
  g_entry_list.sz := 0;
  g_asg_id := -1;
  g_asg_act_id := -1;
--
end pay_iterate;

/
