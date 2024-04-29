--------------------------------------------------------
--  DDL for Package Body PO_ASL_AUTHORIZATIONS_THS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_ASL_AUTHORIZATIONS_THS" as
/* $Header: POXADLSB.pls 115.3 2002/11/23 03:36:44 sbull ship $ */

/*=============================================================================

  PROCEDURE NAME:	insert_row()

============================================================================*/

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
	x_rowid				IN OUT	NOCOPY VARCHAR2) is

  cursor row_id is 	SELECT rowid
			FROM   CHV_AUTHORIZATIONS
    		   	WHERE  reference_id = x_reference_id
			AND    reference_type = x_reference_type
			AND    using_organization_id = x_using_organization_id
			AND    authorization_sequence = x_authorization_sequence;

  x_record_unique	boolean;

begin

    -- Check for duplicate sequence number for the current reference
    -- number and type.  Also check for duplicate authorization
    -- code.

    x_record_unique := po_asl_authorizations_sv.check_record_unique(
			     x_reference_id,
			     x_reference_type,
			     x_authorization_code,
			     x_authorization_sequence,
			     x_using_organization_id);

    IF NOT x_record_unique THEN

	fnd_message.set_name('FND','FORM_RECORD_DUPLICATE');
        app_exception.raise_exception;

    END IF;

    INSERT INTO CHV_AUTHORIZATIONS(
	using_organization_id		,
	reference_id			,
	reference_type			,
	authorization_code		,
	authorization_sequence		,
	last_update_date		,
	last_updated_by	  		,
	creation_date			,
	created_by			,
	last_update_login		,
	purchasing_unit_of_measure	,
	timefence_days
     )  VALUES 			(
	x_using_organization_id		,
	x_reference_id			,
	x_reference_type		,
	x_authorization_code		,
	x_authorization_sequence	,
	x_last_update_date	  	,
	x_last_updated_by	 	,
	x_creation_date		  	,
	x_created_by		  	,
	x_last_update_login		,
	x_purchasing_unit_of_measure	,
	x_timefence_days
	);

  OPEN row_id;
  FETCH row_id INTO x_rowid;
  if (row_id%notfound) then
    CLOSE row_id;
    raise no_data_found;
  end if;
  CLOSE row_id;

end insert_row;


/*=============================================================================

  PROCEDURE NAME:	update_row()

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
	x_rowid					VARCHAR2) is
begin

    UPDATE CHV_AUTHORIZATIONS
    SET
	using_organization_id	   = x_using_organization_id		,
	reference_id		   = x_reference_id			,
	reference_type		   = x_reference_type			,
	authorization_code	   = x_authorization_code		,
	authorization_sequence     = x_authorization_sequence		,
	last_update_date	   = x_last_update_date			,
	last_updated_by	  	   = x_last_updated_by			,
	creation_date		   = x_creation_date			,
	created_by		   = x_created_by			,
	last_update_login	   = x_last_update_login		,
	purchasing_unit_of_measure = x_purchasing_unit_of_measure	,
	timefence_days		   = x_timefence_days
     WHERE rowid = x_rowid;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end update_row;

/*=============================================================================

  PROCEDURE NAME:	lock_row()

============================================================================*/

procedure lock_row(
	x_using_organization_id			NUMBER,
	x_reference_id		  		NUMBER,
	x_reference_type		  	VARCHAR2,
	x_authorization_code   			VARCHAR2,
	x_authorization_sequence		NUMBER,
	x_purchasing_unit_of_measure		VARCHAR2,
	x_timefence_days			NUMBER,
	x_rowid					VARCHAR2) is

  cursor auth_row is	SELECT *
			FROM   CHV_AUTHORIZATIONS
			WHERE  rowid = x_rowid
			FOR UPDATE NOWAIT;

  recinfo auth_row%rowtype;

begin

  OPEN auth_row;
  FETCH auth_row INTO recinfo;
  if (auth_row%notfound) then
    CLOSE auth_row;
    fnd_message.set_name('FND','FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  CLOSE auth_row;

  if (
		(recinfo.using_organization_id = x_using_organization_id)
	AND	(recinfo.reference_id = x_reference_id)
	AND	(recinfo.reference_type = x_reference_type)
	AND	(recinfo.authorization_code = x_authorization_code)
	AND	(recinfo.authorization_sequence = x_authorization_sequence)
	AND	((recinfo.purchasing_unit_of_measure =
			x_purchasing_unit_of_measure) OR
		 ((recinfo.purchasing_unit_of_measure is null) AND
		  (x_purchasing_unit_of_measure is null)))
	AND	((recinfo.timefence_days = x_timefence_days) OR
		 ((recinfo.timefence_days is null) AND
		  (x_timefence_days is null)))
  ) then
    return;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

end lock_row;

END PO_ASL_AUTHORIZATIONS_THS;

/
