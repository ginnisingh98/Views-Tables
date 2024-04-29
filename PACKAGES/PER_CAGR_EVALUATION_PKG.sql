--------------------------------------------------------
--  DDL for Package PER_CAGR_EVALUATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CAGR_EVALUATION_PKG" AUTHID CURRENT_USER as
/* $Header: pecgrevl.pkh 120.0.12000000.1 2007/01/21 21:09:19 appldev ship $ */

TYPE cagr_SE_record    IS RECORD (VALUE                  VARCHAR2(240)
                                 ,RANGE_FROM             VARCHAR2(240)
                                 ,RANGE_TO               VARCHAR2(240)
                                 ,GRADE_SPINE_ID         NUMBER(15)
                                 ,PARENT_SPINE_ID        NUMBER(15)
                                 ,STEP_ID                NUMBER(15)
                                 ,FROM_STEP_ID           NUMBER(15)
                                 ,TO_STEP_ID             NUMBER(15)
                                 ,REQUEST_ID             NUMBER(15)
                                 ,ERROR                  varchar2(100));

TYPE cagr_BE_record    IS RECORD (COLLECTIVE_AGREEMENT_ID NUMBER(15)
                                 ,ASSIGNMENT_ID           NUMBER(15)
                                 ,PERSON_ID               NUMBER(15)
                                 ,VALUE                   VARCHAR2(240)
                                 ,RANGE_FROM              VARCHAR2(240)
                                 ,RANGE_TO                VARCHAR2(240)
                                 ,GRADE_SPINE_ID          NUMBER(15)
                                 ,PARENT_SPINE_ID         NUMBER(15)
                                 ,STEP_ID                 NUMBER(15)
                                 ,FROM_STEP_ID            NUMBER(15)
                                 ,TO_STEP_ID              NUMBER(15)
                                 ,CHOSEN_FLAG             VARCHAR2(30)
                                 ,BENEFICIAL_FLAG         VARCHAR2(30));

TYPE control_structure IS RECORD (effective_date               date
                                 ,operation_mode               varchar2(30)
                                 ,business_group_id            number(10)
                                 ,cagr_request_id              number(10)
                                 ,assignment_id                number(10)
                                 ,assignment_set_id            number(10)
                                 ,collective_agreement_id      number(10)
                                 ,category                     varchar2(30)
                                 ,cagr_set_id                  number(10)
                                 ,payroll_id                   number(10)
                                 ,person_id                    number(10)
                                 ,entitlement_item_id          number(10)
                                 ,commit_flag                  varchar2(30)
                                 ,denormalise_flag             varchar2(30)
                                 ,return_code                  number(10));   -- error code to CONC / FPORM

TYPE cagr_BE_table is TABLE OF cagr_BE_record
                               INDEX BY BINARY_INTEGER;


g_head_separator  constant varchar2(80) := '++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++';
g_separator       constant varchar2(80) := '--------------------------------------------------------------------------------';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< get_entitlement_value >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Wrapper procedure running initialise in single entitlement mode, returning
--   entitlement value in output structure.
--
-- Post Success
--
-- Post Failure:
--
-- Developer Implementation Notes:
--
-- Access Status:
--
PROCEDURE get_entitlement_value (p_process_date                in   date
                                ,p_business_group_id           in   number
                                ,p_assignment_id               in   number
                                ,p_entitlement_item_id         in   number
                                ,p_collective_agreement_id     in   number   default null
                                ,p_collective_agreement_set_id in   number   default null
                                ,p_commit_flag                 in   varchar2 default 'N'
                                ,p_output_structure              out nocopy  per_cagr_evaluation_pkg.cagr_SE_record);


--
-- ----------------------------------------------------------------------------
-- |-------------------------< get_mass_entitlement >-------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Wrapper procedure to call initialise in batch entitlement mode (BE), returning
--   a pl/sql table of eligible people (and their entitlement results) for an
--   entitlement item on the process date.
--
--   If collective_agreement_id parameter is supplied then eligibility for the
--   entitlement item will be evaluated for that cagr only, otherwise eligibility
--   for the entitlement item will be evaluated across all cagrs.
--
--   If a value or step is supplied for the entitlement item then eligibility
--   evaluation will be further restricted to return only those people
--   who are entitled to that item and are eligible for that value or step.
--
-- Post Success
--
-- Post Failure:
--
-- Developer Implementation Notes:
--
-- Access Status:
--
PROCEDURE get_mass_entitlement (p_process_date                 in   date
                               ,p_business_group_id            in   number
                               ,p_entitlement_item_id          in   number
                               ,p_value                        in   varchar2 default null
                               ,p_step_id                      in   number   default null
                               ,p_collective_agreement_id      in   number   default null
                               ,p_collective_agreement_set_id  in   number   default null
                               ,p_commit_flag                  in   varchar2 default 'N'
                               ,p_output_structure         out nocopy      per_cagr_evaluation_pkg.cagr_BE_table
                               ,p_cagr_request_id          out nocopy      number);

--
-- ----------------------------------------------------------------------------
-- |------------------------------< initialise >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   This procedure initiates a run of the collective agreement entitlement
--   evaluation engine.
--
-- Post Success
--
-- Post Failure:
--
-- Developer Implementation Notes:
--
-- Access Status:
--
PROCEDURE initialise
          (p_process_date                 IN    DATE
          ,p_operation_mode               IN    VARCHAR2
          ,p_business_group_id            IN    NUMBER
          ,p_assignment_id                IN    NUMBER   DEFAULT NULL
          ,p_assignment_set_id            IN    NUMBER   DEFAULT NULL
          ,p_collective_agreement_id      IN    NUMBER   DEFAULT NULL
          ,p_collective_agreement_set_id  IN    NUMBER   DEFAULT NULL
          ,p_payroll_id                   IN    NUMBER   DEFAULT NULL
          ,p_person_id                    IN    NUMBER   DEFAULT NULL
          ,p_entitlement_item_id          IN    NUMBER   DEFAULT NULL
          ,p_commit_flag                  IN    VARCHAR2 DEFAULT 'N'
          ,p_apply_results_flag           IN    VARCHAR2 DEFAULT 'N'
          ,p_cagr_request_id              OUT NOCOPY   NUMBER);

--
-- ----------------------------------------------------------------------------
-- |-------------------------< new_entitlement >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--
-- Post Success
--
-- Post Failure:
--
-- Developer Implementation Notes:
--
-- Access Status:
--
FUNCTION new_entitlement (p_ent_id  IN NUMBER) RETURN VARCHAR2;


END per_cagr_evaluation_pkg;

 

/
