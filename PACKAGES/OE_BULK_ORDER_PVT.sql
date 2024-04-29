--------------------------------------------------------
--  DDL for Package OE_BULK_ORDER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_BULK_ORDER_PVT" AUTHID CURRENT_USER AS
/* $Header: OEBVORDS.pls 120.4.12010000.2 2008/11/18 13:02:34 smusanna ship $ */


-----------------------------------------------------------------
-- DATA TYPES (RECORD/TABLE TYPES)
-----------------------------------------------------------------

-------------------------------------------------------------------
-- **** The Data Type Definitions are moved to OE_WSH_BULK_GRP ****
-------------------------------------------------------------------

-- Define Record Data Types

TYPE HEADER_REC_TYPE IS RECORD
(
    accounting_rule_id            OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()
,   accounting_rule_duration      OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()
,   agreement_id                  OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()
,   attribute1                    OE_WSH_BULK_GRP.T_V240 := OE_WSH_BULK_GRP.T_V240()
,   attribute10                   OE_WSH_BULK_GRP.T_V240 := OE_WSH_BULK_GRP.T_V240()
,   attribute11                   OE_WSH_BULK_GRP.T_V240 := OE_WSH_BULK_GRP.T_V240()
,   attribute12                   OE_WSH_BULK_GRP.T_V240 := OE_WSH_BULK_GRP.T_V240()
,   attribute13                   OE_WSH_BULK_GRP.T_V240 := OE_WSH_BULK_GRP.T_V240()
,   attribute14                   OE_WSH_BULK_GRP.T_V240 := OE_WSH_BULK_GRP.T_V240()
,   attribute15                   OE_WSH_BULK_GRP.T_V240 := OE_WSH_BULK_GRP.T_V240()
,   attribute16                   OE_WSH_BULK_GRP.T_V240 := OE_WSH_BULK_GRP.T_V240()   --For bug 2184255
,   attribute17                   OE_WSH_BULK_GRP.T_V240 := OE_WSH_BULK_GRP.T_V240()
,   attribute18                   OE_WSH_BULK_GRP.T_V240 := OE_WSH_BULK_GRP.T_V240()
,   attribute19                   OE_WSH_BULK_GRP.T_V240 := OE_WSH_BULK_GRP.T_V240()
,   attribute2                    OE_WSH_BULK_GRP.T_V240 := OE_WSH_BULK_GRP.T_V240()
,   attribute20                   OE_WSH_BULK_GRP.T_V240 := OE_WSH_BULK_GRP.T_V240()
,   attribute3                    OE_WSH_BULK_GRP.T_V240 := OE_WSH_BULK_GRP.T_V240()
,   attribute4                    OE_WSH_BULK_GRP.T_V240 := OE_WSH_BULK_GRP.T_V240()
,   attribute5                    OE_WSH_BULK_GRP.T_V240 := OE_WSH_BULK_GRP.T_V240()
,   attribute6                    OE_WSH_BULK_GRP.T_V240 := OE_WSH_BULK_GRP.T_V240()
,   attribute7                    OE_WSH_BULK_GRP.T_V240 := OE_WSH_BULK_GRP.T_V240()
,   attribute8                    OE_WSH_BULK_GRP.T_V240 := OE_WSH_BULK_GRP.T_V240()
,   attribute9                    OE_WSH_BULK_GRP.T_V240 := OE_WSH_BULK_GRP.T_V240()
,   booked_flag                   OE_WSH_BULK_GRP.T_V1 := OE_WSH_BULK_GRP.T_V1()
--,   cancelled_flag              OE_WSH_BULK_GRP.T_V1 := OE_WSH_BULK_GRP.T_V1()         -- Do we need this?
,   context                       OE_WSH_BULK_GRP.T_V30 := OE_WSH_BULK_GRP.T_V30()
,   conversion_rate               OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()
,   conversion_rate_date          OE_WSH_BULK_GRP.T_DATE := OE_WSH_BULK_GRP.T_DATE()
,   conversion_type_code          OE_WSH_BULK_GRP.T_V30 := OE_WSH_BULK_GRP.T_V30()
,   customer_preference_set_code  OE_WSH_BULK_GRP.T_V30 := OE_WSH_BULK_GRP.T_V30()
--,   created_by                  OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()       -- Do we need this?
--,   creation_date               OE_WSH_BULK_GRP.T_DATE := OE_WSH_BULK_GRP.T_DATE()      -- Do we need this?
,   cust_po_number                OE_WSH_BULK_GRP.T_V50 := OE_WSH_BULK_GRP.T_V50()
,   deliver_to_contact_id         OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()
,   deliver_to_org_id             OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()
,   demand_class_code             OE_WSH_BULK_GRP.T_V30 := OE_WSH_BULK_GRP.T_V30()
,   earliest_schedule_limit       OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()
--,   expiration_date             OE_WSH_BULK_GRP.T_DATE := OE_WSH_BULK_GRP.T_DATE()
,   fob_point_code                OE_WSH_BULK_GRP.T_V30 := OE_WSH_BULK_GRP.T_V30()
,   freight_carrier_code          OE_WSH_BULK_GRP.T_V30 := OE_WSH_BULK_GRP.T_V30()
,   freight_terms_code            OE_WSH_BULK_GRP.T_V30 := OE_WSH_BULK_GRP.T_V30()
,   global_attribute1             OE_WSH_BULK_GRP.T_V240 := OE_WSH_BULK_GRP.T_V240()
,   global_attribute10            OE_WSH_BULK_GRP.T_V240 := OE_WSH_BULK_GRP.T_V240()
,   global_attribute11            OE_WSH_BULK_GRP.T_V240 := OE_WSH_BULK_GRP.T_V240()
,   global_attribute12            OE_WSH_BULK_GRP.T_V240 := OE_WSH_BULK_GRP.T_V240()
,   global_attribute13            OE_WSH_BULK_GRP.T_V240 := OE_WSH_BULK_GRP.T_V240()
,   global_attribute14            OE_WSH_BULK_GRP.T_V240 := OE_WSH_BULK_GRP.T_V240()
,   global_attribute15            OE_WSH_BULK_GRP.T_V240 := OE_WSH_BULK_GRP.T_V240()
,   global_attribute16            OE_WSH_BULK_GRP.T_V240 := OE_WSH_BULK_GRP.T_V240()
,   global_attribute17            OE_WSH_BULK_GRP.T_V240 := OE_WSH_BULK_GRP.T_V240()
,   global_attribute18            OE_WSH_BULK_GRP.T_V240 := OE_WSH_BULK_GRP.T_V240()
,   global_attribute19            OE_WSH_BULK_GRP.T_V240 := OE_WSH_BULK_GRP.T_V240()
,   global_attribute2             OE_WSH_BULK_GRP.T_V240 := OE_WSH_BULK_GRP.T_V240()
,   global_attribute20            OE_WSH_BULK_GRP.T_V240 := OE_WSH_BULK_GRP.T_V240()
,   global_attribute3             OE_WSH_BULK_GRP.T_V240 := OE_WSH_BULK_GRP.T_V240()
,   global_attribute4             OE_WSH_BULK_GRP.T_V240 := OE_WSH_BULK_GRP.T_V240()
,   global_attribute5             OE_WSH_BULK_GRP.T_V240 := OE_WSH_BULK_GRP.T_V240()
,   global_attribute6             OE_WSH_BULK_GRP.T_V240 := OE_WSH_BULK_GRP.T_V240()
,   global_attribute7             OE_WSH_BULK_GRP.T_V240 := OE_WSH_BULK_GRP.T_V240()
,   global_attribute8             OE_WSH_BULK_GRP.T_V240 := OE_WSH_BULK_GRP.T_V240()
,   global_attribute9             OE_WSH_BULK_GRP.T_V240 := OE_WSH_BULK_GRP.T_V240()
,   global_attribute_category     OE_WSH_BULK_GRP.T_V30 := OE_WSH_BULK_GRP.T_V30()
,   TP_CONTEXT                    OE_WSH_BULK_GRP.T_V30 := OE_WSH_BULK_GRP.T_V30()
,   TP_ATTRIBUTE1                 OE_WSH_BULK_GRP.T_V240 := OE_WSH_BULK_GRP.T_V240()
,   TP_ATTRIBUTE2                 OE_WSH_BULK_GRP.T_V240 := OE_WSH_BULK_GRP.T_V240()
,   TP_ATTRIBUTE3                 OE_WSH_BULK_GRP.T_V240 := OE_WSH_BULK_GRP.T_V240()
,   TP_ATTRIBUTE4                 OE_WSH_BULK_GRP.T_V240 := OE_WSH_BULK_GRP.T_V240()
,   TP_ATTRIBUTE5                 OE_WSH_BULK_GRP.T_V240 := OE_WSH_BULK_GRP.T_V240()
,   TP_ATTRIBUTE6                 OE_WSH_BULK_GRP.T_V240 := OE_WSH_BULK_GRP.T_V240()
,   TP_ATTRIBUTE7                 OE_WSH_BULK_GRP.T_V240 := OE_WSH_BULK_GRP.T_V240()
,   TP_ATTRIBUTE8                 OE_WSH_BULK_GRP.T_V240 := OE_WSH_BULK_GRP.T_V240()
,   TP_ATTRIBUTE9                 OE_WSH_BULK_GRP.T_V240 := OE_WSH_BULK_GRP.T_V240()
,   TP_ATTRIBUTE10                OE_WSH_BULK_GRP.T_V240 := OE_WSH_BULK_GRP.T_V240()
,   TP_ATTRIBUTE11                OE_WSH_BULK_GRP.T_V240 := OE_WSH_BULK_GRP.T_V240()
,   TP_ATTRIBUTE12                OE_WSH_BULK_GRP.T_V240 := OE_WSH_BULK_GRP.T_V240()
,   TP_ATTRIBUTE13                OE_WSH_BULK_GRP.T_V240 := OE_WSH_BULK_GRP.T_V240()
,   TP_ATTRIBUTE14                OE_WSH_BULK_GRP.T_V240 := OE_WSH_BULK_GRP.T_V240()
,   TP_ATTRIBUTE15                OE_WSH_BULK_GRP.T_V240 := OE_WSH_BULK_GRP.T_V240()
,   header_id                     OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()
,   invoice_to_contact_id         OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()
,   invoice_to_org_id             OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()
,   invoicing_rule_id             OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()
--,   last_updated_by             OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()
--,   last_update_date            OE_WSH_BULK_GRP.T_DATE := OE_WSH_BULK_GRP.T_DATE()
--,   last_update_login           OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()
,   latest_schedule_limit         OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()
--,   open_flag                   OE_WSH_BULK_GRP.T_V1 := OE_WSH_BULK_GRP.T_V1()
,   order_category_code           OE_WSH_BULK_GRP.T_V30 := OE_WSH_BULK_GRP.T_V30()
,   ordered_date                  OE_WSH_BULK_GRP.T_DATE := OE_WSH_BULK_GRP.T_DATE()
,   order_date_type_code          OE_WSH_BULK_GRP.T_V30 := OE_WSH_BULK_GRP.T_V30()
,   order_number                  OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()
,   order_source_id               OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()
,   order_type_id                 OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()
,   org_id                      OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()
,   orig_sys_document_ref         OE_WSH_BULK_GRP.T_V50 := OE_WSH_BULK_GRP.T_V50()
,   partial_shipments_allowed     OE_WSH_BULK_GRP.T_V1 := OE_WSH_BULK_GRP.T_V1()
,   payment_term_id               OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()
,   price_list_id                 OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()
,   pricing_date                  OE_WSH_BULK_GRP.T_DATE := OE_WSH_BULK_GRP.T_DATE()
--,   program_application_id      OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()
--,   program_id                  OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()
--,   program_update_date         OE_WSH_BULK_GRP.T_DATE := OE_WSH_BULK_GRP.T_DATE()
,   request_date                  OE_WSH_BULK_GRP.T_DATE := OE_WSH_BULK_GRP.T_DATE()
,   request_id                    OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()
--,   return_reason_code          OE_WSH_BULK_GRP.T_V30 := OE_WSH_BULK_GRP.T_V30()
,   salesrep_id                   OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()
,   sales_channel_code            OE_WSH_BULK_GRP.T_V30 := OE_WSH_BULK_GRP.T_V30()
,   shipment_priority_code        OE_WSH_BULK_GRP.T_V30 := OE_WSH_BULK_GRP.T_V30()
,   shipping_method_code          OE_WSH_BULK_GRP.T_V30 := OE_WSH_BULK_GRP.T_V30()
,   ship_from_org_id              OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()
,   ship_tolerance_above          OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()
,   ship_tolerance_below          OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()
,   ship_to_contact_id            OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()
,   ship_to_org_id                OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()
,   sold_from_org_id              OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()
,   sold_to_contact_id            OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()
,   sold_to_org_id                OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()
--,   source_document_id          OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()
--,   source_document_type_id     OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()
,   tax_exempt_flag               OE_WSH_BULK_GRP.T_V30 := OE_WSH_BULK_GRP.T_V30()
,   tax_exempt_number             OE_WSH_BULK_GRP.T_V50 := OE_WSH_BULK_GRP.T_V50()
,   tax_exempt_reason_code        OE_WSH_BULK_GRP.T_V30 := OE_WSH_BULK_GRP.T_V30()
,   tax_point_code                OE_WSH_BULK_GRP.T_V30 := OE_WSH_BULK_GRP.T_V30()
,   transactional_curr_code       OE_WSH_BULK_GRP.T_V15 := OE_WSH_BULK_GRP.T_V15()
,   version_number                OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()
--,   return_status               OE_WSH_BULK_GRP.T_V1 := OE_WSH_BULK_GRP.T_V1()
--,   db_flag                     OE_WSH_BULK_GRP.T_V1 := OE_WSH_BULK_GRP.T_V1()
--,   operation                   OE_WSH_BULK_GRP.T_V30 := OE_WSH_BULK_GRP.T_V30()
,   first_ack_code                OE_WSH_BULK_GRP.T_V30 := OE_WSH_BULK_GRP.T_V30()
--,   first_ack_date              OE_WSH_BULK_GRP.T_DATE := OE_WSH_BULK_GRP.T_DATE()
--,   last_ack_code               OE_WSH_BULK_GRP.T_V30 := OE_WSH_BULK_GRP.T_V30()
--,   last_ack_date               OE_WSH_BULK_GRP.T_DATE := OE_WSH_BULK_GRP.T_DATE()
--,   change_reason               OE_WSH_BULK_GRP.T_V30 := OE_WSH_BULK_GRP.T_V30()
--,   change_comments             OE_WSH_BULK_GRP.T_V2000 := OE_WSH_BULK_GRP.T_V2000()
,   change_sequence               OE_WSH_BULK_GRP.T_V50 := OE_WSH_BULK_GRP.T_V50()
--,   change_request_code         OE_WSH_BULK_GRP.T_V30 := OE_WSH_BULK_GRP.T_V30()
--,   ready_flag                  OE_WSH_BULK_GRP.T_V1 := OE_WSH_BULK_GRP.T_V1()
--,   status_flag                 OE_WSH_BULK_GRP.T_V1 := OE_WSH_BULK_GRP.T_V1()
--,   force_apply_flag            OE_WSH_BULK_GRP.T_V1 := OE_WSH_BULK_GRP.T_V1()
--,   drop_ship_flag              OE_WSH_BULK_GRP.T_V1 := OE_WSH_BULK_GRP.T_V1()
--,   customer_payment_term_id    OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()
,   payment_type_code             OE_WSH_BULK_GRP.T_V30 := OE_WSH_BULK_GRP.T_V30()
,   payment_amount                OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()
,   check_number                  OE_WSH_BULK_GRP.T_V50 := OE_WSH_BULK_GRP.T_V50()
,   credit_card_code              OE_WSH_BULK_GRP.T_V80 := OE_WSH_BULK_GRP.T_V80()
,   credit_card_holder_name       OE_WSH_BULK_GRP.T_V80 := OE_WSH_BULK_GRP.T_V80()
,   credit_card_number            OE_WSH_BULK_GRP.T_V80 := OE_WSH_BULK_GRP.T_V80()
,   credit_card_expiration_date   OE_WSH_BULK_GRP.T_DATE := OE_WSH_BULK_GRP.T_DATE()
,   credit_card_approval_code     OE_WSH_BULK_GRP.T_V80 := OE_WSH_BULK_GRP.T_V80()
,   credit_card_approval_date     OE_WSH_BULK_GRP.T_DATE := OE_WSH_BULK_GRP.T_DATE()
,   shipping_instructions         OE_WSH_BULK_GRP.T_V2000 := OE_WSH_BULK_GRP.T_V2000()
,   packing_instructions          OE_WSH_BULK_GRP.T_V2000 := OE_WSH_BULK_GRP.T_V2000()
--,   flow_status_code            OE_WSH_BULK_GRP.T_V30 := OE_WSH_BULK_GRP.T_V30()
--,   booked_date                 OE_WSH_BULK_GRP.T_DATE := OE_WSH_BULK_GRP.T_DATE()
--,   marketing_source_code_id    OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()
--,   upgraded_flag               OE_WSH_BULK_GRP.T_V1 := OE_WSH_BULK_GRP.T_V1()
,   lock_control                  OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()
--,   ship_to_edi_location_code   OE_WSH_BULK_GRP.T_V40 := OE_WSH_BULK_GRP.T_V40()
--,   sold_to_edi_location_code   OE_WSH_BULK_GRP.T_V40 := OE_WSH_BULK_GRP.T_V40()
--,   bill_to_edi_location_code   OE_WSH_BULK_GRP.T_V40 := OE_WSH_BULK_GRP.T_V40()
,   order_type_name               OE_WSH_BULK_GRP.T_V30 := OE_WSH_BULK_GRP.T_V30()
,   wf_process_name               OE_WSH_BULK_GRP.T_V30 := OE_WSH_BULK_GRP.T_V30()
,   xml_message_id                OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()
--PIB
,   calculate_price_flag          OE_WSH_BULK_GRP.T_V1 := OE_WSH_BULK_GRP.T_V1()
,   header_index                  OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()
,   event_code                    OE_WSH_BULK_GRP.T_V30 := OE_WSH_BULK_GRP.T_V30()
--PIB
--abghosh
,   sold_to_site_use_id                OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()
-- added for end customer (Bug 5054618)
, End_customer_contact_id OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()
, End_customer_id OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()
, End_customer_site_use_id OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()
, IB_owner OE_WSH_BULK_GRP.T_V30 := OE_WSH_BULK_GRP.T_V30()
, IB_current_location OE_WSH_BULK_GRP.T_V30 := OE_WSH_BULK_GRP.T_V30()
, IB_Installed_at_Location OE_WSH_BULK_GRP.T_V30 := OE_WSH_BULK_GRP.T_V30()
, start_line_index         OE_WSH_BULK_GRP.T_B_INT := OE_WSH_BULK_GRP.T_B_INT()
, end_line_index           OE_WSH_BULK_GRP.T_B_INT := OE_WSH_BULK_GRP.T_B_INT()
);


--  Line record type
---------------------------------------------------------------------
-- **** The Line Record Definitions are moved to OE_WSH_BULK_GRP ****
---------------------------------------------------------------------

TYPE Scredit_Rec_Type IS RECORD
(  header_id                      OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()
,  line_id                        OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()
,  salesrep_id                    OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()
,  sales_credit_type_id           OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()
);

-- Record to store pointers to invalid records

TYPE invalid_hdr_rec_type IS RECORD
(
    order_source_id              OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()
,   orig_sys_document_ref        OE_WSH_BULK_GRP.T_V50 := OE_WSH_BULK_GRP.T_V50()
,   header_id                    OE_WSH_BULK_GRP.T_NUM := OE_WSH_BULK_GRP.T_NUM()
,   ineligible_for_hvop          OE_WSH_BULK_GRP.T_V1 := OE_WSH_BULK_GRP.T_V1()
,   skip_batch                   OE_WSH_BULK_GRP.T_V1 := OE_WSH_BULK_GRP.T_V1()
);

-- Global Number Table of Records Type
TYPE Number_Tbl_Type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;


---------------------------------------------------------------------
-- GLOBAL RECORDS/TABLES
---------------------------------------------------------------------

--bug 3798477
G_CATCHWEIGHT                   BOOLEAN := FALSE;
--bug 3798477

-- Global Header Record

G_HEADER_REC Header_Rec_Type;

-- Global Line Record
G_LINE_REC OE_WSH_BULK_GRP.Line_Rec_Type;

-- Global Record to store pointers to invalid records
G_ERROR_REC invalid_hdr_rec_type;


--------------------------------------------------------------------
-- REQUEST LEVEL GLOBALS
--------------------------------------------------------------------

-- Global Request ID

G_REQUEST_ID NUMBER;
-- Globals required for message context
G_ORDER_SOURCE_ID NUMBER;
G_ORIG_SYS_DOCUMENT_REF VARCHAR2(50);
G_ORIG_SYS_LINE_REF     VARCHAR2(50);
G_ORIG_SYS_SHIPMENT_REF VARCHAR2(50);

-- Globals to identify whether the desc-flex are in use
G_OE_HEADER_ATTRIBUTES         VARCHAR2(1);
G_OE_HEADER_GLOBAL_ATTRIBUTE   VARCHAR2(1);
G_OE_LINE_ATTRIBUTES           VARCHAR2(1);
G_OE_LINE_INDUSTRY_ATTRIBUTE   VARCHAR2(1);
G_OE_HEADER_TP_ATTRIBUTES      VARCHAR2(1);
G_OE_LINE_TP_ATTRIBUTES        VARCHAR2(1);


-- Globals to store various profilles

G_AUTO_SCHEDULE                VARCHAR2(30) :=
                 FND_PROFILE.VALUE('ONT_AUTOSCHEDULE');
G_IIFM                         VARCHAR2(30) :=
                 FND_PROFILE.VALUE('ONT_INCLUDED_ITEM_FREEZE_METHOD');

-- Changing the following profile fetch to sys parameter fetch.
G_SCHEDULE_LINE_ON_HOLD   VARCHAR2(30); -- Initialized in OEBVIMNB.pls

G_IMPORT_SHIPMENTS             VARCHAR2(3) :=
                 nvl(FND_PROFILE.VALUE('ONT_IMP_MULTIPLE_SHIPMENTS'),'NO');
G_DBI_INSTALLED                VARCHAR2(1) :=
                 nvl(FND_PROFILE.VALUE('ONT_DBI_INSTALLED'),'N');
-- Changing the following profile fetch to sys parameter fetch.
G_RESERVATION_TIME_FENCE   VARCHAR2(30); -- Initialized in OEBVIMNB.pls

G_NOTIFICATION_APPROVER        VARCHAR2(4000) :=
                 FND_PROFILE.VALUE('OE_NOTIFICATION_APPROVER');
G_RESP_APPL_ID          VARCHAR2(30) :=
                fnd_profile.value('RESP_APPL_ID');
G_RESP_ID               VARCHAR2(30) :=
                fnd_profile.value('RESP_ID');
G_CONFIGURATOR_USED     VARCHAR2(10) :=
                fnd_profile.value('ONT_USE_CONFIGURATOR');
G_BYPASS_ATP            VARCHAR2(1) :=
                fnd_profile.value('ONT_BYPASS_ATP');


-- Globals to store system parameters
-- These globals are not reset.  The assumption is that the org_id WILL NOT
-- change in a session.

G_ITEM_ORG                     NUMBER; -- Initialized in OEBVIMNB.pls

G_SOB_ID                       NUMBER; -- Initialized in OEBVIMNB.pls

G_CUST_RELATIONS               VARCHAR2(1); -- Initialized in OEBVIMNB.pls

G_CONFIG_EFFECT_DATE           VARCHAR2(10) :=
-                  nvl(OE_Sys_Parameters.VALUE('ONT_CONFIG_EFFECTIVITY_DATE',204),'1');
--------------------------------------------------------------------
-- BATCH LEVEL GLOBALS
--------------------------------------------------------------------

G_ERROR_COUNT                  NUMBER := 0;
G_PRICING_NEEDED               VARCHAR2(1) := 'N';
G_ACK_NEEDED                   VARCHAR2(1) := 'N';
G_SCH_COUNT                    NUMBER;

--BCT
G_REALTIME_CC_REQUIRED         VARCHAR2(1):='Y';
G_CC_REQUIRED                  VARCHAR2(1):='Y';
--BCT

---------------------------------------------------------------------
-- PROCEDURES/FUNCTIONS
---------------------------------------------------------------------

---------------------------------------------------------------------
-- This function is called by desc flex validation routines to first
-- check if a flex is enabled or not.
-- Returns 'Y' if flex is enabled else returns 'N'.
---------------------------------------------------------------------

FUNCTION GET_FLEX_ENABLED_FLAG(p_flex_name VARCHAR2)
RETURN VARCHAR2;

---------------------------------------------------------------------
-- This is the MAIN procedure called from order import for processing
-- orders in this batch.
---------------------------------------------------------------------

PROCEDURE Process_Batch
( p_batch_id                 IN  NUMBER
, p_validate_only            IN  VARCHAR2 DEFAULT 'N'
, p_validate_desc_flex       IN  VARCHAR2 DEFAULT 'Y'
, p_defaulting_mode          IN  VARCHAR2 DEFAULT 'N'
, p_process_configurations   IN  VARCHAR2 DEFAULT 'N'
, p_validate_configurations  IN  VARCHAR2 DEFAULT 'Y'
, p_schedule_configurations  IN  VARCHAR2 DEFAULT 'N'
, p_init_msg_list            IN  VARCHAR2 DEFAULT FND_API.G_FALSE
, p_process_tax              IN  VARCHAR2 DEFAULT 'N'
, x_msg_count                OUT NOCOPY NUMBER
, x_msg_data                 OUT NOCOPY VARCHAR2
, x_return_status            OUT NOCOPY VARCHAR
);

PROCEDURE mark_header_error(p_header_index IN NUMBER,
               p_header_rec IN OUT NOCOPY OE_BULK_ORDER_PVT.HEADER_REC_TYPE);

END OE_BULK_ORDER_PVT;

/
