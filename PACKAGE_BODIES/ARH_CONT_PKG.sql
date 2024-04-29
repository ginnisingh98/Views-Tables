--------------------------------------------------------
--  DDL for Package Body ARH_CONT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARH_CONT_PKG" as
/* $Header: ARHCONTB.pls 120.12 2006/12/04 09:58:42 salladi ship $*/
--
-- PROCEDURE
--     check_unique_contact_name
--
-- DESCRIPTION
--		This procedure checks that a contact name is unique.
--		If it is not it sets a message on the stack and returns
--		a warning flag.
--
-- SCOPE - PUBLIC
--
-- EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS  : IN:     x_rowid 		- uid of row
--			x_customer_id		- customer_id
--			x_first_name		-
--			x_last_name
--              OUT:
--                     	x_warning_flag  	-  W - Warning generated
--					         null - no warning genrated
-- NOTES
--
--
--
--

-- Local procedure specifications
PROCEDURE compare_existing_contact_info
( p_ocon_rec            IN hz_party_contact_v2pub.org_contact_rec_type,
  x_update_required     IN OUT NOCOPY VARCHAR2,
  x_relationship_id     IN OUT NOCOPY NUMBER,
  x_ocon_version_number IN OUT NOCOPY NUMBER );

PROCEDURE upd_ocon_update
(p_ocon_rec            IN hz_party_contact_v2pub.org_contact_rec_type);
--}

  FUNCTION INIT_SWITCH
  ( p_date   IN DATE,
    p_switch IN VARCHAR2 DEFAULT 'NULL_GMISS')
  RETURN DATE
  IS
   res_date date;
  BEGIN
   IF    p_switch = 'NULL_GMISS' THEN
     IF p_date IS NULL THEN
       res_date := FND_API.G_MISS_DATE;
     ELSE
       res_date := p_date;
     END IF;
   ELSIF p_switch = 'GMISS_NULL' THEN
     IF p_date = FND_API.G_MISS_DATE THEN
       res_date := NULL;
     ELSE
       res_date := p_date;
     END IF;
   ELSE
     res_date := TO_DATE('31/12/1800','DD/MM/RRRR');
   END IF;
   RETURN res_date;
  END;

  FUNCTION INIT_SWITCH
  ( p_char   IN VARCHAR2,
    p_switch IN VARCHAR2 DEFAULT 'NULL_GMISS')
  RETURN VARCHAR2
  IS
   res_char varchar2(2000);
  BEGIN
   IF    p_switch = 'NULL_GMISS' THEN
     IF p_char IS NULL THEN
       return FND_API.G_MISS_CHAR;
     ELSE
       return p_char;
     END IF;
   ELSIF p_switch = 'GMISS_NULL' THEN
     IF p_char = FND_API.G_MISS_CHAR THEN
       return NULL;
     ELSE
       return p_char;
     END IF;
   ELSE
     return ('INCORRECT_P_SWITCH');
   END IF;
  END;

  FUNCTION INIT_SWITCH
  ( p_num   IN NUMBER,
    p_switch IN VARCHAR2 DEFAULT 'NULL_GMISS')
  RETURN NUMBER
  IS
  BEGIN
   IF    p_switch = 'NULL_GMISS' THEN
     IF p_num IS NULL THEN
       return FND_API.G_MISS_NUM;
     ELSE
       return p_num;
     END IF;
   ELSIF p_switch = 'GMISS_NULL' THEN
     IF p_num = FND_API.G_MISS_NUM THEN
       return NULL;
     ELSE
       return p_num;
     END IF;
   ELSE
     return ('9999999999');
   END IF;
  END;

  PROCEDURE object_version_select
  (p_table_name                  IN VARCHAR2,
   p_col_id                      IN VARCHAR2,
   x_rowid                       IN OUT NOCOPY ROWID,
   x_object_version_number       IN OUT NOCOPY NUMBER,
   x_last_update_date            IN OUT NOCOPY DATE,
   x_id_value                    IN OUT NOCOPY NUMBER,
   x_return_status               IN OUT NOCOPY VARCHAR2,
   x_msg_count                   IN OUT NOCOPY NUMBER,
   x_msg_data                    IN OUT NOCOPY VARCHAR2 )
  IS
     CURSOR cu_party_version IS
      SELECT ROWID,
             OBJECT_VERSION_NUMBER,
             LAST_UPDATE_DATE,
             NULL
        FROM HZ_PARTIES
        WHERE PARTY_ID  = p_col_id;

     CURSOR cu_org_contact_version IS
     SELECT ROWID,
            OBJECT_VERSION_NUMBER,
            LAST_UPDATE_DATE,
            PARTY_RELATIONSHIP_ID
       FROM HZ_ORG_CONTACTS
      WHERE ORG_CONTACT_ID  = p_col_id;

     CURSOR cu_relationship_version IS
     SELECT ROWID,
            OBJECT_VERSION_NUMBER,
            LAST_UPDATE_DATE,
            PARTY_ID
       FROM HZ_RELATIONSHIPS
      WHERE RELATIONSHIP_ID = p_col_id
        AND DIRECTIONAL_FLAG = 'F';

     CURSOR cu_contact_pt_version IS
     SELECT ROWID,
            OBJECT_VERSION_NUMBER,
            LAST_UPDATE_DATE,
            NULL
       FROM HZ_CONTACT_POINTS
      WHERE CONTACT_POINT_ID = p_col_id;

     CURSOR cu_acct_role_version IS
     SELECT ROWID,
            OBJECT_VERSION_NUMBER,
            LAST_UPDATE_DATE,
            NULL
       FROM HZ_CUST_ACCOUNT_ROLES
      WHERE CUST_ACCOUNT_ROLE_ID = p_col_id;
    l_last_update_date   DATE;
  BEGIN
    IF p_table_name = 'HZ_PARTIES' THEN
         OPEN cu_party_version;
         FETCH cu_party_version INTO
           x_rowid                ,
           x_object_version_number,
           l_last_update_date     ,
           x_id_value;
         CLOSE cu_party_version;
    ELSIF p_table_name = 'HZ_ORG_CONTACTS' THEN
         OPEN cu_org_contact_version;
         FETCH cu_org_contact_version  INTO
           x_rowid                ,
           x_object_version_number,
           l_last_update_date     ,
           x_id_value;
         CLOSE cu_org_contact_version ;

    ELSIF p_table_name = 'HZ_RELATIONSHIPS' THEN
         OPEN cu_relationship_version;
         FETCH cu_relationship_version INTO
           x_rowid                ,
           x_object_version_number,
           l_last_update_date     ,
           x_id_value;
         CLOSE cu_relationship_version;

    ELSIF p_table_name = 'HZ_CONTACT_POINTS' THEN
         OPEN cu_contact_pt_version;
         FETCH cu_contact_pt_version  INTO
           x_rowid                ,
           x_object_version_number,
           l_last_update_date     ,
           x_id_value;
         CLOSE cu_contact_pt_version ;

    ELSIF p_table_name = 'HZ_CUST_ACCOUNT_ROLES' THEN
         OPEN cu_acct_role_version;
         FETCH cu_acct_role_version  INTO
           x_rowid                ,
           x_object_version_number,
           l_last_update_date     ,
           x_id_value;
         CLOSE cu_acct_role_version;

    END IF;

    IF x_rowid IS NULL THEN
        FND_MESSAGE.SET_NAME('AR','HZ_API_NO_RECORD');
        FND_MESSAGE.SET_TOKEN('RECORD',p_table_name);
        FND_MESSAGE.SET_TOKEN('ID',p_col_id);
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
    ELSE
     IF TO_CHAR(x_last_update_date,'DD-MON-YYYY HH:MI:SS') <>
        TO_CHAR(l_last_update_date,'DD-MON-YYYY HH:MI:SS')
     THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
        FND_MESSAGE.SET_TOKEN('TABLE', p_table_name);
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
   END IF;
  END;

  PROCEDURE update_mail_stop
  ( p_org_contact_id  IN NUMBER,
    p_mail_stop       IN VARCHAR2,
    x_return_status   IN OUT NOCOPY VARCHAR2,
    x_msg_data        IN OUT NOCOPY VARCHAR2)
  IS
   CURSOR cu_org_contact_update
   IS
   SELECT org_contact_id
     FROM hz_org_contacts
    WHERE org_contact_id =  p_org_contact_id
      FOR UPDATE OF org_contact_id NOWAIT;
   l_lock NUMBER;
  BEGIN
   OPEN cu_org_contact_update;
   FETCH cu_org_contact_update INTO l_lock;
   IF cu_org_contact_update%FOUND THEN
      UPDATE hz_org_contacts
         SET mail_stop = p_mail_stop
       WHERE org_contact_id = p_org_contact_id;
   ELSE
        FND_MESSAGE.SET_NAME('AR','HZ_API_NO_RECORD');
        FND_MESSAGE.SET_TOKEN('RECORD','HZ_ORG_CONTACTS');
        FND_MESSAGE.SET_TOKEN('ID',p_org_contact_id);
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
   END IF;
   CLOSE cu_org_contact_update;
  EXCEPTION
   WHEN OTHERS THEN
        IF cu_org_contact_update%ISOPEN THEN
           CLOSE cu_org_contact_update;
        END IF;
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_OTHERS_EXCEP' );
        FND_MESSAGE.SET_TOKEN( 'ERROR' ,SQLERRM );
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END;


  PROCEDURE check_unique_contact_name (
					x_customer_id	IN NUMBER,
					x_first_name 	IN VARCHAR2,
					x_last_name	IN VARCHAR2,
					x_warning_flag  IN OUT NOCOPY VARCHAR2 )	IS
  dummy number;
  begin
	select 	1
	into 	dummy
	from 	dual
	where	not exists ( select 	1
                             from  hz_cust_account_roles acct_role,
                                   hz_parties party,
                                   hz_relationships rel
                            where  acct_role.party_id = rel.party_id
                              and  acct_role.role_type = 'CONTACT'
                              and  rel.subject_id = party.party_id
                              and  party.person_last_name    = x_last_name
                              and  party.person_first_name   = x_first_name
                              and  acct_role.cust_account_id = x_customer_id
                              and  rel.subject_table_name    = 'HZ_PARTIES'
                              and  rel.object_table_name     = 'HZ_PARTIES'
                              and  rel.directional_flag      = 'F'
			     );
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
		fnd_message.set_name ('AR','AR_CUST_DUP_CONTACT_NAME');
		x_warning_flag := 'W';
  END check_unique_contact_name;
--
--
--
--
--
-- PROCEDURE
--     check_unique_orig_system_ref
--
-- DESCRIPTION
--		This procedure checks that orig_system_reference  is unique.
--		If it is not it sets a message on the stack and returns
--		failure.
--
-- SCOPE - PUBLIC
--
-- EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
--
-- ARGUMENTS  : IN:     x_rowid 		- uid of row
--			x_orig_system_reference - value to check
--              OUT:

-- NOTES
--
--
--
--
PROCEDURE check_unique_orig_system_ref(
  x_orig_system_reference IN VARCHAR2 ) IS
--
--
dummy number;
BEGIN
	select 	1
	into	dummy
	from 	dual
	where	not exists (	select	1
				from	hz_cust_account_roles acct_role
				where	acct_role.orig_system_reference
                                             = x_orig_system_reference
			  );
EXCEPTION
  WHEN NO_DATA_FOUND THEN
		fnd_message.set_name ('AR','AR_CUST_CONT_REF_EXISTS');
		app_exception.raise_exception;
--
END check_unique_orig_system_ref;


PROCEDURE Insert_Row(
                       X_Contact_Id              IN OUT NOCOPY NUMBER,
                       X_Created_By                     NUMBER,
                       X_Creation_Date                  DATE,
                       X_Customer_Id                    NUMBER,
                       X_Last_Name                      VARCHAR2,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Orig_System_Reference   IN OUT NOCOPY VARCHAR2,
                       X_Status                         VARCHAR2,
                       X_Address_Id                     NUMBER,
                       X_Contact_Key                    VARCHAR2,
                       X_First_Name                     VARCHAR2,
                       X_Job_Title                      VARCHAR2,
                       X_Last_Update_Login              NUMBER,
                       X_Mail_Stop                      VARCHAR2,
                       X_Title                          VARCHAR2,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Attribute16                    VARCHAR2,
                       X_Attribute17                    VARCHAR2,
                       X_Attribute18                    VARCHAR2,
                       X_Attribute19                    VARCHAR2,
                       X_Attribute20                    VARCHAR2,
                       X_Attribute21                    VARCHAR2,
                       X_Attribute22                    VARCHAR2,
                       X_Attribute23                    VARCHAR2,
                       X_Attribute24                    VARCHAR2,
                       X_Attribute25                    VARCHAR2,
                       X_Email_Address                  VARCHAR2,
                       X_Last_Name_Alt                  VARCHAR2 DEFAULT NULL,
                       X_First_Name_Alt                 VARCHAR2 DEFAULT NULL,
                       X_Contact_Number         IN OUT NOCOPY  VARCHAR2,
                       X_Party_Id                       NUMBER,
                       X_Party_Site_Id                  NUMBER,
                       X_Contact_Party_Id       IN OUT NOCOPY  NUMBER,
                       X_Org_Contact_Id         IN OUT NOCOPY  NUMBER,
                       X_Contact_Point_Id       IN OUT NOCOPY  NUMBER,
                       X_Cust_Account_Role_Id   IN OUT NOCOPY  NUMBER,
                       X_Return_Status             OUT NOCOPY  VARCHAR2,
                       X_Msg_Count                 OUT NOCOPY  NUMBER,
                       X_Msg_Data                  OUT NOCOPY  VARCHAR2
  ) IS


i_rel_party_id          NUMBER;
i_sub_party_id          NUMBER;
i_return_status         VARCHAR2(1);
i_msg_count             NUMBER;
i_msg_data              VARCHAR2(2000);
i_job_title_code        VARCHAR2(30);
BEGIN

        Insert_Row(            X_Contact_Id
        ,                      X_Created_By
        ,                      X_Creation_Date
        ,                      X_Customer_Id
        ,                      X_Last_Name
        ,                      X_Last_Updated_By
        ,                      X_Last_Update_Date
        ,                      X_Orig_System_Reference
        ,                      X_Status
        ,                      X_Address_Id
        ,                      X_Contact_Key
        ,                      X_First_Name
        ,                      X_Job_Title
        ,                      I_Job_Title_Code
        ,                      X_Last_Update_Login
        ,                      X_Mail_Stop
        ,                      X_Title
        ,                      X_Attribute_Category
        ,                      X_Attribute1
        ,                      X_Attribute2
        ,                      X_Attribute3
        ,                      X_Attribute4
        ,                      X_Attribute5
        ,                      X_Attribute6
        ,                      X_Attribute7
        ,                      X_Attribute8
        ,                      X_Attribute9
        ,                      X_Attribute10
        ,                      X_Attribute11
        ,                      X_Attribute12
        ,                      X_Attribute13
        ,                      X_Attribute14
        ,                      X_Attribute15
        ,                      X_Attribute16
        ,                      X_Attribute17
        ,                      X_Attribute18
        ,                      X_Attribute19
        ,                      X_Attribute20
        ,                      X_Attribute21
        ,                      X_Attribute22
        ,                      X_Attribute23
        ,                      X_Attribute24
        ,                      X_Attribute25
        ,                      X_Email_Address
        ,                      X_Last_Name_Alt
        ,                      X_First_Name_Alt
        ,                      X_Contact_Number
        ,                      X_Party_Id
        ,                      i_sub_party_id
        ,                      X_Party_Site_Id
        ,                      X_Contact_Party_Id
        ,                      i_rel_party_id
        ,                      X_Org_Contact_Id
        ,                      X_Contact_Point_Id
        ,                      X_Cust_Account_Role_Id
        ,                      i_return_status
        ,                      i_msg_count
        ,                      i_msg_data
        );

        X_Return_Status := i_return_status;
        X_Msg_Count := i_msg_count;
        X_Msg_Data := i_msg_data;


END Insert_Row;



PROCEDURE Insert_Row(
                       X_Contact_Id              IN OUT NOCOPY NUMBER,
                       X_Created_By                     NUMBER,
                       X_Creation_Date                  DATE,
                       X_Customer_Id                    NUMBER,
                       X_Last_Name                      VARCHAR2,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Orig_System_Reference   IN OUT NOCOPY VARCHAR2,
                       X_Status                         VARCHAR2,
                       X_Address_Id                     NUMBER,
                       X_Contact_Key                    VARCHAR2,
                       X_First_Name                     VARCHAR2,
                       X_Job_Title                      VARCHAR2,
                       X_Job_Title_Code                 VARCHAR2,
                       X_Last_Update_Login              NUMBER,
                       X_Mail_Stop                      VARCHAR2,
                       X_Title                          VARCHAR2,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Attribute16                    VARCHAR2,
                       X_Attribute17                    VARCHAR2,
                       X_Attribute18                    VARCHAR2,
                       X_Attribute19                    VARCHAR2,
                       X_Attribute20                    VARCHAR2,
                       X_Attribute21                    VARCHAR2,
                       X_Attribute22                    VARCHAR2,
                       X_Attribute23                    VARCHAR2,
                       X_Attribute24                    VARCHAR2,
                       X_Attribute25                    VARCHAR2,
                       X_Email_Address                  VARCHAR2,
                       X_Last_Name_Alt                  VARCHAR2 DEFAULT NULL,
                       X_First_Name_Alt                 VARCHAR2 DEFAULT NULL,
                       X_Contact_Number         IN OUT NOCOPY  VARCHAR2,
                       X_Party_Id                       NUMBER,
                       X_Sub_Party_Id                   NUMBER,
                       X_Party_Site_Id                  NUMBER,
                       X_Contact_Party_Id       IN OUT NOCOPY  NUMBER,
                       X_Rel_Party_Id           IN OUT NOCOPY  NUMBER,
                       X_Org_Contact_Id         IN OUT NOCOPY  NUMBER,
                       X_Contact_Point_Id       IN OUT NOCOPY  NUMBER,
                       X_Cust_Account_Role_Id   IN OUT NOCOPY  NUMBER,
                       X_Return_Status             OUT NOCOPY  VARCHAR2,
                       X_Msg_Count                 OUT NOCOPY  NUMBER,
                       X_Msg_Data                  OUT NOCOPY  VARCHAR2
  ) IS

--party_rec       hz_party_pub.party_rec_type;
--per_rec         hz_party_pub.person_rec_type;
--prel_rec        hz_party_pub.party_rel_rec_type;
--ocon_rec        hz_party_pub.org_contact_rec_type;
--cpoint_rec      hz_contact_point_pub.contact_points_rec_type;
--cust_point_rec  hz_customer_accounts_pub.cust_contact_pt_rec_type;
--email_rec       hz_contact_point_pub.email_rec_type;
--arole_rec       hz_customer_accounts_pub.cust_acct_roles_rec_type;

  party_rec       hz_party_v2pub.party_rec_type;
  per_rec         hz_party_v2pub.person_rec_type;
  prel_rec        hz_relationship_v2pub.relationship_rec_type;
  ocon_rec        hz_party_contact_v2pub.org_contact_rec_type;
  cpoint_rec      hz_contact_point_v2pub.contact_point_rec_type;
  email_rec       hz_contact_point_v2pub.email_rec_type;
  arole_rec       hz_cust_account_role_v2pub.cust_account_role_rec_type;

  i_subject_party_id       NUMBER;
  i_subject_party_number   VARCHAR2(30);
  i_object_party_id        NUMBER;
  i_profile_id             NUMBER;
  tmp_var                  VARCHAR2(2000);
  i_party_relationship_id  NUMBER;
  i_party_id               NUMBER;
  i_party_number           VARCHAR2(30);
  ii_party_number          VARCHAR2(30);
  i_org_contact_id         NUMBER;
  i_contact_point_id       NUMBER;
  i                        NUMBER;
  tmp_var1                 VARCHAR2(2000);
  i_create_org_contact     VARCHAR2(1) := 'Y';
  i_lock_id                NUMBER;
  x_cust_contact_point_id  NUMBER;
  l_generate_party_number  VARCHAR2(1);

  CURSOR cu_party_type(i_party_id IN NUMBER)
  IS
  SELECT party_type
    FROM hz_parties
   WHERE party_id = i_party_id;

  l_subject_type VARCHAR2(30);
  l_object_type  VARCHAR2(30);

  l_relationship_id   NUMBER;
  l_ocon_version_number  NUMBER;
  l_update_required      VARCHAR2(1) := 'N';

BEGIN

arp_standard.debug('arh_cont_pkg.insert_row +');
arp_standard.debug('  x_contact_number :'||x_contact_number );
arp_standard.debug('  x_contact_id     :'||x_contact_id );
        --
        -- Bug 631501: automatically assign contact number if profile
        -- option AR_AUTOMATIC_CONTACT_NUNMBERING is set to 'Yes'
        --
        IF X_Contact_Number is NULL THEN
        --  if (nvl(fnd_profile.value('AR_AUTOMATIC_CONTACT_NUMBERING'), 'N')
        -- = 'Y') then
           SELECT hz_contact_numbers_s.nextval INTO X_Contact_Number FROM DUAL;
        --  end if;
        -- Bug Fix : 2172123.
	END IF;

/* Bug fix 3421879 - ended IF statement above and created a new IF below.
   Earlier it was one if seperated by ELSIF
*/
        IF X_Org_Contact_Id IS NOT NULL THEN
           i_create_org_contact := 'N';
        END IF;

        IF i_create_org_contact = 'Y' THEN
           SELECT  hz_org_contacts_s.nextval INTO x_contact_id FROM DUAL;
        END IF;

      arp_standard.debug('  i_create_org_contact     :'||i_create_org_contact );

	-- BugFix:2225260
	--- If Subject Party does not exist,added this following if clause.
	--
        IF X_Sub_Party_Id IS NULL THEN
	        select hz_party_number_s.nextval into i_subject_party_number from dual;
       		select hz_parties_s.nextval into i_subject_party_id from dual;
        ELSE
        	i_subject_party_id := X_Sub_Party_Id;
        END IF;

      arp_standard.debug('  X_Sub_Party_Id    :'||X_Sub_Party_Id );
      arp_standard.debug('  i_subject_party_id     :'||i_subject_party_id  );

        select hz_contact_points_s.nextval into i_contact_point_id from dual;
        select hz_cust_account_roles_s.nextval into x_cust_account_role_id from dual;
        select hz_cust_contact_points_s.nextval into x_cust_contact_point_id from dual;

        --
	 -- validate uniqueness
	 --
	 arh_cont_pkg.check_unique_orig_system_ref(x_orig_system_reference);
        l_generate_party_number := fnd_profile.value('HZ_GENERATE_PARTY_NUMBER');


        --
        --  Create a person party
        --
        per_rec.party_rec.party_id := i_subject_party_id;

        IF l_generate_party_number = 'N' THEN
          per_rec.party_rec.party_number := i_subject_party_number;
        END IF;

        per_rec.party_rec.status        := 'A';
        per_rec.person_first_name              := x_first_name;
        per_rec.person_last_name               := x_last_name;
        /* Bug Fix : 2500275   */
        -- per_rec.person_title                   := x_title;
        per_rec.person_pre_name_adjunct        := x_title;
        per_rec.created_by_module              := 'TCA_FORM_WRAPPER';

        --Bug fix 1688212
	--Bug:2225260,added sub party id checking
        IF i_create_org_contact = 'Y' AND X_Sub_Party_Id IS NULL  THEN

         HZ_PARTY_V2PUB.create_person (
           p_person_rec                       => per_rec,
           x_party_id                         => i_subject_party_id,
           x_party_number                     => i_subject_party_number,
           x_profile_id                       => i_profile_id,
           x_return_status                    => x_return_status,
           x_msg_count                        => x_msg_count,
           x_msg_data                         => x_msg_data );

         IF x_msg_count > 1 THEN
          FOR i IN 1..x_msg_count  LOOP
            tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
            tmp_var1 := tmp_var1 || ' '|| tmp_var;
          END LOOP;
          x_msg_data := tmp_var1;
         END IF;

         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           return;
         END IF;

         x_contact_party_id := i_subject_party_id;

        END IF;

        --
        --  Create an Org Contact
        --
        OPEN cu_party_type(x_party_id);
        FETCH cu_party_type INTO l_object_type;
        CLOSE cu_party_type;

        OPEN cu_party_type(i_subject_party_id);
        FETCH cu_party_type INTO l_subject_type;
        CLOSE cu_party_type;

        SELECT hz_party_number_s.nextval INTO ii_party_number FROM DUAL;

        ocon_rec.party_rel_rec.subject_id               := i_subject_party_id;
        ocon_rec.party_rel_rec.subject_table_name       := 'HZ_PARTIES';
--        ocon_rec.party_rel_rec.subject_type             := 'PERSON';
        ocon_rec.party_rel_rec.subject_type             := l_subject_type;
        ocon_rec.party_rel_rec.object_id                := x_party_id;
        ocon_rec.party_rel_rec.object_table_name        := 'HZ_PARTIES';
        ocon_rec.party_rel_rec.object_type              := l_object_type;
        ocon_rec.party_rel_rec.relationship_code        := 'CONTACT_OF';
        ocon_rec.party_rel_rec.relationship_type        := 'CONTACT';
--        ocon_rec.party_rel_rec.directional_flag         := 'Y';
        ocon_rec.party_rel_rec.status                   := 'A';
        ocon_rec.party_rel_rec.start_date               := sysdate;
--        ocon_rec.party_rel_rec.party_relationship_id    := i_party_relationship_id;
        ocon_rec.party_rel_rec.created_by_module        := 'TCA_FORM_WRAPPER';

        IF l_generate_party_number = 'N' THEN
          ocon_rec.party_rel_rec.party_rec.party_number   := ii_party_number;
        END IF;

        ocon_rec.contact_number           := x_contact_number;
        ocon_rec.title                    := x_title;
        ocon_rec.job_title                := x_job_title;
        ocon_rec.job_title_code           := x_job_title_code;
--        ocon_rec.mail_stop                := x_mail_stop;
--        ocon_rec.contact_key              := x_contact_key;
        ocon_rec.party_site_id            := x_party_site_id;
        ocon_rec.orig_system_reference    := x_orig_system_reference;
--        ocon_rec.status                   := x_status;

/*bug5442145-5330162
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
*/
        ocon_rec.created_by_module        := 'TCA_FORM_WRAPPER';

        IF i_create_org_contact = 'Y' THEN

         HZ_PARTY_CONTACT_V2PUB.create_org_contact (
             p_org_contact_rec                  => ocon_rec,
             x_org_contact_id                   => i_org_contact_id,
             x_party_rel_id                     => i_party_relationship_id,
             x_party_id                         => i_party_id,
             x_party_number                     => i_party_number,
             x_return_status                    => x_return_status,
             x_msg_count                        => x_msg_count,
             x_msg_data                         => x_msg_data );

         IF x_msg_count > 1 THEN
           FOR i IN 1..x_msg_count  LOOP
             tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
             tmp_var1 := tmp_var1 || ' '|| tmp_var;
           END LOOP;
           x_msg_data := tmp_var1;
         END IF;

         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            return;
         END IF;

          x_org_contact_id := i_org_contact_id;
          x_rel_party_id := i_party_id;

        END IF;

    --
    -- mail_stop is not in V2 hz_party_contact_v2pub.org_contact_rec_type
    -- Need to do this additional update in replacement
    -- This fix has to be removed if V2 hz_party_contact_v2pub.org_contact_rec_type is
    -- changed to support the attribute MAIL_STOP
    --
    IF    (    (X_Mail_Stop IS NOT NULL)
           AND (X_Mail_Stop <> FND_API.G_MISS_CHAR))
    THEN
           update_mail_stop
             ( p_org_contact_id  => x_org_contact_id,
               p_mail_stop       => X_Mail_Stop,
               x_return_status   => x_return_status,
               x_msg_data        => x_msg_data);

          IF x_msg_count > 1 THEN
            FOR i IN 1..x_msg_count  LOOP
               tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
               tmp_var1 := tmp_var1 || ' '|| tmp_var;
            END LOOP;
            x_msg_data := tmp_var1;
          END IF;

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            return;
          END IF;

    END IF;

--{BUG#4064156
     IF i_create_org_contact = 'N' THEN

         arp_standard.debug('Calling compare_existing_contact_info ');

          ocon_rec.org_contact_id := X_Org_Contact_Id;

          compare_existing_contact_info
          ( p_ocon_rec            => ocon_rec,
            x_update_required     => l_update_required,
            x_relationship_id     => l_relationship_id,
            x_ocon_version_number => l_ocon_version_number );

         arp_standard.debug('  l_update_required :'||l_update_required);
         arp_standard.debug('  l_relationship_id :'||l_relationship_id);
         arp_standard.debug('  l_ocon_version_number :'||l_ocon_version_number);


          IF l_update_required = 'Y' THEN
             arp_standard.debug('Calling upd_ocon_update ');
             arp_standard.debug('   ocon_rec.org_contact_id :'||ocon_rec.org_contact_id);

             upd_ocon_update(p_ocon_rec   => ocon_rec);
          END IF;

     END IF;
--}

        IF i_create_org_contact = 'N' THEN
          i_subject_party_id := x_contact_party_id;
        END IF;


        --
        -- Create an email for the contact
        --
        cpoint_rec.contact_point_id       := i_contact_point_Id;
        cpoint_rec.contact_point_type     := 'EMAIL';
        cpoint_rec.status                 := 'A';
        cpoint_rec.owner_table_name       := 'HZ_PARTIES';
        cpoint_rec.owner_table_id         := i_party_id;

        -- the next 1 line is added to make sure the email_address is
        -- denormalised into hz_parties. bug - 1276469.
        cpoint_rec.primary_flag           := 'Y';
        cpoint_rec.created_by_module      := 'TCA_FORM_WRAPPER';
        email_rec.email_address           := X_Email_Address;

        IF i_create_org_contact = 'N' THEN

            SELECT p.party_id
            INTO cpoint_rec.owner_table_id
            FROM  hz_relationships p,
                  hz_org_contacts o
            WHERE o.org_contact_id = x_org_contact_id
            AND o.party_relationship_id = p.relationship_id
            AND p.subject_table_name = 'HZ_PARTIES'
            AND p.object_table_name = 'HZ_PARTIES'
            AND p.directional_flag = 'F';

        END IF;

        IF X_Email_Address is not null THEN

             HZ_CONTACT_POINT_V2PUB.create_contact_point (
                   p_contact_point_rec                 => cpoint_rec,
                   p_email_rec                         => email_rec,
                   x_contact_point_id                  => i_contact_point_id,
                   x_return_status                     => x_return_status,
                   x_msg_count                         => x_msg_count,
                   x_msg_data                          => x_msg_data
               );

           x_contact_point_id := i_contact_point_id;

           IF x_msg_count > 1 THEN
             FOR i IN 1..x_msg_count  LOOP
               tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
               tmp_var1 := tmp_var1 || ' '|| tmp_var;
             END LOOP;
             x_msg_data := tmp_var1;
           END IF;

           IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              return;
           END IF;

        END IF;

        --
        --  Create a Cust Account Role
        --
        arole_rec.cust_account_role_id    := x_cust_account_role_id;

        IF i_create_org_contact = 'Y' THEN
          arole_rec.party_id                := i_party_id;
        ELSE
          arole_rec.party_id                := x_contact_party_id;
        END IF;

        arole_rec.cust_account_id         := x_customer_id;
        arole_rec.cust_acct_site_id       := x_address_id;
--        arole_rec.begin_date              := sysdate;
        arole_rec.role_type               := 'CONTACT';
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
        arole_rec.created_by_module      := 'TCA_FORM_WRAPPER';
        --Bug Fix : 2305458.
        arole_rec.status                 := x_status;
        -- bug 1276469. passed the contactstatus.
--        arole_rec.current_role_state     := x_Status;

        HZ_CUST_ACCOUNT_ROLE_V2PUB.create_cust_account_role (
            p_cust_account_role_rec             => arole_rec,
            x_cust_account_role_id              => x_cust_account_role_id,
            x_return_status                     => x_return_status,
            x_msg_count                         => x_msg_count,
            x_msg_data                          => x_msg_data
          );

        IF x_msg_count > 1 THEN
          FOR i IN 1..x_msg_count  LOOP
           tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
           tmp_var1 := tmp_var1 || ' '|| tmp_var;
          END LOOP;
          x_msg_data := tmp_var1;
        END IF;

       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           return;
        END IF;

        IF x_return_status = 'S' and x_orig_system_reference is not null THEN

           update hz_cust_account_roles
           set orig_system_reference = x_orig_system_reference
           where cust_account_role_id =  x_cust_account_role_id;

           select orig_system_reference
           into x_orig_system_reference
           from hz_cust_account_roles
           where cust_account_role_id =  x_cust_account_role_id;

        END IF;

        IF x_return_status = 'S' THEN

           select cust_account_role_id
           into i_lock_id
           from hz_cust_account_roles
           where cust_account_role_id =  x_cust_account_role_id
           for update of cust_account_role_id nowait;

           update hz_cust_account_roles
           set attribute21 =  X_Attribute21,
               attribute22 =  X_Attribute22,
               attribute23 =  X_Attribute23,
               attribute24 =  X_Attribute24,
               attribute25 =  X_Attribute25
           where cust_account_role_id =  x_cust_account_role_id;

           select orig_system_reference
           into x_orig_system_reference
           from hz_cust_account_roles
           where cust_account_role_id =  x_cust_account_role_id;

        END IF;

END Insert_Row;


PROCEDURE Update_Row( X_contact_id                               number,
                      X_Last_Name                                VARCHAR2,
                      X_Last_Updated_By                          NUMBER,
                      X_Last_Update_Date             in out NOCOPY      DATE,
                      X_party_Last_Update_Date       in out NOCOPY      DATE,
                      X_org_cont_Last_Update_Date    in out NOCOPY      DATE,
                      X_cont_point_Last_Update_Date  in out NOCOPY      DATE,
                      X_prel_Last_Update_Date        in out NOCOPY      DATE,
                      X_rel_party_Last_Update_Date   in out NOCOPY      DATE,
                      X_Status                         VARCHAR2,
                      X_Contact_Key                    VARCHAR2,
                       X_First_Name                     VARCHAR2,
                       X_Job_Title                      VARCHAR2,
		       X_Job_Title_Code                 VARCHAR2,
                       X_Last_Update_Login              NUMBER,
                       X_Mail_Stop                      VARCHAR2,
                       X_Title                          VARCHAR2,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Attribute16                    VARCHAR2,
                       X_Attribute17                    VARCHAR2,
                       X_Attribute18                    VARCHAR2,
                       X_Attribute19                    VARCHAR2,
                       X_Attribute20                    VARCHAR2,
                       X_Attribute21                    VARCHAR2,
                       X_Attribute22                    VARCHAR2,
                       X_Attribute23                    VARCHAR2,
                       X_Attribute24                    VARCHAR2,
                       X_Attribute25                    VARCHAR2,
                       X_Email_Address                  VARCHAR2,
                       X_Last_Name_Alt                  VARCHAR2 default g_varchar2,
                       X_First_Name_Alt                 VARCHAR2 default g_varchar2,
                       x_contact_number                 VARCHAR2,
                       x_party_id                       number,
                       x_party_site_id                  number,
                       x_contact_party_id               number,
                       x_org_contact_id                 number,
                       x_contact_point_id        in out NOCOPY number,
                       x_cust_account_role_id           number,
                       x_party_relationship_id          number,
                       x_return_status              out NOCOPY varchar2,
                       x_msg_count                  out NOCOPY number,
                       x_msg_data                   out NOCOPY varchar2,
                       x_rel_party_id                   number default null)
IS
   X_PERSON_OBJECT_VERSION      NUMBER :=-1;
   x_org_contact_object_version NUMBER :=-1;
   x_rel_object_version         NUMBER :=-1;
   x_party_object_version       NUMBER :=-1;
   x_contact_pt_object_version  NUMBER :=-1;
   x_acct_role_object_version   NUMBER :=-1;
--   x_job_title_code             VARCHAR2(30);
BEGIN
Update_Row(
                       X_contact_id,
                       X_Last_Name,
                       X_Last_Updated_By,
                       X_Last_Update_Date,
                       X_party_Last_Update_Date,
                       X_org_cont_Last_Update_Date,
                       X_cont_point_Last_Update_Date,
                       X_prel_Last_Update_Date,
                       X_rel_party_Last_Update_Date,
                       X_Status                    ,
                       X_Contact_Key               ,
                       X_First_Name                ,
                       X_Job_Title                 ,
                       X_Job_Title_Code            ,
                       X_Last_Update_Login         ,
                       X_Mail_Stop                 ,
                       X_Title                     ,
                       X_Attribute_Category        ,
                       X_Attribute1                ,
                       X_Attribute2                ,
                       X_Attribute3                ,
                       X_Attribute4                ,
                       X_Attribute5                ,
                       X_Attribute6                ,
                       X_Attribute7                ,
                       X_Attribute8                ,
                       X_Attribute9                ,
                       X_Attribute10               ,
                       X_Attribute11               ,
                       X_Attribute12               ,
                       X_Attribute13               ,
                       X_Attribute14               ,
                       X_Attribute15               ,
                       X_Attribute16               ,
                       X_Attribute17               ,
                       X_Attribute18               ,
                       X_Attribute19               ,
                       X_Attribute20               ,
                       X_Attribute21               ,
                       X_Attribute22               ,
                       X_Attribute23               ,
                       X_Attribute24               ,
                       X_Attribute25               ,
                       X_Email_Address             ,
                       X_Last_Name_Alt             ,
                       X_First_Name_Alt            ,
                       x_contact_number            ,
                       x_party_id                  ,
                       x_party_site_id             ,
                       x_contact_party_id          ,
                       x_org_contact_id            ,
                       x_contact_point_id          ,
                       x_cust_account_role_id      ,
                       x_party_relationship_id     ,
                       x_return_status             ,
                       x_msg_count                 ,
                       x_msg_data                  ,
                       x_rel_party_id              ,
                       x_person_object_version     ,
                       x_org_contact_object_version,
                       x_rel_object_version        ,
                       x_party_object_version      ,
                       x_contact_pt_object_version ,
                       x_acct_role_object_version  );
END;


PROCEDURE Update_Row(
		       X_contact_id			number,
                       X_Last_Name                      VARCHAR2,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Date             in out NOCOPY        DATE,
                       X_party_Last_Update_Date       in out NOCOPY        DATE,
                       X_org_cont_Last_Update_Date    in out NOCOPY        DATE,
                       X_cont_point_Last_Update_Date  in out NOCOPY        DATE,
                       X_prel_Last_Update_Date        in out NOCOPY        DATE,
                       X_rel_party_Last_Update_Date   in out NOCOPY        DATE,
                       X_Status                         VARCHAR2,
                       X_Contact_Key                    VARCHAR2,
                       X_First_Name                     VARCHAR2,
                       X_Job_Title                      VARCHAR2,
                       X_Job_Title_Code                 VARCHAR2,
                       X_Last_Update_Login              NUMBER,
                       X_Mail_Stop                      VARCHAR2,
                       X_Title                          VARCHAR2,
                       X_Attribute_Category             VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Attribute16                    VARCHAR2,
                       X_Attribute17                    VARCHAR2,
                       X_Attribute18                    VARCHAR2,
                       X_Attribute19                    VARCHAR2,
                       X_Attribute20                    VARCHAR2,
                       X_Attribute21                    VARCHAR2,
                       X_Attribute22                    VARCHAR2,
                       X_Attribute23                    VARCHAR2,
                       X_Attribute24                    VARCHAR2,
                       X_Attribute25                    VARCHAR2,
                       X_Email_Address                  VARCHAR2,
                       X_Last_Name_Alt                  VARCHAR2 default g_varchar2,
                       X_First_Name_Alt                 VARCHAR2 default g_varchar2,
                       x_contact_number                 VARCHAR2,
                       x_party_id                       number,
                       x_party_site_id                  number,
                       x_contact_party_id               number,
                       x_org_contact_id                 number,
                       x_contact_point_id        in out NOCOPY number,
                       x_cust_account_role_id           number,
                       x_party_relationship_id          number,
                       x_return_status              out NOCOPY varchar2,
                       x_msg_count                  out NOCOPY number,
                       x_msg_data                   out NOCOPY varchar2,
                       x_rel_party_id                   number default null,
                       x_person_object_version       in out NOCOPY NUMBER,
                       x_org_contact_object_version  in out NOCOPY NUMBER,
                       x_rel_object_version          in out NOCOPY NUMBER,
                       x_party_object_version        in out NOCOPY NUMBER,
                       x_contact_pt_object_version   in out NOCOPY NUMBER,
                       x_acct_role_object_version    in out NOCOPY NUMBER
  )
IS
   party_rec       hz_party_v2pub.party_rec_type;
   per_rec         hz_party_v2pub.person_rec_type;
   prel_rec        hz_relationship_v2pub.relationship_rec_type;
   ocon_rec        hz_party_contact_v2pub.org_contact_rec_type;
   cpoint_rec      hz_contact_point_v2pub.contact_point_rec_type;
   email_rec       hz_contact_point_v2pub.email_rec_type;
   arole_rec       hz_cust_account_role_v2pub.cust_account_role_rec_type;

    tmp_var                         VARCHAR2(2000);
    i                               number;
    tmp_var1                        VARCHAR2(2000);
    x_profile_id                    NUMBER;
    i_rel_party_id                  number;
    i_lock_id                       number;
    l_date                          date;
    i_contact_point_id              number;
    x_cust_contact_point_id         number;
    l_rowid                         ROWID;
    l_version                       NUMBER;
    l_person_rowid                  ROWID;
    l_person_object_version         NUMBER;
    l_person_last_update_date       DATE;
    l_org_contact_rowid             ROWID;
    l_org_contact_object_version    NUMBER;
    l_org_contact_last_update_date  DATE;
    l_rel_rowid                     ROWID;
    l_rel_object_version            NUMBER;
    l_rel_last_update_date          DATE;
    l_dummy_id                      NUMBER;
    l_rel_id                        NUMBER;
    l_party_id                      NUMBER;
    l_party_rowid                   ROWID;
    l_party_object_version          NUMBER;
    l_party_last_update_date        DATE;
    l_contact_pt_rowid              ROWID;
    l_contact_pt_object_version     NUMBER;
    l_contact_pt_last_update_date   DATE;
    l_acct_role_rowid               ROWID;
    l_acct_role_object_version      NUMBER;
    l_acct_role_last_update_date    DATE;

  BEGIN

   --
   party_rec.party_id              := x_contact_party_id;
   party_rec.attribute_category    := INIT_SWITCH(x_Attribute_Category);
   party_rec.attribute1            := INIT_SWITCH(x_Attribute1);
   party_rec.attribute2            := INIT_SWITCH(x_Attribute2);
   party_rec.attribute3            := INIT_SWITCH(x_Attribute3);
   party_rec.attribute4            := INIT_SWITCH(x_Attribute4);
   party_rec.attribute5            := INIT_SWITCH(x_Attribute5);
   party_rec.attribute6            := INIT_SWITCH(x_Attribute6);
   party_rec.attribute7            := INIT_SWITCH(x_Attribute7);
   party_rec.attribute8            := INIT_SWITCH(x_attribute8);
   party_rec.attribute9            := INIT_SWITCH(x_Attribute9);
   party_rec.attribute10           := INIT_SWITCH(x_Attribute10);
   party_rec.attribute11           := INIT_SWITCH(x_Attribute11);
   party_rec.attribute12           := INIT_SWITCH(x_Attribute12);
   party_rec.attribute13           := INIT_SWITCH(x_Attribute13);
   party_rec.attribute14           := INIT_SWITCH(x_Attribute14);
   party_rec.attribute15           := INIT_SWITCH(x_Attribute15);
   party_rec.attribute16           := INIT_SWITCH(x_Attribute16);
   party_rec.attribute17           := INIT_SWITCH(x_Attribute17);
   party_rec.attribute18           := INIT_SWITCH(x_Attribute18);
   party_rec.attribute19           := INIT_SWITCH(x_Attribute19);
   party_rec.attribute20           := INIT_SWITCH(x_Attribute20);

   per_rec.party_rec.party_id      := x_contact_party_id;
   per_rec.person_first_name       := INIT_SWITCH(x_first_name);
   per_rec.person_last_name        := INIT_SWITCH(x_last_name);
   /*    Bug Fix : 2500275  */
   --per_rec.person_title            := INIT_SWITCH(x_title);
   per_rec.person_pre_name_adjunct := INIT_SWITCH(x_title);

   ocon_rec.org_contact_id         := x_org_contact_id;
   ocon_rec.contact_number         := INIT_SWITCH(x_contact_number);
   ocon_rec.title                  := INIT_SWITCH(x_title);
   ocon_rec.job_title              := INIT_SWITCH(x_job_title);
   ocon_rec.job_title_code         := INIT_SWITCH(x_job_title_code);
--   ocon_rec.mail_stop              := INIT_SWITCH(x_mail_stop);
--   ocon_rec.contact_key            := INIT_SWITCH(x_contact_key);
--   ocon_rec.status                 := nvl(x_status,'I');

/*bug5442145-5330162
   ocon_rec.attribute_category     := INIT_SWITCH(x_Attribute_Category);
   ocon_rec.attribute1             := INIT_SWITCH(x_Attribute1);
   ocon_rec.attribute2             := INIT_SWITCH(x_Attribute2);
   ocon_rec.attribute3             := INIT_SWITCH(x_Attribute3);
   ocon_rec.attribute4             := INIT_SWITCH(x_Attribute4);
   ocon_rec.attribute5             := INIT_SWITCH(x_Attribute5);
   ocon_rec.attribute6             := INIT_SWITCH(x_Attribute6);
   ocon_rec.attribute7             := INIT_SWITCH(x_Attribute7);
   ocon_rec.attribute8             := INIT_SWITCH(x_attribute8);
   ocon_rec.attribute9             := INIT_SWITCH(x_Attribute9);
   ocon_rec.attribute10            := INIT_SWITCH(x_Attribute10);
   ocon_rec.attribute11            := INIT_SWITCH(x_Attribute11);
   ocon_rec.attribute12            := INIT_SWITCH(x_Attribute12);
   ocon_rec.attribute13            := INIT_SWITCH(x_Attribute13);
   ocon_rec.attribute14            := INIT_SWITCH(x_Attribute14);
   ocon_rec.attribute15            := INIT_SWITCH(x_Attribute15);
   ocon_rec.attribute16            := INIT_SWITCH(x_Attribute16);
   ocon_rec.attribute17            := INIT_SWITCH(x_Attribute17);
   ocon_rec.attribute18            := INIT_SWITCH(x_Attribute18);
   ocon_rec.attribute19            := INIT_SWITCH(x_Attribute19);
   ocon_rec.attribute20            := INIT_SWITCH(x_Attribute20);
*/

   cpoint_rec.contact_point_id      := x_contact_point_Id;
   cpoint_rec.status                := nvl(x_status,'I');

   email_rec.email_address          := INIT_SWITCH(X_Email_Address);

   arole_rec.cust_account_role_id   := INIT_SWITCH(x_cust_account_role_id);
   arole_rec.attribute_category     := INIT_SWITCH(x_Attribute_Category);
   arole_rec.attribute1             := INIT_SWITCH(x_Attribute1);
   arole_rec.attribute2             := INIT_SWITCH(x_Attribute2);
   arole_rec.attribute3             := INIT_SWITCH(x_Attribute3);
   arole_rec.attribute4             := INIT_SWITCH(x_Attribute4);
   arole_rec.attribute5             := INIT_SWITCH(x_Attribute5);
   arole_rec.attribute6             := INIT_SWITCH(x_Attribute6);
   arole_rec.attribute7             := INIT_SWITCH(x_Attribute7);
   arole_rec.attribute8             := INIT_SWITCH(x_attribute8);
   arole_rec.attribute9             := INIT_SWITCH(x_Attribute9);
   arole_rec.attribute10            := INIT_SWITCH(x_Attribute10);
   arole_rec.attribute11            := INIT_SWITCH(x_Attribute11);
   arole_rec.attribute12            := INIT_SWITCH(x_Attribute12);
   arole_rec.attribute13            := INIT_SWITCH(x_Attribute13);
   arole_rec.attribute14            := INIT_SWITCH(x_Attribute14);
   arole_rec.attribute15            := INIT_SWITCH(x_Attribute15);
   arole_rec.attribute16            := INIT_SWITCH(x_Attribute16);
   arole_rec.attribute17            := INIT_SWITCH(x_Attribute17);
   arole_rec.attribute18            := INIT_SWITCH(x_Attribute18);
   arole_rec.attribute19            := INIT_SWITCH(x_Attribute19);
   arole_rec.attribute20            := INIT_SWITCH(x_Attribute20);
   -- Bug Fix : 2305458.
   arole_rec.status                 := INIT_SWITCH(x_status);
   -- bug 1276469. passed the contactstatus.
--   arole_rec.current_role_state     := INIT_SWITCH(x_Status);

    l_person_object_version := x_person_object_version;
    IF l_person_object_version   = -1 THEN
       object_version_select(
            p_table_name             => 'HZ_PARTIES',
            p_col_id                 => x_contact_party_id,
            x_rowid                  => l_person_rowid,
            x_object_version_number  => l_person_object_version,
            x_last_update_date       => l_person_last_update_date,
            x_id_value               => l_dummy_id,
            x_return_status          => x_return_status,
            x_msg_count              => x_msg_count,
            x_msg_data               => x_msg_data );

        IF x_msg_count > 1 THEN
           FOR i IN 1..x_msg_count  LOOP
             tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
             tmp_var1 := tmp_var1 || ' '|| tmp_var;
           END LOOP;
           x_msg_data := tmp_var1;
        END IF;

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           return;
        END IF;

    END IF;

    HZ_PARTY_V2PUB.update_person (
        p_person_rec                        => per_rec,
        p_party_object_version_number       => l_person_object_version,
        x_profile_id                        => x_profile_id,
        x_return_status                     => x_return_status,
        x_msg_count                         => x_msg_count,
        x_msg_data                          => x_msg_data
    );

    IF x_msg_count > 1 THEN
      FOR i IN 1..x_msg_count  LOOP
        tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
        tmp_var1 := tmp_var1 || ' '|| tmp_var;
      END LOOP;
      x_msg_data := tmp_var1;
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        return;
    END IF;


    SELECT last_update_date,
           object_version_number
      INTO x_party_Last_Update_Date,
           x_person_object_version
      FROM hz_parties
     WHERE party_id = x_contact_party_id;

    l_org_contact_object_version := x_org_contact_object_version;
    IF l_org_contact_object_version  = -1 THEN
       object_version_select(
            p_table_name             => 'HZ_ORG_CONTACTS',
            p_col_id                 => x_org_contact_id,
            x_rowid                  => l_org_contact_rowid,
            x_object_version_number  => l_org_contact_object_version,
            x_last_update_date       => l_org_contact_last_update_date,
            x_id_value               => l_rel_id,
            x_return_status          => x_return_status,
            x_msg_count              => x_msg_count,
            x_msg_data               => x_msg_data );

       IF x_msg_count > 1 THEN
           FOR i IN 1..x_msg_count  LOOP
             tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
             tmp_var1 := tmp_var1 || ' '|| tmp_var;
           END LOOP;
           x_msg_data := tmp_var1;
       END IF;

       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          return;
       END IF;

    END IF;

--HYU
    l_rel_object_version := x_rel_object_version;
    IF l_rel_object_version  = -1 THEN
       object_version_select(
            p_table_name             => 'HZ_RELATIONSHIPS',
            p_col_id                 => l_rel_id,
            x_rowid                  => l_rel_rowid,
            x_object_version_number  => l_rel_object_version,
            x_last_update_date       => l_rel_last_update_date,
            x_id_value               => l_party_id,
            x_return_status          => x_return_status,
            x_msg_count              => x_msg_count,
            x_msg_data               => x_msg_data );

            IF x_msg_count > 1 THEN
              FOR i IN 1..x_msg_count  LOOP
                 tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
                 tmp_var1 := tmp_var1 || ' '|| tmp_var;
              END LOOP;
              x_msg_data := tmp_var1;
            END IF;

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 return;
            END IF;
    END IF;

    l_party_object_version := x_party_object_version;
    IF l_party_object_version  = -1 THEN
       object_version_select(
            p_table_name             => 'HZ_PARTIES',
            p_col_id                 => l_party_id,
            x_rowid                  => l_party_rowid,
            x_object_version_number  => l_party_object_version,
            x_last_update_date       => l_party_last_update_date,
            x_id_value               => l_dummy_id,
            x_return_status          => x_return_status,
            x_msg_count              => x_msg_count,
            x_msg_data               => x_msg_data );

        IF x_msg_count > 1 THEN
           FOR i IN 1..x_msg_count  LOOP
            tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
            tmp_var1 := tmp_var1 || ' '|| tmp_var;
           END LOOP;
           x_msg_data := tmp_var1;
        END IF;

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           return;
        END IF;

    END IF;

    IF X_org_cont_Last_Update_Date = FND_API.G_MISS_DATE
       OR
       X_org_cont_Last_Update_Date IS NULL
    THEN
        ocon_rec.party_rel_rec.party_rec.party_id := NULL;
    ELSE
        ocon_rec.party_rel_rec.party_rec.party_id := l_party_id;
    END IF;

    IF l_rel_last_update_date IS NOT NULL AND
       l_rel_last_update_date <> FND_API.G_MISS_DATE
    THEN
        ocon_rec.party_rel_rec.relationship_id := l_rel_id;
    ELSE
        ocon_rec.party_rel_rec.relationship_id := NULL;
    END IF;

    HZ_PARTY_CONTACT_V2PUB.update_org_contact (
        p_org_contact_rec                   => ocon_rec,
        p_cont_object_version_number        => l_org_contact_object_version,
        p_rel_object_version_number         => l_rel_object_version,
        p_party_object_version_number       => l_party_object_version,
        x_return_status                     => x_return_status,
        x_msg_count                         => x_msg_count,
        x_msg_data                          => x_msg_data
    );

    IF x_msg_count > 1 THEN
      FOR i IN 1..x_msg_count  LOOP
        tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
        tmp_var1 := tmp_var1 || ' '|| tmp_var;
      END LOOP;
      x_msg_data := tmp_var1;
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        return;
    END IF;


    --
    -- mail_stop is not in V2 hz_party_contact_v2pub.org_contact_rec_type
    -- Need to do this additional update in replacement
    -- This fix has to be removed if V2 hz_party_contact_v2pub.org_contact_rec_type is
    -- changed to support the attribute MAIL_STOP
    --
    IF    (X_Mail_Stop IS NOT NULL)
      AND (X_Mail_Stop <> FND_API.G_MISS_CHAR)
    THEN
      update_mail_stop
      ( p_org_contact_id  => x_org_contact_id,
        p_mail_stop       => X_Mail_Stop,
        x_return_status   => x_return_status,
        x_msg_data        => x_msg_data);

      IF x_msg_count > 1 THEN
        FOR i IN 1..x_msg_count  LOOP
          tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
          tmp_var1 := tmp_var1 || ' '|| tmp_var;
        END LOOP;
        x_msg_data := tmp_var1;
      END IF;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        return;
      END IF;

    END IF;

    select last_update_date,
           object_version_number
      into X_org_cont_Last_Update_Date,
           x_org_contact_object_version
      from hz_org_contacts
     where org_contact_id = x_org_contact_id;

    select last_update_date,
           object_version_number
      into X_prel_Last_Update_Date,
           x_rel_object_version
      from hz_relationships
     where relationship_id = x_party_relationship_id
       AND subject_table_name = 'HZ_PARTIES'
       AND object_table_name = 'HZ_PARTIES'
       AND directional_flag = 'F';

  select party_id
    into i_rel_party_id
    from hz_relationships
   where relationship_id = x_party_relationship_id
     AND subject_table_name = 'HZ_PARTIES'
     AND object_table_name = 'HZ_PARTIES'
     AND directional_flag = 'F';

  select last_update_date ,
         object_version_number
    into X_rel_party_Last_Update_Date ,
         x_party_object_version
    from hz_parties
   where party_id = i_rel_party_id;


/**** the following is added for bug 1276469 ***/
    cpoint_rec.contact_point_id       := x_contact_point_Id;
    cpoint_rec.contact_point_type     := 'EMAIL';
    cpoint_rec.status                 := 'A';
/********** Bug Fix Begin#1: 3403289   ***********************/
--bug 4930521 Remove the comments

    cpoint_rec.owner_table_name       := 'HZ_PARTIES';
    cpoint_rec.owner_table_id         := x_rel_party_id;

/**********  Bug Fix End#1: 3403289   ***********************/
  -- the next 1 line is added to make sure the email_address is
  -- denormalised into hz_parties. bug - 1276469.
    l_date                            := X_Cont_Point_Last_Update_Date;

    IF x_contact_point_Id is not null then
         if X_Email_Address is not null then
                -- if new email address is passed, update contact_points
                -- record and set primary to 'Y' so that it is reflected
                -- in hz_parties through denormalization
                cpoint_rec.primary_flag           := 'Y';
                email_rec.email_address           := X_Email_Address;
         else
                -- if email address is set to null from some value
                -- then make the contact_points record non-primary.
                -- this will set email in hz_parties to null by
                -- denormalization process.
                select email_address into email_rec.email_address
                from   hz_contact_points
                where  contact_point_id = x_contact_point_id;
                cpoint_rec.primary_flag           := 'N';
         end if;

         l_contact_pt_object_version := x_contact_pt_object_version;
         IF l_contact_pt_object_version  = -1 THEN
            object_version_select(
              p_table_name             => 'HZ_CONTACT_POINTS',
              p_col_id                 => x_contact_point_Id,
              x_rowid                  => l_contact_pt_rowid,
              x_object_version_number  => l_contact_pt_object_version,
              x_last_update_date       => l_contact_pt_last_update_date,
              x_id_value               => l_dummy_id,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data );

            IF x_msg_count > 1 THEN
              FOR i IN 1..x_msg_count  LOOP
                tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
                tmp_var1 := tmp_var1 || ' '|| tmp_var;
              END LOOP;
              x_msg_data := tmp_var1;
            END IF;

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              return;
            END IF;
          END IF;

/********** Bug Fix Begin#2: 3403289   **********************/
	SELECT owner_table_name,
	       owner_table_id
	INTO   cpoint_rec.owner_table_name,
	       cpoint_rec.owner_table_id
	FROM   hz_contact_points
	WHERE  contact_point_id = x_contact_point_Id;
/**********  Bug Fix End#2: 3403289   ***********************/

          HZ_CONTACT_POINT_V2PUB.update_contact_point (
            p_contact_point_rec                 => cpoint_rec,
            p_email_rec                         => email_rec,
            p_object_version_number             => l_contact_pt_object_version,
            x_return_status                     => x_return_status,
            x_msg_count                         => x_msg_count,
            x_msg_data                          => x_msg_data
          );

          IF x_msg_count > 1 THEN
             FOR i IN 1..x_msg_count  LOOP
                 tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
                 tmp_var1 := tmp_var1 || ' '|| tmp_var;
             END LOOP;
             x_msg_data := tmp_var1;
          END IF;

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            return;
          END IF;

          select last_update_date,
                 object_version_number
            into X_cont_point_last_update_date,
                 x_contact_pt_object_version
            from hz_contact_points
           where contact_point_id = x_contact_point_id;


     ELSE
          -- if contact_point does not exist, create one if non null
          -- email address has been passed.
          if X_Email_Address IS NOT NULL then
                cpoint_rec.primary_flag           := 'Y';
                email_rec.email_address           := X_Email_Address;

                select hz_contact_points_s.nextval
                  into i_contact_point_id
                  from dual;

                cpoint_rec.contact_point_id       := i_contact_point_Id;
                cpoint_rec.created_by_module      := 'TCA_FORM_WRAPPER';

               HZ_CONTACT_POINT_V2PUB.create_contact_point (
                  p_contact_point_rec                 => cpoint_rec,
                  p_email_rec                         => email_rec,
                  x_contact_point_id                  => i_contact_point_id,
                  x_return_status                     => x_return_status,
                  x_msg_count                         => x_msg_count,
                  x_msg_data                          => x_msg_data
               );


              IF x_msg_count > 1 THEN
                FOR i IN 1..x_msg_count  LOOP
                     tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
                     tmp_var1 := tmp_var1 || ' '|| tmp_var;
                END LOOP;
                x_msg_data := tmp_var1;
              END IF;

              IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                return;
              END IF;

               x_contact_point_id := i_contact_point_id;
               select last_update_date,
                      object_version_number
                 into X_cont_point_last_update_date,
                      x_contact_pt_object_version
                 from hz_contact_points
                where contact_point_id = x_contact_point_id;


          end if;

       End if;


/*** end of code added for bug - 1276469 ***/

       l_acct_role_object_version := x_acct_role_object_version;
       IF l_acct_role_object_version  = -1 THEN
            object_version_select(
              p_table_name             => 'HZ_CUST_ACCOUNT_ROLES',
              p_col_id                 => X_cust_account_role_id,
              x_rowid                  => l_acct_role_rowid,
              x_object_version_number  => l_acct_role_object_version,
              x_last_update_date       => l_acct_role_last_update_date,
              x_id_value               => l_dummy_id,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data );

            IF x_msg_count > 1 THEN
                FOR i IN 1..x_msg_count  LOOP
                     tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
                     tmp_var1 := tmp_var1 || ' '|| tmp_var;
                END LOOP;
                x_msg_data := tmp_var1;
            END IF;

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               return;
            END IF;
        END IF;

        HZ_CUST_ACCOUNT_ROLE_V2PUB.update_cust_account_role (
          p_cust_account_role_rec             => arole_rec,
          p_object_version_number             => l_acct_role_object_version,
          x_return_status                     => x_return_status,
          x_msg_count                         => x_msg_count,
          x_msg_data                          => x_msg_data
         );

        IF x_msg_count > 1 THEN
          FOR i IN 1..x_msg_count  LOOP
            tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
            tmp_var1 := tmp_var1 || ' '|| tmp_var;
          END LOOP;
          x_msg_data := tmp_var1;
        END IF;

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          return;
        END IF;

         select cust_account_role_id
           into i_lock_id
           from hz_cust_account_roles
          where cust_account_role_id =  x_cust_account_role_id
            for update of cust_account_role_id nowait;

         update hz_cust_account_roles
          set attribute21 = X_Attribute21,
              attribute22 = X_Attribute22,
              attribute23 = X_Attribute23,
              attribute24 = X_Attribute24,
              attribute25 = X_Attribute25
        where cust_account_role_id = X_contact_id ;

        select last_update_date,
               object_version_number
          into X_Last_Update_Date,
               x_acct_role_object_version
          from hz_cust_account_roles
         where cust_account_role_id = X_contact_id;


END Update_Row;


--{BUG#4064156
PROCEDURE compare_existing_contact_info
( p_ocon_rec            IN hz_party_contact_v2pub.org_contact_rec_type,
  x_update_required     IN OUT NOCOPY VARCHAR2,
  x_relationship_id     IN OUT NOCOPY NUMBER,
  x_ocon_version_number IN OUT NOCOPY NUMBER )
IS
  CURSOR  c IS
  SELECT  contact_number,
          title         ,
          job_title     ,
          job_title_code,
          party_site_id ,
          orig_system_reference,
          attribute_category   ,
          attribute1 ,
          attribute2 ,
          attribute3 ,
          attribute4 ,
          attribute5 ,
          attribute6 ,
          attribute7 ,
          attribute8 ,
          attribute9 ,
          attribute10,
          attribute11,
          attribute12,
          attribute13,
          attribute14,
          attribute15,
          attribute16,
          attribute17,
          attribute18,
          attribute19,
          attribute20,
          object_version_number,
          party_relationship_id
    FROM hz_org_contacts
   WHERE org_contact_id = p_ocon_rec.org_contact_id;
   l_ocon_rec    hz_party_contact_v2pub.org_contact_rec_type;
BEGIN
  x_update_required   := 'N';
  IF  p_ocon_rec.org_contact_id IS NOT NULL THEN
    OPEN c;
    FETCH c INTO
          l_ocon_rec.contact_number,
          l_ocon_rec.title         ,
          l_ocon_rec.job_title     ,
          l_ocon_rec.job_title_code,
          l_ocon_rec.party_site_id ,
          l_ocon_rec.orig_system_reference,
          l_ocon_rec.attribute_category   ,
          l_ocon_rec.attribute1    ,
          l_ocon_rec.attribute2    ,
          l_ocon_rec.attribute3    ,
          l_ocon_rec.attribute4    ,
          l_ocon_rec.attribute5    ,
          l_ocon_rec.attribute6    ,
          l_ocon_rec.attribute7    ,
          l_ocon_rec.attribute8    ,
          l_ocon_rec.attribute9    ,
          l_ocon_rec.attribute10   ,
          l_ocon_rec.attribute11   ,
          l_ocon_rec.attribute12   ,
          l_ocon_rec.attribute13   ,
          l_ocon_rec.attribute14   ,
          l_ocon_rec.attribute15   ,
          l_ocon_rec.attribute16   ,
          l_ocon_rec.attribute17   ,
          l_ocon_rec.attribute18   ,
          l_ocon_rec.attribute19   ,
          l_ocon_rec.attribute20   ,
          x_ocon_version_number,
          x_relationship_id;
    IF c%NOTFOUND THEN
       RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c;

    IF NVL(l_ocon_rec.contact_number,fnd_api.g_miss_char)
         <> NVL(p_ocon_rec.contact_number,fnd_api.g_miss_char) THEN
       x_update_required := 'Y';
    ELSIF
       NVL(l_ocon_rec.title         ,fnd_api.g_miss_char)
         <> NVL(p_ocon_rec.title         ,fnd_api.g_miss_char) THEN
       x_update_required := 'Y';
    ELSIF
       NVL(l_ocon_rec.job_title     ,fnd_api.g_miss_char)
         <> NVL(p_ocon_rec.job_title     ,fnd_api.g_miss_char) THEN
       x_update_required := 'Y';
    ELSIF
       NVL(l_ocon_rec.job_title_code,fnd_api.g_miss_char)
         <> NVL(p_ocon_rec.job_title_code,fnd_api.g_miss_char) THEN
       x_update_required := 'Y';
    ELSIF
       NVL(l_ocon_rec.party_site_id ,fnd_api.g_miss_num)
         <> NVL(p_ocon_rec.party_site_id ,fnd_api.g_miss_num) THEN
       x_update_required := 'Y';
    ELSIF
       NVL(l_ocon_rec.orig_system_reference,fnd_api.g_miss_char)
         <> NVL(p_ocon_rec.orig_system_reference,fnd_api.g_miss_char) THEN
       x_update_required := 'Y';
    ELSIF
       NVL(l_ocon_rec.attribute_category   ,fnd_api.g_miss_char)
         <> NVL(p_ocon_rec.attribute_category   ,fnd_api.g_miss_char) THEN
       x_update_required := 'Y';
    ELSIF
       NVL(l_ocon_rec.attribute1    ,fnd_api.g_miss_char)
         <> NVL(p_ocon_rec.attribute1    ,fnd_api.g_miss_char) THEN
       x_update_required := 'Y';
    ELSIF
       NVL(l_ocon_rec.attribute2    ,fnd_api.g_miss_char)
         <> NVL(p_ocon_rec.attribute2    ,fnd_api.g_miss_char) THEN
       x_update_required := 'Y';
    ELSIF
       NVL(l_ocon_rec.attribute3    ,fnd_api.g_miss_char)
         <> NVL(p_ocon_rec.attribute2    ,fnd_api.g_miss_char) THEN
       x_update_required := 'Y';
    ELSIF
       NVL(l_ocon_rec.attribute4    ,fnd_api.g_miss_char)
         <> NVL(p_ocon_rec.attribute2    ,fnd_api.g_miss_char) THEN
       x_update_required := 'Y';
    ELSIF
       NVL(l_ocon_rec.attribute5    ,fnd_api.g_miss_char)
         <> NVL(p_ocon_rec.attribute2    ,fnd_api.g_miss_char) THEN
       x_update_required := 'Y';
    ELSIF
       NVL(l_ocon_rec.attribute6    ,fnd_api.g_miss_char)
         <> NVL(p_ocon_rec.attribute2    ,fnd_api.g_miss_char) THEN
       x_update_required := 'Y';
    ELSIF
       NVL(l_ocon_rec.attribute7    ,fnd_api.g_miss_char)
         <> NVL(p_ocon_rec.attribute2    ,fnd_api.g_miss_char) THEN
       x_update_required := 'Y';
    ELSIF
       NVL(l_ocon_rec.attribute8    ,fnd_api.g_miss_char)
         <> NVL(p_ocon_rec.attribute2    ,fnd_api.g_miss_char) THEN
       x_update_required := 'Y';
    ELSIF
       NVL(l_ocon_rec.attribute9    ,fnd_api.g_miss_char)
         <> NVL(p_ocon_rec.attribute2    ,fnd_api.g_miss_char) THEN
       x_update_required := 'Y';
    ELSIF
       NVL(l_ocon_rec.attribute10   ,fnd_api.g_miss_char)
         <> NVL(p_ocon_rec.attribute2    ,fnd_api.g_miss_char) THEN
       x_update_required := 'Y';
    ELSIF
       NVL(l_ocon_rec.attribute11   ,fnd_api.g_miss_char)
         <> NVL(p_ocon_rec.attribute2    ,fnd_api.g_miss_char) THEN
       x_update_required := 'Y';
    ELSIF
       NVL(l_ocon_rec.attribute12   ,fnd_api.g_miss_char)
         <> NVL(p_ocon_rec.attribute2    ,fnd_api.g_miss_char) THEN
       x_update_required := 'Y';
    ELSIF
       NVL(l_ocon_rec.attribute13   ,fnd_api.g_miss_char)
         <> NVL(p_ocon_rec.attribute2    ,fnd_api.g_miss_char) THEN
       x_update_required := 'Y';
    ELSIF
       NVL(l_ocon_rec.attribute14   ,fnd_api.g_miss_char)
         <> NVL(p_ocon_rec.attribute2    ,fnd_api.g_miss_char) THEN
       x_update_required := 'Y';
    ELSIF
       NVL(l_ocon_rec.attribute15   ,fnd_api.g_miss_char)
         <> NVL(p_ocon_rec.attribute2    ,fnd_api.g_miss_char) THEN
       x_update_required := 'Y';
    ELSIF
       NVL(l_ocon_rec.attribute16   ,fnd_api.g_miss_char)
         <> NVL(p_ocon_rec.attribute2    ,fnd_api.g_miss_char) THEN
       x_update_required := 'Y';
    ELSIF
       NVL(l_ocon_rec.attribute17   ,fnd_api.g_miss_char)
         <> NVL(p_ocon_rec.attribute2    ,fnd_api.g_miss_char) THEN
       x_update_required := 'Y';
    ELSIF
       NVL(l_ocon_rec.attribute18   ,fnd_api.g_miss_char)
         <> NVL(p_ocon_rec.attribute2    ,fnd_api.g_miss_char) THEN
       x_update_required := 'Y';
    ELSIF
       NVL(l_ocon_rec.attribute19   ,fnd_api.g_miss_char)
         <> NVL(p_ocon_rec.attribute2    ,fnd_api.g_miss_char) THEN
       x_update_required := 'Y';
    ELSIF
       NVL(l_ocon_rec.attribute20   ,fnd_api.g_miss_char)
         <> NVL(p_ocon_rec.attribute2    ,fnd_api.g_miss_char) THEN
       x_update_required := 'Y';
    END IF;
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN  NULL;
END;

PROCEDURE upd_ocon_update
(p_ocon_rec            IN hz_party_contact_v2pub.org_contact_rec_type)
IS
BEGIN
   UPDATE hz_org_contacts
      SET contact_number       = p_ocon_rec.contact_number,
          title                = p_ocon_rec.title,
          job_title            = p_ocon_rec.job_title,
          job_title_code       = p_ocon_rec.job_title_code,
          attribute_category   = p_ocon_rec.attribute_category,
          attribute1           = p_ocon_rec.attribute1,
          attribute2           = p_ocon_rec.attribute2,
          attribute3           = p_ocon_rec.attribute3,
          attribute4           = p_ocon_rec.attribute4,
          attribute5           = p_ocon_rec.attribute5,
          attribute6           = p_ocon_rec.attribute6,
          attribute7           = p_ocon_rec.attribute7,
          attribute8           = p_ocon_rec.attribute8,
          attribute9           = p_ocon_rec.attribute9,
          attribute10          = p_ocon_rec.attribute10,
          attribute11          = p_ocon_rec.attribute11,
          attribute12          = p_ocon_rec.attribute12,
          attribute13          = p_ocon_rec.attribute13,
          attribute14          = p_ocon_rec.attribute14,
          attribute15          = p_ocon_rec.attribute15,
          attribute16          = p_ocon_rec.attribute16,
          attribute17          = p_ocon_rec.attribute17,
          attribute18          = p_ocon_rec.attribute18,
          attribute19          = p_ocon_rec.attribute18,
          attribute20          = p_ocon_rec.attribute20,
          object_version_number= object_version_number + 1
    WHERE org_contact_id = p_ocon_rec.org_contact_id;
EXCEPTION
  WHEN NO_DATA_FOUND THEN NULL;
END;

--}

END arh_cont_pkg;

/
