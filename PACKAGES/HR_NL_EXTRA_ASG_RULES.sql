--------------------------------------------------------
--  DDL for Package HR_NL_EXTRA_ASG_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_NL_EXTRA_ASG_RULES" AUTHID CURRENT_USER AS
/* $Header: penlexar.pkh 120.0.12000000.1 2007/01/22 00:24:29 appldev ship $ */
--
--Global Variables
glo_payroll_id pay_payrolls_f.payroll_id%TYPE;

-----------------------------------------------------------------------------
-- Performs validation for creation of secondary assignment
-----------------------------------------------------------------------------

 PROCEDURE EXTRA_ASSIGNMENT_CHECKS
 ( p_person_id            IN NUMBER
  ,p_payroll_id           IN NUMBER
  ,p_effective_date       IN DATE
  ,p_frequency            IN VARCHAR2
  ,p_normal_hours         IN NUMBER
  ,p_scl_segment1                 in     varchar2
  ,p_scl_segment2                 in     varchar2
  ,p_scl_segment3                 in     varchar2
  ,p_scl_segment4                 in     varchar2
  ,p_scl_segment5                 in     varchar2
  ,p_scl_segment6                 in     varchar2
  ,p_scl_segment7                 in     varchar2
  ,p_scl_segment8                 in     varchar2
  ,p_scl_segment9                 in     varchar2
  ,p_scl_segment10                in     varchar2
  ,p_scl_segment11                in     varchar2
  ,p_scl_segment12                in     varchar2
  ,p_scl_segment13                in     varchar2
  ,p_scl_segment14                in     varchar2
  ,p_scl_segment15                in     varchar2
  ,p_scl_segment16                in     varchar2
  ,p_scl_segment17                in     varchar2
  ,p_scl_segment18                in     varchar2
  ,p_scl_segment19                in     varchar2
  ,p_scl_segment20                in     varchar2
  ,p_scl_segment21                in     varchar2
  ,p_scl_segment22                in     varchar2
  ,p_scl_segment23                in     varchar2
  ,p_scl_segment24                in     varchar2
  ,p_scl_segment25                in     varchar2
  ,p_scl_segment26                in     varchar2
  ,p_scl_segment27                in     varchar2
  ,p_scl_segment28                in     varchar2
  ,p_scl_segment29                in     varchar2
  ,p_scl_segment30                in     varchar2  );
--


----------------------------------------------------------------------
--Performs validation for the updation of an assignment
----------------------------------------------------------------------
 PROCEDURE EXTRA_ASSIGNMENT_CHECKS1
 ( p_assignment_id        IN NUMBER
  ,p_effective_date       IN DATE
  ,p_frequency            IN VARCHAR2
  ,p_normal_hours         IN NUMBER
  ,p_segment1                 in     varchar2
  ,p_segment2                 in     varchar2
  ,p_segment3                 in     varchar2
  ,p_segment4                 in     varchar2
  ,p_segment5                 in     varchar2
  ,p_segment6                 in     varchar2
  ,p_segment7                 in     varchar2
  ,p_segment8                 in     varchar2
  ,p_segment9                 in     varchar2
  ,p_segment10                in     varchar2
  ,p_segment11                in     varchar2
  ,p_segment12                in     varchar2
  ,p_segment13                in     varchar2
  ,p_segment14                in     varchar2
  ,p_segment15                in     varchar2
  ,p_segment16                in     varchar2
  ,p_segment17                in     varchar2
  ,p_segment18                in     varchar2
  ,p_segment19                in     varchar2
  ,p_segment20                in     varchar2
  ,p_segment21                in     varchar2
  ,p_segment22                in     varchar2
  ,p_segment23                in     varchar2
  ,p_segment24                in     varchar2
  ,p_segment25                in     varchar2
  ,p_segment26                in     varchar2
  ,p_segment27                in     varchar2
  ,p_segment28                in     varchar2
  ,p_segment29                in     varchar2
  ,p_segment30                in     varchar2  );
--
--Sets the Global - glo_payroll_id
--For Tax Code Validations to be performed when API is being called implictly from
--People Management Templates - Enter Employee
PROCEDURE set_payroll_id(p_payroll_id IN NUMBER);
END HR_NL_EXTRA_ASG_RULES;

 

/
