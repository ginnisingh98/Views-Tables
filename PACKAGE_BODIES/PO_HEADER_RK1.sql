--------------------------------------------------------
--  DDL for Package Body PO_HEADER_RK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_HEADER_RK1" as
/* $Header: POWRBLB.pls 115.2 2002/11/25 19:44:33 sbull noship $*/



PROCEDURE  get_combined_params_values
                               (X_emp_id                OUT NOCOPY number,
                                X_emp_name              OUT NOCOPY varchar2,
                                X_location_id           OUT NOCOPY number,
                                X_location_code         OUT NOCOPY varchar2,
		 		X_is_buyer_int           OUT NOCOPY number,
 		      		X_emp_flag_int	 	OUT NOCOPY number,
       				X_fnd_user_int              OUT NOCOPY number,
                                X_multi_org_int         IN OUT NOCOPY number,
                                X_org_sob_id            IN OUT NOCOPY number,
                                X_org_sob_name       IN OUT NOCOPY varchar2,
                                X_price_lookup_code  IN OUT NOCOPY varchar2,
                                X_price_type         IN OUT NOCOPY varchar2,
                                X_multiple_disp      IN OUT NOCOPY varchar2,
                                X_source_inventory   IN OUT NOCOPY varchar2,
                                X_source_vendor      IN OUT NOCOPY varchar2)   IS

X_is_buyer         	BOOLEAN;
X_emp_flag 		BOOLEAN;
X_fnd_user 		BOOLEAN;
X_multi_org 		BOOLEAN;

begin

X_is_buyer := true;
X_emp_flag := true;
X_fnd_user := true;
X_multi_org := true;


PO_SETUP_S3.get_combined_parameter_values
                               (X_emp_id,
                                X_emp_name,
                                X_location_id,
                                X_location_code,
                                X_is_buyer,
                                X_emp_flag,
                                X_fnd_user,
                                X_multi_org,
                                X_org_sob_id,
                                X_org_sob_name,
                                X_price_lookup_code,
                                X_price_type,
                                X_multiple_disp,
                                X_source_inventory,
                                X_source_vendor);

 if (X_is_buyer) then
	X_is_buyer_int := 1;
 else
	X_is_buyer_int := 0;
end if;

if (X_emp_flag) then
	X_emp_flag_int := 1;
 else
	X_emp_flag_int := 0;
end if;

if (X_fnd_user) then
	X_fnd_user_int := 1;
 else
	X_fnd_user_int := 0;
end if;

if (X_multi_org) then
	X_multi_org_int := 1;
 else
	X_multi_org_int := 0;
end if;

 end get_combined_params_values;

END PO_HEADER_RK1;

/
