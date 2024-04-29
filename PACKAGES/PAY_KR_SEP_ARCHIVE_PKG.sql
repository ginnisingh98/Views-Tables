--------------------------------------------------------
--  DDL for Package PAY_KR_SEP_ARCHIVE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_KR_SEP_ARCHIVE_PKG" AUTHID CURRENT_USER as
/* $Header: pykrsepa.pkh 120.0.12010000.1 2008/07/27 23:04:32 appldev ship $ */
--------------------------------------------------------------------------------
procedure range_cursor(p_payroll_action_id in number,
                       p_sqlstr            out NOCOPY varchar2);
--------------------------------------------------------------------------------
procedure assignment_action_creation(p_payroll_action_id in number,
                                     p_start_person_id   in number,
                                     p_end_person_id     in number,
                                     p_chunk             in number);
--------------------------------------------------------------------------------
procedure archinit(p_payroll_action_id in number);
--------------------------------------------------------------------------------
procedure archive_data(p_assignment_action_id in number,
                       p_effective_date       in date);
--------------------------------------------------------------------------------
end pay_kr_sep_archive_pkg;

/
