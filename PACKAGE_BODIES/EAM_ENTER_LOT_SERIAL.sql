--------------------------------------------------------
--  DDL for Package Body EAM_ENTER_LOT_SERIAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_ENTER_LOT_SERIAL" AS
  /* $Header: EAMPELSB.pls 115.1 2003/06/25 18:49:24 ayang ship $*/
 g_pkg_name    CONSTANT VARCHAR2(30):= 'eam_enter_lot_serial';

PROCEDURE insert_ser_trx(p_trx_tmp_id 		IN	VARCHAR2,
			 p_serial_trx_tmp_id 	IN 	NUMBER,
			 p_trx_header_id	IN	NUMBER,
			 p_user_id 		IN	NUMBER,
			 p_fm_ser_num 		IN	VARCHAR2,
			 p_to_ser_num		IN	VARCHAR2,
			 p_item_id		IN      NUMBER,
			 p_org_id		IN 	NUMBER,
			 x_err_code		OUT  NOCOPY	NUMBER,
		 	 x_err_message  	OUT  NOCOPY	VARCHAR2) IS
BEGIN

    x_err_code := inv_trx_util_pub.insert_ser_trx(
               p_trx_tmp_id     => p_serial_trx_tmp_id,
               p_user_id        => p_user_id,
               p_fm_ser_num     => p_fm_ser_num,
               p_to_ser_num     => p_to_ser_num,
               x_proc_msg       => x_err_message);

    if (x_err_code = 0) then
	serial_check.inv_mark_serial(
		from_serial_number	=> p_fm_ser_num,
		to_serial_number	=> p_to_ser_num,
		item_id			=> p_item_id,
		org_id			=> p_org_id,
		hdr_id			=> p_trx_header_id,
		temp_id			=> p_trx_tmp_id,
		lot_temp_id		=> p_serial_trx_tmp_id,
		success			=> x_err_code);
    end if;

END insert_ser_trx;

PROCEDURE create_serial_temp_id(p_trx_tmp_id IN VARCHAR2,
				p_lot_number IN VARCHAR2) IS
BEGIN
    update mtl_transaction_lots_temp
    set serial_transaction_temp_id = mtl_material_transactions_s.nextval
    where transaction_temp_id = p_trx_tmp_id and lot_number = p_lot_number;
END create_serial_temp_id;

END eam_enter_lot_serial;

/
