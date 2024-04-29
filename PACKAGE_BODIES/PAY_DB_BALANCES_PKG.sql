--------------------------------------------------------
--  DDL for Package Body PAY_DB_BALANCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_DB_BALANCES_PKG" as
/* $Header: pybaldim.pkb 115.8 2003/05/26 03:44:47 sdhole ship $ */
-- Date          Person        Description.
-- ------------  ------------- --------------------------------------
-- 25-May-03     sdhole        Support new two columns START_DATE_CODE,
--  			       SAVE_RUN_BALANCE_ENABLED to the function
-- 			       create_balance_dimension for 2898483.
-- 10-OCT-2002   nbristow      New attribution on dimenion routes.
-- 07-OCT-2002   nbristow      Support new balance dimension
--                             functionality.
-- 16-JUL-2002   nbristow      Now using SQL%count.
-- 31-AUG-2001   dsaxby        Support new balance dimension columns.
-- 28-FEB-1995   dsaxby        Altered to support 'R' dimension type.
--
--  Building Block for BALANCE DIMENSION
--
function create_balance_dimension
            (p_business_group_id       number   default null,
             p_legislation_code        varchar2 default null,
             p_route_id                number,
             p_database_item_suffix    varchar2,
             p_dimension_name          varchar2,
             p_dimension_type          varchar2 default 'N',
             p_description             varchar2 default null,
             p_feed_checking_type      varchar2 default null,
             p_feed_checking_code      varchar2 default null,
             p_payments_flag           varchar2 default 'N',
             p_expiry_checking_code    varchar2 default null,
             p_expiry_checking_level   varchar2 default null,
             p_dimension_level         varchar2 default null,
             p_period_type             varchar2 default null,
             p_asg_bal_dim             number   default null,
             p_dbi_function            varchar2 default null,
             p_save_run_balance_enabled varchar2 default null,
             p_start_date_code          varchar2 default null)
         return number is
   x number;
begin
   --  check correct use of expiry checking and feed checking attributes
   hr_utility.set_location('pay_db_balances_pkg.create_balance_dimension',10);
   if (p_dimension_type = 'N'
       and (p_feed_checking_code is not null
            or p_feed_checking_type is not null
            or p_expiry_checking_code is not null
            or p_expiry_checking_level is not null))

   or (p_feed_checking_type = 'P' and p_feed_checking_code is null)

   or (p_dimension_type in ('F', 'R')
       and (p_expiry_checking_code is not null
            or p_expiry_checking_level is not null))

   or (p_dimension_type in ('A', 'P')
       and ((p_expiry_checking_code is null and p_expiry_checking_level <> 'N')
            or p_expiry_checking_level is null)) then

         hr_utility.set_message(801, 'HR_BAD_BALDIM_DATA');
         hr_utility.raise_error;
   end if;
--
   --  check the database item suffix: it must only contain valid
   --  characters for a DB Item name
   --   !!!!  hr_checkformat etc.
   --
      If hr_api.not_exists_in_hr_lookups
        (null
        ,'YES_NO'
        ,nvl(p_save_run_balance_enabled,'N')) Then
        --
        fnd_message.set_name('PAY','HR_52966_INVALID_LOOKUP');
        fnd_message.set_token('COLUMN','SAVE_RUN_BALANCE_ENABLED');
        fnd_message.set_token('LOOKUP_TYPE','YES_NO');
        fnd_message.raise_error;
        --
     End If;

   --  do the insert

   hr_utility.set_location('pay_db_balances_pkg.create_balance_dimension',20);
   insert into pay_balance_dimensions
   (balance_dimension_id,
    business_group_id,
    legislation_code,
    route_id,
    payments_flag,
    database_item_suffix,
    dimension_name,
    dimension_type,
    description,
    feed_checking_code,
    feed_checking_type,
    expiry_checking_code,
    expiry_checking_level,
    dimension_level,
    period_type,
    asg_action_balance_dim_id,
    database_item_function,
    save_run_balance_enabled,
    start_date_code)
   select pay_balance_dimensions_s.nextval,
          p_business_group_id,
          p_legislation_code,
          p_route_id,
          p_payments_flag,
          p_database_item_suffix,
          p_dimension_name,
          p_dimension_type,
          p_description,
          p_feed_checking_code,
          p_feed_checking_type,
          p_expiry_checking_code,
          p_expiry_checking_level,
          p_dimension_level,
          p_period_type,
          p_asg_bal_dim,
          p_dbi_function,
          p_save_run_balance_enabled,
          p_start_date_code
     from dual
    where not exists (select ''
                        from pay_balance_dimensions
                       where dimension_name = p_dimension_name
                         and nvl(business_group_id, -999) =
                                      nvl(p_business_group_id, -999)
                         and nvl(legislation_code, 'NULL') =
                                      nvl(p_legislation_code, 'NULL')
                     );
--
   if (SQL%rowcount > 0) then
     hr_utility.set_location('pay_db_balances_pkg.create_balance_dimension',30);
     select pay_balance_dimensions_s.currval
     into   x from dual;
     return x;
   else
     return null;
   end if;
--
end create_balance_dimension;
--
--------------------------------------------------------------------------
-- Procedure create_dimension_route
--
-- Description
--   Inserts dimension routes relationshipts ofr run_balances
--------------------------------------------------------------------------
      procedure create_dimension_route(
                                       p_dim_id     in number,
                                       p_route_id   in number,
                                       p_route_type in varchar2,
                                       p_run_dim_id in number,
                                       p_priority   in number,
                                       p_baltyp_col   in varchar2 default null,
                                       p_dec_required in varchar2 default null)
      is
       l_dim_id number;
       l_run_dim_id number;
       l_route_id number;
      begin
          if (not p_route_type in ('RR', 'SRB')) then
               hr_utility.set_message(801, 'HR_BAD_BALDIM_DATA');
               hr_utility.raise_error;
          end if;
          insert into pay_dimension_routes
                (balance_dimension_id,
                 route_id,
                 route_type,
                 run_dimension_id,
                 priority,
                 balance_type_column,
                 decode_required
                )
          select p_dim_id,
                 p_route_id,
                 p_route_type,
                 p_run_dim_id,
                 p_priority,
                 p_baltyp_col,
                 p_dec_required
            from sys.dual
           where not exists (select ''
                               from pay_dimension_routes
                              where balance_dimension_id = p_dim_id
                                and route_type           = p_route_type
                                and priority             = p_priority);
      end create_dimension_route;
--
end pay_db_balances_pkg;

/
