--------------------------------------------------------
--  DDL for Package Body FARX_C_AL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FARX_C_AL" AS
/* $Header: farxcalb.pls 120.2.12010000.3 2009/07/19 10:50:30 glchen ship $ */

PROCEDURE asset_listing_run (
  errbuf	 out nocopy varchar2,
  retcode	 out nocopy varchar2,
  argument1		in  varchar2,   -- book
  argument2		in  varchar2,   -- set of books id
  argument3		in  varchar2,   -- period_name
  argument4		in  varchar2,   -- chart_of_accounts_id
  argument5		in  varchar2,   -- chart_of_accounts_id
  argument6		in  varchar2  default  null, -- from balancing
  argument7		in  varchar2  default  null, -- to   balancing
  argument8		in  varchar2  default  null, -- from account
  argument9		in  varchar2  default  null, -- to   account
  argument10		in  varchar2  default  null, -- from cc
  argument11		in  varchar2  default  null, -- to   cc
  argument12		in  varchar2  default  null, -- major category
  argument13		in  varchar2  default  null, --	minor category exists check
  argument14		in  varchar2  default  null, --	minor category
  argument15		in  varchar2  default  null, --	category segment number
  argument16		in  varchar2  default  null, --	category segment value
  argument17		in  varchar2  default  null, --	property type
  argument18		in  varchar2  default  null, --	fully reserved
  argument19		in  varchar2  default  null, --	net book value
  argument20		in  varchar2  default  null, --	category depreciation flag
  argument21		in  varchar2  default  null, -- bought
  argument22		in  varchar2  default  null, -- for debug ('Y' or 'N')
  argument23		in  varchar2  default  null,
  argument24		in  varchar2  default  null,
  argument25		in  varchar2  default  null,
  argument26		in  varchar2  default  null,
  argument27		in  varchar2  default  null,
  argument28		in  varchar2  default  null,
  argument29		in  varchar2  default  null,
  argument30		in  varchar2  default  null,
  argument31		in  varchar2  default  null,
  argument32		in  varchar2  default  null,
  argument33		in  varchar2  default  null,
  argument34		in  varchar2  default  null,
  argument35		in  varchar2  default  null,
  argument36		in  varchar2  default  null,
  argument37		in  varchar2  default  null,
  argument38		in  varchar2  default  null,
  argument39		in  varchar2  default  null,
  argument40		in  varchar2  default  null,
  argument41		in  varchar2  default  null,
  argument42		in  varchar2  default  null,
  argument43		in  varchar2  default  null,
  argument44		in  varchar2  default  null,
  argument45		in  varchar2  default  null,
  argument46		in  varchar2  default  null,
  argument47		in  varchar2  default  null,
  argument48		in  varchar2  default  null,
  argument49		in  varchar2  default  null,
  argument50		in  varchar2  default  null,
  argument51		in  varchar2  default  null,
  argument52		in  varchar2  default  null,
  argument53		in  varchar2  default  null,
  argument54		in  varchar2  default  null,
  argument55		in  varchar2  default  null,
  argument56		in  varchar2  default  null,
  argument57		in  varchar2  default  null,
  argument58		in  varchar2  default  null,
  argument59		in  varchar2  default  null,
  argument60		in  varchar2  default  null,
  argument61		in  varchar2  default  null,
  argument62		in  varchar2  default  null,
  argument63		in  varchar2  default  null,
  argument64		in  varchar2  default  null,
  argument65		in  varchar2  default  null,
  argument66		in  varchar2  default  null,
  argument67		in  varchar2  default  null,
  argument68		in  varchar2  default  null,
  argument69		in  varchar2  default  null,
  argument70		in  varchar2  default  null,
  argument71		in  varchar2  default  null,
  argument72		in  varchar2  default  null,
  argument73		in  varchar2  default  null,
  argument74		in  varchar2  default  null,
  argument75		in  varchar2  default  null,
  argument76		in  varchar2  default  null,
  argument77		in  varchar2  default  null,
  argument78		in  varchar2  default  null,
  argument79		in  varchar2  default  null,
  argument80		in  varchar2  default  null,
  argument81		in  varchar2  default  null,
  argument82		in  varchar2  default  null,
  argument83		in  varchar2  default  null,
  argument84		in  varchar2  default  null,
  argument85		in  varchar2  default  null,
  argument86		in  varchar2  default  null,
  argument87		in  varchar2  default  null,
  argument88		in  varchar2  default  null,
  argument89		in  varchar2  default  null,
  argument90		in  varchar2  default  null,
  argument91		in  varchar2  default  null,
  argument92		in  varchar2  default  null,
  argument93		in  varchar2  default  null,
  argument94		in  varchar2  default  null,
  argument95		in  varchar2  default  null,
  argument96		in  varchar2  default  null,
  argument97		in  varchar2  default  null,
  argument98		in  varchar2  default  null,
  argument99		in  varchar2  default  null,
  argument100		in  varchar2  default  null) is

   h_request_id    NUMBER;
   h_login_id       NUMBER;
   h_err_msg       VARCHAR2(2000);
   h_nbv           NUMBER;
   h_debug BOOLEAN;
BEGIN
   h_debug := Upper(argument22) LIKE 'Y%';
   IF h_debug THEN
      fa_rx_util_pkg.enable_debug;
   END IF;

   h_request_id := fnd_global.conc_request_id;

   fnd_profile.get('LOGIN_ID',h_login_id);

   h_nbv := fnd_number.canonical_to_number(argument17);

   farx_al.asset_listing_run (
     book            => argument1,
     period          => argument3,
     from_bal	     => argument6,
     to_bal	     => argument7,
     from_acct	     => argument8,
     to_acct	     => argument9,
     from_cc	     => argument10,
     to_cc	     => argument11,
     major_category  => argument12,
     minor_category  => argument14,
     cat_seg_num     => argument15,
     cat_seg_val     => argument16,
     prop_type       => argument17,
     nbv             => h_nbv,
     fully_reserved  => argument19,
     cat_deprn_flag  => argument20,
     bought          => argument21,
     sob_id          => argument2,
     request_id      => h_request_id,
     login_id         => h_login_id,
     retcode         => retcode,
     errbuf          => errbuf);

   commit;

EXCEPTION WHEN OTHERS THEN
  fnd_message.set_name('OFA', 'FA_SHARED_SERVER_ERROR');
  h_err_msg := fnd_message.get;
  fa_rx_conc_mesg_pkg.log(h_err_msg);
  retcode := 2;

END asset_listing_run;
END FARX_C_AL;

/
