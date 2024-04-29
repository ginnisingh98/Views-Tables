--------------------------------------------------------
--  DDL for Package Body PA_CLIENT_EXT_FV_BUDGET_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CLIENT_EXT_FV_BUDGET_INT" AS
/* $Header: PAXFBIEB.pls 120.3 2006/12/27 11:34:04 anuagraw noship $ */
-- -------------------------------------------------------------------------------------
--      PROCEDURES
-- -------------------------------------------------------------------------------------

--
--Name:         INSERT_BUDGET_LINES
--Type:                 Procedure
--Description:          This procedure is used to insert Budget Lines into interface tables.
--                      Also returns status and interface status.
--
--
--Called Subprograms:   none.
--
--Notes:
--      This extension or function will be called from the PA Budget Workflow (PABUDWF) -->
--      Budget Process (PRO_BASELINE_BUDGET) --> Baseline approved budget Node (FUN_SAVE_BASELINE_ACTION)
--      ,PA_BUDGET_WF.BASELINE_BUDGET.
--
--
--
--HISTORY:
--      31-AUG-06          anuagraw               - Created
--
-- IN Parameters
--   p_project_id                  - Unique identifier of the project in Oracle Projects.
--   p_pre_baselined_version_id    - Unique identifier of the budget version previous to
--                                   current baseline budget version.
--   p_baselined_budget_version_id - Unique identifier of the current baselined budget version.
--
-- OUT Parameters
--   x_rejection_code              - Identifier of the source of the error and the error message
--                                   causing rejecion.
--   x_interface_status            - Identifier of the success status of the budget integration
--                                   to open interface tables.
--


  PROCEDURE INSERT_BUDGET_LINES
  (  p_project_id                     IN         NUMBER
    ,p_pre_baselined_version_id       IN         NUMBER
    ,p_baselined_budget_version_id    IN         NUMBER
    ,x_rejection_code                 OUT NOCOPY VARCHAR2
    ,x_interface_status               OUT NOCOPY VARCHAR2
  ) IS


    l_set_of_books_id         PA_PLSQL_DATATYPES.IdTabTyp;
    l_source                  PA_PLSQL_DATATYPES.Char25TabTyp;
    l_group_id                PA_PLSQL_DATATYPES.IdTabTyp;
    l_record_number           PA_PLSQL_DATATYPES.NumTabTyp;
    l_error_code              PA_PLSQL_DATATYPES.Char10TabTyp;
    l_error_reason            PA_PLSQL_DATATYPES.Char1000TabTyp;
    l_budget_level_id         PA_PLSQL_DATATYPES.IdTabTyp;
    l_budgeting_segments      PA_PLSQL_DATATYPES.Char1000TabTyp;
    l_transaction_TYPE        PA_PLSQL_DATATYPES.Char25TabTyp;
    l_sub_type                PA_PLSQL_DATATYPES.Char30TabTyp;
    l_fund_value              PA_PLSQL_DATATYPES.Char25TabTyp;
    l_period_name             PA_PLSQL_DATATYPES.Char15TabTyp;
    l_segment1_30             PA_PLSQL_DATATYPES.Char150TabTyp;
    l_increase_decrease_flag  PA_PLSQL_DATATYPES.Char1TabTyp;
    l_amount                  PA_PLSQL_DATATYPES.NewAmtTabTyp;
    l_doc_number              PA_PLSQL_DATATYPES.Char20TabTyp;
    l_attribute1              PA_PLSQL_DATATYPES.Char150TabTyp;
    l_attribute2              PA_PLSQL_DATATYPES.Char150TabTyp;
    l_attribute3              PA_PLSQL_DATATYPES.Char150TabTyp;
    l_attribute4              PA_PLSQL_DATATYPES.Char150TabTyp;
    l_attribute5              PA_PLSQL_DATATYPES.Char150TabTyp;
    l_attribute6              PA_PLSQL_DATATYPES.Char150TabTyp;
    l_attribute7              PA_PLSQL_DATATYPES.Char150TabTyp;
    l_attribute8              PA_PLSQL_DATATYPES.Char150TabTyp;
    l_attribute9              PA_PLSQL_DATATYPES.Char150TabTyp;
    l_attribute10             PA_PLSQL_DATATYPES.Char150TabTyp;
    l_attribute11             PA_PLSQL_DATATYPES.Char150TabTyp;
    l_attribute12             PA_PLSQL_DATATYPES.Char150TabTyp;
    l_attribute13             PA_PLSQL_DATATYPES.Char150TabTyp;
    l_attribute14             PA_PLSQL_DATATYPES.Char150TabTyp;
    l_attribute15             PA_PLSQL_DATATYPES.Char150TabTyp;
    l_attribute_category      PA_PLSQL_DATATYPES.Char30TabTyp;
    l_processed_flag          PA_PLSQL_DATATYPES.Char1TabTyp;
    l_status                  PA_PLSQL_DATATYPES.Char25TabTyp;
    l_date_created            PA_PLSQL_DATATYPES.DateTabTyp;
    l_created_by              PA_PLSQL_DATATYPES.NumTabTyp;
    l_corrected_flag          PA_PLSQL_DATATYPES.Char1TabTyp;
    l_last_update_date        PA_PLSQL_DATATYPES.DateTabTyp;
    l_last_updated_by         PA_PLSQL_DATATYPES.NumTabTyp;
    l_gl_date                 PA_PLSQL_DATATYPES.DateTabTyp;
    l_public_law_code         PA_PLSQL_DATATYPES.Char25TabTyp;
    l_advance_type            PA_PLSQL_DATATYPES.Char25TabTyp;
    l_dept_id                 PA_PLSQL_DATATYPES.Num15TabTyp;
    l_main_account            PA_PLSQL_DATATYPES.Num15TabTyp;
    l_transfer_description    PA_PLSQL_DATATYPES.Char30TabTyp;
    l_budget_user_id          PA_PLSQL_DATATYPES.NewAmtTabTyp;

    l_VER_GROUP_ID            VARCHAR2(150);
    l_user_id                 NUMBER(15);
    l_pkg_name                VARCHAR2(30) := 'PA_CLIENT_EXT_FV_BUDGET_INT';
    l_limit                   NUMBER  := 200;
    l_any_rec_found           VARCHAR2(1) := 'N';

  -- 1.Select additional columns here to map them to
  --   the FV_BE_INTERFACE table columns.
  -- 2.Put additional filters here ,if required.

  CURSOR C_PA_BUDGET_LINES(grp_id IN VARCHAR2,usr_id IN VARCHAR2) is
  SELECT
       pia.SET_OF_BOOKS_ID SET_OF_BOOKS_ID
        ,'PROJECTS'        SOURCE
        ,grp_id            GROUP_ID                        -- can be mapped to pbl.attribute1 also
        ,ABS(MOD(dbms_random.random,999))  RECORD_NUMBER   -- can be mappedto  pbl.attribute2 also
        ,null              ERROR_CODE
        ,null              ERROR_REASON
        ,pbl.attribute3    BUDGET_LEVEL_ID
        ,pbl.attribute4    BUDGETING_SEGMENTS
        ,pbl.attribute5    TRANSACTION_TYPE
        ,pbl.attribute6    SUB_TYPE
        ,pbl.attribute7    FUND_VALUE
        ,pbl.attribute8    PERIOD_NAME
        ,pbl.attribute9    SEGMENT1_30
        ,pbl.attribute10   INCREASE_DECREASE_FLAG
        ,pbl.attribute11   AMOUNT
        ,pbl.attribute12   DOC_NUMBER
        ,null              ATTRIBUTE1
        ,null              ATTRIBUTE2
        ,null              ATTRIBUTE3
        ,null              ATTRIBUTE4
        ,null              ATTRIBUTE5
        ,null              ATTRIBUTE6
        ,null              ATTRIBUTE7
        ,null              ATTRIBUTE8
        ,null              ATTRIBUTE9
        ,null              ATTRIBUTE10
        ,null              ATTRIBUTE11
        ,null              ATTRIBUTE12
        ,null              ATTRIBUTE13
        ,null              ATTRIBUTE14
        ,null              ATTRIBUTE15
        ,null              ATTRIBUTE_CATEGORY
        ,'N'               PROCESSED_FLAG
        ,'NEW'             STATUS
        ,pbl.CREATION_DATE DATE_CREATED
        ,pbl.CREATED_BY    CREATED_BY
        ,'N'               CORRECTED_FLAG
        ,null              LAST_UPDATE_DATE
        ,null              LAST_UPDATED_BY
        ,pbl.START_DATE    GL_DATE
        ,null              PUBLIC_LAW_CODE
        ,null              ADVANCE_TYPE
        ,null              DEPT_ID
        ,null              MAIN_ACCOUNT
        ,null              TRANSFER_DESCRIPTION
        ,usr_id            BUDGET_USER_ID
  from  PA_PROJECTS_ALL ppa
       ,PA_PROJECT_TYPES_ALL ppt
       ,PA_IMPLEMENTATIONS_ALL pia
       ,PA_BUDGET_VERSIONS pbv
       ,PA_BUDGET_LINES pbl
       ,PA_RESOURCE_ASSIGNMENTS pra
  where ppa.project_id = p_project_id
  and   ppa.project_TYPE = ppt.project_type
  and   ppa.org_id = ppt.org_id
  and   ppa.project_id = pbv.project_id
  and   ppa.org_id = pia.org_id
  and   pbv.budget_version_id = pbl.budget_version_id
  and   pbv.budget_version_id = p_baselined_budget_version_id
  and   pbl.resource_assignment_id = pra.resource_assignment_id ;


  -- Define your local variables here

  BEGIN

  x_interface_status := null;
  x_rejection_code   := null;

  -- Generating Group_id value from Env.
  SELECT ABS(MOD(dbms_random.random,999)),1003399   -- Please put the value of user_id as per your need.
  into l_VER_GROUP_ID,l_user_id
  FROM dual;

  -- Insert one record for each budget version baseline into
  -- the table FV_BE_INTERFACE_CONTOL

  INSERT INTO FV_BE_INTERFACE_CONTROL
    (
      SOURCE
     ,GROUP_ID
     ,STATUS
     ,DATE_PROCESSED
     ,TIME_PROCESSED
    )
    VALUES
    (
      'PROJECTS'
     ,l_VER_GROUP_ID
     ,'NEW'
     ,to_char(sysdate,'DD-MON-YY')
     ,to_char(sysdate,'HH24:MI:SS')
    );

  -- Do not commit in this package.Calling module will take care of commit;

    OPEN C_PA_BUDGET_LINES(l_VER_GROUP_ID,l_user_id);
    LOOP
    FETCH C_PA_BUDGET_LINES BULK COLLECT INTO
             l_set_of_books_id
            ,l_source
            ,l_group_id
            ,l_record_number
            ,l_error_code
            ,l_error_reason
            ,l_budget_level_id
            ,l_budgeting_segments
            ,l_transaction_TYPE
            ,l_sub_type
            ,l_fund_value
            ,l_period_name
            ,l_segment1_30
            ,l_increase_decrease_flag
            ,l_amount
            ,l_doc_number
            ,l_attribute1
            ,l_attribute2
            ,l_attribute3
            ,l_attribute4
            ,l_attribute5
            ,l_attribute6
            ,l_attribute7
            ,l_attribute8
            ,l_attribute9
            ,l_attribute10
            ,l_attribute11
            ,l_attribute12
            ,l_attribute13
            ,l_attribute14
            ,l_attribute15
            ,l_attribute_category
            ,l_processed_flag
            ,l_status
            ,l_date_created
            ,l_created_by
            ,l_corrected_flag
            ,l_last_update_date
            ,l_last_updated_by
            ,l_gl_date
            ,l_public_law_code
            ,l_advance_type
            ,l_dept_id
            ,l_main_account
            ,l_transfer_description
            ,l_budget_user_id
     LIMIT l_limit;

  -- Enter Your Business Rules Here to manipulate the attribute vales to be inserted into
  -- FV_BE_INTERFACE table or Use The the provided default.

  -- Insert one record for each budget line and one for each reverse budget line into
  -- the table FV_BE_INTERFACE table.

   -- Try to insert into FV_BE_INTERFACE only if any record is found for this loop

   IF l_set_of_books_id.COUNT > 0 then

    --
    l_any_rec_found := 'Y';

    FORALL i IN 1..l_set_of_books_id.COUNT

    INSERT INTO FV_BE_INTERFACE
      (
            SET_OF_BOOKS_ID
           ,SOURCE
           ,GROUP_ID
           ,RECORD_NUMBER
           ,ERROR_CODE
           ,ERROR_REASON
           ,BUDGET_LEVEL_ID
           ,BUDGETING_SEGMENTS
           ,TRANSACTION_TYPE
           ,SUB_TYPE
           ,FUND_VALUE
           ,PERIOD_NAME
           ,SEGMENT1
           ,SEGMENT2
           ,SEGMENT3
           ,SEGMENT4
           ,SEGMENT5
           ,SEGMENT6
           ,SEGMENT7
           ,SEGMENT8
           ,SEGMENT9
           ,SEGMENT10
           ,SEGMENT11
           ,SEGMENT12
           ,SEGMENT13
           ,SEGMENT14
           ,SEGMENT15
           ,SEGMENT16
           ,SEGMENT17
           ,SEGMENT18
           ,SEGMENT19
           ,SEGMENT20
           ,SEGMENT21
           ,SEGMENT22
           ,SEGMENT23
           ,SEGMENT24
           ,SEGMENT25
           ,SEGMENT26
           ,SEGMENT27
           ,SEGMENT28
           ,SEGMENT29
           ,SEGMENT30
           ,INCREASE_DECREASE_FLAG
           ,AMOUNT
           ,DOC_NUMBER
           ,ATTRIBUTE1
           ,ATTRIBUTE2
           ,ATTRIBUTE3
           ,ATTRIBUTE4
           ,ATTRIBUTE5
           ,ATTRIBUTE6
           ,ATTRIBUTE7
           ,ATTRIBUTE8
           ,ATTRIBUTE9
           ,ATTRIBUTE10
           ,ATTRIBUTE11
           ,ATTRIBUTE12
           ,ATTRIBUTE13
           ,ATTRIBUTE14
           ,ATTRIBUTE15
           ,ATTRIBUTE_CATEGORY
           ,PROCESSED_FLAG
           ,STATUS
           ,DATE_CREATED
           ,CREATED_BY
           ,CORRECTED_FLAG
           ,LAST_UPDATE_DATE
           ,LAST_UPDATED_BY
           ,GL_DATE
           ,PUBLIC_LAW_CODE
           ,ADVANCE_TYPE
           ,DEPT_ID
           ,MAIN_ACCOUNT
           ,TRANSFER_DESCRIPTION
           ,BUDGET_USER_ID
      )
        VALUES
      (
             l_set_of_books_id(i)
            ,l_source(i)
            ,l_group_id(i)
            ,l_record_number(i)
            ,l_error_code(i)
            ,l_error_reason(i)
            ,l_budget_level_id(i)
            ,l_budgeting_segments(i)
            ,l_transaction_type(i)
            ,l_sub_type(i)
            ,l_fund_value(i)
            ,l_period_name(i)
            ,REGEXP_SUBSTR(l_segment1_30(i),'[^.]+', 1,1 )
            ,REGEXP_SUBSTR(l_segment1_30(i),'[^.]+', 1,2)
            ,REGEXP_SUBSTR(l_segment1_30(i),'[^.]+', 1,3)
            ,REGEXP_SUBSTR(l_segment1_30(i),'[^.]+', 1,4)
            ,REGEXP_SUBSTR(l_segment1_30(i),'[^.]+', 1,5)
            ,REGEXP_SUBSTR(l_segment1_30(i),'[^.]+', 1,6)
            ,REGEXP_SUBSTR(l_segment1_30(i),'[^.]+', 1,7)
            ,REGEXP_SUBSTR(l_segment1_30(i),'[^.]+', 1,8)
            ,REGEXP_SUBSTR(l_segment1_30(i),'[^.]+', 1,9)
            ,REGEXP_SUBSTR(l_segment1_30(i),'[^.]+', 1,10)
            ,REGEXP_SUBSTR(l_segment1_30(i),'[^.]+', 1,11)
            ,REGEXP_SUBSTR(l_segment1_30(i),'[^.]+', 1,12)
            ,REGEXP_SUBSTR(l_segment1_30(i),'[^.]+', 1,13)
            ,REGEXP_SUBSTR(l_segment1_30(i),'[^.]+', 1,14)
            ,REGEXP_SUBSTR(l_segment1_30(i),'[^.]+', 1,15)
            ,REGEXP_SUBSTR(l_segment1_30(i),'[^.]+', 1,16)
            ,REGEXP_SUBSTR(l_segment1_30(i),'[^.]+', 1,17)
            ,REGEXP_SUBSTR(l_segment1_30(i),'[^.]+', 1,18)
            ,REGEXP_SUBSTR(l_segment1_30(i),'[^.]+', 1,19)
            ,REGEXP_SUBSTR(l_segment1_30(i),'[^.]+', 1,20)
            ,REGEXP_SUBSTR(l_segment1_30(i),'[^.]+', 1,21)
            ,REGEXP_SUBSTR(l_segment1_30(i),'[^.]+', 1,22)
            ,REGEXP_SUBSTR(l_segment1_30(i),'[^.]+', 1,23)
            ,REGEXP_SUBSTR(l_segment1_30(i),'[^.]+', 1,24)
            ,REGEXP_SUBSTR(l_segment1_30(i),'[^.]+', 1,25)
            ,REGEXP_SUBSTR(l_segment1_30(i),'[^.]+', 1,26)
            ,REGEXP_SUBSTR(l_segment1_30(i),'[^.]+', 1,27)
            ,REGEXP_SUBSTR(l_segment1_30(i),'[^.]+', 1,28)
            ,REGEXP_SUBSTR(l_segment1_30(i),'[^.]+', 1,29)
            ,REGEXP_SUBSTR(l_segment1_30(i),'[^.]+', 1,30)
            ,l_increase_decrease_flag(i)
            ,l_amount(i)
            ,l_doc_number(i)
            ,l_attribute1(i)
            ,l_attribute2(i)
            ,l_attribute3(i)
            ,l_attribute4(i)
            ,l_attribute5(i)
            ,l_attribute6(i)
            ,l_attribute7(i)
            ,l_attribute8(i)
            ,l_attribute9(i)
            ,l_attribute10(i)
            ,l_attribute11(i)
            ,l_attribute12(i)
            ,l_attribute13(i)
            ,l_attribute14(i)
            ,l_attribute15(i)
            ,l_attribute_category(i)
            ,l_processed_flag(i)
            ,l_status(i)
            ,l_date_created(i)
            ,l_created_by(i)
            ,l_corrected_flag(i)
            ,l_last_update_date(i)
            ,l_last_updated_by(i)
            ,l_gl_date(i)
            ,l_public_law_code(i)
            ,l_advance_type(i)
            ,l_dept_id(i)
            ,l_main_account(i)
            ,l_transfer_description(i)
            ,l_budget_user_id(i)
      );

  END IF;
   EXIT WHEN C_PA_BUDGET_LINES%NOTFOUND;

    END LOOP;

 if l_any_rec_found = 'Y' then
  x_interface_status := 'True';
 else
  x_interface_status := 'False';
  x_rejection_code  := 'NO_BUDGET_LINE';
 end if;

    -- Do not commit in this package.

  CLOSE C_PA_BUDGET_LINES;

  -- Please set the interface status to True if it is success as per custom logic , by default it is null


  Exception
   WHEN OTHERS THEN

   -- Since insert into both the tables are not successful set status to 'True' and Interface Status to 'False'

    x_interface_status := 'False';
    x_rejection_code  := l_pkg_name||':'||sqlerrm;
  END INSERT_BUDGET_LINES;

end PA_CLIENT_EXT_FV_BUDGET_INT;

/
