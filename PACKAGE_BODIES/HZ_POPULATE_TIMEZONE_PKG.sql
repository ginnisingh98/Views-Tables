--------------------------------------------------------
--  DDL for Package Body HZ_POPULATE_TIMEZONE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_POPULATE_TIMEZONE_PKG" AS
/* $Header: ARHTZCPB.pls 115.4 2004/06/09 19:50:22 awu noship $ */

PROCEDURE Debug_Message(
    p_msg_level IN NUMBER,
--    p_app_name IN VARCHAR2 := 'AR',
    p_msg       IN VARCHAR2)
IS
l_length    NUMBER;
l_start     NUMBER := 1;
l_substring VARCHAR2(50);
BEGIN
    IF FND_MSG_PUB.Check_Msg_Level(p_msg_level)
    THEN
/*
        l_length := lengthb(p_msg);

        -- FND_MESSAGE doesn't allow message name to be over 30 chars
        -- chop message name if length > 30
        WHILE l_length > 30 LOOP
            l_substring := substrb(p_msg, l_start, 30);

            FND_MESSAGE.Set_Name('AR', l_substring);
--          FND_MESSAGE.Set_Name(p_app_name, l_substring);
            l_start := l_start + 30;
            l_length := l_length - 30;
            FND_MSG_PUB.Add;
        END LOOP;

        l_substring := substrb(p_msg, l_start);
        FND_MESSAGE.Set_Name('AR', l_substring);
--        dbms_output.put_line('l_substring: ' || l_substring);
--      FND_MESSAGE.Set_Name(p_app_name, p_msg);
        FND_MSG_PUB.Add;
*/
        l_length := lengthb(p_msg);

        -- FND_MESSAGE doesn't allow application name to be over 30 chars
        -- chop message name if length > 30
        IF l_length > 30
        THEN
            l_substring := substrb(p_msg, l_start, 30);
            FND_MESSAGE.Set_Name('AR', l_substring);
       --     FND_MESSAGE.Set_Name(l_substring, '');
        ELSE
            FND_MESSAGE.Set_Name('AR', p_msg);
       --     FND_MESSAGE.Set_Name(p_msg, '');
        END IF;

        FND_MSG_PUB.Add;
    END IF;
END Debug_Message;


PROCEDURE write_log(p_debug_source NUMBER, p_fpt number, p_mssg  varchar2) IS
BEGIN
     IF p_debug_source = G_DEBUG_CONCURRENT THEN
            -- p_fpt (1,2)?(log : output)
            FND_FILE.put(p_fpt, p_mssg);
            FND_FILE.NEW_LINE(p_fpt, 1);
            -- If p_fpt == 2 and debug flag then also write to log file
            IF p_fpt = 2 And G_Debug THEN
               FND_FILE.put(1, p_mssg);
               FND_FILE.NEW_LINE(1, 1);
            END IF;
     END IF;

    IF G_Debug AND p_debug_source = G_DEBUG_TRIGGER THEN
        -- Write debug message to message stack
            Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, p_mssg);
    END IF; -- G_Debug

    EXCEPTION
        WHEN OTHERS THEN
         NULL;
END Write_Log;

PROCEDURE log(
   message 	IN	VARCHAR2,
   newline	IN	BOOLEAN DEFAULT TRUE) IS
BEGIN

  IF message = 'NEWLINE' THEN
   FND_FILE.NEW_LINE(FND_FILE.LOG, 1);
  ELSIF (newline) THEN
    FND_FILE.put_line(fnd_file.log,message);
  ELSE
    FND_FILE.put(fnd_file.log,message);
  END IF;
END log;


-- private get_phone_timezone_id. No error message raised, only set timezone_id
--  to null if error for bug 3639702
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

--Initialize API return status to success.
        x_return_status := FND_API.G_RET_STS_SUCCESS;
	x_timezone_id := null;

	if p_phone_country_code is null
	then
		x_timezone_id := null;
		x_return_status := FND_API.G_RET_STS_ERROR;
		return;
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
					x_timezone_id := null;
					x_return_status := FND_API.G_RET_STS_ERROR;
					return;
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
						x_timezone_id := null;
						x_return_status := FND_API.G_RET_STS_ERROR;
						return;
					end if; -- x_timezone_id is null

				else
					x_timezone_id := null;
					x_return_status := FND_API.G_RET_STS_ERROR;
					return;
				end if;
			elsif l_count = 0
			then
				x_timezone_id := null;
				x_return_status := FND_API.G_RET_STS_ERROR;
				return;
			end if; -- l_count = 1
		end if; -- if timezone_id is null
	end if;

EXCEPTION

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     /* FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
      FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
      FND_MSG_PUB.ADD; */
     log('Unexpected Error: '||SQLERRM);

end get_phone_timezone_id;


PROCEDURE PHONE_TIMEZONE(errbuf OUT NOCOPY VARCHAR2, retcode OUT NOCOPY
VARCHAR2, p_overwrite_flag IN varchar2) is

	cursor phone_csr is
	  SELECT contact_point_id, phone_country_code, phone_area_code
          FROM hz_contact_points cp
          WHERE contact_point_type = 'PHONE';

	cursor phone_tz_csr is
	  SELECT contact_point_id, phone_country_code, phone_area_code
          FROM hz_contact_points cp
          WHERE contact_point_type = 'PHONE'
	  and timezone_id is null;


    TYPE PHONE_COUNTRY_CODEList  IS TABLE OF HZ_CONTACT_POINTS.PHONE_COUNTRY_CODE%TYPE;
    TYPE PHONE_AREA_CODEList     IS TABLE OF HZ_CONTACT_POINTS.PHONE_AREA_CODE%TYPE;
    TYPE CONTACT_POINT_IDList    IS TABLE OF HZ_CONTACT_POINTS.CONTACT_POINT_ID%TYPE;

    I_PHONE_COUNTRY_CODE        PHONE_COUNTRY_CODEList;
    I_PHONE_AREA_CODE           PHONE_AREA_CODEList;
    I_CONTACT_POINT_ID          CONTACT_POINT_IDList;

    i                           NUMBER;
    rows                        NUMBER := 1000;
    i_commit                    NUMBER;
    commit_counter              NUMBER;
    l_last_fetch                BOOLEAN;
    l_timezone_id		number;
    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);
    l_status varchar2(255);

BEGIN

    log('Process began @: ' || to_char(sysdate,'DD-MON-RRRR:HH:MI:SS'));

    retcode:=0;
    i_commit := 0;
    commit_counter := 1000;
    l_last_fetch:=false;

 if p_overwrite_flag = 'Y'
 then
    /* for each phone we selected */
    OPEN phone_csr;
    LOOP
       FETCH phone_csr BULK COLLECT INTO
          I_CONTACT_POINT_ID, I_PHONE_COUNTRY_CODE, I_PHONE_AREA_CODE LIMIT rows;

       IF phone_csr%NOTFOUND THEN
          l_last_fetch := TRUE;
       END IF;
       IF I_CONTACT_POINT_ID.COUNT = 0 AND l_last_fetch THEN
          EXIT;
       END IF;

       FOR i IN I_CONTACT_POINT_ID.FIRST..I_CONTACT_POINT_ID.LAST
       LOOP
	      get_phone_timezone_id(
			p_api_version => 1.0,
			p_init_msg_list => FND_API.G_TRUE,
			p_phone_country_code => I_PHONE_COUNTRY_CODE(i),
			p_area_code => I_PHONE_AREA_CODE(i),
			p_phone_prefix => null,
			p_country_code => null,-- don't need to pass in this
			x_timezone_id => l_timezone_id,
			x_return_status => l_return_status ,
			x_msg_count =>l_msg_count ,
			x_msg_data => l_msg_data);
			if l_return_status <> fnd_api.g_ret_sts_success
			then  -- we don't raise error
				l_timezone_id := null;
			end if;

           UPDATE hz_contact_points
             SET timezone_id = l_timezone_id
           WHERE contact_point_id = I_CONTACT_POINT_ID(i);

      END LOOP;

      i_commit := i_commit + rows;
      IF i_commit = commit_counter THEN
         COMMIT;
         i_commit := 0;
      END IF;

      IF  l_last_fetch = TRUE THEN
          EXIT;
      END IF;

   END LOOP;
   CLOSE phone_csr;

  else -- do not overwrite existing timezone_id
    OPEN phone_tz_csr;
    LOOP
       FETCH phone_tz_csr BULK COLLECT INTO
          I_CONTACT_POINT_ID, I_PHONE_COUNTRY_CODE, I_PHONE_AREA_CODE LIMIT rows;

       IF phone_tz_csr%NOTFOUND THEN
          l_last_fetch := TRUE;
       END IF;
       IF I_CONTACT_POINT_ID.COUNT = 0 AND l_last_fetch THEN
          EXIT;
       END IF;

       FOR i IN I_CONTACT_POINT_ID.FIRST..I_CONTACT_POINT_ID.LAST
       LOOP
	     get_phone_timezone_id(
			p_api_version => 1.0,
			p_init_msg_list => FND_API.G_TRUE,
			p_phone_country_code => I_PHONE_COUNTRY_CODE(i),
			p_area_code => I_PHONE_AREA_CODE(i),
			p_phone_prefix => null,
			p_country_code => null,-- don't need to pass in this
			x_timezone_id => l_timezone_id,
			x_return_status => l_return_status ,
			x_msg_count =>l_msg_count ,
			x_msg_data => l_msg_data);
			if l_return_status <> fnd_api.g_ret_sts_success
			then  -- we don't raise error
				l_timezone_id := null;
			end if;

           UPDATE hz_contact_points
             SET timezone_id = l_timezone_id
           WHERE contact_point_id = I_CONTACT_POINT_ID(i);

      END LOOP;

      i_commit := i_commit + rows;
      IF i_commit = commit_counter THEN
         COMMIT;
         i_commit := 0;
      END IF;

      IF  l_last_fetch = TRUE THEN
          EXIT;
      END IF;

   END LOOP;
   CLOSE phone_tz_csr;
 end if;

  log('Process Completed @: '||to_char(sysdate,'DD-MON-RRRR:HH:MI:SS'));

EXCEPTION
	WHEN OTHERS THEN
                ERRBUF := ERRBUF||'Error in HZ_POPULATE_TIMEZONE_PKG.PHONE_TIMEZONE:'||to_char(sqlcode)||sqlerrm;
                RETCODE := '2';
                log('Error in HZ_POPULATE_TIMEZONE_PKG.PHONE_TIMEZONE:'||sqlerrm);

end PHONE_TIMEZONE;

PROCEDURE LOCATION_TIMEZONE(errbuf OUT NOCOPY VARCHAR2, retcode OUT NOCOPY
VARCHAR2, p_overwrite_flag IN varchar2) is
	cursor location_csr is
		select location_id, country, state, city, postal_code
		from hz_locations;

	cursor location_tz_csr is
		select location_id, country, state, city, postal_code
		from hz_locations
		where timezone_id is null;

	TYPE COUNTRYList		IS TABLE OF HZ_LOCATIONS.COUNTRY%TYPE;
	TYPE CITYList			IS TABLE OF HZ_LOCATIONS.CITY%TYPE;
	TYPE POSTAL_CODEList		IS TABLE OF HZ_LOCATIONS.POSTAL_CODE%TYPE;
	TYPE STATEList			IS TABLE OF HZ_LOCATIONS.STATE%TYPE;
	TYPE LOCATION_IDList		IS TABLE OF HZ_LOCATIONS.LOCATION_ID%TYPE;

	I_COUNTRY		COUNTRYList;
	I_CITY	CITYList;
	I_POSTAL_CODE		POSTAL_CODEList;
	I_STATE		STATEList;
	I_LOCATION_ID		LOCATION_IDList;

    i                           NUMBER;
    rows                        NUMBER := 1000;
    i_commit                    NUMBER;
    commit_counter              NUMBER;
    l_last_fetch                BOOLEAN;
    l_timezone_id		number;
    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);
    l_status varchar2(255);
begin

 Write_Log(G_DEBUG_CONCURRENT, 1, 'Process began @: ' || to_char(sysdate,'DD-MON-RRRR:HH:MI:SS'));

 retcode:=0;
 i_commit := 0;
 commit_counter := 1000;
 l_last_fetch:=false;

 if p_overwrite_flag = 'Y'
 then
    /* for each location we selected */
    OPEN location_csr;
    LOOP
       FETCH location_csr BULK COLLECT INTO
          I_LOCATION_ID, I_COUNTRY, I_STATE, I_CITY, I_POSTAL_CODE LIMIT rows;

       IF location_csr%NOTFOUND THEN
          l_last_fetch := TRUE;
       END IF;
       IF I_LOCATION_ID.COUNT = 0 AND l_last_fetch THEN
          EXIT;
       END IF;

       FOR i IN I_LOCATION_ID.FIRST..I_LOCATION_ID.LAST
       LOOP
	     hz_timezone_pub.get_timezone_id(
		p_api_version => 1.0,
		p_init_msg_list => FND_API.G_TRUE,
		p_postal_code => I_POSTAL_CODE(i),
		p_city => I_CITY(i),
		p_state => I_STATE(i),
		p_country => I_COUNTRY(i),
		x_timezone_id => l_timezone_id,
		x_return_status => l_return_status ,
		x_msg_count =>l_msg_count ,
		x_msg_data => l_msg_data);
	if l_return_status <> fnd_api.g_ret_sts_success
	then  -- we don't raise error
		l_timezone_id := null;
	end if;

      UPDATE hz_locations
             SET timezone_id = l_timezone_id
           WHERE location_id = I_LOCATION_ID(i);

      END LOOP;

      i_commit := i_commit + rows;
      IF i_commit = commit_counter THEN
         COMMIT;
         i_commit := 0;
      END IF;

      IF  l_last_fetch = TRUE THEN
          EXIT;
      END IF;

    END LOOP;
    CLOSE location_csr;

  else -- overwrite existing timezone
     OPEN location_tz_csr;
     LOOP
       FETCH location_tz_csr BULK COLLECT INTO
          I_LOCATION_ID, I_COUNTRY, I_STATE, I_CITY, I_POSTAL_CODE LIMIT rows;

       IF location_tz_csr%NOTFOUND THEN
          l_last_fetch := TRUE;
       END IF;
       IF I_LOCATION_ID.COUNT = 0 AND l_last_fetch THEN
          EXIT;
       END IF;

       FOR i IN I_LOCATION_ID.FIRST..I_LOCATION_ID.LAST
       LOOP
	     hz_timezone_pub.get_timezone_id(
		p_api_version => 1.0,
		p_init_msg_list => FND_API.G_TRUE,
		p_postal_code => I_POSTAL_CODE(i),
		p_city => I_CITY(i),
		p_state => I_STATE(i),
		p_country => I_COUNTRY(i),
		x_timezone_id => l_timezone_id,
		x_return_status => l_return_status ,
		x_msg_count =>l_msg_count ,
		x_msg_data => l_msg_data);
	if l_return_status <> fnd_api.g_ret_sts_success
	then  -- we don't raise error
		l_timezone_id := null;
	end if;

     UPDATE hz_locations
             SET timezone_id = l_timezone_id
           WHERE location_id = I_LOCATION_ID(i);

      END LOOP;

      i_commit := i_commit + rows;
      IF i_commit = commit_counter THEN
         COMMIT;
         i_commit := 0;
      END IF;

      IF  l_last_fetch = TRUE THEN
          EXIT;
      END IF;

    END LOOP;
    CLOSE location_tz_csr;
 end if;
    Write_Log(G_DEBUG_CONCURRENT, 1, 'Process Completed @: '||to_char(sysdate,'DD-MON-RRRR:HH:MI:SS'));

EXCEPTION
	WHEN OTHERS THEN
                ERRBUF := ERRBUF||'Error in HZ_POPULATE_TIMEZONE_PKG.PHONE_TIMEZONE:'||to_char(sqlcode)||sqlerrm;
                RETCODE := '2';
                Write_Log(G_DEBUG_CONCURRENT, 1,'Error in HZ_POPULATE_TIMEZONE_PKG.PHONE_TIMEZONE:');
                Write_Log(G_DEBUG_CONCURRENT, 1,sqlerrm);
                --l_status := fnd_concurrent.set_completion_status('ERROR',sqlerrm);
                --IF l_status = TRUE THEN
                 --       Write_Log(G_DEBUG_CONCURRENT, 1, 'Error, can not complete Concurrent Program') ;
                --END IF;

end location_timezone;

END HZ_POPULATE_TIMEZONE_PKG;

/
