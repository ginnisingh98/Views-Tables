--------------------------------------------------------
--  DDL for Package Body IGS_AD_LOCATION_ADDR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_LOCATION_ADDR_PKG" AS
 /* $Header: IGSAI45B.pls 120.2 2006/06/23 05:49:03 gmaheswa noship $ */

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
    l_return_status  OUT NOCOPY VARCHAR2,
    x_object_version_number IN OUT NOCOPY NUMBER,
    X_MODE IN VARCHAR2 DEFAULT 'R'
  ) AS

	p_location_rec_insert    HZ_LOCATION_V2PUB.location_rec_type;

    l_msg_count NUMBER;
    l_msg_data VARCHAR2(1000);
    l_location_id NUMBER;
    l_loc_id NUMBER;
    l_location_venue_addr_id NUMBER := x_location_venue_addr_id;

    lv_rowid VARCHAR2(25);
    lv_rowid_locvenue VARCHAR2(25);

    tmp_var1          VARCHAR2(2000);
    tmp_var           VARCHAR2(2000);

    l_addr_val_status  VARCHAR2(30);
    l_addr_warn_msg    VARCHAR2(2000);

BEGIN

	IF x_start_dt IS NOT NULL AND x_end_dt IS NOT NULL THEN
	   IF x_start_dt > x_end_dt THEN
          FND_MESSAGE.SET_NAME('IGS','IGS_PE_FROM_DT_GRT_TO_DATE');
		  IGS_GE_MSG_STACK.ADD;
		  APP_EXCEPTION.RAISE_EXCEPTION;
	   END IF;
	END IF;

     IF x_start_dt IS NULL AND x_end_dt IS NOT NULL THEN
           FND_MESSAGE.SET_NAME('IGS','IGS_PE_CANT_SPECIFY_FROM_DATE');
           IGS_GE_MSG_STACK.ADD;
           APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;

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

    p_location_rec_insert.delivery_point_code := x_delivery_point_code;

    p_location_rec_insert.address_lines_phonetic := x_address_lines_phonetic;
    p_location_rec_insert.address_effective_date := x_start_dt;
    p_location_rec_insert.address_expiration_date := x_end_dt;
    p_location_rec_insert.created_by_module         := 'IGS';
    p_location_rec_insert.application_id            := 8405;

    HZ_LOCATION_V2PUB.create_location (
                 P_INIT_MSG_LIST                        => FND_API.G_TRUE,
                 P_LOCATION_REC                         => p_location_rec_insert,
		 P_DO_ADDR_VAL				=> 'Y',
		 X_LOCATION_ID                          => l_location_id,
		 x_addr_val_status			=> l_addr_val_status,
		 x_addr_warn_msg			=> l_addr_warn_msg,
                 X_RETURN_STATUS                        => l_return_status,
                 X_MSG_COUNT                            => l_msg_count,
                 X_MSG_DATA                             => l_msg_data
                );


   IF l_return_status IN ('E', 'U') THEN

    -- bug 2338473 logic to display more than one error modified.
       x_msg_data := l_msg_data;
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
            x_rowid => lv_rowid_locvenue,
            x_location_venue_addr_id => l_location_venue_addr_id,
            x_location_id => l_location_id,
            x_location_venue_cd => x_location_venue_cd,
            x_source_type => x_source_type,
            x_identifying_address_flag =>  NVL(x_correspondence,'N')
          );
          x_location_venue_addr_id := l_location_venue_addr_id;
		  x_rowid       := lv_rowid_locvenue;
          x_location_id := l_location_id;
          x_object_version_number := 1;
   END IF;

   IF l_addr_val_status = 'W' THEN
      x_msg_data := l_addr_warn_msg;
      l_return_status := l_addr_val_status;
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
    l_return_status  OUT NOCOPY VARCHAR2 ,
	x_object_version_number IN OUT NOCOPY NUMBER,
    X_MODE IN VARCHAR2 DEFAULT 'R'
  ) AS

    p_location_rec_update   HZ_LOCATION_V2PUB.location_rec_type;

    l_msg_count NUMBER;
    l_msg_data VARCHAR2(1000);
    l_location_id NUMBER := x_location_id;
    l_loc_id NUMBER;
    lv_rowid VARCHAR2(25);

    tmp_var1          VARCHAR2(2000);
    tmp_var           VARCHAR2(2000);
    l_addr_val_status  VARCHAR2(30);
    l_addr_warn_msg    VARCHAR2(2000);

CURSOR c IS
SELECT ROWID
FROM igs_pe_hz_locations
WHERE location_id = x_location_id;


BEGIN

	IF x_start_dt IS NOT NULL AND x_end_dt IS NOT NULL THEN
	   IF x_start_dt > x_end_dt THEN
           FND_MESSAGE.SET_NAME('IGS','IGS_PE_FROM_DT_GRT_TO_DATE');
		  IGS_GE_MSG_STACK.ADD;
		  APP_EXCEPTION.RAISE_EXCEPTION;
	   END IF;
	END IF;

    IF x_start_dt IS NULL AND x_end_dt IS NOT NULL THEN
           FND_MESSAGE.SET_NAME('IGS','IGS_PE_CANT_SPECIFY_FROM_DATE');
           IGS_GE_MSG_STACK.ADD;
           APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;


    p_location_rec_update.location_id := x_location_id;
    p_location_rec_update.country := x_country;
    p_location_rec_update.address_style := NVL(x_address_style,FND_API.G_MISS_CHAR);
    p_location_rec_update.address1 := NVL(x_addr_line_1,FND_API.G_MISS_CHAR);
    p_location_rec_update.address2 := NVL(x_addr_line_2,FND_API.G_MISS_CHAR);
    p_location_rec_update.address3 := NVL(x_addr_line_3,FND_API.G_MISS_CHAR);
    p_location_rec_update.address4 := NVL(x_addr_line_4,FND_API.G_MISS_CHAR);
    p_location_rec_update.city := NVL(x_city,FND_API.G_MISS_CHAR);
    p_location_rec_update.state := NVL(x_state,FND_API.G_MISS_CHAR);
    p_location_rec_update.province := NVL(x_province,FND_API.G_MISS_CHAR);
    p_location_rec_update.county := NVL(x_county,FND_API.G_MISS_CHAR);
    p_location_rec_update.postal_code := NVL(x_postal_code,FND_API.G_MISS_CHAR);

    p_location_rec_update.delivery_point_code := NVL(x_delivery_point_code,FND_API.G_MISS_CHAR);

    p_location_rec_update.address_lines_phonetic := NVL(x_address_lines_phonetic,FND_API.G_MISS_CHAR);
    p_location_rec_update.address_effective_date := NVL(x_start_dt,FND_API.G_MISS_DATE);
    p_location_rec_update.address_expiration_date := NVL(x_end_dt,FND_API.G_MISS_DATE);

    HZ_LOCATION_V2PUB.update_location(
         P_INIT_MSG_LIST                        => FND_API.G_TRUE,
         P_LOCATION_REC                         => p_location_rec_update,
	 p_do_addr_val				=> 'Y',
         p_object_version_number                => x_object_version_number,
	 x_addr_val_status			=> l_addr_val_status,
	 x_addr_warn_msg			=> l_addr_warn_msg,
	 X_RETURN_STATUS                        => l_return_status,
         X_MSG_COUNT                            => l_msg_count,
         X_MSG_DATA                             => l_msg_data
        );

  IF l_return_status IN ('E', 'U') THEN
    -- bug 2338473 logic to display more than one error modified.
       x_msg_data := l_msg_data;

       IF l_msg_count > 1 THEN
        FOR i IN 1..l_msg_count  LOOP
          tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
          tmp_var1 := tmp_var1 || ' '|| tmp_var;
        END LOOP;
        x_msg_data := tmp_var1;
       END IF;
       RETURN;

  ELSIF l_return_status = 'S' THEN

          OPEN c ;
	      FETCH c INTO lv_rowid;
	      CLOSE c;

          IGS_PE_HZ_LOCATIONS_PKG.UPDATE_ROW(
            x_rowid => lv_rowid,
            x_location_id => x_location_id,
            x_other_details_1 => x_other_details_1,
            x_other_details_2 => x_other_details_2,
            x_other_details_3 => x_other_details_3,
            -- x_correspondence => x_correspondence,
            x_date_last_verified => x_date_last_verified,
            x_contact_person => x_contact_person     );

          IGS_AD_LOCVENUE_ADDR_PKG.UPDATE_ROW(
            x_rowid => x_rowid,
            x_location_venue_addr_id => x_location_venue_addr_id,
            x_location_id => x_location_id,
            x_location_venue_cd => x_location_venue_cd,
            x_source_type => x_source_type,
            x_identifying_address_flag =>  NVL(x_correspondence,'N')  );

    END IF;
    IF l_addr_val_status = 'W' THEN
      x_msg_data := l_addr_warn_msg;
      l_return_status := l_addr_val_status;
    END IF;

END UPDATE_ROW;

END IGS_AD_LOCATION_ADDR_PKG;

/
