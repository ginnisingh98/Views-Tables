--------------------------------------------------------
--  DDL for Package Body WIP_LOT_TEMP_CLEANUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_LOT_TEMP_CLEANUP" AS
/* $Header: wipltclb.pls 115.6 2002/11/28 13:20:19 rmahidha ship $ */

  procedure fetch_and_delete(
    p_tmp_id in     number,
    p_lots   in out nocopy mtl_transaction_lots_temp_rec) is

    i number := 0;

    cursor get_lots(c_tmp_id number) is
    select
      transaction_temp_id,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      request_id,
      program_application_id,
      program_id,
      program_update_date,
      transaction_quantity,
      primary_quantity,
      lot_number,
      lot_expiration_date,
      error_code,
      serial_transaction_temp_id,
      group_header_id
    from mtl_transaction_lots_temp
    where transaction_temp_id = c_tmp_id;

    lot_rec get_lots%rowtype;
  begin
    -- initialize
    if (p_lots.numrecs is NULL) then
      -- p_lots is empty
      p_lots.numrecs := i;
    else
      -- p_lots already has records
      i := p_lots.numrecs;
    end if;

    open get_lots(c_tmp_id => p_tmp_id);

    loop
      fetch get_lots into lot_rec;

      exit when (get_lots%NOTFOUND);

      i := i + 1;
      p_lots.numrecs := i;
      p_lots.transaction_temp_id(i) := lot_rec.transaction_temp_id;
      p_lots.last_update_date(i) := lot_rec.last_update_date;
      p_lots.last_updated_by(i) := lot_rec.last_updated_by;
      p_lots.creation_date(i) := lot_rec.creation_date;
      p_lots.created_by(i) := lot_rec.created_by;
      p_lots.last_update_login(i) := lot_rec.last_update_login;
      p_lots.request_id(i) := lot_rec.request_id;
      p_lots.program_application_id(i) := lot_rec.program_application_id;
      p_lots.program_id(i) := lot_rec.program_id;
      p_lots.program_update_date(i) := lot_rec.program_update_date;
      p_lots.transaction_quantity(i) := lot_rec.transaction_quantity;
      p_lots.primary_quantity(i) := lot_rec.primary_quantity;
      p_lots.lot_number(i) := lot_rec.lot_number;
      p_lots.lot_expiration_date(i) := lot_rec.lot_expiration_date;
      p_lots.error_code(i) := lot_rec.error_code;
      p_lots.serial_transaction_temp_id(i) := lot_rec.serial_transaction_temp_id;
      p_lots.group_header_id(i) := lot_rec.group_header_id;
    end loop;

    close get_lots;

    if (p_lots.numrecs > 0) then
      delete from mtl_transaction_lots_temp
      where transaction_temp_id = p_tmp_id;
    end if;
  end fetch_and_delete;


  procedure fetch_and_delete(
    p_hdr_id in     number,
    p_lots   in out nocopy mtl_transaction_lots_temp_rec) is

    i number := 0;

    cursor get_lots(c_hdr_id number) is
    select
      transaction_temp_id,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      request_id,
      program_application_id,
      program_id,
      program_update_date,
      transaction_quantity,
      primary_quantity,
      lot_number,
      lot_expiration_date,
      error_code,
      serial_transaction_temp_id,
      group_header_id
    from mtl_transaction_lots_temp
    where group_header_id = c_hdr_id;

    lot_rec get_lots%rowtype;
  begin
    -- initialize
    if (p_lots.numrecs is NULL) then
      -- p_lots is empty
      p_lots.numrecs := i;
    else
      -- p_lots already has records
      i := p_lots.numrecs;
    end if;

    open get_lots(c_hdr_id => p_hdr_id);

    loop
      fetch get_lots into lot_rec;

      exit when (get_lots%NOTFOUND);

      i := i + 1;
      p_lots.numrecs := i;
      p_lots.transaction_temp_id(i) := lot_rec.transaction_temp_id;
      p_lots.last_update_date(i) := lot_rec.last_update_date;
      p_lots.last_updated_by(i) := lot_rec.last_updated_by;
      p_lots.creation_date(i) := lot_rec.creation_date;
      p_lots.created_by(i) := lot_rec.created_by;
      p_lots.last_update_login(i) := lot_rec.last_update_login;
      p_lots.request_id(i) := lot_rec.request_id;
      p_lots.program_application_id(i) := lot_rec.program_application_id;
      p_lots.program_id(i) := lot_rec.program_id;
      p_lots.program_update_date(i) := lot_rec.program_update_date;
      p_lots.transaction_quantity(i) := lot_rec.transaction_quantity;
      p_lots.primary_quantity(i) := lot_rec.primary_quantity;
      p_lots.lot_number(i) := lot_rec.lot_number;
      p_lots.lot_expiration_date(i) := lot_rec.lot_expiration_date;
      p_lots.error_code(i) := lot_rec.error_code;
      p_lots.serial_transaction_temp_id(i) := lot_rec.serial_transaction_temp_id;
      p_lots.group_header_id(i) := lot_rec.group_header_id;
    end loop;

    close get_lots;

    if (p_lots.numrecs > 0) then
      delete from mtl_transaction_lots_temp
      where group_header_id = p_hdr_id;
    end if;
  end fetch_and_delete;

  procedure insert_rows(
    p_lots in mtl_transaction_lots_temp_rec) is
    i number := 1;
  begin
    while (i <= nvl(p_lots.numrecs,0)) loop
      insert into mtl_transaction_lots_temp (
        transaction_temp_id,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        request_id,
        program_application_id,
        program_id,
        program_update_date,
        transaction_quantity,
        primary_quantity,
        lot_number,
        lot_expiration_date,
        error_code,
        serial_transaction_temp_id,
        group_header_id
      ) values (
        p_lots.transaction_temp_id(i),
        p_lots.last_update_date(i),
        p_lots.last_updated_by(i),
        p_lots.creation_date(i),
        p_lots.created_by(i),
        p_lots.last_update_login(i),
        p_lots.request_id(i),
        p_lots.program_application_id(i),
        p_lots.program_id(i),
        p_lots.program_update_date(i),
        p_lots.transaction_quantity(i),
        p_lots.primary_quantity(i),
        p_lots.lot_number(i),
        p_lots.lot_expiration_date(i),
        p_lots.error_code(i),
        p_lots.serial_transaction_temp_id(i),
        p_lots.group_header_id(i)
      );

      i := i + 1;
    end loop;
  end insert_rows;


END WIP_LOT_TEMP_CLEANUP;

/
