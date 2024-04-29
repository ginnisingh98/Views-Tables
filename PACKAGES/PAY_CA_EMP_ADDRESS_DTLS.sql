--------------------------------------------------------
--  DDL for Package PAY_CA_EMP_ADDRESS_DTLS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CA_EMP_ADDRESS_DTLS" AUTHID CURRENT_USER as
/* $Header: paycaaddwrpr.pkh 120.1 2005/10/05 01:45 saurgupt noship $ */

/* Function to fetch the current address details for an employee */
function get_emp_address(p_person_id in number,
                         p_address1  out nocopy varchar2,
                         p_address2  out nocopy varchar2,
                         p_address3  out nocopy varchar2,
                         p_city     out nocopy varchar2,
                         p_postal_code out nocopy varchar2,
                         p_country out nocopy varchar2,
                         p_province out nocopy varchar2) RETURN NUMBER;
END pay_ca_emp_address_dtls ;

 

/
