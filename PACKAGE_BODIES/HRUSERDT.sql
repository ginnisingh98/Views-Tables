--------------------------------------------------------
--  DDL for Package Body HRUSERDT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRUSERDT" as
/* $Header: pyuserdt.pkb 120.2.12000000.1 2007/01/18 02:24:42 appldev ship $ */
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
procedure set_g_effective_date(p_effective_date in date)
is
begin
    -- set g_effective_date cache
    g_effective_date := p_effective_date;
end set_g_effective_date;

--
-- This procedure unsets the g_effective_date cache
--
procedure unset_g_effective_date
is
begin
    -- unset g_effective_date cache
    g_effective_date := null;
end unset_g_effective_date;

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
        select  /*+ INDEX(C PAY_USER_COLUMNS_FK1)
                    INDEX(R PAY_USER_ROWS_F_FK1)
                    INDEX(CINST PAY_USER_COLUMN_INSTANCES_N1)
                    ORDERED */
                CINST.value
        into    l_value
        from    pay_user_tables                    TAB
        ,       pay_user_columns                   C
        ,       pay_user_rows_f                    R
        ,       pay_user_column_instances_f        CINST
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
          select  /*+ INDEX(C PAY_USER_COLUMNS_FK1)
                      INDEX(R PAY_USER_ROWS_F_FK1)
                      INDEX(CINST PAY_USER_COLUMN_INSTANCES_N1)
                      ORDERED */
                  CINST.value
          into    l_value
          from    pay_user_tables                    TAB
          ,       pay_user_columns                   C
          ,       pay_user_rows_f                    R
          ,       pay_user_column_instances_f        CINST
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
        select  /*+ INDEX(C PAY_USER_COLUMNS_FK1)
                    INDEX(R PAY_USER_ROWS_F_FK1)
                    INDEX(CINST PAY_USER_COLUMN_INSTANCES_N1)
                    ORDERED */
                CINST.value
        into    l_value
        from    pay_user_tables                    TAB
        ,       pay_user_columns                   C
        ,       pay_user_rows_f                    R
        ,       pay_user_column_instances_f        CINST
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
        --
        return l_value;
      end;
    end if;

end get_table_value;

END hruserdt;

/
