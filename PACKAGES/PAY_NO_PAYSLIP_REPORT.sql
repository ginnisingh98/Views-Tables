--------------------------------------------------------
--  DDL for Package PAY_NO_PAYSLIP_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NO_PAYSLIP_REPORT" AUTHID CURRENT_USER AS
/* $Header: pynopsrp.pkh 120.0 2007/11/20 05:48:34 namgoyal noship $ */
--
    level_cnt	NUMBER;
    --
    FUNCTION get_parameter ( p_parameter_string IN VARCHAR2
                            ,p_token            IN VARCHAR2
                            ,p_segment_number   IN NUMBER DEFAULT NULL ) RETURN VARCHAR2;

    --
    FUNCTION get_sort_order( p_type              IN VARCHAR2
                            ,p_legislation_code  IN VARCHAR2   ) RETURN VARCHAR2 ;
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
    FROM  pay_temp_object_actions      ptoa
        ,per_all_assignments_f         paaf
        ,per_all_people_f              papf
        ,pay_payroll_actions           ppa
        ,hr_soft_coding_keyflex        hsck
        ,per_business_groups           pbg
        ,per_assignment_status_types   past
        ,per_person_types              ppt
    WHERE ptoa.object_id                = paaf.assignment_id
    AND paaf.person_id                  = papf.person_id
    AND ptoa.payroll_action_id          = TO_NUMBER(pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID'))
    AND ptoa.payroll_action_id          = ppa.payroll_action_id
    AND paaf.effective_start_date       <= TO_DATE(pay_payslip_report.get_parameter(ppa.legislative_parameters,'END_DATE'),'YYYY/MM/DD')
    AND paaf.effective_end_date         >= TO_DATE(pay_payslip_report.get_parameter(ppa.legislative_parameters,'START_DATE'),'YYYY/MM/DD')
    AND papf.effective_start_date       <= TO_DATE(pay_payslip_report.get_parameter(ppa.legislative_parameters,'END_DATE'),'YYYY/MM/DD')
    AND papf.effective_end_date         >= TO_DATE(pay_payslip_report.get_parameter(ppa.legislative_parameters,'START_DATE'),'YYYY/MM/DD')
    AND papf.business_group_id          = pbg.business_group_id
    AND pbg.legislation_code            = NVL(past.legislation_code,pbg.legislation_code)
    AND past.per_system_status          = 'ACTIVE_ASSIGN'
    AND past.active_flag                = 'Y'
    AND past.assignment_status_type_id  = paaf.assignment_status_type_id
    AND	ppt.person_type_id              = papf.person_type_id
    AND ppt.business_group_id	        = pbg.business_group_id
    AND ppt.active_flag                 = 'Y'
    AND ppt.system_person_type	        = 'EMP'
    AND paaf.soft_coding_keyflex_id     = hsck.soft_coding_keyflex_id
    ORDER BY DECODE(pay_payslip_report.get_sort_order('LE',pbg.legislation_code)
                                                          ,'SEGMENT1',hsck.segment1
                                                          ,'SEGMENT2',hsck.segment2
                                                          ,'SEGMENT3',hsck.segment3
                                                          ,'SEGMENT4',hsck.segment4
                                                          ,'SEGMENT5',hsck.segment5
                                                          ,'SEGMENT6',hsck.segment6
                                                          ,'SEGMENT7',hsck.segment7
                                                          ,'SEGMENT8',hsck.segment8
                                                          ,'SEGMENT9',hsck.segment9
                                                          ,'SEGMENT10',hsck.segment10
                                                          ,'SEGMENT11',hsck.segment11
                                                          ,'SEGMENT12',hsck.segment12
                                                          ,'SEGMENT13',hsck.segment13
                                                          ,'SEGMENT14',hsck.segment14
                                                          ,'SEGMENT15',hsck.segment15
                                                          ,'SEGMENT16',hsck.segment16
                                                          ,'SEGMENT17',hsck.segment17
                                                          ,'SEGMENT18',hsck.segment18
                                                          ,'SEGMENT19',hsck.segment19
                                                          ,'SEGMENT20',hsck.segment20
                                                          ,'SEGMENT21',hsck.segment21
                                                          ,'SEGMENT22',hsck.segment22
                                                          ,'SEGMENT23',hsck.segment23
                                                          ,'SEGMENT24',hsck.segment24
                                                          ,'SEGMENT25',hsck.segment25
                                                          ,'SEGMENT26',hsck.segment26
                                                          ,'SEGMENT27',hsck.segment27
                                                          ,'SEGMENT28',hsck.segment28
                                                          ,'SEGMENT29',hsck.segment29
                                                          ,'SEGMENT30',hsck.segment30)
           ,DECODE(pay_payslip_report.get_sort_order('ORG',pbg.legislation_code)
                                                          ,'ORGANIZATION_ID',paaf.organization_id
                                                          ,'ASSIGNMENT_NUMBER',paaf.assignment_number)
           ,DECODE(pay_payslip_report.get_sort_order('NAME',pbg.legislation_code)
                                                           ,'LAST_NAME',papf.last_name
                                                           ,'FIRST_NAME',papf.first_name
                                                           ,'FULL_NAME',papf.full_name
                                                           ,papf.last_name)
           ,paaf.assignment_number ;
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
END pay_no_payslip_report;

/
