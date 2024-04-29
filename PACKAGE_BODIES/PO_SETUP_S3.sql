--------------------------------------------------------
--  DDL for Package Body PO_SETUP_S3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_SETUP_S3" as
/* $Header: POXSES4B.pls 115.1 2002/11/26 19:50:49 sbull ship $*/

/*==========================================================================
  PROCEDURE NAME:	get_combined_parameter_values()

===========================================================================*/

  PROCEDURE  get_combined_parameter_values
			       (X_emp_id		OUT NOCOPY number,
                              	X_emp_name	        OUT NOCOPY varchar2,
                                X_location_id		OUT NOCOPY number,
                                X_location_code 	OUT NOCOPY varchar2,
                                X_is_buyer 		OUT NOCOPY BOOLEAN,
                                X_emp_flag    		OUT NOCOPY BOOLEAN,
                                X_fnd_user              OUT NOCOPY BOOLEAN,
 				X_multi_org	     IN	OUT NOCOPY BOOLEAN,
    				X_org_sob_id	     IN OUT NOCOPY NUMBER,
	 			X_org_sob_name       IN	OUT NOCOPY VARCHAR2,
                                X_price_lookup_code  IN	OUT NOCOPY VARCHAR2,
                                X_price_type         IN OUT NOCOPY VARCHAR2,
                                X_multiple_disp      IN	OUT NOCOPY VARCHAR2,
			        X_source_inventory   IN OUT NOCOPY VARCHAR2,
                                X_source_vendor      IN OUT NOCOPY VARCHAR2) IS

 x_progress     		VARCHAR2(3) := NULL;

 BEGIN

    x_progress := '05';
    X_fnd_user :=  PO_EMPLOYEES_SV.GET_EMPLOYEE(X_emp_id,
                                     		X_emp_name,
                                     		X_location_id,
                                     		X_location_code,
                                     		X_is_buyer,
                                     		X_emp_flag);


    x_progress := '10';
    -- Get org code to store in parameter.org_code for window title
     po_core_s3.get_window_org_sob (x_multi_org,
				    x_org_sob_id,
				    x_org_sob_name);

    x_progress := '15';
    -- Get the display value for lookup code of 'PRICE TYPE'
    IF X_price_lookup_code is not null THEN
       po_headers_sv4.get_lookup_code_dsp ('PRICE TYPE',
                                           X_price_lookup_code,
                                           X_price_type);

    ELSE
       X_price_type := NULL;
    END IF ;

    x_progress := '20';
    -- Get the display value for lookup code of 'MULTIPLE'.
    -- It is to be used in the line promised_date, need_by date and
    -- gl_account fields.
    --
     po_headers_sv4.get_lookup_code_dsp ('TRANSLATE',
                                         'MULTIPLE',
                                         X_multiple_disp);

    x_progress := '25';
    po_reqs_sv.get_req_startup_values (x_source_inventory,
	     		               x_source_vendor);

  EXCEPTION
  WHEN OTHERS THEN
  dbms_output.put_line('After Prog ' || X_progress );
  po_message_s.sql_error('po_setup_s.get_combined_parameter_values', x_progress, sqlcode);
  raise;

 END get_combined_parameter_values;


END PO_SETUP_S3;

/
