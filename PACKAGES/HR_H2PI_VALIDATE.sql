--------------------------------------------------------
--  DDL for Package HR_H2PI_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_H2PI_VALIDATE" AUTHID CURRENT_USER AS
/* $Header: hrh2pivd.pkh 115.3 2002/03/07 15:37:19 pkm ship     $ */

PROCEDURE validate_bg_and_gre(p_from_client_id VARCHAR2);
PROCEDURE validate_pay_basis(p_from_client_id VARCHAR2);
PROCEDURE validate_payroll(p_from_client_id VARCHAR2);
PROCEDURE validate_element_type(p_from_client_id VARCHAR2);
PROCEDURE validate_org_payment_method(p_from_client_id VARCHAR2);
PROCEDURE validate_element_link(p_from_client_id VARCHAR2);
PROCEDURE validate_geocode(p_from_client_id VARCHAR2);

END hr_h2pi_validate;

 

/
