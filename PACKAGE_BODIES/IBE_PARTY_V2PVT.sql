--------------------------------------------------------
--  DDL for Package Body IBE_PARTY_V2PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_PARTY_V2PVT" AS
/* $Header: IBEVPARB.pls 120.6.12010000.2 2016/07/29 11:59:55 kdosapat ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'IBE_PARTY_V2PVT';
G_CREATED_BY_MODULE VARCHAR2(30) := 'USER REGISTRATION';
G_APPLICATION_ID NUMBER := 671;
l_true VARCHAR2(1) := FND_API.G_TRUE;

-----------------------public procedures -------------------------------------
/*=======================================================================
|    Copyright (c) 1999 Oracle Corporation, Redwood Shores, CA, USA
|                         All rights reserved.
|=======================================================================
| PROCEDURE NAME
|    Create_Individual_User
|
| DESCRIPTION
|    This API is called during Individuale User Registration
|
| USAGE
|    -      Create a party in HzParties table.
|    -	Creates Contact Points
|    -	Creates Preferences
|    -	Create an apps username/password combination in FND_USER table.
|
|    -      Link the fnd_user table and hz_parties table by setting
|    	    the customer_id column in fnd_user table.
|  REFERENCED APIS
|     This API calls the following APIs
|     - Create_Person
|     - Create_Contact_Preference
|     - Create_User
|
|=======================================================================*/

Procedure Create_Individual_User(
        p_username		IN	VARCHAR2,
        p_password		IN	VARCHAR2,
        p_person_rec 		IN	HZ_PARTY_V2PUB.person_rec_type,
        p_email_rec 		IN	HZ_CONTACT_POINT_V2PUB.email_rec_type,
        p_work_phone_rec 	IN	HZ_CONTACT_POINT_V2PUB.phone_rec_type,
        p_home_phone_rec 	IN	HZ_CONTACT_POINT_V2PUB.phone_rec_type,
        p_fax_rec	 		IN	HZ_CONTACT_POINT_V2PUB.phone_rec_type,
        p_contact_preference 	IN	VARCHAR2,
        x_person_party_id	OUT NOCOPY	NUMBER,
        x_user_id			OUT NOCOPY	NUMBER,
        x_return_status  	OUT NOCOPY	VARCHAR2,
        x_msg_count  		OUT NOCOPY	NUMBER,
        x_msg_data 	  	OUT NOCOPY	VARCHAR2) is

     l_preference		VARCHAR2(30);
     l_reference_id	NUMBER;
     l_contact_preference_id NUMBER;

     l_account_id NUMBER;
BEGIN
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('enter ibe_party_v2pvt.create_individual_user');
    END IF;



	-- initialize message list
    FND_MSG_PUB.initialize;


	-- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('Call Create_Person() API');
    END IF;

	-- calling internal API to create_person

    Create_Person(p_person_rec => p_person_rec,
            p_email_rec  => p_email_rec,
            p_work_phone_rec => p_work_phone_rec,
            p_home_phone_rec => p_home_phone_rec,
            p_fax_rec => p_fax_rec,
            p_created_by_module =>G_CREATED_BY_MODULE,
            p_account => 'false',
            x_account_id => l_account_id,
            x_person_party_id => x_person_party_id,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data);

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('After call to Create_Person - x_return_status : '|| x_return_status);
       IBE_UTIL.debug('After call to Create_Person - x_msg_count: '|| x_msg_count);
       IBE_UTIL.debug('After call to Create_Person - x_msg_data : '|| x_msg_data);
    END IF;
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('After call to Create_Person - party_id : ' || x_person_party_id);
    END IF;


       -- set the preference value and call update_contact_preference
	 -- to send marketing/promotional emails

	if p_contact_preference = 'YES' then
	   l_preference := 'DO';
	else
         l_preference := 'DO_NOT';
    end if;

IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   	IBE_UTIL.debug('Before call to Update_Contact_Preference');
END IF;

	Update_Contact_Preference(p_party_id => x_person_party_id,
					p_preference => l_preference,
                    		p_object_version_number => null,
					p_created_by_module => G_CREATED_BY_MODULE,
					x_return_status => x_return_status,
					x_msg_count => x_msg_count,
					x_msg_data => x_msg_data);

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       	IBE_UTIL.debug('After call to Update_Contact_Preference - x_return_status : '|| x_return_status);
   	IBE_UTIL.debug('After call to Update_Contact_Preference - x_msg_count : '|| x_msg_count);
   	IBE_UTIL.debug('After call to Update_Contact_Preference  - x_msg_data : '|| x_msg_data);
    END IF;

	IF x_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
	ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('After call to Update_Contact_Preference - x_contact_preference_id : ' || l_contact_preference_id);
    END IF;


	-- Call Create_User to create user in FND by setting
    -- by setting the customer_id column from fnd_user table
	-- to person_party_id
   IF (p_username <> FND_API.G_MISS_CHAR and p_username is not null) then
	IBE_USER_PVT.Create_User(p_user_name => p_username,
			p_password => p_password,
			p_start_date => sysdate,
			p_end_date => null,
			p_password_date => sysdate,
			p_email_address => p_email_rec.email_address,
          		p_customer_id => x_person_party_id,
			x_user_id => x_user_id);

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       	IBE_UTIL.debug('After call to Create_User - x_user_id : '|| to_char(x_user_id));
    END IF;

	if (x_user_id is null) then
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    	end if;
   END IF;



	-- standard call to get message count and if count is 1, get message info
	FND_MSG_PUB.count_and_get(
	    p_encoded => FND_API.G_FALSE,
		p_count => x_msg_count,
		p_data => x_msg_data
		  );

     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.debug('exit ibe_party_v2.create_individual_user');
     END IF;


EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN



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

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN


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

    WHEN OTHERS THEN


    FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
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

END create_individual_user;

/*=======================================================================
|    Copyright (c) 1999 Oracle Corporation, Redwood Shores, CA, USA
|                         All rights reserved.
+=======================================================================
| PROCEDURE NAME
|    Create_Business_User
|
| DESCRIPTION
|    This API is called during Business User Registration
|
| USAGE
|    -      Create an Organization if organization does not exists
|    -      Create a party in HzParties table.
|    -	Record the organizations location and contact points
|    -	Register the user as an org contact for the organization
|    -	Create an apps username/password combination in FND_USER table.
|
|    -      Link the fnd_user table and hz_parties table by setting
|    	the customer_id column in fnd_user table as the relationship_party_id.
|
|  REFERENCED APIS
|     This API calls the following APIs
|     - Find_Organizatio n
|     - Create_Organization
|     - Create_Org_Contact
|     - Update_Contact_Preference
|     - Create_User
|
+=======================================================================*/

Procedure Create_Business_User(
		p_username    	       	IN	VARCHAR2,
		p_password         	IN	VARCHAR2,
		p_person_rec 	    	IN	HZ_PARTY_V2PUB.person_rec_type,
     	p_organization_rec    	IN	HZ_PARTY_V2PUB.organization_rec_type,
     	p_location_rec         	IN	HZ_LOCATION_V2PUB.location_rec_type,
     	p_org_phone_rec     	IN	HZ_CONTACT_POINT_V2PUB.phone_rec_type,
     	p_org_fax_rec  		IN	HZ_CONTACT_POINT_V2PUB.phone_rec_type,
		p_rel_workphone_rec 	IN	HZ_CONTACT_POINT_V2PUB.phone_rec_type,
     	p_rel_homephone_rec 	IN	HZ_CONTACT_POINT_V2PUB.phone_rec_type,
     	p_rel_fax_rec	     	IN	HZ_CONTACT_POINT_V2PUB.phone_rec_type,
		p_rel_email_rec	    	IN	HZ_CONTACT_POINT_V2PUB.email_rec_type,
		p_rel_contact_preference 	IN	VARCHAR2,
		x_person_party_id     	OUT NOCOPY	NUMBER,
     	x_rel_party_id       	OUT NOCOPY	NUMBER,
     	x_org_party_id        	OUT NOCOPY	NUMBER,
		x_user_id               OUT NOCOPY	NUMBER,
     	x_return_status      	OUT NOCOPY	VARCHAR2,
     	x_msg_count    		OUT NOCOPY	NUMBER,
     	x_msg_data       	OUT NOCOPY	VARCHAR2) is

     	l_preference	VARCHAR2(30);
		l_preference_id	NUMBER;
 		l_rel_party_id    NUMBER;    ---party_id of type party_relationship
     	l_contact_preference_id NUMBER;
		l_party_site_id	NUMBER;


   		p_org_name HZ_PARTIES.PARTY_NAME%TYPE := null;
   		p_org_num  HZ_PARTIES.PARTY_NUMBER%TYPE   := null;
        	l_account_id NUMBER;
   		--p_party_rec HZ_PARTY_V2PUB.party_rec_type;
BEGIN
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('enter ibe_party_v2pvt.create_business_user');
    END IF;


	-- initialize message list
	FND_MSG_PUB.initialize;


	-- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Check whether Organization exists

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('Party_number : '||p_organization_rec.party_rec.party_number);
    END IF;
   if (( p_organization_rec.party_rec.party_number is not null) AND
       ( p_organization_rec.party_rec.party_number  <> FND_API.G_MISS_CHAR)) then
    p_org_num := p_organization_rec.party_rec.party_number;
   end if;
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('Party_name : '||p_organization_rec.organization_name);
    END IF;
   if ((p_organization_rec.organization_name is not null) AND
     (p_organization_rec.organization_name <> FND_API.G_MISS_CHAR)) then
    p_org_name := p_organization_rec.organization_name;
   end if;
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('p_org_num : '||p_org_num);
       IBE_UTIL.debug('p_org_name : '||p_org_name);
       IBE_UTIL.debug('Before p_org_nname not null');
    END IF;
    --p_org_name := p_organization_rec.organization_name;

    if ((p_org_name is not null) ) then
   /* Removing duplicate org name check */
   /*    IBE_UTIL.debug('Call Find_Organization()in p_org_name not null API');

        If (  Find_Organization(x_org_id => x_org_party_id,
                                x_org_num => p_org_num,
                                x_org_name =>p_org_name
                                         ))   then
          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
             IBE_UTIL.debug('Inside find_organization - x_org_party_id : '||x_org_party_id);
   		  IBE_UTIL.debug('Inside find_organization - x_org_num : '||p_org_num);
   		  IBE_UTIL.debug('Inside find_organization - x_org_name : '||p_org_name);
          END IF;

             FND_MESSAGE.SET_NAME('IBE','IBE_ERR_UM_ORG_EXISTS');
             FND_MSG_PUB.ADD;
             RAISE FND_API.G_EXC_ERROR;
        end if;
      else
*/
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_UTIL.debug('Before Call to Create Organization');
   	IBE_UTIL.debug('Before Call to Create Organization address1 :'|| p_location_rec.address1);
           IBE_UTIL.debug('Before Call to Create Organization country :'||p_location_rec.country);
           IBE_UTIL.debug('Before Call to Create Organization city :'||p_location_rec.city);
        END IF;
        Create_Organization(
               p_organization_rec =>p_organization_rec,
               p_location_rec =>p_location_rec,
               p_party_site_rec => null,
               p_org_workphone_rec =>p_org_phone_rec,
               /*p_org_homephone_rec => null,*/
               p_org_fax_rec => p_org_fax_rec,
			p_primary_billto => FND_API.G_TRUE,
			p_primary_shipto => FND_API.G_TRUE,
			p_billto => FND_API.G_TRUE,
			p_shipto => FND_API.G_TRUE,
			p_default_primary => FND_API.G_TRUE,
               p_created_by_module =>G_CREATED_BY_MODULE,
               p_account =>'false',
               x_account_id => l_account_id,
			x_party_site_id => l_party_site_id,
               x_org_party_id =>x_org_party_id,
               x_return_status =>x_return_status,
               x_msg_count =>x_msg_count,
               x_msg_data =>x_msg_data);

               IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                    RAISE FND_API.G_EXC_ERROR;
               ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
            IF (IBE_UTIL.G_DEBUGON = l_true) THEN
               IBE_UTIL.debug('After call to Create_Organization - x_return_status : '|| x_return_status);
   	    IBE_UTIL.debug('After call to Create_Organization - x_msg_count : '|| x_msg_count);
   	    IBE_UTIL.debug('After call to Create_Organization  - x_msg_data : '|| x_msg_data);
           IBE_UTIL.debug('After Create Organization x_org_party_id :' || x_org_party_id);
            END IF;

    elsif  (p_org_num is not null)  then
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_UTIL.debug('Call Find_Organization()in p_org_num not null API');
        END IF;
        if (not Find_Organization(x_org_id => x_org_party_id,
                              x_org_num => p_org_num,
                              x_org_name => p_org_name)) then
              IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                 IBE_UTIL.debug('Inside NOT find_organization - x_org_party_id : '||x_org_party_id);
                         IBE_UTIL.debug('Inside NOT find_organization - x_org_num :'||p_org_num);
                         IBE_UTIL.debug('Inside NOT find_organization - x_org_name : '||p_org_name);
              END IF;
            /* If organization does not exist then raise error */
            FND_MESSAGE.SET_NAME('IBE','IBE_ERR_UM_ORG_NOT_FOUND');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
       end if;


   end if;

    -- Create ORG Contact which internally creates party_relationship
    -- Pass organization party id from the above api and as
    -- p_org_id  to create org contact also pass in the account_id if
    -- cust_account_role needs to be created

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('Before Create_Org_Contact');
    END IF;
    Create_Org_Contact(
           p_person_rec => p_person_rec,
           p_relationship_type => 'EMPLOYEE_OF',
           p_org_party_id  =>x_org_party_id,
           p_email_rec =>p_rel_email_rec,
           p_work_phone_rec =>p_rel_workphone_rec,
           p_home_phone_rec =>p_rel_homephone_rec,
           p_fax_rec => p_rel_fax_rec,
           p_created_by_module =>G_CREATED_BY_MODULE,
           x_person_party_id => x_person_party_id,
           x_rel_party_id => l_rel_party_id,
           x_return_status =>  x_return_status,
           x_msg_count =>  x_msg_count,
           x_msg_data =>  x_msg_data);
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

       x_rel_party_id := l_rel_party_id;

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       	IBE_UTIL.debug('After call to Create_Org_Contact - x_return_status : '|| x_return_status);
   	IBE_UTIL.debug('After call to Create_Org_Contact - x_msg_count : '|| x_msg_count);
   	IBE_UTIL.debug('After call to Create_Org_Contact  - x_msg_data : '|| x_msg_data);
       	IBE_UTIL.debug('After Create_Org_Contact x_rel_party_id: '||x_rel_party_id);
    END IF;
	-- Populate contact_level_id with l_rel_party_id which is the
        -- relationship_id and call Create_Contact_Preference to send marketing/promotional emails

        If p_rel_contact_preference = 'YES' then
           l_preference := 'DO';
        Else
           l_preference := 'DO_NOT';
        End if;

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.debug('Before Update_Contact_Preference');
   END IF;
    Update_Contact_Preference(
                p_party_id => x_rel_party_id ,
                p_preference => l_preference,
                p_object_version_number => null,
                p_created_by_module => G_CREATED_BY_MODULE,
                x_return_status => x_return_status,
                x_msg_count      =>  x_msg_count,
                x_msg_data  =>  x_msg_data)  ;

    if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    end if;

IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   	 IBE_UTIL.debug('After call to Update_Contact_Preference - x_return_status : '|| x_return_status);
   	IBE_UTIL.debug('After call to Update_Contact_Preference - x_msg_count : '|| x_msg_count);
   	IBE_UTIL.debug('After call to Update_Contact_Preference  - x_msg_data : '|| x_msg_data);
END IF;


	-- Call Create_User to create user in FND by setting
      -- by setting the customer_id column from fnd_user table
	-- to x_rel_party_id
     IF (p_username <> FND_API.G_MISS_CHAR and p_username is not null) then
	IBE_USER_PVT.Create_User(p_user_name => p_username,
			p_password => p_password,
			p_start_date => sysdate,
			p_end_date => null,
			p_password_date => sysdate,
			p_email_address => p_rel_email_rec.email_address,
          		p_customer_id => x_rel_party_id,
			x_user_id => x_user_id);

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('After call to Create_User - x_user_id : '|| to_char(x_user_id));
    END IF;

	if (x_user_id is null) then
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    end if;


     END IF;

	-- standard call to get message count and if count is 1, get message info
	FND_MSG_PUB.count_and_get(
	      p_encoded => FND_API.G_FALSE,
		  p_count => x_msg_count,
		  p_data => x_msg_data
		  );

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('exit ibe_party_v2.create_business_user');
    END IF;


EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN



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

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN


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

    WHEN OTHERS THEN


    FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
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

END;



/*+=======================================================================
|    Copyright (c) 1999 Oracle Corporation, Redwood Shores, CA, USA
|                         All rights reserved.
+=======================================================================
| PROCEDURE NAME
|    Create_Org_Contact
|
| DESCRIPTION
|    This API is called during Business User Registration and while
|    creating Contacts in User Management
|
| USAGE
|    -      Create a party in HzParties table.
|    -      Creates the user as the org contact for the organization
|    -	Creates COntact Points
|
|  REFERENCED APIS
|     This API calls the following APIs
|     - Create_Person
|     - HZ_PARTY_CONTACT_V2PUB.create_org_contact
|     - Create_Contact_Points
|
+=======================================================================*/

Procedure Create_Org_Contact(
	     p_person_rec		IN	HZ_PARTY_V2PUB.person_rec_type,
         	p_relationship_type	IN	VARCHAR2,   -- 'EMPLOYEE_OF' or 'CONTACT_OF'
		p_org_party_id		IN    NUMBER,
	     p_work_phone_rec    	IN	HZ_CONTACT_POINT_V2PUB.phone_rec_type,
         	p_home_phone_rec    	IN	HZ_CONTACT_POINT_V2PUB.phone_rec_type,
         	p_fax_rec      	 	IN	HZ_CONTACT_POINT_V2PUB.phone_rec_type,
	     p_email_rec       	IN	HZ_CONTACT_POINT_V2PUB.email_rec_type,
	     p_created_by_module 	IN	VARCHAR2,
	     x_person_party_id     	OUT NOCOPY	NUMBER,
         	x_rel_party_id 		OUT NOCOPY	NUMBER,
         	x_return_status      	OUT NOCOPY	VARCHAR2,
         	x_msg_count     	 	OUT NOCOPY	NUMBER,
         	x_msg_data      	  	OUT NOCOPY	VARCHAR2) is

         l_party_rel_rec	HZ_RELATIONSHIP_V2PUB.relationship_rec_type;
         l_org_contact_party_id NUMBER;
         l_rel_id             NUMBER;
         l_account_id		NUMBER;
         l_rel_party_number	HZ_PARTIES.PARTY_NUMBER%TYPE;
         l_rel_party_id       NUMBER;    ---party_id of type party_relationship
         l_org_contact_rec  	HZ_PARTY_CONTACT_V2PUB.org_contact_rec_type;
BEGIN
IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   	IBE_UTIL.debug('enter ibe_party_v2pvt.create_org_contact');
END IF;



	-- initialize message list
	FND_MSG_PUB.initialize;


	-- Initialize API return status to success
     	x_return_status := FND_API.G_RET_STS_SUCCESS;
           IF (IBE_UTIL.G_DEBUGON = l_true) THEN
              IBE_UTIL.debug('Call Create_Person() API');
           END IF;

	-- calling internal API to create_person
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.debug('Call Create_Person() API');
     END IF;

	Create_Person(p_person_rec => p_person_rec,
               p_email_rec  => null,
               p_work_phone_rec => null,
			p_home_phone_rec => null,
			p_fax_rec => null,
			p_created_by_module => p_created_by_module,
			x_person_party_id => x_person_party_id,
               x_account_id => l_account_id,
			x_return_status => x_return_status,
			x_msg_count => x_msg_count,
			x_msg_data => x_msg_data);

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       	IBE_UTIL.debug('After call to Create_Person - x_return_status : '|| x_return_status);
       	IBE_UTIL.debug('After call to Create_Person - x_msg_count : '|| x_msg_count);
       	IBE_UTIL.debug('After call to Create_Person - x_msg_data :' || x_msg_data);
    END IF;
       IF x_return_status = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
     	 ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 END IF;

       -- Create ORG Contact which internally creates party_relationship
       -- Pass person_party_id as subject_id

       l_party_rel_rec.subject_id := x_person_party_id;
       l_party_rel_rec.subject_type :=  'PERSON';
       l_party_rel_rec.subject_table_name :=  'HZ_PARTIES';

      -- pass organization_party_id as object_id
       l_party_rel_rec.object_id :=  p_org_party_id;
       l_party_rel_rec.object_type :=  'ORGANIZATION';
       l_party_rel_rec.object_table_name :=  'HZ_PARTIES';



       if (p_relationship_type = 'EMPLOYEE_OF') then
           l_party_rel_rec.relationship_type :=  'EMPLOYMENT';
           l_party_rel_rec.relationship_code :=  'EMPLOYEE_OF';
       elsif (p_relationship_type = 'CONTACT_OF') then
           l_party_rel_rec.relationship_type :=  'CONTACT';
           l_party_rel_rec.relationship_code :=  'CONTACT_OF';
       end if;

       l_party_rel_rec.start_date:=  sysdate;
       l_party_rel_rec.created_by_module := P_CREATED_BY_MODULE;
       l_party_rel_rec.application_id    := G_APPLICATION_ID;

	  /*
	  -- bug 2600165  fix --
	  IF NVL(fnd_profile.value('HZ_GENERATE_PARTY_NUMBER'), 'Y') = 'N' THEN
IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   	     IBE_UTIL.debug('Party Number Auto generation is off');
END IF;
	     select hz_party_number_s.nextval into l_rel_party_number from dual;
	     l_party_rel_rec.party_rec.party_number := l_rel_party_number;
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        	IBE_UTIL.debug('Relationship Party Number :' || l_rel_party_number);
     END IF;
       END IF;
	  */

       l_org_contact_rec.party_rel_rec  :=  l_party_rel_rec;
       l_org_contact_rec.created_by_module := P_CREATED_BY_MODULE;
       l_org_contact_rec.application_id    := G_APPLICATION_ID;



IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   	IBE_UTIL.debug('Call HZ_PARTY_CONTACT_V2PUB.create_org_contact () API');
END IF;

       HZ_PARTY_CONTACT_V2PUB.create_org_contact (
        	p_org_contact_rec => l_org_contact_rec,
        	x_org_contact_id =>  l_org_contact_party_id,
        	x_party_rel_id =>  l_rel_id,
        	x_party_id =>  l_rel_party_id,
        	x_party_number =>  l_rel_party_number,
        	x_return_status =>  x_return_status,
        	x_msg_count =>  x_msg_count,
        	x_msg_data =>  x_msg_data);
         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_UTIL.debug('After call to HZ_PARTY_CONTACT_V2PUB.create_org_contact -  l_org_contact_party_id : '||  l_org_contact_party_id);
     	IBE_UTIL.debug('After call to HZ_PARTY_CONTACT_V2PUB.create_org_contact - x_return_status : '|| x_return_status);
       	IBE_UTIL.debug('After call to HZ_PARTY_CONTACT_V2PUB.create_org_contact - x_msg_count : '|| x_msg_count);
      	IBE_UTIL.debug('After call to HZ_PARTY_CONTACT_V2PUB.create_org_contact - x_msg_data :' || x_msg_data);
         END IF;


      if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      end if;

      x_rel_party_id := l_rel_party_id;
      -- Create Relationship contact_points, pass rel_party_id from the
      -- above API as owner_table_id
      -- Call internal Create_Contact_Points API

       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_UTIL.debug('Call Create_Contact_Points() API');
       END IF;
       Create_Contact_Points(
                      p_owner_table_id => x_rel_party_id,
                      p_email_rec => p_email_rec,
                      p_work_phone_rec => p_work_phone_rec,
                      p_home_phone_rec => p_home_phone_rec,
                      p_fax_rec => p_fax_rec,
                      p_contact_point_purpose => true,
                      p_created_by_module => G_CREATED_BY_MODULE,
                      x_return_status  => x_return_status,
		          x_msg_count      => x_msg_count,
		          x_msg_data       => x_msg_data);

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('After call to Create_Contact_Points() - x_return_status : '|| x_return_status);
       IBE_UTIL.debug('After call to Create_Contact_Points() - x_msg_count : '|| x_msg_count);
       IBE_UTIL.debug('After call to Create_Contact_Points()- x_msg_data : '|| x_msg_data);
    END IF;
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;




	-- standard call to get message count and if count is 1, get message info
	FND_MSG_PUB.count_and_get(
	      p_encoded => FND_API.G_FALSE,
		  p_count => x_msg_count,
		  p_data => x_msg_data
		  );

     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.debug('exit ibe_party_v2.create_individual_user');
     END IF;


EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN



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

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN


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

    WHEN OTHERS THEN


    FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
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

END;

/*====================================================================
| PROCEDURE NAME
|    Create_Person
|
| DESCRIPTION
|    This API is called by Create_Individual_User,
|                          Create_Customer
|                          Create_Org_Contact
|
| USAGE
|    -    Create a party in HzParties table.
|    -     Creates Contact Points
|    -     Creates  Accountss
|
|  REFERENCED APIS
|     This API calls the following APIs
|    -    HZ_PARTY_v2PUB.create_person
|    -    Create_Contact_Points
|======================================================================*/
Procedure Create_Person(
            p_person_rec 	    	IN	HZ_PARTY_V2PUB.person_rec_type,
            p_email_rec 	    		IN	HZ_CONTACT_POINT_V2PUB.email_rec_type,
            p_work_phone_rec 		IN	HZ_CONTACT_POINT_V2PUB.phone_rec_type,
            p_home_phone_rec 		IN	HZ_CONTACT_POINT_V2PUB.phone_rec_type,
            p_fax_rec	 	    	IN	HZ_CONTACT_POINT_V2PUB.phone_rec_type,
            p_created_by_module	IN	VARCHAR2,
            p_account			IN	VARCHAR2 ,
            x_person_party_id		OUT NOCOPY	NUMBER,
            x_account_id			OUT NOCOPY	NUMBER,
            x_return_status  		OUT NOCOPY	VARCHAR2,
            x_msg_count  		OUT NOCOPY	NUMBER,
            x_msg_data   		OUT NOCOPY	VARCHAR2) is


        l_party_id		NUMBER;
	   l_party_number	HZ_PARTIES.PARTY_NUMBER%TYPE;
        l_profile_id	NUMBER;
        l_account_number NUMBER;
        l_account_id    NUMBER;
        l_person_rec HZ_PARTY_V2PUB.person_rec_type;

        l_home_phone_rec  HZ_CONTACT_POINT_V2PUB.phone_rec_type := null;
        l_work_phone_rec  HZ_CONTACT_POINT_V2PUB.phone_rec_type := null;
        l_fax_rec  HZ_CONTACT_POINT_V2PUB.phone_rec_type := null;
        l_email_rec  HZ_CONTACT_POINT_V2PUB.email_rec_type := null;
BEGIN
IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   	IBE_UTIL.debug('enter ibe_party_v2pvt.create_person');
END IF;

      l_person_rec := p_person_rec;
	 l_person_rec.created_by_module := p_created_by_module;
      l_person_rec.application_id := G_APPLICATION_ID;



	-- initialize message list
	FND_MSG_PUB.initialize;


	-- Initialize API return status to success
     	x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.debug('Call Create_Person() API');
      END IF;

	 /*
     -- bug 2600165 fix --
     IF NVL(fnd_profile.value('HZ_GENERATE_PARTY_NUMBER'), 'Y') = 'N' THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.debug('Party Number Auto generation is off');
      END IF;
      select hz_party_number_s.nextval into l_party_number from dual;
      l_person_rec.party_rec.party_number := l_party_number;
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.debug('Person Party Number :' || l_party_number);
      END IF;
     END IF;
	*/

	-- calling TCA API to create_person

         HZ_PARTY_V2PUB.create_person (
        	p_person_rec     => l_person_rec,
		x_party_id       => l_party_id,
		x_party_number   => l_party_number,
		x_profile_id     => l_profile_id,
		x_return_status  => x_return_status,
		x_msg_count      => x_msg_count,
		x_msg_data       => x_msg_data);

    if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       	IBE_UTIL.debug('After call to HZ_PARTY_V2PUB.create_person - l_party_id : '|| l_party_id);
       	IBE_UTIL.debug('After call to HZ_PARTY_V2PUB.create_person - x_return_status : '|| x_return_status);
   	IBE_UTIL.debug('After call HZ_PARTY_V2PUB.create_person - x_msg_count : '|| x_msg_count);
   	IBE_UTIL.debug('After call to HZ_PARTY_V2PUB.create_person  - x_msg_data : '|| x_msg_data);
    END IF;

       x_person_party_id := l_party_id;


       -- Call internal Create_Contact_Points API
       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_UTIL.debug('Call Create_Contact_Points() API');
       END IF;
       Create_Contact_Points(
                      p_owner_table_id => l_party_id,
                      p_email_rec => p_email_rec,
                      p_work_phone_rec => p_work_phone_rec,
                      p_home_phone_rec => p_home_phone_rec,
                      p_fax_rec => p_fax_rec,
                      p_contact_point_purpose => true,
                      p_created_by_module => G_CREATED_BY_MODULE,
                      x_return_status  => x_return_status,
		          x_msg_count      => x_msg_count,
		          x_msg_data       => x_msg_data);

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      	 IBE_UTIL.debug('After call to Create_Contact_Points() - x_return_status : '|| x_return_status);
          IBE_UTIL.debug('After call to Create_Contact_Points() - x_msg_count : '|| x_msg_count);
   	 IBE_UTIL.debug('After call to Create_Contact_Points()- x_msg_data : '|| x_msg_data);
   END IF;
       IF x_return_status = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
     	 ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 END IF;

      --if p_account - true then call create_account


      If (p_account= 'true') then
      /*** Create Account  for the Person***/
             IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                IBE_UTIL.debug(' Call to Create_Account');
             END IF;

             Create_Account(
                      p_party_id => l_party_id,
                      p_party_type => 'P',
                      p_created_by_module =>p_created_by_module,
                      x_account_id => x_account_id,
                      x_return_status =>x_return_status,
                      x_msg_count =>x_msg_count,
                      x_msg_data =>x_msg_data);



       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_UTIL.debug('After call to Create_Account() - x_return_status : '|| x_return_status);
          IBE_UTIL.debug('After call to Create_Account() - x_msg_count : '|| x_msg_count);
          IBE_UTIL.debug('After call to Create_Account()- x_msg_data : '|| x_msg_data);
       END IF;
       IF x_return_status = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
     	 ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 END IF;

       End if;
	-- standard call to get message count and if count is 1, get message info
	FND_MSG_PUB.count_and_get(
	      p_encoded => FND_API.G_FALSE,
		p_count => x_msg_count,
		p_data => x_msg_data
		  );

     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.debug('exit ibe_party_v2.create_person');
     END IF;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN



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

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN


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

    WHEN OTHERS THEN


    FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
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
END create_person;

/*+====================================================================
| PROCEDURE NAME
|    Create_Organization
|
| DESCRIPTION
|    This API is called by Create_Business_User,
|                          Create_Customer
|
|
| USAGE
|    -    Create Organization
|    -     Creates Location and PartySite
|    -     Creates  Organization contact points
|
|  REFERENCED APIS
|     This API calls the following APIs
|    -    HZ_PARTY_v2PUB.create_organization
|    -    IBE_ADDRESS_V2PVT.create_address
|    -    Create_Contact_Points
|    -    Create_Account id p_account is true
+======================================================================*/
Procedure Create_Organization(
		p_organization_rec 		IN	HZ_PARTY_V2PUB.organization_rec_type,
		p_org_workphone_rec 	IN	HZ_CONTACT_POINT_V2PUB.phone_rec_type,
     /*	p_org_homephone_rec 	IN	HZ_CONTACT_POINT_V2PUB.phone_rec_type,
	*/
		p_org_fax_rec	 		IN	HZ_CONTACT_POINT_V2PUB.phone_rec_type,
     	p_location_rec			IN	HZ_LOCATION_V2PUB.location_rec_type,
     	p_party_site_rec		IN	HZ_PARTY_SITE_V2PUB.party_site_rec_type,
        p_primary_billto                IN      VARCHAR2 := FND_API.G_FALSE,
        p_primary_shipto                IN      VARCHAR2 := FND_API.G_FALSE,
        p_billto                        IN      VARCHAR2 := FND_API.G_FALSE,
        p_shipto                        IN      VARCHAR2 := FND_API.G_FALSE,
        p_default_primary               IN      VARCHAR2 := FND_API.G_FALSE,
		p_created_by_module		IN	VARCHAR2,
		p_account				IN	VARCHAR2 ,
		x_org_party_id	      	OUT NOCOPY	NUMBER,
     	x_account_id			OUT NOCOPY	NUMBER,
		x_party_site_id		OUT NOCOPY	NUMBER,
     	x_return_status  	    	OUT NOCOPY	VARCHAR2,
     	x_msg_count  			OUT NOCOPY	NUMBER,
     	x_msg_data   			OUT NOCOPY	VARCHAR2) is


	  l_party_id		NUMBER;
	  l_party_number	HZ_PARTIES.PARTY_NUMBER%TYPE;
       l_location_id		NUMBER;
	  l_party_site_id	NUMBER;
       l_profile_id	NUMBER;
       l_organization_rec     HZ_PARTY_V2PUB.organization_rec_type;
       l_party_site_rec HZ_PARTY_SITE_V2PUB.party_site_rec_type;
       l_location_rec HZ_LOCATION_V2PUB.location_rec_type;

	  l_org_workphone_rec HZ_CONTACT_POINT_V2PUB.phone_rec_type := null;
	  /*l_org_homephone_rec HZ_CONTACT_POINT_V2PUB.phone_rec_type:= null;*/
	  l_org_fax_rec HZ_CONTACT_POINT_V2PUB.phone_rec_type:= null;


         --l_account_id   NUMBER;
BEGIN
IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   	IBE_UTIL.debug('enter ibe_party_v2pvt.create_organization');
END IF;


      l_organization_rec := p_organization_rec;
	 l_organization_rec.created_by_module := p_created_by_module;
      l_organization_rec.application_id := G_APPLICATION_ID;

      l_location_rec := p_location_rec;
      l_location_rec.created_by_module := p_created_by_module;
      l_location_rec.application_id := G_APPLICATION_ID;
	-- initialize message list
	FND_MSG_PUB.initialize;


	-- Initialize API return status to success
     	x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.debug('Call Create_Organization() API');
      END IF;
     /*
       -- bug 2600165 fix --
      IF NVL(fnd_profile.value('HZ_GENERATE_PARTY_NUMBER'), 'Y') = 'N' THEN
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_UTIL.debug('Party Number Auto generation is off');
        END IF;
	   select hz_party_number_s.nextval into l_party_number from dual;
	   l_organization_rec.party_rec.party_number := l_party_number;
IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   	   IBE_UTIL.debug('Organization Party Number :' || l_party_number);
END IF;

      END IF;
    */
	-- calling TCA API to create_Organization

         HZ_PARTY_V2PUB.create_organization (
        p_organization_rec     => l_organization_rec,
		x_party_id       => l_party_id,
		x_party_number   => l_party_number,
		x_profile_id     => l_profile_id,
		x_return_status  => x_return_status,
		x_msg_count      => x_msg_count,
		x_msg_data       => x_msg_data);
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     	IBE_UTIL.debug('After call to HZ_PARTY_V2PUB.create_organization - l_party_id : '|| l_party_id);
       	IBE_UTIL.debug('After call to HZ_PARTY_V2PUB.create_organization - x_return_status : '|| x_return_status);
   	IBE_UTIL.debug('After call HZ_PARTY_V2PUB.create_organization - x_msg_count : '|| x_msg_count);
   	IBE_UTIL.debug('After call to HZ_PARTY_V2PUB.create_organization  - x_msg_data : '|| x_msg_data);
  END IF;
    if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


       x_org_party_id := l_party_id;

       l_party_site_rec := p_party_site_rec;
       -- Create Party_Site for the Organization
       -- associate org_party_id to l_party_site_rec
       --l_party_site_rec.party_id := l_party_id;
       l_party_site_rec.party_id := x_org_party_id;
       l_party_site_rec.created_by_module := p_created_by_module;
       l_party_site_rec.application_id := G_APPLICATION_ID;

       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_UTIL.debug('Call IBE_ADDRESS_V2PVT.creat_address() API');
          IBE_UTIL.debug('Call IBE_ADDRESS_V2PVT.creat_address() API address1 :'||l_location_rec.address1);
       END IF;
	-- calling internal API to create address (location , party_site)
       IBE_ADDRESS_V2PVT.create_address(
                         p_api_version => 1.0,
                         p_init_msg_list => null,
                         p_commit => null,
                         p_location => l_location_rec,
                         p_party_site => l_party_site_rec,
                         p_primary_billto => p_primary_billto,
                         p_primary_shipto => p_primary_shipto,
                         p_billto => p_billto,
                         p_shipto => p_shipto,
                         p_default_primary =>p_default_primary,
                         x_location_id => l_location_id,
                         x_party_site_id => x_party_site_id,
                         x_return_status  => x_return_status,
			       x_msg_count      => x_msg_count,
			       x_msg_data       => x_msg_data);

      if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.debug('After call to IBE_ADDRESS_V2PVT.create_address - l_location_id : '|| l_location_id);
   	  IBE_UTIL.debug('After call to IBE_ADDRESS_V2PVT.create_address - x_party_site_id : '|| x_party_site_id);
         IBE_UTIL.debug('After call to IBE_ADDRESS_V2PVT.create_address - x_return_status : '|| x_return_status);
         IBE_UTIL.debug('After call IBE_ADDRESS_V2PVT.create_address - x_msg_count : '|| x_msg_count);
         IBE_UTIL.debug('After call to IBE_ADDRESS_V2PVT.create_address  - x_msg_data : '|| x_msg_data);
      END IF;





       -- Call internal Create_Contact_Points API to create Org Contact Points
       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_UTIL.debug('Call Create_Contact_Points() API');
       END IF;
       Create_Contact_Points(
                      p_owner_table_id => x_org_party_id,
                      p_work_phone_rec => p_org_workphone_rec,
                      p_home_phone_rec => null,
                      p_email_rec => null,
                      p_fax_rec =>p_org_fax_rec,
                      p_contact_point_purpose => true,
                      p_created_by_module => G_CREATED_BY_MODULE,
                      x_return_status  => x_return_status,
		          x_msg_count      => x_msg_count,
		          x_msg_data       => x_msg_data);

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      	 IBE_UTIL.debug('After call to Create_Contact_Points() - x_return_status : '|| x_return_status);
          IBE_UTIL.debug('After call to Create_Contact_Points() - x_msg_count : '|| x_msg_count);
   	 IBE_UTIL.debug('After call to Create_Contact_Points()- x_msg_data : '|| x_msg_data);
   END IF;
       IF x_return_status = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
     	 ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 END IF;




      --- if p_accont - true then call create_account


      If (p_account = 'true') then
      /*** Create Account  for the Organization***/
         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_UTIL.debug(' Call to Create_Account');
         END IF;

             Create_Account(
                      p_party_id => x_org_party_id,
                      p_party_type => 'O',
                      p_created_by_module =>p_created_by_module,
                      x_account_id => x_account_id,
                      x_return_status =>x_return_status,
                      x_msg_count =>x_msg_count,
                      x_msg_data =>x_msg_data);



       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_UTIL.debug('After call to Create_Account() - x_return_status : '|| x_return_status);
          IBE_UTIL.debug('After call to Create_Account() - x_account_id : '|| x_account_id);
          IBE_UTIL.debug('After call to Create_Account() - x_msg_count : '|| x_msg_count);
          IBE_UTIL.debug('After call to Create_Account()- x_msg_data : '|| x_msg_data);
       END IF;
       IF x_return_status = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
     	 ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 END IF;

       End if;
	-- standard call to get message count and if count is 1, get message info
	FND_MSG_PUB.count_and_get(
	      p_encoded => FND_API.G_FALSE,
		p_count => x_msg_count,
		p_data => x_msg_data
		  );

     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.debug('exit ibe_party_v2.create_person');
     END IF;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN



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

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN


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

    WHEN OTHERS THEN


    FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
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
END create_organization;


/*+====================================================================
| PROCEDURE NAME
|    Create_Contact_Points
|
| DESCRIPTION
|    This API is called By Create_Person,
|                          Creat_Organization
|                          Create_Org_Contact
|
| USAGE
|
|    -     Creates Contact Points in TCA tables
|
|
|  REFERENCED APIS
|     This API calls the following APIs
|    -    HZ_CONTACT_POINTS_V2PUB.Create_Contact_Points
+======================================================================*/
Procedure Create_Contact_Points(
	   p_owner_table_id 		IN	NUMBER,
	   p_work_phone_rec 		IN	HZ_CONTACT_POINT_V2PUB.phone_rec_type,
         p_home_phone_rec 		IN	HZ_CONTACT_POINT_V2PUB.phone_rec_type,
         p_fax_rec 		 	IN	HZ_CONTACT_POINT_V2PUB.phone_rec_type,
	   p_email_rec	 		IN	HZ_CONTACT_POINT_V2PUB.email_rec_type,
         p_contact_point_purpose	IN	BOOLEAN, --indicates whether to populate contact_point_purpose
	   p_created_by_module		IN	VARCHAR2,
         x_return_status  		OUT NOCOPY	VARCHAR2,
         x_msg_count 		      OUT NOCOPY	NUMBER,
         x_msg_data   			OUT NOCOPY	VARCHAR2) is


	 l_contact_point_id		NUMBER;

       l_contact_point_rec    HZ_CONTACT_POINT_V2PUB.CONTACT_POINT_REC_TYPE;
       l_email_rec  HZ_CONTACT_POINT_V2PUB.email_rec_type := null;

BEGIN
IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   	IBE_UTIL.debug('5917800 - enter ibe_party_v2pvt.create_contact_points');
END IF;

-- for ER 5917800
IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   	IBE_UTIL.debug('5917800 - Added the below code for  Email Notifications ER');
END IF;
l_email_rec := p_email_rec;
l_email_rec.email_format := NVL(FND_PROFILE.VALUE('IBE_DEFAULT_USER_EMAIL_STYLE'), 'MAILTEXT');
      l_contact_point_rec.status := 'A';
      l_contact_point_rec.owner_table_name := 'HZ_PARTIES';
      l_contact_point_rec.owner_table_id := p_owner_table_id;
      l_contact_point_rec.created_by_module := p_created_by_module;
      l_contact_point_rec.application_id := G_APPLICATION_ID;



	-- initialize message list
	FND_MSG_PUB.initialize;
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_UTIL.debug('Enter Create_Contact_Points()');
        END IF;

	-- Initialize API return status to success
     	x_return_status := FND_API.G_RET_STS_SUCCESS;
       l_contact_point_rec.contact_point_type := null;
       if (p_email_rec.email_address is not NULL) then

          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
             IBE_UTIL.debug('Call HZ_CONTACT_POINT_V2PUB.create_email_contact_point API');
          END IF;
          l_contact_point_rec.contact_point_type := 'EMAIL';

	-- calling TCA API to create_email_contact_points

           HZ_CONTACT_POINT_V2PUB.create_email_contact_point (
                        p_contact_point_rec => l_contact_point_rec,
        		p_email_rec => l_email_rec,
        		x_contact_point_id => l_contact_point_id,
        		x_return_status => x_return_status,
        		x_msg_count => x_msg_count,
        		x_msg_data => x_msg_data);
           IF (IBE_UTIL.G_DEBUGON = l_true) THEN
              IBE_UTIL.debug('After call to HZ_CONTACT_POINT_V2PUB.create_email_contact_point l_contact_point_id : '|| l_contact_point_id);
           END IF;
           if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           end if;

       end if;

       l_contact_point_rec.contact_point_type := null;
       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_UTIL.debug(' Workphone_Number : '|| Length(p_work_phone_rec.phone_number));
       END IF;
       if ( p_work_phone_rec.phone_number is not NULL) or (p_work_phone_rec.phone_number <> '' ) then
          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
             IBE_UTIL.debug('Work Phone num is not null phone_Number : '|| p_work_phone_rec.phone_number);
          END IF;
          l_contact_point_rec.contact_point_type := 'PHONE';
       if (p_contact_point_purpose) then
          l_contact_point_rec.contact_point_purpose := 'BUSINESS';
       end if;
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_UTIL.debug('Call HZ_CONTACT_POINT_V2PUB.create_phone_contact_point API');
        END IF;
         --l_contact_point_rec.primary_flag      :=  'Y';
          HZ_CONTACT_POINT_V2PUB.create_phone_contact_point (
                       p_contact_point_rec => l_contact_point_rec,
                       p_phone_rec => p_work_phone_rec,
                       x_contact_point_id => l_contact_point_id,
                       x_return_status => x_return_status,
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data );
         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_UTIL.debug('After call to HZ_CONTACT_POINT_V2PUB.create_phone_contact_point(work) - l_contact_point_id : '|| l_contact_point_id);
         END IF;
        if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        end if;
     end if;

    l_contact_point_rec.contact_point_type := null;
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.debug('HOME_phone_Number : '|| p_home_phone_rec.phone_number);
     END IF;
    if ( p_home_phone_rec.phone_number is not NULL ) then
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('Home Phone num is not null phone_Number : '|| p_home_phone_rec.phone_number);
    END IF;
        l_contact_point_rec.contact_point_type := 'PHONE';
    if (p_contact_point_purpose) then
        l_contact_point_rec.contact_point_purpose := 'PERSONAL';
    end if;
    --if (p_work_phone_rec.phone_number is null) then
            --l_contact_point_rec.primary_flag      :=  'Y';
    --end if;
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('Call HZ_CONTACT_POINT_V2PUB.create_phone_contact_point API');
    END IF;
    HZ_CONTACT_POINT_V2PUB.create_phone_contact_point (
                 p_contact_point_rec => l_contact_point_rec,
                 p_phone_rec => p_home_phone_rec,
                 x_contact_point_id => l_contact_point_id,
                 x_return_status => x_return_status,
                 x_msg_count => x_msg_count,
                 x_msg_data => x_msg_data );
 IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.debug('After call to HZ_CONTACT_POINT_V2PUB.create_phone_contact_point (home)- l_contact_point_id : '|| l_contact_point_id);
 END IF;
    if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    end if;
end if;
IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   IBE_UTIL.debug('Fax_phone_Number : '|| p_fax_rec.phone_number);
END IF;
if ( p_fax_rec.phone_number is not NULL ) then
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.debug('Fax_phone_Number is not null ');
   END IF;

    l_contact_point_rec.contact_point_type := 'PHONE';
    l_contact_point_rec.contact_point_purpose := null;

   --if (p_work_phone_rec.phone_number is null) and (p_home_phone_rec.phone_number is null)  then
           --l_contact_point_rec.primary_flag      :=  'Y';
  --end if;
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.debug('Call HZ_CONTACT_POINT_V2PUB.create_phone_contact_point API');
   END IF;
    HZ_CONTACT_POINT_V2PUB.create_phone_contact_point (
      p_contact_point_rec               => l_contact_point_rec,
      p_phone_rec                       => p_fax_rec,
      x_contact_point_id                => l_contact_point_id,
      x_return_status                   => x_return_status,
      x_msg_count                       => x_msg_count,
      x_msg_data                        => x_msg_data );
IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   IBE_UTIL.debug('After call to HZ_CONTACT_POINT_V2PUB.create_phone_contact_point (fax)- l_contact_point_id : '|| l_contact_point_id);
END IF;
    if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    end if;
end if;
	-- standard call to get message count and if count is 1, get message info
	FND_MSG_PUB.count_and_get(
	      p_encoded => FND_API.G_FALSE,
		p_count => x_msg_count,
		p_data => x_msg_data
		  );

     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.debug('exit ibe_party_v2.create_contact_points');
     END IF;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN



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

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN


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

    WHEN OTHERS THEN


    FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
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


END create_contact_points;

/*+===========================================================================
| PROCEDURE NAME
|    Update_Contact_Preference
|
| DESCRIPTION
|    This API is called By Create_Individual_User,
|                          Creat_Business_User
|
|
| USAGE
|
|    -     Create Contact Prefernece in HZ_CONTACT_PREFERNECE_V2PUB
|
|
|  REFERENCED APIS
|     This API calls the following APIs
|    -  HZ_CONTACT_PREFERENCE_V2PUB.create_contact_preference if no row exists
|    -  HZ_CONTACT_PREFERENCE_V2PUB.update_contact_preference if row exists
+=============================================================================*/
PROCEDURE Update_Contact_Preference(
    p_party_id           IN    NUMBER,
    p_preference         IN    VARCHAR2,
    p_object_version_number IN NUMBER,
    p_created_by_module  IN    VARCHAR2,
    x_return_status      OUT NOCOPY  VARCHAR2,
    x_msg_count          OUT NOCOPY  NUMBER,
    x_msg_data           OUT NOCOPY  VARCHAR2

   )
IS
    l_contact_preference_rec                hz_contact_preference_v2pub.contact_preference_rec_type;
    l_contact_preference_rec2               hz_contact_preference_v2pub.contact_preference_rec_type;
    l_contact_preference_id                 NUMBER;
    l_object_version_number                 NUMBER;
    l_id                                    NUMBER;


BEGIN
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.debug('enter ibe_party_v2pvt.update_contact_preference');
     END IF;

      FND_MSG_PUB.initialize;


    --begin set/create contact preferences
    BEGIN
      SELECT contact_preference_id, object_version_number
      INTO   l_id , l_object_version_number
      From   hz_contact_preferences
      WHERE  contact_level_table='HZ_PARTIES'
      AND    contact_level_table_id=p_party_id;

      --update reason_code if record found
      l_contact_preference_rec.contact_preference_id := l_id;
      l_contact_preference_rec.preference_code := p_preference;
      if (p_object_version_number is not null) then
         l_object_version_number := p_object_version_number;
      end if;
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.debug('Call HZ_CONTACT_PREFERENCE_V2PUB.update_contact_preference API');
      END IF;
      HZ_CONTACT_PREFERENCE_V2PUB.update_contact_preference(
            FND_API.G_FALSE,
            l_contact_preference_rec,
            l_object_version_number,
            x_return_status,
            x_msg_count,
            x_msg_data
        );
IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   	IBE_UTIL.debug('After Call HZ_CONTACT_PREFERENCE_V2PUB.update_contact_preference API');
END IF;
      --create row when no record found
      EXCEPTION WHEN NO_DATA_FOUND THEN
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   	       IBE_UTIL.debug('Got No Data Found Exception in update_contact_preference');
        END IF;

        l_contact_preference_rec2.contact_level_table := 'HZ_PARTIES';
        l_contact_preference_rec2.contact_level_table_id := p_party_id;
        l_contact_preference_rec2.contact_type := 'EMAIL';
        l_contact_preference_rec2.preference_code := p_preference;
        l_contact_preference_rec2.requested_by := 'INTERNAL';
        l_contact_preference_rec2.status := 'A';
        l_contact_preference_rec2.created_by_module := p_created_by_module;

IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   	IBE_UTIL.debug('Call HZ_CONTACT_PREFERENCE_V2PUB.create_contact_preference API');
END IF;
        HZ_CONTACT_PREFERENCE_V2PUB.create_contact_preference(
                FND_API.G_FALSE,
                l_contact_preference_rec2,
                l_contact_preference_id,
                x_return_status,
                x_msg_count,
                x_msg_data
        );
IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   	IBE_UTIL.debug('After call to HZ_CONTACT_PREFERENCE_V2PUB.create_contact_preference API');
END IF;
    END;
    --end set/create contact preferences


       -- standard call to get message count and if count is 1, get message info
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   	       IBE_UTIL.debug('Before FND_MSG_API.count_and_get');
        END IF;

    FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.G_FALSE,
      p_count => x_msg_count,
      p_data => x_msg_data
    );

        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   	       IBE_UTIL.debug('After FND_MSG_API.count_and_get');
        END IF;

--standard exception catching for main body
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    --IBE_UTIL.enable_debug();

    x_return_status := FND_API.G_RET_STS_ERROR;

        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   	       IBE_UTIL.debug('Before FND_MSG_API.count_and_get in Exception');
        END IF;
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


  WHEN OTHERS THEN



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



END Update_Contact_Preference;

/*+====================================================================
| PROCEDURE NAME
|    Update_Person_Language
|
| DESCRIPTION
|  If the API finds a language preference for the given party then it updates
|  the primary indicator to 'N' then it sets the new language as the primary
|  language. If it does not find any language preference for the party then
|  it creates a new one and makrs it primary
|
| USAGE
|
|    -     Create Person Language preference in HZ_PERSON_INFO_V2PUB
|
|
|  REFERENCED APIS
|     This API calls the following APIs
|    -  HZ_PERSON_INFO_V2PUB.create_person_language if no row exists
|    -  HZ_PERSON_INFO_V2PUB.update_person_language if row exists
+======================================================================*/
PROCEDURE Update_Person_Language(
    p_party_id		     IN    NUMBER,
    p_language_name      IN    VARCHAR2,
    p_created_by_module  IN    VARCHAR2,
    x_return_status      OUT NOCOPY  VARCHAR2,
    x_msg_count          OUT NOCOPY  NUMBER,
    x_msg_data           OUT NOCOPY  VARCHAR2
    )
IS
    l_per_language_rec   hz_person_info_v2pub.person_language_rec_type;
    l_id                 NUMBER;
    l_per_language_rec2   hz_person_info_v2pub.person_language_rec_type;
    l_language_use_reference_id number;
    l_object_version_number       NUMBER;

BEGIN

IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   	IBE_UTIL.debug('enter ibe_party_v2pvt.update_person_language');
END IF;

      FND_MSG_PUB.initialize;


  --begin unset primary language indicator
  BEGIN
    SELECT language_use_reference_id, object_version_number
    INTO   l_id, l_object_version_number
    FROM   hz_person_language
    WHERE  party_id=p_party_id and primary_language_indicator='Y';

    l_per_language_rec.primary_language_indicator := 'N';
    l_per_language_rec.language_use_reference_id := l_id;

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('Call HZ_PERSON_INFO_V2PUB.update_person_language API to unset primary');
    END IF;
    hz_person_info_v2pub.update_person_language(
            p_person_language_rec => l_per_language_rec,
            p_object_version_number => l_object_version_number,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data);
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug(' After Call HZ_PERSON_INFO_V2PUB.update_person_language APIto unset primary');
    END IF;
    EXCEPTION WHEN NO_DATA_FOUND THEN
    NULL;
  END;
  --end unset primary language indicator

  --begin set primary language indicator
  BEGIN
      SELECT language_use_reference_id, object_version_number
      INTO   l_id, l_object_version_number
      FROM   hz_person_language
      WHERE  party_id=p_party_id
      AND    language_name=p_language_name
      AND   nvl(status,'A') = 'A';

      l_per_language_rec2.primary_language_indicator := 'Y';
      l_per_language_rec2.language_use_reference_id := l_id;


     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.debug('Call HZ_PERSON_INFO_V2PUB.update_person_language API to set primary');
     END IF;
     hz_person_info_v2pub.update_person_language(
            p_person_language_rec => l_per_language_rec2,
            p_object_version_number => l_object_version_number,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data);

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.debug('After Call HZ_PERSON_INFO_V2PUB.update_person_language API to set primary');
      END IF;
      EXCEPTION WHEN NO_DATA_FOUND THEN
        l_per_language_rec2.primary_language_indicator := 'Y';
        l_per_language_rec2.party_id := p_party_id;
        l_per_language_rec2.language_name := p_language_name;
        l_per_language_rec2.created_by_module := p_created_by_module;

     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.debug('Call HZ_PERSON_INFO_V2PUB.create_person_language API to set primary');
     END IF;
        hz_person_info_v2pub.create_person_language(
             p_person_language_rec => l_per_language_rec2,
             x_language_use_reference_id => l_language_use_reference_id,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data);
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.debug('Call HZ_PERSON_INFO_V2PUB.create_person_language API to set primary');
     END IF;

    END;
    --end set primary language indicator



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


  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

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


  WHEN OTHERS THEN


    ROLLBACK TO person_language;
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


END update_person_language;



/*+====================================================================
| PROCEDURE NAME
|    Create_Account
|
| DESCRIPTION
|    This API is called by Create_Person,
|                          Create_Organization
|
|
| USAGE
|    -    Create an Account for the Person or Organization
|
|
|  REFERENCED APIS
|     This API calls the following APIs
|    -    HZ_CUST_ACCOUNT_V2PUB.Create_Cust_Account
+======================================================================*/
Procedure Create_Account(
	 p_party_id	        IN	NUMBER,  -- person_party_id or org_party_id
	 p_party_type		IN	VARCHAR2,
	 p_created_by_module	IN	VARCHAR2,
	 x_account_id		OUT NOCOPY	NUMBER,
       x_return_status  	OUT NOCOPY	VARCHAR2,
       x_msg_count  		OUT NOCOPY	NUMBER,
       x_msg_data   		OUT NOCOPY	VARCHAR2) is

    ddp_account_rec      hz_cust_account_v2pub.cust_account_rec_type;
    ddp_person_rec       hz_party_v2pub.person_rec_type;
    ddp_organization_rec hz_party_v2pub.organization_rec_type;
    ddp_cust_profile_rec hz_customer_profile_v2pub.customer_profile_rec_type;

    l_gen_cust_num       VARCHAR2(1);
    l_acct_num        VARCHAR2(30);
    l_account_number        VARCHAR2(30);
    l_count                  NUMBER;
    l_account_id NUMBER;
    l_party_number HZ_PARTIES.PARTY_NUMBER%TYPE;
    l_party_id NUMBER;
    l_profile_id NUMBER;



BEGIN
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.debug('enter ibe_party_v2pvt.create_account');
   END IF;

	-- initialize message list if p_init_msg_list is set to TRUE.
	FND_MSG_PUB.initialize;

	-- Initialize API return status to success
     	x_return_status := FND_API.G_RET_STS_SUCCESS;
    BEGIN
          -- pass the account_number if auto generation is off
    l_gen_cust_num :=  HZ_MO_GLOBAL_CACHE.get_generate_customer_number();
    exception when no_data_found then
      l_gen_cust_num := 'N';
    END;

    IF l_gen_cust_num <> 'Y' THEN
      -- always generate an account number

       l_count := 1;
       WHILE l_count > 0 LOOP

        SELECT hz_account_num_s.nextval INTO l_account_number
        FROM dual;


        SELECT COUNT(*) INTO l_count
        FROM hz_cust_accounts
        WHERE account_number = l_account_number;

       END LOOP;



      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.debug('account number from sequence : ' || l_account_number);
      END IF;

       ddp_account_rec.account_number := l_account_number;
    END IF;

     ddp_account_rec.created_by_module := p_created_by_module;
      ddp_account_rec.status := 'A';
      ddp_account_rec.application_id := G_APPLICATION_ID;


   if p_party_type = 'P' then
      ddp_person_rec.party_rec.party_id := p_party_id;
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.debug('Call HZ_CUST_ACCOUNT_V2PUB.create_cust_account() API to create Person Account');
   END IF;
      HZ_CUST_ACCOUNT_V2PUB.create_cust_account(
        p_cust_account_rec =>ddp_account_rec,
        p_person_rec =>ddp_person_rec,
        p_customer_profile_rec=>ddp_cust_profile_rec,
        p_create_profile_amt => FND_API.G_FALSE,
        x_return_status =>x_return_status,
        x_msg_count =>x_msg_count,
        x_msg_data =>x_msg_data,
        x_cust_account_id => x_account_id,
        x_account_number => l_acct_num,
        x_party_id => l_party_id,
        x_party_number =>l_party_number,
        x_profile_id => l_profile_id);

    elsif p_party_type = 'O' then
       ddp_organization_rec.party_rec.party_id := p_party_id;
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('Call HZ_CUST_ACCOUNT_V2PUB.create_cust_account() API to create Organization Account');
    END IF;
       HZ_CUST_ACCOUNT_V2PUB.create_cust_account(
        p_cust_account_rec =>ddp_account_rec,
        p_organization_rec =>ddp_organization_rec,
        p_customer_profile_rec=>ddp_cust_profile_rec,
        p_create_profile_amt => FND_API.G_FALSE,
        x_return_status =>x_return_status,
        x_msg_count =>x_msg_count,
        x_msg_data =>x_msg_data,
        x_cust_account_id => x_account_id,
        x_account_number => l_acct_num,
        x_party_id => l_party_id,
        x_party_number =>l_party_number,
       x_profile_id => l_profile_id);
   End if;

if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
end if;

     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.debug('exit ibe_party_v2.create_account');
     END IF;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

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

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN


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

    WHEN OTHERS THEN


    FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
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
END create_account;

/*+====================================================================
| PROCEDURE NAME
|    Update_Party_Status
|
| DESCRIPTION
|    This API is used to update party and all party_related TCA entity status
|
| USAGE
|    - Activate Party and Inactivate Party
|
|  REFERENCED APIS
|     This API calls the following APIs to update the TCA Entity Status
|       - Hz_party_v2pub.update_person
|       - Hz_party_contact_v2pub.update_org_contact
|       - Hz_party_v2pub.update_organization
|       - Hz_cust_account_v2pub.update_cust_account
|       - Hz_cust_account_role_v2pub.update_cust_account_role
|       - Hz_contact_point_v2pub.update_contact_point
|       - Hz_party_site_v2pub.update_party_site
|       - HZ_.update_contact_preferences
+======================================================================*/
Procedure Update_Party_Status(
         p_party_id	        IN	NUMBER,
         p_party_status         IN      VARCHAR2,
         p_change_org_status    IN      VARCHAR2 := FND_API.G_FALSE,
         p_commit               IN      VARCHAR2 := FND_API.G_FALSE,
         x_return_status        OUT     NOCOPY	VARCHAR2,
         x_msg_count            OUT     NOCOPY    NUMBER,
         x_msg_data             OUT     NOCOPY    VARCHAR2) is

    --TCA Records for updation
    l_person_rec        hz_party_v2pub.person_rec_type;
    l_org_rec           hz_party_v2pub.organization_rec_type;
    l_org_contact_rec   hz_party_contact_v2pub.org_contact_rec_type;
    l_account_rec       hz_cust_account_v2pub.cust_account_rec_type;
    l_contact_point_rec hz_contact_point_v2pub.contact_point_rec_type;
    l_party_site_rec    hz_party_site_v2pub.party_site_rec_type;
    l_custacct_role_rec hz_cust_account_role_v2pub.cust_account_role_rec_type;
    l_cntct_pref_rec    hz_contact_preference_v2pub.contact_preference_rec_type;

    --Local variables
    l_party_type varchar2(30);
    l_party_status varchar2(1);
    l_contact_point_id number;
    l_cp_object_version_number number;
    l_org_id number;
    l_person_party_id number;
    l_person_profile_id number;

   --Cursors for querying TCA Data
   cursor c_getPartyInfo(l_party_id number) IS
      select p.party_type, p.status, p.object_version_number,
             rel.relationship_id,rel.object_version_number rel_object_version_number,
             oc.org_contact_id,oc.object_version_number cont_object_version_number,
             a.cust_account_id,a.object_version_number acct_object_version_number
      from   hz_parties p, hz_relationships rel,hz_cust_accounts a,hz_org_contacts oc
      where  p.party_id = l_party_id and rel.party_id(+) = p.party_id and a.party_id(+) = p.party_id
             and oc.party_relationship_id(+) = rel.relationship_id and rownum <2;
   rec_party_info             c_getPartyInfo%rowtype;

   cursor c_getContactPoints(l_party_id number) IS
     select contact_point_id,object_version_number
     from hz_contact_points
     where owner_table_id = l_party_id
     and owner_table_name = 'HZ_PARTIES';
   rec_contact_point          c_getContactPoints%rowtype;

   cursor c_getPartySite(l_party_id number) IS
     select party_site_id,location_id,object_version_number
     from hz_party_sites
     where party_id = l_party_id;
   rec_party_site             c_getPartySite%rowtype;

   cursor c_getPersonOrgPartyId(l_party_id number) IS
     select subject_id,object_id from hz_relationships
     where party_id = l_party_id and subject_type = 'ORGANIZATION';

   cursor c_getCustAcctRole(l_party_id number) IS
     select cust_account_role_id,object_version_number
     from hz_cust_account_roles
     where party_id = l_party_id;
   rec_custAcct_role          c_getCustAcctRole%rowtype;

   cursor c_getContactPref(l_party_id number) IS
     select contact_preference_id,object_version_number
     from hz_contact_preferences
     where contact_level_table_id = l_party_id;
   rec_cntct_pref          c_getContactPref%rowtype;

BEGIN
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.debug('Begin ibe_party_v2pvt.update_party_status');
   END IF;
    -- initialize message list if p_init_msg_list is set to TRUE.
    FND_MSG_PUB.initialize;
    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('Input party_Id is '||p_party_id);
    END IF;
    --Get Party Details
    OPEN c_getPartyInfo(p_party_id);
    LOOP
        FETCH c_getPartyInfo into rec_party_info;
    l_party_type := rec_party_info.party_type;
    l_party_status := rec_party_info.status;
        EXIT WHEN c_getPartyInfo%notfound;
    END LOOP;
    CLOSE c_getPartyInfo;
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('party_type is '||l_party_type);
       IBE_UTIL.debug('DB party_status is '||l_party_status);
       IBE_UTIL.debug('INPUT party_status is '||p_party_status);
    END IF;
    IF (p_party_status <> l_party_status)THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.debug('DB Party Status and Input Party_Status are not equal,Begin Update');
      END IF;
      IF(l_party_type = 'PERSON') THEN
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_UTIL.debug('Update Person Rec');
        END IF;
        l_person_rec.party_rec.party_id := p_party_id;
        l_person_rec.party_rec.status := p_party_status;
        hz_party_v2pub.update_person
         (p_person_rec => l_person_rec,
          p_party_object_version_number => rec_party_info.object_version_number,
          x_profile_id => l_person_profile_id,
          x_return_status => x_return_status,
          x_msg_count => x_msg_count,
          x_msg_data     => x_msg_data
         );
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_UTIL.debug('x_msg_count from update_person'||x_msg_count);
           IBE_UTIL.debug('x_msg_data from update_person'||x_msg_data);
        END IF;
      ELSIF(l_party_type = 'PARTY_RELATIONSHIP') THEN
        --Org Contacts updation
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_UTIL.debug('Update OrgContact with Party Rel');
        END IF;
        l_org_contact_rec.org_contact_id := rec_party_info.org_contact_id;
        l_org_contact_rec.party_rel_rec.relationship_id := rec_party_info.relationship_id;
        l_org_contact_rec.party_rel_rec.status := p_party_status;
        l_org_contact_rec.party_rel_rec.party_rec.party_id := p_party_id;
        l_org_contact_rec.party_rel_rec.party_rec.status := p_party_status;
        hz_party_contact_v2pub.update_org_contact
         (p_org_contact_rec => l_org_contact_rec,
          p_cont_object_version_number => rec_party_info.cont_object_version_number,
          p_rel_object_version_number => rec_party_info.rel_object_version_number,
          p_party_object_version_number => rec_party_info.object_version_number,
          x_return_status => x_return_status,
          x_msg_count => x_msg_count,
          x_msg_data  => x_msg_data
        );
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_UTIL.debug('x_msg_count from update_org_contact'||x_msg_count);
           IBE_UTIL.debug('x_msg_data from update_org_contact'||x_msg_data);
        END IF;
        --Person party entities and Org Party Entities should also be inactivate
        --So calling this same procedure again with Person PartyId/Org PartyId
        OPEN c_getPersonOrgPartyId(p_party_id);
        LOOP
          FETCH c_getPersonOrgPartyId into l_org_id,l_person_party_id;
          EXIT WHEN c_getPersonOrgPartyId%notfound;
           IF (IBE_UTIL.G_DEBUGON = l_true) THEN
              IBE_UTIL.debug('update person_party_id'||l_person_party_id);
           END IF;
           update_party_status(l_person_party_id,p_party_status,FND_API.G_FALSE,FND_API.G_FALSE,x_return_status,x_msg_count,x_msg_data);
           IF (FND_API.To_Boolean(p_change_org_status))THEN
             IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                IBE_UTIL.debug('change_org_status = True, update org_id'||l_org_id);
             END IF;
             update_party_status(l_org_id,p_party_status,FND_API.G_FALSE,FND_API.G_FALSE,x_return_status,x_msg_count,x_msg_data);
           END IF;
        END LOOP;
        CLOSE c_getPersonOrgPartyId;
      ELSIF(l_party_type = 'ORGANIZATION') THEN
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_UTIL.debug('Update Organization');
        END IF;
        l_org_rec.party_rec.party_id := p_party_id;
        l_org_rec.party_rec.status   := p_party_status;
        hz_party_v2pub.update_organization
         (p_organization_rec => l_org_rec,
          p_party_object_version_number => rec_party_info.object_version_number,
          x_profile_id => l_person_profile_id,
          x_return_status => x_return_status,
          x_msg_count => x_msg_count,
          x_msg_data     => x_msg_data
         );
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_UTIL.debug('x_msg_count from update_org'||x_msg_count);
           IBE_UTIL.debug('x_msg_data from update_org'||x_msg_data);
        END IF;
      END IF;
      --Cust Account status updation
      IF(rec_party_info.cust_account_id IS NOT null) THEN
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_UTIL.debug('Update Account Id'||rec_party_info.cust_account_id);
        END IF;
        l_account_rec.cust_account_id := rec_party_info.cust_account_id;
        l_account_rec.status := p_party_status;
        hz_cust_account_v2pub.update_cust_account
         (p_cust_account_rec => l_account_rec,
          p_object_version_number => rec_party_info.acct_object_version_number,
          x_return_status => x_return_status,
          x_msg_count => x_msg_count,
          x_msg_data => x_msg_data
         );
         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_UTIL.debug('x_msg_count from update_cust_account'||x_msg_count);
            IBE_UTIL.debug('x_msg_data from update_cust_account'||x_msg_data);
         END IF;
       END IF;
       --Cust Acct Role  status update
       FOR rec_custAcct_role in c_getCustAcctRole(p_party_id) loop
       exit when c_getCustAcctRole%notfound;
         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_UTIL.debug('Update AcctRole Id'||rec_custAcct_role.cust_account_role_id);
         END IF;
         l_custacct_role_rec.cust_account_role_id := rec_custAcct_role.cust_account_role_id;
         l_custacct_role_rec.status := p_party_status;
         hz_cust_account_role_v2pub.update_cust_account_role
          (p_cust_account_role_rec => l_custacct_role_rec,
           p_object_version_number => rec_custAcct_role.object_version_number,
           x_return_status => x_return_status,
           x_msg_count => x_msg_count,
           x_msg_data  => x_msg_data
          );
         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_UTIL.debug('x_msg_count from update_cust_account_role'||x_msg_count);
            IBE_UTIL.debug('x_msg_data from update_cust_account_role'||x_msg_data);
         END IF;
       end loop;
       --Contact Points  status update
       FOR rec_contact_point in c_getContactPoints(p_party_id) loop
         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_UTIL.debug('Update Contact_Point Id'||rec_contact_point.contact_point_id);
         END IF;
         l_contact_point_rec.contact_point_id := rec_contact_point.contact_point_id;
         l_contact_point_rec.status := p_party_status;
         hz_contact_point_v2pub.update_contact_point
          (p_contact_point_rec => l_contact_point_rec,
           p_object_version_number => rec_contact_point.object_version_number,
           x_return_status => x_return_status,
           x_msg_count => x_msg_count,
           x_msg_data => x_msg_data
          );
          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
             IBE_UTIL.debug('x_msg_count from update_contact_point'||x_msg_count);
             IBE_UTIL.debug('x_msg_data from update_contact_point'||x_msg_data);
          END IF;
       exit when c_getContactPoints%notfound;
       end loop;

       --Party_Site status update
       FOR rec_party_site in c_getPartySite(p_party_id) loop
         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_UTIL.debug('Update PartySite Id'||rec_party_site.party_site_id);
         END IF;
         l_party_site_rec.party_site_id := rec_party_site.party_site_id;
         l_party_site_rec.status := p_party_status;
         hz_party_site_v2pub.update_party_site
          (p_party_site_rec => l_party_site_rec,
           p_object_version_number => rec_party_site.object_version_number,
           x_return_status => x_return_status,
           x_msg_count => x_msg_count,
           x_msg_data => x_msg_data
          );
          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
             IBE_UTIL.debug('x_msg_count from update_party_site'||x_msg_count);
             IBE_UTIL.debug('x_msg_data from update_party_site'||x_msg_data);
          END IF;
       exit when c_getPartySite%notfound;
       end loop;

       --Contact Preference status update
       FOR rec_cntct_pref in c_getContactPref(p_party_id) loop
         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_UTIL.debug('Update Preference Id'||rec_cntct_pref.contact_preference_id);
         END IF;
         l_cntct_pref_rec.contact_preference_id := rec_cntct_pref.contact_preference_id;
         l_cntct_pref_rec.status := p_party_status;
         hz_contact_preference_v2pub.update_contact_preference
          (p_contact_preference_rec => l_cntct_pref_rec,
           p_object_version_number => rec_cntct_pref.object_version_number,
           x_return_status => x_return_status,
           x_msg_count => x_msg_count,
           x_msg_data => x_msg_data
          );
         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_UTIL.debug('x_msg_count from update_contact_preference'||x_msg_count);
            IBE_UTIL.debug('x_msg_data from update_contact_preference'||x_msg_data);
         END IF;
       exit when c_getContactPref%notfound;
       end loop;
   END IF;
   IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
   END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('Expected Error');
    END IF;
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

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('UnExpected Error');
    END IF;
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

    WHEN OTHERS THEN
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('Other Exception');
    END IF;
    FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
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
END Update_Party_Status;

/*+====================================================================
| PROCEDURE NAME
|    Find_Organization
|
| DESCRIPTION
|  Internal API
|  Find Organization based on org-party_id, org_party_number or
|  org_party_name
|
|
| USAGE
|  Find Organization based on org-party_id, org_party_number or
|  org_party_name
|
|  REFERENCED APIS
|
+======================================================================*/
Function Find_Organization(
	 x_org_id		IN OUT NOCOPY	NUMBER,  --  org_party_id
	 x_org_num		IN OUT NOCOPY	VARCHAR2,
	 x_org_name		IN OUT NOCOPY	VARCHAR2) return boolean IS

cursor c_party_name IS
   select party_id, party_name, party_number from hz_parties where party_name = x_org_name;
cursor c_party_num IS
   select party_id, party_name, party_number from hz_parties where party_number = x_org_num;
cursor c_party_id IS
   select party_id, party_name, party_number from hz_parties where party_id = x_org_id;

ret_val boolean := false;
l_party_rec c_party_name%rowtype;

l_org_name HZ_PARTIES.PARTY_NAME%TYPE := null;
l_org_num HZ_PARTIES.PARTY_NUMBER%TYPE := null;

BEGIN
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.debug('enter ibe_party_v2pvt.find_organization');
      IBE_UTIL.debug('x_org_name: '|| x_org_name);
      IBE_UTIL.debug('x_org_num: '|| x_org_num);
      IBE_UTIL.debug('x_org_id: '|| x_org_id);
   END IF;


   if (x_org_name is not null) then
      l_org_name := x_org_name;
   end if;
   if (x_org_num is not null) then
      l_org_num := x_org_num;
   end if;

   if (l_org_name is not null ) then
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.debug('Inside l_org_name not null');
   END IF;
        Open c_party_name;
        Fetch c_party_name into l_party_rec;
        If (c_party_name%FOUND) then
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_UTIL.debug('Inside party_name found');
        END IF;
            x_org_num   := l_party_rec.party_number;
            x_org_name     := l_party_rec.party_name;
            x_org_id          := l_party_rec.party_id;
            ret_val := true;
        end if;
        Close c_party_name;
  Elsif (l_org_num is not null) then
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.debug('Inside l_org_num not null');
   END IF;
        Open c_party_num;
        Fetch c_party_num into l_party_rec;
        If (c_party_num%FOUND) then
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_UTIL.debug('Inside party_number found');
        END IF;
            x_org_num   := l_party_rec.party_number;
            x_org_name     := l_party_rec.party_name;
            x_org_id          := l_party_rec.party_id;
            ret_val := true;
        end if;
        Close c_party_num;

  Elsif ((x_org_id is not null)  AND (x_org_id <> ' ') AND (x_org_id <> ''))then
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.debug('Inside l_org_id not null');
  END IF;
        Open c_party_id;
        Fetch c_party_id into l_party_rec;
        If (c_party_id%FOUND) then
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_UTIL.debug('Inside party_id found');
        END IF;
            x_org_num   := l_party_rec.party_number;
            x_org_name     := l_party_rec.party_name;
            x_org_id          := l_party_rec.party_id;
            ret_val := true;
        end if;
        Close c_party_num;
   End if;

 --IBE_UTIL.debug('exit ibe_party_v2pvt.find_organization ret_val :' || ret_val);
 IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.debug('x_org_name: '|| x_org_name);
    IBE_UTIL.debug('x_org_num: '|| x_org_num);
    IBE_UTIL.debug('x_org_id: '|| x_org_id);
 END IF;
 --IBE_UTIL.debug('exit ibe_party_v2pvt.find_organization ret_val :' || ret_val));
return ret_val;
END Find_Organization;



/*+====================================================================
| PROCEDURE NAME
|  Save_Tca_Entities
|
| DESCRIPTION
|   Internal API called by IBE_PARTY_V2PVT_W wrapper which in turn is
|   called by saveTcaEntities in PartV2Wrap.java
|
|
| USAGE
|   This API is used for creating/updating a B2C user, Creating/Updating
|   a B2B user, Upgrading a B2C user into a B2B user.
|
|  REFERENCED APIS
|   HZ_PARTY_V2PUB.create_person()
|   HZ_PARTY_V2PUB.update_person()
|   HZ_PARTY_V2PUB.create_organization()
|   HZ_PARTY_V2PUB.update_organization()
|   HZ_LOCATION_V2PUB.create_location()
|   HZ_LOCATION_V2PUB.update_location()
|   HZ_PARTY_SITE_V2PUB.create_party_site()
|   HZ_PARTY_CONTACT_V2PUB.create_org_contact()
|   HZ_CONTACT_PREFERENCE_V2PUB.create_contact_preference()
|   HZ_CONTACT_PREFERENCE_V2PUB.update_contact_preference()
|   HZ_CONTACT_POINT_V2PUB.create_email_contact_point (
|   HZ_CONTACT_POINT_V2PUB.update_email_contact_point (
|   HZ_CONTACT_POINT_V2PUB.create_phone_contact_point (
|   HZ_CONTACT_POINT_V2PUB.update_phone_contact_point (
|
+======================================================================*/
Procedure Save_Tca_Entities(
    p_person_rec                           IN HZ_PARTY_V2PUB.person_rec_type,
    p_person_object_version_number         IN NUMBER,
    p_email_contact_point_rec              IN HZ_CONTACT_POINT_V2PUB.contact_point_rec_type,
    p_email_rec                            IN HZ_CONTACT_POINT_V2PUB.email_rec_type,
    p_email_object_version_number          IN NUMBER,
    p_workph_contact_point_rec             IN HZ_CONTACT_POINT_V2PUB.contact_point_rec_type,
    p_work_phone_rec                       IN HZ_CONTACT_POINT_V2PUB.phone_rec_type,
    p_workph_object_version_number         IN NUMBER,
    p_homeph_contact_point_rec             IN HZ_CONTACT_POINT_V2PUB.contact_point_rec_type,
    p_home_phone_rec                       IN HZ_CONTACT_POINT_V2PUB.phone_rec_type,
    p_homeph_object_version_number         IN NUMBER,
    p_fax_contact_point_rec                IN HZ_CONTACT_POINT_V2PUB.contact_point_rec_type,
    p_fax_rec                              IN HZ_CONTACT_POINT_V2PUB.phone_rec_type,
    p_fax_object_version_number            IN NUMBER,
    p_contact_pref_rec                     IN HZ_CONTACT_PREFERENCE_V2PUB.contact_preference_rec_type,
    p_cntct_pref_object_ver_num            IN NUMBER,
    p_organization_rec                     IN HZ_PARTY_V2PUB.organization_rec_type,
    p_org_object_version_number            IN NUMBER,
    p_location_rec                         IN HZ_LOCATION_V2PUB.location_rec_type,
    p_loc_object_version_number            IN NUMBER,
    p_orgph_contact_point_rec              IN HZ_CONTACT_POINT_V2PUB.contact_point_rec_type,
    p_org_phone_rec                        IN HZ_CONTACT_POINT_V2PUB.phone_rec_type,
    p_orgph_object_version_number          IN NUMBER,
    p_orgfax_contact_point_rec             IN HZ_CONTACT_POINT_V2PUB.contact_point_rec_type,
    p_org_fax_rec                          IN HZ_CONTACT_POINT_V2PUB.phone_rec_type,
    p_orgfax_object_version_number         IN NUMBER,
    p_create_party_rel                     IN VARCHAR2,
    p_created_by_module                    IN VARCHAR2,
    x_person_party_id                      OUT NOCOPY     NUMBER,
    x_rel_party_id                         OUT NOCOPY     NUMBER,
    x_org_party_id                         OUT NOCOPY     NUMBER,
    x_return_status                        OUT NOCOPY     VARCHAR2,
    x_msg_count                            OUT NOCOPY     NUMBER,
    x_msg_data                             OUT NOCOPY     VARCHAR2
)
as

    cursor c_get_party_relationship (c_subject_id NUMBER, c_object_id NUMBER) is
       SELECT party_id FROM hz_relationships
       WHERE subject_id = c_subject_id and subject_type = 'PERSON'
             and object_id = c_object_id and object_type = 'ORGANIZATION';

    cursor c_get_contact_preference (c_party_id NUMBER,c_table_name VARCHAR2) is
       SELECT contact_preference_id,object_version_number FROM hz_contact_preferences
       WHERE contact_level_table_id = c_party_id and contact_level_table = c_table_name
	        and contact_type = 'ALL';

    l_party_rel_rec                HZ_RELATIONSHIP_V2PUB.relationship_rec_type;
    l_org_contact_rec              HZ_PARTY_CONTACT_V2PUB.org_contact_rec_type;
    l_location_rec                 HZ_LOCATION_V2PUB.location_rec_type := p_location_rec;

    l_party_id                     NUMBER;
    l_person_profile_id            NUMBER;
    l_person_party_number          HZ_PARTIES.PARTY_NUMBER%TYPE;
    l_org_profile_id               NUMBER;
    l_org_party_number             HZ_PARTIES.PARTY_NUMBER%TYPE;
    l_org_contact_id               NUMBER;
    l_party_rel_unq_id             NUMBER;  -- unique id of the party relationship
    l_rel_party_number             HZ_PARTIES.PARTY_NUMBER%TYPE;
    l_location_id                  NUMBER;
    l_contact_preference_id        NUMBER;
    l_party_site_id                NUMBER;
    l_party_site_number            HZ_PARTY_SITES.PARTY_SITE_NUMBER%TYPE;

    l_party_site_rec               HZ_PARTY_SITE_V2PUB.party_site_rec_type;
    l_contact_pref_rec             HZ_CONTACT_PREFERENCE_V2PUB.contact_preference_rec_type := p_contact_pref_rec;
    l_person_rec                   HZ_PARTY_V2PUB.person_rec_type := p_person_rec;
    l_organization_rec             HZ_PARTY_V2PUB.organization_rec_type := p_organization_rec;

    l_email_contact_point_id       NUMBER;
    l_workph_contact_point_id      NUMBER;
    l_homeph_contact_point_id      NUMBER;
    l_fax_contact_point_id         NUMBER;
    l_orgph_contact_point_id       NUMBER;
    l_orgfax_contact_point_id      NUMBER;

    l_person_object_version_number NUMBER := p_person_object_version_number;
    l_email_object_version_number  NUMBER := p_email_object_version_number;
    l_workph_object_version_number NUMBER := p_workph_object_version_number;
    l_homeph_object_version_number NUMBER := p_homeph_object_version_number;
    l_fax_object_version_number    NUMBER := p_fax_object_version_number;
    l_cntct_pref_object_ver_num    NUMBER := p_cntct_pref_object_ver_num;
    l_org_object_version_number    NUMBER := p_org_object_version_number;
    l_loc_object_version_number    NUMBER := p_loc_object_version_number;
    l_orgph_object_version_number  NUMBER := p_orgph_object_version_number;
    l_orgfax_object_version_number NUMBER := p_orgfax_object_version_number;

    l_email_contact_point_rec      HZ_CONTACT_POINT_V2PUB.contact_point_rec_type := p_email_contact_point_rec;
    l_workph_contact_point_rec     HZ_CONTACT_POINT_V2PUB.contact_point_rec_type := p_workph_contact_point_rec;
    l_homeph_contact_point_rec     HZ_CONTACT_POINT_V2PUB.contact_point_rec_type := p_homeph_contact_point_rec;
    l_fax_contact_point_rec        HZ_CONTACT_POINT_V2PUB.contact_point_rec_type := p_fax_contact_point_rec;
    l_orgph_contact_point_rec      HZ_CONTACT_POINT_V2PUB.contact_point_rec_type := p_orgph_contact_point_rec;
    l_orgfax_contact_point_rec     HZ_CONTACT_POINT_V2PUB.contact_point_rec_type := p_orgfax_contact_point_rec;

    l_org_name HZ_PARTIES.PARTY_NAME%TYPE := null;

    l_person_party_id    NUMBER := l_person_rec.party_rec.party_id;
    l_rel_party_id       NUMBER := FND_API.G_MISS_NUM;
    l_org_party_id       NUMBER := l_organization_rec.party_rec.party_id;
    --for ER 5917800
    l_email_rec  HZ_CONTACT_POINT_V2PUB.email_rec_type := null;

BEGIN
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('enter ibe_party_v2pvt.Save_Tca_Entities');
    END IF;

    -- initialize message list
    FND_MSG_PUB.initialize;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- for ER 5917800
l_email_rec := p_email_rec;
l_email_rec.email_format := NVL(FND_PROFILE.VALUE('IBE_DEFAULT_USER_EMAIL_STYLE'), 'MAILTEXT');

    -- Create or Update Person
    IF ( l_person_rec.party_rec.party_id = FND_API.G_MISS_NUM or l_person_rec.party_rec.party_id is NULL) THEN
       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_UTIL.debug('Call HZ_PARTY_V2PUB.create_person () API');
       END IF;
       l_person_rec.created_by_module := p_created_by_module;
       HZ_PARTY_V2PUB.Create_Person(
              p_person_rec     =>  l_person_rec,
              x_party_id       =>  l_person_party_id,
              x_party_number   =>  l_person_party_number,
              x_profile_id     =>  l_person_profile_id,
              x_return_status  =>  x_return_status,
              x_msg_count      =>  x_msg_count,
              x_msg_data       =>  x_msg_data);
       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_UTIL.debug('Completed Call HZ_PARTY_V2PUB.create_person () API');
       END IF;
    ELSIF ( l_person_object_version_number <> FND_API.G_MISS_NUM ) THEN
       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_UTIL.debug('Call HZ_PARTY_V2PUB.update_person () API');
       END IF;

       l_person_rec.created_by_module := null;
       l_person_rec.application_id := null;
       l_person_rec.party_rec.party_number := null;
       l_person_rec.party_rec.orig_system_reference := null;

       l_person_party_id := l_person_rec.party_rec.party_id;

       HZ_PARTY_V2PUB.Update_Person(
              p_person_rec                  =>  l_person_rec,
              p_party_object_version_number =>  l_person_object_version_number,
              x_return_status               =>  x_return_status,
              x_profile_id                  =>  l_person_profile_id,
              x_msg_count                   =>  x_msg_count,
              x_msg_data                    =>  x_msg_data);

       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_UTIL.debug('Completed Call HZ_PARTY_V2PUB.update_person () API');
       END IF;
    END IF;

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('After call to HZ_PARTY_V2PUB.create/update person - x_return_status : '|| x_return_status);
       IBE_UTIL.debug('After call to HZ_PARTY_V2PUB.create/update person - x_msg_count : '|| x_msg_count);
       IBE_UTIL.debug('After call to HZ_PARTY_V2PUB.create/update person - x_msg_data :' || x_msg_data);
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS  then
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Create or Update Organization
    IF ( l_organization_rec.party_rec.party_id = FND_API.G_MISS_NUM Or l_organization_rec.party_rec.party_id is NULL) THEN
       IF( l_organization_rec.organization_name is not null AND l_organization_rec.organization_name <> FND_API.G_MISS_CHAR) THEN
           IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                IBE_UTIL.debug('Call HZ_PARTY_V2PUB.create_organization () API');
           END IF;

           l_organization_rec.created_by_module := p_created_by_module;
           l_organization_rec.application_id := G_APPLICATION_ID;
           HZ_PARTY_V2PUB.Create_Organization (
                    p_organization_rec  =>  l_organization_rec,
                  x_return_status     =>  x_return_status,
                  x_msg_count         =>  x_msg_count,
                  x_msg_data          =>  x_msg_data,
                  x_party_id          =>  l_org_party_id,
                  x_party_number   =>  l_org_party_number,
                  x_profile_id     =>  l_org_profile_id);

	         l_organization_rec.party_rec.party_id := l_org_party_id;

           IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                IBE_UTIL.debug('Completed Call HZ_PARTY_V2PUB.create_organization () API'||l_organization_rec.party_rec.party_id);
           END IF;
           IF (IBE_UTIL.G_DEBUGON = l_true) THEN
              IBE_UTIL.debug('After call to HZ_PARTY_V2PUB.create/update organization - x_return_status : '|| x_return_status);
              IBE_UTIL.debug('After call to HZ_PARTY_V2PUB.create/update organization - x_msg_count : '|| x_msg_count);
             IBE_UTIL.debug('After call to HZ_PARTY_V2PUB.create/update organization - x_msg_data :' || x_msg_data);
           END IF;
        END IF;
    ELSIF ( l_org_object_version_number <> FND_API.G_MISS_NUM ) THEN
       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_UTIL.debug('Call HZ_PARTY_V2PUB.update_organization () API');
       END IF;

       l_organization_rec.created_by_module := null;
       l_organization_rec.application_id := null;
       l_organization_rec.party_rec.orig_system_reference := null;
       HZ_PARTY_V2PUB.Update_Organization (
                p_organization_rec             =>  l_organization_rec,
              p_party_object_version_number  =>  l_org_object_version_number,
              x_profile_id                   =>  l_org_profile_id,
              x_return_status                =>  x_return_status,
              x_msg_count                    =>  x_msg_count,
              x_msg_data                     =>  x_msg_data);

       l_org_party_id := l_organization_rec.party_rec.party_id;

       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_UTIL.debug('Completed Call HZ_PARTY_V2PUB.update_organization () API');
       END IF;

       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_UTIL.debug('After call to HZ_PARTY_V2PUB.create/update organization - x_return_status : '|| x_return_status);
          IBE_UTIL.debug('After call to HZ_PARTY_V2PUB.create/update organization - x_msg_count : '|| x_msg_count);
          IBE_UTIL.debug('After call to HZ_PARTY_V2PUB.create/update organization - x_msg_data :' || x_msg_data);
       END IF;
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS  then
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    IF ( (l_org_party_id is null OR l_org_party_id=FND_API.G_MISS_NUM)
         AND l_organization_rec.party_rec.party_number is not null AND l_organization_rec.party_rec.party_number <> FND_API.G_MISS_CHAR) THEN

          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
              IBE_UTIL.debug('Getting the org_id for the party_number: '|| l_organization_rec.party_rec.party_number );
          END IF;

    	  IF(Find_Organization(
        	 x_org_id	=> l_org_party_id,
        	 x_org_num	=> l_organization_rec.party_rec.party_number,
	         x_org_name	=> l_org_name)) THEN

	         l_organization_rec.party_rec.party_id := l_org_party_id;

             IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                IBE_UTIL.debug('After call to Find_Organization - x_org_party_id : '|| l_org_party_id);
                IBE_UTIL.debug('After call to Find_Organization - x_org_num : '|| l_organization_rec.party_rec.party_number);
                IBE_UTIL.debug('After call to Find_Organization - x_org_name :' || l_org_name);
             END IF;
          END IF;
    END IF;

    -- Create Location and Party Site
    IF(l_organization_rec.party_rec.party_id is not null AND l_organization_rec.party_rec.party_id <> FND_API.G_MISS_NUM
       AND l_location_rec.Address1 is not null AND l_location_rec.Address1 <> FND_API.G_MISS_CHAR
       AND l_location_rec.Country is not null AND l_location_rec.Country <> FND_API.G_MISS_CHAR
    ) THEN -- Creating Location only for Organization in B2B flow.
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_UTIL.debug('Before Saving the Location - country: ' || l_location_rec.country);
            IBE_UTIL.debug('Before Saving the Location - address1: ' || l_location_rec.address1);
        END IF;
        IF ( l_location_rec.location_id = FND_API.G_MISS_NUM OR l_location_rec.location_id is NULL) THEN
            IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                IBE_UTIL.debug('Call IBE_ADDRESS_V2PVT.create_address API');
            END IF;

            l_location_rec.created_by_module := p_created_by_module;
            l_location_rec.application_id := G_APPLICATION_ID;

            l_party_site_rec.party_id := l_org_party_id;
            l_party_site_rec.created_by_module := p_created_by_module;
            l_party_site_rec.application_id := G_APPLICATION_ID;

            IBE_ADDRESS_V2PVT.create_address(
                         p_api_version => 1.0,
                         p_init_msg_list => null,
                         p_commit => null,
                         p_location => l_location_rec,
                         p_party_site => l_party_site_rec,
                         p_primary_billto => FND_API.G_TRUE,
                         p_primary_shipto => FND_API.G_TRUE,
                         p_billto => FND_API.G_TRUE,
                         p_shipto => FND_API.G_TRUE,
                         p_default_primary => FND_API.G_TRUE,
                         x_location_id => l_location_id,
                         x_party_site_id => l_party_site_id,
                         x_return_status  => x_return_status,
			          x_msg_count      => x_msg_count,
			          x_msg_data       => x_msg_data);

            IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                 IBE_UTIL.debug('After Call to IBE_ADDRESS_V2PVT.create_address API');
            END IF;

            IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                IBE_UTIL.debug('After call to  IBE_ADDRESS_V2PVT.create_address - x_return_status : '|| x_return_status);
                IBE_UTIL.debug('After call to  IBE_ADDRESS_V2PVT.create_address - x_msg_count : '|| x_msg_count);
                IBE_UTIL.debug('After call to  IBE_ADDRESS_V2PVT.create_address - x_msg_data :' || x_msg_data);
                IBE_UTIL.debug('After call to  IBE_ADDRESS_V2PVT.create_address - l_location_id : '|| l_location_id);
                IBE_UTIL.debug('After call to  IBE_ADDRESS_V2PVT.create_address - l_party_site_id : '|| l_party_site_id);
            END IF;

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS  then
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

        ELSIF ( l_loc_object_version_number <> FND_API.G_MISS_NUM ) THEN
            IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                IBE_UTIL.debug('Call HZ_LOCATION_V2PUB.update_location () API');
            END IF;

            HZ_LOCATION_V2PUB.update_location (
                     p_location_rec  => l_location_rec,
                     p_object_version_number => l_loc_object_version_number,
                   x_return_status => x_return_status,
                     x_msg_count     => x_msg_count,
                 x_msg_data      => x_msg_data);

            IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                IBE_UTIL.debug('After Call to HZ_LOCATION_V2PUB.update_location API');
            END IF;

            IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                  IBE_UTIL.debug('After call to HZ_LOCATION_V2PUB.update_location - x_return_status : '|| x_return_status);
                IBE_UTIL.debug('After call to HZ_LOCATION_V2PUB.update_location - x_msg_count : '|| x_msg_count);
                IBE_UTIL.debug('After call to HZ_LOCATION_V2PUB.update_location - x_msg_data :' || x_msg_data);
            END IF;

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS  then
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;
    END IF; -- if(Organization Name is not NULL)

    IF (p_create_party_rel = 'Y') THEN
       OPEN c_get_party_relationship(l_person_party_id, l_org_party_id);
       FETCH c_get_party_relationship into l_rel_party_id;
       IF c_get_party_relationship%NOTFOUND or l_rel_party_id is null or l_rel_party_id=FND_API.G_MISS_NUM THEN
           l_party_rel_rec.subject_id := l_person_party_id;
           l_party_rel_rec.subject_type :=  'PERSON';
           l_party_rel_rec.subject_table_name :=  'HZ_PARTIES';

           -- pass organization_party_id as object_id
           l_party_rel_rec.object_id :=  l_org_party_id;
           l_party_rel_rec.object_type :=  'ORGANIZATION';
           l_party_rel_rec.object_table_name :=  'HZ_PARTIES';

           l_party_rel_rec.relationship_type :=  'EMPLOYMENT';
           l_party_rel_rec.relationship_code :=  'EMPLOYEE_OF';

           l_party_rel_rec.start_date:=  sysdate;
           l_party_rel_rec.created_by_module := P_CREATED_BY_MODULE;
           l_party_rel_rec.application_id    := G_APPLICATION_ID;

           l_org_contact_rec.party_rel_rec  :=  l_party_rel_rec;
           l_org_contact_rec.created_by_module := P_CREATED_BY_MODULE;
           l_org_contact_rec.application_id    := G_APPLICATION_ID;


           IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                IBE_UTIL.debug('Call HZ_PARTY_CONTACT_V2PUB.create_org_contact () API');
           END IF;

           HZ_PARTY_CONTACT_V2PUB.create_org_contact (
                p_org_contact_rec => l_org_contact_rec,
                x_org_contact_id  => l_org_contact_id,
                x_party_rel_id    => l_party_rel_unq_id,
                x_party_id        => l_rel_party_id,
                x_party_number    => l_rel_party_number,
                x_return_status   => x_return_status,
                x_msg_count       => x_msg_count,
                x_msg_data        => x_msg_data);

           l_party_id := l_rel_party_id;

           IF (IBE_UTIL.G_DEBUGON = l_true) THEN
               IBE_UTIL.debug('After call to HZ_PARTY_CONTACT_V2PUB.create_org_contact - x_return_status : '|| x_return_status);
               IBE_UTIL.debug('After call to HZ_PARTY_CONTACT_V2PUB.create_org_contact - x_msg_count : '|| x_msg_count);
               IBE_UTIL.debug('After call to HZ_PARTY_CONTACT_V2PUB.create_org_contact - x_msg_data :' || x_msg_data);
           END IF;

           IF x_return_status <> FND_API.G_RET_STS_SUCCESS  then
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
       ELSE
           IF (IBE_UTIL.G_DEBUGON = l_true) THEN
               IBE_UTIL.debug('Party relationship already exists with party_id: ' || l_rel_party_id);
           END IF;
           l_party_id := l_rel_party_id;
       END IF;
       CLOSE c_get_party_relationship;
    ELSE
       --Find Party_Rel if org_party_id is available
	  IF (l_person_party_id <> FND_API.G_MISS_NUM and l_person_party_id is not null and l_org_party_id <> FND_API.G_MISS_NUM and l_org_party_id is not null) THEN
       OPEN c_get_party_relationship(l_person_party_id, l_org_party_id);
       FETCH c_get_party_relationship into l_rel_party_id;
	  CLOSE c_get_party_relationship;
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_UTIL.debug('New Find Party Relationship output '||l_rel_party_id);
        END IF;
	  END IF;
	  IF (l_rel_party_id is not null and l_rel_party_id <> FND_API.G_MISS_NUM) then
	    l_party_id := l_rel_party_id;
	  ELSE
         l_party_id := l_person_party_id;
	  END IF;
    END IF; -- p_create_party_rel = 'Y'
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('Going to use this l_party_id for contact_point/contact pref creation'||l_party_id);
    END IF;

    -- Find existing  contact preferences
    IF ( l_contact_pref_rec.contact_preference_id = FND_API.G_MISS_NUM or l_contact_pref_rec.contact_preference_id is NULL AND
    (l_contact_pref_rec.preference_code is not null AND l_contact_pref_rec.preference_code <> FND_API.G_MISS_CHAR)) THEN

       IF ( l_contact_pref_rec.contact_level_table is NULL or l_contact_pref_rec.contact_level_table = FND_API.G_MISS_CHAR ) THEN
            l_contact_pref_rec.contact_level_table := 'HZ_PARTIES';
       END IF;

       IF ( l_contact_pref_rec.contact_level_table_id is NULL or l_contact_pref_rec.contact_level_table_id = FND_API.G_MISS_NUM ) THEN
	    l_contact_pref_rec.contact_level_table_id := l_party_id;
	  END IF;

       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_UTIL.debug('Find Exisiting Contact Preference Record for: ' || l_contact_pref_rec.contact_level_table_id ||',' || l_contact_pref_rec.contact_level_table);
       END IF;

	 --Execute teh cursor
	   OPEN c_get_contact_preference(l_contact_pref_rec.contact_level_table_id,l_contact_pref_rec.contact_level_table);
        FETCH c_get_contact_preference into l_contact_pref_rec.contact_preference_id,l_cntct_pref_object_ver_num;
	   CLOSE c_get_contact_preference;

        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_UTIL.debug('After Finding Exisiting Contact Preference Record : ' || l_contact_pref_rec.contact_preference_id || ',' || l_cntct_pref_object_ver_num);
        END IF;
    END IF;

    -- Create contact preference
    IF ( l_contact_pref_rec.contact_preference_id = FND_API.G_MISS_NUM or l_contact_pref_rec.contact_preference_id is NULL AND
    (l_contact_pref_rec.preference_code is not null AND l_contact_pref_rec.preference_code <> FND_API.G_MISS_CHAR)) THEN
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_UTIL.debug('Call HZ_CONTACT_PREFERENCE_V2PUB.create_contact_preference API');
        END IF;
        l_contact_pref_rec.contact_type := 'ALL';
        l_contact_pref_rec.requested_by := 'INTERNAL';
        l_contact_pref_rec.status := 'A';
        l_contact_pref_rec.created_by_module := p_created_by_module;


        HZ_CONTACT_PREFERENCE_V2PUB.create_contact_preference(

                               p_contact_preference_rec => l_contact_pref_rec,
                               x_contact_preference_id  => l_contact_preference_id,
                           x_return_status   =>  x_return_status,
                           x_msg_count       =>  x_msg_count,
                           x_msg_data        =>  x_msg_data);
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_UTIL.debug('After Call to HZ_CONTACT_PREFERENCE_V2PUB.create_contact_preference API');
        END IF;
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_UTIL.debug('After call to HZ_CONTACT_PREFERENCE_V2PUB.create_contact_preference - x_return_status : '|| x_return_status);
           IBE_UTIL.debug('After call to HZ_CONTACT_PREFERENCE_V2PUB.create_contact_preference - x_msg_count : '|| x_msg_count);
           IBE_UTIL.debug('After call to HZ_CONTACT_PREFERENCE_V2PUB.create_contact_preference - x_msg_data :' || x_msg_data);
        END IF;
    ELSIF ( l_cntct_pref_object_ver_num <> FND_API.G_MISS_NUM ) THEN
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_UTIL.debug('Call HZ_CONTACT_PREFERENCE_V2PUB.update_contact_preference API');
        END IF;

        HZ_CONTACT_PREFERENCE_V2PUB.update_contact_preference(
                   p_contact_preference_rec => l_contact_pref_rec,
                   p_object_version_number  => l_cntct_pref_object_ver_num,
                   x_return_status   =>  x_return_status,
                   x_msg_count       =>  x_msg_count,
                           x_msg_data        =>  x_msg_data);
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_UTIL.debug('After Call to HZ_CONTACT_PREFERENCE_V2PUB.update_contact_preference API');
        END IF;
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_UTIL.debug('After call to HZ_CONTACT_PREFERENCE_V2PUB.update_contact_preference - x_return_status : '|| x_return_status);
           IBE_UTIL.debug('After call to HZ_CONTACT_PREFERENCE_V2PUB.update_contact_preference - x_msg_count : '|| x_msg_count);
           IBE_UTIL.debug('After call to HZ_CONTACT_PREFERENCE_V2PUB.update_contact_preference - x_msg_data :' || x_msg_data);
        END IF;
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS  then
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Create Party/Relationship Contact Points
    if (l_email_rec.email_address is not NULL and l_email_rec.email_address <> FND_API.G_MISS_CHAR) then
       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_UTIL.debug('Email address is not null, Email Address: ' || l_email_rec.email_address);
       END IF;
       -- calling TCA API to create_email_contact_points
       IF (l_email_contact_point_rec.contact_point_id = FND_API.G_MISS_NUM or l_email_contact_point_rec.contact_point_id is NULL) THEN
          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
              IBE_UTIL.debug('Call HZ_CONTACT_POINT_V2PUB.create_email_contact_point API');
          END IF;

          l_email_contact_point_rec.status := 'A';
          l_email_contact_point_rec.owner_table_name := 'HZ_PARTIES';
          l_email_contact_point_rec.created_by_module := p_created_by_module;
          l_email_contact_point_rec.application_id := G_APPLICATION_ID;
          l_email_contact_point_rec.contact_point_type := 'EMAIL';
          l_email_contact_point_rec.contact_point_purpose := null;

          IF ( l_email_contact_point_rec.owner_table_id = FND_API.G_MISS_NUM or l_email_contact_point_rec.owner_table_id is null) THEN
             l_email_contact_point_rec.owner_table_id := l_party_id;
          END IF;

          HZ_CONTACT_POINT_V2PUB.create_email_contact_point (
                            p_contact_point_rec => l_email_contact_point_rec,
                                p_email_rec => l_email_rec,
                                x_contact_point_id => l_email_contact_point_id,
                              x_return_status => x_return_status,
                             x_msg_count => x_msg_count,
                             x_msg_data => x_msg_data);

         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_UTIL.debug('After call to HZ_CONTACT_POINT_V2PUB.create_email_contact_point');
         END IF;

         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_UTIL.debug('After call to HZ_CONTACT_POINT_V2PUB.create_email_contact_point - x_return_status : '|| x_return_status);
            IBE_UTIL.debug('After call to HZ_CONTACT_POINT_V2PUB.create_email_contact_point - x_msg_count : '|| x_msg_count);
            IBE_UTIL.debug('After call to HZ_CONTACT_POINT_V2PUB.create_email_contact_point - x_msg_data :' || x_msg_data);
         END IF;
       ELSIF ( l_email_object_version_number <> FND_API.G_MISS_NUM ) THEN
         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
             IBE_UTIL.debug('Call HZ_CONTACT_POINT_V2PUB.update_email_contact_point API');
         END IF;
            IBE_UTIL.debug('Email Object Version Number' || l_email_object_version_number);
         HZ_CONTACT_POINT_V2PUB.update_email_contact_point (
                           p_contact_point_rec => l_email_contact_point_rec,
                          p_email_rec => l_email_rec,
                       p_object_version_number => l_email_object_version_number,
                          x_return_status => x_return_status,
                          x_msg_count => x_msg_count,
                            x_msg_data => x_msg_data);

         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_UTIL.debug('After call to HZ_CONTACT_POINT_V2PUB.update_email_contact_point');
         END IF;

         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_UTIL.debug('After call to HZ_CONTACT_POINT_V2PUB.update_email_contact_point - x_return_status : '|| x_return_status);
            IBE_UTIL.debug('After call to HZ_CONTACT_POINT_V2PUB.update_email_contact_point - x_msg_count : '|| x_msg_count);
            IBE_UTIL.debug('After call to HZ_CONTACT_POINT_V2PUB.update_email_contact_point - x_msg_data :' || x_msg_data);
         END IF;
       END IF;

       if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       end if;
    end if;


    -- Create Person/Contact WorkPhoneNumber
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug(' Workphone_Number : '|| Length(p_work_phone_rec.phone_number));
    END IF;

    if ( (p_work_phone_rec.phone_number is not NULL) and ( Length(p_work_phone_rec.phone_number) > 0 ) and (p_work_phone_rec.phone_number <> FND_API.G_MISS_CHAR) ) then
       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_UTIL.debug('Work Phone num is not null phone_Number : '|| p_work_phone_rec.phone_number);
       END IF;

       IF (l_workph_contact_point_rec.contact_point_id = FND_API.G_MISS_NUM or l_workph_contact_point_rec.contact_point_id is NULL) THEN
          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
              IBE_UTIL.debug('Call HZ_CONTACT_POINT_V2PUB.create_workph_contact_point API');
          END IF;

          l_workph_contact_point_rec.status := 'A';
          l_workph_contact_point_rec.owner_table_name := 'HZ_PARTIES';
          l_workph_contact_point_rec.created_by_module := p_created_by_module;
          l_workph_contact_point_rec.application_id := G_APPLICATION_ID;
          l_workph_contact_point_rec.contact_point_type := 'PHONE';
          l_workph_contact_point_rec.contact_point_purpose := 'BUSINESS';

          IF ( l_workph_contact_point_rec.owner_table_id= FND_API.G_MISS_NUM or l_workph_contact_point_rec.owner_table_id is null) THEN
             l_workph_contact_point_rec.owner_table_id := l_party_id;
          END IF;

          HZ_CONTACT_POINT_V2PUB.create_phone_contact_point (
                            p_contact_point_rec => l_workph_contact_point_rec,
                                p_phone_rec => p_work_phone_rec,
                                x_contact_point_id => l_workph_contact_point_id,
                              x_return_status => x_return_status,
                             x_msg_count => x_msg_count,
                             x_msg_data => x_msg_data);

         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_UTIL.debug('After call to HZ_CONTACT_POINT_V2PUB.create_workph_contact_point');
         END IF;

         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_UTIL.debug('After call to HZ_CONTACT_POINT_V2PUB.create_workph_contact_point - x_return_status : '|| x_return_status);
            IBE_UTIL.debug('After call to HZ_CONTACT_POINT_V2PUB.create_workph_contact_point - x_msg_count : '|| x_msg_count);
            IBE_UTIL.debug('After call to HZ_CONTACT_POINT_V2PUB.create_workph_contact_point - x_msg_data :' || x_msg_data);
         END IF;
       ELSIF ( l_workph_object_version_number <> FND_API.G_MISS_NUM ) THEN
          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
              IBE_UTIL.debug('Call HZ_CONTACT_POINT_V2PUB.update_workph_contact_point API');
          END IF;

          HZ_CONTACT_POINT_V2PUB.update_phone_contact_point (
                           p_contact_point_rec => l_workph_contact_point_rec,
                          p_phone_rec => p_work_phone_rec,
                       p_object_version_number => l_workph_object_version_number,
                          x_return_status => x_return_status,
                          x_msg_count => x_msg_count,
                            x_msg_data => x_msg_data);

         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_UTIL.debug('After call to HZ_CONTACT_POINT_V2PUB.update_workph_contact_point');
         END IF;

         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_UTIL.debug('After call to HZ_CONTACT_POINT_V2PUB.update_workph_contact_point - x_return_status : '|| x_return_status);
            IBE_UTIL.debug('After call to HZ_CONTACT_POINT_V2PUB.update_workph_contact_point - x_msg_count : '|| x_msg_count);
            IBE_UTIL.debug('After call to HZ_CONTACT_POINT_V2PUB.update_workph_contact_point - x_msg_data :' || x_msg_data);
         END IF;
       END IF;

       if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       end if;
    end if;


    -- Create Person/Contact PersonalPhoneNumber
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug(' Homephone_Number : '|| Length(p_home_phone_rec.phone_number));
    END IF;

    if ( (p_home_phone_rec.phone_number is not NULL) and ( Length(p_home_phone_rec.phone_number) > 0 ) and (p_home_phone_rec.phone_number <> FND_API.G_MISS_CHAR) ) then
       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_UTIL.debug('Home Phone num is not null phone_Number : '|| p_home_phone_rec.phone_number);
       END IF;

       IF (l_homeph_contact_point_rec.contact_point_id = FND_API.G_MISS_NUM or l_homeph_contact_point_rec.contact_point_id is NULL) THEN
          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
              IBE_UTIL.debug('Call HZ_CONTACT_POINT_V2PUB.create_homeph_contact_point API');
          END IF;

          l_homeph_contact_point_rec.status := 'A';
          l_homeph_contact_point_rec.owner_table_name := 'HZ_PARTIES';
          l_homeph_contact_point_rec.created_by_module := p_created_by_module;
          l_homeph_contact_point_rec.application_id := G_APPLICATION_ID;
          l_homeph_contact_point_rec.contact_point_type := 'PHONE';
          l_homeph_contact_point_rec.contact_point_purpose := 'PERSONAL';

          IF ( l_homeph_contact_point_rec.owner_table_id = FND_API.G_MISS_NUM or l_homeph_contact_point_rec.owner_table_id is null) THEN
             l_homeph_contact_point_rec.owner_table_id := l_party_id;
          END IF;

          HZ_CONTACT_POINT_V2PUB.create_phone_contact_point (
                            p_contact_point_rec => l_homeph_contact_point_rec,
                                p_phone_rec => p_home_phone_rec,
                                x_contact_point_id => l_homeph_contact_point_id,
                              x_return_status => x_return_status,
                             x_msg_count => x_msg_count,
                             x_msg_data => x_msg_data);

          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
             IBE_UTIL.debug('After call to HZ_CONTACT_POINT_V2PUB.create_homeph_contact_point');
          END IF;

         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_UTIL.debug('After call to HZ_CONTACT_POINT_V2PUB.create_homeph_contact_point - x_return_status : '|| x_return_status);
            IBE_UTIL.debug('After call to HZ_CONTACT_POINT_V2PUB.create_homeph_contact_point - x_msg_count : '|| x_msg_count);
            IBE_UTIL.debug('After call to HZ_CONTACT_POINT_V2PUB.create_homeph_contact_point - x_msg_data :' || x_msg_data);
         END IF;
       ELSIF ( l_homeph_object_version_number <> FND_API.G_MISS_NUM ) THEN
          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
              IBE_UTIL.debug('Call HZ_CONTACT_POINT_V2PUB.update_homeph_contact_point API');
          END IF;

          HZ_CONTACT_POINT_V2PUB.update_phone_contact_point (
                           p_contact_point_rec => l_homeph_contact_point_rec,
                          p_phone_rec => p_home_phone_rec,
                       p_object_version_number => l_homeph_object_version_number,
                          x_return_status => x_return_status,
                          x_msg_count => x_msg_count,
                            x_msg_data => x_msg_data);

          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
             IBE_UTIL.debug('After call to HZ_CONTACT_POINT_V2PUB.update_homeph_contact_point');
          END IF;

         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_UTIL.debug('After call to HZ_CONTACT_POINT_V2PUB.update_homeph_contact_point - x_return_status : '|| x_return_status);
            IBE_UTIL.debug('After call to HZ_CONTACT_POINT_V2PUB.update_homeph_contact_point - x_msg_count : '|| x_msg_count);
            IBE_UTIL.debug('After call to HZ_CONTACT_POINT_V2PUB.update_homeph_contact_point - x_msg_data :' || x_msg_data);
         END IF;
       END IF;

       if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       end if;
    end if;

    -- Create Person/Contact Fax Number
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug(' Fax Number : '|| Length(p_fax_rec.phone_number));
    END IF;

    if ( (p_fax_rec.phone_number is not NULL) and ( Length(p_fax_rec.phone_number) > 0 ) and (p_fax_rec.phone_number <> FND_API.G_MISS_CHAR) ) then
       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_UTIL.debug('Fax num is not null phone_Number : '|| p_fax_rec.phone_number);
       END IF;

       IF (l_fax_contact_point_rec.contact_point_id = FND_API.G_MISS_NUM or l_fax_contact_point_rec.contact_point_id is NULL) THEN
          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
              IBE_UTIL.debug('Call HZ_CONTACT_POINT_V2PUB.create_fax_contact_point API');
          END IF;

          l_fax_contact_point_rec.status := 'A';
          l_fax_contact_point_rec.owner_table_name := 'HZ_PARTIES';
          l_fax_contact_point_rec.created_by_module := p_created_by_module;
          l_fax_contact_point_rec.application_id := G_APPLICATION_ID;
          l_fax_contact_point_rec.contact_point_type := 'PHONE';
          l_fax_contact_point_rec.contact_point_purpose := null;

          IF ( l_fax_contact_point_rec.owner_table_id = FND_API.G_MISS_NUM or l_fax_contact_point_rec.owner_table_id is null) THEN
             l_fax_contact_point_rec.owner_table_id := l_party_id;
          END IF;

          HZ_CONTACT_POINT_V2PUB.create_phone_contact_point (
                            p_contact_point_rec => l_fax_contact_point_rec,
                                p_phone_rec => p_fax_rec,
                                x_contact_point_id => l_fax_contact_point_id,
                              x_return_status => x_return_status,
                             x_msg_count => x_msg_count,
                             x_msg_data => x_msg_data);

          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
             IBE_UTIL.debug('After call to HZ_CONTACT_POINT_V2PUB.create_fax_contact_point');
          END IF;

         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_UTIL.debug('After call to HZ_CONTACT_POINT_V2PUB.create_fax_contact_point - x_return_status : '|| x_return_status);
            IBE_UTIL.debug('After call to HZ_CONTACT_POINT_V2PUB.create_fax_contact_point - x_msg_count : '|| x_msg_count);
            IBE_UTIL.debug('After call to HZ_CONTACT_POINT_V2PUB.create_fax_contact_point - x_msg_data :' || x_msg_data);
         END IF;
       ELSIF ( l_fax_object_version_number <> FND_API.G_MISS_NUM ) THEN
          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
              IBE_UTIL.debug('Call HZ_CONTACT_POINT_V2PUB.update_fax_contact_point API');
          END IF;

          HZ_CONTACT_POINT_V2PUB.update_phone_contact_point (
                           p_contact_point_rec => l_fax_contact_point_rec,
                          p_phone_rec => p_fax_rec,
                       p_object_version_number => l_fax_object_version_number,
                          x_return_status => x_return_status,
                          x_msg_count => x_msg_count,
                            x_msg_data => x_msg_data);

          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
             IBE_UTIL.debug('After call to HZ_CONTACT_POINT_V2PUB.update_fax_contact_point');
          END IF;

         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_UTIL.debug('After call to HZ_CONTACT_POINT_V2PUB.update_fax_contact_point - x_return_status : '|| x_return_status);
            IBE_UTIL.debug('After call to HZ_CONTACT_POINT_V2PUB.update_fax_contact_point - x_msg_count : '|| x_msg_count);
            IBE_UTIL.debug('After call to HZ_CONTACT_POINT_V2PUB.update_fax_contact_point - x_msg_data :' || x_msg_data);
         END IF;
       END IF;

       if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       end if;
    end if;

    -- Create Organization Phone Number

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug(' org_phone_Number : '|| Length(p_org_phone_rec.phone_number));
    END IF;

    if ( (p_org_phone_rec.phone_number is not NULL) and ( Length(p_org_phone_rec.phone_number) > 0 ) and (p_org_phone_rec.phone_number <> FND_API.G_MISS_CHAR) ) then
       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_UTIL.debug('Org Phone num is not null phone_Number : '|| p_org_phone_rec.phone_number);
       END IF;


       IF ( l_orgph_contact_point_rec.contact_point_id = FND_API.G_MISS_NUM or l_orgph_contact_point_rec.contact_point_id is NULL) THEN

          l_orgph_contact_point_rec.status := 'A';
          l_orgph_contact_point_rec.owner_table_name := 'HZ_PARTIES';
          l_orgph_contact_point_rec.created_by_module := p_created_by_module;
          l_orgph_contact_point_rec.application_id := G_APPLICATION_ID;
          l_orgph_contact_point_rec.contact_point_type := 'PHONE';
          l_orgph_contact_point_rec.contact_point_purpose := 'BUSINESS';

          IF ( l_org_party_id is not NULL AND l_org_party_id <> FND_API.G_MISS_NUM ) THEN

             IF( l_orgph_contact_point_rec.owner_table_id = FND_API.G_MISS_NUM or l_orgph_contact_point_rec.owner_table_id is null) THEN
                 l_orgph_contact_point_rec.owner_table_id := l_org_party_id;
             END IF;

             IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                 IBE_UTIL.debug('Call HZ_CONTACT_POINT_V2PUB.create_orgPh_contact_point API');
             END IF;

             HZ_CONTACT_POINT_V2PUB.create_phone_contact_point (
                            p_contact_point_rec => l_orgph_contact_point_rec,
                                p_phone_rec => p_org_phone_rec,
                                x_contact_point_id => l_orgph_contact_point_id,
                              x_return_status => x_return_status,
                             x_msg_count => x_msg_count,
                             x_msg_data => x_msg_data);

             IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                 IBE_UTIL.debug('After call to HZ_CONTACT_POINT_V2PUB.create_orgPh_contact_point');
             END IF;

             IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                 IBE_UTIL.debug('After call to HZ_CONTACT_POINT_V2PUB.create_orgPh_contact_point - x_return_status : '|| x_return_status);
                 IBE_UTIL.debug('After call to HZ_CONTACT_POINT_V2PUB.create_orgPh_contact_point - x_msg_count : '|| x_msg_count);
                 IBE_UTIL.debug('After call to HZ_CONTACT_POINT_V2PUB.create_orgPh_contact_point - x_msg_data :' || x_msg_data);
             END IF;
          END IF;
       ELSIF ( l_orgph_contact_point_rec.contact_point_id <> FND_API.G_MISS_NUM or l_orgph_contact_point_rec.contact_point_id is not NULL
                            AND l_orgph_object_version_number <> FND_API.G_MISS_NUM ) THEN
          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
              IBE_UTIL.debug('Call HZ_CONTACT_POINT_V2PUB.update_orgPh_contact_point API');
          END IF;

          HZ_CONTACT_POINT_V2PUB.update_phone_contact_point (
                           p_contact_point_rec => l_orgph_contact_point_rec,
                          p_phone_rec => p_org_phone_rec,
                       p_object_version_number => l_orgph_object_version_number,
                          x_return_status => x_return_status,
                          x_msg_count => x_msg_count,
                            x_msg_data => x_msg_data);

          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
             IBE_UTIL.debug('After call to HZ_CONTACT_POINT_V2PUB.update_orgPh_contact_point');
          END IF;

         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_UTIL.debug('After call to HZ_CONTACT_POINT_V2PUB.update_orgPh_contact_point - x_return_status : '|| x_return_status);
            IBE_UTIL.debug('After call to HZ_CONTACT_POINT_V2PUB.update_orgPh_contact_point - x_msg_count : '|| x_msg_count);
            IBE_UTIL.debug('After call to HZ_CONTACT_POINT_V2PUB.update_orgPh_contact_point - x_msg_data :' || x_msg_data);
         END IF;
       END IF;

       if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       end if;
    end if;

    -- Create Organization Fax Number

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug(' Org_fax_Number : '|| Length(p_org_fax_rec.phone_number));
    END IF;


    if ( (p_org_fax_rec.phone_number is not NULL) and ( Length(p_org_fax_rec.phone_number) > 0 ) and (p_org_fax_rec.phone_number <> FND_API.G_MISS_CHAR)) then
       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_UTIL.debug('Fax num is not null phone_Number : '|| p_org_fax_rec.phone_number);
       END IF;

       IF (l_orgfax_contact_point_rec.contact_point_id = FND_API.G_MISS_NUM or l_orgfax_contact_point_rec.contact_point_id is NULL) THEN

          l_orgfax_contact_point_rec.status := 'A';
          l_orgfax_contact_point_rec.owner_table_name := 'HZ_PARTIES';
          l_orgfax_contact_point_rec.created_by_module := p_created_by_module;
          l_orgfax_contact_point_rec.application_id := G_APPLICATION_ID;
          l_orgfax_contact_point_rec.contact_point_type := 'PHONE';
          l_orgfax_contact_point_rec.contact_point_purpose := null;

          IF ( l_org_party_id is not NULL AND l_org_party_id <> FND_API.G_MISS_NUM ) THEN
             IF (l_orgfax_contact_point_rec.owner_table_id = FND_API.G_MISS_NUM or l_orgfax_contact_point_rec.owner_table_id is null) THEN
                 l_orgfax_contact_point_rec.owner_table_id := l_org_party_id;
             END IF;

             IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                 IBE_UTIL.debug('Call HZ_CONTACT_POINT_V2PUB.create_orgFax_contact_point API');
             END IF;

             HZ_CONTACT_POINT_V2PUB.create_phone_contact_point (
                            p_contact_point_rec => l_orgfax_contact_point_rec,
                                p_phone_rec => p_org_fax_rec,
                                x_contact_point_id => l_orgfax_contact_point_id,
                              x_return_status => x_return_status,
                             x_msg_count => x_msg_count,
                             x_msg_data => x_msg_data);

             IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                 IBE_UTIL.debug('After call to HZ_CONTACT_POINT_V2PUB.create_orgFax_contact_point');
             END IF;

             IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                 IBE_UTIL.debug('After call to HZ_CONTACT_POINT_V2PUB.create_orgFax_contact_point - x_return_status : '|| x_return_status);
                 IBE_UTIL.debug('After call to HZ_CONTACT_POINT_V2PUB.create_orgFax_contact_point - x_msg_count : '|| x_msg_count);
                 IBE_UTIL.debug('After call to HZ_CONTACT_POINT_V2PUB.create_orgFax_contact_point - x_msg_data :' || x_msg_data);
             END IF;
          END IF;
       ELSIF ( l_orgfax_contact_point_rec.owner_table_id <> FND_API.G_MISS_NUM AND l_orgfax_contact_point_rec.owner_table_id is not null
       	                     AND l_orgfax_object_version_number <> FND_API.G_MISS_NUM ) THEN
          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
              IBE_UTIL.debug('Call HZ_CONTACT_POINT_V2PUB.update_orgFax_contact_point API');
          END IF;

          HZ_CONTACT_POINT_V2PUB.update_phone_contact_point (
                           p_contact_point_rec => l_orgfax_contact_point_rec,
                          p_phone_rec => p_org_fax_rec,
                       p_object_version_number => l_orgfax_object_version_number,
                          x_return_status => x_return_status,
                          x_msg_count => x_msg_count,
                            x_msg_data => x_msg_data);

          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
             IBE_UTIL.debug('After call to HZ_CONTACT_POINT_V2PUB.update_orgFax_contact_point');
          END IF;

         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_UTIL.debug('After call to HZ_CONTACT_POINT_V2PUB.update_orgFax_contact_point - x_return_status : '|| x_return_status);
            IBE_UTIL.debug('After call to HZ_CONTACT_POINT_V2PUB.update_orgFax_contact_point - x_msg_count : '|| x_msg_count);
            IBE_UTIL.debug('After call to HZ_CONTACT_POINT_V2PUB.update_orgFax_contact_point - x_msg_data :' || x_msg_data);
         END IF;
       END IF;

       if x_return_status <> FND_API.G_RET_STS_SUCCESS  then
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       end if;
    end if;

    x_person_party_id := l_person_party_id;
    x_rel_party_id := l_rel_party_id;
    x_org_party_id := l_org_party_id;

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.debug('Before completing the process in IBE_PARTY_V2PVT.Save_Tca_Entites - x_person_party_id: '|| x_person_party_id);
        IBE_UTIL.debug('Before completing the process in IBE_PARTY_V2PVT.Save_Tca_Entites - x_rel_party_id: '|| x_rel_party_id);
        IBE_UTIL.debug('Before completing the process in IBE_PARTY_V2PVT.Save_Tca_Entites - x_org_party_id:' || x_org_party_id);
        IBE_UTIL.debug('IBE_PARTY_V2PVT.Save_Tca_Entites: Completing the call to Save_Tca_Entties');
    END IF;

EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN



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

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN


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

    WHEN OTHERS THEN


    FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
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

END Save_Tca_Entities;


END IBE_PARTY_V2PVT;

/
