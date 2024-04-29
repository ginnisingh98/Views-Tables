--------------------------------------------------------
--  DDL for Package PO_ASL_API_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_ASL_API_PUB" AUTHID CURRENT_USER AS
/* $Header: PO_ASL_API_PUB.pls 120.2.12010000.3 2014/01/08 11:13:43 vpeddi noship $*/
/*#
 * This package contains procedures that enable you to create ASLs in bulk.
 *
 * @rep:scope public
 * @rep:product PO
 * @rep:displayname ASL API
 */


-- ASL PROCESS_ACTION Constants
g_ACTION_CREATE CONSTANT VARCHAR2(10) := 'CREATE';
g_ACTION_UPDATE CONSTANT VARCHAR2(10) := 'UPDATE';
g_ACTION_SYNC   CONSTANT VARCHAR2(10) := 'SYNC';

-- CHILD PROCESS_ACTION Constants
g_ACTION_ADD    CONSTANT VARCHAR2(10) := 'ADD';
g_ACTION_DELETE CONSTANT VARCHAR2(10) := 'DELETE';

/*#
 * This API will take in all data as plsql table parameters. <br><br>
 *
 * The plsql tables will have fields for the ids as well as display values.
 * Id values if provided will be looked at only if the display value
 * is not given. The plsql tables data is to be linked among themselves
 * using user keys. The plsql tables also contain PROCESS_ACTION. The possible
 * values are CREATE/UPDATE/SYNC. In case of SYNC, this API will determine.
 * whether to do insert or update. This API generates a unique session key,
 * which is used to query the errors reported by this API. <br>  <br>
 *
 * Records will be rejected if  <br>
 * 1. Ids can't be derived from display values. <br>
 * 2. Validations fail  <br><br>
 *
 * After performing all the validations, it will insert/update/delete on the
 * target tables for non-rejected records. Also the errors will be inserted
 * into PO_ASL_API_ERRORS table.
 *
 * @param p_asl_rec
 * This record stores the relationship between an item or commodity; a supplier,
 * distributor, or manufacturer; ship-to organizations; and approval/certification status.
 * Each of the below attribute is table of values.<ul>
 *  <li>user_key -                User key</li>
 *  <li>process_action -          The possible values are CREATE/UPDATE/SYNC</li>
 *  <li>process_status -          Indicates the processing status</li>
 *  <li>global_flag -             Indicates of Whether ASL is global</li>
 *  <li>owning_organization_dsp - Organization that created the record initially</li>
 *  <li>owning_organization_id -  Internal Id of Owning Organization</li>
 *  <li>vendor_business_type -    Business type of Distributor, Direct, or Manufacturer</li>
 *  <li>asl_status_dsp -          Approval/certification status</li>
 *  <li>asl_status_id -           Internal Id of ASL Status</li>
 *  <li>manufacturer_dsp -        Manufacturer of the ASL</li>
 *  <li>manufacturer_id -         Internal Id of Manufacturer</li>
 *  <li>vendor_dsp -              Supplier of the ASL</li>
 *  <li>vendor_id -               Internal Id of Supplier</li>
 *  <li>item_dsp -                Item of the ASL</li>
 *  <li>item_id -                 Internal Id of Item</li>
 *  <li>category_dsp -            Category of the ASL</li>
 *  <li>category_id -             Internal Id of Category</li>
 *  <li>vendor_site_dsp -         Supplier Site of the ASL</li>
 *  <li>vendor_site_id -          Internal Id of Supplier Site</li>
 *  <li>primary_vendor_item -     Supplier, Manufacturer, or Distributor item number</li>
 *  <li>manufacturer_asl_dsp -    Manufacturer associated with distributor</li>
 *  <li>manufacturer_asl_id -     Internal Id of Manufacturer ASL</li>
 *  <li>review_by_date -          Review by date</li>
 *  <li>comments -                Comments</li>
 *  <li>attribute_category -      Standard DFF Column</li>
 *  <li>attribute1..15 -          Standard DFF Columns</li>
 *  <li>request_id -              Standard WHO column</li>
 *  <li>program_application_id -  Standard WHO column</li>
 *  <li>program_id -              Standard WHO column</li>
 *  <li>program_update_date -     Standard WHO column</li>
 *  <li>disable_flag -            Indicator of whether the ASL entry has been disabled</li></ul>
 * @rep:paraminfo {@rep:required}
 *
 * @param p_asl_attr_rec
 * This record stores all information for the supplier/item/organization
 * relationship defined in PO_APPROVED_SUPPLIER_LIST_REC. This information
 * is maintained separately to allow each organization to define its own
 * attributes.<ul>
 * <li>user_key - User key
 * <li>process_action - The possible values are CREATE/UPDATE/SYNC
 * <li>using_organization_dsp - Ship-to organization using record
 * <li>using_organization_id - Id of Using Organization
 * <li>release_generation_method_dsp - Automatic release method
 * <li>release_generation_method - Id of Release Generation Method
 * <li>purchasing_unit_of_measure_dsp - Supplier unit of measure
 * <li>enable_plan_schedule_flag_dsp - Enable planning schedules
 * <li>enable_ship_schedule_flag_dsp - Enable shipping schedules
 * <li>plan_schedule_type_dsp - Default planning schedule type
 * <li>plan_schedule_type - Id of Plan Schedule Type
 * <li>ship_schedule_type_dsp - Default shipping schedule type
 * <li>ship_schedule_type - Id of Ship Schedule Type
 * <li>plan_bucket_pattern_dsp - Default planning schedule bucket pattern
 * <li>plan_bucket_pattern_id - Id of Plan Bucket Pattern
 * <li>ship_bucket_pattern_dsp - Default shipping schedule bucket pattern
 * <li>ship_bucket_pattern_id - Id of Ship Bucket Pattern
 * <li>enable_autoschedule_flag_dsp - Autoschedule enabled
 * <li>scheduler_dsp - Scheduler
 * <li>scheduler_id - Id of Scheduler
 * <li>enable_authorizations_flag_dsp - Authorizations enabled
 * <li>vendor_dsp - Supplier
 * <li>vendor_id - Id of Supplier
 * <li>vendor_site_dsp - Supplier Site
 * <li>vendor_site_id - Id of Supplier Site
 * <li>item_dsp - Item
 * <li>item_id - Id of Item
 * <li>category_dsp - Category
 * <li>category_id - Id of Category
 * <li>attribute_category - DFF Column
 * <li>attribute1..15 - DFF Columns
 * <li>price_update_tolerance_dsp - Max percentage increase allowed to price/sales catalog update sent by supplier
 * <li>processing_lead_time_dsp - Processing lead time in days
 * <li>min_order_qty_dsp - Min qty that needs to be ordered
 * <li>fixed_lot_multiple_dsp - Min lot multiple that can be ordered on top of Min-order qty
 * <li>delivery_calendar_dsp - Name of the delivery calendar
 * <li>country_of_origin_code_dsp - Code for the item's country of manufacture
 * <li>enable_vmi_flag_dsp - VMI enabled indicator
 * <li>vmi_min_qty_dsp - Min qty for VMI replenishment
 * <li>vmi_max_qty_dsp - Max qty for VMI replenishment
 * <li>enable_vmi_auto_replenish_flag - Used by Collaborative Planning to allow/disallow automatic replenishment function
 * <li>vmi_replenishment_approval_dsp - Party with ability to release replenishment requests automatically
 * <li>vmi_replenishment_approval - Id of VMI Replenishment Approval
 * <li>consigned_from_supp_flag_dsp - Indicates that a consigned from supplierrelationship has been established in the ASL
 * <li>last_billing_date - Date of the last consumption advice created
 * <li>consigned_billing_cycle_dsp - Indicate the interval (in days) that must elapse between the creation of consumption advice
 * <li>consume_on_aging_flag_dsp - Indicates whether aging-based consumption is applicable
 * <li>aging_period_dsp - Number of days that can elapse before a consigned receipt becomes due for consumption
 * <li>replenishment_method_dsp - The type of inventory replenishment method used by Collaborative Planning to calculate replenishment points
 * <li>replenishment_method - Id of Replenishment Method
 * <li>vmi_min_days_dsp - Min days of inv supply that needs to be held in the inv org
 * <li>vmi_max_days_dsp - Max days of inv supply that needs to be held in the inv org
 * <li>fixed_order_qty_dsp - Order qty that Collaborative Planning will create a requisition for if replenishment method selected includes a fixed order qty
 * <li>forecast_horizon_dsp - Number of working days in the order forecast to calculate the average daily usage</ul>
 * @rep:paraminfo {@rep:required}
 *
 * @param p_asl_doc_rec
 * This record stores sourcing references to supply agreements, blanket agreements,
 * and catalog quotations associated with particular suppliers and items in PO_APPROVED_SUPPLIER_LIST_REC <ul>
 *  <li>user_key -                        User key</li>
 *  <li>process_action -                  The possible values are CREATE/UPDATE/SYNC</li>
 *  <li>using_organization_dsp -          Ship-to organization using record</li>
 *  <li>using_organization_id -           Internal Id of Using Organization</li>
 *  <li>sequence_num -                    Document ranking</li>
 *  <li>document_type_dsp -               Document type</li>
 *  <li>document_type_code -              Internal Id of Document Type</li>
 *  <li>document_header_dsp -             Document header unique identifier</li>
 *  <li>document_header_id -              Internal Id of Document Header >/li>
 *  <li>document_line_dsp -               Document line unique identifier</li>
 *  <li>document_line_num_id -            Internal Id of Document Line</li>
 *  <li>attribute_category -              Standard DFF Column</li>
 *  <li>attribute1..15 -                  Standard DFF Columns </li>
 *  <li>request_id -                      Standard WHO column</li>
 *  <li>program_application_id -          Standard WHO column</li>
 *  <li>program_id -                      Standard WHO column</li>
 *  <li>program_update_date -             Standard WHO column</li> </ul>
 * @rep:paraminfo {@rep:required}
 *
 * @param p_chv_auth_rec
 * This record stores all references to authorizations within Supplier Scheduling  <ul>
 *  <li>user_key -                        User key</li>
 *  <li>process_action -                  The possible values are CREATE/UPDATE/SYNC</li>
 *  <li>using_organization_dsp -          Ship-to organization using record</li>
 *  <li>using_organization_id -           Internal Id of Using Organization</li>
 *  <li>authorization_code_dsp -          Authorization code</li>
 *  <li>authorization_code -              Internal Id of Authorization Code</li>
 *  <li>authorization_sequence_dsp -      Authorization sequence</li>
 *  <li>timefence_days_dsp -              Time fence associated with each authorization</li>
 *  <li>attribute_category -              Standard DFF Column</li>
 *  <li>attribute1..15 -                  Standard DFF Columns </li>
 *  <li>request_id -                      Standard WHO column</li>
 *  <li>program_application_id -          Standard WHO column</li>
 *  <li>program_id -                      Standard WHO column</li>
 *  <li>program_update_date -             Standard WHO column</li> </ul>
 * @rep:paraminfo {@rep:required}
 *
 * @param p_capacity_rec
 * This record contains information about a supplier's daily capacity, for a given
 * time period. There can be different capacities for different time periods <ul>
 *  <li>user_key -                        User key</li>
 *  <li>process_action -                  The possible values are CREATE/UPDATE/SYNC</li>
 *  <li>using_organization_dsp -          Ship-to organization using record</li>
 *  <li>using_organization_id -           Internal Id of Using Organization</li>
 *  <li>from_date_dsp -                   Date the supplier capacity becomes effective</li>
 *  <li>to_date_dsp -                     End date for the supplier capacity information</li>
 *  <li>capacity_per_day_dsp -            Daily supplier capacity</li>
 *  <li>attribute_category -              Standard DFF Column</li>
 *  <li>attribute1..15 -                  Standard DFF Columns </li>
 *  <li>request_id -                      Standard WHO column</li>
 *  <li>program_application_id -          Standard WHO column</li>
 *  <li>program_id -                      Standard WHO column</li>
 *  <li>program_update_date -             Standard WHO column</li> </ul>
 * @rep:paraminfo {@rep:required}
 *
 * @param p_tolerance_rec
 * This record indicates the supplier's ability to exceed the capacity <ul>
 *  <li>user_key -                        User key</li>
 *  <li>process_action -                  The possible values are CREATE/UPDATE/SYNC</li>
 *  <li>using_organization_dsp -          Ship-to organization using record</li>
 *  <li>using_organization_id -           Internal Id of Using Organization</li>
 *  <li>number_of_days_dsp -              Advance notice in number of days that the supplier needs to meet the exceeded capacity</li>
 *  <li>tolerance_dsp -                   Maximum percentage increase in capacity given the number of days of advance notice</li>
 *  <li>attribute1..15 -                  Standard DFF Columns </li>
 *  <li>request_id -                      Standard WHO column</li>
 *  <li>program_application_id -          Standard WHO column</li>
 *  <li>program_id -                      Standard WHO column</li>
 *  <li>program_update_date -             Standard WHO column</li> </ul>
 * @rep:paraminfo {@rep:required}
 *
 * @param p_commit           API will commit the transaction if the value is 'Y'.
 *  If there are any exceptions found, transaction will NOT be committed, even
 *  this parameter value is 'Y'.
 * @rep:paraminfo {@rep:required}
 *
 * @param x_session_key      Unique session key generated by this API.
 * @param x_return_status    Return status of this API
 * @param x_return_msg       Holds the message in case of any exception
 * @param x_errors           Holds the error messages if any of the records fail.
 *
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname ASL API
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PO_APPROVED_SUPPLIER_LIST
 */
PROCEDURE create_update_asl(
  p_asl_rec         IN OUT NOCOPY PO_APPROVED_SUPPLIER_LIST_REC
, p_asl_attr_rec    IN            PO_ASL_ATTRIBUTES_REC
, p_asl_doc_rec     IN            PO_ASL_DOCUMENTS_REC
, p_chv_auth_rec    IN            CHV_AUTHORIZATIONS_REC
, p_capacity_rec    IN            PO_SUPPLIER_ITEM_CAPACITY_REC
, p_tolerance_rec   IN            PO_SUPPLIER_ITEM_TOLERANCE_REC
, p_commit          IN            VARCHAR2
, x_session_key     OUT NOCOPY    NUMBER
, x_return_status   OUT NOCOPY    VARCHAR2
, x_return_msg      OUT NOCOPY    VARCHAR2
, x_errors          OUT NOCOPY PO_ASL_API_ERROR_REC
);


--------------------------------------------------------------------------------
  --Start of Comments

  --Name: process

  --Function:
  --  This will first derive the id fields based on the display values provided.
  --  Next it will try to default any null fields which are defaultable.
  --  Call PO_ASL_API_PVT.reject_asl_record for which the id values remain null
  --  and dsp values are not null after processing

  --Parameters:

  --OUT:
  --  x_return_status   VARCHAR2(1)
  --  x_return_msg      VARCHAR2(2000)

  --End of Comments
---------------------------------------------------------------------------------

PROCEDURE process(
  x_return_status   OUT NOCOPY VARCHAR2
, x_return_msg      OUT NOCOPY VARCHAR2
);


--------------------------------------------------------------------------------
  --START of comments

  --NAME: get_doc_header

  --FUNCTION:
  --  Retrieves the document header id based on item and category

  --PARAMETERS:
  --IN:
  --  p_user_key_tbl     po_tbl_number
  --  p_entity_name      po_tbl_varchar30
  --  p_rejection_reason po_tbl_varchar2000

  --OUT:
  --  x_return_status    VARCHAR2
  --  x_return_msg       VARCHAR2

  --END of comments
--------------------------------------------------------------------------------

FUNCTION get_doc_header(
  p_user_key         IN  NUMBER
, p_doc_type         IN  VARCHAR2
, p_using_org_id     IN  NUMBER
, p_segment          IN  VARCHAR2
)
RETURN NUMBER;

--------------------------------------------------------------------------------
  --START of comments

  --NAME: get_doc_line_id

  --FUNCTION:
  --  Retrieves the document line id based on headerId, item and category

  --PARAMETERS:
  --IN:
  --  p_user_key_tbl     po_tbl_number
  --  p_entity_name      po_tbl_varchar30
  --  p_rejection_reason po_tbl_varchar2000

  --OUT:
  --  x_return_status    VARCHAR2
  --  x_return_msg       VARCHAR2

  --END of comments
--------------------------------------------------------------------------------

FUNCTION get_doc_line_id(
  p_user_key         IN  NUMBER
, p_header_id        IN  VARCHAR2
, p_using_org_id     IN  NUMBER
, p_line_num         IN  NUMBER
)
RETURN NUMBER;

END PO_ASL_API_PUB;

/
