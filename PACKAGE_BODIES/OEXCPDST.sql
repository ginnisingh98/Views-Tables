--------------------------------------------------------
--  DDL for Package Body OEXCPDST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OEXCPDST" AS
/* $Header: OECPDILB.pls 115.1 99/07/16 08:10:43 porting shi $ */

PROCEDURE OE_CP_DISCOUNT
(       source_id                       IN      NUMBER
,       destination_id                  IN      NUMBER
, 	destination_price_list_id	IN	NUMBER
,       msg_text                        OUT     VARCHAR2
,       return_status                   OUT     NUMBER
,	line_item_not_copied		OUT	NUMBER
,	line_exist			OUT	NUMBER
)

IS
	actbuf				VARCHAR2(100);
	s_entity_code			VARCHAR2(30);
	count_of_exist_items		NUMBER;
	s_discount_line_id		NUMBER := NULL;
	d_discount_line_id		NUMBER := NULL;

	CURSOR C1 IS 	SELECT	DISCOUNT_ID
			,	DISCOUNT_LINE_ID
			,	ENTITY_ID
			,	ENTITY_VALUE
			,	PERCENT
			,	AMOUNT
			,	PRICE
			,	START_DATE_ACTIVE
			,	END_DATE_ACTIVE
			,	CONTEXT
			,	ATTRIBUTE1
			, 	ATTRIBUTE2
			, 	ATTRIBUTE3
			, 	ATTRIBUTE4
			, 	ATTRIBUTE5
			, 	ATTRIBUTE6
			, 	ATTRIBUTE7
			, 	ATTRIBUTE8
			, 	ATTRIBUTE9
			, 	ATTRIBUTE10
			, 	ATTRIBUTE11
			, 	ATTRIBUTE12
			, 	ATTRIBUTE13
			, 	ATTRIBUTE14
			, 	ATTRIBUTE15
			FROM	SO_DISCOUNT_LINES
			WHERE	DISCOUNT_ID = source_id;

	CURSOR C2 IS	SELECT 	PRICE_BREAK_LINES_LOW_RANGE
			,	PRICE_BREAK_LINES_HIGH_RANGE
			,       DISCOUNT_LINE_ID
			,       METHOD_TYPE_CODE
			,       PERCENT
			,       AMOUNT
			,       PRICE
			,       UNIT_CODE
			,       CONTEXT
			,       ATTRIBUTE1
			,       ATTRIBUTE2
			,       ATTRIBUTE3
			,       ATTRIBUTE4
			,       ATTRIBUTE5
			,       ATTRIBUTE6
			,       ATTRIBUTE7
			,       ATTRIBUTE8
			,       ATTRIBUTE9
			,       ATTRIBUTE10
			,       ATTRIBUTE11
			,       ATTRIBUTE12
			,       ATTRIBUTE13
			,       ATTRIBUTE14
			,       ATTRIBUTE15
			FROM 	SO_PRICE_BREAK_LINES
			WHERE	DISCOUNT_LINE_ID = s_discount_line_id;

BEGIN
	line_item_not_copied := 0;
	line_exist := 0;

	FOR C1REC IN C1 LOOP

		s_discount_line_id := C1REC.DISCOUNT_LINE_ID;

		SELECT 	ENTITY_CODE
		INTO 	s_entity_code
		FROM	SO_ENTITIES
		WHERE	ENTITY_ID = C1REC.ENTITY_ID;

		IF (s_entity_code = 'I') THEN

			SELECT  COUNT(*)
			INTO	count_of_exist_items
			FROM    SO_PRICE_LIST_LINES
			WHERE   PRICE_LIST_ID = destination_price_list_id
   			AND     INVENTORY_ITEM_ID = C1REC.ENTITY_VALUE;

		END IF;

		IF (s_entity_code = 'I') AND (count_of_exist_items = 0) THEN

			line_item_not_copied := 1;

		ELSE

			SELECT 	SO_DISCOUNT_LINES_S.NEXTVAL
			INTO	d_discount_line_id
			FROM	DUAL;

			actbuf := 'Inserting discount lines.';
			line_exist := 1;

			INSERT INTO SO_DISCOUNT_LINES
        		( 	DISCOUNT_LINE_ID
			,	CREATION_DATE
			,	CREATED_BY
			,	LAST_UPDATE_DATE
			,	LAST_UPDATED_BY
			,	LAST_UPDATE_LOGIN
			,	PROGRAM_APPLICATION_ID
			,	PROGRAM_ID
			,	PROGRAM_UPDATE_DATE
			,	REQUEST_ID
			,	DISCOUNT_ID
			,	ENTITY_ID
			,	ENTITY_VALUE
			,	PERCENT
			,	AMOUNT
			,	PRICE
			,	START_DATE_ACTIVE
			,	END_DATE_ACTIVE
			,	CONTEXT
			,	ATTRIBUTE1
			,	ATTRIBUTE2
			,	ATTRIBUTE3
			,	ATTRIBUTE4
			,	ATTRIBUTE5
			,	ATTRIBUTE6
			,	ATTRIBUTE7
			,	ATTRIBUTE8
			,	ATTRIBUTE9
			,	ATTRIBUTE10
			,	ATTRIBUTE11
			,	ATTRIBUTE12
			,	ATTRIBUTE13
			,	ATTRIBUTE14
			,	ATTRIBUTE15
			)
			VALUES	(d_discount_line_id
			,	SYSDATE
			,	1
			,	SYSDATE
			,	1
			,	NULL
			,	NULL
			,	NULL
			,	NULL
			,	NULL
			,	destination_id
			,	C1REC.ENTITY_ID
			,	C1REC.ENTITY_VALUE
			,	C1REC.PERCENT
			,	C1REC.AMOUNT
			,	C1REC.PRICE
			,	C1REC.START_DATE_ACTIVE
			,	C1REC.END_DATE_ACTIVE
			,	C1REC.CONTEXT
			,	C1REC.ATTRIBUTE1
			,	C1REC.ATTRIBUTE2
			,	C1REC.ATTRIBUTE3
			,	C1REC.ATTRIBUTE4
			,	C1REC.ATTRIBUTE5
			,	C1REC.ATTRIBUTE6
			,	C1REC.ATTRIBUTE7
			,	C1REC.ATTRIBUTE8
			,	C1REC.ATTRIBUTE9
			,	C1REC.ATTRIBUTE10
			,	C1REC.ATTRIBUTE11
			,	C1REC.ATTRIBUTE12
			,	C1REC.ATTRIBUTE13
			,	C1REC.ATTRIBUTE14
			,	C1REC.ATTRIBUTE15);

			FOR C2REC IN C2 LOOP

				actbuf := 'Inserting price break lines.';

				INSERT INTO SO_PRICE_BREAK_LINES
				(	PRICE_BREAK_LINES_LOW_RANGE
				,	PRICE_BREAK_LINES_HIGH_RANGE
				,	DISCOUNT_LINE_ID
				,	METHOD_TYPE_CODE
				,	CREATION_DATE
        			,       CREATED_BY
        			,       LAST_UPDATE_DATE
        			,       LAST_UPDATED_BY
         			,       LAST_UPDATE_LOGIN
        			,       PROGRAM_APPLICATION_ID
        			,       PROGRAM_ID
         			,       PROGRAM_UPDATE_DATE
        			,       REQUEST_ID
				,	PERCENT
				,	AMOUNT
				,	PRICE
				,	UNIT_CODE
				,	CONTEXT
        			,       ATTRIBUTE1
        			,       ATTRIBUTE2
        			,       ATTRIBUTE3
        			,       ATTRIBUTE4
        			,       ATTRIBUTE5
        			,       ATTRIBUTE6
        			,       ATTRIBUTE7
        			,       ATTRIBUTE8
        			,       ATTRIBUTE9
        			,       ATTRIBUTE10
        			,       ATTRIBUTE11
        			,       ATTRIBUTE12
        			,       ATTRIBUTE13
        			,       ATTRIBUTE14
        			,       ATTRIBUTE15
        			)
        			VALUES	(C2REC.PRICE_BREAK_LINES_LOW_RANGE
				,	C2REC.PRICE_BREAK_LINES_HIGH_RANGE
        			,       d_discount_line_id
        			,       C2REC.METHOD_TYPE_CODE
        			,       SYSDATE
        			,       1
        			,       SYSDATE
        			,       1
        			,       NULL
        			,       NULL
        			,       NULL
        			,       NULL
        			,       NULL
        			,       C2REC.PERCENT
        			,       C2REC.AMOUNT
        			,       C2REC.PRICE
        			,       C2REC.UNIT_CODE
        			,       C2REC.CONTEXT
        			,       C2REC.ATTRIBUTE1
        			,       C2REC.ATTRIBUTE2
        			,       C2REC.ATTRIBUTE3
        			,       C2REC.ATTRIBUTE4
        			,       C2REC.ATTRIBUTE5
        			,       C2REC.ATTRIBUTE6
        			,       C2REC.ATTRIBUTE7
        			,       C2REC.ATTRIBUTE8
        			,       C2REC.ATTRIBUTE9
        			,       C2REC.ATTRIBUTE10
        			,       C2REC.ATTRIBUTE11
        			,       C2REC.ATTRIBUTE12
        			,       C2REC.ATTRIBUTE13
        			,       C2REC.ATTRIBUTE14
        			,       C2REC.ATTRIBUTE15);

			END LOOP;

		END IF;

	END LOOP;

	actbuf := 'Inserting discount customers.';

        INSERT INTO SO_DISCOUNT_CUSTOMERS
        (       DISCOUNT_CUSTOMER_ID
	,	CREATION_DATE
	, 	CREATED_BY
	,	LAST_UPDATE_DATE
	,	LAST_UPDATED_BY
	,	LAST_UPDATE_LOGIN
	,	PROGRAM_APPLICATION_ID
	,	PROGRAM_ID
	,	PROGRAM_UPDATE_DATE
	,	REQUEST_ID
	,	DISCOUNT_ID
	,	CUSTOMER_ID
	,	SITE_USE_ID
	,	START_DATE_ACTIVE
	,	END_DATE_ACTIVE
	,	CONTEXT
	,	ATTRIBUTE1
	,	ATTRIBUTE2
	,	ATTRIBUTE3
	,	ATTRIBUTE4
	,	ATTRIBUTE5
	,	ATTRIBUTE6
	,	ATTRIBUTE7
	,	ATTRIBUTE8
	,	ATTRIBUTE9
	,	ATTRIBUTE10
	,	ATTRIBUTE11
	,	ATTRIBUTE12
	,	ATTRIBUTE13
	,	ATTRIBUTE14
	,	ATTRIBUTE15
        ,       CUSTOMER_CLASS_CODE
	)
	SELECT	SO_DISCOUNT_CUSTOMERS_S.NEXTVAL
	,	SYSDATE
	,	1
	,	SYSDATE
	,	1
	,	NULL
	,	NULL
	,	NULL
	,	NULL
	,	NULL
	,	destination_id
	,	CUSTOMER_ID
	,	SITE_USE_ID
	,	START_DATE_ACTIVE
	,	END_DATE_ACTIVE
	,	CONTEXT
	,	ATTRIBUTE1
	,	ATTRIBUTE2
	,	ATTRIBUTE3
	,	ATTRIBUTE4
	,	ATTRIBUTE5
	,	ATTRIBUTE6
	,	ATTRIBUTE7
	,	ATTRIBUTE8
	,	ATTRIBUTE9
	,	ATTRIBUTE10
	,	ATTRIBUTE11
	,	ATTRIBUTE12
	,	ATTRIBUTE13
	,	ATTRIBUTE14
	,	ATTRIBUTE15
        ,       customer_class_code
	FROM	SO_DISCOUNT_CUSTOMERS
	WHERE	DISCOUNT_ID = source_id;

	return_status := 0;	--success
	msg_text := 'OEXCPDST: success';

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        return_status   := SQLCODE;
        msg_text        := 'OEXCPDST:' || SUBSTR(SQLERRM, 1, 70) || actbuf;

    WHEN OTHERS THEN
        return_status   := SQLCODE;
        msg_text        := 'OEXCPDST:' || SUBSTR(SQLERRM, 1, 70) || actbuf;
END;

END OEXCPDST;

/
