--------------------------------------------------------
--  DDL for Package Body OE_UPG_SO_NEW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_UPG_SO_NEW" as
/* $Header: OEXNUSOB.pls 120.2.12000000.3 2007/11/20 13:18:11 amallik ship $ */


 G_EXC_INVALID_ORDER_CATEGORY    	Exception;
 G_EXC_INVALID_SOURCE_CODE       	Exception;
 G_EXC_INVALID_COPY_SOURCE       	Exception;
 G_EXC_INVALID_INTERNAL_SOURCE   	Exception;
 G_EXC_INVALID_RMA_REFERENCE   	Exception;
 G_EXC_INVALID_ORIGSYS_LINEREF  	Exception;
 G_EXC_INVALID_SRC_DOC_LINE  		Exception;

 G_ERROR_MESSAGE   				Varchar2(240);
 G_SOURCE_DOCUMENT_ID     		Number;
 G_SOURCE_DOCUMENT_TYPE_ID  		Number;
 G_ORDER_SOURCE_ID        		Number;
 G_ORDER_SOURCE_ID_LINE     		Number;
 G_ORIG_SYS_DOCUMENT_REF  		Varchar2(50);
 G_OPEN_FLAG                       VARCHAR2(1);

 G_SHIPPING_INSTRUCTIONS           varchar2(240);
 G_PACKING_INSTRUCTIONS            varchar2(240);
 G_FOB_POINT_CODE                  varchar2(30);
 G_OPEN_ATO_MODEL                  number;
 --g_list_header_id number := -1;    /* Renga */

 Procedure Mark_Order_As_Non_Updatable(p_header_id in number);
 Procedure Query_And_Set_Price_Attribs(p_line_id in number,
                                       p_header_id in number);

   Procedure Upgrade_Price_adjustments
    ( L_level_flag  IN  Varchar2)
    is
    cursor padj_l is
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
             round(pa.percent,38) percent,
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
                  L_level_flag = 'L');

    cursor padj_h is
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
             round(pa.percent,38) percent, --fix bug 2854690
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
         where (  pa.header_id = G_header_id     and
                  L_level_flag = 'H'             and
                  pa.line_id    is null );

    mpa padj_l%ROWTYPE;         /* alias defined for pa (price adjustments)*/
    v_price_adjustment_id     number;
    pa_rec                    QP_Upg_OE_PVT.PRICE_ADJ_REC_TYPE;


--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
  begin
        -- dbms_output.enable(999999999999);
	   if L_level_flag = 'L' then
        	open padj_l;
	   else
		open padj_h;
	   end if;

        G_ERROR_LOCATION := 1;
        loop    /* start loop for Price adjustments*/

			 if L_level_flag = 'L' then
                	fetch padj_l into mpa;
                	exit when padj_l%NOTFOUND;
			 else
                	fetch padj_h into mpa;
                	exit when padj_h%NOTFOUND;
			 end if;

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

			 /* Added by jefflee 6/21/00 */
/*
			 QP_Util.Log_Error(p_id1 => G_OLD_LINE_ID,
						    p_error_type => 'PRICE_ADJUSTMENT-Before call',
						    p_error_desc => mpa.price_adjustment_id ,
						    p_error_module => 'Upg_Price_Adjustments');
*/

			 QP_Upg_OE_PVT.Upg_Price_Adj_OE_to_QP(mpa.discount_id,mpa.discount_line_id,
                                                     mpa.percent, g_line_rec.list_price,
										   g_line_rec.pricing_context, mpa.line_id, pa_rec);
/*
			 QP_Util.Log_Error(p_id1 => pa_rec.list_header_id,
						    p_error_type => 'PRICE_ADJUSTMENT-After call',
						    p_error_desc => pa_rec.list_line_id ,
						    p_error_module => 'Upg_Price_Adjustments');
*/
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
                        attribute15,
                        list_header_id,   /* New columns added by jefflee 6/21/00 */
                        list_line_id,
                        list_line_type_code,
                        modified_from,
                        modified_to,
                        update_allowed,
                        updated_flag,
                        applied_flag,
                        operand,
                        arithmetic_operator,
                        adjusted_amount,
                        pricing_phase_id,
                        charge_type_code,
                        charge_subtype_code,
				    pricing_group_sequence,
                        list_line_no,
                        source_system_code,
                        benefit_qty,
                        benefit_uom_code,
                        print_on_invoice_flag,
                        expiration_date,
				    modifier_level_code,
				    price_break_type_code,
				    lock_control

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
                        mpa.attribute15,
                        pa_rec.list_header_id,  /* New columns added by jefflee 6/21/00 */
                        pa_rec.list_line_id,
                        pa_rec.list_line_type_code,
                        pa_rec.modified_from,
                        pa_rec.modified_to,
                        pa_rec.update_allowed,
                       --bug 2121206 Begin
                  decode(mpa.automatic_flag,'N','Y',pa_rec.updated_flag),
                       --bug 2121206 End
                        pa_rec.applied_flag,
                        pa_rec.operand,
                        pa_rec.arithmetic_operator,
                        pa_rec.adjusted_amount,
                        pa_rec.pricing_phase_id,
                        pa_rec.charge_type_code,
                        pa_rec.charge_subtype_code,
				    pa_rec.pricing_group_sequence,
                        pa_rec.list_line_no,
                        pa_rec.source_system_code,
                        pa_rec.benefit_qty,
                        pa_rec.benefit_uom_code,
                        pa_rec.print_on_invoice_flag,
                        pa_rec.expiration_date,
				    pa_rec.modifier_level_code,
				    pa_rec.price_break_type_code,
				    1
                );

                G_ERROR_LOCATION := 105;

        end loop;   /* end loop for price adjustments */
        G_ERROR_LOCATION := 2;
	   if L_level_flag = 'L' then
        	close padj_l;
	   else
		close padj_h;
	   end if;
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

        mscx sc%ROWTYPE;       /* alias defined for sc (sales credits)*/ -- GSCC change
        v_sales_credit_id     number;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
    begin
        -- dbms_output.enable(999999999);
        open sc;
        G_ERROR_LOCATION := 3;
        loop    /* start loop for sales credits*/

                fetch sc into mscx;
                exit when sc%NOTFOUND;

                begin
                     select
                              sales_credit_id
                     into
                              v_sales_credit_id
                     from
                              oe_sales_credits
                     where  sales_credit_id = mscx.sales_credit_id;

                     select
                          oe_sales_credits_s.nextval
                     into
                          v_sales_credit_id
                     from dual;
                exception
                     when no_data_found then
                          v_sales_credit_id := mscx.sales_credit_id;
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
                      wh_update_date,
				  lock_control
                )
                values
                (
                      v_sales_credit_id,
                      mscx.creation_date,
                      mscx.created_by,
                      mscx.last_update_date,
                      mscx.last_updated_by,
                      mscx.last_update_login,
                      mscx.header_id,
                      mscx.sales_credit_type_id,
                      mscx.salesrep_id,
                      mscx.percent,
                      decode(L_level_flag,'L',G_LINE_ID,null),
                      mscx.context,
                      mscx.attribute1,
                      mscx.attribute2,
                      mscx.attribute3,
                      mscx.attribute4,
                      mscx.attribute5,
                      mscx.attribute6,
                      mscx.attribute7,
                      mscx.attribute8,
                      mscx.attribute9,
                      mscx.attribute10,
                      mscx.attribute11,
                      mscx.attribute12,
                      mscx.attribute13,
                      mscx.attribute14,
                      mscx.attribute15,
                      mscx.dw_update_advice_flag,
                      mscx.wh_update_date,
				  1
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
          v_cancel_comment long;
          --
          l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
          --
   begin
          -- dbms_output.enable(999999999);
          G_ERROR_LOCATION := 5;
          for mcan in can loop
               G_ERROR_LOCATION := 51;
               G_canc_rec := NULL;
               G_ERROR_LOCATION := 52;
               g_canc_rec.can_header_id := mcan.header_id;
               g_canc_rec.can_line_id := mcan.line_id;
               g_canc_rec.can_created_by := mcan.created_by;
               g_canc_rec.can_creation_date := mcan.creation_date;
               g_canc_rec.can_last_updated_by := mcan.last_updated_by;
               g_canc_rec.can_last_update_date := mcan.last_update_date;
               g_canc_rec.can_last_update_login := mcan.last_update_login;
               g_canc_rec.can_program_application_id := mcan.program_application_id;
               g_canc_rec.can_program_id := mcan.program_id;
               g_canc_rec.can_program_update_date := mcan.program_update_date;
               g_canc_rec.can_request_id := mcan.request_id;
               g_canc_rec.can_cancel_code := mcan.cancel_code;
               g_canc_rec.can_cancelled_by := mcan.cancelled_by;
               g_canc_rec.can_cancel_date := mcan.cancel_date;
               g_canc_rec.can_cancelled_quantity := mcan.cancelled_quantity;
			v_cancel_comment := mcan.cancel_comment;
               g_canc_rec.can_cancel_comment := v_cancel_comment;

               g_canc_rec.can_cancel_comment:=substrb(g_canc_rec.can_cancel_comment,1,2000);

               g_canc_rec.can_context := mcan.context;
               g_canc_rec.can_attribute1 := mcan.attribute1;
               g_canc_rec.can_attribute2 := mcan.attribute2;
               g_canc_rec.can_attribute3 := mcan.attribute3;
               g_canc_rec.can_attribute4 := mcan.attribute4;
               g_canc_rec.can_attribute5 := mcan.attribute5;
               g_canc_rec.can_attribute6 := mcan.attribute6;
               g_canc_rec.can_attribute7 := mcan.attribute7;
               g_canc_rec.can_attribute8 := mcan.attribute8;
               g_canc_rec.can_attribute9 := mcan.attribute9;
               g_canc_rec.can_attribute10 := mcan.attribute10;
               g_canc_rec.can_attribute11 := mcan.attribute11;
               g_canc_rec.can_attribute12 := mcan.attribute12;
               g_canc_rec.can_attribute13 := mcan.attribute13;
               g_canc_rec.can_attribute14 := mcan.attribute14;
               g_canc_rec.can_attribute15 := mcan.attribute15;
               -- G_canc_rec := mcan;
               -- dbms_output.put_line('Ins cancellations');
               G_ORD_CANC_FLAG := 'Y';
               OE_UPG_SO_NEW.Upgrade_Insert_Lines_History;
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
/*
          decode(sld.schedule_status_code,
                 NULL, NULL ,
                 nvl(sld.schedule_date,sla.schedule_date)) schedule_date,
*/
          nvl(sld.quantity,(nvl(sla.ordered_quantity,0)-nvl(sla.cancelled_quantity,0))) ordered_quantity,
          decode(sla.ordered_quantity,sla.cancelled_quantity,'Y','N') line_cancel_flag,
          sla.cancelled_quantity,
/*
          decode(nvl(sld.picking_line_id,0),0,sla.shipped_quantity,
		      sld.shipped_quantity) shipped_quantity,
*/
           decode(sla.line_type_code,'RETURN',sla.shipped_quantity,decode(
                  nvl(decode(sla.item_type_code,'SERVICE','N',
                    decode(sla.ato_line_id,null,sld.shippable_flag,
                      decode(sla.item_type_code,'CONFIG',sld.shippable_flag,'N'))),'-'),  'Y',
             decode(sla.source_type_code,'EXTERNAL',
                decode(sld.receipt_status_code,'INTERFACED',sld.quantity,null),sld.shipped_quantity),
             decode((nvl(sla.ordered_quantity,0)- nvl(sla.cancelled_quantity,0)),nvl(sla.shipped_quantity,0),sla.shipped_quantity,
                          null))) shipped_quantity,
    /*Bug2639916  start */
         nvl(sld.invoiced_quantity,sla.invoiced_quantity) invoiced_quantity,
    sld.invoiced_quantity sld_invoiced_quantity,
    sla.invoiced_quantity sla_invoiced_quantity,
    sla.parent_line_id sla_parent_line_id,
  /* Bug2639916  end */
    sla.tax_exempt_number,
          sla.tax_exempt_reason_code,
          nvl(sld.warehouse_id,sla.warehouse_id) warehouse_id,
          sld.subinventory,
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
		sla.commitment_id,
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
          sla.pricing_attribute11,
          sla.pricing_attribute12,
          sla.pricing_attribute13,
          sla.pricing_attribute14,
          sla.pricing_attribute15,
          nvl(sla.creation_date,sysdate) creation_date,
          nvl(sld.created_by,sla.created_by) created_by,
          nvl(sld.last_update_date,sla.last_update_date) last_update_date,
          nvl(sld.last_updated_by,sla.last_updated_by) last_updated_by,
          nvl(sld.last_update_login,sla.last_update_login) last_update_login,
          sla.program_application_id,
          sla.program_id,
          sla.program_update_date,
          sla.request_id,
          decode(sla.item_type_code,
                 'MODEL', decode(sla.parent_line_id,
                                 NULL,sla.line_id,
                                 sla.parent_line_id),
                 'KIT', decode(sla.parent_line_id,
                               NULL,sla.line_id,
                               sla.parent_line_id),
		        sla.parent_line_id) parent_Line_id,
          sla.link_to_line_id,
          nvl(sld.component_sequence_id,sla.component_sequence_id) component_sequence_id,
          nvl(sld.component_code,sla.component_code) component_code,
/* Following lines are changed to fix the item type problem(from ontupg53)
          decode(sla.item_type_code,'STANDARD',
	          decode(sla.option_flag,'Y','OPTION',
		          sla.item_type_code),sla.item_type_code) item_type_code,
*/
          decode(sla.item_type_code,
                 'STANDARD', decode(sla.option_flag,
                                    'Y','OPTION',
                                    sla.item_type_code),
                 'MODEL', decode(sla.parent_line_id,
                                 NULL,'MODEL',
                                 'CLASS'),
                  sla.item_type_code) item_type_code,
          nvl(sla.source_type_code,'INTERNAL') source_type_code,
          sla.transaction_reason_code,
          nvl(sld.latest_acceptable_date,sla.latest_acceptable_date) latest_acceptable_date,
          sld.dep_plan_required_flag,
          decode(sla.item_type_code,'SERVICE',NULL,
            decode(nvl(sld.schedule_status_code,'0'),'0',NULL,'SCHEDULED')) schedule_status_code,
          sld.configuration_item_flag,
          sld.delivery,
          /* sld.load_seq_number, */
		' ' load_seq_number,
          sla.ship_set_number,
          sla.option_flag,
          sla.unit_code,
          sld.line_detail_id,
          sla.credit_invoice_line_id,
          sld.included_item_flag,
		/* Fix from ontupg39(Rupal)
          decode(sla.item_type_code,'MODEL',
            decode(sla.ato_line_id, NULL,
              decode(ato_flag, 'Y', sla.line_id, sla.ato_line_id), sla.ato_line_id),
		          sla.ato_line_id) ato_line_id,
		*/
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
         decode(sla.ordered_quantity,
         sla.cancelled_quantity,'N',nvl(sla.open_flag,'N')) open_flag,
          sla.ship_model_complete_flag,
          sla.standard_component_freeze_date,
          decode(sla.s1,1,'Y','N') booked_flag,
          decode(nvl(sld.picking_line_id,0),0,'N','Y') shipping_interfaced_flag,
          decode(sla.s4,6,'Y',NULL) fulfilled_flag,
          decode(sla.s5,9,'YES',NULL) invoice_interface_status_code,
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
		    sld.shippable_flag) shippable_flag,
          sla.component_sort_code sort_order,
          sla.terms_id
      from
          so_lines_all sla,
          so_line_attributes slattr,
          oe_upgrade_wsh_iface sld
          /* so_line_details sld */
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
             /* Bug #4681686, reshuffled the order by clause to make sure the at the Lines are pulled by
             line_id first */
          sla.line_id,
          sla.ship_set_number,
		sld.component_code,
          sld.line_detail_id;

      mol ol%ROWTYPE;		/* alias defined for detail-less lines cursor*/

      v_product_name           char(2) := 'JL';  -- GSCC fix
      v_service_flag           varchar2(1);
      v_system_id              number;
      v_line_id                number;
      v_cancelled_quantity     number;
      v_ship_set_number        number;
      v_shipped_line_id        number;
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
      --to pass this record structure to QP
      l_qp_upg_line_rec OE_UPG_SO_NEW.LINE_REC_TYPE;
      --
      l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
      --
   begin
        -- bug fix 1759900
        G_OPEN_ATO_MODEL := 0;

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

                g_line_rec.option_number                         := NULL;
                g_line_rec.line_id                               :=mol.line_id;
                g_line_rec.org_id                                :=mol.org_id;
                g_line_rec.header_id                             :=mol.header_id;
                g_line_rec.line_number                           :=mol.line_number;
                g_line_rec.date_requested_current                :=mol.date_requested_current;
                g_line_rec.promise_date	                         :=mol.promise_date;
                g_line_rec.schedule_date                         :=mol.schedule_date;
                g_line_rec.terms_id                              :=mol.terms_id;

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


			 if mol.invoice_interface_status_code = 'YES' then
                   g_line_rec.invoiced_quantity                  :=mol.ordered_quantity;
		/*Bug2639916-Added elsif condition */
                         elsif (mol.item_type_code = 'STANDARD' and mol.sla_parent_line_id is NULL and mol.shippable_flag = 'Y') then
      g_line_rec.invoiced_quantity := mol.sld_invoiced_quantity;
                         else
                   g_line_rec.invoiced_quantity                  :=mol.invoiced_quantity;
			 end if;

			 if g_line_rec.invoiced_quantity = 0 then
                     g_line_rec.invoiced_quantity := NULL;
                end if;

                g_line_rec.tax_exempt_number                     :=mol.tax_exempt_number;
                g_line_rec.tax_exempt_reason_code                :=mol.tax_exempt_reason_code;
                g_line_rec.warehouse_id                          :=mol.warehouse_id;
                g_line_rec.subinventory                          :=mol.subinventory;
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
			 /* from ontupg73 */
                if nvl(mol.item_type_code,'-') = 'SERVICE' then
                     g_line_rec.inventory_item_id    :=mol.service_inventory_item_id;
                else
                     g_line_rec.inventory_item_id    :=mol.inventory_item_id;
                end if;

                g_line_rec.tax_code                              :=mol.tax_code;
                g_line_rec.demand_class_code                     :=mol.demand_class_code;
                g_line_rec.price_list_id                         :=mol.price_list_id;
                g_line_rec.agreement_id                          :=mol.agreement_id;
                g_line_rec.shipment_priority_code                :=mol.shipment_priority_code;
                g_line_rec.ship_method_code                      :=mol.ship_method_code;
                g_line_rec.commitment_id                         :=mol.commitment_id;

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

                if substr(mol.global_attribute_category,1,5) in (v_product_name||'.BR', v_product_name||'.AR', v_product_name||'.CO') then
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
                g_line_rec.pricing_attribute11                   :=mol.pricing_attribute11;
                g_line_rec.pricing_attribute12                   :=mol.pricing_attribute12;
                g_line_rec.pricing_attribute13                   :=mol.pricing_attribute13;
                g_line_rec.pricing_attribute14                   :=mol.pricing_attribute14;
                g_line_rec.pricing_attribute15                   :=mol.pricing_attribute15;
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
                g_line_rec.latest_acceptable_date                :=mol.latest_acceptable_date;
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

                IF g_line_rec.line_type_code = 'RETURN' THEN
			   if nvl(mol.shipped_quantity,0)
					>= nvl(mol.ordered_quantity,0) then
                     g_line_rec.fulfilled_flag                     := 'Y';
                  else
                     g_line_rec.fulfilled_flag                     := NULL;
			   end if;

                ELSE

			   if nvl(mol.shipped_quantity,0) > 0 then
                     g_line_rec.fulfilled_flag                     := 'Y';
                  else
                     g_line_rec.fulfilled_flag                     := NULL;
			   end if;
                END IF;


                g_line_rec.invoice_interface_status_code         :=mol.invoice_interface_status_code;
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
--                g_line_rec.service_period                        :=NULL;   Bug4193589
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

			 -- modified by linda
			 -- set the flag to N for system initiated split lines
			 IF NVL(g_order_source_id, 0) = 10 THEN
                  g_line_rec.calculate_price_flag                 :='N';
                ELSE
                  g_line_rec.calculate_price_flag                 :='Y';
                END IF;

                G_ERROR_LOCATION := 7026;

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

                IF mol.sort_order is not null THEN
                   IF instr(mol.sort_order,'1') = 3 THEN
                       g_line_rec.sort_order   :=
                                  OE_TEMP_ADD_ZERO.oe_add_zero(mol.sort_order);
                   ELSE
                       g_line_rec.sort_order   := mol.sort_order;
                   END IF;
                ELSE
                   g_line_rec.sort_order   := mol.sort_order;
                END IF;

                G_ERROR_LOCATION := 703;

            --    if G_CANCELLED_FLAG = 'Y' or (mol.ordered_quantity = mol.cancelled_quantity and mol.line_cancel_flag = 'Y') then
                if G_CANCELLED_FLAG = 'Y' or mol.ordered_quantity = 0 then
                     g_line_rec.cancelled_flag                   :='Y';
                     g_line_rec.flow_status_code                 :='CANCELLED';
                else

				 /* Following line replaced from script ontupg74
                     g_line_rec.cancelled_flag                   :=NULL; */

				 g_line_rec.cancelled_flag                   := 'N';

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
		       g_line_rec.service_period               :=mol.unit_code;  --Bug 4193589
                         -- Fix made for Bug-1894965
                           if mol.customer_product_id is NOT NULL then

                              g_line_rec.service_reference_type_Code  := 'CUSTOMER_PRODUCT';
                              g_line_rec.service_reference_line_id    := mol.customer_product_id;
                           else
                              g_line_rec.service_reference_type_Code  := 'ORDER';
                              g_line_rec.service_reference_line_id    := mol.service_parent_line_id;

                           end if;

                         -- Fix made for Bug-1894965

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
		       g_line_rec.service_period               :=NULL; --Bug 4193589
                end if;

                if (nvl(v_ship_set_number,0) <> nvl(mol.ship_set_number,0)
                  and mol.ship_set_number is not NULL
                  and mol.schedule_date is not NULL
                  and mol.warehouse_id is not NULL
			   and mol.schedule_status_code is NOT NULL
                  and mol.ship_to_site_use_id is not NULL) then
/*
                  and mol.shipment_priority_code is not NULL
                  and mol.ship_method_code is not NULL)        then
*/

-- Make sure that no line is shipped whithing the ship set.
-- We must take out the lines from the ship set even if one line gets
-- shipped

                       v_ship_set_number := mol.ship_set_number;

			g_include_ship_set := 'N';

			IF mol.ship_set_number is not null THEN
			begin
                        -- 4234107 :shipped_quantity condition modified to have nvl check
			Select line_id into
				v_shipped_line_id from
			so_lines_all where
			header_id = g_line_rec.header_id and
			--shipped_quantity is not null and
                        NVL(shipped_quantity,0) > 0  and
			ship_set_number = v_ship_set_number
			and rownum = 1;
			g_include_ship_set := 'N';
			exception
			when no_data_found then
				g_include_ship_set := 'Y';
			end ;

		      end if;
		  IF g_include_ship_set = 'Y' THEN
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
			end if;
                         G_ERROR_LOCATION := 705;
               elsif mol.ship_set_number is null
                  OR mol.schedule_date is NULL
                  OR mol.warehouse_id is NULL
			   OR mol.schedule_status_code is NULL
                  OR mol.ship_to_site_use_id is NULL then
                         G_ERROR_LOCATION := 706;
                    g_set_id := NULL;
	   	    g_include_ship_set := 'N';
               end if;

               g_copied_line_flag := 'N';

               if v_line_id = mol.line_id then
                    select
                        oe_order_lines_s.nextval
                    into
                        g_line_id
                    from dual;
                    g_line_id_change_flag := 'N';
                    g_line_rec.split_from_line_id := g_orig_line_id; -- 3103312
               else
                    v_line_id              := mol.line_id;
                    g_line_id              := mol.line_id;
                    g_orig_line_id         := mol.line_id;
                    g_line_id_change_flag  := 'Y';
                    g_line_rec.split_from_line_id := NULL;

               end if;

               if G_COPIED_FLAG = 'Y' and mol.original_system_line_reference is not null then
                  G_COPIED_LINE_FLAG := 'Y';
               end if;

			if G_ORDER_SOURCE_ID_LINE IS NOT NULL AND
			   mol.original_system_line_reference IS NOT NULL then

                  if G_AUTO_FLAG = 'Y' then
                      g_line_rec.source_document_type_id := 5;
                  elsif G_COPIED_LINE_FLAG = 'Y' then
                      g_line_rec.source_document_type_id := 2;
                  elsif G_INTERNAL_ORDER = 'Y' then
			  	  null;
                  else
                      g_line_rec.order_source_id := G_ORDER_SOURCE_ID_LINE;
			  	  g_line_rec.orig_sys_document_ref := G_ORIG_SYS_DOCUMENT_REF;
			    	  g_line_rec.original_system_line_reference := mol.original_system_line_reference;
                      g_line_rec.source_document_type_id := NULL;
                      g_line_rec.source_document_id := NULL;
                      g_line_rec.source_document_line_id := NULL;
                  end if;
                else
                      g_line_rec.order_source_id := NULL;
			  	  g_line_rec.orig_sys_document_ref := NULL;
			    	  g_line_rec.original_system_line_reference := NULL;
                      g_line_rec.source_document_type_id := NULL;
                      g_line_rec.source_document_id := NULL;
                      g_line_rec.source_document_line_id := NULL;

			 end if;

               if nvl(mol.included_item_flag,'-') = 'Y' then
                    g_line_rec.link_to_line_id := g_orig_line_id;
                /* Following line commented to fix the data problem
                    g_line_rec.parent_line_id  := g_orig_line_id;
                */
                    g_line_rec.parent_line_id  := mol.parent_line_id;
                    g_line_rec.item_type_code  := 'INCLUDED';
               elsif nvl(mol.configuration_item_flag,'-') = 'Y' then
                    g_line_rec.link_to_line_id := g_orig_line_id;
                /* Following line commented to fix the data problem
                    g_line_rec.parent_line_id  := g_orig_line_id;
                */
                    g_line_rec.parent_line_id  := mol.parent_line_id;
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

			 -- Fix accounting and invoicing rule ids
               IF g_line_id_change_flag = 'Y' THEN
                 if nvl(mol.accounting_rule_id,0) = 0 or nvl(mol.invoicing_rule_id,0) = 0 then
                     BEGIN
                       SELECT decode(agr.override_arule_flag,
                                'N', agr.accounting_rule_id,
                                 decode(comt.override_arule_flag,
                                  'N', comt.accounting_rule_id,
                                   nvl(si.accounting_rule_id,
                                    nvl(comt.accounting_rule_id,
                                          nvl(agr.accounting_rule_id,
                                              nvl(g_accounting_rule_id,NULL)))))),
                              decode(agr.override_irule_flag,
                                'N', agr.invoicing_rule_id,
                                 decode(comt.override_irule_flag,
                                  'N', comt.invoicing_rule_id,
                                   nvl(si.invoicing_rule_id,
                                    nvl(comt.invoicing_rule_id,
                                          nvl(agr.invoicing_rule_id,
                                              nvl(g_invoicing_rule_id,NULL))))))
                       INTO g_line_rec.accounting_rule_id,
                            g_line_rec.invoicing_rule_id
                       FROM  so_lines_all l,
                             so_agreements_b agr,
                             ra_customer_trx_all ct,
                             so_agreements_b comt,
                             mtl_system_items si
                       WHERE l.line_id= mol.line_id
                       AND   l.agreement_id = agr.agreement_id (+)
                       AND   l.commitment_id = ct.customer_trx_id (+)
                       AND   ct.agreement_id = comt.agreement_id (+)
                       AND   nvl(l.warehouse_id, nvl(v_master_org_for_single_org, oe_sys_parameters.value('MASTER_ORGANIZATION_ID', l.org_id))) = si.organization_id
                       AND   l.inventory_item_id = si.inventory_item_id;

                    EXCEPTION
                          WHEN NO_DATA_FOUND THEN
                            /* oe_debug_pub.add('accounting, invoicing rule ids not found. Setting to Null ');*/
                             g_line_rec.accounting_rule_id := NULL;
                             g_line_rec.invoicing_rule_id  := NULL;
                     END;
                 else
                     g_line_rec.invoicing_rule_id                     :=mol.invoicing_rule_id;
                     g_line_rec.accounting_rule_id                    :=mol.accounting_rule_id;
                 end if;
               END IF;

               /* from ontupg73 */

               if g_line_rec.item_type_code = 'SERVICE' then
                    g_line_rec.parent_line_id    := null;
               end if;

/* Null out nocopy schedule date for service lines */


               if g_line_rec.item_type_code = 'SERVICE' then
                    g_line_rec.schedule_date  := null;
               end if;

/* Null out nocopy the service columns if service_duration is */

			/* less than zero */
			if nvl(g_line_rec.service_duration,0) < 0 then
			   g_line_rec.service_duration := null;
			   g_line_rec.service_period := null;
			   g_line_rec.service_start_date := null;
			   g_line_rec.service_end_date := null;
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
                   --v_bal_return_quantity := g_line_rec.ordered_quantity;

			    if g_line_rec.return_reference_type_code is not null then

                      /* Bug2192797: Modified the from clause of following */
                      /* query to go againt _all table. */

                      if g_line_rec.return_reference_type_code = 'INVOICE' then
                       begin
                            select customer_trx_id
                            into v_customer_trx_id
                            from RA_CUSTOMER_TRX_LINES_ALL
                            where customer_trx_line_id =
                              g_line_rec.return_reference_id;
                           -- and ( interface_line_attribute6 is null or
                           --       interface_line_attribute6 between
                           --       '000000000000000' and '999999999999999');
                       exception
                            when others then
                                 v_customer_trx_id     := NULL;
                       end;
                      end if;

                      /* Fix for bug 2001159 */
                      v_reference_line_id := nvl(mol.link_to_line_id,
                                             mol.return_reference_id);

                   end if;

			    if v_reference_line_id is not null then
                      begin
                         select l.header_id into v_reference_header_id
                         from oe_order_lines_all l
                         where line_id = v_reference_line_id;
                      exception
                         when no_data_found then
                              G_ERROR_MESSAGE := 'Referenced Order of the RMA'
                              ||' is not upgraded. line: '
                              ||to_char(mol.line_id);
                              raise G_EXC_INVALID_RMA_REFERENCE;
                      end;
                   end if;


			    if g_line_rec.return_reference_type_code is not null then
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
                             end if;

                       --      if r_option_flag = 'Y' and
                       --         r_ato_flag = 'Y' then
                       --          r_ato_option := TRUE;
                       --      end if;

                             if r_ato_flag = 'N'  and
                               r_original_item_type_code in
                                  ('MODEL','KIT','CLASS') then
                                 r_pto_m_c_k := TRUE;
                             end if;

                             -- Fetch config if line is open
 					    if r_ato_model then
                               if mol.open_flag = 'Y' THEN
                                  begin
 							Select inventory_item_id,unit_code
                                   into r_inventory_item_id_2,
                                        r_uom_code_2
							from mtl_so_rma_interface
  							where rma_line_id = mol.line_id;
                                  exception
                                       when others then
                                        r_no_config_item := TRUE;
                                  end;
                               else
							r_no_config_item := TRUE;
                               end if;
                             end if; /* ato model */

                   end if; /* reference_type_code is not null */


                   begin
                      IF r_pto_m_c_k THEN
                        select received_quantity into v_received_quantity
                        from mtl_so_rma_interface
                        where mol.line_id = rma_line_id
                        and mol.inventory_item_id = inventory_item_id;
                      ELSE
                        select received_quantity into v_received_quantity
                        from mtl_so_rma_interface
                        where mol.line_id = rma_line_id;
				  END IF;

                        if v_received_quantity = 0 THEN
                              v_received_quantity := NULL;
                        end if;
                   exception
                        when no_data_found then
                             v_received_quantity := null;
                        when others then
                             v_received_quantity := null;
                   end;

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

                         if  v_received_quantity is not NULL and
                           v_actual_ordered_quantity > v_received_quantity THEN

                               If  v_return_lctr = 1  then
                                   IF not (r_ato_model) THEN
                                    g_line_rec.shipped_quantity := v_received_quantity;
                                    g_line_rec.ordered_quantity :=  v_received_quantity;
                                         v_return_lctr := 2;
                                    ELSIF r_no_config_item THEN
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
                                    v_return_lctr := 10;
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
                               IF (not r_ato_model) or r_no_config_item then
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
							Select max(line_number) + 1
							into g_line_rec.line_number
							from so_lines_all
							where header_id = G_HEADER_ID;
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
                    end if;

				if G_COPIED_LINE_FLAG = 'Y' then
                        g_line_rec.source_document_id := G_SOURCE_DOCUMENT_ID;
				    g_line_rec.order_source_id := NULL;
				    g_line_rec.orig_sys_document_ref := NULL;
				    g_line_rec.original_system_line_reference := NULL;
                        begin
                             g_line_rec.source_document_line_id
                             := g_line_rec.original_system_line_reference;
                        exception
                             when others then
					    G_ERROR_MESSAGE := 'Invalid Original System Line Reference line : '||to_char(mol.line_id);
					    raise G_EXC_INVALID_ORIGSYS_LINEREF;
                        end;
                    else
                         g_line_rec.source_document_id := NULL;
                         g_line_rec.source_document_line_id:= NULL;
                    end if;

				if G_INTERNAL_ORDER = 'Y' AND
				   mol.original_system_line_reference IS NOT NULL THEN

                       g_line_rec.source_document_type_id := 10;
                       g_line_rec.order_source_id := 10;
				   g_line_rec.source_document_id := G_SOURCE_DOCUMENT_ID;

				   begin
					   select requisition_line_id
					   into   g_line_rec.source_document_line_id
					   from   po_requisition_lines_all
					   where  requisition_header_id = G_SOURCE_DOCUMENT_ID
					   and    line_num = mol.original_system_line_reference
					   and    nvl(org_id,-99) = nvl(mol.org_id,-99);

                       exception

                            when others then
					        G_ERROR_MESSAGE := 'Invalid Internal Line Source line : '||to_char(mol.line_id);
					        raise G_EXC_INVALID_SRC_DOC_LINE;
				   end;

				   g_line_rec.orig_sys_document_ref := G_ORIG_SYS_DOCUMENT_REF;
				   g_line_rec.original_system_line_reference := mol.original_system_line_reference;

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


                /* From ontupg39 */
                if (g_line_rec.ato_line_id IS NOT NULL and
                    g_line_rec.ato_line_id = g_line_rec.line_id and
			    nvl(mol.shippable_flag,'Y') = 'Y' and
			    g_line_rec.item_type_code IN ('MODEL','CLASS')) OR
                   (g_line_rec.ato_line_id IS NOT NULL and
                    g_line_rec.ato_line_id <> g_line_rec.line_id and
			    nvl(mol.shippable_flag,'Y') = 'Y' and
			    g_line_rec.item_type_code IN ('OPTION','CLASS')) THEN

			    g_line_rec.shippable_flag := 'N';
                else

                   g_line_rec.shippable_flag  :=mol.shippable_flag;
			 end if;

                --bug 1869550 fix. for ato_item
                IF g_line_rec.ato_line_id is NOT NULL AND
                   g_line_rec.item_type_code = 'STANDARD' THEN
                   g_line_rec.ato_line_id := g_line_rec.line_id;
                END IF;

				/* Added by Manish/Swami on 6/7/00 to replace ontupg10.sql and merge it
                        into this package */

                    if g_line_rec.actual_departure_date is null then
                      if g_line_rec.schedule_date is null then
                         if g_line_rec.promise_date is null then
					    if g_line_rec.date_requested_current is null then
                                  g_line_rec.tax_date := sysdate;
					    else
                                  g_line_rec.tax_date := g_line_rec.date_requested_current;
					    end if;
                         else
                             g_line_rec.tax_date := g_line_rec.promise_date;
                         end if;
                      else
                         g_line_rec.tax_date := g_line_rec.schedule_date;
                      end if;
                    else
                      g_line_rec.tax_date := g_line_rec.actual_departure_date;
                    end if;

		   /* Update of line_number/option_number  */

				/* Update from ontupg81 */
				if g_line_rec.line_type_code = 'RETURN' THEN

					 g_line_rec.ato_line_id := NULL;
					 g_line_rec.link_to_line_id := NULL;
					 g_line_rec.parent_line_id := NULL;
					 g_line_rec.item_type_code := 'STANDARD';

				end if;

				if g_line_rec.line_type_code = 'REGULAR' AND
				   ((g_line_rec.item_type_code = 'STANDARD') OR
				   (g_line_rec.item_type_code IN ('MODEL','KIT') AND
				    g_line_rec.parent_line_id = g_line_id)) THEN

				   g_line_rec.line_number := mol.line_number;

                    end if;
				if g_line_rec.line_type_code = 'DETAIL' AND
				   ((g_line_rec.item_type_code = 'STANDARD') OR
				   (g_line_rec.item_type_code IN ('MODEL','KIT') AND
				    g_line_rec.parent_line_id = g_line_id)) THEN

                                     r_shipment_number := mol.line_number;

				    SELECT line_number
				    INTO   g_line_rec.line_number
				    FROM   so_lines_all
				    WHERE  line_id = (select shipment_schedule_line_id
								  from   so_lines_all
								  where  line_id = mol.line_id);

                    end if;

                    if g_line_rec.item_type_code IN ('KIT','CLASS','OPTION') AND
				   g_line_rec.parent_line_id <> g_line_id  AND
				   g_line_rec.link_to_line_id IS NOT NULL THEN

                       g_line_rec.option_number := mol.line_number;
                    end if;

                -- Fix bug 1661010: if null, copy payment term from header to all lines
                -- except returns
                if g_line_rec.line_category_code <> 'RETURN'
                   and g_line_rec.terms_id is null then
                   g_line_rec.terms_id := G_TERMS_ID;
                end if;

                -- Fix bug 1661010: update null ship to on regular lines (except for
                -- returns and services)
                if g_line_rec.line_category_code <> 'RETURN'
                   and g_line_rec.item_type_code <> 'SERVICE'
                   and g_line_rec.ship_to_site_use_id is null then

                   if g_line_rec.item_type_code not in ('STANDARD','MODEL') then
                      -- check for ship_to on ATO model first
                      if g_line_rec.ato_line_id <> g_line_rec.line_id then
                         select ship_to_site_use_id
                         into g_line_rec.ship_to_site_use_id
                         from so_lines_all
                         where line_id = g_line_rec.ato_line_id;
                      end if;
                      -- check for ship_to on top model next
                      if g_line_rec.ship_to_site_use_id is null
                         and g_line_rec.parent_line_id <>  g_line_rec.line_id then
                         select ship_to_site_use_id
                         into g_line_rec.ship_to_site_use_id
                         from so_lines_all
                         where line_id = g_line_rec.parent_line_id;
                      end if;
                   end if;

                   -- if still null, copy it from header
                   if g_line_rec.ship_to_site_use_id is null then
                      g_line_rec.ship_to_site_use_id := G_SHIP_TO_SITE_USE_ID;
                   end if;

                end if;

                -- Fix for the bug 2696779

                IF g_line_rec.line_category_code = 'RETURN' THEN

                   IF g_line_rec.ship_to_site_use_id is null THEN
                      g_line_rec.ship_to_site_use_id := G_SHIP_TO_SITE_USE_ID;
                   END IF;

                END IF;

                -- Fix for bug 6640180
                IF g_line_rec.item_type_code = 'SERVICE' THEN
                   IF g_line_rec.ship_to_site_use_id IS NULL THEN
                      g_line_rec.ship_to_site_use_id := G_SHIP_TO_SITE_USE_ID;
                   END IF;
                END IF;
                -- End of fix for bug 6640180

                -- bug fix 1759900
                IF g_line_rec.ato_line_id is not null AND
                   g_line_rec.open_flag = 'Y' AND
                   g_line_rec.ato_line_id = g_line_rec.line_id AND
                   g_line_rec.item_type_code in ('MODEL', 'CLASS')
                THEN
                   G_OPEN_ATO_MODEL := 1;
                END IF;

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
                         subinventory,
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
                         reference_customer_trx_line_id,
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
                         customer_trx_line_id,
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
                         upgraded_flag,
				     lock_control
                    )
                    values
                    (
			 g_line_id,                              /* LINE_ID */
                         g_line_rec.org_id,                      /* ORG_ID */
                         g_line_rec.header_id,                   /* HEADER_ID */
                         g_line_rec.line_type_id,                /* LINE_TYPE_ID, */
                         g_line_rec.line_number,                 /* LINE_NUMBER */
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
                         g_line_rec.subinventory,                /* SUBINVENOTRY */
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
                         g_line_rec.tax_date,                             /* TAX_DATE */
                         g_line_rec.tax_code,                    /* TAX_CODE */
                         null,                                   /* TAX_RATE */
                         g_line_rec.demand_class_code,           /* DEMAND_CLASS_CODE */
                         g_line_rec.price_list_id,               /* Renga PRICE_LIST_ID */
                         null,                                   /* PRICING_DATE */
                         r_shipment_number,                      /* SHIPMENT_NUMBER */
                         g_line_rec.agreement_id,                /* AGREEMENT_ID */
                         g_line_rec.shipment_priority_code,      /* SHIPMENT_PRIORITY_CODE */
                         g_line_rec.ship_method_code,          /* SHIPPPING_METHOD_CODE */
                         g_line_rec.ship_method_code,            /* FREIGHT_CARRIER_CODE */
                         G_freight_terms_code,                   /* FREIGHT_TERMS_CODE */
                         G_FOB_POINT_CODE,                       /* FOB_POINT_CODE */
                         'INVOICE',                              /* TAX_POINT_CODE */
                         g_line_rec.terms_id,                    /* PAYMENT_TERM_ID */
                         g_line_rec.invoicing_rule_id,    /* INVOICING_RULE_ID */
                         g_line_rec.accounting_rule_id,   /* ACCOUNTING_RULE_ID */
                         g_line_rec.source_document_type_id,     /* SOURCE_DOCUMENT_TYPE_ID */
                         g_line_rec.orig_sys_document_ref,      /* ORIG_SYS_DOCUMENT_REF */
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
                         g_line_rec.parent_line_id,              /* TOP_MODEL_LINE_ID */
                         g_line_rec.link_to_line_id,             /* LINK_TO_LINE_ID */
                         g_line_rec.component_sequence_id,       /* COMPONENT_SEQUENCE_ID */
                         g_line_rec.component_code,              /* COMPONENT_CODE */
                         null,                                   /* CONFIG_DISPLAY_SEQUENCE */
                         g_line_rec.sort_order,                  /* SORT_ORDER, */
                         g_line_rec.item_type_code,              /* ITEM_TYPE_CODE */
                         g_line_rec.option_number,              /* OPTION_NUMBER */
                         g_line_rec.option_flag,                 /* OPTION_FLAG, */
                         g_line_rec.dep_plan_required_flag,      /* DEP_PLAN_REQUIRED_FLAG */
                         g_line_rec.visible_demand_flag,         /* VISIBLE_DEMAND_FLAG */
                         g_line_rec.line_category_code,          /* LINE_CATEGORY_CODE */
                         g_line_rec.actual_departure_date,       /* ACTUAL_SHIPMENT_DATE */
                         decode(g_line_rec.line_type_code,'RETURN',
                               decode(g_line_rec.return_reference_type_code,
                               'INVOICE',g_line_rec.return_reference_id,NULL), NULL), /* REFERENCE_CUSTOMER_TRX_LINE_ID */

                         /* Fixing bug 2001159 */
                         decode(g_line_rec.line_type_code,'RETURN',g_line_rec.return_reference_type_Code,NULL),           /* RETURN_CONTEXT */

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
                         g_line_rec.split_from_line_id,          /* split_from_line_id */
                         g_line_rec.planning_prod_seq_number,    /* cust_production_seq_num */
                         decode(G_AUTO_FLAG,'Y','Y',NULL),       /* authorized_to_ship_flag */
                         g_line_rec.invoice_interface_status_code,  /* invoice_interface_status_code */
                         decode(g_include_ship_set,'N',null,
		decode(g_line_rec.cancelled_flag,'Y',null,g_set_id)),
	                   /* Ship_Set_Id */
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
                         g_line_rec.order_source_id,              /* ORDER_SOURCE_ID, */
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
                         g_line_rec.commitment_id,               /* commitment_id */
                         null,                                   /* end_item_unit_number */
                         null,                                   /* mfg_component_sequence_id */
                         null,                                   /* config_header_id */
                         null,                                   /* config_rev_nbr */
                         G_PACKING_INSTRUCTIONS,                /* packing_instructions */
                         G_SHIPPING_INSTRUCTIONS,                /* shipping_instructions */
                         g_line_rec.invoiced_quantity,           /* invoiced_quantity */
                         null,                                   /* customer_trx_line_id */
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
                         decode(g_line_rec.open_flag,'Y','I','Y'),/* upgraded_flag */
				     1
                     );

                    /* To fix oe_drop_ship_source if an external line
                       is shipped partially */

                     IF g_line_id <> g_orig_line_id AND
                        g_line_rec.source_type_code = 'EXTERNAL' AND
                        g_line_rec.shipped_quantity is null THEN
                        BEGIN
                           UPDATE oe_drop_ship_sources
                           SET line_id=g_line_id
                           WHERE line_id=g_orig_line_id;
                        EXCEPTION
                         WHEN OTHERS THEN
                              null;
                        END;
                     END IF;



                     r_lctr := r_lctr + 1;

                     G_ERROR_LOCATION := 709;

                     G_Log_Rec.Header_Id          := g_header_id;
                     G_Log_Rec.Old_Line_Id        := mol.line_id;
                     G_Log_Rec.picking_Line_Id    := mol.picking_line_id;
                     G_Log_Rec.Old_Line_Detail_id := mol.line_detail_id;
                     G_Log_Rec.Delivery           := mol.Delivery;

                     G_Log_Rec.New_Line_ID        := g_line_id;    -- 2/24/2000
                     g_log_rec.return_qty_available := g_line_rec.ordered_quantity;  -- 2/24/2000

                     G_Log_Rec.New_Line_Number    := g_line_rec.line_number;
                     G_Log_Rec.mtl_sales_order_id := g_mtl_sales_order_id;

                     OE_UPG_SO_NEW.Upgrade_Insert_Upgrade_Log;

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
                                OE_UPG_SO_NEW.upgrade_insert_errors
                                (
                                   L_header_id => g_header_id,
                                   L_comments  => 'Updating RCV shipment failed for line :'
							   ||to_char(g_old_line_id)||' with oracle error ORA-'
                                          ||to_char(sqlcode));
                     end;

		 /* For return config items do not copy pricing attributes*/
		IF v_return_lctr < 4  or v_return_lctr = 10 then

                     /* ========== Line Level Pricing Attributes =========== Added by jefflee 6/21/00 */
                     l_qp_upg_line_rec := g_line_rec;
                     l_qp_upg_line_rec.line_id:=g_line_id;
                     QP_Upg_OE_PVT.Upg_Pricing_Attribs(l_qp_upg_line_rec);

                     /* ========== Line Level Price Adjustments =========== */

                   IF (    (g_line_rec.item_type_code <> 'INCLUDED' )
                       AND (g_line_rec.item_type_code <> 'CONFIG') ) THEN

                     OE_UPG_SO_NEW.Upgrade_Price_Adjustments
                           ( L_level_flag => 'L');

                   END IF;

                 END IF;

				 /* ========== Line Level Sales Credits =========== */
                     OE_UPG_SO_NEW.Upgrade_Sales_Credits
                            ( L_level_flag => 'L');

                     if OE_UPG_SO_NEW.G_HDR_CANC_FLAG = 'Y' then
                          G_ERROR_LOCATION := 710;
                          g_canc_rec := g_hdr_canc_rec;
                          G_ORD_CANC_FLAG := 'N';
                          OE_UPG_SO_NEW.Upgrade_Insert_Lines_History;
                     end if;

                     if v_bal_return_quantity <= 0  or v_line_exit_flag = 1 then
                           exit;
                     end if;

               end loop;   /* extra loop for returns */

               /* ========== Line Level Cancellations =========== */
/*                    if nvl(mol.cancelled_quantity,0) > 0 and OE_UPG_SO_NEW.G_HDR_CANC_FLAG <> 'Y' then */

               if g_line_id_Change_flag = 'Y' then
                    if nvl(mol.cancelled_quantity,0) > 0 then
                          OE_UPG_SO_NEW.Upgrade_Cancellations ;
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
     select /*+ ORDERED USE_NL(SHA SHATTR) */
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
           sha.sales_channel_code, -- Added by JAUTOMO
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
          decode(sha.cancelled_flag ,'Y', 'N',nvl(sha.open_flag,'N')) open_flag,
           decode(sha.s1,1,'Y','N') booked_flag,
		 sha.s1_date,
		 sha.shipping_instructions,
		 sha.packing_instructions
       from
           so_headers_all          sha,
           so_header_attributes    shattr
       where
           sha.upgrade_flag = 'N' and
           sha.header_id = shattr.header_id(+) and
           (( L_Line_type = 'R' and sha.order_category = 'RMA') or
            ( L_Line_type = 'O' and sha.order_category <> 'RMA')) and
           sha.header_id between v_start_header and v_end_header
       order by
           sha.header_id;

	  v_source_code_profile_value    varchar2(100);
	  v_auto_source_code             varchar2(30);
       v_error_code                   number;
	  l_source_code                  varchar2(30);
       l_count NUMBER := 0;
       v_cancel_comment     long;
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
                 where   slab = L_slab
                 and   nvl(line_type,'O') = L_line_type ;

/*                 where nvl(alloted_flag,'N') = 'N' */

            exception
                 when no_data_found then
                     OE_UPG_SO_NEW.upgrade_insert_errors
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

            OE_UPG_SO_NEW.g_earliest_schedule_limit :=
              to_number(FND_PROFILE.VALUE('OE_SCHEDULE_DATE_WINDOW'));

            OE_UPG_SO_NEW.g_latest_schedule_limit := OE_UPG_SO_NEW.g_earliest_schedule_limit;

            v_source_code_profile_value       := fnd_profile.value('SO_SOURCE_CODE');

            --5302907: Ref. to old sys. param table commented
            /*
            select count(*) into l_count from oe_system_parameters_all;
            IF l_count = 1 THEN
               select master_organization_id
               into v_master_org_for_single_org
               from oe_system_parameters_all;
            END IF;
            */
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
                  G_INVOICE_TO_SITE_USE_ID := moh.invoice_to_site_use_id;
                  G_PURCHASE_ORDER_NUM     := moh.purchase_order_num;
                  G_SALESREP_ID            := moh.salesrep_id;
                  G_TERMS_ID               := moh.terms_id;
                  G_ACCOUNTING_RULE_ID     := moh.accounting_rule_id;
                  G_INVOICING_RULE_ID      := moh.invoicing_rule_id;
                  G_CANCELLED_FLAG         := moh.cancelled_flag;
                  G_ORDER_TYPE_ID          := moh.order_type_id;
                  G_SOURCE_DOCUMENT_ID     := NULL;
                  G_SOURCE_DOCUMENT_TYPE_ID := NULL;
                  G_ORDER_SOURCE_ID        := NULL;
			   G_ORIG_SYS_DOCUMENT_REF  := NULL;
                  G_COPIED_FLAG 		   := 'N';
                  G_ERROR_MESSAGE 		   := NULL;
			   G_INTERNAL_ORDER         := 'N';
			   G_ORDER_SOURCE_ID_LINE   := NULL;
			   G_OPEN_FLAG              := NULL;

                  G_ORDER_SOURCE_ID_LINE := moh.original_system_source_code;

			   G_SHIPPING_INSTRUCTIONS := moh.shipping_instructions;
			   G_PACKING_INSTRUCTIONS := moh.packing_instructions;

			   G_FOB_POINT_CODE := moh.fob_code;
                  -- bug 1661010
                  G_SHIP_TO_SITE_USE_ID := moh.ship_to_site_use_id;

                  if moh.open_flag = 'Y' then
				 G_OPEN_FLAG := 'Y';
			   else
				 G_OPEN_FLAG := 'N';
			   end if;

                  if moh.order_category = 'P' then
                     G_INTERNAL_ORDER := 'Y';
			   end if;

                  if moh.order_category in ('P','R') then
             			G_ORDER_CATEGORY_CODE := 'ORDER';
                  elsif moh.order_category = 'RMA' then
             			G_ORDER_CATEGORY_CODE := 'RETURN';
                  else
			     -- insert error message for invalid order category
				G_ERROR_MESSAGE := 'Invalid Order Category.';
                  	raise G_EXC_INVALID_ORDER_CATEGORY;
                  end if;

                  -- IF original_system_source_code is alphanumeric
			   -- do not process the order
                  if moh.original_system_source_code is not null then
                     begin
                       l_source_code :=
					to_number(moh.original_system_source_code);
                     exception
				      When others then
					   -- insert error message for invalid source
				        G_ERROR_MESSAGE := 'Invalid Order Source code.';
				        raise G_EXC_INVALID_SOURCE_CODE;
                     end;
                  end if;

                  if moh.original_system_source_code = '2'  and
			      moh.original_system_reference is not null then
                     G_SOURCE_DOCUMENT_TYPE_ID := 2;
                     G_COPIED_FLAG             := 'Y';
                     begin
                     G_SOURCE_DOCUMENT_ID      :=
					to_number(moh.original_system_reference);
                     exception
					When Others then
                           -- Error message alphanumeric copy reference
				       G_ERROR_MESSAGE := 'Invalid Copy Order Source.';
					  raise G_EXC_INVALID_COPY_SOURCE;
                     end;

                  elsif moh.order_category  = 'P'  and
				moh.original_system_reference is not null then
                     G_ORDER_SOURCE_ID := 10;
                     G_ORIG_SYS_DOCUMENT_REF := moh.original_system_reference;
                     G_SOURCE_DOCUMENT_TYPE_ID := 10;

                     begin
				   select requisition_header_id into G_SOURCE_DOCUMENT_ID
                       from   po_requisition_headers_all
                       where  segment1 = moh.original_system_reference
                       and    nvl(org_id,-99) = nvl(moh.org_id,-99);
                     exception
					When no_data_found Then
                           -- Message invalid internal order reference
				       G_ERROR_MESSAGE := 'Invalid Internal Order Source.';
					  raise G_EXC_INVALID_INTERNAL_SOURCE;
                     end;
                  elsif moh.original_system_source_code is not NULL then
                     G_ORDER_SOURCE_ID := moh.original_system_source_code;
                     G_ORIG_SYS_DOCUMENT_REF := moh.original_system_reference;
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

                  /* Renga - get new list_header_id for the
                      agreement's price_list_id  */
               --Sameer: retaining old price_list_id for agreements
               /*  begin

                   select new_list_header_id
                   into g_list_header_id
                   from qp_discount_mapping
                   where old_discount_id = moh.price_list_id
                   and old_discount_line_id is null
                   and new_list_line_id is null
                   and new_type = 'P';

                  exception

                     when no_data_found then
                          g_list_header_id := moh.price_list_id;

                  end;
               */
                 /* Renga */

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
                       sold_from_org_id,
				   lock_control,
				   shipping_instructions,
				   packing_instructions
                  )
                  values
                  (
                       moh.header_id,                          /* HEADER_ID */
                       moh.org_id,                             /* ORG_ID */
                       moh.order_type_id,                      /* ORDER_TYPE_ID */
                       moh.order_number,                       /* ORDER_NUMBER */
                       1,                                      /* VERSION_NUMBER, */
                       NULL,                                   /* EXPIRATION_DATE, */
                       G_ORDER_SOURCE_ID,             /* ORDER_SOURCE_ID, */
                       G_SOURCE_DOCUMENT_TYPE_ID,  /* SOURCE_DOCUMENT_TYPE_ID,*/
                       G_ORIG_SYS_DOCUMENT_REF,    /* ORIG_SYS_DOCUMENT_REF,*/
                       G_SOURCE_DOCUMENT_ID,           /* SOURCE_DOCUMENT_ID, */
                       moh.date_ordered,                       /* ORDERED_DATE */
                       moh.date_requested_current,             /* REQUEST_DATE */
                       null,                                   /* PRICING_DATE, */
                       moh.shipment_priority_code,             /* SHIPMENT_PRIORITY_CODE */
                       moh.demand_class_code,                  /* DEMAND_CLASS_CODE */
                       moh.price_list_id,                      /* Renga PRICE_LIST_ID */
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
                       moh.invoicing_rule_id,                  /* INVOICING_RULE_ID */
                       moh.accounting_rule_id,                 /* ACCOUNTING_RULE_ID */
                       moh.terms_id,                           /* PAYMENT_TERM_ID */
                       moh.ship_method_code,                   /* SHIPING_METHOD_CODE */
                       moh.ship_method_code,                 /* FREIGHT_CARRIER_CODE */
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
                       OE_UPG_SO_NEW.G_Earliest_Schedule_Limit,    /* EARLIEST_SCHEDULE_LIMIT */
                       OE_UPG_SO_NEW.G_Latest_Schedule_Limit,      /* LATEST_SCHEDULE_LIMIT   */
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
                       moh.sales_channel_code,                 /* SALES CHANNEL CODE */
                       G_ORDER_CATEGORY_CODE,                  /* ORDER_CATEGORY_CODE */
                       nvl(moh.cancelled_flag,'N'),            /* CANCELLED_FLAG */
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
                       decode(moh.open_flag,'Y','I','Y'),      /* UPGRADED_FLAG */
                       decode(nvl(moh.booked_flag,'-'),'Y',
                               moh.s1_date,NULL),              /* BOOKED_DATE */
                       moh.org_id,                             /* SOLD_FROM_ORG_ID */
				   1,
				   moh.shipping_instructions,
				   moh.packing_instructions
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
                                 g_hdr_canc_rec.can_header_id ,
                                 g_hdr_canc_rec.can_line_id ,
                                 g_hdr_canc_rec.can_created_by ,
                                 g_hdr_canc_rec.can_creation_date ,
                                 g_hdr_canc_rec.can_last_updated_by ,
                                 g_hdr_canc_rec.can_last_update_date ,
                                 g_hdr_canc_rec.can_last_update_login ,
                                 g_hdr_canc_rec.can_program_application_id ,
                                 g_hdr_canc_rec.can_program_id ,
                                 g_hdr_canc_rec.can_program_update_date ,
                                 g_hdr_canc_rec.can_request_id ,
                                 g_hdr_canc_rec.can_cancel_code ,
                                 g_hdr_canc_rec.can_cancelled_by ,
                                 g_hdr_canc_rec.can_cancel_date ,
                                 g_hdr_canc_rec.can_cancelled_quantity ,
                                 v_cancel_comment ,
                                 g_hdr_canc_rec.can_context ,
                                 g_hdr_canc_rec.can_attribute1 ,
                                 g_hdr_canc_rec.can_attribute2 ,
                                 g_hdr_canc_rec.can_attribute3 ,
                                 g_hdr_canc_rec.can_attribute4 ,
                                 g_hdr_canc_rec.can_attribute5 ,
                                 g_hdr_canc_rec.can_attribute6 ,
                                 g_hdr_canc_rec.can_attribute7 ,
                                 g_hdr_canc_rec.can_attribute8 ,
                                 g_hdr_canc_rec.can_attribute9 ,
                                 g_hdr_canc_rec.can_attribute10 ,
                                 g_hdr_canc_rec.can_attribute11 ,
                                 g_hdr_canc_rec.can_attribute12 ,
                                 g_hdr_canc_rec.can_attribute13 ,
                                 g_hdr_canc_rec.can_attribute14 ,
                                 g_hdr_canc_rec.can_attribute15
                             --    G_Hdr_Canc_Rec
                            from
                                 so_order_cancellations    soc
                            where   soc.header_id = g_header_id
                            and     soc.line_Id   is null
                            and     rownum =1 ;
                            g_hdr_canc_rec.can_cancel_comment := v_cancel_comment;
                            g_hdr_canc_rec.can_cancel_comment:=substrb(g_hdr_canc_rec.can_cancel_comment,1,2000) ;
                       end if;
                  exception
                       when others then
                            null;
                  end;

                  /* ============  Order Lines Creation ===========*/

                  G_LINE_ID := NULL;
                  OE_UPG_SO_NEW.Upgrade_Create_Order_Lines;

                  /* ============  Line Sets Creation (ontupg46.sql )=======*/
                         -- bug fix 1759900
                         IF G_OPEN_ATO_MODEL = 1 THEN
			   OE_UPG_SO_NEW.Insert_Multiple_Models;
                         END IF;

                  /* ============  Line Sets Creation (ontupg16.sql )=======*/

                  -- Changed to conditional execution on 10/23/01 by stsukuma
                  IF  G_OPEN_FLAG = 'Y' THEN
			   OE_UPG_SO_NEW.Upgrade_Create_Line_Sets;
                  END IF;

                  /* ============  Updates After Creation =======*/

			   OE_UPG_SO_NEW.Update_After_Insert;

                  /* ============  Update Remnant Flag(ontupg53) =======*/

                  IF  G_OPEN_FLAG = 'Y' THEN

			       OE_UPG_SO_NEW.Update_remnant_flag;
                  END IF;

                  /* ============  Updates for Returns =======*/

                  IF  G_ORDER_CATEGORY_CODE = 'RETURN' THEN
			   	  Process_Upgraded_Returns(G_HEADER_ID);
				  Return_Fulfillment_Sets(G_HEADER_ID);
                  END IF;

                  /* ============  Header Level Sales Credits ===========*/
                  OE_UPG_SO_NEW.Upgrade_Sales_Credits
                  ( L_level_flag => 'H');

                  /* ============  Header Level Price Adjustments ===========*/
                  OE_UPG_SO_NEW.Upgrade_Price_Adjustments ( L_level_flag => 'H');

                  /* ============  Upgrade Log Handling ===========*/

                  g_log_rec                     := NULL;
                  g_log_rec.header_id           := g_header_id;
                  g_log_rec.mtl_sales_order_id  := g_mtl_sales_order_id;

                  OE_UPG_SO_NEW.Upgrade_Insert_Upgrade_Log;

                  Update SO_HEADERS_ALL
                  set upgrade_flag = 'Y'
                  where header_id = G_HEADER_ID;

                  G_ERROR_LOCATION := 10;

                  if G_ERROR_ALERT = 'Y' then
                       G_ERROR_LOCATION := 11;
                       ROLLBACK TO HEADER_SAVE_POINT;
                       v_error_code := sqlcode;
                       OE_UPG_SO_NEW.upgrade_insert_errors
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
                  when G_EXC_INVALID_COPY_SOURCE THEN
                       ROLLBACK TO HEADER_SAVE_POINT;
                       OE_UPG_SO_NEW.upgrade_insert_errors
                       (  L_header_id => G_HEADER_ID,
                          L_comments  => G_ERROR_MESSAGE
                        );
                       Mark_Order_As_Non_Updatable(G_HEADER_ID);
				   COMMIT;
				   commit_counter := 0;
                       G_ERROR_ALERT  := 'N';
                  when G_EXC_INVALID_INTERNAL_SOURCE THEN
                       ROLLBACK TO HEADER_SAVE_POINT;
                       OE_UPG_SO_NEW.upgrade_insert_errors
                       (  L_header_id => G_HEADER_ID,
                          L_comments  => G_ERROR_MESSAGE
                        );
                       Mark_Order_As_Non_Updatable(G_HEADER_ID);
				   COMMIT;
				   commit_counter := 0;
                       G_ERROR_ALERT  := 'N';
                  when G_EXC_INVALID_SOURCE_CODE THEN
                       ROLLBACK TO HEADER_SAVE_POINT;
                       OE_UPG_SO_NEW.upgrade_insert_errors
                       (  L_header_id => G_HEADER_ID,
                          L_comments  => G_ERROR_MESSAGE
                        );
                       Mark_Order_As_Non_Updatable(G_HEADER_ID);
				   COMMIT;
				   commit_counter := 0;
                       G_ERROR_ALERT  := 'N';
                  when G_EXC_INVALID_ORDER_CATEGORY THEN
                       ROLLBACK TO HEADER_SAVE_POINT;
                       OE_UPG_SO_NEW.upgrade_insert_errors
                       (  L_header_id => G_HEADER_ID,
                          L_comments  => G_ERROR_MESSAGE
                        );
                       Mark_Order_As_Non_Updatable(G_HEADER_ID);
				   COMMIT;
				   commit_counter := 0;
                       G_ERROR_ALERT  := 'N';
                  when G_EXC_INVALID_RMA_REFERENCE THEN
                       ROLLBACK TO HEADER_SAVE_POINT;
                       OE_UPG_SO_NEW.upgrade_insert_errors
                       (  L_header_id => G_HEADER_ID,
                          L_comments  => G_ERROR_MESSAGE
                        );
                       Mark_Order_As_Non_Updatable(G_HEADER_ID);
				   COMMIT;
				   commit_counter := 0;
                       G_ERROR_ALERT  := 'N';
                  when G_EXC_INVALID_ORIGSYS_LINEREF THEN
                       ROLLBACK TO HEADER_SAVE_POINT;
                       OE_UPG_SO_NEW.upgrade_insert_errors
                       (  L_header_id => G_HEADER_ID,
                          L_comments  => G_ERROR_MESSAGE
                        );
                       Mark_Order_As_Non_Updatable(G_HEADER_ID);
				   COMMIT;
				   commit_counter := 0;
                       G_ERROR_ALERT  := 'N';
                  when G_EXC_INVALID_SRC_DOC_LINE THEN
                       ROLLBACK TO HEADER_SAVE_POINT;
                       OE_UPG_SO_NEW.upgrade_insert_errors
                       (  L_header_id => G_HEADER_ID,
                          L_comments  => G_ERROR_MESSAGE
                        );
                       Mark_Order_As_Non_Updatable(G_HEADER_ID);
				   COMMIT;
				   commit_counter := 0;
                       G_ERROR_ALERT  := 'N';
                  when others then
                       /* G_ERROR_LOCATION := 12; */
                       ROLLBACK TO HEADER_SAVE_POINT;
                       v_error_code := sqlcode;
                       OE_UPG_SO_NEW.upgrade_insert_errors
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
              if commit_counter > 100 then
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
            reference_customer_trx_line_id,
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
		  customer_trx_line_id,
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
            g_line_rec.line_number,                         /* LINE_NUMBER */
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
            g_line_rec.tax_date,                                     /* TAX_DATE */
            g_line_rec.tax_code,                            /* TAX_CODE */
            null,                                           /* TAX_RATE */
            g_line_rec.demand_class_code,                   /* DEMAND_CLASS_CODE */
            g_line_rec.price_list_id,                       /* PRICE_LIST_ID */
            null,                                           /* PRICING_DATE */
            r_shipment_number,                              /* SHIPMENT_NUMBER */
            g_line_rec.agreement_id,                        /* AGREEMENT_ID */
            g_line_rec.shipment_priority_code,              /* SHIPMENT_PRIORITY_CODE */
            g_line_rec.ship_method_code,             /* SHIPPPING_METHOD_CODE */
            g_line_rec.ship_method_code,                    /* FREIGHT_CARRIER_CODE */
            G_freight_terms_code,                           /* FREIGHT_TERMS_CODE */
            G_FOB_POINT_CODE,                               /* FOB_POINT_CODE */
            'INVOICE',                                      /* TAX_POINT_CODE */
            g_line_rec.terms_id,                            /* PAYMENT_TERM_ID */
            g_line_rec.invoicing_rule_id,                   /* INVOICING_RULE_ID */
            g_line_rec.accounting_rule_id,                  /* ACCOUNTING_RULE_ID */

            g_line_rec.source_document_type_id,             /* SOURCE_DOCUMENT_TYPE_ID */
            null,                                           /* ORIG_SYS_DOCUMENT_REF */
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
            g_line_rec.sort_order,                          /* SORT_ORDER, */
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
                                                     NULL), /* REFERENCE_CUSTOMER_TRX_LINE_ID */
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
            g_line_rec.split_from_line_id,                  /* split_from_line_id */
            g_line_rec.planning_prod_seq_number,            /* cust_production_seq_num */
            decode(G_AUTO_FLAG,'Y','Y',NULL),               /* authorized_to_ship_flag */
            g_line_rec.invoice_interface_status_code,       /* invoice_interface_status_code */
            decode(g_include_ship_set,'N',null,
		decode(g_line_rec.cancelled_flag,'Y',null,g_set_id)),                                       /* Ship_Set_Id */
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
            g_line_rec.parent_line_id,                      /* top_model_line_id, */
            g_line_rec.cancelled_flag,                      /* cancelled_flag, */
            g_line_rec.open_flag,                           /* open_flag, */
            null,                                           /* over_ship_reason_code, */
            null,                                           /* over_ship_resolved_flag, */
            decode(nvl(g_line_rec.customer_item_id,-1),
              -1,'INT','CUST'),                             /* item_identifier_type, */
            g_line_rec.commitment_id,                       /* commitment_id, */
            g_line_rec.shipping_interfaced_flag,            /* shipping_interfaced_flag, */
            g_line_rec.credit_invoice_line_id,              /* credit_invoice_line_id, */
            null,                                           /* end_item_unit_number, */
            null,                                           /* mfg_component_sequence_id, */
            null,                                           /* config_header_id, */
            null,                                           /* config_rev_nbr, */
            g_shipping_instructions,                        /* shipping_instructions, */
            g_packing_instructions,                         /* packing_instructions, */
            g_line_rec.invoiced_quantity,                   /* invoiced_quantity, */
            null,                                           /* customer_trx_line_id, */
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
            g_line_rec.revenue_amount                       /* revenue_amount, */
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
       (  L_total_slabs IN number,
		L_type        IN varchar2)
      is
      v_type              varchar2(1);
      cursor RDis
      is
      select
          sha.header_id
      from
          so_headers_all sha
      where
		 ( sha.upgrade_flag = 'N' and   (sha.order_category =  'RMA' and v_type = 'R') )  or
           ( sha.upgrade_flag = 'N' and  (sha.order_category <> 'RMA' and v_type = 'O' ) )  or
           ( nvl(sha.upgrade_flag,'N') in ('N','X') and v_type = 'M')  or
           ( sha.open_flag = 'Y' and sha.upgrade_flag = 'Y' and v_type = 'W')
      order by sha.header_id;

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

   --
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
   --
   Begin
      v_type := L_type;

      delete oe_upgrade_distribution
	 where line_type  = v_type;
      commit;


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
                where
                ( sha.upgrade_flag = 'N' and (sha.order_category =  'RMA' and v_type = 'R') )  or
                ( sha.upgrade_flag = 'N' and (sha.order_category <> 'RMA' and v_type = 'O') )  or
                ( nvl(sha.upgrade_flag,'N') in ('N','X') and v_type = 'M')  or
                ( sha.open_flag = 'Y' and sha.upgrade_flag = 'Y' and v_type = 'W');
           exception
                when others then
                  null;
           end;

           if  v_total_headers < 500  or l_total_slabs = 1 then

                OE_UPG_SO_NEW.Upgrade_Insert_Distbn_Record
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

                         OE_UPG_SO_NEW.Upgrade_Insert_Distbn_Record
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

                OE_UPG_SO_NEW.Upgrade_Insert_Distbn_Record
                (
                    L_slab             => v_slab_count,
                    L_start_header_id  => v_min_header,
                    L_end_Header_id    => v_max_header ,
                    L_type_var         => v_type
                );

                commit;
	      end if;
      commit;

   End Upgrade_Process_Distbns;


   PROCEDURE upgrade_inst_detail_distbns
     (
      p_number_of_slabs IN NUMBER
      )
     IS

	TYPE line_service_cursor_type IS REF CURSOR;

	line_service_detail_count line_service_cursor_type;

	-- Dynamic SQL used because the select based column expressions
	-- did not compile when used directly as a cursor definition.
	-- This cursor allows us to determine the actual slab distribution
	-- by doing only one index scan of the primary key index for this table

	l_cursor_stmt VARCHAR2(2000) :=
	  'select ' ||
	  '   line_service_detail_id,'||
	  '   (select count(1) from so_line_service_details),' ||
	  '   (select min(line_service_detail_id) from so_line_service_details),' ||
	  '   (select max(line_service_detail_id) from so_line_service_details)' ||
	  ' from so_line_service_details' ||
	  ' order by line_service_detail_id';

	l_total_slabs            NUMBER := p_number_of_slabs;
	l_current_slab           NUMBER := 1;
	l_record_counter         NUMBER := 0;
	l_records_per_slab       NUMBER := 0;

	l_line_service_detail_id NUMBER := NULL;
	l_row_count              NUMBER := NULL;
	l_min_id                 NUMBER := NULL;
	l_max_id                 NUMBER := NULL;

	l_starting_id            NUMBER := NULL;
	l_ending_id              NUMBER := NULL;

	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
   BEGIN

      DELETE FROM oe_upgrade_distribution
	WHERE line_type = 'I';

      OPEN line_service_detail_count FOR l_cursor_stmt;

      FETCH line_service_detail_count INTO
	l_line_service_detail_id,  l_row_count,  l_min_id,  l_max_id;

      IF line_service_detail_count%NOTFOUND THEN

	 NULL;

       ELSIF l_row_count < 500 OR l_total_slabs = 1 THEN

	 oe_upg_so_new.upgrade_insert_distbn_record
	   (
	    l_slab            => 1,
	    l_start_header_id => l_min_id,
	    l_end_header_id   => l_max_id,
	    l_type_var        => 'I'
	    );

       ELSE

	 l_records_per_slab := Round(l_row_count / l_total_slabs);
	 l_starting_id :=  l_line_service_detail_id;
	 l_record_counter := l_record_counter + 1;

	 LOOP

	    IF (l_record_counter = l_records_per_slab
		AND l_current_slab < l_total_slabs) THEN

	       oe_upg_so_new.upgrade_insert_distbn_record
		 (
		  l_slab            => l_current_slab,
		  l_start_header_id => l_starting_id,
		  l_end_header_id   => l_line_service_detail_id,
		  l_type_var        => 'I'
		  );

	       l_current_slab := l_current_slab + 1;
	       l_record_counter := 0;

	       FETCH line_service_detail_count INTO
		 l_line_service_detail_id,  l_row_count, l_min_id, l_max_id;
	       EXIT WHEN line_service_detail_count%notfound;

	       l_starting_id := l_line_service_detail_id;

	     ELSE

		  FETCH line_service_detail_count INTO
		    l_line_service_detail_id,  l_row_count, l_min_id, l_max_id;
		  EXIT WHEN line_service_detail_count%notfound;

	    END IF;

	    l_record_counter := l_record_counter + 1;

	 END LOOP;

	 IF l_record_counter <> 0 THEN

	    oe_upg_so_new.upgrade_insert_distbn_record
	      (
	       l_slab            => l_current_slab,
	       l_start_header_id => l_starting_id,
	       l_end_header_id   => l_max_id,
	       l_type_var        => 'I'
	       );

	 END IF;

      END IF;

      CLOSE line_service_detail_count;

      COMMIT;

   END upgrade_inst_detail_distbns;

   ---------------------------------
   --  Upgrade_holds_Distbns      --
   ---------------------------------
   Procedure  Upgrade_holds_Distbns
       (  L_total_slabs IN number )
      is
      v_type              varchar2(1);
      cursor RDis
      is
      select
          shsa.hold_source_id
      from
          so_hold_sources_all  shsa
      order by shsa.hold_source_id;

      v_total_sources     number;
      v_min_source        number;
      v_max_source        number;
      v_counter           number;
      v_gap               number;
      v_slab_count        number;
      v_slab_start        number;
      v_slab_end          number;
      v_dis_hold_source_id     number;
      v_start_flag        number;
      v_total_slabs       number;

   --
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
   --
   Begin
      v_type := 'H';

      delete oe_upgrade_distribution
	 where line_type  = v_type;
      commit;


           begin
                select
                     count(*),
                     nvl(min(shsa.hold_source_id),0),
                     nvl(max(shsa.hold_source_id),0)
                into
                     v_total_sources,
                     v_min_source,
                     v_max_source
                from
                     so_hold_sources_all  shsa;
           exception
                when others then
                  null;
           end;

           if  v_total_sources < 500  or l_total_slabs = 1 then

                OE_UPG_SO_NEW.Upgrade_Insert_Distbn_Record
                (
                    L_slab             => 1,
                    L_start_header_id  => v_min_source,
                    L_end_Header_id    => v_max_source,
                    L_type_var         => v_type
                );

           else
                v_min_source  := 0;
                v_max_source  := 0;
                v_total_slabs := L_total_slabs;
                v_counter     := 0;
                v_start_flag  := 0;
                v_slab_count  := 0;
                v_gap         := round(v_total_sources / v_total_slabs);

                for  MRdis  in  Rdis  loop

                    v_dis_hold_source_id := MRdis.hold_source_id;
                    v_counter            := v_counter + 1;

                    if v_start_flag = 0 then
                              v_start_flag := 1;
                              v_min_source := MRdis.hold_source_id;
                              v_max_source := NULL;
                              v_slab_count := v_slab_count + 1;
                    end if;

                    if v_counter = v_gap and v_slab_count < v_total_slabs then
                         v_max_source := MRdis.hold_source_id;

                         OE_UPG_SO_NEW.Upgrade_Insert_Distbn_Record
                         (
                             L_slab             => v_slab_count,
                             L_start_header_id  => v_min_source,
                             L_end_Header_id    => v_max_source,
                             L_type_var         => v_type
                         );

                         v_counter    := 0;
                         v_start_flag := 0;
                    end if;

                end loop;
                v_max_source := v_dis_hold_source_id;

                OE_UPG_SO_NEW.Upgrade_Insert_Distbn_Record
                (
                    L_slab             => v_slab_count,
                    L_start_header_id  => v_min_source,
                    L_end_Header_id    => v_max_source ,
                    L_type_var         => v_type
                );

                commit;
	      end if;
      commit;

   End Upgrade_holds_Distbns;

   ---------------------------------------
   -- Upgrade Freight Charges Distribution
   ---------------------------------------

Procedure  Upgrade_Freight_Distbns
(  L_total_slabs IN number)
      is
      v_type              varchar2(1);
      CURSOR C_FREIGHT
      IS
      SELECT freight_charge_id
      FROM so_freight_charges
      ORDER BY freight_charge_id;

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

   --
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
   --
  BEGIN
      v_type := 'F';

      DELETE oe_upgrade_distribution
	 WHERE line_type  = v_type;
      COMMIT;


      BEGIN
          SELECT
                count(*),
                nvl(min(freight_charge_id),0),
                nvl(max(freight_charge_id),0)
          INTO
                v_total_headers,
                v_min_header,
                v_max_header
          FROM
                so_freight_charges;
      EXCEPTION
          WHEN OTHERS THEN
                  NULL;
      END;

      IF  v_total_headers < 500  or l_total_slabs = 1 then

          OE_UPG_SO_NEW.Upgrade_Insert_Distbn_Record
          (
                    L_slab             => 1,
                    L_start_header_id  => v_min_header,
                    L_end_Header_id    => v_max_header,
                    L_type_var         => v_type
           );

      ELSE
          v_max_header  := 0;
          v_min_header  := 0;
          v_total_slabs := L_total_slabs;
          v_counter     := 0;
          v_start_flag  := 0;
          v_slab_count  := 0;
          v_gap         := round(v_total_headers / v_total_slabs);

          FOR  C1  IN  C_FREIGHT  LOOP
              v_dis_header_id := C1.freight_charge_id;
              v_counter       := v_counter + 1;

              IF v_start_flag = 0 then
                  v_start_flag := 1;
                  v_min_header := C1.freight_charge_id;
                  v_max_header := NULL;
                  v_slab_count := v_slab_count + 1;
              END IF;

              IF v_counter = v_gap and v_slab_count < v_total_slabs then
                  v_max_header := C1.freight_charge_id;

                  OE_UPG_SO_NEW.Upgrade_Insert_Distbn_Record
                  (
                             L_slab             => v_slab_count,
                             L_start_header_id  => v_min_header,
                             L_end_Header_id    => v_max_header,
                             L_type_var         => v_type
                  );

                  v_counter    := 0;
                  v_start_flag := 0;
              END IF;

          END LOOP;
          v_max_header := v_dis_header_id;

          OE_UPG_SO_NEW.Upgrade_Insert_Distbn_Record
          (
                    L_slab             => v_slab_count,
                    L_start_header_id  => v_min_header,
                    L_end_Header_id    => v_max_header ,
                    L_type_var         => v_type
          );

	 END IF;
      COMMIT;

  END Upgrade_Freight_Distbns;


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
           substr(l_comments,1,240),
           sysdate
       );

       G_ERROR_LOCATION := 19;
   End Upgrade_Insert_Errors;

Procedure update_remnant_flag
IS

   cursor model_lines IS
      select /*+ INDEX(SO_LINES_N1) */ lines.line_id
      from so_lines_all lines
      where lines.header_id = G_HEADER_ID
	 and lines.item_type_code in ('MODEL','KIT')
      and parent_line_id is null
      and lines.line_type_code in ('REGULAR','DETAIL');

   cursor option_lines(p_parent_line_id IN NUMBER) IS
      select line_id,inventory_item_id,item_type_code
      from so_lines_all
      where parent_line_id=p_parent_line_id;

   cursor included_items(p_line_id IN NUMBER) IS
      select line_detail_id
      from so_line_details
      where line_id=p_line_id
      AND included_item_flag = 'Y';

   l_parent_line_id        NUMBER  := 0;
   l_ii_line_id            NUMBER;
   l_detail_line_id        NUMBER;
   no_of_details           NUMBER;
   no_of_picking_details   NUMBER;
   l_valid                 VARCHAR2(1) := 'N';
   multiple_details_exist  BOOLEAN := FALSE;
   l_count                 NUMBER := 0;
   l_option_line_id        NUMBER;
   l_item_type_code        VARCHAR2(30);
   l_inventory_item_id     NUMBER;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
begin

  OPEN model_lines;

  LOOP

     FETCH model_lines INTO l_parent_line_id;
     EXIT WHEN model_lines%notfound;

     /* Check for the model line if there are multiple included items */

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'MODEL LINE ID : ' || L_PARENT_LINE_ID ) ;
     END IF;

     SELECT count(*)
     INTO no_of_details
     FROM SO_LINE_DETAILS
     WHERE LINE_ID = l_parent_line_id
     AND   INCLUDED_ITEM_FLAG = 'N'
     AND   nvl(CONFIGURATION_ITEM_FLAG,'N') = 'N';

     IF no_of_details > 1 THEN
                                              IF l_debug_level  > 0 THEN
                                                  oe_debug_pub.add(  'MULTIPLE DETAILS EXIST FOR :' || L_PARENT_LINE_ID ) ;
                                              END IF;
        multiple_details_exist := TRUE;
        goto mld;
     END IF;

     BEGIN
       SELECT line_detail_id
       INTO l_detail_line_id
       FROM SO_LINE_DETAILS
       WHERE LINE_ID = l_parent_line_id
       AND   INCLUDED_ITEM_FLAG = 'N'
       AND   nvl(CONFIGURATION_ITEM_FLAG,'N') = 'N';
     EXCEPTION
       WHEN OTHERS THEN
            l_detail_line_id:=0;
     END;

     /* Check to see if  the oe_upgrade_wsh_iface have multiple
     details */

     SELECT /*+ INDEX(oe_upgrade_wsh_iface OE_UPGRADE_WSH_IFACE_N2) */
	count(*)
     INTO no_of_picking_details
     from oe_upgrade_wsh_iface
     where line_detail_id = l_detail_line_id;

     IF no_of_picking_details > 1 THEN
                                            IF l_debug_level  > 0 THEN
                                                oe_debug_pub.add(  'MULTIPLE PICKING DETAILS EXIST FOR :' || L_PARENT_LINE_ID ) ;
                                            END IF;
        multiple_details_exist := TRUE;
        goto mld;
     END IF;

     BEGIN
       SELECT 'Y'
       INTO l_valid
       FROM so_line_details
       WHERE line_id=l_parent_line_id
       AND included_item_flag='Y'
       group by inventory_item_id
       having count(*) > 1;

                                            IF l_debug_level  > 0 THEN
                                                oe_debug_pub.add(  'MULTIPLE INCLUDED ITEM EXISTS FOR :' || L_PARENT_LINE_ID ) ;
                                            END IF;

     EXCEPTION
       WHEN OTHERS THEN
             null;
     END ;

     IF l_valid = 'Y' THEN
	   IF l_debug_level  > 0 THEN
	       oe_debug_pub.add(  '1. SETTING MULTIPLE_DETAILS_EXIST TO TRUE' , 1 ) ;
	   END IF;
        multiple_details_exist := TRUE;
        goto mld;
     END IF;

     OPEN included_items(l_parent_line_id);

     LOOP

       FETCH included_items
       INTO l_ii_line_id;
       EXIT WHEN included_items%notfound;

       SELECT count(*)
       INTO no_of_picking_details
       from oe_upgrade_wsh_iface
       where line_detail_id = l_ii_line_id;

       IF no_of_picking_details > 1 THEN
                                            IF l_debug_level  > 0 THEN
                                                oe_debug_pub.add(  'MULTIPLE PICKING DETAILS EXIST FOR :' || L_II_LINE_ID ) ;
                                            END IF;
          multiple_details_exist := TRUE;
          EXIT;
       END IF;

     END LOOP;

     CLOSE included_items;

     IF multiple_details_exist THEN
	          IF l_debug_level  > 0 THEN
	              oe_debug_pub.add(  '1. GOTO MULTIPLE_DETAILS_EXIST' , 1 ) ;
	          END IF;
               goto mld;
     END IF;

     -- Get the multiple config lines.
     OPEN option_lines(l_parent_line_id);

     LOOP

         -- Get next config line. You should create new model and options
         -- only for the second config detail.

         FETCH option_lines
         INTO l_option_line_id,l_inventory_item_id,l_item_type_code;
         EXIT WHEN option_lines%notfound;

         -- See if the option has multiple details

         SELECT count(*)
         INTO no_of_details
         FROM SO_LINE_DETAILS
         WHERE LINE_ID = l_option_line_id
         AND   INVENTORY_ITEM_ID = l_inventory_item_id
         AND   INCLUDED_ITEM_FLAG = 'N'
         AND   nvl(CONFIGURATION_ITEM_FLAG,'N') = 'N';

         IF no_of_details > 1 THEN
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'MULTIPLE DETAILS EXIST FOR :' || L_OPTION_LINE_ID ) ;
            END IF;
            multiple_details_exist := TRUE;
            EXIT;
         END IF;

         /* Check to see if  the oe_upgrade_wsh_iface have multiple
            details */
          BEGIN
            SELECT line_detail_id
            INTO l_detail_line_id
            FROM SO_LINE_DETAILS
            WHERE LINE_ID = l_option_line_id
            AND   INVENTORY_ITEM_ID = l_inventory_item_id
            AND   INCLUDED_ITEM_FLAG = 'N'
            AND   nvl(CONFIGURATION_ITEM_FLAG,'N') = 'N';
          EXCEPTION
		   WHEN OTHERS THEN
				l_detail_line_id := 0;
          END;


          SELECT count(*)
          INTO no_of_picking_details
          from oe_upgrade_wsh_iface
          where line_detail_id = l_detail_line_id;

         IF no_of_picking_details > 1 THEN
                                            IF l_debug_level  > 0 THEN
                                                oe_debug_pub.add(  'MULTIPLE PICKING DETAILS EXIST FOR :' || L_OPTION_LINE_ID ) ;
                                            END IF;
            multiple_details_exist := TRUE;
            EXIT;
         END IF;

         /* Check to see if the included items of this option class
           have multiple details. */
         IF l_item_type_code = 'CLASS' THEN
             BEGIN
                SELECT 'Y'
                INTO l_valid
                FROM so_line_details
                WHERE line_id=l_option_line_id
                AND included_item_flag='Y'
                group by inventory_item_id
                having count(*) > 1;

                                            IF l_debug_level  > 0 THEN
                                                oe_debug_pub.add(  'MULTIPLE INCLUDED ITEM EXISTS FOR :' || L_OPTION_LINE_ID ) ;
                                            END IF;

             EXCEPTION
                WHEN OTHERS THEN
                         null;
             END ;

             IF l_valid = 'Y' THEN
	           IF l_debug_level  > 0 THEN
	               oe_debug_pub.add(  '1. EXITING' , 1 ) ;
	           END IF;
                EXIT;
             END IF;
         END IF;

         IF l_item_type_code ='CLASS' THEN
             OPEN included_items(l_option_line_id);

             LOOP

               FETCH included_items
               INTO l_ii_line_id;
               EXIT WHEN included_items%notfound;

               SELECT count(*)
               INTO no_of_picking_details
               from oe_upgrade_wsh_iface
               where line_detail_id = l_ii_line_id;

               IF no_of_picking_details > 1 THEN
                                            IF l_debug_level  > 0 THEN
                                                oe_debug_pub.add(  'MULTIPLE PICKING DETAILS EXIST FOR :' || L_II_LINE_ID ) ;
                                            END IF;
                 multiple_details_exist := TRUE;
                 EXIT;
               END IF;

             END LOOP;

             CLOSE included_items;
             IF multiple_details_exist THEN
	          IF l_debug_level  > 0 THEN
	              oe_debug_pub.add(  '2. EXITING' , 1 ) ;
	          END IF;
               EXIT;
             END IF;
         END IF;
     END LOOP;

     CLOSE option_lines;
     <<mld>>
     IF multiple_details_exist THEN
        -- Update remnant_flag in oe_order_lines

        l_count := l_count + 1;

        UPDATE /*+ INDEX(OE_ORDER_LINES_N10) */ OE_ORDER_LINES_ALL
        SET model_remnant_flag='Y'
        WHERE top_model_line_id=l_parent_line_id
        AND model_remnant_flag is null ;


        multiple_details_exist := FALSE;
        l_valid := null;
/*
        IF l_count > 500 THEN
           l_count := 0;
           commit;
        END IF;
*/
     END IF;

  END LOOP;
  CLOSE model_lines;

exception
      when others then
             OE_UPG_SO_NEW.upgrade_insert_errors
             ( L_header_id => g_header_id,
               L_comments  => 'Update_Remnant_Flag failed on ora error: '||to_char(sqlcode)
             );
             raise;

end update_remnant_flag;

   Procedure Update_After_Insert
   IS

	   Cursor c_get_record is
	   select /*+ INDEX(OE_ORDER_LINES_N1) */
			line_id,
			item_type_code,
			top_model_line_id,
			ato_line_id,
			shippable_flag,
			shipped_quantity,
			line_number,
			shipment_number,
			model_remnant_flag,
			link_to_line_id,
            line_category_code,
			fulfilled_quantity,
			fulfilled_flag,
			fulfillment_date,
			actual_shipment_date,
			ordered_quantity,
			service_reference_line_id,
			option_number,
			component_number,
            unit_selling_price,
            unit_list_price,
            ship_set_id,
            ship_from_org_id,
            ship_to_org_id,
            schedule_ship_date,
            schedule_status_code
         from
			oe_order_lines_all
         where
			header_id = G_HEADER_ID;

      cursor service_product_lines (p_serviceable_line_id IN NUMBER) IS
	    select line_id , service_parent_line_id
	    from so_lines_all
	    where service_parent_line_id = p_serviceable_line_id;

      cursor log_product_lines (p_service_parent_line_id IN NUMBER) IS

	    select old_line_id, new_line_id from
	    oe_upgrade_log_v where
	    old_line_id = p_service_parent_line_id
	    and old_line_id <> new_line_id
	    order by new_line_id;

       cursor log_service_lines (p_line_id IN NUMBER) IS

	    select old_line_id, new_line_id from
	    oe_upgrade_log_v where
	    old_line_id = p_line_id
	    and old_line_id <> new_line_id
	    order by new_line_id;

      v_new_line_id number;
      l_serviceable_line_id        NUMBER;
	 l_line_id                    NUMBER;
	 l_service_parent_line_id     NUMBER;
	 l_old_line_id1               NUMBER;
	 l_old_line_id2               NUMBER;
	 l_new_line_id1               NUMBER;
	 l_new_line_id2               NUMBER;
         l_count                      NUMBER;
    l_get_record        c_get_record%rowtype;
--    l_get_table         get_update_tbl_type;
    TYPE temp_get_table IS TABLE OF c_get_record%rowtype
    INDEX BY BINARY_INTEGER;
    l_get_table         temp_get_table;
    l_get_index         NUMBER := 0;
    l_temp_index        NUMBER := 0;
    l_ii_table          temp_get_table;
    l_ii_index          NUMBER := 0;
    TYPE top_model_tbl IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;
    l_top_model_tbl				top_model_tbl;
    l_top_model_index   NUMBER := 0;
    l_not_shipped_line      BOOLEAN;
    l_shipped_line          BOOLEAN;
    l_update_table       update_tbl_type;
    l_update_index		NUMBER:=0;
    l_main_component     NUMBER :=0;
    l_ii_component     NUMBER :=0;
    l_option_number    NUMBER := 0;
    l_service_reference_line_id NUMBER := 0;
    l_new_line_id      NUMBER;
    l_not_in_the_set   BOOLEAN;
    l_in_the_set       BOOLEAN;
    l_invalid_set      BOOLEAN;
    l_ship_set_id      NUMBER;
    l_set_index        NUMBER;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
   BEGIN

	 FOR  l_temp_record IN  c_get_record
	 LOOP

           l_get_index := l_temp_record.line_id;
		 l_get_record := l_temp_record;
		 l_get_table(l_get_index) := l_temp_record;
		 l_update_table(l_get_index).line_number := l_temp_record.line_number;
		 l_update_table(l_get_index).option_number := l_temp_record.option_number;
		 l_update_table(l_get_index).shipment_number := l_temp_record.shipment_number;
		 l_update_table(l_get_index).component_number := l_temp_record.component_number;
		 l_update_table(l_get_index).ordered_quantity := l_temp_record.ordered_quantity;
		 l_update_table(l_get_index).shipped_quantity := l_temp_record.shipped_quantity;
		 l_update_table(l_get_index).fulfilled_quantity := l_temp_record.fulfilled_quantity;
		 l_update_table(l_get_index).fulfilled_flag := l_temp_record.fulfilled_flag;
		 l_update_table(l_get_index).fulfillment_date := l_temp_record.fulfillment_date;
		 l_update_table(l_get_index).actual_shipment_date := l_temp_record.actual_shipment_date;
		 l_update_table(l_get_index).model_remnant_flag := l_temp_record.model_remnant_flag;
		 l_update_table(l_get_index).service_reference_line_id := l_temp_record.service_reference_line_id;
		 l_update_table(l_get_index).item_type_code := l_temp_record.item_type_code;
		 l_update_table(l_get_index).top_model_line_id := l_temp_record.top_model_line_id;

                 l_update_table(l_get_index).ato_line_id := l_temp_record.ato_line_id;
                 --bug 1869550 fix. for ato_item under pto model.

                 IF l_temp_record.ato_line_id is NOT NULL and
                    l_temp_record.ato_line_id <>  l_temp_record.line_id and
                    l_temp_record.item_type_code = 'OPTION'
                 THEN

                   SELECT /*+ INDEX(OE_ORDER_LINES_N1) */
                          count(*)
                   INTO   l_count
                   FROM   oe_order_lines_all
                   WHERE  ato_line_id = l_temp_record.ato_line_id
                   AND    top_model_line_id = l_temp_record.top_model_line_id
                   AND    header_id = G_HEADER_ID;

                   IF l_count = 1 THEN
       	             l_update_table(l_get_index).ato_line_id := l_temp_record.line_id;
                   END IF;
                 END IF;

		 l_update_table(l_get_index).shippable_flag := l_temp_record.shippable_flag;
		 l_update_table(l_get_index).temp_update_flag :=  'N';


                IF l_temp_record.item_type_code = 'INCLUDED' THEN
                   l_update_table(l_get_index).unit_selling_price := 0;
                   l_update_table(l_get_index).unit_list_price := 0;
                   l_update_table(l_get_index).temp_update_flag := 'Y';
                ELSIF l_temp_record.item_type_code = 'CONFIG' THEN
                   l_update_table(l_get_index).unit_selling_price := 0;
                   l_update_table(l_get_index).unit_list_price := 0;
                   l_update_table(l_get_index).temp_update_flag := 'Y';
                ELSE
                 l_update_table(l_get_index).unit_selling_price := l_temp_record.unit_selling_price;
                 l_update_table(l_get_index).unit_list_price := l_temp_record.unit_list_price;
                END IF;


		 IF l_temp_record.line_id = l_temp_record.top_model_line_id THEN
              l_top_model_index := l_top_model_index + 1;
		    l_top_model_tbl(l_top_model_index) := l_temp_record.line_id;
		 END IF;

         /* From ont00106.sql */

         l_update_table(l_get_index).ship_set_id := l_temp_record.ship_set_id;

         /* End ont00106.sql */
	 END LOOP;

      /* If there are no lines */
	 IF l_get_table.count <= 0 then

         GOTO NO_LINES;

	 END IF;

      /* From ontupg17 */

      l_temp_index := l_get_table.FIRST;
      WHILE l_temp_index IS NOT NULL
	 LOOP

	      /* First retrieve all the serviceable lines */

           IF  l_get_table(l_temp_index).item_type_code = 'SERVICE' THEN

               GOTO NEXT_SERVICE_LINE;
	      END IF;

           BEGIN

                -- Get the equivalent records from so_lines_all
			 l_serviceable_line_id := l_get_table(l_temp_index).line_id;

                OPEN service_product_lines (l_serviceable_line_id);

	           LOOP

     	          FETCH service_product_lines
     	          into l_line_id, l_service_parent_line_id;
                    EXIT WHEN service_product_lines%NOTFOUND;

                     /*Have 2 open cursors for retrieving log records  */

	               OPEN log_product_lines (l_service_parent_line_id);
	               OPEN log_service_lines (l_line_id);

		          LOOP

		            FETCH log_product_lines
		            into l_old_line_id1, l_new_line_id1;
		            EXIT WHEN log_product_lines%NOTFOUND;

		            FETCH log_service_lines
		            into l_old_line_id2, l_new_line_id2;
		            EXIT WHEN log_service_lines%NOTFOUND;

                      -- Now update the service line
		            -- in oe_order_lines_all table

		            l_update_table(l_new_line_id2).service_reference_line_id := l_new_line_id1;
			       l_update_table(l_new_line_id2).temp_update_flag := 'Y';

                    END LOOP;

	           CLOSE log_service_lines;

                CLOSE log_product_lines;

	           END LOOP;  /* Loop for service product lines */

	           CLOSE service_product_lines;

           EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                     OE_UPG_SO_NEW.Upgrade_Insert_Errors(
                       G_HEADER_ID,
                       'FYI Only: Service Ref.Line id not updated in OM for Line '
                           ||to_char(l_new_line_id2));

           END;

	      <<NEXT_SERVICE_LINE>>

	      l_temp_index := l_get_table.NEXT(l_temp_index);

	 END LOOP; /* ontupg17 */

      /* No model Lines */
	 IF  l_top_model_tbl.count <= 0 THEN

          GOTO END_MODELS;

	 END IF;

      /* from ontupg53 */

      l_ii_table := l_get_table;

	 FOR  I IN l_top_model_tbl.FIRST .. l_top_model_tbl.LAST
	 LOOP
          l_shipped_line     := FALSE;
          l_not_shipped_line := FALSE;
		l_main_component := 0;
		l_option_number := 0;
        l_not_in_the_set     := FALSE;
        l_in_the_set := FALSE;
        l_invalid_set := FALSE;
        l_ship_set_id := Null;
        l_set_index   := Null;

      l_temp_index := l_get_table.FIRST;
      WHILE l_temp_index IS NOT NULL
	 LOOP

		IF nvl(l_get_table(l_temp_index).top_model_line_id,0) <> l_top_model_tbl(I) THEN

             GOTO NEXT_LINE;
		END IF;

        IF l_set_index is null THEN

           l_set_index := l_temp_index;

        END IF;

        /** From ont00106.sql **/

         IF l_get_table(l_temp_index).ship_set_id is not null THEN

            l_in_the_set := TRUE;
            l_ship_set_id := l_get_table(l_temp_index).ship_set_id;

            IF l_get_table(l_temp_index).ship_from_org_id is null
            OR l_get_table(l_temp_index).ship_to_org_id is null
            OR l_get_table(l_temp_index).schedule_ship_date is null
            OR l_get_table(l_temp_index).schedule_status_code is null
            THEN
                 l_invalid_set := TRUE;
            END IF;


         ELSE

            IF  l_invalid_set = FALSE
            AND l_get_table(l_temp_index).ship_from_org_id is not null
            AND l_get_table(l_temp_index).ship_to_org_id is not null
            AND l_get_table(l_temp_index).schedule_ship_date is not null
            AND l_get_table(l_temp_index).schedule_status_code is not null
            AND l_get_table(l_temp_index).ship_from_org_id = l_get_table(l_set_index).ship_from_org_id
            AND l_get_table(l_temp_index).ship_to_org_id = l_get_table(l_set_index).ship_to_org_id
            AND l_get_table(l_temp_index).schedule_ship_date  = l_get_table(l_set_index).schedule_ship_date
            THEN

                Null;
            ELSE
              l_invalid_set := TRUE;
            END IF;


            l_not_in_the_set := TRUE;

         END IF; -- Main If

        /** End ont00106.sql **/

         IF nvl(l_get_table(l_temp_index).shippable_flag,'N') = 'Y' THEN
            IF l_get_table(l_temp_index).shipped_quantity is null OR
               l_get_table(l_temp_index).shipped_quantity = 0 THEN
                   l_not_shipped_line := TRUE;
            ELSIF l_get_table(l_temp_index).shipped_quantity > 0 THEN
                   l_shipped_line := TRUE;
            END IF;
         ELSE

            -- Change for #3145399
                 IF l_get_table(l_temp_index).ato_line_id is not NULL THEN
                    BEGIN
                       SELECT /*+ INDEX(OE_ORDER_LINES_N1) */ ACTUAL_SHIPMENT_DATE
                       INTO   l_update_table(l_temp_index).actual_shipment_date
                       FROM   OE_ORDER_LINES_ALL
                       WHERE  TOP_MODEL_LINE_ID = l_get_table(l_temp_index).top_model_line_id
                       AND    ATO_LINE_ID = l_get_table(l_temp_index).ato_line_id
                       AND    ITEM_TYPE_CODE='CONFIG'
                       AND    header_id=G_HEADER_ID;
                    EXCEPTION WHEN OTHERS THEN
                       NULL;
                    END;
                 END IF;
          END IF;

		IF l_get_table(l_temp_index).link_to_line_id = l_top_model_tbl(I) AND
		   l_get_table(l_temp_index).item_type_code = 'INCLUDED' THEN

             l_main_component := l_main_component + 1;
		   l_update_table(l_temp_index).line_number := l_get_table(l_top_model_tbl(I)).line_number;
		   l_update_table(l_temp_index).shipment_number := l_get_table(l_top_model_tbl(I)).shipment_number;
		   l_update_table(l_temp_index).component_number := l_main_component;
		   l_update_table(l_temp_index).option_number := NULL;
             l_update_table(l_temp_index).temp_update_flag := 'Y';

          END IF;

		IF l_get_table(l_temp_index).top_model_line_id = l_top_model_tbl(I) AND
		   l_get_table(l_temp_index).item_type_code <> 'INCLUDED' AND
		   l_get_table(l_temp_index).line_id <> l_top_model_tbl(I) THEN

             IF l_get_table(l_temp_index).item_type_code = 'CONFIG' THEN

		      l_update_table(l_temp_index).line_number := l_get_table(l_top_model_tbl(I)).line_number;
		      l_update_table(l_temp_index).shipment_number := l_get_table(l_top_model_tbl(I)).shipment_number;
		      l_update_table(l_temp_index).component_number := NULL;
		      l_update_table(l_temp_index).option_number := NULL;
                l_update_table(l_temp_index).temp_update_flag := 'Y';

		   ELSE
		      l_update_table(l_temp_index).line_number := l_get_table(l_top_model_tbl(I)).line_number;
		      l_update_table(l_temp_index).shipment_number := l_get_table(l_top_model_tbl(I)).shipment_number;
		      l_update_table(l_temp_index).component_number := l_get_table(l_temp_index).component_number;
		      l_update_table(l_temp_index).option_number := l_get_table(l_temp_index).option_number;
              l_update_table(l_temp_index).temp_update_flag := 'Y';

		   END IF;

             IF (l_get_table(l_temp_index).item_type_code = 'KIT' OR
			  l_get_table(l_temp_index).item_type_code = 'CLASS') AND
			  (l_get_table(l_temp_index).ato_line_id is null) THEN

                  l_ii_component := 0;
                  l_ii_index := l_ii_table.FIRST;

        		   WHILE l_ii_index IS NOT NULL
    	        	   LOOP
		            IF nvl(l_ii_table(l_ii_index).top_model_line_id,0) <> l_top_model_tbl(I) THEN

                         GOTO NEXT_LINE_1;
		            END IF;

		           IF l_ii_table(l_ii_index).link_to_line_id = l_get_table(l_temp_index).line_id AND
		              l_ii_table(l_ii_index).item_type_code = 'INCLUDED' THEN

                        l_ii_component := l_ii_component + 1;

		              l_update_table(l_ii_index).line_number := l_get_table(l_top_model_tbl(I)).line_number;
		              l_update_table(l_ii_index).shipment_number := l_get_table(l_top_model_tbl(I)).shipment_number;
		              l_update_table(l_ii_index).component_number := l_ii_component;
		              l_update_table(l_ii_index).option_number := l_get_table(l_top_model_tbl(I)).option_number;
                        l_update_table(l_ii_index).temp_update_flag := 'Y';

                     END IF;

                  << NEXT_LINE_1>>

			   l_ii_index := l_ii_table.NEXT(l_ii_index);
		        END LOOP;

             END IF;

          END IF;

        <<NEXT_LINE>>

	   l_temp_index := l_get_table.NEXT(l_temp_index);

	 END LOOP;

      IF (l_shipped_line = TRUE AND l_not_shipped_line = TRUE) THEN

          l_update_index := l_update_table.FIRST;

		WHILE l_update_index IS NOT NULL
		LOOP
		   IF nvl(l_update_table(l_update_index).top_model_line_id,0) <> l_top_model_tbl(I) THEN
                GOTO NEXT_LINE_2;
             END IF;

		   l_update_table(l_update_index).model_remnant_flag := 'Y';
		   l_update_table(l_update_index).temp_update_flag := 'Y';

          <<NEXT_LINE_2>>
		l_update_index := l_update_table.NEXT(l_update_index);

		END LOOP;

	 END IF;

	 IF (l_shipped_line = TRUE AND l_not_shipped_line = FALSE) THEN

		l_update_index := l_update_table.FIRST;

		WHILE l_update_index IS NOT NULL
		LOOP
		   IF nvl(l_update_table(l_update_index).top_model_line_id,0) <> l_top_model_tbl(I) THEN
			 GOTO NEXT_LINE_3;
             END IF;

		   IF l_update_table(l_update_index).ato_line_id IS NULL AND
			 l_update_table(l_update_index).shippable_flag = 'N' THEN

			 l_update_table(l_update_index).shipped_quantity := l_update_table(l_update_index).ordered_quantity;
			 l_update_table(l_update_index).fulfilled_quantity := l_update_table(l_update_index).ordered_quantity;
			 l_update_table(l_update_index).fulfilled_flag := 'Y';
			 l_update_table(l_update_index).fulfillment_date := l_update_table(l_update_index).actual_shipment_date;
		      l_update_table(l_update_index).temp_update_flag := 'Y';

		   END IF;

             <<NEXT_LINE_3>>
		   l_update_index := l_update_table.NEXT(l_update_index);
		END LOOP; /* Shipped Quantity */

	 END IF;

     /** From 0nt00106.sql **/

      IF (l_in_the_set = TRUE AND l_not_in_the_set = TRUE)
      AND l_invalid_set = FALSE
      AND l_ship_set_id is not null THEN

          l_update_index := l_update_table.FIRST;

		WHILE l_update_index IS NOT NULL
		LOOP
		   IF nvl(l_update_table(l_update_index).top_model_line_id,0) <> l_top_model_tbl(I) THEN
                GOTO NEXT_LINE_4;
           END IF;

		   l_update_table(l_update_index).ship_set_id  := l_ship_set_id;
           l_update_table(l_update_index).temp_update_flag := 'Y';

          <<NEXT_LINE_4>>

           l_update_index := l_update_table.NEXT(l_update_index);

		END LOOP;

      ELSIF (l_in_the_set = TRUE AND l_not_in_the_set = TRUE)
      OR  l_invalid_set = TRUE THEN

          l_update_index := l_update_table.FIRST;

		WHILE l_update_index IS NOT NULL
		LOOP
		   IF nvl(l_update_table(l_update_index).top_model_line_id,0) <> l_top_model_tbl(I) THEN
                GOTO NEXT_LINE_5;
           END IF;

		   l_update_table(l_update_index).ship_set_id  := Null;
           l_update_table(l_update_index).temp_update_flag := 'Y';

          <<NEXT_LINE_5>>

           l_update_index := l_update_table.NEXT(l_update_index);

		END LOOP;

	 END IF;
     /** End 0nt00106.sql **/

	 END LOOP; /* For Models ontupg53 */

	 <<END_MODELS>>
	 NULL;

      /* From ontupg14 */
      l_update_index := l_update_table.FIRST;

	 WHILE l_update_index IS NOT NULL
	 LOOP

	    BEGIN

         IF l_update_table(l_update_index).item_type_code = 'SERVICE' AND
		  l_update_table(l_update_index).service_reference_line_id IS NOT NULL THEN

            l_service_reference_line_id := l_update_table(l_update_index).service_reference_line_id;
            l_update_table(l_update_index).line_number := l_update_table(l_service_reference_line_id).line_number;
            l_update_table(l_update_index).shipment_number := l_update_table(l_service_reference_line_id).shipment_number;
            l_update_table(l_update_index).option_number := l_update_table(l_service_reference_line_id).option_number;
            l_update_table(l_update_index).temp_update_flag := 'Y';

         END IF;

	    EXCEPTION

		   WHEN NO_DATA_FOUND THEN

                  OE_UPG_SO_NEW.Upgrade_Insert_Errors(
                  G_HEADER_ID,
                  'FYI Only: Service Ref information not updated since parent line does not exist'
                  ||to_char(l_update_index));

	    END;

	    l_update_index := l_update_table.NEXT(l_update_index);
	 END LOOP; /* ontupg14 */


	 /* Update the lines  */

	 l_update_index := l_update_table.FIRST;

	 WHILE l_update_index IS NOT NULL
	 LOOP

          IF l_update_table(l_update_index).temp_update_flag = 'Y' THEN

             UPDATE /*+ INDEX(OE_ORDER_LINES_U1) */ OE_ORDER_LINES_ALL
		   SET    SHIPPED_QUANTITY = l_update_table(l_update_index).shipped_quantity,
				FULFILLED_FLAG = l_update_table(l_update_index).fulfilled_flag,
				FULFILLED_QUANTITY = l_update_table(l_update_index).fulfilled_quantity,
				ACTUAL_SHIPMENT_DATE = l_update_table(l_update_index).actual_shipment_date,
				FULFILLMENT_DATE = l_update_table(l_update_index).fulfillment_date,
				LINE_NUMBER = l_update_table(l_update_index).line_number,
				OPTION_NUMBER = l_update_table(l_update_index).option_number,
				SHIPMENT_NUMBER = l_update_table(l_update_index).shipment_number,
				COMPONENT_NUMBER = l_update_table(l_update_index).component_number,
				MODEL_REMNANT_FLAG = l_update_table(l_update_index).model_remnant_flag,
				SERVICE_REFERENCE_LINE_ID = l_update_table(l_update_index).service_reference_line_id,
				SHIPPABLE_FLAG = l_update_table(l_update_index).shippable_flag,
                UNIT_SELLING_PRICE = l_update_table(l_update_index).unit_selling_price,
                UNIT_LIST_PRICE = l_update_table(l_update_index).unit_list_price,
                ATO_LINE_ID = l_update_table(l_update_index).ato_line_id,
                SHIP_SET_ID = l_update_table(l_update_index).ship_set_id
             WHERE  LINE_ID = l_update_index;
		END IF;

		l_update_index := l_update_table.NEXT(l_update_index);

	 END LOOP;

	 <<NO_LINES>>
	 NULL;

   exception
      when others then
             OE_UPG_SO_NEW.upgrade_insert_errors
             ( L_header_id => g_header_id,
               L_comments  => 'Update_After_Insert failed on ora error: '||to_char(sqlcode)
             );
             raise;

   END Update_After_Insert;

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

          /*Hints are changed to fix the bug 1826762 for the bug1974897*/
          select /*+ ORDERED USE_NL(sla1,sla2,upg,oeol)
                      INDEX (sla1 SO_LINES_N1)
                      INDEX (sla2 SO_LINES_N18)
                      INDEX (upg OE_UPGRADE_LOG_N1)
                      INDEX (oeol OE_ORDER_LINES_U1)
                  */
               sla1.header_id,
               sla1.line_id,
               sla1.line_number,
			sla1.inventory_item_id,
			sla1.unit_code
          from
               so_lines_all sla1, so_lines_all sla2, oe_upgrade_log upg,
			oe_order_lines_all oeol
          where sla1.header_id = G_HEADER_ID
		and   sla1.line_type_code = 'PARENT'
          and   sla1.item_type_code in ('KIT','MODEL','STANDARD')
		and   sla1.parent_line_id is null -- To filter out option lines
		and   sla1.parent_line_id is null -- To filter out option lines
          and  sla1.line_id = sla2.shipment_schedule_line_id
		and  sla2.line_id = upg.old_line_id
		and  upg.new_line_id = oeol.line_id
          order by sla1.line_id;

/* Performance changes bug 1961136 */
          cursor c3 is

        SELECT /*+ ORDERED  USE_NL(OOLA SLA UPG) INDEX(oola OE_ORDER_LINES_N1)
          INDEX(upg OE_UPGRADE_LOG_N6) index(sla SO_LINES_U1) */
      OOLA.LINE_ID,OOLA.LINE_NUMBER
        FROM OE_ORDER_LINES_ALL OOLA,
            OE_UPGRADE_LOG UPG  ,
                SO_LINES_ALL  SLA
        WHERE OOLA.HEADER_ID = G_HEADER_ID  AND
        OOLA.LINE_ID = UPG.NEW_LINE_ID  AND
              UPG.OLD_LINE_ID =  SLA.LINE_ID  AND
              SLA.SHIPMENT_SCHEDULE_LINE_ID = v_line_id
        ORDER BY OOLA.LINE_ID;


          cursor c5 is
          select
                header_id,
                line_id,
                line_number,
			 inventory_item_id,
			 unit_code
          from
                so_lines_all sla
          where sla.header_id = G_HEADER_ID
		AND  sla.line_type_code = 'REGULAR'
          AND  item_type_code in ('KIT','MODEL','STANDARD')
          and  parent_line_id is null  -- To filter out options  (included on Leena's instn.)
          and  parent_line_id is null  -- To filter out options  (included on Leena's instn.)
--          and sla.line_id in
          and exists
            (select /*+ INDEX(ln OE_ORDER_LINES_N1) */lg.old_line_id
             from oe_upgrade_log_v lg, oe_order_lines_all ln
             where  ln.header_id = sla.header_id
		   and    lg.old_line_id = sla.line_id
		   and    lg.new_line_id = ln.line_id
             and    ln.item_type_code not in  ('INCLUDED','CONFIG')
             group by lg.old_line_id
             having count(*) > 1);

	    cursor c7  is
         select /*+ INDEX(oe_upgrade_log OE_UPGRADE_LOG_N1) */ --bug5909908
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
/*
               if v_commit_ctr > 500 then
                    commit;
                    v_commit_ctr := 0;
               end if;
*/
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
/*
               if v_commit_ctr > 500 then
                    commit;
                    v_commit_ctr := 0;
               end if;
*/
          end loop;
exception
      when others then
             OE_UPG_SO_NEW.upgrade_insert_errors
             ( L_header_id => g_header_id,
               L_comments  => 'Line set updation failed on ora error: '||to_char(sqlcode)
             );
             raise;
   End Upgrade_Create_Line_Sets;

-- 1. Select all the models which have multiple config details.
-- 2. Select all the options for the model.
-- 3. Create new lines for the options of the model and for the model itself.
-- 4. Attach the config item to the model line.
-- 5. update the option quantity for the original option lines.

PROCEDURE Insert_Row
(   p_line_rec                      IN  OE_Order_PUB.Line_Rec_Type,
    p_orig_line_id                  IN  Number,
    p_upgraded_flag                 IN  Varchar2 default 'Y',
    p_apply_price_adj               IN  Varchar2 default 'Y'
);

FUNCTION Query_Row
(   p_line_id                       IN  NUMBER) RETURN OE_Order_PUB.Line_Rec_Type;

PROCEDURE insert_multiple_models IS

   cursor multiple_cfg_detail(p_ato_line_id IN NUMBER) IS
      select /*+ INDEX(OE_ORDER_LINES_ALL OE_ORDER_LINES_N1) */ line_id,ordered_quantity,shipped_quantity
      from oe_order_lines_all
      where  header_id = G_HEADER_ID
	 and ato_line_id=p_ato_line_id
      and item_type_code = 'CONFIG';

   cursor multiple_cfg_parent IS
      select /*+ INDEX(OE_ORDER_LINES_ALL OE_ORDER_LINES_N1) */
	 ato_line_id
      from oe_order_lines_all
	 where header_id = G_HEADER_ID
      group by ato_line_id,item_type_code
      having item_type_code = 'CONFIG'
      and count(*) > 1;

   cursor model_and_options(p_ato_line_id IN NUMBER) IS
      select /*+ INDEX(OE_ORDER_LINES_ALL OE_ORDER_LINES_N1) */
	 line_id
      from oe_order_lines_all
      where header_id = G_HEADER_ID
	 and ato_line_id=p_ato_line_id
      and item_type_code <> 'CONFIG'
      order by component_code;

   cursor service_lines(p_service_reference_line_id IN NUMBER) IS
      select /*+ INDEX(OE_ORDER_LINES_ALL OE_ORDER_LINES_N1) */
	 line_id
      from oe_order_lines_all
      where  header_id = G_HEADER_ID
	 and service_reference_line_id = p_service_reference_line_id;

   l_cfg_line_id          NUMBER;
   l_cfg_ordered_quantity NUMBER;
   l_cfg_shipped_quantity NUMBER;
   p_ato_line_id          NUMBER;
   l_line_id              NUMBER;
   l_service_count        NUMBER;
   l_service_line_id      NUMBER;

   l_model_rec            OE_ORDER_PUB.line_rec_type;
   l_line_rec             OE_ORDER_PUB.line_rec_type;
   l_service_line_rec     OE_ORDER_PUB.line_rec_type;
   l_new_line_rec         OE_ORDER_PUB.line_rec_type;
   v_error_code           NUMBER;
   l_orig_model_quantity  NUMBER := 0;
   --
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
   --
BEGIN

  -- Get the model line which has multiple config lines.
  OPEN multiple_cfg_parent;

  LOOP

     FETCH multiple_cfg_parent INTO p_ato_line_id;
     EXIT WHEN multiple_cfg_parent%notfound;

     -- Get the original model quantity. This is needed to calculate
     -- any new option quantities.

     BEGIN
       SELECT ordered_quantity
       INTO l_orig_model_quantity
       FROM oe_order_lines_all
       WHERE line_id=p_ato_line_id;
     EXCEPTION
       WHEN OTHERS THEN
          l_orig_model_quantity := 0;
     END;

     IF l_orig_model_quantity is null THEN
        l_orig_model_quantity := 0;
     END IF;

     -- Get the multiple config lines.
     OPEN multiple_cfg_detail(p_ato_line_id);
     FETCH multiple_cfg_detail
     INTO l_cfg_line_id,l_cfg_ordered_quantity,l_cfg_shipped_quantity;

     -- This is the first config detail. If the quantity of the config is
     -- not the same as that model, then we should update the whole
     -- configuration.

     IF l_cfg_ordered_quantity <> l_orig_model_quantity THEN
     BEGIN

       IF l_orig_model_quantity > 0 THEN

          UPDATE OE_ORDER_LINES_ALL

          SET ordered_quantity = ordered_quantity/l_orig_model_quantity *
                                 l_cfg_ordered_quantity,
              shipped_quantity = ordered_quantity/l_orig_model_quantity *
						   l_cfg_shipped_quantity,
              fulfilled_quantity = ordered_quantity/l_orig_model_quantity *
						   l_cfg_shipped_quantity,
              fulfilled_flag = decode((ordered_quantity/l_orig_model_quantity *
				             l_cfg_shipped_quantity),null,'N','Y'),
              fulfillment_date = decode((ordered_quantity/l_orig_model_quantity *
				             l_cfg_shipped_quantity),null,NULL,actual_shipment_date)

          WHERE header_id=G_HEADER_ID
          AND ato_line_id=p_ato_line_id
          AND item_type_code <> 'CONFIG';

          UPDATE OE_ORDER_LINES_ALL OOL
		SET OOL.ORDERED_QUANTITY = (SELECT ORDERED_QUANTITY
							   FROM OE_ORDER_LINES_ALL OOL1
							   WHERE OOL1.LINE_ID = OOL.SERVICE_REFERENCE_LINE_ID)
          WHERE OOL.HEADER_ID = G_HEADER_ID
		AND   OOL.ITEM_TYPE_CODE = 'SERVICE';

          -- Select the model quantity again

          BEGIN
            SELECT ordered_quantity
            INTO l_orig_model_quantity
            FROM oe_order_lines_all
            WHERE line_id=p_ato_line_id;
          EXCEPTION
            WHEN OTHERS THEN
               l_orig_model_quantity := 0;
          END;
       END IF;


     EXCEPTION
       WHEN OTHERS THEN
            null;
     END;
     END IF;

     IF l_orig_model_quantity is null THEN
        l_orig_model_quantity := 0;
     END IF;

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
           INTO l_line_id;
           EXIT WHEN model_and_options%notfound;


           l_line_rec                          := Query_Row(l_line_id);
           Query_And_Set_Price_Attribs(l_line_rec.line_id,l_line_rec.header_id);
           IF l_line_rec.line_id = l_line_rec.ato_line_id AND
              l_line_rec.item_type_code in ('MODEL','CLASS') THEN

              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'CREATING A NEW MODEL LINE' ) ;
              END IF;

              l_new_line_rec                   := l_line_rec;

              SELECT oe_order_lines_s.nextval
              INTO l_new_line_rec.line_id
              FROM dual;

              l_new_line_rec.ato_line_id       := l_new_line_rec.line_id;

              IF l_line_rec.line_id = l_line_rec.top_model_line_id
              THEN
                 l_new_line_rec.top_model_line_id := l_new_line_rec.line_id;
              ELSE
                 l_new_line_rec.top_model_line_id := l_line_rec.top_model_line_id;
              END IF;

              IF l_line_rec.link_to_line_id is null THEN
                 l_new_line_rec.link_to_line_id   := null;
              ELSE
                 l_new_line_rec.link_to_line_id   := l_line_rec.link_to_line_id;
              END IF;

              l_new_line_rec.ordered_quantity  := l_cfg_ordered_quantity;
              l_new_line_rec.shipped_quantity  := l_cfg_shipped_quantity;
              l_new_line_rec.fulfilled_quantity  := l_cfg_shipped_quantity;

		    IF nvl(l_cfg_shipped_quantity,0) <> 0 THEN

                 l_new_line_rec.fulfilled_flag := 'Y';
			  l_new_line_rec.fulfillment_date := l_line_rec.actual_shipment_date;
		    ELSE
                 l_new_line_rec.fulfilled_flag := 'N';
			  l_new_line_rec.fulfillment_date := NULL;

		    END IF;

              l_model_rec := l_new_line_rec;

                                IF l_debug_level  > 0 THEN
                                    oe_debug_pub.add(  'INSERTING A MODEL LINE :' || L_NEW_LINE_REC.LINE_ID ) ;
                                END IF;

              INSERT_ROW(l_new_line_rec, l_line_id);

		    -- Update the config item to point to the new model.

              UPDATE oe_order_lines_all
              SET ato_line_id = l_model_rec.line_id,
                  top_model_line_id = l_model_rec.top_model_line_id,
                  link_to_line_id = l_model_rec.line_id
              WHERE line_id=l_cfg_line_id;
/*
              UPDATE oe_order_lines_all
              SET link_to_line_id = l_model_rec.line_id
              WHERE line_id=l_cfg_line_id;
*/
              OPEN service_lines(l_line_id);

              LOOP
                  FETCH SERVICE_LINES INTO
                  l_service_line_id;
                  EXIT WHEN SERVICE_LINES%NOTFOUND;

                  l_service_line_rec    := Query_Row(l_service_line_id);
                  Query_And_Set_Price_Attribs(l_service_line_rec.line_id,l_service_line_rec.header_id);
                  SELECT oe_order_lines_s.nextval
                  INTO l_service_line_rec.line_id
                  FROM dual;

                  l_service_line_rec.service_reference_line_id
                                                  := l_new_line_rec.line_id;
                  l_service_line_rec.ordered_quantity
                                                  := l_new_line_rec.ordered_quantity;
			   INSERT_ROW(l_service_line_rec,l_service_line_id);

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
              l_new_line_rec.top_model_line_id := l_model_rec.top_model_line_id;
              l_new_line_rec.link_to_line_id   := null;
              IF l_orig_model_quantity > 0 THEN
                 l_new_line_rec.ordered_quantity  :=
                     (l_new_line_rec.ordered_quantity /
                      l_orig_model_quantity) *
                      l_cfg_ordered_quantity;

                 l_new_line_rec.shipped_quantity  :=
                     (l_new_line_rec.ordered_quantity /
                      l_orig_model_quantity) *
                      l_cfg_shipped_quantity;

		       IF nvl(l_cfg_shipped_quantity,0) <> 0 THEN

                    l_new_line_rec.fulfilled_flag := 'Y';
			     l_new_line_rec.fulfillment_date := l_line_rec.actual_shipment_date;
				l_new_line_rec.fulfilled_quantity :=
                                (l_new_line_rec.ordered_quantity /
                                l_orig_model_quantity) *
                                l_cfg_shipped_quantity;
		       ELSE
                    l_new_line_rec.fulfilled_flag := 'N';
			     l_new_line_rec.fulfillment_date := NULL;
				l_new_line_rec.fulfilled_quantity := NULL;

		       END IF;

              END IF;

              INSERT_ROW(l_new_line_rec,l_line_id);

              OPEN service_lines(l_line_id);

              LOOP
                  FETCH SERVICE_LINES INTO
                  l_service_line_id;
                  EXIT WHEN SERVICE_LINES%NOTFOUND;

                  l_service_line_rec    := Query_Row(l_service_line_id);
                  Query_And_Set_Price_Attribs(l_service_line_rec.line_id,l_service_line_rec.header_id);
                  SELECT oe_order_lines_s.nextval
                  INTO l_service_line_rec.line_id
                  FROM dual;

                  l_service_line_rec.service_reference_line_id
                                                  := l_new_line_rec.line_id;
                  l_service_line_rec.ordered_quantity
                                                  := l_new_line_rec.ordered_quantity;

			   INSERT_ROW(l_service_line_rec,l_service_line_id);

              END LOOP;
              CLOSE service_lines;
           END IF;

         END LOOP;

         CLOSE model_and_options;

         /* Update LINK_TO_LINE_ID for all the new classes and options
            created */

          UPDATE OE_ORDER_LINES_ALL OEOPT
          SET    LINK_TO_LINE_ID = (
                 SELECT OELNK.LINE_ID
                 FROM   OE_ORDER_LINES_ALL OELNK
                 WHERE( OELNK.LINE_ID = OEOPT.TOP_MODEL_LINE_ID
                 OR     OELNK.TOP_MODEL_LINE_ID = OEOPT.TOP_MODEL_LINE_ID )
                 AND    OELNK.COMPONENT_CODE =
                     SUBSTR( OEOPT.COMPONENT_CODE,
                          1, LENGTH( RTRIM( OEOPT.COMPONENT_CODE,
                                   '0123456789' ) ) - 1 )
                 AND OELNK.ATO_LINE_ID = l_model_rec.line_id)
          WHERE  HEADER_ID = l_model_rec.header_id
          AND ATO_LINE_ID = l_model_rec.line_id
          AND ITEM_TYPE_CODE <> 'SERVICE';

       END LOOP;

     END IF;

     CLOSE multiple_cfg_detail;

  END LOOP;
exception
      when others then
             v_error_code := sqlcode;
             OE_UPG_SO_NEW.upgrade_insert_errors
             ( L_header_id => g_header_id,
               L_comments  => 'Exception insert_multiple_models: '
                    ||'Error code -'
                    ||to_char(v_error_code)
             );
             raise;

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
    ,       UPGRADED_FLAG
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
	   l_line_rec.upgraded_flag          := l_implicit_rec.upgraded_flag;
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
    p_upgraded_flag                 IN  Varchar2 default 'Y',
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
    ,       LOCK_CONTROL
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
--    ,       p_upgraded_flag
    ,       p_line_rec.upgraded_flag
    ,       1
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
            reference_customer_trx_line_id,
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
		     customer_trx_line_id,
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
            reference_customer_trx_line_id,
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
		     customer_trx_line_id,
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
    OE_UPG_SO_NEW.Upgrade_Insert_Upgrade_Log;

    g_line_id   := p_line_rec.line_id;
    g_header_id := p_line_rec.header_id;


    IF p_apply_price_adj = 'Y' THEN
       /* ========== Line Level Pricing Attributes =========== Added by jefflee 6/21/00 */
       QP_Upg_OE_PVT.Upg_Pricing_Attribs(p_line_rec);

        g_line_rec.pricing_attribute11:=null;
        g_line_rec.pricing_attribute12:=null;
        g_line_rec.pricing_attribute13:=null;
        g_line_rec.pricing_attribute14:=null;
        g_line_rec.pricing_attribute15:=null;

       /* ========== Price Adjustments =========== */
      IF (    (p_line_rec.item_type_code <> 'INCLUDED' )
                       AND (p_line_rec.item_type_code <> 'CONFIG') ) THEN

         OE_UPG_SO_NEW.Upgrade_Price_Adjustments
         ( L_level_flag => 'L');

      END IF;

    END IF;


    /* ========== Sales Credits =========== */
    OE_UPG_SO_NEW.Upgrade_Sales_Credits
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
l_delivered_quantity  NUMBER;
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
  l_delivered_quantity := l_rec.delivered_quantity;

  IF l_received_quantity = 0 THEN
     l_received_quantity := NULL;
  END IF;

  IF l_delivered_quantity = 0 THEN
     l_delivered_quantity := NULL;
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
   l_line_rec1.fulfilled_quantity := l_delivered_quantity;
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
   l_line_rec1.fulfilled_quantity := l_delivered_quantity;
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

Procedure Process_Upgraded_Returns(p_header_id in NUMBER) is
l_commit_counter number := 0;
l_line_id number;
l_header_id number;
v_error_code number;
Cursor C1 is
     Select/*+ INDEX(l1 OE_ORDER_LINES_N1) INDEX(l2 OE_ORDER_LINES_U1) */ l1.line_id,l1.header_id
     from oe_order_lines_all l1, oe_order_lines_all l2
     where l1.reference_line_id = l2.line_id
     and l2.item_type_code in ('MODEL','CLASS','KIT')
     and l2.ato_line_id is null
     and l1.line_category_code = 'RETURN'
     and l1.reference_type is not null
	and nvl(l1.open_flag,'-') = 'Y'
     and l1.header_id = p_header_id;
     --
     l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
     --
begin

 For l_rec in C1 LOOP
 l_header_id := l_rec.header_id;
 l_line_id := l_rec.line_id;

 BEGIN
    Insert_Return_Included_Items(l_line_id,'Process_Returns');
 Exception
      when others then
             v_error_code := sqlcode;
             OE_UPG_SO_NEW.upgrade_insert_errors
             ( L_header_id => l_header_id,
               L_comments  => 'Exception in Process_Upgraded_Returns: '
                    ||'Error code -'
                    ||to_char(v_error_code)
                    ||' - Line id '||to_char(l_line_id)
             );
            raise;
 END;

 End LOOP;

end Process_Upgraded_Returns;

Procedure Mark_Order_As_Non_Updatable(p_header_id in number)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  Update so_headers_all
  set upgrade_flag = 'X'
  where header_id = p_header_id;

  -- Check to see if any referenced Returns Should also be marked

END Mark_Order_As_Non_Updatable;


Procedure Return_Fulfillment_Sets(p_header_id in NUMBER)
IS
l_commit_counter number := 0;
v_error_code number;
l_header_id number;
l_line_id number;
l_ref_line_id number;
l_ref_header_id number;
l_config_line_id number;
l_line_id1 number;
l_fulfillment_set_id number;
l_fulfillment_ref_line_id number;
Cursor C1 is
      Select /*+ INDEX(l1 OE_ORDER_LINES_N1) INDEX(l2 OE_ORDER_LINES_U1) */ l1.header_id
      from  oe_order_lines_all l1, oe_order_lines_all l2
      where l1.header_id = p_header_id
	 and l1.reference_line_id = l2.line_id
	 and nvl(l1.open_flag,'-') = 'Y'
      and l2.item_type_code in ('MODEL','CLASS','KIT')
      and l1.line_category_code = 'RETURN';

Cursor C2 is
      Select /*+ INDEX(l1 OE_ORDER_LINES_N1) INDEX(l2 OE_ORDER_LINES_U1) */
	 l1.line_id,l2.item_type_code,l2.line_id ref_line_id,l2.header_id ref_header_id
      from  oe_order_lines_all l1, oe_order_lines_all l2
      where l1.reference_line_id = l2.line_id
	 and l1.inventory_item_id = l2.inventory_item_id
	 and nvl(l1.open_flag,'-') = 'Y'
      and l2.item_type_code in ('MODEL','CLASS')
      and l2.ato_line_id = l2.line_id
	 and l1.header_id = l_header_id;
Cursor C3_1 is
      Select /*+ INDEX(OE_ORDER_LINES_N1) */ line_id
      from oe_order_lines_all
      where ato_line_id  = l_ref_line_id
	 and header_id = l_ref_header_id
      and item_type_code = 'CONFIG';
Cursor C3_2 is
      Select /*+ INDEX(OE_ORDER_LINES_N1) */ line_id
      from  oe_order_lines_all
      where item_type_code in ('CLASS','CONFIG','OPTION')
	 and header_id = l_ref_header_id
	 and ato_line_id = l_ref_line_id
	 and ato_line_id <> line_id;
Cursor C3_3 is
        Select /*+ INDEX(OE_ORDER_LINES_N1) */ line_id
        from oe_order_lines_all
        where reference_line_id = l_fulfillment_ref_line_id
        and header_id = l_header_id;
Cursor C4 is
      Select /*+ INDEX(l1 OE_ORDER_LINES_N1) INDEX(l2 OE_ORDER_LINES_U1) */
	 l1.line_id,l2.item_type_code,l2.line_id ref_line_id,l2.header_id ref_header_id
      from  oe_order_lines_all l1, oe_order_lines_all l2
      where l1.reference_line_id = l2.line_id
	 and l1.inventory_item_id = l2.inventory_item_id
      and l2.item_type_code in ('MODEL','CLASS','KIT')
      and l2.ato_line_id is null
	 and nvl(l1.open_flag,'-') = 'Y'
	 and l1.header_id = l_header_id;
Cursor C5 is
      Select /*+ INDEX(OE_ORDER_LINES_N1) */
	 line_id,inventory_item_id
      from  oe_order_lines_all
      where item_type_code in ('INCLUDED')
	 and header_id = l_ref_header_id
	 and link_to_line_id = l_ref_line_id;
Cursor C5_1 is
        Select /*+ INDEX(OE_ORDER_LINES_N1) */
	   line_id
        from oe_order_lines_all
        where reference_line_id = l_fulfillment_ref_line_id
        and header_id = l_header_id;
l_temp_rec C1%ROWTYPE;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

Open C1;
Fetch C1 into l_temp_rec;

IF C1%NOTFOUND THEN
	Close C1;
	Return;
end if;

Close C1;

begin

l_header_id := p_header_id;

  -- Loop for ATO
  FOR l_rec1 in C2 LOOP   -- Loop for ATO
     l_line_id := l_rec1.line_id;
     l_ref_line_id := l_rec1.ref_line_id;
     l_ref_header_id := l_rec1.ref_header_id;

	--
     -- Fix References for Config Items
	--
	Open  C3_1;
	Fetch C3_1 into l_config_line_id;
     Close C3_1;

	IF l_config_line_id is not null THEN
         Update /*+ INDEX(OE_ORDER_LINES_ALL OE_ORDER_LINES_N1) */
	    oe_order_lines_all
	    set reference_line_id = l_config_line_id,
  		ordered_item_id = inventory_item_id,
  		unit_list_price = null,
  		unit_selling_price = null
	    where reference_line_id = l_ref_line_id
	    and line_id <> l_line_id
	    and header_id = l_header_id;
/*
         delete from oe_price_adjustments
	    where line_id in (select line_id
	    from oe_order_lines_all
	    where reference_line_id = l_config_line_id);
*/
     END IF;


    --
    -- Add ATO model and its children into a Fulfillment Set
    --

     select oe_sets_s.nextval into l_fulfillment_set_id from dual;
     --insert into sets .....

	insert into oe_sets
          ( SET_ID, SET_NAME, SET_TYPE, HEADER_ID, SHIP_FROM_ORG_ID,
               SHIP_TO_ORG_ID,SCHEDULE_SHIP_DATE, SCHEDULE_ARRIVAL_DATE,
               FREIGHT_CARRIER_CODE, SHIPPING_METHOD_CODE,
               SHIPMENT_PRIORITY_CODE, SET_STATUS,
               CREATED_BY, CREATION_DATE, UPDATED_BY, UPDATE_DATE,
               UPDATE_LOGIN, INVENTORY_ITEM_ID,ORDERED_QUANTITY_UOM,
               LINE_TYPE_ID,SHIP_TOLERANCE_ABOVE, SHIP_TOLERANCE_BELOW)
    values
          ( l_fulfillment_set_id, to_char(l_fulfillment_set_id),
               'FULFILLMENT_SET',l_header_id,null,null, null,null,null,
               null,null,null, 0,sysdate,0, sysdate,
               0,null,null,null,null,null
          );


     -- Add line to set
	Insert into oe_line_sets( Line_id, Set_id, SYSTEM_REQUIRED_FLAG)
	Values (l_line_id, l_fulfillment_set_id, 'Y');


     FOR l_rec2 in C3_2 LOOP
	   l_fulfillment_ref_line_id := l_rec2.line_id;
        FOR l_rec21 in C3_3 LOOP
           -- Add line to set
	      Insert into oe_line_sets( Line_id, Set_id, SYSTEM_REQUIRED_FLAG)
	      Values (l_rec21.line_id, l_fulfillment_set_id, 'Y');
        END LOOP;
     END LOOP;

  END LOOP;  -- Loop for ATO



  FOR l_rec1 in C4 LOOP  -- Loop for PTO
     l_line_id := l_rec1.line_id;
     l_ref_line_id := l_rec1.ref_line_id;
     l_ref_header_id := l_rec1.ref_header_id;

	--
     -- Fix References for Included Items
	--

     FOR l_rec1_1 in C5 LOOP
     	Update /*+ INDEX(OE_ORDER_LINES_ALL OE_ORDER_LINES_N1) */
		oe_order_lines_all
	    	set reference_line_id = l_rec1_1.line_id
	    	where reference_line_id = l_ref_line_id
		and inventory_item_id = l_rec1_1.inventory_item_id
	    	and line_id <> l_line_id
	    	and header_id = l_header_id;
     END LOOP;


    --
    -- Add PTO model/class/kit and its included items into a Fulfillment Set
    --

     select oe_sets_s.nextval into l_fulfillment_set_id from dual;
     --insert into sets .....

	insert into oe_sets
          ( SET_ID, SET_NAME, SET_TYPE, HEADER_ID, SHIP_FROM_ORG_ID,
               SHIP_TO_ORG_ID,SCHEDULE_SHIP_DATE, SCHEDULE_ARRIVAL_DATE,
               FREIGHT_CARRIER_CODE, SHIPPING_METHOD_CODE,
               SHIPMENT_PRIORITY_CODE, SET_STATUS,
               CREATED_BY, CREATION_DATE, UPDATED_BY, UPDATE_DATE,
               UPDATE_LOGIN, INVENTORY_ITEM_ID,ORDERED_QUANTITY_UOM,
               LINE_TYPE_ID,SHIP_TOLERANCE_ABOVE, SHIP_TOLERANCE_BELOW)
    values
          ( l_fulfillment_set_id, to_char(l_fulfillment_set_id),
               'FULFILLMENT_SET',l_header_id,null,null, null,null,null,
               null,null,null, 0,sysdate,0, sysdate,
               0,null,null,null,null,null
          );


     -- Add line to set
	Insert into oe_line_sets( Line_id, Set_id, SYSTEM_REQUIRED_FLAG)
	Values (l_line_id, l_fulfillment_set_id, 'Y');

     FOR l_rec2 in C5 LOOP
	   l_fulfillment_ref_line_id := l_rec2.line_id;
        FOR l_rec21 in C5_1 LOOP
           -- Add line to set
	      Insert into oe_line_sets( Line_id, Set_id, SYSTEM_REQUIRED_FLAG)
	      Values (l_rec21.line_id, l_fulfillment_set_id, 'Y');
        END LOOP;
     END LOOP;

  END LOOP; -- Loop for PTO

exception
      when others then
             v_error_code := sqlcode;
             OE_UPG_SO_NEW.upgrade_insert_errors
             ( L_header_id => l_header_id,
               L_comments  => 'Exception return_fulfillment_sets: '
                    ||'Error code -'
                    ||to_char(v_error_code)
                    ||' - Line id '||to_char(l_line_id)
             );
             raise;
end;

END Return_Fulfillment_Sets;

Procedure Upgrade_Upd_Serv_Ref_line_id
IS
      cursor serviceable_lines is
      select line_id from oe_order_lines_all
      where item_type_code <> 'SERVICE';

      cursor service_product_lines (p_serviceable_line_id IN NUMBER) IS
	    select line_id , service_parent_line_id
	    from so_lines_all
	    where service_parent_line_id = p_serviceable_line_id;

      cursor log_product_lines (p_service_parent_line_id IN NUMBER) IS

	    select old_line_id, new_line_id from
	    oe_upgrade_log_v where
	    old_line_id = p_service_parent_line_id
	    and old_line_id <> new_line_id
	    order by new_line_id;

       cursor log_service_lines (p_line_id IN NUMBER) IS

	    select old_line_id, new_line_id from
	    oe_upgrade_log_v where
	    old_line_id = p_line_id
	    and old_line_id <> new_line_id
	    order by new_line_id;

      v_new_line_id number;
      l_serviceable_line_id        NUMBER;
	 l_line_id                    NUMBER;
	 l_service_parent_line_id     NUMBER;
	 l_old_line_id1               NUMBER;
	 l_old_line_id2               NUMBER;
	 l_new_line_id1               NUMBER;
	 l_new_line_id2               NUMBER;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
 begin

	OPEN serviceable_lines;

     LOOP

	  /* First retrieve all the serviceable lines */

       FETCH serviceable_lines into l_serviceable_line_id;
	  EXIT WHEN serviceable_lines%NOTFOUND;

      -- Get the equivalent records from so_lines_all
      OPEN service_product_lines (l_serviceable_line_id);

	 LOOP

     	 FETCH service_product_lines
     	 into l_line_id, l_service_parent_line_id;
           EXIT WHEN service_product_lines%NOTFOUND;

       /* Have 2 open cursors for retrieving log records */

	  OPEN log_product_lines (l_service_parent_line_id);
	  OPEN log_service_lines (l_line_id);

		 LOOP

		   FETCH log_product_lines
		   into l_old_line_id1, l_new_line_id1;
		   EXIT WHEN log_product_lines%NOTFOUND;

		   FETCH log_service_lines
		   into l_old_line_id2, l_new_line_id2;
		   EXIT WHEN log_service_lines%NOTFOUND;


             -- Now update the service line
		   -- in oe_order_lines_all table

		   update oe_order_lines_all
		   set service_reference_line_id = l_new_line_id1
		   where line_id = l_new_line_id2;

           END LOOP;

	   CLOSE log_service_lines;

        CLOSE log_product_lines;

	  END LOOP; /* Loop for service product lines */

	 CLOSE service_product_lines;

    END LOOP; /* Loop for serviceable lines */

   CLOSE serviceable_lines;

EXCEPTION
   WHEN OTHERS
   then NULL;

END Upgrade_Upd_Serv_Ref_line_id;

Procedure Query_And_Set_Price_Attribs(p_line_id IN NUMBER, p_header_id NUMBER) IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin
Select pricing_attribute11,pricing_attribute12,
       pricing_attribute13,pricing_attribute14,pricing_attribute15
INTO   g_line_rec.pricing_attribute11,
       g_line_rec.pricing_attribute12,
       g_line_rec.pricing_attribute13,
       g_line_rec.pricing_attribute14,
       g_line_rec.pricing_attribute15
From   oe_order_price_attribs
Where  line_id = p_line_id
and    header_id = p_header_id;

Exception When others then null;
End;

End OE_UPG_SO_NEW;

/
