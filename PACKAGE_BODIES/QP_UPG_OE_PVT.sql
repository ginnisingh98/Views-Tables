--------------------------------------------------------
--  DDL for Package Body QP_UPG_OE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_UPG_OE_PVT" as
/* $Header: QPXIUOEB.pls 120.4 2005/09/20 12:41:41 hwong noship $ */

PROCEDURE Upg_Price_Adj_OE_to_QP(  p_discount_id       IN NUMBER,
                                   p_discount_line_id  IN NUMBER,
                                   p_percent           IN NUMBER,
                                   p_unit_list_price   IN NUMBER,
                                   p_pricing_context   IN VARCHAR2,
                                   p_line_id           IN NUMBER,
                         	   x_output	      OUT NOCOPY /* file.sql.39 change */ PRICE_ADJ_REC_TYPE )
IS

     cursor oepadj is
     select     /* + Ordered index(dmap QP_DISCOUNT_MAPPING_T1) */
		dmap.new_list_header_id,
		dmap.new_list_line_id,
		dmap.new_type,
		dmap.old_price_break_lines_low,
		dmap.old_price_break_lines_high,
		dmap.old_method_type_code,
		lh.source_system_code,
		ll.modifier_level_code,
		ll.pricing_group_sequence,
		ll.list_line_type_code,
		ll.override_flag,
		ll.pricing_phase_id,
		ll.charge_type_code,
		ll.charge_subtype_code,
		ll.list_line_no,
		ll.benefit_qty,
		ll.benefit_uom_code,
		ll.print_on_invoice_flag,
		ll.expiration_date
	from
		qp_discount_mapping dmap, qp_list_lines ll, qp_list_headers_b lh
	where 	p_discount_id     = dmap.old_discount_id
	and 	(p_discount_line_id   = dmap.old_discount_line_id  or
		p_discount_line_id is null or p_discount_line_id = -1)
	and  dmap.new_list_header_id  = ll.list_header_id
	and  dmap.new_list_line_id  = ll.list_line_id
	and  dmap.new_list_header_id  = lh.list_header_id
	and  (p_pricing_context = dmap.pricing_context
	     or dmap.pricing_context is null);

     cursor price_breaks(p_line_id NUMBER, p_discount_id NUMBER) is
     select
		dmap.old_discount_id,
		dmap.new_list_header_id,
		dmap.new_list_line_id,
		dmap.old_price_break_lines_low,
          	dmap.old_price_break_lines_high,
		dmap.old_method_type_code,
		dmap.new_type,
		ll.list_line_type_code,
          	ll.override_flag,
		oeordl.ordered_quantity
     from
		qp_discount_mapping dmap, oe_order_lines_all oeordl, qp_list_lines ll
     where
            (	dmap.old_discount_id = p_discount_id  and
		oeordl.line_id = p_line_id and
		dmap.new_list_line_id = ll.list_line_id  and
		dmap.new_type = 'B'  and
		decode( dmap.old_method_type_code,
			'UNITS', oeordl.ordered_quantity,
			'DOLLARS', oeordl.ordered_quantity * oeordl.unit_list_price,
			0)
		between nvl( dmap.old_price_break_lines_low,
			     decode( dmap.old_method_type_code,
			     	     'UNITS', oeordl.ordered_quantity,
				     'DOLLARS', oeordl.ordered_quantity * oeordl.unit_list_price,
				     0)) and
		nvl( dmap.old_price_break_lines_high,
                             decode( dmap.old_method_type_code,
                                     'UNITS', oeordl.ordered_quantity,
                                     'DOLLARS', oeordl.ordered_quantity * oeordl.unit_list_price,
                                     0))
            );


     	v_modified_from	number;
     	v_updated_flag	varchar2(1);
     	v_applied_flag	varchar2(1);
     	v_operator	varchar2(30);
     	v_id1		number;
     	v_err_msg	varchar2(2000);
		qppadj          oepadj%ROWTYPE;
     	qpprice_breaks  price_breaks%ROWTYPE;


     BEGIN

	v_modified_from := 0;
	v_updated_flag  := 'N';
	v_applied_flag  := 'Y';

	OPEN oepadj;

	FETCH oepadj INTO qppadj;


	IF  qppadj.new_type = 'B' THEN
		open price_breaks( p_line_id, p_discount_id);
		fetch price_breaks into qpprice_breaks;

		qppadj.new_list_line_id := qpprice_breaks.new_list_line_id;
		qppadj.list_line_type_code := qpprice_breaks.list_line_type_code;
		qppadj.override_flag := qpprice_breaks.override_flag;

		close price_breaks;
	END IF;

	x_output.list_header_id 	:=	qppadj.new_list_header_id;
	x_output.list_line_id		:=	qppadj.new_list_line_id;
	x_output.list_line_type_code	:=	qppadj.list_line_type_code;
	x_output.modified_from		:=	v_modified_from;
	x_output.modified_to		:=	p_percent;
	x_output.update_allowed		:=	qppadj.override_flag;
	x_output.operand		:=	p_percent;
	x_output.updated_flag		:=	v_updated_flag;
	x_output.applied_flag		:=	v_applied_flag;
	x_output.arithmetic_operator	:=	'%';
	x_output.price_break_type_code	:=	'POINT';
	x_output.adjusted_amount	:=	p_percent * p_unit_list_price / 100;
	x_output.pricing_phase_id	:=	qppadj.pricing_phase_id;
	x_output.charge_type_code	:=	qppadj.charge_type_code;
	x_output.charge_subtype_code	:=	qppadj.charge_subtype_code;
	x_output.list_line_no		:=	qppadj.list_line_no;
	x_output.source_system_code	:=	qppadj.source_system_code;
	x_output.benefit_qty		:=	qppadj.benefit_qty;
	x_output.benefit_uom_code	:=	qppadj.benefit_uom_code;
	x_output.print_on_invoice_flag  :=	qppadj.print_on_invoice_flag;
	x_output.modifier_level_code  :=	qppadj.modifier_level_code;
	x_output.pricing_group_sequence  := qppadj.pricing_group_sequence;
	x_output.expiration_date	:=	qppadj.expiration_date;


	EXCEPTION
	 WHEN OTHERS THEN
	   	v_err_msg := SQLERRM;
	   	rollback;
	   	QP_Util.Log_Error(p_id1 => p_line_id,
				  p_error_type =>'PRICE_ADJUSTMENT',
		   		  p_error_desc => v_err_msg,
				  p_error_module => 'Upg_Price_Adj_OE_to_QP');
		raise;

end Upg_Price_Adj_OE_to_QP;


PROCEDURE Upg_Pricing_Attribs
IS

 v_order_price_attrib_id	NUMBER;
 v_err_msg			varchar2(2000);

 begin

	IF (OE_Upg_SO_NEW.g_line_rec.pricing_attribute1 IS NOT NULL)  OR
	   (OE_Upg_SO_NEW.g_line_rec.pricing_attribute2 IS NOT NULL)  OR
	   (OE_Upg_SO_NEW.g_line_rec.pricing_attribute3 IS NOT NULL)  OR
	   (OE_Upg_SO_NEW.g_line_rec.pricing_attribute4 IS NOT NULL)  OR
	   (OE_Upg_SO_NEW.g_line_rec.pricing_attribute5 IS NOT NULL)  OR
	   (OE_Upg_SO_NEW.g_line_rec.pricing_attribute6 IS NOT NULL)  OR
	   (OE_Upg_SO_NEW.g_line_rec.pricing_attribute7 IS NOT NULL)  OR
	   (OE_Upg_SO_NEW.g_line_rec.pricing_attribute8 IS NOT NULL)  OR
	   (OE_Upg_SO_NEW.g_line_rec.pricing_attribute9 IS NOT NULL)  OR
	   (OE_Upg_SO_NEW.g_line_rec.pricing_attribute10 IS NOT NULL) OR
	   (OE_Upg_SO_NEW.g_line_rec.pricing_attribute11 IS NOT NULL) OR
	   (OE_Upg_SO_NEW.g_line_rec.pricing_attribute12 IS NOT NULL) OR
	   (OE_Upg_SO_NEW.g_line_rec.pricing_attribute13 IS NOT NULL) OR
	   (OE_Upg_SO_NEW.g_line_rec.pricing_attribute14 IS NOT NULL) OR
	   (OE_Upg_SO_NEW.g_line_rec.pricing_attribute15 IS NOT NULL)

	THEN
		SELECT OE_ORDER_PRICE_ATTRIBS_S.nextval
		INTO v_order_price_attrib_id
		FROM dual;

		insert into oe_order_price_attribs
		(	header_id,
			line_id,
			creation_date,
			created_by,
			last_update_date,
			last_updated_by,
			last_update_login,
			program_application_id,
			program_id,
			program_update_date,
			request_id,
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
			pricing_attribute11,
			pricing_attribute12,
			pricing_attribute13,
			pricing_attribute14,
			pricing_attribute15,
			flex_title,
			order_price_attrib_id,
			override_flag	,
			lock_control)
		values
		(	OE_Upg_SO_NEW.g_line_rec.header_id,
			OE_Upg_SO_NEW.g_line_rec.line_id,
			SYSDATE,
			FND_GLOBAL.USER_ID,
			SYSDATE,
			FND_GLOBAL.USER_ID,
			FND_GLOBAL.LOGIN_ID,
			OE_Upg_SO_NEW.g_line_rec.program_application_id,
			OE_Upg_SO_NEW.g_line_rec.program_id,
			OE_Upg_SO_NEW.g_line_rec.program_update_date,
			OE_Upg_SO_NEW.g_line_rec.request_id,
			NVL(OE_Upg_SO_NEW.g_line_rec.pricing_context,'Upgrade Context'),
			OE_Upg_SO_NEW.g_line_rec.pricing_attribute1,
			OE_Upg_SO_NEW.g_line_rec.pricing_attribute2,
			OE_Upg_SO_NEW.g_line_rec.pricing_attribute3,
			OE_Upg_SO_NEW.g_line_rec.pricing_attribute4,
			OE_Upg_SO_NEW.g_line_rec.pricing_attribute5,
			OE_Upg_SO_NEW.g_line_rec.pricing_attribute6,
			OE_Upg_SO_NEW.g_line_rec.pricing_attribute7,
			OE_Upg_SO_NEW.g_line_rec.pricing_attribute8,
			OE_Upg_SO_NEW.g_line_rec.pricing_attribute9,
			OE_Upg_SO_NEW.g_line_rec.pricing_attribute10,
			OE_Upg_SO_NEW.g_line_rec.pricing_attribute11,
			OE_Upg_SO_NEW.g_line_rec.pricing_attribute12,
			OE_Upg_SO_NEW.g_line_rec.pricing_attribute13,
			OE_Upg_SO_NEW.g_line_rec.pricing_attribute14,
			OE_Upg_SO_NEW.g_line_rec.pricing_attribute15,
			'QP_ATTR_DEFNS_PRICING',
			v_order_price_attrib_id,
			'N',
			1);
	END IF;

		EXCEPTION
	 		WHEN OTHERS THEN
	   			v_err_msg := SQLERRM;
	   			rollback;
	   			QP_Util.Log_Error(p_id1 => v_order_price_attrib_id,
				  		  p_error_type =>'PRICE_ATTRIBUTES',
		   		  		  p_error_desc => v_err_msg,
				  		  p_error_module => 'Upg_Pricing_Attribs');
				raise;


 end Upg_Pricing_Attribs;

PROCEDURE Upg_Pricing_Attribs(p_line_rec IN OE_Order_PUB.Line_Rec_Type)
IS

 v_order_price_attrib_id	NUMBER;
 v_err_msg			varchar2(2000);

 begin

	IF (p_line_rec.pricing_attribute1 IS NOT NULL)  OR
	   (p_line_rec.pricing_attribute2 IS NOT NULL)  OR
	   (p_line_rec.pricing_attribute3 IS NOT NULL)  OR
	   (p_line_rec.pricing_attribute4 IS NOT NULL)  OR
	   (p_line_rec.pricing_attribute5 IS NOT NULL)  OR
	   (p_line_rec.pricing_attribute6 IS NOT NULL)  OR
	   (p_line_rec.pricing_attribute7 IS NOT NULL)  OR
	   (p_line_rec.pricing_attribute8 IS NOT NULL)  OR
	   (p_line_rec.pricing_attribute9 IS NOT NULL)  OR
	   (p_line_rec.pricing_attribute10 IS NOT NULL) OR
	   (oe_upg_so_new.g_line_rec.pricing_attribute11 IS NOT NULL) OR
	   (oe_upg_so_new.g_line_rec.pricing_attribute12 IS NOT NULL) OR
	   (oe_upg_so_new.g_line_rec.pricing_attribute13 IS NOT NULL) OR
	   (oe_upg_so_new.g_line_rec.pricing_attribute14 IS NOT NULL) OR
	   (oe_upg_so_new.g_line_rec.pricing_attribute15 IS NOT NULL)

	THEN

		SELECT OE_ORDER_PRICE_ATTRIBS_S.nextval
		INTO v_order_price_attrib_id
		FROM dual;

		insert into oe_order_price_attribs
		(	header_id,
			line_id,
			creation_date,
			created_by,
			last_update_date,
			last_updated_by,
			last_update_login,
			program_application_id,
			program_id,
			program_update_date,
			request_id,
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
			pricing_attribute11,
			pricing_attribute12,
			pricing_attribute13,
			pricing_attribute14,
			pricing_attribute15,
			flex_title,
			order_price_attrib_id,
			override_flag	,
			lock_control)
		values
		(	p_line_rec.header_id,
			p_line_rec.line_id,
			SYSDATE,
			FND_GLOBAL.USER_ID,
			SYSDATE,
			FND_GLOBAL.USER_ID,
			FND_GLOBAL.LOGIN_ID,
			p_line_rec.program_application_id,
			p_line_rec.program_id,
			p_line_rec.program_update_date,
			p_line_rec.request_id,
			NVL(p_line_rec.pricing_context,'Upgrade Context'),
			p_line_rec.pricing_attribute1,
			p_line_rec.pricing_attribute2,
			p_line_rec.pricing_attribute3,
			p_line_rec.pricing_attribute4,
			p_line_rec.pricing_attribute5,
			p_line_rec.pricing_attribute6,
			p_line_rec.pricing_attribute7,
			p_line_rec.pricing_attribute8,
			p_line_rec.pricing_attribute9,
			p_line_rec.pricing_attribute10,
			oe_upg_so_new.g_line_rec.pricing_attribute11,
			oe_upg_so_new.g_line_rec.pricing_attribute12,
			oe_upg_so_new.g_line_rec.pricing_attribute13,
			oe_upg_so_new.g_line_rec.pricing_attribute14,
			oe_upg_so_new.g_line_rec.pricing_attribute15,
			'QP_ATTR_DEFNS_PRICING',
			v_order_price_attrib_id,
			'N',
			1);
	END IF;

		EXCEPTION
	 		WHEN OTHERS THEN
	   			v_err_msg := SQLERRM;
	   			rollback;
	   			QP_Util.Log_Error(p_id1 => v_order_price_attrib_id,
				  		  p_error_type =>'PRICE_ATTRIBUTES',
		   		  		  p_error_desc => v_err_msg,
				  		  p_error_module => 'Upg_Pricing_Attribs');
				raise;


 end Upg_Pricing_Attribs;



PROCEDURE Upg_Pricing_Attribs (p_upg_line_rec IN OE_UPG_SO_NEW.LINE_REC_TYPE)
IS

 v_order_price_attrib_id	NUMBER;
 v_err_msg			varchar2(2000);

 begin

	IF (p_upg_line_rec.pricing_attribute1 IS NOT NULL)  OR
	   (p_upg_line_rec.pricing_attribute2 IS NOT NULL)  OR
	   (p_upg_line_rec.pricing_attribute3 IS NOT NULL)  OR
	   (p_upg_line_rec.pricing_attribute4 IS NOT NULL)  OR
	   (p_upg_line_rec.pricing_attribute5 IS NOT NULL)  OR
	   (p_upg_line_rec.pricing_attribute6 IS NOT NULL)  OR
	   (p_upg_line_rec.pricing_attribute7 IS NOT NULL)  OR
	   (p_upg_line_rec.pricing_attribute8 IS NOT NULL)  OR
	   (p_upg_line_rec.pricing_attribute9 IS NOT NULL)  OR
	   (p_upg_line_rec.pricing_attribute10 IS NOT NULL) OR
	   (p_upg_line_rec.pricing_attribute11 IS NOT NULL) OR
	   (p_upg_line_rec.pricing_attribute12 IS NOT NULL) OR
	   (p_upg_line_rec.pricing_attribute13 IS NOT NULL) OR
	   (p_upg_line_rec.pricing_attribute14 IS NOT NULL) OR
	   (p_upg_line_rec.pricing_attribute15 IS NOT NULL)

	THEN
		SELECT OE_ORDER_PRICE_ATTRIBS_S.nextval
		INTO v_order_price_attrib_id
		FROM dual;

		insert into oe_order_price_attribs
		(	header_id,
			line_id,
			creation_date,
			created_by,
			last_update_date,
			last_updated_by,
			last_update_login,
			program_application_id,
			program_id,
			program_update_date,
			request_id,
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
			pricing_attribute11,
			pricing_attribute12,
			pricing_attribute13,
			pricing_attribute14,
			pricing_attribute15,
			flex_title,
			order_price_attrib_id,
			override_flag	,
			lock_control)
		values
		(	p_upg_line_rec.header_id,
			p_upg_line_rec.line_id,
			SYSDATE,
			FND_GLOBAL.USER_ID,
			SYSDATE,
			FND_GLOBAL.USER_ID,
			FND_GLOBAL.LOGIN_ID,
			p_upg_line_rec.program_application_id,
			p_upg_line_rec.program_id,
			p_upg_line_rec.program_update_date,
			p_upg_line_rec.request_id,
			NVL(p_upg_line_rec.pricing_context,'Upgrade Context'),
			p_upg_line_rec.pricing_attribute1,
			p_upg_line_rec.pricing_attribute2,
			p_upg_line_rec.pricing_attribute3,
			p_upg_line_rec.pricing_attribute4,
			p_upg_line_rec.pricing_attribute5,
			p_upg_line_rec.pricing_attribute6,
			p_upg_line_rec.pricing_attribute7,
			p_upg_line_rec.pricing_attribute8,
			p_upg_line_rec.pricing_attribute9,
			p_upg_line_rec.pricing_attribute10,
			p_upg_line_rec.pricing_attribute11,
			p_upg_line_rec.pricing_attribute12,
			p_upg_line_rec.pricing_attribute13,
			p_upg_line_rec.pricing_attribute14,
			p_upg_line_rec.pricing_attribute15,
			'QP_ATTR_DEFNS_PRICING',
			v_order_price_attrib_id,
			'N',
			1);
	END IF;

		EXCEPTION
	 		WHEN OTHERS THEN
	   			v_err_msg := SQLERRM;
	   			rollback;
	   			QP_Util.Log_Error(p_id1 => v_order_price_attrib_id,
				  		  p_error_type =>'PRICE_ATTRIBUTES',
		   		  		  p_error_desc => v_err_msg,
				  		  p_error_module => 'Upg_Pricing_Attribs');
				raise;


 end Upg_Pricing_Attribs;


END QP_Upg_OE_PVT;

/
