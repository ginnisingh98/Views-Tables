--------------------------------------------------------
--  DDL for Package Body ECE_TIMEZONE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECE_TIMEZONE_API" AS
-- $Header: ECETZAPB.pls 120.3.12000000.2 2007/10/03 15:00:55 cpeixoto ship $

   PROCEDURE get_server_timezone_details(
                                      p_date                 IN  DATE,
                                      x_gmt_deviation        OUT NOCOPY NUMBER,
                                      x_global_timezone_name OUT NOCOPY VARCHAR2) IS
      st_tz_id number;
      p_api_version number;
      p_init_msg_list varchar2(32767) := FND_API.G_FALSE;
      x_msg_data varchar2(2000);
      x_msg_count number;
      x_return_status varchar2(20);
      x_name varchar2(80);
      xProgress                  VARCHAR2(80);

      BEGIN
         if ec_debug.G_debug_level >= 2 then
         ec_debug.push('ECE_TIMEZONE_API.GET_SERVER_TIMEZONE_DETAILS');
	 end if;
	 xProgress := 'TZAPI-10-1000';
	 fnd_profile.get('SERVER_TIMEZONE_ID',st_tz_id);
         xProgress := 'TZAPI-10-1010';
         if p_date is not null then
         hz_timezone_pub.get_timezone_gmt_deviation(
	                                            1.0,
						    p_init_msg_list,
						    st_tz_id,
						    p_date,
						    x_gmt_deviation,
						    x_global_timezone_name,
						    x_name,
						    x_return_status,
						    x_msg_count,
						    x_msg_data
						   );
         end if;
         if ec_debug.G_debug_level >= 2 then
	 ec_debug.pl(3,'gmt deviation: ',x_gmt_deviation);
	 ec_debug.pl(3,'Timezone Code: ',x_global_timezone_name);
         ec_debug.pop('ECE_TIMEZONE_API.GET_SERVER_TIMEZONE_DETAILS');
	 end if;
          EXCEPTION
         WHEN OTHERS THEN
            ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL',xProgress);
            ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
            if ec_debug.G_debug_level >= 2 then
            ec_debug.pop('ECE_TIMEZONE_API.GET_SERVER_TIMEZONE_DETAILS');
	    end if;
            app_exception.raise_exception;


      END  get_server_timezone_details;

     PROCEDURE get_date(
                       p_src_date      IN  DATE,
                       p_timezone_name IN  VARCHAR2,
                       x_dest_date     OUT NOCOPY DATE) IS
           st_tz_id number;
           ct_tz_id number;
           p_api_version number;
           p_init_msg_list varchar2(32767) := FND_API.G_FALSE ;
           x_msg_data varchar2(2000);
           x_msg_count number;
           x_return_status varchar2(20);
           xProgress                  VARCHAR2(80);

/* fix for bug 6391170
	   CURSOR c_timezone(p_timezone_name IN varchar2
			     ) IS
	          select timezone_id
	          from hz_timezones_vl
		  where upper(name) = p_timezone_name; */

           CURSOR c_timezone(p_timezone_name IN varchar2
                             ) IS
                  select upgrade_tz_id timezone_id
                  from fnd_timezones_vl
                  where upper(timezone_code) = p_timezone_name;

      BEGIN
          if ec_debug.G_debug_level >= 2 then
          ec_debug.push('ECE_TIMEZONE_API.GET_DATE');
	  end if;
	  xProgress := 'TZAPI-20-1000';
	  if (p_timezone_name is not null) then
          FOR i_timezone in c_timezone(upper(p_timezone_name))
	  LOOP
	   ct_tz_id := i_timezone.timezone_id;
	   exit;
	  END LOOP;
	  xProgress := 'TZAPI-20-1010';
          fnd_profile.get('SERVER_TIMEZONE_ID',st_tz_id);
	  xProgress := 'TZAPI-20-1020';
          hz_timezone_pub.get_time(
	                           1.0,
				   p_init_msg_list,
				   ct_tz_id,
				   st_tz_id,
				   p_src_date,
				   x_dest_date,
				   x_return_status,
				   x_msg_count,
				   x_msg_data);
         else
	  x_dest_date := p_src_date;
	 end if;
         if ec_debug.G_debug_level >= 2 then
         ec_debug.pl(3,'x_dest_date: ',x_dest_date);
         ec_debug.pop('ECE_TIMEZONE_API.GET_DATE');
	 end if;
          EXCEPTION
         WHEN OTHERS THEN
            ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL',xProgress);
            ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
            if ec_debug.G_debug_level >= 2 then
            ec_debug.pop('ECE_TIMEZONE_API.GET_DATE');
	    end if;
            app_exception.raise_exception;

      END get_date;
END;

/
