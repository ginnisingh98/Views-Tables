--------------------------------------------------------
--  DDL for Package Body WMS_WP_PARAMETERS_LOV_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_WP_PARAMETERS_LOV_PKG" as
/* $Header: WMSPLTHB.pls 120.1.12010000.1 2009/03/25 09:55:13 shrmitra noship $ */

procedure INSERT_ROW (
  x_object_id  in NUMBER,
  x_object_name in VARCHAR2,
  x_object_description in VARCHAR2,
  x_parameter_id  in NUMBER,
  x_parameter_name in VARCHAR2,
  x_parameter_description in VARCHAR2
) is


begin

  insert into wms_wp_parameters_lov (
  object_id,
  object_name,
  object_description,
  parameter_id,
  parameter_name,
  parameter_description
  ) values (
  x_object_id,
  x_object_name,
  x_object_description,
  x_parameter_id,
  x_parameter_name,
  x_parameter_description
  );

end INSERT_ROW;



procedure UPDATE_ROW (
  x_object_id  in NUMBER,
  x_object_name in VARCHAR2,
  x_object_description in VARCHAR2,
  x_parameter_id  in NUMBER,
  x_parameter_name in VARCHAR2,
  x_parameter_description in VARCHAR2
) is
begin
  update wms_wp_parameters_lov set
    object_id = x_object_id,
    object_name = x_object_name,
    object_description = x_object_description,
    parameter_id = x_parameter_id,
    parameter_name = x_parameter_name,
    parameter_description = x_parameter_description
  where parameter_id = x_parameter_id;

  if (sql%notfound) then
    raise no_data_found;
  end if;


end UPDATE_ROW;

PROCEDURE LOAD_ROW(
 x_object_id  in NUMBER,
  x_object_name in VARCHAR2,
  x_object_description in VARCHAR2,
  x_parameter_id  in NUMBER,
  x_parameter_name in VARCHAR2,
  x_parameter_description in VARCHAR2) is

   l_parameter_id number;
begin

    select parameter_id into l_parameter_id
    from wms_wp_parameters_lov
    where parameter_id = x_parameter_id;

      -- Update existing row
      WMS_WP_PARAMETERS_LOV_PKG.UPDATE_ROW(
     x_object_id,
          x_object_name,
          x_object_description,
	     x_parameter_id,
          x_parameter_name,
          x_parameter_Description);

  exception
    when no_data_found then
      -- Record doesn't exist - insert in all cases
        WMS_WP_PARAMETERS_LOV_PKG.INSERT_ROW (
     x_object_id,
          x_object_name,
          x_object_description,
	     x_parameter_id,
          x_parameter_name,
          x_parameter_Description);

end LOAD_ROW;

end WMS_WP_PARAMETERS_LOV_PKG;

/
