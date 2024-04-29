--------------------------------------------------------
--  DDL for Package PAY_DB_BALANCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_DB_BALANCES_PKG" AUTHID CURRENT_USER as
/* $Header: pybaldim.pkh 115.5 2003/05/26 03:43:37 sdhole ship $ */
/*  Copyright (C) 1993 Oracle Corporation. All rights reserved.   */

/*
 Change List
 ===========

 Date       Author    ER/CR No. Description of Change
 +---------+----------+---------+-------------------------------------------
  25-May-03  sdhole     2898483  Support new two columns START_DATE_CODE,
		 		 SAVE_RUN_BALANCE_ENABLED to the function
  				 create_balance_dimension.
  10-OCT-02 nbristow             New attribution on dimenion routes.
  07-OCT-02 nbristow             Support new balance dimension functionality.
  31-AUG-01 dsaxby               Support new balance dimension columns.
  05-OCT-94 R.FINE               Renamed package to pay_db_balances_pkg
  11/03/93  H.MINTON             Added copyright and exit line
 ---------------------------------------------------------------------------
*/
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
         return number;
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
                                       p_priority     in number,
                                       p_baltyp_col   in varchar2 default null,
                                       p_dec_required in varchar2 default null);
--
end pay_db_balances_pkg;

 

/
