--------------------------------------------------------
--  DDL for Package Body ONT_ITM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ONT_ITM_PKG" AS
/* $Header: OEXVITMB.pls 120.15.12010000.13 2010/12/02 07:51:54 sahvivek ship $ */

G_PKG_NAME         CONSTANT VARCHAR2(30) := 'ONT_ITM_PKG';
G_Dp_Service_Flag      VARCHAR2(1) := 'N'; --bug 5009103


/*-----------------------------------------------------+
 | Name        :   Process_ITM_Request                 |
 | Parameters  :   IN  p_line_rec                      |
 |                 OUT NOCOPY x_return_status          |
 |                            x_result_out             |
 | Description :   This Procedure is called from Work  |
 |                 Flow for Performing Screening       |
 |                                                     |
 +-----------------------------------------------------*/

PROCEDURE Process_ITM_Request
(p_line_rec        IN  OE_ORDER_PUB.line_rec_type
,x_return_status   OUT NOCOPY VARCHAR2
,x_result_out      OUT NOCOPY VARCHAR2
)

IS
l_api_name                  CONSTANT VARCHAR2(30)    := 'Process_ITM_Request';
l_master_organization_id    NUMBER;
l_return_status		    VARCHAR2(1000);
l_result_out		    VARCHAR2(2400);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
      SAVEPOINT	CREATE_REQUEST_PUB;

      IF l_debug_level  > 0 THEN
         OE_DEBUG_PUB.ADD('Starting process_itm_request...'||'for line id:'||p_line_rec.line_id);
      END IF;

      SELECT master_organization_id
      INTO   l_master_organization_id
      FROM   mtl_parameters
      WHERE  organization_id = p_line_rec.ship_from_org_id;

      Create_Request(
		p_master_organization_id  =>  l_master_organization_id ,
		p_line_rec  	          =>  p_line_rec ,
		x_return_status	          =>  l_return_status);

      IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

	 x_return_status    := FND_API.G_RET_STS_SUCCESS;
	 x_result_out 	    := OE_GLOBALS.G_WFR_COMPLETE;

         --  The Flow Status is updated to Export Compliance Screening

         IF l_debug_level  > 0 THEN
            OE_DEBUG_PUB.Add('Before calling update flow status to...'|| 'AWAITING EXPORT SCREENING' ) ;
         END IF;

	 OE_ORDER_WF_UTIL.Update_Flow_Status_Code
                    (p_line_id                =>   p_line_rec.line_id
                     ,p_flow_status_code      =>   'AWAITING_EXPORT_SCREENING'
                     ,x_return_status         =>   l_return_status
                     );

         IF l_debug_level  > 0 THEN
            OE_DEBUG_PUB.Add('Return status from flow status api '|| l_return_status,1);
         END IF;

         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	    x_result_out 	:= OE_GLOBALS.G_WFR_INCOMPLETE;
         END IF;

      ELSIF l_return_status  = FND_API.G_RET_STS_ERROR THEN
            x_return_status := FND_API.G_RET_STS_ERROR;

            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  'NOT ABLE TO CREATE REQUEST...' , 1 ) ;
            END IF;

            -- The Flow Status is updated to Export Compliance Screening

	    OE_Order_WF_Util.Update_Flow_Status_Code
                 (p_line_id               =>   p_line_rec.line_id
                 ,p_flow_status_code      =>   'EXPORT_SCREENING_DATA_ERROR'
                 ,x_return_status         =>   l_return_status
                  );

            IF l_debug_level  > 0 THEN
               OE_DEBUG_PUB.Add('Return status from flow status api '|| l_return_status,1);
            END IF;

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	       x_result_out 	:= OE_GLOBALS.G_WFR_INCOMPLETE;
	    END IF;

      ELSE
	 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

      END IF;  -- End of checking l_return_status

      IF l_debug_level  > 0 THEN
         OE_DEBUG_PUB.Add('Ending process_itm_request...'|| 'for line id:'||p_line_rec.line_id);
      END IF;

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
           ROLLBACK TO CREATE_REQUEST_PUB;
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   ROLLBACK TO CREATE_REQUEST_PUB;
        WHEN OTHERS THEN
   	   ROLLBACK TO CREATE_REQUEST_PUB;
	IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	   FND_MSG_PUB.Add_Exc_Msg
    	    			(G_PKG_NAME,
    	    			 l_api_name
	    			);
	END IF;
END  Process_ITM_Request;

-- Function added for bug5140692
-- Function changed to procedure for Bug 9583024, and three new out parameters added
PROCEDURE Get_Contact_name
(
  p_contact_id IN NUMBER,
  x_contact_name   OUT NOCOPY VARCHAR2,
  x_contact_hz_id  OUT NOCOPY NUMBER,
  x_contact_number OUT NOCOPY VARCHAR2)
IS

l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add('OEXVITMB.pls: Inside Get_Contact_name, contact_id='||p_contact_id,3);
  END IF;

  SELECT PARTY.PARTY_NAME, party.party_id, party.party_number
   INTO  x_contact_name, x_contact_hz_id, x_contact_number   --Bug 9583024
  FROM HZ_CUST_ACCOUNT_ROLES  ACCT_ROLE,
       HZ_PARTIES             PARTY,
       HZ_CUST_ACCOUNTS       ACCT,
       HZ_RELATIONSHIPS       REL,
       HZ_PARTIES             REL_PARTY
  WHERE ACCT_ROLE.CUST_ACCOUNT_ROLE_ID = p_contact_id
    AND ACCT_ROLE.PARTY_ID             = REL.PARTY_ID
    AND ACCT_ROLE.ROLE_TYPE            = 'CONTACT'
    AND REL.SUBJECT_TABLE_NAME         = 'HZ_PARTIES'
    AND REL.OBJECT_TABLE_NAME          = 'HZ_PARTIES'
    AND REL.SUBJECT_ID                 = PARTY.PARTY_ID
    AND REL.PARTY_ID                   = REL_PARTY.PARTY_ID
    AND REL.OBJECT_ID                  = ACCT.PARTY_ID
    AND ACCT.CUST_ACCOUNT_ID           = ACCT_ROLE.CUST_ACCOUNT_ID;


    IF l_debug_level  > 0 THEN
      oe_debug_pub.add('OEXVITMB.pls: Contact name ='||x_contact_name,5);
      oe_debug_pub.add('OEXVITMB.pls: Contact Hz id ='||x_contact_hz_id,5);
      oe_debug_pub.add('OEXVITMB.pls: Contact Hz number ='||x_contact_number,5);
      oe_debug_pub.add('Exiting Get_Contact_name',3);
    END IF;


EXCEPTION
  WHEN NO_DATA_FOUND THEN
       IF l_debug_level  > 0 THEN
         oe_debug_pub.add('OEXVITMB: NO_DATA_FOUND exception..',3 );
       END IF;
       Raise;
  WHEN OTHERS THEN
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add('OEXVITMB: OTHERS exception in Get_Contact_name...',3 );
       END IF;
       Raise;
END Get_Contact_name;

/*-----------------------------------------------------+
 | Name        :   Get_Address                         |
 | Parameters  :   IN  p_source_id                     |
 |                     p_source_type                   |
 |                     p_contact_id                    |
 |                 OUT NOCOPY x_party_name             |
 |                     x_alternate_name  bug 4231894   |
 |                     x_address                       |
 |                     x_city                          |
 |                     x_state                         |
 |                     x_country                       |
 |                     x_postal_code                   |
 |      	       x_phone 		               |
 |                     x_email 	                       |
 |                     x_fax 			       |
 |                     x_url                           |
 |                     x_contact_person                |
 |                     x_hz_party_id                   |
 |                     x_hz_party_number               |
 |                     x_party_site_number             |
 |                     x_contact_hz_party_id           |
 |                     x_contact_hz_party_number       |
 |                     x_return_status                 |
 | Description :   This Procedure gets the address     |
 |                 details of sources                  |
 |                                                     |
 +-----------------------------------------------------*/

PROCEDURE Get_Address (
 p_source_id               IN  NUMBER
,p_source_type             IN  VARCHAR2
,p_contact_id		   IN  NUMBER
,p_org_id_passed           IN  VARCHAR2
,x_party_name              OUT NOCOPY VARCHAR2
,x_alternate_name          OUT NOCOPY VARCHAR2 -- bug4231894
,x_address1                OUT NOCOPY VARCHAR2 -- bug7485980
,x_address2                OUT NOCOPY VARCHAR2 -- bug7485980
,x_address3                OUT NOCOPY VARCHAR2 -- bug7485980
,x_address4                OUT NOCOPY VARCHAR2 -- bug7485980
,x_city                    OUT NOCOPY VARCHAR2
,x_state                   OUT NOCOPY VARCHAR2
,x_country                 OUT NOCOPY VARCHAR2
,x_postal_code             OUT NOCOPY VARCHAR2
,x_phone                   OUT NOCOPY VARCHAR2
,x_email                   OUT NOCOPY VARCHAR2
,x_fax                     OUT NOCOPY VARCHAR2
,x_url                     OUT NOCOPY VARCHAR2
,x_contact_person          OUT NOCOPY VARCHAR2
,x_hz_party_id             OUT NOCOPY NUMBER   -- Bug 9583024
,x_hz_party_number         OUT NOCOPY VARCHAR2 -- Bug 9583024
,x_party_site_number       OUT NOCOPY VARCHAR2 -- Bug 9583024
,x_contact_hz_party_id     OUT NOCOPY NUMBER   -- Bug 9583024
,x_contact_hz_party_number OUT NOCOPY VARCHAR2 -- Bug 9583024
,x_return_status           OUT NOCOPY VARCHAR2
)
IS
l_api_name              CONSTANT VARCHAR2(30)	:= 'Get_Address';
c_fax                   VARCHAR2(1000) default null;
c_email                 VARCHAR2(1000) default null;
c_phone                 VARCHAR2(1000) default null;
c_contact_name          VARCHAR2(1000) default null;
l_source_type           VARCHAR2(35);

   -- This Cursor is used for getting the Address Details for the
   -- Ship_to_org_id details. The same cursor is used for ship_to,
   -- deliver_to,Invoice_to.
   -- NULL values are passed into the State column.
   -- Modified the address cursors to remove concatenation of , in addresses for bug 7485890
   -- Modified the cursor for Bug 9583024
    CURSOR C_GET_ADDRESS (cp_source_id  NUMBER, cp_source_type  VARCHAR2)
    IS
    SELECT
          site_uses.site_use_id         source_id,
          decode(cp_source_type, 'END_CUSTOMER', cp_source_type, site_uses.site_use_code) source_type, --Bug 9583024
          party.party_name              party_name,
	  loc.address1                  address1,
	  loc.address2                  address2,
	  loc.address3                  address3,
	  loc.address4                  address4,
          --  ltrim(rtrim(loc.address1||','||loc.address2||
          --          ','||loc.address3||','||loc.address4)) address,
          loc.city                      city,
          loc.state                     state,
          loc.country                   country,
          loc.postal_code               postal_code,
          decode(party.party_type,'PERSON',hp.person_name_phonetic, party.organization_name_phonetic )  alternate_name,
          party.party_id                hz_party_id,      -- Bug 9583024
          party.party_number            hz_party_number , -- Bug 9583024
          party_site.party_site_number party_site_number  -- Bug 9583024
    FROM
          hz_cust_site_uses_all   site_uses,
          hz_cust_acct_sites_all  acct_site,
          hz_party_sites          party_site,
          hz_locations            loc,
          hz_cust_accounts        cust_acct,
          hz_parties              party,
          hz_Person_profiles      hp
    WHERE
            site_uses.cust_acct_site_id = acct_site.cust_acct_site_id
        AND acct_site.cust_account_id   = cust_acct.cust_account_id
        AND party.party_id              = cust_acct.party_id
        AND acct_site.party_site_id     = party_site.party_site_id
        AND loc.location_id             = party_site.location_id
        AND site_uses.site_use_code     = decode(cp_source_type, 'END_CUSTOMER', site_uses.site_use_code, cp_source_type) --Bug 9583024
        AND site_uses.site_use_id       = cp_source_id
        AND hp.party_id(+)              = party.party_id -- bug 4231894
        AND rownum                      = 1;

    CURSOR  C_SHIP_FROM_ADDRESS_SF (cp_ship_from_org_id  NUMBER)
    IS
    SELECT
	  hu.organization_id   	source_id,
	  'SHIP_FROM' 		source_type,
       	  hu.name     		party_name,
	  hl.address_line_1     address1,
	  hl.address_line_2     address2,
	  hl.address_line_3     address3,
       	  --  ltrim(rtrim(hl.address_line_1||','||
          --           hl.address_line_2||','||hl.address_line_3)) address,
       	  hl.town_or_city    	city,
          hl.region_2        	state,
       	  hl.country         	country,
       	  hl.postal_code      	postal_code,
          hl.telephone_number_1 	phone,
          NULL email,
          NULL fax,
          NULL url
     FROM
          hr_all_organization_units hu,
          hr_locations hl
     WHERE
	      hl.location_id = hu.location_id
          AND hu.organization_id = cp_ship_from_org_id;

     --  This cursor is specifically for the Sold_to Details
     --  Cursor modified for Bug 9583024
     CURSOR C_SOLD_TO_ADDRESS(cp_sold_to_org_id NUMBER)
     IS
     SELECT
           cust_acct.cust_account_id     source_id,
           'SOLD_TO'                     source_type,
           party.party_name              party_name,
	   loc.address1                  address1,
	   loc.address2                  address2,
	   loc.address3                  address3,
	   loc.address4                  address4,
           --  ltrim(rtrim(loc.address1||','||loc.address2
           --       ||','||loc.address3||','||loc.address4))   address,
           loc.city                      city,
           loc.state                     state,
           loc.country                   country,
           loc.postal_code               postal_code,
           decode(party.party_type,'ORGANIZATION',party.organization_name_phonetic
                                                 ,hp.person_name_phonetic) alternate_name, -- bug4231894
           party.party_id                hz_party_id ,     -- Bug 9583024
           party.party_number            hz_party_number , -- Bug 9583024
           party_site.party_site_number party_site_number  -- Bug 9583024
     FROM
           hz_parties           party,
           hz_cust_accounts     cust_acct,
           hz_locations         loc,
           hz_party_sites       party_site,
           hz_Person_profiles   hp
     WHERE
               party.party_id            = cust_acct.party_id
           AND cust_acct.cust_account_id = cp_sold_to_org_id
           AND party_site.party_id       = party.party_id
           AND loc.location_id           = party_site.location_id
           AND hp.party_id(+)            = party.party_id   -- bug 4231894
           AND rownum                    = 1;

--Added for Bug 9583024
l_contact_name            HZ_PARTIES.PARTY_NAME%TYPE;
l_contact_hz_id           HZ_PARTIES.PARTY_ID%TYPE;
l_contact_number          HZ_PARTIES.PARTY_NUMBER%TYPE;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

     IF l_debug_level  > 0 THEN
        oe_debug_pub.add('Inside get address , source_type_code is '||p_source_type||' ,p_source_id='||p_source_id||' ,p_contact_id='||p_contact_id,4); -- bug 4231894
     END IF;

     IF (p_source_type IN ('INTERMED_SHIP_TO','SHIP_TO',
                                     'BILL_TO','DELIVER_TO', 'END_CUSTOMER')) THEN --Bug 9583024
         IF p_source_type = 'INTERMED_SHIP_TO' THEN
            l_source_type := 'SHIP_TO';
         ELSE
            l_source_type := p_source_type;
         END IF;

	FOR c_address IN C_GET_ADDRESS(p_source_id,l_source_type)
	LOOP
	  x_party_name 	:= c_address.party_name;
          x_alternate_name := c_address.alternate_name; -- bug 4231894
	  x_address1 	:= c_address.address1;
	  x_address2    := c_address.address2;
	  x_address3    := c_address.address3;
	  x_address4    := c_address.address4;
	  x_city    	:= c_address.city;
          -- Bug 5009103, The state would be passed
          IF G_Dp_Service_Flag <> 'Y' THEN
            x_state     := c_address.state;
          END IF; -- 5009103 ends
	  x_postal_code := c_address.postal_code;
	  x_country 	:= c_address.country;

	  -- Bug 9583024 : START
	  IF p_contact_id IS NOT NULL THEN --bug5140692
            IF l_debug_level  > 0 THEN
               oe_debug_pub.add('Before calling Get_Contact_name...' ) ;
            END IF;

            Get_Contact_name(p_contact_id, l_contact_name , l_contact_hz_id, l_contact_number);

            IF l_debug_level  > 0 THEN
              OE_DEBUG_PUB.Add('After calling Get_Contact_name ...');
            END IF;

            x_contact_person := l_contact_name;
            x_contact_hz_party_id :=  l_contact_hz_id;
            x_contact_hz_party_number := l_contact_number;
          END IF;

	  x_hz_party_id         :=  c_address.hz_party_id;
          x_hz_party_number     :=  c_address.hz_party_number;
          x_party_site_number   :=  c_address.party_site_number;
	  -- Bug 9583024 : END
        END LOOP;
     END IF;

     IF (p_source_type ='SHIP_FROM') THEN
        FOR c_sf_address in C_SHIP_FROM_ADDRESS_SF(p_source_id)
        LOOP
	   x_party_name := c_sf_address.party_name;
           x_alternate_name := NULL; -- bug 4231894
	   x_address1 	:= c_sf_address.address1;
	   x_address2   := c_sf_address.address2;
	   x_address3   := c_sf_address.address3;
	   x_address4   := NULL;
	   x_city    	:= c_sf_address.city;
           IF G_Dp_Service_Flag <> 'Y' THEN --bug 5009103
             x_state    := c_sf_address.state;
           END IF;
	   x_postal_code:= c_sf_address.postal_code;
	   x_country 	:= c_sf_address.country;
        END LOOP;
     END IF;

     IF (p_source_type ='SOLD_TO') THEN
        -- begin : 9130718
        IF (p_org_id_passed = 'Y') THEN
	/*
	   (Only)If there is no customer location entered on the order
	   header, we will pick any site irrespective of usage type.
	*/
	    FOR c_sold in C_SOLD_TO_ADDRESS(p_source_id)
	    LOOP
	        x_party_name := c_sold.party_name;
	        x_alternate_name := c_sold.alternate_name; -- bug 4231894
	        x_address1   := c_sold.address1;
	        x_address2   := c_sold.address2;
	        x_address3   := c_sold.address3;
	        x_address4   := c_sold.address4;
	        x_city       := c_sold.city;
	        IF G_Dp_Service_Flag <> 'Y' THEN --bug 5009103
	           x_state    := c_sold.state;
	        END IF;
	        x_postal_code:= c_sold.postal_code;
	        x_country    := c_sold.country;

	       IF p_contact_id IS NOT NULL THEN --bug5140692

                 -- Bug 9583024 : START
		 IF l_debug_level  > 0 THEN
                   oe_debug_pub.add('Before calling Get_Contact_name...' ) ;
                 END IF;

                 Get_Contact_name(p_contact_id, l_contact_name , l_contact_hz_id, l_contact_number);

                 IF l_debug_level  > 0 THEN
                   OE_DEBUG_PUB.Add('After calling Get_Contact_name ...');
                 END IF;

                 x_contact_person := l_contact_name;
                 x_contact_hz_party_id :=  l_contact_hz_id;
                 x_contact_hz_party_number := l_contact_number;
               END IF;

	       x_hz_party_id         :=  c_sold.hz_party_id   ;
               x_hz_party_number     :=  c_sold.hz_party_number  ;
               x_party_site_number   :=  c_sold.party_site_number ;
	       -- Bug 9583024 : END
	     END LOOP;
	ELSE
	-- end : 9130718
	     FOR c_sold in C_GET_ADDRESS(p_source_id,p_source_type) -- bug 7261101
             LOOP
	         x_party_name := c_sold.party_name;
                 x_alternate_name := c_sold.alternate_name; -- bug 4231894
	         x_address1 	:= c_sold.address1;
      	         x_address2   := c_sold.address2;
	         x_address3   := c_sold.address3;
	         x_address4   := c_sold.address4;
	         x_city    	:= c_sold.city;
                 IF G_Dp_Service_Flag <> 'Y' THEN --bug 5009103
                    x_state    := c_sold.state;
                 END IF;
    	         x_postal_code:= c_sold.postal_code;
	         x_country 	:= c_sold.country;
                 IF p_contact_id IS NOT NULL THEN --bug5140692

                    -- Bug 9583024 : START
		    IF l_debug_level  > 0 THEN
                      oe_debug_pub.add('Before calling Get_Contact_name...' ) ;
                    END IF;

                    Get_Contact_name(p_contact_id, l_contact_name , l_contact_hz_id, l_contact_number);

                    IF l_debug_level  > 0 THEN
                     OE_DEBUG_PUB.Add('After calling Get_Contact_name ...');
                    END IF;
                    x_contact_person := l_contact_name;

		    x_contact_hz_party_id :=  l_contact_hz_id;
                    x_contact_hz_party_number := l_contact_number;
                 END IF;

	       x_hz_party_id         :=  c_sold.hz_party_id   ;
               x_hz_party_number     :=  c_sold.hz_party_number ;
               x_party_site_number   :=  c_sold.party_site_number ;
	       -- Bug 9583024 : END
             END LOOP;
	 END IF;
     END IF;

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add('Exiting get_address',4);
     END IF;
EXCEPTION
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	    FND_MSG_PUB.Add_Exc_Msg
                                 (G_PKG_NAME,
                                  l_api_name
                             	 );
         END IF;

END Get_Address;


/*-----------------------------------------------------+
 | Name        :   Update_Process_Flag                 |
 | Parameters  :   IN  p_line_id                       |
 |                                                     |
 | Description :   This Procedure checks whether any   |
 |                 requests exists for the line id     |
 |                 with process flag not equal to 4    |
 |                 and calls Update_Process_Flag.      |
 +-----------------------------------------------------*/

PROCEDURE Update_Process_Flag(
                        p_line_id     IN  NUMBER
                         )  IS

l_request_control_id_list WSH_ITM_UTIL.CONTROL_ID_LIST;
x_return_status VARCHAR2(30);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add('Entering update process flag..' , 4 ) ;
     END IF;

     SELECT request_control_id
     BULK COLLECT
     INTO   l_request_control_id_list
     FROM   WSH_ITM_REQUEST_CONTROL
     WHERE  application_id = 660
        AND original_system_line_reference = p_line_id
        AND Process_flag <> 4;

     IF l_request_control_id_list.count > 0 THEN

        WSH_ITM_UTIL.Update_process_Flag(
                     l_request_control_id_list,
                     4,
                     x_return_status);
     END IF;


     IF l_debug_level  > 0 THEN
         oe_debug_pub.add('Update process flag returned with ..'|| x_return_status ,1);
         oe_debug_pub.add('Exiting update process flag..',4 ) ;
     END IF;

Exception
     WHEN NO_DATA_FOUND THEN
        NULL;
END Update_Process_Flag;


/*-----------------------------------------------------+
 | Name        :   Init_Address_Table                  |
 | Parameters  :                                       |
 |                                                     |
 | Description :   This Procedure initializes Address  |
 |                 table                               |
 +-----------------------------------------------------*/

PROCEDURE Init_Address_Table
IS
I          INTEGER;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

      FOR I in 1..Address_Table.COUNT
      LOOP

          Address_Table(I).add_source_type          := NULL;
          Address_Table(I).add_source_orgid         := NULL;
          Address_Table(I).add_contact_id           := NULL;
          Address_Table(I).add_party_name           := NULL;
          Address_Table(I).add_alternate_name       := NULL; -- bug 4231894
	  Address_Table(I).add_party_address1       := NULL; -- bug 7485980
	  Address_Table(I).add_party_address2       := NULL; -- bug 7485980
	  Address_Table(I).add_party_address3       := NULL; -- bug 7485980
	  Address_Table(I).add_party_address4       := NULL; -- bug 7485980
          Address_Table(I).add_party_city           := NULL;
          Address_Table(I).add_party_state          := NULL;
          Address_Table(I).add_party_country        := NULL;
          Address_Table(I).add_party_postal_code    := NULL;
          Address_Table(I).add_party_phone          := NULL;
          Address_Table(I).add_party_email          := NULL;
          Address_Table(I).add_party_fax            := NULL;
          Address_Table(I).add_party_url            := NULL;
          Address_Table(I).add_party_contact_name   := NULL;
          --Added for Bug 9583024
          Address_Table(I).add_HZ_PARTY_ID          := NULL;
          Address_Table(I).add_HZ_PARTY_NUMBER      := NULL;
          Address_Table(I).add_PARTY_SITE_NUMBER    := NULL;
          Address_Table(I).add_contact_hz_party_id  := NULL;
          Address_Table(I).add_contact_hz_party_number  := NULL;
     END LOOP;
END;


/*-----------------------------------------------------+
 | Name        :   Create_Request                      |
 | Parameters  :   IN  p_master_organization_id        |
 |                     p_line_rec                      |
 |                 OUT NOCOPY x_return_status          |
 |                                                     |
 | Description :   This Procedure inserts records into |
 |                 Request interface tables            |
 |                                                     |
 +-----------------------------------------------------*/



PROCEDURE Create_Request
(     p_master_organization_id IN  NUMBER
,     p_line_rec               IN  OE_ORDER_PUB.line_rec_type
,     x_return_status          OUT NOCOPY VARCHAR2
)
IS
l_api_name                    CONSTANT VARCHAR2(30)  :=  'Create_Request';
l_request_control_id          NUMBER;
l_request_set_id              NUMBER;
l_party_id                    NUMBER;
x_party_name                  VARCHAR2(2000);
x_alternate_name              VARCHAR2(320); -- bug 4231894
x_party_address1              VARCHAR2(2000); -- bug 7485980
x_party_address2              VARCHAR2(2000); -- bug 7485980
x_party_address3              VARCHAR2(2000); -- bug 7485980
x_party_address4              VARCHAR2(2000); -- bug 7485980
x_party_city                  VARCHAR2(60);
x_party_state                 VARCHAR2(60);
x_party_country               VARCHAR2(60);
x_postal_code                 VARCHAR2(60);
x_phone                       VARCHAR2(80);
x_email                       VARCHAR2(2000);
x_url                         VARCHAR2(2000);
x_fax                         VARCHAR2(80);
l_service_types               VARCHAR2(50);
l_addl_country_name           VARCHAR2(5);
x_contact_name                VARCHAR2(360);
x_service_tbl                 WSH_ITM_UTIL.SERVICE_TBL_TYPE;
x_supports_combination_flag   VARCHAR2(1);
l_Generic_Service_Flag        VARCHAR2(1);
I                             INTEGER;
J                             INTEGER;
l_rec_count                   INTEGER;
l_return_status               VARCHAR2(30);
l_order_number                NUMBER;
l_order_type                  VARCHAR2(30);
l_cust_po_number              VARCHAR2(50);
l_transactional_curr_code     VARCHAR2(15);
l_conversion_type_code        VARCHAR2(30);
l_conversion_rate             NUMBER;
l_ordered_date                DATE;
l_organization_code           VARCHAR2(3);

-- Bug 9583024 : Cursor to Check for GTM Flows
CURSOR cur_check_gtm_flows IS
 SELECT  decode (wits.value, 'FALSE', 'N', null, 'N', 'TRUE', 'Y', 'N')
 FROM wsh_itm_parameter_setups_b wits
 WHERE wits.PARAMETER_NAME = 'WSH_ITM_INTG_GTM';

-- 4380792 Commented the below unused type code variable
-- and added term name variable
--l_payment_type_code           VARCHAR2(30);
l_payment_term_name           VARCHAR2(15);
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_sold_to_contact_id            NUMBER; -- BUG 5140692

l_product_code			VARCHAR2(100); -- BUG 5408161
l_Item_type			VARCHAR2(80);  -- BUG 5408161
l_order_line_number             VARCHAR2(100); --Bug 5647666
l_sold_to_site_use_id           NUMBER;  --Bug 7261101
l_org_id_passed                 VARCHAR2(1) := 'N'; -- Bug 9130718
-- Added for Bug 9583024
x_hz_party_id                   HZ_PARTIES.PARTY_ID%TYPE;
x_hz_party_number               HZ_PARTIES.PARTY_NUMBER%TYPE;
x_party_site_number             HZ_PARTY_SITES.PARTY_SITE_NUMBER%TYPE;
x_contact_hz_party_id           HZ_PARTIES.PARTY_ID%TYPE;
x_contact_hz_party_number       HZ_PARTIES.PARTY_NUMBER%TYPE;
l_itm_intg_gtm                  VARCHAR2(1) := 'N';

BEGIN

l_Generic_Service_Flag        := 'N';
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add('Start creating request...' ) ;
    END IF;


    -- Update Process Flag for requests with Errors

       Update_Process_Flag(p_line_rec.line_id);

    x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- Check for Ship From Org Id and Ship To Org Id
    -- Ship From/To Org_id is Mandatory for processing.

        IF p_line_rec.ship_from_org_id IS NULL  OR
            p_line_rec.ship_to_org_id IS NULL
         THEN

           IF l_debug_level  > 0 THEN
               oe_debug_pub.add('Ship from and ship to orgid are mandatory' , 1 ) ;
           END IF;

            FND_MESSAGE.SET_NAME('ONT','OE_ECS_MISSING_SRC_DEST');

              IF p_line_rec.ship_from_org_id IS NULL THEN
                  FND_MESSAGE.SET_TOKEN('SRC_DEST',
                  OE_ORDER_UTIL.Get_Attribute_Name('SHIP_FROM_ORG_ID'));
	      END IF;

              IF p_line_rec.ship_to_org_id IS NULL THEN
                   FND_MESSAGE.SET_TOKEN('SRC_DEST',
                   OE_ORDER_UTIL.Get_Attribute_Name('SHIP_TO_ORG_ID'));
              END IF;

            OE_MSG_PUB.Add;
	    x_return_status := FND_API.G_RET_STS_ERROR;
           RETURN;
        END IF;

      -- Check whether Additional Country Check is needed
      -- Get the Service type Code
      -- Moved this call before building the address table for bug 5009103
       IF l_debug_level  > 0 THEN
           oe_debug_pub.add('Before calling get service details...' ) ;
       END IF;

       WSH_ITM_UTIL.Get_Service_Details(660,
                                        p_master_organization_id,
                                        p_line_rec.ship_from_org_id,
                                        x_service_tbl,
                                        x_supports_combination_flag,
                                        l_return_status);

       IF l_debug_level  > 0 THEN
          OE_DEBUG_PUB.Add('Get service details returned with ...'|| l_return_status);
       END IF;

      -- Check for Denied Party Service

       FOR l_serv IN 1..x_service_tbl.COUNT
       LOOP
         IF x_service_tbl(l_serv).Service_Type_Code  = 'OM_EXPORT_COMPLIANCE' AND
            OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN
           l_Generic_Service_flag   := 'Y';
           l_service_types     := x_service_tbl(l_serv).Service_Type_Code;

           -- Generic Screening only if it is setup.
           EXIT;
         END IF;

         IF x_service_tbl(l_serv).Service_Type_Code  = 'DP' THEN
           l_addl_country_name := x_service_tbl(l_serv).Addl_Country_Code;
           l_service_types     := x_service_tbl(l_serv).Service_Type_Code;
           G_Dp_Service_flag   := 'Y';
         END IF;
       END LOOP;
       -- Return if service is not available.
       IF G_Dp_service_flag =  'N' AND l_Generic_Service_Flag =  'N'THEN
         IF l_debug_level  > 0 THEN
             oe_debug_pub.add('No Service is Available...');
         END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
       END IF;

       -- Initialize the Address Table
       Init_Address_Table();

       -- gtm flow check Bug 9583024
       OPEN cur_check_gtm_flows;
        FETCH cur_check_gtm_flows into l_itm_intg_gtm;
       CLOSE cur_check_gtm_flows;

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add('GTM Integration enabled ' || l_itm_intg_gtm);
           oe_debug_pub.add('end_customer_id  '||to_char(p_line_rec.end_customer_id));
           oe_debug_pub.add('end_customer_site_use_id  '||to_char(p_line_rec.end_customer_site_use_id));
           oe_debug_pub.add('end_customer_contact_id  '||to_char(p_line_rec.end_customer_contact_id));
       END IF;

       -- Fill Address table with Source types
       Address_table(1).add_source_type  :=  'SHIP_FROM';
       Address_table(2).add_source_type  :=  'SHIP_TO';
       Address_table(3).add_source_type  :=  'DELIVER_TO';
       Address_table(4).add_source_type  :=  'BILL_TO';
       Address_table(5).add_source_type  :=  'SOLD_TO';
       Address_table(6).add_source_type  :=  'INTERMED_SHIP_TO';
      -- Bug 9583024
       IF (l_itm_intg_gtm = 'Y' ) then
         Address_table(7).add_source_type  :=  'END_CUSTOMER';
       END IF;

       -- Fill Address table with Source Org Ids

       -- Bug 7261101
       BEGIN
         SELECT sold_to_site_use_id
         INTO l_sold_to_site_use_id
         FROM oe_order_headers_all
         WHERE header_id = p_line_rec.header_id;

	 IF l_sold_to_site_use_id IS NULL THEN
            l_sold_to_site_use_id := p_line_rec.sold_to_org_id; -- Bug 9130718
       	    l_org_id_passed := 'Y'; -- Bug 9130718
	 END IF;
       EXCEPTION
         WHEN OTHERS THEN
            l_sold_to_site_use_id := NULL;
       END;
       --Bug 7261101

       Address_table(1).add_source_orgid :=  p_line_rec.ship_from_org_id;
       Address_table(2).add_source_orgid :=  p_line_rec.ship_to_org_id;
       Address_table(3).add_source_orgid :=  p_line_rec.deliver_to_org_id;
       Address_table(4).add_source_orgid :=  p_line_rec.invoice_to_org_id;
       Address_table(5).add_source_orgid :=  l_sold_to_site_use_id; -- Bug 7261101
       Address_table(6).add_source_orgid :=  p_line_rec.intermed_ship_to_org_id;
      -- Bug 9583024
       IF (l_itm_intg_gtm = 'Y' ) then
          Address_table(7).add_source_orgid :=  p_line_rec.end_customer_site_use_id;
       END IF;



       BEGIN --bug 5140692
         SELECT sold_to_contact_id
         INTO l_sold_to_contact_id
         FROM oe_order_headers_all
         WHERE header_id = p_line_rec.header_id;
       EXCEPTION
         WHEN OTHERS THEN
         l_sold_to_contact_id := NULL;
       END;

       -- Fill Address table with Contact Org Ids
       Address_table(1).add_contact_id := NULL;
       Address_table(2).add_contact_id := p_line_rec.ship_to_contact_id;
       Address_table(3).add_contact_id := p_line_rec.deliver_to_contact_id;
       Address_table(4).add_contact_id := p_line_rec.invoice_to_contact_id;
       Address_table(5).add_contact_id := l_sold_to_contact_id; --bug 5140692
       Address_table(6).add_contact_id := p_line_rec.intermed_ship_to_contact_id;
      -- Bug 9583024
       IF (l_itm_intg_gtm = 'Y' ) then
         Address_table(7).add_contact_id := p_line_rec.end_customer_contact_id;
       END IF;


       -- Get Address details for Source types

         FOR I in 1..Address_table.COUNT
	 -- Modified the call to procedure as signature has been changed Bug 7485980
         LOOP

                Get_Address(
                           Address_table(I).add_source_orgid,
                           Address_table(I).add_source_type,
                           Address_table(I).add_contact_id,
			   l_org_id_passed, --Bug 9130718
			   x_party_name,
                           x_alternate_name, -- bug 4231894
                           x_party_address1, -- bug 7485980
			   x_party_address2, -- bug 7485980
			   x_party_address3, -- bug 7485980
			   x_party_address4, -- bug 7485980
			   x_party_city,
                           x_party_state,
		           x_party_country,
                           x_postal_code,
		           x_phone,
                           x_email,
                           x_fax,
                           x_url,
		 	   x_contact_name,
                           x_hz_party_id        ,   -- Bug 9583024
                           x_hz_party_number    ,   -- Bug 9583024
                           x_party_site_number  ,   -- Bug 9583024
                           x_contact_hz_party_id ,  -- Bug 9583024
                           x_contact_hz_party_number , -- Bug 9583024
		           x_return_status);

           -- Fill Address table with details

           Address_table(I).add_party_name          :=  x_party_name;
           Address_table(I).add_alternate_name      :=  x_alternate_name; --bug 4231894
           Address_table(I).add_party_address1      :=  x_party_address1; --bug 7485980
	   Address_table(I).add_party_address2      :=  x_party_address2; --bug 7485980
	   Address_table(I).add_party_address3      :=  x_party_address3; --bug 7485980
	   Address_table(I).add_party_address4      :=  x_party_address4; --bug 7485980
           Address_table(I).add_party_city          :=  x_party_city;
           Address_table(I).add_party_state         :=  x_party_state;
           Address_table(I).add_party_country       :=  x_party_country;
           Address_table(I).add_party_postal_code   :=  x_postal_code;
           Address_table(I).add_party_phone         :=  x_phone;
           Address_table(I).add_party_email         :=  x_email;
           Address_table(I).add_party_fax           :=  x_fax;
           Address_table(I).add_party_url           :=  x_url;
           Address_table(I).add_party_contact_name  :=  x_contact_name;
           -- Bug 9583024
           Address_Table(I).add_hz_party_id             := x_hz_party_id ;
           Address_Table(I).add_hz_party_number         := x_hz_party_number ;
           Address_Table(I).add_party_site_number       := x_party_site_number  ;
           Address_Table(I).add_contact_hz_party_id     := x_contact_hz_party_id  ;
           Address_Table(I).add_contact_hz_party_number := x_contact_hz_party_number  ;


           IF l_debug_level  > 0 THEN
              OE_DEBUG_PUB.Add(Address_table(i).add_source_type ||'_country code:'||x_party_country,3);
              OE_DEBUG_PUB.Add(Address_table(i).add_source_type ||' party:'||x_party_name,3);
              OE_DEBUG_PUB.Add(Address_table(i).add_source_type ||' state:'||x_party_state,3);-- bug 5009103
           END IF;
      END LOOP;   -- Loop for getting Address details

      -- Check For Ship From and Ship To Party names
      -- Both should not be NULL.

         IF Address_table(1).add_party_name  IS NULL OR
            Address_table(2).add_party_name  IS NULL
          THEN

              FND_MESSAGE.SET_NAME('ONT','OE_ECS_INVALID_PARTY_ADDR');

	         IF Address_table(1).add_party_name  IS NULL THEN
	            FND_MESSAGE.SET_TOKEN('PARTY',
                        OE_ORDER_UTIL.Get_Attribute_Name('SHIP_FROM_ORG_ID'));
	         END IF;

	         IF Address_table(2).add_party_name  IS NULL THEN
                    FND_MESSAGE.SET_TOKEN('PARTY',
                        OE_ORDER_UTIL.Get_Attribute_Name('SHIP_TO_ORG_ID'));
	         END IF;

            OE_MSG_PUB.Add;

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add('Ship from and customer party name are mandatory' , 1 ) ;
        END IF;

	    x_return_status := FND_API.G_RET_STS_ERROR;
            RETURN;
	  END IF;

       -- Inserting Records in to wsh_itm_request_control

       -- If parent Country Check is needed we will insert one more record for
       -- additional country check with country name


          IF l_Addl_Country_Name IS NOT NULL THEN
              l_rec_count  := 2;
                 SELECT wsh_itm_request_set_s.NEXTVAL
                 INTO   l_request_set_id
                 FROM   dual;
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add('Addl country name:'||l_addl_country_name);
              END IF;
          ELSE
              l_rec_count := 1;
          END IF;



     FOR I in 1..l_rec_count LOOP

       SELECT wsh_itm_request_control_s.NEXTVAL
       INTO   l_request_control_id
       FROM   dual;


       -- Retrieve the Header Information

       -- 4380792 Modified the below  SQL to fetch
       -- Payment Terms Name instead of payment type code.
       /*
       SELECT order_number,order_type,cust_po_number,
              transactional_curr_code,conversion_type_code,
              conversion_rate,ordered_date, terms
       INTO   l_order_number,l_order_type,l_cust_po_number,
              l_transactional_curr_code,l_conversion_type_code,
              l_conversion_rate,l_ordered_date,l_payment_term_name
       FROM   oe_order_headers_v
       WHERE  header_id = p_line_rec.header_id; */

       -- Fixed for SQLperf, SQL Repository ID 14882287
       SELECT h.order_number, ot.name, h.cust_po_number, h.transactional_curr_code,
              h.conversion_type_code, h.conversion_rate, h.ordered_date, term.name
       INTO l_order_number, l_order_type, l_cust_po_number, l_transactional_curr_code,
            l_conversion_type_code, l_conversion_rate, l_ordered_date, l_payment_term_name
       FROM oe_order_headers h, oe_transaction_types_tl ot, ra_terms_tl term
       WHERE  h.header_id = p_line_rec.header_id
          AND h.order_type_id = ot.transaction_type_id
          AND ot.language = userenv('LANG')
          AND h.payment_term_id = term.term_id(+)
          AND term.Language(+) = userenv('LANG');

       -- Retrieve Organization Code

       SELECT organization_code
       INTO   l_organization_code
       FROM   mtl_parameters
       WHERE  organization_id = p_line_rec.ship_from_org_id;

       --Bug 5647666
       -- Get concatenated order_line_number
       -- LINE_NUMBER.SHIPMENT_NUMBER.OPTION_NUMBER.COMPONENT_NUMBER.SERVICE_NUMBER

       l_order_line_number := OE_ORDER_MISC_PUB.GET_CONCAT_LINE_NUMBER(p_line_rec.line_id);

       -- If Parent country check is needed we will change the SHIP FROM
       -- Country name to parent country
       -- Source Org_id is entered as -1

         IF  I = 2 THEN
                Address_table(1).add_source_orgid        := -1;
                Address_table(1).add_party_address1      := NULL; --bug 7485980
		Address_table(1).add_party_address2      := NULL; --bug 7485980
		Address_table(1).add_party_address3      := NULL; --bug 7485980
		Address_table(1).add_party_address4      := NULL; --bug 7485980
                Address_table(1).add_party_city          := NULL;
                Address_table(1).add_party_state         := NULL;
                Address_table(1).add_party_country       := l_addl_country_name;
                Address_table(1).add_party_postal_code   := NULL;
                Address_table(1).add_party_contact_name  := NULL;
                Address_table(1).add_party_phone         := NULL;
                Address_table(1).add_party_email         := NULL;
                Address_table(1).add_party_fax           := NULL;
                Address_table(1).add_party_url           := NULL;
                -- Bug 9583024
                Address_Table(1).add_HZ_PARTY_ID             := NULL;
                Address_Table(1).add_HZ_PARTY_NUMBER         := NULL;
                Address_Table(1).add_PARTY_SITE_NUMBER       := NULL;
                Address_Table(1).add_contact_hz_party_id     := NULL;
                Address_Table(1).add_contact_hz_party_number := NULL;
        END IF;

        INSERT INTO WSH_ITM_REQUEST_CONTROL (
                                        REQUEST_CONTROL_ID,
                                        REQUEST_SET_ID,
                                        APPLICATION_ID,
					MASTER_ORGANIZATION_ID,
					ORGANIZATION_CODE,
					APPLICATION_USER_ID,
					SERVICE_TYPE_CODE,
					TRANSACTION_DATE,
                                        SHIP_FROM_COUNTRY_CODE,
                                        SHIP_TO_COUNTRY_CODE,
					ORIGINAL_SYSTEM_REFERENCE,
					ORIGINAL_SYSTEM_LINE_REFERENCE,
					PROCESS_FLAG,
					RESPONSE_HEADER_ID,
					DEBUG_FLAG,
					ONLINE_FLAG,
					ATTRIBUTE1_NAME,
		                        ATTRIBUTE2_NAME,
					ATTRIBUTE3_NAME,
					ATTRIBUTE4_NAME,
					ATTRIBUTE5_NAME,
					ATTRIBUTE6_NAME,
					ATTRIBUTE7_NAME,
					ATTRIBUTE8_NAME,
					ATTRIBUTE9_NAME,
					ATTRIBUTE10_NAME,
					ATTRIBUTE11_NAME,
					ATTRIBUTE12_NAME,
					ATTRIBUTE13_NAME,
					ATTRIBUTE14_NAME,
					ATTRIBUTE15_NAME,
					ATTRIBUTE1_VALUE,
		                        ATTRIBUTE2_VALUE,
					ATTRIBUTE3_VALUE,
					ATTRIBUTE4_VALUE,
					ATTRIBUTE5_VALUE,
					ATTRIBUTE6_VALUE,
					ATTRIBUTE7_VALUE,
					ATTRIBUTE8_VALUE,
					ATTRIBUTE9_VALUE,
					ATTRIBUTE10_VALUE,
					ATTRIBUTE11_VALUE,
					ATTRIBUTE12_VALUE,
					ATTRIBUTE13_VALUE,
					ATTRIBUTE14_VALUE,
					ATTRIBUTE15_VALUE,
                                        ORDER_NUMBER,
                                        ORDER_TYPE,
                                        OPERATING_UNIT,
                                        CUST_PO_NUM ,
                                        TRANSACTIONAL_CURR_CODE ,
                                        CONVERSION_TYPE_CODE,
                                        CONVERSION_RATE,
                                        ORDERED_DATE,
                                        SHIPPING_METHOD_CODE ,
                                        REQUEST_DATE,
                                        FREIGHT_TERMS_CODE,
                                        PAYMENT_NAME,
                                        PAYMENT_TERM_ID,
                                        ORDERED_QUANTITY,
                                        ORDERED_QUANTITY_UOM, --bug 3640122
                                        LINE_NUMBER,
                                        ORDER_LINE_NUMBER,  --Bug 5647666
                                        UNIT_LIST_PRICE,
                                        UNIT_SELLING_PRICE,
                                        TRIGGERING_POINT,
					CREATION_DATE,
					CREATED_BY,
					LAST_UPDATED_BY,
					LAST_UPDATE_DATE,
					LAST_UPDATE_LOGIN,
                                        ORGANIZATION_ID, --Added for bug 6639636
                                        TOP_MODEL_LINE_ID, -- Added for ER 6490366
					ATO_LINE_ID, -- Bug 9670588
					LINK_TO_LINE_ID, -- Bug 9670588
					SPLIT_FROM_LINE_ID -- Bug 9670588
					)
				VALUES (
					l_request_control_id,
                                        l_request_set_id,
					660,
					p_master_organization_id,
					l_organization_code,
					FND_GLOBAL.USER_ID,
					l_service_types,
					sysdate,
                                        Address_table(1).add_party_country,
                                        Address_table(2).add_party_country,
					p_line_rec.header_id,
					p_line_rec.line_id,
					0,
					null,
					null,
					null,
					null,
					null,
					null,
					null,
					null,
					null,
					null,
					null,
					null,
					null,
					null,
					null,
					null,
					null,
					null,
					null,
					null,
					null,
					null,
					null,
					null,
					null,
					null,
					null,
					null,
					null,
					null,
					null,
					null,
					null,
                                        l_order_number,
                                        l_order_type,
                                        p_line_rec.org_id,
                                        l_cust_po_number,
                                        l_transactional_curr_code,
                                        l_conversion_type_code,
                                        l_conversion_rate,
                                        l_ordered_date,
                                        p_line_rec.shipping_method_code,
                                        p_line_rec.request_date,
                                        p_line_rec.freight_terms_code,
                                        l_payment_term_name,
                                        p_line_rec.payment_term_id,
                                        p_line_rec.ordered_quantity,
                                        p_line_rec.order_quantity_uom,--bug 3640122
                                        p_line_rec.line_number,
                                        l_order_line_number,  --Bug 5647666
                                        p_line_rec.unit_list_price,
                                        p_line_rec.unit_selling_price,
                                        'ORDER_SCHEDULING',
					sysdate,
					FND_GLOBAL.USER_ID,
					FND_GLOBAL.USER_ID,
					sysdate,
					FND_GLOBAL.USER_ID,
                                        p_line_rec.ship_from_org_id, --Added for bug 6639636
                                        p_line_rec.top_model_line_id, -- Added for bug 6490366
					p_line_rec.ato_line_id, --bug 9670588
					p_line_rec.link_to_line_id , -- Bug 9670588
					p_line_rec.split_from_line_id -- Bug 9670588
                                      );



       IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN

          IF l_debug_level  > 0 THEN
             oe_debug_pub.add('Inserted record in to wsh_itm_request_control...' , 1 ) ;
             oe_debug_pub.add('WSH_ITM_ITEMS INVENTORY_ITEM_ID :'||p_line_rec.inventory_item_id , 1 ) ;
             oe_debug_pub.add('WSH_ITM_ITEMS ORGANIZATION_CODE :'||l_organization_code , 1 ) ;
          END IF;

  	  -- BUG 5408161
	  -- Retrieve concatenated_segments ('ProductCode' in WSH_ITM_ITEMS table)
	  SELECT concatenated_segments into l_product_code
	        FROM  mtl_system_items_vl
		WHERE inventory_item_id = p_line_rec.inventory_item_id
		AND organization_id = p_line_rec.ship_from_org_id; --l_organization_code ;


          -- Bug 5739175
          BEGIN
	  -- Retrieve Item_type
	  Select MEANING INTO l_Item_type
	       FROM MTL_SYSTEM_ITEMS_B items, FND_LOOKUP_VALUES FLV
	       WHERE items.INVENTORY_ITEM_ID = p_line_rec.inventory_item_id
               AND items.ORGANIZATION_ID = p_line_rec.ship_from_org_id --l_organization_code
               AND FLV.LOOKUP_CODE = items.ITEM_TYPE AND  FLV.LOOKUP_TYPE = 'ITEM_TYPE'
               AND FLV.VIEW_APPLICATION_ID = 3
               AND FLV.LANGUAGE =  userenv('LANG')
               AND FLV.ENABLED_FLAG = 'Y' ;

          EXCEPTION
             WHEN OTHERS THEN
               l_Item_type := null;
          END;

          INSERT INTO WSH_ITM_ITEMS (
                                    ITEM_ID,
                                    REQUEST_CONTROL_ID,
                                    INVENTORY_ITEM_ID,
                                    ORGANIZATION_CODE,
                                    OPERATING_UNIT,
    				    PRODUCT_CODE,
				    ITEM_TYPE,
		    	  	    CREATION_DATE,
		  		    CREATED_BY,
				    LAST_UPDATED_BY,
				    LAST_UPDATE_DATE,
				    LAST_UPDATE_LOGIN
                                    )
                             VALUES (
                                    wsh_itm_items_s.NEXTVAL,
                                    l_request_control_id,
                                    p_line_rec.inventory_item_id,
                                    l_organization_code,
                                    p_line_rec.org_id,
                                    l_product_code,
				    l_Item_type,
				    sysdate,
				    FND_GLOBAL.USER_ID,
				    FND_GLOBAL.USER_ID,
				    sysdate,
				    FND_GLOBAL.USER_ID
                                   );

          IF l_debug_level  > 0 THEN
             oe_debug_pub.add('Inserted record in to wsh_itm_items...' , 1 ) ;
          END IF;

       END IF;

       -- Inserting Records in to wsh_itm_parties
       -- Records inserted are equal to number of source types(parties)

       FOR J in 1..Address_table.COUNT LOOP


         IF Address_table(J).add_source_orgid IS NOT NULL THEN

          SELECT wsh_itm_parties_s.NEXTVAL
          INTO   l_party_id
          FROM   dual;

          INSERT INTO WSH_ITM_PARTIES (
                                      PARTY_ID,
                                      REQUEST_CONTROL_ID,
                                      ORIGINAL_SYSTEM_REFERENCE,
 	                              ORIGINAL_SYSTEM_LINE_REFERENCE,
		                      SOURCE_ORG_ID,
		                      PARTY_TYPE,
		                      PARTY_NAME,
                                      ALTERNATE_NAME,  -- BUG 4231894
                                      PARTY_ADDRESS1,
	                              PARTY_ADDRESS2,
                                      PARTY_ADDRESS3,
                                      PARTY_ADDRESS4,
                                      PARTY_ADDRESS5,
                                      PARTY_CITY,
                                      PARTY_STATE,
                                      PARTY_COUNTRY_CODE,
                                      PARTY_COUNTRY_NAME,
                                      POSTAL_CODE,
                                      CONTACT_NAME,
                                      PHONE,
                                      EMAIL,
		                      FAX,
	                              WEB,
				      ATTRIBUTE1_NAME,
		                      ATTRIBUTE2_NAME,
			              ATTRIBUTE3_NAME,
				      ATTRIBUTE4_NAME,
				      ATTRIBUTE5_NAME,
				      ATTRIBUTE6_NAME,
				      ATTRIBUTE7_NAME,
				      ATTRIBUTE8_NAME,
				      ATTRIBUTE9_NAME,
				      ATTRIBUTE10_NAME,
				      ATTRIBUTE11_NAME,
				      ATTRIBUTE12_NAME,
				      ATTRIBUTE13_NAME,
				      ATTRIBUTE14_NAME,
				      ATTRIBUTE15_NAME,
			              ATTRIBUTE1_VALUE,
		                      ATTRIBUTE2_VALUE,
				      ATTRIBUTE3_VALUE,
				      ATTRIBUTE4_VALUE,
				      ATTRIBUTE5_VALUE,
				      ATTRIBUTE6_VALUE,
				      ATTRIBUTE7_VALUE,
				      ATTRIBUTE8_VALUE,
				      ATTRIBUTE9_VALUE,
				      ATTRIBUTE10_VALUE,
				      ATTRIBUTE11_VALUE,
			              ATTRIBUTE12_VALUE,
			              ATTRIBUTE13_VALUE,
				      ATTRIBUTE14_VALUE,
			              ATTRIBUTE15_VALUE,
                                      CREATION_DATE,
                                      CREATED_BY,
                                      LAST_UPDATED_BY,
                                      LAST_UPDATE_DATE,
                                      LAST_UPDATE_LOGIN,
                                      -- Bug 9583024
                                      HZ_PARTY_ID,
                                      HZ_PARTY_NUMBER ,
                                      PARTY_SITE_NUMBER     ,
                                      CONTACT_HZ_PARTY_ID ,
                                      CONTACT_HZ_PARTY_NUMBER
                                      )
                               VALUES (
                                       l_party_id,
                                       l_request_control_id,
                                       p_line_rec.header_id,
                                       p_line_rec.line_id,
                                       Address_table(J).add_source_orgid,
                                       Address_table(J).add_source_type,
                                       Address_table(J).add_party_name,
                                       Address_table(J).add_alternate_name, --bug 4231894
                                       Address_table(J).add_party_address1,
                                       Address_table(J).add_party_address2,
				       Address_table(J).add_party_address3,
                                       Address_table(J).add_party_address4,
                                       null,
                                       Address_table(J).add_party_city,
                                       Address_table(J).add_party_state,
                                       Address_table(J).add_party_country,
                                       Address_table(J).add_party_country,
                                       Address_table(J).add_party_postal_code,
                                       Address_table(J).add_party_contact_name,
                                       Address_table(J).add_party_phone,
                                       Address_table(J).add_party_email,
                                       Address_table(J).add_party_fax,
                                       Address_table(J).add_party_url,
                                       null,
                                       null,
                                       null,
                                       null,
                                       null,
                                       null,
                                       null,
                                       null,
                                       null,
                                       null,
                                       null,
                                       null,
                                       null,
                                       null,
                                       null,
                                       null,
                                       null,
                                       null,
                                       null,
                                       null,
                                       null,
                                       null,
                                       null,
                                       null,
                                       null,
                                       null,
                                       null,
                                       null,
                                       null,
                                       null,
                                       sysdate,
                                       FND_GLOBAL.USER_ID,
                                       FND_GLOBAL.USER_ID,
                                       sysdate,
                                       FND_GLOBAL.USER_ID,
                                       -- Bug 9583024
                                       Address_Table(J).add_hz_party_id  ,
                                       Address_Table(J).add_hz_party_number ,
                                       Address_Table(J).add_party_site_number    ,
                                       Address_Table(J).add_contact_hz_party_id,
                                       Address_Table(J).add_contact_hz_party_number
                                       );

         IF l_debug_level  > 0 THEN
             oe_debug_pub.add(  'INSERTED '||J||' RECORDS IN TO WSH_ITM_PARTIES...' ) ;
         END IF;

        END IF;     -- Check for Org id

      END LOOP;   -- Loop for inserting records in to Itm Parties

    END LOOP;   -- Loop for inserting records in to Request Control


  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'END CREATING REQUEST...' ) ;
  END IF;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
      oe_debug_pub.add(  'END CREATING REQUEST...'||sqlerrm ) ;
       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      oe_debug_pub.add(  'END CREATING REQUEST...'||sqlerrm ) ;
       WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg
	                       (G_PKG_NAME,
	                        l_api_name
	                        );
       END IF;
      oe_debug_pub.add(  'END CREATING REQUEST...'||sqlerrm ) ;

END Create_Request;

/*-----------------------------------------------------+
 | Name        :   WSH_ITM_ONT                         |
 | Parameters  :   IN  p_master_organization_id        |
 |                     p_line_rec                      |
 |                                                     |
 | Description :   This is a Call Back Procedure       |
 |                 called by Generic Adapter           |
 |                                                     |
 +-----------------------------------------------------*/

PROCEDURE WSH_ITM_ONT  (
                        p_request_control_id  IN NUMBER    default null
		       ,p_request_set_id      IN NUMBER    default null
		       ,p_status_code         IN VARCHAR2  default null
                       ) IS

        CURSOR C_Resp_Lines(cp_response_header_id NUMBER) IS
        SELECT wl.Error_Text,wl.denied_party_flag,wp.Party_name
        FROM   wsh_itm_response_lines wl,
               wsh_itm_parties wp
        WHERE      wl.Response_header_id = cp_response_header_id
               AND wp.party_id           = wl.party_id;

        CURSOR C_Get_Responses(cp_request_control_id  NUMBER,
                              cp_request_set_id  NUMBER)
        IS
        SELECT request_control_id,response_header_id,organization_id,
               nvl(original_system_line_reference,0) line_id,
               nvl(original_system_reference,0) header_id --bug 4503620
        FROM   wsh_itm_request_control wrc
        WHERE  request_control_id = nvl(cp_request_control_id,0)
          AND  wrc.application_id        = 660
        UNION
        SELECT request_control_id,response_header_id,organization_id,
               nvl(original_system_line_reference,0) line_id,
               nvl(original_system_reference,0) header_id --bug 4503620
        FROM   wsh_itm_request_control wrc
        WHERE  request_set_id = nvl(cp_request_set_id,0)
          AND  wrc.application_id        = 660;


l_api_name	          CONSTANT  VARCHAR2(30)    := 'Response_API';

l_request_control_id      NUMBER;
l_response_header_id      NUMBER;
l_services                WSH_ITM_RESPONSE_PKG.SrvTabTyp;
l_return_status           VARCHAR2(35);
l_error_text              VARCHAR2(2000);
-- Commented for bug 8762350
/*
l_denied_party_flag       VARCHAR2(1);
l_line_id                 NUMBER;
l_header_id               NUMBER; -- bug 4503620
l_top_model_line_id       NUMBER;
l_line_rec                OE_ORDER_PUB.line_rec_type;
l_services                WSH_ITM_RESPONSE_PKG.SrvTabTyp;
l_hold_source_rec	  OE_Holds_PVT.Hold_Source_REC_type;
l_return_status           VARCHAR2(35);
l_data_error              VARCHAR2(1);
l_system_error            VARCHAR2(1);
l_activity_complete       VARCHAR2(1);
l_hold_applied            VARCHAR2(1);
l_dp_hold_flag            VARCHAR2(1);
l_gen_hold_flag           VARCHAR2(1);
l_interpreted_value       VARCHAR2(30);
p_return_status           VARCHAR2(30);
l_result_out              VARCHAR2(30);
l_msg_count               NUMBER         :=  0;
l_msg_data                VARCHAR2(2000);
l_error_text              VARCHAR2(2000);
l_dummy                   VARCHAR2(10);
l_org_id                  NUMBER;
l_serv                    INTEGER;
l_activity                VARCHAR2(30); -- Bug 7688120*/

l_line_id                 NUMBER;
l_header_id               NUMBER; -- bug 4503620
l_org_id                  NUMBER;
l_activity                VARCHAR2(250);
l_interpreted_value       VARCHAR2(30);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

       OE_DEBUG_PUB.Add('Entering WSH_ITM_ONT...');

       SAVEPOINT RESPONSE_API;

       -- Begin : 8762350
      /* This API will now be used only to notify the workflow that ITM request
         has been completed. The actual updation of line with the screening
	 results will be done by the next activity in the workflow (added via
	 this bug).
	 All the existing code in this API has been moved to :
	 oe_export_compliance_wf.update_screening_result(...)
	 Line will not be progressed from the export_screening_compliance if
	 it is in system error.
      */

       Oe_debug_pub.ADD('Req control ID / Req set ID / Status code : ' ||
                        p_request_control_id || '/' || p_request_set_id ||
			'/' || p_status_code);

       -- Get the line and header ID

       FOR c_responses IN C_Get_Responses(p_request_control_id,p_request_set_id)
       LOOP
          l_line_id := c_responses.line_id;
          l_header_id := c_responses.header_id; --bug 4503620
       END LOOP;

        -- Get the Org Id

       SELECT ORG_ID
       INTO l_org_id
       FROM oe_order_lines_all
       WHERE line_id = l_line_id;

       -- MOAC change DBMS_APPLICATION_INFO.Set_Client_Info(l_org_id);
       mo_global.set_policy_context('S',l_org_id);

       IF p_status_code = 'OVERRIDE' THEN

              IF l_debug_level > 0 THEN
	        oe_debug_pub.add('Overriding export compliance screening.');
	      END IF;

	      -- Bug 7688120
	      SELECT wpa.activity_name -- Bug 10361575
	      INTO l_activity
	      FROM wf_item_activity_statuses wias, wf_process_activities wpa
	      WHERE wias.item_type = 'OEOL'
	      AND wias.item_key = To_Char(l_line_id)
      	      AND wias.process_activity = wpa.instance_id
      	      AND wias.activity_status = 'NOTIFIED';

	      IF l_activity in ('EXPORT_COMPLIANCE_SCREENING', 'EXPORT_COMPLIANCE_ELIGIBLE') THEN -- Bug 10361575
 	         WF_ENGINE.CompleteActivityInternalName(
                                         'OEOL',
                                         to_char(l_line_id),
                                         l_activity,
                                         'OVERRIDE' );
	      ELSE
	        IF l_debug_level > 0 THEN
	         oe_debug_pub.add('No action taken, notified activity is '||l_activity||'.'); -- Bug 10361575
		END IF;
	      END IF;

	      RETURN;

       END IF;

       -- Get the response and check for system errors

       FOR c_responses IN C_Get_Responses(p_request_control_id,p_request_set_id)
       LOOP
	  l_request_control_id := c_responses.request_control_id;
	  l_response_header_id := c_responses.response_header_id;

          WSH_ITM_RESPONSE_PKG.ONT_RESPONSE_ANALYSER (
							p_request_control_id => l_request_control_id,
							x_interpreted_value => l_interpreted_value,
							x_SrvTab => l_services,
							x_return_status => l_return_status
	                                              );

           IF l_debug_level > 0 THEN
		OE_DEBUG_PUB.Add('Response analyser return status :' || l_return_status, 1);
		OE_DEBUG_PUB.Add('Response Interpreted value :' || l_interpreted_value, 1);
           END IF;

	   -- Do not progress the workflow if the line is in system error.

           IF l_interpreted_value = 'SYSTEM' THEN

                --  Check for errors in Response Headers.
		SELECT error_text
		INTO l_error_text
		FROM wsh_itm_response_headers
		WHERE response_header_id = l_response_header_id;

		FND_MESSAGE.SET_NAME('ONT', 'OE_ECS_SYSTEM_ERROR');
		FND_MESSAGE.SET_TOKEN('ERRORTEXT', l_error_text);
		OE_MSG_PUB.Add;

		-- Check for errors in Response lines

		FOR c_error IN c_resp_lines(l_response_header_id)
		    LOOP
		    BEGIN
			l_error_text := c_error.error_text;
			FND_MESSAGE.SET_NAME('ONT', 'OE_ECS_SYSTEM_ERROR');
			FND_MESSAGE.SET_TOKEN('ERRORTEXT', l_error_text);
			OE_MSG_PUB.Add;
		    END;
		END LOOP;

		RETURN;

           END IF; -- system error

       END LOOP;

       WF_ENGINE.CompleteActivityInternalName(
					      'OEOL',
					      to_char(l_line_id),
					      'EXPORT_COMPLIANCE_SCREENING',
					      'COMPLETE' );

       OE_DEBUG_PUB.Add('Leaving WSH_ITM_ONT...');

      /*

      -- This select statement is used to lock the Top Model Line.
      -- After the Top Model Line is Locked we go ahead the Lock the
      -- individual Line.

         SELECT top_model_line_id
         INTO   l_top_model_line_id
         FROM   oe_order_lines
         WHERE  line_id = l_line_id;

         BEGIN --bug 4503620
           IF l_top_model_line_id IS NOT NULL THEN
             SELECT '1'
             INTO  l_dummy
             FROM  oe_order_lines_all
             WHERE line_id= l_top_model_line_id
             FOR UPDATE; --Commented for bug 6415831 --nowait;
           END IF;

             -- Wait until the lock on the row is released and then
             -- lock the row

           SELECT '1'
           INTO  l_dummy
           FROM  oe_order_lines_all
           WHERE line_id= l_line_id
           FOR UPDATE; --Commented for bug 6415831 --nowait;
         EXCEPTION
           WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN
             IF l_debug_level  > 0 THEN
               oe_debug_pub.add('OEXVITMB.pls: unable to lock the line',1);
             END IF;
             IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR) THEN
               OE_MSG_PUB.set_msg_context(
               p_entity_code                => 'LINE'
              ,p_entity_id                  => l_line_id
              ,p_header_id                  => l_header_id
              ,p_line_id                    => l_line_id);

               fnd_message.set_name('ONT', 'OE_LINE_LOCKED');
               OE_MSG_PUB.Add;
               OE_MSG_PUB.Save_API_Messages;
             END IF;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END; --bug 4503620 ends

         OE_LINE_UTIL.Query_Row ( p_line_id         => l_line_id,
                                    x_line_rec      => l_line_rec);


        -- Check whether the Line is cancelled

         IF l_line_rec.cancelled_flag = 'Y' THEN
            IF l_debug_level  > 0 THEN
               oe_debug_pub.add('The line '||to_char(l_line_id)||'is already cancelled.',1);
            END IF;
            RETURN;
         END IF;

         OE_MSG_PUB.set_msg_context(
             p_entity_code                => 'LINE'
            ,p_entity_id                  => l_line_rec.line_id
            ,p_header_id                  => l_line_rec.header_id
            ,p_line_id                    => l_line_rec.line_id
            ,p_order_source_id            => l_line_rec.order_source_id
            ,p_orig_sys_document_ref      => l_line_rec.orig_sys_document_ref
            ,p_orig_sys_document_line_ref => l_line_rec.orig_sys_line_ref
            ,p_orig_sys_shipment_ref      => l_line_rec.orig_sys_shipment_ref
            ,p_change_sequence            => l_line_rec.change_sequence
            ,p_source_document_type_id    => l_line_rec.source_document_type_id
            ,p_source_document_id         => l_line_rec.source_document_id
            ,p_source_document_line_id    => l_line_rec.source_document_line_id
            );


        -- If the user has choosen to override Screening

        IF p_status_code = 'OVERRIDE' THEN

           IF l_debug_level  > 0 THEN
               oe_debug_pub.add('Override screening for line id:'||l_line_id,3);
           END IF;

           -- Update Work flow Status Code

              OE_ORDER_WF_UTIL.Update_Flow_Status_Code (
                     p_line_id              =>   l_line_id,
                     p_flow_status_code     =>   'EXPORT_SCREENING_COMPLETED',
                     x_return_status        =>   l_return_status
                     );


              IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 OE_STANDARD_WF.Save_Messages;
                 OE_STANDARD_WF.Clear_Msg_Context;
                 APP_EXCEPTION.Raise_Exception;
              END IF;

	      -- Bug 7688120
	      SELECT wpa.instance_label INTO l_activity
	      FROM wf_item_activity_statuses wias, wf_process_activities wpa
	      WHERE wias.item_type = 'OEOL'
	      AND wias.item_key = To_Char(l_line_id)
      	      AND wias.process_activity = wpa.instance_id
      	      AND wias.activity_status = 'NOTIFIED';

              WF_ENGINE.CompleteActivityInternalName(
                                         'OEOL',
                                         to_char(l_line_id),
                                         l_activity, -- Bug 7688120
                                         'OVERRIDE' );


	     RETURN;
        END IF;

          -- Calling Response Analyser

    FOR c_responses IN C_Get_Responses(p_request_control_id,p_request_set_id)
    LOOP
    BEGIN

          l_request_control_id := c_responses.request_control_id;
          l_response_header_id := c_responses.response_header_id;

          WSH_ITM_RESPONSE_PKG.ONT_RESPONSE_ANALYSER  (
           	p_request_control_id   => l_request_control_id,
	        x_interpreted_value    => l_interpreted_value,
                x_SrvTab               => l_services,
                x_return_status        => l_return_status
                );



          IF l_debug_level  > 0 THEN
             OE_DEBUG_PUB.Add('Response analyser return status :'|| l_return_status,1);
          END IF;

        -- Check for System or Data errors.

        IF l_interpreted_value =  'SYSTEM' OR l_interpreted_value = 'DATA' THEN

           --  Check for errors in Response Headers.

               SELECT error_text
               INTO   l_error_text
               FROM   wsh_itm_response_headers
               WHERE  response_header_id = l_response_header_id;

           IF l_interpreted_value = 'DATA' THEN
              l_data_error := 'Y';
              FND_MESSAGE.SET_NAME('ONT','OE_ECS_DATA_ERROR');
           ELSE
              l_system_error := 'Y';
              FND_MESSAGE.SET_NAME('ONT','OE_ECS_SYSTEM_ERROR');
           END IF;

           FND_MESSAGE.SET_TOKEN('ERRORTEXT',l_error_text);
           OE_MSG_PUB.Add;


           -- Check for errors in Response lines

	      FOR c_error IN c_resp_lines(l_response_header_id)
	      LOOP
                 BEGIN
	     	     l_error_text  :=   c_error.error_text;

		     IF l_interpreted_value =  'DATA' THEN
		        FND_MESSAGE.SET_NAME('ONT','OE_ECS_DATA_ERROR');
       		     ELSE
			FND_MESSAGE.SET_NAME('ONT','OE_ECS_SYSTEM_ERROR');
          	     END IF;

	             FND_MESSAGE.SET_TOKEN('ERRORTEXT',l_error_text);
                     OE_MSG_PUB.Add;
                END;
              END LOOP;
        END IF;     --Check for System or Data Errors

        -- Get the Parties Denied.

           FOR c_resplines IN c_resp_lines(l_response_header_id)
           LOOP
             BEGIN
               IF c_resplines.denied_party_flag = 'Y' THEN
	         FND_MESSAGE.SET_NAME('ONT','OE_ECS_DENIED_PARTY');
                 FND_MESSAGE.SET_TOKEN('DENIEDPARTY',
                                             c_resplines.party_name);
                 OE_MSG_PUB.Add;
                 IF l_debug_level  > 0 THEN
                    OE_DEBUG_PUB.Add('Party Name:'||c_resplines.party_name||',denied');
                 END IF;
               END IF;
	     END;
	   END LOOP;

           -- Check for Denied Party Service


              FOR l_serv IN 1..l_services.COUNT
              LOOP
                 IF l_debug_level  > 0 THEN
                    OE_DEBUG_PUB.Add('Service Result'||l_services(l_serv).Service_Result,1);
                 END IF;

                 IF l_services(l_serv).Service_Type = 'DP' THEN
                     l_dp_hold_flag :=  l_services(l_serv).Service_Result;
                 END IF;
                 IF l_services(l_serv).Service_Type = 'OM_EXPORT_COMPLIANCE' AND
                               OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510'  THEN
                     l_gen_hold_flag :=  l_services(l_serv).Service_Result;
                 END IF;
              END LOOP;

               l_hold_applied := l_dp_hold_flag;

            IF l_interpreted_value = 'SUCCESS' THEN
	         l_activity_complete := 'Y';
            END IF;
         END;
        END LOOP;

       -- Progress Work Flow to Next Stage

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add('Progress Work Flow to Next Stage...',1);
       END IF;


       -- If one response has system error and other has data error we
       -- consider that line has system error. If both the responses has
       -- data error we consider thata line has data error.

           IF l_system_error = 'Y' THEN
              NULL;

           ELSIF l_data_error='Y' THEN

	      OE_ORDER_WF_UTIL.Update_Flow_Status_Code
                    (p_line_id             =>   l_line_id,
                     p_flow_status_code    =>   'EXPORT_SCREENING_DATA_ERROR',
                     x_return_status       =>   l_return_status
                     );

                 IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    OE_STANDARD_WF.Save_Messages;
                    OE_STANDARD_WF.Clear_Msg_Context;
                    APP_EXCEPTION.Raise_Exception;
                 END IF;

	        WF_ENGINE.CompleteActivityInternalName('OEOL',
                                        to_char(l_line_id),
                                        'EXPORT_COMPLIANCE_SCREENING',
                                        'INCOMPLETE');

            ELSIF l_gen_hold_flag = 'Y' AND
                     OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN

                  OE_DEBUG_PUB.Add('Generic Hold!!!');

                  -- The Hold_Id of the Generic Hold has been
                  -- seeded as 23.


                   l_hold_source_rec.hold_entity_code := 'O';
                   l_hold_source_rec.hold_id          := 23;
                   l_hold_source_rec.hold_entity_id   := l_line_rec.header_id;
                   l_hold_source_rec.line_id          := l_line_rec.line_id;

                OE_HOLDS_PUB.Apply_Holds
                        (   p_api_version        => 1.0
                        ,   p_validation_level   => FND_API.G_VALID_LEVEL_NONE
                        ,   p_hold_source_rec    => l_hold_source_rec
                        ,   x_return_status      => l_return_status
                        ,   x_msg_count          => l_msg_count
                        ,   x_msg_data           => l_msg_data
                        );

                 IF l_return_status = FND_API.G_RET_STS_ERROR THEN
                     RAISE FND_API.G_EXC_ERROR;
                 ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 ELSIF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
                      IF l_debug_level  > 0 THEN
                         oe_debug_pub.add('Applied Generic hold on line:'|| l_line_rec.line_id,1);
                      END IF;
                 END IF;

                OE_Order_WF_Util.Update_Flow_Status_Code
                    (p_line_id             =>   l_line_id,
                     p_flow_status_code    =>   'EXPORT_SCREENING_COMPLETED',
                     x_return_status       =>   l_return_status
                     );

                 IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    OE_STANDARD_WF.Save_Messages;
                    OE_STANDARD_WF.Clear_Msg_Context;
                    APP_EXCEPTION.Raise_Exception;
                 END IF;

                WF_ENGINE.CompleteActivityInternalName('OEOL',
                                        to_char(l_line_id),
                                        'EXPORT_COMPLIANCE_SCREENING',
                                        'HOLD_APPLIED');

            ELSIF l_hold_applied = 'Y' THEN

           -- Check whether Denied party hold needs to be applied

              -- The Hold_Id of the Denied Party Hold has been
              -- seeded as 21.


                   l_hold_source_rec.hold_entity_code := 'O';
                   l_hold_source_rec.hold_id	      := 21;
   	           l_hold_source_rec.hold_entity_id   := l_line_rec.header_id;
	           l_hold_source_rec.line_id	      := l_line_rec.line_id;

	     	OE_HOLDS_PUB.Apply_Holds
			(   p_api_version        => 1.0
			,   p_validation_level   => FND_API.G_VALID_LEVEL_NONE
			,   p_hold_source_rec    => l_hold_source_rec
			,   x_return_status      => l_return_status
			,   x_msg_count          => l_msg_count
			,   x_msg_data           => l_msg_data
			);

		 IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          	     RAISE FND_API.G_EXC_ERROR;
        	 ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          	     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        	 ELSIF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
                      IF l_debug_level  > 0 THEN
                         oe_debug_pub.add('Applied denied party hold on line:'|| l_line_rec.line_id,1);
                      END IF;
                 END IF;

                OE_Order_WF_Util.Update_Flow_Status_Code
                    (p_line_id             =>   l_line_id,
                     p_flow_status_code    =>   'EXPORT_SCREENING_COMPLETED',
                     x_return_status       =>   l_return_status
                     );

                 IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    OE_STANDARD_WF.Save_Messages;
                    OE_STANDARD_WF.Clear_Msg_Context;
                    APP_EXCEPTION.Raise_Exception;
                 END IF;

               WF_ENGINE.CompleteActivityInternalName('OEOL',
					to_char(l_line_id),
                                        'EXPORT_COMPLIANCE_SCREENING',
                                        'HOLD_APPLIED');

            ELSIF l_activity_complete ='Y' THEN

                OE_ORDER_WF_UTIL.Update_Flow_Status_Code
                    (p_line_id            =>  l_line_id,
                     p_flow_status_code   =>  'EXPORT_SCREENING_COMPLETED',
                     x_return_status      =>  l_return_status
                     );

                 IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                    OE_STANDARD_WF.Save_Messages;
                    OE_STANDARD_WF.Clear_Msg_Context;
                    APP_EXCEPTION.Raise_Exception;
                 END IF;

	         WF_ENGINE.CompleteActivityInternalName('OEOL',
                                        to_char(l_line_id),
                                        'EXPORT_COMPLIANCE_SCREENING',
                                        'COMPLETE');

            END IF;


       OE_MSG_PUB.SAVE_MESSAGES(l_line_rec.line_id);

       IF l_debug_level  > 0 THEN
           oe_debug_pub.add('Exiting response api',1);
       END IF; */

       -- End : 8762350

EXCEPTION
        WHEN OTHERS THEN
           ROLLBACK TO RESPONSE_API;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
           FND_MSG_PUB.Add_Exc_Msg
                                (G_PKG_NAME,
                                 l_api_name
                                );
        END IF;

END WSH_ITM_ONT;

END ONT_ITM_PKG;

/
