--------------------------------------------------------
--  DDL for Package PO_SETUP_S3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_SETUP_S3" AUTHID CURRENT_USER as
/* $Header: POXSES4S.pls 115.2 2002/11/25 22:38:57 sbull ship $*/

/*===========================================================================
  PACKAGE NAME:		PO_SETUP_S3

  DESCRIPTION:

  CLIENT/SERVER:	Server

  LIBRARY NAME

  OWNER:

  PROCEDURE NAMES:	get_combined_parameter_values

===========================================================================*/
/*===========================================================================
  PROCEDURE NAME:	get_combined_parameter_values()

  DESCRIPTION:		This procedure combines several server procedural calls
                        for getting the PO parameter block varaibles value.
                        The purpose is to enhance the PO startup performance by
                        reducing the number of server procedural calls.


  PARAMETERS:

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:      	WLAU	7/3/1996	Created
===========================================================================*/

 PROCEDURE get_combined_parameter_values
			       (X_emp_id		OUT NOCOPY number,
                              	X_emp_name	        OUT NOCOPY varchar2,
                                X_location_id		OUT NOCOPY number,
                                X_location_code 	OUT NOCOPY varchar2,
                                X_is_buyer 		OUT NOCOPY BOOLEAN,
                                X_emp_flag    		OUT NOCOPY BOOLEAN,
 			  	X_fnd_user              OUT NOCOPY BOOLEAN,
				X_multi_org	     IN OUT NOCOPY BOOLEAN,
    				X_org_sob_id	     IN OUT NOCOPY NUMBER,
	 			X_org_sob_name       IN OUT NOCOPY VARCHAR2,
                                X_price_lookup_code  IN	OUT NOCOPY VARCHAR2,
                                X_price_type         IN OUT NOCOPY VARCHAR2,
                                X_multiple_disp	     IN	OUT NOCOPY VARCHAR2,
			        X_source_inventory   IN OUT NOCOPY VARCHAR2,
                                X_source_vendor      IN OUT NOCOPY VARCHAR2);


END PO_SETUP_S3;

 

/
