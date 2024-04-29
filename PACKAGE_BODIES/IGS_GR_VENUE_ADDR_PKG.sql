--------------------------------------------------------
--  DDL for Package Body IGS_GR_VENUE_ADDR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_GR_VENUE_ADDR_PKG" as
/* $Header: IGSGI20B.pls 120.1 2005/09/16 07:04:29 appldev ship $ */
PROCEDURE INSERT_ROW (
    x_rowid IN OUT NOCOPY VARCHAR2,
    x_location_venue_addr_id IN OUT NOCOPY NUMBER,
    x_location_id IN OUT NOCOPY NUMBER,
    x_location_venue_cd IN VARCHAR2,
    x_start_dt IN DATE,
    x_end_dt IN DATE,
    x_country IN VARCHAR2,
    x_address_style IN VARCHAR2,
    x_addr_line_1 IN VARCHAR2,
    x_addr_line_2 IN VARCHAR2,
    x_addr_line_3 IN VARCHAR2,
    x_addr_line_4 IN VARCHAR2,
    x_date_last_verified IN DATE,
    x_correspondence IN VARCHAR2,
    x_city IN VARCHAR2,
    x_state IN VARCHAR2,
    x_province IN VARCHAR2,
    x_county IN VARCHAR2,
    x_postal_code IN VARCHAR2,
    x_address_lines_phonetic IN VARCHAR2,
    x_delivery_point_code IN VARCHAR2,
    x_other_details_1 IN VARCHAR2,
    x_other_details_2 IN VARCHAR2,
    x_other_details_3 IN VARCHAR2,
    x_source_type IN VARCHAR2,
    x_contact_person IN VARCHAR2 default NULL,
    x_msg_data OUT NOCOPY VARCHAR2,
    X_MODE IN VARCHAR2 DEFAULT 'R'
  ) AS

    p_location_rec_insert HZ_LOCATION_V2PUB.location_rec_type;

    l_return_status VARCHAR2(100);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(1000);
    l_location_id NUMBER;
    l_loc_id NUMBER;
    l_location_venue_addr_id NUMBER := x_location_venue_addr_id;

    lv_rowid VARCHAR2(25);
    tmp_var1          VARCHAR2(2000);
    tmp_var           VARCHAR2(2000);

BEGIN
    p_location_rec_insert.country := x_country;
    p_location_rec_insert.address_style := x_address_style;
    p_location_rec_insert.address1 := x_addr_line_1;
    p_location_rec_insert.address2 := x_addr_line_2;
    p_location_rec_insert.address3 := x_addr_line_3;
    p_location_rec_insert.address4 := x_addr_line_4;
    p_location_rec_insert.city := x_city;
    p_location_rec_insert.state := x_state;
    p_location_rec_insert.province := x_province;
    p_location_rec_insert.county := x_county;
    p_location_rec_insert.postal_code := x_postal_code;
    p_location_rec_insert.address_lines_phonetic := x_address_lines_phonetic;
    p_location_rec_insert.address_effective_date := x_start_dt;
    p_location_rec_insert.address_expiration_date := x_end_dt;
    p_location_rec_insert.created_by_module := 'IGS';
    p_location_rec_insert.content_source_type := 'USER_ENTERED';


    /*  Hz_Location_Pub.CREATE_LOCATION(
        p_api_version => 1.0,
        p_init_msg_list => FND_API.G_TRUE,
        p_location_rec => p_location_rec_insert,
        x_return_status => l_return_status,
        x_msg_count => l_msg_count,
        x_msg_data=> l_msg_data,
        x_location_id => l_location_id
	); */


	HZ_LOCATION_V2PUB.create_location(
                   p_init_msg_list  => FND_API.G_FALSE,
                   p_location_rec   => p_location_rec_insert,
                   x_location_id    => l_location_id ,
                   x_return_status  => l_return_status,
                   x_msg_count      => l_msg_count,
                   x_msg_data       => l_msg_data
                   );


      IF l_return_status IN ('E', 'U') THEN

         IF l_msg_count > 1 THEN
            FOR i IN 1..l_msg_count  LOOP
              tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
              tmp_var1 := tmp_var1 || ' '|| tmp_var;
            END LOOP;
            x_msg_data := tmp_var1;
         END IF;
         RETURN;
      ELSIF l_return_status = 'S' THEN

   	  HZ_TAX_ASSIGNMENT_V2PUB.CREATE_LOC_ASSIGNMENT(
		p_location_id => l_location_id,
		p_lock_flag     =>FND_API.G_FALSE,
		p_created_by_module => 'IGS',
 	        x_return_status =>l_return_status,
 	        x_msg_count     => l_msg_count,
 	        x_msg_data      =>l_msg_data,
 	        x_loc_id        => l_loc_id,
		p_application_id =>8405
		);

        x_location_id := l_location_id;

        IF l_return_status IN ('E', 'U') THEN
          IF l_msg_count > 1 THEN
            FOR i IN 1..l_msg_count  LOOP
              tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
              tmp_var1 := tmp_var1 || ' '|| tmp_var;
            END LOOP;
            x_msg_data := tmp_var1;
          END IF;
          RETURN;
        ELSIF l_return_status = 'S' THEN


          IGS_PE_HZ_LOCATIONS_PKG.INSERT_ROW(
            x_rowid => lv_rowid,
            x_location_id => l_location_id,
            x_other_details_1 => x_other_details_1,
            x_other_details_2 => x_other_details_2,
            x_other_details_3 => x_other_details_3,
            -- x_correspondence => x_correspondence,
            x_date_last_verified => x_date_last_verified,
            x_contact_person => x_contact_person
          );
          IGS_AD_LOCVENUE_ADDR_PKG.INSERT_ROW(
            x_rowid => x_rowid,
            x_location_venue_addr_id => l_location_venue_addr_id,
            x_location_id => l_location_id,
            x_location_venue_cd => x_location_venue_cd,
            x_source_type => x_source_type,
            x_identifying_address_flag =>  NVL(x_correspondence,'N')
          );
          x_location_venue_addr_id := l_location_venue_addr_id;
        END IF;
      END IF;

END INSERT_ROW;

PROCEDURE UPDATE_ROW (
    x_rowid IN VARCHAR2,
    x_location_venue_addr_id IN NUMBER,
    x_location_id IN NUMBER,
    x_location_venue_cd IN VARCHAR2,
    x_start_dt IN DATE,
    x_end_dt IN DATE,
    x_country IN VARCHAR2,
    x_address_style IN VARCHAR2,
    x_addr_line_1 IN VARCHAR2,
    x_addr_line_2 IN VARCHAR2,
    x_addr_line_3 IN VARCHAR2,
    x_addr_line_4 IN VARCHAR2,
    x_date_last_verified IN DATE,
    x_correspondence IN VARCHAR2,
    x_city IN VARCHAR2,
    x_state IN VARCHAR2,
    x_province IN VARCHAR2,
    x_county IN VARCHAR2,
    x_postal_code IN VARCHAR2,
    x_address_lines_phonetic IN VARCHAR2,
    x_delivery_point_code IN VARCHAR2,
    x_other_details_1 IN VARCHAR2,
    x_other_details_2 IN VARCHAR2,
    x_other_details_3 IN VARCHAR2,
    x_source_type IN VARCHAR2,
    x_contact_person IN VARCHAR2 default NULL,
    x_msg_data OUT NOCOPY VARCHAR2,
    X_MODE IN VARCHAR2 DEFAULT 'R'
  ) AS

    p_location_rec_update Hz_Location_v2Pub.location_rec_type;

    l_return_status VARCHAR2(100);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(1000);
    l_location_id NUMBER := x_location_id;
    l_loc_id NUMBER;
    l_last_update_date DATE;
    lv_rowid VARCHAR2(25);

    tmp_var1          VARCHAR2(2000);
    tmp_var           VARCHAR2(2000);

    CURSOR c_loc IS
      SELECT OBJECT_VERSION_NUMBER
      FROM hz_locations
      WHERE location_id = x_location_id;

    loc_rec c_loc%ROWTYPE;

BEGIN
    p_location_rec_update.location_id := x_location_id;
    p_location_rec_update.country := x_country;
    p_location_rec_update.address_style := NVL(x_address_style,FND_API.G_MISS_CHAR);
    p_location_rec_update.address1 := x_addr_line_1;
    p_location_rec_update.address2 := NVL(x_addr_line_2,FND_API.G_MISS_CHAR);
    p_location_rec_update.address3 := NVL(x_addr_line_3,FND_API.G_MISS_CHAR);
    p_location_rec_update.address4 := NVL(x_addr_line_4,FND_API.G_MISS_CHAR);
    p_location_rec_update.city := NVL(x_city,FND_API.G_MISS_CHAR);
    p_location_rec_update.state := NVL(x_state,FND_API.G_MISS_CHAR);
    p_location_rec_update.province := NVL(x_province,FND_API.G_MISS_CHAR);
    p_location_rec_update.county := NVL(x_county,FND_API.G_MISS_CHAR);
    p_location_rec_update.postal_code := NVL(x_postal_code,FND_API.G_MISS_CHAR);
    p_location_rec_update.address_lines_phonetic := NVL(x_address_lines_phonetic,FND_API.G_MISS_CHAR);
    p_location_rec_update.address_effective_date := NVL(x_start_dt,FND_API.G_MISS_DATE);
    p_location_rec_update.address_expiration_date := NVL(x_end_dt,FND_API.G_MISS_DATE);

     OPEN c_loc;
     FETCH c_loc INTO loc_rec;
     CLOSE c_loc;

       HZ_LOCATION_V2PUB.update_location(
                    p_location_rec     =>   p_location_rec_update,
                    p_object_version_number => loc_rec.object_version_number,
                    x_return_status     => l_return_status,
                    x_msg_count  => l_msg_count,
                    x_msg_data=> l_msg_data
                    );

      IF l_return_status IN ('E', 'U') THEN

        IF l_msg_count > 1 THEN
            FOR i IN 1..l_msg_count  LOOP
              tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
              tmp_var1 := tmp_var1 || ' '|| tmp_var;
            END LOOP;
            x_msg_data := tmp_var1;
         END IF;
         RETURN;
      ELSIF l_return_status = 'S' THEN

    	HZ_TAX_ASSIGNMENT_V2PUB.UPDATE_LOC_ASSIGNMENT(
 	        p_location_id   => l_location_id,
		p_lock_flag     =>FND_API.G_FALSE,
		p_created_by_module  => 'IGS',
 	        x_return_status =>l_return_status,
 	        x_msg_count     => l_msg_count,
 	        x_msg_data      => l_msg_data,
 	        x_loc_id        => l_loc_id,
		p_application_id =>8405
 	        --p_lock_flag
		);

        IF l_return_status IN ('E', 'U') THEN

          IF l_msg_count > 1 THEN
            FOR i IN 1..l_msg_count  LOOP
              tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
              tmp_var1 := tmp_var1 || ' '|| tmp_var;
            END LOOP;
            x_msg_data := tmp_var1;
          END IF;
          RETURN;
        ELSIF l_return_status = 'S' THEN

		  SELECT ROWID INTO lv_rowid FROM IGS_PE_HZ_LOCATIONS WHERE location_id = x_location_id;

          IGS_PE_HZ_LOCATIONS_PKG.UPDATE_ROW(
            x_rowid => lv_rowid,
            x_location_id => x_location_id,
            x_other_details_1 => x_other_details_1,
            x_other_details_2 => x_other_details_2,
            x_other_details_3 => x_other_details_3,
           --  x_correspondence => x_correspondence,
            x_date_last_verified => x_date_last_verified,
            x_contact_person => x_contact_person
          );

          IGS_AD_LOCVENUE_ADDR_PKG.UPDATE_ROW(
            x_rowid => x_rowid,
            x_location_venue_addr_id => x_location_venue_addr_id,
            x_location_id => x_location_id,
            x_location_venue_cd => x_location_venue_cd,
            x_source_type => x_source_type,
            x_identifying_address_flag => NVL(x_correspondence,'N')
          );
        END IF;
    END IF;
END UPDATE_ROW;

end IGS_GR_VENUE_ADDR_PKG;

/
