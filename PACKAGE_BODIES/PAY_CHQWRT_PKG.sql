--------------------------------------------------------
--  DDL for Package Body PAY_CHQWRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CHQWRT_PKG" as
/* $Header: pychqwrt.pkb 120.1.12010000.2 2008/08/06 07:01:12 ubhat ship $ */
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1992 Oracle Corporation UK Ltd.,                *
   *                   Chertsey, England.                           *
   *                                                                *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation UK Ltd,  *
   *  Oracle Park, Bittams Lane, Guildford Road, Chertsey, Surrey,  *
   *  England.                                                      *
   *                                                                *
   ******************************************************************

   Name        : chqsql

   Description : Package and procedure to build sql for cheque writer.

   Test List
   ---------
   Procedure                     Name       Date        Test Id Status
   +----------------------------+----------+-----------+-------+--------------+

   Change List
   -----------
   Date         Name        Vers   Bug No   Description
   -----------  ----------  -----  -------  -----------------------------------
   01-FEB-2006  NBRISTOW    115.3           Added ability to pay organizations
                                            directly.
   10-Dec-2004  SuSivasu    115.2           Removed cheque_date function.
   06-Dec-2004  SuSivasu    115.1           Added cheque_date function.
   12-APR-1996  NBRISTOW    40.9            Chequewriter was rewriten to use
                                            multiple threads. As a result
                                            the sql has been changed to
                                            retrieve the assignment action
                                            in the correct order.
   11-APR-1996  NBRISTOW    40.8            SQL was creating duplicate actions
                                            for voided payments.
   29-Mar-1996  cadams      40.7            Added subquery to allow voided
                                            cheques to be selected
   01-FEB-1996  mwcallag    40.6   339128   SQL tuned to improve performance.
   05-OCT-1994  RFINE       40.4            Renamed package to pay_chqwrt_pkg
   10-DEC-1993  DSAXBY      40.1   G350     Altered incorrect assignment
                                            interlock sql.
                                            Added missing date effective join.
   12-OCT-1993  CLEVERLY    1.0             First created.
*/
   chq_sql  varchar(4000); -- select list for pre-payments..
--
   ---------------------------------- chqsql ----------------------------------
   /*
      NAME
         chqsql - build dynamic sql.
      DESCRIPTION
         builds an SQL statement from a 'kit of parts'.
         It concatenates various parts together depending on
         what is required, ie the ordering of the pre-payments
         so that cheque numbers are allocated in the correct
         sequence for that organisation.
      NOTES
         The procedure passes back the length of the resultant
         string, so it can be successfully null terminated by
         the calling program.

         NB If you alter or add select statements check that they
            do not contain more than 4000 characters
   */
   procedure chqsql
   (
      procname   in            varchar2,     /* name of the select statement to use */
      sqlstr     in out nocopy varchar2,     /* string holding the sql statement */
      len        out    nocopy number        /* length of the sql string */
   ) is
   begin
      -- go through each of the sql sub strings and see if
      -- they are needed.
      if procname = 'DEFAULT' then
         sqlstr := chq_sql;
      else
         sqlstr := chq_sql;
      end if;
      len := length(sqlstr); -- return the length of the string.
   end chqsql;
--
   function get_upgrade_status
     (p_business_group_id number
     ,p_short_name        varchar2
     )return varchar2 is
     --
     l_status pay_upgrade_status.status%type;
     --
   begin
     --
     pay_core_utils.get_upgrade_status(p_business_group_id,p_short_name,l_status);
     --
     return l_status;
     --
   exception
     when others then
       --
       return 'E';
       --
   end get_upgrade_status;
--
   --------------------------------- cheque_date ------------------------------
   /*
      NAME
         cheque_date - derives the cheque date.
      DESCRIPTION
         Returns the cheque date based on the select payment
      NOTES
         <none>
   */
   /*
   function cheque_date
   (
      p_business_group_id    in number,
      p_payroll_id           in number,
      p_consolidation_set_id in number,
      p_start_date           in date,
      p_end_date             in date,
      p_payment_type_id      in number,
      p_payment_method_id    in number,
      p_cheque_style         in varchar2
   ) return date is
     --
     l_cheque_date   date;
     statem          varchar2(1000);
     rows_processed  integer;
     sql_curs        number;
     l_leg_code      per_business_groups_perf.legislation_code%type;
     --
     l_bee_iv_upgrade  varchar2(1);
     --
   begin
     --
     l_bee_iv_upgrade := get_upgrade_status(p_business_group_id,'CHQ_WRT_CHEQUE_DATE');
     --
     if l_bee_iv_upgrade = 'E' then
        hr_utility.set_message(801, 'HR_XXXX_CW_CHQ_DATE_UPGRADING');
        hr_utility.raise_error;
     end if;
     --
     if l_bee_iv_upgrade = 'N' then
        return nvl(p_end_date,sysdate);
     end if;
     --
     select legislation_code
     into   l_leg_code
     from   per_business_groups_perf
     where  business_group_id = p_business_group_id;
     --
     statem := 'BEGIN
                :cheque_date := pay_'||lower(l_leg_code)||'_cheque_writer_pkg.cheque_date(
                                :business_group_id,
                                :payroll_id,
                                :consolidation_set_id,
                                :start_date,
                                :end_date,
                                :payment_type_id,
                                :payment_method_id,
                                :cheque_style); END;';
     --
     sql_curs := dbms_sql.open_cursor;
     --
     dbms_sql.parse(sql_curs,
                  statem,
                  dbms_sql.v7);
     --
     dbms_sql.bind_variable(sql_curs, 'cheque_date',          l_cheque_date);
     dbms_sql.bind_variable(sql_curs, 'business_group_id',    p_business_group_id);
     dbms_sql.bind_variable(sql_curs, 'payroll_id',           p_payroll_id);
     dbms_sql.bind_variable(sql_curs, 'consolidation_set_id', p_consolidation_set_id);
     dbms_sql.bind_variable(sql_curs, 'start_date',           p_start_date);
     dbms_sql.bind_variable(sql_curs, 'end_date',             p_end_date);
     dbms_sql.bind_variable(sql_curs, 'payment_type_id',      p_payment_type_id);
     dbms_sql.bind_variable(sql_curs, 'payment_method_id',    p_payment_method_id);
     dbms_sql.bind_variable(sql_curs, 'cheque_style',         p_cheque_style);
     --
     rows_processed := dbms_sql.execute(sql_curs);
     --
     dbms_sql.variable_value(sql_curs, 'cheque_date', l_cheque_date);
     --
     dbms_sql.close_cursor(sql_curs);
     --
     return l_cheque_date;
     --
     --
   exception
     when others then
       --
       if dbms_sql.is_open(sql_curs) then
          dbms_sql.close_cursor(sql_curs);
       end if;
       --
       return to_date(null);
       --
   end cheque_date;
   */
--
begin
--
chq_sql := '
   select paa.rowid
     from
          (select /*+ ORDERED */paa1.assignment_action_id,
                  hou.name,
                  ppf.last_name,
                  ppf.first_name
             from pay_payroll_actions    ppa1,
                  pay_assignment_actions paa1,
                  per_assignments_f      paf,
                  hr_organization_units  hou,
                  per_people_f           ppf



            where paa1.object_type is null
              and paa1.payroll_action_id = ppa1.payroll_action_id
              and paa1.payroll_action_id = :pactid
              and paa1.assignment_id     = paf.assignment_id
              and ppa1.effective_date between
                          paf.effective_start_date and paf.effective_end_date
              and paf.person_id         = ppf.person_id
              and ppa1.effective_date between
                          ppf.effective_start_date and ppf.effective_end_date
              and paf.organization_id   = hou.organization_id
           union all
            select paa1.assignment_action_id,
                   hou.name,
                   null,
                   null
              from hr_organization_units  hou,
                   pay_assignment_actions paa1
             where paa1.object_type = ''HOU''
               and paa1.object_id   = hou.organization_id
               and paa1.payroll_action_id = :pactid
          ) un,
          pay_assignment_actions paa
    where paa.payroll_action_id = :pactid
      and paa.assignment_action_id = un.assignment_action_id
    order by un.name,un.last_name,un.first_name
      for update of paa.assignment_id';
--
end pay_chqwrt_pkg;

/
