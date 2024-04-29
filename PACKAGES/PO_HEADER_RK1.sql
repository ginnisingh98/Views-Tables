--------------------------------------------------------
--  DDL for Package PO_HEADER_RK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_HEADER_RK1" AUTHID CURRENT_USER as
/* $Header: POWRBLS.pls 115.2 2002/11/25 19:44:20 sbull noship $*/


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
                                X_source_vendor      IN OUT NOCOPY varchar2);


END PO_HEADER_RK1;

 

/
