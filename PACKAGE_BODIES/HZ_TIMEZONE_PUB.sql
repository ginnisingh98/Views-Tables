--------------------------------------------------------
--  DDL for Package Body HZ_TIMEZONE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_TIMEZONE_PUB" as
/*$Header: ARHTMZOB.pls 120.19 2006/08/14 00:59:33 kbaird ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'HZ_TIMEZONE_PUB';

/*===========================================================================+
 | PROCEDURE                                                                 |
 |              Get_Timezone_ID                                              |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              Get Timezone ID given the address element.                   |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_api_version                                          |
 |                    p_init_msg_list                                        |
 |		      p_postal_code					     |
 |		      p_city						     |
 |		      p_state						     |
 |		      p_country                 			     |
 |              OUT:                                                         |
 |                    x_return_status                                        |
 |                    x_msg_count                                            |
 |                    x_msg_data                                             |
 |                    x_timezone_id                                          |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES 								     |
 |									     |
 | MODIFICATION HISTORY                                                      |
 |    Stephanie Zhang   23-AUG-99  Created                                   |
 |                                                                           |
 +===========================================================================*/
Procedure Get_Timezone_ID
(
  p_api_version         in      number,
 -- p_init_msg_list       in      varchar2:= FND_API.G_FLASE	,
  p_init_msg_list       in      varchar2,
  p_postal_code		in	varchar2,
  p_city		in	varchar2,
  p_state		in	varchar2,
  p_country		in	varchar2,
  x_timezone_id		out nocopy	number,
  x_return_status	out nocopy	varchar2,
  x_msg_count           out nocopy     number,
  x_msg_data            out nocopy     varchar2)
IS
  l_api_name              CONSTANT VARCHAR2(30) := 'Get_Timezone_ID';
  l_api_version           CONSTANT  NUMBER       := 1.0;

  l_msg_token		VARCHAR2(2000);
BEGIN

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

 BEGIN
-- postal_code is unique within a country.   There should never be more than one mapping row
-- for the same postal code within the same country.   Thus, if the postal code and country are passed in
-- and a match on that postal code and country are found, that is the correct time zone (without regard
-- to the city or state on the mapping row or the city or state passed in)
   SELECT timezone_id
   INTO   x_timezone_id
   FROM   HZ_TIMEZONE_MAPPING
   WHERE  postal_code = p_postal_code
   AND    country = p_country;
  EXCEPTION WHEN NO_DATA_FOUND THEN
-- if no postal code direct match is found, then start walking the geographic hierarchy.
-- match first at city level, then state, then country.
-- Since state is not required in many countries of the world, there are slightly
-- different checks for the case where people expect state to be passed and when not.
-- We need to avoid the case where a city and country are passed and there might be multiple
-- cities in the same country with the same name.   City and Country cannot be used
-- to match a mapping row without a state present.
   IF (p_state is null) THEN   --compare all, no state
     BEGIN
	 SELECT timezone_id
 	 INTO   x_timezone_id
 	 FROM   HZ_TIMEZONE_MAPPING
 	 WHERE  postal_code = p_postal_code
 	 AND	upper(city) = upper(p_city)
 	 AND    state is null
 	 AND    country = p_country;
     EXCEPTION WHEN NO_DATA_FOUND THEN --compare city, no state
       BEGIN
 	   SELECT timezone_id
 	   INTO   x_timezone_id
 	   FROM   HZ_TIMEZONE_MAPPING
 	   WHERE postal_code is null
 	   AND	upper(city) = upper(p_city)
 	   AND    state is null
 	   AND    country = p_country;
      EXCEPTION WHEN NO_DATA_FOUND THEN --compare country, no state
        BEGIN
 	     SELECT timezone_id
 	     INTO   x_timezone_id
 	     FROM   HZ_TIMEZONE_MAPPING
 	     WHERE  postal_code is null
 	     AND    city is null
 	     AND    state is null
 	     AND    country = p_country;
        EXCEPTION WHEN NO_DATA_FOUND THEN  --not found
          FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
          FND_MESSAGE.SET_TOKEN('RECORD', 'mapping');
	  --------Bug no: 3565475--------------------
	  IF  p_postal_code IS NOT NULL and p_postal_code <> fnd_api.g_miss_char THEN
              l_msg_token := p_postal_code||',';
          END IF;
  	  IF  p_city IS NOT NULL and p_city <> fnd_api.g_miss_char THEN
              l_msg_token := l_msg_token||p_city||',';
          END IF;
  	  IF  p_state IS NOT NULL and p_state <> fnd_api.g_miss_char THEN
              l_msg_token := l_msg_token||p_state||',';
          END IF;
  	  IF  p_country IS NOT NULL and p_country <> fnd_api.g_miss_char THEN
              l_msg_token := l_msg_token||p_country||',';
          END IF;
	  l_msg_token := substrb(l_msg_token,1,instrb(l_msg_token,',',-1)-1);
	  FND_MESSAGE.SET_TOKEN('VALUE', l_msg_token);
          --FND_MESSAGE.SET_TOKEN('VALUE', p_postal_code||','||p_city||','||p_state||','||p_country);
	  ------End of Bug no: 3565475----------------
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        END; -- compare country, no state
     END; -- compare city, no state
   END; -- compare all, no state

  ELSE  -- if state is passed

   BEGIN -- compare all
 	 SELECT timezone_id
 	 INTO   x_timezone_id
 	 FROM   HZ_TIMEZONE_MAPPING
 	 WHERE  postal_code = p_postal_code
 	 AND	upper(city) = upper(p_city)
 	 AND    state = p_state
 	 AND    country = p_country;
   EXCEPTION WHEN NO_DATA_FOUND THEN --compare city, state, country
      BEGIN
 	   SELECT timezone_id
 	   INTO   x_timezone_id
 	   FROM   HZ_TIMEZONE_MAPPING
 	   WHERE postal_code is null
 	   AND	upper(city) = upper(p_city)
 	   AND    state = p_state
 	   AND    country = p_country;
      EXCEPTION WHEN NO_DATA_FOUND THEN --compare state, country
        BEGIN
 	     SELECT timezone_id
 	     INTO   x_timezone_id
 	     FROM   HZ_TIMEZONE_MAPPING
 	     WHERE  postal_code is null
 	     AND    city is null
 	     AND    state = p_state
 	     AND    country = p_country;
      EXCEPTION WHEN NO_DATA_FOUND THEN --compare country
        BEGIN
 	     SELECT timezone_id
 	     INTO   x_timezone_id
 	     FROM   HZ_TIMEZONE_MAPPING
 	     WHERE  postal_code is null
 	     AND    city is null
 	     AND    state is null
 	     AND    country = p_country;
        EXCEPTION WHEN NO_DATA_FOUND THEN
          FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
          FND_MESSAGE.SET_TOKEN('RECORD', 'mapping');
	  --------Bug no: 3565475--------------------
	  IF  p_postal_code IS NOT NULL and p_postal_code <> fnd_api.g_miss_char THEN
              l_msg_token := p_postal_code||',';
          END IF;
  	  IF  p_city IS NOT NULL and p_city <> fnd_api.g_miss_char THEN
              l_msg_token := l_msg_token||p_city||',';
          END IF;
  	  IF  p_state IS NOT NULL and p_state <> fnd_api.g_miss_char THEN
              l_msg_token := l_msg_token||p_state||',';
          END IF;
  	  IF  p_country IS NOT NULL and p_country <> fnd_api.g_miss_char THEN
              l_msg_token := l_msg_token||p_country||',';
          END IF;
	  l_msg_token := substrb(l_msg_token,1,instrb(l_msg_token,',',-1)-1);
	  FND_MESSAGE.SET_TOKEN('VALUE', l_msg_token);
          --FND_MESSAGE.SET_TOKEN('VALUE', p_postal_code||','||p_city||','||p_state||','||p_country);
	  ------End of Bug no: 3565475----------------
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        END; --compare country
     END; --compare state, country
   END; --compare city, state, country
 END; --compare all
END IF; --if state is passed
END; --if postal code and country match

--Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
/* comment out arp_util.debug for fixing bug 3655764
                arp_util.debug('x_msg_count ' || to_char(x_msg_count));
                arp_util.debug('x_msg_data  '|| x_msg_data);
                arp_util.debug('EXC');
                arp_util.debug('error code : '|| to_char(SQLCODE));
                arp_util.debug('error text : '|| SQLERRM); */
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
/* comment out arp_util.debug for fixing bug 3655764
                arp_util.debug('x_msg_count ' || to_char(x_msg_count));
                arp_util.debug('x_msg_data  '|| x_msg_data);
                arp_util.debug('UNEXC'); */
        WHEN OTHERS THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
/* comment out arp_util.debug for fixing bug 3655764
                arp_util.debug('x_msg_count ' || to_char(x_msg_count));
                arp_util.debug('x_msg_count ' || to_char(x_msg_count));
                arp_util.debug('x_msg_data  '|| x_msg_data);
                arp_util.debug('OTHERS');
	        arp_util.debug('error code : '|| to_char(SQLCODE));
                arp_util.debug('error text : '|| SQLERRM); */
END  Get_Timezone_ID;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |              Get_Phone_Timezone_ID                                        |
 |                                                                           |
 | DESCRIPTION                                                               |
 |               Return timezone id by passing in area code and phone        |
 |               country code.                                               |
 |             parameter p_phone_prefix is for future use. No logic on it.   |
 |             p_country_code needed only if non-unique row returned.        |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_api_version                                          |
 |                    p_init_msg_list                                        |
 |		      p_phone_country_code (required)                        |
 |		      p_area_code	       				     |
 |		      p_phone_prefix  (for future use)	                     |
 |                    p_country_code(only need to pass in if two countries   |
 |                    have same phone_country_code / area code               |
 |                    passed in)                                             |
 |              OUT:                                                         |
 |                    x_return_status                                        |
 |                    x_msg_count                                            |
 |                    x_msg_data                                             |
 |                    x_timezone_id                                          |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES 						                     |
 |							                     |
 | MODIFICATION HISTORY                                                      |
 |    AWU     19-AUG-03  Created                                             |
 |                                                                           |
 +===========================================================================*/

  Procedure Get_Phone_Timezone_ID (
  p_api_version		in	number,
  p_init_msg_list     in      varchar2,
  p_phone_country_code  in      varchar2,
  p_area_code         in      varchar2,
  p_phone_prefix        in      varchar2,
  p_country_code        in     varchar2,
  x_timezone_id         out nocopy     number,
  x_return_status       out nocopy     varchar2,
  x_msg_count		out nocopy	number,
  x_msg_data		out nocopy	varchar2
) IS
  l_api_name              CONSTANT VARCHAR2(30) := 'Get_Phone_Timezone_ID';
  l_api_version           CONSTANT  NUMBER       := 1.0;

	cursor get_tz_by_pcc_csr is
		select timezone_id
		from hz_phone_country_codes
		where phone_country_code = p_phone_country_code;

	cursor get_tz_by_pcc_cc_csr is
		select timezone_id
		from hz_phone_country_codes
		where territory_code = p_country_code
		and phone_country_code = p_phone_country_code;

	cursor get_country_tz_count_csr is
		select count(*)
		from hz_phone_country_codes
		where phone_country_code = p_phone_country_code;

	cursor get_area_code_tzone_csr is
		select timezone_id
		from hz_phone_area_codes
		where phone_country_code = p_phone_country_code
		and area_code = p_area_code;

	cursor get_area_code_count_csr is
		select count(*)
		from hz_phone_area_codes
		where phone_country_code = p_phone_country_code
		and area_code = p_area_code;

	cursor get_area_code_tz_csr is
		select timezone_id
		from hz_phone_area_codes
		where phone_country_code = p_phone_country_code
		and area_code = p_area_code
		and territory_code = p_country_code;

l_count number := 0;
l_tz_count number := 0;

BEGIN

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
	x_timezone_id := null;

	if p_phone_country_code is null
	then
		FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
		FND_MESSAGE.SET_TOKEN( 'COLUMN', 'p_phone_country_code' );
		FND_MSG_PUB.ADD;
		x_return_status := FND_API.G_RET_STS_ERROR;
		RAISE FND_API.G_EXC_ERROR;
	else  -- phone_country_code is not null
		if p_area_code is not null
		then
			if p_country_code is not null
			then
				open get_area_code_tz_csr;
				fetch get_area_code_tz_csr into x_timezone_id;
				close get_area_code_tz_csr;

			else -- p_country_code is null
				open get_area_code_count_csr;
				fetch get_area_code_count_csr into l_tz_count;
				close get_area_code_count_csr;

				if l_tz_count >1 -- need country code to be passed in
				then
					FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
					FND_MESSAGE.SET_TOKEN( 'COLUMN', 'p_country_code' );
					FND_MSG_PUB.ADD;
					x_return_status := FND_API.G_RET_STS_ERROR;
					RAISE FND_API.G_EXC_ERROR;
				elsif l_tz_count = 1
				then
					open get_area_code_tzone_csr;
					fetch get_area_code_tzone_csr into x_timezone_id;
					close get_area_code_tzone_csr;
				end if;
			end if; -- country code is not null
		end if; -- p_area_code is not null

   -- other case such as l_tz_count = 0 or area_code not passed in, then logic below

		if x_timezone_id is null
		then
			open get_country_tz_count_csr;
			fetch get_country_tz_count_csr into l_count;
			close get_country_tz_count_csr;
			if l_count = 1
			then
				open get_tz_by_pcc_csr;
				fetch get_tz_by_pcc_csr into x_timezone_id;
				close get_tz_by_pcc_csr;
			elsif l_count > 1
			then
				if p_country_code is not null
				then
					open get_tz_by_pcc_cc_csr;
					fetch get_tz_by_pcc_cc_csr into x_timezone_id;
					close get_tz_by_pcc_cc_csr;
					if x_timezone_id is null
					then
						FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_DATA_FOUND');
						FND_MESSAGE.SET_TOKEN('COLUMN','phone_country_code+country_code');
						FND_MESSAGE.SET_TOKEN('TABLE', 'HZ_PHONE_COUNTRY_CODES');
						FND_MSG_PUB.ADD;
						x_return_status := FND_API.G_RET_STS_ERROR;
						RAISE FND_API.G_EXC_ERROR;
					end if; -- x_timezone_id is null

				else
					FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
					FND_MESSAGE.SET_TOKEN( 'COLUMN', 'country_code' );
					FND_MSG_PUB.ADD;
					x_return_status := FND_API.G_RET_STS_ERROR;
					 RAISE FND_API.G_EXC_ERROR;
				end if;
			elsif l_count = 0
			then
				FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_DATA_FOUND');
				FND_MESSAGE.SET_TOKEN('COLUMN','PHONE_COUNTRY_CODE');
				FND_MESSAGE.SET_TOKEN('TABLE', 'HZ_PHONE_COUNTRY_CODES');
				FND_MSG_PUB.ADD;
				x_return_status := FND_API.G_RET_STS_ERROR;
				RAISE FND_API.G_EXC_ERROR;
			end if; -- l_count = 1
		end if; -- if timezone_id is null
	end if;
	 FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data );

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
      FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
      FND_MSG_PUB.ADD;

      FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data );

end get_phone_timezone_id;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |              Get_Timezone_GMT_Deviation                                   |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              Get Timezone GMT Deviation, Name given the reference date    |
 |              and Timezone_id                                              |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_api_version                                          |
 |                    p_init_msg_list                                        |
 |		      	  p_date					     |
 |		      p_timezone_id					     |
 |              OUT:                                                         |
 |                    x_return_status                                        |
 |                    x_msg_count                                            |
 |                    x_msg_data                                             |
 |                    x_GMT_deviation 					     |
 |		      x_global_timezone_name			             |
 |		      x_name	                                             |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES 								     |
 |									     |
 | MODIFICATION HISTORY                                                      |
 |    Stephanie Zhang   23-AUG-99  Created                                   |
 |                                                                           |
 +===========================================================================*/
Procedure Get_Timezone_GMT_Deviation(
  p_api_version         in      number,
  p_init_msg_list       in      varchar2,
  p_timezone_id		  in	number,
  p_date		  in	date,
  x_GMT_deviation	  out nocopy	number,
  x_global_timezone_name  out nocopy	varchar2,
  x_name		  out nocopy	varchar2,
  x_return_status	  out nocopy	varchar2,
  x_msg_count            out nocopy     number,
  x_msg_data             out nocopy     varchar2)
IS
  l_api_name              CONSTANT VARCHAR2(30) := 'Get_Timezone_GMT_Deviation';
  l_api_version           CONSTANT  NUMBER       := 1.0;
  l_GMT_deviation	number;
  l_dst_flag		varchar2(1);
  l_date_in_gmt		date;
  l_timezone_code	varchar2(50);
BEGIN

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

/* this should be changed in the next release to get the global_timezone_name from the tzabbrev
   of v$timezone_names which is the database table of timezones, but we will leave it for now
   because some product may be using the %s substitution capability in order to turn a P%sT into
   PST or PDT based on dst - although I doubt it
*/

  BEGIN
  SELECT H.GLOBAL_TIMEZONE_NAME,
	 F.NAME,
	 F.GMT_OFFSET,
	 F.DAYLIGHT_SAVINGS_FLAG,
	 F.TIMEZONE_CODE
  INTO   x_global_timezone_name,
	 x_name,
	 l_GMT_deviation,
	 l_dst_flag,
	 l_timezone_code
  FROM 	 HZ_TIMEZONES H, FND_TIMEZONES_VL F
  WHERE  H.timezone_id = p_timezone_id
    AND  H.timezone_id = F.upgrade_tz_id;

  EXCEPTION WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
        FND_MESSAGE.SET_TOKEN('RECORD', 'timezone');
        FND_MESSAGE.SET_TOKEN('VALUE',  to_char(p_timezone_id));
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
  END;

  IF (l_dst_flag = 'N')THEN
	 x_GMT_deviation := l_GMT_Deviation;
  ELSIF (l_dst_flag = 'Y') then

/* Find the gmt deviation by converting the date to gmt and then finding the difference
   between the original date and the date in gmt.   This routine will fail with an unexpected
   error if the timezone_code that is stored in fnd_timezones does not match the tzname in
   v$timezone_names.  Check that the customer (or db instance) is running with the large timezone.dat
   file from the database.   There are two versions of the timezone.dat file available from the db
   and one has the whole list of timezones and the other has a smaller list.  Only the larger file
   has all the timezones which are supported in apps (present in fnd_timezones)
*/
   	l_date_in_gmt :=  to_timestamp_tz(to_char(p_date,'YYYY-MM-DD HH24:MI:SS') || ' ' || l_timezone_code,
                                        'YYYY-MM-DD HH24:MI:SS TZR') at time zone 'GMT';
	x_GMT_deviation := to_char((p_date-l_date_in_gmt)*24);

  END IF;

--Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);
EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
                arp_util.debug('x_msg_count ' || to_char(x_msg_count));
                arp_util.debug('x_msg_data  '|| x_msg_data);
                arp_util.debug('EXC');
                arp_util.debug('error code : '|| to_char(SQLCODE));
                arp_util.debug('error text : '|| SQLERRM);
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
                arp_util.debug('x_msg_count ' || to_char(x_msg_count));
                arp_util.debug('x_msg_data  '|| x_msg_data);
                arp_util.debug('UNEXC');
        WHEN OTHERS THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
                arp_util.debug('x_msg_count ' || to_char(x_msg_count));
                arp_util.debug('x_msg_data  '|| x_msg_data);
                arp_util.debug('OTHERS');
	        arp_util.debug('error code : '|| to_char(SQLCODE));
                arp_util.debug('error text : '|| SQLERRM);
END  Get_Timezone_GMT_Deviation;

/*===========================================================================+
 | FUNCTION                                                                  |
 |              Convert_DateTime		                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              Returns the datetime in the destination timezone,            |
 |              given the source datetime, source                            |
 |		timezone_id and destination timezone_id			     |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_source_tz_id				             |
 |		      p_dest_tz_id					     |
 |		      p_source_day_time					     |
 |                                                                           |
 | RETURNS    : datetime                                                     |
 |                                                                           |
 | NOTES 								     |
 |									     |
 | MODIFICATION HISTORY                                                      |
 |    Kris Doherty      03-SEP-03  Created                                   |
 +===========================================================================*/
Function Convert_DateTime(
   p_source_tz_id		   in  number,
   p_dest_tz_id		           in  number,
   p_source_day_time		   in  date
  ) RETURN DATE
IS
   l_dest_gmt_deviation         number;
   l_dest_tz_code               varchar2(50);
   l_source_tz_code		varchar2(50);
   l_dest_datetime		date;
   l_return_status	        varchar2(1);
   l_msg_count                  number;
   l_msg_data                   varchar2(2000);

BEGIN
   BEGIN
 	SELECT timezone_code
	  INTO l_dest_tz_code
	  FROM fnd_timezones_b
	 WHERE upgrade_tz_id = p_dest_tz_id;

 	SELECT timezone_code
	  INTO l_source_tz_code
	  FROM fnd_timezones_b
	 WHERE upgrade_tz_id = p_source_tz_id;

    EXCEPTION WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
        FND_MESSAGE.SET_TOKEN('RECORD', 'timezone');
        FND_MESSAGE.SET_TOKEN('VALUE', to_char(p_dest_tz_id)||to_char(p_source_tz_id));
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END;

return fnd_timezone_pub.adjust_datetime(p_source_day_time, l_source_tz_code, l_dest_tz_code);

EXCEPTION WHEN OTHERS THEN
  RAISE;
END Convert_DateTime;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |              Get_Time		                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              Get destination day time, given the source day time, source  |
 |		timezone_id and destination timezone_id			     |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_api_version                                          |
 |                    p_init_msg_list                                        |
 |		      p_source_tz_id				             |
 |		      p_dest_tz_id					     |
 |		      p_source_day_time					     |
 |              OUT:                                                         |
 |                    x_return_status                                        |
 |                    x_msg_count                                            |
 |                    x_msg_data                                             |
 |                    x_dest_day_time 					     |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES 								     |
 |									     |
 | MODIFICATION HISTORY                                                      |
 |    Stephanie Zhang   23-AUG-99  Created                                   |
 |    Kris Doherty      03-AUG-03  Modified to call Get_Time_and_Code        |
 |                                 we need to keep this signature as is      |
 |                                 for backward compatibility                |
 +===========================================================================*/
Procedure Get_Time(
   p_api_version                   IN  NUMBER,
   p_init_msg_list       	   in  varchar2,
   p_source_tz_id		   in  number,
   p_dest_tz_id		           in  number,
   p_source_day_time		   in  date,
   x_dest_day_time 		   out nocopy date,
   x_return_status                 out nocopy VARCHAR2,
   x_msg_count                     out nocopy NUMBER,
   x_msg_data                      out nocopy VARCHAR2)
IS
   l_api_name              CONSTANT VARCHAR2(30) := 'Get_Time';
   l_api_version           CONSTANT  NUMBER       := 1.0;
   l_dest_gmt_deviation         number;
   l_dest_tz_code               varchar2(5);

BEGIN

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

-- Validate that non null parameters have been passed
	IF ((p_source_tz_id is null) OR
	    (p_dest_tz_id is null) OR
            (p_source_day_time is null))
           THEN
		FND_MESSAGE.SET_NAME('AR', 'HZ_API_NULL_PARAMETER_RECEIVED');
		FND_MESSAGE.SET_TOKEN('PROC','Get_Time');
		FND_MESSAGE.SET_TOKEN('P_SOURCE_TZ_ID',p_source_tz_id);
		FND_MESSAGE.SET_TOKEN('P_DEST_TZ_ID',p_dest_tz_id);
		FND_MESSAGE.SET_TOKEN('P_SOURCE_DAY_TIME',p_source_day_time);
		FND_MSG_PUB.ADD;
		x_return_status := FND_API.G_RET_STS_ERROR;
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

        x_dest_day_time := hz_timezone_pub.convert_datetime(p_source_tz_id, p_dest_tz_id, p_source_day_time);

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
        WHEN OTHERS THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
END Get_Time;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |              Get_Time_and_Code		                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              Get destination day time, destination tz short code (which   |
 |              will be different if day is in daylight savings or not),     |
 |              and the destination tz offset from GMT (again for the given  |
 |              day as this also changes based on daylight savings)          |
 |              given the source day time, source                            |
 |		timezone_id and destination timezone_id			     |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_api_version                                          |
 |                    p_init_msg_list                                        |
 |		      p_source_tz_id				             |
 |		      p_dest_tz_id					     |
 |		      p_source_day_time					     |
 |              OUT:                                                         |
 |                    x_dest_day_time 					     |
 |                    x_dest_tz_code                                         |
 |                    x_dest_gmt_deviation                                   |
 |                    x_return_status                                        |
 |                    x_msg_count                                            |
 |                    x_msg_data                                             |

 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES 								     |
 |									     |
 | MODIFICATION HISTORY                                                      |
 |    Kris Baird   03-AUG-03  Created                                        |
 |                                                                           |
 +===========================================================================*/
Procedure Get_Time_and_Code(
   p_api_version                   IN  NUMBER,
   p_init_msg_list          	    in  varchar2,
   p_source_tz_id		    in  number,
   p_dest_tz_id		            in  number,
   p_source_day_time		    in  date,
   x_dest_day_time 		   out nocopy date,
   x_dest_tz_code         	   out nocopy varchar2,
   x_dest_gmt_deviation   	   out nocopy number,
   x_return_status                 out nocopy VARCHAR2,
   x_msg_count                     out nocopy NUMBER,
   x_msg_data                      out nocopy VARCHAR2)
IS
   l_api_name              CONSTANT VARCHAR2(30) := 'Get_Time_and_Code';
   l_api_version           CONSTANT  NUMBER       := 1.0;
   l_dest_day_time	        date;
   std_GMT_deviation		number;
   l_global_timezone_name	varchar2(50);
   l_name			varchar2(80);
   s_status			varchar2(1);
   s_msg_count			number;
   s_msg_data			varchar2(2000);
   d_GMT_deviation		number;
   d_dst_flag			varchar2(1);
   l_standard_short_code        varchar2(5);
   l_daylight_short_code        varchar2(5);

BEGIN

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

/* convert p_source_day_time to new timezone */
        l_dest_day_time := hz_timezone_pub.convert_datetime(p_source_tz_id, p_dest_tz_id, p_source_day_time);

/* now figure out if this is in dst or not in order to return the correct code */
/* if the gmt offset for this new timezone is the standard offset then it is not dst */

    SELECT GMT_DEVIATION_HOURS,
           STANDARD_TIME_SHORT_CODE,
           DAYLIGHT_SAVINGS_SHORT_CODE
    INTO   std_GMT_deviation,
           l_standard_short_code,
	   l_daylight_short_code
    FROM   HZ_TIMEZONES
    WHERE  timezone_id =  p_dest_tz_id;

   /* Get GMT Deviation for the dest day in the destination timezone */

    Get_Timezone_GMT_Deviation(1.0, 'F', p_dest_tz_id, l_dest_day_time,
	d_GMT_deviation, l_global_timezone_name, l_name, s_status,
		s_msg_count, s_msg_data);
    IF(s_status <> FND_API.G_RET_STS_SUCCESS )THEN
	FND_MESSAGE.SET_NAME('AR', 'HZ_API_RETURN_ERROR');
        FND_MESSAGE.SET_TOKEN('PROC', 'GET_GMT_DEVIATION');
        FND_MESSAGE.SET_TOKEN('VALUE',  to_char(p_dest_tz_id)||','
			||to_char(l_dest_day_time, 'MM-DD-RR')||','
			||to_char(p_dest_tz_id));
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

/* if the current offset is different than the standard offset, then it must be daylight savings */
    IF (std_GMT_deviation <> d_GMT_deviation) THEN
	x_dest_tz_code := l_daylight_short_code;
    ELSE
	x_dest_tz_code := l_standard_short_code;
    END IF;

    x_dest_gmt_deviation := d_GMT_deviation;
    x_dest_day_time := l_dest_day_time;

--Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
        WHEN OTHERS THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
END Get_Time_and_Code;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |              Get_Primary_Zone                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              Takes in an offset from GMT and a daylight savings rule      |
 |              and returns a default primary timezone which meets that      |
 |              definition.   This is to facilitate the automatic mapping    |
 |              of an address to a timezone in the future (when we integrate |
 |              with the spatial data which will have a more accurate        |
 |              timezone boundry definition                                  |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		 p_api_version                                               |
 |		 p_init_msg_list                                             |
 | 		 p_gmt_deviation_hours	                                     |
 |               p_daylight_savings_time_flag				     |
 | 		 p_begin_dst_month					     |
 | 		 p_begin_dst_day					     |
 | 		 p_begin_dst_week_of_month				     |
 | 		 p_begin_dst_day_of_week  				     |
 | 		 p_begin_dst_hour					     |
 | 		 p_end_dst_month					     |
 | 		 p_end_dst_day					             |
 | 		 p_end_dst_week_of_month				     |
 | 		 p_end_dst_day_of_week  				     |
 | 		 p_end_dst_hour					    	     |
 |									     |
 |              OUT:                                                         |
 |               x_timezone_id						     |
 |               x_timezone_name					     |
 |               x_timezone_code					     |
 |     		 x_return_status                                             |
 | 		 x_msg_count                                                 |
 |               x_msg_data                                                  |
 |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES 								     |
 |			 	        				     |
 | MODIFICATION HISTORY                                                      |
 |    Kris Baird   03-AUG-03  Created                                        |
 |                                                                           |
 +===========================================================================*/

PROCEDURE Get_Primary_Zone (
   p_api_version              in number,
   p_init_msg_list            in varchar2,
   p_gmt_deviation_hours      in number,
   p_daylight_savings_time_flag in varchar2,
   p_begin_dst_month            in varchar2,
   p_begin_dst_day              in number,
   p_begin_dst_week_of_month    in number,
   p_begin_dst_day_of_week      in number,
   p_begin_dst_hour             in number,
   p_end_dst_month              in varchar2,
   p_end_dst_day                in number,
   p_end_dst_week_of_month      in number,
   p_end_dst_day_of_week        in number,
   p_end_dst_hour               in number,
   x_timezone_id                out nocopy number,
   x_timezone_name              out nocopy varchar2,
   x_timezone_code              out nocopy varchar2,
   x_return_status              out nocopy varchar2,
   x_msg_count                  out nocopy number,
   x_msg_data                   out nocopy varchar2)
IS
   l_api_name              CONSTANT VARCHAR2(30) := 'Get_Primary_Zone';
   l_api_version           CONSTANT  NUMBER       := 1.0;

BEGIN

--Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call(
                                        l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
BEGIN

        select  h.timezone_id,
		f.name,
		f.timezone_code
        into    x_timezone_id,
                x_timezone_name,
                x_timezone_code
        from    hz_timezones_vl h, fnd_timezones_vl f
        where   h.timezone_id = f.upgrade_tz_id
	  and   h.gmt_deviation_hours = p_gmt_deviation_hours
          and   h.daylight_savings_time_flag = p_daylight_savings_time_flag
	  and   nvl(h.begin_dst_month,'-99') =  nvl(p_begin_dst_month,'-99')
	  and   nvl(h.begin_dst_day,-99)   =	nvl(p_begin_dst_day,-99)
	  and   nvl(h.begin_dst_week_of_month,-99) = 	nvl(p_begin_dst_week_of_month,-99)
	  and   nvl(h.begin_dst_day_of_week,-99) = 	nvl(p_begin_dst_day_of_week,-99)
	  and   nvl(begin_dst_hour,-99)  = nvl(p_begin_dst_hour,-99)
	  and   nvl(h.end_dst_month,'-99') =  nvl(p_end_dst_month,'-99')
	  and   nvl(h.end_dst_day,-99)   =	nvl(p_end_dst_day,-99)
	  and   nvl(h.end_dst_week_of_month,-99) = 	nvl(p_end_dst_week_of_month,-99)
	  and   nvl(h.end_dst_day_of_week,-99) = 	nvl(p_end_dst_day_of_week,-99)
	  and   nvl(end_dst_hour,-99) = nvl(p_end_dst_hour,-99)
          and   h.primary_zone_flag = 'Y';

      EXCEPTION WHEN NO_DATA_FOUND THEN
          FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
          FND_MESSAGE.SET_TOKEN('RECORD', 'zone mapping');
          FND_MESSAGE.SET_TOKEN('VALUE', to_char(p_gmt_deviation_hours)||
                                ','||p_daylight_savings_time_flag||','
				||p_begin_dst_month||','||to_char(p_begin_dst_day)
				||to_char(p_begin_dst_week_of_month)||','||to_char(p_begin_dst_day_of_week));
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;

        END;

--Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
                arp_util.debug('x_msg_count ' || to_char(x_msg_count));
                arp_util.debug('x_msg_data  '|| x_msg_data);
                arp_util.debug('EXC');
                arp_util.debug('error code : '|| to_char(SQLCODE));
                arp_util.debug('error text : '|| SQLERRM);
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
                arp_util.debug('x_msg_count ' || to_char(x_msg_count));
                arp_util.debug('x_msg_data  '|| x_msg_data);
                arp_util.debug('UNEXC');
        WHEN OTHERS THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
                arp_util.debug('x_msg_count ' || to_char(x_msg_count));
                arp_util.debug('x_msg_data  '|| x_msg_data);
                arp_util.debug('OTHERS');
	        arp_util.debug('error code : '|| to_char(SQLCODE));
                arp_util.debug('error text : '|| SQLERRM);
END Get_Primary_Zone;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |              Get_Timezone_Short_Code                                      |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              Takes in a datetime and a timezone id or a timezone_code     |
 |              and returns the gmt deviation, tz short code for that day    |
 |              and the tz name for display to an end user.                  |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		 p_api_version                                               |
 |		 p_init_msg_list                                             |
 | 		 p_timezone_id                                               |
 |               p_timezone_code                                             |
 | 		 p_date                                                      |
 |									     |
 |              OUT:                                                         |
 |               x_gmt_deviation                                             |
 |               x_timezone_short_code                                       |
 |               x_timezone_name					     |
 |     		 x_return_status                                             |
 | 		 x_msg_count                                                 |
 |               x_msg_data                                                  |
 |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES 								     |
 |			 	        				     |
 | MODIFICATION HISTORY                                                      |
 |    Kris Baird   03-AUG-03  Created                                        |
 |                                                                           |
 +===========================================================================*/
Procedure Get_Timezone_Short_Code
(
  p_api_version         in      number,
  p_init_msg_list       in      varchar2,
  p_timezone_id		in	number,
  p_timezone_code 	in      varchar2,
  p_date		in      date,
  x_gmt_deviation	out nocopy     number,
  x_timezone_short_code out nocopy     varchar2,
  x_name		out nocopy     varchar2,
  x_return_status	out nocopy     varchar2,
  x_msg_count           out nocopy     number,
  x_msg_data            out nocopy     varchar2)
IS
  l_api_name              CONSTANT VARCHAR2(30) := 'Get_Timezone_Short_Code';
  l_api_version           CONSTANT  NUMBER       := 1.0;
   l_gmt_deviation	   number;
   l_current_GMT_deviation number;
   l_date_in_gmt	   date;
   l_standard_short_code   varchar2(5);
   l_daylight_short_code   varchar2(5);
   l_timezone_id           number;
   l_timezone_code	   varchar2(50);

BEGIN

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

  IF (p_timezone_id is not null) THEN
  BEGIN

    SELECT F.GMT_OFFSET,
           H.STANDARD_TIME_SHORT_CODE,
           H.DAYLIGHT_SAVINGS_SHORT_CODE,
           F.NAME,
	   F.TIMEZONE_CODE
    INTO   l_gmt_deviation,
           l_standard_short_code,
	   l_daylight_short_code,
           x_name,
	   l_timezone_code
    FROM   HZ_TIMEZONES_VL H, FND_TIMEZONES_VL F
    WHERE  H.timezone_id =  p_timezone_id
      AND  H.timezone_id =  F.upgrade_tz_id;

    EXCEPTION WHEN NO_DATA_FOUND THEN
       		FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
        	FND_MESSAGE.SET_TOKEN('RECORD', 'timezone id');
        	FND_MESSAGE.SET_TOKEN('VALUE',  to_char(p_timezone_id));
        	FND_MSG_PUB.ADD;
        	RAISE FND_API.G_EXC_ERROR;
    END;
   ELSE
        BEGIN
	    SELECT f.GMT_OFFSET,
           	   h.STANDARD_TIME_SHORT_CODE,
           	   h.DAYLIGHT_SAVINGS_SHORT_CODE,
           	   f.NAME
    	   INTO    l_gmt_deviation,
           	   l_standard_short_code,
	   	   l_daylight_short_code,
           	   x_name
     	   FROM    FND_TIMEZONES_VL f, HZ_TIMEZONES_VL h
    	  WHERE    f.timezone_code =  p_timezone_code
            AND    f.upgrade_tz_id = h.timezone_id;

	l_timezone_code := p_timezone_code;

	 EXCEPTION WHEN NO_DATA_FOUND THEN
       		FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
        	FND_MESSAGE.SET_TOKEN('RECORD', 'timezone code');
        	FND_MESSAGE.SET_TOKEN('VALUE', p_timezone_code);
        	FND_MSG_PUB.ADD;
        	RAISE FND_API.G_EXC_ERROR;
    	 END;

  END IF;

/* find out what this date is in gmt so I can then find the current offset (since the db does not expose the
   offset values, we have to do a little math to calculate it
*/

   l_date_in_gmt :=  to_timestamp_tz(to_char(p_date,'YYYY-MM-DD HH24:MI:SS') || ' ' || l_timezone_code,
                                        'YYYY-MM-DD HH24:MI:SS TZR') at time zone 'GMT';
   l_current_GMT_deviation := to_char((p_date-l_date_in_gmt)*24);


/* if the current offset is different than the standard offset, then it must be daylight savings */

    IF (l_GMT_deviation <> l_current_GMT_deviation) THEN
	x_timezone_short_code := l_daylight_short_code;
    ELSE
	x_timezone_short_code := l_standard_short_code;
    END IF;

    x_gmt_deviation := l_current_GMT_deviation;

--Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
        WHEN OTHERS THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
END  Get_Timezone_Short_Code;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |              Get_begin_end_dst_day_time                                   |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              THIS ROUTINE IS OBSOLETE AND SHOULD NO LONGER BE USED        |
 |              DAYLIGHT SAVINGS INFORMATION SHOULD BE TAKEN FROM THE DATABASE
 |              TIMEZONE DEFINITIONS AND NOT FROM THE HZ DEFINITIONS         |
 |              Get the begin/end daylight saving day and time               |
 | 	           in date data type by constructing each component stored in
 |			 the timezone table, given the year and the timezone_id.
 | SCOPE - OBSOLETE                                                          |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              	  p_year                       		             |
 |		      	  p_timezone_id					     |
 |              OUT:                                                         |
 |                    x_begin_dst_date                                       |
 |                    x_end_dst_date                                         |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES 								     |
 |									     |
 | MODIFICATION HISTORY                                                      |
 |    Stephanie Zhang   23-AUG-99  Created                                   |
 |                                                                           |
 +===========================================================================*/

Procedure Get_begin_end_dst_day_time(
  p_year		in	varchar2,
  p_timezone_id		in	number,
  x_begin_dst_date	out nocopy	date,
  x_end_dst_date	out nocopy 	date
) IS
  v_dst_flag		varchar2(1);
  v_begin_dst_month	varchar2(3);
  v_begin_dst_day	number;
  v_begin_dst_week_of_m number;
  v_begin_dst_day_of_w	number;
  v_begin_dst_hour	number;
  v_end_dst_month	varchar2(3);
  v_end_dst_day		number;
  v_end_dst_week_of_m	number;
  v_end_dst_day_of_w	number;
  v_end_dst_hour	number;
  v_date		date:= null;
BEGIN
  SELECT DAYLIGHT_SAVINGS_TIME_FLAG,
	 LPAD(BEGIN_DST_MONTH,2,'0'),
	 BEGIN_DST_DAY,
	 BEGIN_DST_WEEK_OF_MONTH,
	 BEGIN_DST_DAY_OF_WEEK,
	 BEGIN_DST_HOUR,
	 LPAD(END_DST_MONTH,2,'0'),
	 END_DST_DAY,
	 END_DST_WEEK_OF_MONTH,
	 END_DST_DAY_OF_WEEK,
 	 END_DST_HOUR
  INTO   v_dst_flag,
	 v_begin_dst_month,
	 v_begin_dst_day,
  	 v_begin_dst_week_of_m,
 	 v_begin_dst_day_of_w,
  	 v_begin_dst_hour,
  	 v_end_dst_month,
  	 v_end_dst_day,
  	 v_end_dst_week_of_m,
  	 v_end_dst_day_of_w,
  	 v_end_dst_hour
  FROM 	 HZ_TIMEZONES_VL
  WHERE  timezone_id = p_timezone_id;

  IF(v_dst_flag = 'N')THEN
	x_begin_dst_date := null;
	x_end_dst_date := null;
 	return;
  ELSIF(v_dst_flag = 'Y')THEN
         IF(v_begin_dst_day is not NULL)THEN
	 x_begin_dst_date := to_date(v_begin_dst_month||
		'-'||to_char(v_begin_dst_day)||
		'-'||p_year||
		' '||to_char(trunc(v_begin_dst_hour))||
                ' '||to_char(round((v_begin_dst_hour - trunc(v_begin_dst_hour))*60,2)),
                'MM-DD-YYYY HH24 MI');
	 ELSE
	     IF(v_begin_dst_week_of_m <> -1)THEN
               Get_date_from_W_and_D(p_year, v_begin_dst_month,
		   to_char(v_begin_dst_week_of_m),
		   to_char(v_begin_dst_day_of_w),
	           v_date);
	       IF v_date is null THEN
		    FND_MESSAGE.SET_NAME('AR', 'HZ_API_RETURN_ERROR');
       		    FND_MESSAGE.SET_TOKEN('PROC', 'Get_date_from_W_and_D');
          	    FND_MESSAGE.SET_TOKEN('VALUE', p_year||','
			||v_begin_dst_month
			||','||to_char(v_begin_dst_week_of_m)
			||','||to_char(v_begin_dst_day_of_w));
          	    FND_MSG_PUB.ADD;
        	    RAISE FND_API.G_EXC_ERROR;
	       END IF;
	       x_begin_dst_date := to_date(to_char(v_date, 'MM-DD-YYYY')||
		' '||to_char(trunc(v_begin_dst_hour))||
                ' '||to_char(round((v_begin_dst_hour - trunc(v_begin_dst_hour))*60,2)),
                'MM-DD-YYYY HH24 MI');
	     ELSE
	     /* -1 means begin daylight saving week is the last week
		of the month, we have to figure out whether
		the last week is the 4th or 5th
	     */
		Get_date_from_W_and_D(p_year, v_begin_dst_month,
                   '5',
                   to_char(v_begin_dst_day_of_w),
                   v_date);
	     	IF(to_char(v_date, 'MM') = v_begin_dst_month)THEN
		   /* The 5th week is the last week of the month  */
		   x_begin_dst_date := to_date(to_char(v_date, 'MM-DD-YYYY')||
		   ' '||to_char(trunc(v_begin_dst_hour))||
                   ' '||to_char(round((v_begin_dst_hour - trunc(v_begin_dst_hour))*60,2)),
                   'MM-DD-YYYY HH24 MI');
	     	ELSE
		  Get_date_from_W_and_D(p_year, v_begin_dst_month,
                   '4',
                   to_char(v_begin_dst_day_of_w),
                   v_date);
                   x_begin_dst_date := to_date(to_char(v_date, 'MM-DD-YYYY')||
		   ' '||to_char(trunc(v_begin_dst_hour))||
                   ' '||to_char(round((v_begin_dst_hour - trunc(v_begin_dst_hour))*60,2)),
                   'MM-DD-YYYY HH24 MI');
	        END IF;
	     END IF;
	 END IF;

	 IF(v_end_dst_day is not NULL)THEN
         x_end_dst_date := to_date(v_end_dst_month||
                '-'||to_char(v_end_dst_day)||
                '-'||p_year||
	        ' '||to_char(trunc(v_end_dst_hour))||
                ' '||to_char(round((v_end_dst_hour - trunc(v_end_dst_hour))*60,2)),
                'MM-DD-YYYY HH24 MI');
         ELSE
             IF(v_end_dst_week_of_m <> -1)THEN
		Get_date_from_W_and_D(p_year, v_end_dst_month,
                   to_char(v_end_dst_week_of_m),
                   to_char(v_end_dst_day_of_w),
                   v_date);
		IF v_date is null THEN
		    FND_MESSAGE.SET_NAME('AR', 'HZ_API_RETURN_ERROR');
       		    FND_MESSAGE.SET_TOKEN('PROC', 'Get_date_from_W_and_D');
          	    FND_MESSAGE.SET_TOKEN('VALUE', p_year||','||v_end_dst_month
				||','||to_char(v_end_dst_week_of_m)
				||','||to_char(v_end_dst_day_of_w));
          	    FND_MSG_PUB.ADD;
        	    RAISE FND_API.G_EXC_ERROR;
	        END IF;
                x_end_dst_date := to_date(to_char(v_date, 'MM-DD-YYYY')
	        ||' '||to_char(trunc(v_end_dst_hour))||
                ' '||to_char(round((v_end_dst_hour - trunc(v_end_dst_hour))*60,2)),
                'MM-DD-YYYY HH24 MI');
             ELSE
                Get_date_from_W_and_D(p_year, v_end_dst_month,
		   '5',
                   to_char(v_end_dst_day_of_w),
                   v_date);
                IF(to_char(v_date, 'MM') = v_end_dst_month)THEN
                   x_end_dst_date := to_date(to_char(v_date, 'MM-DD-YYYY')
	             ||' '||to_char(trunc(v_end_dst_hour))||
                     ' '||to_char(round((v_end_dst_hour - trunc(v_end_dst_hour))*60,2)),
                     'MM-DD-YYYY HH24 MI');
                ELSE
		   Get_date_from_W_and_D(p_year, v_end_dst_month,
                   '4',
                   to_char(v_end_dst_day_of_w),
                   v_date);
                   x_end_dst_date := to_date(to_char(v_date, 'MM-DD-YYYY')
	             ||' '||to_char(trunc(v_end_dst_hour))||
                     ' '||to_char(round((v_end_dst_hour - trunc(v_end_dst_hour))*60,2)),
                     'MM-DD-YYYY HH24 MI');
                END IF;
             END IF;
         END IF;
  END IF;
EXCEPTION WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
        FND_MESSAGE.SET_TOKEN('RECORD', 'timezone');
        FND_MESSAGE.SET_TOKEN('VALUE', to_char(p_timezone_id));
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
END Get_begin_end_dst_day_time;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |              Get_date_from_W_and_D                                        |
 |                                                                           |
 | DESCRIPTION                                                               |
 |              Get the date (in date format) given the year, month, week of |
 |			 the month, day of the week.		             |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_year                       		             |
 |		      	  p_month				             |
 |		      	  p_week					     |
 |		      	  p_day						     |
 |              OUT:                                                         |
 |                    x_date   		                                     |
 |          IN/ OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES 								     |
 |									     |
 | MODIFICATION HISTORY                                                      |
 |    Stephanie Zhang   23-AUG-99  Created                                   |
 |                                                                           |
 +===========================================================================*/

PROCEDURE Get_date_from_W_and_D (
  p_year	in 	varchar2,
  p_month	in	varchar2,
  p_week	in      varchar2,
  p_day		in	varchar2,
  x_date	out nocopy	varchar2)
IS
  l_date		date;
  l_first_date_of_m     date;
  l_last_date_of_m	date;
  l_week_of_m		varchar2(1);
  l_day_of_w		varchar2(1);
  l_total	 	number;
  l_db_sunday           number;
  l_day                 number;
BEGIN
  -- Initialize first_date as first day of the month
  l_first_date_of_m := to_date(p_year||' '||p_month||' '||'01', 'YYYY MM DD');
  l_last_date_of_m := last_day(l_first_date_of_m);
  l_total := l_last_date_of_m - l_first_date_of_m;
  l_date := l_first_date_of_m;
  l_day := to_number(p_day);

-- the p_day passed in is from the timezone data seeded in apps.  this is always
-- the day of the week assuming that sunday is day 1.
-- the database allows configuration of which day of the week is day one, so
-- we have to see what the database thinks a sunday is and then adjust p_day
-- accordingly.  we know that 01-01-1978 was a sunday so we test that date.

    l_db_sunday := to_number(to_char(to_date('01-01-1978','DD-MM-YYYY'),'D'));

    IF (l_db_sunday = 1) THEN NULL;
    ELSIF (l_day > (8- l_db_sunday))
         THEN l_day := l_day - (8- l_db_sunday);
    ELSIF (l_day <= (8- l_db_sunday))
         THEN l_day := l_day + l_db_sunday -1;
    END IF;

  for i in 0..l_total LOOP
  	l_date := l_first_date_of_m + i ;
    /* Bug Fix 2651358
    select to_char(l_date, 'W'),
	   to_char(l_date, 'D')
    into   l_week_of_m,
	   l_day_of_w
    from   sys.dual;
    */

    IF     (to_char(l_date, 'W') = p_week) and (to_number(to_char(l_date, 'D')) = l_day) THEN
	      x_date := l_date;
        return;
    END IF;
  END LOOP;
END Get_date_from_W_and_D;


END HZ_TIMEZONE_PUB;

/
