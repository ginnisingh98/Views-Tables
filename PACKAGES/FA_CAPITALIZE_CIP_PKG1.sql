--------------------------------------------------------
--  DDL for Package FA_CAPITALIZE_CIP_PKG1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_CAPITALIZE_CIP_PKG1" AUTHID CURRENT_USER as
/* $Header: faxccas1.pls 120.4.12010000.2 2009/07/19 10:43:35 glchen ship $ */

  PROCEDURE CALC_SUBCOMP_LIFE(
	    X_book	      VARCHAR2,
	    X_cat_id          NUMBER,
	    X_parent_asset_id NUMBER,
	    X_dpis	      DATE,
	    h_deprn_method    VARCHAR2,
	    h_prorate_date    DATE,
	    X_user_id         NUMBER,
  	    X_curr_date	      DATE,
	    h_life            IN OUT NOCOPY NUMBER,
	    X_Calling_Fn	VARCHAR2,
	    p_log_level_rec   IN     FA_API_TYPES.log_level_rec_type);

  PROCEDURE CHECK_LIFE(
            X_book 	      VARCHAR2,
	    X_cat_id	      NUMBER,
	    X_dpis	      DATE,
	    h_deprn_method    VARCHAR2,
	    h_rate_source_rule VARCHAR2,
            h_life_in_months   NUMBER,
	    h_lim              NUMBER,
            X_user_id          NUMBER,
            X_curr_date	       DATE,
            h_new_life         IN OUT NOCOPY NUMBER,
	    X_Calling_Fn		VARCHAR2,
	    p_log_level_rec    IN     FA_API_TYPES.log_level_rec_type);

END FA_CAPITALIZE_CIP_PKG1;

/
