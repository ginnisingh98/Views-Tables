--------------------------------------------------------
--  DDL for Package Body FAP_CALCULATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FAP_CALCULATE" as
/* $Header: fapkcab.pls 120.3.12010000.2 2009/07/19 10:57:27 glchen ship $ */

    procedure  CALC_RECOVERABLE_COST
       (cost			in  number,
        salvage_value		in  number,
        itc_basis		in  number,
        itc_amount_id		in  number,
        ceiling_name		in  varchar2,
	date_placed_in_service	in  date,
        recoverable_cost out nocopy number, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) is
	rc_no_ceiling	number;
    begin
	select	cost - salvage_value -
		(nvl(itc_basis, 0) * nvl( min(ir.basis_reduction_rate), 0))
	into 	rc_no_ceiling
	from	fa_itc_rates 		ir
	where	ir.itc_amount_id = calc_recoverable_cost.itc_amount_id;

	select	least (rc_no_ceiling, nvl (min (ce.limit), rc_no_ceiling))
	into 	recoverable_cost
	from	fa_ceilings 		ce,
		fa_ceiling_types	ct
	where	ce.ceiling_name =
		    decode (ct.ceiling_type,
                            'RECOVERABLE COST CEILING',
				calc_recoverable_cost.ceiling_name,
                            NULL) and
		date_placed_in_service between
		    nvl(ce.start_date, date_placed_in_service) and
		    nvl(ce.end_date, date_placed_in_service)
	and	ct.ceiling_name =  calc_recoverable_cost.ceiling_name;
    exception
	when NO_DATA_FOUND then
	    FND_MESSAGE.SET_NAME('OFA', 'FA_FE_CANT_GEN_RECOV_COST');
	    FND_MESSAGE.RAISE_ERROR;
    end;

END FAP_CALCULATE;

/
