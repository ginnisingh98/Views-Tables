--------------------------------------------------------
--  DDL for Package FA_MASSADD_DIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_MASSADD_DIST_PKG" AUTHID CURRENT_USER as
/* $Header: faxmadts.pls 120.2.12010000.2 2009/07/19 10:03:29 glchen ship $ */

PROCEDURE DIST_SET (X_name         varchar2,
		    X_total_units  number,
		    X_mass_addition_id  number,
		    X_success  out nocopy boolean, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

PROCEDURE SAVEPT;

PROCEDURE ROLLBK;


END FA_MASSADD_DIST_PKG;

/
