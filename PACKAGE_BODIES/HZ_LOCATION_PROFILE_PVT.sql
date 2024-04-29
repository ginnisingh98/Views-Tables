--------------------------------------------------------
--  DDL for Package Body HZ_LOCATION_PROFILE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_LOCATION_PROFILE_PVT" AS
/*$Header: ARHLCPVB.pls 120.15 2006/06/28 17:41:23 baianand noship $*/

PROCEDURE log(
   message      IN      VARCHAR2,
   newline      IN      BOOLEAN DEFAULT TRUE);

FUNCTION logerror(SQLERRM VARCHAR2 DEFAULT NULL)
         RETURN VARCHAR2;

PROCEDURE set_profile_rec_type (
   p_location_profile_rec      IN OUT NOCOPY LOCATION_PROFILE_REC_TYPE
);

PROCEDURE set_profile_rec_type (
   p_location_profile_rec      IN OUT NOCOPY LOCATION_PROFILE_REC_TYPE
) IS

   -- cursor to get address component when inserting a new row to location profile
   CURSOR get_address_component(l_location_id NUMBER) IS
   SELECT hl.country, hl.address1, hl.address2, hl.address3,
          hl.address4, hl.city, hl.postal_code, hl.state,
          hl.province, hl.county, hl.actual_content_source,
          hl.validation_status_code, hl.date_validated
   FROM   hz_locations hl
   WHERE  hl.location_id = l_location_id;

   l_location_profile_rec      location_profile_rec_type;
   db_country                  HZ_LOCATIONS.COUNTRY%TYPE;
   db_county                   HZ_LOCATIONS.COUNTY%TYPE;
   db_validation_status_code   HZ_LOCATIONS.VALIDATION_STATUS_CODE%TYPE;
   db_date_validated           HZ_LOCATIONS.DATE_VALIDATED%TYPE;
   db_address1                 HZ_LOCATIONS.ADDRESS1%TYPE;
   db_address2                 HZ_LOCATIONS.ADDRESS2%TYPE;
   db_address3                 HZ_LOCATIONS.ADDRESS3%TYPE;
   db_address4                 HZ_LOCATIONS.ADDRESS4%TYPE;
   db_city                     HZ_LOCATIONS.CITY%TYPE;
   db_postal_code              HZ_LOCATIONS.POSTAL_CODE%TYPE;
   db_state                    HZ_LOCATIONS.STATE%TYPE;
   db_province                 HZ_LOCATIONS.PROVINCE%TYPE;
   db_content_source           HZ_LOCATIONS.ACTUAL_CONTENT_SOURCE%TYPE;

BEGIN

   l_location_profile_rec := p_location_profile_rec;

   OPEN get_address_component(l_location_profile_rec.location_id);
   FETCH get_address_component INTO db_country, db_address1, db_address2, db_address3,
     db_address4, db_city, db_postal_code, db_state, db_province, db_county,
     db_content_source, db_validation_status_code, db_date_validated;
   CLOSE get_address_component;

   IF (l_location_profile_rec.validation_status_code IS NULL) THEN
     l_location_profile_rec.validation_status_code := db_validation_status_code;
   END IF;
   IF (l_location_profile_rec.date_validated IS NULL) THEN
     l_location_profile_rec.date_validated := db_date_validated;
   END IF;
   IF (l_location_profile_rec.address1 IS NULL) THEN
     l_location_profile_rec.address1 := db_address1;
   END IF;
   IF (l_location_profile_rec.address2 IS NULL) THEN
     l_location_profile_rec.address2 := db_address2;
   END IF;
   IF (l_location_profile_rec.address3 IS NULL) THEN
     l_location_profile_rec.address3 := db_address3;
   END IF;
   IF (l_location_profile_rec.address4 IS NULL) THEN
     l_location_profile_rec.address4 := db_address4;
   END IF;
   IF (l_location_profile_rec.city IS NULL) THEN
     l_location_profile_rec.city := db_city;
   END IF;
   IF (l_location_profile_rec.postal_code IS NULL) THEN
     l_location_profile_rec.postal_code := db_postal_code;
   END IF;
   IF (l_location_profile_rec.county IS NULL) THEN
     l_location_profile_rec.county := db_county;
   END IF;
   IF (l_location_profile_rec.country IS NULL) THEN
     l_location_profile_rec.country := db_country;
   END IF;
   IF (l_location_profile_rec.prov_state_admin_code IS NULL) THEN
     IF (db_state IS NULL) THEN
       l_location_profile_rec.prov_state_admin_code := db_province;
     ELSE
       l_location_profile_rec.prov_state_admin_code := db_state;
     END IF;
   END IF;

   p_location_profile_rec := l_location_profile_rec;

END set_profile_rec_type;

PROCEDURE create_location_profile (
   p_init_msg_list             IN VARCHAR2 := FND_API.G_FALSE
  ,p_location_profile_rec      IN  location_profile_rec_type
  ,x_location_profile_id       OUT NOCOPY    NUMBER
  ,x_return_status             OUT NOCOPY    VARCHAR2
  ,x_msg_count                 OUT NOCOPY    NUMBER
  ,x_msg_data                  OUT NOCOPY    VARCHAR2
) IS
  l_location_profile_rec   location_profile_rec_type;
  l_end_date               DATE;
  l_start_date             DATE;
BEGIN

  savepoint create_location_profile_pub;

  -- initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  --Initialize API return status to success.
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_start_date := NVL(p_location_profile_rec.effective_start_date,sysdate);
  l_end_date := NVL(p_location_profile_rec.effective_end_date,to_date('4712.12.31 00:01','YYYY.MM.DD HH24:MI'));

  validate_mandatory_column(
    p_create_update_flag        => 'C'
   ,p_location_profile_rec      => p_location_profile_rec
   ,x_return_status             => x_return_status );

  --Should check if profile already exist

  IF(x_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF(x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_location_profile_rec := p_location_profile_rec;

  IF(l_location_profile_rec.validation_sst_flag = 'N') THEN
    l_end_date := sysdate;
  END IF;

  HZ_LOCATION_PROFILES_PKG.Insert_Row (
       x_location_profile_id            => l_location_profile_rec.location_profile_id
      ,x_location_id                    => l_location_profile_rec.location_id
      ,x_actual_content_source          => l_location_profile_rec.actual_content_source
      ,x_effective_start_date           => l_start_date
      ,x_effective_end_date             => l_end_date
      ,x_validation_sst_flag            => l_location_profile_rec.validation_sst_flag
      ,x_validation_status_code         => l_location_profile_rec.validation_status_code
      ,x_date_validated                 => l_location_profile_rec.date_validated
      ,x_address1                       => l_location_profile_rec.address1
      ,x_address2                       => l_location_profile_rec.address2
      ,x_address3                       => l_location_profile_rec.address3
      ,x_address4                       => l_location_profile_rec.address4
      ,x_city                           => l_location_profile_rec.city
      ,x_postal_code                    => l_location_profile_rec.postal_code
      ,x_prov_state_admin_code          => l_location_profile_rec.prov_state_admin_code
      ,x_county                         => l_location_profile_rec.county
      ,x_country                        => l_location_profile_rec.country
      ,x_object_version_number          => 1
  );

  x_location_profile_id := l_location_profile_rec.location_profile_id;

  -- denormalize validation_status_code to HZ_LOCATIONS

-- SSM SST Integration and Extension
-- Changed the hard coded value of DNB and instead will check if the content source is of type 'PURCHASED'.

--IF(NOT(l_location_profile_rec.actual_content_source in ('USER_ENTERED','DNB'))) THEN
  IF(NOT(l_location_profile_rec.actual_content_source = 'USER_ENTERED' OR
         HZ_UTILITY_V2PUB.is_purchased_content_source(l_location_profile_rec.actual_content_source) = 'Y'      )
    ) THEN
    UPDATE HZ_LOCATIONS
    SET date_validated = sysdate
      , validation_status_code = l_location_profile_rec.validation_status_code
      , last_update_date = hz_utility_v2pub.last_update_date
      , last_updated_by = hz_utility_v2pub.last_updated_by
      , last_update_login = hz_utility_v2pub.last_update_login
    WHERE location_id = l_location_profile_rec.location_id;
  END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO create_location_profile_pub;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO create_location_profile_pub;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

   WHEN OTHERS THEN
     ROLLBACK TO create_location_profile_pub;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);
END create_location_profile;

-- This procedure update a record in location profile
PROCEDURE update_location_profile (
   p_init_msg_list             IN VARCHAR2 := FND_API.G_FALSE
  ,p_location_profile_rec      IN location_profile_rec_type
--  ,px_object_version_number    IN OUT NOCOPY NUMBER
  ,x_return_status             OUT NOCOPY    VARCHAR2
  ,x_msg_count                 OUT NOCOPY    NUMBER
  ,x_msg_data                  OUT NOCOPY    VARCHAR2
) IS
   l_object_version_number     NUMBER;
   l_location_profile_rec      location_profile_rec_type;
   l_validation_sst_flag       VARCHAR2(1);
   l_rowid                     ROWID := NULL;
   l_dummy                     VARCHAR2(1);
   l_maintain_history          VARCHAR2(1);
   l_allow_update_std          VARCHAR2(1);
   l_found_profile             VARCHAR2(1);
   l_end_date                  DATE;
   l_orig_sst_flag             VARCHAR2(1);

   -- check if there exist profile record for the location from the same content source
   -- Fix for bug 5189929 - Added .001 to sysdate while looking for active records
   CURSOR is_profile_exist(l_location_id NUMBER, l_content_source VARCHAR2) IS
   SELECT 'X'
   FROM hz_location_profiles
   WHERE location_id = l_location_id
   AND actual_content_source = l_content_source
   AND sysdate+.001 between effective_start_date and nvl(effective_end_date, sysdate)
   AND rownum = 1;

   -- check if the current location record has been validated
   CURSOR is_standardized(l_location_id NUMBER) IS
   SELECT 'X'
   FROM hz_locations
   WHERE location_id = l_location_id
   AND date_validated IS NOT NULL
   AND validation_status_code IS NOT NULL;

   cursor c_all_active_loc_profiles(c_location_id NUMBER, c_location_profile_id NUMBER) is
   select location_profile_id, rowid, object_version_number
   from   hz_location_profiles
   where  sysdate between effective_start_date and nvl(effective_end_date, sysdate)
   and    location_id = c_location_id
   and    location_profile_id <> c_location_profile_id;

   l_enddate_other_active      VARCHAR2(1);
   l_enddate                   DATE;
   l_startdate                 DATE;

BEGIN

   savepoint update_location_profile_pub;

   -- initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(p_init_msg_list) THEN
     FND_MSG_PUB.initialize;
   END IF;

   --Initialize API return status to success.
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   l_maintain_history := nvl(fnd_profile.value('HZ_MAINTAIN_LOC_HISTORY'),'Y');
   l_allow_update_std := nvl(fnd_profile.value('HZ_UPDATE_STD_ADDRESS'), 'Y');
   l_location_profile_rec := p_location_profile_rec;

   l_end_date := NVL(p_location_profile_rec.effective_end_date,to_date('4712.12.31 00:01','YYYY.MM.DD HH24:MI'));
   l_enddate_other_active := 'N';

   OPEN is_standardized(l_location_profile_rec.location_id);
   FETCH is_standardized INTO l_dummy;
   CLOSE is_standardized;

   -- location has been validated before and profile is set to 'N'
   -- only if validation_sst_flag is not passed
   IF(l_location_profile_rec.validation_sst_flag IS NULL) THEN
     IF((l_allow_update_std = 'N') AND (l_dummy IS NOT NULL)) THEN
       l_validation_sst_flag := 'N';
     ELSE
       l_validation_sst_flag := 'Y';
     END IF;
   ELSE
     l_validation_sst_flag := l_location_profile_rec.validation_sst_flag;
   END IF;

   OPEN is_profile_exist(l_location_profile_rec.location_id,
                         l_location_profile_rec.actual_content_source);
   FETCH is_profile_exist INTO l_found_profile;
   CLOSE is_profile_exist;

   validate_mandatory_column(
      p_create_update_flag        => 'U'
     ,p_location_profile_rec      => l_location_profile_rec
     ,x_return_status             => x_return_status );

   -- find the profile of the content source
   IF(l_found_profile IS NOT NULL) THEN
     -- not maintain history
     IF(l_maintain_history = 'N') THEN

       -- Fix for bug 5189929 - Added .001 to sysdate while looking for active records
       SELECT rowid, object_version_number, validation_sst_flag
       INTO l_rowid, l_object_version_number, l_orig_sst_flag
       FROM hz_location_profiles
       WHERE location_id = l_location_profile_rec.location_id
       AND actual_content_source = l_location_profile_rec.actual_content_source
       AND sysdate+.001 between effective_start_date and nvl(effective_end_date,sysdate)
       AND rownum = 1
       FOR UPDATE NOWAIT;

       -- only update location profile if the sst flag is set to 'Y'
       IF(l_validation_sst_flag = 'Y') OR (l_orig_sst_flag = 'N') THEN

         IF(x_return_status = FND_API.G_RET_STS_ERROR) THEN
           RAISE FND_API.G_EXC_ERROR;
         ELSIF(x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         HZ_LOCATION_PROFILES_PKG.Update_Row(
            x_rowid                          => l_rowid
           ,x_location_profile_id            => NULL
           ,x_location_id                    => NULL
           ,x_actual_content_source          => NULL
           ,x_effective_start_date           => NULL
           ,x_effective_end_date             => l_end_date
           ,x_validation_sst_flag            => l_validation_sst_flag
           ,x_validation_status_code         => l_location_profile_rec.validation_status_code
           ,x_date_validated                 => l_location_profile_rec.date_validated
           ,x_address1                       => l_location_profile_rec.address1
           ,x_address2                       => l_location_profile_rec.address2
           ,x_address3                       => l_location_profile_rec.address3
           ,x_address4                       => l_location_profile_rec.address4
           ,x_city                           => l_location_profile_rec.city
           ,x_postal_code                    => l_location_profile_rec.postal_code
           ,x_prov_state_admin_code          => l_location_profile_rec.prov_state_admin_code
           ,x_county                         => l_location_profile_rec.county
           ,x_country                        => l_location_profile_rec.country
           ,x_object_version_number          => nvl(l_object_version_number,1)+1
         );

       END IF;

     ELSE -- maintain history is 'Y'

       IF(x_return_status = FND_API.G_RET_STS_ERROR) THEN
         RAISE FND_API.G_EXC_ERROR;
       ELSIF(x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

       -- need to check the existing sst flag of the location profile
       -- if Y: do not update existing location profiles
       -- if N: update existing location profiles
       -- Fix for bug 5189929 - Added .001 to sysdate while looking for active records
       SELECT rowid, object_version_number, validation_sst_flag
       INTO l_rowid, l_object_version_number, l_orig_sst_flag
       FROM hz_location_profiles
       WHERE location_id = l_location_profile_rec.location_id
       AND actual_content_source = l_location_profile_rec.actual_content_source
       AND sysdate+.001 between effective_start_date and nvl(effective_end_date,sysdate)
       AND rownum = 1
       FOR UPDATE NOWAIT;

       -- only end date the existing profile record if validation_sst_flag
       -- is 'Y' or original sst flag is 'N'
       -- otherwise, don't update existing profile record and then just
       -- insert new location profile record.  In this case, validation_sst_flag
       -- is always 'N'.
       IF(l_validation_sst_flag = 'Y') OR (l_orig_sst_flag = 'N') THEN
         HZ_LOCATION_PROFILES_PKG.Update_Row(
            x_rowid                          => l_rowid
           ,x_location_profile_id            => NULL
           ,x_location_id                    => NULL
           ,x_actual_content_source          => NULL
           ,x_effective_start_date           => NULL
           ,x_effective_end_date             => sysdate
           ,x_validation_sst_flag            => NULL
           ,x_validation_status_code         => NULL
           ,x_date_validated                 => NULL
           ,x_address1                       => NULL
           ,x_address2                       => NULL
           ,x_address3                       => NULL
           ,x_address4                       => NULL
           ,x_city                           => NULL
           ,x_postal_code                    => NULL
           ,x_prov_state_admin_code          => NULL
           ,x_county                         => NULL
           ,x_country                        => NULL
           ,x_object_version_number          => nvl(l_object_version_number,1)+1
        );
      ELSE
        l_end_date := sysdate;
      END IF;

      -- get database value if caller program pass NULL to address component
      -- when passing NULL, it means that caller does not want to update the
      -- value
      set_profile_rec_type(l_location_profile_rec);

      HZ_LOCATION_PROFILES_PKG.Insert_Row (
          x_location_profile_id            => l_location_profile_rec.location_profile_id
         ,x_location_id                    => l_location_profile_rec.location_id
         ,x_actual_content_source          => l_location_profile_rec.actual_content_source
         ,x_effective_start_date           => sysdate
         ,x_effective_end_date             => l_end_date
         ,x_validation_sst_flag            => l_validation_sst_flag
         ,x_validation_status_code         => l_location_profile_rec.validation_status_code
         ,x_date_validated                 => l_location_profile_rec.date_validated
         ,x_address1                       => l_location_profile_rec.address1
         ,x_address2                       => l_location_profile_rec.address2
         ,x_address3                       => l_location_profile_rec.address3
         ,x_address4                       => l_location_profile_rec.address4
         ,x_city                           => l_location_profile_rec.city
         ,x_postal_code                    => l_location_profile_rec.postal_code
         ,x_prov_state_admin_code          => l_location_profile_rec.prov_state_admin_code
         ,x_county                         => l_location_profile_rec.county
         ,x_country                        => l_location_profile_rec.country
         ,x_object_version_number          => 1
       );

     END IF;

   ELSE  -- cannot find the content source in profile

     IF(x_return_status = FND_API.G_RET_STS_ERROR) THEN
       RAISE FND_API.G_EXC_ERROR;
     ELSIF(x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

      -- get database value if caller program pass NULL to address component
      -- when passing NULL, it means that caller does not want to update the
      -- value
     set_profile_rec_type(l_location_profile_rec);

     if l_validation_sst_flag = 'N' then
        l_enddate_other_active := 'N';
        l_startdate := sysdate-1;
        l_enddate := sysdate-1;
     else
        l_enddate_other_active := 'Y';
        l_startdate := sysdate;
        l_enddate := l_end_date;
     end if;

     HZ_LOCATION_PROFILES_PKG.Insert_Row (
        x_location_profile_id            => l_location_profile_rec.location_profile_id
       ,x_location_id                    => l_location_profile_rec.location_id
       ,x_actual_content_source          => l_location_profile_rec.actual_content_source
       ,x_effective_start_date           => l_startdate
       ,x_effective_end_date             => l_enddate
       ,x_validation_sst_flag            => l_validation_sst_flag
       ,x_validation_status_code         => l_location_profile_rec.validation_status_code
       ,x_date_validated                 => l_location_profile_rec.date_validated
       ,x_address1                       => l_location_profile_rec.address1
       ,x_address2                       => l_location_profile_rec.address2
       ,x_address3                       => l_location_profile_rec.address3
       ,x_address4                       => l_location_profile_rec.address4
       ,x_city                           => l_location_profile_rec.city
       ,x_postal_code                    => l_location_profile_rec.postal_code
       ,x_prov_state_admin_code          => l_location_profile_rec.prov_state_admin_code
       ,x_county                         => l_location_profile_rec.county
       ,x_country                        => l_location_profile_rec.country
       ,x_object_version_number          => 1
     );

   END IF;

   -- denormalize validation_status_code to HZ_LOCATIONS only if location can be updated

   -- SSM SST Integration and Extension
   -- Instead of hard-coding, check if source system is of type PURCHASED.

 --IF(NOT(l_location_profile_rec.actual_content_source in ('USER_ENTERED','DNB'))) THEN
   IF (NOT(l_location_profile_rec.actual_content_source = 'USER_ENTERED' OR
             HZ_UTILITY_V2PUB.is_purchased_content_source(l_location_profile_rec.actual_content_source)= 'Y'     )
      )THEN
     -- if update standardized is ok, then update HZ_LOCATIONS, otherwise do nothing
     IF(l_validation_sst_flag = 'Y') THEN
       UPDATE HZ_LOCATIONS
       SET date_validated = sysdate,
           validation_status_code = l_location_profile_rec.validation_status_code
       WHERE location_id = l_location_profile_rec.location_id;

       BEGIN
         UPDATE HZ_LOCATION_PROFILES
         SET validation_sst_flag = 'N'
         WHERE validation_sst_flag = 'Y'
         AND sysdate between effective_start_date and nvl(effective_end_date, sysdate)
	 /* SSM SST Integration and Extension
	  * Removed the hard-coded value of DNB and will instead check if the
	  * source system is not of type PURCHASED.

         AND actual_content_source <> l_location_profile_rec.actual_content_source
         AND actual_content_source not in ('USER_ENTERED','DNB');*/

         AND actual_content_source NOT IN ( l_location_profile_rec.actual_content_source, 'USER_ENTERED')
         AND HZ_UTILITY_V2PUB.is_purchased_content_source(actual_content_source) = 'N'
         AND location_id = l_location_profile_rec.location_id;

       EXCEPTION
         WHEN NO_DATA_FOUND THEN
           NULL;
       END;
     END IF;
   ELSE  -- nullify if actual_content_source in ('USER_ENTERED', 'DNB')
     IF(l_validation_sst_flag = 'Y') THEN
       UPDATE HZ_LOCATIONS
       SET date_validated = null,
           validation_status_code = null
       WHERE location_id = l_location_profile_rec.location_id;
     END IF;
   END IF;

   IF (l_enddate_other_active = 'Y') then
      for l_all_active_loc_profiles in c_all_active_loc_profiles(l_location_profile_rec.location_id,l_location_profile_rec.location_profile_id) loop
         HZ_LOCATION_PROFILES_PKG.Update_Row(
            x_rowid                          => l_all_active_loc_profiles.rowid
           ,x_location_profile_id            => l_all_active_loc_profiles.location_profile_id
           ,x_location_id                    => NULL
           ,x_actual_content_source          => NULL
           ,x_effective_start_date           => NULL
           ,x_effective_end_date             => sysdate
           ,x_validation_sst_flag            => NULL
           ,x_validation_status_code         => NULL
           ,x_date_validated                 => NULL
           ,x_address1                       => NULL
           ,x_address2                       => NULL
           ,x_address3                       => NULL
           ,x_address4                       => NULL
           ,x_city                           => NULL
           ,x_postal_code                    => NULL
           ,x_prov_state_admin_code          => NULL
           ,x_county                         => NULL
           ,x_country                        => NULL
           ,x_object_version_number          => nvl(l_all_active_loc_profiles.object_version_number,1)+1
        );
      end loop;
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO update_location_profile_pub;
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO update_location_profile_pub;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);

   WHEN OTHERS THEN
     ROLLBACK TO update_location_profile_pub;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data);
END update_location_profile;

PROCEDURE validate_mandatory_column (
   p_create_update_flag        IN VARCHAR2,
   p_location_profile_rec      IN location_profile_rec_type,
   x_return_status             IN OUT NOCOPY VARCHAR2
) IS

   l_dummy                     VARCHAR2(1);
   l_actual_content_source     VARCHAR2(30);
   l_location_id               NUMBER;
   l_location_profile_id       NUMBER;
   l_address1                  VARCHAR2(240);
   l_effective_start_date      DATE;
   l_validation_sst_flag       VARCHAR2(1);
   l_country                   VARCHAR2(2);

   CURSOR check_lookup(l_lookup_code VARCHAR2, l_lookup_type VARCHAR2) IS
   select 'X'
   from AR_LOOKUPS
   where lookup_type = l_lookup_type
   and lookup_code = l_lookup_code;

BEGIN

   l_actual_content_source  := p_location_profile_rec.actual_content_source;
   l_location_profile_id    := p_location_profile_rec.location_profile_id;
   l_location_id            := p_location_profile_rec.location_id;
   l_address1               := p_location_profile_rec.address1;
   l_country                := p_location_profile_rec.country;
   l_effective_start_date   := p_location_profile_rec.effective_start_date;
   l_validation_sst_flag    := p_location_profile_rec.validation_sst_flag;

   IF(l_location_id IS NULL OR l_location_id = FND_API.G_MISS_NUM) THEN
     FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
     FND_MESSAGE.SET_TOKEN('COLUMN' ,'LOCATION_ID');
     FND_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF (p_create_update_flag = 'U') THEN
     IF(l_actual_content_source = FND_API.G_MISS_CHAR) THEN
       FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
       FND_MESSAGE.SET_TOKEN('COLUMN' ,'ACTUAL_CONTENT_SOURCE');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
     END IF;

     IF(l_address1 = FND_API.G_MISS_CHAR) THEN
       FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
       FND_MESSAGE.SET_TOKEN('COLUMN' ,'ADDRESS1');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
     END IF;

     IF(l_country = FND_API.G_MISS_CHAR) THEN
       FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
       FND_MESSAGE.SET_TOKEN('COLUMN' ,'COUNTRY');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
     END IF;
   ELSIF (p_create_update_flag = 'C') THEN
     IF(l_actual_content_source IS NULL OR l_actual_content_source = FND_API.G_MISS_CHAR) THEN
       FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
       FND_MESSAGE.SET_TOKEN('COLUMN' ,'ACTUAL_CONTENT_SOURCE');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
     END IF;

     IF(l_address1 IS NULL OR l_address1 = FND_API.G_MISS_CHAR) THEN
       FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
       FND_MESSAGE.SET_TOKEN('COLUMN' ,'ADDRESS1');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
     END IF;

     IF(l_country IS NULL OR l_country = FND_API.G_MISS_CHAR) THEN
       FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
       FND_MESSAGE.SET_TOKEN('COLUMN' ,'COUNTRY');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
     END IF;
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.ADD;
END validate_mandatory_column;

PROCEDURE set_effective_end_date (
   p_location_profile_id       IN NUMBER
  ,x_return_status             IN OUT NOCOPY VARCHAR2
) IS

  l_dummy            VARCHAR2(1);

  CURSOR is_profile_exist(l_location_profile_id NUMBER) IS
  SELECT 'X'
  FROM HZ_LOCATION_PROFILES
  WHERE location_profile_id = l_location_profile_id;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  OPEN is_profile_exist(p_location_profile_id);
  FETCH is_profile_exist INTO l_dummy;
  CLOSE is_profile_exist;

  IF(l_dummy IS NOT NULL) THEN
    BEGIN
      UPDATE hz_location_profiles
      SET effective_end_date = sysdate
      WHERE location_profile_id = p_location_profile_id;
    EXCEPTION
      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;
  ELSE
    FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NO_RECORD' );
    FND_MESSAGE.SET_TOKEN( 'RECORD', 'Location Profile' );
    FND_MESSAGE.SET_TOKEN( 'VALUE', p_location_profile_id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.ADD;

END set_effective_end_date;

--
-- This procedure will update both HZ_LOCATIONS.validation_status_code
-- and HZ_LOCATION_PROFILES.validation_status_code
-- This procedure should not be invoked along.  It should be called
-- after creating or updating location.  It is required for those
-- content source which is NOT USER_ENTERED.
-- The reason is that when creating/updating location, there is no
-- parameter to pass validation_status_code in HZ_LOCATIONS_V2PUB
-- api.  As location is being created/updated, location profile
-- will also be created/updated base on the profile
-- HZ_MAINTAIN_LOC_HISTORY and whether there is an existing
-- active profile record for that content source.
-- Therefore, after location profile is being created/updated,
-- the caller program that calls HZ_LOCATIONS_V2PUB should also
-- set the validation_status_code appropriately if the actual_content_source
-- passed in is NOT USER_ENTERED record.
--
PROCEDURE set_validation_status_code (
   p_location_profile_id       IN NUMBER
  ,p_validation_status_code    IN VARCHAR2
  ,x_return_status             IN OUT NOCOPY VARCHAR2
) IS

  l_dummy            VARCHAR2(1);

  CURSOR is_profile_exist(l_location_profile_id NUMBER) IS
  SELECT 'X'
  FROM HZ_LOCATION_PROFILES
  WHERE location_profile_id = l_location_profile_id;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  OPEN is_profile_exist(p_location_profile_id);
  FETCH is_profile_exist INTO l_dummy;
  CLOSE is_profile_exist;

  IF(l_dummy IS NOT NULL) THEN
    BEGIN
      UPDATE hz_location_profiles
      SET validation_status_code = p_validation_status_code
      WHERE location_profile_id = p_location_profile_id;

      UPDATE hz_locations
      SET validation_status_code = p_validation_status_code
      WHERE location_id =
      ( SELECT location_id
        FROM HZ_LOCATION_PROFILES
        WHERE location_profile_id = p_location_profile_id);
    EXCEPTION
      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;
  ELSE
    FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NO_RECORD' );
    FND_MESSAGE.SET_TOKEN( 'RECORD', 'Location Profile' );
    FND_MESSAGE.SET_TOKEN( 'VALUE', p_location_profile_id);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.ADD;

END set_validation_status_code;

PROCEDURE log(
   message      IN      VARCHAR2,
   newline      IN      BOOLEAN DEFAULT TRUE
) IS
BEGIN
  IF message = 'NEWLINE' THEN
   FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
  ELSIF (newline) THEN
    FND_FILE.put_line(fnd_file.log,message);
  ELSE
    FND_FILE.put(fnd_file.log,message);
  END IF;
END log;

/*-----------------------------------------------------------------------
 | Function to fetch messages of the stack and log the error
 | Also returns the error
 |-----------------------------------------------------------------------*/
FUNCTION logerror(SQLERRM VARCHAR2 DEFAULT NULL)
RETURN VARCHAR2 IS
  l_msg_data VARCHAR2(2000);
BEGIN
  FND_MSG_PUB.Reset;

  FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
    l_msg_data := l_msg_data || FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE );
  END LOOP;
  IF (SQLERRM IS NOT NULL) THEN
    l_msg_data := l_msg_data || SQLERRM;
  END IF;
  log(l_msg_data);
  RETURN l_msg_data;
END logerror;

END HZ_LOCATION_PROFILE_PVT;

/
