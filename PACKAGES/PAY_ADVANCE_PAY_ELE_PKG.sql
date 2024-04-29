--------------------------------------------------------
--  DDL for Package PAY_ADVANCE_PAY_ELE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ADVANCE_PAY_ELE_PKG" AUTHID CURRENT_USER as
/* $Header: pyadvele.pkh 115.1 2003/11/13 17:07 susivasu noship $ */
--
g_adv_pay_process varchar2(1) := null;
--
--
function get_subpriority(p_leg_code      in varchar2,
                         p_creator_type  in varchar2,
                         p_subpriority   in number)
        return pay_element_entries_f.subpriority%TYPE;
--
End PAY_ADVANCE_PAY_ELE_PKG;

 

/
