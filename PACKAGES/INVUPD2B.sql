--------------------------------------------------------
--  DDL for Package INVUPD2B
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INVUPD2B" AUTHID CURRENT_USER as
/* $Header: INVUPD2S.pls 120.1.12010000.3 2009/03/23 12:00:52 pdasi ship $ */

-- Bug 5870114
-- This value is set int he EGO_ITEM_PUB package when the user tries to update from PLM
TYPE OBJECT_VERSION_REC IS RECORD (
     inventory_item_id   NUMBER := null,
     org_id      NUMBER := null,
     Object_Version_Number NUMBER := null
);

obj_ver_rec OBJECT_VERSION_REC;
-- Code changes for Bug 5870114  Ends


FUNCTION validate_item_update_master
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

FUNCTION check_child_records
(
	master_row_id   ROWID,
	inv_item_id     NUMBER,
	org_id 		NUMBER,
	trans_id	NUMBER,
	prog_appid 	NUMBER		:= -1,
	prog_id 	NUMBER		:= -1,
	request_id 	NUMBER		:= -1,
	user_id 	NUMBER		:= -1,
	login_id 	NUMBER		:= -1,
	err_text IN OUT	NOCOPY VARCHAR2,
	xset_id  IN     NUMBER          DEFAULT NULL
)
	return NUMBER;

FUNCTION create_child_update_mast_attr
(
	master_row_id   ROWID,
	inv_item_id     NUMBER,
	org_id          NUMBER,
	xset_id IN      NUMBER
)
	return INTEGER;

FUNCTION copy_master_to_child
(
	master_row_id   ROWID,
	inv_item_id     NUMBER,
	org_id IN          NUMBER,
	xset_id IN      NUMBER
)
        return INTEGER;

FUNCTION validate_item_update_child
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

FUNCTION update_validations
(
		row_id		ROWID,
		org_id		NUMBER,
		trans_id	NUMBER,
		user_id         NUMBER          := -1,
		login_id        NUMBER          := -1,
		prog_appid      NUMBER          := -1,
		prog_id         NUMBER          := -1,
		request_id      NUMBER          := -1
)
	return INTEGER;

--added an extra parameter commit_flag a part of bug 8269256 fix
FUNCTION inproit_process_item_update
(
	prg_appid  IN   NUMBER,
	prg_id     IN   NUMBER,
	req_id     IN   NUMBER,
	user_id    IN   NUMBER,
	login_id   IN   NUMBER,
	error_message  OUT      NOCOPY VARCHAR2,
	message_name   OUT      NOCOPY VARCHAR2,
	table_name     OUT      NOCOPY VARCHAR2,
	xset_id    IN   NUMBER DEFAULT NULL,
    commit_flag  IN     NUMBER       DEFAULT 1

)
	return INTEGER;

FUNCTION set_process_flag3
(
			   row_id  ROWID,
			   user_id NUMBER := -1,
			   login_id        NUMBER          := -1,
			   prog_appid      NUMBER          := -1,
			   prog_id         NUMBER          := -1,
			   reqst_id      NUMBER          := -1

)
	return INTEGER;

FUNCTION get_message
(
	msg_name        VARCHAR2,
	error_text OUT	NOCOPY VARCHAR2
)
	return INTEGER;

end INVUPD2B;

/
