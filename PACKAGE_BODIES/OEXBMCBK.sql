--------------------------------------------------------
--  DDL for Package Body OEXBMCBK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OEXBMCBK" AS
/* $Header: OEXBMCBB.pls 115.1 99/07/16 08:11:35 porting shi $ */

PROCEDURE get_config_delivery
(
	link_mode		IN NUMBER,
	dem_src_header 		IN NUMBER,
	dem_src_line 		IN NUMBER,
	dem_src_type 		IN NUMBER,
	config_item_id 		IN NUMBER,
	dem_src_delivery 	IN OUT NUMBER,
	msg_text 		IN OUT VARCHAR2,
	completion_status 		IN OUT NUMBER
)
IS
	parameter_error		EXCEPTION;
	header_id 		NUMBER := 0;
	user_id		 	NUMBER := 0;
	stmt_number		NUMBER := 0;
BEGIN

	completion_status := 0;	-- success
	msg_text := 'OEXBMCBK:' || 'success';

	IF (dem_src_header = -1) OR
	   (dem_src_line = -1)   OR
	   (dem_src_type = -1)   OR
	   (config_item_id = -1) THEN
		RAISE parameter_error;
	END IF;

-- Get the header_id from mtl_sales_orders using the ccid (dem_src_header)

	stmt_number := 1;

	SELECT OEORD.HEADER_ID
	INTO   header_id
	FROM   MTL_SALES_ORDERS MTLSO,
	       SO_ORDER_TYPES_ALL OETYP,
	       SO_HEADERS_ALL OEORD
	WHERE  MTLSO.SALES_ORDER_ID = dem_src_header
	AND    OETYP.NAME = MTLSO.SEGMENT2
	AND    OEORD.ORDER_NUMBER = TO_NUMBER( MTLSO.SEGMENT1 )
	AND    OEORD.ORDER_TYPE_ID = OETYP.ORDER_TYPE_ID;

	IF (link_mode = 1) THEN

-- Update the MFG Release column for this configuration to 'ATO Item Created'
-- when linking the configuration item

	stmt_number := 2;

	UPDATE 	SO_LINES_ALL
	SET 	S27 = 23
	WHERE 	HEADER_ID = header_id
	AND 	(LINE_ID = dem_src_line
		 OR ATO_LINE_ID = dem_src_line)
	AND 	ATO_FLAG = 'Y';

	ELSIF (link_mode = 2) THEN

-- Update the MFG Release column for this configuration to 'Released'
-- when delinking the configuration item

	stmt_number := 3;

	UPDATE	SO_LINES_ALL
	SET	S27 = 4
	WHERE	HEADER_ID = header_id
	AND 	(LINE_ID = dem_src_line
		 OR ATO_LINE_ID = dem_src_line)
	AND 	ATO_FLAG = 'Y'
	AND 	NOT EXISTS
		(SELECT	'Released Details'
		 FROM	SO_LINE_DETAILS
		 WHERE	LINE_ID IN
			(SELECT LINE_ID
			 FROM SO_LINES_ALL
			 WHERE LINE_ID = dem_src_line)
		 AND 	INVENTORY_ITEM_ID = config_item_id
		 AND 	RELEASED_FLAG = 'Y');

	END IF;

-- Get the next delivery to be used in line_details and mtl_demand
-- if linking the configuration item

	IF (link_mode = 1) THEN

	stmt_number := 4;

	SELECT 	SO_DELIVERIES_S.NEXTVAL
	INTO 	dem_src_delivery
	FROM 	DUAL;

	END IF;

	IF (link_mode = 1) THEN

-- Insert the line detail for the configuration item with the same
-- information as the link_model line detail when linking configuration item

	stmt_number := 5;

	INSERT INTO SO_LINE_DETAILS
		(LINE_ID,
                 LINE_DETAIL_ID,
                 DELIVERY,
                 CREATED_BY,
                 CREATION_DATE,
                 LAST_UPDATED_BY,
                 LAST_UPDATE_DATE,
                 COMPONENT_CODE,
                 COMPONENT_RATIO,
                 COMPONENT_SEQUENCE_ID,
                 CONFIGURATION_ITEM_FLAG,
                 CUSTOMER_REQUESTED_LOT_FLAG,
                 DEMAND_CLASS_CODE,
                 INCLUDED_ITEM_FLAG,
                 INVENTORY_ITEM_ID,
                 INVENTORY_LOCATION_ID,
                 LATEST_ACCEPTABLE_DATE,
                 LOT_NUMBER,
                 QUANTITY,
                 RELEASED_FLAG,
                 REQUIRED_FOR_REVENUE_FLAG,
                 SHIPPABLE_FLAG,
                 TRANSACTABLE_FLAG,
                 RESERVABLE_FLAG,
                 REVISION,
                 SCHEDULE_DATE,
                 SCHEDULE_STATUS_CODE,
                 SUBINVENTORY,
                 UNIT_CODE,
                 WAREHOUSE_ID,
                 CUSTOMER_ITEM_ID,
                 DPW_ASSIGNED_FLAG,
                 WIP_COMPLETED_QUANTITY,
                 WIP_RESERVED_QUANTITY,
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
                 ATTRIBUTE15)
        SELECT   LD.LINE_ID,
                 SO_LINE_DETAILS_S.NEXTVAL,
                 dem_src_delivery,
                 user_id,
                 SYSDATE,
                 user_id,
                 SYSDATE,
                 NVL(LD.COMPONENT_CODE, LD.INVENTORY_ITEM_ID)
			|| '-' || TO_CHAR(config_item_id),
                 LD.COMPONENT_RATIO,
                 NULL,
                 'Y',
                 LD.CUSTOMER_REQUESTED_LOT_FLAG,
                 LD.DEMAND_CLASS_CODE,
                 'N',
                 config_item_id,
                 LD.INVENTORY_LOCATION_ID,
                 LD.LATEST_ACCEPTABLE_DATE,
                 LD.LOT_NUMBER,
                 LD.QUANTITY,
                 'N',
                 LD.REQUIRED_FOR_REVENUE_FLAG,
                 'Y',
                 'Y',
                 'Y',
                 LD.REVISION,
                 LD.SCHEDULE_DATE,
                 LD.SCHEDULE_STATUS_CODE,
                 LD.SUBINVENTORY,
                 LD.UNIT_CODE,
                 LD.WAREHOUSE_ID,
                 LD.CUSTOMER_ITEM_ID,
                 LD.DPW_ASSIGNED_FLAG,
                 NULL,
                 NULL,
                 LD.CONTEXT,
                 LD.ATTRIBUTE1,
                 LD.ATTRIBUTE2,
                 LD.ATTRIBUTE3,
                 LD.ATTRIBUTE4,
                 LD.ATTRIBUTE5,
                 LD.ATTRIBUTE6,
                 LD.ATTRIBUTE7,
                 LD.ATTRIBUTE8,
                 LD.ATTRIBUTE9,
                 LD.ATTRIBUTE10,
                 LD.ATTRIBUTE11,
                 LD.ATTRIBUTE12,
                 LD.ATTRIBUTE13,
                 LD.ATTRIBUTE14,
                 LD.ATTRIBUTE15
	FROM 	SO_LINE_DETAILS LD
	WHERE 	LD.LINE_ID = dem_src_line
	AND 	LD.INCLUDED_ITEM_FLAG = 'N'
	AND 	ROWNUM = 1;

	ELSIF (link_mode = 2) THEN

-- Delete the configuration item detail from so_line_details when the
-- configuration item is delinked in mtl_demand

	stmt_number := 6;

	DELETE 	FROM 	SO_LINE_DETAILS
		WHERE 	LINE_ID = dem_src_line
		AND 	INVENTORY_ITEM_ID = config_item_id;

	END IF;

EXCEPTION
    WHEN parameter_error THEN
	completion_status 	:= -1;
	msg_text		:= 'OEXBMCBK:' || 'verify parameters';
    WHEN OTHERS THEN
    	completion_status	:= SQLCODE;
  	msg_text		:= 'OEXBMCBK:(' || TO_CHAR(stmt_number) ||
					'):' || SUBSTR(SQLERRM, 1, 70);
END;

END OEXBMCBK;

/
