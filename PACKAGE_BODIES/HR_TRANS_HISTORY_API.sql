--------------------------------------------------------
--  DDL for Package Body HR_TRANS_HISTORY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_TRANS_HISTORY_API" as
/* $Header: hrtrhapi.pkb 120.9.12010000.2 2009/08/13 11:11:46 gpurohit ship $ */
-- Global variables
   g_date_format varchar2(10) := 'RRRR/MM/DD';
   g_package  varchar2(33) := 'HR_TRANS_HISTORY_API.';
   g_debug boolean := hr_utility.debug_enabled;
--
--

 TYPE NumberTblType IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
 TYPE DateTblType IS TABLE OF DATE INDEX BY BINARY_INTEGER;
 TYPE VarChar08TblType IS TABLE OF VARCHAR2(8) INDEX BY BINARY_INTEGER;
 TYPE VarChar10TblType IS TABLE OF VARCHAR2(10) INDEX BY BINARY_INTEGER;
 TYPE VarChar30TblType IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
 TYPE VarChar61TblType IS TABLE OF VARCHAR2(61) INDEX BY BINARY_INTEGER;
 TYPE VarChar150TblType IS TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;
 TYPE VarChar240TblType IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;
 TYPE VarChar320TblType IS TABLE OF VARCHAR2(320) INDEX BY BINARY_INTEGER;
 TYPE VarChar2000TblType IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;

TYPE TransStateHistTbl IS RECORD
(
  TRANSACTION_HISTORY_ID                     NumberTblType
  ,APPROVAL_HISTORY_ID                       NumberTblType
  ,CREATOR_PERSON_ID                         NumberTblType
  ,CREATOR_ROLE                              VarChar320TblType
  ,STATUS                                    VarChar10TblType
  ,TRANSACTION_STATE                         VarChar10TblType
  ,EFFECTIVE_DATE                            DateTblType
  ,EFFECTIVE_DATE_OPTION                     VarChar10TblType
  ,LAST_UPDATE_ROLE                          VarChar320TblType
  ,PARENT_TRANSACTION_ID                     NumberTblType
  ,RELAUNCH_FUNCTION                         VarChar30TblType
  ,CREATED_BY                                NumberTblType
  ,CREATION_DATE                             DateTblType
  ,LAST_UPDATE_DATE                          DateTblType
  ,LAST_UPDATED_BY                           NumberTblType
  ,LAST_UPDATE_LOGIN                         NumberTblType
);

TYPE TransValueTbl IS RECORD
(
                   transaction_value_id    NumberTblType
		  ,step_history_id         NumberTblType
		  ,datatype                VarChar30TblType
		  ,name                    VarChar30TblType
		  ,value                   VarChar2000TblType
		  ,original_value          VarChar2000TblType
		  ,created_by              NumberTblType
		  ,creation_date           DateTblType
		  ,last_update_date        DateTblType
		  ,last_updated_by         NumberTblType
		  ,last_update_login       NumberTblType
);

TYPE TransStepTbl IS RECORD
(
                  STEP_HISTORY_ID          NumberTblType
		 ,TRANSACTION_HISTORY_ID   NumberTblType
		 ,API_NAME                 VarChar61TblType
		 ,API_DISPLAY_NAME         VarChar61TblType
		 ,PROCESSING_ORDER         NumberTblType
 		 ,CREATED_BY               NumberTblType
		 ,CREATION_DATE            DateTblType
		 ,LAST_UPDATE_DATE         DateTblType
		 ,LAST_UPDATED_BY          NumberTblType
		 ,LAST_UPDATE_LOGIN        NumberTblType
		 ,ITEM_TYPE                VarChar08TblType
		 ,ITEM_KEY                 VarChar240TblType
		 ,ACTIVITY_ID              NumberTblType
		 ,OBJECT_TYPE              VarChar30TblType
		 ,OBJECT_NAME              VarChar150TblType
		 ,OBJECT_IDENTIFIER        VarChar240TblType
         ,OBJECT_STATE             VarChar30TblType
		 ,PK1                      VarChar240TblType
		 ,PK2                      VarChar240TblType
		 ,PK3                      VarChar240TblType
		 ,PK4                      VarChar240TblType
		 ,PK5                      VarChar240TblType
		 ,INFORMATION_CATEGORY       VarChar30TblType
		 ,INFORMATION1               VarChar150TblType
		 ,INFORMATION2               VarChar150TblType
		 ,INFORMATION3               VarChar150TblType
		 ,INFORMATION4               VarChar150TblType
		 ,INFORMATION5               VarChar150TblType
		 ,INFORMATION6               VarChar150TblType
		 ,INFORMATION7               VarChar150TblType
		 ,INFORMATION8               VarChar150TblType
		 ,INFORMATION9               VarChar150TblType
		 ,INFORMATION10              VarChar150TblType
		 ,INFORMATION11              VarChar150TblType
		 ,INFORMATION12              VarChar150TblType
		 ,INFORMATION13              VarChar150TblType
		 ,INFORMATION14              VarChar150TblType
		 ,INFORMATION15              VarChar150TblType
		 ,INFORMATION16              VarChar150TblType
		 ,INFORMATION17              VarChar150TblType
		 ,INFORMATION18              VarChar150TblType
		 ,INFORMATION19              VarChar150TblType
		 ,INFORMATION20              VarChar150TblType
		 ,INFORMATION21              VarChar150TblType
		 ,INFORMATION22              VarChar150TblType
		 ,INFORMATION23              VarChar150TblType
		 ,INFORMATION24              VarChar150TblType
		 ,INFORMATION25              VarChar150TblType
		 ,INFORMATION26              VarChar150TblType
		 ,INFORMATION27              VarChar150TblType
		 ,INFORMATION28              VarChar150TblType
		 ,INFORMATION29              VarChar150TblType
		 ,INFORMATION30              VarChar150TblType

);

--
--
FUNCTION getTransStateSequence
(
   P_TRANSACTION_ID  IN NUMBER
) RETURN NUMBER
IS
  -- Cursor to return MaxSeq for new transactions.
  CURSOR getMaxSeq IS
    SELECT MAX(APPROVAL_HISTORY_ID)
    FROM   PQH_SS_TRANS_STATE_HISTORY
    WHERE  TRANSACTION_HISTORY_ID = P_TRANSACTION_ID;

  -- Cursor to return Max seq for old transactions.
  CURSOR getMaxOldSeq IS
    SELECT MAX(APPROVAL_HISTORY_ID)
    FROM   PQH_SS_APPROVAL_HISTORY
    WHERE  TRANSACTION_HISTORY_ID = P_TRANSACTION_ID;

  CURSOR populateStateTable IS
    Select
            ah.TRANSACTION_HISTORY_ID
           ,ah.APPROVAL_HISTORY_ID
           ,tx.CREATOR_PERSON_ID
           ,tx.CREATOR_ROLE
           ,tx.STATUS
           ,tx.TRANSACTION_STATE
           ,ah.TRANSACTION_EFFECTIVE_DATE
           ,ah.EFFECTIVE_DATE_OPTION
           ,tx.LAST_UPDATE_ROLE
           ,tx.PARENT_TRANSACTION_ID
           ,tx.RELAUNCH_FUNCTION
           ,ah.CREATED_BY
           ,ah.CREATION_DATE
           ,ah.LAST_UPDATE_DATE
           ,ah.LAST_UPDATED_BY
           ,ah.LAST_UPDATE_LOGIN
         FROM pqh_ss_approval_history ah, HR_API_TRANSACTIONS tx
         WHERE  TRANSACTION_ID = TRANSACTION_HISTORY_ID
         AND TRANSACTION_HISTORY_ID = P_TRANSACTION_ID;

  -- Note: Heena - Can we use only PQH_SS_APPROVAL_HISTORY ?

  l_seq_id NUMBER(5) := NULL;
  l_proc constant varchar2(100) := g_package || ' getTransStateSequence';
  stateTbl TransStateHistTbl;
  l_cnt INTEGER;

BEGIN
  hr_utility.set_location('Entering: '|| l_proc,5);
  OPEN getMaxSeq;
  FETCH getMaxSeq into l_seq_id;
  CLOSE getMaxSeq;
  -- Check if this is old transaction, if yes, fetch from approval table.
  If l_seq_id IS NULL Then
      OPEN getMaxOldSeq;
      FETCH getMaxOldSeq INTO l_seq_id;
      CLOSE getMaxOldSeq;
      IF (l_seq_id IS NOT NULL) THEN
        -- populate PQH_SS_TRANS_STATE_HISTORY
        -- from PQH_SS_APPROVAL_HISTORY and HR_API_TRANSACTIONS
        NULL;
        OPEN populateStateTable;
        FETCH populateStateTable BULK COLLECT INTO
           stateTbl.TRANSACTION_HISTORY_ID
          ,stateTbl.APPROVAL_HISTORY_ID
          ,stateTbl.CREATOR_PERSON_ID
          ,stateTbl.CREATOR_ROLE
          ,stateTbl.STATUS
          ,stateTbl.TRANSACTION_STATE
          ,stateTbl.EFFECTIVE_DATE
          ,stateTbl.EFFECTIVE_DATE_OPTION
          ,stateTbl.LAST_UPDATE_ROLE
          ,stateTbl.PARENT_TRANSACTION_ID
          ,stateTbl.RELAUNCH_FUNCTION
          ,stateTbl.CREATED_BY
          ,stateTbl.CREATION_DATE
          ,stateTbl.LAST_UPDATE_DATE
          ,stateTbl.LAST_UPDATED_BY
          ,stateTbl.LAST_UPDATE_LOGIN;

        l_cnt := stateTbl.TRANSACTION_HISTORY_ID.count;
        FOR  i in 1.. l_cnt LOOP
          Insert into pqh_ss_trans_state_history
          (
           TRANSACTION_HISTORY_ID,
           APPROVAL_HISTORY_ID,
           CREATOR_PERSON_ID,
           CREATOR_ROLE,
           STATUS,
           TRANSACTION_STATE,
           EFFECTIVE_DATE,
           EFFECTIVE_DATE_OPTION,
           LAST_UPDATE_ROLE,
           PARENT_TRANSACTION_ID,
           RELAUNCH_FUNCTION,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_LOGIN
        )
        values
        (
           stateTbl.TRANSACTION_HISTORY_ID(i)
          ,stateTbl.APPROVAL_HISTORY_ID(i)
          ,stateTbl.CREATOR_PERSON_ID(i)
          ,stateTbl.CREATOR_ROLE(i)
          ,stateTbl.STATUS(i)
          ,stateTbl.TRANSACTION_STATE(i)
          ,stateTbl.EFFECTIVE_DATE(i)
          ,stateTbl.EFFECTIVE_DATE_OPTION(i)
          ,stateTbl.LAST_UPDATE_ROLE(i)
          ,stateTbl.PARENT_TRANSACTION_ID(i)
          ,stateTbl.RELAUNCH_FUNCTION(i)
          ,stateTbl.CREATED_BY(i)
          ,stateTbl.CREATION_DATE(i)
          ,stateTbl.LAST_UPDATE_DATE(i)
          ,stateTbl.LAST_UPDATED_BY(i)
          ,stateTbl.LAST_UPDATE_LOGIN(i)
         );
       END LOOP;
      END IF;
  END IF;
  hr_utility.set_location('Leaving: '|| l_proc,10);
  RETURN l_seq_id;

EXCEPTION
  WHEN OTHERS THEN
     hr_utility.set_location('EXCEPTION: '|| l_proc,555);
     If getMaxSeq%ISOPEN Then
       CLOSE getMaxSeq;
     End If;

     If getMaxOldSeq%ISOPEN Then
       CLOSE getMaxOldSeq;
     End If;

     raise;
END getTransStateSequence;
---
---
---
Procedure RevertPerPayTransValues
(
  P_TRANSACTION_STEP_ID     IN              NUMBER,
  P_APPROVAL_HISTORY_ID     IN              NUMBER
)
IS
cursor csr_per_pay_trans_hist(C_APPROVAL_HISTORY_ID NUMBER)
is
   select pay_transaction_id,
          transaction_id    ,
          transaction_step_id,
          item_type          ,
          item_key           ,
          pay_proposal_id    ,
          assignment_id      ,
          pay_basis_id       ,
          business_group_id  ,
          change_date        ,
          date_to            ,
          last_change_date   ,
          reason             ,
          multiple_components,
          component_id       ,
          change_amount_n    ,
          change_percentage  ,
          proposed_salary_n  ,
          parent_pay_transaction_id,
          prior_pay_proposal_id    ,
          prior_pay_transaction_id ,
          prior_proposed_salary_n  ,
          prior_pay_basis_id   ,
          approved             ,
          next_perf_review_date,
          next_sal_review_date ,
          attribute_category   ,
          attribute1     ,
          attribute2     ,
          attribute3     ,
          attribute4     ,
          attribute5     ,
          attribute6     ,
          attribute7     ,
          attribute8     ,
          attribute9     ,
          attribute10    ,
          attribute11    ,
          attribute12    ,
          attribute13    ,
          attribute14    ,
          attribute15    ,
          attribute16    ,
          attribute17    ,
          attribute18    ,
          attribute19    ,
          attribute20    ,
          comments       ,
          last_update_date  ,
          last_updated_by   ,
          last_update_login ,
          created_by        ,
          creation_date     ,
          object_version_number,
          status               ,
          dml_operation        ,
          display_cd           ,
          txn_dml_operation
     from per_pay_transaction_history
     where approval_history_id = C_APPROVAL_HISTORY_ID
     and   transaction_step_id = P_TRANSACTION_STEP_ID;
BEGIN
  --
  delete from per_pay_transactions where transaction_step_id = P_TRANSACTION_STEP_ID;
  --
  for csr_per_pay_trans_hist_rec in csr_per_pay_trans_hist(P_APPROVAL_HISTORY_ID)
  loop
     --
     Insert into per_pay_transactions
     (    pay_transaction_id,
          transaction_id    ,
          transaction_step_id,
          item_type          ,
          item_key           ,
          pay_proposal_id    ,
          assignment_id      ,
          pay_basis_id       ,
          business_group_id  ,
          change_date        ,
          date_to            ,
          last_change_date   ,
          reason             ,
          multiple_components,
          component_id       ,
          change_amount_n    ,
          change_percentage  ,
          proposed_salary_n  ,
          parent_pay_transaction_id,
          prior_pay_proposal_id    ,
          prior_pay_transaction_id ,
          prior_proposed_salary_n  ,
          prior_pay_basis_id   ,
          approved             ,
          next_perf_review_date,
          next_sal_review_date ,
          attribute_category   ,
          attribute1     ,
          attribute2     ,
          attribute3     ,
          attribute4     ,
          attribute5     ,
          attribute6     ,
          attribute7     ,
          attribute8     ,
          attribute9     ,
          attribute10    ,
          attribute11    ,
          attribute12    ,
          attribute13    ,
          attribute14    ,
          attribute15    ,
          attribute16    ,
          attribute17    ,
          attribute18    ,
          attribute19    ,
          attribute20    ,
          comments       ,
          last_update_date  ,
          last_updated_by   ,
          last_update_login ,
          created_by        ,
          creation_date     ,
          object_version_number,
          status               ,
          dml_operation        ,
          display_cd           ,
          txn_dml_operation)
     values(
          csr_per_pay_trans_hist_rec.pay_transaction_id,
          csr_per_pay_trans_hist_rec.transaction_id    ,
          csr_per_pay_trans_hist_rec.transaction_step_id,
          csr_per_pay_trans_hist_rec.item_type          ,
          csr_per_pay_trans_hist_rec.item_key           ,
          csr_per_pay_trans_hist_rec.pay_proposal_id    ,
          csr_per_pay_trans_hist_rec.assignment_id      ,
          csr_per_pay_trans_hist_rec.pay_basis_id       ,
          csr_per_pay_trans_hist_rec.business_group_id  ,
          csr_per_pay_trans_hist_rec.change_date        ,
          csr_per_pay_trans_hist_rec.date_to            ,
          csr_per_pay_trans_hist_rec.last_change_date   ,
          csr_per_pay_trans_hist_rec.reason             ,
          csr_per_pay_trans_hist_rec.multiple_components,
          csr_per_pay_trans_hist_rec.component_id       ,
          csr_per_pay_trans_hist_rec.change_amount_n    ,
          csr_per_pay_trans_hist_rec.change_percentage  ,
          csr_per_pay_trans_hist_rec.proposed_salary_n  ,
          csr_per_pay_trans_hist_rec.parent_pay_transaction_id,
          csr_per_pay_trans_hist_rec.prior_pay_proposal_id    ,
          csr_per_pay_trans_hist_rec.prior_pay_transaction_id ,
          csr_per_pay_trans_hist_rec.prior_proposed_salary_n  ,
          csr_per_pay_trans_hist_rec.prior_pay_basis_id   ,
          csr_per_pay_trans_hist_rec.approved             ,
          csr_per_pay_trans_hist_rec.next_perf_review_date,
          csr_per_pay_trans_hist_rec.next_sal_review_date ,
          csr_per_pay_trans_hist_rec.attribute_category   ,
          csr_per_pay_trans_hist_rec.attribute1     ,
          csr_per_pay_trans_hist_rec.attribute2     ,
          csr_per_pay_trans_hist_rec.attribute3     ,
          csr_per_pay_trans_hist_rec.attribute4     ,
          csr_per_pay_trans_hist_rec.attribute5     ,
          csr_per_pay_trans_hist_rec.attribute6     ,
          csr_per_pay_trans_hist_rec.attribute7     ,
          csr_per_pay_trans_hist_rec.attribute8     ,
          csr_per_pay_trans_hist_rec.attribute9     ,
          csr_per_pay_trans_hist_rec.attribute10    ,
          csr_per_pay_trans_hist_rec.attribute11    ,
          csr_per_pay_trans_hist_rec.attribute12    ,
          csr_per_pay_trans_hist_rec.attribute13    ,
          csr_per_pay_trans_hist_rec.attribute14    ,
          csr_per_pay_trans_hist_rec.attribute15    ,
          csr_per_pay_trans_hist_rec.attribute16    ,
          csr_per_pay_trans_hist_rec.attribute17    ,
          csr_per_pay_trans_hist_rec.attribute18    ,
          csr_per_pay_trans_hist_rec.attribute19    ,
          csr_per_pay_trans_hist_rec.attribute20    ,
          csr_per_pay_trans_hist_rec.comments       ,
          csr_per_pay_trans_hist_rec.last_update_date  ,
          csr_per_pay_trans_hist_rec.last_updated_by   ,
          csr_per_pay_trans_hist_rec.last_update_login ,
          csr_per_pay_trans_hist_rec.created_by        ,
          csr_per_pay_trans_hist_rec.creation_date     ,
          csr_per_pay_trans_hist_rec.object_version_number,
          csr_per_pay_trans_hist_rec.status               ,
          csr_per_pay_trans_hist_rec.dml_operation        ,
          csr_per_pay_trans_hist_rec.display_cd           ,
          csr_per_pay_trans_hist_rec.txn_dml_operation);
       --
  end loop;
--
END RevertPerPayTransValues;
---
---
---
Procedure RevertTransSteps
(
   P_TRANSACTION_ID          IN              NUMBER
  ,P_APPROVAL_HISTORY_ID     IN              NUMBER
)
IS
  CURSOR cur_step_hist IS
    SELECT
	  STEP_HISTORY_ID
	 ,TRANSACTION_HISTORY_ID
	 ,API_NAME
	 ,API_DISPLAY_NAME
	 ,PROCESSING_ORDER
	 ,CREATED_BY
	 ,CREATION_DATE
	 ,LAST_UPDATE_DATE
	 ,LAST_UPDATED_BY
 	 ,LAST_UPDATE_LOGIN
	 ,ITEM_TYPE
	 ,ITEM_KEY
	 ,ACTIVITY_ID
	 ,OBJECT_TYPE
	 ,OBJECT_NAME
	 ,OBJECT_IDENTIFIER
     ,OBJECT_STATE
	 ,PK1
	 ,PK2
	 ,PK3
	 ,PK4
	 ,PK5
	 ,INFORMATION_CATEGORY
	 ,INFORMATION1
	 ,INFORMATION2
	 ,INFORMATION3
	 ,INFORMATION4
	 ,INFORMATION5
	 ,INFORMATION6
	 ,INFORMATION7
	 ,INFORMATION8
	 ,INFORMATION9
	 ,INFORMATION10
	 ,INFORMATION11
	 ,INFORMATION12
	 ,INFORMATION13
	 ,INFORMATION14
	 ,INFORMATION15
	 ,INFORMATION16
	 ,INFORMATION17
	 ,INFORMATION18
	 ,INFORMATION19
	 ,INFORMATION20
	 ,INFORMATION21
	 ,INFORMATION22
	 ,INFORMATION23
	 ,INFORMATION24
	 ,INFORMATION25
	 ,INFORMATION26
	 ,INFORMATION27
	 ,INFORMATION28
	 ,INFORMATION29
	 ,INFORMATION30
    FROM PQH_SS_STEP_HISTORY
    WHERE TRANSACTION_HISTORY_ID = P_TRANSACTION_ID
    AND   APPROVAL_HISTORY_ID = P_APPROVAL_HISTORY_ID;

    l_cnt Integer;
    l_proc constant varchar2(100) := g_package || ' RevertTransSteps';
    TxStepTbl TransStepTbl;
BEGIN
   hr_utility.set_location('Entering: '|| l_proc,5);
   OPEN cur_step_hist;
   FETCH cur_step_hist BULK COLLECT INTO
          TxStepTbl.STEP_HISTORY_ID
		 ,TxStepTbl.TRANSACTION_HISTORY_ID
		 ,TxStepTbl.API_NAME
		 ,TxStepTbl.API_DISPLAY_NAME
		 ,TxStepTbl.PROCESSING_ORDER
 		 ,TxStepTbl.CREATED_BY
		 ,TxStepTbl.CREATION_DATE
		 ,TxStepTbl.LAST_UPDATE_DATE
		 ,TxStepTbl.LAST_UPDATED_BY
		 ,TxStepTbl.LAST_UPDATE_LOGIN
		 ,TxStepTbl.ITEM_TYPE
		 ,TxStepTbl.ITEM_KEY
		 ,TxStepTbl.ACTIVITY_ID
		 ,TxStepTbl.OBJECT_TYPE
		 ,TxStepTbl.OBJECT_NAME
		 ,TxStepTbl.OBJECT_IDENTIFIER
         ,TxStepTbl.OBJECT_STATE
		 ,TxStepTbl.PK1
		 ,TxStepTbl.PK2
		 ,TxStepTbl.PK3
		 ,TxStepTbl.PK4
		 ,TxStepTbl.PK5
		 ,TxStepTbl.INFORMATION_CATEGORY
		 ,TxStepTbl.INFORMATION1
		 ,TxStepTbl.INFORMATION2
		 ,TxStepTbl.INFORMATION3
		 ,TxStepTbl.INFORMATION4
		 ,TxStepTbl.INFORMATION5
		 ,TxStepTbl.INFORMATION6
		 ,TxStepTbl.INFORMATION7
		 ,TxStepTbl.INFORMATION8
		 ,TxStepTbl.INFORMATION9
		 ,TxStepTbl.INFORMATION10
		 ,TxStepTbl.INFORMATION11
		 ,TxStepTbl.INFORMATION12
		 ,TxStepTbl.INFORMATION13
		 ,TxStepTbl.INFORMATION14
		 ,TxStepTbl.INFORMATION15
		 ,TxStepTbl.INFORMATION16
		 ,TxStepTbl.INFORMATION17
		 ,TxStepTbl.INFORMATION18
		 ,TxStepTbl.INFORMATION19
		 ,TxStepTbl.INFORMATION20
		 ,TxStepTbl.INFORMATION21
		 ,TxStepTbl.INFORMATION22
		 ,TxStepTbl.INFORMATION23
		 ,TxStepTbl.INFORMATION24
		 ,TxStepTbl.INFORMATION25
		 ,TxStepTbl.INFORMATION26
		 ,TxStepTbl.INFORMATION27
		 ,TxStepTbl.INFORMATION28
		 ,TxStepTbl.INFORMATION29
		 ,TxStepTbl.INFORMATION30;
    CLOSE cur_step_hist;

    l_cnt  := TxStepTbl.STEP_HISTORY_ID.count;

    FOR i in 1.. l_cnt LOOP
      INSERT INTO HR_API_TRANSACTION_STEPS
      (
	 TRANSACTION_STEP_ID
	,TRANSACTION_ID
	,API_NAME
	,API_DISPLAY_NAME
	,PROCESSING_ORDER
    ,CREATOR_PERSON_ID
    ,OBJECT_VERSION_NUMBER
	,CREATED_BY
	,CREATION_DATE
	,LAST_UPDATE_DATE
	,LAST_UPDATED_BY
	,LAST_UPDATE_LOGIN
	,ITEM_TYPE
	,ITEM_KEY
	,ACTIVITY_ID
	,OBJECT_TYPE
	,OBJECT_NAME
	,OBJECT_IDENTIFIER
    ,OBJECT_STATE
	,PK1
	,PK2
	,PK3
	,PK4
	,PK5
	,INFORMATION_CATEGORY
	,INFORMATION1
	,INFORMATION2
	,INFORMATION3
	,INFORMATION4
	,INFORMATION5
	,INFORMATION6
	,INFORMATION7
	,INFORMATION8
	,INFORMATION9
	,INFORMATION10
	,INFORMATION11
	,INFORMATION12
	,INFORMATION13
	,INFORMATION14
	,INFORMATION15
	,INFORMATION16
	,INFORMATION17
	,INFORMATION18
	,INFORMATION19
	,INFORMATION20
	,INFORMATION21
	,INFORMATION22
	,INFORMATION23
	,INFORMATION24
	,INFORMATION25
	,INFORMATION26
	,INFORMATION27
	,INFORMATION28
	,INFORMATION29
	,INFORMATION30
     )
     values
     (
         TxStepTbl.STEP_HISTORY_ID(i)
		,TxStepTbl.TRANSACTION_HISTORY_ID(i)
		,TxStepTbl.API_NAME(i)
		,TxStepTbl.API_DISPLAY_NAME(i)
		,TxStepTbl.PROCESSING_ORDER(i)
		,0                                -- creator_person_id
		,0                                -- OVN
 		,TxStepTbl.CREATED_BY(i)
		,TxStepTbl.CREATION_DATE(i)
		,TxStepTbl.LAST_UPDATE_DATE(i)
		,TxStepTbl.LAST_UPDATED_BY(i)
		,TxStepTbl.LAST_UPDATE_LOGIN(i)
		,TxStepTbl.ITEM_TYPE(i)
		,TxStepTbl.ITEM_KEY(i)
		,TxStepTbl.ACTIVITY_ID(i)
		,TxStepTbl.OBJECT_TYPE(i)
		,TxStepTbl.OBJECT_NAME(i)
		,TxStepTbl.OBJECT_IDENTIFIER(i)
        ,TxStepTbl.OBJECT_STATE(i)
		,TxStepTbl.PK1(i)
		,TxStepTbl.PK2(i)
		,TxStepTbl.PK3(i)
		,TxStepTbl.PK4(i)
		,TxStepTbl.PK5(i)
		,TxStepTbl.INFORMATION_CATEGORY(i)
		,TxStepTbl.INFORMATION1(i)
		,TxStepTbl.INFORMATION2(i)
		,TxStepTbl.INFORMATION3(i)
		,TxStepTbl.INFORMATION4(i)
		,TxStepTbl.INFORMATION5(i)
		,TxStepTbl.INFORMATION6(i)
		,TxStepTbl.INFORMATION7(i)
		,TxStepTbl.INFORMATION8(i)
		,TxStepTbl.INFORMATION9(i)
		,TxStepTbl.INFORMATION10(i)
		,TxStepTbl.INFORMATION11(i)
		,TxStepTbl.INFORMATION12(i)
		,TxStepTbl.INFORMATION13(i)
		,TxStepTbl.INFORMATION14(i)
		,TxStepTbl.INFORMATION15(i)
		,TxStepTbl.INFORMATION16(i)
		,TxStepTbl.INFORMATION17(i)
		,TxStepTbl.INFORMATION18(i)
		,TxStepTbl.INFORMATION19(i)
		,TxStepTbl.INFORMATION20(i)
		,TxStepTbl.INFORMATION21(i)
		,TxStepTbl.INFORMATION22(i)
		,TxStepTbl.INFORMATION23(i)
		,TxStepTbl.INFORMATION24(i)
		,TxStepTbl.INFORMATION25(i)
		,TxStepTbl.INFORMATION26(i)
		,TxStepTbl.INFORMATION27(i)
		,TxStepTbl.INFORMATION28(i)
		,TxStepTbl.INFORMATION29(i)
		,TxStepTbl.INFORMATION30(i)
        );
    RevertPerPayTransValues
    (
      TxStepTbl.STEP_HISTORY_ID(i),
      P_APPROVAL_HISTORY_ID
    );
    END LOOP;
    hr_utility.set_location('Leaving: '|| l_proc,10);
Exception
    when OTHERS then
        hr_utility.set_location('EXCEPTION: '|| l_proc,555);
        If cur_step_hist%IsOpen Then
            CLOSE cur_step_hist;
	End If;
        raise;
END RevertTransSteps;

Procedure RevertTransValues
(
   P_TRANSACTION_ID          IN              NUMBER
  ,P_APPROVAL_HISTORY_ID     IN              NUMBER
)
IS

CURSOR cur_trans_value IS
SELECT
		   transaction_value_id
		  ,step_history_id
		  ,datatype
		  ,name
		  ,value
		  ,original_value
		  ,created_by
		  ,creation_date
		  ,last_update_date
		  ,last_updated_by
		  ,last_update_login
FROM  PQH_SS_VALUE_HISTORY
Where step_history_id in
    ( SELECT STEP_HISTORY_ID
      FROM   PQH_SS_STEP_HISTORY
      WHERE  TRANSACTION_HISTORY_ID = P_TRANSACTION_ID
      AND    APPROVAL_HISTORY_ID = P_APPROVAL_HISTORY_ID)
AND APPROVAL_HISTORY_ID = P_APPROVAL_HISTORY_ID;

      l_cnt integer;
      l_proc constant varchar2(100) := g_package || ' RevertTransValues';
      TxValueTbl TransValueTbl;

BEGIN
  hr_utility.set_location('Entering: '|| l_proc,5);
  OPEN cur_trans_value;
  FETCH cur_trans_value BULK COLLECT INTO
           TxValueTbl.transaction_value_id
          ,TxValueTbl.step_history_id
		  ,TxValueTbl.datatype
		  ,TxValueTbl.name
		  ,TxValueTbl.value
		  ,TxValueTbl.original_value
		  ,TxValueTbl.created_by
		  ,TxValueTbl.creation_date
		  ,TxValueTbl.last_update_date
		  ,TxValueTbl.last_updated_by
		  ,TxValueTbl.last_update_login;
  CLOSE cur_trans_value;

  l_cnt := TxValueTbl.transaction_value_id.count;
  For i in 1.. l_cnt Loop
    INSERT INTO hr_api_transaction_values
    (
       TRANSACTION_VALUE_ID
       ,TRANSACTION_STEP_ID
       ,DATATYPE
       ,NAME
       ,VARCHAR2_VALUE
       ,NUMBER_VALUE
       ,DATE_VALUE
       ,ORIGINAL_VARCHAR2_VALUE
       ,ORIGINAL_NUMBER_VALUE
       ,ORIGINAL_DATE_VALUE
       ,CREATED_BY
       ,CREATION_DATE
       ,LAST_UPDATE_DATE
       ,LAST_UPDATED_BY
       ,LAST_UPDATE_LOGIN
    )
    VALUES
    (
       TxValueTbl.transaction_value_id(i)
      ,TxValueTbl.step_history_id(i)
      ,TxValueTbl.datatype(i)
      ,TxValueTbl.name(i)
      ,decode (TxValueTbl.datatype(i), 'VARCHAR2', TxValueTbl.value(i),  'BOOLEAN', TxValueTbl.value(i),null)
      ,decode (TxValueTbl.datatype(i), 'NUMBER', decode(TxValueTbl.value(i), null, null, to_number(TxValueTbl.value(i))), null)
      ,decode (TxValueTbl.datatype(i), 'DATE', decode(TxValueTbl.value(i), null, null, fnd_date.canonical_to_date(TxValueTbl.value(i))), null)
      ,decode (TxValueTbl.datatype(i), 'VARCHAR2', TxValueTbl.original_value(i), null)
      ,decode (TxValueTbl.datatype(i), 'NUMBER', decode(TxValueTbl.original_value(i), null, null, to_number(TxValueTbl.original_value(i))), null)
      ,decode (TxValueTbl.datatype(i), 'DATE', decode(TxValueTbl.original_value(i), null, null, fnd_date.canonical_to_date(TxValueTbl.original_value(i))), null)
      ,TxValueTbl.created_by(i)
      ,TxValueTbl.creation_date(i)
      ,TxValueTbl.last_update_date(i)
      ,TxValueTbl.last_updated_by(i)
      ,TxValueTbl.last_update_login(i)
    );
  END LOOP;
  hr_utility.set_location('Calling: RevertPerPayTransValues '|| l_proc,10);
  --
  --RevertPerPayTransValues(P_APPROVAL_HISTORY_ID);
  --
  hr_utility.set_location('Leaving: '|| l_proc,20);
Exception
    when OTHERS then
        hr_utility.set_location('EXCEPTION: '|| l_proc,555);
        If cur_trans_value%IsOpen Then
          CLOSE cur_trans_value;
	End If;
        raise;
END RevertTransValues;

procedure correctOldTxnHistoryData(P_TRANSACTION_ID  IN  NUMBER)
as
 -- local variables
 l_temp_found VarChar2(1);
 l_proc constant varchar2(100) := g_package || ' correctOldTxnHistoryData';
 ln_min_seq_id number;
 ln_max_seq_id number;
 -- Cursor to return Min and Max seq for old transactions step hist
  CURSOR getMinMaxOldSeq IS
    SELECT MIN(APPROVAL_HISTORY_ID),MAX(APPROVAL_HISTORY_ID)
    FROM   PQH_SS_STEP_HISTORY
    WHERE  TRANSACTION_HISTORY_ID = P_TRANSACTION_ID;


   CURSOR  origValUpgTrans IS
    SELECT TRANSACTION_VALUE_ID, VALUE, ORIGINAL_VALUE
    FROM   PQH_SS_STEP_HISTORY step, PQH_SS_VALUE_HISTORY val
    WHERE  step.TRANSACTION_HISTORY_ID = P_TRANSACTION_ID
    and    step.step_history_id =  val.step_history_id
    and    step.approval_history_id = val.approval_history_id
    and    val.approval_history_id = -1;

  CURSOR PsuedoValUpgTrans IS
    SELECT 1
    FROM   PQH_SS_STEP_HISTORY step, PQH_SS_VALUE_HISTORY val
    WHERE  step.TRANSACTION_HISTORY_ID = P_TRANSACTION_ID
    and    step.step_history_id =  val.step_history_id
    and    step.approval_history_id = val.approval_history_id
    and    val.approval_history_id = 0
    and    val.value IS NOT NULL;


 Begin
    hr_utility.set_location('Entering: '|| l_proc,5);
    -- archive data correction logic
    -- correct ONLY if max history id is 0 and min -1
    -- delete current txn values all the time if max history id is >0
    -- if max history id is 0 and module is LOA  DONOT Delete

    -- get the min and max sequence id of archive step history
    begin
        open getMinMaxOldSeq;
        FETCH getMinMaxOldSeq into
        ln_min_seq_id,ln_max_seq_id;
        CLOSE getMinMaxOldSeq;

     exception
     when others then
       raise;
    end;

    IF ln_max_seq_id = 0 and  ln_min_seq_id = -1 THEN
          OPEN PsuedoValUpgTrans;
          FETCH PsuedoValUpgTrans into l_temp_found;
          IF PsuedoValUpgTrans%NOTFOUND THEN
            /* Copy values stored for approval_history_id = -1
               to values stored for approval_history_id = 0 */
            FOR t in origValUpgTrans LOOP
                UPDATE pqh_ss_value_history
                SET     VALUE = t.VALUE, ORIGINAL_VALUE = t.ORIGINAL_VALUE
                WHERE  TRANSACTION_VALUE_ID = t.TRANSACTION_VALUE_ID
                AND    APPROVAL_HISTORY_ID  = 0;
            END LOOP;
          END IF;
          CLOSE PsuedoValUpgTrans;
      END IF;

   hr_utility.set_location('Leaving: '|| l_proc,10);

 end correctOldTxnHistoryData ;



--
-- ---------------------------------------------------------------------- --
-- --------------------<RevertToLastSave>------------------------- --
-- ---------------------------------------------------------------------- --
--

Procedure RevertToLastSave
(
  P_TRANSACTION_ID          IN              NUMBER
)
IS
  l_seq_id NUMBER(5);
  lv_found VarChar2(2);
  l_proc constant varchar2(100) := g_package || ' RevertToLastSave';
Begin
   hr_utility.set_location('Entering: '|| l_proc,5);
   l_seq_id := getTransStateSequence(P_TRANSACTION_ID => P_TRANSACTION_ID);

   -- Copy Transaction details from history.
   UPDATE HR_API_TRANSACTIONS
   SET (
	  STATUS
	 ,TRANSACTION_STATE
	 ,TRANSACTION_EFFECTIVE_DATE
	 ,EFFECTIVE_DATE_OPTION
	 ,PARENT_TRANSACTION_ID
	 ,RELAUNCH_FUNCTION
	 ,TRANSACTION_DOCUMENT
   )
   =
   ( SELECT
	  STATUS
	 ,TRANSACTION_STATE
	 ,EFFECTIVE_DATE
	 ,EFFECTIVE_DATE_OPTION
	 ,PARENT_TRANSACTION_ID
	 ,RELAUNCH_FUNCTION
	 ,TRANSACTION_DOCUMENT
     FROM PQH_SS_TRANS_STATE_HISTORY
     WHERE TRANSACTION_HISTORY_ID = P_TRANSACTION_ID
     AND   approval_history_id = l_seq_id
   )
   WHERE TRANSACTION_ID = P_TRANSACTION_ID
   AND exists (SELECT 1 FROM PQH_SS_TRANS_STATE_HISTORY
                WHERE TRANSACTION_HISTORY_ID = P_TRANSACTION_ID
                AND   approval_history_id = l_seq_id);

    -- special handling for old txn in progress
  -- archive data correction logic
    -- correct ONLY if max history id is 0 and min -1
    if(l_seq_id =0) then
       correctOldTxnHistoryData(P_TRANSACTION_ID);
    end if;

    -- delete current txn values all the time if max history id is >0
    -- if max history id is 0 and module is LOA  DONOT Delete step
    -- and value history
    if(l_seq_id =0) then
      begin
        select 'Y' into lv_found
        from PQH_SS_STEP_HISTORY
        where TRANSACTION_HISTORY_ID =P_TRANSACTION_ID
        and  API_NAME='HR_LOA_SS.PROCESS_API';
        exception
        when no_data_found then
          lv_found :='N';
        when others then
           raise;
       end;

       if(lv_found is not null and lv_found='Y') then
         -- no more further processing return
         return;
       end if;
    end if;
  -- end special handling


   -- DELETE Steps and Values First.
    DELETE HR_API_TRANSACTION_VALUES
    WHERE TRANSACTION_STEP_ID in
    ( SELECT TRANSACTION_STEP_ID
      FROM   HR_API_TRANSACTION_STEPS
      WHERE  TRANSACTION_ID = P_TRANSACTION_ID);

    DELETE HR_API_TRANSACTION_STEPS
    WHERE TRANSACTION_ID = P_TRANSACTION_ID;

   -- Copy Steps from history to transaction tables.
      RevertTransSteps
      (
         P_TRANSACTION_ID          => P_TRANSACTION_ID
        ,P_APPROVAL_HISTORY_ID     => l_seq_id
      );
   -- Copy Steps from history to transaction tables.
      RevertTransValues
      (
         P_TRANSACTION_ID          => P_TRANSACTION_ID
        ,P_APPROVAL_HISTORY_ID     => l_seq_id
      );
      hr_utility.set_location('Leaving: '|| l_proc,10);
Exception
    when OTHERS then
        hr_utility.set_location('EXCEPTION: '|| l_proc,555);
        raise;
End RevertToLastSave;

Procedure DeleteStaleData
(
   P_TRANSACTION_ID        IN   NUMBER
  ,P_ACTION                IN   VARCHAR DEFAULT 'SFL'
)
IS
  l_seq_id NUMBER(5);
  l_action   VARCHAR2(30);
  l_proc constant varchar2(100) := g_package || ' DeleteStaleData';

  CURSOR cur_chk_stale_data  IS
    select action
    from   pqh_ss_approval_history
    WHERE  TRANSACTION_HISTORY_ID = P_TRANSACTION_ID
    and    approval_history_id = l_seq_id
    and    action = 'SFL';

Begin
    --hr_utility.trace_on(null, 'TIGER');
    --g_debug := TRUE;
    hr_utility.set_location('Entering: '|| l_proc,5);
 IF P_ACTION NOT IN ('QUESTION', 'ANSWER') THEN
    l_seq_id := getTransStateSequence(P_TRANSACTION_ID => P_TRANSACTION_ID);

    OPEN cur_chk_stale_data;
    FETCH cur_chk_stale_data into l_action;

    If cur_chk_stale_data%found AND l_seq_id IS NOT NULL THEN
    hr_utility.set_location('Entering If: '|| l_proc,15);
	-- Delete State History
   	    DELETE pqh_ss_trans_state_history
	    WHERE  TRANSACTION_HISTORY_ID = P_TRANSACTION_ID
	    and    approval_history_id = l_seq_id;

	-- Delete Routing History
   	    DELETE pqh_ss_approval_history
	    WHERE  TRANSACTION_HISTORY_ID = P_TRANSACTION_ID
	    and    approval_history_id = l_seq_id;

        -- TODO: Delete Value History
           DELETE pqh_ss_value_history
           WHERE approval_history_id = l_seq_id
                    and   step_history_id in (
                             SELECT step_history_id
			     FROM pqh_ss_step_history
                             WHERE transaction_history_id = P_TRANSACTION_ID
                             and   approval_history_id    = l_seq_id
			     );

	-- Delete Steps History
   	    DELETE pqh_ss_step_history
	    WHERE  TRANSACTION_HISTORY_ID = P_TRANSACTION_ID
	    and    approval_history_id = l_seq_id;

    -- Delete Per Pay Trans History
       DELETE per_pay_transaction_history
       WHERE  TRANSACTION_ID = P_TRANSACTION_ID
       and    approval_history_id = l_seq_id;

	   IF P_ACTION NOT IN ('SFL', 'SUBMIT', 'RESUBMIT') THEN
	       RevertToLastSave(P_TRANSACTION_ID);
       END IF;

    END If;
    CLOSE cur_chk_stale_data;
 END IF;
    hr_utility.set_location('Leaving: '|| l_proc,10);
Exception
    when OTHERS then
        hr_utility.set_location('EXCEPTION: '|| l_proc,555);
        If cur_chk_stale_data%IsOpen Then
           CLOSE cur_chk_stale_data;
	End If;
        raise;
End DeleteStaleData;

--
-- ---------------------------------------------------------------------- --
-- -----------------------<SaveRoutingHistory>--------------------------- --
-- ---------------------------------------------------------------------- --
--

Procedure SaveRoutingHistory
(
  P_TRANSACTION_ID                  IN OUT  NOCOPY  NUMBER
 ,P_APPROVAL_HISTORY_ID             IN OUT  NOCOPY  NUMBER
 ,P_NOTIFICATION_ID                 IN       NUMBER
 ,P_ACTION                          IN       VARCHAR2
 ,P_USER_NAME                       IN       VARCHAR2
 ,P_USER_COMMENT                    IN       VARCHAR2  default hr_api.g_varchar2
)
IS
   l_proc constant varchar2(100) := g_package || 'SaveRoutingHistory';
   lv_orig_system  wf_roles.orig_system%type;
   lv_orig_system_id wf_roles.orig_system_id%type;

   CURSOR cur_trans_details IS
      SELECT ITEM_TYPE, ITEM_KEY, TRANSACTION_EFFECTIVE_DATE, EFFECTIVE_DATE_OPTION
      FROM   HR_API_TRANSACTIONS
      WHERE TRANSACTION_ID = P_TRANSACTION_ID;

   l_row cur_trans_details%RowType;
Begin
     hr_utility.set_location('Entering: '|| l_proc,5);
     Open cur_trans_details;
     Fetch cur_trans_details into l_row;
     CLOSE cur_trans_details;

     pqh_tah_ins.set_base_key_value(
       p_approval_history_id => P_APPROVAL_HISTORY_ID
      ,p_transaction_history_id => P_TRANSACTION_ID
	 );

    -- get the orig system and system id of the user passed
       wf_directory.getroleorigsysinfo(p_user_name,lv_orig_system,lv_orig_system_id);

     pqh_tah_ins.ins(
           p_transaction_effective_date => l_row.TRANSACTION_EFFECTIVE_DATE
		  ,p_action                     => P_ACTION
		  ,p_user_name                  => P_USER_NAME
                  ,p_orig_system                => lv_orig_system
                  ,p_orig_system_id             => lv_orig_system_id
		  ,p_transaction_item_type      => l_row.ITEM_TYPE
		  ,p_transaction_item_key       => l_row.ITEM_KEY
		  ,p_effective_date_option      => l_row.EFFECTIVE_DATE_OPTION
		  ,p_notification_id            => P_NOTIFICATION_ID
		  ,p_user_comment               => P_USER_COMMENT
		  ,p_approval_history_id        => P_APPROVAL_HISTORY_ID
		  ,p_transaction_history_id     => P_TRANSACTION_ID
     );
     hr_utility.set_location('Leaving: '|| l_proc,10);
Exception
    when OTHERS then
      hr_utility.set_location('EXCEPTION: '|| l_proc,555);
      If cur_trans_details%IsOpen Then
           CLOSE cur_trans_details;
      End If;
      raise;
End SaveRoutingHistory;
---
---
---
procedure SavePerPayTransHistory(
  P_TRANSACTION_STEP_ID             IN              NUMBER,
  P_APPROVAL_HISTORY_ID             IN              NUMBER
)
IS

cursor csr_per_pay_trans
is
   select pay_transaction_id,
          transaction_id    ,
          transaction_step_id,
          item_type          ,
          item_key           ,
          pay_proposal_id    ,
          assignment_id      ,
          pay_basis_id       ,
          business_group_id  ,
          change_date        ,
          date_to            ,
          last_change_date   ,
          reason             ,
          multiple_components,
          component_id       ,
          change_amount_n    ,
          change_percentage  ,
          proposed_salary_n  ,
          parent_pay_transaction_id,
          prior_pay_proposal_id    ,
          prior_pay_transaction_id ,
          prior_proposed_salary_n  ,
          prior_pay_basis_id   ,
          approved             ,
          next_perf_review_date,
          next_sal_review_date ,
          attribute_category   ,
          attribute1     ,
          attribute2     ,
          attribute3     ,
          attribute4     ,
          attribute5     ,
          attribute6     ,
          attribute7     ,
          attribute8     ,
          attribute9     ,
          attribute10    ,
          attribute11    ,
          attribute12    ,
          attribute13    ,
          attribute14    ,
          attribute15    ,
          attribute16    ,
          attribute17    ,
          attribute18    ,
          attribute19    ,
          attribute20    ,
          comments       ,
          last_update_date  ,
          last_updated_by   ,
          last_update_login ,
          created_by        ,
          creation_date     ,
          object_version_number,
          status               ,
          dml_operation        ,
          display_cd           ,
          txn_dml_operation
     from per_pay_transactions
     where transaction_step_id = P_TRANSACTION_STEP_ID;

BEGIN
   for csr_per_pay_trans_rec in csr_per_pay_trans
   loop
     Insert into per_pay_transaction_history
     (    pay_transaction_id,
	  APPROVAL_HISTORY_ID,
	  transaction_id    ,
	  transaction_step_id,
	  item_type          ,
	  item_key           ,
	  pay_proposal_id    ,
	  assignment_id      ,
	  pay_basis_id       ,
	  business_group_id  ,
	  change_date        ,
	  date_to            ,
	  last_change_date   ,
	  reason             ,
	  multiple_components,
	  component_id       ,
	  change_amount_n    ,
	  change_percentage  ,
	  proposed_salary_n  ,
	  parent_pay_transaction_id,
	  prior_pay_proposal_id    ,
	  prior_pay_transaction_id ,
	  prior_proposed_salary_n  ,
	  prior_pay_basis_id   ,
	  approved             ,
	  next_perf_review_date,
	  next_sal_review_date ,
	  attribute_category   ,
	  attribute1     ,
	  attribute2     ,
	  attribute3     ,
	  attribute4     ,
	  attribute5     ,
	  attribute6     ,
	  attribute7     ,
	  attribute8     ,
	  attribute9     ,
	  attribute10    ,
	  attribute11    ,
	  attribute12    ,
	  attribute13    ,
	  attribute14    ,
	  attribute15    ,
	  attribute16    ,
	  attribute17    ,
	  attribute18    ,
	  attribute19    ,
	  attribute20    ,
	  comments       ,
	  last_update_date  ,
	  last_updated_by   ,
	  last_update_login ,
	  created_by        ,
	  creation_date     ,
	  object_version_number,
	  status               ,
	  dml_operation        ,
	  display_cd           ,
          txn_dml_operation)
     values(
          csr_per_pay_trans_rec.pay_transaction_id,
          P_APPROVAL_HISTORY_ID,
          csr_per_pay_trans_rec.transaction_id    ,
          csr_per_pay_trans_rec.transaction_step_id,
          csr_per_pay_trans_rec.item_type          ,
          csr_per_pay_trans_rec.item_key           ,
          csr_per_pay_trans_rec.pay_proposal_id    ,
          csr_per_pay_trans_rec.assignment_id      ,
          csr_per_pay_trans_rec.pay_basis_id       ,
          csr_per_pay_trans_rec.business_group_id  ,
          csr_per_pay_trans_rec.change_date        ,
          csr_per_pay_trans_rec.date_to            ,
          csr_per_pay_trans_rec.last_change_date   ,
          csr_per_pay_trans_rec.reason             ,
          csr_per_pay_trans_rec.multiple_components,
          csr_per_pay_trans_rec.component_id       ,
          csr_per_pay_trans_rec.change_amount_n    ,
          csr_per_pay_trans_rec.change_percentage  ,
          csr_per_pay_trans_rec.proposed_salary_n  ,
          csr_per_pay_trans_rec.parent_pay_transaction_id,
          csr_per_pay_trans_rec.prior_pay_proposal_id    ,
          csr_per_pay_trans_rec.prior_pay_transaction_id ,
          csr_per_pay_trans_rec.prior_proposed_salary_n  ,
          csr_per_pay_trans_rec.prior_pay_basis_id   ,
          csr_per_pay_trans_rec.approved             ,
          csr_per_pay_trans_rec.next_perf_review_date,
          csr_per_pay_trans_rec.next_sal_review_date ,
          csr_per_pay_trans_rec.attribute_category   ,
          csr_per_pay_trans_rec.attribute1     ,
          csr_per_pay_trans_rec.attribute2     ,
          csr_per_pay_trans_rec.attribute3     ,
          csr_per_pay_trans_rec.attribute4     ,
          csr_per_pay_trans_rec.attribute5     ,
          csr_per_pay_trans_rec.attribute6     ,
          csr_per_pay_trans_rec.attribute7     ,
          csr_per_pay_trans_rec.attribute8     ,
          csr_per_pay_trans_rec.attribute9     ,
          csr_per_pay_trans_rec.attribute10    ,
          csr_per_pay_trans_rec.attribute11    ,
          csr_per_pay_trans_rec.attribute12    ,
          csr_per_pay_trans_rec.attribute13    ,
          csr_per_pay_trans_rec.attribute14    ,
          csr_per_pay_trans_rec.attribute15    ,
          csr_per_pay_trans_rec.attribute16    ,
          csr_per_pay_trans_rec.attribute17    ,
          csr_per_pay_trans_rec.attribute18    ,
          csr_per_pay_trans_rec.attribute19    ,
          csr_per_pay_trans_rec.attribute20    ,
          csr_per_pay_trans_rec.comments       ,
          csr_per_pay_trans_rec.last_update_date  ,
          csr_per_pay_trans_rec.last_updated_by   ,
          csr_per_pay_trans_rec.last_update_login ,
          csr_per_pay_trans_rec.created_by        ,
          csr_per_pay_trans_rec.creation_date     ,
          csr_per_pay_trans_rec.object_version_number,
          csr_per_pay_trans_rec.status               ,
          csr_per_pay_trans_rec.dml_operation        ,
          csr_per_pay_trans_rec.display_cd           ,
          csr_per_pay_trans_rec.txn_dml_operation);
     end loop;

END savePerPayTRansHistory;
---
---
---
Procedure SaveTransValueHistory
(
  P_TRANSACTION_STEP_ID  IN NUMBER
 ,P_APPROVAL_HISTORY_ID  IN NUMBER
)
IS
CURSOR cur_trans_value IS
  select  transaction_value_id ,
          datatype             ,
          name                 ,
          decode( datatype, 'VARCHAR2', varchar2_value,
	'BOOLEAN', varchar2_value,
                            'DATE'    , fnd_date.date_to_canonical(date_value),
                            'NUMBER'  , number_value  , '' ) value ,
          decode( datatype, 'VARCHAR2', original_varchar2_value,
                            'DATE'    , fnd_date.date_to_canonical(original_date_value),
                            'NUMBER'  , original_number_value  , '' ) original_value ,
          created_by           ,
          creation_date        ,
          last_update_date     ,
          last_updated_by      ,
          last_update_login
  from   hr_api_transaction_values
  where  transaction_step_id =  P_TRANSACTION_STEP_ID;

  l_cnt   integer;
  l_proc constant varchar2(100) := g_package || ' SaveTransValueHisroty';
  TxValueTbl TransValueTbl;
BEGIN
  hr_utility.set_location('Entering: '|| l_proc,5);

  OPEN cur_trans_value;
  FETCH cur_trans_value BULK COLLECT INTO
                   TxValueTbl.transaction_value_id
		  ,TxValueTbl.datatype
		  ,TxValueTbl.name
		  ,TxValueTbl.value
		  ,TxValueTbl.original_value
		  ,TxValueTbl.created_by
		  ,TxValueTbl.creation_date
		  ,TxValueTbl.last_update_date
		  ,TxValueTbl.last_updated_by
		  ,TxValueTbl.last_update_login;
  CLOSE cur_trans_value;

  l_cnt := TxValueTbl.transaction_value_id.count;

  For i in 1 .. l_cnt LOOP

	  INSERT into pqh_ss_value_history (
		   transaction_value_id
		  ,step_history_id
		  ,approval_history_id
		  ,datatype
		  ,name
		  ,value
		  ,original_value
		  ,created_by
		  ,creation_date
		  ,last_update_date
		  ,last_updated_by
		  ,last_update_login )
	  values(
                   TxValueTbl.transaction_value_id(i)
		  ,P_TRANSACTION_STEP_ID
		  ,P_APPROVAL_HISTORY_ID
		  ,TxValueTbl.datatype(i)
		  ,TxValueTbl.name(i)
		  ,TxValueTbl.value(i)
		  ,TxValueTbl.original_value(i)
		  ,TxValueTbl.created_by(i)
		  ,TxValueTbl.creation_date(i)
		  ,TxValueTbl.last_update_date(i)
		  ,TxValueTbl.last_updated_by(i)
		  ,TxValueTbl.last_update_login(i));

  END LOOP;
  hr_utility.set_location('Calling: savePerPayTransHistory '|| l_proc,10);
  --
  --SavePerPayTransHistory(P_APPROVAL_HISTORY_ID);
  --
  hr_utility.set_location('Leaving: '|| l_proc,20);
EXCEPTION
  WHEN OTHERS THEN
     hr_utility.set_location('EXCEPTION: '|| l_proc,555);
     If cur_trans_value%Isopen Then
       CLOSE cur_trans_value;
     End If;
     RAISE;
END SaveTransValueHistory;

Procedure SaveTransStepHistory
(
  P_TRANSACTION_ID                  IN              NUMBER
 ,P_APPROVAL_HISTORY_ID             IN              NUMBER
)
is

Cursor cur_trans_steps IS
  SELECT
	 TRANSACTION_STEP_ID
	,TRANSACTION_ID
	,API_NAME
	,API_DISPLAY_NAME
	,PROCESSING_ORDER
	,CREATED_BY
	,CREATION_DATE
	,LAST_UPDATE_DATE
	,LAST_UPDATED_BY
	,LAST_UPDATE_LOGIN
	,ITEM_TYPE
	,ITEM_KEY
	,ACTIVITY_ID
	,OBJECT_TYPE
	,OBJECT_NAME
	,OBJECT_IDENTIFIER
    ,OBJECT_STATE
	,PK1
	,PK2
	,PK3
	,PK4
	,PK5
	,INFORMATION_CATEGORY
	,INFORMATION1
	,INFORMATION2
	,INFORMATION3
	,INFORMATION4
	,INFORMATION5
	,INFORMATION6
	,INFORMATION7
	,INFORMATION8
	,INFORMATION9
	,INFORMATION10
	,INFORMATION11
	,INFORMATION12
	,INFORMATION13
	,INFORMATION14
	,INFORMATION15
	,INFORMATION16
	,INFORMATION17
	,INFORMATION18
	,INFORMATION19
	,INFORMATION20
	,INFORMATION21
	,INFORMATION22
	,INFORMATION23
	,INFORMATION24
	,INFORMATION25
	,INFORMATION26
	,INFORMATION27
	,INFORMATION28
	,INFORMATION29
	,INFORMATION30
     FROM hr_api_transaction_steps
     WHERE TRANSACTION_ID = P_TRANSACTION_ID;

    l_cnt integer;
    l_proc constant varchar2(100) := g_package || 'SaveTransStepHisroty';
    TxStepTbl TransStepTbl;
Begin
  hr_utility.set_location('Entering: '|| l_proc,5);
  OPEN cur_trans_steps;
  FETCH cur_trans_steps BULK COLLECT INTO
                  TxStepTbl.STEP_HISTORY_ID
		 ,TxStepTbl.TRANSACTION_HISTORY_ID
		 ,TxStepTbl.API_NAME
		 ,TxStepTbl.API_DISPLAY_NAME
		 ,TxStepTbl.PROCESSING_ORDER
 		 ,TxStepTbl.CREATED_BY
		 ,TxStepTbl.CREATION_DATE
		 ,TxStepTbl.LAST_UPDATE_DATE
		 ,TxStepTbl.LAST_UPDATED_BY
		 ,TxStepTbl.LAST_UPDATE_LOGIN
		 ,TxStepTbl.ITEM_TYPE
		 ,TxStepTbl.ITEM_KEY
		 ,TxStepTbl.ACTIVITY_ID
		 ,TxStepTbl.OBJECT_TYPE
		 ,TxStepTbl.OBJECT_NAME
		 ,TxStepTbl.OBJECT_IDENTIFIER
         ,TxStepTbl.OBJECT_STATE
		 ,TxStepTbl.PK1
		 ,TxStepTbl.PK2
		 ,TxStepTbl.PK3
		 ,TxStepTbl.PK4
		 ,TxStepTbl.PK5
		 ,TxStepTbl.INFORMATION_CATEGORY
		 ,TxStepTbl.INFORMATION1
		 ,TxStepTbl.INFORMATION2
		 ,TxStepTbl.INFORMATION3
		 ,TxStepTbl.INFORMATION4
		 ,TxStepTbl.INFORMATION5
		 ,TxStepTbl.INFORMATION6
		 ,TxStepTbl.INFORMATION7
		 ,TxStepTbl.INFORMATION8
		 ,TxStepTbl.INFORMATION9
		 ,TxStepTbl.INFORMATION10
		 ,TxStepTbl.INFORMATION11
		 ,TxStepTbl.INFORMATION12
		 ,TxStepTbl.INFORMATION13
		 ,TxStepTbl.INFORMATION14
		 ,TxStepTbl.INFORMATION15
		 ,TxStepTbl.INFORMATION16
		 ,TxStepTbl.INFORMATION17
		 ,TxStepTbl.INFORMATION18
		 ,TxStepTbl.INFORMATION19
		 ,TxStepTbl.INFORMATION20
		 ,TxStepTbl.INFORMATION21
		 ,TxStepTbl.INFORMATION22
		 ,TxStepTbl.INFORMATION23
		 ,TxStepTbl.INFORMATION24
		 ,TxStepTbl.INFORMATION25
		 ,TxStepTbl.INFORMATION26
		 ,TxStepTbl.INFORMATION27
		 ,TxStepTbl.INFORMATION28
		 ,TxStepTbl.INFORMATION29
		 ,TxStepTbl.INFORMATION30;
  CLOSE cur_trans_steps;
  l_cnt := TxStepTbl.STEP_HISTORY_ID.count;

  For i in 1 .. l_cnt Loop
    INSERT INTO pqh_ss_step_history
	(
	          STEP_HISTORY_ID
	 	 ,APPROVAL_HISTORY_ID
		 ,TRANSACTION_HISTORY_ID
		 ,API_NAME
		 ,API_DISPLAY_NAME
		 ,PROCESSING_ORDER
 		 ,CREATED_BY
		 ,CREATION_DATE
		 ,LAST_UPDATE_DATE
		 ,LAST_UPDATED_BY
		 ,LAST_UPDATE_LOGIN
		 ,ITEM_TYPE
		 ,ITEM_KEY
		 ,ACTIVITY_ID
		 ,OBJECT_TYPE
		 ,OBJECT_NAME
		 ,OBJECT_IDENTIFIER
         ,OBJECT_STATE
		 ,PK1
		 ,PK2
		 ,PK3
		 ,PK4
		 ,PK5
		 ,INFORMATION_CATEGORY
		 ,INFORMATION1
		 ,INFORMATION2
		 ,INFORMATION3
		 ,INFORMATION4
		 ,INFORMATION5
		 ,INFORMATION6
		 ,INFORMATION7
		 ,INFORMATION8
		 ,INFORMATION9
		 ,INFORMATION10
		 ,INFORMATION11
		 ,INFORMATION12
		 ,INFORMATION13
		 ,INFORMATION14
		 ,INFORMATION15
		 ,INFORMATION16
		 ,INFORMATION17
		 ,INFORMATION18
		 ,INFORMATION19
		 ,INFORMATION20
		 ,INFORMATION21
		 ,INFORMATION22
		 ,INFORMATION23
		 ,INFORMATION24
		 ,INFORMATION25
		 ,INFORMATION26
		 ,INFORMATION27
		 ,INFORMATION28
		 ,INFORMATION29
		 ,INFORMATION30
	)
	VALUES
	(
                 TxStepTbl.STEP_HISTORY_ID(i)
		,P_APPROVAL_HISTORY_ID
		,TxStepTbl.TRANSACTION_HISTORY_ID(i)
		,TxStepTbl.API_NAME(i)
		,TxStepTbl.API_DISPLAY_NAME(i)
		,TxStepTbl.PROCESSING_ORDER(i)
 		,TxStepTbl.CREATED_BY(i)
		,TxStepTbl.CREATION_DATE(i)
		,TxStepTbl.LAST_UPDATE_DATE(i)
		,TxStepTbl.LAST_UPDATED_BY(i)
		,TxStepTbl.LAST_UPDATE_LOGIN(i)
		,TxStepTbl.ITEM_TYPE(i)
		,TxStepTbl.ITEM_KEY(i)
		,TxStepTbl.ACTIVITY_ID(i)
		,TxStepTbl.OBJECT_TYPE(i)
		,TxStepTbl.OBJECT_NAME(i)
		,TxStepTbl.OBJECT_IDENTIFIER(i)
        ,TxStepTbl.OBJECT_STATE(i)
		,TxStepTbl.PK1(i)
		,TxStepTbl.PK2(i)
		,TxStepTbl.PK3(i)
		,TxStepTbl.PK4(i)
		,TxStepTbl.PK5(i)
		,TxStepTbl.INFORMATION_CATEGORY(i)
		,TxStepTbl.INFORMATION1(i)
		,TxStepTbl.INFORMATION2(i)
		,TxStepTbl.INFORMATION3(i)
		,TxStepTbl.INFORMATION4(i)
		,TxStepTbl.INFORMATION5(i)
		,TxStepTbl.INFORMATION6(i)
		,TxStepTbl.INFORMATION7(i)
		,TxStepTbl.INFORMATION8(i)
		,TxStepTbl.INFORMATION9(i)
		,TxStepTbl.INFORMATION10(i)
		,TxStepTbl.INFORMATION11(i)
		,TxStepTbl.INFORMATION12(i)
		,TxStepTbl.INFORMATION13(i)
		,TxStepTbl.INFORMATION14(i)
		,TxStepTbl.INFORMATION15(i)
		,TxStepTbl.INFORMATION16(i)
		,TxStepTbl.INFORMATION17(i)
		,TxStepTbl.INFORMATION18(i)
		,TxStepTbl.INFORMATION19(i)
		,TxStepTbl.INFORMATION20(i)
		,TxStepTbl.INFORMATION21(i)
		,TxStepTbl.INFORMATION22(i)
		,TxStepTbl.INFORMATION23(i)
		,TxStepTbl.INFORMATION24(i)
		,TxStepTbl.INFORMATION25(i)
		,TxStepTbl.INFORMATION26(i)
		,TxStepTbl.INFORMATION27(i)
		,TxStepTbl.INFORMATION28(i)
		,TxStepTbl.INFORMATION29(i)
		,TxStepTbl.INFORMATION30(i)
	);

    SaveTransValueHistory
    (
      P_TRANSACTION_STEP_ID =>  TxStepTbl.STEP_HISTORY_ID(i)
     ,P_APPROVAL_HISTORY_ID =>  P_APPROVAL_HISTORY_ID
    );

    SavePerPayTransHistory
    (
      TxStepTbl.STEP_HISTORY_ID(i),
      P_APPROVAL_HISTORY_ID
    );
  End Loop;
  hr_utility.set_location('Leaving: '|| l_proc,10);
EXCEPTION
  WHEN OTHERS THEN
     hr_utility.set_location('EXCEPTION: '|| l_proc,555);
     If cur_trans_steps%Isopen Then
       CLOSE cur_trans_steps;
     End If;
     RAISE;
End SaveTransStepHistory;

--
-- ---------------------------------------------------------------------- --
-- --------------------<SaveTransactionHistory>------------------------- --
-- ---------------------------------------------------------------------- --
--

Procedure SaveTransactionHistory
(
  P_TRANSACTION_ID       IN OUT NOCOPY NUMBER
 ,P_APPROVAL_HISTORY_ID  OUT NOCOPY NUMBER
)
IS
    CURSOR cur_trans_details IS
    SELECT
         t.TRANSACTION_ID
         ,t.CREATOR_PERSON_ID
         ,t.ASSIGNMENT_ID
         ,t.SELECTED_PERSON_ID
         ,t.ITEM_TYPE
         ,t.ITEM_KEY
         ,t.PROCESS_NAME
         ,t.FUNCTION_ID
         ,t.RPTG_GRP_ID
         ,t.PLAN_ID
         ,t.TRANSACTION_GROUP
         ,t.TRANSACTION_IDENTIFIER
         ,t.STATUS
         ,t.TRANSACTION_STATE
         ,t.TRANSACTION_EFFECTIVE_DATE
         ,t.EFFECTIVE_DATE_OPTION
         ,t.CREATOR_ROLE
         ,t.LAST_UPDATE_ROLE
         ,t.PARENT_TRANSACTION_ID
         ,t.RELAUNCH_FUNCTION
         ,t.TRANSACTION_DOCUMENT
         ,pt.transaction_history_id
    FROM hr_api_transactions t, pqh_ss_transaction_history pt
    WHERE transaction_id = P_TRANSACTION_ID
    AND t.transaction_id = pt.transaction_history_ID (+);

    l_trans_details_row cur_trans_details%ROWTYPE;
    l_seq_id PQH_SS_TRANS_STATE_HISTORY.approval_history_id%TYPE;
    l_proc constant varchar2(100) := g_package || ' SaveTransactionHistory';

Begin
    hr_utility.set_location('Entering: '|| l_proc,5);
    P_APPROVAL_HISTORY_ID := getTransStateSequence(P_TRANSACTION_ID);
    OPEN cur_trans_details;
    FETCH cur_trans_details INTO l_trans_details_row;
    If l_trans_details_row.transaction_history_id IS NULL then
      -- insert into transaction history
         pqh_txh_ins.set_base_key_value(p_transaction_history_id => P_TRANSACTION_ID);

         pqh_txh_ins.ins(
		 p_creator_person_id              =>   l_trans_details_row.creator_person_id
		,p_assignment_id                  =>   l_trans_details_row.assignment_id
		,p_selected_person_id             =>   l_trans_details_row.selected_person_id
		,p_item_type                      =>   l_trans_details_row.item_type
		,p_item_key                       =>   l_trans_details_row.item_key
		,p_process_name                   =>   l_trans_details_row.process_name
		,p_function_id                    =>   l_trans_details_row.function_id
		,p_rptg_grp_id                    =>   l_trans_details_row.rptg_grp_id
		,p_plan_id                        =>   l_trans_details_row.plan_id
		,p_transaction_group              =>   l_trans_details_row.transaction_group
		,p_transaction_identifier         =>   l_trans_details_row.transaction_identifier
		,p_transaction_history_id         =>   P_TRANSACTION_ID
         );
    End IF;

    P_APPROVAL_HISTORY_ID := nvl(P_APPROVAL_HISTORY_ID,0) + 1;
      -- insert into transaction state history
    pqh_tsh_ins.set_base_key_value(
      p_transaction_history_id        => P_TRANSACTION_ID
     ,P_APPROVAL_HISTORY_ID           => P_APPROVAL_HISTORY_ID
    );

    pqh_tsh_ins.ins(
      p_creator_person_id             =>    l_trans_details_row.creator_person_id
	  ,p_creator_role                  =>   l_trans_details_row.creator_role
	  ,p_status                        =>   l_trans_details_row.status
	  ,p_transaction_state             =>   l_trans_details_row.transaction_state
	  ,p_effective_date                =>   l_trans_details_row.transaction_effective_date
	  ,p_effective_date_option         =>   l_trans_details_row.effective_date_option
	  ,p_last_update_role              =>   l_trans_details_row.last_update_role
	  ,p_parent_transaction_id         =>   l_trans_details_row.parent_transaction_id
	  ,p_relaunch_function             =>   l_trans_details_row.relaunch_function
	  ,p_transaction_document          =>   l_trans_details_row.transaction_document
	  ,p_transaction_history_id        =>   P_TRANSACTION_ID
	  ,P_APPROVAL_HISTORY_ID           =>   P_APPROVAL_HISTORY_ID);

    -- insert into transaction steps history
     SaveTransStepHistory (
      P_TRANSACTION_ID        => P_TRANSACTION_ID
     ,P_APPROVAL_HISTORY_ID   => P_APPROVAL_HISTORY_ID
   );
   CLOSE cur_trans_details;
   hr_utility.set_location('Leaving: '|| l_proc,10);
Exception
    when OTHERS then
        hr_utility.set_location('EXCEPTION: '|| l_proc,555);
        If cur_trans_details%IsOpen Then
	   CLOSE cur_trans_details;
	End If;
        raise;
End SaveTransactionHistory;

--
--
Procedure ARCHIVE_ACTION
(
  P_TRANSACTION_ID    IN NUMBER
 ,P_NOTIFICATION_ID   IN NUMBER
 ,P_USER_NAME         IN VARCHAR2
 ,P_USER_COMMENT      IN VARCHAR2  DEFAULT NULL
 ,P_ACTION            IN VARCHAR2
)
IS
  l_action  VARCHAR2(15) := 'TRANSFER';
  l_seq_id NUMBER(5);
  l_trans_id NUMBER(15);
  l_proc constant varchar2(100) := g_package || ' ARCHIVE_ACTION';

 Begin
 --
--hr_utility.trace_on(null, 'TIGER');
--g_debug := TRUE;
--
   hr_utility.set_location('Entering: '|| l_proc,5);
   deleteStaleData(P_TRANSACTION_ID, P_ACTION);
   l_trans_id := P_TRANSACTION_ID;
   If (P_ACTION = 'RESUBMIT' AND P_NOTIFICATION_ID IS NULL)
      OR (P_ACTION IN ('SFL','SUBMIT')) Then

     SaveTransactionHistory
     (
        P_TRANSACTION_ID           => l_trans_id
       ,P_APPROVAL_HISTORY_ID      => l_seq_id
     );

   Else
     l_seq_id := getTransStateSequence(P_TRANSACTION_ID => P_TRANSACTION_ID);
   End If;

  -- For resumit case the notification  call back will handle th routing history
  IF (P_NOTIFICATION_ID IS NOT NULL OR P_ACTION in ('SFL','SUBMIT')) THEN
    l_seq_id := nvl(l_seq_id, 1);
   SaveRoutingHistory
   (
      P_TRANSACTION_ID                  => l_trans_id
     ,P_APPROVAL_HISTORY_ID             => l_seq_id
     ,P_NOTIFICATION_ID                 => P_NOTIFICATION_ID
     ,P_ACTION                          => P_ACTION
     ,P_USER_NAME                       => P_USER_NAME
     ,P_USER_COMMENT                    => P_USER_COMMENT
   );
  END IF;

   hr_utility.set_location('Leaving: '|| l_proc,10);
Exception
    when OTHERS then
        --ROLLBACK;
	hr_utility.set_location('EXCEPTION: '|| l_proc,555);
        raise;
End ARCHIVE_ACTION;

--
--
Procedure ARCHIVE_SUBMIT
(
  P_TRANSACTION_ID                  IN       NUMBER
 ,P_NOTIFICATION_ID                 IN       NUMBER
 ,P_USER_NAME                       IN       VARCHAR2
 ,P_USER_COMMENT                    IN       VARCHAR2
)
IS
  l_proc constant varchar2(100) := g_package || ' ARCHIVE_SUBMIT';
Begin
 --
-- hr_utility.trace_on(null, 'TIGER');
--g_debug := TRUE;
--
   hr_utility.set_location('Entering: '|| l_proc,5);
   ARCHIVE_ACTION
   (
    P_TRANSACTION_ID                  => P_TRANSACTION_ID
   ,P_NOTIFICATION_ID                 => P_NOTIFICATION_ID
   ,P_USER_NAME                       => P_USER_NAME
   ,P_USER_COMMENT                    => P_USER_COMMENT
   ,P_ACTION                          => 'SUBMIT'
  );
  hr_utility.set_location('Leaving: '|| l_proc,10);
Exception
    when OTHERS then
        hr_utility.set_location('EXCEPTION: '|| l_proc,555);
        raise;
End ARCHIVE_SUBMIT;

--
--
Procedure ARCHIVE_RESUBMIT
(
  P_TRANSACTION_ID                  IN       NUMBER
 ,P_NOTIFICATION_ID                 IN       NUMBER
 ,P_USER_NAME                       IN       VARCHAR2
 ,P_USER_COMMENT                    IN       VARCHAR2
)
IS
  l_proc constant varchar2(100) := g_package || ' ARCHIVE_RESUBMIT';
Begin
   hr_utility.set_location('Entering: '|| l_proc,5);
   ARCHIVE_ACTION
   (
    P_TRANSACTION_ID                  => P_TRANSACTION_ID
   ,P_NOTIFICATION_ID                 => P_NOTIFICATION_ID
   ,P_USER_NAME                       => P_USER_NAME
   ,P_USER_COMMENT                    => P_USER_COMMENT
   ,P_ACTION                          => 'RESUBMIT'
  );
  hr_utility.set_location('Leaving: '|| l_proc,10);
Exception
    when OTHERS then
        hr_utility.set_location('EXCEPTION: '|| l_proc,555);
        raise;
End ARCHIVE_RESUBMIT;

Procedure ARCHIVE_SFL
(
  P_TRANSACTION_ID                  IN       NUMBER
 ,P_NOTIFICATION_ID                 IN       NUMBER
 ,P_USER_NAME                       IN       VARCHAR2
)
IS
l_proc constant varchar2(100) := g_package || ' ARCHIVE_SFL';

Begin
 --
-- hr_utility.trace_on(null, 'TIGER');
--g_debug := TRUE;
--
   hr_utility.set_location('Entering: '|| l_proc,5);
   ARCHIVE_ACTION
   (
    P_TRANSACTION_ID                  => P_TRANSACTION_ID
   ,P_NOTIFICATION_ID                 => P_NOTIFICATION_ID
   ,P_USER_NAME                       => P_USER_NAME
   ,P_ACTION                          => 'SFL'
  );
  hr_utility.set_location('Leaving: '|| l_proc,10);
Exception
    when OTHERS then
        hr_utility.set_location('EXCEPTION: '|| l_proc,555);
        raise;
End ARCHIVE_SFL;

Procedure ARCHIVE_APPROVE
(
  P_TRANSACTION_ID                  IN       NUMBER
 ,P_NOTIFICATION_ID                 IN       NUMBER
 ,P_USER_NAME                       IN       VARCHAR2
 ,P_USER_COMMENT                    IN       VARCHAR2
)
IS
l_proc constant varchar2(100) := g_package || ' ARCHIVE_APPROVE';
Begin
   hr_utility.set_location('Entering: '|| l_proc,5);
   ARCHIVE_ACTION
   (
    P_TRANSACTION_ID                  => P_TRANSACTION_ID
   ,P_NOTIFICATION_ID                 => P_NOTIFICATION_ID
   ,P_USER_NAME                       => P_USER_NAME
   ,P_USER_COMMENT                    => P_USER_COMMENT
   ,P_ACTION                          => 'APPROVED'
  );
  hr_utility.set_location('Leaving: '|| l_proc,10);
Exception
    when OTHERS then
        hr_utility.set_location('EXCEPTION: '|| l_proc,555);
        raise;
End ARCHIVE_APPROVE;

Procedure ARCHIVE_DELETE
(
  P_TRANSACTION_ID                  IN       NUMBER
 ,P_NOTIFICATION_ID                 IN       NUMBER
 ,P_USER_NAME                       IN       VARCHAR2
 ,P_USER_COMMENT                    IN       VARCHAR2
)
IS
l_proc constant varchar2(100) := g_package || ' ARCHIVE_DELETE';
Begin
   hr_utility.set_location('Entering: '|| l_proc,5);
   ARCHIVE_ACTION
   (
    P_TRANSACTION_ID                  => P_TRANSACTION_ID
   ,P_NOTIFICATION_ID                 => P_NOTIFICATION_ID
   ,P_USER_NAME                       => P_USER_NAME
   ,P_USER_COMMENT                    => P_USER_COMMENT
   ,P_ACTION                          => 'DELETED'
  );
  hr_utility.set_location('Leaving: '|| l_proc,10);
Exception
    when OTHERS then
        hr_utility.set_location('EXCEPTION: '|| l_proc,555);
        raise;
End ARCHIVE_DELETE;

Procedure ARCHIVE_REJECT
(
  P_TRANSACTION_ID                  IN       NUMBER
 ,P_NOTIFICATION_ID                 IN       NUMBER
 ,P_USER_NAME                       IN       VARCHAR2
 ,P_USER_COMMENT                    IN       VARCHAR2
)
IS
l_proc constant varchar2(100) := g_package || ' ARCHIVE_REJECT';
Begin
   hr_utility.set_location('Entering: '|| l_proc,5);
   ARCHIVE_ACTION
   (
    P_TRANSACTION_ID                  => P_TRANSACTION_ID
   ,P_NOTIFICATION_ID                 => P_NOTIFICATION_ID
   ,P_USER_NAME                       => P_USER_NAME
   ,P_USER_COMMENT                    => P_USER_COMMENT
   ,P_ACTION                          => 'REJECTED'
  );
  hr_utility.set_location('Leaving: '|| l_proc,10);
Exception
    when OTHERS then
        hr_utility.set_location('EXCEPTION: '|| l_proc,555);
        raise;
End ARCHIVE_REJECT;

Procedure ARCHIVE_RFC
(
  P_TRANSACTION_ID                  IN       NUMBER
 ,P_NOTIFICATION_ID                 IN       NUMBER
 ,P_USER_NAME                       IN       VARCHAR2
 ,P_USER_COMMENT                    IN       VARCHAR2
)
IS
l_proc constant varchar2(100) := g_package || ' ARCHIVE_RFC';
Begin
   hr_utility.set_location('Entering: '|| l_proc,5);
   ARCHIVE_ACTION
   (
    P_TRANSACTION_ID                  => P_TRANSACTION_ID
   ,P_NOTIFICATION_ID                 => P_NOTIFICATION_ID
   ,P_USER_NAME                       => P_USER_NAME
   ,P_USER_COMMENT                    => P_USER_COMMENT
   ,P_ACTION                          => 'RFC'
  );
  hr_utility.set_location('Leaving: '|| l_proc,10);
Exception
    when OTHERS then
        hr_utility.set_location('EXCEPTION: '|| l_proc,555);
        raise;
End ARCHIVE_RFC;

Procedure ARCHIVE_TRANSFER
(
  P_TRANSACTION_ID                  IN       NUMBER
 ,P_NOTIFICATION_ID                 IN       NUMBER
 ,P_USER_NAME                       IN       VARCHAR2
 ,P_USER_COMMENT                    IN       VARCHAR2
)
IS
l_proc constant varchar2(100) := g_package || ' ARCHIVE_TRANSFER';
Begin
 --
-- hr_utility.trace_on(null, 'TIGER');
--g_debug := TRUE;
--
   hr_utility.set_location('Entering: '|| l_proc,5);
   ARCHIVE_ACTION
   (
    P_TRANSACTION_ID                  => P_TRANSACTION_ID
   ,P_NOTIFICATION_ID                 => P_NOTIFICATION_ID
   ,P_USER_NAME                       => P_USER_NAME
   ,P_USER_COMMENT                    => P_USER_COMMENT
   ,P_ACTION                          => 'TRANSFER'
  );
  hr_utility.set_location('Leaving: '|| l_proc,10);
Exception
    when OTHERS then
        hr_utility.set_location('EXCEPTION: '|| l_proc,555);
        raise;
End ARCHIVE_TRANSFER;

Procedure ARCHIVE_FORWARD
(
  P_TRANSACTION_ID                  IN       NUMBER
 ,P_NOTIFICATION_ID                 IN       NUMBER
 ,P_USER_NAME                       IN       VARCHAR2
 ,P_USER_COMMENT                    IN       VARCHAR2
)
IS
l_proc constant varchar2(100) := g_package || ' ARCHIVE_FORWARD';
Begin
   hr_utility.set_location('Entering: '|| l_proc,5);
   ARCHIVE_ACTION
   (
    P_TRANSACTION_ID                  => P_TRANSACTION_ID
   ,P_NOTIFICATION_ID                 => P_NOTIFICATION_ID
   ,P_USER_NAME                       => P_USER_NAME
   ,P_USER_COMMENT                    => P_USER_COMMENT
   ,P_ACTION                          => 'FORWARD'
  );
  hr_utility.set_location('Leaving: '|| l_proc,10);
Exception
    when OTHERS then
        hr_utility.set_location('EXCEPTION: '|| l_proc,555);
        raise;
End ARCHIVE_FORWARD;

Procedure ARCHIVE_REQ_MOREINFO
(
  P_TRANSACTION_ID                  IN       NUMBER
 ,P_NOTIFICATION_ID                 IN       NUMBER
 ,P_USER_NAME                       IN       VARCHAR2
 ,P_USER_COMMENT                    IN       VARCHAR2
)
IS
l_proc constant varchar2(100) := g_package || ' ARCHIVE_REQ_MOREINFO';
Begin
   hr_utility.set_location('Entering: '|| l_proc,5);
   ARCHIVE_ACTION
   (
    P_TRANSACTION_ID                  => P_TRANSACTION_ID
   ,P_NOTIFICATION_ID                 => P_NOTIFICATION_ID
   ,P_USER_NAME                       => P_USER_NAME
   ,P_USER_COMMENT                    => P_USER_COMMENT
   ,P_ACTION                          => 'QUESTION'
  );
  hr_utility.set_location('Leaving: '|| l_proc,10);
Exception
    when OTHERS then
        hr_utility.set_location('EXCEPTION: '|| l_proc,555);
        raise;
End ARCHIVE_REQ_MOREINFO;

Procedure ARCHIVE_ANSWER_MOREINFO
(
  P_TRANSACTION_ID                  IN       NUMBER
 ,P_NOTIFICATION_ID                 IN       NUMBER
 ,P_USER_NAME                       IN       VARCHAR2
 ,P_USER_COMMENT                    IN       VARCHAR2
)
IS
l_proc constant varchar2(100) := g_package || ' ARCHIVE_ANSWER_MOREINFO';
Begin
   hr_utility.set_location('Entering: '|| l_proc,5);
   ARCHIVE_ACTION
   (
    P_TRANSACTION_ID                  => P_TRANSACTION_ID
   ,P_NOTIFICATION_ID                 => P_NOTIFICATION_ID
   ,P_USER_NAME                       => P_USER_NAME
   ,P_USER_COMMENT                    => P_USER_COMMENT
   ,P_ACTION                          => 'ANSWER'
  );
  hr_utility.set_location('Leaving: '|| l_proc,10);
Exception
    when OTHERS then
        hr_utility.set_location('EXCEPTION: '|| l_proc,555);
        raise;
End ARCHIVE_ANSWER_MOREINFO;

Procedure CANCEL_ACTION
(
  P_TRANSACTION_ID IN NUMBER
)
IS
   l_proc constant varchar2(100) := g_package || ' CANCEL_ACTION';
   PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
 --
-- hr_utility.trace_on(null, 'TIGER');
--g_debug := TRUE;
--
  hr_utility.set_location('Entering: '|| l_proc,5);

  RevertToLastSave
  (
    P_TRANSACTION_ID    =>  P_TRANSACTION_ID
  );
  hr_utility.set_location('Leaving: '|| l_proc,10);
  commit;
Exception
    when OTHERS then
        hr_utility.set_location('EXCEPTION: '|| l_proc,555);
        ROLLBACK;
        RAISE;
END CANCEL_ACTION;

Procedure ARCHIVE_TIMEOUT
(
  P_TRANSACTION_ID                  IN       NUMBER
 ,P_NOTIFICATION_ID                 IN       NUMBER
 ,P_USER_NAME                       IN       VARCHAR2
 ,P_USER_COMMENT                    IN       VARCHAR2
)
IS
l_proc constant varchar2(100) := g_package || ' ARCHIVE_TIMEOUT';
Begin
   hr_utility.set_location('Entering: '|| l_proc,5);
   ARCHIVE_ACTION
   (
    P_TRANSACTION_ID                  => P_TRANSACTION_ID
   ,P_NOTIFICATION_ID                 => P_NOTIFICATION_ID
   ,P_USER_NAME                       => P_USER_NAME
   ,P_USER_COMMENT                    => P_USER_COMMENT
   ,P_ACTION                          => 'TIMEOUT'
  );
  hr_utility.set_location('Leaving: '|| l_proc,10);
Exception
    when OTHERS then
        hr_utility.set_location('EXCEPTION: '|| l_proc,555);
        raise;
End ARCHIVE_TIMEOUT;

END HR_TRANS_HISTORY_API;

/
