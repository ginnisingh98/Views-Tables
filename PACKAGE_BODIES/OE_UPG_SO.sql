--------------------------------------------------------
--  DDL for Package Body OE_UPG_SO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_UPG_SO" as
/* $Header: OEXIUSOB.pls 115.48 2003/10/20 06:58:37 appldev ship $ */


   Procedure Upgrade_Price_adjustments
    ( L_level_flag  IN  Varchar2)
    is
    cursor padj is
        select
             pa.price_adjustment_id,
             pa.creation_date,
             pa.created_by,
             pa.last_update_date,
             pa.last_updated_by,
             pa.last_update_login,
             pa.program_application_id,
             pa.program_id,
             pa.program_update_date,
             pa.request_id,
             pa.header_id,
             pa.discount_id,
             pa.discount_line_id,
             pa.automatic_flag,
             pa.percent,
             pa.line_id,
             pa.context,
             pa.attribute1,
             pa.attribute2,
             pa.attribute3,
             pa.attribute4,
             pa.attribute5,
             pa.attribute6,
             pa.attribute7,
             pa.attribute8,
             pa.attribute9,
             pa.attribute10,
             pa.attribute11,
             pa.attribute12,
             pa.attribute13,
             pa.attribute14,
             pa.attribute15
         from
             so_price_adjustments pa
         where (  pa.line_id   = G_OLD_LINE_ID   and
                  pa.header_id = G_HEADER_Id     and
                  L_level_flag = 'L')                 or
               (  pa.header_id = G_header_id     and
                  L_level_flag = 'H'             and
                  pa.line_id    is null );

    mpa padj%ROWTYPE;         /* alias defined for pa (price adjustments)*/
    v_price_adjustment_id     number;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
  begin
        -- dbms_output.enable(999999999999);
        open padj;
        G_ERROR_LOCATION := 1;
        loop    /* start loop for Price adjustments*/

                fetch padj into mpa;
                exit when padj%NOTFOUND;

                G_ERROR_LOCATION := 101;

                begin
                     select
                              price_adjustment_id
                     into
                              v_price_adjustment_id
                     from
                           oe_price_adjustments
                     where  price_adjustment_id = mpa.price_adjustment_id;

                     G_ERROR_LOCATION := 102;

                     select
                          oe_price_adjustments_s.nextval
                     into
                          v_price_adjustment_id
                     from dual;
                     G_ERROR_LOCATION := 103;
                exception
                     when no_data_found then
                          v_price_adjustment_id := mpa.price_adjustment_id;
/*
                     when others then
                          null;
*/
                          /* Should also process ERRORS here */
                end;

                -- dbms_output.put_line('ins oe_price_adjs');

                G_ERROR_LOCATION := 104;

                insert into oe_price_adjustments
                (
                        price_adjustment_id,
                        creation_date,
                        created_by,
                        last_update_date,
                        last_updated_by,
                        last_update_login,
                        program_application_id,
                        program_id,
                        program_update_date,
                        request_id,
                        header_id,
                        discount_id,
                        discount_line_id,
                        automatic_flag,
                        percent,
                        line_id,
                        context,
                        attribute1,
                        attribute2,
                        attribute3,
                        attribute4,
                        attribute5,
                        attribute6,
                        attribute7,
                        attribute8,
                        attribute9,
                        attribute10,
                        attribute11,
                        attribute12,
                        attribute13,
                        attribute14,
                        attribute15
                )
                values
                (
                        v_price_adjustment_id,
                        mpa.creation_date,
                        mpa.created_by,
                        mpa.last_update_date,
                        mpa.last_updated_by,
                        mpa.last_update_login,
                        mpa.program_application_id,
                        mpa.program_id,
                        mpa.program_update_date,
                        mpa.request_id,
                        mpa.header_id,
                        mpa.discount_id,
                        mpa.discount_line_id,
                        mpa.automatic_flag,
                        mpa.percent,
                        decode(L_level_flag,'L',G_LINE_ID,null),
                        mpa.context,
                        mpa.attribute1,
                        mpa.attribute2,
                        mpa.attribute3,
                        mpa.attribute4,
                        mpa.attribute5,
                        mpa.attribute6,
                        mpa.attribute7,
                        mpa.attribute8,
                        mpa.attribute9,
                        mpa.attribute10,
                        mpa.attribute11,
                        mpa.attribute12,
                        mpa.attribute13,
                        mpa.attribute14,
                        mpa.attribute15
                );

                G_ERROR_LOCATION := 105;

        end loop;   /* end loop for price adjustments */
        G_ERROR_LOCATION := 2;
        close padj;
   End upgrade_price_adjustments;

   Procedure Upgrade_Sales_Credits
          ( L_level_flag  IN  Varchar2)
        is
        cursor sc is
        select
                ssc.sales_credit_id,
                ssc.creation_date,
                ssc.created_by,
                ssc.last_update_date,
                ssc.last_updated_by,
                ssc.last_update_login,
                ssc.header_id,
                ssc.sales_credit_type_id,
                ssc.salesrep_id,
                ssc.percent,
                ssc.line_id,
                ssc.context,
                ssc.attribute1,
                ssc.attribute2,
                ssc.attribute3,
                ssc.attribute4,
                ssc.attribute5,
                ssc.attribute6,
                ssc.attribute7,
                ssc.attribute8,
                ssc.attribute9,
                ssc.attribute10,
                ssc.attribute11,
                ssc.attribute12,
                ssc.attribute13,
                ssc.attribute14,
                ssc.attribute15,
                null dw_update_advice_flag,
                ssc.wh_update_date
        from
                so_sales_credits            ssc
        where (  (ssc.line_id           = G_OLD_LINE_ID and
                  ssc.header_id	     = G_header_id   and
                  L_level_flag          = 'L')
              or (ssc.header_id         = G_header_id   and
                  L_level_flag       = 'H'           and
                  ssc.line_id        is null ) );

        msc sc%ROWTYPE;       /* alias defined for sc (sales credits)*/
        v_sales_credit_id     number;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
    begin
        -- dbms_output.enable(999999999);
        open sc;
        G_ERROR_LOCATION := 3;
        loop    /* start loop for sales credits*/

                fetch sc into msc;
                exit when sc%NOTFOUND;

                begin
                     select
                              sales_credit_id
                     into
                              v_sales_credit_id
                     from
                              oe_sales_credits
                     where  sales_credit_id = msc.sales_credit_id;

                     select
                          oe_sales_credits_s.nextval
                     into
                          v_sales_credit_id
                     from dual;
                exception
                     when no_data_found then
                          v_sales_credit_id := msc.sales_credit_id;
                     when others then
                          null;
                          /* Should also process ERRORS here */
                end;

                -- dbms_output.put_line('Ins oe_sales_credits');
                insert into oe_sales_credits
                (
                      sales_credit_id,
                      creation_date,
                      created_by,
                      last_update_date,
                      last_updated_by,
                      last_update_login,
                      header_id,
                      sales_credit_type_id,
                      salesrep_id,
                      percent,
                      line_id,
                      context,
                      attribute1,
                      attribute2,
                      attribute3,
                      attribute4,
                      attribute5,
                      attribute6,
                      attribute7,
                      attribute8,
                      attribute9,
                      attribute10,
                      attribute11,
                      attribute12,
                      attribute13,
                      attribute14,
                      attribute15,
                      dw_update_advice_flag,
                      wh_update_date
                )
                values
                (
                      v_sales_credit_id,
                      msc.creation_date,
                      msc.created_by,
                      msc.last_update_date,
                      msc.last_updated_by,
                      msc.last_update_login,
                      msc.header_id,
                      msc.sales_credit_type_id,
                      msc.salesrep_id,
                      msc.percent,
                      decode(L_level_flag,'L',G_LINE_ID,null),
                      msc.context,
                      msc.attribute1,
                      msc.attribute2,
                      msc.attribute3,
                      msc.attribute4,
                      msc.attribute5,
                      msc.attribute6,
                      msc.attribute7,
                      msc.attribute8,
                      msc.attribute9,
                      msc.attribute10,
                      msc.attribute11,
                      msc.attribute12,
                      msc.attribute13,
                      msc.attribute14,
                      msc.attribute15,
                      msc.dw_update_advice_flag,
                      msc.wh_update_date
                );
        end loop;   /* end loop for Sales credits*/
        G_ERROR_LOCATION := 4;
        close sc;
   End Upgrade_Sales_Credits;

   Procedure Upgrade_Cancellations
     is
     cursor can is
          select
               soc.header_id,
               soc.line_id,
               soc.created_by,
               soc.creation_date,
               soc.last_updated_by,
               soc.last_update_date,
               soc.last_update_login,
               soc.program_application_id,
               soc.program_id,
               soc.program_update_date,
               soc.request_id,
               soc.cancel_code,
               soc.cancelled_by,
               soc.cancel_date,
               soc.cancelled_quantity,
               soc.cancel_comment,
               soc.context,
               soc.attribute1,
               soc.attribute2,
               soc.attribute3,
               soc.attribute4,
               soc.attribute5,
               soc.attribute6,
               soc.attribute7,
               soc.attribute8,
               soc.attribute9,
               soc.attribute10,
               soc.attribute11,
               soc.attribute12,
               soc.attribute13,
               soc.attribute14,
               soc.attribute15
          from
               so_order_cancellations 	soc
          where   soc.line_id  	=  G_old_line_id
          and     soc.header_id	=  G_header_id;

     --
     l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
     --
   begin
          -- dbms_output.enable(999999999);
          G_ERROR_LOCATION := 5;
          for mcan in can loop
               G_canc_rec := NULL;
               G_canc_rec := mcan;
               -- dbms_output.put_line('Ins cancellations');
               G_ORD_CANC_FLAG := 'Y';
               OE_Upg_SO.Upgrade_Insert_Lines_History;
               G_ORD_CANC_FLAG := 'N';
          end loop;   /* end loop for Cancellations */
          G_ERROR_LOCATION := 6;
   End Upgrade_Cancellations;

   Procedure Upgrade_Create_Order_Lines
      is
      cursor ol is
      select
          sla.line_id,
          sla.org_id,
          sla.header_id,
          sla.line_number,
          sla.date_requested_current,
          sla.promise_date,
          nvl(sld.schedule_date,sla.schedule_date) schedule_date,
          nvl(sld.quantity,(nvl(sla.ordered_quantity,0)-nvl(sla.cancelled_quantity,0))) ordered_quantity,
          decode(nvl(sla.ordered_quantity,0),nvl(sla.cancelled_quantity,0),'Y','N') line_cancel_flag,
          sla.cancelled_quantity,
          decode(
                  nvl(decode(sla.item_type_code,'SERVICE','N',
                    decode(sla.ato_line_id,null,sld.shippable_flag,
                      decode(sla.item_type_code,'CONFIG',sld.shippable_flag,'N'))),'-'),  'Y',
             decode(sla.source_type_code,'EXTERNAL',
                decode(sld.receipt_status_code,'INTERFACED',sld.quantity,null),sld.shipped_quantity),
             decode(nvl(sla.ordered_quantity,0),nvl(sla.shipped_quantity,0),sla.shipped_quantity,
                          null)) shipped_quantity,
          nvl(sld.invoiced_quantity,sla.invoiced_quantity) invoiced_quantity,
          sla.tax_exempt_number,
          sla.tax_exempt_reason_code,
          nvl(sld.warehouse_id,sla.warehouse_id) warehouse_id,
          sla.ship_to_site_use_id,
          sla.ship_to_contact_id,
          decode(G_AUTO_FLAG,'Y',sla.customer_item_id,
                 nvl(sld.customer_item_id,sla.customer_item_id)) customer_item_id,
          sla.demand_stream_id,
          sla.customer_dock_code,
          sla.customer_job,
          sla.customer_production_line,
          sla.customer_model_serial_number,
          sla.project_id,
          sla.task_id,
          nvl(sld.inventory_item_id,sla.inventory_item_id) inventory_item_id,
          sla.inventory_item_id service_inventory_item_id,
          sla.tax_code,
          sla.demand_class_code,
          sla.price_list_id,
          sla.agreement_id,
          sla.shipment_priority_code,
          sla.ship_method_code,
          sla.invoicing_rule_id,
          sla.accounting_rule_id,
          sla.original_system_line_reference,
          sla.selling_price,
          sla.list_price,
          sla.context,
          sla.attribute1,
          sla.attribute2,
          sla.attribute3,
          sla.attribute4,
          sla.attribute5,
          sla.attribute6,
          sla.attribute7,
          sla.attribute8,
          sla.attribute9,
          sla.attribute10,
          sla.attribute11,
          sla.attribute12,
          sla.attribute13,
          sla.attribute14,
          sla.attribute15,
          slattr.industry_context,
          slattr.industry_attribute1,
          slattr.industry_attribute2,
          slattr.industry_attribute3,
          slattr.industry_attribute4,
          slattr.industry_attribute5,
          slattr.industry_attribute6,
          slattr.industry_attribute7,
          slattr.industry_attribute8,
          slattr.industry_attribute9,
          slattr.industry_attribute10,
          slattr.industry_attribute11,
          slattr.industry_attribute12,
          slattr.industry_attribute13,
          slattr.industry_attribute14,
          slattr.industry_attribute15,
          slattr.global_attribute_category,
          slattr.global_attribute1,
          slattr.global_attribute2,
          slattr.global_attribute3,
          slattr.global_attribute4,
          slattr.global_attribute5,
          slattr.global_attribute6,
          slattr.global_attribute7,
          slattr.global_attribute8,
          slattr.global_attribute9,
          slattr.global_attribute10,
          slattr.global_attribute11,
          slattr.global_attribute12,
          slattr.global_attribute13,
          slattr.global_attribute14,
          slattr.global_attribute15,
          slattr.global_attribute16,
          slattr.global_attribute17,
          slattr.global_attribute18,
          slattr.global_attribute19,
          slattr.global_attribute20,
          sla.pricing_context,
          sla.pricing_attribute1,
          sla.pricing_attribute2,
          sla.pricing_attribute3,
          sla.pricing_attribute4,
          sla.pricing_attribute5,
          sla.pricing_attribute6,
          sla.pricing_attribute7,
          sla.pricing_attribute8,
          sla.pricing_attribute9,
          sla.pricing_attribute10,
          nvl(sld.creation_date,sla.creation_date) creation_date,
          nvl(sld.created_by,sla.created_by) created_by,
          nvl(sld.last_update_date,sla.last_update_date) last_update_date,
          nvl(sld.last_updated_by,sla.last_updated_by) last_updated_by,
          nvl(sld.last_update_login,sla.last_update_login) last_update_login,
          sla.program_application_id,
          sla.program_id,
          sla.program_update_date,
          sla.request_id,
          decode(sla.item_type_code,'MODEL',
	          decode(sla.parent_line_id,NULL,sla.line_id,sla.parent_line_id),
		          sla.parent_line_id) parent_Line_id,
          sla.link_to_line_id,
          nvl(sld.component_sequence_id,sla.component_sequence_id) component_sequence_id,
          nvl(sld.component_code,sla.component_code) component_code,
          decode(sla.item_type_code,
                 'STANDARD', decode(sla.option_flag,
                                    'Y','OPTION',
                                    sla.item_type_code),
                 'MODEL', decode(sla.parent_line_id,
                                 NULL,'MODEL',
                                 'CLASS'),
                  sla.item_type_code) item_type_code,
          sla.source_type_code,
          sla.transaction_reason_code,
          nvl(sld.latest_acceptable_date, sla.latest_acceptable_date) latest_acceptable_date,
          sld.dep_plan_required_flag,
          decode(sla.item_type_code,'SERVICE',NULL,
            decode(nvl(sld.schedule_status_code,'0'),'0',NULL,'SCHEDULED')) schedule_status_code,
          sld.configuration_item_flag,
          sld.delivery,
		' ' load_seq_number,
          sla.ship_set_number,
          sla.option_flag,
          sla.unit_code,
          sld.line_detail_id,
          sla.credit_invoice_line_id,
          sld.included_item_flag,
          decode(sla.item_type_code,
                 'MODEL', decode(sla.ato_line_id,
                                 NULL, decode(ato_flag,
                                              'Y', sla.line_id,
                                               sla.ato_line_id),
                                 sla.ato_line_id),
                 'STANDARD', decode(sla.ato_line_id,
                                    NULL, decode(ato_flag,
                                                 'Y', sla.line_id,
                                                  sla.ato_line_id),
                                    sla.ato_line_id),
                 sla.ato_line_id) ato_line_id,
          decode(sla.line_type_code,'RETURN','RETURN','ORDER') line_category_code,
          sla.planning_priority,
          decode(sla.return_reference_type_code,'ORDER','ORDER',
	          'PO','PO','INVOICE','INVOICE',sla.return_reference_type_code)
                                     return_reference_type_code,
          sla.line_type_code,
          sla.return_reference_id,
          nvl(sla.open_flag,'N') open_flag,
          sla.ship_model_complete_flag,
          sla.standard_component_freeze_date,
          decode(sla.s1,1,'Y','N') booked_flag,
          decode(nvl(sld.picking_line_id,0),0,'N','Y') shipping_interfaced_flag,
          decode(sla.s4,6,'Y',NULL) fulfilled_flag,
          decode(sla.s5,9,'YES',8,'NOT_ELIGIBLE',24,'NOT_ELIGIBLE',NULL) invoice_interface_status_code,
          sla.s5,
          sla.intermediate_ship_to_id,
          sla.transaction_type_code,
          sla.transaction_comments,
          sla.selling_percent,
          sla.customer_product_id,
          sla.cp_service_id,
          nvl(sld.quantity,sla.serviced_quantity) serviced_quantity,
          sla.service_duration,
          sla.service_start_date,
          sla.service_end_date,
          sla.service_coterminate_flag,
          sla.service_period_conversion_rate,
          sla.service_mass_txn_temp_id,
          sla.service_parent_line_id,
          sla.list_percent,
          sla.percent_base_price,
          sld.picking_line_id,
		sla.planning_prod_seq_number,
		sld.actual_departure_date,
          decode(sla.item_type_code,'SERVICE',NULL,
            decode(nvl(sld.schedule_status_code,'-'),'-','','Y')) visible_demand_flag,
          decode(sla.item_type_code,'SERVICE','N',
            decode(sla.ato_line_id,null,sld.shippable_flag,
              decode(sla.item_type_code,'CONFIG',sld.shippable_flag,'N'))) shippable_flag
          /*  If you make changes to shippable flag in the above line, make it also on */
          /*  shipped_quantity decode                                                  */
      from
          so_lines_all sla,
          so_line_attributes slattr,
          oe_upgrade_wsh_iface sld
      where
          sla.line_id   = slattr.line_id (+)  and
          sla.header_id = G_header_id         and
          decode(sla.item_type_code,'SERVICE',
                nvl(sla.service_parent_line_id,0),sla.line_id) = sld.line_id(+) and
          sla.line_type_code <> 'PARENT'      and
          not exists
          (select NE.line_id from so_lines_all NE
           where NE.line_Id = sla.service_parent_line_id
           and   NE.line_type_code = 'PARENT')            /* Standalone service not upgraded */
      order by
          sla.ship_set_number,
          sla.line_id,
          sld.component_code,
          sld.line_detail_id;

      mol ol%ROWTYPE;		/* alias defined for detail-less lines cursor*/

      v_service_flag           varchar2(1);
      v_system_id              number;
      v_line_id                number;
      v_cancelled_quantity     number;
      v_ship_set_number        number;

      v_ins_return_quantity    number;
      v_avl_return_quantity    number;
      v_bal_return_quantity    number;
      v_return_new_line_id     number;
      v_return_new_line_number number;
      v_return_lctr            number;
      v_return_created_line_id number;
      v_line_exit_flag         number;
      v_cust_trx_attribute6    number;
      v_customer_trx_id        number;
      v_received_quantity      number;
      v_actual_ordered_quantity number;
      r_pto_m_c_k boolean := FALSE;
      r_upgraded_flag varchar2(1):= null;
      --
      l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
      --
   begin
        -- dbms_output.enable(999999999);

        G_ERROR_LOCATION := 7;
        v_line_id                    := 0;
        g_line_id_change_flag        := 'N';
        g_last_line_number           := 0;
        v_ship_set_number            := 0;
        g_set_id                     := NULL;


        open ol;
        <<begining_of_lines_loop>>
        loop    /* start loop for Order lines */
                G_ERROR_LOCATION := 701;

                r_shipment_number            := 1;
                r_ato_model                  := FALSE;
                r_pto_m_c_k                  := FALSE;
                r_no_config_item             := FALSE;
                r_ato_option                 := FALSE;
                r_upgraded_flag              := null;
                r_line_set_id         	     := null;
                r_inventory_item_id          := null;
                r_uom_code         	     := null;
                r_warehouse_id         	     := null;
                v_return_created_line_id     := null;

                fetch ol into mol;
                exit when ol%NOTFOUND;

                /* Services are not split in terms with its parents' details
                if the Parent's detail
                is a Included item or a config item  (changed on 12/22/99)*/

                if mol.item_type_code = 'SERVICE' and
                    (nvl(mol.included_item_flag,'-') = 'Y'
                          or nvl(mol.configuration_item_flag,'-') = 'Y') then
                     goto begining_of_lines_loop;
                end if;

                /* g_line_rec := mol; */

                if mol.item_type_code = 'SERVICE' then
                    v_service_flag := 'Y';
                else
                    v_service_flag := 'N';
                end if;

                G_OLD_LINE_ID                                    :=mol.line_id;

                g_line_rec.line_id                               :=mol.line_id;
                g_line_rec.org_id                                :=mol.org_id;
                g_line_rec.header_id                             :=mol.header_id;
                g_line_rec.line_number                           :=mol.line_number;
                g_line_rec.date_requested_current                :=mol.date_requested_current;
                g_line_rec.promise_date	                         :=mol.promise_date;

                if mol.schedule_status_code is null then
                     g_line_rec.schedule_date  :=null;
                else
                     g_line_rec.schedule_date  :=mol.schedule_date;
                end if;

                if v_service_flag = 'Y' then
                     g_line_rec.ordered_quantity      :=  mol.serviced_quantity;
                else
                     g_line_rec.ordered_quantity      :=  mol.ordered_quantity;
                end if;

			 if g_line_rec.ordered_quantity = 0 then
                     g_line_rec.ordered_quantity := NULL;
                end if;

                g_line_rec.cancelled_quantity                    :=mol.cancelled_quantity;
                g_line_rec.shipped_quantity                      :=mol.shipped_quantity;

			 if g_line_rec.shipped_quantity = 0 then
                     g_line_rec.shipped_quantity := NULL;
                end if;

                if nvl(mol.invoice_interface_status_code,'-') = 'YES' then
                   g_line_rec.invoiced_quantity   :=mol.ordered_quantity;
                else
                   g_line_rec.invoiced_quantity   :=mol.invoiced_quantity;
                end if;

			 if nvl(g_line_rec.invoiced_quantity,0) = 0 then
                     g_line_rec.invoiced_quantity := NULL;
                end if;

                if nvl(mol.item_type_code,'-') = 'SERVICE' then
                     g_line_rec.inventory_item_id    :=mol.service_inventory_item_id;
                else
                     g_line_rec.inventory_item_id    :=mol.inventory_item_id;
                end if;

                g_line_rec.tax_exempt_number                     :=mol.tax_exempt_number;
                g_line_rec.tax_exempt_reason_code                :=mol.tax_exempt_reason_code;
                g_line_rec.warehouse_id                          :=mol.warehouse_id;
                g_line_rec.ship_to_site_use_id                   :=mol.ship_to_site_use_id;
                g_line_rec.ship_to_contact_id                    :=mol.ship_to_contact_id;
                g_line_rec.customer_item_id                      :=mol.customer_item_id;
                g_line_rec.demand_stream_id                      :=mol.demand_stream_id;
                g_line_rec.customer_dock_code                    :=mol.customer_dock_code;
                g_line_rec.customer_job                          :=mol.customer_job;
                g_line_rec.customer_production_line              :=mol.customer_production_line;
                g_line_rec.customer_model_serial_number          :=mol.customer_model_serial_number;
                g_line_rec.project_id                            :=mol.project_id;
                g_line_rec.task_id                               :=mol.task_id;
                g_line_rec.tax_code                              :=mol.tax_code;
                g_line_rec.demand_class_code                     :=mol.demand_class_code;
                g_line_rec.price_list_id                         :=mol.price_list_id;
                g_line_rec.agreement_id                          :=mol.agreement_id;
                g_line_rec.shipment_priority_code                :=mol.shipment_priority_code;
                g_line_rec.ship_method_code                      :=mol.ship_method_code;
                g_line_rec.invoicing_rule_id                     :=mol.invoicing_rule_id;
                g_line_rec.accounting_rule_id                    :=mol.accounting_rule_id;
                g_line_rec.original_system_line_reference        :=mol.original_system_line_reference;
                g_line_rec.selling_price                         :=mol.selling_price;
                g_line_rec.list_price                            :=mol.list_price;
                g_line_rec.context                               :=mol.context;
                g_line_rec.attribute1                            :=mol.attribute1;
                g_line_rec.attribute2                            :=mol.attribute2;
                g_line_rec.attribute3                            :=mol.attribute3;
                g_line_rec.attribute4                            :=mol.attribute4;
                g_line_rec.attribute5                            :=mol.attribute5;
                g_line_rec.attribute6                            :=mol.attribute6;
                g_line_rec.attribute7                            :=mol.attribute7;
                g_line_rec.attribute8                            :=mol.attribute8;
                g_line_rec.attribute9                            :=mol.attribute9;
                g_line_rec.attribute10                           :=mol.attribute10;
                g_line_rec.attribute11                           :=mol.attribute11;
                g_line_rec.attribute12                           :=mol.attribute12;
                g_line_rec.attribute13                           :=mol.attribute13;
                g_line_rec.attribute14                           :=mol.attribute14;
                g_line_rec.attribute15                           :=mol.attribute15;
                g_line_rec.industry_context                      :=mol.industry_context;
                g_line_rec.industry_attribute1                   :=mol.industry_attribute1;
                g_line_rec.industry_attribute2                   :=mol.industry_attribute2;
                g_line_rec.industry_attribute3                   :=mol.industry_attribute3;
                g_line_rec.industry_attribute4                   :=mol.industry_attribute4;
                g_line_rec.industry_attribute5                   :=mol.industry_attribute5;
                g_line_rec.industry_attribute6                   :=mol.industry_attribute6;
                g_line_rec.industry_attribute7                   :=mol.industry_attribute7;
                g_line_rec.industry_attribute8                   :=mol.industry_attribute8;
                g_line_rec.industry_attribute9                   :=mol.industry_attribute9;
                g_line_rec.industry_attribute10                  :=mol.industry_attribute10;
                g_line_rec.industry_attribute11                  :=mol.industry_attribute11;
                g_line_rec.industry_attribute12                  :=mol.industry_attribute12;
                g_line_rec.industry_attribute13                  :=mol.industry_attribute13;
                g_line_rec.industry_attribute14                  :=mol.industry_attribute14;
                g_line_rec.industry_attribute15                  :=mol.industry_attribute15;
                G_ERROR_LOCATION := 702;

                if substr(mol.global_attribute_category,1,5) in ('JL.BR', 'JL.AR', 'JL.CO') then
                     g_line_rec.global_attribute_category   :=
                         substr(mol.global_attribute_category,1,5)||'.OEXOEORD.LINES';
                else
                     g_line_rec.global_attribute_category   :=  mol.global_attribute_category;
                end if;

                G_ERROR_LOCATION := 7021;

                g_line_rec.global_attribute1                     :=mol.global_attribute1;
                g_line_rec.global_attribute2                     :=mol.global_attribute2;
                g_line_rec.global_attribute3                     :=mol.global_attribute3;
                g_line_rec.global_attribute4                     :=mol.global_attribute4;
                g_line_rec.global_attribute5                     :=mol.global_attribute5;
                g_line_rec.global_attribute6                     :=mol.global_attribute6;
                g_line_rec.global_attribute7                     :=mol.global_attribute7;
                g_line_rec.global_attribute8                     :=mol.global_attribute8;
                g_line_rec.global_attribute9                     :=mol.global_attribute9;
                g_line_rec.global_attribute10                    :=mol.global_attribute10;
                g_line_rec.global_attribute11                    :=mol.global_attribute11;
                g_line_rec.global_attribute12                    :=mol.global_attribute12;
                g_line_rec.global_attribute13                    :=mol.global_attribute13;
                g_line_rec.global_attribute14                    :=mol.global_attribute14;
                g_line_rec.global_attribute15                    :=mol.global_attribute15;
                g_line_rec.global_attribute16                    :=mol.global_attribute16;
                g_line_rec.global_attribute17                    :=mol.global_attribute17;
                g_line_rec.global_attribute18                    :=mol.global_attribute18;
                g_line_rec.global_attribute19                    :=mol.global_attribute19;
                g_line_rec.global_attribute20                    :=mol.global_attribute20;
                g_line_rec.pricing_context                       :=mol.pricing_context;
                g_line_rec.pricing_attribute1                    :=mol.pricing_attribute1;
                g_line_rec.pricing_attribute2                    :=mol.pricing_attribute2;
                g_line_rec.pricing_attribute3                    :=mol.pricing_attribute3;
                g_line_rec.pricing_attribute4                    :=mol.pricing_attribute4;
                g_line_rec.pricing_attribute5                    :=mol.pricing_attribute5;
                g_line_rec.pricing_attribute6                    :=mol.pricing_attribute6;
                g_line_rec.pricing_attribute7                    :=mol.pricing_attribute7;
                g_line_rec.pricing_attribute8                    :=mol.pricing_attribute8;
                g_line_rec.pricing_attribute9                    :=mol.pricing_attribute9;
                g_line_rec.pricing_attribute10                   :=mol.pricing_attribute10;
                g_line_rec.creation_date                         :=mol.creation_date;
                g_line_rec.created_by                            :=mol.created_by;
                g_line_rec.last_update_date                      :=mol.last_update_date;
                g_line_rec.last_updated_by                       :=mol.last_updated_by;
                g_line_rec.last_update_login                     :=mol.last_update_login;
                g_line_rec.program_application_id                :=mol.program_application_id;
                g_line_rec.program_id                            :=mol.program_id;
                g_line_rec.program_update_date                   :=mol.program_update_date;
                g_line_rec.request_id                            :=mol.request_id;

                G_ERROR_LOCATION := 7022;

                g_line_rec.parent_line_id                        :=mol.parent_line_id;
                g_line_rec.link_to_line_id                       :=mol.link_to_line_id;
                g_line_rec.component_sequence_id                 :=mol.component_sequence_id;
                g_line_rec.component_code                        :=mol.component_code;
                g_line_rec.item_type_code                        :=mol.item_type_code;
                g_line_rec.source_type_code                      :=mol.source_type_code;
                g_line_rec.transaction_reason_code               :=mol.transaction_reason_code;

                if mol.latest_acceptable_date is null then
				 begin
                          g_line_rec.latest_acceptable_date  := g_line_rec.date_requested_current
                               + G_EARLIEST_SCHEDULE_LIMIT;
                     exception
                          when others then
                              g_line_rec.latest_acceptable_date  :=NULL;
                              oe_upg_so.upgrade_insert_errors
                              (
                                   L_header_id => g_header_id,
                                   L_comments  => 'FYI Only: Line ID: '||to_char(g_old_line_id)
                                  ||' had corrupted data in Date_requested_current field. Latest_acceptable_date is updated to NULL for all its new lines'
                              );

                     end;
                else
                     g_line_rec.latest_acceptable_date  :=mol.latest_acceptable_date;
                end if;

                g_line_rec.dep_plan_required_flag                :=mol.dep_plan_required_flag;
                g_line_rec.schedule_status_code                  :=mol.schedule_status_code;
                g_line_rec.configuration_item_flag               :=mol.configuration_item_flag;
                g_line_rec.ship_set_number                       :=mol.ship_set_number;
                g_line_rec.option_flag                           :=mol.option_flag;
                g_line_rec.unit_code                             :=mol.unit_code;
                g_line_rec.line_detail_id                        :=mol.line_detail_id;
                g_line_rec.credit_invoice_line_id                :=mol.credit_invoice_line_id;
                g_line_rec.included_item_flag                    :=mol.included_item_flag;
                g_line_rec.ato_line_id                           :=mol.ato_line_id;
                g_line_rec.line_category_code                    :=mol.line_category_code;
                g_line_rec.planning_priority                     :=mol.planning_priority;
                g_line_rec.return_reference_type_code            :=mol.return_reference_type_code;
                g_line_rec.line_type_code                        :=mol.line_type_code;
                g_line_rec.return_reference_id                   :=mol.return_reference_id;
                g_line_rec.open_flag                             :=mol.open_flag;
                g_line_rec.ship_model_complete_flag              :=mol.ship_model_complete_flag;
                g_line_rec.standard_component_freeze_date        :=mol.standard_component_freeze_date;

                G_ERROR_LOCATION := 7023;

                g_line_rec.booked_flag                           :=mol.booked_flag;
                g_line_rec.shipping_interfaced_flag              :=mol.shipping_interfaced_flag;
                g_line_rec.fulfilled_flag                        :=mol.fulfilled_flag;
                g_line_rec.intermediate_ship_to_id               :=mol.intermediate_ship_to_id;
                g_line_rec.transaction_type_code                 :=mol.transaction_type_code;
                g_line_rec.transaction_comments                  :=mol.transaction_comments;
                g_line_rec.selling_percent                       :=mol.selling_percent;
                g_line_rec.customer_product_id                   :=mol.customer_product_id;
                g_line_rec.cp_service_id                         :=mol.cp_service_id;
                g_line_rec.serviced_quantity                     :=mol.serviced_quantity;
                g_line_rec.service_duration                      :=mol.service_duration;
                g_line_rec.service_start_date                    :=mol.service_start_date;
                g_line_rec.service_end_date                      :=mol.service_end_date;
                g_line_rec.service_coterminate_flag              :=mol.service_coterminate_flag;
                g_line_rec.service_period_conversion_rate        :=mol.service_period_conversion_rate;
                g_line_rec.service_mass_txn_temp_id              :=mol.service_mass_txn_temp_id;
                g_line_rec.service_parent_line_id                :=mol.service_parent_line_id;
                g_line_rec.service_period                        :=NULL;
                g_line_rec.list_percent                          :=mol.list_percent;
                g_line_rec.percent_base_price                    :=mol.percent_base_price;
                g_line_rec.picking_line_id                       :=mol.picking_line_id;

                G_ERROR_LOCATION := 7024;

                g_line_rec.planning_prod_seq_number              :=mol.planning_prod_seq_number;
                g_line_rec.actual_departure_date                 :=mol.actual_departure_date;
                g_line_rec.re_source_flag                        :='N';
                g_line_rec.tp_context                            :=null;
                g_line_rec.tp_attribute1                         :=null;
                g_line_rec.tp_attribute2                         :=null;
                g_line_rec.tp_attribute3                         :=null;
                g_line_rec.tp_attribute4                         :=null;
                g_line_rec.tp_attribute5                         :=null;
                g_line_rec.tp_attribute6                         :=null;
                g_line_rec.tp_attribute7                         :=null;
                g_line_rec.tp_attribute8                         :=null;
                g_line_rec.tp_attribute9                         :=null;
                g_line_rec.tp_attribute10                        :=null;
                g_line_rec.tp_attribute11                        :=null;
                g_line_rec.tp_attribute12                        :=null;
                g_line_rec.tp_attribute13                        :=null;
                g_line_rec.tp_attribute14                        :=null;
                g_line_rec.tp_attribute15                        :=null;

                g_line_rec.fulfilled_quantity                    :=mol.shipped_quantity;
			 if g_line_rec.fulfilled_quantity = 0 then
                     g_line_rec.fulfilled_quantity := NULL;
                end if;


                G_ERROR_LOCATION := 7025;

                g_line_rec.marketing_source_code_id              :=null;
                g_line_rec.calculate_price_flag                  :='Y';

                G_ERROR_LOCATION := 7026;

                g_line_rec.shippable_flag                        :=mol.shippable_flag;
                g_line_rec.fulfillment_method_code               :=null;

                G_ERROR_LOCATION := 7027;

                g_line_rec.revenue_amount                        :=null;

                if nvl(g_line_rec.shipped_quantity,0) > 0 then
                     g_line_rec.shipping_quantity_uom            :=mol.unit_code;
                     g_line_rec.fulfillment_date                 :=mol.actual_departure_date;
                else
                     g_line_rec.fulfillment_date                 :=null;
                     g_line_rec.shipping_quantity_uom            :=null;
                end if;

                G_ERROR_LOCATION := 7028;

                g_line_rec.visible_demand_flag                   :=mol.visible_demand_flag;
                g_line_rec.flow_status_code                      :=null;

                G_ERROR_LOCATION := 703;

                if G_CANCELLED_FLAG = 'Y' or (mol.ordered_quantity = mol.cancelled_quantity) then
                     g_line_rec.cancelled_flag                   :='Y';
                     g_line_rec.flow_status_code                 :='CANCELLED';
                else
                     g_line_rec.cancelled_flag                   :=NULL;

                     if mol.open_flag = 'N' then
                          g_line_rec.flow_status_code            :='CLOSED';
                     elsif mol.booked_Flag = 'N' then
                          g_line_rec.flow_status_code            :='ENTERED';
                     elsif mol.booked_Flag = 'Y' then
                          g_line_rec.flow_status_code            :='BOOKED';
                     else
                          g_line_rec.flow_status_code            :=NULL;
                     end if;
                end if;


                if v_service_flag = 'Y' then
                       g_line_rec.service_txn_reason_code      := mol.transaction_reason_code;
                       g_line_rec.service_txn_comments         := mol.transaction_comments;
                       g_line_rec.service_number               := mol.line_number;
                       g_line_rec.service_reference_type_Code  := 'ORDER';
                       g_line_rec.service_reference_line_id    := mol.service_parent_line_id;

                       v_system_id := NULL;

                       select max(system_id) into v_system_id from so_line_service_details
                       where line_id = mol.line_id;

                       g_line_rec.service_reference_system_id  :=v_system_id;
                else
                       g_line_rec.service_txn_reason_code := NULL;
                       g_line_rec.service_txn_comments    := NULL;
                       g_line_rec.service_number          := NULL;
                       g_line_rec.service_reference_type_Code  :=NULL;
                       g_line_rec.service_reference_line_id    :=NULL;
                       g_line_rec.service_reference_system_id  :=NULL;
                end if;

                if (nvl(v_ship_set_number,0) <> nvl(mol.ship_set_number,0)
                  and mol.ship_set_number is not NULL
                  and mol.schedule_date is not NULL
                  and mol.warehouse_id is not NULL
                  and mol.schedule_status_code is not NULL
                  and mol.ship_to_site_use_id is not NULL) then
/*
                  and mol.shipment_priority_code is not NULL
                  and mol.ship_method_code is not NULL)        then
*/
                       v_ship_set_number := mol.ship_set_number;
                       select
                            oe_sets_s.nextval
                       into
                            g_set_id
                       from dual;

                       G_ERROR_LOCATION := 704;

                       insert into oe_sets
                        (
                                set_id,
                                set_name,
                                set_type,
                                header_id,
                                ship_from_org_id,
                                ship_to_org_id,
                                shipment_priority_code,
                                schedule_ship_date,
                                schedule_arrival_date,
                                freight_carrier_code,
                                shipping_method_code,
                                set_status,
                                created_by,
                                creation_date,
                                update_date,
                                updated_by,
                                update_login
                        )
                       values
                        (
                                g_set_id,                   /* SET_ID                 */
                                mol.ship_set_number, 	     /* SET_NAME               */
                                'SHIP_SET',                 /* SET_TYPE               */
                                G_header_id,                /* HEADER_ID              */
                                mol.warehouse_id,           /* SHIP_FROM_ORG_ID       */
                                NULL,                       /* SHIP_TO_ORG_ID         */
                                mol.shipment_priority_code, /* SHIPMENT_PRIORITY_CODE */
                                mol.schedule_date,          /* SCHEDULE_SHIP_DATE     */
                                null,                       /* SCHEDULE_ARRIVAL_DATE  */
                                mol.ship_method_code,       /* FREIGHT_CARRIER_CODE   */
                                mol.ship_method_code,       /* SHIP_METHOD_CODE       */
                                null,                       /* SET_STATUS             */
                                1,                          /* CREATED_BY             */
                                SYSDATE,                    /* CREATION_DATE          */
                                SYSDATE,                    /* LAST_UPDATE_DATE       */
                                1,                          /* LAST_UPDATED_BY        */
                                0                           /* LAST_UPDATE_LOGIN      */
                         );
                         G_ERROR_LOCATION := 705;
               elsif mol.ship_set_number is null then
                         G_ERROR_LOCATION := 706;
                    g_set_id := NULL;
               end if;

               g_copied_line_flag := 'N';

               if v_line_id = mol.line_id then
                    select
                        oe_order_lines_s.nextval
                    into
                        g_line_id
                    from dual;
                    g_line_id_change_flag := 'N';
               else
                    v_line_id              := mol.line_id;
                    g_line_id              := mol.line_id;
                    g_orig_line_id         := mol.line_id;
                    g_line_id_change_flag  := 'Y';

                    if G_COPIED_FLAG = 'Y' and mol.original_system_line_reference is not null then
                          G_COPIED_LINE_FLAG := 'Y';
                    end if;
               end if;

                if G_AUTO_FLAG = 'Y' then
                    g_line_rec.source_document_type_id := 5;
                elsif G_COPIED_LINE_FLAG = 'Y' then
                    g_line_rec.source_document_type_id := 2;
                elsif G_ORDER_SOURCE_ID in (1,3,4,7,8) then
                    g_line_rec.source_document_type_id := g_order_source_id;
                else
                    g_line_rec.source_document_type_id := NULL;
                end if;

               if nvl(mol.included_item_flag,'-') = 'Y' then
                    g_line_rec.link_to_line_id := g_orig_line_id;
                    g_line_rec.parent_line_id  := g_orig_line_id;
                    g_line_rec.item_type_code  := 'INCLUDED';
               elsif nvl(mol.configuration_item_flag,'-') = 'Y' then
                    g_line_rec.link_to_line_id := g_orig_line_id;
                    g_line_rec.parent_line_id  := g_orig_line_id;
                    g_line_rec.ato_line_id     := g_orig_line_id;
                    g_line_rec.item_type_code  := 'CONFIG';
               elsif ((mol.line_id <> mol.parent_line_id) AND
                     (mol.item_type_code = 'MODEL')) THEN
                    g_line_rec.link_to_line_id := mol.link_to_line_id;
                    g_line_rec.parent_line_id  := mol.parent_line_id;
                    g_line_rec.ato_line_id     := mol.ato_line_id;
                    g_line_rec.item_type_code  := 'CLASS';
               else
                    g_line_rec.link_to_line_id := mol.link_to_line_id;
                    g_line_rec.parent_line_id  := mol.parent_line_id;
                    g_line_rec.ato_line_id     := mol.ato_line_id;
                    g_line_rec.item_type_code  := mol.item_type_code;
               end if;

               if g_line_rec.item_type_code = 'SERVICE' then
                    g_line_rec.top_model_line_id    := null;
               else
                    g_line_rec.top_model_line_id    := g_line_rec.parent_line_id;
               end if;

               g_Last_Line_Number := g_Last_Line_Number + 1;

               /* Initializing temporary variables */

               v_ins_return_quantity    := NULL;
               v_avl_return_quantity    := NULL;
               v_bal_return_quantity    := NULL;
               v_return_new_line_id     := NULL;
               v_return_new_line_number := NULL;
               v_reference_line_id      := NULL;
               v_reference_header_id    := NULL;
               v_return_lctr            := NULL;
               v_return_created_line_id := NULL;
               v_line_exit_flag         := NULL;
               G_log_rec.comments       := NULL;


               v_ins_return_quantity := g_line_rec.ordered_quantity;
               v_avl_return_quantity := 0;

               if  g_line_rec.line_type_code = 'RETURN' THEN
                   v_bal_return_quantity := g_line_rec.ordered_quantity;
                   begin
                        select received_quantity into v_received_quantity
                        from mtl_so_rma_interface
                        where mol.line_id = rma_line_id;

                        if v_received_quantity = 0 THEN
                              v_received_quantity := NULL;
                        end if;
                   exception
                        when no_data_found then
                             v_received_quantity := null;
                        when others then
                             v_received_quantity := null;
                   end;

                   if g_line_rec.return_reference_type_code is not null
                      and g_line_rec.return_reference_type_code = 'INVOICE' then
                       begin
                            select
                                 customer_trx_id
                            into
                                 v_customer_trx_id
                            from
                                 RA_CUSTOMER_TRX_LINES
                            where customer_trx_line_id = g_line_rec.return_reference_id
                            and ( interface_line_attribute6 is null or
                                  interface_line_attribute6 between
                                       '000000000000000' and '999999999999999');
                       exception
                            when no_data_found then
                                 v_customer_trx_id     := NULL;
                       end;
                   end if;

                   v_reference_line_id := mol.link_to_line_id;

                   if v_reference_line_id is not null then
                      begin
                         select header_id into v_reference_header_id
                         from so_lines_all
					where line_id = v_reference_line_id;
                      exception
                         when others then
                              null;
                      end;
			    end if;

               else
                   v_bal_return_quantity := 0;
                   v_reference_line_id   := NULL;
               end if;

/*
               v_actual_ordered_quantity := nvl(mol.ordered_quantity,0) -
                           nvl(mol.cancelled_quantity,0);
*/
               v_actual_ordered_quantity := nvl(mol.ordered_quantity,0) ;

               if g_hdr_canc_flag = 'Y' or mol.line_cancel_flag = 'Y' then
                    g_line_rec.ordered_quantity := 0;
               else
                    g_line_rec.ordered_quantity := mol.ordered_quantity;
               end if;

               G_ERROR_LOCATION := 707;

               v_line_exit_flag := 0;
               v_return_lctr    := 1;
               r_lctr           := 1;

               loop
                    /* v_return_lctr := v_return_lctr + 1; */

                    if g_line_rec.line_type_code = 'RETURN'  THEN

				    if g_line_rec.return_reference_type_code is not null then

                          if r_lctr = 1 then
					    begin
                                Select item_type_code, ato_flag,option_flag
                                into r_original_item_type_code,
							r_ato_flag,r_option_flag
                                from so_lines_all
                                where line_id = mol.link_to_line_id;
                             exception
                                     when others then
                                        null;
					    end;


                             if r_original_item_type_code = 'MODEL' and
                                r_ato_flag = 'Y' then
                                 r_ato_model := TRUE;
                                 r_upgraded_flag := 'P';
                             end if;

                             if r_option_flag = 'Y' and
                                r_ato_flag = 'Y' then
                                 r_ato_option := TRUE;
                                 r_upgraded_flag := 'P';
                             end if;

                             if r_ato_flag = 'N'  and
                                r_original_item_type_code in
                                  ('MODEL','KIT','CLASS') then
                                 r_pto_m_c_k := TRUE;
                                 r_upgraded_flag := 'P';
                             end if;

                             if r_ato_model then
                                  begin
                                       Select
                                           inventory_item_id,
                                           unit_code,
                                           warehouse_id
                                       into
                                           r_inventory_item_id_2,
                                           r_uom_code_2,
                                           r_warehouse_id_2
                                       from so_line_details
                                       where configuration_item_flag = 'Y'
                                       and line_id = mol.link_to_line_id;
                                  exception
                                       when others then
					               r_no_config_item := TRUE;
                                  end;
                             end if; /* ato model */
                            end if; /* r_lctr = 1 */
                         end if; /* reference_type_code is not null */

                         if  v_received_quantity is not NULL and
                           v_actual_ordered_quantity > v_received_quantity THEN

                               If  v_return_lctr = 1  then
                                   IF not (r_ato_model or r_ato_option or r_pto_m_c_k) THEN
                                    g_line_rec.shipped_quantity := v_received_quantity;
                                    g_line_rec.ordered_quantity :=  v_received_quantity;
                                         v_return_lctr := 2;
                                    ELSIF r_ato_option or r_no_config_item  or r_pto_m_c_k THEN
                                    g_line_rec.shipped_quantity := v_received_quantity;
                                    v_line_exit_flag := 1;
							 ELSE /* it is a model */
                                    g_line_rec.shipped_quantity := v_received_quantity;
                                         v_return_lctr := 3;
                                    END IF;
                               elsif v_return_lctr = 2 then
                                    g_line_rec.shipped_quantity := null;
                                    g_line_rec.ordered_quantity :=
                                         nvl(v_actual_ordered_quantity,0) - nvl(v_received_quantity,0);
                                    g_line_rec.cancelled_quantity := null;
                                    g_line_rec.fulfilled_quantity := null;
                                    g_line_rec.invoiced_quantity := null;
							 r_shipment_number := 2;
                                    v_return_lctr := 5;
                                    v_line_exit_flag := 1;
                               elsif v_return_lctr in (3,4) then
                                     r_inventory_item_id := r_inventory_item_id_2;
                                     r_uom_code := r_uom_code_2;
                                     r_warehouse_id := r_warehouse_id_2;
                                     IF v_return_lctr = 3 Then
                                         g_line_rec.shipped_quantity := v_received_quantity;
                                         g_line_rec.ordered_quantity :=  v_received_quantity;
                                         v_return_lctr := 4;
                                     ELSIF v_return_lctr = 4 Then
                                         g_line_rec.shipped_quantity := null;
                                         g_line_rec.ordered_quantity :=
                                              nvl(v_actual_ordered_quantity,0) - nvl(v_received_quantity,0);
                                         g_line_rec.cancelled_quantity := null;
                                         g_line_rec.fulfilled_quantity := null;
                                         g_line_rec.invoiced_quantity := null;
                                         r_shipment_number := 2;
                                         v_return_lctr := 5;
                                         v_line_exit_flag := 1;
                                     END IF;
                               end if;
                         else
                               IF (not r_ato_model) or r_ato_option
                                 or r_no_config_item or r_pto_m_c_k then
                                     v_line_exit_flag := 1;
                               ELSIF v_return_lctr = 3 THEN
                                     r_inventory_item_id := r_inventory_item_id_2;
                                     r_uom_code := r_uom_code_2;
                                     r_warehouse_id := r_warehouse_id_2;
                                     v_return_lctr := 4;
                                     v_line_exit_flag := 1;
                               ELSE
                                     v_return_lctr := 3;
                               END IF;
                         end if;

                         IF (v_received_quantity is not null and
						v_actual_ordered_quantity > v_received_quantity)
				      AND v_return_lctr in (2,4) THEN
                              select oe_sets_s.nextval
                              into r_line_set_id from dual;
                              -- Also Insert into oe_sets
               			insert into oe_sets
               			(
                    			SET_ID,
                    			SET_NAME,
                    			SET_TYPE,
                    			HEADER_ID,
                    			SHIP_FROM_ORG_ID,
                    			SHIP_TO_ORG_ID,
                    			SCHEDULE_SHIP_DATE,
                    			SCHEDULE_ARRIVAL_DATE,
                    			FREIGHT_CARRIER_CODE,
                    			SHIPPING_METHOD_CODE,
                    			SHIPMENT_PRIORITY_CODE,
                    			SET_STATUS,
                    			CREATED_BY,
                    			CREATION_DATE,
                    			UPDATED_BY,
                    			UPDATE_DATE,
                    			UPDATE_LOGIN,
                    			INVENTORY_ITEM_ID,
                    			ORDERED_QUANTITY_UOM,
                    			LINE_TYPE_ID,
                    			SHIP_TOLERANCE_ABOVE,
                    			SHIP_TOLERANCE_BELOW
               			)
               			values
               			(
                    			r_line_set_id,          /* SET_ID, */
                    			to_char(r_line_set_id), /* SET_NAME, */
                    			'LINE_SET',             /* SET_TYPE, */
                    			g_line_rec.header_id,   /* HEADER_ID,*/
                    			null,                   /* SHIP_FROM_ORG_ID, */
                    			null,                   /* SHIP_TO_ORG_ID, */
                    			null,                   /* SCHEDULE_SHIP_DATE, */
                    			null,                   /* SCHEDULE_ARRIVAL_DATE, */
                    			null,                   /* FREIGHT_CARRIER_CODE, */
                    			null,                   /* SHIPPING_METHOD_CODE, */
                    			null,                   /* SHIPMENT_PRIORITY_CODE, */
                    			null,                   /* SET_STATUS, */
                    			0,                      /* CREATED_BY, */
                    			sysdate,                /* CREATION_DATE, */
                    			0,                      /* UPDATED_BY, */
                    			sysdate,                /* UPDATE_DATE, */
                    			0,                      /* UPDATE_LOGIN, */
                    			null,                   /* INVENTORY_ITEM_ID, */
                    			null,                   /* ORDERED_QUANTITY_UOM,*/
                    			null,                   /* LINE_TYPE_ID, */
                    			null,                   /* SHIP_TOLERANCE_ABOVE,*/
                    			null                    /* SHIP_TOLERANCE_BELOW */
               			);
                         END IF;

					IF v_return_lctr = 4 THEN
						g_last_line_number := g_last_line_number +1;
                         END IF;
                    else
                         v_line_exit_flag := 1;
                    end if;  /* line_type_code = 'RETURN' */

                    if G_AUTO_FLAG = 'Y' then
                         begin
                              select
                                    H.schedule_type_ext,
                                    L.header_id,
                                    L.line_id
                              into
                                    g_line_rec.rla_schedule_type_code,
                                    g_line_rec.source_document_id,
                                    g_line_rec.source_document_line_id
                              from
                                    RLM_SCHEDULE_LINES_ALL   L,
                                    RLM_SCHEDULE_HEADERS_ALL H
                              where   to_char(mol.demand_stream_id)  = L.ITEM_DETAIL_REF_VALUE_3
                              and     L.Header_id                    = H.Header_id
                              and     L.ITEM_DETAIL_REF_CODE_3       = 'ID';
                         exception
                              when no_data_found then
                                    g_line_rec.rla_schedule_type_code := NULL;
                                    g_line_rec.source_document_id     := NUll;
                                    g_line_rec.source_document_line_id:= NUll;
                              when too_many_rows then
                                    g_line_rec.rla_schedule_type_code := NULL;
                                    g_line_rec.source_document_id     := NULL;
                                    g_line_rec.source_document_line_id:= NULL;
                              when others then
                                    NULL;
                         end;
                    else
                         g_line_rec.rla_schedule_type_code := NULL;
					if G_COPIED_LINE_FLAG = 'Y' then
                              g_line_rec.source_document_id := G_SOURCE_DOCUMENT_ID;
                              g_line_rec.source_document_line_id := g_line_rec.original_system_line_reference;
                         else
                              g_line_rec.source_document_id := NULL;
                              g_line_rec.source_document_line_id:= NULL;
                         end if;
                    end if;

                    G_ERROR_LOCATION := 708;

                    begin
                         select
                               nvl(decode(G_ORDER_CATEGORY_CODE,
                                      'ORDER',DEFAULT_OUTBOUND_LINE_TYPE_ID,
							   'RETURN',DEFAULT_INBOUND_LINE_TYPE_ID,0),0)
                         into
                               g_line_rec.line_type_id
                         from
                               oe_transaction_types_all tta
                         where tta.transaction_type_id = G_ORDER_TYPE_ID;
                    exception
                         when others then
                              g_line_rec.line_type_id := 0;
                    end;

                    if r_lctr > 1 then
                         select
                              oe_order_lines_s.nextval
                         into
                              v_return_created_line_id
                         from dual;
				end if;

                    if r_lctr = 1 then
                         g_line_id := g_line_id;
                    else
                         g_line_id := v_return_created_line_id;
                    end if;

                    if nvl(g_line_rec.invoiced_quantity,0) = nvl(g_line_rec.ordered_quantity,0) and
                               mol.s5 = 5 then
                         g_line_rec.invoice_interface_status_code := 'YES';
                    else
                         g_line_rec.invoice_interface_status_code := mol.invoice_interface_status_code;
                    end if;

                    /* Record insertion into Order Lines table */

                    insert into  oe_order_lines_all
                    (
                         line_id,
                         org_id,
                         header_id,
                         line_type_id,
                         line_number,
                         ordered_item,
                         request_date,
                         promise_date,
                         schedule_ship_date,
                         order_quantity_uom,
                         pricing_quantity,
                         pricing_quantity_uom,
                         cancelled_quantity,
                         shipped_quantity,
                         ordered_quantity,
                         fulfilled_quantity,
                         shipping_quantity,
                         shipping_quantity_uom,
                         delivery_lead_time,
                         tax_exempt_flag,
                         tax_exempt_number,
                         tax_exempt_reason_code,
                         ship_from_org_id,
                         ship_to_org_id,
                         invoice_to_org_id,
                         deliver_to_org_id,
                         ship_to_contact_id,
                         deliver_to_contact_id,
                         invoice_to_contact_id,
                         sold_to_org_id,
                         cust_po_number,
                         ship_tolerance_above,
                         ship_tolerance_below,
                         demand_bucket_type_code,
                         veh_cus_item_cum_key_id,
                         rla_schedule_type_code,
                         customer_dock_code,
                         customer_job,
                         customer_production_line,
                         cust_model_serial_number,
                         project_id,
                         task_id,
                         inventory_item_id,
                         tax_date,
                         tax_code,
                         tax_rate,
                         demand_class_code,
                         price_list_id,
                         pricing_date,
                         shipment_number,
                         agreement_id,
                         shipment_priority_code,
                         shipping_method_code,
                         freight_carrier_code,
                         freight_terms_code,
                         fob_point_code,
                         tax_point_code,
                         payment_term_id,
                         invoicing_rule_id,
                         accounting_rule_id,
                         source_document_type_id,
                         orig_sys_document_ref,
                         source_document_id,
                         orig_sys_line_ref,
                         source_document_line_id,
                         reference_line_id,
                         reference_type,
                         reference_header_id,
                         item_revision,
                         unit_selling_price,
                         unit_list_price,
                         tax_value,
                         context,
                         attribute1,
                         attribute2,
                         attribute3,
                         attribute4,
                         attribute5,
                         attribute6,
                         attribute7,
                         attribute8,
                         attribute9,
                         attribute10,
                         attribute11,
                         attribute12,
                         attribute13,
                         attribute14,
                         attribute15,
                         global_attribute_category,
                         global_attribute1,
                         global_attribute2,
                         global_attribute3,
                         global_attribute4,
                         global_attribute5,
                         global_attribute6,
                         global_attribute7,
                         global_attribute8,
                         global_attribute9,
                         global_attribute10,
                         global_attribute11,
                         global_attribute12,
                         global_attribute13,
                         global_attribute14,
                         global_attribute15,
                         global_attribute16,
                         global_attribute17,
                         global_attribute18,
                         global_attribute19,
                         global_attribute20,
                         pricing_context,
                         pricing_attribute1,
                         pricing_attribute2,
                         pricing_attribute3,
                         pricing_attribute4,
                         pricing_attribute5,
                         pricing_attribute6,
                         pricing_attribute7,
                         pricing_attribute8,
                         pricing_attribute9,
                         pricing_attribute10,
                         industry_context,
                         industry_attribute1,
                         industry_attribute2,
                         industry_attribute3,
                         industry_attribute4,
                         industry_attribute5,
                         industry_attribute6,
                         industry_attribute7,
                         industry_attribute8,
                         industry_attribute9,
                         industry_attribute10,
                         industry_attribute11,
                         industry_attribute12,
                         industry_attribute13,
                         industry_attribute14,
                         industry_attribute15,
                         industry_attribute16,
                         industry_attribute17,
                         industry_attribute18,
                         industry_attribute19,
                         industry_attribute20,
                         industry_attribute21,
                         industry_attribute22,
                         industry_attribute23,
                         industry_attribute24,
                         industry_attribute25,
                         industry_attribute26,
                         industry_attribute27,
                         industry_attribute28,
                         industry_attribute29,
                         industry_attribute30,
                         creation_date,
                         created_by,
                         last_update_date,
                         last_updated_by,
                         last_update_login,
                         program_application_id,
                         program_id,
                         program_update_date,
                         request_id,
                         top_model_line_id,
                         link_to_line_id,
                         component_sequence_id,
                         component_code,
                         config_display_sequence,
                         sort_order,
                         item_type_code,
                         option_number,
                         option_flag,
                         dep_plan_required_flag,
                         visible_demand_flag,
                         line_category_code,
                         actual_shipment_date,
                         customer_trx_line_id,
                         return_context,
                         return_attribute1,
                         return_attribute2,
                         return_attribute3,
                         return_attribute4,
                         return_attribute5,
                         return_attribute6,
                         return_attribute7,
                         return_attribute8,
                         return_attribute9,
                         return_attribute10,
                         return_attribute11,
                         return_attribute12,
                         return_attribute13,
                         return_attribute14,
                         return_attribute15,
                         intmed_ship_to_org_id,
                         intmed_ship_to_contact_id,
                         actual_arrival_date,
                         ato_line_id,
                         auto_selected_quantity,
                         component_number,
                         earliest_acceptable_date,
                         explosion_date,
                         latest_acceptable_date,
                         model_group_number,
                         schedule_arrival_date,
                         ship_model_complete_flag,
                         schedule_status_code,
                         return_reason_code,
                         salesrep_id,
                         split_from_line_id,
                         cust_production_seq_num,
                         authorized_to_ship_flag,
                         invoice_interface_status_code,
                         ship_set_id,
                         arrival_set_id,
                         over_ship_reason_code,
                         over_ship_resolved_flag,
                         shipping_interfaced_flag,
                         ordered_item_id,
                         item_identifier_type,
                         configuration_id,
                         credit_invoice_line_id,
                         source_type_code,
                         planning_priority,
                         open_flag,
                         booked_flag,
                         fulfilled_flag,
                         service_txn_reason_code,
                         service_txn_comments,
                         service_duration,
                         service_start_date,
                         service_end_date,
                         service_coterminate_flag,
                         unit_selling_percent,
                         unit_list_percent,
                         unit_percent_base_price,
                         service_number,
                         service_period,
                         order_source_id,
                         tp_context,
                         tp_attribute1,
                         tp_attribute2,
                         tp_attribute3,
                         tp_attribute4,
                         tp_attribute5,
                         tp_attribute6,
                         tp_attribute7,
                         tp_attribute8,
                         tp_attribute9,
                         tp_attribute10,
                         tp_attribute11,
                         tp_attribute12,
                         tp_attribute13,
                         tp_attribute14,
                         tp_attribute15,
                         flow_status_code,
                         re_source_flag,
                         service_reference_type_Code,
                         service_reference_line_id,
                         service_reference_system_id,
                         calculate_price_flag,
                         marketing_source_code_id,
                         shippable_flag,
                         fulfillment_method_code,
                         revenue_amount,
                         fulfillment_date,
                         cancelled_flag,
                         sold_from_org_id,
                         commitment_id,
                         end_item_unit_number,
                         mfg_component_sequence_id,
                         config_header_id,
                         config_rev_nbr,
                         packing_instructions,
                         shipping_instructions,
                         invoiced_quantity,
                         reference_customer_trx_line_id,
                         split_by,
                         line_set_id,
                         orig_sys_shipment_ref,
                         change_sequence,
                         drop_ship_flag,
                         customer_line_number,
                         customer_shipment_number,
                         customer_item_net_price,
                         customer_payment_term_id,
                         first_ack_code,
                         last_ack_code,
                         first_ack_date,
                         last_ack_date,
                         model_remnant_flag,
                         upgraded_flag
                    )
                    values
                    (
					g_line_id,                              /* LINE_ID */
                         g_line_rec.org_id,                      /* ORG_ID */
                         g_line_rec.header_id,                   /* HEADER_ID */
                         g_line_rec.line_type_id,                /* LINE_TYPE_ID, */
                         g_line_rec.line_number,                 /* LINE_NUMBER */
--                         g_last_line_number,                     /* LINE_NUMBER */
                         null,                                   /* ordered_item, */
                         g_line_rec.date_requested_current,      /* REQUEST_DATE */
                         g_line_rec.promise_date,                /* PROMISE_DATE */
                         g_line_rec.schedule_date,               /* SCHEDULE_SHIP_DATE */
                         nvl(r_uom_code,g_line_rec.unit_code),   /* ORDER_QUANTITY_UOM */
                         g_line_rec.ordered_quantity,            /* PRICING_QUANTITY */
                         nvl(r_uom_code,g_line_rec.unit_code),   /* PRICING_QUANTITY_UOM */
                         decode(g_hdr_canc_flag,'Y', g_line_rec.cancelled_quantity,
                           decode(g_line_id_Change_flag,'Y',
                             g_line_rec.cancelled_quantity,0)),  /* CANCELLED_QUANTITY */
                         g_line_rec.shipped_quantity,            /* SHIPPED_QUANTITY */
                         decode(g_hdr_canc_flag,'Y',0,
                            nvl(g_line_rec.ordered_quantity,0)), /* ORDERED_QUANTITY */
                         g_line_rec.fulfilled_quantity,          /* FULFILLED_QUANTITY */
                         g_line_rec.shipped_quantity,            /* SHIPPING_QUANTITY */
                         nvl(r_uom_code,
                            g_line_rec.shipping_quantity_uom),   /* SHIPPING_QUANTITY_UOM */
                         null,                                   /* DELIVERY_LEAD_TIME */
                         G_TAX_EXEMPT_FLAG,                      /* TAX_EXEMPT_FLAG */
                         g_line_rec.tax_exempt_number,           /* TAX_EXEMPT_NUMBER */
                         g_line_rec.tax_exempt_reason_code,      /* TAX_EXEMPT_REASON_CODE */
                         g_line_rec.warehouse_id,                /* SHIP_FROM_ORG_ID */
                         g_line_rec.ship_to_site_use_id,         /* SHIP_TO_ORG_ID */
                         G_INVOICE_TO_SITE_USE_ID,               /* INVOICE_TO_ORG_ID */
                         null,                                   /* DELIVER_TO_ORG_ID */
                         g_line_rec.ship_to_contact_id,          /* SHIP_TO_CONTACT_ID */
                         null,                                   /* DELIVER_TO_CONTACT_ID */
                         null,                                   /* INVOICE_TO_CONTACT_ID */
                         G_CUSTOMER_ID,                          /* SOLD_TO_ORG_ID */
                         decode(G_AUTO_FLAG,'Y',
                             g_line_rec.industry_attribute3,
                                    G_PURCHASE_ORDER_NUM),       /* CUST_PO_NUMBER */
                         null,                                   /* SHIP_TOLERANCE_ABOVE */
                         null,                                   /* SHIP_TOLERANCE_BELOW */
                         decode(G_AUTO_FLAG,'Y','DAY',NULL),     /* DEMAND_BUCKET_TYPE_CODE */
                         decode(G_AUTO_FLAG,'Y',-1,NULL),        /* VEH_CUS_ITEM_CUM_KEY_ID */
                         g_line_rec.rla_schedule_type_code,      /* RLA_SCHEDULE_TYPE_CODE */
                         g_line_rec.customer_dock_code,          /* CUSTOMER_DOCK_CODE */
                         g_line_rec.customer_job,                /* CUSTOMER_JOB */
                         g_line_rec.customer_production_line,    /* CUSTOMER_PRODUCTION_LINE */
                         g_line_rec.customer_model_serial_number, /* CUST_MODEL_SERIAL_NUMBER */
                         g_line_rec.project_id,                  /* PROJECT_ID */
                         g_line_rec.task_id,                     /* TASK_ID	 */
                         nvl(r_inventory_item_id,g_line_rec.inventory_item_id),  /* INVENTORY_ITEM_ID */
                         null,                                   /* TAX_DATE */
                         g_line_rec.tax_code,                    /* TAX_CODE */
                         null,                                   /* TAX_RATE */
                         g_line_rec.demand_class_code,           /* DEMAND_CLASS_CODE */
                         g_line_rec.price_list_id,               /* PRICE_LIST_ID */
                         null,                                   /* PRICING_DATE */
                         r_shipment_number,                      /* SHIPMENT_NUMBER */
                         g_line_rec.agreement_id,                /* AGREEMENT_ID */
                         g_line_rec.shipment_priority_code,      /* SHIPMENT_PRIORITY_CODE */
                         null,                                   /* SHIPPPING_METHOD_CODE */
                         g_line_rec.ship_method_code,            /* FREIGHT_CARRIER_CODE */
                         G_freight_terms_code,                   /* FREIGHT_TERMS_CODE */
                         null,                                   /* FOB_POINT_CODE */
                         'INVOICE',                              /* TAX_POINT_CODE */
                         G_terms_id,                             /* PAYMENT_TERM_ID */
                         nvl(g_line_rec.invoicing_rule_id,0),    /* INVOICING_RULE_ID */
                         nvl(g_line_rec.accounting_rule_id,0),   /* ACCOUNTING_RULE_ID */
                         g_line_rec.source_document_type_id,     /* SOURCE_DOCUMENT_TYPE_ID */
                         G_ORIG_SYS_DOCUMENT_REF,                /* ORIG_SYS_DOCUMENT_REF */
                         g_line_rec.source_document_id,          /* SOURCE_DOCUMENT_ID */
                         g_line_rec.original_system_line_reference, /* ORIG_SYS_LINE_REFERENCE */
                         g_line_rec.source_document_line_id,     /* SOURCE_DOCUMENT_LINE_ID */
                         v_reference_line_id,                    /* REFERENCE_LINE_ID */
                         g_line_rec.return_reference_type_code,  /* REFERENCE_TYPE */
                         v_reference_header_id,                  /* REFERENCE_HEADER_ID */
                         null,                                   /* ITEM_REVISION */
                         g_line_rec.selling_price,               /* SELLING_PRICE */
                         g_line_rec.list_price,                  /* LIST_PRICE */
                         null,                                   /* TAX_VALUE */
                         g_line_rec.context,                     /* CONTEXT */
                         g_line_rec.attribute1,                  /* ATTRIBUTE1 */
                         g_line_rec.attribute2,                  /* ATTRIBUTE2 */
                         g_line_rec.attribute3,                  /* ATTRIBUTE3 */
                         g_line_rec.attribute4,                  /* ATTRIBUTE4 */
                         g_line_rec.attribute5,                  /* ATTRIBUTE5 */
                         g_line_rec.attribute6,                  /* ATTRIBUTE6 */
                         g_line_rec.attribute7,                  /* ATTRIBUTE7 */
                         g_line_rec.attribute8,                  /* ATTRIBUTE8 */
                         g_line_rec.attribute9,                  /* ATTRIBUTE9 */
                         g_line_rec.attribute10,                 /* ATTRIBUTE10 */
                         g_line_rec.attribute11,                 /* ATTRIBUTE11 */
                         g_line_rec.attribute12,                 /* ATTRIBUTE12 */
                         g_line_rec.attribute13,                 /* ATTRIBUTE13 */
                         g_line_rec.attribute14,                 /* ATTRIBUTE14 */
                         g_line_rec.attribute15,                 /* ATTRIBUTE15 */
                         g_line_rec.global_attribute_category,   /* GLOBAL_ATTRIBUTE_CATEGORY */
                         g_line_rec.global_attribute1,           /* GLOBAL_ATTRIBUTE1 */
                         g_line_rec.global_attribute2,           /* GLOBAL_ATTRIBUTE2 */
                         g_line_rec.global_attribute3,           /* GLOBAL_ATTRIBUTE3 */
                         g_line_rec.global_attribute4,           /* GLOBAL_ATTRIBUTE4 */
                         g_line_rec.global_attribute5,           /* GLOBAL_ATTRIBUTE5 */
                         g_line_rec.global_attribute6,           /* GLOBAL_ATTRIBUTE6 */
                         g_line_rec.global_attribute7,           /* GLOBAL_ATTRIBUTE7 */
                         g_line_rec.global_attribute8,           /* GLOBAL_ATTRIBUTE8 */
                         g_line_rec.global_attribute9,           /* GLOBAL_ATTRIBUTE9 */
                         g_line_rec.global_attribute10,          /* GLOBAL_ATTRIBUTE10 */
                         g_line_rec.global_attribute11,          /* GLOBAL_ATTRIBUTE11 */
                         g_line_rec.global_attribute12,          /* GLOBAL_ATTRIBUTE12 */
                         g_line_rec.global_attribute13,          /* GLOBAL_ATTRIBUTE13 */
                         g_line_rec.global_attribute14,          /* GLOBAL_ATTRIBUTE14 */
                         g_line_rec.global_attribute15,          /* GLOBAL_ATTRIBUTE15 */
                         g_line_rec.global_attribute16,          /* GLOBAL_ATTRIBUTE16 */
                         g_line_rec.global_attribute17,          /* GLOBAL_ATTRIBUTE17 */
                         g_line_rec.global_attribute18,          /* GLOBAL_ATTRIBUTE18 */
                         g_line_rec.global_attribute19,          /* GLOBAL-ATTRIBUTE19 */
                         g_line_rec.global_attribute20,          /* GLOBAL_ATTRIBUTE20 */
                         g_line_rec.pricing_context,             /* PRICING_CONTEXT    */
                         g_line_rec.pricing_attribute1,          /* PRICING_ATTRIBUTE1 */
                         g_line_rec.pricing_attribute2,          /* PRICING_ATTRIBUTE2 */
                         g_line_rec.pricing_attribute3,          /* PRICING_ATTRIBUTE3 */
                         g_line_rec.pricing_attribute4,          /* PRICING_ATTRIBUTE4 */
                         g_line_rec.pricing_attribute5,          /* PRICING_ATTRIBUTE5 */
                         g_line_rec.pricing_attribute6,          /* PRICING_ATTRIBUTE6 */
                         g_line_rec.pricing_attribute7,          /* PRICING_ATTRIBUTE7 */
                         g_line_rec.pricing_attribute8,          /* PRICING_ATTRIBUTE8 */
                         g_line_rec.pricing_attribute9,          /* PRICING_ATTRIBUTE9 */
                         g_line_rec.pricing_attribute10,         /* PRICING_ATTRIBUTE10*/
                         g_line_rec.industry_context,            /* INDUSTRY_CONTEXT   */
                         g_line_rec.industry_attribute1,         /* INDUSTRY_ATTRIBUTE1 */
                         decode(g_auto_Flag,'Y',
                             NULL,g_line_rec.industry_attribute2),  /* INDUSTRY_ATTRIBUTE2 */
                         decode(g_auto_Flag,'Y',
                             NULL,g_line_rec.industry_attribute3),  /* INDUSTRY_ATTRIBUTE3 */
                         decode(g_auto_Flag,'Y',
                             NULL,g_line_rec.industry_attribute4),  /* INDUSTRY_ATTRIBUTE4 */
                         decode(g_auto_Flag,'Y',
                             NULL,g_line_rec.industry_attribute5),  /* INDUSTRY_ATTRIBUTE5 */
                         decode(g_auto_Flag,'Y',
                             NULL,g_line_rec.industry_attribute6),  /* INDUSTRY_ATTRIBUTE6 */
                         decode(g_auto_Flag,'Y',
                             NULL,g_line_rec.industry_attribute7),  /* INDUSTRY_ATTRIBUTE7 */
                         decode(g_auto_Flag,'Y',
                             NULL,g_line_rec.industry_attribute8),  /* INDUSTRY_ATTRIBUTE8 */
                         decode(g_auto_Flag,'Y',
                             NULL,g_line_rec.industry_attribute9),  /* INDUSTRY_ATTRIBUTE9 */
                         decode(g_auto_Flag,'Y',
                             NULL,g_line_rec.industry_attribute10), /* INDUSTRY_ATTRIBUTE10 */
                         decode(g_auto_Flag,'Y',
                             NULL,g_line_rec.industry_attribute11), /* INDUSTRY_ATTRIBUTE11 */
                         decode(g_auto_Flag,'Y',
                             NULL,g_line_rec.industry_attribute12), /* INDUSTRY_ATTRIBUTE12 */
                         decode(g_auto_Flag,'Y',
                             NULL,g_line_rec.industry_attribute13), /* INDUSTRY_ATTRIBUTE13 */
                         decode(g_auto_Flag,'Y',
                             NULL,g_line_rec.industry_attribute14), /* INDUSTRY_ATTRIBUTE14 */
                         decode(g_auto_Flag,'Y',
                             NULL,g_line_rec.industry_attribute15), /* INDUSTRY_ATTRIBUTE15 */
                         NULL,                                   /* INDUSTRY_ATTRIBUTE16 */
                         NULL,                                   /* INDUSTRY_ATTRIBUTE17 */
                         NULL,                                   /* INDUSTRY_ATTRIBUTE18 */
                         NULL,                                   /* INDUSTRY_ATTRIBUTE19 */
                         NULL,                                   /* INDUSTRY_ATTRIBUTE20 */
                         NULL,                                   /* INDUSTRY_ATTRIBUTE21 */
                         NULL,                                   /* INDUSTRY_ATTRIBUTE22 */
                         NULL,                                   /* INDUSTRY_ATTRIBUTE23 */
                         NULL,                                   /* INDUSTRY_ATTRIBUTE24 */
                         NULL,                                   /* INDUSTRY_ATTRIBUTE25 */
                         NULL,                                   /* INDUSTRY_ATTRIBUTE26 */
                         NULL,                                   /* INDUSTRY_ATTRIBUTE27 */
                         NULL,                                   /* INDUSTRY_ATTRIBUTE28 */
                         NULL,                                   /* INDUSTRY_ATTRIBUTE29 */
                         NULL,                                   /* INDUSTRY_ATTRIBUTE30 */
                         g_line_rec.creation_date,               /* CREATION_DATE */
                         g_line_rec.created_by,	               /* CREATED_BY */
                         g_line_rec.last_update_date,            /* LAST_UPDATE_DATE */
                         g_line_rec.last_updated_by,             /* LAST_UPDATED_BY */
                         g_line_rec.last_update_login,           /* LAST_UPDATE_LOGIN */
                         nvl(g_line_rec.program_application_id,0), /* PROGRAM_APPLICATION_ID */
                         g_line_rec.program_id,                  /* PROGRAM_ID */
                         g_line_rec.program_update_date,         /* PROGRAM_UPDATE_DATE */
                         g_line_rec.request_id,                  /* REQUEST_ID */
                         g_line_rec.top_model_line_id,           /* TOP_MODEL_LINE_ID */
                         g_line_rec.link_to_line_id,             /* LINK_TO_LINE_ID */
                         g_line_rec.component_sequence_id,       /* COMPONENT_SEQUENCE_ID */
                         g_line_rec.component_code,              /* COMPONENT_CODE */
                         null,                                   /* CONFIG_DISPLAY_SEQUENCE */
                         null,                                   /* SORT_ORDER, */
                         g_line_rec.item_type_code,              /* ITEM_TYPE_CODE */
                         null,                                   /* OPTION_NUMBER */
                         g_line_rec.option_flag,                 /* OPTION_FLAG, */
                         g_line_rec.dep_plan_required_flag,      /* DEP_PLAN_REQUIRED_FLAG */
                         g_line_rec.visible_demand_flag,         /* VISIBLE_DEMAND_FLAG */
                         g_line_rec.line_category_code,          /* LINE_CATEGORY_CODE */
                         g_line_rec.actual_departure_date,       /* ACTUAL_SHIPMENT_DATE */
                         decode(g_line_rec.line_type_code,'RETURN',
                               decode(g_line_rec.return_reference_type_code,
                               'INVOICE',g_line_rec.return_reference_id,NULL), NULL), /* CUSTOMER_TRX_LINE_ID */
                         g_line_rec.return_reference_type_Code,           /* RETURN_CONTEXT */
                         decode(g_line_rec.line_type_code,'RETURN',
                             decode(g_line_rec.return_reference_type_code,
                               'INVOICE',v_customer_trx_id,
                                v_reference_header_id),NULL),             /* RETURN_ATTRIBUTE1 */
                         decode(g_line_rec.line_type_code,'RETURN',
                             decode(g_line_rec.return_reference_type_code,
                              'INVOICE',g_line_rec.return_reference_id,
                                 v_reference_line_id),NULL),          /* RETURN_ATTRIBUTE2 */
                         NULL,                                        /* RETURN_ATTRIBUTE3 */
                         NULL,                                        /* RETURN_ATTRIBUTE4 */
                         null,                                   /* RETURN_ATTRIBUTE5 */
                         null,                                   /* RETURN_ATTRIBUTE6 */
                         null,                                   /* RETURN_ATTRIBUTE7 */
                         null,                                   /* RETURN_ATTRIBUTE8 */
                         null,                                   /* RETURN_ATTRIBUTE9 */
                         null,                                   /* RETURN_ATTRIBUTE10 */
                         null,                                   /* RETURN_ATTRIBUTE11 */
                         null,                                   /* RETURN_ATTRIBUTE12 */
                         null,                                   /* RETURN_ATTRIBUTE13 */
                         null,                                   /* RETURN_ATTRIBUTE14 */
                         null,                                   /* RETURN_ATTRIBUTE15 */
                         g_line_rec.intermediate_ship_to_id,     /* intmed_ship_to_org_id, */
                         g_line_rec.ship_to_contact_id,          /* intmed_ship_to_contact_id, */
                         null,                                   /* actual_arrival_date, */
                         g_line_rec.ato_line_id,                 /* ATO_LINE_ID */
                         null,                                   /* auto_selected_quantity, */
                         null,                                   /* component_number, */
                         null,                                   /* earliest_acceptable_date, */
                         g_line_rec.standard_component_freeze_date, /* explosion_date, */
                         g_line_rec.latest_acceptable_date,      /* latest_acceptable_date, */
                         null,                                   /* model_group_number, */
                         null,                                   /* schedule_arrival_date, */
                         g_line_rec.ship_model_complete_flag,    /* ship_model_complete_flag, */
                         g_line_rec.schedule_status_code,        /* schedule_status_code, */
                         g_line_rec.transaction_reason_code,     /* return_reason_code */
                         g_salesrep_id,                          /* salesrep_id */
                         null,                                   /* split_from_line_id */
                         g_line_rec.planning_prod_seq_number,    /* cust_production_seq_num */
                         decode(G_AUTO_FLAG,'Y','Y',NULL),       /* authorized_to_ship_flag */
                         g_line_rec.invoice_interface_status_code,  /* invoice_interface_status_code */
                         g_set_id,                               /* Ship_Set_Id */
                         null,                                   /* Arrival_Set_Id */
                         null,                                   /* over_ship_reason_code */
                         null,                                   /* over_ship_resolved_flag */
                         g_line_rec.shipping_interfaced_flag,    /* shipping_interfaced_flag */
                         decode(nvl(g_line_rec.customer_item_id,-1),
                                   -1,g_line_rec.inventory_item_id,
                                        g_line_rec.customer_item_id),   /* ordered_item_id */
                         decode(nvl(g_line_rec.customer_item_id,-1),
                                  -1,'INT','CUST'),              /* item_identifier_type*/
                         null,                                   /* configuration_id */
                         g_line_rec.credit_invoice_line_id,      /* credit_invoice_line_id */
                         g_line_rec.source_type_code,            /* source_type_code */
                         g_line_rec.planning_priority,           /* planning_priority */
                         g_line_rec.open_flag,                   /* open_flag */
                         g_line_rec.booked_flag,                 /* booked_flag */
                         g_line_rec.fulfilled_flag,              /* fulfilled_Flag */
                         g_line_rec.service_txn_reason_code,     /* service_txn_reason_code */
                         g_line_rec.service_txn_comments,        /* service_txn_comments */
                         g_line_rec.service_duration,            /* service_duration */
                         g_line_rec.service_start_date,          /* service_start_date */
                         g_line_rec.service_end_date,            /* service_end_date */
                         g_line_rec.service_coterminate_flag,    /* service_coterminate_flag */
                         g_line_rec.selling_percent,             /* unit_selling_percent */
                         g_line_rec.list_percent,                /* unit_list_percent */
                         g_line_rec.percent_base_price,          /* unit_percent_base_price */
                         g_line_rec.service_number,              /* service_number */
                         g_line_rec.service_period,              /* service_period */
                         nvl(G_ORDER_SOURCE_ID,0),               /* ORDER_SOURCE_ID, */
                         g_line_rec.tp_context,                  /* tp_context */
                         g_line_rec.tp_attribute1,               /* tp_attribute1 */
                         g_line_rec.tp_attribute2,               /* tp_attribute2 */
                         g_line_rec.tp_attribute3,               /* tp_attribute3 */
                         g_line_rec.tp_attribute4,               /* tp_attribute4 */
                         g_line_rec.tp_attribute5,               /* tp_attribute5 */
                         g_line_rec.tp_attribute6,               /* tp_attribute6 */
                         g_line_rec.tp_attribute7,               /* tp_attribute7 */
                         g_line_rec.tp_attribute8,               /* tp_attribute8 */
                         g_line_rec.tp_attribute9,               /* tp_attribute9 */
                         g_line_rec.tp_attribute10,              /* tp_attribute10 */
                         g_line_rec.tp_attribute11,              /* tp_attribute11 */
                         g_line_rec.tp_attribute12,              /* tp_attribute12 */
                         g_line_rec.tp_attribute13,              /* tp_attribute13 */
                         g_line_rec.tp_attribute14,              /* tp_attribute14 */
                         g_line_rec.tp_attribute15,              /* tp_attribute15 */
                         g_line_rec.flow_status_code,            /* flow_status_code */
                         g_line_rec.re_source_flag,              /* re_source_flag */
                         g_line_rec.service_reference_type_Code, /* service_reference_type_code */
                         g_line_rec.service_reference_line_id,   /* service_reference_line_id */
                         g_line_rec.service_reference_system_id, /* service_reference_system_id */
                         g_line_rec.calculate_price_flag,        /* calculate_price_flag */
                         g_line_rec.marketing_source_code_id,    /* marketing_source_code_id */
                         g_line_rec.shippable_flag,              /* shippable_flag */
                         g_line_rec.fulfillment_method_code,     /* fulfillment_method_code */
                         g_line_rec.revenue_amount,              /* revenue_amount */
                         g_line_rec.fulfillment_date,            /* fulfillment_date */
                         g_line_rec.cancelled_flag,              /* cancelled_flag */
                         g_line_rec.org_id,                      /* sold_from_org_id */
                         null,                                   /* commitment_id */
                         null,                                   /* end_item_unit_number */
                         null,                                   /* mfg_component_sequence_id */
                         null,                                   /* config_header_id */
                         null,                                   /* config_rev_nbr */
                         null,                                   /* packing_instructions */
                         null,                                   /* shipping_instructions */
                         g_line_rec.invoiced_quantity,           /* invoiced_quantity */
                         null,                                   /* reference_customer_trx_line_id */
                         null,                                   /* split_by */
                         nvl(r_line_set_id,null),                /* line_set_id */
                         null,                                   /* orig_sys_shipment_ref */
                         null,                                   /* change_sequence */
                         null,                                   /* drop_ship_flag */
                         null,                                   /* customer_line_number */
                         null,                                   /* customer_shipment_number */
                         null,                                   /* customer_item_net_price */
                         null,                                   /* customer_payment_term_id */
                         null,                                   /* first_ack_code */
                         null,                                   /* last_ack_code */
                         null,                                   /* first_ack_date */
                         null,                                   /* last_ack_date */
                         null,                                   /* model_remnant_flag */
                         nvl(r_upgraded_flag,'Y')                /* upgraded_flag */
                     );

                     r_lctr := r_lctr + 1;

                     G_ERROR_LOCATION := 709;

                     G_Log_Rec.Header_Id          := g_header_id;
                     G_Log_Rec.Old_Line_Id        := mol.line_id;
                     G_Log_Rec.picking_Line_Id    := mol.picking_line_id;
                     G_Log_Rec.Old_Line_Detail_id := mol.line_detail_id;
                     G_Log_Rec.Delivery           := mol.Delivery;

                     G_Log_Rec.New_Line_ID        := g_line_id;    -- 2/24/2000
                     g_log_rec.return_qty_available := g_line_rec.ordered_quantity;  -- 2/24/2000

                     G_Log_Rec.New_Line_Number    := g_last_line_number;
                     G_Log_Rec.mtl_sales_order_id := g_mtl_sales_order_id;

                     OE_UPG_SO.Upgrade_Insert_Upgrade_Log;

                     g_log_rec.comments := NULL;

                     begin

                          IF v_return_lctr = 4 THEN
                               -- Update PO Tables
                               -- rcv_shipment_lines, rcv_transactions,rcv_supply
                               update rcv_shipment_lines
                               set oe_order_line_id = v_return_created_line_id
                               where oe_order_line_id = g_old_line_id;

                               update rcv_transactions
                               set oe_order_line_id = v_return_created_line_id
                               where oe_order_line_id = g_old_line_id;

                               update rcv_supply
                               set oe_order_line_id = v_return_created_line_id
                               where oe_order_line_id = g_old_line_id;
                          END IF;
                     exception
                              when others then
                                oe_upg_so.upgrade_insert_errors
                                (
                                   L_header_id => g_header_id,
                                   L_comments  => 'Updating RCV shipment failed for line :'
							   ||to_char(g_old_line_id)||' with oracle error ORA-'
                                          ||to_char(sqlcode));
                     end;

                     /* ========== Line Level Sales Credits =========== */
                     OE_Upg_SO.Upgrade_Sales_Credits
                            ( L_level_flag => 'L');

                     /* ========== Line Level Price Adjustments =========== */
                     OE_Upg_SO.Upgrade_Price_Adjustments
                           ( L_level_flag => 'L');

                     if OE_Upg_SO.G_HDR_CANC_FLAG = 'Y' then
                          G_ERROR_LOCATION := 710;
                          g_canc_rec := g_hdr_canc_rec;
                          G_ORD_CANC_FLAG := 'N';
                          OE_Upg_SO.Upgrade_Insert_Lines_History;
                     end if;

                     if v_bal_return_quantity <= 0  or v_line_exit_flag = 1 then
                           exit;
                     end if;

               end loop;   /* extra loop for returns */

               /* ========== Line Level Cancellations =========== */
/*                    if nvl(mol.cancelled_quantity,0) > 0 and OE_Upg_SO.G_HDR_CANC_FLAG <> 'Y' then */

               if g_line_id_Change_flag = 'Y' then
                    if nvl(mol.cancelled_quantity,0) > 0 then
                          OE_Upg_SO.Upgrade_Cancellations ;
                    end if;
               end if;

        end loop;   /* end loop for Order lines*/
        close ol;
        G_ERROR_LOCATION := 8;

  End Upgrade_Create_Order_Lines;

  Procedure Upgrade_Create_Order_Headers
	( L_Line_Type   IN    varchar2,
       L_Slab        IN    number  )
     is
     commit_counter  number;
     v_start_header  number;
     v_end_header    number;

       /* The oh cursor is declared to bring Order Headers details */

     cursor oh is
     select
           sha.header_id,
           sha.org_id,
           sha.order_type_id,
           sha.order_number,
           sha.credit_card_expiration_date,
           sha.original_system_source_code,
           sha.original_system_reference,
           sha.date_ordered,
           sha.date_requested_current,
           sha.shipment_priority_code,
           sha.demand_class_code,
           sha.price_list_id,
           sha.tax_exempt_flag,
           sha.tax_exempt_num tax_exempt_num,
           sha.tax_exempt_reason_code,
           sha.conversion_rate,
           sha.conversion_type_code,
           sha.conversion_date,
           sha.ship_partial_flag,
           sha.currency_code,
           sha.agreement_id,
           sha.purchase_order_num,
           sha.invoicing_rule_id,
           sha.accounting_rule_id,
           sha.terms_id,
           sha.ship_method_code,
           sha.fob_code,
           sha.freight_terms_code,
           sha.ship_to_contact_id,
           sha.invoice_to_contact_id,
           sha.creation_date,
           sha.created_by,
           sha.last_updated_by,
           sha.last_update_date,
           sha.last_update_login,
           sha.program_application_id,
           sha.program_id,
           sha.program_update_date,
           sha.request_id,
           sha.customer_id,
           sha.salesrep_id,
           sha.cancelled_flag,
           sha.context,
           sha.attribute1,
           sha.attribute2,
           sha.attribute3,
           sha.attribute4,
           sha.attribute5,
           sha.attribute6,
           sha.attribute7,
           sha.attribute8,
           sha.attribute9,
           sha.attribute10,
           sha.attribute11,
           sha.attribute12,
           sha.attribute13,
           sha.attribute14,
           sha.attribute15,
           sha.payment_type_code,
           sha.payment_amount,
           sha.check_number,
           sha.credit_card_code,
           sha.credit_card_holder_name,
           sha.credit_card_number,
           sha.credit_card_approval_code,
           shattr.global_attribute_category,
           shattr.global_attribute1,
           shattr.global_attribute2,
           shattr.global_attribute3,
           shattr.global_attribute4,
           shattr.global_attribute5,
           shattr.global_attribute6,
           shattr.global_attribute7,
           shattr.global_attribute8,
           shattr.global_attribute9,
           shattr.global_attribute10,
           shattr.global_attribute11,
           shattr.global_attribute12,
           shattr.global_attribute13,
           shattr.global_attribute14,
           shattr.global_attribute15,
           shattr.global_attribute16,
           shattr.global_attribute17,
           shattr.global_attribute18,
           shattr.global_attribute19,
           shattr.global_attribute20,
           sha.invoice_to_site_use_id,
           sha.order_category,
           sha.ordered_by_contact_id,
           sha.ship_to_site_use_id,
           sha.warehouse_id,
           nvl(sha.open_flag,'N') open_flag,
           decode(sha.s1,1,'Y','N') booked_flag,
		 sha.s1_date
       from
           so_headers_all          sha,
           so_header_attributes    shattr
       where
           sha.upgrade_flag = 'N' and
           sha.header_id = shattr.header_id(+) and
/*
           (( L_Line_type = 'R' and sha.order_category = 'RMA') or
            ( L_Line_type = 'O' and sha.order_category <> 'RMA')) and
*/
           sha.header_id between v_start_header and v_end_header
       order by
           sha.header_id;

	  v_source_code_profile_value    varchar2(100);
	  v_auto_source_code             varchar2(30);
       v_error_code                   number;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
  begin
            --  dbms_output.enable(999999999);
            G_ERROR_LOCATION := 9;
            begin
                 select
                       start_header_id,
                       end_header_id
                 into
                       v_start_header,
                       v_end_header
                 from  oe_upgrade_distribution
                 where   slab = L_slab;

/*                 where nvl(alloted_flag,'N') = 'N'
                  and   nvl(line_type,'O') = L_line_type  */

            exception
                 when no_data_found then
                     oe_upg_so.upgrade_insert_errors
                     (
                        L_header_id => 0,
                        L_comments  => 'FYI Only: Parallel process of Sales Order Upgrade not used for the slab:'||to_char(L_slab)
                     );
                     v_start_header := 0;
                     v_end_header := 0;
                     commit;
                     return;
            end;

            commit_counter := 0;

            OE_Upg_SO.g_earliest_schedule_limit :=
              to_number(FND_PROFILE.VALUE('OE_SCHEDULE_DATE_WINDOW'));

            OE_Upg_SO.g_latest_schedule_limit := OE_Upg_SO.g_earliest_schedule_limit;

            v_source_code_profile_value       := fnd_profile.value('SO_SOURCE_CODE');
            v_auto_source_code                := NULL;

            fnd_profile.get('RLA_ORDERIMPORT_SOURCE',v_auto_source_code);

            for moh in oh loop     /*  start loop for Order Headers */
               begin

                  G_Error_Alert := 'N';
                  SAVEPOINT HEADER_SAVE_POINT;

                  -- dbms_output.put_line('Inserting Header  ==============>');

                  G_LOG_Rec                := NULL;

                  G_HEADER_ID              := moh.header_id;
                  G_TAX_EXEMPT_FLAG        := moh.tax_exempt_flag;
                  G_CUSTOMER_ID            := moh.customer_id;
                  G_FREIGHT_TERMS_CODE     := moh.freight_terms_code;
                  G_SOURCE_DOCUMENT_ID     := NULL;
                  G_INVOICE_TO_SITE_USE_ID := moh.invoice_to_site_use_id;
                  G_PURCHASE_ORDER_NUM     := moh.purchase_order_num;
                  G_SALESREP_ID            := moh.salesrep_id;
                  G_CANCELLED_FLAG         := moh.cancelled_flag;
                  G_ORDER_TYPE_ID          := moh.order_type_id;
                  G_ORIG_SYS_DOCUMENT_REF  := moh.original_system_reference;

                  begin
                       select
                            decode(moh.order_category,'P','ORDER',
                                 'R','ORDER','RMA','RETURN','*')
                       into
                            G_ORDER_CATEGORY_CODE
                       from dual;
                  exception
                       when others then
                            G_ORDER_CATEGORY_CODE := NULL;
                  end;

                  begin
                        select 10 into G_ORDER_SOURCE_ID
                        from so_order_sources
                        where order_source_id = moh.original_system_source_code
                        and   name = 'Internal';
                  exception
                        when no_data_found then
                            G_ORDER_SOURCE_ID        := nvl(moh.original_system_source_code,0);
                        when others then
                            G_ORDER_SOURCE_ID        := nvl(moh.original_system_source_code,0);
                  end;

                  /* Preparing values for COPIED ORDERS */
                  G_COPIED_FLAG := 'N';

                  if moh.original_system_source_code = '2' then
                       G_SOURCE_DOCUMENT_ID := moh.original_system_reference;
                       G_COPIED_FLAG        := 'Y';
                  end if;


                  /* Setting Automotive Order Flag  */

                  if moh.original_system_source_code = v_auto_source_code then
                       G_AUTO_FLAG := 'Y';
                  else
                       G_AUTO_FLAG := 'N';
                  end if;

                  /*  Getting MTL_SALES_ORDER_ID */

                  begin
                       select
                            sales_order_id
                       into
                            G_MTL_SALES_ORDER_ID
                       from
                            mtl_sales_orders mso,
                            so_order_types_115_all sota
                       where  segment1 = to_char(moh.order_number)
                       and    segment2 = sota.name
                       and    segment3 = v_source_code_profile_value
                       and    moh.order_type_id = sota.order_type_id
                       and    rownum = 1;
                  exception
                       when no_data_found then
                            G_MTL_SALES_ORDER_ID := NULL;
                       when others then
                            G_MTL_SALES_ORDER_ID := NULL;
                  end;

                  insert into oe_order_headers_all
                  (
                       header_id,
                       org_id,
                       order_type_id,
                       order_number,
                       version_number,
                       expiration_date,
                       order_source_id,
                       source_document_type_id,
                       orig_sys_document_ref,
                       source_document_id,
                       ordered_date,
                       request_date,
                       pricing_date,
                       shipment_priority_code,
                       demand_class_code,
                       price_list_id,
                       tax_exempt_flag,
                       tax_exempt_number,
                       tax_exempt_reason_code,
                       conversion_rate,
                       conversion_type_code,
                       conversion_rate_date,
                       partial_shipments_allowed,
                       ship_tolerance_above,
                       ship_tolerance_below,
                       transactional_curr_code,
                       agreement_id,
                       tax_point_code,
                       cust_po_number,
                       invoicing_rule_id,
                       accounting_rule_id,
                       payment_term_id,
                       shipping_method_code,
                       freight_carrier_code,
                       fob_point_code,
                       freight_terms_code,
                       sold_to_org_id,
                       ship_from_org_id,
                       ship_to_org_id,
                       invoice_to_org_id,
                       deliver_to_org_id,
                       sold_to_contact_id,
                       ship_to_contact_id,
                       invoice_to_contact_id,
                       deliver_to_contact_id,
                       creation_date,
                       created_by,
                       last_updated_by,
                       last_update_date,
                       last_update_login,
                       program_application_id,
                       program_id,
                       program_update_date,
                       request_id,
                       salesrep_id,
                       return_reason_code,
                       context,
                       attribute1,
                       attribute2,
                       attribute3,
                       attribute4,
                       attribute5,
                       attribute6,
                       attribute7,
                       attribute8,
                       attribute9,
                       attribute10,
                       attribute11,
                       attribute12,
                       attribute13,
                       attribute14,
                       attribute15,
                       global_attribute_category,
                       global_attribute1,
                       global_attribute2,
                       global_attribute3,
                       global_attribute4,
                       global_attribute5,
                       global_attribute6,
                       global_attribute7,
                       global_attribute8,
                       global_attribute9,
                       global_attribute10,
                       global_attribute11,
                       global_attribute12,
                       global_attribute13,
                       global_attribute14,
                       global_attribute15,
                       global_attribute16,
                       global_attribute17,
                       global_attribute18,
                       global_attribute19,
                       global_attribute20,
                       order_date_type_code,
                       earliest_schedule_limit,
                       latest_schedule_limit,
                       payment_type_code,
                       payment_amount,
                       check_number,
                       credit_card_code,
                       credit_card_holder_name,
                       credit_card_number,
                       credit_card_expiration_date,
                       credit_card_approval_code,
                       credit_card_approval_date,
                       sales_channel_code,
                       order_category_code,
                       cancelled_flag,
                       open_flag,
                       booked_flag,
                       marketing_source_code_id,
                       tp_context,
                       tp_attribute1,
                       tp_attribute2,
                       tp_attribute3,
                       tp_attribute4,
                       tp_attribute5,
                       tp_attribute6,
                       tp_attribute7,
                       tp_attribute8,
                       tp_attribute9,
                       tp_attribute10,
                       tp_attribute11,
                       tp_attribute12,
                       tp_attribute13,
                       tp_attribute14,
                       tp_attribute15,
                       flow_status_code,
                       upgraded_flag,
                       booked_date,
                       sold_from_org_id
                  )
                  values
                  (
                       moh.header_id,                          /* HEADER_ID */
                       moh.org_id,                             /* ORG_ID */
                       moh.order_type_id,                      /* ORDER_TYPE_ID */
                       moh.order_number,                       /* ORDER_NUMBER */
                       1,                                      /* VERSION_NUMBER, */
                       NULL,                                   /* EXPIRATION_DATE, */
                       G_ORDER_SOURCE_ID,                      /* ORDER_SOURCE_ID, */
                       decode(g_copied_flag,'Y',2,NULL),       /* SOURCE_DOCUMENT_TYPE_ID, */
                       moh.original_system_reference,          /* ORIG_SYS_DOCUMENT_REF, */
                       decode(g_copied_flag,'Y',
                         g_source_document_id,NULL),           /* SOURCE_DOCUMENT_ID, */
                       moh.date_ordered,                       /* ORDERED_DATE */
                       moh.date_requested_current,             /* REQUEST_DATE */
                       null,                                   /* PRICING_DATE, */
                       moh.shipment_priority_code,             /* SHIPMENT_PRIORITY_CODE */
                       moh.demand_class_code,                  /* DEMAND_CLASS_CODE */
                       moh.price_list_id,                      /* PRICE_LIST_ID */
                       moh.tax_exempt_flag,                    /* TAX_EXEMPT_FLAG */
                       moh.tax_exempt_num,                     /* TAX_EXEMPT_NUMBER */
                       moh.tax_exempt_reason_code,             /* TAX_EXEMPT_REASON_CODE */
                       moh.conversion_rate,                    /* CONVERSION_RATE */
                       moh.conversion_type_code,               /* CONVERSION_TYPE_CODE */
                       moh.conversion_date,                    /* CONVERSION_RATE_DATE */
                       moh.ship_partial_flag,                  /* PARTIAL_SHIPMENTS_ALLOWED */
                       null,                                   /* SHIP_TOLERANCE_ABOVE, */
                       null,                                   /* SHIP_TOLERANCE_BELOW, */
                       moh.currency_code,                      /* TRANSACTIONAL_CURR_CODE */
                       moh.agreement_id,                       /* AGREEMENT_ID */
                       'INVOICE',                              /* TAX_POINT_CODE */
                       decode(G_AUTO_FLAG,'Y',
                             g_line_rec.industry_attribute3,
                                  G_PURCHASE_ORDER_NUM),       /* CUST_PO_NUMBER */
                       nvl(moh.invoicing_rule_id,0),           /* INVOICING_RULE_ID */
                       nvl(moh.accounting_rule_id,0),          /* ACCOUNTING_RULE_ID */
                       nvl(moh.terms_id,0),                    /* PAYMENT_TERM_ID */
                       moh.ship_method_code,                   /* SHIPING_METHOD_CODE */
                       null,                                   /* FREIGHT_CARRIER_CODE */
                       moh.fob_code,                           /* FOB_POINT_CODE */
                       moh.freight_terms_code,                 /* FREIGHT_TERMS_CODE */
                       G_customer_id,                          /* SOLD_TO_ORG_ID */
                       moh.warehouse_id,                       /* SHIP_FROM_ORG_ID */
                       moh.ship_to_site_use_id,                /* SHIP_TO_ORG_ID */
                       moh.invoice_to_site_use_id,             /* INVOICE_TO_ORG_ID */
                       null,                                   /* DELIVER_TO_ORG_ID */
                       moh.ordered_by_contact_id,              /* SOLD_TO_CONTACT_ID */
                       moh.ship_to_contact_id,                 /* SHIP_TO_CONTACT_ID */
                       moh.invoice_to_contact_id,              /* INVOICE_TO_CONTACT_ID */
                       null,                                   /* DELIVER_TO_CONTACT_ID */
                       moh.creation_date,                      /* CREATION_DATE */
                       moh.created_by,                         /* CREATED_BY */
                       moh.last_updated_by,                    /* LAST_UPDATED_BY */
                       moh.last_update_date,                   /* LAST_UPDATE_DATE */
                       moh.last_update_login,                  /* LAST_UPDATE_LOGIN */
                       nvl(moh.program_application_id,0),      /* PROGRAM_APPLICATION_ID */
                       moh.program_id,                         /* PROGRAM_ID */
                       moh.program_update_date,                /* PROGRAM_UPDATE_DATE */
                       moh.request_id,                         /* REQUEST_ID */
                       moh.salesrep_id,                        /* SALESREP_ID */
                       null,                                   /* RETURN_REASON_CODE */
                       moh.context,                            /* CONTEXT */
                       moh.attribute1,                         /* ATTRIBUTE1 */
                       moh.attribute2,                         /* ATTRIBUTE2 */
                       moh.attribute3,                         /* ATTRIBUTE3 */
                       moh.attribute4,                         /* ATTRIBUTE4 */
                       moh.attribute5,                         /* ATTRIBUTE5 */
                       moh.attribute6,                         /* ATTRIBUTE6 */
                       moh.attribute7,                         /* ATTRIBUTE7 */
                       moh.attribute8,                         /* ATTRIBUTE8 */
                       moh.attribute9,                         /* ATTRIBUTE9 */
                       moh.attribute10,                        /* ATTRIBUTE10 */
                       moh.attribute11,                        /* ATTRIBUTE11 */
                       moh.attribute12,                        /* ATTRIBUTE12 */
                       moh.attribute13,                        /* ATTRIBUTE13 */
                       moh.attribute14,                        /* ATTRIBUTE14 */
                       moh.attribute15,                        /* ATTRIBUTE15 */
                       moh.global_attribute_category,          /* GLOBAL_ATTRIBUTE_CATEGORY */
                       moh.global_attribute1,                  /* GLOBAL_ATTRIBUTE1 */
                       moh.global_attribute2,                  /* GLOBAL_ATTRIBUTE2 */
                       moh.global_attribute3,                  /* GLOBAL_ATTRIBUTE3 */
                       moh.global_attribute4,                  /* GLOBAL_ATTRIBUTE4 */
                       moh.global_attribute5,                  /* GLOBAL_ATTRIBUTE5 */
                       moh.global_attribute6,                  /* GLOBAL_ATTRIBUTE6 */
                       moh.global_attribute7,                  /* GLOBAL_ATTRIBUTE7 */
                       moh.global_attribute8,                  /* GLOBAL_ATTRIBUTE8 */
                       moh.global_attribute9,                  /* GLOBAL_ATTRIBUTE9 */
                       moh.global_attribute10,                 /* GLOBAL_ATTRIBUTE10 */
                       moh.global_attribute11,                 /* GLOBAL_ATTRIBUTE11 */
                       moh.global_attribute12,                 /* GLOBAL_ATTRIBUTE12 */
                       moh.global_attribute13,                 /* GLOBAL_ATTRIBUTE13 */
                       moh.global_attribute14,                 /* GLOBAL_ATTRIBUTE14 */
                       moh.global_attribute15,                 /* GLOBAL_ATTRIBUTE15 */
                       moh.global_attribute16,                 /* GLOBAL_ATTRIBUTE16 */
                       moh.global_attribute17,                 /* GLOBAL_ATTRIBUTE17 */
                       moh.global_attribute18,                 /* GLOBAL_ATTRIBUTE18 */
                       moh.global_attribute19,                 /* GLOBAL_ATTRIBUTE19 */
                       moh.global_attribute20,                 /* GLOBAL_ATTRIBUTE20 */
                       'SHIP',                                 /* ORDER_DATE_TYPE_CODE    */
                       OE_Upg_SO.G_Earliest_Schedule_Limit,    /* EARLIEST_SCHEDULE_LIMIT */
                       OE_Upg_SO.G_Latest_Schedule_Limit,      /* LATEST_SCHEDULE_LIMIT   */
                       moh.payment_type_code,                  /* PAYMENT_TYPE_CODE */
                       moh.payment_amount,                     /* PAYMENT_AMOUNT */
                       moh.check_number,                       /* CHECK_NUMBER */
                       moh.credit_card_code,                   /* CREDIT_CARD_CODE */
                       moh.credit_card_holder_name,            /* CREDIT_CARD_HOLDER_NAME */
                       moh.credit_card_number,                 /* CREDIT_CARD_NUMBER */
                       moh.credit_card_expiration_date,        /* CREDIT_CARD_EXPIRATION_DATE */
                       moh.credit_card_approval_code,          /* CREDIT_CARD_APPROVAL_CODE */
                       decode(moh.credit_card_approval_code,NULL,NULL,
                                                moh.s1_date),  /* CREDIT_CARD_APPROVAL_DATE */
                       null,                                   /* SALES CHANNEL CODE */
                       G_ORDER_CATEGORY_CODE,                  /* ORDER_CATEGORY_CODE */
                       moh.cancelled_flag,                     /* CANCELLED_FLAG */
                       moh.open_flag,                          /* OPEN_FLAG */
                       moh.booked_flag,                        /* BOOKED_FLAG */
                       null,                                   /* MARKETING_SOURCE_CODE_ID */
                       null,                                   /* TP_CONTEXT */
                       null,                                   /* TP_ATTRIBUTE1 */
                       null,                                   /* TP_ATTRIBUTE2 */
                       null,                                   /* TP_ATTRIBUTE3 */
                       null,                                   /* TP_ATTRIBUTE4 */
                       null,                                   /* TP_ATTRIBUTE5 */
                       null,                                   /* TP_ATTRIBUTE6 */
                       null,                                   /* TP_ATTRIBUTE7 */
                       null,                                   /* TP_ATTRIBUTE8 */
                       null,                                   /* TP_ATTRIBUTE9 */
                       null,                                   /* TP_ATTRIBUTE10 */
                       null,                                   /* TP_ATTRIBUTE11 */
                       null,                                   /* TP_ATTRIBUTE12 */
                       null,                                   /* TP_ATTRIBUTE13 */
                       null,                                   /* TP_ATTRIBUTE14 */
                       null,                                   /* TP_ATTRIBUTE15 */
                       decode(G_CANCELLED_FLAG,'Y','CANCELLED',
                           decode(moh.open_flag,'N','CLOSED',
                               decode(moh.booked_flag,'N','ENTERED',
                                  'Y','BOOKED',NULL))),        /* FLOW_STATUS_CODE */
                       'Y',                                    /* UPGRADED_FLAG */
                       decode(nvl(moh.booked_flag,'-'),'Y',
                               moh.s1_date,NULL),              /* BOOKED_DATE */
                       moh.org_id                              /* SOLD_FROM_ORG_ID */
                  );

                  G_HDR_CANC_FLAG := NULL;
                  G_HDR_CANC_FLAG := moh.cancelled_flag;

                  begin
                       G_canc_rec := NULL;
                       if nvl(moh.cancelled_Flag,'-')  = 'Y' then
                            select
                                 soc.header_id,
                                 soc.line_id,
                                 soc.created_by,
                                 soc.creation_date,
                                 soc.last_updated_by,
                                 soc.last_update_date,
                                 soc.last_update_login,
                                 soc.program_application_id,
                                 soc.program_id,
                                 soc.program_update_date,
                                 soc.request_id,
                                 soc.cancel_code,
                                 soc.cancelled_by,
                                 soc.cancel_date,
                                 soc.cancelled_quantity,
                                 soc.cancel_comment,
                                 soc.context,
                                 soc.attribute1,
                                 soc.attribute2,
                                 soc.attribute3,
                                 soc.attribute4,
                                 soc.attribute5,
                                 soc.attribute6,
                                 soc.attribute7,
                                 soc.attribute8,
                                 soc.attribute9,
                                 soc.attribute10,
                                 soc.attribute11,
                                 soc.attribute12,
                                 soc.attribute13,
                                 soc.attribute14,
                                 soc.attribute15
                            into
                                 G_Hdr_Canc_Rec
                            from
                                 so_order_cancellations    soc
                            where   soc.header_id = g_header_id
                            and     soc.line_Id   is null
                            and     rownum =1 ;
                       end if;
                  exception
                       when others then
                            null;
                  end;

                  /* ============  Order Lines Creation ===========*/

                  G_LINE_ID := NULL;
                  OE_Upg_SO.Upgrade_Create_Order_Lines;

                  /* ============  Header Level Sales Credits ===========*/
                  OE_Upg_SO.Upgrade_Sales_Credits
                  ( L_level_flag => 'H');

                  /* ============  Header Level Price Adjustments ===========*/
                  OE_Upg_SO.Upgrade_Price_Adjustments ( L_level_flag => 'H');

                  /* ============  Upgrade Log Handling ===========*/

                  g_log_rec                     := NULL;
                  g_log_rec.header_id           := g_header_id;
                  g_log_rec.mtl_sales_order_id  := g_mtl_sales_order_id;

                  OE_UPG_SO.Upgrade_Insert_Upgrade_Log;

                  Update SO_HEADERS_ALL
                  set upgrade_flag = 'Y'
                  where header_id = G_HEADER_ID;

                  G_ERROR_LOCATION := 10;

                  if G_ERROR_ALERT = 'Y' then
                       G_ERROR_LOCATION := 11;
                       ROLLBACK TO HEADER_SAVE_POINT;
                       v_error_code := sqlcode;
                       oe_upg_so.upgrade_insert_errors
                       (
                           L_header_id => g_header_id,
                           L_comments  => 'Exception tapped: Alert level = '
                              ||to_char(G_ERROR_LOCATION)||' Code -'
                              ||to_char(v_error_code)
                              ||' - Line id '||to_char(g_line_id)
                              ||' Line detail id'
                              ||to_char(g_line_rec.line_detail_id)
                       );
                       COMMIT;
                       commit_counter := 0;
                       G_ERROR_ALERT  := 'N';
                  end if;
            exception
                  when others then
                       /* G_ERROR_LOCATION := 12; */
                       ROLLBACK TO HEADER_SAVE_POINT;
                       v_error_code := sqlcode;
                       oe_upg_so.upgrade_insert_errors
                       (
                          L_header_id => G_HEADER_ID,
                          L_comments  => 'Exception tapped: Exception level ='
                              ||to_char(G_ERROR_LOCATION)||'code -'
                              ||to_char(v_error_code)
                              ||' - Line id '||to_char(G_LINE_ID)
                              ||' Line detail id'
                              ||to_char(g_line_rec.line_detail_id)
                       );
                       COMMIT;
                       commit_counter := 0;
                       G_ERROR_ALERT  := 'N';
                       raise;
            end;

            G_ERROR_LOCATION := 120;
              if commit_counter > 500 then
                  G_ERROR_LOCATION := 121;
                  commit;
                  commit_counter := 0;
              else
                  G_ERROR_LOCATION := 122;
                  commit_counter := commit_counter + 1;
              end if;
          end loop;       /* end loop for Order Headers */
          G_ERROR_LOCATION := 13;
          commit;

   -- dbms_output.put_line('just ending');
   End Upgrade_Create_Order_Headers;

   Procedure Upgrade_Insert_Lines_History is
   --
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
   --
   begin
        G_ERROR_LOCATION := 14;
        insert into  oe_order_lines_history
        (
            line_id,
            org_id,
            header_id,
            line_type_id,
            line_number,
            ordered_item,
            request_date,
            promise_date,
            schedule_ship_date,
            order_quantity_uom,
            pricing_quantity,
            pricing_quantity_uom,
            cancelled_quantity,
            shipped_quantity,
            ordered_quantity,
            fulfilled_quantity,
            shipping_quantity,
            shipping_quantity_uom,
            delivery_lead_time,
            tax_exempt_flag,
            tax_exempt_number,
            tax_exempt_reason_code,
            ship_from_org_id,
            ship_to_org_id,
            invoice_to_org_id,
            deliver_to_org_id,
            ship_to_contact_id,
            deliver_to_contact_id,
            invoice_to_contact_id,
            sold_to_org_id,
            cust_po_number,
            ship_tolerance_above,
            ship_tolerance_below,
            demand_bucket_type_code,
            veh_cus_item_cum_key_id,
            rla_schedule_type_code,
            customer_dock_code,
            customer_job,
            customer_production_line,
            cust_model_serial_number,
            project_id,
            task_id,
            inventory_item_id,
            tax_date,
            tax_code,
            tax_rate,
            demand_class_code,
            price_list_id,
            pricing_date,
            shipment_number,
            agreement_id,
            shipment_priority_code,
            shipping_method_code,
            freight_carrier_code,
            freight_terms_code,
            fob_point_code,
            tax_point_code,
            payment_term_id,
            invoicing_rule_id,
            accounting_rule_id,
            source_document_type_id,
            orig_sys_document_ref,
            source_document_id,
            orig_sys_line_ref,
            source_document_line_id,
            reference_line_id,
            reference_type,
            reference_header_id,
            item_revision,
            unit_selling_price,
            unit_list_price,
            tax_value,
            context,
            attribute1,
            attribute2,
            attribute3,
            attribute4,
            attribute5,
            attribute6,
            attribute7,
            attribute8,
            attribute9,
            attribute10,
            attribute11,
            attribute12,
            attribute13,
            attribute14,
            attribute15,
            global_attribute_category,
            global_attribute1,
            global_attribute2,
            global_attribute3,
            global_attribute4,
            global_attribute5,
            global_attribute6,
            global_attribute7,
            global_attribute8,
            global_attribute9,
            global_attribute10,
            global_attribute11,
            global_attribute12,
            global_attribute13,
            global_attribute14,
            global_attribute15,
            global_attribute16,
            global_attribute17,
            global_attribute18,
            global_attribute19,
            global_attribute20,
            pricing_context,
            pricing_attribute1,
            pricing_attribute2,
            pricing_attribute3,
            pricing_attribute4,
            pricing_attribute5,
            pricing_attribute6,
            pricing_attribute7,
            pricing_attribute8,
            pricing_attribute9,
            pricing_attribute10,
            industry_context,
            industry_attribute1,
            industry_attribute2,
            industry_attribute3,
            industry_attribute4,
            industry_attribute5,
            industry_attribute6,
            industry_attribute7,
            industry_attribute8,
            industry_attribute9,
            industry_attribute10,
            industry_attribute11,
            industry_attribute12,
            industry_attribute13,
            industry_attribute14,
            industry_attribute15,
            industry_attribute16,
            industry_attribute17,
            industry_attribute18,
            industry_attribute19,
            industry_attribute20,
            industry_attribute21,
            industry_attribute22,
            industry_attribute23,
            industry_attribute24,
            industry_attribute25,
            industry_attribute26,
            industry_attribute27,
            industry_attribute28,
            industry_attribute29,
            industry_attribute30,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login,
            program_application_id,
            program_id,
            program_update_date,
            request_id,
            configuration_id,
            link_to_line_id,
            component_sequence_id,
            component_code,
            config_display_sequence,
            sort_order,
            item_type_code,
            option_number,
            option_flag,
            dep_plan_required_flag,
            visible_demand_flag,
            line_category_code,
            actual_shipment_date,
            customer_trx_line_id,
            return_context,
            return_attribute1,
            return_attribute2,
            return_attribute3,
            return_attribute4,
            return_attribute5,
            return_attribute6,
            return_attribute7,
            return_attribute8,
            return_attribute9,
            return_attribute10,
            return_attribute11,
            return_attribute12,
            return_attribute13,
            return_attribute14,
            return_attribute15,
            intmed_ship_to_org_id,
            intmed_ship_to_contact_id,
            actual_arrival_date,
            ato_line_id,
            auto_selected_quantity,
            component_number,
            earliest_acceptable_date,
            explosion_date,
            latest_acceptable_date,
            model_group_number,
            schedule_arrival_date,
            ship_model_complete_flag,
            schedule_status_code,
            return_reason_code,
            salesrep_id,
            split_from_line_id,
            cust_production_seq_num,
            authorized_to_ship_flag,
            invoice_interface_status_code,
            ship_set_id,
            arrival_set_id,
            hist_comments,
            hist_type_code,
            reason_code,
            hist_created_by,
            hist_creation_date,
            source_type_code,
            booked_flag,
            fulfilled_flag,
            sold_from_org_id,
		  top_model_line_id,
		  cancelled_flag,
		  open_flag,
		  over_ship_reason_code,
		  over_ship_resolved_flag,
		  item_identifier_type,
		  commitment_id,
		  shipping_interfaced_flag,
		  credit_invoice_line_id,
		  end_item_unit_number,
		  mfg_component_sequence_id,
		  config_header_id,
		  config_rev_nbr,
		  shipping_instructions,
		  packing_instructions,
		  invoiced_quantity,
		  reference_customer_trx_line_id,
		  split_by,
		  line_set_id,
		  tp_context,
		  tp_attribute1,
		  tp_attribute2,
		  tp_attribute3,
		  tp_attribute4,
		  tp_attribute5,
		  tp_attribute6,
		  tp_attribute7,
		  tp_attribute8,
		  tp_attribute9,
		  tp_attribute10,
		  tp_attribute11,
		  tp_attribute12,
		  tp_attribute13,
		  tp_attribute14,
		  tp_attribute15,
		  fulfillment_method_code,
		  service_reference_type_code,
		  service_reference_line_id,
		  service_reference_system_id,
		  ordered_item_id,
		  service_number,
		  service_duration,
		  service_start_date,
		  re_source_flag,
		  flow_status_code,
		  service_end_date,
		  service_coterminate_flag,
		  shippable_flag,
		  order_source_id,
		  orig_sys_shipment_ref,
		  change_sequence,
		  drop_ship_flag,
		  customer_line_number,
		  customer_shipment_number,
		  customer_item_net_price,
		  customer_payment_term_id,
		  first_ack_date,
		  first_ack_code,
		  last_ack_code,
		  last_ack_date,
		  planning_priority,
		  service_txn_comments,
		  service_period,
		  unit_selling_percent,
		  unit_list_percent,
		  unit_percent_base_price,
		  model_remnant_flag,
		  service_txn_reason_code,
		  calculate_price_flag,
		  revenue_amount
        )
        values
        (
            g_line_id,                                      /* LINE_ID */
            g_line_rec.org_id,                              /* ORG_ID */
            g_line_rec.header_id,                           /* HEADER_ID */
            g_line_rec.line_type_id,                        /* LINE_TYPE_ID, */
            g_last_line_number,                             /* LINE_NUMBER */
            null,                                           /* ordered_item, */
            g_line_rec.date_requested_current,              /* REQUEST_DATE */
            g_line_rec.promise_date,                        /* PROMISE_DATE */
            g_line_rec.schedule_date,                       /* SCHEDULE_SHIP_DATE */
            nvl(r_uom_code,g_line_rec.unit_code),           /* ORDER_QUANTITY_UOM */
            g_line_rec.ordered_quantity,                    /* PRICING_QUANTITY */
            nvl(r_uom_code,g_line_rec.unit_code),           /* PRICING_QUANTITY_UOM */
            decode(G_ORD_CANC_FLAG,'Y',G_canc_rec.can_cancelled_quantity,
              decode(g_hdr_canc_flag,'Y', g_line_rec.cancelled_quantity,
                decode(g_line_id_Change_flag,'Y', g_line_rec.cancelled_quantity,0))),
                                                            /* CANCELLED_QUANTITY */
            g_line_rec.shipped_quantity,                    /* SHIPPED_QUANTITY */
            decode(g_hdr_canc_flag,'Y',0,
                nvl(g_line_rec.ordered_quantity,0)),        /* ORDERED_QUANTITY */
            g_line_rec.fulfilled_quantity,                  /* FULFILLED_QUANTITY */
            g_line_rec.shipped_quantity,                    /* SHIPPING_QUANTITY */
            nvl(r_uom_code,
                g_line_rec.shipping_quantity_uom),          /* SHIPPING_QUANTITY_UOM */
            null,                                           /* DELIVERY_LEAD_TIME */
            G_tax_exempt_flag,                              /* TAX_EXEMPT_FLAG */
            g_line_rec.tax_exempt_number,                   /* TAX_EXEMPT_NUMBER */
            g_line_rec.tax_exempt_reason_code,              /* TAX_EXEMPT_REASON_CODE */
            g_line_rec.warehouse_id,                        /* SHIP_FROM_ORG_ID */
            g_line_rec.ship_to_site_use_id,                 /* SHIP_TO_ORG_ID */
            g_invoice_to_site_use_id,                       /* INVOICE_TO_ORG_ID */
            null,                                           /* DELIVER_TO_ORG_ID */
            g_line_rec.ship_to_contact_id,                  /* SHIP_TO_CONTACT_ID */
            null,                                           /* DELIVER_TO_CONTACT_ID */
            null,                                           /* INVOICE_TO_CONTACT_ID */
            G_customer_id,                                  /* SOLD_TO_ORG_ID */
            G_Purchase_Order_Num,                           /* CUST_PO_NUMBER */
            null,                                           /* SHIP_TOLERANCE_ABOVE */
            null,                                           /* SHIP_TOLERANCE_BELOW */
            decode(G_AUTO_FLAG,'Y','DAY',NULL),             /* DEMAND_BUCKET_TYPE_CODE */
            decode(G_AUTO_FLAG,'Y',-1,NULL),                /* VEH_CUS_ITEM_CUM_KEY_ID */
            g_line_rec.rla_schedule_type_code,              /* RLA_SCHEDULE_TYPE_CODE */
            g_line_rec.customer_dock_code,                  /* CUSTOMER_DOCK_CODE */
            g_line_rec.customer_job,                        /* CUSTOMER_JOB */
            g_line_rec.customer_production_line,            /* CUSTOMER_PRODUCTION_LINE */
            g_line_rec.customer_model_serial_number,        /* CUST_MODEL_SERIAL_NUMBER */
            g_line_rec.project_id,                          /* PROJECT_ID */
            g_line_rec.task_id,                             /* TASK_ID	 */
            nvl(r_inventory_item_id,g_line_rec.inventory_item_id),  /* INVENTORY_ITEM_ID */
            null,                                           /* TAX_DATE */
            g_line_rec.tax_code,                            /* TAX_CODE */
            null,                                           /* TAX_RATE */
            g_line_rec.demand_class_code,                   /* DEMAND_CLASS_CODE */
            g_line_rec.price_list_id,                       /* PRICE_LIST_ID */
            null,                                           /* PRICING_DATE */
            r_shipment_number,                              /* SHIPMENT_NUMBER */
            g_line_rec.agreement_id,                        /* AGREEMENT_ID */
            g_line_rec.shipment_priority_code,              /* SHIPMENT_PRIORITY_CODE */
            null,                                           /* SHIPPPING_METHOD_CODE */
            g_line_rec.ship_method_code,                    /* FREIGHT_CARRIER_CODE */
            G_freight_terms_code,                           /* FREIGHT_TERMS_CODE */
            null,                                           /* FOB_POINT_CODE */
            'INVOICE',                                      /* TAX_POINT_CODE */
            G_terms_id,                                     /* PAYMENT_TERM_ID */
            nvl(g_line_rec.invoicing_rule_id,0),            /* INVOICING_RULE_ID */
            nvl(g_line_rec.accounting_rule_id,0),           /* ACCOUNTING_RULE_ID */
            g_line_rec.source_document_type_id,             /* SOURCE_DOCUMENT_TYPE_ID */
            G_ORIG_SYS_DOCUMENT_REF,                        /* ORIG_SYS_DOCUMENT_REF */
            g_line_rec.source_document_id,                  /* SOURCE_DOCUMENT_ID */
            g_line_rec.original_system_line_reference,      /* ORIG_SYS_LINE_REFERENCE */
            g_line_rec.source_document_line_id,             /* SOURCE_DOCUMENT_LINE_ID */
            v_reference_line_id,                            /* REFERENCE_LINE_ID */
            g_line_rec.return_reference_type_code,          /* REFERENCE_TYPE */
            v_reference_header_id,                          /* REFERENCE_HEADER_ID */
            null,                                           /* ITEM_REVISION */
            g_line_rec.selling_price,                       /* SELLING_PRICE */
            g_line_rec.list_price,                          /* LIST_PRICE */
            null,                                           /* TAX_VALUE */
            g_line_rec.context,                             /* CONTEXT */
            g_line_rec.attribute1,                          /* ATTRIBUTE1 */
            g_line_rec.attribute2,                          /* ATTRIBUTE2 */
            g_line_rec.attribute3,                          /* ATTRIBUTE3 */
            g_line_rec.attribute4,                          /* ATTRIBUTE4 */
            g_line_rec.attribute5,                          /* ATTRIBUTE5 */
            g_line_rec.attribute6,                          /* ATTRIBUTE6 */
            g_line_rec.attribute7,                          /* ATTRIBUTE7 */
            g_line_rec.attribute8,                          /* ATTRIBUTE8 */
            g_line_rec.attribute9,                          /* ATTRIBUTE9 */
            g_line_rec.attribute10,                         /* ATTRIBUTE10 */
            g_line_rec.attribute11,                         /* ATTRIBUTE11 */
            g_line_rec.attribute12,                         /* ATTRIBUTE12 */
            g_line_rec.attribute13,                         /* ATTRIBUTE13 */
            g_line_rec.attribute14,                         /* ATTRIBUTE14 */
            g_line_rec.attribute15,                         /* ATTRIBUTE15 */
            g_line_rec.global_attribute_category,	    /* GLOBAL_ATTRIBUTE_CATEGORY */
            g_line_rec.global_attribute1,                   /* GLOBAL_ATTRIBUTE1 */
            g_line_rec.global_attribute2,                   /* GLOBAL_ATTRIBUTE2 */
            g_line_rec.global_attribute3,                   /* GLOBAL_ATTRIBUTE3 */
            g_line_rec.global_attribute4,                   /* GLOBAL_ATTRIBUTE4 */
            g_line_rec.global_attribute5,                   /* GLOBAL_ATTRIBUTE5 */
            g_line_rec.global_attribute6,                   /* GLOBAL_ATTRIBUTE6 */
            g_line_rec.global_attribute7,                   /* GLOBAL_ATTRIBUTE7 */
            g_line_rec.global_attribute8,                   /* GLOBAL_ATTRIBUTE8 */
            g_line_rec.global_attribute9,                   /* GLOBAL_ATTRIBUTE9 */
            g_line_rec.global_attribute10,                  /* GLOBAL_ATTRIBUTE10 */
            g_line_rec.global_attribute11,                  /* GLOBAL_ATTRIBUTE11 */
            g_line_rec.global_attribute12,                  /* GLOBAL_ATTRIBUTE12 */
            g_line_rec.global_attribute13,                  /* GLOBAL_ATTRIBUTE13 */
            g_line_rec.global_attribute14,                  /* GLOBAL_ATTRIBUTE14 */
            g_line_rec.global_attribute15,                  /* GLOBAL_ATTRIBUTE15 */
            g_line_rec.global_attribute16,                  /* GLOBAL_ATTRIBUTE16 */
            g_line_rec.global_attribute17,                  /* GLOBAL_ATTRIBUTE17 */
            g_line_rec.global_attribute18,                  /* GLOBAL_ATTRIBUTE18 */
            g_line_rec.global_attribute19,                  /* GLOBAL-ATTRIBUTE19 */
            g_line_rec.global_attribute20,                  /* GLOBAL_ATTRIBUTE20 */
            g_line_rec.pricing_context,                     /* PRICING_CONTEXT */
            g_line_rec.pricing_attribute1,                  /* PRICING_ATTRIBUTE1 */
            g_line_rec.pricing_attribute2,                  /* PRICING_ATTRIBUTE2 */
            g_line_rec.pricing_attribute3,                  /* PRICING_ATTRIBUTE3 */
            g_line_rec.pricing_attribute4,                  /* PRICING_ATTRIBUTE4 */
            g_line_rec.pricing_attribute5,                  /* PRICING_ATTRIBUTE5 */
            g_line_rec.pricing_attribute6,                  /* PRICING_ATTRIBUTE6 */
            g_line_rec.pricing_attribute7,                  /* PRICING_ATTRIBUTE7 */
            g_line_rec.pricing_attribute8,                  /* PRICING_ATTRIBUTE8 */
            g_line_rec.pricing_attribute9,                  /* PRICING_ATTRIBUTE9 */
            g_line_rec.pricing_attribute10,                 /* PRICING_ATTRIBUTE10*/
            g_line_rec.industry_context,                    /* INDUSTRY_CONTEXT    */
            g_line_rec.industry_attribute1,                 /* INDUSTRY_ATTRIBUTE1 */
            decode(G_AUTO_FLAG,'Y',NULL,
			    g_line_rec.industry_attribute2),         /* INDUSTRY_ATTRIBUTE2 */
            decode(G_AUTO_FLAG,'Y',NULL,
                g_line_rec.industry_attribute3),            /* INDUSTRY_ATTRIBUTE3 */
            decode(G_AUTO_FLAG,'Y',NULL,
                g_line_rec.industry_attribute4),            /* INDUSTRY_ATTRIBUTE4 */
            decode(G_AUTO_FLAG,'Y',NULL,
                g_line_rec.industry_attribute5),            /* INDUSTRY_ATTRIBUTE5 */
            decode(G_AUTO_FLAG,'Y',NULL,
                g_line_rec.industry_attribute6),            /* INDUSTRY_ATTRIBUTE6 */
            decode(G_AUTO_FLAG,'Y',NULL,
                g_line_rec.industry_attribute7),            /* INDUSTRY_ATTRIBUTE7 */
            decode(G_AUTO_FLAG,'Y',NULL,
                g_line_rec.industry_attribute8),            /* INDUSTRY_ATTRIBUTE8 */
            decode(G_AUTO_FLAG,'Y',NULL,
                g_line_rec.industry_attribute9),            /* INDUSTRY_ATTRIBUTE9 */
            decode(G_AUTO_FLAG,'Y',NULL,
                g_line_rec.industry_attribute10),           /* INDUSTRY_ATTRIBUTE10 */
            decode(G_AUTO_FLAG,'Y',NULL,
                g_line_rec.industry_attribute11),           /* INDUSTRY_ATTRIBUTE11 */
            decode(G_AUTO_FLAG,'Y',NULL,
                g_line_rec.industry_attribute12),           /* INDUSTRY_ATTRIBUTE12 */
            decode(G_AUTO_FLAG,'Y',NULL,
                g_line_rec.industry_attribute13),           /* INDUSTRY_ATTRIBUTE13 */
            decode(G_AUTO_FLAG,'Y',NULL,
                g_line_rec.industry_attribute14),           /* INDUSTRY_ATTRIBUTE14 */
            decode(G_AUTO_FLAG,'Y',NULL,
                g_line_rec.industry_attribute15),           /* INDUSTRY_ATTRIBUTE15 */
            NULL,                                           /* INDUSTRY_ATTRIBUTE16 */
            NULL,                                           /* INDUSTRY_ATTRIBUTE17 */
            NULL,                                           /* INDUSTRY_ATTRIBUTE18 */
            NULL,                                           /* INDUSTRY_ATTRIBUTE19 */
            NULL,                                           /* INDUSTRY_ATTRIBUTE20 */
            NULL,                                           /* INDUSTRY_ATTRIBUTE21 */
            NULL,                                           /* INDUSTRY_ATTRIBUTE22 */
            NULL,                                           /* INDUSTRY_ATTRIBUTE23 */
            NULL,                                           /* INDUSTRY_ATTRIBUTE24 */
            NULL,                                           /* INDUSTRY_ATTRIBUTE25 */
            NULL,                                           /* INDUSTRY_ATTRIBUTE26 */
            NULL,                                           /* INDUSTRY_ATTRIBUTE27 */
            NULL,                                           /* INDUSTRY_ATTRIBUTE28 */
            NULL,                                           /* INDUSTRY_ATTRIBUTE29 */
            NULL,                                           /* INDUSTRY_ATTRIBUTE30 */
            g_line_rec.creation_date,                       /* CREATION_DATE */
            g_line_rec.created_by,                          /* CREATED_BY */
            g_line_rec.last_update_date,                    /* LAST_UPDATE_DATE */
            g_line_rec.last_updated_by,                     /* LAST_UPDATED_BY */
            g_line_rec.last_update_login,                   /* LAST_UPDATE_LOGIN */
            nvl(g_line_rec.program_application_id,0),       /* PROGRAM_APPLICATION_ID */
            g_line_rec.program_id,                          /* PROGRAM_ID */
            g_line_rec.program_update_date,                 /* PROGRAM_UPDATE_DATE */
            g_line_rec.request_id,                          /* REQUEST_ID */
            g_line_rec.parent_line_id,                      /* CONFIGURATION_ID */
            g_line_rec.link_to_line_id,                     /* LINK_TO_LINE_ID */
            g_line_rec.component_sequence_id,               /* COMPONENT_SEQUENCE_ID */
            g_line_rec.component_code,                      /* COMPONENT_CODE */
            null,                                           /* CONFIG_DISPLAY_SEQUENCE */
            null,                                           /* SORT_ORDER, */
            g_line_rec.item_type_code,                      /* ITEM_TYPE_CODE */
            null,                                           /* OPTION_NUMBER */
            g_line_rec.option_flag,                         /* OPTION_FLAG, */
            g_line_rec.dep_plan_required_flag,              /* DEP_PLAN_REQUIRED_FLAG */
            g_line_rec.visible_demand_flag,                 /* VISIBLE_DEMAND_FLAG */
            g_line_rec.line_category_code,                  /* LINE_CATEGORY_CODE */
            g_line_rec.actual_departure_date,               /* ACTUAL_SHIPMENT_DATE */
            decode(g_line_rec.line_type_code,'RETURN',
              decode(g_line_rec.return_reference_type_code,
                'INVOICE',g_line_rec.return_reference_id,NULL),
                                                     NULL), /* CUSTOMER_TRX_LINE_ID */
            g_line_rec.return_reference_type_Code,          /* RETURN_CONTEXT */
            decode(g_line_rec.line_type_code,'RETURN',
                 decode(g_line_rec.return_reference_type_code,
                    'INVOICE',v_customer_trx_id,
                        v_reference_header_id),NULL),       /* RETURN_ATTRIBUTE1 */
            decode(g_line_rec.line_type_code,'RETURN',
                 decode(g_line_rec.return_reference_type_code,
                    'INVOICE',g_line_rec.return_reference_id,
                       v_reference_line_id),NULL),          /* RETURN_ATTRIBUTE2 */
            null,                                           /* RETURN_ATTRIBUTE3 */
            null,                                           /* RETURN_ATTRIBUTE4 */
            null,                                           /* RETURN_ATTRIBUTE5 */
            null,                                           /* RETURN_ATTRIBUTE6 */
            null,                                           /* RETURN_ATTRIBUTE7 */
            null,                                           /* RETURN_ATTRIBUTE8 */
            null,                                           /* RETURN_ATTRIBUTE9 */
            null,                                           /* RETURN_ATTRIBUTE10 */
            null,                                           /* RETURN_ATTRIBUTE11 */
            null,                                           /* RETURN_ATTRIBUTE12 */
            null,                                           /* RETURN_ATTRIBUTE13 */
            null,                                           /* RETURN_ATTRIBUTE14 */
            null,                                           /* RETURN_ATTRIBUTE15 */
            g_line_rec.intermediate_ship_to_id,             /* intmed_ship_to_org_id, */
            g_line_rec.ship_to_contact_id,                  /* intmed_ship_to_contact_id, */
            null,                                           /* actual_arrival_date, */
            g_line_rec.ato_line_id,                         /* ATO_LINE_ID */
            null,                                           /* auto_selected_quantity, */
            null,                                           /* component_number, */
            null,                                           /* earliest_acceptable_date, */
            g_line_rec.standard_component_freeze_date,      /* explosion_date, */
            g_line_rec.latest_acceptable_date,              /* latest_acceptable_date, */
            null,                                           /* model_group_number, */
            null,                                           /* schedule_arrival_date, */
            g_line_rec.ship_model_complete_flag,            /* ship_model_complete_flag, */
            g_line_rec.schedule_status_code,                /* schedule_status_code, */
            g_line_rec.transaction_reason_code,             /* return_reason_code */
            g_salesrep_id,                                  /* salesrep_id */
            null,                                           /* split_from_line_id */
            g_line_rec.planning_prod_seq_number,            /* cust_production_seq_num */
            decode(G_AUTO_FLAG,'Y','Y',NULL),               /* authorized_to_ship_flag */
            g_line_rec.invoice_interface_status_code,       /* invoice_interface_status_code */
            g_set_id,                                       /* Ship_Set_Id */
            null,                                           /* Arrival_Set_Id */
            g_canc_rec.can_cancel_comment,                  /* Hist_Comments */
            'CANCELLATION',                                 /* Hist_Type_Code */
            g_canc_rec.can_cancel_code,                     /* Reason_Code */
            g_canc_rec.can_cancelled_by,                    /* Hist_Created_By 	*/
            g_canc_rec.can_cancel_date,                     /* Hist_Creation_Date */
            g_line_rec.source_type_code,                    /* Source_Type_Code */
            g_line_rec.Booked_Flag,                         /* booked_Flag */
            g_line_rec.fulfilled_flag,                      /* fulfilled_flag */
            g_line_rec.org_id,                              /* sold_from_org_id, */
            g_line_rec.top_model_line_id,                   /* top_model_line_id, */
            g_line_rec.cancelled_flag,                      /* cancelled_flag, */
            g_line_rec.open_flag,                           /* open_flag, */
            null,                                           /* over_ship_reason_code, */
            null,                                           /* over_ship_resolved_flag, */
            decode(nvl(g_line_rec.customer_item_id,-1),
              -1,'INT','CUST'),                             /* item_identifier_type, */
            null,                                           /* commitment_id, */
            g_line_rec.shipping_interfaced_flag,            /* shipping_interfaced_flag, */
            g_line_rec.credit_invoice_line_id,              /* credit_invoice_line_id, */
            null,                                           /* end_item_unit_number, */
            null,                                           /* mfg_component_sequence_id, */
            null,                                           /* config_header_id, */
            null,                                           /* config_rev_nbr, */
            null,                                           /* shipping_instructions, */
            null,                                           /* packing_instructions, */
            g_line_rec.invoiced_quantity,                   /* invoiced_quantity, */
            null,                                           /* reference_customer_trx_line_id, */
            null,                                           /* split_by, */
            null,                                           /* line_set_id, */
            g_line_rec.tp_context,                          /* tp_context */
            g_line_rec.tp_attribute1,                       /* tp_attribute1 */
            g_line_rec.tp_attribute2,                       /* tp_attribute2 */
            g_line_rec.tp_attribute3,                       /* tp_attribute3 */
            g_line_rec.tp_attribute4,                       /* tp_attribute4 */
            g_line_rec.tp_attribute5,                       /* tp_attribute5 */
            g_line_rec.tp_attribute6,                       /* tp_attribute6 */
            g_line_rec.tp_attribute7,                       /* tp_attribute7 */
            g_line_rec.tp_attribute8,                       /* tp_attribute8 */
            g_line_rec.tp_attribute9,                       /* tp_attribute9 */
            g_line_rec.tp_attribute10,                      /* tp_attribute10 */
            g_line_rec.tp_attribute11,                      /* tp_attribute11 */
            g_line_rec.tp_attribute12,                      /* tp_attribute12 */
            g_line_rec.tp_attribute13,                      /* tp_attribute13 */
            g_line_rec.tp_attribute14,                      /* tp_attribute14 */
            g_line_rec.tp_attribute15,                      /* tp_attribute15 */
            g_line_rec.fulfillment_method_code,             /* fulfillment_method_code, */
            g_line_rec.service_reference_type_code,         /* service_reference_type_code, */
            g_line_rec.service_reference_line_id,           /* service_reference_line_id, */
            g_line_rec.service_reference_system_id,         /* service_reference_system_id, */
            decode(nvl(g_line_rec.customer_item_id,-1),
                     -1,g_line_rec.inventory_item_id,
                            g_line_rec.customer_item_id),   /* ordered_item_id */
            g_line_rec.service_number,                      /* service_number, */
            g_line_rec.service_duration,                    /* service_duration, */
            g_line_rec.service_start_date,                  /* service_start_date, */
            g_line_rec.re_source_flag,                      /* re_source_flag, */
            g_line_rec.flow_status_code,                    /* flow_status_code, */
            g_line_rec.service_end_date,                    /* service_end_date, */
            g_line_rec.service_coterminate_flag,            /* service_coterminate_flag, */
            g_line_rec.shippable_flag,                      /* shippable_flag, */
            nvl(G_ORDER_SOURCE_ID,0),                       /* order_source_id, */
            null,                                           /* orig_sys_shipment_ref, */
            null,                                           /* change_sequence, */
            null,                                           /* drop_ship_flag, */
            null,                                           /* customer_line_number, */
            null,                                           /* customer_shipment_number, */
            null,                                           /* customer_item_net_price, */
            null,                                           /* customer_payment_term_id, */
            null,                                           /* first_ack_date, */
            null,                                           /* first_ack_code, */
            null,                                           /* last_ack_code, */
            null,                                           /* last_ack_date, */
            g_line_rec.planning_priority,                   /* planning_priority, */
            g_line_rec.service_txn_comments,                /* service_txn_comments, */
            g_line_rec.service_period,                      /* service_period, */
            g_line_rec.selling_percent,                     /* unit_selling_percent, */
            g_line_rec.list_percent,                        /* unit_list_percent, */
            g_line_rec.percent_base_price,                  /* unit_percent_base_price, */
            null,                                           /* model_remnant_flag, */
            g_line_rec.service_txn_reason_code,             /* service_txn_reason_code, */
            g_line_rec.calculate_price_flag,                /* calculate_price_flag, */
            g_line_rec.revenue_amount                      /* revenue_amount, */
        );
        G_ERROR_LOCATION := 15;
   End Upgrade_Insert_Lines_History;

   Procedure Upgrade_Insert_Upgrade_log
   is
   --
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
   --
   begin

        G_ERROR_LOCATION := 16;
        insert into oe_upgrade_log
        (
             header_id,
             old_line_id,
             old_line_detail_id,
             new_line_id,
             picking_line_id,
             new_line_number,
             mtl_sales_order_id,
             return_qty_available,
             comments,
             creation_date,
		   delivery
         )
         values
         (
             g_log_rec.header_id,                 /* HEADER_ID              */
             g_log_rec.old_line_id,               /* OLD_LINE_ID            */
             g_log_rec.old_line_detail_id,        /* OLD_LINE_DETAIL_ID     */
             g_log_rec.new_line_id,               /* NEW_LINE_ID            */
             g_log_rec.picking_line_id,           /* PICKING_LINE_ID        */
             g_log_rec.new_line_number,           /* NEW_LINE_NUMBER        */
             g_log_rec.mtl_sales_order_id,        /* MTL_SALES_ORDER_ID     */
             g_log_rec.return_qty_available,      /* RETURN_QTY_AVAILABLE   */
             g_log_rec.comments,                  /* COMMENTS               */
             sysdate,                             /* CREATION_DATE          */
             g_log_rec.delivery                   /* DELIVERY               */
         );
        G_ERROR_LOCATION := 17;

   End Upgrade_Insert_Upgrade_log;

   Procedure  Upgrade_Process_Distbns
       (  L_total_slabs IN number)
      is
      v_type              varchar2(1);
      cursor RDis
      is
      select
          sha.header_id
      from
          so_headers_all sha
      where  sha.upgrade_flag = 'N'
      order by sha.header_id;

/*
      and  ( (sha.order_category =  'RMA' and v_type = 'R') or
             (sha.order_category <> 'RMA' and v_type = 'O')     )
*/

      v_total_headers     number;
      v_min_header        number;
      v_max_header        number;
      v_counter           number;
      v_gap               number;
      v_slab_count        number;
      v_slab_start        number;
      v_slab_end          number;
      v_dis_header_id     number;
      v_start_flag        number;
      v_total_slabs       number;
      v_type_ctr          number;

   --
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
   --
   Begin

      delete oe_upgrade_distribution;
      commit;
      v_type_ctr := 1;

      loop
           if v_type_ctr = 1 then
                v_type := 'O';
/*
           elsif v_type_ctr =2 then
                v_type := 'R';
*/
           else
                exit;
           end if;

           begin
                select
                     count(*),
                     nvl(min(sha.header_id),0),
                     nvl(max(sha.header_id),0)
                into
                     v_total_headers,
                     v_min_header,
                     v_max_header
                from
                     so_headers_all sha
                where  sha.upgrade_flag = 'N';
/*
                and     ( (sha.order_category =  'RMA' and v_type = 'R') or
                          (sha.order_category <> 'RMA' and v_type = 'O')     );
*/
           exception
                when others then
                  null;
           end;

           if  v_total_headers < 5000  or l_total_slabs = 1 then

                OE_UPG_SO.Upgrade_Insert_Distbn_Record
                (
                    L_slab             => 1,
                    L_start_header_id  => v_min_header,
                    L_end_Header_id    => v_max_header,
                    L_type_var         => v_type
                );

           else
                v_max_header  := 0;
                v_min_header  := 0;
                v_total_slabs := L_total_slabs;
                v_counter     := 0;
                v_start_flag  := 0;
                v_slab_count  := 0;
                v_gap         := round(v_total_headers / v_total_slabs);

                for  MRdis  in  Rdis  loop

                    v_dis_header_id := MRdis.header_id;
                    v_counter       := v_counter + 1;

                    if v_start_flag = 0 then
                              v_start_flag := 1;
                              v_min_header := MRdis.header_id;
                              v_max_header := NULL;
                              v_slab_count := v_slab_count + 1;
                    end if;

                    if v_counter = v_gap and v_slab_count < v_total_slabs then
                         v_max_header := MRdis.header_id;

                         OE_UPG_SO.Upgrade_Insert_Distbn_Record
                         (
                             L_slab             => v_slab_count,
                             L_start_header_id  => v_min_header,
                             L_end_Header_id    => v_max_header,
                             L_type_var         => v_type
                         );

                         v_counter    := 0;
                         v_start_flag := 0;
                    end if;

                end loop;
                v_max_header := v_dis_header_id;

                OE_UPG_SO.Upgrade_Insert_Distbn_Record
                (
                    L_slab             => v_slab_count,
                    L_start_header_id  => v_min_header,
                    L_end_Header_id    => v_max_header ,
                    L_type_var         => v_type
                );

                commit;
	      end if;
           v_type_ctr := v_type_ctr + 1;
      end loop;
      commit;

   End Upgrade_Process_Distbns;

   Procedure Upgrade_Insert_Distbn_Record
   (
      L_slab             IN  Varchar2,
      L_start_Header_id  IN  Number,
      L_end_Header_Id    IN  Number,
      L_type_var         IN  Varchar2
   )
   is

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
   Begin
       insert into oe_upgrade_distribution
       (
           slab,
           start_header_id,
           end_header_id,
           alloted_flag,
           line_type,
           creation_date
       )
       values
       (
           L_slab,
           L_start_Header_id,
           L_end_Header_id,
           'N',
           L_type_var,
           sysdate
       );

   End Upgrade_Insert_Distbn_Record;

   Procedure Upgrade_Insert_Errors
   (
      L_header_id             IN  Varchar2,
      L_comments              IN  varchar2
   )
   is

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
   Begin
       G_ERROR_LOCATION := 18;
       insert into oe_upgrade_errors
       (
           header_id,
           comments,
           creation_date
       )
       values
       (
           l_header_id,
           l_comments,
           sysdate
       );

       G_ERROR_LOCATION := 19;
   End Upgrade_Insert_Errors;

   Procedure Upgrade_Create_Line_Sets
   is
          v_set_id          number;
          v_line_number     number;
          v_shipment_number number;
          v_header_id       number;
          v_line_id         number;
          v_commit_ctr      number;
          v_mem_line_num    number;

          cursor c1 is
          select
               header_id,
               line_id,
               line_number,
			inventory_item_id,
			unit_code
          from
               so_lines_all
          where line_type_code = 'PARENT'
          and   item_type_code in ('KIT','MODEL','STANDARD')
		and   parent_line_id is null -- To filter out option lines
		and   parent_line_id is null -- To filter out option lines
          and  line_id in
            (select shipment_schedule_line_id from so_lines_all
             where line_id in
                   (select old_line_id from oe_upgrade_log_v
                    where new_line_id in
                       (select line_id from oe_order_lines_all
                        where line_set_id is null)))
          order by header_id, line_id;

          cursor c3 is
          select
               line_id,
               line_number
          from oe_order_lines_all oola
          where line_id in
             (select new_line_id  from oe_upgrade_log oul, so_lines_all sla
              where oul.old_line_id = sla.line_id
              and   sla.shipment_schedule_line_id = v_line_id)
		    and  item_type_code in ('KIT','MODEL','STANDARD')
          order by line_id;

          cursor c5 is
          select
                header_id,
                line_id,
                line_number,
			 inventory_item_id,
			 unit_code
          from
                so_lines_all sla
          where sla.line_type_code = 'REGULAR'
          AND  item_type_code in ('KIT','MODEL','STANDARD')
          and  parent_line_id is null  -- To filter out options  (included on Leena's instn.)
          and  parent_line_id is null  -- To filter out options  (included on Leena's instn.)
          and sla.line_id in
            (select lg.old_line_id
             from oe_upgrade_log_v lg, oe_order_lines_all ln
             where  lg.new_line_id = ln.line_id
             and    ln.item_type_code not in  ('INCLUDED','CONFIG')
             group by lg.old_line_id
             having count(*) > 1);

	    cursor c7  is
         select
             new_line_id line_id,
             new_line_number line_number
         from oe_upgrade_log
         where old_line_id = v_line_id
         and   old_line_id is not null;
         v_ctr number;
         p_line_number number;
	    v_item_type_code varchar2(200);
	    --
	    l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	    --
     begin
          v_header_id  := 0;
          v_commit_ctr := 0;

          for c2 in c1  loop

               v_line_id := c2.line_id;
               p_line_number := c2.line_number;

               /*   Create  a set */

               select oe_sets_s.nextval into v_set_id from dual;

               insert into oe_sets
               (
                    SET_ID,
                    SET_NAME,
                    SET_TYPE,
                    HEADER_ID,
                    SHIP_FROM_ORG_ID,
                    SHIP_TO_ORG_ID,
                    SCHEDULE_SHIP_DATE,
                    SCHEDULE_ARRIVAL_DATE,
                    FREIGHT_CARRIER_CODE,
                    SHIPPING_METHOD_CODE,
                    SHIPMENT_PRIORITY_CODE,
                    SET_STATUS,
                    CREATED_BY,
                    CREATION_DATE,
                    UPDATED_BY,
                    UPDATE_DATE,
                    UPDATE_LOGIN,
                    INVENTORY_ITEM_ID,
                    ORDERED_QUANTITY_UOM,
                    LINE_TYPE_ID,
                    SHIP_TOLERANCE_ABOVE,
                    SHIP_TOLERANCE_BELOW
               )
               values
               (
                    v_set_id,                     /* SET_ID, */
                    to_char(v_set_id),            /* SET_NAME, */
                    'LINE_SET',                   /* SET_TYPE, */
                    c2.header_id,                 /* HEADER_ID,*/
                    null,                         /* SHIP_FROM_ORG_ID, */
                    null,                         /* SHIP_TO_ORG_ID, */
                    null,                         /* SCHEDULE_SHIP_DATE, */
                    null,                         /* SCHEDULE_ARRIVAL_DATE, */
                    null,                         /* FREIGHT_CARRIER_CODE, */
                    null,                         /* SHIPPING_METHOD_CODE, */
                    null,                         /* SHIPMENT_PRIORITY_CODE, */
                    null,                         /* SET_STATUS, */
                    0,                            /* CREATED_BY, */
                    sysdate,                      /* CREATION_DATE, */
                    0,                            /* UPDATED_BY, */
                    sysdate,                      /* UPDATE_DATE, */
                    0,                            /* UPDATE_LOGIN, */
                    c2.inventory_item_id,         /* INVENTORY_ITEM_ID, */
                    c2.unit_code,                 /* ORDERED_QUANTITY_UOM, */
                    null,                         /* LINE_TYPE_ID, */
                    null,                         /* SHIP_TOLERANCE_ABOVE, */
                    null                          /* SHIP_TOLERANCE_BELOW */
               );

               v_shipment_number := 0;
               v_ctr := 0;
               for c4 in c3 loop

                     v_shipment_number := v_shipment_number + 1;

                     update oe_order_lines_all
                     set line_set_id     = v_set_id,
                         line_number     = p_line_number,
                         shipment_number = v_shipment_number
                     where line_id = c4.line_id;
               end loop;
               v_commit_ctr := v_commit_ctr + 1;

               if v_commit_ctr > 500 then
                    commit;
                    v_commit_ctr := 0;
               end if;

          end loop;

          v_line_number := 0;
          v_header_id  := 0;

          for c6 in c5 loop
               v_line_id := c6.line_id;
               p_line_number := c6.line_number;

               select oe_sets_s.nextval into v_set_id from dual;

               insert into oe_sets
               (
                    SET_ID,
                    SET_NAME,
                    SET_TYPE,
                    HEADER_ID,
                    SHIP_FROM_ORG_ID,
                    SHIP_TO_ORG_ID,
                    SCHEDULE_SHIP_DATE,
                    SCHEDULE_ARRIVAL_DATE,
                    FREIGHT_CARRIER_CODE,
                    SHIPPING_METHOD_CODE,
                    SHIPMENT_PRIORITY_CODE,
                    SET_STATUS,
                    CREATED_BY,
                    CREATION_DATE,
                    UPDATED_BY,
                    UPDATE_DATE,
                    UPDATE_LOGIN,
                    INVENTORY_ITEM_ID,
                    ORDERED_QUANTITY_UOM,
                    LINE_TYPE_ID,
                    SHIP_TOLERANCE_ABOVE,
                    SHIP_TOLERANCE_BELOW
               )
               values
               (
                    v_set_id,                     /* SET_ID, */
                    to_char(v_set_id),            /* SET_NAME, */
                    'LINE_SET',                   /* SET_TYPE, */
                    c6.header_id,                 /* HEADER_ID,*/
                    null,                         /* SHIP_FROM_ORG_ID, */
                    null,                         /* SHIP_TO_ORG_ID, */
                    null,                         /* SCHEDULE_SHIP_DATE, */
                    null,                         /* SCHEDULE_ARRIVAL_DATE, */
                    null,                         /* FREIGHT_CARRIER_CODE, */
                    null,                         /* SHIPPING_METHOD_CODE, */
                    null,                         /* SHIPMENT_PRIORITY_CODE, */
                    null,                         /* SET_STATUS, */
                    0,                            /* CREATED_BY, */
                    sysdate,                      /* CREATION_DATE, */
                    0,                            /* UPDATED_BY, */
                    sysdate,                      /* UPDATE_DATE, */
                    0,                            /* UPDATE_LOGIN, */
                    c6.inventory_item_id,         /* INVENTORY_ITEM_ID, */
                    c6.unit_code,                         /* ORDERED_QUANTITY_UOM, */
                    null,                         /* LINE_TYPE_ID, */
                    null,                         /* SHIP_TOLERANCE_ABOVE, */
                    null                          /* SHIP_TOLERANCE_BELOW */
               );

               v_shipment_number := 0;

               v_ctr := 0;
               for c8 in c7 loop
				begin
				v_item_type_code := null;
					select item_type_code into
					v_item_type_code from
					oe_order_lines_all
					where
					line_id = c8.line_id;
				exception
				when no_data_found then
				null;
				end ;
				IF v_item_type_code = 'MODEL' OR
				 v_item_type_code = 'STANDARD' OR
				 v_item_type_code = 'KIT' THEN

                     v_shipment_number := v_shipment_number + 1;

                     update oe_order_lines_all ooal
                     set line_set_id     = v_set_id,
                         line_number     = p_line_number,
                         shipment_number = v_shipment_number
                     where ooal.line_id = c8.line_id;
			     END IF;
               end loop;
               v_commit_ctr := v_commit_ctr + 1;

               if v_commit_ctr > 500 then
                    commit;
                    v_commit_ctr := 0;
               end if;
          end loop;
          commit;

     exception
          when others then
               rollback;
               oe_upg_so.upgrade_insert_errors
               (
                    L_header_id => 0,
                    L_comments  => 'Line set updation failed on ora error: '||to_char(sqlcode)
               );
               commit;
   End Upgrade_Create_Line_Sets;

   Procedure Upgrade_Upd_Serv_Ref_line_id
      is
      cursor c1 is
      select header_id, line_id from oe_order_lines_all
      where item_type_code = 'SERVICE';
      v_new_line_id number;
      --
      l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
      --
   begin
          for c2 in c1 loop
             begin
                 select oul2.new_line_id  into v_new_line_id
                 from
                      oe_upgrade_log_v oul1,
                      oe_upgrade_log_v oul2,
                      so_lines_all sla1,
                      so_lines_all sla2
                 where oul1.new_line_id = c2.line_id
                 and   oul1.old_line_id = sla1.line_id
                 and   nvl(sla1.service_parent_line_id,0) = nvl(sla2.line_id,0)
                 and   sla2.line_id = oul2.old_line_id
                 and   nvl(oul1.old_line_detail_id,0) = nvl(oul2.old_line_detail_id,0)
                 and   nvl(oul1.picking_line_id,0) = nvl(oul2.picking_line_id,0);

                 update oe_order_lines_all
                 set service_reference_line_id = v_new_line_id
                 where line_Id = c2.line_id;
             exception
                 when no_data_found then
                     oe_upg_so.Upgrade_Insert_Errors(
                       c2.header_id,
                       'FYI Only: Service Ref.Line id not updated in OM for Line '
                           ||to_char(c2.line_id)||
                        'as it is not found in Order Entry table');
             end;
          end loop;
          commit;
   Exception
          when others then
               null;
   End Upgrade_Upd_Serv_Ref_line_id;


-- 1. Select all the models which have multiple config details.
-- 2. Select all the options for the model.
-- 3. Create new lines for the options of the model and for the model itself.
-- 4. Attach the config item to the model line.
-- 5. update the option quantity for the original option lines.

PROCEDURE Insert_Row
(   p_line_rec                      IN  OE_Order_PUB.Line_Rec_Type,
    p_orig_line_id                  IN  Number,
    p_upgraded_flag                 IN  Varchar2,
    p_apply_price_adj               IN  Varchar2 default 'Y'
);

FUNCTION Query_Row
(   p_line_id                       IN  NUMBER) RETURN OE_Order_PUB.Line_Rec_Type;

PROCEDURE insert_multiple_models IS

   cursor multiple_cfg_detail(p_ato_line_id IN NUMBER) IS
      select line_id,ordered_quantity,shipped_quantity
      from oe_order_lines_all
      where ato_line_id=p_ato_line_id
      and item_type_code = 'CONFIG';

   cursor multiple_cfg_parent IS
      select ato_line_id
      from oe_order_lines_all
      group by ato_line_id,item_type_code
      having item_type_code = 'CONFIG'
      and count(*) > 1;

   cursor model_and_options(p_ato_line_id IN NUMBER) IS
      select line_id,upgraded_flag
      from oe_order_lines_all
      where ato_line_id=p_ato_line_id
      and item_type_code <> 'CONFIG'
      order by component_code;

   cursor service_lines(p_service_reference_line_id IN NUMBER) IS
      select line_id,upgraded_flag
      from oe_order_lines_all
      where service_reference_line_id = p_service_reference_line_id;

   l_cfg_line_id          NUMBER;
   l_cfg_ordered_quantity NUMBER;
   l_cfg_shipped_quantity NUMBER;
   p_ato_line_id          NUMBER;
   l_line_id              NUMBER;
   l_service_count        NUMBER;
   l_service_line_id      NUMBER;
   l_s_upgraded_flag      VARCHAR2(1);

   l_model_rec            OE_ORDER_PUB.line_rec_type;
   l_line_rec             OE_ORDER_PUB.line_rec_type;
   l_service_line_rec     OE_ORDER_PUB.line_rec_type;
   l_new_line_rec         OE_ORDER_PUB.line_rec_type;
   l_upgraded_flag        VARCHAR2(1);


--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  -- Get the model line which has multiple config lines.
  OPEN multiple_cfg_parent;

  LOOP

     FETCH multiple_cfg_parent INTO p_ato_line_id;
     EXIT WHEN multiple_cfg_parent%notfound;

     -- Get the multiple config lines.
     OPEN multiple_cfg_detail(p_ato_line_id);
     FETCH multiple_cfg_detail
     INTO l_cfg_line_id,l_cfg_ordered_quantity,l_cfg_shipped_quantity;

     IF multiple_cfg_parent%found
     THEN

       LOOP

         -- Get next config line. You should create new model and options
         -- only for the second config detail.

         FETCH multiple_cfg_detail
         INTO l_cfg_line_id,l_cfg_ordered_quantity,l_cfg_shipped_quantity;
         EXIT WHEN multiple_cfg_detail%notfound;


--       dbms_output.put_line('Cfg Line Id: ' || l_cfg_line_id);
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'CFG LINE ID: ' || L_CFG_LINE_ID , 1 ) ;
         END IF;

         -- Create model and option lines for each of the config line.

         OPEN model_and_options(p_ato_line_id);

         LOOP

           FETCH model_and_options
           INTO l_line_id,l_upgraded_flag;
           EXIT WHEN model_and_options%notfound;


           l_line_rec                          := Query_Row(l_line_id);

           IF l_line_rec.item_type_code = 'MODEL' THEN
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'CREATING A NEW MODEL LINE' ) ;
              END IF;
              l_new_line_rec                   := l_line_rec;

              SELECT oe_order_lines_s.nextval
              INTO l_new_line_rec.line_id
              FROM dual;

              l_new_line_rec.ato_line_id       := l_new_line_rec.line_id;
              l_new_line_rec.top_model_line_id := l_new_line_rec.line_id;
              l_new_line_rec.link_to_line_id   := null;
              l_new_line_rec.ordered_quantity  := l_cfg_ordered_quantity;
              l_model_rec := l_new_line_rec;

                                IF l_debug_level  > 0 THEN
                                    oe_debug_pub.add(  'INSERTING A MODEL LINE :' || L_NEW_LINE_REC.LINE_ID ) ;
                                END IF;

              INSERT_ROW(l_new_line_rec, l_line_id,l_upgraded_flag);

		    -- Update the config item to point to the new model.

              UPDATE oe_order_lines_all
              SET ato_line_id = l_model_rec.line_id,
                  top_model_line_id = l_model_rec.line_id
              WHERE line_id=l_cfg_line_id;

              UPDATE oe_order_lines_all
              SET link_to_line_id = l_model_rec.line_id
              WHERE line_id=l_cfg_line_id;

              OPEN service_lines(l_line_id);

              LOOP
                  FETCH SERVICE_LINES INTO
                  l_service_line_id,l_s_upgraded_flag;
                  EXIT WHEN SERVICE_LINES%NOTFOUND;

                  l_service_line_rec    := Query_Row(l_service_line_id);

                  SELECT oe_order_lines_s.nextval
                  INTO l_service_line_rec.line_id
                  FROM dual;

                  l_service_line_rec.service_reference_line_id
                                                  := l_new_line_rec.line_id;
			   INSERT_ROW(l_service_line_rec,l_service_line_id,l_s_upgraded_flag);

              END LOOP;
              CLOSE service_lines;

           ELSE
--            dbms_output.put_line('Creating a new option line ');
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'CREATING A NEW OPTION LINE ' , 1 ) ;
              END IF;
              l_new_line_rec                   := l_line_rec;

              SELECT oe_order_lines_s.nextval
              INTO l_new_line_rec.line_id
              FROM dual;

              l_new_line_rec.ato_line_id       := l_model_rec.line_id;
              l_new_line_rec.top_model_line_id := l_model_rec.line_id;
              l_new_line_rec.link_to_line_id   := null;
              l_new_line_rec.ordered_quantity  :=
                   (l_new_line_rec.ordered_quantity / l_model_rec.ordered_quantity) *
                    l_cfg_ordered_quantity;

              INSERT_ROW(l_new_line_rec,l_line_id,l_upgraded_flag);

              OPEN service_lines(l_line_id);

              LOOP
                  FETCH SERVICE_LINES INTO
                  l_service_line_id,l_s_upgraded_flag;
                  EXIT WHEN SERVICE_LINES%NOTFOUND;

                  l_service_line_rec    := Query_Row(l_service_line_id);

                  SELECT oe_order_lines_s.nextval
                  INTO l_service_line_rec.line_id
                  FROM dual;

                  l_service_line_rec.service_reference_line_id
                                                  := l_new_line_rec.line_id;

                  INSERT_ROW(l_service_line_rec,l_service_line_id,l_s_upgraded_flag);

              END LOOP;
              CLOSE service_lines;
           END IF;

         END LOOP;

         CLOSE model_and_options;

       END LOOP;

     END IF;

     CLOSE multiple_cfg_detail;

  END LOOP;

END insert_multiple_models;


FUNCTION Query_Row
(   p_line_id     IN NUMBER) RETURN OE_Order_PUB.Line_Rec_Type
IS
l_line_rec                    OE_Order_PUB.Line_Rec_Type;
l_line_tbl                    OE_Order_PUB.Line_Tbl_Type;

CURSOR l_line_csr IS
    SELECT  ACCOUNTING_RULE_ID
    ,       ACTUAL_ARRIVAL_DATE
    ,       ACTUAL_SHIPMENT_DATE
    ,       AGREEMENT_ID
    ,       ARRIVAL_SET_ID
    ,       ATO_LINE_ID
    ,       ATTRIBUTE1
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       AUTO_SELECTED_QUANTITY
    ,       AUTHORIZED_TO_SHIP_FLAG
    ,       BOOKED_FLAG
    ,       CANCELLED_FLAG
    ,       CANCELLED_QUANTITY
    ,       COMPONENT_CODE
    ,       COMPONENT_NUMBER
    ,       COMPONENT_SEQUENCE_ID
    ,       CONFIG_HEADER_ID
    ,       CONFIG_REV_NBR
    ,       CONFIG_DISPLAY_SEQUENCE
    ,       CONFIGURATION_ID
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       CREDIT_INVOICE_LINE_ID
    ,       CUSTOMER_DOCK_CODE
    ,       CUSTOMER_JOB
    ,       CUSTOMER_PRODUCTION_LINE
    ,       CUST_PRODUCTION_SEQ_NUM
    ,       CUSTOMER_TRX_LINE_ID
    ,       CUST_MODEL_SERIAL_NUMBER
    ,       CUST_PO_NUMBER
    ,       DELIVERY_LEAD_TIME
    ,       DELIVER_TO_CONTACT_ID
    ,       DELIVER_TO_ORG_ID
    ,       DEMAND_BUCKET_TYPE_CODE
    ,       DEMAND_CLASS_CODE
    ,       DEP_PLAN_REQUIRED_FLAG
    ,       EARLIEST_ACCEPTABLE_DATE
    ,       END_ITEM_UNIT_NUMBER
    ,       EXPLOSION_DATE
    ,       FIRST_ACK_CODE
    ,       FIRST_ACK_DATE
    ,       FOB_POINT_CODE
    ,       FREIGHT_CARRIER_CODE
    ,       FREIGHT_TERMS_CODE
    ,       FULFILLED_QUANTITY
    ,       FULFILLED_FLAG
    ,       FULFILLMENT_METHOD_CODE
    ,       FULFILLMENT_DATE
    ,       GLOBAL_ATTRIBUTE1
    ,       GLOBAL_ATTRIBUTE10
    ,       GLOBAL_ATTRIBUTE11
    ,       GLOBAL_ATTRIBUTE12
    ,       GLOBAL_ATTRIBUTE13
    ,       GLOBAL_ATTRIBUTE14
    ,       GLOBAL_ATTRIBUTE15
    ,       GLOBAL_ATTRIBUTE16
    ,       GLOBAL_ATTRIBUTE17
    ,       GLOBAL_ATTRIBUTE18
    ,       GLOBAL_ATTRIBUTE19
    ,       GLOBAL_ATTRIBUTE2
    ,       GLOBAL_ATTRIBUTE20
    ,       GLOBAL_ATTRIBUTE3
    ,       GLOBAL_ATTRIBUTE4
    ,       GLOBAL_ATTRIBUTE5
    ,       GLOBAL_ATTRIBUTE6
    ,       GLOBAL_ATTRIBUTE7
    ,       GLOBAL_ATTRIBUTE8
    ,       GLOBAL_ATTRIBUTE9
    ,       GLOBAL_ATTRIBUTE_CATEGORY
    ,       HEADER_ID
    ,       INDUSTRY_ATTRIBUTE1
    ,       INDUSTRY_ATTRIBUTE10
    ,       INDUSTRY_ATTRIBUTE11
    ,       INDUSTRY_ATTRIBUTE12
    ,       INDUSTRY_ATTRIBUTE13
    ,       INDUSTRY_ATTRIBUTE14
    ,       INDUSTRY_ATTRIBUTE15
    ,       INDUSTRY_ATTRIBUTE16
    ,       INDUSTRY_ATTRIBUTE17
    ,       INDUSTRY_ATTRIBUTE18
    ,       INDUSTRY_ATTRIBUTE19
    ,       INDUSTRY_ATTRIBUTE20
    ,       INDUSTRY_ATTRIBUTE21
    ,       INDUSTRY_ATTRIBUTE22
    ,       INDUSTRY_ATTRIBUTE23
    ,       INDUSTRY_ATTRIBUTE24
    ,       INDUSTRY_ATTRIBUTE25
    ,       INDUSTRY_ATTRIBUTE26
    ,       INDUSTRY_ATTRIBUTE27
    ,       INDUSTRY_ATTRIBUTE28
    ,       INDUSTRY_ATTRIBUTE29
    ,       INDUSTRY_ATTRIBUTE30
    ,       INDUSTRY_ATTRIBUTE2
    ,       INDUSTRY_ATTRIBUTE3
    ,       INDUSTRY_ATTRIBUTE4
    ,       INDUSTRY_ATTRIBUTE5
    ,       INDUSTRY_ATTRIBUTE6
    ,       INDUSTRY_ATTRIBUTE7
    ,       INDUSTRY_ATTRIBUTE8
    ,       INDUSTRY_ATTRIBUTE9
    ,       INDUSTRY_CONTEXT
    ,       INTMED_SHIP_TO_CONTACT_ID
    ,       INTMED_SHIP_TO_ORG_ID
    ,       INVENTORY_ITEM_ID
    ,       INVOICE_INTERFACE_STATUS_CODE
    ,       INVOICE_TO_CONTACT_ID
    ,       INVOICE_TO_ORG_ID
    ,       INVOICED_QUANTITY
    ,       INVOICING_RULE_ID
    ,       ORDERED_ITEM_ID
    ,       ITEM_IDENTIFIER_TYPE
    ,       ORDERED_ITEM
    ,       ITEM_REVISION
    ,       ITEM_TYPE_CODE
    ,       LAST_ACK_CODE
    ,       LAST_ACK_DATE
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LATEST_ACCEPTABLE_DATE
    ,       LINE_CATEGORY_CODE
    ,       LINE_ID
    ,       LINE_NUMBER
    ,       LINE_TYPE_ID
    ,       LINK_TO_LINE_ID
    ,       MODEL_GROUP_NUMBER
  --  ,       MFG_COMPONENT_SEQUENCE_ID
    ,       OPEN_FLAG
    ,       OPTION_FLAG
    ,       OPTION_NUMBER
    ,       ORDERED_QUANTITY
    ,       ORDER_QUANTITY_UOM
    ,       ORG_ID
    ,       ORIG_SYS_DOCUMENT_REF
    ,       ORIG_SYS_LINE_REF
    ,       OVER_SHIP_REASON_CODE
    ,       OVER_SHIP_RESOLVED_FLAG
    ,       PAYMENT_TERM_ID
    ,       PLANNING_PRIORITY
    ,       PRICE_LIST_ID
    ,       PRICING_ATTRIBUTE1
    ,       PRICING_ATTRIBUTE10
    ,       PRICING_ATTRIBUTE2
    ,       PRICING_ATTRIBUTE3
    ,       PRICING_ATTRIBUTE4
    ,       PRICING_ATTRIBUTE5
    ,       PRICING_ATTRIBUTE6
    ,       PRICING_ATTRIBUTE7
    ,       PRICING_ATTRIBUTE8
    ,       PRICING_ATTRIBUTE9
    ,       PRICING_CONTEXT
    ,       PRICING_DATE
    ,       PRICING_QUANTITY
    ,       PRICING_QUANTITY_UOM
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       PROJECT_ID
    ,       PROMISE_DATE
    ,       RE_SOURCE_FLAG
    ,       REFERENCE_CUSTOMER_TRX_LINE_ID
    ,       REFERENCE_HEADER_ID
    ,       REFERENCE_LINE_ID
    ,       REFERENCE_TYPE
    ,       REQUEST_DATE
    ,       REQUEST_ID
    ,       RETURN_ATTRIBUTE1
    ,       RETURN_ATTRIBUTE10
    ,       RETURN_ATTRIBUTE11
    ,       RETURN_ATTRIBUTE12
    ,       RETURN_ATTRIBUTE13
    ,       RETURN_ATTRIBUTE14
    ,       RETURN_ATTRIBUTE15
    ,       RETURN_ATTRIBUTE2
    ,       RETURN_ATTRIBUTE3
    ,       RETURN_ATTRIBUTE4
    ,       RETURN_ATTRIBUTE5
    ,       RETURN_ATTRIBUTE6
    ,       RETURN_ATTRIBUTE7
    ,       RETURN_ATTRIBUTE8
    ,       RETURN_ATTRIBUTE9
    ,       RETURN_CONTEXT
    ,       RETURN_REASON_CODE
    ,       RLA_SCHEDULE_TYPE_CODE
    ,       SALESREP_ID
    ,       SCHEDULE_ARRIVAL_DATE
    ,       SCHEDULE_SHIP_DATE
    ,       SCHEDULE_STATUS_CODE
    ,       SHIPMENT_NUMBER
    ,       SHIPMENT_PRIORITY_CODE
    ,       SHIPPED_QUANTITY
    ,       SHIPPING_METHOD_CODE
    ,       SHIPPING_QUANTITY
    ,       SHIPPING_QUANTITY_UOM
    ,       SHIP_FROM_ORG_ID
    ,       SHIP_SET_ID
    ,       SHIP_TOLERANCE_ABOVE
    ,       SHIP_TOLERANCE_BELOW
    ,       SHIPPABLE_FLAG
    ,       SHIPPING_INTERFACED_FLAG
    ,       SHIP_TO_CONTACT_ID
    ,       SHIP_TO_ORG_ID
    ,       SHIP_MODEL_COMPLETE_FLAG
    ,       SOLD_TO_ORG_ID
    ,       SOLD_FROM_ORG_ID
    ,       SORT_ORDER
    ,       SOURCE_DOCUMENT_ID
    ,       SOURCE_DOCUMENT_LINE_ID
    ,       SOURCE_DOCUMENT_TYPE_ID
    ,       SOURCE_TYPE_CODE
    ,       SPLIT_FROM_LINE_ID
    ,       LINE_SET_ID
    ,       SPLIT_BY
    ,       MODEL_REMNANT_FLAG
    ,       TASK_ID
    ,       TAX_CODE
    ,       TAX_DATE
    ,       TAX_EXEMPT_FLAG
    ,       TAX_EXEMPT_NUMBER
    ,       TAX_EXEMPT_REASON_CODE
    ,       TAX_POINT_CODE
    ,       TAX_RATE
    ,       TAX_VALUE
    ,       TOP_MODEL_LINE_ID
    ,       UNIT_LIST_PRICE
    ,       UNIT_SELLING_PRICE
    ,       VISIBLE_DEMAND_FLAG
    ,       VEH_CUS_ITEM_CUM_KEY_ID
    ,       SHIPPING_INSTRUCTIONS
    ,       PACKING_INSTRUCTIONS
    ,       SERVICE_TXN_REASON_CODE
    ,       SERVICE_TXN_COMMENTS
    ,       SERVICE_DURATION
    ,       SERVICE_PERIOD
    ,       SERVICE_START_DATE
    ,       SERVICE_END_DATE
    ,       SERVICE_COTERMINATE_FLAG
    ,       UNIT_LIST_PERCENT
    ,       UNIT_SELLING_PERCENT
    ,       UNIT_PERCENT_BASE_PRICE
    ,       SERVICE_NUMBER
    ,       SERVICE_REFERENCE_TYPE_CODE
    ,       SERVICE_REFERENCE_LINE_ID
    ,       SERVICE_REFERENCE_SYSTEM_ID
    ,       TP_CONTEXT
    ,       TP_ATTRIBUTE1
    ,       TP_ATTRIBUTE2
    ,       TP_ATTRIBUTE3
    ,       TP_ATTRIBUTE4
    ,       TP_ATTRIBUTE5
    ,       TP_ATTRIBUTE6
    ,       TP_ATTRIBUTE7
    ,       TP_ATTRIBUTE8
    ,       TP_ATTRIBUTE9
    ,       TP_ATTRIBUTE10
    ,       TP_ATTRIBUTE11
    ,       TP_ATTRIBUTE12
    ,       TP_ATTRIBUTE13
    ,       TP_ATTRIBUTE14
    ,       TP_ATTRIBUTE15
    ,       FLOW_STATUS_CODE
    ,       MARKETING_SOURCE_CODE_ID
    ,       CALCULATE_PRICE_FLAG
    ,       COMMITMENT_ID
    ,       ORDER_SOURCE_ID        -- aksingh
    FROM    OE_ORDER_LINES_ALL
    WHERE  LINE_ID = p_line_id ;


--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    --  Loop over fetched records

    FOR l_implicit_rec IN l_line_csr LOOP

        l_line_rec.accounting_rule_id  := l_implicit_rec.ACCOUNTING_RULE_ID;
        l_line_rec.actual_arrival_date := l_implicit_rec.ACTUAL_ARRIVAL_DATE;
        l_line_rec.actual_shipment_date := l_implicit_rec.ACTUAL_SHIPMENT_DATE;
        l_line_rec.agreement_id        := l_implicit_rec.AGREEMENT_ID;
        l_line_rec.arrival_Set_id      := l_implicit_rec.ARRIVAL_SET_ID;
        l_line_rec.ato_line_id         := l_implicit_rec.ATO_LINE_ID;
        l_line_rec.attribute1          := l_implicit_rec.ATTRIBUTE1;
        l_line_rec.attribute10         := l_implicit_rec.ATTRIBUTE10;
        l_line_rec.attribute11         := l_implicit_rec.ATTRIBUTE11;
        l_line_rec.attribute12         := l_implicit_rec.ATTRIBUTE12;
        l_line_rec.attribute13         := l_implicit_rec.ATTRIBUTE13;
        l_line_rec.attribute14         := l_implicit_rec.ATTRIBUTE14;
        l_line_rec.attribute15         := l_implicit_rec.ATTRIBUTE15;
        l_line_rec.attribute2          := l_implicit_rec.ATTRIBUTE2;
        l_line_rec.attribute3          := l_implicit_rec.ATTRIBUTE3;
        l_line_rec.attribute4          := l_implicit_rec.ATTRIBUTE4;
        l_line_rec.attribute5          := l_implicit_rec.ATTRIBUTE5;
        l_line_rec.attribute6          := l_implicit_rec.ATTRIBUTE6;
        l_line_rec.attribute7          := l_implicit_rec.ATTRIBUTE7;
        l_line_rec.attribute8          := l_implicit_rec.ATTRIBUTE8;
        l_line_rec.attribute9          := l_implicit_rec.ATTRIBUTE9;
        l_line_rec.auto_selected_quantity  := l_implicit_rec.AUTO_SELECTED_QUANTITY;
        l_line_rec.Authorized_to_ship_flag  := l_implicit_rec.Authorized_to_ship_flag;
        l_line_rec.booked_flag          := l_implicit_rec.booked_flag;
        l_line_rec.cancelled_flag       := l_implicit_rec.cancelled_flag;
        l_line_rec.cancelled_quantity  := l_implicit_rec.CANCELLED_QUANTITY;
        l_line_rec.component_code      := l_implicit_rec.COMPONENT_CODE;
        l_line_rec.component_number    := l_implicit_rec.COMPONENT_NUMBER;
        l_line_rec.component_sequence_id := l_implicit_rec.COMPONENT_SEQUENCE_ID;
        l_line_rec.config_header_id := l_implicit_rec.CONFIG_HEADER_ID;
        l_line_rec.config_rev_nbr := l_implicit_rec.CONFIG_REV_NBR;
        l_line_rec.config_display_sequence := l_implicit_rec.CONFIG_DISPLAY_SEQUENCE;
        l_line_rec.configuration_id    := l_implicit_rec.CONFIGURATION_ID;
        l_line_rec.context             := l_implicit_rec.CONTEXT;

        l_line_rec.created_by          := l_implicit_rec.CREATED_BY;
        l_line_rec.creation_date       := l_implicit_rec.CREATION_DATE;
        l_line_rec.credit_invoice_line_id  := l_implicit_rec.CREDIT_INVOICE_LINE_ID;
        l_line_rec.customer_dock_code  := l_implicit_rec.CUSTOMER_DOCK_CODE;
        l_line_rec.customer_job        := l_implicit_rec.CUSTOMER_JOB;
        l_line_rec.customer_production_line := l_implicit_rec.CUSTOMER_PRODUCTION_LINE;
        l_line_rec.cust_production_seq_num := l_implicit_rec.CUST_PRODUCTION_SEQ_NUM;
        l_line_rec.customer_trx_line_id := l_implicit_rec.CUSTOMER_TRX_LINE_ID;
        l_line_rec.cust_model_serial_number := l_implicit_rec.CUST_MODEL_SERIAL_NUMBER;
        l_line_rec.cust_po_number      := l_implicit_rec.CUST_PO_NUMBER;
        l_line_rec.delivery_lead_time  := l_implicit_rec.DELIVERY_LEAD_TIME;
        l_line_rec.deliver_to_contact_id := l_implicit_rec.DELIVER_TO_CONTACT_ID;
        l_line_rec.deliver_to_org_id   := l_implicit_rec.DELIVER_TO_ORG_ID;
        l_line_rec.demand_bucket_type_code := l_implicit_rec.DEMAND_BUCKET_TYPE_CODE;
        l_line_rec.demand_class_code   := l_implicit_rec.DEMAND_CLASS_CODE;
        l_line_rec.dep_plan_required_flag := l_implicit_rec.DEP_PLAN_REQUIRED_FLAG;

        l_line_rec.earliest_acceptable_date   := l_implicit_rec.EARLIEST_ACCEPTABLE_DATE;
	   l_line_rec.end_item_unit_number       := l_implicit_rec.END_ITEM_UNIT_NUMBER;
        l_line_rec.explosion_date   := l_implicit_rec.EXPLOSION_DATE;
        l_line_rec.first_ack_code   := l_implicit_rec.FIRST_ACK_CODE;
        l_line_rec.first_ack_date   := l_implicit_rec.FIRST_ACK_DATE;
        l_line_rec.fob_point_code      := l_implicit_rec.FOB_POINT_CODE;
        l_line_rec.freight_carrier_code  := l_implicit_rec.FREIGHT_CARRIER_CODE;
        l_line_rec.freight_terms_code  := l_implicit_rec.FREIGHT_TERMS_CODE;
        l_line_rec.fulfilled_quantity  := l_implicit_rec.FULFILLED_QUANTITY;
        l_line_rec.fulfilled_flag  := l_implicit_rec.FULFILLED_FLAG;
        l_line_rec.fulfillment_method_code  := l_implicit_rec.FULFILLMENT_METHOD_CODE;
        l_line_rec.fulfillment_date    := l_implicit_rec.FULFILLMENT_DATE;
        l_line_rec.global_attribute1   := l_implicit_rec.GLOBAL_ATTRIBUTE1;
        l_line_rec.global_attribute10  := l_implicit_rec.GLOBAL_ATTRIBUTE10;
        l_line_rec.global_attribute11  := l_implicit_rec.GLOBAL_ATTRIBUTE11;
        l_line_rec.global_attribute12  := l_implicit_rec.GLOBAL_ATTRIBUTE12;
        l_line_rec.global_attribute13  := l_implicit_rec.GLOBAL_ATTRIBUTE13;
        l_line_rec.global_attribute14  := l_implicit_rec.GLOBAL_ATTRIBUTE14;
        l_line_rec.global_attribute15  := l_implicit_rec.GLOBAL_ATTRIBUTE15;
        l_line_rec.global_attribute16  := l_implicit_rec.GLOBAL_ATTRIBUTE16;
        l_line_rec.global_attribute17  := l_implicit_rec.GLOBAL_ATTRIBUTE17;
        l_line_rec.global_attribute18  := l_implicit_rec.GLOBAL_ATTRIBUTE18;
        l_line_rec.global_attribute19  := l_implicit_rec.GLOBAL_ATTRIBUTE19;
        l_line_rec.global_attribute2   := l_implicit_rec.GLOBAL_ATTRIBUTE2;
        l_line_rec.global_attribute20  := l_implicit_rec.GLOBAL_ATTRIBUTE20;
        l_line_rec.global_attribute3   := l_implicit_rec.GLOBAL_ATTRIBUTE3;
        l_line_rec.global_attribute4   := l_implicit_rec.GLOBAL_ATTRIBUTE4;
        l_line_rec.global_attribute5   := l_implicit_rec.GLOBAL_ATTRIBUTE5;
        l_line_rec.global_attribute6   := l_implicit_rec.GLOBAL_ATTRIBUTE6;
        l_line_rec.global_attribute7   := l_implicit_rec.GLOBAL_ATTRIBUTE7;
        l_line_rec.global_attribute8   := l_implicit_rec.GLOBAL_ATTRIBUTE8;
        l_line_rec.global_attribute9   := l_implicit_rec.GLOBAL_ATTRIBUTE9;
        l_line_rec.global_attribute_category := l_implicit_rec.GLOBAL_ATTRIBUTE_CATEGORY;
        l_line_rec.header_id           := l_implicit_rec.HEADER_ID;
        l_line_rec.industry_attribute1 := l_implicit_rec.INDUSTRY_ATTRIBUTE1;
        l_line_rec.industry_attribute10 := l_implicit_rec.INDUSTRY_ATTRIBUTE10;
        l_line_rec.industry_attribute11 := l_implicit_rec.INDUSTRY_ATTRIBUTE11;
        l_line_rec.industry_attribute12 := l_implicit_rec.INDUSTRY_ATTRIBUTE12;
        l_line_rec.industry_attribute13 := l_implicit_rec.INDUSTRY_ATTRIBUTE13;
        l_line_rec.industry_attribute14 := l_implicit_rec.INDUSTRY_ATTRIBUTE14;
        l_line_rec.industry_attribute15 := l_implicit_rec.INDUSTRY_ATTRIBUTE15;
         l_line_rec.industry_attribute16 := l_implicit_rec.INDUSTRY_ATTRIBUTE16;
         l_line_rec.industry_attribute17 := l_implicit_rec.INDUSTRY_ATTRIBUTE17;
        l_line_rec.industry_attribute18 := l_implicit_rec.INDUSTRY_ATTRIBUTE18;
        l_line_rec.industry_attribute19 := l_implicit_rec.INDUSTRY_ATTRIBUTE19;
        l_line_rec.industry_attribute20 := l_implicit_rec.INDUSTRY_ATTRIBUTE20;
        l_line_rec.industry_attribute21 := l_implicit_rec.INDUSTRY_ATTRIBUTE21;
        l_line_rec.industry_attribute22 := l_implicit_rec.INDUSTRY_ATTRIBUTE22;
        l_line_rec.industry_attribute23:= l_implicit_rec.INDUSTRY_ATTRIBUTE23;
        l_line_rec.industry_attribute24 := l_implicit_rec.INDUSTRY_ATTRIBUTE24;
        l_line_rec.industry_attribute25 := l_implicit_rec.INDUSTRY_ATTRIBUTE25;
        l_line_rec.industry_attribute26 := l_implicit_rec.INDUSTRY_ATTRIBUTE26;
        l_line_rec.industry_attribute27 := l_implicit_rec.INDUSTRY_ATTRIBUTE27;
        l_line_rec.industry_attribute28 := l_implicit_rec.INDUSTRY_ATTRIBUTE28;
        l_line_rec.industry_attribute29 := l_implicit_rec.INDUSTRY_ATTRIBUTE29;
        l_line_rec.industry_attribute30 := l_implicit_rec.INDUSTRY_ATTRIBUTE30;
        l_line_rec.industry_attribute2 := l_implicit_rec.INDUSTRY_ATTRIBUTE2;
        l_line_rec.industry_attribute3 := l_implicit_rec.INDUSTRY_ATTRIBUTE3;
        l_line_rec.industry_attribute4 := l_implicit_rec.INDUSTRY_ATTRIBUTE4;
        l_line_rec.industry_attribute5 := l_implicit_rec.INDUSTRY_ATTRIBUTE5;
        l_line_rec.industry_attribute6 := l_implicit_rec.INDUSTRY_ATTRIBUTE6;
        l_line_rec.industry_attribute7 := l_implicit_rec.INDUSTRY_ATTRIBUTE7;
        l_line_rec.industry_attribute8 := l_implicit_rec.INDUSTRY_ATTRIBUTE8;
        l_line_rec.industry_attribute9 := l_implicit_rec.INDUSTRY_ATTRIBUTE9;
        l_line_rec.industry_context    := l_implicit_rec.INDUSTRY_CONTEXT;
        l_line_rec.intermed_ship_to_contact_id := l_implicit_rec.INTMED_SHIP_TO_CONTACT_ID;
        l_line_rec.intermed_ship_to_org_id := l_implicit_rec.INTMED_SHIP_TO_ORG_ID;
        l_line_rec.inventory_item_id   := l_implicit_rec.INVENTORY_ITEM_ID;
        l_line_rec.invoice_interface_status_code := l_implicit_rec.INVOICE_INTERFACE_STATUS_CODE;

        l_line_rec.invoice_to_contact_id := l_implicit_rec.INVOICE_TO_CONTACT_ID;
        l_line_rec.invoice_to_org_id   := l_implicit_rec.INVOICE_TO_ORG_ID;
        l_line_rec.invoiced_quantity   := l_implicit_rec.INVOICED_QUANTITY;
        l_line_rec.invoicing_rule_id   := l_implicit_rec.INVOICING_RULE_ID;
        l_line_rec.ordered_item_id             := l_implicit_rec.ORDERED_ITEM_ID;
        l_line_rec.item_identifier_type := l_implicit_rec.ITEM_IDENTIFIER_TYPE;
        l_line_rec.ordered_item          := l_implicit_rec.ORDERED_ITEM;
        l_line_rec.item_revision       := l_implicit_rec.ITEM_REVISION;
        l_line_rec.item_type_code      := l_implicit_rec.ITEM_TYPE_CODE;
        l_line_rec.last_ack_code       := l_implicit_rec.LAST_ACK_CODE;
        l_line_rec.last_ack_date       := l_implicit_rec.LAST_ACK_DATE;
        l_line_rec.last_updated_by     := l_implicit_rec.LAST_UPDATED_BY;
        l_line_rec.last_update_date    := l_implicit_rec.LAST_UPDATE_DATE;
        l_line_rec.last_update_login   := l_implicit_rec.LAST_UPDATE_LOGIN;
        l_line_rec.latest_acceptable_date   := l_implicit_rec.LATEST_ACCEPTABLE_DATE;
        l_line_rec.line_category_code  := l_implicit_rec.LINE_CATEGORY_CODE;
        l_line_rec.line_id             := l_implicit_rec.LINE_ID;
        l_line_rec.line_number         := l_implicit_rec.LINE_NUMBER;
        l_line_rec.line_type_id        := l_implicit_rec.LINE_TYPE_ID;
        l_line_rec.link_to_line_id     := l_implicit_rec.LINK_TO_LINE_ID;

        l_line_rec.model_group_number := l_implicit_rec.MODEL_GROUP_NUMBER;
       -- l_line_rec.mfg_component_sequence_id := l_implicit_rec.MFG_COMPONENT_SEQUENCE_ID;
        l_line_rec.open_flag           := l_implicit_rec.open_flag;
        l_line_rec.option_flag         := l_implicit_rec.OPTION_FLAG;
        l_line_rec.option_number       := l_implicit_rec.OPTION_NUMBER;
        l_line_rec.ordered_quantity    := l_implicit_rec.ORDERED_QUANTITY;
        l_line_rec.order_quantity_uom  := l_implicit_rec.ORDER_QUANTITY_UOM;
        l_line_rec.org_id              := l_implicit_rec.ORG_ID;
        l_line_rec.orig_sys_document_ref := l_implicit_rec.ORIG_SYS_DOCUMENT_REF;
        l_line_rec.orig_sys_line_ref := l_implicit_rec.ORIG_SYS_LINE_REF;
       l_line_rec.over_ship_reason_code := l_implicit_rec.OVER_SHIP_REASON_CODE;
        l_line_rec.over_ship_resolved_flag := l_implicit_rec.OVER_SHIP_RESOLVED_FLAG;
        l_line_rec.source_document_line_id := l_implicit_rec.SOURCE_DOCUMENT_LINE_ID;
        l_line_rec.payment_term_id     := l_implicit_rec.PAYMENT_TERM_ID;
        l_line_rec.planning_priority     := l_implicit_rec.PLANNING_PRIORITY;
        l_line_rec.price_list_id       := l_implicit_rec.PRICE_LIST_ID;
        l_line_rec.pricing_attribute1  := l_implicit_rec.PRICING_ATTRIBUTE1;
        l_line_rec.pricing_attribute10 := l_implicit_rec.PRICING_ATTRIBUTE10;
        l_line_rec.pricing_attribute2  := l_implicit_rec.PRICING_ATTRIBUTE2;
        l_line_rec.pricing_attribute3  := l_implicit_rec.PRICING_ATTRIBUTE3;
        l_line_rec.pricing_attribute4  := l_implicit_rec.PRICING_ATTRIBUTE4;
        l_line_rec.pricing_attribute5  := l_implicit_rec.PRICING_ATTRIBUTE5;
        l_line_rec.pricing_attribute6  := l_implicit_rec.PRICING_ATTRIBUTE6;
        l_line_rec.pricing_attribute7  := l_implicit_rec.PRICING_ATTRIBUTE7;
        l_line_rec.pricing_attribute8  := l_implicit_rec.PRICING_ATTRIBUTE8;
        l_line_rec.pricing_attribute9  := l_implicit_rec.PRICING_ATTRIBUTE9;
        l_line_rec.pricing_context     := l_implicit_rec.PRICING_CONTEXT;
        l_line_rec.pricing_date        := l_implicit_rec.PRICING_DATE;
        l_line_rec.pricing_quantity    := l_implicit_rec.PRICING_QUANTITY;
        l_line_rec.pricing_quantity_uom := l_implicit_rec.PRICING_QUANTITY_UOM;
        l_line_rec.program_application_id := l_implicit_rec.PROGRAM_APPLICATION_ID;
        l_line_rec.program_id          := l_implicit_rec.PROGRAM_ID;
        l_line_rec.program_update_date := l_implicit_rec.PROGRAM_UPDATE_DATE;
        l_line_rec.project_id          := l_implicit_rec.PROJECT_ID;
        l_line_rec.promise_date        := l_implicit_rec.PROMISE_DATE;
        l_line_rec.re_source_flag      := l_implicit_rec.RE_SOURCE_FLAG;
        l_line_rec.reference_customer_trx_line_id := l_implicit_rec.reference_customer_trx_line_id;
        l_line_rec.reference_header_id := l_implicit_rec.REFERENCE_HEADER_ID;
        l_line_rec.reference_line_id   := l_implicit_rec.REFERENCE_LINE_ID;
        l_line_rec.reference_type      := l_implicit_rec.REFERENCE_TYPE;

        l_line_rec.request_date        := l_implicit_rec.REQUEST_DATE;
        l_line_rec.request_id          := l_implicit_rec.REQUEST_ID;
        l_line_rec.return_attribute1   := l_implicit_rec.RETURN_ATTRIBUTE1;
        l_line_rec.return_attribute10  := l_implicit_rec.RETURN_ATTRIBUTE10;
        l_line_rec.return_attribute11  := l_implicit_rec.RETURN_ATTRIBUTE11;
        l_line_rec.return_attribute12  := l_implicit_rec.RETURN_ATTRIBUTE12;
        l_line_rec.return_attribute13  := l_implicit_rec.RETURN_ATTRIBUTE13;
        l_line_rec.return_attribute14  := l_implicit_rec.RETURN_ATTRIBUTE14;
        l_line_rec.return_attribute15  := l_implicit_rec.RETURN_ATTRIBUTE15;
        l_line_rec.return_attribute2   := l_implicit_rec.RETURN_ATTRIBUTE2;
        l_line_rec.return_attribute3   := l_implicit_rec.RETURN_ATTRIBUTE3;
        l_line_rec.return_attribute4   := l_implicit_rec.RETURN_ATTRIBUTE4;
        l_line_rec.return_attribute5   := l_implicit_rec.RETURN_ATTRIBUTE5;
        l_line_rec.return_attribute6   := l_implicit_rec.RETURN_ATTRIBUTE6;
        l_line_rec.return_attribute7   := l_implicit_rec.RETURN_ATTRIBUTE7;
        l_line_rec.return_attribute8   := l_implicit_rec.RETURN_ATTRIBUTE8;
        l_line_rec.return_attribute9   := l_implicit_rec.RETURN_ATTRIBUTE9;
        l_line_rec.return_context      := l_implicit_rec.RETURN_CONTEXT;
        l_line_rec.return_reason_code      := l_implicit_rec.RETURN_REASON_CODE;
         l_line_rec.salesrep_id      := l_implicit_rec.SALESREP_ID;
        l_line_rec.rla_schedule_type_code := l_implicit_rec.RLA_SCHEDULE_TYPE_CODE;
        l_line_rec.schedule_arrival_date      := l_implicit_rec.SCHEDULE_ARRIVAL_DATE;
        l_line_rec.schedule_ship_date       := l_implicit_rec.SCHEDULE_SHIP_DATE;
        l_line_rec.schedule_status_code       := l_implicit_rec.SCHEDULE_STATUS_CODE;
        l_line_rec.shipment_number     := l_implicit_rec.SHIPMENT_NUMBER;
        l_line_rec.shipment_priority_code := l_implicit_rec.SHIPMENT_PRIORITY_CODE;
        l_line_rec.shipped_quantity    := l_implicit_rec.SHIPPED_QUANTITY;
        l_line_rec.shipping_method_code := l_implicit_rec.SHIPPING_METHOD_CODE;
        l_line_rec.shipping_quantity   := l_implicit_rec.SHIPPING_QUANTITY;
        l_line_rec.shipping_quantity_uom := l_implicit_rec.SHIPPING_QUANTITY_UOM;
        l_line_rec.ship_from_org_id    := l_implicit_rec.SHIP_FROM_ORG_ID;
        l_line_rec.ship_set_id    := l_implicit_rec.SHIP_SET_ID;
        l_line_rec.ship_tolerance_above := l_implicit_rec.SHIP_TOLERANCE_ABOVE;
        l_line_rec.ship_tolerance_below := l_implicit_rec.SHIP_TOLERANCE_BELOW;
        l_line_rec.shippable_flag := l_implicit_rec.SHIPPABLE_FLAG;
        l_line_rec.shipping_interfaced_flag := l_implicit_rec.SHIPPING_INTERFACED_FLAG;
        l_line_rec.ship_to_contact_id  := l_implicit_rec.SHIP_TO_CONTACT_ID;
        l_line_rec.ship_to_org_id      := l_implicit_rec.SHIP_TO_ORG_ID;
        l_line_rec.ship_model_complete_flag      := l_implicit_rec.SHIP_MODEL_COMPLETE_FLAG;

        l_line_rec.sold_to_org_id      := l_implicit_rec.SOLD_TO_ORG_ID;
        l_line_rec.sold_from_org_id      := l_implicit_rec.SOLD_FROM_ORG_ID;
        l_line_rec.sort_order          := l_implicit_rec.SORT_ORDER;
        l_line_rec.source_document_id := l_implicit_rec.SOURCE_DOCUMENT_ID;
        l_line_rec.source_document_line_id := l_implicit_rec.SOURCE_DOCUMENT_LINE_ID;
        l_line_rec.source_document_type_id := l_implicit_rec.SOURCE_DOCUMENT_TYPE_ID;
        l_line_rec.source_type_code        := l_implicit_rec.SOURCE_TYPE_CODE;
        l_line_rec.split_from_line_id      := l_implicit_rec.SPLIT_FROM_LINE_ID;
        l_line_rec.line_set_id             := l_implicit_rec.LINE_SET_ID;
        l_line_rec.split_by      := l_implicit_rec.SPLIT_BY;
        l_line_rec.model_remnant_flag := l_implicit_rec.MODEL_REMNANT_FLAG;
        l_line_rec.task_id             := l_implicit_rec.TASK_ID;
        l_line_rec.tax_code            := l_implicit_rec.TAX_CODE;
        l_line_rec.tax_date            := l_implicit_rec.TAX_DATE;
        l_line_rec.tax_exempt_flag     := l_implicit_rec.TAX_EXEMPT_FLAG;
        l_line_rec.tax_exempt_number   := l_implicit_rec.TAX_EXEMPT_NUMBER;
        l_line_rec.tax_exempt_reason_code := l_implicit_rec.TAX_EXEMPT_REASON_CODE;
        l_line_rec.tax_point_code      := l_implicit_rec.TAX_POINT_CODE;
        l_line_rec.tax_rate            := l_implicit_rec.TAX_RATE;
        l_line_rec.tax_value           := l_implicit_rec.TAX_VALUE;
        l_line_rec.top_model_line_id   := l_implicit_rec.TOP_MODEL_LINE_ID;
        l_line_rec.unit_list_price     := l_implicit_rec.UNIT_LIST_PRICE;
        l_line_rec.unit_selling_price  := l_implicit_rec.UNIT_SELLING_PRICE;
        l_line_rec.visible_demand_flag := l_implicit_rec.VISIBLE_DEMAND_FLAG;
        l_line_rec.veh_cus_item_cum_key_id := l_implicit_rec.VEH_CUS_ITEM_CUM_KEY_ID;
        l_line_rec.shipping_instructions := l_implicit_rec.shipping_instructions;
        l_line_rec.packing_instructions := l_implicit_rec.packing_instructions;
	   l_line_rec.service_txn_reason_code := l_implicit_rec.service_txn_reason_code;
        l_line_rec.service_txn_comments := l_implicit_rec.service_txn_comments;
	   l_line_rec.service_duration := l_implicit_rec.service_duration;
	   l_line_rec.service_period := l_implicit_rec.service_period;
	   l_line_rec.service_start_date := l_implicit_rec.service_start_date;
	   l_line_rec.service_end_date := l_implicit_rec.service_end_date;
	   l_line_rec.service_coterminate_flag := l_implicit_rec.service_coterminate_flag;
	   l_line_rec.unit_list_percent := l_implicit_rec.unit_list_percent;
	   l_line_rec.unit_selling_percent := l_implicit_rec.unit_selling_percent;
	   l_line_rec.unit_percent_base_price := l_implicit_rec.unit_percent_base_price;
	   l_line_rec.service_number := l_implicit_rec.service_number;
	   l_line_rec.service_reference_type_code := l_implicit_rec.service_reference_type_code;
	   l_line_rec.service_reference_line_id:= l_implicit_rec.service_reference_line_id;
	   l_line_rec.service_reference_system_id:= l_implicit_rec.service_reference_system_id;

	   l_line_rec.tp_context := l_implicit_rec.tp_context;
	   l_line_rec.tp_attribute1 := l_implicit_rec.tp_attribute1;
	   l_line_rec.tp_attribute2 := l_implicit_rec.tp_attribute2;
	   l_line_rec.tp_attribute3 := l_implicit_rec.tp_attribute3;
	   l_line_rec.tp_attribute4 := l_implicit_rec.tp_attribute4;
	   l_line_rec.tp_attribute5 := l_implicit_rec.tp_attribute5;
	   l_line_rec.tp_attribute6 := l_implicit_rec.tp_attribute6;
	   l_line_rec.tp_attribute7 := l_implicit_rec.tp_attribute7;
	   l_line_rec.tp_attribute8 := l_implicit_rec.tp_attribute8;
	   l_line_rec.tp_attribute9 := l_implicit_rec.tp_attribute9;
	   l_line_rec.tp_attribute10:= l_implicit_rec.tp_attribute10;
	   l_line_rec.tp_attribute11:= l_implicit_rec.tp_attribute11;
	   l_line_rec.tp_attribute12:= l_implicit_rec.tp_attribute12;
	   l_line_rec.tp_attribute13:= l_implicit_rec.tp_attribute13;
	   l_line_rec.tp_attribute14:= l_implicit_rec.tp_attribute14;
	   l_line_rec.tp_attribute15:= l_implicit_rec.tp_attribute15;
	   l_line_rec.flow_status_code := l_implicit_rec.flow_status_code;
	   l_line_rec.marketing_source_code_id := l_implicit_rec.marketing_source_code_id;
	   l_line_rec.calculate_price_flag := l_implicit_rec.calculate_price_flag;
           l_line_rec.commitment_id        := l_implicit_rec.commitment_id;
        l_line_rec.order_source_id        := l_implicit_rec.order_source_id;
        l_line_tbl(l_line_tbl.COUNT + 1) := l_line_rec;

    END LOOP;


    RETURN l_line_tbl(1);

EXCEPTION

    WHEN NO_DATA_FOUND THEN

	   RAISE NO_DATA_FOUND;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    WHEN OTHERS THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Query_Row;

PROCEDURE Insert_Row
(   p_line_rec                      IN  OE_Order_PUB.Line_Rec_Type,
    p_orig_line_id                  IN  Number,
    p_upgraded_flag                 IN  Varchar2,
    p_apply_price_adj               IN  Varchar2 default 'Y'
)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   /* bring old_line_id from log table using the L_Line_id as the new_line_id */

   G_OLD_LINE_ID := 0;
   begin
     select max(old_line_id) into G_OLD_LINE_ID from oe_upgrade_log_v
     where new_line_id = p_orig_line_id;
   exception
     when others then
     G_OLD_LINE_ID := 0;
   end;

    INSERT  INTO OE_ORDER_LINES_ALL
    (       ORG_ID
    ,       ACCOUNTING_RULE_ID
    ,       ACTUAL_ARRIVAL_DATE
    ,       ACTUAL_SHIPMENT_DATE
    ,       AGREEMENT_ID
    ,       ARRIVAL_SET_ID
    ,       ATO_LINE_ID
    ,       ATTRIBUTE1
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       AUTO_SELECTED_QUANTITY
    ,       AUTHORIZED_TO_SHIP_FLAG
    ,       BOOKED_FLAG
    ,       CANCELLED_FLAG
    ,       CANCELLED_QUANTITY
    ,       COMPONENT_CODE
    ,       COMPONENT_NUMBER
    ,       COMPONENT_SEQUENCE_ID
    ,       CONFIG_HEADER_ID
    ,       CONFIG_REV_NBR
    ,       CONFIG_DISPLAY_SEQUENCE
    ,       CONFIGURATION_ID
    ,       CONTEXT
    ,       CREATED_BY
    ,       CREATION_DATE
    ,       CREDIT_INVOICE_LINE_ID
    ,       CUSTOMER_LINE_NUMBER
    ,       CUSTOMER_SHIPMENT_NUMBER
    ,       CUSTOMER_ITEM_NET_PRICE
    ,       CUSTOMER_PAYMENT_TERM_ID
    ,       CUSTOMER_DOCK_CODE
    ,       CUSTOMER_JOB
    ,       CUSTOMER_PRODUCTION_LINE
    ,       CUST_PRODUCTION_SEQ_NUM
    ,       CUSTOMER_TRX_LINE_ID
    ,       CUST_MODEL_SERIAL_NUMBER
    ,       CUST_PO_NUMBER
    ,       DELIVERY_LEAD_TIME
    ,       DELIVER_TO_CONTACT_ID
    ,       DELIVER_TO_ORG_ID
    ,       DEMAND_BUCKET_TYPE_CODE
    ,       DEMAND_CLASS_CODE
    ,       DEP_PLAN_REQUIRED_FLAG
    --,       DROP_SHIP_FLAG
    ,       EARLIEST_ACCEPTABLE_DATE
    ,       END_ITEM_UNIT_NUMBER
    ,       EXPLOSION_DATE
    ,       FIRST_ACK_CODE
    ,       FIRST_ACK_DATE
    ,       FOB_POINT_CODE
    ,       FREIGHT_CARRIER_CODE
    ,       FREIGHT_TERMS_CODE
    ,       FULFILLED_QUANTITY
    ,       FULFILLED_FLAG
    ,       FULFILLMENT_METHOD_CODE
    ,       FULFILLMENT_DATE
    ,       GLOBAL_ATTRIBUTE1
    ,       GLOBAL_ATTRIBUTE10
    ,       GLOBAL_ATTRIBUTE11
    ,       GLOBAL_ATTRIBUTE12
    ,       GLOBAL_ATTRIBUTE13
    ,       GLOBAL_ATTRIBUTE14
    ,       GLOBAL_ATTRIBUTE15
    ,       GLOBAL_ATTRIBUTE16
    ,       GLOBAL_ATTRIBUTE17
    ,       GLOBAL_ATTRIBUTE18
    ,       GLOBAL_ATTRIBUTE19
    ,       GLOBAL_ATTRIBUTE2
    ,       GLOBAL_ATTRIBUTE20
    ,       GLOBAL_ATTRIBUTE3
    ,       GLOBAL_ATTRIBUTE4
    ,       GLOBAL_ATTRIBUTE5
    ,       GLOBAL_ATTRIBUTE6
    ,       GLOBAL_ATTRIBUTE7
    ,       GLOBAL_ATTRIBUTE8
    ,       GLOBAL_ATTRIBUTE9
    ,       GLOBAL_ATTRIBUTE_CATEGORY
    ,       HEADER_ID
    ,       INDUSTRY_ATTRIBUTE1
    ,       INDUSTRY_ATTRIBUTE10
    ,       INDUSTRY_ATTRIBUTE11
    ,       INDUSTRY_ATTRIBUTE12
    ,       INDUSTRY_ATTRIBUTE13
    ,       INDUSTRY_ATTRIBUTE14
    ,       INDUSTRY_ATTRIBUTE15
    ,       INDUSTRY_ATTRIBUTE16
    ,       INDUSTRY_ATTRIBUTE17
    ,       INDUSTRY_ATTRIBUTE18
    ,       INDUSTRY_ATTRIBUTE19
    ,       INDUSTRY_ATTRIBUTE20
    ,       INDUSTRY_ATTRIBUTE21
    ,       INDUSTRY_ATTRIBUTE22
    ,       INDUSTRY_ATTRIBUTE23
    ,       INDUSTRY_ATTRIBUTE24
    ,       INDUSTRY_ATTRIBUTE25
    ,       INDUSTRY_ATTRIBUTE26
    ,       INDUSTRY_ATTRIBUTE27
    ,       INDUSTRY_ATTRIBUTE28
    ,       INDUSTRY_ATTRIBUTE29
    ,       INDUSTRY_ATTRIBUTE30
    ,       INDUSTRY_ATTRIBUTE2
    ,       INDUSTRY_ATTRIBUTE3
    ,       INDUSTRY_ATTRIBUTE4
    ,       INDUSTRY_ATTRIBUTE5
    ,       INDUSTRY_ATTRIBUTE6
    ,       INDUSTRY_ATTRIBUTE7
    ,       INDUSTRY_ATTRIBUTE8
    ,       INDUSTRY_ATTRIBUTE9
    ,       INDUSTRY_CONTEXT
    ,       INTMED_SHIP_TO_CONTACT_ID
    ,       INTMED_SHIP_TO_ORG_ID
    ,       INVENTORY_ITEM_ID
    ,       INVOICE_INTERFACE_STATUS_CODE
    ,       INVOICE_TO_CONTACT_ID
    ,       INVOICE_TO_ORG_ID
    ,       INVOICED_QUANTITY
    ,       INVOICING_RULE_ID
    ,       ORDERED_ITEM_ID
    ,       ITEM_IDENTIFIER_TYPE
    ,       ORDERED_ITEM
    ,       ITEM_REVISION
    ,       ITEM_TYPE_CODE
    ,       LAST_ACK_CODE
    ,       LAST_ACK_DATE
    ,       LAST_UPDATED_BY
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATE_LOGIN
    ,       LATEST_ACCEPTABLE_DATE
    ,       LINE_CATEGORY_CODE
    ,       LINE_ID
    ,       LINE_NUMBER
    ,       LINE_TYPE_ID
    ,       LINK_TO_LINE_ID
    ,       MODEL_GROUP_NUMBER
   -- ,       MFG_COMPONENT_SEQUENCE_ID
    ,       OPEN_FLAG
    ,       OPTION_FLAG
    ,       OPTION_NUMBER
    ,       ORDERED_QUANTITY
    ,       ORDER_QUANTITY_UOM
    --,       ORG_ID
    ,       ORDER_SOURCE_ID
    ,       ORIG_SYS_DOCUMENT_REF
    ,       ORIG_SYS_LINE_REF
    ,       ORIG_SYS_SHIPMENT_REF
    ,       CHANGE_SEQUENCE
    ,       OVER_SHIP_REASON_CODE
    ,       OVER_SHIP_RESOLVED_FLAG
    ,       PAYMENT_TERM_ID
    ,       PLANNING_PRIORITY
    ,       PRICE_LIST_ID
    ,       PRICING_ATTRIBUTE1
    ,       PRICING_ATTRIBUTE10
    ,       PRICING_ATTRIBUTE2
    ,       PRICING_ATTRIBUTE3
    ,       PRICING_ATTRIBUTE4
    ,       PRICING_ATTRIBUTE5
    ,       PRICING_ATTRIBUTE6
    ,       PRICING_ATTRIBUTE7
    ,       PRICING_ATTRIBUTE8
    ,       PRICING_ATTRIBUTE9
    ,       PRICING_CONTEXT
    ,       PRICING_DATE
    ,       PRICING_QUANTITY
    ,       PRICING_QUANTITY_UOM
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       PROJECT_ID
    ,       PROMISE_DATE
    ,       RE_SOURCE_FLAG
    ,       REFERENCE_CUSTOMER_TRX_LINE_ID
    ,       REFERENCE_HEADER_ID
    ,       REFERENCE_LINE_ID
    ,       REFERENCE_TYPE
    ,       REQUEST_DATE
    ,       REQUEST_ID
    ,       RETURN_ATTRIBUTE1
    ,       RETURN_ATTRIBUTE10
    ,       RETURN_ATTRIBUTE11
    ,       RETURN_ATTRIBUTE12
    ,       RETURN_ATTRIBUTE13
    ,       RETURN_ATTRIBUTE14
    ,       RETURN_ATTRIBUTE15
    ,       RETURN_ATTRIBUTE2
    ,       RETURN_ATTRIBUTE3
    ,       RETURN_ATTRIBUTE4
    ,       RETURN_ATTRIBUTE5
    ,       RETURN_ATTRIBUTE6
    ,       RETURN_ATTRIBUTE7
    ,       RETURN_ATTRIBUTE8
    ,       RETURN_ATTRIBUTE9
    ,       RETURN_CONTEXT
    ,       RETURN_REASON_CODE
    ,       RLA_SCHEDULE_TYPE_CODE
    ,       SALESREP_ID
    ,       SCHEDULE_ARRIVAL_DATE
    ,       SCHEDULE_SHIP_DATE
    ,       SCHEDULE_STATUS_CODE
    ,       SHIPMENT_NUMBER
    ,       SHIPMENT_PRIORITY_CODE
    ,       SHIPPED_QUANTITY
    ,       SHIPPING_METHOD_CODE
    ,       SHIPPING_QUANTITY
    ,       SHIPPING_QUANTITY_UOM
    ,       SHIP_FROM_ORG_ID
    ,       SHIP_SET_ID
    ,       SHIP_TOLERANCE_ABOVE
    ,       SHIP_TOLERANCE_BELOW
    ,       SHIPPABLE_FLAG
    ,       SHIPPING_INTERFACED_FLAG
    ,       SHIP_TO_CONTACT_ID
    ,       SHIP_TO_ORG_ID
    ,       SHIP_MODEL_COMPLETE_FLAG
    ,       SOLD_TO_ORG_ID
    ,       SOLD_FROM_ORG_ID
    ,       SORT_ORDER
    ,       SOURCE_DOCUMENT_ID
    ,       SOURCE_DOCUMENT_LINE_ID
    ,       SOURCE_DOCUMENT_TYPE_ID
    ,       SOURCE_TYPE_CODE
    ,       SPLIT_FROM_LINE_ID
    ,       LINE_SET_ID
    ,       SPLIT_BY
    ,       model_remnant_flag
    ,       TASK_ID
    ,       TAX_CODE
    ,       TAX_DATE
    ,       TAX_EXEMPT_FLAG
    ,       TAX_EXEMPT_NUMBER
    ,       TAX_EXEMPT_REASON_CODE
    ,       TAX_POINT_CODE
    ,       TAX_RATE
    ,       TAX_VALUE
    ,       TOP_MODEL_LINE_ID
    ,       UNIT_LIST_PRICE
    ,       UNIT_SELLING_PRICE
    ,       VISIBLE_DEMAND_FLAG
    ,       VEH_CUS_ITEM_CUM_KEY_ID
    ,       SHIPPING_INSTRUCTIONS
    ,       PACKING_INSTRUCTIONS
    ,       SERVICE_TXN_REASON_CODE
    ,       SERVICE_TXN_COMMENTS
    ,       SERVICE_DURATION
    ,       SERVICE_PERIOD
    ,       SERVICE_START_DATE
    ,       SERVICE_END_DATE
    ,       SERVICE_COTERMINATE_FLAG
    ,       UNIT_LIST_PERCENT
    ,       UNIT_SELLING_PERCENT
    ,       UNIT_PERCENT_BASE_PRICE
    ,       SERVICE_NUMBER
    ,       SERVICE_REFERENCE_TYPE_CODE
    ,       SERVICE_REFERENCE_LINE_ID
    ,       SERVICE_REFERENCE_SYSTEM_ID
    ,       TP_CONTEXT
    ,       TP_ATTRIBUTE1
    ,       TP_ATTRIBUTE2
    ,       TP_ATTRIBUTE3
    ,       TP_ATTRIBUTE4
    ,       TP_ATTRIBUTE5
    ,       TP_ATTRIBUTE6
    ,       TP_ATTRIBUTE7
    ,       TP_ATTRIBUTE8
    ,       TP_ATTRIBUTE9
    ,       TP_ATTRIBUTE10
    ,       TP_ATTRIBUTE11
    ,       TP_ATTRIBUTE12
    ,       TP_ATTRIBUTE13
    ,       TP_ATTRIBUTE14
    ,       TP_ATTRIBUTE15
    ,       FLOW_STATUS_CODE
    ,       MARKETING_SOURCE_CODE_ID
    ,       CALCULATE_PRICE_FLAG
    ,       COMMITMENT_ID
    ,       UPGRADED_FLAG
    )
    VALUES
    (       p_line_rec.org_id
    ,       p_line_rec.accounting_rule_id
    ,       p_line_rec.actual_arrival_date
    ,       p_line_rec.actual_shipment_date
    ,       p_line_rec.agreement_id
    ,       p_line_rec.arrival_set_id
    ,       p_line_rec.ato_line_id
    ,       p_line_rec.attribute1
    ,       p_line_rec.attribute10
    ,       p_line_rec.attribute11
    ,       p_line_rec.attribute12
    ,       p_line_rec.attribute13
    ,       p_line_rec.attribute14
    ,       p_line_rec.attribute15
    ,       p_line_rec.attribute2
    ,       p_line_rec.attribute3
    ,       p_line_rec.attribute4
    ,       p_line_rec.attribute5
    ,       p_line_rec.attribute6
    ,       p_line_rec.attribute7
    ,       p_line_rec.attribute8
    ,       p_line_rec.attribute9
    ,       p_line_rec.auto_selected_quantity
    ,       p_line_rec.authorized_to_ship_flag
    ,       p_line_rec.booked_flag
    ,       p_line_rec.cancelled_flag
    ,       p_line_rec.cancelled_quantity
    ,       p_line_rec.component_code
    ,       p_line_rec.component_number
    ,       p_line_rec.component_sequence_id
    ,       p_line_rec.config_header_id
    ,       p_line_rec.config_rev_nbr
    ,       p_line_rec.config_display_sequence
    ,       p_line_rec.configuration_id
    ,       p_line_rec.context
    ,       p_line_rec.created_by
    ,       p_line_rec.creation_date
    ,       p_line_rec.credit_invoice_line_id
    ,       p_line_rec.customer_line_number
    ,       p_line_rec.customer_shipment_number
    ,       p_line_rec.customer_item_net_price
    ,       p_line_rec.customer_payment_term_id
    ,       p_line_rec.customer_dock_code
    ,       p_line_rec.customer_job
    ,       p_line_rec.customer_production_line
    ,       p_line_rec.cust_production_seq_num
    ,       p_line_rec.customer_trx_line_id
    ,       p_line_rec.cust_model_serial_number
    ,       p_line_rec.cust_po_number
    ,       p_line_rec.delivery_lead_time
    ,       p_line_rec.deliver_to_contact_id
    ,       p_line_rec.deliver_to_org_id
    ,       p_line_rec.demand_bucket_type_code
    ,       p_line_rec.demand_class_code
    ,       p_line_rec.dep_plan_required_flag
    --,       p_line_rec.drop_ship_flag
    ,       p_line_rec.earliest_acceptable_date
    ,       p_line_rec.end_item_unit_number
    ,       p_line_rec.explosion_date
    ,       p_line_rec.first_ack_code
    ,       p_line_rec.first_ack_date
    ,       p_line_rec.fob_point_code
    ,       p_line_rec.freight_carrier_code
    ,       p_line_rec.freight_terms_code
    ,       p_line_rec.fulfilled_quantity
    ,       p_line_rec.fulfilled_flag
    ,       p_line_rec.fulfillment_method_code
    ,       p_line_rec.fulfillment_date
    ,       p_line_rec.global_attribute1
    ,       p_line_rec.global_attribute10
    ,       p_line_rec.global_attribute11
    ,       p_line_rec.global_attribute12
    ,       p_line_rec.global_attribute13
    ,       p_line_rec.global_attribute14
    ,       p_line_rec.global_attribute15
    ,       p_line_rec.global_attribute16
    ,       p_line_rec.global_attribute17
    ,       p_line_rec.global_attribute18
    ,       p_line_rec.global_attribute19
    ,       p_line_rec.global_attribute2
    ,       p_line_rec.global_attribute20
    ,       p_line_rec.global_attribute3
    ,       p_line_rec.global_attribute4
    ,       p_line_rec.global_attribute5
    ,       p_line_rec.global_attribute6
    ,       p_line_rec.global_attribute7
    ,       p_line_rec.global_attribute8
    ,       p_line_rec.global_attribute9
    ,       p_line_rec.global_attribute_category
    ,       p_line_rec.header_id
    ,       p_line_rec.industry_attribute1
    ,       p_line_rec.industry_attribute10
    ,       p_line_rec.industry_attribute11
    ,       p_line_rec.industry_attribute12
    ,       p_line_rec.industry_attribute13
    ,       p_line_rec.industry_attribute14
    ,       p_line_rec.industry_attribute15
    ,       p_line_rec.industry_attribute16
    ,       p_line_rec.industry_attribute17
    ,       p_line_rec.industry_attribute18
    ,       p_line_rec.industry_attribute19
    ,       p_line_rec.industry_attribute20
    ,       p_line_rec.industry_attribute21
    ,       p_line_rec.industry_attribute22
    ,       p_line_rec.industry_attribute23
    ,       p_line_rec.industry_attribute24
    ,       p_line_rec.industry_attribute25
    ,       p_line_rec.industry_attribute26
    ,       p_line_rec.industry_attribute27
    ,       p_line_rec.industry_attribute28
    ,       p_line_rec.industry_attribute29
    ,       p_line_rec.industry_attribute30
    ,       p_line_rec.industry_attribute2
    ,       p_line_rec.industry_attribute3
    ,       p_line_rec.industry_attribute4
    ,       p_line_rec.industry_attribute5
    ,       p_line_rec.industry_attribute6
    ,       p_line_rec.industry_attribute7
    ,       p_line_rec.industry_attribute8
    ,       p_line_rec.industry_attribute9
    ,       p_line_rec.industry_context
    ,       p_line_rec.intermed_ship_to_contact_id
    ,       p_line_rec.intermed_ship_to_org_id
    ,       p_line_rec.inventory_item_id
    ,       p_line_rec.invoice_interface_status_code
    ,       p_line_rec.invoice_to_contact_id
    ,       p_line_rec.invoice_to_org_id
    ,       p_line_rec.invoiced_quantity
    ,       p_line_rec.invoicing_rule_id
    ,       p_line_rec.ordered_item_id
    ,       p_line_rec.item_identifier_type
    ,       p_line_rec.ordered_item
    ,       p_line_rec.item_revision
    ,       p_line_rec.item_type_code
    ,       p_line_rec.last_ack_code
    ,       p_line_rec.last_ack_date
    ,       p_line_rec.last_updated_by
    ,       p_line_rec.last_update_date
    ,       p_line_rec.last_update_login
    ,       p_line_rec.latest_acceptable_date
    ,       p_line_rec.line_category_code
    ,       p_line_rec.line_id
    ,       p_line_rec.line_number
    ,       p_line_rec.line_type_id
    ,       p_line_rec.link_to_line_id
    ,       p_line_rec.model_group_number
    --,       p_line_rec.mfg_component_sequence_id
    ,       p_line_rec.open_flag
    ,       p_line_rec.option_flag
    ,       p_line_rec.option_number
    ,       p_line_rec.ordered_quantity
    ,       p_line_rec.order_quantity_uom
    --,       l_org_id
    ,       p_line_rec.order_source_id
    ,       p_line_rec.orig_sys_document_ref
    ,       p_line_rec.orig_sys_line_ref
    ,       p_line_rec.orig_sys_shipment_ref
    ,       p_line_rec.change_sequence
    ,       p_line_rec.over_ship_reason_code
    ,       p_line_rec.over_ship_resolved_flag
    ,       p_line_rec.payment_term_id
    ,       p_line_rec.planning_priority
    ,       p_line_rec.price_list_id
    ,       p_line_rec.pricing_attribute1
    ,       p_line_rec.pricing_attribute10
    ,       p_line_rec.pricing_attribute2
    ,       p_line_rec.pricing_attribute3
    ,       p_line_rec.pricing_attribute4
    ,       p_line_rec.pricing_attribute5
    ,       p_line_rec.pricing_attribute6
    ,       p_line_rec.pricing_attribute7
    ,       p_line_rec.pricing_attribute8
    ,       p_line_rec.pricing_attribute9
    ,       p_line_rec.pricing_context
    ,       p_line_rec.pricing_date
    ,       p_line_rec.pricing_quantity
    ,       p_line_rec.pricing_quantity_uom
    ,       p_line_rec.program_application_id
    ,       p_line_rec.program_id
    ,       p_line_rec.program_update_date
    ,       p_line_rec.project_id
    ,       p_line_rec.promise_date
    ,       p_line_rec.re_source_flag
    ,       p_line_rec.reference_customer_trx_line_id
    ,       p_line_rec.reference_header_id
    ,       p_line_rec.reference_line_id
    ,       p_line_rec.reference_type
    ,       p_line_rec.request_date
    ,       p_line_rec.request_id
    ,       p_line_rec.return_attribute1
    ,       p_line_rec.return_attribute10
    ,       p_line_rec.return_attribute11
    ,       p_line_rec.return_attribute12
    ,       p_line_rec.return_attribute13
    ,       p_line_rec.return_attribute14
    ,       p_line_rec.return_attribute15
    ,       p_line_rec.return_attribute2
    ,       p_line_rec.return_attribute3
    ,       p_line_rec.return_attribute4
    ,       p_line_rec.return_attribute5
    ,       p_line_rec.return_attribute6
    ,       p_line_rec.return_attribute7
    ,       p_line_rec.return_attribute8
    ,       p_line_rec.return_attribute9
    ,       p_line_rec.return_context
    ,       p_line_rec.return_reason_code
    ,       p_line_rec.rla_schedule_type_code
    ,       p_line_rec.salesrep_id
    ,       p_line_rec.schedule_arrival_date
    ,       p_line_rec.schedule_ship_date
    ,       p_line_rec.schedule_status_code
    ,       p_line_rec.shipment_number
    ,       p_line_rec.shipment_priority_code
    ,       p_line_rec.shipped_quantity
    ,       p_line_rec.shipping_method_code
    ,       p_line_rec.shipping_quantity
    ,       p_line_rec.shipping_quantity_uom
    ,       p_line_rec.ship_from_org_id
    ,       p_line_rec.ship_set_id
    ,       p_line_rec.ship_tolerance_above
    ,       p_line_rec.ship_tolerance_below
    ,       p_line_rec.shippable_flag
    ,       p_line_rec.shipping_interfaced_flag
    ,       p_line_rec.ship_to_contact_id
    ,       p_line_rec.ship_to_org_id
    ,       p_line_rec.ship_model_complete_flag

    ,       p_line_rec.sold_to_org_id
    ,       p_line_rec.sold_from_org_id
    ,       p_line_rec.sort_order
    ,       p_line_rec.source_document_id
    ,       p_line_rec.source_document_line_id
    ,       p_line_rec.source_document_type_id
    ,       p_line_rec.source_type_code
    ,       p_line_rec.split_from_line_id
    ,       p_line_rec.line_set_id
    ,       p_line_rec.split_by
    ,       p_line_rec.model_remnant_flag
    ,       p_line_rec.task_id
    ,       p_line_rec.tax_code
    ,       p_line_rec.tax_date
    ,       p_line_rec.tax_exempt_flag
    ,       p_line_rec.tax_exempt_number
    ,       p_line_rec.tax_exempt_reason_code
    ,       p_line_rec.tax_point_code
    ,       p_line_rec.tax_rate
    ,       p_line_rec.tax_value
    ,       p_line_rec.top_model_line_id
    ,       p_line_rec.unit_list_price
    ,       p_line_rec.unit_selling_price
    ,       p_line_rec.visible_demand_flag
    ,       p_line_rec.veh_cus_item_cum_key_id
    ,       p_line_rec.shipping_instructions
    ,       p_line_rec.packing_instructions
    ,       p_line_rec.service_txn_reason_code
    ,       p_line_rec.service_txn_comments
    ,       p_line_rec.service_duration
    ,       p_line_rec.service_period
    ,       p_line_rec.service_start_date
    ,       p_line_rec.service_end_date
    ,       p_line_rec.service_coterminate_flag
    ,       p_line_rec.unit_list_percent
    ,       p_line_rec.unit_selling_percent
    ,       p_line_rec.unit_percent_base_price
    ,       p_line_rec.service_number
    ,       p_line_rec.service_reference_type_code
    ,       p_line_rec.service_reference_line_id
    ,       p_line_rec.service_reference_system_id
    ,       p_line_rec.tp_context
    ,       p_line_rec.tp_attribute1
    ,       p_line_rec.tp_attribute2
    ,       p_line_rec.tp_attribute3
    ,       p_line_rec.tp_attribute4
    ,       p_line_rec.tp_attribute5
    ,       p_line_rec.tp_attribute6
    ,       p_line_rec.tp_attribute7
    ,       p_line_rec.tp_attribute8
    ,       p_line_rec.tp_attribute9
    ,       p_line_rec.tp_attribute10
    ,       p_line_rec.tp_attribute11
    ,       p_line_rec.tp_attribute12
    ,       p_line_rec.tp_attribute13
    ,       p_line_rec.tp_attribute14
    ,       p_line_rec.tp_attribute15
    ,       p_line_rec.flow_status_code
    ,       p_line_rec.marketing_source_code_id
    ,       p_line_rec.calculate_price_flag
    ,       p_line_rec.commitment_id
    ,       p_upgraded_flag
    );

        insert into  oe_order_lines_history
        (
            line_id,
            org_id,
            header_id,
            line_type_id,
            line_number,
            ordered_item,
            request_date,
            promise_date,
            schedule_ship_date,
            order_quantity_uom,
            pricing_quantity,
            pricing_quantity_uom,
            cancelled_quantity,
            shipped_quantity,
            ordered_quantity,
            fulfilled_quantity,
            shipping_quantity,
            shipping_quantity_uom,
            delivery_lead_time,
            tax_exempt_flag,
            tax_exempt_number,
            tax_exempt_reason_code,
            ship_from_org_id,
            ship_to_org_id,
            invoice_to_org_id,
            deliver_to_org_id,
            ship_to_contact_id,
            deliver_to_contact_id,
            invoice_to_contact_id,
            sold_to_org_id,
            cust_po_number,
            ship_tolerance_above,
            ship_tolerance_below,
            demand_bucket_type_code,
            veh_cus_item_cum_key_id,
            rla_schedule_type_code,
            customer_dock_code,
            customer_job,
            customer_production_line,
            cust_model_serial_number,
            project_id,
            task_id,
            inventory_item_id,
            tax_date,
            tax_code,
            tax_rate,
            demand_class_code,
            price_list_id,
            pricing_date,
            shipment_number,
            agreement_id,
            shipment_priority_code,
            shipping_method_code,
            freight_carrier_code,
            freight_terms_code,
            fob_point_code,
            tax_point_code,
            payment_term_id,
            invoicing_rule_id,
            accounting_rule_id,
            source_document_type_id,
            orig_sys_document_ref,
            source_document_id,
            orig_sys_line_ref,
            source_document_line_id,
            reference_line_id,
            reference_type,
            reference_header_id,
            item_revision,
            unit_selling_price,
            unit_list_price,
            tax_value,
            context,
            attribute1,
            attribute2,
            attribute3,
            attribute4,
            attribute5,
            attribute6,
            attribute7,
            attribute8,
            attribute9,
            attribute10,
            attribute11,
            attribute12,
            attribute13,
            attribute14,
            attribute15,
            global_attribute_category,
            global_attribute1,
            global_attribute2,
            global_attribute3,
            global_attribute4,
            global_attribute5,
            global_attribute6,
            global_attribute7,
            global_attribute8,
            global_attribute9,
            global_attribute10,
            global_attribute11,
            global_attribute12,
            global_attribute13,
            global_attribute14,
            global_attribute15,
            global_attribute16,
            global_attribute17,
            global_attribute18,
            global_attribute19,
            global_attribute20,
            pricing_context,
            pricing_attribute1,
            pricing_attribute2,
            pricing_attribute3,
            pricing_attribute4,
            pricing_attribute5,
            pricing_attribute6,
            pricing_attribute7,
            pricing_attribute8,
            pricing_attribute9,
            pricing_attribute10,
            industry_context,
            industry_attribute1,
            industry_attribute2,
            industry_attribute3,
            industry_attribute4,
            industry_attribute5,
            industry_attribute6,
            industry_attribute7,
            industry_attribute8,
            industry_attribute9,
            industry_attribute10,
            industry_attribute11,
            industry_attribute12,
            industry_attribute13,
            industry_attribute14,
            industry_attribute15,
            industry_attribute16,
            industry_attribute17,
            industry_attribute18,
            industry_attribute19,
            industry_attribute20,
            industry_attribute21,
            industry_attribute22,
            industry_attribute23,
            industry_attribute24,
            industry_attribute25,
            industry_attribute26,
            industry_attribute27,
            industry_attribute28,
            industry_attribute29,
            industry_attribute30,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login,
            program_application_id,
            program_id,
            program_update_date,
            request_id,
            configuration_id,
            link_to_line_id,
            component_sequence_id,
            component_code,
            config_display_sequence,
            sort_order,
            item_type_code,
            option_number,
            option_flag,
            dep_plan_required_flag,
            visible_demand_flag,
            line_category_code,
            actual_shipment_date,
            customer_trx_line_id,
            return_context,
            return_attribute1,
            return_attribute2,
            return_attribute3,
            return_attribute4,
            return_attribute5,
            return_attribute6,
            return_attribute7,
            return_attribute8,
            return_attribute9,
            return_attribute10,
            return_attribute11,
            return_attribute12,
            return_attribute13,
            return_attribute14,
            return_attribute15,
            intmed_ship_to_org_id,
            intmed_ship_to_contact_id,
            actual_arrival_date,
            ato_line_id,
            auto_selected_quantity,
            component_number,
            earliest_acceptable_date,
            explosion_date,
            latest_acceptable_date,
            model_group_number,
            schedule_arrival_date,
            ship_model_complete_flag,
            schedule_status_code,
            return_reason_code,
            salesrep_id,
            split_from_line_id,
            cust_production_seq_num,
            authorized_to_ship_flag,
            invoice_interface_status_code,
            ship_set_id,
            arrival_set_id,
            hist_comments,
            hist_type_code,
            reason_code,
            hist_created_by,
            hist_creation_date,
            source_type_code,
            booked_flag,
            fulfilled_flag,
            sold_from_org_id,
		     top_model_line_id,
		     cancelled_flag,
		     open_flag,
		     over_ship_reason_code,
		     over_ship_resolved_flag,
		     item_identifier_type,
		     commitment_id,
		     shipping_interfaced_flag,
		     credit_invoice_line_id,
		     end_item_unit_number,
		     mfg_component_sequence_id,
		     config_header_id,
		     config_rev_nbr,
		     shipping_instructions,
		     packing_instructions,
		     invoiced_quantity,
		     reference_customer_trx_line_id,
		     split_by,
		     line_set_id,
		     tp_context,
		     tp_attribute1,
		     tp_attribute2,
		     tp_attribute3,
		     tp_attribute4,
		     tp_attribute5,
		     tp_attribute6,
		     tp_attribute7,
		     tp_attribute8,
		     tp_attribute9,
		     tp_attribute10,
		     tp_attribute11,
		     tp_attribute12,
		     tp_attribute13,
		     tp_attribute14,
		     tp_attribute15,
		     fulfillment_method_code,
		     service_reference_type_code,
		     service_reference_line_id,
		     service_reference_system_id,
		     ordered_item_id,
		     service_number,
		     service_duration,
		     service_start_date,
		     re_source_flag,
		     flow_status_code,
		     service_end_date,
		     service_coterminate_flag,
		     shippable_flag,
		     order_source_id,
		     orig_sys_shipment_ref,
		     change_sequence,
		     drop_ship_flag,
		     customer_line_number,
		     customer_shipment_number,
		     customer_item_net_price,
		     customer_payment_term_id,
		     first_ack_date,
		     first_ack_code,
		     last_ack_code,
		     last_ack_date,
		     planning_priority,
		     service_txn_comments,
		     service_period,
		     unit_selling_percent,
		     unit_list_percent,
		     unit_percent_base_price,
		     model_remnant_flag,
		     service_txn_reason_code,
		     calculate_price_flag,
		     revenue_amount
       )
       select
            p_line_rec.line_id,
            org_id,
            header_id,
            line_type_id,
            line_number,
            ordered_item,
            request_date,
            promise_date,
            schedule_ship_date,
            order_quantity_uom,
            pricing_quantity,
            pricing_quantity_uom,
            cancelled_quantity,
            shipped_quantity,
            ordered_quantity,
            fulfilled_quantity,
            shipping_quantity,
            shipping_quantity_uom,
            delivery_lead_time,
            tax_exempt_flag,
            tax_exempt_number,
            tax_exempt_reason_code,
            ship_from_org_id,
            ship_to_org_id,
            invoice_to_org_id,
            deliver_to_org_id,
            ship_to_contact_id,
            deliver_to_contact_id,
            invoice_to_contact_id,
            sold_to_org_id,
            cust_po_number,
            ship_tolerance_above,
            ship_tolerance_below,
            demand_bucket_type_code,
            veh_cus_item_cum_key_id,
            rla_schedule_type_code,
            customer_dock_code,
            customer_job,
            customer_production_line,
            cust_model_serial_number,
            project_id,
            task_id,
            inventory_item_id,
            tax_date,
            tax_code,
            tax_rate,
            demand_class_code,
            price_list_id,
            pricing_date,
            shipment_number,
            agreement_id,
            shipment_priority_code,
            shipping_method_code,
            freight_carrier_code,
            freight_terms_code,
            fob_point_code,
            tax_point_code,
            payment_term_id,
            invoicing_rule_id,
            accounting_rule_id,
            source_document_type_id,
            orig_sys_document_ref,
            source_document_id,
            orig_sys_line_ref,
            source_document_line_id,
            reference_line_id,
            reference_type,
            reference_header_id,
            item_revision,
            unit_selling_price,
            unit_list_price,
            tax_value,
            context,
            attribute1,
            attribute2,
            attribute3,
            attribute4,
            attribute5,
            attribute6,
            attribute7,
            attribute8,
            attribute9,
            attribute10,
            attribute11,
            attribute12,
            attribute13,
            attribute14,
            attribute15,
            global_attribute_category,
            global_attribute1,
            global_attribute2,
            global_attribute3,
            global_attribute4,
            global_attribute5,
            global_attribute6,
            global_attribute7,
            global_attribute8,
            global_attribute9,
            global_attribute10,
            global_attribute11,
            global_attribute12,
            global_attribute13,
            global_attribute14,
            global_attribute15,
            global_attribute16,
            global_attribute17,
            global_attribute18,
            global_attribute19,
            global_attribute20,
            pricing_context,
            pricing_attribute1,
            pricing_attribute2,
            pricing_attribute3,
            pricing_attribute4,
            pricing_attribute5,
            pricing_attribute6,
            pricing_attribute7,
            pricing_attribute8,
            pricing_attribute9,
            pricing_attribute10,
            industry_context,
            industry_attribute1,
            industry_attribute2,
            industry_attribute3,
            industry_attribute4,
            industry_attribute5,
            industry_attribute6,
            industry_attribute7,
            industry_attribute8,
            industry_attribute9,
            industry_attribute10,
            industry_attribute11,
            industry_attribute12,
            industry_attribute13,
            industry_attribute14,
            industry_attribute15,
            industry_attribute16,
            industry_attribute17,
            industry_attribute18,
            industry_attribute19,
            industry_attribute20,
            industry_attribute21,
            industry_attribute22,
            industry_attribute23,
            industry_attribute24,
            industry_attribute25,
            industry_attribute26,
            industry_attribute27,
            industry_attribute28,
            industry_attribute29,
            industry_attribute30,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login,
            program_application_id,
            program_id,
            program_update_date,
            request_id,
            configuration_id,
            link_to_line_id,
            component_sequence_id,
            component_code,
            config_display_sequence,
            sort_order,
            item_type_code,
            option_number,
            option_flag,
            dep_plan_required_flag,
            visible_demand_flag,
            line_category_code,
            actual_shipment_date,
            customer_trx_line_id,
            return_context,
            return_attribute1,
            return_attribute2,
            return_attribute3,
            return_attribute4,
            return_attribute5,
            return_attribute6,
            return_attribute7,
            return_attribute8,
            return_attribute9,
            return_attribute10,
            return_attribute11,
            return_attribute12,
            return_attribute13,
            return_attribute14,
            return_attribute15,
            intmed_ship_to_org_id,
            intmed_ship_to_contact_id,
            actual_arrival_date,
            ato_line_id,
            auto_selected_quantity,
            component_number,
            earliest_acceptable_date,
            explosion_date,
            latest_acceptable_date,
            model_group_number,
            schedule_arrival_date,
            ship_model_complete_flag,
            schedule_status_code,
            return_reason_code,
            salesrep_id,
            split_from_line_id,
            cust_production_seq_num,
            authorized_to_ship_flag,
            invoice_interface_status_code,
            ship_set_id,
            arrival_set_id,
            hist_comments,
            hist_type_code,
            reason_code,
            hist_created_by,
            hist_creation_date,
            source_type_code,
            booked_flag,
            fulfilled_flag,
            sold_from_org_id,
		     top_model_line_id,
		     cancelled_flag,
		     open_flag,
		     over_ship_reason_code,
		     over_ship_resolved_flag,
		     item_identifier_type,
		     commitment_id,
		     shipping_interfaced_flag,
		     credit_invoice_line_id,
		     end_item_unit_number,
		     mfg_component_sequence_id,
		     config_header_id,
		     config_rev_nbr,
		     shipping_instructions,
		     packing_instructions,
		     invoiced_quantity,
		     reference_customer_trx_line_id,
		     split_by,
		     line_set_id,
		     tp_context,
		     tp_attribute1,
		     tp_attribute2,
		     tp_attribute3,
		     tp_attribute4,
		     tp_attribute5,
		     tp_attribute6,
		     tp_attribute7,
		     tp_attribute8,
		     tp_attribute9,
		     tp_attribute10,
		     tp_attribute11,
		     tp_attribute12,
		     tp_attribute13,
		     tp_attribute14,
		     tp_attribute15,
		     fulfillment_method_code,
		     service_reference_type_code,
		     service_reference_line_id,
		     service_reference_system_id,
		     ordered_item_id,
		     service_number,
		     service_duration,
		     service_start_date,
		     re_source_flag,
		     flow_status_code,
		     service_end_date,
		     service_coterminate_flag,
		     shippable_flag,
		     order_source_id,
		     orig_sys_shipment_ref,
		     change_sequence,
		     drop_ship_flag,
		     customer_line_number,
		     customer_shipment_number,
		     customer_item_net_price,
		     customer_payment_term_id,
		     first_ack_date,
		     first_ack_code,
		     last_ack_code,
		     last_ack_date,
		     planning_priority,
		     service_txn_comments,
		     service_period,
		     unit_selling_percent,
		     unit_list_percent,
		     unit_percent_base_price,
		     model_remnant_flag,
		     service_txn_reason_code,
		     calculate_price_flag,
		     revenue_amount
         from oe_order_lines_history
         where line_id = p_orig_line_id;

    /* Insert log record here */
    G_Log_Rec.Header_Id          := p_line_rec.header_id;
    G_Log_Rec.Old_Line_Id        := g_Old_line_id;
    G_Log_Rec.picking_Line_Id    := null;
    G_Log_Rec.Old_Line_Detail_id := null;
    G_Log_Rec.Delivery           := null;
    G_Log_Rec.New_Line_ID        := p_line_rec.line_id;
    g_log_rec.return_qty_available := null;
    G_Log_Rec.New_Line_Number    := null;
    G_Log_Rec.mtl_sales_order_id := null;  /* to check with Rupal if this is okay */
    g_log_rec.comments           := 'Created through sub-program for Upgrade';
    OE_UPG_SO.Upgrade_Insert_Upgrade_Log;

    g_line_id   := p_line_rec.line_id;
    g_header_id := p_line_rec.header_id;

    /* ========== Price Adjustments =========== */
    IF p_apply_price_adj = 'Y' THEN
    OE_Upg_SO.Upgrade_Price_Adjustments
    ( L_level_flag => 'L');
    END IF;

    /* ========== Sales Credits =========== */
    OE_Upg_SO.Upgrade_Sales_Credits
    ( L_level_flag => 'L');

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING INSERT_ROW' , 1 ) ;
    END IF;

EXCEPTION
    WHEN OTHERS THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Insert_Row;

Procedure Insert_Return_Included_Items(p_line_id NUMBER,module varchar2 default null)
IS
l_inventory_item_id  NUMBER;
l_line_set_id  NUMBER;
l_line_number  NUMBER;
l_shipment_line_id  NUMBER;
l_line_id  NUMBER;
l_line_id1  NUMBER;
l_received_quantity  NUMBER;
l_line_rec OE_Order_PUB.Line_Rec_Type;
l_line_rec1 OE_Order_PUB.Line_Rec_Type;
Cursor C1 is
  Select rma_interface_id,rma_id,rma_line_id,
  inventory_item_id,component_sequence_id,
  quantity, unit_code,received_quantity,delivered_quantity
  from mtl_so_rma_interface
  where rma_line_id = p_line_id
  and inventory_item_id <> l_inventory_item_id;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN

 l_line_rec := Query_Row(p_line_id);
 l_inventory_item_id := l_line_rec.inventory_item_id;

 For l_rec in C1 LOOP

    select oe_order_lines_s.nextval into l_line_id from dual;

    IF module is null then
    		g_Last_Line_Number  := g_Last_Line_Number +1;
		l_line_number := g_Last_Line_Number;
    else
		begin
			Select max(line_number) into l_line_number
			from oe_order_lines_all
			where header_id = l_line_rec.header_id;

               l_line_number := l_line_number + 1;
          exception
			when others then
				l_line_number := 1;
          end;
    end if;

  l_received_quantity := l_rec.received_quantity;

  IF l_received_quantity = 0 THEN
     l_received_quantity := NULL;
  END IF;


  l_line_rec1 := l_line_rec;
  l_line_rec1.line_number := l_line_number;
  l_line_rec1.inventory_item_id     := l_rec.inventory_item_id;
  l_line_rec1.ordered_item_id       := l_rec.inventory_item_id;
  l_line_rec1.ordered_item          := NULL;
  l_line_rec1.order_quantity_uom    := l_rec.unit_code;
  l_line_rec1.shipping_quantity_uom := l_rec.unit_code;
  l_line_rec1.pricing_quantity_uom  := l_rec.unit_code;
  l_line_rec1.unit_list_price       := 0;
  l_line_rec1.unit_selling_price    := 0;


  IF  l_received_quantity is NULL or
	(l_rec.quantity <= l_received_quantity) THEN
   l_line_rec1.line_id := l_line_id;
   l_line_rec1.shipment_number := 1;
   l_line_rec1.ordered_quantity  := l_rec.quantity;
   l_line_rec1.pricing_quantity  := l_rec.quantity;
   l_line_rec1.shipped_quantity   := l_received_quantity;
   l_line_rec1.fulfilled_quantity := l_received_quantity;
   l_line_rec1.invoiced_quantity  := NULL;

   Insert_Row(l_line_rec1,p_line_id,'Y','N');

  ELSE

   select oe_sets_s.nextval into l_line_set_id from dual;

   insert into oe_sets
          ( SET_ID, SET_NAME, SET_TYPE, HEADER_ID, SHIP_FROM_ORG_ID,
			SHIP_TO_ORG_ID,SCHEDULE_SHIP_DATE, SCHEDULE_ARRIVAL_DATE,
               FREIGHT_CARRIER_CODE, SHIPPING_METHOD_CODE,
               SHIPMENT_PRIORITY_CODE, SET_STATUS,
               CREATED_BY, CREATION_DATE, UPDATED_BY, UPDATE_DATE,
               UPDATE_LOGIN, INVENTORY_ITEM_ID,ORDERED_QUANTITY_UOM,
			LINE_TYPE_ID,SHIP_TOLERANCE_ABOVE, SHIP_TOLERANCE_BELOW)
    values
          (l_line_set_id, to_char(l_line_set_id),
               'LINE_SET',l_line_rec.header_id,null,null, null,null,null,
               null,null,null, 0,sysdate,0, sysdate,
               0,null,null,null,null,null
          );


   l_line_rec1.line_id := l_line_id;
   l_line_rec1.shipment_number := 1;
   l_line_rec1.ordered_quantity   := l_rec.received_quantity;
   l_line_rec1.pricing_quantity   := l_line_rec1.ordered_quantity;
   l_line_rec1.shipped_quantity   := l_rec.received_quantity;
   l_line_rec1.fulfilled_quantity := l_rec.received_quantity;
   l_line_rec1.invoiced_quantity  := NULL;

   l_line_rec1.line_set_id := l_line_set_id;

   Insert_Row(l_line_rec1,p_line_id,'Y','N');

   select oe_order_lines_s.nextval into l_line_id1 from dual;

   l_line_rec1.line_id := l_line_id1;
   l_line_rec1.shipment_number := 2;
   l_line_rec1.ordered_quantity   := l_rec.quantity-l_rec.received_quantity;
   l_line_rec1.pricing_quantity   := l_line_rec1.ordered_quantity;
   l_line_rec1.shipped_quantity   := NULL;
   l_line_rec1.fulfilled_quantity := NULL;
   l_line_rec1.invoiced_quantity  := NULL;

   Insert_Row(l_line_rec1,p_line_id,'Y','N');

   END IF;

   begin
           -- Update PO Tables
           -- rcv_shipment_lines, rcv_transactions,rcv_supply

           select shipment_line_id
		 into  l_shipment_line_id
           from rcv_shipment_lines
           where oe_order_line_id = p_line_id
           and item_id = l_rec.inventory_item_id;

           update rcv_shipment_lines
           set oe_order_line_id = l_line_id
           where shipment_line_id = l_shipment_line_id;

           update rcv_transactions
           set oe_order_line_id = l_line_id
           where shipment_line_id = l_shipment_line_id;

           update rcv_supply
           set oe_order_line_id = l_line_id
           where shipment_line_id = l_shipment_line_id;

  		 exception
                when others then
                      null;
    end;

 END LOOP;  -- End loop for C1

END Insert_Return_Included_Items;

Procedure Process_Upgraded_Returns is
l_commit_counter number := 0;
l_line_id number;
l_header_id number;
v_error_code number;
Cursor C1 is
     Select l1.line_id,l1.header_id
     from oe_order_lines_all l1, oe_order_lines_all l2
     where l1.reference_line_id = l2.line_id
     and l2.item_type_code in ('MODEL','CLASS','KIT')
     and l2.ato_line_id is null
     and l1.line_category_code = 'RETURN'
     and l1.reference_type is not null
	and l1.upgraded_flag in ('Y','P')
	and nvl(l1.open_flag,'-') = 'Y'
     and l1.line_id not in (
			Select u.new_line_id
               from oe_upgrade_log u
               where u.module = 'RI') ;
begin

 For l_rec in C1 LOOP
 l_commit_counter := l_commit_counter +1;
 l_header_id := l_rec.header_id;
 l_line_id := l_rec.line_id;

 BEGIN

    SAVEPOINT R_SAVE_POINT;

    Insert_Return_Included_Items(l_line_id,'Process_Returns');

    -- Insert the header_id,line_id entry into the upgrade Log
    insert into oe_upgrade_log(header_id,new_line_id,creation_date, module)
     values (l_header_id,l_line_id,sysdate, 'RI');

    exception
      when others then
             ROLLBACK TO R_SAVE_POINT;
             v_error_code := sqlcode;
             oe_upg_so.upgrade_insert_errors
             ( L_header_id => l_header_id,
               L_comments  => 'Exception in Process_Upgraded_Returns: '
                    ||'Error code -'
                    ||to_char(v_error_code)
                    ||' - Line id '||to_char(l_line_id)
             );
             COMMIT;
             l_commit_counter := 0;
             raise;

 END;

 IF l_commit_counter = 500 THEN
	Commit;
     l_commit_counter := 0;
 END IF;

 End LOOP;

commit;

 -- Code to split ATO Items
 Fix_Returns_Splits;

end Process_Upgraded_Returns;

--
-- Procedure to split ATO Items that are
-- partially received. Called in Process_Upgraded_Returns.
--
Procedure Fix_Returns_Splits is
l_commit_counter number := 0;
v_error_code number;
l_header_id number;
l_line_id number;
l_line_id1 number;
l_line_set_id number;
v_received_quantity number;
-- Cursor to select ATO Items
Cursor C1 is
      Select l1.line_id,l1.header_id,'RA' item_type,m.received_quantity
      from  oe_order_lines_all l1, oe_order_lines_all l2,mtl_so_rma_interface m
      where l1.reference_line_id = l2.line_id
	 and l1.line_category_code = 'RETURN'
	 and decode(m.received_quantity,0,NULL,m.received_quantity) <
	 l1.ordered_quantity
      and l1.line_id = m.rma_line_id
      and l2.item_type_code = 'OPTION'
      and l2.ato_line_id = l2.line_id
	 and l1.upgraded_flag in ('Y','P')
      and l1.line_id not in(
			Select new_line_id
			from oe_upgrade_log u
			where u.module = 'RA');
l_line_rec OE_Order_PUB.Line_Rec_Type;
l_line_rec2 OE_Order_PUB.Line_Rec_Type;
BEGIN

FOR l_rec in C1 LOOP
   l_commit_counter := l_commit_counter + 1;

   begin

   SAVEPOINT SAVE_POINT1;

   l_line_id := l_rec.line_id;
   l_header_id := l_rec.header_id;
   v_received_quantity := l_rec.received_quantity;

   l_line_rec := Query_Row(l_line_id);

   select oe_sets_s.nextval into l_line_set_id from dual;

   insert into oe_sets
          ( SET_ID, SET_NAME, SET_TYPE, HEADER_ID, SHIP_FROM_ORG_ID,
               SHIP_TO_ORG_ID,SCHEDULE_SHIP_DATE, SCHEDULE_ARRIVAL_DATE,
               FREIGHT_CARRIER_CODE, SHIPPING_METHOD_CODE,
               SHIPMENT_PRIORITY_CODE, SET_STATUS,
               CREATED_BY, CREATION_DATE, UPDATED_BY, UPDATE_DATE,
               UPDATE_LOGIN, INVENTORY_ITEM_ID,ORDERED_QUANTITY_UOM,
               LINE_TYPE_ID,SHIP_TOLERANCE_ABOVE, SHIP_TOLERANCE_BELOW)
    values
          (l_line_set_id, to_char(l_line_set_id),
               'LINE_SET',l_line_rec.header_id,null,null, null,null,null,
               null,null,null, 0,sysdate,0, sysdate,
               0,null,null,null,null,null
          );


  Update oe_order_lines_all
  set shipped_quantity = v_received_quantity,
  fulfilled_quantity = v_received_quantity,
  ordered_quantity = v_received_quantity ,
  line_set_id = l_line_set_id
  where line_id = l_line_id;


   select oe_order_lines_s.nextval
   into l_line_id1
   from dual;

   l_line_rec2 := l_line_rec;
   l_line_rec2.line_id := l_line_id1;
   l_line_rec2.shipment_number := 2;
   l_line_rec2.ordered_quantity   := l_line_rec.ordered_quantity - v_received_quantity;
   l_line_rec2.shipped_quantity   := null;
   l_line_rec2.fulfilled_quantity := null;
   l_line_rec2.invoiced_quantity  := null;
   l_line_rec2.line_set_id := l_line_set_id;

   Insert_Row(l_line_rec2,l_line_id,'Y','N');


   -- Insert the header_id,line_id entry into the upgrade Log
    insert into oe_upgrade_log(header_id,new_line_id,creation_date, module)
     values (l_header_id,l_line_id,sysdate, l_rec.item_type);

   exception
      when others then
             ROLLBACK TO SAVE_POINT1;
             v_error_code := sqlcode;
             oe_upg_so.upgrade_insert_errors
             ( L_header_id => l_header_id,
               L_comments  => 'Exception in Fix_Returns_Splits: '
                    ||'Error code -'
                    ||to_char(v_error_code)
                    ||' - Line id '||to_char(l_line_id)
             );
             COMMIT;
             l_commit_counter := 0;
             raise;
  end;


  if l_commit_counter = 500 then
     commit;
     l_commit_counter := 0;
  end if;

END LOOP;

Commit;

END Fix_Returns_Splits;

End OE_Upg_SO;

/
