--------------------------------------------------------
--  DDL for Package PAY_CA_DEDN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CA_DEDN_PKG" AUTHID CURRENT_USER AS
/* $Header: pycadedn.pkh 120.0 2005/05/29 03:30:10 appldev noship $ */

FUNCTION pay_ca_tot_owed (
    p_assignment_id         IN    NUMBER   DEFAULT NULL
   ,p_element_type_id       IN    NUMBER   DEFAULT NULL
   ,p_effective_date        IN    DATE     DEFAULT NULL
   ,p_date_earned           IN    DATE     DEFAULT NULL)

RETURN number;
--
PRAGMA RESTRICT_REFERENCES(pay_ca_tot_owed, WNDS);
end pay_ca_dedn_pkg;

 

/
