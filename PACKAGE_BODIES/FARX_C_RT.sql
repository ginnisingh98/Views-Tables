--------------------------------------------------------
--  DDL for Package Body FARX_C_RT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FARX_C_RT" as
/* $Header: farxcrtb.pls 120.3.12010000.2 2009/07/19 13:51:10 glchen ship $ */

g_print_debug boolean := fa_cache_pkg.fa_print_debug;

PROCEDURE RET (
  errbuf	    out nocopy varchar2,
  retcode	    out nocopy varchar2,
  argument1	    in	varchar2,   -- book
  argument2         in  varchar2,   -- begin period_name
  argument3         in  varchar2,   -- end period name
  argument4         in  varchar2  default  null, -- chart of account id
  argument5         in  varchar2  default  null, -- category structure number
  argument6         in  varchar2  default  null, -- from major category
  argument7         in  varchar2  default  null, -- to   major category
  argument8         in  varchar2  default  null, -- minor category exists check
  argument9         in  varchar2  default  null, -- from minor category
  argument10        in  varchar2  default  null, -- to   minor category
  argument11	   in  varchar2  default  null,  -- from cost center
  argument12        in  varchar2  default  null, -- to   cost center
  argument13        in  varchar2  default  null, -- category segment number
  argument14        in  varchar2  default  null, -- from category segment value
  argument15        in  varchar2  default  null, -- to   category segment value
  argument16        in  varchar2  default  null, -- from asset number
  argument17        in  varchar2  default  null, -- to   asset number
  argument18        in  varchar2  default  null, -- debug
  argument19        in  varchar2  default  null,
  argument20        in  varchar2  default  null,
  argument21	   in  varchar2  default  null,
  argument22        in  varchar2  default  null,
  argument23        in  varchar2  default  null,
  argument24        in  varchar2  default  null,
  argument25        in  varchar2  default  null,
  argument26        in  varchar2  default  null,
  argument27        in  varchar2  default  null,
  argument28        in  varchar2  default  null,
  argument29        in  varchar2  default  null,
  argument30        in  varchar2  default  null,
  argument31	   in  varchar2  default  null,
  argument32        in  varchar2  default  null,
  argument33        in  varchar2  default  null,
  argument34        in  varchar2  default  null,
  argument35        in  varchar2  default  null,
  argument36        in  varchar2  default  null,
  argument37        in  varchar2  default  null,
  argument38        in  varchar2  default  null,
  argument39        in  varchar2  default  null,
  argument40        in  varchar2  default  null,
  argument41	   in  varchar2  default  null,
  argument42        in  varchar2  default  null,
  argument43        in  varchar2  default  null,
  argument44        in  varchar2  default  null,
  argument45        in  varchar2  default  null,
  argument46        in  varchar2  default  null,
  argument47        in  varchar2  default  null,
  argument48        in  varchar2  default  null,
  argument49        in  varchar2  default  null,
  argument50        in  varchar2  default  null,
  argument51	   in  varchar2  default  null,
  argument52        in  varchar2  default  null,
  argument53        in  varchar2  default  null,
  argument54        in  varchar2  default  null,
  argument55        in  varchar2  default  null,
  argument56        in  varchar2  default  null,
  argument57        in  varchar2  default  null,
  argument58        in  varchar2  default  null,
  argument59        in  varchar2  default  null,
  argument60        in  varchar2  default  null,
  argument61	   in  varchar2  default  null,
  argument62        in  varchar2  default  null,
  argument63        in  varchar2  default  null,
  argument64        in  varchar2  default  null,
  argument65        in  varchar2  default  null,
  argument66        in  varchar2  default  null,
  argument67        in  varchar2  default  null,
  argument68        in  varchar2  default  null,
  argument69        in  varchar2  default  null,
  argument70        in  varchar2  default  null,
  argument71	   in  varchar2  default  null,
  argument72        in  varchar2  default  null,
  argument73        in  varchar2  default  null,
  argument74        in  varchar2  default  null,
  argument75        in  varchar2  default  null,
  argument76        in  varchar2  default  null,
  argument77        in  varchar2  default  null,
  argument78        in  varchar2  default  null,
  argument79        in  varchar2  default  null,
  argument80        in  varchar2  default  null,
  argument81	   in  varchar2  default  null,
  argument82        in  varchar2  default  null,
  argument83        in  varchar2  default  null,
  argument84        in  varchar2  default  null,
  argument85        in  varchar2  default  null,
  argument86        in  varchar2  default  null,
  argument87        in  varchar2  default  null,
  argument88        in  varchar2  default  null,
  argument89        in  varchar2  default  null,
  argument90        in  varchar2  default  null,
  argument91	   in  varchar2  default  null,
  argument92        in  varchar2  default  null,
  argument93        in  varchar2  default  null,
  argument94        in  varchar2  default  null,
  argument95        in  varchar2  default  null,
  argument96        in  varchar2  default  null,
  argument97        in  varchar2  default  null,
  argument98        in  varchar2  default  null,
  argument99        in  varchar2  default  null,
  argument100            in       varchar2 default null) is

  h_request_id    number;
  h_user_id	  number;
  h_err_msg     varchar2(2000);
  h_debug	boolean;

  begin
 -- for debugging
   h_debug := Upper(argument18) LIKE 'Y%';
   IF h_debug THEN
      fa_rx_util_pkg.enable_debug;
   END IF;

   IF (g_print_debug) THEN
   	fa_rx_util_pkg.debug('RET: ' || 'argument1:' ||argument1);
   	fa_rx_util_pkg.debug('RET: ' || 'argument2:' ||argument2);
   	fa_rx_util_pkg.debug('RET: ' || 'argument3:' ||argument3);
   	fa_rx_util_pkg.debug('RET: ' || 'argument4:' ||argument4);
   	fa_rx_util_pkg.debug('RET: ' || 'argument5:' ||argument5);
   	fa_rx_util_pkg.debug('RET: ' || 'argument6:' ||argument6);
   	fa_rx_util_pkg.debug('RET: ' || 'argument7:' ||argument7);
   	fa_rx_util_pkg.debug('RET: ' || 'argument8:' ||argument8);
   	fa_rx_util_pkg.debug('RET: ' || 'argument9:' ||argument9);
   	fa_rx_util_pkg.debug('RET: ' || 'argument10:' ||argument10);
   	fa_rx_util_pkg.debug('RET: ' || 'argument11:' ||argument11);
   	fa_rx_util_pkg.debug('RET: ' || 'argument12:' ||argument12);
   	fa_rx_util_pkg.debug('RET: ' || 'argument13:' ||argument13);
   	fa_rx_util_pkg.debug('RET: ' || 'argument14:' ||argument14);
   	fa_rx_util_pkg.debug('RET: ' || 'argument15:' ||argument15);
   	fa_rx_util_pkg.debug('RET: ' || 'argument16:' ||argument16);
   	fa_rx_util_pkg.debug('RET: ' || 'argument17:' ||argument17);
   END IF;

--  select max(fcr.request_id) into h_request_id
--  from fnd_concurrent_requests fcr, fnd_concurrent_programs fcp
--  where fcr.argument1 = argument1
--  and fcr.argument2 = argument2
--  and fcr.argument3 = argument3
--  and fcr.phase_code = 'R'
--  and fcr.concurrent_program_id = fcp.concurrent_program_id
--  and fcp.concurrent_program_name = 'RXFARET';

  h_request_id := fnd_global.conc_request_id;
  fnd_profile.get('USER_ID',h_user_id);

  farx_rt.ret (
        book 		=> argument1,
        begin_period 	=> argument2,
        end_period 	=> argument3,
	from_maj_cat	=> argument6,
	to_maj_cat	=> argument7,
	from_min_cat	=> argument9,
	to_min_cat	=> argument10,
	from_cc		=> argument11,
	to_cc		=> argument12,
	cat_seg_num	=> argument13,
	from_cat_seg_val => argument14,
	to_cat_seg_val	=> argument15,
	from_asset_num	=> argument16,
	to_asset_num	=> argument17,
        request_id 	=> h_request_id,
	user_id 	=> h_user_id,
	retcode 	=> retcode,
	errbuf 		=> errbuf);
  retcode := 0;


exception when others then
  fnd_message.set_name('OFA', 'FA_SHARED_SERVER_ERROR');
  h_err_msg := fnd_message.get;
  fa_rx_conc_mesg_pkg.log(h_err_msg);
  retcode := 2;


  end ret;

END FARX_C_RT;

/
