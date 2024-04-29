--------------------------------------------------------
--  DDL for Package PAY_PL_POST_TERMINATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PL_POST_TERMINATION_PKG" AUTHID CURRENT_USER as
/* $Header: pyplterm.pkh 120.0 2006/03/01 22:19:22 mseshadr noship $ */

PROCEDURE Actual_Term_sii_tax_records(p_debug             boolean default false
                                      ,p_period_of_service_id    number
                                      ,p_actual_termination_date Date
                                      ,p_business_group_id       NUMBER
                                      );
End PAY_PL_POST_TERMINATION_PKG;

 

/
