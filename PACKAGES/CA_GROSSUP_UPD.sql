--------------------------------------------------------
--  DDL for Package CA_GROSSUP_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CA_GROSSUP_UPD" AUTHID CURRENT_USER as
/* $Header: pycantgu.pkh 115.0 2001/03/23 14:48:16 pkm ship        $ */


PROCEDURE setup_grossup_bal(p_baltype_id number,
                            p_baldim_id number);

PROCEDURE delete_late_bal(p_start_latest_bal_id number,
                          p_end_latest_bal_id   number,
                          p_dim_id           number);

END ca_grossup_upd;

 

/
