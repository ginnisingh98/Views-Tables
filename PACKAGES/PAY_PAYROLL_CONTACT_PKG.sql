--------------------------------------------------------
--  DDL for Package PAY_PAYROLL_CONTACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PAYROLL_CONTACT_PKG" AUTHID CURRENT_USER AS
/* $Header: pycoprco.pkh 120.0 2005/05/29 04:08:52 appldev noship $ */

procedure action_creation(p_pactid in number,
                          p_stperson in number,
                          p_endperson in number,
                          p_chunk in number);

procedure archinit(p_payroll_action_id in number);
procedure process_data(p_assactid in number, p_effective_date in date);
procedure range_cursor (pactid in number, sqlstr out nocopy varchar2);
procedure deinitialise (pactid in number);

END pay_payroll_contact_pkg;

 

/
