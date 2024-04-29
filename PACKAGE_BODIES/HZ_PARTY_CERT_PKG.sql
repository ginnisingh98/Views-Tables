--------------------------------------------------------
--  DDL for Package Body HZ_PARTY_CERT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_PARTY_CERT_PKG" AS
/* $Header: ARHCERTB.pls 120.14 2005/10/30 04:17:45 appldev noship $ */

-- AUTHOR : CVIJAYAN ("VJN")
-- THIS API WAS CREATED TO UPDATE THE NEWLY CREATED COLUMN CERTIFICATION_LEVEL IN HZ_PARTIES
-- BASE BUG -- 3125139



/**
 * PROCEDURE set_certification_level
 *
 * DESCRIPTION
 *     Sets the value of the newly added certification level flag in HZ_PARTIES .
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 *
 * ARGUMENTS
 *
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   08-06 -2002    Colathur Vijayan ("VJN")    o Created.
 *   15-FEB-2005    Rajeswari B                 o Bug No: 4181943 Added DQM Synchronization functionality.
 */

PROCEDURE set_certification_level (
-- input parameters
  p_init_msg_list		IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
  p_party_id         	IN  number,
  p_cert_level         IN  VARCHAR2,
  p_cert_reason_code         IN  VARCHAR2,
-- in/out parameters
  x_object_version_number	IN OUT NOCOPY NUMBER,
-- output parameters
  x_return_status		OUT NOCOPY VARCHAR2,
  x_msg_count			OUT NOCOPY NUMBER,
  x_msg_data			OUT NOCOPY VARCHAR2
)
IS

    cursor get_party_type_csr is
	   select party_type
	   from hz_parties
	   where party_id = p_party_id;

    l_object_version_number           NUMBER;
    l_rowid                           ROWID;
    l_party_id                        NUMBER;
    l_count                           NUMBER;
    l_cert_reason_code varchar2(30);
    dss_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    dss_msg_count     NUMBER := 0;
    dss_msg_data      VARCHAR2(2000):= null;
    l_test_security   VARCHAR2(1):= 'F';
    l_party_type varchar2(30);

BEGIN

    -- standard start of API savepoint
    SAVEPOINT set_certification_level ;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- check whether record has been updated by another user.
    -- if not, lock it.

    BEGIN
        SELECT object_version_number, rowid , party_id
        INTO   l_object_version_number, l_rowid , l_party_id
        FROM   HZ_PARTIES
        WHERE  party_id = p_party_id
        and party_type in ('ORGANIZATION','PERSON')
        FOR UPDATE NOWAIT;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
        FND_MESSAGE.SET_TOKEN('RECORD', 'party of type organization');
        FND_MESSAGE.SET_TOKEN('VALUE', NVL(TO_CHAR(P_PARTY_ID), 'NULL'));
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END;

    -- If this happens the record has changed
    IF NOT ((x_object_version_number is null and l_object_version_number is null)
                OR (nvl(x_object_version_number,-1) = l_object_version_number))
    THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
            FND_MESSAGE.SET_TOKEN('TABLE', 'HZ_PARTIES');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
    END IF;

    x_object_version_number := nvl(l_object_version_number, 1) + 1;


    l_cert_reason_code := p_cert_reason_code;
    if (p_cert_level is null or p_cert_level =  FND_API.G_MISS_CHAR)
    then
	l_cert_reason_code := null;
    end if;


    ----------------------------------
    -- VALIDATIONS
    ----------------------------------
    -- validate the passed in certification status against ar_lookups
    -- only if it is non-trivial ( neither null nor fnd_api.g_miss_char)

     IF p_cert_level is not null and p_cert_level <> FND_API.G_MISS_CHAR
     THEN
             HZ_UTILITY_V2PUB.validate_lookup(
                       p_column           => 'certification_level',
                       p_lookup_type      => 'HZ_PARTY_CERT_LEVEL',
                       p_column_value     =>  p_cert_level ,
                       x_return_status    =>  x_return_status
           );
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS
    THEN
         RAISE FND_API.G_EXC_ERROR;
    END IF;


    -- validate the passed in certification reason code against ar_lookups
    -- only if it is non-trivial ( neither null nor fnd_api.g_miss_char)

     IF p_cert_reason_code is not null and p_cert_reason_code <> FND_API.G_MISS_CHAR
     THEN
             HZ_UTILITY_V2PUB.validate_lookup(
                       p_column           => 'cert_reason_code',
                       p_lookup_type      => 'HZ_PARTY_CERT_REASON',
                       p_column_value     =>  p_cert_reason_code ,
                       x_return_status    =>  x_return_status
           );
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS
    THEN
         RAISE FND_API.G_EXC_ERROR;
    END IF;



    -- take out DSS Check per PM
/*    IF NVL(fnd_profile.value('HZ_DSS_ENABLED'), 'N') = 'Y' THEN
      l_test_security :=
           hz_dss_util_pub.test_instance(
                  p_operation_code     => 'UPDATE',
                  p_db_object_name     => 'HZ_PARTIES',
                  p_instance_pk1_value => l_party_id,
                  p_user_name          => fnd_global.user_name,
                  x_return_status      => dss_return_status,
                  x_msg_count          => dss_msg_count,
                  x_msg_data           => dss_msg_data);

      if dss_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE FND_API.G_EXC_ERROR;
      end if;

      if (l_test_security <> 'T' OR l_test_security <> FND_API.G_TRUE) then

         FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_NO_UPDATE_PRIVILEGE');
         FND_MESSAGE.SET_TOKEN('ENTITY_NAME',
                               hz_dss_util_pub.get_display_name('HZ_PARTIES', null));
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
      end if;
    END IF;

*/
    -- do the actual update
    UPDATE HZ_PARTIES SET
        CERTIFICATION_LEVEL = DECODE( p_cert_level, FND_API.G_MISS_CHAR, NULL, p_cert_level ),
        CERT_REASON_CODE = DECODE( l_cert_reason_code, FND_API.G_MISS_CHAR, NULL, l_cert_reason_code ),
        LAST_UPDATED_BY = HZ_UTILITY_V2PUB.LAST_UPDATED_BY,
        CREATION_DATE = CREATION_DATE,
        LAST_UPDATE_LOGIN = HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN,
        REQUEST_ID = HZ_UTILITY_V2PUB.REQUEST_ID, --Bug No.4181943
        PROGRAM_APPLICATION_ID = HZ_UTILITY_V2PUB.PROGRAM_APPLICATION_ID,
        CREATED_BY = CREATED_BY,
        LAST_UPDATE_DATE = HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
        PROGRAM_ID = HZ_UTILITY_V2PUB.PROGRAM_ID,
        PROGRAM_UPDATE_DATE = HZ_UTILITY_V2PUB.PROGRAM_UPDATE_DATE,
        OBJECT_VERSION_NUMBER = DECODE( X_OBJECT_VERSION_NUMBER, NULL, OBJECT_VERSION_NUMBER, FND_API.G_MISS_NUM, NULL, X_OBJECT_VERSION_NUMBER )
        WHERE ROWID = l_rowid;

    -- Start of changes Bug No: 4181943

    -- do DQM sychronization

        open get_party_type_csr;
        fetch get_party_type_csr into l_party_type;
        close get_party_type_csr;


        if l_party_type = 'ORGANIZATION' then

	   HZ_DQM_SYNC.sync_org(p_party_id,'U');

        elsif l_party_type = 'PERSON' then

	   HZ_DQM_SYNC.sync_person(p_party_id,'U');

        end if;

    -- End of changes Bug No: 4181943


    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO set_certification_level;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
    WHEN OTHERS THEN
        ROLLBACK TO set_certification_level ;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
END set_certification_level ;

/* should only be called from DL UI.Since validation is done from UI. No additional
validation here */

PROCEDURE set_party_attributes(
-- input parameters
  p_init_msg_list		IN  VARCHAR2  DEFAULT FND_API.G_FALSE,
  p_party_id         	IN  number,
  p_status         IN  VARCHAR2,
  p_internal_flag       IN  VARCHAR2,
-- in/out parameters
  x_object_version_number	IN OUT NOCOPY NUMBER,
-- output parameters
  x_return_status		OUT NOCOPY VARCHAR2,
  x_msg_count			OUT NOCOPY NUMBER,
  x_msg_data			OUT NOCOPY VARCHAR2
) is
	cursor get_party_type_csr is
		select party_type
		from hz_parties
		where party_id = p_party_id;

l_party_type varchar2(30);
dss_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
dss_msg_count     NUMBER := 0;
dss_msg_data      VARCHAR2(2000):= null;
l_test_security   VARCHAR2(1):= 'F';

begin
	-- standard start of API savepoint
    	SAVEPOINT set_party_attributes ;

    	-- initialize message list if p_init_msg_list is set to TRUE.
    	IF FND_API.to_Boolean(p_init_msg_list) THEN
        	FND_MSG_PUB.initialize;
    	END IF;

    	-- initialize API return status to success.
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

	 -- Take out DSS Check per PM
/*    IF NVL(fnd_profile.value('HZ_DSS_ENABLED'), 'N') = 'Y' THEN
      l_test_security :=
           hz_dss_util_pub.test_instance(
                  p_operation_code     => 'UPDATE',
                  p_db_object_name     => 'HZ_PARTIES',
                  p_instance_pk1_value => p_party_id,
                  p_user_name          => fnd_global.user_name,
                  x_return_status      => dss_return_status,
                  x_msg_count          => dss_msg_count,
                  x_msg_data           => dss_msg_data);

      if dss_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE FND_API.G_EXC_ERROR;
      end if;

      if (l_test_security <> 'T' OR l_test_security <> FND_API.G_TRUE) then

         FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_NO_UPDATE_PRIVILEGE');
         FND_MESSAGE.SET_TOKEN('ENTITY_NAME',
                               hz_dss_util_pub.get_display_name('HZ_PARTIES', null));
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
      end if;
    END IF;
*/

        open get_party_type_csr;
	fetch get_party_type_csr into l_party_type;
	close get_party_type_csr;

       if p_internal_flag is not null
       then
	if l_party_type = 'ORGANIZATION'
	then


    		UPDATE HZ_ORGANIZATION_PROFILES SET
        	internal_flag = p_internal_flag,
        	LAST_UPDATED_BY = HZ_UTILITY_V2PUB.LAST_UPDATED_BY,
        	CREATION_DATE = CREATION_DATE,
        	LAST_UPDATE_LOGIN = HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN,
        	REQUEST_ID = HZ_UTILITY_V2PUB.REQUEST_ID, --Bug No.4181943
        	PROGRAM_APPLICATION_ID = HZ_UTILITY_V2PUB.PROGRAM_APPLICATION_ID,
        	CREATED_BY = CREATED_BY,
        	LAST_UPDATE_DATE = HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
        	PROGRAM_ID = HZ_UTILITY_V2PUB.PROGRAM_ID,
        	PROGRAM_UPDATE_DATE = HZ_UTILITY_V2PUB.PROGRAM_UPDATE_DATE,
        	OBJECT_VERSION_NUMBER = nvl(object_version_number,1)+1
        	WHERE party_id = p_party_id;


	elsif l_party_type = 'PERSON'
	then

    		UPDATE HZ_PERSON_PROFILES SET
        	internal_flag = p_internal_flag,
        	LAST_UPDATED_BY = HZ_UTILITY_V2PUB.LAST_UPDATED_BY,
        	CREATION_DATE = CREATION_DATE,
        	LAST_UPDATE_LOGIN = HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN,
        	REQUEST_ID = HZ_UTILITY_V2PUB.REQUEST_ID, --Bug No.4181943
        	PROGRAM_APPLICATION_ID = HZ_UTILITY_V2PUB.PROGRAM_APPLICATION_ID,
        	CREATED_BY = CREATED_BY,
        	LAST_UPDATE_DATE = HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
        	PROGRAM_ID = HZ_UTILITY_V2PUB.PROGRAM_ID,
        	PROGRAM_UPDATE_DATE = HZ_UTILITY_V2PUB.PROGRAM_UPDATE_DATE,
        	OBJECT_VERSION_NUMBER = nvl(object_version_number,1)+1
        	WHERE party_id = p_party_id;


	end if;
      end if; -- internal_flag is not null

      	if p_status is not null
	then
		UPDATE HZ_PARTIES SET
        		status = p_status,
        		LAST_UPDATED_BY = HZ_UTILITY_V2PUB.LAST_UPDATED_BY,
        		CREATION_DATE = CREATION_DATE,
        		LAST_UPDATE_LOGIN = HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN,
        		REQUEST_ID = HZ_UTILITY_V2PUB.REQUEST_ID, --Bug No.4181943
        		PROGRAM_APPLICATION_ID = HZ_UTILITY_V2PUB.PROGRAM_APPLICATION_ID,
        		CREATED_BY = CREATED_BY,
        		LAST_UPDATE_DATE = HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,
        		PROGRAM_ID = HZ_UTILITY_V2PUB.PROGRAM_ID,
        		PROGRAM_UPDATE_DATE = HZ_UTILITY_V2PUB.PROGRAM_UPDATE_DATE,
        		OBJECT_VERSION_NUMBER = nvl(object_version_number,1)+1
        	WHERE party_id = p_party_id;
	end if;

	-- Start of changes Bug No: 4181943

	-- do DQM sychronization

	if l_party_type = 'ORGANIZATION' then

	   HZ_DQM_SYNC.sync_org(p_party_id,'U');

	elsif l_party_type = 'PERSON' then

	   HZ_DQM_SYNC.sync_person(p_party_id,'U');

	end if;

        -- End of changes Bug No: 4181943

 -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO set_party_attributes;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
    WHEN OTHERS THEN
        ROLLBACK TO set_party_attributes;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

end;


END HZ_PARTY_CERT_PKG ;


/
