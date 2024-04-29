--------------------------------------------------------
--  DDL for Package Body OE_INF_POPULATE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_INF_POPULATE_PUB" AS
/* $Header: OEXPIFPB.pls 120.2 2006/02/17 04:25:53 mbhoumik noship $ */


--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'OE_INF_POPULATE_PUB';


--  Start of Comments
--  API name    Populate_Interface
--  Type        Public
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

PROCEDURE Populate_Interface
(   p_api_version_number            IN  NUMBER
,   x_return_status                 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
,   p_order_number_from             IN  NUMBER
,   p_order_source_id               IN  NUMBER
)
IS
order_number_v          number := p_order_number_from;
order_source_id_v       number := p_order_source_id;
old_header_id_v         number := 0;
l_sold_to_org_id        number;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXPIFPB: ENTERING POPULATE_INTERFACE API' ) ;
  END IF;

  -- Select the header_id from the oe_order_headers_all table
  -- for what ???
  BEGIN

    SELECT header_id, sold_to_org_id
      INTO old_header_id_v, l_sold_to_org_id
      FROM oe_order_headers_all
     WHERE order_number = order_number_v;

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'OEXPIFPB: HEADER ID => ' || TO_CHAR ( OLD_HEADER_ID_V ) ) ;
     END IF;

	EXCEPTION
	WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'OEXPIFPB: EXITING POPULATE_INTERFACE API' ) ;
         END IF;
  END;

  IF old_header_id_v is not null THEN

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'OEXPIFPB: BEFORE INSERT TO OE_HEADERS_IFACE_ALL' ) ;
     END IF;

     INSERT INTO oe_headers_iface_all (
      order_source_id
     ,orig_sys_document_ref
     ,change_sequence
     ,order_source
     ,org_id
     ,header_id
     ,order_number
     ,version_number
     ,ordered_date
     ,order_category
     ,order_type
     ,order_type_id
     ,request_date
     ,shipment_priority
     ,shipment_priority_code
     ,demand_class
     ,demand_class_code
     ,price_list
     ,price_list_id
     ,tax_exempt_flag
     ,tax_exempt_number
     ,tax_exempt_reason
     ,tax_exempt_reason_code
     ,conversion_rate
     ,conversion_rate_date
     ,partial_shipments_allowed
     --,remainder_orders_allowed
     ,ship_tolerance_above
     ,ship_tolerance_below
     ,order_date_type_code
     ,earliest_schedule_limit
     ,latest_schedule_limit
     --,invoice_tolerance_above
     --,invoice_tolerance_below
     --,related_po_number
     ,agreement
     ,agreement_id
     ,tax_point
     ,tax_point_code
     ,customer_po_number
     ,customer_payment_term
     ,customer_payment_term_id
     ,payment_type_code
     ,payment_amount
     ,check_number
     ,credit_card_code
     ,credit_card_holder_name
     ,credit_card_number
     ,credit_card_expiration_date
     ,credit_card_approval_code
     ,invoicing_rule
     ,invoicing_rule_id
     ,accounting_rule
     ,accounting_rule_id
     ,payment_term
     ,payment_term_id
     ,shipping_method
     ,shipping_method_code
     ,shipping_instructions
     ,packing_instructions
     ,freight_carrier_code
     ,freight_terms
     ,freight_terms_code
     ,fob_point
     ,fob_point_code
     --,sold_from_org
     --,sold_from_org_id
     ,sold_to_org
     ,sold_to_org_id
     ,ship_from_org
     ,ship_from_org_id
     ,ship_to_org
     ,ship_to_org_id
     ,invoice_to_org
     ,invoice_to_org_id
     ,deliver_to_org
     ,deliver_to_org_id
     ,deliver_to_customer
     ,deliver_to_customer_number
     ,sold_to_contact
     ,sold_to_contact_id
     ,ship_to_contact
     ,ship_to_contact_id
     ,invoice_to_contact
     ,invoice_to_contact_id
     ,deliver_to_contact
     ,deliver_to_contact_id
     ,creation_date
     ,created_by
     ,last_update_date
     ,last_updated_by
     ,last_update_login
     ,program_application_id
     ,program_id
     ,program_update_date
     ,request_id
     ,context
     ,attribute1
     ,attribute2
     ,attribute3
     ,attribute4
     ,attribute5
     ,attribute6
     ,attribute7
     ,attribute8
     ,attribute9
     ,attribute10
     ,attribute11
     ,attribute12
     ,attribute13
     ,attribute14
     ,attribute15
     ,global_attribute_category
     ,global_attribute1
     ,global_attribute2
     ,global_attribute3
     ,global_attribute4
     ,global_attribute5
     ,global_attribute6
     ,global_attribute7
     ,global_attribute8
     ,global_attribute9
     ,global_attribute10
     ,global_attribute11
     ,global_attribute12
     ,global_attribute13
     ,global_attribute14
     ,global_attribute15
     ,global_attribute16
     ,global_attribute17
     ,global_attribute18
     ,global_attribute19
     ,global_attribute20
     ,error_flag
     ,operation_code
     ,ready_flag
     ,status_flag
     ,force_apply_flag
     ,change_request_code
     ,submission_datetime
     ,conversion_type
     ,conversion_type_code
     ,transactional_curr
     ,transactional_curr_code
     ,salesrep_id
     ,salesrep
     ,sales_channel_code
     ,return_reason_code
     ,customer_id
     ,customer_name
     ,customer_number
     ,invoice_address1
     ,invoice_address2
     ,invoice_address3
     ,invoice_address4
     ,invoice_city
     ,invoice_country
     ,invoice_county
     ,invoice_customer
     ,invoice_customer_number
     ,invoice_postal_code
     ,invoice_province_int
     ,invoice_site
     ,invoice_site_code
     ,invoice_state
     ,invoice_to_contact_first_name
     ,invoice_to_contact_last_name
     ,ordered_by_contact_first_name
     ,ordered_by_contact_last_name
     ,drop_ship_flag
     ,header_po_context
     ,po_attribute_1
     ,po_attribute_2
     ,po_attribute_3
     ,po_attribute_4
     ,po_attribute_5
     ,po_attribute_6
     ,po_attribute_7
     ,po_attribute_8
     ,po_attribute_9
     ,po_attribute_10
     ,po_attribute_11
     ,po_attribute_12
     ,po_attribute_13
     ,po_attribute_14
     ,po_attribute_15
     ,po_revision_date
     ,ship_to_address1
     ,ship_to_address2
     ,ship_to_address3
     ,ship_to_address4
     ,ship_to_city
     ,ship_to_contact_first_name
     ,ship_to_contact_last_name
     ,ship_to_county
     ,ship_to_customer
     ,ship_to_customer_number
     ,ship_to_postal_code
     ,ship_to_province
     ,ship_to_site_int
     ,ship_to_state
     ,ship_to_country
     ,shipment_priority_code_int
     ,change_reason
     ,change_comments
     ,sold_to_site_use_id
     ,transaction_phase_code
     ,expiration_date
     ,quote_number
     ,quote_date
     ,sales_document_name
     ,user_status_code
     ,end_customer_id
     ,end_customer_contact_id
     ,end_customer_site_use_id
     ,ib_owner_code			--modified for bug 4240715
     ,ib_current_location_code		--modified for bug 4240715
     ,ib_installed_at_location_code	--modified for bug 4240715
     )
     select
      order_source_id_v           /* order_source_id      number */
     ,to_char(order_number_v)     /* orig_sys_document_ref varchar2(50) */
     ,''                          /* change_sequence      varchar2(50) */
     ,''                          /* order_source         varchar2(30) */
     ,org_id          --moac      /* org_id               number */
     ,''                          /* header_id            number */
     ,''                          /* order_number         number */
     ,''                          /* version_number       number */
     ,sysdate                     /* ordered_date         date */
     ,'ORDER'                     /* order_category       varchar2(30) */
     ,''                          /* order_type           varchar2(30) */
     ,order_type_id               /* order_type_id        number */
     ,sysdate                     /* request_date         date */
     ,''                          /* shipment_priority    varchar2(30) */
     ,shipment_priority_code      /* shipment_priority_code varchar2(30) */
     ,''                          /* demand_class         varchar2(30) */
     ,demand_class_code           /* demand_class_code    varchar2(30) */
     ,''                          /* price_list           varchar2(30) */
     ,price_list_id               /* price_list_id        number */
     ,tax_exempt_flag             /* tax_exempt_flag      varchar2(30) */
     ,tax_exempt_number           /* tax_exempt_number    number */
     ,''                          /* tax_exempt_reason    varchar2(30) */
     ,tax_exempt_reason_code      /* tax_exempt_reason_code varchar2(30) */
     ,conversion_rate             /* conversion_rate      number */
     ,conversion_rate_date        /* conversion_rate_date date */
     ,partial_shipments_allowed   /* partial_shipments_allowed varchar2(1) */
     --,remainder_orders_allowed  /* remainder_orders_allowed  varchar2(1) */
     ,ship_tolerance_above        /* ship_tolerance_above number */
     ,ship_tolerance_below        /* ship_tolerance_below number */
     ,order_date_type_code        /* order_date_type_code varchar2(30) */
     ,earliest_schedule_limit     /* earliest_schedule_limit      number */
     ,latest_schedule_limit       /* latest_schedule_limit        number */
     --,invoice_tolerance_above   /* invoice_tolerance_above   number */
     --,invoice_tolerance_below   /* invoice_tolerance_below   number */
     --,related_po_number         /* related_po_number    varchar2(50) */
     ,''                          /* agreement            varchar2(50) */
     ,''                          /* agreement_id         number */
     ,''                          /* tax_point            varchar2(30) */
     ,tax_point_code              /* tax_point_code       varchar2(30) */
     ,''                          /* customer_po_number   varchar2(50) */
     ,''                          /* customer_payment_term    varchar2(30) */
     ,''                          /* customer_payment_term_id number */
     ,payment_type_code           /* payment_type_code    varchar2(30) */
     ,payment_amount              /* payment_amount       number */
     ,check_number                /* check_number         varchar2(50) */
     ,credit_card_code            /* credit_card_code     varchar2(30) */
     ,credit_card_holder_name     /* credit_card_holder_name   varchar2(50) */
     ,credit_card_number          /* credit_card_number   varchar2(50) */
     ,credit_card_expiration_date /* credit_card_expiration_date  date */
     ,credit_card_approval_code   /* credit_card_approval_code varchar2(50) */
     ,''                          /* invoicing_rule       varchar2(30) */
     ,invoicing_rule_id           /* invoicing_rule_id    number */
     ,''                          /* accounting_rule      varchar2(30) */
     ,accounting_rule_id          /* accounting_rule_id   number */
     ,''                          /* payment_term         varchar2(30) */
     ,payment_term_id             /* payment_term_id      number */
     ,''                          /* shipping_method      varchar2(30) */
     ,shipping_method_code        /* shipping_method_code varchar2(30) */
     ,''                          /* shipping_instructions varchar2(240) */
     ,''                          /* packing_instructions varchar2(240) */
     ,''                          /* freight_carrier_code varchar2(30) */
     ,''                          /* freight_terms        varchar2(30) */
     ,freight_terms_code          /* freight_terms_code   varchar2(30) */
     ,''                          /* fob_point            varchar2(30) */
     ,fob_point_code              /* fob_point_code       varchar2(30) */
     ,''                          /* sold_from_org        varchar2(30) */
     --,sold_from_org_id          /* sold_from_org_id     number */
     --,''                        /* sold_to_org          varchar2(30) */
     ,sold_to_org_id              /* sold_to_org_id       number */
     ,''                          /* ship_from_org        varchar2(30) */
     ,ship_from_org_id            /* ship_from_org_id     number */
     ,''                          /* ship_to_org          varchar2(30) */
     ,ship_to_org_id              /* ship_to_org_id       number */
     ,''                          /* invoice_to_org       varchar2(30) */
     ,invoice_to_org_id           /* invoice_to_org_id    number */
     ,''                          /* deliver_to_org       varchar2(30) */
     ,''                          /* deliver_to_org_id    number */
     ,''                          /* deliver_to_customer  varchar2(30) */
     ,''                          /* deliver_to_customer_number varchar2(30) */
     ,''                          /* sold_to_contact      varchar2(30) */
     ,sold_to_contact_id          /* sold_to_contact_id   number */
     ,''                          /* ship_to_contact      varchar2(30) */
     ,ship_to_contact_id          /* ship_to_contact_id   number */
     ,''                          /* invoice_to_contact   varchar2(30) */
     ,invoice_to_contact_id       /* invoice_to_contact_id number */
     ,''                          /* deliver_to_contact   varchar2(30) */
     ,deliver_to_contact_id       /* deliver_to_contact_id number */
     ,sysdate                     /* creation_date        date   not null */
     ,-1                          /* created_by           number not null */
     ,sysdate                     /* last_update_date     date   not null */
     ,-1                          /* last_updated_by      number not null */
     ,0                           /* last_update_login    number */
     ,program_application_id      /* program_application_id number */
     ,program_id                  /* program_id           number */
     ,program_update_date         /* program_update_date  date */
     ,''                          /* request_id           number */
     ,context                     /* context              varchar2(30) */
     ,attribute1                  /* attribute1           varchar2(240) */
     ,attribute2                  /* attribute2           varchar2(240) */
     ,attribute3                  /* attribute3           varchar2(240) */
     ,attribute4                  /* attribute4           varchar2(240) */
     ,attribute5                  /* attribute5           varchar2(240) */
     ,attribute6                  /* attribute6           varchar2(240) */
     ,attribute7                  /* attribute7           varchar2(240) */
     ,attribute8                  /* attribute8           varchar2(240) */
     ,attribute9                  /* attribute9           varchar2(240) */
     ,attribute10                 /* attribute10          varchar2(240) */
     ,attribute11                 /* attribute11          varchar2(240) */
     ,attribute12                 /* attribute12          varchar2(240) */
     ,attribute13                 /* attribute13          varchar2(240) */
     ,attribute14                 /* attribute14          varchar2(240) */
     ,attribute15                 /* attribute15          varchar2(240) */
     ,global_attribute_category   /* global_attribute_category varchar2(30) */
     ,global_attribute1           /* global_attribute1    varchar2(240) */
     ,global_attribute2           /* global_attribute2    varchar2(240) */
     ,global_attribute3           /* global_attribute3    varchar2(240) */
     ,global_attribute4           /* global_attribute4    varchar2(240) */
     ,global_attribute5           /* global_attribute5    varchar2(240) */
     ,global_attribute6           /* global_attribute6    varchar2(240) */
     ,global_attribute7           /* global_attribute7    varchar2(240) */
     ,global_attribute8           /* global_attribute8    varchar2(240) */
     ,global_attribute9           /* global_attribute9    varchar2(240) */
     ,global_attribute10          /* global_attribute10   varchar2(240) */
     ,global_attribute11          /* global_attribute11   varchar2(240) */
     ,global_attribute12          /* global_attribute12   varchar2(240) */
     ,global_attribute13          /* global_attribute13   varchar2(240) */
     ,global_attribute14          /* global_attribute14   varchar2(240) */
     ,global_attribute15          /* global_attribute15   varchar2(240) */
     ,global_attribute16          /* global_attribute16   varchar2(240) */
     ,global_attribute17          /* global_attribute17   varchar2(240) */
     ,global_attribute18          /* global_attribute18   varchar2(240) */
     ,global_attribute19          /* global_attribute19   varchar2(240) */
     ,global_attribute20          /* global_attribute20   varchar2(240) */
     ,''                          /* error_flag           varchar2(1) */
     ,'INSERT'                    /* operation_code       varchar2(30) */
     ,''                          /* ready_flag           varchar2(1) */
     ,''                          /* status_flag          varchar2(1) */
     ,''                          /* force_apply_flag     varchar2(1) */
     ,''                          /* change_request_code  varchar2(30) */
     ,''                          /* submission_datetime  date */
     ,''                          /* conversion_type      varchar2(30) */
     ,conversion_type_code        /* conversion_type_code varchar2(30) */
     ,''                          /* transactional_curr   varchar2(30) */
     ,transactional_curr_code     /* transactional_curr_code  varchar2(3) */
     ,salesrep_id                 /* salesrep_id          number */
     ,''                          /* salesrep             varchar2(30) */
     ,sales_channel_code          /* sales_channel_code   varchar2(30) */
     ,return_reason_code          /* return_reason_code   varchar2(30) */
     ,''                          /* customer_id          number */
     ,''                          /* customer_name        varchar2(30) */
     ,''                          /* customer_number      varchar2(30) */
     ,''                          /* invoice_address1     varchar2(35) */
     ,''                          /* invoice_address2     varchar2(35) */
     ,''                          /* invoice_address3     varchar2(35) */
     ,''                          /* invoice_address4     varchar2(35) */
     ,''                          /* invoice_city         varchar2(30) */
     ,''                          /* invoice_country      varchar2(20) */
     ,''                          /* invoice_county       varchar2(25) */
     ,''                          /* invoice_customer     varchar2(60) */
     ,''                          /* invoice_customer_number  varchar2(30) */
     ,''                          /* invoice_postal_code  varchar2(15) */
     ,''                          /* invoice_province_int varchar2(30) */
     ,''                          /* invoice_site         varchar2(30) */
     ,''                          /* invoice_site_code    varchar2(30) */
     ,''                          /* invoice_state        varchar2(30) */
     ,''                          /* invoice_to_contact_first_namevarchar2(30)*/
     ,''                          /* invoice_to_contact_last_name varchar2(30)*/
     ,''                          /* ordered_by_contact_first_namevarchar2(30)*/
     ,''                          /* ordered_by_contact_last_name varchar2(30)*/
     ,''                          /* drop_ship_flag       varchar2(1) */
     ,''                          /* header_po_context    varchar2(30) */
     ,''                          /* po_attribute_1       varchar2(240) */
     ,''                          /* po_attribute_2       varchar2(240) */
     ,''                          /* po_attribute_3       varchar2(240) */
     ,''                          /* po_attribute_4       varchar2(240) */
     ,''                          /* po_attribute_5       varchar2(240) */
     ,''                          /* po_attribute_6       varchar2(240) */
     ,''                          /* po_attribute_7       varchar2(240) */
     ,''                          /* po_attribute_8       varchar2(240) */
     ,''                          /* po_attribute_9       varchar2(240) */
     ,''                          /* po_attribute_10      varchar2(240) */
     ,''                          /* po_attribute_11      varchar2(240) */
     ,''                          /* po_attribute_12      varchar2(240) */
     ,''                          /* po_attribute_13      varchar2(240) */
     ,''                          /* po_attribute_14      varchar2(240) */
     ,''                          /* po_attribute_15      varchar2(240) */
     ,''                          /* po_revision_date     date */
     ,''                          /* ship_to_address_1    varchar2(30) */
     ,''                          /* ship_to_address_2    varchar2(30) */
     ,''                          /* ship_to_address_3    varchar2(30) */
     ,''                          /* ship_to_address_4    varchar2(30) */
     ,''                          /* ship_to_city         varchar2(30) */
     ,''                          /* ship_to_contact_first_namevarchar2(30) */
     ,''                          /* ship_to_contact_last_name varchar2(30) */
     ,''                          /* ship_to_county       varchar2(30) */
     ,''                          /* ship_to_customer     varchar2(30) */
     ,''                          /* ship_to_customer_numbervarchar2(30) */
     ,''                          /* ship_to_postal_code  varchar2(30) */
     ,''                          /* ship_to_province     varchar2(30) */
     ,''                          /* ship_to_site_int     varchar2(30) */
     ,''                          /* ship_to_state        varchar2(30) */
     ,''                          /* ship_to_country      varchar2(30) */
     ,''                          /* shipment_priority_code_intvarchar2(30) */
     ,''                          /* change_reason        varchar2(30) */
     ,''                          /* change_comments      varchar2(2000) */
     ,sold_to_site_use_id         /* sold_to_site_use_id  number */
     ,transaction_phase_code      /* transaction_phase_code varchar2(30) */
     ,expiration_date             /* expiration_date      date */
     ,quote_number                /* quote_number         number */
     ,quote_date                  /* quote_date           date */
     ,sales_document_name         /* sales_document_name  varchar2(240) */
     ,user_status_code            /* user_status_code     varcahr2(30)  */
     ,end_customer_id             /* end_customer_id      number */
     ,end_customer_contact_id     /* end_customer_contact_id      number */
     ,end_customer_site_use_id    /* end_customer_site_use_id     number */
     ,ib_owner                    /* ib_owner             varchar2(60) */
     ,ib_current_location         /* ib_current_location  varchar2(60) */
     ,ib_installed_at_location    /* ib_installed_at_location varchar2(60) */
     from oe_order_headers_all
     where order_number = order_number_v;

     IF SQL%ROWCOUNT > 0 THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'OEXPIFPB: AFTER SUCCESSFUL INSERT TO OE_HEADERS_IFACE_ALL' ) ;
        END IF;
     ELSE
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'OEXPIFPB: AFTER UN-SUCCESSFUL INSERT TO OE_HEADERS_IFACE_ALL' ) ;
        END IF;
        return;
     END IF;

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'OEXPIFPB: BEFORE INSERT TO OE_LINES_IFACE_ALL' ) ;
     END IF;

     INSERT INTO oe_lines_iface_all (
       order_source_id                       /* number */
     , orig_sys_document_ref                 /* varchar2(50) */
     , orig_sys_line_ref                     /* varchar2(50) */
     , orig_sys_shipment_ref                 /* varchar2(50) */
     , change_sequence                       /* varchar2(50) */
     , org_id                                /* number */
     , line_number                           /* number */
     , shipment_number                       /* number */
     , line_id                               /* number */
     --, invoice_number                      /* varchar2(20) */
     , line_type_id                          /* number */
     , line_type                             /* varchar2(30) */
     , item_type_code                        /* varchar2(30) */
     , inventory_item_id                     /* number */
     , inventory_item                        /* varchar2(30) */
     , link_to_line_ref                      /* varchar2(50) */
     , top_model_line_ref                    /* varchar2(50) */
     , component_code
--      , component_sequence_id
--      , sort_order
     , request_date                          /* date */
     , promise_date                          /* date */
     , schedule_ship_date                    /* date */
     , schedule_arrival_date                 /* date */
     , delivery_lead_time                    /* number */
     , ordered_quantity                      /* number */
     , order_quantity_uom                    /* varchar2(3) */
     , ordered_quantity2                      /* number  OPM */
     , ordered_quantity_uom2                    /* varchar2(3) OPM  */
     , shipping_quantity                     /* number */
     , shipping_quantity_uom                 /* varchar2(3) */
     , shipped_quantity                      /* number */
     , cancelled_quantity                    /* number */
     , fulfilled_quantity                    /* number */
     , pricing_quantity                      /* number */
     , pricing_quantity_uom                  /* varchar2(3) */
     --, sold_from_org_id                    /* number */
     --, sold_from_org                               /* varchar2(30) */
     , sold_to_org_id                        /* number */
     , sold_to_org                           /* varchar2(30) */
     , ship_from_org_id                      /* number */
     , ship_from_org                         /* varchar2(30) */
     , ship_to_org_id                        /* number */
     , ship_to_org                           /* varchar2(30) */
     , deliver_to_org_id                     /* number */
     , deliver_to_org                        /* varchar2(30) */
     , invoice_to_org_id                     /* number */
     , invoice_to_org                        /* varchar2(30) */
     , ship_set_id                           /* number */
     , ship_set_name                         /* varchar(30) */
     , ship_to_address1                      /* varchar2(30) */
     , ship_to_address2                      /* varchar2(30) */
     , ship_to_address3                      /* varchar2(30) */
     , ship_to_address4                      /* varchar2(30) */
     , ship_to_city                          /* varchar2(30) */
     , ship_to_county                        /* varchar2(30) */
     , ship_to_state                         /* varchar2(30) */
     , ship_to_postal_code                   /* varchar2(30) */
     , ship_to_country                       /* varchar2(30) */
     , ship_to_contact_first_name            /* varchar2(30) */
     , ship_to_contact_last_name             /* varchar2(30) */
     , ship_to_contact_job_title             /* varchar2(30) */
     , ship_to_contact_area_code1            /* varchar2(10) */
     , ship_to_contact_area_code2            /* varchar2(10) */
     , ship_to_contact_area_code3            /* varchar2(10) */
     , ship_to_contact_id                    /* number */
     , ship_to_contact                       /* varchar2(30) */
     , deliver_to_contact_id                 /* number */
     , deliver_to_contact                    /* varchar2(30) */
     , invoice_to_contact_id                 /* number */
     , invoice_to_contact                    /* varchar2(30) */
     , drop_ship_flag                        /* varchar2(1) */
     , ship_tolerance_above                  /* number */
     , ship_tolerance_below                  /* number */
     --, invoice_tolerance_above               /* number */
     --, invoice_tolerance_below               /* number */
     --, cost_type_id                                /* number */
     --, cost_type                           /* varchar2(30) */
     --, costing_date                          /* date */
     --, material_cost                         /* number */
     --, material_overhead_cost                /* number */
     --, resource_cost                         /* number */
     --, outside_processing_cost               /* number */
     --, overhead_cost                         /* number */
     , price_list                            /* varchar2(30) */
     , price_list_id                         /* number */
     , pricing_date                          /* date */
     , unit_list_price                       /* number */
     , unit_selling_price                    /* number */
     , explosion_date                        /* date */
     , calculate_price_flag                  /* varchar2(1) */
     , tax_code                              /* varchar2(50)  */
     , tax                                   /* varchar2(50) */
     , tax_value                             /* number */
     , tax_date                              /* date */
     , tax_point_code                        /* varchar2(30) */
     , tax_point                             /* varchar2(30) */
     , tax_exempt_flag                       /* varchar2(30) */
     , tax_exempt_number                     /* number */
     , tax_exempt_reason_code                /* varchar2(30) */
     , tax_exempt_reason                     /* varchar2(30) */
     , agreement_id                          /* number */
     , agreement                             /* varchar2(30) */
     , invoicing_rule_id                     /* number */
     , invoicing_rule                        /* varchar2(30) */
     , accounting_rule_id                    /* number */
     , accounting_rule                       /* varchar2(30) */
     , payment_term_id                       /* number */
     , payment_term                          /* varchar2(30) */
     , demand_class                          /* varchar2(30) */
     , demand_class_code                     /* varchar2(30) */
     , shipment_priority_code                /* varchar2(30) */
     , shipment_priority                     /* varchar2(30) */
     , shipping_method_code                  /* varchar2(30) */
     , shipping_method                       /* varchar2(30) */
     , freight_carrier_code                  /* varchar2(30) */
     , freight_terms_code                    /* varchar2(30) */
     , freight_terms                         /* varchar2(30) */
     , fob_point_code                        /* varchar2(30) */
     , fob_point                             /* varchar2(30) */
     , reference_type                        /* varchar2(30) */
     , reference_header_id                   /* number */
     , reference_header                      /* varchar2(30) */
     , reference_line_id                     /* number */
     , reference_line                        /* varchar2(30) */
     , customer_po_number                    /* varchar2(50) */
     , customer_line_number                  /* varchar2(50) */
     , customer_shipment_number              /* varchar2(50) */
     --, related_po_number                     /* varchar2(50)  */
     , customer_item_id_type                 /* varchar2(30) */
     , customer_item_id                      /* number */
     , customer_item_name                    /* number */
     -- , customer_item_revision                /* varchar2(50) */
     , customer_item_net_price               /* number */
     , customer_payment_term_id              /* number */
     , customer_payment_term                 /* varchar2(30) */
     , demand_bucket_type_code               /* varchar2(30) */
     , schedule_item_detail                  /* varchar2(30) */
     , demand_stream                         /* varchar2(30) */
     , customer_dock_code                    /* varchar2(30) */
     , customer_dock                         /* varchar2(50) */
     , customer_job                          /* varchar2(50) */
     , customer_production_line              /* varchar2(50) */
     , cust_model_serial_number              /* varchar2(50) */
     --, planning_prod_seq_num               /* number */
     , project_id                            /* number */
     , project                               /* varchar2(30) */
     , task_id                               /* number */
     , task                                  /* varchar2(30) */
     , end_item_unit_number                  /* varchar2(30) */
     , item_revision                         /* varchar2(3) */
     --, payment_trx_id                      /* number */
     --, payment_trx                         /* varchar2(30) */
     , line_po_context                       /* varchar2(30) */
     , contract_po_number                    /* varchar2(150) */
     , attribute1                            /* varchar2(240) */
     , attribute2                            /* varchar2(240) */
     , attribute3                            /* varchar2(240) */
     , attribute4                            /* varchar2(240) */
     , attribute5                            /* varchar2(240) */
     , attribute6                            /* varchar2(240) */
     , attribute7                            /* varchar2(240) */
     , attribute8                            /* varchar2(240) */
     , attribute9                            /* varchar2(240) */
     , attribute10                           /* varchar2(240) */
     , attribute11                           /* varchar2(240) */
     , attribute12                           /* varchar2(240) */
     , attribute13                           /* varchar2(240) */
     , attribute14                           /* varchar2(240) */
     , attribute15                           /* varchar2(240) */
     , industry_context                      /* varchar2(30) */
     , industry_attribute1                   /* varchar2(240) */
     , industry_attribute2                   /* varchar2(240) */
     , industry_attribute3                   /* varchar2(240) */
     , industry_attribute4                   /* varchar2(240) */
     , industry_attribute5                   /* varchar2(240) */
     , industry_attribute6                   /* varchar2(240) */
     , industry_attribute7                   /* varchar2(240) */
     , industry_attribute8                   /* varchar2(240) */
     , industry_attribute9                   /* varchar2(240) */
     , industry_attribute10                  /* varchar2(240) */
     , industry_attribute11                  /* varchar2(240) */
     , industry_attribute12                  /* varchar2(240) */
     , industry_attribute13                  /* varchar2(240) */
     , industry_attribute14                  /* varchar2(240) */
     , industry_attribute15                  /* varchar2(240) */
     , industry_attribute16                  /* varchar2(240) */
     , industry_attribute17                  /* varchar2(240) */
     , industry_attribute18                  /* varchar2(240) */
     , industry_attribute19                  /* varchar2(240) */
     , industry_attribute20                  /* varchar2(240) */
     , industry_attribute21                  /* varchar2(240) */
     , industry_attribute22                  /* varchar2(240) */
     , industry_attribute23                  /* varchar2(240) */
     , industry_attribute24                  /* varchar2(240) */
     , industry_attribute25                  /* varchar2(240) */
     , industry_attribute26                  /* varchar2(240) */
     , industry_attribute27                  /* varchar2(240) */
     , industry_attribute28                  /* varchar2(240) */
     , industry_attribute29                  /* varchar2(240) */
     , industry_attribute30                  /* varchar2(240) */
     , pricing_context                       /* varchar2(150) */
     , pricing_attribute1                    /* varchar2(240) */
     , pricing_attribute2                    /* varchar2(240) */
     , pricing_attribute3                    /* varchar2(240) */
     , pricing_attribute4                    /* varchar2(240) */
     , pricing_attribute5                    /* varchar2(240) */
     , pricing_attribute6                    /* varchar2(240) */
     , pricing_attribute7                    /* varchar2(240) */
     , pricing_attribute8                    /* varchar2(240) */
     , pricing_attribute9                    /* varchar2(240) */
     , pricing_attribute10                   /* varchar2(240) */
     , global_attribute_category             /* varchar2(30) */
     , global_attribute1                     /* varchar2(240) */
     , global_attribute2                     /* varchar2(240) */
     , global_attribute3                     /* varchar2(240) */
     , global_attribute4                     /* varchar2(240) */
     , global_attribute5                     /* varchar2(240) */
     , global_attribute6                     /* varchar2(240) */
     , global_attribute7                     /* varchar2(240) */
     , global_attribute8                     /* varchar2(240) */
     , global_attribute9                     /* varchar2(240) */
     , global_attribute10                    /* varchar2(240) */
     , global_attribute11                    /* varchar2(240) */
     , global_attribute12                    /* varchar2(240) */
     , global_attribute13                    /* varchar2(240) */
     , global_attribute14                    /* varchar2(240) */
     , global_attribute15                    /* varchar2(240) */
     , global_attribute16                    /* varchar2(240) */
     , global_attribute17                    /* varchar2(240) */
     , global_attribute18                    /* varchar2(240) */
     , global_attribute19                    /* varchar2(240) */
     , global_attribute20                    /* varchar2(240) */
     , return_attribute1                     /* varchar2(240) */
     , return_attribute2                     /* varchar2(240) */
     , return_attribute3                     /* varchar2(240) */
     , return_attribute4                     /* varchar2(240) */
     , return_attribute5                     /* varchar2(240) */
     , return_attribute6                     /* varchar2(240) */
     , return_attribute7                     /* varchar2(240) */
     , return_attribute8                     /* varchar2(240) */
     , return_attribute9                     /* varchar2(240) */
     , return_attribute10                    /* varchar2(240) */
     , return_attribute11                    /* varchar2(240) */
     , return_attribute12                    /* varchar2(240) */
     , return_attribute13                    /* varchar2(240) */
     , return_attribute14                    /* varchar2(240) */
     , return_attribute15                    /* varchar2(240) */
     , inventory_item_segment_1              /* varchar2(240) */
     , inventory_item_segment_2              /* varchar2(240) */
     , inventory_item_segment_3              /* varchar2(240) */
     , inventory_item_segment_4              /* varchar2(240) */
     , inventory_item_segment_5              /* varchar2(240) */
     , inventory_item_segment_6              /* varchar2(240) */
     , inventory_item_segment_7              /* varchar2(240) */
     , inventory_item_segment_8              /* varchar2(240) */
     , inventory_item_segment_9              /* varchar2(240) */
     , inventory_item_segment_10             /* varchar2(240) */
     , inventory_item_segment_11             /* varchar2(240) */
     , inventory_item_segment_12             /* varchar2(240) */
     , inventory_item_segment_13             /* varchar2(240) */
     , inventory_item_segment_14             /* varchar2(240) */
     , inventory_item_segment_15             /* varchar2(240) */
     , inventory_item_segment_16             /* varchar2(240) */
     , inventory_item_segment_17             /* varchar2(240) */
     , inventory_item_segment_18             /* varchar2(240) */
     , inventory_item_segment_19             /* varchar2(240) */
     , inventory_item_segment_20             /* varchar2(240) */
     , operation_code                        /* varchar2(30) */
     , error_flag                            /* varchar2(1) */
     , status_flag                           /* varchar2(1) */
     , change_request_code                   /* varchar2(30) */
     , request_id                            /* number */
     , created_by                            /* number       not null */
     , creation_date                         /* date         not null */
     , last_updated_by                       /* number       not null */
     , last_update_date                      /* date         not null */
     , last_update_login                     /* number */
     , program_application_id                /* number */
     , program_id                            /* number */
     , program_update_date                   /* date */
     , split_from_line_id                    /* number */
     , cust_production_seq_num               /* varchar2(50) */
     , authorized_to_ship_flag               /* varchar2(1) */
     , veh_cus_item_cum_key_id               /* number */
     , salesrep_id                           /* number */
     , return_reason_code                    /* varchar2(30) */
     , over_ship_reason_code                 /* varchar2(30) */
     , over_ship_resolved_flag               /* varchar2(1) */
     , credit_invoice_line_id                /* number */
     , change_reason                         /* varchar2(30) */
     , change_comments                       /* varchar2(2000) */
     , user_item_description
     , end_customer_id                       /* number */
     , end_customer_contact_id               /* number */
     , end_customer_site_use_id              /* number */
     , ib_owner_code                         /* varchar2(60) */	--modified for bug 4240715
     , ib_current_location_code              /* varchar2(60) */	--modified for bug 4240715
     , ib_installed_at_location_code         /* varchar2(60) */	--modified for bug 4240715
     -- INVCONV
     , shipping_quantity2                     /* number */
     , shipping_quantity_uom2                 /* varchar2(3) */
     , shipped_quantity2                      /* number */
     , cancelled_quantity2                    /* number */
     , fulfilled_quantity2                    /* number */


     )
     select
       order_source_id_v          /* order_source_id      number */
     , to_char(order_number_v)    /* orig_sys_document_ref varchar2(50) */
     , rtrim(to_char(line_number)||'-'||to_char(option_number))
                                  /* orig_sys_line_ref    varchar2(50) */
     , ''                         /* orig_sys_shipment_refvarchar2(50) */
     , ''                         /* change_sequence      varchar2(50) */
     , org_id         --moac      /* org_id               number */
     , line_number                /* line_number          number */
     , ''                         /* shipment_number      number */
-- Following is inserted only for the purpose of the referece for the child
-- level once they are created this should be updated to NULL
     , line_id                    /* line_id              number */
     --, ''                       /* invoice_number       varchar2(20) */
     , line_type_id               /* line_type_id         number */
     , ''                         /* line_type            varchar2(30) */
     , item_type_code             /* item_type_code       varchar2(30) */
     , inventory_item_id          /* inventory_item_id    number */
     , ''                         /* inventory_item       varchar2(30) */
     , decode(link_to_line_id, NULL, NULL, get_link_to_line_ref(line_id))
                                  /* link_to_line_ref     varchar2(50) */
     , decode(top_model_line_id, NULL, NULL, get_top_model_line_ref(line_id))
                                  /* link_to_line_ref     varchar2(50) */
     , component_code
--      , component_sequence_id
--      , sort_order
     , request_date               /* request_date         date */
     , promise_date               /* promise_date         date */
     , schedule_ship_date         /* schedule_ship_date   date */
     , schedule_arrival_date      /* schedule_arrival_date   date */
     , delivery_lead_time         /* delivery_lead_time   number */
     , ordered_quantity           /* ordered_quantity     number */
     , order_quantity_uom         /* order_quantity_uom   varchar2(3) */
     , ordered_quantity2           /* ordered_quantity     number OPM  */
     , ordered_quantity_uom2         /* order_quantity_uom   varchar2(3) OPM  */
     , shipping_quantity          /* shipping_quantity    number */
     , shipping_quantity_uom      /* shipping_quantity_uomvarchar2(3) */
     , shipped_quantity           /* shipped_quantity     number */
     , ''                         /* cancelled_quantity   number */
     , fulfilled_quantity         /* fulfilled_quantity   number */
     , ''                         /* pricing_quantity     number */
     , ''                         /* pricing_quantity_uom varchar2(3) */
     --, sold_from_org_id         /* sold_from_org_id     number */
     --, ''                       /* sold_from_org        varchar2(30) */
     , sold_to_org_id             /* sold_to_org_id       number */
     , ''                         /* sold_to_org          varchar2(30) */
     , ship_from_org_id           /* ship_from_org_id     number */
     , ''                         /* ship_from_org        varchar2(30) */
     , ship_to_org_id             /* ship_to_org_id       number */
     , ''                         /* ship_to_org          varchar2(30) */
     , ''                         /* deliver_to_org_id    number */
     , ''                         /* deliver_to_org       varchar2(30) */
     , invoice_to_org_id          /* invoice_to_org_id    number */
     , ''                         /* invoice_to_org       varchar2(30) */
     , ''                         /* ship_set_id          number */
     , ship_set_id                /* ship_set_name        varchar2(30) */
     , ''                         /* ship_to_address_1    varchar2(30) */
     , ''                         /* ship_to_address_2    varchar2(30) */
     , ''                         /* ship_to_address_3    varchar2(30) */
     , ''                         /* ship_to_address_4    varchar2(30) */
     , ''                         /* ship_to_city         varchar2(30) */
     , ''                         /* ship_to_county       varchar2(30) */
     , ''                         /* ship_to_state        varchar2(30) */
     , ''                         /* ship_to_postal_code  varchar2(30) */
     , ''                         /* ship_to_country      varchar2(30) */
     , ''                         /* ship_to_contact_first_namevarchar2(30) */
     , ''                         /* ship_to_contact_last_name varchar2(30) */
     , ''                         /* ship_to_contact_job_title varchar2(30) */
     , ''                         /* ship_to_contact_area_code1varchar2(10) */
     , ''                         /* ship_to_contact_area_code2varchar2(10) */
     , ''                         /* ship_to_contact_area_code3varchar2(10) */
     , ship_to_contact_id         /* ship_to_contact_id   number */
     , ''                         /* ship_to_contact      varchar2(30) */
     , deliver_to_contact_id      /* deliver_to_contact_idnumber */
     , ''                         /* deliver_to_contact   varchar2(30) */
     , invoice_to_contact_id      /* invoice_to_contact_idnumber */
     , ''                         /* invoice_to_contact   varchar2(30) */
     , ''                         /* drop_ship_flag       varchar2(1) */
     , ship_tolerance_above       /* ship_tolerance_above number */
     , ship_tolerance_below       /* ship_tolerance_below number */
     --, invoice_tolerance_above  /* invoice_tolerance_above number */
     --, invoice_tolerance_below  /* invoice_tolerance_below      number */
     --, cost_type_id             /* cost_type_id         number */
     --, ''                       /* cost_type            varchar2(30) */
     --, costing_date             /* costing_date         date */
     --, material_cost            /* material_cost        number */
     --, material_overhead_cost   /* material_overhead_cost       number */
     --, resource_cost            /* resource_cost        number */
     --, outside_processing_cost  /* outside_processing_cost      number */
     --, overhead_cost            /* overhead_cost        number */
     , ''                         /* price_list           varchar2(30) */
     , price_list_id              /* price_list_id        number */
     , pricing_date               /* pricing_date         date */
     , nvl(unit_list_price,0)     /* unit_list_price      number */
     , nvl(unit_selling_price,0)  /* unit_selling_price   number */
     , explosion_date             /* date */
     , 'N'                        /* calculate_price_flag varchar2(1) */
     , tax_code                   /* tax_code             varchar2(50) */
     , ''                         /* tax                  varchar2(50) */
     , ''                  /* tax_value            number */
     , tax_date                   /* tax_date             date */
     , tax_point_code             /* tax_point_code       varchar2(30) */
     , ''                         /* tax_point            varchar2(30) */
     , tax_exempt_flag            /* tax_exempt_flag      varchar2(30) */
     , tax_exempt_number          /* tax_exempt_number    number */
     , tax_exempt_reason_code     /* tax_exempt_reason_code varchar2(30) */
     , ''                         /* tax_exempt_reason    varchar2(30) */
     , ''                         /* agreement_id         number */
     , ''                         /* agreement            varchar2(30) */
     , invoicing_rule_id          /* invoicing_rule_id    number */
     , ''                         /* invoicing_rule       varchar2(30) */
     , accounting_rule_id         /* accounting_rule_id   number */
     , ''                         /* accounting_rule      varchar2(30) */
     , payment_term_id            /* payment_term_id      number */
     , ''                         /* payment_term         varchar2(30) */
     , ''                         /* demand_class         varchar2(30) */
     , demand_class_code          /* demand_class_code    varchar2(30) */
     , shipment_priority_code     /* shipment_priority_code varchar2(30) */
     , ''                         /* shipment_priority    varchar2(30) */
     , shipping_method_code       /* shipping_method_code varchar2(30) */
     , ''                         /* shipping_method      varchar2(30) */
     , ''                         /* freight_carrier_code varchar2(30) */
     , freight_terms_code         /* freight_terms_code   varchar2(30) */
     , ''                         /* freight_terms        varchar2(30) */
     , fob_point_code             /* fob_point_code       varchar2(30) */
     , ''                         /* fob_point            varchar2(30) */
     , reference_type             /* reference_type       varchar2(30) */
     , reference_header_id        /* reference_header_id  number */
     , ''                         /* reference_header     varchar2(30) */
     , reference_line_id          /* reference_line_id    number */
     , ''                         /* reference_line       varchar2(30) */
     , ''                         /* customer_po_number   varchar2(50) */
     , ''                         /* customer_line_number varchar2(50) */
     , ''                         /* customer_shipment_number varchar2(50) */
     --, related_po_number        /* related_po_number    varchar2(50) */
     , 'INT' --item_identifier_type  /* customer_item_id_type varchar2(30) */
     , ordered_item_id            /* customer_item_id     number */
     , ordered_item               /* customer_item        varchar2(2000) */
     -- , customer_item_revision     /* customer_item_revision varchar2(50) */
     , ''                         /* customer_item_net_price number */
     , ''                         /* customer_payment_term_id number */
     , ''                         /* customer_payment_term     varchar2(30) */
     , demand_bucket_type_code    /* demand_bucket_type_code   varchar2(30) */
     , ''                         /* schedule_item_detail varchar2(30) */
     , ''                         /* demand_stream        varchar2(30) */
     , customer_dock_code         /* customer_dock_code   varchar2(30) */
     , ''                         /* customer_dock        varchar2(50) */
     , customer_job               /* customer_job         varchar2(50) */
     , customer_production_line   /* customer_production_line varchar2(50) */
     , cust_model_serial_number   /* cust_model_serial_number varchar2(50) */
     --, planning_prod_seq_num    /* planning_prod_seq_num number */
     , project_id                 /* project_id           number */
     , ''                         /* project              varchar2(30) */
     , task_id                    /* task_id              number */
     , ''                         /* task                 varchar2(30) */
     , end_item_unit_number       /* end_item_unit_number varchar2(30) */
     , item_revision              /* item_revision        varchar2(3) */
     --, payment_trx_id           /* payment_trx_id       number */
     --, ''                       /* payment_trx          varchar2(30) */
     , ''                         /* line_po_context      varchar2(30) */
     , ''                         /* contract_po_number   varchar2(150) */
     , attribute1                 /* attribute1           varchar2(240) */
     , attribute2                 /* attribute2           varchar2(240) */
     , attribute3                 /* attribute3           varchar2(240) */
     , attribute4                 /* attribute4           varchar2(240) */
     , attribute5                 /* attribute5           varchar2(240) */
     , attribute6                 /* attribute6           varchar2(240) */
     , attribute7                 /* attribute7           varchar2(240) */
     , attribute8                 /* attribute8           varchar2(240) */
     , attribute9                 /* attribute9           varchar2(240) */
     , attribute10                /* attribute10          varchar2(240) */
     , attribute11                /* attribute11          varchar2(240) */
     , attribute12                /* attribute12          varchar2(240) */
     , attribute13                /* attribute13          varchar2(240) */
     , attribute14                /* attribute14          varchar2(240) */
     , attribute15                /* attribute15          varchar2(240) */
     , industry_context           /* industry_context     varchar2(30) */
     , industry_attribute1        /* industry_attribute1  varchar2(240) */
     , industry_attribute2        /* industry_attribute2  varchar2(240) */
     , industry_attribute3        /* industry_attribute3  varchar2(240) */
     , industry_attribute4        /* industry_attribute4  varchar2(240) */
     , industry_attribute5        /* industry_attribute5  varchar2(240) */
     , industry_attribute6        /* industry_attribute6  varchar2(240) */
     , industry_attribute7        /* industry_attribute7  varchar2(240) */
     , industry_attribute8        /* industry_attribute8  varchar2(240) */
     , industry_attribute9        /* industry_attribute9  varchar2(240) */
     , industry_attribute10       /* industry_attribute10 varchar2(240) */
     , industry_attribute11       /* industry_attribute11 varchar2(240) */
     , industry_attribute12       /* industry_attribute12 varchar2(240) */
     , industry_attribute13       /* industry_attribute13 varchar2(240) */
     , industry_attribute14       /* industry_attribute14 varchar2(240) */
     , industry_attribute15       /* industry_attribute15 varchar2(240) */
     , industry_attribute16       /* industry_attribute16 varchar2(240) */
     , industry_attribute17       /* industry_attribute17 varchar2(240) */
     , industry_attribute18       /* industry_attribute18 varchar2(240) */
     , industry_attribute19       /* industry_attribute19 varchar2(240) */
     , industry_attribute20       /* industry_attribute20 varchar2(240) */
     , industry_attribute21       /* industry_attribute21 varchar2(240) */
     , industry_attribute22       /* industry_attribute22 varchar2(240) */
     , industry_attribute23       /* industry_attribute23 varchar2(240) */
     , industry_attribute24       /* industry_attribute24 varchar2(240) */
     , industry_attribute25       /* industry_attribute25 varchar2(240) */
     , industry_attribute26       /* industry_attribute26 varchar2(240) */
     , industry_attribute27       /* industry_attribute27 varchar2(240) */
     , industry_attribute28       /* industry_attribute28 varchar2(240) */
     , industry_attribute29       /* industry_attribute29 varchar2(240) */
     , industry_attribute30       /* industry_attribute30 varchar2(240) */
     , pricing_context            /* pricing_context      varchar2(150) */
     , pricing_attribute1         /* pricing_attribute1   varchar2(240) */
     , pricing_attribute2         /* pricing_attribute2   varchar2(240) */
     , pricing_attribute3         /* pricing_attribute3   varchar2(240) */
     , pricing_attribute4         /* pricing_attribute4   varchar2(240) */
     , pricing_attribute5         /* pricing_attribute5   varchar2(240) */
     , pricing_attribute6         /* pricing_attribute6   varchar2(240) */
     , pricing_attribute7         /* pricing_attribute7   varchar2(240) */
     , pricing_attribute8         /* pricing_attribute8   varchar2(240) */
     , pricing_attribute9         /* pricing_attribute9   varchar2(240) */
     , pricing_attribute10        /* pricing_attribute10  varchar2(240) */
     , global_attribute_category  /* global_attribute_category varchar2(30) */
     , global_attribute1          /* global_attribute1    varchar2(240) */
     , global_attribute2          /* global_attribute2    varchar2(240) */
     , global_attribute3          /* global_attribute3    varchar2(240) */
     , global_attribute4          /* global_attribute4    varchar2(240) */
     , global_attribute5          /* global_attribute5    varchar2(240) */
     , global_attribute6          /* global_attribute6    varchar2(240) */
     , global_attribute7          /* global_attribute7    varchar2(240) */
     , global_attribute8          /* global_attribute8    varchar2(240) */
     , global_attribute9          /* global_attribute9    varchar2(240) */
     , global_attribute10         /* global_attribute10   varchar2(240) */
     , global_attribute11         /* global_attribute11   varchar2(240) */
     , global_attribute12         /* global_attribute12   varchar2(240) */
     , global_attribute13         /* global_attribute13   varchar2(240) */
     , global_attribute14         /* global_attribute14   varchar2(240) */
     , global_attribute15         /* global_attribute15   varchar2(240) */
     , global_attribute16         /* global_attribute16   varchar2(240) */
     , global_attribute17         /* global_attribute17   varchar2(240) */
     , global_attribute18         /* global_attribute18   varchar2(240) */
     , global_attribute19         /* global_attribute19   varchar2(240) */
     , global_attribute20         /* global_attribute20   varchar2(240) */
     , return_attribute1          /* return_attribute1    varchar2(240) */
     , return_attribute2          /* return_attribute2    varchar2(240) */
     , return_attribute3          /* return_attribute3    varchar2(240) */
     , return_attribute4          /* return_attribute4    varchar2(240) */
     , return_attribute5          /* return_attribute5    varchar2(240) */
     , return_attribute6          /* return_attribute6    varchar2(240) */
     , return_attribute7          /* return_attribute7    varchar2(240) */
     , return_attribute8          /* return_attribute8    varchar2(240) */
     , return_attribute9          /* return_attribute9    varchar2(240) */
     , return_attribute10         /* return_attribute10   varchar2(240) */
     , return_attribute11         /* return_attribute11   varchar2(240) */
     , return_attribute12         /* return_attribute12   varchar2(240) */
     , return_attribute13         /* return_attribute13   varchar2(240) */
     , return_attribute14         /* return_attribute14   varchar2(240) */
     , return_attribute15         /* return_attribute15   varchar2(240) */
     , ''                         /* inventory_item_segment_1 varchar2(240) */
     , ''                         /* inventory_item_segment_2 varchar2(240) */
     , ''                         /* inventory_item_segment_3 varchar2(240) */
     , ''                         /* inventory_item_segment_4 varchar2(240) */
     , ''                         /* inventory_item_segment_5 varchar2(240) */
     , ''                         /* inventory_item_segment_6 varchar2(240) */
     , ''                         /* inventory_item_segment_7 varchar2(240) */
     , ''                         /* inventory_item_segment_8 varchar2(240) */
     , ''                         /* inventory_item_segment_9 varchar2(240) */
     , ''                         /* inventory_item_segment_10varchar2(240) */
     , ''                         /* inventory_item_segment_11varchar2(240) */
     , ''                         /* inventory_item_segment_12varchar2(240) */
     , ''                         /* inventory_item_segment_13varchar2(240) */
     , ''                         /* inventory_item_segment_14varchar2(240) */
     , ''                         /* inventory_item_segment_15varchar2(240) */
     , ''                         /* inventory_item_segment_16varchar2(240) */
     , ''                         /* inventory_item_segment_17varchar2(240) */
     , ''                         /* inventory_item_segment_18varchar2(240) */
     , ''                         /* inventory_item_segment_19varchar2(240) */
     , ''                         /* inventory_item_segment_20varchar2(240) */
     , 'INSERT'                   /* operation_code       varchar2(30) */
     , ''                         /* error_flag           varchar2(1) */
     , ''                         /* status_flag          varchar2(1) */
     , ''                         /* change_request_code  varchar2(30) */
     , ''                         /* request_id           number */
     , -1                         /* created_by           number */
     , sysdate                    /* creation_date        date */
     , -1                         /* last_updated_by      number */
     , sysdate                    /* last_update_date     date */
     , 0                          /* last_update_login    number */
     , program_application_id     /* program_application_idnumber */
     , program_id                 /* program_id           number */
     , program_update_date        /* program_update_date  date */
     , split_from_line_id         /* split_from_line_id   number */
     , cust_production_seq_num    /* cust_production_seq_num   varchar2(50) */
     , authorized_to_ship_flag    /* authorized_to_ship_flag    varchar2(1) */
     , veh_cus_item_cum_key_id    /* veh_cus_item_cum_key_id         number */
     , salesrep_id                /* salesrep_id          number */
     , return_reason_code         /* return_reason_code   varchar2(30) */
     , over_ship_reason_code      /* over_ship_reason_codevarchar2(30) */
     , over_ship_resolved_flag    /* over_ship_resolved_flag    varchar2(1) */
     , ''                         /* credit_invoice_line_id       number */
     , ''                         /* change_reason        varchar2(30) */
     , ''                         /* change_comments      varchar2(2000) */
     , user_item_description
     ,end_customer_id             /* end_customer_id      number */
     ,end_customer_contact_id     /* end_customer_contact_id      number */
     ,end_customer_site_use_id    /* end_customer_site_use_id     number */
     ,ib_owner                    /* ib_owner             varchar2(60) */
     ,ib_current_location         /* ib_current_location  varchar2(60) */
     ,ib_installed_at_location    /* ib_installed_at_location varchar2(60) */
    -- INVCONV
     , shipping_quantity2                     /* number */
     , shipping_quantity_uom2                 /* varchar2(3) */
     , shipped_quantity2                      /* number */
     , cancelled_quantity2                    /* number */
     , fulfilled_quantity2                    /* number */

     from oe_order_lines_all
     where header_id = old_header_id_v;

     IF SQL%ROWCOUNT > 0 THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'OEXPIFPB: AFTER SUCCESSFUL INSERT TO OE_LINES_IFACE_ALL' ) ;
        END IF;
     ELSE
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'OEXPIFPB: AFTER UN-SUCCESSFUL INSERT TO OE_LINES_IFACE_ALL' ) ;
        END IF;
     END IF;

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'OEXPIFPB: BEFORE INSERT TO OE_PRICE_ADJS_IFACE_ALL' ) ;
     END IF;

     /* Header Level Price Adjustment */
     INSERT INTO OE_PRICE_ADJS_IFACE_ALL (
       PROGRAM_ID                                        /*NUMBER(22)*/
     , PROGRAM_UPDATE_DATE                               /*DATE(7)*/
     , REQUEST_ID                                        /*NUMBER(22)*/
     , OPERATION_CODE                                    /*VARCHAR2(30)*/
     , ERROR_FLAG                                        /*VARCHAR2(1)*/
     , STATUS_FLAG                                       /*VARCHAR2(1)*/
     , INTERFACE_STATUS                                  /*VARCHAR2(1000)*/
     , LIST_HEADER_ID                                    /*NUMBER(22)*/
     , LIST_NAME                                         /*VARCHAR2(240)*/
     , LIST_LINE_ID                                      /*NUMBER(22)*/
     , LIST_LINE_TYPE_CODE                               /*VARCHAR2(30)*/
     , CHARGE_TYPE_CODE                                  /*VARCHAR2(30)*/
     , LIST_LINE_NUMBER                                  /*VARCHAR2(30)*/
     , MODIFIER_MECHANISM_TYPE_CODE                      /*VARCHAR2(30)*/
     , MODIFIED_FROM                                     /*NUMBER(22)*/
     , MODIFIED_TO                                       /*NUMBER(22)*/
     , UPDATED_FLAG                                      /*VARCHAR2(1)*/
     , UPDATE_ALLOWED                                    /*VARCHAR2(1)*/
     , APPLIED_FLAG                                      /*VARCHAR2(1)*/
     , CHANGE_REASON_CODE                                /*VARCHAR2(30)*/
     , CHANGE_REASON_TEXT                                /*VARCHAR2(2000)*/
     , OPERAND                                           /*NUMBER(22)*/
     , ARITHMETIC_OPERATOR                               /*VARCHAR2(30)*/
     , ADJUSTED_AMOUNT                                   /*NUMBER(22)*/
     , PRICING_PHASE_ID                                  /*NUMBER(22)*/
     , ORDER_SOURCE_ID                                   /*NUMBER(22)*/
     , ORIG_SYS_DOCUMENT_REF                             /*VARCHAR2(50)*/
     , ORIG_SYS_LINE_REF                                 /*VARCHAR2(50)*/
     , ORIG_SYS_SHIPMENT_REF                             /*VARCHAR2(50)*/
     , ORIG_SYS_DISCOUNT_REF                             /*VARCHAR2(50)*/
     , CHANGE_SEQUENCE                                   /*VARCHAR2(50)*/
     , CHANGE_REQUEST_CODE                               /*VARCHAR2(30)*/
     , ORG_ID                                            /*NUMBER(22)*/
     , DISCOUNT_ID                                       /*NUMBER(22)*/
     , DISCOUNT_LINE_ID                                  /*NUMBER(22)*/
     , DISCOUNT_NAME                                     /*VARCHAR2(240)*/
     , PERCENT                                           /*NUMBER(22)*/
     , AUTOMATIC_FLAG                                    /*VARCHAR2(1)*/
     , CONTEXT                                           /*VARCHAR2(30)*/
     , ATTRIBUTE1                                        /*VARCHAR2(240)*/
     , ATTRIBUTE2                                        /*VARCHAR2(240)*/
     , ATTRIBUTE3                                        /*VARCHAR2(240)*/
     , ATTRIBUTE4                                        /*VARCHAR2(240)*/
     , ATTRIBUTE5                                        /*VARCHAR2(240)*/
     , ATTRIBUTE6                                        /*VARCHAR2(240)*/
     , ATTRIBUTE7                                        /*VARCHAR2(240)*/
     , ATTRIBUTE8                                        /*VARCHAR2(240)*/
     , ATTRIBUTE9                                        /*VARCHAR2(240)*/
     , ATTRIBUTE10                                       /*VARCHAR2(240)*/
     , ATTRIBUTE11                                       /*VARCHAR2(240)*/
     , ATTRIBUTE12                                       /*VARCHAR2(240)*/
     , ATTRIBUTE13                                       /*VARCHAR2(240)*/
     , ATTRIBUTE14                                       /*VARCHAR2(240)*/
     , ATTRIBUTE15                                       /*VARCHAR2(240)*/
     , CREATION_DATE                                     /*DATE(7)*/
     , CREATED_BY                                        /*NUMBER(22)*/
     , LAST_UPDATE_DATE                                  /*DATE(7)*/
     , LAST_UPDATED_BY                                   /*NUMBER(22)*/
     , LAST_UPDATE_LOGIN                                 /*NUMBER(22)*/
     , PROGRAM_APPLICATION_ID                            /*NUMBER(22)*/
     , SOLD_TO_ORG_ID                                    /*NUMBER(22)*/
     )
     SELECT
       ''                                                /*NULL*/
     , ''                                                /*NULL*/
     , ''                                                /*NULL*/
     , 'INSERT'                                          /*NULL Operation*/
     , ''                                                /*NULL*/
     , ''                                                /*NULL*/
     , ''                                                /*NULL*/
     , LIST_HEADER_ID                                    /*LIST_HEADER_ID*/
     , ''                                                /*LIST_NAME NULL*/
     , LIST_LINE_ID                                      /*NULL*/
     , LIST_LINE_TYPE_CODE                               /*NULL*/
     , CHARGE_TYPE_CODE                                  /*NULL*/
     , LIST_LINE_NO                                      /*VARCHAR2(30)*/
     , MODIFIER_MECHANISM_TYPE_CODE                      /*NULL*/
     , MODIFIED_FROM                                     /*NULL*/
     , MODIFIED_TO                                       /*NULL*/
     , UPDATED_FLAG                                      /*NULL*/
     , UPDATE_ALLOWED                                    /*NULL*/
     , APPLIED_FLAG                                      /*NULL*/
     , CHANGE_REASON_CODE                                /*NULL*/
     , CHANGE_REASON_TEXT                                /*NULL*/
     , OPERAND                                           /*NULL*/
     , ARITHMETIC_OPERATOR                               /*NULL*/
     , ADJUSTED_AMOUNT                                   /*NULL*/
     , PRICING_PHASE_ID                                  /*NULL*/
     , order_source_id_v               /*NULL order_source_id*/
     , to_char(order_number_v)         /*NULL orig_sys_document_ref*/
     , ''                              /*NULL orig_sys_line_ref*/
     , ''                              /*NULL orig_sys_shipment_ref*/
     , '1'                             /*NULL orig_sys_discount_ref*/
     , CHANGE_SEQUENCE                                   /*NULL*/
     , CHANGE_REASON_CODE              /*NULL change_request_code*/
     , ''                              /*NULL*/
     , ''                              /*NULL DISCOUNT_ID*/
     , ''                              /*NULL DISCOUNT_LINE_ID*/
     , ''                                                /*NULL*/
     , PERCENT                                           /*NULL*/
     , AUTOMATIC_FLAG                                    /*NOT NULL*/
     , CONTEXT                                           /*NULL*/
     , ATTRIBUTE1                                        /*NULL*/
     , ATTRIBUTE2                                        /*NULL*/
     , ATTRIBUTE3                                        /*NULL*/
     , ATTRIBUTE4                                        /*NULL*/
     , ATTRIBUTE5                                        /*NULL*/
     , ATTRIBUTE6                                        /*NULL*/
     , ATTRIBUTE7                                        /*NULL*/
     , ATTRIBUTE8                                        /*NULL*/
     , ATTRIBUTE9                                        /*NULL*/
     , ATTRIBUTE10                                       /*NULL*/
     , ATTRIBUTE11                                       /*NULL*/
     , ATTRIBUTE12                                       /*NULL*/
     , ATTRIBUTE13                                       /*NULL*/
     , ATTRIBUTE14                                       /*NULL*/
     , ATTRIBUTE15                                       /*NULL*/
     , sysdate                                           /*NOT NULL*/
     , -1                                                /*NOT NULL*/
     , sysdate                                           /*NOT NULL*/
     , -1                                                /*NOT NULL*/
     , 0                                                 /*NULL*/
     , ''                                                /*NULL*/
     , l_sold_to_org_id                                  /*NULL*/
     from  oe_price_adjustments
     where header_id = old_header_id_v
     and   line_id is null
     and applied_Flag = 'Y';

     IF SQL%ROWCOUNT > 0 THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'OEXPIFPB: AFTER SUCCESSFUL INSERT TO OE_PRICE_ADJS_IFACE_ALL FOR HEADER' ) ;
        END IF;
     ELSE
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'OEXPIFPB: AFTER UN-SUCCESSFUL INSERT TO OE_PRICE_ADJS_IFACE_ALL FOR HEADER' ) ;
        END IF;
     END IF;

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'OEXPIFPB: BEFORE INSERT TO OE_PRICE_ADJS_IFACE_ALL FOR LINE' ) ;
     END IF;


    /* Line Level Payments */

   Insert into oe_payments_interface
   (
     ORDER_SOURCE_ID,
     change_sequence,
     PAYMENT_TRX_ID,
     CREATION_DATE,
     CREATED_BY,
     LAST_UPDATE_DATE,
     LAST_UPDATED_BY,
     LAST_UPDATE_LOGIN,
     OPERATION_CODE,
     REQUEST_ID,
     PROGRAM_APPLICATION_ID,
     PROGRAM_ID,
     PROGRAM_UPDATE_DATE,
     CONTEXT,
     ATTRIBUTE1,
     ATTRIBUTE2,
     ATTRIBUTE3,
     ATTRIBUTE4,
     ATTRIBUTE5,
     ATTRIBUTE6,
     ATTRIBUTE7,
     ATTRIBUTE8,
     ATTRIBUTE9,
     ATTRIBUTE10,
     ATTRIBUTE11,
     ATTRIBUTE12,
     ATTRIBUTE13,
     ATTRIBUTE14,
     ATTRIBUTE15,
     PAYMENT_TYPE_CODE,
     CREDIT_CARD_CODE,
     CREDIT_CARD_NUMBER,
     CREDIT_CARD_HOLDER_NAME,
     CREDIT_CARD_EXPIRATION_DATE,
     PREPAID_AMOUNT,
     PAYMENT_SET_ID,
     RECEIPT_METHOD_ID,
     PAYMENT_COLLECTION_EVENT,
     CREDIT_CARD_APPROVAL_CODE,
     CREDIT_CARD_APPROVAL_DATE,
     CHECK_NUMBER,
     PAYMENT_AMOUNT,
     PAYMENT_NUMBER,
     ORIG_SYS_PAYMENT_REF,
     ORIG_SYS_DOCUMENT_REF,
     ORIG_SYS_LINE_REF,
     ORIG_SYS_SHIPMENT_REF,
     ORG_ID
     )Select
      order_source_id_v,
      '',
      PAYMENT_TRX_ID
      ,sysdate
      ,-1
      ,sysdate
      ,-1
      ,0
      ,'INSERT'
      ,''
      ,''
      ,''
      ,''
      ,CONTEXT
      ,ATTRIBUTE1
      ,ATTRIBUTE2
      ,ATTRIBUTE3
      ,ATTRIBUTE4
      ,ATTRIBUTE5
      ,ATTRIBUTE6
      ,ATTRIBUTE7
      ,ATTRIBUTE8
      ,ATTRIBUTE9
      ,ATTRIBUTE10
      ,ATTRIBUTE11
      ,ATTRIBUTE12
      ,ATTRIBUTE13
      ,ATTRIBUTE14
      ,ATTRIBUTE15
      ,PAYMENT_TYPE_CODE
      ,CREDIT_CARD_CODE
      ,CREDIT_CARD_NUMBER
      ,CREDIT_CARD_HOLDER_NAME
      ,CREDIT_CARD_EXPIRATION_DATE
      ,PREPAID_AMOUNT
      ,PAYMENT_SET_ID
      ,RECEIPT_METHOD_ID
      ,PAYMENT_COLLECTION_EVENT
      ,CREDIT_CARD_APPROVAL_CODE
      ,CREDIT_CARD_APPROVAL_DATE
      ,CHECK_NUMBER
      ,PAYMENT_AMOUNT
      ,PAYMENT_NUMBER
      ,rtrim(to_char(line_id)||'-'||to_char(payment_number))
      ,to_char(order_number_v)
      ,get_line_ref_from_line_id(line_id)
      ,''
      ,''
      FROM OE_PAYMENTS
      where header_id = old_header_id_v
        and   line_id is not null;

      IF SQL%ROWCOUNT > 0 THEN
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OEXPIFPB: AFTER SUCCESSFUL INSERT TO OE_PAYMENTS_INTERFACE FOR LINE' ) ;
       END IF;
     ELSE
        IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPIFPB: AFTER UN-SUCCESSFUL INSERT TO OE_PAYMENTS_INTERFACE FOR LINE' ) ;
        END IF;
     END IF;

 /* Header Payments */

   Insert into oe_payments_interface
   (
     ORDER_SOURCE_ID,
     change_sequence,
     PAYMENT_TRX_ID,
     CREATION_DATE,
     CREATED_BY,
     LAST_UPDATE_DATE,
     LAST_UPDATED_BY,
     LAST_UPDATE_LOGIN,
     OPERATION_CODE,
     REQUEST_ID,
     PROGRAM_APPLICATION_ID,
     PROGRAM_ID,
     PROGRAM_UPDATE_DATE,
     CONTEXT,
     ATTRIBUTE1,
     ATTRIBUTE2,
     ATTRIBUTE3,
     ATTRIBUTE4,
     ATTRIBUTE5,
     ATTRIBUTE6,
     ATTRIBUTE7,
     ATTRIBUTE8,
     ATTRIBUTE9,
     ATTRIBUTE10,
     ATTRIBUTE11,
     ATTRIBUTE12,
     ATTRIBUTE13,
     ATTRIBUTE14,
     ATTRIBUTE15,
     PAYMENT_TYPE_CODE,
     CREDIT_CARD_CODE,
     CREDIT_CARD_NUMBER,
     CREDIT_CARD_HOLDER_NAME,
     CREDIT_CARD_EXPIRATION_DATE,
     PREPAID_AMOUNT,
     PAYMENT_SET_ID,
     RECEIPT_METHOD_ID,
     PAYMENT_COLLECTION_EVENT,
     CREDIT_CARD_APPROVAL_CODE,
     CREDIT_CARD_APPROVAL_DATE,
     CHECK_NUMBER,
     PAYMENT_AMOUNT,
     PAYMENT_NUMBER,
     ORIG_SYS_PAYMENT_REF,
     ORIG_SYS_DOCUMENT_REF,
     ORIG_SYS_LINE_REF,
     ORIG_SYS_SHIPMENT_REF,
     ORG_ID
     )Select
     order_source_id_v,
     '',
     PAYMENT_TRX_ID
     ,sysdate
     ,-1
     ,sysdate
     ,-1
     ,0
     ,'INSERT'
     ,''
     ,''
     ,''
     ,''
     ,CONTEXT
     ,ATTRIBUTE1
     ,ATTRIBUTE2
     ,ATTRIBUTE3
     ,ATTRIBUTE4
     ,ATTRIBUTE5
     ,ATTRIBUTE6
     ,ATTRIBUTE7
     ,ATTRIBUTE8
     ,ATTRIBUTE9
     ,ATTRIBUTE10
     ,ATTRIBUTE11
     ,ATTRIBUTE12
     ,ATTRIBUTE13
     ,ATTRIBUTE14
     ,ATTRIBUTE15
     ,PAYMENT_TYPE_CODE
     ,CREDIT_CARD_CODE
     ,CREDIT_CARD_NUMBER
     ,CREDIT_CARD_HOLDER_NAME
     ,CREDIT_CARD_EXPIRATION_DATE
     ,PREPAID_AMOUNT
     ,PAYMENT_SET_ID
     ,RECEIPT_METHOD_ID
     ,PAYMENT_COLLECTION_EVENT
     ,CREDIT_CARD_APPROVAL_CODE
     ,CREDIT_CARD_APPROVAL_DATE
     ,CHECK_NUMBER
     ,PAYMENT_AMOUNT
     ,PAYMENT_NUMBER
     ,rtrim('-'||to_char(PAYMENT_NUMBER))
     ,to_char(order_number_v)
     ,get_line_ref_from_line_id(line_id)
     ,''
     ,''
     FROM OE_PAYMENTS
     where header_id = old_header_id_v
     and   line_id is null;

      IF SQL%ROWCOUNT > 0 THEN
        IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'OEXPIFPB: AFTER SUCCESSFUL INSERT TO OE_PAYMENTS_INTERFACE FOR HEADERS' ) ;
       END IF;
     ELSE
        IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPIFPB: AFTER UN-SUCCESSFUL INSERT TO OE_PAYMENTS_INTERFACE FOR HEADERS' ) ;
      END IF;
     END IF;

/* Line Level Price Adjustment */
     INSERT INTO OE_PRICE_ADJS_IFACE_ALL (
       PROGRAM_ID                                 /*NUMBER(22)*/
     , PROGRAM_UPDATE_DATE                        /*DATE(7)*/
     , REQUEST_ID                                 /*NUMBER(22)*/
     , OPERATION_CODE                             /*VARCHAR2(30)*/
     , ERROR_FLAG                                 /*VARCHAR2(1)*/
     , STATUS_FLAG                                /*VARCHAR2(1)*/
     , INTERFACE_STATUS                           /*VARCHAR2(1000)*/
     , LIST_HEADER_ID                             /*NUMBER(22)*/
     , LIST_NAME                                  /*VARCHAR2(240)*/
     , LIST_LINE_ID                               /*NUMBER(22)*/
     , LIST_LINE_TYPE_CODE                        /*VARCHAR2(30)*/
     , CHARGE_TYPE_CODE                           /*VARCHAR2(30)*/
     , LIST_LINE_NUMBER                              /*VARCHAR2(30)*/
     , MODIFIER_MECHANISM_TYPE_CODE               /*VARCHAR2(30)*/
     , MODIFIED_FROM                              /*NUMBER(22)*/
     , MODIFIED_TO                                /*NUMBER(22)*/
     , UPDATED_FLAG                               /*VARCHAR2(1)*/
     , UPDATE_ALLOWED                             /*VARCHAR2(1)*/
     , APPLIED_FLAG                               /*VARCHAR2(1)*/
     , CHANGE_REASON_CODE                         /*VARCHAR2(30)*/
     , CHANGE_REASON_TEXT                         /*VARCHAR2(2000)*/
     , OPERAND                                    /*NUMBER(22)*/
     , ARITHMETIC_OPERATOR                        /*VARCHAR2(30)*/
     , ADJUSTED_AMOUNT                            /*NUMBER(22)*/
     , PRICING_PHASE_ID                           /*NUMBER(22)*/
     , ORDER_SOURCE_ID                            /*NUMBER(22)*/
     , ORIG_SYS_DOCUMENT_REF                      /*VARCHAR2(50)*/
     , ORIG_SYS_LINE_REF                          /*VARCHAR2(50)*/
     , ORIG_SYS_SHIPMENT_REF                      /*VARCHAR2(50)*/
     , ORIG_SYS_DISCOUNT_REF                      /*VARCHAR2(50)*/
     , CHANGE_SEQUENCE                            /*VARCHAR2(50)*/
     , CHANGE_REQUEST_CODE                        /*VARCHAR2(30)*/
     , ORG_ID                                     /*NUMBER(22)*/
     , DISCOUNT_ID                                /*NUMBER(22)*/
     , DISCOUNT_LINE_ID                           /*NUMBER(22)*/
     , DISCOUNT_NAME                              /*VARCHAR2(240)*/
     , PERCENT                                    /*NUMBER(22)*/
     , AUTOMATIC_FLAG                             /*VARCHAR2(1)*/
     , CONTEXT                                    /*VARCHAR2(30)*/
     , ATTRIBUTE1                                 /*VARCHAR2(240)*/
     , ATTRIBUTE2                                 /*VARCHAR2(240)*/
     , ATTRIBUTE3                                 /*VARCHAR2(240)*/
     , ATTRIBUTE4                                 /*VARCHAR2(240)*/
     , ATTRIBUTE5                                 /*VARCHAR2(240)*/
     , ATTRIBUTE6                                 /*VARCHAR2(240)*/
     , ATTRIBUTE7                                 /*VARCHAR2(240)*/
     , ATTRIBUTE8                                 /*VARCHAR2(240)*/
     , ATTRIBUTE9                                 /*VARCHAR2(240)*/
     , ATTRIBUTE10                                /*VARCHAR2(240)*/
     , ATTRIBUTE11                                /*VARCHAR2(240)*/
     , ATTRIBUTE12                                /*VARCHAR2(240)*/
     , ATTRIBUTE13                                /*VARCHAR2(240)*/
     , ATTRIBUTE14                                /*VARCHAR2(240)*/
     , ATTRIBUTE15                                /*VARCHAR2(240)*/
     , CREATION_DATE                              /*DATE(7)*/
     , CREATED_BY                                 /*NUMBER(22)*/
     , LAST_UPDATE_DATE                           /*DATE(7)*/
     , LAST_UPDATED_BY                            /*NUMBER(22)*/
     , LAST_UPDATE_LOGIN                          /*NUMBER(22)*/
     , PROGRAM_APPLICATION_ID                     /*NUMBER(22)*/
     , SOLD_TO_ORG_ID                             /*NUMBER(22)*/
     )
     SELECT
       ''                                         /*NULL*/
     , ''                                         /*NULL*/
     , ''                                         /*NULL*/
     , 'INSERT'                                   /*NULL Operation*/
     , ''                                         /*NULL*/
     , ''                                         /*NULL*/
     , ''                                         /*NULL*/
     , LIST_HEADER_ID                             /*NULL*/
     , ''                                         /*LIST_NAME NULL*/
     , LIST_LINE_ID                               /*NULL*/
     , LIST_LINE_TYPE_CODE                        /*NULL*/
     , CHARGE_TYPE_CODE                           /*VARCHAR2(30)*/
     , LIST_LINE_NO                                  /*VARCHAR2(30)*/
     , MODIFIER_MECHANISM_TYPE_CODE               /*NULL*/
     , MODIFIED_FROM                              /*NULL*/
     , MODIFIED_TO                                /*NULL*/
     , UPDATED_FLAG                               /*NULL*/
     , UPDATE_ALLOWED                             /*NULL*/
     , APPLIED_FLAG                               /*NULL*/
     , CHANGE_REASON_CODE                         /*NULL*/
     , CHANGE_REASON_TEXT                         /*NULL*/
     , OPERAND                                    /*NULL*/
     , ARITHMETIC_OPERATOR                        /*NULL*/
     , ADJUSTED_AMOUNT                            /*NULL*/
     , PRICING_PHASE_ID                           /*NULL*/
     , order_source_id_v                          /*NULL order_source_id*/
     , to_char(order_number_v)              /*NULL orig_sys_document_ref*/
     , get_line_ref_from_line_id(line_id)   /*NULL orig_sys_line_ref*/
     , ''                                   /*NULL orig_sys_shipment_ref*/
     , '1'                                  /*NULL orig_sys_discount_ref*/
     , CHANGE_SEQUENCE                            /*NULL*/
     , CHANGE_REASON_CODE                         /*NULL change_request_code*/
     , ''                                         /*NULL*/
     , DISCOUNT_ID                                /*NULL*/
     , DISCOUNT_LINE_ID                           /*NULL*/
     , ''                                         /*NULL*/
     , PERCENT                                    /*NULL*/
     , AUTOMATIC_FLAG                             /*NOT NULL*/
     , CONTEXT                                    /*NULL*/
     , ATTRIBUTE1                                 /*NULL*/
     , ATTRIBUTE2                                 /*NULL*/
     , ATTRIBUTE3                                 /*NULL*/
     , ATTRIBUTE4                                 /*NULL*/
     , ATTRIBUTE5                                 /*NULL*/
     , ATTRIBUTE6                                 /*NULL*/
     , ATTRIBUTE7                                 /*NULL*/
     , ATTRIBUTE8                                 /*NULL*/
     , ATTRIBUTE9                                 /*NULL*/
     , ATTRIBUTE10                                /*NULL*/
     , ATTRIBUTE11                                /*NULL*/
     , ATTRIBUTE12                                /*NULL*/
     , ATTRIBUTE13                                /*NULL*/
     , ATTRIBUTE14                                /*NULL*/
     , ATTRIBUTE15                                /*NULL*/
     , sysdate                                    /*NOT NULL*/
     , -1                                         /*NOT NULL*/
     , sysdate                                    /*NOT NULL*/
     , -1                                         /*NOT NULL*/
     , 0                                          /*NULL*/
     , ''                                         /*NULL*/
     , l_sold_to_org_id                           /*NULL*/
     from  oe_price_adjustments
     where header_id = old_header_id_v
     and   line_id is not null
     and applied_Flag = 'Y';

     IF SQL%ROWCOUNT > 0 THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'OEXPIFPB: AFTER SUCCESSFUL INSERT TO OE_PRICE_ADJS_INTERFACE FOR LINE' ) ;
        END IF;
     ELSE
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'OEXPIFPB: AFTER UN-SUCCESSFUL INSERT TO OE_PRICE_ADJS_INTERFACE FOR LINE' ) ;
        END IF;
     END IF;

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'OEXPIFPB: BEFORE INSERT TO OE_CREDITS_IFACE_ALL' ) ;
     END IF;
     /* Header Level Sales Credits */
     INSERT INTO OE_CREDITS_IFACE_ALL (
       SALESREP                      /*VARCHAR2(30)*/
     , SALES_CREDIT_TYPE_ID          /*NUMBER(22)*/
     , SALES_CREDIT_TYPE             /*VARCHAR2(30)*/
     , QUOTA_FLAG                    /*VARCHAR2(1)*/
     , PERCENT                       /*NUMBER(22)*/
     , CONTEXT                       /*VARCHAR2(30)*/
     , ATTRIBUTE1                    /*VARCHAR2(240)*/
     , ATTRIBUTE2                    /*VARCHAR2(240)*/
     , ATTRIBUTE3                    /*VARCHAR2(240)*/
     , ATTRIBUTE4                    /*VARCHAR2(240)*/
     , ATTRIBUTE5                    /*VARCHAR2(240)*/
     , ATTRIBUTE6                    /*VARCHAR2(240)*/
     , ATTRIBUTE7                    /*VARCHAR2(240)*/
     , ATTRIBUTE8                    /*VARCHAR2(240)*/
     , ATTRIBUTE9                    /*VARCHAR2(240)*/
     , ATTRIBUTE10                   /*VARCHAR2(240)*/
     , ATTRIBUTE11                   /*VARCHAR2(240)*/
     , ATTRIBUTE12                   /*VARCHAR2(240)*/
     , ATTRIBUTE13                   /*VARCHAR2(240)*/
     , ATTRIBUTE14                   /*VARCHAR2(240)*/
     , ATTRIBUTE15                   /*VARCHAR2(240)*/
     , CREATED_BY                    /*NUMBER(22)*/
     , CREATION_DATE                 /*DATE(7)*/
     , LAST_UPDATED_BY               /*NUMBER(22)*/
     , LAST_UPDATE_DATE              /*DATE(7)*/
     , LAST_UPDATE_LOGIN             /*NUMBER(22)*/
     , PROGRAM_APPLICATION_ID        /*NUMBER(22)*/
     , PROGRAM_ID                    /*NUMBER(22)*/
     , PROGRAM_UPDATE_DATE           /*DATE(7)*/
     , REQUEST_ID                    /*NUMBER(22)*/
     , OPERATION_CODE                /*VARCHAR2(30)*/
     , ERROR_FLAG                    /*VARCHAR2(1)*/
     , STATUS_FLAG                   /*VARCHAR2(1)*/
     , INTERFACE_STATUS              /*VARCHAR2(1000)*/
     , ORDER_SOURCE_ID               /*NUMBER(22)*/
     , ORIG_SYS_DOCUMENT_REF         /*VARCHAR2(50)*/
     , ORIG_SYS_LINE_REF             /*VARCHAR2(50)*/
     , ORIG_SYS_SHIPMENT_REF         /*VARCHAR2(50)*/
     , ORIG_SYS_CREDIT_REF           /*VARCHAR2(50)*/
     , CHANGE_SEQUENCE               /*VARCHAR2(50)*/
     , CHANGE_REQUEST_CODE           /*VARCHAR2(30)*/
     , ORG_ID                        /*NUMBER(22)*/
     , SALESREP_ID                   /*NUMBER(22)*/
     , SOLD_TO_ORG_ID                /*NUMBER(22)*/
     )
     SELECT
       ''                           /*SALESREP NULL*/
     , SALES_CREDIT_TYPE_ID         /*SALES_CREDIT_TYPE_ID NULL*/
     , ''                           /*SALES_CREDIT_TYPE NULL*/
     , ''                           /*QUOTA_FLAG NULL*/
     , PERCENT                      /*PERCENT NULL*/
     , CONTEXT                      /*CONTEXT NULL*/
     , ATTRIBUTE1                   /*ATTRIBUTE1 NULL*/
     , ATTRIBUTE2                   /*ATTRIBUTE2 NULL*/
     , ATTRIBUTE3                   /*ATTRIBUTE3 NULL*/
     , ATTRIBUTE4                   /*ATTRIBUTE4 NULL*/
     , ATTRIBUTE5                   /*ATTRIBUTE5 NULL*/
     , ATTRIBUTE6                   /*ATTRIBUTE6 NULL*/
     , ATTRIBUTE7                   /*ATTRIBUTE7 NULL*/
     , ATTRIBUTE8                   /*ATTRIBUTE8 NULL*/
     , ATTRIBUTE9                   /*ATTRIBUTE9 NULL*/
     , ATTRIBUTE10                  /*ATTRIBUTE10 NULL*/
     , ATTRIBUTE11                  /*ATTRIBUTE11 NULL*/
     , ATTRIBUTE12                  /*ATTRIBUTE12 NULL*/
     , ATTRIBUTE13                  /*ATTRIBUTE13 NULL*/
     , ATTRIBUTE14                  /*ATTRIBUTE14 NULL*/
     , ATTRIBUTE15                  /*ATTRIBUTE15 NULL*/
     , -1                           /*CREATED_BY NOT NULL*/
     , sysdate                      /*CREATION_DATE NOT NULL*/
     , -1                           /*LAST_UPDATED_BY NOT NULL*/
     , sysdate                      /*LAST_UPDATE_DATE NOT NULL*/
     , 0                            /*LAST_UPDATE_LOGIN NULL*/
     , ''                           /*PROGRAM_APPLICATION_ NULL*/
     , ''                           /*PROGRAM_ID NULL*/
     , ''                           /*PROGRAM_UPDATE_DATE NULL*/
     , ''                           /*REQUEST_ID NULL*/
     , 'INSERT'                     /*OPERATION_CODE NULL*/
     , ''                           /*ERROR_FLAG NULL*/
     , ''                           /*STATUS_FLAG NULL*/
     , ''                           /*INTERFACE_STATUS NULL*/
     , ORDER_SOURCE_ID_V            /*ORDER_SOURCE_ID NULL*/
     , TO_CHAR(ORDER_NUMBER_V)      /*ORIG_SYS_DOCUMENT_RE NULL*/
     , ''                           /*ORIG_SYS_LINE_REF NULL*/
     , ''                           /*ORIG_SYS_SHIPMENT_RE NULL*/
     , SALES_CREDIT_ID              /*ORIG_SYS_CREDIT_REF NULL*/
     , ''                           /*CHANGE_SEQUENCE NULL*/
     , ''                           /*CHANGE_REQUEST_CODE NULL*/
     , ''                           /*ORG_ID NULL*/
     , SALESREP_ID                  /*SALESREP_ID NULL*/
     , l_sold_to_org_id             /*SOLD_TO_ORG_ID NULL*/
     from  oe_sales_credits
     where header_id = old_header_id_v
     and   line_id is null;

     IF SQL%ROWCOUNT > 0 THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'OEXPIFPB: AFTER SUCCESSFUL INSERT TO OE_CREDITS_IFACE_ALL FOR HEADER' ) ;
        END IF;
     ELSE
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'OEXPIFPB: AFTER UN-SUCCESSFUL INSERT TO OE_CREDITS_IFACE_ALL FOR HEADER' ) ;
        END IF;
     END IF;

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'OEXPIFPB: BEFORE INSERT TO OE_CREDITS_IFACE_ALL' ) ;
     END IF;

     /* Line Level Sales Credits */
     INSERT INTO OE_CREDITS_IFACE_ALL (
       SALESREP                      /*VARCHAR2(30)*/
     , SALES_CREDIT_TYPE_ID          /*NUMBER(22)*/
     , SALES_CREDIT_TYPE             /*VARCHAR2(30)*/
     , QUOTA_FLAG                    /*VARCHAR2(1)*/
     , PERCENT                       /*NUMBER(22)*/
     , CONTEXT                       /*VARCHAR2(30)*/
     , ATTRIBUTE1                    /*VARCHAR2(240)*/
     , ATTRIBUTE2                    /*VARCHAR2(240)*/
     , ATTRIBUTE3                    /*VARCHAR2(240)*/
     , ATTRIBUTE4                    /*VARCHAR2(240)*/
     , ATTRIBUTE5                    /*VARCHAR2(240)*/
     , ATTRIBUTE6                    /*VARCHAR2(240)*/
     , ATTRIBUTE7                    /*VARCHAR2(240)*/
     , ATTRIBUTE8                    /*VARCHAR2(240)*/
     , ATTRIBUTE9                    /*VARCHAR2(240)*/
     , ATTRIBUTE10                   /*VARCHAR2(240)*/
     , ATTRIBUTE11                   /*VARCHAR2(240)*/
     , ATTRIBUTE12                   /*VARCHAR2(240)*/
     , ATTRIBUTE13                   /*VARCHAR2(240)*/
     , ATTRIBUTE14                   /*VARCHAR2(240)*/
     , ATTRIBUTE15                   /*VARCHAR2(240)*/
     , CREATED_BY                    /*NUMBER(22)*/
     , CREATION_DATE                 /*DATE(7)*/
     , LAST_UPDATED_BY               /*NUMBER(22)*/
     , LAST_UPDATE_DATE              /*DATE(7)*/
     , LAST_UPDATE_LOGIN             /*NUMBER(22)*/
     , PROGRAM_APPLICATION_ID        /*NUMBER(22)*/
     , PROGRAM_ID                    /*NUMBER(22)*/
     , PROGRAM_UPDATE_DATE           /*DATE(7)*/
     , REQUEST_ID                    /*NUMBER(22)*/
     , OPERATION_CODE                /*VARCHAR2(30)*/
     , ERROR_FLAG                    /*VARCHAR2(1)*/
     , STATUS_FLAG                   /*VARCHAR2(1)*/
     , INTERFACE_STATUS              /*VARCHAR2(1000)*/
     , ORDER_SOURCE_ID               /*NUMBER(22)*/
     , ORIG_SYS_DOCUMENT_REF         /*VARCHAR2(50)*/
     , ORIG_SYS_LINE_REF             /*VARCHAR2(50)*/
     , ORIG_SYS_SHIPMENT_REF         /*VARCHAR2(50)*/
     , ORIG_SYS_CREDIT_REF           /*VARCHAR2(50)*/
     , CHANGE_SEQUENCE               /*VARCHAR2(50)*/
     , CHANGE_REQUEST_CODE           /*VARCHAR2(30)*/
     , ORG_ID                        /*NUMBER(22)*/
     , SALESREP_ID                   /*NUMBER(22)*/
     , SOLD_TO_ORG_ID                /*NUMBER(22)*/
     )
     SELECT
       ''                           /*SALESREP NULL*/
     , SALES_CREDIT_TYPE_ID         /*SALES_CREDIT_TYPE_ID NULL*/
     , ''                           /*SALES_CREDIT_TYPE NULL*/
     , ''                           /*QUOTA_FLAG NULL*/
     , PERCENT                      /*PERCENT NULL*/
     , CONTEXT                      /*CONTEXT NULL*/
     , ATTRIBUTE1                   /*ATTRIBUTE1 NULL*/
     , ATTRIBUTE2                   /*ATTRIBUTE2 NULL*/
     , ATTRIBUTE3                   /*ATTRIBUTE3 NULL*/
     , ATTRIBUTE4                   /*ATTRIBUTE4 NULL*/
     , ATTRIBUTE5                   /*ATTRIBUTE5 NULL*/
     , ATTRIBUTE6                   /*ATTRIBUTE6 NULL*/
     , ATTRIBUTE7                   /*ATTRIBUTE7 NULL*/
     , ATTRIBUTE8                   /*ATTRIBUTE8 NULL*/
     , ATTRIBUTE9                   /*ATTRIBUTE9 NULL*/
     , ATTRIBUTE10                  /*ATTRIBUTE10 NULL*/
     , ATTRIBUTE11                  /*ATTRIBUTE11 NULL*/
     , ATTRIBUTE12                  /*ATTRIBUTE12 NULL*/
     , ATTRIBUTE13                  /*ATTRIBUTE13 NULL*/
     , ATTRIBUTE14                  /*ATTRIBUTE14 NULL*/
     , ATTRIBUTE15                  /*ATTRIBUTE15 NULL*/
     , -1                           /*CREATED_BY NOT NULL*/
     , sysdate                      /*CREATION_DATE NOT NULL*/
     , -1                           /*LAST_UPDATED_BY NOT NULL*/
     , sysdate                      /*LAST_UPDATE_DATE NOT NULL*/
     , 0                            /*LAST_UPDATE_LOGIN NULL*/
     , ''                           /*PROGRAM_APPLICATION_ NULL*/
     , ''                           /*PROGRAM_ID NULL*/
     , ''                           /*PROGRAM_UPDATE_DATE NULL*/
     , ''                           /*REQUEST_ID NULL*/
     , 'INSERT'                     /*OPERATION_CODE NULL*/
     , ''                           /*ERROR_FLAG NULL*/
     , ''                           /*STATUS_FLAG NULL*/
     , ''                           /*INTERFACE_STATUS NULL*/
     , ORDER_SOURCE_ID_V            /*ORDER_SOURCE_ID NULL*/
     , TO_CHAR(ORDER_NUMBER_V)      /*ORIG_SYS_DOCUMENT_RE NULL*/
     , get_line_ref_from_line_id(line_id) /*ORIG_SYS_LINE_REF NULL*/
     , ''                           /*ORIG_SYS_SHIPMENT_RE NULL*/
     , SALES_CREDIT_ID              /*ORIG_SYS_CREDIT_REF NULL*/
     , ''                           /*CHANGE_SEQUENCE NULL*/
     , ''                           /*CHANGE_REQUEST_CODE NULL*/
     , ''                           /*ORG_ID NULL*/
     , SALESREP_ID                  /*SALESREP_ID NULL*/
     , l_sold_to_org_id             /*SOLD_TO_ORG_ID NULL*/
     from  oe_sales_credits
     where header_id = old_header_id_v
     and   line_id is not null;

     IF SQL%ROWCOUNT > 0 THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'OEXPIFPB: AFTER SUCCESSFUL INSERT TO OE_CREDITS_IFACE_ALL FOR LINES' ) ;
        END IF;
     ELSE
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'OEXPIFPB: AFTER UN-SUCCESSFUL INSERT TO OE_CREDITS_IFACE_ALL FOR LINES' ) ;
        END IF;
     END IF;

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'OEXPIFPB: BEFORE INSERT TO OE_LOTSERIALS_IFACE_ALL' ) ;
     END IF;

     /* Line Level Lots Serial */
     INSERT INTO OE_LOTSERIALS_IFACE_ALL (
       ORIG_SYS_LINE_REF             /*VARCHAR2(50)*/
     , ORIG_SYS_SHIPMENT_REF         /*VARCHAR2(50)*/
     , ORIG_SYS_LOTSERIAL_REF        /*VARCHAR2(50)*/
     , CHANGE_SEQUENCE               /*VARCHAR2(50)*/
     , CHANGE_REQUEST_CODE           /*VARCHAR2(30)*/
     , ORG_ID                        /*NUMBER(22)*/
     , LOT_NUMBER                    /*NUMBER(80)*/ -- INVCONV
--     , SUBLOT_NUMBER                 /*VARCHAR2(30)*/ -- OPM 2380194   INVCONV REMOVE
     , FROM_SERIAL_NUMBER            /*VARCHAR2(30)*/
     , TO_SERIAL_NUMBER              /*VARCHAR2(30)*/
     , QUANTITY                      /*NUMBER(22)*/
     , QUANTITY2                      /*NUMBER(22)*/ -- OPM 2380194
     , CONTEXT                       /*VARCHAR2(30)*/
     , ATTRIBUTE1                    /*VARCHAR2(240)*/
     , ATTRIBUTE2                    /*VARCHAR2(240)*/
     , ATTRIBUTE3                    /*VARCHAR2(240)*/
     , ATTRIBUTE4                    /*VARCHAR2(240)*/
     , ATTRIBUTE5                    /*VARCHAR2(240)*/
     , ATTRIBUTE6                    /*VARCHAR2(240)*/
     , ATTRIBUTE7                    /*VARCHAR2(240)*/
     , ATTRIBUTE8                    /*VARCHAR2(240)*/
     , ATTRIBUTE9                    /*VARCHAR2(240)*/
     , ATTRIBUTE10                   /*VARCHAR2(240)*/
     , ATTRIBUTE11                   /*VARCHAR2(240)*/
     , ATTRIBUTE12                   /*VARCHAR2(240)*/
     , ATTRIBUTE13                   /*VARCHAR2(240)*/
     , ATTRIBUTE14                   /*VARCHAR2(240)*/
     , ATTRIBUTE15                   /*VARCHAR2(240)*/
     , CREATED_BY                    /*NUMBER(22)*/
     , CREATION_DATE                 /*DATE(7)*/
     , LAST_UPDATED_BY               /*NUMBER(22)*/
     , LAST_UPDATE_DATE              /*DATE(7)*/
     , LAST_UPDATE_LOGIN             /*NUMBER(22)*/
     , PROGRAM_APPLICATION_ID        /*NUMBER(22)*/
     , PROGRAM_ID                    /*NUMBER(22)*/
     , PROGRAM_UPDATE_DATE           /*DATE(7)*/
     , REQUEST_ID                    /*NUMBER(22)*/
     , OPERATION_CODE                /*VARCHAR2(30)*/
     , ERROR_FLAG                    /*VARCHAR2(1)*/
     , STATUS_FLAG                   /*VARCHAR2(1)*/
     , INTERFACE_STATUS              /*VARCHAR2(1000)*/
     , ORDER_SOURCE_ID               /*NUMBER(22)*/
     , ORIG_SYS_DOCUMENT_REF         /*VARCHAR2(50)*/
     , SOLD_TO_ORG_ID                /*NUMBER(22)*/
     )
     Select
       get_line_ref_from_line_id(line_id)/*ORIG_SYS_LINE_REF NULL*/
     , ''                            /*ORIG_SYS_SHIPMENT_RE NULL*/
     , ''                            /*ORIG_SYS_LOTSERIAL_R NULL*/
     , ''                            /*CHANGE_SEQUENCE NULL*/
     , ''                            /*CHANGE_REQUEST_CODE NULL*/
     , ''                            /*ORG_ID NULL*/
     , LOT_NUMBER                    /*LOT_NUMBER NULL*/
--     , SUBLOT_NUMBER                 /*SUBLOT_NUMBER NULL*/ -- OPM 2380194  INVCONV REMOVE
     , FROM_SERIAL_NUMBER            /*FROM_SERIAL_NUMBER NULL*/
     , TO_SERIAL_NUMBER              /*TO_SERIAL_NUMBER NULL*/
     , QUANTITY                      /*QUANTITY NULL*/
     , QUANTITY2                     /*QUANTITY2 NULL*/  -- OPM 2380194
     , CONTEXT                       /*CONTEXT NULL*/
     , ATTRIBUTE1                    /*ATTRIBUTE1 NULL*/
     , ATTRIBUTE2                    /*ATTRIBUTE2 NULL*/
     , ATTRIBUTE3                    /*ATTRIBUTE3 NULL*/
     , ATTRIBUTE4                    /*ATTRIBUTE4 NULL*/
     , ATTRIBUTE5                    /*ATTRIBUTE5 NULL*/
     , ATTRIBUTE6                    /*ATTRIBUTE6 NULL*/
     , ATTRIBUTE7                    /*ATTRIBUTE7 NULL*/
     , ATTRIBUTE8                    /*ATTRIBUTE8 NULL*/
     , ATTRIBUTE9                    /*ATTRIBUTE9 NULL*/
     , ATTRIBUTE10                   /*ATTRIBUTE10 NULL*/
     , ATTRIBUTE11                   /*ATTRIBUTE11 NULL*/
     , ATTRIBUTE12                   /*ATTRIBUTE12 NULL*/
     , ATTRIBUTE13                   /*ATTRIBUTE13 NULL*/
     , ATTRIBUTE14                   /*ATTRIBUTE14 NULL*/
     , ATTRIBUTE15                   /*ATTRIBUTE15 NULL*/
     , -1                            /*CREATED_BY NOT NULL*/
     , sysdate                       /*CREATION_DATE NOT NULL*/
     , -1                            /*LAST_UPDATED_BY NOT NULL*/
     , sysdate                       /*LAST_UPDATE_DATE NOT NULL*/
     , 0                             /*LAST_UPDATE_LOGIN NULL*/
     , ''                            /*PROGRAM_APPLICATION_ NULL*/
     , ''                            /*PROGRAM_ID NULL*/
     , ''                            /*PROGRAM_UPDATE_DATE NULL*/
     , ''                            /*REQUEST_ID NULL*/
     , 'INSERT'                      /*OPERATION_CODE NULL*/
     , ''                            /*ERROR_FLAG NULL*/
     , ''                            /*STATUS_FLAG NULL*/
     , ''                            /*INTERFACE_STATUS NULL*/
     , ORDER_SOURCE_ID_V             /*ORDER_SOURCE_ID NULL*/
     , to_char(ORDER_NUMBER_V)       /*ORIG_SYS_DOCUMENT_RE NULL*/
     , l_sold_to_org_id              /*L_SOLD_TO_ORG_ID NULL*/
     From  oe_lot_serial_numbers
     where line_id in (select line_id from oe_order_lines
     			   where  header_id = old_header_id_v);

     IF SQL%ROWCOUNT > 0 THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'OEXPIFPB: AFTER SUCCESSFUL INSERT TO OE_LOTSERIALS_IFACE_ALL FOR LINES' ) ;
        END IF;
     ELSE
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'OEXPIFPB: AFTER UN-SUCCESSFUL INSERT TO OE_LOTSERIALS_IFACE_ALL FOR LINES' ) ;
        END IF;
     END IF;

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'OEXPIFPB: BEFORE UPDATE OE_LINES_IFACE_ALL' ) ;
     END IF;
     update oe_lines_iface_all
     set    line_id = ''
     where  orig_sys_document_ref = to_char(order_number_v);

     IF SQL%ROWCOUNT > 0 THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'OEXPIFPB: AFTER SUCCESSFUL UPDATE OF OE_LINES_IFACE_ALL' ) ;
        END IF;
     ELSE
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'OEXPIFPB: AFTER UN-SUCCESSFUL UPDATE OF OE_LINES_IFACE_ALL' ) ;
        END IF;
     END IF;

   END IF;

END POPULATE_INTERFACE;

FUNCTION GET_LINK_TO_LINE_REF
(   p_line_id                       IN NUMBER
)
RETURN VARCHAR2
IS
l_link_to_line_id     NUMBER;
l_line_number         NUMBER;
l_option_number       NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPIFPB: ENTERING GET_LINK_TO_LINE_REF API' ) ;
    END IF;

--       dbms_output.put_line('line id =>' || to_char(p_line_id));
    SELECT link_to_line_id,   line_number,  option_number
    INTO   l_link_to_line_id, l_line_number,l_option_number
    FROM   oe_order_lines
    WHERE  line_id = p_line_id;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPIFPB: AFTER SELECTING LINK DATA' ) ;
    END IF;

    IF l_link_to_line_id is null THEN
--       dbms_output.put_line('link to line id is null');
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'OEXPIFPB: LINK LINEID IS NULL' ) ;
       END IF;
       return null;
    ELSIF l_link_to_line_id is not null THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'OEXPIFPB: LINK LINEID IS NOT NULL' ) ;
       END IF;
       BEGIN
         SELECT  line_number, option_number
         INTO    l_line_number, l_option_number
         FROM    oe_order_lines
         WHERE   line_id = l_link_to_line_id;
       END;

--       dbms_output.put_line('link to line id is not null');
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'OEXPIFPB: BEFORE RETURN LINK DATA' ) ;
       END IF;
       return to_char(l_line_number) || '-' || to_char(l_option_number);

    END IF;

     EXCEPTION
       WHEN OTHERS THEN
--       dbms_output.put_line('link to line id exception');
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'OEXPIFPB: LINK RETURNS OTHERS EXCEPTION' ) ;
          END IF;

          return null;

END GET_LINK_TO_LINE_REF;

FUNCTION GET_TOP_MODEL_LINE_REF
(   p_line_id                       IN NUMBER
)
RETURN VARCHAR2
IS
l_top_model_line_id     NUMBER;
l_line_number           NUMBER;
l_option_number         NUMBER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPIFPB: ENTERING GET_TOP_MODEL_LINE_REF API' ) ;
    END IF;

    SELECT top_model_line_id,   line_number,  option_number
    INTO   l_top_model_line_id, l_line_number,l_option_number
    FROM   oe_order_lines
    WHERE  line_id = p_line_id;

    IF l_top_model_line_id is null THEN
--       dbms_output.put_line('top model is null');
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'OEXPIFPB: TOP MODEL LINEID IS NULL' ) ;
       END IF;
       return null;
    ELSIF l_top_model_line_id is not null THEN
--       dbms_output.put_line('top model is not null');
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'OEXPIFPB: TOP MODEL LINEID IS NOT NULL' ) ;
       END IF;
       BEGIN
         SELECT  line_number, option_number
         INTO    l_line_number, l_option_number
         FROM    oe_order_lines
         WHERE   line_id = l_top_model_line_id;
       END;

--       dbms_output.put_line('top model is not null before retunr');
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add(  'OEXPIFPB: BEFORE RETURN TOP MODEL DATA' ) ;
       END IF;
       return to_char(l_line_number) || '-' || to_char(l_option_number);

     END IF;

     EXCEPTION
       WHEN OTHERS THEN
--       dbms_output.put_line('top model exception');
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'OEXPIFPB: TOP MODEL RETURNS OTHERS EXCEPTION' ) ;
          END IF;
          return null;

END GET_TOP_MODEL_LINE_REF;

FUNCTION GET_LINE_REF_FROM_LINE_ID
(   p_line_id                       IN NUMBER
)
RETURN VARCHAR2
IS
l_orig_sys_line_ref     VARCHAR2(50);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPIFPB: ENTERING GET_LINE_REF_FROM_LINE_ID API' ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'P_LINE_ID ==> ' || P_LINE_ID ) ;
    END IF;

    SELECT orig_sys_line_ref
    INTO   l_orig_sys_line_ref
    FROM   oe_lines_iface_all
    WHERE  line_id = p_line_id;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OEXPIFPB: BEFORE RETURN LINE REF' ) ;
    END IF;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'L_ORIG_SYS_LINE_REF ==> ' || L_ORIG_SYS_LINE_REF ) ;
    END IF;
    return l_orig_sys_line_ref;

    EXCEPTION
       WHEN OTHERS THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'OEXPIFPB: LINE REF RETURNS OTHERS EXCEPTION' ) ;
          END IF;
          return null;

END GET_LINE_REF_FROM_LINE_ID;

END OE_INF_POPULATE_PUB;


/
