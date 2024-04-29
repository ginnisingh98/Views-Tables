--------------------------------------------------------
--  DDL for Package Body IGS_PE_CONTACT_POINT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_CONTACT_POINT_PKG" AS
/* $Header: IGSNI78B.pls 115.12 2003/05/05 14:56:42 kpadiyar ship $ */

PROCEDURE HZ_CONTACT_POINTS_AKE(
           p_action		        IN VARCHAR2,
 		 p_rowid 		IN OUT NOCOPY VARCHAR2,
   		 p_status		IN VARCHAR2,
  		 p_owner_table_name	IN VARCHAR2,
  		 p_owner_table_id	IN NUMBER,
  		 P_primary_flag	        IN VARCHAR2,
  		 p_email_format	        IN VARCHAR2,
   		 p_email_address	IN VARCHAR2,
		 p_return_status        OUT NOCOPY VARCHAR2,
                 p_msg_data             OUT NOCOPY VARCHAR2,
                 p_last_update_date     IN OUT NOCOPY DATE ,
                 p_contact_point_id     IN OUT NOCOPY NUMBER,
                 p_contact_point_ovn    IN OUT NOCOPY NUMBER,
                 p_attribute_category   IN VARCHAR2,
                 p_attribute1           IN VARCHAR2,
   		 p_attribute2           IN VARCHAR2,
   		 p_attribute3           IN VARCHAR2,
  		 p_attribute4           IN VARCHAR2,
   		 p_attribute5           IN VARCHAR2,
   		 p_attribute6           IN VARCHAR2,
   		 p_attribute7           IN VARCHAR2,
   		 p_attribute8           IN VARCHAR2,
   		 p_attribute9           IN VARCHAR2,
  		 p_attribute10 	    IN VARCHAR2,
   		 p_attribute11 	    IN VARCHAR2,
   		 p_attribute12 	    IN VARCHAR2,
   		 p_attribute13 	    IN VARCHAR2,
   		 p_attribute14 	    IN VARCHAR2,
   		 p_attribute15 	    IN VARCHAR2,
   		 p_attribute16 	    IN VARCHAR2,
   		 p_attribute17          IN VARCHAR2,
   		 p_attribute18 	    IN VARCHAR2,
   		 p_attribute19 	    IN VARCHAR2,
   		 p_attribute20 	    IN VARCHAR2

) AS
  /*************************************************************
  Created By : kumaravel
  Date Created By : Sep 15 2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

 		p_api_version 		      NUMBER(15)   := 1.0;
 		p_init_msg_list		 VARCHAR2(30) :=  FND_API.G_FALSE;
 		p_commit 		           VARCHAR2(30) := FND_API.G_FALSE;
 		l_msg_count 		      NUMBER(15);
          l_contact_point_rec	      HZ_CONTACT_POINT_V2PUB.contact_point_rec_type;
          l_email_rec		      HZ_CONTACT_POINT_V2PUB.email_rec_type;
		l_last_update_date        hz_contact_points.last_update_date%TYPE;
	     l_obj_ver                 hz_contact_points.object_version_number%TYPE;

           tmp_var1          VARCHAR2(2000);
           tmp_var           VARCHAR2(2000);

            CURSOR  get_lupd_date(p_contact_point_id NUMBER ) IS
            SELECT  last_update_date
            FROM    hz_contact_points
            WHERE   contact_point_id = p_contact_point_id;


 BEGIN
     IF p_action = 'INSERT' THEN
                           l_CONTACT_POINT_REC.CONTACT_POINT_ID	        := p_contact_point_id;
                           l_CONTACT_POINT_REC.CONTACT_POINT_TYPE	:= 'EMAIL';
                           l_CONTACT_POINT_REC.STATUS		        := p_status;
                           l_CONTACT_POINT_REC.OWNER_TABLE_NAME	        := p_owner_table_name;
                           l_CONTACT_POINT_REC.OWNER_TABLE_ID	        := p_owner_table_id;
                           l_CONTACT_POINT_REC.PRIMARY_FLAG	        := p_primary_flag;
                           l_CONTACT_POINT_REC.CONTENT_SOURCE_TYPE	:= 'USER_ENTERED';
                           l_CONTACT_POINT_REC.attribute_category       := p_attribute_category  ;
                           l_CONTACT_POINT_REC.attribute1               := p_attribute1;
                           l_CONTACT_POINT_REC.attribute2	 	:= p_attribute2;
                           l_CONTACT_POINT_REC.attribute3		:= p_attribute3;
                           l_CONTACT_POINT_REC.attribute4	 	:= p_attribute4 ;
                           l_CONTACT_POINT_REC.attribute5		:= p_attribute5;
                           l_CONTACT_POINT_REC.attribute6	 	:= p_attribute6;
                           l_CONTACT_POINT_REC.attribute7	 	:= p_attribute7;
                           l_CONTACT_POINT_REC.attribute8	 	:= p_attribute8;
                           l_CONTACT_POINT_REC.attribute9		:= p_attribute9 ;
                       	   l_CONTACT_POINT_REC.attribute10		:= p_attribute10 ;
                           l_CONTACT_POINT_REC.attribute11	 	:= p_attribute11;
                           l_CONTACT_POINT_REC.attribute12	 	:= p_attribute12;
                           l_CONTACT_POINT_REC.attribute13		:= p_attribute13 ;
                           l_CONTACT_POINT_REC.attribute14	 	:= p_attribute14;
                           l_CONTACT_POINT_REC.attribute15	 	:= p_attribute15;
                           l_CONTACT_POINT_REC.attribute16	 	:= p_attribute16;
                           l_CONTACT_POINT_REC.attribute17	 	:= p_attribute17;
                           l_CONTACT_POINT_REC.attribute18		:= p_attribute18;
                           l_CONTACT_POINT_REC.attribute19  	     := p_attribute19;
                           l_CONTACT_POINT_REC.attribute20	 	:= p_attribute20;
                           l_CONTACT_POINT_REC.created_by_module   := 'IGS';

                            l_EMAIL_REC.EMAIL_FORMAT	     :=      p_email_format;
                           l_EMAIL_REC.EMAIL_ADDRESS	:=      p_email_address;


                  HZ_CONTACT_POINT_V2PUB.create_contact_point(
                             p_init_msg_list           => p_init_msg_list ,
                             p_contact_point_rec       => l_contact_point_rec ,
                             p_email_rec               => l_EMAIL_REC,
                             x_contact_point_id        => p_contact_point_id,
                             x_return_status           => p_return_status ,
                             x_msg_count               => l_msg_count,
                             x_msg_data                => p_msg_data);

        IF p_return_status = 'S' THEN
            p_contact_point_ovn := 1;
        ELSIF p_return_status <> 'S' THEN
           -- bug 2338473 logic to display more than one error modified.
          IF l_msg_count > 1 THEN
            FOR i IN 1..l_msg_count  LOOP
              tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
              tmp_var1 := tmp_var1 || ' '|| tmp_var;
            END LOOP;
          p_msg_data := tmp_var1;
          END IF;
          RETURN;
       END IF;

 ELSIF p_action = 'UPDATE' THEN


                  l_CONTACT_POINT_REC.CONTACT_POINT_ID	     :=  p_contact_point_id;
                  l_CONTACT_POINT_REC.CONTACT_POINT_TYPE	:=  'EMAIL';
                  l_CONTACT_POINT_REC.STATUS		          :=  p_status;
                  l_CONTACT_POINT_REC.OWNER_TABLE_NAME	     :=  p_owner_table_name;
                  l_CONTACT_POINT_REC.OWNER_TABLE_ID	     :=  p_owner_table_id;
                  l_CONTACT_POINT_REC.PRIMARY_FLAG	     :=  NVL(p_primary_flag,FND_API.G_MISS_CHAR);
               --   l_CONTACT_POINT_REC.CONTENT_SOURCE_TYPE	:=  'USER_ENTERED';
                  l_CONTACT_POINT_REC.attribute_category    :=  NVL(p_attribute_category,FND_API.G_MISS_CHAR);
                   l_CONTACT_POINT_REC.attribute1          := NVL(p_attribute1,FND_API.G_MISS_CHAR);
                  l_CONTACT_POINT_REC.attribute2	 	:= NVL(p_attribute2,FND_API.G_MISS_CHAR);
                  l_CONTACT_POINT_REC.attribute3		:= NVL(p_attribute3,FND_API.G_MISS_CHAR);
                  l_CONTACT_POINT_REC.attribute4	 	:= NVL(p_attribute4,FND_API.G_MISS_CHAR);
                  l_CONTACT_POINT_REC.attribute5		:= NVL(p_attribute5,FND_API.G_MISS_CHAR);
                  l_CONTACT_POINT_REC.attribute6	 	:= NVL(p_attribute6,FND_API.G_MISS_CHAR);
                  l_CONTACT_POINT_REC.attribute7	 	:= NVL(p_attribute7,FND_API.G_MISS_CHAR);
                  l_CONTACT_POINT_REC.attribute8	 	:= NVL(p_attribute8,FND_API.G_MISS_CHAR);
                  l_CONTACT_POINT_REC.attribute9		:= NVL(p_attribute9,FND_API.G_MISS_CHAR);
                  l_CONTACT_POINT_REC.attribute10		:= NVL(p_attribute10,FND_API.G_MISS_CHAR);
                  l_CONTACT_POINT_REC.attribute11	 	:= NVL(p_attribute11,FND_API.G_MISS_CHAR);
                  l_CONTACT_POINT_REC.attribute12	 	:= NVL(p_attribute12,FND_API.G_MISS_CHAR);
                  l_CONTACT_POINT_REC.attribute13		:= NVL(p_attribute13,FND_API.G_MISS_CHAR);
                  l_CONTACT_POINT_REC.attribute14	 	:= NVL(p_attribute14,FND_API.G_MISS_CHAR);
                  l_CONTACT_POINT_REC.attribute15	 	:= NVL(p_attribute15,FND_API.G_MISS_CHAR);
                  l_CONTACT_POINT_REC.attribute16	 	:= NVL(p_attribute16,FND_API.G_MISS_CHAR);
                  l_CONTACT_POINT_REC.attribute17	 	:= NVL(p_attribute17,FND_API.G_MISS_CHAR);
                  l_CONTACT_POINT_REC.attribute18		:= NVL(p_attribute18,FND_API.G_MISS_CHAR);
                  l_CONTACT_POINT_REC.attribute19      := NVL(p_attribute19,FND_API.G_MISS_CHAR);
                  l_CONTACT_POINT_REC.attribute20	 	:= NVL(p_attribute20,FND_API.G_MISS_CHAR);
               --   l_CONTACT_POINT_REC.created_by_module   := 'IGS';

                  l_EMAIL_REC.EMAIL_FORMAT   :=      NVL(p_email_format,FND_API.G_MISS_CHAR);
                  l_EMAIL_REC.EMAIL_ADDRESS	:=      NVL(p_email_address,FND_API.G_MISS_CHAR);

          HZ_CONTACT_POINT_V2PUB.update_contact_point(
                              p_init_msg_list         => p_init_msg_list ,
                              p_contact_point_rec     => l_contact_point_rec ,
                              p_email_rec             => l_EMAIL_REC ,
                              p_object_version_number => p_contact_point_ovn,
                              x_return_status         => p_return_status,
                              x_msg_count             => l_msg_count ,
                              x_msg_data              => p_msg_data

                                                     );



	IF p_return_status <> 'S' THEN
           -- bug 2338473 logic to display more than one error modified.
          IF l_msg_count > 1 THEN
            FOR i IN 1..l_msg_count  LOOP
              tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
              tmp_var1 := tmp_var1 || ' '|| tmp_var;
            END LOOP;
          p_msg_data := tmp_var1;
          END IF;
          RETURN;
       END IF;

END IF;

END HZ_CONTACT_POINTS_AKE;

PROCEDURE HZ_CONTACT_POINTS_AKP(
           p_action		        IN VARCHAR2,
 		 p_rowid 		IN OUT NOCOPY VARCHAR2,
   		 p_status		IN VARCHAR2,
  		 p_owner_table_name	IN VARCHAR2,
  		 p_owner_table_id	IN NUMBER,
  		 P_primary_flag		IN VARCHAR2,
   		 p_phone_country_code   IN VARCHAR2,
 		 p_phone_area_code      IN VARCHAR2,
                 p_phone_number         IN VARCHAR2,
                 p_phone_extension      IN VARCHAR2,
                 p_phone_line_type      IN  VARCHAR2,
		 p_return_status   	OUT NOCOPY VARCHAR2,
   	 	 p_msg_data             OUT NOCOPY VARCHAR2,
 		 p_last_update_date	IN OUT NOCOPY DATE,
        	 p_contact_point_id     IN OUT NOCOPY NUMBER,
                 p_contact_point_ovn    IN OUT NOCOPY NUMBER,
        	 p_attribute_category   IN VARCHAR2,
        	 p_attribute1       	IN VARCHAR2,
   		 p_attribute2       	IN VARCHAR2,
   		 p_attribute3       	IN VARCHAR2,
  		 p_attribute4       	IN VARCHAR2,
   		 p_attribute5       	IN VARCHAR2,
   		 p_attribute6       	IN VARCHAR2,
   		 p_attribute7       	IN VARCHAR2,
   		 p_attribute8       	IN VARCHAR2,
   		 p_attribute9       	IN VARCHAR2,
   		 p_attribute10 		IN VARCHAR2,
   		 p_attribute11 		IN VARCHAR2,
   		 p_attribute12 		IN VARCHAR2,
   		 p_attribute13 		IN VARCHAR2,
   		 p_attribute14 		IN VARCHAR2,
   		 p_attribute15 		IN VARCHAR2,
   		 p_attribute16 		IN VARCHAR2,
   		 p_attribute17 		IN VARCHAR2,
   		 p_attribute18 		IN VARCHAR2,
   		 p_attribute19 		IN VARCHAR2,
   		 p_attribute20 		IN VARCHAR2
) AS
  /*************************************************************
  Created By : Kumaravel
  Date Created By : Sep 15 2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

 		p_api_version 		NUMBER(15)   := 1.0;
 		p_init_msg_list	VARCHAR2(30) := FND_API.G_FALSE;
 		p_commit 			VARCHAR2(30) := FND_API.G_FALSE;
 		l_msg_count 		NUMBER(15);
		l_last_update_date  hz_contact_points.last_update_date%TYPE;

 	    l_contact_point_rec	        HZ_CONTACT_POINT_V2PUB.contact_point_rec_type;
 	    l_phone_rec			   HZ_CONTACT_POINT_V2PUB.phone_rec_type;


        CURSOR  get_lupd_date(p_contact_point_id NUMBER ) IS
        SELECT  last_update_date
        FROM    hz_contact_points
        WHERE   contact_point_id = p_contact_point_id;


    tmp_var1          VARCHAR2(2000);
    tmp_var           VARCHAR2(2000);

 BEGIN

IF p_action = 'INSERT' THEN
                        l_CONTACT_POINT_REC.CONTACT_POINT_ID	:=  p_contact_point_id;
                        l_CONTACT_POINT_REC.CONTACT_POINT_TYPE  := 'PHONE';
                        l_CONTACT_POINT_REC.STATUS		     :=  p_status;
                        l_CONTACT_POINT_REC.OWNER_TABLE_NAME	:=  P_owner_table_name;
                        l_CONTACT_POINT_REC.OWNER_TABLE_ID	     :=  p_owner_table_id;
                        l_CONTACT_POINT_REC.PRIMARY_FLAG	     :=  p_primary_flag;
                        l_CONTACT_POINT_REC.CONTENT_SOURCE_TYPE	:=  'USER_ENTERED';
                        l_CONTACT_POINT_REC.attribute_category  := p_attribute_category  ;
                         l_CONTACT_POINT_REC.attribute1           := p_attribute1;
                        l_CONTACT_POINT_REC.attribute2	 	:= p_attribute2;
                        l_CONTACT_POINT_REC.attribute3		:= p_attribute3;
                        l_CONTACT_POINT_REC.attribute4	 	:= p_attribute4 ;
                        l_CONTACT_POINT_REC.attribute5		:= p_attribute5;
                        l_CONTACT_POINT_REC.attribute6	 	:= p_attribute6;
                        l_CONTACT_POINT_REC.attribute7	 	:= p_attribute7;
                        l_CONTACT_POINT_REC.attribute8	 	:= p_attribute8;
                        l_CONTACT_POINT_REC.attribute9		:= p_attribute9 ;
                        l_CONTACT_POINT_REC.attribute10		:= p_attribute10 ;
                        l_CONTACT_POINT_REC.attribute11	 	:= p_attribute11;
                        l_CONTACT_POINT_REC.attribute12	 	:= p_attribute12;
                        l_CONTACT_POINT_REC.attribute13		:= p_attribute13 ;
                        l_CONTACT_POINT_REC.attribute14	 	:= p_attribute14;
                        l_CONTACT_POINT_REC.attribute15	 	:= p_attribute15;
                        l_CONTACT_POINT_REC.attribute16	 	:= p_attribute16;
                        l_CONTACT_POINT_REC.attribute17	 	:= p_attribute17;
                        l_CONTACT_POINT_REC.attribute18		:= p_attribute18;
                        l_CONTACT_POINT_REC.attribute19  	     := p_attribute19;
                        l_CONTACT_POINT_REC.attribute20	 	:= p_attribute20;
                         l_CONTACT_POINT_REC.created_by_module   := 'IGS';


                        l_PHONE_REC.PHONE_COUNTRY_CODE	 :=   p_phone_country_code;
                        l_PHONE_REC.PHONE_AREA_CODE	      :=   p_phone_area_code;
                        l_PHONE_REC.PHONE_NUMBER	           :=   p_phone_number;
                        l_PHONE_REC.PHONE_EXTENSION	      :=   p_phone_extension;
                        l_PHONE_REC.PHONE_LINE_TYPE	      :=   p_phone_line_type;

           HZ_CONTACT_POINT_V2PUB.create_contact_point(
                       p_init_msg_list           => p_init_msg_list ,
                       p_contact_point_rec       => l_contact_point_rec ,
                       p_phone_rec               => l_phone_rec ,
                       x_contact_point_id        => p_contact_point_id,
                       x_return_status           => p_return_status ,
                       x_msg_count               => l_msg_count,
                       x_msg_data                => p_msg_data );


        IF p_return_status = 'S' THEN
            p_contact_point_ovn := 1;
	ELSIF p_return_status <> 'S' THEN
           -- bug 2338473 logic to display more than one error modified.
          IF l_msg_count > 1 THEN
            FOR i IN 1..l_msg_count  LOOP
              tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
              tmp_var1 := tmp_var1 || ' '|| tmp_var;
            END LOOP;
          p_msg_data := tmp_var1;
          END IF;
          RETURN;
       END IF;


 ELSIF p_action = 'UPDATE' THEN


                  l_CONTACT_POINT_REC.CONTACT_POINT_ID	      :=  p_contact_point_id;
                  l_CONTACT_POINT_REC.CONTACT_POINT_TYPE     := 'PHONE';
                  l_CONTACT_POINT_REC.STATUS		           :=  p_status;
                  l_CONTACT_POINT_REC.OWNER_TABLE_NAME	      :=  P_owner_table_name;
                  l_CONTACT_POINT_REC.OWNER_TABLE_ID	      :=  p_owner_table_id;
                  l_CONTACT_POINT_REC.PRIMARY_FLAG	      :=  NVL(p_primary_flag,FND_API.G_MISS_CHAR);
                --  l_CONTACT_POINT_REC.CONTENT_SOURCE_TYPE	 :=  'USER_ENTERED';
                  l_CONTACT_POINT_REC.attribute_category    :=  NVL(p_attribute_category,FND_API.G_MISS_CHAR);
                   l_CONTACT_POINT_REC.attribute1          := NVL(p_attribute1,FND_API.G_MISS_CHAR);
                  l_CONTACT_POINT_REC.attribute2	 	:= NVL(p_attribute2,FND_API.G_MISS_CHAR);
                  l_CONTACT_POINT_REC.attribute3		:= NVL(p_attribute3,FND_API.G_MISS_CHAR);
                  l_CONTACT_POINT_REC.attribute4	 	:= NVL(p_attribute4,FND_API.G_MISS_CHAR);
                  l_CONTACT_POINT_REC.attribute5		:= NVL(p_attribute5,FND_API.G_MISS_CHAR);
                  l_CONTACT_POINT_REC.attribute6	 	:= NVL(p_attribute6,FND_API.G_MISS_CHAR);
                  l_CONTACT_POINT_REC.attribute7	 	:= NVL(p_attribute7,FND_API.G_MISS_CHAR);
                  l_CONTACT_POINT_REC.attribute8	 	:= NVL(p_attribute8,FND_API.G_MISS_CHAR);
                  l_CONTACT_POINT_REC.attribute9		:= NVL(p_attribute9,FND_API.G_MISS_CHAR);
                  l_CONTACT_POINT_REC.attribute10		:= NVL(p_attribute10,FND_API.G_MISS_CHAR);
                  l_CONTACT_POINT_REC.attribute11	 	:= NVL(p_attribute11,FND_API.G_MISS_CHAR);
                  l_CONTACT_POINT_REC.attribute12	 	:= NVL(p_attribute12,FND_API.G_MISS_CHAR);
                  l_CONTACT_POINT_REC.attribute13		:= NVL(p_attribute13,FND_API.G_MISS_CHAR);
                  l_CONTACT_POINT_REC.attribute14	 	:= NVL(p_attribute14,FND_API.G_MISS_CHAR);
                  l_CONTACT_POINT_REC.attribute15	 	:= NVL(p_attribute15,FND_API.G_MISS_CHAR);
                  l_CONTACT_POINT_REC.attribute16	 	:= NVL(p_attribute16,FND_API.G_MISS_CHAR);
                  l_CONTACT_POINT_REC.attribute17	 	:= NVL(p_attribute17,FND_API.G_MISS_CHAR);
                  l_CONTACT_POINT_REC.attribute18		:= NVL(p_attribute18,FND_API.G_MISS_CHAR);
                  l_CONTACT_POINT_REC.attribute19      := NVL(p_attribute19,FND_API.G_MISS_CHAR);
                  l_CONTACT_POINT_REC.attribute20	 	:= NVL(p_attribute20,FND_API.G_MISS_CHAR);
              --    l_CONTACT_POINT_REC.created_by_module   := 'IGS';


                  l_PHONE_REC.PHONE_COUNTRY_CODE	      :=  NVL(p_phone_country_code,FND_API.G_MISS_CHAR);
                  l_PHONE_REC.PHONE_AREA_CODE	      :=  NVL(p_phone_area_code,FND_API.G_MISS_CHAR);
                  l_PHONE_REC.PHONE_NUMBER	           :=  NVL( p_phone_number,FND_API.G_MISS_CHAR);
                  l_PHONE_REC.PHONE_EXTENSION	      :=  NVL( p_phone_extension,FND_API.G_MISS_CHAR);
                  l_PHONE_REC.PHONE_LINE_TYPE	      :=  NVL( p_phone_line_type,FND_API.G_MISS_CHAR);

                 HZ_CONTACT_POINT_V2PUB.update_contact_point(
		                     p_init_msg_list         => p_init_msg_list ,
                                     p_contact_point_rec     => l_contact_point_rec ,
                                     p_phone_rec	     =>  l_PHONE_REC,
                                     p_object_version_number => p_contact_point_ovn,
                                     x_return_status         => p_return_status,
                                     x_msg_count             => l_msg_count ,
                                     x_msg_data              => p_msg_data

                                                            );



       IF p_return_status <> 'S' THEN
           -- bug 2338473 logic to display more than one error modified.
          IF l_msg_count > 1 THEN
            FOR i IN 1..l_msg_count  LOOP
              tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
              tmp_var1 := tmp_var1 || ' '|| tmp_var;
            END LOOP;
          p_msg_data := tmp_var1;
          END IF;
          RETURN;
       END IF;

END IF;

END HZ_CONTACT_POINTS_AKP;

END IGS_PE_CONTACT_POINT_PKG;

/
