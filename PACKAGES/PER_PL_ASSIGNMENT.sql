--------------------------------------------------------
--  DDL for Package PER_PL_ASSIGNMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PL_ASSIGNMENT" AUTHID CURRENT_USER as
/* $Header: peplasgp.pkh 120.2.12010000.1 2008/07/28 05:19:32 appldev ship $ */
PROCEDURE  create_pl_secondary_emp_asg
                    (  p_person_id                  number
                      ,p_payroll_id                 number
                      ,p_effective_date             date
                      ,p_scl_segment3               varchar2
                      ,p_scl_segment4               varchar2
                      ,p_scl_segment5               varchar2
                      ,p_scl_segment6               varchar2
                      ,p_scl_segment7               varchar2
                      ,p_scl_segment8               varchar2
                      ,p_scl_segment9               varchar2
                      ,p_scl_segment11              varchar2
                      ,p_scl_segment12              varchar2
                      ,p_scl_segment13              varchar2
                      ,p_scl_segment14              varchar2
                      ,p_scl_segment15              varchar2
                      ,p_scl_segment16              varchar2
                      ,p_notice_period              number
                      ,P_NOTICE_PERIOD_UOM          VARCHAR2
                      ,p_employment_category        varchar2
                      );

PROCEDURE update_pl_emp_asg
                     (P_EFFECTIVE_DATE               DATE
                     ,P_ASSIGNMENT_ID                NUMBER
                     ,P_ASSIGNMENT_STATUS_TYPE_ID    NUMBER
                     ,P_SEGMENT3                     VARCHAR2
                     ,P_SEGMENT4                     VARCHAR2
                     ,P_SEGMENT5                     VARCHAR2
                     ,P_SEGMENT6                     VARCHAR2
                     ,P_SEGMENT7                     VARCHAR2
                     ,P_SEGMENT8                     VARCHAR2
                     ,P_SEGMENT9                     VARCHAR2
                     ,P_SEGMENT11                    VARCHAR2
                     ,P_SEGMENT12                    VARCHAR2
                     ,P_SEGMENT13                    VARCHAR2
                     ,P_SEGMENT14                    VARCHAR2
                     ,P_SEGMENT15                    VARCHAR2
                     ,P_SEGMENT16                    VARCHAR2
                     ,P_NOTICE_PERIOD                NUMBER
                     ,P_NOTICE_PERIOD_UOM            VARCHAR2
                     );
procedure update_pl_emp_asg_criteria
                         (P_EFFECTIVE_DATE       DATE
                         ,P_ASSIGNMENT_ID        NUMBER
                         ,P_PAYROLL_ID           NUMBER
                         ,P_EMPLOYMENT_CATEGORY  VARCHAR2);



PROCEDURE CREATE_PL_SECONDARY_EMP_ASG_A
            (P_ASSIGNMENT_ID     in number,
             P_EFFECTIVE_DATE    in date,
             P_SCL_SEGMENT3      in varchar2);

PROCEDURE UPDATE_PL_EMP_ASG_A
           (P_EFFECTIVE_DATE     in date,
            P_SEGMENT3           in varchar2,
            P_ASSIGNMENT_ID      in number);




END PER_PL_ASSIGNMENT;


/
