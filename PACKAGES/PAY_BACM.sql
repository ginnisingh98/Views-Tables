--------------------------------------------------------
--  DDL for Package PAY_BACM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BACM" AUTHID CURRENT_USER AS
/*   $Header: pybacsmd.pkh 115.0 99/07/17 05:43:46 porting ship $     */
/* * ***************************************************************************  Copyright (c) Oracle Corporation (UK) Ltd 1993.  All Rights Reserved.
  PRODUCT
    Oracle*Payroll
  NAME  DESCRIPTION
  Magnetic tape multi-processing day procedure.
*/
FUNCTION is_date_valid( ass_act_id in number,
                          ov_rid_date IN DATE,
                          per_pro_date IN DATE)
                RETURN VARCHAR;
--
      pragma restrict_references (is_date_valid, WNDS, WNPS);
end pay_bacm;

 

/
