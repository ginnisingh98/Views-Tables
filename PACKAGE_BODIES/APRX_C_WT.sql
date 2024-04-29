--------------------------------------------------------
--  DDL for Package Body APRX_C_WT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."APRX_C_WT" AS
/* $Header: aprxcwtb.pls 120.3 2006/02/24 09:27:59 sarakris noship $ */

  -- AP Witholding core Report

PROCEDURE get_awt_tax(
  errbuf               out NOCOPY varchar2,
  retcode              out NOCOPY varchar2,
  argument1         in  varchar2,   -- date from
  argument2         in  varchar2,   -- date to
  argument3         in  varchar2,   -- supplier from
  argument4         in  varchar2,   -- supplier to
  argument5         in  varchar2,   -- supplier type
  argument6         in  varchar2,   -- debug_flag
  argument7         in  varchar2,   -- sql_trace
  argument8         in  varchar2  default  null,
  argument9         in  varchar2  default  null,
  argument10        in  varchar2  default  null,
  argument11        in  varchar2  default  null,
  argument12        in  varchar2  default  null,
  argument13        in  varchar2  default  null,
  argument14        in  varchar2  default  null,
  argument15        in  varchar2  default  null,
  argument16        in  varchar2  default  null,
  argument17        in  varchar2  default  null,
  argument18        in  varchar2  default  null,
  argument19        in  varchar2  default  null,
  argument20        in  varchar2  default  null,
  argument21        in  varchar2  default  null,
  argument22        in  varchar2  default  null,
  argument23        in  varchar2  default  null,
  argument24        in  varchar2  default  null,
  argument25        in  varchar2  default  null,
  argument26        in  varchar2  default  null,
  argument27        in  varchar2  default  null,
  argument28        in  varchar2  default  null,
  argument29        in  varchar2  default  null,
  argument30        in  varchar2  default  null,
  argument31        in  varchar2  default  null,
  argument32        in  varchar2  default  null,
  argument33        in  varchar2  default  null,
  argument34        in  varchar2  default  null,
  argument35        in  varchar2  default  null,
  argument36        in  varchar2  default  null,
  argument37        in  varchar2  default  null,
  argument38        in  varchar2  default  null,
  argument39        in  varchar2  default  null,
  argument40        in  varchar2  default  null,
  argument41        in  varchar2  default  null,
  argument42        in  varchar2  default  null,
  argument43        in  varchar2  default  null,
  argument44        in  varchar2  default  null,
  argument45        in  varchar2  default  null,
  argument46        in  varchar2  default  null,
  argument47        in  varchar2  default  null,
  argument48        in  varchar2  default  null,
  argument49        in  varchar2  default  null,
  argument50        in  varchar2  default  null,
  argument51        in  varchar2  default  null,
  argument52        in  varchar2  default  null,
  argument53        in  varchar2  default  null,
  argument54        in  varchar2  default  null,
  argument55        in  varchar2  default  null,
  argument56        in  varchar2  default  null,
  argument57        in  varchar2  default  null,
  argument58        in  varchar2  default  null,
  argument59        in  varchar2  default  null,
  argument60        in  varchar2  default  null,
  argument61        in  varchar2  default  null,
  argument62        in  varchar2  default  null,
  argument63        in  varchar2  default  null,
  argument64        in  varchar2  default  null,
  argument65        in  varchar2  default  null,
  argument66        in  varchar2  default  null,
  argument67        in  varchar2  default  null,
  argument68        in  varchar2  default  null,
  argument69        in  varchar2  default  null,
  argument70        in  varchar2  default  null,
  argument71        in  varchar2  default  null,
  argument72        in  varchar2  default  null,
  argument73        in  varchar2  default  null,
  argument74        in  varchar2  default  null,
  argument75        in  varchar2  default  null,
  argument76        in  varchar2  default  null,
  argument77        in  varchar2  default  null,
  argument78        in  varchar2  default  null,
  argument79        in  varchar2  default  null,
  argument80        in  varchar2  default  null,
  argument81        in  varchar2  default  null,
  argument82        in  varchar2  default  null,
  argument83        in  varchar2  default  null,
  argument84        in  varchar2  default  null,
  argument85        in  varchar2  default  null,
  argument86        in  varchar2  default  null,
  argument87        in  varchar2  default  null,
  argument88        in  varchar2  default  null,
  argument89        in  varchar2  default  null,
  argument90        in  varchar2  default  null,
  argument91        in  varchar2  default  null,
  argument92        in  varchar2  default  null,
  argument93        in  varchar2  default  null,
  argument94        in  varchar2  default  null,
  argument95        in  varchar2  default  null,
  argument96        in  varchar2  default  null,
  argument97        in  varchar2  default  null,
  argument98        in  varchar2  default  null,
  argument99        in  varchar2  default  null,
  argument100       in  varchar2  default  null)
is
  l_request_id           number;
  debug_flag             varchar2(1);
  sql_trace              varchar2(1);

begin
  --
  -- Assign parameters doing any necessary mappings
  -- e.g. date/number conversion
  l_request_id       := fnd_global.conc_request_id;
  debug_flag         := upper(substrb(argument6,1,1));
  sql_trace          := upper(substrb(argument7,1,1));

  --
  -- SQL Trace switches and debug flags are optional
  -- but highly recommended.
  if debug_flag = 'Y' then
        fa_rx_util_pkg.enable_debug;
  end if;

  --
  -- Run report
  aprx_wt.ap_wht_tax_report(
        argument1,
        argument2,
        argument3,
        argument4,
        argument5,
        l_request_id,
        retcode,
        errbuf);
end get_awt_tax;

END APRX_C_WT;

/
