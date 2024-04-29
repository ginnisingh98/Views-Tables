--------------------------------------------------------
--  DDL for Package Body IGS_OR_PHONES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_OR_PHONES_PKG" AS
/* $Header: IGSOI25B.pls 115.13 2003/05/06 09:31:26 ssawhney ship $ */
/******************************************************************
Change History

Who                          When                            What
npalanis       14-feb-2002                   Bug ID : 2225917 : SWCR008 Obsoleted   Get_Level  Procedure ,
                                              Check_Primary  . Removed  parameters
                                              Customer_Id ,Address_Id,Contact_Id, in Insert_row and Update Row Procedure ,
                                              Removed  Cust contact point API
ssawhney        9-may-2002        Bug 2338473 -- allow for more than one HZ error to appear, where ever direct calls to HZ APIs are present.

gmuralid        26-NOV-2002       BUG  2466674 --  V2API uptake
                                  Changed reference of HZ_CONTACT_POINT_PUB
                                  TO HZ_CONTACT_POINT_V2PUB for create
                                  and update of contact points
gmuralid        27-NOV-02         BUG 2676422 Commented created_by_module := IGS in update call
pkpatel         6-JAN-2003        Bug 2730137
                                  Removed the hard coding with g_gen
ssawhney        30-APR-2003	  OVN changes for V2API signature changes
***************************************************************** */
  g_parties     CONSTANT         VARCHAR2(15) := 'HZ_PARTIES';
  g_tlx         CONSTANT         VARCHAR2(10) := 'TLX';
  g_phone       CONSTANT         VARCHAR2(10) := 'PHONE';


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
Who     When       What
***************************************************************** */
  BEGIN
    FOR l_cnt IN 1..p_msg_cnt LOOP
      l_var := FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE);
      l_message := l_message||' '||l_var;
    END LOOP;

    RETURN (l_message);
  END get_error_msg;

  PROCEDURE Insert_Row(
                       X_Phone_Id                IN OUT NOCOPY NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Creation_Date                  DATE,
                       X_Created_By                     NUMBER,
                       X_Phone_Number                   VARCHAR2,
                       X_Status                         VARCHAR2,
                       X_Phone_Type                     VARCHAR2,
                       X_Last_Update_Login              NUMBER,
                       X_Country_code                   VARCHAR2,
                       X_Area_Code                      VARCHAR2,
                       X_Extension                      VARCHAR2,
                       X_Primary_Flag                   VARCHAR2,
                       X_Orig_System_Reference    IN OUT NOCOPY VARCHAR2,
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
                       x_party_id                       NUMBER,
                       x_party_site_id                  NUMBER,
                       x_msg_count                  OUT NOCOPY NUMBER,
                       x_msg_data                   OUT NOCOPY VARCHAR2,
                       x_return_status              OUT NOCOPY VARCHAR2,
		       x_contact_point_ovn          IN OUT NOCOPY NUMBER) AS
/******************************************************************

Created By:         Amit Gairola

Date Created By:    01-AUG-2001

Purpose:            This procedure Inserts the record for the Contact Phones

Known limitations,enhancements,remarks:

Change History

Who     When       What

***************************************************************** */
   email_rec                HZ_CONTACT_POINT_V2PUB.email_rec_type;
   edi_rec                  HZ_CONTACT_POINT_V2PUB.edi_rec_type;
   phone_rec                HZ_CONTACT_POINT_V2PUB.phone_rec_type;
   telex_rec                HZ_CONTACT_POINT_V2PUB.telex_rec_type;
   web_rec                  HZ_CONTACT_POINT_V2PUB.web_rec_type;
   cpoint_rec               HZ_CONTACT_POINT_V2PUB.contact_point_rec_type;
   x_owner_table            VARCHAR2(30);
   x_owner_table_id         NUMBER;

   tmp_var   VARCHAR2(2000);
   tmp_var1  VARCHAR2(2000);
  BEGIN

      x_owner_table := g_parties;
      x_owner_table_id := x_party_id;

-- Get the value for the x_phone_id from the Sequence
    SELECT hz_contact_points_s.NEXTVAL
    INTO   x_phone_id
    FROM   dual;

    IF (x_orig_system_reference IS NULL) THEN
      x_orig_system_reference := x_phone_id;
    END IF;

-- Assign values to the Contacts record based
-- on the inputs provided to the procedure
    cpoint_rec.contact_point_id       := x_phone_Id;
    cpoint_rec.contact_point_type     := X_Phone_Type;
    cpoint_rec.status                 := x_status;
    cpoint_rec.owner_table_name       := x_owner_table;
    cpoint_rec.owner_table_id         := x_owner_table_id;
    cpoint_rec.primary_flag           := x_primary_flag;
    cpoint_rec.orig_system_reference  := x_orig_system_reference;
    cpoint_rec.attribute_category     := x_attribute_category;
    cpoint_rec.attribute1             := x_attribute1;
    cpoint_rec.attribute2             := x_attribute2;
    cpoint_rec.attribute3             := x_attribute3;
    cpoint_rec.attribute4             := x_attribute4;
    cpoint_rec.attribute5             := x_attribute5;
    cpoint_rec.attribute6             := x_attribute6;
    cpoint_rec.attribute7             := x_attribute7;
    cpoint_rec.attribute8             := x_attribute8;
    cpoint_rec.attribute9             := x_attribute9;
    cpoint_rec.attribute10            := x_attribute10;
    cpoint_rec.attribute11            := x_attribute11;
    cpoint_rec.attribute12            := x_attribute12;
    cpoint_rec.attribute13            := x_attribute13;
    cpoint_rec.attribute14            := x_attribute14;
    cpoint_rec.attribute15            := x_attribute15;
    cpoint_rec.attribute16            := x_attribute16;
    cpoint_rec.attribute17            := x_attribute17;
    cpoint_rec.attribute18            := x_attribute18;
    cpoint_rec.attribute19            := x_attribute19;
    cpoint_rec.attribute20            := x_attribute20;
    cpoint_rec.created_by_module := 'IGS';
    cpoint_rec.content_source_type := 'USER_ENTERED';


    IF x_phone_type = g_tlx THEN
      telex_rec.telex_number       := x_phone_number;
    END IF;

    IF x_phone_type = g_tlx AND
      x_area_code IS NOT NULL THEN
      telex_rec.telex_number       := x_area_code ||'-'||x_phone_number;
    END IF;
    IF x_phone_type NOT IN ( g_tlx) THEN
      phone_rec.phone_line_type      := x_phone_type;
      cpoint_rec.contact_point_type  := g_phone;
      phone_rec.phone_number         := x_phone_number;
      phone_rec.phone_country_code   := x_country_code;
      phone_rec.phone_area_code      := x_area_code;
      phone_rec.phone_extension      := x_extension;
    END IF;

-- call the API for the creation of the Contact Points
           HZ_CONTACT_POINT_V2PUB.create_contact_point(
                                 p_init_msg_list         => FND_API.G_FALSE,
                                 p_contact_point_rec     => cpoint_rec,
                                 p_edi_rec               => edi_rec,
                                 p_email_rec              => email_rec,
                                 p_phone_rec              => phone_rec,
                                 p_telex_rec              => telex_rec,
                                 p_web_rec                => web_rec,
                                 x_return_status          => x_return_status,
                                 x_msg_count              => x_msg_count,
                                 x_msg_data               => x_msg_data,
                                 x_contact_point_id       => x_phone_id);


    IF x_return_status <> 'S' THEN
      -- ssawhney bug 2338473
      IF x_msg_count > 1 THEN
         FOR i IN 1..x_msg_count  LOOP
          tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
          tmp_var1 := tmp_var1 || ' '|| tmp_var;
         END LOOP;
	 x_msg_data := tmp_var1;
      END IF;
      RETURN;
    END IF;

    -- everything successful
    x_contact_point_ovn := 1;

  END insert_row;


  PROCEDURE Update_Row(
 		             X_phone_id			           NUMBER,
                       X_Last_Update_Date               IN OUT NOCOPY     DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Phone_Number                   VARCHAR2,
                       X_Status                         VARCHAR2,
                       X_Phone_Type                     VARCHAR2,
                       X_Last_Update_Login              NUMBER,
                       X_country_code                   VARCHAR2,
		             X_Area_Code                      VARCHAR2,
                       X_Extension                      VARCHAR2,
                       X_Primary_Flag                   VARCHAR2,
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
                       x_msg_count                  OUT NOCOPY NUMBER,
                       x_msg_data                   OUT NOCOPY VARCHAR2,
                       x_return_status              OUT NOCOPY VARCHAR2,
		       x_contact_point_ovn          IN OUT NOCOPY NUMBER) AS
/******************************************************************

Created By:         Amit Gairola

Date Created By:    01-AUG-2001

Purpose:            This procedure updates the Phones Record

Known limitations,enhancements,remarks:

Change History

Who     When       What

***************************************************************** */

   email_rec          HZ_CONTACT_POINT_V2PUB.email_rec_type;
   edi_rec            HZ_CONTACT_POINT_V2PUB.edi_rec_type;
   phone_rec          HZ_CONTACT_POINT_V2PUB.phone_rec_type;
   telex_rec          HZ_CONTACT_POINT_V2PUB.telex_rec_type;
   web_rec            HZ_CONTACT_POINT_V2PUB.web_rec_type;
   cpoint_rec         HZ_CONTACT_POINT_V2PUB.contact_point_rec_type;
   l_obj_ver          hz_contact_points.object_version_number%TYPE;

   tmp_var   VARCHAR2(2000);
   tmp_var1  VARCHAR2(2000);



  BEGIN
-- Assign the values from the input to the Contact Points record
    cpoint_rec.contact_point_id       := x_phone_Id;
    cpoint_rec.contact_point_type     := X_Phone_Type;
    cpoint_rec.status                 := x_status;
    cpoint_rec.primary_flag           := NVL(x_primary_flag,FND_API.G_MISS_CHAR);
    cpoint_rec.attribute_category     := NVL(x_attribute_category,FND_API.G_MISS_CHAR);
    cpoint_rec.attribute1             := NVL(x_attribute1,FND_API.G_MISS_CHAR);
    cpoint_rec.attribute2             := NVL(x_attribute2,FND_API.G_MISS_CHAR);
    cpoint_rec.attribute3             := NVL(x_attribute3,FND_API.G_MISS_CHAR);
    cpoint_rec.attribute4             := NVL(x_attribute4,FND_API.G_MISS_CHAR);
    cpoint_rec.attribute5             := NVL(x_attribute5,FND_API.G_MISS_CHAR);
    cpoint_rec.attribute6             := NVL(x_attribute6,FND_API.G_MISS_CHAR);
    cpoint_rec.attribute7             := NVL(x_attribute7,FND_API.G_MISS_CHAR);
    cpoint_rec.attribute8             := NVL(x_attribute8,FND_API.G_MISS_CHAR);
    cpoint_rec.attribute9             := NVL(x_attribute9,FND_API.G_MISS_CHAR);
    cpoint_rec.attribute10            := NVL(x_attribute10,FND_API.G_MISS_CHAR);
    cpoint_rec.attribute11            := NVL(x_attribute11,FND_API.G_MISS_CHAR);
    cpoint_rec.attribute12            := NVL(x_attribute12,FND_API.G_MISS_CHAR);
    cpoint_rec.attribute13            := NVL(x_attribute13,FND_API.G_MISS_CHAR);
    cpoint_rec.attribute14            := NVL(x_attribute14,FND_API.G_MISS_CHAR);
    cpoint_rec.attribute15            := NVL(x_attribute15,FND_API.G_MISS_CHAR);
    cpoint_rec.attribute16            := NVL(x_attribute16,FND_API.G_MISS_CHAR);
    cpoint_rec.attribute17            := NVL(x_attribute17,FND_API.G_MISS_CHAR);
    cpoint_rec.attribute18            := NVL(x_attribute18,FND_API.G_MISS_CHAR);
    cpoint_rec.attribute19            := NVL(x_attribute19,FND_API.G_MISS_CHAR);
    cpoint_rec.attribute20            := NVL(x_attribute20,FND_API.G_MISS_CHAR);
   -- cpoint_rec.created_by_module := 'IGS';
   --cpoint_rec.content_source_type := 'USER_ENTERED ';

    IF x_phone_type = g_tlx THEN
      telex_rec.telex_number       := x_phone_number;
    END IF;

    IF x_phone_type = g_tlx AND
      x_area_code IS NOT NULL THEN
      telex_rec.telex_number       := x_area_code ||'-'||x_phone_number;
    END IF;
    IF x_phone_type NOT IN ( g_tlx) THEN
      phone_rec.phone_line_type     := NVL(x_phone_type,FND_API.G_MISS_CHAR);
      cpoint_rec.contact_point_type := g_phone;
      phone_rec.phone_number        := NVL(x_phone_number,FND_API.G_MISS_CHAR);
      phone_rec.phone_country_code  := NVL(x_country_code,FND_API.G_MISS_CHAR);
      phone_rec.phone_area_code     := NVL(x_area_code,FND_API.G_MISS_CHAR);
      phone_rec.phone_extension     := NVL(x_extension,FND_API.G_MISS_CHAR);
    END IF;

-- Call the API for the updation of the Contact Points



                 HZ_CONTACT_POINT_V2PUB.update_contact_point(
                                           p_init_msg_list         => FND_API.G_FALSE,
                                           p_contact_point_rec     => cpoint_rec,
                                           p_edi_rec                => edi_rec,
                                           p_email_rec             => email_rec ,
                       			   p_phone_rec              => phone_rec,
                                           p_telex_rec              => telex_rec,
                                           p_web_rec                => web_rec,
                                           p_object_version_number => x_contact_point_ovn,
                                           x_return_status         => x_return_status,
                                           x_msg_count             => x_msg_count,
                                           x_msg_data              => x_msg_data
                                                                      );

    IF x_return_status <> 'S' THEN
      IF x_msg_count > 1 THEN
         FOR i IN 1..x_msg_count  LOOP
          tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
          tmp_var1 := tmp_var1 || ' '|| tmp_var;
         END LOOP;
	 x_msg_data := tmp_var1;
      END IF;
      RETURN;
    END IF;

  END update_row;


  PROCEDURE Delete_Row(X_phoneid   VARCHAR2) AS
  /******************************************************************

  Created By:         Amit Gairola

  Date Created By:    01-AUG-2001

  Purpose:            This procedure deletes the record for the Phone Id passed
                      as Input

  Known limitations,enhancements,remarks:

  Change History

  Who     When       What
  ssawhney           made this NULL. Can not delete from HZ table
***************************************************************** */
  BEGIN
    Null;
  END delete_row;

END igs_or_phones_pkg;

/
