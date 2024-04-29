--------------------------------------------------------
--  DDL for Package EAM_ENTER_LOT_SERIAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_ENTER_LOT_SERIAL" AUTHID CURRENT_USER AS
 /* $Header: EAMPELSS.pls 115.1 2003/06/25 18:46:56 ayang ship $*/
PROCEDURE insert_ser_trx(p_trx_tmp_id 		IN 	VARCHAR2,
			 p_serial_trx_tmp_id 	IN 	NUMBER,
			 p_trx_header_id	IN	NUMBER,
			 p_user_id 		IN	NUMBER,
			 p_fm_ser_num 		IN	VARCHAR2,
			 p_to_ser_num		IN	VARCHAR2,
			 p_item_id		IN      NUMBER,
			 p_org_id		IN 	NUMBER,
			 x_err_code		OUT  NOCOPY	NUMBER,
		 	 x_err_message  	OUT  NOCOPY	VARCHAR2);

PROCEDURE create_serial_temp_id(p_trx_tmp_id IN VARCHAR2,
				p_lot_number IN VARCHAR2);

END eam_enter_lot_serial;



 

/
