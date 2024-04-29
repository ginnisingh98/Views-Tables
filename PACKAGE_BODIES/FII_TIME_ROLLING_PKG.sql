--------------------------------------------------------
--  DDL for Package Body FII_TIME_ROLLING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_TIME_ROLLING_PKG" AS
/*$Header: FIICMT3B.pls 120.1.12000000.1 2007/01/18 17:57:25 appldev ship $*/

g_debug_flag         VARCHAR2(1) := NVL(FND_PROFILE.value('FII_DEBUG_MODE'), 'N');

PROCEDURE Load_Rolling_Offsets
( o_error_msg OUT NOCOPY VARCHAR2,
  o_error_code OUT NOCOPY VARCHAR2)
IS

l_user number;

BEGIN

l_user := FND_GLOBAL.USER_ID;

insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_WEEK'  ,'YEARLY', 0, -6, 0, sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_WEEK'  ,'YEARLY', -7, -6,1, sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_WEEK'  ,'YEARLY', -14, -6, 2, sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_WEEK'  ,'YEARLY', -21,  -6 ,  3, sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_WEEK'  ,'YEARLY', -28 , -6 ,  4, sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_WEEK'  ,'YEARLY', -35,  -6 ,  5, sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_WEEK'  ,'YEARLY', -42,  -6 ,  6, sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_WEEK'  ,'YEARLY', -49,  -6 ,  7, sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_WEEK'  ,'YEARLY', -56,  -6 ,  8 , sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_WEEK'  ,'YEARLY', -63,  -6 ,  9, sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_WEEK'  ,'YEARLY', -70,  -6 , 10, sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_WEEK'  ,'YEARLY', -77,  -6 , 11, sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_WEEK'  ,'YEARLY', -84,  -6 , 12, sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_MONTH' ,'YEARLY',  0 ,  -29,  0, sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_MONTH' ,'YEARLY', -30  ,-29,  1 , sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_MONTH' ,'YEARLY', -60  ,-29,  2  , sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_MONTH' ,'YEARLY', -90  ,-29,  3   , sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_MONTH' ,'YEARLY', -120 ,-29,  4 , sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_MONTH' ,'YEARLY', -150 ,-29,  5 , sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_MONTH' ,'YEARLY', -180 ,-29,  6 , sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_MONTH' ,'YEARLY', -210 ,-29,  7 , sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_MONTH' ,'YEARLY', -240 ,-29,  8 , sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_MONTH' ,'YEARLY', -270 ,-29,  9 , sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_MONTH' ,'YEARLY', -300 ,-29, 10 , sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_MONTH' ,'YEARLY', -330 ,-29, 11 , sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_QTR'   ,'YEARLY',  0   ,-89, 0 , sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_QTR'   ,'YEARLY', -90  ,-89, 1 , sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_QTR'   ,'YEARLY', -180 ,-89, 2 , sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_QTR'   ,'YEARLY', -270 ,-89, 3 , sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_YEAR'  ,'YEARLY',  0   ,-364, 0 , sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_YEAR'  ,'YEARLY', -365 ,-364, 1 , sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_YEAR'  ,'YEARLY', -730 ,-364, 2 , sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_YEAR'  ,'YEARLY', -1095 ,-364,3 , sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_WEEK'  ,'SEQUENTIAL',  0,    -6 , 0 , sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_WEEK'  ,'SEQUENTIAL',  -7,   -6 , 1 , sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_WEEK'  ,'SEQUENTIAL',  -14,  -6 , 2 , sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_WEEK'  ,'SEQUENTIAL',  -21 , -6 , 3 , sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_WEEK'  ,'SEQUENTIAL',  -28 , -6 , 4 , sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_WEEK'  ,'SEQUENTIAL',  -35 , -6 , 5 , sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_WEEK'  ,'SEQUENTIAL',  -42 , -6 , 6 , sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_WEEK'  ,'SEQUENTIAL',  -49 , -6 , 7 , sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_WEEK'  ,'SEQUENTIAL',  -56 , -6 , 8 , sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_WEEK'  ,'SEQUENTIAL',  -63 , -6 , 9 , sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_WEEK'  ,'SEQUENTIAL',  -70 , -6 , 10 , sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_WEEK'  ,'SEQUENTIAL',  -77 , -6 , 11 , sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_WEEK'  ,'SEQUENTIAL',  -84 , -6 , 12 , sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_MONTH' ,'SEQUENTIAL',   0   ,-29,  0, sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_MONTH' ,'SEQUENTIAL',  -30  ,-29,  1, sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_MONTH' ,'SEQUENTIAL',  -60  ,-29,  2 , sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_MONTH' ,'SEQUENTIAL',  -90  ,-29,  3 , sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_MONTH' ,'SEQUENTIAL',  -120 ,-29,  4 , sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_MONTH' ,'SEQUENTIAL',  -150 ,-29,  5 , sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_MONTH' ,'SEQUENTIAL',  -180 ,-29,  6 , sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_MONTH' ,'SEQUENTIAL',  -210 ,-29,  7 , sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_MONTH' ,'SEQUENTIAL',  -240 ,-29,  8 , sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_MONTH' ,'SEQUENTIAL',  -270 ,-29,  9 , sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_MONTH' ,'SEQUENTIAL',  -300 ,-29, 10 , sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_MONTH' ,'SEQUENTIAL',  -330 ,-29, 11 , sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_QTR'   ,'SEQUENTIAL',   0   ,-89, 0  , sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_QTR'   ,'SEQUENTIAL',  -90  ,-89, 1 , sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_QTR'   ,'SEQUENTIAL',  -180 ,-89, 2 , sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_QTR'   ,'SEQUENTIAL',  -270 ,-89, 3 , sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_QTR'   ,'SEQUENTIAL',  -360 ,-89, 4 , sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_QTR'   ,'SEQUENTIAL',  -450 ,-89, 5 , sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_QTR'   ,'SEQUENTIAL',  -540  ,-89,6 , sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_QTR'   ,'SEQUENTIAL',  -630  ,-89,7 , sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_YEAR'  ,'SEQUENTIAL',   0   ,-364,0 , sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_YEAR'  ,'SEQUENTIAL',  -365 ,-364,1 , sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_YEAR'  ,'SEQUENTIAL',  -730 ,-364,2 , sysdate, l_user, sysdate, l_user, l_user);
insert into fii_time_rolling_offsets(period_type, comparison_type, offset, start_date_offset, period_number, creation_date, created_by, last_update_date, last_updated_by, last_update_login)
values ('FII_ROLLING_YEAR'  ,'SEQUENTIAL',  -1095 ,-364,3 , sysdate, l_user, sysdate, l_user, l_user);

COMMIT;

o_error_code := 0;
o_error_msg := '';

if g_debug_flag = 'Y' then
   fii_util.put_line('Successfully loaded the Rolling period offsets.');
end if;

exception

  when others then

    o_error_code := sqlcode;
    o_error_msg := sqlerrm;
    if g_debug_flag = 'Y' then
       fii_util.put_line('Error loading the Rolling period offsets.');
    end if;
    RAISE_APPLICATION_ERROR(-20000,o_error_msg);

END Load_Rolling_Offsets;

END FII_TIME_ROLLING_PKG;

/
