--------------------------------------------------------
--  DDL for Package PAY_ASG_PROCESS_GRP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ASG_PROCESS_GRP_PKG" AUTHID CURRENT_USER as
/* $Header: pycorapg.pkh 120.1 2006/01/10 07:19:16 nbristow noship $ */
--
procedure asg_insert_trigger(p_assignment_id            in number,
                             p_person_id                in number,
                             p_period_of_service_id     in number,
                             p_new_effective_start_date in date,
                             p_new_effective_end_date   in date,
                             p_new_payroll_id           in number,
                             p_business_group_id        in number
                            );
procedure asg_update_trigger(p_assignment_id            in number,
                             p_person_id                in number,
                             p_period_of_service_id     in number,
                             p_old_effective_start_date in date,
                             p_old_effective_end_date   in date,
                             p_new_effective_start_date in date,
                             p_new_effective_end_date   in date,
                             p_old_payroll_id           in number,
                             p_new_payroll_id           in number,
                             p_business_group_id        in number
                            );
procedure asg_delete_trigger(p_assignment_id        in number,
                             p_effective_end_date   in date,
                             p_business_group_id    in number,
                             p_effective_end_date_o in date
                            );
procedure upgrade_asg(p_asg_id in number);
--
end pay_asg_process_grp_pkg;

 

/
