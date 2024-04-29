--------------------------------------------------------
--  DDL for Package Body FARX_C_DP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FARX_C_DP" AS
/* $Header: farxcdpb.pls 120.4.12010000.3 2009/10/30 11:23:02 pmadas ship $ */
g_print_debug boolean := fa_cache_pkg.fa_print_debug;

PROCEDURE deprn_rep (
  errbuf         out nocopy varchar2,
  retcode        out nocopy varchar2,
  argument1             in  varchar2,   -- book
  argument2             in  varchar2,   -- MRC: Set of books id
  argument3             in  varchar2,   -- period_name
  argument4             in  varchar2,   -- report_style
  argument5             in  varchar2  default  null, -- debug
  argument6             in  varchar2  default  null,
  argument7             in  varchar2  default  null,
  argument8             in  varchar2  default  null,
  argument9             in  varchar2  default  null,
  argument10            in  varchar2  default  null,
  argument11            in  varchar2  default  null,
  argument12            in  varchar2  default  null,
  argument13            in  varchar2  default  null,
  argument14            in  varchar2  default  null,
  argument15            in  varchar2  default  null,
  argument16            in  varchar2  default  null,
  argument17            in  varchar2  default  null,
  argument18            in  varchar2  default  null,
  argument19            in  varchar2  default  null,
  argument20            in  varchar2  default  null,
  argument21            in  varchar2  default  null,
  argument22            in  varchar2  default  null,
  argument23            in  varchar2  default  null,
  argument24            in  varchar2  default  null,
  argument25            in  varchar2  default  null,
  argument26            in  varchar2  default  null,
  argument27            in  varchar2  default  null,
  argument28            in  varchar2  default  null,
  argument29            in  varchar2  default  null,
  argument30            in  varchar2  default  null,
  argument31            in  varchar2  default  null,
  argument32            in  varchar2  default  null,
  argument33            in  varchar2  default  null,
  argument34            in  varchar2  default  null,
  argument35            in  varchar2  default  null,
  argument36            in  varchar2  default  null,
  argument37            in  varchar2  default  null,
  argument38            in  varchar2  default  null,
  argument39            in  varchar2  default  null,
  argument40            in  varchar2  default  null,
  argument41            in  varchar2  default  null,
  argument42            in  varchar2  default  null,
  argument43            in  varchar2  default  null,
  argument44            in  varchar2  default  null,
  argument45            in  varchar2  default  null,
  argument46            in  varchar2  default  null,
  argument47            in  varchar2  default  null,
  argument48            in  varchar2  default  null,
  argument49            in  varchar2  default  null,
  argument50            in  varchar2  default  null,
  argument51            in  varchar2  default  null,
  argument52            in  varchar2  default  null,
  argument53            in  varchar2  default  null,
  argument54            in  varchar2  default  null,
  argument55            in  varchar2  default  null,
  argument56            in  varchar2  default  null,
  argument57            in  varchar2  default  null,
  argument58            in  varchar2  default  null,
  argument59            in  varchar2  default  null,
  argument60            in  varchar2  default  null,
  argument61            in  varchar2  default  null,
  argument62            in  varchar2  default  null,
  argument63            in  varchar2  default  null,
  argument64            in  varchar2  default  null,
  argument65            in  varchar2  default  null,
  argument66            in  varchar2  default  null,
  argument67            in  varchar2  default  null,
  argument68            in  varchar2  default  null,
  argument69            in  varchar2  default  null,
  argument70            in  varchar2  default  null,
  argument71            in  varchar2  default  null,
  argument72            in  varchar2  default  null,
  argument73            in  varchar2  default  null,
  argument74            in  varchar2  default  null,
  argument75            in  varchar2  default  null,
  argument76            in  varchar2  default  null,
  argument77            in  varchar2  default  null,
  argument78            in  varchar2  default  null,
  argument79            in  varchar2  default  null,
  argument80            in  varchar2  default  null,
  argument81            in  varchar2  default  null,
  argument82            in  varchar2  default  null,
  argument83            in  varchar2  default  null,
  argument84            in  varchar2  default  null,
  argument85            in  varchar2  default  null,
  argument86            in  varchar2  default  null,
  argument87            in  varchar2  default  null,
  argument88            in  varchar2  default  null,
  argument89            in  varchar2  default  null,
  argument90            in  varchar2  default  null,
  argument91            in  varchar2  default  null,
  argument92            in  varchar2  default  null,
  argument93            in  varchar2  default  null,
  argument94            in  varchar2  default  null,
  argument95            in  varchar2  default  null,
  argument96            in  varchar2  default  null,
  argument97            in  varchar2  default  null,
  argument98            in  varchar2  default  null,
  argument99            in  varchar2  default  null,
  argument100           in  varchar2  default  null) is

   h_request_id    NUMBER;
   h_login_id       NUMBER;
   h_err_msg       VARCHAR2(2000);
   h_debug         BOOLEAN;

   h_report_style  VARCHAR2(1);

BEGIN
   h_debug := Upper(argument5) LIKE 'Y%';  -- MRC
   IF h_debug THEN
      fa_rx_util_pkg.enable_debug;
   END IF;

   --  select max(fcr.request_id) into h_request_id
   --  from fnd_concurrent_requests fcr, fnd_concurrent_programs fcp
   --  where fcr.argument1 = argument1
   --  and fcr.argument2 = argument2
   --  and fcr.argument3 = argument3
   --  and fcr.phase_code = 'R'
   --  and fcr.concurrent_program_id = fcp.concurrent_program_id
   --  and fcp.concurrent_program_name = 'RXFARL';

   h_request_id := fnd_global.conc_request_id;
   fnd_profile.get('LOGIN_ID',h_login_id);

   if nvl(argument4,'N') = 'Y' then  -- MRC
     h_report_style := 'D';
   else
     h_report_style := 'S';
   end if;

   farx_dp.deprn_run (
     book             => argument1,
     sob_id           => argument2,  -- MRC
     period           => argument3,  -- MRC
     from_bal         => NULL,
     to_bal           => NULL,
     from_acct        => NULL,
     to_acct          => NULL,
     from_cc          => NULL,
     to_cc            => NULL,
     from_maj_cat     => NULL,
     from_min_cat     => NULL,
     cat_seg_num      => NULL,
     from_cat_seg_val => NULL,
     prop_type        => NULL,
     to_maj_cat       => NULL,
     to_min_cat       => NULL,
     to_cat_seg_val   => NULL,
     from_asset_num   => NULL,
     to_asset_num     => NULL,
     report_style     => h_report_style,
     request_id       => h_request_id,
     login_id         => h_login_id,
     retcode          => retcode,
     errbuf           => errbuf);

   commit;

EXCEPTION WHEN OTHERS THEN
  fnd_message.set_name('OFA', 'FA_SHARED_SERVER_ERROR');
  h_err_msg := fnd_message.get;
  fa_rx_conc_mesg_pkg.log(h_err_msg);
  retcode := 2;

END deprn_rep;

--

PROCEDURE book_run (
  errbuf         out nocopy varchar2,
  retcode        out nocopy varchar2,
  argument1             in  varchar2,   -- book
  argument2             in  varchar2,   -- period_name
  argument3             in  varchar2,   -- chart_of_accounts_id
  argument4             in  varchar2,   -- chart_of_accounts_id
  argument5             in  varchar2  default  null, -- from balancing
  argument6             in  varchar2  default  null, -- to   balancing
  argument7             in  varchar2  default  null, -- from account
  argument8             in  varchar2  default  null, -- to   account
  argument9             in  varchar2  default  null, -- from cc
  argument10            in  varchar2  default  null, -- to   cc
  argument11            in  varchar2  default  null, -- from major category
  argument12            in  varchar2  default  null, -- to   major category
  argument13            in  varchar2  default  null, -- minor category exists check
  argument14            in  varchar2  default  null, -- from minor category
  argument15            in  varchar2  default  null, -- to   minor category
  argument16            in  varchar2  default  null, -- category segment number
  argument17            in  varchar2  default  null, -- from category segment value
  argument18            in  varchar2  default  null, -- to   category segment value
  argument19            in  varchar2  default  null, -- property type
  argument20            in  varchar2  default  null, -- from asset number
  argument21            in  varchar2  default  null, -- to   asset number
  argument22            in  varchar2,   -- report_style
  argument23            in  varchar2  default  null, -- debug
  argument24            in  varchar2  default  null,
  argument25            in  varchar2  default  null,
  argument26            in  varchar2  default  null,
  argument27            in  varchar2  default  null,
  argument28            in  varchar2  default  null,
  argument29            in  varchar2  default  null,
  argument30            in  varchar2  default  null,
  argument31            in  varchar2  default  null,
  argument32            in  varchar2  default  null,
  argument33            in  varchar2  default  null,
  argument34            in  varchar2  default  null,
  argument35            in  varchar2  default  null,
  argument36            in  varchar2  default  null,
  argument37            in  varchar2  default  null,
  argument38            in  varchar2  default  null,
  argument39            in  varchar2  default  null,
  argument40            in  varchar2  default  null,
  argument41            in  varchar2  default  null,
  argument42            in  varchar2  default  null,
  argument43            in  varchar2  default  null,
  argument44            in  varchar2  default  null,
  argument45            in  varchar2  default  null,
  argument46            in  varchar2  default  null,
  argument47            in  varchar2  default  null,
  argument48            in  varchar2  default  null,
  argument49            in  varchar2  default  null,
  argument50            in  varchar2  default  null,
  argument51            in  varchar2  default  null,
  argument52            in  varchar2  default  null,
  argument53            in  varchar2  default  null,
  argument54            in  varchar2  default  null,
  argument55            in  varchar2  default  null,
  argument56            in  varchar2  default  null,
  argument57            in  varchar2  default  null,
  argument58            in  varchar2  default  null,
  argument59            in  varchar2  default  null,
  argument60            in  varchar2  default  null,
  argument61            in  varchar2  default  null,
  argument62            in  varchar2  default  null,
  argument63            in  varchar2  default  null,
  argument64            in  varchar2  default  null,
  argument65            in  varchar2  default  null,
  argument66            in  varchar2  default  null,
  argument67            in  varchar2  default  null,
  argument68            in  varchar2  default  null,
  argument69            in  varchar2  default  null,
  argument70            in  varchar2  default  null,
  argument71            in  varchar2  default  null,
  argument72            in  varchar2  default  null,
  argument73            in  varchar2  default  null,
  argument74            in  varchar2  default  null,
  argument75            in  varchar2  default  null,
  argument76            in  varchar2  default  null,
  argument77            in  varchar2  default  null,
  argument78            in  varchar2  default  null,
  argument79            in  varchar2  default  null,
  argument80            in  varchar2  default  null,
  argument81            in  varchar2  default  null,
  argument82            in  varchar2  default  null,
  argument83            in  varchar2  default  null,
  argument84            in  varchar2  default  null,
  argument85            in  varchar2  default  null,
  argument86            in  varchar2  default  null,
  argument87            in  varchar2  default  null,
  argument88            in  varchar2  default  null,
  argument89            in  varchar2  default  null,
  argument90            in  varchar2  default  null,
  argument91            in  varchar2  default  null,
  argument92            in  varchar2  default  null,
  argument93            in  varchar2  default  null,
  argument94            in  varchar2  default  null,
  argument95            in  varchar2  default  null,
  argument96            in  varchar2  default  null,
  argument97            in  varchar2  default  null,
  argument98            in  varchar2  default  null,
  argument99            in  varchar2  default  null,
  argument100           in  varchar2  default  null) is

   h_request_id    NUMBER;
   h_login_id       NUMBER;
   h_err_msg       VARCHAR2(2000);
   h_debug BOOLEAN;

   h_report_style  VARCHAR2(1);
BEGIN
   --
   h_debug := Upper(argument23) LIKE 'Y%';
   IF h_debug THEN
      fa_rx_util_pkg.enable_debug;
   END IF;

   if nvl(argument22,'N') = 'Y' then
     h_report_style := 'D';
   else
     h_report_style := 'S';
   end if;

   IF (g_print_debug) THEN
        fa_rx_util_pkg.debug('book_run: ' || 'argument1:' ||argument1);
        fa_rx_util_pkg.debug('book_run: ' || 'argument2:' ||argument2);
        fa_rx_util_pkg.debug('book_run: ' || 'argument3:' ||argument3);
        fa_rx_util_pkg.debug('book_run: ' || 'argument4:' ||argument4);
        fa_rx_util_pkg.debug('book_run: ' || 'argument5:' ||argument5);
        fa_rx_util_pkg.debug('book_run: ' || 'argument6:' ||argument6);
        fa_rx_util_pkg.debug('book_run: ' || 'argument7:' ||argument7);
        fa_rx_util_pkg.debug('book_run: ' || 'argument8:' ||argument8);
        fa_rx_util_pkg.debug('book_run: ' || 'argument9:' ||argument9);
        fa_rx_util_pkg.debug('book_run: ' || 'argument10:' ||argument10);
        fa_rx_util_pkg.debug('book_run: ' || 'argument11:' ||argument11);
        fa_rx_util_pkg.debug('book_run: ' || 'argument12:' ||argument12);
        fa_rx_util_pkg.debug('book_run: ' || 'argument13:' ||argument13);
        fa_rx_util_pkg.debug('book_run: ' || 'argument14:' ||argument14);
        fa_rx_util_pkg.debug('book_run: ' || 'argument15:' ||argument15);
        fa_rx_util_pkg.debug('book_run: ' || 'argument16:' ||argument16);
        fa_rx_util_pkg.debug('book_run: ' || 'argument17:' ||argument17);
        fa_rx_util_pkg.debug('book_run: ' || 'argument18:' ||argument18);
        fa_rx_util_pkg.debug('book_run: ' || 'argument19:' ||argument19);
        fa_rx_util_pkg.debug('book_run: ' || 'argument20:' ||argument20);
        fa_rx_util_pkg.debug('book_run: ' || 'argument21:' ||argument21);
        fa_rx_util_pkg.debug('book_run: ' || 'argument22:' ||argument22);
   END IF;

   --  select max(fcr.request_id) into h_request_id
   --  from fnd_concurrent_requests fcr, fnd_concurrent_programs fcp
   --  where fcr.argument1 = argument1
   --  and fcr.argument2 = argument2
   --  and fcr.argument3 = argument3
   --  and fcr.phase_code = 'R'
   --  and fcr.concurrent_program_id = fcp.concurrent_program_id
   --  and fcp.concurrent_program_name = 'RXFARL';

   h_request_id := fnd_global.conc_request_id;
   fnd_profile.get('LOGIN_ID',h_login_id);

   farx_dp.deprn_run (
     book             => argument1,
     period           => argument2,
     from_bal         => argument5,
     to_bal           => argument6,
     from_acct        => argument7,
     to_acct          => argument8,
     from_cc          => argument9,
     to_cc            => argument10,
     from_maj_cat     => argument11,
     to_maj_cat       => argument12,
     from_min_cat     => argument14,
     to_min_cat       => argument15,
     cat_seg_num      => argument16,
     from_cat_seg_val => argument17,
     to_cat_seg_val   => argument18,
     prop_type        => argument19,
     from_asset_num   => argument20,
     to_asset_num     => argument21,
     report_style     => h_report_style,
     request_id       => h_request_id,
     login_id         => h_login_id,
     retcode          => retcode,
     errbuf           => errbuf);

   commit;

EXCEPTION WHEN OTHERS THEN
  fnd_message.set_name('OFA', 'FA_SHARED_SERVER_ERROR');
  h_err_msg := fnd_message.get;
  fa_rx_conc_mesg_pkg.log(h_err_msg);
  retcode := 2;

END book_run;

END FARX_C_DP;

/
