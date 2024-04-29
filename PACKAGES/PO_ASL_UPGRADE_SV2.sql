--------------------------------------------------------
--  DDL for Package PO_ASL_UPGRADE_SV2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_ASL_UPGRADE_SV2" AUTHID CURRENT_USER AS
/* $Header: POXA2LUS.pls 115.2 2002/11/25 19:44:08 sbull ship $*/

/*===========================================================================
  FUNCTION  NAME:	upgrade_autosource_vendors

  DESCRIPTION:

  PARAMETERS:		x_sr_receipt_id	   	NUMBER,
			x_autosource_rule_id	NUMBER,
			x_item_id		NUMBER,
			x_asl_status_id		NUMBER

  DESIGN REFERENCES:


  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	CMOK		8/13/96		Created

===========================================================================*/

PROCEDURE upgrade_autosource_vendors(
	x_sr_receipt_id	   	NUMBER,
	x_autosource_rule_id	NUMBER,
	x_item_id		NUMBER,
	x_asl_status_id		NUMBER,
	x_upgrade_docs		VARCHAR2,
	x_usr_upgrade_docs	VARCHAR2);

PROCEDURE create_asl_entry(x_vendor_id			NUMBER,
			   x_item_id			NUMBER,
			   x_asl_status_id		NUMBER,
			   x_last_update_date		DATE,
			   x_last_update_login		NUMBER,
			   x_last_updated_by		NUMBER,
			   x_created_by			NUMBER,
			   x_creation_date		DATE,
			   x_usr_upgrade_docs		VARCHAR2,
			   x_asl_id		IN OUT NOCOPY  NUMBER);

/*===========================================================================

  PROCEDURE NAME:       upgrade_asl_documents

===========================================================================*/

PROCEDURE upgrade_asl_documents(
        x_autosource_rule_id    NUMBER,
        x_vendor_id             NUMBER,
        x_asl_id                NUMBER
        );

END PO_ASL_UPGRADE_SV2;

 

/
