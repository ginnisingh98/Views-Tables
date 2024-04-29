--------------------------------------------------------
--  DDL for Package PAY_US_DEDN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_DEDN_PKG" AUTHID CURRENT_USER AS
/* $Header: pyusdedn.pkh 115.0 99/08/31 16:32:42 porting ship    $ */

FUNCTION pay_us_tot_owed (
    p_assignment_id         IN    NUMBER   DEFAULT NULL
   ,p_element_type_id       IN    NUMBER   DEFAULT NULL
   ,p_effective_date        IN    DATE     DEFAULT NULL
   ,p_date_earned           IN    DATE     DEFAULT NULL)

RETURN number;
--
PRAGMA RESTRICT_REFERENCES(pay_us_tot_owed, WNDS);
end pay_us_dedn_pkg;

 

/
