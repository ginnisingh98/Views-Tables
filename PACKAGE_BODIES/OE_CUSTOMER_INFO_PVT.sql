--------------------------------------------------------
--  DDL for Package Body OE_CUSTOMER_INFO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_CUSTOMER_INFO_PVT" AS
/* $Header: OEXVCUSB.pls 120.0.12010000.3 2009/01/28 06:00:42 smanian noship $ */

G_PKG_NAME          VARCHAR2(100)        := 'OE_CUSTOMER_INFO_PVT';
G_CREATED_BY_MODULE VARCHAR2(100)        := 'ONT_OI_ADD_CUSTOMER';
G_EMAIL_REQUIRED            VARCHAR2(1);
G_AUTO_PARTY_NUMBERING      VARCHAR2(1);
G_AUTO_CUST_NUMBERING       VARCHAR2(1);
G_AUTO_CONTACT_NUMBERING    VARCHAR2(1);
G_AUTO_LOCATION_NUMBERING   VARCHAR2(1);
G_AUTO_SITE_NUMBERING       VARCHAR2(1);
G_ONT_ADD_CUSTOMER          VARCHAR2(1);


/* This procedure reads important profile options and system parameter values and store them in global variables */
PROCEDURE Initialize_Global( x_return_status OUT NOCOPY  Varchar2);


PROCEDURE Initialize_Global( x_return_status OUT NOCOPY  Varchar2)
IS
   l_sys_parm_rec           ar_system_parameters_all%rowtype;
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
Begin

 x_return_status            := FND_API.G_RET_STS_SUCCESS;

IF l_debug_level  > 0 THEN
	oe_debug_pub.add(  'ENTERING PROCEDURE INITIALIZE_GLOBAL' ) ;
END IF;

  l_Sys_Parm_Rec := OE_Sys_Parameters_Pvt.Get_AR_Sys_Params;

  fnd_profile.get('HZ_GENERATE_PARTY_NUMBER',G_AUTO_PARTY_NUMBERING);
  fnd_profile.get('HZ_GENERATE_PARTY_SITE_NUMBER',G_AUTO_SITE_NUMBERING);
  fnd_profile.get('ONT_MANDATE_CUSTOMER_EMAIL',G_EMAIL_REQUIRED);
  fnd_profile.get('HZ_GENERATE_CONTACT_NUMBER',G_AUTO_CONTACT_NUMBERING);
  fnd_profile.get('ONT_ADD_CUSTOMER_OI',G_ONT_ADD_CUSTOMER);

  G_AUTO_PARTY_NUMBERING    :=  NVL(G_AUTO_PARTY_NUMBERING,'Y');
  G_AUTO_CUST_NUMBERING     :=  NVL(l_sys_parm_rec.GENERATE_CUSTOMER_NUMBER,'Y');
  G_AUTO_LOCATION_NUMBERING :=  NVL(l_sys_parm_rec.AUTO_SITE_NUMBERING,'Y');
  G_AUTO_SITE_NUMBERING     :=  NVL(G_AUTO_SITE_NUMBERING, 'Y');
  G_EMAIL_REQUIRED          :=  NVL(G_EMAIL_REQUIRED,'Y');
  G_AUTO_CONTACT_NUMBERING  :=  NVL(G_AUTO_CONTACT_NUMBERING,'Y');
  G_ONT_ADD_CUSTOMER        :=  NVL(G_ONT_ADD_CUSTOMER,'Y');



IF l_debug_level  > 0 THEN
	oe_debug_pub.add('G_AUTO_PARTY_NUMBERING :'||G_AUTO_PARTY_NUMBERING);
	oe_debug_pub.add('G_AUTO_CUST_NUMBERING :'||G_AUTO_CUST_NUMBERING);
	oe_debug_pub.add('G_AUTO_LOCATION_NUMBERING :'||G_AUTO_LOCATION_NUMBERING);
	oe_debug_pub.add('G_AUTO_SITE_NUMBERING :'||G_AUTO_SITE_NUMBERING);
	oe_debug_pub.add('G_EMAIL_REQUIRED :'||G_EMAIL_REQUIRED);
	oe_debug_pub.add('G_AUTO_CONTACT_NUMBERING :'||G_AUTO_CONTACT_NUMBERING);
	oe_debug_pub.add('G_ONT_ADD_CUSTOMER :'||G_ONT_ADD_CUSTOMER);

	IF OE_GLOBALS.G_UPDATE_ON_ID THEN
		oe_debug_pub.add('OE_GLOBALS.G_UPDATE_ON_ID : TRUE');
	ELSE
		oe_debug_pub.add('OE_GLOBALS.G_UPDATE_ON_ID : FALSE');
	END IF;

	oe_debug_pub.add(  'EXITING PROCEDURE INITIALIZE_GLOBAL' ) ;

END IF;

Exception
   WHEN OTHERS THEN

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'PROBLEM IN CALL TO INITIALIZE_GLOBAL. ABORT PROCESSING'||SQLERRM ) ;
     END IF;
     x_return_status            := FND_API.G_RET_STS_UNEXP_ERROR;

     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Initialize_Global'
            );
     END IF;

End Initialize_Global;


/* This procedure will be called from OE_HEADER_UTIL and OE_LINE_UTIL packages
   to derive/create customer/address/contact related  information
*/

Procedure get_customer_info_ids
                         (
		          p_customer_info_tbl    IN OUT NOCOPY OE_ORDER_PUB.CUSTOMER_INFO_TABLE_TYPE,
		          p_operation_code       IN VARCHAR2,
			  p_sold_to_customer_ref IN VARCHAR2,
			  p_ship_to_customer_ref IN VARCHAR2,
			  p_bill_to_customer_ref IN VARCHAR2,
			  p_deliver_to_customer_ref IN VARCHAR2,

			  p_ship_to_address_ref IN VARCHAR2,
			  p_bill_to_address_ref IN VARCHAR2,
			  p_deliver_to_address_ref IN VARCHAR2,
			  p_sold_to_address_ref    IN VARCHAR2,

			  p_sold_to_contact_ref IN VARCHAR2,
			  p_ship_to_contact_ref IN VARCHAR2,
			  p_bill_to_contact_ref IN VARCHAR2,
			  p_deliver_to_contact_ref IN VARCHAR2,

			  p_sold_to_customer_id IN NUMBER,
			  p_ship_to_customer_id IN NUMBER,
			  p_bill_to_customer_id IN NUMBER,
			  p_deliver_to_customer_id IN NUMBER,

			  p_ship_to_org_id IN NUMBER,
			  p_invoice_to_org_id IN NUMBER,
			  p_deliver_to_org_id IN NUMBER,
			  p_sold_to_site_use_id IN NUMBER,

			  p_sold_to_contact_id IN NUMBER,
			  p_ship_to_contact_id IN NUMBER,
			  p_invoice_to_contact_id IN NUMBER,
			  p_deliver_to_contact_id IN NUMBER,


			  x_sold_to_customer_id OUT NOCOPY  NUMBER,
			  x_ship_to_customer_id OUT NOCOPY  NUMBER,
			  x_bill_to_customer_id OUT NOCOPY  NUMBER,
			  x_deliver_to_customer_id OUT NOCOPY  NUMBER,

			  x_ship_to_org_id OUT NOCOPY  NUMBER,
			  x_invoice_to_org_id OUT NOCOPY  NUMBER,
			  x_deliver_to_org_id OUT NOCOPY  NUMBER,
  			  x_sold_to_site_use_id OUT NOCOPY  NUMBER,

			  x_sold_to_contact_id OUT NOCOPY  NUMBER,
			  x_ship_to_contact_id OUT NOCOPY  NUMBER,
			  x_invoice_to_contact_id OUT NOCOPY  NUMBER,
			  x_deliver_to_contact_id OUT NOCOPY  NUMBER,


			  x_return_status   OUT NOCOPY VARCHAR2,
			  x_msg_count       OUT NOCOPY NUMBER,
			  x_msg_data        OUT NOCOPY VARCHAR2
			  ) IS
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;


l_sold_to_cust_found boolean := FALSE;
l_ship_to_cust_found boolean := FALSE;
l_bill_to_cust_found boolean := FALSE;
l_deliver_to_cust_found boolean := FALSE;

l_ship_addr_found boolean    := FALSE;
l_bill_addr_found boolean    := FALSE;
l_deliver_addr_found boolean := FALSE;
l_sold_addr_found boolean := FALSE;

l_sold_cont_found boolean    := FALSE;
l_ship_cont_found boolean    := FALSE;
l_bill_cont_found boolean    := FALSE;
l_deliver_cont_found boolean := FALSE;


l_sold_to_customer_rec OE_ORDER_PUB.CUSTOMER_INFO_REC_TYPE;
l_ship_to_customer_rec OE_ORDER_PUB.CUSTOMER_INFO_REC_TYPE;
l_bill_to_customer_rec OE_ORDER_PUB.CUSTOMER_INFO_REC_TYPE;
l_deliver_to_customer_rec OE_ORDER_PUB.CUSTOMER_INFO_REC_TYPE;

l_sold_to_cust_index NUMBER;
l_ship_to_cust_index NUMBER;
l_bill_to_cust_index NUMBER;
l_deliver_to_cust_index  NUMBER;

l_ship_addr_rec_index NUMBER;
l_bill_addr_rec_index NUMBER;
l_deliver_addr_rec_index NUMBER;
l_sold_addr_rec_index NUMBER;

l_sold_cont_rec_index NUMBER;
l_ship_cont_rec_index NUMBER;
l_bill_cont_rec_index NUMBER;
l_deliver_cont_rec_index NUMBER;


l_new_sold_to_org_id NUMBER;
l_new_ship_to_customer_id NUMBER;
l_new_bill_to_customer_id NUMBER;
l_new_deliver_to_cust_id  NUMBER;

l_new_sold_to_party_id NUMBER;
l_new_ship_to_party_id NUMBER;
l_new_bill_to_party_id NUMBER;
l_new_deliver_to_party_id  NUMBER;

l_customer_id NUMBER;
BEGIN

 IF l_debug_level > 0 THEN
	oe_debug_pub.add(' Entering OE_CUSTOMER_INFO_PVT.get_customer_info_ids'||p_customer_info_tbl.count);
 END IF;


Initialize_Global(x_return_status);

IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	x_return_status := FND_API.G_RET_STS_ERROR;
	RETURN;
END IF;


x_return_status := FND_API.G_RET_STS_SUCCESS;


x_sold_to_customer_id    := p_sold_to_customer_id;
x_ship_to_customer_id    := p_ship_to_customer_id;
x_bill_to_customer_id    := p_bill_to_customer_id;
x_deliver_to_customer_id := p_deliver_to_customer_id;

x_ship_to_org_id    := p_ship_to_org_id;
x_invoice_to_org_id := p_invoice_to_org_id;
x_deliver_to_org_id := p_deliver_to_org_id;

x_sold_to_contact_id    := p_sold_to_contact_id;
x_ship_to_contact_id    := p_ship_to_contact_id;
x_invoice_to_contact_id := p_invoice_to_contact_id;
x_deliver_to_contact_id := p_deliver_to_contact_id;


IF p_sold_to_customer_ref IS NOT NULL THEN

	FOR i in 1..p_customer_info_tbl.last LOOP
		 IF p_customer_info_tbl.exists(i) THEN
			 IF p_customer_info_tbl(i).customer_info_type_code = 'CUSTOMER' THEN
				IF p_customer_info_tbl(i).customer_info_ref = p_sold_to_customer_ref THEN

					IF l_sold_to_cust_found = FALSE THEN
					   l_sold_to_cust_found := TRUE;
					   l_sold_to_cust_index := i;
					   l_sold_to_customer_rec := p_customer_info_tbl(i);
					END IF;
				END IF;
			 END IF;
		 END IF;
	END LOOP;

END IF;


IF p_ship_to_customer_ref IS NOT NULL THEN

	FOR i in 1..p_customer_info_tbl.last LOOP
		IF p_customer_info_tbl.exists(i) THEN
			 IF p_customer_info_tbl(i).customer_info_type_code = 'CUSTOMER' THEN
				IF p_customer_info_tbl(i).customer_info_ref = p_ship_to_customer_ref THEN
					IF l_ship_to_cust_found = FALSE THEN
					   l_ship_to_cust_found := TRUE;
					   l_ship_to_cust_index := i;
					   l_ship_to_customer_rec := p_customer_info_tbl(i);
					END IF;
				END IF;
			 END IF;
		END IF;
	END LOOP;

END IF;

IF p_bill_to_customer_ref IS NOT NULL THEN

	FOR i in 1..p_customer_info_tbl.last LOOP
		IF p_customer_info_tbl.exists(i) THEN
			 IF p_customer_info_tbl(i).customer_info_type_code = 'CUSTOMER' THEN
				IF p_customer_info_tbl(i).customer_info_ref = p_bill_to_customer_ref THEN
					IF l_bill_to_cust_found = FALSE THEN
					   l_bill_to_cust_found := TRUE;
					   l_bill_to_cust_index := i;
					   l_bill_to_customer_rec := p_customer_info_tbl(i);
					END IF;
				END IF;
			 END IF;
		END IF;
	END LOOP;

END IF;

IF p_deliver_to_customer_ref IS NOT NULL THEN

	FOR i in 1..p_customer_info_tbl.last LOOP
		IF p_customer_info_tbl.exists(i) THEN
			 IF p_customer_info_tbl(i).customer_info_type_code = 'CUSTOMER' THEN
				IF p_customer_info_tbl(i).customer_info_ref = p_deliver_to_customer_ref THEN
					IF l_deliver_to_cust_found = FALSE THEN
					   l_deliver_to_cust_found := TRUE;
					   l_deliver_to_cust_index := i;
					   l_deliver_to_customer_rec := p_customer_info_tbl(i);
					END IF;
				END IF;
			 END IF;
		END IF;
       END LOOP;

END IF;

IF l_debug_level > 0 THEN

	IF l_sold_to_cust_found THEN
		oe_debug_pub.add('Sold to customer record  passed :'||l_sold_to_cust_index);
	END IF;

        IF l_ship_to_cust_found THEN
		oe_debug_pub.add('Ship to customer record  passed :'||l_ship_to_cust_index);
	END IF;

        IF l_bill_to_cust_found THEN
		oe_debug_pub.add('Bill to customer record  passed :'||l_bill_to_cust_index);
	END IF;

	IF l_deliver_to_cust_found THEN
		oe_debug_pub.add('Sold to customer record  passed :'||l_deliver_to_cust_index);
	END IF;

        oe_debug_pub.add('Check for Permissions :'||G_ONT_ADD_CUSTOMER);
END IF;


IF G_ONT_ADD_CUSTOMER = 'N' THEN  /* Nothing allowed */

	 fnd_message.set_name('ONT','ONT_OI_INL_SET_PARAMETER');
         fnd_message.set_token('TYPE', 'Customers, Addresses or Contacts');
         oe_msg_pub.add;
         x_return_status := FND_API.G_RET_STS_ERROR;
	 RETURN;

ELSIF  G_ONT_ADD_CUSTOMER = 'P' THEN  /* Address and contact can be added to an exisiting customer */

	GOTO ADDRESS_CREATION;

ELSE   /* Evering allowed */

	  IF l_debug_level > 0 THEN
		oe_debug_pub.add('No restriction to create customer/address and contact.Continue...');
	  END IF;
END IF;

IF l_debug_level > 0 THEN
	oe_debug_pub.add('Start Creating customers (SOLD_TO/SHIP_TO/BILL_TO/DELIVER_TO) if records are passed');
END IF;

/*
1.Check whether customer_id is sent
2.If customer_id is not sent check whether value is sent and try to derive id from value
3.If customer_id is sent then see if value is aslo sent and try to update the value on the id ig OE_GLOBALS.G_UPDATE_ON_ID is true
4.If customer_id could not be resolved till step 3,create the customer
5. Check for minimum required fields
6.Validate customer related fields
7. call TCA API to create the customer
*/

IF l_sold_to_cust_found
THEN

	IF l_debug_level > 0 THEN
		oe_debug_pub.add('l_sold_to_customer_rec.customer_id :'||l_sold_to_customer_rec.customer_id);
	END IF;

	IF NVL(l_sold_to_customer_rec.customer_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM  THEN

		Check_Duplicate_Customer( p_customer_record => l_sold_to_customer_rec
					 , p_type           => 'SOLD_TO'
			                 , x_customer_id    => l_new_sold_to_org_id
					 );

		IF l_new_sold_to_org_id = FND_API.G_MISS_NUM THEN
			oe_msg_pub.delete_msg(oe_msg_pub.g_msg_count);
		ELSE
			x_sold_to_customer_id := l_new_sold_to_org_id;
			p_customer_info_tbl(l_sold_to_cust_index).new_account_id := l_new_sold_to_org_id;
		END IF;

		IF l_debug_level > 0 THEN
			oe_debug_pub.add('l_new_sold_to_org_id:'||l_new_sold_to_org_id);
		END IF;

	ELSE
		IF IS_BOTH_ID_VAL_PASSED( p_customer_rec => l_sold_to_customer_rec )
	           AND OE_GLOBALS.G_UPDATE_ON_ID
		THEN

			Update_Customer (p_customer_rec => l_sold_to_customer_rec
					 , x_return_status =>x_return_status
		                         );
			IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

				IF l_debug_level > 0 THEN
					oe_debug_pub.add ('Updating Customer information failed,returning');
				END IF;

				RETURN;
			END IF;
		END IF;

		l_new_sold_to_org_id   := l_sold_to_customer_rec.customer_id;
		x_sold_to_customer_id := l_sold_to_customer_rec.customer_id;
		p_customer_info_tbl(l_sold_to_cust_index).new_account_id := l_sold_to_customer_rec.customer_id;

	END IF;


	IF NVL(l_new_sold_to_org_id,FND_API.G_MISS_NUM) =  FND_API.G_MISS_NUM THEN

			Check_Customer_Fields(l_sold_to_customer_rec,x_return_status);

			IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
				IF l_debug_level > 0 THEN
					oe_debug_pub.add ('Check_Customer_Fields failed,returning');
				END IF;

				RETURN;
			END IF;

			Validate_Customer_Fields(l_sold_to_customer_rec,x_return_status);

			IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
				IF l_debug_level > 0 THEN
					oe_debug_pub.add ('Validate_Customer_Fields failed,returning');
				END IF;

				RETURN;
			END IF;
	END IF;

	IF  NVL(l_new_sold_to_org_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM THEN
			Create_account (
				  p_header_customer_info_rec => l_sold_to_customer_rec,
				  x_cust_account_id  =>l_new_sold_to_org_id,
				  x_party_id         =>l_new_sold_to_party_id,
				  x_return_status   =>x_return_status,
				  x_msg_count       =>x_msg_count,
				  x_msg_data        => x_msg_data
				  );


			IF l_debug_level > 0 THEN
				oe_debug_pub.add(' Create_account : x_return_status :'||x_return_status);
				oe_debug_pub.add(' Create_account : l_new_sold_to_party_id :'||l_new_sold_to_party_id);
				oe_debug_pub.add(' Create_account : l_new_sold_to_org_id :'||l_new_sold_to_org_id);
				oe_debug_pub.add(' Create_account : x_msg_count :'||x_msg_count);
				oe_debug_pub.add(' Create_account : x_msg_data :'||x_msg_data);
			END IF;

			IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
  			   oe_msg_pub.transfer_msg_stack;
			   RETURN;
			END IF;


	END IF;

		x_sold_to_customer_id := l_new_sold_to_org_id;
		p_customer_info_tbl(l_sold_to_cust_index).new_account_id := l_new_sold_to_org_id;


END IF;

IF l_debug_level > 0 THEN
	oe_debug_pub.add(' Step 1 :Completed ');
END IF;


/*
1.Check whether customer_id is sent
2.If customer_id is not sent check whether value is sent and try to derive id from value
3.If customer_id is sent then see if value is aslo sent and try to update the value on the id ig OE_GLOBALS.G_UPDATE_ON_ID is true
4.If customer_id could not be resolved till step 3,create the customer
5. Check for minimum required fields
6.Validate customer related fields
7. call TCA API to create the customer
*/


IF l_ship_to_cust_found
THEN

IF l_debug_level > 0 THEN
	oe_debug_pub.add('l_ship_to_customer_rec.customer_id :'||l_ship_to_customer_rec.customer_id);
END IF;

IF NVL(l_ship_to_customer_rec.customer_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM  THEN
	Check_Duplicate_Customer( p_customer_record => l_ship_to_customer_rec
				 , p_type           => 'SHIP_TO'
			         , x_customer_id    => l_new_ship_to_customer_id
				 );

	IF l_new_ship_to_customer_id = FND_API.G_MISS_NUM THEN
		oe_msg_pub.delete_msg(oe_msg_pub.g_msg_count);
	ELSE
		x_ship_to_customer_id  := l_new_ship_to_customer_id;
	        p_customer_info_tbl(l_ship_to_cust_index).new_account_id := l_new_ship_to_customer_id;
	END IF;


	IF l_debug_level > 0 THEN
		oe_debug_pub.add('l_new_ship_to_customer_id :'||l_new_ship_to_customer_id);
		oe_debug_pub.add('l_new_ship_to_party_id :'||l_new_ship_to_party_id);
	END IF;

ELSE
           IF IS_BOTH_ID_VAL_PASSED( p_customer_rec => l_ship_to_customer_rec )
	   AND OE_GLOBALS.G_UPDATE_ON_ID
	   THEN
			Update_Customer (p_customer_rec => l_ship_to_customer_rec
					 , x_return_status =>x_return_status
		                         );
			IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
				IF l_debug_level > 0 THEN
					oe_debug_pub.add('Update_Customer failed  ,returning');
				END IF;
				RETURN;
			END IF;
       END IF;

       l_new_ship_to_customer_id := l_ship_to_customer_rec.customer_id;
       x_ship_to_customer_id  := l_ship_to_customer_rec.customer_id;
       p_customer_info_tbl(l_ship_to_cust_index).new_account_id := l_ship_to_customer_rec.customer_id;
END IF;

	IF NVL(l_new_ship_to_customer_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM  THEN

		Check_Customer_Fields(l_ship_to_customer_rec,x_return_status);

		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			IF l_debug_level > 0 THEN
				oe_debug_pub.add('Check_Customer_Fields failed  ,returning');
			END IF;

			RETURN;
		END IF;

		Validate_Customer_Fields(l_ship_to_customer_rec,x_return_status);

		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			IF l_debug_level > 0 THEN
				oe_debug_pub.add('Validate_Customer_Fields failed  ,returning');
			END IF;

			RETURN;
		END IF;

	END IF;

	IF  NVL(l_new_ship_to_customer_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM
	THEN
		Create_account (
				  p_header_customer_info_rec => l_ship_to_customer_rec,
				  x_cust_account_id  =>l_new_ship_to_customer_id,
				  x_party_id         =>l_new_ship_to_party_id,
				  x_return_status   =>x_return_status,
				  x_msg_count       =>x_msg_count,
				  x_msg_data        => x_msg_data
				  );

		IF l_debug_level > 0 THEN
				oe_debug_pub.add(' Create_account : x_return_status :'||x_return_status);
				oe_debug_pub.add(' Create_account : l_new_ship_to_party_id :'||l_new_ship_to_party_id);
				oe_debug_pub.add(' Create_account : l_new_ship_to_customer_id :'||l_new_ship_to_customer_id);
				oe_debug_pub.add(' Create_account : x_msg_count :'||x_msg_count);
				oe_debug_pub.add(' Create_account : x_msg_data :'||x_msg_data);
		END IF;

		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   oe_msg_pub.transfer_msg_stack;
		   RETURN;
		END IF;
	END IF;

		x_ship_to_customer_id  := l_new_ship_to_customer_id;
 	        p_customer_info_tbl(l_ship_to_cust_index).new_account_id := l_new_ship_to_customer_id;
END IF;

IF l_debug_level > 0 THEN
	oe_debug_pub.add(' Step 2 :Completed ');
END IF;


IF l_bill_to_cust_found
THEN

IF l_debug_level > 0 THEN
	oe_debug_pub.add('l_bill_to_customer_rec.customer_id:'||l_bill_to_customer_rec.customer_id);
END IF;

IF NVL(l_bill_to_customer_rec.customer_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM  THEN

	Check_Duplicate_Customer( p_customer_record => l_bill_to_customer_rec
					 , p_type           => 'BILL_TO'
			                 , x_customer_id    => l_new_bill_to_customer_id
					 );


	IF l_new_bill_to_customer_id = FND_API.G_MISS_NUM THEN
		oe_msg_pub.delete_msg(oe_msg_pub.g_msg_count);
	ELSE
		x_bill_to_customer_id  := l_new_bill_to_customer_id;
		p_customer_info_tbl(l_bill_to_cust_index).new_account_id := l_new_bill_to_customer_id;
	END IF;

	IF l_debug_level > 0 THEN
		oe_debug_pub.add('l_new_bill_to_customer_id:'||l_new_bill_to_customer_id);
		oe_debug_pub.add('l_new_bill_to_party_id:'||l_new_bill_to_party_id);
	END IF;
ELSE
      IF IS_BOTH_ID_VAL_PASSED( p_customer_rec => l_bill_to_customer_rec )
	   AND OE_GLOBALS.G_UPDATE_ON_ID
      THEN

		Update_Customer (p_customer_rec => l_bill_to_customer_rec
					 , x_return_status =>x_return_status
		                         );

		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			IF l_debug_level > 0 THEN
				oe_debug_pub.add('Update_Customer failed  ,returning');
			END IF;
			RETURN;
		END IF;

      END IF;

	l_new_bill_to_customer_id := l_bill_to_customer_rec.customer_id;
	x_bill_to_customer_id  := l_bill_to_customer_rec.customer_id;
	p_customer_info_tbl(l_bill_to_cust_index).new_account_id := l_bill_to_customer_rec.customer_id;

END IF;

	IF NVL(l_new_bill_to_customer_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM THEN

		Check_Customer_Fields(l_bill_to_customer_rec,x_return_status);

		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			IF l_debug_level > 0 THEN
				oe_debug_pub.add('Check_Customer_Fields failed  ,returning');
			END IF;

			RETURN;
		END IF;

		Validate_Customer_Fields(l_bill_to_customer_rec,x_return_status);

		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			IF l_debug_level > 0 THEN
				oe_debug_pub.add('Validate_Customer_Fields failed  ,returning');
			END IF;

			RETURN;
		END IF;

	END IF;

	IF  NVL(l_new_bill_to_customer_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM
	THEN
		Create_account (
				  p_header_customer_info_rec => l_bill_to_customer_rec,
				  x_cust_account_id  =>l_new_bill_to_customer_id,
				  x_party_id         =>l_new_bill_to_party_id,
				  x_return_status   =>x_return_status,
				  x_msg_count       =>x_msg_count,
				  x_msg_data        => x_msg_data
				  );

		IF l_debug_level > 0 THEN
				oe_debug_pub.add(' Create_account : x_return_status :'||x_return_status);
				oe_debug_pub.add(' Create_account : l_new_bill_to_party_id :'||l_new_bill_to_party_id);
				oe_debug_pub.add(' Create_account : l_new_bill_to_customer_id :'||l_new_bill_to_customer_id);
				oe_debug_pub.add(' Create_account : x_msg_count :'||x_msg_count);
				oe_debug_pub.add(' Create_account : x_msg_data :'||x_msg_data);
		END IF;

		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   oe_msg_pub.transfer_msg_stack;
		   RETURN;
		END IF;

	END IF;

		x_bill_to_customer_id  := l_new_bill_to_customer_id;
	        p_customer_info_tbl(l_bill_to_cust_index).new_account_id := l_new_bill_to_customer_id;

END IF;

IF l_debug_level > 0 THEN
	oe_debug_pub.add(' Step 3 :Completed ');
END IF;


IF l_deliver_to_cust_found
THEN

IF l_debug_level > 0 THEN
	oe_Debug_pub.add('l_deliver_to_customer_rec.customer_id:'||l_deliver_to_customer_rec.customer_id);
END IF;

IF NVL(l_deliver_to_customer_rec.customer_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM  THEN

	Check_Duplicate_Customer( p_customer_record => l_deliver_to_customer_rec
				 , p_type           => 'DELIVER_TO'
		                 , x_customer_id    => l_new_deliver_to_cust_id
				 );


	IF l_new_deliver_to_cust_id = FND_API.G_MISS_NUM THEN
		oe_msg_pub.delete_msg(oe_msg_pub.g_msg_count);
	ELSE
		x_deliver_to_customer_id := l_new_deliver_to_cust_id;
		p_customer_info_tbl(l_deliver_to_cust_index).new_account_id := l_new_deliver_to_cust_id;
	END IF;

	IF l_debug_level > 0 THEN
		oe_Debug_pub.add('l_new_deliver_to_cust_id :'||l_new_deliver_to_cust_id);
		oe_Debug_pub.add('l_new_deliver_to_party_id :'||l_new_deliver_to_party_id);
	END IF;

ELSE
	IF IS_BOTH_ID_VAL_PASSED( p_customer_rec => l_deliver_to_customer_rec )
	   AND OE_GLOBALS.G_UPDATE_ON_ID
	THEN

			Update_Customer (p_customer_rec => l_deliver_to_customer_rec
					 , x_return_status =>x_return_status
		                         );
			IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
				IF l_debug_level > 0 THEN
					oe_debug_pub.add('Update_Customer failed  ,returning');
				END IF;

				RETURN;
			END IF;

        END IF;

	l_new_deliver_to_cust_id  := l_deliver_to_customer_rec.customer_id;
	x_deliver_to_customer_id := l_deliver_to_customer_rec.customer_id;
	p_customer_info_tbl(l_deliver_to_cust_index).new_account_id := l_deliver_to_customer_rec.customer_id;

END IF;

	IF NVL(l_new_deliver_to_cust_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM THEN

		Check_Customer_Fields(l_deliver_to_customer_rec,x_return_status);

		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			IF l_debug_level > 0 THEN
				oe_debug_pub.add('Check_Customer_Fields failed  ,returning');
			END IF;

			RETURN;
		END IF;

		Validate_Customer_Fields(l_deliver_to_customer_rec,x_return_status);

		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			IF l_debug_level > 0 THEN
				oe_debug_pub.add('Validate_Customer_Fields failed  ,returning');
			END IF;

			RETURN;
		END IF;


	END IF;

	IF  NVL(l_new_deliver_to_cust_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM
    	THEN
		Create_account (  p_header_customer_info_rec => l_deliver_to_customer_rec,
				  x_cust_account_id  =>l_new_deliver_to_cust_id,
				  x_party_id         =>l_new_deliver_to_party_id ,
				  x_return_status   =>x_return_status,
				  x_msg_count       =>x_msg_count,
				  x_msg_data        => x_msg_data
				  );


		IF l_debug_level > 0 THEN
			oe_debug_pub.add(' Create_account : x_return_status :'||x_return_status);
			oe_debug_pub.add(' Create_account : l_new_deliver_to_party_id :'||l_new_bill_to_party_id);
			oe_debug_pub.add(' Create_account : l_new_deliver_to_cust_id :'||l_new_bill_to_customer_id);
			oe_debug_pub.add(' Create_account : x_msg_count :'||x_msg_count);
			oe_debug_pub.add(' Create_account : x_msg_data :'||x_msg_data);
		END IF;


		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   oe_msg_pub.transfer_msg_stack;
		   RETURN;
		END IF;

	END IF;

		x_deliver_to_customer_id := l_new_deliver_to_cust_id;
		p_customer_info_tbl(l_deliver_to_cust_index).new_account_id := l_new_deliver_to_cust_id;
END IF;


--Create Relationship b/w customers
IF ( NVL(x_sold_to_customer_id,FND_API.G_MISS_NUM)<> FND_API.G_MISS_NUM ) THEN

Create_relationships (  p_sold_to_customer_id => x_sold_to_customer_id,
			p_ship_to_customer_id => x_ship_to_customer_id,
			p_bill_to_customer_id => x_bill_to_customer_id,
			p_deliver_to_cust_id  => x_deliver_to_customer_id,
			x_return_status   =>x_return_status ,
			x_msg_count       => x_msg_count,
			x_msg_data        =>x_msg_data);

IF l_debug_level > 0 THEN
	oe_debug_pub.add('Create_relationships :x_return_status : '||x_return_status);
	oe_debug_pub.add('Create_relationships :x_msg_data : '||x_msg_count);
	oe_debug_pub.add('Create_relationships :x_msg_data : '||x_msg_data);
END IF;

IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	oe_msg_pub.transfer_msg_stack;
	RETURN;
END IF;

END IF;
--End  of create_relationship

<< ADDRESS_CREATION >>
--Address Creation starts for customers

IF p_ship_to_address_ref IS NOT NULL THEN

	FOR i in 1..p_customer_info_tbl.last LOOP
	   IF p_customer_info_tbl.exists(i) THEN
		IF p_customer_info_tbl(i).customer_info_type_code ='ADDRESS' THEN
			IF p_customer_info_tbl(i).customer_info_ref = p_ship_to_address_ref THEN
				IF p_customer_info_tbl(i).customer_id IS  NULL THEN --Both Cust and address being created in this call

					FOR j in 1..p_customer_info_tbl.last LOOP
					    IF p_customer_info_tbl.exists(j) THEN
						IF p_customer_info_tbl(j).customer_info_ref = p_customer_info_tbl(i).parent_customer_info_ref
						AND p_customer_info_tbl(j).customer_info_type_code = 'CUSTOMER' THEN
							IF l_ship_addr_found = FALSE THEN
								l_ship_addr_found := TRUE;
								l_ship_addr_rec_index := i;
								l_customer_id         := p_customer_info_tbl(j).new_account_id;
							END IF;
						END IF;
					     END IF;
					END LOOP;
				ELSE --Address being added to existing customer

					IF l_ship_addr_found = FALSE THEN
						l_ship_addr_found := TRUE;
						l_ship_addr_rec_index := i;
						l_customer_id         := p_customer_info_tbl(i).customer_id;
					END IF;


				END IF;

			END IF;
		END IF;
	   END IF;
	END LOOP;
END IF;



IF l_ship_addr_found THEN

	IF NOT IS_VALID_ID( p_customer_id => l_customer_id ) THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MESSAGE.set_name('ONT','OE_INVALID_ATTRIBUTE');
		FND_MESSAGE.SET_TOKEN('ATTRIBUTE','CUSTOMER_ID');
		OE_MSG_PUB.Add;
		RETURN;
	END IF;


	Create_Addresses (
	  p_customer_info_tbl => p_customer_info_tbl
	, p_operation_code    => p_operation_code
	, p_customer_id       => l_customer_id
	, p_address_rec_index => l_ship_addr_rec_index
	, p_address_usage     => 'SHIP_TO'
	, p_sold_to_customer_id => x_sold_to_customer_id
	, p_ship_to_customer_id => x_ship_to_customer_id
	, p_bill_to_customer_id  => x_bill_to_customer_id
	, p_deliver_to_customer_id =>x_deliver_to_customer_id
	, x_ship_to_org_id        => x_ship_to_org_id
	, x_invoice_to_org_id     => x_invoice_to_org_id
	, x_deliver_to_org_id     => x_deliver_to_org_id
	, x_sold_to_site_use_id   => x_sold_to_site_use_id
	, x_return_status     => x_return_status
	, x_msg_count         => x_msg_count
	, x_msg_data          => x_msg_data
	) ;

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		RETURN;
	END IF;
END IF;


IF p_bill_to_address_ref IS NOT NULL THEN

	FOR i in 1..p_customer_info_tbl.last LOOP
	  IF p_customer_info_tbl.exists(i) THEN
		IF p_customer_info_tbl(i).customer_info_type_code ='ADDRESS' THEN
			IF p_customer_info_tbl(i).customer_info_ref = p_bill_to_address_ref THEN
				IF p_customer_info_tbl(i).customer_id IS  NULL THEN --Both Cust and address being created in this call

					FOR j in 1..p_customer_info_tbl.last LOOP
					    IF p_customer_info_tbl.exists(j) THEN
						IF p_customer_info_tbl(j).customer_info_ref = p_customer_info_tbl(i).parent_customer_info_ref
						AND p_customer_info_tbl(j).customer_info_type_code = 'CUSTOMER' THEN
							IF l_bill_addr_found = FALSE THEN
								l_bill_addr_found := TRUE;
								l_bill_addr_rec_index := i;
								l_customer_id         := p_customer_info_tbl(j).new_account_id;
							END IF;
						END IF;
					     END IF;
					END LOOP;

				ELSE

					IF l_bill_addr_found = FALSE THEN
						l_bill_addr_found := TRUE;
						l_bill_addr_rec_index := i;
						l_customer_id         := p_customer_info_tbl(i).customer_id;
					END IF;


				END IF;

			END IF;
		END IF;
           END IF;
	END LOOP;

END IF;


IF l_bill_addr_found THEN

	IF NOT IS_VALID_ID( p_customer_id => l_customer_id ) THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MESSAGE.set_name('ONT','OE_INVALID_ATTRIBUTE');
		FND_MESSAGE.SET_TOKEN('ATTRIBUTE','CUSTOMER_ID');
		OE_MSG_PUB.Add;
		RETURN;
	END IF;


	Create_Addresses (
	  p_customer_info_tbl => p_customer_info_tbl
	, p_operation_code    => p_operation_code
	, p_customer_id       => l_customer_id
	, p_address_rec_index => l_bill_addr_rec_index
	, p_address_usage     => 'BILL_TO'
	, p_sold_to_customer_id => x_sold_to_customer_id
	, p_ship_to_customer_id => x_ship_to_customer_id
	, p_bill_to_customer_id  => x_bill_to_customer_id
	, p_deliver_to_customer_id => x_deliver_to_customer_id
	, x_ship_to_org_id        => x_ship_to_org_id
	, x_invoice_to_org_id     => x_invoice_to_org_id
	, x_deliver_to_org_id     => x_deliver_to_org_id
	, x_sold_to_site_use_id   => x_sold_to_site_use_id
	, x_return_status     => x_return_status
	, x_msg_count         => x_msg_count
	, x_msg_data          => x_msg_data
	) ;

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		RETURN;
	END IF;

END IF;

IF p_deliver_to_address_ref IS NOT NULL THEN

	FOR i in 1..p_customer_info_tbl.last LOOP
	   IF p_customer_info_tbl.exists(i) THEN
		IF p_customer_info_tbl(i).customer_info_type_code ='ADDRESS' THEN
			IF p_customer_info_tbl(i).customer_info_ref = p_deliver_to_address_ref THEN
				IF p_customer_info_tbl(i).customer_id IS  NULL THEN --Both Cust and address being created in this call

					FOR j in 1..p_customer_info_tbl.last LOOP
					   IF p_customer_info_tbl.exists(j) THEN
						IF p_customer_info_tbl(j).customer_info_ref = p_customer_info_tbl(i).parent_customer_info_ref
						AND p_customer_info_tbl(j).customer_info_type_code = 'CUSTOMER' THEN
							IF l_deliver_addr_found = FALSE THEN
								l_deliver_addr_found := TRUE;
								l_deliver_addr_rec_index := i;
								l_customer_id         := p_customer_info_tbl(j).new_account_id;
							END IF;
						END IF;
					   END IF;
					END LOOP;
				ELSE

					IF l_deliver_addr_found = FALSE THEN
						l_deliver_addr_found := TRUE;
						l_deliver_addr_rec_index := i;
						l_customer_id         := p_customer_info_tbl(i).customer_id;
					END IF;


				END IF;

			END IF;
		END IF;
	   END IF;
	END LOOP;

END IF;


IF l_deliver_addr_found THEN

	IF NOT IS_VALID_ID( p_customer_id => l_customer_id ) THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MESSAGE.set_name('ONT','OE_INVALID_ATTRIBUTE');
		FND_MESSAGE.SET_TOKEN('ATTRIBUTE','CUSTOMER_ID');
		OE_MSG_PUB.Add;
		RETURN;
	END IF;


	Create_Addresses (
	  p_customer_info_tbl => p_customer_info_tbl
  	, p_operation_code    => p_operation_code
	, p_customer_id       => l_customer_id
	, p_address_rec_index => l_deliver_addr_rec_index
	, p_address_usage     => 'DELIVER_TO'
	, p_sold_to_customer_id => x_sold_to_customer_id
	, p_ship_to_customer_id => x_ship_to_customer_id
	, p_bill_to_customer_id  => x_bill_to_customer_id
	, p_deliver_to_customer_id => x_deliver_to_customer_id
	, x_ship_to_org_id        => x_ship_to_org_id
	, x_invoice_to_org_id     => x_invoice_to_org_id
	, x_deliver_to_org_id     => x_deliver_to_org_id
	, x_sold_to_site_use_id   => x_sold_to_site_use_id
	, x_return_status     => x_return_status
	, x_msg_count         => x_msg_count
	, x_msg_data          => x_msg_data
	) ;

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		RETURN;
	END IF;

END IF;

IF p_sold_to_address_ref IS NOT NULL THEN

	FOR i in 1..p_customer_info_tbl.last LOOP
	   IF p_customer_info_tbl.exists(i) THEN
		IF p_customer_info_tbl(i).customer_info_type_code ='ADDRESS' THEN
			IF p_customer_info_tbl(i).customer_info_ref = p_sold_to_address_ref THEN
				IF p_customer_info_tbl(i).customer_id IS  NULL THEN --Both Cust and address being created in this call

					FOR j in 1..p_customer_info_tbl.last LOOP
					   IF p_customer_info_tbl.exists(j) THEN
						IF p_customer_info_tbl(j).customer_info_ref = p_customer_info_tbl(i).parent_customer_info_ref
						AND p_customer_info_tbl(j).customer_info_type_code = 'CUSTOMER' THEN
							IF l_sold_addr_found = FALSE THEN
								l_sold_addr_found := TRUE;
								l_sold_addr_rec_index := i;
								l_customer_id         := p_customer_info_tbl(j).new_account_id;
							END IF;
						END IF;
					   END IF;
					END LOOP;
				ELSE

					IF l_sold_addr_found = FALSE THEN
						l_sold_addr_found := TRUE;
						l_sold_addr_rec_index := i;
						l_customer_id         := p_customer_info_tbl(i).customer_id;
					END IF;


				END IF;

			END IF;
		END IF;
	   END IF;
	END LOOP;

END IF;


IF l_sold_addr_found THEN

	IF NOT IS_VALID_ID( p_customer_id => l_customer_id ) THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MESSAGE.set_name('ONT','OE_INVALID_ATTRIBUTE');
		FND_MESSAGE.SET_TOKEN('ATTRIBUTE','CUSTOMER_ID');
		OE_MSG_PUB.Add;
		RETURN;
	END IF;

	Create_Addresses (
	  p_customer_info_tbl => p_customer_info_tbl
  	, p_operation_code    => p_operation_code
	, p_customer_id       => l_customer_id
	, p_address_rec_index => l_sold_addr_rec_index
	, p_address_usage     => 'SOLD_TO'
	, p_sold_to_customer_id => x_sold_to_customer_id
	, p_ship_to_customer_id => x_ship_to_customer_id
	, p_bill_to_customer_id  => x_bill_to_customer_id
	, p_deliver_to_customer_id => x_deliver_to_customer_id
	, x_ship_to_org_id        => x_ship_to_org_id
	, x_invoice_to_org_id     => x_invoice_to_org_id
	, x_deliver_to_org_id     => x_deliver_to_org_id
	, x_sold_to_site_use_id   => x_sold_to_site_use_id
	, x_return_status     => x_return_status
	, x_msg_count         => x_msg_count
	, x_msg_data          => x_msg_data
	) ;

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		RETURN;
	END IF;

END IF;




--Contacts

IF  p_sold_to_contact_ref IS NOT NULL THEN

FOR i in 1..p_customer_info_tbl.last LOOP
	IF p_customer_info_tbl.exists(i) THEN
		IF p_customer_info_tbl(i).customer_info_type_code ='CONTACT' THEN
			IF p_customer_info_tbl(i).customer_info_ref = p_sold_to_contact_ref THEN
				IF p_customer_info_tbl(i).customer_id IS  NULL THEN --Both Cust and address being created in this call

					FOR j in 1..p_customer_info_tbl.last LOOP
					   IF p_customer_info_tbl.exists(j) THEN
						IF p_customer_info_tbl(j).customer_info_ref = p_customer_info_tbl(i).parent_customer_info_ref
						AND p_customer_info_tbl(j).customer_info_type_code = 'CUSTOMER' THEN
							IF l_sold_cont_found = FALSE THEN
								l_sold_cont_found := TRUE;
								l_sold_cont_rec_index := i;
								l_customer_id         := p_customer_info_tbl(j).new_account_id;
							END IF;
						END IF;
					    END IF;
					END LOOP;
				ELSE

					IF l_sold_cont_found = FALSE THEN
						l_sold_cont_found := TRUE;
						l_sold_cont_rec_index := i;
						l_customer_id         := p_customer_info_tbl(i).customer_id;
					END IF;


				END IF;

			END IF;
		END IF;
	END IF;
END LOOP;

END IF;


IF l_sold_cont_found THEN

	IF NOT IS_VALID_ID( p_customer_id => l_customer_id ) THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MESSAGE.set_name('ONT','OE_INVALID_ATTRIBUTE');
		FND_MESSAGE.SET_TOKEN('ATTRIBUTE','CUSTOMER_ID');
		OE_MSG_PUB.Add;
		RETURN;
	END IF;

Create_Contact (  p_customer_info_tbl => p_customer_info_tbl
	  , p_operation_code    => p_operation_code
	  , p_customer_id        => l_customer_id
	  , p_customer_rec_index => l_sold_cont_rec_index
	  , p_usage_code         => 'SOLD_TO'
	  , x_sold_to_contact_id => x_sold_to_contact_id
  	  , x_ship_to_contact_id => x_ship_to_contact_id
	  , x_invoice_to_contact_id => x_invoice_to_contact_id
	  , x_deliver_to_contact_id => x_deliver_to_contact_id
	  , x_return_status      => x_return_status
	  , x_msg_count          => x_msg_count
	  , x_msg_data           => x_msg_data
	  );

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		oe_msg_pub.transfer_msg_stack;
		x_return_status := FND_API.G_RET_STS_ERROR;
		RETURN;
	END IF;

END IF;

IF  p_ship_to_contact_ref IS NOT NULL THEN

FOR i in 1..p_customer_info_tbl.last LOOP
	IF p_customer_info_tbl.exists(i) THEN
		IF p_customer_info_tbl(i).customer_info_type_code ='CONTACT' THEN
			IF p_customer_info_tbl(i).customer_info_ref = p_ship_to_contact_ref THEN
				IF p_customer_info_tbl(i).customer_id IS  NULL THEN --Both Cust and address being created in this call

					FOR j in 1..p_customer_info_tbl.last LOOP
					   IF p_customer_info_tbl.exists(j) THEN
						IF p_customer_info_tbl(j).customer_info_ref = p_customer_info_tbl(i).parent_customer_info_ref
						AND p_customer_info_tbl(j).customer_info_type_code = 'CUSTOMER' THEN
							IF l_ship_cont_found = FALSE THEN
								l_ship_cont_found := TRUE;
								l_ship_cont_rec_index := i;
								l_customer_id         := p_customer_info_tbl(j).new_account_id;
							END IF;
						END IF;
					   END IF;
					END LOOP;
				ELSE

					IF l_ship_cont_found = FALSE THEN
						l_ship_cont_found := TRUE;
						l_ship_cont_rec_index := i;
						l_customer_id         := p_customer_info_tbl(i).customer_id;
					END IF;


				END IF;

			END IF;
		END IF;
	END IF;
END LOOP;

END IF;


IF l_ship_cont_found THEN

	IF NOT IS_VALID_ID( p_customer_id => l_customer_id ) THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MESSAGE.set_name('ONT','OE_INVALID_ATTRIBUTE');
		FND_MESSAGE.SET_TOKEN('ATTRIBUTE','CUSTOMER_ID');
		OE_MSG_PUB.Add;
		RETURN;
	END IF;

Create_Contact (  p_customer_info_tbl => p_customer_info_tbl
    	  , p_operation_code    => p_operation_code
	  , p_customer_id        => l_customer_id
	  , p_customer_rec_index => l_ship_cont_rec_index
	  , p_usage_code         => 'SHIP_TO'
	  , x_sold_to_contact_id => x_sold_to_contact_id
  	  , x_ship_to_contact_id => x_ship_to_contact_id
	  , x_invoice_to_contact_id => x_invoice_to_contact_id
	  , x_deliver_to_contact_id => x_deliver_to_contact_id
	  , x_return_status      => x_return_status
	  , x_msg_count          => x_msg_count
	  , x_msg_data           => x_msg_data
	  );

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		oe_msg_pub.transfer_msg_stack;
		x_return_status := FND_API.G_RET_STS_ERROR;
		RETURN;
	END IF;

END IF;



IF  p_bill_to_contact_ref IS NOT NULL THEN

FOR i in 1..p_customer_info_tbl.last LOOP
	IF p_customer_info_tbl.exists(i) THEN
		IF p_customer_info_tbl(i).customer_info_type_code ='CONTACT' THEN
			IF p_customer_info_tbl(i).customer_info_ref = p_bill_to_contact_ref THEN
				IF p_customer_info_tbl(i).customer_id IS  NULL THEN --Both Cust and address being created in this call

					FOR j in 1..p_customer_info_tbl.last LOOP
					    IF p_customer_info_tbl.exists(j) THEN
						IF p_customer_info_tbl(j).customer_info_ref = p_customer_info_tbl(i).parent_customer_info_ref
						AND p_customer_info_tbl(j).customer_info_type_code = 'CUSTOMER' THEN
							IF l_bill_cont_found = FALSE THEN
								l_bill_cont_found := TRUE;
								l_bill_cont_rec_index := i;
								l_customer_id         := p_customer_info_tbl(j).new_account_id;
							END IF;
						END IF;
					    END IF;
					END LOOP;
				ELSE

					IF l_bill_cont_found = FALSE THEN
						l_bill_cont_found := TRUE;
						l_bill_cont_rec_index := i;
						l_customer_id         := p_customer_info_tbl(i).customer_id;
					END IF;


				END IF;

			END IF;
		END IF;
	END IF;
END LOOP;

END IF;


IF l_bill_cont_found THEN

	IF NOT IS_VALID_ID( p_customer_id => l_customer_id ) THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MESSAGE.set_name('ONT','OE_INVALID_ATTRIBUTE');
		FND_MESSAGE.SET_TOKEN('ATTRIBUTE','CUSTOMER_ID');
		OE_MSG_PUB.Add;
		RETURN;
	END IF;

Create_Contact (  p_customer_info_tbl => p_customer_info_tbl
    	  , p_operation_code    => p_operation_code
	  , p_customer_id        => l_customer_id
	  , p_customer_rec_index => l_bill_cont_rec_index
	  , p_usage_code         => 'BILL_TO'
	  , x_sold_to_contact_id => x_sold_to_contact_id
  	  , x_ship_to_contact_id => x_ship_to_contact_id
	  , x_invoice_to_contact_id => x_invoice_to_contact_id
	  , x_deliver_to_contact_id => x_deliver_to_contact_id
	  , x_return_status      => x_return_status
	  , x_msg_count          => x_msg_count
	  , x_msg_data           => x_msg_data
	  );

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		oe_msg_pub.transfer_msg_stack;
		x_return_status := FND_API.G_RET_STS_ERROR;
		RETURN;
	END IF;

END IF;


IF  p_deliver_to_contact_ref IS NOT NULL THEN

FOR i in 1..p_customer_info_tbl.last LOOP
	IF p_customer_info_tbl.exists(i) THEN
		IF p_customer_info_tbl(i).customer_info_type_code ='CONTACT' THEN
			IF p_customer_info_tbl(i).customer_info_ref = p_deliver_to_contact_ref THEN
				IF p_customer_info_tbl(i).customer_id IS  NULL THEN --Both Cust and address being created in this call

					FOR j in 1..p_customer_info_tbl.last LOOP
					    IF p_customer_info_tbl.exists(j) THEN
						IF p_customer_info_tbl(j).customer_info_ref = p_customer_info_tbl(i).parent_customer_info_ref
						AND p_customer_info_tbl(j).customer_info_type_code = 'CUSTOMER' THEN
							IF l_deliver_cont_found = FALSE THEN
								l_deliver_cont_found := TRUE;
								l_deliver_cont_rec_index := i;
								l_customer_id         := p_customer_info_tbl(j).new_account_id;
							END IF;
						END IF;
					    END IF;
					END LOOP;
				ELSE

					IF l_deliver_cont_found = FALSE THEN
						l_deliver_cont_found := TRUE;
						l_deliver_cont_rec_index := i;
						l_customer_id         := p_customer_info_tbl(i).customer_id;
					END IF;


				END IF;

			END IF;
		END IF;
	END IF;
END LOOP;

END IF;


IF l_deliver_cont_found THEN

	IF NOT IS_VALID_ID( p_customer_id => l_customer_id ) THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MESSAGE.set_name('ONT','OE_INVALID_ATTRIBUTE');
		FND_MESSAGE.SET_TOKEN('ATTRIBUTE','CUSTOMER_ID');
		OE_MSG_PUB.Add;
		RETURN;
	END IF;

Create_Contact (  p_customer_info_tbl => p_customer_info_tbl
   	  , p_operation_code    => p_operation_code
	  , p_customer_id        => l_customer_id
	  , p_customer_rec_index => l_deliver_cont_rec_index
	  , p_usage_code         => 'DELIVER_TO'
	  , x_sold_to_contact_id => x_sold_to_contact_id
  	  , x_ship_to_contact_id => x_ship_to_contact_id
	  , x_invoice_to_contact_id => x_invoice_to_contact_id
	  , x_deliver_to_contact_id => x_deliver_to_contact_id
	  , x_return_status      => x_return_status
	  , x_msg_count          => x_msg_count
	  , x_msg_data           => x_msg_data
	  );

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		oe_msg_pub.transfer_msg_stack;
		x_return_status := FND_API.G_RET_STS_ERROR;
		RETURN;
	END IF;

END IF;



IF l_debug_level > 0 THEN
	oe_debug_pub.add(' Entering OE_CUSTOMER_INFO_PVT.get_customer_info_ids');
END IF;


EXCEPTION

	WHEN OTHERS THEN

	IF l_debug_level > 0 THEN
		oe_debug_pub.add('OE_CUSTOMER_INFO_PVT.get_customer_info_ids : Other Errors :'||SQLERRM);
	END IF;

	x_return_status := FND_API.G_RET_STS_ERROR;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'get_customer_info_ids'
            );
        END IF;

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

End get_customer_info_ids;

/* This procedure will call the wraper procedure oe_oe_inline_address.create_account which
inturn calls TCA apis to create a customer account. Email and phone contact points for the party will
also be created if passed*/

Procedure Create_account (p_header_customer_info_rec IN OE_ORDER_PUB.CUSTOMER_INFO_REC_TYPE,
                          x_party_id        OUT NOCOPY NUMBER,
			  x_cust_account_id OUT NOCOPY NUMBER,
			  x_return_status   OUT NOCOPY VARCHAR2,
			  x_msg_count       OUT NOCOPY NUMBER,
			  x_msg_data        OUT NOCOPY VARCHAR2
			  ) IS
l_customer_info_rec OE_ORDER_PUB.CUSTOMER_INFO_REC_TYPE;
l_party_id NUMBER := NULL;
l_party_type VARCHAR2(100) := NULL;
l_organization_name VARCHAR2(360) ;
l_customer_first_name varchar2(100);
l_customer_middle_name varchar2(100);
l_customer_last_name   varchar2(100);
l_customer_name_adjunct varchar2(100);
l_customer_name_suffix  varchar2(100);
l_party_number NUMBER;
x_party_number varchar2(30);
l_cust_account_number varchar2(30);

l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN

IF l_debug_level > 0 THEN
	oe_debug_pub.add('Entering OE_CUSTOMER_INFO_PVT.Create_account');
END IF;

x_return_status     := FND_API.G_RET_STS_SUCCESS;
l_customer_info_rec := p_header_customer_info_rec;

IF G_AUTO_PARTY_NUMBERING = 'Y' THEN
	l_party_number := NULL;
ELSE
	l_party_number := l_customer_info_rec.party_number;
END IF;

IF G_AUTO_CUST_NUMBERING = 'Y' THEN
	l_cust_account_number := NULL;
ELSE
	l_cust_account_number := l_customer_info_rec.customer_number;
END IF;


IF l_customer_info_rec.customer_type = 'PERSON' THEN
	l_party_type := 'PERSON';
	l_customer_first_name    := l_customer_info_rec.person_first_name;
	l_customer_middle_name   := l_customer_info_rec.person_middle_name;
	l_customer_last_name     := l_customer_info_rec.person_last_name;
	l_customer_name_adjunct  := l_customer_info_rec.person_title;
	l_customer_name_suffix   := l_customer_info_rec.person_name_suffix;

ELSE
	l_party_type := 'ORGANIZATION';
	l_organization_name := l_customer_info_rec.organization_name;
END IF;

--account under an existing party
IF l_customer_info_rec.party_id IS NOT NULL THEN

	IF IS_VALID_ID ( p_party_id => l_customer_info_rec.party_id) THEN
		l_party_id := l_customer_info_rec.party_id;
	ELSE
		FND_MESSAGE.set_name('ONT','OE_INVALID_ATTRIBUTE');
		FND_MESSAGE.SET_TOKEN('ATTRIBUTE','PARTY_ID');
		OE_MSG_PUB.Add;
		x_return_status := FND_API.G_RET_STS_ERROR;

	END IF;
END IF;


If l_debug_level >0 then
	oe_debug_pub.add('l_party_type :'||l_party_type);
	oe_debug_pub.add('l_party_number :'||l_party_number);
	oe_debug_pub.add('l_organization_name :'||l_organization_name);
	oe_debug_pub.add('l_customer_first_name :'||l_customer_first_name);
	oe_debug_pub.add('l_customer_middle_name :'||l_customer_middle_name);
	oe_debug_pub.add('l_customer_last_name :'||l_customer_last_name);

End If;


oe_oe_inline_address.create_account(
                 p_party_number=> l_party_number,
                 p_organization_name=>l_organization_name,
                 p_party_type=>l_party_type,
		 p_party_id=>l_party_id,
                 p_first_name=>l_customer_first_name,
                 p_last_name=>l_customer_last_name,
                 p_middle_name=>l_customer_middle_name,
                 p_name_suffix=>l_customer_name_suffix,
                 p_title=>l_customer_name_adjunct,
                 p_email=> l_customer_info_rec.email_address,
                 c_attribute_category=>l_customer_info_rec.attribute_category ,
                 c_attribute1=>l_customer_info_rec.attribute1,
                 c_attribute2=>l_customer_info_rec.attribute2,
                 c_attribute3=>l_customer_info_rec.attribute3,
                 c_attribute4=>l_customer_info_rec.attribute4,
                 c_attribute5=>l_customer_info_rec.attribute5,
                 c_attribute6=>l_customer_info_rec.attribute6,
                 c_attribute7=>l_customer_info_rec.attribute8,
                 c_attribute8=>l_customer_info_rec.attribute8,
                 c_attribute9=>l_customer_info_rec.attribute9,
                 c_attribute10=>l_customer_info_rec.attribute10,
                 c_attribute11=>l_customer_info_rec.attribute11,
                 c_attribute12=>l_customer_info_rec.attribute12,
                 c_attribute13=>l_customer_info_rec.attribute13,
                 c_attribute14=>l_customer_info_rec.attribute14,
                 c_attribute15=>l_customer_info_rec.attribute15,
                 c_attribute16=>l_customer_info_rec.attribute16,
                 c_attribute17=>l_customer_info_rec.attribute17,
                 c_attribute18=>l_customer_info_rec.attribute18,
                 c_attribute19=>l_customer_info_rec.attribute19,
		 c_attribute20=>l_customer_info_rec.attribute20,
                 c_global_attribute_category=>l_customer_info_rec.global_attribute_category,
                 c_global_attribute1=>l_customer_info_rec.global_attribute1,
                 c_global_attribute2=>l_customer_info_rec.global_attribute2,
                 c_global_attribute3=>l_customer_info_rec.global_attribute3,
                 c_global_attribute4=>l_customer_info_rec.global_attribute4,
                 c_global_attribute5=>l_customer_info_rec.global_attribute5,
                 c_global_attribute6=>l_customer_info_rec.global_attribute6,
                 c_global_attribute7=>l_customer_info_rec.global_attribute7,
                 c_global_attribute8=>l_customer_info_rec.global_attribute8,
                 c_global_attribute9=>l_customer_info_rec.global_attribute9,
                 c_global_attribute10=>l_customer_info_rec.global_attribute11,
                 c_global_attribute11=>l_customer_info_rec.global_attribute12,
                 c_global_attribute12=>l_customer_info_rec.global_attribute12,
                 c_global_attribute13=>l_customer_info_rec.global_attribute13,
                 c_global_attribute14=>l_customer_info_rec.global_attribute14,
                 c_global_attribute15=>l_customer_info_rec.global_attribute15,
                 c_global_attribute16=>l_customer_info_rec.global_attribute16,
                 c_global_attribute17=>l_customer_info_rec.global_attribute17,
                 c_global_attribute18=>l_customer_info_rec.global_attribute18,
                 c_global_attribute19=>l_customer_info_rec.global_attribute19,
                 c_global_attribute20=>l_customer_info_rec.global_attribute20,
		 p_alternate_name=>NULL,
                 p_tax_reference=>NULL,
                 p_taxpayer_id=>NULL,
                 x_party_id=>x_party_id,
                 x_party_number=>x_party_number,
                 x_cust_Account_id=> x_cust_account_id,
                 x_cust_account_number=>l_cust_account_number,--IN/OUT Check
                 x_return_status=>x_return_status,
                 x_msg_count=>x_msg_count,
                 x_msg_data=>x_msg_data,
                 in_Created_by_module=>G_CREATED_BY_MODULE ,
		 p_orig_system => l_customer_info_rec.orig_system,
		 p_orig_system_reference => l_customer_info_rec.orig_system_reference,
		 p_account_description   => l_customer_info_rec.account_description
                 );

       IF l_debug_level > 0  THEN
	oe_debug_pub.add('Create_account TCA CALL:x_return_status:'||x_return_status);
	oe_debug_pub.add('Create_account TCA CALL:x_msg_count:'||x_msg_count);
	oe_debug_pub.add('Create_account TCA CALL:x_msg_data:'||x_msg_data);
	oe_debug_pub.add('Create_account TCA CALL:x_cust_account_id:'||x_cust_account_id);
	oe_debug_pub.add('Create_account TCA CALL:x_cust_account_number:'||l_cust_account_number);
       END IF;

       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		RETURN;
       END IF;

       IF NVL(l_customer_info_rec.email_address,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR Then

		oe_oe_inline_address.create_contact_point
		(
		         in_contact_point_type => 'EMAIL',
			 in_owner_table_id     => x_party_id,
		         in_email	       => l_customer_info_rec.email_address,
		         in_phone_area_code    => NULL,
		         in_phone_number       => NULL,
		         in_phone_extension    => NULL,
			 in_phone_country_code  => NULL,
			 p_created_by_module    => G_CREATED_BY_MODULE,
			 p_orig_system          => l_customer_info_rec.orig_system,
			 p_orig_system_reference => l_customer_info_rec.orig_system_reference,
			 x_return_status        => x_return_status,
			 x_msg_count            => x_msg_count,
			 x_msg_data             => x_msg_data
		 );

	       IF l_debug_level > 0  THEN
			oe_debug_pub.add('create_contact_point EMAIL TCA CALL:x_return_status:'||x_return_status);
			oe_debug_pub.add('create_contact_point EMAIL TCA CALL:x_msg_count:'||x_msg_count);
			oe_debug_pub.add('create_contact_point EMAIL TCA CALL:x_msg_data:'||x_msg_data);
	       END IF;


	       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			RETURN;
	       END IF;


       END IF;

       IF NVL(l_customer_info_rec.phone_number,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR Then

		oe_oe_inline_address.create_contact_point
	                     (in_contact_point_type =>'PHONE',
                             in_owner_table_id=>x_party_id,
                             in_email=>NULL,
                             in_phone_area_code =>l_customer_info_rec.phone_area_code,
                             in_phone_number=>l_customer_info_rec.phone_number,
                             in_phone_extension=>l_customer_info_rec.phone_extension,
                             in_phone_country_code=>l_customer_info_rec.phone_country_code,
                             x_return_status=>x_return_status,
                             x_msg_count=>x_msg_count,
                             x_msg_data=>x_msg_data
                        		);

	       IF l_debug_level > 0  THEN
			oe_debug_pub.add('create_contact_point PHONE TCA CALL:x_return_status:'||x_return_status);
			oe_debug_pub.add('create_contact_point PHONE TCA CALL:x_msg_count:'||x_msg_count);
			oe_debug_pub.add('create_contact_point PHONE TCA CALL:x_msg_data:'||x_msg_data);
	       END IF;

	       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			RETURN;
	       END IF;

       END IF;

Exception
	WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Create_account'
            );
        END IF;

End Create_account;

/*
This procedure creates relationship between the sold_to customer and other site customers if a
relation ship does not exists already.Relation ships will be created only if the sysem paramer OM:Customer
Relation Ship is set to Related Customer
*/
Procedure Create_relationships (p_sold_to_customer_id IN NUMBER,
                                p_ship_to_customer_id NUMBER DEFAULT NULL,
                                p_bill_to_customer_id NUMBER DEFAULT NULL,
                                p_deliver_to_cust_id NUMBER DEFAULT NULL,
			        x_return_status   OUT NOCOPY VARCHAR2,
				x_msg_count       OUT NOCOPY NUMBER,
			        x_msg_data        OUT NOCOPY VARCHAR2
			  ) IS
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_rel_flag VARCHAR2(1);
BEGIN

IF l_debug_level > 0 THEN
	oe_debug_pub.add('Entering OE_CUSTOMER_INFO_PVT.Create_relationships ');
END IF;

x_return_status := FND_API.G_RET_STS_SUCCESS;

l_rel_flag := OE_Sys_Parameters.Value('CUSTOMER_RELATIONSHIPS_FLAG');

IF l_rel_flag  <> 'Y' THEN
	IF l_debug_level > 0 THEN
		oe_debug_pub.add(' No need to create relationships.system param is not related customers ');
	END IF;
	RETURN;
END IF;

IF NVL(p_sold_to_customer_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM
   AND NVL(p_ship_to_customer_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM
   AND p_sold_to_customer_id <> p_ship_to_customer_id
   AND NOT check_relation_exists ( p_sold_to_customer_id,p_ship_to_customer_id )
THEN
 oe_oe_inline_address.create_cust_relationship(  p_cust_acct_id => p_sold_to_customer_id
						,p_related_cust_acct_id => p_ship_to_customer_id
						,p_reciprocal_flag      => 'Y'
						,p_created_by_module    => G_CREATED_BY_MODULE
						,x_return_status        => x_return_status
						,x_msg_count            => x_msg_count
						,x_msg_data             => x_msg_data);

        IF l_debug_level > 0  THEN
		oe_debug_pub.add('Ship to customer relation creation');
		oe_debug_pub.add('Create_relationships TCA CALL:x_return_status:'||x_return_status);
		oe_debug_pub.add('Create_relationships TCA CALL:x_msg_count:'||x_msg_count);
		oe_debug_pub.add('Create_relationships TCA CALL:x_msg_data:'||x_msg_data);
       END IF;

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		RETURN;
	END IF;

END IF;

IF NVL(p_sold_to_customer_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM
   AND NVL(p_bill_to_customer_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM
   AND p_sold_to_customer_id <> p_bill_to_customer_id
   AND NOT check_relation_exists ( p_sold_to_customer_id,p_bill_to_customer_id )
THEN

 oe_oe_inline_address.create_cust_relationship(  p_cust_acct_id =>  p_sold_to_customer_id
						,p_related_cust_acct_id => p_bill_to_customer_id
						,p_reciprocal_flag      => 'Y'
						,p_created_by_module    => G_CREATED_BY_MODULE
						,x_return_status        => x_return_status
						,x_msg_count            => x_msg_count
					        ,x_msg_data             => x_msg_data);

        IF l_debug_level > 0  THEN
		oe_debug_pub.add('Invoice to customer relation creation');
		oe_debug_pub.add('Create_relationships TCA CALL:x_return_status:'||x_return_status);
		oe_debug_pub.add('Create_relationships TCA CALL:x_msg_count:'||x_msg_count);
		oe_debug_pub.add('Create_relationships TCA CALL:x_msg_data:'||x_msg_data);
       END IF;

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		RETURN;
	END IF;

END IF;

IF NVL(p_sold_to_customer_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM
   AND NVL(p_deliver_to_cust_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM
   AND p_sold_to_customer_id <> p_deliver_to_cust_id
   AND NOT check_relation_exists ( p_sold_to_customer_id,p_deliver_to_cust_id )
THEN


 oe_oe_inline_address.create_cust_relationship(  p_cust_acct_id =>  p_sold_to_customer_id
						,p_related_cust_acct_id => p_deliver_to_cust_id
						,p_reciprocal_flag      => 'Y'
						,p_created_by_module    => G_CREATED_BY_MODULE
						,x_return_status        => x_return_status
						,x_msg_count            => x_msg_count
					        ,x_msg_data             => x_msg_data);
        IF l_debug_level > 0  THEN
		oe_debug_pub.add('Deliver to customer relation creation');
		oe_debug_pub.add('Create_relationships TCA CALL:x_return_status:'||x_return_status);
		oe_debug_pub.add('Create_relationships TCA CALL:x_msg_count:'||x_msg_count);
		oe_debug_pub.add('Create_relationships TCA CALL:x_msg_data:'||x_msg_data);
       END IF;


	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		RETURN;
	END IF;

END IF;

IF l_debug_level > 0 THEN
	oe_debug_pub.add('Exiting OE_CUSTOMER_INFO_PVT.Create_relationships ');
END IF;

Exception
	WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Create_relationships'
            );
        END IF;

	IF l_debug_level > 0 THEN
		oe_debug_pub.add('Unexpected error in  OE_CUSTOMER_INFO_PVT.Create_relationships '||SQLERRM);
	END IF;

End Create_relationships;


/* This procedure will create a party site for the passed party_id and the location details*/

Procedure Create_Party_Site
		(  p_party_id IN NUMBER,
		   p_address_rec     IN OE_ORDER_PUB.CUSTOMER_INFO_REC_TYPE,
x_location_id OUT NOCOPY NUMBER,
x_party_site_id OUT NOCOPY NUMBER,
x_return_status OUT NOCOPY VARCHAR2,
x_msg_count OUT NOCOPY NUMBER,
x_msg_data OUT NOCOPY VARCHAR2 )IS

l_location_rec       HZ_LOCATION_V2PUB.location_rec_type;
l_msg_count number;
l_msg_data  Varchar2(4000);
l_return_status Varchar2(1);
l_party_site_number VARCHAR2(360);
x_party_site_number VARCHAR2 (360);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--

BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

IF l_debug_level > 0 THEN
	oe_debug_pub.add('Entering OE_CUSTOMER_INFO_PVT.Create_Party_Site');
END IF;


  IF l_debug_level > 0 then
	oe_debug_pub.add('Step 1:Create Location');
  end if;

   oe_oe_inline_address.Create_Location(
                   p_country => p_address_rec.country,
		   p_address1 => p_address_rec.address1,
		   p_address2 => p_address_rec.address2,
		   p_address3 => p_address_rec.address3,
		   p_address4 => p_address_rec.address4,
                   p_city    => p_address_rec.city,
		   p_postal_code  => p_address_rec.postal_code,
		   p_state   => p_address_rec.state,
		   p_province => p_address_rec.province,
		   p_county   => p_address_rec.county,
		   p_address_style => p_address_rec.address_style ,
		   p_address_line_phonetic =>p_address_rec.address_line_phonetic,
		   p_created_by_module => G_CREATED_BY_MODULE,
		   p_orig_system  => p_address_rec.orig_system,
		   p_orig_system_reference =>p_address_rec.orig_system_reference,
                   x_location_id => x_location_id,
		   c_Attribute_Category =>p_address_rec.Attribute_Category,
		   c_Attribute1 => p_address_rec.Attribute1,
		  c_Attribute2 => p_address_rec.Attribute2,
		  c_Attribute3 => p_address_rec.Attribute3,
		  c_Attribute4 => p_address_rec.Attribute4,
		  c_Attribute5 => p_address_rec.Attribute5,
		  c_Attribute6 => p_address_rec.Attribute6,
		  c_Attribute7 => p_address_rec.Attribute7,
		  c_Attribute8 => p_address_rec.Attribute8,
		  c_Attribute9 => p_address_rec.Attribute9,
		  c_Attribute10 => p_address_rec.Attribute10,
		  c_Attribute11  => p_address_rec.Attribute11,
		  c_Attribute12 => p_address_rec.Attribute12,
		  c_Attribute13  => p_address_rec.Attribute13,
		  c_Attribute14  => p_address_rec.Attribute14,
		  c_Attribute15 => p_address_rec.Attribute15,
		  c_Attribute16  => p_address_rec.Attribute16,
		  c_Attribute17 => p_address_rec.Attribute17,
		  c_Attribute18 => p_address_rec.Attribute18,
		  c_Attribute19 => p_address_rec.Attribute19,
		  c_Attribute20 => p_address_rec.Attribute20,
		  c_global_Attribute_Category => p_address_rec.global_Attribute_Category,
		  c_global_Attribute1 => p_address_rec.global_Attribute1,
		  c_global_Attribute2 => p_address_rec.global_Attribute2,
		  c_global_Attribute3 => p_address_rec.global_Attribute3,
		  c_global_Attribute4 => p_address_rec.global_Attribute4,
		  c_global_Attribute5 => p_address_rec.global_Attribute5,
		  c_global_Attribute6 => p_address_rec.global_Attribute6,
		  c_global_Attribute7 => p_address_rec.global_Attribute7,
		  c_global_Attribute8 => p_address_rec.global_Attribute8,
		  c_global_Attribute9 => p_address_rec.global_Attribute9,
		  c_global_Attribute10 => p_address_rec.global_Attribute10,
		  c_global_Attribute11 => p_address_rec.global_Attribute11,
		  c_global_Attribute12 => p_address_rec.global_Attribute12,
		  c_global_Attribute13 => p_address_rec.global_Attribute13,
		  c_global_Attribute14 => p_address_rec.global_Attribute14,
		  c_global_Attribute15 => p_address_rec.global_Attribute15,
		  c_global_Attribute16 => p_address_rec.global_Attribute16,
		  c_global_Attribute17 => p_address_rec.global_Attribute17,
		  c_global_Attribute18 => p_address_rec.global_Attribute18,
		  c_global_Attribute19 => p_address_rec.global_Attribute19,
		  c_global_Attribute20 => p_address_rec.global_Attribute20,
		  x_return_status => x_return_status,
		  x_msg_count => x_msg_count,
		  x_msg_data => x_msg_data);

 IF l_debug_level > 0 THEN
	oe_debug_pub.add('End of Step 1:Create Location :x_return_status:'||x_return_status);
	oe_debug_pub.add('End of Step 1:Create Location :x_msg_count:'||x_msg_count);
	oe_debug_pub.add('End of Step 1:Create Location :x_msg_data:'||x_msg_data);
	oe_debug_pub.add('End of Step 1:Create Location :x_location_id:'||x_location_id);
 END IF;

IF x_return_status <>  FND_API.G_RET_STS_SUCCESS then
	return;
END IF;

 IF l_debug_level > 0 THEN
	oe_debug_pub.add('Step 2:Create party site');
 END  IF;

	IF G_AUTO_SITE_NUMBERING = 'Y' THEN
		l_party_site_number := NULL;
	ELSE
		l_party_site_number := p_address_rec.site_number;
	END IF;

	oe_oe_inline_address.Create_Party_Site
	 (
		   p_party_id => p_party_id,
		   p_location_id => x_location_id,
		   p_party_site_number => l_party_site_number,
		   p_created_by_module => G_CREATED_BY_MODULE,
		   x_party_site_id => x_party_site_id,
  		   x_party_site_number => x_party_site_number,
	           x_return_status  => x_return_status,
		   x_msg_count => x_msg_count,
		   x_msg_data => x_msg_data
	   );

 IF l_debug_level > 0 THEN
	oe_debug_pub.add('End of Step 2:Create party_site :x_return_status:'||x_return_status);
	oe_debug_pub.add('End of Step 2:Create party_site :x_msg_count:'||x_msg_count);
	oe_debug_pub.add('End of Step 2:Create party_site :x_msg_data:'||x_msg_data);
	oe_debug_pub.add('End of Step 2:Create party_site :x_party_site_id:'||x_party_site_id);
 END IF;


IF l_debug_level > 0 THEN
	oe_debug_pub.add('Exiting OE_CUSTOMER_INFO_PVT.Create_Party_Site');
END IF;


EXCEPTION
	WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	IF l_debug_level > 0 THEN
		oe_debug_pub.add('Unexpected error in  OE_CUSTOMER_INFO_PVT.Create_Party_Site '||SQLERRM);
	END IF;

	IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Create_Party_Site'
            );
        END IF;

END Create_Party_Site;

/* This procedure will create a account site for a customer taking party site as input */

Procedure Create_Cust_Account_Site
		(  p_party_site_id IN NUMBER,
		   p_cust_account_id IN NUMBER,
		   p_address_rec     IN OE_ORDER_PUB.CUSTOMER_INFO_REC_TYPE,
x_cust_account_site_id OUT NOCOPY NUMBER,
x_return_status OUT NOCOPY VARCHAR2,
x_msg_count OUT NOCOPY NUMBER,
x_msg_data OUT NOCOPY VARCHAR2 ) IS

l_location_rec       HZ_LOCATION_V2PUB.location_rec_type;
l_msg_count number;
l_msg_data  Varchar2(4000);
l_return_status Varchar2(1);
l_party_site_number VARCHAR2(360);
x_party_site_number VARCHAR2 (360);
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--

BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

IF l_debug_level > 0 THEN
	oe_debug_pub.add('Entering OE_CUSTOMER_INFO_PVT.Create_Cust_Account_Site');
END IF;

IF l_debug_level > 0 THEN
	oe_debug_pub.add('Step 3:Create Account Site');
END IF;

	 oe_oe_inline_address.Create_Account_Site
	 (
		  p_cust_account_id  => p_cust_account_id,
		  p_party_site_id    => p_party_site_id,
		  c_Attribute_Category   => p_address_rec.attribute_category,
                  c_Attribute1           => p_address_rec.attribute1,
                  c_Attribute2           => p_address_rec.attribute2,
                  c_Attribute3           => p_address_rec.attribute3,
                  c_Attribute4           => p_address_rec.attribute4,
                  c_Attribute5           => p_address_rec.attribute5,
                  c_Attribute6           => p_address_rec.attribute6,
                  c_Attribute7           => p_address_rec.attribute7,
                  c_Attribute8           => p_address_rec.attribute8,
                  c_Attribute9           => p_address_rec.attribute9,
                  c_Attribute10          => p_address_rec.attribute10,
                  c_Attribute11          => p_address_rec.attribute11,
                  c_Attribute12          => p_address_rec.attribute12,
                  c_Attribute13          => p_address_rec.attribute13,
                  c_Attribute14          => p_address_rec.attribute14,
                  c_Attribute15          => p_address_rec.attribute15,
                  c_Attribute16          => p_address_rec.attribute16,
                  c_Attribute17          => p_address_rec.attribute17,
                  c_Attribute18          => p_address_rec.attribute18,
                  c_Attribute19          => p_address_rec.attribute19,
                  c_Attribute20          => p_address_rec.attribute20,
		  x_customer_site_id => x_cust_account_site_id,
		  x_return_status => x_return_status,
		  x_msg_count     => x_msg_count,
		  x_msg_data      => x_msg_data,
		  in_created_by_module => G_CREATED_BY_MODULE
	 );
 IF l_debug_level > 0 THEN
	oe_debug_pub.add('End of Step 3:Create Account_Site :x_return_status:'||x_return_status);
	oe_debug_pub.add('End of Step 3:Create Account_Site :x_msg_count:'||x_msg_count);
	oe_debug_pub.add('End of Step 3:Create Account_Site :x_msg_data:'||x_msg_data);
	oe_debug_pub.add('End of Step 3:Create Account_Site :x_cust_account_site_id:'||x_cust_account_site_id);
 END IF;

IF l_debug_level > 0 THEN
	oe_debug_pub.add('Exiting OE_CUSTOMER_INFO_PVT.Create_Cust_Account_Site');
END IF;


EXCEPTION
	WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	IF l_debug_level > 0 THEN
		oe_debug_pub.add('Unexpected error in  OE_CUSTOMER_INFO_PVT.Create_Cust_Account_Site '||SQLERRM);
	END IF;

	IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Create_Cust_Account_Site'
            );
        END IF;

END Create_Cust_Account_Site;

/* Create account site usages  */

PROCEDURE Create_Acct_Site_Uses
(	          p_cust_acct_site_id  IN NUMBER,
		  p_location_number    IN VARCHAR2,
		  p_site_use_code      IN VARCHAR2,
		  x_site_use_id OUT NOCOPY NUMBER,
		  x_return_status OUT NOCOPY VARCHAR2,
		  x_msg_count OUT NOCOPY NUMBER ,
		  x_msg_data OUT NOCOPY VARCHAR2)
IS
  l_location_number          VARCHAR2(360);
  l_acct_site_uses           HZ_CUST_ACCOUNT_SITE_V2PUB.cust_site_use_rec_type;
  l_cust_profile_rec         HZ_CUSTOMER_PROFILE_V2PUB.customer_profile_rec_type;
  p_org_id NUMBER := MO_GLOBAL.get_current_org_id;
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN
    IF l_debug_level > 0 THEN
	oe_debug_pub.add('Entering OE_CUSTOMER_INFO_PVT.Create_Acct_Site_Uses');
    END IF;


     l_acct_site_uses.cust_acct_site_id := p_cust_acct_site_id;
     l_acct_site_uses.created_by_module := G_CREATED_BY_MODULE;
     l_acct_site_uses.application_id    := 660;
     l_acct_site_uses.org_id            := p_org_id;
     l_acct_site_uses.site_use_code     := p_site_use_code;

     IF p_location_number IS NOT NULL THEN
	l_acct_site_uses.location     := p_location_number;
     END IF;


    HZ_CUST_ACCOUNT_SITE_V2PUB.Create_Cust_Site_Use
    (
              p_cust_site_use_rec => l_acct_site_uses,
              p_customer_profile_rec => l_cust_profile_rec,
              p_create_profile => FND_API.G_FALSE,
              x_return_status => x_return_status,
              x_msg_count => x_msg_count,
              x_msg_data => x_msg_data,
              x_site_use_id => x_site_use_id
     );

    IF l_debug_level > 0 THEN
	oe_debug_pub.add('Create_Cust_Site_Use : x_return_status:'||x_return_status);
	oe_debug_pub.add('Create_Cust_Site_Use : x_msg_count:'||x_msg_count);
	oe_debug_pub.add('Create_Cust_Site_Use : x_msg_data:'||x_msg_data);
	oe_debug_pub.add('Create_Cust_Site_Use : x_site_use_id:'||x_site_use_id);
    END IF;


    IF l_debug_level > 0 THEN
	oe_debug_pub.add('Exiting OE_CUSTOMER_INFO_PVT.Create_Acct_Site_Uses');
    END IF;

EXCEPTION
	WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	IF l_debug_level > 0 THEN
		oe_debug_pub.add('Unexpected error in  OE_CUSTOMER_INFO_PVT.Create_Acct_Site_Uses '||SQLERRM);
	END IF;

	IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Create_Acct_Site_Uses'
            );
        END IF;

END Create_Acct_Site_Uses;


/* This procuedre will get all the party sites for the passed party and check whether the site being created
is already there .If found it returns the existing party_site_id */

Procedure Check_Party_Site_Exists( p_party_id IN NUMBER,
                          	    p_address_rec     IN OE_ORDER_PUB.CUSTOMER_INFO_REC_TYPE,
				    x_party_site_id OUT NOCOPY NUMBER
				    ) IS
CURSOR party_location
IS
SELECT party_site_id,location_id
FROM hz_party_sites
WHERE party_id = p_party_id;

l_location_rec       HZ_LOCATION_V2PUB.location_rec_type;
l_return_status VARCHAR2(1);
l_msg_count NUMBER;
l_msg_data VARCHAR2(4000);
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

x_party_site_id := FND_API.G_MISS_NUM;

IF l_debug_level > 0 THEN
	oe_debug_pub.add('Entering  OE_CUSTOMER_INFO_PVT.Check_Party_Site_Exists : p_party_id'||p_party_id);
END IF;


FOR i in party_location LOOP

	IF l_debug_level > 0 THEN
		oe_debug_pub.add('Party_site_id :'||i.party_site_id);
		oe_debug_pub.add('Location_id :'||i.location_id);
	END IF;


		HZ_LOCATION_V2PUB.get_location_rec(
		    p_init_msg_list => FND_API.G_TRUE,
		    p_location_id   => i.location_id,
		    x_location_rec  => l_location_rec,
		    x_return_status => l_return_status,
		    x_msg_count     => l_msg_count,
		    x_msg_data      => l_msg_data
		);

		IF l_debug_level > 0 THEN
			oe_debug_pub.add('l_return_status :'||l_return_status);
			oe_debug_pub.add('l_msg_data :'||l_msg_data);
		END IF;

		IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			x_party_site_id := FND_API.G_MISS_NUM;
			oe_msg_pub.transfer_msg_stack;
			RETURN;
		END IF;


		 --Check for match
		IF     NVL(l_location_rec.country,FND_API.G_MISS_CHAR) = NVL(p_address_rec.country,FND_API.G_MISS_CHAR)
		   AND NVL(l_location_rec.state,FND_API.G_MISS_CHAR) = NVL(p_address_rec.state,FND_API.G_MISS_CHAR)
		   AND NVL(l_location_rec.city,FND_API.G_MISS_CHAR) = NVL(p_address_rec.city,FND_API.G_MISS_CHAR)
		   AND NVL(l_location_rec.county,FND_API.G_MISS_CHAR) = NVL(p_address_rec.county,FND_API.G_MISS_CHAR)
		   AND NVL(l_location_rec.ADDRESS1,FND_API.G_MISS_CHAR) = NVL(p_address_rec.ADDRESS1,FND_API.G_MISS_CHAR)
		   AND NVL(l_location_rec.ADDRESS2,FND_API.G_MISS_CHAR) = NVL(p_address_rec.ADDRESS2,FND_API.G_MISS_CHAR)
		   AND NVL(l_location_rec.ADDRESS3,FND_API.G_MISS_CHAR) = NVL(p_address_rec.ADDRESS3,FND_API.G_MISS_CHAR)
		   AND NVL(l_location_rec.ADDRESS4,FND_API.G_MISS_CHAR) = NVL(p_address_rec.ADDRESS4,FND_API.G_MISS_CHAR)
		THEN

			IF l_debug_level > 0 THEN
				oe_debug_pub.add(' MATCH FOUND : Party Site Exists');
				oe_debug_pub.add(' x_party_site_id:'||i.party_site_id);
				oe_debug_pub.add(' Location_id:'||i.location_id);
			END IF;

			x_party_site_id := i.party_site_id;
			RETURN;
		END IF;


END LOOP;


IF l_debug_level > 0 THEN
	oe_debug_pub.add(' No Match found :x_party_site_id :'||x_party_site_id);
	oe_debug_pub.add('Exiting  OE_CUSTOMER_INFO_PVT.Check_Party_Site_Exists');
END IF;

EXCEPTION
	WHEN OTHERS THEN
	IF l_debug_level > 0 THEN
		oe_debug_pub.add('Other errors in Check_Party_Site_Exists: '||SQLERRM);
	END IF;

	x_party_site_id := FND_API.G_MISS_NUM;

END Check_Party_Site_Exists;

/*This procedure checks whether a party site has already got a account site */

Procedure Check_Cust_Site_Exists ( p_party_site_id IN NUMBER,
				   p_cust_account_id IN NUMBER,
				   x_cust_acct_site_id OUT NOCOPY NUMBER
				  )IS
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN


IF l_debug_level > 0 THEN
	oe_debug_pub.add('Entering  OE_CUSTOMER_INFO_PVT.Check_Cust_Site_Exists');
END IF;

x_cust_acct_site_id := FND_API.G_MISS_NUM;

SELECT  cust_acct_site_id
INTO x_cust_acct_site_id
FROM hz_cust_acct_sites
WHERE    party_site_id = p_party_site_id
AND cust_account_id = p_cust_account_id
AND ROWNUM =1;



IF l_debug_level > 0 THEN
	oe_debug_pub.add('x_cust_acct_site_id :'||x_cust_acct_site_id);
	oe_debug_pub.add('Exiting  OE_CUSTOMER_INFO_PVT.Check_Cust_Site_Exists');
END IF;

EXCEPTION
	WHEN OTHERS THEN
	x_cust_acct_site_id := FND_API.G_MISS_NUM;

	IF l_debug_level > 0 THEN
		oe_debug_pub.add('Other Errors :'||SQLERRM);
	END IF;
END Check_Cust_Site_Exists;

/* This function returns the location_id for the given cust_acct_site_id */
Function Get_Location_id( p_cust_acct_site_id IN NUMBER DEFAULT NULL)
RETURN NUMBER IS
l_location_id NUMBER;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

IF l_debug_level > 0 THEN
	oe_debug_pub.add('Entering OE_CUSTOMER_INFO_PVT.Get_Location_id');
END IF;


   SELECT loc.location_id
    INTO l_location_id
    FROM hz_cust_acct_sites      acct_site,
         hz_party_sites          party_site,
         hz_locations            loc
  WHERE acct_site.party_site_id     =  party_site.party_site_id
    AND loc.location_id             =  party_site.location_id
    AND acct_site.cust_acct_site_id =  p_cust_acct_site_id ;


IF l_debug_level > 0 THEN
	oe_debug_pub.add('l_location_id :'||l_location_id);
END IF;

RETURN l_location_id;

EXCEPTION
	WHEN OTHERS THEN
	IF l_debug_level > 0 THEN
		oe_debug_pub.add(' OTHER ERROERS IN OE_CUSTOMER_INFO_PVT.Get_Location_id'|| SQLERRM);
	END IF;

	RETURN NULL;
END Get_Location_id;


/* This procedure is called from Get_Customer_Info_ids to create customer sites and different usages */
Procedure Create_Addresses (
                            p_customer_info_tbl IN OUT NOCOPY OE_ORDER_PUB.CUSTOMER_INFO_TABLE_TYPE
			  , p_operation_code      IN VARCHAR2
			  , p_sold_to_customer_id IN NUMBER
			  , p_ship_to_customer_id IN NUMBER
			  , p_bill_to_customer_id IN NUMBER
			  , p_deliver_to_customer_id IN NUMBER
			  , p_customer_id       IN NUMBER
                          , p_address_rec_index  IN NUMBER
			  , p_address_usage      IN VARCHAR2
			  , x_ship_to_org_id  IN OUT NOCOPY NUMBER
			  , x_invoice_to_org_id IN OUT NOCOPY NUMBER
			  , x_deliver_to_org_id IN OUT NOCOPY NUMBER
	                  , x_sold_to_site_use_id IN OUT NOCOPY NUMBER
  		          , x_return_status   OUT NOCOPY VARCHAR2
			  , x_msg_count       OUT NOCOPY NUMBER
			  , x_msg_data        OUT NOCOPY VARCHAR2
			  ) IS


l_addr_rec OE_ORDER_PUB.CUSTOMER_INFO_REC_TYPE;

l_ship_addr_rec_index  NUMBER;
l_bill_addr_rec_index  NUMBER;
l_deliver_addr_rec_index NUMBER;


x_ship_account_site_id NUMBER;
x_bill_account_site_id NUMBER;
x_deliver_account_site_id NUMBER;


x_location_id NUMBER;
x_party_site_id NUMBER;
x_party_site_number VARCHAR2(360);
x_cust_account_site_id NUMBER;
x_site_use_id NUMBER;

l_location_number VARCHAR2(360);

l_party_id NUMBER;
x_customer_id NUMBER;
l_customer_id NUMBER;

l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_site_customer_id NUMBER;
x_account_site_id NUMBER;

BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

IF l_debug_level > 0 THEN
	oe_debug_pub.add('Entering procedure OE_CUSTOMER_INFO_PVT.Create_Addresses');
	oe_debug_pub.add('p_address_usage:'||p_address_usage);
END IF;

l_addr_rec := 	p_customer_info_tbl(p_address_rec_index);


 IF p_address_usage = 'SHIP_TO' THEN
	l_site_customer_id := p_ship_to_customer_id;
 ELSIF p_address_usage ='BILL_TO' THEN
	l_site_customer_id := p_bill_to_customer_id ;
 ELSIF p_address_usage = 'DELIVER_TO' THEN
	l_site_customer_id := p_deliver_to_customer_id;
 ELSE
	l_site_customer_id := p_customer_id;
 END IF;

 IF NVL( l_addr_rec.site_use_id ,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM THEN


		  Value_To_Id_Address    (  p_address_record   => l_addr_rec
					  , p_sold_to_org_id   => p_sold_to_customer_id
					  , p_site_customer_id => l_site_customer_id
					  , p_site_usage       => p_address_usage
					  , x_site_usage_id    => x_site_use_id);

		IF x_site_use_id = FND_API.G_MISS_NUM THEN
	      	        oe_msg_pub.delete_msg(oe_msg_pub.g_msg_count);
		ELSE
			IF p_address_usage = 'SHIP_TO' THEN
			    x_ship_to_org_id  := x_site_use_id;
			ELSIF p_address_usage ='BILL_TO' THEN
			    x_invoice_to_org_id  := x_site_use_id;
			ELSIF p_address_usage ='DELIVER_TO' THEN
			      x_deliver_to_org_id := x_site_use_id;
			ELSE
				x_sold_to_site_use_id := x_site_use_id;
			END IF ;

		END IF;
 ELSE

		--Update Address logic to go here
		IF IS_BOTH_ID_VAL_PASSED( p_address_rec => l_addr_rec )
	           AND OE_GLOBALS.G_UPDATE_ON_ID
             	THEN
			Update_Location (p_address_rec => l_addr_rec
	    			       , p_site_use_id   => l_addr_rec.site_use_id
		  		       , p_site_usage_code => p_address_usage
				       , x_return_status =>x_return_status
				       , x_msg_count => x_msg_count
				       , x_msg_data  => x_msg_data
		   		      );
	           END IF;

		IF l_debug_level > 0  THEN
			oe_debug_pub.add('Update_Location :x_return_status'||x_return_status);
			oe_debug_pub.add('Update_Location :x_msg_count'||x_msg_count);
			oe_debug_pub.add('Update_Location :x_msg_data'||x_msg_data);
		END IF;

		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		        oe_msg_pub.transfer_msg_stack;
			RETURN;
		END IF;

		x_site_use_id     := l_addr_rec.site_use_id;

		IF p_address_usage = 'SHIP_TO' THEN
		    x_ship_to_org_id  := x_site_use_id;
		ELSIF p_address_usage ='BILL_TO' THEN
		    x_invoice_to_org_id  := x_site_use_id;
		ELSIF p_address_usage ='DELIVER_TO' THEN
		      x_deliver_to_org_id := x_site_use_id;
		ELSE
			x_sold_to_site_use_id := x_site_use_id;
		END IF ;



END IF;

IF G_AUTO_LOCATION_NUMBERING = 'Y' THEN
	l_location_number := NULL;
ELSE
	l_location_number := l_addr_rec.location_number;
END IF;

IF NVL(x_site_use_id ,FND_API.G_MISS_NUM ) = FND_API.G_MISS_NUM THEN
	Check_Duplicate_Address (   p_address_record    => l_addr_rec
				  , p_sold_to_org_id    => p_sold_to_customer_id
				  , p_site_customer_id  => l_site_customer_id
				  , p_site_usage        => p_address_usage
				  , x_site_usage_id     => x_site_use_id);

	IF x_site_use_id = FND_API.G_MISS_NUM THEN
		 oe_msg_pub.delete_msg(oe_msg_pub.g_msg_count);
	ELSE
			IF p_address_usage = 'SHIP_TO' THEN
			    x_ship_to_org_id  := x_site_use_id;
			ELSIF p_address_usage ='BILL_TO' THEN
			    x_invoice_to_org_id  := x_site_use_id;
			ELSIF p_address_usage ='DELIVER_TO' THEN
			      x_deliver_to_org_id := x_site_use_id;
			ELSE
				x_sold_to_site_use_id := x_site_use_id;
			END IF ;

	END IF;
END IF;


IF NVL(x_site_use_id ,FND_API.G_MISS_NUM ) = FND_API.G_MISS_NUM THEN

	        Check_Party_Site_Exists( p_party_id => Get_Party_ID(p_customer_id),
                          	        p_address_rec     =>l_addr_rec,
				        x_party_site_id => x_party_site_id
				    );

		IF x_party_site_id <> FND_API.G_MISS_NUM THEN

				Check_Cust_Site_Exists ( p_party_site_id =>x_party_site_id,
				   p_cust_account_id =>p_customer_id,
				   x_cust_acct_site_id =>x_account_site_id
				  );
		END IF;


	       IF x_account_site_id <> FND_API.G_MISS_NUM  THEN

			IF l_debug_level > 0 THEN
				oe_debug_pub.add('This site is aleary created ,so check create site usage alone');
			END IF;


			        Check_site_usage_exists ( p_cust_acct_site_id => x_account_site_id
						  ,p_site_usage  => p_address_usage
						  ,x_site_use_id => x_site_use_id);

				IF x_site_use_id <> FND_API.G_MISS_NUM THEN
					 IF l_debug_level > 0 THEN
						oe_debug_pub.add(p_address_usage||': Site Usage already exists ');
						oe_debug_pub.add(p_address_usage||': Create_Acct_Site_Uses:x_site_use_id'||x_site_use_id);
					END IF;
				ELSE

					 Create_Acct_Site_Uses(
						  p_cust_acct_site_id  => x_account_site_id,
						  p_location_number      => l_location_number,
						  p_site_use_code      => p_address_usage,
						  x_site_use_id        => x_site_use_id ,
						  x_return_status      => x_return_status,
						  x_msg_count          => x_msg_count,
						  x_msg_data           => x_msg_data );

				END IF;

				 IF l_debug_level > 0 THEN
					oe_debug_pub.add(p_address_usage||': Create_Acct_Site_Uses:x_return_status:'||x_return_status);
					oe_debug_pub.add(p_address_usage||': Create_Acct_Site_Uses: x_msg_count :'||x_return_status);
					oe_debug_pub.add(p_address_usage||': Create_Acct_Site_Uses: x_msg_data'||x_msg_data);
					oe_debug_pub.add(p_address_usage||': Create_Acct_Site_Uses:x_site_use_id'||x_site_use_id);
				 END IF;

				 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
					oe_msg_pub.transfer_msg_stack;
					RETURN;
				 END IF;

             ELSE
			  IF l_debug_level > 0 THEN
				oe_debug_pub.add('Create both site and site usage');
 			  END IF;


			IF x_party_site_id = FND_API.G_MISS_NUM THEN
				Create_Party_Site
				(  p_party_id => Get_Party_ID(p_customer_id),
				   p_address_rec     => l_addr_rec,
				   x_location_id  => x_location_id,
				   x_party_site_id => x_party_site_id,
				   x_return_status =>x_return_status,
				   x_msg_count =>x_msg_count,
				   x_msg_data =>x_msg_data
				);

				IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
					oe_msg_pub.transfer_msg_stack;
					RETURN;
				END IF;

			END IF;

			IF l_debug_level > 0 THEN
				oe_debug_pub.add(p_address_usage||': Create_Party_Site:x_return_status:'||x_return_status);
				oe_debug_pub.add(p_address_usage||': Create_Party_Site: x_msg_count :'||x_msg_count);
				oe_debug_pub.add(p_address_usage||': Create_Party_Site: x_msg_data'||x_msg_data);
				oe_debug_pub.add(p_address_usage||': Create_Party_Site:x_party_site_id'||x_party_site_id);
				oe_debug_pub.add(p_address_usage||': Create_Party_Site:x_location_id'||x_location_id);
			END IF;



			Create_Cust_Account_Site
			(  p_party_site_id =>x_party_site_id,
			   p_cust_account_id =>p_customer_id,
			   p_address_rec     => l_addr_rec,
	  		   x_cust_account_site_id =>x_account_site_id,
			   x_return_status =>x_return_status,
			   x_msg_count =>x_msg_count,
			   x_msg_data =>x_msg_data
			);


			 IF l_debug_level > 0 THEN
				oe_debug_pub.add(p_address_usage||': Create_Cust_Account_Site:x_return_status:'||x_return_status);
				oe_debug_pub.add(p_address_usage||': Create_Cust_Account_Site: x_msg_count :'||x_msg_count);
				oe_debug_pub.add(p_address_usage||': Create_Cust_Account_Site: x_msg_data'||x_msg_data);
				oe_debug_pub.add(p_address_usage||': Create_Cust_Account_Site:x_ship_account_site_id'||x_ship_account_site_id);
			 END IF;

			 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
				oe_msg_pub.transfer_msg_stack;
				RETURN;
			 END IF;

			  Create_Acct_Site_Uses(
						  p_cust_acct_site_id  => x_account_site_id ,
						  p_location_number      => l_location_number,
						  p_site_use_code      => p_address_usage,
						  x_site_use_id        => x_site_use_id ,
						  x_return_status      => x_return_status,
						  x_msg_count          => x_msg_count,
						  x_msg_data           => x_msg_data );


			  IF l_debug_level > 0 THEN
				oe_debug_pub.add(p_address_usage||': Create_Acct_Site_Uses:x_return_status:'||x_return_status);
				oe_debug_pub.add(p_address_usage||': Create_Acct_Site_Uses: x_msg_count :'||x_return_status);
				oe_debug_pub.add(p_address_usage||': Create_Acct_Site_Uses: x_msg_data'||x_msg_data);
				oe_debug_pub.add(p_address_usage||': Create_Acct_Site_Uses:x_site_use_id'||x_site_use_id);
			 END IF;

			 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
				oe_msg_pub.transfer_msg_stack;
				RETURN;
			 END IF;


	      END IF;
			IF p_address_usage = 'SHIP_TO' THEN
			    x_ship_to_org_id  := x_site_use_id;
			ELSIF p_address_usage ='BILL_TO' THEN
			    x_invoice_to_org_id  := x_site_use_id;
			ELSIF p_address_usage ='DELIVER_TO' THEN
			      x_deliver_to_org_id := x_site_use_id;
			ELSE
				x_sold_to_site_use_id := x_site_use_id;
			END IF ;
	  ELSE
			IF p_address_usage = 'SHIP_TO' THEN
			    x_ship_to_org_id  := x_site_use_id;
			ELSIF p_address_usage ='BILL_TO' THEN
			    x_invoice_to_org_id  := x_site_use_id;
			ELSIF p_address_usage ='DELIVER_TO' THEN
			      x_deliver_to_org_id := x_site_use_id;
			ELSE
				x_sold_to_site_use_id := x_site_use_id;
			END IF ;
	  END IF;



IF l_debug_level > 0 THEN
	oe_debug_pub.add('Exiting procedure OE_CUSTOMER_INFO_PVT.Create_Addresses');
END IF;

EXCEPTION
	WHEN OTHERS THEN
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Create_Addresses'
            );
        END IF;

END Create_Addresses;


Procedure Check_Customer_Fields (p_customer_record IN OE_ORDER_PUB.CUSTOMER_INFO_REC_TYPE
                                 ,x_return_status OUT NOCOPY VARCHAR2 ) IS
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

 IF p_customer_record.customer_type IS NULL  THEN
      fnd_message.set_name('ONT','ONT_PO_INL_REQD');
      fnd_message.set_token('API_NAME', 'CREATE_ACCOUNT');
      fnd_message.set_token('FIELD_REQD',  'CUSTOMER_TYPE');
      oe_msg_pub.add;
      x_return_status      := FND_API.G_RET_STS_ERROR;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'CUSTOMER TYPE REQUIRED BUT NOT ENTERED' ) ;
      END IF;


 END IF;

 IF ( p_customer_record.customer_type = 'ORGANIZATION'
       AND p_customer_record.organization_name IS NULL
     )
  THEN
      fnd_message.set_name('ONT','ONT_PO_INL_REQD');
      fnd_message.set_token('API_NAME', 'CREATE_ACCOUNT');
      fnd_message.set_token('FIELD_REQD',  'ORGANIZATION_NAME');
      oe_msg_pub.add;
      x_return_status      := FND_API.G_RET_STS_ERROR;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'ORGANIZATION NAME REQUIRED BUT NOT ENTERED' ) ;
      END IF;


 END IF;


 IF ( p_customer_record.customer_type = 'PERSON'
       AND p_customer_record.person_first_name IS NULL
       AND p_customer_record.person_last_name IS NULL
      )
  THEN
      fnd_message.set_name('ONT','ONT_PO_INL_REQD');
      fnd_message.set_token('API_NAME', 'CREATE_ACCOUNT');
      fnd_message.set_token('FIELD_REQD',  'PERSON_FIRST_NAME');
      oe_msg_pub.add;
      x_return_status      := FND_API.G_RET_STS_ERROR;

       IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'PERSON FIRST/LAST NAME REQUIRED BUT NOT ENTERED' ) ;
      END IF;


  END IF;


  IF G_EMAIL_REQUIRED = 'Y' and
      p_customer_record.email_address is NULL THEN
      fnd_message.set_name('ONT','ONT_PO_INL_REQD');
      fnd_message.set_token('API_NAME', 'CREATE_ACCOUNT');
      fnd_message.set_token('FIELD_REQD',  'EMAIL_ADDRESS');
      oe_msg_pub.add;
      x_return_status      := FND_API.G_RET_STS_ERROR;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'EMAIL REQUIRED BUT NOT ENTERED' ) ;
      END IF;
  END IF;

   IF G_AUTO_PARTY_NUMBERING = 'N' and
      p_customer_record.party_number IS NULL Then

      fnd_message.set_name('ONT','ONT_PO_INL_REQD');
      fnd_message.set_token('API_NAME', 'CREATE_ACCOUNT');
      fnd_message.set_token('FIELD_REQD',  'PARTY_NUMBER');
      oe_msg_pub.add;
      x_return_status      := FND_API.G_RET_STS_ERROR;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'PARTY NUMBER REQUIRED BUT NOT ENTERED' ) ;
      END IF;

   End If;

   IF G_AUTO_CUST_NUMBERING = 'N' and
      p_customer_record.customer_number IS NULL THEN

      fnd_message.set_name('ONT','ONT_PO_INL_REQD');
      fnd_message.set_token('API_NAME', 'CREATE_ACCOUNT');
      fnd_message.set_token('FIELD_REQD',  'CUSTOMER_NUMBER');
      oe_msg_pub.add;
      x_return_status      := FND_API.G_RET_STS_ERROR;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'CUSTOMER NUMBER REQUIRED BUT NOT ENTERED' ) ;
      END IF;

   End If;

EXCEPTION
         WHEN OTHERS THEN
	 NULL;
END Check_Customer_Fields;

Procedure Validate_Customer_Fields (p_customer_record IN OE_ORDER_PUB.CUSTOMER_INFO_REC_TYPE
                                    ,x_return_status OUT NOCOPY VARCHAR2 )IS
x_party_id NUMBER;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF p_customer_record.customer_type NOT IN ('ORGANIZATION','PERSON')    THEN
		FND_MESSAGE.set_name('ONT','OE_INVALID_ATTRIBUTE');
		FND_MESSAGE.SET_TOKEN('ATTRIBUTE','PARTY_ID');
		OE_MSG_PUB.Add;
		x_return_status := FND_API.G_RET_STS_ERROR;
	END IF;

EXCEPTION
         WHEN OTHERS THEN
	 NULL;
END Validate_Customer_Fields;


Procedure Check_Duplicate_Customer (  p_customer_record IN OE_ORDER_PUB.CUSTOMER_INFO_REC_TYPE
				    , p_type            IN VARCHAR2
                                    , x_customer_id  OUT NOCOPY VARCHAR2
				   ) IS
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

IF l_debug_level >0 THEN
	oe_debug_pub.add('Entering OE_CUSTOMER_INFO_PVT.Check_Duplicate_Customer');
END IF;
   x_customer_id := FND_API.G_MISS_NUM;

   IF p_customer_record.customer_type = 'ORGANIZATION' THEN
      IF p_type = 'SOLD_TO' THEN
	      x_customer_id := Oe_value_to_id.sold_to_org(
					p_sold_to_org     => p_customer_record.organization_name,
					p_customer_number => p_customer_record.customer_number);
      ELSE
	      x_customer_id := Oe_value_to_id.site_customer(
					p_site_customer           => p_customer_record.organization_name
				      , p_site_customer_number    => p_customer_record.customer_number
			    	      , p_type                    =>p_type );


      END IF;
   ELSIF p_customer_record.customer_type = 'PERSON' THEN
         IF p_type = 'SOLD_TO' THEN
	        x_customer_id := oe_value_to_id.sold_to_org(
					p_sold_to_org    =>  p_customer_record.person_first_name || ' ' ||
						                p_customer_record.person_last_name,
			                p_customer_number => p_customer_record.customer_number);
	ELSE
		x_customer_id := Oe_value_to_id.site_customer(
					p_site_customer           =>  p_customer_record.person_first_name || ' ' ||
						                      p_customer_record.person_last_name
			              , p_site_customer_number    => p_customer_record.customer_number
			    	      , p_type                    => p_type );
	END IF;
   END IF;


IF l_debug_level >0 THEN
	oe_debug_pub.add('Exiting OE_CUSTOMER_INFO_PVT.Check_Duplicate_Customer :'||x_customer_id);
END IF;

EXCEPTION
	WHEN OTHERS THEN
	IF l_debug_level >0 THEN
		oe_debug_pub.add('Other errors in  OE_CUSTOMER_INFO_PVT.Check_Duplicate_Customer :'||SQLERRM);
	END IF;

END Check_Duplicate_Customer;




Procedure Check_Address_Fields (p_address_record IN OE_ORDER_PUB.CUSTOMER_INFO_REC_TYPE
                                ,x_return_status OUT NOCOPY VARCHAR2 ) IS
BEGIN
NULL;
EXCEPTION
         WHEN OTHERS THEN
	 NULL;
END Check_Address_Fields;


Procedure Validate_Address_Fields (p_address_record IN OE_ORDER_PUB.CUSTOMER_INFO_REC_TYPE
                                  ,x_return_status OUT NOCOPY VARCHAR2 )IS
BEGIN

NULL;
EXCEPTION
         WHEN OTHERS THEN
	 NULL;
END Validate_Address_Fields;


Procedure Check_Duplicate_Address ( p_address_record   IN OE_ORDER_PUB.CUSTOMER_INFO_REC_TYPE
                                  , p_sold_to_org_id   IN NUMBER
				  , p_site_customer_id IN NUMBER
				  , p_site_usage       IN VARCHAR2
				  , x_site_usage_id    OUT NOCOPY NUMBER
				  )IS
l_address_validation VARCHAR2(1);
l_site_customer_id NUMBER;
BEGIN
l_address_validation := OE_Sys_Parameters.VALUE('OE_ADDR_VALID_OIMP');


      IF l_address_validation = 'S' THEN
	        l_site_customer_id := p_sold_to_org_id;
      ELSIF  l_address_validation ='R' THEN
		l_site_customer_id := p_site_customer_id;
      ELSE
	x_site_usage_id := NULL;
        RETURN;
      END IF;



IF p_site_usage = 'SHIP_TO' THEN

         x_site_usage_id     := Oe_Value_To_Id.Ship_To_Org(
         p_ship_to_address1 => p_address_record.address1,
         p_ship_to_address2 => p_address_record.address2,
         p_ship_to_address3 => p_address_record.address3,
         p_ship_to_address4 => p_address_record.address4,
         p_ship_to_location => p_address_record.location_number,
         p_ship_to_city     => p_address_record.city,
         p_ship_to_state    => p_address_record.state,
         p_ship_to_postal_code => p_address_record.postal_code,
         p_ship_to_country  => p_address_record.country,
         p_ship_to_org      => p_address_record.location_number,
         p_sold_to_org_id   => p_sold_to_org_id,
	 p_ship_to_customer_id =>l_site_customer_id);

ELSIF p_site_usage = 'BILL_TO' Then

             x_site_usage_id     := Oe_Value_To_Id.Invoice_To_Org(
         p_invoice_to_address1 => p_address_record.address1,
         p_invoice_to_address2 => p_address_record.address2,
         p_invoice_to_address3 => p_address_record.address3,
         p_invoice_to_address4 => p_address_record.address4,
         p_invoice_to_location => p_address_record.location_number,
         p_invoice_to_city     => p_address_record.city,
         p_invoice_to_state    => p_address_record.state,
         p_invoice_to_postal_code => p_address_record.postal_code,
         p_invoice_to_country  => p_address_record.country,
         p_invoice_to_org      => p_address_record.location_number,
         p_sold_to_org_id   => p_sold_to_org_id,
	 p_invoice_to_customer_id => l_site_customer_id);
ELSIF  p_site_usage = 'DELIVER_TO' THEN
	 x_site_usage_id     := Oe_Value_To_Id.Deliver_To_Org(
          p_deliver_to_address1 => p_address_record.address1,
          p_deliver_to_address2 => p_address_record.address2,
          p_deliver_to_address3 => p_address_record.address3,
          p_deliver_to_address4 => p_address_record.address4,
          p_deliver_to_location => p_address_record.location_number,
          p_deliver_to_city     => p_address_record.city,
          p_deliver_to_state    => p_address_record.state,
          p_deliver_to_postal_code => p_address_record.postal_code,
          p_deliver_to_country  => p_address_record.country,
          p_deliver_to_org      => p_address_record.location_number,
          p_sold_to_org_id      => p_sold_to_org_id,
          p_deliver_to_customer_id => l_site_customer_id);
ELSE
	 x_site_usage_id      := Oe_Value_To_Id.Customer_Location
		(   p_sold_to_location_address1              =>p_address_record.address1
		,   p_sold_to_location_address2              =>p_address_record.address2
		,   p_sold_to_location_address3              =>p_address_record.address3
		,   p_sold_to_location_address4              =>p_address_record.address4
		,   p_sold_to_location                       =>p_address_record.location_number
		,   p_sold_to_location_city                  =>p_address_record.city
		,   p_sold_to_location_state                 =>p_address_record.state
		,   p_sold_to_location_postal_code           =>p_address_record.postal_code
		,   p_sold_to_location_country               =>p_address_record.country
		,   p_sold_to_org_id                         =>p_sold_to_org_id
		);


END IF;


EXCEPTION
	WHEN OTHERS THEN
	x_site_usage_id := FND_API.G_MISS_NUM;
END Check_Duplicate_Address;

Procedure Value_To_Id_Address    ( p_address_record   IN OE_ORDER_PUB.CUSTOMER_INFO_REC_TYPE
                                  , p_sold_to_org_id   IN NUMBER
				  , p_site_customer_id IN NUMBER
				  , p_site_usage       IN VARCHAR2
				  , x_site_usage_id    OUT NOCOPY NUMBER
				  ) IS
BEGIN

	IF p_site_usage = 'SHIP_TO' THEN

		 x_site_usage_id     := Oe_Value_To_Id.Ship_To_Org(
		 p_ship_to_address1 => p_address_record.address1,
		 p_ship_to_address2 => p_address_record.address2,
		 p_ship_to_address3 => p_address_record.address3,
		 p_ship_to_address4 => p_address_record.address4,
		 p_ship_to_location => p_address_record.location_number,
		 p_ship_to_city     => p_address_record.city,
		 p_ship_to_state    => p_address_record.state,
		 p_ship_to_postal_code => p_address_record.postal_code,
		 p_ship_to_country  => p_address_record.country,
		 p_ship_to_org      => p_address_record.location_number,
		 p_sold_to_org_id   => p_sold_to_org_id,
		 p_ship_to_customer_id =>p_site_customer_id);

	ELSIF p_site_usage = 'BILL_TO' Then

		     x_site_usage_id     := Oe_Value_To_Id.Invoice_To_Org(
		 p_invoice_to_address1 => p_address_record.address1,
		 p_invoice_to_address2 => p_address_record.address2,
		 p_invoice_to_address3 => p_address_record.address3,
		 p_invoice_to_address4 => p_address_record.address4,
		 p_invoice_to_location => p_address_record.location_number,
		 p_invoice_to_city     => p_address_record.city,
		 p_invoice_to_state    => p_address_record.state,
		 p_invoice_to_postal_code => p_address_record.postal_code,
		 p_invoice_to_country  => p_address_record.country,
		 p_invoice_to_org      => p_address_record.location_number,
		 p_sold_to_org_id      => p_sold_to_org_id,
		 p_invoice_to_customer_id => p_site_customer_id);
	ELSIF  p_site_usage = 'DELIVER_TO' THEN

		 x_site_usage_id     := Oe_Value_To_Id.Deliver_To_Org(
		  p_deliver_to_address1 => p_address_record.address1,
		  p_deliver_to_address2 => p_address_record.address2,
		  p_deliver_to_address3 => p_address_record.address3,
		  p_deliver_to_address4 => p_address_record.address4,
		  p_deliver_to_location => p_address_record.location_number,
		  p_deliver_to_city     => p_address_record.city,
		  p_deliver_to_state    => p_address_record.state,
		  p_deliver_to_postal_code => p_address_record.postal_code,
		  p_deliver_to_country  => p_address_record.country,
		  p_deliver_to_org      => p_address_record.location_number,
		  p_sold_to_org_id      => p_sold_to_org_id,
		  p_deliver_to_customer_id => p_site_customer_id);
	ELSE
		x_site_usage_id      := Oe_Value_To_Id.Customer_Location
		(   p_sold_to_location_address1              =>p_address_record.address1
		,   p_sold_to_location_address2              =>p_address_record.address2
		,   p_sold_to_location_address3              =>p_address_record.address3
		,   p_sold_to_location_address4              =>p_address_record.address4
		,   p_sold_to_location                       =>p_address_record.location_number
		,   p_sold_to_location_city                  =>p_address_record.city
		,   p_sold_to_location_state                 =>p_address_record.state
		,   p_sold_to_location_postal_code           =>p_address_record.postal_code
		,   p_sold_to_location_country               =>p_address_record.country
		,   p_sold_to_org_id                         =>p_sold_to_org_id
		);

	END IF;

EXCEPTION
         WHEN OTHERS THEN
	 x_site_usage_id := FND_API.G_MISS_NUM;
END Value_To_Id_Address;

Procedure Check_Contact_Fields (p_contact_record IN OE_ORDER_PUB.CUSTOMER_INFO_REC_TYPE
                                ,x_return_status OUT NOCOPY VARCHAR2 ) IS
BEGIN

 x_return_status      := FND_API.G_RET_STS_SUCCESS;

IF  p_contact_record.person_first_name IS NULL
    AND p_contact_record.person_last_name IS NULL

  THEN
      fnd_message.set_name('ONT','ONT_PO_INL_REQD');
      fnd_message.set_token('API_NAME', 'CREATE_CONTACT');
      fnd_message.set_token('FIELD_REQD',  'PERSON_FIRST_NAME');
      oe_msg_pub.add;
      x_return_status      := FND_API.G_RET_STS_ERROR;

END IF;

EXCEPTION
         WHEN OTHERS THEN
	 NULL;
END Check_Contact_Fields;


Procedure Validate_Contact_Fields (p_contact_record IN OE_ORDER_PUB.CUSTOMER_INFO_REC_TYPE
                                   ,x_return_status OUT NOCOPY VARCHAR2 ) IS
BEGIN

x_return_status      := FND_API.G_RET_STS_SUCCESS;

IF G_AUTO_CONTACT_NUMBERING = 'N' THEN
	IF p_contact_record.contact_number IS NULL THEN
	   fnd_message.set_name('ONT','ONT_PO_INL_REQD');
	   fnd_message.set_token('API_NAME', 'CREATE_CONTACT');
	   fnd_message.set_token('FIELD_REQD',  'CONTACT_NUMBER');
	   oe_msg_pub.add;
	   x_return_status      := FND_API.G_RET_STS_ERROR;
	END IF;
END IF;

EXCEPTION
         WHEN OTHERS THEN
	 NULL;
END Validate_Contact_Fields;


Function Get_Party_ID ( p_cust_acct_id IN NUMBER)
RETURN NUMBER IS
l_party_id NUMBER;
BEGIN

        select party_id
	into   l_party_id
	from hz_cust_accounts
	where cust_account_id = p_cust_acct_id;

	RETURN l_party_id;

EXCEPTION
	WHEN OTHERS THEN
	RETURN FND_API.G_MISS_NUM;
END Get_Party_ID;

/* This procedure is used to update a address location.This will be called from create_address procedure if
bot ID and Value are passed for address related fields and OE_GLOBALS.G_UPDATE_ON_ID is TRUE
*/

Procedure Update_Location (  p_address_rec IN OE_ORDER_PUB.CUSTOMER_INFO_REC_TYPE
                           , p_site_use_id IN NUMBER
			   , p_site_usage_code IN VARCHAR2
			   , x_return_status OUT NOCOPY VARCHAR2
			   , x_msg_count OUT NOCOPY NUMBER
			   , x_msg_data  OUT NOCOPY VARCHAR2
			   ) IS
l_location_rec HZ_LOCATION_V2PUB.LOCATION_REC_TYPE;
l_location_id NUMBER;
x_ver_number NUMBER;
BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

l_location_id := Get_Location_id (   p_site_usage_code => p_site_usage_code
				     , p_site_use_id    => p_site_use_id
			          );

IF l_location_id <> FND_API.G_MISS_NUM THEN
	  l_location_rec.location_id := l_location_id;
	  l_location_rec.address1 := p_address_rec.address1;
	  l_location_rec.address2 := p_address_rec.address2;
	  l_location_rec.address3 := p_address_rec.address3;
	  l_location_rec.address4 := p_address_rec.address4;
	  l_location_rec.city     := p_address_rec.city;
	  l_location_rec.state    := p_address_rec.state;
	  l_location_rec.postal_code := p_address_rec.postal_code;
	  l_location_rec.country := p_address_rec.country;

	  x_ver_number := Get_obj_version_number(p_location_id => l_location_id);

	 HZ_LOCATION_V2PUB.UPDATE_LOCATION (
		p_init_msg_list  => FND_API.G_TRUE,
		p_location_rec  => l_location_rec,
		p_object_version_number => x_ver_number,
		x_return_status   =>x_return_status,
		x_msg_count =>x_msg_count,
		x_msg_data  =>x_msg_data
		);

ELSE
	x_return_status := FND_API.G_RET_STS_ERROR;
END IF;

EXCEPTION
	WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Update_Location'
            );
        END IF;

END Update_Location;

/* This function returns the current object version number
which will be passed to the TCA APIS in case of updates*/

FUNCTION Get_obj_version_number( p_location_id IN NUMBER DEFAULT NULL
				,p_cust_account_id IN NUMBER DEFAULT NULL
				,p_party_id        IN NUMBER DEFAULT NULL ) RETURN NUMBER
IS
l_version_num NUMBER;
BEGIN

	IF p_location_id IS NOT NULL THEN
		select object_version_number
		into l_version_num
		from hz_locations
		where location_id = p_location_id;
	END IF;

	IF p_cust_account_id IS NOT NULL THEN
		SELECT OBJECT_VERSION_NUMBER
		into l_version_num
		FROM HZ_CUST_ACCOUNTS
		WHERE CUST_ACCOUNT_ID = p_cust_account_id;
	END IF;

	IF p_party_id IS NOT NULL THEN
		SELECT OBJECT_VERSION_NUMBER
		into l_version_num
		FROM HZ_PARTIES
		WHERE party_id = p_party_id;
	END IF;

	RETURN l_version_num;
EXCEPTION
	WHEN OTHERS THEN
	return NULL;
END Get_obj_version_number;

/* This function returns the location_id for the given site_use_id and usage_code */

Function Get_Location_id (  p_site_usage_code IN VARCHAR2 DEFAULT NULL
                          , p_site_use_id     IN NUMBER DEFAULT NULL ) RETURN NUMBER
IS
l_location_id NUMBER;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

    SELECT loc.location_id
    INTO l_location_id
    FROM hz_cust_site_uses   site_uses,
         hz_cust_acct_sites  acct_site,
         hz_party_sites          party_site,
         hz_locations            loc
    WHERE site_uses.cust_acct_site_id =  acct_site.cust_acct_site_id
	AND acct_site.party_site_id     =  party_site.party_site_id
	AND loc.location_id             =  party_site.location_id
	AND site_uses.site_use_code     =  p_site_usage_code
	AND site_uses.site_use_id       =  p_site_use_id;

   IF l_debug_level > 0 THEN
  	oe_debug_pub.add('Get_Location_id :l_location_id :'||l_location_id );
  END IF;

	return l_location_id;

EXCEPTION
	WHEN OTHERS THEN
	IF l_debug_level > 0 THEN
  		oe_debug_pub.add('Unable to retrive the location_id for the site_use_id :'||p_site_use_id||'and site_usage_code :'||p_site_usage_code);
	END IF;
	FND_MESSAGE.set_name('ONT','OE_INVALID_ATTRIBUTE');
	FND_MESSAGE.SET_TOKEN('ATTRIBUTE','SITE_USE_ID');
	OE_MSG_PUB.Add;
	return FND_API.G_MISS_NUM;
END Get_Location_id;


/* This procedure will be called from Create_Account procedure if both ID and Value is passed
for customer fields and OE_GLOBALS.G_UPDATE_ON_ID is TRUE. This API can update Customer_name,
Account_Description,Account_number,Email contact point,Phone contact point*/

Procedure Update_Customer ( p_customer_rec IN OE_ORDER_PUB.CUSTOMER_INFO_REC_TYPE
	  		   , x_return_status OUT NOCOPY VARCHAR2 ) IS
x_version_number  NUMBER;
l_cust_acct_rec HZ_CUST_ACCOUNT_V2PUB.CUST_ACCOUNT_REC_TYPE;
l_person_rec    HZ_PARTY_V2PUB.PERSON_REC_TYPE;
l_organization_rec HZ_PARTY_V2PUB.organization_rec_type;
l_party_rec HZ_PARTY_V2PUB.PARTY_REC_TYPE;

x_msg_count NUMBER;
x_msg_data VARCHAR2(4000);
l_customer_id NUMBER;
l_party_id    NUMBER;
l_party_type VARCHAR2(50);
x_profile_id NUMBER;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN

	x_return_status := FND_API.G_RET_STS_SUCCESS;

	 IF l_debug_level > 0 THEN
		oe_debug_pub.add('Entering OE_CUSTOMER_INFO_PVT.Update_Customer ');
	END IF;

	IF NOT IS_VALID_ID ( p_customer_id => p_customer_rec.customer_id ) THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		RETURN;
	END IF;


	l_party_id       := Get_Party_ID   (p_customer_rec.customer_id);
        l_party_type     := Get_Party_Type (l_party_id);



	IF l_party_type = 'ORGANIZATION' THEN
		l_party_rec.party_id := l_party_id;
		l_organization_rec.party_rec := l_party_rec;
		l_organization_rec.organization_name := p_customer_rec.organization_name;
		x_version_number := Get_obj_version_number(p_party_id => l_party_id);

		hz_party_v2pub.update_organization (
				p_init_msg_list  =>  FND_API.G_TRUE,
			        p_organization_rec => l_organization_rec,
				p_party_object_version_number  => x_version_number,
				x_profile_id      =>x_profile_id,
			        x_return_status   =>x_return_status,
				x_msg_count => x_msg_count,
			        x_msg_data  => x_msg_data );

	ELSE
		l_party_rec.party_id := l_party_id;
		l_person_rec.person_first_name := p_customer_rec.person_first_name;
		l_person_rec.person_middle_name := p_customer_rec.person_middle_name;
		l_person_rec.person_last_name := p_customer_rec.person_last_name;
		l_person_rec.person_title      := p_customer_rec.person_title;
		l_person_rec.person_name_suffix := p_customer_rec.person_name_suffix;
		l_person_rec.party_rec := l_party_rec;
		x_version_number := Get_obj_version_number(p_party_id => l_party_id);

		     hz_party_v2pub.update_person (
			    p_init_msg_list   =>  FND_API.G_TRUE,
			    p_person_rec    => l_person_rec,
			    p_party_object_version_number  => x_version_number,
			    x_profile_id      =>x_profile_id,
			    x_return_status   =>x_return_status,
			    x_msg_count => x_msg_count,
			    x_msg_data  => x_msg_data );


	END IF;

       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		oe_msg_pub.transfer_msg_stack;
		RETURN;
       END IF;


       IF p_customer_rec.email_address IS NOT NULL THEN
		oe_oe_inline_address.create_contact_point
		(
		         in_contact_point_type => 'EMAIL',
			 in_owner_table_id     => l_party_id,
		         in_email	       => p_customer_rec.email_address,
		         in_phone_area_code    => NULL,
		         in_phone_number       => NULL,
		         in_phone_extension    => NULL,
			 in_phone_country_code  => NULL,
			 p_created_by_module    => G_CREATED_BY_MODULE,
			 p_orig_system          => p_customer_rec.orig_system,
			 p_orig_system_reference => p_customer_rec.orig_system_reference,
			 x_return_status        => x_return_status,
			 x_msg_count            => x_msg_count,
			 x_msg_data             => x_msg_data
		 );

	END IF;

       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		oe_msg_pub.transfer_msg_stack;
		RETURN;
       END IF;

       IF p_customer_rec.phone_number IS NOT NULL Then

		oe_oe_inline_address.create_contact_point
	                     (in_contact_point_type =>'PHONE',
                             in_owner_table_id=>l_party_id,
                             in_email=>NULL,
                             in_phone_area_code =>p_customer_rec.phone_area_code,
                             in_phone_number=>p_customer_rec.phone_number,
                             in_phone_extension=>p_customer_rec.phone_extension,
                             in_phone_country_code=>p_customer_rec.phone_country_code,
                             x_return_status=>x_return_status,
                             x_msg_count=>x_msg_count,
                             x_msg_data=>x_msg_data
                     		);
       END IF;

       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		oe_msg_pub.transfer_msg_stack;
		RETURN;
       END IF;

      IF p_customer_rec.customer_number IS NOT NULL
	   OR p_customer_rec.account_description IS NOT NULL THEN

		x_version_number := Get_obj_version_number(p_cust_account_id => p_customer_rec.customer_id);
		l_cust_acct_rec.account_number  := p_customer_rec.customer_number;
 	        l_cust_acct_rec.account_name    := p_customer_rec.account_description;
		l_cust_acct_rec.cust_account_id := p_customer_rec.customer_id;

	       HZ_CUST_ACCOUNT_V2PUB.UPDATE_CUST_ACCOUNT (
		p_init_msg_list  => FND_API.G_TRUE,
		p_cust_account_rec  => l_cust_acct_rec,
		p_object_version_number => x_version_number,
		x_return_status  => x_return_status,
		x_msg_count      =>x_msg_count,
		x_msg_data       =>x_msg_data
		);
	END IF;


       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		oe_msg_pub.transfer_msg_stack;
		RETURN;
       END IF;

	IF l_debug_level > 0 THEN
		oe_debug_pub.add('Update_Customer :x_return_status:'||x_return_status);
		oe_debug_pub.add('Update_Customer:x_msg_count:'||x_msg_count);
		oe_debug_pub.add('Update_Customer :x_msg_data:'||x_msg_data);
		oe_debug_pub.add('Entering OE_CUSTOMER_INFO_PVT.Update_Customer ');
	END IF;

EXCEPTION
		WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
END Update_Customer;

/* This procedure is called from Get_Customer_Info_Ids procedure to create contacts */

Procedure Create_Contact (  p_customer_info_tbl IN OE_ORDER_PUB.CUSTOMER_INFO_TABLE_TYPE
			  , p_operation_code    IN VARCHAR2
			  , p_customer_id IN        NUMBER
                          , p_customer_rec_index IN NUMBER
			  , p_usage_code      IN VARCHAR2
			  , x_sold_to_contact_id IN OUT NOCOPY NUMBER
			  , x_ship_to_contact_id IN OUT NOCOPY NUMBER
			  , x_invoice_to_contact_id IN OUT NOCOPY NUMBER
			  , x_deliver_to_contact_id IN OUT NOCOPY NUMBER
  		          , x_return_status   OUT NOCOPY VARCHAR2
			  , x_msg_count       OUT NOCOPY NUMBER
			  , x_msg_data        OUT NOCOPY VARCHAR2
			  ) IS
l_contact_rec_index NUMBER;
l_contact_rec OE_ORDER_PUB.CUSTOMER_INFO_REC_TYPE;
x_contact_id NUMBER;
out_cont_name VARCHAR2(1000);
x_sold_to_cont_index NUMBER;
x_ship_to_cont_index  NUMBER;
x_bill_to_cont_index  NUMBER;
x_deliver_to_cont_index NUMBER;

x_cust_account_id NUMBER;
x_party_id        NUMBER;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
x_customer_id NUMBER;
l_customer_id NUMBER;
l_site_use_id NUMBER;
BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

IF l_debug_level > 0 THEN
	oe_debug_pub.add('Entering OE_CUSTMER_INFO_PVT.Create_Contact');
END IF;

l_contact_rec := p_customer_info_tbl(p_customer_rec_index);


IF NVL( l_contact_rec.contact_id ,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM THEN

		  Value_To_Id_Contact ( p_contact_record  => l_contact_rec
                                       , p_customer_id         => p_customer_id
				       , p_site_usage_code     => p_usage_code
				       , p_site_usage_id       => l_site_use_id
				       , x_contact_id          => x_contact_id
				      );
		IF x_contact_id = FND_API.G_MISS_NUM THEN
		     oe_msg_pub.delete_msg(oe_msg_pub.g_msg_count);
		ELSE
			IF p_usage_code = 'SOLD_TO' THEN
				x_sold_to_contact_id := x_contact_id;
		        ELSIF p_usage_code = 'SHIP_TO' THEN
				x_ship_to_contact_id := x_contact_id;
		        ELSIF p_usage_code = 'BILL_TO' THEN
				x_invoice_to_contact_id := x_contact_id;
	                ELSE
				x_deliver_to_contact_id := x_contact_id;
		        END IF;
		END IF;
 ELSE
		--Update Contact logic to go here
		IF IS_BOTH_ID_VAL_PASSED( p_contact_rec => l_contact_rec )
	           AND OE_GLOBALS.G_UPDATE_ON_ID
             	THEN
			Update_Contact (p_contact_rec => l_contact_rec
			   , x_return_status =>x_return_status
			   , x_msg_count => x_msg_count
			   , x_msg_data  => x_msg_data
			   );
	        END IF;

		IF l_debug_level > 0  THEN
			oe_debug_pub.add('Update_Location :x_return_status'||x_return_status);
			oe_debug_pub.add('Update_Location :x_msg_count'||x_msg_count);
			oe_debug_pub.add('Update_Location :x_msg_data'||x_msg_data);
		END IF;

		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		        oe_msg_pub.transfer_msg_stack;
			RETURN;
		END IF;


	 IF p_usage_code = 'SOLD_TO' THEN
		x_sold_to_contact_id := l_contact_rec.contact_id;
	 ELSIF p_usage_code = 'SHIP_TO' THEN
		x_ship_to_contact_id := l_contact_rec.contact_id;
	 ELSIF p_usage_code = 'BILL_TO' THEN
		x_invoice_to_contact_id := l_contact_rec.contact_id;
	 ELSE
		x_deliver_to_contact_id := l_contact_rec.contact_id;
	 END IF;


	  x_contact_id :=l_contact_rec.contact_id;

END IF;

IF NVL(x_contact_id , FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM THEN

		Check_Contact_Fields (l_contact_rec,x_return_status);

		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			RETURN;
		END IF;

		Validate_Contact_Fields(l_contact_rec,x_return_status);

		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			RETURN;
		END IF;

		oe_oe_inline_address.create_contact(
					p_contact_last_name  => l_contact_rec.person_last_name,
					p_contact_first_name => l_contact_rec.person_first_name,
					p_contact_title      => l_contact_rec.person_title,
					p_email              => l_contact_rec.email_address,
					p_area_code          => l_contact_rec.phone_area_code,
					p_phone_number       => l_contact_rec.phone_number,
					p_extension          => l_contact_rec.phone_extension,
					p_acct_id            => p_customer_id,
					p_party_id           => Get_party_id(p_customer_id),
					in_phone_country_code => l_contact_rec.phone_country_code,
					p_created_by_module   => G_CREATED_BY_MODULE,
					p_orig_system         => l_contact_rec.orig_system,
					p_orig_system_reference     => l_contact_rec.orig_system_reference,
					c_attribute_category =>l_contact_rec.attribute_category,
					c_attribute1=>l_contact_rec.attribute1,
					c_attribute2=>l_contact_rec.attribute2,
					c_attribute3=>l_contact_rec.attribute3,
					c_attribute4=>l_contact_rec.attribute4,
					c_attribute5=>l_contact_rec.attribute5,
					 c_attribute6=>l_contact_rec.attribute6,
					 c_attribute7=>l_contact_rec.attribute7,
					 c_attribute8=>l_contact_rec.attribute8,
					 c_attribute9=>l_contact_rec.attribute9,
					 c_attribute10=>l_contact_rec.attribute10,
					 c_attribute11=>l_contact_rec.attribute11,
					 c_attribute12=>l_contact_rec.attribute12,
					 c_attribute13=>l_contact_rec.attribute13,
					 c_attribute14=>l_contact_rec.attribute14,
					 c_attribute15=>l_contact_rec.attribute15,
					 c_attribute16=>l_contact_rec.attribute16,
					 c_attribute17=>l_contact_rec.attribute17,
					 c_attribute18=>l_contact_rec.attribute18,
					 c_attribute19=>l_contact_rec.attribute19,
					 c_attribute20=>l_contact_rec.attribute20,
					 c_attribute21=>l_contact_rec.attribute21,
					 c_attribute22=>l_contact_rec.attribute22,
					 c_attribute23=>l_contact_rec.attribute23,
					 c_attribute24=>l_contact_rec.attribute24,
					 c_attribute25=>l_contact_rec.attribute25,
					 c2_attribute_category=>l_contact_rec.global_attribute_category,
					 c2_attribute1=>l_contact_rec.global_attribute1,
					 c2_attribute2=>l_contact_rec.global_attribute2,
					 c2_attribute3=>l_contact_rec.global_attribute3,
					 c2_attribute4=>l_contact_rec.global_attribute4,
					 c2_attribute5=>l_contact_rec.global_attribute5,
					 c2_attribute6=>l_contact_rec.global_attribute6,
					 c2_attribute7=>l_contact_rec.global_attribute7,
					 c2_attribute8=>l_contact_rec.global_attribute8,
					 c2_attribute9=>l_contact_rec.global_attribute9,
					 c2_attribute10=>l_contact_rec.global_attribute10,
					 c2_attribute11=>l_contact_rec.global_attribute11,
					 c2_attribute12=>l_contact_rec.global_attribute12,
					 c2_attribute13=>l_contact_rec.global_attribute13,
					 c2_attribute14=>l_contact_rec.global_attribute14,
					 c2_attribute15=>l_contact_rec.global_attribute15,
					 c2_attribute16=>l_contact_rec.global_attribute16,
					 c2_attribute17=>l_contact_rec.global_attribute17,
					 c2_attribute18=>l_contact_rec.global_attribute18,
					 c2_attribute19=>l_contact_rec.global_attribute19,
					 c2_attribute20=>l_contact_rec.global_attribute20,
					 x_return_status      =>x_return_status,
					 x_msg_count          =>x_msg_count,
					 x_msg_data           =>x_msg_data,
					 x_contact_id         =>x_contact_id,
					 x_contact_name       => out_cont_name  );
	IF l_debug_level > 0 THEN
			oe_debug_pub.add('Create Contact x_return_status :'||x_return_status);
			oe_debug_pub.add('Create Contact x_msg_data:'||x_msg_data);
			oe_debug_pub.add('Create Contact out_cont_id :'||x_contact_id);
			oe_debug_pub.add('Create Contact out_cont_name :'||out_cont_name);

	 END IF;

	 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		oe_msg_pub.transfer_msg_stack;
		RETURN;
	 END IF;

	 IF p_usage_code = 'SOLD_TO' THEN
		x_sold_to_contact_id := x_contact_id;
	 ELSIF p_usage_code = 'SHIP_TO' THEN
		x_ship_to_contact_id := x_contact_id;
	 ELSIF p_usage_code = 'BILL_TO' THEN
		x_invoice_to_contact_id := x_contact_id;
	 ELSE
		x_deliver_to_contact_id := x_contact_id;
	 END IF;


END IF;



 IF l_debug_level > 0 THEN
  	oe_debug_pub.add('Exiting OE_CUSTMER_INFO_PVT.Create_Contact');
  END IF;

EXCEPTION
	WHEN OTHERS THEN

	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Create_Contact'
            );
        END IF;

	  IF l_debug_level > 0 THEN
  		oe_debug_pub.add('Create_account Other Errors :'||SQLERRM);
	  END IF;

END Create_Contact;



Function IS_BOTH_ID_VAL_PASSED ( p_customer_rec IN OE_ORDER_PUB.CUSTOMER_INFO_REC_TYPE)
RETURN BOOLEAN
IS
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
	IF NVL(p_customer_rec.customer_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM    THEN
		IF NVL(p_customer_rec.organization_name,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR
		   OR NVL(p_customer_rec.account_description,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR
		   OR NVL(p_customer_rec.customer_number,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR
		   OR NVL(p_customer_rec.person_first_name,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR
		   OR NVL(p_customer_rec.person_middle_name,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR
		   OR NVL(p_customer_rec.person_last_name,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR
		   OR NVL(p_customer_rec.person_title,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR
		   OR NVL(p_customer_rec.person_name_suffix,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR
		THEN
			IF l_debug_level > 0 THEN
				oe_debug_pub.add('Both ID and Value Passed for Customer record');
			END IF;
			RETURN TRUE;
	        END IF;
         END IF;

	RETURN FALSE;
END IS_BOTH_ID_VAL_PASSED;


Function IS_BOTH_ID_VAL_PASSED ( p_address_rec IN OE_ORDER_PUB.CUSTOMER_INFO_REC_TYPE)
RETURN BOOLEAN
IS
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

	IF NVL(p_address_rec.site_use_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN

		IF     NVL(p_address_rec.country,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR
		   OR NVL(p_address_rec.state,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR
		   OR NVL(p_address_rec.city,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR
		   OR NVL(p_address_rec.county,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR
		   OR NVL(p_address_rec.postal_code,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR
		   OR NVL(p_address_rec.ADDRESS1,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR
		   OR NVL(p_address_rec.ADDRESS2,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR
		   OR NVL(p_address_rec.ADDRESS3,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR
		   OR NVL(p_address_rec.ADDRESS4,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR
		THEN
			IF l_debug_level > 0 THEN
				oe_debug_pub.add('Both ID and Value Passed for address record');
			END IF;

			RETURN TRUE;
		END IF;
	END IF;
			RETURN FALSE;
END IS_BOTH_ID_VAL_PASSED;



Function IS_BOTH_ID_VAL_PASSED ( p_contact_rec IN OE_ORDER_PUB.CUSTOMER_INFO_REC_TYPE)
RETURN BOOLEAN
IS
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
	IF NVL(p_contact_rec.contact_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM    THEN
		IF    NVL(p_contact_rec.person_first_name,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR
		   OR NVL(p_contact_rec.person_middle_name,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR
		   OR NVL(p_contact_rec.person_last_name,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR
		   OR NVL(p_contact_rec.person_title,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR
		   OR NVL(p_contact_rec.person_name_suffix,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR
		THEN
			IF l_debug_level > 0 THEN
				oe_debug_pub.add('Both ID and Value Passed for Customer record');
			END IF;
			RETURN TRUE;
	        END IF;
         END IF;

	RETURN FALSE;

END IS_BOTH_ID_VAL_PASSED;

/* This function returns true if a relation ship already exists between the two customers */
Function check_relation_exists (  p_customer_id IN NUMBER
				  ,p_rel_customer_id NUMBER ) RETURN BOOLEAN
IS
l_exists VARCHAR2(1);
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

        SELECT 'Y' INTO l_exists
        FROM HZ_CUST_ACCT_RELATE
        WHERE CUST_ACCOUNT_ID = p_customer_id
        AND RELATED_CUST_ACCOUNT_ID = p_rel_customer_id
	AND STATUS='A';

	IF l_exists = 'Y' THEN
		IF l_debug_level > 0 THEN
			oe_debug_pub.add('Relation ship already exists between these two customers');
		END IF;

		RETURN TRUE;
	ELSE
		RETURN FALSE;
	END IF;
EXCEPTION
	WHEN OTHERS THEN
	IF l_debug_level > 0 THEN
			oe_debug_pub.add('Relation ship does not  exists .Create it');
	END IF;

	RETURN FALSE;

END check_relation_exists;

FUNCTION IS_VALID_ID ( p_party_id IN NUMBER DEFAULT NULL ,
		       p_customer_id IN NUMBER DEFAULT NULL ) RETURN BOOLEAN
IS
l_exists varchar2(1);
BEGIN

IF NVL(p_customer_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
	RETURN ( oe_validate.customer(p_customer_id => p_customer_id ));
END IF;

IF NVL(p_party_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
		select 'Y'
		into l_exists
		from HZ_PARTIES
		Where party_id = p_party_id;

		RETURN TRUE;
END IF;

	RETURN FALSE;
EXCEPTION
	WHEN OTHERS THEN
	RETURN FALSE;
END IS_VALID_ID;



Procedure Value_To_Id_contact( p_contact_record   IN OE_ORDER_PUB.CUSTOMER_INFO_REC_TYPE
                             , p_customer_id   IN NUMBER
			     , p_site_usage_code       IN VARCHAR2
			     , p_site_usage_id    OUT NOCOPY NUMBER
			     , x_contact_id       OUT NOCOPY NUMBER
				 )IS
l_contact_name VARCHAR2(5000);
BEGIN
    x_contact_id := FND_API.G_MISS_NUM;

    Select p_contact_record.person_last_name
           || DECODE(p_contact_record.person_first_name,  NULL, NULL, ', '
	   || p_contact_record.PERSON_FIRST_NAME)
	   || DECODE(p_contact_record.Person_Name_Suffix, NULL, NULL, ', '
	   ||p_contact_record.Person_Name_Suffix)
    Into l_contact_name
    From Dual;

     x_contact_id :=  Oe_Value_To_Id.Sold_To_Contact(
			  p_sold_to_contact    => l_contact_name,
			  p_sold_to_org_id     => p_customer_id);



EXCEPTION
	WHEN OTHERS THEN
	x_contact_id := FND_API.G_MISS_NUM;

END Value_To_Id_contact;

/*This function checks whether the passed  site usage already exits for the passed account site */
PROCEDURE Check_site_usage_exists ( p_cust_acct_site_id IN NUMBER
				    ,p_site_usage         IN VARCHAR2
				    ,x_site_use_id        OUT NOCOPY NUMBER)
IS
BEGIN

x_site_use_id := FND_API.G_MISS_NUM;

    SELECT site_uses.site_use_id
    INTO   x_site_use_id
    FROM hz_cust_acct_sites  acct_site,
         hz_cust_site_uses   site_uses,
         hz_party_sites          party_site,
         hz_locations            loc
    WHERE site_uses.cust_acct_site_id =  acct_site.cust_acct_site_id
	AND acct_site.party_site_id     =  party_site.party_site_id
	AND loc.location_id             =  party_site.location_id
	AND site_uses.site_use_code     =  p_site_usage
	AND acct_site.CUST_ACCT_SITE_ID = p_cust_acct_site_id
	AND  site_uses.STATUS = 'A';



EXCEPTION
	WHEN OTHERS THEN
	x_site_use_id := FND_API.G_MISS_NUM;
END Check_site_usage_exists;

FUNCTION Get_Party_Type ( p_party_id IN NUMBER )RETURN VARCHAR2
IS
l_party_type VARCHAR2(50);
BEGIN
	select party_type
	into l_party_type
	from hz_parties
	where party_id = p_party_id;

	RETURN l_party_type;

EXCEPTION
	WHEN OTHERS THEN
	RETURN NULL;
END Get_Party_Type;

/* Updates the contact information like person name,title,email,phone  .Called from create_contact procedure
if both ID and value are passed in contact record and OE_GLOBALS.G_UPDATE_ON_ID is TRUE*/

PROCEDURE Update_Contact  ( p_contact_rec IN OE_ORDER_PUB.CUSTOMER_INFO_REC_TYPE
			   , x_return_status  OUT NOCOPY VARCHAR2
			   , x_msg_count      OUT NOCOPY NUMBER
			   , x_msg_data       OUT NOCOPY VARCHAR2
			   )
IS
l_party_id NUMBER;
x_profile_id NUMBER;
l_person_rec    HZ_PARTY_V2PUB.PERSON_REC_TYPE;
l_party_rec HZ_PARTY_V2PUB.PARTY_REC_TYPE;
x_version_number NUMBER;
l_rel_party_id NUMBER;
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

	IF l_debug_level > 0 THEN
		oe_debug_pub.add('Entering OE_CUSTOMER_INFO_PVT.Update_Contact ');
	END IF;
begin

 SELECT party.party_id,REL_PARTY.party_id
 into l_party_id , l_rel_party_id
 FROM HZ_CUST_ACCOUNT_ROLES ACCT_ROLE,
 HZ_PARTIES PARTY,
 HZ_CUST_ACCOUNTS ACCT,
 HZ_RELATIONSHIPS REL,
 HZ_ORG_CONTACTS ORG_CONT,
 HZ_PARTIES REL_PARTY
 WHERE ACCT_ROLE.PARTY_ID = REL.PARTY_ID
 AND ACCT_ROLE.ROLE_TYPE = 'CONTACT'
 AND ORG_CONT.PARTY_RELATIONSHIP_ID = REL.RELATIONSHIP_ID
 AND REL.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
 AND REL.OBJECT_TABLE_NAME = 'HZ_PARTIES'
 AND REL.SUBJECT_ID = PARTY.PARTY_ID
 AND REL.PARTY_ID = REL_PARTY.PARTY_ID
 AND REL.OBJECT_ID = ACCT.PARTY_ID
 AND ACCT.CUST_ACCOUNT_ID = ACCT_ROLE.CUST_ACCOUNT_ID
 AND ACCT_ROLE.CUST_ACCOUNT_ROLE_ID = p_contact_rec.contact_id;

Exception
	WHEN OTHERS THEN
	fnd_message.set_name('ONT','OE_INVALID_ATTRIBUTE');
	FND_MESSAGE.SET_TOKEN('ATTRIBUTE','CONTACT_ID');
	OE_MSG_PUB.Add;
	x_return_status := FND_API.G_RET_STS_ERROR;
End;

		l_party_rec.party_id            := l_party_id;
		l_person_rec.party_rec          := l_party_rec;
		l_person_rec.person_first_name  := p_contact_rec.person_first_name;
		l_person_rec.person_middle_name  := p_contact_rec.person_middle_name;
		l_person_rec.person_last_name  := p_contact_rec.person_last_name;
		l_person_rec.person_title       := p_contact_rec.person_title;
		l_person_rec.person_name_suffix := p_contact_rec.person_name_suffix;
		x_version_number                := Get_obj_version_number(p_party_id => l_party_id);

		hz_party_v2pub.update_person (
			    p_init_msg_list   =>  FND_API.G_TRUE,
			    p_person_rec    => l_person_rec,
			    p_party_object_version_number  => x_version_number,
			    x_profile_id      =>x_profile_id,
			    x_return_status   =>x_return_status,
			    x_msg_count => x_msg_count,
			    x_msg_data  => x_msg_data );



IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	oe_msg_pub.transfer_msg_stack;
	RETURN;
END IF;


IF p_contact_rec.email_address IS NOT NULL THEN
		oe_oe_inline_address.create_contact_point
		(
		         in_contact_point_type => 'EMAIL',
			 in_owner_table_id     => l_rel_party_id,
		         in_email	       => p_contact_rec.email_address,
		         in_phone_area_code    => NULL,
		         in_phone_number       => NULL,
		         in_phone_extension    => NULL,
			 in_phone_country_code  => NULL,
			 p_created_by_module    => G_CREATED_BY_MODULE,
			 p_orig_system          => p_contact_rec.orig_system,
			 p_orig_system_reference => p_contact_rec.orig_system_reference,
			 x_return_status        => x_return_status,
			 x_msg_count            => x_msg_count,
			 x_msg_data             => x_msg_data
		 );

END IF;

IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	oe_msg_pub.transfer_msg_stack;
	RETURN;
END IF;

IF p_contact_rec.phone_number IS NOT NULL Then

	oe_oe_inline_address.create_contact_point
	                     (in_contact_point_type =>'PHONE',
                             in_owner_table_id=>l_rel_party_id,
                             in_email=>NULL,
                             in_phone_area_code =>p_contact_rec.phone_area_code,
                             in_phone_number=>p_contact_rec.phone_number,
                             in_phone_extension=>p_contact_rec.phone_extension,
                             in_phone_country_code=>p_contact_rec.phone_country_code,
                             x_return_status=>x_return_status,
                             x_msg_count=>x_msg_count,
                             x_msg_data=>x_msg_data
                     		);
       END IF;

IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	oe_msg_pub.transfer_msg_stack;
	RETURN;
END IF;



        IF l_debug_level > 0 THEN
		oe_debug_pub.add('Update_Contact :x_return_status:'||x_return_status);
		oe_debug_pub.add('Update_Contact :x_msg_count:'||x_msg_count);
		oe_debug_pub.add('Update_Contact :x_msg_data:'||x_msg_data);
		oe_debug_pub.add('Entering OE_CUSTOMER_INFO_PVT.Update_Contact ');
	END IF;

EXCEPTION
	WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_ERROR;

	IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Update_Contact'
            );
        END IF;

	IF l_debug_level > 0 THEN
  		oe_debug_pub.add('Update_Contact Other Errors :'||SQLERRM);
	END IF;


END Update_Contact;

END OE_CUSTOMER_INFO_PVT;

/
