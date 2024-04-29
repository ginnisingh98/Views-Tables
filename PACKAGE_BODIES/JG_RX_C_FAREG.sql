--------------------------------------------------------
--  DDL for Package Body JG_RX_C_FAREG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_RX_C_FAREG" AS
/* $Header: jgrxcfrb.pls 115.7 2003/12/30 15:43:03 mbickley ship $ */

  -- FA Register core Report

PROCEDURE get_asset_rtrmnt_details(
  errbuf            OUT NOCOPY VARCHAR2,
  retcode           OUT NOCOPY VARCHAR2,
  argument1         IN  VARCHAR2,   -- Book Type
  argument2         IN  VARCHAR2,   -- From Period
  argument3         IN  VARCHAR2,   -- To Period
  argument4         IN  VARCHAR2,   -- Dummy
  argument5         IN  VARCHAR2,   -- Major Categoy
  argument6         IN  VARCHAR2,   -- Minor Category
  argument7         IN  VARCHAR2,   -- Report Type
  argument8         IN  VARCHAR2,   -- debug_flag
  argument9         IN  VARCHAR2,   -- sql_trace
  argument10        IN  VARCHAR2,
  argument11        IN  VARCHAR2,
  argument12        IN  VARCHAR2,
  argument13        IN  VARCHAR2,
  argument14        IN  VARCHAR2,
  argument15        IN  VARCHAR2,
  argument16        IN  VARCHAR2,
  argument17        IN  VARCHAR2,
  argument18        IN  VARCHAR2,
  argument19        IN  VARCHAR2,
  argument20        IN  VARCHAR2,
  argument21        IN  VARCHAR2,
  argument22        IN  VARCHAR2,
  argument23        IN  VARCHAR2,
  argument24        IN  VARCHAR2,
  argument25        IN  VARCHAR2,
  argument26        IN  VARCHAR2,
  argument27        IN  VARCHAR2,
  argument28        IN  VARCHAR2,
  argument29        IN  VARCHAR2,
  argument30        IN  VARCHAR2,
  argument31        IN  VARCHAR2,
  argument32        IN  VARCHAR2,
  argument33        IN  VARCHAR2,
  argument34        IN  VARCHAR2,
  argument35        IN  VARCHAR2,
  argument36        IN  VARCHAR2,
  argument37        IN  VARCHAR2,
  argument38        IN  VARCHAR2,
  argument39        IN  VARCHAR2,
  argument40        IN  VARCHAR2,
  argument41        IN  VARCHAR2,
  argument42        IN  VARCHAR2,
  argument43        IN  VARCHAR2,
  argument44        IN  VARCHAR2,
  argument45        IN  VARCHAR2,
  argument46        IN  VARCHAR2,
  argument47        IN  VARCHAR2,
  argument48        IN  VARCHAR2,
  argument49        IN  VARCHAR2,
  argument50        IN  VARCHAR2,
  argument51        IN  VARCHAR2,
  argument52        IN  VARCHAR2,
  argument53        IN  VARCHAR2,
  argument54        IN  VARCHAR2,
  argument55        IN  VARCHAR2,
  argument56        IN  VARCHAR2,
  argument57        IN  VARCHAR2,
  argument58        IN  VARCHAR2,
  argument59        IN  VARCHAR2,
  argument60        IN  VARCHAR2,
  argument61        IN  VARCHAR2,
  argument62        IN  VARCHAR2,
  argument63        IN  VARCHAR2,
  argument64        IN  VARCHAR2,
  argument65        IN  VARCHAR2,
  argument66        IN  VARCHAR2,
  argument67        IN  VARCHAR2,
  argument68        IN  VARCHAR2,
  argument69        IN  VARCHAR2,
  argument70        IN  VARCHAR2,
  argument71        IN  VARCHAR2,
  argument72        IN  VARCHAR2,
  argument73        IN  VARCHAR2,
  argument74        IN  VARCHAR2,
  argument75        IN  VARCHAR2,
  argument76        IN  VARCHAR2,
  argument77        IN  VARCHAR2,
  argument78        IN  VARCHAR2,
  argument79        IN  VARCHAR2,
  argument80        IN  VARCHAR2,
  argument81        IN  VARCHAR2,
  argument82        IN  VARCHAR2,
  argument83        IN  VARCHAR2,
  argument84        IN  VARCHAR2,
  argument85        IN  VARCHAR2,
  argument86        IN  VARCHAR2,
  argument87        IN  VARCHAR2,
  argument88        IN  VARCHAR2,
  argument89        IN  VARCHAR2,
  argument90        IN  VARCHAR2,
  argument91        IN  VARCHAR2,
  argument92        IN  VARCHAR2,
  argument93        IN  VARCHAR2,
  argument94        IN  VARCHAR2,
  argument95        IN  VARCHAR2,
  argument96        IN  VARCHAR2,
  argument97        IN  VARCHAR2,
  argument98        IN  VARCHAR2,
  argument99        IN  VARCHAR2,
  argument100       IN  VARCHAR2)
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

  -- ATG mandate remove sql code trace
  -- IF sql_trace = 'Y' then
  --       FA_RX_UTIL_PKG.enable_trace;
  -- END IF;

  IF debug_flag = 'Y' then
        FA_RX_UTIL_PKG.enable_debug;
  END IF;

  --
  -- Run report


      JG_RX_FAREG.fa_get_report(
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

END JG_RX_C_FAREG;

/
