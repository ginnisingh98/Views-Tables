--------------------------------------------------------
--  DDL for Package FA_STANDARD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_STANDARD_PKG" AUTHID CURRENT_USER as
/* $Header: faxsrvrs.pls 120.1.12010000.2 2009/07/19 13:04:43 glchen ship $ */

 procedure raise_error(	called_fn in varchar2,
			calling_fn in varchar2,
			name in varchar2 default null,
			token1 in varchar2 default null,
			value1 in varchar2 default null,
			token2 in varchar2 default null,
			value2 in varchar2 default null,
			token3 in varchar2 default null,
			value3 in varchar2 default null,
			translate in boolean default FALSE, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null);

END FA_STANDARD_PKG;

/
