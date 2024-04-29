--------------------------------------------------------
--  DDL for Package PER_ONEBOX_VACBAL_ACCRUAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ONEBOX_VACBAL_ACCRUAL" AUTHID CURRENT_USER as
/* $Header: peonebvb.pkh 120.0 2006/06/02 17:59:47 jarthurt noship $ */
function net_balance(p_person_id in number,
                     p_date      in date) return number;
function time_off_taken(p_person_id in number,
                        p_date      in date) return number;
end per_onebox_vacbal_accrual;

 

/
