--------------------------------------------------------
--  DDL for Package Body IGW_SETUP_PERSONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_SETUP_PERSONS_PVT" AS
--$Header: igwvspeb.pls 115.5 2002/11/15 00:48:33 ashkumar noship $

PROCEDURE CREATE_PERSON (
p_init_msg_list     		IN VARCHAR2   := Fnd_Api.G_False,
p_validate_only     		IN VARCHAR2   := Fnd_Api.G_False,
p_commit            		IN VARCHAR2   := Fnd_Api.G_False,
p_status			IN VARCHAR2,
p_person_pre_name_adjunct	IN VARCHAR2,
p_person_first_name 		IN VARCHAR2,
p_person_middle_name  		IN VARCHAR2,
p_person_last_name  		IN VARCHAR2,
p_ssn				IN VARCHAR2,
p_date_of_birth			IN DATE,
p_address1          		IN VARCHAR2,
p_address2          		IN VARCHAR2,
p_address3          		IN VARCHAR2,
p_city              		IN VARCHAR2,
p_state             		IN VARCHAR2,
p_postal_code       		IN VARCHAR2,
p_county            		IN VARCHAR2,
p_country_name      		IN VARCHAR2,
p_country_code                  IN VARCHAR2,
x_party_id          		OUT NOCOPY NUMBER,
x_return_status     		OUT NOCOPY VARCHAR2,
x_msg_count         		OUT NOCOPY NUMBER,
x_msg_data          		OUT NOCOPY VARCHAR2) IS


      x_party_number	      VARCHAR2(30);
      x_profile_id	      NUMBER;
      x_location_id	      NUMBER;
      l_party_site_id	      NUMBER;
      l_country_code          VARCHAR2(2) := p_country_code;
      l_party_site_number     VARCHAR2(30);
      l_party_rec	      HZ_PARTY_V2PUB.PARTY_REC_TYPE;
      l_person_rec            HZ_PARTY_V2PUB.PERSON_REC_TYPE;
      l_location_rec          HZ_LOCATION_V2PUB.LOCATION_REC_TYPE;
      l_party_site_rec        HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE;

   BEGIN
      IF Fnd_Api.To_Boolean(p_commit) THEN
           SAVEPOINT Create_Person_Pvt;
      END IF;

      x_return_status := Fnd_Api.G_Ret_Sts_Success;

      IF Fnd_Api.To_Boolean(p_init_msg_list) THEN
         Fnd_Msg_Pub.Initialize;
      END IF;

      -- get country_code from country_name if country_code is null
      if (p_country_name is null) then
           l_country_code := null;
      else
           GET_COUNTRY_CODE(p_country_name   =>   p_country_name,
                            x_country_code   =>   l_country_code);
      end if;
      check_errors;

      l_person_rec.person_pre_name_adjunct := p_person_pre_name_adjunct;
      l_person_rec.person_first_name := p_person_first_name;
      l_person_rec.person_middle_name := p_person_middle_name;
      l_person_rec.person_last_name := p_person_last_name;
      l_person_rec.jgzz_fiscal_code := p_ssn;
      l_person_rec.date_of_birth := p_date_of_birth;
      l_person_rec.created_by_module := 'IGW';

      l_party_rec.orig_system_reference := 'IGW';
      l_party_rec.status := p_status;

      IF Fnd_Profile.Value_Wnps('HZ_GENERATE_PARTY_NUMBER') = 'N' THEN
         SELECT to_char(hz_party_number_s.nextval)
         INTO   l_party_rec.party_number
         FROM   dual;
      END IF;

      l_person_rec.party_rec := l_party_rec;


      Hz_Party_V2pub.Create_Person
      (
         p_init_msg_list     => FND_API.g_false,
         p_person_rec	     =>	l_person_rec,
         x_party_id         => x_party_id,
         x_party_number     => x_party_number,
         x_profile_id       => x_profile_id,
         X_RETURN_STATUS    => X_RETURN_STATUS,
         X_MSG_COUNT        => X_MSG_COUNT,
         X_MSG_DATA         => X_MSG_DATA
      );
      check_errors;

      l_location_rec.address1 := p_address1;
      l_location_rec.address2 := p_address2;
      l_location_rec.address3 := p_address3;
      l_location_rec.city := p_city;
      l_location_rec.state := p_state;
      l_location_rec.postal_code := p_postal_code;
      l_location_rec.county  := p_county;
      l_location_rec.country := l_country_code;
      l_location_rec.orig_system_reference := 'IGW';
      l_location_rec.created_by_module := 'IGW';

      Hz_Location_V2pub.Create_Location
      (
         P_INIT_MSG_LIST     => FND_API.g_false,
         p_location_rec      => l_location_rec,
         x_location_id       => x_location_id,
         X_RETURN_STATUS     => X_RETURN_STATUS,
         X_MSG_COUNT         => X_MSG_COUNT,
         X_MSG_DATA          => X_MSG_DATA
      );
      check_errors;

      l_party_site_rec.party_id  := x_party_id;
      l_party_site_rec.location_id  := x_location_id;
      l_party_site_rec.identifying_address_flag := 'Y';
      l_party_site_rec.orig_system_reference := 'IGW';
      l_party_site_rec.created_by_module := 'IGW';

      IF Fnd_Profile.Value_Wnps('HZ_GENERATE_PARTY_SITE_NUMBER') = 'N' THEN
         SELECT to_char(hz_party_site_number_s.nextval)
         INTO   l_party_site_rec.party_site_number
         FROM   dual;
      END IF;

      Hz_Party_Site_V2pub.Create_Party_Site
      (
         P_INIT_MSG_LIST     => FND_API.g_false,
         p_party_site_rec    => l_party_site_rec,
         x_party_site_id     => l_party_site_id,
         x_party_site_number => l_party_site_number,
         X_RETURN_STATUS    => X_RETURN_STATUS,
         X_MSG_COUNT        => X_MSG_COUNT,
         X_MSG_DATA         => X_MSG_DATA
      );

      check_errors;



      IF Fnd_Api.To_Boolean(p_commit) THEN

         COMMIT;

      END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF p_commit = FND_API.G_TRUE THEN
              ROLLBACK TO Create_Person_Pvt;
        END IF;

        x_return_status := FND_API.G_RET_STS_ERROR;

        fnd_msg_pub.count_and_get(p_count	=>	x_msg_count,
   			          p_data	=>	x_msg_data);


  WHEN OTHERS THEN
       IF p_commit = FND_API.G_TRUE THEN
              ROLLBACK TO Create_Person_Pvt;
       END IF;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       fnd_msg_pub.add_exc_msg(p_pkg_name       =>    'IGW_SETUP_PERSONS_PVT',
                            p_procedure_name    =>    'CREATE_PERSON',
                            p_error_text        =>     SUBSTRB(SQLERRM,1,240));

       fnd_msg_pub.count_and_get(p_count	=>	x_msg_count,
   			          p_data	=>	x_msg_data);


   END CREATE_PERSON;

--------------------------------------------------------------------------------------------------------
PROCEDURE UPDATE_PERSON (
p_init_msg_list     			IN VARCHAR2   := Fnd_Api.G_False,
p_validate_only     			IN VARCHAR2   := Fnd_Api.G_False,
p_commit            			IN VARCHAR2   := Fnd_Api.G_False,
p_party_id				IN NUMBER,
p_location_id  				IN NUMBER,
p_status				IN VARCHAR2,
p_person_pre_name_adjunct		IN VARCHAR2,
p_person_first_name 			IN VARCHAR2,
p_person_middle_name  			IN VARCHAR2,
p_person_last_name  			IN VARCHAR2,
p_ssn					IN VARCHAR2,
p_date_of_birth				IN DATE,
p_address1          			IN VARCHAR2,
p_address2          			IN VARCHAR2,
p_address3          			IN VARCHAR2,
p_city              			IN VARCHAR2,
p_state             			IN VARCHAR2,
p_postal_code       			IN VARCHAR2,
p_county            			IN VARCHAR2,
p_country_name      			IN VARCHAR2,
p_country_code                  	IN VARCHAR2,
p_party_object_version_number   	IN NUMBER,
p_loc_object_version_number		IN NUMBER,
x_return_status     			OUT NOCOPY VARCHAR2,
x_msg_count         			OUT NOCOPY NUMBER,
x_msg_data          			OUT NOCOPY VARCHAR2) IS

      l_party_object_version_number     NUMBER := p_party_object_version_number;
      l_loc_object_version_number       NUMBER := p_party_object_version_number;
      x_profile_id	      		NUMBER;
      x_location_id	      		NUMBER;
      l_party_site_id	      		NUMBER;
      l_country_code          		VARCHAR2(2) := p_country_code;
      l_party_site_number     		VARCHAR2(30);
      l_party_rec	      		HZ_PARTY_V2PUB.PARTY_REC_TYPE;
      l_person_rec            		HZ_PARTY_V2PUB.PERSON_REC_TYPE;
      l_location_rec          		HZ_LOCATION_V2PUB.LOCATION_REC_TYPE;
      l_party_site_rec        		HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE;

   BEGIN
      IF Fnd_Api.To_Boolean(p_commit) THEN
           SAVEPOINT Update_Person_Pvt;
      END IF;

      x_return_status := Fnd_Api.G_Ret_Sts_Success;

      IF Fnd_Api.To_Boolean(p_init_msg_list) THEN
         Fnd_Msg_Pub.Initialize;
      END IF;

      -- get country_code from country_name if country_code is null
      if (p_country_name is null) then
          l_country_code := null;
      else
           GET_COUNTRY_CODE(p_country_name   =>   p_country_name,
                            x_country_code   =>   l_country_code);
      end if;
      check_errors;

      l_party_rec.orig_system_reference := 'IGW';
      l_party_rec.party_id := p_party_id;
      l_party_rec.status := p_status;

      l_person_rec.person_pre_name_adjunct := p_person_pre_name_adjunct;
      l_person_rec.person_first_name := p_person_first_name;
      l_person_rec.person_middle_name := p_person_middle_name;
      l_person_rec.person_last_name := p_person_last_name;
      l_person_rec.jgzz_fiscal_code := p_ssn;
      l_person_rec.date_of_birth := p_date_of_birth;
      l_person_rec.created_by_module := 'IGW';
      l_person_rec.party_rec := l_party_rec;


      Hz_Party_V2pub.Update_Person
      (
         p_init_msg_list     		   => FND_API.g_false,
         p_person_rec	     		   => l_person_rec,
         p_party_object_version_number     => l_party_object_version_number,
         x_profile_id       		   => x_profile_id,
         X_RETURN_STATUS    		   => X_RETURN_STATUS,
         X_MSG_COUNT        		   => X_MSG_COUNT,
         X_MSG_DATA         		   => X_MSG_DATA
      );
      check_errors;

      l_location_rec.location_id := p_location_id;
      l_location_rec.address1 := p_address1;
      l_location_rec.address2 := p_address2;
      l_location_rec.address3 := p_address3;
      l_location_rec.city := p_city;
      l_location_rec.state := p_state;
      l_location_rec.postal_code := p_postal_code;
      l_location_rec.county  := p_county;
      l_location_rec.country := l_country_code;
      l_location_rec.orig_system_reference := 'IGW';
      l_location_rec.created_by_module := 'IGW';

      Hz_Location_V2pub.Update_Location
      (
         P_INIT_MSG_LIST     			=> FND_API.g_false,
         p_location_rec      			=> l_location_rec,
         p_object_version_number                => l_loc_object_version_number,
         X_RETURN_STATUS     			=> X_RETURN_STATUS,
         X_MSG_COUNT         			=> X_MSG_COUNT,
         X_MSG_DATA          			=> X_MSG_DATA
      );
      check_errors;

      IF Fnd_Api.To_Boolean(p_commit) THEN

         COMMIT;

      END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF p_commit = FND_API.G_TRUE THEN
              ROLLBACK TO Update_Person_Pvt;
        END IF;

        x_return_status := FND_API.G_RET_STS_ERROR;

        fnd_msg_pub.count_and_get(p_count	=>	x_msg_count,
   			          p_data	=>	x_msg_data);


  WHEN OTHERS THEN
       IF p_commit = FND_API.G_TRUE THEN
              ROLLBACK TO Update_Person_Pvt;
       END IF;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       fnd_msg_pub.add_exc_msg(p_pkg_name       =>    'IGW_SETUP_PERSONS_PVT',
                            p_procedure_name    =>    'UPDATE_PERSON',
                            p_error_text        =>     SUBSTRB(SQLERRM,1,240));

       fnd_msg_pub.count_and_get(p_count	=>	x_msg_count,
   			          p_data	=>	x_msg_data);


END UPDATE_PERSON;

-----------------------------------------------------------------------------------------
PROCEDURE GET_COUNTRY_CODE (P_COUNTRY_NAME         IN    	VARCHAR2,
			    X_COUNTRY_CODE	   OUT NOCOPY          VARCHAR2) IS


l_country_code      VARCHAR2(2);
BEGIN
select territory_code
into l_country_code
from fnd_territories_vl
where upper(territory_short_name) = upper(p_country_name);

x_country_code := l_country_code;

exception
when no_data_found then
          FND_MESSAGE.SET_NAME('IGW','IGW_SS_COUNTRY_INVALID');
          FND_MSG_PUB.Add;
          raise fnd_api.g_exc_error;
when too_many_rows then
          FND_MESSAGE.SET_NAME('IGW','IGW_SS_COUNTRY_INVALID');
          FND_MSG_PUB.Add;
          raise fnd_api.g_exc_error;
when others then
          fnd_msg_pub.add_exc_msg(p_pkg_name       => 'IGW_SETUP_PERSONS_PVT',
                            	  p_procedure_name => 'GET_COUNTRY_CODE',
                            	  p_error_text     => SUBSTRB(SQLERRM,1,240));
          raise fnd_api.g_exc_unexpected_error;

END GET_COUNTRY_CODE;


----------------------------------------------------------------------------------------------
PROCEDURE CHECK_ERRORS is
 l_msg_count 	NUMBER;
 BEGIN
       	l_msg_count := fnd_msg_pub.count_msg;
        IF (l_msg_count > 0) THEN
              RAISE  FND_API.G_EXC_ERROR;
        END IF;

 END CHECK_ERRORS;


END IGW_SETUP_PERSONS_PVT;

/
