--------------------------------------------------------
--  DDL for Package Body FA_RXC_GROUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_RXC_GROUP" AS
/* $Header: farxcgab.pls 120.2.12010000.3 2009/10/30 10:17:00 pmadas ship $ */

-- global variables
g_print_debug boolean := fa_cache_pkg.fa_print_debug;


PROCEDURE get_group_asset_info (
  x_errbuf          out NOCOPY varchar2,
  x_retcode         out NOCOPY varchar2,
  argument1         in  varchar2,   -- book
  -- MRC
  argument2         in  varchar2,   -- MRC: Set of books id
  argument3         in  varchar2,   -- start filcal year
  argument4         in  varchar2,   -- end fiscal year
  argument5         in  varchar2,   -- category structure number
  argument6         in  varchar2,   -- major category low
  argument7         in  varchar2,   -- major category high
  argument8         in  varchar2,   -- minor category exists
  argument9         in  varchar2,   -- minor category low
  argument10        in  varchar2,   -- minor category high
  argument11        in  varchar2,   -- category segment name
  argument12        in  varchar2,   -- category segment name low
  argument13        in  varchar2,   -- category segment name high
  argument14        in  varchar2,   -- asset number low
  argument15        in  varchar2,   -- asset number high
  argument16        in  varchar2,   -- drill down
  argument17        in  varchar2,   -- debug
  -- End MRC
  argument18        in  varchar2,
  argument19        in  varchar2,
  argument20        in  varchar2,
  argument21        in  varchar2,
  argument22        in  varchar2,
  argument23        in  varchar2,
  argument24        in  varchar2,
  argument25        in  varchar2,
  argument26        in  varchar2,
  argument27        in  varchar2,
  argument28        in  varchar2,
  argument29        in  varchar2,
  argument30        in  varchar2,
  argument31        in  varchar2,
  argument32        in  varchar2,
  argument33        in  varchar2,
  argument34        in  varchar2,
  argument35        in  varchar2,
  argument36        in  varchar2,
  argument37        in  varchar2,
  argument38        in  varchar2,
  argument39        in  varchar2,
  argument40        in  varchar2,
  argument41        in  varchar2,
  argument42        in  varchar2,
  argument43        in  varchar2,
  argument44        in  varchar2,
  argument45        in  varchar2,
  argument46        in  varchar2,
  argument47        in  varchar2,
  argument48        in  varchar2,
  argument49        in  varchar2,
  argument50        in  varchar2,
  argument51        in  varchar2,
  argument52        in  varchar2,
  argument53        in  varchar2,
  argument54        in  varchar2,
  argument55        in  varchar2,
  argument56        in  varchar2,
  argument57        in  varchar2,
  argument58        in  varchar2,
  argument59        in  varchar2,
  argument60        in  varchar2,
  argument61        in  varchar2,
  argument62        in  varchar2,
  argument63        in  varchar2,
  argument64        in  varchar2,
  argument65        in  varchar2,
  argument66        in  varchar2,
  argument67        in  varchar2,
  argument68        in  varchar2,
  argument69        in  varchar2,
  argument70        in  varchar2,
  argument71        in  varchar2,
  argument72        in  varchar2,
  argument73        in  varchar2,
  argument74        in  varchar2,
  argument75        in  varchar2,
  argument76        in  varchar2,
  argument77        in  varchar2,
  argument78        in  varchar2,
  argument79        in  varchar2,
  argument80        in  varchar2,
  argument81        in  varchar2,
  argument82        in  varchar2,
  argument83        in  varchar2,
  argument84        in  varchar2,
  argument85        in  varchar2,
  argument86        in  varchar2,
  argument87        in  varchar2,
  argument88        in  varchar2,
  argument89        in  varchar2,
  argument90        in  varchar2,
  argument91        in  varchar2,
  argument92        in  varchar2,
  argument93        in  varchar2,
  argument94        in  varchar2,
  argument95        in  varchar2,
  argument96        in  varchar2,
  argument97        in  varchar2,
  argument98        in  varchar2,
  argument99        in  varchar2,
  argument100       in  varchar2)
IS
  l_request_id      NUMBER;
  l_user_id         NUMBER;
  l_err_msg         VARCHAR2(2000);
  l_debug           BOOLEAN;

BEGIN
  l_debug := UPPER(argument17) LIKE 'Y%';   -- MRC
  IF l_debug THEN
    fa_rx_util_pkg.enable_debug;
  END IF;

  IF (g_print_debug) THEN
    fa_rx_util_pkg.debug('get_group_asset_info: ' || 'argument1:' ||argument1);
    -- MRC
    fa_rx_util_pkg.debug('get_group_asset_info: ' || 'argument2:' ||argument2);
    fa_rx_util_pkg.debug('get_group_asset_info: ' || 'argument3:' ||argument3);
    fa_rx_util_pkg.debug('get_group_asset_info: ' || 'argument4:' ||argument4);
    fa_rx_util_pkg.debug('get_group_asset_info: ' || 'argument5:' ||argument5);
    fa_rx_util_pkg.debug('get_group_asset_info: ' || 'argument6:' ||argument6);
    fa_rx_util_pkg.debug('get_group_asset_info: ' || 'argument7:' ||argument7);
    fa_rx_util_pkg.debug('get_group_asset_info: ' || 'argument8:' ||argument8);
    fa_rx_util_pkg.debug('get_group_asset_info: ' || 'argument9:' ||argument9);
    fa_rx_util_pkg.debug('get_group_asset_info: ' || 'argument10:' ||argument10);
    fa_rx_util_pkg.debug('get_group_asset_info: ' || 'argument11:' ||argument11);
    fa_rx_util_pkg.debug('get_group_asset_info: ' || 'argument12:' ||argument12);
    fa_rx_util_pkg.debug('get_group_asset_info: ' || 'argument13:' ||argument13);
    fa_rx_util_pkg.debug('get_group_asset_info: ' || 'argument14:' ||argument14);
    fa_rx_util_pkg.debug('get_group_asset_info: ' || 'argument15:' ||argument15);
    fa_rx_util_pkg.debug('get_group_asset_info: ' || 'argument16:' ||argument16);
    fa_rx_util_pkg.debug('get_group_asset_info: ' || 'argument17:' ||argument17);
    -- End MRC
  END IF;


  l_request_id := fnd_global.conc_request_id;
  fnd_profile.get('USER_ID',l_user_id);

  fa_rx_group.get_group_asset_info (
    p_book_type_code        => argument1,
    -- MRC
    p_sob_id                => argument2,    -- MRC: Set of books id
    p_start_fiscal_year     => argument3,
    p_end_fiscal_year       => argument4,
    p_major_category_low    => argument6,
    p_major_category_high   => argument7,
    p_minor_category_low    => argument9,
    p_minor_category_high   => argument10,
    p_category_segment_name => argument11,
    p_category_segment_low  => argument12,
    p_category_segment_high => argument13,
    p_asset_number_low      => argument14,
    p_asset_number_high     => argument15,
    p_drill_down            => argument16,
    -- End MRC
    p_request_id            => l_request_id,
    p_user_id               => l_user_id,
    x_retcode               => x_retcode,
    x_errbuf                => x_errbuf);

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    fnd_message.set_name('OFA', 'FA_SHARED_SERVER_ERROR');
    l_err_msg := fnd_message.get;
    fa_rx_conc_mesg_pkg.log(l_err_msg);
    x_retcode := 2;

END get_group_asset_info;

END FA_RXC_GROUP;

/
