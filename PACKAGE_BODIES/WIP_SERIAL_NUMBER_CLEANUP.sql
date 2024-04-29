--------------------------------------------------------
--  DDL for Package Body WIP_SERIAL_NUMBER_CLEANUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_SERIAL_NUMBER_CLEANUP" AS
/* $Header: wipsnclb.pls 115.7 2002/12/03 12:05:51 simishra ship $ */

  procedure fetch_and_delete(
    p_grp_id  in     number,
    p_status  in     number,
    p_serials in out nocopy mtl_serial_numbers_rec) is

    i number := 0;

    cursor get_serials(
      c_grp_id number,
      c_status number) is
    select
    INVENTORY_ITEM_ID,
    SERIAL_NUMBER,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    REQUEST_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_ID,
    PROGRAM_UPDATE_DATE,
    INITIALIZATION_DATE,
    COMPLETION_DATE,
    SHIP_DATE,
    CURRENT_STATUS,
    REVISION,
    LOT_NUMBER,
    FIXED_ASSET_TAG,
    RESERVED_ORDER_ID,
    PARENT_ITEM_ID,
    PARENT_SERIAL_NUMBER,
    ORIGINAL_WIP_ENTITY_ID,
    ORIGINAL_UNIT_VENDOR_ID,
    VENDOR_SERIAL_NUMBER,
    VENDOR_LOT_NUMBER,
    LAST_TXN_SOURCE_TYPE_ID,
    LAST_TRANSACTION_ID,
    LAST_RECEIPT_ISSUE_TYPE,
    LAST_TXN_SOURCE_NAME,
    LAST_TXN_SOURCE_ID,
    DESCRIPTIVE_TEXT,
    CURRENT_SUBINVENTORY_CODE,
    CURRENT_LOCATOR_ID,
    CURRENT_ORGANIZATION_ID,
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
    GROUP_MARK_ID,
    LINE_MARK_ID,
    LOT_LINE_MARK_ID
    from mtl_serial_numbers
    where group_mark_id = c_grp_id
    and current_status = c_status;

    serial_rec get_serials%rowtype;
  begin
    -- initialize
    if (p_serials.numrecs is NULL) then
      -- p_serials is empty
      p_serials.numrecs := i;
    else
      -- p_serials already has records
      i := p_serials.numrecs;
    end if;

    open get_serials(
      c_grp_id => p_grp_id,
      c_status => p_status);

    loop
      fetch get_serials into serial_rec;

      exit when (get_serials%NOTFOUND);

      i := i + 1;
      p_serials.numrecs := i;
      p_serials.INVENTORY_ITEM_ID(i) := serial_rec.INVENTORY_ITEM_ID;
      p_serials.SERIAL_NUMBER(i) := serial_rec.SERIAL_NUMBER;
      p_serials.LAST_UPDATE_DATE(i) := serial_rec.LAST_UPDATE_DATE;
      p_serials.LAST_UPDATED_BY(i) := serial_rec.LAST_UPDATED_BY;
      p_serials.CREATION_DATE(i) := serial_rec.CREATION_DATE;
      p_serials.CREATED_BY(i) := serial_rec.CREATED_BY;
      p_serials.LAST_UPDATE_LOGIN(i) := serial_rec.LAST_UPDATE_LOGIN;
      p_serials.REQUEST_ID(i) := serial_rec.REQUEST_ID;
      p_serials.PROGRAM_APPLICATION_ID(i) := serial_rec.PROGRAM_APPLICATION_ID;
      p_serials.PROGRAM_ID(i) := serial_rec.PROGRAM_ID;
      p_serials.PROGRAM_UPDATE_DATE(i) := serial_rec.PROGRAM_UPDATE_DATE;
      p_serials.INITIALIZATION_DATE(i) := serial_rec.INITIALIZATION_DATE;
      p_serials.COMPLETION_DATE(i) := serial_rec.COMPLETION_DATE;
      p_serials.SHIP_DATE(i) := serial_rec.SHIP_DATE;
      p_serials.CURRENT_STATUS(i) := serial_rec.CURRENT_STATUS;
      p_serials.REVISION(i) := serial_rec.REVISION;
      p_serials.LOT_NUMBER(i) := serial_rec.LOT_NUMBER;
      p_serials.FIXED_ASSET_TAG(i) := serial_rec.FIXED_ASSET_TAG;
      p_serials.RESERVED_ORDER_ID(i) := serial_rec.RESERVED_ORDER_ID;
      p_serials.PARENT_ITEM_ID(i) := serial_rec.PARENT_ITEM_ID;
      p_serials.PARENT_SERIAL_NUMBER(i) := serial_rec.PARENT_SERIAL_NUMBER;
      p_serials.ORIGINAL_WIP_ENTITY_ID(i) := serial_rec.ORIGINAL_WIP_ENTITY_ID;
      p_serials.ORIGINAL_UNIT_VENDOR_ID(i) := serial_rec.ORIGINAL_UNIT_VENDOR_ID;
      p_serials.VENDOR_SERIAL_NUMBER(i) := serial_rec.VENDOR_SERIAL_NUMBER;
      p_serials.VENDOR_LOT_NUMBER(i) := serial_rec.VENDOR_LOT_NUMBER;
      p_serials.LAST_TXN_SOURCE_TYPE_ID(i) := serial_rec.LAST_TXN_SOURCE_TYPE_ID;
      p_serials.LAST_TRANSACTION_ID(i) := serial_rec.LAST_TRANSACTION_ID;
      p_serials.LAST_RECEIPT_ISSUE_TYPE(i) := serial_rec.LAST_RECEIPT_ISSUE_TYPE;
      p_serials.LAST_TXN_SOURCE_NAME(i) := serial_rec.LAST_TXN_SOURCE_NAME;
      p_serials.LAST_TXN_SOURCE_ID(i) := serial_rec.LAST_TXN_SOURCE_ID;
      p_serials.DESCRIPTIVE_TEXT(i) := serial_rec.DESCRIPTIVE_TEXT;
      p_serials.CURRENT_SUBINVENTORY_CODE(i) := serial_rec.CURRENT_SUBINVENTORY_CODE;
      p_serials.CURRENT_LOCATOR_ID(i) := serial_rec.CURRENT_LOCATOR_ID;
      p_serials.CURRENT_ORGANIZATION_ID(i) := serial_rec.CURRENT_ORGANIZATION_ID;
      p_serials.ATTRIBUTE_CATEGORY(i) := serial_rec.ATTRIBUTE_CATEGORY;
      p_serials.ATTRIBUTE1(i) := serial_rec.ATTRIBUTE1;
      p_serials.ATTRIBUTE2(i) := serial_rec.ATTRIBUTE2;
      p_serials.ATTRIBUTE3(i) := serial_rec.ATTRIBUTE3;
      p_serials.ATTRIBUTE4(i) := serial_rec.ATTRIBUTE4;
      p_serials.ATTRIBUTE5(i) := serial_rec.ATTRIBUTE5;
      p_serials.ATTRIBUTE6(i) := serial_rec.ATTRIBUTE6;
      p_serials.ATTRIBUTE7(i) := serial_rec.ATTRIBUTE7;
      p_serials.ATTRIBUTE8(i) := serial_rec.ATTRIBUTE8;
      p_serials.ATTRIBUTE9(i) := serial_rec.ATTRIBUTE9;
      p_serials.ATTRIBUTE10(i) := serial_rec.ATTRIBUTE10;
      p_serials.ATTRIBUTE11(i) := serial_rec.ATTRIBUTE11;
      p_serials.ATTRIBUTE12(i) := serial_rec.ATTRIBUTE12;
      p_serials.ATTRIBUTE13(i) := serial_rec.ATTRIBUTE13;
      p_serials.ATTRIBUTE14(i) := serial_rec.ATTRIBUTE14;
      p_serials.ATTRIBUTE15(i) := serial_rec.ATTRIBUTE15;
      p_serials.GROUP_MARK_ID(i) := serial_rec.GROUP_MARK_ID;
      p_serials.LINE_MARK_ID(i) := serial_rec.LINE_MARK_ID;
      p_serials.LOT_LINE_MARK_ID(i) := serial_rec.LOT_LINE_MARK_ID;
    end loop;

    close get_serials;

    if (p_serials.numrecs > 0) then
      delete mtl_serial_numbers
      where group_mark_id = p_grp_id
      and current_status = p_status;
    end if;
  end fetch_and_delete;

  procedure insert_rows(
    p_serials in mtl_serial_numbers_rec) is
    i number := 1;
  begin
    while (i <= nvl(p_serials.numrecs, 0)) loop
      insert into mtl_serial_numbers (
        INVENTORY_ITEM_ID,
        SERIAL_NUMBER,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        REQUEST_ID,
        PROGRAM_APPLICATION_ID,
        PROGRAM_ID,
        PROGRAM_UPDATE_DATE,
        INITIALIZATION_DATE,
        COMPLETION_DATE,
        SHIP_DATE,
        CURRENT_STATUS,
        REVISION,
        LOT_NUMBER,
        FIXED_ASSET_TAG,
        RESERVED_ORDER_ID,
        PARENT_ITEM_ID,
        PARENT_SERIAL_NUMBER,
        ORIGINAL_WIP_ENTITY_ID,
        ORIGINAL_UNIT_VENDOR_ID,
        VENDOR_SERIAL_NUMBER,
        VENDOR_LOT_NUMBER,
        LAST_TXN_SOURCE_TYPE_ID,
        LAST_TRANSACTION_ID,
        LAST_RECEIPT_ISSUE_TYPE,
        LAST_TXN_SOURCE_NAME,
        LAST_TXN_SOURCE_ID,
        DESCRIPTIVE_TEXT,
        CURRENT_SUBINVENTORY_CODE,
        CURRENT_LOCATOR_ID,
        CURRENT_ORGANIZATION_ID,
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
        GROUP_MARK_ID,
        LINE_MARK_ID,
        LOT_LINE_MARK_ID
      ) values (
        p_serials.INVENTORY_ITEM_ID(i),
        p_serials.SERIAL_NUMBER(i),
        p_serials.LAST_UPDATE_DATE(i),
        p_serials.LAST_UPDATED_BY(i),
        p_serials.CREATION_DATE(i),
        p_serials.CREATED_BY(i),
        p_serials.LAST_UPDATE_LOGIN(i),
        p_serials.REQUEST_ID(i),
        p_serials.PROGRAM_APPLICATION_ID(i),
        p_serials.PROGRAM_ID(i),
        p_serials.PROGRAM_UPDATE_DATE(i),
        p_serials.INITIALIZATION_DATE(i),
        p_serials.COMPLETION_DATE(i),
        p_serials.SHIP_DATE(i),
        p_serials.CURRENT_STATUS(i),
        p_serials.REVISION(i),
        p_serials.LOT_NUMBER(i),
        p_serials.FIXED_ASSET_TAG(i),
        p_serials.RESERVED_ORDER_ID(i),
        p_serials.PARENT_ITEM_ID(i),
        p_serials.PARENT_SERIAL_NUMBER(i),
        p_serials.ORIGINAL_WIP_ENTITY_ID(i),
        p_serials.ORIGINAL_UNIT_VENDOR_ID(i),
        p_serials.VENDOR_SERIAL_NUMBER(i),
        p_serials.VENDOR_LOT_NUMBER(i),
        p_serials.LAST_TXN_SOURCE_TYPE_ID(i),
        p_serials.LAST_TRANSACTION_ID(i),
        p_serials.LAST_RECEIPT_ISSUE_TYPE(i),
        p_serials.LAST_TXN_SOURCE_NAME(i),
        p_serials.LAST_TXN_SOURCE_ID(i),
        p_serials.DESCRIPTIVE_TEXT(i),
        p_serials.CURRENT_SUBINVENTORY_CODE(i),
        p_serials.CURRENT_LOCATOR_ID(i),
        p_serials.CURRENT_ORGANIZATION_ID(i),
        p_serials.ATTRIBUTE_CATEGORY(i),
        p_serials.ATTRIBUTE1(i),
        p_serials.ATTRIBUTE2(i),
        p_serials.ATTRIBUTE3(i),
        p_serials.ATTRIBUTE4(i),
        p_serials.ATTRIBUTE5(i),
        p_serials.ATTRIBUTE6(i),
        p_serials.ATTRIBUTE7(i),
        p_serials.ATTRIBUTE8(i),
        p_serials.ATTRIBUTE9(i),
        p_serials.ATTRIBUTE10(i),
        p_serials.ATTRIBUTE11(i),
        p_serials.ATTRIBUTE12(i),
        p_serials.ATTRIBUTE13(i),
        p_serials.ATTRIBUTE14(i),
        p_serials.ATTRIBUTE15(i),
        p_serials.GROUP_MARK_ID(i),
        p_serials.LINE_MARK_ID(i),
        p_serials.LOT_LINE_MARK_ID(i)
      );

      i := i + 1;
    end loop;
  end insert_rows;

  procedure fetch_and_unmark(
    p_hdr_id  in     number,
    p_serials in out nocopy mtl_serial_numbers_mark_rec) is
    i number := 0;

    cursor get_serials(c_hdr_id number) is
    select
    SERIAL_NUMBER,
    INVENTORY_ITEM_ID,
    GROUP_MARK_ID,
    LINE_MARK_ID,
    LOT_LINE_MARK_ID
    from mtl_serial_numbers
    where group_mark_id = c_hdr_id;

    serial_rec get_serials%rowtype;
  begin
    -- initialize
    if (p_serials.numrecs is NULL) then
      -- p_serials is empty
      p_serials.numrecs := i;
    else
      -- p_serials already has records
      i := p_serials.numrecs;
    end if;

    open get_serials(c_hdr_id => p_hdr_id);

    loop
      fetch get_serials into serial_rec;

      exit when (get_serials%NOTFOUND);

      i := i + 1;
      p_serials.numrecs := i;
      p_serials.SERIAL_NUMBER(i) := serial_rec.SERIAL_NUMBER;
      p_serials.INVENTORY_ITEM_ID(i) := serial_rec.INVENTORY_ITEM_ID;
      p_serials.GROUP_MARK_ID(i) := serial_rec.GROUP_MARK_ID;
      p_serials.LINE_MARK_ID(i) := serial_rec.LINE_MARK_ID;
      p_serials.LOT_LINE_MARK_ID(i) := serial_rec.LOT_LINE_MARK_ID;
    end loop;

    close get_serials;

    if (p_serials.numrecs > 0) then
      update mtl_serial_numbers
      set group_mark_id = null,
          line_mark_id = null,
          lot_line_mark_id = null
      where group_mark_id = p_hdr_id;
    end if;
  end fetch_and_unmark;

  procedure mark(
    p_serials in mtl_serial_numbers_mark_rec,
    p_retcode out nocopy number) is
    i number := 1;

    -- cursor to lock rows
    cursor lock_rows(
      c_item_id number,
      c_serial  varchar2) is
    select 'x'
    from mtl_serial_numbers
    where inventory_item_id = c_item_id
    and serial_number = c_serial
    for update nowait;

    x_dummy varchar2(1);
  begin
    p_retcode := SUCCESS;

    savepoint mark_serials;

    while (i <= nvl(p_serials.numrecs, 0)) loop
      /* When remarking only this session should be transacting these
         serial numbers.  If cannot update, then some other session has
         locked this serial number => error out. */
      open lock_rows(
        c_item_id => p_serials.INVENTORY_ITEM_ID(i),
        c_serial  => p_serials.SERIAL_NUMBER(i));
      fetch lock_rows into x_dummy;
      close lock_rows;

      update mtl_serial_numbers
      set group_mark_id = p_serials.GROUP_MARK_ID(i),
          line_mark_id = p_serials.LINE_MARK_ID(i),
          lot_line_mark_id = p_serials.LOT_LINE_MARK_ID(i)
      where inventory_item_id = p_serials.INVENTORY_ITEM_ID(i)
      and serial_number = p_serials.SERIAL_NUMBER(i);

      i := i + 1;
    end loop;

  exception
    when others then
      /* cannot lock serial numbers should exception to here */
      /* as well as other types of exceptions */
      close lock_rows;
      rollback to mark_serials;
      p_retcode := FAILURE;
  end mark;

END WIP_SERIAL_NUMBER_CLEANUP;

/
