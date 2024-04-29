--------------------------------------------------------
--  DDL for Package IBE_PARTY_V2PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_PARTY_V2PVT" AUTHID CURRENT_USER as
/* $Header: IBEVPARS.pls 120.1.12010000.2 2016/09/22 06:23:16 kdosapat ship $ */





Procedure Create_Individual_User(
        p_username		IN	VARCHAR2,
        p_password		IN	VARCHAR2,
        p_person_rec 		IN	HZ_PARTY_V2PUB.person_rec_type,
        p_email_rec	 	IN	HZ_CONTACT_POINT_V2PUB.email_rec_type,
        p_work_phone_rec 	IN	HZ_CONTACT_POINT_V2PUB.phone_rec_type,
        p_home_phone_rec 	IN	HZ_CONTACT_POINT_V2PUB.phone_rec_type,
        p_fax_rec	 		IN	HZ_CONTACT_POINT_V2PUB.phone_rec_type,
        p_contact_preference 	IN	VARCHAR2,
        x_person_party_id	OUT NOCOPY	NUMBER,
        x_user_id			OUT NOCOPY	NUMBER,
        x_return_status  	OUT NOCOPY	VARCHAR2,
        x_msg_count  		OUT NOCOPY	NUMBER,
        x_msg_data 	  	OUT NOCOPY	VARCHAR2);


 Procedure Create_Business_User(
	p_username    	          	IN	VARCHAR2,
	p_password         		IN	VARCHAR2,
	p_person_rec 		    	IN	HZ_PARTY_V2PUB.Person_Rec_type,
     	p_organization_rec	    	IN	HZ_PARTY_V2PUB.Organization_rec_type,
     	p_location_rec         		IN	HZ_LOCATION_V2PUB.Location_rec_type,
     	p_org_phone_rec     		IN	HZ_CONTACT_POINT_V2PUB.phone_rec_type,
     	p_org_fax_rec   			IN	HZ_CONTACT_POINT_V2PUB.phone_rec_type,
	p_rel_workphone_rec 		IN	HZ_CONTACT_POINT_V2PUB.phone_rec_type,
     	p_rel_homephone_rec 		IN	HZ_CONTACT_POINT_V2PUB.phone_rec_type,
     	p_rel_fax_rec	 	    	IN	HZ_CONTACT_POINT_V2PUB.phone_rec_type,
	p_rel_email_rec	   		IN	HZ_CONTACT_POINT_V2PUB.email_rec_type,
	p_rel_contact_preference 	IN	VARCHAR2,
	x_person_party_id      		OUT NOCOPY	NUMBER,
     	x_rel_party_id         		OUT NOCOPY	NUMBER,
     	x_org_party_id         		OUT NOCOPY	NUMBER,
	x_user_id         	      OUT NOCOPY	NUMBER,
	x_return_status      		OUT NOCOPY	VARCHAR2,
     	x_msg_count    	  		OUT NOCOPY	NUMBER,
     	x_msg_data      	  		OUT NOCOPY	VARCHAR2);


Procedure Create_Org_Contact(
	     	p_person_rec		IN	HZ_PARTY_V2PUB.person_rec_type,
         	p_relationship_type	IN	VARCHAR2,   -- 'EMPLOYEE_OF' or 'CONTACT_OF'
		p_org_party_id		IN 	NUMBER,
	     	p_work_phone_rec    	IN	HZ_CONTACT_POINT_V2PUB.phone_rec_type,
         	p_home_phone_rec    	IN	HZ_CONTACT_POINT_V2PUB.phone_rec_type,
         	p_fax_rec      	 	IN	HZ_CONTACT_POINT_V2PUB.phone_rec_type,
	      p_email_rec       	IN	HZ_CONTACT_POINT_V2PUB.email_rec_type,
	     	p_created_by_module 	IN	VARCHAR2,
	     	x_person_party_id   	OUT NOCOPY	NUMBER,
         	x_rel_party_id 		OUT NOCOPY	NUMBER,
         	x_return_status     	OUT NOCOPY	VARCHAR2,
         	x_msg_count     		OUT NOCOPY	NUMBER,
         	x_msg_data      		OUT NOCOPY	VARCHAR2);

Procedure Create_Person(
            p_person_rec 		IN	HZ_PARTY_V2PUB.person_rec_type,
            p_email_rec 		IN	HZ_CONTACT_POINT_V2PUB.email_rec_type,
            p_work_phone_rec 		IN	HZ_CONTACT_POINT_V2PUB.phone_rec_type,
            p_home_phone_rec 		IN	HZ_CONTACT_POINT_V2PUB.phone_rec_type,
            p_fax_rec	 	    	IN	HZ_CONTACT_POINT_V2PUB.phone_rec_type,
            p_created_by_module	IN	VARCHAR2,
            p_account			IN	VARCHAR2 := FND_API.G_FALSE,
            x_person_party_id		OUT NOCOPY	NUMBER,
            x_account_id	    	OUT NOCOPY	NUMBER,
            x_return_status  		OUT NOCOPY	VARCHAR2,
            x_msg_count  		OUT NOCOPY	NUMBER,
            x_msg_data   		OUT NOCOPY	VARCHAR2);

Procedure Create_Organization(
	p_organization_rec 	    	IN	HZ_PARTY_V2PUB.organization_rec_type,
	p_org_workphone_rec 		IN	HZ_CONTACT_POINT_V2PUB.phone_rec_type,
    	/*p_org_homephone_rec 		IN	HZ_CONTACT_POINT_V2PUB.phone_rec_type,*/
	p_org_fax_rec	         	IN	HZ_CONTACT_POINT_V2PUB.phone_rec_type,
     	p_location_rec	        	IN	HZ_LOCATION_V2PUB.location_rec_type,
     	p_party_site_rec	      	IN	HZ_PARTY_SITE_V2PUB.party_site_rec_type,
        p_primary_billto                IN      VARCHAR2 := FND_API.G_FALSE,
        p_primary_shipto                IN      VARCHAR2 := FND_API.G_FALSE,
        p_billto                        IN      VARCHAR2 := FND_API.G_FALSE,
        p_shipto                        IN      VARCHAR2 := FND_API.G_FALSE,
        p_default_primary               IN      VARCHAR2 := FND_API.G_FALSE,
	p_created_by_module	    	IN	VARCHAR2,
	p_account		        	IN	VARCHAR2 := FND_API.G_FALSE,
	x_org_party_id        		OUT NOCOPY	NUMBER,
     	x_account_id	            OUT NOCOPY	NUMBER,
		x_party_site_id		OUT	NOCOPY	NUMBER,
     	x_return_status          	OUT NOCOPY	VARCHAR2,
     	x_msg_count  	          	OUT NOCOPY	NUMBER,
     	x_msg_data   	         	OUT NOCOPY	VARCHAR2);

PROCEDURE Update_Contact_Preference(
    p_party_id           IN    NUMBER,
    p_preference         IN    VARCHAR2,
    p_object_version_number IN NUMBER,
    p_created_by_module  IN    VARCHAR2,
    x_return_status      OUT NOCOPY  VARCHAR2,
    x_msg_count          OUT NOCOPY  NUMBER,
    x_msg_data           OUT NOCOPY  VARCHAR2

   );

PROCEDURE Update_Person_Language(
    p_party_id		 IN    NUMBER,
    p_language_name      IN    VARCHAR2,
    p_created_by_module  IN  VARCHAR2,
    x_return_status      OUT NOCOPY  VARCHAR2,
    x_msg_count          OUT NOCOPY  NUMBER,
    x_msg_data           OUT NOCOPY  VARCHAR2
    );

Procedure Create_Account(
	 p_party_id			IN	NUMBER,  -- person_party_id or org_party_id
	 p_party_type		IN	VARCHAR2,
	 p_created_by_module	IN	VARCHAR2,
	 x_account_id	     	OUT NOCOPY	NUMBER,
       x_return_status  	OUT NOCOPY	VARCHAR2,
       x_msg_count  		OUT NOCOPY	NUMBER,
       x_msg_data   		OUT NOCOPY	VARCHAR2);

Procedure Create_Contact_Points(
	p_owner_table_id 		IN	NUMBER,
	p_work_phone_rec 		IN	HZ_CONTACT_POINT_V2PUB.phone_rec_type,
     	p_home_phone_rec 		IN	HZ_CONTACT_POINT_V2PUB.phone_rec_type,
     	p_fax_rec 			IN	HZ_CONTACT_POINT_V2PUB.phone_rec_type,
	p_email_rec	 		IN	HZ_CONTACT_POINT_V2PUB.email_rec_type,
     	p_contact_point_purpose	IN	BOOLEAN, --indicates whether to populate contact_point_purpose
	p_created_by_module	IN	VARCHAR2,
     	x_return_status  		OUT NOCOPY	VARCHAR2,
     	x_msg_count 		OUT NOCOPY	NUMBER,
     	x_msg_data   		OUT NOCOPY	VARCHAR2);

Procedure Update_Party_Status(
       p_party_id             IN   NUMBER,
       p_party_status         IN   VARCHAR2,
       p_change_org_status    IN   VARCHAR2 := FND_API.G_FALSE,
       p_commit               IN   VARCHAR2 := FND_API.G_FALSE,
       x_return_status        OUT  NOCOPY   VARCHAR2,
       x_msg_count            OUT  NOCOPY   NUMBER,
       x_msg_data             OUT  NOCOPY   VARCHAR2);

Function Find_Organization(
	 x_org_id		IN OUT NOCOPY	NUMBER,  --  org_party_id
	 x_org_num		IN OUT NOCOPY	VARCHAR2,
	 x_org_name		IN OUT NOCOPY	VARCHAR2) return boolean;

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
    x_msg_data                             OUT NOCOPY     VARCHAR2);


 /*procedure gen_acct_num(
    x_acct_num           OUT   VARCHAR2
  );
 */

end ibe_party_v2pvt;

/
