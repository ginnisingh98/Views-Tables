--------------------------------------------------------
--  DDL for Package Body WIP_SERIAL_TEMP_CLEANUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_SERIAL_TEMP_CLEANUP" AS
/* $Header: wipstclb.pls 115.6 2002/11/29 14:38:28 rmahidha ship $ */

  procedure fetch_and_delete(
    p_tmp_id  in     number,
    p_serials in out nocopy mtl_serial_numbers_temp_rec) is

    i number := 0;

    cursor get_serials(c_tmp_id number) is
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
      vendor_serial_number,
      vendor_lot_number,
      fm_serial_number,
      to_serial_number,
      serial_prefix,
      error_code error_code,
      group_header_id
    from mtl_serial_numbers_temp
    where transaction_temp_id = c_tmp_id;

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

    open get_serials(c_tmp_id => p_tmp_id);

    loop
      fetch get_serials into serial_rec;

      exit when (get_serials%NOTFOUND);

      i := i + 1;
      p_serials.numrecs := i;
      p_serials.transaction_temp_id(i) := serial_rec.transaction_temp_id;
      p_serials.last_update_date(i) := serial_rec.last_update_date;
      p_serials.last_updated_by(i) := serial_rec.last_updated_by;
      p_serials.creation_date(i) := serial_rec.creation_date;
      p_serials.created_by(i) := serial_rec.created_by;
      p_serials.last_update_login(i) := serial_rec.last_update_login;
      p_serials.request_id(i) := serial_rec.request_id;
      p_serials.program_application_id(i) := serial_rec.program_application_id;
      p_serials.program_id(i) := serial_rec.program_id;
      p_serials.program_update_date(i) := serial_rec.program_update_date;
      p_serials.vendor_serial_number(i) := serial_rec.vendor_serial_number;
      p_serials.vendor_lot_number(i) := serial_rec.vendor_lot_number;
      p_serials.fm_serial_number(i) := serial_rec.fm_serial_number;
      p_serials.to_serial_number(i) := serial_rec.to_serial_number;
      p_serials.serial_prefix(i) := serial_rec.serial_prefix;
      p_serials.error_code(i) := serial_rec.error_code;
      p_serials.group_header_id(i) := serial_rec.group_header_id;
    end loop;

    close get_serials;

    if (p_serials.numrecs > 0) then
      delete from mtl_serial_numbers_temp
      where transaction_temp_id = p_tmp_id;
    end if;
  end fetch_and_delete;

  procedure fetch_and_delete(
    p_hdr_id  in     number,
    p_serials in out nocopy mtl_serial_numbers_temp_rec) is

    i number := 0;

    cursor get_serials(c_hdr_id number) is
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
      vendor_serial_number,
      vendor_lot_number,
      fm_serial_number,
      to_serial_number,
      serial_prefix,
      error_code error_code,
      group_header_id
    from mtl_serial_numbers_temp
    where group_header_id = c_hdr_id;

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
      p_serials.transaction_temp_id(i) := serial_rec.transaction_temp_id;
      p_serials.last_update_date(i) := serial_rec.last_update_date;
      p_serials.last_updated_by(i) := serial_rec.last_updated_by;
      p_serials.creation_date(i) := serial_rec.creation_date;
      p_serials.created_by(i) := serial_rec.created_by;
      p_serials.last_update_login(i) := serial_rec.last_update_login;
      p_serials.request_id(i) := serial_rec.request_id;
      p_serials.program_application_id(i) := serial_rec.program_application_id;
      p_serials.program_id(i) := serial_rec.program_id;
      p_serials.program_update_date(i) := serial_rec.program_update_date;
      p_serials.vendor_serial_number(i) := serial_rec.vendor_serial_number;
      p_serials.vendor_lot_number(i) := serial_rec.vendor_lot_number;
      p_serials.fm_serial_number(i) := serial_rec.fm_serial_number;
      p_serials.to_serial_number(i) := serial_rec.to_serial_number;
      p_serials.serial_prefix(i) := serial_rec.serial_prefix;
      p_serials.error_code(i) := serial_rec.error_code;
      p_serials.group_header_id(i) := serial_rec.group_header_id;
    end loop;

    close get_serials;

    if (p_serials.numrecs > 0) then
      delete from mtl_serial_numbers_temp
      where group_header_id = p_hdr_id;
    end if;
  end fetch_and_delete;

  procedure insert_rows(
    p_serials in mtl_serial_numbers_temp_rec) is
    i number := 1;
  begin
    while (i <= nvl(p_serials.numrecs, 0)) loop
      insert into mtl_serial_numbers_temp (
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
        vendor_serial_number,
        vendor_lot_number,
        fm_serial_number,
        to_serial_number,
        serial_prefix,
        error_code,
        group_header_id
      ) values (
        p_serials.transaction_temp_id(i),
        p_serials.last_update_date(i),
        p_serials.last_updated_by(i),
        p_serials.creation_date(i),
        p_serials.created_by(i),
        p_serials.last_update_login(i),
        p_serials.request_id(i),
        p_serials.program_application_id(i),
        p_serials.program_id(i),
        p_serials.program_update_date(i),
        p_serials.vendor_serial_number(i),
        p_serials.vendor_lot_number(i),
        p_serials.fm_serial_number(i),
        p_serials.to_serial_number(i),
        p_serials.serial_prefix(i),
        p_serials.error_code(i),
        p_serials.group_header_id(i)
      );

      i := i + 1;
    end loop;
  end insert_rows;

END WIP_SERIAL_TEMP_CLEANUP;

/
