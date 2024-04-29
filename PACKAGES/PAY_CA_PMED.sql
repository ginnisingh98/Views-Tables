--------------------------------------------------------
--  DDL for Package PAY_CA_PMED
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CA_PMED" AUTHID CURRENT_USER AS
/* $Header: pycapmcl.pkh 115.1 2003/03/20 00:32:54 ssattini noship $ */

FUNCTION get_source_id ( p_jurisdiction_code     VARCHAR2,
                         p_tax_unit_id           NUMBER,
                         p_business_group_id     NUMBER,
                         p_different_jd          VARCHAR2,
                         p_account_number IN OUT nocopy VARCHAR2)
  RETURN NUMBER;

END pay_ca_pmed;

 

/
