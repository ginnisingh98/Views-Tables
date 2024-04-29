--------------------------------------------------------
--  DDL for Package FA_CHK_BALSEG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_CHK_BALSEG_PKG" AUTHID CURRENT_USER as
/* $Header: faxbases.pls 120.2.12010000.2 2009/07/19 10:42:39 glchen ship $ */

procedure check_balancing_segments(
	book		in varchar2,
	asset_id	in number,
 	success  out nocopy boolean,
	calling_fn	in varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

END FA_CHK_BALSEG_PKG;

/
