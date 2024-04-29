--------------------------------------------------------
--  DDL for Package Body XDP_OE_ORDER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDP_OE_ORDER" AS
/* $Header: XDPOEORB.pls 120.1 2005/06/16 01:52:04 appldev  $ */


	/*----------------------------------------
		Procedure : Insert_OE_Order
		Purpose : Insert into XDP OE Order Header
	----------------------------------------*/
	-- API to Insert into XDP OE Order Header Table
	PROCEDURE Insert_OE_Order( P_OE_Order_Header IN XDP_TYPES.OE_ORDER_HEADER,
				P_OE_Order_Parameter_List IN XDP_TYPES.OE_ORDER_PARAMETER_LIST,
				Return_Code OUT NOCOPY NUMBER,
				Error_Description OUT NOCOPY VARCHAR2 ) IS


	lv_oe_order_header	XDP_TYPES.OE_ORDER_HEADER ;
	lv_oe_order_parameter_list	XDP_TYPES.OE_ORDER_PARAMETER_LIST ;
	lv_param_count	BINARY_INTEGER ;
	lv_temp		BINARY_INTEGER ;
	BEGIN
		-- Make a Local copy.
		lv_oe_order_header := P_OE_ORDER_HEADER ;
		lv_oe_order_parameter_list := P_OE_Order_Parameter_List ;

		-- Initialize
		Return_Code := 0 ;
		Error_Description := '' ;

		-- Check if the Order Number is passed.
		IF( lv_oe_order_header.ORDER_NUMBER IS NULL ) THEN
			Return_Code := -111 ;
			Error_Description := 'Error: XDP OE Order Number cannot be NULL' ;
			RETURN ;
		END IF ;

		-- Check if the Order Number already exists
		IF ( OE_Order_Exists( lv_oe_order_header.ORDER_NUMBER,
				lv_oe_order_header.ORDER_VERSION ) = 'Y' ) THEN

			Return_Code := -111 ;
			Error_Description := 'Error: Order Number ' ||
				lv_oe_order_header.ORDER_NUMBER || ' exists.' ;
			RETURN ;
		END IF ;

		IF( lv_oe_order_header.PROVISIONING_DATE IS NULL ) THEN
			lv_oe_order_header.PROVISIONING_DATE := SYSDATE ;

		END IF ;

		-- Insert into the XDP OE Order Header Table
		INSERT INTO XDP_OE_ORDER_HEADERS (
			ORDER_NUMBER,
			ORDER_VERSION,
			PROVISIONING_DATE,
			COMPLETION_DATE,
			ORDER_TYPE,
			ORDER_ACTION,
			ORDER_SOURCE,
			PRIORITY,
			STATUS,
			SDP_ORDER_ID,
			DUE_DATE,
			CUSTOMER_REQUIRED_DATE,
			CUSTOMER_NAME,
			CUSTOMER_ID,
			ORG_ID,
			SERVICE_PROVIDER_ID,
			TELEPHONE_NUMBER,
			RELATED_ORDER_ID,
			ORDER_COMMENT,
			SP_ORDER_NUMBER,
			SP_USERID,
			JEOPARDY_ENABLED_FLAG,
			ORDER_REF_NAME,
			ORDER_REF_VALUE
		)
		VALUES (
			UPPER(lv_oe_order_header.ORDER_NUMBER),
                        -- Order version made mandatory. 03/27/2001. skilaru
			NVL(lv_oe_order_header.ORDER_VERSION,'1'),
			lv_oe_order_header.PROVISIONING_DATE,
			lv_oe_order_header.COMPLETION_DATE,
			lv_oe_order_header.ORDER_TYPE,
			lv_oe_order_header.ORDER_ACTION,
			lv_oe_order_header.ORDER_SOURCE,
			lv_oe_order_header.PRIORITY,
			'SUBMITTED',
			lv_oe_order_header.SDP_ORDER_ID,
			lv_oe_order_header.DUE_DATE,
			lv_oe_order_header.CUSTOMER_REQUIRED_DATE,
			UPPER(lv_oe_order_header.CUSTOMER_NAME),
			lv_oe_order_header.CUSTOMER_ID,
			lv_oe_order_header.ORG_ID,
			lv_oe_order_header.SERVICE_PROVIDER_ID,
			lv_oe_order_header.TELEPHONE_NUMBER,
			lv_oe_order_header.RELATED_ORDER_ID,
			lv_oe_order_header.ORDER_COMMENT,
			lv_oe_order_header.SP_ORDER_NUMBER,
			lv_oe_order_header.SP_USERID,
			lv_oe_order_header.JEOPARDY_ENABLED_FLAG,
			lv_oe_order_header.ORDER_REF_NAME,
			lv_oe_order_header.ORDER_REF_VALUE
		) ;

		-- Check if any Parameters are defined for this Order
		IF( lv_oe_order_parameter_list.COUNT = 0 ) THEN
			-- No Parameters.
			NULL ;
		ELSE
			-- Insert any XDP OE Order Parameters.
			lv_param_count := lv_oe_order_parameter_list.FIRST ;
			FOR lv_temp IN 1..lv_oe_order_parameter_list.COUNT
			LOOP
				INSERT INTO XDP_OE_ORDER_PARAMETERS (
					ORDER_NUMBER,
					ORDER_VERSION,
					PARAMETER_NAME,
					PARAMETER_VALUE
				)
				VALUES (
					UPPER(lv_oe_order_header.ORDER_NUMBER),
                                        -- Order version made mandatory. 03/27/2001. skilaru
					NVL(lv_oe_order_header.ORDER_VERSION,'1'),
					lv_oe_order_parameter_list( lv_param_count ).PARAMETER_NAME,
					lv_oe_order_parameter_list( lv_param_count ).PARAMETER_VALUE
				) ;
				lv_param_count := lv_oe_order_parameter_list.NEXT( lv_param_count ) ;

			END LOOP ;
		END IF ;

	--COMMIT ;
	EXCEPTION
		WHEN OTHERS THEN
			Return_Code := SQLCODE ;
			Error_Description := SUBSTR( SQLERRM, 1, 280 ) ;
	END	Insert_OE_Order ;


	/*----------------------------------------
		Function: OE_Order_Exists
		Purpose: Check if the given Order already exists.
	----------------------------------------*/
	FUNCTION OE_Order_Exists( P_Order_Number IN VARCHAR2,
                                  -- Order version made mandatory. 03/27/2001. skilaru
				  P_Version IN VARCHAR2)
			        	RETURN VARCHAR2 IS
	lv_exists_flag VARCHAR2(1);
	BEGIN
--		IF P_Version IS NULL THEN
		BEGIN
			SELECT 'Y' INTO lv_exists_flag
			FROM DUAL
			WHERE EXISTS
				( SELECT 'x' FROM XDP_OE_ORDER_HEADERS
				WHERE ORDER_NUMBER =
						UPPER(P_Order_Number));
                                -- AND ORDER_VERSION IS NULL);
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				lv_exists_flag := 'N';
		END;
/*		ELSE
		BEGIN
			SELECT 'Y' INTO lv_exists_flag
			FROM DUAL
			WHERE EXISTS
				( SELECT 'x' FROM XDP_OE_ORDER_HEADERS
				WHERE ORDER_NUMBER =
						UPPER( P_Order_Number) AND
				ORDER_VERSION = UPPER( p_Version));
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				lv_exists_flag := 'N';
		END;
		END IF;
*/
		RETURN lv_exists_flag;

	EXCEPTION
		WHEN OTHERS THEN
			RAISE ;
	END 	OE_Order_Exists ;


	/*----------------------------------------
		Procedure : Insert_OE_Order_Line
		Purpose : Insert into XDP OE Order Line and Line Details
	----------------------------------------*/
	-- API to Insert into XDP OE Order Line and Line Details Table
	PROCEDURE Insert_OE_Order_Line( P_OE_Order_Line IN XDP_TYPES.OE_ORDER_LINE,
				P_OE_Order_Line_Detail_List IN XDP_TYPES.OE_ORDER_LINE_DETAIL_LIST,
				Return_Code OUT NOCOPY NUMBER,
				Error_Description OUT NOCOPY VARCHAR2 ) IS

	lv_oe_order_line XDP_TYPES.OE_ORDER_LINE ;
	lv_oe_order_line_detail_list XDP_TYPES.OE_ORDER_LINE_DETAIL_LIST ;
	lv_detail_count	BINARY_INTEGER ;
	lv_temp		BINARY_INTEGER ;
	BEGIN
		-- Make a Local Copy
		lv_oe_order_line := P_OE_Order_Line ;
		lv_oe_order_line_detail_list := P_OE_Order_Line_Detail_List ;

		-- Initialize
		Return_Code := 0 ;
		Error_Description := '' ;

		-- Check if Mandatory fields have Values.
		IF( lv_oe_order_line.ORDER_NUMBER IS NULL ) THEN
			Return_Code := -111 ;
			Error_Description := 'Error: XDP OE Order Number cannot be NULL' ;
			RETURN ;
		END IF ;

		IF( lv_oe_order_line.LINE_NUMBER IS NULL ) THEN
			Return_Code := -111 ;
			Error_Description := 'Error: XDP OE Order Line Number cannot be NULL' ;
			RETURN ;
		END IF ;

		IF( lv_oe_order_line.LINE_ITEM_NAME IS NULL ) THEN
			Return_Code := -111 ;
			Error_Description := 'Error: XDP OE Order Line Item Name cannot be NULL' ;
			RETURN ;
		END IF ;

		IF( lv_oe_order_line.PROVISIONING_REQUIRED_FLAG IS NULL ) THEN
			lv_oe_order_line.PROVISIONING_REQUIRED_FLAG := 'Y' ;
		END IF ;

		-- Check if this is a Valid XDP OE Order
		IF ( OE_Order_Exists(UPPER( lv_oe_order_line.ORDER_NUMBER ),
				lv_oe_order_line.ORDER_VERSION ) = 'N' ) THEN

			Return_Code := -111 ;
			Error_Description := 'Error: Order Number ' ||
				lv_oe_order_line.ORDER_NUMBER || ' does not exist.' ;
			RETURN ;
		END IF ;

		-- Insert the XDP Order Line
		INSERT INTO XDP_OE_ORDER_LINES (
			ORDER_NUMBER,
			ORDER_VERSION,
			LINE_NUMBER,
			LINE_ITEM_NAME,
			LINE_ITEM_VERSION,
			LINE_ITEM_ACTION,
			PROVISIONING_REQUIRED_FLAG,
			IS_WORKITEM_FLAG,
			LINE_ITEM_TYPE,
			STATUS,
			PROVISIONING_SEQUENCE,
			PRIORITY,
			PROVISIONING_DATE,
			DUE_DATE,
			CUSTOMER_REQUIRED_DATE,
			COMPLETION_DATE,
			BUNDLE_ID,
			BUNDLE_SEQUENCE,
			STARTING_NUMBER,
			ENDING_NUMBER,
			JEOPARDY_ENABLED_FLAG
		)
		VALUES (
			UPPER(lv_oe_order_line.ORDER_NUMBER),
                        -- Order version made mandatory. 03/27/2001. skilaru
			NVL(lv_oe_order_line.ORDER_VERSION,'1'),
			lv_oe_order_line.LINE_NUMBER,
			lv_oe_order_line.LINE_ITEM_NAME,
			lv_oe_order_line.LINE_ITEM_VERSION,
			lv_oe_order_line.LINE_ITEM_ACTION,
			lv_oe_order_line.PROVISIONING_REQUIRED_FLAG,
			lv_oe_order_line.IS_WORKITEM_FLAG,
			lv_oe_order_line.LINE_ITEM_TYPE,
			lv_oe_order_line.STATUS,
			lv_oe_order_line.PROVISIONING_SEQUENCE,
			lv_oe_order_line.PRIORITY,
			lv_oe_order_line.PROVISIONING_DATE,
			lv_oe_order_line.DUE_DATE,
			lv_oe_order_line.CUSTOMER_REQUIRED_DATE,
			lv_oe_order_line.COMPLETION_DATE,
			lv_oe_order_line.BUNDLE_ID,
			lv_oe_order_line.BUNDLE_SEQUENCE,
			lv_oe_order_line.STARTING_NUMBER,
			lv_oe_order_line.ENDING_NUMBER,
			lv_oe_order_line.JEOPARDY_ENABLED_FLAG
		) ;

		-- Check if any details are defined for this Line
		IF( lv_oe_order_line_detail_list.COUNT = 0 ) THEN
			-- No details
			NULL ;
		ELSE
			-- Insert any Line Details
			lv_detail_count := lv_oe_order_line_detail_list.FIRST ;
			FOR lv_temp IN 1..lv_oe_order_line_detail_list.COUNT
			LOOP
				INSERT INTO XDP_OE_ORDER_LINE_DETS (
					ORDER_NUMBER,
					ORDER_VERSION,
					LINE_NUMBER,
					PARAMETER_NAME,
					PARAMETER_VALUE,
					PARAMETER_REF_VALUE
				)
				VALUES (
					UPPER( lv_oe_order_line.ORDER_NUMBER),
                                        -- Order version made mandatory. 03/27/2001. skilaru
					NVL(lv_oe_order_line.ORDER_VERSION,'1'),
					lv_oe_order_line.LINE_NUMBER,
					lv_oe_order_line_detail_list( lv_detail_count ).PARAMETER_NAME,
					lv_oe_order_line_detail_list( lv_detail_count ).PARAMETER_VALUE,
				lv_oe_order_line_detail_list( lv_detail_count ).PARAMETER_REF_VALUE

				) ;
				lv_detail_count := lv_oe_order_line_detail_list.NEXT( lv_detail_count ) ;

			END LOOP ;
		END IF ;

		--COMMIT ;
	EXCEPTION
		WHEN OTHERS THEN
			Return_Code := SQLCODE ;
			Error_Description := SUBSTR( SQLERRM, 1, 280 ) ;
	END	Insert_OE_Order_Line ;

	/*----------------------------------------
		Procedure : Submit_OE_Order
		Purpose : Subimt an Order for Processing from XDP OE Order Tables

		Orginally this was XDP_Submit_OE_Order Procedure. This has now been
		moved into this Package.
	----------------------------------------*/
	-- API to Submit an Order for Processing from XDP OE Order Tables
	PROCEDURE Submit_OE_Order( P_OE_Order_Number IN VARCHAR2,
                                -- Order version made mandatory 03/27/2001. skilaru
				-- P_OE_Order_Version IN VARCHAR2 DEFAULT NULL,
				P_OE_Order_Version IN VARCHAR2,
				SDP_Order_ID OUT NOCOPY NUMBER,
				Return_Code OUT NOCOPY NUMBER,
				Error_Description OUT NOCOPY VARCHAR2) IS
	lv_header		XDP_TYPES.ORDER_HEADER;
	lv_order_params		XDP_TYPES.ORDER_PARAMETER_LIST;
	lv_line			XDP_TYPES.ORDER_LINE_LIST;
	lv_line_details		XDP_TYPES.LINE_PARAM_LIST;
	lv_index		NUMBER;
	l_sdp_order_id          NUMBER;

	CURSOR lc_param IS
	SELECT PARAMETER_NAME, PARAMETER_VALUE
	FROM XDP_OE_ORDER_PARAMETERS
	WHERE ORDER_NUMBER = p_oe_order_number
	AND ORDER_VERSION = p_oe_order_version ;

       /* p_oe_order_version made mandatory. This cursor is never opened.
       ** Code section will be removed in next change of API.
       ** 02/27/2001. skilaru
       */
--	CURSOR lc_param2 IS
--	SELECT PARAMETER_NAME, PARAMETER_VALUE
--	FROM XDP_OE_ORDER_PARAMETERS
--	WHERE ORDER_NUMBER = p_oe_order_number
--	AND ORDER_VERSION IS NULL;

	CURSOR lc_line IS
	SELECT *
	FROM XDP_OE_ORDER_LINES
	WHERE ORDER_NUMBER = p_oe_order_number
	AND ORDER_VERSION = p_oe_order_version;

       /* p_oe_order_version made mandatory. This cursor is never opened.
       ** Code section will be removed in next change of API.
       ** 02/27/2001. skilaru
       */
--	CURSOR lc_line2 IS
--	SELECT *
--	FROM XDP_OE_ORDER_LINES
--	WHERE ORDER_NUMBER = p_oe_order_number
--	AND ORDER_VERSION IS NULL;

	CURSOR lc_line_param IS
	select *
	from xdp_oe_order_line_dets
	where order_number = p_oe_order_number
	and order_version = p_oe_order_version;

       /* p_oe_order_version made mandatory. This cursor is never opened.
       ** Code section will be removed in next change of API.
       ** 02/27/2001. skilaru
       */
--	CURSOR lc_line_param2 IS
--	select *
--	from xdp_oe_order_line_dets
--	where order_number = p_oe_order_number
--	and order_version IS NULL;

	BEGIN
	return_code := 0;
       /* p_oe_order_version made mandatory. This code path will never
       ** be taken and is hence put within comments.
       ** Code section will be removed in next change of API.
       ** 02/27/2001. skilaru

	IF p_oe_order_version IS NULL THEN
		select order_number ,
			order_version ,
			provisioning_date,
			priority ,
			due_date ,
			customer_required_date ,
			order_type ,
			order_action ,
			order_source ,
			related_order_id,
			org_id ,
			customer_name ,
			customer_id  ,
			service_provider_id ,
			telephone_number,
			jeopardy_enabled_flag,
			order_ref_name,
			order_ref_value,
			sp_order_number,
			sp_userid
		into lv_header.order_number ,
			lv_header.order_version ,
			lv_header.provisioning_date,
			lv_header.priority ,
			lv_header.due_date ,
			lv_header.customer_required_date ,
			lv_header.order_type ,
			lv_header.order_action ,
			lv_header.order_source ,
			lv_header.related_order_id,
			lv_header.org_id ,
			lv_header.customer_name ,
			lv_header.customer_id  ,
			lv_header.service_provider_id ,
			lv_header.telephone_number,
			lv_header.jeopardy_enabled_flag,
			lv_header.order_ref_name,
			lv_header.order_ref_value,
			lv_header.sp_order_number,
			lv_header.sp_userid
		from xdp_oe_order_headers
		where order_number = p_oe_order_number
		and order_version IS NULL;

		lv_index := 0;
		FOR lv_param_rec in lc_param2 LOOP
			lv_index := lv_index + 1;
			lv_order_params(lv_index).parameter_name :=
						lv_param_rec.parameter_name;
			lv_order_params(lv_index).parameter_value :=
						lv_param_rec.parameter_value;
		END LOOP;

		lv_index := 0;
		FOR lv_line_rec in lc_line2 LOOP
			lv_index := lv_index + 1;
			lv_line(lv_index).line_number :=
						lv_line_rec.line_number;
			lv_line(lv_index).LINE_ITEM_NAME :=
						lv_line_rec.LINE_ITEM_NAME ;
			lv_line(lv_index).version :=
						lv_line_rec.line_item_version;
			lv_line(lv_index).is_workitem_flag :=
						lv_line_rec.is_workitem_flag;
			lv_line(lv_index).action:=
						lv_line_rec.line_item_action ;
			lv_line(lv_index).provisioning_date :=
						lv_line_rec.provisioning_date ;
			lv_line(lv_index).provisioning_required_flag :=
					lv_line_rec.provisioning_required_flag ;
			lv_line(lv_index).provisioning_sequence :=
					lv_line_rec.provisioning_sequence ;
			lv_line(lv_index).bundle_id :=
						lv_line_rec.bundle_id ;
			lv_line(lv_index).bundle_sequence :=
						lv_line_rec.bundle_sequence ;
			lv_line(lv_index).priority :=
						lv_line_rec.priority ;
			lv_line(lv_index).due_date :=
						lv_line_rec.due_date ;
			lv_line(lv_index).customer_required_date:=
						lv_line_rec.customer_required_date;
			lv_line(lv_index).jeopardy_enabled_flag:=
					lv_line_rec.jeopardy_enabled_flag;
			lv_line(lv_index).starting_number:=
						lv_line_rec.starting_number;
			lv_line(lv_index).ending_number:=
						lv_line_rec.ending_number;

		END LOOP;

		lv_index := 0;
		FOR lv_line_param_rec IN lc_line_param2 LOOP
			lv_index := lv_index + 1;
			lv_line_details(lv_index).line_number :=
						lv_line_param_rec.line_number;
			lv_line_details(lv_index).parameter_name :=
					lv_line_param_rec.parameter_name;
			lv_line_details(lv_index).parameter_value :=
					lv_line_param_rec.parameter_value;
			lv_line_details(lv_index).parameter_ref_value :=
					lv_line_param_rec.parameter_ref_value;
		END LOOP;

	ELSE
************************/
		select order_number ,
			order_version ,
			provisioning_date,
			priority ,
			due_date ,
			customer_required_date ,
			order_type ,
			order_action ,
			order_source ,
			related_order_id,
			org_id ,
			customer_name ,
			customer_id  ,
			service_provider_id ,
			telephone_number,
			jeopardy_enabled_flag,
			order_ref_name,
			order_ref_value,
			sp_order_number,
			sp_userid
		into lv_header.order_number ,
			lv_header.order_version ,
			lv_header.provisioning_date,
			lv_header.priority ,
			lv_header.due_date ,
			lv_header.customer_required_date ,
			lv_header.order_type ,
			lv_header.order_action ,
			lv_header.order_source ,
			lv_header.related_order_id,
			lv_header.org_id ,
			lv_header.customer_name ,
			lv_header.customer_id  ,
			lv_header.service_provider_id ,
			lv_header.telephone_number,
			lv_header.jeopardy_enabled_flag,
			lv_header.order_ref_name,
			lv_header.order_ref_value,
			lv_header.sp_order_number,
			lv_header.sp_userid
		from xdp_oe_order_headers
		where order_number = p_oe_order_number
		and order_version = p_oe_order_version;

		lv_index := 0;
		FOR lv_param_rec in lc_param LOOP
			lv_index := lv_index + 1;
			lv_order_params(lv_index).parameter_name :=
					lv_param_rec.parameter_name;
			lv_order_params(lv_index).parameter_value :=
					lv_param_rec.parameter_value;
		END LOOP;

		lv_index := 0;
		FOR lv_line_rec in lc_line LOOP
			lv_index := lv_index + 1;
			lv_line(lv_index).line_number :=
					lv_line_rec.line_number;
			lv_line(lv_index).LINE_ITEM_NAME :=
					lv_line_rec.LINE_ITEM_NAME ;
			lv_line(lv_index).version :=
					lv_line_rec.line_item_version;
			lv_line(lv_index).is_workitem_flag :=
					lv_line_rec.is_workitem_flag;
			lv_line(lv_index).action:=
					lv_line_rec.line_item_action ;
			lv_line(lv_index).provisioning_date :=
					lv_line_rec.provisioning_date ;
			lv_line(lv_index).provisioning_required_flag :=
					lv_line_rec.provisioning_required_flag ;
			lv_line(lv_index).provisioning_sequence :=
					lv_line_rec.provisioning_sequence ;
			lv_line(lv_index).bundle_id :=
					lv_line_rec.bundle_id ;
			lv_line(lv_index).bundle_sequence :=
					lv_line_rec.bundle_sequence ;
			lv_line(lv_index).priority :=
					lv_line_rec.priority ;
			lv_line(lv_index).due_date :=
					lv_line_rec.due_date ;
			lv_line(lv_index).customer_required_date:=
					lv_line_rec.customer_required_date;
			lv_line(lv_index).jeopardy_enabled_flag:=
					lv_line_rec.jeopardy_enabled_flag;
			lv_line(lv_index).starting_number:=
					lv_line_rec.starting_number;
			lv_line(lv_index).ending_number:=
					lv_line_rec.ending_number;
		END LOOP;

		lv_index := 0;
		FOR lv_line_param_rec IN lc_line_param LOOP
			lv_index := lv_index + 1;
			lv_line_details(lv_index).line_number :=
					lv_line_param_rec.line_number;
			lv_line_details(lv_index).parameter_name :=
					lv_line_param_rec.parameter_name;
			lv_line_details(lv_index).parameter_value :=
					lv_line_param_rec.parameter_value;
			lv_line_details(lv_index).parameter_ref_value :=
					lv_line_param_rec.parameter_ref_value;
		END LOOP;
--	END IF;

	XDP_INTERFACES.PROCESS_ORDER( P_ORDER_HEADER => lv_header,
			P_ORDER_PARAMETER => lv_order_params,
			P_ORDER_LINE_LIST => lv_line,
			P_LINE_PARAMETER_LIST 	=> lv_line_details,
			SDP_ORDER_ID => sdp_order_id,
			RETURN_CODE => return_code,
			ERROR_DESCRIPTION => error_description);

	/* BEN: 5/6/99 made this change:
	**      update table xdp_oe_order_headers with the value obtained from
	**      process_order() for the SDP_ORDER_ID column.
	*/

	l_sdp_order_id := sdp_order_id;

       /* p_oe_order_version made mandatory. This code path will never
       ** be taken and is hence put within comments.
       ** Code section will be removed in next change of API.
       ** 02/27/2001. skilaru
	IF p_oe_order_version IS NULL THEN

		update XDP_OE_ORDER_HEADERS
		set SDP_ORDER_ID = l_sdp_order_id, STATUS='SUBMITTED'
		where ORDER_NUMBER =  p_oe_order_number
		and   ORDER_VERSION is NULL;

	ELSE
**************/
		update XDP_OE_ORDER_HEADERS
		set SDP_ORDER_ID = l_sdp_order_id, STATUS='SUBMITTED'
		where ORDER_NUMBER =  p_oe_order_number
		and   ORDER_VERSION = p_oe_order_version;
--	END IF;

	EXCEPTION
		WHEN OTHERS THEN
		     return_code := SQLCODE;
		     error_description := SUBSTR(SQLERRM,1,280);
	END Submit_OE_Order;

END	XDP_OE_ORDER ;

/
