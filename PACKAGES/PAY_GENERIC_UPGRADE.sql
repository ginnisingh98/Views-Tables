--------------------------------------------------------
--  DDL for Package PAY_GENERIC_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_GENERIC_UPGRADE" AUTHID CURRENT_USER AS
/* $Header: pycogus.pkh 120.0.12010000.1 2008/07/27 22:22:24 appldev ship $ */

procedure set_upgrade_status (p_upg_def_id in number,
                              p_upg_lvl    in varchar2,
                              p_bus_grp    in number,
                              p_leg_code   in varchar2,
                              p_status     in varchar2);
procedure new_business_group (p_bus_grp_id in number,
                              p_leg_code in varchar2);
-- Continuous Calculation Process procedures.
-- seeded in pay_report_format_mappings and called by pyugen.
--
procedure action_creation(p_pactid in number,
                          p_stperson in number,
                          p_endperson in number,
                          p_chunk in number);

procedure archinit(p_payroll_action_id in number);
procedure upgrade_data(p_assactid in number, p_effective_date in date);
procedure range_cursor (pactid in number, sqlstr out nocopy varchar2);
procedure deinitialise (pactid in number);

END pay_generic_upgrade;

/
