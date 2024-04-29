--------------------------------------------------------
--  DDL for Package FA_ROUND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_ROUND_PKG" AUTHID CURRENT_USER as
/* $Header: faxrnds.pls 120.2.12010000.2 2009/07/19 13:10:28 glchen ship $ */

  PROCEDURE fa_round(X_amount   in out nocopy number,
		  X_book     varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null);

  PROCEDURE fa_ceil(X_amount    in out nocopy number,
		 X_book      varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null);

  PROCEDURE fa_floor(X_amount   in out nocopy number,
		  X_book     varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null);

end FA_ROUND_PKG;

/
