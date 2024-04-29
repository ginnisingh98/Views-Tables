--------------------------------------------------------
--  DDL for Package PAY_SG_IRAS_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_SG_IRAS_ARCHIVE" AUTHID CURRENT_USER as
/* $Header: pysgirar.pkh 120.5.12010000.1 2008/07/27 23:41:21 appldev ship $ */
    level_cnt  number;

    --
    type t_balanceid_store_rec is record
    (  user_entity_id             ff_user_entities.user_entity_id%type,
       defined_balance_id         pay_defined_balances.defined_balance_id%type );
    --
    type t_ytd_balanceid_store_tab is table of  t_balanceid_store_rec index by binary_integer;
    t_ytd_balanceid_store         t_ytd_balanceid_store_tab;
    t_ytd_a8a_balanceid_store     t_ytd_balanceid_store_tab;
     --
    type t_month_balanceid_store_tab is table of  t_balanceid_store_rec index by binary_integer;
    t_month_balanceid_store       t_month_balanceid_store_tab;
    --
    ---------------------------------------------------------------------
    -- 3435334 Record of person_ids with same national identifier
    ---------------------------------------------------------------------
    type t_person_id_tab is table of per_all_people_f.person_id%type index by binary_integer;
    g_person_id_tab               t_person_id_tab;
    --
    type t_rehire_same_person_record is record
    (
        person_id  per_all_people_f.person_id%type
    );
    --------------------------------------------------------------------
    -- Bug 4688761 Record of person_ids with archived person_id
    --------------------------------------------------------------------
    type t_archived_person_rec is record
    (
        person_id  per_all_people_f.person_id%type
    );
    type t_archived_person_tab is table of t_archived_person_rec index by binary_integer;
    t_archived_person t_archived_person_tab;

    -------------------------------------------------------------------
    -- 3956870  Defined to store the balance status details
    -------------------------------------------------------------------
   type balance_status_store_rec is record
   (   business_group_id          pay_balance_validation.business_group_id%type,
       defined_balance_id         pay_balance_validation.defined_balance_id%type,
       run_balance_status         pay_balance_validation.run_balance_status%type
    );
    --
    type t_balance_status_store_tab is table of balance_status_store_rec  index by binary_integer;
    t_bal_stat_rec      t_balance_status_store_tab;

    --------------------------------------------------------------------
    -- These are PUBLIC procedures are required by the Archive process.
    -- Their names are stored in PAY_REPORT_FORMAT_MAPPINGS_F so that
    -- the archive process knows what code to execute for each step of
    -- the archive.
    --------------------------------------------------------------------
    procedure range_code
     ( p_payroll_action_id  in pay_payroll_actions.payroll_action_id%type,
       p_sql               out nocopy varchar2 );
    --
    procedure assignment_action_code
     ( p_payroll_action_id  in pay_payroll_actions.payroll_action_id%type,
       p_start_person_id    in per_all_people_f.person_id%type,
       p_end_person_id      in per_all_people_f.person_id%type,
       p_chunk              in number );
    --
    procedure initialization_code
     ( p_payroll_action_id  in pay_payroll_actions.payroll_action_id%type );
    --
    procedure archive_code
     ( p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type,
       p_effective_date        in date );
    ----------------------------------------------------------------------------
    -- Bug: 3118540 Procedures called from SRS 'IR8S Ad Hoc Printed Archive'
    ----------------------------------------------------------------------------
    procedure assignment_action_code_adhoc
     ( p_payroll_action_id    in  pay_payroll_actions.payroll_action_id%type,
       p_start_person_id    in  per_all_people_f.person_id%type,
       p_end_person_id      in  per_all_people_f.person_id%type,
       p_chunk              in  number );
    --
    procedure initialization_code_adhoc
     (  p_payroll_action_id  in pay_payroll_actions.payroll_action_id%type );
    --
    Function get_archive_value
     (  p_user_entity_name     in ff_user_entities.user_entity_name%type,
        p_assignment_action_id in pay_assignment_actions.assignment_action_id%type ) return varchar2;
    --
    procedure deinit_code
            ( p_payroll_action_id  in pay_payroll_actions.payroll_action_id%type );
    ----------------------------------------------------------------------------
    -- These are PRIVATE procedures that required for the Archive
    -- process.
    --------------------------------------------------------------------
    procedure archive_balances
     ( p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type,
       p_person_id             in per_all_people_f.person_id%type,
       p_business_group_id     in hr_organization_units.business_group_id%type,
       p_tax_unit_id           in ff_archive_item_contexts.context%type,
       p_basis_year            in varchar2 );
    --
    procedure archive_balance_dates
     ( p_person_id in per_all_people_f.person_id%TYPE,
       p_basis_year in varchar2,
       p_business_group_id     in hr_organization_units.business_group_id%type,
       p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type,
       p_run_ass_action_id     in pay_assignment_actions.assignment_action_id%type,
       p_tax_unit_id           in pay_assignment_actions.tax_unit_id%type );
    --
    procedure archive_org_info
     ( p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type,
       p_business_group_id     in hr_organization_units.business_group_id%type,
       p_legal_entity_id       in hr_organization_units.organization_id%type,
       p_person_id             in per_all_people_f.person_id%type,
       p_basis_start           in date,
       p_basis_end             in date );
    --
    procedure archive_person_details
     ( p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type,
       p_person_id             in per_all_people_f.person_id%type,
       p_basis_start           in date,
       p_basis_end             in date );
    --
    procedure archive_person_addresses
     ( p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type,
       p_person_id             in per_all_people_f.person_id%type,
       p_basis_start           in date,
       p_basis_end             in date );
    --
    procedure archive_person_cq_addresses
     ( p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type,
       p_person_id             in per_all_people_f.person_id%type,
       p_basis_start           in date,
       p_basis_end             in date );
    --
    procedure archive_emp_details
     ( p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type,
       p_person_id             in per_all_people_f.person_id%type,
       p_basis_start           in date,
       p_basis_end             in date );
    --
    procedure archive_people_flex
     ( p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type,
       p_person_id             in per_all_people_f.person_id%type,
       p_basis_start           in date,
       p_basis_end             in date );
    --
    procedure archive_person_eits
     ( p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type,
       p_person_id             in per_all_people_f.person_id%type,
       p_basis_start           in date,
       p_basis_end             in date );

    --------------------------------------------------------------------------
    -- Bug 5435088, Added for payroll date
    --------------------------------------------------------------------------
    procedure archive_payroll_date
     ( p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type,
       p_business_group_id     in hr_organization_units.business_group_id%type,
       p_legal_entity_id       in hr_organization_units.organization_id%type,
       p_person_id             in per_all_people_f.person_id%type,
       p_basis_year            in varchar2);
    --
    --
    --------------------------------------------------------------------------
    -- Bug #4688761, added legal_entity_id
    -- Bug 4890964, added assignment_id
    --------------------------------------------------------------------------
    procedure archive_assignment_eits
     ( p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type,
       p_person_id             in per_all_people_f.person_id%type,
       p_assignment_id         in per_all_assignments_f.assignment_id%type,
       p_legal_entity_id       in hr_organization_units.organization_id%type,
       p_basis_start           in date,
       p_basis_end             in date );
    --
    --------------------------------------------------------------------------
    -- Bug #5078454
    --------------------------------------------------------------------------
    procedure archive_ass_bonus_date_eits
     ( p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type,
       p_person_id             in per_all_people_f.person_id%type,
       p_assignment_id         in per_all_assignments_f.assignment_id%type,
       p_legal_entity_id       in hr_organization_units.organization_id%type,
       p_basis_start           in date,
       p_basis_end             in date );
    --
    --------------------------------------------------------------------------
    -- Bug 5435088
    --------------------------------------------------------------------------
    procedure archive_ass_payment_method
     ( p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type,
       p_person_id             in per_all_people_f.person_id%type,
       p_assignment_id         in per_all_assignments_f.assignment_id%type,
       p_legal_entity_id       in hr_organization_units.organization_id%type,
       p_basis_start           in date,
       p_basis_end             in date);
    --
    -------------------------------------------------------------------------
    -- Bug #4688761, added legal_entity_id
    -------------------------------------------------------------------------
    procedure archive_os_assignment
     ( p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type,
       p_person_id             in per_all_people_f.person_id%type,
       p_legal_entity_id       in hr_organization_units.organization_id%type,
       p_basis_start           in date,
       p_basis_end             in date );
    --
    --------------------------------------------------------------------------
    -- Bug 4890964, added assignment_id
    --------------------------------------------------------------------------
    procedure archive_job_designation
     ( p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type,
       p_person_id             in per_all_people_f.person_id%type,
       p_assignment_id         in per_all_assignments_f.assignment_id%type,
       p_legal_entity_id       in hr_organization_units.organization_id%type,
       p_basis_start           in date,
       p_basis_end             in date,
       p_er_designation_type   in hr_organization_information.org_information17%type,
       p_er_position_seg_type  in hr_organization_information.org_information18%type );
    --
    ---------------------------------------------------------------------------
    -- Bug #4314453, added legal_entity_id
    ---------------------------------------------------------------------------
    procedure archive_shares_details
     ( p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type,
       p_person_id             in per_all_people_f.person_id%type,
       p_tax_unit_id           in ff_archive_item_contexts.context%type,
       p_basis_start           in date,
       p_basis_end             in date );
    --
    procedure archive_ir8s_c_details
     ( p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type,
       p_person_id             in per_all_people_f.person_id%type,
       p_tax_unit_id           in ff_archive_item_contexts.context%type,
       p_business_group_id     in per_assignments_f.business_group_id%type,
       p_basis_start           in date,
       p_basis_end             in date );
    --
    procedure archive_ir8s_c_detail_moas
     ( p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type,
       p_1_person_id           in per_all_people_f.person_id%type,
       p_person_id             in per_all_people_f.person_id%type,
       p_tax_unit_id           in ff_archive_item_contexts.context%type,
       p_business_group_id     in per_assignments_f.business_group_id%type,
       p_basis_start           in date,
       p_basis_end             in date );
    --
    procedure archive_item
     ( p_user_entity_name      in ff_user_entities.user_entity_name%type,
       p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type,
       p_archive_value         in ff_archive_items.value%type );
    --
    procedure archive_item_2
     ( p_user_entity_name      in ff_user_entities.user_entity_name%type,
       p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type,
       p_archive_value         in ff_archive_items.value%type,
       p_context_value2        in ff_archive_item_contexts.context%type );
    --
    procedure archive_item_3
     ( p_user_entity_name      in ff_user_entities.user_entity_name%type,
       p_assignment_action_id  in pay_assignment_actions.assignment_action_id%type,
       p_archive_value         in ff_archive_items.value%type,
       p_context_value2        in ff_archive_item_contexts.context%type,
       p_context_value3        in ff_archive_item_contexts.context%type );
    -------------------------------------------------------------------------------
    -- Bug 3435334 - New function introduced for implementing duplicate person logic
    -- with pre-processor
    -------------------------------------------------------------------------------
    function employee_if_latest
     ( p_national_identifier   in  varchar2,
       p_person_id             in  per_all_people_f.person_id%type,
       p_setup_action_id       in  pay_payroll_actions.payroll_action_id%type,
       p_report_type           in  varchar2 ) return boolean ;
    --
    ----------------------------------------------------------------------------
    -- Bug 4688761 - New function to check if the person_id has been archived once
    ----------------------------------------------------------------------------
    function person_if_archived (p_person_id       in per_all_people_f.person_id%type)           return boolean;
    --
    ----------------------------------------------------------------------------
    -- Bug 4890964 - The function to get the LE if it is with the latest primary
    --               assignment for multi-LEs.
    ----------------------------------------------------------------------------
    function pri_if_latest
                    ( p_person_id   in per_all_people_f.person_id%type
                    , p_tax_unit_id in ff_archive_item_contexts.context%type
                    , p_basis_start in date
                    , p_basis_end   in date)  return boolean;
    --
    ----------------------------------------------------------------------------
    -- Bug 4890964 - The function to get the assignment with LE if its the
    --               latest primary assignment
    ----------------------------------------------------------------------------
    function pri_LE_if_latest
                    ( p_person_id   in per_all_people_f.person_id%type
                    , p_tax_unit_id in ff_archive_item_contexts.context%type
                    , p_basis_start in date
                    , p_basis_end   in date)  return number;
    --
    ----------------------------------------------------------------------------
    -- Bug 4890964 - The function to get the assignment with LE if its the
    --               latest assignment without primay flag defined.
    ----------------------------------------------------------------------------
    function id_LE_if_latest
                    ( p_person_id   in per_all_people_f.person_id%type
                    , p_tax_unit_id in ff_archive_item_contexts.context%type
                    , p_basis_start in date
                    , p_basis_end   in date)  return number;
    --
    ---------------------------------------------------------------------------
    -- Bug 5435088 - The function to check if a value is numeric
    ---------------------------------------------------------------------------
    function check_is_number (p_value in varchar2) return boolean;

    ---------------------------------------------------------------------------
    -- Bug 5435088 - The function to check if the payer id is valid
    ---------------------------------------------------------------------------
    function check_payee_id (p_ee_income_tax_number in varchar2,
                             p_payee_id_type     in varchar2) return char;

    ---------------------------------------------------------------------------
    -- Bug 5435088 - The function to get country code
    ---------------------------------------------------------------------------
    function get_country_code (p_country in varchar2) return varchar2;


    ---------------------------------------------------------------------------
    -- Bug 5435088 - The function to check if the payee id is valid
    ---------------------------------------------------------------------------
    function check_payer_id (p_er_income_tax_number in varchar2,
                             p_er_payer_id     in varchar2) return char;


    ---------------------------------------------------------------------
    -- PUBLIC cursors used to retrieve data and pass it to IRAS formulae.
    -- Passes parameters to SG_ARCHIVE_HEADER formula
    -- Just need 1 context for Org Info
    ---------------------------------------------------------------------
    cursor  archive_header is
    select  'ASSIGNMENT_ACTION_ID=C',
            pac.assignment_action_id,
            'BASIS_YEAR=P',
            pay_core_utils.get_parameter('BASIS_YEAR', ppa.legislative_parameters) basis_year,
            'CREATION_DATE=P',
            to_char(sysdate,'YYYYMMDD') creation_date
    from    pay_payroll_actions ppa,
            pay_assignment_actions pac,
            ff_archive_items    ffi,
            ff_database_items  fdi
    where   ppa.payroll_action_id  = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
    and     ppa.payroll_action_id  = pac.payroll_action_id
    and     pac.action_status      = 'C'
    and     ffi.context1           = pac.assignment_action_id   /* Added joins for bug:3232300 */
    and     fdi.user_name          = 'X_SG_LEGAL_ENTITY_SG_LEGAL_ENTITY_NAME'
    and     ffi.user_entity_id     = fdi.user_entity_id
    and     rownum=1;
    ---------------------------------------------------------------------
    -- Passes parameters to SG_ARCHIVE_DETAILS formula
    ---------------------------------------------------------------------
    cursor archive_details is
    select distinct
           'ASSIGNMENT_ACTION_ID=C',
           pac.assignment_action_id,
           'TAX_UNIT_ID=C',
           to_number(ac2.context) tax_unit_id,
           'BASIS_YEAR=P',
           pay_core_utils.get_parameter('BASIS_YEAR', ppa.legislative_parameters) basis_year,
           'P_ASSIGNMENT_ACTION_ID=P',
           to_char(pac.assignment_action_id),
           'PERSON_ID=P',
           to_char(paa.person_id) person_id,
           'ASSIGNMENT_NUMBER=P',
           paa.assignment_number assignment_number
    from   per_all_assignments_f paa,
           pay_payroll_actions ppa,
           pay_assignment_actions pac,
           ff_archive_items fai,
           ff_archive_item_contexts ac2
    where  ppa.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
    and    pac.action_status = 'C'
    and    ppa.payroll_action_id = pac.payroll_action_id
    and    paa.assignment_id = pac.assignment_id
    and    ppa.business_group_id = pay_magtape_generic.get_parameter_value('BUSINESS_GROUP_ID')
    and    paa.business_group_id = ppa.business_group_id
    and    fai.context1 = pac.assignment_action_id
    and    fai.archive_item_id = ac2.archive_item_id and ac2.sequence_no = 2
    order by paa.person_id;
    ---------------------------------------------------------------------
    -- Passes parameters to SG_ARCHIVE_DETAILS formula
    ---------------------------------------------------------------------
    cursor archive_org_details is
    select distinct
           'TAX_UNIT_ID=C',
           to_number(ac2.context) tax_unit_id,
           'BASIS_YEAR=P',
           pay_core_utils.get_parameter('BASIS_YEAR', ppa.legislative_parameters) basis_year
    from   per_all_assignments_f paa,
           pay_payroll_actions ppa,
           pay_assignment_actions pac,
           ff_archive_items fai,
           ff_archive_item_contexts ac2
    where  ppa.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
    and    pac.action_status = 'C'
    and    ppa.payroll_action_id = pac.payroll_action_id
    and    paa.assignment_id = pac.assignment_id
    and    ppa.business_group_id = pay_magtape_generic.get_parameter_value('BUSINESS_GROUP_ID')
    AND    paa.business_group_id = ppa.business_group_id
    and    fai.context1 = pac.assignment_action_id
    and    fai.archive_item_id = ac2.archive_item_id and ac2.sequence_no = 2
    order by paa.person_id;
    ---------------------------------------------------------------------
end pay_sg_iras_archive;

/
