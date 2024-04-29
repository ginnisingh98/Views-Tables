--------------------------------------------------------
--  DDL for Package PAY_US_GROSSUP_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_GROSSUP_UPD" AUTHID CURRENT_USER as
/* $Header: pyusntgu.pkh 115.1 2003/01/09 18:40:05 meshah noship $ */


PROCEDURE setup_grossup_bal(p_baltype_id number,
                            p_baldim_id number);

PROCEDURE delete_late_bal(p_start_latest_bal_id number,
                          p_end_latest_bal_id   number,
                          p_dim_id           number);

END pay_us_grossup_upd;

 

/
