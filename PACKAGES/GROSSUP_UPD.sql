--------------------------------------------------------
--  DDL for Package GROSSUP_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GROSSUP_UPD" AUTHID CURRENT_USER as
/* $Header: pyusntgu.pkh 115.0 2001/01/09 15:38:29 pkm ship    $ */


PROCEDURE setup_grossup_bal(p_baltype_id number,
                            p_baldim_id number);

PROCEDURE delete_late_bal(p_start_latest_bal_id number,
                          p_end_latest_bal_id   number,
                          p_dim_id           number);

END grossup_upd;

 

/
