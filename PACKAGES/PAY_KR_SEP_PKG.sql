--------------------------------------------------------
--  DDL for Package PAY_KR_SEP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_KR_SEP_PKG" AUTHID CURRENT_USER as
/* $Header: pykrsepp.pkh 115.4 2002/12/11 12:16:12 krapolu noship $ */
--------------------------------------------------------------------------------
function get_iyea_tax_adj(p_assignment_action_id in number,
                          p_business_group_id    in number,
                          p_itax_adj             out NOCOPY number,
                          p_rtax_adj             out NOCOPY number,
                          p_stax_adj             out NOCOPY number) return number;
--------------------------------------------------------------------------------
function get_ihia_prem_adj(p_assignment_action_id in number,
                           p_business_group_id    in number,
                           p_hi_prem_ee_adj       out NOCOPY number,
                           p_hi_prem_er_adj       out NOCOPY number) return number;
--------------------------------------------------------------------------------
end pay_kr_sep_pkg;

 

/
