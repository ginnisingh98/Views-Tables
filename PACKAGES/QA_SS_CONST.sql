--------------------------------------------------------
--  DDL for Package QA_SS_CONST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_SS_CONST" AUTHID CURRENT_USER AS
/* $Header: qltsscnb.pls 120.14.12010000.2 2010/02/08 05:48:08 skolluku ship $ */


--
-- This package will now serve all server-side packages by
-- maintaining constants and useful data types.
--

  TYPE Eqr_Array IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;

    def_array Eqr_Array;
    value_array Eqr_Array;

  TYPE names_table is TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

  TYPE charid_table is TABLE OF NUMBER INDEX BY BINARY_INTEGER;

  TYPE Ctx_Table is TABLE OF VARCHAR2(255) INDEX BY BINARY_INTEGER;

  TYPE num_table is TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE var150_table is TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;
  TYPE var30_table is TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

    def30_tab var30_table; -- Used as an empty default table

  TYPE bool_table is TABLE OF BOOLEAN INDEX BY BINARY_INTEGER;
  TYPE var2000_table is TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;

    no_of_cols NUMBER := 0;
    no_of_rows CONSTANT NUMBER := 25;
    max_cols CONSTANT NUMBER := 160;
    plan_name_i qa_plans.name%TYPE := NULL;
    org_code_i mtl_parameters.organization_code%TYPE := NULL;
    debug_mode BOOLEAN := TRUE;
    debug_variable NUMBER;

        -- G_Wip_Entity_Type NUMBER;
        -- G_Wip_Repetitive_Schedule_Id NUMBER;
        -- G_Po_Header_Id NUMBER;
        -- G_Po_Release_Id NUMBER;
        -- G_Po_Line_Id NUMBER;
        -- G_Line_Location_Id NUMBER;
        -- G_Po_Distribution_Id NUMBER;
        -- G_Organization_Id NUMBER;
        -- G_Item_Id NUMBER;
        -- G_Wip_Entity_Id NUMBER;
        -- G_Wip_Line_Id NUMBER;

-------------------------------------------

--
-- Below are the Char_ID values for all collection elements
--

    transaction_date                CONSTANT NUMBER := 1;
    organization_id                 CONSTANT NUMBER := 2;
    department                      CONSTANT NUMBER := 3;
    quantity                        CONSTANT NUMBER := 4;
    qa_created_by_name              CONSTANT NUMBER := 5;
    quality_code                    CONSTANT NUMBER := 6;
    comments                        CONSTANT NUMBER := 7;
    inspection_result               CONSTANT NUMBER := 8;
    supplier_lot                    CONSTANT NUMBER := 9;
    item                            CONSTANT NUMBER := 10;
    item_category                   CONSTANT NUMBER := 11;
    uom                             CONSTANT NUMBER := 12;
    revision                        CONSTANT NUMBER := 13;
    subinventory                    CONSTANT NUMBER := 14;
    locator                         CONSTANT NUMBER := 15;
    lot_number                      CONSTANT NUMBER := 16;
    serial_number                   CONSTANT NUMBER := 17;
    reason_code                     CONSTANT NUMBER := 18;
    job_name                        CONSTANT NUMBER := 19;
    production_line                 CONSTANT NUMBER := 20;
    to_op_seq_num                   CONSTANT NUMBER := 21;
    from_op_seq_num                 CONSTANT NUMBER := 22;
    to_intraoperation_step          CONSTANT NUMBER := 23;
    from_intraoperation_step        CONSTANT NUMBER := 24;
    resource_code                   CONSTANT NUMBER := 25;
    vendor_name                     CONSTANT NUMBER := 26;
    po_number                       CONSTANT NUMBER := 27;
    po_line_num                     CONSTANT NUMBER := 28;
    po_shipment_num                 CONSTANT NUMBER := 29;

    receipt_num                     CONSTANT NUMBER := 31;
    customer_name                   CONSTANT NUMBER := 32;
    sales_order                     CONSTANT NUMBER := 33;
    rma_number                      CONSTANT NUMBER := 34;
    order_line                      CONSTANT NUMBER := 35;
    ship_to                         CONSTANT NUMBER := 36;
    location                        CONSTANT NUMBER := 37;
    collection_id                   CONSTANT NUMBER := 38;
    name                            CONSTANT NUMBER := 39;
    destination_type                CONSTANT NUMBER := 40;
    return_to                       CONSTANT NUMBER := 41;
    employee                        CONSTANT NUMBER := 42;
    operation_code                  CONSTANT NUMBER := 45;
    plan_type                       CONSTANT NUMBER := 46;
    department_class                CONSTANT NUMBER := 48;
    qa_last_update_date             CONSTANT NUMBER := 49;
    qa_last_updated_by_name         CONSTANT NUMBER := 50;
    qa_creation_date                CONSTANT NUMBER := 51;
    item_description                CONSTANT NUMBER := 52;
    transaction_type                CONSTANT NUMBER := 53;

    comp_item                       CONSTANT NUMBER := 60;
    comp_uom                        CONSTANT NUMBER := 62;
    comp_revision                   CONSTANT NUMBER := 63;
    comp_subinventory               CONSTANT NUMBER := 64;
    comp_locator                    CONSTANT NUMBER := 65;
    comp_lot_number                 CONSTANT NUMBER := 66;
    comp_serial_number              CONSTANT NUMBER := 67;
    customer_description            CONSTANT NUMBER := 68;
    supplier_description            CONSTANT NUMBER := 69;
    po_receipt_date                 CONSTANT NUMBER := 71;
    po_shipped_date                 CONSTANT NUMBER := 72;
    po_packing_slip                 CONSTANT NUMBER := 73;
    received_by                     CONSTANT NUMBER := 74;
    freight_carrier                 CONSTANT NUMBER := 75;
    num_of_containers               CONSTANT NUMBER := 76;
    order_type                      CONSTANT NUMBER := 77;
    ordered_quantity                CONSTANT NUMBER := 78;
    expected_receipt_date           CONSTANT NUMBER := 79;
    vender_item_number              CONSTANT NUMBER := 80;
    vendor_item_number              CONSTANT NUMBER := 80;
                    -- charid 80 twice purposefully
                    -- to take care of seed115 typo
                    -- now can use either spelling in my code

    hazard_class                    CONSTANT NUMBER := 81;
    un_number                       CONSTANT NUMBER := 82;
    po_routing_name                 CONSTANT NUMBER := 83;

    defect_code                     CONSTANT NUMBER := 100;
    to_department                   CONSTANT NUMBER := 107;
    to_operation_code               CONSTANT NUMBER := 108;
    requestor                       CONSTANT NUMBER := 109;
    po_release_num                  CONSTANT NUMBER := 110;
    parent_quantity                 CONSTANT NUMBER := 111;
    uom_name                        CONSTANT NUMBER := 112;
    insp_reason_code                CONSTANT NUMBER := 113;
    insp_supplier_lot               CONSTANT NUMBER := 114;
    asl_status                      CONSTANT NUMBER := 115;

    project_number                  CONSTANT NUMBER := 121;
    task_number                     CONSTANT NUMBER := 122;
    job_complete                    CONSTANT NUMBER := 123;
    avail_to_complete               CONSTANT NUMBER := 124;
    vendor_site_code                CONSTANT NUMBER := 130;
    build_sequence                  CONSTANT NUMBER := 133;
    schedule_number                 CONSTANT NUMBER := 134;
    schedule_group_name             CONSTANT NUMBER := 135;
    bom_revision                    CONSTANT NUMBER := 136;
    bom_revision_date               CONSTANT NUMBER := 137;
    routing_revision                CONSTANT NUMBER := 138;
    routing_revision_date           CONSTANT NUMBER := 139;
    accounting_class                CONSTANT NUMBER := 140;
    demand_class                    CONSTANT NUMBER := 141;
    scrap_account_alias             CONSTANT NUMBER := 142;
    scrap_account                   CONSTANT NUMBER := 143;
    scrap_op_seq                    CONSTANT NUMBER := 144;
    kanban_number                   CONSTANT NUMBER := 145;
    ship_to_location                CONSTANT NUMBER := 146;
    item_instance_serial            CONSTANT NUMBER := 147; -- Bug 9203907
    license_plate_number                CONSTANT NUMBER := 150;
    inspection_quantity             CONSTANT NUMBER := 151;
    lot_inspection_qty              CONSTANT NUMBER := 152;
    serial_inspection_qty           CONSTANT NUMBER := 153;
    contract_number                         CONSTANT NUMBER := 154;
    contract_line_number                CONSTANT NUMBER := 155;
    deliverable_number                  CONSTANT NUMBER := 156;
    intransit_shipment_num          CONSTANT NUMBER := 157;
    rma_line_num                    CONSTANT NUMBER := 158;
    customer_item_num               CONSTANT NUMBER := 159;
    source_document_code            CONSTANT NUMBER := 160;
    receipt_source_code             CONSTANT NUMBER := 161;
    asset_group                     CONSTANT NUMBER := 162;
    --dgupta: Start R12 EAM Integration. Bug 4345492
    asset_instance_number           CONSTANT NUMBER := 2147483550;
    --dgupta: End R12 EAM Integration. Bug 4345492
    asset_number                    CONSTANT NUMBER := 163;
    asset_activity                  CONSTANT NUMBER := 164;
    work_order                      CONSTANT NUMBER := 165;
    step                            CONSTANT NUMBER := 166;
    party_name                      CONSTANT NUMBER := 167;

-- added the following to include new hardcoded element followup activity, transfer license plate number
-- saugupta
    xfr_license_plate_number        CONSTANT NUMBER := 2147483574;
    followup_activity               CONSTANT NUMBER := 2147483575;

    --
    -- Included the following newly added collection elements
    -- for ASO project. Existing vacancies in QA_CHARS seed
    -- are used instead of appending to the maximum CHAR_ID of seed
    -- rkunchal Thu Jul 25 01:43:48 PDT 2002
    --

    item_instance                   CONSTANT NUMBER := 30;
    service_request                 CONSTANT NUMBER := 43;
    maintenance_requirement         CONSTANT NUMBER := 44;
    rework_job                      CONSTANT NUMBER := 47;
    counter_name                    CONSTANT NUMBER := 54;
    counter_reading                 CONSTANT NUMBER := 55;

    disposition_source              CONSTANT NUMBER := 56;
    disposition_action              CONSTANT NUMBER := 57;
    disposition                     CONSTANT NUMBER := 58;
    disposition_status              CONSTANT NUMBER := 59;

    collection_plan                 CONSTANT NUMBER := 61;
    installed_base_lot              CONSTANT NUMBER := 84;

    inspection_type                 CONSTANT NUMBER := 87;
    engineering_approval            CONSTANT NUMBER := 88;
    purchasing_approval             CONSTANT NUMBER := 89;
    qa_approval                     CONSTANT NUMBER := 90;
    approval_required               CONSTANT NUMBER := 91;
    approval_confirmed              CONSTANT NUMBER := 92;
    launch_action                   CONSTANT NUMBER := 93;
    action_fired                    CONSTANT NUMBER := 94;
    launch_workflow                 CONSTANT NUMBER := 95;
    mechanic                        CONSTANT NUMBER := 96;
    inspector                       CONSTANT NUMBER := 97;
    work_order_status               CONSTANT NUMBER := 98;
    due_date                        CONSTANT NUMBER := 99;
    operation_status                CONSTANT NUMBER := 125;
    approval_requested              CONSTANT NUMBER := 131;
    disposition_message             CONSTANT NUMBER := 132;

    --
    -- End of inclusions for ASO project
    -- rkunchal Thu Jul 25 01:43:48 PDT 2002
    --

--
-- See Bug 588213
-- To support the new hardcoded element Maintenance Op Seq Number
-- to be used along with Maintenance Workorder
-- rkunchal Mon Sep 23 23:46:28 PDT 2002
--
    maintenance_op_seq              CONSTANT NUMBER := 199;
--
-- End of inclusions for Bug 2588213
--

-- Start of inclusions for NCM Hardcode Elements.
-- suramasw Thu Oct 31 10:48:59 PST 2002.
-- Bug 2449067.

    nonconformance_source           CONSTANT NUMBER := 166;
    nonconform_severity             CONSTANT NUMBER := 175;
    nonconform_priority             CONSTANT NUMBER := 176;
    nonconformance_type             CONSTANT NUMBER := 177;
    nonconformance_code             CONSTANT NUMBER := 178;
    nonconformance_status           CONSTANT NUMBER := 183;
    date_opened                     CONSTANT NUMBER := 185;
    date_closed                     CONSTANT NUMBER := 186;
    days_to_close                   CONSTANT NUMBER := 187;
    lot_status                      CONSTANT NUMBER := 188;
    serial_status                   CONSTANT NUMBER := 189;
    bill_reference                  CONSTANT NUMBER := 2147483631;
    routing_reference               CONSTANT NUMBER := 2147483630;
    concurrent_request_id           CONSTANT NUMBER := 2147483629;
    to_subinventory                 CONSTANT NUMBER := 2147483628;
    to_locator                      CONSTANT NUMBER := 2147483627;
    receiving_trans_num             CONSTANT NUMBER := 2147483621;

    -- End of inclusions for NCM Hardcode Elements.

    -- Softcoded Elements for NCM Actions.

    quantity_nonconforming          CONSTANT NUMBER := 168;
    nonconforming_uom               CONSTANT NUMBER := 169;
    short_description               CONSTANT NUMBER := 170;
    detailed_description            CONSTANT NUMBER := 171;
    email_address                   CONSTANT NUMBER := 179;
    send_email                      CONSTANT NUMBER := 180;
    entered_by_user                 CONSTANT NUMBER := 181;
    nonconformance_number           CONSTANT NUMBER := 182;
    enter_details                   CONSTANT NUMBER := 184;
    process_name                    CONSTANT NUMBER := 190;
    process_step                    CONSTANT NUMBER := 191;
    nonconform_line_status          CONSTANT NUMBER := 192;
    note_type                       CONSTANT NUMBER := 193;
    notes                           CONSTANT NUMBER := 194;
    action_executed                 CONSTANT NUMBER := 195;
    action_executed_by              CONSTANT NUMBER := 196;
    action_type                     CONSTANT NUMBER := 197;
    action_description              CONSTANT NUMBER := 198;
    Action_Assigned_To              CONSTANT NUMBER := 2147483620;
    source_reference_id             CONSTANT NUMBER := 2147483647;
    source_ref_line_id              CONSTANT NUMBER := 2147483646;
    disposition_number              CONSTANT NUMBER := 2147483645;
    disposition_quantity            CONSTANT NUMBER := 2147483644;
    disposition_uom                 CONSTANT NUMBER := 2147483643;
    disposition_owner               CONSTANT NUMBER := 2147483642;
    source_owner                    CONSTANT NUMBER := 2147483641;
    disposition_desc                CONSTANT NUMBER := 2147483640;
    disposition_line_num            CONSTANT NUMBER := 2147483639;
    disposition_line_desc           CONSTANT NUMBER := 2147483638;
    implementation_by               CONSTANT NUMBER := 2147483637;
    implement_disposition           CONSTANT NUMBER := 2147483636;
    disposition_module              CONSTANT NUMBER := 2147483635;
    job_class                       CONSTANT NUMBER := 2147483634;
    job_start_date                  CONSTANT NUMBER := 2147483633;
    job_end_date                    CONSTANT NUMBER := 2147483632;
    date_required                   CONSTANT NUMBER := 2147483626;
    owner_email                     CONSTANT NUMBER := 2147483625;
    source_owner_email              CONSTANT NUMBER := 2147483624;
    nonconform_line_num             CONSTANT NUMBER := 2147483623;
    move_order_number               CONSTANT NUMBER := 2147483622;
    new_rework_job                  CONSTANT NUMBER := 2147483619;

    -- End of inclusions for NCM Actions.

    -- anagarwa  Wed Nov 13 16:41:40 PST 2002
    -- New NCM elements
    default_values                  CONSTANT NUMBER := 2147483618;
    nonconform_item_type            CONSTANT NUMBER := 2147483617;
    rework_op_seq_num               CONSTANT NUMBER := 2147483616;
    rework_operation_code           CONSTANT NUMBER := 2147483615;
    rework_department               CONSTANT NUMBER := 2147483614;
    resource_op_seq_num             CONSTANT NUMBER := 2147483613;
    assigned_units                  CONSTANT NUMBER := 2147483612;
    usage_rate                      CONSTANT NUMBER := 2147483611;

    --anagarwa Thu Nov 14 13:31:42 PST 2002
    -- Start inclusion for CAR elements
    request_source                  CONSTANT NUMBER := 2147483608;
    request_priority                CONSTANT NUMBER := 2147483605;
    request_severity                CONSTANT NUMBER := 2147483604;
    request_status                  CONSTANT NUMBER := 2147483601;
    eco_name                        CONSTANT NUMBER := 2147483590;

    -- end of CAR elements

   -- Bug 4345779. Audits project.
   -- Added constants for new audit elements.
   -- srhariha. Wed Jun  1 12:13:02 PDT 2005.

   internal_auditee_email           CONSTANT NUMBER := 2147483525;
   internal_auditor_email           CONSTANT NUMBER := 2147483526;
   finding_date                     CONSTANT NUMBER := 2147483527;
   finding_type                     CONSTANT NUMBER := 2147483528;
   audit_finding_num                CONSTANT NUMBER := 2147483529;
   audit_question                   CONSTANT NUMBER := 2147483530;
   question_code                    CONSTANT NUMBER := 2147483531;
   question_category                CONSTANT NUMBER := 2147483532;
   car_required                     CONSTANT NUMBER := 2147483533;
   procedure_compliant              CONSTANT NUMBER := 2147483534;
   procedure_adequate               CONSTANT NUMBER := 2147483535;
   procedure_exists                 CONSTANT NUMBER := 2147483536;
   audit_result                     CONSTANT NUMBER := 2147483537;
   audit_status                     CONSTANT NUMBER := 2147483538;
   audit_area                       CONSTANT NUMBER := 2147483539;
   external_auditee                 CONSTANT NUMBER := 2147483540;
   external_auditor                 CONSTANT NUMBER := 2147483541;
   registrar                        CONSTANT NUMBER := 2147483542;
   internal_auditee                 CONSTANT NUMBER := 2147483543;
   internal_auditor                 CONSTANT NUMBER := 2147483544;
   lead_internal_auditor            CONSTANT NUMBER := 2147483545;
   audit_objective                  CONSTANT NUMBER := 2147483546;
   audit_type                       CONSTANT NUMBER := 2147483547;
   audit_name                       CONSTANT NUMBER := 2147483548;
   audit_num                        CONSTANT NUMBER := 2147483549;
   standard_violated                CONSTANT NUMBER := 2147483606;
   section_violated                 CONSTANT NUMBER := 2147483591;
   -- End 4345779.




    --
    -- The following are Quality datatypes
    --

    character_datatype              CONSTANT NUMBER := 1;
    number_datatype                 CONSTANT NUMBER := 2;
    date_datatype                   CONSTANT NUMBER := 3;

    -- Bug 2427337. Introduced 2 new datatype constants.
    -- rponnusa Tue Jun 25 06:15:48 PDT 2002
    comment_datatype                CONSTANT NUMBER := 4;
    sequence_datatype               CONSTANT NUMBER := 5;
    datetime_datatype               CONSTANT NUMBER := 6;

    --
    -- The following are Transaction Numbers that indicate an
    -- external product integration.
    --

    wip_move_txn                    CONSTANT NUMBER := 1;
    wip_completion_txn              CONSTANT NUMBER := 4;
    po_inspection_txn               CONSTANT NUMBER := 21;
    po_receiving_txn                CONSTANT NUMBER := 6;
    flow_work_order_less_txn        CONSTANT NUMBER := 22;
    cs_service_request_txn          CONSTANT NUMBER := 20;
    ss_outside_processing_txn       CONSTANT NUMBER := 100;
    ss_shipments_txn                CONSTANT NUMBER := 110;
    eam_work_order_txn              CONSTANT NUMBER := 31;
    eam_asset_txn                   CONSTANT NUMBER := 32;
    eam_operation_txn               CONSTANT NUMBER := 33;

    -- R12 OPM Deviations. Bug 4345503 Start
    process_nc_txn                  CONSTANT NUMBER := 34;
    -- R12 OPM Deviations. Bug 4345503 End

    /* R12 DR Integration. Bug 4345489 Start */
    depot_repair_txn                CONSTANT NUMBER := 2005;
    /* R12 DR Integration. Bug 4345489 End */

    --dgupta: Start R12 EAM Integration. Bug 4345492
    eam_checkin_txn                 CONSTANT NUMBER := 2006;
    eam_checkout_txn                CONSTANT NUMBER := 2007;
    --dgupta: End R12 EAM Integration. Bug 4345492

/* R12 OAF Txn Integration . Bug 4343758 */
    flow_line_op_txn                CONSTANT NUMBER := 24;
    osfm_move_txn                   CONSTANT NUMBER := 23;
/* R12 OAF Txn Integration . Bug 4343758 */


    -- Bug 4519558. OA Framework Integration project. UT bug fix.
    -- Added the following constants.
    -- srhariha. Tue Aug  2 01:37:53 PDT 2005.

    -- Bug 4519558.OA Framework Integration project. UT bug fix.
    -- Incorporating Bryan's code review comments. Replace prefix
    -- 'mob' with 'msca'.
    -- Mobile transaction number range : [1001 - 1999]
    -- srhariha. Mon Aug 22 02:50:35 PDT 2005.


    msca_move_txn                CONSTANT NUMBER := 1001;
    msca_scrap_reject_txn        CONSTANT NUMBER := 1002;
    msca_return_txn              CONSTANT NUMBER := 1003;
    msca_completion_txn          CONSTANT NUMBER := 1004;
    msca_wo_less_txn             CONSTANT NUMBER := 1005;
    msca_flow_txn                CONSTANT NUMBER := 1006;
    msca_material_txn            CONSTANT NUMBER := 1007;
    msca_move_and_complete_txn   CONSTANT NUMBER := 1008;
    msca_return_and_move_txn     CONSTANT NUMBER := 1009;
    msca_ser_move_txn            CONSTANT NUMBER := 1011;
    msca_ser_scrap_rej_txn       CONSTANT NUMBER := 1012;
    msca_ser_return_txn          CONSTANT NUMBER := 1013;
    msca_ser_completion_txn      CONSTANT NUMBER := 1014;
    msca_ser_material_txn        CONSTANT NUMBER := 1017;
    msca_ser_move_and_comp_txn   CONSTANT NUMBER := 1018;
    msca_ser_return_and_move_txn CONSTANT NUMBER := 1019;
    wma_lpn_inspection_txn       CONSTANT NUMBER := 1021;
    msca_recv_inspection_txn     CONSTANT NUMBER := 1022;
    wms_lpn_based_txn            CONSTANT NUMBER := 1041;

    mob_txn_lookup_prefix    CONSTANT VARCHAR2(15) := 'QA_TXN_TYPE_';
    -- End 4519558.

    --
    -- The following are Quality Action numbers.
    --

    display_message_action          CONSTANT NUMBER := 1;
    reject_input_action             CONSTANT NUMBER := 2;
    send_email_action               CONSTANT NUMBER := 10;
    exec_sql_action                 CONSTANT NUMBER := 11;
    exec_script_action              CONSTANT NUMBER := 12;
    launch_request_action           CONSTANT NUMBER := 13;
    post_action_log_action          CONSTANT NUMBER := 15;
    place_job_on_hold_action        CONSTANT NUMBER := 16;
    assign_shop_floor_action        CONSTANT NUMBER := 17;
    assign_lot_status_action        CONSTANT NUMBER := 18;
    assign_serial_status_action     CONSTANT NUMBER := 19;
    assign_item_status_action       CONSTANT NUMBER := 20;
    place_supplier_on_hold_action   CONSTANT NUMBER := 21;
    place_document_on_hold_action   CONSTANT NUMBER := 22;
    hold_all_schedules_action       CONSTANT NUMBER := 23;
    assign_value_action             CONSTANT NUMBER := 24;
    accept_shipment_action          CONSTANT NUMBER := 25;
    reject_shipment_action          CONSTANT NUMBER := 26;
    assign_asl_status_action        CONSTANT NUMBER := 27;
    launch_workflow_action          CONSTANT NUMBER := 28;

    -- Bug 4305107. Introduced send notification to element
    -- shkalyan Apr-21-2005
    send_notification_to            CONSTANT NUMBER := 2147483577;

    -- R12 ERES Support in Service Family. Bug 4345768 Start
    esignature_status               CONSTANT NUMBER := 2147483572;
    -- R12 ERES Support in Service Family. Bug 4345768 End

    -- R12 OPM Deviations. Bug 4345503 Start
    process_batch_num               CONSTANT NUMBER := 2147483556;
    process_batchstep_num           CONSTANT NUMBER := 2147483555;
    process_operation               CONSTANT NUMBER := 2147483554;
    process_activity                CONSTANT NUMBER := 2147483553;
    process_resource                CONSTANT NUMBER := 2147483552;
    process_parameter               CONSTANT NUMBER := 2147483551;
    -- R12 OPM Deviations. Bug 4345503 End

    /* R12 DR Integration. Bug 4345489 Start */
    repair_order_number        CONSTANT NUMBER := 2147483558;
    jtf_task_number            CONSTANT NUMBER := 2147483557;
    /* R12 DR Integration. Bug 4345489 End */
    --
    -- Some max values
    --

    -- Max. # of coll. elements, useful as hash function.  Need this
    -- no. to avoid hash collision.
    max_elements   CONSTANT NUMBER := 100000;

    --
    -- Release management requires a procedure.  We will
    -- supply an empty dummy procedure here.
    --

    procedure dummy1;

    --
    -- Bug 4635316
    -- Introduced constants for Global parameters Org_Id and User_Id
    -- which would be used in the package "qa_validation_api", file qltvalb.plb,
    -- to be replaced with the bind variables,in the string containing the
    -- sql text, used to assign a value to an element, in an action.
    -- Also introduced are the constants for the respetive Bind variables
    -- ntungare Thu Oct  6 21:52:39 PDT 2005
    --
    global_param_org_id             CONSTANT VARCHAR2(20) := ':PARAMETER.ORG_ID';
    global_param_user_id            CONSTANT VARCHAR2(20) := ':PARAMETER.USER_ID';
    bindvar_param_org_id            CONSTANT VARCHAR2(20) := ':PARAMETER_ORG_ID';
    bindvar_param_user_id           CONSTANT VARCHAR2(20) := ':PARAMETER_USER_ID';

    --
    -- Tracking Bug 4697145
    -- MOAC Upgrade feature.  One seeded template plan is
    -- dedicated to signal a JRad regeneration in the future.
    -- See Bug text for info.
    -- bso Sun Nov  6 16:52:53 PST 2005
    --
    jrad_upgrade_plan CONSTANT NUMBER := 1;


    --
    -- Tracking Bug 4939897
    -- R12 Forms Upgrade - Obsolete Graphics.
    -- bso Tue Feb  7 15:38:53 PST 2006
    --
    output_type_pareto     CONSTANT NUMBER := 1;
    output_type_trend      CONSTANT NUMBER := 2;
    output_type_report     CONSTANT NUMBER := 3;
    output_type_stats      CONSTANT NUMBER := 4;
    output_type_control    CONSTANT NUMBER := 5;
    output_type_histogram  CONSTANT NUMBER := 6;

    control_chart_XBarR    CONSTANT NUMBER := 1;
    control_chart_XmR      CONSTANT NUMBER := 2;
    control_chart_XBarS    CONSTANT NUMBER := 3;
    control_chart_mXmR     CONSTANT NUMBER := 4;

    chart_function_sum     CONSTANT NUMBER := 1;
    chart_function_count   CONSTANT NUMBER := 2;
    chart_function_average CONSTANT NUMBER := 3;
    chart_function_min     CONSTANT NUMBER := 4;
    chart_function_max     CONSTANT NUMBER := 5;

   --
   -- R12 performance fix. Added constant for few date chars.
   -- srhariha. Thu Feb 16 22:38:26 PST 2006
   --

   expected_resolution_date CONSTANT NUMBER := 128;
   actual_resolution_date   CONSTANT NUMBER := 129;
   approval_date            CONSTANT NUMBER := 2147483598;
   follow_up_date           CONSTANT NUMBER := 2147483600;


END qa_ss_const;


/
