--------------------------------------------------------
--  DDL for Package Body OE_CREATE_ACCOUNT_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_CREATE_ACCOUNT_INFO" AS
/* $Header: OEXCACTB.pls 120.9 2006/07/21 14:11:32 mbhoumik noship $ */


G_PKG_NAME                CONSTANT VARCHAR2(30) := 'OE_CREATE_ACCOUNT_INFO';
G_CREATED_BY_MODULE       VARCHAR2(150);
G_account_created_or_found VARCHAR2(50) := 'FOUND'; /*cc project */
G_fetch_primary_party_sites boolean :=FALSE;  /*cc project */

--  Start of Comments
--  API name    Crate_Account_Layer
--  Type        Private
--  Function    Automatic creation of Account Layer from Party Layer
--
--  Pre-reqs
--
--  Parameters
--
--  Notes
--
--  End of Comments


PROCEDURE Create_Account_Layer(
 p_control_rec        IN Control_Rec_Type := G_MISS_CONTROL_REC
,x_return_status      OUT NOCOPY VARCHAR2
,x_msg_count          OUT NOCOPY NUMBER
,x_msg_data           OUT NOCOPY VARCHAR2
,p_party_customer_rec IN OUT NOCOPY /* file.sql.39 change */ Party_customer_rec
,p_site_tbl     IN OUT NOCOPY /* file.sql.39 change */  site_tbl_type
,p_account_tbl     OUT  NOCOPY account_tbl
,p_contact_tbl out NOCOPY contact_tbl
) IS

p_allow_account_creation boolean :=FALSE;
p_allow_contact_creation boolean := FALSE;
p_allow_site_creation boolean := FALSE;
l_multiple_account boolean :=FALSE;
l_add_customer varchar2(30);
l_cust_account_role_id number;
l_org_contact_id number  := null;
l_cust_account_id number := null;
l_party_id number  := null;

--list of all related customers
l_related_customer_tab account_tbl;
p2_contact_tbl contact_tbl;
l2_cust_account_id number := null;
l3_cust_account_id number  := null;
l2_party_id number  := null;
l2_org_contact_id number  := null;
l_account_tbl account_tbl;
l2_party_number varchar2(20):=NULL;
matched_cust number :=NULL;
i number;

found_relationship BOOLEAN;

l_status varchar2(10);


CURSOR c_check_account(in_cust_account_id in number) IS
  SELECT status,party_id
    FROM hz_cust_accounts
   WHERE cust_account_id = in_cust_account_id;

CURSOR c_get_cust_account_id(in_cust_account_number in varchar2) IS
  SELECT cust_account_id,party_id,status
    FROM hz_cust_accounts
   WHERE account_number=in_cust_account_number
     AND status='A';

CURSOR c_cust_account_id(in_cust_account_id in number) IS
  SELECT party_id
    FROM hz_cust_accounts
   WHERE cust_account_id=in_cust_account_id
     AND status='A';

CURSOR c_related_cust_account_id (in_cust_account_id in number) IS
  SELECT cust_account_id
    FROM hz_cust_acct_relate
   WHERE related_cust_account_id=in_cust_account_id
     AND status='A';

l_contact_status varchar2(10) := 'XXX';
x_msg_data_contact varchar2(4000);
x_msg_count_contact number := null;
l_site_failed boolean := FALSE;
l_party_site_use_id number := null;
lcustomer_relations varchar2(1) := 'N';
l_rc_matched boolean := FALSE;
l_site_use_code varchar2(10);		--added for bug 4240715
--
l_debug_level NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  SAVEPOINT CREATE_ACCOUNT_LAYER;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Checking to see if the OM message stack needs to be initialized
  IF p_control_rec.p_init_msg_list THEN
    oe_msg_pub.initialize;
  END IF;

  IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  ' ==== Entering Create Account Layer ====');
     oe_debug_pub.add(' rec acct_id  = '||p_party_customer_rec.p_cust_account_id||
		      ' rec acct_nbr = '||p_party_customer_rec.p_cust_account_number);
     oe_debug_pub.add(' rec party_id ='||p_party_customer_rec.p_party_id|| ' rec party_nbr = '||
		      p_party_customer_rec.p_party_number);
     oe_debug_pub.add( ' rec org_contact_id = '||p_party_customer_rec.p_org_contact_id||
		       ' rec role_id = '||p_party_customer_rec.p_cust_account_role_id ) ;
  END IF;

  IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'allow account creation = '||P_CONTROL_REC.P_ALLOW_ACCOUNT_CREATION ) ;
  END IF;

  IF p_control_rec.p_allow_account_creation IS NOT NULL THEN

     IF p_control_rec.p_allow_account_creation = 'ALL' then
	p_allow_account_creation := TRUE;
	p_allow_contact_creation := TRUE;
	p_allow_site_creation    := TRUE;

     ELSIF p_control_rec.p_allow_account_creation = 'SITE_AND_CONTACT' then
	p_allow_account_creation := FALSE;
	p_allow_contact_creation := TRUE;
	p_allow_site_creation    := TRUE;

     ELSIF p_control_rec.p_allow_account_creation = 'NONE' then
	p_allow_account_creation := FALSE;
	p_allow_contact_creation := FALSE;
	p_allow_site_creation    := FALSE;

      -- any other values will be considered 'CHECK'
     ELSE
	fnd_profile.get('ONT_AUTOMATIC_ACCOUNT_CREATION',l_add_customer);
	IF l_debug_level  > 0 THEN
	   oe_debug_pub.add(  'atuomatic account creation profile = '||L_ADD_CUSTOMER ) ;
	END IF;
	IF l_add_customer = 'Y' then
	   p_allow_account_creation := TRUE;
	   p_allow_contact_creation := TRUE;
	   p_allow_site_creation    := TRUE;

	ELSIF l_add_customer='P' then
	   p_allow_account_creation := FALSE;
	   p_allow_contact_creation := TRUE;
	   p_allow_site_creation    := TRUE;
	ELSE
	   p_allow_account_creation := FALSE;
	   p_allow_contact_creation := FALSE;
	   p_allow_site_creation    := FALSE;
	END IF;

     END IF; -- checking the creation access profile

  ELSE -- if it is null
      fnd_profile.get('ONT_AUTOMATIC_ACCOUNT_CREATION',l_add_customer);
      IF l_debug_level  > 0 THEN
	 oe_debug_pub.add(  'atuomatic account creation profile = '||L_ADD_CUSTOMER ) ;
      END IF;
      IF l_add_customer = 'Y' then
	 p_allow_account_creation := TRUE;
	 p_allow_contact_creation := TRUE;
        p_allow_site_creation    := TRUE;

     ELSIF l_add_customer='P' then
        p_allow_account_creation := FALSE;
        p_allow_contact_creation := TRUE;
        p_allow_site_creation    := TRUE;
     ELSE
        p_allow_account_creation := FALSE;
        p_allow_contact_creation := FALSE;
        p_allow_site_creation    := FALSE;
     END IF;

  END IF; -- if permission is not null

  /*cc project. Value to id is not required for Telesales and Teleservice Integrations. The
  newly introduced flag p_control_rec.p_do_value_to_id it having a default value of TRUE. By default
  Value to id will be done for all the calls. But when calling from Teleservice and Telesales Integrations
  we will setting it as false so that value to id is ignored for these integrations.
  */

  IF (p_control_rec.p_do_value_to_id ) THEN
     IF l_debug_level  > 0 THEN
	oe_debug_pub.add('valud to id is required');
     END IF;
     Value_to_id(
	      p_party_customer_rec     => p_party_customer_rec
	      ,p_site_tbl     	        => p_site_tbl
	      ,p_permission             => l_add_customer
	      ,x_return_status          => x_return_status
	      ,x_msg_count              => x_msg_count
	      ,x_msg_data               => x_msg_data);

     IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         OE_MSG_PUB.Count_And_Get
           (   p_count                       => x_msg_count
	    ,   p_data                        => x_msg_data
	    );
         IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'returning with error after value_to_id' ) ;
         END IF;
         return;
     END IF;
   ELSE
      IF l_debug_level  > 0 THEN
	oe_debug_pub.add('valud to id is not required');
      END IF;
   END IF;
   /*cc project*/

IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  '===> entering create account layer');
     oe_debug_pub.add(' rec acct_id  = '||p_party_customer_rec.p_cust_account_id||
		          ' rec acct_nbr = '||p_party_customer_rec.p_cust_account_number);
     oe_debug_pub.add(' rec party_id = '||p_party_customer_rec.p_party_id||
			  ' rec party_nbr = '|| p_party_customer_rec.p_party_number);
     oe_debug_pub.add( ' rec org_contact_id = '||p_party_customer_rec.p_org_contact_id||
		           ' rec role_id        = '||p_party_customer_rec.p_cust_account_role_id ) ;
  END IF;

  -- Checking for minimum required information
  IF p_party_customer_rec.p_party_id IS NULL AND
     p_party_customer_rec.p_cust_account_id IS NULL AND
     p_party_customer_rec.p_cust_account_number IS NULL AND
     p_party_customer_rec.p_party_number IS NULL then

     --p_party_customer_rec.p_org_contact_id IS NULL AND
     --p_party_customer_rec.p_cust_account_role_id IS NULL  THEN

    x_return_status := FND_API.G_RET_STS_ERROR;
                         IF l_debug_level  > 0 THEN
                             oe_debug_pub.add(  'Returning with error as '|| ' required information is not sent' ) ;
                         END IF;
    return;
  END IF;

  IF p_control_rec.p_created_by_module IS NULL THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
                         IF l_debug_level  > 0 THEN
                             oe_debug_pub.add(  'returning with error as '|| ' created by module is not sent' ) ;
                         END IF;
    return;

  ELSE
    G_CREATED_BY_MODULE := p_control_rec.p_created_by_module;
  END IF;



  IF p_Control_rec.p_process_customer THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  ' customer processing required' ) ;
    end IF;
  ELSE
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  ' customer processing not required' ) ;
    end if;
  end if;

  if p_control_rec.p_process_contact then
    if l_debug_level  > 0 then
        oe_debug_pub.add(  ' contact processing required' ) ;
    end if;
  else
    if l_debug_level  > 0 then
        oe_debug_pub.add(  ' contact processing not required' ) ;
    END IF;
  END IF;

  l_cust_account_id := p_party_customer_rec.p_cust_account_id;
  l_party_id := p_party_customer_rec.p_party_id;

  -- we do not call check account if any account information is passed
  -- if both account and party information is passed then we ignore the
  -- party information

  oe_debug_pub.add('p_party_customer_rec.p_cust_account_id 	= '||p_party_customer_rec.p_cust_account_id );
  oe_debug_pub.add('p_party_customer_rec.p_cust_account_number  = '||p_party_customer_rec.p_cust_account_number );
  oe_debug_pub.add('p_party_customer_rec.p_party_id	= '||p_party_customer_rec.p_party_id );
  oe_debug_pub.add('p_party_customer_rec.p_party_number = '||p_party_customer_rec.p_party_number );


  IF ((p_party_customer_rec.p_cust_account_id is null) AND
     (p_party_customer_rec.p_party_id is not null or
     p_party_customer_rec.p_party_number is not null) AND
     p_control_rec.p_process_customer) then

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  '=== calling check_and_create_account...' ) ;
    END IF;

    /*cc project, Initializing the G_account_created_or_found before calling
    check_and_create_account.Everytime Check_and_create_account is called it will be
    resetting the value to CREATED in case account is created*/

    G_account_created_or_found :='FOUND';

    Check_and_Create_Account(
      p_party_id=>p_party_customer_rec.p_party_id
     ,p_party_number=>p_party_customer_rec.p_party_number
     ,p_allow_account_creation=>p_allow_account_creation
     ,p_multiple_account_is_error=>p_control_rec.p_multiple_account_is_error
     ,p_account_tbl=>p_account_tbl
     ,p_out_org_contact_id=>l_org_contact_id
     ,p_out_cust_account_role_id=>l_cust_account_role_id
     ,x_return_status=>x_return_status
     ,x_msg_count=>x_msg_count
     ,x_msg_data=>x_msg_data
     ,p_site_tbl_count=>p_site_tbl.COUNT
     ,p_return_if_only_party=>p_control_rec.p_return_if_only_party
    );
    /*cc project assigning the value of G_account_created_or_found to p_party_customer_rec */
    p_party_customer_rec.p_account_created_or_found :=G_account_created_or_found;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add( 'Account Found/Created:'||p_party_customer_rec.p_account_created_or_found) ;
    END IF;
    /*cc project*/

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  '=== ...done calling check_and_create_account' ) ;
    END IF;

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'returning with error' ) ;
      END IF;
      return;

    END IF;


    IF p_account_tbl.COUNT > 0 then
       FOR i in p_account_tbl.FIRST..p_account_tbl.LAST
		LOOP
	  IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  ' ACCT_ID='||P_ACCOUNT_TBL ( I ) ) ;
	  END IF;
       END LOOP;
    END IF;

    --If multiple Accounts then return the account table
    IF p_account_tbl.COUNT > 1 then
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'returning with multiple accounts' ) ;
      end IF;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      l_multiple_account := TRUE;
      return;
    ELSIF p_account_tbl.COUNT = 0 then
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'no accounts found returning' ) ;
      end IF;
      /*cc project, We need to return the status success, if account creation is not allowed so that
       Add customer will be shown */
      IF ((p_control_rec.p_return_if_only_party AND p_site_tbl.COUNT = 0) OR ( G_CREATED_BY_MODULE = 'ONT_TELESERVICE_INTEGRATION' AND NOT p_allow_account_creation))THEN
        x_return_status := FND_API.G_RET_STS_SUCCESS;
      ELSE
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      return;
    ELSIF p_account_tbl.COUNT = 1 then
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      l_cust_account_id := p_account_tbl(1);
    END IF;
  ELSE
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  ' account does not need to be checked' ) ;
    END IF;

  END IF; -- if account needs to be checked

  -- Checking for Account Information
  IF p_party_customer_rec.p_cust_account_id is not null AND
     p_control_rec.p_process_customer THEN

    OPEN c_check_account(p_party_customer_rec.p_cust_account_id);
    FETCH c_check_account
     INTO l_status,
          l_party_id;

    IF c_check_account%FOUND THEN
      IF l_status <>'A' then
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'account is not active' ) ;
        END IF;
        FND_MESSAGE.Set_Name('ONT','ONT_AAC_INACTIVE_ACCOUNT');
        OE_MSG_PUB.ADD;
        CLOSE c_check_account;
        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
        return;
      END IF;

      oe_debug_pub.add(  'overwriting p_account_tbl: ' || p_account_tbl.COUNT ) ;

      p_account_tbl(1) := p_party_customer_rec.p_cust_account_id;
      p_party_customer_rec.p_party_id := l_party_id;

    ELSIF c_check_account%NOTFOUND THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'invalid account.no such account_id ' ) ;
        END IF;
        FND_MESSAGE.Set_Name('ONT','ONT_AAC_NO_ACCOUNT');
        OE_MSG_PUB.ADD;
        CLOSE c_check_account;
        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
        return;

    END IF;


  -- if Account Number was passed then we ge the cust account id
  ELSIF   p_party_customer_rec.p_cust_account_number is not null AND
          p_control_rec.p_process_customer THEN

    OPEN c_get_cust_account_id(p_party_customer_rec.p_cust_account_Number);
    FETCH c_get_cust_account_id
     INTO l_cust_account_id,
          l_party_id,
          l_status;

    IF c_get_cust_account_id%NOTFOUND THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'invalid customer account number:'||p_party_customer_rec.p_cust_account_Number ) ;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('ONT','ONT_AAC_NO_ACCOUNT');
      OE_MSG_PUB.ADD;
      CLOSE c_get_cust_account_id;
        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
      return;
    ELSIF c_get_cust_account_id%FOUND THEN
      IF l_status <> 'A' then
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'account for account number is not active' ) ;
        END IF;
        FND_MESSAGE.Set_Name('ONT','ONT_AAC_INACTIVE_ACCOUNT');
        OE_MSG_PUB.ADD;
        CLOSE c_get_cust_account_id;
        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
        return;
      END IF;

      p_party_customer_rec.p_party_id := l_party_id;
    END IF;

  END IF; -- if account information is not null


  -- getting party_id for the account_record
  IF l_party_id is null AND
     p_control_rec.p_process_customer then
    OPEN c_cust_account_id(l_cust_account_id);
    FETCH c_cust_account_id
     INTO l_party_id;
    IF c_cust_account_id%NOTFOUND THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'INVALID CUSTOMER ACCOUNT ID' ) ;
      END IF;
      CLOSE c_cust_account_id;
        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
      return;
    END IF;
  END IF;


  IF l_debug_level  > 0 THEN
     oe_debug_pub.add(' status after acct = '||x_return_status||' l_cust_account_id = '|| l_cust_account_id);
     oe_debug_pub.add(' rec cust_id       = '||p_party_customer_rec.p_cust_account_id|| ' l_party_id = '||l_party_id||
		      ' acct tbl count = '||p_account_tbl.count ) ;
  END IF;


  /* cc project. At this point sold_to_customer is either created or found.
     For the contact center integration we need to return back the control to
     give higher precedence for defaulting of related customer and account sites
     in case sold_to_customer is found.
  */
  IF (p_control_rec.p_return_if_customer_found = TRUE  AND p_party_customer_rec.p_account_created_or_found ='FOUND') THEN
	IF l_debug_level  > 0 THEN
           oe_debug_pub.add('account was found.p_return_if_customer_found is true, so returning ');
	END IF;
	return;
  ELSE
	IF l_debug_level  > 0 THEN
           oe_debug_pub.add('either accunt was created or p_return_if_customer_found is false, So continue processing');
	   oe_debug_pub.add('p_account_created_or_found:'||p_party_customer_rec.p_account_created_or_found);
        END IF;

  END IF;
  /* cc project */


  /* at this point: created the sold_to customer
     now start creating the related customers
  */
  lcustomer_relations := OE_Sys_Parameters.VALUE('CUSTOMER_RELATIONSHIPS_FLAG');
  fnd_profile.get('ONT_AUTOMATIC_ACCOUNT_CREATION',l_add_customer);

  oe_debug_pub.add('related customer profile: '||lcustomer_relations);
  oe_debug_pub.add('add customer profile: '||l_add_customer);

  IF l_debug_level  > 0 THEN
	oe_debug_pub.add(  'Starting related customer(RC) support' ) ;
  END IF;

  /* p_site_tbl exists {*/
  IF p_site_tbl.COUNT > 0 THEN

  /* loop through p_site_tbl {*/

	--{added for bug 4240715
	/*added to handle conditon where no sold to information passed and other customer(ship/bill/delvier)being passed */

	    IF p_party_customer_rec.p_party_id IS NULL AND -- end customer enhancement
							   p_party_customer_rec.p_cust_account_id IS NULL AND
							      p_party_customer_rec.p_cust_account_number IS  NULL AND
								 p_party_customer_rec.p_party_number IS NULL and
								    p_site_tbl(i).p_site_use_code <>'END_CUST' then

	       x_return_status := FND_API.G_RET_STS_ERROR;
	       IF l_debug_level  > 0 THEN
		  oe_debug_pub.add(  'Returning with error as '|| ' required information is not sent' ) ;
	       END IF;

	       return;
	    End if;
	--bug 4240715}

    FOR i IN p_site_tbl.FIRST..p_site_tbl.LAST LOOP
      IF l_debug_level  > 0 THEN
	 oe_debug_pub.add ('AAC:VTI:  ============ SITE CUSTOMER '||i||' of '||p_site_tbl.LAST||' ================ ');
	 oe_debug_pub.add(  'AAC:RC: processing site level customer#'||i);
      END IF;

      l2_cust_account_id := p_site_tbl(i).p_cust_account_id;
      l2_party_id        := p_site_tbl(i).p_party_id;


      if (p_site_tbl(i).p_process_site = false) then

	 IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'AAC:RC: customer#'||i||' does not require account creation, skipping');
	 END IF;
	 goto skip_loop;
      end if;

      IF  (p_site_tbl(i).p_cust_account_id is null) THEN
       /* account creation needed {*/

	 IF l_debug_level  > 0 THEN
	    oe_debug_pub.add('AAC:RC: account creation needed: party_id:'|| l2_party_id);
	    oe_debug_pub.add(  '=== calling check_and_create_account...' ) ;
	 END IF;
        -- create account if needed (profile willing ofcourse)
        Check_and_Create_Account(
		       p_party_id=>l2_party_id
		       ,p_party_number=>l2_party_number
		       ,p_allow_account_creation=>p_allow_account_creation
		       ,p_multiple_account_is_error=>p_control_rec.p_multiple_account_is_error
		       ,p_account_tbl=>l_account_tbl
		       ,p_out_org_contact_id=>l_org_contact_id
		       ,p_out_cust_account_role_id=>l_cust_account_role_id
		       ,x_return_status=>x_return_status
		       ,x_msg_count=>x_msg_count
		       ,x_msg_data=>x_msg_data
		       ,p_site_tbl_count=>p_site_tbl.COUNT
		       ,p_return_if_only_party=>p_control_rec.p_return_if_only_party
		       );

	IF l_debug_level  > 0 THEN
	   oe_debug_pub.add(  '=== ...done calling check_and_create_account' ) ;
	END IF;

	-- error checking
      --If multiple Accounts then return the account table
      IF l_account_tbl.COUNT > 1 then
	 IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'AAC:RC: returning with multiple accounts' ) ;
	 END IF;
	 x_return_status := FND_API.G_RET_STS_SUCCESS;
	 --l_multiple_account := TRUE;
	 P_account_tbl:=l_account_tbl;
	 return;
      ELSIF l_account_tbl.COUNT = 0 then
	 IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'AAC:RC: no accounts found returning' ) ;
	 END IF;
	 IF p_control_rec.p_return_if_only_party AND p_site_tbl.COUNT = 0 THEN
	    x_return_status := FND_API.G_RET_STS_SUCCESS;
	 ELSE
	    x_return_status := FND_API.G_RET_STS_ERROR;
	 END IF;
	 x_return_status := FND_API.G_RET_STS_SUCCESS;
	 return;
      ELSIF l_account_tbl.COUNT = 1 then
	 x_return_status := FND_API.G_RET_STS_SUCCESS;
	 l2_cust_account_id := l_account_tbl(1);

	 -- populate cust_account_id back to site_tbl
	 IF l_debug_level  > 0 THEN
	    oe_debug_pub.add('AAC:RC: account created: cust_account_id:'|| l2_cust_account_id);
	 END IF;
	 p_site_tbl(i).p_cust_account_id:=l2_cust_account_id;
      END IF; -- account_tbl count

     END IF; /* account creation ends} */

     IF ((p_site_tbl(i).p_cust_account_id is not null)
	and (p_site_tbl(i).p_site_use_code <> 'END_CUST')) THEN -- end customer changes(bug 4240715)

      IF l_debug_level  > 0 THEN
	 oe_debug_pub.add(  'AAC:RC: account exists, checking for relationship' ) ;
	 oe_debug_pub.add(  'l_cust_account_id   = '||l_cust_account_id);
	 oe_debug_pub.add(  'site_tbl account_id = '||p_site_tbl(i).p_cust_account_id);
	 oe_debug_pub.add(  'party_customer_rec account_id = '||p_party_customer_rec.p_cust_account_id);
      END IF;

      found_relationship := FALSE;
      IF l_cust_account_id=p_site_tbl(i).p_cust_account_id
	 --or p_site_tbl(i).p_cust_account_id is null
      THEN
	 oe_debug_pub.add('AAC:RC: Customers are same');
	 l_rc_matched := TRUE;
      else
	 oe_debug_pub.add('AAC:RC: Customers are different');
	 l_rc_matched := FALSE;
      end if;

      IF (lcustomer_relations = 'N')
      then
	 oe_debug_pub.add('AAC:RC: Relationship is N');

	 if (l_rc_matched = FALSE ) then
	    FND_MESSAGE.Set_Name('ONT','ONT_AVAIL_GENERIC');
	    FND_MESSAGE.Set_Token('TEXT',' Customer Relationship is not allowed. SoldTo and Site Level Customer should be same');
            OE_MSG_PUB.ADD;
	    oe_debug_pub.add('AAC:RC: ERROR: Customers are different');
	    x_return_status :=  FND_API.G_RET_STS_ERROR;
	    return;
	 END IF;

      elsif (lcustomer_relations = 'Y')
      then
	 oe_debug_pub.add('AAC:RC: Relationship is Y');

	 IF (l_rc_matched = FALSE)
	 then
	    oe_debug_pub.add('AAC:RC: Customers are different. Create relationship');
	    begin
	       select cust_account_id
		  into matched_cust
		  from hz_cust_acct_relate
		  where related_cust_account_id=l_cust_account_id
		  and cust_account_id=p_site_tbl(i).p_cust_account_id;

	       found_relationship := TRUE;
	       IF l_debug_level  > 0 THEN
		  oe_debug_pub.add(  'AAC:RC: relationship found' ) ;
	       END IF;

	    EXCEPTION
	       WHEN NO_DATA_FOUND THEN
		  IF l_debug_level  > 0 THEN
		     oe_debug_pub.add(  'AAC:RC: no relationship' ) ;
	          END IF;
		  found_relationship  := FALSE;

	    END; -- begin

            if(found_relationship = FALSE) then

              if (l_add_customer = 'Y')
              then
	       oe_debug_pub.add('AAC:RC: l_add_customer is Y');
               oe_debug_pub.add('AAC:RC: creating relationship');
	       oe_oe_inline_address.create_cust_relationship(
							     p_cust_acct_id => p_site_tbl(i).p_cust_account_id
							     ,p_related_cust_acct_id => l_cust_account_id
							     ,p_reciprocal_flag      => 'Y'
							     ,x_return_status        => x_return_status
							     ,x_msg_count            => x_msg_count
							     ,x_msg_data             => x_msg_data);

	       IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
		  oe_debug_pub.add('Creating relationship failed');

		  x_return_status := FND_API.G_RET_STS_ERROR;
		  FND_MESSAGE.Set_Name('ONT','ONT_AVAIL_GENERIC');
		  FND_MESSAGE.Set_Token('TEXT',' Customer Relationship creation failed. ', FALSE);
		  OE_MSG_PUB.ADD;
		  OE_MSG_PUB.Count_And_Get ( p_count => x_msg_count ,  p_data => x_msg_data );
		  return;
	       END IF; -- if failure
               oe_debug_pub.add('AAC:RC: relationship created');
	    else -- l_add_customer = 'N'
	       x_return_status := FND_API.G_RET_STS_ERROR;
	       IF l_debug_level  > 0 THEN
		  oe_debug_pub.add('AAC:RC: ERROR: l_add_customer is N' );
	       END IF;
	       FND_MESSAGE.Set_Name('ONT','ONT_AVAIL_GENERIC');
	       FND_MESSAGE.Set_Token('TEXT',' Customer Relationship not defined. No permission to create relationship. ', FALSE);
	       OE_MSG_PUB.ADD;
	       OE_MSG_PUB.Count_And_Get ( p_count => x_msg_count ,  p_data => x_msg_data );
	       return;
	    end if; -- l_add_customer end
           end if; -- found_relationship
	 else -- l_rc_matched = TRUE
	    oe_debug_pub.add('AAC:RC: Customers are same. continue');
	 end if; --l_rc_matched


      elsif (lcustomer_relations = 'A')
      then
	 oe_debug_pub.add('AAC:RC: Relationship is A. Continue');
      end if;

     END IF; -- if p_site_tbl account_id is not null

     <<skip_loop>>
     null;

   END LOOP; /* looping through p_site_tbl} */

  END IF;/* we have p_site_tbl} */

  IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'AAC: ...done related customer' ) ;
  END IF;
     /* done related customer here */

  -- if the check_customer did not fail or did not return multiple accts
  -- then call check contact

  IF x_return_status <> FND_API.G_RET_STS_ERROR AND
    ( p_account_tbl.COUNT = 1 OR
      p_party_customer_rec.p_cust_account_id IS NOT NULL) AND
     p_Control_rec.p_process_contact
  THEN
     IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'checking and creating contact' ) ;
     END IF;
     -- if contact was found in check account because of party relationship
     -- then use that contact
     IF l_cust_account_role_id is null AND
	l_org_contact_id is null then
	IF l_debug_level  > 0 THEN
	   oe_debug_pub.add(  'taking contact informaton from record' ) ;
	END IF;
	l_cust_account_role_id :=p_party_customer_rec.p_cust_account_role_id;
	l_org_contact_id :=p_party_customer_rec.p_org_contact_id;
     END IF;

     IF l_cust_account_role_id is not null OR
	l_org_contact_id is not null then

	-- check_and_Create_Contact should also handle validation against related
	-- customers
	l3_cust_account_id := l_cust_account_id;

	-- handle the scenario if no acct or party information is passed
	Check_and_Create_Contact(
				 p_party_id=>l_party_id
				 ,p_cust_account_id=>l3_cust_account_id
				 ,p_org_contact_id=>l_org_Contact_id
				 ,P_site_use_code=>null
				 ,p_allow_contact_creation=>p_allow_contact_creation
				 ,p_create_responsibility=>FALSE
				 ,p_cust_account_role_id=>l_cust_account_role_id
				 ,p_cust_account_site_id=>null
				 ,p_assign_contact_to_site=>FALSE
				 ,p_multiple_account_is_error=>p_control_rec.p_multiple_account_is_error
				 ,p_multiple_contact_is_error=>p_control_rec.p_multiple_contact_is_error
				 ,p_contact_tbl=>p_contact_tbl
				 ,p_multiple_account=>l_multiple_account
				 ,x_return_status=>x_return_status
				 ,x_msg_count=>x_msg_count
				 ,x_msg_data=>x_msg_data
				 );


      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'count contact table = '||P_CONTACT_TBL.COUNT ) ;
      END IF;
      IF p_Contact_tbl.COUNT > 0 THEN
        FOR i in p_contact_tbl.FIRST..p_contact_tbl.LAST
        LOOP
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'contact_id = '||P_CONTACT_TBL ( I ) ) ;
          END IF;
        END LOOP;
      END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'contact with error' ) ;
        END IF;
        l_contact_status := FND_API.G_RET_STS_ERROR;
        x_msg_data_contact := x_msg_data;
        x_msg_count_contact := x_msg_count;
        --OE_MSG_PUB.Count_And_Get
        --(   p_count                       => x_msg_count
        --,   p_data                        => x_msg_data
        --);
        --return;
      END IF;


      --If multiple Contact then return the contact table
      IF p_contact_tbl.COUNT > 1 then
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'returning with multiple contacts' ) ;
        end IF;

	if p_control_rec.p_multiple_contact_is_error then
	   IF l_debug_level  > 0 THEN
	      oe_debug_pub.add(  'erroring with multiple contacts' ) ;
	   END IF;
	   x_return_status :=  FND_API.G_RET_STS_ERROR;
	else
	   x_return_status := FND_API.G_RET_STS_SUCCESS;
	end if;
        return;
     ELSIF p_contact_tbl.COUNT = 0 then
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'no contacts found error' ) ;
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
      ELSIF p_contact_tbl.COUNT = 1 then
        null;
      END IF;

    ELSE
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'not calling check contact' ) ;
      END IF;

    END IF; -- if contact data is passed

  ELSE -- if status is not success

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  '2 not calling check contact' ) ;
      END IF;

  END IF; -- if status  was successful


  IF p_control_rec.p_continue_processing_on_error then
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'continue processing on error' ) ;
    end if;
  else
    if l_debug_level  > 0 then
        oe_debug_pub.add(  'do not continue processing on error' ) ;
    END IF;
  END IF;

  -- If status is not error and there are records in the site table
  -- OR we shall continue even if error
  IF (p_control_rec.p_continue_processing_on_error AND p_site_tbl.COUNT >0 ) OR
     (x_return_status <> FND_API.G_RET_STS_ERROR AND p_site_tbl.COUNT > 0 ) THEN

     -- loop through p_site_tbl for all contacts

     FOR i IN p_site_tbl.FIRST..p_site_tbl.LAST LOOP

	IF l_debug_level  > 0 THEN
	   oe_debug_pub.add ('AAC:VTI:  ============ SITE CONTACT '||i||' of '||p_site_tbl.LAST||' =============== ');
	   oe_debug_pub.add(  'AAC: processing site#'||i||' for contacts');
	END IF;

	l2_cust_account_id := l_cust_account_id;
	l2_party_id        := l_party_id;
	l2_org_contact_id  := l_org_contact_id;

	if (nvl(p_site_tbl(i).p_cust_account_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM
	    OR nvl(p_site_tbl(i).p_party_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM )
	then
	   l2_cust_account_id := p_site_tbl(i).p_cust_account_id;
	   l2_party_id     := p_site_tbl(i).p_party_id;
	   oe_debug_pub.add('site level cust_account_id: '||l2_cust_account_id);
	   oe_debug_pub.add('site level party_id: '||l2_party_id);
	end if;

         oe_debug_pub.add(  'AAC:Site Contact-Cust_Acct_Role_id'||p_site_tbl(i).p_cust_account_role_id);
         oe_debug_pub.add(  'AAC:Site Contact-Cust_Acct_Role_id'||l_cust_account_role_id);
        if (nvl(p_site_tbl(i).p_cust_account_role_id,FND_API.G_MISS_NUM)
              = FND_API.G_MISS_NUM) THEN
           l_cust_account_role_id:=null;
        else
           l_cust_account_role_id:=p_site_tbl(i).p_cust_account_role_id;
        end if;
         oe_debug_pub.add(  'AAC: After Site Contact-Cust_Acct_Role_id'||l_cust_account_role_id);


	if nvl(p_site_tbl(i).p_org_contact_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM then
	   l2_org_contact_id := p_site_tbl(i).p_org_contact_id;
	end if;

	--{added for bug 4240715
	if p_site_tbl(i).p_site_use_code ='END_CUST' then /* added check for end customer */
	   l_site_use_code := 'SOLD';
           if nvl(p_site_tbl(i).p_cust_account_role_id,FND_API.G_MISS_NUM)=FND_API.G_MISS_NUM then
            l_cust_account_role_id:=null;
	   else
	      l_cust_account_role_id :=p_site_tbl(i).p_cust_account_role_id;
	      end if;
	else
	   l_site_use_code := p_site_tbl(i).p_site_use_code;
	  end if;
	  --bug 4240715}

	Check_and_Create_Contact(
				 p_party_id=>l2_party_id
				 ,p_cust_account_id=>l2_cust_account_id
				 ,p_org_contact_id=>l2_org_Contact_id
				 ,P_site_use_code=>l_site_use_code		--modified for bug 4240715
				 ,p_allow_contact_creation=>p_allow_contact_creation
				 ,p_create_responsibility=>FALSE
				 ,p_cust_account_role_id=>l_cust_account_role_id
				 ,p_cust_account_site_id=>null
				 ,p_assign_contact_to_site=>FALSE
				 ,p_multiple_account_is_error=>p_control_rec.p_multiple_account_is_error
				 ,p_multiple_contact_is_error=>p_control_rec.p_multiple_contact_is_error
				 ,p_contact_tbl=>p2_contact_tbl
				 ,p_multiple_account=>l_multiple_account
				 ,x_return_status=>x_return_status
				 ,x_msg_count=>x_msg_count
				 ,x_msg_data=>x_msg_data
				 );

	IF l_debug_level  > 0 THEN
	   oe_debug_pub.add(  'AAC: ..done calling check_and_create_contacts ' ) ;
          oe_debug_pub.add(  'count contact table = '||P2_CONTACT_TBL.COUNT ) ;
      END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'contact with error' ) ;
        END IF;

        l_contact_status := FND_API.G_RET_STS_ERROR;
        x_msg_data_contact := x_msg_data;
        x_msg_count_contact := x_msg_count;
      END IF;


      --If multiple Contact then return the contact table
      IF p2_contact_tbl.COUNT > 1 then
	 if p_control_rec.p_multiple_contact_is_error then
	    IF l_debug_level  > 0 THEN
	       oe_debug_pub.add(  'erroring with multiple contacts' ) ;
	    END IF;
	    x_return_status :=  FND_API.G_RET_STS_ERROR;
	 else
	    x_return_status := FND_API.G_RET_STS_SUCCESS;
	 end if;

      ELSIF p2_contact_tbl.COUNT = 0 then
	 IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'no contacts found error' ) ;
	 END IF;
	 x_return_status := FND_API.G_RET_STS_ERROR;
      ELSIF p2_contact_tbl.COUNT = 1 then
	 p_site_tbl(i).p_cust_account_role_id := p2_contact_tbl(1);
      END IF;
   end loop;

   IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'XX calling check_and_create_sites... ' ) ;
    END IF;

    -- check_and_Create_Sites should also valdiate against related
    -- customers now. and create their sites if ncessary
    /*cc project, based on the  g_fech_parimary_party_sites value the logic for check_and_create
    sites will execute. If it is true then we will ignore the addresses passed to us and instead
    fetch and primary party sites and related account sites. If primary party sites are found and no corresponding
    account sites are there then we will create the account sites.
    If there is no primary party sites are found then we will use the party sites that are passed to
    fetch/create the account sites

    The above logic is only for the Contact Center Integration. For other integrations and
    existing logic should work
    */

    G_fetch_primary_party_sites :=p_control_rec.p_fetch_primary_party_sites;

    IF l_debug_level  > 0 THEN
       IF  (G_fetch_primary_party_sites) THEN
	   oe_debug_pub.add('G_fetch_primary_party_sites :TRUE');
       ELSE
	   oe_debug_pub.add('G_fetch_primary_party_sites :FALSE');
       END IF;
    END IF;

    /*cc project */
    Check_and_Create_Sites(
      p_party_id=>l_party_id
     ,p_cust_account_id=>l_cust_account_id
     ,p_site_tbl=>p_site_tbl
     ,p_allow_site_creation=>p_allow_site_creation
     ,p_continue_on_error=>p_control_rec.p_continue_processing_on_error
     ,x_return_status=>x_return_status
     ,x_msg_data=>x_msg_data
     ,x_msg_count=>x_msg_count
     );

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'XX ...done calling check_and_create_sites ' ) ;
    END IF;

 ELSE
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'not calling check_and_create_sites X ' ) ;
    END IF;

  END IF; -- if site table exists

  -- we may not have to check the success status as data may need to be
  -- commited even if some txn failed.
  -- however in telesales we will never commit so it is fine
  IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
    IF p_control_rec.p_commit THEN
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'commiting the txn' ) ;
      end if;
      commit;

    end if;
  else

        if l_debug_level  > 0 then
            oe_debug_pub.add(  'not commiting the txn' ) ;
        END IF;
        l_site_failed := TRUE;
        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );


  END IF;

  -- THere might be failure in contact processing
  -- to show that message we send the status as error
  -- since in the client messages are displayed if only status is error
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  ' checking contact failure status = '||l_contact_status ) ;
  END IF;
  IF l_contact_status = FND_API.G_RET_STS_ERROR THEN
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  ' returning error for contact' ) ;
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;

    -- If site has failed then count and get above will catch that
    -- else to find the error message for contact we do this
    IF NOT l_site_failed then
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  ' msg from contact only' ) ;
      END IF;
      x_msg_data := x_msg_data_contact;
      x_msg_count := x_msg_count_contact;
    END IF;

  END IF;
  oe_debug_pub.add(  'p_account_tbl: ' || p_account_tbl.COUNT ) ;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

      IF c_check_account%ISOPEN THEN
        CLOSE c_check_account;
      END IF;
      IF c_get_cust_account_id%ISOPEN THEN
        CLOSE c_get_cust_account_id;
      END IF;
      IF c_cust_account_id%ISOPEN THEN
        CLOSE c_cust_account_id;
      END IF;

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN


      IF c_get_cust_account_id%ISOPEN THEN
        CLOSE c_get_cust_account_id;
      END IF;
      IF c_cust_account_id%ISOPEN THEN
        CLOSE c_cust_account_id;
      END IF;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN


      IF c_get_cust_account_id%ISOPEN THEN
        CLOSE c_get_cust_account_id;
      END IF;
      IF c_cust_account_id%ISOPEN THEN
        CLOSE c_cust_account_id;
      END IF;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                        IF l_debug_level  > 0 THEN
                            oe_debug_pub.add(  'CREATE_ACCOUNT_LAYER WHEN OTHER EXCEPTION CODE='|| SQLCODE||' MESSAGE='||SQLERRM ) ;
                        END IF;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'create_account_layer'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END create_account_layer;



PROCEDURE Check_and_Create_Sites(
    p_party_id in number
   ,p_cust_account_id in number
   ,p_site_tbl in out NOCOPY /* file.sql.39 change */ site_tbl_Type
   ,p_allow_site_creation in boolean
   ,p_continue_on_error in boolean
   -- this expects either party_site_use_id or site_use_code and party_site_id
   ,x_return_status out NOCOPY varchar2
   ,x_msg_data out NOCOPY varchar2
   ,x_msg_count out NOCOPY varchar2
   ) IS

l_site_use_code varchar2(20);
l_party_site_id number := null;
l_party_id number := null;
l_primary_per_type varchar2(10);
l_cust_acct_site_id number;
l_site_use_id number := null;
l_site_use_primary_flag varchar2(10);
l_send_primary varchar2(10);
l_end_customer_passed varchar2(2);	--added for bug 4240715
l_status varchar2(10);
l_primary_site_use varchar2(10);
lx_party_site_use_id number := null;	--added for bug 4240715

/* cc project */
l_party_site_use_id number;
l_party_site_id_cc number;
/* cc project */


CURSOR c_party_site_use(in_party_site_use_id in number) IS
  SELECT site_use.site_use_type,site_use.party_site_id,site_use.primary_per_type
    FROM hz_party_site_uses site_use,
         hz_party_sites site
   WHERE party_site_use_id = in_party_site_use_id
     AND site.party_site_id = site_use.party_site_id
     AND site.status = 'A'
     AND site_use.status='A';

CURSOR c_party_site(in_party_site_id in number) IS
  SELECT party_id,status
    FROM hz_party_sites
   WHERE party_site_id = in_party_site_id;


CURSOR c_acct_site(in_cust_account_id in number
                  ,in_party_site_id in number
                  ,in_site_use_code in varchar2) IS
  SELECT s.cust_acct_site_id,u.site_use_id,u.primary_flag
    FROM hz_cust_acct_sites s,
         hz_cust_site_uses_all u
   WHERE s.cust_account_id = in_cust_account_id
     AND s.party_site_id = in_party_site_id
     AND s.status(+) = 'A'
     AND u.cust_acct_site_id(+) = s.cust_acct_site_id
     AND u.site_use_code(+) = in_site_use_code
     AND u.status(+) = 'A';

CURSOR c_site_use(in_site_use_id in number,
                  in_site_use_code in varchar2) IS
  SELECT uses.cust_acct_site_id,
         uses.status,
         uses.primary_flag,
         cust_site.cust_account_id
    FROM hz_cust_site_uses uses, hz_cust_acct_sites_all cust_site
   WHERE site_use_id = in_site_Use_id
     AND site_use_code = in_site_use_code
     AND cust_site.cust_acct_site_id = uses.cust_acct_site_id;

CURSOR C_get_cust_from_site_use_id(l_site_use_Id NUMBER) IS
        SELECT a.cust_account_id
        FROM hz_cust_acct_sites_all a,
             hz_cust_site_uses b
        WHERE b.site_use_id=l_site_use_id
        and a.cust_acct_site_id=b.cust_acct_site_id
        and b.status = 'A';

/*cc project*/
CURSOR c_get_party_sites(in_party_id  in number) IS
   SELECT party_site_id
          FROM hz_party_sites
	  where party_id = in_party_id
	  and status='A';


CURSOR c_prim_party_site_use(in_party_site_id in number,in_site_use_type in varchar2) IS
    SELECT party_site_use_id
          FROM hz_party_site_uses
	  where party_site_id=in_party_site_id and
	  site_use_type=in_site_use_type and
	  primary_per_type='Y'
	  and status='A';


/*cc project*/
--{added for bug 4240715
CURSOR c_endcust_party_site_use(in_party_site_id in number,in_site_use_type in varchar2) IS
  SELECT site_use.party_site_use_id
    FROM hz_party_site_uses site_use,
         hz_party_sites site
   WHERE party_site_use_id = site_use.party_site_use_id
     AND site.party_site_id = in_party_site_id
     AND site_use.site_use_type =in_site_use_type
     AND site.status = 'A'
     AND site_use.status='A';

 --bug 4240715}


l_return_status varchar2(1);
px_cust_account_id number := null;
l_cust_account_id number := null;
--l_site_party_site_use_id number := null;
px_party_id number := null;

--
l_debug_level  NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   px_party_id        := p_party_id;
   px_cust_account_id := p_cust_account_id;

   --l_debug_level:=1;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_return_status := FND_API.G_RET_STS_SUCCESS;

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(' cust_id  = '||p_cust_account_id);
      oe_debug_pub.add(' party_id = '||p_party_id);
      oe_debug_pub.add(' site tbl count = '||p_SITE_TBL.COUNT ) ;
   END IF;

   IF p_cust_account_id is null then
      x_return_status := FND_API.G_RET_STS_ERROR;
  IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  ' ERROR: cust account id must be sent to check sites' ) ;
  END IF;

END IF;


FOR i in p_site_tbl.FIRST..p_site_tbl.LAST
LOOP

   l_party_site_id := null;
   l_site_use_code := null;
   l_party_id      := null;
   l_status        := null;
   l_site_use_code := null;
   l_party_id      := null;
   l_primary_per_type  := null;
   l_cust_acct_site_id := null;
   l_site_use_id           := null;
   l_site_use_primary_flag := null;
   l_send_primary          := null;
   l_primary_site_use      := null;
   l_end_customer_passed   :='N';  --added for bug 4240715

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   IF l_debug_level  > 0 THEN
      oe_debug_pub.add ('AAC:VTI:  ========= SITE TABLE RECORD '||i||' of '||p_site_tbl.LAST||' ================== ');
      oe_debug_pub.add(' site table rec #'||i);
      oe_debug_pub.add(' party_site_use_id = '|| p_site_tbl(i).p_party_site_use_id);
      oe_debug_pub.add(' party_site_id     = '|| p_site_tbl(i).p_party_site_id|| ' site_use_code = '||p_site_tbl(i).p_site_use_code);
      oe_debug_pub.add(' site_use_id       ='||p_site_tbl(i).p_site_use_id ) ;
   END IF;

   if (p_site_tbl(i).p_process_site = FALSE) then
      IF (l_debug_level  > 0) THEN
	 oe_debug_pub.add(  ' p_process_site is NULL, skipping site processing..');
      end if;
      goto skip_site;
   end if;

     --{added for bug 4240715
   if(p_site_tbl(i).p_site_use_code ='END_CUST') then -- end_customer enhancement
       l_end_customer_passed :='Y';
       end if;
     --bug 4240715}

   if nvl(p_site_tbl(i).p_cust_account_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM OR
      nvl(p_site_tbl(i).p_party_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM
   then
      px_cust_account_id := p_site_tbl(i).p_cust_account_id;
      px_party_id := p_site_tbl(i).p_party_id;
   end if;


   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  ' site level customer: party_id:'||px_party_id ) ;
      oe_debug_pub.add(  ' site level customer: account_id:'||px_cust_account_id ) ;
   END IF;


 if (      nvl(p_site_tbl(i).p_party_site_use_id  ,FND_API.G_MISS_NUM)  = FND_API.G_MISS_NUM
       and nvl(p_site_tbl(i).p_party_site_id      ,FND_API.G_MISS_NUM)  = FND_API.G_MISS_NUM
       and nvl(p_site_tbl(i).p_site_use_id        ,FND_API.G_MISS_NUM)  = FND_API.G_MISS_NUM
       and nvl(p_site_tbl(i).p_site_address1      ,FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR
       and nvl(p_site_tbl(i).p_site_address2      ,FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR
       and nvl(p_site_tbl(i).p_site_address3      ,FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR
       and nvl(p_site_tbl(i).p_site_address4      ,FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR
       and nvl(p_site_tbl(i).p_site_org           ,FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR
       and nvl(p_site_tbl(i).p_site_city          ,FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR
       and nvl(p_site_tbl(i).p_site_state         ,FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR
       and nvl(p_site_tbl(i).p_site_postal_code   ,FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR
       and nvl(p_site_tbl(i).p_site_country       ,FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR
       and nvl(p_site_tbl(i).p_cust_account_id    ,FND_API.G_MISS_NUM)  = FND_API.G_MISS_NUM
       and nvl(p_site_tbl(i).p_party_id           ,FND_API.G_MISS_NUM)  = FND_API.G_MISS_NUM)
   then
      --nothing to do! return!
      IF l_debug_level > 0 THEN
	 oe_debug_pub.add ('AAC: create_sites: no data passed in, likely a contact search; returning');
      END IF;
      return;
   end if;


  IF p_site_tbl(i).p_site_use_code IS NOT NULL THEN
    l_site_use_code := p_site_tbl(i).p_site_use_code;
  ELSE
    l_return_status := FND_API.G_RET_STS_ERROR;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'site use not specified' ) ;
    END IF;
    FND_MESSAGE.Set_Name('ONT','ONT_AAC_ERROR');

    FND_MESSAGE.Set_Token('TEXT','Usage of Account Site should be specified', FALSE);
    OE_MSG_PUB.ADD;
    IF p_continue_on_error THEN
      null;
    ELSE
        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
      return;
    END IF;
  END IF; -- if site_use_code is not null

  -- If site_use_id is passed then we validate this for the account
 IF p_site_tbl(i).p_site_use_id IS NOT NULL THEN

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  ' checking site_use_id' ) ;
   END IF;

	--{added for bug 4240715
	-- added for end customer /* check done based on the order SOLD_TO,SHIP_TO,BILL_TO,DELIVER_TO */
     if l_site_use_code ='END_CUST' then

	OPEN c_site_use(p_site_tbl(i).p_site_use_id,'SOLD_TO');
	FETCH c_site_use
	    INTO l_cust_acct_site_id,
		 l_status,
		 l_primary_site_use,
		 l_cust_account_id;

	if c_site_use%FOUND then
	   oe_debug_pub.add('Checking for end customer of type SOLD_TO');
	   l_site_use_code :='SOLD_TO';
	   l_site_use_id := p_site_tbl(i).p_site_use_id;
	   px_cust_account_id := p_cust_account_id;
	   px_party_id := p_party_id;
	   if l_status <> 'A' then
	      l_return_status := fnd_api.g_ret_sts_error;
	      IF l_debug_level  > 0 THEN
		 oe_debug_pub.add(  'account site use is inactive' ) ;
	      END IF;
	   end if;
	  /* IF l_cust_account_id <> px_cust_account_id then
	      x_return_status := FND_API.G_RET_STS_ERROR;
	      l_return_status := FND_API.G_RET_STS_ERROR;
	      IF l_debug_level  > 0 THEN
		 oe_debug_pub.add(  'site does not belong to this account, or site account' ) ;
	      END IF;
	   End if; */
	   goto end_customer_found;
	Else -- not sold to
	   close c_site_use;
	end if; -- sold to check;

	OPEN c_site_use(p_site_tbl(i).p_site_use_id,'SHIP_TO');
	FETCH c_site_use
	    INTO l_cust_acct_site_id,
		 l_status,
		 l_primary_site_use,
		 l_cust_account_id;

	if c_site_use%FOUND then
	   oe_debug_pub.add('Checking for end customer of type SHIP_TO');
	   l_site_use_code :='SHIP_TO';
	   l_site_use_id := p_site_tbl(i).p_site_use_id;
	   px_cust_account_id := p_cust_account_id;
	   px_party_id := p_party_id;
	   if l_status <> 'A' then
	      l_return_status := fnd_api.g_ret_sts_error;
	      IF l_debug_level  > 0 THEN
		 oe_debug_pub.add(  'account site use is inactive' ) ;
	      END IF;
	      FND_MESSAGE.Set_Name('ONT','ONT_AAC_SHIPTO_INACTIVE');
	      OE_MSG_PUB.ADD;
	   end if;
	 /*  IF l_cust_account_id <> px_cust_account_id then
	      x_return_status := FND_API.G_RET_STS_ERROR;
	      l_return_status := FND_API.G_RET_STS_ERROR;
	      IF l_debug_level  > 0 THEN
		 oe_debug_pub.add(  'site does not belong to this account, or site account' ) ;
	      END IF;
	      FND_MESSAGE.Set_Name('ONT','ONT_AAC_SHIPTO_ACCOUNT');
	      OE_MSG_PUB.ADD;
	   End if; */
	   goto end_customer_found;
	Else
	   close c_site_use;
	end if; -- ship to customer check;

	OPEN c_site_use(p_site_tbl(i).p_site_use_id,'BILL_TO');
	FETCH c_site_use
	    INTO l_cust_acct_site_id,
		 l_status,
		 l_primary_site_use,
		 l_cust_account_id;

	if c_site_use%FOUND then
	   oe_debug_pub.add('Checking for end customer of type BILL_TO');
	   l_site_use_code :='BILL_TO';
	   l_site_use_id := p_site_tbl(i).p_site_use_id;
	   px_cust_account_id := p_cust_account_id;
	   px_party_id := p_party_id;
	   if l_status <> 'A' then
	      l_return_status := fnd_api.g_ret_sts_error;
	      IF l_debug_level  > 0 THEN
		 oe_debug_pub.add(  'account site use is inactive' ) ;
	      END IF;
	      FND_MESSAGE.Set_Name('ONT','ONT_AAC_BILLTO_INACTIVE');
	      OE_MSG_PUB.ADD;
	   end if;
	  /* IF l_cust_account_id <> px_cust_account_id then
	      x_return_status := FND_API.G_RET_STS_ERROR;
	      l_return_status := FND_API.G_RET_STS_ERROR;
	      IF l_debug_level  > 0 THEN
		 oe_debug_pub.add(  'site does not belong to this account, or site account' ) ;
	      END IF;
	      FND_MESSAGE.Set_Name('ONT','ONT_AAC_BILLTO_ACCOUNT');
	      OE_MSG_PUB.ADD;
	   End if;*/
	   goto end_customer_found;
	Else -- not invoice to
	   close c_site_use;
	end if;

	OPEN c_site_use(p_site_tbl(i).p_site_use_id,'DELIVER_TO');
	FETCH c_site_use
	    INTO l_cust_acct_site_id,
		 l_status,
		 l_primary_site_use,
		 l_cust_account_id;

	if c_site_use%FOUND then
	   oe_debug_pub.add('Checking for end customer of type DELIVER_TO');
	   l_site_use_code :='DELIVER_TO';
	   l_site_use_id := p_site_tbl(i).p_site_use_id;
	   px_cust_account_id := p_cust_account_id;
	   px_party_id := p_party_id;
	   if l_status <> 'A' then
	      l_return_status := fnd_api.g_ret_sts_error;
	      IF l_debug_level  > 0 THEN
		 oe_debug_pub.add(  'account site use is inactive' ) ;
	      END IF;
	      FND_MESSAGE.Set_Name('ONT','ONT_AAC_DELIVERTO_INACTIVE');
	      OE_MSG_PUB.ADD;
	   end if;
	  /* IF l_cust_account_id <> px_cust_account_id then
	      x_return_status := FND_API.G_RET_STS_ERROR;
	      l_return_status := FND_API.G_RET_STS_ERROR;
	      IF l_debug_level  > 0 THEN
		 oe_debug_pub.add(  'site does not belong to this account, or site account' ) ;
	      END IF;
	      FND_MESSAGE.Set_Name('ONT','ONT_AAC_DELIVERTO_ACCOUNT');
	      OE_MSG_PUB.ADD;
	   End if; */
	   goto end_customer_found;
	else
	   close c_site_use;
	end if; -- deliver account;
	--bug 4240715}
     ELSE  -- not End customer

	OPEN c_site_use(p_site_tbl(i).p_site_use_id,l_site_use_code);
	FETCH c_site_use
	INTO l_cust_acct_site_id,
         l_status,
         l_primary_site_use,
         l_cust_account_id;

	l_site_use_id := p_site_tbl(i).p_site_use_id;
	px_cust_account_id := p_cust_account_id;
	px_party_id := p_party_id
	;

	IF c_site_use%FOUND THEN

	IF l_debug_level  > 0 THEN
	 oe_debug_pub.add('found site_use_id acct_site_id = '||l_cust_acct_site_id|| ' status='||l_status);
	 oe_debug_pub.add('                       primary = '||l_primary_site_use|| ' cust_account_id = '||l_cust_account_id ) ;
	end if;

	if l_status <> 'A' then
	 l_return_status := fnd_api.g_ret_sts_error;
		IF l_debug_level  > 0 THEN
		oe_debug_pub.add(  'account site use is inactive' ) ;
		END IF;

		IF l_site_use_code = 'SHIP_TO' then
			FND_MESSAGE.Set_Name('ONT','ONT_AAC_SHIPTO_INACTIVE');
		ELSIF l_site_use_code = 'BILL_TO' then
			FND_MESSAGE.Set_Name('ONT','ONT_AAC_BILLTO_INACTIVE');
		ELSIF l_site_use_code = 'DELIVER_TO' then
			FND_MESSAGE.Set_Name('ONT','ONT_AAC_DELIVERTO_INACTIVE');
		END IF;

	 OE_MSG_PUB.ADD;
	END IF;

	oe_debug_pub.add(  'px_accoun_id:'||px_cust_account_id||'l_accoun_id:'||l_cust_account_id ) ;
	/* IF l_cust_account_id <> px_cust_account_id then
		x_return_status := FND_API.G_RET_STS_ERROR;
		l_return_status := FND_API.G_RET_STS_ERROR;
		IF l_debug_level  > 0 THEN
			oe_debug_pub.add(  'site does not belong to this account, or site account' ) ;
		END IF;

		IF l_site_use_code = 'SHIP_TO' then
			FND_MESSAGE.Set_Name('ONT','ONT_AAC_SHIPTO_ACCOUNT');
		ELSIF l_site_use_code = 'BILL_TO' then
			FND_MESSAGE.Set_Name('ONT','ONT_AAC_BILLTO_ACCOUNT');
		ELSIF l_site_use_code = 'DELIVER_TO' then
			FND_MESSAGE.Set_Name('ONT','ONT_AAC_DELIVERTO_ACCOUNT');
		END IF;

	OE_MSG_PUB.ADD;
	END IF;
     */

	p_site_tbl(i).p_cust_acct_site_id := l_cust_acct_site_id;

	ELSIF c_site_use%NOTFOUND THEN
	 x_return_status := FND_API.G_RET_STS_ERROR;
	l_return_status := FND_API.G_RET_STS_ERROR;
	IF l_debug_level  > 0 THEN
	oe_debug_pub.add(  'INVALID SITE_USE_ID ' ) ;
       END IF;

       IF l_site_use_code = 'SHIP_TO' then
	  FND_MESSAGE.Set_Name('ONT','ONT_AAC_NO_SHIPTO');
       ELSIF l_site_use_code = 'BILL_TO' then
	  FND_MESSAGE.Set_Name('ONT','ONT_AAC_NO_BILLTO');
       ELSIF l_site_use_code = 'DELIVER_TO' then
	  FND_MESSAGE.Set_Name('ONT','ONT_AAC_NO_DELIVERTO');
       END IF;

       OE_MSG_PUB.ADD;

	END IF; -- if cursor found
	CLOSE c_site_use;
	END IF;		-- site_ use_code (bug 4240715)
	ELSE -- if site_use_id is null

		IF l_debug_level  > 0 THEN
		oe_debug_pub.add(  ' site_use_id not passed' ) ;
		END IF;
  /*cc project, based on the  g_fech_parimary_party_sites value the logic for check_and_create
    sites will execute. If it is true then we will ignore the addresses passed to us and instead
    fetch and primary party sites and related account sites. If primary party sites are found and no corresponding
    account sites are there then we will create the account sites.
    If there is no primary party sites are found then we will use the party sites that are passed to
    fetch/create the account sites

    The above logic is only for the Contact Center Integration. For other integrations and
    existing logic should work
  */
   IF(G_fetch_primary_party_sites) THEN

      /*fetching all the party sites of the given party_id */

      FOR l_party_site_id_rec IN c_get_party_sites(p_site_tbl(i).p_party_id) LOOP

	 l_party_site_id_cc :=l_party_site_id_rec.party_site_id;

	 IF l_debug_level  > 0 THEN
	    oe_debug_pub.add('cc Party site id :'|| l_party_site_id_cc);
	    oe_debug_pub.add('searching whether party site usage is primary or not');
	 END IF;

	 OPEN c_prim_party_site_use(l_party_site_id_cc,p_site_tbl(i).p_site_use_code);
	 FETCH c_prim_party_site_use
	 into l_party_site_use_id;


         IF c_prim_party_site_use%NOTFOUND THEN
	    IF l_debug_level  > 0 THEN
                 oe_debug_pub.add('no primary party site use of type :'||p_site_tbl(i).p_site_use_code||' of party_site_id:'||l_party_site_id_cc);
            END IF;
	 ELSIF c_prim_party_site_use%FOUND THEN
            p_site_tbl(i).p_party_site_use_id :=l_party_site_use_id;
	    l_party_site_id :=l_party_site_id_cc;
	    IF l_debug_level  > 0 THEN
               oe_debug_pub.add(' primary party site use of type :'||p_site_tbl(i).p_site_use_code||' of party_site_id:'||l_party_site_id_cc||' is found,party_site_use_id is'||l_party_site_use_id);
	       oe_debug_pub.add('exiting from loop to search primary party site uses');
	    END IF;
	    Close c_prim_party_site_use;
	    exit;

         END IF;

	 IF c_prim_party_site_use%ISOPEN then
	    Close c_prim_party_site_use;
	 END IF;

      END LOOP;

      /* By now we should have got the l_party_site_id populated in case a active primary party site use is found.
	 If we have not got it yet then we should execute the party_site_id passed to us
      */
      IF(l_party_site_id IS NULL) Then

        /*party_site_use_id will never be passed under contact center integration.
        we have to use site_use_code and party_site_id
        */
        -- if party_site_id is sent
         IF l_party_site_id is null AND
          x_return_status <> FND_API.G_RET_STS_ERROR then
	  oe_debug_pub.add(  'l_party_site_id is null and p_site_tbl(i).p_party_site_id is '||p_site_tbl(i).p_party_site_id);
            IF p_site_tbl(i).p_party_site_id is not null then
               IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  'checking for party_site_id ' ) ;
               END IF;

               l_party_site_id := p_site_tbl(i).p_party_site_id;

               OPEN c_party_site(l_party_site_id);
               FETCH c_party_site
	       INTO l_party_id,
	       l_status;

	       IF c_party_site%NOTFOUND THEN
	          l_return_status := FND_API.G_RET_STS_ERROR;
	          x_return_status := FND_API.G_RET_STS_ERROR;
	          IF l_debug_level  > 0 THEN
	             oe_debug_pub.add(  'no such party site id' ) ;
	          END IF;
	         CLOSE c_party_site;

	        IF l_site_use_code = 'SHIP_TO' then
	           FND_MESSAGE.Set_Name('ONT','ONT_AAC_NO_SHIPTO');
	        ELSIF l_site_use_code = 'BILL_TO' then
	           FND_MESSAGE.Set_Name('ONT','ONT_AAC_NO_BILLTO');
	        ELSIF l_site_use_code = 'DELIVER_TO' then
	           FND_MESSAGE.Set_Name('ONT','ONT_AAC_NO_DELIVERTO');
	        END IF;

	        OE_MSG_PUB.ADD;
	        IF p_continue_on_error THEN
	          null;
	        ELSE
	          OE_MSG_PUB.Count_And_Get
		  (   p_count                       => x_msg_count
		    ,   p_data                        => x_msg_data
		    );
	           return;
	        END IF;

	      ELSIF c_party_site%FOUND THEN

	        IF l_debug_level  > 0 THEN
	          oe_debug_pub.add(  'found for party_site_id ' ) ;
	        END IF;

	        IF l_status <> 'A' THEN

	          x_return_status := FND_API.G_RET_STS_ERROR;
	          l_return_status := FND_API.G_RET_STS_ERROR;

	          IF l_site_use_code = 'SHIP_TO' then
	            FND_MESSAGE.Set_Name('ONT','ONT_AAC_SHIPTO_INACTIVE');
	          ELSIF l_site_use_code = 'BILL_TO' then
	            FND_MESSAGE.Set_Name('ONT','ONT_AAC_BILLTO_INACTIVE');
	          ELSIF l_site_use_code = 'DELIVER_TO' then
	            FND_MESSAGE.Set_Name('ONT','ONT_AAC_DELIVERTO_INACTIVE');
	          END IF;

	          OE_MSG_PUB.ADD;
	          IF l_debug_level  > 0 THEN
                     oe_debug_pub.add(  'party site is not active' ) ;
	          END IF;
	          CLOSE c_party_site;
	          IF p_continue_on_error THEN
	             null;
	          ELSE
                     OE_MSG_PUB.Count_And_Get
	             (   p_count                       => x_msg_count
		     ,   p_data                        => x_msg_data
		     );
                     return;
	          END IF;

                END IF; -- if status is not active

                oe_debug_pub.add('px: '||px_party_id||' l_party:'||l_party_id);

                IF px_party_id <> l_party_id THEN
	           x_return_status := FND_API.G_RET_STS_ERROR;
	           l_return_status := FND_API.G_RET_STS_ERROR;

	           IF l_site_use_code = 'SHIP_TO' then
                      FND_MESSAGE.Set_Name('ONT','ONT_AAC_SHIPTO_ACCOUNT');
	           ELSIF l_site_use_code = 'BILL_TO' then
                      FND_MESSAGE.Set_Name('ONT','ONT_AAC_BILLTO_ACCOUNT');
	           ELSIF l_site_use_code = 'DELIVER_TO' then
                      FND_MESSAGE.Set_Name('ONT','ONT_AAC_DELIVERTO_ACCOUNT');
	           END IF;

	           OE_MSG_PUB.ADD;
	           IF l_debug_level  > 0 THEN
	             oe_debug_pub.add(  'party site does not belong to the party' ) ;
	           END IF;

		   CLOSE c_party_site;
	           IF p_continue_on_error THEN
                      null;
	           ELSE
                      OE_MSG_PUB.Count_And_Get
	              (   p_count                       => x_msg_count
		      ,   p_data                        => x_msg_data
		       );
                      return;
	           END IF;
                END IF; -- if party_id does not match

                IF c_party_site%ISOPEN THEN
	          CLOSE c_party_site;
                END IF;

             END IF; -- if party_site_id found

           ELSE -- if party_site_id is null
	   oe_debug_pub.add( 'Yes.. Party_Site_id is not null');
	      if l_end_customer_passed ='N' then -- if its not end customer(4240715)
              x_return_status := FND_API.G_RET_STS_ERROR;
              l_return_status := FND_API.G_RET_STS_ERROR;
              FND_MESSAGE.Set_Name('ONT','ONT_AVAIL_GENERIC');
              FND_MESSAGE.Set_Token('TEXT','Not a Valid Account Site ', FALSE);
              OE_MSG_PUB.ADD;
              IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(  'no site information is sent ' ) ;
              END IF;
             IF p_continue_on_error THEN
                null;
             ELSE
                OE_MSG_PUB.Count_And_Get
	         (   p_count                       => x_msg_count
	         ,   p_data                        => x_msg_data
	          );
                 return;
             END IF;
	     end if; -- as long as its not end customer(4240715)
          END IF; -- if party_site_id not null
        END IF; -- if l_party_site_id is null
      ELSE
	 oe_debug_pub.add('Have got the primary_party_site_use_id');
      END IF;


   ELSE --G_fetch_primary_party_sites =FALSE
    -- existing logic


 -- Determining the Site Use Code
 -- Either party_site_use_id should be passed or
 -- party_site_id and site_use_code should be passed
 IF  p_site_tbl(i).p_party_site_use_id IS NOT NULL THEN

    IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'checking for party_site_use_id ='|| P_SITE_TBL ( I ) .P_PARTY_SITE_USE_ID ) ;
    END IF;
    OPEN c_party_site_use(p_site_tbl(i).p_party_site_use_id);
    FETCH c_party_site_use
       INTO l_site_use_code,
       l_party_site_id,
       l_primary_per_type;

    IF c_party_site_use%NOTFOUND THEN
       l_return_status := FND_API.G_RET_STS_ERROR;
       x_return_status := FND_API.G_RET_STS_ERROR;
       IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'not a valid party site use id' ) ;
       END IF;

       IF l_site_use_code = 'SHIP_TO' then
	  FND_MESSAGE.Set_Name('ONT','ONT_AAC_NO_SHIPTO');
       ELSIF l_site_use_code = 'BILL_TO' then
	  FND_MESSAGE.Set_Name('ONT','ONT_AAC_NO_BILLTO');
       ELSIF l_site_use_code = 'DELIVER_TO' then
	  FND_MESSAGE.Set_Name('ONT','ONT_AAC_NO_DELIVERTO');
       END IF;

       OE_MSG_PUB.ADD;
       CLOSE c_party_site_use;

       IF p_continue_on_error THEN
	  null;
       ELSE
	  OE_MSG_PUB.Count_And_Get
	     (   p_count                       => x_msg_count
		 ,   p_data                        => x_msg_data
		 );
	  return;
       END IF;
    ELSIF c_party_site_use%FOUND THEN
       p_site_tbl(i).p_party_site_id := l_party_site_id;
    END IF;

    IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  ' site_use_code = '||L_SITE_USE_CODE ) ;
    END IF;
    -- site use code has to be passed in the control record
    -- because we can make a party site as a account site of bill,ship,deliver
    -- even if the party site use is STMNTS or others
    --p_site_tbl(i).p_site_use_code := l_site_use_code;

    IF c_party_site_use%ISOPEN THEN
       CLOSE c_party_site_use;
    END IF;

 END IF; -- if party_site_use_id is not null

 -- if party_site_id is sent
 IF l_party_site_id is null AND
    x_return_status <> FND_API.G_RET_STS_ERROR then
    IF p_site_tbl(i).p_party_site_id is not null then
       IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'checking for party_site_id ' ) ;
       END IF;
       l_party_site_id := p_site_tbl(i).p_party_site_id;

       OPEN c_party_site(l_party_site_id);
       FETCH c_party_site
	  INTO l_party_id,
	  l_status;
       IF c_party_site%NOTFOUND THEN
	  l_return_status := FND_API.G_RET_STS_ERROR;
	  x_return_status := FND_API.G_RET_STS_ERROR;
	  IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'no such party site id' ) ;
	  END IF;
	  CLOSE c_party_site;

	  IF l_site_use_code = 'SHIP_TO' then
	     FND_MESSAGE.Set_Name('ONT','ONT_AAC_NO_SHIPTO');
	  ELSIF l_site_use_code = 'BILL_TO' then
	     FND_MESSAGE.Set_Name('ONT','ONT_AAC_NO_BILLTO');
	  ELSIF l_site_use_code = 'DELIVER_TO' then
	     FND_MESSAGE.Set_Name('ONT','ONT_AAC_NO_DELIVERTO');
	  END IF;

	  OE_MSG_PUB.ADD;
	  IF p_continue_on_error THEN
	     null;
	  ELSE
	     OE_MSG_PUB.Count_And_Get
		(   p_count                       => x_msg_count
		    ,   p_data                        => x_msg_data
		    );
	     return;
	  END IF;
       ELSIF c_party_site%FOUND THEN

	  IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'found for party_site_id ' ) ;
	  END IF;
        IF l_status <> 'A' THEN

	   x_return_status := FND_API.G_RET_STS_ERROR;
	   l_return_status := FND_API.G_RET_STS_ERROR;

	   IF l_site_use_code = 'SHIP_TO' then
	      FND_MESSAGE.Set_Name('ONT','ONT_AAC_SHIPTO_INACTIVE');
	   ELSIF l_site_use_code = 'BILL_TO' then
	      FND_MESSAGE.Set_Name('ONT','ONT_AAC_BILLTO_INACTIVE');
	   ELSIF l_site_use_code = 'DELIVER_TO' then
	      FND_MESSAGE.Set_Name('ONT','ONT_AAC_DELIVERTO_INACTIVE');
	   END IF;

	   OE_MSG_PUB.ADD;
	   IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  'party site is not active' ) ;
	   END IF;
	   CLOSE c_party_site;
	   IF p_continue_on_error THEN
	      null;
	   ELSE
            OE_MSG_PUB.Count_And_Get
	       (   p_count                       => x_msg_count
		   ,   p_data                        => x_msg_data
		   );
            return;
	 END IF;

      END IF; -- if status is not active

      oe_debug_pub.add('px: '||px_party_id||' l_party:'||l_party_id);

      IF px_party_id <> l_party_id THEN
	 x_return_status := FND_API.G_RET_STS_ERROR;
	 l_return_status := FND_API.G_RET_STS_ERROR;

	 IF l_site_use_code = 'SHIP_TO' then
            FND_MESSAGE.Set_Name('ONT','ONT_AAC_SHIPTO_ACCOUNT');
	 ELSIF l_site_use_code = 'BILL_TO' then
            FND_MESSAGE.Set_Name('ONT','ONT_AAC_BILLTO_ACCOUNT');
	 ELSIF l_site_use_code = 'DELIVER_TO' then
            FND_MESSAGE.Set_Name('ONT','ONT_AAC_DELIVERTO_ACCOUNT');
	 END IF;

	 OE_MSG_PUB.ADD;
	 IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'party site does not belong to the party' ) ;
	 END IF;
	 CLOSE c_party_site;
	 IF p_continue_on_error THEN
            null;
	 ELSE
            OE_MSG_PUB.Count_And_Get
	       (   p_count                       => x_msg_count
		   ,   p_data                        => x_msg_data
		   );
            return;
	 END IF;
      END IF; -- if party_id does not match

      IF c_party_site%ISOPEN THEN
	 CLOSE c_party_site;
      END IF;

   END IF; -- if party_site_id found

ELSE -- if party_site_id is null
	   oe_debug_pub.add( 'Yes.. Party_Site_id is not null.. Second');
  if l_end_customer_passed ='N' then -- if its not end customer(bug 4240715)
   x_return_status := FND_API.G_RET_STS_ERROR;
   l_return_status := FND_API.G_RET_STS_ERROR;
   FND_MESSAGE.Set_Name('ONT','ONT_AVAIL_GENERIC');
   FND_MESSAGE.Set_Token('TEXT','Not a Valid Account Site ', FALSE);
   OE_MSG_PUB.ADD;
   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'no site information is sent ' ) ;
   END IF;
   IF p_continue_on_error THEN
      null;
   ELSE
      OE_MSG_PUB.Count_And_Get
	 (   p_count                       => x_msg_count
	     ,   p_data                        => x_msg_data
	     );
      return;
   END IF;
   End If; --if its not end customer
END IF; -- if party_site_id not null
END IF; -- if l_party_site_id is null

IF l_debug_level  > 0 THEN
   oe_debug_pub.add(  ' l_party_site_id ='||l_party_site_id|| ' l_site_use_code ='||L_SITE_USE_CODE ) ;
END IF;


END IF; --G_fetch_primary_party_sites

--{added for bug 4240715
 --------------------------

-- added for end customer /* check done based on the order SOLD_TO,SHIP_TO,BILL_TO,DELIVER_TO */
     if l_site_use_code ='END_CUST' then
	OPEN c_endcust_party_site_use(l_party_site_id,'SOLD_TO');
	FETCH c_endcust_party_site_use
	    INTO lx_party_site_use_id;

	if c_endcust_party_site_use%FOUND then
	   oe_debug_pub.add('Checking for end customer of type SOLD_TO');
	   l_site_use_code :='SOLD_TO';
	   	   goto end_customer_site_use_found;
	Else -- not sold to
	   close c_endcust_party_site_use;
	end if; -- sold to check;

OPEN c_endcust_party_site_use(l_party_site_id,'SHIP_TO');
	FETCH c_endcust_party_site_use
	    INTO lx_party_site_use_id;

	if c_endcust_party_site_use%FOUND then
	   oe_debug_pub.add('Checking for end customer of type SHIP_TO');
	   l_site_use_code :='SHIP_TO';
	   	   goto end_customer_site_use_found;
	Else -- not sold to
	   close c_endcust_party_site_use;
	end if; -- sold to check;
	OPEN c_endcust_party_site_use(l_party_site_id,'BILL_TO');
	FETCH c_endcust_party_site_use
	    INTO lx_party_site_use_id;

	if c_endcust_party_site_use%FOUND then
	   oe_debug_pub.add('Checking for end customer of type BILL_TO');
	   l_site_use_code :='BILL_TO';
	   	   goto end_customer_site_use_found;
	Else -- not sold to
	   close c_endcust_party_site_use;
	end if; -- sold to check;
 OPEN c_endcust_party_site_use(l_party_site_id,'DELIVER_TO');
	FETCH c_endcust_party_site_use
	    INTO lx_party_site_use_id;

	if c_endcust_party_site_use%FOUND then
	   oe_debug_pub.add('Checking for end customer of type DELIVER_TO');
	   l_site_use_code :='DELIVER_TO';
	   	   goto end_customer_site_use_found;
	Else -- not sold to
	   close c_endcust_party_site_use;
	end if; -- sold to check;
	oe_debug_pub.add('Site use code selected for end customer is'||l_site_use_code);
	END IF;
--------------------------------

<<end_customer_site_use_found>>


     IF x_return_status = FND_API.G_RET_STS_SUCCESS and l_site_use_code <>'END_CUST'  THEN


	IF l_debug_level  > 0 THEN
	   oe_debug_pub.add(  ' continuing processing' ) ;
	end if;
	-- fetch the account_site_id
	IF p_site_tbl(i).p_create_primary_acct_site_use then
	   l_send_primary := 'Y';
	ELSE
	   l_send_primary := 'N';
	END IF;

	OPEN c_acct_site(px_cust_account_id,l_party_site_id,l_site_use_code);
	FETCH c_acct_site
	    INTO l_cust_acct_site_id,
		 l_site_use_id,
		 l_site_use_primary_flag;
	IF c_acct_site%FOUND THEN

	   IF l_debug_level  > 0 THEN
	      oe_debug_pub.add(  ' account site found = '||L_SITE_USE_ID ) ;
	   END IF;
	   IF l_site_use_id IS NULL THEN
	      IF l_debug_level  > 0 THEN
		 oe_debug_pub.add(  'make a call to create account site use' ) ;
	      END IF;
	      -- make a call to create account site use

	      IF p_allow_site_creation then
		 oe_oe_inline_address.Create_Acct_Site_Uses
		    (
		     p_cust_acct_site_id =>l_cust_acct_site_id,
		     p_location   =>null,
		     p_site_use_code   =>l_site_use_code,
		     x_site_use_id =>l_site_use_id  ,
		     x_return_status   => x_return_status,
		     x_msg_count       => x_msg_count,
		     x_msg_data        => x_msg_data,
		     c_attribute_category=>null,
		     c_attribute1=>null,
		     c_attribute2=>null,
		     c_attribute3=>null,
		     c_attribute4=>null,
		     c_attribute5=>null,
		     c_attribute6=>null,
		     c_attribute7=>null,
		     c_attribute8=>null,
		     c_attribute9=>null,
		     c_attribute10=>null,
		     c_attribute11=>null,
		     c_attribute12=>null,
		     c_attribute13=>null,
		     c_attribute14=>null,
		     c_attribute15=>null,
		     c_attribute16=>null,
		     c_attribute17=>null,
		     c_attribute18=>null,
		     c_attribute19=>null,
		     c_attribute20=>null,
		     c_attribute21=>null,
		     c_attribute22=>null,
		     c_attribute23=>null,
		     c_attribute24=>null,
		     c_attribute25=>null,
		     in_created_by_module=>G_CREATED_BY_MODULE,
		     in_primary_flag =>l_send_primary
		     );
		 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		    CLOSE c_acct_site;
		    IF l_debug_level  > 0 THEN
		       oe_debug_pub.add(  ' account site use creation failed' ) ;
		    END IF;
		    IF l_debug_level  > 0 THEN
		       oe_debug_pub.add(  ' error = '||X_MSG_DATA||' count = '||X_MSG_COUNT ) ;
		    END IF;

		    x_return_status := FND_API.G_RET_STS_ERROR;
		    l_return_status := FND_API.G_RET_STS_ERROR;

		    IF x_msg_count = 1 then

		       IF l_site_use_code = 'SHIP_TO' then
			  FND_MESSAGE.Set_Name('ONT','ONT_AAC_SHIPTO_SITE_CREATION');
		       ELSIF l_site_use_code = 'BILL_TO' then
			  FND_MESSAGE.Set_Name('ONT','ONT_AAC_BILLTO_SITE_CREATION');
		       ELSIF l_site_use_code = 'DELIVER_TO' then
			  FND_MESSAGE.Set_Name('ONT','ONT_AAC_DELIVERTO_SITE_CREATION');
		       END IF;

		       FND_MESSAGE.Set_Token('TCA_MESSAGE',x_msg_data, FALSE);
		       OE_MSG_PUB.ADD;
		    ELSE
		       oe_msg_pub.transfer_msg_stack;
		    END IF;

		    IF p_continue_on_error THEN
		       null;
		    ELSE
		       return;
		    END IF;
		 END IF;
	      ELSE
		 x_return_status := FND_API.G_RET_STS_ERROR;
		 l_return_status := FND_API.G_RET_STS_ERROR;
		 FND_MESSAGE.Set_Name('ONT','ONT_AAC_SITE_PERMISSION');
		 OE_MSG_PUB.ADD;
		 IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  ' not authorized to create site' ) ;
		 END IF;
		 CLOSE c_acct_site;
		 IF p_continue_on_error THEN
		    null;
		 ELSE
		    return;
		 END IF;
	      END IF; -- if permission to create sites

	   END IF; -- if site_use_id is null;
	ELSIF c_acct_site%NOTFOUND THEN

	   -- make a call to create acct site and account site use
	   IF l_debug_level  > 0 THEN
	      oe_debug_pub.add(  'make a call to create acct site and use' ) ;
	   END IF;

	   IF p_allow_site_creation THEN

	      IF l_debug_level  > 0 THEN
		 oe_debug_pub.add(  ' creating account site' ) ;
	      end IF;
	      oe_oe_inline_address.Create_Account_Site
		 (
		  p_cust_account_id =>px_cust_account_id,
		  p_party_site_id   =>l_party_site_id,
		  c_attribute_category=>null,
		  c_attribute1=>null,
		  c_attribute2=>null,
		  c_attribute3=>null,
		  c_attribute4=>null,
		  c_attribute5=>null,
		  c_attribute6=>null,
		  c_attribute7=>null,
		  c_attribute8=>null,
		  c_attribute9=>null,
		  c_attribute10=>null,
		  c_attribute11=>null,
		  c_attribute12=>null,
		  c_attribute13=>null,
		  c_attribute14=>null,
		  c_attribute15=>null,
		  c_attribute16=>null,
		  c_attribute17=>null,
		  c_attribute18=>null,
		  c_attribute19=>null,
		  c_attribute20=>null,
		  x_customer_site_id =>l_cust_acct_site_id ,
		  x_return_status   => x_return_status,
		  x_msg_count       => x_msg_count,
		  x_msg_data        => x_msg_data,
		  in_created_by_module=>G_CREATED_BY_MODULE
                  ) ;
	      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		 CLOSE c_acct_site;
		 l_return_status := FND_API.G_RET_STS_ERROR;
		 IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  ' account site creation failed' ) ;
		    oe_debug_pub.add(  ' error = '||X_MSG_DATA||' count = '||X_MSG_COUNT ) ;
		 END IF;
		 IF x_msg_count = 1 then

		    IF l_site_use_code = 'SHIP_TO' then
		       FND_MESSAGE.Set_Name('ONT','ONT_AAC_SHIPTO_SITE_CREATION');
		    ELSIF l_site_use_code = 'BILL_TO' then
		       FND_MESSAGE.Set_Name('ONT','ONT_AAC_BILLTO_SITE_CREATION');
		    ELSIF l_site_use_code = 'DELIVER_TO' then
		       FND_MESSAGE.Set_Name('ONT','ONT_AAC_DELIVERTO_SITE_CREATION');
		    END IF;

		    FND_MESSAGE.Set_Token('TCA_MESSAGE',x_msg_data, FALSE);
		    OE_MSG_PUB.ADD;
		 ELSE
		    oe_msg_pub.transfer_msg_stack;
		 END IF;
		 IF p_continue_on_error THEN
		    null;
		 ELSE
		    return;
		 END IF;

	      ELSE

		 IF l_debug_level  > 0 THEN
		    oe_debug_pub.add(  ' acct_site_id created = '||L_CUST_ACCT_SITE_ID ) ;
		 END IF;
		 oe_oe_inline_address.Create_Acct_Site_Uses
		    (
		     p_cust_acct_site_id =>l_cust_acct_site_id,
		     p_location   =>null,
		     p_site_use_code   =>l_site_use_code,
		     x_site_use_id =>l_site_use_id  ,
		     x_return_status   => x_return_status,
		     x_msg_count       => x_msg_count,
		     x_msg_data        => x_msg_data,
		     c_attribute_category=>null,
		     c_attribute1=>null,
		     c_attribute2=>null,
		     c_attribute3=>null,
		     c_attribute4=>null,
		     c_attribute5=>null,
		     c_attribute6=>null,
		     c_attribute7=>null,
		     c_attribute8=>null,
		     c_attribute9=>null,
		     c_attribute10=>null,
		     c_attribute11=>null,
		     c_attribute12=>null,
		     c_attribute13=>null,
		     c_attribute14=>null,
		     c_attribute15=>null,
		     c_attribute16=>null,
		     c_attribute17=>null,
		     c_attribute18=>null,
		     c_attribute19=>null,
		     c_attribute20=>null,
		     c_attribute21=>null,
		     c_attribute22=>null,
		     c_attribute23=>null,
		     c_attribute24=>null,
		     c_attribute25=>null,
		     in_created_by_module=>G_CREATED_BY_MODULE,
		     in_primary_flag =>l_send_primary
		     );

		 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		    l_return_status := FND_API.G_RET_STS_ERROR;
		    CLOSE c_acct_site;
		    IF l_debug_level  > 0 THEN
		       oe_debug_pub.add(  ' account site use creation failed' ) ;
		       oe_debug_pub.add(  'error = '||x_msg_data||' count = '||x_MSG_COUNT ) ;
		    END IF;
		    IF x_msg_count = 1 then
		       IF l_debug_level  > 0 THEN
			  oe_debug_pub.add(  ' adding to message stack' ) ;
		       END IF;

		       IF l_site_use_code = 'SHIP_TO' then
			  FND_MESSAGE.Set_Name('ONT','ONT_AAC_SHIPTO_SITE_CREATION');
		       ELSIF l_site_use_code = 'BILL_TO' then
			  FND_MESSAGE.Set_Name('ONT','ONT_AAC_BILLTO_SITE_CREATION');
		       ELSIF l_site_use_code = 'DELIVER_TO' then
			  FND_MESSAGE.Set_Name('ONT','ONT_AAC_DELIVERTO_SITE_CREATION');
		       END IF;

		       FND_MESSAGE.Set_Token('TCA_MESSAGE',x_msg_data, FALSE);
		       OE_MSG_PUB.ADD;
		    ELSE
		       IF l_debug_level  > 0 THEN
			  oe_debug_pub.add(  ' transferring to message stack' ) ;
		       END IF;
		       oe_msg_pub.transfer_msg_stack;
		    END IF;
		    IF p_continue_on_error THEN
		       null;
		    ELSE
		       return;
		    END IF;

		 END IF;

	      END IF; -- if acct site creation succeeded

	   ELSE

	      x_return_status := FND_API.G_RET_STS_ERROR;
	      l_return_status := FND_API.G_RET_STS_ERROR;
	      FND_MESSAGE.Set_Name('ONT','ONT_AAC_SITE_PERMISSION');
	      OE_MSG_PUB.ADD;
	      IF l_debug_level  > 0 THEN
		 oe_debug_pub.add(  '2 not allowed to create site' ) ;
	      END IF;
	      CLOSE c_acct_site;
	      IF p_continue_on_error THEN
		 null;
	      ELSE
		 return;
	      END IF;

	   END IF; -- if allow site creation

	END IF; -- if cursor found

	IF c_acct_site%ISOPEN THEN
	   CLOSE c_acct_site;
	END IF;

     END IF; -- if status is success

     IF l_debug_level  > 0 THEN
	oe_debug_pub.add(  ' assinging site table site_id = '||l_site_use_id|| ' acct site_id = '||L_CUST_ACCT_SITE_ID ) ;
     END IF;


 -- END IF; -- if site_use_id is passed
   --**

--bug 4240715}



/*cc project*/

IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  ' continuing processing' ) ;
   end if;
   -- fetch the account_site_id
   IF p_site_tbl(i).p_create_primary_acct_site_use then
      l_send_primary := 'Y';
   ELSE
      l_send_primary := 'N';
   END IF;

   OPEN c_acct_site(px_cust_account_id,l_party_site_id,l_site_use_code);
   FETCH c_acct_site
      INTO l_cust_acct_site_id,
      l_site_use_id,
      l_site_use_primary_flag;
   IF c_acct_site%FOUND THEN

      IF l_debug_level  > 0 THEN
	 oe_debug_pub.add(  ' account site found = '||L_SITE_USE_ID ) ;
      END IF;
      IF l_site_use_id IS NULL THEN
        IF l_debug_level  > 0 THEN
	   oe_debug_pub.add(  'make a call to create account site use' ) ;
        END IF;
        -- make a call to create account site use

        IF p_allow_site_creation then
	   oe_oe_inline_address.Create_Acct_Site_Uses
	      (
	       p_cust_acct_site_id =>l_cust_acct_site_id,
	       p_location   =>null,
	       p_site_use_code   =>l_site_use_code,
	       x_site_use_id =>l_site_use_id  ,
	       x_return_status   => x_return_status,
	       x_msg_count       => x_msg_count,
	       x_msg_data        => x_msg_data,
	       c_attribute_category=>null,
	       c_attribute1=>null,
	       c_attribute2=>null,
	       c_attribute3=>null,
	       c_attribute4=>null,
	       c_attribute5=>null,
	       c_attribute6=>null,
	       c_attribute7=>null,
	       c_attribute8=>null,
	       c_attribute9=>null,
	       c_attribute10=>null,
                 c_attribute11=>null,
                 c_attribute12=>null,
                 c_attribute13=>null,
                 c_attribute14=>null,
                 c_attribute15=>null,
                 c_attribute16=>null,
                 c_attribute17=>null,
                 c_attribute18=>null,
                 c_attribute19=>null,
                 c_attribute20=>null,
                 c_attribute21=>null,
                 c_attribute22=>null,
                 c_attribute23=>null,
                 c_attribute24=>null,
                 c_attribute25=>null,
                 in_created_by_module=>G_CREATED_BY_MODULE,
	       in_primary_flag =>l_send_primary
	       );
	   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	      CLOSE c_acct_site;
	      IF l_debug_level  > 0 THEN
		 oe_debug_pub.add(  ' account site use creation failed' ) ;
	      END IF;
	      IF l_debug_level  > 0 THEN
		 oe_debug_pub.add(  ' error = '||X_MSG_DATA||' count = '||X_MSG_COUNT ) ;
	      END IF;

	      x_return_status := FND_API.G_RET_STS_ERROR;
	      l_return_status := FND_API.G_RET_STS_ERROR;

	      IF x_msg_count = 1 then

		 IF l_site_use_code = 'SHIP_TO' then
		    FND_MESSAGE.Set_Name('ONT','ONT_AAC_SHIPTO_SITE_CREATION');
		 ELSIF l_site_use_code = 'BILL_TO' then
		    FND_MESSAGE.Set_Name('ONT','ONT_AAC_BILLTO_SITE_CREATION');
		 ELSIF l_site_use_code = 'DELIVER_TO' then
		    FND_MESSAGE.Set_Name('ONT','ONT_AAC_DELIVER_SITE_CREATION');
		 END IF;

		 FND_MESSAGE.Set_Token('TCA_MESSAGE',x_msg_data, FALSE);
		 OE_MSG_PUB.ADD;
	      ELSE
		 oe_msg_pub.transfer_msg_stack;
	      END IF;

	      IF p_continue_on_error THEN
		 null;
	      ELSE
		 return;
	      END IF;
	   END IF;
        ELSE
	   x_return_status := FND_API.G_RET_STS_ERROR;
	   l_return_status := FND_API.G_RET_STS_ERROR;
	   FND_MESSAGE.Set_Name('ONT','ONT_AAC_SITE_PERMISSION');
	   OE_MSG_PUB.ADD;
	   IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  ' not authorized to create site' ) ;
	   END IF;
	   CLOSE c_acct_site;
	   IF p_continue_on_error THEN
	      null;
	   ELSE
	      return;
	   END IF;
        END IF; -- if permission to create sites

     END IF; -- if site_use_id is null;
  ELSIF c_acct_site%NOTFOUND THEN

     -- make a call to create acct site and account site use
     IF l_debug_level  > 0 THEN
	oe_debug_pub.add(  'make a call to create acct site and use' ) ;
     END IF;

     IF p_allow_site_creation THEN

        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  ' creating account site' ) ;
        end IF;
        oe_oe_inline_address.Create_Account_Site
                  (
                 p_cust_account_id =>px_cust_account_id,
                 p_party_site_id   =>l_party_site_id,
                 c_attribute_category=>null,
                 c_attribute1=>null,
                 c_attribute2=>null,
                 c_attribute3=>null,
                 c_attribute4=>null,
                 c_attribute5=>null,
                 c_attribute6=>null,
                 c_attribute7=>null,
                 c_attribute8=>null,
                 c_attribute9=>null,
                 c_attribute10=>null,
                 c_attribute11=>null,
                 c_attribute12=>null,
                 c_attribute13=>null,
                 c_attribute14=>null,
                 c_attribute15=>null,
                 c_attribute16=>null,
                 c_attribute17=>null,
                 c_attribute18=>null,
                 c_attribute19=>null,
                 c_attribute20=>null,
                 x_customer_site_id =>l_cust_acct_site_id ,
                 x_return_status   => x_return_status,
                 x_msg_count       => x_msg_count,
                 x_msg_data        => x_msg_data,
                 in_created_by_module=>G_CREATED_BY_MODULE
                  ) ;
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          CLOSE c_acct_site;
          l_return_status := FND_API.G_RET_STS_ERROR;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  ' account site creation failed' ) ;
              oe_debug_pub.add(  ' error = '||X_MSG_DATA||' count = '||X_MSG_COUNT ) ;
          END IF;
          IF x_msg_count = 1 then

              IF l_site_use_code = 'SHIP_TO' then
                FND_MESSAGE.Set_Name('ONT','ONT_AAC_SHIPTO_SITE_CREATION');
              ELSIF l_site_use_code = 'BILL_TO' then
                FND_MESSAGE.Set_Name('ONT','ONT_AAC_BILLTO_SITE_CREATION');
              ELSIF l_site_use_code = 'DELIVER_TO' then
                FND_MESSAGE.Set_Name('ONT','ONT_AAC_DELIVER_SITE_CREATION');
              END IF;

              FND_MESSAGE.Set_Token('TCA_MESSAGE',x_msg_data, FALSE);
              OE_MSG_PUB.ADD;
          ELSE
            oe_msg_pub.transfer_msg_stack;
          END IF;
          IF p_continue_on_error THEN
            null;
          ELSE
            return;
          END IF;

        ELSE

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(  ' acct_site_id created = '||L_CUST_ACCT_SITE_ID ) ;
          END IF;
          oe_oe_inline_address.Create_Acct_Site_Uses
                  (
                 p_cust_acct_site_id =>l_cust_acct_site_id,
                 p_location   =>null,
                 p_site_use_code   =>l_site_use_code,
                 x_site_use_id =>l_site_use_id  ,
                 x_return_status   => x_return_status,
                 x_msg_count       => x_msg_count,
                 x_msg_data        => x_msg_data,
                 c_attribute_category=>null,
                 c_attribute1=>null,
                 c_attribute2=>null,
                 c_attribute3=>null,
                 c_attribute4=>null,
                 c_attribute5=>null,
                 c_attribute6=>null,
                 c_attribute7=>null,
                 c_attribute8=>null,
                 c_attribute9=>null,
                 c_attribute10=>null,
                 c_attribute11=>null,
                 c_attribute12=>null,
                 c_attribute13=>null,
                 c_attribute14=>null,
                 c_attribute15=>null,
                 c_attribute16=>null,
                 c_attribute17=>null,
                 c_attribute18=>null,
                 c_attribute19=>null,
                 c_attribute20=>null,
                 c_attribute21=>null,
                 c_attribute22=>null,
                 c_attribute23=>null,
                 c_attribute24=>null,
                 c_attribute25=>null,
                 in_created_by_module=>G_CREATED_BY_MODULE,
                 in_primary_flag =>l_send_primary
                  );

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            l_return_status := FND_API.G_RET_STS_ERROR;
            CLOSE c_acct_site;
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(  ' account site use creation failed' ) ;
                oe_debug_pub.add(  'error = '||x_msg_data||' count = '||x_MSG_COUNT ) ;
            END IF;
            IF x_msg_count = 1 then
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  ' adding to message stack' ) ;
              END IF;

              IF l_site_use_code = 'SHIP_TO' then
                FND_MESSAGE.Set_Name('ONT','ONT_AAC_SHIPTO_SITE_CREATION');
              ELSIF l_site_use_code = 'BILL_TO' then
                FND_MESSAGE.Set_Name('ONT','ONT_AAC_BILLTO_SITE_CREATION');
              ELSIF l_site_use_code = 'DELIVER_TO' then
                FND_MESSAGE.Set_Name('ONT','ONT_AAC_DELIVER_SITE_CREATION');
              END IF;

              FND_MESSAGE.Set_Token('TCA_MESSAGE',x_msg_data, FALSE);
              OE_MSG_PUB.ADD;
            ELSE
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add(  ' transferring to message stack' ) ;
              END IF;
              oe_msg_pub.transfer_msg_stack;
            END IF;
            IF p_continue_on_error THEN
              null;
            ELSE
              return;
            END IF;

          END IF;

        END IF; -- if acct site creation succeeded

      ELSE

        x_return_status := FND_API.G_RET_STS_ERROR;
        l_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name('ONT','ONT_AAC_SITE_PERMISSION');
        OE_MSG_PUB.ADD;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  '2 not allowed to create site' ) ;
        END IF;
        CLOSE c_acct_site;
        IF p_continue_on_error THEN
          null;
        ELSE
          return;
        END IF;

      END IF; -- if allow site creation

    END IF; -- if cursor found

    IF c_acct_site%ISOPEN THEN
      CLOSE c_acct_site;
    END IF;

  END IF; -- if status is success

                   IF l_debug_level  > 0 THEN
                       oe_debug_pub.add(  ' assinging site table site_id = '||l_site_use_id|| ' acct site_id = '||L_CUST_ACCT_SITE_ID ) ;
                   END IF;
 END IF; -- if site_use_id is passed

<<end_customer_found>>		--added for bug 4240715
 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN



       IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  ' site not success so copying null' ) ;
   END IF;
   p_site_tbl(i).p_site_use_id := null;
   p_site_tbl(i).p_cust_acct_site_id := null;
 ELSE

    OPEN C_get_cust_from_site_use_id(l_site_use_id);
    FETCH C_get_cust_from_site_use_id
     INTO p_site_tbl(i).p_cust_account_id;

    IF C_get_cust_from_site_use_id%FOUND THEN

       IF l_debug_level  > 0 THEN
	  oe_debug_pub.add(  ' account site found = '||p_site_tbl(i).p_cust_account_id ) ;
       END IF;
    END IF;
    close C_get_cust_from_site_use_id;

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  ' site success so copying actual' ) ;
   END IF;

   p_site_tbl(i).p_site_use_id := l_site_use_id;
   p_site_tbl(i).p_cust_acct_site_id := l_cust_acct_site_id;

 END IF;

 <<skip_site>>
 null;

END LOOP;


x_return_status := l_return_status;

IF x_return_status <> FND_API.G_RET_STS_SUCCESS then
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  ' doing count and get for site' ) ;
  END IF;
        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
END IF;
                 IF l_debug_level  > 0 THEN
                     oe_debug_pub.add(  ' at end of site msg = '||x_msg_data|| ' count = '||x_MSG_COUNT ) ;
                 END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

      IF c_party_site_use%ISOPEN THEN
        CLOSE c_party_site_use;
      END IF;
      IF c_party_site%ISOPEN THEN
        CLOSE c_party_site;
      END IF;
      IF c_acct_site%ISOPEN THEN
        CLOSE c_acct_site;
      END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN


      IF c_party_site_use%ISOPEN THEN
        CLOSE c_party_site_use;
      END IF;
      IF c_party_site%ISOPEN THEN
        CLOSE c_party_site;
      END IF;
      IF c_acct_site%ISOPEN THEN
        CLOSE c_acct_site;
      END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN


      IF c_party_site_use%ISOPEN THEN
        CLOSE c_party_site_use;
      END IF;
      IF c_party_site%ISOPEN THEN
        CLOSE c_party_site;
      END IF;
      IF c_acct_site%ISOPEN THEN
        CLOSE c_acct_site;
      END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                        IF l_debug_level  > 0 THEN
                            oe_debug_pub.add(  'check_and_create_site when other code = '|| sqlcode||' message = '||sqlerrm ) ;
                        END IF;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Check_and_create_sites'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );


END Check_and_Create_Sites;




PROCEDURE  find_contact(
          in_party_id in number
         ,out_org_contact_id out NOCOPY number
         ,out_cust_account_role_id out NOCOPY number
                       ) IS

--
l_debug_level  NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

null;

END find_contact;


PROCEDURE Check_and_Create_Contact(
    p_party_id in number -- used to see if org_contact belongs to this party
   ,p_cust_account_id in number --acct from ct is in account table
   ,p_org_contact_id in number
   ,p_site_use_code in varchar2
   ,p_allow_contact_creation in boolean
   ,p_create_responsibility in boolean
   ,p_cust_account_role_id in out NOCOPY /* file.sql.39 change */ number
   ,p_cust_account_site_id in number
   ,p_assign_contact_to_site in boolean
   ,p_multiple_account_is_error in boolean
   ,p_multiple_contact_is_error in boolean
   ,p_contact_tbl out NOCOPY contact_tbl
   ,p_multiple_account out NOCOPY boolean
   ,x_return_status     OUT  NOCOPY    VARCHAR2
   ,x_msg_count         OUT  NOCOPY    NUMBER
   ,x_msg_data          OUT  NOCOPY    VARCHAR2
  ) IS


CURSOR c_get_cust_id(in_cust_account_role_id in number) IS
  SELECT cust_account_id
    FROM hz_cust_account_roles
   where cust_account_role_id = in_cust_account_role_id;

CURSOR  c_cust_role_site( in_cust_account_role_id in number) IS
  SELECT status,
         role_type,
         cust_account_id,
         cust_acct_site_id
    FROM hz_cust_account_roles
   where cust_account_role_id = in_cust_account_role_id;

CURSOR  c_cust_account_role( in_cust_account_role_id in number) IS
  SELECT cust_acct_site_id,
         status,
         role_type,
         cust_account_id
    FROM hz_cust_account_roles
   where cust_account_role_id = in_cust_account_role_id;

CURSOR c_org_contact(in_org_contact_id in number,
                     in_cust_account_id in number) IS
  SELECT role.cust_account_role_id,
         role.cust_acct_site_id
    FROM hz_org_contacts org,
         hz_relationships rel,
         hz_cust_accounts acct,
         hz_cust_account_roles role
   WHERE org.org_Contact_id = in_org_contact_id
     AND org.party_relationship_id = rel.relationship_id
     AND rel.object_id=acct.party_id
     AND rel.subject_table_name='HZ_PARTIES'
     AND rel.object_table_name='HZ_PARTIES'
     AND acct.cust_account_id = in_cust_account_id
     and role.cust_account_id = acct.cust_account_id
     and role.role_type ='CONTACT'
     and role.party_id = rel.party_id
     and acct.status = 'A'
     and role.status = 'A'
     and rel.status = 'A';


CURSOR C_get_cust_id_from_party_id(l_Party_Id NUMBER) IS
  SELECT cust_account_id,account_number
    FROM hz_cust_accounts
   WHERE party_id = l_Party_Id
     and status = 'A';

CURSOR c_check_org_contact(in_party_id in number,in_org_contact_id in number) IS
  SELECT rel.party_id
    FROM hz_org_contacts org,
         hz_relationships rel
   WHERE org.org_contact_id = in_org_contact_id
     AND rel.status = 'A'
     AND rel.relationship_id = org.party_relationship_id
     AND (rel.object_id=in_party_id OR rel.subject_id=in_party_id)
     AND rel.subject_table_name='HZ_PARTIES'
     AND rel.object_table_name='HZ_PARTIES';
     --AND org.status='A'; -- bug 3810361, TCA USAGE GUIDE SAYS THIS IS NOT SUPPORTED IN V2 API, We should instead look at hz_relationships.status

l_party_id       NUMBER := null;
l_org_contact_id number := null;
l_rel_party_id varchar2(100);
l_status varchar2(100);
l_cust_role_site_id number := null;
l_role_type varchar2(100);
l_cust_account_id number := null;
l_account_number varchar2(30);
l_cust_account_role_id number := null;
l_cust_acct_site_id number  := null;
l_multiple_contact boolean := FALSE;
l_return_status varchar2(10);
l_msg_data varchar2(4000);
l_msg_count number;
l_message varchar2(4000);
px_party_id number := null;
px_cust_account_id number := null;

--
l_debug_level  NUMBER := oe_debug_pub.g_debug_level;
l_indent varchar2(5) := '   ';
--
BEGIN
   l_debug_level:=1;
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'entering check_and_create_contact ');
    oe_debug_pub.add(l_indent||' party_id       = '||p_party_id||' cust_id = '||p_cust_account_id);
    oe_debug_pub.add(l_indent||' org_contact_id ='||p_org_contact_id|| ' p_site_use_code = '||p_site_use_code);
    oe_debug_pub.add(l_indent||' p_acct_role_id ='|| p_cust_account_role_id|| ' p_acct_account_site_id = '||
		     p_cust_account_site_id ) ;
  END IF;

  IF l_debug_level  > 0 THEN
     if p_multiple_contact_is_error then
        oe_debug_pub.add(l_indent||  'multiple contact is error' ) ;
     else
        oe_debug_pub.add( l_indent|| 'multiple contact is not error' ) ;
     end if;

     if p_assign_contact_to_site then
        oe_debug_pub.add( l_indent|| 'assign_contact_to_site ' ) ;
     else
        oe_debug_pub.add(l_indent||  'not assign_contact_to_site ' ) ;
     end if;

     if p_create_responsibility then
        oe_debug_pub.add(l_indent||  'create responsibility ' ) ;
     else
        oe_debug_pub.add(l_indent||  'not create responsibility ' ) ;
     end if;

     if p_allow_contact_creation then
        oe_debug_pub.add( l_indent|| 'allow_contact_creation ' ) ;
     else
        oe_debug_pub.add( l_indent|| 'not allow_contact_creation ' ) ;
     END IF;
  END IF;


  x_return_status := FND_API.G_RET_STS_SUCCESS;
  p_contact_tbl.DELETE;
  p_multiple_account := FALSE;


  -- atleast some kind of account information is needed
  IF p_cust_account_id is  null AND
     p_cust_account_role_id is null then
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(l_indent||  ' not a valid call to check contact' ) ;
    END IF;
    return;

  END IF;

  -- getting the cust account id
  IF p_cust_account_id is  null AND
     p_cust_account_role_id is not null then

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  l_indent||' getting account from contact information' ) ;
    end IF;
    OPEN c_get_cust_id(p_cust_account_role_id);
    FETCH c_get_cust_id
     INTO l_cust_account_id;

    IF c_get_cust_id%NOTFOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add( l_indent|| 'not a valid cust account role id' ) ;
      END IF;
      FND_MESSAGE.Set_Name('ONT', 'ONT_AAC_NO_CONTACT');
      OE_MSG_PUB.ADD;

      CLOSE c_get_cust_id;
        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

      return;

    END IF;

    CLOSE c_get_cust_id;
  END IF;

  -- we get cust_account_id from role_id if found above
  IF l_cust_account_id is null then
    l_cust_account_id := p_cust_account_id;
  END IF;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add( l_indent|| 'cust_account_id = '||L_CUST_ACCOUNT_ID ) ;
  END IF;

  p_contact_tbl.DELETE;
  IF l_cust_account_id is not null then

    IF p_cust_account_role_id is not null then

      -- if we need to assign the contact to a site, then first we check
      -- if it is already attached to that site
      IF p_assign_contact_to_site and p_cust_account_site_id is not null then
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(l_indent||  'need to assign contact to site' ) ;
        END IF;
        OPEN c_cust_role_site( p_cust_account_role_id);
        FETCH c_cust_role_site
         INTO l_status,
              l_role_type,
              l_cust_account_id,
              l_cust_role_site_id;


        IF c_cust_role_site%NOTFOUND THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add( l_indent|| 'site contact not found' ) ;
          END IF;
          CLOSE c_cust_role_site;

          IF p_create_responsibility then
            --create acct contact and attach site and pass the responsibility
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add( l_indent|| ' 1 not supported currently' ) ;
            end IF;
          ELSE
            --create acct contact and attach site and DO NOT pass responsibility
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add( l_indent|| ' 2 not supported currently' ) ;
            END IF;
          END IF;

        ELSIF c_cust_role_site%FOUND THEN

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(l_indent||  'site contact found' ) ;
          END IF;
          IF l_status <> 'A' then
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add( l_indent|| 'cust account role is not active' ) ;
            END IF;
            CLOSE c_cust_role_site;
            x_return_status := FND_API.G_RET_STS_ERROR;
            return;

          END IF;

          IF l_role_type <> 'CONTACT' then
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add( l_indent|| 'cust account role type is not valid' ) ;
            END IF;
            CLOSE c_cust_role_site;
            x_return_status := FND_API.G_RET_STS_ERROR;
            return;

          END IF;

          IF l_cust_account_id <> p_cust_account_id then
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(l_indent||  'acct role does not belong to this acct' ) ;
            END IF;
            CLOSE c_cust_role_site;
            x_return_status := FND_API.G_RET_STS_ERROR;
            return;
          END IF;


          IF l_cust_role_site_id <> p_cust_account_site_id then
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add( l_indent|| 'Cust account role for site is not valid' ) ;
            END IF;
            CLOSE c_cust_role_site;
            x_return_status := FND_API.G_RET_STS_ERROR;
            return;

          END IF;


          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(l_indent||  'found the contact attached to account site' ) ;
          END IF;
          CLOSE c_cust_role_site;
          p_contact_tbl(1) :=p_cust_account_role_id;
          return;

        END IF;
        CLOSE c_cust_role_site;

      ELSE -- if the contact is not to be assigned to a site

        OPEN  c_cust_account_role(p_cust_account_role_id);
        FETCH c_cust_account_role
         INTO l_cust_role_site_id,
              l_status,
              l_role_type,
              l_cust_account_id;

        IF c_cust_account_role%NOTFOUND then

          CLOSE c_cust_account_role;

          x_return_status := FND_API.G_RET_STS_ERROR;
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(l_indent||  '2 contact_id not found' ) ;
          END IF;
          FND_MESSAGE.Set_Name('ONT', 'ONT_AAC_NO_CONTACT');
          OE_MSG_PUB.ADD;
          OE_MSG_PUB.Count_And_Get
          (   p_count                       => x_msg_count
          ,   p_data                        => x_msg_data
          );
          return;

        ELSIF c_cust_account_role%FOUND then

          IF l_status <> 'A' then
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add( l_indent|| 'cust account role is not active' ) ;
            END IF;
            CLOSE c_cust_account_role;
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.Set_Name('ONT', 'ONT_AAC_INACTIVE_CONTACT');
            OE_MSG_PUB.ADD;
            OE_MSG_PUB.Count_And_Get
            (   p_count                       => x_msg_count
            ,   p_data                        => x_msg_data
            );
            return;

          END IF;

          IF l_role_type <> 'CONTACT' then
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add( l_indent|| 'cust account role type is not valid' ) ;
            END IF;
            CLOSE c_cust_account_role;
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.Set_Name('ONT', 'ONT_AAC_ROLE_CONTACT');
            OE_MSG_PUB.ADD;
            OE_MSG_PUB.Count_And_Get
            (   p_count                       => x_msg_count
            ,   p_data                        => x_msg_data
            );
            return;

          END IF;


          IF l_cust_account_id <> p_cust_account_id then
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add( l_indent|| 'Account role does not belong to this acct' ) ;
            END IF;
            CLOSE c_cust_account_role;
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.Set_Name('ONT', 'ONT_AAC_CONTACT_ACCOUNT');
            OE_MSG_PUB.ADD;
            OE_MSG_PUB.Count_And_Get
            (   p_count                       => x_msg_count
            ,   p_data                        => x_msg_data
            );
            return;
          END IF;

          IF p_create_responsibility then
            --check if resp exists. if not then create one
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add( l_indent|| ' 1 not supported currently' ) ;
            end if;
          END IF;

          IF l_debug_level  > 0 THEN
              oe_debug_pub.add( l_indent|| 'found contact attached to account returning' ) ;
          END IF;
          CLOSE c_cust_account_role;
          p_contact_tbl(1) :=p_cust_account_role_id;
          return;
        END IF; -- if cust_account_role found

        CLOSE c_cust_account_role;

      END IF; -- if contact is to be assigned to the site


    ELSIF p_org_Contact_id is not null  then -- if acct contact not passed

      -- check to see if the incoming party_id is atleast the object or subject
      OPEN c_check_org_contact(p_party_id,p_org_contact_id);
      FETCH c_check_org_contact
       INTO l_rel_party_id;

      IF c_check_org_contact%NOTFOUND then
                         IF l_debug_level  > 0 THEN
                             oe_debug_pub.add(l_indent||  'org contact_id does not belong to sent party or '|| ' contact may be inactive' ) ;
                         END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        CLOSE c_check_org_contact;
        FND_MESSAGE.Set_Name('ONT','ONT_AAC_CONTACT_ACCOUNT');
        OE_MSG_PUB.ADD;
        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
                         IF l_debug_level  > 0 THEN
                             oe_debug_pub.add(l_indent||  ' contact error msg = '||x_msg_data|| '; count = '||x_MSG_COUNT ) ;
                         END IF;

        return;
      END IF;
      CLOSE c_check_org_contact;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(l_indent||  'checking for value of org_contact_id' ) ;
      END IF;
      -- derive customer account
      OPEN c_org_contact(p_org_Contact_id,
                         l_cust_account_id );
      LOOP
        --oe_debug_pub.add('Inside get_cust_role_id loop');
        FETCH c_org_contact
        INTO l_cust_account_role_id,
             l_cust_acct_site_id;
        EXIT WHEN C_org_contact%NOTFOUND;

	IF l_debug_level  > 0 THEN
	   oe_debug_pub.add(l_indent||  'acct_role_id = '||l_cust_account_role_id|| ' cust_acct_site_id = '||L_CUST_ACCT_SITE_ID ) ;
	END IF;

        p_contact_tbl(p_contact_tbl.COUNT + 1):= l_cust_account_role_id;

      END LOOP;

      CLOSE c_org_contact;


      -- IF we are not assigning this contact to a particular site
      -- or a particular responsibility then multiple records is an error
      -- Else we try to match multiple records for that specific type
      IF NOT p_assign_contact_to_site AND
         NOT p_create_responsibility then

        IF p_multiple_contact_is_error THEN

          IF p_contact_tbl.COUNT > 1 then
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add(l_indent||  'error >1 contact for org_contact_id' ) ;
            END IF;
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.Set_Name('ONT','ONT_AVAIL_GENERIC');
            FND_MESSAGE.Set_Token('TEXT',' Multiple Contacts ', FALSE);
            OE_MSG_PUB.ADD;
            OE_MSG_PUB.Count_And_Get
            (   p_count                       => x_msg_count
            ,   p_data                        => x_msg_data
            );
            return;
          END IF;
        END IF; -- if multiple contact is error


        IF p_contact_tbl.COUNT = 1 then
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add( l_indent|| 'RETURNING WITH ONE CONTACT' ) ;
          END IF;
          x_return_status := FND_API.G_RET_STS_SUCCESS;
          return;
        ELSIF p_contact_tbl.COUNT = 0 then
	   IF l_debug_level  > 0 THEN
	      oe_debug_pub.add( l_indent|| 'no contact for account found. creating '|| ' acct_id = '||p_cust_account_id|| ' rel_party_id = '||L_REL_PARTY_ID ) ;
	   END IF;

          IF p_allow_contact_creation THEN

            oe_oe_inline_address.Create_acct_contact
             (
             p_acct_id=>p_cust_account_id,
             p_contact_party_id=>l_rel_party_id,
             x_return_status=>l_return_status,
             x_msg_count=>l_msg_count,
             x_msg_data=>l_msg_data,
             x_contact_id=>p_contact_tbl(1),
             c_attribute_category=>null,
             c_attribute1=>null,
             c_attribute2=>null,
             c_attribute3=>null,
             c_attribute4=>null,
             c_attribute5=>null,
             c_attribute6=>null,
             c_attribute7=>null,
             c_attribute8=>null,
             c_attribute9=>null,
             c_attribute10=>null,
             c_attribute11=>null,
             c_attribute12=>null,
             c_attribute13=>null,
             c_attribute14=>null,
             c_attribute15=>null,
             c_attribute16=>null,
             c_attribute17=>null,
             c_attribute18=>null,
             c_attribute19=>null,
             c_attribute20=>null,
             c_attribute21=>null,
             c_attribute22=>null,
             c_attribute23=>null,
             c_attribute24=>null,
             c_attribute25=>null,
             c2_attribute_category=>null,
             c2_attribute1=>null,
             c2_attribute2=>null,
             c2_attribute3=>null,
             c2_attribute4=>null,
             c2_attribute5=>null,
             c2_attribute6=>null,
             c2_attribute7=>null,
             c2_attribute8=>null,
             c2_attribute9=>null,
             c2_attribute10=>null,
             c2_attribute11=>null,
             c2_attribute12=>null,
             c2_attribute13=>null,
             c2_attribute14=>null,
             c2_attribute15=>null,
             c2_attribute16=>null,
             c2_attribute17=>null,
             c2_attribute18=>null,
             c2_attribute19=>null,
             c2_attribute20=>null,
             in_Created_by_module=>G_CREATED_BY_MODULE
                  );

           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN

             x_return_status := l_return_status;
             x_msg_data := l_msg_data;
             x_msg_count := l_msg_count;
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add(l_indent||  ' contact creation failed' ) ;
                 oe_debug_pub.add( l_indent|| ' error = '||X_MSG_DATA ) ;
             END IF;

             IF x_msg_count = 1 then
              FND_MESSAGE.Set_Name('ONT','ONT_AAC_CONTACT_CREATION');
              FND_MESSAGE.Set_Token('TCA_MESSAGE',x_msg_data, FALSE);
              OE_MSG_PUB.ADD;
             ELSE
              oe_msg_pub.transfer_msg_stack;
             END IF;

             OE_MSG_PUB.Count_And_Get
             (   p_count                       => x_msg_count
             ,   p_data                        => x_msg_data
             );
             return;
           ELSE
             x_return_status := FND_API.G_RET_STS_SUCCESS;
                              IF l_debug_level  > 0 THEN
                                  oe_debug_pub.add( l_indent|| ' contact creation succeeded '|| ' cust acct_role_id = '||P_CONTACT_TBL ( 1 ) ) ;
                              END IF;

           END IF;
           ELSE
             x_return_status := FND_API.G_RET_STS_ERROR;
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add( l_indent|| 'not allowed to create contact' ) ;
             end IF;
             FND_MESSAGE.Set_Name('ONT', 'ONT_AAC_CONTACT_PERMISSION');
             OE_MSG_PUB.ADD;
             OE_MSG_PUB.Count_And_Get
             (   p_count                       => x_msg_count
             ,   p_data                        => x_msg_data
             );
             return;

           END IF; -- if permission to create contact

         END IF; -- contact table count


      ELSIF (p_assign_contact_to_site AND
             p_cust_account_site_id is not null) OR
            (p_create_responsibility AND p_site_use_code is not null) then

         -- if zero then create the account contact appropiately
         -- take care of account site and responsibility
         IF p_contact_tbl.COUNT = 0 then
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add( l_indent|| 'equal to ZERO' ) ;
             END IF;
             x_return_status := FND_API.G_RET_STS_SUCCESS;
             return;

         -- if one or more then check the account contact appropiately
         -- take care of account site and responsibility
         -- and create if not present
         ELSIF p_Contact_tbl.COUNT >0 then
             IF l_debug_level  > 0 THEN
                 oe_debug_pub.add( l_indent|| 'one or more than one' ) ;
             END IF;
             x_return_status := FND_API.G_RET_STS_SUCCESS;
             return;
         END IF;

      END IF; -- if not to be assigned

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(l_indent||  'cust_acct_role_id = '||L_CUST_ACCOUNT_ROLE_ID ) ;
      END IF;

    ELSE
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(l_indent||  'error no contact information is passed' ) ;
        END IF;
        return;
    END IF; -- if p_cust_account_role_id is not null

  ELSE -- if cust_account_id is not passed
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(l_indent||  'this procedure expects the account_id to be passed' ) ;
    END IF;
    return;

  END IF; -- if cust_account_id is not null


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                        IF l_debug_level  > 0 THEN
                            oe_debug_pub.add(  'CHECK_CONTACT WHEN OTHER EXCEPTION CODE='|| SQLCODE||' MESSAGE='||SQLERRM ) ;
                        END IF;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'check_and_create_contact'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );


END check_and_create_Contact;



PROCEDURE Check_and_Create_Account(
    p_party_id in number
   ,p_party_number in varchar2
   ,p_allow_account_creation in boolean
   ,p_multiple_account_is_error in boolean
   ,p_account_tbl out NOCOPY account_tbl
   ,p_out_org_contact_id out NOCOPY number
   ,p_out_cust_account_role_id out NOCOPY number
   ,x_return_status     OUT NOCOPY     VARCHAR2
   ,x_msg_count         OUT NOCOPY     NUMBER
   ,x_msg_data          OUT NOCOPY     VARCHAR2
   ,p_site_tbl_count    IN number
   ,p_return_if_only_party in boolean
  ) IS

    CURSOR C_get_cust_id_from_party_id(l_Party_Id NUMBER) IS
        SELECT cust_account_id,
               account_number
        FROM hz_cust_accounts
        WHERE party_id = l_Party_Id
        and status = 'A';

    CURSOR party_rec(l_party_id in number) IS
        select party_type
        from hz_parties
        where party_id = l_party_id;

    CURSOR party_number_rec IS
        select party_id,party_type
        from hz_parties
        where party_id = p_party_number;


    l_cust_account_id   NUMBER  := NULL;
    l_return_status     VARCHAR2(1);
    l_party_type        VARCHAR2(30);
    l_object_party_id   NUMBER;
    l_party_id          NUMBER;
    l_message           varchar2(300);
    l_account_number    varchar2(30);
    p_multiple_account  boolean := FALSE;
    l_org_contact_Id    number;
    l_cust_account_role_id number;
    l_msg_count     Number;
    l_msg_data      Varchar2(4000);
    x_party_id number;
    x_party_number varchar2(30);
    x_cust_Account_id number;
    x_cust_account_number varchar2(30);
    l_found boolean := FALSE;

--
l_debug_level  NUMBER := oe_debug_pub.g_debug_level;
l_indent varchar2(5) := '  ';
i number := 0;

--
BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   p_account_tbl.DELETE;

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(l_indent||'party_id = '||p_party_id|| '; party_number = '||p_party_number);
      oe_debug_pub.add(l_indent||'site tbl count = '||p_site_tbl_count ) ;
   END IF;

  if p_allow_account_creation then
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add( l_indent|| ' allowed account creation' ) ;
    END IF;
  end if;

  if p_multiple_account_is_error then
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(l_indent||  ' multiple account is error' ) ;
    END IF;
  end if;

  if p_return_if_only_party then
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(l_indent||  ' return_if_only_party' ) ;
    END IF;
  end if;


  -- if both party_id and party_number information is not provided then
  -- then we raise an error
  IF p_party_id is not null or p_party_number is not null then

    -- we will ignore party_number if party_id is passed
    IF p_party_id is null and p_party_number is not null then
      OPEN  party_number_rec;
      FETCH party_number_rec
       INTO l_party_id,
            l_party_type;

      IF party_number_rec%NOTFOUND THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(l_indent||  'no such party found for party_number' ) ;
        END IF;
        CLOSE party_number_rec;
        FND_MESSAGE.Set_Name('ONT','ONT_AAC_NO_PARTY');
        OE_MSG_PUB.ADD;
        return;
      END IF;

      CLOSE party_number_rec;
    ELSE
      l_party_id := p_party_id;
      OPEN  party_rec(l_party_id);
      FETCH party_rec
       INTO l_party_type;

      IF party_rec%NOTFOUND THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(l_indent||  'no such party found for party_id' ) ;
        END IF;
        FND_MESSAGE.Set_Name('ONT','ONT_AAC_NO_PARTY');
        OE_MSG_PUB.ADD;
        CLOSE party_rec;
        return;
      END IF;

      CLOSE party_rec;

    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(l_indent||  'party type for sold_to = '|| L_PARTY_TYPE ) ;
    END IF;
    IF l_party_type = 'PERSON' OR l_party_type ='ORGANIZATION' THEN

                          IF l_debug_level  > 0 THEN
                              oe_debug_pub.add(l_indent||  'party type = '||l_party_type|| '; party_id = '||l_PARTY_ID ) ;
                          END IF;
      -- derive customer account
      OPEN C_get_cust_id_from_party_id(l_Party_Id);
      LOOP
        IF l_debug_level  > 0 THEN
	   i := i+1;
	   oe_debug_pub.add ('AAC:VTI:  ===GET_CUST_LOOP_'||i||'===== ');
	   oe_debug_pub.add(l_indent|| 'inside get_cust_id loop :X#'||i) ;
        END IF;

        FETCH C_get_cust_id_from_party_id
         INTO l_cust_account_id,
              l_account_number;
	EXIT WHEN C_get_cust_id_from_party_id%NOTFOUND;

	IF l_debug_level  > 0 THEN
	   oe_debug_pub.add( l_indent|| 'acct_id = '||l_cust_account_id|| '; account number = '||l_ACCOUNT_NUMBER ) ;
	END IF;

	IF l_debug_level  > 0 THEN
	   oe_debug_pub.add( l_indent|| 'row count get_cust_id = '|| C_GET_CUST_ID_FROM_PARTY_ID%ROWCOUNT ) ;
	END IF;

        IF p_multiple_account_is_error THEN
	   IF C_get_cust_id_from_party_id%ROWCOUNT > 1 then
	      IF l_debug_level  > 0 THEN
		 oe_debug_pub.add( l_indent|| 'more than one account for party id' ) ;
	      END IF;
	      x_return_status := FND_API.G_RET_STS_ERROR;
	      FND_MESSAGE.Set_Name('ONT','ONT_AVAIL_GENERIC');
	      FND_MESSAGE.Set_Token('TEXT','Multiple Accounts Exist', FALSE);
	      OE_MSG_PUB.ADD;
	      EXIT;
	   END IF;
        end if;
	IF l_debug_level  > 0 THEN
	   oe_debug_pub.add(l_indent||  'adding to account tbl id = '||L_CUST_ACCOUNT_ID ) ;
	END IF;
	p_account_tbl(p_account_tbl.COUNT + 1):= l_cust_account_id;


     END LOOP;

     -- if multiple accounts are detected then do not proceed further as
     -- contacts and sites needs to be created once an account is selected
     IF p_account_tbl.COUNT > 1 then
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add( l_indent|| 'multiple accounts found' ) ;
        end IF;
        p_multiple_account := TRUE;
      END IF;

      CLOSE C_get_cust_id_from_party_id;

      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  l_indent||'cust acct id for sold_to = '|| L_CUST_ACCOUNT_ID ) ;
      END IF;


    ELSE -- if not person or organization

        x_return_status := FND_API.G_RET_STS_ERROR;
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(l_indent||  ' invalid party type' ) ;
        end IF;
        FND_MESSAGE.Set_Name('ONT', 'ONT_AAC_INVALID_PARTY');
        OE_MSG_PUB.ADD;

    END IF; -- party_type

    IF p_account_tbl.COUNT > 0 then
    FOR i in p_account_tbl.FIRST..p_account_tbl.LAST
    LOOP
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add( l_indent|| 'acct_id = '||P_ACCOUNT_TBL ( I ) ) ;
        END IF;
    END LOOP;
    END IF;

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(l_indent||  'before checking to create cust account' ) ;
    END IF;
    -- create customer account
    IF x_return_status <> FND_API.G_RET_STS_ERROR AND
       NOT p_multiple_account AND
       l_cust_account_id IS NULL THEN

      IF p_allow_account_creation THEN

        IF p_site_tbl_count = 0 AND p_return_if_only_party THEN

          -- We will not process even the Contact information
          -- as we will not have account information
          -- Even if party level contact is passed then
          -- user should select it in the Add Customer form
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add( l_indent|| ' going to call add customer' ) ;
          END IF;
          x_return_status := FND_API.G_RET_STS_SUCCESS;
          return;

        ELSE
          IF l_party_id is not NULL THEN
            IF l_debug_level  > 0 THEN
                oe_debug_pub.add( l_indent|| 'creating cust account...' ) ;
            END IF;

            oe_oe_inline_address.create_account(
                 p_party_number=>null,
                 p_organization_name=>null,
                 p_alternate_name=>null,
                 p_tax_reference=>NULL,
                 p_taxpayer_id=>NULL,
                 p_party_id=>l_party_id,
                 p_first_name=>null,
                 p_last_name=>null,
                 p_middle_name=>null,
                 p_name_suffix=>null,
                 p_title=>null,
                 p_party_type=>l_party_type,
                 p_email=>null,
                 c_attribute_category=>null,
                 c_attribute1=>null,
                 c_attribute2=>null,
                 c_attribute3=>null,
                 c_attribute4=>null,
                 c_attribute5=>null,
                 c_attribute6=>null,
                 c_attribute7=>null,
                 c_attribute8=>null,
                 c_attribute9=>null,
                 c_attribute10=>null,
                 c_attribute11=>null,
                 c_attribute12=>null,
                 c_attribute13=>null,
                 c_attribute14=>null,
                 c_attribute15=>null,
                 c_attribute16=>null,
                 c_attribute17=>null,
                 c_attribute18=>null,
                 c_attribute19=>null,
		 c_attribute20=>null,
                 c_global_attribute_category=>null,
                 c_global_attribute1=>null,
                 c_global_attribute2=>null,
                 c_global_attribute3=>null,
                 c_global_attribute4=>null,
                 c_global_attribute5=>null,
                 c_global_attribute6=>null,
                 c_global_attribute7=>null,
                 c_global_attribute8=>null,
                 c_global_attribute9=>null,
                 c_global_attribute10=>null,
                 c_global_attribute11=>null,
                 c_global_attribute12=>null,
                 c_global_attribute13=>null,
                 c_global_attribute14=>null,
                 c_global_attribute15=>null,
                 c_global_attribute16=>null,
                 c_global_attribute17=>null,
                 c_global_attribute18=>null,
                 c_global_attribute19=>null,
                 c_global_attribute20=>null,
                 x_party_id=>x_party_id,
                 x_party_number=>x_party_number,
                 x_cust_Account_id=>x_cust_account_id,
                 x_cust_account_number=>x_cust_account_number,
                 x_return_status=>x_return_status,
                 x_msg_count=>l_msg_count,
                 x_msg_data=>l_msg_data,
                 in_Created_by_module=>G_CREATED_BY_MODULE
                 );

            IF l_debug_level  > 0 THEN
	       oe_debug_pub.add( l_indent|| ' create account status='||x_RETURN_STATUS|| '; x_party_id = '|| X_PARTY_ID);
	       oe_debug_pub.add(l_indent||' x_cust_id   = '||X_CUST_ACCOUNT_ID|| '; x_cust_nbr = '||X_CUST_ACCOUNT_NUMBER);
	       oe_debug_pub.add(l_indent||' l_msg_count ='|| L_MSG_COUNT|| '; l_msg_data = '||L_MSG_DATA ) ;
            END IF;

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              IF l_debug_level  > 0 THEN
                  oe_debug_pub.add( l_indent|| ' account creation failed' ) ;
              END IF;
              IF x_msg_count = 1 then
                FND_MESSAGE.Set_Name('ONT','ONT_AAC_ACCOUNT_CREATION');
                FND_MESSAGE.Set_Token('TCA_MESSAGE',x_msg_data, FALSE);
                OE_MSG_PUB.ADD;
              ELSE
                oe_msg_pub.transfer_msg_stack;
              END IF;

            END IF;
            p_account_tbl(1):= x_cust_account_id;
	    /*cc project assigning the value CREATED TO variable G_account_created_or_found. We need
	    to do the site creation process in case account is created and not search for the sites*/
	    IF l_debug_level  > 0 THEN
               oe_debug_pub.add('cc account created');
	    END IF;

	    G_account_created_or_found :='CREATED';

	    /*cc project*/
          END IF; -- end party if
        END IF; -- If p_return_if_only_party

      ELSE -- profile is N raise error
       /*cc project  ,For Contact Center Integration
       If there is no permission to create the account , but party information is passed
       then we have to open the add Customer Form to the user. So returning
       status as success instead of error.*/

        IF G_CREATED_BY_MODULE <> 'ONT_TELESERVICE_INTEGRATION' THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
           IF l_debug_level  > 0 THEN
              oe_debug_pub.add(l_indent||  'not allowed to create account' ) ;
           END IF;
           FND_MESSAGE.Set_Name('ONT', 'ONT_AAC_ACCOUNT_PERMISSION');
           OE_MSG_PUB.ADD;
	ELSE
	  IF l_debug_level  > 0 THEN
              oe_debug_pub.add('Contact Center Integration, no permission to create account');
           END IF;
	END IF;
      END IF; -- end profile condition

    ELSE
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(l_indent||  ' account does not need to be created' ) ;
        END IF;
    END IF; -- checking to see if acconts needs to be created

    --oe_debug_pub.add('p_out_cust_account_id = '|| p_account_tbl(1));

  ELSE
    --x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.Set_Name('ONT', 'ONT_AVAIL_GENERIC');
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(l_indent||  'party_id or party number is not passed' ) ;
    END IF;
    l_message := 'Party_id or Party Number is not passed';
    FND_MESSAGE.Set_Token('TEXT',l_message, FALSE);
    OE_MSG_PUB.ADD;

  END IF; -- if party_id or party_number is not null


  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(l_indent||  'create account at the end' ) ;
  END IF;
  IF x_return_status <> FND_API.G_RET_STS_SUCCESS then
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(l_indent||  'doing count_and_get' ) ;
    END IF;
    oe_msg_pub.count_and_get(p_encoded=>fnd_api.G_TRUE,
                             p_count => x_msg_count,
                             p_data=>x_msg_data
                             );
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add( l_indent|| 'count = '||x_msg_count||'; msg = '||X_MSG_DATA ) ;
    END IF;
  END IF;

  IF l_debug_level  > 0 THEN
     oe_debug_pub.add( l_indent|| 'p_account_tbl: ' || p_account_tbl.COUNT ) ;
     oe_debug_pub.add( l_indent|| 'exiting check_and_create_account: ' || X_RETURN_STATUS ) ;
  END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        IF C_get_cust_id_from_party_id%ISOPEN THEN
          CLOSE c_get_cust_id_from_party_id;
        END IF;
        IF party_rec%ISOPEN THEN
          CLOSE party_rec;
        END IF;
        IF party_number_rec%ISOPEN THEN
          CLOSE party_number_rec;
        END IF;

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN


        IF C_get_cust_id_from_party_id%ISOPEN THEN
          CLOSE c_get_cust_id_from_party_id;
        END IF;
        IF party_rec%ISOPEN THEN
          CLOSE party_rec;
        END IF;
        IF party_number_rec%ISOPEN THEN
          CLOSE party_number_rec;
        END IF;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

    WHEN OTHERS THEN


        IF C_get_cust_id_from_party_id%ISOPEN THEN
          CLOSE c_get_cust_id_from_party_id;
        END IF;
        IF party_rec%ISOPEN THEN
          CLOSE party_rec;
        END IF;
        IF party_number_rec%ISOPEN THEN
          CLOSE party_number_rec;
        END IF;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                        IF l_debug_level  > 0 THEN
                            oe_debug_pub.add(  'CHECK_ACCOUNT WHEN OTHERS EXCEPTION CODE='|| SQLCODE||' MESSAGE='||SQLERRM ) ;
                        END IF;

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'check_and_create_account'
            );
        END IF;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
END check_and_create_account;

PROCEDURE set_debug_on IS

l_file_val varchar2(2000);

--
l_debug_level  NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

oe_debug_pub.debug_on;
oe_debug_pub.initialize;
l_file_val	:= OE_DEBUG_PUB.Set_Debug_Mode('FILE');

END set_debug_on;



PROCEDURE if_multiple_accounts(
                                p_party_id in number
                               ,p_party_number varchar2
                               ,p_account_Tbl out NOCOPY account_tbl
                               ,x_return_status out NOCOPY varchar2
                               ,x_msg_data out NOCOPY varchar2
                               ,x_msg_count out NOCOPY number
                               ) IS

    CURSOR C_get_cust_id_from_party_id(l_Party_Id NUMBER) IS
        SELECT cust_account_id,
               account_number
        FROM hz_cust_accounts
        WHERE party_id = l_Party_Id
        and status = 'A';

    CURSOR party_rec(l_party_id in number) IS
        select party_type
        from hz_parties
        where party_id = l_party_id;

    CURSOR party_number_rec IS
        select party_id,party_type
        from hz_parties
        where party_id = p_party_number;

    l_party_type        VARCHAR2(30);
    l_party_id          NUMBER;
    l_cust_account_id   number;
    l_account_number    varchar2(30);

--
l_debug_level  NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  p_account_tbl.DELETE;

                      IF l_debug_level  > 0 THEN
                          oe_debug_pub.add(  ' PARTY_ID='||P_PARTY_ID|| ' PARTY_NUMBER ='||P_PARTY_NUMBER ) ;
                      END IF;
  -- if both party_id and party_number information is not provided then
  -- then we raise an error
  IF p_party_id is not null or p_party_number is not null then

    -- we will ignore party_number if party_id is passed
    IF p_party_id is null and p_party_number is not null then
      OPEN  party_number_rec;
      FETCH party_number_rec
       INTO l_party_id,
            l_party_type;

      IF party_number_rec%NOTFOUND THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'NO SUCH PARTY FOUND FOR PARTY_NUMBER' ) ;
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name('ONT','ONT_AACC_NO_ACCOUNT');
        OE_MSG_PUB.ADD;
        CLOSE party_number_rec;
        return;
      END IF;

      CLOSE party_number_rec;
    ELSE
      l_party_id := p_party_id;
      OPEN  party_rec(l_party_id);
      FETCH party_rec
       INTO l_party_type;

      IF party_rec%NOTFOUND THEN
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'NO SUCH PARTY FOUND FOR PARTY_ID' ) ;
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name('ONT','ONT_AAC_NO_ACCOUNT');
        OE_MSG_PUB.ADD;
        CLOSE party_rec;
        return;
      END IF;

      CLOSE party_rec;

    END IF; -- if party_number is not null

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'PARTY TYPE FOR SOLD_TO = '|| L_PARTY_TYPE ) ;
    END IF;
    IF l_party_type = 'PERSON' OR l_party_type ='ORGANIZATION' THEN

                          IF l_debug_level  > 0 THEN
                              oe_debug_pub.add(  'PARTY TYPE='||L_PARTY_TYPE|| ' PARTY_ID='||L_PARTY_ID ) ;
                          END IF;
      -- derive customer account
      OPEN C_get_cust_id_from_party_id(l_Party_Id);
      LOOP
        IF l_debug_level  > 0 THEN
            oe_debug_pub.add(  'INSIDE GET_CUST_ID LOOP' ) ;
        END IF;
        FETCH C_get_cust_id_from_party_id
         INTO l_cust_account_id,
              l_account_number;
        EXIT WHEN C_get_cust_id_from_party_id%NOTFOUND;

	IF l_debug_level  > 0 THEN
	   oe_debug_pub.add(  'ACCT_ID='||L_CUST_ACCOUNT_ID|| ' ACCOUNT NUMBER='||L_ACCOUNT_NUMBER ) ;
	END IF;

	IF l_debug_level  > 0 THEN
	   oe_debug_pub.add(  'ROW COUNT GET_CUST_ID='|| C_GET_CUST_ID_FROM_PARTY_ID%ROWCOUNT ) ;
	END IF;

	oe_debug_pub.add('X1:ADDING TO ACCOUNT TBL ID='||L_CUST_ACCOUNT_ID ) ;

	IF l_debug_level  > 0 THEN
	   oe_debug_pub.add(  'ADDING TO ACCOUNT TBL ID='||L_CUST_ACCOUNT_ID ) ;
	END IF;

	oe_debug_pub.add('X2:ADDING TO ACCOUNT TBL ID='||L_CUST_ACCOUNT_ID ) ;

	p_account_tbl(p_account_tbl.COUNT + 1):= l_cust_account_id;

	oe_debug_pub.add('X3:ADDING TO ACCOUNT TBL ID='||L_CUST_ACCOUNT_ID ) ;

     END LOOP;
  ELSE
     IF l_debug_level  > 0 THEN
	oe_debug_pub.add(  'INVALID PARTY TYPE' ) ;
     END IF;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.Set_Name('ONT','ONT_AAC_INVALID_PARTY');
     OE_MSG_PUB.ADD;
        return;
    END IF;

  ELSE
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'NO PARTY INFORMATION SENT' ) ;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('ONT','ONT_AVAIL_GENERIC');
      FND_MESSAGE.Set_Token('TEXT','No Customer Information ', FALSE);
      OE_MSG_PUB.ADD;
      return;
  END IF;

END if_multiple_accounts;


-- Value_to_id for Automatic Account Creation :
-- Try to lookup id-s for values passed in for customer, contact and sites
-- Conservatively checking if the id columns are also passed.
-- p_permission = "Y" -- Allow everything,
--                "P" --allow contact and address only
--                "N" -- nothing is allowed.

PROCEDURE Value_to_id(
		      p_party_customer_rec IN OUT NOCOPY Party_customer_rec
		      ,p_site_tbl          IN OUT NOCOPY site_tbl_type
		      ,p_permission        IN            varchar2
		      ,x_return_status        OUT NOCOPY VARCHAR2
		      ,x_msg_count          OUT NOCOPY NUMBER
		      ,x_msg_data           OUT NOCOPY VARCHAR2)
IS
   -- local variables here
   l_debug_level  NUMBER := oe_debug_pub.g_debug_level;
   l_dummy1 number := null;
   l_dummy2 number := null;
   l_dummy3 number := null;
   l_dummy4 boolean := false;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF l_debug_level > 0 THEN
      oe_debug_pub.add ('AAC:VTI: starting Value-To-Id');
      oe_debug_pub.add ('AAC:VTI: looking for header level stuff');
   END IF;


   -- if both party_id and account_id are missing, call find_sold_to_id
   if (nvl(p_party_customer_rec.p_party_id,FND_API.G_MISS_NUM)=FND_API.G_MISS_NUM
       OR nvl(p_party_customer_rec.p_cust_account_id,FND_API.G_MISS_NUM)=FND_API.G_MISS_NUM)
   then

      -- calling find_sold_to_id
      find_sold_to_id(
		      p_party_id             =>  p_party_customer_rec.p_party_id
		      ,p_cust_account_id     =>  p_party_customer_rec.p_cust_account_id
		      ,p_party_name          =>  p_party_customer_rec.p_party_name
		      ,p_cust_account_number =>  p_party_customer_rec.p_cust_account_number
		      ,p_party_number        =>  p_party_customer_rec.p_party_number
		      ,p_party_site_id       =>  l_dummy1
		      ,p_party_site_use_id   =>  l_dummy2
		      ,p_site_use_id         =>  l_dummy3
		      ,p_party_site_use_code =>  'SOLD_TO'		--bug 4240715
		      ,p_permission          => p_permission
		      ,p_process_site        =>  l_dummy4
		      ,x_return_status       => x_return_status
		      );

      IF  x_return_status = FND_API.G_RET_STS_ERROR then
	 -- not found a party_id/cust_account_id
	 -- error message already logged inside find_sold_to_id
	 IF l_debug_level > 0 THEN
	    oe_debug_pub.add ('AAC:VTI:sold_to_id account/party not found for header');
	 END IF;
	 -- exit if account_id cannot be found
	 return;
      end if; -- x_return_status

   end if;

   IF l_debug_level > 0 THEN
      oe_debug_pub.add ('AAC:VTI: looking for sold_to contact');
   END IF;

   -- if both org_contact_id and account_role_id are missing, call find_contact_id
   if (nvl(p_party_customer_rec.p_org_contact_id,FND_API.G_MISS_NUM)=FND_API.G_MISS_NUM
       and nvl(p_party_customer_rec.p_cust_account_role_id,FND_API.G_MISS_NUM)=FND_API.G_MISS_NUM)
   then
      find_contact_id( p_contact_id          => p_party_customer_rec.p_org_contact_id
		       ,p_cust_contact_id    => p_party_customer_rec.p_cust_account_role_id
		       ,p_contact_name       => p_party_customer_rec.p_contact_name
		       ,p_permission         => p_permission
		       ,p_sold_to_org_id     => p_party_customer_rec.p_cust_account_id
		       ,p_site_use_id        => p_party_customer_rec.p_cust_account_id
		       ,p_party_id	     => p_party_customer_rec.p_party_id
       		       ,p_site_use_code      => 'SOLD_TO'
		       ,x_return_status      => x_return_status
		       );

   end if;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF p_site_tbl.COUNT <> 0 then
      for i in p_site_tbl.FIRST..p_site_tbl.LAST loop
	 -- do value-to-id for each site record

	 IF l_debug_level > 0 THEN
	    oe_debug_pub.add ('AAC:VTI:  ============ VTI SITE RECORD '||i||' of '||p_site_tbl.LAST||' =============== ');
	    oe_debug_pub.add ('AAC:VTI:  looking for site party_id line record #'||i);
	 END IF;


	 -- do party v-t-i
	 find_sold_to_id(
			 p_party_id             =>  p_site_tbl(i).p_party_id
			 ,p_cust_account_id     =>  p_site_tbl(i).p_cust_account_id--site_customer_id
			 ,p_party_name          =>  p_site_tbl(i).p_party_name
			 ,p_cust_account_number =>  p_site_tbl(i).p_cust_account_number
			 ,p_party_number        =>  p_site_tbl(i).p_party_number
			 ,p_site_use_id         =>  p_site_tbl(i).p_site_use_id
			 ,p_party_site_id       =>  p_site_tbl(i).p_party_site_id
			 ,p_party_site_use_id   =>  p_site_tbl(i).p_party_site_use_id
			 ,p_party_site_use_code =>  p_site_tbl(1).p_site_use_code
			 ,p_permission          => p_permission
			 ,p_process_site        => p_site_tbl(i).p_process_site
			 ,x_return_status => x_return_status
			 );

	 IF  x_return_status = FND_API.G_RET_STS_ERROR then
	    -- not found a party_id/cust_account_id
	    -- error message already logged inside find_sold_to_id
	    IF l_debug_level > 0 THEN
	       oe_debug_pub.add ('AAC:VTI:sold_to_id account/party not found for line#'||i);
	    END IF;
	    -- exit if account_id cannot be found
	    return;
	 end if; -- x_return_status

	 IF l_debug_level > 0 THEN
	    oe_debug_pub.add ('AAC:VTI: looking for site contact');
	 END IF;

	 oe_debug_pub.add('P1:'||p_site_tbl(i).p_site_use_id);
	 -- do contact v-t-i
	 find_contact_id(
			 p_contact_id                => p_site_tbl(i).p_org_contact_id
			 ,p_cust_contact_id	     => p_site_tbl(i).p_cust_account_role_id
			 ,p_contact_name     	     => p_site_tbl(i).p_contact_name
			 ,p_permission               => p_permission
			 ,p_sold_to_org_id	     => p_site_tbl(i).p_cust_account_id
			 ,p_site_use_id              => p_party_customer_rec.p_cust_account_id
			 ,p_party_id		     => p_site_tbl(i).p_party_id
			 ,p_site_use_code            => p_site_tbl(i).p_site_use_code	--bug 4240715
			 ,x_return_status            => x_return_status
			 );

	 x_return_status := FND_API.G_RET_STS_SUCCESS;
	 -- do site v-t-i
	  oe_debug_pub.add('P2:'||p_site_tbl(i).p_site_use_id);
	 find_site_id(
		      p_site_use_id             => p_site_tbl(i).p_party_site_use_id
		      ,p_site_id                => p_site_tbl(i).p_party_site_id
		      ,p_account_site_use_id	=> p_site_tbl(i).p_site_use_id
		      ,p_site_use_code   	=> p_site_tbl(i).p_site_use_code
		      ,p_site_address1   	=> p_site_tbl(i).p_site_address1
		      ,p_site_address2   	=> p_site_tbl(i).p_site_address2
		      ,p_site_address3   	=> p_site_tbl(i).p_site_address3
		      ,p_site_address4   	=> p_site_tbl(i).p_site_address4
		      ,p_site_org        	=> p_site_tbl(i).p_site_org
		      ,p_site_city       	=> p_site_tbl(i).p_site_city
		      ,p_site_state      	=> p_site_tbl(i).p_site_state
		      ,p_site_postal_code	=> p_site_tbl(i).p_site_postal_code
		      ,p_site_country    	=> p_site_tbl(i).p_site_country
		      ,p_site_customer_id	=> p_site_tbl(i).p_cust_account_id
		      ,p_sold_to_org_id         => p_party_customer_rec.p_cust_account_id
		      ,p_party_id               => p_site_tbl(i).p_party_id
		      ,p_sold_to_party_id       => p_party_customer_rec.p_party_id
		      ,p_permission             => p_permission
		      ,x_return_status          => x_return_status
		      ,x_msg_count              => x_msg_count
		      ,x_msg_data               => x_msg_data
		      );
	  oe_debug_pub.add('P3:'||p_site_tbl(i).p_site_use_id);
	 IF  x_return_status = FND_API.G_RET_STS_ERROR then
	 -- not found a party_id/cust_account_id
	    -- error message already logged inside find_sold_to_id
	    IF l_debug_level > 0 THEN
	       oe_debug_pub.add ('AAC:VTI:site_use_id account/party not found for line#'||1);
	    END IF;
	    -- exit if account_id cannot be found
	    return;
	 end if; -- x_return_status

      end loop;
end if;

   IF l_debug_level > 0 THEN
      oe_debug_pub.add ('AAC:VTI: ending Value-To-Id');
   END IF;

END value_to_id;

PROCEDURE find_sold_to_id(
			  p_party_id IN OUT  NOCOPY number
			  ,p_cust_account_id in out  NOCOPY number
			  ,p_party_name     IN varchar2
			  ,p_cust_account_number IN varchar2
			  ,p_party_number in varchar2
			  ,p_permission in varchar2
			  ,p_site_use_id          IN OUT NOCOPY number
			  ,p_party_site_id          IN OUT NOCOPY number
			  ,p_party_site_use_id      IN OUT NOCOPY number
			  ,p_party_site_use_code    IN  varchar2 DEFAULT NULL		--bug 4240715
			  ,p_process_site           IN OUT NOCOPY boolean
			  ,x_return_status OUT NOCOPY VARCHAR2
			  )
IS
   -- local variables here
   cursor c_get_account_id(l_party_id number) is
   select cust_account_id
      --into p_cust_account_id -- commented for bug 3449269
      from hz_cust_accounts
      where party_id=l_party_id
      and status='A';
   l_debug_level  NUMBER := oe_debug_pub.g_debug_level;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF l_debug_level > 0 THEN
      oe_debug_pub.add ('AAC:VTI: FSTI: starting find_sold_to_id');
   END IF;

   -- check if party_id and cust_account_id are not null, return if so
   if (nvl(p_cust_account_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM
       and nvl(p_party_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM)
   THEN
      IF l_debug_level > 0 THEN
	 oe_debug_pub.add ('AAC:FSTI: party_id and account_id are not null, nothing to do: returning');
      END IF;
      RETURN;
   ELSE
      IF l_debug_level > 0 THEN
	 oe_debug_pub.add ('AAC:FSTI: party_name: '||p_party_name||'; cust_account_number: '||p_cust_account_number);
	 oe_debug_pub.add ('AAC:FSTI: party_id: '||p_party_id||'; cust_account_id: '||p_cust_account_id);
      END IF;
   END IF;

   if (nvl(p_site_use_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM
       and nvl(p_party_site_id      ,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM
       and nvl(p_party_site_use_id  ,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM
       and nvl(p_party_name         ,FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR
       and nvl(p_party_number       ,FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR
       and nvl(p_cust_account_number,FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR
       and nvl(p_cust_account_id   ,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM
       and nvl(p_party_id           ,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM)
   then
      --nothing to do! return!
      IF l_debug_level > 0 THEN
	 oe_debug_pub.add ('AAC:FSTI: no data passed in, seting process_site to false, returning');
      END IF;
      p_process_site:=false;
      return;
   end if;

   oe_debug_pub.add('p_site_use_id	    :'||p_site_use_id);
   oe_debug_pub.add('p_party_site_id        :'||p_party_site_id      );
   oe_debug_pub.add('p_party_site_use_id    :'||p_party_site_use_id  );
   oe_debug_pub.add('p_party_name           :'||p_party_name         );
   oe_debug_pub.add('p_party_number         :'||p_party_number       );
   oe_debug_pub.add('p_cust_account_number  :'||p_cust_account_number  );
   oe_debug_pub.add('p_cust_account_id      :'||p_cust_account_id   );
   oe_debug_pub.add('p_party_id             :'||p_party_id);

   begin
      -- check if site_use_id is passed
      if (nvl(p_cust_account_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM and
	  nvl(p_site_use_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM ) then

	 IF l_debug_level > 0 THEN
	    oe_debug_pub.add ('AAC:FSTI: site_use_id:'||p_site_use_id||' is not null, cust_account_id is null: getting cust_account_id');
	 END IF;

	 select s.cust_account_id
	    into p_cust_account_id
	    from hz_cust_acct_sites_all s,
	    hz_cust_site_uses u
	    where s.cust_acct_site_id=u.cust_acct_site_id
	    and u.site_use_id=p_site_use_id;

      end if;

      -- check if cust_account_id is not null, return if so
      if nvl(p_cust_account_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM and
	 nvl(p_party_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM then

	 IF l_debug_level > 0 THEN
	    oe_debug_pub.add ('AAC:FSTI: cust_account_id:'||p_cust_account_id||' is not null, party_id is null: getting party_id');
	 END IF;

	 select party_id
	    into p_party_id
	    from hz_cust_accounts
	    where cust_account_id=p_cust_account_id;

	 RETURN;
      END IF;

    EXCEPTION

	 WHEN NO_DATA_FOUND THEN

	    IF (OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR))
	    THEN
	       FND_MESSAGE.Set_Name('ONT', 'ONT_AAC_INVALID_ACCOUNT');
	       OE_MSG_PUB.ADD;
            END IF;

	    IF l_debug_level > 4 THEN
	       oe_debug_pub.add ('AAC:VTI: invalid cust_account_id ');
	    END IF;

	    x_return_status := FND_API.G_RET_STS_ERROR;
	    return;

	 WHEN OTHERS THEN

	    --IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	    --THEN
	       OE_MSG_PUB.Add_Exc_Msg(
				      G_PKG_NAME
				      ,'find_sold_to_id'
				      );
	    --END IF;
	    IF l_debug_level > 4 THEN
	       oe_debug_pub.add ('AAC:VTI: unexpected error in find_sold_to_id');
	    END IF;
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

	 end;


   -- look for cust_account_id using party_name
   p_cust_account_id := sold_to_org(
				    p_sold_to_org => p_party_name
				    ,p_customer_number => p_cust_account_number
				    ,p_site_use_code => p_party_site_use_code
				    );

   -- if account found, return
   IF nvl(p_cust_account_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM
   THEN
      p_cust_account_id := NULL;

   else
      -- found a sold_to_org_id/cust_account_id
      IF l_debug_level > 0 THEN
	 oe_debug_pub.add ('AAC:FSTI: found sold_to_org_id/cust_account_id:'||p_cust_account_id);
      END IF;

      -- also find the party_id for this account_id
      if nvl(p_party_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM THEN
	 begin
	 select party_id
	     into p_party_id
	     from hz_cust_accounts
	    where cust_account_id = p_cust_account_id;

	 IF l_debug_level > 0 THEN
	    oe_debug_pub.add ('AAC:FSTI: also found party_id:'||p_party_id||', returning');
	 END IF;
	 EXCEPTION

	 WHEN NO_DATA_FOUND THEN

	    IF (OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR))
	    THEN
	       FND_MESSAGE.Set_Name('ONT', 'ONT_AAC_INVALID_ACCOUNT');
	       OE_MSG_PUB.ADD;
            END IF;

	    IF l_debug_level > 4 THEN
	       oe_debug_pub.add ('AAC:VTI: invalid cust_account_id ');
	    END IF;

	    x_return_status := FND_API.G_RET_STS_ERROR;
	    return;

	 WHEN OTHERS THEN

	    --IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	    --THEN
	       OE_MSG_PUB.Add_Exc_Msg(
				      G_PKG_NAME
				      ,'find_sold_to_id'
				      );
	    --END IF;
	    IF l_debug_level > 4 THEN
	       oe_debug_pub.add ('AAC:VTI: unexpected error in find_sold_to_id');
	    END IF;
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

	 end;
     end if;
     return;
   end if;

   if (nvl(p_party_number,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM
       and nvl(p_party_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM)
       then
       IF l_debug_level > 0 THEN
	 oe_debug_pub.add ('AAC:FSTI: party_number:'|| p_party_number||' is not null, picking up party_id from it');
      END IF;

      begin
	 select party_id
	    into p_party_id
	    from hz_parties
	    where party_number=p_party_number;

	 EXCEPTION

	 WHEN NO_DATA_FOUND THEN

	    IF (OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR))
	    THEN
	       FND_MESSAGE.Set_Name('ONT', 'ONT_AAC_INVALID_PARTY');
	       OE_MSG_PUB.ADD;
            END IF;

	    IF l_debug_level > 4 THEN
	       oe_debug_pub.add ('AAC:VTI: invalid party_number ');
	    END IF;

	    x_return_status := FND_API.G_RET_STS_ERROR;
	    p_party_id := null;
	    return;

	 WHEN OTHERS THEN

	    --IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	    --THEN
	    OE_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,'find_sold_to_id' );	  --modified for bug 4590205
	    --END IF;
	    IF l_debug_level > 4 THEN
	       oe_debug_pub.add ('AAC:VTI: unexpected error in find_sold_to_id');
	    END IF;
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

	 end;
    end if;


    if (nvl(p_party_site_use_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM
       and nvl(p_party_site_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM)
     then
       IF l_debug_level > 0 THEN
	 oe_debug_pub.add ('AAC:FSTI: party_site_use_id:'|| p_party_site_use_id||' is not null, picking up party_site_id from it');
      END IF;
      begin
	 select party_site_id
	    into p_party_site_id
	    from hz_party_site_uses
	    where party_site_use_id=p_party_site_use_id;

	 EXCEPTION

	 WHEN NO_DATA_FOUND THEN

	    IF (OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR))
	    THEN
	       FND_MESSAGE.Set_Name('ONT', 'ONT_AAC_INVALID_PARTY');
	       OE_MSG_PUB.ADD;
            END IF;

	    IF l_debug_level > 4 THEN
	       oe_debug_pub.add ('AAC:VTI: invalid party_site_use_id ');
	    END IF;

	    x_return_status := FND_API.G_RET_STS_ERROR;
	    p_party_site_id := null;
	    return;

	 WHEN OTHERS THEN

	    --IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	    --THEN
	    OE_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,'find_sold_to_id' );	--modified for bug 4590205
	    --END IF;
	    IF l_debug_level > 4 THEN
	       oe_debug_pub.add ('AAC:VTI: unexpected error in find_sold_to_id');
	    END IF;
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

	 end;
    end if;

   if (nvl(p_party_site_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM
       and nvl(p_party_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM)
   then
       IF l_debug_level > 0 THEN
	 oe_debug_pub.add ('AAC:FSTI: party_site_id:'|| p_party_site_id||' is not null, picking up party_id from it');
      END IF;
      begin
	 select party_id
	    into p_party_id
	    from hz_party_sites
	    where party_site_id=p_party_site_id;

	 EXCEPTION

	 WHEN NO_DATA_FOUND THEN

	    IF (OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR))
	    THEN
	       FND_MESSAGE.Set_Name('ONT', 'ONT_AAC_INVALID_PARTY');
	       OE_MSG_PUB.ADD;
            END IF;

	    IF l_debug_level > 4 THEN
	       oe_debug_pub.add ('AAC:VTI: invalid party_site_id ');
	    END IF;

	    x_return_status := FND_API.G_RET_STS_ERROR;
	    return;

	 WHEN OTHERS THEN

	    --IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	    --THEN
	    OE_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,'find_sold_to_id' );		--modified for bug 4590205
	    --END IF;
	    IF l_debug_level > 4 THEN
	       oe_debug_pub.add ('AAC:VTI: unexpected error in find_sold_to_id');
	    END IF;
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

	 end;
    end if;

    /*
    if (nvl(p_party_site_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM
	and nvl(p_site_use_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM)
    then
       IF l_debug_level > 0 THEN
	 oe_debug_pub.add ('AAC:FSTI: party_site_id:'|| p_party_site_id||' is not null, picking up cust site_use_id from it');
      END IF;
      begin
	 select u.site_use_id
	    into p_site_use_id
	    from hz_cust_acct_sites s,hz_cust_site_uses_all u
	    where s.party_site_id=p_party_site_id
	    and s.cust_acct_site_id= u.cust_acct_site_id;

	 EXCEPTION

	 WHEN NO_DATA_FOUND THEN

	    IF l_debug_level > 4 THEN
	       oe_debug_pub.add ('AAC:VTI: party_site_id: no site_use_id ');
	    END IF;
	    p_site_use_id := null;

	 WHEN TOO_MANY_ROWS THEN
	   IF l_debug_level > 4 THEN
	       oe_debug_pub.add ('AAC:VTI: party_site_id: multiple sites found ');
	    END IF;
	    p_site_use_id := null;

	 WHEN OTHERS THEN

	    --IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	    --THEN
	    OE_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,'find_site_id' );
	    --END IF;
	    IF l_debug_level > 4 THEN
	       oe_debug_pub.add ('AAC:VTI: unexpected error in find_sold_to_id');
	    END IF;
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

	 end;
    end if;*/

    /*
    if (nvl(p_party_site_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM)
       and nvl(p_cust_account_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM
    then
       IF l_debug_level > 0 THEN
	  oe_debug_pub.add ('AAC:FSTI: party_site_id:'|| p_party_site_id||' is not null, picking up cust_account_id from it via account_sites');
       END IF;
       begin
	  select distinct cust_account_id
	     into p_cust_account_id
	     from hz_cust_acct_sites cs
	     where party_site_id=p_party_site_id;

      EXCEPTION

	 WHEN NO_DATA_FOUND THEN

	    IF l_debug_level > 4 THEN
	       oe_debug_pub.add ('AAC:VTI: party_site_id: no cust_account_id via site_use_id');
	    END IF;
	    p_cust_account_id := null;

	 WHEN TOO_MANY_ROWS THEN
	   IF l_debug_level > 4 THEN
	       oe_debug_pub.add ('AAC:VTI: party_site_id: multiple accounts ');
	    END IF;

	    p_cust_account_id := null;
	    x_return_status := FND_API.G_RET_STS_ERROR;
	    p_cust_account_id := null;
	    FND_MESSAGE.Set_Name('ONT','ONT_AVAIL_GENERIC');
	    FND_MESSAGE.Set_Token('TEXT','Multiple Accounts Exist', FALSE);
	    OE_MSG_PUB.ADD;

	    return;

	 WHEN OTHERS THEN

	    --IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	    --THEN
	    OE_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,'find_site_id' );
	    --END IF;
	    IF l_debug_level > 4 THEN
	       oe_debug_pub.add ('AAC:VTI: unexpected error in find_sold_to_id');
	    END IF;
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

	 end;
    end if;*/


    /*
    if (nvl(p_site_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM)
       and nvl(p_cust_account_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM
    then
       IF l_debug_level > 0 THEN
	  oe_debug_pub.add ('AAC:FSTI: site_id:'|| p_site_id||' is not null, picking up cust_account_id from it');
       END IF;
       begin
	 select distinct cust_account_id
	     into p_cust_account_id
	     from hz_cust_acct_sites
	     where cust_acct_site_id=p_site_id;

      EXCEPTION

	 WHEN NO_DATA_FOUND THEN

	    IF l_debug_level > 4 THEN
	       oe_debug_pub.add ('AAC:VTI: site_id: no cust_account_id via site_id');
	    END IF;
	    p_cust_account_id := null;

	 WHEN TOO_MANY_ROWS THEN
	   IF l_debug_level > 4 THEN
	       oe_debug_pub.add ('AAC:VTI: site_id: multiple accounts, returning with error ');
	    END IF;

	    x_return_status := FND_API.G_RET_STS_ERROR;
	    p_cust_account_id := null;
	    FND_MESSAGE.Set_Name('ONT','ONT_AVAIL_GENERIC');
	    FND_MESSAGE.Set_Token('TEXT','Multiple Accounts Exist', FALSE);
	    OE_MSG_PUB.ADD;

	    return;

	 WHEN OTHERS THEN

	    --IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	    --THEN
	    OE_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,'find_site_id' );
	    --END IF;
	    IF l_debug_level > 4 THEN
	       oe_debug_pub.add ('AAC:VTI: unexpected error in find_sold_to_id');
	    END IF;
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

	 end;
    end if;
*/
   -- check if party_id is not null
   -- We have a party_id, then look for account_id using it
   -- multiple matches is an error
   -- single/zero match is ok

    if nvl(p_party_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM
       and nvl(p_cust_account_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM THEN
      IF l_debug_level > 0 THEN
	 oe_debug_pub.add ('AAC:FSTI: party_id:'|| p_party_id||' is not null, picking up account_id from it');
      END IF;

      open c_get_account_id(p_party_id);

      loop
         fetch c_get_account_id
	    into p_cust_account_id;
	 EXIT WHEN c_get_account_id%NOTFOUND;

	 if c_get_account_id%ROWCOUNT > 1 then

	    IF l_debug_level > 0 THEN
	       oe_debug_pub.add ('AAC:FSTI: ERROR: multiple accounts found');
	    END IF;

	    --x_return_status := FND_API.G_RET_STS_ERROR;
	    p_cust_account_id := null;
	    FND_MESSAGE.Set_Name('ONT','ONT_AVAIL_GENERIC');
	    FND_MESSAGE.Set_Token('TEXT','Multiple Accounts Exist', FALSE);
	    OE_MSG_PUB.ADD;
	    close c_get_account_id;

	    return;
	 end if;
      end loop;

      if (c_get_account_id%ROWCOUNT = 1)
      then
	 IF l_debug_level > 0 THEN
	    oe_debug_pub.add ('AAC:FSTI: one account found:'||p_cust_account_id);
	 END IF;
      end if;

      if (c_get_account_id%ROWCOUNT = 0)
      then
	 IF l_debug_level > 0 THEN
	    oe_debug_pub.add ('AAC:FSTI: no account found');
	 END IF;
	 p_cust_account_id := NULL;
      end if;

      close c_get_account_id;
      return;
   end if;

   -- no account found, and party_id is null/missing
   -- try to find name in party_layer
   -- check if we have permissions to create accounts ("Y")
   -- looking for party_id is futile if we cannot create an account

   IF p_permission <> 'Y' THEN
      -- reset cust_account_id, set error condition
      -- and return
      IF l_debug_level > 0 THEN
	 oe_debug_pub.add ('AAC:FSTI: no permission to create account: returning');
      END IF;
      FND_MESSAGE.Set_Name('ONT', 'ONT_AAC_ACCOUNT_PERMISSION');
      OE_MSG_PUB.ADD;
      p_cust_account_id := NULL;
      x_return_status := FND_API.G_RET_STS_ERROR;
      return;
   END IF;

   -- at this point:
   -- no matching cust_account_id found,
   -- we have permission to create account,
   -- and going to search for name in party layer
   IF l_debug_level > 0 THEN
      oe_debug_pub.add ('AAC:FSTI: have permission to create account: trying to find party_id');
   END IF;

   p_party_id := get_party_id(
			       p_party_name => p_party_name,
			       p_party_number => p_party_number,
			       p_party_site_use_code => p_party_site_use_code
			       );


   IF nvl(p_party_id,FND_API.G_MISS_NUM) =  FND_API.G_MISS_NUM
   THEN
      -- didn't find a party_id either
      -- since we *cannot* create a party, error out
      IF l_debug_level > 0 THEN
	 oe_debug_pub.add ('AAC:FSTI: cannot find party_id, returning with error');
      END IF;
      p_party_id := NULL;
      x_return_status := FND_API.G_RET_STS_ERROR;
      return;
   END IF;

   IF l_debug_level > 0 THEN
      oe_debug_pub.add ('AAC:FSTI: found party_id:'||p_party_id);
   END IF;


   IF l_debug_level > 0 THEN
      oe_debug_pub.add ('AAC:VTI: ending find_sold_to_id');
   END IF;

   return;

EXCEPTION

   WHEN NO_DATA_FOUND THEN

      IF (OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR))
      THEN

	 fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
	 FND_MESSAGE.SET_TOKEN('ATTRIBUTE','find_sold_to_id');
	 OE_MSG_PUB.Add;

     END IF;
     IF l_debug_level > 4 THEN
	oe_debug_pub.add ('AAC:VTI: invalid p_cust_account_id in find_sold_to_id');      -- got a party_name
     END IF;

     x_return_status := FND_API.G_RET_STS_ERROR;
     return;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
	   OE_MSG_PUB.Add_Exc_Msg(
				  G_PKG_NAME
				  ,'find_Sold_To_Org_id'
				  );
        END IF;
	IF l_debug_level > 4 THEN
	   oe_debug_pub.add ('AAC:VTI: unexpected error in find_sold_to_id');      -- got a party_name
	END IF;
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END find_sold_to_id;

PROCEDURE find_contact_id(
			  p_contact_id          IN OUT  NOCOPY number
			  ,p_cust_contact_id    IN OUT  NOCOPY number
			  ,p_contact_name       IN     varchar2
			  ,p_permission         in     varchar2
			  ,p_sold_to_org_id     in     number
			  ,p_site_use_id        in     number
			  ,p_party_id           in     number
  			  ,p_site_use_code      in varchar2 default null
			  ,x_return_status      OUT NOCOPY varchar2
			  )
IS
   -- local variables here
l_debug_level  NUMBER := oe_debug_pub.g_debug_level;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF l_debug_level > 0 THEN
      oe_debug_pub.add ('AAC:VTI: starting find_contact_id...');
   END IF;

   -- check if cust_contact_id is not null, return if so
   if nvl(p_cust_contact_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
      IF l_debug_level > 0 THEN
	 oe_debug_pub.add ('AAC:FCI: cust_contact_id is not null, nothing to do: warn; returning}');
      END IF;

      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_SUCCESS)
      THEN
	 fnd_message.set_name('ONT','OE_BOTH_VAL_AND_ID_EXIST');
	 FND_MESSAGE.SET_TOKEN('ATTRIBUTE','sold_to_contact');
	 OE_MSG_PUB.Add;
      END IF;

      RETURN;
   END IF;

   if nvl(p_sold_to_org_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM THEN
      IF l_debug_level > 0 THEN
	 oe_debug_pub.add ('AAC:FCI: sold_to_org_id is null; returning');
      END IF;

      return;
   end if;


   IF l_debug_level > 0 THEN
      oe_debug_pub.add ('AAC:FCI: contact_name is   '||p_contact_name);
      oe_debug_pub.add ('AAC:FCI: org_contact_id is '||p_contact_id);
      oe_debug_pub.add ('AAC:FCI: party_id is       '||p_party_id);
      oe_debug_pub.add ('AAC:FCI: sold_to_org_id is '|| p_sold_to_org_id);
   END IF;

   -- look for cust_contact_id using contact_name


   if nvl(p_contact_name,FND_API.G_MISS_CHAR) <> FND_API.G_MISS_CHAR
   and nvl(p_cust_contact_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM THEN
      IF l_debug_level > 0 THEN
	 oe_debug_pub.add ('AAC:FCI: contact_name is not null,trying to find account contact_id');
      END IF;
      if p_site_use_code <> 'END_CUST' then
      p_cust_contact_id := OE_Value_To_Id.sold_to_contact(
							  p_sold_to_contact => p_contact_name
						       ,p_sold_to_org_id => p_sold_to_org_id
							  );
      else
	 p_cust_contact_id := OE_Value_To_Id.end_Customer_contact(
							  p_end_customer_contact => p_contact_name
						       ,p_end_customer_id => p_sold_to_org_id
							  );
	end if;
      -- if contact found, return
      IF nvl(p_cust_contact_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM
      THEN
	 -- found a cust_contact_id
	 IF l_debug_level > 0 THEN
	    oe_debug_pub.add ('AAC:FCI: found cust_contact_id:'||p_cust_contact_id||', returning}');
	 END IF;
	 return;
      else
	 p_cust_contact_id := null;
      end if;
   end if;


   -- check if contact_id is not null, return if so
   if nvl(p_contact_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
      IF l_debug_level > 0 THEN
	 oe_debug_pub.add ('AAC:FSTI: org_contact_id is not null');
      END IF;

      RETURN;
   END IF;


   -- at this point:
   -- no matching cust_contact_id found,
   -- we have permission to create contact,
   -- and going to search for name in party layer
   IF l_debug_level > 0 THEN
      oe_debug_pub.add ('AAC:FCI: no account contact_id');
      oe_debug_pub.add ('AAC:FCI: have permission to create account contact: finding party contact_id');
   END IF;

   IF nvl(p_contact_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM
   THEN
      p_contact_id := get_party_contact_id(
					   p_contact_name => p_contact_name
					   ,p_party_id => p_party_id
					   ,p_sold_to_org_id => p_sold_to_org_id
					   );


      IF nvl(p_contact_id,FND_API.G_MISS_NUM) =  FND_API.G_MISS_NUM
      THEN
	 -- didn't find a party level contact_id either
	 -- since we *cannot* create a party, error out
	 IF l_debug_level > 0 THEN
	    oe_debug_pub.add ('AAC:FCI: cannot find contact_id, returning with error}');
	 END IF;
	 p_contact_id := NULL;
	 x_return_status := FND_API.G_RET_STS_ERROR;
	 return;
      END IF;
   end if;
   -- found a contact_id

   IF l_debug_level > 0 THEN
      oe_debug_pub.add ('AAC:FCI: found contact_id:'||p_contact_id);
      oe_debug_pub.add ('AAC:VTI: ...done find_contact_id');
   END IF;

   return;

END find_contact_id;

procedure find_site_id(
		       p_site_use_id           IN OUT NOCOPY number
		       ,p_site_id              IN OUT NOCOPY number
		       ,p_account_site_use_id  in out NOCOPY number
		       ,p_site_use_code        in  varchar2
		       ,p_site_address1        in  VARCHAR2
		       ,p_site_address2        in  VARCHAR2
		       ,p_site_address3        in  VARCHAR2
		       ,p_site_address4        in  VARCHAR2
		       ,p_site_org             in  VARCHAR2
		       ,p_site_city            in  VARCHAR2
		       ,p_site_state           in  VARCHAR2
		       ,p_site_postal_code     in  VARCHAR2
		       ,p_site_country         in  VARCHAR2
		       ,p_site_customer_id     in  number
		       ,p_sold_to_org_id       in  number
		       ,p_sold_to_party_id     in  number
		       ,p_party_id             IN out nocopy number
		       ,p_permission           in varchar2
		       ,x_return_status        OUT NOCOPY VARCHAR2
		       ,x_msg_data             out NOCOPY varchar2
		       ,x_msg_count            out NOCOPY varchar2
		       )
IS
   -- local variables here
l_debug_level  NUMBER := oe_debug_pub.g_debug_level;
l_cust_account_id number := null;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF l_debug_level > 0 THEN
      oe_debug_pub.add ('AAC:VTI: FSI: starting find_site_id{');
   END IF;

   if (nvl(p_party_id ,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM)
      then
      IF l_debug_level > 0 THEN
	 oe_debug_pub.add ('AAC:FSI: party_id null; returning');
      END IF;

      return;
   end if;

   if (nvl(p_party_id ,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM
       OR nvl(p_site_customer_id ,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM)
   then
      l_cust_account_id := p_site_customer_id;
   else
      l_cust_account_id := p_sold_to_org_id;
   end if;

   -- check if site_address1 is null
   IF l_debug_level > 0 THEN
      if nvl(p_site_address1,FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR THEN
	 oe_debug_pub.add ('AAC:FSI: warning: site_address1 is null');
      else
	 oe_debug_pub.add ('AAC:FSI: site_address1 : '||p_site_address1);
      end if;
      oe_debug_pub.add (   'AAC:FSI: cust_account_id is '|| l_cust_account_id);
   END IF;

   -- check if cust_site_use_id is not null, return if so
   if nvl(p_account_site_use_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM THEN
      IF l_debug_level > 0 THEN
	 oe_debug_pub.add ('AAC:FSI: account_site_use_id is not null; returning');
      END IF;

      RETURN;
   END IF;

   -- check if site_use_code is null, return with error if so
   if nvl(p_site_use_code, FND_API.G_MISS_CHAR) =  FND_API.G_MISS_CHAR then
      IF l_debug_level > 0 THEN
	 oe_debug_pub.add ('AAC:FSI: site_use_code is null: error; returning');
	 oe_debug_pub.add ('AAC:VTI: ending find_site_id}');
      end if;
      x_return_status := FND_API.G_RET_STS_ERROR;
      return;
   end if;

   if (nvl(p_site_use_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM
       and nvl(p_site_id            ,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM
       and nvl(p_account_site_use_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM
       --and nvl(p_site_use_code      ,FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR
       and nvl(p_site_address1      ,FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR
       and nvl(p_site_address2      ,FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR
       and nvl(p_site_address3      ,FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR
       and nvl(p_site_address4      ,FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR
       and nvl(p_site_org           ,FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR
       and nvl(p_site_city          ,FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR
       and nvl(p_site_state         ,FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR
       and nvl(p_site_postal_code   ,FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR
       and nvl(p_site_country       ,FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR
       and nvl(p_site_customer_id   ,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM
       --and nvl(l_cust_account_id     ,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM
       --and nvl(p_sold_to_party_id   ,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM
       and nvl(p_party_id           ,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM)
   then
      --nothing to do! return!
      IF l_debug_level > 0 THEN
	 oe_debug_pub.add ('AAC:FSI: no data passed in, returning');
      END IF;
      return;
   end if;

   IF l_debug_level > 0 THEN
     oe_debug_pub.add('p_site_use_id            :'|| p_site_use_id         );
     oe_debug_pub.add('p_site_id                :'|| p_site_id             );
     oe_debug_pub.add('p_account_site_use_id    :'|| p_account_site_use_id );
     oe_debug_pub.add('p_site_use_code          :'|| p_site_use_code       );
     oe_debug_pub.add('p_site_address1          :'|| p_site_address1       );
     oe_debug_pub.add('p_site_address2          :'|| p_site_address2       );
     oe_debug_pub.add('p_site_address3          :'|| p_site_address3       );
     oe_debug_pub.add('p_site_address4          :'|| p_site_address4       );
     oe_debug_pub.add('p_site_org               :'|| p_site_org            );
     oe_debug_pub.add('p_site_city              :'|| p_site_city           );
     oe_debug_pub.add('p_site_state             :'|| p_site_state          );
     oe_debug_pub.add('p_site_postal_code       :'|| p_site_postal_code    );
     oe_debug_pub.add('p_site_country           :'|| p_site_country        );
     oe_debug_pub.add('p_site_customer_id       :'|| p_site_customer_id    );
     oe_debug_pub.add('p_party_id               :'|| p_party_id    );
  end if;

   if nvl(p_site_use_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM
   and nvl(p_site_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM  then
      IF l_debug_level > 0 THEN
	 oe_debug_pub.add ('AAC:FSI: party_site_use_id:'||p_site_use_id||' is not null; using it to get party_site_id');
      END IF;
      begin

	 select party_site_id
	    into p_site_id
	    from hz_party_site_uses
	    where party_site_use_id=p_site_use_id
	    and status='A';

      EXCEPTION

	 WHEN NO_DATA_FOUND THEN

	    IF (OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR))
	    THEN
	       FND_MESSAGE.Set_Name('ONT','ONT_AVAIL_GENERIC');
	       FND_MESSAGE.Set_Token('TEXT','Not a Valid party site use ', FALSE);
	       OE_MSG_PUB.ADD;
            END IF;

	    IF l_debug_level > 4 THEN
	       oe_debug_pub.add ('AAC:VTI: invalid party_site_use_id ');
	    END IF;

	    x_return_status := FND_API.G_RET_STS_ERROR;
	    return;

	 WHEN OTHERS THEN

	    --IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	    --THEN
	       OE_MSG_PUB.Add_Exc_Msg(
				      G_PKG_NAME
				      ,'find_site_id'
				      );
	    --END IF;
	    IF l_debug_level > 4 THEN
	       oe_debug_pub.add ('AAC:VTI: unexpected error in find_site_id');
	    END IF;
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

	 end;

      end if;

   if nvl(p_site_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM
   and nvl(p_party_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM then
      IF l_debug_level > 0 THEN
	 oe_debug_pub.add ('AAC:FSI: party_site_id:'||p_site_id||' is not null; using it to get party_id');
      END IF;
      begin
	 select s.party_id
	    into p_party_id
	    from hz_party_sites s
	    where s.party_site_id=p_site_id
	    and s.status='A';

	 IF l_debug_level > 0 THEN
	    oe_debug_pub.add ('AAC:FSI: got party_id:'||p_party_id);
	 END IF;


      EXCEPTION

	 WHEN NO_DATA_FOUND THEN

	    IF (OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR))
	    THEN
	       FND_MESSAGE.Set_Name('ONT','ONT_AVAIL_GENERIC');
	       FND_MESSAGE.Set_Token('TEXT','Not a Valid party site ', FALSE);
	       OE_MSG_PUB.ADD;

            END IF;
	    IF l_debug_level > 4 THEN
	       oe_debug_pub.add ('AAC:VTI: invalid party_site_id ');
	    END IF;
	    x_return_status := FND_API.G_RET_STS_ERROR;
	    return;

	 WHEN OTHERS THEN

	    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	    THEN
	       OE_MSG_PUB.Add_Exc_Msg(
				      G_PKG_NAME
				      ,'find_site_id'
				      );
	    END IF;
	    IF l_debug_level > 4 THEN
	       oe_debug_pub.add ('AAC:VTI: unexpected error in find_site_id');
	    END IF;
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

	 end;
      end if;

      if nvl(p_site_address1      ,FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR
	 and nvl(p_site_address2      ,FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR
	 and nvl(p_site_address3      ,FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR
	 and nvl(p_site_address4      ,FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR
	 and nvl(p_site_org           ,FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR
	 and nvl(p_site_city          ,FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR
	 and nvl(p_site_state         ,FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR
	 and nvl(p_site_postal_code   ,FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR
	 and nvl(p_site_country       ,FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR
      then
	 --nothing to do! return!
	 IF l_debug_level > 0 THEN
	    oe_debug_pub.add ('AAC:FSI: no data passed in, returning');
	 END IF;
	 return;
      end if;

      -- look for cust_site_id using site_name
   IF l_debug_level > 0 THEN
      oe_debug_pub.add ('AAC:FSI: trying to find account site_use_id');
   END IF;

   /*
   if p_site_use_code='SHIP_TO'
   THEN

      p_account_site_use_id := OE_Value_To_Id.ship_to_org(
 							  p_ship_to_address1     =>    p_site_address1
 							  ,p_ship_to_address2    =>    p_site_address2
 							  ,p_ship_to_address3    =>    p_site_address3
 							  ,p_ship_to_address4    =>    p_site_address4
 							  ,p_ship_to_location    =>    p_site_org
 							  ,p_ship_to_org         =>    p_site_org
 							  ,p_sold_to_org_id      =>    l_cust_account_id
 							  ,p_ship_to_city        =>    p_site_city
 							  ,p_ship_to_state       =>    p_site_state
 							  ,p_ship_to_postal_code =>    p_site_postal_code
 							  ,p_ship_to_country     =>    p_site_country
 							  ,p_ship_to_customer_id =>    p_site_customer_id );


   elsif p_site_use_code='BILL_TO'
   THEN

      p_account_site_use_id := OE_Value_To_Id.invoice_to_org(
							     p_invoice_to_address1     =>    p_site_address1
							     ,p_invoice_to_address2    =>    p_site_address2
							     ,p_invoice_to_address3    =>    p_site_address3
							     ,p_invoice_to_address4    =>    p_site_address4
							     ,p_invoice_to_location    =>    p_site_org
							     ,p_invoice_to_org         =>    p_site_org
							     ,p_sold_to_org_id         =>    l_cust_account_id
							     ,p_invoice_to_city        =>    p_site_city
							     ,p_invoice_to_state       =>    p_site_state
							     ,p_invoice_to_postal_code =>    p_site_postal_code
							     ,p_invoice_to_country     =>    p_site_country
							     ,p_invoice_to_customer_id =>    p_site_customer_id       );


   elsif p_site_use_code='DELIVER_TO'
   THEN
      p_account_site_use_id := OE_Value_To_Id.deliver_to_org(
							     p_deliver_to_address1        =>    p_site_address1
							     ,p_deliver_to_address2       =>    p_site_address2
							     ,p_deliver_to_address3       =>    p_site_address3
							     ,p_deliver_to_address4       =>    p_site_address4
							     ,p_deliver_to_location       =>    p_site_org
							     ,p_deliver_to_org            =>    p_site_org
							     ,p_sold_to_org_id            =>    l_cust_account_id
							     ,p_deliver_to_city           =>    p_site_city
							     ,p_deliver_to_state          =>    p_site_state
							     ,p_deliver_to_postal_code    =>    p_site_postal_code
							     ,p_deliver_to_country        =>    p_site_country
							     ,p_deliver_to_customer_id    =>    p_site_customer_id    );

   else
      -- ERROR!
      IF l_debug_level > 0 THEN
	 oe_debug_pub.add ('AAC:FSI: site_use_code is invalid:'||p_site_use_code);
      END IF;
      return;
   end if;

   -- if site found, return
   IF nvl(p_account_site_use_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM
   THEN
      -- found a a cust_site_id
      IF l_debug_level > 0 THEN
	 oe_debug_pub.add ('AAC:FSI: found cust_site_use_id:'||p_account_site_use_id||', returning');
	 oe_debug_pub.add ('AAC:VTI: ending find_site_id');
      END IF;


      if  nvl(p_party_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM then
	 IF l_debug_level > 0 THEN
	    oe_debug_pub.add ('AAC:FSI: cust_site_use_id:'||p_account_site_use_id||' is not null; using it to get party_id');
	 END IF;
	 begin
	    select a.party_id
	       into p_party_id
	       from hz_cust_accounts a,
	       hz_cust_acct_sites s,
	       hz_cust_site_uses_all u
	       where u.site_use_id=p_account_site_use_id
	       and u.cust_acct_site_id=s.cust_acct_site_id
	       and s.cust_account_id=a.cust_account_id;

	 IF l_debug_level > 0 THEN
	    oe_debug_pub.add ('AAC:FSI: got party_id:'||p_party_id);
	 END IF;


      EXCEPTION

	 WHEN NO_DATA_FOUND THEN

	    IF (OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR))
	    THEN
	       FND_MESSAGE.Set_Name('ONT','ONT_AVAIL_GENERIC');
	       FND_MESSAGE.Set_Token('TEXT','Not a Valid account site use', FALSE);
	       OE_MSG_PUB.ADD;

            END IF;
	    IF l_debug_level > 4 THEN
	       oe_debug_pub.add ('AAC:VTI: invalid cust_site_use_id ');
	    END IF;
	    x_return_status := FND_API.G_RET_STS_ERROR;
	    return;

	 end;
      end if;

      return;
   else
      p_account_site_use_id := NULL; --convert from G_MISS_NUM
   END IF;
*/
   -- no account site found, try to find name in party_layer
   -- check if we have permissions to create sites (should be "Y" or "P")
   -- looking for party level site_id is futile if we cannot create a site

   -- at this point:
   -- no matching cust_site_id found,
   -- we have permission to create site,
   -- and going to search for name in party layer
   IF l_debug_level > 0 THEN
      oe_debug_pub.add ('AAC:FSI: no account site_use_id');
      oe_debug_pub.add ('AAC:FSI: finding party site_use_id');
   END IF;

   if (nvl(p_site_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM) then
      p_site_id := get_party_site_id(
				      p_site_address1     =>    p_site_address1
				      ,p_site_address2    =>    p_site_address2
				      ,p_site_address3    =>    p_site_address3
				      ,p_site_address4    =>    p_site_address4
				      ,p_site_location    =>    p_site_org
				      ,p_site_org         =>    p_site_org
				      ,p_sold_to_party_id =>    p_sold_to_party_id
				      ,p_site_city        =>    p_site_city
				      ,p_site_state       =>    p_site_state
				      ,p_site_postal_code =>    p_site_postal_code
				      ,p_site_country     =>    p_site_country
				      ,p_site_customer_id =>    p_site_customer_id
				      ,p_site_use_code    =>    p_site_use_code
				      ,p_party_id         =>    p_party_id
				      );

      IF nvl(p_site_id,FND_API.G_MISS_NUM) =  FND_API.G_MISS_NUM
      THEN
	 -- didn't find a party level site_id either
	 -- since we *cannot* create a party, error out
	 IF l_debug_level > 0 THEN
	    oe_debug_pub.add ('AAC:FSI: cannot find party_site_id, returning with error');
	 END IF;
	 p_site_id := NULL;
	 --x_return_status := FND_API.G_RET_STS_ERROR;
	 return;
      ELSE -- we did find a party_site_id, get party_id from it
	if nvl(p_party_id,FND_API.G_MISS_NUM) = FND_API.G_MISS_NUM then
	   IF l_debug_level > 0 THEN
	      oe_debug_pub.add ('AAC:FSI: party_site_id:'||p_site_id||' is not null; using it to get party_id');
	   END IF;
	   begin
	      select s.party_id
		 into p_party_id
		 from hz_party_sites s
		 where s.party_site_id=p_site_id
		 and s.status='A';

	      IF l_debug_level > 0 THEN
		 oe_debug_pub.add ('AAC:FSI: got party_id:'||p_party_id);
	      END IF;


	   EXCEPTION

	      WHEN NO_DATA_FOUND THEN

		 IF (OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR))
		 THEN
		    FND_MESSAGE.Set_Name('ONT','ONT_AVAIL_GENERIC');
		    FND_MESSAGE.Set_Token('TEXT','Not a Valid party site ', FALSE);
		    OE_MSG_PUB.ADD;

	        END IF;
		IF l_debug_level > 4 THEN
		   oe_debug_pub.add ('AAC:VTI: invalid party_site_id ');
		END IF;
		x_return_status := FND_API.G_RET_STS_ERROR;
		return;

	     WHEN OTHERS THEN

	       IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	       THEN
		  OE_MSG_PUB.Add_Exc_Msg(
					 G_PKG_NAME
					 ,'find_site_id'
					 );
	       END IF;
	       IF l_debug_level > 4 THEN
		  oe_debug_pub.add ('AAC:VTI: unexpected error in find_site_id');
	       END IF;
	       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

	    end;
	 end if;
      end if;
   end if;

   -- found a site_id

   IF l_debug_level > 0 THEN
      oe_debug_pub.add ('AAC:FSI: party site_use_id:'||p_site_use_id);
      oe_debug_pub.add ('AAC:FSI: account site_use_id:'||p_account_site_use_id);
   END IF;

   return;

END find_site_id;

/* helper functions */

FUNCTION get_party_id(
	      p_party_name in varchar2
	      ,p_party_number in varchar2
              ,p_party_site_use_code in varchar2
	      ) return number
IS
   l_id                          NUMBER;
   l_debug_level  CONSTANT NUMBER := 5;--oe_debug_pub.g_debug_level;
BEGIN
   IF l_debug_level > 4 THEN
      oe_debug_pub.add ('AAC:VTI: starting get_party_id{');
   END IF;

   -- did they actually pass some values?
   IF  (nvl(p_party_name,fnd_api.g_miss_char) = fnd_api.g_miss_char
	AND nvl(p_party_number,fnd_api.g_miss_char) = fnd_api.g_miss_char)
   THEN
      IF l_debug_level > 4 THEN
	 oe_debug_pub.add ('AAC: null values passed: name'||p_party_name||' number:'||p_party_number);
	 oe_debug_pub.add ('AAC:VTI: ending get_party_id}');
      END IF;
      RETURN NULL;
   END IF;

   IF (nvl(p_party_number,fnd_api.g_miss_char) <> fnd_api.g_miss_char)
   THEN
      -- got a party_number
      IF l_debug_level > 4 THEN
	 oe_debug_pub.add ('AAC:VTI:GPI party number: '||p_party_number);
      END IF;

	SELECT party_id
	  INTO l_id
	  FROM hz_parties party
	 WHERE party.party_number = p_party_number
	       and status='A';

   ELSE
      IF l_debug_level > 4 THEN
	 oe_debug_pub.add ('AAC:VTI:GPI name: '||p_party_name);      -- got a party_name
      END IF;

	SELECT  party.party_id
	  INTO l_id
	  FROM HZ_PARTIES Party
	 WHERE party.party_name = p_party_name
	       and status='A';

   END IF;

   IF l_debug_level > 4 THEN
      oe_debug_pub.add ('AAC:VTI:GPI: party_id: '||l_id);
      oe_debug_pub.add ('AAC:VTI: ending get_party_id}');
   END IF;

   return l_id;
EXCEPTION

   WHEN NO_DATA_FOUND THEN

      IF (OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR))
      THEN

	 fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
	--{bug 4240715
	 if p_party_site_use_code is NULL or p_party_site_use_code = 'SOLD_TO' then
       	 FND_MESSAGE.SET_TOKEN('ATTRIBUTE','sold_to_org_id');
	 elsif p_party_site_use_code ='SHIP_TO' then
	 FND_MESSAGE.SET_TOKEN('ATTRIBUTE','ship_to_org_id');
	 elsif p_party_site_use_code ='BILL_TO' then
	 FND_MESSAGE.SET_TOKEN('ATTRIBUTE','bill_to_org_id');
	 elsif p_party_site_use_code ='DELIVER_TO' then
	 FND_MESSAGE.SET_TOKEN('ATTRIBUTE','deliver_to_org_id');
	 elsif p_party_site_use_code ='END_CUST' then
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE','end_customer_id');
         end if;
	 --bug 4240715}
	 OE_MSG_PUB.Add;

     END IF;
     IF l_debug_level > 4 THEN
	oe_debug_pub.add ('AAC:VTI: no data in Get_party_id');      -- got a party_name
     END IF;
     RETURN FND_API.G_MISS_NUM;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
	   OE_MSG_PUB.Add_Exc_Msg(
				  G_PKG_NAME
				  ,'get_party_id'		 --modified for bug 4590205
				  );
        END IF;
	IF l_debug_level > 4 THEN
	   oe_debug_pub.add ('AAC:VTI: unexpected error in Get_party_id');      -- got a party_name
	END IF;
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END get_party_id;

FUNCTION get_party_contact_id(
			      p_contact_name in varchar2
			      ,p_party_id in number
			      ,p_sold_to_org_id in number
			      ) return number
IS

   CURSOR c_org_contact_id(in_org_contact_name in varchar2,
			   in_party_id number)
   IS
     SELECT org_contact.org_contact_id
       FROM hz_parties party,
	    hz_relationships rel,
	    hz_org_contacts org_contact,
	    ar_lookups arl
      WHERE rel.object_id=in_party_id
	AND rel.relationship_id=org_contact.party_relationship_id
	AND rel.party_id=rel.subject_id
	AND rel.directional_flag='Y'
	AND party.party_type='PERSON'
	AND party.person_last_name || decode(party.person_first_name, null, null, ', '||
					     party.person_first_name) || decode(arl.meaning, null, null, ' '||arl.meaning) = in_org_contact_name
	AND arl.lookup_code(+)=org_contact.title
	AND arl.lookup_type(+)='CONTACT_TITLE';


   l_id                          NUMBER;
   l_debug_level  CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

   IF l_debug_level > 4 THEN
      oe_debug_pub.add ('AAC:VTI: starting get_party_contact_id...');
   END IF;

    IF  nvl(p_contact_name,FND_API.G_MISS_CHAR) = FND_API.G_MISS_CHAR
    THEN
       IF l_debug_level > 4  THEN
 	 oe_debug_pub.add ('AAC:VTI: no contact_name');
 	 oe_debug_pub.add ('AAC:VTI: ...done get_party_contact_id');
       END IF;
       RETURN NULL;
    END IF;

    OPEN c_org_contact_id(p_contact_name,p_party_id);
    FETCH c_org_contact_id
       INTO l_id;

    IF c_org_contact_id%FOUND then
       CLOSE c_org_contact_id;
       IF l_debug_level > 4  THEN
	  oe_debug_pub.add ('AAC:VTI:  org_contact_id:'||l_id);
	  oe_debug_pub.add ('AAC:VTI: ...done get_party_contact_id');
       end if;
       return l_id;
    end if;

    IF l_debug_level > 4  THEN
       oe_debug_pub.add ('AAC:VTI: GCI org_contact_id not found');
    end if;

    CLOSE c_org_contact_id;

    IF l_debug_level > 4 THEN
       oe_debug_pub.add ('AAC:VTI: ...done get_party_contact_id');
    END IF;

    return NULL;

END get_party_contact_id;



FUNCTION get_party_site_id(
			    p_site_address1    IN  VARCHAR2
			   ,p_site_address2    IN  VARCHAR2
			   ,p_site_address3    IN  VARCHAR2
			   ,p_site_address4    IN  VARCHAR2
			   ,p_site_location    IN  VARCHAR2
			   ,p_site_org         IN  VARCHAR2
			   ,p_sold_to_party_id IN  number
			   ,p_site_city        IN  VARCHAR2
			   ,p_site_state       IN  VARCHAR2
			   ,p_site_postal_code IN  VARCHAR2
			   ,p_site_country     IN  VARCHAR2
			   ,p_site_customer_id IN  VARCHAR2
			   ,p_site_use_code    IN  VARCHAR2
			   ,p_party_id         IN  number
			   ) return number
IS

   l_id                          NUMBER;
   lcustomer_relations varchar2(1);


   CURSOR c_party_site_id(in_sold_to_party_id number) IS
     SELECT site.party_site_id
       FROM hz_locations loc,
	    hz_party_sites site
      WHERE site.location_id=loc.location_id
	and site.party_id=in_sold_to_party_id
	and loc.address1  = p_site_address1
	and nvl( loc.address2, fnd_api.g_miss_char) =
	    nvl( p_site_address2, fnd_api.g_miss_char)
	and nvl( loc.address3, fnd_api.g_miss_char) =
	    nvl( p_site_address3, fnd_api.g_miss_char)
	and nvl( loc.address4, fnd_api.g_miss_char) =
	    nvl( p_site_address4, fnd_api.g_miss_char)
	and nvl( loc.city, fnd_api.g_miss_char) =
	    nvl( p_site_city, fnd_api.g_miss_char)
	and nvl( loc.state, fnd_api.g_miss_char) =
	    nvl( p_site_state, fnd_api.g_miss_char)
	and nvl( loc.postal_code, fnd_api.g_miss_char) =
	    nvl( p_site_postal_code, fnd_api.g_miss_char)
	and nvl( loc.country, fnd_api.g_miss_char) =
	    nvl( p_site_country, fnd_api.g_miss_char);


  /*
   cursor C1(in_sold_to_party_id number) IS
     SELECT site.party_site_id
       FROM HZ_PARTY_SITES  	        SITE,
	    HZ_LOCATIONS	        LOC
      WHERE site.location_id=loc.location_id
	and site.status='A'
	and loc.ADDRESS1  = p_site_address1
	AND nvl( loc.ADDRESS2, fnd_api.g_miss_char) =
	    nvl( p_site_address2, fnd_api.g_miss_char)
	AND nvl( loc.ADDRESS3, fnd_api.g_miss_char) =
	    nvl( p_site_address3, fnd_api.g_miss_char)
	AND nvl( loc.ADDRESS4, fnd_api.g_miss_char) =
	    nvl( p_site_address4, fnd_api.g_miss_char)
	AND nvl( loc.city, fnd_api.g_miss_char) =
	    nvl( p_site_city, fnd_api.g_miss_char)
	AND nvl( loc.state, fnd_api.g_miss_char) =
	    nvl( p_site_state, fnd_api.g_miss_char)
	AND nvl( loc.postal_code, fnd_api.g_miss_char) =
	    nvl( p_site_postal_code, fnd_api.g_miss_char)
	AND nvl( loc.country, fnd_api.g_miss_char) =
	    nvl( p_site_country, fnd_api.g_miss_char)
	AND site.status = 'A'
	AND site.party_id in(
			     SELECT in_sold_to_party_id FROM DUAL
			     UNION
			     SELECT object_ID
			     FROM HZ_relationships rel
			     WHERE rel.subject_id= in_sold_to_party_id
			     and  rel.status='A');
   */
   CURSOR c2  IS
     SELECT site.party_site_id
       FROM hz_locations loc,
	    hz_party_sites site
      WHERE site.location_id=loc.location_id
	and site.status='A'
	and loc.address1  = p_site_address1
	and nvl( loc.address2, fnd_api.g_miss_char) =
	    nvl( p_site_address2, fnd_api.g_miss_char)
	and nvl( loc.address3, fnd_api.g_miss_char) =
	    nvl( p_site_address3, fnd_api.g_miss_char)
	and nvl( loc.address4, fnd_api.g_miss_char) =
	    nvl( p_site_address4, fnd_api.g_miss_char)
	and nvl( loc.city, fnd_api.g_miss_char) =
	    nvl( p_site_city, fnd_api.g_miss_char)
	and nvl( loc.state, fnd_api.g_miss_char) =
	    nvl( p_site_state, fnd_api.g_miss_char)
	and nvl( loc.postal_code, fnd_api.g_miss_char) =
	    nvl( p_site_postal_code, fnd_api.g_miss_char)
	and nvl( loc.country, fnd_api.g_miss_char) =
	    nvl( p_site_country, fnd_api.g_miss_char);

   l_site_party_id number;
   l_sold_to_party_id number;
   l_dummy number;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'AAC: site_address1:'||P_SITE_ADDRESS1);
	oe_debug_pub.add('  address4:'||p_site_address4);
	oe_debug_pub.add( ' party_id:'||p_party_id ) ;
    END IF;

    IF (nvl( p_site_address1,fnd_api.g_miss_char) = fnd_api.g_miss_char
	AND nvl(p_site_address2,fnd_api.g_miss_char) = fnd_api.g_miss_char
	AND nvl( p_site_address3,fnd_api.g_miss_char) = fnd_api.g_miss_char
	AND nvl( p_site_address4,fnd_api.g_miss_char) = fnd_api.g_miss_char
	AND nvl( p_sold_to_party_id,fnd_api.g_miss_num) = fnd_api.g_miss_num)
    THEN
       IF l_debug_level  > 0 THEN
	  oe_debug_pub.add(  'AAC: all incoming data missing,returning');
       end if;
       RETURN NULL;
    END IF;

    if (nvl(p_party_id,FND_API.G_MISS_NUM) <> FND_API.G_MISS_NUM) then
       IF l_debug_level  > 0 THEN
	  oe_debug_pub.add(  'AAC: incoming party_id is '||p_party_id ) ;
       END IF;

       OPEN c_party_site_id(p_party_id);
       FETCH c_party_site_id
	  INTO l_id;

       IF c_party_site_id%FOUND then
	  CLOSE c_party_site_id;
	  IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'AAC: found party_site_id is '||l_id ) ;
	  END IF;
	  return l_id;

       ELSE
	  IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'AAC: not found party_site_id in 1st try; trying SQL2' ) ;
	  END IF;

	  SELECT site.party_site_id
	     INTO l_id
	     FROM hz_locations loc,
	     hz_party_sites site
	     WHERE loc.ADDRESS1  = p_site_address1
	     AND nvl( loc.ADDRESS2, fnd_api.g_miss_char) =
	     nvl( p_site_address2, fnd_api.g_miss_char)
	     AND nvl( loc.ADDRESS3, fnd_api.g_miss_char) =
	     nvl( p_site_address3, fnd_api.g_miss_char)
	     AND DECODE(loc.CITY,NULL,NULL,loc.CITY||', ')||
	     DECODE(loc.STATE, NULL, NULL, loc.STATE || ', ')||
	     DECODE(POSTAL_CODE, NULL, NULL, loc.POSTAL_CODE || ', ')||
	     DECODE(loc.COUNTRY, NULL, NULL, loc.COUNTRY) =
	     nvl( p_site_address4, fnd_api.g_miss_char)
	     AND site.status = 'A'
	     AND site.party_id = p_party_id
	     and site.location_id=loc.location_id;

       END IF;
       CLOSE c_party_site_id;

       IF l_debug_level  > 0 THEN
	  oe_debug_pub.add(  'AAC: found party_site_id is '||l_id );
       END IF;

       RETURN l_id;

    ELSE --p_party_id is null...

       IF l_debug_level  > 0 THEN
	  oe_debug_pub.add(  'AAC: party_id is null' ) ;
       END IF;

       OPEN C2;

       FETCH C2
	  INTO l_id;

       IF C2%FOUND then
	  CLOSE C2 ;
	  IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'AAC: found site_use_id = '||L_ID ) ;
	  END IF;
	  return l_id;

       ELSE
	  IF l_debug_level  > 0 THEN
	     oe_debug_pub.add(  'AAC: not found party_site_id in 1st try; trying SQL2' ) ;
	  END IF;

	  SELECT site.party_site_id
	   INTO l_id
	   FROM hz_locations loc,
	   hz_party_sites site
	   WHERE loc.ADDRESS1  = p_site_address1
	   AND nvl( loc.ADDRESS2, fnd_api.g_miss_char) =
	   nvl( p_site_address2, fnd_api.g_miss_char)
	   AND nvl( loc.ADDRESS3, fnd_api.g_miss_char) =
	   nvl( p_site_address3, fnd_api.g_miss_char)
	   AND DECODE(loc.CITY,NULL,NULL,loc.CITY||', ')||
	   DECODE(loc.STATE, NULL, NULL, loc.STATE || ', ')||
	   DECODE(POSTAL_CODE, NULL, NULL, loc.POSTAL_CODE || ', ')||
	   DECODE(loc.COUNTRY, NULL, NULL, loc.COUNTRY) =
	   nvl( p_site_address4, fnd_api.g_miss_char)
	   AND site.status = 'A'
	   and site.location_id=loc.location_id;

	IF l_debug_level  > 0 THEN
	   oe_debug_pub.add(  '  found site_use_id = '||L_ID ) ;
	 END IF;

    END IF;
    CLOSE C2;

    RETURN l_id;
 END IF;



EXCEPTION

   WHEN NO_DATA_FOUND THEN

      IF (c_party_site_id%ISOPEN) then
	 CLOSE c_party_site_id;
      END IF;


      IF C2%ISOPEN then
	 CLOSE C2;
      END IF;

      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
      THEN

	 fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
	 FND_MESSAGE.SET_TOKEN('ATTRIBUTE','get_party_site_id');
	 OE_MSG_PUB.Add;

      END IF;

      RETURN NULL;

  WHEN OTHERS THEN

  IF c_party_site_id%ISOPEN then
     CLOSE c_party_site_id;
  END IF;

  IF C2%ISOPEN then
     CLOSE C2;
  END IF;

  IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN
     OE_MSG_PUB.Add_Exc_Msg
	(   G_PKG_NAME
            ,   'get_party_site_id'
            );
  END IF;

  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END get_party_site_id;



FUNCTION Sold_To_Org
(   p_sold_to_org                   IN  VARCHAR2
,   p_customer_number               IN  VARCHAR2
,   p_site_use_code                 IN VARCHAR2
) RETURN NUMBER
IS
	l_id                          NUMBER;
	--
	l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
	--
BEGIN

    IF  nvl(p_sold_to_org,fnd_api.g_miss_char) = fnd_api.g_miss_char
	   AND nvl(p_customer_number,fnd_api.g_miss_char) = fnd_api.g_miss_char
    THEN
        RETURN NULL;
    END IF;


    IF nvl(p_customer_number,fnd_api.g_miss_char) <> fnd_api.g_miss_char THEN

      SELECT ORGANIZATION_ID
      INTO l_id
      FROM OE_SOLD_TO_ORGS_V
      WHERE CUSTOMER_NUMBER = p_customer_number;

   ELSE
      Select  Cust_Acct.Cust_account_id
	 into l_id
	 from HZ_CUST_ACCOUNTS  Cust_Acct,
	 HZ_PARTIES Party
	 where Cust_Acct.Party_id = Party.party_id
	 and cust_acct.status='A'
	  and Party.Party_name = p_sold_to_org;

    END IF;

    RETURN l_id;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            fnd_message.set_name('ONT','OE_VALUE_TO_ID_ERROR');
	    --{bug 4240715
		if p_site_use_code is NULL or p_site_use_code = 'SOLD_TO' then
       	 FND_MESSAGE.SET_TOKEN('ATTRIBUTE','sold_to_org_id');
	 elsif p_site_use_code ='SHIP_TO' then
	 FND_MESSAGE.SET_TOKEN('ATTRIBUTE','ship_to_org_id');
	 elsif p_site_use_code ='BILL_TO' then
	 FND_MESSAGE.SET_TOKEN('ATTRIBUTE','bill_to_org_id');
	 elsif p_site_use_code ='DELIVER_TO' then
	 FND_MESSAGE.SET_TOKEN('ATTRIBUTE','deliver_to_org_id');
	 elsif p_site_use_code ='END_CUST' then
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE','end_customer_id');
         end if;
           -- FND_MESSAGE.SET_TOKEN('ATTRIBUTE','sold_to_org_id');
	--bug 4240715}
            OE_MSG_PUB.Add;

        END IF;

        RETURN FND_API.G_MISS_NUM;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Sold_To_Org'
            );
        END IF;

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Sold_To_Org;

PROCEDURE does_Cust_Exist(p_cust_id IN NUMBER,				--(5255840)
			 x_found OUT NOCOPY VARCHAR2)
IS

pragma autonomous_transaction;

BEGIN
		select 'Y' into x_found from HZ_CUST_ACCOUNTS where cust_account_id= p_cust_id;
EXCEPTION
		WHEN NO_DATA_FOUND THEN
		x_found:='N';

		WHEN OTHERS THEN
		oe_debug_pub.add('Yes... Error in Autonomous Block:'||SQLERRM);
		x_found:='E';
END;

--------------------------------------------------------------
FUNCTION CUST_EXISTS(cust_id number) return Boolean IS		--(5255840)
--------------------------------------------------------------------
l_temp			varchar2(2);
BEGIN

	does_Cust_Exist(p_cust_id => cust_id,
			x_found => l_temp);
	oe_debug_pub.add('Yes.. does_Cust_Exist:'||l_temp);
	IF l_temp='Y' THEN
		return TRUE;
	ELSIF l_temp='N' THEN
		oe_debug_pub.add('Yes.. Committing');
		COMMIT;
		return TRUE;
	ELSE
		return FALSE;
	END IF;

EXCEPTION WHEN OTHERS THEN
		oe_debug_pub.add('Yes... Error in CUST_EXISTS:'||SQLERRM);
		return FALSE;
END Cust_Exists;

END oe_create_account_info;

/
