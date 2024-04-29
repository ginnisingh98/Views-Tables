--------------------------------------------------------
--  DDL for Package Body PEFRUSDT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PEFRUSDT" as
/* $Header: pefrusdt.pkb 120.1 2005/06/15 01:55:42 sbairagi noship $ */
function get_table_value (p_bus_group_id      in number,
                          p_table_name        in varchar2,
                          p_col_name          in varchar2,
                          p_row_value         in varchar2,
                          p_effective_date    in date  default null)
         return varchar2 is
l_effective_date    date;
l_range_or_match    pay_user_tables.range_or_match%type;
l_value             pay_user_column_instances_f.value%type;
cached       boolean  := FALSE;
g_leg_code   varchar2(2);
begin
    --
    -- Use either the supplied date, or the date from fnd_sessions
    --
    if (p_effective_date is null) then
        begin
            select effective_date
            into   l_effective_date
            from   fnd_sessions
            where  session_id = userenv('sessionid');
        end;
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
    select range_or_match
    into   l_range_or_match
    from   pay_user_tables
    where  upper(user_table_name) = upper(p_table_name)
    and    nvl (business_group_id,
                p_bus_group_id)   = p_bus_group_id;
    --
    if (l_range_or_match = 'M') then       -- matched
      begin
        select  CINST.value
        into    l_value
        from    pay_user_column_instances_f        CINST
        ,       pay_user_columns                   C
        ,       pay_user_rows_f                    R
        ,       pay_user_tables                    TAB
        where   upper(TAB.user_table_name)       = upper(p_table_name)
        and     nvl (TAB.business_group_id,
                     p_bus_group_id)             = p_bus_group_id
        and     nvl (TAB.legislation_code,
                     g_leg_code)                 = g_leg_code
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
        return l_value;
      exception
        when others then return null;
      end;
    else                                   -- range
      begin
        select  CINST.value
        into    l_value
        from    pay_user_column_instances_f        CINST
        ,       pay_user_columns                   C
        ,       pay_user_rows_f                    R
        ,       pay_user_tables                    TAB
        where   upper(TAB.user_table_name)       = upper(p_table_name)
        and     nvl (TAB.business_group_id,
                     p_bus_group_id)             = p_bus_group_id
        and     nvl (TAB.legislation_code,
                     g_leg_code)                 = g_leg_code
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
        and     to_number (p_row_value)
        between to_number (R.row_low_range_or_name)
        and     to_number (R.row_high_range)
        and     TAB.user_key_units               = 'N'
        and     CINST.user_row_id                = R.user_row_id
        and     l_effective_date           between CINST.effective_start_date
        and     CINST.effective_end_date
        and     nvl (CINST.business_group_id,
                     p_bus_group_id)             = p_bus_group_id
        and     nvl (CINST.legislation_code,
                     g_leg_code)                 = g_leg_code;
        --
        return l_value;
      exception
        when others then return null;
      end;
    end if;

end get_table_value;
--
END pefrusdt;

/
