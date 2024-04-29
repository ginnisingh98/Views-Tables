--------------------------------------------------------
--  DDL for Package Body CSFW_TIMEZONE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSFW_TIMEZONE_PUB" as
/* $Header: csfwtznb.pls 115.5 2003/10/16 07:02:12 srengana ship $ */
-- Start of Comments
-- Package name     : CSFW_TIMEZONE_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments
FUNCTION GET_CLIENT_TIME(p_server_time date)
RETURN date IS

l_client_tz_id  number;
l_server_tz_id  number;
l_msg_count     number;
l_status        varchar2(1);
x_client_time   date;
l_msg_data      varchar2(2000);


BEGIN

IF (fnd_timezones.timezones_enabled <> 'Y') THEN
        return p_server_time;
END IF;

l_client_tz_id := to_number(fnd_profile.value_specific('CLIENT_TIMEZONE_ID'));
l_server_tz_id := to_number(fnd_profile.value_specific('SERVER_TIMEZONE_ID'));

HZ_TIMEZONE_PUB.GET_TIME(1.0, 'F', l_server_tz_id, l_client_tz_id, p_server_time, x_client_time, l_status, l_msg_count, l_msg_data);

return x_client_time;
END GET_CLIENT_TIME;



FUNCTION TIME_DIFF_SERVER_TO_CLIENT
RETURN NUMBER IS

l_client_tz_id  number;
l_server_tz_id  number;
l_msg_count     number;
l_status        varchar2(1);
x_time_diff     number;
l_msg_data      varchar2(2000);
l_sysdate_server date;
l_sysdate_client date;

BEGIN
IF (fnd_timezones.timezones_enabled <> 'Y') THEN
        return 0;
END IF;

l_client_tz_id := to_number(fnd_profile.value_specific('CLIENT_TIMEZONE_ID'));
l_server_tz_id := to_number(fnd_profile.value_specific('SERVER_TIMEZONE_ID'));

l_sysdate_server := sysdate;

HZ_TIMEZONE_PUB.GET_TIME(1.0, 'F', l_server_tz_id, l_client_tz_id, l_sysdate_server, l_sysdate_client, l_status, l_msg_count, l_msg_data);
x_time_diff := l_sysdate_server - l_sysdate_client;-- (server - client)

return x_time_diff;

END TIME_DIFF_SERVER_TO_CLIENT;


FUNCTION GET_SERVER_TIME(p_client_time VARCHAR2, p_date_format VARCHAR2)
RETURN String IS

l_client_tz_id  number;
l_server_tz_id  number;
l_msg_count     number;
l_status        varchar2(1);
x_server_time   date;
l_msg_data      varchar2(2000);
l_client_date   date;


BEGIN

IF (fnd_timezones.timezones_enabled <> 'Y') THEN
        return p_client_time;
END IF;


l_client_tz_id := to_number(fnd_profile.value('CLIENT_TIMEZONE_ID'));
l_server_tz_id := to_number(fnd_profile.value('SERVER_TIMEZONE_ID'));

HZ_TIMEZONE_PUB.GET_TIME(1.0, 'F', l_client_tz_id,l_server_tz_id, to_date(p_client_time, p_date_format) ,x_server_time, l_status, l_msg_count, l_msg_data);

return to_char(x_server_time,p_date_format) ;
END GET_SERVER_TIME;




END CSFW_TIMEZONE_PUB;

/
