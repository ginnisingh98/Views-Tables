--------------------------------------------------------
--  DDL for Package Body OTA_RA_CON_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_RA_CON_API" as
/* $Header: otcon01t.pkb 120.2.12000000.2 2007/05/02 04:57:00 aabalakr noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_ra_con_api.';  -- Global package name
--
-- |--------------------------------------------------------------------------|
-- |-------------------------< insert_contact >-------------------------------|
-- |--------------------------------------------------------------------------|
--
-- PUBLIC
-- Inserts a Contact using name and customer ID
-- Currently only used by Delegate Bookings
--
procedure insert_contact (p_contact_id        out nocopy number,
                          p_customer_id       in  number,
                          p_last_name         in  varchar2,
                          p_first_name        in  varchar2,
                          p_title             in  varchar2,
                          p_administrator     in  number) is
--
  l_proc 	varchar2(72) := g_package||'insert_contact';
--

i_rel_party_id          NUMBER;
i_return_status         VARCHAR2(1);
i_msg_count             NUMBER;
i_msg_data              VARCHAR2(2000);

X_Cust_Account_Role_Id  NUMBER;
X_Contact_Number        VARCHAR2(20);
X_Orig_System_Reference VARCHAR2(20);
X_Contact_Party_Id      NUMBER;
X_Org_Contact_Id        NUMBER;

begin
--
  hr_utility.set_location('Entering:'||l_proc, 5);
  X_Cust_Account_Role_Id := NULL;
  X_Contact_Number       := NULL;
  X_Orig_System_Reference:= NULL;
  X_Contact_Party_Id     := NULL;
  X_Org_Contact_Id       := NULL;
  --
 Insert_Row(
                       X_Contact_Id              =>  P_Contact_Id,
                       X_Created_By              =>  p_administrator,
                       X_Customer_Id             =>  P_Customer_Id,
                       X_Last_Name               =>  P_Last_Name,
                       X_Last_Updated_By         =>  p_administrator,
                       X_Orig_System_Reference   =>  X_Orig_System_Reference,
                       X_First_Name              =>  P_First_Name,
                       X_Title                   =>  P_Title,
		       X_Contact_Number          =>  X_Contact_Number,
		       X_Contact_Party_Id        =>  X_Contact_Party_Id,
                       X_Rel_Party_Id            =>  i_rel_party_id,
        	       X_Org_Contact_Id          =>  X_Org_Contact_Id,
                       X_Cust_Account_Role_Id    =>  X_Cust_Account_Role_Id,
                       X_Return_Status           =>  i_Return_Status,
                       X_Msg_Count               =>  i_Msg_Count,
                       X_Msg_Data                =>  i_Msg_Data
  ) ;

--
  p_contact_id := x_cust_account_role_id;
--
  hr_utility.set_location(' Leaving:'||l_proc, 10);
end insert_contact;

-- |--------------------------------------------------------------------------|
-- |-------------------------< update_contact >-------------------------------|
-- |--------------------------------------------------------------------------|
--
-- PUBLIC
-- Updates a given Contact in RA_CONTACTS
-- Currently only used by Delegate Bookings
--
procedure update_contact (p_contact_id        in number,
                          p_last_name         in varchar2,
                          p_first_name        in varchar2,
                          p_title             in varchar2) is
--
l_proc 	varchar2(72) := g_package||'update_contact';
x_profile_id            NUMBER;
x_return_status 	VARCHAR2(1);
x_msg_count             NUMBER;
x_msg_data              VARCHAR2(2000);
tmp_var                 VARCHAR2(2000);
tmp_var1                VARCHAR2(2000);
l_temp                  VARCHAR2(30);
x_party_id              HZ_PARTIES.PARTY_ID%type;
x_party_object_version_number NUMBER;
l_sql_stat              VARCHAR2(4000);
--

begin
--
  hr_utility.set_location('Entering:'||l_proc, 5);
--
-- arkashya Bug #2652833: Changed update on ra_contacts to be based on HZ_ tables directly
/*
update HZ_PARTIES
  set
     PERSON_LAST_NAME = substrb( p_last_name,1,50),
     PERSON_FIRST_NAME = substrb(p_first_name,1,40),
     PERSON_PRE_NAME_ADJUNCT = p_title
  where
     PARTY_ID =  (select PARTY.PARTY_ID
     from HZ_CUST_ACCOUNT_ROLES ACCT_ROLE,
          HZ_PARTIES PARTY,
          HZ_RELATIONSHIPS REL,
          HZ_ORG_CONTACTS ORG_CONT,
          HZ_CUST_ACCOUNTS ROLE_ACCT
     where     ACCT_ROLE.PARTY_ID             = REL.PARTY_ID
           AND ACCT_ROLE.ROLE_TYPE            = 'CONTACT'
           AND ORG_CONT.PARTY_RELATIONSHIP_ID = REL.RELATIONSHIP_ID
           AND REL.SUBJECT_ID                 = PARTY.PARTY_ID
           AND REL.SUBJECT_TABLE_NAME         = 'HZ_PARTIES'
           AND REL.OBJECT_TABLE_NAME          = 'HZ_PARTIES'
           AND ACCT_ROLE.CUST_ACCOUNT_ID      = ROLE_ACCT.CUST_ACCOUNT_ID
           AND ROLE_ACCT.PARTY_ID	      = REL.OBJECT_ID
           AND ACCT_ROLE.CUST_ACCOUNT_ROLE_ID = p_contact_id );
*/
     SELECT party.party_id, party.object_version_number
     INTO x_party_id, x_party_object_version_number
     FROM HZ_CUST_ACCOUNT_ROLES ACCT_ROLE,
          HZ_PARTIES PARTY,
          HZ_RELATIONSHIPS REL,
          HZ_ORG_CONTACTS ORG_CONT,
          HZ_CUST_ACCOUNTS ROLE_ACCT
     WHERE ACCT_ROLE.PARTY_ID                 = REL.PARTY_ID
           AND ACCT_ROLE.ROLE_TYPE            = 'CONTACT'
           AND ORG_CONT.PARTY_RELATIONSHIP_ID = REL.RELATIONSHIP_ID
           AND REL.SUBJECT_ID                 = PARTY.PARTY_ID
           AND REL.SUBJECT_TABLE_NAME         = 'HZ_PARTIES'
           AND REL.OBJECT_TABLE_NAME          = 'HZ_PARTIES'
           AND ACCT_ROLE.CUST_ACCOUNT_ID      = ROLE_ACCT.CUST_ACCOUNT_ID
           AND ROLE_ACCT.PARTY_ID	      = REL.OBJECT_ID
           AND ACCT_ROLE.CUST_ACCOUNT_ROLE_ID = p_contact_id;

-- Update person party using HZ_PARTY_V2PUB V2 APIs

       l_sql_stat := ' Declare
          per_rec         HZ_PARTY_V2PUB.person_rec_type;
          party_rec       HZ_PARTY_V2PUB.party_rec_type;
        Begin
          per_rec.party_rec.party_id	:= :x_party_id;
          per_rec.party_rec.status	:= ''A'';
          per_rec.person_first_name	:= :p_first_name;
          per_rec.person_last_name	:= :p_last_name;
          per_rec.person_title		:= :p_title;

	  HZ_PARTY_V2PUB.update_person(
                null,
                per_rec,
                :x_party_object_version_number,
        	:x_profile_id,
                :x_return_status,
                :x_msg_count,
                :x_msg_data
                );
        End;';

     EXECUTE IMMEDIATE l_sql_stat
             USING   IN  x_party_id
             ,       IN  p_first_name
             ,       IN  p_last_name
             ,       IN  p_title
             ,       IN OUT x_party_object_version_number
	     ,       OUT x_profile_id
             ,       OUT x_return_status
             ,       OUT x_msg_count
             ,       OUT x_msg_data;


--dbms_output.put_line('x_contact_party_id--'||x_contact_party_id);
          IF x_msg_count > 1 THEN
            FOR i IN 1..x_msg_count  LOOP
              tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
              tmp_var1 := tmp_var1 || ' '|| tmp_var;
            END LOOP;
            x_msg_data := tmp_var1;
          END IF;


--dbms_output.put_line('x_return_status--'||x_return_status);
        IF x_return_status <> 'S' THEN
          RETURN;
        END IF;



  hr_utility.set_location(' Leaving:'||l_proc, 10);
end;
--

-- |--------------------------------------------------------------------------|
-- |-------------------------< Insert_Row >-----------------------------------|
-- |--------------------------------------------------------------------------|
--
-- PUBLIC
-- hdshah Bug#1729321 Insert_Row procedure included to create contacts using TCA apis.
PROCEDURE Insert_Row(
                       X_Contact_Id            IN  OUT NOCOPY NUMBER,
                       X_Created_By                     NUMBER,
                       X_Creation_Date                  DATE  ,
                       X_Customer_Id                    NUMBER,
                       X_Last_Name                      VARCHAR2,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Date               DATE    ,
                       X_Orig_System_Reference IN OUT NOCOPY   VARCHAR2 ,
                       X_Status                         VARCHAR2 ,
                       X_Address_Id                     NUMBER  ,
                       X_Contact_Key                    VARCHAR2 ,
                       X_First_Name                     VARCHAR2,
                       X_Job_Title                      VARCHAR2 ,
                       X_Last_Update_Login              NUMBER   ,
                       X_Mail_Stop                      VARCHAR2 ,
                       X_Title                          VARCHAR2,
                       X_Attribute_Category             VARCHAR2 ,
                       X_Attribute1                     VARCHAR2 ,
                       X_Attribute2                     VARCHAR2 ,
                       X_Attribute3                     VARCHAR2 ,
                       X_Attribute4                     VARCHAR2 ,
                       X_Attribute5                     VARCHAR2 ,
                       X_Attribute6                     VARCHAR2 ,
                       X_Attribute7                     VARCHAR2 ,
                       X_Attribute8                     VARCHAR2 ,
                       X_Attribute9                     VARCHAR2 ,
                       X_Attribute10                    VARCHAR2 ,
                       X_Attribute11                    VARCHAR2 ,
                       X_Attribute12                    VARCHAR2 ,
                       X_Attribute13                    VARCHAR2 ,
                       X_Attribute14                    VARCHAR2 ,
                       X_Attribute15                    VARCHAR2 ,
                       X_Attribute16                    VARCHAR2 ,
                       X_Attribute17                    VARCHAR2 ,
                       X_Attribute18                    VARCHAR2 ,
                       X_Attribute19                    VARCHAR2 ,
                       X_Attribute20                    VARCHAR2 ,
                       X_Attribute21                    VARCHAR2 ,
                       X_Attribute22                    VARCHAR2 ,
                       X_Attribute23                    VARCHAR2 ,
                       X_Attribute24                    VARCHAR2 ,
                       X_Attribute25                    VARCHAR2 ,
                       X_Email_Address                  VARCHAR2 ,
                       X_Last_Name_Alt                  VARCHAR2 ,
                       X_First_Name_Alt                 VARCHAR2 ,
                       X_Contact_Number        IN OUT NOCOPY VARCHAR2 ,
                       X_Party_Id                       NUMBER ,
                       X_Party_Site_Id                  NUMBER ,
                       X_Contact_Party_Id      IN OUT NOCOPY   NUMBER ,
                       X_Rel_Party_Id          IN OUT NOCOPY   NUMBER ,
                       X_Org_Contact_Id        IN OUT NOCOPY   NUMBER ,
                       X_Contact_Point_Id               NUMBER ,
                       X_Cust_Account_Role_Id  IN OUT NOCOPY  NUMBER ,
                       X_Return_Status             OUT NOCOPY  VARCHAR2,
                       X_Msg_Count                 OUT NOCOPY  NUMBER,
                       X_Msg_Data                  OUT NOCOPY  VARCHAR2
  ) IS

i_subject_party_id       HZ_PARTIES.PARTY_ID%type;
i_subject_party_number   VARCHAR2(30);
i_object_party_id        NUMBER;
i_profile_id             NUMBER;
tmp_var                  VARCHAR2(2000);
i_party_relationship_id  NUMBER;
i_party_id               HZ_PARTIES.PARTY_ID%type;
i_party_number           VARCHAR2(30);
i_org_contact_id         NUMBER;
tmp_var1                 VARCHAR2(2000);
i_create_org_contact     VARCHAR2(1);
i_lock_id                NUMBER;
customer_party_id        NUMBER;
l_temp                   VARCHAR2(1);
l_sql_stat               VARCHAR2(4000);
l_sql_stat_2             VARCHAR2(4000);
l_sql_stat_3             VARCHAR2(4000);
l_created_by_module varchar2(150);
per_rec         HZ_PARTY_V2PUB.person_rec_type ;
party_rec       HZ_PARTY_V2PUB.party_rec_type ;
ocon_rec      HZ_PARTY_CONTACT_V2PUB.org_contact_rec_type ;
party_rel_rec HZ_RELATIONSHIP_V2PUB.relationship_rec_type ;
arole_rec       HZ_CUST_ACCOUNT_ROLE_V2PUB.cust_account_role_rec_type;

BEGIN
     i_create_org_contact := 'Y';
     l_created_by_module  := 'OLMENR';

     SELECT hz_contact_numbers_s.nextval INTO X_Contact_Number FROM DUAL;




          per_rec.party_rec.status        := 'A';
          per_rec.person_first_name       := x_first_name;
          per_rec.person_last_name        := x_last_name;
          per_rec.person_title            := x_title;
          per_rec.created_by_module       := l_created_by_module;

          HZ_PARTY_V2PUB.create_person(
                l_temp,
                per_rec,
		        i_subject_party_id,
            i_subject_party_number,
	        i_profile_id,
                x_return_status,
                x_msg_count,
                x_msg_data
                );


      x_contact_party_id := i_subject_party_id;

--dbms_output.put_line('x_contact_party_id--'||x_contact_party_id);
          IF x_msg_count > 1 THEN
            FOR i IN 1..x_msg_count  LOOP
              tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
              tmp_var1 := tmp_var1 || ' '|| tmp_var;
            END LOOP;
            x_msg_data := tmp_var1;
          END IF;

--dbms_output.put_line('x_return_status--'||x_return_status);
        IF x_return_status <> 'S' THEN
          RETURN;
        END IF;
 --Column relationship_code must have a value. Invalid value for subject_id. Please enter  id value from .
 --Column subject_table_name must have a value.(HZ_PARTIES)
 --Column subject_type must have a value. Invalid value for object_id. Please enter  id value from .(PERSON)
 --Column object_table_name must have a value.(HZ_PARTIES)
 --Column object_type must have a value (ORGANIZATION)
        --
        --  Create an Org Contact
        --
--Check for select and customer_party_id hdshah
          select party_id into customer_party_id from hz_cust_accounts where
                                          cust_account_id = x_customer_id;

        ocon_rec.party_rel_rec.subject_id           := i_subject_party_id;
        ocon_rec.party_rel_rec.object_id            := customer_party_id;
        ocon_rec.party_rel_rec.relationship_type    := 'CONTACT';
        ocon_rec.party_rel_rec.relationship_code    := 'CONTACT_OF';
        ocon_rec.party_rel_rec.subject_table_name   := 'HZ_PARTIES';
        ocon_rec.party_rel_rec.object_table_name     :='HZ_PARTIES';
        ocon_rec.party_rel_rec.subject_type         := 'PERSON';
        ocon_rec.party_rel_rec.object_type          := 'ORGANIZATION';
        ocon_rec.party_rel_rec.start_date           := sysdate;
        ocon_rec.contact_number           := x_contact_number;
        ocon_rec.job_title                := x_job_title;
        ocon_rec.party_site_id            := x_party_site_id;
        --ocon_rec.title                := x_title;
        ocon_rec.orig_system_reference    := x_orig_system_reference;
        ocon_rec.attribute_category       := x_Attribute_Category;
        ocon_rec.attribute1               := x_Attribute1;
        ocon_rec.attribute2               := x_Attribute2;
        ocon_rec.attribute3               := x_Attribute3;
        ocon_rec.attribute4               := x_Attribute4;
        ocon_rec.attribute5               := x_Attribute5;
        ocon_rec.attribute6               := x_Attribute6;
        ocon_rec.attribute7               := x_Attribute7;
        ocon_rec.attribute8               := x_attribute8;
        ocon_rec.attribute9               := x_Attribute9;
        ocon_rec.attribute10              := x_Attribute10;
        ocon_rec.attribute11              := x_Attribute11;
        ocon_rec.attribute12              := x_Attribute12;
        ocon_rec.attribute13              := x_Attribute13;
        ocon_rec.attribute14              := x_Attribute14;
        ocon_rec.attribute15              := x_Attribute15;
        ocon_rec.attribute16              := x_Attribute16;
        ocon_rec.attribute17              := x_Attribute17;
        ocon_rec.attribute18              := x_Attribute18;
        ocon_rec.attribute19              := x_Attribute19;
        ocon_rec.attribute20              := x_Attribute20;
        ocon_rec.created_by_module        := l_created_by_module;

        HZ_PARTY_CONTACT_V2PUB.create_org_contact(
				l_temp,
				ocon_rec,
				i_org_contact_id,
				i_party_relationship_id,
				i_party_id,
				i_party_number,
				x_return_status,
				x_msg_count,
				x_msg_data);




          x_org_contact_id := i_org_contact_id;
          x_rel_party_id   := i_party_id;

--dbms_output.put_line('x_org_contact_id--'||x_org_contact_id);
--dbms_output.put_line('x_rel_party_id--'||x_rel_party_id);

          IF x_msg_count > 1 THEN
            FOR i IN 1..x_msg_count  LOOP
              tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
              tmp_var1 := tmp_var1 || ' '|| tmp_var;
            END LOOP;
            x_msg_data := tmp_var1;
          END IF;

--dbms_output.put_line('x_msg_data--'||x_msg_data);
--dbms_output.put_line('x_return_status22--'||x_return_status);
        IF x_return_status <> 'S' THEN
          RETURN;
        END IF;

        --
        --  Create a Cust Account Role
        --


        arole_rec.party_id               := i_party_id;
        arole_rec.cust_account_id        := x_customer_id;
	arole_rec.cust_acct_site_id          := x_address_id;
        arole_rec.role_type              := 'CONTACT';
        arole_rec.attribute_category     := x_Attribute_Category;
        arole_rec.attribute1             := x_Attribute1;
        arole_rec.attribute2             := x_Attribute2;
        arole_rec.attribute3             := x_Attribute3;
        arole_rec.attribute4             := x_Attribute4;
        arole_rec.attribute5             := x_Attribute5;
        arole_rec.attribute6             := x_Attribute6;
        arole_rec.attribute7             := x_Attribute7;
        arole_rec.attribute8             := x_attribute8;
        arole_rec.attribute9             := x_Attribute9;
        arole_rec.attribute10            := x_Attribute10;
        arole_rec.attribute11            := x_Attribute11;
        arole_rec.attribute12            := x_Attribute12;
        arole_rec.attribute13            := x_Attribute13;
        arole_rec.attribute14            := x_Attribute14;
        arole_rec.attribute15            := x_Attribute15;
        arole_rec.attribute16            := x_Attribute16;
        arole_rec.attribute17            := x_Attribute17;
        arole_rec.attribute18            := x_Attribute18;
        arole_rec.attribute19            := x_Attribute19;
        arole_rec.attribute20            := x_Attribute20;
        arole_rec.created_by_module       := l_created_by_module;

        HZ_CUST_ACCOUNT_ROLE_V2PUB.create_cust_account_role(
                l_temp,
                arole_rec,
                x_cust_account_role_id,
	        x_return_status,
                x_msg_count,
                x_msg_data);


        IF x_msg_count > 1 THEN
          FOR i IN 1..x_msg_count  LOOP
            tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
            tmp_var1 := tmp_var1 || ' '|| tmp_var;
          END LOOP;
          x_msg_data := tmp_var1;

        END IF;



END Insert_Row;

end ota_ra_con_api;

/
