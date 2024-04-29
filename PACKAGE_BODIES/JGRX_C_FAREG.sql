--------------------------------------------------------
--  DDL for Package Body JGRX_C_FAREG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JGRX_C_FAREG" AS
/* $Header: jgrxcfrb.pls 115.2 2000/08/29 16:20:00 pkm ship   $ */

  -- FA Register core Report

PROCEDURE get_asset_rtrmnt_details(
  errbuf            OUT VARCHAR2,
  retcode           OUT VARCHAR2,
  argument1         IN  VARCHAR2,   -- Book Type
  argument2         IN  VARCHAR2,   -- From Period
  argument3         IN  VARCHAR2,   -- To Period
  argument4         IN  VARCHAR2,   -- Dummy
  argument5         IN  VARCHAR2,   -- Major Categoy
  argument6         IN  VARCHAR2,   -- Minor Category
  argument7         IN  VARCHAR2,   -- Report Type
  argument8         IN  VARCHAR2,   -- debug_flag
  argument9         IN  VARCHAR2,   -- sql_trace
  argument10        IN  VARCHAR2  DEFAULT  NULL,
  argument11        IN  VARCHAR2  DEFAULT  NULL,
  argument12        IN  VARCHAR2  DEFAULT  NULL,
  argument13        IN  VARCHAR2  DEFAULT  NULL,
  argument14        IN  VARCHAR2  DEFAULT  NULL,
  argument15        IN  VARCHAR2  DEFAULT  NULL,
  argument16        IN  VARCHAR2  DEFAULT  NULL,
  argument17        IN  VARCHAR2  DEFAULT  NULL,
  argument18        IN  VARCHAR2  DEFAULT  NULL,
  argument19        IN  VARCHAR2  DEFAULT  NULL,
  argument20        IN  VARCHAR2  DEFAULT  NULL,
  argument21        IN  VARCHAR2  DEFAULT  NULL,
  argument22        IN  VARCHAR2  DEFAULT  NULL,
  argument23        IN  VARCHAR2  DEFAULT  NULL,
  argument24        IN  VARCHAR2  DEFAULT  NULL,
  argument25        IN  VARCHAR2  DEFAULT  NULL,
  argument26        IN  VARCHAR2  DEFAULT  NULL,
  argument27        IN  VARCHAR2  DEFAULT  NULL,
  argument28        IN  VARCHAR2  DEFAULT  NULL,
  argument29        IN  VARCHAR2  DEFAULT  NULL,
  argument30        IN  VARCHAR2  DEFAULT  NULL,
  argument31        IN  VARCHAR2  DEFAULT  NULL,
  argument32        IN  VARCHAR2  DEFAULT  NULL,
  argument33        IN  VARCHAR2  DEFAULT  NULL,
  argument34        IN  VARCHAR2  DEFAULT  NULL,
  argument35        IN  VARCHAR2  DEFAULT  NULL,
  argument36        IN  VARCHAR2  DEFAULT  NULL,
  argument37        IN  VARCHAR2  DEFAULT  NULL,
  argument38        IN  VARCHAR2  DEFAULT  NULL,
  argument39        IN  VARCHAR2  DEFAULT  NULL,
  argument40        IN  VARCHAR2  DEFAULT  NULL,
  argument41        IN  VARCHAR2  DEFAULT  NULL,
  argument42        IN  VARCHAR2  DEFAULT  NULL,
  argument43        IN  VARCHAR2  DEFAULT  NULL,
  argument44        IN  VARCHAR2  DEFAULT  NULL,
  argument45        IN  VARCHAR2  DEFAULT  NULL,
  argument46        IN  VARCHAR2  DEFAULT  NULL,
  argument47        IN  VARCHAR2  DEFAULT  NULL,
  argument48        IN  VARCHAR2  DEFAULT  NULL,
  argument49        IN  VARCHAR2  DEFAULT  NULL,
  argument50        IN  VARCHAR2  DEFAULT  NULL,
  argument51        IN  VARCHAR2  DEFAULT  NULL,
  argument52        IN  VARCHAR2  DEFAULT  NULL,
  argument53        IN  VARCHAR2  DEFAULT  NULL,
  argument54        IN  VARCHAR2  DEFAULT  NULL,
  argument55        IN  VARCHAR2  DEFAULT  NULL,
  argument56        IN  VARCHAR2  DEFAULT  NULL,
  argument57        IN  VARCHAR2  DEFAULT  NULL,
  argument58        IN  VARCHAR2  DEFAULT  NULL,
  argument59        IN  VARCHAR2  DEFAULT  NULL,
  argument60        IN  VARCHAR2  DEFAULT  NULL,
  argument61        IN  VARCHAR2  DEFAULT  NULL,
  argument62        IN  VARCHAR2  DEFAULT  NULL,
  argument63        IN  VARCHAR2  DEFAULT  NULL,
  argument64        IN  VARCHAR2  DEFAULT  NULL,
  argument65        IN  VARCHAR2  DEFAULT  NULL,
  argument66        IN  VARCHAR2  DEFAULT  NULL,
  argument67        IN  VARCHAR2  DEFAULT  NULL,
  argument68        IN  VARCHAR2  DEFAULT  NULL,
  argument69        IN  VARCHAR2  DEFAULT  NULL,
  argument70        IN  VARCHAR2  DEFAULT  NULL,
  argument71        IN  VARCHAR2  DEFAULT  NULL,
  argument72        IN  VARCHAR2  DEFAULT  NULL,
  argument73        IN  VARCHAR2  DEFAULT  NULL,
  argument74        IN  VARCHAR2  DEFAULT  NULL,
  argument75        IN  VARCHAR2  DEFAULT  NULL,
  argument76        IN  VARCHAR2  DEFAULT  NULL,
  argument77        IN  VARCHAR2  DEFAULT  NULL,
  argument78        IN  VARCHAR2  DEFAULT  NULL,
  argument79        IN  VARCHAR2  DEFAULT  NULL,
  argument80        IN  VARCHAR2  DEFAULT  NULL,
  argument81        IN  VARCHAR2  DEFAULT  NULL,
  argument82        IN  VARCHAR2  DEFAULT  NULL,
  argument83        IN  VARCHAR2  DEFAULT  NULL,
  argument84        IN  VARCHAR2  DEFAULT  NULL,
  argument85        IN  VARCHAR2  DEFAULT  NULL,
  argument86        IN  VARCHAR2  DEFAULT  NULL,
  argument87        IN  VARCHAR2  DEFAULT  NULL,
  argument88        IN  VARCHAR2  DEFAULT  NULL,
  argument89        IN  VARCHAR2  DEFAULT  NULL,
  argument90        IN  VARCHAR2  DEFAULT  NULL,
  argument91        IN  VARCHAR2  DEFAULT  NULL,
  argument92        IN  VARCHAR2  DEFAULT  NULL,
  argument93        IN  VARCHAR2  DEFAULT  NULL,
  argument94        IN  VARCHAR2  DEFAULT  NULL,
  argument95        IN  VARCHAR2  DEFAULT  NULL,
  argument96        IN  VARCHAR2  DEFAULT  NULL,
  argument97        IN  VARCHAR2  DEFAULT  NULL,
  argument98        IN  VARCHAR2  DEFAULT  NULL,
  argument99        IN  VARCHAR2  DEFAULT  NULL,
  argument100       IN  VARCHAR2  DEFAULT  NULL)
IS
  l_request_id           NUMBER;
  debug_flag             VARCHAR2(1);
  sql_trace              VARCHAR2(1);

BEGIN
  --
  -- Assign parameters doing any necessary mappings
  -- e.g. date/number conversion
  l_request_id       := FND_GLOBAL.conc_request_id;
  debug_flag         := UPPER(SUBSTRB(argument8,1,1));
  sql_trace          := UPPER(SUBSTRB(argument9,1,1));

  --
  -- SQL Trace switches and debug flags are optional
  -- but highly recommended.
  IF sql_trace = 'Y' then
        FA_RX_UTIL_PKG.enable_trace;
  END IF;
  IF debug_flag = 'Y' then
        FA_RX_UTIL_PKG.enable_debug;
  END IF;

  --
  -- Run report
  JGRX_FAREG.fa_get_report(
        argument1,
        argument2,
        argument3,
        argument4,
        argument5,
        argument6,
        argument7,
        l_request_id,
        retcode,
        errbuf);

END get_asset_rtrmnt_details;

END JGRX_C_FAREG;

/
