--------------------------------------------------------
--  DDL for Package FARX_C_DP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FARX_C_DP" AUTHID CURRENT_USER AS
/* $Header: farxcdps.pls 120.3.12010000.3 2009/10/30 11:19:02 pmadas ship $ */

PROCEDURE deprn_rep (
  errbuf         out nocopy varchar2,
  retcode        out nocopy varchar2,
  argument1             in  varchar2,   -- book
  argument2             in  varchar2,   -- MRC: Set of books id
  argument3             in  varchar2,   -- period_name
  argument4             in  varchar2  default  'N', -- report_style
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
  argument100           in  varchar2  default  null);

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
  argument22            in  varchar2  default  'N', -- report_style
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
  argument100           in  varchar2  default  null);
END FARX_C_DP;

/
