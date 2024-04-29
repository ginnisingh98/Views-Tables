--------------------------------------------------------
--  DDL for Package PO_ASL_AUTHORIZATIONS_THS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_ASL_AUTHORIZATIONS_THS" AUTHID CURRENT_USER as
/* $Header: POXADLSS.pls 115.2 2002/11/23 03:36:31 sbull ship $ */

/*===========================================================================
  PROCEDURE NAME:	insert_row


  DESCRIPTION:     	Lock table handler for CHV_AUTHORIZATIONS


  CHANGE HISTORY:  	28-Jun-96	CMOK		Created

=============================================================================*/

procedure insert_row(
	x_using_organization_id			NUMBER,
	x_reference_id		  		NUMBER,
	x_reference_type		  	VARCHAR2,
	x_authorization_code   			VARCHAR2,
	x_authorization_sequence		NUMBER,
	x_last_update_date	  		DATE,
	x_last_updated_by	  		NUMBER,
	x_creation_date		  		DATE,
	x_created_by		  		NUMBER,
	x_last_update_login			NUMBER,
	x_purchasing_unit_of_measure		VARCHAR2,
	x_timefence_days			NUMBER,
	x_rowid				IN OUT	NOCOPY VARCHAR2);


/*===========================================================================
  PROCEDURE NAME:	update_row


  DESCRIPTION:     	Table handler for CHV_AUTHORIZATIONS


  CHANGE HISTORY:  	28-Jun-96	cmok		Created

=============================================================================*/

procedure update_row(
	x_using_organization_id			NUMBER,
	x_reference_id		  		NUMBER,
	x_reference_type		  	VARCHAR2,
	x_authorization_code   			VARCHAR2,
	x_authorization_sequence		NUMBER,
	x_last_update_date	  		DATE,
	x_last_updated_by	  		NUMBER,
	x_creation_date		  		DATE,
	x_created_by		  		NUMBER,
	x_last_update_login			NUMBER,
	x_purchasing_unit_of_measure		VARCHAR2,
	x_timefence_days			NUMBER,
	x_rowid					VARCHAR2);

/*===========================================================================
  PROCEDURE NAME:	lock_row


  DESCRIPTION:     	Lock table handler for CHV_AUTHORIZATIONS


  CHANGE HISTORY:  	28-Jun-96	cmok		Created

=============================================================================*/

procedure lock_row(
	x_using_organization_id			NUMBER,
	x_reference_id		  		NUMBER,
	x_reference_type		  	VARCHAR2,
	x_authorization_code   			VARCHAR2,
	x_authorization_sequence		NUMBER,
	x_purchasing_unit_of_measure		VARCHAR2,
	x_timefence_days			NUMBER,
	x_rowid					VARCHAR2);

END PO_ASL_AUTHORIZATIONS_THS;

 

/
