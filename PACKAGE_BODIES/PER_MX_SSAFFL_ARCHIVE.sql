--------------------------------------------------------
--  DDL for Package Body PER_MX_SSAFFL_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_MX_SSAFFL_ARCHIVE" AS
/* $Header: pemxafar.pkb 120.2 2006/08/04 10:05:24 sbairagi noship $ */
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1993 Oracle Corporation.                        *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation,         *
   *  500 Oracle Parkway, Redwood City, CA, 94065.                  *
   *                                                                *
   ******************************************************************

    Name        : per_mx_ssaffl_archive

    Description : This package is used by the Social Security Affiliation
                  Archive process to archive the Hire/Rehire, Termination
                  Affiliation records in pay_action_information table.

    Change List
    -----------
    Date        Name       Vers    Bug No   Description
    ----------- ---------- ------  -------  --------------------------
    03-MAY-2004 kthirmiy   115.0            Created.
    17-MAY-2004 kthirmiy   115.1            Changed to get gre from location
                                            when gre_id from soft_coding_keyflex_id
                                            is null.
    11-JUN-2004 kthirmiy   115.2            Changed to check both tran_gre_id and
                                            gre_id is not null
    17-JUN-2004 kthirmiy   115.3            If both tran_gre_id and gre_id
                                            is not null then use gre_id.
                                            If tran_gre_id is not null and
                                            gre_id is null then use trans_gre_id
                                            in the c_get_asg query in
                                            action_creation.
    17-JUN-2004 kthirmiy   115.4            removed substr and archiving names
                                            all the characters and dispmag mag report
                                            will substr to put 27 chars in the tape.
    28-JUN-2004 kthirmiy   115.5  3722795   Name changed to archive as
                                            First_name || ' '||middle_names
    29-Jun-2004 kthirmiy   115.6            set the g_concurrent_flag to yes
    01-Jul-2004 kthirmiy   115.7            changed lv_assignment_number
                                            from Number to VARCHAR2(30)
    14-Jul-2004 kthirmiy   115.8            fixed the message to show correctly
    16-Jul-2004 kthirmiy   115.9            Added logic to remove the multiple
                                            correction records in the
                                            interpret_all_asg_events.
                                            Added start_date to get it from the
                                            pay_payroll_actions table in the
                                            get_payroll_action_info procedure.
                                            Added a new function get_start_date
                                            to return the archive_start_date
                                            from the passed parameter legal employer,
                                            transmitter gre and gre.
    19-Jul-2004 kthirmiy  115.10  3773620   changed to get the separation date as
                                            actual termination date when archiving
                                            separation details for termination.
    27-Jul-2004 kthirmiy  115.11            Added to get the values from the table.
    02-Aug-2004 kthirmiy  115.12  3797326   Changed interpret_all_asg_events procedure
                                            to handle the reverse termination issue.
                                            Now the event group has column
                                            assignment_status_type_id to track the changes.
                                            Renamed write_arch_plsql_table procedure to
                                            arch_hire_separation_data.
                                            Also moved the archive hire or separation
                                            details from archive_data to
                                            arch_hire_separation_data
    05-Aug-2004 kthrimiy  115.13   3814482  changed process_end_date procedure
                                            to handle term and rev term issue
    26-Aug-2004 kthirmiy  115.14   3856502  changed to archive jurisdiction
                                            column as blank.
    01-Dec-2004 kthirmiy  115.15            Added get_idw function call in
                                            archive_hire_details procedure to
                                            get the idw.
    02-Dec-2004 kthirmiy  115.16            round idw to 2 decimal and archive
    03-Jan-2005 kthirmiy  115.17   4084628  IDW is limited to 25 times of minimum wages
                                            of Zone A for reporting purposes
    07-Jan-2005 kthirmiy  115.18   4104743  Default Implementation date is derived from
                                            pay_mx_legislation_info_f table.
    07-Jan-2005 kthirmiy  115.19            fixed gscc error
    20-Jan-2005 ardsouza  115.20   4129001  Added p_business_group_id parameter to
                                            procedure "derive_gre_from_loc_scl".
    06-May-2005 kthirmiy  115.21   4353084  removed the redundant use of bind variable
                                            payroll_action_id
    01-Aug-2005 kthirmiy  115.22   4528984  Added where condition to get the correct
                                            minimum wage based on the effective_date
    02-AUG-2006 sbairagi  115.23   4872076  CURSOR c_chk_dyn_triggers_enabled od procedure
                                            range_cursor is tuned.
  ******************************************************************************/


   --
   -- < PRIVATE GLOBALS > ---------------------------------------------------
   --

   gv_package          VARCHAR2(100)   ;

   gv_event_group      VARCHAR2(40)    ;

   g_ambiguous_error   VARCHAR2(100)   ;
   g_missing_gre_error VARCHAR2(100)   ;

   g_report_imp_date   DATE ;

   g_event_group_id    NUMBER ;

   g_action_hire_category VARCHAR2(100) ;
   g_action_sep_category  VARCHAR2(100) ;

   -- flag to write the debug messages in the concurrent program log file
   g_concurrent_flag      VARCHAR2(1)  ;
   -- flag to write the debug messages in the trace file
   g_debug_flag           VARCHAR2(1)  ;



  /******************************************************************************
   Name      : msg
   Purpose   : Log a message, either using fnd_file, or hr_utility.trace
  ******************************************************************************/

  PROCEDURE msg(p_text  VARCHAR2)
  IS
  --
  BEGIN
    -- Write to the concurrent request log
    fnd_file.put_line(fnd_file.log, p_text);

  END msg;

  /******************************************************************************
   Name      : dbg
   Purpose   : Log a message, either using fnd_file, or hr_utility.trace
               if debuggging is enabled
  ******************************************************************************/
  PROCEDURE dbg(p_text  VARCHAR2) IS

  BEGIN

   IF (g_debug_flag = 'Y') THEN
     IF (g_concurrent_flag = 'Y') THEN
        -- Write to the concurrent request log
        fnd_file.put_line(fnd_file.log, p_text);
     ELSE
         -- Use HR trace
         hr_utility.trace(p_text);
     END IF;
   END IF;

  END dbg;


  /******************************************************************************
   Name      : get_default_imp_date
   Purpose   : This function returns the default implementation date
               from pay_mx_legislation_info_f table
   ******************************************************************************/
   FUNCTION get_default_imp_date
   RETURN VARCHAR2
   IS

   cursor c_get_def_imp_date
   is
   select fnd_date.canonical_to_date(legislation_info1)
   from pay_mx_legislation_info_f
   where legislation_info_type='MX Social Security Reporting' ;

   ld_def_date        date ;

   begin

    open c_get_def_imp_date ;
    fetch c_get_def_imp_date into ld_def_date ;
    close c_get_def_imp_date;

    return fnd_date.date_to_canonical(ld_def_date) ;

   end get_default_imp_date;


  /******************************************************************************
   Name      : get_start_date
   Purpose   : This function returns the archive start date based on the parameters
               1) Get the report implementation date for the legal employer id
               2) If it is null then default
                   report imp date = default implementation date from
                                     mx pay legislation info f table
               3) Get the Last time archive process ran date for a tax unit id
               4) If it is null then first time running the report
                  so default it to report imp date
   Note      : This function is called from the conc program
               Social Security Affiliation Data Archive Process
               parameter conc_start_date
   ******************************************************************************/
   FUNCTION get_start_date( p_legal_emp_id in varchar2
                          ,p_tran_gre_id  in varchar2
                          ,p_gre_id       in varchar2
                         ) RETURN VARCHAR2
   IS

   cursor c_get_start_date(cp_tax_unit_id in number)
   is
   select  fnd_date.canonical_to_date(ltrim(rtrim(substr(ppa.legislative_parameters,
                instr(ppa.legislative_parameters,
                         'END_DATE=')
                + length('END_DATE='),
                (instr(ppa.legislative_parameters,
                         'LEGAL_EMPLOYER=') - 1 )
              - (instr(ppa.legislative_parameters,
                         'END_DATE=')
              + length('END_DATE='))))))
   from pay_assignment_actions paa,
       pay_payroll_actions ppa
   where paa.tax_unit_id = cp_tax_unit_id
    and ppa.payroll_action_id=paa.payroll_action_id
    and ppa.report_type='SS_AFFILIATION'
    and ppa.report_qualifier ='IMSS'
   order by paa.payroll_action_id desc ;


   cursor c_get_imp_date(cp_organization_id in number)
    is
    select fnd_date.canonical_to_date(org_information6)
    from hr_organization_information
    where org_information_context= 'MX_TAX_REGISTRATION'
    and organization_id = cp_organization_id ;

    ld_report_imp_date   date ;
    ld_start_date        date ;
    lv_start_date        varchar2(50);
    ln_tax_unit_id       NUMBER;

    begin

    -- get the report Implementation Date from p_legal_emp_id
    open c_get_imp_date(to_number(p_legal_emp_id)) ;
    fetch c_get_imp_date into ld_report_imp_date ;
    if c_get_imp_date%notfound then
       -- defaulting to Report Implementation Date from mx pay legislation info table
       ld_report_imp_date := fnd_date.canonical_to_date(get_default_imp_date) ;
    end if;
    close c_get_imp_date;

    if p_gre_id is not null then
       ln_tax_unit_id := to_number(p_gre_id) ;
    else
       ln_tax_unit_id := to_number(p_tran_gre_id) ;
    end if ;

    open c_get_start_date(ln_tax_unit_id);
    fetch c_get_start_date into ld_start_date ;
    if c_get_start_date%notfound then
       -- assign the ld_start_date from rep imp date
       ld_start_date := ld_report_imp_date ;
    end if;
    close c_get_start_date;

    lv_start_date := fnd_date.date_to_canonical(ld_start_date) ;

    return lv_start_date ;

    end get_start_date;


  /******************************************************************************
   Name      : get_payroll_action_info
   Purpose   : This procedue returns the Payroll Action level parameter
               information for SS Affiliation Archiver.
   Arguments : p_payroll_action_id - Payroll_Action_id of archiver
               p_start_date        - Start date of Archiver
               p_end_date          - End date of Archiver
               p_business_group_id - Business Group ID
               p_tran_gre_id       - Transmiter GRE Id
               p_gre_id            - GRE Id
               p_event_group_id    - Event Group Id
  ******************************************************************************/
  PROCEDURE get_payroll_action_info(p_payroll_action_id     in        number
                                   ,p_start_date           out nocopy date
                                   ,p_end_date             out nocopy date
                                   ,p_business_group_id    out nocopy number
                                   ,p_tran_gre_id          out nocopy number
                                   ,p_gre_id               out nocopy number
                                   ,p_event_group_id       out nocopy number
                                   )
  IS
      -- cursor to get all the parameters from pay_payroll_actions table

      cursor c_payroll_Action_info(cp_payroll_action_id in number) is
      select business_group_id,
             to_number(substr(legislative_parameters,
                    instr(legislative_parameters,
                    'GRE_ID=')
                + length('GRE_ID='))) , -- gre_id
             to_number(ltrim(rtrim(substr(legislative_parameters,
                instr(legislative_parameters,
                         'TRANS_GRE=')
                + length('TRANS_GRE='),
                (instr(legislative_parameters,
                         'GRE_ID=') - 1 )
              - (instr(legislative_parameters,
                         'TRANS_GRE=')
              + length('TRANS_GRE=')))))) , -- trans_gre

             to_number(ltrim(rtrim(substr(legislative_parameters,
                instr(legislative_parameters,
                         'LEGAL_EMPLOYER=')
                + length('LEGAL_EMPLOYER='),
                (instr(legislative_parameters,
                         'TRANS_GRE=') - 1 )
              - (instr(legislative_parameters,
                         'LEGAL_EMPLOYER=')
              + length('LEGAL_EMPLOYER=')))))) , -- legal_employer

             fnd_date.canonical_to_date(ltrim(rtrim(substr(legislative_parameters,
                instr(legislative_parameters,
                         'END_DATE=')
                + length('END_DATE='),
                (instr(legislative_parameters,
                         'LEGAL_EMPLOYER=') - 1 )
              - (instr(legislative_parameters,
                         'END_DATE=')
              + length('END_DATE=')))))),  -- end_date

             fnd_date.canonical_to_date(ltrim(rtrim(substr(legislative_parameters,
                instr(legislative_parameters,
                         'START_DATE=')
                + length('START_DATE='),
                (instr(legislative_parameters,
                         'END_DATE=') - 1 )
              - (instr(legislative_parameters,
                         'START_DATE=')
              + length('START_DATE='))))))  -- start_date
      from pay_payroll_actions
      where payroll_action_id = cp_payroll_action_id;

   cursor c_get_imp_date(cp_organization_id in number)
    is
    select fnd_date.canonical_to_date(org_information6)
    from hr_organization_information
    where org_information_context= 'MX_TAX_REGISTRATION'
    and organization_id = cp_organization_id ;


    cursor c_get_event_group (cp_event_group_name in varchar2) is
    select event_group_id
    from pay_event_groups
    where event_group_name = cp_event_group_name ;

    ld_end_date          DATE;
    ld_start_date        DATE;
    ln_business_group_id NUMBER;
    ln_tran_gre_id       NUMBER;
    ln_gre_id            NUMBER;

    ln_tax_unit_id       NUMBER;
    ln_legal_emp_id      NUMBER;
    ln_event_group_id    NUMBER;

    ld_report_imp_date   DATE;

    lv_procedure_name    VARCHAR2(100) ;
    lv_error_message     VARCHAR2(200) ;
    ln_step              NUMBER;

   BEGIN

       lv_procedure_name    := '.get_payroll_action_info';

       hr_utility.set_location(gv_package || lv_procedure_name, 10);
       ln_step := 1;
       dbg('Entering get_payroll_action_info .......');

       -- open the cursor to get all the parameters from pay_payroll_actions table
       open c_payroll_action_info(p_payroll_action_id);
       fetch c_payroll_action_info into ln_business_group_id,
                                        ln_gre_id,
                                        ln_tran_gre_id,
                                        ln_legal_emp_id,
                                        ld_end_date,
                                        ld_start_date
                                        ;
       close c_payroll_action_info;

       -- get the report Implementation Date from ln_legal_emp_id and set it to the
       -- global variable g_report_imp_date
       hr_utility.set_location(gv_package || lv_procedure_name, 20);
       ln_step := 2;
       dbg('Get report Impl date for Legal employer id ' ||to_char(ln_legal_emp_id) );

       open c_get_imp_date(ln_legal_emp_id) ;
       fetch c_get_imp_date into ld_report_imp_date ;
       if c_get_imp_date%notfound then
          dbg('WARNING : Report Implementaton date is not entered for legal employer ' );
          dbg('so defaulting to Report Implementation Date from pay mx legislation info table');
          ld_report_imp_date := fnd_date.canonical_to_date(get_default_imp_date) ;
       end if;
       close c_get_imp_date;
       dbg('report impl date is '||to_char(ld_report_imp_date) );
       g_report_imp_date := ld_report_imp_date;

       hr_utility.set_location(gv_package || lv_procedure_name, 40);
       ln_step := 3;
       dbg('Get Event Group Id ' );

       open c_get_event_group(gv_event_group) ;
       fetch c_get_event_group into ln_event_group_id ;
       close c_get_event_group ;

       p_start_date        := ld_start_date;
       p_end_date          := ld_end_date;
       p_business_group_id := ln_business_group_id;
       p_tran_gre_id       := ln_tran_gre_id;
       p_gre_id            := ln_gre_id;
       p_event_group_id    := ln_event_group_id ;

       dbg('Parameters.....');
       dbg('start date     : ' || fnd_date.date_to_canonical(p_start_date)) ;
       dbg('end date       : ' || fnd_date.date_to_canonical(p_end_date)) ;
       dbg('bus group id   : ' || to_char(p_business_group_id)) ;
       dbg('trans gre id   : ' || to_char(p_tran_gre_id)) ;
       dbg('gre id         : ' || to_char(p_gre_id)) ;
       dbg('event group id : ' || to_char(p_event_group_id) );

       hr_utility.set_location(gv_package || lv_procedure_name, 40);
       ln_step := 4;

       dbg('Exiting get_payroll_action_info .......');

  EXCEPTION
    when others then
      lv_error_message := 'Error at step ' || ln_step || ' in ' ||
                           gv_package || lv_procedure_name;

      dbg(lv_error_message || '-' || sqlerrm);
      hr_utility.raise_error;

  END get_payroll_action_info;


  /******************************************************************
   Name      : range_cursor
   Purpose   : This returns the select statement that is
               used to created the range rows for the
               Social Security Affiliation Archiver.
   Notes     : Calls procedure - get_payroll_action_info
  ******************************************************************/
  PROCEDURE range_cursor( p_payroll_action_id in        number
                         ,p_sqlstr           out nocopy varchar2)
  IS

    CURSOR c_chk_dyn_triggers_enabled(cp_func_area in VARCHAR2)
    IS
    select /*+INDEX(PFA PAY_FUNCTIONAL_AREAS_PK)
              INDEX(PTE PAY_TRIGGER_EVENTS_PK)*/
	      pte.short_name
    from pay_functional_areas pfa,
         pay_functional_triggers pft,
         pay_trigger_events     pte
    where pfa.short_name = cp_func_area
    and   pfa.area_id = pft.area_id
    and   pft.event_id = pte.event_id
    and ( pte.generated_flag <> 'Y' or pte.enabled_flag <> 'Y' ) ;

    ld_start_date         DATE;
    ld_end_date           DATE;
    ln_business_group_id  NUMBER;
    ln_tran_gre_id        NUMBER;
    ln_gre_id             NUMBER;
    ln_event_group_id     NUMBER;

    lv_sql_string         VARCHAR2(32000);
    lv_procedure_name     VARCHAR2(100)  ;

    lv_func_area          VARCHAR2(40);
    lv_trigger_name       VARCHAR2(100);
  BEGIN

    dbg('Entering range_cursor ....... ') ;

    gv_package            := 'per_mx_ssaffl_archive'  ;
    gv_event_group        := 'MX_HIRE_SEPARATION_EVG' ;
    g_ambiguous_error     := '1' ; -- Multiple GRE found
    g_missing_gre_error   := '2' ; -- Location is not in the hierarchy';
    g_debug_flag          := 'Y' ;
--    g_concurrent_flag     := 'Y' ;

    lv_procedure_name     := '.range_cursor';
    hr_utility.set_location(gv_package || lv_procedure_name, 10);

    lv_func_area          := 'SS Affiliation Events' ;

    --	Get all the parameter information from pay_payroll_actions table
    dbg('Get parameter information from pay_payroll_actions table' ) ;

    get_payroll_action_info(p_payroll_action_id    => p_payroll_action_id
                            ,p_start_date           => ld_start_date
                            ,p_end_date             => ld_end_date
                            ,p_business_group_id    => ln_business_group_id
                            ,p_tran_gre_id          => ln_tran_gre_id
                            ,p_gre_id               => ln_gre_id
                            ,p_event_group_id       => ln_event_group_id);

     hr_utility.set_location(gv_package || lv_procedure_name, 20);

     -- Check the dynamic triggers are enable for functional area
     dbg('Check dynamic triggers enabled' ) ;

     open c_chk_dyn_triggers_enabled(lv_func_area );
     fetch c_chk_dyn_triggers_enabled into lv_trigger_name  ;

     if c_chk_dyn_triggers_enabled%found then
        close c_chk_dyn_triggers_enabled;

        dbg('Error : Dynamic triggers NOT enabled' ) ;
        lv_sql_string := null;

        hr_utility.raise_error;

     else

        dbg('Dynamic triggers Enabled' ) ;
        close c_chk_dyn_triggers_enabled ;

        lv_sql_string := 'select distinct ppe.assignment_id
          from pay_process_events ppe,
             pay_event_updates  peu,
             pay_datetracked_events pde
        where ppe.creation_date between
        fnd_date.canonical_to_date(''' || fnd_date.date_to_canonical(ld_start_date) || ''')
        and fnd_date.canonical_to_date(''' || fnd_date.date_to_canonical(ld_end_date) || ''')
        and ppe.event_update_id = peu.event_update_id
        and peu.dated_table_id = pde.dated_table_id
        and pde.event_group_id = ''' ||ln_event_group_id || '''
        and ppe.business_group_id = ''' ||ln_business_group_id || '''
        and (( decode(peu.column_name,''EFFECTIVE_END_DATE'',''1'') = nvl(pde.column_name,''1'')
        and decode(peu.event_type,''U'',''E'')=pde.update_type )
        or ( nvl(peu.column_name,1) = nvl(pde.column_name,1)
             and peu.event_type=pde.update_type ))
        and :payroll_action_id > 0 ' ;

     end if;

     hr_utility.set_location(gv_package || lv_procedure_name, 30);
     p_sqlstr := lv_sql_string;
     hr_utility.set_location(gv_package || lv_procedure_name, 40);

     dbg('Exiting range_cursor .......') ;

  END range_cursor;

  /************************************************************
   Name      : derive_gre_from_loc_scl
   Purpose   : This function derives the gre from the parmeters
               Location, BG and SCL(soft coding keyflex id)
  ************************************************************/
  FUNCTION derive_gre_from_loc_scl(
                 p_location_id             in number
                ,p_business_group_id       in number
                ,p_soft_coding_keyflex_id  in number
                ,p_effective_date          in date ) RETURN NUMBER
  IS

  ln_gre_id                 NUMBER;
  l_is_ambiguous            BOOLEAN ;
  l_missing_gre             BOOLEAN ;

  BEGIN

     if p_soft_coding_keyflex_id is not null then
        -- get the gre_id using scl
        ln_gre_id := hr_mx_utility.get_gre_from_scl(p_soft_coding_keyflex_id) ;

     end if;

     if ln_gre_id is null then
        -- get the gre_id using location
        ln_gre_id := hr_mx_utility.get_gre_from_location(
                                            p_location_id,
                                            p_business_group_id,
                                            p_effective_date,
                                            l_is_ambiguous,
                                            l_missing_gre ) ;
        if ln_gre_id is null then
           -- set the error message
           if l_is_ambiguous then
              ln_gre_id := -1 ;
           end if;
           if l_missing_gre then
              ln_gre_id := -2 ;
           end if;
        end if;

     end if;

     return (ln_gre_id) ;

  END derive_gre_from_loc_scl ;



  /************************************************************
   Name      : action_creation
   Purpose   : This creates the assignment actions for
               a specific chunk of people to be archived
               by the SS Affiliation Archiver process.
   Notes     : Calls procedure - get_payroll_action_info
  ************************************************************/
  PROCEDURE action_creation(
                 p_payroll_action_id   in number
                ,p_start_assignment_id in number
                ,p_end_assignment_id   in number
                ,p_chunk               in number)
  IS

   cursor c_get_asg( cp_start_assignment_id in number
                    ,cp_end_assignment_id   in number
                    ,cp_tran_gre_id         in number
                    ,cp_gre_id              in number
                    ,cp_business_group_id   in number
                    ,cp_start_date          in date
                    ,cp_end_date            in date
                    ,cp_event_group_id      in number
                        ) is
   select distinct ppe.assignment_id
--        ,paf.person_id,
--        ,per_mx_ssaffl_archive.derive_gre_from_loc_scl(paf.location_id,paf.business_group_id,paf.soft_coding_keyflex_id,ppe.effective_date)
          from pay_process_events ppe,
               pay_event_updates  peu,
               pay_datetracked_events pde,
               per_all_assignments_f  paf
          where ppe.creation_date between cp_start_date and cp_end_date
            and peu.event_update_id = ppe.event_update_id
            and ppe.business_group_id = cp_business_group_id
            and pde.dated_table_id = peu.dated_table_id
            and pde.event_group_id = cp_event_group_id
            and (( decode(peu.column_name,'EFFECTIVE_END_DATE','1') = nvl(pde.column_name,'1')
            and decode(peu.event_type,'U','E')=pde.update_type )
            or ( nvl(peu.column_name,1) = nvl(pde.column_name,1)
                 and peu.event_type=pde.update_type ) )
            and  paf.assignment_id = ppe.assignment_id
            and paf.assignment_id between cp_start_assignment_id and cp_end_assignment_id
            and ppe.effective_date between paf.effective_start_date and paf.effective_end_date
            and (( per_mx_ssaffl_archive.derive_gre_from_loc_scl(paf.location_id,paf.business_group_id,paf.soft_coding_keyflex_id,ppe.effective_date) = -1 )
              or ( per_mx_ssaffl_archive.derive_gre_from_loc_scl(paf.location_id,paf.business_group_id,paf.soft_coding_keyflex_id,ppe.effective_date) = -2 )
              or ( cp_tran_gre_id is not null and cp_gre_id is not null and
                   per_mx_ssaffl_archive.derive_gre_from_loc_scl(paf.location_id,paf.business_group_id,paf.soft_coding_keyflex_id,ppe.effective_date)=cp_gre_id )
              or ( cp_tran_gre_id is not null and cp_gre_id is null and
                   per_mx_ssaffl_archive.derive_gre_from_loc_scl(paf.location_id,paf.business_group_id,paf.soft_coding_keyflex_id,ppe.effective_date)
                   in
                   (select organization_id
                    from hr_organization_information hoi
                    where  hoi.org_information_context = 'MX_SOC_SEC_DETAILS'
                    and ((org_information6 = cp_tran_gre_id ) OR ( organization_id = cp_tran_gre_id and org_information3='Y'))))) ;


    ld_start_date         DATE;
    ld_end_date           DATE;
    ln_business_group_id  NUMBER;
    ln_tran_gre_id        NUMBER;
    ln_gre_id             NUMBER;
    ln_person_id          NUMBER;
    ln_tax_unit_id        NUMBER;
    ln_event_group_id     NUMBER;
    ln_assignment_id      NUMBER;
    ln_action_id          NUMBER;
    lv_procedure_name     VARCHAR2(100) ;
    lv_error_message      VARCHAR2(200);
    ln_step               NUMBER;

  begin

     dbg('Entering Action creation ..............') ;

     gv_package            := 'per_mx_ssaffl_archive'  ;
     gv_event_group        := 'MX_HIRE_SEPARATION_EVG' ;
     g_debug_flag          := 'Y' ;
--     g_concurrent_flag     := 'Y' ;

     lv_procedure_name    := '.action_creation';

     hr_utility.set_location(gv_package || lv_procedure_name, 10);
     ln_step := 1;
     dbg('Get parameter information from pay_payroll_actions table' ) ;

     get_payroll_action_info(p_payroll_action_id => p_payroll_action_id
                            ,p_start_date        => ld_start_date
                            ,p_end_date          => ld_end_date
                            ,p_business_group_id => ln_business_group_id
                            ,p_tran_gre_id       => ln_tran_gre_id
                            ,p_gre_id            => ln_gre_id
                            ,p_event_group_id    => ln_event_group_id
                            );


     hr_utility.set_location(gv_package || lv_procedure_name, 20);
     ln_step := 2;
     dbg('Action creation Query parameters') ;
     dbg('Start assignment id : ' || to_char(p_start_assignment_id));
     dbg('End   assignment id : ' || to_char(p_end_assignment_id));
     dbg('tansmitter gre id   : ' || to_char(ln_tran_gre_id));
     dbg('gre id              : ' || to_char(ln_gre_id));
     dbg('event group id      : ' || to_char(ln_event_group_id));
     dbg('business_group_id   : ' || to_char(ln_business_group_id));
     dbg('start date is       : ' || fnd_date.date_to_canonical(ld_start_date)) ;
     dbg('end date is         : ' || fnd_date.date_to_canonical(ld_end_date)) ;

     open c_get_asg( p_start_assignment_id
                    ,p_end_assignment_id
                    ,ln_tran_gre_id
                    ,ln_gre_id
                    ,ln_business_group_id
                    ,ld_start_date
                    ,ld_end_date
                    ,ln_event_group_id);

     -- Loop for all rows returned for SQL statement.
     hr_utility.set_location(gv_package || lv_procedure_name, 30);
     ln_step := 3;

     loop
        fetch c_get_asg into ln_assignment_id ;
        exit when c_get_asg%notfound;

        -- if gre_id is not null then tax_unit_id= gre_id
        -- if tran_gre_id is not null then tax_unit_id = tran_gre_id

        hr_utility.set_location(gv_package || lv_procedure_name, 40);
        ln_step := 4;
        dbg('creating aaid for assignment_id = ' || to_char(ln_assignment_id) ||
               ' Tax Unit Id = ' || to_char(nvl(ln_gre_id,ln_tran_gre_id)) ) ;

        select pay_assignment_actions_s.nextval
        into ln_action_id
        from dual;


        -- insert into pay_assignment_actions.
        hr_nonrun_asact.insact(ln_action_id,
                               ln_assignment_id,
                               p_payroll_action_id,
                               p_chunk,
                               nvl(ln_gre_id,ln_tran_gre_id),
                               null,
                               'U',
                               null);

        dbg('assignment action id is ' || to_char(ln_action_id)  );

     end loop;
     close c_get_asg;

     hr_utility.set_location(gv_package || lv_procedure_name, 50);
     ln_step := 5;

     dbg('Exiting Action creation ..............') ;


  EXCEPTION
    when others then
      lv_error_message := 'Error at step ' || ln_step || ' in ' ||
                           gv_package || lv_procedure_name;
      dbg(lv_error_message || '-' || sqlerrm);
      hr_utility.raise_error;

  END action_creation;

  /******************************************************************************
   Name      : archinit
   Purpose   : This procedure performs all the required initialization.
  ******************************************************************************/
  PROCEDURE archinit( p_payroll_action_id in number)
  IS

    ln_step                   NUMBER;
    lv_procedure_name         VARCHAR2(100) ;

  BEGIN


     dbg('Entering archinit .............');

     gv_package              := 'per_mx_ssaffl_archive'  ;
     gv_event_group          := 'MX_HIRE_SEPARATION_EVG' ;
     g_ambiguous_error       := '1' ; -- Multiple GRE found
     g_missing_gre_error     := '2' ; -- Location is not in the hierarchy';
     g_action_hire_category  := 'MX SS HIRE DETAILS' ;
     g_action_sep_category   := 'MX SS SEPARATION DETAILS';
     g_debug_flag            := 'Y' ;
--     g_concurrent_flag       := 'Y' ;

     lv_procedure_name     := '.archinit';

     hr_utility.set_location(gv_package || lv_procedure_name, 10);
     ln_step := 1;

     dbg('Exiting archinit .............');

  END archinit;

  /*****************************************************************************
   Name      : chk_active_asg_exists
   Purpose   : This function check any active assignment exists for the passed
               parameters and return the flag.
  ******************************************************************************/
  FUNCTION chk_active_asg_exists(
                 p_skip_assignment_id   in number
                ,p_person_id            in number
                ,p_gre_id               in number
                ,p_effective_date       in date
                )     RETURN VARCHAR2
  IS

  cursor c_get_active_asg(cp_skip_assignment_id   in number
                         ,cp_person_id            in number
                         ,cp_gre_id               in number
                         ,cp_effective_date       in date )
  IS
  select 'Y'
  from per_all_assignments_f paf
  where paf.assignment_id <> cp_skip_assignment_id
    and paf.person_id = cp_person_id
    and cp_effective_date between paf.effective_start_date and paf.effective_end_date
    and per_mx_ssaffl_archive.derive_gre_from_loc_scl(paf.location_id,paf.business_group_id,paf.soft_coding_keyflex_id,cp_effective_date)
      = cp_gre_id ;

  lv_flag                   VARCHAR2(1);

  BEGIN

     lV_flag := 'N' ;
     open c_get_active_asg(p_skip_assignment_id
                          ,p_person_id
                          ,p_gre_id
                          ,p_effective_date );
     fetch c_get_active_asg into lv_flag ;
     if c_get_active_asg%notfound then
        lv_flag :='N' ;
     end if;
     close c_get_active_asg ;

     RETURN (lv_flag) ;

  END chk_active_asg_exists ;


  /******************************************************************************
   Name      : get_rww_ind
   Purpose   : This function returns the reduced working week indicator
  ******************************************************************************/

  PROCEDURE get_rww_ind(p_workschedule    in        varchar2
                       ,p_rww_ind        out nocopy varchar2)
  is

  cursor c_rww(cp_workschedule in varchar2)  is
  select sum(decode(to_number(puci.value),0,0,1))
  from pay_user_column_instances_f puci,
        pay_user_columns puc
  where puc.user_column_name = cp_workschedule
  and puc.legislation_code='MX'
  and puc.user_column_id = puci.user_column_id ;

  ln_rww number ;

  BEGIN

   if p_workschedule is not null then

      open c_rww(p_workschedule) ;
      fetch c_rww into ln_rww ;
      close c_rww ;

      if ln_rww = 7  then
         -- can not be 7 if it is 7 then just assign it to 6
         -- need to check the sum logic will it work for all the values
         ln_rww := 6 ;
      end if;

      p_rww_ind := to_char(ln_rww) ;
   else
      p_rww_ind := null ;
   end if;

  END ;


  /************************************************************************
   Name      : archive_sep_details
   Purpose   : This procedure Archives separation details for the passed
               assignment_action_id and assignment_id
  *************************************************************************/
  PROCEDURE archive_sep_details( p_assignment_action_id  in number
                                ,p_assignment_id         in number
                                ,p_effective_date        in date
                                ,p_tax_unit_id           in number
                                ,p_arch_status           in varchar2
                                ,p_arch_reason           in varchar2
                               )
  IS

  cursor c_get_sep_details (cp_assignment_id in number
                           , cp_effective_date in date )
  is
  select replace(ppf.per_information3,'-','')  emp_ss_number
        ,ppf.last_name            paternal_last_name
        ,ppf.per_information1     maternal_last_name
        ,ppf.first_name || ' ' ||ppf.middle_names   name
        ,ppf.employee_number      worker_id
  from per_all_assignments_f paf,
       per_all_people_f ppf
  where paf.assignment_id = cp_assignment_id
    and paf.person_id = ppf.person_id
    and cp_effective_date between paf.effective_start_date and paf.effective_end_date
    and cp_effective_date between ppf.effective_start_date and ppf.effective_end_date ;

  cursor c_get_er_ss_number(cp_gre_id in number )
  is
  select org_information1
  from hr_organization_information
  where org_information_context= 'MX_SOC_SEC_DETAILS'
  and organization_id = cp_gre_id ;

  cursor c_get_org_information ( cp_organization_id in number)
  is
  select org_information3,org_information5, org_information6
  from hr_organization_information
  where org_information_context= 'MX_SOC_SEC_DETAILS'
  and organization_id = cp_organization_id ;

  cursor c_get_leaving_reason( cp_assignment_id in number
                              ,cp_effective_date in date
                              ,cp_gre_id in number
                             )
  is
  select aei_information3
  from per_assignment_extra_info pae
  where pae.assignment_id = cp_assignment_id
  and information_type = 'MX_SS_EMP_TRANS_REASON'
  and fnd_date.canonical_to_date(aei_information1) = cp_effective_date
  and aei_information2 = cp_gre_id ;

  cursor c_get_pos_leaving_reason(cp_assignment_id in number
                                 ,cp_effective_date in date )
  is
  select pds_information1, actual_termination_date
  from per_periods_of_service ppos,
       per_all_assignments_f paf
  where paf.assignment_id = cp_assignment_id
    and paf.person_id = ppos.person_id
    and cp_effective_date between paf.effective_start_date and paf.effective_end_date
    and pds_information_category='MX' ;


    lv_emp_ss_number         varchar2(240);
    lv_er_ss_number          varchar2(240);
    lv_paternal_last_name    varchar2(240);
    lv_maternal_last_name    varchar2(240);
    lv_name                  varchar2(240);
    lv_worker_id             varchar2(240);
    lv_type_of_tran          varchar2(240);
    lv_imss_way_bill         varchar2(240);
    lv_layout_identifier     varchar2(240);

    lv_leaving_reason        varchar2(240);

    lv_transmitter           VARCHAR2(1);
    ln_way_bill              NUMBER;
    ln_tr_gre_id             NUMBER;

    ln_action_information_id NUMBER ;
    ln_object_version_number NUMBER ;

    lv_procedure_name        VARCHAR2(100) ;
    lv_error_message         VARCHAR2(200) ;
    ln_step                  NUMBER;
    ld_sep_date              DATE ;

  BEGIN

    lv_procedure_name     := '.archive_sep_details';

    dbg('Entering archive_sep_details .........');

    lv_type_of_tran       := '02' ;
    lv_layout_identifier  := '9' ;
    ld_sep_date           :=  p_effective_date-1 ;

    ln_step := 1;
    hr_utility.set_location(gv_package || lv_procedure_name, 10);

    dbg('Get employer ss id ');
    -- get employer ss id for p_tax_unit_id
    open c_get_er_ss_number(p_tax_unit_id) ;
    fetch c_get_er_ss_number into lv_er_ss_number ;
    close c_get_er_ss_number ;

    ln_step := 2;
    hr_utility.set_location(gv_package || lv_procedure_name, 20);

    dbg('Get GRE leaving reason from assignment extra info ');
    -- get GRE leaving reason
    open c_get_leaving_reason( p_assignment_id
                              ,p_effective_date-1
                              ,p_tax_unit_id
                             ) ;
    fetch c_get_leaving_reason into lv_leaving_reason ;
    close c_get_leaving_reason ;
    if lv_leaving_reason is null then
       dbg('Get GRE leaving reason from period of service ');
       -- get it from periods of service
       -- also the effective date passed is not correct
       -- so need to get the actual termination date
       open c_get_pos_leaving_reason(p_assignment_id
                                    ,p_effective_date ) ;
       fetch c_get_pos_leaving_reason into lv_leaving_reason, ld_sep_date ;
       close c_get_pos_leaving_reason ;
    end if;


    ln_step := 3;
    hr_utility.set_location(gv_package || lv_procedure_name, 30);

    dbg('Get IMSS way bill for gre '|| to_char(p_tax_unit_id));

    -- get IMSS Waybill for p_tax_unit_id
    open c_get_org_information ( p_tax_unit_id ) ;
    fetch c_get_org_information into lv_transmitter,
                                     ln_way_bill,
                                     ln_tr_gre_id ;
    close c_get_org_information ;

    dbg('Transmitter flag for this GRE is '|| lv_transmitter);

    if lv_transmitter = 'Y' then
       lv_imss_way_bill:= ln_way_bill ;
     else
       dbg('Null or No then get the waybill number from the trans gre' );
       open c_get_org_information ( ln_tr_gre_id ) ;
       fetch c_get_org_information into lv_transmitter,
                                     ln_way_bill,
                                     ln_tr_gre_id ;
       lv_imss_way_bill:= ln_way_bill ;
       close c_get_org_information ;
    end if;

    dbg('IMSS Waybill Number is '||lv_imss_way_bill );

    ln_step := 4;
    hr_utility.set_location(gv_package || lv_procedure_name, 40);

    dbg('Get separation details from assignment' );
    -- get the asg details from the table
    open c_get_sep_details( p_assignment_id,
                            p_effective_date ) ;
    fetch c_get_sep_details into
             lv_emp_ss_number
            ,lv_paternal_last_name
            ,lv_maternal_last_name
            ,lv_name
            ,lv_worker_id ;

    close c_get_sep_details ;


    ln_step := 5;
    hr_utility.set_location(gv_package || lv_procedure_name, 50);

    msg('Calling the Api to create the separation details with the parameters ');

    msg('Action_information_category : ' || 'MX SS SEPARATION DETAILS' );
    msg('Action Context Id           : ' || to_char(p_assignment_action_id) );
    msg('ER SS Number is    : ' || lv_er_ss_number );
    msg('EE SS Number is    : ' || lv_emp_ss_number );
    msg('Paternal Last Name : ' || lv_paternal_last_name );
    msg('Maternal Last Name : ' || lv_maternal_last_name );
    msg('Name               : ' || lv_name );
    msg('Separation Date    : ' || to_char(ld_sep_date,'DDMMYYYY'));
    msg('transaction type   : ' || lv_type_of_tran );
    msg('IMSS Waybill       : ' || lv_imss_way_bill );
    msg('Worker ID          : ' || lv_worker_id );
    msg('Leaving Reason     : ' || lv_leaving_reason );
    msg('Layout Identifier  : ' || lv_layout_identifier);

    -- call the api to insert the record in pay_action_information
    pay_action_information_api.create_action_information(
                p_action_information_id => ln_action_information_id
               ,p_object_version_number => ln_object_version_number
               ,p_action_information_category => 'MX SS SEPARATION DETAILS'
               ,p_action_context_id    => p_assignment_action_id
               ,p_action_context_type  => 'AAP'
               ,p_jurisdiction_code    => null
               ,p_assignment_id        => p_assignment_id
               ,p_tax_unit_id          => p_tax_unit_id
               ,p_effective_date       => p_effective_date
               ,p_action_information1  => substr(lv_er_ss_number,1,10)
               ,p_action_information2  => substr(lv_er_ss_number,length(lv_er_ss_number),1)
               ,p_action_information3  => substr(lv_emp_ss_number,1,10)
               ,p_action_information4  => substr(lv_emp_ss_number,length(lv_emp_ss_number),1)
               ,p_action_information5  => lv_paternal_last_name
               ,p_action_information6  => lv_maternal_last_name
               ,p_action_information7  => lv_name
               ,p_action_information8  => null    -- filler1
               ,p_action_information9  => to_char(ld_sep_date,'DDMMYYYY')
               ,p_action_information10 => null    -- filler2
               ,p_action_information11 => lv_type_of_tran
               ,p_action_information12 => lv_imss_way_bill
               ,p_action_information13 => lv_worker_id
               ,p_action_information14 => lv_leaving_reason
               ,p_action_information15 => null -- filler3
               ,p_action_information16 => lv_layout_identifier
               ,p_action_information22 => p_arch_status
               ,p_action_information23 => p_arch_reason
                );
    msg('Successfully Archived. Action Information Id is : ' || to_char(ln_action_information_id) );

     ln_step := 10;
     hr_utility.set_location(gv_package || lv_procedure_name, 100);

    dbg('Exiting archive_sep_details .........');

  EXCEPTION
   when others then
      lv_error_message := 'Error at step ' || ln_step || ' in ' ||
                           gv_package || lv_procedure_name;

      dbg(lv_error_message || '-' || sqlerrm);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END archive_sep_details ;


  /*************************************************************************
   Name      : archive_hire_details
   Purpose   : This procedure Archives hire details for the passed
               assignment_action_id and assignment_id
  **************************************************************************/
  PROCEDURE archive_hire_details( p_assignment_action_id  in number
                                 ,p_assignment_id         in number
                                 ,p_effective_date        in date
                                 ,p_tax_unit_id           in number
                                 ,p_arch_status           in varchar2
                                 ,p_arch_reason           in varchar2
                                )
  IS
  cursor c_get_hire_details (cp_assignment_id in number
                           , cp_effective_date in date )
  is
  select replace(ppf.per_information3,'-','')   emp_ss_number
        ,ppf.last_name            paternal_last_name
        ,per_information1         maternal_last_name
        ,ppf.first_name || ' ' || ppf.middle_names   name
        ,substr(employment_category,3,1) worker_type
        ,hsc.segment6             salary_type
        ,puc.user_column_name     work_schedule
        ,per_information4         med_center
        ,employee_number          worker_id
        ,national_identifier      CURP
  from per_all_assignments_f paf,
       per_all_people_f ppf,
       hr_soft_coding_keyflex hsc,
       pay_user_columns puc
  where paf.assignment_id = cp_assignment_id
    and paf.person_id = ppf.person_id
    and paf.soft_coding_keyflex_id = hsc.soft_coding_keyflex_id (+)
    and hsc.segment4 = puc.user_column_id(+)
    and trunc(cp_effective_date) between paf.effective_start_date and paf.effective_end_date
    and trunc(cp_effective_date) between ppf.effective_start_date and ppf.effective_end_date ;

  cursor c_get_er_ss_number(cp_gre_id in number )
  is
  select replace(org_information1,'-','')
  from hr_organization_information
  where org_information_context= 'MX_SOC_SEC_DETAILS'
  and organization_id = cp_gre_id ;

  cursor c_get_org_information ( cp_organization_id in number)
  is
  select org_information3,org_information5, org_information6
  from hr_organization_information
  where org_information_context= 'MX_SOC_SEC_DETAILS'
  and organization_id = cp_organization_id ;


  -- cursor to get the minimum wage for Zone A
  cursor c_minimum_wage_zonea (cp_effective_date in date )
  is
  select legislation_info2
  from pay_mx_legislation_info_f
  where legislation_info_type='MX Minimum Wage Information'
  and legislation_info1='MWA'
  and cp_effective_date between effective_start_date and effective_end_date ;

    lv_emp_ss_number         varchar2(240);
    lv_er_ss_number          varchar2(240);
    lv_paternal_last_name    varchar2(240);
    lv_maternal_last_name    varchar2(240);
    lv_name                  varchar2(240);
    lv_worker_type           varchar2(240);
    lv_salary_type           varchar2(240);
    lv_work_schedule         varchar2(240);
    lv_rww_indicator         varchar2(240);
    lv_med_center            varchar2(240);
    lv_worker_id             varchar2(240);
    lv_CURP                  varchar2(240);

    ln_idw                   NUMBER;
    ln_min_wage              NUMBER;

    ln_fixed_idw             NUMBER;
    ln_variable_idw          NUMBER;

    lv_type_of_tran          varchar2(240);
    lv_imss_way_bill         varchar2(240);
    lv_layout_identifier     varchar2(240);

    lv_transmitter           VARCHAR2(1);
    ln_way_bill              NUMBER;
    ln_tr_gre_id             NUMBER;

    ln_action_information_id NUMBER ;
    ln_object_version_number NUMBER ;

    lv_procedure_name     VARCHAR2(100) ;
    lv_error_message      VARCHAR2(200);
    ln_step               NUMBER;

  BEGIN

    lv_procedure_name     := '.archive_hire_details';

    dbg('Entering Archive hire details.........');

    lv_type_of_tran          := '08' ;
    lv_layout_identifier     := '9' ;


    ln_step := 1;
    hr_utility.set_location(gv_package || lv_procedure_name, 10);

    dbg('Get employer ssid ');
    -- get employer ss id for p_tax_unit_id
    open c_get_er_ss_number(p_tax_unit_id) ;
    fetch c_get_er_ss_number into lv_er_ss_number ;
    close c_get_er_ss_number ;

    ln_step := 2;
    hr_utility.set_location(gv_package || lv_procedure_name, 20);

    dbg('Get IMSS waybill for gre '|| to_char(p_tax_unit_id) );

    -- get IMSS Waybill for p_tax_unit_id
    open c_get_org_information ( p_tax_unit_id ) ;
    fetch c_get_org_information into lv_transmitter,
                                     ln_way_bill,
                                     ln_tr_gre_id ;
    close c_get_org_information ;

    dbg('Transmitter flag for this GRE is '|| lv_transmitter);

    if lv_transmitter = 'Y' then
       lv_imss_way_bill:= ln_way_bill ;
    else

       dbg('Null or No then get the waybill number from the trans gre' );
       open c_get_org_information ( ln_tr_gre_id ) ;
       fetch c_get_org_information into lv_transmitter,
                                     ln_way_bill,
                                     ln_tr_gre_id ;
       lv_imss_way_bill:= ln_way_bill ;
       close c_get_org_information ;
    end if;

    dbg('way bill number is ' || lv_imss_way_bill );

    ln_step := 3;
    hr_utility.set_location(gv_package || lv_procedure_name, 30);

    dbg('Get hire details from assignment ' );
    dbg('Assignment Id  : ' || to_char(p_assignment_id) );
    dbg('Effective Date : ' || to_char(p_effective_date,'DD-MON-YYYY'));

    -- get the asg details from the base table
    open c_get_hire_details(p_assignment_id
                           ,p_effective_date ) ;
    fetch c_get_hire_details into
             lv_emp_ss_number
            ,lv_paternal_last_name
            ,lv_maternal_last_name
            ,lv_name
            ,lv_worker_type
            ,lv_salary_type
            ,lv_work_schedule
            ,lv_med_center
            ,lv_worker_id
            ,lv_CURP ;

     close c_get_hire_details ;

     ln_step := 4;
     hr_utility.set_location(gv_package || lv_procedure_name, 40);

     dbg('Get reduced working week indicator from workschedule ' );

     -- derive Reduced Working-week indicator from workschedule
     if lv_work_schedule is not null then
        get_rww_ind(lv_work_schedule,lv_rww_indicator );
     else
        lv_rww_indicator := null ;
     end if;

     ln_step := 5;
     hr_utility.set_location(gv_package || lv_procedure_name, 50);

     dbg('Get IDW' );

     dbg('Assignment Id   '||to_char(p_assignment_id) );
     dbg('Tax unit Id     '||to_char(p_tax_unit_id) );
     dbg('Effective Date  '||to_char(p_effective_date) );
     dbg('Mode            '||'BIMONTH_REPORT' );

     ln_min_wage := 0 ;

     -- get the minimum wage for Zone A
     /* bug fix 4528984 */
     open c_minimum_wage_zonea (p_effective_date) ;
     fetch c_minimum_wage_zonea into ln_min_wage ;
     close c_minimum_wage_zonea ;

     dbg('Zone A Minimum Wage  '||to_char(ln_min_wage) );

     ln_idw := 0 ;
     ln_idw := pay_mx_ff_udfs.get_idw( p_assignment_id  => p_assignment_id
             ,p_tax_unit_id    => p_tax_unit_id
             ,p_effective_date => p_effective_date
             ,p_mode           => 'BIMONTH_REPORT'
             ,p_fixed_idw      => ln_fixed_idw
             ,p_variable_idw   => ln_variable_idw
             ) ;

     dbg('Calulated IDW from get_idw  '||to_char(ln_idw) );

     -- check the IDW with 25 times of zone A minimum wage
     -- if idw is greater than 25 times of zone A minimum wage then
     --    idw = 25 times of zone A minimum wage
     -- else
     --    idw = calculated one
     -- end if

     if ln_idw > ( 25 * ln_min_wage ) then
        ln_idw := 25 * ln_min_wage ;
     end if;

     dbg('IDW after compared with min wage '||to_char(ln_idw) );

     -- round to 2 decimal and archive
     ln_idw := round(ln_idw,2) ;

     dbg('IDW with 2 decimal  '||to_char(ln_idw) );

     dbg('call api to insert the record in pay action information with parameters' );
     msg('Action_information_category : ' || 'MX SS HIRE DETAILS' );
     msg('Action Context Id           : ' || to_char(p_assignment_action_id) );
     msg('ER SS Number is    : ' || lv_er_ss_number );
     msg('EE SS Number is    : ' || lv_emp_ss_number );
     msg('Paternal Last Name : ' || lv_paternal_last_name );
     msg('Maternal Last Name : ' || lv_maternal_last_name );
     msg('Name               : ' || lv_name );
     msg('IDW                : ' || to_char(ln_idw) );
     msg('Worker Type        : ' || lv_worker_type );
     msg('Salary Type        : ' || lv_salary_type );
     msg('RWW Indicator      : ' || lv_rww_indicator);
     msg('Hire Date          : ' || to_char(p_effective_date,'DDMMYYYY'));
     msg('Med Center         : ' || lv_med_center );
     msg('transaction type   : ' || lv_type_of_tran );
     msg('IMSS Waybill       : ' || lv_imss_way_bill );
     msg('Worker ID          : ' || lv_worker_id );
     msg('CURP               : ' || lv_curp );
     msg('Layout Identifier  : ' || lv_layout_identifier );


     -- call the api to insert the record in pay_action_information
     pay_action_information_api.create_action_information(
                p_action_information_id => ln_action_information_id
               ,p_object_version_number => ln_object_version_number
               ,p_action_information_category => 'MX SS HIRE DETAILS'
               ,p_action_context_id    => p_assignment_action_id
               ,p_action_context_type  => 'AAP'
               ,p_jurisdiction_code    => null
               ,p_assignment_id        => p_assignment_id
               ,p_tax_unit_id          => p_tax_unit_id
               ,p_effective_date       => p_effective_date
               ,p_action_information1  => substr(lv_er_ss_number,1,10)
               ,p_action_information2  => substr(lv_er_ss_number,length(lv_er_ss_number),1)
               ,p_action_information3  => substr(lv_emp_ss_number,1,10)
               ,p_action_information4  => substr(lv_emp_ss_number,length(lv_emp_ss_number),1)
               ,p_action_information5  => lv_paternal_last_name
               ,p_action_information6  => lv_maternal_last_name
               ,p_action_information7  => lv_name
               ,p_action_information8  => to_char(ln_idw)
               ,p_action_information9  => null    -- filler1
               ,p_action_information10 => lv_worker_type
               ,p_action_information11 => lv_salary_type
               ,p_action_information12 => lv_rww_indicator
               ,p_action_information13 => to_char(p_effective_date,'DDMMYYYY')
               ,p_action_information14 => lv_med_center
               ,p_action_information15 => null -- filler2
               ,p_action_information16 => lv_type_of_tran
               ,p_action_information17 => lv_imss_way_bill
               ,p_action_information18 => lv_worker_id
               ,p_action_information19 => null -- filler3
               ,p_action_information20 => lv_curp
               ,p_action_information21 => lv_layout_identifier
               ,p_action_information22 => p_arch_status
               ,p_action_information23 => p_arch_reason
                );

     msg('Successfully Archived. Action Information Id is : ' || to_char(ln_action_information_id) );

    ln_step := 6;
    hr_utility.set_location(gv_package || lv_procedure_name, 100);

    dbg('Exiting archive_hire_details .........');

  EXCEPTION
   when others then
      lv_error_message := 'Error at step ' || ln_step || ' in ' ||
                           gv_package || lv_procedure_name;

      dbg(lv_error_message || '-' || sqlerrm);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END archive_hire_details ;

  /************************************************************
   Name      : arch_hire_separation_data
   Purpose   : This procedure archives the hire and separation details
  ************************************************************/
  PROCEDURE arch_hire_separation_data
                                  ( p_assignment_action_id in number,
                                    p_arch_type          in varchar2,
                                    p_assignment_id      in number,
                                    p_assignment_number  in varchar2,
                                    p_location_id        in number,
                                    p_effective_date     in date,
                                    p_gre_id             in number,
                                    p_error_mesg         in varchar2,
                                    p_event_type         in varchar2
                                   )
  is

  CURSOR c_get_location_code (cp_location_id in number)
  IS
  select location_code
  from hr_locations
  where location_id = cp_location_id ;

  CURSOR c_get_gre_name (cp_gre_id in number)
  IS
  select name
  from hr_organization_units
  where organization_id = cp_gre_id ;


  lv_procedure_name        VARCHAR2(100) ;
  lv_location_code         VARCHAR2(30);
  lv_gre_name              VARCHAR2(100);
  lv_error_message         VARCHAR2(200);
  ln_step                  NUMBER;

  BEGIN


  lv_procedure_name     := '.arch_hire_separation_data';
  hr_utility.set_location(gv_package || lv_procedure_name, 10);
  ln_step := 1;

  dbg('Entering arch_hire_separation_data .........');

  if p_arch_type='E' then

     open c_get_location_code(p_location_id) ;
     fetch c_get_location_code into lv_location_code ;
     close c_get_location_code ;

     if p_error_mesg = '1' then

        msg('Error : ' || p_assignment_number || ' assignment ' || lv_location_code
                    || ' location is assigned to multiple GREs in the Generic Hierarchy' );
        pay_core_utils.push_message(800,'HR_MX_GRE_AMBIGUOUS','F') ;
     else
        msg('Error : ' || p_assignment_number || ' assignment ' || lv_location_code
                    || ' location is not assigned to a GRE in the Generic Hierarchy' );
        pay_core_utils.push_message(800,'HR_MX_LOC_MISSING_GEN_HIER','F') ;

     end if;
     pay_core_utils.push_token('LOC_CODE',lv_location_code) ;
     pay_core_utils.push_token('ASG_NUMBER',p_assignment_number) ;

  else

     open c_get_gre_name(p_gre_id) ;
     fetch c_get_gre_name into lv_gre_name ;
     close c_get_gre_name ;

     if p_arch_type ='H' then
        msg('Archiving Hire details for assignment number ' || p_assignment_number );
        msg('GRE           : ' || lv_gre_name );
        msg('Assignment Id : ' || to_char(p_assignment_id) ) ;
        msg('GRE Id        : ' || to_char(p_gre_id) ) ;
        -- call the archive_hire_details to insert into pay_action_information table
        archive_hire_details( p_assignment_action_id  => p_assignment_action_id
                             ,p_assignment_id         => p_assignment_id
                             ,p_effective_date        => p_effective_date
                             ,p_tax_unit_id           => p_gre_id
                             ,p_arch_status           => 'A'
                             ,p_arch_reason           => 'Archived'
                            ) ;
      elsif p_arch_type='S' then
        msg('Archiving Separation details for assignment number ' || p_assignment_number );
        msg('GRE           : ' || lv_gre_name );
        msg('Assignment Id : ' || to_char(p_assignment_id ) ) ;
        msg('GRE Id        : ' || to_char(p_gre_id ) ) ;
        -- call the archive_sep_details to insert into pay_action_information table
        archive_sep_details( p_assignment_action_id  => p_assignment_action_id
                            ,p_assignment_id         => p_assignment_id
                            ,p_effective_date        => p_effective_date
                            ,p_tax_unit_id           => p_gre_id
                            ,p_arch_status           => 'A'
                            ,p_arch_reason           => 'Archived'
                           ) ;

      elsif p_arch_type='R' then
        msg('Archiving Reverse Terminataion Rehire details for assignment number ' || p_assignment_number );
        msg('GRE           : ' || lv_gre_name );
        msg('Assignment Id : ' || to_char(p_assignment_id) ) ;
        msg('GRE Id        : ' || to_char(p_gre_id) ) ;
        -- call the archive_hire_details to insert into pay_action_information table
        archive_hire_details( p_assignment_action_id  => p_assignment_action_id
                             ,p_assignment_id         => p_assignment_id
                             ,p_effective_date        => p_effective_date
                             ,p_tax_unit_id           => p_gre_id
                             ,p_arch_status           => 'R'
                             ,p_arch_reason           => 'Reverse Termination Rehired'
                            ) ;
      end if;
  end if;


  hr_utility.set_location(gv_package || lv_procedure_name, 100);
  dbg('Exiting arch_hire_separation_data .........');

  EXCEPTION
   when others then
      lv_error_message := 'Error at step ' || ln_step || ' in ' ||
                           gv_package || lv_procedure_name;
      dbg(lv_error_message || '-' || sqlerrm);
      hr_utility.raise_error;

  END arch_hire_separation_data;

  /************************************************************
   Name      : process_insert_event
   Purpose   : This procedure process insert event.
               This procedure is called
               from interpret_all_asg_events procedure
  ************************************************************/
  PROCEDURE process_insert_event(
                 p_assignment_action_id  in number
                ,p_assignment_id   in number
                ,p_effective_date  in date
                )
  IS

  -- Cursor to check the record exist in the archive table
  cursor c_chk_archive ( cp_person_id in number,
                         cp_gre_id    in number,
                         cp_effective_date date,
                         cp_action_info_category varchar2 )
  is
  select 'Y'
  from pay_action_information pai,
       per_all_assignments_f paf
  where pai.action_context_type ='AAP'
   and  pai.action_information_category = cp_action_info_category
   and  pai.tax_unit_id = cp_gre_id
   and  pai.assignment_id = paf.assignment_id
   and  paf.person_id = cp_person_id
   and  cp_effective_date between paf.effective_start_date and paf.effective_end_date
   order by pai.effective_date desc ;


  cursor c_asg_details(cp_assignment_id  in number,
                       cp_effective_date in date )
  is
  select paf.person_id,
         paf.assignment_number,
         paf.location_id,
         paf.soft_coding_keyflex_id,
         paf.business_group_id
  from per_all_assignments_f paf
  where paf.assignment_id = cp_assignment_id
    and cp_effective_date between paf.effective_start_date
       and paf.effective_end_date ;

  ln_gre_id                    NUMBER  ;
  ln_person_id                 NUMBER  ;
  lv_assignment_number         VARCHAR2(30);
  ln_location_id               NUMBER ;
  ln_soft_coding_keyflex_id    NUMBER ;
  ln_business_group_id         NUMBER ;
  lv_gre_error_mesg            VARCHAR2(100);
  lv_chk                       VARCHAR2(1);

  lv_asg_flag                  VARCHAR2(1);

  lv_procedure_name            VARCHAR2(100);
  lv_error_message             VARCHAR2(200);
  ln_step                      NUMBER;

  BEGIN

     dbg('Entering process insert event..........' );

     lv_procedure_name         := '.process_insert_event';

     hr_utility.set_location(gv_package || lv_procedure_name, 10);
     ln_step := 1;
     dbg('Get assignment details ' );

     open c_asg_details( p_assignment_id,
                         p_effective_date ) ;
     fetch c_asg_details into ln_person_id,
                              lv_assignment_number,
                              ln_location_id,
                              ln_soft_coding_keyflex_id,
                              ln_business_group_id;
     close c_asg_details ;

     hr_utility.set_location(gv_package || lv_procedure_name, 20);
     ln_step := 2;
     dbg('Dervie GRE from location and SCL ' );
     ln_gre_id := derive_gre_from_loc_scl( ln_location_id
                                          ,ln_business_group_id
                                          ,ln_soft_coding_keyflex_id
                                          ,p_effective_date   ) ;

     hr_utility.set_location(gv_package || lv_procedure_name, 30);
     ln_step := 3;

     if ln_gre_id = -1 or ln_gre_id = -2 then
        if ln_gre_id = -1 then
           lv_gre_error_mesg := g_ambiguous_error ;
        else
           lv_gre_error_mesg := g_missing_gre_error ;
        end if;

        arch_hire_separation_data(p_assignment_action_id   => p_assignment_action_id,
                               p_arch_type              => 'E',
                               p_assignment_id          => p_assignment_id,
                               p_assignment_number      => lv_assignment_number,
                               p_location_id            => ln_location_id,
                               p_effective_date         => p_effective_date,
                               p_gre_id                 => null,
                               p_error_mesg             => lv_gre_error_mesg,
                               p_event_type             => 'I'
                              ) ;
        dbg('Error in deriving GRE for ' || to_char(ln_location_id) );
        return ;

     end if ;

     hr_utility.set_location(gv_package || lv_procedure_name, 40);
     ln_step := 4;

     -- Check record exists in Archive table for person_id, gre_id,
     -- effective_date, hire_category

     dbg('Check record exists in archive table with HIRE as info category' );
     dbg(' person id            = '||to_char(ln_person_id) );
     dbg(' gre id               = '||to_char(ln_gre_id) );
     dbg(' eff date             = '||to_char(p_effective_date,'DD-MON-YYYY') );
     dbg(' Action info category = ' ||g_action_hire_category );

     open c_chk_archive ( ln_person_id, ln_gre_id, p_effective_date, g_action_hire_category ) ;
     fetch c_chk_archive into lv_chk ;
     if c_chk_archive%found then

        -- if record found then
        dbg('HIRE record exists in archive table');

        close c_chk_archive ;

        -- Check the separation record exists in archive table for
        -- person_id, ger_id, effective_date, sep_category

        hr_utility.set_location(gv_package || lv_procedure_name, 50);
        ln_step := 5;

        dbg('Check record exists in archive table with SEPARATION as info category' );
        dbg(' person id            = '||to_char(ln_person_id) );
        dbg(' gre id               = '||to_char(ln_gre_id) );
        dbg(' eff date             = '||to_char(p_effective_date,'DD-MON-YYYY') );
        dbg(' Action info category = '||g_action_sep_category );

        open c_chk_archive ( ln_person_id, ln_gre_id, p_effective_date, g_action_sep_category ) ;
        fetch c_chk_archive into lv_chk ;
        if c_chk_archive%found then

           -- if it is there then event is a rehire
           dbg('SEPARATION record found then it is a rehire record' );
           dbg('Archieve data as arch_type = H ');

           arch_hire_separation_data(p_assignment_action_id   => p_assignment_action_id,
                                  p_arch_type              => 'H',
                                  p_assignment_id          => p_assignment_id,
                                  p_assignment_number      => lv_assignment_number,
                                  p_location_id            => ln_location_id,
                                  p_effective_date         => p_effective_date,
                                  p_gre_id                 => ln_gre_id ,
                                  p_error_mesg             => null,
                                  p_event_type             => 'I'
                                 ) ;
        end if;
        close c_chk_archive ;

     else
        close c_chk_archive ;

        hr_utility.set_location(gv_package || lv_procedure_name, 60);

        -- record does not exists in archive table
        dbg('HIRE Record not found in archive table');

        -- find out this person is reported to IMSS prior to g_report_imp_date by legacy system
        -- by looking at assignment records

        dbg('Check this person is reported to IMSS prior to rep imp date ' );
        dbg(' person id            = '||to_char(ln_person_id) );
        dbg(' gre id               = '||to_char(ln_gre_id) );
        dbg(' eff date             = '||to_char(g_report_imp_date-1,'DD-MON-YYYY') );

        lv_asg_flag := chk_active_asg_exists( p_assignment_id
                              ,ln_person_id
                              ,ln_gre_id
                              ,g_report_imp_date-1
                             ) ;
        if lv_asg_flag ='N' then
           dbg('record not found ' );
            -- record does not exists
            -- this person NOT reported by legacy system
            -- so write to hire plsql table
            dbg('Archive data as arch_type = H ');
            arch_hire_separation_data(p_assignment_action_id   => p_assignment_action_id,
                                  p_arch_type          => 'H',
                                  p_assignment_id      => p_assignment_id,
                                  p_assignment_number  => lv_assignment_number,
                                  p_location_id        => ln_location_id,
                                  p_effective_date     => p_effective_date,
                                  p_gre_id             => ln_gre_id ,
                                  p_error_mesg         => null,
                                  p_event_type         => 'I'
                                 );
        end if;

    end if ;

    hr_utility.set_location(gv_package || lv_procedure_name, 100);
    ln_step := 6;

    dbg('Exiting process insert event..........' );

  exception
    when others then
      lv_error_message := 'Error at step ' || ln_step ||
                          ' in ' || gv_package || lv_procedure_name;
      dbg(lv_error_message || '-' || sqlerrm);
      hr_utility.raise_error;

  END process_insert_event ;

  /************************************************************
   Name      : process_correction_event
   Purpose   : This procedure process correction event.
               This procedure is called
               from interpret_all_asg_events procedure
  ************************************************************/
  PROCEDURE process_correction_event
                                  ( p_assignment_action_id  in number
                                   ,p_assignment_id   in number
                                   ,p_effective_date  in date
                                   ,p_column_name     in varchar
                                   ,p_old_value       in number
                                   ,p_new_value       in number
                                   ,p_column_name1    in varchar
                                   ,p_old_value1      in number
                                   ,p_new_value1      in number
                                   )
  IS

  -- Cursor to get person details
  cursor c_person_details(cp_assignment_id  in number,
                       cp_effective_date in date )
  is
  select person_id,
         assignment_number,
         location_id,
         soft_coding_keyflex_id,
         business_group_id
  from per_all_assignments_f paf
  where paf.assignment_id = cp_assignment_id
    and cp_effective_date between paf.effective_start_date
       and paf.effective_end_date ;


  -- Cursor to check the record exist in the archive table
  cursor c_chk_archive ( cp_person_id in number,
                         cp_gre_id    in number,
                         cp_effective_date date,
                         cp_action_info_category varchar2 )
  is
  select 'Y'
  from pay_action_information pai,
       per_all_assignments_f paf
  where pai.action_context_type ='AAP'
   and  pai.action_information_category = cp_action_info_category
   and  pai.tax_unit_id = cp_gre_id
   and  pai.assignment_id = paf.assignment_id
   and  paf.person_id = cp_person_id
   and  cp_effective_date between paf.effective_start_date and paf.effective_end_date
   order by pai.effective_date desc ;


  l_is_ambiguous               BOOLEAN ;
  l_missing_gre                BOOLEAN ;
  ln_old_gre_id                NUMBER  ;
  ln_new_gre_id                NUMBER  ;
  ln_person_id                 NUMBER  ;
  ln_business_group_id         NUMBER  ;
  lv_assignment_number         VARCHAR2(30);
  lv_gre_error_mesg            VARCHAR2(100);
  lv_chk                       VARCHAR2(1);

  lv_asg_flag                  VARCHAR2(1);

  ln_location_id               NUMBER ;
  ln_soft_coding_keyflex_id    NUMBER ;
  ln_old_value                 NUMBER ;
  ln_new_value                 NUMBER ;
  ln_old_value1                NUMBER ;
  ln_new_value1                NUMBER ;

  lv_procedure_name            VARCHAR2(100) ;
  lv_error_message             VARCHAR2(200);
  ln_step                      NUMBER;

  BEGIN

   dbg('Entering process correction event..............');

   ln_step := 1;
   hr_utility.set_location(gv_package || lv_procedure_name, 10);

   -- assign the values to local variable

   lv_procedure_name           := '.process_correction_event';

   ln_old_value                := p_old_value ;
   ln_new_value                := p_new_value ;
   ln_old_value1               := p_old_value1 ;
   ln_new_value1               := p_new_value1 ;

   dbg('Get person details ' );

   -- get the person_id for this assignment
   open c_person_details(p_assignment_id,
                         p_effective_date ) ;

   fetch c_person_details into ln_person_id, lv_assignment_number,
                          ln_location_id,ln_soft_coding_keyflex_id,
                          ln_business_group_id;

   close c_person_details ;

   -- If the user made the correction only on location_id then
   --    p_old_value = old value of location id
   --    p_new_value = new value of location id will be passed
   -- else if the user made the correction only on soft_coding_keyflex_id then
   --    p_old_value1 = old value of soft_coding_keyflex_id
   --    p_new_value1 = new value of soft_coding_keyflex_id will be passed

   -- Check location id  is null
   -- if it is null then the user did not update the
   -- location id so get it from the table and assign
   -- old and new value equal to the table value

   if p_old_value is null and p_new_value is null then

      dbg('Assigning location id from table values');

      ln_old_value := ln_location_id ;
      ln_new_value := ln_location_id ;
   end if;

   -- Check soft coding key flex value is null
   -- if it is null then the user did not update the
   -- soft coding keyflex so get it from table and assign
   -- old and new value equal to the table value

   if p_old_value1 is null and p_new_value1 is null then

      dbg('Assigning soft coding keyflex id from table values');

      ln_old_value1 := ln_soft_coding_keyflex_id ;
      ln_new_value1 := ln_soft_coding_keyflex_id ;
   end if;

   dbg('After the values got from the table values');
   dbg('Column Name    :' || 'LOCATION_ID' );
   dbg('Old Value      :' || to_char(ln_old_value) );
   dbg('new Value      :' || to_char(ln_new_value) );
   dbg('Column Name    :' || 'SOFT_CODING_KEYFLEX_ID' );
   dbg('Old Value      :' || to_char(ln_old_value1) );
   dbg('new Value      :' || to_char(ln_new_value1) );


   dbg('Dervie old GRE from old location and old SCL ' );
   ln_old_gre_id := derive_gre_from_loc_scl( ln_old_value
                                            ,ln_business_group_id
                                            ,ln_old_value1
                                            ,p_effective_date   ) ;
   hr_utility.set_location(gv_package || lv_procedure_name, 30);
   ln_step := 2;

   if ln_old_gre_id = -1 or ln_old_gre_id = -2 then
      if ln_old_gre_id = -1 then
         lv_gre_error_mesg := g_ambiguous_error ;
      else
         lv_gre_error_mesg := g_missing_gre_error ;
      end if;

        dbg('Error in deriving GRE for OLD Location ' );
        msg('Error in deriving GRE for OLD Location ' );

        arch_hire_separation_data(p_assignment_action_id   => p_assignment_action_id,
                               p_arch_type              => 'E',
                               p_assignment_id          => p_assignment_id,
                               p_assignment_number      => lv_assignment_number,
                               p_location_id            => ln_old_value,
                               p_effective_date         => p_effective_date,
                               p_gre_id                 => null,
                               p_error_mesg             => lv_gre_error_mesg,
                               p_event_type             => 'C'
                              ) ;

   end if ;

   dbg('Dervie New GRE from new location and new SCL ' );
   ln_new_gre_id := derive_gre_from_loc_scl( ln_new_value
                                            ,ln_business_group_id
                                            ,ln_new_value1
                                            ,p_effective_date   ) ;
   hr_utility.set_location(gv_package || lv_procedure_name, 30);
   ln_step := 3;

   if ln_new_gre_id = -1 or ln_new_gre_id = -2 then
      if ln_new_gre_id = -1 then
         lv_gre_error_mesg := g_ambiguous_error ;
      else
         lv_gre_error_mesg := g_missing_gre_error ;
      end if;

      dbg('Error in deriving GRE for NEW Location ' );
      msg('Error in deriving GRE for NEW Location ' );

      arch_hire_separation_data(p_assignment_action_id   => p_assignment_action_id,
                               p_arch_type              => 'E',
                               p_assignment_id          => p_assignment_id,
                               p_assignment_number      => lv_assignment_number,
                               p_location_id            => ln_new_value,
                               p_effective_date         => p_effective_date,
                               p_gre_id                 => null,
                               p_error_mesg             => lv_gre_error_mesg,
                               p_event_type             => 'C'
                              ) ;
   end if ;

   ln_step := 4;

   dbg('old GRE : ' || to_char(ln_old_gre_id) );
   dbg('new GRE : ' || to_char(ln_new_gre_id) );


   if (ln_old_gre_id is not null  and
      ln_new_gre_id is  not null and
      ln_old_gre_id = ln_new_gre_id ) then

      hr_utility.set_location(gv_package || lv_procedure_name, 50);
      dbg('old and new GREs are same no need to process');

      Return ;

   end if;


   ln_step := 5;
   hr_utility.set_location(gv_package || lv_procedure_name, 70);

   -- if old gre is not null then process for old GRE
   if  ln_old_gre_id <> -1 and ln_old_gre_id <> -2 and ln_old_gre_id is not null then
   dbg('Process for old GRE ' );
   -- check record exists in Archive table with old GRE, person id, effective_date
   dbg('Check record is archived in archive table with HIRE as info category' );
   dbg(' person id            = '||to_char(ln_person_id) );
   dbg(' gre id               = '||to_char(ln_old_gre_id) );
   dbg(' eff date             = '||to_char(p_effective_date,'DD-MON-YYYY') );
   dbg(' Action info category = ' ||g_action_hire_category );

   open c_chk_archive ( ln_person_id, ln_old_gre_id, p_effective_date, g_action_hire_category ) ;
   fetch c_chk_archive into lv_chk ;
   if c_chk_archive%found then
      close c_chk_archive ;
      -- record exists then this person already reported with old GRE
      dbg('record found this person already reported with old GRE' );
      -- do we want to separate from old GRE A
      -- if yes then check any other active assignments with old GRE
      dbg('Check any other active assignments exists for this employee ' );
      dbg(' assignment id        = '||to_char(p_assignment_id) );
      dbg(' person id            = '||to_char(ln_person_id) );
      dbg(' gre id               = '||to_char(ln_old_gre_id) );
      dbg(' eff date             = '||to_char(p_effective_date,'DD-MON-YYYY') );

      lv_asg_flag := chk_active_asg_exists( p_assignment_id
                            ,ln_person_id
                            ,ln_old_gre_id
                            ,p_effective_date
                           ) ;
      if lv_asg_flag ='N' then
         -- no record found then archive separation data
        dbg('no active assignments found so archive data as arch_type=S ' );
        arch_hire_separation_data(p_assignment_action_id   => p_assignment_action_id
                             ,p_arch_type         => 'S'
                             ,p_assignment_id      => p_assignment_id
                             ,p_assignment_number  => lv_assignment_number
                             ,p_location_id        => ln_old_value
                             ,p_effective_date     => p_effective_date
                             ,p_gre_id             => ln_old_gre_id
                             ,p_error_mesg         => null
                             ,p_event_type         => 'C'
                             ) ;

      end if;

   end if;

   end if; -- process for old gre

   ln_step := 6;
   hr_utility.set_location(gv_package || lv_procedure_name, 80);


   -- if new gre id is not null then process for the new GRE
   if ln_new_gre_id <> -1 and ln_new_gre_id <> -2 and ln_new_gre_id is not null then
      dbg('Process for the new GRE ' );
      -- check any other active assignments with new GRE
      -- if yes then no need to archive
      -- if no then archive hire details
      dbg('Check any other active assignments exists for this employee ' );
      dbg(' assignment id        = '||to_char(p_assignment_id) );
      dbg(' person id            = '||to_char(ln_person_id) );
      dbg(' gre id               = '||to_char(ln_new_gre_id) );
      dbg(' eff date             = '||to_char(p_effective_date,'DD-MON-YYYY') );

      lv_asg_flag := chk_active_asg_exists( p_assignment_id
                            ,ln_person_id
                            ,ln_new_gre_id
                            ,p_effective_date
                           ) ;
      if lv_asg_flag ='N' then
         -- write in plsql table with hire
         dbg('no active assignments found so archive data as arch_type=H ' );
         arch_hire_separation_data(p_assignment_action_id   => p_assignment_action_id
                               ,p_arch_type          => 'H'
                               ,p_assignment_id      => p_assignment_id
                               ,p_assignment_number  => lv_assignment_number
                               ,p_location_id        => ln_new_value
                               ,p_effective_date     => p_effective_date
                               ,p_gre_id             => ln_new_gre_id
                               ,p_error_mesg         => null
                               ,p_event_type         => 'C'
                               ) ;
      end if;

   end if; -- process for new gre

   ln_step := 7;
   hr_utility.set_location(gv_package || lv_procedure_name, 100);

   dbg('Exiting process correction event..........' );

  exception
    when others then
      lv_error_message := 'Error at step ' || ln_step ||
                          ' in ' || gv_package || lv_procedure_name;
      dbg(lv_error_message || '-' || sqlerrm);
      hr_utility.raise_error;

   END process_correction_event;


  /************************************************************
   Name      : process_update_event
   Purpose   : This procedure process the update event.
               This procedure is called
               from interpret_all_asg_events procedure
  ************************************************************/
  PROCEDURE process_update_event  ( p_assignment_action_id  in number
                                   ,p_assignment_id   in number
                                   ,p_effective_date  in date
                                   ,p_column_name     in varchar
                                   ,p_old_value       in number
                                   ,p_new_value       in number
                                   ,p_column_name1    in varchar
                                   ,p_old_value1      in number
                                   ,p_new_value1      in number
                                   )
  IS

  -- Cursor to get person details
  cursor c_person_details(cp_assignment_id  in number,
                       cp_effective_date in date )
  is
  select person_id,
         assignment_number,
         location_id,
         soft_coding_keyflex_id,
         business_group_id
  from per_all_assignments_f paf
  where paf.assignment_id = cp_assignment_id
    and cp_effective_date between paf.effective_start_date
       and paf.effective_end_date ;

  -- Cursor to check the record exist in the archive table
  cursor c_chk_archive ( cp_person_id in number,
                         cp_gre_id    in number,
                         cp_effective_date date,
                         cp_action_info_category varchar2 )
  is
  select 'Y'
  from pay_action_information pai,
       per_all_assignments_f paf
  where pai.action_context_type ='AAP'
   and  pai.action_information_category = cp_action_info_category
   and  pai.tax_unit_id = cp_gre_id
   and  pai.assignment_id = paf.assignment_id
   and  cp_effective_date between paf.effective_start_date and paf.effective_end_date
   and  paf.person_id = CP_PERSON_ID
   order by pai.effective_date desc ;


  l_is_ambiguous               BOOLEAN ;
  l_missing_gre                BOOLEAN ;
  ln_old_gre_id                NUMBER  ;
  ln_new_gre_id                NUMBER  ;
  ln_person_id                 NUMBER  ;
  lv_assignment_number         VARCHAR2(30);
  lv_gre_error_mesg            VARCHAR2(100);
  lv_chk                       VARCHAR2(1);
  lv_asg_flag                  VARCHAR2(1);

  ln_location_id               NUMBER ;
  ln_business_group_id         NUMBER ;
  ln_soft_coding_keyflex_id    NUMBER ;
  ln_old_value                 NUMBER ;
  ln_new_value                 NUMBER ;
  ln_old_value1                NUMBER ;
  ln_new_value1                NUMBER ;

  lv_procedure_name            VARCHAR2(100);
  lv_error_message             VARCHAR2(200);
  ln_step                      NUMBER;

   BEGIN

    dbg('Entering process_update_event ..........');

    ln_step := 1;

    -- assign the values to local variable
    lv_procedure_name            := '.process_update_event';

    ln_old_value                := p_old_value ;
    ln_new_value                := p_new_value ;
    ln_old_value1               := p_old_value1 ;
    ln_new_value1               := p_new_value1 ;

    hr_utility.set_location(gv_package || lv_procedure_name, 10);
    dbg('Get person details ' );

   -- get the person_id for this assignment
   open c_person_details(p_assignment_id,
                         p_effective_date ) ;
   fetch c_person_details into ln_person_id, lv_assignment_number,
                          ln_location_id,ln_soft_coding_keyflex_id,
                          ln_business_group_id;
   close c_person_details ;

   -- If the user made the update only on location_id then
   --    p_old_value = old value of location id
   --    p_new_value = new value of location id will be passed
   -- else if the user made the update only on soft_coding_keyflex_id then
   --    p_old_value1 = old value of soft_coding_keyflex_id
   --    p_new_value1 = new value of soft_coding_keyflex_id will be passed

   -- Check location id  is null
   -- if it is null then the user did not update the
   -- location id so get it from the table and assign
   -- old and new value equal to the table value

   if p_old_value is null and p_new_value is null then

      dbg('Assigning location id from table values');

      ln_old_value := ln_location_id ;
      ln_new_value := ln_location_id ;
   end if;

   -- Check soft coding key flex value is null
   -- if it is null then the user did not update the
   -- soft coding keyflex so get it from table and assign
   -- old and new value equal to the table value

   if p_old_value1 is null and p_new_value1 is null then

      dbg('Assigning soft coding keyflex id from table values');

      ln_old_value1 := ln_soft_coding_keyflex_id ;
      ln_new_value1 := ln_soft_coding_keyflex_id ;
   end if;

   dbg('After the values got from the table values');
   dbg('Column Name    :' || 'LOCATION_ID' );
   dbg('Old Value      :' || to_char(ln_old_value) );
   dbg('new Value      :' || to_char(ln_new_value) );
   dbg('Column Name    :' || 'SOFT_CODING_KEYFLEX_ID' );
   dbg('Old Value      :' || to_char(ln_old_value1) );
   dbg('new Value      :' || to_char(ln_new_value1) );


   dbg('Dervie old GRE from old location and old SCL ' );
   ln_old_gre_id := derive_gre_from_loc_scl( ln_old_value
                                            ,ln_business_group_id
                                            ,ln_old_value1
                                            ,p_effective_date   ) ;
   hr_utility.set_location(gv_package || lv_procedure_name, 30);
   ln_step := 2;

   if ln_old_gre_id = -1 or ln_old_gre_id = -2 then
      if ln_old_gre_id = -1 then
         lv_gre_error_mesg := g_ambiguous_error ;
      else
         lv_gre_error_mesg := g_missing_gre_error ;
      end if;

        dbg('Error in deriving GRE for OLD Location ' );
        msg('Error in deriving GRE for OLD Location ' );

        arch_hire_separation_data(p_assignment_action_id   => p_assignment_action_id,
                               p_arch_type              => 'E',
                               p_assignment_id          => p_assignment_id,
                               p_assignment_number      => lv_assignment_number,
                               p_location_id            => ln_old_value,
                               p_effective_date         => p_effective_date,
                               p_gre_id                 => null,
                               p_error_mesg             => lv_gre_error_mesg,
                               p_event_type             => 'C'
                              ) ;

   end if ;

   dbg('Dervie New GRE from new location and new SCL ' );
   ln_new_gre_id := derive_gre_from_loc_scl( ln_new_value
                                            ,ln_business_group_id
                                            ,ln_new_value1
                                            ,p_effective_date   ) ;
   hr_utility.set_location(gv_package || lv_procedure_name, 30);
   ln_step := 3;

   if ln_new_gre_id = -1 or ln_new_gre_id = -2 then
      if ln_new_gre_id = -1 then
         lv_gre_error_mesg := g_ambiguous_error ;
      else
         lv_gre_error_mesg := g_missing_gre_error ;
      end if;


        dbg('Error in deriving GRE for NEW Location ' );
        msg('Error in deriving GRE for NEW Location ' );

        arch_hire_separation_data(p_assignment_action_id   => p_assignment_action_id,
                               p_arch_type              => 'E',
                               p_assignment_id          => p_assignment_id,
                               p_assignment_number      => lv_assignment_number,
                               p_location_id            => ln_new_value,
                               p_effective_date         => p_effective_date,
                               p_gre_id                 => null,
                               p_error_mesg             => lv_gre_error_mesg,
                               p_event_type             => 'C'
                              ) ;
    end if ;

    ln_step := 4;

    dbg('old GRE : ' || to_char(ln_old_gre_id) );
    dbg('new GRE : ' || to_char(ln_new_gre_id) );

    if (ln_old_gre_id is not null and
       ln_new_gre_id  is not null and
       ln_old_gre_id = ln_new_gre_id) then

       hr_utility.set_location(gv_package || lv_procedure_name, 60);
       dbg('old and new GREs are same no need to process');

       Return ;

    end if;


    if  ln_old_gre_id <> -1 and ln_old_gre_id <> -2 and ln_old_gre_id is not null then
        -- process for old GRE
        dbg('Process for old GRE ' );

        -- Check any other active assignments exists with old_gre_id for this person_id
        dbg('Check any other active assignments exists for this employee ' );
        dbg(' assignment id        = '||to_char(p_assignment_id) );
        dbg(' person id            = '||to_char(ln_person_id) );
        dbg(' gre id               = '||to_char(ln_old_gre_id) );
        dbg(' eff date             = '||to_char(g_report_imp_date-1,'DD-MON-YYYY') );

        lv_asg_flag := chk_active_asg_exists( p_assignment_id
                              ,ln_person_id
                              ,ln_old_gre_id
                              ,g_report_imp_date-1
                             ) ;
        if lv_asg_flag ='N' then
           dbg('no active assignments found so archive data as arch_type=S ' );
           arch_hire_separation_data( p_assignment_action_id   => p_assignment_action_id,
                                   p_arch_type          => 'S',
                                   p_assignment_id      => p_assignment_id,
                                   p_assignment_number  => lv_assignment_number,
                                   p_location_id        => ln_old_value,
                                   p_effective_date     => p_effective_date,
                                   p_gre_id             => ln_old_gre_id,
                                   p_error_mesg         => lv_gre_error_mesg,
                                   p_event_type         => 'U'
                                 ) ;
         end if ;
         hr_utility.set_location(gv_package || lv_procedure_name, 80);

    end if; -- old gre

    if ln_new_gre_id <> -1 and ln_new_gre_id <> -2 and ln_new_gre_id is not null then

       -- process for new GRE
       dbg('Process for new GRE ' );
       -- check record exists in Archive table for person_id, new_gre_id and effective_date
       dbg('Check record is archived in archive table with HIRE as info category' );
       dbg(' person id            = '||to_char(ln_person_id) );
       dbg(' gre id               = '||to_char(ln_new_gre_id) );
       dbg(' eff date             = '||to_char(p_effective_date,'DD-MON-YYYY') );
       dbg(' Action info category = ' ||g_action_hire_category );
       open c_chk_archive( ln_person_id, ln_new_gre_id, p_effective_date, g_action_hire_category ) ;
       fetch c_chk_archive into lv_chk ;
       if c_chk_archive%notfound then
          close c_chk_archive ;
          -- record not found then
         dbg('HIRE Record not found in archive table');
         -- find out this person is reported to IMSS prior to g_report_imp_date by legacy system
         -- by looking at assignment records
         dbg('Check this person is reported to IMSS prior to rep imp date ' );
         dbg(' person id            = '||to_char(ln_person_id) );
         dbg(' gre id               = '||to_char(ln_new_gre_id) );
         dbg(' eff date             = '||to_char(g_report_imp_date-1,'DD-MON-YYYY') );

         lv_asg_flag := chk_active_asg_exists( p_assignment_id
                             ,ln_person_id
                             ,ln_new_gre_id
                             ,g_report_imp_date-1
                           ) ;
         if lv_asg_flag ='N' then
            -- archive the data
            dbg('Not reported to IMSS so write in arch plsql table arch_type=H ');
            arch_hire_separation_data(p_assignment_action_id   => p_assignment_action_id,
                                   p_arch_type          => 'H',
                                   p_assignment_id      => p_assignment_id,
                                   p_assignment_number  => lv_assignment_number,
                                   p_location_id        => ln_new_value,
                                   p_effective_date     => p_effective_date,
                                   p_gre_id             => ln_new_gre_id ,
                                   p_error_mesg         => null,
                                   p_event_type         => 'U'
                                 ) ;
         end if;
       end if ; -- chk_archive
     end if ; -- new gre

     ln_step := 5;
     hr_utility.set_location(gv_package || lv_procedure_name, 100);

     dbg('Exiting process update event..........' );

  exception
    when others then
      lv_error_message := 'Error at step ' || ln_step ||
                          ' in ' || gv_package || lv_procedure_name;
      dbg(lv_error_message || '-' || sqlerrm);

      hr_utility.raise_error;

  END process_update_event;


  /************************************************************
   Name      : process_enddate_event
   Purpose   : This procedure process enddate event.
               This procedure is called
               from interpret_all_asg_events procedure
  ************************************************************/
  PROCEDURE process_enddate_event( p_assignment_action_id  in number
                                  ,p_assignment_id   in number
                                  ,p_effective_date  in date
                                  ,p_old_value       in varchar2
                                  ,p_new_value       in varchar2
                                 )
  IS

  cursor c_asg_details(cp_assignment_id  in number,
                       cp_effective_date in date )
  is
  select paf.person_id,paf.assignment_number,paf.location_id,
         paf.soft_coding_keyflex_id, pas.per_system_status,
         paf.business_group_id
  from per_all_assignments_f paf,
       per_assignment_status_types pas
  where paf.assignment_id = cp_assignment_id
    and pas.assignment_status_type_id = paf.assignment_status_type_id
    and cp_effective_date between paf.effective_start_date
       and paf.effective_end_date ;

  -- Cursor to check the record exist in the archive table
  cursor c_chk_archive ( cp_assignment_id in number,
                         cp_effective_date date,
                         cp_action_info_category varchar2 )
  is
  select 'Y'
  from pay_action_information pai
  where pai.action_context_type ='AAP'
   and  pai.action_information_category = cp_action_info_category
   and  pai.assignment_id = cp_assignment_id
   and  trunc(pai.effective_date) = trunc(cp_effective_date) ;


  ln_gre_id                    NUMBER  ;
  ln_person_id                 NUMBER  ;
  lv_assignment_number         VARCHAR2(30);
  ln_location_id               NUMBER  ;
  ln_business_group_id         NUMBER  ;
  ln_soft_coding_keyflex_id    NUMBER  ;
  lv_per_system_status         VARCHAR2(100);
  lv_chk                       VARCHAR2(1);
  lv_gre_error_mesg            VARCHAR2(100);
  lv_asg_flag                  VARCHAR2(1);
  lv_procedure_name            VARCHAR2(100);
  lv_error_message             VARCHAR2(200);
  ln_step                      NUMBER;

  BEGIN

     dbg('Entering process enddate event ..........');

     lv_procedure_name         := '.process_enddate_event';
     ln_step := 1;
     hr_utility.set_location(gv_package || lv_procedure_name, 10);

     open c_asg_details( p_assignment_id,
                            p_effective_date ) ;
     fetch c_asg_details into ln_person_id,
                              lV_assignment_number,
                              ln_location_id,
                              ln_soft_coding_keyflex_id,
                              lv_per_system_status,
                              ln_business_group_id;
     close c_asg_details ;

     dbg('Dervie GRE from location and SCL ' );

     ln_gre_id := derive_gre_from_loc_scl( ln_location_id
                                          ,ln_business_group_id
                                          ,ln_soft_coding_keyflex_id
                                          ,p_effective_date   ) ;
     if ln_gre_id = -1 or ln_gre_id = -2 then
        if ln_gre_id = -1 then
           lv_gre_error_mesg := g_ambiguous_error ;
        else
           lv_gre_error_mesg := g_missing_gre_error ;
        end if;
        arch_hire_separation_data(p_assignment_action_id   => p_assignment_action_id,
                                  p_arch_type         =>'E',
                                  p_assignment_id      => p_assignment_id,
                                  p_assignment_number  => lv_assignment_number,
                                     p_location_id        => ln_location_id,
                                     p_effective_date     => p_effective_date,
                                     p_gre_id             => null,
                                     p_error_mesg         => lv_gre_error_mesg,
                                     p_event_type         => 'E'
                                    ) ;
              dbg('Error in deriving GRE for Location Id ' || to_char(ln_location_id) );
              return ;
     end if ; -- ln_gre_id

     if to_char(p_effective_date,'DD/MM/YYYY') <> '31/12/4712' then
        dbg('Effective date is not equal to 31-DEC-4712' );

        if lv_per_system_status = 'ACTIVE_ASSIGN' then

           ln_step := 2;

           -- Check any other active assignments exists with gre_id for this person_id
           dbg('Check any other active assignments exists for this employee ' );
           dbg(' assignment id        = '||to_char(p_assignment_id) );
           dbg(' person id            = '||to_char(ln_person_id) );
           dbg(' gre id               = '||to_char(ln_gre_id) );
           dbg(' eff date             = '||to_char(p_effective_date,'DD-MON-YYYY') );

           lv_asg_flag :=chk_active_asg_exists( p_assignment_id
                           ,ln_person_id
                           ,ln_gre_id
                           ,p_effective_date
                           ) ;
           if lv_asg_flag ='N' then
              -- no record found then archive separation data
              dbg( 'No Active assignment found archive data as arch_type=S ');
              arch_hire_separation_data(p_assignment_action_id   => p_assignment_action_id,
                               p_arch_type          =>'S',
                               p_assignment_id      => p_assignment_id,
                               p_assignment_number  => lv_assignment_number,
                               p_location_id        => ln_location_id,
                               p_effective_date     => p_effective_date,
                               p_gre_id             => ln_gre_id,
                               p_error_mesg         => null,
                               p_event_type         => 'U'
                              ) ;
           end if ;

      end if ; -- lv_per_system_status

   else
        -- effective_date is equal to EOT 31-DEC-4712
        -- Check the separation record exists in archive table with
        -- effective date as old value
        -- if record exists then
        --    termination record is already archived so
        --    rehire this record with the status of R-Reverse Terminated
        -- else
        --    termination record is not archived so reverse term record is ignored
        -- end if

        dbg('Effective date equal to 31-DEC-4712' );
        -- check record exists in Archive table for person_id, new_gre_id and effective_date
        dbg('Check record is archived in archive table with SEPARATION as info category' );
        dbg(' assignment id        = '||to_char(p_assignment_id) );
        dbg(' eff date             = '||p_old_value  );
        dbg(' Action info category = ' ||g_action_sep_category );
        open c_chk_archive( p_assignment_id,
                            to_date(p_old_value,'DD/MM/YY'),
                            g_action_sep_category ) ;
        fetch c_chk_archive into lv_chk ;
        if c_chk_archive%found then
           -- termination record is already archived so
           -- rehire this record with the status of R-Reverse Terminated
            dbg('Separation record is reported to IMSS so write in arch plsql table arch_type=R ');
            arch_hire_separation_data(p_assignment_action_id   => p_assignment_action_id,
                                   p_arch_type          => 'R',
                                   p_assignment_id      => p_assignment_id,
                                   p_assignment_number  => lv_assignment_number,
                                   p_location_id        => ln_location_id,
                                   p_effective_date     => to_date(p_old_value,'DD/MM/YY') + 1,
                                   p_gre_id             => ln_gre_id ,
                                   p_error_mesg         => null,
                                   p_event_type         => 'E'
                                 ) ;
        else
           dbg('Separation record is NOT reported to IMSS');
           dbg('Skipping the Reverse Termination record  ');
        end if;
        close c_chk_archive ;

      end if; --to_char(p_effective_date)

      ln_step := 3;
      hr_utility.set_location(gv_package || lv_procedure_name, 100);

      dbg('Exiting process end date event..........' );

  exception
    when others then
      lv_error_message := 'Error at step ' || ln_step ||
                          ' in ' || gv_package || lv_procedure_name;
      dbg(lv_error_message || '-' || sqlerrm);

      hr_utility.raise_error;

  END process_enddate_event;

  /************************************************************
   Name      : interpret_all_asg_events
   Purpose   : interpret all the change events for an assignment
  ************************************************************/
  PROCEDURE interpret_all_asg_events(
                 p_assignment_action_id in number
                ,p_assignment_id   in number
                ,p_start_date      in date
                ,p_end_date        in date
                ,p_event_group_id  in number
                )

  IS

  cursor c_asg_status_type(cp_assignment_status_type_id in number)
  is
  select PER_SYSTEM_STATUS from per_assignment_status_types
  where assignment_status_type_id = cp_assignment_status_type_id ;


  int_pkg_events        pay_interpreter_pkg.t_detailed_output_table_type;
  asg_events_table      t_int_asg_event_table;
  l_proration_dates     pay_interpreter_pkg.t_proration_dates_table_type;
  l_proration_changes   pay_interpreter_pkg.t_proration_type_table_type;
  l_pro_type_tab        pay_interpreter_pkg.t_proration_type_table_type;

  lv_change_values      VARCHAR2(100);
  ln_old_value          NUMBER ;
  ln_new_value          NUMBER ;
  ln_old_value1         NUMBER ;
  ln_new_value1         NUMBER ;

  lv_old_value          VARCHAR2(100) ;
  lv_new_value          VARCHAR2(100) ;

  lv_old_asg_status     VARCHAR2(100);
  lv_new_asg_status     VARCHAR2(100);

  lv_procedure_name     VARCHAR2(100) ;
  lv_error_message      VARCHAR2(200);
  ln_step               NUMBER;
  lv_insert_found       VARCHAR2(1);
  lv_enddate_found      VARCHAR2(1);
  lv_row_found          VARCHAR2(1);

  ln_index              NUMBER ;


  BEGIN

       dbg('Entering interpret_all_asg_events...........' );
       dbg('Processing Assignment Id '|| to_char(p_assignment_id) );
       msg('Processing Assignment Id '|| to_char(p_assignment_id) );

       lv_procedure_name     := '.interpret_all_asg_events';

       hr_utility.set_location(gv_package || lv_procedure_name, 10);
       ln_step := 1;
       dbg('call the interpreter pkg ' );

       -- call the interpreter pkg
       pay_interpreter_pkg.entry_affected(
        p_element_entry_id      => null
       ,p_assignment_action_id  => NULL
       ,p_assignment_id         => p_assignment_id
       ,p_mode                  => NULL
       ,p_process               => NULL
       ,p_event_group_id        => p_event_group_id
       ,p_process_mode          => 'ENTRY_CREATION_DATE'
       ,p_start_date            => p_start_date
       ,p_end_date              => p_end_date
       ,p_unique_sort           => 'N' -- tells the interpreter not to do a unique sort
       ,p_business_group_id     => null
       ,t_detailed_output       => int_pkg_events   --OUTPUT OF RESULTS
       ,t_proration_dates       => l_proration_dates
       ,t_proration_change_type => l_proration_changes
       ,t_proration_type        => l_pro_type_tab);

       dbg('Rows returned from pay_interpreter_pkg.entry_affected are');
       FOR i in 1..int_pkg_events.COUNT
       LOOP
           dbg('Result row       :' ||to_char(i));
           dbg('Datetracked_event: '||int_pkg_events(i).datetracked_event );
           dbg('Change_mode      : '||int_pkg_events(i).change_mode );
           dbg('Effective_date   : '||to_char(int_pkg_events(i).effective_date,'DD-MON-YYYY')) ;
           dbg('dated_table_id   : '||TO_CHAR(int_pkg_events(i).dated_table_id)) ;
           dbg('column_name      : '||int_pkg_events(i).column_name ) ;
           dbg('Update_type      : '||int_pkg_events(i).update_type ) ;
           dbg('old_value        : '||int_pkg_events(i).old_value ) ;
           dbg('new_value        : '||int_pkg_events(i).new_value ) ;
           dbg('change_values    : '||int_pkg_events(i).change_values ) ;
       END LOOP ;
       dbg('Total rows returned from interpreter pkg ' || to_char(int_pkg_events.COUNT) );

       /* The following is the multiple scenerios and the event records returned from the
          Interpreter pacakge

          1) User Entry      : Insert record
                               on 01-JAN-2004 record created
                               (default record inserted while entering the person record)
             Int pkg Returns : Returns one record
             Process         : Process only the insert record

          2) User Entry      : Insert followed by multiple correction record
                               a)on 01-JAN-2004   record inserted
                               b)DTrack 01-JAN-2004 corrected either location or GRE in the SCL

             Int pkg Returns : Returns 3 records
                               i)  Insert
                               ii) Location correction
                               iii)SCL correction

             Process         : Process only the insert and skip the correction records

          3) User Entry      : Insert record and Update record followed by correction record
                               a)on 01-JAN-2004   record inserted
                               b)DTrack 05-JAN-2004 updated either location or GRE in the SCL
                               c)DTrack 05-JAN-2004 corrected either location or GRE in the SCL

             Int pkg Returns : Returns 5 records
                               i) insert
                               ii) Location update
                               iii) SCL update
                               iv) location correction
                                v) SCL Correction

             Process          : process insert and update record with the last correction record.

          4) User Entry       : Single or multiple correction record
                                a)DTrack 05-JAN-2004 corrected either location or GRE in the SCL
             Int Pkg Returns  : Single or Multiple records
             Process          : Process the last correction record
             Example   05-JAN-2004   A  to B  on last update date 06-Jan-2004 at 10:00 am
                       05-JAN-2004   B  to C  on last update date 06-Jan-2004 at 11:00 am
                       05-JAN-2004   c  to D  on last update date 06-Jan-2004 at 12:00 am
             Take the last record and new value is D

          5) User Entry       : Single or multiple update record
                                a)DTrack 05-FEB-2004 updated either location or GRE in the SCL
             Int Pkg Returns  : Single or Multiple records
             Process          : Process the update record with both location and scl

          6) User Entry       : Multiple update record followed by correction record
                                a)DTrack 05-MAR-2004 updated both location and GRE in the SCL
                                b)DTrack 05-MAR-2004 corrected both location and GRE in the SCL
             Int Pkg Returns  : Single or Multiple records
             Process          : Process the update record with the correction value

          7) User Entry       : Hire, Correction and Terminate record
                                a)DTrack 01-JUL-2004 record Inserted
                                b)DTrack 01-JUL-2004 corrected both location and GRE in the SCL
                                C)End Employement on 31-JUL-2004 with
                                  actual_termination_date = final process date = 31-JUL-2004
             Int Pkg Returns  : Single or Multiple records
             Process          : Process Insert, correction and termination record

          8) User Entry       : Hire, Correction,Terminate record and Reverse terminate
                                a)DTrack 01-JUL-2004 record Inserted
                                b)DTrack 01-JUL-2004 corrected both location and GRE in the SCL
                                C)End Employement on 31-JUL-2004 with
                                  actual_termination_date = final process date = 31-JUL-2004
                                d)Reverse Terminate
             Int Pkg Returns  : Single or Multiple records
             Process          : Process Insert, correction records ( ignore termination and
                                   corresponding reverse termination)
          9) User Entry       : Hire, Correction and Terminate record
                                a)DTrack 01-JUL-2004 record Inserted
                                b)DTrack 01-JUL-2004 corrected both location and GRE in the SCL
                                C)End Employement on 31-JUL-2004 with
                                  actual_termination_date = 31-JUL-2004
                                  final process date = null
             Int Pkg Returns  : Single or Multiple records
             Process          : Process Insert, correction and termination record

          10)User Entry       : Hire, Correction,Terminate record and Reverse terminate
                                a)DTrack 01-JUL-2004 record Inserted
                                b)DTrack 01-JUL-2004 corrected both location and GRE in the SCL
                                C)End Employement on 31-JUL-2004 with
                                  actual_termination_date =  31-JUL-2004
                                  final process date = null
                                d)Reverse Terminate
             Int Pkg Returns  : Single or Multiple records
             Process          : Process Insert, correction records ( ignore termination and
                                   corresponding reverse termination)
       */

       hr_utility.set_location(gv_package || lv_procedure_name, 20);
       ln_step := 2;
       dbg('Remove the duplication rows on the same effective date');

       FOR i in 1..int_pkg_events.COUNT
       LOOP
           dbg('Processing int pkg results row :' ||to_char(i));
           dbg('Datetracked_event: '||int_pkg_events(i).datetracked_event );
           dbg('Change_mode      : '||int_pkg_events(i).change_mode );
           dbg('Effective_date   : '||to_char(int_pkg_events(i).effective_date,'DD-MON-YYYY')) ;
           dbg('dated_table_id   : '||TO_CHAR(int_pkg_events(i).dated_table_id)) ;
           dbg('column_name      : '||int_pkg_events(i).column_name ) ;
           dbg('Update_type      : '||int_pkg_events(i).update_type ) ;
           dbg('old_value        : '||int_pkg_events(i).old_value ) ;
           dbg('new_value        : '||int_pkg_events(i).new_value ) ;
           dbg('change_values    : '||int_pkg_events(i).change_values ) ;


           if int_pkg_events(i).update_type ='I'  then
               ln_index := asg_events_table.COUNT + 1 ;
               asg_events_table(ln_index).update_type    := int_pkg_events(i).update_type ;
               asg_events_table(ln_index).effective_date := int_pkg_events(i).effective_date ;
               asg_events_table(ln_index).column_name    := int_pkg_events(i).column_name ;
               asg_events_table(ln_index).old_value      := int_pkg_events(i).old_value ;
               asg_events_table(ln_index).new_value      := int_pkg_events(i).new_value ;

           elsif int_pkg_events(i).update_type ='E' then
                 -- convert the values from change_values to old and new value
                 -- change values will have <old_value> -> <new_value> ie 31-DEC-12 -> 31-JUL-04
                 lv_change_values := int_pkg_events(i).change_values ;
                 if ltrim(rtrim(SUBSTR(lv_change_values,1,INSTR(lv_change_values,'->')-1))) = '<null>' then
                    lv_old_value := '<null>';
                 else
                    lv_old_value := ltrim(rtrim(SUBSTR(lv_change_values,1,INSTR(lv_change_values,'->')-1)));
                 end if;
                 if ltrim(rtrim(SUBSTR(lv_change_values,INSTR(lv_change_values,'->')+3))) = '<null>' then
                    lv_new_value := '<null>';
                 else
                    lv_new_value := ltrim(rtrim(SUBSTR(lv_change_values,INSTR(lv_change_values,'->')+3)))  ;
                 end if;
                 -- add row in asg_events_table
                 ln_index := asg_events_table.COUNT + 1 ;
                 asg_events_table(ln_index).update_type    := int_pkg_events(i).update_type ;
                 asg_events_table(ln_index).effective_date := int_pkg_events(i).effective_date ;
                 asg_events_table(ln_index).column_name    := int_pkg_events(i).column_name ;
                 asg_events_table(ln_index).old_value      := lv_old_value ;
                 asg_events_table(ln_index).new_value      := lv_new_value ;

           elsif (int_pkg_events(i).column_name = 'ASSIGNMENT_STATUS_TYPE_ID') AND
                 (int_pkg_events(i).update_type ='C' or
                  int_pkg_events(i).update_type ='U' ) THEN

                  -- convert the values from change_values to old and new value
                  dbg( 'convert the values from change_values to old and new value' );
                  if int_pkg_events(i).update_type = 'C' then
                      -- change values will have <old_value> -> <new_value> ie 590 -> 610
                      lv_change_values := int_pkg_events(i).change_values ;
                      if ltrim(rtrim(SUBSTR(lv_change_values,1,INSTR(lv_change_values,'->')-1))) = '<null>' then
                         lv_old_value := '<null>';
                      else
                         lv_old_value := ltrim(rtrim(SUBSTR(lv_change_values,1,INSTR(lv_change_values,'->')-1)));
                      end if;
                      if ltrim(rtrim(SUBSTR(lv_change_values,INSTR(lv_change_values,'->')+3))) = '<null>' then
                         lv_new_value := '<null>';
                      else
                         lv_new_value := ltrim(rtrim(SUBSTR(lv_change_values,INSTR(lv_change_values,'->')+3)))  ;
                      end if;
                  elsif int_pkg_events(i).update_type = 'U' then
                      lv_old_value := int_pkg_events(i).old_value  ;
                      lv_new_value := int_pkg_events(i).new_value  ;
                  end if;
                  dbg( 'old value :'||lv_old_value );
                  dbg( 'new value :'||lv_new_value );

                  -- ACTIVE_ASSIGN to TERM_ASSIGN   ok
                  -- TERM_ASSIGN TO ACTIVE_ASSIGN   This is a reverse termination so skip the record

                  if lv_old_value <> '<null>' then
                     open c_asg_status_type(to_number(lv_old_value)) ;
                     fetch c_asg_status_type into lv_old_asg_status ;
                     close c_asg_status_type ;
                  end if;

                  if lv_new_value <> '<null>' then
                     open c_asg_status_type(to_number(lv_new_value)) ;
                     fetch c_asg_status_type into lv_new_asg_status ;
                     close c_asg_status_type ;
                  end if;

                  dbg( 'old assignment status :'||lv_old_asg_status );
                  dbg( 'new assignment status :'||lv_new_asg_status );

                  if lv_old_asg_status = 'ACTIVE_ASSIGN' and lv_new_asg_status='TERM_ASSIGN' then
                     -- insert the record
                    ln_index := asg_events_table.COUNT + 1 ;
                    asg_events_table(ln_index).update_type    := 'E' ;
                    asg_events_table(ln_index).effective_date := int_pkg_events(i).effective_date - 1  ;
                    asg_events_table(ln_index).column_name    := int_pkg_events(i).column_name ;
                    asg_events_table(ln_index).old_value      := int_pkg_events(i).old_value ;
                    asg_events_table(ln_index).new_value      := int_pkg_events(i).new_value ;
                  else
                    dbg('Change of Assignment_Status_type_id event record is skipped') ;
                  end if;


           elsif ( int_pkg_events(i).column_name = 'LOCATION_ID' or
                   int_pkg_events(i).column_name = 'SOFT_CODING_KEYFLEX_ID' ) AND
                 ( int_pkg_events(i).update_type ='C' or
                   int_pkg_events(i).update_type ='U' ) THEN

               -- check the row exists in asg_events_table with matching effective_date and
               -- update_type = I
               lV_insert_found := 'N' ;
               FOR j in 1..asg_events_table.COUNT
               LOOP
                   if (asg_events_table(j).effective_date = int_pkg_events(i).effective_date and
                      asg_events_table(j).update_type    = 'I' ) then
                      lV_insert_found :='Y' ;
                      exit ;
                   end if;
               END LOOP ;
               if lV_insert_found = 'Y' then
                  dbg( 'row skipped from int_pkg_events as the insert record exists on the same effective date' );
               else
                   -- convert the values from change_values to old and new value
                   dbg( 'convert the values from change_values to old and new value' );
                   if int_pkg_events(i).update_type = 'C' then
                      -- change values will have <old_value> -> <new_value> ie 590 -> 610
                      lv_change_values := int_pkg_events(i).change_values ;
                      if ltrim(rtrim(SUBSTR(lv_change_values,1,INSTR(lv_change_values,'->')-1))) = '<null>' then
                         lv_old_value := '<null>';
                      else
                         lv_old_value := ltrim(rtrim(SUBSTR(lv_change_values,1,INSTR(lv_change_values,'->')-1)));
                      end if;
                      if ltrim(rtrim(SUBSTR(lv_change_values,INSTR(lv_change_values,'->')+3))) = '<null>' then
                         lv_new_value := '<null>';
                      else
                         lv_new_value := ltrim(rtrim(SUBSTR(lv_change_values,INSTR(lv_change_values,'->')+3)))  ;
                      end if;
                  elsif int_pkg_events(i).update_type = 'U' then
                      lv_old_value := int_pkg_events(i).old_value  ;
                      lv_new_value := int_pkg_events(i).new_value  ;
                  end if;
                  dbg( 'old value :'||lv_old_value );
                  dbg( 'new value :'||lv_new_value );

                  -- Check the row exists in asg_events_table with matching efective_date and
                  -- update_type ='C' or update_type='U'
                  lV_row_found := 'N' ;
                  FOR j in 1..asg_events_table.COUNT
                  LOOP
                   if (asg_events_table(j).effective_date = int_pkg_events(i).effective_date and
                       (asg_events_table(j).update_type = 'U' or asg_events_table(j).update_type = 'C')
                      ) then

                      lV_row_found :='Y' ;
                      -- record found so update the row with the current values
                      if int_pkg_events(i).column_name = 'LOCATION_ID' then
                         asg_events_table(j).column_name  := int_pkg_events(i).column_name ;
                         asg_events_table(j).new_value    := lv_new_value ;
                         if asg_events_table(j).old_value is null then
                            asg_events_table(j).old_value    := lv_old_value ;
                         end if;
                      elsif int_pkg_events(i).column_name = 'SOFT_CODING_KEYFLEX_ID' then
                         asg_events_table(j).column_name1 := int_pkg_events(i).column_name ;
                         asg_events_table(j).new_value1   := lv_new_value ;
                         if asg_events_table(j).old_value1 is null then
                            asg_events_table(j).old_value1 := lv_old_value ;
                         end if;
                      end if;
                      dbg( 'row updated with current value as multiple correction/update record found' );
                      exit ;
                   end if;
                  END LOOP ;
                  if lv_row_found = 'N' then
                     -- add row in asg_events_table
                     dbg('record not found so add the record ');
                     ln_index := asg_events_table.COUNT + 1 ;
                     asg_events_table(ln_index).update_type    := int_pkg_events(i).update_type ;
                     asg_events_table(ln_index).effective_date := int_pkg_events(i).effective_date ;

                     if int_pkg_events(i).column_name = 'LOCATION_ID' then
                        asg_events_table(ln_index).column_name    := int_pkg_events(i).column_name ;
                        asg_events_table(ln_index).old_value      := lv_old_value ;
                        asg_events_table(ln_index).new_value      := lv_new_value ;

                     elsif int_pkg_events(i).column_name = 'SOFT_CODING_KEYFLEX_ID' then
                        asg_events_table(ln_index).column_name1    := int_pkg_events(i).column_name ;
                        asg_events_table(ln_index).old_value1      := lv_old_value ;
                        asg_events_table(ln_index).new_value1      := lv_new_value ;
                     end if;
                  end if; -- lv_row_found
               end if; --lv_insert_found
           end if; -- update_type

       END LOOP ;

       hr_utility.set_location(gv_package || lv_procedure_name, 30);
       ln_step := 3;
       dbg('Process after removed the duplication rows' );
       dbg('Total rows need to process from the asg events is ' || to_char(asg_events_table.COUNT) );

       FOR i in 1..asg_events_table.COUNT
       LOOP

          dbg('Assignment Id  :' || to_char(p_assignment_id) );
          dbg('Effective Date :' || to_char(asg_events_table(i).effective_date,'DD-MON-YYYY') );
          dbg('Update Type    :' || asg_events_table(i).update_type );
          dbg('Column Name    :' || asg_events_table(i).column_name );
          dbg('Old Value      :' || asg_events_table(i).old_value   );
          dbg('new Value      :' || asg_events_table(i).new_value );
          dbg('Column Name    :' || asg_events_table(i).column_name1 );
          dbg('Old Value      :' || asg_events_table(i).old_value1);
          dbg('new Value      :' || asg_events_table(i).new_value1 );


          if asg_events_table(i).update_type = 'I' then

              dbg('call process insert event' );
              msg('Processing Insert Event' );
              process_insert_event( p_assignment_action_id
                                   ,p_assignment_id
                                   ,asg_events_table(i).effective_date
                                  ) ;

           elsif asg_events_table(i).update_type = 'E' then

              dbg('call process_endate_event' );
              msg('Processing Enddate Event' );
              process_enddate_event(p_assignment_action_id
                                   ,p_assignment_id
                                   ,asg_events_table(i).effective_date
                                   ,asg_events_table(i).old_value
                                   ,asg_events_table(i).new_value
                                   );

           elsif ( asg_events_table(i).update_type = 'C' or
                   asg_events_table(i).update_type = 'U' ) then

               dbg('Event update type is C or U ' );

               if asg_events_table(i).old_value = '<null>' then
                  ln_old_value := null;
               else
                  ln_old_value := to_number(asg_events_table(i).old_value);
               end if;
               if asg_events_table(i).new_value = '<null>' then
                  ln_new_value := null;
               else
                  ln_new_value := to_number(asg_events_table(i).new_value) ;
               end if;
               if asg_events_table(i).old_value1 = '<null>' then
                  ln_old_value1 := null;
               else
                  ln_old_value1 := to_number(asg_events_table(i).old_value1);
               end if;
               if asg_events_table(i).new_value1 = '<null>' then
                  ln_new_value1 := null;
               else
                  ln_new_value1 := to_number(asg_events_table(i).new_value1) ;
               end if;

               dbg('After Old and New values converted to numeric ' );
               dbg('Assignment Id  :' || to_char(p_assignment_id) );
               dbg('Effective Date :' || to_char(asg_events_table(i).effective_date,'DD-MON-YYYY') );
               dbg('Update Type    :' || asg_events_table(i).update_type );
               dbg('Column Name    :' || asg_events_table(i).column_name );
               dbg('Old Value      :' || to_char(ln_old_value) );
               dbg('new Value      :' || to_char(ln_new_value) );
               dbg('Column Name    :' || asg_events_table(i).column_name1 );
               dbg('Old Value      :' || to_char(ln_old_value1) );
               dbg('new Value      :' || to_char(ln_new_value1) );

               if asg_events_table(i).update_type = 'C' then

                  dbg('call process_correction_event' );
                  msg('Processing Correction Event' );
                  process_correction_event( p_assignment_action_id
                                        ,p_assignment_id
                                        ,asg_events_table(i).effective_date
                                        ,asg_events_table(i).column_name
                                        ,ln_old_value
                                        ,ln_new_value
                                        ,asg_events_table(i).column_name1
                                        ,ln_old_value1
                                        ,ln_new_value1
                                       );

               else
                  -- asg_events_table(i).update_type = 'U'

                  dbg('call process_update_event' );
                  msg('Processing Update Event' );
                  process_update_event( p_assignment_action_id
                                    ,p_assignment_id
                                    ,asg_events_table(i).effective_date
                                    ,asg_events_table(i).column_name
                                    ,ln_old_value
                                    ,ln_new_value
                                    ,asg_events_table(i).column_name1
                                    ,ln_old_value1
                                    ,ln_new_value1
                                    );

              end if;  --  C or U

           end if;

      END LOOP ;

      ln_step := 4;
      hr_utility.set_location(gv_package || lv_procedure_name, 40);

      dbg('Exiting interpret_all_asg_events...........' );


  exception
    when others then
      lv_error_message := 'Error at step ' || ln_step ||
                          ' in ' || gv_package || lv_procedure_name;
      dbg(lv_error_message || '-' || sqlerrm);
      hr_utility.raise_error;

  END interpret_all_asg_events ;

  /************************************************************
   Name      : archive_data
   Purpose   : This procedure Archives data which will be used
               in the SS Worksheet report and magtape report.
  ************************************************************/
  PROCEDURE archive_data(p_assignment_action_id  in number
                        ,p_effective_date in date)
  IS

    cursor c_asg_action_info (cp_assignment_action in number) is
      select paa.payroll_action_id,
             paa.assignment_id,
             paa.tax_unit_id
        from pay_assignment_actions paa
       where paa.assignment_action_id = cp_assignment_action;


    lv_procedure_name        VARCHAR2(100);
    lv_error_message         VARCHAR2(200);
    ln_step                  NUMBER;

    ln_payroll_action_id     NUMBER;
    ln_assignment_action_id  NUMBER;
    ln_assignment_iD         NUMBER;
    ln_tax_unit_id           NUMBER;
    ld_start_date            DATE;
    ld_end_date              DATE;
    ln_business_group_id     NUMBER;
    ln_tran_gre_id           NUMBER;
    ln_gre_id                NUMBER;
    ln_event_group_id        NUMBER;

  BEGIN

     dbg('Entering archive data ...........');
     dbg('assignment action id is ' || to_char(p_assignment_action_id) );

     lv_procedure_name       := '.archive_data';
     hr_utility.set_location(gv_package || lv_procedure_name, 10);
     ln_step := 1;

     dbg('Get Payroll Action Id ');
     open  c_asg_action_info (p_assignment_action_id);
     fetch c_asg_action_info into ln_payroll_action_id,
                                  ln_assignment_id,
                                  ln_tax_unit_id ;
     close c_asg_action_info;
     dbg('Payroll action id' || to_char(ln_payroll_action_id) );

     hr_utility.set_location(gv_package || lv_procedure_name, 20);
     ln_step := 2;
     dbg('Get parameter information from pay_payroll_actions table' ) ;
     get_payroll_action_info(p_payroll_action_id  => ln_payroll_action_id
                            ,p_start_date         => ld_start_date
                            ,p_end_date           => ld_end_date
                            ,p_business_group_id  => ln_business_group_id
                            ,p_tran_gre_id        => ln_tran_gre_id
                            ,p_gre_id             => ln_gre_id
                            ,p_event_group_id     => ln_event_group_id);

     hr_utility.set_location(gv_package || lv_procedure_name, 30);
     ln_step := 3;
     dbg('call Interpret_all_asg_events');

     interpret_all_asg_events( p_assignment_action_id => p_assignment_action_id
                              ,p_assignment_id        => ln_assignment_id
                              ,p_start_date           => ld_start_date
                              ,p_end_date             => ld_end_date
                              ,p_event_group_id       => ln_event_group_id
                             ) ;

     hr_utility.set_location(gv_package || lv_procedure_name, 40);

     dbg('Exiting archive data ...........');

  EXCEPTION
   when others then
      lv_error_message := 'Error at step ' || ln_step || ' in ' ||
                           gv_package || lv_procedure_name;
      dbg(lv_error_message || '-' || sqlerrm);
      hr_utility.raise_error;

  end archive_data;


--begin
--hr_utility.trace_on (null, 'SSAFFL');

end per_mx_ssaffl_archive;

/
