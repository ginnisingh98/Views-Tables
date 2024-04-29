--------------------------------------------------------
--  DDL for Package PAY_CONTACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CONTACT_PKG" AUTHID CURRENT_USER AS
/* $Header: pypaycon.pkh 120.0 2005/05/29 07:16:11 appldev noship $ */
FUNCTION populate_pay_contact_details(p_assignment_id     in number
                                         ,p_business_group_id in number
                                         ,p_effective_date    in date
                                         ,p_contact_name      in varchar2
                                         ,p_phone             in varchar2
                                         ,p_email             in varchar2
                                         )
RETURN number;
--
END pay_contact_pkg;

 

/
