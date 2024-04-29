--------------------------------------------------------
--  DDL for Package Body PAY_DBI_STARTUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_DBI_STARTUP_PKG" as
/* $Header: pystrdbi.pkb 115.4 99/07/17 06:35:33 porting ship  $ */
/*
--
-- Copyright (c) Oracle Corporation 1991, 1992, 1993. All rights reserved.
--
/*
   NAME
      pystrdbi.pkb
--
   DESCRIPTION
      Procedures used for creating the start up data for database items,
      namely the routes and the appropriate contexts.  The procedure
      create_dbi_startup is called from the main start up file.
--
  MODIFIED (DD-MON-YYYY)
     alogue     16-MAR-1999 - Removed GET_HOURS_WORKED.
     alogue     11-JAN-1999 - Added GET_HOURS_WORKED to ff_functions.
                              R11.5 change whereby date contexts are passed
                              into routes as dates (and thus don't require
                              a to_date() on them).
     alogue     20-MAY-1998 - Fix to ABSENCE_SUM_OF_ELEMENT_ENTRY_VALUES route
                              text.
     alogue     31-OCT-1997 - change to GRADE_RATE_ROUTE route text.
     alogue     24-OCT-1997 - change to RETROADJ_RUN_BAL_ROUTE route text.
     alogue     05-AUG-1997 - Tidy Up: EVENTS_DESC_FLEX_ROUTE and
                              EMPLOYEE_ADDRESSES_DESC_FLEX_ROUTE
                              to use end of time as DD/MM/YY.
     alogue     07-APR-1997 - Tidy Up: inclusion of bug 418051 route
                              ABSENCE_SUM_OF_ELEMENT_ENTRY_VALUES fix.
     mwcallag   06-JAN-1995 - Performance changes resulting from the DEC
                              Benchmark.  These include:
                              --
                              Route : ELEMENT_TYPE_COUNT_OF_ELEMENT_ENTRIES
                              modified by disabling the index on
			      EE.entry_type.
                              --
                              The following routes used to use the synonym
                              fnd_lookups.  Originally this was a simple
                              table, but now is a complex view, and hence
                              these routes now refer to the view hr_lookups,
                              and also use the application id column (= 800)
                              for improved performance:
                              ELEMENT_TYPE_AT_TYPE_LEVEL
                              ELEMENT_TYPE_AT_TYPE_LEVEL_DP
                              ELEMENT_TYPE_AT_ASSIGNMENT_LEVEL
                              ELEMENT_TYPE_AT_ASSIGNMENT_LEVEL_DP
                              --
                              The following routes use the view hr_lookups.
                              They have been modified to also use the
                              application id column (= 800) for improved
                              performance:
                              INPUT_VALUE_FROM_INPUT_VALUE_TABLE
                              INPUT_VALUE_FROM_INPUT_VALUE_TABLE_DP
                              --
     mwcallag   13-OCT-1994 - Route PAYROLL_ACTION_FLEXFIELD_ROUTE deleted.
     rfine      05-OCT-1994 - Renamed package to pay_dbi_startup_pkg.
     mwcallag   29-APR-1994   Route INPUT_VALUE_ENTRY_LEVEL tuned.
     mwcallag   07-DEC-1993 - G291 Change to Legal Company route, now uses the
                              passed in context parameter.
     mwcallag   01-DEC-1993 - inserts for User Defined Tables added.
     mwcallag   03-NOV-1993 - Assignment Developer Descriptive flex addded.
     mwcallag   02-NOV-1993 - Join to benefit_classifications added to
                              element_type_at_type_level route.
     mwcallag   01-SEP-1993 - Date paid routes added for element types and
                              input values.
     mwcallag   12-AUG-1993 - Minor change to Legal Company route.
     mwcallag   11-AUG-1993 - Organization Payment Methods DF, External Account
                              Keyflex, and Legal company DF routes added.
     mwcallag   09-AUG-1993 - More routes for Descriptive flexfields added.
     mwcallag   03-AUG-1993 - Organization Developer DF and SCL routes added.
     mwcallag   21-JUN-1993 - date earned removed from absence type route.
     mwcallag   24-MAY-1993 - grade rate route shortened following removal of
                              rate_type database item.
     mwcallag   07-MAY-1993 - spine and key flex routes added.
     mwcallag   30-APR-1993 - absence and descriptive flex routes added.
     mwcallag   27-APR-1993 - created.
*/
--
PROCEDURE create_dbi_startup is
l_text                       long;
l_date_earned_context_id     number;
l_assign_id_context_id       number;
l_payroll_context_id         number;
l_payroll_action_context_id  number;
l_org_pay_method_id          number;
l_per_pay_method_id          number;
l_tax_unit_id                number;
l_assignment_action_id       number;
l_business_group_id          number;
l_function_id                number;
l_temp                       number;
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
    hr_utility.set_location('pay_dbi_startup_pkg.insert_route_parameters', 1);
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
-- ******** local procedure : insert_route_context_usages  ********
--
procedure insert_route_context_usages
(
    p_context_id    in  number,
    p_sequence_no   in  number
) is
begin
    hr_utility.set_location('pay_dbi_startup_pkg.insert_route_context_usages', 1);
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
BEGIN
    --
    -- get the context ids from the context table
    --
    hr_utility.set_location('pay_dbi_startup_pkg.create_dbi_startup', 1);
    select context_id
    into   l_date_earned_context_id
    from   ff_contexts
    where  context_name = 'DATE_EARNED';
    --
    hr_utility.set_location('pay_dbi_startup_pkg.create_dbi_startup', 2);
    select context_id
    into   l_assign_id_context_id
    from   ff_contexts
    where  context_name = 'ASSIGNMENT_ID';
    --
    hr_utility.set_location('pay_dbi_startup_pkg.create_dbi_startup', 3);
    select context_id
    into   l_payroll_context_id
    from   ff_contexts
    where  context_name = 'PAYROLL_ID';
    --
    hr_utility.set_location('pay_dbi_startup_pkg.create_dbi_startup', 4);
    select context_id
    into   l_payroll_action_context_id
    from   ff_contexts
    where  context_name = 'PAYROLL_ACTION_ID';
    --
    hr_utility.set_location('pay_dbi_startup_pkg.create_dbi_startup', 5);
    select context_id
    into   l_org_pay_method_id
    from   ff_contexts
    where  context_name = 'ORG_PAY_METHOD_ID';
    --
    hr_utility.set_location('pay_dbi_startup_pkg.create_dbi_startup', 6);
    select context_id
    into   l_per_pay_method_id
    from   ff_contexts
    where  context_name = 'PER_PAY_METHOD_ID';
    --
    hr_utility.set_location('pay_dbi_startup_pkg.create_dbi_startup', 7);
    select context_id
    into   l_tax_unit_id
    from   ff_contexts
    where  context_name = 'TAX_UNIT_ID';
    --
    hr_utility.set_location('pay_dbi_startup_pkg.create_dbi_startup', 8);
    select context_id
    into   l_assignment_action_id
    from   ff_contexts
    where  context_name = 'ASSIGNMENT_ACTION_ID';
    --
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                       +
    -- element type route, name : ELEMENT_TYPE_AT_TYPE_LEVEL +
    --                                                       +
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text :=  'pay_element_types_f                    ETYPE,
pay_element_classifications            ECLASS,
ben_benefit_classifications            BCLASS,
hr_lookups                             CELOOK
WHERE  ETYPE.element_type_id = &U1
AND    &B1 BETWEEN ETYPE.effective_start_date
                AND ETYPE.effective_end_date
AND    ETYPE.classification_id               = ECLASS.classification_id
AND    BCLASS.benefit_classification_id   (+)= ETYPE.benefit_classification_id
AND    ETYPE.closed_for_entry_flag           = CELOOK.lookup_code
AND    CELOOK.application_id                 = 800
AND    CELOOK.lookup_type                    = ''YES_NO''';
    --
    hr_utility.set_location('pay_dbi_startup_pkg.create_dbi_startup', 8);
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
    select  ff_routes_s.nextval,
            'ELEMENT_TYPE_AT_TYPE_LEVEL',
            'N',
            'simple element type route',
            l_text,
            sysdate,
            0,
            0,
            0,
            sysdate
    from    dual;
    --
    insert_route_parameters ('Element Type ID', 'N', 1);
    insert_route_context_usages (l_date_earned_context_id, 1);
    --
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                                  +
    -- Date paid element type route : ELEMENT_TYPE_AT_TYPE_LEVEL_DP     +
    --                                                                  +
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := '/* route for date paid element type at type level */
       pay_element_types_f                  ETYPE,
       pay_element_classifications          ECLASS,
       ben_benefit_classifications          BCLASS,
       hr_lookups                           CELOOK,
       fnd_sessions                         SES
WHERE  ETYPE.element_type_id              = &U1
AND    SES.session_id                     = USERENV(''SESSIONID'')
AND    SES.effective_date           BETWEEN ETYPE.effective_start_date
                                        AND ETYPE.effective_end_date
AND    ETYPE.classification_id            = ECLASS.classification_id
AND    BCLASS.benefit_classification_id(+)= ETYPE.benefit_classification_id
AND    ETYPE.closed_for_entry_flag        = CELOOK.lookup_code
AND    CELOOK.application_id              = 800
AND    CELOOK.lookup_type                 = ''YES_NO''';
    --
    hr_utility.set_location('pay_dbi_startup_pkg.create_dbi_startup', 9);
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
    select  ff_routes_s.nextval,
            'ELEMENT_TYPE_AT_TYPE_LEVEL_DP',
            'N',
            'route for date paid element type at type level',
            l_text,
            sysdate,
            0,
            0,
            0,
            sysdate
    from    dual;
    --
    insert_route_parameters ('Element Type ID', 'N', 1);
    --
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                             +
    -- element type route, name : ELEMENT_TYPE_AT_ASSIGNMENT_LEVEL +
    --                                                             +
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := 'pay_element_links_f ELINK,
 pay_element_types_f ETYPE,
 per_assignments_f  PERA,
 hr_lookups QULOOK_LINK,
 hr_lookups QULOOK_TYPE,
 hr_lookups CTLOOK,
 hr_lookups SLLOOK_LINK,
 hr_lookups SLLOOK_TYPE
WHERE  ETYPE.element_type_id = &U1
AND    &B1 BETWEEN ETYPE.effective_start_date
                AND ETYPE.effective_end_date
AND    ETYPE.element_type_id (+)= ELINK.element_type_id
AND    &B1 BETWEEN ELINK.effective_start_date
                AND ELINK.effective_end_date
AND    PERA.assignment_id  = &B2
AND    &B1 BETWEEN PERA.effective_start_date
                AND PERA.effective_end_date
AND    ((ELINK.payroll_id IS NOT NULL
AND      ELINK.payroll_id = PERA.payroll_id)
OR      (ELINK.link_to_all_payrolls_flag = ''Y''
AND      PERA.payroll_id IS NOT NULL)
OR     ELINK.payroll_id  IS NULL)
AND   (ELINK.organization_id = PERA.organization_id
OR     ELINK.organization_id IS NULL)
AND   (ELINK.position_id  = PERA.position_id
OR     ELINK.position_id IS NULL)
AND   (ELINK.job_id = PERA.job_id
OR     ELINK.job_id IS NULL)
AND   (ELINK.grade_id = PERA.grade_id
OR     ELINK.grade_id IS NULL)
AND   (ELINK.location_id = PERA.location_id
OR     ELINK.location_id IS NULL)
AND    (ELINK.people_group_id IS NULL
OR     EXISTS
(SELECT 1
 FROM   pay_assignment_link_usages_f PAL
 WHERE  PAL.assignment_id  = &B2
 AND    PAL.element_link_id = ELINK.element_link_id
 AND    &B1 BETWEEN PAL.effective_start_date
                 AND PAL.effective_end_date))
AND   QULOOK_LINK.lookup_code     (+)= ELINK.qualifying_units
AND   QULOOK_LINK.lookup_type     (+)= ''QUALIFYING_UNITS''
AND   QULOOK_LINK.application_id  (+)= 800
AND   QULOOK_TYPE.lookup_code     (+)= ETYPE.qualifying_units
AND   QULOOK_TYPE.lookup_type     (+)= ''QUALIFYING_UNITS''
AND   QULOOK_TYPE.application_id  (+)= 800
AND   SLLOOK_LINK.lookup_code     (+)= ELINK.standard_link_flag
AND   SLLOOK_LINK.lookup_type     (+)= ''YES_NO''
AND   SLLOOK_LINK.application_id  (+)= 800
AND   SLLOOK_TYPE.lookup_code     (+)= ETYPE.standard_link_flag
AND   SLLOOK_TYPE.lookup_type     (+)= ''YES_NO''
AND   SLLOOK_TYPE.application_id  (+)= 800
AND   ELINK.costable_type            = CTLOOK.lookup_code
AND   CTLOOK.application_id          = 800
AND   CTLOOK.lookup_type             = ''COSTABLE_TYPE''';
    --
    -- the above route text is so long that we hit a current PL/SQL bug of
    -- inserting with a select when using a long data type. So select the next
    -- value for the route_id separately, until this bug is fixed:
    --
    hr_utility.set_location('pay_dbi_startup_pkg.create_dbi_startup', 10);
    select ff_routes_s.nextval
    into   l_temp
    from   dual;
    --
    -- now do the normal insert
    --
    hr_utility.set_location('pay_dbi_startup_pkg.create_dbi_startup', 11);
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
    values (ff_routes_s.currval,
           'ELEMENT_TYPE_AT_ASSIGNMENT_LEVEL',
           'N',
    'element type information with partial matching to the element link table',
           l_text,
            sysdate,
            0,
            0,
            0,
            sysdate);
    --
    insert_route_parameters ('Element Type ID', 'N', 1);
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id,   2);
    --
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                               +
    -- Date paid element type : ELEMENT_TYPE_AT_ASSIGNMENT_LEVEL_DP  +
    --                                                               +
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := '/* route for date paid element type at assignment level */
       pay_element_links_f                    ELINK,
       pay_element_types_f                    ETYPE,
       per_assignments_f                      PERA,
       hr_lookups                             QULOOK_LINK,
       hr_lookups                             QULOOK_TYPE,
       hr_lookups                             CTLOOK,
       hr_lookups                             SLLOOK_LINK,
       hr_lookups                             SLLOOK_TYPE,
       fnd_sessions                           SES
WHERE  ETYPE.element_type_id                = &U1
AND    SES.session_id                       = USERENV(''SESSIONID'')
AND    SES.effective_date             BETWEEN ETYPE.effective_start_date
                                          AND ETYPE.effective_end_date
AND    ETYPE.element_type_id             (+)= ELINK.element_type_id
AND    SES.effective_date             BETWEEN ELINK.effective_start_date
                                          AND ELINK.effective_end_date
AND    PERA.assignment_id                   = &B1
AND    SES.effective_date             BETWEEN PERA.effective_start_date
                                          AND PERA.effective_end_date
AND    ((ELINK.payroll_id                  IS NOT NULL
AND      ELINK.payroll_id                   = PERA.payroll_id)
OR      (ELINK.link_to_all_payrolls_flag    = ''Y''
AND      PERA.payroll_id                   IS NOT NULL)
OR     ELINK.payroll_id                    IS NULL)
AND   (ELINK.organization_id                = PERA.organization_id
OR     ELINK.organization_id               IS NULL)
AND   (ELINK.position_id                    = PERA.position_id
OR     ELINK.position_id                   IS NULL)
AND   (ELINK.job_id                         = PERA.job_id
OR     ELINK.job_id                        IS NULL)
AND   (ELINK.grade_id                       = PERA.grade_id
OR     ELINK.grade_id                      IS NULL)
AND   (ELINK.location_id                    = PERA.location_id
OR     ELINK.location_id                   IS NULL)
AND    (ELINK.people_group_id              IS NULL
OR     EXISTS
       (SELECT 1
        FROM   pay_assignment_link_usages_f          PAL
	WHERE  PAL.assignment_id                   = &B1
        AND    PAL.element_link_id                 = ELINK.element_link_id
        AND    SES.effective_date            BETWEEN PAL.effective_start_date
                                                 AND PAL.effective_end_date))
AND   QULOOK_LINK.lookup_code     (+)= ELINK.qualifying_units
AND   QULOOK_LINK.lookup_type     (+)= ''QUALIFYING_UNITS''
AND   QULOOK_LINK.application_id  (+)= 800
AND   QULOOK_TYPE.lookup_code     (+)= ETYPE.qualifying_units
AND   QULOOK_TYPE.lookup_type     (+)= ''QUALIFYING_UNITS''
AND   QULOOK_TYPE.application_id  (+)= 800
AND   SLLOOK_LINK.lookup_code     (+)= ELINK.standard_link_flag
AND   SLLOOK_LINK.lookup_type     (+)= ''YES_NO''
AND   SLLOOK_LINK.application_id  (+)= 800
AND   SLLOOK_TYPE.lookup_code     (+)= ETYPE.standard_link_flag
AND   SLLOOK_TYPE.lookup_type     (+)= ''YES_NO''
AND   SLLOOK_TYPE.application_id  (+)= 800
AND   ELINK.costable_type            = CTLOOK.lookup_code
AND   CTLOOK.application_id          = 800
AND   CTLOOK.lookup_type             = ''COSTABLE_TYPE''';
    --
    -- the above route text is so long that we hit a current PL/SQL bug of
    -- inserting with a select when using a long data type. So select the next
    -- value for the route_id separately, until this bug is fixed:
    --
    hr_utility.set_location('pay_dbi_startup_pkg.create_dbi_startup', 12);
    select ff_routes_s.nextval
    into   l_temp
    from   dual;
    --
    -- now do the normal insert
    --
    hr_utility.set_location('pay_dbi_startup_pkg.create_dbi_startup', 13);
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
    values (ff_routes_s.currval,
           'ELEMENT_TYPE_AT_ASSIGNMENT_LEVEL_DP',
           'N',
 'Date paid element type info with partial matching to the element link table',
           l_text,
            sysdate,
            0,
            0,
            0,
            sysdate);
    --
    insert_route_parameters ('Element Type ID', 'N', 1);
    insert_route_context_usages (l_assign_id_context_id,   1);
    --
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                                  +
    -- element type route, name : ELEMENT_TYPE_COUNT_OF_ELEMENT_ENTRIES +
    --                                                                  +
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    -- note : The upper on the EE.entry_type is to force the route to use
    -- the more selective n4 index (1:element_link_id, 2:assignment_id)
    -- rather than the n50 index (1:assignment_id, 2:entry_type, 3:start_date,
    -- 4:end_date).
    --
    l_text := 'pay_element_entries_f       EE,
       pay_element_links_f                     ELINK,
       pay_element_types_f                     ETYPE
WHERE  &B1 BETWEEN EE.effective_start_date
                AND EE.effective_end_date
AND    upper (EE.entry_type)                 = ''E''
AND    EE.element_link_id                    = ELINK.element_link_id
AND    &B1 BETWEEN ELINK.effective_start_date
                AND ELINK.effective_end_date
AND    ELINK.element_type_id                 = ETYPE.element_type_id
AND    &B1 BETWEEN ETYPE.effective_start_date
                AND ETYPE.effective_end_date
AND    ETYPE.element_type_id                 = &U1
AND    EE.assignment_id                      = &B2';
    --
    hr_utility.set_location('pay_dbi_startup_pkg.create_dbi_startup', 14);
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
    select  ff_routes_s.nextval,
            'ELEMENT_TYPE_COUNT_OF_ELEMENT_ENTRIES',
            'N',
          'route to element entry table for given assignment and element type',
            l_text,
            sysdate,
            0,
            0,
            0,
            sysdate
    from    dual;
    --
    insert_route_parameters ('Element Type ID', 'N', 1);
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id,   2);
    --
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                                     +
    -- Date paid, element type : ELEMENT_TYPE_COUNT_OF_ELEMENT_ENTRIES_DP  +
    --                                                                     +
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := '/* route for date paid element type count of entries */
       pay_element_entries_f                  EE,
       pay_element_links_f                    ELINK,
       pay_element_types_f                    ETYPE,
       fnd_sessions                           SES
WHERE  EE.assignment_id                     = &B1
and    SES.session_id                       = USERENV(''SESSIONID'')
AND    SES.effective_date             BETWEEN EE.effective_start_date
                                          AND EE.effective_end_date
AND    EE.entry_type                        = ''E''
AND    EE.element_link_id                   = ELINK.element_link_id
AND    SES.effective_date             BETWEEN ELINK.effective_start_date
                                          AND ELINK.effective_end_date
AND    ELINK.element_type_id                = ETYPE.element_type_id
AND    SES.effective_date             BETWEEN ETYPE.effective_start_date
                                          AND ETYPE.effective_end_date
AND    ETYPE.element_type_id                = &U1';
    --
    hr_utility.set_location('pay_dbi_startup_pkg.create_dbi_startup', 15);
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
    select  ff_routes_s.nextval,
            'ELEMENT_TYPE_COUNT_OF_ELEMENT_ENTRIES_DP',
            'N',
 'route for DP, element entry table for given assignment and element type',
            l_text,
            sysdate,
            0,
            0,
            0,
            sysdate
    from    dual;
    --
    insert_route_parameters ('Element Type ID', 'N', 1);
    insert_route_context_usages (l_assign_id_context_id,   1);
    --
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                             +
    -- input value route, name: INPUT_VALUE_FROM_INPUT_VALUE_TABLE +
    --                                                             +
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := 'pay_input_values_f              INPUTV,
       hr_lookups                              UMLOOK
WHERE  INPUTV.input_value_id                 = &U1
AND    &B1 BETWEEN INPUTV.effective_start_date
                AND INPUTV.effective_end_date
AND    INPUTV.uom                           = UMLOOK.lookup_code
AND    UMLOOK.application_id                = 800
AND    UMLOOK.lookup_type                   = ''UNITS''';
    --
    hr_utility.set_location('pay_dbi_startup_pkg.create_dbi_startup', 16);
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
    select  ff_routes_s.nextval,
            'INPUT_VALUE_FROM_INPUT_VALUE_TABLE',
            'N',
            'route to input value table',
            l_text,
            sysdate,
            0,
            0,
            0,
            sysdate
    from    dual;
    --
    insert_route_parameters ('Input value ID', 'N', 1);
    insert_route_context_usages (l_date_earned_context_id, 1);
    --
    --+++++++++++++++++++********+++++++++++++++++++++++++++++++++++++++++++
    --                                                                     +
    -- Date paid input value route : INPUT_VALUE_FROM_INPUT_VALUE_TABLE_DP +
    --                                                                     +
    --+++++++++++++++++++********+++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := '/* route for date paid input value */
       pay_input_values_f              INPUTV,
       hr_lookups                      UMLOOK,
       fnd_sessions                    SES
WHERE  INPUTV.input_value_id         = &U1
AND    SES.session_id                = USERENV(''SESSIONID'')
AND    SES.effective_date      BETWEEN INPUTV.effective_start_date
                                   AND INPUTV.effective_end_date
AND    INPUTV.uom                    = UMLOOK.lookup_code
AND    UMLOOK.application_id         = 800
AND    UMLOOK.lookup_type            = ''UNITS''';
    --
    hr_utility.set_location('pay_dbi_startup_pkg.create_dbi_startup', 17);
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
    select  ff_routes_s.nextval,
            'INPUT_VALUE_FROM_INPUT_VALUE_TABLE_DP',
            'N',
            'Date paid route to input value table',
            l_text,
            sysdate,
            0,
            0,
            0,
            sysdate
    from    dual;
    --
    insert_route_parameters ('Input value ID', 'N', 1);
    --
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                             +
    -- input value route, name: INPUT_VALUE_USING_PARTIAL_MATCHING +
    --                                                             +
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := 'pay_input_values_f INPUTV,
pay_link_input_values_f LIV,
pay_element_types_f ETYPE,
pay_element_links_f ELINK,
per_assignments_f   PERA
WHERE  INPUTV.input_value_id = &U1
AND    &B1 BETWEEN INPUTV.effective_start_date
                AND INPUTV.effective_end_date
AND    INPUTV.input_value_id = LIV.input_value_id
AND    INPUTV.element_type_id = ETYPE.element_type_id
AND    &B1 BETWEEN ETYPE.effective_start_date
                AND ETYPE.effective_end_date
AND    ETYPE.element_type_id (+)= ELINK.element_type_id
AND    &B1 BETWEEN ELINK.effective_start_date
                AND ELINK.effective_end_date
AND    PERA.assignment_id  = &B2
AND    &B1 BETWEEN PERA.effective_start_date
                AND PERA.effective_end_date
AND    ((ELINK.payroll_id IS NOT NULL
AND      ELINK.payroll_id  = PERA.payroll_id)
OR      (ELINK.link_to_all_payrolls_flag    = ''Y''
AND      PERA.payroll_id  IS NOT NULL)
OR     ELINK.payroll_id   IS NULL)
AND   (ELINK.organization_id  = PERA.organization_id
OR     ELINK.organization_id  IS NULL)
AND   (ELINK.position_id = PERA.position_id
OR     ELINK.position_id IS NULL)
AND   (ELINK.job_id = PERA.job_id
OR     ELINK.job_id IS NULL)
AND   (ELINK.grade_id = PERA.grade_id
OR     ELINK.grade_id IS NULL)
AND   (ELINK.location_id = PERA.location_id
OR     ELINK.location_id  IS NULL)
AND    (ELINK.people_group_id IS NULL
OR     EXISTS
(SELECT 1
FROM   pay_assignment_link_usages_f PAL
WHERE  PAL.assignment_id = &B2
AND    PAL.element_link_id = ELINK.element_link_id
AND    &B1 BETWEEN PAL.effective_start_date
                AND PAL.effective_end_date))
AND    ELINK.element_link_id = LIV.element_link_id
AND    &B1 BETWEEN LIV.effective_start_date
                AND LIV.effective_end_date';
    --
    -- the above route text is so long that we hit a current PL/SQL bug of
    -- inserting with a select when using a long data type. So select the next
    -- value for the route_id separately, until this bug is fixed:
    --
    hr_utility.set_location('pay_dbi_startup_pkg.create_dbi_startup', 18);
    select ff_routes_s.nextval
    into   l_temp
    from   dual;
    --
    -- now do the normal insert
    --
    hr_utility.set_location('pay_dbi_startup_pkg.create_dbi_startup', 19);
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
    values (ff_routes_s.currval,
            'INPUT_VALUE_USING_PARTIAL_MATCHING',
            'N',
            'route for input value for given assignment id',
            l_text,
            sysdate,
            0,
            0,
            0,
            sysdate);
    --
    insert_route_parameters ('Input value ID', 'N', 1);
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id,   2);
    --
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                                     +
    -- Date paid input value route: INPUT_VALUE_USING_PARTIAL_MATCHING_DP  +
    --                                                                     +
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := ' /* route for date paid input value partial matching */
       pay_input_values_f                     INPUTV,
       pay_link_input_values_f                LIV,
       pay_element_types_f                    ETYPE,
       pay_element_links_f                    ELINK,
       per_assignments_f                      PERA,
       fnd_sessions                           SES
WHERE  INPUTV.input_value_id                = &U1
AND    SES.session_id                       = USERENV(''SESSIONID'')
AND    SES.effective_date             BETWEEN INPUTV.effective_start_date
                                          AND INPUTV.effective_end_date
AND    INPUTV.input_value_id                = LIV.input_value_id
AND    INPUTV.element_type_id               = ETYPE.element_type_id
AND    SES.effective_date             BETWEEN ETYPE.effective_start_date
                                          AND ETYPE.effective_end_date
AND    ETYPE.element_type_id             (+)= ELINK.element_type_id
AND    SES.effective_date             BETWEEN ELINK.effective_start_date
                                          AND ELINK.effective_end_date
AND    PERA.assignment_id                   = &B1
AND    SES.effective_date             BETWEEN PERA.effective_start_date
                                          AND PERA.effective_end_date
AND    ((ELINK.payroll_id                  IS NOT NULL
AND      ELINK.payroll_id                   = PERA.payroll_id)
OR      (ELINK.link_to_all_payrolls_flag    = ''Y''
AND      PERA.payroll_id                   IS NOT NULL)
OR     ELINK.payroll_id                    IS NULL)
AND   (ELINK.organization_id                = PERA.organization_id
OR     ELINK.organization_id               IS NULL)
AND   (ELINK.position_id                    = PERA.position_id
OR     ELINK.position_id                   IS NULL)
AND   (ELINK.job_id                         = PERA.job_id
OR     ELINK.job_id                        IS NULL)
AND   (ELINK.grade_id                       = PERA.grade_id
OR     ELINK.grade_id                      IS NULL)
AND   (ELINK.location_id                    = PERA.location_id
OR     ELINK.location_id                   IS NULL)
AND    (ELINK.people_group_id              IS NULL
OR     EXISTS
       (SELECT 1
       FROM   pay_assignment_link_usages_f          PAL
       WHERE  PAL.assignment_id                   = &B1
       AND    PAL.element_link_id                 = ELINK.element_link_id
       AND    SES.effective_date            BETWEEN PAL.effective_start_date
                                                AND PAL.effective_end_date))
AND    ELINK.element_link_id                = LIV.element_link_id
AND    SES.effective_date             BETWEEN LIV.effective_start_date
                                          AND LIV.effective_end_date';
    --
    -- the above route text is so long that we hit a current PL/SQL bug of
    -- inserting with a select when using a long data type. So select the next
    -- value for the route_id separately, until this bug is fixed:
    --
    hr_utility.set_location('pay_dbi_startup_pkg.create_dbi_startup', 20);
    select ff_routes_s.nextval
    into   l_temp
    from   dual;
    --
    -- now do the normal insert
    --
    hr_utility.set_location('pay_dbi_startup_pkg.create_dbi_startup', 21);
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
    values (ff_routes_s.currval,
            'INPUT_VALUE_USING_PARTIAL_MATCHING_DP',
            'N',
            'route for input value for given assignment id',
            l_text,
            sysdate,
            0,
            0,
            0,
            sysdate);
    --
    insert_route_parameters ('Input value ID', 'N', 1);
    insert_route_context_usages (l_assign_id_context_id,   1);
    --
    --++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                   +
    -- input value route, name : INPUT_VALUE_ENTRY_LEVEL +
    --                                                   +
    --++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := '/* Route : INPUT_VALUE_ENTRY_LEVEL */
        pay_element_entry_values_f               EEV,
        pay_element_entries_f                    EE,
        pay_link_input_values_f                  LIV,
        pay_input_values_f                       INPUTV
WHERE   INPUTV.input_value_id                  = &U1
AND     &B1 BETWEEN INPUTV.effective_start_date
                 AND INPUTV.effective_end_date
AND     INPUTV.element_type_id + 0             = &U2
AND     LIV.input_value_id                     = INPUTV.input_value_id
AND     &B1 BETWEEN LIV.effective_start_date
                 AND LIV.effective_end_date
AND     EEV.input_value_id + 0                 = INPUTV.input_value_id
AND     EEV.element_entry_id                   = EE.element_entry_id
AND     EEV.effective_start_date               = EE.effective_start_date
AND     EEV.effective_end_date                 = EE.effective_end_date
AND     EE.element_link_id                     = LIV.element_link_id
AND     EE.assignment_id                       = &B2
AND     &B1 BETWEEN EE.effective_start_date
                 AND EE.effective_end_date
AND     nvl(EE.ENTRY_TYPE, ''E'')              = ''E''';
    --
    hr_utility.set_location('pay_dbi_startup_pkg.create_dbi_startup', 22);
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
    select  ff_routes_s.nextval,
            'INPUT_VALUE_ENTRY_LEVEL',
            'N',
          'route for input value to element entry level',
            l_text,
            sysdate,
            0,
            0,
            0,
            sysdate
    from    dual;
    --
    insert_route_parameters ('Input value ID',  'N', 1);
    insert_route_parameters ('Element Type ID', 'N', 2);
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id,   2);
    --
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                           +
    -- Date paid input value route : INPUT_VALUE_ENTRY_LEVEL_DP  +
    --                                                           +
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := '/* route for date paid input value entry level */
       pay_input_values_f                     INPUTV,
       pay_element_entry_values_f             EEV,
       pay_link_input_values_f                LIV,
       pay_element_types_f                    ETYPE,
       pay_element_links_f                    ELINK,
       pay_element_entries_f                  EE,
       fnd_sessions                           SES
WHERE  INPUTV.input_value_id                = &U1
AND    SES.session_id                       = USERENV(''SESSIONID'')
AND    SES.effective_date             BETWEEN INPUTV.effective_start_date
                                          AND INPUTV.effective_end_date
AND    INPUTV.input_value_id                = EEV.input_value_id
AND    INPUTV.input_value_id                = LIV.input_value_id
AND    SES.effective_date             BETWEEN LIV.effective_start_date
                                          AND LIV.effective_end_date
AND    INPUTV.element_type_id               = ETYPE.element_type_id
AND    SES.effective_date             BETWEEN ETYPE.effective_start_date
                                          AND ETYPE.effective_end_date
AND    ETYPE.element_type_id                = ELINK.element_type_id
AND    SES.effective_date             BETWEEN ELINK.effective_start_date
                                          AND ELINK.effective_end_date
AND    EE.assignment_id                     = &B1
AND    SES.effective_date             BETWEEN EE.effective_start_date
                                          AND EE.effective_end_date
AND    ELINK.element_link_id                = EE.element_link_id
AND    ELINK.element_link_id                = LIV.element_link_id
AND    EE.entry_type                        = ''E''
AND    EE.element_entry_id                  = EEV.element_entry_id
AND    SES.effective_date             BETWEEN EEV.effective_start_date
                                          AND EEV.effective_end_date';
    --
    hr_utility.set_location('pay_dbi_startup_pkg.create_dbi_startup', 23);
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
    select  ff_routes_s.nextval,
            'INPUT_VALUE_ENTRY_LEVEL_DP',
            'N',
          'route for input value to element entry level',
            l_text,
            sysdate,
            0,
            0,
            0,
            sysdate
    from    dual;
    --
    insert_route_parameters ('Input value ID', 'N', 1);
    insert_route_context_usages (l_assign_id_context_id,   1);
    --
    --+++++++++++++++++++++++++++++++++++++++
    --                                      +
    -- grade route, name : GRADE_RATE_ROUTE +
    --                                      +
    --+++++++++++++++++++++++++++++++++++++++
    --
    l_text := '/* route for grade rates */
       pay_grade_rules_f                       GRULE,
       per_assignments_f                       ASSIGN
WHERE  &B1 BETWEEN GRULE.effective_start_date
                AND GRULE.effective_end_date
AND    GRULE.grade_or_spinal_point_id        = ASSIGN.grade_id +0
AND    GRULE.rate_type                       = ''G''
AND    ASSIGN.assignment_id                  = &B2
AND    &B1 BETWEEN ASSIGN.effective_start_date
                AND ASSIGN.effective_end_date
AND    GRULE.rate_id                         = &U1';
    --
    hr_utility.set_location('pay_dbi_startup_pkg.create_dbi_startup', 24);
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
    select  ff_routes_s.nextval,
            'GRADE_RATE_ROUTE',
            'N',
            'route for grade rates',
            l_text,
            sysdate,
            0,
            0,
            0,
            sysdate
    from    dual;
    --
    insert_route_parameters ('Grade Rate ID', 'N', 1);
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id,   2);
    --
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                       +
    -- people flex route, name : PEOPLE_FLEXFIELD_ROUTE      +
    --                                                       +
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text :=  '/* route for people flex */
       per_assignments_f                      ASSIGN,
       per_all_people_f                       target
WHERE  &B1 BETWEEN ASSIGN.effective_start_date
                AND ASSIGN.effective_end_date
AND    ASSIGN.assignment_id                 = &B2
AND    ASSIGN.person_id                     = target.person_id
AND    &B1 BETWEEN target.effective_start_date
                AND target.effective_end_date';
    --
    hr_utility.set_location('pay_dbi_startup_pkg.create_dbi_startup', 25);
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
    select  ff_routes_s.nextval,
            'PEOPLE_FLEXFIELD_ROUTE',
            'N',
            'people group flexfield route',
            l_text,
            sysdate,
            0,
            0,
            0,
            sysdate
    from    dual;
    --
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id, 2);
    --
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                       +
    -- payroll flex route, name : PAYROLL_FLEXFIELD_ROUTE    +
    --                                                       +
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text :=  '/* route for payrolls flex */
pay_all_payrolls_f                     target
WHERE  target.payroll_id                    = &B1
AND    &B2 BETWEEN target.effective_start_date
                AND target.effective_end_date';
    --
    hr_utility.set_location('pay_dbi_startup_pkg.create_dbi_startup', 26);
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
    select  ff_routes_s.nextval,
            'PAYROLL_FLEXFIELD_ROUTE',
            'N',
            'payroll flexfield route',
            l_text,
            sysdate,
            0,
            0,
            0,
            sysdate
    from    dual;
    --
    insert_route_context_usages (l_payroll_context_id, 1);
    insert_route_context_usages (l_date_earned_context_id, 2);
    --
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                          +
    -- assignment flex route, name : ASSIGNMENT_FLEXFIELD_ROUTE +
    --                                                          +
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text :=  '/* route for assignment flex */
per_all_assignments_f                  target
WHERE  &B1 BETWEEN target.effective_start_date
                AND target.effective_end_date
AND    target.assignment_id                 = &B2';
    --
    hr_utility.set_location('pay_dbi_startup_pkg.create_dbi_startup', 28);
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
    select  ff_routes_s.nextval,
            'ASSIGNMENT_FLEXFIELD_ROUTE',
            'N',
            'assignment flexfield route',
            l_text,
            sysdate,
            0,
            0,
            0,
            sysdate
    from    dual;
    --
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id, 2);
    --
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                       +
    -- grade flex route, name : GRADE_FLEXFIELD_ROUTE        +
    --                                                       +
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text :=  '/* route for grade flex */
per_grades                             target,
per_assignments_f                      ASSIGN
WHERE  &B1 BETWEEN ASSIGN.effective_start_date
                AND ASSIGN.effective_end_date
AND    ASSIGN.assignment_id                 = &B2
AND    ASSIGN.grade_id                      = target.grade_id';
    --
    hr_utility.set_location('pay_dbi_startup_pkg.create_dbi_startup', 29);
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
    select  ff_routes_s.nextval,
            'GRADE_FLEXFIELD_ROUTE',
            'N',
            'grade flexfield route',
            l_text,
            sysdate,
            0,
            0,
            0,
            sysdate
    from    dual;
    --
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id, 2);
    --
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                          +
    -- Absence descriptive flex : ABSENCE_DESC_FLEX_ROUTE       +
    --                                                          +
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text :=  '/* route for absence descriptive flex */
        per_absence_attendances                target,
        per_assignments_f                      ASSIGN
WHERE   &B1 BETWEEN ASSIGN.effective_start_date
                AND ASSIGN.effective_end_date
AND    ASSIGN.assignment_id                  = &B2
AND    ASSIGN.assignment_type                = ''E''
AND    target.person_id                      = ASSIGN.person_id
AND    target.absence_attendance_id  =
       (select max (absence_attendance_id)
        from   per_absence_attendances
        where  person_id   =  ASSIGN.person_id
        and    date_start <=  &B1
       )';
    --
    hr_utility.set_location('pay_dbi_startup_pkg.create_dbi_startup', 30);
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
    select  ff_routes_s.nextval,
            'ABSENCE_DESC_FLEX_ROUTE',
            'N',
            'Absence flexfield route',
            l_text,
            sysdate,
            0,
            0,
            0,
            sysdate
    from    dual;
    --
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id, 2);
    --
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                               +
    -- Absence type descriptive flex :  ABSENCE_TYPE_DESC_FLEX_ROUTE +
    --                                                               +
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text :=  '/* route for Absence type descriptive flex */
        per_absence_attendance_types           target,
        per_absence_attendances                ABSENCE,
        per_assignments_f                      ASSIGN
WHERE   &B1 BETWEEN ASSIGN.effective_start_date
                 AND ASSIGN.effective_end_date
AND    ASSIGN.assignment_id                  = &B2
AND    ASSIGN.assignment_type                = ''E''
AND    ABSENCE.person_id                     = ASSIGN.person_id
AND    target.absence_attendance_type_id   = ABSENCE.absence_attendance_type_id
AND    ABSENCE.absence_attendance_id  =
       (select max (absence_attendance_id)
        from   per_absence_attendances
        where  person_id   =  ASSIGN.person_id
        and    date_start <=  &B1
       )';
    --
    hr_utility.set_location('pay_dbi_startup_pkg.create_dbi_startup', 31);
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
    select  ff_routes_s.nextval,
            'ABSENCE_TYPE_DESC_FLEX_ROUTE',
            'N',
            'Absence type flexfield route',
            l_text,
            sysdate,
            0,
            0,
            0,
            sysdate
    from    dual;
    --
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id, 2);
    --
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                                    +
    -- Employee Addresses desc. flex : EMPLOYEE_ADDRESSES_DESC_FLEX_ROUTE +
    --                                                                    +
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text :=  '/* route for Employee Addresses descriptive flex */
       per_addresses                           target,
       per_assignments_f                       ASSIGN
WHERE  &B1 BETWEEN ASSIGN.effective_start_date
                AND ASSIGN.effective_end_date
AND    ASSIGN.assignment_id                  = &B2
AND    target.person_id                      = ASSIGN.person_id
AND    target.primary_flag                   = ''Y''
AND    &B1 BETWEEN target.date_from
AND    nvl (target.date_to, to_date (''4712/12/31'',''YYYY/MM/DD''))';
    --
    hr_utility.set_location('pay_dbi_startup_pkg.create_dbi_startup', 32);
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
    select  ff_routes_s.nextval,
            'EMPLOYEE_ADDRESSES_DESC_FLEX_ROUTE',
            'N',
            'Employee Addresses flexfield route',
            l_text,
            sysdate,
            0,
            0,
            0,
            sysdate
    from    dual;
    --
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id, 2);
    --
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                          +
    -- Events descriptive flex : EVENTS_DESC_FLEX_ROUTE         +
    --                                                          +
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text :=  '/* route for events descriptive flex */
       per_events                              target
WHERE  target.assignment_id                  = &B2
AND    event_id =
       (select max (event_id)
        from   per_events
        where  assignment_id         =  &B2
        and    &B1 between date_start
        and    nvl (date_end, to_date (''4712/12/31'',''YYYY/MM/DD''))
       )';
    --
    hr_utility.set_location('pay_dbi_startup_pkg.create_dbi_startup', 33);
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
    select  ff_routes_s.nextval,
            'EVENTS_DESC_FLEX_ROUTE',
            'N',
            'Events flexfield route',
            l_text,
            sysdate,
            0,
            0,
            0,
            sysdate
    from    dual;
    --
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id, 2);
    --
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                          +
    -- Job descriptive flex : JOBS_DESC_FLEX_ROUTE              +
    --                                                          +
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text :=  '/* route for Job descriptive flex */
        per_jobs                               target,
        per_assignments_f                      ASSIGN
WHERE   &B1 BETWEEN ASSIGN.effective_start_date
                 AND ASSIGN.effective_end_date
AND    ASSIGN.assignment_id                  = &B2
AND    ASSIGN.job_id                         = target.job_id';
    --
    hr_utility.set_location('pay_dbi_startup_pkg.create_dbi_startup', 34);
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
    select  ff_routes_s.nextval,
            'JOBS_DESC_FLEX_ROUTE',
            'N',
            'Job flexfield route',
            l_text,
            sysdate,
            0,
            0,
            0,
            sysdate
    from    dual;
    --
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id, 2);
    --
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                          +
    -- Contacts descriptive flex : CONTACTS_DESC_FLEX_ROUTE     +
    --                                                          +
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text :=  '/* route for Contacts descriptive flex */
        per_contact_relationships              target,
        per_assignments_f                      ASSIGN
WHERE   &B1 BETWEEN ASSIGN.effective_start_date
                 AND ASSIGN.effective_end_date
AND    ASSIGN.assignment_id                  = &B2
AND    ASSIGN.assignment_type                = ''E''
AND    ASSIGN.person_id                      = target.contact_person_id
AND    target.primary_contact_flag           = ''Y''';
    --
    hr_utility.set_location('pay_dbi_startup_pkg.create_dbi_startup', 35);
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
    select  ff_routes_s.nextval,
            'CONTACTS_DESC_FLEX_ROUTE',
            'N',
            'Contacts flexfield route',
            l_text,
            sysdate,
            0,
            0,
            0,
            sysdate
    from    dual;
    --
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id, 2);
    --
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                                   +
    -- period of service desc flex : PERIODS_OF_SERVICE_DESC_FLEX_ROUTE  +
    --                                                                   +
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text :=  '/* route for periods of service descriptive flex */
        per_periods_of_service                 target,
        per_assignments_f                      ASSIGN
WHERE   &B1 BETWEEN ASSIGN.effective_start_date
                 AND ASSIGN.effective_end_date
AND    ASSIGN.assignment_id                  = &B2
AND    ASSIGN.assignment_type                = ''E''
AND    target.period_of_service_id           = ASSIGN.period_of_service_id';
    --
    hr_utility.set_location('pay_dbi_startup_pkg.create_dbi_startup', 36);
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
    select  ff_routes_s.nextval,
            'PERIODS_OF_SERVICE_DESC_FLEX_ROUTE',
            'N',
            'periods of service flexfield route',
            l_text,
            sysdate,
            0,
            0,
            0,
            sysdate
    from    dual;
    --
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id, 2);
    --
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                                  +
    -- recruitment desc flex : RECRUITMENT_ACTIVITIES_DESC_FLEX_ROUTE   +
    --                                                                  +
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text :=  '/* route for recruitment activities descriptive flex */
        per_recruitment_activities             target,
        per_assignments_f                      ASSIGN
WHERE   &B1 BETWEEN ASSIGN.effective_start_date
                 AND ASSIGN.effective_end_date
AND    ASSIGN.assignment_id                  = &B2
AND    ASSIGN.assignment_type                = ''A''
AND    target.recruitment_activity_id        = ASSIGN.recruitment_activity_id';
    --
    hr_utility.set_location('pay_dbi_startup_pkg.create_dbi_startup', 37);
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
    select  ff_routes_s.nextval,
            'RECRUITMENT_ACTIVITIES_DESC_FLEX_ROUTE',
            'N',
            'recruitment activities flexfield route',
            l_text,
            sysdate,
            0,
            0,
            0,
            sysdate
    from    dual;
    --
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id, 2);
    --
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                          +
    -- Positions descriptive flex : POSITION_DESC_FLEX_ROUTE    +
    --                                                          +
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text :=  '/* route for Positions descriptive flex */
        per_positions                          target,
        per_assignments_f                      ASSIGN
WHERE   &B1 BETWEEN ASSIGN.effective_start_date
                 AND ASSIGN.effective_end_date
AND    ASSIGN.assignment_id                  = &B2
AND    target.position_id                    = ASSIGN.position_id';
    --
    hr_utility.set_location('pay_dbi_startup_pkg.create_dbi_startup', 38);
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
    select  ff_routes_s.nextval,
            'POSITION_DESC_FLEX_ROUTE',
            'N',
            'Positions flexfield route',
            l_text,
            sysdate,
            0,
            0,
            0,
            sysdate
    from    dual;
    --
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id, 2);
    --
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                              +
    -- Application descriptive flex : APPLICATIONS_DESC_FLEX_ROUTE  +
    --                                                              +
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text :=  '/* route for Application descriptive flex */
        per_applications                       target,
        per_assignments_f                      ASSIGN
WHERE   &B1 BETWEEN ASSIGN.effective_start_date
                 AND ASSIGN.effective_end_date
AND    ASSIGN.assignment_id                  = &B2
AND    ASSIGN.assignment_type                = ''A''
AND    target.application_id                 = ASSIGN.application_id';
    --
    hr_utility.set_location('pay_dbi_startup_pkg.create_dbi_startup', 39);
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
    select  ff_routes_s.nextval,
            'APPLICATIONS_DESC_FLEX_ROUTE',
            'N',
            'Applications flexfield route',
            l_text,
            sysdate,
            0,
            0,
            0,
            sysdate
    from    dual;
    --
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id, 2);
    --
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                              +
    -- Organization descriptive flex : ORGANIZATION_DESC_FLEX_ROUTE +
    --                                                              +
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text :=  '/* route for Organization descriptive flex */
        hr_organization_units                  target,
        per_assignments_f                      ASSIGN
WHERE   &B1 BETWEEN ASSIGN.effective_start_date
                 AND ASSIGN.effective_end_date
AND    ASSIGN.assignment_id                  = &B2
AND    target.organization_id                = ASSIGN.organization_id';
    --
    hr_utility.set_location('pay_dbi_startup_pkg.create_dbi_startup', 40);
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
    select  ff_routes_s.nextval,
            'ORGANIZATION_DESC_FLEX_ROUTE',
            'N',
            'Organization flexfield route',
            l_text,
            sysdate,
            0,
            0,
            0,
            sysdate
    from    dual;
    --
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id, 2);
    --
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                                  +
    -- Organization Developer DF route : DEVELOPER_ORG_DESC_FLEX_ROUTE  +
    --                                                                  +
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := '/* route for Organization Developer DF */
hr_organization_information            target,
per_assignments_f                      ASSIGN
WHERE  &B1 BETWEEN ASSIGN.effective_start_date
                AND ASSIGN.effective_end_date
AND    ASSIGN.assignment_id                  = &B2
AND    ASSIGN.organization_id                = target.organization_id
AND    replace (ltrim(rtrim(target.org_information_context)),'' '',''_'')
                                             = &U1';
    --
    hr_utility.set_location('pay_dbi_startup_pkg.create_dbi_startup', 41);
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
    select  ff_routes_s.nextval,
            'DEVELOPER_ORG_DESC_FLEX_ROUTE',
            'N',
            'route for Organization Developer Descriptive Flexfield',
            l_text,
            sysdate,
            0,
            0,
            0,
            sysdate
    from    dual;
    --
    insert_route_parameters ('Organization Information Context', 'T', 1);
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id,   2);
    --
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                                  +
    -- Assignment Developer DF route : DEVELOPER_ASS_DESC_FLEX_ROUTE    +
    --                                                                  +
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := '/* route for Assignment Developer DF */
per_assignment_extra_info      target
where   target.assignment_id         = &B1
and     replace (ltrim(rtrim(target.information_type)),'' '',''_'') = &U1';
    --
    hr_utility.set_location('pay_dbi_startup_pkg.create_dbi_startup', 42);
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
    select  ff_routes_s.nextval,
            'DEVELOPER_ASS_DESC_FLEX_ROUTE',
            'N',
            'route for Assignment Developer Descriptive Flexfield',
            l_text,
            sysdate,
            0,
            0,
            0,
            sysdate
    from    dual;
    --
    insert_route_parameters ('Assignment Information Context', 'T', 1);
    insert_route_context_usages (l_assign_id_context_id,   1);
    --
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                                  +
    --  Organization Payment DF :  ORG_PAY_METHOD_DESC_FLEX_ROUTE       +
    --                                                                  +
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := '/* route for Organization Payment Method DF */
        pay_org_payment_methods_f              target
where   &B1 BETWEEN target.effective_start_date
                 AND target.effective_end_date
and     target.org_payment_method_id         = &B2
and     target.payment_type_id               = &U1';
    --
    hr_utility.set_location('pay_dbi_startup_pkg.create_dbi_startup', 43);
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
    select  ff_routes_s.nextval,
            'ORG_PAY_METHOD_DESC_FLEX_ROUTE',
            'N',
            'route for Organization Payment Method Descriptive Flex',
            l_text,
            sysdate,
            0,
            0,
            0,
            sysdate
    from    dual;
    --
    insert_route_parameters ('Payment Type id', 'N', 1);
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_org_pay_method_id,      2);
    --
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                                  +
    --  External Account Keyflex route : EXT_ACCOUNT_PER_KEYFLEX_ROUTE  +
    --                                                                  +
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := '/* route for Personal External Account Keyflex */
        pay_external_accounts                  target
,       pay_personal_payment_methods_f         PERPAY
where   &B1 BETWEEN PERPAY.effective_start_date
                 AND PERPAY.effective_end_date
and     PERPAY.personal_payment_method_id    = &B2
and     target.external_account_id        (+)= PERPAY.external_account_id';
    --
    hr_utility.set_location('pay_dbi_startup_pkg.create_dbi_startup', 44);
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
    select  ff_routes_s.nextval,
            'EXT_ACCOUNT_PER_KEYFLEX_ROUTE',
            'N',
            'route for Personal External Account Keyflex',
            l_text,
            sysdate,
            0,
            0,
            0,
            sysdate
    from    dual;
    --
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_per_pay_method_id,      2);
    --
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                                  +
    --  External Account Keyflex route : EXT_ACCOUNT_ORG_KEYFLEX_ROUTE  +
    --                                                                  +
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := '/* route for Organization External Account Keyflex */
        pay_external_accounts                  target
,       pay_org_payment_methods_f              ORGPAY
where   ORGPAY.org_payment_method_id         = &B2
and     &B1 BETWEEN ORGPAY.effective_start_date
                 AND ORGPAY.effective_end_date
and     target.external_account_id          = ORGPAY.external_account_id';
    --
    hr_utility.set_location('pay_dbi_startup_pkg.create_dbi_startup', 45);
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
    select  ff_routes_s.nextval,
            'EXT_ACCOUNT_ORG_KEYFLEX_ROUTE',
            'N',
            'route for Organization External Account Keyflex',
            l_text,
            sysdate,
            0,
            0,
            0,
            sysdate
    from    dual;
    --
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_org_pay_method_id,      2);
    --
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                                  +
    --  Legal Company DF route :  LEGAL_CO_DESC_FLEX_ROUTE              +
    --                                                                  +
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := '/* route for Legal Company Descriptive Flex */
       hr_organization_information             target
where  target.organization_id                = &B1
AND    replace(ltrim(rtrim(target.org_information_context)),'' '',''_'')
                                             = &U1';
    --
    hr_utility.set_location('pay_dbi_startup_pkg.create_dbi_startup', 46);
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
    select  ff_routes_s.nextval,
            'LEGAL_CO_DESC_FLEX_ROUTE',
            'N',
            'route for Legal Company Descriptive Flex',
            l_text,
            sysdate,
            0,
            0,
            0,
            sysdate
    from    dual;
    --
    insert_route_parameters ('Organization Information Context', 'T', 1);
    insert_route_context_usages (l_tax_unit_id, 1);
    --
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                           +
    -- absence route, name : ABSENCE_SUM_OF_ELEMENT_ENTRY_VALUES +
    --                                                           +
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    -- note : there is no context of date earned since the route needs to
    -- sum all element entry values for a given absence type regardless of
    -- the current session date.
    --
    l_text := '/* absence route */
       pay_element_entry_values_f          target,
       pay_element_entries_f               EE,
       pay_link_input_values_f             LNKV,
       per_absence_attendance_types        ABTYPE
WHERE  ABTYPE.absence_attendance_type_id   = &U1
and    LNKV.input_value_id                 = ABTYPE.input_value_id
AND    TARGET.input_value_id+0             = LNKV.input_value_id
and    EE.element_link_ID                  = LNKV.element_link_id
AND    EE.element_entry_id                 = TARGET.element_entry_id
and    TARGET.effective_start_date between
              EE.effective_start_date and EE.effective_end_date
and    TARGET.effective_start_date between
              LNKV.effective_start_date and LNKV.effective_end_date
AND    EE.assignment_id                    = &B1';
    --
    hr_utility.set_location('pay_dbi_startup_pkg.create_dbi_startup', 47);
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
    select  ff_routes_s.nextval,
            'ABSENCE_SUM_OF_ELEMENT_ENTRY_VALUES',
            'N',
            'absence route to element entry values',
            l_text,
            sysdate,
            0,
            0,
            0,
            sysdate
    from    dual;
    --
    insert_route_parameters ('Absence Type ID', 'N', 1);
    insert_route_context_usages (l_assign_id_context_id, 1);
    --
    --+++++++++++++++++++++++++++++++++++++++
    --                                      +
    -- spine route, name : SPINE_RATE_ROUTE +
    --                                      +
    --+++++++++++++++++++++++++++++++++++++++
    --
    l_text := '/* route for spine rates */
       pay_grade_rules_f                       target,
       per_spinal_point_steps_f                sps,
       per_spinal_point_placements_f           spp
WHERE  &B1 BETWEEN target.effective_start_date
                AND target.effective_end_date
AND    target.rate_type                      = ''SP''
AND    target.rate_id                        = &U1
AND    target.grade_or_spinal_point_id       = sps.spinal_point_id
AND    &B1 BETWEEN sps.effective_start_date
                AND sps.effective_end_date
AND    sps.step_id                           = spp.step_id
AND    spp.assignment_id                     = &B2
AND    &B1 BETWEEN spp.effective_start_date
                AND spp.effective_end_date';
    --
    hr_utility.set_location('pay_dbi_startup_pkg.create_dbi_startup', 48);
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
    select  ff_routes_s.nextval,
            'SPINE_RATE_ROUTE',
            'N',
            'route for grade rates',
            l_text,
            sysdate,
            0,
            0,
            0,
            sysdate
    from    dual;
    --
    insert_route_parameters ('Spine Rate ID', 'N', 1);
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id,   2);
    --
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                       +
    -- key flexfield route, name : KEY_FLEXFIELD_ROUTE       +
    --                                                       +
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text :=  '/* key flexfield route */
       per_all_assignments_f                  ASSIGN,
       per_all_positions                      POS,
       per_position_definitions               POSDEF, /* target for position */
       per_grades                             GRA,
       per_grade_definitions                  GRADEF, /* target for grade    */
       per_jobs                               JOB,
       per_job_definitions                    JOBDEF, /* target for job      */
       pay_people_groups                      PGROUP  /* target for group    */
WHERE  &B1 BETWEEN ASSIGN.effective_start_date
                AND ASSIGN.effective_end_date
AND    ASSIGN.assignment_id                 = &B2
AND    POS.position_id                   (+)= ASSIGN.position_id
AND    POSDEF.position_definition_id     (+)= POS.position_definition_id
AND    GRA.grade_id                      (+)= ASSIGN.grade_id
AND    GRADEF.grade_definition_id        (+)= GRA.grade_definition_id
AND    JOB.job_id                        (+)= ASSIGN.job_id
AND    JOBDEF.job_definition_id          (+)= JOB.job_definition_id
AND    PGROUP.people_group_id            (+)= ASSIGN.people_group_id';
    --
    hr_utility.set_location('pay_dbi_startup_pkg.create_dbi_startup', 49);
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
    select  ff_routes_s.nextval,
            'KEY_FLEXFIELD_ROUTE',
            'N',
            'key flexfield route',
            l_text,
            sysdate,
            0,
            0,
            0,
            sysdate
    from    dual;
    --
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id, 2);
    --
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                                  +
    -- SCL assignment level route : SCL_ASS_FLEX_ROUTE                  +
    --                                                                  +
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := '/* route for SCL keyflex - assignment level */
hr_soft_coding_keyflex                 target,
per_assignments_f                      ASSIGN
WHERE  &B1 BETWEEN ASSIGN.effective_start_date
                AND ASSIGN.effective_end_date
AND    ASSIGN.assignment_id                  = &B2
AND    target.soft_coding_keyflex_id         = ASSIGN.soft_coding_keyflex_id
AND    target.enabled_flag                   = ''Y''
AND    target.id_flex_num                    = &U1';
    --
    hr_utility.set_location('pay_dbi_startup_pkg.create_dbi_startup', 50);
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
    select  ff_routes_s.nextval,
            'SCL_ASS_FLEX_ROUTE',
            'N',
            'route for SCL assignment level Flexfield',
            l_text,
            sysdate,
            0,
            0,
            0,
            sysdate
    from    dual;
    --
    insert_route_parameters ('ID flex number', 'N', 1);
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id,   2);
    --
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                                  +
    -- SCL payroll level route : SCL_PAY_FLEX_ROUTE                     +
    --                                                                  +
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := '/* route for SCL keyflex - payroll level */
       hr_soft_coding_keyflex                  target
,      per_assignments_f                       ASSIGN
,      pay_payrolls_f                          PAYROLL
WHERE  &B1 BETWEEN ASSIGN.effective_start_date
                AND ASSIGN.effective_end_date
AND    ASSIGN.assignment_id                  = &B2
AND    target.id_flex_num                    = &U1
AND    target.enabled_flag                   = ''Y''
AND    PAYROLL.payroll_id                    = ASSIGN.payroll_id
AND    &B1 BETWEEN PAYROLL.effective_start_date
                AND PAYROLL.effective_end_date
AND    target.soft_coding_keyflex_id         = PAYROLL.soft_coding_keyflex_id';
    --
    hr_utility.set_location('pay_dbi_startup_pkg.create_dbi_startup', 51);
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
    select  ff_routes_s.nextval,
            'SCL_PAY_FLEX_ROUTE',
            'N',
            'route for SCL payroll level Flexfield',
            l_text,
            sysdate,
            0,
            0,
            0,
            sysdate
    from    dual;
    --
    insert_route_parameters ('ID flex number', 'N', 1);
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id,   2);
    --
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                                  +
    -- SCL organization level route : SCL_ORG_FLEX_ROUTE                +
    --                                                                  +
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := '/* route for SCL keyflex - organization level */
       hr_soft_coding_keyflex                  target
,      per_assignments_f                       ASSIGN
,      hr_organization_units                   ORG
WHERE  &B1 BETWEEN ASSIGN.effective_start_date
                AND ASSIGN.effective_end_date
AND    ASSIGN.assignment_id                  = &B2
AND    target.enabled_flag                   = ''Y''
AND    target.id_flex_num                    = &U1
AND    ORG.organization_id                   = ASSIGN.organization_id
AND    target.soft_coding_keyflex_id         = ORG.soft_coding_keyflex_id';
    --
    hr_utility.set_location('pay_dbi_startup_pkg.create_dbi_startup', 52);
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
    select  ff_routes_s.nextval,
            'SCL_ORG_FLEX_ROUTE',
            'N',
            'route for SCL organization level Flexfield',
            l_text,
            sysdate,
            0,
            0,
            0,
            sysdate
    from    dual;
    --
    insert_route_parameters ('ID flex number', 'N', 1);
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id,   2);
    --
    --
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                                  +
    -- Retroadjusted Run route : RETROADJ_RUN_BAL_ROUTE                +
    --                                                                  +
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    l_text := '
pay_balance_feeds_f                  FEED,
pay_run_result_values                 TARGET,
pay_run_results                       RR,
pay_assignment_actions                ASSACT,
pay_assignment_actions                BAL_ASSACT,
pay_payroll_actions                   PACT,
pay_element_entries_f                 PEE
where   FEED.balance_type_id          = &U1
                       + decode(PACT.payroll_action_id, null, 0,0)
and     BAL_ASSACT.assignment_action_id = &B1
and     FEED.input_value_id           = TARGET.input_value_id
and     TARGET.run_result_id          = RR.run_result_id
and     RR.status                     in (''P'', ''PA'')
and     (RR.source_id                 = PEE.element_entry_id
and     RR.source_type not in (''R'', ''V''))
and     PEE.assignment_id             = BAL_ASSACT.assignment_id
and     PACT.payroll_action_id        = ASSACT.payroll_action_id
and     PACT.effective_date between
        FEED.effective_start_date and FEED.effective_end_date
and     PACT.date_earned between
        PEE.effective_start_date  and PEE.effective_end_date
and     RR.assignment_action_id       = ASSACT.assignment_action_id
and     ((ASSACT.assignment_action_id = &B1 and PEE.creator_type <> ''R'')
or      (PEE.creator_type = ''R'' and  PEE.source_id = &B1
         and PEE.entry_type = ''E''))';
--
    hr_utility.set_location('pay_dbi_startup_pkg.create_dbi_startup', 53);
    insert into  ff_routes
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
    select  ff_routes_s.nextval,
            'RETROADJ_RUN_BAL_ROUTE',
            'N',
            'route for Retroadjusted Run To Date Balance',
            l_text,
            sysdate,
            0,
            0,
            0,
            sysdate
    from dual;
    --
    insert_route_parameters ('ID balance type', 'N', 1);
    insert_route_context_usages (l_assignment_action_id, 1);
    --
    --
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                                  +
    --         Functions for the Entity Horizon                         +
    --                                                                  +
    --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
    -- The following function is used to call the PL/SQL function from
    -- formula to retrieve data from the User Defined Tables.
    --
    hr_utility.set_location ('pay_dbi_startup_pkg.create_dbi_startup', 100);
    select ff_functions_s.nextval
    into   l_function_id
    from dual;
    --
    hr_utility.set_location ('pay_dbi_startup_pkg.create_dbi_startup', 101);
    --
    -- insert the main formula:
    -- note: perform a normal insert (rather than using a select) to avoid
    -- oracle error ora-4091.
    --
    insert into ff_functions
           (function_id,
            business_group_id,
            legislation_code,
            class,
            name,
            alias_name,
            data_type,
            definition,
            last_update_date,
            last_updated_by,
            last_update_login,
            created_by,
            creation_date)
     values(l_function_id,
            null,
            null,
            'U',
            'GET_TABLE_VALUE',
            null,
            'T',
            'hruserdt.get_table_value',
            sysdate,
            0,
            0,
            0,
            sysdate);
     --
     -- insert the context usages (first listed parameters to the formula)
     --
     hr_utility.set_location ('pay_dbi_startup_pkg.create_dbi_startup', 102);
     select context_id
     into   l_business_group_id
     from   ff_contexts
     where  context_name = 'BUSINESS_GROUP_ID';
     --
     hr_utility.set_location ('pay_dbi_startup_pkg.create_dbi_startup', 103);
     insert into ff_function_context_usages
            (function_id,
             sequence_number,
             context_id)
     values (l_function_id,
             1,
             l_business_group_id);
     --
     -- insert the formula parameters
     --
     hr_utility.set_location ('pay_dbi_startup_pkg.create_dbi_startup', 104);
     insert into ff_function_parameters
            (function_id,
             sequence_number,
             class,
             continuing_parameter,
             data_type,
             name,
             optional)
     values (l_function_id,
             1,
             'I',
             'N',
             'T',
             'table_name',
             'N');
     --
     hr_utility.set_location ('pay_dbi_startup_pkg.create_dbi_startup', 105);
     insert into ff_function_parameters
            (function_id,
             sequence_number,
             class,
             continuing_parameter,
             data_type,
             name,
             optional)
     values (l_function_id,
             2,
             'I',
             'N',
             'T',
             'column_name',
             'N');
     --
     hr_utility.set_location ('pay_dbi_startup_pkg.create_dbi_startup', 106);
     insert into ff_function_parameters
            (function_id,
             sequence_number,
             class,
             continuing_parameter,
             data_type,
             name,
             optional)
     values (l_function_id,
             3,
             'I',
             'N',
             'T',
             'row_value',
             'N');
     --
     hr_utility.set_location ('pay_dbi_startup_pkg.create_dbi_startup', 107);
     insert into ff_function_parameters
            (function_id,
             sequence_number,
             class,
             continuing_parameter,
             data_type,
             name,
             optional)
     values (l_function_id,
             4,
             'I',
             'N',
             'D',
             'effective_date',
             'Y');
     --
     hr_utility.set_location ('pay_dbi_startup_pkg.create_dbi_startup', 108);
--
END create_dbi_startup;
end pay_dbi_startup_pkg;

/
