--------------------------------------------------------
--  DDL for Package Body IGS_OR_CONTACTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_OR_CONTACTS_PKG" AS
/* $Header: IGSOI24B.pls 120.4 2006/05/30 09:10:52 vskumar ship $ */
/* Change History
|   who                  when                           what

|   npalanis           15-feb-2002      Bug ID - 2225917 : SWCR008   Removed  parameters
|                                             Customer_Id ,Address_Id,Contact_Id, in
|                                             Insert_row and  cust_acct_role_id is removed
|                                             from Update Row Procedure  .Org_contact_role_id is added
|                                             in both insert_row and update_row  .Procedure to create
|                                             org_contact_role is created .Cursor to get last_update_date
|                                             from hz_org_contact_roles table is written . Call To HZ_CUSTOMER_ACCOUTN.CREATE_ACCT_ROLES
|                                             is removed .Sequences HZ_CUST_ACCT_ROLES_S and HZ_CUST_CONTACT_POINTS are removed
|   pkpatel            03-APR-2002       Bug ID - 2283145 : Added the Code for Generating And Passing the party number
|   				              if the profile value is set to 'No' for generating the party number
|   ssawhney          7-may              Bug 2338473 -- allow for more than one HZ error to appear.
|   kpadiyar          15-May-2002        Bug 2373159 -- OSSIMP15: ERROR MESSAGE FOR DUPLICTED INSTITUTION CONTACT NOT INFORMATIVE.
|   kpadiyar          19-May-2002        Bug 2373159 -- Code changed to return the party number instead of the party id - Review comments.

    gmuralid          25-NOV-2002        BUG 2466674 -- V2 API UPTAKE CHANGED REFERENCE OF HZ_CONTACT_POINT_PUB TO
                                         HZ_CONTACT_POINT_V2PUB FOR BOTH CREATE AND UPDATE CONTACT POINTS THROUGHOUT
                                         THE PACKAGE BODY.
    | masehgal  26-Nov-2002  TCA_V2API_uptake  corrected as per V2
     ssawhney           30-apr-2003      V2API OVN changes
    pkpatel           4-Oct-2005         Bug 4654735 (Replaced the reference of HZ_PARTY_RELATIONSHIPS with HZ_RELATIONSHIPS)
*/

  g_email             CONSTANT VARCHAR2(10) := 'EMAIL';
  g_status            CONSTANT VARCHAR2(1)  := 'A';
  g_own_tab_name      CONSTANT VARCHAR2(10) := 'HZ_PARTIES';
  g_contact_of        CONSTANT VARCHAR2(15) := 'CONTACT_OF';
  g_contact           CONSTANT VARCHAR2(20) := 'CONTACT';

  FUNCTION get_error_msg(p_msg_cnt     IN NUMBER) RETURN VARCHAR2 AS
    l_count     NUMBER(3);
    l_cnt       NUMBER(3);
    l_message   VARCHAR2(2000);
    l_var       VARCHAR2(2000);
/******************************************************************

Created By:         Amit Gairola

Date Created By:    01-AUG-2001

Purpose:            This function returns the message from the message stack
                    and concatenates all the messages

Known limitations,enhancements,remarks:

Change History

Who       When          What
kpadiyar 15-May-2002   Added the message index parameter in the FND_MSG_PUB call
                       and the if condition logic to check the no of msgs in stack
		       and give the right output.
***************************************************************** */
  BEGIN
    IF p_msg_cnt = 1 THEN
       l_message := FND_MSG_PUB.Get(p_msg_index => p_msg_cnt , p_encoded => FND_API.G_FALSE);
    ELSE
    FOR l_cnt IN 1..p_msg_cnt LOOP
      l_var := FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE);
      l_message := l_message||' '||l_var;
    END LOOP;
    END IF;

    RETURN (l_message);
  END get_error_msg;

  PROCEDURE Insert_Row( x_last_name                    VARCHAR2 ,
                       x_orig_system_reference  IN OUT NOCOPY VARCHAR2 ,
                       x_status                        VARCHAR2 ,
                       x_contact_key                   VARCHAR2 ,
                       x_first_name                    VARCHAR2 ,
                       x_job_title                     VARCHAR2 ,
                       x_mail_stop                     VARCHAR2 ,
                       x_title                         VARCHAR2 ,
                       x_attribute_category            VARCHAR2 ,
                       x_attribute1                    VARCHAR2 ,
                       x_attribute2                    VARCHAR2 ,
                       x_attribute3                    VARCHAR2 ,
                       x_attribute4                    VARCHAR2 ,
                       x_attribute5                    VARCHAR2 ,
                       x_attribute6                    VARCHAR2 ,
                       x_attribute7                    VARCHAR2 ,
                       x_attribute8                    VARCHAR2 ,
                       x_attribute9                    VARCHAR2 ,
                       x_attribute10                   VARCHAR2 ,
                       x_attribute11                   VARCHAR2 ,
                       x_attribute12                   VARCHAR2 ,
                       x_attribute13                   VARCHAR2 ,
                       x_attribute14                   VARCHAR2 ,
                       x_attribute15                   VARCHAR2 ,
                       x_attribute16                   VARCHAR2 ,
                       x_attribute17                   VARCHAR2 ,
                       x_attribute18                   VARCHAR2 ,
                       x_attribute19                   VARCHAR2 ,
                       x_attribute20                   VARCHAR2 ,
                       x_attribute21                   VARCHAR2 ,
                       x_attribute22                   VARCHAR2 ,
                       x_attribute23                   VARCHAR2 ,
                       x_attribute24                   VARCHAR2 ,
                       x_attribute25                   VARCHAR2 ,
                       x_email_address                 VARCHAR2 ,
                       x_last_name_alt                 VARCHAR2 ,
                       x_first_name_alt                VARCHAR2 ,
                       x_contact_number         IN OUT NOCOPY VARCHAR2 ,
                       x_party_id                      NUMBER ,
                       x_party_site_id                 NUMBER ,
                       x_contact_party_id       IN OUT NOCOPY NUMBER ,
                       x_org_contact_id         IN OUT NOCOPY NUMBER ,
                       x_contact_point_id       IN OUT NOCOPY NUMBER ,
                       x_rel_party_id           IN OUT NOCOPY NUMBER ,
                       x_created_by                    NUMBER ,
                       x_creation_date                 DATE   ,
                       x_updated_by                    NUMBER ,
                       x_update_date                   DATE   ,
                       x_last_update_login             NUMBER ,
                       x_return_status             OUT NOCOPY VARCHAR2 ,
                       x_msg_count                 OUT NOCOPY NUMBER   ,
                       x_msg_data                  OUT NOCOPY VARCHAR2 ,
                       x_org_contact_role_id    IN OUT NOCOPY NUMBER,
		       P_ORG_ROLE_OVN             IN OUT NOCOPY NUMBER,
		       P_REL_OVN                  IN OUT NOCOPY NUMBER,
		       P_REL_PARTY_OVN            IN OUT NOCOPY NUMBER,
		       P_ORG_CONT_OVN             IN OUT NOCOPY NUMBER,
		       P_CONTACT_POINT_OVN        IN OUT NOCOPY NUMBER
                       ) AS
/******************************************************************

Created By:         Amit Gairola

Date Created By:    01-AUG-2001

Purpose:            This procedure creates the records in the Org Contacts
                    Creates the Customer Contact Points and the Cust Account
                    Roles

Known limitations,enhancements,remarks:

Change History

Who     When       What
ssawhney          bug 2338473. logic for more than one error modified.
kpadiyar 15-May-2002   Added the call to the local get_error_msg function to get the correct message
kpadiyar 19-May-2002   Added local function get_party_number to returnt the party_number instead of party_id.- Review comments
kumma    07-JUN-2002   Commented out NOCOPY the call to fnd_msg_pub.add as a call to igs_ge_msg_stact.add is also present
vskumar  24-May-2006   xbuild3 performace fix. changed first select statment related to table hz_relationships.
***************************************************************** */
--  masehgal    changed  to  hz_xxxx_V2PUB
    ocon_rec                    hz_party_contact_v2pub.org_contact_rec_type;
    cpoint_rec                  hz_contact_point_v2pub.contact_point_rec_type;
    email_rec                   hz_contact_point_v2pub.email_rec_type;
    l_party_rec                 hz_party_v2pub.party_rec_type;
    org_rel_rec                 hz_relationship_v2pub.relationship_rec_type;

    l_var                       VARCHAR2(1);
    l_party_number              hz_parties.party_number%TYPE;
    l_party_relationship_id     hz_relationships.relationship_id%TYPE;
    l_party_id                  hz_parties.party_id%TYPE;
    l_contact_point_id          NUMBER(10);

    tmp_var1                    VARCHAR2(2000);
    tmp_var                     VARCHAR2(2000);

    lv_party_number             hz_parties.party_number%TYPE;
    lv_contact_party_number     hz_parties.party_number%TYPE;

  -- Cursor for checking if the record exists in the
  -- IGS_OR_CONTACTS_V for the Org Party Id and the
  -- Contact Party Id
    CURSOR cur_or_cntcts(cp_org_party_id       NUMBER,
                         cp_contact_party_id   NUMBER) IS
     SELECT 1
     FROM hz_relationships rel
     WHERE object_id     = cp_org_party_id AND
	   subject_id  = cp_contact_party_id AND
	   REL.SUBJECT_TYPE = 'PERSON' AND
	   REL.SUBJECT_TABLE_NAME = 'HZ_PARTIES' AND
	   REL.OBJECT_TABLE_NAME = 'HZ_PARTIES' AND
	   REL.DIRECTIONAL_FLAG = 'F'     AND
	   REL.RELATIONSHIP_TYPE = 'CONTACT';


    FUNCTION get_party_number ( p_party_id number)
      RETURN VARCHAR2 IS
        CURSOR c_party IS
           SELECT party_number
           FROM   hz_parties
           WHERE  party_id = p_party_id;

        lv_party_number VARCHAR2(30);

     BEGIN
        OPEN   c_party;
        FETCH  c_party INTO lv_party_number;
        RETURN lv_party_number;
        CLOSE  c_party;
     END;

  BEGIN

  -- Open the cursor for checking if the
  -- record already exists
    OPEN cur_or_cntcts(x_party_id, x_contact_party_id);
    FETCH cur_or_cntcts INTO l_var;
    IF cur_or_cntcts%FOUND THEN
       -- If the record already exists, then the
       -- Error has to be returned to the form
       CLOSE cur_or_cntcts;
       x_return_status := 'E';

       /* To get the party number for the party id to pass to the message */
       lv_party_number := get_party_number(x_party_id);
       lv_contact_party_number := get_party_number(x_contact_party_id);

       FND_MESSAGE.Set_Name('IGS','IGS_OR_REC_EXISTS');
       FND_MESSAGE.Set_Token('ORG_PARTY_ID',lv_party_number);
       FND_MESSAGE.Set_Token('CONT_PARTY_ID',lv_contact_party_number);

       -- FND_MSG_PUB.Add;
       x_msg_count :=1;
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;

    END IF;
    CLOSE cur_or_cntcts;

    SELECT hz_contact_points_s.NEXTVAL
    INTO   l_contact_point_id
    FROM   DUAL;

-- Assign the values in the Contacts Record
    org_rel_rec.subject_id              := x_contact_party_id;
    org_rel_rec.object_id               := x_party_id;
    org_rel_rec.relationship_type       := g_contact;
    org_rel_rec.start_date              := TRUNC(SYSDATE);
    org_rel_rec.created_by_module       := 'IGS';
    org_rel_rec.STATUS                  := x_status;
    ocon_rec.contact_number             := x_contact_number;
    ocon_rec.title                      := x_title;
    ocon_rec.job_title                  := x_job_title;
    ocon_rec.party_site_id              := x_party_site_id;
    ocon_rec.orig_system_reference      := x_orig_system_reference;
    ocon_rec.created_by_module          := 'IGS';
    ocon_rec.attribute_category         := x_attribute_category;
    ocon_rec.attribute1                 := x_attribute1;
    ocon_rec.attribute2                 := x_attribute2;
    ocon_rec.attribute3                 := x_attribute3;
    ocon_rec.attribute4                 := x_attribute4;
    ocon_rec.attribute5                 := x_attribute5;
    ocon_rec.attribute6                 := x_attribute6;
    ocon_rec.attribute7                 := x_attribute7;
    ocon_rec.attribute8                 := x_attribute8;
    ocon_rec.attribute9                 := x_attribute9;
    ocon_rec.attribute10                := x_attribute10;
    ocon_rec.attribute11                := x_attribute11;
    ocon_rec.attribute12                := x_attribute12;
    ocon_rec.attribute13                := x_attribute13;
    ocon_rec.attribute14                := x_attribute14;
    ocon_rec.attribute15                := x_attribute15;
    ocon_rec.attribute16                := x_attribute16;
    ocon_rec.attribute17                := x_attribute17;
    ocon_rec.attribute18                := x_attribute18;
    ocon_rec.attribute19                := x_attribute19;
    ocon_rec.attribute20                := x_attribute20;
    org_rel_rec.subject_type            := 'PERSON';
    org_rel_rec.subject_table_name      := 'HZ_PARTIES';
    org_rel_rec.object_type             := 'ORGANIZATION';
    org_rel_rec.object_table_name       := 'HZ_PARTIES';
    org_rel_rec.relationship_code       := g_contact_of;

    -- Generating And Passing the party number if the profile value is set to 'No' for generating the party number
    IF FND_PROFILE.VALUE('HZ_GENERATE_PARTY_NUMBER') = 'N' THEN
       SELECT hz_party_number_s.NEXTVAL
       INTO   l_party_rec.party_number
       FROM   dual;

       org_rel_rec.party_rec.party_number  := l_party_rec.party_number;

    END IF;
    ocon_rec.party_rel_rec := org_rel_rec;

--  masehgal   changed Call to V2PUB for the Creation of the Org Contacts
    hz_party_contact_v2pub.create_org_contact(
                                    p_init_msg_list    => 'T',
                                    p_org_contact_rec  => ocon_rec,
                                    x_return_status    => x_return_status,
                                    x_msg_count        => x_msg_count,
                                    x_msg_data         => x_msg_data,
                                    x_org_contact_id   => x_org_contact_id,
                                    x_party_rel_id     => l_party_relationship_id,
                                    x_party_id         => l_party_id,
                                    x_party_number     => l_party_number
                                    );

-- If the return status is not 'S' from the API Call
-- then exit from the procedure
    IF x_return_status <> 'S' THEN
    -- bug 2338473 logic to display more than one error modified.

       IF x_msg_count > 1 THEN
          FOR i IN 1..x_msg_count  LOOP
              tmp_var  := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
              tmp_var1 := tmp_var1 || ' '|| tmp_var;
          END LOOP;
          x_msg_data := tmp_var1;
       END IF;
       RETURN;

    END IF;

-- If the return status is 'S' i.e. not in 'E' or 'U'
    IF x_return_status NOT IN ('E','U') THEN

-- Assign the values to the Contact Points Record
      x_rel_party_id                 :=  l_party_id;
      cpoint_rec.contact_point_id    := l_contact_point_id;
      cpoint_rec.contact_point_type  := g_email;
      cpoint_rec.status              := g_status;
      cpoint_rec.owner_table_name    := g_own_tab_name;
      cpoint_rec.owner_table_id      :=  l_party_id;
      cpoint_rec.primary_flag        := 'Y';
      cpoint_rec.created_by_module   := 'IGS';
      cpoint_rec.content_source_type := 'USER_ENTERED';
      email_rec.email_address        := x_email_address;

-- If the Email Address is provided, then create the Contact Point
      IF x_email_address IS NOT NULL THEN
                       hz_contact_point_v2pub.create_contact_point(
                                  p_init_msg_list           => FND_API.G_FALSE,
                                  p_contact_point_rec       => cpoint_rec ,
                                  p_edi_rec                 => NULL,
                                  p_email_rec               => email_rec,
                                  p_phone_rec               => NULL,
                                  p_telex_rec               => NULL,
                                  p_web_rec                 => NULL,
                                  x_contact_point_id        => x_contact_point_id,
                                  x_return_status           => x_return_status ,
                                  x_msg_count               => x_msg_count,
                                  x_msg_data                => x_msg_data );

        IF x_return_status <> 'S' THEN
	-- 2338473.
          IF x_msg_count > 1 THEN
	        -- initialise the variables again
		       tmp_var  := NULL;
		       tmp_var1 := NULL;

		       FOR i IN 1..x_msg_count  LOOP
			        tmp_var  := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
			        tmp_var1 := tmp_var1 || ' '|| tmp_var;
		       END LOOP;
		       x_msg_data := tmp_var1;
	       END IF;
          RETURN;
        END IF;
      END IF;
    END IF;

    -- All inserts are successful.

    P_REL_OVN         :=1;
    P_REL_PARTY_OVN   :=1;
    P_ORG_CONT_OVN    :=1;
    P_CONTACT_POINT_OVN  :=1;

  END insert_row;

  PROCEDURE Update_Row(x_Last_Name                               VARCHAR2,
                       x_Last_Updated_By                         NUMBER,
                       x_Last_Update_Date               IN OUT NOCOPY   DATE,
                       x_party_Last_Update_Date         IN OUT NOCOPY   DATE,
                       x_org_cont_Last_Update_Date      IN OUT NOCOPY   DATE,
                       x_cont_point_Last_Update_Date    IN OUT NOCOPY   DATE,
                       x_prel_Last_Update_Date          IN OUT NOCOPY   DATE,
                       x_rel_party_Last_Update_Date     IN OUT NOCOPY   DATE,
                       x_Status                                  VARCHAR2,
                       x_Contact_Key                             VARCHAR2,
                       x_First_Name                              VARCHAR2,
                       x_Job_Title                               VARCHAR2,
                       x_Last_Update_Login                       NUMBER,
                       x_Mail_Stop                               VARCHAR2,
                       x_Title                                   VARCHAR2,
                       x_Attribute_Category                      VARCHAR2,
                       x_Attribute1                              VARCHAR2,
                       x_Attribute2                              VARCHAR2,
                       x_Attribute3                              VARCHAR2,
                       x_Attribute4                              VARCHAR2,
                       x_Attribute5                              VARCHAR2,
                       x_Attribute6                              VARCHAR2,
                       x_Attribute7                              VARCHAR2,
                       x_Attribute8                              VARCHAR2,
                       x_Attribute9                              VARCHAR2,
                       x_Attribute10                             VARCHAR2,
                       x_Attribute11                             VARCHAR2,
                       x_Attribute12                             VARCHAR2,
                       x_Attribute13                             VARCHAR2,
                       x_Attribute14                             VARCHAR2,
                       x_Attribute15                             VARCHAR2,
                       x_Attribute16                             VARCHAR2,
                       x_Attribute17                             VARCHAR2,
                       x_Attribute18                             VARCHAR2,
                       x_Attribute19                             VARCHAR2,
                       x_Attribute20                             VARCHAR2,
                       x_Attribute21                             VARCHAR2,
                       x_Attribute22                             VARCHAR2,
                       x_Attribute23                             VARCHAR2,
                       x_Attribute24                             VARCHAR2,
                       x_Attribute25                             VARCHAR2,
                       x_Email_Address                           VARCHAR2,
                       x_Last_Name_Alt                           VARCHAR2 ,
                       x_First_Name_Alt                          VARCHAR2 ,
                       x_contact_number                          VARCHAR2,
                       x_party_id                                NUMBER,
                       x_party_site_id                           NUMBER,
                       x_contact_party_id                        NUMBER,
                       x_org_contact_id                          NUMBER,
                       x_contact_point_id               IN OUT NOCOPY   NUMBER,
                       x_party_relationship_id                   NUMBER,
                       x_return_status                     OUT NOCOPY   VARCHAR2,
                       x_msg_count                         OUT NOCOPY   NUMBER,
                       x_msg_data                          OUT NOCOPY   VARCHAR2,
                       x_rel_party_id                            NUMBER ,
                       x_org_contact_role_id            IN OUT NOCOPY   NUMBER,
		       P_ORG_ROLE_OVN                   IN OUT NOCOPY NUMBER,
		       P_REL_OVN                        IN OUT NOCOPY NUMBER,
		       P_REL_PARTY_OVN                  IN OUT NOCOPY NUMBER,
		       P_ORG_CONT_OVN                   IN OUT NOCOPY NUMBER,
		       P_CONTACT_POINT_OVN              IN OUT NOCOPY NUMBER
                      ) AS
/******************************************************************

Created By:         Amit Gairola

Date Created By:    01-AUG-2001

Purpose:            This procedure Updates the records in the Org Contacts
                    Updates the Customer Contact Points

Known limitations,enhancements,remarks:

Change History

Who     When       What
ssawhney           2338473 -- to display all message if mroe than one error
***************************************************************** */
    ocon_rec            hz_party_contact_v2pub.org_contact_rec_type;
    cpoint_rec          hz_contact_point_v2pub.contact_point_rec_type;
    email_rec           hz_contact_point_v2pub.email_rec_type;
    org_rel_rec         hz_relationship_v2pub.relationship_rec_type;
    l_party_id          hz_parties.party_id%TYPE;
    l_last_update_date  DATE;
    l_contact_point_id  NUMBER(20);
    tmp_var1            VARCHAR2(2000);
    tmp_var             VARCHAR2(2000);

-- Cursor for the email address from the HZ_CONTACT_POINTS
    CURSOR cur_hz_contact_pts(cp_contact_point_id    NUMBER) IS
      SELECT email_address
      FROM   hz_contact_points
      WHERE  contact_point_id     = cp_contact_point_id;

 l_obj_ver                    hz_contact_points.object_version_number%TYPE;
 l_org_contacts_obj_ver_num   hz_org_contacts.object_version_number%TYPE;
 l_rel_obj_ver_num             hz_org_contacts.object_version_number%TYPE;
 l_hz_parties_obj_ver_num  hz_org_contacts.object_version_number%TYPE;

  BEGIN

-- Assign the values to the Org Contact Record
    ocon_rec.org_contact_id           := x_org_contact_id;
    ocon_rec.contact_number           := NVL(x_contact_number,FND_API.G_MISS_CHAR);
    ocon_rec.title                    := NVL(x_title,FND_API.G_MISS_CHAR);
    ocon_rec.job_title                := NVL(x_job_title,FND_API.G_MISS_CHAR);
    ocon_rec.attribute_category       := NVL(x_Attribute_Category,FND_API.G_MISS_CHAR);
    ocon_rec.attribute1               := NVL(x_Attribute1,FND_API.G_MISS_CHAR);
    ocon_rec.attribute2               := NVL(x_Attribute2,FND_API.G_MISS_CHAR);
    ocon_rec.attribute3               := NVL(x_Attribute3,FND_API.G_MISS_CHAR);
    ocon_rec.attribute4               := NVL(x_Attribute4,FND_API.G_MISS_CHAR);
    ocon_rec.attribute5               := NVL(x_Attribute5,FND_API.G_MISS_CHAR);
    ocon_rec.attribute6               := NVL(x_Attribute6,FND_API.G_MISS_CHAR);
    ocon_rec.attribute7               := NVL(x_Attribute7,FND_API.G_MISS_CHAR);
    ocon_rec.attribute8               := NVL(x_attribute8,FND_API.G_MISS_CHAR);
    ocon_rec.attribute9               := NVL(x_Attribute9,FND_API.G_MISS_CHAR);
    ocon_rec.attribute10              := NVL(x_Attribute10,FND_API.G_MISS_CHAR);
    ocon_rec.attribute11              := NVL(x_Attribute11,FND_API.G_MISS_CHAR);
    ocon_rec.attribute12              := NVL(x_Attribute12,FND_API.G_MISS_CHAR);
    ocon_rec.attribute13              := NVL(x_Attribute13,FND_API.G_MISS_CHAR);
    ocon_rec.attribute14              := NVL(x_Attribute14,FND_API.G_MISS_CHAR);
    ocon_rec.attribute15              := NVL(x_Attribute15,FND_API.G_MISS_CHAR);
    ocon_rec.attribute16              := NVL(x_Attribute16,FND_API.G_MISS_CHAR);
    ocon_rec.attribute17              := NVL(x_Attribute17,FND_API.G_MISS_CHAR);
    ocon_rec.attribute18              := NVL(x_Attribute18,FND_API.G_MISS_CHAR);
    ocon_rec.attribute19              := NVL(x_Attribute19,FND_API.G_MISS_CHAR);
    ocon_rec.attribute20              := NVL(x_Attribute20,FND_API.G_MISS_CHAR);

    org_rel_rec.subject_type          := 'PERSON';
    org_rel_rec.subject_table_name    := 'HZ_PARTIES';
    org_rel_rec.object_type           := 'ORGANIZATION';
    org_rel_rec.object_table_name     := 'HZ_PARTIES';
    org_rel_rec.status                :=  x_Status;
    org_rel_rec.relationship_code     := g_contact_of;
    org_rel_rec.relationship_id       := x_party_relationship_id;

    ocon_rec.party_rel_rec := org_rel_rec;

--    IF x_last_update_date IS NULL THEN

--    END IF;
-- Assign the values to the Contact Points Record
    cpoint_rec.contact_point_id       := x_contact_point_Id;
    cpoint_rec.status                 := NVL(x_status,'I');

-- Assign the value to the Email Record
-- email_rec.email_address           := NVL(X_Email_Address,FND_API.G_MISS_CHAR);

-- Fetch the Org Contact Last Update Date
l_org_contacts_obj_ver_num := P_ORG_CONT_OVN;
l_hz_parties_obj_ver_num   := P_REL_PARTY_OVN;
l_rel_obj_ver_num          := P_REL_OVN;

-- Call the API for the updation of the Org Contact Record
    hz_party_contact_v2pub.update_org_contact(
                                    p_init_msg_list                 => 'T',
                                    p_org_contact_rec               => ocon_rec,
                                    p_cont_object_version_number    => l_org_contacts_obj_ver_num,
                                    p_rel_object_version_number     => l_rel_obj_ver_num,
                                    p_party_object_version_number   => l_hz_parties_obj_ver_num,
                                    x_return_status                 => x_return_status,
                                    x_msg_count                     => x_msg_count,
                                    x_msg_data                      => x_msg_data);

-- If the API returns Error,
-- then exit the procedure
     IF x_return_status <> 'S' THEN
       IF x_msg_count > 1 THEN
	        -- initialise the variables again
		tmp_var := NULL;
		tmp_var1 := NULL;

		FOR i IN 1..x_msg_count  LOOP
			tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
			tmp_var1 := tmp_var1 || ' '|| tmp_var;
		END LOOP;
		x_msg_data := tmp_var1;
	END IF;
        RETURN;
     END IF;

   -- Assign the values to the Contact Points Record
    cpoint_rec.contact_point_id    := x_contact_point_id;
    cpoint_rec.contact_point_type  := g_email;
    cpoint_rec.status              := 'A';
    cpoint_rec.owner_table_name    := g_own_tab_name;
    cpoint_rec.owner_table_id      := x_rel_party_id;

-- If the Contact Point Id is not present, then
-- Create the Contact Point if the Email Address is NOT NULL
-- else update the Contact Point


    IF x_contact_point_id IS NOT NULL THEN

       IF x_email_address IS NOT NULL THEN
         cpoint_rec.primary_flag := 'Y';
         email_rec.email_address := x_email_address;
       ELSE

         cpoint_rec.primary_flag := 'N';
         email_rec.email_address := FND_API.G_MISS_CHAR;
       END IF;

      l_obj_ver := P_CONTACT_POINT_OVN;


       HZ_CONTACT_POINT_V2PUB.update_contact_point(
                                    p_init_msg_list         => FND_API.G_FALSE,
                                    p_contact_point_rec     => cpoint_rec,
                                    p_edi_rec               => NULL,
                                    p_email_rec             => email_rec,
                                    p_phone_rec             => NULL,
                                    p_telex_rec             => NULL,
                                    p_web_rec               => NULL,
               				p_object_version_number => l_obj_ver,
                                    x_return_status         => x_return_status,
                                    x_msg_count             => x_msg_count,
                                    x_msg_data              => x_msg_data
                                                           );

    ELSE

      IF x_email_address IS NOT NULL THEN
        cpoint_rec.primary_flag := 'Y';
        email_rec.email_address := x_email_address;

        SELECT hz_contact_points_s.NEXTVAL
        INTO  cpoint_rec.contact_point_id
        FROM   dual;

       cpoint_rec.created_by_module    := 'IGS' ;
       cpoint_rec.content_source_type  := 'USER_ENTERED';

           hz_contact_point_v2pub.create_contact_point(
                      p_init_msg_list           => FND_API.G_FALSE,
                      p_contact_point_rec       => cpoint_rec ,
                      p_edi_rec                 => NULL,
                      p_email_rec               => email_rec,
                      p_phone_rec               => NULL,
                      p_telex_rec               => NULL,
                      p_web_rec                 => NULL,
                      x_contact_point_id        => l_contact_point_id,
                      x_return_status           => x_return_status ,
                      x_msg_count               => x_msg_count,
                      x_msg_data                => x_msg_data );

      END IF;
   END IF;

    IF x_return_status <> 'S' THEN
      IF x_msg_count > 1 THEN
	        -- initialise the variables again
		tmp_var  := NULL;
		tmp_var1 := NULL;

		FOR i IN 1..x_msg_count  LOOP
			tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
			tmp_var1 := tmp_var1 || ' '|| tmp_var;
		END LOOP;
		x_msg_data := tmp_var1;
      END IF;
      RETURN;
    END IF;

    -- every thing successful then
    P_CONTACT_POINT_OVN := l_obj_ver ;
    P_ORG_CONT_OVN := l_org_contacts_obj_ver_num;
    P_REL_PARTY_OVN := l_hz_parties_obj_ver_num;
    P_REL_OVN := l_rel_obj_ver_num  ;
  END update_row;

END igs_or_contacts_pkg;

/
