--------------------------------------------------------
--  DDL for Package PAY_NZ_EMS_TAX_RATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NZ_EMS_TAX_RATE" AUTHID CURRENT_USER as
/*  $Header: pynzemsrt.pkh 120.0.12010000.2 2008/11/10 07:25:17 dduvvuri noship $
**
**  Copyright (c) 1999 Oracle Corporation
**  All Rights Reserved
**
**  The package has a function which checks if the value of Tax Rate input
**  being used is NULL or not.
**
**  Change List
**  ===========
**
**  Date        Author   Reference Description
**  -----------+--------+---------+-------------
**  07-NOV-2009 dduvvuri  7480679   Created the package
**  10-NOV-2009 dduvvuri  7480679   Function inputs and definition changed
*/

 FUNCTION get_tax_rate (p_given_date in DATE
                       , p_run_result_id in NUMBER
                       )
 RETURN VARCHAR2;

end pay_nz_ems_tax_rate ;

/
