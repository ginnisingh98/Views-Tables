--------------------------------------------------------
--  DDL for Package PAY_SG_IRAS_MAGTAPE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_SG_IRAS_MAGTAPE" AUTHID CURRENT_USER as
/* $Header: pysgirmt.pkh 120.1.12010000.9 2009/06/04 05:40:50 jalin ship $ */

  level_cnt  number;
  g_report_type VARCHAR2(20);
  g_file VARCHAR2(20);

  --------------------------------------------------------------------
  -- These are PUBLIC procedures are required by the Archive process.
  -- Their names are stored in PAY_REPORT_FORMAT_MAPPINGS_F so that
  -- the archive process knows what code to execute for each step of
  -- the archive.
  --------------------------------------------------------------------
  procedure range_code
    (p_payroll_action_id  in pay_payroll_actions.payroll_action_id%type,
     p_sql                out nocopy varchar2);

  procedure assignment_action_code
    (p_payroll_action_id  in pay_payroll_actions.payroll_action_id%type,
     p_start_person_id    in per_all_people_f.person_id%type,
     p_end_person_id      in per_all_people_f.person_id%type,
     p_chunk              in number);

  procedure initialization_code
    (p_payroll_action_id  in pay_payroll_actions.payroll_action_id%type);

  procedure archive_code
    (p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type,
     p_effective_date        in date);

  -- commented out for bug 5616519
--  function  return_indicator_flag( p_assignment_id  in number,
--                                   p_report_type    in varchar2 ) return varchar2 ;
  ---------------------------------------------------------------------
  -- PUBLIC cursors to retrieve data and pass it to IRAS formulae that
  -- will write out header information for the 3 file types.
  -- Bug 3232300: Added joins for table ff_archive_items and ff_database_items
  -- so that it selects only that  assignment action id against
  -- which archived header information exist.

  ---------------------------------------------------------------------
  -- Passes parameters to SG_IRAS_HEADER formula
  cursor ir8a_header is
    select 'ASSIGNMENT_ACTION_ID=C',
           aac.assignment_action_id,
           'APPLICATION_REFERENCE=P',
           'IR8A' application_reference,
           'BASIS_YEAR=P',
           pay_core_utils.get_parameter('BASIS_YEAR', apa.legislative_parameters) basis_year,
           'CREATION_DATE=P',
           to_char(sysdate,'YYYYMMDD') creation_date
    from   pay_payroll_actions mpa,
           pay_payroll_actions apa,
           pay_assignment_actions aac,
           ff_archive_items   ffi,
           ff_database_items  fdi
    where  mpa.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
    and    apa.payroll_action_id = pay_core_utils.get_parameter('ARCHIVE_RUN_ID', mpa.legislative_parameters)
    and    apa.payroll_action_id = aac.payroll_action_id
    and    apa.action_status     = 'C'
    and    ffi.context1          = aac.assignment_action_id   /* Added joins for bug:3232300 */
    and    fdi.user_name         = 'X_SG_LEGAL_ENTITY_SG_LEGAL_ENTITY_NAME'
    and    ffi.user_entity_id    = fdi.user_entity_id
    and    rownum=1;

  -- Passes parameters to SG_IRAS_HEADER formula
  cursor ir8s_header is
    select 'ASSIGNMENT_ACTION_ID=C',
            aac.assignment_action_id,
           'APPLICATION_REFERENCE=P',
           'IR8S' application_reference,
           'BASIS_YEAR=P',
            pay_core_utils.get_parameter('BASIS_YEAR', apa.legislative_parameters) basis_year,
           'CREATION_DATE=P',
            to_char(sysdate,'YYYYMMDD') creation_date
    from   pay_payroll_actions mpa,
           pay_payroll_actions apa,
           pay_assignment_actions aac
	   ,ff_archive_items  ffi
           ,ff_database_items fdi
    where  mpa.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
    and    apa.payroll_action_id = pay_core_utils.get_parameter('ARCHIVE_RUN_ID', mpa.legislative_parameters)
    and    apa.payroll_action_id = aac.payroll_action_id
    and    apa.action_status     = 'C'
    and    ffi.context1          = aac.assignment_action_id   /* Added joins for bug:3232300 */
    and    fdi.user_name         = 'X_SG_LEGAL_ENTITY_SG_LEGAL_ENTITY_NAME'
    and    ffi.user_entity_id    =  fdi.user_entity_id
    and    rownum=1;

  -- Passes parameters to SG_IRAS_HEADER formula
  cursor a8a_header is
    select 'ASSIGNMENT_ACTION_ID=C',
           aac.assignment_action_id,
           'APPLICATION_REFERENCE=P',
           'IRA8A' application_reference,
           'BASIS_YEAR=P',
            pay_core_utils.get_parameter('BASIS_YEAR', apa.legislative_parameters) basis_year,
           'CREATION_DATE=P',
           to_char(sysdate,'YYYYMMDD') creation_date
    from   pay_payroll_actions mpa,
           pay_payroll_actions apa,
           pay_assignment_actions aac,
	   ff_archive_items    ffi,
           ff_database_items  fdi
    where  mpa.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
    and    apa.payroll_action_id = pay_core_utils.get_parameter('ARCHIVE_RUN_ID', mpa.legislative_parameters)
    and    apa.payroll_action_id = aac.payroll_action_id
    and    apa.action_status     = 'C'
    and    ffi.context1          = aac.assignment_action_id   /* Added joins for bug:3232300 */
    and    fdi.user_name         = 'X_SG_LEGAL_ENTITY_SG_LEGAL_ENTITY_NAME'
    and    ffi.user_entity_id    = fdi.user_entity_id
    and    rownum=1;

  -- Passes parameters to SG_IRAS_HEADER formula
  cursor a8b_header is
    select 'ASSIGNMENT_ACTION_ID=C',
           aac.assignment_action_id,
           'APPLICATION_REFERENCE=P',
           'IRA8B' application_reference,
           'BASIS_YEAR=P',
           pay_core_utils.get_parameter('BASIS_YEAR', apa.legislative_parameters) basis_year,
           'CREATION_DATE=P',
           to_char(sysdate,'YYYYMMDD') creation_date
    from   pay_payroll_actions mpa,
           pay_payroll_actions apa,
           pay_assignment_actions aac,
      	   ff_archive_items  ffi,
           ff_database_items fdi
    where  mpa.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
    and    apa.payroll_action_id = pay_core_utils.get_parameter('ARCHIVE_RUN_ID', mpa.legislative_parameters)
    and    apa.payroll_action_id = aac.payroll_action_id
    and    apa.action_status     = 'C'
    and    ffi.context1          = aac.assignment_action_id   /* Added joins for bug:3232300 */
    and    fdi.user_name         = 'X_SG_LEGAL_ENTITY_SG_LEGAL_ENTITY_NAME'
    and    ffi.user_entity_id    = fdi.user_entity_id
    and    rownum=1;

  ---------------------------------------------------------------------
  -- PUBLIC cursor used to pass parameters to SG_IR8A_DETAILS,
  -- SG_IR8S_DETAILS, and SG_A8A_DETAILS formulae.
  -- Not all parameters are required by all formulae, but it is more
  -- efficient and easily maintainable if 1 cursor is used for all 3
  -- detail sections of the magtapes.
  -- Bug 3249481 - Added function call pay_sg_iras_magtape.return_indicator_flag( )
  -- Bug 5616519 - Removed function call pay_sg_iras_magtape.return_indicator_flag( )
  ---------------------------------------------------------------------
  cursor iras_details is
    select distinct
           'ASSIGNMENT_ACTION_ID=C',
           aac.assignment_action_id,
           'TAX_UNIT_ID=C',
           pay_core_utils.get_parameter('LEGAL_ENTITY_ID', apa.legislative_parameters) tax_unit_id,
           'BASIS_YEAR=P',
           pay_core_utils.get_parameter('BASIS_YEAR', apa.legislative_parameters) basis_year,
           'P_ASSIGNMENT_ACTION_ID=P',
           to_char(mac.assignment_action_id),
           'ASSIGNMENT_ID=P',
           to_char(paa.assignment_id) assignment_id,
           'PERSON_ID=P',
           to_char(paa.person_id) person_id,
           'ASSIGNMENT_NUMBER=P',
           paa.assignment_number assignment_number
--	  'RECORD_INDICATOR_FLAG=P',
--           pay_sg_iras_magtape.return_indicator_flag(paa.assignment_id ,mpa.report_type)
    from   per_all_assignments_f paa,
           pay_payroll_actions mpa,
           pay_assignment_actions mac,
           pay_payroll_actions apa,
           pay_assignment_actions aac
    where  mpa.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
    and    mpa.payroll_action_id = mac.payroll_action_id
    and    apa.payroll_action_id = pay_core_utils.get_parameter('ARCHIVE_RUN_ID', mpa.legislative_parameters)
    and    apa.payroll_action_id = aac.payroll_action_id
    and    paa.assignment_id = aac.assignment_id
    and    apa.action_status = 'C'
    and    aac.action_status = 'C'
    and    (paa.effective_start_date <= to_date('31/' || '12/' || pay_core_utils.get_parameter('BASIS_YEAR', apa.legislative_parameters),'dd/mm/yyyy')
           and paa.effective_end_date >= to_date('01/' || '01/' || pay_core_utils.get_parameter('BASIS_YEAR', apa.legislative_parameters),'dd/mm/yyyy'))
    and    paa.assignment_id = mac.assignment_id
    order by paa.person_id;

  ---------------------------------------------------------------------
  -- PUBLIC cursors used to retrieve data and pass it to IR8S formulae
  -- as this magtape has more detailed records.
  -- Modified for Bug 2672462, Bug 2654499
  ---------------------------------------------------------------------
  -- Passes parameters to SG_IR8S_MONTH_DETAILS formula
  cursor ir8s_month_details is
    select distinct
           'ASSIGNMENT_ACTION_ID=C',
           aac.assignment_action_id,
           'TAX_UNIT_ID=C',
           pay_core_utils.get_parameter('LEGAL_ENTITY_ID', apa.legislative_parameters) tax_unit_id,
           'DATE_EARNED=C',
           ac3.context date_earned,
           'MONTH=P',
           to_char(fnd_date.canonical_to_date(ac3.context),'MON') month,
           'PERSON_ID=P',
           to_char(paa.person_id) person_id,
           'DATE_ORDER=P',
           fnd_date.canonical_to_date(ac3.context) date_order
    from   per_all_assignments_f paa,
           pay_payroll_actions apa,
           pay_assignment_actions aac,
           pay_payroll_actions mpa,
           ff_archive_items fai,
           ff_archive_item_contexts ac2,
           ff_archive_item_contexts ac3,
           ff_user_entities ffe,
           ff_routes ffr
    where  mpa.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
    and    paa.assignment_id = pay_magtape_generic.get_parameter_value('ASSIGNMENT_ID')
    and    apa.payroll_action_id = pay_core_utils.get_parameter('ARCHIVE_RUN_ID', mpa.legislative_parameters)
    and    apa.payroll_action_id = aac.payroll_action_id
    and    paa.assignment_id = aac.assignment_id
    and    aac.assignment_action_id = fai.context1
    and    fai.archive_item_id = ac2.archive_item_id and ac2.sequence_no = 2
    and    fai.archive_item_id = ac3.archive_item_id and ac3.sequence_no = 3
    and    apa.action_status = 'C'
    and    fai.user_entity_id = ffe.user_entity_id
    and    ffe.route_id = ffr.route_id
    and    ffr.route_name  = 'SG IRAS Month Balances Archive'
    and    (paa.effective_start_date <= to_date('31/' || '12/' || pay_core_utils.get_parameter('BASIS_YEAR', apa.legislative_parameters),'dd/mm/yyyy')
           and paa.effective_end_date >= to_date('01/' || '01/' || pay_core_utils.get_parameter('BASIS_YEAR', apa.legislative_parameters),'dd/mm/yyyy'))
    order by paa.person_id, fnd_date.canonical_to_date(ac3.context);

  ---------------------------------------------------------------------
  -- Passes parameters to SG_IR8S_WAGE_DETAILS
  -- Modified for bug 3027801
  -- Bug 3249481 - Added person_id check for performance
  ---------------------------------------------------------------------
  cursor ir8s_wage_details is
    select distinct 'ASSIGNMENT_ACTION_ID=C',
           aac.assignment_action_id,
           'TAX_UNIT_ID=C',
           pay_core_utils.get_parameter('LEGAL_ENTITY_ID', apa.legislative_parameters) tax_unit_id,
          'SOURCE_ID=C',
           ac3.context source_id,
           'ASS_EXTRA_ID=P',
           ac3.context ass_extra_id,
           'PERSON_ID=P',
           paa.person_id
    from pay_payroll_actions mpa,
         pay_payroll_actions apa,
         pay_assignment_actions aac,
         per_all_assignments_f paa,
         ff_archive_items fai,
         ff_archive_items fai1,
         ff_database_items fdi,
         ff_archive_item_contexts ac2,
         ff_archive_item_contexts ac3
where    mpa.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
and   paa.person_id = pay_magtape_generic.get_parameter_value('PERSON_ID')
and   apa.payroll_action_id = pay_core_utils.get_parameter('ARCHIVE_RUN_ID', mpa.legislative_parameters)
and   apa.payroll_action_id = aac.payroll_action_id
and   aac.assignment_id = paa.assignment_id
and   aac.assignment_action_id = fai.context1
and   fai.archive_item_id = ac2.archive_item_id and ac2.sequence_no = 2
and   fai.archive_item_id = ac3.archive_item_id and ac3.sequence_no = 3
and   fai.user_entity_id in (
                             select user_entity_id
                             from ff_database_items
                             where user_name = 'X_MOA410')
and   fai.context1 = fai1.context1
and   fai1.user_entity_id = fdi.user_entity_id
and   fdi.user_name = 'X_IR8S_C_INVALID_RECORDS'
and   fai1.value = 'Y'
and   (paa.effective_start_date <= to_date('31/' || '12/' || pay_core_utils.get_parameter('BASIS_YEAR', apa.legislative_parameters),'dd/mm/yyyy')
      and paa.effective_end_date >= to_date('01/' || '01/' || pay_core_utils.get_parameter('BASIS_YEAR', apa.legislative_parameters),'dd/mm/yyyy'))
order by paa.person_id, ac3.context;


-- Bug 3501956. Modified to retrieve information from PER_PEOPLE_EXTRA_INFO
  cursor a8b_esop_details is
    select distinct 'ASSIGNMENT_ACTION_ID=C',
           aac.assignment_action_id,
           'TAX_UNIT_ID=C',
           pay_core_utils.get_parameter('LEGAL_ENTITY_ID', apa.legislative_parameters) tax_unit_id,
	   'SOURCE_ID=C',
	   ac3.context source_id,
           'PERSON_EXTRA_ID=P',  -- 'ASS_EXTRA_ID=P',
           ac3.context person_extra_id,  -- ac3.context ass_extra_id,
           'PERSON_ID=P',
           to_char(paa.person_id) person_id
    from   per_all_assignments_f paa,
           pay_payroll_actions mpa,
           pay_assignment_actions mac,
           pay_payroll_actions apa,
           pay_assignment_actions aac,
           ff_archive_items fai,
           ff_archive_item_contexts ac2,
           ff_archive_item_contexts ac3
    where  mpa.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
    and    paa.assignment_id = pay_magtape_generic.get_parameter_value('ASSIGNMENT_ID')
    and    apa.payroll_action_id = pay_core_utils.get_parameter('ARCHIVE_RUN_ID', mpa.legislative_parameters)
    and    apa.payroll_action_id = aac.payroll_action_id
    and    paa.assignment_id = aac.assignment_id
    and    apa.action_status = 'C'
    and    aac.assignment_action_id = fai.context1
    and    fai.archive_item_id = ac2.archive_item_id and ac2.sequence_no = 2
    and    fai.archive_item_id = ac3.archive_item_id and ac3.sequence_no = 3
    and   fai.user_entity_id in (
                                 select user_entity_id
                                 from ff_database_items
                                 where user_name = 'X_A8B_OPTION')
    and   fai.value = 'E'
    /* Bug 2654499 */
    and    (paa.effective_start_date <= to_date('31/' || '12/' || pay_core_utils.get_parameter('BASIS_YEAR', apa.legislative_parameters),'dd/mm/yyyy')
           and paa.effective_end_date >= to_date('01/' || '01/' || pay_core_utils.get_parameter('BASIS_YEAR', apa.legislative_parameters),'dd/mm/yyyy'))
    and paa.assignment_id = mac.assignment_id     /* Bug 2676415 */
    order by paa.person_id, ac3.context;

-- Bug 3501956. Modified to retrieve information from PER_PEOPLE_EXTRA_INFO
  cursor a8b_eesop_details is
    select distinct 'ASSIGNMENT_ACTION_ID=C',
           aac.assignment_action_id,
           'TAX_UNIT_ID=C',
           pay_core_utils.get_parameter('LEGAL_ENTITY_ID', apa.legislative_parameters) tax_unit_id,
           'SOURCE_ID=C',
           ac3.context source_id,
           'PERSON_EXTRA_ID=P',    -- 'ASS_EXTRA_ID=P',
           ac3.context person_extra_id,  -- ac3.context ass_extra_id,
           'PERSON_ID=P',
           to_char(paa.person_id) person_id
    from   per_all_assignments_f paa,
           pay_payroll_actions mpa,
           pay_assignment_actions mac,
           pay_payroll_actions apa,
           pay_assignment_actions aac,
           ff_archive_items fai,
           ff_archive_item_contexts ac2,
           ff_archive_item_contexts ac3
    where  mpa.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
    and    paa.assignment_id = pay_magtape_generic.get_parameter_value('ASSIGNMENT_ID')
    and    apa.payroll_action_id = pay_core_utils.get_parameter('ARCHIVE_RUN_ID', mpa.legislative_parameters)
    and    apa.payroll_action_id = aac.payroll_action_id
    and    paa.assignment_id = aac.assignment_id
    and    apa.action_status = 'C'
    and    aac.assignment_action_id = fai.context1
    and    fai.archive_item_id = ac2.archive_item_id and ac2.sequence_no = 2
    and    fai.archive_item_id = ac3.archive_item_id and ac3.sequence_no = 3
    and   fai.user_entity_id in (
                                 select user_entity_id
                                 from ff_database_items
                                 where user_name = 'X_A8B_OPTION')
    and   fai.value = 'EE'
    /* Bug 2654499 */
    and    (paa.effective_start_date <= to_date('31/' || '12/' || pay_core_utils.get_parameter('BASIS_YEAR', apa.legislative_parameters),'dd/mm/yyyy')
           and paa.effective_end_date >= to_date('01/' || '01/' || pay_core_utils.get_parameter('BASIS_YEAR', apa.legislative_parameters),'dd/mm/yyyy'))
    and paa.assignment_id = mac.assignment_id
    order by paa.person_id, ac3.context;

-- Bug 3501956. Modified to retrieve information from PER_PEOPLE_EXTRA_INFO
  cursor a8b_csop_details is
    select distinct 'ASSIGNMENT_ACTION_ID=C',
           aac.assignment_action_id,
           'TAX_UNIT_ID=C',
           pay_core_utils.get_parameter('LEGAL_ENTITY_ID', apa.legislative_parameters) tax_unit_id,
           'SOURCE_ID=C',
           ac3.context source_id,
           'PERSON_EXTRA_ID=P',   -- 'ASS_EXTRA_ID=P'
           ac3.context person_extra_id,  -- ac3.context ass_extra_id
           'PERSON_ID=P',
           to_char(paa.person_id) person_id
    from   per_all_assignments_f paa,
           pay_payroll_actions mpa,
           pay_assignment_actions mac,
           pay_payroll_actions apa,
           pay_assignment_actions aac,
           ff_archive_items fai,
           ff_archive_item_contexts ac2,
           ff_archive_item_contexts ac3
    where  mpa.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
    and    paa.assignment_id = pay_magtape_generic.get_parameter_value('ASSIGNMENT_ID')
    and    apa.payroll_action_id = pay_core_utils.get_parameter('ARCHIVE_RUN_ID', mpa.legislative_parameters)
    and    apa.payroll_action_id = aac.payroll_action_id
    and    paa.assignment_id = aac.assignment_id
    and    apa.action_status = 'C'
    and    aac.assignment_action_id = fai.context1
    and    fai.archive_item_id = ac2.archive_item_id and ac2.sequence_no = 2
    and    fai.archive_item_id = ac3.archive_item_id and ac3.sequence_no = 3
    and   fai.user_entity_id in (
                                 select user_entity_id
                                 from ff_database_items
                                 where user_name = 'X_A8B_OPTION')
    and   fai.value = 'C'
    /* Bug 2654499 */
    and    (paa.effective_start_date <= to_date('31/' || '12/' || pay_core_utils.get_parameter('BASIS_YEAR', apa.legislative_parameters),'dd/mm/yyyy')
           and paa.effective_end_date >= to_date('01/' || '01/' || pay_core_utils.get_parameter('BASIS_YEAR', apa.legislative_parameters),'dd/mm/yyyy'))
    and    paa.assignment_id = mac.assignment_id
    order by paa.person_id, ac3.context;

--Bug 7415444, added new cursor for A8B NSOP details
  cursor a8b_nsop_details is
    select distinct 'ASSIGNMENT_ACTION_ID=C',
           aac.assignment_action_id,
           'TAX_UNIT_ID=C',
           pay_core_utils.get_parameter('LEGAL_ENTITY_ID', apa.legislative_parameters) tax_unit_id,
           'SOURCE_ID=C',
           ac3.context source_id,
           'PERSON_EXTRA_ID=P',   -- 'ASS_EXTRA_ID=P'
           ac3.context person_extra_id,  -- ac3.context ass_extra_id
           'PERSON_ID=P',
           to_char(paa.person_id) person_id
    from   per_all_assignments_f paa,
           pay_payroll_actions mpa,
           pay_assignment_actions mac,
           pay_payroll_actions apa,
           pay_assignment_actions aac,
           ff_archive_items fai,
           ff_archive_item_contexts ac2,
           ff_archive_item_contexts ac3
    where  mpa.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
    and    paa.assignment_id = pay_magtape_generic.get_parameter_value('ASSIGNMENT_ID')
    and    apa.payroll_action_id = pay_core_utils.get_parameter('ARCHIVE_RUN_ID', mpa.legislative_parameters)
    and    apa.payroll_action_id = aac.payroll_action_id
    and    paa.assignment_id = aac.assignment_id
    and    apa.action_status = 'C'
    and    aac.assignment_action_id = fai.context1
    and    fai.archive_item_id = ac2.archive_item_id and ac2.sequence_no = 2
    and    fai.archive_item_id = ac3.archive_item_id and ac3.sequence_no = 3
    and   fai.user_entity_id in (
                                 select user_entity_id
                                 from ff_database_items
                                 where user_name = 'X_A8B_OPTION')
    and   fai.value = 'N'
    /* Bug 2654499 */
    and    (paa.effective_start_date <= to_date('31/' || '12/' || pay_core_utils.get_parameter('BASIS_YEAR', apa.legislative_parameters),'dd/mm/yyyy')
           and paa.effective_end_date >= to_date('01/' || '01/' || pay_core_utils.get_parameter('BASIS_YEAR', apa.legislative_parameters),'dd/mm/yyyy'))
    and    paa.assignment_id = mac.assignment_id
    order by paa.person_id, ac3.context;



-- Bug 3501956. Modified to retrieve information from PER_PEOPLE_EXTRA_INFO
  cursor a8b_total_details is
    select distinct 'ASSIGNMENT_ACTION_ID=C',
           aac.assignment_action_id,
           'TAX_UNIT_ID=C',
           pay_core_utils.get_parameter('LEGAL_ENTITY_ID', apa.legislative_parameters) tax_unit_id,
           'PERSON_ID=P',
           to_char(paa.person_id) person_id
    from   per_all_assignments_f paa,
           pay_payroll_actions mpa,
           pay_assignment_actions mac,
           pay_payroll_actions apa,
           pay_assignment_actions aac,
           ff_archive_items fai,
           ff_archive_item_contexts ac2,
           ff_archive_item_contexts ac3
    where  mpa.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
    and    paa.assignment_id = pay_magtape_generic.get_parameter_value('ASSIGNMENT_ID')
    and    apa.payroll_action_id = pay_core_utils.get_parameter('ARCHIVE_RUN_ID', mpa.legislative_parameters)
    and    apa.payroll_action_id = aac.payroll_action_id
    and    paa.assignment_id = aac.assignment_id
    and    apa.action_status = 'C'
    and    aac.assignment_action_id = fai.context1
    and    fai.archive_item_id = ac2.archive_item_id and ac2.sequence_no = 2
    and    fai.archive_item_id = ac3.archive_item_id and ac3.sequence_no = 3
    and   fai.user_entity_id in (
                                 select user_entity_id
                                 from ff_database_items
                                 where user_name = 'X_A8B_OPTION')
    /* Bug 2654499 */
    and    (paa.effective_start_date <= to_date('31/' || '12/' || pay_core_utils.get_parameter('BASIS_YEAR', apa.legislative_parameters),'dd/mm/yyyy')
           and paa.effective_end_date >= to_date('01/' || '01/' || pay_core_utils.get_parameter('BASIS_YEAR', apa.legislative_parameters),'dd/mm/yyyy'))
    and    paa.assignment_id = mac.assignment_id
    order by paa.person_id;
end pay_sg_iras_magtape;

/
