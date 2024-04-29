--------------------------------------------------------
--  DDL for Package QA_AUDIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_AUDIT_PKG" AUTHID CURRENT_USER AS
/* $Header: qaaudits.pls 120.1 2005/07/14 03:31 srhariha noship $ */

    --
    -- General utilities for audit.
    --


    --
    -- Search paramters
    --
 TYPE summary_param_rec IS RECORD (standard varchar2(150));
 TYPE cat_summary_param_rec IS RECORD (standard varchar2(150),
                                         section varchar2(150),
                                         area varchar2(150),
                                         category varchar2(150));

 TYPE SummaryParamArray IS TABLE OF summary_param_rec    INDEX BY BINARY_INTEGER;
 TYPE CatSummaryParamArray IS TABLE OF cat_summary_param_rec    INDEX BY BINARY_INTEGER;


   --
   -- Copy questions from Audit Question Bank to Audit Questions and Response plan.
   -- It also does the following.
   -- (1) Copy context elements from audit master.
   -- (2) Create history records for audit questions.
   --
   --  Parameters IN :
   --
   --     Audit Question Bank details :-
   --       p_audit_bank_plan_id      - Question Bank Plan id
   --       p_audit_bank_org_id       - Organization in which Question bank is stored.
   --
   --     Audit Questions and Response plan details :-
   --       p_audit_question_plan_id  - Audit Questions Plan id
   --       p_audit_question_org_id   - Audit Questions org id
   --
   --     Search parameters :-
   --        p_summary_params         - Audit Summary search param (standard)
   --        p_cat_summary_params     - Audit Category Summary search param (standard,section,area,cat)
   --
   --  Parameters OUT :
   --        x_count                  - Number of rows copied
   --
   --
   --  IMPORTANT:
   --    Currently we use Rosetta tool to generate wrapper for this function. Following
   --    files are dependent on this procedure and package types.
   --
   --    (1) java/audit/server/QuestionBankAMImpl.java
   --    (2) java/audit/SummaryParamRec.java
   --    (3) java/audit/CatSummaryParamRec.java
   --    (4) patch/115/sql/qaaudwrs.pls
   --    (5) patch/115/sql/qaaudwrb.pls
   --
   --    If someone changes signature of this procedure or TYPES defined in this package,
   --    they must generate wrappers using Rosetta tool to reflect the changes in wrappers.
   --
   --    Please refer helper document for more details :
   --    http://files.oraclecorp.com/content/AllPublic/SharedFolders/Manufacturing-Public/SADBILMO/Quality%20Management/Build/11.5.11/Audits/Copy%20Audit%20UI/Helper%20document%20to%20use%20Rosetta%20tool.doc




   PROCEDURE copy_questions(
             p_audit_bank_plan_id NUMBER,
             p_audit_bank_org_id NUMBER,
             p_summary_params qa_audit_pkg.SummaryParamArray,
             p_cat_summary_params qa_audit_pkg.CatSummaryParamArray,
             p_audit_question_plan_id NUMBER,
             p_audit_question_org_id NUMBER,
             p_audit_num VARCHAR2,
             x_count OUT NOCOPY NUMBER,
             x_msg_count OUT NOCOPY NUMBER,
             x_msg_data OUT NOCOPY VARCHAR2,
             x_return_status OUT NOCOPY VARCHAR2);

END qa_audit_pkg;

 

/
