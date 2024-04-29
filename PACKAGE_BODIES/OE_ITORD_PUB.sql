--------------------------------------------------------
--  DDL for Package Body OE_ITORD_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_ITORD_PUB" AS
/* $Header: OEXPITOB.pls 120.1 2008/01/24 08:37:30 smanian noship $ */


G_PKG_NAME    CONSTANT       VARCHAR2(30) := 'OE_ITORD_PUB';

/* This procedure shall be called by custom programs to import item orderability rules into OM */

Procedure Import_Item_orderability_rules ( p_Item_Orderability_Import_Tbl IN OUT NOCOPY OE_ITORD_PUB.Item_Orderability_Import_Tbl
					   , p_commit_flag IN VARCHAR2 DEFAULT 'N') IS
l_debug_level NUMBER := oe_debug_pub.g_debug_level;
begin


IF l_debug_level > 0 then
	oe_debug_pub.add('Entering OE_ITORD_PUB.Import_Item_orderability_rules');
End If;

for i in 1..p_Item_Orderability_Import_Tbl.count loop

       OE_ITORD_PUB.Check_required_fields( p_Item_Orderability_Import_Tbl(i));
          IF  p_Item_Orderability_Import_Tbl(i).status = FND_API.G_RET_STS_SUCCESS  then
	     OE_ITORD_PUB.Validate_required_fields ( p_Item_Orderability_Import_Tbl(i));
	        IF p_Item_Orderability_Import_Tbl(i).status = FND_API.G_RET_STS_SUCCESS  then
	            OE_ITORD_PUB.Validate_conditional_fields ( p_Item_Orderability_Import_Tbl(i));
		       IF p_Item_Orderability_Import_Tbl(i).status = FND_API.G_RET_STS_SUCCESS  then
			   OE_ITORD_PUB.check_duplicate_rules ( p_Item_Orderability_Import_Tbl(i) );
			      IF p_Item_Orderability_Import_Tbl(i).status = FND_API.G_RET_STS_SUCCESS  then
				 OE_ITORD_PUB.Validate_rules_DFF (p_Item_Orderability_Import_Tbl(i));
				    IF p_Item_Orderability_Import_Tbl(i).status = FND_API.G_RET_STS_SUCCESS  then
					OE_ITORD_PUB.insert_rules(p_Item_Orderability_Import_Tbl(i));
				    END IF;

	  		      END IF;
		       END IF;
	        END IF;
	 END IF;

 End Loop;

	IF p_commit_flag ='Y' then
		commit;
	ELSE
		rollback;
	End If;

IF l_debug_level > 0 then
	oe_debug_pub.add('Leaving OE_ITORD_PUB.Import_Item_orderability_rules');
End If;

Exception
	when others then
	 OE_MSG_PUB.Add_Exc_Msg
         (
          G_PKG_NAME
           ,'Import_Item_orderability_rules'
          );
End Import_Item_orderability_rules;


Procedure  Check_required_fields ( p_Item_Orderability_Import_Rec IN OUT NOCOPY OE_ITORD_PUB.Item_Orderability_Import_Rec )
IS
l_debug_level   NUMBER := oe_debug_pub.g_debug_level;
begin


    IF l_debug_level > 0 then
	oe_debug_pub.add('Entering OE_ITORD_PUB.Check_required_fields');
    End If;

     p_Item_Orderability_Import_Rec.status := FND_API.G_RET_STS_SUCCESS;
     p_Item_Orderability_Import_Rec.msg_data      := NULL;
     p_Item_Orderability_Import_Rec.msg_count     := 0;

     IF p_Item_Orderability_Import_Rec.org_id is NULL then

	     fnd_message.set_name('ONT','OE_ATTRIBUTE_REQUIRED');
             fnd_message.set_token('ATTRIBUTE','ORG_ID');
	     p_Item_Orderability_Import_Rec.status := FND_API.G_RET_STS_ERROR;
	     p_Item_Orderability_Import_Rec.msg_data      := p_Item_Orderability_Import_Rec.msg_data ||fnd_global.local_chr(59)||fnd_message.get;
	     p_Item_Orderability_Import_Rec.msg_count     := p_Item_Orderability_Import_Rec.msg_count + 1;
	END IF;

	IF p_Item_Orderability_Import_Rec.ITEM_LEVEL is NULL then
	     fnd_message.set_name('ONT','OE_ATTRIBUTE_REQUIRED');
             fnd_message.set_token('ATTRIBUTE','ITEM_LEVEL');
	     p_Item_Orderability_Import_Rec.status := FND_API.G_RET_STS_ERROR;
	     p_Item_Orderability_Import_Rec.msg_data      := p_Item_Orderability_Import_Rec.msg_data ||fnd_global.local_chr(59)||fnd_message.get ;
	     p_Item_Orderability_Import_Rec.msg_count     := p_Item_Orderability_Import_Rec.msg_count + 1;
	END IF;

	IF p_Item_Orderability_Import_Rec.generally_available is NULL then
             fnd_message.set_name('ONT','OE_ATTRIBUTE_REQUIRED');
             fnd_message.set_token('ATTRIBUTE','GENERALLY_AVAILABLE');
	     p_Item_Orderability_Import_Rec.status := FND_API.G_RET_STS_ERROR;
	     p_Item_Orderability_Import_Rec.msg_data      := p_Item_Orderability_Import_Rec.msg_data ||fnd_global.local_chr(59)||fnd_message.get ;
	     p_Item_Orderability_Import_Rec.msg_count     := p_Item_Orderability_Import_Rec.msg_count + 1;
	END IF;

        IF   p_Item_Orderability_Import_Rec.rule_level is NULL then
             fnd_message.set_name('ONT','OE_ATTRIBUTE_REQUIRED');
             fnd_message.set_token('ATTRIBUTE','RULE_LEVEL');
	     p_Item_Orderability_Import_Rec.status := FND_API.G_RET_STS_ERROR;
	     p_Item_Orderability_Import_Rec.msg_data      := p_Item_Orderability_Import_Rec.msg_data ||fnd_global.local_chr(59)||fnd_message.get;
	     p_Item_Orderability_Import_Rec.msg_count     := p_Item_Orderability_Import_Rec.msg_count + 1;
        END IF;


       IF p_Item_Orderability_Import_Rec.created_by is NULL then
             fnd_message.set_name('ONT','OE_ATTRIBUTE_REQUIRED');
             fnd_message.set_token('ATTRIBUTE','CREATED_BY');
	     p_Item_Orderability_Import_Rec.status := FND_API.G_RET_STS_ERROR;
	     p_Item_Orderability_Import_Rec.msg_data      := p_Item_Orderability_Import_Rec.msg_data ||fnd_global.local_chr(59)||fnd_message.get;
	     p_Item_Orderability_Import_Rec.msg_count     := p_Item_Orderability_Import_Rec.msg_count + 1;
        END IF;

	IF p_Item_Orderability_Import_Rec.creation_date  is NULL then
             fnd_message.set_name('ONT','OE_ATTRIBUTE_REQUIRED');
             fnd_message.set_token('ATTRIBUTE','CREATION_DATE');
	     p_Item_Orderability_Import_Rec.status := FND_API.G_RET_STS_ERROR;
	     p_Item_Orderability_Import_Rec.msg_data      := p_Item_Orderability_Import_Rec.msg_data ||fnd_global.local_chr(59)||fnd_message.get;
	     p_Item_Orderability_Import_Rec.msg_count     := p_Item_Orderability_Import_Rec.msg_count + 1;

	END IF;

	IF p_Item_Orderability_Import_Rec.last_updated_by  is NULL then
	     fnd_message.set_name('ONT','OE_ATTRIBUTE_REQUIRED');
             fnd_message.set_token('ATTRIBUTE','LAST_UPDATED_BY');
	     p_Item_Orderability_Import_Rec.status := FND_API.G_RET_STS_ERROR;
	     p_Item_Orderability_Import_Rec.msg_data      := p_Item_Orderability_Import_Rec.msg_data ||fnd_global.local_chr(59)||fnd_message.get;
	     p_Item_Orderability_Import_Rec.msg_count     := p_Item_Orderability_Import_Rec.msg_count + 1;
        END IF;

	IF p_Item_Orderability_Import_Rec.last_update_date  is NULL then
	     fnd_message.set_name('ONT','OE_ATTRIBUTE_REQUIRED');
             fnd_message.set_token('ATTRIBUTE','LAST_UPDATE_DATE');
	     p_Item_Orderability_Import_Rec.status := FND_API.G_RET_STS_ERROR;
	     p_Item_Orderability_Import_Rec.msg_data      := p_Item_Orderability_Import_Rec.msg_data ||fnd_global.local_chr(59)||fnd_message.get;
	     p_Item_Orderability_Import_Rec.msg_count     := p_Item_Orderability_Import_Rec.msg_count + 1;
        END IF;


   IF l_debug_level > 0 then
	oe_debug_pub.add('Leaving OE_ITORD_PUB.Check_required_fields');
   End If;

Exception
    when others then
    NULL;
End Check_required_fields;

Procedure Validate_required_fields ( p_Item_Orderability_Import_REC IN OUT NOCOPY OE_ITORD_PUB.Item_Orderability_Import_REC )
IS

l_exists varchar2(1);
l_debug_level   NUMBER := oe_debug_pub.g_debug_level;
begin


   IF l_debug_level > 0 then
	oe_debug_pub.add('Entering OE_ITORD_PUB.Validate_required_fields');
    End If;

    p_Item_Orderability_Import_Rec.status := FND_API.G_RET_STS_SUCCESS;
    p_Item_Orderability_Import_Rec.msg_data      := NULL;
    p_Item_Orderability_Import_Rec.msg_count     := 0;

IF p_Item_Orderability_Import_Rec.org_id is NOT NULL then
           begin
			     SELECT 'Y' into l_exists
			     FROM HR_OPERATING_UNITS
			     where organization_id = p_Item_Orderability_Import_Rec.org_id
			     and rownum = 1;
              Exception
			when no_data_found then
				 fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
				 fnd_message.set_token('ATTRIBUTE','ORG_ID');
				 p_Item_Orderability_Import_Rec.status := FND_API.G_RET_STS_ERROR;
				 p_Item_Orderability_Import_Rec.msg_data      := p_Item_Orderability_Import_Rec.msg_data ||fnd_global.local_chr(59)||fnd_message.get;
				 p_Item_Orderability_Import_Rec.msg_count     := p_Item_Orderability_Import_Rec.msg_count + 1;
	      End;
END IF;

IF p_Item_Orderability_Import_Rec.ITEM_LEVEL is NOT NULL then

	     IF p_Item_Orderability_Import_Rec.ITEM_LEVEL NOT IN ('I','C') then
	            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
		    fnd_message.set_token('ATTRIBUTE','ITEM_LEVEL');
		    p_Item_Orderability_Import_Rec.status := FND_API.G_RET_STS_ERROR;
	    	    p_Item_Orderability_Import_Rec.msg_data      := p_Item_Orderability_Import_Rec.msg_data ||fnd_global.local_chr(59)||fnd_message.get;
		    p_Item_Orderability_Import_Rec.msg_count     := p_Item_Orderability_Import_Rec.msg_count + 1;
	     END IF;

 END IF;


IF p_Item_Orderability_Import_Rec.RULE_LEVEL is NOT NULL then

	     IF p_Item_Orderability_Import_Rec.RULE_LEVEL NOT IN ('CUSTOMER',
	     'CUST_CLASS',
	     'CUST_CATEGORY',
	     'REGIONS',
	     'ORDER_TYPE',
	     'SHIP_TO_LOC',
	     'SALES_CHANNEL',
	     'SALES_REP',
	     'END_CUST',
	     'BILL_TO_LOC',
	     'DELIVER_TO_LOC'

	    ) then
	            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
		    fnd_message.set_token('ATTRIBUTE','RULE_LEVEL');
		    p_Item_Orderability_Import_Rec.status := FND_API.G_RET_STS_ERROR;
	    	    p_Item_Orderability_Import_Rec.msg_data      := p_Item_Orderability_Import_Rec.msg_data ||fnd_global.local_chr(59)||fnd_message.get;
		    p_Item_Orderability_Import_Rec.msg_count     := p_Item_Orderability_Import_Rec.msg_count + 1;

	     END IF;

END IF;



IF p_Item_Orderability_Import_Rec.generally_available is NOT NULL then
              IF  p_Item_Orderability_Import_Rec.generally_available  NOT IN ('Y' ,'N' ) then
	            fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
		    fnd_message.set_token('ATTRIBUTE','GENERALLY_AVAILABLE');
		    p_Item_Orderability_Import_Rec.status := FND_API.G_RET_STS_ERROR;
	    	    p_Item_Orderability_Import_Rec.msg_data      := p_Item_Orderability_Import_Rec.msg_data ||fnd_global.local_chr(59)||fnd_message.get;
		    p_Item_Orderability_Import_Rec.msg_count     := p_Item_Orderability_Import_Rec.msg_count + 1;

	     END IF;
END IF;

IF p_Item_Orderability_Import_Rec.created_by is NOT NULL then

	     begin

	     select 'Y' into l_exists
	     from fnd_user where user_id = p_Item_Orderability_Import_Rec.created_by
	     and end_date is NULL;

	     Exception
		when others then
		fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
	        fnd_message.set_token('ATTRIBUTE','CREATED_BY');
		p_Item_Orderability_Import_Rec.status := FND_API.G_RET_STS_ERROR;
	    	p_Item_Orderability_Import_Rec.msg_data      := p_Item_Orderability_Import_Rec.msg_data ||fnd_global.local_chr(59)||fnd_message.get;
		p_Item_Orderability_Import_Rec.msg_count     := p_Item_Orderability_Import_Rec.msg_count + 1;

	     End;

END IF;

IF p_Item_Orderability_Import_Rec.last_updated_by  is NULL then
	     begin
	     select 'Y' into l_exists
	     from fnd_user where user_id =  p_Item_Orderability_Import_Rec.last_updated_by
	     and end_date is NULL;

	     Exception
		when others then
		fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
	        fnd_message.set_token('ATTRIBUTE','LAST_UPDATED_BY');
		p_Item_Orderability_Import_Rec.status := FND_API.G_RET_STS_ERROR;
	    	p_Item_Orderability_Import_Rec.msg_data      := p_Item_Orderability_Import_Rec.msg_data ||fnd_global.local_chr(59)||fnd_message.get;
		p_Item_Orderability_Import_Rec.msg_count     := p_Item_Orderability_Import_Rec.msg_count + 1;

	     End;
END IF;


   IF l_debug_level > 0 then
	oe_debug_pub.add('Leaving OE_ITORD_PUB.Validate_required_fields');
    End If;

Exception
    when others then
     p_Item_Orderability_Import_Rec.status := FND_API.G_RET_STS_UNEXP_ERROR;
     p_Item_Orderability_Import_Rec.msg_data      := SQLERRM;
     p_Item_Orderability_Import_Rec.msg_count     := 1;
End Validate_required_fields;



Procedure Validate_conditional_fields ( p_Item_Orderability_Import_Rec IN OUT NOCOPY OE_ITORD_PUB.Item_Orderability_Import_Rec )
IS
l_exists VARCHAR2(1);
l_debug_level   NUMBER := oe_debug_pub.g_debug_level;
begin

    IF l_debug_level > 0 then
	oe_debug_pub.add('Entering  OE_ITORD_PUB.Validate_conditional_fields');
    End If;

     p_Item_Orderability_Import_Rec.status := FND_API.G_RET_STS_SUCCESS;
     p_Item_Orderability_Import_Rec.msg_data      := NULL;
     p_Item_Orderability_Import_Rec.msg_count     := 0;


  IF  p_Item_Orderability_Import_Rec.RULE_LEVEL = 'CUSTOMER' THEN

	IF  p_Item_Orderability_Import_Rec.customer_id IS NULL then
			fnd_message.set_name('ONT','OE_ITORD_FIELD_REQUIRED');
			fnd_message.set_token('FIELD','Rule Level Value');
			fnd_message.set_token('CRITERIA','CUSTOMER_ID');
			p_Item_Orderability_Import_Rec.status := FND_API.G_RET_STS_ERROR;
			p_Item_Orderability_Import_Rec.msg_data      := p_Item_Orderability_Import_Rec.msg_data ||fnd_global.local_chr(59)||fnd_message.get;
			p_Item_Orderability_Import_Rec.msg_count     := p_Item_Orderability_Import_Rec.msg_count + 1;

	ELSE
		begin
		    SELECT 'Y'
		    INTO l_exists
		    FROM hz_parties party,
			hz_cust_accounts acct
		    WHERE acct.party_id = party.party_id
		    AND   acct.status = 'A'
		    AND acct.cust_account_id = p_Item_Orderability_Import_Rec.customer_id ;
		 Exception
			when no_data_found then
			fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
			fnd_message.set_token('ATTRIBUTE','CUSTOMER_ID');
			p_Item_Orderability_Import_Rec.status := FND_API.G_RET_STS_ERROR;
			p_Item_Orderability_Import_Rec.msg_data      := p_Item_Orderability_Import_Rec.msg_data ||fnd_global.local_chr(59)||fnd_message.get;
			p_Item_Orderability_Import_Rec.msg_count     := p_Item_Orderability_Import_Rec.msg_count + 1;

		 End;
	END IF;

		  p_Item_Orderability_Import_Rec.CUSTOMER_CLASS_ID       := NULL;
		  p_Item_Orderability_Import_Rec.CUSTOMER_CATEGORY_CODE  := NULL;
		  p_Item_Orderability_Import_Rec.REGION_ID               := NULL;
		  p_Item_Orderability_Import_Rec.ORDER_TYPE_ID           := NULL;
		  p_Item_Orderability_Import_Rec.SHIP_TO_LOCATION_ID     := NULL;
		  p_Item_Orderability_Import_Rec.SALES_CHANNEL_CODE      := NULL;
		  p_Item_Orderability_Import_Rec.SALES_PERSON_ID         := NULL;
		  p_Item_Orderability_Import_Rec.END_CUSTOMER_ID         := NULL;
		  p_Item_Orderability_Import_Rec.BILL_TO_LOCATION_ID     := NULL;
		  p_Item_Orderability_Import_Rec.DELIVER_TO_LOCATION_ID  := NULL;



 END IF;

 IF  p_Item_Orderability_Import_Rec.RULE_LEVEL = 'CUSTOMER_CLASS' THEN

	IF  p_Item_Orderability_Import_Rec.CUSTOMER_CLASS_ID IS NULL then
			fnd_message.set_name('ONT','OE_ITORD_FIELD_REQUIRED');
			fnd_message.set_token('FIELD','Rule Level Value');
			fnd_message.set_token('CRITERIA','CUSTOMER_CLASS_ID');
			p_Item_Orderability_Import_Rec.status        := FND_API.G_RET_STS_ERROR;
			p_Item_Orderability_Import_Rec.msg_data      := p_Item_Orderability_Import_Rec.msg_data ||fnd_global.local_chr(59)||fnd_message.get;
			p_Item_Orderability_Import_Rec.msg_count     := p_Item_Orderability_Import_Rec.msg_count + 1;

	ELSE
		begin
		         SELECT 'Y'
			 INTO l_exists
			 FROM hz_cust_profile_classes cpc
			 WHERE profile_class_id = p_Item_Orderability_Import_Rec.customer_class_id ;
		 Exception
			when no_data_found then
			fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
			fnd_message.set_token('ATTRIBUTE','CUSTOMER_CLASS_ID');
			p_Item_Orderability_Import_Rec.status := FND_API.G_RET_STS_ERROR;
			p_Item_Orderability_Import_Rec.msg_data      := p_Item_Orderability_Import_Rec.msg_data ||fnd_global.local_chr(59)||fnd_message.get;
			p_Item_Orderability_Import_Rec.msg_count     := p_Item_Orderability_Import_Rec.msg_count + 1;

		 End;
	END IF;

		  p_Item_Orderability_Import_Rec.CUSTOMER_ID             := NULL;
		  p_Item_Orderability_Import_Rec.CUSTOMER_CATEGORY_CODE  := NULL;
		  p_Item_Orderability_Import_Rec.REGION_ID               := NULL;
		  p_Item_Orderability_Import_Rec.ORDER_TYPE_ID           := NULL;
		  p_Item_Orderability_Import_Rec.SHIP_TO_LOCATION_ID     := NULL;
		  p_Item_Orderability_Import_Rec.SALES_CHANNEL_CODE      := NULL;
		  p_Item_Orderability_Import_Rec.SALES_PERSON_ID         := NULL;
		  p_Item_Orderability_Import_Rec.END_CUSTOMER_ID         := NULL;
		  p_Item_Orderability_Import_Rec.BILL_TO_LOCATION_ID     := NULL;
		  p_Item_Orderability_Import_Rec.DELIVER_TO_LOCATION_ID  := NULL;



 END IF;


 IF  p_Item_Orderability_Import_Rec.RULE_LEVEL ='CUST_CATEGORY' then

	 IF p_Item_Orderability_Import_Rec.customer_category_code IS NULL THEN

			fnd_message.set_name('ONT','OE_ITORD_FIELD_REQUIRED');
			fnd_message.set_token('FIELD','Rule Level Value');
			fnd_message.set_token('CRITERIA','CUSTOMER_CATEGORY_CODE');
			P_Item_Orderability_Import_Rec.status := FND_API.G_RET_STS_ERROR;
			p_Item_Orderability_Import_Rec.msg_data      := p_Item_Orderability_Import_Rec.msg_data ||fnd_global.local_chr(59)||fnd_message.get;
			p_Item_Orderability_Import_Rec.msg_count     := p_Item_Orderability_Import_Rec.msg_count + 1;


	 ELSE
		 begin
		   SELECT 'Y'
		   INTO l_exists
		   FROM ar_lookups
		   WHERE lookup_type = 'CUSTOMER_CATEGORY'
		    AND lookup_code = p_Item_Orderability_Import_Rec.customer_category_code ;
		 Exception
			when no_data_found then
			fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
			fnd_message.set_token('ATTRIBUTE','CUSTOMER_CATEGORY_CODE');
			p_Item_Orderability_Import_Rec.status := FND_API.G_RET_STS_ERROR;
			p_Item_Orderability_Import_Rec.msg_data      := p_Item_Orderability_Import_Rec.msg_data ||fnd_global.local_chr(59)||fnd_message.get;
			p_Item_Orderability_Import_Rec.msg_count     := p_Item_Orderability_Import_Rec.msg_count + 1;

		 End;

	 END IF;
		  p_Item_Orderability_Import_Rec.CUSTOMER_ID             := NULL;
		  p_Item_Orderability_Import_Rec.CUSTOMER_CLASS_ID       := NULL;
		  p_Item_Orderability_Import_Rec.REGION_ID               := NULL;
		  p_Item_Orderability_Import_Rec.ORDER_TYPE_ID           := NULL;
		  p_Item_Orderability_Import_Rec.SHIP_TO_LOCATION_ID     := NULL;
		  p_Item_Orderability_Import_Rec.SALES_CHANNEL_CODE      := NULL;
		  p_Item_Orderability_Import_Rec.SALES_PERSON_ID         := NULL;
		  p_Item_Orderability_Import_Rec.END_CUSTOMER_ID         := NULL;
		  p_Item_Orderability_Import_Rec.BILL_TO_LOCATION_ID     := NULL;
		  p_Item_Orderability_Import_Rec.DELIVER_TO_LOCATION_ID  := NULL;
 END IF;

 IF  p_Item_Orderability_Import_Rec.RULE_LEVEL ='REGIONS' then

	  IF p_Item_Orderability_Import_Rec.region_id IS NULL THEN
			fnd_message.set_name('ONT','OE_ITORD_FIELD_REQUIRED');
			fnd_message.set_token('FIELD','Rule Level Value');
			fnd_message.set_token('CRITERIA','REGION_ID');
			p_Item_Orderability_Import_Rec.status := FND_API.G_RET_STS_ERROR;
			p_Item_Orderability_Import_Rec.msg_data      := p_Item_Orderability_Import_Rec.msg_data ||fnd_global.local_chr(59)||fnd_message.get;
			p_Item_Orderability_Import_Rec.msg_count     := p_Item_Orderability_Import_Rec.msg_count + 1;
	 ELSE
		 begin
		    SELECT 'Y'
		    INTO l_exists
		    FROM wsh_regions_v
		   WHERE region_id = p_Item_Orderability_Import_Rec.region_id;
		 Exception
			when no_data_found then
			fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
			fnd_message.set_token('ATTRIBUTE','REGION_ID');
			p_Item_Orderability_Import_Rec.status := FND_API.G_RET_STS_ERROR;
			p_Item_Orderability_Import_Rec.msg_data      := p_Item_Orderability_Import_Rec.msg_data ||fnd_global.local_chr(59)||fnd_message.get;
			p_Item_Orderability_Import_Rec.msg_count     := p_Item_Orderability_Import_Rec.msg_count + 1;

		 End;
     END IF;

		  p_Item_Orderability_Import_Rec.CUSTOMER_ID             := NULL;
		  p_Item_Orderability_Import_Rec.CUSTOMER_CLASS_ID       := NULL;
		  p_Item_Orderability_Import_Rec.CUSTOMER_CATEGORY_CODE  := NULL;
		  p_Item_Orderability_Import_Rec.ORDER_TYPE_ID           := NULL;
		  p_Item_Orderability_Import_Rec.SHIP_TO_LOCATION_ID     := NULL;
		  p_Item_Orderability_Import_Rec.SALES_CHANNEL_CODE      := NULL;
		  p_Item_Orderability_Import_Rec.SALES_PERSON_ID         := NULL;
		  p_Item_Orderability_Import_Rec.END_CUSTOMER_ID         := NULL;
		  p_Item_Orderability_Import_Rec.BILL_TO_LOCATION_ID     := NULL;
		  p_Item_Orderability_Import_Rec.DELIVER_TO_LOCATION_ID  := NULL;
END IF;

IF  p_Item_Orderability_Import_Rec.RULE_LEVEL ='ORDER_TYPE' then

	IF p_Item_Orderability_Import_Rec.order_type_id IS NULL THEN
			fnd_message.set_name('ONT','OE_ITORD_FIELD_REQUIRED');
			fnd_message.set_token('FIELD','Rule Level Value');
			fnd_message.set_token('CRITERIA','ORDER_TYPE_ID');
			p_Item_Orderability_Import_Rec.status := FND_API.G_RET_STS_ERROR;
			p_Item_Orderability_Import_Rec.msg_data      := p_Item_Orderability_Import_Rec.msg_data ||fnd_global.local_chr(59)||fnd_message.get;
			p_Item_Orderability_Import_Rec.msg_count     := p_Item_Orderability_Import_Rec.msg_count + 1;
       ELSE
	  begin
		   SELECT 'Y'
		   INTO l_exists
		   FROM oe_order_types_v
		   WHERE order_type_id = p_Item_Orderability_Import_Rec.order_type_id ;
		 Exception
			when no_data_found then
			fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
			fnd_message.set_token('ATTRIBUTE','ORDER_TYPE_ID');
			p_Item_Orderability_Import_Rec.status := FND_API.G_RET_STS_ERROR;
			p_Item_Orderability_Import_Rec.msg_data      := p_Item_Orderability_Import_Rec.msg_data ||fnd_global.local_chr(59)||fnd_message.get;
			p_Item_Orderability_Import_Rec.msg_count     := p_Item_Orderability_Import_Rec.msg_count + 1;
		 End;
       END IF;

	  p_Item_Orderability_Import_Rec.CUSTOMER_ID             := NULL;
	  p_Item_Orderability_Import_Rec.CUSTOMER_CLASS_ID       := NULL;
	  p_Item_Orderability_Import_Rec.CUSTOMER_CATEGORY_CODE  := NULL;
	  p_Item_Orderability_Import_Rec.REGION_ID               := NULL;
	  p_Item_Orderability_Import_Rec.SHIP_TO_LOCATION_ID     := NULL;
	  p_Item_Orderability_Import_Rec.SALES_CHANNEL_CODE      := NULL;
	  p_Item_Orderability_Import_Rec.SALES_PERSON_ID         := NULL;
	  p_Item_Orderability_Import_Rec.END_CUSTOMER_ID         := NULL;
	  p_Item_Orderability_Import_Rec.BILL_TO_LOCATION_ID     := NULL;
	  p_Item_Orderability_Import_Rec.DELIVER_TO_LOCATION_ID  := NULL;

  END IF;

 IF  p_Item_Orderability_Import_Rec.RULE_LEVEL ='SHIP_TO_LOC' then


      IF p_Item_Orderability_Import_Rec.SHIP_TO_LOCATION_ID IS NULL THEN
			fnd_message.set_name('ONT','OE_ITORD_FIELD_REQUIRED');
			fnd_message.set_token('FIELD','Rule Level Value');
			fnd_message.set_token('CRITERIA','SHIP_TO_LOCATION_ID');
			p_Item_Orderability_Import_Rec.status := FND_API.G_RET_STS_ERROR;
			p_Item_Orderability_Import_Rec.msg_data      := p_Item_Orderability_Import_Rec.msg_data ||fnd_global.local_chr(59)||fnd_message.get;
			p_Item_Orderability_Import_Rec.msg_count     := p_Item_Orderability_Import_Rec.msg_count + 1;
       ELSE
		 begin
		   SELECT  'Y'
		   INTO l_exists
		   FROM hz_cust_site_uses_all site
		   WHERE site.site_use_code = 'SHIP_TO'
		    AND site.site_use_id= p_Item_Orderability_Import_Rec.SHIP_TO_LOCATION_ID;
		 Exception
			when no_data_found then
			fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
			fnd_message.set_token('ATTRIBUTE','SHIP_TO_LOCATION_ID');
			p_Item_Orderability_Import_Rec.status := FND_API.G_RET_STS_ERROR;
			p_Item_Orderability_Import_Rec.msg_data      := p_Item_Orderability_Import_Rec.msg_data ||fnd_global.local_chr(59)||fnd_message.get;
			p_Item_Orderability_Import_Rec.msg_count     := p_Item_Orderability_Import_Rec.msg_count + 1;
		 End;
	END IF;

		  p_Item_Orderability_Import_Rec.CUSTOMER_ID             := NULL;
		  p_Item_Orderability_Import_Rec.CUSTOMER_CLASS_ID       := NULL;
		  p_Item_Orderability_Import_Rec.CUSTOMER_CATEGORY_CODE  := NULL;
		  p_Item_Orderability_Import_Rec.REGION_ID               := NULL;
		  p_Item_Orderability_Import_Rec.ORDER_TYPE_ID           := NULL;
		  p_Item_Orderability_Import_Rec.SALES_CHANNEL_CODE      := NULL;
		  p_Item_Orderability_Import_Rec.SALES_PERSON_ID         := NULL;
		  p_Item_Orderability_Import_Rec.END_CUSTOMER_ID         := NULL;
		  p_Item_Orderability_Import_Rec.BILL_TO_LOCATION_ID     := NULL;
		  p_Item_Orderability_Import_Rec.DELIVER_TO_LOCATION_ID  := NULL;

  END IF;

 IF  p_Item_Orderability_Import_Rec.RULE_LEVEL ='SALES_CHANNEL' then

      IF p_Item_Orderability_Import_Rec.SALES_CHANNEL_CODE IS NULL THEN
			fnd_message.set_name('ONT','OE_ITORD_FIELD_REQUIRED');
			fnd_message.set_token('FIELD','Rule Level Value');
			fnd_message.set_token('CRITERIA','SALES_CHANNEL_CODE');
			p_Item_Orderability_Import_Rec.status := FND_API.G_RET_STS_ERROR;
			p_Item_Orderability_Import_Rec.msg_data      := p_Item_Orderability_Import_Rec.msg_data ||fnd_global.local_chr(59)||fnd_message.get;
			p_Item_Orderability_Import_Rec.msg_count     := p_Item_Orderability_Import_Rec.msg_count + 1;
       ELSE
		begin
		   SELECT 'Y'
		   INTO l_exists
		   FROM oe_lookups
		  WHERE lookup_type = 'SALES_CHANNEL'
		    AND lookup_code =p_Item_Orderability_Import_Rec.sales_channel_code;
		 Exception
			when no_data_found then
			fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
			fnd_message.set_token('ATTRIBUTE','SALES_CHANNEL_CODE');
			p_Item_Orderability_Import_Rec.status := FND_API.G_RET_STS_ERROR;
			p_Item_Orderability_Import_Rec.msg_data      := p_Item_Orderability_Import_Rec.msg_data ||fnd_global.local_chr(59)||fnd_message.get;
			p_Item_Orderability_Import_Rec.msg_count     := p_Item_Orderability_Import_Rec.msg_count + 1;
		End;
	END IF;

		  p_Item_Orderability_Import_Rec.CUSTOMER_ID             := NULL;
		  p_Item_Orderability_Import_Rec.CUSTOMER_CLASS_ID       := NULL;
		  p_Item_Orderability_Import_Rec.CUSTOMER_CATEGORY_CODE  := NULL;
		  p_Item_Orderability_Import_Rec.REGION_ID               := NULL;
		  p_Item_Orderability_Import_Rec.ORDER_TYPE_ID           := NULL;
		  p_Item_Orderability_Import_Rec.SHIP_TO_LOCATION_ID     := NULL;
		  p_Item_Orderability_Import_Rec.SALES_PERSON_ID         := NULL;
		  p_Item_Orderability_Import_Rec.END_CUSTOMER_ID         := NULL;
		  p_Item_Orderability_Import_Rec.BILL_TO_LOCATION_ID     := NULL;
		  p_Item_Orderability_Import_Rec.DELIVER_TO_LOCATION_ID  := NULL;

 END IF;

 --check
 IF  p_Item_Orderability_Import_Rec.RULE_LEVEL ='SALES_REP' then

	IF p_Item_Orderability_Import_Rec.SALES_PERSON_ID IS NULL THEN
			fnd_message.set_name('ONT','OE_ITORD_FIELD_REQUIRED');
			fnd_message.set_token('FIELD','Rule Level Value');
			fnd_message.set_token('CRITERIA','SALES_PERSON_ID');
			p_Item_Orderability_Import_Rec.status := FND_API.G_RET_STS_ERROR;
			p_Item_Orderability_Import_Rec.msg_data      := p_Item_Orderability_Import_Rec.msg_data ||fnd_global.local_chr(59)||fnd_message.get;
			p_Item_Orderability_Import_Rec.msg_count     := p_Item_Orderability_Import_Rec.msg_count + 1;
       ELSE

	       begin
		  SELECT 'Y'
		  INTO l_exists
		  FROM ra_salesreps
		  WHERE salesrep_id = p_Item_Orderability_Import_Rec.SALES_PERSON_ID;

		 Exception
			when no_data_found then
			fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
			fnd_message.set_token('ATTRIBUTE','SALES_PERSON_ID');
			p_Item_Orderability_Import_Rec.status := FND_API.G_RET_STS_ERROR;
			p_Item_Orderability_Import_Rec.msg_data      := p_Item_Orderability_Import_Rec.msg_data ||fnd_global.local_chr(59)||fnd_message.get;
			p_Item_Orderability_Import_Rec.msg_count     := p_Item_Orderability_Import_Rec.msg_count + 1;
		End;

	 END IF;

		  p_Item_Orderability_Import_Rec.CUSTOMER_ID             := NULL;
		  p_Item_Orderability_Import_Rec.CUSTOMER_CLASS_ID       := NULL;
		  p_Item_Orderability_Import_Rec.CUSTOMER_CATEGORY_CODE  := NULL;
		  p_Item_Orderability_Import_Rec.REGION_ID               := NULL;
		  p_Item_Orderability_Import_Rec.ORDER_TYPE_ID           := NULL;
		  p_Item_Orderability_Import_Rec.SHIP_TO_LOCATION_ID     := NULL;
		  p_Item_Orderability_Import_Rec.SALES_CHANNEL_CODE      := NULL;
		  p_Item_Orderability_Import_Rec.END_CUSTOMER_ID         := NULL;
		  p_Item_Orderability_Import_Rec.BILL_TO_LOCATION_ID     := NULL;
		  p_Item_Orderability_Import_Rec.DELIVER_TO_LOCATION_ID  := NULL;
 END IF;

 IF  p_Item_Orderability_Import_Rec.RULE_LEVEL = 'END_CUST' then

    IF p_Item_Orderability_Import_Rec.end_customer_id IS NULL THEN
			fnd_message.set_name('ONT','OE_ITORD_FIELD_REQUIRED');
			fnd_message.set_token('FIELD','Rule Level Value');
			fnd_message.set_token('CRITERIA','END_CUSTOMER_ID');
			p_Item_Orderability_Import_Rec.status := FND_API.G_RET_STS_ERROR;
			p_Item_Orderability_Import_Rec.msg_data      := p_Item_Orderability_Import_Rec.msg_data ||fnd_global.local_chr(59)||fnd_message.get;
			p_Item_Orderability_Import_Rec.msg_count     := p_Item_Orderability_Import_Rec.msg_count + 1;
       ELSE

		 begin
		    SELECT 'Y'
		    INTO l_exists
		    FROM hz_parties party,
			hz_cust_accounts acct
		    WHERE acct.party_id = party.party_id
		    AND acct.cust_account_id = p_Item_Orderability_Import_Rec.end_customer_id ;
		 Exception
			when no_data_found then
			fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
			fnd_message.set_token('ATTRIBUTE','END_CUSTOMER_ID');
			p_Item_Orderability_Import_Rec.status := FND_API.G_RET_STS_ERROR;
			p_Item_Orderability_Import_Rec.msg_data      := p_Item_Orderability_Import_Rec.msg_data ||fnd_global.local_chr(59)||fnd_message.get;
			p_Item_Orderability_Import_Rec.msg_count     := p_Item_Orderability_Import_Rec.msg_count + 1;
		 End;

	 END IF;

		  p_Item_Orderability_Import_Rec.CUSTOMER_ID             := NULL;
		  p_Item_Orderability_Import_Rec.CUSTOMER_CLASS_ID       := NULL;
		  p_Item_Orderability_Import_Rec.CUSTOMER_CATEGORY_CODE  := NULL;
		  p_Item_Orderability_Import_Rec.REGION_ID               := NULL;
		  p_Item_Orderability_Import_Rec.ORDER_TYPE_ID           := NULL;
		  p_Item_Orderability_Import_Rec.SHIP_TO_LOCATION_ID     := NULL;
		  p_Item_Orderability_Import_Rec.SALES_CHANNEL_CODE      := NULL;
		  p_Item_Orderability_Import_Rec.SALES_PERSON_ID         := NULL;
		  p_Item_Orderability_Import_Rec.BILL_TO_LOCATION_ID     := NULL;
		  p_Item_Orderability_Import_Rec.DELIVER_TO_LOCATION_ID  := NULL;

 END IF;

 IF  p_Item_Orderability_Import_Rec.RULE_LEVEL = 'BILL_TO_LOC' then

 IF p_Item_Orderability_Import_Rec.BILL_TO_LOCATION_ID IS NULL THEN
			fnd_message.set_name('ONT','OE_ITORD_FIELD_REQUIRED');
			fnd_message.set_token('FIELD','Rule Level Value');
			fnd_message.set_token('CRITERIA','BILL_TO_LOCATION_ID');
			p_Item_Orderability_Import_Rec.status := FND_API.G_RET_STS_ERROR;
			p_Item_Orderability_Import_Rec.msg_data      := p_Item_Orderability_Import_Rec.msg_data ||fnd_global.local_chr(59)||fnd_message.get;
			p_Item_Orderability_Import_Rec.msg_count     := p_Item_Orderability_Import_Rec.msg_count + 1;
  ELSE
	 begin
	    SELECT 'Y'
            INTO l_exists
            FROM hz_cust_site_uses_all site
            WHERE site.site_use_code = 'BILL_TO'
            AND site.site_use_id= p_Item_Orderability_Import_Rec.BILL_TO_LOCATION_ID ;
	 Exception
		when no_data_found then
		 fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
		fnd_message.set_token('ATTRIBUTE','BILL_TO_LOCATION_ID');
		p_Item_Orderability_Import_Rec.status := FND_API.G_RET_STS_ERROR;
	    	p_Item_Orderability_Import_Rec.msg_data      := p_Item_Orderability_Import_Rec.msg_data ||fnd_global.local_chr(59)||fnd_message.get;
		p_Item_Orderability_Import_Rec.msg_count     := p_Item_Orderability_Import_Rec.msg_count + 1;

	 End;

  END IF;

		  p_Item_Orderability_Import_Rec.CUSTOMER_ID             := NULL;
		  p_Item_Orderability_Import_Rec.CUSTOMER_CLASS_ID       := NULL;
		  p_Item_Orderability_Import_Rec.CUSTOMER_CATEGORY_CODE  := NULL;
		  p_Item_Orderability_Import_Rec.REGION_ID               := NULL;
		  p_Item_Orderability_Import_Rec.ORDER_TYPE_ID           := NULL;
		  p_Item_Orderability_Import_Rec.SHIP_TO_LOCATION_ID     := NULL;
		  p_Item_Orderability_Import_Rec.SALES_CHANNEL_CODE      := NULL;
		  p_Item_Orderability_Import_Rec.SALES_PERSON_ID         := NULL;
		  p_Item_Orderability_Import_Rec.END_CUSTOMER_ID         := NULL;
		  p_Item_Orderability_Import_Rec.DELIVER_TO_LOCATION_ID  := NULL;

 END IF;

IF  p_Item_Orderability_Import_Rec.RULE_LEVEL = 'DELIVER_TO_LOC' then

 IF p_Item_Orderability_Import_Rec.DELIVER_TO_LOCATION_ID IS NULL THEN
			fnd_message.set_name('ONT','OE_ITORD_FIELD_REQUIRED');
			fnd_message.set_token('FIELD','Rule Level Value');
			fnd_message.set_token('CRITERIA','DELIVER_TO_LOCATION_ID');
			p_Item_Orderability_Import_Rec.status := FND_API.G_RET_STS_ERROR;
			p_Item_Orderability_Import_Rec.msg_data      := p_Item_Orderability_Import_Rec.msg_data ||fnd_global.local_chr(59)||fnd_message.get;
			p_Item_Orderability_Import_Rec.msg_count     := p_Item_Orderability_Import_Rec.msg_count + 1;
  ELSE

	 begin
	   SELECT 'Y'
           INTO l_exists
           FROM hz_cust_site_uses_all site
           WHERE site.site_use_code = 'DELIVER_TO'
           AND site.site_use_id= p_Item_Orderability_Import_Rec.DELIVER_TO_LOCATION_ID;
	 Exception
		when no_data_found then
		fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
		fnd_message.set_token('ATTRIBUTE','DELIVER_TO_LOCATION_ID');
		p_Item_Orderability_Import_Rec.status := FND_API.G_RET_STS_ERROR;
	    	p_Item_Orderability_Import_Rec.msg_data      := p_Item_Orderability_Import_Rec.msg_data ||fnd_global.local_chr(59)||fnd_message.get;
		p_Item_Orderability_Import_Rec.msg_count     := p_Item_Orderability_Import_Rec.msg_count + 1;

	 End;
  END IF;

		  p_Item_Orderability_Import_Rec.CUSTOMER_ID             := NULL;
		  p_Item_Orderability_Import_Rec.CUSTOMER_CLASS_ID       := NULL;
		  p_Item_Orderability_Import_Rec.CUSTOMER_CATEGORY_CODE  := NULL;
		  p_Item_Orderability_Import_Rec.REGION_ID               := NULL;
		  p_Item_Orderability_Import_Rec.ORDER_TYPE_ID           := NULL;
		  p_Item_Orderability_Import_Rec.SHIP_TO_LOCATION_ID     := NULL;
		  p_Item_Orderability_Import_Rec.SALES_CHANNEL_CODE      := NULL;
		  p_Item_Orderability_Import_Rec.SALES_PERSON_ID         := NULL;
		  p_Item_Orderability_Import_Rec.END_CUSTOMER_ID         := NULL;
		  p_Item_Orderability_Import_Rec.BILL_TO_LOCATION_ID     := NULL;

 END IF;


   IF p_Item_Orderability_Import_Rec.Item_level = 'I' then

	   IF p_Item_Orderability_Import_Rec.inventory_item_id IS NULL then

		fnd_message.set_name('ONT','OE_ITORD_FIELD_REQUIRED');
		fnd_message.set_token('FIELD','Inventory Item');
		fnd_message.set_token('CRITERIA','Item');
		p_Item_Orderability_Import_Rec.status := FND_API.G_RET_STS_ERROR;
	    	p_Item_Orderability_Import_Rec.msg_data      := p_Item_Orderability_Import_Rec.msg_data ||fnd_global.local_chr(59)||fnd_message.get;
		p_Item_Orderability_Import_Rec.msg_count     := p_Item_Orderability_Import_Rec.msg_count + 1;

	   ELSE
		begin
		  select 'Y' into l_exists
		  from mtl_system_items_b
		  where inventory_item_id = p_Item_Orderability_Import_Rec.inventory_item_id
		  and organization_id = oe_sys_parameters.value('MASTER_ORGANIZATION_ID',p_Item_Orderability_Import_Rec.org_id );
		Exception
			when no_data_found then
			 fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
		         fnd_message.set_token('ATTRIBUTE','INVENTORY_ITEM_ID');
		         p_Item_Orderability_Import_Rec.status := FND_API.G_RET_STS_ERROR;
	    	         p_Item_Orderability_Import_Rec.msg_data      := p_Item_Orderability_Import_Rec.msg_data ||fnd_global.local_chr(59)||fnd_message.get;
		         p_Item_Orderability_Import_Rec.msg_count     := p_Item_Orderability_Import_Rec.msg_count + 1;

		End;

	   END IF;

	p_Item_Orderability_Import_Rec.item_category_id := NULL;

   ELSIF   p_Item_Orderability_Import_Rec.Item_level = 'C' then

		If p_Item_Orderability_Import_Rec.item_category_id IS NULL then
			  fnd_message.set_name('ONT','OE_ITORD_FIELD_REQUIRED');
			  fnd_message.set_token('FIELD','Item Category');
			  fnd_message.set_token('CRITERIA','Category');
			  p_Item_Orderability_Import_Rec.status := FND_API.G_RET_STS_ERROR;
	    		  p_Item_Orderability_Import_Rec.msg_data      := p_Item_Orderability_Import_Rec.msg_data ||fnd_global.local_chr(59)||fnd_message.get;
		          p_Item_Orderability_Import_Rec.msg_count     := p_Item_Orderability_Import_Rec.msg_count + 1;

		Else
			begin
				select 'Y' into l_exists
				from mtl_categories
				where category_id = p_Item_Orderability_Import_Rec.item_category_id ;
			Exception
				when others then
				  fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
			          fnd_message.set_token('ATTRIBUTE','ITEM_CATEGORY_ID');
			          p_Item_Orderability_Import_Rec.status := FND_API.G_RET_STS_ERROR;
	    			  p_Item_Orderability_Import_Rec.msg_data      := p_Item_Orderability_Import_Rec.msg_data ||fnd_global.local_chr(59)||fnd_message.get;
				  p_Item_Orderability_Import_Rec.msg_count     := p_Item_Orderability_Import_Rec.msg_count + 1;

			End ;

		End If;

	p_Item_Orderability_Import_Rec.inventory_item_id := NULL;
END IF;

   IF l_debug_level > 0 then
	oe_debug_pub.add('Leaving OE_ITORD_PUB.Validate_conditional_fields');
    End If;

Exception
	when others then
	 p_Item_Orderability_Import_Rec.status := FND_API.G_RET_STS_UNEXP_ERROR;
	 p_Item_Orderability_Import_Rec.msg_data      := SQLERRM;
	 p_Item_Orderability_Import_Rec.msg_count     := 1;
End Validate_conditional_fields;


Procedure  check_duplicate_rules ( p_Item_Orderability_Import_Rec IN OUT NOCOPY OE_ITORD_PUB.Item_Orderability_Import_Rec )
IS
l_exists Varchar2(1);
l_return_token boolean := TRUE;
l_rule_level_coulmn VARCHAR2(1000);
l_rule_level_value VARCHAR2(1000);
l_data_type VARCHAR2(1);

sql_stmt VARCHAR2(32000);
l_debug_level   NUMBER := oe_debug_pub.g_debug_level;
begin

IF l_debug_level > 0 then
	oe_debug_pub.add('Entering OE_ITORD_PUB.check_duplicate_rules');
End If;

     p_Item_Orderability_Import_Rec.status := FND_API.G_RET_STS_SUCCESS;
     p_Item_Orderability_Import_Rec.msg_data      := NULL;
     p_Item_Orderability_Import_Rec.msg_count     := 0;

 IF p_Item_Orderability_Import_Rec.item_level = 'I' then

		      begin
				 SELECT 'Y'
				 INTO l_exists
				 FROM mtl_item_categories ic,
				    mtl_default_category_sets cs,
				    oe_item_orderability oei
				 WHERE ic.category_set_id=cs.category_set_id
				 AND cs.functional_area_id = 7
				 AND ic.organization_id = oe_sys_parameters.Value('MASTER_ORGANIZATION_ID',p_Item_Orderability_Import_Rec.org_id)
				 AND ic.inventory_item_id = p_Item_Orderability_Import_Rec.inventory_item_id
				 AND oei.enable_flag='Y'
				 AND ic.category_id = oei.item_category_id
				 and org_id = p_Item_Orderability_Import_Rec.org_id
			        AND rownum = 1;

				fnd_message.set_name('ONT','OE_ITORD_RULE_EXISTS');
				fnd_message.SET_TOKEN('CRITERIA','Item Category');
				p_Item_Orderability_Import_Rec.status := FND_API.G_RET_STS_ERROR;
	    			p_Item_Orderability_Import_Rec.msg_data      := p_Item_Orderability_Import_Rec.msg_data ||fnd_global.local_chr(59)||fnd_message.get;
				p_Item_Orderability_Import_Rec.msg_count     := p_Item_Orderability_Import_Rec.msg_count + 1;
		         Exception
				when no_data_found then
				NULL;
		         End;

			OE_ITORD_PUB.get_rule_coulumn_details(p_Item_Orderability_Import_Rec,l_rule_level_coulmn,l_rule_level_value,l_data_type);

			sql_stmt :=    ' select count(1) '
			             || ' from oe_item_orderability io_hdr , oe_item_orderability_rules io_rules '
				     || ' where io_hdr.orderability_id = io_rules.orderability_id '
				     || ' and io_hdr.enable_flag = ''Y'' '
				     || ' and io_rules.enable_flag=''Y'' '
				     || ' and io_hdr.org_id = '|| p_Item_Orderability_Import_Rec.org_id
				     || ' and io_hdr.inventory_item_id = ' || p_Item_Orderability_Import_Rec.inventory_item_id
				     || ' and io_rules.rule_level = ' ||''''|| p_Item_Orderability_Import_Rec.rule_level ||''''
				     || ' and io_rules.'||l_rule_level_coulmn
				     || ' = ' ;

			  IF l_data_type = 'N' then
				sql_stmt := sql_stmt || to_number(l_rule_level_value);
			  ELSE
                                sql_stmt := sql_stmt || ''''||l_rule_level_value||'''';
			  END IF;



		IF NOT OE_ITORD_UTIL.Check_Duplicate_Rules(sql_stmt)
		 THEN
		   fnd_message.set_name('ONT','OE_ITORD_DUP_RULE_EXISTS');
		   fnd_message.set_token('RULE_LEVEL',l_rule_level_coulmn);
		   fnd_message.set_token('RULE_LEVEL_VALUE',l_rule_level_value);
		   p_Item_Orderability_Import_Rec.status := FND_API.G_RET_STS_ERROR;
	    	   p_Item_Orderability_Import_Rec.msg_data      := p_Item_Orderability_Import_Rec.msg_data ||fnd_global.local_chr(59)||fnd_message.get;
		   p_Item_Orderability_Import_Rec.msg_count     := p_Item_Orderability_Import_Rec.msg_count + 1;
               END IF;



  END IF;

  IF p_Item_Orderability_Import_Rec.item_level = 'C' then
        		begin

			       SELECT 'Y'
			       into l_exists
			       FROM mtl_item_categories ic,
				 mtl_default_category_sets cs,
				 oe_item_orderability oei
				WHERE ic.category_set_id=cs.category_set_id
				 AND cs.functional_area_id = 7
				 AND ic.organization_id=oe_sys_parameters.Value('MASTER_ORGANIZATION_ID',p_Item_Orderability_Import_Rec.org_id)
				 AND ic.inventory_item_id = oei.inventory_item_id
				 AND oei.enable_flag='Y'
				 AND ic.category_id = p_Item_Orderability_Import_Rec.ITEM_CATEGORY_ID
				 and org_id = p_Item_Orderability_Import_Rec.org_id
				 AND rownum = 1;

				 fnd_message.set_name('ONT','OE_ITORD_RULE_EXISTS');
				 fnd_message.SET_TOKEN('CRITERIA','Item');
				 p_Item_Orderability_Import_Rec.status := FND_API.G_RET_STS_ERROR;
	    			 p_Item_Orderability_Import_Rec.msg_data      := p_Item_Orderability_Import_Rec.msg_data ||fnd_global.local_chr(59)||fnd_message.get;
				 p_Item_Orderability_Import_Rec.msg_count     := p_Item_Orderability_Import_Rec.msg_count + 1;
			  Exception
				when no_data_found then
				NULL;
			  End ;


		OE_ITORD_PUB.get_rule_coulumn_details(p_Item_Orderability_Import_Rec,l_rule_level_coulmn,l_rule_level_value,l_data_type);

		sql_stmt :=    ' select count(1) '
			             || ' from oe_item_orderability io_hdr , oe_item_orderability_rules io_rules '
				     || ' where io_hdr.orderability_id = io_rules.orderability_id '
				     || ' and io_hdr.enable_flag = ''Y'' '
				     || ' and io_rules.enable_flag=''Y'' '
				     || ' and io_hdr.org_id = '|| p_Item_Orderability_Import_Rec.org_id
				     || ' and io_hdr.item_category_id = ' || p_Item_Orderability_Import_Rec.item_category_id
				     || ' and io_rules.rule_level = ' ||''''|| p_Item_Orderability_Import_Rec.rule_level ||''''
				     || ' and io_rules.'||l_rule_level_coulmn
				     || ' = ' ;

			  IF l_data_type = 'N' then
				sql_stmt := sql_stmt || to_number(l_rule_level_value);
			  ELSE
                                sql_stmt := sql_stmt || ''''||l_rule_level_value||'''';
			  END IF;



		IF NOT OE_ITORD_UTIL.Check_Duplicate_Rules(sql_stmt)
		 THEN
		   fnd_message.set_name('ONT','OE_ITORD_DUP_RULE_EXISTS');
		   fnd_message.set_token('RULE_LEVEL',l_rule_level_coulmn);
		   fnd_message.set_token('RULE_LEVEL_VALUE',l_rule_level_value);
		   p_Item_Orderability_Import_Rec.status := FND_API.G_RET_STS_ERROR;
	    	   p_Item_Orderability_Import_Rec.msg_data      := p_Item_Orderability_Import_Rec.msg_data ||fnd_global.local_chr(59)||fnd_message.get;
		   p_Item_Orderability_Import_Rec.msg_count     := p_Item_Orderability_Import_Rec.msg_count + 1;
               END IF;



End If;

IF l_debug_level > 0 then
	oe_debug_pub.add('Leaving OE_ITORD_PUB.check_duplicate_rules');
End If;

Exception
	when others then
	 p_Item_Orderability_Import_Rec.status := FND_API.G_RET_STS_UNEXP_ERROR;
	 p_Item_Orderability_Import_Rec.msg_data      := SQLERRM;
	 p_Item_Orderability_Import_Rec.msg_count     := 1;
End check_duplicate_rules;

Procedure get_rule_coulumn_details( p_Item_Orderability_Import_Rec IN OE_ITORD_PUB.Item_Orderability_Import_Rec ,
				    x_rule_level_column OUT NOCOPY VARCHAR2,
				    x_rule_level_value  OUT NOCOPY VARCHAR2,
				    x_data_type         OUT NOCOPY VARCHAR2
   			           ) IS
p_rule_level VARCHAR2(1000);
begin

       x_data_type := 'N';
       p_rule_level := p_Item_Orderability_Import_Rec.RULE_LEVEL;

      IF p_rule_level = 'CUSTOMER'
      THEN
         x_rule_level_column := 'CUSTOMER_ID';
	 x_rule_level_value := p_Item_Orderability_Import_Rec.customer_id;
      ELSIF p_rule_level = 'CUST_CLASS'
      THEN
         x_rule_level_column :=  'CUSTOMER_CLASS_ID';
 	 x_rule_level_value := p_Item_Orderability_Import_Rec.CUSTOMER_CLASS_ID;
      ELSIF p_rule_level = 'CUST_CATEGORY'
      THEN
         x_rule_level_column :=  'CUSTOMER_CATEGORY_CODE';
         x_rule_level_value := p_Item_Orderability_Import_Rec.CUSTOMER_CATEGORY_CODE;
         x_data_type         := 'C';
      ELSIF p_rule_level = 'REGIONS'
      THEN
         x_rule_level_column :=  'REGION_ID';
	 x_rule_level_value := p_Item_Orderability_Import_Rec.REGION_ID;
      ELSIF p_rule_level = 'ORDER_TYPE'
      THEN
         x_rule_level_column :=  'ORDER_TYPE_ID';
         x_rule_level_value := p_Item_Orderability_Import_Rec.ORDER_TYPE_ID;
      ELSIF p_rule_level = 'SHIP_TO_LOC'
      THEN
         x_rule_level_column :=  'SHIP_TO_LOCATION_ID';
         x_rule_level_value := p_Item_Orderability_Import_Rec.SHIP_TO_LOCATION_ID;
      ELSIF p_rule_level = 'SALES_CHANNEL'
      THEN
         x_rule_level_column :=  'SALES_CHANNEL_CODE';
	 x_rule_level_value := p_Item_Orderability_Import_Rec.SALES_CHANNEL_CODE;
         x_data_type         := 'C';
      ELSIF p_rule_level = 'SALES_REP'
      THEN
         x_rule_level_column :=  'SALES_PERSON_ID';
         x_rule_level_value := p_Item_Orderability_Import_Rec.SALES_PERSON_ID;
      ELSIF p_rule_level = 'END_CUST'
      THEN
         x_rule_level_column :=  'END_CUSTOMER_ID';
         x_rule_level_value := p_Item_Orderability_Import_Rec.END_CUSTOMER_ID;
     ELSIF p_rule_level = 'BILL_TO_LOC'
      THEN
         x_rule_level_column :=  'BILL_TO_LOCATION_ID';
	 x_rule_level_value := p_Item_Orderability_Import_Rec.BILL_TO_LOCATION_ID;
     ELSIF p_rule_level = 'DELIVER_TO_LOC'
     THEN
         x_rule_level_column :=  'DELIVER_TO_LOCATION_ID';
         x_rule_level_value := p_Item_Orderability_Import_Rec.DELIVER_TO_LOCATION_ID;
     END IF;

End;

Procedure insert_rules( p_Item_Orderability_Import_Rec IN OUT NOCOPY  OE_ITORD_PUB.Item_Orderability_Import_Rec ) IS

l_item_orderability_rec OE_ITORD_UTIL.Item_Orderability_Rec;
l_item_orderability_rules_rec OE_ITORD_UTIL.Item_Orderability_Rules_Rec;
l_orderability_id NUMBER;
l_status   VARCHAR2(1);
l_rowid rowid := NULL;

l_debug_level   NUMBER := oe_debug_pub.g_debug_level;
begin

IF l_debug_level > 0 then
	oe_debug_pub.add('Entering OE_ITORD_PUB.insert_rules');
End If;

     p_Item_Orderability_Import_Rec.status := FND_API.G_RET_STS_SUCCESS;
     p_Item_Orderability_Import_Rec.msg_data      := NULL;
     p_Item_Orderability_Import_Rec.msg_count     := 0;


		   begin
				select orderability_id into l_orderability_id
				from oe_item_orderability
				where  enable_flag = 'Y'
				and org_id = p_Item_Orderability_Import_Rec.org_id
				and   item_level = p_Item_Orderability_Import_Rec.ITEM_LEVEL
				and  ( inventory_item_id = p_Item_Orderability_Import_Rec.inventory_item_id
				      OR item_category_id  = p_Item_Orderability_Import_Rec.inventory_item_id );

			Exception
				 when no_data_found then
				 l_orderability_id := NULL;

			End;

			IF l_orderability_id IS NULL then

				SELECT OE_ITEM_ORDERABILITY_S.nextval
				INTO l_orderability_id
			        FROM dual;

			        l_item_orderability_rec.orderability_id     := l_orderability_id;
			        l_item_orderability_rec.org_id              := p_Item_Orderability_Import_Rec.org_id;
			        l_item_orderability_rec.item_level          := p_Item_Orderability_Import_Rec.item_level;
				l_item_orderability_rec.item_category_id    := p_Item_Orderability_Import_Rec.item_category_id;
			        l_item_orderability_rec.inventory_item_id   := p_Item_Orderability_Import_Rec.inventory_item_id;
			        l_item_orderability_rec.generally_available := p_Item_Orderability_Import_Rec.generally_available;
			        l_item_orderability_rec.enable_flag         := 'Y';
				l_item_orderability_rec.created_by          := p_Item_Orderability_Import_Rec.created_by;
			        l_item_orderability_rec.creation_date       := p_Item_Orderability_Import_Rec.creation_date;
			        l_item_orderability_rec.last_updated_by     := p_Item_Orderability_Import_Rec.last_updated_by;
			        l_item_orderability_rec.last_update_date    := p_Item_Orderability_Import_Rec.last_update_date;


				OE_ITORD_UTIL.INSERT_ROW (l_item_orderability_rec,l_status);
		       END IF;


                     	      l_item_orderability_rules_rec.ORDERABILITY_ID        := l_orderability_id;
			      l_item_orderability_rules_rec.RULE_LEVEL             := p_Item_Orderability_Import_Rec.rule_level;
			      l_item_orderability_rules_rec.CUSTOMER_ID            := p_Item_Orderability_Import_Rec.customer_id;
			      l_item_orderability_rules_rec.CUSTOMER_CLASS_ID      := p_Item_Orderability_Import_Rec.customer_class_id;
			      l_item_orderability_rules_rec.CUSTOMER_CATEGORY_CODE := p_Item_Orderability_Import_Rec.customer_category_code;
			      l_item_orderability_rules_rec.REGION_ID              := p_Item_Orderability_Import_Rec.region_id;
			      l_item_orderability_rules_rec.ORDER_TYPE_ID          := p_Item_Orderability_Import_Rec.order_type_id;
			      l_item_orderability_rules_rec.SHIP_TO_LOCATION_ID    := p_Item_Orderability_Import_Rec.SHIP_TO_LOCATION_ID;
			      l_item_orderability_rules_rec.SALES_CHANNEL_CODE     := p_Item_Orderability_Import_Rec.SALES_CHANNEL_CODE;
			      l_item_orderability_rules_rec.SALES_PERSON_ID        := p_Item_Orderability_Import_Rec.SALES_PERSON_ID;
			      l_item_orderability_rules_rec.END_CUSTOMER_ID        := p_Item_Orderability_Import_Rec.END_CUSTOMER_ID;
			      l_item_orderability_rules_rec.BILL_TO_LOCATION_ID    := p_Item_Orderability_Import_Rec.BILL_TO_LOCATION_ID;
			      l_item_orderability_rules_rec.DELIVER_TO_LOCATION_ID := p_Item_Orderability_Import_Rec.DELIVER_TO_LOCATION_ID;
			      l_item_orderability_rules_rec.ENABLE_FLAG            := 'Y';
			      l_item_orderability_rules_rec.CREATED_BY             := p_Item_Orderability_Import_Rec.created_by;
			      l_item_orderability_rules_rec.CREATION_DATE          := p_Item_Orderability_Import_Rec.creation_date;
			      l_item_orderability_rules_rec.LAST_UPDATED_BY        := p_Item_Orderability_Import_Rec.last_updated_by;
			      l_item_orderability_rules_rec.LAST_UPDATE_DATE       := p_Item_Orderability_Import_Rec.last_update_date;
			      l_item_orderability_rules_rec.CONTEXT                := p_Item_Orderability_Import_Rec.context;
			      l_item_orderability_rules_rec.ATTRIBUTE1             := p_Item_Orderability_Import_Rec.ATTRIBUTE1;
			      l_item_orderability_rules_rec.ATTRIBUTE2             := p_Item_Orderability_Import_Rec.ATTRIBUTE2;
			      l_item_orderability_rules_rec.ATTRIBUTE3             := p_Item_Orderability_Import_Rec.ATTRIBUTE3;
			      l_item_orderability_rules_rec.ATTRIBUTE4             := p_Item_Orderability_Import_Rec.ATTRIBUTE4;
			      l_item_orderability_rules_rec.ATTRIBUTE5             := p_Item_Orderability_Import_Rec.ATTRIBUTE5;
			      l_item_orderability_rules_rec.ATTRIBUTE6             := p_Item_Orderability_Import_Rec.ATTRIBUTE6;
			      l_item_orderability_rules_rec.ATTRIBUTE7             := p_Item_Orderability_Import_Rec.ATTRIBUTE7;
			      l_item_orderability_rules_rec.ATTRIBUTE8             := p_Item_Orderability_Import_Rec.ATTRIBUTE8;
			      l_item_orderability_rules_rec.ATTRIBUTE9             := p_Item_Orderability_Import_Rec.ATTRIBUTE9;
			      l_item_orderability_rules_rec.ATTRIBUTE10            := p_Item_Orderability_Import_Rec.ATTRIBUTE10;
			      l_item_orderability_rules_rec.ATTRIBUTE11            := p_Item_Orderability_Import_Rec.ATTRIBUTE11;
			      l_item_orderability_rules_rec.ATTRIBUTE12            := p_Item_Orderability_Import_Rec.ATTRIBUTE12;
			      l_item_orderability_rules_rec.ATTRIBUTE13            := p_Item_Orderability_Import_Rec.ATTRIBUTE13;
			      l_item_orderability_rules_rec.ATTRIBUTE14            := p_Item_Orderability_Import_Rec.ATTRIBUTE14;
			      l_item_orderability_rules_rec.ATTRIBUTE15            := p_Item_Orderability_Import_Rec.ATTRIBUTE15;
			      l_item_orderability_rules_rec.ATTRIBUTE16            := p_Item_Orderability_Import_Rec.ATTRIBUTE16;
			      l_item_orderability_rules_rec.ATTRIBUTE17            := p_Item_Orderability_Import_Rec.ATTRIBUTE17;
			      l_item_orderability_rules_rec.ATTRIBUTE18            := p_Item_Orderability_Import_Rec.ATTRIBUTE18;
			      l_item_orderability_rules_rec.ATTRIBUTE19            := p_Item_Orderability_Import_Rec.ATTRIBUTE19;
			      l_item_orderability_rules_rec.ATTRIBUTE20            := p_Item_Orderability_Import_Rec.ATTRIBUTE20;

			OE_ITORD_UTIL.Insert_Row( l_item_orderability_rules_rec
                              , l_status
                              , l_rowid
                              );

		IF l_rowid   IS NOT NULL then

				 select orderability_id into l_orderability_id
				 from oe_item_orderability_rules where rowid = l_rowid ;

				 p_Item_Orderability_Import_Rec.status := FND_API.G_RET_STS_SUCCESS;
	    	                 p_Item_Orderability_Import_Rec.msg_data      := 'Rule Created Successfully .Orderability_id ='||l_orderability_id;
		                 p_Item_Orderability_Import_Rec.msg_count     := 1;

		End If;


IF l_debug_level > 0 then
	oe_debug_pub.add('Leaving OE_ITORD_PUB.insert_rules');
End If;

Exception
	when others then
	 p_Item_Orderability_Import_Rec.status := FND_API.G_RET_STS_UNEXP_ERROR;
	 p_Item_Orderability_Import_Rec.msg_data      := SQLERRM;
	 p_Item_Orderability_Import_Rec.msg_count     := 1;


End insert_rules;


Procedure  Validate_rules_DFF (p_Item_Orderability_Import_Rec IN OUT NOCOPY OE_ITORD_PUB.Item_Orderability_Import_Rec )
IS
 l_debug_level   NUMBER := oe_debug_pub.g_debug_level;
BEGIN

IF l_debug_level > 0 then
	oe_debug_pub.add('Entering  OE_ITORD_PUB.Validate_rules_DFF ');
End If;


FND_FLEX_DESCVAL.Set_Context_Value
		   ( context_value   => p_Item_Orderability_Import_Rec.context);

FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE1'
                   ,  column_value  =>  p_Item_Orderability_Import_Rec.attribute1);

FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE2'
                   ,  column_value  =>  p_Item_Orderability_Import_Rec.attribute2);
FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE3'
                   ,  column_value  =>  p_Item_Orderability_Import_Rec.attribute3);
FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE4'
                   ,  column_value  =>  p_Item_Orderability_Import_Rec.attribute4);
FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE5'
                   ,  column_value  =>  p_Item_Orderability_Import_Rec.attribute5);
FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE6'
                   ,  column_value  =>  p_Item_Orderability_Import_Rec.attribute6);
FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE7'
                   ,  column_value  =>  p_Item_Orderability_Import_Rec.attribute7);
FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE8'
                   ,  column_value  =>  p_Item_Orderability_Import_Rec.attribute8);
FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE9'
                   ,  column_value  =>  p_Item_Orderability_Import_Rec.attribute9);
FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE10'
                   ,  column_value  =>  p_Item_Orderability_Import_Rec.attribute10);
FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE11'
                   ,  column_value  =>  p_Item_Orderability_Import_Rec.attribute11);
FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE12'
                   ,  column_value  =>  p_Item_Orderability_Import_Rec.attribute12);
FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE13'
                   ,  column_value  =>  p_Item_Orderability_Import_Rec.attribute13);
FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE14'
                   ,  column_value  =>  p_Item_Orderability_Import_Rec.attribute14);
FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE15'
                   ,  column_value  =>  p_Item_Orderability_Import_Rec.attribute15);
FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE16'
                   ,  column_value  =>  p_Item_Orderability_Import_Rec.attribute16);
FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE17'
                   ,  column_value  =>  p_Item_Orderability_Import_Rec.attribute17);

FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE18'
                   ,  column_value  =>  p_Item_Orderability_Import_Rec.attribute18);
FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE19'
                   ,  column_value  =>  p_Item_Orderability_Import_Rec.attribute19);
FND_FLEX_DESCVAL.Set_Column_Value
                  (   column_name   => 'ATTRIBUTE20'
                   ,  column_value  =>  p_Item_Orderability_Import_Rec.attribute20);


	IF FND_FLEX_DESCVAL.Validate_Desccols( appl_short_name => 'ONT' ,
					       desc_flex_name  =>'OE_ITORD_ATTRIBUTES'
					     )
	THEN
		p_Item_Orderability_Import_Rec.status := FND_API.G_RET_STS_SUCCESS;
		p_Item_Orderability_Import_Rec.msg_data      := 'VALID';
		p_Item_Orderability_Import_Rec.msg_count     := 1;
	ELSE
	         FND_MESSAGE.Set_Encoded(FND_FLEX_DESCVAL.Encoded_Error_Message);
		 p_Item_Orderability_Import_Rec.status := FND_API.G_RET_STS_ERROR;
	    	 p_Item_Orderability_Import_Rec.msg_data      := fnd_message.get;
		 p_Item_Orderability_Import_Rec.msg_count     := 1;
	END IF;




IF l_debug_level > 0 then
	oe_debug_pub.add('Leaving  OE_ITORD_PUB.Validate_rules_DFF ');
End If;

EXCEPTION

   WHEN OTHERS THEN
     p_Item_Orderability_Import_Rec.status := FND_API.G_RET_STS_UNEXP_ERROR;
     P_Item_Orderability_Import_Rec.msg_data      := SQLERRM;
     p_Item_Orderability_Import_Rec.msg_count     := 1;

END Validate_rules_DFF;



END OE_ITORD_PUB;

/
