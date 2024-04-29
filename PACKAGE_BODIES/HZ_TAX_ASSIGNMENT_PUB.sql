--------------------------------------------------------
--  DDL for Package Body HZ_TAX_ASSIGNMENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_TAX_ASSIGNMENT_PUB" as
/* $Header: ARHTLASB.pls 115.14 2003/09/30 23:50:41 acng ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'HZ_TAX_ASSIGNMENT_PUB' ;

procedure do_create_update_loc_assign(
        p_location_id                  IN      NUMBER,
        p_create_update_flag           IN      VARCHAR2,
        x_loc_id                       OUT     NOCOPY NUMBER,
        x_return_status                IN OUT  NOCOPY VARCHAR2,  /* Changed from OUT to IN OUT*/
        p_lock_flag                    IN      VARCHAR2 :=  FND_API.G_FALSE
) IS

   l_org_id                     NUMBER;
   l_count                      NUMBER;
   l_rowid                      ROWID  := NULL;

   l_city                       VARCHAR2(60);
   l_state                      VARCHAR2(60);
   l_country                    VARCHAR2(60);
   l_county                     VARCHAR2(60);
   l_province                   VARCHAR2(60);
   l_postal_code                VARCHAR2(60);
   l_attribute1                 VARCHAR2(150);
   l_attribute2                 VARCHAR2(150);
   l_attribute3                 VARCHAR2(150);
   l_attribute4                 VARCHAR2(150);
   l_attribute5                 VARCHAR2(150);
   l_attribute6                 VARCHAR2(150);
   l_attribute7                 VARCHAR2(150);
   l_attribute8                 VARCHAR2(150);
   l_attribute9                 VARCHAR2(150);
   l_attribute10                VARCHAR2(150);
   l_wh_update_date             DATE;

   l_is_remit_to_location       VARCHAR2(1) := 'N';  /* New local param for remit to addr*/

   db_city                       VARCHAR2(60);
   db_state                      VARCHAR2(60);
   db_country                    VARCHAR2(60);
   db_county                     VARCHAR2(60);
   db_province                   VARCHAR2(60);
   db_postal_code                VARCHAR2(60);
   db_attribute1                 VARCHAR2(150);
   db_attribute2                 VARCHAR2(150);
   db_attribute3                 VARCHAR2(150);
   db_attribute4                 VARCHAR2(150);
   db_attribute5                 VARCHAR2(150);
   db_attribute6                 VARCHAR2(150);
   db_attribute7                 VARCHAR2(150);
   db_attribute8                 VARCHAR2(150);
   db_attribute9                 VARCHAR2(150);
   db_attribute10                VARCHAR2(150);
   db_wh_update_date             DATE;

-- ACNG add call to location profile: BEGIN
    l_location_profile_rec  hz_location_profile_pvt.location_profile_rec_type;
    l_actual_content_source VARCHAR2(30);
    l_return_status         VARCHAR2(30);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);
    l_allow_update_std        VARCHAR2(1);
    l_date_validated          DATE;
    l_validation_status_code  VARCHAR2(30);
-- ACNG add call to location profile: END

BEGIN

	select * 			/* Bug Fix 2020712 */
	into  arp_standard.sysparm
	from  ar_system_parameters;

  -- check org context
  -- if org context is not available then no record will be created in
  -- hz_loc_assignments table.

      SELECT
        NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1), ' ', NULL,
                         SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)
      INTO l_org_id
      FROM dual;

/*
      IF l_org_id is NULL or l_org_id = -99 THEN

         FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
         FND_MESSAGE.SET_TOKEN('COLUMN', 'org_id');
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
     END IF;
*/

  -- check the required fields:
     IF p_location_id IS NULL OR
        p_location_id = FND_API.G_MISS_NUM  THEN

          FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
          FND_MESSAGE.SET_TOKEN('COLUMN', 'p_location_id');
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
     END IF;

  -- IF p_lock_flag is true then
  -- Check whether location record has been updated by another user. If not, lock it.
  -- IF p_loc_flag is not true then the location has been locked already.

  IF p_lock_flag = 'T' OR p_lock_flag = FND_API.G_TRUE  THEN

     -- get location components
     BEGIN
       SELECT country, city,  state, county, province,  postal_code,
              attribute1, attribute2, attribute3, attribute4, attribute5,
              attribute6, attribute7, attribute8, attribute9, attribute10,
              wh_update_date
            , actual_content_source
            , date_validated
            , validation_status_code
       INTO   l_country, l_city, l_state, l_county, l_province, l_postal_code,
              l_attribute1,l_attribute2,l_attribute3,l_attribute4,l_attribute5,
              l_attribute6,l_attribute7,l_attribute8,l_attribute9,l_attribute10,
              l_wh_update_date
            , l_actual_content_source
            , l_date_validated
            , l_validation_status_code
       FROM   HZ_LOCATIONS
       WHERE  location_id = p_location_id
       FOR UPDATE OF location_id NOWAIT;

       EXCEPTION WHEN NO_DATA_FOUND THEN
                         FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
                         FND_MESSAGE.SET_TOKEN('RECORD', 'hz_locations');
                         FND_MESSAGE.SET_TOKEN('VALUE', to_char(p_location_id));
                         FND_MSG_PUB.ADD;
                         x_return_status := FND_API.G_RET_STS_ERROR;

      END;  -- end of SELECT

  ELSE -- do not lock the location record
       -- get location components

     BEGIN
       SELECT country, city,  state, county, province,  postal_code,
              attribute1, attribute2, attribute3, attribute4, attribute5,
              attribute6, attribute7, attribute8, attribute9, attribute10,
              wh_update_date
            , actual_content_source
       INTO   l_country, l_city, l_state, l_county, l_province, l_postal_code,
              l_attribute1,l_attribute2,l_attribute3,l_attribute4,l_attribute5,
              l_attribute6,l_attribute7,l_attribute8,l_attribute9,l_attribute10,
              l_wh_update_date
            , l_actual_content_source
       FROM   HZ_LOCATIONS
       WHERE  location_id = p_location_id;

       EXCEPTION WHEN NO_DATA_FOUND THEN
                         FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
                         FND_MESSAGE.SET_TOKEN('RECORD', 'hz_locations');
                         FND_MESSAGE.SET_TOKEN('VALUE', to_char(p_location_id));
                         FND_MSG_PUB.ADD;
                         x_return_status := FND_API.G_RET_STS_ERROR;

      END;  -- end of SELECT ;

  END IF ;

-- ACNG
    -- raise error if the update location profile option is turned off and
    -- the address has been validated before
    l_allow_update_std := nvl(fnd_profile.value('HZ_UPDATE_STD_ADDRESS'), 'Y');
    IF(l_allow_update_std = 'N' AND
       l_date_validated IS NOT NULL AND
       l_validation_status_code IS NOT NULL) THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_LOC_NO_UPDATE');
      FND_MSG_PUB.ADD;
      RAISE fnd_api.g_exc_error;
    END IF;
-- ACNG

        db_country      :=      l_country;
        db_city         :=      l_city ;
        db_state        :=      l_state ;
        db_county       :=      l_county ;
        db_province     :=      l_province;
        db_postal_code  :=      l_postal_code;
        db_attribute1   :=      l_attribute1;
        db_attribute2   :=      l_attribute2;
        db_attribute3   :=      l_attribute3;
        db_attribute4   :=      l_attribute4;
        db_attribute5   :=      l_attribute5;
        db_attribute6   :=      l_attribute6;
        db_attribute7   :=      l_attribute7;
        db_attribute8   :=      l_attribute8;
        db_attribute9   :=      l_attribute9;
        db_attribute10  :=      l_attribute10;
        db_wh_update_date:=     l_wh_update_date;

  --
  -- Chevking whether this location is for Remit-To Address or not
  --
  BEGIN
    SELECT  'Y'
    INTO    l_is_remit_to_location
    FROM    DUAL
    WHERE   EXISTS ( SELECT  1
                     FROM    hz_party_sites ps
                     WHERE   ps.location_id = p_location_id
                     AND     ps.party_id = -1);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
  END;

  -- call tax package to populate loc_id for a location

     -- run validation for default country.
     -- Added additional condition to check whether
     -- this is for Remit-To Address or not.
  IF l_country = arp_standard.sysparm.default_country AND
     l_is_remit_to_location <> 'Y' THEN

        arp_adds.Set_Location_CCID(l_country,
                                   l_city,
                                   l_state,
                                   l_county,
                                   l_province,
                                   l_postal_code,
                                   l_attribute1,
                                   l_attribute2,
                                   l_attribute3,
                                   l_attribute4,
                                   l_attribute5,
                                   l_attribute6,
                                   l_attribute7,
                                   l_attribute8,
                                   l_attribute9,
                                   l_attribute10,
                                   x_loc_id,
                                   p_location_id );

--Update location attributes if the values in the database do not match
--with the values returned by the above procedure.

	IF         db_country      =      l_country
	AND        db_city         =      l_city
	AND        db_state        =      l_state
	AND        db_county       =      l_county
	AND        db_province     =      l_province
	AND        db_postal_code  =      l_postal_code
	AND        db_attribute1   =      l_attribute1
	AND        db_attribute2   =      l_attribute2
	AND        db_attribute3   =      l_attribute3
	AND        db_attribute4   =      l_attribute4
	AND        db_attribute5   =      l_attribute5
	AND        db_attribute6   =      l_attribute6
	AND        db_attribute7   =      l_attribute7
	AND        db_attribute8   =      l_attribute8
	AND        db_attribute9   =      l_attribute9
	AND        db_attribute10  =      l_attribute10 THEN

		NULL;
	ELSE
		UPDATE hz_locations SET
        	country      =      l_country,
        	city         =      l_city ,
        	state        =      l_state ,
        	county       =      l_county ,
        	province     =      l_province,
        	postal_code  =      l_postal_code,
        	attribute1   =      l_attribute1,
        	attribute2   =      l_attribute2,
        	attribute3   =      l_attribute3,
        	attribute4   =      l_attribute4,
        	attribute5   =      l_attribute5,
        	attribute6   =      l_attribute6,
        	attribute7   =      l_attribute7,
        	attribute8   =      l_attribute8,
        	attribute9   =      l_attribute9,
        	attribute10  =      l_attribute10
		WHERE  location_id = p_location_id;

-- ACNG add call to location profile: BEGIN

   IF(NOT( db_country      =      l_country
       AND db_city         =      l_city
       AND db_state        =      l_state
       AND db_county       =      l_county
       AND db_province     =      l_province
       AND db_postal_code  =      l_postal_code)) THEN

     l_location_profile_rec.location_profile_id := NULL;
     l_location_profile_rec.location_id := p_location_id;
     l_location_profile_rec.actual_content_source := l_actual_content_source;
     l_location_profile_rec.effective_start_date := NULL;
     l_location_profile_rec.effective_end_date := NULL;
     l_location_profile_rec.date_validated := NULL;
     l_location_profile_rec.city := l_city;
     l_location_profile_rec.postal_code := l_postal_code;
     l_location_profile_rec.county := l_county;
     l_location_profile_rec.country := l_country;
     l_location_profile_rec.address1 := NULL;
     l_location_profile_rec.address2 := NULL;
     l_location_profile_rec.address3 := NULL;
     l_location_profile_rec.address4 := NULL;

     IF(l_state IS NOT NULL) THEN
       l_location_profile_rec.prov_state_admin_code := l_state;
     ELSIF(l_province IS NOT NULL) THEN
       l_location_profile_rec.prov_state_admin_code := l_province;
     ELSE
       l_location_profile_rec.prov_state_admin_code := NULL;
     END IF;

     l_return_status := FND_API.G_RET_STS_SUCCESS;

     hz_location_profile_pvt.update_location_profile (
       p_location_profile_rec      => l_location_profile_rec
      ,x_return_status             => l_return_status
      ,x_msg_count                 => l_msg_count
      ,x_msg_data                  => l_msg_data );

     IF(l_return_status = FND_API.G_RET_STS_ERROR) THEN
       RAISE fnd_api.g_exc_error;
     ELSIF(l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE fnd_api.g_exc_unexpected_error;
     END IF;

   END IF;

-- ACNG add call to location profile: END

	END IF;



     ELSE -- not default country
                x_loc_id := NULL;

    END IF; -- default country


/******** commented out as control does not come here, it goes thru V2 API
  IF p_create_update_flag = 'C' THEN

     -- check if the combination of location_id and org_id exists in database,
     -- if it exists, then tax group has created a record for a party without
     -- any customer account site. we just update the loc_id accordingly for
     -- that record.

     BEGIN
       l_count := 0;

       SELECT count(*)
       INTO l_count
       FROM hz_loc_assignments
       WHERE location_id = p_location_id
       AND  nvl(org_id, l_org_id) = l_org_id;

       if l_count = 0 then

         -- insert loc_id for a new location:
         HZ_LOC_ASSIGNMENTS_PKG.INSERT_ROW(
          X_Rowid => l_rowid,
          X_LOCATION_ID => p_location_id,
          X_LOC_ID => x_loc_id,
          X_ORG_ID => l_org_id,
          X_CREATED_BY => hz_utility_pub.CREATED_BY,
          X_CREATION_DATE => hz_utility_pub.CREATION_DATE,
          X_LAST_UPDATE_LOGIN => hz_utility_pub.LAST_UPDATE_LOGIN,
          X_LAST_UPDATE_DATE => hz_utility_pub.LAST_UPDATE_DATE,
          X_LAST_UPDATED_BY => hz_utility_pub.LAST_UPDATED_BY,
          X_REQUEST_ID => hz_utility_pub.REQUEST_ID,
          X_PROGRAM_APPLICATION_ID => hz_utility_pub.PROGRAM_APPLICATION_ID,
          X_PROGRAM_ID => hz_utility_pub.PROGRAM_ID,
          X_PROGRAM_UPDATE_DATE => hz_utility_pub.PROGRAM_UPDATE_DATE,
          X_WH_UPDATE_DATE => l_wh_update_date
          );

        else -- update loc_id for an existing location.

         --Select rowid.
         select rowid INTO l_rowid FROM hz_loc_assignments
         WHERE location_id = p_location_id
         AND  nvl(org_id, l_org_id) = l_org_id;

         HZ_LOC_ASSIGNMENTS_PKG.UPDATE_ROW(
          X_Rowid => l_rowid,
          X_LOCATION_ID => p_location_id,
          X_LOC_ID => x_loc_id,
          X_ORG_ID => l_org_id,
          X_CREATED_BY => FND_API.G_MISS_NUM,
          X_CREATION_DATE => FND_API.G_MISS_DATE,
          X_LAST_UPDATE_LOGIN => hz_utility_pub.LAST_UPDATE_LOGIN,
          X_LAST_UPDATE_DATE => hz_utility_pub.LAST_UPDATE_DATE,
          X_LAST_UPDATED_BY => hz_utility_pub.LAST_UPDATED_BY,
          X_REQUEST_ID => hz_utility_pub.REQUEST_ID,
          X_PROGRAM_APPLICATION_ID => hz_utility_pub.PROGRAM_APPLICATION_ID,
          X_PROGRAM_ID => hz_utility_pub.PROGRAM_ID,
          X_PROGRAM_UPDATE_DATE => hz_utility_pub.PROGRAM_UPDATE_DATE,
          X_WH_UPDATE_DATE => l_wh_update_date
        );
      end if;
    END; -- end of p_create_update_flag = 'C'


  ELSIF p_create_update_flag = 'U' THEN

     --Select rowid.
         select rowid INTO l_rowid FROM hz_loc_assignments
         WHERE location_id = p_location_id
         AND  nvl(org_id, l_org_id) = l_org_id;

    -- update loc_id for modified location

    HZ_LOC_ASSIGNMENTS_PKG.UPDATE_ROW(
          X_Rowid => l_rowid,
          X_LOCATION_ID => p_location_id,
          X_LOC_ID => x_loc_id,
          X_ORG_ID => l_org_id,
          X_CREATED_BY => FND_API.G_MISS_NUM,
          X_CREATION_DATE => FND_API.G_MISS_DATE,
          X_LAST_UPDATE_LOGIN => hz_utility_pub.LAST_UPDATE_LOGIN,
          X_LAST_UPDATE_DATE => hz_utility_pub.LAST_UPDATE_DATE,
          X_LAST_UPDATED_BY => hz_utility_pub.LAST_UPDATED_BY,
          X_REQUEST_ID => hz_utility_pub.REQUEST_ID,
          X_PROGRAM_APPLICATION_ID => hz_utility_pub.PROGRAM_APPLICATION_ID,
          X_PROGRAM_ID => hz_utility_pub.PROGRAM_ID,
          X_PROGRAM_UPDATE_DATE => hz_utility_pub.PROGRAM_UPDATE_DATE,
          X_WH_UPDATE_DATE => l_wh_update_date
        );

  END IF;
********************* commented out till here *******************/

end do_create_update_loc_assign;

procedure create_loc_assignment(
        p_api_version                  IN      NUMBER,
        p_init_msg_list                IN      VARCHAR2:= FND_API.G_FALSE,
        p_commit                       IN      VARCHAR2:= FND_API.G_FALSE,
        p_location_id                  IN      NUMBER,
        x_return_status                IN OUT  NOCOPY VARCHAR2, /* Changed from OUT to IN OUT*/
        x_msg_count                    OUT     NOCOPY NUMBER,
        x_msg_data                     OUT     NOCOPY VARCHAR2,
        x_loc_id                       OUT     NOCOPY NUMBER,
        p_lock_flag                    IN      VARCHAR2 :=FND_API.G_FALSE
) IS

   l_api_name          CONSTANT VARCHAR2(30)  := 'create loc assignment';
   l_api_version       CONSTANT  NUMBER        := 1.0;
   l_location_id       NUMBER := p_location_id;
   APP_EXCEPTION	EXCEPTION;
   PRAGMA EXCEPTION_INIT(APP_EXCEPTION, -20000);
BEGIN
--Standard start of API savepoint
        SAVEPOINT create_loc_assignment_pub;
--Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call(
                                        l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

--Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean(p_init_msg_list) THEN
                FND_MSG_PUB.initialize;
        END IF;

--Initialize API return status to success.
        x_return_status := FND_API.G_RET_STS_SUCCESS;


-- Call to business logic.

/********* following code is remarked as everything is done through V2 API now
-- populate loc_id by calling tax package.
        do_create_update_loc_assign( p_location_id,
                                     'C',
                                     x_loc_id,
                                     x_return_status,
                                     p_lock_flag);
****************/

    -- code for doing everything thru V2 API
    HZ_TAX_ASSIGNMENT_V2PUB.create_loc_assignment(
        p_location_id                  => p_location_id,
        p_lock_flag                    => p_lock_flag,
        p_created_by_module            => 'TCA_V1_API',
        p_application_id               => -222,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        x_loc_id                       => x_loc_id
);


IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
END IF;

--Standard check of p_commit.
        IF FND_API.to_Boolean(p_commit) THEN
                Commit;
        END IF;

--Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);
EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO create_loc_assignment_pub;
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO create_loc_assignment_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

        WHEN  APP_EXCEPTION THEN
                ROLLBACK TO create_loc_assignment_pub;
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;
 		FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
        WHEN OTHERS THEN
                ROLLBACK TO create_loc_assignment_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;

 FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

END create_loc_assignment;

procedure update_loc_assignment(
        p_api_version                  IN      NUMBER,
        p_init_msg_list                IN      VARCHAR2:= FND_API.G_FALSE,
        p_commit                       IN      VARCHAR2:= FND_API.G_FALSE,
        p_location_id                  IN      NUMBER,
        x_return_status                IN OUT  NOCOPY VARCHAR2, /* Changed from OUT to IN OUT*/
        x_msg_count                    OUT     NOCOPY NUMBER,
        x_msg_data                     OUT     NOCOPY VARCHAR2,
        x_loc_id                       OUT     NOCOPY NUMBER,
        p_lock_flag                    IN      VARCHAR2 :=FND_API.G_TRUE
) IS

   l_api_name           CONSTANT VARCHAR2(30)  := 'update loc assignment';
   l_api_version        CONSTANT  NUMBER        := 1.0;
   l_location_id        NUMBER := p_location_id;
   APP_EXCEPTION	EXCEPTION;
   PRAGMA EXCEPTION_INIT(APP_EXCEPTION, -20000);

BEGIN
--Standard start of API savepoint
        SAVEPOINT update_loc_assignment_pub;
--Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call(
                                        l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

--Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean(p_init_msg_list) THEN
                FND_MSG_PUB.initialize;
        END IF;

--Initialize API return status to success.
        x_return_status := FND_API.G_RET_STS_SUCCESS;


-- Call to business logic.

/******** following code is remarked as everything is now done thru V2 API
-- populate loc_id by calling tax package.
        do_create_update_loc_assign( l_location_id,
                                     'U',
                                     x_loc_id,
                                     x_return_status,
                                     p_lock_flag );
*****************/

    -- code for doing everything by V2 API
    HZ_TAX_ASSIGNMENT_V2PUB.update_loc_assignment(
        p_location_id                  => l_location_id,
        p_lock_flag                    => p_lock_flag,
        p_created_by_module            => 'TCA_V1_API',
        p_application_id               => -222,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        x_loc_id                       => x_loc_id
);

IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
END IF;

--Standard check of p_commit.
        IF FND_API.to_Boolean(p_commit) THEN
                Commit;
        END IF;

--Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);
EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO update_loc_assignment_pub;
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO update_loc_assignment_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

        WHEN  APP_EXCEPTION THEN
                ROLLBACK TO update_loc_assignment_pub;
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;
 		FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

        WHEN OTHERS THEN
                ROLLBACK TO update_loc_assignment_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;

 FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

END update_loc_assignment;


end HZ_TAX_ASSIGNMENT_PUB;

/
