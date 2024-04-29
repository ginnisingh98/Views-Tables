--------------------------------------------------------
--  DDL for Package HZ_TIMEZONE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_TIMEZONE_PUB" AUTHID CURRENT_USER as
/*$Header: ARHTMZOS.pls 115.7 2003/10/13 21:50:33 awu ship $ */
Procedure Get_Timezone_ID (
  p_api_version		in	number,
  p_init_msg_list     in      varchar2,
  p_postal_code         in      varchar2,
  p_city                in      varchar2,
  p_state		in 	varchar2,
  p_country             in      varchar2,
  x_timezone_id         out nocopy     number,
  x_return_status       out nocopy     varchar2,
  x_msg_count		out nocopy	number,
  x_msg_data		out nocopy	varchar2
);

/*===========================================================================+
 | PROCEDURE                                                                 |
 |              Get_Phone_Timezone_ID                                              |
 |                                                                           |
 | DESCRIPTION                                                               |
 |               Return timezone id by passing in area code and phone        |
 |               country code.                                               |
 |             parameter p_phone_prefix is for future use. No logic on it.   |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_api_version                                          |
 |                    p_init_msg_list                                        |
 |		      p_phone_country_code 	                             |
 |		      p_area_code	       				     |
 |		      p_phone_prefix  (for future use)	                     |
 |                    p_country_code(only need to pass in if two countries   |
 |                    have same phone_country_code and no area code          |
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
  p_country_code  in      varchar2,
  x_timezone_id         out nocopy     number,
  x_return_status       out nocopy     varchar2,
  x_msg_count		out nocopy	number,
  x_msg_data		out nocopy	varchar2
);



Procedure Get_Timezone_GMT_Deviation (
  p_api_version          in      number,
  p_init_msg_list     in      varchar2,
  p_timezone_id          in      number,
  p_date                 in      date,
  x_GMT_deviation        out nocopy     number,
  x_global_timezone_name out nocopy     varchar2,
  x_name                 out nocopy     varchar2,
  x_return_status        out nocopy     varchar2,
  x_msg_count            out nocopy     number,
  x_msg_data             out nocopy     varchar2
);

Function Convert_DateTime(
   p_source_tz_id		   in  number,
   p_dest_tz_id		           in  number,
   p_source_day_time		   in  date
  ) RETURN DATE;

Procedure Get_Time (
   p_api_version        in      number,
   p_init_msg_list     in      varchar2,
   p_source_tz_id       in      number,
   p_dest_tz_id         in      number,
   p_source_day_time    in      date,
   x_dest_day_time      out nocopy     date,
   x_return_status        out nocopy     varchar2,
   x_msg_count            out nocopy     number,
   x_msg_data             out nocopy     varchar2
);

Procedure Get_Time_and_Code (
   p_api_version        in      number,
   p_init_msg_list     in      varchar2,
   p_source_tz_id       in      number,
   p_dest_tz_id         in      number,
   p_source_day_time    in      date,
   x_dest_day_time      out nocopy     date,
   x_dest_tz_code         out nocopy     varchar2,
   x_dest_gmt_deviation   out nocopy     number,
   x_return_status        out nocopy     varchar2,
   x_msg_count            out nocopy     number,
   x_msg_data             out nocopy     varchar2
);

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
   x_msg_data                   out nocopy varchar2
);

Procedure Get_Timezone_Short_Code (
  p_api_version		in	number,
  p_init_msg_list     in      varchar2,
  p_timezone_id		in	number,
  p_timezone_code 	in      varchar2,
  p_date		in      date,
  x_gmt_deviation	out nocopy	number,
  x_timezone_short_code out nocopy	varchar2,
  x_name		out nocopy     varchar2,
  x_return_status       out nocopy     varchar2,
  x_msg_count		out nocopy	number,
  x_msg_data		out nocopy	varchar2
);

Procedure Get_begin_end_dst_day_time (
  p_year                in      varchar2,
  p_timezone_id         in      number,
  x_begin_dst_date      out nocopy     date,
  x_end_dst_date        out nocopy     date
);

Procedure Get_date_from_W_and_D
(
  p_year        	in      varchar2,
  p_month       	in      varchar2,
  p_week        	in      varchar2,
  p_day         	in      varchar2,
  x_date        	out nocopy     varchar2
);


END  HZ_TIMEZONE_PUB;

 

/
