--------------------------------------------------------
--  DDL for Package Body CS_LIST_PRICE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_LIST_PRICE_PKG" as
/* $Header: csxlistb.pls 115.1 99/07/16 09:08:25 porting ship  $ */

PROCEDURE  call_fetch_list_price (
		p_inventory_item_id	IN 	NUMBER,
 		p_price_list_id		IN 	NUMBER,
 		p_unit_code		IN 	VARCHAR2,
 		p_service_duration	IN 	NUMBER,
 		p_item_Type_code	IN 	VARCHAR2 ,
 		p_pricing_attribute1	IN 	VARCHAR2 ,
 		p_pricing_attribute2	IN 	VARCHAR2 ,
 		p_pricing_attribute3	IN 	VARCHAR2 ,
 		p_pricing_attribute4	IN 	VARCHAR2 ,
 		p_pricing_attribute5	IN 	VARCHAR2 ,
 		p_pricing_attribute6	IN 	VARCHAR2 ,
 		p_pricing_attribute7	IN 	VARCHAR2 ,
 		p_pricing_attribute8	IN 	VARCHAR2 ,
 		p_pricing_attribute9	IN 	VARCHAR2 ,
 		p_pricing_attribute10	IN 	VARCHAR2 ,
 		p_pricing_attribute11	IN 	VARCHAR2 ,
 		p_pricing_attribute12	IN 	VARCHAR2 ,
 		p_pricing_attribute13	IN 	VARCHAR2 ,
 		p_pricing_attribute14	IN 	VARCHAR2 ,
 		p_pricing_attribute15	IN 	VARCHAR2 ,
		p_base_price		IN 	NUMBER ,
		p_price_list_id_out	OUT 	NUMBER ,
		p_prc_method_code_out	OUT 	VARCHAR2 ,
		p_list_price		OUT 	NUMBER ,
		p_list_percent		OUT 	NUMBER ,
		p_rounding_factor	OUT 	NUMBER ,
		p_error_flag		OUT 	VARCHAR2 ,
		p_error_message		OUT 	VARCHAR2
	 ) IS

	G_PRC_LST_DEF_ATTEMPTS  CONSTANT NUMBER := 2;

	l_api_version_number 	NUMBER;
	l_fetch_attempts 		NUMBER;
 	l_init_msg_list    		VARCHAR2(1);
 	l_validation_level    	NUMBER;
	l_return_status    		VARCHAR2(1);
	l_msg_count			NUMBER;
	l_msg_data			VARCHAR2(2000);
 	l_prc_method_code		VARCHAR2(4);
	l_error_message		VARCHAR2(2000);

 BEGIN
	/* This should be changed whenever the api version changes */
	l_api_version_number 		:= 1.0;

	/* Initialize the message list */
 	l_init_msg_list    			:= FND_API.G_FALSE;



 	l_validation_level    		:= FND_API.G_VALID_LEVEL_FULL;
 	l_fetch_attempts    		:= G_PRC_LST_DEF_ATTEMPTS;


	/* Method code in so_price_list_lines can be either amount based or */
	/* percentage based . */

	SELECT DISTINCT METHOD_CODE
	INTO  l_prc_method_code
	FROM  so_price_list_lines
	WHERE Price_List_Id = p_price_list_id
     AND   Inventory_Item_Id = p_inventory_item_id
	AND   Unit_Code  = p_unit_Code;

	--DBMS_Output.Put_Line('Calling Fetch_List_Price. ');
	--DBMS_Output.Put_Line('Values passed are :');
	--DBMS_Output.Put_Line('Version No.='||to_char(l_api_version_number));
	--DBMS_Output.Put_Line('Init Msg. List='|| l_init_msg_list);
	--DBMS_Output.Put_Line('Return Status=' || l_return_status);


 	/* Call Fetch_Price_List. */
  	OE_PRICE_LIST_PVT.FETCH_LIST_PRICE
			(l_api_version_number  ,
     		 l_init_msg_list       ,
	           l_validation_level    ,
     		 l_return_status       ,
     		 l_msg_count           ,
     		 l_msg_data            ,
     		 p_price_list_id       ,
     		 p_inventory_item_id   ,
			 p_unit_code	        ,
			 p_service_duration    ,
			 p_item_type_code      ,
			 l_prc_method_code     ,
			 p_pricing_attribute1  ,
			 p_pricing_attribute2  ,
			 p_pricing_attribute3  ,
			 p_pricing_attribute4  ,
			 p_pricing_attribute5  ,
			 p_pricing_attribute6  ,
			 p_pricing_attribute7  ,
			 p_pricing_attribute8  ,
			 p_pricing_attribute9  ,
			 p_pricing_attribute10  ,
			 p_pricing_attribute11  ,
			 p_pricing_attribute12  ,
			 p_pricing_attribute13  ,
			 p_pricing_attribute14  ,
			 p_pricing_attribute15  ,
			 p_base_price  ,
			 l_fetch_attempts  ,
			 p_price_list_id_out  ,
			 p_prc_method_code_out  ,
			 p_list_price  ,
			 p_list_percent  ,
			 p_rounding_factor
     				);


 	IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
		p_error_flag := 'Y';
	ELSE
		p_error_flag := 'N';
	END IF;

	l_error_message := NULL ;
	/** Check if there are any warnings passed from the Pricing API. **/
	IF (l_msg_count >= 1) THEN
     		FOR I IN 1..l_msg_count LOOP
 			l_msg_data := FND_MSG_PUB.Get(p_msg_index => I,
 					p_encoded     => FND_API.G_FALSE);
		 	l_error_message := l_error_message || to_char(i);
		 	l_error_message := l_error_message || l_msg_data;
     		END LOOP;
	END IF ;

	FND_MSG_PUB.Delete_Msg ;

   END call_fetch_list_price ;

END cs_list_price_pkg;

/
