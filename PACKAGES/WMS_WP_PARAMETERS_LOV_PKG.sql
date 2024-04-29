--------------------------------------------------------
--  DDL for Package WMS_WP_PARAMETERS_LOV_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_WP_PARAMETERS_LOV_PKG" AUTHID CURRENT_USER as
/* $Header: WMSPLTHS.pls 120.1.12010000.1 2009/03/25 09:55:15 shrmitra noship $ */

procedure INSERT_ROW (
  x_object_id  in NUMBER,
  x_object_name in VARCHAR2,
  x_object_description in VARCHAR2,
  x_parameter_id  in NUMBER,
  x_parameter_name in VARCHAR2,
  x_parameter_description in VARCHAR2
 );

procedure UPDATE_ROW (
  x_object_id  in NUMBER,
  x_object_name in VARCHAR2,
  x_object_description in VARCHAR2,
  x_parameter_id  in NUMBER,
  x_parameter_name in VARCHAR2,
  x_parameter_description in VARCHAR2
 );

PROCEDURE LOAD_ROW(
 x_object_id  in NUMBER,
  x_object_name in VARCHAR2,
  x_object_description in VARCHAR2,
  x_parameter_id  in NUMBER,
  x_parameter_name in VARCHAR2,
  x_parameter_description in VARCHAR2);

end WMS_WP_PARAMETERS_LOV_PKG;

/
