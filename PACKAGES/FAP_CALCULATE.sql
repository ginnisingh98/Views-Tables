--------------------------------------------------------
--  DDL for Package FAP_CALCULATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FAP_CALCULATE" AUTHID CURRENT_USER as
/* $Header: fapkcas.pls 120.2.12010000.2 2009/07/19 10:57:55 glchen ship $ */

  procedure CALC_RECOVERABLE_COST
       (cost			in  number,
        salvage_value		in  number,
        itc_basis		in  number,
        itc_amount_id		in  number,
        ceiling_name		in  varchar2,
	date_placed_in_service	in  date,
        recoverable_cost out nocopy number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

END FAP_CALCULATE;

/
