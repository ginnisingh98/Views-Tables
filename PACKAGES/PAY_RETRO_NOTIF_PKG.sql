--------------------------------------------------------
--  DDL for Package PAY_RETRO_NOTIF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_RETRO_NOTIF_PKG" AUTHID CURRENT_USER as
/* $Header: payretno.pkh 120.1.12010000.1 2008/07/27 21:52:52 appldev ship $ */
--

procedure run_asg_adv_retronot(
                    p_assignment_id      in number,
                    p_business_group_id  in number,
                    p_time_started       in date   default sysdate,
                    p_event_group        in number default null);

procedure run_debug(p_event_group in number,
                    p_start_date  in date,
                    p_end_date    in date,
                    p_bg_id       in number,
                    p_assignment_id in number,
                    p_rownum      in number,
                    p_adv_flag    in varchar2);
-------------------------------------------------------------------------------
Procedure get_asg_info(
        p_assignment_id     IN            NUMBER
,       p_report_date       IN            DATE
,       p_business_group_id IN            NUMBER
,       p_legislation_code  IN            VARCHAR2
,       p_asg_status           OUT NOCOPY VARCHAR2
,       p_person_name          OUT NOCOPY VARCHAR2);
-------------------------------------------------------------------------------
Procedure get_ele_info(
        p_element_entry_id  IN            NUMBER
,       p_report_date       IN            DATE
,       p_business_group_id IN            NUMBER
,       p_legislation_code  IN            VARCHAR2
,       p_element_name         OUT NOCOPY VARCHAR2);
-------------------------------------------------------------------------------
procedure range_cursor ( pactid in         number,
                         sqlstr out nocopy varchar2
                       );
procedure action_creation ( pactid in number,
                            stperson in number,
                            endperson in number,
                            chunk in number
                          );
procedure archinit(p_payroll_action_id in number);
procedure process_action(p_assactid in number,
                         p_effective_date in date
                        );
procedure deinitialise (pactid in number);
-------------------------------------------------------------------------------
Function get_person_name(
        p_assignment_id     IN            NUMBER
,       p_report_date       IN            DATE
,       p_business_group_id IN            NUMBER
,       p_legislation_code  IN            VARCHAR2)
Return varchar2;
-------------------------------------------------------------------------------
Function get_asg_status(
        p_assignment_id     IN            NUMBER
,       p_report_date       IN            DATE
,       p_business_group_id IN            NUMBER
,       p_legislation_code  IN            VARCHAR2)
Return varchar2;
-------------------------------------------------------------------------------
End PAY_RETRO_NOTIF_PKG;

/
