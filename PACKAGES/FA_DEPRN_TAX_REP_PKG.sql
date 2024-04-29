--------------------------------------------------------
--  DDL for Package FA_DEPRN_TAX_REP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_DEPRN_TAX_REP_PKG" AUTHID CURRENT_USER as
/* $Header: fadptxs.pls 120.4.12010000.3 2009/07/19 11:04:09 glchen ship $ */


procedure fadptx_insert (
 	errbuf	           out nocopy varchar2,
  	retcode	           out nocopy number,
	book		   in  varchar2,
	year		   in  number,
        state_from	   in  varchar2,
	state_to           in  varchar2,
	tax_asset_type_seg in  varchar2 default 'MINOR_CATEGORY',
	category_from	   in  varchar2,
	category_to	   in  varchar2,
	sale_code	   in  varchar2,
        all_state	   in  boolean,
        rounding           in  boolean, --bug4919991
	request_id	   in  number,
	login_id	   in  number
);

function debug (p_print varchar2, k number) return varchar2;

END FA_DEPRN_TAX_REP_PKG;

/
