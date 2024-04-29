--------------------------------------------------------
--  DDL for Package Body HRSTRDBI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRSTRDBI" as
/* $Header: pestrdbi.pkb 115.60 2002/12/09 13:56:53 eumenyio ship $ */
/*
--
-- Copyright (c) Oracle Corporation 1991, 1992, 1993. All rights reserved.
--
/*
   NAME
      pestrdbi.pkb     - create static entity database items
--
   DESCRIPTION
      This procedure is to be run once only on a new account.  It creates all
      the static database items used in formula writing and Quick Paint.  This
      includes the formula types and their contexts.
--
  MODIFIED (DD-MM-YYYY)
     dcasemor   02-DEC-2002 - Added assignment_category to
                              SEH_ASS_PERSON_DETAILS_PERF.
     divicker   28-NOV-2002 - rename ue BIS_PERSON_ASSIGNMENT_DETAILS to
                              BIS_PERSON_ASSIGNMENT_DETAILS_PERF
     mreid      26-NOV-2002 - Added Date Earned route
                              SEH_ASG_LAST_EARNED_PER_NUM
     skota	30-OCT-2002 - moved the database items to new routes
     divicker   08-OCT-2002 - added 'ASSIGNMENT_ACTION_DATES_ROUTE' etc
     divicker   07-OCT-2002 - changed list of Net to Gross contexts
                              added mod function
     divicker   02-SEP-2002 - dbis ASG_LAST_PROPOSED_SALARY_CHANGE and
                              ASG_LAST_PROPOSED_SALARY_PERCENT changed to
                              use proposed_salary_n
     dcasemor   16-SEP-2002 - Bug 2571440. Changed the route of
                              ACCRUAL_PLAN_PAYROLL_PROCESS_3 so that it only
                              picks up PTO elements which are balance related.
     dcasemor   05-SEP-2002 - Bug 1791902. Changed the formula text for
                              PTO_PAYROLL_CARRYOVER.
     divicker   29-AUG-2002 - Added formula_type 'Payroll Run Proration'
     alogue     28-AUG-2002 - Added new dbitems LAST_REG_PAYMENT_PERIOD and
                              LAST_REG_PAYMENT_PERIOD_START_DATE. Bug 2527079.
     alogue     17-JUN-2002 - Addition of hint to dbitems using SEH_ASS_LAST_PER_NUM
                              route to optimise performance.
     divicker   13-JUN-2002 - change Promotion formula to Promotion_template
                              added SEH_ASSIGNMENT_DETAILS route, ue, dbi
     divicker   06-JUN-2002 - added Promotion formula type
                              added to route SEH_ASS_PERSON_DETAILS_2
                              added dbi ASG_CHANGE_REASON
     divicker   27-MAY-2002 - added routes HRI_ASG_DETAILS, HRI_ASG_INHRTD_WRK_CNDTNS
                            - change to TEMPLATE_FTE and TEMPLATE_HEAD formulae
     divicker   17-MAY-2002 - use PTU_PERSON_TYPE instead of PERSON for CAGR
     divicker   26-NOV-2001 - Added CON_NATIONAL_IDENTIFIER dbi for US EOY
                            - Added CAGR formula type and formulae
                            - HR_CAGR_TEMPLATE and HR_CAGR_PYS_TEMPLATE
     jgoswami   25-OCT-2001 - Added dbi PER_1099R_NAME Fix for Bug 2072482
     divicker   25-OCT-2001 - removed source_action_id null check from
                              ACCRUAL_PLAN_PAYROLL_PROCESS_3 route
     dcasemor   12-OCT-2001 - Removed some comments from the Fast Formula
                              PTO_PAYROLL_BALANCE_CALCULATION.
     divicker   11-OCT-2001 - Added dbi PTU_REC_PERSON_TYPE
     dcasemor   10-OCT-2001 - Removed a bracket from the fast formula
                              TEMPLATE_ABSENCE_DURATION.
     divicker   07-SEP-2001 - merge of peorgrte.sql, peposrte.sql
                              That is: addition of ASG_ORG_ROUTE and
                              ASG_POS_ROUTE routes.
     divicker   07-SEP-2001 - ACCRUAL_PLAN_PAYROLL_PROCESS_3 run_result logic
                              added
                              TEMPLATE_ABSENCE_DURATION fix to default times
     divicker   04-SEP-2001 - Add PTU versions of PER_PERSON_TYPE,
                              SUP_PERSON_TYPE, CON_PERSON_TYPE
     alogue     09-AUG-2001 - Fix to route SEH_SADMIN_SALARY_ELEMENT.
                              Bug 1927280.
     alogue     02-AUG-2001 - Fix to route contexts usages for
                              ACCRUAL_PLAN_PAYROLL_PROCESS_2.
     mreid      20-JUL-2001 - Changed PTO formula to reference
                              ENTRY_PROCESSED_IN_PERIOD
     alogue     17-JUL-2001 - New function ENTRY_PROCESSED_IN_PERIOD.
     alogue     09-JUL-2001 - New formula PTO_ORACLE_SKIP_RULE,
                              PTO_PAYROLL_BALANCE_CALCULATION,
                              PTO_SIMPLE_BALANCE_MULTIPLIER,
                              PTO_HD_ANNIVERSARY_BALANCE,
                              PTO_HD_ANNIVERSARY_PERIOD_ACCRUAL,
                              PTO_HD_ANNIVERSARY_CARRYOVER,
                              PTO_TAGGING_FORMULA.
                              Changes to PTO_PAYROLL_PERIOD_ACCRUAL,
                              PTO_PAYROLL_CALCULATION and
                              PTO_PAYROLL_CARRYOVER formula.
                              New routes ACCRUAL_PLAN_PAYROLL_PROCESS_1,
                              ACCRUAL_PLAN_PAYROLL_PROCESS_2,
                              ACCRUAL_PLAN_PAYROLL_PROCESS_3 and their user entities
                              and dbitems.
     mreid      03-JUL-2001 - Corrected ACCRUAL_PLAN_CONT_SERVICE_DATES
                              and ACCRUAL_PLAN_ENROLLMENT_DATES.
     alogue     12-JUN-2001 - Amended ACCRUAL_PLAN_CONT_SERVICE_DATES route.
     alogue     31-MAY-2001 - Amended ACCRUAL_PLAN_ENROLLMENT_DATES route
                              and ACCRUAL_PLAN_CONT_SERVICE_DATES route.
     alogue     24-MAY-2001 - New CURRENT_ELEMENT_TYPE_ID dbitem.
     dcasemor   08-MAR-2001 - Bug 1610788.
                              Added PERSON_ID context to Accrual formula type.
     alogue     06-MAR-2001 - New ENTRY_END_DATE dbitem,
     alogue     11-DEC-2000 - New ELEMENT_TYPE_ATTRIBUTES route,
                              ELEMENT_TYPE_ATTRIBUTES user entity, and
                              ELEMENT_NAME dbitem.
     alogue     30-NOV-2000 - New PAY_EARNED_PERIOD_CORE route, PAY_PD_DETAILS_CORE
                              user entity, and PAY_EARNED dbitems.
     alogue     26-SEP-2000 - Fix to CHECK_RATE_TYPE formula.
                              Source_text into Oracle Payroll
                              ff_ftype_context_usages.
     alogue     05-JUN-2000 - Fixes to SEH_ASSIGN_HR_ADDRESS, SEH_PER_PERSON_ADDRESS,
                              and SEH_CON_PERSON_ADDRESS route texts.
     alogue     17-MAY-2000 - R11.5 Concurrent patch Entity Horizon changes:
                              Change to SEH_PER_PERSON_DETAILS, bug 1096840.
     alogue     12-MAY-2000 - R11.5 Concurrent patch Entity Horizon changes:
                              New route SEH_SADMIN_SALARY_PROPOSALS_2.
                              New route PER_TIME_PERIODS_INFO and dbitems.
                              Fix to formula QH_ASSIGNMENT_NAME.
                              New dbitem SUP_EMAIL_ADDRESS.
     alogue     07-APR-2000 - R11.5 Concurrent patch Entity Horizon changes:
                              Performance changes to SEH_ASSIGN_HR_ADDRESS,
                              SEH_CON_PERSON_ADDRESS and SEH_PER_PERSON_ADDRESS
                              use fnd_territories_tl.
                              Change to PTO_PAYROLL_CALCULATION formula.
                              Change to PTO_SIMPLE_MULTIPLIER formula.
                              Change to PTO_SIMPLE_PERIOD_ACCRUAL formula.
                              Change to PTO_SIMPLE_CARRYOVER formula.
                              Change to CALCULATE_PAYROLL_PERIODS function.
                              Iterative Engine support.
                              New route ASSIGNMENT_CONTRACTS_ROUTE and
                              accompanying dbitems.
                              New formula QH_ASSIGNMENT_NAME.
     alogue     08-NOV-1999 - R11.5 Entity Horizon changes:
                              Change to PTO_PAYROLL_CALCULATION formula.
                              Change to PTO_SIMPLE_MULTIPLIER formula.
                              Change to PTO_SIMPLE_CARRYOVER formula.
                              Change to PTO_ROLLING_ACCRUAL formula.
                              Change to PTO_PAYROLL_CARRYOVER formula.
                              Change to ACCRUAL_PLAN_ENROLLMENT_DATES,
                              ACCRUAL_PLAN_CONT_SERVICE_DATES routes.
                              New BIS dbitems ASG_EMPLOYMENT_CATEGORY_CODE,
                              ASG_PRIMARY_CODE and ASG_FREQ_CODE.
                              Change to TEMPLATE_BIS_DAYS_TO_HOURS formula.
                              Change to TEMPLATE_HEAD formula.
                              Change to TEMPLATE_FTE formula.
     alogue     26-OCT-1999 - R11.5 Entity Horizon changes:
                              New dbitem ASG_SALARY_BASIS_ANNUALIZATION_FACTOR
                              ASG_SALARY_BASIS_GRADE_ANNUALIZATION_FACTOR.
                              Change to ASSIGNMENT_FULL_TIME_CONDITIONS route.
                              Change to SEH_ASS_PERSON_DETAILS route.
                              Change to SEH_REC_DETAILS route.
                              Change to SEH_SUP_DETAILS route.
                              New formula TEMPLATE_ABSENCE_DURATION.
                              New function COUNT_WORKING_DAYS.
                              Change to PTO_PAYROLL_CALCULATION formula.
                              New PAY_EARNED_PERIOD_CORE route, PAY_PD_DETAILS_CORE
                              user entity, and PAY_EARNED dbitems.
     alogue     02-JUN-1999 - R11.5 Entity Horizon changes: Fixes to
                              PTO_PAYROLL_CALCULATION, PTO_ROLLING_ACCRUAL
                              and PTO_SIMPLE_MULTIPLIER.
                              New ff_function CHK_NAT_ID_FORMAT.
     alogue     25-JUN-1999 - R11.5 Entity Horizon changes:
                              New dbitems : PER_PREFIX, PER_SUFFIX,
                              PER_ADR_COUNTRY_CODE and ENTRY_START_DATE.
     alogue     24-MAY-1999 - R11.5 Entity Horizon changes:
                              New formula TEMPLATE_BIS_TRAINING_CONVERT_DURATION.
                              New context SOURCE_TEXT.
                              New Accrual formula types + changes to formulae..
     alogue     26-APR-1999 - R11.5 Entity Horizon changes: Canonical Date and
                              Canonical Number support.
                              New ff_context source_id.
                              Accrual plan changes: ACCRUAL_PLAN_ENROLLMENT_DATES
                              and ACCRUAL_PLAN_CONT_SERVICE_DATES.
                              Fix to ACCRUAL_PLAN_SERVICE_DATES.
                              New formula PTO_INELIGIBILITY_CALCULATION.
                              New formula CHECK_RATE_TYPE.
                              New procedure insert_user_tables to seed
                              user tables.
     alogue     16-MAR-1999 - R11.5 Entity Horizon changes:
                              Outer join for per_phones in SEH_PER_PERSON_DETAILS
                              New ACCRUAL formula type.
                              Route ACCRUAL_PLAN_VALUES and its dbitems.
                              Route CARRIED_OVER_VALUES and its dbitems.
                              Route ACCRUAL_PLAN_SERVICE_DATES and its dbitems.
                              Route ACCRUAL_PLAN_DATES and its dbitems.
                              Added TEMPLATE_BIS_DAYS_TO_HOURS, TEMPLATE_FTE,
                              TEMPLATE_HEAD, EXAMPLE_BIS_OT_BAND1 to
                              ff_formulas_f.
                              Created insert_formula to insert PTO_PAYROLL_CARRYOVER,
                              PTO_PAYROLL_PERIOD_ACCRUAL, PTO_PAYROLL_CALCULATION,
                              PTO_ROLLING_CARRYOVER, PTO_ROLLING_PERIOD_ACCRUAL,
                              PTO_ROLLING_ACCRUAL, PTO_SIMPLE_CARRYOVER,
                              PTO_SIMPLE_PERIOD_ACCRUAL, PTO_SIMPLE_MULTIPLIER
                              into ff_formulas_f.
                              Created insert_functions to insert GET_HOURS_WORKED,
                              CURRENCY_CONVERT_AMOUNT, GET_RATE_TYPE,
                              CHECK_RATE_TYPE and accrual functions
                              into ff_functions.
     alogue     11-JAN-1999 - R11.5 Entity Horizon changes:
                              OAB and other new ff_contexts, route
                              ASSIGNMENT_BUDGET_VALUES and dbitems,
                              ASSIGNMENT_FULL_TIME_CONDITIONS route
                              and dbitems.
                              R11.5 change whereby date contexts are passed
                              into routes as dates (and thus don't require
                              a to_date() on them).
                              Change to SEH_SADMIN_LAST_PERFORM_REV route.
                              New routes SEH_CON_PERSON_DETAILS_2,
                              SEH_ASS_PERSON_DETAILS_3, SEH_PER_PERSON_DETAILS_2
                              and dbitems.
     alogue     13-JUL-1998 - Legislative Check formula type.
     alogue     20-MAY-1998 - Performance fixes for SEH_ASS_PERSON_DETAILS and
                              SEH_PER_PERSON_DETAILS routes.
     alogue     13-NOV-1997 - Rename PER_CONTACTS table to
                              PER_CONTACT_RELATIONSHIPS.
     alogue     11-NOV-1997 - user entity PAY_PAYROLLS_ENTITY fix.
     alogue     07-NOV-1997 - New database item EMP_PROJ_TERM_DATE.
     rfine      13-OCT-97   110.5  563034  Changed parent table name from
                                           PER_PEOPLE_F to PER_ALL_PEOPLE_F
     alogue     07-OCT-1997 - fix of SEH_ASS_PERSON_DETAILS route.
     alogue     12-AUG-1997 - per_phones put into various routes
     alogue     07-AUG-1997 - ff_context TAX_GROUP.
     alogue     05-AUG-1997 - Rename use of fnd_territories to
                              fnd_territories_vl.
     alogue     29-MAY-1997 - Fix to PAY_PAYROLLS_ROUTE.
     alogue     19-MAY-1997 - Renamed database item ARREARS_FLAG to
                              PAYROLL_ARREARS_FLAG.
     alogue     07-APR-1997 - New routes: TARGET_PAYROLL_ACTION_ROUTE
                              (for action_type item) and PAY_PAYROLLS_ROUTE
                              (for arrears_flag item) for advance pay.
                              Also tidy up reflecting bug 374466
                              SEH_ASS_PERSON_DETAILS route fix.
     mwcallag   01-SEP-1995 - sysdate and Session date routes and DB items
                              added.
     mwcallag   24-APR-1995 - Cheque number DB items added (UK, US spelling).
     mwcallag   31-MAR-1995 - Entity for PAY_PROC_PERIOD_NUMBER DB items now
                              has not_found_allowed = 'Y'.
     mwcallag   06-JAN-1995 - Performance changes resulting from the DEC
                              Benchmark.  These include:
                              --
                              A new route : SEH_ASS_PERSON_DETAILS_2  - this
                              holds DB items that were previously being slowed
                              down in route SEH_ASS_PERSON_DETAILS.
                              --
                              Index for pay_basis_id disabled in the route
                              SEH_SADMIN_SALARY_ELEMENT.
                              --
                              The following routes used to use the synonym
                              fnd_lookups.  Originally this was a simple
                              table, but now is a complex view, and hence
                              these routes now refer to the view hr_lookups,
                              and also use the application id column (= 800)
                              for improved performance:
                              SEH_PER_PERSON_DETAILS
                              SEH_ASS_PERSON_DETAILS
                              SEH_CON_PERSON_DETAILS
                              SEH_REC_DETAILS
                              SEH_SUP_DETAILS
                              --
                              The following routes use the view hr_lookups.
                              They have been modified to also use the
                              application id column (= 800) for improved
                              performance:
                              SEH_EMP_PERSON_SERVICE_2
                              SEH_SADMIN_SALARY_BASIS
                              SEH_SADMIN_SALARY_PROPOSALS
                              SEH_ASSIGN_HR_ADDRESS_US
                              SEH_ASSIGN_ADDRESS_US
                              SEH_ASSIGN_HR_ADDRESS_UK
                              SEH_ASSIGN_ADDRESS_UK
                              --
     mwcallag   24-OCT-1994 - New context of ORIGINAL_ENTRY_ID added to
                              payroll and element skip formual types
     mwcallag   15-OCT-1994 - Various changes ready for US benchmark:
                              Date restriction added to Person and contact
                              address routes (bug no. 240009).
                              SEH_PAY_DETAILS route now uses the context of
                              payroll action rather than payroll id to improve
                              performance.
                              New DB item added to route SEH_PAY_DETAILS:
                              PAY_PROC_PERIOD_NUMBER
                              PAY_PROC_PERIOD_ID
                              PAY_PROC_PERIOD_NAME
                              --
                              'PAY_PROC_PERIOD_NUMBER' replaces the old
                              'ASG_PROC_PERIOD_NUMBER' DB item.
                              ASG_LAST_PROC_PERIOD_NUMBER route changed to use
                              the context of assignment id (the previous
                              change to use payroll action was wrong), also
                              uses the DB change of time_period_id on the
                              payroll actions table to improve performance.
                              New DB item added to this route:
                              ASG_LAST_PROC_PERIOD_NAME
                              ASG_LAST_PROC_PERIOD_ID
                              ASG_LAST_PROC_PAYROLL_NAME
                              --
     mwcallag   28-JUL-1994 - Payroll period DB items added.
     mwcallag   16-JUN-1994 - Route SEH_EMP_PERSON_SERVICE_2 altered, nvl
                              added.
                              This ensures a row is always returned.
     mwcallag   29-APR-1994 - Route SEH_ASS_LAST_PER_NUM tuned, now uses the
                              context of payroll action id rather than
                              assignment id. (ASG_LAST_PROC_PERIOD_NUMBER).
                              Route SEH_EMP_PERSON_SERVICE split into 2 for
                              performance purposes.
     mwcallag   25-MAR-1994 - Not found flag for all ASG_%_LAST% DB item
                              set to yes.
     mwcallag   18-MAR-1994 - Not found flag for ASG_LAST_PROC_PERIOD_NUMBER
                              set to yes - there wont be an entry for the
                              first run.
     mwcallag   28-FEB-1994 - Database name changed from 'ASS_%' to 'ASG_%'.
     mwcallag   11-JAN-1994 - New context of Element type id added to
                              ff_contexts.
     mwcallag   06-JAN-1994 - Contact routes changed to use contact_person_id.
     mwcallag   15-DEC-1993 - HR location (general, GB and US) DB items added.
                              G417 ASS_SALARY changed to Number data type.
                              ASS_SALARY_BASIS_CODE DB item added.
     mwcallag   09-DEC-1993 - G337 Payroll DB items added: PAY_PERIODS_PER_YEAR
                              and PAY_PROC_PERIOD_DATE_PAID.
     mwcallag   02-DEC-1993 - Salary Admin Db items added.
     mwcallag   02-NOV-1993 - 'User Table Validation' formula type added.
     mwcallag   22-OCT-1993 - Further formula types and contexts added.
     mwcallag   08-OCT-1993 - Payroll DB items : null allowed set to 'N'.
     mwcallag   07-SEP-1993 - ********************************
                              * DIVERGENCE FROM FROZEN CODE  *
                              ********************************
                              More Static DB items added, together with
                              new routes for payroll processing.
     mwcallag   31-AUG-1993 - Person type definition texts changed from
                              'system_person_type' to 'user_person_type'.
                              Payroll formula type changed to include fewer
                              context usages.
     mwcallag   11-AUG-1993 - New contexts for payment formula type.
     mwcallag   22-JUL-1993 - Routine split into 2 procedures for easier
                              re-building.
     mwcallag   20-JUL-1993 - Some DB items changed from number to text type.
     mwcallag   21-JUN-1993 - 'Element Input Validation' formula type added.
     mwcallag   15-JUN-1993 - minor changes to routes to ensure a row is
                              always returned (outer joins added, etc).
     mwcallag   04-JUN-1993 - general mods and application details route added
     mwcallag   28-MAY-1993 - minor change to person assignment details route.
     mwcallag   26-MAY-1993 - creator type changed following database change.
     mwcallag   17-MAY-1993 - created.
*/
procedure insert_context is
--
--   +==================================================================+
--   |    Insert FF contexts                                            |
--   +==================================================================+
--
begin
   declare
      procedure do_insert (l_context_name varchar2, l_data_type varchar2) is
         x number;
      begin
         x := ffdict.get_context_level;
         --
         hr_utility.set_location('hrstrdbi.ff_context_do_insert', 1);
         insert into ff_contexts
         (context_id,
          context_level,
          context_name,
          data_type)
         values
         (ff_contexts_s.nextval,
          x,
          l_context_name,
          l_data_type);
      end;
   begin
      do_insert ('BUSINESS_GROUP_ID',     'N');
      do_insert ('PAYROLL_ID',            'N');
      do_insert ('PAYROLL_ACTION_ID',     'N');
      do_insert ('ASSIGNMENT_ID',         'N');
      do_insert ('ASSIGNMENT_ACTION_ID',  'N');
      do_insert ('DATE_EARNED',           'D');
      do_insert ('ORG_PAY_METHOD_ID',     'N');
      do_insert ('PER_PAY_METHOD_ID',     'N');
      do_insert ('ORGANIZATION_ID',       'N');
      do_insert ('TAX_UNIT_ID',           'N');
      do_insert ('JURISDICTION_CODE',     'T');
      do_insert ('BALANCE_DATE',          'D');
      do_insert ('ELEMENT_ENTRY_ID',      'N');
      do_insert ('ELEMENT_TYPE_ID',       'N');
      do_insert ('ORIGINAL_ENTRY_ID',     'N');
      do_insert ('TAX_GROUP',             'T');
      do_insert ('PGM_ID',                'N');
      do_insert ('PL_ID',                 'N');
      do_insert ('PL_TYP_ID',             'N');
      do_insert ('OPT_ID',                'N');
      do_insert ('LER_ID',                'N');
      do_insert ('COMM_TYP_ID',           'N');
      do_insert ('ACT_TYP_ID',            'N');
      do_insert ('ACCRUAL_PLAN_ID',       'N');
      do_insert ('PERSON_ID',             'N');
      do_insert ('SOURCE_ID',             'N');
      do_insert ('SOURCE_TEXT',           'T');
   end;
--
--   +==================================================================+
--   |    Insert FF formula type and contexts                           |
--   +==================================================================+
--
   declare
       procedure do_insert
       (
           p_formula_type_name  in varchar2
       ) is
       begin
           hr_utility.set_location('hrstrdbi.ff_type_do_insert', 1);
           insert into ff_formula_types
                 (formula_type_id,
                  formula_type_name,
                  last_update_date,
                  last_updated_by,
                  last_update_login,
                  created_by,
                  creation_date)
          values (ff_formula_types_s.nextval,
                  p_formula_type_name,
                  sysdate,
                  0,
                  0,
                  0,
                  sysdate);
       end do_insert;
    begin
       do_insert ('Oracle Payroll');
       hr_utility.set_location('hrstrdbi.insert_context', 1);
       insert into ff_ftype_context_usages (formula_type_id, context_id)
       select ff_formula_types_s.currval, CON.context_id
       from ff_contexts CON
       where context_name in ('BUSINESS_GROUP_ID',
                              'PAYROLL_ID',
                              'PAYROLL_ACTION_ID',
                              'ASSIGNMENT_ID',
                              'ASSIGNMENT_ACTION_ID',
                              'DATE_EARNED',
			      'TAX_UNIT_ID',
			      'JURISDICTION_CODE',
			      'BALANCE_DATE',
                              'ELEMENT_ENTRY_ID',
                              'ELEMENT_TYPE_ID',
                              'ORIGINAL_ENTRY_ID',
                              'SOURCE_ID',
                              'TAX_GROUP',
                              'SOURCE_TEXT');
       --
       do_insert ('Payment');
       hr_utility.set_location('hrstrdbi.insert_context', 2);
       insert into ff_ftype_context_usages (formula_type_id, context_id)
       select ff_formula_types_s.currval, CON.context_id
       from ff_contexts CON
       where context_name in ('BUSINESS_GROUP_ID',
                              'PAYROLL_ID',
                              'PAYROLL_ACTION_ID',
                              'ASSIGNMENT_ID',
                              'ASSIGNMENT_ACTION_ID',
                              'DATE_EARNED',
			      'ORG_PAY_METHOD_ID',
			      'PER_PAY_METHOD_ID',
			      'ORGANIZATION_ID',
			      'TAX_UNIT_ID',
			      'JURISDICTION_CODE');
       --
       do_insert ('Assignment Set');
       hr_utility.set_location('hrstrdbi.insert_context', 3);
       insert into ff_ftype_context_usages (formula_type_id, context_id)
       select ff_formula_types_s.currval, CON.context_id
       from ff_contexts CON
       where context_name in ('DATE_EARNED', 'ASSIGNMENT_ID');
       --
       do_insert ('QuickPaint');
       hr_utility.set_location('hrstrdbi.insert_context', 4);
       insert into ff_ftype_context_usages (formula_type_id, context_id)
       select ff_formula_types_s.currval, CON.context_id
       from ff_contexts CON
       where context_name in ('DATE_EARNED', 'ASSIGNMENT_ID');
       --
       do_insert ('Element Input Validation');
       hr_utility.set_location('hrstrdbi.insert_context', 5);
       insert into ff_ftype_context_usages (formula_type_id, context_id)
       select ff_formula_types_s.currval, CON.context_id
       from ff_contexts CON
       where context_name in ('DATE_EARNED',
                              'ASSIGNMENT_ID', 'BUSINESS_GROUP_ID');
       --
       do_insert ('Element Skip');
       hr_utility.set_location('hrstrdbi.insert_context', 6);
       insert into ff_ftype_context_usages (formula_type_id, context_id)
       select ff_formula_types_s.currval, CON.context_id
       from ff_contexts CON
       where context_name in ('BUSINESS_GROUP_ID',
                              'PAYROLL_ID',
                              'PAYROLL_ACTION_ID',
                              'ASSIGNMENT_ID',
                              'ASSIGNMENT_ACTION_ID',
                              'DATE_EARNED',
                              'TAX_UNIT_ID',
                              'JURISDICTION_CODE',
			      'ELEMENT_ENTRY_ID',
                              'ELEMENT_TYPE_ID',
                              'ORIGINAL_ENTRY_ID',
                              'SOURCE_ID',
                              'TAX_GROUP');
       --
       do_insert ('Legislative Check');
       hr_utility.set_location('hrstrdbi.insert_context', 7);
       insert into ff_ftype_context_usages (formula_type_id, context_id)
       select ff_formula_types_s.currval, CON.context_id
       from ff_contexts CON
       where context_name in ('ASSIGNMENT_ID',
                              'ASSIGNMENT_ACTION_ID',
                              'DATE_EARNED');
       --
       do_insert ('Accrual');
       hr_utility.set_location('hrstrdbi.insert_context', 8);
       insert into ff_ftype_context_usages (formula_type_id, context_id)
       select ff_formula_types_s.currval, CON.context_id
       from ff_contexts CON
       where context_name in ('ASSIGNMENT_ID',
                              'ASSIGNMENT_ACTION_ID',
                              'DATE_EARNED',
                              'ACCRUAL_PLAN_ID',
                              'PAYROLL_ID',
                              'BUSINESS_GROUP_ID',
                              'PERSON_ID');
       --
       do_insert ('Accrual Subformula');
       hr_utility.set_location('hrstrdbi.insert_context', 9);
       insert into ff_ftype_context_usages (formula_type_id, context_id)
       select ff_formula_types_s.currval, CON.context_id
       from ff_contexts CON
       where context_name in ('ASSIGNMENT_ID',
                              'DATE_EARNED',
                              'ACCRUAL_PLAN_ID',
                              'PAYROLL_ID',
                              'BUSINESS_GROUP_ID');
       --
       do_insert ('Accrual Carryover');
       hr_utility.set_location('hrstrdbi.insert_context', 10);
       insert into ff_ftype_context_usages (formula_type_id, context_id)
       select ff_formula_types_s.currval, CON.context_id
       from ff_contexts CON
       where context_name in ('ASSIGNMENT_ID',
                              'DATE_EARNED',
                              'ACCRUAL_PLAN_ID',
                              'PAYROLL_ID',
                              'BUSINESS_GROUP_ID');
       --
       do_insert ('Accrual Ineligibility');
       hr_utility.set_location('hrstrdbi.insert_context', 11);
       insert into ff_ftype_context_usages (formula_type_id, context_id)
       select ff_formula_types_s.currval, CON.context_id
       from ff_contexts CON
       where context_name in ('ASSIGNMENT_ID',
                              'DATE_EARNED',
                              'ACCRUAL_PLAN_ID',
                              'PAYROLL_ID',
                              'BUSINESS_GROUP_ID');
       --
       do_insert ('Net to Gross');
       hr_utility.set_location('hrstrdbi.insert_context', 12);
       insert into ff_ftype_context_usages (formula_type_id, context_id)
       select ff_formula_types_s.currval, CON.context_id
       from ff_contexts CON
       where context_name in ('BUSINESS_GROUP_ID',
                              'PAYROLL_ID',
                              'PAYROLL_ACTION_ID',
                              'ASSIGNMENT_ID',
                              'DATE_EARNED',
                              'ELEMENT_ENTRY_ID',
                              'ASSIGNMENT_ACTION_ID',
                              'ELEMENT_TYPE_ID');
       --
       do_insert('CAGR');
       hr_utility.set_location('hrstrdbi.insert_context', 13);
       insert into ff_ftype_context_usages (formula_type_id, context_id)
       select ff_formula_types_s.currval, CON.context_id
       from ff_contexts CON
       where context_name in ('BUSINESS_GROUP_ID',
                              'PAYROLL_ID',
                              'ASSIGNMENT_ID',
                              'DATE_EARNED',
                              'ORGANIZATION_ID',
                              'TAX_UNIT_ID',
                              'PERSON_ID');
       --
       do_insert('Promotion');
       hr_utility.set_location('hrstrdbi.insert_context', 14);
       insert into ff_ftype_context_usages (formula_type_id, context_id)
       select ff_formula_types_s.currval, CON.context_id
       from ff_contexts CON
       where context_name in ('ASSIGNMENT_ID',
                              'DATE_EARNED');
       --
       do_insert('Payroll Run Proration');
       hr_utility.set_location('hrstrdbi.insert_context', 15);
       insert into ff_ftype_context_usages (formula_type_id, context_id)
       select ff_formula_types_s.currval, CON.context_id
       from ff_contexts CON
       where context_name in ('BUSINESS_GROUP_ID',
                              'PAYROLL_ID',
                              'PAYROLL_ACTION_ID',
                              'ASSIGNMENT_ID',
                              'ASSIGNMENT_ACTION_ID',
                              'DATE_EARNED',
                              'TAX_UNIT_ID',
                              'JURISDICTION_CODE',
                              'BALANCE_DATE',
                              'ELEMENT_ENTRY_ID',
                              'ELEMENT_TYPE_ID',
                              'ORIGINAL_ENTRY_ID',
                              'TAX_GROUP',
                              'SOURCE_ID',
                              'SOURCE_TEXT');
       --
       -- This formula type does not use any contexts:
       --
       do_insert ('User Table Validation');
    end;
    --
end insert_context;
--
PROCEDURE insert_routes_db_items is
l_text                          long;
l_date_earned_context_id        number;
l_assign_id_context_id          number;
l_assign_action_id_context_id   number;
l_payroll_id_context_id         number;
l_payroll_action_id_context_id  number;
l_accrual_plan_id_context_id    number;
l_original_entry_id             number;
l_element_entry_id              number;
l_element_type_id               number;
l_route_parameters_id           number;
--
-- ******** local procedure : insert_route_parameters  ********
--
procedure insert_route_parameters
(
    p_parameter_name  in  varchar2,
    p_data_type       in  varchar2,
    p_sequence_no     in  number
) is
begin
    hr_utility.set_location('hrstrdbi.insert_route_parameters', 1);
    insert into ff_route_parameters
          (route_id,
           sequence_no,
           parameter_name,
           data_type,
           route_parameter_id)
   select  ff_routes_s.currval,
           p_sequence_no,
           p_parameter_name,
           p_data_type,
           ff_route_parameters_s.nextval
   from    dual;
end insert_route_parameters;
--
-- ******** local procedure : insert_route_parameter_values  ********
--
procedure insert_route_parameter_values
(
    p_route_parameter_id  in  number,
    p_value               in  varchar2
) is
begin
    hr_utility.set_location('hrstrdbi.insert_route_parameter_values', 1);
    insert into ff_route_parameter_values
           (route_parameter_id,
            user_entity_id,
            value,
            last_update_date,
            creation_date)
    values (p_route_parameter_id,
            ff_user_entities_s.currval,
            p_value,
            sysdate,
            sysdate);
end insert_route_parameter_values;
--
-- ******** local procedure : insert_route_context_usages  ********
--
procedure insert_route_context_usages
(
    p_context_id    in  number,
    p_sequence_no   in  number
) is
begin
    hr_utility.set_location('hrstrdbi.insert_route_context_usages', 1);
    insert into ff_route_context_usages
           (route_id,
            context_id,
            sequence_no)
    select  ff_routes_s.currval,
            p_context_id,
            p_sequence_no
    from    dual;
end insert_route_context_usages;
--
-- ******** local procedure : insert_user_entity  ********
--
procedure insert_user_entity
(
    p_user_entity_name       in varchar2,
    p_description            in varchar2,
    p_notfound_allowed_flag  in varchar2 default 'N'
) is
begin
    hr_utility.set_location('hrstrdbi.insert_user_entity', 1);
    insert into ff_user_entities
           (user_entity_id,
            business_group_id,
            legislation_code,
            route_id,
            notfound_allowed_flag,
            user_entity_name,
            creator_id,
            creator_type,
            entity_description,
            last_update_date,
            last_updated_by,
            last_update_login,
            created_by,
            creation_date)
    --
    values (ff_user_entities_s.nextval,
            null,
            null,
            ff_routes_s.currval,
            p_notfound_allowed_flag,
            p_user_entity_name,
            0,
            'SEH',
            p_description,
            sysdate,
            0,
            0,
            0,
            sysdate);
end insert_user_entity;
--
-- ******** local procedure : insert_database_item  ********
--
procedure insert_database_item
(
    p_user_name          in varchar2,
    p_definition_text    in varchar2,
    p_description        in varchar2,
    p_data_type          in varchar2,
    p_null_allowed_flag  in varchar2
) is
begin
    hr_utility.set_location('hrstrdbi.insert_database_item', 1);
    hr_utility.trace ('creating : ' || p_user_name);
    insert into ff_database_items (
            user_name,
            user_entity_id,
            data_type,
            definition_text,
            null_allowed_flag,
            description,
            last_update_date,
            last_updated_by,
            last_update_login,
            created_by,
            creation_date)
    --
    values (p_user_name,
            ff_user_entities_s.currval,
            p_data_type,
            p_definition_text,
            p_null_allowed_flag,
            p_description,
            sysdate,
            0,
            0,
            0,
            sysdate);
end insert_database_item;
--
--
-- ******** local procedure : insert_route  ********
--
procedure insert_route
(
    p_route_name    in varchar2,
    p_description   in varchar2,
    p_text          in varchar2
) is
begin
    hr_utility.trace ('creating route : ' || p_route_name);
    hr_utility.set_location('hrstrdbi.insert_route', 1);
    insert into ff_routes
           (route_id,
            route_name,
            user_defined_flag,
            description,
            text,
            last_update_date,
            last_updated_by,
            last_update_login,
            created_by,
            creation_date)
    values (ff_routes_s.nextval,
            p_route_name,
            'N',
            p_description,
            p_text,
            sysdate,
            0,
            0,
            0,
            sysdate);
end insert_route;
--
------------------------------ begin -------------------------------
--
BEGIN
    --
    -- get the context ids from the context table
    --
    hr_utility.set_location('hrstrdbi.insert_routes_db_items', 1);
    select context_id
    into   l_date_earned_context_id
    from   ff_contexts
    where  context_name = 'DATE_EARNED';
    --
    hr_utility.set_location('hrstrdbi.insert_routes_db_items', 2);
    select context_id
    into   l_assign_id_context_id
    from   ff_contexts
    where  context_name = 'ASSIGNMENT_ID';
    --
    hr_utility.set_location('hrstrdbi.insert_routes_db_items', 3);
    select context_id
    into   l_payroll_action_id_context_id
    from   ff_contexts
    where  context_name = 'PAYROLL_ACTION_ID';
    --
    hr_utility.set_location('hrstrdbi.insert_routes_db_items', 4);
    select context_id
    into   l_assign_action_id_context_id
    from   ff_contexts
    where  context_name = 'ASSIGNMENT_ACTION_ID';
    --
    hr_utility.set_location('hrstrdbi.insert_routes_db_items', 5);
    select context_id
    into   l_payroll_id_context_id
    from   ff_contexts
    where  context_name = 'PAYROLL_ID';
    --
    hr_utility.set_location('hrstrdbi.insert_routes_db_items', 6);
    select context_id
    into   l_accrual_plan_id_context_id
    from   ff_contexts
    where  context_name = 'ACCRUAL_PLAN_ID';
    --
    hr_utility.set_location('hrstrdbi.insert_routes_db_items', 7);
    select context_id
    into   l_original_entry_id
    from   ff_contexts
    where  context_name = 'ORIGINAL_ENTRY_ID';
    --
    hr_utility.set_location('hrstrdbi.insert_routes_db_items', 8);
    select context_id
    into   l_element_entry_id
    from   ff_contexts
    where  context_name = 'ELEMENT_ENTRY_ID';
    --
    hr_utility.set_location('hrstrdbi.insert_routes_db_items', 9);
    select context_id
    into   l_element_type_id
    from   ff_contexts
    where  context_name = 'ELEMENT_TYPE_ID';
    --
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                       +
    -- Route for person details : SEH_PER_PERSON_DETAILS     +
    --                                                       +
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := '/* Person details */
          per_all_people_f       PEOPLE
  ,       per_person_types       PTYPE
  ,       per_phones             PHONE
  ,       fnd_sessions           SES
  ,       hr_lookups             a
  ,       hr_lookups             c
  ,       hr_lookups             d
  ,       hr_lookups             e
  ,       hr_lookups             f
  ,       hr_lookups             g
  ,       hr_lookups             h
  ,       hr_lookups             i
  ,       per_all_assignments_f  ASSIGN
  where   &B1 BETWEEN ASSIGN.effective_start_date
                   AND ASSIGN.effective_end_date
  and     ASSIGN.assignment_id = &B2
  and     PEOPLE.person_id     = ASSIGN.person_id
  and     &B1 BETWEEN PEOPLE.effective_start_date
                   AND PEOPLE.effective_end_date
  and     PTYPE.person_type_id = PEOPLE.person_type_id
  and     PHONE.parent_id (+) = PEOPLE.person_id
  AND     PHONE.parent_table (+)= ''PER_PEOPLE_F''
  and     PHONE.phone_type (+)= ''W1''
  AND     &B1 BETWEEN NVL(PHONE.date_from(+),&B1)
                   AND NVL(PHONE.date_to(+),&B1)
  and     a.lookup_type        = ''YES_NO''
  and     a.lookup_code        = nvl(PEOPLE.current_applicant_flag,''N'')
  and     a.application_id     = 800
  and     c.lookup_type        = ''YES_NO''
  and     c.lookup_code        = nvl(PEOPLE.current_employee_flag,''N'')
  and     c.application_id     = 800
  and     d.lookup_type        = ''REGISTERED_DISABLED''
  and     d.lookup_code        = nvl(PEOPLE.registered_disabled_flag,''N'')
  and     d.application_id     = 800
  and     e.lookup_type     (+)= ''HOME_OFFICE''
  and     e.lookup_code     (+)= PEOPLE.expense_check_send_to_address
  and     e.application_id  (+)= 800
  and     f.lookup_type     (+)= ''MAR_STATUS''
  and     f.lookup_code     (+)= PEOPLE.marital_status
  and     f.application_id  (+)= 800
  and     g.lookup_type     (+)= ''NATIONALITY''
  and     g.lookup_code     (+)= PEOPLE.nationality
  and     g.application_id  (+)= 800
  and     h.lookup_type     (+)= ''SEX''
  and     h.lookup_code     (+)= PEOPLE.sex
  and     h.application_id  (+)= 800
  and     i.lookup_type     (+)= ''TITLE''
  and     i.lookup_code     (+)= PEOPLE.title
  and     i.application_id  (+)= 800
  and     SES.session_id       = USERENV(''SESSIONID'')';
    --
    insert_route ('SEH_PER_PERSON_DETAILS',
                  'person details route',
                  l_text);
    --
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id,   2);
    --
    insert_user_entity ('PERSON_DETAILS',
                        'person details for an assignment');
    --
    -- insert database items for the route defined above:
    --
    -- Moved all the database items to SEH_PER_PERSON_DETAILS_PERF
    --
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                            +
    -- Route for person details : SEH_PER_PERSON_DETAILS_PERF     +
    --                                                            +
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := '/* Person details */
          per_all_people_f       PEOPLE
  ,       per_person_types       PTYPE
  ,       per_phones             PHONE
  ,       fnd_sessions           SES
  ,       hr_lookups             a
  ,       hr_lookups             c
  ,       hr_lookups             d
  ,       per_all_assignments_f  ASSIGN
  where   &B1 BETWEEN ASSIGN.effective_start_date
                   AND ASSIGN.effective_end_date
  and     ASSIGN.assignment_id = &B2
  and     PEOPLE.person_id     = ASSIGN.person_id
  and     &B1 BETWEEN PEOPLE.effective_start_date
                   AND PEOPLE.effective_end_date
  and     PTYPE.person_type_id = PEOPLE.person_type_id
  and     PHONE.parent_id (+) = PEOPLE.person_id
  AND     PHONE.parent_table (+)= ''PER_PEOPLE_F''
  and     PHONE.phone_type (+)= ''W1''
  AND     &B1 BETWEEN NVL(PHONE.date_from(+),&B1)
                   AND NVL(PHONE.date_to(+),&B1)
  and     a.lookup_type        = ''YES_NO''
  and     a.lookup_code        = nvl(PEOPLE.current_applicant_flag,''N'')
  and     a.application_id     = 800
  and     c.lookup_type        = ''YES_NO''
  and     c.lookup_code        = nvl(PEOPLE.current_employee_flag,''N'')
  and     c.application_id     = 800
  and     d.lookup_type        = ''REGISTERED_DISABLED''
  and     d.lookup_code        = nvl(PEOPLE.registered_disabled_flag,''N'')
  and     d.application_id     = 800
  and     SES.session_id       = USERENV(''SESSIONID'')';
    --
    insert_route ('SEH_PER_PERSON_DETAILS_PERF',
                  'person details route (performant version)',
                  l_text);
    --
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id,   2);
    --
    insert_user_entity ('PERSON_DETAILS_PERF',
                        'person details for an assignment (performant version)');
    --
    -- insert database items for the route defined above:
    --
    insert_database_item ('PER_PERSON_TYPE',
                          'PTYPE.user_person_type',
                          'Type of person, eg. employee, applicant, etc.',
                          'T',
                          'N');
    --
    insert_database_item ('PTU_PER_PERSON_TYPE',
                          'hr_person_type_usage_info.get_user_person_type(SES.effective_date, PEOPLE.person_id) user_person_type',
                          'Type of person, eg. employee, applicant, etc.',
                          'T',
                          'N');
    --
    insert_database_item ('PER_LAST_NAME',
                          'PEOPLE.last_name',
                          'The person''s last name',
                          'T',
                          'N');
    --
    insert_database_item ('PER_FIRST_NAME',
                          'PEOPLE.first_name',
                          'The person''s first name',
                          'T',
                          'Y');
    --
    insert_database_item ('PER_KNOWN_AS',
                          'PEOPLE.known_as',
                          'The person''s preferred name',
                          'T',
                          'Y');
    --
    insert_database_item ('PER_MIDDLE_NAMES',
                          'PEOPLE.middle_names',
                          'The person''s middle names',
                          'T',
                          'Y');
    --
    insert_database_item ('PER_FULL_NAME',
                          'PEOPLE.full_name',
                          'The person''s full name',
                          'T',
                          'Y');
    --
    insert_database_item ('PER_APPLICANT_NUMBER',
                          'PEOPLE.applicant_number',
                          'The person''s applicant number',
                          'T',
                          'Y');
    --
    insert_database_item ('PER_DATE_VERIFIED',
                          'PEOPLE.date_employee_data_verified',
         'The date the employee last verified his/her personal data',
                          'D',
                          'Y');
    --
    insert_database_item ('PER_DATE_OF_BIRTH',
                          'PEOPLE.date_of_birth',
                          'The person''s date of birth',
                          'D',
                          'Y');
    --
    insert_database_item ('PER_EMP_NUMBER',
                          'PEOPLE.employee_number',
                          'The person''s employee number',
                          'T',
                          'Y');
    --
    insert_database_item ('PER_NATIONAL_IDENTIFIER',
                          'PEOPLE.national_identifier',
                          'The person''s national identifier',
                          'T',
                          'Y');
    --
    insert_database_item ('PER_PREV_LAST_NAME',
                          'PEOPLE.previous_last_name',
                          'The person''s previous last name',
                          'T',
                          'Y');
    --
    insert_database_item ('PER_WORK_PHONE',
                          'NVL(PHONE.phone_number,PEOPLE.work_telephone)',
                          'The person''s work telephone number',
                          'T',
                          'Y');
    --
    insert_database_item ('PER_MAIL_DESTINATION',
                          'PEOPLE.expense_check_send_to_address',
                          'The person''s mail destination',
                          'T',
                          'Y');
    --
    insert_database_item ('PER_AGE',
          'TRUNC(MONTHS_BETWEEN(SES.EFFECTIVE_DATE, PEOPLE.date_of_birth)/12)',
                          'The person''s age',
                          'N',
                          'Y');
    --
    insert_database_item ('PER_CURRENT_APP',
                          'a.meaning',
                       'Whether the person is a current applicant (yes/no)',
                          'T',
                          'Y');
    --
    insert_database_item ('PER_CURRENT_EMP',
                          'c.meaning',
                 'Whether the person is a current employee (yes/no)',
                          'T',
                          'Y');
    --
    insert_database_item ('PER_DISABLED',
                          'd.meaning',
                          'Whether the person is disabled (yes/no)',
                          'T',
                          'Y');
    --
    insert_database_item ('PER_SEND_EXPENSES',
        		  'hr_general.decode_lookup(''HOME_OFFICE'',
        		      PEOPLE.expense_check_send_to_address)',
                    'Where to send the person''s expenses (home/office)',
                          'T',
                          'Y');
    --
    insert_database_item ('PER_MARITAL_STATUS',
                          'hr_general.decode_lookup(''MAR_STATUS'',
                         	 PEOPLE.marital_status)',
                          'The person''s maritial status',
                          'T',
                          'Y');
    --
    insert_database_item ('PER_NATIONALITY',
                          'hr_general.decode_lookup(''NATIONALITY'',
                          	PEOPLE.nationality)',
                          'The person''s nationality',
                          'T',
                          'Y');
    --
    insert_database_item ('PER_SEX',
                          'hr_general.decode_lookup(''SEX'',PEOPLE.sex)',
                          'The person''s sex',
                          'T',
                          'Y');
    --
    insert_database_item ('PER_TITLE',
                          'hr_general.decode_lookup(''TITLE'',PEOPLE.title)',
                          'The person''s title',
                          'T',
                          'Y');
    --
    insert_database_item ('PER_PREFIX',
                          'PEOPLE.pre_name_adjunct',
                          'The employee''s name prefix',
                          'T',
                          'Y');
    --
    insert_database_item ('PER_SUFFIX',
                          'PEOPLE.suffix',
                          'The employee''s name suffix',
                          'T',
                          'Y');
    --
    insert_database_item ('PER_1099R_NAME',
                          '''TRANSFER_LN=''||people.last_name||''TRANSFER_FN=''||
                            people.first_name||''TRANSFER_MN=''|| people.middle_names||
                            ''TRANSFER_SSN=''||people.national_identifier',
                          'Employee Details for 1099R',
                          'T',
                          'N');
    --
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                       +
    -- Route for person details : SEH_PER_PERSON_DETAILS_2   +
    --                                                       +
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := '/* Person details */
        per_all_assignments_f           ASSIGN
       ,per_all_people_f                PEOPLE
       ,hr_lookups                      HL1
       ,hr_lookups                      HL2
       ,hr_lookups                      HL3
       ,fnd_sessions                    SES
where   &B1 BETWEEN ASSIGN.effective_start_date
                 AND ASSIGN.effective_end_date
and     ASSIGN.assignment_id           = &B2
and     PEOPLE.person_id               = ASSIGN.person_id
and     &B1 BETWEEN PEOPLE.effective_start_date
                 AND PEOPLE.effective_end_date
and     HL1.application_id           (+)= 800
and     HL1.lookup_type              (+)= ''YES_NO''
and     HL1.lookup_code              (+)= nvl(PEOPLE.coord_ben_no_cvg_flag,''N'')
and     HL2.application_id           (+)= 800
and     HL2.lookup_type              (+)= ''YES_NO''
and     HL2.lookup_code              (+)= nvl(PEOPLE.dpdnt_vlntry_svce_flag,''N'')
and     HL3.application_id           (+)= 800
and     HL3.lookup_type              (+)= ''TOBACCO_USER''
and     HL3.lookup_code              (+)= PEOPLE.uses_tobacco_flag
and     SES.session_id                  = USERENV(''sessionid'')';
    --
    insert_route ('SEH_PER_PERSON_DETAILS_2',
                  'person details',
                  l_text);
    --
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id,   2);
    --
    insert_user_entity ('PERSON_DETAILS_2',
                        'person details 2');
    --
    -- insert database items for the route defined above:
    --
    -- Moved all the database items to PEOPLE.uses_tobacco_flag
    --
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                            +
    -- Route for person details : SEH_PER_PERSON_DETAILS_2_PERF   +
    --                                                            +
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := '/* Person details */
        per_all_assignments_f           ASSIGN
       ,per_all_people_f                PEOPLE
       ,fnd_sessions                    SES
where   &B1 BETWEEN ASSIGN.effective_start_date
                 AND ASSIGN.effective_end_date
and     ASSIGN.assignment_id           = &B2
and     PEOPLE.person_id               = ASSIGN.person_id
and     &B1 BETWEEN PEOPLE.effective_start_date
                 AND PEOPLE.effective_end_date
and     SES.session_id                  = USERENV(''sessionid'')';
    --
    insert_route ('SEH_PER_PERSON_DETAILS_2_PERF',
                  'person details (performant version)',
                  l_text);
    --
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id,   2);
    --
    insert_user_entity ('PERSON_DETAILS_2_PERF',
                        'person details 2 (performant version)');
    --
    -- insert database items for the route defined above:
    --
    insert_database_item ('PER_DPDNT_ADOPTION_DATE',
                          'PEOPLE.DPDNT_ADOPTION_DATE',
                          'Dependents Adoption Date',
                          'D',
                          'Y');
    --
    insert_database_item ('PER_RECEIPT_OF_DEATH_CERT_DATE',
                          'PEOPLE.RECEIPT_OF_DEATH_CERT_DATE',
                          'Date of receipt of the persons death certificate',
                          'D',
                          'Y');
    --
    insert_database_item ('PER_ORIGINAL_DATE_OF_HIRE',
                          'PEOPLE.ORIGINAL_DATE_OF_HIRE',
                          'Date the person was first hired',
                          'D',
                          'Y');
    --
    insert_database_item ('PER_DATE_OF_DEATH',
                          'PEOPLE.DATE_OF_DEATH',
                          'Persons date of death',
                          'D',
                          'Y');
    --
    insert_database_item ('PER_COORD_BEN_MED_PLN_NO',
                          'PEOPLE.COORD_BEN_MED_PLN_NO',
                          'Coordination of Benefits Medical Plan Number',
                          'T',
                          'Y');
    --
    insert_database_item ('PER_COORD_BEN_NO_CVG_FLAG',
                          'hr_general.decode_lookup(''YES_NO'',
                          	nvl(PEOPLE.coord_ben_no_cvg_flag,''N''))',
                          'Coordination of Benefits No Other Coverage',
                          'T',
                          'Y');
    --
    insert_database_item ('PER_DPDNT_VLNTRY_SVCE_FLAG',
                          'hr_general.decode_lookup(''YES_NO'',
                           	nvl(PEOPLE.dpdnt_vlntry_svce_flag,''N''))',
                          'Dependant on voluntary service',
                          'T',
                          'Y');
    --
    insert_database_item ('PER_BENEFIT_GROUP_ID',
                          'PEOPLE.BENEFIT_GROUP_ID',
                          'Benefit Group ID',
                          'N',
                          'Y');
    --
    insert_database_item ('PER_USES_TOBACCO_FLAG',
                          'hr_general.decode_lookup(''TOBACCO_USER'',
                          	PEOPLE.uses_tobacco_flag)',
                          'Uses Tobacco Flag',
                          'T',
                          'Y');
    --
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                               +
    -- Route for person period of service : SEH_EMP_PERSON_SERVICE_1 +
    --                                                               +
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    -- This route has been split into 2 for performance purposes.  The date
    -- DB items are used in the payroll formulae.
    --
    l_text := '/* Person current period of service date details */
        per_all_assignments_f                   ASSIGN
,       per_periods_of_service                  SERVICE
where   &B1 BETWEEN ASSIGN.effective_start_date
                 AND ASSIGN.effective_end_date
and     ASSIGN.assignment_id                  = &B2
and     SERVICE.period_of_Service_id       (+)= ASSIGN.period_of_service_id';
    --
    insert_route ('SEH_EMP_PERSON_SERVICE_1',
                  'employee person period of service route 1 (date details)',
                  l_text);
    --
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id,   2);
    --
    insert_user_entity ('EMPLOYEE_PERSON_SERVICE_DETAILS_1',
                        'employee person current service date details');
    --
    -- insert database items for the route defined above:
    --
    insert_database_item ('EMP_HIRE_DATE',
                          'SERVICE.date_start',
                          'The employee''s hire date',
                          'D',
                          'Y');
    --
    insert_database_item ('EMP_TERM_DATE',
                          'SERVICE.actual_termination_date',
                          'The employee''s termination date',
                          'D',
                          'Y');
    --
    insert_database_item ('EMP_LAST_PROCESS_DATE',
                          'SERVICE.last_standard_process_date',
                          'The date the employee was last processed',
                          'D',
                          'Y');
    --
    insert_database_item ('EMP_PROJ_TERM_DATE',
                          'SERVICE.projected_termination_date',
                          'The employee''s projected termination date',
                          'D',
                          'Y');
    --
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                               +
    -- Route for person period of service : SEH_EMP_PERSON_SERVICE_2 +
    --                                                               +
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := '/* Person current period of service other details */
        per_all_assignments_f                   ASSIGN
,       per_periods_of_service                  SERVICE
,       per_all_people_f                        PEOPLE
,       hr_lookups                              LOOK1
where   &B1 BETWEEN ASSIGN.effective_start_date
                 AND ASSIGN.effective_end_date
and     ASSIGN.assignment_id                  = &B2
and     SERVICE.period_of_Service_id       (+)= ASSIGN.period_of_service_id
and     LOOK1.lookup_code                  (+)= SERVICE.leaving_reason
and     LOOK1.lookup_type                  (+)= ''LEAV_REAS''
and     LOOK1.application_id               (+)= 800
and     PEOPLE.person_id           (+)= SERVICE.termination_accepted_person_id
and     &B1 between nvl (PEOPLE.effective_start_date, &B1)
                 and nvl (PEOPLE.effective_end_date, &B1)';
    --
    insert_route ('SEH_EMP_PERSON_SERVICE_2',
                  'employee person period of service route (other details)',
                  l_text);
    --
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id,   2);
    --
    insert_user_entity ('EMPLOYEE_PERSON_SERVICE_DETAILS_2',
                        'employee person current service other details');
    --
    -- insert database items for the route defined above:
    --
    insert_database_item ('EMP_LEAVING_REASON',
                          'LOOK1.meaning',
                          'The reason the employee left',
                          'T',
                          'Y');
    --
    insert_database_item ('EMP_TERM_ACCEPTED_BY',
                          'PEOPLE.full_name',
                          'The person who accepted the employee''s notice',
                          'T',
                          'Y');
    --
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                           +
    -- Route for person address details : SEH_PER_PERSON_ADDRESS +
    --                                                           +
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := '/* Person address details */
	per_all_assignments_f  ASSIGN
,	per_addresses          ADDR
,	fnd_territories_tl     a
where	&B1 BETWEEN ASSIGN.effective_start_date
                 AND ASSIGN.effective_end_date
and     ASSIGN.assignment_id   = &B2
and	ADDR.person_id      (+)= ASSIGN.person_id
and	ADDR.primary_flag   (+)= ''Y''
and     &B1 BETWEEN nvl(ADDR.date_from, &B1)
                 AND nvl(ADDR.date_to, &B1)
and	a.territory_code    (+)= ADDR.country
and 	a.language          (+)= userenv(''LANG'')';
    --
    insert_route ('SEH_PER_PERSON_ADDRESS',
                  'employee person address route',
                  l_text);
    --
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id,   2);
    --
    insert_user_entity ('EMPLOYEE_PERSON_ADDRESS_DETAILS',
                        'employee person address details');
    --
    -- insert database items for the route defined above:
    --
    --
    insert_database_item ('PER_ADR_DATE_FROM',
                          'ADDR.date_from',
     'The first date on which the person can be contacted at this address',
                          'D',
                          'Y');
    --
    insert_database_item ('PER_ADR_DATE_TO',
                          'ADDR.date_to',
        'The last date on which the person can be contacted at this address',
                          'D',
                          'Y');
    --
    insert_database_item ('PER_ADR_LINE_1',
                          'ADDR.address_line1',
                          'The first line of the person''s address',
                          'T',
                          'Y');
    --
    insert_database_item ('PER_ADR_LINE_2',
                          'ADDR.address_line2',
                          'The second line of the person''s address',
                          'T',
                          'Y');
    --
    insert_database_item ('PER_ADR_LINE_3',
                          'ADDR.address_line3',
                          'The third line of the person''s address',
                          'T',
                          'Y');
    --
    insert_database_item ('PER_ADR_CITY',
                          'ADDR.town_or_city',
                          'The name of the person''s town or city',
                          'T',
                          'Y');
    --
    insert_database_item ('PER_ADR_REGION_1',
                          'ADDR.region_1',
                          'The first line of the person''s region',
                          'T',
                          'Y');
    --
    insert_database_item ('PER_ADR_REGION_2',
                          'ADDR.region_2',
                          'The second line of the person''s region',
                          'T',
                          'Y');
    --
    insert_database_item ('PER_ADR_REGION_3',
                          'ADDR.region_3',
                          'The third line of the person''s region',
                          'T',
                          'Y');
    --
    insert_database_item ('PER_ADR_POSTAL_CODE',
                          'ADDR.postal_code',
                          'The person''s postal code',
                          'T',
                          'Y');
    --
    insert_database_item ('PER_ADR_PHONE_1',
                          'ADDR.TELEPHONE_NUMBER_1',
                          'The person''s first contact number',
                          'T',
                          'Y');
    --
    insert_database_item ('PER_ADR_PHONE_2',
                          'ADDR.TELEPHONE_NUMBER_2',
                          'The person''s second contact number',
                          'T',
                          'Y');
    --
    insert_database_item ('PER_ADR_PHONE_3',
                          'ADDR.TELEPHONE_NUMBER_3',
                          'The person''s third contact number',
                          'T',
                          'Y');
    --
    insert_database_item ('PER_ADR_COUNTRY',
                          'a.territory_short_name',
                          'The name of the person''s country',
                          'T',
                          'Y');
    --
    insert_database_item ('PER_ADR_COUNTRY_CODE',
                          'a.territory_code',
                          '** Person''s country code **',
                          'T',
                          'Y');
    --
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                              +
    -- Route for person assignment details : SEH_ASS_PERSON_DETAILS +
    --                                                              +
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --

   l_text := '/* Person assignment details */
        per_grades                       GRADE
,       per_jobs                         JOB
,       per_assignment_status_types      AST
,       pay_all_payrolls_f               PAYROLL
,       hr_locations                     LOC
,       hr_all_organization_units        ORG
,       pay_people_groups                GRP
,       per_all_vacancies                VAC
,       per_all_people_f                 PEOPLE1
,       per_all_people_f                 PEOPLE2
,       hr_all_positions_f               POS1
,       hr_all_positions_f               POS2
,       hr_all_positions_f               POS3
,       hr_lookups                       HR1
,       hr_lookups                       HR2
,       hr_lookups                       HR4
,       hr_lookups                       HR5
,       hr_lookups                       HR6
,       hr_lookups                       HR7
,       hr_lookups                       FND1
,       hr_lookups                       FND2
,       per_all_assignments_f            ASSIGN
where   &B1 BETWEEN ASSIGN.effective_start_date
                 AND ASSIGN.effective_end_date
and     &B1 BETWEEN POS1.effective_start_date(+)
                 AND POS1.effective_end_date(+)
and     &B1 BETWEEN POS2.effective_start_date(+)
                 AND POS2.effective_end_date(+)
and     &B1 BETWEEN POS3.effective_start_date(+)
                 AND POS3.effective_end_date(+)
and     ASSIGN.assignment_id           = &B2
and     GRADE.grade_id              (+)= ASSIGN.grade_id
and     JOB.job_id                  (+)= ASSIGN.job_id
and     AST.assignment_status_type_id  = ASSIGN.assignment_status_type_id
and     PAYROLL.payroll_id          (+)= ASSIGN.payroll_id
and     &B1 between nvl (PAYROLL.effective_start_date, &B1)
                 and nvl (PAYROLL.effective_end_date, &B1)
and     LOC.location_id             (+)= ASSIGN.location_id
and     ORG.organization_id            = ASSIGN.organization_id
and     GRP.people_group_id         (+)= ASSIGN.people_group_id
and     VAC.vacancy_id              (+)= ASSIGN.vacancy_id
and     HR1.lookup_code                = ASSIGN.assignment_type
and     HR1.lookup_type                = ''EMP_APL''
and     HR1.application_id             = 800
and     HR2.lookup_code             (+)= ASSIGN.probation_unit
and     HR2.lookup_type             (+)= ''UNITS''
and     HR2.application_id          (+)= 800
and     FND1.lookup_code               = ASSIGN.primary_flag
and     FND1.lookup_type               = ''YES_NO''
and     FND1.application_id            = 800
and     FND2.lookup_code            (+)= ASSIGN.manager_flag
and     FND2.lookup_type            (+)= ''YES_NO''
and     FND2.application_id         (+)= 800
and     PEOPLE1.person_id           (+)= ASSIGN.recruiter_id
and     PEOPLE2.person_id           (+)= ASSIGN.supervisor_id
and     POS1.position_id            (+)= ASSIGN.position_id
and     HR4.lookup_code             (+)= POS1.frequency
and     HR4.lookup_type             (+)= ''FREQUENCY''
and     HR4.application_id          (+)= 800
and     HR5.lookup_code             (+)= ASSIGN.employment_category
and     HR5.lookup_type             (+)= ''EMP_CAT''
and     HR5.application_id          (+)= 800
and     HR6.lookup_code             (+)= ASSIGN.perf_review_period_frequency
and     HR6.lookup_type             (+)= ''FREQUENCY''
and     HR6.application_id          (+)= 800
and     HR7.lookup_code             (+)= ASSIGN.sal_review_period_frequency
and     HR7.lookup_type             (+)= ''FREQUENCY''
and     HR7.application_id          (+)= 800
and     POS2.position_id            (+)= POS1.successor_position_id
and     POS3.position_id            (+)= POS1.relief_position_id';
    --
    insert_route ('SEH_ASS_PERSON_DETAILS',
                  'person assignment route',
                  l_text);
    --
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id,   2);
    --
    insert_user_entity ('PERSON_ASSIGNMENT_DETAILS',
                        'person assignment details');
    --
    -- insert database items for the route defined above:
    --
    --
    -- Moved all the database items to SEH_ASS_PERSON_DETAILS_PERF
    --
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                                   +
    -- Route for person assignment details : SEH_ASS_PERSON_DETAILS_PERF +
    --                                                                   +
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --

   l_text := '/* Person assignment details */
        per_grades                       GRADE
,       per_jobs                         JOB
,       per_assignment_status_types      AST
,       pay_all_payrolls_f               PAYROLL
,       hr_locations                     LOC
,       hr_all_organization_units        ORG
,       pay_people_groups                GRP
,       per_all_vacancies                VAC
,       per_all_people_f                 PEOPLE1
,       per_all_people_f                 PEOPLE2
,       hr_all_positions_f               POS1
,       hr_all_positions_f               POS2
,       hr_all_positions_f               POS3
,       hr_lookups                       HR1
,       hr_lookups                       FND1
,       per_all_assignments_f            ASSIGN
where   &B1 BETWEEN ASSIGN.effective_start_date
                 AND ASSIGN.effective_end_date
and     &B1 BETWEEN POS1.effective_start_date(+)
                 AND POS1.effective_end_date(+)
and     &B1 BETWEEN POS2.effective_start_date(+)
                 AND POS2.effective_end_date(+)
and     &B1 BETWEEN POS3.effective_start_date(+)
                 AND POS3.effective_end_date(+)
and     ASSIGN.assignment_id           = &B2
and     GRADE.grade_id              (+)= ASSIGN.grade_id
and     JOB.job_id                  (+)= ASSIGN.job_id
and     AST.assignment_status_type_id  = ASSIGN.assignment_status_type_id
and     PAYROLL.payroll_id          (+)= ASSIGN.payroll_id
and     &B1 between nvl (PAYROLL.effective_start_date, &B1)
                 and nvl (PAYROLL.effective_end_date, &B1)
and     LOC.location_id             (+)= ASSIGN.location_id
and     ORG.organization_id            = ASSIGN.organization_id
and     GRP.people_group_id         (+)= ASSIGN.people_group_id
and     VAC.vacancy_id              (+)= ASSIGN.vacancy_id
and     HR1.lookup_code                = ASSIGN.assignment_type
and     HR1.lookup_type                = ''EMP_APL''
and     HR1.application_id             = 800
and     FND1.lookup_code               = ASSIGN.primary_flag
and     FND1.lookup_type               = ''YES_NO''
and     FND1.application_id            = 800
and     PEOPLE1.person_id           (+)= ASSIGN.recruiter_id
and     PEOPLE2.person_id           (+)= ASSIGN.supervisor_id
and     POS1.position_id            (+)= ASSIGN.position_id
and     POS2.position_id            (+)= POS1.successor_position_id
and     POS3.position_id            (+)= POS1.relief_position_id';
    --
    insert_route ('SEH_ASS_PERSON_DETAILS_PERF',
                  'person assignment route (performant version)',
                  l_text);
    --
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id,   2);
    --
    insert_user_entity ('PERSON_ASSIGNMENT_DETAILS_PERF',
                        'person assignment details ( performant version )');
    --
    -- insert database items for the route defined above:
    --
    --
    insert_database_item ('ASG_GRADE',
                          'GRADE.name',
                          'The employee''s grade',
                          'T',
                          'Y');
    --
    insert_database_item ('ASG_GRADE_DATE_FROM',
                          'GRADE.date_from',
          'The date from which this assignment grade information is effective',
                          'D',
                          'Y');
    --
    insert_database_item ('ASG_GRADE_DATE_TO',
                          'GRADE.date_to',
           'The date to which this assignment grade information is effective',
                          'D',
                          'Y');
    --
    insert_database_item ('ASG_JOB',
                          'JOB.name',
                          'The employee''s job',
                          'T',
                          'Y');
    --
    insert_database_item ('ASG_JOB_DATE_FROM',
                          'JOB.date_from',
            'The date from which this assignment job information is effective',
                          'D',
                          'Y');
    --
    insert_database_item ('ASG_JOB_DATE_TO',
                          'JOB.date_to',
             'The date to which this assignment job information is effective',
                          'D',
                          'Y');
    --
    insert_database_item ('ASG_STATUS',
                          'AST.user_status',
                          'The primary status for the assignment',
                          'T',
                          'N');
    --
    insert_database_item ('ASG_PAYROLL',
                          'PAYROLL.payroll_name',
                          'The employee''s payroll',
                          'T',
                          'Y');
    --
    insert_database_item ('ASG_LOCATION',
                          'LOC.location_code',
                          'The employee''s location',
                          'T',
                          'Y');
    --
    insert_database_item ('ASG_LOC_INACTIVE_DATE',
                          'LOC.inactive_date',
                    'The date to which the location information is effective',
                          'D',
                          'Y');
    --
    insert_database_item ('ASG_ORG',
                          'ORG.name',
                          'The employee''s organization',
                          'T',
                          'N');
    --
    insert_database_item ('ASG_ORG_DATE_FROM',
                          'ORG.date_from',
       'The date from which assignment organization information is effective',
                          'D',
                          'N');
    --
    insert_database_item ('ASG_ORG_DATE_TO',
                          'ORG.date_to',
         'The date to which assignment organization information is effective',
                          'D',
                          'Y');
    --
    insert_database_item ('ASG_GROUP',
                          'GRP.group_name',
                          'The employee''s group',
                          'T',
                          'Y');
    --
    insert_database_item ('ASG_VACANCY',
                          'VAC.name',
                          'The name of the vacancy applied for',
                          'T',
                          'Y');
    --
    insert_database_item ('ASG_TYPE',
                          'HR1.meaning',
                         'Whether this assignment is an employee or applicant',
                          'T',
                          'Y');
    --
    insert_database_item ('ASG_PROB_UNITS',
                          'hr_general.decode_lookup(''UNITS'',
                          	ASSIGN.probation_unit)',
                          'The units of the assignment''s probation period',
                          'T',
                          'Y');
    --
    insert_database_item ('ASG_PRIMARY',
                          'FND1.meaning',
                	  'Whether this is the employee''s primary assignment (yes/no)',
                          'T',
                          'N');
    --
    insert_database_item ('ASG_MANAGER',
                          'hr_general.decode_lookup(''YES_NO'',
                          		ASSIGN.manager_flag)',
               'Whether the assignment is a managerial assignment (yes/no)',
                          'T',
                          'Y');
    --
    insert_database_item ('ASG_POSITION',
                          'POS1.name',
                          'The employee''s position',
                          'T',
                          'Y');
    --
    insert_database_item ('ASG_POS_DATE_FROM',
                          'POS1.date_effective',
      'The date from which this assignment position information is effective',
                          'D',
                          'Y');
    --
    insert_database_item ('ASG_POS_DATE_TO',
                          'POS1.date_end',
        'The date to which this assignment position information is effective',
                          'D',
                          'Y');
    --
    insert_database_item ('ASG_POS_HOURS',
                          'POS1.working_hours',
                     'The standard number of working hours for the position',
                          'N',
                          'Y');
    --
    insert_database_item ('ASG_POS_START_TIME',
                          'POS1.time_normal_start',
                       'The standard start time for the assignment position',
                          'T',
                          'Y');
    --
    insert_database_item ('ASG_POS_END_TIME',
                          'POS1.time_normal_finish',
                          'The standard end time for the assignment position',
                          'T',
                          'Y');
    --
    insert_database_item ('ASG_POS_PROB_PERIOD',
                          'POS1.probation_period',
                          'The probation period for the assignment position',
                          'N',
                          'Y');
    --
    insert_database_item ('ASG_POS_FREQ',
                          'hr_general.decode_lookup(''FREQUENCY'',
                          	POS1.frequency)',
       'The frequency for which the assignment position''s hours is measured',
                          'T',
                          'Y');
    --
    insert_database_item ('ASG_SUCCESSOR',
                          'POS2.name',
                      'The position name that will succeed into this position',
                          'T',
                          'Y');
    --
    insert_database_item ('ASG_RELIEF',
                          'POS3.name',
             'The relief position if the current position hoilder is absent',
                          'T',
                          'Y');
    --
    insert_database_item ('ASG_REC_FULL_NAME',
                          'PEOPLE1.full_name',
                          'The full name for the recruiter',
                          'T',
                          'Y');
    --
    insert_database_item ('ASG_SUP_FULL_NAME',
                          'PEOPLE2.full_name',
                          'The full name for the supervisor',
                          'T',
                          'Y');
    --
    -- Some salary admin DB items:
    --
    insert_database_item ('ASG_EMPLOYMENT_CATEGORY',
                          'hr_general.decode_lookup(''EMP_CAT'',
                          	ASSIGN.employment_category)',
                          'The employment category for the assignment',
                          'T',
                          'Y');
    --
    insert_database_item ('ASG_ASSIGNMENT_CATEGORY',
                          'decode(ASSIGN.employment_category
                                 ,''E'', hr_general.decode_lookup(''EMP_CAT'',
                          	         ASSIGN.employment_category)
                                 ,''C'', hr_general.decode_lookup(''CWK_ASG_CATEGORY'',
                                         ASSIGN.employment_category))',
                          'The assignment category for the assignment',
                          'T',
                          'Y');
    --
    insert_database_item ('ASG_PERFORMANCE_REVIEW_FREQUENCY',
                          'hr_general.decode_lookup(''FREQUENCY'',
                          	ASSIGN.perf_review_period_frequency)',
                 'The performance review frequency for the assignment',
                          'T',
                          'Y');
    --
    insert_database_item ('ASG_SALARY_REVIEW_FREQUENCY',
                          'hr_general.decode_lookup(''FREQUENCY'',
                          	ASSIGN.sal_review_period_frequency)',
                          'The salary review frequency for the assignment',
                          'T',
                          'Y');
    --
    -- BIS DBitems
    --
    insert_database_item ('ASG_PRIMARY_CODE',
                          'FND1.lookup_code',
                          'Primary Code',
                          'T',
                          'N');
    --
    insert_user_entity ('BIS_PERSON_ASSIGNMENT_DETAILS_PERF',
                        'person assignment details',
                        'Y');
    --
    insert_database_item ('ASG_EMPLOYMENT_CATEGORY_CODE',
                          'ASSIGN.employment_category',
                          'Employment Category Code',
                          'T',
                          'Y');
    --
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                                +
    -- Route for person assignment details : SEH_ASS_PERSON_DETAILS_2 +
    --                                                                +
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    -- Split from above route to improve performance of key DB items
    --
    --
    l_text := '/* Person assignment details 2 */
per_all_assignments_f         ASSIGN,
hr_lookups                    HR3,
hr_lookups                    HR4
where &B1 BETWEEN ASSIGN.effective_start_date
               AND ASSIGN.effective_end_date
and     ASSIGN.assignment_id                = &B2
and     HR3.application_id               (+)= 800
and     HR3.lookup_code                  (+)= ASSIGN.frequency
and     HR3.lookup_type                  (+)= ''FREQUENCY''
and     HR4.application_id               (+)= 800
and     HR4.lookup_code                  (+)= ASSIGN.change_reason
and     HR4.lookup_type                  (+)= ''EMP_ASSIGN_REASON''';
    --
    insert_route ('SEH_ASS_PERSON_DETAILS_2',
                  'person assignment route 2',
                  l_text);
    --
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id,   2);
    --
    insert_user_entity ('PERSON_ASSIGNMENT_DETAILS_2',
                        'person assignment details 2');
    --
    -- insert database items for the route defined above:
    --
    --
    insert_database_item ('ASG_DATE_FROM',
                          'ASSIGN.effective_start_date',
               'The date from which this assignment information is effective',
                          'D',
                          'N');
    --
    insert_database_item ('ASG_DATE_TO',
                          'ASSIGN.effective_end_date',
                'The date to which this assignment information is effective',
                          'D',
                          'N');
    --
    insert_database_item ('ASG_INT_ADDR_LINE',
                          'ASSIGN.internal_address_line',
                          'The internal address of the assignment',
                          'T',
                          'Y');
    --
    insert_database_item ('ASG_ASSIGNMENT_SEQUENCE',
                          'ASSIGN.assignment_sequence',
                          'This is used as a default for assignment number',
                          'N',
                          'N');
    --
    insert_database_item ('ASG_NUMBER',
                          'ASSIGN.assignment_number',
                          'The assignment number',
                          'T',
                          'Y');
    --
    insert_database_item ('ASG_PROB_END_DATE',
                          'ASSIGN.date_probation_end',
                          'The probation period end date',
                          'D',
                          'Y');
    --
    insert_database_item ('ASG_PROB_PERIOD',
                          'ASSIGN.probation_period',
                          'The assignment''s probation period',
                          'N',
                          'Y');
    --
    insert_database_item ('ASG_HOURS',
                          'ASSIGN.normal_hours',
                     'The standard number of working hours for the assignment',
                          'N',
                          'Y');
    --
    insert_database_item ('ASG_START_TIME',
                          'ASSIGN.time_normal_start',
                          'The standard start time for the assignment',
                          'T',
                          'Y');
    --
    insert_database_item ('ASG_END_TIME',
                          'ASSIGN.time_normal_finish',
                          'The standard end time for the assignment',
                          'T',
                          'Y');
    --
    insert_database_item ('ASG_PERFORMANCE_REVIEW_PERIOD',
                          'ASSIGN.perf_review_period',
                          'The performance review period for the assignment',
                          'N',
                          'Y');
    --
    insert_database_item ('ASG_SALARY_REVIEW_PERIOD',
                          'ASSIGN.sal_review_period',
                          'The salary review period for the assignment',
                          'N',
                          'Y');
    --
    insert_database_item ('ASG_FREQ',
                          'HR3.meaning',
          'The frequency for which the assignment working hours are measured',
                          'T',
                          'Y');
    --
    insert_database_item ('ASG_CHANGE_REASON',
                          'HR4.meaning',
                          'The change reason for the assignment',
                          'T',
                          'Y');
    --
    -- BIS DBitems
    --
    insert_user_entity ('BIS_PERSON_ASSIGNMENT_DETAILS_2',
                        'person assignment details 2',
                        'Y');
    --
    insert_database_item ('ASG_FREQ_CODE',
                          'HR3.lookup_code',
                          'Assignment Working Hours Frequency Code',
                          'T',
                          'Y');
    --
    --
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                                +
    -- Route for person assignment details : SEH_ASS_PERSON_DETAILS_3 +
    --                                                                +
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := '/* Person assignment details 3 */
        per_all_assignments_f           ASSIGN
       ,hr_lookups                      HR1
       ,hr_lookups                      HR2
where   &B1 BETWEEN ASSIGN.effective_start_date
                 AND ASSIGN.effective_end_date
and     ASSIGN.assignment_id           = &B2
and     HR1.application_id          (+) = 800
and     HR1.lookup_type             (+) = ''YES_NO''
and     HR1.lookup_code             (+) = nvl(ASSIGN.LABOUR_UNION_MEMBER_FLAG,''N'')
and     HR2.application_id          (+) = 800
and     HR2.lookup_type             (+) = ''BARGAINING_UNIT_CODE''
and     HR2.lookup_code             (+) = ASSIGN.BARGAINING_UNIT_CODE';
    --
    insert_route ('SEH_ASS_PERSON_DETAILS_3',
                  'person assignment route 3',
                  l_text);
    --
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id,   2);
    --
    insert_user_entity ('PERSON_ASSIGNMENT_DETAILS_3',
                        'person assignment details 3');
    --
    -- insert database items for the route defined above:
    --
    -- moved the database items to SEH_ASS_PERSON_DETAILS_3_PERF
    --
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                                     +
    -- Route for person assignment details : SEH_ASS_PERSON_DETAILS_3_PERF +
    --                                                                     +
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := '/* Person assignment details 3 */
        per_all_assignments_f           ASSIGN
where   &B1 BETWEEN ASSIGN.effective_start_date
                 AND ASSIGN.effective_end_date
and     ASSIGN.assignment_id           = &B2';
    --
    insert_route ('SEH_ASS_PERSON_DETAILS_3_PERF',
                  'person assignment route 3 (performant version)',
                  l_text);
    --
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id,   2);
    --
    insert_user_entity ('PERSON_ASSIGNMENT_DETAILS_3_PERF',
                        'person assignment details 3 (performant version)');
    --
    -- insert database items for the route defined above:
    --
    insert_database_item ('ASG_LABOUR_UNION_MEMBER_FLAG',
                          'hr_general.decode_lookup(''YES_NO'',
                          	nvl(ASSIGN.LABOUR_UNION_MEMBER_FLAG,''N''))',
                          'Labour Union Member',
                          'T',
                          'Y');
    --
    insert_database_item ('ASG_BARGAINING_UNIT_CODE',
                          'hr_general.decode_lookup(''BARGAINING_UNIT_CODE'',
                          	ASSIGN.BARGAINING_UNIT_CODE)',
                          'Bargaining Unit Code',
                          'T',
                          'Y');
    --
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                     +
    -- Route for contact details : SEH_CON_PERSON_DETAILS  +
    --                                                     +
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := '/* contact person details */
        per_all_assignments_f                ASSIGN
,       per_contact_relationships            CONTACT
,       per_all_people_f                     PEOPLE
,	per_person_types                     PTYPE
,       per_phones                           PHONE
,       fnd_sessions                         SES
,	hr_lookups                           a
,	hr_lookups                           c
,	hr_lookups                           d
,       hr_lookups                           f
,       hr_lookups                           g
,       hr_lookups                           h
,       hr_lookups                           i
,       hr_lookups                           j
where   &B1 BETWEEN ASSIGN.effective_start_date
                 AND ASSIGN.effective_end_date
and     ASSIGN.assignment_id               = &B2
and     CONTACT.person_id               (+)= ASSIGN.person_id
and     CONTACT.primary_contact_flag    (+)= ''Y''
and     PEOPLE.person_id                (+)= CONTACT.contact_person_id
and     &B1 BETWEEN nvl (PEOPLE.effective_start_date, &B1)
                 AND nvl (PEOPLE.effective_end_date, &B1)
and	PTYPE.person_type_id (+)= PEOPLE.person_type_id
and     PHONE.parent_id (+) = PEOPLE.person_id
and     PHONE.parent_table (+)= ''PER_ALL_PEOPLE_F''
and     PHONE.phone_type (+)= ''W1''
and     &B1 BETWEEN NVL(PHONE.date_from, &B1)
                 AND NVL(PHONE.date_to, &B1)
and	a.lookup_type           = ''YES_NO''
and	a.lookup_code           = nvl(PEOPLE.current_applicant_flag,''N'')
and     a.application_id        = 800
and	c.lookup_type           = ''YES_NO''
and	c.lookup_code           = nvl(PEOPLE.current_employee_flag,''N'')
and     c.application_id        = 800
and	d.lookup_type           = ''YES_NO''
and	d.lookup_code           = nvl(PEOPLE.registered_disabled_flag,''N'')
and     d.application_id        = 800
and     f.lookup_type        (+)= ''MAR_STATUS''
and     f.lookup_code        (+)= PEOPLE.marital_status
and     f.application_id     (+)= 800
and     g.lookup_type        (+)= ''NATIONALITY''
and     g.lookup_code        (+)= PEOPLE.nationality
and     g.application_id     (+)= 800
and     h.lookup_type        (+)= ''SEX''
and     h.lookup_code        (+)= PEOPLE.sex
and     h.application_id     (+)= 800
and     i.lookup_type        (+)= ''TITLE''
and     i.lookup_code        (+)= PEOPLE.title
and     i.application_id     (+)= 800
and     j.lookup_type        (+)= ''CONTACT''
and     j.lookup_code        (+)= CONTACT.contact_type
and     j.application_id     (+)= 800
and     SES.session_id          = USERENV(''SESSIONID'')';
    --
    insert_route ('SEH_CON_PERSON_DETAILS',
                  'assignment contact details',
                  l_text);
    --
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id,   2);
    --
    insert_user_entity ('ASSIGNMENT_CONTACT_DETAILS',
                        'assignment contact details');
    --
    -- insert database items for the route defined above:
    --
    --
    -- Database items have been moved to SEH_CON_PERSON_DETAILS_PERF
    --
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                          +
    -- Route for contact details : SEH_CON_PERSON_DETAILS_PERF  +
    --                                                          +
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := '/* contact person details */
        per_all_assignments_f                ASSIGN
,       per_contact_relationships            CONTACT
,       per_all_people_f                     PEOPLE
,	per_person_types                     PTYPE
,       per_phones                           PHONE
,       fnd_sessions                         SES
,	hr_lookups                           a
,	hr_lookups                           c
,	hr_lookups                           d
where   &B1 BETWEEN ASSIGN.effective_start_date
                 AND ASSIGN.effective_end_date
and     ASSIGN.assignment_id               = &B2
and     CONTACT.person_id               (+)= ASSIGN.person_id
and     CONTACT.primary_contact_flag    (+)= ''Y''
and     PEOPLE.person_id                (+)= CONTACT.contact_person_id
and     &B1 BETWEEN nvl (PEOPLE.effective_start_date, &B1)
                 AND nvl (PEOPLE.effective_end_date, &B1)
and	PTYPE.person_type_id (+)= PEOPLE.person_type_id
and     PHONE.parent_id (+) = PEOPLE.person_id
and     PHONE.parent_table (+)= ''PER_ALL_PEOPLE_F''
and     PHONE.phone_type (+)= ''W1''
and     &B1 BETWEEN NVL(PHONE.date_from, &B1)
                 AND NVL(PHONE.date_to, &B1)
and	a.lookup_type           = ''YES_NO''
and	a.lookup_code           = nvl(PEOPLE.current_applicant_flag,''N'')
and     a.application_id        = 800
and	c.lookup_type           = ''YES_NO''
and	c.lookup_code           = nvl(PEOPLE.current_employee_flag,''N'')
and     c.application_id        = 800
and	d.lookup_type           = ''YES_NO''
and	d.lookup_code           = nvl(PEOPLE.registered_disabled_flag,''N'')
and     d.application_id        = 800
and     SES.session_id          = USERENV(''SESSIONID'')';
    --
    insert_route ('SEH_CON_PERSON_DETAILS_PERF',
                  'assignment contact details (performant version)',
                  l_text);
    --
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id,   2);
    --
    insert_user_entity ('ASSIGNMENT_CONTACT_DETAILS_PERF',
                        'assignment contact details (performant version)');
    --
    -- insert database items for the route defined above:
    --
    --
    --
    insert_database_item ('CON_NATIONAL_IDENTIFIER',
                          'PEOPLE.national_identifier',
                          'The contacts national identifier',
                          'T',
                          'Y');
    --
    insert_database_item ('CON_START_DATE',
                          'PEOPLE.effective_start_date',
                'The date from which this contact information is effective',
                          'D',
                          'Y');
    --
    insert_database_item ('CON_END_DATE',
                          'PEOPLE.effective_end_date',
                  'The date to which this contact information is effective',
                          'D',
                          'Y');
    --
    insert_database_item ('CON_FULL_NAME',
                          'PEOPLE.full_name',
                          'The contact''s full name',
                          'T',
                          'Y');
    --
    insert_database_item ('CON_LAST_NAME',
                          'PEOPLE.last_name',
                          'The contact''s last name',
                          'T',
                          'Y');
    --
    insert_database_item ('CON_FIRST_NAME',
                          'PEOPLE.first_name',
                          'The contact''s first name',
                          'T',
                          'Y');
    --
    insert_database_item ('CON_KNOWN_AS',
                          'PEOPLE.known_as',
                          'The contact''s preferred name',
                          'T',
                          'Y');
    --
    insert_database_item ('CON_MIDDLE_NAMES',
                          'PEOPLE.middle_names',
                          'The contact''s middle names',
                          'T',
                          'Y');
    --
    insert_database_item ('CON_APP_NUMBER',
                          'PEOPLE.applicant_number',
                          'The contact''s applicant number',
                          'T',
                          'Y');
    --
    insert_database_item ('CON_DATE_OF_BIRTH',
                          'PEOPLE.date_of_birth',
                          'The contact''s date of birth',
                          'D',
                          'Y');
    --
    insert_database_item ('CON_EMP_NUMBER',
                          'PEOPLE.employee_number',
                          'The contact''s employee number',
                          'T',
                          'Y');
    --
    insert_database_item ('CON_WORK_PHONE',
                          'NVL(PHONE.phone_number,PEOPLE.work_telephone)',
                          'The contact''s work telephone number',
                          'T',
                          'Y');
    --
    insert_database_item ('CON_AGE',
         'TRUNC(MONTHS_BETWEEN(SES.EFFECTIVE_DATE, PEOPLE.date_of_birth)/12)',
                          'The contact''s age',
                          'N',
                          'Y');
    --
    insert_database_item ('CON_PERSON_TYPE',
                          'PTYPE.user_person_type',
                          'The contact''s person type,  employee, etc.',
                          'T',
                          'Y');
    --
    insert_database_item ('PTU_CON_PERSON_TYPE',
                          'hr_person_type_usage_info.get_user_person_type(SES.effective_date,PEOPLE.person_id) user_person_type',
                          'The contact''s person type,  employee, etc.',
                          'T',
                          'Y');
    --
    insert_database_item ('CON_CURRENT_APP',
                          'a.meaning',
                      'Whether the contact is a current applicant (yes/no)',
                          'T',
                          'Y');
    insert_database_item ('CON_CURRENT_EMP',
                          'c.meaning',
                          'Whether the contact is a current employee (yes/no)',
                          'T',
                          'Y');
    --
    insert_database_item ('CON_DISABLED',
                          'd.meaning',
                          'Whether the contact is disabled (yes/no)',
                          'T',
                          'Y');
    --
    insert_database_item ('CON_MARITAL_STATUS',
                          'hr_general.decode_lookup(''MAR_STATUS'',
                          	PEOPLE.marital_status)',
                          'The contact''s maritial status',
                          'T',
                          'Y');
    --
    insert_database_item ('CON_NATIONALITY',
                          'hr_general.decode_lookup(''NATIONALITY'',
                          	PEOPLE.nationality)',
                          'The contact''s nationality',
                          'T',
                          'Y');
    --
    insert_database_item ('CON_SEX',
                          'hr_general.decode_lookup(''SEX'',
                          	PEOPLE.sex)',
                          'The contact''s sex',
                          'T',
                          'Y');
    --
    insert_database_item ('CON_TITLE',
                          'hr_general.decode_lookup(''TITLE'',
                          	PEOPLE.title)',
                          'The contact''s title',
                          'T',
                          'Y');
    --
    insert_database_item ('CON_RELATIONSHIP',
                          'hr_general.decode_lookup(''CONTACT'',
                          	CONTACT.contact_type)',
                   'The relationship of the contact to the employee',
                          'T',
                          'Y');
    --
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                       +
    -- Route for contact details : SEH_CON_PERSON_DETAILS_2  +
    --                                                       +
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := '/* contact person details */
                per_all_assignments_f                ASSIGN
        ,       per_contact_relationships            CONTACT
        ,       per_all_people_f                     PEOPLE
        ,       ben_ler_f                            BEN1
        ,       ben_ler_f                            BEN2
        ,       fnd_sessions                         SES
        ,       hr_lookups                           a
        ,       hr_lookups                           b
        ,       hr_lookups                           c
        ,       hr_lookups                           d
        ,       hr_lookups                           e

    where   &B1 BETWEEN ASSIGN.effective_start_date
                     AND ASSIGN.effective_end_date
    and     ASSIGN.assignment_id               = &B2
    and     CONTACT.person_id               (+)= ASSIGN.person_id
    and     CONTACT.primary_contact_flag    (+)= ''Y''
    and     PEOPLE.person_id                (+)= CONTACT.contact_person_id
    and     &B1 BETWEEN PEOPLE.effective_start_date
                     AND PEOPLE.effective_end_date
    and     BEN1.ler_id           (+)= CONTACT.start_life_reason_id
    and     BEN2.ler_id           (+)= CONTACT.end_life_reason_id
    and     a.lookup_type           = ''YES_NO''
    and     a.lookup_code           = nvl(CONTACT.RLTD_PER_RSDS_W_DSGNTR_FLAG,''N'')
    and     a.application_id        = 800
    and     b.lookup_type           = ''YES_NO''
    and     b.lookup_code           = nvl(CONTACT.PERSONAL_FLAG,''N'')
    and     b.application_id        = 800
    and     c.lookup_type           = ''YES_NO''
    and     c.lookup_code           = nvl(CONTACT.THIRD_PARTY_PAY_FLAG,''N'')
    and     c.application_id        = 800
    and     d.lookup_type           = ''YES_NO''
    and     d.lookup_code           = nvl(CONTACT.BENEFICIARY_FLAG,''N'')
    and     d.application_id        = 800
    and     e.lookup_type           = ''YES_NO''
    and     e.lookup_code           = nvl(CONTACT.DEPENDENT_FLAG,''N'')
    and     e.application_id        = 800
    and     SES.session_id          = USERENV(''SESSIONID'')';
    --
    insert_route ('SEH_CON_PERSON_DETAILS_2',
                  'contact details',
                  l_text);
    --
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id,   2);
    --
    insert_user_entity ('CONTACT_DETAILS',
                        'contact details');
    --
    -- insert database items for the route defined above:
    --
    --
    --
    insert_database_item ('CON_DATE_START',
                          'CONTACT.DATE_START',
                'Start date of the contact relationship',
                          'D',
                          'Y');
    --
    insert_database_item ('CON_DATE_END',
                          'CONTACT.DATE_END',
                'End date of the contact relationship',
                          'D',
                          'Y');
    --
    insert_database_item ('CON_START_LIFE_REASON_ID',
                          'BEN1.name',
                  'Reason for the start of the relationship',
                          'T',
                          'Y');
    --
    insert_database_item ('CON_END_LIFE_REASON_ID',
                          'BEN2.name',
                  'Reason for the end of the relationship',
                          'T',
                          'Y');
    --
    insert_database_item ('CON_RLTD_PER_RSDS_W_DSGNTR',
                          'a.meaning',
                          'Related person resides with designator',
                          'T',
                          'Y');
    --
    insert_database_item ('CON_PERSONAL_FLAG',
                          'b.meaning',
                          'Personal Relationship Flag',
                          'T',
                          'Y');
    --
    insert_database_item ('CON_THIRD_PARTY_PAY_FLAG',
                          'c.meaning',
                          'Third Party Payments Relationship Flag',
                          'T',
                          'Y');
    --
    insert_database_item ('CON_BENEFICIARY_FLAG',
                          'd.meaning',
                          'Beneficiary Flag',
                          'T',
                          'Y');
    --
    insert_database_item ('CON_DEPENDENT_FLAG',
                          'e.meaning',
                          'Dependent Flag',
                          'T',
                          'Y');
    --
    insert_database_item ('CON_SEQUENCE_NUMBER',
                          'CONTACT.SEQUENCE_NUMBER',
                          'Sequence number',
                          'N',
                          'Y');

    --
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                             +
    -- Route for contact address details : SEH_CON_PERSON_ADDRESS  +
    --                                                             +
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := '/* contact address details */
        per_all_assignments_f                ASSIGN
,       per_contact_relationships            CONTACT
,       per_all_people_f                     PEOPLE
,	per_addresses                        ADDR
,	fnd_territories_tl                   a
,	fnd_territories_tl                   b
where	&B1 BETWEEN ASSIGN.effective_start_date
                 AND ASSIGN.effective_end_date
and     ASSIGN.assignment_id               = &B2
and     CONTACT.person_id               (+)= ASSIGN.person_id
and     CONTACT.primary_contact_flag    (+)= ''Y''
and     &B1 BETWEEN nvl(ADDR.date_from, &B1)
                 AND nvl(ADDR.date_to, &B1)
and     PEOPLE.person_id                (+)= CONTACT.contact_person_id
and     &B1 BETWEEN nvl (PEOPLE.effective_start_date, &B1)
                 AND nvl (PEOPLE.effective_end_date, &B1)
and	ADDR.person_id                  (+)=  PEOPLE.person_id
and	ADDR.primary_flag               (+)= ''Y''
and	a.territory_code                (+)= ADDR.country
and	a.language                      (+)= userenv(''LANG'')
and	b.territory_code                (+)= ADDR.style
and	b.language                      (+)= userenv(''LANG'')';
    --
    insert_route ('SEH_CON_PERSON_ADDRESS',
                  'contact address details',
                  l_text);
    --
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id,   2);
    --
    insert_user_entity ('CONTACT_ADDRESS_DETAILS',
                        'contact address details');
    --
    -- insert database items for the route defined above:
    --
    --
    insert_database_item ('CON_ADR_DATE_FROM',
                          'ADDR.date_from',
     'The first date on which the contact can be contacted at this address',
                          'D',
                          'Y');
    --
    insert_database_item ('CON_ADR_DATE_TO',
                          'ADDR.date_to',
     'The last date on which the contact can be contacted at this address',
                          'D',
                          'Y');
    --
    insert_database_item ('CON_ADR_LINE_1',
                          'ADDR.address_line1',
                          'The first line of the contact''s address',
                          'T',
                          'Y');
    --
    insert_database_item ('CON_ADR_LINE_2',
                          'ADDR.address_line2',
                          'The second line of the contact''s address',
                          'T',
                          'Y');
    --
    insert_database_item ('CON_ADR_LINE_3',
                          'ADDR.address_line3',
                          'The third line of the contact''s address',
                          'T',
                          'Y');
    --
    insert_database_item ('CON_ADR_CITY',
                          'ADDR.town_or_city',
                          'The name of the contact''s town or city',
                          'T',
                          'Y');
    --
    insert_database_item ('CON_ADR_REGION_1',
                          'ADDR.region_1',
                          'The first line of the contact''s region',
                          'T',
                          'Y');
    --
    insert_database_item ('CON_ADR_REGION_2',
                          'ADDR.region_2',
                          'The second line of the contact''s region',
                          'T',
                          'Y');
    --
    insert_database_item ('CON_ADR_REGION_3',
                          'ADDR.region_3',
                          'The third line of the contact''s region',
                          'T',
                          'Y');
    --
    insert_database_item ('CON_ADR_POSTAL_CODE',
                          'ADDR.postal_code',
                          'The contact''s postal code',
                          'T',
                          'Y');
    --
    insert_database_item ('CON_ADR_PHONE_1',
                          'ADDR.telephone_number_1',
                          'The contact''s first telephone number',
                          'T',
                          'Y');
    --
    insert_database_item ('CON_ADR_PHONE_2',
                          'ADDR.telephone_number_2',
                          'The contact''s second telephone number',
                          'T',
                          'Y');
    --
    insert_database_item ('CON_ADR_PHONE_3',
                          'ADDR.telephone_number_3',
                          'The contact''s third telephone number',
                          'T',
                          'Y');
    --
    insert_database_item ('CON_ADR_COUNTRY',
                          'a.territory_short_name',
                          'The name of the contact''s country',
                          'T',
                          'Y');
    --
    --++++++++++++++++++++++++++++++++++++++++++++++++
    --                                               +
    -- Route for recruiter details : SEH_REC_DETAILS +
    --                                               +
    --++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := '/* recruiter details */
        per_all_assignments_f                ASSIGN
,       per_all_assignments_f                RASSIGN
,       per_all_people_f                     PEOPLE
,	per_person_types                     PTYPE
,       per_phones                           PHONE
,       per_grades                           GRADE
,       per_jobs                             JOB
,       hr_locations                         LOC
,       hr_all_organization_units            ORG
,       hr_all_positions_f                   POS
,	hr_lookups                           a
,	hr_lookups                           c
,	hr_lookups                           d
where   &B1 BETWEEN ASSIGN.effective_start_date
                 AND ASSIGN.effective_end_date
and     &B1 BETWEEN POS.effective_start_date(+)
                 AND POS.effective_end_date(+)
and     ASSIGN.assignment_id               = &B2
and     PEOPLE.person_id                (+)= ASSIGN.recruiter_id
and     &B1 BETWEEN nvl (PEOPLE.effective_start_date, &B1)
                 AND nvl (PEOPLE.effective_end_date, &B1)
and	PTYPE.person_type_id (+)= PEOPLE.person_type_id
and     PHONE.parent_id (+) = PEOPLE.person_id
and     PHONE.parent_table (+)= ''PER_ALL_PEOPLE_F''
and     PHONE.phone_type (+)= ''W1''
and     &B1 BETWEEN NVL(PHONE.date_from, &B1)
                 AND NVL(PHONE.date_to, &B1)
and	a.lookup_type           = ''YES_NO''
and	a.lookup_code           = nvl(PEOPLE.current_applicant_flag,''N'')
and     a.application_id        = 800
and	c.lookup_type           = ''YES_NO''
and	c.lookup_code           = nvl(PEOPLE.current_employee_flag,''N'')
and     c.application_id        = 800
and     RASSIGN.person_id    (+)= ASSIGN.recruiter_id
and     RASSIGN.primary_flag (+)= ''Y''
and     &B1 BETWEEN nvl (RASSIGN.effective_start_date, &B1)
                 AND nvl (RASSIGN.effective_end_date, &B1)
and     GRADE.grade_id       (+)= RASSIGN.grade_id
and     JOB.job_id           (+)= RASSIGN.job_id
and     LOC.location_id      (+)= RASSIGN.location_id
and     ORG.organization_id  (+)= RASSIGN.organization_id
and     POS.position_id      (+)= RASSIGN.position_id
and     d.lookup_type        (+)= ''YES_NO''
and     d.application_id     (+)= 800
and     d.lookup_code        (+)= RASSIGN.manager_flag';
    --
    insert_route ('SEH_REC_DETAILS',
                  'recruiter details',
                  l_text);
    --
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id,   2);
    --
    insert_user_entity ('RECRUITER_DETAILS',
                        'recruiter details');
    --
    -- insert database items for the route defined above:
    --
    -- Moved the databse items to SEH_REC_DETAILS_PERF
    --
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                    +
    -- Route for recruiter details : SEH_REC_DETAILS_PERF +
    --                                                    +
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := '/* recruiter details */
        per_all_assignments_f                ASSIGN
,       per_all_assignments_f                RASSIGN
,       per_all_people_f                     PEOPLE
,	per_person_types                     PTYPE
,       per_phones                           PHONE
,       per_grades                           GRADE
,       per_jobs                             JOB
,       hr_locations                         LOC
,       hr_all_organization_units            ORG
,       hr_all_positions_f                   POS
,	hr_lookups                           a
,	hr_lookups                           c
where   &B1 BETWEEN ASSIGN.effective_start_date
                 AND ASSIGN.effective_end_date
and     &B1 BETWEEN POS.effective_start_date(+)
                 AND POS.effective_end_date(+)
and     ASSIGN.assignment_id               = &B2
and     PEOPLE.person_id                (+)= ASSIGN.recruiter_id
and     &B1 BETWEEN nvl (PEOPLE.effective_start_date, &B1)
                 AND nvl (PEOPLE.effective_end_date, &B1)
and	PTYPE.person_type_id (+)= PEOPLE.person_type_id
and     PHONE.parent_id (+) = PEOPLE.person_id
and     PHONE.parent_table (+)= ''PER_ALL_PEOPLE_F''
and     PHONE.phone_type (+)= ''W1''
and     &B1 BETWEEN NVL(PHONE.date_from, &B1)
                 AND NVL(PHONE.date_to, &B1)
and	a.lookup_type           = ''YES_NO''
and	a.lookup_code           = nvl(PEOPLE.current_applicant_flag,''N'')
and     a.application_id        = 800
and	c.lookup_type           = ''YES_NO''
and	c.lookup_code           = nvl(PEOPLE.current_employee_flag,''N'')
and     c.application_id        = 800
and     RASSIGN.person_id    (+)= ASSIGN.recruiter_id
and     RASSIGN.primary_flag (+)= ''Y''
and     &B1 BETWEEN nvl (RASSIGN.effective_start_date, &B1)
                 AND nvl (RASSIGN.effective_end_date, &B1)
and     GRADE.grade_id       (+)= RASSIGN.grade_id
and     JOB.job_id           (+)= RASSIGN.job_id
and     LOC.location_id      (+)= RASSIGN.location_id
and     ORG.organization_id  (+)= RASSIGN.organization_id
and     POS.position_id      (+)= RASSIGN.position_id';
    --
    insert_route ('SEH_REC_DETAILS_PERF',
                  'recruiter details (performant version)',
                  l_text);
    --
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id,   2);
    --
    insert_user_entity ('RECRUITER_DETAILS_PERF',
                        'recruiter details (performant version)');
    --
    -- insert database items for the route defined above:
    --
    --
    insert_database_item ('REC_EMP_NUMBER',
                          'PEOPLE.employee_number',
                          'The recruiter''s employee number',
                          'T',
                          'Y');
    --
    insert_database_item ('REC_WORK_PHONE',
                          'NVL(PHONE.phone_number,PEOPLE.work_telephone)',
                          'The recruiter''s work telephone number',
                          'T',
                          'Y');
    --
    insert_database_item ('REC_PERSON_TYPE',
                          'PTYPE.user_person_type',
                          'Type of person, eg. employee, applicant, etc.',
                          'T',
                          'Y');
    --
    insert_database_item ('PTU_REC_PERSON_TYPE',
                          'hr_person_type_usage_info.get_user_person_type(people.effective_end_date, people.person_id) user_person_type',
                          'Type of person, eg. employee, applicant, etc.',
                          'T',
                          'Y');
    --
    insert_database_item ('REC_CURRENT_APP',
                          'a.meaning',
                       'Whether the recruiter is a current applicant (yes/no)',
                          'T',
                          'Y');
    --
    insert_database_item ('REC_CURRENT_EMP',
                          'c.meaning',
                        'Whether the recruiter is a current employee (yes/no)',
                          'T',
                          'Y');
    --
    insert_database_item ('REC_GRADE',
                          'Grade.name',
                          'The grade of the recruiter',
                          'T',
                          'Y');
    --
    insert_database_item ('REC_JOB',
                          'JOB.name',
                          'The job of the recruiter',
                          'T',
                          'Y');
    --
    insert_database_item ('REC_LOCATION',
                          'LOC.location_code',
                          'The location of the recruiter',
                          'T',
                          'Y');
    --
    insert_database_item ('REC_ORG',
                          'ORG.name',
                          'The organization name of the recruiter',
                          'T',
                          'Y');
    --
    insert_database_item ('REC_INT_ADDR_LINE',
                          'RASSIGN.internal_address_line',
                          'The internal address of the recruiter',
                          'T',
                          'Y');
    --
    insert_database_item ('REC_MANAGER',
                          'hr_general.decode_lookup(''YES_NO'',
                          	RASSIGN.manager_flag)',
               'Whether the assignment is a managerial assignment (yes/no)',
                          'T',
                          'Y');
    --
    insert_database_item ('REC_POSITION',
                          'POS.name',
                          'The position name of the recruiter',
                          'T',
                          'Y');
    --
    --+++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                +
    -- Route for supervisor details : SEH_SUP_DETAILS +
    --                                                +
    --+++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := '/* supervisor details */
        per_all_assignments_f                ASSIGN
,       per_all_assignments_f                SASSIGN
,       per_all_people_f                     PEOPLE
,       per_person_types                     PTYPE
,       per_phones                           PHONE
,       per_grades                           GRADE
,       per_jobs                             JOB
,       hr_locations                         LOC
,       hr_all_organization_units            ORG
,       hr_all_positions_f                   POS
,	hr_lookups                           c
,	hr_lookups                           d
where   &B1 BETWEEN ASSIGN.effective_start_date
                 AND ASSIGN.effective_end_date
and     &B1 BETWEEN ASSIGN.effective_start_date(+)
                 AND ASSIGN.effective_end_date(+)
and     ASSIGN.assignment_id               = &B2
and     PEOPLE.person_id                (+)= ASSIGN.supervisor_id
and     &B1 BETWEEN nvl (PEOPLE.effective_start_date, &B1)
                 AND nvl (PEOPLE.effective_end_date, &B1)
and	PTYPE.person_type_id            (+)= PEOPLE.person_type_id
and     PHONE.parent_id (+) = PEOPLE.person_id
and     PHONE.parent_table (+)= ''PER_ALL_PEOPLE_F''
and     PHONE.phone_type (+)= ''W1''
and     &B1 BETWEEN NVL(PHONE.date_from, &B1)
                 AND NVL(PHONE.date_to, &B1)
and     SASSIGN.person_id               (+)= ASSIGN.supervisor_id
and     &B1 BETWEEN nvl (SASSIGN.effective_start_date, &B1)
                 AND nvl (SASSIGN.effective_end_date, &B1)
and     SASSIGN.primary_flag (+)= ''Y''
and     GRADE.grade_id       (+)= SASSIGN.grade_id
and     JOB.job_id           (+)= SASSIGN.job_id
and     LOC.location_id      (+)= SASSIGN.location_id
and     ORG.organization_id  (+)= SASSIGN.organization_id
and     POS.position_id      (+)= SASSIGN.position_id
and	c.lookup_type           = ''YES_NO''
and	c.lookup_code           = nvl(PEOPLE.current_employee_flag,''N'')
and     c.application_id        = 800
and     d.lookup_type        (+)= ''YES_NO''
and     d.application_id     (+)= 800
and     d.lookup_code        (+)= SASSIGN.manager_flag';
    --
    insert_route ('SEH_SUP_DETAILS',
                  'supervisor details',
                  l_text);
    --
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id,   2);
    --
    insert_user_entity ('SUPERVISOR_DETAILS',
                        'supervisor details');
    --
    -- insert database items for the route defined above:
    --
    --
    -- moved the database items to SEH_SUP_DETAILS_PERF
    --
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                     +
    -- Route for supervisor details : SEH_SUP_DETAILS_PERF +
    --                                                     +
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := '/* supervisor details */
        per_all_assignments_f                ASSIGN
,       per_all_assignments_f                SASSIGN
,       per_all_people_f                     PEOPLE
,       per_person_types                     PTYPE
,       per_phones                           PHONE
,       per_grades                           GRADE
,       per_jobs                             JOB
,       hr_locations                         LOC
,       hr_all_organization_units            ORG
,       hr_all_positions_f                   POS
,	hr_lookups                           c
where   &B1 BETWEEN ASSIGN.effective_start_date
                 AND ASSIGN.effective_end_date
and     &B1 BETWEEN ASSIGN.effective_start_date(+)
                 AND ASSIGN.effective_end_date(+)
and     ASSIGN.assignment_id               = &B2
and     PEOPLE.person_id                (+)= ASSIGN.supervisor_id
and     &B1 BETWEEN nvl (PEOPLE.effective_start_date, &B1)
                 AND nvl (PEOPLE.effective_end_date, &B1)
and	PTYPE.person_type_id            (+)= PEOPLE.person_type_id
and     PHONE.parent_id (+) = PEOPLE.person_id
and     PHONE.parent_table (+)= ''PER_ALL_PEOPLE_F''
and     PHONE.phone_type (+)= ''W1''
and     &B1 BETWEEN NVL(PHONE.date_from, &B1)
                 AND NVL(PHONE.date_to, &B1)
and     SASSIGN.person_id               (+)= ASSIGN.supervisor_id
and     &B1 BETWEEN nvl (SASSIGN.effective_start_date, &B1)
                 AND nvl (SASSIGN.effective_end_date, &B1)
and     SASSIGN.primary_flag (+)= ''Y''
and     GRADE.grade_id       (+)= SASSIGN.grade_id
and     JOB.job_id           (+)= SASSIGN.job_id
and     LOC.location_id      (+)= SASSIGN.location_id
and     ORG.organization_id  (+)= SASSIGN.organization_id
and     POS.position_id      (+)= SASSIGN.position_id
and	c.lookup_type           = ''YES_NO''
and	c.lookup_code           = nvl(PEOPLE.current_employee_flag,''N'')
and     c.application_id        = 800';
    --
    insert_route ('SEH_SUP_DETAILS_PERF',
                  'supervisor details (performant version)',
                  l_text);
    --
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id,   2);
    --
    insert_user_entity ('SUPERVISOR_DETAILS_PERF',
                        'supervisor details (performant version)');
    --
    -- insert database items for the route defined above:
    --
    --
    --
    insert_database_item ('SUP_EMP_NUMBER',
                          'PEOPLE.employee_number',
                          'The employee number of the supervisor',
                          'T',
                          'Y');
    --
    insert_database_item ('SUP_WORK_PHONE',
                          'NVL(PHONE.phone_number,PEOPLE.work_telephone)',
                          'The supervisor''s work telephone number',
                          'T',
                          'Y');
    --
    insert_database_item ('SUP_PERSON_TYPE',
                          'PTYPE.user_person_type',
                          'Type of person, eg. employee, applicant, etc.',
                          'T',
                          'Y');
    --
    insert_database_item ('PTU_SUP_PERSON_TYPE',
                          'hr_person_type_usage_info.get_user_person_type(PEOPLE.effective_end_date,PEOPLE.person_id) user_person_type',
                          'Type of person, eg. employee, applicant, etc.',
                          'T',
                          'Y');
    --
    insert_database_item ('SUP_DATE_FROM',
                          'SASSIGN.effective_start_date',
           'The date from which this supervisor information is effective',
                          'D',
                          'Y');
    --
    insert_database_item ('SUP_DATE_TO',
                          'SASSIGN.effective_end_date',
             'The date to which this supervisor information is effective',
                          'D',
                          'Y');
    --
    insert_database_item ('SUP_INT_ADDR_LINE',
                          'SASSIGN.internal_address_line',
                          'The internal address of the supervisor',
                          'T',
                          'Y');
    --
    insert_database_item ('SUP_GRADE',
                          'Grade.name',
                          'The grade of the supervisor',
                          'T',
                          'Y');
    --
    insert_database_item ('SUP_JOB',
                          'JOB.name',
                          'The job of the supervisor',
                          'T',
                          'Y');
    --
    insert_database_item ('SUP_LOCATION',
                          'LOC.location_code',
                          'The location of the the supervisor',
                          'T',
                          'Y');
    --
    insert_database_item ('SUP_ORG',
                          'ORG.name',
                          'The organization name of the supervisor',
                          'T',
                          'Y');
    --
    insert_database_item ('SUP_POSITION',
                          'POS.name',
                          'The position name of the supervisor',
                          'T',
                          'Y');
    --
    insert_database_item ('SUP_CURRENT_EMP',
                          'c.meaning',
                    'Whether the supervisor is a current employee (yes/no)',
                          'T',
                          'Y');
    --
    insert_database_item ('SUP_MANAGER',
                          'hr_general.decode_lookup(''YES_NO'',
                          	SASSIGN.manager_flag)',
                 'Whether the assignment is a managerial assignment (yes/no)',
                          'T',
                          'Y');
    --
    insert_database_item ('SUP_EMAIL_ADDRESS',
                          'people.email_address',
                          'Persons email address',
                          'T',
                          'Y');
    --
    --++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                 +
    -- Route for application details : SEH_APL_DETAILS +
    --                                                 +
    --++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := '/* application details */
        per_all_assignments_f                ASSIGN
,       per_applications                     APPLIC
where   &B1 BETWEEN ASSIGN.effective_start_date
                 AND ASSIGN.effective_end_date
and     ASSIGN.assignment_id               = &B2
and     APPLIC.application_id           (+)= ASSIGN.application_id';
    --
    insert_route ('SEH_APL_DETAILS',
                  'application details',
                  l_text);
    --
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id,   2);
    --
    insert_user_entity ('APPLICATION_DETAILS',
                        'application details');
    --
    -- insert database items for the route defined above:
    --
    insert_database_item ('APL_DATE_RECEIVED',
                          'APPLIC.date_received',
                          'The date the application was received',
                          'D',
                          'Y');
    --
    insert_database_item ('APL_DATE_END',
                          'APPLIC.date_end',
                          'The date the application ended',
                          'D',
                          'Y');
    --
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                             +
    -- Route for Date Paid personal status : SEH_ASS_PER_STATUS_DP +
    --                                                             +
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := '/* Personal status (Date paid context) */
        per_assignment_status_types         STYPE
,       per_assignments_f                   ASSIGN
,       fnd_sessions                        SES
where   ASSIGN.assignment_id              = &B1
and     SES.session_id                    = USERENV(''SESSIONID'')
and     SES.effective_date          between ASSIGN.effective_start_date
                                        and ASSIGN.effective_end_date
and     STYPE.assignment_status_type_id   = ASSIGN.assignment_status_type_id';
    --
    insert_route ('SEH_ASS_PER_STATUS_DP',
                  'Personal status (Date paid context)',
                  l_text);
    --
    insert_route_context_usages (l_assign_id_context_id,   1);
    --
    insert_user_entity ('ASSIGNMENT_DP_STATUS',
                        'Personal status (Date paid context)');
    --
    -- insert database items for the route defined above:
    --
    insert_database_item ('ASG_PER_STATUS_DP',
                          'STYPE.per_system_status',
                     'Personal status for the assignment (Date paid context)',
                          'T',
                          'Y');
    --
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                               +
    -- Route for last processed period number : SEH_ASS_LAST_PER_NUM +
    -- (Date Paid route)                                             +
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := '/* Period number the assignment last processed */
       pay_assignment_actions            ASSACT
,      pay_payroll_actions               PACT
,      pay_payrolls_f                    PAYROLL
,      per_time_periods                  TIMEP
where  ASSACT.assignment_id            = &B1
and    ASSACT.action_sequence =
      (
       select max (ASSACT2.action_sequence)
       from   pay_payroll_actions              PACT2
       ,      pay_assignment_actions           ASSACT2
       where  ASSACT2.assignment_id          = &B1
       and    ASSACT2.action_status          = ''C''
       and    PACT2.payroll_action_id        = ASSACT2.payroll_action_id
       and    PACT2.action_type             in (''R'', ''Q'')
      )
and    PACT.payroll_action_id          = ASSACT.payroll_action_id
and    PACT.time_period_id             = TIMEP.time_period_id
and    PAYROLL.payroll_id              = PACT.payroll_id
and    PACT.effective_date       BETWEEN PAYROLL.effective_start_date
                                     AND PAYROLL.effective_end_date';
    --
    insert_route ('SEH_ASS_LAST_PER_NUM',
                  'Period number the assignment last processed',
                  l_text);
    --
    insert_route_context_usages (l_assign_id_context_id, 1);
    --
    insert_user_entity ('LAST_PER_NUMBER',
                        'Period number the assignment last processed',
                        'Y');
    --
    -- insert database items for the route defined above:
    --
    insert_database_item ('ASG_LAST_PROC_PERIOD_NUMBER',
                          '/*+ INDEX(ASSACT PAY_ASSIGNMENT_ACTIONS N1)*/ TIMEP.period_num',
                     'The period number the assignment was last processed',
                          'N',
                          'N');
    --
    insert_database_item ('ASG_LAST_PROC_PERIOD_NAME',
                          '/*+ INDEX(ASSACT PAY_ASSIGNMENT_ACTIONS N1)*/ TIMEP.period_name',
                          'The period name the assignment was last processed',
                          'T',
                          'N');
    --
    insert_database_item ('ASG_LAST_PROC_PERIOD_ID',
                          '/*+ INDEX(ASSACT PAY_ASSIGNMENT_ACTIONS N1)*/ TIMEP.time_period_id',
                          'The Time period id the assignment was last processed',
                          'N',
                          'N');
    --
    insert_database_item ('ASG_LAST_PROC_PAYROLL_NAME',
                          '/*+ INDEX(ASSACT PAY_ASSIGNMENT_ACTIONS N1)*/ PAYROLL.payroll_name',
                          'The payroll name the assignment was last processed',
                          'T',
                          'N');
    --
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                                      +
    -- Route for last processed period number : SEH_ASG_LAST_EARNED_PER_NUM +
    -- (Date Earned route)                                                  +
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := '/* Period number the assignment last processed */
       pay_assignment_actions            ASSACT
,      pay_payroll_actions               PACT
,      pay_payrolls_f                    PAYROLL
,      per_time_periods                  TIMEP
where  ASSACT.assignment_id            = &B1
and    ASSACT.action_sequence =
      (
       select max (ASSACT2.action_sequence)
       from   pay_payroll_actions              PACT2
       ,      pay_assignment_actions           ASSACT2
       where  ASSACT2.assignment_id          = &B1
       and    ASSACT2.action_status          = ''C''
       and    PACT2.payroll_action_id        = ASSACT2.payroll_action_id
       and    PACT2.action_type             in (''R'', ''Q'')
      )
and    PACT.payroll_action_id          = ASSACT.payroll_action_id
and    PACT.time_period_id             = TIMEP.time_period_id
and    PAYROLL.payroll_id              = PACT.payroll_id
and    PACT.date_earned       BETWEEN PAYROLL.effective_start_date
                                  AND PAYROLL.effective_end_date';
    --
    insert_route ('SEH_ASG_LAST_EARNED_PER_NUM',
                  'Period number the assignment last processed as of date earned',
                  l_text);
    --
    insert_route_context_usages (l_assign_id_context_id, 1);
    --
    insert_user_entity ('LAST_EARNED_PER_NUMBER',
                        'Period number the assignment last processed as of date earned',
                        'Y');
    --
    -- insert database items for the route defined above:
    --
    insert_database_item ('ASG_LAST_EARNED_PERIOD_NUMBER',
                          '/*+ INDEX(ASSACT PAY_ASSIGNMENT_ACTIONS N1)*/ TIMEP.period_num',
                     'The period number the assignment was last processed as of date earned',
                          'N',
                          'N');
    --
    insert_database_item ('ASG_LAST_EARNED_PERIOD_NAME',
                          '/*+ INDEX(ASSACT PAY_ASSIGNMENT_ACTIONS N1)*/ TIMEP.period_name',
                          'The period name the assignment was last processed as of date earned',
                          'T',
                          'N');
    --
    insert_database_item ('ASG_LAST_EARNED_PERIOD_ID',
                          '/*+ INDEX(ASSACT PAY_ASSIGNMENT_ACTIONS N1)*/ TIMEP.time_period_id',
                          'The Time period id the assignment was last processed as of date earned',
                          'N',
                          'N');
    --
    insert_database_item ('ASG_LAST_EARNED_PAYROLL_NAME',
                          '/*+ INDEX(ASSACT PAY_ASSIGNMENT_ACTIONS N1)*/ PAYROLL.payroll_name',
                          'The payroll name the assignment was last processed as of date earned',
                          'T',
                          'N');
    --
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                      +
    -- Route for Assignment start date : SEH_ASS_START_DATE +
    --                                                      +
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := '/*  Assignment start date */
    per_assignments_f
where   assignment_id       = &B1';
    --
    insert_route ('SEH_ASS_START_DATE',
                  'Start date for the assignment',
                  l_text);
    --
    insert_route_context_usages (l_assign_id_context_id,   1);
    --
    insert_user_entity ('ASS_START_DATE',
                        'The start date of the assignment');
    --
    -- insert database items for the route defined above:
    --
    insert_database_item ('ASG_START_DATE',
                          'min (effective_start_date)',
                          'The start date of the assignment',
                          'D',
                          'Y');
    --
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                      +
    -- Route for Assignment action : SEH_ASS_ACTION         +
    --                                                      +
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := '/*  Assignment action route */
    pay_assignment_actions
where   assignment_action_id  = &B1';
    --
    insert_route ('SEH_ASS_ACTION',
                  'Assignment action route',
                  l_text);
    --
    insert_route_context_usages (l_assign_action_id_context_id,   1);
    --
    insert_user_entity ('SEH_ASS_ACTION',
                        'Assignment action route');
    --
    -- insert database items for the route defined above:
    --
    insert_database_item ('CHEQUE_UK_NUMBER',
                          'serial_number',
              'The cheque number for the assignment action (UK spelling)',
                          'T',
                          'Y');
    --
    insert_database_item ('CHECK_US_NUMBER',
                          'serial_number',
              'The cheque number for the assignment action (US spelling)',
                          'T',
                          'Y');
    --
    --++++++++++++++++++++++++++++++++++++++++++++++
    --                                             +
    -- Route for Payroll details : SEH_PAY_DETAILS +
    --                                             +
    --++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := '/*  Payroll details */
        pay_payroll_actions                      PACTION
,       per_time_periods                         TPERIOD
,       per_time_period_types                    TPTYPE
where   PACTION.payroll_action_id              = &B1
and     TPERIOD.time_period_id                 = PACTION.time_period_id
and     TPTYPE.period_type                     = TPERIOD.period_type';
    --
    insert_route ('SEH_PAY_DETAILS',
                  'Payroll details',
                  l_text);
    --
    insert_route_context_usages (l_payroll_action_id_context_id, 1);
    --
    insert_user_entity ('PAY_DETAILS',
                        'Payroll details',
                        'Y');
    --
    -- insert database items for the route defined above:
    --
    --
    insert_database_item ('PAY_PROC_PERIOD_NUMBER',
                          'TPERIOD.period_num',
                          'The current period number for the payroll',
                          'N',
                          'N');
    --
    insert_database_item ('PAY_PROC_PERIOD_START_DATE',
                          'TPERIOD.start_date',
                          'The start date of the payroll period',
                          'D',
                          'N');
    --
    insert_database_item ('PAY_PROC_PERIOD_END_DATE',
                          'TPERIOD.end_date',
                          'The end date of the payroll period',
                          'D',
                          'N');
    --
    insert_database_item ('PAY_PROC_PERIOD_DIRECT_DEPOSIT_DATE',
                          'TPERIOD.default_dd_date',
                          'The direct deposit date for the payroll period',
                          'D',
                          'Y');
    --
    insert_database_item ('PAY_PROC_PERIOD_PAY_ADVICE_DATE',
                          'TPERIOD.pay_advice_date',
                          'The pay advice date for the payroll period',
                          'D',
                          'Y');
    --
    insert_database_item ('PAY_PROC_PERIOD_CUT_OFF_DATE',
                          'TPERIOD.cut_off_date',
                          'The cut off date for the payroll period',
                          'D',
                          'Y');
    --
    insert_database_item ('PAY_PROC_PERIOD_ID',
                          'TPERIOD.time_period_id',
                          'The id of the time period for the payroll',
                          'N',
                          'N');
    --
    insert_database_item ('PAY_PROC_PERIOD_NAME',
                          'TPERIOD.period_name',
                          'The period name for the payroll',
                          'T',
                          'N');
    --
    insert_database_item ('PAY_PERIODS_PER_YEAR',
                          'TPTYPE.number_per_fiscal_year',
                          'The number of payable periods in the year',
                          'N',
                          'N');
    --
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                            +
    -- Route for Payroll Action details : SEH_PAY_ACTION_DETAILS  +
    --                                                            +
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := '/*  Payroll action details */
       pay_payroll_actions            PACTION
where  PACTION.payroll_action_id    = &B1';
    --
    insert_route ('SEH_PAY_ACTION_DETAILS',
                  'Payroll action details',
                  l_text);
    --
    insert_route_context_usages (l_payroll_action_id_context_id, 1);
    --
    insert_user_entity ('PAY_ACTION_DETAILS',
                        'Payroll action details');
    --
    -- insert database items for the route defined above:
    --
    --
    insert_database_item ('PAY_PROC_PERIOD_DATE_PAID',
                          'PACTION.effective_date',
                          'The date the payroll was paid',
                          'D',
                          'N');
    --
    -- Some salary admin DB items:
    --
    --+++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                  +
    -- Route for Salary Basis : SEH_SADMIN_SALARY_BASIS +
    --                                                  +
    --+++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := '/* Salary basis route for salary admin */
        per_assignments_f                      ASSIGN
,       per_pay_bases                          BASES
,       pay_input_values_f                     INPUTV
,       pay_element_types_f                    ETYPE
,       pay_rates                              RATE
,       hr_lookups                             HR1
,       hr_lookups                             HR2
where   &B1 BETWEEN ASSIGN.effective_start_date
                 AND ASSIGN.effective_end_date
and     ASSIGN.assignment_id                 = &B2
and     BASES.pay_basis_id                (+)= ASSIGN.pay_basis_id
and     INPUTV.input_value_id             (+)= BASES.input_value_id
and     &B1 between nvl (INPUTV.effective_start_date, &B1)
                 and nvl (INPUTV.effective_end_date, &B1)
and     ETYPE.element_type_id             (+)= INPUTV.element_type_id
and     &B1 between nvl (ETYPE.effective_start_date, &B1)
                 and nvl (ETYPE.effective_end_date, &B1)
and     RATE.rate_id                      (+)= BASES.rate_id
and     HR1.lookup_code                   (+)= BASES.pay_basis
and     HR1.lookup_type                   (+)= ''PAY_BASIS''
and     HR1.application_id                (+)= 800
and     HR2.lookup_code                   (+)= BASES.rate_basis
and     HR2.application_id                (+)= 800
and     HR2.lookup_type                   (+)= ''PAY_BASIS''';
    --
    insert_route ('SEH_SADMIN_SALARY_BASIS',
                  'Salary basis route for salary admin',
                  l_text);
    --
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id,   2);
    --
    insert_user_entity ('SADMIN_SALARY_BASIS',
                        'Salary basis');
    --
    -- insert database items for the route defined above:
    --
    -- moved the databse items to SEH_SADMIN_SALARY_BASIS_PERF
    --
    -- Some salary admin DB items:
    --
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                       +
    -- Route for Salary Basis : SEH_SADMIN_SALARY_BASIS_PERF +
    --                                                       +
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := '/* Salary basis route for salary admin */
        per_assignments_f                      ASSIGN
,       per_pay_bases                          BASES
,       pay_input_values_f                     INPUTV
,       pay_element_types_f                    ETYPE
,       pay_rates                              RATE
where   &B1 BETWEEN ASSIGN.effective_start_date
                 AND ASSIGN.effective_end_date
and     ASSIGN.assignment_id                 = &B2
and     BASES.pay_basis_id                (+)= ASSIGN.pay_basis_id
and     INPUTV.input_value_id             (+)= BASES.input_value_id
and     &B1 between nvl (INPUTV.effective_start_date, &B1)
                 and nvl (INPUTV.effective_end_date, &B1)
and     ETYPE.element_type_id             (+)= INPUTV.element_type_id
and     &B1 between nvl (ETYPE.effective_start_date, &B1)
                 and nvl (ETYPE.effective_end_date, &B1)
and     RATE.rate_id                      (+)= BASES.rate_id';
    --
    insert_route ('SEH_SADMIN_SALARY_BASIS_PERF',
                  'Salary basis route for salary admin (performant version)',
                  l_text);
    --
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id,   2);
    --
    insert_user_entity ('SADMIN_SALARY_BASIS_PERF',
                        'Salary basis (performant version)');
    --
    -- insert database items for the route defined above:
    --
    insert_database_item ('ASG_SALARY_BASIS_NAME',
                          'BASES.name',
                          'The salary basis name for the assignment',
                          'T',
                          'Y');
    --
    insert_database_item ('ASG_SALARY_BASIS',
                          'hr_general.decode_lookup(''PAY_BASIS'',
                          	BASES.pay_basis)',
    'The payment basis (ie. frequency) for the assignment, eg. monthly',
                          'T',
                          'Y');
    --
    insert_database_item ('ASG_SALARY_BASIS_CODE',
                          'BASES.pay_basis',
                          'The payment basis lookup code for the assignment',
                          'T',
                          'Y');
    --
    insert_database_item ('ASG_SALARY_BASIS_ANNUALIZATION_FACTOR',
                          'BASES.pay_annualization_factor',
                          'The payment basis pay annualization factor for the assignment',
                          'N',
                          'Y');
    --
    insert_database_item ('ASG_SALARY_BASIS_GRADE_ANNUALIZATION_FACTOR',
                          'BASES.grade_annualization_factor',
                          'The payment basis grade annualization factor for the assignment',
                          'N',
                          'Y');
    --
    insert_database_item ('ASG_SALARY_ELEMENT',
                          'ETYPE.element_name',
                          'The display element name',
                          'T',
                          'Y');
    --
    insert_database_item ('ASG_SALARY_ELEMENT_VALUE_NAME',
                          'INPUTV.name',
                          'The display input value name',
                          'T',
                          'Y');
    --
    insert_database_item ('ASG_SALARY_GRADE_RATE',
                          'RATE.name',
                          'The display rate name',
                          'T',
                          'Y');
    --
    insert_database_item ('ASG_SALARY_RATE_BASIS',
                          'hr_general.decode_lookup(''PAY_BASIS'',
                          	BASES.rate_basis)',
                          'The salary rate basis (ie. frequency)',
                          'T',
                          'Y');
    --
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                    +
    -- Route for Salary Basis : SEH_SADMIN_SALARY_ELEMENT +
    --                                                    +
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := '/* Salary element route for salary admin */
        per_assignments_f                      ASSIGN
,       per_pay_bases                          BASES
,       pay_element_entries_f                  EE
,       pay_element_entry_values_f             EEV
where   &B1 BETWEEN ASSIGN.effective_start_date
                 AND ASSIGN.effective_end_date
and     ASSIGN.assignment_id                 = &B2
and     BASES.pay_basis_id                +0 = ASSIGN.pay_basis_id
and     EEV.input_value_id                   = BASES.input_value_id
and     &B1 BETWEEN EEV.effective_start_date
                 AND EEV.effective_end_date
and     EE.assignment_id                     = ASSIGN.assignment_id
and     EE.entry_type = ''E''
and     &B1 BETWEEN EE.effective_start_date
                 AND EE.effective_end_date
and     EEV.element_entry_id                 = EE.element_entry_id';
    --
    insert_route ('SEH_SADMIN_SALARY_ELEMENT',
                  'Salary element route for salary admin',
                  l_text);
    --
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id,   2);
    --
    -- since the above route could fail (eg. if the assignment is not on the
    -- payroll) both null allowed and not found allowed are set to yes, and
    -- this DB item is on its own.
    --
    insert_user_entity ('SADMIN_SALARY_ELEMENT',
                        'Salary element',
                        'Y');
    --
    -- insert database items for the route defined above:
    --
    insert_database_item ('ASG_SALARY',
                          'fnd_number.canonical_to_number (EEV.screen_entry_value)',
                          'The current salary for an employee',
                          'N',
                          'Y');
    --
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                          +
    -- Route for Salary proposals : SEH_SADMIN_SALARY_PROPOSALS +
    --                                                          +
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := '/* Salary Proposals route for salary admin */
        per_pay_proposals            PRO
,       pay_element_entries_f        EE
,       hr_lookups                   HR1
,       hr_lookups                   HRNO
,       hr_lookups                   HRYES
where   PRO.assignment_id          = &B2
and     HR1.lookup_code         (+)= PRO.proposal_reason
and     HR1.lookup_type         (+)= ''PROPOSAL_REASON''
and     HRNO.lookup_code           = ''N''
and     HRNO.lookup_type           = ''YES_NO''
and     HRNO.application_id        = 800
and     HRYES.lookup_code          = ''Y''
and     HRYES.lookup_type          = ''YES_NO''
and     HRYES.application_id       = 800
and     EE.creator_id           (+)= PRO.pay_proposal_id
and     EE.creator_type         (+)= ''SP''
and     PRO.change_date =
        (select  max (PRO2.change_date)
         from    per_pay_proposals         PRO2
         where   PRO2.change_date       <= &B1
         and     PRO2.assignment_id      = PRO.assignment_id)';
    --
    insert_route ('SEH_SADMIN_SALARY_PROPOSALS',
                  'Salary Proposals route for salary admin',
                  l_text);
    --
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id,   2);
    --
    insert_user_entity ('SEH_SADMIN_SALARY_PROPOSALS',
                        'Salary element',
                        'Y');
    --
    -- insert database items for the route defined above:
    --
    -- moved the database item to SEH_SADMIN_SALARY_PROPOSALS_PERF
    --
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                               +
    -- Route for Salary proposals : SEH_SADMIN_SALARY_PROPOSALS_PERF +
    --                                                               +
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := '/* Salary Proposals route for salary admin */
        per_pay_proposals            PRO
,       pay_element_entries_f        EE
,       hr_lookups                   HRNO
,       hr_lookups                   HRYES
where   PRO.assignment_id          = &B2
and     HR1.lookup_code         (+)= PRO.proposal_reason
and     HR1.lookup_type         (+)= ''PROPOSAL_REASON''
and     HRNO.lookup_code           = ''N''
and     HRNO.lookup_type           = ''YES_NO''
and     HRNO.application_id        = 800
and     HRYES.lookup_code          = ''Y''
and     HRYES.lookup_type          = ''YES_NO''
and     HRYES.application_id       = 800
and     EE.creator_id           (+)= PRO.pay_proposal_id
and     EE.creator_type         (+)= ''SP''
and     PRO.change_date =
        (select  max (PRO2.change_date)
         from    per_pay_proposals         PRO2
         where   PRO2.change_date       <= &B1
         and     PRO2.assignment_id      = PRO.assignment_id)';
    --
    insert_route ('SEH_SADMIN_SALARY_PROPOSALS_PERF',
                  'Salary Proposals route for salary admin ( performant version)',
                  l_text);
    --
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id,   2);
    --
    insert_user_entity ('SEH_SADMIN_SALARY_PROPOSALS_PERF',
                        'Salary element (performant version)',
                        'Y');
    --
    -- insert database items for the route defined above:
    --
    insert_database_item ('ASG_LAST_SALARY_CHANGE_APPROVED',
          'decode (EE.element_entry_id, null, HRNO.meaning, HRYES.meaning)',
              'Whether the last proposed salary change has been approved ',
                          'T',
                          'N');
    --
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                            +
    -- Route for Salary proposals : SEH_SADMIN_SALARY_PROPOSALS_2 +
    --                                                            +
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := '/* Salary Proposals route for salary admin */
        per_pay_proposals            PRO
,       hr_lookups                   HR1
,       hr_lookups                   HRNO
,       hr_lookups                   HRYES
where   PRO.assignment_id          = &B2
and     HR1.lookup_code         (+)= PRO.proposal_reason
and     HR1.lookup_type         (+)= ''PROPOSAL_REASON''
and     HRNO.lookup_code           = ''N''
and     HRNO.lookup_type           = ''YES_NO''
and     HRNO.application_id        = 800
and     HRYES.lookup_code          = ''Y''
and     HRYES.lookup_type          = ''YES_NO''
and     HRYES.application_id       = 800
and     PRO.change_date =
        (select  max (PRO2.change_date)
         from    per_pay_proposals          PRO2
         where   PRO2.change_date        <= &B1
         and     PRO2.assignment_id       = PRO.assignment_id)';
    --
    insert_route ('SEH_SADMIN_SALARY_PROPOSALS_2',
                  'Salary Proposals route for salary admin',
                  l_text);
    --
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id,   2);
    --
    insert_user_entity ('SEH_SADMIN_SALARY_PROPOSALS_2',
                        'Salary element',
                        'Y');
    --
    -- insert database items for the route defined above:
    --
    -- moved the database items to SEH_SADMIN_SALARY_PROPOSALS_2_PERF
    --
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                                 +
    -- Route for Salary proposals : SEH_SADMIN_SALARY_PROPOSALS_2_PERF +
    --                                                                 +
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := '/* Salary Proposals route for salary admin */
        per_pay_proposals            PRO
,       hr_lookups                   HRNO
,       hr_lookups                   HRYES
where   PRO.assignment_id          = &B2
and     HRNO.lookup_code           = ''N''
and     HRNO.lookup_type           = ''YES_NO''
and     HRNO.application_id        = 800
and     HRYES.lookup_code          = ''Y''
and     HRYES.lookup_type          = ''YES_NO''
and     HRYES.application_id       = 800
and     PRO.change_date =
        (select  max (PRO2.change_date)
         from    per_pay_proposals          PRO2
         where   PRO2.change_date        <= &B1
         and     PRO2.assignment_id       = PRO.assignment_id)';
    --
    insert_route ('SEH_SADMIN_SALARY_PROPOSALS_2_PERF',
                  'Salary Proposals route for salary admin (performant version)',
                  l_text);
    --
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id,   2);
    --
    insert_user_entity ('SEH_SADMIN_SALARY_PROPOSALS_2_PERF',
                        'Salary element (performant version)',
                        'Y');
    --
    -- insert database items for the route defined above:
    --
    --
    insert_database_item ('ASG_LAST_SALARY_DATE',
                          'PRO.change_date',
                          'The last salary change date',
                          'D',
                          'Y');
    --
    insert_database_item ('ASG_LAST_CHANGE_REASON',
                          'hr_general.decode_lookup(''PROPOSAL_REASON'',
                          	PRO.proposal_reason)',
                          'The reason the salary was changed',
                          'T',
                          'Y');
    --
    insert_database_item ('ASG_NEXT_SALARY_DATE',
                          'PRO.next_sal_review_date',
                          'The date of the next salary change',
                          'D',
                          'Y');
    --
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                                    +
    -- Route for last performance review : SEH_SADMIN_LAST_PERFORM_REVIEW +
    --                                                                    +
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := '/* Last performance review route for salary admin */
        per_performance_reviews PRO
,       per_assignments_f ASG
,       per_events EVENT
,       hr_lookups HR1
,       hr_lookups HR2
,       hr_locations LOC
where   ASG.assignment_id                    = &B2
and     &B1 between ASG.effective_start_date
                 and ASG.effective_end_date
and     PRO.person_id                        = ASG.person_id
and     PRO.review_date                      =
        (select  max (PRO2.review_date)
         from    per_performance_reviews       PRO2
         where   PRO2.person_id        = PRO.person_id
         and     PRO2.review_date     <= &B1)
and     EVENT.event_id                    (+)= PRO.event_id
and     HR1.lookup_code                   (+)= EVENT.type
and     HR1.lookup_type                   (+)= ''EMP_INTERVIEW_TYPE''
and     HR2.lookup_code                   (+)= PRO.performance_rating
and     HR2.lookup_type                   (+)= ''PERFORMANCE_RATING''
and     LOC.location_id                   (+)= EVENT.location_id';
    --
    insert_route ('SEH_SADMIN_LAST_PERFORM_REVIEW',
                  'Last performance review route for salary admin',
                  l_text);
    --
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id,   2);
    --
    insert_user_entity ('SEH_SADMIN_LAST_REVIEW',
                        'Salary element',
                        'Y');
    --
    -- insert database items for the route defined above:
    --
    -- moved the database items to SEH_SADMIN_LAST_PERFORM_REVIEW_PERF
    --
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                                         +
    -- Route for last performance review : SEH_SADMIN_LAST_PERFORM_REVIEW_PERF +
    --                                                                         +
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := '/* Last performance review route for salary admin */
        per_performance_reviews PRO
,       per_assignments_f ASG
,       per_events EVENT
,       hr_locations LOC
where   ASG.assignment_id                    = &B2
and     &B1 between ASG.effective_start_date
                 and ASG.effective_end_date
and     PRO.person_id                        = ASG.person_id
and     PRO.review_date                      =
        (select  max (PRO2.review_date)
         from    per_performance_reviews       PRO2
         where   PRO2.person_id        = PRO.person_id
         and     PRO2.review_date     <= &B1)
and     EVENT.event_id                    (+)= PRO.event_id
and     LOC.location_id                   (+)= EVENT.location_id';
    --
    insert_route ('SEH_SADMIN_LAST_PERFORM_REVIEW_PERF',
                  'Last performance review route for salary admin (performant version)',
                  l_text);
    --
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id,   2);
    --
    insert_user_entity ('SEH_SADMIN_LAST_REVIEW_PERF',
                        'Salary element (performant version)',
                        'Y');
    --
    -- insert database items for the route defined above:
    --
    insert_database_item ('ASG_LAST_PERFORMANCE_DATE',
          'decode (PRO.event_id, null, PRO.review_date, EVENT.date_start)',
                          'Last performance review date',
                          'D',
                          'Y');
    --
    insert_database_item ('ASG_LAST_PERFORMANCE_TYPE',
                          'hr_general.decode_lookup(''EMP_INTERVIEW_TYPE'',
                          	EVENT.type)',
                          'Last performance review type',
                          'T',
                          'Y');
    --
    insert_database_item ('ASG_LAST_PERFORMANCE_LOCATION',
                          'LOC.location_code',
                          'Last performance review location',
                          'T',
                          'Y');
    --
    insert_database_item ('ASG_LAST_PERFORMANCE_RATING',
                          'hr_general.decode_lookup(''PERFORMANCE_RATING'',
                          	PRO.performance_rating)',
                          'Last performance review rating',
                          'T',
                          'Y');
    --
    insert_database_item ('ASG_NEXT_PERFORMANCE_DATE',
                          'PRO.next_perf_review_date',
                          'Next performance review date',
                          'D',
                          'Y');
    --
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                                    +
    -- Route for last salary change : SEH_SADMIN_LAST_SALARY_CHANGE       +
    --                                                                    +
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := '/* Last salary change route for salary admin */
        pay_element_entries_f                EE
,       pay_element_entry_values_f           EEV
,       per_pay_bases                        BASES1
,       per_pay_bases                        BASES2
,       per_pay_proposals                    PRO
,       per_assignments_f                    ASSIGN1
,       per_assignments_f                    ASSIGN2
where   EEV.effective_start_date           = EE.effective_start_date
/*  ^ Every change of entry results in a change of the entry values also  */
and     EE.assignment_id                   = &B2
and     EEV.element_entry_id               = EE.element_entry_id
and     EEV.input_value_id                 = BASES1.input_value_id
and     PRO.assignment_id                  = &B2
and     (PRO.change_date - 1)        between EE.effective_start_date
                                         and EE.effective_end_date
/* ^ finds the last salary entry  amongst others */
and     ASSIGN2.pay_basis_id               = BASES2.pay_basis_id
and     ASSIGN1.pay_basis_id               = BASES1.pay_basis_id
and     (PRO.change_date - 1)        between ASSIGN1.effective_start_date
                                         and ASSIGN1.effective_end_date
/* ^ find the assignment record for the last actual salary change */
and     PRO.change_date              between ASSIGN2.effective_start_date
                                         and ASSIGN2.effective_end_date
/* ^ find the assignment record on the day of the proposed change */
and     ASSIGN2.assignment_id              = PRO.assignment_id
and     ASSIGN1.assignment_id              = PRO.assignment_id
and     PRO.change_date =
        (select  max(PRO2.change_date)
         from    per_pay_proposals        PRO2
         where   PRO2.change_date      <= &B1
         and     PRO2.assignment_id     = PRO.assignment_id)';
    --
    insert_route ('SEH_SADMIN_LAST_SALARY_CHANGE',
                  'Last salary change route for salary admin',
                  l_text);
    --
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id,   2);
    --
    insert_user_entity ('SEH_SADMIN_LAST_SALARY_CHANGE',
                        'Last salary change',
                        'Y');
    --
    -- insert database items for the route defined above:
    --
    insert_database_item ('ASG_LAST_PROPOSED_SALARY_CHANGE',
   'decode(BASES1.pay_basis, BASES2.pay_basis, (PRO.proposed_salary_n -
    EEV.screen_entry_value), null)',
                          'The proposed salary change',
                          'N',
                          'Y');
    --
    insert_database_item ('ASG_LAST_PROPOSED_SALARY_PERCENT',
  'decode(BASES1.pay_basis, BASES2.pay_basis, (((PRO.proposed_salary_n -
   EEV.screen_entry_value) *100)/EEV.screen_entry_value), null)',
                          'The proposed salary change as a percentage',
                          'N',
                          'Y');
    --
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                                    +
    -- Route for general HR addresss : SEH_ASSIGN_HR_ADDRESS              +
    --                                                                    +
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := '/* The work address for the assignment (general legislation) */
        per_all_assignments_f                  ASSIGN
,       hr_locations                           HRLOC
,       fnd_territories_tl                     TER
where	&B1 BETWEEN ASSIGN.effective_start_date
                 AND ASSIGN.effective_end_date
and     ASSIGN.assignment_id                 = &B2
and     HRLOC.location_id                    = ASSIGN.location_id
and     TER.territory_code                (+)= HRLOC.country
and     TER.language                      (+)= userenv(''LANG'')';
    --
    insert_route ('SEH_ASSIGN_HR_ADDRESS',
                  'The work address for the assignment (general legislation)',
                  l_text);
    --
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id,   2);
    --
    insert_user_entity ('SEH_ASSIGN_HR_ADDRESS',
                 'The work address for the assignment (general legislation)',
                        'Y');
    --
    -- insert database items for the route defined above:
    --
    --
    insert_database_item ('LOC_ADR_LINE_1',
                          'HRLOC.address_line_1',
                          'The first line of the assignment''s work address',
                          'T',
                          'Y');
    --
    insert_database_item ('LOC_ADR_LINE_2',
                          'HRLOC.address_line_2',
                          'The second line of the assignment''s work address',
                          'T',
                          'Y');
    --
    insert_database_item ('LOC_ADR_LINE_3',
                          'HRLOC.address_line_3',
                          'The third line of the assignment''s work address',
                          'T',
                          'Y');
    --
    insert_database_item ('LOC_ADR_POSTAL_CODE',
                          'HRLOC.postal_code',
                          'The postal code for the assignment''s work address',
                          'T',
                          'Y');
    --
    insert_database_item ('LOC_ADR_REGION_1',
                          'HRLOC.region_1',
                          'The first line of the assignment''s region',
                          'T',
                          'Y');
    --
    insert_database_item ('LOC_ADR_REGION_2',
                          'HRLOC.region_2',
                          'The second line of the assignment''s region',
                          'T',
                          'Y');
    --
    insert_database_item ('LOC_ADR_REGION_3',
                          'HRLOC.region_3',
                          'The third line of the assignment''s region',
                          'T',
                          'Y');
    --
    insert_database_item ('LOC_ADR_PHONE_1',
                          'HRLOC.telephone_number_1',
                          'The assignment''s first work telephone number',
                          'T',
                          'Y');
    --
    insert_database_item ('LOC_ADR_PHONE_2',
                          'HRLOC.telephone_number_2',
                          'The assignment''s second work telephone number',
                          'T',
                          'Y');
    --
    insert_database_item ('LOC_ADR_PHONE_3',
                          'HRLOC.telephone_number_3',
                          'The assignment''s third work telephone number',
                          'T',
                          'Y');
    --
    insert_database_item ('LOC_ADR_CITY',
                          'HRLOC.town_or_city',
                          'The town or city where the assignment works',
                          'T',
                          'Y');
    --
    insert_database_item ('LOC_ADR_COUNTRY',
                          'TER.territory_short_name',
                          'The country where the assignment works',
                          'T',
                          'Y');
    --
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                                    +
    -- Route for US HR addresss : SEH_ASSIGN_HR_ADDRESS_US                +
    --                                                                    +
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := '/* The work address for the assignment (US legislation) */
        per_all_assignments_f                  ASSIGN
,       hr_locations                           HRLOC
,       hr_lookups                             HR1
where	&B1 BETWEEN ASSIGN.effective_start_date
                 AND ASSIGN.effective_end_date
and     ASSIGN.assignment_id                 = &B2
and     HRLOC.location_id                    = ASSIGN.location_id
and     HRLOC.style                          = ''US''
and     HR1.lookup_code                   (+)= HRLOC.region_2
and     HR1.application_id                (+)= 800
and     HR1.lookup_type                   (+)= ''US_STATE''';
    --
    insert_route ('SEH_ASSIGN_HR_ADDRESS_US',
                  'The work address for the assignment (US legislation)',
                  l_text);
    --
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id,   2);
    --
    insert_user_entity ('SEH_ASSIGN_HR_ADDRESS_US',
                 'The work address for the assignment (US legislation)',
                        'Y');
    --
    -- insert database items for the route defined above:
    --
    insert_database_item ('LOC_ADR_US_COUNTY',
                          'HRLOC.region_1',
                          'The assignment''s work county (US only)',
                          'T',
                          'Y');
    --
    insert_database_item ('LOC_ADR_US_STATE',
                          'HR1.meaning',
                          'The assignment''s work state (US only)',
                          'T',
                          'Y');
    --
    insert_database_item ('LOC_ADR_US_STATE_CODE',
                          'HRLOC.region_2',
                          'The assignment''s work state code (US only)',
                          'T',
                          'Y');
    --
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                                    +
    -- Route for US home addresss : SEH_ASSIGN_ADDRESS_US                 +
    --                                                                    +
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := '/* The home address for the assignment (US legislation) */
        per_all_assignments_f                  ASSIGN
,	per_addresses                          ADDR
,       hr_lookups                             HR1
where	&B1 BETWEEN ASSIGN.effective_start_date
                 AND ASSIGN.effective_end_date
and     ASSIGN.assignment_id                 = &B2
and	ADDR.person_id                    (+)= ASSIGN.person_id
and	ADDR.primary_flag                 (+)= ''Y''
and	ADDR.style                           = ''US''
and     HR1.lookup_code                   (+)= ADDR.region_2
and     HR1.application_id                (+)= 800
and     HR1.lookup_type                   (+)= ''US_STATE''';
    --
    insert_route ('SEH_ASSIGN_ADDRESS_US',
                  'The home address for the assignment (US legislation)',
                  l_text);
    --
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id,   2);
    --
    insert_user_entity ('SEH_ASSIGN_ADDRESS_US',
                 'The home address for the assignment (US legislation)',
                        'Y');
    --
    -- insert database items for the route defined above:
    --
    insert_database_item ('PER_ADR_US_COUNTY',
                          'ADDR.region_1',
                          'The assignment''s county (US only)',
                          'T',
                          'Y');
    --
    insert_database_item ('PER_ADR_US_STATE',
                          'HR1.meaning',
                          'The assignment''s state (US only)',
                          'T',
                          'Y');
    --
    insert_database_item ('PER_ADR_US_STATE_CODE',
                          'ADDR.region_2',
                          'The assignment''s state code (US only)',
                          'T',
                          'Y');
    --
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                                    +
    -- Route for UK HR addresss : SEH_ASSIGN_HR_ADDRESS_UK                +
    --                                                                    +
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := '/* The work address for the assignment (GB legislation) */
        per_all_assignments_f                  ASSIGN
,       hr_locations                           HRLOC
,       hr_lookups                             HR1
where	&B1 BETWEEN ASSIGN.effective_start_date
                 AND ASSIGN.effective_end_date
and     ASSIGN.assignment_id                 = &B2
and     HRLOC.location_id                    = ASSIGN.location_id
and     HRLOC.style                          = ''GB''
and     HR1.lookup_code                   (+)= HRLOC.region_1
and     HR1.application_id                (+)= 800
and     HR1.lookup_type                   (+)= ''GB_COUNTY''';
    --
    insert_route ('SEH_ASSIGN_HR_ADDRESS_UK',
                  'The work address for the assignment (GB legislation)',
                  l_text);
    --
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id,   2);
    --
    insert_user_entity ('SEH_ASSIGN_HR_ADDRESS_UK',
                 'The work address for the assignment (GB legislation)',
                        'Y');
    --
    -- insert database items for the route defined above:
    --
    insert_database_item ('LOC_ADR_UK_COUNTY',
                          'HR1.meaning',
                          'The assignment''s work county (UK only)',
                          'T',
                          'Y');
    --
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                                    +
    -- Route for UK home addresss : SEH_ASSIGN_ADDRESS_UK                 +
    --                                                                    +
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := '/* The home address for the assignment (GB legislation) */
        per_all_assignments_f                  ASSIGN
,	per_addresses                          ADDR
,       hr_lookups                             HR1
where	&B1 BETWEEN ASSIGN.effective_start_date
                 AND ASSIGN.effective_end_date
and     ASSIGN.assignment_id                 = &B2
and	ADDR.person_id                    (+)= ASSIGN.person_id
and	ADDR.primary_flag                 (+)= ''Y''
and	ADDR.style                           = ''GB''
and     HR1.lookup_code                   (+)= ADDR.region_1
and     HR1.application_id                (+)= 800
and     HR1.lookup_type                   (+)= ''GB_COUNTY''';
    --
    insert_route ('SEH_ASSIGN_ADDRESS_UK',
                  'The home address for the assignment (GB legislation)',
                  l_text);
    --
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id,   2);
    --
    insert_user_entity ('SEH_ASSIGN_ADDRESS_UK',
                 'The home address for the assignment (GB legislation)',
                        'Y');
    --
    -- insert database items for the route defined above:
    --
    insert_database_item ('PER_ADR_UK_COUNTY',
                          'HR1.meaning',
                          'The assignment''s home county (UK only)',
                          'T',
                          'Y');
    --
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                                    +
    --  Route for sysdate : SEH_SYSDATE                                   +
    --                                                                    +
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := 'dual';
    --
        insert_route ('SEH_SYSDATE',
                      'sysdate route',
                      l_text);
    --
    insert_user_entity ('SEH_SYSDATE',
                        'sysdate route');
    --
    -- insert database items for the route defined above:
    --
    --
    insert_database_item ('SYSDATE',
                          'sysdate',
                          'The system date',
                          'D',
                          'N');
    --
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                                    +
    --  Route for session date : SEH_SESSION_DATE                         +
    --                                                                    +
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := 'fnd_sessions where session_id = userenv(''sessionid'')';
    --
        insert_route ('SEH_SESSION_DATE',
                      'session date route',
                      l_text);
    --
    insert_user_entity ('SEH_SESSION_DATE',
                        'session date route',
                        'Y');
    --
    -- insert database items for the route defined above:
    --
    --
    insert_database_item ('SESSION_DATE',
                          'effective_date',
                          'The session date',
                          'D',
                          'N');
    --
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                         +
    -- Route for target payroll action : TARGET_PAYROLL_ACTION +
    --                                                         +
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := '/* route for target_payroll_action */
       pay_payroll_actions PAC
,      pay_payroll_actions TARGET
WHERE PAC.target_payroll_action_id = TARGET.payroll_action_id
AND   PAC.payroll_action_id = &B1';
    --
    insert_route ('TARGET_PAYROLL_ACTION_ROUTE',
                  'Route for Target payroll action',
                  l_text);
    --
    insert_route_context_usages (l_payroll_action_id_context_id, 1);
    --
    insert_user_entity ('TARGET_PAYROLL_ACTION_ENTITY',
                        'Entity for payroll target action',
                        'Y');
    --
    -- insert database items for the route defined above:
    --
    insert_database_item ('ACTION_TYPE',
                          'TARGET.ACTION_TYPE',
                          'Actual Value of Action_Type',
                          'T',
                          'N');
    --
    --++++++++++++++++++++++++++++++++++++++++++++++++
    --                                               +
    -- Route for payroll arrears flag : PAY_PAYROLLS +
    --                                               +
    --++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := '/* route for pay_payrolls */
       pay_payrolls_f PAYROLL
WHERE  &B1 BETWEEN PAYROLL.effective_start_date
                AND PAYROLL.effective_end_date
AND    PAYROLL.payroll_id = &B2';
    --
    insert_route ('PAY_PAYROLLS_ROUTE',
                  'Route for pay_payrolls',
                  l_text);
    --
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_payroll_id_context_id, 2);
    --
    insert_user_entity ('PAY_PAYROLLS_ENTITY',
                        'Entity for pay_payrolls',
                        'Y');
    --
    -- insert database items for the route defined above:
    --
    insert_database_item ('PAYROLL_ARREARS_FLAG',
                          'PAYROLL.ARREARS_FLAG',
                          'Actual Value of Arrears_Flag',
                          'T',
                          'Y');
    --
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                               +
    -- Route for assignment budget values : ASSIGNMENT_BUDGET_VALUES +
    --                                                               +
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := '/* route for assignment budget values */
        per_assignment_budget_values_f           BUDGET
where   BUDGET.assignment_id                   = &B1
and     BUDGET.unit                            = &U1
and     &B2 between BUDGET.effective_start_date
and     BUDGET.effective_end_date';
    --
    insert_route ('ASSIGNMENT_BUDGET_VALUES',
                  'Route for Assignment Budget Values',
                  l_text);
    --
    insert_route_context_usages (l_assign_id_context_id,   1);
    insert_route_context_usages (l_date_earned_context_id, 2);
    --
    insert_route_parameters ('UNIT', 'T', 1);
    --
    insert_user_entity ('ASSIGNMENT_FTE_BUDGET_VALUES',
                        'Entity for FTE Assignment Budget Values',
                        'Y');
    --
    select ff_route_parameters_s.currval
    into   l_route_parameters_id
    from   dual;
    --
    insert_route_parameter_values ( l_route_parameters_id,
                                    '''FTE''');
    --
    -- insert database items for the route defined above:
    --
    insert_database_item ('ASG_FTE_VALUE',
                          'BUDGET.VALUE',
                          'Full Time Equivalent Budget Actual Value',
                          'N',
                          'N');
    --
    insert_user_entity ('ASSIGNMENT_HEAD_BUDGET_VALUES',
                        'Entity for Assignment HEAD Budget Values',
                        'Y');
    --
    insert_route_parameter_values ( l_route_parameters_id,
                                    '''HEAD''');
    --
    -- insert database items for the route defined above:
    --
    insert_database_item ('ASG_HEAD_VALUE',
                          'BUDGET.VALUE',
                          'HEAD Budget Actual Value',
                          'N',
                          'N');
    --
    insert_user_entity ('ASSIGNMENT_MONEY_BUDGET_VALUES',
                        'Entity for Assignment Money Budget Values',
                        'Y');
    --
    insert_route_parameter_values ( l_route_parameters_id,
                                    '''MONEY''');
    --
    -- insert database items for the route defined above:
    --
    insert_database_item ('ASG_MONEY_VALUE',
                          'BUDGET.VALUE',
                          'Money Budget Actual Value',
                          'N',
                          'N');
    --
    insert_user_entity ('ASSIGNMENT_PFT_BUDGET_VALUES',
                        'Entity for Assignment PFT Budget Values',
                        'Y');
    --
    insert_route_parameter_values ( l_route_parameters_id,
                                    '''PFT''');
    --
    -- insert database items for the route defined above:
    --
    insert_database_item ('ASG_PFT_VALUE',
                          'BUDGET.VALUE',
                          'PFT Budget Actual Value',
                          'N',
                          'N');
    --
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                               +
    -- Route for assignment full time conditions :                   +
    --                               ASSIGNMENT_FULL_TIME_CONDITIONS +
    --                                                               +
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := '/* route for assignment inherited normal working conditions */
   per_all_assignments_f    ASSIGN
,  hr_positions_f     POS
,  per_organization_units    ORG
,  per_business_groups    BUS
where &B1 BETWEEN ASSIGN.effective_start_date
               AND ASSIGN.effective_end_date
AND  &B1 BETWEEN POS.effective_start_date(+)
              AND POS.effective_end_date(+)
and  ASSIGN.assignment_id   = &B2
and  ASSIGN.position_id    = POS.position_id (+)
and  ASSIGN.organization_id    = ORG.organization_id
and  ASSIGN.business_group_id   = BUS.business_group_id
and  ( POS.FREQUENCY is not null
 OR ORG.FREQUENCY is not null
 OR BUS.FREQUENCY is not null)';
    --
    insert_route ('ASSIGNMENT_FULL_TIME_CONDITIONS',
                  'Route for Assignment Full Time Conditions for pay_payrolls',
                  l_text);
    --
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id,   2);
    --
    insert_user_entity ('ASSIGNMENT_FULL_TIME_CONDITIONS',
                        'Entity for Assignment Full Time Conditions',
                        'Y');
    --
    -- insert database items for the route defined above:
    --
    insert_database_item ('ASG_FULL_TIME_HOURS',
                          'nvl(POS.WORKING_HOURS,nvl(ORG.WORKING_HOURS,BUS.WORKING_HOURS))',
                          'Full Time Working Hours',
                          'N',
                          'N');
    --
    insert_database_item ('ASG_FULL_TIME_FREQ',
                          'nvl(POS.FREQUENCY,nvl(ORG.FREQUENCY,BUS.FREQUENCY))',
                          'Full Time Frequency',
                          'T',
                          'N');
    --
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                               +
    -- Route for accrual plans :                                     +
    --                               ACCRUAL_PLAN_VALUES             +
    --                                                               +
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
l_text := '/* route for assignment budget values */
        pay_accrual_plans           PAP
where   PAP.accrual_plan_id = &B1';
    --
    insert_route ('ACCRUAL_PLAN_VALUES',
                  'Route for Accrual Plans',
                  l_text);
    --
    insert_route_context_usages (l_accrual_plan_id_context_id, 1);
    --
    insert_user_entity ('ACP_NAME',
                        'Entity for Accrual PLans',
                        'Y');
    --
    -- insert database items for the route defined above:
    --
    insert_database_item ('ACP_NAME',
                          'PAP.ACCRUAL_PLAN_NAME',
                          'Name of accrual plan',
                          'T',
                          'N');
    --
    insert_database_item ('ACP_CATEGORY',
                          'PAP.ACCRUAL_CATEGORY',
                          'Accrual Category - Sick, Vacation etc',
                          'T',
                          'N');
    --
    insert_database_item ('ACP_START',
                          'PAP.ACCRUAL_START',
                          'Accrual Start - BOY, HD etc',
                          'T',
                          'Y');
    --
    insert_database_item ('ACP_UOM',
                          'PAP.ACCRUAL_UNITS_OF_MEASURE',
                          'Unit of measure used for accrual plan',
                          'T',
                          'N');
    --
    insert_database_item ('ACP_INELIGIBILITY_PERIOD_TYPE',
                          'PAP.INELIGIBLE_PERIOD_TYPE',
                          'Type of period before eligibility commences',
                          'T',
                          'Y');
    --
    insert_database_item ('ACP_INELIGIBILITY_PERIOD_LENGTH',
                          'PAP.INELIGIBLE_PERIOD_LENGTH',
                          'Number of periods before eligibility is attained',
                          'N',
                          'Y');
    --
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                               +
    -- Route for accrual plan values :                               +
    --                               CARRIED_OVER_VALUES             +
    --                                                               +
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
l_text := '/* route for carry over values */
        pay_accrual_plans           PAP,
        pay_element_entries_f       PEE,
        pay_element_entry_values_f  PEV1,
        pay_element_entry_values_f  PEV2
where   PAP.accrual_plan_id = &B1
and     pap.co_date_input_value_id = pev1.input_value_id
and     pap.co_input_value_id = pev2.input_value_id
and     pev1.element_entry_id = pev2.element_entry_id
and     pev1.element_entry_id = pee.element_entry_id
and     pee.assignment_id = &B2
and     pev1.screen_entry_value < fnd_date.date_to_canonical(&B3)
and not exists (select 1
                from pay_element_entry_values_f pev3,
                     pay_element_entries_f      pee1
                where pee1.element_entry_id = pev3.element_entry_id
                and pev3.element_entry_id != pev1.element_entry_id
                and pev3.input_value_id = pev1.input_value_id
                and pev3.screen_entry_value <= fnd_date.date_to_canonical(&B3)
                and (  (pev3.screen_entry_value > pev1.screen_entry_value)
                    or (pev3.screen_entry_value = pev1.screen_entry_value)
                        and pee1.entry_type = ''S''))';
    --
    insert_route ('CARRIED_OVER_VALUES',
                  'Route for Accrual Plans',
                  l_text);
    --
    insert_route_context_usages (l_accrual_plan_id_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id, 2);
    insert_route_context_usages (l_date_earned_context_id, 3);
    --
    insert_user_entity ('ACP_CARRIED_OVER_PTO',
                        'Entity for carried over values',
                        'Y');
    --
    -- insert database items for the route defined above:
    --
    insert_database_item ('ACP_CARRIED_OVER_PTO',
                          'PEV2.SCREEN_ENTRY_VALUE',
                          'Amount of PTO carried over',
                          'N',
                          'N');
    --
    insert_database_item ('ACP_CARRIED_OVER_DATE',
                          'PEV1.SCREEN_ENTRY_VALUE',
                          'Date on which CO is effective',
                          'N',
                          'N');
    --
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                               +
    -- Route for accrual plan service dates :                        +
    --                               ACCRUAL_PLAN_SERVICE_DATES      +
    --                                                               +
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
l_text := '/* route for service dates used in accrual plan calculations */
         per_all_assignments_f asg,
         per_periods_of_service pps
  where  asg.assignment_id = &B1
  and    &B2 between asg.effective_start_date
              and     asg.effective_end_date
  and    asg.period_of_service_id = pps.period_of_service_id';
    --
    insert_route ('ACCRUAL_PLAN_SERVICE_DATES',
                  'Route for Accrual Plan Service Dates',
                  l_text);
    --
    insert_route_context_usages (l_assign_id_context_id, 1);
    insert_route_context_usages (l_date_earned_context_id, 2);
    --
    insert_user_entity ('ACP_SERVICE_DATES',
                        'Entity for accrual plan service dates',
                        'Y');
    --
    -- insert database items for the route defined above:
    --
    insert_database_item ('ACP_TERMINATION_DATE',
                          'PPS.ACTUAL_TERMINATION_DATE',
                          'Termination Date',
                          'D',
                          'Y');
    --
    insert_database_item ('ACP_SERVICE_START_DATE',
                          'PPS.DATE_START',
                          'Hire Date',
                          'D',
                          'N');
    --
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                               +
    -- Route for accrual plan dates :                                +
    --                               ACCRUAL_PLAN_ENROLLMENT_DATES   +
    --                                                               +
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
l_text := '/* route for dates used in accrual plan calculations */
         pay_element_entries_f pee,
         pay_element_links_f pel,
         pay_element_types_f pet,
         pay_accrual_plans pap
  where  pee.element_link_id = pel.element_link_id
  and    pel.element_type_id = pet.element_type_id
  and    pet.element_type_id = pap.accrual_plan_element_type_id
  and    pee.entry_type =''E''
  and    pee.assignment_id = &B2
  and    pap.accrual_plan_id = &B1
  and    &B3 between pee.effective_start_date
              and     pee.effective_end_date
  and    &B3 between pel.effective_start_date
              and     pel.effective_end_date
  and    &B3 between pet.effective_start_date
              and     pet.effective_end_date';
    --
    insert_route ('ACCRUAL_PLAN_ENROLLMENT_DATES',
                  'Route for Accrual Plan Dates',
                  l_text);
    --
    insert_route_context_usages (l_accrual_plan_id_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id, 2);
    insert_route_context_usages (l_date_earned_context_id, 3);
    --
    insert_user_entity ('ACCRUAL_PLAN_ENROLLMENT_DATES',
                        'Entity for Date of enrollment in a plan',
                        'Y');
    --
    -- insert database items for the route defined above:
    --
    insert_database_item ('ACP_ENROLLMENT_START_DATE',
                          'LEAST(PEE.EFFECTIVE_START_DATE)',
                          'Enrollment Date',
                          'D',
                          'N');
    --
    insert_database_item ('ACP_ENROLLMENT_END_DATE',
                          'GREATEST(PEE.EFFECTIVE_END_DATE)',
                          'Enrollment Date',
                          'D',
                          'N');
    --
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                               +
    -- Route for accrual plan dates :                                +
    --                               ACCRUAL_PLAN_CONT_SERVICE_DATES +
    --                                                               +
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
l_text := '/* route for dates used in accrual plan calculations */
         pay_element_entries_f pee,
         pay_element_entry_values_f pev,
         pay_input_values_f piv,
         pay_accrual_plans pap,
         pay_element_links_f pel,
         pay_element_types_f pet
  where  pev.element_entry_id = pee.element_entry_id
  and    pee.element_link_id = pel.element_link_id
  and    pel.element_type_id = pet.element_type_id
  and    pap.accrual_plan_element_type_id = pet.element_type_id
  and    piv.input_value_id = pev.input_value_id
  and    piv.element_type_id = pet.element_type_id
  and    pee.entry_type =''E''
  and    pee.assignment_id = &B2
  and    pap.accrual_plan_id = &B1
  and    &B3 between pet.effective_start_date
              and     pet.effective_end_date
  and    &B3 between pel.effective_start_date
              and     pel.effective_end_date
  and    &B3 between pee.effective_start_date
              and     pee.effective_end_date
  and    &B3 between piv.effective_start_date
              and     piv.effective_end_date
  and    &B3 between pev.effective_start_date
              and     pev.effective_end_date
  and    piv.name = ''Continuous Service Date''';
    --
    insert_route ('ACCRUAL_PLAN_CONT_SERVICE_DATES',
                  'Route for Accrual Plan Dates',
                  l_text);
    --
    insert_route_context_usages (l_accrual_plan_id_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id, 2);
    insert_route_context_usages (l_date_earned_context_id, 3);
    --
    insert_user_entity ('ACCRUAL_PLAN_CONT_SERVICE_DATES',
                        'Entity for CSD of person enrolled in plan',
                        'Y');
    --
    -- insert database items for the route defined above:
    --
    insert_database_item ('ACP_CONTINUOUS_SERVICE_DATE',
                          'FND_DATE.CANONICAL_TO_DATE(PEV.SCREEN_ENTRY_VALUE)',
                          'Continuous Service Date',
                          'D',
                          'Y');
    --
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                               +
    -- Route for original entry attributes dates :                   +
    --                               ORIGINAL_ENTRY_ATTRIBUTES       +
    --                                                               +
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
l_text := '/* route for original entry attributes */
        pay_element_entries_f                    TARGET
where   TARGET.element_entry_id                = &B1';
    --
    insert_route ('ORIGINAL_ENTRY_ATTRIBUTES',
                  'Route for Original Element Entry attributes',
                  l_text);
    --
    insert_route_context_usages (l_original_entry_id, 1);
    --
    insert_user_entity ('ORIGINAL_ENTRY_ATTRIBUTES',
                        'Entity for original entry details');
    --
    insert_database_item ('ENTRY_START_DATE',
                          'min(TARGET.effective_start_date)',
                          'start date of the original entry',
                          'D',
                          'N');
    --
    insert_database_item ('ENTRY_END_DATE',
                          'max(TARGET.effective_end_date)',
                          'end date of the original entry',
                          'D',
                          'N');
    --
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                               +
    -- Route for  date earned dbitems :                              +
    --                               PAY_EARNED_PERIOD               +
    --                                                               +
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
l_text := '/* route pay earned period (core) */
            per_time_periods ptp,
            pay_payroll_actions ppa
where ppa.date_earned BETWEEN ptp.START_DATE and ptp.END_DATE
  and ppa.payroll_action_id = &B1
  and ptp.payroll_id = ppa.payroll_id';
    --
    insert_route ('PAY_EARNED_PERIOD_CORE',
                  'Route for pay earned period',
                  l_text);
    --
    insert_route_context_usages (l_payroll_action_id_context_id, 1);
    --
    insert_user_entity ('PAY_PD_DETAILS_CORE',
                        'Entity for original entry details',
                        'Y');
    --
    insert_database_item ('PAY_EARNED_START_DATE',
                          'PTP.start_date',
                          'The start date of the earned period',
                          'D',
                          'N');
    --
    insert_database_item ('PAY_EARNED_END_DATE',
                          'PTP.end_date',
                          'The end date of the earned period',
                          'D',
                          'N');
    --
    insert_database_item ('PAY_EARNED_DIRECT_DEPOSIT_DATE',
                          'PTP.default_dd_date',
                          'The direct deposit date of the earned period',
                          'D',
                          'N');
    --
    insert_database_item ('PAY_EARNED_PAY_ADVICE_DATE',
                          'PTP.pay_advice_date',
                          'The pay advice date of the earned period',
                          'D',
                          'N');
    --
    insert_database_item ('PAY_EARNED_CUT_OFF_DATE',
                          'PTP.cut_off_date',
                          'The cut off date of the earned period',
                          'D',
                          'N');
    --
    insert_database_item ('PAY_EARNED_PERIOD_NAME',
                          'PTP.period_name',
                          'The period name for the earned period',
                          'T',
                          'N');
    --
    insert_database_item ('PAY_EARNED_PERIOD_NUMBER',
                          'PTP.period_num',
                          'The period number for the earned period',
                          'N',
                          'N');
    --
    insert_database_item ('PAY_EARNED_PERIOD_ID',
                          'PTP.time_period_id',
                          'The time period id for the earned period',
                          'N',
                          'N');
    --
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                               +
    -- Route for gross up amount retrieval :                         +
    --                               GROSSUP_AMOUNT                  +
    --                                                               +
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
l_text := '/* route for gross up amount */
     pay_defined_balances pdb,
     pay_assignment_actions paa,
     pay_balance_types      pbt,
     pay_run_results        prr,
     pay_payroll_actions    ppa,
     per_business_groups    pbg
where paa.assignment_action_id = &B1
and   paa.payroll_action_id = ppa.payroll_action_id
and   ppa.business_group_id = pbg.business_group_id
and   pbt.balance_type_id = pdb.balance_type_id
and   ((pbt.business_group_id = ppa.business_group_id)
       or (pbt.legislation_code = pbg.legislation_code
           and pbt.business_group_id is null)
       or (pbt.legislation_code is null
           and pbt.business_group_id is null)
      )
and   pdb.grossup_allowed_flag = ''Y''
and   paa.assignment_action_id = prr.assignment_action_id
and   prr.source_id = &B2
and   prr.source_type = ''E''
and   not exists (select ''''
                    from pay_grossup_bal_exclusions pgb
                   where prr.source_id = pgb.source_id
                     and pgb.balance_type_id = pbt.balance_type_id
                     and pgb.source_type = ''EE''
                  )
and   not exists (select ''''
                    from pay_grossup_bal_exclusions pgb
                   where prr.element_type_id = pgb.source_id
                     and pgb.balance_type_id = pbt.balance_type_id
                     and pgb.source_type = ''ET''
                  )';
    --
    insert_route ('GROSSUP_AMOUNT',
                  'Route for gross up amount',
                  l_text);
    --
    insert_route_context_usages (l_assign_action_id_context_id,   1);
    insert_route_context_usages (l_element_entry_id, 2);
    --
    insert_user_entity ('GROSSUP_AMOUNT',
                        'Entity for gross up');
    --
    insert_database_item ('GROSSUP_AMOUNT',
                          'nvl(sum(pay_balance_pkg.get_value(pdb.defined_balance_id,paa.assignment_action_id)), 0)',
                          'Gross up amount to be added to the Net',
                          'N',
                          'N');
    --
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                               +
    -- Route for  assignment contracts :                             +
    --                               ASSIGNMENT_CONTRACTS_ROUTE      +
    --                                                               +
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
l_text := '/* route for contracts */
     per_contracts_f           target,
     per_all_assignments_f     asg
  where asg.assignment_id   = &B1
  and   target.contract_id (+) = asg.contract_id
  and   &B2 between asg.effective_start_date and asg.effective_end_date
  and  &B2 between target.effective_start_date and target.effective_end_date';
    --
    insert_route ('ASSIGNMENT_CONTRACTS_ROUTE',
                  'Route for Assignment Contracts',
                  l_text);
    --
    insert_route_context_usages (l_assign_id_context_id, 1);
    insert_route_context_usages (l_date_earned_context_id, 2);
    --
    insert_user_entity ('insert_route_context_usages',
                        'Entity for Assignment Contracts',
                        'Y');
    --
    insert_database_item ('CTR_TYPE',
                          'target.type',
                          'Contract Type (code)',
                          'T',
                          'Y');
    --
    insert_database_item ('CTR_STATUS',
                          'target.status',
                          'Contract Status (code)',
                          'T',
                          'Y');
    --
    insert_database_item ('CTR_TYPE_MEANING',
                          'hr_general.decode_lookup(''CONTRACT_TYPE'',target.type)',
                          'Contract Type (meaning)',
                          'T',
                          'Y');
    --
    insert_database_item ('CTR_STATUS_MEANING',
                          'hr_general.decode_lookup(''CONTRACT_STATUS'',target.status)',
                          'Contract Status (meaning)',
                          'T',
                          'Y');
    --
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                               +
    -- Route for  time periods :                                     +
    --                               PER_TIME_PERIODS_INFO           +
    --                                                               +
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
l_text := '/* PER_TIME_PERIODS_INFO */
pay_payroll_actions paction,
per_time_periods target
where   paction.payroll_action_id = &B1
and     target.payroll_id = paction.payroll_id
and     to_char(target.regular_payment_date,''YYYY'') = to_char(paction.effective_date,''YYYY'')';
    --
    insert_route ('PER_TIME_PERIODS_INFO',
                  'PER_TIME_PERIODS_INFO based on payroll_action_id and effective_date',
                  l_text);
    --
    insert_route_context_usages (l_payroll_action_id_context_id, 1);
    --
    insert_user_entity ('PER_TIME_PERIOD_DETAILS',
                        'PER_TIME_PERIOD_DETAILS',
                        'Y');
    --
    insert_database_item ('PAY_NO_OF_SCHEDULED_PAYMENTS',
                          'Count(target.REGULAR_PAYMENT_DATE)',
                          'Number of Scheduled Payments Per Year',
                          'N',
                          'Y');
    --
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                               +
    -- Route for  element types attributes periods :                 +
    --                               ELEMENT_TYPE_ATTRIBUTES         +
    --                                                               +
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
l_text := '/* route for element type attributes */
        pay_element_types_f                    TARGET
where   TARGET.element_type_id                = &B1
and     &B2
        BETWEEN TARGET.effective_start_date and TARGET.effective_end_date ';
    --
    insert_route ('ELEMENT_TYPE_ATTRIBUTES',
                  'Route for Element Type attributes',
                  l_text);
    --
    insert_route_context_usages (l_element_type_id, 1);
    insert_route_context_usages (l_date_earned_context_id, 2);
    --
    insert_user_entity ('ELEMENT_TYPE_ATTRIBUTES',
                        'Entity for element type details');
    --
    insert_database_item ('ELEMENT_NAME',
                          'TARGET.element_name',
                          'element name of the element being processed',
                          'T',
                          'N');
    --
    insert_database_item ('CURRENT_ELEMENT_TYPE_ID',
                          'TARGET.element_type_id',
                          'The element type id of the element being processed',
                          'N',
                          'N');
    --
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                               +
    -- Route for accrual plan dates :                                +
    --                               ACCRUAL_PLAN_PAYROLL_PROCESS_1  +
    --                                                               +
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
l_text := '/* route for dates used in accrual plan calculations */
         pay_element_entries_f pee,
         pay_accrual_plans pap,
         pay_element_links_f pel
  where  pap.accrual_plan_element_type_id = pel.element_type_id
  and    pel.element_link_id = pee.element_link_id
  and    pee.element_entry_id = &B1
  and    &B2 between pee.effective_start_date
              and     pee.effective_end_date';
    --
    insert_route ('ACCRUAL_PLAN_PAYROLL_PROCESS_1',
                  'Route for Accrual Plan ID',
                  l_text);
    --
    insert_route_context_usages (l_element_entry_id, 1);
    insert_route_context_usages (l_date_earned_context_id, 2);
    --
    insert_user_entity ('ACCRUAL_PLAN_PAYROLL_PROCESS_1',
                        'Entity for ID of a plan',
                        'Y');
    --
    insert_database_item ('PTO_ACCRUAL_PLAN_ID',
                          'DISTINCT PAP.ACCRUAL_PLAN_ID',
                          'Accrual Plan ID',
                          'N',
                          'N');
    --
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                               +
    -- Route for accrual plan dates :                                +
    --                               ACCRUAL_PLAN_PAYROLL_PROCESS_2  +
    --                                                               +
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
l_text := '
         pay_assignment_actions paa,
         pay_payroll_actions ppa
  where  ppa.payroll_action_id = paa.payroll_action_id
  and    paa.assignment_action_id = &B1';
    --
    insert_route ('ACCRUAL_PLAN_PAYROLL_PROCESS_2',
                  'Route for Accrual Plan Dates',
                  l_text);
    --
    insert_route_context_usages (l_assign_action_id_context_id,   1);
    --
    insert_user_entity ('ACCRUAL_PLAN_PAYROLL_PROCESS_2',
                        'Entity for start and end calculation dates for pto',
                        'Y');
    --
    insert_database_item ('PTO_DATE_PAID_CALCULATION_DATE',
                          'PPA.EFFECTIVE_DATE',
                          'Date Paid for current period',
                          'D',
                          'Y');
    --
    insert_database_item ('PTO_DATE_EARNED_CALCULATION_DATE',
                          'PPA.DATE_EARNED',
                          'Date Earned for current period',
                          'D',
                          'Y');
    --
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                               +
    -- Route for accrual plan dates :                                +
    --                               ACCRUAL_PLAN_PAYROLL_PROCESS_3  +
    --                                                               +
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
l_text := '/* route for dates used in accrual plan calculations */
         pay_assignment_actions paa,
         pay_assignment_actions paa2,
         pay_payroll_actions ppa,
         pay_run_results prr
  where  paa.assignment_action_id = &B1
  and    paa2.assignment_id = paa.assignment_id
  and    paa2.payroll_action_id = ppa.payroll_action_id
  and    paa2.action_sequence < paa.action_sequence
  and    paa2.action_status = ''C''
  and    paa2.assignment_action_id = prr.assignment_action_id
  and    prr.element_type_id = (SELECT pap.balance_element_type_id
                                FROM   pay_accrual_plans pap
                                WHERE  pap.accrual_plan_element_type_id = &B2)
  and    ppa.action_type in (''R'',''Q'',''V'',''B'')';
    --
    insert_route ('ACCRUAL_PLAN_PAYROLL_PROCESS_3',
                  'Route for Accrual Plan Dates',
                  l_text);
    --
    insert_route_context_usages (l_assign_action_id_context_id, 1);
    insert_route_context_usages (l_element_type_id, 2);
    --
    insert_user_entity ('ACCRUAL_PLAN_PAYROLL_PROCESS_3',
                        'Entity for start and end calculation dates for pto',
                        'Y');
    --
    insert_database_item ('PTO_DATE_PAID_START_DATE',
                          'MAX(PPA.EFFECTIVE_DATE) + 1',
                          'Date Paid for previous period',
                          'D',
                          'Y');
    --
    insert_database_item ('PTO_DATE_EARNED_START_DATE',
                          'MAX(PPA.DATE_EARNED) + 1',
                          'Date Earned for previous period',
                          'D',
                          'Y');
    --
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                               +
    -- Route for Assignment Organizations:                           +
    --                               ASG_ORG_ROUTE                   +
    --                                                               +
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
l_text := '/* Route for Assignment Organizations */
           hr_all_organization_units target
          ,hr_locations loc
          ,hr_lookups org_type
          ,hr_lookups int_ext
          ,per_all_assignments_f ASSIGN
  where target.location_id=loc.location_id(+)
  and  target.type=org_type.lookup_code(+)
  and (org_type.lookup_type=''ORG_TYPE''
       or target.type is null)
  and  target.internal_external_flag=int_ext.lookup_code(+)
  and (int_ext.lookup_type=''INTL_EXTL''
       or target.internal_external_flag is null)
  and &B1 between ASSIGN.effective_start_date
      and ASSIGN.effective_end_date
  and ASSIGN.assignment_id = &B2
  and ASSIGN.organization_id=target.organization_id';
    --
    insert_route ('ASG_ORG_ROUTE',
                  'Route for Assignment Organizations',
                  l_text);
    --
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id,   2);
    --
    insert_user_entity ('ASG_ORG',
                        'The Assignment Organization User Entity',
                        'Y');
    --
    insert_database_item ('ASG_ORG_LOCATION',
                          'loc.location_code',
                          'Assignment Organization Location',
                          'T',
                          'Y');
    --
    insert_database_item ('ASG_ORG_TYPE',
                          'org_type.meaning',
                          'Assignment Organization Type',
                          'T',
                          'Y');
    --
    insert_database_item ('ASG_ORG_INT_EXT',
                          'int_ext.meaning',
                          'Assignment Organization Internal External Flag',
                          'T',
                          'Y');
    --
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                               +
    -- Route for Assignment Organizations:                           +
    --                               ASG_POS_ROUTE                   +
    --                                                               +
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
l_text := '/* Route for Assignment Positions */
           hr_all_positions_f target
          ,hr_locations loc
          ,hr_lookups frequency
          ,hr_lookups probation
          ,per_all_assignments_f ASSIGN
  where target.location_id=loc.location_id(+)
  and  target.frequency=frequency.lookup_code(+)
  and (frequency.lookup_type=''FREQUENCY''
       or target.frequency is null)
  and  target.probation_period_unit_cd=probation.lookup_code(+)
  and (probation.lookup_type=''QUALIFYING_UNITS''
       or target.probation_period_unit_cd is null)
  and &B1 between ASSIGN.effective_start_date
      and ASSIGN.effective_end_date
  and ASSIGN.assignment_id = &B2
  and ASSIGN.position_id=target.position_id
  and &B1 between target.effective_start_date
      and target.effective_end_date';
    --
    insert_route ('ASG_POS_ROUTE',
                  'Route for Assignment Positions',
                  l_text);
    --
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id,   2);
    --
    insert_user_entity ('ASG_POS',
                        'The Assignment Position User Entity',
                        'Y');
    --
    insert_database_item ('ASG_POS_LOCATION',
                          'loc.location_code',
                          'Assignment Position Location',
                          'T',
                          'Y');
    --
    insert_database_item ('ASG_POS_FREQUENCY',
                          'frequency.meaning',
                          'Assignment Position Frequency',
                          'T',
                          'Y');
    --
    insert_database_item ('ASG_POS_WORKING_HOURS',
                          'target.working_hours',
                          'Assignment Position Working Hours',
                          'N',
                          'Y');
    --
    insert_database_item ('ASG_POS_PROBATION_PERIOD',
                          'target.probation_period',
                          'Assignment Position Probation Period',
                          'T',
                          'Y');
    --
    insert_database_item ('ASG_POS_PROBATION_PERIOD_UNITS',
                          'period.meaning',
                          'Assignment Position Probation Period Units',
                          'T',
                          'Y');
    --
    insert_database_item ('ASG_POS_FTE',
                          'target.fte',
                          'Assignment Position FTE',
                          'T',
                          'Y');
    --
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                               +
    -- Route for Assignment Details                                  +
    --                               SEH_ASSIGNMENT_DETAILS          +
    --                                                               +
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := '/* Assignment Details */
        per_all_assignments_f     ASSIGN
        WHERE &B1 BETWEEN ASSIGN.effective_start_date AND
                           ASSIGN.effective_end_date
        AND &B2 = ASSIGN.ASSIGNMENT_ID';

    insert_route ('SEH_ASSIGNMENT_DETAILS',
                  'Assignment Details',
                  l_text);
    --
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id,   2);
    --
    insert_user_entity ('SEH_ASSIGNMENT_DETAILS',
                        'Assignment Details',
                        'Y');
    --
    insert_database_item ('ASG_WORK_AT_HOME',
                          'ASSIGN.work_at_home',
                          'The work at home code for an assignment',
                          'T',
                          'Y');
    --
    --
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                               +
    -- Route for HRI Assignment Details                              +
    --                               HRI_ASG_DETAILS                 +
    --                                                               +
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := '/* HRI Assignment Details */
        per_all_assignments_f     asg
        WHERE &B1 BETWEEN asg.effective_start_date AND asg.effective_end_date
        AND &B2 = asg.assignment_id';

    insert_route ('HRI_ASG_DETAILS',
                  'HRI Assignment only',
                  l_text);
    --
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id,   2);
    --
    insert_user_entity ('HRI_ASG_DETAILS',
                        'HRI Assignment Details',
                        'Y');
    --
    insert_database_item ('HRI_ASG_PRIMARY_CODE',
                          'asg.primary_flag',
                          'Primary Assignment Code',
                          'T',
                          'N');
    insert_database_item ('HRI_ASG_EMPLOYMENT_CATEGORY_CODE',
                          'asg.employment_category',
                          'Employment Category Code',
                          'T',
                          'Y');
    insert_database_item ('HRI_ASG_FREQ_CODE',
                          'asg.frequency',
                          'Assignment Working Hours Frequency Code',
                          'T',
                          'Y');
    insert_database_item ('HRI_ASG_HOURS',
                          'asg.normal_hours',
                          'Assignment Normal Working Hours',
                          'N',
                          'Y');

    --
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                               +
    -- Route for HRI Assignment Details                              +
    --                               HRI_ASG_INHRTD_WRK_CNDTNS       +
    --                                                               +
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    l_text := '/* HRI Assignment Inherited Working Conditions */
        per_all_assignments_f          asg
        ,hr_all_positions_f            hpf
        ,hr_organization_information   oi_org
        ,hr_organization_information   oi_bus
        WHERE &B1 BETWEEN asg.effective_start_date
              AND asg.effective_end_date
        AND   &B1 BETWEEN hpf.effective_start_date(+)
              AND hpf.effective_end_date(+)
        AND   asg.assignment_id   = &B2
        AND   asg.position_id    = hpf.position_id (+)
        AND   asg.organization_id    = oi_org.organization_id (+)
        AND   oi_org.org_information_context (+) = ''Work Day Information''
        AND   asg.business_group_id   = oi_bus.organization_id (+)
        AND   oi_bus.org_information_context (+) = ''Work Day Information''
        AND  ( hpf.frequency is not null
              OR oi_org.org_information4 is not null
              OR oi_bus.org_information4 is not null)';

    insert_route ('HRI_ASG_INHRTD_WRK_CNDTNS',
                  'HRI Assignment Inherited Working Conditions',
                  l_text);
    --
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id,   2);
    --
    insert_user_entity ('HRI_ASG_INHRTD_WRK_CNDTNS',
                        'HRI Assignment Inherited Working Conditions',
                        'Y');
    --
    insert_database_item ('HRI_ASG_FULL_TIME_HOURS',
                          'NVL(hpf.working_hours,NVL(oi_org.org_information3,oi_bus.org_information3))',
                          'Full Time Working Hours',
                          'N',
                          'Y');
    insert_database_item ('HRI_ASG_FULL_TIME_FREQ',
                          'NVL(hpf.frequency,NVL(oi_org.org_information4,oi_bus.org_information4))',
                          'Full Time Frequency',
                          'T',
                          'N');

    --
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                               +
    -- Route for LAST_REG_PAYMENT_PERIOD                             +
    --                               LAST_REGULAR_PAYMENT_PERIOD     +
    --                                                               +
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    l_text := '/* LAST_REG_PAYMENT_PERIOD */
        pay_payroll_actions paction,
        per_time_periods    target
        where paction.payroll_action_id = &B1
        and   target.payroll_id = paction.payroll_id
        and to_char(target.regular_payment_date,''YYYY'')=to_char(paction.effective_date,''YYYY'')
        and   target.regular_payment_date <= paction.effective_date';
    --
    insert_route ('LAST_REGULAR_PAYMENT_PERIOD',
                  'Last Regular Payment Period',
                  l_text);
    --
    insert_route_context_usages (l_payroll_action_id_context_id, 1);
    --
    insert_user_entity ('LAST_REGULAR_PAYMENT_PERIOD',
                        'Last Regular Payment Period',
                        'Y');
    --
    insert_database_item ('LAST_REG_PAYMENT_PERIOD',
                          'nvl(max(period_num), 1)',
                          'Last Regular Payment Period',
                          'N',
                          'N');
    --
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                               +
    -- Route for LAST_REG_PAYMENT_PERIOD_START_DATE                  +
    --                      LAST_REG_PAYMENT_PERIOD_START_DATE       +
    --                                                               +
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    l_text := '/* LAST_REG_PAYMENT_PERIOD_START_DATE */
      pay_payroll_actions paction,
      per_time_periods target
      where paction.payroll_action_id = &B1
      and   target.payroll_id = paction.payroll_id
      and  (target.regular_payment_date <= paction.effective_date
      or    target.regular_payment_date =
                    (select min (tp.regular_payment_date)
                     from pay_payroll_actions ppa,
                          per_time_periods tp
                     where ppa.payroll_action_id = &B1
                     and   tp.payroll_id         = ppa.payroll_id
                     and   to_char(tp.regular_payment_date,''YYYY'') =
                           to_char(ppa.effective_date,''YYYY'')))';
    --
    insert_route ('LAST_REG_PAYMENT_PERIOD_START_DATE',
                  'Last Regular Payment Period Start Date',
                  l_text);
    --
    insert_route_context_usages (l_payroll_action_id_context_id, 1);
    --
    insert_user_entity ('LAST_REG_PAYMENT_PERIOD_START_DATE',
                        'Last Regular Payment Period Start Date',
                        'Y');
    --
    insert_database_item ('LAST_REG_PAYMENT_PERIOD_START_DATE',
                          'Max(target.START_DATE)',
                          'Last Regular Payment Period Start Date',
                          'D',
                          'N');

    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                               +
    -- Route for  ASSIGNMENT_ACTION_DATES_ROUTE                      +
    --                                                               +
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    l_text := '/* ASSIGNMENT_ACTION_DATES_ROUTE */
             pay_assignment_actions target,
             pay_assignment_actions paa
  	where target.assignment_action_id = paa.source_action_id
	  and paa.assignment_action_id = &B1';

    --
    insert_route ('ASSIGNMENT_ACTION_DATES_ROUTE',
                  'Assignment Action Start Date',
                  l_text);
    --
    insert_route_context_usages (l_assign_action_id_context_id, 1);
    --
    insert_user_entity ('ASSIGNMENT_ACTION_DATES_UENT',
                        'Entity for the assignment Action Dates',
                        'Y');
    --
    insert_database_item ('ASSIGNMENT_ACTION_START_DATE',
                          'target.START_DATE',
                          'Assignment Action Start Date',
                          'D',
                          'Y');

    insert_database_item ('ASSIGNMENT_ACTION_END_DATE',
                          'target.END_DATE',
                          'Assignment Action End Date',
                          'D',
                          'Y');


--
end insert_routes_db_items;
--
PROCEDURE insert_functions is
l_text                          long;
l_function_id                   number;
--
   procedure load_function(p_name       varchar2
                          ,p_type       varchar2
                          ,p_definition varchar2
                          ,p_description varchar2
                          ,p_function_id out nocopy number
                          ,p_alias      varchar2 default null) is
      l_function_id number;
   begin
      --
      select ff_functions_s.nextval
      into l_function_id
      from dual;
      --
      insert into ff_functions
      (FUNCTION_ID
      ,BUSINESS_GROUP_ID
      ,LEGISLATION_CODE
      ,CLASS
      ,NAME
      ,ALIAS_NAME
      ,DATA_TYPE
      ,DEFINITION
      ,LAST_UPDATE_DATE
      ,LAST_UPDATED_BY
      ,LAST_UPDATE_LOGIN
      ,CREATED_BY
      ,CREATION_DATE
      ,DESCRIPTION
      )
      values(l_function_id
      ,      null
      ,      null
      ,      'E'
      ,      p_name
      ,      p_alias
      ,      p_type
      ,      p_definition
      ,      sysdate
      ,      -1
      ,      -1
      ,      -1
      ,      sysdate
      ,      p_description
      );
      --
      p_function_id := l_function_id;
      --
   end;
   --
   procedure load_parameter(p_sequence_no number
                           ,p_function_id number
                           ,p_data_type   varchar2
                           ,p_name        varchar2
                            ) is

   begin
     --
     insert into ff_function_parameters
     (FUNCTION_ID
     ,SEQUENCE_NUMBER
     ,CLASS
     ,CONTINUING_PARAMETER
     ,DATA_TYPE
     ,NAME
     ,OPTIONAL
      )
     values
     (p_function_id
     ,p_sequence_no
     ,'I'
     ,'N'
     ,p_data_type
     ,p_name
     ,'N'
     );
     --
   end;
   --
   procedure load_context_usage(p_sequence_no  number
                               ,p_function_id  number
                               ,p_context_name varchar2
                                ) is
     l_context_id number;
   begin
     --
     select context_id
     into l_context_id
     from ff_contexts
     where context_name = p_context_name;
     --
     insert into ff_function_context_usages
     (FUNCTION_ID
     ,SEQUENCE_NUMBER
     ,CONTEXT_ID
     )
     values
     (p_function_id
	     ,p_sequence_no
     ,l_context_id
     );
     --
   end;
   --
begin
--
     --
     --  PLSQL mod function
     --
     hr_utility.set_location ('hrstrdbi.insert_functions' , 10);
     load_function('MOD',
                   'N',
                   'MOD',
                   'Function to implement plsql mod function',
                   l_function_id,
                   'MODULUS'
                   );
     --
     hr_utility.set_location ('hrstrdbi.insert_functions' , 11);
     load_parameter(1,
                    l_function_id,
                    'N', 'P_VAL1');
     --
     hr_utility.set_location ('hrstrdbi.insert_functions' , 12);
     load_parameter(2,
                    l_function_id,
                    'N', 'P_VAL2');
     --
     -- The following function GET_HOURS_WORKED is used by report HRUTLHRS.
     --
     hr_utility.set_location ('hrstrdbi.insert_functions' , 10);
     load_function('GET_HOURS_WORKED',
		   'N',
		   'hrfastanswers.get_hours_worked',
		   'Function to return the number of overtime hours worked',
		   l_function_id
		   );
     --
     hr_utility.set_location ('hrstrdbi.insert_functions' , 11);
     load_parameter(1,
		    l_function_id,
		    'N', 'P_MULTIPLE');
     --
     hr_utility.set_location ('hrstrdbi.insert_functions', 12);
     load_context_usage(1,
			l_function_id,
			'ASSIGNMENT_ID');
     --
     hr_utility.set_location ('hrstrdbi.insert_functions', 13);
     load_context_usage(2,
			l_function_id,
			'DATE_EARNED');
     --
     hr_utility.set_location ('hrstrdbi.insert_functions', 14);
     --
     --  CURRENCY_CONVERT_AMOUNT function
     --
     load_function('CURRENCY_CONVERT_AMOUNT',
                   'N',
                   'HR_currency_pkg.convert_amount',
                   null,
                   l_function_id
                   );
     --
     load_parameter(1,
                    l_function_id,
                    'T', 'from_currency');
     --
     load_parameter(2,
                    l_function_id,
                    'T', 'to_currency');
     --
     load_parameter(3,
                    l_function_id,
                    'D', 'conversion_date');
     --
     load_parameter(4,
                    l_function_id,
                    'N', 'amount');
     --
     load_parameter(5,
                    l_function_id,
                    'T', 'rate_type');
     --
     hr_utility.set_location ('hrstrdbi.insert_functions', 15);
     --
     --  GET_RATE_TYPE function
     --
     load_function('GET_RATE_TYPE',
                   'N',
                   'HR_currency_pkg.get_rate_type',
                   null,
                   l_function_id
                   );
     --
     load_parameter(1,
                    l_function_id,
                    'N', 'business_group_id');
     --
     load_parameter(2,
                    l_function_id,
                    'D', 'conversion_date');
     --
     load_parameter(3,
                    l_function_id,
                    'T', 'processing_type');
     --
     hr_utility.set_location ('hrstrdbi.insert_functions', 16);
     --
     --  CHECK_RATE_TYPE function
     --
     load_function('CHECK_RATE_TYPE',
                   'N',
                   'HR_currency_pkg.check_rate_type',
                   null,
                   l_function_id
                   );
     --
     load_parameter(1,
                    l_function_id,
                    'T', 'rate_type');
     --
     hr_utility.set_location ('hrstrdbi.insert_functions', 17);
     --
     --  accrual functions
     --
	/********* CALCULATE_PAYROLL_PERIODS ***********************/
	--
	load_function('CALCULATE_PAYROLL_PERIODS',
		      'N',
		      'PER_UTILITY_FUNCTIONS.CALCULATE_PAYROLL_PERIODS',
                      null,
		      l_function_id
		      );
	--
	load_context_usage(1,
			   l_function_id,
			   'PAYROLL_ID');
	--
	load_context_usage(2,
			   l_function_id,
			   'DATE_EARNED');
	--
	/********* LOOP_CONTROL ***********************/
	--
	load_function('LOOP_CONTROL',
		      'N',
		      'PER_FORMULA_FUNCTIONS.LOOP_CONTROL',
                      null,
		      l_function_id);
	--
	load_parameter(1,
		       l_function_id,
		       'T', 'p_formula_name');
	--
	load_context_usage(1,
			   l_function_id,
			   'BUSINESS_GROUP_ID');
	--
	load_context_usage(2,
			   l_function_id,
			   'DATE_EARNED');
	--
	load_context_usage(3,
			   l_function_id,
			   'ASSIGNMENT_ID');
	--
	load_context_usage(4,
			   l_function_id,
			   'PAYROLL_ID');
	--
	load_context_usage(5,
			   l_function_id,
			   'ACCRUAL_PLAN_ID');
	--
	/********* SET_DATE ***********************/
	--
	load_function('SET_DATE',
		      'N',
		      'PER_FORMULA_FUNCTIONS.SET_DATE',
                      null,
		      l_function_id);
	--
	load_parameter(1,
		       l_function_id,
		       'T', 'p_name');
	--
	load_parameter(2,
		       l_function_id,
		       'D', 'p_value');
	--
	/*********  SET_TEXT ***********************/
	--
	load_function('SET_TEXT',
		      'N',
		      'PER_FORMULA_FUNCTIONS.SET_TEXT',
                      null,
		      l_function_id);
	--
	load_parameter(1,
		       l_function_id,
		       'T', 'p_name');
	--
	load_parameter(2,
		       l_function_id,
		       'T', 'p_value');
	--
	/********* GET_TEXT ***********************/
	--
	load_function('GET_TEXT',
		      'T',
		      'PER_FORMULA_FUNCTIONS.GET_TEXT',
                      null,
		      l_function_id);
	--
	load_parameter(1,
		       l_function_id,
		       'T', 'p_name');
	--
	/********* GET_DATE ***********************/
	--
	load_function('GET_DATE',
		      'D',
		      'PER_FORMULA_FUNCTIONS.GET_DATE',
                      null,
		      l_function_id);
	--
	load_parameter(1,
		       l_function_id,
		       'T', 'p_name');
	--
	/********* ISNULL ***********************/
	--
	load_function('ISNULL',
		      'T',
		      'PER_FORMULA_FUNCTIONS.ISNULL',
                      null,
		      l_function_id);
	--
	load_parameter(1,
		       l_function_id,
		       'T', 'p_value');
	--
	/********* ISNULL ***********************/
	--
	load_function('ISNULL',
		      'N',
		      'PER_FORMULA_FUNCTIONS.ISNULL',
                      null,
		      l_function_id);
	--
	load_parameter(1,
		       l_function_id,
		       'N', 'p_value');
	--
	/********* ISNULL ***********************/
	--
	load_function('ISNULL',
		      'D',
		      'PER_FORMULA_FUNCTIONS.ISNULL',
                      null,
		      l_function_id);
	--
	load_parameter(1,
		       l_function_id,
                    'D', 'p_value');
     --
     /********* REMOVE_GLOBALS ***********************/
     --
     load_function('REMOVE_GLOBALS',
                   'N',
                   'PER_FORMULA_FUNCTIONS.REMOVE_GLOBALS',
                   null,
                   l_function_id);
     --
     /********* CLEAR_GLOBALS ***********************/
     --
     load_function('CLEAR_GLOBALS',
                   'N',
                   'PER_FORMULA_FUNCTIONS.CLEAR_GLOBALS',
                   null,
                   l_function_id);
     --
     /********* DEBUG ***********************/
     --
     load_function('DEBUG',
                   'N',
                   'PER_FORMULA_FUNCTIONS.DEBUG',
                   null,
                   l_function_id);
     --
     load_parameter(1,
                    l_function_id,
                    'T', 'p_message');
     --
     /********* RAISE_ERROR ***********************/
     --
     load_function('RAISE_ERROR',
                   'N',
                   'PER_FORMULA_FUNCTIONS.RAISE_ERROR',
                   null,
                   l_function_id);
     --
     load_parameter(1,
                    l_function_id,
                    'N', 'p_application_id');
     --
     load_parameter(2,
                    l_function_id,
                    'T', 'p_message_name');
     --
     /********* GET_PAYROLL_PERIOD ***********************/
     --
     load_function('GET_PAYROLL_PERIOD',
                   'N',
                   'PER_UTILITY_FUNCTIONS.GET_PAYROLL_PERIOD',
                   null,
                   l_function_id);
     --
     load_parameter(1,
                    l_function_id,
                    'D', 'p_date_in_period');
     --
     load_context_usage(1,
                        l_function_id,
                        'PAYROLL_ID');
     --
     /********* GET_ACCRUAL_BAND ***********************/
     --
     load_function('GET_ACCRUAL_BAND',
                   'N',
                   'PER_UTILITY_FUNCTIONS.GET_ACCRUAL_BAND',
                   null,
                   l_function_id);
     --
     load_parameter(1,
                    l_function_id,
                    'N', 'p_number_of_years');
     --
     load_context_usage(1,
                        l_function_id,
                        'ACCRUAL_PLAN_ID');
     --
     /********* CALL_FORMULA ***********************/
     --
     load_function('CALL_FORMULA',
                   'N',
                   'PER_FORMULA_FUNCTIONS.CALL_FORMULA',
                   null,
                   l_function_id);
     --
     load_parameter(1,
                    l_function_id,
                    'T', 'p_formula_name');
     --
     load_context_usage(1,
                        l_function_id,
                        'BUSINESS_GROUP_ID');
     --
     load_context_usage(2,
                        l_function_id,
                        'DATE_EARNED');
     --
     load_context_usage(3,
                        l_function_id,
                        'ASSIGNMENT_ID');
     --
     load_context_usage(4,
                        l_function_id,
                        'PAYROLL_ID');
     --
     load_context_usage(5,
                        l_function_id,
                        'ACCRUAL_PLAN_ID');
     --
     /********* GET_NUMBER ***********************/
     --
     load_function('GET_NUMBER',
                   'N',
                   'PER_FORMULA_FUNCTIONS.GET_NUMBER',
                   null,
                   l_function_id);
     --
     load_parameter(1,
                    l_function_id,
                    'T', 'p_name');
     --
     /********* GET_ASSIGNMENT_STATUS ***********************/
     --
     load_function('GET_ASSIGNMENT_STATUS',
                   'N',
                   'PER_UTILITY_FUNCTIONS.GET_ASSIGNMENT_STATUS',
                   null,
                   l_function_id);
     --
     load_parameter(1,
                    l_function_id,
                    'D', 'p_effective_date');
     --
     load_context_usage(1,
                        l_function_id,
                        'ASSIGNMENT_ID');
     --
     /********* GET_PERIOD_DATES ***********************/
     --
     load_function('GET_PERIOD_DATES',
                   'N',
                   'PER_UTILITY_FUNCTIONS.GET_PERIOD_DATES',
                   null,
                   l_function_id);
     --
     load_parameter(1,
                    l_function_id,
                    'D', 'p_date_in_period');
     --
     load_parameter(2,
                    l_function_id,
                    'T', 'p_period_unit');
     --
     load_parameter(3,
                    l_function_id,
                    'D', 'p_base_start_date');
     --
     load_parameter(4,
                    l_function_id,
                    'N', 'p_unit_multiplier');
     --
     /********* SET_NUMBER ***********************/
     --
     load_function('SET_NUMBER',
                   'N',
                   'PER_FORMULA_FUNCTIONS.SET_NUMBER',
                   null,
                   l_function_id);
     --
     load_parameter(1,
                    l_function_id,
                    'T', 'p_name');
     --
     load_parameter(2,
                    l_function_id,
                    'N', 'p_value');
     --
     /********* GET_OTHER_NET_CONTRIBUTION ***********************/
     --
     load_function('GET_OTHER_NET_CONTRIBUTION',
                   'N',
                   'PER_ACCRUAL_CALC_FUNCTIONS.GET_OTHER_NET_CONTRIBUTION',
                   null,
                   l_function_id);
     --
     load_parameter(1,
                    l_function_id,
                    'D', 'p_calculation_date');
     --
     load_parameter(2,
                    l_function_id,
                    'D', 'p_start_date');
     --
     load_context_usage(1,
                        l_function_id,
                        'ASSIGNMENT_ID');
     --
     load_context_usage(2,
                        l_function_id,
                        'ACCRUAL_PLAN_ID');
     --
     /********* PUT_MESSAGE ***********************/
     --
     load_function('PUT_MESSAGE',
                   'N',
                   'PER_ACCRUAL_MESSAGE_PKG.PUT_MESSAGE',
                   null,
                   l_function_id);
     --
     load_parameter(1,
                    l_function_id,
                    'T', 'P_MESSAGE');
     --
     /********* GET_ABSENCE ***********************/
     --
     load_function('GET_ABSENCE',
                   'N',
                   'PER_ACCRUAL_CALC_FUNCTIONS.GET_ABSENCE',
                   null,
                   l_function_id);
     --
     load_parameter(1,
                    l_function_id,
                    'D', 'p_calculation_date');
     --
     load_parameter(2,
                    l_function_id,
                    'D', 'p_start_date');
     --
     load_context_usage(1,
                        l_function_id,
                        'ASSIGNMENT_ID');
     --
     load_context_usage(2,
                        l_function_id,
                        'ACCRUAL_PLAN_ID');
     --
     /********* GET_CARRY_OVER ***********************/
     --
     load_function('GET_CARRY_OVER',
                   'N',
                   'PER_ACCRUAL_CALC_FUNCTIONS.GET_CARRY_OVER',
                   null,
                   l_function_id);
     --
     load_parameter(1,
                    l_function_id,
                    'D', 'p_calculation_date');
     --
     load_parameter(2,
                    l_function_id,
                    'D', 'p_start_date');
     --
     load_context_usage(1,
                        l_function_id,
                        'ASSIGNMENT_ID');
     --
     load_context_usage(2,
                        l_function_id,
                        'ACCRUAL_PLAN_ID');
     --
     hr_utility.set_location ('hrstrdbi.insert_functions', 15);
     --
     load_function('CHK_NAT_ID_FORMAT',
                   'T',
                   'hr_ni_chk_pkg.chk_nat_id_format',
                   null,
                   l_function_id);
     --
     load_parameter(1,
                    l_function_id,
                    'T', 'national_identifer');
     --
     load_parameter(2,
                    l_function_id,
                    'T', 'format');
     --
     hr_utility.set_location ('hrstrdbi.insert_functions', 16);
     --
     load_function('COUNT_WORKING_DAYS',
                   'T',
                   'hr_cal_abs_dur_pkg.count_working_days',
                   null,
                   l_function_id);
     --
     load_parameter(1,
                    l_function_id,
                    'T', 'starting_date');
     --
     load_parameter(2,
                    l_function_id,
                    'T', 'total_days');
     --
     hr_utility.set_location ('hrstrdbi.insert_functions', 17);
     --
     /********* ITERATION_INITIALISE ***********************/
     --
     load_function('ITERATION_INITIALISE',
                   'N',
                   'pay_iterate.initialise',
                   null,
                   l_function_id);
     --
     load_parameter(1,
                    l_function_id,
                    'N', 'High Value');
     --
     load_parameter(2,
                    l_function_id,
                    'N', 'Low Value');
     --
     load_parameter(3,
                    l_function_id,
                    'N', 'Target Value');
     --
     load_context_usage(1,
                        l_function_id,
                        'ELEMENT_ENTRY_ID');
     --
     hr_utility.set_location ('hrstrdbi.insert_functions', 18);
     --
     /********* ITERATION_GET_INTERPOLATION ****************/
     --
     load_function('ITERATION_GET_INTERPOLATION',
                   'N',
                   'pay_iterate.get_interpolation_guess',
                   null,
                   l_function_id);
     --
     load_parameter(1,
                    l_function_id,
                    'N', 'Result Value');
     --
     load_context_usage(1,
                        l_function_id,
                        'ELEMENT_ENTRY_ID');
     --
     hr_utility.set_location ('hrstrdbi.insert_functions', 19);
     --
     /********* ITERATION_GET_BINARY ***********************/
     --
     load_function('ITERATION_GET_BINARY',
                   'N',
                   'pay_iterate.get_binary_guess',
                   null,
                   l_function_id);
     --
     load_parameter(1,
                    l_function_id,
                    'T', 'Mode');
     --
     load_context_usage(1,
                        l_function_id,
                        'ELEMENT_ENTRY_ID');
     --
     hr_utility.set_location ('hrstrdbi.insert_functions', 20);
     --
     /********* ITERATION_GET_HIGH ***********************/
     --
     load_function('ITERATION_GET_HIGH',
                   'N',
                   'pay_iterate.get_high_value',
                   null,
                   l_function_id);
     --
     load_context_usage(1,
                        l_function_id,
                        'ELEMENT_ENTRY_ID');
     --
     hr_utility.set_location ('hrstrdbi.insert_functions', 21);
     --
     /********* ITERATION_GET_LOW ***********************/
     --
     load_function('ITERATION_GET_LOW',
                   'N',
                   'pay_iterate.get_low_value',
                   null,
                   l_function_id);
     --
     load_context_usage(1,
                        l_function_id,
                        'ELEMENT_ENTRY_ID');
     --
     /********* ITERATION_GET_LOW ***********************/
     --
     load_function('ENTRY_PROCESSED_IN_PERIOD',
                   'T',
                   'pay_consumed_entry.consumed_entry',
                   'returns Y if the entry has been processed in a prior run in period',
                   l_function_id);
     --
     load_context_usage(1,
                        l_function_id,
                        'DATE_EARNED');
     --
     load_context_usage(2,
                        l_function_id,
                        'PAYROLL_ID');
     --
     load_context_usage(3,
                        l_function_id,
                        'ORIGINAL_ENTRY_ID');
     --
--
end insert_functions;
--
--
PROCEDURE insert_formula is
l_text                          long;
l_ftype_id                      number;
--
begin
--
     --
     --  BIS template formula TEMPLATE_BIS_DAYS_TO_HOURS
     --
l_text := '
/*********************************************************************
FORMULA NAME: TEMPLATE_BIS_DAYS_TO_HOURS
FORMULA TYPE: Quickpaint
DESCRIPTION:  Converts a number of Days to a number of Hours
--
INPUTS:         days_worked
--
DBI Required:   ASG_FULL_TIME_FREQ
                ASG_FULL_TIME_HOURS
                ASG_FREQ_CODE
                ASG_HOURS
--
Change History
--------------
Author     Date       Version  Bug      Description
---------  ---------  -------  -------  -----------
S.Bhattal  30-SEP-99  115.0    1008543  Created - non-translatable
					database items fixed.
********************************************************************/

/* Updatable Values Section */

/* Defaults Section */

DEFAULT FOR asg_full_time_freq IS ''X''
DEFAULT FOR asg_full_time_hours IS 0
DEFAULT FOR asg_freq_code IS ''X''
DEFAULT FOR asg_hours IS 0

/* Inputs Section */

INPUTS ARE days_worked

/* Main Body of Formula */

/* Set up the default number of working hours per day */
/* This is only used if no Working Conditions have been */
/* entered at any level */
dflt_hours_per_day = 8

/* Set up constants to use to divide the number of hours */
/* specified on a Working Conditions to get the number */
/* of working hours per day */
working_days_per_week = 5
working_days_per_month = 21


IF (asg_freq_code WAS NOT DEFAULTED) AND
   (asg_hours WAS NOT DEFAULTED)
THEN
(
  hours = asg_hours
  freq  = asg_freq_code
)
ELSE
(
  IF (asg_full_time_freq WAS NOT DEFAULTED) AND
     (asg_full_time_hours WAS NOT DEFAULTED)
  THEN
  (
    hours = asg_full_time_hours
    freq = asg_full_time_freq
  )
  ELSE
  (
     hours = dflt_hours_per_day
     freq = ''D''
  )
)

IF (freq = ''D'')
THEN
  hours_worked = days_worked * hours

ELSE IF (freq = ''W'')
THEN
  hours_worked = days_worked * (hours / working_days_per_week)

ELSE IF (freq = ''M'')
THEN
  hours_worked = days_worked * (hours / working_days_per_month)

ELSE
  hours_worked = 0

hours_worked = ROUND(hours_worked,2)

RETURN hours_worked
';
    --
    select formula_type_id
    into   l_ftype_id
    from   ff_formula_types
    where  formula_type_name = 'QuickPaint';
    --
    INSERT INTO ff_formulas_f
    (formula_id,
     effective_start_date,
     effective_end_date,
     business_group_id,
     legislation_code,
     formula_type_id,
     formula_name,
     description,
     formula_text,
     sticky_flag)
    VALUES
    (ff_formulas_s.nextval,
     to_date('01/01/0001','DD/MM/YYYY'),
     to_date('31/12/4712','DD/MM/YYYY'),
     NULL,
     NULL,
     l_ftype_id,
     'TEMPLATE_BIS_DAYS_TO_HOURS',
     'Template conversion from Days to Hours',
     l_text,
     NULL);
     --
     hr_utility.set_location ('hrstrdbi.insert_formula', 114);
     --
     --  BIS template formula TEMPLATE_FTE
     --
l_text := '
/*********************************************************************
FORMULA NAME: TEMPLATE_FTE
FORMULA TYPE: Quickpaint
DESCRIPTION:  Calculates Assignment Full Time Equivalent value based on
              a) the value entered in Assignmnet Budget Values Form
              b) if part time worker the ratio of the normal conditions
                 for the position, organization or business group actually
                 worked
--
INPUTS:         None
--
DBI Required:
                HRI_ASG_FULL_TIME_FREQ
                HRI_ASG_FULL_TIME_HOURS
                HRI_ASG_EMPLOYMENT_CATEGORY_CODE
                HRI_ASG_FREQ_CODE
                HRI_ASG_HOURS
--
Change History
--
Author     Date       Version  Bug      Description
---------  ---------  -------  -------  -----------
S.Bhattal  30-SEP-99  115.0    1008543  Created - non-translatable
					database items fixed.
					ASG_FTE_VALUE removed.
D.Vickers  27-MAY-2002                  HRI dbis now used
********************************************************************/

/* Updatable Values Section */

/* Defaults Section */

DEFAULT FOR hri_asg_full_time_freq IS ''X''
DEFAULT FOR hri_asg_full_time_hours IS 0
DEFAULT FOR hri_asg_employment_category_code IS ''X''
DEFAULT FOR hri_asg_freq_code IS ''X''
DEFAULT FOR hri_asg_hours IS 0

/* Inputs Section */

/* Main Body of Formula */
/* Set up the number of working hours per day, week and month
These figures are used to determine the proportion of  available time a person w
orks and the proportion of available time a Position, Organization or Business G
roup usually works */

daily_hours = 8
weekly_hours = 40
monthly_hours = 169
default_fte=0

/* If employment category is not entered then FTE cannot be calculated */

   IF hri_asg_employment_category_code WAS DEFAULTED THEN
      fte = default_fte

   ELSE
/* If assignment is Full Time then FTE=1 */

      IF hri_asg_employment_category_code = ''FR''
      OR hri_asg_employment_category_code = ''FT'' THEN
         fte = 1

   ELSE
/* If assignment is Part Time the FTE depends on working hours */

      IF hri_asg_employment_category_code = ''PR''
      OR hri_asg_employment_category_code = ''PT'' THEN

/* If either the assignment conditions or those of position, organization or bus
iness group are not entered then FTE cannot be calculated */

         IF hri_asg_full_time_freq WAS DEFAULTED
         OR hri_asg_freq_code WAS DEFAULTED THEN
            fte = default_fte

         ELSE
/* If assignment normal frequency is not the same as position, organization or b
usiness group frequency then it is necessary to convert the number of hours work
ed into a standard unit */
/* Note the value of asg_full_time_freq is the lookup_code, not the meaning
so requires no translation */
            IF NOT hri_asg_full_time_freq = hri_asg_freq_code THEN
            (
               IF hri_asg_full_time_freq = ''H'' THEN
                  hours = 1
               ELSE IF hri_asg_full_time_freq = ''D'' THEN
                  hours = daily_hours
               ELSE IF hri_asg_full_time_freq = ''W'' THEN
                  hours = weekly_hours
               ELSE IF hri_asg_full_time_freq = ''M'' THEN
                  hours = monthly_hours
               ELSE
                  hours = 0

/* For the position, organization, business group working hours calculate the pr
oportion of available hours in the month that are worked */

               IF hours = 0 THEN
                  full_time_month_ratio = 0
               ELSE
                  full_time_month_ratio = hri_asg_full_time_hours / hours

/* Now repeat the above for the assignment normal conditions */

             IF hri_asg_freq_code = ''HO'' THEN
                  hours = 1
               ELSE IF hri_asg_freq_code = ''D'' THEN
                  hours = daily_hours
               ELSE IF hri_asg_freq_code = ''W'' THEN
                  hours = weekly_hours
               ELSE IF hri_asg_freq_code = ''M'' THEN
                  hours = monthly_hours
               ELSE
                  hours = 0

/* For the assignment working hours calculate the proportion of available hours
in the month that are worked */

               IF hours = 0 THEN
                  asg_month_ratio = 0
               ELSE
                  asg_month_ratio = hri_asg_hours / hours

/* Now calculate the ratio of hours worked by the assignment to those worked in
the position, organization or business group (this is the FTE) */

               IF asg_month_ratio = 0 OR full_time_month_ratio = 0 THEN
                  fte = default_fte
               ELSE
                  fte = asg_month_ratio / full_time_month_ratio
            )
            ELSE
               fte = hri_asg_hours / hri_asg_full_time_hours

   ELSE

/* If employment category is not Part Time or Full Time the cannot calculate FTE
 */
      fte = default_fte

/* Round the calculated figure to 2 decimal places */
fte = ROUND(fte,2)

RETURN fte
';
    --
    select formula_type_id
    into   l_ftype_id
    from   ff_formula_types
    where  formula_type_name = 'QuickPaint';
    --
    INSERT INTO ff_formulas_f
    (formula_id,
     effective_start_date,
     effective_end_date,
     business_group_id,
     legislation_code,
     formula_type_id,
     formula_name,
     description,
     formula_text,
     sticky_flag)
    VALUES
    (ff_formulas_s.nextval,
     to_date('01/01/0001','DD/MM/YYYY'),
     to_date('31/12/4712','DD/MM/YYYY'),
     NULL,
     NULL,
     l_ftype_id,
     'TEMPLATE_FTE',
     'Calculates Assignment Full Time Equivalent Value',
     l_text,
     NULL);
     --
     hr_utility.set_location ('hrstrdbi.insert_formula', 115);
     --
     --  BIS template formula TEMPLATE_HEAD
     --
l_text := '
/*********************************************************************
FORMULA NAME: TEMPLATE_HEAD
FORMULA TYPE: Quickpaint
DESCRIPTION:  Calculates Assignment Headcount value based on
              a) the value entered in Assignmnet Budget Values Form
              b) if assignment is primary then 1 else 0
--
INPUTS:         None
--
DBI Required:   ASG_PRIMARY_CODE
--
Change History
--
Author     Date       Version  Bug      Description
---------  ---------  -------  -------  -----------
S.Bhattal  30-SEP-99  115.0    1008671  Created - non-translatable
					database items fixed.
					ASG_HEAD_VALUE removed.
D.Vickers  27-MAY-2002                  Use HRI dbis
********************************************************************/

/* Updatable Values Section */

/* Defaults Section */

DEFAULT FOR hri_asg_primary_code IS ''Y''

/* Inputs Section */

/* Main Body of Formula */
        IF hri_asg_primary_code = ''Y'' THEN
                headcount = 1
        ELSE
                headcount = 0

/* Round the value to 2 decimal places */
headcount = ROUND(headcount,2)

RETURN headcount
';
     --
     select formula_type_id
     into   l_ftype_id
     from   ff_formula_types
     where  formula_type_name = 'QuickPaint';
     --
      INSERT INTO ff_formulas_f
     (formula_id,
      effective_start_date,
      effective_end_date,
      business_group_id,
      legislation_code,
      formula_type_id,
      formula_name,
      description,
      formula_text,
      sticky_flag)
   VALUES
     (ff_formulas_s.nextval,
      to_date('01/01/0001','DD/MM/YYYY'),
      to_date('31/12/4712','DD/MM/YYYY'),
      NULL,
      NULL,
      l_ftype_id,
      'TEMPLATE_HEAD',
      'Calculates Assignment Headcount Value',
      l_text,
      NULL);
     --
     hr_utility.set_location ('hrstrdbi.insert_formula', 116);
     --
     --  BIS template formula EXAMPLE_BIS_OT_BAND1
     --
l_text := '
/*********************************************************************
FORMULA NAME: EXAMPLE_BIS_OT_BAND1
FORMULA TYPE: Quickpaint
DESCRIPTION:  This is an example of the syntax required for the
	      fast formualae which need to be set up for use with
	      the Hours Worked Analysis Report.  The function
	      get_hours_worked calculates total hours worked from
	      the Overtime element seeded with US Payroll.
--
INPUTS:         None
--
DBI Required:   None
--
Change History
--------------
Date       Author    Version    Description
----       ------    -------    -----------
10 Sep 98  jmay      110.0      Created
--
16-SEP-98  mmillmor  110.2      Added a header
--
26 Nov 98  sbhattal  110.3      Create FastFormula type Quickpaint if it
				does not exist (required for fresh HR databases
				which have not had the HR post-install steps
				applied, or for BIS customers who do not have
				HR).
--
********************************************************************/

/* Updatable Values Section */

/* Defaults Section */

/* Inputs Section */

/* Main Body of Formula */
hours_worked = get_hours_worked(1.5)

RETURN hours_worked
';
    --
    select formula_type_id
    into   l_ftype_id
    from   ff_formula_types
    where  formula_type_name = 'QuickPaint';
    --
      INSERT INTO ff_formulas_f
     (formula_id,
      effective_start_date,
      effective_end_date,
      business_group_id,
      legislation_code,
      formula_type_id,
      formula_name,
      description,
      formula_text,
      sticky_flag)
   VALUES
     (ff_formulas_s.nextval,
      to_date('01/01/0001','DD/MM/YYYY'),
      to_date('31/12/4712','DD/MM/YYYY'),
      NULL,
      NULL,
      l_ftype_id,
      'EXAMPLE_BIS_OT_BAND1',
      'Calculate Overtime',
      l_text,
      NULL);
     --
     hr_utility.set_location ('hrstrdbi.insert_formula', 117);
    --
l_text := '
DEFAULT FOR ACP_CONTINUOUS_SERVICE_DATE IS ''4712/12/31 00:00:00'' (date)
DEFAULT FOR ACP_SERVICE_START_DATE IS ''4712/12/31 00:00:00'' (date)

INPUTS ARE
Calculation_Date (date),
Accrual_term (text)

IF (Accrual_Term = ''CURRENT'') THEN
(
  /* Set the effective date of the carryover to the end date
     of the last payroll period of this year */
  Temp_Effective_date = to_date(''3112'' + to_char(Calculation_date, ''YYYY''), ''DDMMYYYY'')

  E = GET_PAYROLL_PERIOD(Temp_Effective_date)
  Calculation_Period_SD  = get_date(''PAYROLL_PERIOD_START_DATE'')
  Calculation_Period_ED = get_date(''PAYROLL_PERIOD_END_DATE'')

  IF (to_char(Calculation_Period_ED, ''YYYY'') <> to_char(Calculation_Period_SD, ''YYYY'')) THEN
  (
    E = GET_PAYROLL_PERIOD(add_days(Calculation_Period_SD, -1))
    Calculation_Period_SD  = get_date(''PAYROLL_PERIOD_START_DATE'')
    Calculation_Period_ED = get_date(''PAYROLL_PERIOD_END_DATE'')
  )

  Effective_date = Calculation_Period_ED

  /* Set the expiry date of the carryover to the end date
     of the last payroll period of next year */
  Temp_Expiry_date = to_date(''3112'' + to_char(add_years(Calculation_date, 1)
                                        ,''YYYY''), ''DDMMYYYY'')

  E = GET_PAYROLL_PERIOD(Temp_Expiry_date)
  Calculation_Period_SD = get_date(''PAYROLL_PERIOD_START_DATE'')
  Calculation_Period_ED = get_date(''PAYROLL_PERIOD_END_DATE'')

  IF (to_char(Calculation_Period_ED, ''YYYY'') <> to_char(Calculation_Period_SD,''YYYY'')) THEN
  (
   E = GET_PAYROLL_PERIOD(add_days(Calculation_Period_SD, -1))
    Calculation_Period_SD  = get_date(''PAYROLL_PERIOD_START_DATE'')
    Calculation_Period_ED = get_date(''PAYROLL_PERIOD_END_DATE'')
  )

  Expiry_Date = Calculation_Period_ED

)
ELSE IF (Accrual_term = ''PREVIOUS'') THEN
(
  /* Set the effective date of the carryover to the end date
     of the last payroll period of last year */
  Temp_Effective_date = ADD_DAYS(to_date(''0101'' + to_char(Calculation_date, ''YYYY''), ''DDMMYYYY''), -1)

  E = GET_PAYROLL_PERIOD(Temp_Effective_date)
  Calculation_Period_SD  = get_date(''PAYROLL_PERIOD_START_DATE'')
  Calculation_Period_ED = get_date(''PAYROLL_PERIOD_END_DATE'')

  IF (to_char(Calculation_Period_ED, ''YYYY'') <> to_char(Calculation_Period_SD, ''YYYY'')) THEN
  (
    E = GET_PAYROLL_PERIOD(add_days(Calculation_Period_SD, -1))
    Calculation_Period_SD  = get_date(''PAYROLL_PERIOD_START_DATE'')
    Calculation_Period_ED = get_date(''PAYROLL_PERIOD_END_DATE'')
  )

  Effective_date = Calculation_Period_ED

  /* Set the expiry date of the carryover to the end date
     of the last payroll period of this year */
  Temp_Expiry_date = to_date(''3112'' + to_char(Calculation_date, ''YYYY''), ''DDMMYYYY'')

  E = GET_PAYROLL_PERIOD(Temp_Expiry_date)
  Calculation_Period_SD  = get_date(''PAYROLL_PERIOD_START_DATE'')
  Calculation_Period_ED = get_date(''PAYROLL_PERIOD_END_DATE'')

  IF (to_char(Calculation_Period_ED, ''YYYY'') <> to_char(Calculation_Period_SD, ''YYYY'')) THEN
  (
    E = GET_PAYROLL_PERIOD(add_days(Calculation_Period_SD, -1))
    Calculation_Period_SD  = get_date(''PAYROLL_PERIOD_START_DATE'')
    Calculation_Period_ED = get_date(''PAYROLL_PERIOD_END_DATE'')
  )

  Expiry_Date = Calculation_Period_ED
)

IF ACP_CONTINUOUS_SERVICE_DATE WAS DEFAULTED THEN
(
  Continuous_Service_Date = ACP_SERVICE_START_DATE
)
ELSE
(
  Continuous_Service_Date = ACP_CONTINUOUS_SERVICE_DATE
)

Years_service = floor(months_between(Effective_date, Continuous_Service_Date) / 12)

IF (GET_ACCRUAL_BAND(years_service) = 0) THEN
(
  Max_carryover = GET_NUMBER(''MAX_CARRY_OVER'')
)
ELSE
(
  Max_carryover = 0
)

Process = ''YES''

RETURN Max_Carryover, Effective_date, Expiry_Date, Process
';
    --
    select formula_type_id
    into   l_ftype_id
    from   ff_formula_types
    where  formula_type_name = 'Accrual Carryover';
    --
      INSERT INTO ff_formulas_f
     (formula_id,
      effective_start_date,
      effective_end_date,
      business_group_id,
      legislation_code,
      formula_type_id,
      formula_name,
      description,
      formula_text,
      sticky_flag)
   VALUES
     (ff_formulas_s.nextval,
      to_date('01/01/0001','DD/MM/YYYY'),
      to_date('31/12/4712','DD/MM/YYYY'),
      NULL,
      NULL,
      l_ftype_id,
      'PTO_PAYROLL_CARRYOVER',
      'Seeded carry over payroll formula for PTO accruals',
      l_text,
      NULL);
     --
     hr_utility.set_location ('hrstrdbi.insert_formula', 118);
    --
l_text := '
/* ------------------------------------------------------------------------
    NAME : PTO_PAYROLL_PERIOD_ACCRUAL
    This formula calculates the amount of PTO accrued for a particular payroll period
   ---------------------------------------------------------------------*/

/*------------------------------------------------------------------------
    Get the global variable to be used in this formula
 ------------------------------------------------------------------------*/

Payroll_Year_Number_Of_Periods = get_number(''PAYROLL_YEAR_NUMBER_OF_PERIODS'')
Continuous_Service_Date = get_date(''CONTINUOUS_SERVICE_DATE'')
Total_Accrued_PTO = get_number(''TOTAL_ACCRUED_PTO'')
Period_SD = get_date(''PERIOD_SD'')
Period_ED = get_date(''PERIOD_ED'')
Last_Period_SD = get_date(''LAST_PERIOD_SD'')
Last_Period_ED = get_date(''LAST_PERIOD_ED'')
Payroll_Year_SD = get_date(''PAYROLL_YEAR_SD'')

/*----------------------------------------------------------------------
    Determine the Accrual Band that applies this period
    1. If upper limit is not set then find the band spanning the continuous service number of years
    2. If the band is not found then end the processing for this period
    3. If continuous service is less than the upper limit then use the globals as they are
    4. If continuous service is greater than or equal to the upper limit then reset the globals
  ----------------------------------------------------------------------*/

Annual_Rate = get_number(''ANNUAL_RATE'')
Upper_Limit = get_number(''UPPER_LIMIT'')
Ceiling = get_number(''CEILING'')

Years_Service = Floor(Months_Between(Period_ED,Continuous_Service_Date)/12)

IF (Upper_Limit = 0 OR
     Years_Service >= Upper_Limit ) THEN
   (
    IF ( GET_ACCRUAL_BAND(Years_Service) = 0 ) THEN
        (
         Annual_Rate = get_number(''ANNUAL_RATE'')
         Upper_Limit = get_number(''UPPER_LIMIT'')
         Ceiling = get_number(''CEILING'')
        )
    ELSE
       (
        Continue_Processing_Flag = ''N''
        Return Continue_Processing_Flag
        )
   )

Accrual_Rate = Annual_Rate / Payroll_Year_Number_Of_Periods

/* ----------------------------------------------------------------------
    Calculate the Amount Accrued this Period excluding time where
    the assignment was not active.
   ---------------------------------------------------------------------*/

Assignment_Inactive_Days = GET_ASG_INACTIVE_DAYS(Period_SD, Period_ED)

IF Assignment_Inactive_Days <> 0 THEN
    (
     Working_Days = GET_WORKING_DAYS(Period_SD, Period_ED)
         IF Working_Days = Assignment_Inactive_Days THEN
              (
               Multiplier = 0
               )
         ELSE
              (
               Multiplier = 1 - (Assignment_Inactive_Days / Working_Days)
               )
     )
ELSE
   (
    Multiplier = 1
    )

Period_Accrued_PTO = Accrual_Rate * Multiplier

/* ----------------------------------------------------------------------
    Calculate any absence or bought/sold time etc. to be accounted for in this period.
   ---------------------------------------------------------------------*/

Absence = GET_ABSENCE(Period_ED, Payroll_Year_SD)
CarryOver = GET_CARRY_OVER(Period_ED, Payroll_Year_SD)
Other = GET_OTHER_NET_CONTRIBUTION(Period_ED, Payroll_Year_SD)

Period_Others = CarryOver + Other - Absence

/* ----------------------------------------------------------------------
    Now establish whether the Accrual this period has gone over the ceiling if one exists
   ----------------------------------------------------------------------*/

IF (Ceiling > 0) THEN
    (
     IF (Total_Accrued_PTO + Period_Accrued_PTO + Period_Others > Ceiling) THEN
         (
          Amount_Over_Ceiling = Total_Accrued_PTO + Period_Accrued_PTO + Period_Others - Ceiling
          IF (Amount_Over_Ceiling > Period_Accrued_PTO) THEN
               (
               Period_Accrued_PTO = 0
               )
          ELSE
              (
               Period_Accrued_PTO = Period_Accrued_PTO - Amount_Over_Ceiling
              )
          )
     )

/*---------------------------------------------------------------------
    Set the Running Total
  ---------------------------------------------------------------------*/

E = set_number(''TOTAL_ACCRUED_PTO'',Total_Accrued_PTO + Period_Accrued_PTO)


/* ----------------------------------------------------------------------
    Establish whether the current period is the last one, if so end the processing, otherwise get the
    next period
------------------------------------------------------------------------*/

IF Period_SD = Last_Period_SD THEN
    (
    Continue_Processing_Flag = ''N''
    )
ELSE
   (
    E = GET_PAYROLL_PERIOD(ADD_DAYS(Period_ED,1))
    E = set_date(''PERIOD_SD'',get_date(''PAYROLL_PERIOD_START_DATE''))
    E = set_date(''PERIOD_ED'',get_date(''PAYROLL_PERIOD_END_DATE''))

   Continue_Processing_Flag = ''Y''
   )

Return Continue_Processing_Flag
';
    --
    select formula_type_id
    into   l_ftype_id
    from   ff_formula_types
    where  formula_type_name = 'Accrual Subformula';
    --
     INSERT INTO ff_formulas_f
     (formula_id,
      effective_start_date,
      effective_end_date,
      business_group_id,
      legislation_code,
      formula_type_id,
      formula_name,
      description,
      formula_text,
      sticky_flag)
   VALUES
     (ff_formulas_s.nextval,
      to_date('01/01/0001','DD/MM/YYYY'),
      to_date('31/12/4712','DD/MM/YYYY'),
      NULL,
      NULL,
      l_ftype_id,
      'PTO_PAYROLL_PERIOD_ACCRUAL',
      'Seeded looping payroll formula for PTO accruals',
      l_text,
      NULL);
    --
    hr_utility.set_location ('hrstrdbi.insert_formula', 119);
    --
l_text := '
/* ------------------------------------------------------------------------
    NAME : PTO_PAYROLL_CALCULATION
    This formula calculates the dates between which an assignment is to accrue time
   ---------------------------------------------------------------------*/

DEFAULT FOR ACP_START IS ''HD''
DEFAULT FOR ACP_INELIGIBILITY_PERIOD_TYPE IS ''CM''
DEFAULT FOR ACP_INELIGIBILITY_PERIOD_LENGTH IS 0
DEFAULT FOR ACP_CONTINUOUS_SERVICE_DATE IS ''4712/12/31 00:00:00'' (date)
DEFAULT FOR ACP_ENROLLMENT_END_DATE IS ''4712/12/31 00:00:00'' (date)
DEFAULT FOR ACP_TERMINATION_DATE IS ''4712/12/31 00:00:00'' (date)
DEFAULT FOR ACP_ENROLLMENT_START_DATE IS ''4712/12/31 00:00:00'' (date)
DEFAULT FOR ACP_SERVICE_START_DATE IS ''4712/12/31 00:00:00'' (date)

INPUTS ARE
Calculation_Date (date)

E = CALCULATE_PAYROLL_PERIODS()

/*-----------------------------------------------------------------------
   For the payroll year that spans the Calculation Date
   get the first days of the payroll year
  ----------------------------------------------------------------------- */

Payroll_Year_First_Valid_Date = GET_DATE(''PAYROLL_YEAR_FIRST_VALID_DATE'')
E = SET_DATE(''PAYROLL_YEAR_SD'', Payroll_Year_First_Valid_Date)

/* ------------------------------------------------------------------------
   Set the Calculation_Date to the Termination Date / Enrollment end date if not defaulted
-------------------------------------------------------------------------- */

IF NOT (ACP_TERMINATION_DATE WAS DEFAULTED) OR
    NOT (ACP_ENROLLMENT_END_DATE WAS DEFAULTED) THEN
(
  Early_End_Date = least(ACP_TERMINATION_DATE, ACP_ENROLLMENT_END_DATE)

  IF (Early_End_Date < Calculation_Date) THEN
  (
    Calculation_Date = Early_End_Date
  )
)

/* ------------------------------------------------------------------------
   Get the last whole payroll period prior to the Calculation Date and ensure that it is within the
   Payroll Year (if the Calculation Date is the End of a Period then use that period)
   ------------------------------------------------------------------------ */

E = GET_PAYROLL_PERIOD(Calculation_Date)
Calculation_Period_SD  = get_date(''PAYROLL_PERIOD_START_DATE'')
Calculation_Period_ED = get_date(''PAYROLL_PERIOD_END_DATE'')

IF (Calculation_Date <> Calculation_Period_ED) THEN
    (
     E = GET_PAYROLL_PERIOD(ADD_DAYS(Calculation_Period_SD,-1))
    Calculation_Period_SD  = get_date(''PAYROLL_PERIOD_START_DATE'')
    Calculation_Period_ED = get_date(''PAYROLL_PERIOD_END_DATE'')
   )


/* ------------------------------------------------------------------------
   Set the Continuous Service Global Variable, whilst also
   ensuring that the continuous service date is before the Calculation Period
  ------------------------------------------------------------------------ */

IF (ACP_CONTINUOUS_SERVICE_DATE WAS DEFAULTED) THEN
    (
    E = set_date(''CONTINUOUS_SERVICE_DATE'', ACP_SERVICE_START_DATE)
    )
ELSE IF(ACP_CONTINUOUS_SERVICE_DATE > Calculation_Period_SD) THEN
   (
    Total_Accrued_PTO = 0
    E = PUT_MESSAGE(''HR_52796_PTO_FML_CSD'')
    E = set_date(''CONTINUOUS_SERVICE_DATE'', ACP_CONTINUOUS_SERVICE_DATE)
   )
ELSE
  (
    E = set_date(''CONTINUOUS_SERVICE_DATE'', ACP_CONTINUOUS_SERVICE_DATE)
  )

/* ------------------------------------------------------------------------
   Determine the Accrual Start Rule and modify the start date of the accrual calculation accordingly

   N.B. In this calculation the Accrual Start Rule determines the date from which a person may first accrue
   PTO. The Ineligibility Rule determines the period of time during which the PTO is not registered.
   Once this date has passed the accrual is registered from the date determined by the Accrual Start Rule.
 ------------------------------------------------------------------------ */

Continuous_Service_Date = get_date(''CONTINUOUS_SERVICE_DATE'')

IF (ACP_START = ''BOY'') THEN
    (
     First_Eligible_To_Accrue_Date =
         to_date(''01/01/''||to_char(add_months(Continuous_Service_Date, 12), ''YYYY''),
                       ''DD/MM/YYYY'')
     )
ELSE IF (ACP_START = ''PLUS_SIX_MONTHS'') THEN
    (
     First_Eligible_To_Accrue_Date = add_months(Continuous_Service_Date,6)
     )
ELSE IF (ACP_START = ''HD'') THEN
    (
     First_Eligible_To_Accrue_Date  = Continuous_Service_Date
     )

/*------------------------------------------------------------------------
   Determine the date on which accrued PTo may first be registered, i.e the date on which the
   Ineligibility Period expires
   ------------------------------------------------------------------------ */

Accrual_Ineligibility_Expired_Date = First_Eligible_To_Accrue_Date

IF (ACP_START <> ''PLUS_SIX_MONTHS'' AND
     ACP_INELIGIBILITY_PERIOD_LENGTH > 0) THEN
   (
   IF ACP_INELIGIBILITY_PERIOD_TYPE = ''BM'' THEN
      (
      Accrual_Ineligibility_Expired_Date = add_months(Continuous_Service_Date,
                                                    ACP_INELIGIBILITY_PERIOD_LENGTH*2)
      )
   ELSE IF ACP_INELIGIBILITY_PERIOD_TYPE = ''F'' THEN
      (
      Accrual_Ineligibility_Expired_Date = add_days(Continuous_Service_Date,
                                                    ACP_INELIGIBILITY_PERIOD_LENGTH*14)
      )
   ELSE IF ACP_INELIGIBILITY_PERIOD_TYPE = ''CM'' THEN
      (
      Accrual_Ineligibility_Expired_Date = add_months(Continuous_Service_Date,
                                                      ACP_INELIGIBILITY_PERIOD_LENGTH)
      )
   ELSE IF ACP_INELIGIBILITY_PERIOD_TYPE = ''LM'' THEN
      (
      Accrual_Ineligibility_Expired_Date = add_days(Continuous_Service_Date,
                                                  ACP_INELIGIBILITY_PERIOD_LENGTH*28)
      )
   ELSE IF ACP_INELIGIBILITY_PERIOD_TYPE = ''Q'' THEN
      (
      Accrual_Ineligibility_Expired_Date = add_months(Continuous_Service_Date,
                                                      ACP_INELIGIBILITY_PERIOD_LENGTH*3)
      )
   ELSE IF ACP_INELIGIBILITY_PERIOD_TYPE = ''SM'' THEN
      (
      Accrual_Ineligibility_Expired_Date = add_months(Continuous_Service_Date,
                                                      ACP_INELIGIBILITY_PERIOD_LENGTH/2)
      )
   ELSE IF ACP_INELIGIBILITY_PERIOD_TYPE = ''SY'' THEN
      (
      Accrual_Ineligibility_Expired_Date = add_months(Continuous_Service_Date,
                                                      ACP_INELIGIBILITY_PERIOD_LENGTH*6)
      )
   ELSE IF ACP_INELIGIBILITY_PERIOD_TYPE = ''W'' THEN
      (
      Accrual_Ineligibility_Expired_Date = add_days(Continuous_Service_Date,
                                                    ACP_INELIGIBILITY_PERIOD_LENGTH*7)
      )
   ELSE IF ACP_INELIGIBILITY_PERIOD_TYPE = ''Y'' THEN
      (
      Accrual_Ineligibility_Expired_Date = add_months(Continuous_Service_Date,
                                                      ACP_INELIGIBILITY_PERIOD_LENGTH*12)
      )

   IF Accrual_Ineligibility_Expired_Date > First_Eligible_To_Accrue_Date
   AND Calculation_Date < Accrual_Ineligibility_Expired_Date THEN
      (
      First_Eligible_To_Accrue_Date = Accrual_Ineligibility_Expired_Date
      )
   )


/* ----------------------------------------------------------------------
  If the employee is eligible to accrue before the start of this year,
  we must get the period dates for the first period of the year.
  Otherwise, we do not need these dates, as we will never accrue that
  far back.
----------------------------------------------------------------------- */

IF First_Eligible_To_Accrue_Date <= Payroll_Year_First_Valid_Date THEN
(
  E = GET_PAYROLL_PERIOD(Payroll_Year_First_Valid_Date)

  Payroll_Year_1st_Period_SD = get_date(''PAYROLL_PERIOD_START_DATE'')
  Payroll_Year_1st_Period_ED = get_date(''PAYROLL_PERIOD_END_DATE'')

  IF Payroll_Year_1st_Period_SD <> Payroll_Year_First_Valid_Date THEN
  (
     E = GET_PAYROLL_PERIOD(ADD_DAYS(Payroll_Year_1st_Period_ED, 1))

    Payroll_Year_1st_Period_SD = get_date(''PAYROLL_PERIOD_START_DATE'')
    Payroll_Year_1st_Period_ED = get_date(''PAYROLL_PERIOD_END_DATE'')
  )

  Effective_Start_Date = Payroll_Year_First_Valid_Date

)
ELSE
(
  /* ------------------------------------------------------------------------
   Get the first full payroll period following the First_Eligible_To_Accrue_Date
   (if it falls on the beginning of the period then use that period)
  ------------------------------------------------------------------------- */

  E = GET_PAYROLL_PERIOD(First_Eligible_To_Accrue_Date )
  First_Eligible_To_Accrue_Period_SD  = get_date(''PAYROLL_PERIOD_START_DATE'')
  First_Eligible_To_Accrue_Period_ED  = get_date(''PAYROLL_PERIOD_END_DATE'')

  IF First_Eligible_To_Accrue_Date <> First_Eligible_To_Accrue_Period_SD THEN
  (
    E = GET_PAYROLL_PERIOD(add_days(First_Eligible_To_Accrue_Period_ED,1))
    First_Eligible_To_Accrue_Period_SD  = get_date(''PAYROLL_PERIOD_START_DATE'')
    First_Eligible_To_Accrue_Period_ED  = get_date(''PAYROLL_PERIOD_END_DATE'')
   )

  IF (First_Eligible_To_Accrue_Period_SD > Calculation_Period_ED) THEN
  (
    Total_Accrued_PTO = 0
    E = PUT_MESSAGE(''HR_52793_PTO_FML_ASG_INELIG'')
  )


  Payroll_Year_1st_Period_SD = First_Eligible_To_Accrue_Period_SD
  Payroll_Year_1st_Period_ED = First_Eligible_To_Accrue_Period_ED

  Effective_Start_Date = First_Eligible_To_Accrue_Date

)
  Effective_Start_Date = GREATEST(Effective_Start_Date, ACP_ENROLLMENT_START_DATE)


/* -----------------------------------------------------------------
  Output messages based on calculated date
----------------------------------------------------------------- */

IF (Early_End_Date < Payroll_Year_1st_Period_ED) THEN
(
  Total_Accrued_PTO = 0
  E = PUT_MESSAGE(''HR_52794_PTO_FML_ASG_TER'')
)

If (Calculation_Period_ED < Payroll_Year_1st_Period_ED) THEN
(
  Total_Accrued_PTO = 0
  E = PUT_MESSAGE(''HR_52795_PTO_FML_CALC_DATE'')
)



/* ------------------------------------------------------------------------
   Determine the date on which PTO actually starts accruing based on Hire Date,
   Continuous Service Date and plan Enrollment Start Date. Remember, we have already determined
   whether to user hire date or CSD earlier in the formula.
   If this date is after the 1st period and the fisrt eligible date then establish the first full payroll period
   after this date (if the Actual Start Date falls on the beginning of a payroll period then use this period)
 ------------------------------------------------------------------------ */

 Enrollment_Start_Date = ACP_ENROLLMENT_START_DATE

 Actual_Accrual_Start_Date = GREATEST(Enrollment_Start_Date,
                                      Continuous_Service_Date,
                                      Payroll_Year_1st_Period_SD)

/* -------------------------------------------------------------------------
       Determine the actual start of the accrual calculation
-------------------------------------------------------------------------*/
IF (Actual_Accrual_Start_Date > Payroll_Year_1st_Period_SD AND
     Actual_Accrual_Start_Date > First_Eligible_To_Accrue_Date) THEN
    (
     E = GET_PAYROLL_PERIOD(Actual_Accrual_Start_Date)

     Accrual_Start_Period_SD = get_date(''PAYROLL_PERIOD_START_DATE'')
     Accrual_Start_Period_ED = get_date(''PAYROLL_PERIOD_END_DATE'')

     IF Actual_Accrual_Start_Date > Accrual_Start_Period_SD THEN
         (
          E = GET_PAYROLL_PERIOD(add_days(Accrual_Start_Period_ED,1))

          Accrual_Start_Period_SD = get_date(''PAYROLL_PERIOD_START_DATE'')
          Accrual_Start_Period_ED = get_date(''PAYROLL_PERIOD_END_DATE'')
         )

/* -----------------------------------------------------------------
        If the Actual Acrual Period is after the Calculation Period then end the processing.
----------------------------------------------------------------- */
        IF (Accrual_Start_Period_SD > Calculation_Period_ED) THEN
            (
            Total_Accrued_PTO = 0
            E = PUT_MESSAGE(''HR_52797_PTO_FML_ACT_ACCRUAL'')
            )
     )

ELSE IF (First_Eligible_To_Accrue_Date > Payroll_Year_1st_Period_SD) THEN
     (
          Accrual_Start_Period_SD = First_Eligible_To_Accrue_Period_SD
          Accrual_Start_Period_ED = First_Eligible_To_Accrue_Period_ED
     )
ELSE
    (
          Accrual_Start_Period_SD = Payroll_Year_1st_Period_SD
          Accrual_Start_Period_ED = Payroll_Year_1st_Period_ED
    )

 /* -------------------------------------------------------------------
       Now set up the information that will be used in when looping through the payroll periods
--------------------------------------------------------------------- */

IF Calculation_Period_ED >= Accrual_Start_Period_ED THEN
(
E = set_date(''PERIOD_SD'',Accrual_Start_Period_SD)
E = set_date(''PERIOD_ED'',Accrual_Start_Period_ED)
E = set_date(''LAST_PERIOD_SD'',Calculation_Period_SD)
E = set_date(''LAST_PERIOD_ED'',Calculation_Period_ED)
E = set_number(''TOTAL_ACCRUED_PTO'',0)

/* -------------------------------------------------------------------
       Initialize Band Information
-------------------------------------------------------------------- */

E = set_number(''ANNUAL_RATE'', 0)
E = set_number(''UPPER_LIMIT'', 0)
E = set_number(''CEILING'', 0)

E = LOOP_CONTROL(''PTO_PAYROLL_PERIOD_ACCRUAL'')

Total_Accrued_PTO = get_number(''TOTAL_ACCRUED_PTO'')
)

IF Accrual_Start_Period_SD <= Calculation_Period_SD THEN
(
  Accrual_end_date = Calculation_Period_ED
)

IF Effective_Start_Date > Actual_Accrual_Start_Date THEN
(
  Effective_Start_Date = Actual_Accrual_Start_Date
)

Effective_End_Date = Calculation_Date

IF Effective_Start_Date >= Effective_End_Date THEN
(
  Effective_Start_Date = least(Effective_End_Date, Accrual_Start_Period_SD)
)

RETURN Total_Accrued_PTO, Effective_start_date, Effective_end_date, Accrual_end_date
';
    --
    select formula_type_id
    into   l_ftype_id
    from   ff_formula_types
    where  formula_type_name = 'Accrual';
    --
     INSERT INTO ff_formulas_f
     (formula_id,
      effective_start_date,
      effective_end_date,
      business_group_id,
      legislation_code,
      formula_type_id,
      formula_name,
      description,
      formula_text,
      sticky_flag)
   VALUES
     (ff_formulas_s.nextval,
      to_date('01/01/0001','DD/MM/YYYY'),
      to_date('31/12/4712','DD/MM/YYYY'),
      NULL,
      NULL,
      l_ftype_id,
      'PTO_PAYROLL_CALCULATION',
      'Seeded top level payroll formula for PTO accruals',
      l_text,
      NULL);
    --
    hr_utility.set_location ('hrstrdbi.insert_formula', 120);
    --
l_text := '
/* ------------------------------------------------------------------------
    NAME : PTO_ROLLING_CARRYOVER
    This formula is the seeded carryover formula for the rolling year accrual plan. Alth ough
    carryover has no meaning for a plan of this kind, we still require a formula for use by the absence
    screen. This formula simply returns calculation date, and zero.
   ---------------------------------------------------------------------*/

INPUTS ARE
Calculation_Date (date)

Max_Carryover = 0
Effective_Date = Calculation_Date
Expiry_Date = Calculation_Date

RETURN Max_Carryover, Effective_date, Expiry_Date
';
    --
    select formula_type_id
    into   l_ftype_id
    from   ff_formula_types
    where  formula_type_name = 'Accrual Carryover';
    --
    INSERT INTO ff_formulas_f
     (formula_id,
      effective_start_date,
      effective_end_date,
      business_group_id,
      legislation_code,
      formula_type_id,
      formula_name,
      description,
      formula_text,
      sticky_flag)
   VALUES
     (ff_formulas_s.nextval,
      to_date('01/01/0001','DD/MM/YYYY'),
      to_date('31/12/4712','DD/MM/YYYY'),
      NULL,
      NULL,
      l_ftype_id,
      'PTO_ROLLING_CARRYOVER',
      'Seeded carry over rolling formula for PTO accruals',
      l_text,
      NULL);
    --
    hr_utility.set_location ('hrstrdbi.insert_formula', 121);
    --
l_text := '
/* ------------------------------------------------------------------------
    NAME : PTO_ROLLING_PERIOD_ACCRUAL
    This formula calculates the amount of PTO accrued for a particular period. It is a seeded formula
    called by PTO_ROLLING_ACCRUAL.
   ----------------------------------------------------------------------*/

/*-----------------------------------------------------------------------
    Get the global variables to be used in this formula
 ------------------------------------------------------------------------*/

Continuous_Service_Date = get_date(''CONTINUOUS_SERVICE_DATE'')
End_of_Term = get_date(''END_OF_TERM'')
Beginning_of_Term = get_date(''BEGINNING_OF_TERM'')
Total_Accrued_PTO = get_number(''TOTAL_ACCRUED_PTO'')
Period_SD = get_date(''PERIOD_SD'')
Period_ED = get_date(''PERIOD_ED'')
Last_Period_SD = get_date(''LAST_PERIOD_SD'')
Last_Period_ED = get_date(''LAST_PERIOD_ED'')

Accrual_Rate = get_number(''ACCRUAL_RATE'')
Accruing_Frequency = get_text(''ACCRUING_FREQUENCY'')
Accruing_Multiplier = get_number(''ACCRUING_MULTIPLIER'')

Ceiling = get_number(''CEILING'')

/* ----------------------------------------------------------------------
    Calculate the Amount Accrued this Period
   ---------------------------------------------------------------------*/

Period_Accrued_PTO = Accrual_Rate

/* ----------------------------------------------------------------------
    Calculate any absence or bought/sold time etc. to be accounted for in this period.
   ---------------------------------------------------------------------*/

Absence = GET_ABSENCE(Period_ED, Beginning_of_Term)
CarryOver = GET_CARRY_OVER(Period_ED, Beginning_of_Term)
Other = GET_OTHER_NET_CONTRIBUTION(Period_ED, Beginning_of_Term)

Period_Others = CarryOver + Other - Absence

/* ----------------------------------------------------------------------
    Now establish whether the Accrual this period has gone over the ceiling if one exists. If so,
    reduce the accrual by the amount over the ceiling.
   ----------------------------------------------------------------------*/

IF (Ceiling > 0) THEN
    (
     IF (Total_Accrued_PTO + Period_Accrued_PTO + Period_Others > Ceiling) THEN
         (
          Amount_Over_Ceiling = Total_Accrued_PTO + Period_Accrued_PTO + Period_Others - Ceiling
          IF (Amount_Over_Ceiling > Period_Accrued_PTO) THEN
               (
               Period_Accrued_PTO = 0
               )
          ELSE
              (
               Period_Accrued_PTO = Period_Accrued_PTO - Amount_Over_Ceiling
              )
          )
     )

/*---------------------------------------------------------------------
    Set the Running Total
  ---------------------------------------------------------------------*/

E = set_number(''TOTAL_ACCRUED_PTO'',Total_Accrued_PTO + Period_Accrued_PTO)

/* ---------------------------------------------------------------------
    Establish whether the current period is the last one, if so end the processing, otherwise get the
    next period
------------------------------------------------------------------------*/

IF Period_SD >= Last_Period_SD THEN
    (
    Continue_Processing_Flag = ''N''
    )
ELSE
   (
    E = GET_PERIOD_DATES(ADD_DAYS(Period_ED,1),
                                               Accruing_Frequency,
                                               End_of_Term,
                                               Accruing_Multiplier)

    E = set_date(''PERIOD_SD'', get_date(''PERIOD_START_DATE''))
    E = set_date(''PERIOD_ED'', get_date(''PERIOD_END_DATE''))

   Continue_Processing_Flag = ''Y''
   )

Return Continue_Processing_Flag
';
    --
    select formula_type_id
    into   l_ftype_id
    from   ff_formula_types
    where  formula_type_name = 'Accrual Subformula';
    --
    INSERT INTO ff_formulas_f
     (formula_id,
      effective_start_date,
      effective_end_date,
      business_group_id,
      legislation_code,
      formula_type_id,
      formula_name,
      description,
      formula_text,
      sticky_flag)
   VALUES
     (ff_formulas_s.nextval,
      to_date('01/01/0001','DD/MM/YYYY'),
      to_date('31/12/4712','DD/MM/YYYY'),
      NULL,
      NULL,
      l_ftype_id,
      'PTO_ROLLING_PERIOD_ACCRUAL',
      'Seeded looping rolling formula for PTO accruals',
      l_text,
      NULL);
    --
    hr_utility.set_location ('hrstrdbi.insert_formula', 122);
    --
l_text := '
/* ------------------------------------------------------------------------
    NAME : PTO_ROLLING_ACCRUAL
    This seeded formula calculates the dates between which an assignment is to accrue time. It calls
    another formula (PTO_ROLLING_PERIOD_ACCRUAL) to calculate the gross accrual in each period.
    It is designed to be used with the carryover formula, PTO_ROLLING_CARRYOVER.
   ---------------------------------------------------------------------*/

DEFAULT FOR ACP_INELIGIBILITY_PERIOD_TYPE IS ''CM''
DEFAULT FOR ACP_INELIGIBILITY_PERIOD_LENGTH IS 0
DEFAULT FOR ACP_CONTINUOUS_SERVICE_DATE IS ''4712/12/31 00:00:00'' (date)
DEFAULT FOR ACP_ENROLLMENT_END_DATE IS ''4712/12/31 00:00:00'' (date)
DEFAULT FOR ACP_TERMINATION_DATE IS ''4712/12/31 00:00:00'' (date)
DEFAULT FOR ACP_ENROLLMENT_START_DATE IS ''4712/12/31 00:00:00'' (date)
DEFAULT FOR ACP_SERVICE_START_DATE IS ''4712/12/31 00:00:00'' (date)

INPUTS ARE
Calculation_Date (date)

E = SET_NUMBER(''CEILING'', 20)
E = SET_NUMBER(''ACCRUAL_RATE'', 2)

Accruing_Frequency = ''M''   /* Month */
Accruing_Multiplier = 1

E = SET_TEXT(''ACCRUING_FREQUENCY'', Accruing_Frequency)
E = SET_NUMBER(''ACCRUING_MULTIPLIER'', Accruing_Multiplier)

/* ------------------------------------------------------------------------
   Set the Continuous Service Global Variable to hire date, unless a continuous service date was
   entered for the employee.
  ------------------------------------------------------------------------ */

IF (ACP_CONTINUOUS_SERVICE_DATE WAS DEFAULTED) THEN
    (
    E = set_date(''CONTINUOUS_SERVICE_DATE'', ACP_SERVICE_START_DATE)
    )
ELSE
  (
    E = set_date(''CONTINUOUS_SERVICE_DATE'', ACP_CONTINUOUS_SERVICE_DATE)
  )

Continuous_Service_Date = get_date(''CONTINUOUS_SERVICE_DATE'')

/* ------------------------------------------------------------------------
   Set the Calculation_Date to the Termination Date, or enrollment end date, if either is not null
-------------------------------------------------------------------------- */

IF NOT (ACP_TERMINATION_DATE WAS DEFAULTED) OR
    NOT (ACP_ENROLLMENT_END_DATE WAS DEFAULTED) THEN
(
  Early_End_Date = least(ACP_TERMINATION_DATE, ACP_ENROLLMENT_END_DATE)

  IF (Early_End_Date < Calculation_Date) THEN
  (
    Calculation_Date = Early_End_Date
  )
)


/* ------------------------------------------------------------------------
   Get the whole period prior which has Calculation Date as its end date.
   ------------------------------------------------------------------------ */

E = GET_PERIOD_DATES(ADD_DAYS(Calculation_Date, 1),
                                           Accruing_Frequency,
                                           ADD_DAYS(Calculation_Date, 1),
                                           Accruing_Multiplier)

Dummy_Period_SD  = get_date(''PERIOD_START_DATE'')

E = SET_DATE(''END_OF_TERM'', Dummy_Period_SD)

E = GET_PERIOD_DATES(ADD_DAYS(Dummy_Period_SD, -1),
                                           Accruing_Frequency,
                                           Dummy_period_SD,
                                           Accruing_Multiplier)

Calculation_Period_SD  = get_date(''PERIOD_START_DATE'')
Calculation_Period_ED = get_date(''PERIOD_END_DATE'')

/*------------------------------------------------------------------------
   Get the first period to be considered within the rolling year
---------------------------------------------------------------------------*/

First_Period_In_Year = Greatest(Add_Days(Add_Years(Calculation_Period_ED, -1), 1),
                                                        Continuous_Service_date)

E = GET_PERIOD_DATES(First_period_in_year,
                                          Accruing_Frequency,
                                          Dummy_Period_SD,
                                          Accruing_Multiplier)

First_Period_In_Year_SD  = get_date(''PERIOD_START_DATE'')
First_Period_In_Year_ED = get_date(''PERIOD_END_DATE'')

IF First_Period_In_year_SD < First_Period_In_Year THEN
(
  E = GET_PERIOD_DATES(ADD_DAYS(First_period_in_year_ED, 1),
                                            Accruing_Frequency,
                                            Dummy_Period_SD,
                                            Accruing_Multiplier)

  First_Period_In_Year_SD  = get_date(''PERIOD_START_DATE'')
  First_Period_In_Year_ED = get_date(''PERIOD_END_DATE'')
)

E = set_date(''BEGINNING_OF_TERM'', First_Period_In_Year_SD)

First_Eligible_To_Accrue_Date  = Continuous_Service_Date

/*------------------------------------------------------------------------
   Determine the date on which accrued PTO may first be registered, i.e the date on which the
   Ineligibility Period expires
   ------------------------------------------------------------------------ */

Accrual_Ineligibility_Expired_Date = First_Eligible_To_Accrue_Date

IF ACP_INELIGIBILITY_PERIOD_LENGTH > 0 THEN
   (
   IF ACP_INELIGIBILITY_PERIOD_TYPE = ''BM'' THEN
      (
      Accrual_Ineligibility_Expired_Date = add_months(Continuous_Service_Date,
                                                                                        ACP_INELIGIBILITY_PERIOD_LENGTH*2)
      )
   ELSE IF ACP_INELIGIBILITY_PERIOD_TYPE = ''F'' THEN
      (
      Accrual_Ineligibility_Expired_Date = add_days(Continuous_Service_Date,
                                                                                   ACP_INELIGIBILITY_PERIOD_LENGTH*14)
      )
   ELSE IF ACP_INELIGIBILITY_PERIOD_TYPE = ''CM'' THEN
      (
      Accrual_Ineligibility_Expired_Date = add_months(Continuous_Service_Date,
                                                                                        ACP_INELIGIBILITY_PERIOD_LENGTH)
      )
   ELSE IF ACP_INELIGIBILITY_PERIOD_TYPE = ''LM'' THEN
      (
      Accrual_Ineligibility_Expired_Date = add_days(Continuous_Service_Date,
                                                                                    ACP_INELIGIBILITY_PERIOD_LENGTH*28)
      )
   ELSE IF ACP_INELIGIBILITY_PERIOD_TYPE = ''Q'' THEN
      (
      Accrual_Ineligibility_Expired_Date = add_months(Continuous_Service_Date,
                                                                                        ACP_INELIGIBILITY_PERIOD_LENGTH*3)
      )
   ELSE IF ACP_INELIGIBILITY_PERIOD_TYPE = ''SM'' THEN
      (
      Accrual_Ineligibility_Expired_Date = add_months(Continuous_Service_Date,
                                                                                        ACP_INELIGIBILITY_PERIOD_LENGTH/2)
      )
   ELSE IF ACP_INELIGIBILITY_PERIOD_TYPE = ''SY'' THEN
      (
      Accrual_Ineligibility_Expired_Date = add_months(Continuous_Service_Date,
                                                                                        ACP_INELIGIBILITY_PERIOD_LENGTH*6)
      )
   ELSE IF ACP_INELIGIBILITY_PERIOD_TYPE = ''W'' THEN
      (
      Accrual_Ineligibility_Expired_Date = add_days(Continuous_Service_Date,
                                                                                   ACP_INELIGIBILITY_PERIOD_LENGTH*7)
      )
   ELSE IF ACP_INELIGIBILITY_PERIOD_TYPE = ''Y'' THEN
      (
      Accrual_Ineligibility_Expired_Date = add_months(Continuous_Service_Date,
                                                                                        ACP_INELIGIBILITY_PERIOD_LENGTH*12)
      )

   IF Accrual_Ineligibility_Expired_Date > First_Eligible_To_Accrue_Date
   AND Calculation_Date < Accrual_Ineligibility_Expired_Date THEN
      (
      First_Eligible_To_Accrue_Date = Accrual_Ineligibility_Expired_Date
      )
   )

/* ------------------------------------------------------------------------
   Get the first full period following the First_Eligible_To_Accrue_Date
   (if it falls on the beginning of the period then use that period)
------------------------------------------------------------------------- */

IF First_Eligible_To_Accrue_Date > First_Period_In_Year_SD THEN
(
  E = GET_PERIOD_DATES(First_Eligible_To_Accrue_Date,
                                             Accruing_Frequency,
                                             Dummy_Period_SD,
                                             Accruing_Multiplier)

  First_Eligible_To_Accrue_Period_SD  = get_date(''PERIOD_START_DATE'')
  First_Eligible_To_Accrue_Period_ED  = get_date(''PERIOD_END_DATE'')

  IF First_Eligible_To_Accrue_Date <> First_Eligible_To_Accrue_Period_SD THEN
  (
    E = GET_PERIOD_DATES(ADD_DAYS(First_Eligible_To_Accrue_Period_ED, 1),
                                              Accruing_Frequency,
                                              Dummy_Period_SD,
                                              Accruing_Multiplier)

    First_Eligible_To_Accrue_Period_SD  = get_date(''PERIOD_START_DATE'')
    First_Eligible_To_Accrue_Period_ED = get_date(''PERIOD_END_DATE'')
  )

  IF (First_Eligible_To_Accrue_Period_SD > Calculation_Period_ED) THEN
     (
       Total_Accrued_PTO = 0
       E = PUT_MESSAGE(''HR_52793_PTO_FML_ASG_INELIG'')
    )
)
ELSE
(
  First_Eligible_To_Accrue_Period_SD  = First_Period_In_Year_SD
  First_Eligible_To_Accrue_Period_ED  = First_Period_In_Year_ED
)

/* ------------------------------------------------------------------------
   Determine the date on which PTO actually starts accruing based on Hire Date,
   Continuous Service Date and plan Enrollment Start Date. Remember, we have already determined
   whether to user hire date or CSD earlier in the formula.
   If this date is after the 1st period and the fisrt eligible date then establish the first full period
   after this date (if the Actual Start Date falls on the beginning of a period then use this period)
 ------------------------------------------------------------------------ */

IF Continuous_Service_date = ACP_CONTINUOUS_SERVICE_DATE THEN
(
  Actual_Accrual_Start_Date = Continuous_service_Date
)
ELSE
(
  Actual_Accrual_Start_Date = greatest(Continuous_Service_Date,
                                       ACP_ENROLLMENT_START_DATE,
                                       First_Period_In_Year_SD)
)

/* -------------------------------------------------------------------------
       Determine the actual start of the accrual calculation
-------------------------------------------------------------------------*/
IF (Actual_Accrual_Start_Date > First_Eligible_To_Accrue_Period_SD AND
      Actual_Accrual_Start_Date > First_Period_In_Year_SD) THEN
    (
     E = GET_PERIOD_DATES(Actual_Accrual_Start_Date,
                                                Accruing_Frequency,
                                                Dummy_Period_SD,
                                                Accruing_Multiplier)

     Accrual_Start_Period_SD = get_date(''PERIOD_START_DATE'')
     Accrual_Start_Period_ED = get_date(''PERIOD_END_DATE'')

     IF Accrual_start_period_SD <> Actual_Accrual_Start_Date THEN
     (
       E = GET_PERIOD_DATES(Add_Days(Accrual_Start_Period_ED, 1),
                                                  Accruing_Frequency,
                                                  Dummy_Period_SD,
                                                  Accruing_Multiplier)

       Accrual_Start_Period_SD = get_date(''PERIOD_START_DATE'')
       Accrual_Start_Period_ED = get_date(''PERIOD_END_DATE'')
     )

/* -----------------------------------------------------------------
        If the Actual Accrual Period is after the Calculation Period then end the processing.
----------------------------------------------------------------- */
        IF (Accrual_Start_Period_SD > Calculation_Period_ED) THEN
            (
            Total_Accrued_PTO = 0
            E = PUT_MESSAGE(''HR_52797_PTO_FML_ACT_ACCRUAL'')
            )
     )
ELSE IF (First_Eligible_To_Accrue_Period_SD > First_Period_In_Year_SD) THEN
     (
          Accrual_Start_Period_SD = First_Eligible_To_Accrue_Period_SD
          Accrual_Start_Period_ED = First_Eligible_To_Accrue_Period_ED
     )
ELSE
    (
          Accrual_Start_Period_SD = First_Period_In_Year_SD
          Accrual_Start_Period_ED = First_Period_In_Year_ED
    )

 /* -------------------------------------------------------------------
       Now set up the information that will be used in when looping through the periods
--------------------------------------------------------------------- */
E = set_number(''TOTAL_ACCRUED_PTO'',0)

IF Calculation_Date >= Accrual_Start_Period_ED THEN
(
E = set_date(''PERIOD_SD'',Accrual_Start_Period_SD)
E = set_date(''PERIOD_ED'',Accrual_Start_Period_ED)
E = set_date(''LAST_PERIOD_SD'',Calculation_Period_SD)
E = set_date(''LAST_PERIOD_ED'',Calculation_Period_ED)

E = LOOP_CONTROL(''PTO_ROLLING_PERIOD_ACCRUAL'')

)

Total_Accrued_PTO = get_number(''TOTAL_ACCRUED_PTO'')

IF Accrual_Start_Period_SD <= Calculation_Period_SD THEN
(
  Accrual_end_date = Calculation_Period_ED
)

Effective_Start_Date = Actual_Accrual_Start_Date
Effective_End_Date = Calculation_Date

IF Effective_Start_Date >= Effective_End_Date THEN
(
  Effective_Start_Date = least(Effective_End_Date, Actual_Accrual_Start_Date)
)

RETURN Total_Accrued_PTO, Effective_start_date, Effective_end_date, Accrual_end_date
';
    --
    select formula_type_id
    into   l_ftype_id
    from   ff_formula_types
    where  formula_type_name = 'Accrual';
    --
    INSERT INTO ff_formulas_f
     (formula_id,
      effective_start_date,
      effective_end_date,
      business_group_id,
      legislation_code,
      formula_type_id,
      formula_name,
      description,
      formula_text,
      sticky_flag)
   VALUES
     (ff_formulas_s.nextval,
      to_date('01/01/0001','DD/MM/YYYY'),
      to_date('31/12/4712','DD/MM/YYYY'),
      NULL,
      NULL,
      l_ftype_id,
      'PTO_ROLLING_ACCRUAL',
      'Seeded top level rolling formula for PTO accruals',
      l_text,
      NULL);
    --
    hr_utility.set_location ('hrstrdbi.insert_formula', 123);
    --
l_text := '
/* ------------------------------------------------------------------------
    NAME : PTO_SIMPLE_CARRYOVER
    This formula is the seeded carryover folmula for our simple multiplier accrual plan
   ---------------------------------------------------------------------*/

DEFAULT FOR ACP_CONTINUOUS_SERVICE_DATE IS ''4712/12/31 00:00:00'' (date)
DEFAULT FOR ACP_SERVICE_START_DATE IS ''4712/12/31 00:00:00'' (date)

INPUTS ARE
Calculation_Date (date),
Accrual_term (text)

Effective_Date = to_date(''3105'' + to_char(Calculation_date, ''YYYY''), ''DDMMYYYY'')

IF (Accrual_Term = ''CURRENT'') AND (Effective_Date < Calculation_Date) THEN
(
  Effective_date = ADD_YEARS(Effective_Date, 1)
)
ELSE IF (Accrual_term = ''PREVIOUS'') AND (Effective_Date >= Calculation_Date) THEN
(
  Effective_date = ADD_YEARS(Effective_Date, -1)
)

Expiry_Date = add_years(effective_date, 1)

Max_carryover = 5
Process = ''YES''

RETURN Max_Carryover, Effective_date, Expiry_Date, Process

';
    --
    select formula_type_id
    into   l_ftype_id
    from   ff_formula_types
    where  formula_type_name = 'Accrual Carryover';
    --
    INSERT INTO ff_formulas_f
     (formula_id,
      effective_start_date,
      effective_end_date,
      business_group_id,
      legislation_code,
      formula_type_id,
      formula_name,
      description,
      formula_text,
      sticky_flag)
   VALUES
     (ff_formulas_s.nextval,
      to_date('01/01/0001','DD/MM/YYYY'),
      to_date('31/12/4712','DD/MM/YYYY'),
      NULL,
      NULL,
      l_ftype_id,
      'PTO_SIMPLE_CARRYOVER',
      'Seeded simple carryover formula for PTO accruals',
      l_text,
      NULL);
    --
    hr_utility.set_location ('hrstrdbi.insert_formula', 124);
    --
l_text := '
/* ------------------------------------------------------------------------
    NAME : PTO_SIMPLE_MULTIPLIER_PERIOD_ACCRUAL
    This formula calculates the amount of PTO accrued for a particular period
   ---------------------------------------------------------------------*/

/*------------------------------------------------------------------------
    Get the global variable to be used in this formula
 ------------------------------------------------------------------------*/

Continuous_Service_Date = get_date(''CONTINUOUS_SERVICE_DATE'')
Total_Accrued_PTO = get_number(''TOTAL_ACCRUED_PTO'')
Period_SD = get_date(''PERIOD_SD'')
Period_ED = get_date(''PERIOD_ED'')
Last_Period_SD = get_date(''LAST_PERIOD_SD'')
Last_Period_ED = get_date(''LAST_PERIOD_ED'')

Accrual_Rate = get_number(''ACCRUAL_RATE'')
Accruing_Frequency = get_text(''ACCRUING_FREQUENCY'')
Accruing_Multiplier = get_number(''ACCRUING_MULTIPLIER'')
Beginning_of_Calculation_Year = get_date(''BEGINNING_OF_CALCULATION_YEAR'')

Ceiling = get_number(''CEILING'')

/* ----------------------------------------------------------------------
    Calculate the Amount Accrued this Period
   ---------------------------------------------------------------------*/

Period_Accrued_PTO = Accrual_Rate

/* ----------------------------------------------------------------------
    Calculate any absence or bought/sold time etc. to be accounted for in this period.
   ---------------------------------------------------------------------*/

Absence = GET_ABSENCE(Period_ED, Beginning_of_Calculation_Year)
CarryOver = GET_CARRY_OVER(Period_ED, Beginning_of_Calculation_Year)
Other = GET_OTHER_NET_CONTRIBUTION(Period_ED, Beginning_of_Calculation_Year)

Period_Others = CarryOver + Other - Absence

/* ----------------------------------------------------------------------
    Now establish whether the Accrual this period has gone over the ceiling if one exists
   ----------------------------------------------------------------------*/

IF (Ceiling > 0) THEN
    (
     IF (Total_Accrued_PTO + Period_Accrued_PTO + Period_Others > Ceiling) THEN
         (
          Amount_Over_Ceiling = Total_Accrued_PTO + Period_Accrued_PTO + Period_Others - Ceiling
          IF (Amount_Over_Ceiling > Period_Accrued_PTO) THEN
               (
               Period_Accrued_PTO = 0
               )
          ELSE
              (
               Period_Accrued_PTO = Period_Accrued_PTO - Amount_Over_Ceiling
              )
          )
     )

/*---------------------------------------------------------------------
    Set the Running Total
  ---------------------------------------------------------------------*/

E = set_number(''TOTAL_ACCRUED_PTO'',Total_Accrued_PTO + Period_Accrued_PTO)


/* ----------------------------------------------------------------------
    Establish whether the current period is the last one, if so end the processing, otherwise get the
    next period
------------------------------------------------------------------------*/

IF Period_SD = Last_Period_SD THEN
    (
    Continue_Processing_Flag = ''N''
    )
ELSE
   (
    E = GET_PERIOD_DATES(ADD_DAYS(Period_ED,1),
                                               Accruing_Frequency,
                                               Beginning_of_Calculation_Year,
                                               Accruing_Multiplier)

    E = set_date(''PERIOD_SD'', get_date(''PERIOD_START_DATE''))
    E = set_date(''PERIOD_ED'', get_date(''PERIOD_END_DATE''))

   Continue_Processing_Flag = ''Y''
   )

Return Continue_Processing_Flag
';
    --
    select formula_type_id
    into   l_ftype_id
    from   ff_formula_types
    where  formula_type_name = 'Accrual Subformula';
    --
    INSERT INTO ff_formulas_f
     (formula_id,
      effective_start_date,
      effective_end_date,
      business_group_id,
      legislation_code,
      formula_type_id,
      formula_name,
      description,
      formula_text,
      sticky_flag)
   VALUES
     (ff_formulas_s.nextval,
      to_date('01/01/0001','DD/MM/YYYY'),
      to_date('31/12/4712','DD/MM/YYYY'),
      NULL,
      NULL,
      l_ftype_id,
      'PTO_SIMPLE_PERIOD_ACCRUAL',
      'Seeded simple looping formula for PTO accruals',
      l_text,
      NULL);
    --
    hr_utility.set_location ('hrstrdbi.insert_formula', 125);
    --
l_text := '
/* ------------------------------------------------------------------------
    NAME : PTO_SIMPLE_MULTIPLIER
    This formula calculates the start and end dates for out simple multiplier.
   ---------------------------------------------------------------------*/

DEFAULT FOR ACP_INELIGIBILITY_PERIOD_TYPE IS ''CM''
DEFAULT FOR ACP_INELIGIBILITY_PERIOD_LENGTH IS 0
DEFAULT FOR ACP_CONTINUOUS_SERVICE_DATE IS ''4712/12/31 00:00:00'' (date)
DEFAULT FOR ACP_ENROLLMENT_END_DATE IS ''4712/12/31 00:00:00'' (date)
DEFAULT FOR ACP_TERMINATION_DATE IS ''4712/12/31 00:00:00'' (date)
DEFAULT FOR ACP_ENROLLMENT_START_DATE IS ''4712/12/31 00:00:00'' (date)
DEFAULT FOR ACP_SERVICE_START_DATE IS ''4712/12/31 00:00:00'' (date)

INPUTS ARE
Calculation_Date (date)

E = SET_NUMBER(''CEILING'', 20)
E = SET_NUMBER(''ACCRUAL_RATE'', 2)

Accruing_Frequency = ''M''   /* Month */
Accruing_Multiplier = 1

E = SET_TEXT(''ACCRUING_FREQUENCY'', Accruing_Frequency)
E = SET_NUMBER(''ACCRUING_MULTIPLIER'', Accruing_Multiplier)

Beginning_Of_Calculation_Year = to_date(''0106''||to_char(Calculation_Date,''YYYY''),''DDMMYYYY'')

IF Beginning_Of_Calculation_Year > Calculation_Date THEN
(
  Beginning_of_Calculation_Year = ADD_MONTHS(Beginning_Of_Calculation_Year, -12)
)

E = SET_DATE(''BEGINNING_OF_CALCULATION_YEAR'', Beginning_Of_Calculation_Year)

E = GET_PERIOD_DATES(Beginning_of_Calculation_Year,
                                          Accruing_Frequency,
                                          Beginning_Of_Calculation_Year,
                                          Accruing_Multiplier)

First_Period_SD = get_date(''PERIOD_START_DATE'')
First_Period_ED = get_date(''PERIOD_END_DATE'')

/* ------------------------------------------------------------------------
   Set the Calculation_Date to the Termination Date if not null
-------------------------------------------------------------------------- */

IF NOT (ACP_TERMINATION_DATE WAS DEFAULTED) OR
    NOT (ACP_ENROLLMENT_END_DATE WAS DEFAULTED) THEN
(
  Early_End_Date = least(ACP_TERMINATION_DATE, ACP_ENROLLMENT_END_DATE)

  IF (Early_End_Date < First_Period_ED) THEN
  (
    Total_Accrued_PTO = 0
    E = PUT_MESSAGE(''HR_52794_PTO_FML_ASG_TER'')
   )

  IF (Early_End_Date < Calculation_Date) THEN
  (
    Calculation_Date = Early_End_Date
  )
)

/* ------------------------------------------------------------------------
   Get the last whole period prior to the Calculation Date and ensure that it is within the
   Year (if the Calculation Date is the End of a Period then use that period)
   ------------------------------------------------------------------------ */

E = GET_PERIOD_DATES(Calculation_Date,
                                          Accruing_Frequency,
                                          Beginning_of_Calculation_Year,
                                          Accruing_Multiplier)

Calculation_Period_SD  = get_date(''PERIOD_START_DATE'')
Calculation_Period_ED = get_date(''PERIOD_END_DATE'')

IF (Calculation_Date <> Calculation_Period_ED) THEN
    (
     E = GET_PERIOD_DATES(ADD_DAYS(Calculation_Period_SD,-1),
                                                Accruing_Frequency,
                                                Beginning_of_Calculation_Year,
                                                Accruing_Multiplier)

    Calculation_Period_SD  = get_date(''PERIOD_START_DATE'')
    Calculation_Period_ED = get_date(''PERIOD_END_DATE'')
   )

If (Calculation_Period_ED < First_Period_ED) THEN
   (
    Total_Accrued_PTO = 0
    E = PUT_MESSAGE(''HR_52795_PTO_FML_CALC_DATE'')
    )

/* ------------------------------------------------------------------------
   Set the Continuous Service Global Variable, whilst also
   ensuring that the continuous service date is before the Calculation Period
  ------------------------------------------------------------------------ */

IF (ACP_CONTINUOUS_SERVICE_DATE WAS DEFAULTED) THEN
    (
    E = set_date(''CONTINUOUS_SERVICE_DATE'', ACP_SERVICE_START_DATE)
    )
ELSE IF(ACP_CONTINUOUS_SERVICE_DATE > Calculation_Period_SD) THEN
   (
    Total_Accrued_PTO = 0
    E = PUT_MESSAGE(''HR_52796_PTO_FML_CSD'')
    E = set_date(''CONTINUOUS_SERVICE_DATE'', ACP_CONTINUOUS_SERVICE_DATE)
   )
ELSE
  (
    E = set_date(''CONTINUOUS_SERVICE_DATE'', ACP_CONTINUOUS_SERVICE_DATE)
  )

Continuous_Service_Date = get_date(''CONTINUOUS_SERVICE_DATE'')

First_Eligible_To_Accrue_Date  = Continuous_Service_Date

/*------------------------------------------------------------------------
   Determine the date on which accrued PTo may first be registered, i.e the date on which the
   Ineligibility Period expires
   ------------------------------------------------------------------------ */

Accrual_Ineligibility_Expired_Date = First_Eligible_To_Accrue_Date

IF (ACP_INELIGIBILITY_PERIOD_LENGTH > 0) THEN
   (
   IF ACP_INELIGIBILITY_PERIOD_TYPE = ''BM'' THEN
      (
      Accrual_Ineligibility_Expired_Date = add_months(Continuous_Service_Date,
                                                                                        ACP_INELIGIBILITY_PERIOD_LENGTH*2)
      )
   ELSE IF ACP_INELIGIBILITY_PERIOD_TYPE = ''F'' THEN
      (
      Accrual_Ineligibility_Expired_Date = add_days(Continuous_Service_Date,
                                                                                   ACP_INELIGIBILITY_PERIOD_LENGTH*14)
      )
   ELSE IF ACP_INELIGIBILITY_PERIOD_TYPE = ''CM'' THEN
      (
      Accrual_Ineligibility_Expired_Date = add_months(Continuous_Service_Date,
                                                                                        ACP_INELIGIBILITY_PERIOD_LENGTH)
      )
   ELSE IF ACP_INELIGIBILITY_PERIOD_TYPE = ''LM'' THEN
      (
      Accrual_Ineligibility_Expired_Date = add_days(Continuous_Service_Date,
                                                                                    ACP_INELIGIBILITY_PERIOD_LENGTH*28)
      )
   ELSE IF ACP_INELIGIBILITY_PERIOD_TYPE = ''Q'' THEN
      (
      Accrual_Ineligibility_Expired_Date = add_months(Continuous_Service_Date,
                                                                                        ACP_INELIGIBILITY_PERIOD_LENGTH*3)
      )
   ELSE IF ACP_INELIGIBILITY_PERIOD_TYPE = ''SM'' THEN
      (
      Accrual_Ineligibility_Expired_Date = add_months(Continuous_Service_Date,
                                                                                        ACP_INELIGIBILITY_PERIOD_LENGTH/2)
      )
   ELSE IF ACP_INELIGIBILITY_PERIOD_TYPE = ''SY'' THEN
      (
      Accrual_Ineligibility_Expired_Date = add_months(Continuous_Service_Date,
                                                                                        ACP_INELIGIBILITY_PERIOD_LENGTH*6)
      )
   ELSE IF ACP_INELIGIBILITY_PERIOD_TYPE = ''W'' THEN
      (
      Accrual_Ineligibility_Expired_Date = add_days(Continuous_Service_Date,
                                                                                   ACP_INELIGIBILITY_PERIOD_LENGTH*7)
      )
   ELSE IF ACP_INELIGIBILITY_PERIOD_TYPE = ''Y'' THEN
      (
      Accrual_Ineligibility_Expired_Date = add_months(Continuous_Service_Date,
                                                                                        ACP_INELIGIBILITY_PERIOD_LENGTH*12)
      )

   IF Accrual_Ineligibility_Expired_Date > First_Eligible_To_Accrue_Date
   AND Calculation_Date < Accrual_Ineligibility_Expired_Date THEN
      (
      First_Eligible_To_Accrue_Date = Accrual_Ineligibility_Expired_Date
      )
   )

/* ------------------------------------------------------------------------
   Get the first full period following the First_Eligible_To_Accrue_Date
   (if it falls on the beginning of the period then use that period)
------------------------------------------------------------------------- */

IF First_Eligible_To_Accrue_Date > Beginning_Of_Calculation_Year THEN
(
  E = GET_PERIOD_DATES(First_Eligible_To_Accrue_Date,
                                             Accruing_Frequency,
                                             Beginning_Of_Calculation_Year,
                                             Accruing_Multiplier)

  First_Eligible_To_Accrue_Period_SD  = get_date(''PERIOD_START_DATE'')
  First_Eligible_To_Accrue_Period_ED  = get_date(''PERIOD_END_DATE'')

  IF First_Eligible_To_Accrue_Date <> First_Eligible_To_Accrue_Period_SD THEN
      (
       E = GET_PERIOD_DATES(add_days(First_Eligible_To_Accrue_Period_ED,1),
                                                  Accruing_Frequency,
                                                  Beginning_Of_Calculation_Year,
                                                  Accruing_Multiplier)

       First_Eligible_To_Accrue_Period_SD  = get_date(''PERIOD_START_DATE'')
       First_Eligible_To_Accrue_Period_ED  = get_date(''PERIOD_END_DATE'')
       )

  IF (First_Eligible_To_Accrue_Period_SD > Calculation_Period_ED) THEN
     (
       Total_Accrued_PTO = 0
       E = PUT_MESSAGE(''HR_52793_PTO_FML_ASG_INELIG'')
    )
)
ELSE
(
  First_Eligible_To_Accrue_Period_SD  = First_Period_SD
  First_Eligible_To_Accrue_Period_ED  = First_Period_ED
)
/* ------------------------------------------------------------------------
   Determine the date on which PTO actually starts accruing based on Hire Date,
   Continuous Service Date and plan Enrollment Start Date. Remember, we have already determined
   whether to user hire date or CSD earlier in the formula.
   If this date is after the 1st period and the fisrt eligible date then establish the first full period
   after this date (if the Actual Start Date falls on the beginning of a period then use this period)
 ------------------------------------------------------------------------ */

IF Continuous_Service_date = ACP_CONTINUOUS_SERVICE_DATE THEN
(
  Actual_Accrual_Start_Date = Continuous_service_Date
)
ELSE
(
  Actual_Accrual_Start_Date = greatest(Continuous_Service_Date,
                                       ACP_ENROLLMENT_START_DATE,
                                       First_Period_SD)
)

/* -------------------------------------------------------------------------
       Determine the actual start of the accrual calculation
-------------------------------------------------------------------------*/
IF (Actual_Accrual_Start_Date > First_Period_SD AND
     Actual_Accrual_Start_Date > First_Eligible_To_Accrue_Period_SD) THEN
    (
     E = GET_PERIOD_DATES(Actual_Accrual_Start_Date,
                                                Accruing_Frequency,
                                                Beginning_Of_Calculation_Year,
                                                Accruing_Multiplier)

     Accrual_Start_Period_SD = get_date(''PERIOD_START_DATE'')
     Accrual_Start_Period_ED = get_date(''PERIOD_END_DATE'')

     IF Actual_Accrual_Start_Date > Accrual_Start_Period_SD THEN
         (
          E = GET_PERIOD_DATES(add_days(Accrual_Start_Period_ED,1),
                                                     Accruing_Frequency,
                                                     Beginning_of_Calculation_Year,
                                                     Accruing_Multiplier)

          Accrual_Start_Period_SD = get_date(''PERIOD_START_DATE'')
          Accrual_Start_Period_ED = get_date(''PERIOD_END_DATE'')
         )

/* -----------------------------------------------------------------
        If the Actual Acrual Period is after the Calculation Period then end the processing.
----------------------------------------------------------------- */
        IF (Accrual_Start_Period_SD > Calculation_Period_ED) THEN
            (
            Total_Accrued_PTO = 0
            E = PUT_MESSAGE(''HR_52797_PTO_FML_ACT_ACCRUAL'')
            )
     )

ELSE IF (First_Eligible_To_Accrue_Period_SD > First_Period_SD) THEN
     (
          Accrual_Start_Period_SD = First_Eligible_To_Accrue_Period_SD
          Accrual_Start_Period_ED = First_Eligible_To_Accrue_Period_ED
     )
ELSE
     (
          Accrual_Start_Period_SD = First_Period_SD
          Accrual_Start_Period_ED = First_Period_ED
    )

 /* -------------------------------------------------------------------
       Now set up the information that will be used in when looping through the periods
--------------------------------------------------------------------- */
IF Calculation_Period_ED >= Accrual_Start_Period_ED THEN
(
E = set_date(''PERIOD_SD'',Accrual_Start_Period_SD)
E = set_date(''PERIOD_ED'',Accrual_Start_Period_ED)
E = set_date(''LAST_PERIOD_SD'',Calculation_Period_SD)
E = set_date(''LAST_PERIOD_ED'',Calculation_Period_ED)
E = set_number(''TOTAL_ACCRUED_PTO'',0)

E = LOOP_CONTROL(''PTO_SIMPLE_PERIOD_ACCRUAL'')

Total_Accrued_PTO = get_number(''TOTAL_ACCRUED_PTO'')
)

IF Accrual_Start_Period_SD <= Calculation_Period_SD THEN
(
  Accrual_end_date = Calculation_Period_ED
)

Effective_Start_Date = Accrual_Start_Period_SD
Effective_End_Date = Calculation_Date

IF Effective_Start_Date >= Effective_End_Date THEN
(
  Effective_Start_Date = Effective_End_Date
)

RETURN Total_Accrued_PTO, Effective_start_date, Effective_end_date, Accrual_end_date
';
    --
    select formula_type_id
    into   l_ftype_id
    from   ff_formula_types
    where  formula_type_name = 'Accrual';
    --
    INSERT INTO ff_formulas_f
     (formula_id,
      effective_start_date,
      effective_end_date,
      business_group_id,
      legislation_code,
      formula_type_id,
      formula_name,
      description,
      formula_text,
      sticky_flag)
   VALUES
     (ff_formulas_s.nextval,
      to_date('01/01/0001','DD/MM/YYYY'),
      to_date('31/12/4712','DD/MM/YYYY'),
      NULL,
      NULL,
      l_ftype_id,
      'PTO_SIMPLE_MULTIPLIER',
      'Seeded simple top level formula for PTO accruals',
      l_text,
      NULL);
    --
--
    hr_utility.set_location ('hrstrdbi.insert_formula', 126);
--
l_text := '
/* ------------------------------------------------------------------------
    NAME : PTO_INELIGIBILITY_CALCULATION
   ---------------------------------------------------------------------*/

DEFAULT FOR ACP_START IS ''HD''
DEFAULT FOR ACP_INELIGIBILITY_PERIOD_TYPE IS ''CM''
DEFAULT FOR ACP_INELIGIBILITY_PERIOD_LENGTH IS 0
DEFAULT FOR ACP_CONTINUOUS_SERVICE_DATE IS ''4712/12/31 00:00:00'' (date)
DEFAULT FOR ACP_ENROLLMENT_END_DATE IS ''4712/12/31 00:00:00'' (date)
DEFAULT FOR ACP_TERMINATION_DATE IS ''4712/12/31 00:00:00'' (date)
DEFAULT FOR ACP_ENROLLMENT_START_DATE IS ''4712/12/31 00:00:00'' (date)
DEFAULT FOR ACP_SERVICE_START_DATE IS ''4712/12/31 00:00:00'' (date)

INPUTS ARE
Calculation_Date (date)

/* ------------------------------------------------------------------------
   Set the Calculation_Date to the Termination Date / Enrollment end date if not defaulted
------------------------------------------------------------------------ */

IF NOT (ACP_TERMINATION_DATE WAS DEFAULTED) OR
    NOT (ACP_ENROLLMENT_END_DATE WAS DEFAULTED) THEN
(
  Early_End_Date = least(ACP_TERMINATION_DATE, ACP_ENROLLMENT_END_DATE)


  IF (Early_End_Date < Calculation_Date) THEN
  (
    Calculation_Date = Early_End_Date
  )
)

/* ------------------------------------------------------------------------
   Set the Continuous Service Global Variable, whilst also
   ensuring that the continuous service date is before the Calculation Period
  ------------------------------------------------------------------------ */

IF (ACP_CONTINUOUS_SERVICE_DATE WAS DEFAULTED) THEN
    (
    Continuous_Service_Date = ACP_SERVICE_START_DATE
    )
ELSE
  (
    Continuous_Service_Date = ACP_CONTINUOUS_SERVICE_DATE
  )

IF (ACP_START = ''BOY'') THEN
    (
     First_Eligible_To_Accrue_Date =
         to_date(''01/01/''||to_char(add_days(add_months(Continuous_Service_Date, 12), -1), ''YYYY''),
                       ''DD/MM/YYYY'')
     )
ELSE IF (ACP_START = ''PLUS_SIX_MONTHS'') THEN
    (
     First_Eligible_To_Accrue_Date = add_months(Continuous_Service_Date,6)
     )
ELSE IF (ACP_START = ''HD'') THEN
    (
     First_Eligible_To_Accrue_Date  = Continuous_Service_Date
     )

/*------------------------------------------------------------------------
   Determine the date on which accrued PTo may first be registered, i.e the date on which the
   Ineligibility Period expires
   ------------------------------------------------------------------------ */

Accrual_Ineligibility_Expired_Date = First_Eligible_To_Accrue_Date

IF (ACP_INELIGIBILITY_PERIOD_LENGTH > 0) THEN
   (
   IF ACP_INELIGIBILITY_PERIOD_TYPE = ''BM'' THEN
      (
      Accrual_Ineligibility_Expired_Date = add_months(Continuous_Service_Date,
                                                     ACP_INELIGIBILITY_PERIOD_LENGTH*2)
      )
   ELSE IF ACP_INELIGIBILITY_PERIOD_TYPE = ''F'' THEN
      (
      Accrual_Ineligibility_Expired_Date = add_days(Continuous_Service_Date,
                                                   ACP_INELIGIBILITY_PERIOD_LENGTH*14)
      )
   ELSE IF ACP_INELIGIBILITY_PERIOD_TYPE = ''CM'' THEN
      (
      Accrual_Ineligibility_Expired_Date = add_months(Continuous_Service_Date,
                                                     ACP_INELIGIBILITY_PERIOD_LENGTH)
      )
   ELSE IF ACP_INELIGIBILITY_PERIOD_TYPE = ''LM'' THEN
      (
      Accrual_Ineligibility_Expired_Date = add_days(Continuous_Service_Date,
                                                   ACP_INELIGIBILITY_PERIOD_LENGTH*28)
      )
   ELSE IF ACP_INELIGIBILITY_PERIOD_TYPE = ''Q'' THEN
      (
      Accrual_Ineligibility_Expired_Date = add_months(Continuous_Service_Date,
                                                     ACP_INELIGIBILITY_PERIOD_LENGTH*3)
      )
   ELSE IF ACP_INELIGIBILITY_PERIOD_TYPE = ''SM'' THEN
      (
      Accrual_Ineligibility_Expired_Date = add_months(Continuous_Service_Date,
                                                     ACP_INELIGIBILITY_PERIOD_LENGTH/2)
      )
   ELSE IF ACP_INELIGIBILITY_PERIOD_TYPE = ''SY'' THEN
      (
      Accrual_Ineligibility_Expired_Date = add_months(Continuous_Service_Date,
                                                     ACP_INELIGIBILITY_PERIOD_LENGTH*6)
      )
   ELSE IF ACP_INELIGIBILITY_PERIOD_TYPE = ''W'' THEN
      (
      Accrual_Ineligibility_Expired_Date = add_days(Continuous_Service_Date,
                                                   ACP_INELIGIBILITY_PERIOD_LENGTH*7)
      )
   ELSE IF ACP_INELIGIBILITY_PERIOD_TYPE = ''Y'' THEN
      (
      Accrual_Ineligibility_Expired_Date = add_months(Continuous_Service_Date,
                                                     ACP_INELIGIBILITY_PERIOD_LENGTH*12)
      )

   )

IF Calculation_Date > greatest(Accrual_Ineligibility_Expired_Date,
			       First_Eligible_To_Accrue_Date) THEN
(
  Assignment_eligible = ''Y''
)
ELSE
(
  Assignment_eligible = ''N''
)

RETURN Assignment_eligible
';
    --
    select formula_type_id
    into   l_ftype_id
    from   ff_formula_types
    where  formula_type_name = 'Accrual Ineligibility';
    --
    INSERT INTO ff_formulas_f
     (formula_id,
      effective_start_date,
      effective_end_date,
      business_group_id,
      legislation_code,
      formula_type_id,
      formula_name,
      description,
      formula_text,
      sticky_flag)
   VALUES
     (ff_formulas_s.nextval,
      to_date('01/01/0001','DD/MM/YYYY'),
      to_date('31/12/4712','DD/MM/YYYY'),
      NULL,
      NULL,
      l_ftype_id,
      'PTO_INELIGIBILITY_CALCULATION',
      'Seeded formula allowing paymix to cope with PTO accruals upgrade',
      l_text,
      NULL);
    --
    hr_utility.set_location ('hrstrdbi.insert_formula', 127);
    --
l_text := ' /**************************************************************
FORMULA NAME: CHECK_RATE_TYPE
FORMULA TYPE:  User Table Validation
DESCRIPTION:     Check rate type exists in GL_DAILY_CONVERSION_TYPES
History
02 Feb 1999     wkerr        First Created.
***************************************************************/
INPUTS ARE entry_value (text)
rt = check_rate_type(entry_value)
IF rt = -1 THEN
(
        formula_status = ''E''
        formula_message = ''Rate type does not exist.''
)
ELSE IF rt = -2 THEN
(
        formula_status = ''E''
        formula_message = ''User Rate type is not allowed.''
)
ELSE
        formula_status = ''S''
RETURN formula_status, formula_message
 ';
    --
    select formula_type_id
    into   l_ftype_id
    from   ff_formula_types
    where  formula_type_name = 'User Table Validation';
    --
    INSERT INTO ff_formulas_f
     (formula_id,
      effective_start_date,
      effective_end_date,
      business_group_id,
      legislation_code,
      formula_type_id,
      formula_name,
      description,
      formula_text,
      sticky_flag)
   VALUES
     (ff_formulas_s.nextval,
      to_date('01/01/0001','DD/MM/YYYY'),
      to_date('31/12/4712','DD/MM/YYYY'),
      NULL,
      NULL,
      l_ftype_id,
      'CHECK_RATE_TYPE',
      'Checks that conversion type exists',
      l_text,
      NULL);
    --
    hr_utility.set_location ('hrstrdbi.insert_formula', 128);
    --
l_text := '/*******************************************************************
FORMULA NAME: TEMPLATE_BIS_TRAINING_CONVERT_DURATION
FORMULA TYPE: Quickpaint
DESCRIPTION:  Converts a duration value to from one units to another
--
INPUTS:  from_duration_units
         to_duration_units
         from_duration
         activity_version_name
         event_name
--
RETURNS: to_duration
--
DBI Required:   None
--
Change History
12 Mar 1999     Created       Barry Goodsell
********************************************************************/
/* Updatable Values Section */

/* Defaults Section */

/* Inputs Section */
INPUTS ARE from_duration_units (text)
,          from_duration (number)
,          to_duration_units (text)
,          activity_version_name (text)
,          event_name (text)

/* Main Body of Formula */
hours_per_day   = 8
hours_per_week  = hours_per_day * 5
hours_per_month = hours_per_week * 4.225
hours_per_year  = hours_per_month * 12

/* Calculate Duration in Hours */
IF (from_duration_units = ''Y'') THEN
  hours = from_duration * hours_per_year
ELSE IF (from_duration_units = ''M'') THEN
  hours = from_duration * hours_per_month
ELSE IF (from_duration_units = ''W'') THEN
  hours = from_duration * hours_per_week
ELSE IF (from_duration_units = ''D'') THEN
  hours = from_duration * hours_per_day
ELSE IF (from_duration_units = ''H'') THEN
  hours = from_duration
ELSE
  hours = 0

/* Calculate Duration in desired units */
IF (to_duration_units = ''H'') THEN
  to_duration = hours
ELSE IF (to_duration_units = ''D'') THEN
  to_duration = hours / hours_per_day
ELSE IF (to_duration_units = ''W'') THEN
  to_duration = hours / hours_per_week
ELSE IF (to_duration_units = ''M'') THEN
  to_duration = hours / hours_per_month
ELSE IF (to_duration_units = ''Y'') THEN
  to_duration = hours / hours_per_year
ELSE
  to_duration = 0

RETURN to_duration
';
    --
    select formula_type_id
    into   l_ftype_id
    from   ff_formula_types
    where  formula_type_name = 'QuickPaint';
    --
    INSERT INTO ff_formulas_f
     (formula_id,
      effective_start_date,
      effective_end_date,
      business_group_id,
      legislation_code,
      formula_type_id,
      formula_name,
      description,
      formula_text,
      sticky_flag)
   VALUES
     (ff_formulas_s.nextval,
      to_date('01/01/0001','DD/MM/YYYY'),
      to_date('31/12/4712','DD/MM/YYYY'),
      NULL,
      NULL,
      l_ftype_id,
      'TEMPLATE_BIS_TRAINING_CONVERT_DURATION',
      'Seeded formula to Calculate Training Duration',
      l_text,
      NULL);
    --
    hr_utility.set_location ('hrstrdbi.insert_formula', 128);
    --
l_text := '/*
FORMULA NAME: TEMPLATE_ABSENCE_DURATION
FORMULA TYPE: Quickpaint
DESCRIPTION:  Calculates the Employee''s Absence
              Duration in days or hours. The profile
              ''HR: Absence Duration Auto Overwrite''
              determines if an existing duration value
              can change automatically or not.
--
INPUTS:
             - days_or_hours: the units of the absence
             - date_start: the absence start date
             - date_end: the absence end date
             - time_start: the absence start time
             - time_end: the absence end time
--
DBI Required:
             - asg_start_time :  the assignment start time
             - asg_end_time: the assignment end time
             - asg_pos_start_time: the positon start time
             - asg_pos_end_time: the position end time
--
Change History
01 Sep 99       jmoyano         Created
10 Oct 01       dcasemor        end_day was being set to
                                asg_start_time. Also allowed
                                hours to be defaulted if no
                                UOM is set and hours have been
                                entered.
*/
/* Main Body of Formula */
INPUTS ARE days_or_hours(text),
           date_start (date),
           date_end (date),
           time_start (text),
           time_end (text)
/* default values */
DEFAULT FOR days_or_hours IS ''D''
DEFAULT FOR time_start IS ''09:00''
DEFAULT FOR time_end IS ''17:00''
DEFAULT FOR date_start IS ''0001/01/01 00:00:00'' (DATE)
DEFAULT FOR date_end IS ''4712/12/31 00:00:00'' (DATE)
/* database items */
DEFAULT FOR asg_start_time IS ''09:00''
DEFAULT FOR asg_end_time IS ''17:00''
DEFAULT FOR asg_pos_start_time IS ''09:00''
DEFAULT FOR asg_pos_end_time IS ''17:00''
/* local variables */
error_or_warning = '' ''
invalid_msg = '' ''
duration = ''0''
number_of_days = 0
/* Defaults Section */
/* default values for working day, these are only used if no
working conditions can be found */
begin_day = ''09:00''
end_day = ''17:00''

IF ((date_start WAS DEFAULTED) or (date_end WAS DEFAULTED)) then
  duration = ''0''
else
(
  number_of_days = days_between(date_end,date_start)
/* absence in hours */
  IF days_or_hours = ''H''
  OR (days_or_hours WAS DEFAULTED
      AND time_start WAS NOT DEFAULTED
      AND time_end WAS NOT DEFAULTED) THEN
  (
/* look for the assignment values*/
      If ((asg_start_time WAS NOT DEFAULTED) and
          (asg_end_time WAS NOT DEFAULTED)) then
      (
         begin_day = asg_start_time
         end_day = asg_end_time
      )
      else
      (
/* look for the position values */
        if ((asg_pos_start_time  WAS NOT DEFAULTED) and
            (asg_pos_end_time WAS NOT DEFAULTED)) then
        (
           begin_day = asg_pos_start_time
           end_day = asg_pos_end_time
        )
      )
/* compute hours per day */
      hours_per_day =  ((to_num(substr(end_day,1,2))*60 +
                         to_num(substr(end_day,4,2))) -
                        (to_num(substr(begin_day,1,2))*60 +
                         to_num(substr(begin_day,4,2)))) / 60
/* absence takes place during the same day */
      IF number_of_days = 0 THEN
        duration = to_char(((to_num(substr(time_end,1,2))*60 +
                             to_num(substr(time_end,4,2))) -
                            (to_num(substr(time_start,1,2))*60 +
                             to_num(substr(time_start,4,2)))) / 60)
/* more than one day */
      ELSE
        (
          duration = to_char(( (to_num(substr(time_end,1,2))*60 +
                                to_num(substr(time_end,4,2))) -
                               (to_num(substr(begin_day,1,2))*60 +
                                to_num(substr(begin_day,4,2))) +
                               (to_num(substr(end_day,1,2))*60 +
                                to_num(substr(end_day,4,2))) -
                               (to_num(substr(time_start,1,2))*60 +
                                to_num(substr(time_start,4,2))) ) / 60)
          duration = to_char(to_num(duration) +
                (DAYS_BETWEEN(date_end,date_start) - 1)* hours_per_day)
        )
  )
/* absence in days */
  ELSE
  (
    duration = to_char(DAYS_BETWEEN(date_end,date_start) + 1)
  )
/* use of error messages:
  if to_num(duration) = 0 then
  (
    duration = ''FAILED''
    invalid_msg = ''HR_ABSENCE_CANNOT_BE_ZERO''
  )
*/
)
return duration, invalid_msg';
    --
    INSERT INTO ff_formulas_f
     (formula_id,
      effective_start_date,
      effective_end_date,
      business_group_id,
      legislation_code,
      formula_type_id,
      formula_name,
      description,
      formula_text,
      sticky_flag)
   VALUES
     (ff_formulas_s.nextval,
      to_date('01/01/0001','DD/MM/YYYY'),
      to_date('31/12/4712','DD/MM/YYYY'),
      NULL,
      NULL,
      l_ftype_id,
      'TEMPLATE_ABSENCE_DURATION',
      'formula template for absence duration calculation',
      l_text,
      NULL);
    --
    hr_utility.set_location ('hrstrdbi.insert_formula', 129);
--
  l_text := '
/******************************************************************************
 *
 * Formula Name : CALC_GROSSUP_PAY_VALUE
 *
 * Description  : Simple formula to calculate the gross pay based on the
 *                net pay and additional amount.
 *
 *  Change History
 *  --------------
 *
 *  Who        Date       Description
 *  ---------- ---------- --------------------------------------------------
 *  N.Bristow  24-NOV-99  Created.
 *
 *****************************************************************************/
inputs are amount(number),
           additional_amount (number)
payment_amount = amount + additional_amount
return payment_amount';
    --
    select formula_type_id
    into   l_ftype_id
    from   ff_formula_types
    where  formula_type_name = 'Oracle Payroll';
    --
    INSERT INTO ff_formulas_f
     (formula_id,
      effective_start_date,
      effective_end_date,
      business_group_id,
      legislation_code,
      formula_type_id,
      formula_name,
      description,
      formula_text,
      sticky_flag)
   VALUES
     (ff_formulas_s.nextval,
      to_date('01/01/0001','DD/MM/YYYY'),
      to_date('31/12/4712','DD/MM/YYYY'),
      NULL,
      NULL,
      l_ftype_id,
      'CALC_GROSSUP_PAY_VALUE',
      'This formula is used in the grossup calculations',
      l_text,
      NULL);
    --
    hr_utility.set_location ('hrstrdbi.insert_formula', 130);
    --
  l_text := '
/******************************************************************************
 *
 * Formula Name : DEFAULT_GROSSUP
 *
 * Description  : This formula calculates the additional amount needed
 *                on top of a specified Net pay, that is need to reach tje
 *                the gross amount (before deductions).
 *
 *  Change History
 *  --------------
 *
 *  Who        Date       Description
 *  ---------- ---------- --------------------------------------------------
 *  N.Bristow  24-NOV-99  Created.
 *
 *****************************************************************************/
default for low_gross is -999
default for high_gross is -999
default for additional_amount is -999
default for pay_value is -999
inputs are amount(number),
           low_gross(number),
           high_gross(number),
           to_within(number),
           additional_amount(number),
           method(text),
           pay_value(number)
stopper = 1
/* Do any initialisation needed */
if (low_gross = -999  or high_gross = -999) then
 ( if (low_gross = -999) then
      low_gross = amount
   if (high_gross = -999) then
      high_gross = amount*2
   dummy = ITERATION_INITIALISE(high_gross, low_gross, amount)
   /*
     Now get the initial guess
   */
   if method = ''INTERPOLATION'' then
   (
      new_guess = ITERATION_GET_INTERPOLATION(0)
   )
   else
   (
      new_guess = ITERATION_GET_BINARY(''INCREASE'')
   )
   additional_amount = new_guess - amount

   return low_gross, high_gross, additional_amount )
/* Heres the real processing */
grossup_balance = GROSSUP_AMOUNT
if (additional_amount = grossup_balance) then
    return stopper
if (additional_amount + to_within >= grossup_balance
    and additional_amount - to_within <= grossup_balance) then
(
    remainder = additional_amount - grossup_balance
    return remainder, stopper
)
/*
if (additional_amount + to_within >= grossup_balance) then
(
    mesg = grossup_balance
    remainder = additional_amount - grossup_balance
    return remainder, stopper, grossup_balance
)
else
(
   if (additional_amount - to_within <= grossup_balance) then
   (
    mesg = 2
      remainder = additional_amount - grossup_balance
      return remainder, stopper, mesg
   )
)
*/

/* OK we have not found the correct value so we have to guess a new value */

if method = ''INTERPOLATION'' then
(
   changer = additional_amount - grossup_balance
   new_guess = ITERATION_GET_INTERPOLATION(changer)
   low_gross = ITERATION_GET_LOW()
   high_gross = ITERATION_GET_HIGH()
   additional_amount = new_guess - amount
   additional_amount = round(additional_amount,2)
   return additional_amount, low_gross, high_gross, grossup_balance, changer
)
else
(
   /* It must be binary method */
   if additional_amount < grossup_balance then
   (
       mesg = ''TO LOW Increasing''
       new_guess = ITERATION_GET_BINARY(''INCREASE'')
   )
   else
   (
       mesg = ''TO HIGH reducing''
       new_guess = ITERATION_GET_BINARY(''REDUCE'')
   )

   low_gross = ITERATION_GET_LOW()
   high_gross = ITERATION_GET_HIGH()
   additional_amount = new_guess - amount
   return additional_amount, low_gross, high_gross, mesg, grossup_balance
)
';
    --
    select formula_type_id
    into   l_ftype_id
    from   ff_formula_types
    where  formula_type_name = 'Net to Gross';
    --
    INSERT INTO ff_formulas_f
     (formula_id,
      effective_start_date,
      effective_end_date,
      business_group_id,
      legislation_code,
      formula_type_id,
      formula_name,
      description,
      formula_text,
      sticky_flag)
   VALUES
     (ff_formulas_s.nextval,
      to_date('01/01/0001','DD/MM/YYYY'),
      to_date('31/12/4712','DD/MM/YYYY'),
      NULL,
      NULL,
      l_ftype_id,
      'DEFAULT_GROSSUP',
      'This formula is used in the grossup calculations',
      l_text,
      NULL);
    --
    hr_utility.set_location ('hrstrdbi.insert_formula', 131);
    --
  l_text := '
/******************************************************************************
 *
 * Formula Name : QH_ASSIGNMENT_NAME
 *
 ******************************************************************************/
DEFAULT FOR asg_job is '' ''
DEFAULT FOR asg_org is '' ''

assignment_name=asg_job||''.''||asg_org

RETURN assignment_name';
    --
    select formula_type_id
    into   l_ftype_id
    from   ff_formula_types
    where  formula_type_name = 'QuickPaint';
    --
    INSERT INTO ff_formulas_f
     (formula_id,
      effective_start_date,
      effective_end_date,
      business_group_id,
      legislation_code,
      formula_type_id,
      formula_name,
      description,
      formula_text,
      sticky_flag)
   VALUES
     (ff_formulas_s.nextval,
      to_date('01/01/0001','DD/MM/YYYY'),
      to_date('31/12/4712','DD/MM/YYYY'),
      NULL,
      NULL,
      l_ftype_id,
      'QH_ASSIGNMENT_NAME',
      'This formula is used to get a job assignment_name',
      l_text,
      NULL);
    --
    hr_utility.set_location ('hrstrdbi.insert_formula', 132);
    --
    l_text := '
/* ------------------------------------------------------------------------
    FORMULA NAME : PTO_ORACLE_SKIP_RULE
    FORMULA_TYPE : Element Skip
    DESCRIPTION  : Skip rule to prevent PTO accrual elements from being
                   processed more than once in a payroll period. This
                   formula is system assigned to the accrual plan elements
                   when a new accrual plan is created.
   ---------------------------------------------------------------------*/

  /* Defaults Section */

  default for SKIP_FLAG IS ''N''

  /* Formula Body */

  already_processed = ENTRY_PROCESSED_IN_PERIOD()

  IF already_processed = ''Y'' THEN
     (
      SKIP_FLAG = ''Y''
      mesg = ''Element skipped. Already processed this period.''
     )
  ELSE
     (
      SKIP_FLAG = ''N''
     )

RETURN SKIP_FLAG';
    --
    select formula_type_id
    into   l_ftype_id
    from   ff_formula_types
    where  formula_type_name = 'Element Skip';
    --
     INSERT INTO ff_formulas_f
     (formula_id,
      effective_start_date,
      effective_end_date,
      business_group_id,
      legislation_code,
      formula_type_id,
      formula_name,
      description,
      formula_text,
      sticky_flag)
   VALUES
     (ff_formulas_s.nextval,
      to_date('01/01/0001','DD/MM/YYYY'),
      to_date('31/12/4712','DD/MM/YYYY'),
      NULL,
      NULL,
      l_ftype_id,
      'PTO_ORACLE_SKIP_RULE',
      'Skips PTO elements that have already been processed in the same period',
      l_text,
      NULL);
    --
    hr_utility.set_location ('hrstrdbi.insert_formula', 133);
    --
l_text := '
/* ------------------------------------------------------------------------
    NAME : PTO_PAYROLL_BALANCE_CALCULATION
    This formula calculates the dates between which an assignment is to accrue.
    It is based on PTO_PAYROLL_CALCULATION, but has been amended to allow its
    use with the payroll balance functionality.
   ---------------------------------------------------------------------*/

DEFAULT FOR ACP_START IS ''HD''
DEFAULT FOR ACP_INELIGIBILITY_PERIOD_TYPE IS ''CM''
DEFAULT FOR ACP_INELIGIBILITY_PERIOD_LENGTH IS 0
DEFAULT FOR ACP_CONTINUOUS_SERVICE_DATE IS ''4712/12/31 00:00:00'' (date)
DEFAULT FOR ACP_ENROLLMENT_END_DATE IS ''4712/12/31 00:00:00'' (date)
DEFAULT FOR ACP_TERMINATION_DATE IS ''4712/12/31 00:00:00'' (date)
DEFAULT FOR ACP_ENROLLMENT_START_DATE IS ''4712/12/31 00:00:00'' (date)
DEFAULT FOR ACP_SERVICE_START_DATE IS ''4712/12/31 00:00:00'' (date)

default for Accrual_Start_Date is ''4712/12/31 00:00:00'' (date)
default for Accrual_Latest_Balance is 0

INPUTS ARE
Calculation_Date (date),
Accrual_Start_Date (date),
Accrual_Latest_Balance

E = CALCULATE_PAYROLL_PERIODS()

/*-----------------------------------------------------------------------
   For the payroll year that spans the Calculation Date
   get the first days of the payroll year. If we have a latest balance,
   we use the Accrual Start Date.
  ----------------------------------------------------------------------- */

Payroll_Year_First_Valid_Date = GET_DATE(''PAYROLL_YEAR_FIRST_VALID_DATE'')


IF Accrual_Start_Date < Payroll_Year_First_Valid_Date THEN
(
  Accrual_Start_Date = Payroll_Year_First_Valid_Date
)


IF NOT (Accrual_Start_Date WAS DEFAULTED) THEN
(
  E = SET_DATE(''PAYROLL_YEAR_SD'', Accrual_Start_Date)
)
ELSE
(
  E = SET_DATE(''PAYROLL_YEAR_SD'', Payroll_Year_First_Valid_Date)
)


/* ------------------------------------------------------------------------
   Set the Calculation_Date to the Termination Date / Enrollment end date if not defaulted
-------------------------------------------------------------------------- */

IF NOT (ACP_TERMINATION_DATE WAS DEFAULTED) OR
    NOT (ACP_ENROLLMENT_END_DATE WAS DEFAULTED) THEN
(
  Early_End_Date = least(ACP_TERMINATION_DATE, ACP_ENROLLMENT_END_DATE)

  IF (Early_End_Date < Calculation_Date) THEN
  (
    Calculation_Date = Early_End_Date
  )
)

/* ------------------------------------------------------------------------
   Get the last whole payroll period prior to the Calculation Date and ensure that it is within the
   Payroll Year (if the Calculation Date is the End of a Period then use that period)
   ------------------------------------------------------------------------ */

E = GET_PAYROLL_PERIOD(Calculation_Date)
Calculation_Period_SD  = get_date(''PAYROLL_PERIOD_START_DATE'')
Calculation_Period_ED = get_date(''PAYROLL_PERIOD_END_DATE'')

IF (Calculation_Date <> Calculation_Period_ED) AND
   (Calculation_Period_SD > Payroll_Year_First_Valid_Date) THEN
    (
     E = GET_PAYROLL_PERIOD(ADD_DAYS(Calculation_Period_SD,-1))
    Calculation_Period_SD  = get_date(''PAYROLL_PERIOD_START_DATE'')
    Calculation_Period_ED = get_date(''PAYROLL_PERIOD_END_DATE'')
   )
ELSE IF (Calculation_Period_SD = Payroll_Year_First_Valid_Date) AND
        (Calculation_Date <> Calculation_Period_ED) THEN
  (
    Calculation_Period_ED = ADD_DAYS(Calculation_Period_SD,-1)
  )


/* ------------------------------------------------------------------------
   Set the Continuous Service Global Variable, whilst also
   ensuring that the continuous service date is before the Calculation Period
  ------------------------------------------------------------------------ */

IF (ACP_CONTINUOUS_SERVICE_DATE WAS DEFAULTED) THEN
    (
    E = set_date(''CONTINUOUS_SERVICE_DATE'', ACP_SERVICE_START_DATE)
    )
ELSE IF(ACP_CONTINUOUS_SERVICE_DATE > Calculation_Period_SD) THEN
   (
    Total_Accrued_PTO = 0
    E = PUT_MESSAGE(''HR_52796_PTO_FML_CSD'')
    E = set_date(''CONTINUOUS_SERVICE_DATE'', ACP_CONTINUOUS_SERVICE_DATE)
   )
ELSE
  (
    E = set_date(''CONTINUOUS_SERVICE_DATE'', ACP_CONTINUOUS_SERVICE_DATE)
  )

/* ------------------------------------------------------------------------
   Determine the Accrual Start Rule and modify the start date of the accrual calculation accordingly

   N.B. In this calculation the Accrual Start Rule determines the date from which a person may first accrue
   PTO. The Ineligibility Rule determines the period of time during which the PTO is not registered.
   Once this date has passed the accrual is registered from the date determined by the Accrual Start Rule.
 ------------------------------------------------------------------------ */

Continuous_Service_Date = get_date(''CONTINUOUS_SERVICE_DATE'')

IF (ACP_START = ''BOY'') THEN
    (
     First_Eligible_To_Accrue_Date =
         to_date(''01/01/''||to_char(add_months(Continuous_Service_Date, 12), ''YYYY''),
                 ''DD/MM/YYYY'')
     )
ELSE IF (ACP_START = ''PLUS_SIX_MONTHS'') THEN
    (
     First_Eligible_To_Accrue_Date = add_months(Continuous_Service_Date,6)
     )
ELSE IF (ACP_START = ''HD'') THEN
    (
     First_Eligible_To_Accrue_Date  = Continuous_Service_Date
     )

/*------------------------------------------------------------------------
   Determine the date on which accrued PTo may first be registered, i.e the date on which the
   Ineligibility Period expires
   ------------------------------------------------------------------------ */

Accrual_Ineligibility_Expired_Date = First_Eligible_To_Accrue_Date

IF (ACP_START <> ''PLUS_SIX_MONTHS'' AND
     ACP_INELIGIBILITY_PERIOD_LENGTH > 0) THEN
   (
   IF ACP_INELIGIBILITY_PERIOD_TYPE = ''BM'' THEN
      (
      Accrual_Ineligibility_Expired_Date = add_months(Continuous_Service_Date,
                                                    ACP_INELIGIBILITY_PERIOD_LENGTH*2)
      )
   ELSE IF ACP_INELIGIBILITY_PERIOD_TYPE = ''F'' THEN
      (
      Accrual_Ineligibility_Expired_Date = add_days(Continuous_Service_Date,
                                                    ACP_INELIGIBILITY_PERIOD_LENGTH*14)
      )
   ELSE IF ACP_INELIGIBILITY_PERIOD_TYPE = ''CM'' THEN
      (
      Accrual_Ineligibility_Expired_Date = add_months(Continuous_Service_Date,
                                                      ACP_INELIGIBILITY_PERIOD_LENGTH)
      )
   ELSE IF ACP_INELIGIBILITY_PERIOD_TYPE = ''LM'' THEN
      (
      Accrual_Ineligibility_Expired_Date = add_days(Continuous_Service_Date,
                                                  ACP_INELIGIBILITY_PERIOD_LENGTH*28)
      )
   ELSE IF ACP_INELIGIBILITY_PERIOD_TYPE = ''Q'' THEN
      (
      Accrual_Ineligibility_Expired_Date = add_months(Continuous_Service_Date,
                                                      ACP_INELIGIBILITY_PERIOD_LENGTH*3)
      )
   ELSE IF ACP_INELIGIBILITY_PERIOD_TYPE = ''SM'' THEN
      (
      Accrual_Ineligibility_Expired_Date = add_months(Continuous_Service_Date,
                                                      ACP_INELIGIBILITY_PERIOD_LENGTH/2)
      )
   ELSE IF ACP_INELIGIBILITY_PERIOD_TYPE = ''SY'' THEN
      (
      Accrual_Ineligibility_Expired_Date = add_months(Continuous_Service_Date,
                                                      ACP_INELIGIBILITY_PERIOD_LENGTH*6)
      )
   ELSE IF ACP_INELIGIBILITY_PERIOD_TYPE = ''W'' THEN
      (
      Accrual_Ineligibility_Expired_Date = add_days(Continuous_Service_Date,
                                                    ACP_INELIGIBILITY_PERIOD_LENGTH*7)
      )
   ELSE IF ACP_INELIGIBILITY_PERIOD_TYPE = ''Y'' THEN
      (
      Accrual_Ineligibility_Expired_Date = add_months(Continuous_Service_Date,
                                                      ACP_INELIGIBILITY_PERIOD_LENGTH*12)
      )

   IF Accrual_Ineligibility_Expired_Date > First_Eligible_To_Accrue_Date
   AND Calculation_Date < Accrual_Ineligibility_Expired_Date THEN
      (
      First_Eligible_To_Accrue_Date = Accrual_Ineligibility_Expired_Date
      )
   )


/* ----------------------------------------------------------------------
  If the employee is eligible to accrue before the start of this year,
  we must get the period dates for the first period of the year.
  Otherwise, we do not need these dates, as we will never accrue that
  far back.
----------------------------------------------------------------------- */

IF (not Accrual_Start_Date was defaulted) AND
   ((Calculation_Date < Accrual_Ineligibility_Expired_Date) OR
    (Accrual_Start_Date > Accrual_Ineligibility_Expired_Date)) THEN
(

/*
 * This function checks for unprocessed plan element entries, and
 * returns the EE effective start date of the earliest it finds. This may
 * be useful if we amend the design to process a partial year starting at
 * this date.
 *
 * At the moment, however, we simply recalculate for the entire plan term
 * in these circumstances, so Adjusted_Start_Date is never used
 */

  Adjusted_Start_Date = Get_Start_Date(Accrual_Start_Date,
                                       Payroll_Year_First_Valid_Date)

  IF (Adjusted_Start_Date < Accrual_Start_Date) THEN
  (
    Process_Full_Term = ''Y''
  )
  ELSE
  (
    Process_Full_Term = ''N''
  )
)
ELSE
(
  Process_Full_Term = ''Y''
)

Latest_Balance = 0

IF (Process_Full_Term = ''N'') AND
   (Accrual_Start_Date >= First_Eligible_To_Accrue_Date) THEN
(
  E = GET_PAYROLL_PERIOD(Adjusted_Start_Date)
  Payroll_Year_1st_Period_SD = get_date(''PAYROLL_PERIOD_START_DATE'')
  Payroll_Year_1st_Period_ED = get_date(''PAYROLL_PERIOD_END_DATE'')

  Latest_Balance = Accrual_Latest_Balance
  Effective_Start_Date = Adjusted_Start_Date

  IF First_Eligible_To_Accrue_Date > Payroll_Year_1st_Period_SD THEN
  (
     E = GET_PAYROLL_PERIOD(ADD_DAYS(Payroll_Year_1st_Period_ED, 1))

    Payroll_Year_1st_Period_SD = get_date(''PAYROLL_PERIOD_START_DATE'')
    Payroll_Year_1st_Period_ED = get_date(''PAYROLL_PERIOD_END_DATE'')
  )

)
ELSE IF First_Eligible_To_Accrue_Date <= Payroll_Year_First_Valid_Date THEN
(
  IF (not Accrual_Start_Date was defaulted) THEN
  (
    Latest_Balance = Accrual_Latest_Balance
  )
  ELSE
  (
    Latest_Balance = 0
  )

  E = GET_PAYROLL_PERIOD(Payroll_Year_First_Valid_Date)

  Payroll_Year_1st_Period_SD = get_date(''PAYROLL_PERIOD_START_DATE'')
  Payroll_Year_1st_Period_ED = get_date(''PAYROLL_PERIOD_END_DATE'')

  IF Payroll_Year_1st_Period_SD <> Payroll_Year_First_Valid_Date THEN
  (
     E = GET_PAYROLL_PERIOD(ADD_DAYS(Payroll_Year_1st_Period_ED, 1))

    Payroll_Year_1st_Period_SD = get_date(''PAYROLL_PERIOD_START_DATE'')
    Payroll_Year_1st_Period_ED = get_date(''PAYROLL_PERIOD_END_DATE'')
  )

  Effective_Start_Date = Payroll_Year_First_Valid_Date
)
ELSE
(
  /* ------------------------------------------------------------------------
   Get the first full payroll period following the First_Eligible_To_Accrue_Date
   (if it falls on the beginning of the period then use that period)
  ------------------------------------------------------------------------- */
  IF (not Accrual_Start_Date was defaulted) THEN
  (
    Latest_Balance = Accrual_Latest_Balance
  )
  ELSE
  (
    Latest_Balance = 0
  )

  E = GET_PAYROLL_PERIOD(First_Eligible_To_Accrue_Date )
  First_Eligible_To_Accrue_Period_SD  = get_date(''PAYROLL_PERIOD_START_DATE'')
  First_Eligible_To_Accrue_Period_ED  = get_date(''PAYROLL_PERIOD_END_DATE'')

  IF First_Eligible_To_Accrue_Date <> First_Eligible_To_Accrue_Period_SD THEN
  (
    E = GET_PAYROLL_PERIOD(add_days(First_Eligible_To_Accrue_Period_ED,1))
    First_Eligible_To_Accrue_Period_SD  = get_date(''PAYROLL_PERIOD_START_DATE'')
    First_Eligible_To_Accrue_Period_ED  = get_date(''PAYROLL_PERIOD_END_DATE'')
   )

  IF (First_Eligible_To_Accrue_Period_SD > Calculation_Period_ED) THEN
  (
    Total_Accrued_PTO = 0
    E = PUT_MESSAGE(''HR_52793_PTO_FML_ASG_INELIG'')
  )

  Payroll_Year_1st_Period_SD = First_Eligible_To_Accrue_Period_SD
  Payroll_Year_1st_Period_ED = First_Eligible_To_Accrue_Period_ED

  Effective_Start_Date = First_Eligible_To_Accrue_Date
)

  Effective_Start_Date = GREATEST(Effective_Start_Date, ACP_ENROLLMENT_START_DATE)

/* -----------------------------------------------------------------
  Output messages based on calculated date
----------------------------------------------------------------- */

IF (Early_End_Date < Payroll_Year_1st_Period_ED) THEN
(
  Total_Accrued_PTO = 0
  E = PUT_MESSAGE(''HR_52794_PTO_FML_ASG_TER'')
)

If (Calculation_Period_ED < Payroll_Year_1st_Period_ED) THEN
(
  Total_Accrued_PTO = 0
  E = PUT_MESSAGE(''HR_52795_PTO_FML_CALC_DATE'')
)



/* ------------------------------------------------------------------------
   Determine the date on which PTO actually starts accruing based on Hire Date,
   Continuous Service Date and plan Enrollment Start Date. Remember, we have
   already determined whether to user hire date or CSD earlier in the formula.
   If this date is after the 1st period and the fisrt eligible date then
   establish the first full payroll period after this date
   (if the Actual Start Date falls on the beginning of a payroll period then
   use this period)
 ------------------------------------------------------------------------ */


  Enrollment_Start_Date = ACP_ENROLLMENT_START_DATE

  Actual_Accrual_Start_Date = GREATEST(Enrollment_Start_Date,
                                       Continuous_Service_Date,
                                       Payroll_Year_1st_Period_SD)

/* -------------------------------------------------------------------------
       Determine the actual start of the accrual calculation
-------------------------------------------------------------------------*/
IF (Actual_Accrual_Start_Date > Payroll_Year_1st_Period_SD AND
     Actual_Accrual_Start_Date > First_Eligible_To_Accrue_Date) THEN
    (
     E = GET_PAYROLL_PERIOD(Actual_Accrual_Start_Date)

     Accrual_Start_Period_SD = get_date(''PAYROLL_PERIOD_START_DATE'')
     Accrual_Start_Period_ED = get_date(''PAYROLL_PERIOD_END_DATE'')

     IF Actual_Accrual_Start_Date > Accrual_Start_Period_SD THEN
         (
          E = GET_PAYROLL_PERIOD(add_days(Accrual_Start_Period_ED,1))

          Accrual_Start_Period_SD = get_date(''PAYROLL_PERIOD_START_DATE'')
          Accrual_Start_Period_ED = get_date(''PAYROLL_PERIOD_END_DATE'')
         )

/* -----------------------------------------------------------------
        If the Actual Acrual Period is after the Calculation Period then end the processing.
----------------------------------------------------------------- */
        IF (Accrual_Start_Period_SD > Calculation_Period_ED) THEN
            (
            Total_Accrued_PTO = 0
            E = PUT_MESSAGE(''HR_52797_PTO_FML_ACT_ACCRUAL'')
            )
     )

ELSE IF (First_Eligible_To_Accrue_Date > Payroll_Year_1st_Period_SD) THEN
     (
          Accrual_Start_Period_SD = First_Eligible_To_Accrue_Period_SD
          Accrual_Start_Period_ED = First_Eligible_To_Accrue_Period_ED
     )
ELSE
    (
          Accrual_Start_Period_SD = Payroll_Year_1st_Period_SD
          Accrual_Start_Period_ED = Payroll_Year_1st_Period_ED
    )

 /* -------------------------------------------------------------------
       Now set up the information that will be used in when looping
       through the payroll periods
--------------------------------------------------------------------- */

IF Calculation_Period_ED >= Accrual_Start_Period_ED THEN
(
E = set_date(''PERIOD_SD'',Accrual_Start_Period_SD)
E = set_date(''PERIOD_ED'',Accrual_Start_Period_ED)
E = set_date(''LAST_PERIOD_SD'',Calculation_Period_SD)
E = set_date(''LAST_PERIOD_ED'',Calculation_Period_ED)

IF (Process_Full_Term = ''N'') THEN
(
  E = set_number(''TOTAL_ACCRUED_PTO'', Latest_Balance)
)
ELSE
(
  E = set_number(''TOTAL_ACCRUED_PTO'', 0)
)

/* -------------------------------------------------------------------
       Initialize Band Information
-------------------------------------------------------------------- */

E = set_number(''ANNUAL_RATE'', 0)
E = set_number(''UPPER_LIMIT'', 0)
E = set_number(''CEILING'', 0)

E = LOOP_CONTROL(''PTO_PAYROLL_PERIOD_ACCRUAL'')

Total_Accrued_PTO = get_number(''TOTAL_ACCRUED_PTO'') - Latest_Balance
)

IF Accrual_Start_Period_SD <= Calculation_Period_SD THEN
(
  Accrual_end_date = Calculation_Period_ED
)

IF Process_Full_Term = ''Y'' AND
   Effective_Start_Date > Actual_Accrual_Start_Date THEN
(
  Effective_Start_Date = Actual_Accrual_Start_Date
)

Effective_End_Date = Calculation_Date

IF Effective_Start_Date >= Effective_End_Date THEN
(
  Effective_Start_Date = least(Effective_End_Date, Accrual_Start_Period_SD)
)

RETURN Total_Accrued_PTO, Effective_start_date, Effective_end_date, Accrual_end_date
';
    --
    select formula_type_id
    into   l_ftype_id
    from   ff_formula_types
    where  formula_type_name = 'Accrual';
    --
     INSERT INTO ff_formulas_f
     (formula_id,
      effective_start_date,
      effective_end_date,
      business_group_id,
      legislation_code,
      formula_type_id,
      formula_name,
      description,
      formula_text,
      sticky_flag)
   VALUES
     (ff_formulas_s.nextval,
      to_date('01/01/0001','DD/MM/YYYY'),
      to_date('31/12/4712','DD/MM/YYYY'),
      NULL,
      NULL,
      l_ftype_id,
      'PTO_PAYROLL_BALANCE_CALCULATION',
      'Seeded top level payroll formula for PTO accruals',
      l_text,
      NULL);
    --
    hr_utility.set_location ('hrstrdbi.insert_formula', 134);
    --
l_text := '
/* ------------------------------------------------------------------------
    NAME : PTO_SIMPLE_BALANCE_MULTIPLIER
    This formula calculates the start and end dates for out simple multiplier.
    This formula calculates the dates between which an assignment is to accrue.
    It is based on PTO_SIMPLE_MULTIPLIER, but has been amended to allow its
    use in the new payroll balance functionality. It may not be used out of the box
    but must be amended, according to the documentaion, by inserting the
    name of the database item which was created with your defined balance.
    This defined balance should have been created immediately after the
    accrual plan.
   ---------------------------------------------------------------------*/

DEFAULT FOR ACP_INELIGIBILITY_PERIOD_TYPE IS ''CM''
DEFAULT FOR ACP_INELIGIBILITY_PERIOD_LENGTH IS 0
DEFAULT FOR ACP_CONTINUOUS_SERVICE_DATE IS ''4712/12/31 00:00:00'' (date)
DEFAULT FOR ACP_ENROLLMENT_END_DATE IS ''4712/12/31 00:00:00'' (date)
DEFAULT FOR ACP_TERMINATION_DATE IS ''4712/12/31 00:00:00'' (date)
DEFAULT FOR ACP_ENROLLMENT_START_DATE IS ''4712/12/31 00:00:00'' (date)
DEFAULT FOR ACP_SERVICE_START_DATE IS ''4712/12/31 00:00:00'' (date)

default for Accrual_Start_Date is ''4712/12/31 00:00:00'' (date)
default for Accrual_Latest_Balance is 0

INPUTS ARE
Calculation_Date (date),
Accrual_Start_Date (date),
Accrual_Latest_Balance

E = SET_NUMBER(''CEILING'', 20)
E = SET_NUMBER(''ACCRUAL_RATE'', 2)

Accruing_Frequency = ''M''   /* Month */
Accruing_Multiplier = 1

E = SET_TEXT(''ACCRUING_FREQUENCY'', Accruing_Frequency)
E = SET_NUMBER(''ACCRUING_MULTIPLIER'', Accruing_Multiplier)

Beginning_Of_Calculation_Year = to_date(''0106''||to_char(Calculation_Date,''YYYY''),
                                        ''DDMMYYYY'')

IF (Beginning_Of_Calculation_Year > Calculation_Date) THEN
(
  Beginning_of_Calculation_Year = ADD_MONTHS(Beginning_Of_Calculation_Year, -12)
)

IF Accrual_Start_Date < Beginning_Of_Calculation_Year THEN
(
  Accrual_Start_Date = Beginning_Of_Calculation_Year
)

E = SET_DATE(''BEGINNING_OF_CALCULATION_YEAR'', Beginning_Of_Calculation_Year)

E = GET_PERIOD_DATES(Beginning_of_Calculation_Year,
                     Accruing_Frequency,
                     Beginning_Of_Calculation_Year,
                     Accruing_Multiplier)

First_Period_SD = get_date(''PERIOD_START_DATE'')
First_Period_ED = get_date(''PERIOD_END_DATE'')

/* ------------------------------------------------------------------------
   Set the Calculation_Date to the Termination Date if not null
-------------------------------------------------------------------------- */

IF NOT (ACP_TERMINATION_DATE WAS DEFAULTED) OR
    NOT (ACP_ENROLLMENT_END_DATE WAS DEFAULTED) THEN
(
  Early_End_Date = least(ACP_TERMINATION_DATE, ACP_ENROLLMENT_END_DATE)

  IF (Early_End_Date < First_Period_ED) THEN
  (
    Total_Accrued_PTO = 0
    E = PUT_MESSAGE(''HR_52794_PTO_FML_ASG_TER'')
   )

  IF (Early_End_Date < Calculation_Date) THEN
  (
    Calculation_Date = Early_End_Date
  )
)

/* ------------------------------------------------------------------------
   Get the last whole period prior to the Calculation Date and ensure that it is within the
   Year (if the Calculation Date is the End of a Period then use that period)
   ------------------------------------------------------------------------ */

E = GET_PERIOD_DATES(Calculation_Date,
                     Accruing_Frequency,
                     Beginning_of_Calculation_Year,
                     Accruing_Multiplier)

Calculation_Period_SD  = get_date(''PERIOD_START_DATE'')
Calculation_Period_ED = get_date(''PERIOD_END_DATE'')

IF (Calculation_Date <> Calculation_Period_ED) THEN
    (
     E = GET_PERIOD_DATES(ADD_DAYS(Calculation_Period_SD,-1),
                                                Accruing_Frequency,
                                                Beginning_of_Calculation_Year,
                                                Accruing_Multiplier)

    Calculation_Period_SD  = get_date(''PERIOD_START_DATE'')
    Calculation_Period_ED = get_date(''PERIOD_END_DATE'')
   )

If (Calculation_Period_ED < First_Period_ED) THEN
   (
    Total_Accrued_PTO = 0
    E = PUT_MESSAGE(''HR_52795_PTO_FML_CALC_DATE'')
    )

/* ------------------------------------------------------------------------
   Set the Continuous Service Global Variable, whilst also
   ensuring that the continuous service date is before the Calculation Period
  ------------------------------------------------------------------------ */

IF (ACP_CONTINUOUS_SERVICE_DATE WAS DEFAULTED) THEN
    (
    E = set_date(''CONTINUOUS_SERVICE_DATE'', ACP_SERVICE_START_DATE)
    )
ELSE IF(ACP_CONTINUOUS_SERVICE_DATE > Calculation_Period_SD) THEN
   (
    Total_Accrued_PTO = 0
    E = PUT_MESSAGE(''HR_52796_PTO_FML_CSD'')
    E = set_date(''CONTINUOUS_SERVICE_DATE'', ACP_CONTINUOUS_SERVICE_DATE)
   )
ELSE
  (
    E = set_date(''CONTINUOUS_SERVICE_DATE'', ACP_CONTINUOUS_SERVICE_DATE)
  )

Continuous_Service_Date = get_date(''CONTINUOUS_SERVICE_DATE'')

First_Eligible_To_Accrue_Date  = Continuous_Service_Date

/*------------------------------------------------------------------------
   Determine the date on which accrued PTo may first be registered, i.e the date on which the
   Ineligibility Period expires
   ------------------------------------------------------------------------ */

Accrual_Ineligibility_Expired_Date = First_Eligible_To_Accrue_Date

IF (ACP_INELIGIBILITY_PERIOD_LENGTH > 0) THEN
   (
   IF ACP_INELIGIBILITY_PERIOD_TYPE = ''BM'' THEN
      (
      Accrual_Ineligibility_Expired_Date = add_months(Continuous_Service_Date,
                                                      ACP_INELIGIBILITY_PERIOD_LENGTH*2)
      )
   ELSE IF ACP_INELIGIBILITY_PERIOD_TYPE = ''F'' THEN
      (
      Accrual_Ineligibility_Expired_Date = add_days(Continuous_Service_Date,
                                                    ACP_INELIGIBILITY_PERIOD_LENGTH*14)
      )
   ELSE IF ACP_INELIGIBILITY_PERIOD_TYPE = ''CM'' THEN
      (
      Accrual_Ineligibility_Expired_Date = add_months(Continuous_Service_Date,
                                                      ACP_INELIGIBILITY_PERIOD_LENGTH)
      )
   ELSE IF ACP_INELIGIBILITY_PERIOD_TYPE = ''LM'' THEN
      (
      Accrual_Ineligibility_Expired_Date = add_days(Continuous_Service_Date,
                                                    ACP_INELIGIBILITY_PERIOD_LENGTH*28)
      )
   ELSE IF ACP_INELIGIBILITY_PERIOD_TYPE = ''Q'' THEN
      (
      Accrual_Ineligibility_Expired_Date = add_months(Continuous_Service_Date,
                                                      ACP_INELIGIBILITY_PERIOD_LENGTH*3)
      )
   ELSE IF ACP_INELIGIBILITY_PERIOD_TYPE = ''SM'' THEN
      (
      Accrual_Ineligibility_Expired_Date = add_months(Continuous_Service_Date,
                                                      ACP_INELIGIBILITY_PERIOD_LENGTH/2)
      )
   ELSE IF ACP_INELIGIBILITY_PERIOD_TYPE = ''SY'' THEN
      (
      Accrual_Ineligibility_Expired_Date = add_months(Continuous_Service_Date,
                                                      ACP_INELIGIBILITY_PERIOD_LENGTH*6)
      )
   ELSE IF ACP_INELIGIBILITY_PERIOD_TYPE = ''W'' THEN
      (
      Accrual_Ineligibility_Expired_Date = add_days(Continuous_Service_Date,
                                                    ACP_INELIGIBILITY_PERIOD_LENGTH*7)
      )
   ELSE IF ACP_INELIGIBILITY_PERIOD_TYPE = ''Y'' THEN
      (
      Accrual_Ineligibility_Expired_Date = add_months(Continuous_Service_Date,
                                                      ACP_INELIGIBILITY_PERIOD_LENGTH*12)
      )

   IF Accrual_Ineligibility_Expired_Date > First_Eligible_To_Accrue_Date
   AND Calculation_Date < Accrual_Ineligibility_Expired_Date THEN
      (
      First_Eligible_To_Accrue_Date = Accrual_Ineligibility_Expired_Date
      )
   )

/* ------------------------------------------------------------------------
   Get the first full period following the First_Eligible_To_Accrue_Date
   (if it falls on the beginning of the period then use that period)
------------------------------------------------------------------------- */

Latest_Balance = 0

IF (not Accrual_Start_Date was defaulted) AND
   ((Calculation_Date < Accrual_Ineligibility_Expired_Date) OR
    (Accrual_Start_Date > Accrual_Ineligibility_Expired_Date)) THEN
(
  Adjusted_Start_Date = Get_Start_Date(Accrual_Start_Date,
                                       Beginning_Of_Calculation_Year)

  IF (Adjusted_Start_Date < Accrual_Start_Date) THEN
  (
    Process_Full_Term = ''Y''
  )
  ELSE
  (
    Process_Full_Term = ''N''
  )
)
ELSE
(
  Process_Full_Term = ''Y''
)

IF (Process_Full_Term = ''N'') AND
   (Accrual_Start_Date >= First_Eligible_To_Accrue_Date) THEN
(

  E = GET_PERIOD_DATES(Adjusted_Start_Date,
                       Accruing_Frequency,
                       Beginning_Of_Calculation_Year,
                       Accruing_Multiplier)

  First_Eligible_To_Accrue_Period_SD = get_date(''PERIOD_START_DATE'')
  First_Eligible_To_Accrue_Period_ED = get_date(''PERIOD_END_DATE'')

  Latest_Balance = Accrual_Latest_Balance
  Effective_Start_Date = Accrual_Start_Date

)
ELSE IF First_Eligible_To_Accrue_Date > Beginning_Of_Calculation_Year THEN
(
  IF (not Accrual_Start_Date was defaulted) THEN
  (
    Latest_Balance = Accrual_Latest_Balance
  )
  ELSE
  (
    Latest_Balance = 0
  )

  E = GET_PERIOD_DATES(First_Eligible_To_Accrue_Date,
                       Accruing_Frequency,
                       Beginning_Of_Calculation_Year,
                       Accruing_Multiplier)

  First_Eligible_To_Accrue_Period_SD  = get_date(''PERIOD_START_DATE'')
  First_Eligible_To_Accrue_Period_ED  = get_date(''PERIOD_END_DATE'')

  IF First_Eligible_To_Accrue_Date <> First_Eligible_To_Accrue_Period_SD THEN
      (
       E = GET_PERIOD_DATES(add_days(First_Eligible_To_Accrue_Period_ED,1),
                                                  Accruing_Frequency,
                                                  Beginning_Of_Calculation_Year,
                                                  Accruing_Multiplier)

       First_Eligible_To_Accrue_Period_SD  = get_date(''PERIOD_START_DATE'')
       First_Eligible_To_Accrue_Period_ED  = get_date(''PERIOD_END_DATE'')
       )

  IF (First_Eligible_To_Accrue_Period_SD > Calculation_Period_ED) THEN
     (
       Total_Accrued_PTO = 0
       E = PUT_MESSAGE(''HR_52793_PTO_FML_ASG_INELIG'')
    )

  Effective_Start_Date = First_Eligible_To_Accrue_Date
)
ELSE
(
  IF (not Accrual_Start_Date was defaulted) THEN
  (
    Latest_Balance = Accrual_Latest_Balance
  )
  ELSE
  (
    Latest_Balance = 0
  )

  First_Eligible_To_Accrue_Period_SD  = First_Period_SD
  First_Eligible_To_Accrue_Period_ED  = First_Period_ED

  Effective_Start_Date = Beginning_Of_Calculation_Year
)
/* ------------------------------------------------------------------------
   Determine the date on which PTO actually starts accruing based on Hire Date,
   Continuous Service Date and plan Enrollment Start Date. Remember, we have already determined
   whether to user hire date or CSD earlier in the formula.
   If this date is after the 1st period and the fisrt eligible date then establish the first full period
   after this date (if the Actual Start Date falls on the beginning of a period then use this period)
 ------------------------------------------------------------------------ */

IF Continuous_Service_date = ACP_CONTINUOUS_SERVICE_DATE THEN
(
  Actual_Accrual_Start_Date = Continuous_service_Date
)
ELSE
(
  Actual_Accrual_Start_Date = greatest(Continuous_Service_Date,
                                       ACP_ENROLLMENT_START_DATE,
                                       First_Period_SD)
)

/* -------------------------------------------------------------------------
       Determine the actual start of the accrual calculation
-------------------------------------------------------------------------*/
IF (Actual_Accrual_Start_Date > First_Period_SD AND
     Actual_Accrual_Start_Date > First_Eligible_To_Accrue_Period_SD) THEN
    (
     E = GET_PERIOD_DATES(Actual_Accrual_Start_Date,
                          Accruing_Frequency,
                          Beginning_Of_Calculation_Year,
                          Accruing_Multiplier)

     Accrual_Start_Period_SD = get_date(''PERIOD_START_DATE'')
     Accrual_Start_Period_ED = get_date(''PERIOD_END_DATE'')

     IF Actual_Accrual_Start_Date > Accrual_Start_Period_SD THEN
         (
          E = GET_PERIOD_DATES(add_days(Accrual_Start_Period_ED,1),
                               Accruing_Frequency,
                               Beginning_of_Calculation_Year,
                               Accruing_Multiplier)

          Accrual_Start_Period_SD = get_date(''PERIOD_START_DATE'')
          Accrual_Start_Period_ED = get_date(''PERIOD_END_DATE'')
         )

/* -----------------------------------------------------------------
        If the Actual Acrual Period is after the Calculation Period then end the processing.
----------------------------------------------------------------- */
        IF (Accrual_Start_Period_SD > Calculation_Period_ED) THEN
            (
            Total_Accrued_PTO = 0
            E = PUT_MESSAGE(''HR_52797_PTO_FML_ACT_ACCRUAL'')
            )
     )

ELSE IF (First_Eligible_To_Accrue_Period_SD > First_Period_SD) THEN
     (
      Accrual_Start_Period_SD = First_Eligible_To_Accrue_Period_SD
      Accrual_Start_Period_ED = First_Eligible_To_Accrue_Period_ED
     )
ELSE
    (
      Accrual_Start_Period_SD = First_Period_SD
      Accrual_Start_Period_ED = First_Period_ED
    )

 /* -------------------------------------------------------------------
       Now set up the information that will be used in when looping through the periods
--------------------------------------------------------------------- */

IF Calculation_Period_ED >= Accrual_Start_Period_ED THEN
(
  E = set_date(''PERIOD_SD'',Accrual_Start_Period_SD)
  E = set_date(''PERIOD_ED'',Accrual_Start_Period_ED)
  E = set_date(''LAST_PERIOD_SD'',Calculation_Period_SD)
  E = set_date(''LAST_PERIOD_ED'',Calculation_Period_ED)

  IF (Process_Full_Term = ''N'') THEN
  (
    E = set_number(''TOTAL_ACCRUED_PTO'', Latest_Balance)
  )
  ELSE
  (
    E = set_number(''TOTAL_ACCRUED_PTO'', 0)
  )

  E = LOOP_CONTROL(''PTO_SIMPLE_PERIOD_ACCRUAL'')

  Total_Accrued_PTO = get_number(''TOTAL_ACCRUED_PTO'') - Latest_Balance

)
ELSE
(
  Total_Accrued_PTO = 0
)


IF Accrual_Start_Period_SD <= Calculation_Period_SD THEN
(
  Accrual_end_date = Calculation_Period_ED
)

IF Process_Full_Term = ''Y'' AND
   Effective_Start_Date > Actual_Accrual_Start_Date THEN
(
  Effective_Start_Date = Actual_Accrual_Start_Date
)

Effective_End_Date = Calculation_Date

IF Effective_Start_Date >= Effective_End_Date THEN
(
  Effective_Start_Date = Effective_End_Date
)

RETURN Total_Accrued_PTO, Effective_start_date, Effective_end_date, Accrual_end_date
';
    --
    select formula_type_id
    into   l_ftype_id
    from   ff_formula_types
    where  formula_type_name = 'Accrual';
    --
     INSERT INTO ff_formulas_f
     (formula_id,
      effective_start_date,
      effective_end_date,
      business_group_id,
      legislation_code,
      formula_type_id,
      formula_name,
      description,
      formula_text,
      sticky_flag)
   VALUES
     (ff_formulas_s.nextval,
      to_date('01/01/0001','DD/MM/YYYY'),
      to_date('31/12/4712','DD/MM/YYYY'),
      NULL,
      NULL,
      l_ftype_id,
      'PTO_SIMPLE_BALANCE_MULTIPLIER',
      'Seeded top level formula for PTO accruals',
      l_text,
      NULL);
    --
    hr_utility.set_location ('hrstrdbi.insert_formula', 135);
    --
l_text := '
/* ------------------------------------------------------------------------
    NAME : PTO_HD_ANNIVERSARY_BALANCE
    This formula calculates the start and end dates for a simple multiplier.
    This formula calculates the dates between which an assignment is to accrue.
   ---------------------------------------------------------------------*/

DEFAULT FOR ACP_INELIGIBILITY_PERIOD_TYPE IS ''CM''
DEFAULT FOR ACP_INELIGIBILITY_PERIOD_LENGTH IS 0
DEFAULT FOR ACP_CONTINUOUS_SERVICE_DATE IS ''4712/12/31 00:00:00'' (date)
DEFAULT FOR ACP_ENROLLMENT_END_DATE IS ''4712/12/31 00:00:00'' (date)
DEFAULT FOR ACP_TERMINATION_DATE IS ''4712/12/31 00:00:00'' (date)
DEFAULT FOR ACP_ENROLLMENT_START_DATE IS ''4712/12/31 00:00:00'' (date)
DEFAULT FOR ACP_SERVICE_START_DATE IS ''4712/12/31 00:00:00'' (date)

default for Accrual_Start_Date is ''4712/12/31 00:00:00'' (date)
default for Accrual_Latest_Balance is 0

INPUTS ARE
Calculation_Date (date),
Accrual_Start_Date (date),
Accrual_Latest_Balance

E = SET_NUMBER(''CEILING'', 20)
E = SET_NUMBER(''ACCRUAL_RATE'', 2)

Accruing_Frequency = ''M''   /* Month */
Accruing_Multiplier = 1

E = SET_TEXT(''ACCRUING_FREQUENCY'', Accruing_Frequency)
E = SET_NUMBER(''ACCRUING_MULTIPLIER'', Accruing_Multiplier)

Hire_Date_Anniversary = add_months(ACP_SERVICE_START_DATE,
                                  trunc(months_between(Calculation_Date,
                                                       ACP_SERVICE_START_DATE) / 12) * 12)

IF Accrual_Start_Date < Hire_Date_Anniversary THEN
(
  Accrual_Start_Date = Hire_Date_Anniversary
)

E = SET_DATE(''HIRE_DATE_ANNIVERSARY'', Hire_Date_Anniversary)

E = GET_PERIOD_DATES(Hire_Date_Anniversary,
                     Accruing_Frequency,
                     Hire_Date_Anniversary,
                     Accruing_Multiplier)

First_Period_SD = get_date(''PERIOD_START_DATE'')
First_Period_ED = get_date(''PERIOD_END_DATE'')

/* ------------------------------------------------------------------------
   Set the Calculation_Date to the Termination Date if not null
-------------------------------------------------------------------------- */

IF NOT (ACP_TERMINATION_DATE WAS DEFAULTED) OR
    NOT (ACP_ENROLLMENT_END_DATE WAS DEFAULTED) THEN
(
  Early_End_Date = least(ACP_TERMINATION_DATE, ACP_ENROLLMENT_END_DATE)

  IF (Early_End_Date < First_Period_ED) THEN
  (
    Total_Accrued_PTO = 0
    E = PUT_MESSAGE(''HR_52794_PTO_FML_ASG_TER'')
   )

  IF (Early_End_Date < Calculation_Date) THEN
  (
    Calculation_Date = Early_End_Date
  )
)

/* ------------------------------------------------------------------------
   Get the last whole period prior to the Calculation Date and ensure that it is within the
   Year (if the Calculation Date is the End of a Period then use that period)
   ------------------------------------------------------------------------ */

E = GET_PERIOD_DATES(Calculation_Date,
                     Accruing_Frequency,
                     Hire_Date_Anniversary,
                     Accruing_Multiplier)

Calculation_Period_SD  = get_date(''PERIOD_START_DATE'')
Calculation_Period_ED = get_date(''PERIOD_END_DATE'')

IF (Calculation_Date <> Calculation_Period_ED) THEN
    (
     E = GET_PERIOD_DATES(ADD_DAYS(Calculation_Period_SD,-1),
                                                Accruing_Frequency,
                                                Hire_Date_Anniversary,
                                                Accruing_Multiplier)

    Calculation_Period_SD  = get_date(''PERIOD_START_DATE'')
    Calculation_Period_ED = get_date(''PERIOD_END_DATE'')
   )

If (Calculation_Period_ED < First_Period_ED) THEN
   (
    Total_Accrued_PTO = 0
    E = PUT_MESSAGE(''HR_52795_PTO_FML_CALC_DATE'')
    )

/* ------------------------------------------------------------------------
   Set the Continuous Service Global Variable, whilst also
   ensuring that the continuous service date is before the Calculation Period
  ------------------------------------------------------------------------ */

IF (ACP_CONTINUOUS_SERVICE_DATE WAS DEFAULTED) THEN
    (
    E = set_date(''SERVICE_START_DATE'', ACP_SERVICE_START_DATE)
    )
ELSE IF(ACP_CONTINUOUS_SERVICE_DATE > Calculation_Period_SD) THEN
   (
    Total_Accrued_PTO = 0
    E = PUT_MESSAGE(''HR_52796_PTO_FML_CSD'')
    E = set_date(''SERVICE_START_DATE'', ACP_CONTINUOUS_SERVICE_DATE)
   )
ELSE
  (
    E = set_date(''SERVICE_START_DATE'', ACP_CONTINUOUS_SERVICE_DATE)
  )

/*
E = set_date(''SERVICE_START_DATE'', ACP_SERVICE_START_DATE)
*/
Service_Start_Date = get_date(''SERVICE_START_DATE'')

First_Eligible_To_Accrue_Date  = Service_Start_Date


/*------------------------------------------------------------------------
   Determine the date on which accrued PTo may first be registered, i.e the date on which the
   Ineligibility Period expires
   ------------------------------------------------------------------------ */

Accrual_Ineligibility_Expired_Date = First_Eligible_To_Accrue_Date

IF (ACP_INELIGIBILITY_PERIOD_LENGTH > 0) THEN
   (
   IF ACP_INELIGIBILITY_PERIOD_TYPE = ''BM'' THEN
      (
      Accrual_Ineligibility_Expired_Date = add_months(Service_Start_Date,
                                                      ACP_INELIGIBILITY_PERIOD_LENGTH*2)
      )
   ELSE IF ACP_INELIGIBILITY_PERIOD_TYPE = ''F'' THEN
      (
      Accrual_Ineligibility_Expired_Date = add_days(Service_Start_Date,
                                                    ACP_INELIGIBILITY_PERIOD_LENGTH*14)
      )
   ELSE IF ACP_INELIGIBILITY_PERIOD_TYPE = ''CM'' THEN
      (
      Accrual_Ineligibility_Expired_Date = add_months(Service_Start_Date,
                                                      ACP_INELIGIBILITY_PERIOD_LENGTH)
      )
   ELSE IF ACP_INELIGIBILITY_PERIOD_TYPE = ''LM'' THEN
      (
      Accrual_Ineligibility_Expired_Date = add_days(Service_Start_Date,
                                                    ACP_INELIGIBILITY_PERIOD_LENGTH*28)
      )
   ELSE IF ACP_INELIGIBILITY_PERIOD_TYPE = ''Q'' THEN
      (
      Accrual_Ineligibility_Expired_Date = add_months(Service_Start_Date,
                                                      ACP_INELIGIBILITY_PERIOD_LENGTH*3)
      )
   ELSE IF ACP_INELIGIBILITY_PERIOD_TYPE = ''SM'' THEN
      (
      Accrual_Ineligibility_Expired_Date = add_months(Service_Start_Date,
                                                      ACP_INELIGIBILITY_PERIOD_LENGTH/2)
      )
   ELSE IF ACP_INELIGIBILITY_PERIOD_TYPE = ''SY'' THEN
      (
      Accrual_Ineligibility_Expired_Date = add_months(Service_Start_Date,
                                                      ACP_INELIGIBILITY_PERIOD_LENGTH*6)
      )
   ELSE IF ACP_INELIGIBILITY_PERIOD_TYPE = ''W'' THEN
      (
      Accrual_Ineligibility_Expired_Date = add_days(Service_Start_Date,
                                                    ACP_INELIGIBILITY_PERIOD_LENGTH*7)
      )
   ELSE IF ACP_INELIGIBILITY_PERIOD_TYPE = ''Y'' THEN
      (
      Accrual_Ineligibility_Expired_Date = add_months(Service_Start_Date,
                                                      ACP_INELIGIBILITY_PERIOD_LENGTH*12)
      )

   IF Accrual_Ineligibility_Expired_Date > First_Eligible_To_Accrue_Date
   AND Calculation_Date < Accrual_Ineligibility_Expired_Date THEN
      (
      First_Eligible_To_Accrue_Date = Accrual_Ineligibility_Expired_Date
      )
   )

/* ------------------------------------------------------------------------
   Get the first full period following the First_Eligible_To_Accrue_Date
   (if it falls on the beginning of the period then use that period)
------------------------------------------------------------------------- */

Latest_Balance = 0

IF (not Accrual_Start_Date was defaulted) AND
   ((Calculation_Date < Accrual_Ineligibility_Expired_Date) OR
    (Accrual_Start_Date > Accrual_Ineligibility_Expired_Date)) THEN
(
  Adjusted_Start_Date = Get_Start_Date(Accrual_Start_Date,
                                       Hire_Date_Anniversary)

  IF (Adjusted_Start_Date < Accrual_Start_Date) THEN
  (
    Process_Full_Term = ''Y''
  )
  ELSE
  (
    Process_Full_Term = ''N''
  )
)
ELSE
(
  Process_Full_Term = ''Y''
)

IF (Process_Full_Term = ''N'') AND
   (Accrual_Start_Date >= First_Eligible_To_Accrue_Date) THEN
(

  E = GET_PERIOD_DATES(Adjusted_Start_Date,
                       Accruing_Frequency,
                       Hire_Date_Anniversary,
                       Accruing_Multiplier)

  First_Eligible_To_Accrue_Period_SD = get_date(''PERIOD_START_DATE'')
  First_Eligible_To_Accrue_Period_ED = get_date(''PERIOD_END_DATE'')

  Latest_Balance = Accrual_Latest_Balance
  Effective_Start_Date = Accrual_Start_Date

)
ELSE IF First_Eligible_To_Accrue_Date > Hire_Date_Anniversary THEN
(
  IF (not Accrual_Start_Date was defaulted) THEN
  (
    Latest_Balance = Accrual_Latest_Balance
  )
  ELSE
  (
    Latest_Balance = 0
  )

  E = GET_PERIOD_DATES(First_Eligible_To_Accrue_Date,
                       Accruing_Frequency,
                       Hire_Date_Anniversary,
                       Accruing_Multiplier)

  First_Eligible_To_Accrue_Period_SD  = get_date(''PERIOD_START_DATE'')
  First_Eligible_To_Accrue_Period_ED  = get_date(''PERIOD_END_DATE'')

  IF First_Eligible_To_Accrue_Date <> First_Eligible_To_Accrue_Period_SD THEN
      (
       E = GET_PERIOD_DATES(add_days(First_Eligible_To_Accrue_Period_ED,1),
                                                  Accruing_Frequency,
                                                  Hire_Date_Anniversary,
                                                  Accruing_Multiplier)

       First_Eligible_To_Accrue_Period_SD  = get_date(''PERIOD_START_DATE'')
       First_Eligible_To_Accrue_Period_ED  = get_date(''PERIOD_END_DATE'')
       )

  IF (First_Eligible_To_Accrue_Period_SD > Calculation_Period_ED) THEN
     (
       Total_Accrued_PTO = 0
       E = PUT_MESSAGE(''HR_52793_PTO_FML_ASG_INELIG'')
    )

  Effective_Start_Date = First_Eligible_To_Accrue_Date

)
ELSE
(
  IF (not Accrual_Start_Date was defaulted) THEN
  (
    Latest_Balance = Accrual_Latest_Balance
  )
  ELSE
  (
    Latest_Balance = 0
  )

  First_Eligible_To_Accrue_Period_SD  = First_Period_SD
  First_Eligible_To_Accrue_Period_ED  = First_Period_ED

  Effective_Start_Date = Hire_Date_Anniversary
)
/* ------------------------------------------------------------------------
   Determine the date on which PTO actually starts accruing based on Hire Date,
   Service Start Date and plan Enrollment Start Date.
   If this date is after the 1st period and the fisrt eligible date then
   establish the first full period after this date (if the Actual Start
   Date falls on the beginning of a period then use this period)
 ------------------------------------------------------------------------ */

Actual_Accrual_Start_Date = greatest(Service_Start_Date,
                                     ACP_ENROLLMENT_START_DATE,
                                     First_Period_SD)

/* -------------------------------------------------------------------------
       Determine the actual start of the accrual calculation
-------------------------------------------------------------------------*/
IF (Actual_Accrual_Start_Date > First_Period_SD AND
     Actual_Accrual_Start_Date > First_Eligible_To_Accrue_Period_SD) THEN
    (
     E = GET_PERIOD_DATES(Actual_Accrual_Start_Date,
                          Accruing_Frequency,
                          Hire_Date_Anniversary,
                          Accruing_Multiplier)

     Accrual_Start_Period_SD = get_date(''PERIOD_START_DATE'')
     Accrual_Start_Period_ED = get_date(''PERIOD_END_DATE'')

     IF Actual_Accrual_Start_Date > Accrual_Start_Period_SD THEN
         (
          E = GET_PERIOD_DATES(add_days(Accrual_Start_Period_ED,1),
                               Accruing_Frequency,
                               Hire_Date_Anniversary,
                               Accruing_Multiplier)

          Accrual_Start_Period_SD = get_date(''PERIOD_START_DATE'')
          Accrual_Start_Period_ED = get_date(''PERIOD_END_DATE'')
         )

/* -----------------------------------------------------------------
        If the Actual Acrual Period is after the Calculation Period then end the processing.
----------------------------------------------------------------- */
        IF (Accrual_Start_Period_SD > Calculation_Period_ED) THEN
            (
            Total_Accrued_PTO = 0
            E = PUT_MESSAGE(''HR_52797_PTO_FML_ACT_ACCRUAL'')
            )
     )

ELSE IF (First_Eligible_To_Accrue_Period_SD > First_Period_SD) THEN
     (
      Accrual_Start_Period_SD = First_Eligible_To_Accrue_Period_SD
      Accrual_Start_Period_ED = First_Eligible_To_Accrue_Period_ED
     )
ELSE
    (
      Accrual_Start_Period_SD = First_Period_SD
      Accrual_Start_Period_ED = First_Period_ED
    )

 /* -------------------------------------------------------------------
       Now set up the information that will be used in when looping through the periods
--------------------------------------------------------------------- */

IF Calculation_Period_ED >= Accrual_Start_Period_ED THEN
(
  E = set_date(''PERIOD_SD'',Accrual_Start_Period_SD)
  E = set_date(''PERIOD_ED'',Accrual_Start_Period_ED)
  E = set_date(''LAST_PERIOD_SD'',Calculation_Period_SD)
  E = set_date(''LAST_PERIOD_ED'',Calculation_Period_ED)

  IF (Process_Full_Term = ''N'') THEN
  (
    E = set_number(''TOTAL_ACCRUED_PTO'', Latest_Balance)
  )
  ELSE
  (
    E = set_number(''TOTAL_ACCRUED_PTO'', 0)
  )

  E = LOOP_CONTROL(''PTO_HD_ANNIVERSARY_PERIOD_ACCRUAL'')

  Total_Accrued_PTO = get_number(''TOTAL_ACCRUED_PTO'') - Latest_Balance

)
ELSE
(
  Total_Accrued_PTO = 0
)


IF Accrual_Start_Period_SD <= Calculation_Period_SD THEN
(
  Accrual_end_date = Calculation_Period_ED
)

IF Process_Full_Term = ''Y'' AND
   Effective_Start_Date > Actual_Accrual_Start_Date THEN
(
  Effective_Start_Date = Actual_Accrual_Start_Date
)

Effective_End_Date = Calculation_Date

IF Effective_Start_Date >= Effective_End_Date THEN
(
  Effective_Start_Date = Effective_End_Date
)

RETURN Total_Accrued_PTO, Effective_start_date, Effective_end_date, Accrual_end_date
';
    --
    select formula_type_id
    into   l_ftype_id
    from   ff_formula_types
    where  formula_type_name = 'Accrual';
    --
     INSERT INTO ff_formulas_f
     (formula_id,
      effective_start_date,
      effective_end_date,
      business_group_id,
      legislation_code,
      formula_type_id,
      formula_name,
      description,
      formula_text,
      sticky_flag)
   VALUES
     (ff_formulas_s.nextval,
      to_date('01/01/0001','DD/MM/YYYY'),
      to_date('31/12/4712','DD/MM/YYYY'),
      NULL,
      NULL,
      l_ftype_id,
      'PTO_HD_ANNIVERSARY_BALANCE',
      'Seeded simple top level formula for PTO accruals',
      l_text,
      NULL);
    --
    hr_utility.set_location ('hrstrdbi.insert_formula', 136);
    --
l_text := '
/* ------------------------------------------------------------------------
    NAME : PTO_HD_ANNIVERSARY_PERIOD_ACCRUAL
    This formula calculates the amount of PTO accrued for a particular period
   ---------------------------------------------------------------------*/

/*------------------------------------------------------------------------
    Get the global variable to be used in this formula
 ------------------------------------------------------------------------*/

Service_Start_Date = get_date(''SERVICE_START_DATE'')
Total_Accrued_PTO = get_number(''TOTAL_ACCRUED_PTO'')
Period_SD = get_date(''PERIOD_SD'')
Period_ED = get_date(''PERIOD_ED'')
Last_Period_SD = get_date(''LAST_PERIOD_SD'')
Last_Period_ED = get_date(''LAST_PERIOD_ED'')

Accrual_Rate = get_number(''ACCRUAL_RATE'')
Accruing_Frequency = get_text(''ACCRUING_FREQUENCY'')
Accruing_Multiplier = get_number(''ACCRUING_MULTIPLIER'')
Hire_Date_Anniversary = get_date(''HIRE_DATE_ANNIVERSARY'')

Ceiling = get_number(''CEILING'')

/* ----------------------------------------------------------------------
    Calculate the Amount Accrued this Period
   ---------------------------------------------------------------------*/

Period_Accrued_PTO = Accrual_Rate

/* ----------------------------------------------------------------------
    Calculate any absence or bought/sold time etc. to be accounted for in this period.
   ---------------------------------------------------------------------*/

Absence = GET_ABSENCE(Period_ED, Hire_Date_Anniversary)
CarryOver = GET_CARRY_OVER(Period_ED, Hire_Date_Anniversary)
Other = GET_OTHER_NET_CONTRIBUTION(Period_ED, Hire_Date_Anniversary)

Period_Others = CarryOver + Other - Absence

/* ----------------------------------------------------------------------
    Now establish whether the Accrual this period has gone over the ceiling if one exists
   ----------------------------------------------------------------------*/

IF (Ceiling > 0) THEN
    (
     IF (Total_Accrued_PTO + Period_Accrued_PTO + Period_Others > Ceiling) THEN
         (
          Amount_Over_Ceiling = Total_Accrued_PTO + Period_Accrued_PTO + Period_Others - Ceiling
          IF (Amount_Over_Ceiling > Period_Accrued_PTO) THEN
               (
               Period_Accrued_PTO = 0
               )
          ELSE
              (
               Period_Accrued_PTO = Period_Accrued_PTO - Amount_Over_Ceiling
              )
          )
     )

/*---------------------------------------------------------------------
    Set the Running Total
  ---------------------------------------------------------------------*/

E = set_number(''TOTAL_ACCRUED_PTO'',Total_Accrued_PTO + Period_Accrued_PTO)


/* ----------------------------------------------------------------------
    Establish whether the current period is the last one, if so end the processing, otherwise get the
    next period
------------------------------------------------------------------------*/

IF Period_SD >= Last_Period_SD THEN
    (
    Continue_Processing_Flag = ''N''
    )
ELSE
   (
    E = GET_PERIOD_DATES(ADD_DAYS(Period_ED,1),
                         Accruing_Frequency,
                         Hire_Date_Anniversary,
                         Accruing_Multiplier)

    E = set_date(''PERIOD_SD'', get_date(''PERIOD_START_DATE''))
    E = set_date(''PERIOD_ED'', get_date(''PERIOD_END_DATE''))

   Continue_Processing_Flag = ''Y''
   )

Return Continue_Processing_Flag
';
    --
    select formula_type_id
    into   l_ftype_id
    from   ff_formula_types
    where  formula_type_name = 'Accrual Subformula';
    --
     INSERT INTO ff_formulas_f
     (formula_id,
      effective_start_date,
      effective_end_date,
      business_group_id,
      legislation_code,
      formula_type_id,
      formula_name,
      description,
      formula_text,
      sticky_flag)
   VALUES
     (ff_formulas_s.nextval,
      to_date('01/01/0001','DD/MM/YYYY'),
      to_date('31/12/4712','DD/MM/YYYY'),
      NULL,
      NULL,
      l_ftype_id,
      'PTO_HD_ANNIVERSARY_PERIOD_ACCRUAL',
      'Seeded hire date anniversary looping formula for PTO accruals',
      l_text,
      NULL);
    --
    hr_utility.set_location ('hrstrdbi.insert_formula', 137);
    --
l_text := '
/* ------------------------------------------------------------------------
    NAME : PTO_HD_ANNIVERSARY_CARRYOVER
    This formula is the seeded carryover formula for our
    hire date anniversary accrual plan
   ---------------------------------------------------------------------*/

DEFAULT FOR ACP_SERVICE_START_DATE IS ''4712/12/31 00:00:00'' (date)

INPUTS ARE
Calculation_Date (date),
Accrual_term (text)

Effective_Date = add_months(ACP_SERVICE_START_DATE,
                            trunc(months_between(Calculation_Date,
                                                 ACP_SERVICE_START_DATE) / 12) * 12)

IF (Accrual_Term = ''CURRENT'') THEN
(
  Effective_date = ADD_YEARS(Effective_Date, 1)
)

Effective_Date = add_days(Effective_Date, -1)
Expiry_Date = add_years(effective_date, 1)
Max_carryover = 5
Process = ''YES''

RETURN Max_Carryover, Effective_date, Expiry_Date, Process

';
    --
    select formula_type_id
    into   l_ftype_id
    from   ff_formula_types
    where  formula_type_name = 'Accrual Carryover';
    --
     INSERT INTO ff_formulas_f
     (formula_id,
      effective_start_date,
      effective_end_date,
      business_group_id,
      legislation_code,
      formula_type_id,
      formula_name,
      description,
      formula_text,
      sticky_flag)
   VALUES
     (ff_formulas_s.nextval,
      to_date('01/01/0001','DD/MM/YYYY'),
      to_date('31/12/4712','DD/MM/YYYY'),
      NULL,
      NULL,
      l_ftype_id,
      'PTO_HD_ANNIVERSARY_CARRYOVER',
      'Seeded simple carryover formula for PTO accruals',
      l_text,
      NULL);
    --
    hr_utility.set_location ('hrstrdbi.insert_formula', 138);
    --
l_text := '
/* -------------------------------------------------------
    NAME : PTO_TAGGING_FORMULA
    This formula returns the element entry id of retrospective
    elements which require tagging during the payroll run.
   ---------------------------------------------------------*/

retro_element_entry_id = get_retro_element()

if retro_element_entry_id = -1 then
(
  RETURN
)
else
(
  RETURN retro_element_entry_id
)
';
    --
    select formula_type_id
    into   l_ftype_id
    from   ff_formula_types
    where  formula_type_name = 'Oracle Payroll';
    --
     INSERT INTO ff_formulas_f
     (formula_id,
      effective_start_date,
      effective_end_date,
      business_group_id,
      legislation_code,
      formula_type_id,
      formula_name,
      description,
      formula_text,
      sticky_flag)
   VALUES
     (ff_formulas_s.nextval,
      to_date('01/01/0001','DD/MM/YYYY'),
      to_date('31/12/4712','DD/MM/YYYY'),
      NULL,
      NULL,
      l_ftype_id,
      'PTO_TAGGING_FORMULA',
      'Seeded top level payroll formula for PTO accruals',
      l_text,
      NULL);
    --
    hr_utility.set_location ('hrstrdbi.insert_formula', 139);
    --
l_text := '
/* -------------------------------------------------------
    NAME : HR_CAGR_PYS_TEMPLATE
   ---------------------------------------------------------*/
DEFAULT FOR ASG_EMPLOYMENT_CATEGORY_CODE IS ''FR''
DEFAULT FOR PTU_PER_PERSON_TYPE IS              ''X''
DEFAULT FOR ASG_LABOUR_UNION_MEMBER_FLAG  IS  ''N''
DEFAULT FOR LOC_ADR_CITY                 IS   ''X''
DEFAULT FOR LOC_ADR_COUNTRY             IS    ''X''
DEFAULT FOR PER_AGE                      IS   0
DEFAULT FOR PER_DISABLED                 IS   ''N''
DEFAULT FOR PER_DISABLED                 IS   ''N''
DEFAULT FOR PER_MARITAL_STATUS           IS   ''U''
DEFAULT FOR PER_SEX                      IS   ''M''
VALUE               = to_text(0)
RANGE_FROM          = to_text(0)
RANGE_TO            = to_text(0)
PARENT_SPINE_ID     = ''0''
STEP_ID             = ''0''
FROM_STEP_ID        = ''0''
TO_STEP_ID          = ''0''
GRADE_SPINE_ID      = ''0''
If      (PTU_PER_PERSON_TYPE              LIKE ''Employee%''
        AND ASG_EMPLOYMENT_CATEGORY_CODE = ''FR''
        AND ASG_LABOUR_UNION_MEMBER_FLAG = ''Y''
        AND LOC_ADR_COUNTRY              <> ''FRG''
        AND PER_AGE                      < 35
        AND PER_DISABLED                 = ''N''          ) THEN
(
VALUE           = to_text(500)
RANGE_FROM      = to_text(500)
RANGE_TO        = to_text(500)
)
If      (PTU_PER_PERSON_TYPE              LIKE ''Employee%''
        AND ASG_EMPLOYMENT_CATEGORY_CODE = ''FR''
        AND ASG_LABOUR_UNION_MEMBER_FLAG = ''Y''
        AND LOC_ADR_COUNTRY              = ''FRG''
        AND PER_AGE                      > 45
        AND PER_AGE                      < 50           ) THEN
(
VALUE                     = to_text(to_number(VALUE)+100)
RANGE_FROM                = to_text(to_number(VALUE)+100)
RANGE_TO                  = to_text(to_number(VALUE)+200)
)
IF ( PER_DISABLED = ''N'')
THEN
(
VALUE = to_text(to_number(VALUE)+100)
RANGE_FROM = to_text(to_number(RANGE_FROM)+200)
RANGE_TO = to_text(to_number(RANGE_TO)+300)
)
IF ( ASG_EMPLOYMENT_CATEGORY_CODE = ''FR'' )
THEN
(
VALUE = to_text(to_number(VALUE)+999)
RANGE_FROM = to_text(to_number(RANGE_FROM)+444)
RANGE_TO = to_text(to_number(RANGE_TO)+333)
)
IF ( PER_AGE < 35 )
THEN
(
VALUE = to_text(to_number(VALUE)+999)
RANGE_FROM = to_text(to_number(RANGE_FROM)+444)
RANGE_TO = to_text(to_number(RANGE_TO)+333)
)
parent_spine_id = to_text(100)
return      PARENT_SPINE_ID
,           STEP_ID
,           FROM_STEP_ID
,           TO_STEP_ID
,           GRADE_SPINE_ID
';
    --
    select formula_type_id
    into   l_ftype_id
    from   ff_formula_types
    where  formula_type_name = 'CAGR';
    --
     INSERT INTO ff_formulas_f
     (formula_id,
      effective_start_date,
      effective_end_date,
      business_group_id,
      legislation_code,
      formula_type_id,
      formula_name,
      description,
      formula_text,
      sticky_flag)
   VALUES
     (ff_formulas_s.nextval,
      to_date('01-01-1951','DD-MM-YYYY'),
      to_date('31-12-4712','DD-MM-YYYY'),
      NULL,
      NULL,
      l_ftype_id,
      'HR_CAGR_PYS_TEMPLATE',
      'HR_CAGR_PYS_TEMPLATE',
      l_text,
      NULL);
    --
    hr_utility.set_location ('hrstrdbi.insert_formula', 140);
    --
l_text := '
/* -------------------------------------------------------
    NAME : HR_CAGR_TEMPLATE
   ---------------------------------------------------------*/
DEFAULT FOR ASG_EMPLOYMENT_CATEGORY_CODE IS ''FR''
DEFAULT FOR PTU_PER_PERSON_TYPE IS              ''X''
DEFAULT FOR ASG_LABOUR_UNION_MEMBER_FLAG  IS  ''N''
DEFAULT FOR LOC_ADR_CITY                 IS   ''X''
DEFAULT FOR LOC_ADR_COUNTRY             IS    ''X''
DEFAULT FOR PER_AGE                      IS   0
DEFAULT FOR PER_DISABLED                 IS   ''N''
DEFAULT FOR PER_DISABLED                 IS   ''N''
DEFAULT FOR PER_MARITAL_STATUS           IS   ''U''
DEFAULT FOR PER_SEX                      IS   ''M''
VALUE               = to_text(0)
RANGE_FROM          = to_text(0)
RANGE_TO            = to_text(0)
PARENT_SPINE_ID     = ''0''
STEP_ID             = ''0''
FROM_STEP_ID        = ''0''
TO_STEP_ID          = ''0''
GRADE_SPINE_ID      = ''0''
If      (PTU_PER_PERSON_TYPE              LIKE ''Employee%''
        AND ASG_EMPLOYMENT_CATEGORY_CODE = ''FR''
        AND ASG_LABOUR_UNION_MEMBER_FLAG = ''Y''
        AND LOC_ADR_COUNTRY              <> ''FRG''
        AND PER_AGE                      < 35
        AND PER_DISABLED                 = ''N''          ) THEN
(
VALUE           = to_text(500)
RANGE_FROM      = to_text(500)
RANGE_TO        = to_text(500)
)
If      (PTU_PER_PERSON_TYPE              LIKE ''Employee%''
        AND ASG_EMPLOYMENT_CATEGORY_CODE = ''FR''
        AND ASG_LABOUR_UNION_MEMBER_FLAG = ''Y''
        AND LOC_ADR_COUNTRY              = ''FRG''
        AND PER_AGE                      > 45
        AND PER_AGE                      < 50           ) THEN
(
VALUE                     = to_text(to_number(VALUE)+100)
RANGE_FROM                = to_text(to_number(VALUE)+100)
RANGE_TO                  = to_text(to_number(VALUE)+200)
)
IF ( PER_DISABLED = ''N'')
THEN
(
VALUE = to_text(to_number(VALUE)+100)
RANGE_FROM = to_text(to_number(RANGE_FROM)+200)
RANGE_TO = to_text(to_number(RANGE_TO)+300)
)
IF ( ASG_EMPLOYMENT_CATEGORY_CODE = ''FR'' )
THEN
(
VALUE = to_text(to_number(VALUE)+999)
RANGE_FROM = to_text(to_number(RANGE_FROM)+444)
RANGE_TO = to_text(to_number(RANGE_TO)+333)
)
IF ( PER_AGE < 35 )
THEN
(
VALUE = to_text(to_number(VALUE)+999)
RANGE_FROM = to_text(to_number(RANGE_FROM)+444)
RANGE_TO = to_text(to_number(RANGE_TO)+333)
)
return      VALUE
,           RANGE_FROM
/* ,           RANGE_TO
,           PARENT_SPINE_ID
,           GRADE_SPINE_ID
,           FROM_STEP_ID
,           TO_STEP_ID  */
';
    --
    select formula_type_id
    into   l_ftype_id
    from   ff_formula_types
    where  formula_type_name = 'CAGR';
    --
     INSERT INTO ff_formulas_f
     (formula_id,
      effective_start_date,
      effective_end_date,
      business_group_id,
      legislation_code,
      formula_type_id,
      formula_name,
      description,
      formula_text,
      sticky_flag)
   VALUES
     (ff_formulas_s.nextval,
      to_date('01-01-1951','DD-MM-YYYY'),
      to_date('31-12-4712','DD-MM-YYYY'),
      NULL,
      NULL,
      l_ftype_id,
      'HR_CAGR_TEMPLATE',
      'HR_CAGR_TEMPLATE',
      l_text,
      NULL);
    --
    hr_utility.set_location ('hrstrdbi.insert_formula', 141);
    --
l_text := '
/****************************************************************
FORMULA NAME: PROMOTION_TEMPLATE
FORMULA TYPE: Promotion
DESCRIPTION:  This formula determines whether or not an employee
              has received a promotion as of the date earned
              being passed into the formula.
              When called from the promotions package, this
              formula will be used to calculate the number of
              promotions which have occurred over a specified
              period.
              To use this functionality please copy the code
              into a new formula named PROMOTION with a type of
              Promotion and uncomment the code.
              Then, to use the default functionality, set
              up an assignment change reason with a meaning of
              Promotion in the lookup table EMP_ASSIGN_REASON
              This formula can also be customized, by either
              using different change reasons, additional change
              reasons, or by using different criteria with
              which to define promotion.
              For instance, additional change reasons of
              HQ Move and Position Change could be added in the
              same way as Promotion so that the formula will
              record a promotion when there is a change reason
              of Promotion, HQ Move or Position Change.
              Also grade changes could be used as promotion
              criteria, for instance, instead of the change
              reason.  This would require a different database
              item such as ASG_GRADE or ASG_GRADE_DATE_FROM.
              The formula could return a count of 1 where
              ASG_GRADE_DATE_FROM = DATE_EARNED, thus recording
              grade changes as promotions.
INPUTS:
RETURNS:      A count which will return a 1 if a promotion has
              occurred,according to rules described above and a
              0 if one has not.
DBI Required: none are required, but the default formula uses
              asg_change_reason :  the assignment change reason
*****************************************************************/
default for ASG_CHANGE_REASON  is ''Record Reason''
l_count = 0
/**************************************************************
Example code - this will count all occurrences where Assignment
Change Reason is Promotion
**************************************************************/
/****
==
uncomment code below for default functionality, or customize
==
****/
/*
if ASG_CHANGE_REASON = ''Promotion'' then
(
  l_count = 1
)
else
(
  l_count = 0
)
*/
return l_count';

   select formula_type_id
   into l_ftype_id
   from ff_formula_types
   where formula_type_name = 'Promotion';
    --
    INSERT INTO ff_formulas_f
     (formula_id,
      effective_start_date,
      effective_end_date,
      business_group_id,
      legislation_code,
      formula_type_id,
      formula_name,
      description,
      formula_text,
      sticky_flag)
   VALUES
     (ff_formulas_s.nextval,
      to_date('01/01/0001','DD/MM/YYYY'),
      to_date('31/12/4712','DD/MM/YYYY'),
      NULL,
      NULL,
      l_ftype_id,
      'PROMOTION_TEMPLATE',
      'Seeded Promotions Formula',
      l_text,
      NULL);
    --
    hr_utility.set_location ('hrstrdbi.insert_formula', 142);
    --
--
end insert_formula;
--
procedure insert_user_tables is
--
  l_formula_id number;
begin
    hr_utility.set_location ('hrstrdbi.insert_user_tables', 1);
    --
   BEGIN
     select formula_id into l_formula_id
      FROM ff_formulas_f
      WHERE formula_name = 'CHECK_RATE_TYPE'
      AND EFFECTIVE_START_DATE = to_date('01-01-0001', 'DD-MM-YYYY')
      AND EFFECTIVE_END_DATE = to_date('31-12-4712', 'DD-MM-YYYY');
   EXCEPTION
      WHEN OTHERS then
         l_formula_id := null;
   END;
--
   insert into pay_user_tables (
                              USER_TABLE_ID
                            , BUSINESS_GROUP_ID
                            , LEGISLATION_CODE
                            , RANGE_OR_MATCH
                            , USER_KEY_UNITS
                            , USER_TABLE_NAME
                            , LEGISLATION_SUBGROUP
                            , USER_ROW_TITLE
                            , LAST_UPDATE_DATE
                            , LAST_UPDATED_BY
                            , LAST_UPDATE_LOGIN
                            , CREATED_BY
                            , CREATION_DATE
                            )
              select          pay_user_tables_s.nextval
                            , NULL
		            , NULL
                            , 'M'
                            , 'T'
                            , 'EXCHANGE_RATE_TYPES'
                            , NULL
                            , 'Processing Type'
                            , trunc(sysdate)
                            , NULL
                            , NULL
                            , NULL
                            , trunc(sysdate)
                from         sys.dual;
   --
   insert into pay_user_columns (
 		USER_COLUMN_ID
		,BUSINESS_GROUP_ID
		,LEGISLATION_CODE
		,USER_TABLE_ID
		,FORMULA_ID
		,USER_COLUMN_NAME
		,LEGISLATION_SUBGROUP
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN
		,CREATED_BY
		,CREATION_DATE )
	 select pay_user_columns_s.nextval
		,''
		,NULL
		,udt.user_table_id
		,l_formula_id
		,'Conversion Rate Type'
		,''
		,sysdate
		,1
		,1
		,1
		,sysdate
	 from pay_user_tables udt
         where udt.user_table_name = 'EXCHANGE_RATE_TYPES';
  --
  insert into pay_user_rows (
 		USER_ROW_ID
 	        ,EFFECTIVE_START_DATE
	        ,EFFECTIVE_END_DATE
		,BUSINESS_GROUP_ID
		,LEGISLATION_CODE
		,USER_TABLE_ID
		,ROW_LOW_RANGE_OR_NAME
		,LEGISLATION_SUBGROUP
		,ROW_HIGH_RANGE
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN
		,CREATED_BY
		,CREATION_DATE )
         select pay_user_rows_s.nextval
   	        , to_date('01-01-0001', 'DD-MM-YYYY')
		, to_date('31-12-4712', 'DD-MM-YYYY')
		,NULL
		,NULL
		,udt.user_table_id
		,'BIS'
		,''
		,''
	        ,''
		,1
		,1
		,1
		,sysdate
	from pay_user_tables udt
        where udt.user_table_name = 'EXCHANGE_RATE_TYPES';
  --
  insert into pay_user_rows (
 		USER_ROW_ID
 	        ,EFFECTIVE_START_DATE
	        ,EFFECTIVE_END_DATE
		,BUSINESS_GROUP_ID
		,LEGISLATION_CODE
		,USER_TABLE_ID
		,ROW_LOW_RANGE_OR_NAME
		,LEGISLATION_SUBGROUP
		,ROW_HIGH_RANGE
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN
		,CREATED_BY
		,CREATION_DATE )
	 select pay_user_rows_s.nextval
   	        , to_date('01-01-0001', 'DD-MM-YYYY')
		, to_date('31-12-4712', 'DD-MM-YYYY')
		,NULL
		,NULL
		,udt.user_table_id
		,'HRMS'
		,''
		,''
	        ,''
		,1
		,1
		,1
		,sysdate
	 from pay_user_tables udt
	 where udt.user_table_name = 'EXCHANGE_RATE_TYPES';
  --
  insert into pay_user_rows (
 		USER_ROW_ID
 	        ,EFFECTIVE_START_DATE
	        ,EFFECTIVE_END_DATE
		,BUSINESS_GROUP_ID
		,LEGISLATION_CODE
		,USER_TABLE_ID
		,ROW_LOW_RANGE_OR_NAME
		,LEGISLATION_SUBGROUP
		,ROW_HIGH_RANGE
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN
		,CREATED_BY
		,CREATION_DATE )
	 select pay_user_rows_s.nextval
   	        , to_date('01-01-0001', 'DD-MM-YYYY')
		, to_date('31-12-4712', 'DD-MM-YYYY')
		,NULL
		,NULL
		,udt.user_table_id
		,'PAY'
		,''
		,''
	        ,''
		,1
		,1
		,1
		,sysdate
	 from pay_user_tables udt
	 where udt.user_table_name = 'EXCHANGE_RATE_TYPES';
    --
    hr_utility.set_location ('hrstrdbi.insert_user_tables', 2);
--
end insert_user_tables;
--
procedure insert_monetary_units is
 TYPE eur_info_type is RECORD (name VARCHAR2(150), value NUMBER);
 TYPE eur_info_tab IS TABLE OF eur_info_type INDEX BY BINARY_INTEGER;
 eur_info eur_info_tab;
begin
  eur_info(1).name := 'Five Hundred Euros'; eur_info(1).value := 500;
  eur_info(2).name := 'Two Hundred Euros'; eur_info(2).value := 200;
  eur_info(3).name := 'One Hundred Euros'; eur_info(3).value := 100;
  eur_info(4).name := 'Fifty Euros'; eur_info(4).value := 50;
  eur_info(5).name := 'Twenty Euros'; eur_info(5).value := 20;
  eur_info(6).name := 'Ten Euros'; eur_info(6).value := 10;
  eur_info(7).name := 'Five Euros'; eur_info(7).value := 5;
  eur_info(8).name := 'Two Euros'; eur_info(8).value := 2;
  eur_info(9).name := 'One Euro'; eur_info(9).value := 1;
  eur_info(10).name := 'Fifty Cents'; eur_info(10).value := 0.5;
  eur_info(11).name := 'Twenty Cents'; eur_info(11).value := 0.2;
  eur_info(12).name := 'Ten Cents'; eur_info(12).value := 0.1;
  eur_info(13).name := 'Five Cents'; eur_info(13).value := 0.05;
  eur_info(14).name := 'Two Cents'; eur_info(14).value := 0.02;
  eur_info(15).name := 'One Cent'; eur_info(15).value := 0.01;

  FOR i in 1..15 LOOP

    insert into pay_monetary_units
    (MONETARY_UNIT_ID,
     CURRENCY_CODE,
     MONETARY_UNIT_NAME,
     RELATIVE_VALUE,
     COMMENTS,
     CREATION_DATE)
     values
     (pay_monetary_units_s.nextval,
      'EUR',
      eur_info(i).name,
      eur_info(i).value,
      NULL,
      sysdate);

  END LOOP;

end insert_monetary_units;
--
procedure create_dbi_startup is
begin
    insert_context;
    insert_routes_db_items;
    insert_functions;
    insert_formula;
    insert_user_tables;
    insert_monetary_units;
end create_dbi_startup;
end hrstrdbi;

/
