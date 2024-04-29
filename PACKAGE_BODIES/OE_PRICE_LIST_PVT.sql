--------------------------------------------------------
--  DDL for Package Body OE_PRICE_LIST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_PRICE_LIST_PVT" AS
/* $Header: OEXVLSTB.pls 115.1 99/07/16 08:17:02 porting shi $ */

--  Global constant holding the package  name to be used by
--  messaging routines in the case of an unexpected error.

G_PKG_NAME  	CONSTANT    VARCHAR2(30):='OE_Price_List_PVT';

--  This global variable is used to keep count of the fetch level that
--  is currently executed. It is used to decide whether to put a message
--  indicating that no list price was found for the item on the price
--  list. The requirement is to add this message for the primary price
--  list only.

G_Fetch_Level	    NUMBER := 0;

--  Utility function called by Fetch)List_Price API.

FUNCTION    Get_Sec_Price_List
(   p_price_list_id	IN  NUMBER  )
RETURN NUMBER;

FUNCTION    Get_Price_List_Name
(   p_price_list_id	IN  NUMBER  )
RETURN VARCHAR2;

FUNCTION    Get_Item_Description
(   p_item_id	IN  NUMBER  )
RETURN VARCHAR2;

FUNCTION    Get_Unit_Name
(   p_unit_code	IN  VARCHAR2 )
RETURN VARCHAR2;

--  Fetch List price API.

PROCEDURE Fetch_List_Price
( p_api_version_number	IN  NUMBER	    	    	    	    	,
  p_init_msg_list	IN  VARCHAR2    := FND_API.G_FALSE		,
  p_validation_level	IN  NUMBER	:= FND_API.G_VALID_LEVEL_FULL	,
  p_return_status   	OUT VARCHAR2					,
  p_msg_count		OUT NUMBER					,
  p_msg_data		OUT VARCHAR2					,
  p_price_list_id	IN  NUMBER	:= NULL				,
  p_inventory_item_id	IN  NUMBER	:= NULL				,
  p_unit_code		IN  VARCHAR2	:= NULL				,
  p_service_duration	IN  NUMBER	:= NULL				,
  p_item_type_code	IN  VARCHAR2	:= NULL				,
  p_prc_method_code	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute1	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute2	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute3	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute4	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute5	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute6	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute7	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute8	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute9	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute10	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute11	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute12	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute13	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute14	IN  VARCHAR2	:= NULL				,
  p_pricing_attribute15	IN  VARCHAR2	:= NULL				,
  p_base_price		IN  NUMBER	:= NULL				,
  p_fetch_attempts	IN  NUMBER	:= G_PRC_LST_DEF_ATTEMPTS	,
  p_price_list_id_out	    OUT	NUMBER					,
  p_prc_method_code_out	    OUT	VARCHAR2				,
  p_list_price		    OUT	NUMBER					,
  p_list_percent	    OUT	NUMBER					,
  p_rounding_factor	    OUT	NUMBER
)
IS
    l_api_version_number    CONSTANT    NUMBER  	:=  1.0;
    l_api_name  	    CONSTANT    VARCHAR2(30):=  'Fetch_List_Price';
    l_return_status	    VARCHAR2(1);
    l_fetch_attempts	    NUMBER	    := p_fetch_attempts;
    l_validation_error	    BOOLEAN	    := FALSE;
    l_prc_method_code       VARCHAR2(4)	    :=	p_prc_method_code	;
    l_price_list_id		NUMBER	    :=	p_price_list_id		;
    l_prc_method_code_out	VARCHAR2(4) :=	NULL	;
    l_list_price		NUMBER	    :=	NULL	;
    l_list_percent	    	NUMBER	    :=	NULL	;
    l_rounding_factor	    	NUMBER	    :=	NULL	;
BEGIN

    --  Standard call to check for call compatibility

    IF NOT FND_API.Compatible_API_Call
    (	l_api_version_number,
        p_api_version_number,
	l_api_name	    ,
	G_PKG_NAME	    )
    THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --  Initialize message list if p_init_msg_list is set to TRUE

    IF FND_API.to_Boolean(p_init_msg_list)  THEN

 	    FND_MSG_PUB.initialize;

    END IF;

    --  Initialize p_return_status

    p_return_status := FND_API.G_RET_STS_SUCCESS;

    --	Validate Input. Start with mandatory validation.

    --  Fetch_attempts can not be greater that max attempts allowed

    IF p_fetch_attempts > G_PRC_LST_MAX_ATTEMPTS THEN

	l_validation_error := TRUE;

	FND_MESSAGE.SET_NAME('OE','OE_PRC_LIST_INVALID_FETCH_ATTEMPTS');
	FND_MESSAGE.SET_TOKEN('PASSED_FETCH_ATTEMPTS',p_fetch_attempts);
	FND_MESSAGE.SET_TOKEN('MAX_FETCH_ATTEMPTS',G_PRC_LST_MAX_ATTEMPTS);
	FND_MSG_PUB.Add;

    END IF;

    --	Validation that can be turned off through the use of
    --	validation level.

    IF p_validation_level = FND_API.G_VALID_LEVEL_FULL THEN

	--  Validate :
	--	price_list_id
	--	item_id
	--	unit_code
	--	item_type_code
	--	fetch_attempts
	--  This code needs to be added in the future if we provide a
	--  public API.

	NULL;

    END IF;

    IF l_validation_error THEN
	RAISE FND_API.G_EXC_ERROR;
    END IF;

    --	Check required parameters.

    IF  p_price_list_id IS NULL
    OR  p_inventory_item_id IS NULL
    OR  p_unit_code IS NULL
    THEN
	RETURN;
    END IF;

    --	Set the G_Fetch_level. Since this API calls itself
    --	recursively, this variable indicates the call level. It is
    --	used forward on.

    G_Fetch_Level := G_Fetch_Level + 1;

    --	Fetch list price.

    --	There are two fetch statements :
    --	    1.	General statement that drives on item id.
    --	    2.	Special case for Oracle USA where we drive on item_id
    --		and pricing_attribute2
    --		In case a customer doesn't have an index on
    --		PRICING_ATTRIBUTE2, it shouldn't be aproblem because
    --		the statement will still drive on item_id.
    --
    --	The ROWNUM = 1 condition is to accomodate the case where there
    --	is more than one active price list line that meets the select
    --	criteria. Inherited from release 9.


    --	Block encapsulating the fetch statements to handle the case
    --	where no rows are found. The reason it is not handled in the
    --	API exception handler, is that the handler itself may raise
    --	exceptions that should be handled by the API exception
    --	handler.  are no rows.

    BEGIN

    IF p_pricing_attribute2 IS NULL THEN

	--  Debug info
/*
	FND_MSG_PUB.Add_Exc_Msg
	(   p_error_text    =>	'pricing_attribute2 is null' );
*/
	--  Fecth driving on item_id

	SELECT	/*+ ordered use_nl(OELST OELIN)
                    index(OELST SO_PRICE_LISTS_U1)
                    index(OELIN SO_PRICE_LIST_LINES_N1) */
		OELST.ROUNDING_FACTOR
	,	OELIN.METHOD_CODE
	,	OELIN.LIST_PRICE
	INTO
		l_rounding_factor
	,	l_prc_method_code_out
	,	l_list_price
	FROM	SO_PRICE_LISTS OELST
        ,	SO_PRICE_LIST_LINES OELIN
	WHERE	OELIN.INVENTORY_ITEM_ID = p_inventory_item_id
	AND	OELIN.UNIT_CODE = p_unit_code
	AND	OELIN.METHOD_CODE =
		 NVL( l_prc_method_code, OELIN.METHOD_CODE )
	AND	TRUNC(SYSDATE)
                BETWEEN NVL( OELIN.START_DATE_ACTIVE, TRUNC(SYSDATE) )
		AND     NVL( OELIN.END_DATE_ACTIVE, TRUNC(SYSDATE) )
	AND	NVL( OELIN.PRICING_ATTRIBUTE1, ' ' ) =
		NVL( p_pricing_attribute1, ' ' )
	AND	NVL( OELIN.PRICING_ATTRIBUTE2, ' ' ) =
		NVL( p_pricing_attribute2, ' ' )
	AND	NVL( OELIN.PRICING_ATTRIBUTE3, ' ' ) =
		NVL( p_pricing_attribute3, ' ' )
	AND	NVL( OELIN.PRICING_ATTRIBUTE4, ' ' ) =
		NVL( p_pricing_attribute4, ' ' )
	AND	NVL( OELIN.PRICING_ATTRIBUTE5, ' ' ) =
		NVL( p_pricing_attribute5, ' ' )
	AND	NVL( OELIN.PRICING_ATTRIBUTE6, ' ' ) =
		NVL( p_pricing_attribute6, ' ' )
	AND	NVL( OELIN.PRICING_ATTRIBUTE7, ' ' ) =
		NVL( p_pricing_attribute7, ' ' )
	AND	NVL( OELIN.PRICING_ATTRIBUTE8, ' ' ) =
		NVL( p_pricing_attribute8, ' ' )
	AND	NVL( OELIN.PRICING_ATTRIBUTE9, ' ' ) =
		NVL( p_pricing_attribute9, ' ' )
	AND	NVL( OELIN.PRICING_ATTRIBUTE10, ' ' ) =
		NVL( p_pricing_attribute10, ' ' )
	AND	NVL( OELIN.PRICING_ATTRIBUTE11, ' ' ) =
		NVL( p_pricing_attribute11, ' ' )
	AND	NVL( OELIN.PRICING_ATTRIBUTE12, ' ' ) =
		NVL( p_pricing_attribute12, ' ' )
	AND	NVL( OELIN.PRICING_ATTRIBUTE13, ' ' ) =
		NVL( p_pricing_attribute13, ' ' )
	AND	NVL( OELIN.PRICING_ATTRIBUTE14, ' ' ) =
		NVL( p_pricing_attribute14, ' ' )
	AND	NVL( OELIN.PRICING_ATTRIBUTE15, ' ' ) =
		NVL( p_pricing_attribute15, ' ' )
	AND	OELST.PRICE_LIST_ID = p_price_list_id
	AND	TRUNC(SYSDATE)
		BETWEEN NVL( OELST.START_DATE_ACTIVE, TRUNC(SYSDATE) )
		AND     NVL( OELST.END_DATE_ACTIVE, TRUNC(SYSDATE) )
	AND	OELST.PRICE_LIST_ID = OELIN.PRICE_LIST_ID
	AND	ROWNUM = 1;

    ELSE

	--  Fetch driving on p_pricing_attribute2

	SELECT	/*+ ordered use_nl(OELST OELIN)
                    index(OELST SO_PRICE_LISTS_U1)
                    index(OELIN SO_PRICE_LIST_LINES_N1) */
		OELST.ROUNDING_FACTOR
	,	OELIN.METHOD_CODE
	,	OELIN.LIST_PRICE
	INTO
		l_rounding_factor
	,	l_prc_method_code_out
	,	l_list_price
	FROM	SO_PRICE_LISTS OELST
        ,	SO_PRICE_LIST_LINES OELIN
	WHERE	OELIN.INVENTORY_ITEM_ID = p_inventory_item_id
	AND	OELIN.UNIT_CODE = p_unit_code
	AND	OELIN.METHOD_CODE =
		 NVL( l_prc_method_code, OELIN.METHOD_CODE )
	AND	TRUNC(SYSDATE)
                BETWEEN NVL( OELIN.START_DATE_ACTIVE, TRUNC(SYSDATE) )
		AND     NVL( OELIN.END_DATE_ACTIVE, TRUNC(SYSDATE) )
	AND	NVL( OELIN.PRICING_ATTRIBUTE1, ' ' ) =
		NVL( p_pricing_attribute1, ' ' )
	AND	OELIN.PRICING_ATTRIBUTE2 = p_pricing_attribute2
	AND	NVL( OELIN.PRICING_ATTRIBUTE3, ' ' ) =
		NVL( p_pricing_attribute3, ' ' )
	AND	NVL( OELIN.PRICING_ATTRIBUTE4, ' ' ) =
		NVL( p_pricing_attribute4, ' ' )
	AND	NVL( OELIN.PRICING_ATTRIBUTE5, ' ' ) =
		NVL( p_pricing_attribute5, ' ' )
	AND	NVL( OELIN.PRICING_ATTRIBUTE6, ' ' ) =
		NVL( p_pricing_attribute6, ' ' )
	AND	NVL( OELIN.PRICING_ATTRIBUTE7, ' ' ) =
		NVL( p_pricing_attribute7, ' ' )
	AND	NVL( OELIN.PRICING_ATTRIBUTE8, ' ' ) =
		NVL( p_pricing_attribute8, ' ' )
	AND	NVL( OELIN.PRICING_ATTRIBUTE9, ' ' ) =
		NVL( p_pricing_attribute9, ' ' )
	AND	NVL( OELIN.PRICING_ATTRIBUTE10, ' ' ) =
		NVL( p_pricing_attribute10, ' ' )
	AND	NVL( OELIN.PRICING_ATTRIBUTE11, ' ' ) =
		NVL( p_pricing_attribute11, ' ' )
	AND	NVL( OELIN.PRICING_ATTRIBUTE12, ' ' ) =
		NVL( p_pricing_attribute12, ' ' )
	AND	NVL( OELIN.PRICING_ATTRIBUTE13, ' ' ) =
		NVL( p_pricing_attribute13, ' ' )
	AND	NVL( OELIN.PRICING_ATTRIBUTE14, ' ' ) =
		NVL( p_pricing_attribute14, ' ' )
	AND	NVL( OELIN.PRICING_ATTRIBUTE15, ' ' ) =
		NVL( p_pricing_attribute15, ' ' )
	AND	OELST.PRICE_LIST_ID = p_price_list_id
	AND	TRUNC(SYSDATE)
		BETWEEN NVL( OELST.START_DATE_ACTIVE, TRUNC(SYSDATE) )
		AND     NVL( OELST.END_DATE_ACTIVE, TRUNC(SYSDATE) )
	AND	OELST.PRICE_LIST_ID = OELIN.PRICE_LIST_ID
	AND	ROWNUM = 1;

    END IF;

    IF l_list_price IS NULL THEN

	--  No list price found, clear OUT parameters.

	p_price_list_id_out	    :=  NULL;
	p_prc_method_code_out	    :=  NULL;
	p_list_price		    :=  NULL;
	p_list_percent		    :=  NULL;
	p_rounding_factor	    :=  NULL;

    ELSE

	--  Debug info
/*
	FND_MSG_PUB.Add_Exc_Msg
	(   p_error_text    =>	'list price is not null - '||
	    ' list_price = '||l_list_price||
	    ' l_prc_method_code = '||l_prc_method_code_out||
	    ' l_rounding_factor = '||l_rounding_factor
	 );
*/
	--  Calculate list price.

	IF l_prc_method_code_out = G_PRC_METHOD_AMOUNT THEN

	    l_list_price := ROUND ( l_list_price , - l_rounding_factor );
	    l_list_percent := NULL ;

	ELSIF l_prc_method_code_out = G_PRC_METHOD_PERCENT THEN

	    --	List percent is the selected list price

	    l_list_percent := l_list_price ;

	    IF	p_base_price IS NULL
	    THEN

		--  No base price

		l_list_price := NULL ;

	    ELSE

		l_list_price := l_list_percent * p_base_price / 100 ;

		IF p_item_type_code = G_PRC_ITEM_SERVICE THEN

		    l_list_price := l_list_price * p_service_duration ;

		END IF;

		l_list_price := ROUND ( l_list_price , l_rounding_factor );

	    END IF;

	ELSE

	    --	Unexpected error, invalid pricing method

	    IF	FND_MSG_PUB.Check_Msg_Level (
		FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	    THEN

		FND_MSG_PUB.Add_Exc_Msg
		(   G_PKG_NAME  	    ,
		    l_api_name    	    ,
		    'Invalid pricing method ='||l_prc_method_code_out
		);

	    END IF;

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

	END IF; -- prc_method_code

	p_price_list_id_out	    :=	p_price_list_id		    ;
	p_prc_method_code_out	    :=	l_prc_method_code_out	    ;
	p_list_price		    :=	l_list_price		    ;
	p_list_percent		    :=	l_list_percent		    ;
	p_rounding_factor	    :=	l_rounding_factor	    ;

    END IF; --	There is a list price

    EXCEPTION

	WHEN NO_DATA_FOUND THEN

	--  Debug info
/*
	FND_MSG_PUB.Add_Exc_Msg
	(   p_error_text    =>	'Primary fetch not successful' );
*/
	    --  Check if the maximum number of attempts has been
	    --	exceeded. When l_fetch attempts is 1 this means there
	    --	should be no more fetch attempts, else, look for a
	    --	secondary list.

	    IF l_fetch_attempts > 1 THEN

		l_fetch_attempts := l_fetch_attempts - 1;

		--  Get secondary_price_list_id

		l_price_list_id :=  Get_Sec_Price_List ( p_price_list_id );

		IF l_price_list_id IS NOT NULL THEN

		    --	Call Fetch_List_Price using the sec list.

		    Fetch_List_Price
		    ( 	p_api_version_number	    ,
                        FND_API.G_FALSE		    ,
			FND_API.G_VALID_LEVEL_NONE  ,
			l_return_status		    ,
                        p_msg_count		    ,
   			p_msg_data		    ,
		        l_price_list_id		    ,
		      	p_inventory_item_id	    ,
		      	p_unit_code		    ,
		        p_service_duration	    ,
		        p_item_type_code	    ,
		      	p_prc_method_code	    ,
		      	p_pricing_attribute1	    ,
		      	p_pricing_attribute2	    ,
		      	p_pricing_attribute3	    ,
			p_pricing_attribute4	    ,
			p_pricing_attribute5	    ,
		      	p_pricing_attribute6	    ,
		      	p_pricing_attribute7	    ,
		      	p_pricing_attribute8	    ,
		      	p_pricing_attribute9	    ,
		      	p_pricing_attribute10	    ,
		      	p_pricing_attribute11	    ,
		      	p_pricing_attribute12	    ,
		      	p_pricing_attribute13	    ,
		      	p_pricing_attribute14	    ,
			p_pricing_attribute15	    ,
			p_base_price		    ,
			l_fetch_attempts	    ,
		      	p_price_list_id_out	    ,
		      	p_prc_method_code_out	    ,
		      	l_list_price		    ,
		     	p_list_percent		    ,
		     	p_rounding_factor
		    );

		    IF  l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

                        -- Unexpected error, abort processing
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

		    ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

                        -- Error, abort processing
                        RAISE FND_API.G_EXC_ERROR;

		    ELSE

			--  Set p_list_price. We don't receive the
			--  list price in p_list_price because we need
			--  to check its value after the call.

			p_list_price := l_list_price ;

		    END IF;

		END IF; --  There was a secondary price list.

	    END IF; -- fetch_attempts > 1

	WHEN OTHERS THEN

	    -- Unexpected error

	    IF	FND_MSG_PUB.Check_Msg_Level(
		FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	    THEN

		FND_MSG_PUB.Add_Exc_Msg
		(   G_PKG_NAME  	    ,
		    l_api_name
		);

	    END IF;

	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END; -- BEGIN select list price block.

    --	At this point, All processing is done, and all the secondary
    --	fetches have been performed.

    --	If list_price is NULL and the fetch level =1 meaning that this
    --	is the execution coresponding to the primary fetch. Then add an
    --	informational message to inform the caller that the item was
    --	not found o the price list.

	--  Debug info
/*
	FND_MSG_PUB.Add_Exc_Msg
	(   p_error_text    =>	'End of Fetch_List_Price - '||
	    ' l_list_price = '||l_list_price||
	    ' G_Fetch_Level = '||G_Fetch_Level
	);
*/

    IF	l_list_price IS NULL AND
	G_Fetch_Level = 1
    THEN

	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS)
	THEN

	    FND_MESSAGE.SET_NAME('OE','OE_PRC_NO_LIST_PRICE');
	    FND_MESSAGE.SET_TOKEN('PRICE_LIST',	Get_Price_List_Name
						(p_price_list_id) );
	    FND_MESSAGE.SET_TOKEN('ITEM',   Get_Item_Description
					    (p_inventory_item_id) );
	    FND_MESSAGE.SET_TOKEN('UNTI',Get_Unit_Name (p_unit_code ));
	    FND_MSG_PUB.Add;

	 END IF;

    END IF;

    --  Decement G_Fetch_Level

    G_Fetch_Level := G_Fetch_Level - 1;

    -- Get message count and if 1, return message data

    FND_MSG_PUB.Count_And_Get
    (   p_count =>  p_msg_count	,
	p_data  =>  p_msg_data
    );


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

    	p_return_status := FND_API.G_RET_STS_ERROR;

        -- Get message count and if 1, return message data

        FND_MSG_PUB.Count_And_Get
            (p_count => p_msg_count,
             p_data  => p_msg_data
        );

	--  Decement G_Fetch_Level

	G_Fetch_Level := G_Fetch_Level - 1;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    	p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        -- Get message count and if 1, return message data

        FND_MSG_PUB.Count_And_Get
            (p_count => p_msg_count,
             p_data  => p_msg_data
        );

	--  Decement G_Fetch_Level

	G_Fetch_Level := G_Fetch_Level - 1;

    WHEN OTHERS THEN

    	p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    	IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
    	    FND_MSG_PUB.Add_Exc_Msg
    	    (	G_PKG_NAME  	    ,
    	    	l_api_name
	    );
    	END IF;

        -- Get message count and if 1, return message data

        FND_MSG_PUB.Count_And_Get
        (   p_count => p_msg_count,
            p_data  => p_msg_data
        );

	--  Decement G_Fetch_Level

	G_Fetch_Level := G_Fetch_Level - 1;

END; -- Fetch_List_Price

--  Utility function called by Fetch)List_Price API.

FUNCTION    Get_Sec_Price_List
(   p_price_list_id	IN  NUMBER  )
RETURN NUMBER
IS
l_sec_price_list_id	NUMBER := NULL;
BEGIN

    IF p_price_list_id IS NULL THEN
	RETURN NULL;
    END IF;

    SELECT	SECONDARY_PRICE_LIST_ID
    INTO	l_sec_price_list_id
    FROM	SO_PRICE_LISTS
    WHERE	PRICE_LIST_ID = p_price_list_id;

    RETURN l_sec_price_list_id;

EXCEPTION

    WHEN OTHERS THEN

	FND_MSG_PUB.Add_Exc_Msg
	(   G_PKG_NAME  	    ,
	    'Get_Sec_Price_List - p_price_list_id = '||p_price_list_id
	);

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Sec_Price_List;

FUNCTION    Get_Price_List_Name
(   p_price_list_id	IN  NUMBER  )
RETURN VARCHAR2
IS
l_name	VARCHAR2(80) := NULL;
BEGIN

    IF p_price_list_id IS NULL THEN
	RETURN NULL;
    END IF;

    SELECT	NAME
    INTO	l_name
    FROM	SO_PRICE_LISTS
    WHERE	PRICE_LIST_ID = p_price_list_id;

    RETURN l_name;

EXCEPTION

    WHEN OTHERS THEN

	FND_MSG_PUB.Add_Exc_Msg
	(   G_PKG_NAME  	    ,
	    'Get_Price_List_Name - p_price_list_id = '||p_price_list_id
	);

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Price_List_Name;

FUNCTION    Get_Item_Description
(   p_item_id	IN  NUMBER  )
RETURN VARCHAR2
IS
l_desc	    VARCHAR2(240)   := NULL;
l_org_id    NUMBER	    := NULL;
BEGIN

    l_org_id := FND_PROFILE.VALUE ('SO_ORGANIZATION_ID');

    IF	p_item_id IS NULL OR
	l_org_id IS NULL
    THEN
	RETURN NULL;
    END IF;

    SELECT  DESCRIPTION
    INTO    l_desc
    FROM    MTL_SYSTEM_ITEMS
    WHERE   INVENTORY_ITEM_ID = p_item_id
    AND	    ORGANIZATION_ID = l_org_id;

    RETURN l_desc;

EXCEPTION

    WHEN OTHERS THEN

	FND_MSG_PUB.Add_Exc_Msg
	(   G_PKG_NAME  	    ,
	    'Get_Item_Description - p_item_id = '||p_item_id||
	    ' org_id ='||l_org_id
	);

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Item_Description;

FUNCTION    Get_Unit_Name
(   p_unit_code	IN  VARCHAR2 )
RETURN VARCHAR2
IS
l_name	VARCHAR2(80) := NULL;
BEGIN

    IF p_unit_code IS NULL THEN
	RETURN NULL;
    END IF;

    SELECT  UNIT_OF_MEASURE
    INTO    l_name
    FROM    MTL_UNITS_OF_MEASURE
    WHERE   UOM_CODE = p_unit_code;

    RETURN l_name;

EXCEPTION

    WHEN OTHERS THEN

	FND_MSG_PUB.Add_Exc_Msg
	(   G_PKG_NAME  	    ,
	    'Get_Unit_Name - p_unit_code  = '||p_unit_code
	);

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Get_Unit_Name;

END OE_Price_List_PVT;


/
