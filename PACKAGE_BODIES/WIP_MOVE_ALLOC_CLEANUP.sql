--------------------------------------------------------
--  DDL for Package Body WIP_MOVE_ALLOC_CLEANUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_MOVE_ALLOC_CLEANUP" AS
/* $Header: wipmaclb.pls 115.6 2002/11/28 13:23:49 rmahidha ship $ */

  procedure fetch_and_delete(
    p_mov_grp_id in     number,
    p_mov_allocs in out nocopy wip_move_txn_allocations_rec) is

    i number := 0;

    cursor get_move_allocs(c_mov_grp_id number) is
    select
      TRANSACTION_ID,
      REPETITIVE_SCHEDULE_ID,
      ORGANIZATION_ID,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_LOGIN,
      REQUEST_ID,
      PROGRAM_APPLICATION_ID,
      PROGRAM_ID,
      PROGRAM_UPDATE_DATE,
      TRANSACTION_QUANTITY,
      PRIMARY_QUANTITY
    from wip_move_txn_allocations
    where transaction_id in
      (select transaction_id
       from wip_move_txn_interface
       where group_id = c_mov_grp_id);

    mov_alloc_rec get_move_allocs%rowtype;
  begin
    -- initialize
    if (p_mov_allocs.numrecs is NULL) then
      -- p_mov_allocs is empty
      p_mov_allocs.numrecs := i;
    else
      -- p_mov_allocs already has records
      i := p_mov_allocs.numrecs;
    end if;

    open get_move_allocs(c_mov_grp_id => p_mov_grp_id);

    loop
      fetch get_move_allocs into mov_alloc_rec;

      exit when (get_move_allocs%NOTFOUND);

      i := i + 1;
      p_mov_allocs.numrecs := i;
      p_mov_allocs.TRANSACTION_ID(i) := mov_alloc_rec.TRANSACTION_ID;
      p_mov_allocs.REPETITIVE_SCHEDULE_ID(i) := mov_alloc_rec.REPETITIVE_SCHEDULE_ID;
      p_mov_allocs.ORGANIZATION_ID(i) := mov_alloc_rec.ORGANIZATION_ID;
      p_mov_allocs.LAST_UPDATE_DATE(i) := mov_alloc_rec.LAST_UPDATE_DATE;
      p_mov_allocs.LAST_UPDATED_BY(i) := mov_alloc_rec.LAST_UPDATED_BY;
      p_mov_allocs.CREATION_DATE(i) := mov_alloc_rec.CREATION_DATE;
      p_mov_allocs.CREATED_BY(i) := mov_alloc_rec.CREATED_BY;
      p_mov_allocs.LAST_UPDATE_LOGIN(i) := mov_alloc_rec.LAST_UPDATE_LOGIN;
      p_mov_allocs.REQUEST_ID(i) := mov_alloc_rec.REQUEST_ID;
      p_mov_allocs.PROGRAM_APPLICATION_ID(i) := mov_alloc_rec.PROGRAM_APPLICATION_ID;
      p_mov_allocs.PROGRAM_ID(i) := mov_alloc_rec.PROGRAM_ID;
      p_mov_allocs.PROGRAM_UPDATE_DATE(i) := mov_alloc_rec.PROGRAM_UPDATE_DATE;
      p_mov_allocs.TRANSACTION_QUANTITY(i) := mov_alloc_rec.TRANSACTION_QUANTITY;
      p_mov_allocs.PRIMARY_QUANTITY(i) := mov_alloc_rec.PRIMARY_QUANTITY;
    end loop;

    if (p_mov_allocs.numrecs > 0) then
      delete from wip_move_txn_allocations
      where transaction_id in
         (select transaction_id
          from wip_move_txn_interface
          where group_id = p_mov_grp_id);
    end if;
  end fetch_and_delete;

  procedure insert_rows(
    p_mov_allocs in wip_move_txn_allocations_rec) is
    i number := 1;
  begin
    while (i <= nvl(p_mov_allocs.numrecs, 0)) loop
      insert into wip_move_txn_allocations (
        TRANSACTION_ID,
        REPETITIVE_SCHEDULE_ID,
        ORGANIZATION_ID,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        REQUEST_ID,
        PROGRAM_APPLICATION_ID,
        PROGRAM_ID,
        PROGRAM_UPDATE_DATE,
        TRANSACTION_QUANTITY,
        PRIMARY_QUANTITY
      ) values (
        p_mov_allocs.TRANSACTION_ID(i),
        p_mov_allocs.REPETITIVE_SCHEDULE_ID(i),
        p_mov_allocs.ORGANIZATION_ID(i),
        p_mov_allocs.LAST_UPDATE_DATE(i),
        p_mov_allocs.LAST_UPDATED_BY(i),
        p_mov_allocs.CREATION_DATE(i),
        p_mov_allocs.CREATED_BY(i),
        p_mov_allocs.LAST_UPDATE_LOGIN(i),
        p_mov_allocs.REQUEST_ID(i),
        p_mov_allocs.PROGRAM_APPLICATION_ID(i),
        p_mov_allocs.PROGRAM_ID(i),
        p_mov_allocs.PROGRAM_UPDATE_DATE(i),
        p_mov_allocs.TRANSACTION_QUANTITY(i),
        p_mov_allocs.PRIMARY_QUANTITY(i)
      );

      i := i + 1;
    end loop;
  end insert_rows;

END WIP_MOVE_ALLOC_CLEANUP;

/
