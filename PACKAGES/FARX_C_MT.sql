--------------------------------------------------------
--  DDL for Package FARX_C_MT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FARX_C_MT" AUTHID CURRENT_USER as
/* $Header: FARXCMTS.pls 120.1.12010000.2 2009/07/19 11:53:55 glchen ship $ */

PROCEDURE insert_to_itf (
                p_book              in    varchar2,
                p_event_name        in    varchar2,
                p_maint_date_from   in    date,
                p_maint_date_to     in    date,
                p_asset_number_from in    varchar2,
                p_asset_number_to   in    varchar2,
                p_dpis_from         in    date,
                p_dpis_to           in    date,
                p_cat_id       	    in    number,
                p_request_id        in    number,
                retcode             out nocopy   varchar2,
                errbuf              out nocopy   varchar2);


PROCEDURE asset_maintenance (
  errbuf	    out nocopy varchar2,
  retcode	    out nocopy varchar2,
  argument1	    in  varchar2,   -- book
  argument2	    in  varchar2 default  null,  -- event_name
  argument3	    in	varchar2 default  null,  -- maint_date_from
  argument4         in  varchar2 default  null,  -- maint_date_to
  argument5         in  varchar2 default  null,  -- asset_number_from
  argument6         in  varchar2 default  null,  -- asset_number_to
  argument7         in  varchar2 default  null,  -- dpis_from
  argument8         in  varchar2 default  null,  -- dpis_to
  argument9         in  varchar2 default  null,  -- category
  argument10        in  varchar2 default  null,
  argument11        in  varchar2 default  null,
  argument12        in  varchar2 default  null,
  argument13        in  varchar2 default  null,
  argument14        in  varchar2  default  null,
  argument15        in  varchar2  default  null,
  argument16        in  varchar2  default  null,
  argument17        in  varchar2  default  null,
  argument18        in  varchar2  default  null,
  argument19        in  varchar2  default  null,
  argument20        in  varchar2  default  null,
  argument21	    in  varchar2  default  null,
  argument22        in  varchar2  default  null,
  argument23        in  varchar2  default  null,
  argument24        in  varchar2  default  null,
  argument25        in  varchar2  default  null,
  argument26        in  varchar2  default  null,
  argument27        in  varchar2  default  null,
  argument28        in  varchar2  default  null,
  argument29        in  varchar2  default  null,
  argument30        in  varchar2  default  null,
  argument31	    in  varchar2  default  null,
  argument32        in  varchar2  default  null,
  argument33        in  varchar2  default  null,
  argument34        in  varchar2  default  null,
  argument35        in  varchar2  default  null,
  argument36        in  varchar2  default  null,
  argument37        in  varchar2  default  null,
  argument38        in  varchar2  default  null,
  argument39        in  varchar2  default  null,
  argument40        in  varchar2  default  null,
  argument41	    in  varchar2  default  null,
  argument42        in  varchar2  default  null,
  argument43        in  varchar2  default  null,
  argument44        in  varchar2  default  null,
  argument45        in  varchar2  default  null,
  argument46        in  varchar2  default  null,
  argument47        in  varchar2  default  null,
  argument48        in  varchar2  default  null,
  argument49        in  varchar2  default  null,
  argument50        in  varchar2  default  null,
  argument51	    in  varchar2  default  null,
  argument52        in  varchar2  default  null,
  argument53        in  varchar2  default  null,
  argument54        in  varchar2  default  null,
  argument55        in  varchar2  default  null,
  argument56        in  varchar2  default  null,
  argument57        in  varchar2  default  null,
  argument58        in  varchar2  default  null,
  argument59        in  varchar2  default  null,
  argument60        in  varchar2  default  null,
  argument61	    in  varchar2  default  null,
  argument62        in  varchar2  default  null,
  argument63        in  varchar2  default  null,
  argument64        in  varchar2  default  null,
  argument65        in  varchar2  default  null,
  argument66        in  varchar2  default  null,
  argument67        in  varchar2  default  null,
  argument68        in  varchar2  default  null,
  argument69        in  varchar2  default  null,
  argument70        in  varchar2  default  null,
  argument71	    in  varchar2  default  null,
  argument72        in  varchar2  default  null,
  argument73        in  varchar2  default  null,
  argument74        in  varchar2  default  null,
  argument75        in  varchar2  default  null,
  argument76        in  varchar2  default  null,
  argument77        in  varchar2  default  null,
  argument78        in  varchar2  default  null,
  argument79        in  varchar2  default  null,
  argument80        in  varchar2  default  null,
  argument81	    in  varchar2  default  null,
  argument82        in  varchar2  default  null,
  argument83        in  varchar2  default  null,
  argument84        in  varchar2  default  null,
  argument85        in  varchar2  default  null,
  argument86        in  varchar2  default  null,
  argument87        in  varchar2  default  null,
  argument88        in  varchar2  default  null,
  argument89        in  varchar2  default  null,
  argument90        in  varchar2  default  null,
  argument91	    in  varchar2  default  null,
  argument92        in  varchar2  default  null,
  argument93        in  varchar2  default  null,
  argument94        in  varchar2  default  null,
  argument95        in  varchar2  default  null,
  argument96        in  varchar2  default  null,
  argument97        in  varchar2  default  null,
  argument98        in  varchar2  default  null,
  argument99        in  varchar2  default  null,
  argument100       in  varchar2  default null);

  procedure do_insert(
                p_book              in    varchar2,
                p_event_name        in    varchar2,
                p_maint_date_from   in    date,
                p_maint_date_to     in    date,
                p_asset_number_from in    varchar2,
                p_asset_number_to   in    varchar2,
                p_dpis_from         in    date,
                p_dpis_to           in    date,
                p_category_id       in    varchar2,
                p_request_id        in    number,
		p_retcode	    out nocopy   number);

END FARX_C_MT;

/