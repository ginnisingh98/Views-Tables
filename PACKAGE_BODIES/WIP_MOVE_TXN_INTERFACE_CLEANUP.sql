--------------------------------------------------------
--  DDL for Package Body WIP_MOVE_TXN_INTERFACE_CLEANUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_MOVE_TXN_INTERFACE_CLEANUP" AS
/* $Header: wipmvclb.pls 115.7 2002/11/28 13:38:40 rmahidha ship $ */

  procedure fetch_and_delete(
    p_grp_id in     number,
    p_moves  in out nocopy wip_move_txn_interface_rec) is

    i number := 0;

    cursor get_moves(c_grp_id number) is
    select
      TRANSACTION_ID,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATED_BY_NAME,
      CREATION_DATE,
      CREATED_BY,
      CREATED_BY_NAME,
      LAST_UPDATE_LOGIN,
      REQUEST_ID,
      PROGRAM_APPLICATION_ID,
      PROGRAM_ID,
      PROGRAM_UPDATE_DATE,
      GROUP_ID,
      SOURCE_CODE,
      SOURCE_LINE_ID,
      PROCESS_PHASE,
      PROCESS_STATUS,
      TRANSACTION_TYPE,
      ORGANIZATION_ID,
      ORGANIZATION_CODE,
      WIP_ENTITY_ID,
      WIP_ENTITY_NAME,
      ENTITY_TYPE,
      PRIMARY_ITEM_ID,
      LINE_ID,
      LINE_CODE,
      REPETITIVE_SCHEDULE_ID,
      TRANSACTION_DATE,
      ACCT_PERIOD_ID,
      FM_OPERATION_SEQ_NUM,
      FM_OPERATION_CODE,
      FM_DEPARTMENT_ID,
      FM_DEPARTMENT_CODE,
      FM_INTRAOPERATION_STEP_TYPE,
      TO_OPERATION_SEQ_NUM,
      TO_OPERATION_CODE,
      TO_DEPARTMENT_ID,
      TO_DEPARTMENT_CODE,
      TO_INTRAOPERATION_STEP_TYPE,
      TRANSACTION_QUANTITY,
      TRANSACTION_UOM,
      PRIMARY_QUANTITY,
      PRIMARY_UOM,
      SCRAP_ACCOUNT_ID,
      REASON_ID,
      REASON_NAME,
      REFERENCE,
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
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      qa_collection_id,
      overcompletion_transaction_id,
      overcompletion_transaction_qty,
      overcompletion_primary_qty
    from wip_move_txn_interface
    where group_id = c_grp_id;

    move_rec get_moves%rowtype;
  begin
    -- initialize
    if (p_moves.numrecs is NULL) then
      -- p_moves is empty
      p_moves.numrecs := i;
    else
      -- p_moves already has records
      i := p_moves.numrecs;
    end if;

    open get_moves(c_grp_id => p_grp_id);

    loop
      fetch get_moves into move_rec;

      exit when (get_moves%NOTFOUND);

      i := i + 1;
      p_moves.numrecs := i;
      p_moves.TRANSACTION_ID(i) := move_rec.TRANSACTION_ID;
      p_moves.LAST_UPDATE_DATE(i) := move_rec.LAST_UPDATE_DATE;
      p_moves.LAST_UPDATED_BY(i) := move_rec.LAST_UPDATED_BY;
      p_moves.LAST_UPDATED_BY_NAME(i) := move_rec.LAST_UPDATED_BY_NAME;
      p_moves.CREATION_DATE(i) := move_rec.CREATION_DATE;
      p_moves.CREATED_BY(i) := move_rec.CREATED_BY;
      p_moves.CREATED_BY_NAME(i) := move_rec.CREATED_BY_NAME;
      p_moves.LAST_UPDATE_LOGIN(i) := move_rec.LAST_UPDATE_LOGIN;
      p_moves.REQUEST_ID(i) := move_rec.REQUEST_ID;
      p_moves.PROGRAM_APPLICATION_ID(i) := move_rec.PROGRAM_APPLICATION_ID;
      p_moves.PROGRAM_ID(i) := move_rec.PROGRAM_ID;
      p_moves.PROGRAM_UPDATE_DATE(i) := move_rec.PROGRAM_UPDATE_DATE;
      p_moves.GROUP_ID(i) := move_rec.GROUP_ID;
      p_moves.SOURCE_CODE(i) := move_rec.SOURCE_CODE;
      p_moves.SOURCE_LINE_ID(i) := move_rec.SOURCE_LINE_ID;
      p_moves.PROCESS_PHASE(i) := move_rec.PROCESS_PHASE;
      p_moves.PROCESS_STATUS(i) := move_rec.PROCESS_STATUS;
      p_moves.TRANSACTION_TYPE(i) := move_rec.TRANSACTION_TYPE;
      p_moves.ORGANIZATION_ID(i) := move_rec.ORGANIZATION_ID;
      p_moves.ORGANIZATION_CODE(i) := move_rec.ORGANIZATION_CODE;
      p_moves.WIP_ENTITY_ID(i) := move_rec.WIP_ENTITY_ID;
      p_moves.WIP_ENTITY_NAME(i) := move_rec.WIP_ENTITY_NAME;
      p_moves.ENTITY_TYPE(i) := move_rec.ENTITY_TYPE;
      p_moves.PRIMARY_ITEM_ID(i) := move_rec.PRIMARY_ITEM_ID;
      p_moves.LINE_ID(i) := move_rec.LINE_ID;
      p_moves.LINE_CODE(i) := move_rec.LINE_CODE;
      p_moves.REPETITIVE_SCHEDULE_ID(i) := move_rec.REPETITIVE_SCHEDULE_ID;
      p_moves.TRANSACTION_DATE(i) := move_rec.TRANSACTION_DATE;
      p_moves.ACCT_PERIOD_ID(i) := move_rec.ACCT_PERIOD_ID;
      p_moves.FM_OPERATION_SEQ_NUM(i) := move_rec.FM_OPERATION_SEQ_NUM;
      p_moves.FM_OPERATION_CODE(i) := move_rec.FM_OPERATION_CODE;
      p_moves.FM_DEPARTMENT_ID(i) := move_rec.FM_DEPARTMENT_ID;
      p_moves.FM_DEPARTMENT_CODE(i) := move_rec.FM_DEPARTMENT_CODE;
      p_moves.FM_INTRAOPERATION_STEP_TYPE(i) := move_rec.FM_INTRAOPERATION_STEP_TYPE;
      p_moves.TO_OPERATION_SEQ_NUM(i) := move_rec.TO_OPERATION_SEQ_NUM;
      p_moves.TO_OPERATION_CODE(i) := move_rec.TO_OPERATION_CODE;
      p_moves.TO_DEPARTMENT_ID(i) := move_rec.TO_DEPARTMENT_ID;
      p_moves.TO_DEPARTMENT_CODE(i) := move_rec.TO_DEPARTMENT_CODE;
      p_moves.TO_INTRAOPERATION_STEP_TYPE(i) := move_rec.TO_INTRAOPERATION_STEP_TYPE;
      p_moves.TRANSACTION_QUANTITY(i) := move_rec.TRANSACTION_QUANTITY;
      p_moves.TRANSACTION_UOM(i) := move_rec.TRANSACTION_UOM;
      p_moves.PRIMARY_QUANTITY(i) := move_rec.PRIMARY_QUANTITY;
      p_moves.PRIMARY_UOM(i) := move_rec.PRIMARY_UOM;
      p_moves.SCRAP_ACCOUNT_ID(i) := move_rec.SCRAP_ACCOUNT_ID;
      p_moves.REASON_ID(i) := move_rec.REASON_ID;
      p_moves.REASON_NAME(i) := move_rec.REASON_NAME;
      p_moves.REFERENCE(i) := move_rec.REFERENCE;
      p_moves.ATTRIBUTE_CATEGORY(i) := move_rec.ATTRIBUTE_CATEGORY;
      p_moves.ATTRIBUTE1(i) := move_rec.ATTRIBUTE1;
      p_moves.ATTRIBUTE2(i) := move_rec.ATTRIBUTE2;
      p_moves.ATTRIBUTE3(i) := move_rec.ATTRIBUTE3;
      p_moves.ATTRIBUTE4(i) := move_rec.ATTRIBUTE4;
      p_moves.ATTRIBUTE5(i) := move_rec.ATTRIBUTE5;
      p_moves.ATTRIBUTE6(i) := move_rec.ATTRIBUTE6;
      p_moves.ATTRIBUTE7(i) := move_rec.ATTRIBUTE7;
      p_moves.ATTRIBUTE8(i) := move_rec.ATTRIBUTE8;
      p_moves.ATTRIBUTE9(i) := move_rec.ATTRIBUTE9;
      p_moves.ATTRIBUTE10(i) := move_rec.ATTRIBUTE10;
      p_moves.ATTRIBUTE11(i) := move_rec.ATTRIBUTE11;
      p_moves.ATTRIBUTE12(i) := move_rec.ATTRIBUTE12;
      p_moves.ATTRIBUTE13(i) := move_rec.ATTRIBUTE13;
      p_moves.ATTRIBUTE14(i) := move_rec.ATTRIBUTE14;
      p_moves.ATTRIBUTE15(i) := move_rec.ATTRIBUTE15;
      p_moves.QA_COLLECTION_ID(i) := move_rec.QA_COLLECTION_ID;
      p_moves.overcompletion_transaction_id(i) := move_rec.overcompletion_transaction_id;
      p_moves.overcompletion_transaction_qty(i) := move_rec.overcompletion_transaction_qty;
      p_moves.overcompletion_primary_qty(i) := move_rec.overcompletion_primary_qty;
    end loop;

    close get_moves;

    if (p_moves.numrecs > 0) then
      delete from wip_move_txn_interface
      where group_id = p_grp_id;
    end if;
  end fetch_and_delete;

  procedure insert_rows(
    p_moves in wip_move_txn_interface_rec) is
    i number := 1;
  begin
    while (i <= nvl(p_moves.numrecs, 0)) loop
      insert into wip_move_txn_interface (
        TRANSACTION_ID,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATED_BY_NAME,
        CREATION_DATE,
        CREATED_BY,
        CREATED_BY_NAME,
        LAST_UPDATE_LOGIN,
        REQUEST_ID,
        PROGRAM_APPLICATION_ID,
        PROGRAM_ID,
        PROGRAM_UPDATE_DATE,
        GROUP_ID,
        SOURCE_CODE,
        SOURCE_LINE_ID,
        PROCESS_PHASE,
        PROCESS_STATUS,
        TRANSACTION_TYPE,
        ORGANIZATION_ID,
        ORGANIZATION_CODE,
        WIP_ENTITY_ID,
        WIP_ENTITY_NAME,
        ENTITY_TYPE,
        PRIMARY_ITEM_ID,
        LINE_ID,
        LINE_CODE,
        REPETITIVE_SCHEDULE_ID,
        TRANSACTION_DATE,
        ACCT_PERIOD_ID,
        FM_OPERATION_SEQ_NUM,
        FM_OPERATION_CODE,
        FM_DEPARTMENT_ID,
        FM_DEPARTMENT_CODE,
        FM_INTRAOPERATION_STEP_TYPE,
        TO_OPERATION_SEQ_NUM,
        TO_OPERATION_CODE,
        TO_DEPARTMENT_ID,
        TO_DEPARTMENT_CODE,
        TO_INTRAOPERATION_STEP_TYPE,
        TRANSACTION_QUANTITY,
        TRANSACTION_UOM,
        PRIMARY_QUANTITY,
        PRIMARY_UOM,
        SCRAP_ACCOUNT_ID,
        REASON_ID,
        REASON_NAME,
        REFERENCE,
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
        ATTRIBUTE11,
        ATTRIBUTE12,
        ATTRIBUTE13,
        ATTRIBUTE14,
        ATTRIBUTE15,
        qa_collection_id,
	overcompletion_transaction_id,
	overcompletion_transaction_qty,
	overcompletion_primary_qty
      ) values (
        p_moves.TRANSACTION_ID(i),
        p_moves.LAST_UPDATE_DATE(i),
        p_moves.LAST_UPDATED_BY(i),
        p_moves.LAST_UPDATED_BY_NAME(i),
        p_moves.CREATION_DATE(i),
        p_moves.CREATED_BY(i),
        p_moves.CREATED_BY_NAME(i),
        p_moves.LAST_UPDATE_LOGIN(i),
        p_moves.REQUEST_ID(i),
        p_moves.PROGRAM_APPLICATION_ID(i),
        p_moves.PROGRAM_ID(i),
        p_moves.PROGRAM_UPDATE_DATE(i),
        p_moves.GROUP_ID(i),
        p_moves.SOURCE_CODE(i),
        p_moves.SOURCE_LINE_ID(i),
        p_moves.PROCESS_PHASE(i),
        p_moves.PROCESS_STATUS(i),
        p_moves.TRANSACTION_TYPE(i),
        p_moves.ORGANIZATION_ID(i),
        p_moves.ORGANIZATION_CODE(i),
        p_moves.WIP_ENTITY_ID(i),
        p_moves.WIP_ENTITY_NAME(i),
        p_moves.ENTITY_TYPE(i),
        p_moves.PRIMARY_ITEM_ID(i),
        p_moves.LINE_ID(i),
        p_moves.LINE_CODE(i),
        p_moves.REPETITIVE_SCHEDULE_ID(i),
        p_moves.TRANSACTION_DATE(i),
        p_moves.ACCT_PERIOD_ID(i),
        p_moves.FM_OPERATION_SEQ_NUM(i),
        p_moves.FM_OPERATION_CODE(i),
        p_moves.FM_DEPARTMENT_ID(i),
        p_moves.FM_DEPARTMENT_CODE(i),
        p_moves.FM_INTRAOPERATION_STEP_TYPE(i),
        p_moves.TO_OPERATION_SEQ_NUM(i),
        p_moves.TO_OPERATION_CODE(i),
        p_moves.TO_DEPARTMENT_ID(i),
        p_moves.TO_DEPARTMENT_CODE(i),
        p_moves.TO_INTRAOPERATION_STEP_TYPE(i),
        p_moves.TRANSACTION_QUANTITY(i),
        p_moves.TRANSACTION_UOM(i),
        p_moves.PRIMARY_QUANTITY(i),
        p_moves.PRIMARY_UOM(i),
        p_moves.SCRAP_ACCOUNT_ID(i),
        p_moves.REASON_ID(i),
        p_moves.REASON_NAME(i),
        p_moves.REFERENCE(i),
        p_moves.ATTRIBUTE_CATEGORY(i),
        p_moves.ATTRIBUTE1(i),
        p_moves.ATTRIBUTE2(i),
        p_moves.ATTRIBUTE3(i),
        p_moves.ATTRIBUTE4(i),
        p_moves.ATTRIBUTE5(i),
        p_moves.ATTRIBUTE6(i),
        p_moves.ATTRIBUTE7(i),
        p_moves.ATTRIBUTE8(i),
        p_moves.ATTRIBUTE9(i),
        p_moves.ATTRIBUTE10(i),
        p_moves.ATTRIBUTE11(i),
        p_moves.ATTRIBUTE12(i),
        p_moves.ATTRIBUTE13(i),
        p_moves.ATTRIBUTE14(i),
        p_moves.ATTRIBUTE15(i),
        p_moves.QA_COLLECTION_ID(i),
	p_moves.overcompletion_transaction_id(i),
	p_moves.overcompletion_transaction_qty(i),
	p_moves.overcompletion_primary_qty(i)
      );

      i := i + 1;
    end loop;
  end insert_rows;

END WIP_MOVE_TXN_INTERFACE_CLEANUP;

/
