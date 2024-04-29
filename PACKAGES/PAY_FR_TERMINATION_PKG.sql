--------------------------------------------------------
--  DDL for Package PAY_FR_TERMINATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_FR_TERMINATION_PKG" AUTHID CURRENT_USER as
/* $Header: pyfrterm.pkh 115.1 2003/01/15 19:23:52 jheer noship $ */
Function get_termination_service_det (p_business_group_id in number,
                                          p_assignment_id in number,
                                          p_termination_date in date,
                                          p_pre_service_ratio  out NOCOPY number,
                                          p_post_service_ratio out NOCOPY number)
Return number;
end PAY_FR_TERMINATION_PKG;

 

/
