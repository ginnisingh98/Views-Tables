--------------------------------------------------------
--  DDL for Package Body CCT_DEFAULT_LOOKUP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CCT_DEFAULT_LOOKUP_PUB" as
/* $Header: cctdefcb.pls 120.0 2005/06/02 10:04:29 appldev noship $ */

/*------------------------------------------------------------------------
REM  Group : Customer Initialization Phase
REM  Get Customer/PartyID from any one of the following Objects if available
REM  ANI                  --occtANI
REM  PARTY_NUMBER         --PartyNumber
REM  QUOTE_NUMBER         --QuoteNum
REM  ORDER_NUMBER         --OrderNum
REM  COLLATERAL_REQUEST   --CollateralReq
REM  ACCOUNT_NUMBER       --AccountNum
REM  EVENT_REGISTRATION_CODE --EventCode
REM  MARKETING_PIN        --MarketingPin
REM  SERVICE_KEY            --ServiceKey
REM  SERVICE_REQUEST_NUMBER --ServiceRequestNum
REM
REM  using an api provided by Telesales team
REM
REM-----------------------------------------------------------------------*/

Function GetData(x_key_value_varr IN OUT NOCOPY CCT_KEYVALUE_VARR)
Return Varchar2
IS
     p_cct_object_type_1 VARCHAR2(255):=CCT_INTERACTIONKEYS_PUB.KEY_SERVICE_REQUEST_NUMBER;
	p_cct_object_type_2 VARCHAR2(255):=CCT_INTERACTIONKEYS_PUB.KEY_PARTY_NUMBER;
	p_cct_object_type_3 VARCHAR2(255):=CCT_INTERACTIONKEYS_PUB.KEY_QUOTE_NUMBER;
	p_cct_object_type_4 VARCHAR2(255):=CCT_INTERACTIONKEYS_PUB.KEY_ORDER_NUMBER;
	p_cct_object_type_5 VARCHAR2(255):=CCT_INTERACTIONKEYS_PUB.KEY_COLLATERAL_REQUEST_NUMBER ;
	p_cct_object_type_6 VARCHAR2(255):=CCT_INTERACTIONKEYS_PUB.KEY_ACCOUNT_NUMBER;
	p_cct_object_type_7 VARCHAR2(255):=CCT_INTERACTIONKEYS_PUB.KEY_EVENT_REGISTRATION_CODE;
	p_cct_object_type_8 VARCHAR2(255):=CCT_INTERACTIONKEYS_PUB.KEY_MARKETING_PIN ;
	p_cct_object_type_9 VARCHAR2(255):=CCT_INTERACTIONKEYS_PUB.KEY_SERVICE_KEY;
	p_cct_object_type_10 VARCHAR2(255):=CCT_INTERACTIONKEYS_PUB.KEY_ANI;


	p_result VARCHAR2(1):='N';
	p_tmp_result VARCHAR2(4000):='N';
	p_object_type VARCHAR2(255);
	p_object_value VARCHAR2(255);
	p_cct_party_id_Key VARCHAR2(255):=CCT_INTERACTIONKEYS_PUB.KEY_CUSTOMER_ID;
	p_cct_party_name_key VARCHAR2(255):=CCT_INTERACTIONKEYS_PUB.KEY_CUSTOMER_NAME;
	p_party_id     NUMBER;
	p_party_name   VARCHAR2(255);
Begin
	-- Check if Customer_ID is already present in incoming request. If yes call getPartyForObject
	-- and retrieve CustomerName for that ID. If no CustomerName can be found then re-try using
	-- above KEYs.

    p_object_value:=cct_collection_util_pub.get(x_key_value_varr,p_cct_party_id_Key,p_result);
    if(p_result='Y') then
    	p_object_type:=p_cct_party_id_Key;
     AST_ROUTING_PUB.getPartyForObject(p_object_type,p_object_value,p_party_name,p_party_id);
     If ((p_party_id<>AST_ROUTING_PUB.G_NO_PARTY) AND (p_party_id<>AST_ROUTING_PUB.G_MULTIPLE_PARTY)) THEN
       p_tmp_result:=CCT_collection_util_pub.put(x_key_value_varr,p_cct_party_name_key,p_party_name);
       p_result:='Y';
       return p_result;
     END IF;
     --dbms_output.put_line('@Start : Value of key '||p_object_type||' and value '||p_object_value);

    end if;

    p_object_value:=cct_collection_util_pub.get(x_key_value_varr,p_cct_object_type_1,p_result);
    if(p_result='Y') then
    	p_object_type:=p_cct_object_type_1;
    	goto EXECUTE_API;
    end if;
    p_object_value:=cct_collection_util_pub.get(x_key_value_varr,p_cct_object_type_2,p_result);
    if(p_result='Y') then
    	p_object_type:=p_cct_object_type_2;
    	goto EXECUTE_API;
    end if;
    p_object_value:=cct_collection_util_pub.get(x_key_value_varr,p_cct_object_type_3,p_result);
    if(p_result='Y') then
    	p_object_type:=p_cct_object_type_3;
    	goto EXECUTE_API;
    end if;
    p_object_value:=cct_collection_util_pub.get(x_key_value_varr,p_cct_object_type_4,p_result);
    if(p_result='Y') then
    	p_object_type:=p_cct_object_type_4;
    	goto EXECUTE_API;
    end if;
    p_object_value:=cct_collection_util_pub.get(x_key_value_varr,p_cct_object_type_5,p_result);
    if(p_result='Y') then
    	p_object_type:=p_cct_object_type_5;
    	goto EXECUTE_API;
    end if;
    p_object_value:=cct_collection_util_pub.get(x_key_value_varr,p_cct_object_type_6,p_result);
    if(p_result='Y') then
    	p_object_type:=p_cct_object_type_6;
    	goto EXECUTE_API;
    end if;
    p_object_value:=cct_collection_util_pub.get(x_key_value_varr,p_cct_object_type_7,p_result);
    if(p_result='Y') then
    	p_object_type:=p_cct_object_type_7;
    	goto EXECUTE_API;
    end if;
    p_object_value:=cct_collection_util_pub.get(x_key_value_varr,p_cct_object_type_8,p_result);
    if(p_result='Y') then
    	p_object_type:=p_cct_object_type_8;
    	goto EXECUTE_API;
    end if;
    p_object_value:=cct_collection_util_pub.get(x_key_value_varr,p_cct_object_type_9,p_result);
    if(p_result='Y') then
    	p_object_type:=p_cct_object_type_9;
    	goto EXECUTE_API;
    end if;
    p_object_value:=cct_collection_util_pub.get(x_key_value_varr,p_cct_object_type_10,p_result);
    if(p_result='Y') then
    	p_object_type:=p_cct_object_type_10;
    	goto EXECUTE_API;
    end if;



<<EXECUTE_API>>
    AST_ROUTING_PUB.getPartyForObject(p_object_type,p_object_value,p_party_name,p_party_id);
   	If ((p_party_id<>AST_ROUTING_PUB.G_NO_PARTY) AND (p_party_id<>AST_ROUTING_PUB.G_MULTIPLE_PARTY)) THEN
   	    p_tmp_result:=CCT_collection_util_pub.put(x_key_value_varr,p_cct_party_id_key,to_char(p_party_id));
   	    p_tmp_result:=CCT_collection_util_pub.put(x_key_value_varr,p_cct_party_name_key,p_party_name);
   	END IF;
	--dbms_output.put_line('Value of key '||p_object_type||' and value '||p_object_value);
	--dbms_output.put_line('Value of partyName '||p_party_name||' and p_party_id '||p_party_id);
     -- Everything succeeded, so mark the operation as success and return it
   	p_result:='Y';
	return p_result;
EXCEPTION
    WHEN OTHERS THEN
        p_result:='N';
	--dbms_output.put_line('Exception : Value of key '||p_object_type||' and value '||p_object_value);
        return p_result;
END;

END CCT_Default_Lookup_PUB;

/
