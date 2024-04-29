--------------------------------------------------------
--  DDL for Package FA_DEPRN_TAX_C_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_DEPRN_TAX_C_PKG" AUTHID CURRENT_USER AS
/* $Header: facdptxs.pls 120.3.12010000.3 2009/07/19 11:05:45 glchen ship $ */
PROCEDURE fadptx_insert (
  errbuf	 out nocopy varchar2,
  retcode	 out nocopy number,
  argument1		in  varchar2,   -- book
  argument2		in  varchar2,   -- year
  argument3		in  varchar2,	-- locstruct_num
  argument4		in  varchar2,	-- start_state
  argument5		in  varchar2,	-- end_state
  argument6		in  varchar2,	-- cat_struct_num
  argument7		in  varchar2  default 'MINOR_CATEGORY',	-- tax_asset_type_seg
  argument8		in  varchar2, 	-- minor_cat_exist
  argument9		in  varchar2  default  null, 	-- start_category
  argument10		in  varchar2  default  null, 	-- end_dategory
  argument11		in  varchar2  default  null, 	-- sale_code
  argument12		in  varchar2  default  null, 	-- sum_rep
  argument13		in  varchar2  default  null, 	-- all_rep
  argument14		in  varchar2  default  null, 	-- add_rep
  argument15		in  varchar2  default  null,    -- dec_rep
  argument16		in  varchar2  default  null,    -- debug
  argument17		in  varchar2  default  null,    -- round --bug4919991
  argument18		in  varchar2  default  null,
  argument19		in  varchar2  default  null,
  argument20		in  varchar2  default  null,
  argument21		in  varchar2  default  null,
  argument22		in  varchar2  default  null,
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
  argument100           in  varchar2  default  null);
END FA_DEPRN_TAX_C_PKG;

/
