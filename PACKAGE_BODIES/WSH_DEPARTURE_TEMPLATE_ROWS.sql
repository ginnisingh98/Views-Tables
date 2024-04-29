--------------------------------------------------------
--  DDL for Package Body WSH_DEPARTURE_TEMPLATE_ROWS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_DEPARTURE_TEMPLATE_ROWS" as
/* $Header: WSHTDEPB.pls 115.1 99/07/16 08:22:23 porting shi $ */


-- ===========================================================================
--
-- Name:
--
--   insert_row
--
-- Description:
--
--   Called by the client to insert a row into the
--   WSH_DEPARTURE_TEMPLATES table.
--
-- ===========================================================================

procedure insert_row(
  X_rowid			in out varchar2,
  X_departure_template_id	in out number,
  X_name			varchar2,
  X_organization_id		number,
  X_vehicle_item_id		number,
  X_vehicle_number 		varchar2,
  X_freight_carrier_code	varchar2,
  X_planned_frequency		varchar2,
  X_planned_day			varchar2,
  X_planned_time		number,
  X_weight_uom_code		varchar2,
  X_volume_uom_code		varchar2,
  X_routing_instructions	varchar2,
  X_attribute_category		varchar2,
  X_attribute1			varchar2,
  X_attribute2			varchar2,
  X_attribute3			varchar2,
  X_attribute4			varchar2,
  X_attribute5			varchar2,
  X_attribute6			varchar2,
  X_attribute7			varchar2,
  X_attribute8			varchar2,
  X_attribute9			varchar2,
  X_attribute10			varchar2,
  X_attribute11			varchar2,
  X_attribute12			varchar2,
  X_attribute13			varchar2,
  X_attribute14			varchar2,
  X_attribute15			varchar2,
  X_creation_date		date,
  X_created_by			number,
  X_last_update_date		date,
  X_last_updated_by		number,
  X_last_update_login		number)
is

  cursor id_sequence is
    select wsh_departure_templates_s.nextval
    from sys.dual;

  cursor row_id is
    select rowid
    from wsh_departure_templates
    where departure_template_id = X_departure_template_id;

begin

  open id_sequence;
  fetch id_sequence into X_departure_template_id;
  close id_sequence;

  insert into wsh_departure_templates(

    departure_template_id,
    name,
    organization_id,
    vehicle_item_id,
    vehicle_number ,
    freight_carrier_code,
    planned_frequency,
    planned_day,
    planned_time,
    weight_uom_code,
    volume_uom_code,
    routing_instructions,
    attribute_category,
    attribute1,
    attribute2,
    attribute3,
    attribute4,
    attribute5,
    attribute6,
    attribute7,
    attribute8,
    attribute9,
    attribute10,
    attribute11,
    attribute12,
    attribute13,
    attribute14,
    attribute15,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    last_update_login)

  values(

    X_departure_template_id,
    X_name,
    X_organization_id,
    X_vehicle_item_id,
    X_vehicle_number ,
    X_freight_carrier_code,
    X_planned_frequency,
    X_planned_day,
    X_planned_time,
    X_weight_uom_code,
    X_volume_uom_code,
    X_routing_instructions,
    X_attribute_category,
    X_attribute1,
    X_attribute2,
    X_attribute3,
    X_attribute4,
    X_attribute5,
    X_attribute6,
    X_attribute7,
    X_attribute8,
    X_attribute9,
    X_attribute10,
    X_attribute11,
    X_attribute12,
    X_attribute13,
    X_attribute14,
    X_attribute15,
    X_creation_date,
    X_created_by,
    X_last_update_date,
    X_last_updated_by,
    X_last_update_login
  );

  open row_id;

  fetch row_id into X_rowid;

  if (row_id%NOTFOUND) then
    close row_id;
    raise NO_DATA_FOUND;
  end if;

  close row_id;

exception
  when DUP_VAL_ON_INDEX then
    fnd_message.set_name('OE', 'WSH_TMPL_DUP_VAL');
    app_exception.raise_exception;

end insert_row;


-- ===========================================================================
--
-- Name:
--
--   lock_row
--
-- Description:
--
--   Called by the client to lock a row into the
--   WSH_DEPARTURE_TEMPLATES table.
--
-- ===========================================================================

procedure lock_row(
  X_rowid			varchar2,
  X_departure_template_id	number,
  X_name			varchar2,
  X_organization_id		number,
  X_vehicle_item_id		number,
  X_vehicle_number 		varchar2,
  X_freight_carrier_code	varchar2,
  X_planned_frequency		varchar2,
  X_planned_day			varchar2,
  X_planned_time		number,
  X_weight_uom_code		varchar2,
  X_volume_uom_code		varchar2,
  X_routing_instructions	varchar2,
  X_attribute_category		varchar2,
  X_attribute1			varchar2,
  X_attribute2			varchar2,
  X_attribute3			varchar2,
  X_attribute4			varchar2,
  X_attribute5			varchar2,
  X_attribute6			varchar2,
  X_attribute7			varchar2,
  X_attribute8			varchar2,
  X_attribute9			varchar2,
  X_attribute10			varchar2,
  X_attribute11			varchar2,
  X_attribute12			varchar2,
  X_attribute13			varchar2,
  X_attribute14			varchar2,
  X_attribute15			varchar2
)
is

  cursor lock_record is
    select *
    from   wsh_departure_templates
    where  rowid = X_rowid
    for update nowait;

  rec_info lock_record%ROWTYPE;

begin

  open lock_record;

  fetch lock_record into rec_info;

  if (lock_record%NOTFOUND) then
    close lock_record;

    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;

  end if;

  close lock_record;

  if (
	  (rec_info.departure_template_id = X_departure_template_id)
    and
	  ((rec_info.name = X_name)
	or
	  ((rec_info.name is null)
	    and (X_name is null)))
    and
	  (rec_info.organization_id = X_organization_id)
    and
	  ((rec_info.vehicle_item_id = X_vehicle_item_id)
	or
	  ((rec_info.vehicle_item_id is null)
	    and (X_vehicle_item_id is null)))
    and
	  ((rec_info.vehicle_number = X_vehicle_number)
	or
	  ((rec_info.vehicle_number is null)
	    and (X_vehicle_number is null)))
    and
	  ((rec_info.freight_carrier_code = X_freight_carrier_code)
	or
	  ((rec_info.freight_carrier_code is null)
	    and (X_freight_carrier_code is null)))
    and
	  (rec_info.planned_frequency = X_planned_frequency)
    and
	  ((rec_info.planned_day = X_planned_day)
	or
	  ((rec_info.planned_day is null)
	    and (X_planned_day is null)))
    and
	  ((rec_info.planned_time = X_planned_time)
	or
	  ((rec_info.planned_time is null)
	    and (X_planned_time is null)))
    and
	  ((rec_info.weight_uom_code = X_weight_uom_code)
	or
	  ((rec_info.weight_uom_code is null)
	    and (X_weight_uom_code is null)))
    and
	  ((rec_info.volume_uom_code = X_volume_uom_code)
	or
	  ((rec_info.volume_uom_code is null)
	    and (X_volume_uom_code is null)))
    and
	  ((rec_info.routing_instructions = X_routing_instructions)
	or
	  ((rec_info.routing_instructions is null)
	    and (X_routing_instructions is null)))
    and
	  ((rec_info.attribute_category = X_attribute_category)
	or
	  ((rec_info.attribute_category is null)
	    and (X_attribute_category is null)))
    and
	  ((rec_info.attribute1 = X_attribute1)
	or
	  ((rec_info.attribute1 is null)
	    and (X_attribute1 is null)))
    and
	  ((rec_info.attribute2 = X_attribute2)
	or
	  ((rec_info.attribute2 is null)
	    and (X_attribute2 is null)))
    and
	  ((rec_info.attribute3 = X_attribute3)
	or
	  ((rec_info.attribute3 is null)
	    and (X_attribute3 is null)))
    and
	  ((rec_info.attribute4 = X_attribute4)
	or
	  ((rec_info.attribute4 is null)
	    and (X_attribute4 is null)))
    and
	  ((rec_info.attribute5 = X_attribute5)
	or
	  ((rec_info.attribute5 is null)
	    and (X_attribute5 is null)))
    and
	  ((rec_info.attribute6 = X_attribute6)
	or
	  ((rec_info.attribute6 is null)
	    and (X_attribute6 is null)))
    and
	  ((rec_info.attribute7 = X_attribute7)
	or
	  ((rec_info.attribute7 is null)
	    and (X_attribute7 is null)))
    and
	  ((rec_info.attribute8 = X_attribute8)
	or
	  ((rec_info.attribute8 is null)
	    and (X_attribute8 is null)))
    and
	  ((rec_info.attribute9 = X_attribute9)
	or
	  ((rec_info.attribute9 is null)
	    and (X_attribute9 is null)))
    and
	  ((rec_info.attribute10 = X_attribute10)
	or
	  ((rec_info.attribute10 is null)
	    and (X_attribute10 is null)))
    and
	  ((rec_info.attribute11 = X_attribute11)
	or
	  ((rec_info.attribute11 is null)
	    and (X_attribute11 is null)))
    and
	  ((rec_info.attribute12 = X_attribute12)
	or
	  ((rec_info.attribute12 is null)
	    and (X_attribute12 is null)))
    and
	  ((rec_info.attribute13 = X_attribute13)
	or
	  ((rec_info.attribute13 is null)
	    and (X_attribute13 is null)))
    and
	  ((rec_info.attribute14 = X_attribute14)
	or
	  ((rec_info.attribute14 is null)
	    and (X_attribute14 is null)))
    and
	  ((rec_info.attribute15 = X_attribute15)
	or
	  ((rec_info.attribute15 is null)
	    and (X_attribute15 is null)))
  ) then

    return;

  else

    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;

  end if;

end lock_row;


-- ===========================================================================
--
-- Name:
--
--   update_row
--
-- Description:
--
--   Called by the client to update a row into the
--   WSH_DEPARTURE_TEMPLATES table.
--
-- ===========================================================================

procedure update_row(
  X_rowid			varchar2,
  X_departure_template_id	number,
  X_name			varchar2,
  X_organization_id		number,
  X_vehicle_item_id		number,
  X_vehicle_number 		varchar2,
  X_freight_carrier_code	varchar2,
  X_planned_frequency		varchar2,
  X_planned_day			varchar2,
  X_planned_time		number,
  X_weight_uom_code		varchar2,
  X_volume_uom_code		varchar2,
  X_routing_instructions	varchar2,
  X_attribute_category		varchar2,
  X_attribute1			varchar2,
  X_attribute2			varchar2,
  X_attribute3			varchar2,
  X_attribute4			varchar2,
  X_attribute5			varchar2,
  X_attribute6			varchar2,
  X_attribute7			varchar2,
  X_attribute8			varchar2,
  X_attribute9			varchar2,
  X_attribute10			varchar2,
  X_attribute11			varchar2,
  X_attribute12			varchar2,
  X_attribute13			varchar2,
  X_attribute14			varchar2,
  X_attribute15			varchar2,
  X_last_update_date            date,
  X_last_updated_by             number,
  X_last_update_login           number)
is
begin

  update wsh_departure_templates set

    departure_template_id	= X_departure_template_id,
    name			= X_name,
    organization_id		= X_organization_id,
    vehicle_item_id		= X_vehicle_item_id,
    vehicle_number 		= X_vehicle_number ,
    freight_carrier_code	= X_freight_carrier_code,
    planned_frequency		= X_planned_frequency,
    planned_day			= X_planned_day,
    planned_time		= X_planned_time,
    weight_uom_code		= X_weight_uom_code,
    volume_uom_code		= X_volume_uom_code,
    routing_instructions	= X_routing_instructions,
    attribute_category		= X_attribute_category,
    attribute1			= X_attribute1,
    attribute2			= X_attribute2,
    attribute3			= X_attribute3,
    attribute4			= X_attribute4,
    attribute5			= X_attribute5,
    attribute6			= X_attribute6,
    attribute7			= X_attribute7,
    attribute8			= X_attribute8,
    attribute9			= X_attribute9,
    attribute10			= X_attribute10,
    attribute11			= X_attribute11,
    attribute12			= X_attribute12,
    attribute13			= X_attribute13,
    attribute14			= X_attribute14,
    attribute15			= X_attribute15,
    last_update_date		= X_last_update_date,
    last_updated_by		= X_last_updated_by,
    last_update_login		= X_last_update_login

  where rowid = X_rowid;

  if (SQL%NOTFOUND) then
    raise NO_DATA_FOUND;
  end if;

exception
  when DUP_VAL_ON_INDEX then
    fnd_message.set_name('OE', 'WSH_TMPL_DUP_VAL');
    app_exception.raise_exception;

end update_row;


-- ===========================================================================
--
-- Name:
--
--   delete_row
--
-- Description:
--
--   Called by the client to delete a row into the
--   WSH_DEPARTURE_TEMPLATES table.
--
-- ===========================================================================

procedure delete_row(X_rowid varchar2)
is
begin

  delete from wsh_departure_templates
  where rowid = X_rowid;

  if (SQL%NOTFOUND) then
    raise NO_DATA_FOUND;
  end if;

end delete_row;


end wsh_departure_template_rows;

/
