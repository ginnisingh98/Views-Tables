--------------------------------------------------------
--  DDL for Package INVUPD1B
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INVUPD1B" AUTHID CURRENT_USER as
/* $Header: INVUPD1S.pls 115.6 2002/12/01 02:15:02 rbande ship $ */

FUNCTION mtl_pr_assign_item_data_update
(
	org_id		NUMBER,
	all_org		NUMBER		:= 2,
	prog_appid	NUMBER		:= -1,
	prog_id		NUMBER		:= -1,
	request_id	NUMBER		:= -1,
	user_id		NUMBER		:= -1,
	login_id	NUMBER		:= -1,
	err_text IN OUT	NOCOPY VARCHAR2,
	xset_id  IN	NUMBER		DEFAULT -999
)
	return INTEGER;

FUNCTION chk_exist_copy_template_attr
(
	org_id		NUMBER,
	all_org		NUMBER		:= 2,
	prog_appid	NUMBER		:= -1,
	prog_id		NUMBER		:= -1,
	request_id	NUMBER		:= -1,
	user_id		NUMBER		:= -1,
	login_id	NUMBER		:= -1,
	err_text IN OUT	NOCOPY VARCHAR2,
	xset_id  IN	NUMBER		DEFAULT -999
)
	return INTEGER;

FUNCTION check_inv_item_id
(
	org_id		NUMBER,
	all_org		NUMBER		:= 2,
	prog_appid	NUMBER		:= -1,
	prog_id		NUMBER		:= -1,
	request_id	NUMBER		:= -1,
	user_id		NUMBER		:= -1,
	login_id	NUMBER		:= -1,
	err_text IN OUT	NOCOPY VARCHAR2,
	xset_id  IN	NUMBER		DEFAULT -999
)
	return INTEGER;

FUNCTION exists_in_msi
(
	row_id          	ROWID,
	org_id			NUMBER,
	inv_item_id IN OUT	NOCOPY NUMBER,
	prog_appid		NUMBER		:= -1,
	prog_id			NUMBER		:= -1,
	request_id		NUMBER		:= -1,
	user_id			NUMBER		:= -1,
	login_id		NUMBER		:= -1,
	trans_id		NUMBER,
	err_text IN OUT		NOCOPY VARCHAR2,
	xset_id  IN		NUMBER		DEFAULT NULL
)
	return INTEGER;

FUNCTION exists_onhand_quantities
(
	org_id		NUMBER,
	inv_item_id	NUMBER
)
	return INTEGER;

FUNCTION exists_onhand_child_qties
(
	org_id		NUMBER,
	inv_item_id	NUMBER
)
	return INTEGER;

FUNCTION copy_msi_to_msii
(
	row_id          ROWID,
	org_id          NUMBER,
	inv_item_id     NUMBER
)
	return INTEGER;

FUNCTION mtl_pr_validate_item_update
(
	org_id 		NUMBER,
	all_org 	NUMBER		:= 2,
	prog_appid 	NUMBER		:= -1,
	prog_id 	NUMBER		:= -1,
	request_id 	NUMBER		:= -1,
	user_id 	NUMBER		:= -1,
	login_id 	NUMBER		:= -1,
	err_text IN OUT	NOCOPY VARCHAR2,
	xset_id  IN	NUMBER		DEFAULT NULL
)
	return INTEGER;

--
-- Check for attribute dependencies impacted by onhand quantites.
--

FUNCTION mtl_validate_attr_upd
(
   org_id		IN  NUMBER
,  item_id              IN  NUMBER
,  row_id		IN  ROWID
,  attr_err_mesg_name   OUT NOCOPY VARCHAR2
)
RETURN  INTEGER;


END INVUPD1B;

 

/
