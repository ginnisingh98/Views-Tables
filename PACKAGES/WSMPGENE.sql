--------------------------------------------------------
--  DDL for Package WSMPGENE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSMPGENE" AUTHID CURRENT_USER AS
/* $Header: WSMGENES.pls 115.4 2000/06/19 12:41:24 pkm ship     $ */


  PROCEDURE one_inv_g(
			wip_ent_id		NUMBER,
			level_no		NUMBER,
			ent_name	IN OUT	VARCHAR2,
			ent_id	IN OUT	NUMBER,
			qty		IN OUT	NUMBER,
			org_id	IN OUT	number,
			x_err_code OUT NUMBER,
			x_err_msg OUT VARCHAR2 );

  PROCEDURE first_wip_g(wip_ent_id NUMBER,
			item_number IN OUT VARCHAR2,
			 org_id IN OUT number,
			x_err_code OUT NUMBER,
			x_err_msg OUT VARCHAR2);

 PROCEDURE issue_to_wip_n(trans_id NUMBER,
		wip_ent_id IN OUT NUMBER,
		x_err_code OUT NUMBER,
			x_err_msg OUT VARCHAR2);

  PROCEDURE fes_txn_n(trans_ref IN NUMBER,
		    lot_name IN VARCHAR2,
		    item_id IN NUMBER,
		    cur_trans_id IN OUT NUMBER,
		    next_trans_id IN OUT NUMBER,
		    next_indicator IN OUT VARCHAR2,
		    next_trans_ref IN OUT NUMBER,
		    tran_name IN OUT VARCHAR2,
		    inv_or_wip IN OUT VARCHAR2,
		    txn_type IN OUT VARCHAR2,
		    txn_type_id OUT NUMBER,
			x_err_code OUT NUMBER,
			x_err_msg OUT VARCHAR2 );

  PROCEDURE wip_to_complete_n(wip_ent_id NUMBER,org_id NUMBER,
			no_trans IN OUT NUMBER,
			x_err_code OUT NUMBER,
			x_err_msg OUT VARCHAR2);

  PROCEDURE inv_n(item_id NUMBER,
	       lot_name VARCHAR2,
	       cur_trans_id NUMBER,
		 no_of_trans IN OUT NUMBER,
		x_err_code OUT NUMBER,
			x_err_msg OUT VARCHAR2);

  PROCEDURE new_qty_n(trans_id NUMBER,wip_ent_id NUMBER,
			qty IN OUT NUMBER,
			x_err_code OUT NUMBER,
			x_err_msg OUT VARCHAR2);

  PROCEDURE completed_qty_n(wip_ent_id NUMBER,
				qty IN OUT NUMBER,
				x_err_code OUT NUMBER,
			x_err_msg OUT VARCHAR2);

  PROCEDURE first_wip_w(wip_ent_id NUMBER,
			item_number IN OUT VARCHAR2,
			org_id IN OUT NUMBER,
			x_err_code OUT NUMBER,
			x_err_msg OUT VARCHAR2);

  PROCEDURE one_inv_w(wip_ent_id NUMBER,
			level_no NUMBER,
			ent_name IN OUT VARCHAR2,
			ent_id IN OUT NUMBER,
			qty IN OUT NUMBER,
			item_number IN OUT VARCHAR2,
			org_id IN OUT NUMBER,
			x_err_code OUT NUMBER,
			x_err_msg OUT VARCHAR2);

  PROCEDURE subxsfer_refs_p(trans_id NUMBER,
			from_sub IN OUT VARCHAR2,
			to_sub IN OUT VARCHAR2,
			x_err_code OUT NUMBER,
			x_err_msg OUT VARCHAR2);

  FUNCTION complete_from_wip(trans_id NUMBER,
				x_err_code OUT NUMBER,
			x_err_msg OUT VARCHAR2) RETURN NUMBER;

  PROCEDURE fes_txn_o(trans_ref IN NUMBER,
		    lot_name IN VARCHAR2,
		    item_id IN NUMBER,
		    cur_trans_id IN OUT NUMBER,
		    next_indicator IN OUT VARCHAR2,
		    inv_or_wip IN OUT VARCHAR2,
		    next_trans_id IN OUT NUMBER,
		    txn_type IN OUT VARCHAR2,
                    txn_type_id OUT NUMBER,
		    next_trans_ref IN OUT NUMBER,
                    tran_name IN OUT VARCHAR2,
	            wip_id IN OUT NUMBER,
			x_err_code OUT NUMBER,
			x_err_msg OUT VARCHAR2);

  PROCEDURE issue_from_inv_o(wip_ent_id NUMBER,org_id NUMBER,
		no_trans IN OUT NUMBER,
		x_err_code OUT NUMBER,
			x_err_msg OUT VARCHAR2);

  PROCEDURE wip_o(cur_trans_id IN NUMBER,
		wip_ent_id IN NUMBER,
		next_trans_id IN OUT NUMBER,
		x_err_code OUT NUMBER,
			x_err_msg OUT VARCHAR2);

  PROCEDURE inv_o(item_id NUMBER,
	       lot_name VARCHAR2,
	       cur_trans_id NUMBER,
		no_of_trans IN OUT NUMBER,
		x_err_code OUT NUMBER,
			x_err_msg OUT VARCHAR2);

  PROCEDURE new_qty_o(trans_id NUMBER,
		   wip_ent_id NUMBER,qty IN OUT NUMBER,
			x_err_code OUT NUMBER,
			x_err_msg OUT VARCHAR2);

  PROCEDURE issued_qty_o(wip_ent_id NUMBER,
			qty IN OUT NUMBER,
			x_err_code OUT NUMBER,
			x_err_msg OUT VARCHAR2);

  PROCEDURE wsm_inv_meaning_t (txn_id NUMBER,
		tran_type  OUT VARCHAR2,
		wsm_inv_txn_type_id OUT NUMBER,
		x_err_code OUT NUMBER,
			x_err_msg OUT VARCHAR2);

  PROCEDURE org_transfers_t(from_org_id NUMBER,
			to_org_id NUMBER,
			from_org_code IN OUT VARCHAR2,
			to_org_code IN OUT VARCHAR2,
			x_err_code OUT NUMBER,
			x_err_msg OUT VARCHAR2);

  PROCEDURE get_next_type_id_t(id NUMBER,
			type_id IN OUT NUMBER,
			x_err_code OUT NUMBER,
			x_err_msg OUT VARCHAR2);

end WSMPGENE;


 

/
