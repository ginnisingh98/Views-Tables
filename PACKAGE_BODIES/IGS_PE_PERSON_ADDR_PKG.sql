--------------------------------------------------------
--  DDL for Package Body IGS_PE_PERSON_ADDR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_PERSON_ADDR_PKG" AS
/* $Header: IGSNI12B.pls 120.2 2006/07/24 12:44:33 vskumar noship $ */

procedure INSERT_ROW (
                p_action                        IN      VARCHAR2,
                p_rowid                         IN OUT NOCOPY  VARCHAR2,
                p_location_id                   IN OUT NOCOPY  NUMBER,
                p_start_dt                      IN      igs_pe_hz_pty_sites.start_date%TYPE,
                p_end_dt                        IN      igs_pe_hz_pty_sites.end_date%TYPE,
                p_country                       IN      VARCHAR2,
                p_address_style                 IN      VARCHAR2,
                p_addr_line_1                   IN      VARCHAR2,
                p_addr_line_2                   IN      VARCHAR2,
                p_addr_line_3                   IN      VARCHAR2,
                p_addr_line_4                   IN      VARCHAR2,
                p_date_last_verified            IN      DATE,
                p_correspondence                IN      VARCHAR2,
                p_city                          IN      VARCHAR2,
                p_state                         IN      VARCHAR2,
                p_province                      IN      VARCHAR2,
                p_county                        IN      VARCHAR2,
                p_postal_code                   IN      VARCHAR2,
                p_address_lines_phonetic        IN      VARCHAR2,
                p_delivery_point_code           IN      VARCHAR2,
                p_other_details_1               IN      VARCHAR2,
                p_other_details_2               IN      VARCHAR2,
                p_other_details_3               IN      VARCHAR2,
                l_return_status         OUT NOCOPY     VARCHAR2,
                l_msg_data              OUT NOCOPY      VARCHAR2,
                p_party_id                      IN      NUMBER,
                p_party_site_id       IN OUT NOCOPY     NUMBER,
                p_party_type            IN      VARCHAR2,
                p_last_update_date      IN OUT NOCOPY  DATE,
                p_party_site_ovn                IN OUT NOCOPY hz_party_sites.object_version_number%TYPE,
                p_location_ovn                  IN OUT NOCOPY hz_party_sites.object_version_number%TYPE,
                p_status                        IN hz_party_sites.status%TYPE
   ) AS

        p_init_msg_list                 VARCHAR2(30) := FND_API.G_TRUE;
        p_lock_flag                     VARCHAR2(30) := FND_API.G_FALSE;
        l_contact_person        VARCHAR2(40) := NULL;
        l_msg_count             NUMBER(15);
        l_loc_id                NUMBER(15);
        lv_rowid                VARCHAR2(25);
        l_tmp_var1               VARCHAR2(2000);
        l_tmp_var               VARCHAR2(2000);
        p_location_rec_insert    HZ_LOCATION_V2PUB.location_rec_type;
        p_party_site_rec_insert   HZ_PARTY_SITE_V2PUB.party_site_rec_type;
	l_addr_val_status  VARCHAR2(30);
	l_addr_warn_msg    VARCHAR2(2000);

         CURSOR c_birth_date_val IS SELECT date_of_birth FROM HZ_PERSON_PROFILES
         WHERE party_id = p_party_id AND effective_end_Date IS NULL;
         l_date_of_birth HZ_PERSON_PROFILES.DATE_OF_BIRTH%TYPE;

        CURSOR c_party_site_number IS
        SELECT hz_party_site_number_s.NEXTVAL
        FROM dual;

        l_party_site_number   HZ_PARTY_SITES.PARTY_SITE_NUMBER%TYPE;
        l_hz_gen_party_site   VARCHAR2(10);
BEGIN

        IF p_start_dt IS NOT NULL AND p_end_dt IS NOT NULL THEN
           IF p_start_dt > p_end_dt THEN
                  FND_MESSAGE.SET_NAME('IGS','IGS_PE_FROM_DT_GRT_TO_DATE');
                  IGS_GE_MSG_STACK.ADD;
                  APP_EXCEPTION.RAISE_EXCEPTION;
           END IF;
        END IF;

        IF p_start_dt IS NULL AND p_end_dt IS NOT NULL THEN
              FND_MESSAGE.SET_NAME('IGS','IGS_PE_CANT_SPECIFY_FROM_DATE');
              IGS_GE_MSG_STACK.ADD;
              APP_EXCEPTION.RAISE_EXCEPTION;
        END IF;

        IF p_start_dt IS NOT NULL THEN
          OPEN c_birth_date_val; FETCH c_birth_date_val INTO l_date_of_birth;
          CLOSE c_birth_date_val;
          IF(p_start_dt IS NOT NULL AND l_Date_of_birth IS NOT NULL) THEN
            IF(p_start_dt < l_date_of_birth) THEN
              Fnd_Message.Set_Name('IGS','IGS_PE_DREC_GT_BTDT');
              IGS_GE_MSG_STACK.ADD;
              App_Exception.Raise_Exception;
            END IF;
          END IF;
        END IF;

        p_location_rec_insert.country                   := p_country;
        p_location_rec_insert.address_style             := p_address_style;
        p_location_rec_insert.address1                  := p_addr_line_1;
        p_location_rec_insert.address2                  := p_addr_line_2;
        p_location_rec_insert.address3                  := p_addr_line_3;
        p_location_rec_insert.address4                  := p_addr_line_4;
        p_location_rec_insert.city                      := p_city;
        p_location_rec_insert.state                     := p_state;
        p_location_rec_insert.province                  := p_province;
        p_location_rec_insert.county                    := p_county;
        p_location_rec_insert.postal_code               := p_postal_code;
        p_location_rec_insert.address_lines_phonetic    := p_address_lines_phonetic;
        p_location_rec_insert.address_effective_date    := NULL;
        p_location_rec_insert.address_expiration_date   := NULL;
        p_location_rec_insert.created_by_module         := 'IGS';
        p_location_rec_insert.application_id            := 8405;
        p_location_rec_insert.delivery_point_code       := p_delivery_point_code;

        HZ_LOCATION_V2PUB.create_location (
                 P_INIT_MSG_LIST                        => p_init_msg_list,
                 P_LOCATION_REC                         => p_location_rec_insert,
		 P_DO_ADDR_VAL				=> 'Y',
		 X_LOCATION_ID                          => p_location_id,
		 x_addr_val_status			=> l_addr_val_status,
		 x_addr_warn_msg			=> l_addr_warn_msg,
                 X_RETURN_STATUS                        => l_return_status,
                 X_MSG_COUNT                            => l_msg_count,
                 X_MSG_DATA                             => l_msg_data
                );

            IF l_return_status in ('E', 'U') THEN
            --sbaliga added this code corresponding to IF condition as part of #2338473

             IF l_msg_count > 1 THEN
              FOR i IN 1..l_msg_count
                LOOP
                l_tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
                l_tmp_var1 := l_tmp_var1 || ' '|| l_tmp_var;
                END LOOP;
              l_msg_data := l_tmp_var1;
             END IF;
             RETURN;
           ELSIF l_return_status = 'S' THEN
                p_location_ovn   := 1;
	        -- bug 2203778 : ssawhney, correspondence flag is obsoleted from IGS table and from now
                -- this flag will be replaced by hz_party_sites

                P_PARTY_SITE_REC_INSERT.PARTY_ID          :=  p_party_id;
                P_PARTY_SITE_REC_INSERT.LOCATION_ID       :=  p_location_id;
                P_PARTY_SITE_REC_INSERT.IDENTIFYING_ADDRESS_FLAG :=  p_correspondence ;
                P_PARTY_SITE_REC_INSERT.created_by_module := 'IGS';
                P_PARTY_SITE_REC_INSERT.application_id    := 8405;
                P_PARTY_SITE_REC_INSERT.status            := p_status;

                -- ssawhney bug 2379291. added logic to pass party site number if profile is set to autogenerate false.

                fnd_profile.get('HZ_GENERATE_PARTY_SITE_NUMBER',l_hz_gen_party_site);
                IF l_hz_gen_party_site = 'N' THEN
                   OPEN c_party_site_number;
                     FETCH c_party_site_number INTO l_party_site_number;
                   CLOSE c_party_site_number;
                   P_PARTY_SITE_REC_INSERT.PARTY_SITE_NUMBER := 'IGS-'||l_party_site_number;
                END IF;


		HZ_PARTY_SITE_V2PUB.CREATE_PARTY_SITE
		(
		       P_INIT_MSG_LIST          => p_init_msg_list,
		       P_PARTY_SITE_REC       =>  p_party_site_rec_insert,
		       X_RETURN_STATUS        => l_return_status,
		       X_MSG_COUNT              => l_msg_count,
		       X_MSG_DATA               => l_msg_data,
		       X_PARTY_SITE_ID        => p_party_site_id,
		       X_PARTY_SITE_NUMBER    => l_party_site_number /* not passed to form */
		);

	        IF l_return_status ='E' or l_return_status ='U' THEN
 		    --ssawhney added this code corresponding to IF condition as part of #2338473
		    IF l_msg_count > 1 THEN
			FOR i IN 1..l_msg_count
			LOOP
			   l_tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
 			   l_tmp_var1 := l_tmp_var1 || ' '|| l_tmp_var;
			END LOOP;
			l_msg_data := l_tmp_var1;
		    END IF;
		    RETURN;
                    -- remove code for creation of customer account site.
                    -- ssawhney : 2225917
               ELSIF l_return_status = 'S' THEN
                    p_party_site_ovn := 1;
                    IF p_start_dt IS NOT NULL OR p_end_dt IS NOT NULL THEN
                         igs_pe_hz_pty_sites_pkg.insert_row(x_rowid          => lv_rowid,
                                                     x_party_site_id  => p_party_site_id,
                                                     x_start_date     => p_start_dt,
                                                     x_end_date       => p_end_dt );
                    END IF;
               END IF;
           END IF;

   IF l_addr_val_status = 'W' THEN
      l_msg_data := l_addr_warn_msg;
      l_return_status := l_addr_val_status;
   END IF;

END INSERT_ROW;

procedure UPDATE_ROW (
                p_action                        IN      VARCHAR2,
                p_rowid                         IN OUT NOCOPY  VARCHAR2,
                p_location_id                   IN OUT NOCOPY  NUMBER,
                p_start_dt                      IN      igs_pe_hz_pty_sites.start_date%TYPE,
                p_end_dt                        IN      igs_pe_hz_pty_sites.end_date%TYPE,
                p_country                       IN      VARCHAR2,
                p_address_style                 IN      VARCHAR2,
                p_addr_line_1                   IN      VARCHAR2,
                p_addr_line_2                   IN      VARCHAR2,
                p_addr_line_3                   IN      VARCHAR2,
                p_addr_line_4                   IN      VARCHAR2,
                p_date_last_verified            IN      DATE,
                p_correspondence                IN      VARCHAR2,
                p_city                          IN      VARCHAR2,
                p_state                         IN      VARCHAR2,
                p_province                      IN      VARCHAR2,
                p_county                        IN      VARCHAR2,
                p_postal_code                   IN      VARCHAR2,
                p_address_lines_phonetic        IN      VARCHAR2,
                p_delivery_point_code           IN      VARCHAR2,
                p_other_details_1               IN      VARCHAR2,
                p_other_details_2               IN      VARCHAR2,
                p_other_details_3               IN      VARCHAR2,
                l_return_status                 OUT NOCOPY     VARCHAR2,
                l_msg_data                      OUT NOCOPY      VARCHAR2,
                p_party_id                      IN      NUMBER,
                p_party_site_id                 IN OUT NOCOPY   NUMBER,
                p_party_type                    IN      VARCHAR2,
                p_last_update_date              IN  OUT NOCOPY DATE,
                p_party_site_ovn                IN OUT NOCOPY hz_party_sites.object_version_number%TYPE,
                p_location_ovn                  IN OUT NOCOPY hz_party_sites.object_version_number%TYPE,
                p_status                        IN hz_party_sites.status%TYPE
  )
  AS
        p_init_msg_list                 VARCHAR2(30) := FND_API.G_TRUE;
        p_lock_flag                     VARCHAR2(30) := FND_API.G_FALSE;
        l_contact_person        VARCHAR2(40) := NULL;
        l_party_site_number   HZ_PARTY_SITES.PARTY_SITE_NUMBER%TYPE;
        l_msg_count             NUMBER(15);
        l_loc_id                NUMBER(15);
        lv_rowid                VARCHAR2(25);
        p_location_rec_update   HZ_LOCATION_V2PUB.location_rec_type;
        p_party_site_rec_update HZ_PARTY_SITE_V2PUB.party_site_rec_type;
        l_tmp_var1           VARCHAR2(2000);
        l_tmp_var            VARCHAR2(2000);
        l_start_dt           DATE;
	l_addr_val_status  VARCHAR2(30);
	l_addr_warn_msg    VARCHAR2(2000);

        CURSOR c_birth_date_val IS SELECT date_of_birth FROM HZ_PERSON_PROFILES
        WHERE party_id = p_party_id AND effective_end_Date IS NULL;
        l_date_of_birth HZ_PERSON_PROFILES.DATE_OF_BIRTH%TYPE;


        CURSOR get_rowid(p_party_site_id NUMBER) IS
        SELECT ROWID,start_date
        FROM igs_pe_hz_pty_sites WHERE party_site_id = p_party_site_id;

BEGIN

                -- bug 2203778 : ssawhney, correspondence flag is obsoleted from IGS table and from now
                -- this flag will be replaced by hz_party_sites

        IF p_start_dt IS NOT NULL AND p_end_dt IS NOT NULL THEN
           IF p_start_dt > p_end_dt THEN
                  FND_MESSAGE.SET_NAME('IGS','IGS_PE_FROM_DT_GRT_TO_DATE');
                  IGS_GE_MSG_STACK.ADD;
                  APP_EXCEPTION.RAISE_EXCEPTION;
           END IF;
        END IF;

        IF p_start_dt IS NULL AND p_end_dt IS NOT NULL THEN
              FND_MESSAGE.SET_NAME('IGS','IGS_PE_CANT_SPECIFY_FROM_DATE');
              IGS_GE_MSG_STACK.ADD;
              APP_EXCEPTION.RAISE_EXCEPTION;
        END IF;
        IF p_start_dt IS NOT NULL THEN
          OPEN c_birth_date_val; FETCH c_birth_date_val INTO l_date_of_birth;
          CLOSE c_birth_date_val;
          IF(p_start_dt IS NOT NULL AND l_Date_of_birth IS NOT NULL) THEN
            IF(p_start_dt < l_date_of_birth) THEN
              Fnd_Message.Set_Name('IGS','IGS_PE_DREC_GT_BTDT');
              IGS_GE_MSG_STACK.ADD;
              App_Exception.Raise_Exception;
            END IF;
          END IF;
        END IF;

        p_location_rec_update.location_id               := p_location_id;
        p_location_rec_update.country                   := p_country;
        p_location_rec_update.address_style             := NVL(p_address_style,FND_API.G_MISS_CHAR);
        p_location_rec_update.address1                  := NVL(p_addr_line_1,FND_API.G_MISS_CHAR);
        p_location_rec_update.address2                  := NVL(p_addr_line_2,FND_API.G_MISS_CHAR);
        p_location_rec_update.address3                  := NVL(p_addr_line_3,FND_API.G_MISS_CHAR);
        p_location_rec_update.address4                  := NVL(p_addr_line_4,FND_API.G_MISS_CHAR);
        p_location_rec_update.city                      := NVL(p_city,FND_API.G_MISS_CHAR);
        p_location_rec_update.state                     := NVL(p_state,FND_API.G_MISS_CHAR);
        p_location_rec_update.province                  := NVL(p_province,FND_API.G_MISS_CHAR);
        p_location_rec_update.county                    := NVL(p_county,FND_API.G_MISS_CHAR);
        p_location_rec_update.postal_code               := NVL(p_postal_code,FND_API.G_MISS_CHAR);
        p_location_rec_update.address_lines_phonetic    := NVL(p_address_lines_phonetic,FND_API.G_MISS_CHAR);
        p_location_rec_update.delivery_point_code       := NVL(p_delivery_point_code,FND_API.G_MISS_CHAR);
        P_PARTY_SITE_REC_update.PARTY_ID                 :=     p_party_id;
        P_PARTY_SITE_REC_update.PARTY_SITE_ID            :=     p_party_site_id;
        P_PARTY_SITE_REC_update.LOCATION_ID              :=     p_location_id;
        P_PARTY_SITE_REC_update.IDENTIFYING_ADDRESS_FLAG :=     p_correspondence;
        P_PARTY_SITE_REC_update.status                   :=     p_status;

    HZ_LOCATION_V2PUB.update_location(
         P_INIT_MSG_LIST                        => p_init_msg_list,
         P_LOCATION_REC                         => p_location_rec_update,
	 p_do_addr_val				=> 'Y',
         p_object_version_number                => p_location_ovn,
	 x_addr_val_status			=> l_addr_val_status,
	 x_addr_warn_msg			=> l_addr_warn_msg,
	 X_RETURN_STATUS                        => l_return_status,
         X_MSG_COUNT                            => l_msg_count,
         X_MSG_DATA                             => l_msg_data
        );
        IF l_return_status in ('E', 'U') THEN
                --sbaliga added this code corresponding to IF condition as part of #2338473
            IF l_msg_count > 1 THEN
            FOR i IN 1..l_msg_count
             LOOP
             l_tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
             l_tmp_var1 := l_tmp_var1 || ' '|| l_tmp_var;
            END LOOP;
            l_msg_data := l_tmp_var1;
            END IF;
               RETURN;
        ELSIF l_return_status = 'S' THEN
            HZ_PARTY_SITE_V2PUB.UPDATE_PARTY_SITE(
                                  p_init_msg_list => p_init_msg_list,
                                  p_party_site_rec =>  p_party_site_rec_update,
                                  p_object_version_number => p_party_site_ovn,
                                  x_return_status => l_return_status,
                                  x_msg_count => l_msg_count,
                                  x_msg_data  => l_msg_data
                           );

        IF l_return_status ='E' or l_return_status ='U' THEN
        --ssawhney added this code corresponding to IF condition as part of #2338473
          IF l_msg_count > 1 THEN
            FOR i IN 1..l_msg_count LOOP
            l_tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
            l_tmp_var1 := l_tmp_var1 || ' '|| l_tmp_var;
            END LOOP;
          l_msg_data := l_tmp_var1;
          END IF;
          RETURN;
                -- remove code for creation of customer account site.
                -- ssawhney : 2225917
        ELSIF l_return_status = 'S' THEN
          OPEN   get_rowid(p_party_site_id);
          FETCH  get_rowid INTO lv_rowid,l_start_dt;
          CLOSE  get_rowid;

          IF p_start_dt IS NOT NULL OR l_start_dt IS NOT NULL THEN
              igs_pe_hz_pty_sites_pkg.add_row(x_rowid             => lv_rowid,
                                              x_party_site_id => p_party_site_id,
                                              x_start_date    => p_start_dt,
                                              x_end_date      => p_end_dt);

          END IF;  -- for party site.
        END IF; -- for rowid
    END IF;   -- success of update location

   IF l_addr_val_status = 'W' THEN
      l_msg_data := l_addr_warn_msg;
      l_return_status := l_addr_val_status;
   END IF;
END update_row;

END igs_pe_person_addr_pkg;

/
