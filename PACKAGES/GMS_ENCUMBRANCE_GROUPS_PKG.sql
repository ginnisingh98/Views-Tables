--------------------------------------------------------
--  DDL for Package GMS_ENCUMBRANCE_GROUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_ENCUMBRANCE_GROUPS_PKG" AUTHID CURRENT_USER as
/* $Header: GMSEGRPS.pls 120.2 2007/02/06 09:46:56 rshaik ship $ */

/* Table handler procedures */

 procedure insert_row (x_rowid				in out NOCOPY VARCHAR2,
                       x_encumbrance_group		in VARCHAR2,
                       x_last_update_date		in DATE,
                       x_last_updated_by		in NUMBER,
                       x_creation_date			in DATE,
                       x_created_by			in NUMBER,
                       x_encumbrance_group_status	in VARCHAR2,
                       x_encumbrance_ending_date	in DATE,
                       x_system_linkage_function	in VARCHAR2,
                       x_control_count			in NUMBER  	DEFAULT NULL,
                       x_control_total_amount		in NUMBER  	DEFAULT NULL,
                       x_description			in VARCHAR2  	DEFAULT NULL,
                       x_last_update_login		in NUMBER  	DEFAULT NULL,
                       x_transaction_source		in VARCHAR2  	DEFAULT NULL,
                       x_org_id                         in NUMBER,
		       x_request_id                     IN NUMBER       DEFAULT NULL); /*Bug 5689213*/

 procedure update_row (x_rowid				in VARCHAR2,
                       x_encumbrance_group		in VARCHAR2,
                       x_last_update_date		in DATE,
                       x_last_updated_by		in NUMBER,
                       x_encumbrance_group_status	in VARCHAR2,
                       x_encumbrance_ending_date	in DATE,
                       x_system_linkage_function	in VARCHAR2,
                       x_control_count			in NUMBER,
                       x_control_total_amount		in NUMBER,
                       x_description			in VARCHAR2,
                       x_last_update_login		in NUMBER,
                       x_transaction_source		in VARCHAR2);


 procedure delete_row (x_rowid	in VARCHAR2);

 procedure lock_row (x_rowid	in VARCHAR2);


/* Procedures to change the status of an encumbrance group */


 -- Possible error codes for submit:
 --  submit_only_working
 --  control_amounts_must_match
 --  exp_items_must_exist
 --  no_null_quantity

 procedure submit (x_encumbrance_group	in VARCHAR2,
                   x_err_code		in out NOCOPY NUMBER,
                   x_return_status	in out NOCOPY VARCHAR2);

 procedure release (x_encumbrance_group	in VARCHAR2,
                   x_err_code		in out NOCOPY NUMBER,
                   x_return_status	in out NOCOPY VARCHAR2);

 procedure rework (x_encumbrance_group	in VARCHAR2,
                   x_err_code		in out NOCOPY NUMBER,
                   x_return_status	in out NOCOPY VARCHAR2);

END gms_encumbrance_groups_pkg;

/
