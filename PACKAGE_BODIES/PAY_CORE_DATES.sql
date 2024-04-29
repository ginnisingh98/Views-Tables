--------------------------------------------------------
--  DDL for Package Body PAY_CORE_DATES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CORE_DATES" as
/* $Header: pycordat.pkb 120.4 2006/04/25 06:16:25 mkataria noship $ */
--
--
-- Set up the globals
--
g_debug boolean := hr_utility.debug_enabled;
--
procedure get_offset_date(p_period_type    in  varchar2,
                          p_period_units   in  number,
                          p_effective_date in  date,
                          p_offset_date    out nocopy date)
is
begin
--
   /* do we need to alter the date, only if the
      number of offset periods in question is not
      zero
   */
   if (p_period_units = 0) then
--
     p_offset_date := p_effective_date;
--
   else
--
     if (p_period_type = 'YEAR') then
--
        p_offset_date := add_months(p_effective_date, (12 * p_period_units));
--
     elsif (p_period_type = 'QUARTER') then
--
        p_offset_date := add_months(p_effective_date, (3 * p_period_units));
--
     elsif (p_period_type = 'MONTH') then
--
        p_offset_date := add_months(p_effective_date, (1 * p_period_units));
--
     else
--
       p_offset_date := p_effective_date;
--
     end if;
   end if;
--
end get_offset_date;
--
procedure perform_day_adjustment(p_day_adjustment in     varchar2,
                                 p_effective_date in out nocopy date
                                 )
is
l_day_adjustment_value number;
begin
--
if p_day_adjustment = 'NEXT' then
   l_day_adjustment_value := 1;
elsif p_day_adjustment = 'PRIOR' then
   l_day_adjustment_value := -1;
elsif p_day_adjustment = 'CURRENT' then
   l_day_adjustment_value := 0;
else
   begin
     l_day_adjustment_value := to_number(p_day_adjustment);
   exception
     when others then
          hr_utility.set_message(801,'HR_51153_INVAL_NUM_FORMAT');
          hr_utility.raise_error;
   end;
end if;
p_effective_date := p_effective_date + l_day_adjustment_value;

--
end perform_day_adjustment;
--
procedure get_time_definition_date(p_time_def_id     in            number,
                                   p_effective_date  in            date,
                                   p_start_date         out nocopy date,
                                   p_bus_grp         in            number   default null)
is
l_return_date date;
--
l_period_type    pay_time_definitions.period_type%type;
l_period_unit    pay_time_definitions.period_unit%type;
l_day_adjustment pay_time_definitions.day_adjustment%type;
l_period_date    date;
--
begin
   g_debug := hr_utility.debug_enabled;
--
   select period_type,
          nvl(period_unit, 0),
          nvl(day_adjustment,0)
     into l_period_type,
          l_period_unit,
          l_day_adjustment
     from pay_time_definitions
    where time_definition_id = p_time_def_id;
--
--
   get_offset_date(l_period_type,
                   l_period_unit,
                   p_effective_date,
                   l_period_date);
--
   l_return_date := null;
--
   if (l_period_type = 'YEAR') then
--
     l_return_date := trunc(l_period_date, 'Y');
--
   elsif (l_period_type = 'QUARTER') then
--
     l_return_date := trunc(l_period_date, 'Q');
--
   elsif (l_period_type = 'START_OF_TIME') then
--
     l_return_date := to_date('0001/01/01 00:00:00', 'YYYY/MM/DD HH24:MI:SS');
--
   elsif (l_period_type = 'END_OF_TIME') then
--
     l_return_date := to_date('4712/12/31 00:00:00', 'YYYY/MM/DD HH24:MI:SS');
--
   elsif (l_period_type = 'MONTH') then
--
     l_return_date := trunc(l_period_date, 'MM');
--
   elsif (l_period_type = 'RUN') then
--
     l_return_date := l_period_date;
--
   elsif (l_period_type = 'TYEAR') then
--
     l_return_date:= pay_ip_route_support.tax_year(p_bus_grp,
                                   l_period_date);
--
   elsif (l_period_type = 'TQUARTER') then
--
     l_return_date:= pay_ip_route_support.tax_quarter(p_bus_grp,
                                   l_period_date);
--
   elsif (l_period_type = 'FYEAR') then
--
     l_return_date:= pay_ip_route_support.fiscal_year(p_bus_grp,
                                   l_period_date);
--
   elsif (l_period_type = 'FQUARTER') then
--
     l_return_date:= pay_ip_route_support.fiscal_quarter(p_bus_grp,
                                   l_period_date);
--
   elsif (l_period_type = 'DAILY') then
--
     l_return_date := l_period_date;

   end if;
--
   perform_day_adjustment(l_day_adjustment,
                          l_return_date
                         );

   p_start_date := l_return_date;
--
end get_time_definition_date;
--
function get_time_definition_date(p_time_def_id     in            number,
                                  p_effective_date  in            date,
                                  p_bus_grp         in            number   default null)
return date
is
l_start_date date;
begin
--
  get_time_definition_date(p_time_def_id    => p_time_def_id,
                           p_effective_date => p_effective_date,
                           p_start_date     => l_start_date,
                           p_bus_grp        => p_bus_grp);
--
  return l_start_date;
--
end get_time_definition_date;
--
procedure is_date_in_span(p_start_time_def_id in     number,
                          p_end_time_def_id   in     number,
                          p_test_date         in     date,
                          p_effective_date    in     date,
                          p_result               out nocopy boolean,
                          p_bus_grp           in     number default null
                         )
is
l_start_date date;
l_end_date   date;
begin
--
  get_time_definition_date(p_time_def_id    => p_start_time_def_id,
                           p_effective_date => p_effective_date,
                           p_start_date     => l_start_date,
                           p_bus_grp        => p_bus_grp);
--
  get_time_definition_date(p_time_def_id    => p_end_time_def_id,
                           p_effective_date => p_effective_date,
                           p_start_date     => l_end_date,
                           p_bus_grp        => p_bus_grp);
--
  if (p_test_date between l_start_date and l_end_date) then
      p_result := TRUE;
  else
      p_result := FALSE;
  end if;
--
end is_date_in_span;
--
function is_date_in_span(p_start_time_def_id in     number,
                         p_end_time_def_id   in     number,
                         p_test_date         in     date,
                         p_effective_date    in     date,
                         p_bus_grp           in     number default null
                         )
return varchar2
is
l_start_date date;
l_end_date   date;
begin
--
  get_time_definition_date(p_time_def_id    => p_start_time_def_id,
                           p_effective_date => p_effective_date,
                           p_start_date     => l_start_date,
                           p_bus_grp        => p_bus_grp);
--
  get_time_definition_date(p_time_def_id    => p_end_time_def_id,
                           p_effective_date => p_effective_date,
                           p_start_date     => l_end_date,
                           p_bus_grp        => p_bus_grp);
--
  if (p_test_date between l_start_date and l_end_date) then
      return 'Y';
  else
      return 'N';
  end if;
--
end is_date_in_span;
--
end pay_core_dates;

/
