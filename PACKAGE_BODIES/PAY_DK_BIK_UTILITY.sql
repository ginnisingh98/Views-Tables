--------------------------------------------------------
--  DDL for Package Body PAY_DK_BIK_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_DK_BIK_UTILITY" as
/* $Header: pydkbiku.pkb 120.1.12010000.2 2009/11/05 06:55:48 vijranga ship $ */
--
g_leg_code   varchar2(2);
cached       boolean  := FALSE;
g_effective_date    date := null;
--
plsql_value_error exception;
pragma exception_init(plsql_value_error, -6502);
--
--
-- This procedure sets the g_effective_date cache
--

function get_table_value (p_bus_group_id      in number,
                          p_table_name        in varchar2,
                          p_col_name          in varchar2,
                          p_row_value         in varchar2,
                          p_effective_date    in date  default null)
         return varchar2 is
l_effective_date    date;
l_range_or_match    pay_user_tables.range_or_match%type;
l_table_id          pay_user_tables.user_table_id%type;
l_value             pay_user_column_instances_f.value%type;
l_value_num         NUMBER;

begin
    --
    -- Use either the supplied date, or the date from fnd_sessions
    --
    if (p_effective_date is null) then
       if (g_effective_date is null) then
          begin
             select effective_date
             into   l_effective_date
             from   fnd_sessions
             where  session_id = userenv('sessionid');
          end;
       else
          l_effective_date := g_effective_date;
       end if;
    else
        l_effective_date := p_effective_date;
    end if;
    --
    -- get the legislation code:
    --
    begin
        if cached = FALSE THEN
          select legislation_code
          into   g_leg_code
          from   per_business_groups
          where  business_group_id = p_bus_group_id;
          cached := TRUE;
        end if;
    end;
    --
    -- get the type of query to be performed, either range or match
    --
    select range_or_match, user_table_id
    into   l_range_or_match, l_table_id
    from   pay_user_tables
    where  upper(user_table_name) = upper(p_table_name)
    and    nvl (business_group_id,
                p_bus_group_id)   = p_bus_group_id
    and    nvl(legislation_code, g_leg_code) = g_leg_code;
    --
    if (l_range_or_match = 'M') then       -- matched
      begin
        select  CINST.value
        into    l_value
        from    pay_user_column_instances_f        CINST
        ,       pay_user_columns                   C
        ,       pay_user_rows_f                    R
        ,       pay_user_tables                    TAB
        where   TAB.user_table_id                = l_table_id
        and     C.user_table_id                  = TAB.user_table_id
        and     nvl (C.business_group_id,
                     p_bus_group_id)            = p_bus_group_id
        and     nvl (C.legislation_code,
                     g_leg_code)                 = g_leg_code
        and     upper (C.user_column_name)       = upper (p_col_name)
        and     CINST.user_column_id             = C.user_column_id
        and     R.user_table_id                  = TAB.user_table_id
        and     l_effective_date           between R.effective_start_date
        and     R.effective_end_date
        and     nvl (R.business_group_id,
                     p_bus_group_id)             = p_bus_group_id
        and     nvl (R.legislation_code,
                     g_leg_code)                 = g_leg_code
        and     decode
                (TAB.user_key_units,
                 'D', to_char(fnd_date.canonical_to_date(p_row_value)),
                 'N', to_char(fnd_number.canonical_to_number(p_row_value)),
                 'T', upper (p_row_value),
                 null) =
                decode
                (TAB.user_key_units,
                 'D', to_char(fnd_date.canonical_to_date(R.row_low_range_or_name)),
                 'N', to_char(fnd_number.canonical_to_number(R.row_low_range_or_name)),
                 'T', upper (R.row_low_range_or_name),
                 null)
        and     CINST.user_row_id                = R.user_row_id
        and     l_effective_date           between CINST.effective_start_date
        and     CINST.effective_end_date
        and     nvl (CINST.business_group_id,
                     p_bus_group_id)             = p_bus_group_id
        and     nvl (CINST.legislation_code,
                     g_leg_code)                 = g_leg_code;
        --
      exception
        when plsql_value_error then
          select  CINST.value
          into    l_value
          from    pay_user_column_instances_f        CINST
          ,       pay_user_columns                   C
          ,       pay_user_rows_f                    R
          ,       pay_user_tables                    TAB
          where   TAB.user_table_id                = l_table_id
          and     C.user_table_id                  = TAB.user_table_id
          and     nvl (C.business_group_id,
                       p_bus_group_id)            = p_bus_group_id
          and     nvl (C.legislation_code,
                       g_leg_code)                 = g_leg_code
          and     upper (C.user_column_name)       = upper (p_col_name)
          and     CINST.user_column_id             = C.user_column_id
          and     R.user_table_id                  = TAB.user_table_id
          and     l_effective_date           between R.effective_start_date
          and     R.effective_end_date
          and     nvl (R.business_group_id,
                       p_bus_group_id)             = p_bus_group_id
          and     nvl (R.legislation_code,
                       g_leg_code)                 = g_leg_code
          and     decode
                  (TAB.user_key_units,
                   'D', to_char(fnd_date.canonical_to_date(p_row_value)),
                   'N', p_row_value,
                   'T', upper (p_row_value),
                   null) =
                  decode
                  (TAB.user_key_units,
                   'D', to_char(fnd_date.canonical_to_date(R.row_low_range_or_name)),
                   'N', R.row_low_range_or_name,
                   'T', upper (R.row_low_range_or_name),
                   null)
          and     CINST.user_row_id                = R.user_row_id
          and     l_effective_date           between CINST.effective_start_date
          and     CINST.effective_end_date
          and     nvl (CINST.business_group_id,
                       p_bus_group_id)             = p_bus_group_id
          and     nvl (CINST.legislation_code,
                       g_leg_code)                 = g_leg_code;
          --
        when others then
          raise;
      end;
      --
      return l_value;
      --
    else                                   -- range
      begin
        select  CINST.value
        into    l_value
        from    pay_user_column_instances_f        CINST
        ,       pay_user_columns                   C
        ,       pay_user_rows_f                    R
        ,       pay_user_tables                    TAB
        where   TAB.user_table_id                = l_table_id
        and     C.user_table_id                  = TAB.user_table_id
        and     nvl (C.business_group_id,
                     p_bus_group_id)             = p_bus_group_id
        and     nvl (C.legislation_code,
                     g_leg_code)                 = g_leg_code
        and     upper (C.user_column_name)       = upper (p_col_name)
        and     CINST.user_column_id             = C.user_column_id
        and     R.user_table_id                  = TAB.user_table_id
        and     l_effective_date           between R.effective_start_date
        and     R.effective_end_date
        and     nvl (R.business_group_id,
                     p_bus_group_id)             = p_bus_group_id
        and     nvl (R.legislation_code,
                     g_leg_code)                 = g_leg_code
        and     fnd_number.canonical_to_number (p_row_value)
        between fnd_number.canonical_to_number (R.row_low_range_or_name)
        and     fnd_number.canonical_to_number (R.row_high_range)
        and     TAB.user_key_units               = 'N'
        and     CINST.user_row_id                = R.user_row_id
        and     l_effective_date           between CINST.effective_start_date
        and     CINST.effective_end_date
        and     nvl (CINST.business_group_id,
                     p_bus_group_id)             = p_bus_group_id
        and     nvl (CINST.legislation_code,
                     g_leg_code)                 = g_leg_code;

        l_value_num := fnd_number.canonical_to_number(l_value);


        if fnd_number.canonical_to_number(l_value) <= 0 then
           l_value := 'N';
        end if;



	exception
        when NO_DATA_FOUND then
         l_value := 'NE';

       when others then
          l_value := 'ERR';
	end;
        --
        return l_value;

    end if;


end get_table_value;


FUNCTION get_vehicle_info
( p_assignment_id per_all_assignments_f.assignment_id%TYPE,
  p_business_group_id    in     number,
  p_date_earned DATE,
  p_vehicle_allot_id pqp_vehicle_allocations_f.VEHICLE_ALLOCATION_ID%TYPE,
  p_lic_reg_date OUT NOCOPY pqp_vehicle_repository_f.INITIAL_REGISTRATION%TYPE,
  p_buying_date OUT NOCOPY pqp_vehicle_repository_f.LAST_REGISTRATION_RENEW_DATE%TYPE,
  p_buying_price   OUT NOCOPY pqp_vehicle_repository_f.LIST_PRICE%TYPE,
  p_green_environment_fee OUT NOCOPY pqp_vehicle_repository_f.vre_information2%TYPE -- 9079593 fix
)
return NUMBER
IS
l_value NUMBER;
BEGIN
    BEGIN

    select pvr.INITIAL_REGISTRATION
          ,pvr.LAST_REGISTRATION_RENEW_DATE
          ,pvr.LIST_PRICE
	      ,pvr.vre_information2 -- 9079593 fix
    INTO   p_lic_reg_date
          ,p_buying_date
          ,p_buying_price
	      ,p_green_environment_fee -- 9079593 fix
    from   pqp_vehicle_allocations_f  pva
          ,pqp_vehicle_repository_f   pvr
    where  pva.assignment_id = p_assignment_id
    and    pvr.vehicle_repository_id = pva.vehicle_repository_id
    and    pva.business_group_id         =  p_business_group_id
    and    pva.vehicle_allocation_id     =  p_vehicle_allot_id
    and    p_date_earned between pva.EFFECTIVE_START_DATE and pva.EFFECTIVE_END_DATE
    and    p_date_earned between pvr.EFFECTIVE_START_DATE and pvr.EFFECTIVE_END_DATE;

    l_value := 1;

    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
        l_value := 0;

    END;

RETURN l_value;
END get_vehicle_info;

END pay_dk_bik_utility;

/
