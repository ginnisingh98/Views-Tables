--------------------------------------------------------
--  DDL for Package WSH_DEPARTURE_TEMPLATE_ROWS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_DEPARTURE_TEMPLATE_ROWS" AUTHID CURRENT_USER as
/* $Header: WSHTDEPS.pls 115.1 99/07/16 08:22:30 porting shi $ */


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
  X_last_update_login		number);

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
  X_attribute15			varchar2);

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
  X_last_update_login           number);


procedure delete_row(X_rowid varchar2);


end wsh_departure_template_rows;

 

/
