--------------------------------------------------------
--  DDL for Package Body FA_RX_ALT_BAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_RX_ALT_BAL" as
/* $Header: farxacblb.pls 120.0.12010000.2 2009/07/19 12:57:56 glchen ship $ */




PROCEDURE ASSET_COST_BAL (
  errbuf	 out nocopy varchar2,
  retcode	 out nocopy varchar2,
  argument1		in	varchar2,   -- book
  argument2                 in      varchar2,   -- start_period_name
  argument3                 in      varchar2,   -- end_period_name
  argument4             in      varchar2,   -- standard 'N' or drill down 'Y'
  argument5           in      varchar2 default null,       --
  argument6        in  varchar2  default  null,
  argument7        in  varchar2  default  null,
  argument8        in  varchar2  default  null,
  argument9        in  varchar2  default  null,
  argument10        in  varchar2  default  null,
  argument11	   in  varchar2  default  null,
  argument12        in  varchar2  default  null,
  argument13        in  varchar2  default  null,
  argument14        in  varchar2  default  null,
  argument15        in  varchar2  default  null,
  argument16        in  varchar2  default  null,
  argument17        in  varchar2  default  null,
  argument18        in  varchar2  default  null,
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

h_request_id  number;
h_user_id    number;
h_err_msg   varchar2(2000);

h_report_style varchar2(1);

begin


 h_request_id := fnd_global.conc_request_id;

  fnd_profile.get('USER_ID',h_user_id);

  if nvl(argument4,'N') = 'Y' then
    h_report_style := 'D';
  else
    h_report_style := 'S';
  end if;

  farx_bl.asset_cost_balances_rpt (
    book => argument1,
    start_period_name => argument2,
    end_period_name => argument3,
    report_style => h_report_style, -- 'S' or 'D' -- Added for Group Depreciation
    request_id => h_request_id,
    user_id => h_user_id,
    errbuf => errbuf,
    retcode => retcode);

  commit;

exception when others then
  fnd_message.set_name('OFA','FA_SHARED_SERVER_ERROR');
  h_err_msg := fnd_message.get;
  fa_rx_conc_mesg_pkg.log(h_err_msg);
  retcode := 2;

end asset_cost_bal;




PROCEDURE CIP_COST_BAL (
  errbuf	 out nocopy varchar2,
  retcode	 out nocopy varchar2,
  argument1		in	varchar2,   -- book
  argument2                 in      varchar2,   -- start_period_name
  argument3                 in      varchar2,   -- end_period_name
  argument4             in      varchar2 default null,   --login id
  argument5           in      varchar2 default null,       --
  argument6        in  varchar2  default  null,
  argument7        in  varchar2  default  null,
  argument8        in  varchar2  default  null,
  argument9        in  varchar2  default  null,
  argument10        in  varchar2  default  null,
  argument11	   in  varchar2  default  null,
  argument12        in  varchar2  default  null,
  argument13        in  varchar2  default  null,
  argument14        in  varchar2  default  null,
  argument15        in  varchar2  default  null,
  argument16        in  varchar2  default  null,
  argument17        in  varchar2  default  null,
  argument18        in  varchar2  default  null,
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

h_request_id  number;
h_user_id    number;
h_err_msg   varchar2(2000);

begin

 h_request_id := fnd_global.conc_request_id;

  fnd_profile.get('USER_ID',h_user_id);

  farx_bl.cip_balances_rpt (
    book => argument1,
    start_period_name => argument2,
    end_period_name => argument3,
    request_id => h_request_id,
    user_id => h_user_id,
    errbuf => errbuf,
    retcode => retcode);

  commit;

exception when others then
  fnd_message.set_name('OFA','FA_SHARED_SERVER_ERROR');
  h_err_msg := fnd_message.get;
  fa_rx_conc_mesg_pkg.log(h_err_msg);
  retcode := 2;

end cip_cost_bal;




PROCEDURE ACCUM_DEPRN_BAL (
  errbuf	 out nocopy varchar2,
  retcode	 out nocopy varchar2,
  argument1		in	varchar2,   -- book
  argument2                 in      varchar2,   -- start_period_name
  argument3                 in      varchar2,   -- end_period_name
  argument4             in      varchar2,   -- Standard 'N' or Drill Down 'Y'
  argument5           in      varchar2 default null,       --
  argument6        in  varchar2  default  null,
  argument7        in  varchar2  default  null,
  argument8        in  varchar2  default  null,
  argument9        in  varchar2  default  null,
  argument10        in  varchar2  default  null,
  argument11	   in  varchar2  default  null,
  argument12        in  varchar2  default  null,
  argument13        in  varchar2  default  null,
  argument14        in  varchar2  default  null,
  argument15        in  varchar2  default  null,
  argument16        in  varchar2  default  null,
  argument17        in  varchar2  default  null,
  argument18        in  varchar2  default  null,
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

h_user_id    number;
h_request_id  number;
h_err_msg   varchar2(2000);

h_report_style varchar2(1);

begin

 h_request_id := fnd_global.conc_request_id;

  fnd_profile.get('USER_ID',h_user_id);

  if nvl(argument4,'N') = 'Y' then
    h_report_style := 'D';
  else
    h_report_style := 'S';
  end if;

  farx_bl.accum_deprn_balances_rpt (
    book => argument1,
    start_period_name => argument2,
    end_period_name => argument3,
    report_style => h_report_style,
    request_id => h_request_id,
    user_id => h_user_id,
    errbuf => errbuf,
    retcode => retcode);

  commit;
exception when others then
  fnd_message.set_name('OFA','FA_SHARED_SERVER_ERROR');
  h_err_msg := fnd_message.get;
  fa_rx_conc_mesg_pkg.log(h_err_msg);
  retcode := 2;

end accum_deprn_bal;




PROCEDURE REVAL_RSV_BAL (
  errbuf	 out nocopy varchar2,
  retcode	 out nocopy varchar2,
  argument1		in	varchar2,   -- book
  argument2                 in      varchar2,   -- start_period_name
  argument3                 in      varchar2,   -- end_period_name
  argument4             in      varchar2 default null,   --login id
  argument5           in      varchar2 default null,       --
  argument6        in  varchar2  default  null,
  argument7        in  varchar2  default  null,
  argument8        in  varchar2  default  null,
  argument9        in  varchar2  default  null,
  argument10        in  varchar2  default  null,
  argument11	   in  varchar2  default  null,
  argument12        in  varchar2  default  null,
  argument13        in  varchar2  default  null,
  argument14        in  varchar2  default  null,
  argument15        in  varchar2  default  null,
  argument16        in  varchar2  default  null,
  argument17        in  varchar2  default  null,
  argument18        in  varchar2  default  null,
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

h_user_id    number;
h_request_id  number;
h_err_msg   varchar2(2000);

begin

  fnd_message.set_name('OFA','FA_SHARED_SAVE_FIRST');
  h_err_msg := fnd_message.get;

  fa_rx_conc_mesg_pkg.log(h_err_msg);


 h_request_id := fnd_global.conc_request_id;

  fnd_profile.get('USER_ID',h_user_id);

  farx_bl.reval_reserve_balances_rpt (
    book => argument1,
    start_period_name => argument2,
    end_period_name => argument3,
    request_id => h_request_id,
    user_id => h_user_id,
    errbuf => errbuf,
    retcode => retcode);

  commit;
exception when others then
  fnd_message.set_name('OFA','FA_SHARED_SERVER_ERROR');
  h_err_msg := fnd_message.get;
  fa_rx_conc_mesg_pkg.log(h_err_msg);
  retcode := 2;

end reval_rsv_bal;




END FA_RX_ALT_BAL;

/
