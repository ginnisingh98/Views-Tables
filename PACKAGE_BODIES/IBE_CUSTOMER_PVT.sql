--------------------------------------------------------
--  DDL for Package Body IBE_CUSTOMER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_CUSTOMER_PVT" AS
/* $Header: IBEVACTB.pls 120.6.12010000.2 2009/06/03 10:02:51 scnagara ship $ */

l_true VARCHAR2(1) := FND_API.G_TRUE;


--PROCEDURE Set_Bank_Acct_End_Date : This API has been removed: mannamra:10/07/2005



/*
 *PROCEDURE:
 *      setOptInOutPreference
 *DESCRIPTION:
 *      -calls HZ_CONTACT_PREFERENCE_V2PUB to update the preference code
 *      -creates a row in HZ_CONTACT_PREFERENCES if no row exists for party_id
 */
PROCEDURE setOptInOutPreference(
    p_party_id           IN    NUMBER,
    p_preference         IN    VARCHAR2,
    p_init_msg_list      IN    VARCHAR2 := FND_API.G_TRUE,
    p_commit             IN    VARCHAR2 := FND_API.G_FALSE,
    p_api                IN    NUMBER,
    x_return_status      OUT  NOCOPY VARCHAR2,
    x_msg_count          OUT  NOCOPY NUMBER,
    x_msg_data           OUT  NOCOPY VARCHAR2

   )
IS
    l_contact_preference_rec                hz_contact_preference_v2pub.contact_preference_rec_type;
    l_contact_preference_rec2               hz_contact_preference_v2pub.contact_preference_rec_type;
    l_contact_preference_id                 NUMBER;
    l_object_version_number                 NUMBER;
    l_id                                    NUMBER;
    l_date                                  DATE;
    l_obj_ver                               NUMBER;

BEGIN
    --IBE_UTIL.enable_debug();
    -- standard start of API savepoint
    SAVEPOINT setOptInOutPreference;

    -- standard call to check for call compatibility
    IF NOT FND_API.compatible_api_call(1.0,
                                       p_api,
                                       'getOptInOutPreference',
                                       G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --begin set/create contact preferences
    BEGIN
      SELECT contact_preference_id, last_update_date, object_version_number
      INTO   l_id, l_date, l_obj_ver
      From   hz_contact_preferences
      WHERE  contact_level_table='HZ_PARTIES'
      AND    contact_level_table_id=p_party_id;
      --update reason_code if record found
      l_contact_preference_rec.contact_preference_id := l_id;
      l_contact_preference_rec.preference_code := p_preference;
      l_object_version_number := l_obj_ver;
      HZ_CONTACT_PREFERENCE_V2PUB.update_contact_preference(
            FND_API.G_FALSE,
            l_contact_preference_rec,
            l_object_version_number,
            x_return_status,
            x_msg_count,
            x_msg_data
        );

      --create row when no record found
      EXCEPTION WHEN NO_DATA_FOUND THEN
        l_contact_preference_rec2.contact_level_table := 'HZ_PARTIES';
        l_contact_preference_rec2.contact_level_table_id := p_party_id;
        l_contact_preference_rec2.contact_type := 'ALL';
        l_contact_preference_rec2.preference_code := p_preference;
        l_contact_preference_rec2.requested_by := 'INTERNAL';
        l_contact_preference_rec2.status := 'A';
        l_contact_preference_rec2.created_by_module := 'TCA_V1_API';
        HZ_CONTACT_PREFERENCE_V2PUB.create_contact_preference(
                FND_API.G_FALSE,
                l_contact_preference_rec2,
                l_contact_preference_id,
                x_return_status,
                x_msg_count,
                x_msg_data
        );
    END;
    --end set/create contact preferences


    -- standard check of p_commit
    IF FND_API.to_boolean(p_commit) THEN
      commit;
    END IF;
    -- standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data => x_msg_data
    );
    --IBE_UTIL.disable_debug();

--standard exception catching for main body
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    --IBE_UTIL.enable_debug();

    ROLLBACK TO setOptInOutPreference;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data => x_msg_data
    );
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('G_EXC_ERROR exception');
       IBE_UTIL.debug('x_msg_count ' || to_char(x_msg_count));
       IBE_UTIL.debug('x_msg_data ' || x_msg_data);
       IBE_UTIL.debug('error code : '|| to_char(SQLCODE));
       IBE_UTIL.debug('error text : '|| SQLERRM);
    END IF;

    --IBE_UTIL.disable_debug();

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --IBE_UTIL.enable_debug();

    ROLLBACK TO setOptInOutPreference;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data => x_msg_data
    );
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('G_EXC_UNEXPECTED_ERROR exception');
       IBE_UTIL.debug('x_msg_count ' || to_char(x_msg_count));
       IBE_UTIL.debug('x_msg_data ' || x_msg_data);
       IBE_UTIL.debug('error code : '|| to_char(SQLCODE));
       IBE_UTIL.debug('error text : '|| SQLERRM);
    END IF;

    --IBE_UTIL.disable_debug();

  WHEN OTHERS THEN
    --IBE_UTIL.enable_debug();

    ROLLBACK TO setOptInOutPreference;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data => x_msg_data
    );
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('OTHER exception');
       IBE_UTIL.debug('x_msg_count ' || to_char(x_msg_count));
       IBE_UTIL.debug('x_msg_data ' || x_msg_data);
       IBE_UTIL.debug('error code : '|| to_char(SQLCODE));
       IBE_UTIL.debug('error text : '|| SQLERRM);
    END IF;

    --IBE_UTIL.disable_debug();

END setOptInOutPreference;



/* Local Function to get credit card type given the number

   -- Input Parameter(s)
       - p_credit_card_number NUMBER
   -- Returns
         Credit_card_type VARCHAR2
*/
function get_credit_card_type(
     --fix 2861827
     --p_Credit_Card_Number NUMBER
     p_Credit_Card_Number VARCHAR2
) RETURN VARCHAR2
AS
     l_credit_Card_number Varchar2(30);
     l_credit_card_length Number;
Begin
    --fix 2861827
     --l_credit_card_number := to_char(p_credit_card_number);
     l_credit_card_number := p_credit_card_number;
     l_credit_card_length := length(l_credit_card_number);

     If (l_credit_Card_length = 16 and substr(l_credit_card_number,1,2) in ('51','52','53','54','55') ) Then
          Return ('MC');
     Elsif ((l_credit_Card_length = 13 or l_credit_card_length = 16)  and substr(l_credit_card_number,1,1) = '4') Then
          Return ('VISA');
     Elsif (l_credit_Card_length = 15 and substr(l_credit_card_number,1,2) in ('34','37')) Then
          Return ('AMEX');
     Elsif (l_credit_card_length = 14 and substr(l_credit_card_number,1,3) in ('300','301','302','303','305','36','38')) Then
          Return('DINERS');
     Elsif (l_credit_card_length = 16 and substr(l_credit_card_number,1,4) = '6011')Then
          Return ('DISCOVER');
     Elsif ((l_credit_card_length = 15 and substr(l_credit_card_number,1,4) in ('2014','2149')) or
     ((l_credit_card_length = 15 or l_credit_card_length = 16) and (substr(l_credit_card_number,1,1) = '3' or substr(l_credit_card_number,1,4) in ('2131','1800')))) Then
          Return ('OTHERS');
     Else
          Return('ERROR');
     End If;

End get_credit_card_type;


-- This procedure will return a valid credit card information
-- if it can find a default credit card.
procedure get_default_credit_card_info(
    p_api_version            IN  NUMBER,
    p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
    p_cust_account_id        IN  NUMBER,
    p_party_id               IN  NUMBER,
    p_mini_site_id           IN  NUMBER,
    x_return_status          OUT NOCOPY VARCHAR2,
    x_msg_count              OUT NOCOPY NUMBER,
    x_msg_data               OUT NOCOPY VARCHAR2,
    x_cc_assignment_id        OUT NOCOPY NUMBER
                              )
IS
  l_api_name               CONSTANT VARCHAR2(30) := 'get_default_credit_card_info';
  l_api_version            CONSTANT NUMBER       := 1.0;

  prm_bank_acct_num AP_BANK_ACCOUNTS.BANK_ACCOUNT_NUM%TYPE := NULL;
  prm_inactive_date AP_BANK_ACCOUNTS.INACTIVE_DATE%TYPE := NULL;
  prm_acct_holder_name AP_BANK_ACCOUNTS.BANK_ACCOUNT_NAME%TYPE := NULL;
  prm_credit_card_type VARCHAR2(50) := NULL;

  def_bank_acct_num AP_BANK_ACCOUNTS.BANK_ACCOUNT_NUM%TYPE := NULL;
  def_inactive_date AP_BANK_ACCOUNTS.INACTIVE_DATE%TYPE := NULL;
  def_acct_holder_name AP_BANK_ACCOUNTS.BANK_ACCOUNT_NAME%TYPE:= NULL;
  def_credit_card_type VARCHAR2(50) := NULL;

  l_credit_card_type VARCHAR2(50) := NULL;



  CURSOR c_getPrimaryCCInfo(l_cust_acct_id NUMBER,l_party_id NUMBER,l_msite_id NUMBER) IS
 SELECT assign.instr_assignment_id
         FROM   iby_fndcpt_payer_assgn_instr_v assign
         WHERE  assign.party_id = l_party_id
         AND    assign.order_of_preference = 1
         AND    assign.org_id is null
         AND    assign.cust_account_id is null
         AND    assign.instrument_type = 'CREDITCARD'
         and    assign.ACCT_SITE_USE_ID is null
         AND    nvl(CARD_EXPIRYDATE, sysdate) >= sysdate
         and
			 exists
			 (select msite_information1
			  from ibe_msite_information m, fnd_lookup_values b
		       where
				   m.msite_id =l_msite_id and
				   b.lookup_type = 'CREDIT_CARD' and
				   b.view_application_id = 660 and
			        b.enabled_flag = 'Y' and
				 (b.tag = 'Y' or b.tag is null) and
				   b.language = userenv('lang') and
				msite_information_context = 'CC_TYPE' and
			--	  b.lookup_code = msite_information1		 -- bug 8550854, scnagara
			decode(b.lookup_code, 'MASTERCARD', 'MASTERCARD','MC', 'MASTERCARD', b.lookup_code)  = msite_information1
                     and msite_information1 = assign.card_issuer_code);

CURSOR c_getFirstCCInfo(l_cust_acct_id NUMBER,l_party_id NUMBER,l_msite_id NUMBER) IS
        SELECT assign.instr_assignment_id
         FROM   iby_fndcpt_payer_assgn_instr_v assign
        WHERE  assign.party_id = l_party_id
         AND    assign.org_id is null
         AND    assign.cust_account_id is null
         AND    assign.instrument_type = 'CREDITCARD'
         and    assign.ACCT_SITE_USE_ID is null
         AND    nvl(CARD_EXPIRYDATE, sysdate) >= sysdate
         and
                exists
               (select msite_information1
                from ibe_msite_information m, fnd_lookup_values b
                where
                      m.msite_id = l_msite_id and
                      b.lookup_type = 'CREDIT_CARD' and
                      (b.tag = 'Y' or b.tag is null) and
                      b.language = userenv('lang') and
                      msite_information_context = 'CC_TYPE' and
                  --  b.lookup_code = msite_information1	 -- bug 8550854, scnagara
		   decode(b.lookup_code, 'MASTERCARD', 'MASTERCARD','MC', 'MASTERCARD', b.lookup_code) = msite_information1
                and msite_information1 = assign.card_issuer_code)
                and rownum < 2
        order by assign.order_of_preference asc;

        l_def_cc_assignment_id NUMBER;
        l_cc_assignment_id NUMBER;
BEGIN

  --IBE_UTIL.enable_debug();

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.debug('enter ibe_customer_pvt.get_default_credit_card_info');
  END IF;


  IF NOT FND_API.compatible_api_call(l_api_version,
                                     p_api_version,
                                     l_api_name,
                                     G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

    -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;


  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.debug('call cursor c_getPrimaryCCInfo()');
  END IF;
  -- call cursor c_getPrimaryInfo

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.debug('cust_acct_id = '||p_cust_account_id||'party_id = '||p_party_id||' minisite_id : '||p_mini_site_id);
  END IF;

  OPEN c_getPrimaryCCInfo(p_cust_account_id,p_party_id,p_mini_site_id);

  FETCH c_getPrimaryCCInfo INTO l_cc_assignment_id ;

 IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.debug('call cursor c_getFirstCCInfo()');
 END IF;
  OPEN c_getFirstCCInfo(p_cust_account_id,p_party_id,p_mini_site_id);

  FETCH c_getFirstCCInfo INTO l_def_cc_assignment_id;

  if c_getPrimaryCCInfo%FOUND then
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.debug('Primary CC found');
      END IF;

     x_cc_assignment_id:= l_cc_assignment_id;
       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('x_cc_assign_id : '||l_cc_assignment_id);
      END IF;
 --else
   --IBE_UTIL.debug('No Primary Info found');
   --close c_getPrimaryCCInfo;
 --end if;
 elsif (c_getFirstCCInfo%FOUND) then

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.debug('Default CC found ');
      END IF;

        x_cc_assignment_id := l_def_cc_assignment_id;
          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('x_def_cc_assign_id : '||l_def_cc_assignment_id);
      END IF;
 else

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.debug(' No default Credit card info found ');
      END IF;
      close c_getFirstCCInfo;
      close c_getPrimaryCCInfo;
end if;

    /* 3/3/05: comment out
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('x_credit_card_num : '||x_credit_card_num);
        IBE_UTIL.debug('x_card_holder_name : '||x_card_holder_name);
        IBE_UTIL.debug('x_credit_card_exp_date : '||x_credit_card_exp_date);
        IBE_UTIL.debug('x_credit_card_type : '||x_credit_card_type);
    END IF;
    */


    x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- standard check of p_commit
  IF FND_API.to_boolean(p_commit) THEN
    commit;
  END IF;

  -- standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.G_FALSE,
    p_count => x_msg_count,
    p_data => x_msg_data
  );


  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.debug('exit ibe_customer_pvt.get_default_credit_card_info');
  END IF;

  --IBE_UTIL.disable_debug();

EXCEPTION

     WHEN FND_API.G_EXC_ERROR THEN
    --IBE_UTIL.enable_debug();

     --ROLLBACK TO create_credit_card;

     x_return_status := FND_API.G_RET_STS_ERROR;
	FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('G_EXC_ERROR exception');
       IBE_UTIL.debug('x_msg_count ' || to_char(x_msg_count));
       IBE_UTIL.debug('x_msg_data ' || x_msg_data);
       IBE_UTIL.debug('error code : '|| to_char(SQLCODE));
       IBE_UTIL.debug('error text : '|| SQLERRM);
    END IF;


    --IBE_UTIL.disable_debug();




    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    --IBE_UTIL.enable_debug();

     --ROLLBACK TO create_credit_card;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
                               p_data       =>      x_msg_data,
                               p_encoded    =>      'F');

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('G_EXC_UNEXPECTED_ERROR exception');
       IBE_UTIL.debug('x_msg_count ' || to_char(x_msg_count));
       IBE_UTIL.debug('x_msg_data ' || x_msg_data);
       IBE_UTIL.debug('error code : '|| to_char(SQLCODE));
       IBE_UTIL.debug('error text : '|| SQLERRM);
    END IF;

    --IBE_UTIL.disable_debug();




    WHEN OTHERS THEN
    --IBE_UTIL.enable_debug();

     --ROLLBACK TO create_credit_card;
     FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
     FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
     FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
     FND_MESSAGE.Set_Token('REASON', SQLERRM);
     FND_MSG_PUB.Add;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	 FND_MSG_PUB.Add;
	 FND_MSG_PUB.Count_And_Get(p_count      =>      x_msg_count,
		  				  p_data       =>      x_msg_data,
						  p_encoded    =>      'F');


    --IBE_UTIL.debug('OTHER exception');
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('x_msg_count ' || to_char(x_msg_count));
       IBE_UTIL.debug('x_msg_data ' || x_msg_data);
       IBE_UTIL.debug('error code : '|| to_char(SQLCODE));
       IBE_UTIL.debug('error text : '|| SQLERRM);
    END IF;

    --IBE_UTIL.disable_debug();




END;

-- This procedure gets the primary credit card id if it already exists

procedure get_primary_credit_card_id(p_username         IN VARCHAR2,
                                     x_credit_card_id   OUT NOCOPY NUMBER)
IS

cursor C_get_primary_credit_card(c_party_id NUMBER) is
SELECT instr_assignment_id
FROM   IBY_FNDCPT_PAYER_ASSGN_INSTR_V
WHERE  party_id          = c_party_id
AND    org_id            is null
AND    cust_account_id   is null
AND    acct_site_use_id  IS NULL
AND    instrument_type   = 'CREDITCARD'
AND    payment_function  = 'CUSTOMER_PAYMENT'
and    order_of_preference = 1;

cursor C_get_party_cust_accnt(c_username VARCHAR2) is
SELECT customer_id, person_party_id
FROM    fnd_user
WHERE  user_name = c_username;

rec_get_primary_credit_card c_get_primary_credit_card%rowtype;
rec_get_party_cust_accnt    c_get_party_cust_accnt%rowtype;

l_customer_id     NUMBER;
l_person_party_id NUMBER;
l_assignment_id   NUMBER;
l_party_to_use    NUMBER;

BEGIN
  --IBE_UTIL.enable_debug();

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.debug('enter ibe_customer_pvt.get_primary_credit_card_id');
  END IF;

  FOR rec_get_party_cust_accnt in C_get_party_cust_accnt(p_username) LOOP
    l_customer_id     := rec_get_party_cust_accnt.customer_id;
    l_person_party_id := rec_get_party_cust_accnt.person_party_id;
    exit when c_get_party_cust_accnt%notfound;
  END LOOP;

  IF (l_customer_id is null) THEN
    l_party_to_use := l_person_party_id;
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.debug('customer_id does not have any value, using the person_party_id');
    END IF;
  ELSE
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.debug('customer_id has a value,l_party_to_use: '||l_customer_id);
    END IF;
    l_party_to_use := l_customer_id;
  END IF;

  FOR rec_get_primary_credit_card in c_get_primary_credit_card(l_party_to_use) LOOP
    l_assignment_id := rec_get_primary_credit_card.instr_assignment_id;
    EXIT when c_get_primary_credit_card%NOTFOUND;
  END LOOP;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.debug('primary card asignment id is '||l_assignment_id);
  END IF;
  x_credit_card_id := l_assignment_id;
END ;


-- This procedure updates the primary credit card id if it already exists,
-- it also sets the primary credit card id if it does not exists.

/*procedure set_primary_credit_card_id: mannamra: 11/14/2005 : Bug 4725304: This API can be obsoleted because it is
used to set the value of FND Preference PRIMARY_CARD but going forward primary credit card setting will be
@ done in iPayment schema. */


-- This procedure creates a new credit card by calling
-- arp_bank_pkg.process_bank_account. It also sets the
-- new credit card id as primary credit card if a primary
-- credit card id does not exists.

/*procedure create_credit_card: mannamra: 11/14/2005 : Bug 4725304:  This API can be obsoleted because it is used to create a credit card in AP's
@ Bank Accouts' schema but going forward credit cards will be stored in
@ iPayment schema. IBE_PAYMENT_INT_PVT.saveCC() will be used to perform this
 operation.*/


END ibe_customer_pvt;

/
