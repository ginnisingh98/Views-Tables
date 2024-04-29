--------------------------------------------------------
--  DDL for Package Body WIP_TRANSACTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_TRANSACTIONS_PKG" as
/* $Header: wiptxnsb.pls 115.12 2004/07/29 10:36:19 panagara ship $ */

  SUCCESS constant number := 0;
  FAILURE constant number := -1;

  procedure mov_cleanup(
    mov_group_id  in number,
    res_group_id  in number,
    mtl_header_id in number,
    bf_page       in number,
    save_point    in varchar2,
    err_code      out NOCOPY number,
    err_app       out NOCOPY varchar2,
    err_msg       out NOCOPY varchar2) is

    move_recs wip_move_txn_interface_cleanup.WIP_MOVE_TXN_INTERFACE_REC;
    alloc_recs wip_move_alloc_cleanup.WIP_MOVE_TXN_ALLOCATIONS_REC;
    mtl_temp_recs wip_mtl_txns_temp_cleanup.MTL_TRANSACTIONS_TEMP_REC;
    sn_temp_recs wip_serial_temp_cleanup.MTL_SERIAL_NUMBERS_TEMP_REC;
    lt_temp_recs wip_lot_temp_cleanup.MTL_TRANSACTION_LOTS_TEMP_REC;
    sn_recs wip_serial_number_cleanup.MTL_SERIAL_NUMBERS_REC;
    sn_marks wip_serial_number_cleanup.MTL_SERIAL_NUMBERS_MARK_REC;

    cursor overcpl_move_id is
       select wmti1.transaction_id
	 from wip_move_txn_interface wmti,
	 wip_move_txn_interface wmti1
	 where wmti.group_id = mov_group_id
	 and wmti.overcompletion_transaction_id is not NULL
	 AND wmti.overcompletion_transaction_qty > 0
	 and wmti1.overcompletion_transaction_id = wmti.overcompletion_transaction_id;

    oc_mov_group_id  NUMBER;
    oc_move_recs wip_move_txn_interface_cleanup.WIP_MOVE_TXN_INTERFACE_REC;
    oc_alloc_recs wip_move_alloc_cleanup.WIP_MOVE_TXN_ALLOCATIONS_REC;

    x_retcode number;
    x_app varchar2(3);
    x_msg varchar2(30);
  begin
    -- initialize
    err_code := SUCCESS;
    err_app := NULL;
    err_msg := NULL;

    move_recs.numrecs := 0;
    alloc_recs.numrecs := 0;
    mtl_temp_recs.numrecs := 0;
    sn_temp_recs.numrecs := 0;
    lt_temp_recs.numrecs := 0;

    oc_move_recs.numrecs := 0;
    oc_alloc_recs.numrecs := 0;

    oc_mov_group_id := NULL;
    open overcpl_move_id;

    loop
    	fetch overcpl_move_id into oc_mov_group_id;
   	exit when overcpl_move_id%NOTFOUND;
    	if (oc_mov_group_id IS NOT NULL) THEN
       	-- Overcompletion
       	-- No manual WCTI transactions will be there for child transaction
       	-- and Move processing hasn't happened for child yet.

       	wip_move_alloc_cleanup.fetch_and_delete
	 (p_mov_grp_id => oc_mov_group_id,
	  p_mov_allocs => oc_alloc_recs);

       	wip_move_txn_interface_cleanup.fetch_and_delete
	 (p_grp_id => oc_mov_group_id,
	  p_moves => oc_move_recs);

    	end if;
   end loop;

    if (res_group_id > 0) then
       delete wip_cost_txn_interface
       where group_id = res_group_id;
    end if;

    if (mtl_header_id > 0) then
      wip_move_alloc_cleanup.fetch_and_delete(
        p_mov_grp_id => mov_group_id,
        p_mov_allocs => alloc_recs);

      wip_mtl_txns_temp_cleanup.fetch_and_delete(
        p_hdr_id      => mtl_header_id,
        p_act_id      => NULL,
        p_materials   => mtl_temp_recs,
        p_lots        => lt_temp_recs,
        p_serials     => sn_temp_recs,
        p_dyn_serials => sn_recs,
        p_ser_marks   => sn_marks);
    end if;

    wip_move_txn_interface_cleanup.fetch_and_delete(
      p_grp_id => mov_group_id,
      p_moves => move_recs);

    commit;

    if (bf_page = 2) then
      wip_utilities.do_sql('SAVEPOINT ' || save_point);
      wip_move_txn_interface_cleanup.insert_rows(move_recs);

      if (mtl_header_id > 0) then
        wip_mtl_txns_temp_cleanup.insert_rows(
          p_materials   => mtl_temp_recs,
          p_lots        => lt_temp_recs,
          p_serials     => sn_temp_recs,
          p_dyn_serials => sn_recs,
          p_ser_marks   => sn_marks,
          p_retcode     => x_retcode,
          p_app         => x_app,
          p_msg         => x_msg);

        if (x_retcode <> wip_serial_number_cleanup.SUCCESS) then
          rollback;
          err_code := FAILURE;
          err_app := x_app;
          err_msg := x_msg;
          return;
        end if;

        wip_move_alloc_cleanup.insert_rows(alloc_recs);
      end if;
    end if;

    err_code := SUCCESS;

  exception
    when others then
      err_code := FAILURE;
      err_app := 'INV';
      err_msg := 'INV_RPC_CLEANUP_ERROR';
  end mov_cleanup;

  procedure mtl_cleanup(
    mtl_header_id in number,
    entry_sp      in varchar2,
    err_code      out NOCOPY number,
    err_app       out NOCOPY varchar2,
    err_msg       out NOCOPY varchar2) is
    mtl_tmp_recs wip_mtl_txns_temp_cleanup.MTL_TRANSACTIONS_TEMP_REC;
    mtl_sn_tmp_recs wip_serial_temp_cleanup.MTL_SERIAL_NUMBERS_TEMP_REC;
    mtl_lt_tmp_recs wip_lot_temp_cleanup.MTL_TRANSACTION_LOTS_TEMP_REC;
    mtl_dyn_sn_recs wip_serial_number_cleanup.MTL_SERIAL_NUMBERS_REC;
    mtl_sn_mrks wip_serial_number_cleanup.MTL_SERIAL_NUMBERS_MARK_REC;

    x_retcode number;
    x_app varchar2(3);
    x_msg varchar2(30);
  begin
    -- get material records
    wip_mtl_txns_temp_cleanup.fetch_and_delete(
      p_hdr_id      => mtl_header_id,
      p_act_id      => NULL,
      p_materials   => mtl_tmp_recs,
      p_lots        => mtl_lt_tmp_recs,
      p_serials     => mtl_sn_tmp_recs,
      p_dyn_serials => mtl_dyn_sn_recs,
      p_ser_marks   => mtl_sn_mrks);

    commit;

    wip_utilities.do_sql('SAVEPOINT ' || entry_sp);

    -- insert material records
    wip_mtl_txns_temp_cleanup.insert_rows(
      p_materials   => mtl_tmp_recs,
      p_lots        => mtl_lt_tmp_recs,
      p_serials     => mtl_sn_tmp_recs,
      p_dyn_serials => mtl_dyn_sn_recs,
      p_ser_marks   => mtl_sn_mrks,
      p_retcode     => x_retcode,
      p_app         => x_app,
      p_msg         => x_msg);

    if (x_retcode <> wip_serial_number_cleanup.SUCCESS) then
      rollback;
      err_code := FAILURE;
      err_app := x_app;
      err_msg := x_msg;
      return;
    end if;

    err_code := SUCCESS;

  exception
    when others then
      err_code := FAILURE;
      err_app := 'INV';
      err_msg := 'INV_RPC_CLEANUP_ERROR';
  end mtl_cleanup;

  PROCEDURE cmp_cleanup(
    mtl_header_id IN NUMBER,
    action_id     IN NUMBER,
    criteria_sp   IN VARCHAR2,
    entry_sp      IN VARCHAR2,
    insert_sp     IN VARCHAR2,
    bf_page       IN NUMBER,
    err_code      OUT NOCOPY NUMBER,
    err_app       OUT NOCOPY VARCHAR2,
    err_msg       OUT NOCOPY VARCHAR2) IS

    cmp_mtl_tmp_recs wip_mtl_txns_temp_cleanup.MTL_TRANSACTIONS_TEMP_REC;
    cmp_sn_tmp_recs wip_serial_temp_cleanup.MTL_SERIAL_NUMBERS_TEMP_REC;
    cmp_lt_tmp_recs wip_lot_temp_cleanup.MTL_TRANSACTION_LOTS_TEMP_REC;
    cmp_dyn_sn_recs wip_serial_number_cleanup.MTL_SERIAL_NUMBERS_REC;
    cmp_sn_mrks wip_serial_number_cleanup.MTL_SERIAL_NUMBERS_MARK_REC;

    bf_mtl_tmp_recs wip_mtl_txns_temp_cleanup.MTL_TRANSACTIONS_TEMP_REC;
    bf_sn_tmp_recs wip_serial_temp_cleanup.MTL_SERIAL_NUMBERS_TEMP_REC;
    bf_lt_tmp_recs wip_lot_temp_cleanup.MTL_TRANSACTION_LOTS_TEMP_REC;
    bf_dyn_sn_recs wip_serial_number_cleanup.MTL_SERIAL_NUMBERS_REC;
    bf_sn_mrks wip_serial_number_cleanup.MTL_SERIAL_NUMBERS_MARK_REC;

    -- Overcompletion
    oc_move_recs wip_move_txn_interface_cleanup.WIP_MOVE_TXN_INTERFACE_REC;
    oc_alloc_recs wip_move_alloc_cleanup.WIP_MOVE_TXN_ALLOCATIONS_REC;

    cursor overcpl_move_id is
	select wmti.transaction_id
	from mtl_material_transactions_temp mmtt,
	wip_move_txn_interface wmti
	where mmtt.TRANSACTION_HEADER_ID = mtl_header_id
	and mmtt.overcompletion_transaction_id is not null
	and wmti.overcompletion_transaction_id = mmtt.overcompletion_transaction_id;

    oc_mov_group_id  NUMBER;
    x_retcode number;
    x_app varchar2(3);
    x_msg varchar2(30);
  BEGIN

     -- get Overcompletion Move records
     oc_mov_group_id := NULL;
     OPEN overcpl_move_id;
     FETCH overcpl_move_id into oc_mov_group_id;
     CLOSE overcpl_move_id;

     if (oc_mov_group_id IS NOT NULL) THEN
	-- Overcompletion
	-- No WCTI transactions will be there since, no Manual charges are allowed
	-- and Move processing hasn't happened.

	wip_move_alloc_cleanup.fetch_and_delete
	  (p_mov_grp_id => oc_mov_group_id,
	   p_mov_allocs => oc_alloc_recs);

	wip_move_txn_interface_cleanup.fetch_and_delete
	  (p_grp_id => oc_mov_group_id,
	   p_moves => oc_move_recs);
     end if;

    -- get completion records
    wip_mtl_txns_temp_cleanup.fetch_and_delete(
      p_hdr_id      => mtl_header_id,
      p_act_id      => action_id,
      p_materials   => cmp_mtl_tmp_recs,
      p_lots        => cmp_lt_tmp_recs,
      p_serials     => cmp_sn_tmp_recs,
      p_dyn_serials => cmp_dyn_sn_recs,
      p_ser_marks   => cmp_sn_mrks);

    -- get rest of material records
    wip_mtl_txns_temp_cleanup.fetch_and_delete(
      p_hdr_id      => mtl_header_id,
      p_act_id      => NULL,
      p_materials   => bf_mtl_tmp_recs,
      p_lots        => bf_lt_tmp_recs,
      p_serials     => bf_sn_tmp_recs,
      p_dyn_serials => bf_dyn_sn_recs,
      p_ser_marks   => bf_sn_mrks);

    commit;

    wip_utilities.do_sql('SAVEPOINT ' || criteria_sp);

    -- post lot and serial records
    wip_lot_temp_cleanup.insert_rows(p_lots => cmp_lt_tmp_recs);
    wip_serial_temp_cleanup.insert_rows(p_serials => cmp_sn_tmp_recs);
    wip_serial_number_cleanup.insert_rows(p_serials => cmp_dyn_sn_recs);
    wip_serial_number_cleanup.mark(
      p_serials => cmp_sn_mrks,
      p_retcode => x_retcode);
    if (x_retcode <> wip_serial_number_cleanup.SUCCESS) then
      rollback;
      err_code := x_retcode;
      err_app := 'INV';
      err_msg := 'INV_RPC_CLEANUP_ERROR';
      return;
    end if;

    wip_utilities.do_sql('SAVEPOINT ' || entry_sp);

    -- post completion records
    wip_mtl_txns_temp_cleanup.insert_rows(p_mtls => cmp_mtl_tmp_recs);

    IF ( oc_move_recs.numrecs > 0 ) THEN
       -- Overcompletion
       wip_move_txn_interface_cleanup.insert_rows(oc_move_recs);
    END IF;

    wip_utilities.do_sql('SAVEPOINT ' || insert_sp);

    if (bf_page = 2) then
      -- insert backflush records
      wip_mtl_txns_temp_cleanup.insert_rows(
        p_materials   => bf_mtl_tmp_recs,
        p_lots        => bf_lt_tmp_recs,
        p_serials     => bf_sn_tmp_recs,
        p_dyn_serials => bf_dyn_sn_recs,
        p_ser_marks   => bf_sn_mrks,
        p_retcode     => x_retcode,
        p_app         => x_app,
        p_msg         => x_msg);
      if (x_retcode <> wip_serial_number_cleanup.SUCCESS) then
        rollback;
        err_code := FAILURE;
        err_app := x_app;
        err_msg := x_msg;
        return;
      end if;

      IF (oc_alloc_recs.numrecs > 0 ) THEN
	 -- Overcompletion
	 wip_move_alloc_cleanup.insert_rows(oc_alloc_recs);
      END IF;

    end if;

    err_code := SUCCESS;

  exception
    when others then
      err_code := FAILURE;
      err_app := 'INV';
      err_msg := 'INV_RPC_CLEANUP_ERROR';
  end cmp_cleanup;

  procedure cleanup(
    mov_group_id        in number,
    res_group_id        in number,
    mtl_header_id       in number) is
  begin

    if (mov_group_id > 0) then

      delete wip_move_txn_allocations
      where transaction_id in
        (select transaction_id
         from wip_move_txn_interface
         where group_id = mov_group_id);

      delete wip_move_txn_interface
      where group_id = mov_group_id;

    end if;

    if (res_group_id > 0) then
      delete wip_cost_txn_interface
      where group_id = res_group_id;
    end if;

    if (mtl_header_id > 0) then

      -- Delete predefined serial numbers
      delete mtl_serial_numbers
      where group_mark_id = mtl_header_id
        and current_status = 6;

      -- Unmark serial numbers
      update mtl_serial_numbers
      set group_mark_id = null,
          line_mark_id = null,
          lot_line_mark_id = null
      where group_mark_id = mtl_header_id;

      -- Delete lot and serial records from temp tables
      delete mtl_serial_numbers_temp
      where group_header_id = mtl_header_id;

      delete mtl_transaction_lots_temp
      where group_header_id = mtl_header_id;

      delete mtl_material_transactions_temp
      where transaction_header_id = mtl_header_id;

    end if;

    commit;

  end cleanup;

  FUNCTION rec_count_MMTT (mtl_hdr_id   IN NUMBER) return NUMBER IS
    ccount NUMBER;
  BEGIN
    select count(*)
      into ccount
      from mtl_material_transactions_temp
     where transaction_header_id = mtl_hdr_id;

    RETURN ccount;

  END rec_count_MMTT;

  Procedure cln_up_MMTT(txn_hdr_id  in number) is
   begin
    delete mtl_transaction_lots_temp
    where transaction_temp_id in
      (select transaction_temp_id
       from mtl_material_transactions_temp
       where transaction_header_id=txn_hdr_id
       and transaction_mode=1);
    delete mtl_serial_numbers_temp where
    transaction_temp_id in
      (select transaction_temp_id
       from mtl_material_transactions_temp
       where transaction_header_id=txn_hdr_id
       and transaction_mode=1);
    delete mtl_material_transactions_temp
    where transaction_header_id=txn_hdr_id
    and transaction_mode=1;
    commit;
end cln_up_MMTT ;

  procedure cln_up_MTI (txn_hdr_id in number) is

  completion_count1 number := 0 ;
  completion_count2 number := 0 ;
  l_bind1 number;
  l_bind2 number;
  l_bind3 number;
  l_bind4 number;

  begin
/* Performance Bug 3788705. Use bind variables so that single parse would be
   enough for the following 2 queries. */
  l_bind1 := 17;
  l_bind2 := 44;
  l_bind3 := 90;
  l_bind4 := NULL;
  select count(*)
  into   completion_count1
  from   mtl_transactions_interface
  where  transaction_header_id = txn_hdr_id
  and    transaction_type_id in (l_bind1, l_bind2, l_bind3, l_bind4) ;
  l_bind1 := 35;
  l_bind2 := 43;
  l_bind3 := 38;
  l_bind4 := 48;
  select count(*)
  into   completion_count2
  from   mtl_transactions_interface
  where  transaction_header_id = txn_hdr_id
  and    transaction_type_id in (l_bind1, l_bind2, l_bind3, l_bind4) ;

  if ((completion_count1 = 0) and (completion_count2 > 0)) then

     delete from mtl_transaction_lots_interface
     where transaction_interface_id in
           ( select transaction_interface_id from
             mtl_transactions_interface
             where transaction_header_id = txn_hdr_id
             and transaction_type_id in (35, 43, 38, 48)
           ) ;

      delete from mtl_serial_numbers_interface
      where  transaction_interface_id in
              (  select transaction_interface_id from
                 mtl_transactions_interface
                 where transaction_header_id = txn_hdr_id
                 and transaction_type_id in (35, 43, 38, 48)
              ) ;

      delete from mtl_transactions_interface
      where  transaction_header_id = txn_hdr_id
      and    transaction_type_id in (35, 43, 38, 48) ;

      commit ;
   end if ;
END ;
end WIP_TRANSACTIONS_PKG;

/
