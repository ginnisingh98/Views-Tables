--------------------------------------------------------
--  DDL for Package Body HZ_TIMEZONE_UTILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_TIMEZONE_UTILS_PVT" AS
/*$Header: ARHTZUTB.pls 120.5 2005/10/30 03:55:25 appldev noship $ */

procedure duplicate_country_code(p_territory_code in varchar2, x_return_status out nocopy varchar2) is

	cursor territory_code_exist_csr is
		select 'Y'
		from hz_phone_country_codes
	where territory_code = p_territory_code;

l_exist varchar2(1);

begin
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	open territory_code_exist_csr;
	fetch territory_code_exist_csr into l_exist;
	close territory_code_exist_csr;
	if l_exist = 'Y'
	then
		FND_MESSAGE.SET_NAME('AR', 'HZ_API_DUPLICATE_COLUMN');
		FND_MESSAGE.SET_TOKEN('COLUMN', 'territory_code');
		FND_MSG_PUB.ADD;
		x_return_status := FND_API.G_RET_STS_ERROR;
	end if;
end;

procedure duplicate_area_code(p_territory_code in varchar2, p_area_code in varchar2,
		x_return_status out nocopy varchar2) is

	cursor area_code_exist_csr is
		select 'Y'
		from hz_phone_area_codes
	where territory_code = p_territory_code
	 and area_code = p_area_code;

l_exist varchar2(1);

begin
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	open area_code_exist_csr;
	fetch area_code_exist_csr into l_exist;
	close area_code_exist_csr;
	if l_exist = 'Y'
	then
		FND_MESSAGE.SET_NAME('AR', 'HZ_TZ_AREA_DUP_ERROR');
		FND_MSG_PUB.ADD;
		x_return_status := FND_API.G_RET_STS_ERROR;
	end if;
end;

PROCEDURE create_area_code(
  p_territory_code        IN VARCHAR2,
  p_phone_country_code    IN VARCHAR2,
  p_area_code             IN VARCHAR2,
  p_description           IN VARCHAR2,
  p_timezone_id           IN NUMBER,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2) is

l_rowid ROWID;
begin
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	fnd_msg_pub.initialize;
	SAVEPOINT create_area_code;

        if p_area_code <> TRANSLATE (
                 p_area_code,
                 '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz()- .+''~`\/@#$%^*_,|}{[]?<>=";:',
                 '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz')
	then
		fnd_message.set_name('AR','HZ_INVALID_AREA_CODE');
		FND_MSG_PUB.ADD;
		x_return_status := FND_API.G_RET_STS_ERROR;
		RAISE FND_API.G_EXC_ERROR;
	end if;

	duplicate_area_code(p_territory_code,p_area_code, x_return_status);
	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	HZ_PHONE_AREA_CODES_PKG.insert_row(
                    p_rowid      => l_rowid,
                    p_TERRITORY_CODE                       =>p_TERRITORY_CODE,
                    p_AREA_CODE                            =>p_AREA_CODE,
                    p_PHONE_COUNTRY_CODE                   =>p_PHONE_COUNTRY_CODE,
                    p_DESCRIPTION                          =>p_DESCRIPTION,
                    p_CREATED_BY                           =>hz_utility_v2pub.created_by,
                    p_CREATION_DATE                        =>hz_utility_v2pub.creation_date,
                    p_LAST_UPDATE_LOGIN                    => hz_utility_v2pub.last_update_login,
                    p_LAST_UPDATE_DATE                     => hz_utility_v2pub.last_update_date,
                    p_LAST_UPDATED_BY                      =>hz_utility_v2pub.last_updated_by,
                    p_OBJECT_VERSION_NUMBER                =>1,
		    p_TIMEZONE_ID			   =>p_TIMEZONE_ID);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK to create_area_code;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                        p_encoded => FND_API.G_FALSE,
                        p_count => x_msg_count,
                        p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK to create_area_code;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                        p_encoded => FND_API.G_FALSE,
                        p_count => x_msg_count,
                        p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK to create_area_code;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;

        FND_MSG_PUB.Count_And_Get(
                        p_encoded => FND_API.G_FALSE,
                        p_count => x_msg_count,
                        p_data  => x_msg_data);
END;

PROCEDURE update_area_code(
  p_territory_code        IN VARCHAR2,
  p_area_code             IN VARCHAR2,
  p_old_area_code         IN VARCHAR2,
  p_description           IN VARCHAR2,
  p_timezone_id           IN NUMBER,
  p_object_version_number IN OUT NOCOPY NUMBER,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2) is

  l_object_version_number NUMBER;
  l_rowid ROWID;
  l_area_code varchar2(30);

begin
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	fnd_msg_pub.initialize;
	SAVEPOINT update_area_code;


	 if p_area_code <> TRANSLATE (
                 p_area_code,
                 '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz()- .+''~`\/@#$%^*_,|}{[]?<>=";:',
                 '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz')
	then
		fnd_message.set_name('AR','HZ_INVALID_AREA_CODE');
		FND_MSG_PUB.ADD;
		x_return_status := FND_API.G_RET_STS_ERROR;
		RAISE FND_API.G_EXC_ERROR;
	end if;

         -- check whether record has been updated by another user. If not, lock it.
    BEGIN
        SELECT OBJECT_VERSION_NUMBER,rowid,area_code
        INTO   l_object_version_number, l_rowid, l_area_code
        FROM   HZ_PHONE_AREA_CODES
        WHERE  TERRITORY_CODE = p_territory_code
	and area_code = p_old_area_code
        FOR UPDATE OF TERRITORY_CODE NOWAIT;

        IF NOT ((p_object_version_number is null and l_object_version_number is
null)
                OR (p_object_version_number = l_object_version_number))
        THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
            FND_MESSAGE.SET_TOKEN('TABLE', 'HZ_PHONE_AREA_CODES');
            FND_MSG_PUB.ADD;
            x_return_status := FND_API.G_RET_STS_ERROR;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        p_object_version_number := nvl(l_object_version_number, 1) + 1;

    EXCEPTION WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
        FND_MESSAGE.SET_TOKEN('RECORD', 'HZ_PHONE_AREA_CODES');
        FND_MESSAGE.SET_TOKEN('VALUE', 'territory_code+area_code');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END;

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	if l_area_code <> p_area_code
	then
		duplicate_area_code(p_territory_code,p_area_code, x_return_status);
		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			RAISE FND_API.G_EXC_ERROR;
		END IF;
	end if;

	HZ_PHONE_AREA_CODES_PKG.update_row(
                    p_rowid      => l_rowid,
                    p_TERRITORY_CODE                       =>p_TERRITORY_CODE,
                    p_AREA_CODE                            =>p_AREA_CODE,
                    p_PHONE_COUNTRY_CODE                   =>fnd_api.g_miss_char,
                    p_DESCRIPTION                          =>p_DESCRIPTION,
                    p_CREATED_BY                           =>hz_utility_v2pub.created_by,
                    p_CREATION_DATE                        =>hz_utility_v2pub.creation_date,
                    p_LAST_UPDATE_LOGIN                    => hz_utility_v2pub.last_update_login,
                    p_LAST_UPDATE_DATE                     => hz_utility_v2pub.last_update_date,
                    p_LAST_UPDATED_BY                      =>hz_utility_v2pub.last_updated_by,
                    p_OBJECT_VERSION_NUMBER		   =>l_object_version_number,
		    p_TIMEZONE_ID			   =>p_TIMEZONE_ID );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK to update_area_code;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                        p_encoded => FND_API.G_FALSE,
                        p_count => x_msg_count,
                        p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK to update_area_code;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                        p_encoded => FND_API.G_FALSE,
                        p_count => x_msg_count,
                        p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK to update_area_code;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;

        FND_MSG_PUB.Count_And_Get(
                        p_encoded => FND_API.G_FALSE,
                        p_count => x_msg_count,
                        p_data  => x_msg_data);
end;
function areacode_timezone_exist(p_territory_code in varchar2) return varchar2 is

	cursor areacode_timezone_exist_csr is
		select 'Y'
		from hz_phone_area_codes
		where territory_code = p_territory_code
		and timezone_id is not null;

l_exist varchar2(1);
begin
	open areacode_timezone_exist_csr;
	fetch areacode_timezone_exist_csr into l_exist;
	close areacode_timezone_exist_csr;
	if l_exist = 'Y'
	then return 'Y';
	else return  'N';
	end if;
end;

PROCEDURE update_country_timezone(
  p_territory_code        IN VARCHAR2,
  p_timezone_id           IN NUMBER,
  p_object_version_number IN OUT NOCOPY NUMBER,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2) is

l_exist_flag varchar2(1);
l_object_version_number number;
begin
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	fnd_msg_pub.initialize;

	  BEGIN
        SELECT OBJECT_VERSION_NUMBER
        INTO   l_object_version_number
        FROM   HZ_PHONE_COUNTRY_CODES
        WHERE  TERRITORY_CODE = p_territory_code
        FOR UPDATE OF TERRITORY_CODE NOWAIT;

        IF NOT ((p_object_version_number is null and l_object_version_number is
null)
                OR (p_object_version_number = l_object_version_number))
        THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
            FND_MESSAGE.SET_TOKEN('TABLE', 'HZ_PHONE_COUNTRY_CODES');
            FND_MSG_PUB.ADD;
            x_return_status := FND_API.G_RET_STS_ERROR;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        p_object_version_number := nvl(l_object_version_number, 1) + 1;

    EXCEPTION WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
        FND_MESSAGE.SET_TOKEN('RECORD', 'HZ_PHONE_AREA_CODES');
        FND_MESSAGE.SET_TOKEN('VALUE', 'territory_code+area_code');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END;

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;


	update hz_phone_country_codes
	set  timezone_id = p_timezone_id,
	object_version_number =  nvl(l_object_version_number, 1) + 1,
	-- Bug 3032780
        --CREATED_BY                           =hz_utility_v2pub.created_by,
        --CREATION_DATE                        =hz_utility_v2pub.creation_date,
        LAST_UPDATE_LOGIN                    = hz_utility_v2pub.last_update_login,
        LAST_UPDATE_DATE                     = hz_utility_v2pub.last_update_date,
        LAST_UPDATED_BY                      =hz_utility_v2pub.last_updated_by
	where territory_code = p_territory_code;

	If (SQL%NOTFOUND) then
		x_return_status := FND_API.G_RET_STS_ERROR;
		RAISE NO_DATA_FOUND;
	End If;

        l_exist_flag := areacode_timezone_exist(p_territory_code);
        -- if timezone is entered from country level, delete area code level timezone
	if p_timezone_id is not null and l_exist_flag = 'Y'
	then
		update hz_phone_area_codes
		set timezone_id = null,
		object_version_number = nvl(object_version_number,1)+1,
	-- Bug 3032780
        --      CREATED_BY                           =hz_utility_v2pub.created_by,
	--	CREATION_DATE                        =hz_utility_v2pub.creation_date,
		LAST_UPDATE_LOGIN                    = hz_utility_v2pub.last_update_login,
		LAST_UPDATE_DATE                     = hz_utility_v2pub.last_update_date,
		LAST_UPDATED_BY                      =hz_utility_v2pub.last_updated_by
		where territory_code = p_territory_code;
	end if;

end;


END HZ_TIMEZONE_UTILS_PVT;

/
