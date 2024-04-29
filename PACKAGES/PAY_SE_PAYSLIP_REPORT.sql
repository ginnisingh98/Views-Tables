--------------------------------------------------------
--  DDL for Package PAY_SE_PAYSLIP_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_SE_PAYSLIP_REPORT" AUTHID CURRENT_USER AS
/* $Header: pysepsrp.pkh 120.0.12010000.1 2008/07/27 23:38:01 appldev ship $ */
--
    level_cnt	NUMBER;
    --
    FUNCTION get_parameter ( p_parameter_string IN VARCHAR2
                            ,p_token            IN VARCHAR2
                            ,p_segment_number   IN NUMBER DEFAULT NULL ) RETURN VARCHAR2;
    --
    PROCEDURE get_all_parameters(p_payroll_action_id                 IN          NUMBER
                                ,p_payroll_id                        OUT  NOCOPY NUMBER
                                ,p_consolidation_set_id              OUT  NOCOPY NUMBER
                                ,p_start_date                        OUT  NOCOPY VARCHAR2
                                ,p_end_date                          OUT  NOCOPY VARCHAR2
                                ,p_rep_group                         OUT  NOCOPY VARCHAR2
                                ,p_rep_category                      OUT  NOCOPY VARCHAR2
                                ,p_assignment_set_id                 OUT  NOCOPY NUMBER
                                ,p_assignment_id                     OUT  NOCOPY NUMBER
                                ,p_effective_date                    OUT  NOCOPY DATE
                                ,p_business_group_id                 OUT  NOCOPY NUMBER
                                ,p_legislation_code                  OUT  NOCOPY VARCHAR2 ) ;
    --
    CURSOR  csr_header IS
    Select 'DUMMY=P',dummy
    FROM    DUAL;
    --
    CURSOR  csr_asg IS
    SELECT 'TRANSFER_ACT_ID=P',ptoa.object_Action_id
    FROM    pay_temp_object_actions ptoa
    WHERE 	ptoa.payroll_action_id = to_number(pay_magtape_generic.get_parameter_value
                                                ('TRANSFER_PAYROLL_ACTION_ID'));
    --
    CURSOR csr_curr_act IS
    SELECT 'TRANSFER_ACT_ID=P',
           pay_magtape_generic.get_parameter_value('TRANSFER_ACT_ID')
    FROM DUAL;
    --
    PROCEDURE xml_header;
    --
    PROCEDURE xml_footer;
    --
    PROCEDURE xml_asg;
    --
    PROCEDURE qualifying_proc(p_assignment_id    IN         NUMBER
                             ,p_qualifier        OUT NOCOPY VARCHAR2 );
    --
--
END pay_se_payslip_report;

/
