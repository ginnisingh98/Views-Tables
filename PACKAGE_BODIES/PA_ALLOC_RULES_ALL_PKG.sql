--------------------------------------------------------
--  DDL for Package Body PA_ALLOC_RULES_ALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ALLOC_RULES_ALL_PKG" AS
 /* $Header: PAXATRLB.pls 120.2 2005/06/20 12:58:54 dlanka noship $  */
procedure INSERT_ROW (
   X_ROWID 			in out NOCOPY VARCHAR2,
  X_RULE_ID 			in out NOCOPY NUMBER,
  X_RULE_NAME 			in VARCHAR2,
  X_DESCRIPTION 		in VARCHAR2,
  X_POOL_PERCENT 		in NUMBER,
  X_PERIOD_TYPE 		in VARCHAR2,
  X_SOURCE_AMOUNT_TYPE 		in VARCHAR2,
  X_SOURCE_BALANCE_CATEGORY 	in VARCHAR2,
  X_SOURCE_BALANCE_TYPE 	in VARCHAR2,
  X_ALLOC_RESOURCE_LIST_ID 	in NUMBER,
  X_AUTO_RELEASE_FLAG 		in VARCHAR2,
  X_ALLOCATION_METHOD 		in VARCHAR2,
  X_IMP_WITH_EXCEPTION 		in VARCHAR2,
  X_DUP_TARGETS_FLAG 		in VARCHAR2,
  X_TARGET_EXP_TYPE_CLASS 	in VARCHAR2,
  X_TARGET_EXP_ORG_ID 		in NUMBER,
  X_TARGET_EXP_TYPE 		in VARCHAR2,
  X_TARGET_COST_TYPE 		in VARCHAR2,
  X_OFFSET_EXP_TYPE_CLASS 	in VARCHAR2,
  X_OFFSET_EXP_ORG_ID 		in NUMBER,
  X_OFFSET_EXP_TYPE 		in VARCHAR2,
  X_OFFSET_COST_TYPE 		in VARCHAR2,
  X_OFFSET_METHOD 		in VARCHAR2,
  X_OFFSET_PROJECT_ID 		in NUMBER,
  X_OFFSET_TASK_ID 		in NUMBER,
  X_BASIS_METHOD 		in VARCHAR2,
  X_BASIS_RELATIVE_PERIOD 	in NUMBER,
  X_BASIS_AMOUNT_TYPE 		in VARCHAR2,
  X_BASIS_BALANCE_CATEGORY 	in VARCHAR2,
  X_BASIS_BUDGET_TYPE_CODE 	in VARCHAR2,
  X_BAS_BUDGET_ENTRY_METHOD_CODE in VARCHAR2,
  X_BASIS_BALANCE_TYPE 		in VARCHAR2,
  X_BASIS_RESOURCE_LIST_ID 	in NUMBER,
  X_SOURCE_EXTN_FLAG 		in VARCHAR2,
  X_TARGET_EXTN_FLAG 		in VARCHAR2,
  X_FIXED_AMOUNT 		in NUMBER,
  X_START_DATE_ACTIVE 		in DATE,
  X_END_DATE_ACTIVE 		in DATE,
  X_ATTRIBUTE_CATEGORY 		in VARCHAR2,
  X_ATTRIBUTE1 			in VARCHAR2,
  X_ATTRIBUTE2 			in VARCHAR2,
  X_ATTRIBUTE3 			in VARCHAR2,
  X_ATTRIBUTE4 			in VARCHAR2,
  X_ATTRIBUTE5 			in VARCHAR2,
  X_ATTRIBUTE6 			in VARCHAR2,
  X_ATTRIBUTE7 			in VARCHAR2,
  X_ATTRIBUTE8 			in VARCHAR2,
  X_ATTRIBUTE9 			in VARCHAR2,
  X_ATTRIBUTE10 		in VARCHAR2,
  X_CREATION_DATE		in DATE,
  X_CREATED_BY			in NUMBER,
  X_LAST_UPDATE_DATE		in DATE,
  X_LAST_UPDATED_BY		in NUMBER,
  X_LAST_UPDATE_LOGIN		in NUMBER,
  X_LIMIT_TARGET_PROJECTS_CODE in varchar2,
  X_BASIS_FIN_PLAN_TYPE_ID      in NUMBER /* Bug 2619977 */ ,
    /* FP.M : Allocation Impact : 3512552 */
  X_ALLOC_RESOURCE_STRUCT_TYPE In Varchar2 ,
  X_BASIS_RESOURCE_STRUCT_TYPE In Varchar2 ,
  X_ALLOC_RBS_VERSION In Number ,
  X_BASIS_RBS_VERSION In Number ,
  X_ORG_ID in number

) is
    cursor C is select ROWID from PA_ALLOC_RULES_ALL
      where RULE_ID = X_RULE_ID;
    CURSOR C1 is Select pa_alloc_rules_s.nextval from sys.dual;
    --X_LAST_UPDATE_DATE DATE;
    --X_LAST_UPDATED_BY NUMBER;
    --X_LAST_UPDATE_LOGIN NUMBER;
begin
  --X_LAST_UPDATE_DATE := SYSDATE;

  if X_RULE_ID is null then
    open C1;
    fetch C1 into X_RULE_ID;
    close C1;
  end if;
  insert into PA_ALLOC_RULES_ALL (
    RULE_ID,
    RULE_NAME,
    DESCRIPTION,
    POOL_PERCENT,
    PERIOD_TYPE,
    SOURCE_AMOUNT_TYPE,
    SOURCE_BALANCE_CATEGORY,
    SOURCE_BALANCE_TYPE,
    ALLOC_RESOURCE_LIST_ID,
    AUTO_RELEASE_FLAG,
    ALLOCATION_METHOD,
    IMP_WITH_EXCEPTION,
    DUP_TARGETS_FLAG,
    TARGET_EXP_TYPE_CLASS,
    TARGET_EXP_ORG_ID,
    TARGET_EXP_TYPE,
    TARGET_COST_TYPE,
    OFFSET_EXP_TYPE_CLASS,
    OFFSET_EXP_ORG_ID,
    OFFSET_EXP_TYPE,
    OFFSET_COST_TYPE,
    OFFSET_METHOD,
    OFFSET_PROJECT_ID,
    OFFSET_TASK_ID,
    BASIS_METHOD,
    BASIS_RELATIVE_PERIOD,
    BASIS_AMOUNT_TYPE,
    BASIS_BALANCE_CATEGORY,
    BASIS_BUDGET_TYPE_CODE,
    BASIS_FIN_PLAN_TYPE_ID, /* Bug 2619977 */
    BASIS_BUDGET_ENTRY_METHOD_CODE,
    BASIS_BALANCE_TYPE,
    BASIS_RESOURCE_LIST_ID,
    SOURCE_EXTN_FLAG,
    TARGET_EXTN_FLAG,
    FIXED_AMOUNT,
    START_DATE_ACTIVE,
    END_DATE_ACTIVE,
    ATTRIBUTE_CATEGORY,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    ATTRIBUTE5,
    ATTRIBUTE6,
    ATTRIBUTE7,
    ATTRIBUTE8,
    ATTRIBUTE9,
    ATTRIBUTE10,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LIMIT_TARGET_PROJECTS_CODE ,

	  /* FP.M : Allocation Impact : 3512552 */
	ALLOC_RESOURCE_STRUCT_TYPE ,
    BASIS_RESOURCE_STRUCT_TYPE ,
    ALLOC_RBS_VERSION  ,
    BASIS_RBS_VERSION ,
    ORG_ID

  ) values (
    X_RULE_ID,
    X_RULE_NAME,
    X_DESCRIPTION,
    X_POOL_PERCENT,
    X_PERIOD_TYPE,
    X_SOURCE_AMOUNT_TYPE,
    X_SOURCE_BALANCE_CATEGORY,
    X_SOURCE_BALANCE_TYPE,
    X_ALLOC_RESOURCE_LIST_ID,
    X_AUTO_RELEASE_FLAG,
    X_ALLOCATION_METHOD,
    X_IMP_WITH_EXCEPTION,
    X_DUP_TARGETS_FLAG,
    X_TARGET_EXP_TYPE_CLASS,
    X_TARGET_EXP_ORG_ID,
    X_TARGET_EXP_TYPE,
    X_TARGET_COST_TYPE,
    X_OFFSET_EXP_TYPE_CLASS,
    X_OFFSET_EXP_ORG_ID,
    X_OFFSET_EXP_TYPE,
    X_OFFSET_COST_TYPE,
    X_OFFSET_METHOD,
    X_OFFSET_PROJECT_ID,
    X_OFFSET_TASK_ID,
    X_BASIS_METHOD,
    X_BASIS_RELATIVE_PERIOD,
    X_BASIS_AMOUNT_TYPE,
    X_BASIS_BALANCE_CATEGORY,
    X_BASIS_BUDGET_TYPE_CODE,
    X_BASIS_FIN_PLAN_TYPE_ID, /* Bug 2619977 */
    X_BAS_BUDGET_ENTRY_METHOD_CODE,
    X_BASIS_BALANCE_TYPE,
    X_BASIS_RESOURCE_LIST_ID,
    X_SOURCE_EXTN_FLAG,
    X_TARGET_EXTN_FLAG,
    X_FIXED_AMOUNT,
    X_START_DATE_ACTIVE,
    X_END_DATE_ACTIVE,
    X_ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE1,
    X_ATTRIBUTE2,
    X_ATTRIBUTE3,
    X_ATTRIBUTE4,
    X_ATTRIBUTE5,
    X_ATTRIBUTE6,
    X_ATTRIBUTE7,
    X_ATTRIBUTE8,
    X_ATTRIBUTE9,
    X_ATTRIBUTE10,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_LIMIT_TARGET_PROJECTS_CODE ,

	/* FP.M : Allocation Impact : 3512552 */
	X_ALLOC_RESOURCE_STRUCT_TYPE ,
    X_BASIS_RESOURCE_STRUCT_TYPE ,
    X_ALLOC_RBS_VERSION  ,
    X_BASIS_RBS_VERSION ,
    X_ORG_ID
  );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_RULE_ID in NUMBER,
  X_RULE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_POOL_PERCENT in NUMBER,
  X_PERIOD_TYPE in VARCHAR2,
  X_SOURCE_AMOUNT_TYPE in VARCHAR2,
  X_SOURCE_BALANCE_CATEGORY in VARCHAR2,
  X_SOURCE_BALANCE_TYPE in VARCHAR2,
  X_ALLOC_RESOURCE_LIST_ID in NUMBER,
  X_AUTO_RELEASE_FLAG in VARCHAR2,
  X_ALLOCATION_METHOD in VARCHAR2,
  X_IMP_WITH_EXCEPTION in VARCHAR2,
  X_DUP_TARGETS_FLAG in VARCHAR2,
  X_TARGET_EXP_TYPE_CLASS in VARCHAR2,
  X_TARGET_EXP_ORG_ID in NUMBER,
  X_TARGET_EXP_TYPE in VARCHAR2,
  X_TARGET_COST_TYPE in VARCHAR2,
  X_OFFSET_EXP_TYPE_CLASS in VARCHAR2,
  X_OFFSET_EXP_ORG_ID in NUMBER,
  X_OFFSET_EXP_TYPE in VARCHAR2,
  X_OFFSET_COST_TYPE in VARCHAR2,
  X_OFFSET_METHOD in VARCHAR2,
  X_OFFSET_PROJECT_ID in NUMBER,
  X_OFFSET_TASK_ID in NUMBER,
  X_BASIS_METHOD in VARCHAR2,
  X_BASIS_RELATIVE_PERIOD in NUMBER,
  X_BASIS_AMOUNT_TYPE in VARCHAR2,
  X_BASIS_BALANCE_CATEGORY in VARCHAR2,
  X_BASIS_BUDGET_TYPE_CODE in VARCHAR2,
  X_BAS_BUDGET_ENTRY_METHOD_CODE in VARCHAR2,
  X_BASIS_BALANCE_TYPE in VARCHAR2,
  X_BASIS_RESOURCE_LIST_ID in NUMBER,
  X_SOURCE_EXTN_FLAG in VARCHAR2,
  X_TARGET_EXTN_FLAG in VARCHAR2,
  X_FIXED_AMOUNT in NUMBER,
  X_START_DATE_ACTIVE in DATE,
  X_END_DATE_ACTIVE in DATE,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_LIMIT_TARGET_PROJECTS_CODE  varchar2,
  X_BASIS_FIN_PLAN_TYPE_ID in NUMBER /* Bug 2619977 */ ,

  /* FP.M : Allocation Impact : 3512552 */
  X_ALLOC_RESOURCE_STRUCT_TYPE In Varchar2 ,
  X_BASIS_RESOURCE_STRUCT_TYPE In Varchar2 ,
  X_ALLOC_RBS_VERSION In Number ,
  X_BASIS_RBS_VERSION In Number


) is
  cursor c1 is select
      RULE_NAME,
      DESCRIPTION,
      POOL_PERCENT,
      PERIOD_TYPE,
      SOURCE_AMOUNT_TYPE,
      SOURCE_BALANCE_CATEGORY,
      SOURCE_BALANCE_TYPE,
      ALLOC_RESOURCE_LIST_ID,
      AUTO_RELEASE_FLAG,
      ALLOCATION_METHOD,
      IMP_WITH_EXCEPTION,
      DUP_TARGETS_FLAG,
      TARGET_EXP_TYPE_CLASS,
      TARGET_EXP_ORG_ID,
      TARGET_EXP_TYPE,
      TARGET_COST_TYPE,
      OFFSET_EXP_TYPE_CLASS,
      OFFSET_EXP_ORG_ID,
      OFFSET_EXP_TYPE,
      OFFSET_COST_TYPE,
      OFFSET_METHOD,
      OFFSET_PROJECT_ID,
      OFFSET_TASK_ID,
      BASIS_METHOD,
      BASIS_RELATIVE_PERIOD,
      BASIS_AMOUNT_TYPE,
      BASIS_BALANCE_CATEGORY,
      BASIS_BUDGET_TYPE_CODE,
      BASIS_FIN_PLAN_TYPE_ID, /*Bug 2619977 */
      BASIS_BUDGET_ENTRY_METHOD_CODE,
      BASIS_BALANCE_TYPE,
      BASIS_RESOURCE_LIST_ID,
      SOURCE_EXTN_FLAG,
      TARGET_EXTN_FLAG,
      FIXED_AMOUNT,
      START_DATE_ACTIVE,
      END_DATE_ACTIVE,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      LIMIT_TARGET_PROJECTS_CODE ,
	    /* FP.M : Allocation Impact : 3512552 */
	  ALLOC_RESOURCE_STRUCT_TYPE ,
	  BASIS_RESOURCE_STRUCT_TYPE ,
	  ALLOC_RBS_VERSION  ,
	  BASIS_RBS_VERSION

    from PA_ALLOC_RULES_ALL
    where RULE_ID = X_RULE_ID
    for update of RULE_ID nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
    close c1;
    return;
  end if;
  close c1;

  if ( (tlinfo.RULE_NAME = X_RULE_NAME)
      AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
           OR ((tlinfo.DESCRIPTION is null)
               AND (X_DESCRIPTION is null)))
      AND ((tlinfo.POOL_PERCENT = X_POOL_PERCENT)
           OR ((tlinfo.POOL_PERCENT is null)
               AND (X_POOL_PERCENT is null)))
      AND ((tlinfo.PERIOD_TYPE = X_PERIOD_TYPE)
           OR ((tlinfo.PERIOD_TYPE is null)
               AND (X_PERIOD_TYPE is null)))
      AND ((tlinfo.SOURCE_AMOUNT_TYPE = X_SOURCE_AMOUNT_TYPE)
           OR ((tlinfo.SOURCE_AMOUNT_TYPE is null)
               AND (X_SOURCE_AMOUNT_TYPE is null)))
      AND ((tlinfo.SOURCE_BALANCE_CATEGORY = X_SOURCE_BALANCE_CATEGORY)
           OR ((tlinfo.SOURCE_BALANCE_CATEGORY is null)
               AND (X_SOURCE_BALANCE_CATEGORY is null)))
      AND ((tlinfo.SOURCE_BALANCE_TYPE = X_SOURCE_BALANCE_TYPE)
           OR ((tlinfo.SOURCE_BALANCE_TYPE is null)
               AND (X_SOURCE_BALANCE_TYPE is null)))
      AND ((tlinfo.ALLOC_RESOURCE_LIST_ID = X_ALLOC_RESOURCE_LIST_ID)
           OR ((tlinfo.ALLOC_RESOURCE_LIST_ID is null)
               AND (X_ALLOC_RESOURCE_LIST_ID is null)))
      AND ((tlinfo.AUTO_RELEASE_FLAG = X_AUTO_RELEASE_FLAG)
           OR ((tlinfo.AUTO_RELEASE_FLAG is null)
               AND (X_AUTO_RELEASE_FLAG is null)))
      AND ((tlinfo.ALLOCATION_METHOD = X_ALLOCATION_METHOD)
           OR ((tlinfo.ALLOCATION_METHOD is null)
               AND (X_ALLOCATION_METHOD is null)))
      AND ((tlinfo.IMP_WITH_EXCEPTION = X_IMP_WITH_EXCEPTION)
           OR ((tlinfo.IMP_WITH_EXCEPTION is null)
               AND (X_IMP_WITH_EXCEPTION is null)))
      AND ((tlinfo.DUP_TARGETS_FLAG = X_DUP_TARGETS_FLAG)
           OR ((tlinfo.DUP_TARGETS_FLAG is null)
               AND (X_DUP_TARGETS_FLAG is null)))
      AND ((tlinfo.TARGET_EXP_TYPE_CLASS = X_TARGET_EXP_TYPE_CLASS)
           OR ((tlinfo.TARGET_EXP_TYPE_CLASS is null)
               AND (X_TARGET_EXP_TYPE_CLASS is null)))
      AND ((tlinfo.TARGET_EXP_ORG_ID = X_TARGET_EXP_ORG_ID)
           OR ((tlinfo.TARGET_EXP_ORG_ID is null)
               AND (X_TARGET_EXP_ORG_ID is null)))
      AND ((tlinfo.TARGET_EXP_TYPE = X_TARGET_EXP_TYPE)
           OR ((tlinfo.TARGET_EXP_TYPE is null)
               AND (X_TARGET_EXP_TYPE is null)))
      AND ((tlinfo.TARGET_COST_TYPE = X_TARGET_COST_TYPE)
           OR ((tlinfo.TARGET_COST_TYPE is null)
               AND (X_TARGET_COST_TYPE is null)))
      AND ((tlinfo.OFFSET_EXP_TYPE_CLASS = X_OFFSET_EXP_TYPE_CLASS)
           OR ((tlinfo.OFFSET_EXP_TYPE_CLASS is null)
               AND (X_OFFSET_EXP_TYPE_CLASS is null)))
      AND ((tlinfo.OFFSET_EXP_ORG_ID = X_OFFSET_EXP_ORG_ID)
           OR ((tlinfo.OFFSET_EXP_ORG_ID is null)
               AND (X_OFFSET_EXP_ORG_ID is null)))
      AND ((tlinfo.OFFSET_EXP_TYPE = X_OFFSET_EXP_TYPE)
           OR ((tlinfo.OFFSET_EXP_TYPE is null)
               AND (X_OFFSET_EXP_TYPE is null)))
      AND ((tlinfo.OFFSET_COST_TYPE = X_OFFSET_COST_TYPE)
           OR ((tlinfo.OFFSET_COST_TYPE is null)
               AND (X_OFFSET_COST_TYPE is null)))
      AND ((tlinfo.OFFSET_METHOD = X_OFFSET_METHOD)
           OR ((tlinfo.OFFSET_METHOD is null)
               AND (X_OFFSET_METHOD is null)))
      AND ((tlinfo.OFFSET_PROJECT_ID = X_OFFSET_PROJECT_ID)
           OR ((tlinfo.OFFSET_PROJECT_ID is null)
               AND (X_OFFSET_PROJECT_ID is null)))
      AND ((tlinfo.OFFSET_TASK_ID = X_OFFSET_TASK_ID)
           OR ((tlinfo.OFFSET_TASK_ID is null)
               AND (X_OFFSET_TASK_ID is null)))
      AND ((tlinfo.BASIS_METHOD = X_BASIS_METHOD)
           OR ((tlinfo.BASIS_METHOD is null)
               AND (X_BASIS_METHOD is null)))
      AND ((tlinfo.BASIS_RELATIVE_PERIOD = X_BASIS_RELATIVE_PERIOD)
           OR ((tlinfo.BASIS_RELATIVE_PERIOD is null)
               AND (X_BASIS_RELATIVE_PERIOD is null)))
      AND ((tlinfo.BASIS_AMOUNT_TYPE = X_BASIS_AMOUNT_TYPE)
           OR ((tlinfo.BASIS_AMOUNT_TYPE is null)
               AND (X_BASIS_AMOUNT_TYPE is null)))
      AND ((tlinfo.BASIS_BALANCE_CATEGORY = X_BASIS_BALANCE_CATEGORY)
           OR ((tlinfo.BASIS_BALANCE_CATEGORY is null)
               AND (X_BASIS_BALANCE_CATEGORY is null)))
      AND ((tlinfo.BASIS_BUDGET_TYPE_CODE = X_BASIS_BUDGET_TYPE_CODE)
           OR ((tlinfo.BASIS_BUDGET_TYPE_CODE is null)
               AND (X_BASIS_BUDGET_TYPE_CODE is null)))
 /* Next 3 lines added for bug 2619977 */
      AND ((tlinfo.BASIS_FIN_PLAN_TYPE_ID = X_BASIS_FIN_PLAN_TYPE_ID)
           OR ((tlinfo.BASIS_FIN_PLAN_TYPE_ID is null)
               AND (X_BASIS_FIN_PLAN_TYPE_ID is null)))
	AND ((tlinfo.BASIS_BUDGET_ENTRY_METHOD_CODE = X_BAS_BUDGET_ENTRY_METHOD_CODE)
           OR ((tlinfo.BASIS_BUDGET_ENTRY_METHOD_CODE is null)
               AND (X_BAS_BUDGET_ENTRY_METHOD_CODE is null)))
      AND ((tlinfo.BASIS_BALANCE_TYPE = X_BASIS_BALANCE_TYPE)
           OR ((tlinfo.BASIS_BALANCE_TYPE is null)
               AND (X_BASIS_BALANCE_TYPE is null)))
      AND ((tlinfo.BASIS_RESOURCE_LIST_ID = X_BASIS_RESOURCE_LIST_ID)
           OR ((tlinfo.BASIS_RESOURCE_LIST_ID is null)
               AND (X_BASIS_RESOURCE_LIST_ID is null)))
      AND ((tlinfo.SOURCE_EXTN_FLAG = X_SOURCE_EXTN_FLAG)
           OR ((tlinfo.SOURCE_EXTN_FLAG is null)
               AND (X_SOURCE_EXTN_FLAG is null)))
      AND ((tlinfo.TARGET_EXTN_FLAG = X_TARGET_EXTN_FLAG)
           OR ((tlinfo.TARGET_EXTN_FLAG is null)
               AND (X_TARGET_EXTN_FLAG is null)))
      AND ((tlinfo.FIXED_AMOUNT = X_FIXED_AMOUNT)
           OR ((tlinfo.FIXED_AMOUNT is null)
               AND (X_FIXED_AMOUNT is null)))
      AND ((tlinfo.START_DATE_ACTIVE = X_START_DATE_ACTIVE)
           OR ((tlinfo.START_DATE_ACTIVE is null)
               AND (X_START_DATE_ACTIVE is null)))
      AND ((tlinfo.END_DATE_ACTIVE = X_END_DATE_ACTIVE)
           OR ((tlinfo.END_DATE_ACTIVE is null)
               AND (X_END_DATE_ACTIVE is null)))
      AND ((tlinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
           OR ((tlinfo.ATTRIBUTE_CATEGORY is null)
               AND (X_ATTRIBUTE_CATEGORY is null)))
      AND ((tlinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
           OR ((tlinfo.ATTRIBUTE1 is null)
               AND (X_ATTRIBUTE1 is null)))
      AND ((tlinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
           OR ((tlinfo.ATTRIBUTE2 is null)
               AND (X_ATTRIBUTE2 is null)))
      AND ((tlinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
           OR ((tlinfo.ATTRIBUTE3 is null)
               AND (X_ATTRIBUTE3 is null)))
      AND ((tlinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
           OR ((tlinfo.ATTRIBUTE4 is null)
               AND (X_ATTRIBUTE4 is null)))
      AND ((tlinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
           OR ((tlinfo.ATTRIBUTE5 is null)
               AND (X_ATTRIBUTE5 is null)))
      AND ((tlinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
           OR ((tlinfo.ATTRIBUTE6 is null)
               AND (X_ATTRIBUTE6 is null)))
      AND ((tlinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
           OR ((tlinfo.ATTRIBUTE7 is null)
               AND (X_ATTRIBUTE7 is null)))
      AND ((tlinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
           OR ((tlinfo.ATTRIBUTE8 is null)
               AND (X_ATTRIBUTE8 is null)))
      AND ((tlinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
           OR ((tlinfo.ATTRIBUTE9 is null)
               AND (X_ATTRIBUTE9 is null)))
      AND ((tlinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
           OR ((tlinfo.ATTRIBUTE10 is null)
               AND (X_ATTRIBUTE10 is null)))
      AND ((tlinfo.LIMIT_TARGET_PROJECTS_CODE = X_LIMIT_TARGET_PROJECTS_CODE)
           OR ((tlinfo.LIMIT_TARGET_PROJECTS_CODE is null)
               AND (X_LIMIT_TARGET_PROJECTS_CODE is null)))

	  /* FP.M : Allocation Impact : 3512552 */
	  AND ((tlinfo.ALLOC_RESOURCE_STRUCT_TYPE = X_ALLOC_RESOURCE_STRUCT_TYPE)
           OR ((tlinfo.ALLOC_RESOURCE_STRUCT_TYPE is null)
               AND (X_ALLOC_RESOURCE_STRUCT_TYPE is null)))
      AND ((tlinfo.BASIS_RESOURCE_STRUCT_TYPE = X_BASIS_RESOURCE_STRUCT_TYPE)
           OR ((tlinfo.BASIS_RESOURCE_STRUCT_TYPE is null)
               AND (X_BASIS_RESOURCE_STRUCT_TYPE is null)))
      AND ((tlinfo.ALLOC_RBS_VERSION = X_ALLOC_RBS_VERSION)
           OR ((tlinfo.ALLOC_RBS_VERSION is null)
               AND (X_ALLOC_RBS_VERSION is null)))
      AND ((tlinfo.BASIS_RBS_VERSION = X_BASIS_RBS_VERSION)
           OR ((tlinfo.BASIS_RBS_VERSION is null)
               AND (X_BASIS_RBS_VERSION is null)))


  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_RULE_ID 			in NUMBER,
  X_RULE_NAME			in VARCHAR2,
  X_DESCRIPTION 		in VARCHAR2,
  X_POOL_PERCENT 		in NUMBER,
  X_PERIOD_TYPE 		in VARCHAR2,
  X_SOURCE_AMOUNT_TYPE 		in VARCHAR2,
  X_SOURCE_BALANCE_CATEGORY 	in VARCHAR2,
  X_SOURCE_BALANCE_TYPE 	in VARCHAR2,
  X_ALLOC_RESOURCE_LIST_ID 	in NUMBER,
  X_AUTO_RELEASE_FLAG 		in VARCHAR2,
  X_ALLOCATION_METHOD 		in VARCHAR2,
  X_IMP_WITH_EXCEPTION 		in VARCHAR2,
  X_DUP_TARGETS_FLAG 		in VARCHAR2,
  X_TARGET_EXP_TYPE_CLASS 	in VARCHAR2,
  X_TARGET_EXP_ORG_ID 		in NUMBER,
  X_TARGET_EXP_TYPE 		in VARCHAR2,
  X_TARGET_COST_TYPE 		in VARCHAR2,
  X_OFFSET_EXP_TYPE_CLASS 	in VARCHAR2,
  X_OFFSET_EXP_ORG_ID 		in NUMBER,
  X_OFFSET_EXP_TYPE 		in VARCHAR2,
  X_OFFSET_COST_TYPE 		in VARCHAR2,
  X_OFFSET_METHOD 		in VARCHAR2,
  X_OFFSET_PROJECT_ID 		in NUMBER,
  X_OFFSET_TASK_ID 		in NUMBER,
  X_BASIS_METHOD 		      in VARCHAR2,
  X_BASIS_RELATIVE_PERIOD	in NUMBER,
  X_BASIS_AMOUNT_TYPE 		in VARCHAR2,
  X_BASIS_BALANCE_CATEGORY 	in VARCHAR2,
  X_BASIS_BUDGET_TYPE_CODE 	in VARCHAR2,
  X_BAS_BUDGET_ENTRY_METHOD_CODE in VARCHAR2,
  X_BASIS_BALANCE_TYPE 		in VARCHAR2,
  X_BASIS_RESOURCE_LIST_ID 	in NUMBER,
  X_SOURCE_EXTN_FLAG 		in VARCHAR2,
  X_TARGET_EXTN_FLAG 		in VARCHAR2,
  X_FIXED_AMOUNT 		      in NUMBER,
  X_START_DATE_ACTIVE 		in DATE,
  X_END_DATE_ACTIVE 		in DATE,
  X_ATTRIBUTE_CATEGORY 		in VARCHAR2,
  X_ATTRIBUTE1 			in VARCHAR2,
  X_ATTRIBUTE2 			in VARCHAR2,
  X_ATTRIBUTE3 			in VARCHAR2,
  X_ATTRIBUTE4 			in VARCHAR2,
  X_ATTRIBUTE5 			in VARCHAR2,
  X_ATTRIBUTE6 			in VARCHAR2,
  X_ATTRIBUTE7 			in VARCHAR2,
  X_ATTRIBUTE8 			in VARCHAR2,
  X_ATTRIBUTE9 			in VARCHAR2,
  X_ATTRIBUTE10 		in VARCHAR2,
  X_LAST_UPDATE_DATE		in DATE,
  X_LAST_UPDATED_BY		in NUMBER,
  X_LAST_UPDATE_LOGIN		in NUMBER,
  X_LIMIT_TARGET_PROJECTS_CODE varchar2,
  X_BASIS_FIN_PLAN_TYPE_ID      in NUMBER /* Bug 2619977 */ ,

  /* FP.M : Allocation Impact : 3512552 */
  X_ALLOC_RESOURCE_STRUCT_TYPE In Varchar2 ,
  X_BASIS_RESOURCE_STRUCT_TYPE In Varchar2 ,
  X_ALLOC_RBS_VERSION In Number ,
  X_BASIS_RBS_VERSION In Number


  ) is
    begin

  update PA_ALLOC_RULES_ALL set
    RULE_NAME = X_RULE_NAME,
    DESCRIPTION = X_DESCRIPTION,
    POOL_PERCENT = X_POOL_PERCENT,
    PERIOD_TYPE = X_PERIOD_TYPE,
    SOURCE_AMOUNT_TYPE = X_SOURCE_AMOUNT_TYPE,
    SOURCE_BALANCE_CATEGORY = X_SOURCE_BALANCE_CATEGORY,
    SOURCE_BALANCE_TYPE = X_SOURCE_BALANCE_TYPE,
    ALLOC_RESOURCE_LIST_ID = X_ALLOC_RESOURCE_LIST_ID,
    AUTO_RELEASE_FLAG = X_AUTO_RELEASE_FLAG,
    ALLOCATION_METHOD = X_ALLOCATION_METHOD,
    IMP_WITH_EXCEPTION = X_IMP_WITH_EXCEPTION,
    DUP_TARGETS_FLAG = X_DUP_TARGETS_FLAG,
    TARGET_EXP_TYPE_CLASS = X_TARGET_EXP_TYPE_CLASS,
    TARGET_EXP_ORG_ID = X_TARGET_EXP_ORG_ID,
    TARGET_EXP_TYPE = X_TARGET_EXP_TYPE,
    TARGET_COST_TYPE = X_TARGET_COST_TYPE,
    OFFSET_EXP_TYPE_CLASS = X_OFFSET_EXP_TYPE_CLASS,
    OFFSET_EXP_ORG_ID = X_OFFSET_EXP_ORG_ID,
    OFFSET_EXP_TYPE = X_OFFSET_EXP_TYPE,
    OFFSET_COST_TYPE = X_OFFSET_COST_TYPE,
    OFFSET_METHOD = X_OFFSET_METHOD,
    OFFSET_PROJECT_ID = X_OFFSET_PROJECT_ID,
    OFFSET_TASK_ID = X_OFFSET_TASK_ID,
    BASIS_METHOD = X_BASIS_METHOD,
    BASIS_RELATIVE_PERIOD = X_BASIS_RELATIVE_PERIOD,
    BASIS_AMOUNT_TYPE = X_BASIS_AMOUNT_TYPE,
    BASIS_BALANCE_CATEGORY = X_BASIS_BALANCE_CATEGORY,
    BASIS_BUDGET_TYPE_CODE = X_BASIS_BUDGET_TYPE_CODE,
    BASIS_FIN_PLAN_TYPE_ID = X_BASIS_FIN_PLAN_TYPE_ID, /* Bug 2619977 */
    BASIS_BUDGET_ENTRY_METHOD_CODE = X_BAS_BUDGET_ENTRY_METHOD_CODE,
    BASIS_BALANCE_TYPE = X_BASIS_BALANCE_TYPE,
    BASIS_RESOURCE_LIST_ID = X_BASIS_RESOURCE_LIST_ID,
    SOURCE_EXTN_FLAG = X_SOURCE_EXTN_FLAG,
    TARGET_EXTN_FLAG = X_TARGET_EXTN_FLAG,
    FIXED_AMOUNT = X_FIXED_AMOUNT,
    START_DATE_ACTIVE = X_START_DATE_ACTIVE,
    END_DATE_ACTIVE = X_END_DATE_ACTIVE,
    ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
    ATTRIBUTE1 = X_ATTRIBUTE1,
    ATTRIBUTE2 = X_ATTRIBUTE2,
    ATTRIBUTE3 = X_ATTRIBUTE3,
    ATTRIBUTE4 = X_ATTRIBUTE4,
    ATTRIBUTE5 = X_ATTRIBUTE5,
    ATTRIBUTE6 = X_ATTRIBUTE6,
    ATTRIBUTE7 = X_ATTRIBUTE7,
    ATTRIBUTE8 = X_ATTRIBUTE8,
    ATTRIBUTE9 = X_ATTRIBUTE9,
    ATTRIBUTE10 = X_ATTRIBUTE10,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    LIMIT_TARGET_PROJECTS_CODE=X_LIMIT_TARGET_PROJECTS_CODE ,

	/* FP.M : Allocation Impact : 3512552 */

	ALLOC_RESOURCE_STRUCT_TYPE = X_ALLOC_RESOURCE_STRUCT_TYPE ,
	BASIS_RESOURCE_STRUCT_TYPE = X_BASIS_RESOURCE_STRUCT_TYPE ,
	ALLOC_RBS_VERSION = X_ALLOC_RBS_VERSION  ,
	BASIS_RBS_VERSION = X_BASIS_RBS_VERSION

  where RULE_ID = X_RULE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

procedure DELETE_ROW (
  X_RULE_ID in NUMBER
) is
begin
  delete from PA_ALLOC_RULES_ALL
  where RULE_ID = X_RULE_ID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

/* Bug 2573742 Begins */

  delete from PA_ALLOC_SOURCE_LINES
  where  RULE_ID = X_RULE_ID;

  delete from PA_ALLOC_TARGET_LINES
  where  RULE_ID = X_RULE_ID;

  delete from PA_ALLOC_GL_LINES
  where  RULE_ID = X_RULE_ID;

  delete from PA_ALLOC_RESOURCES
  where  RULE_ID = X_RULE_ID;

/* Bug 2573742 Ends */

end DELETE_ROW;

end PA_ALLOC_RULES_ALL_PKG;

/
