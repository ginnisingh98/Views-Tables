--------------------------------------------------------
--  DDL for Package PAY_SA_HIST_ARCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_SA_HIST_ARCH_PKG" AUTHID CURRENT_USER AS
/* $Header: pysapupg.pkh 120.0.12010000.2 2009/05/31 10:04:06 krreddy noship $ */

procedure range_cursor(pactid in number,
                       sqlstr out nocopy varchar2);
procedure action_creation(pactid in number,
                          stperson in number,
                          endperson in number,
                          chunk in number);
procedure archinit(p_payroll_action_id in number);
PROCEDURE archive_historic_data(p_assactid in number,
                                p_effective_date in date);

END pay_sa_hist_arch_pkg ;

/
