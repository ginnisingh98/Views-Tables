--------------------------------------------------------
--  DDL for Package BNE_GRAPHS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BNE_GRAPHS_PKG" AUTHID CURRENT_USER as
/* $Header: bnegraphs.pls 120.1 2005/08/30 03:18:47 dagroves noship $ */


procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_APPLICATION_ID in NUMBER,
  X_INTEGRATOR_CODE in VARCHAR2,
  X_SEQUENCE_NUM in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_LAYOUT_APP_ID in NUMBER,
  X_LAYOUT_CODE in VARCHAR2,
  X_GRAPH_DIMENSION_CODE in VARCHAR2,
  X_GRAPH_TYPE_CODE in VARCHAR2,
  X_AUTO_GRAPH_FLAG in VARCHAR2,
  X_CHART_TITLE in VARCHAR2,
  X_X_AXIS_LABEL in VARCHAR2,
  X_Y_AXIS_LABEL in VARCHAR2,
  X_Z_AXIS_LABEL in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_LAST_UPDATE_DATE in DATE
  );
procedure LOCK_ROW (
  X_APPLICATION_ID in NUMBER,
  X_INTEGRATOR_CODE in VARCHAR2,
  X_SEQUENCE_NUM in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_LAYOUT_APP_ID in NUMBER,
  X_LAYOUT_CODE in VARCHAR2,
  X_GRAPH_DIMENSION_CODE in VARCHAR2,
  X_GRAPH_TYPE_CODE in VARCHAR2,
  X_AUTO_GRAPH_FLAG in VARCHAR2,
  X_CHART_TITLE in VARCHAR2,
  X_X_AXIS_LABEL in VARCHAR2,
  X_Y_AXIS_LABEL in VARCHAR2,
  X_Z_AXIS_LABEL in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_LAST_UPDATE_DATE in DATE
);
procedure UPDATE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_INTEGRATOR_CODE in VARCHAR2,
  X_SEQUENCE_NUM in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_LAYOUT_APP_ID in NUMBER,
  X_LAYOUT_CODE in VARCHAR2,
  X_GRAPH_DIMENSION_CODE in VARCHAR2,
  X_GRAPH_TYPE_CODE in VARCHAR2,
  X_AUTO_GRAPH_FLAG in VARCHAR2,
  X_CHART_TITLE in VARCHAR2,
  X_X_AXIS_LABEL in VARCHAR2,
  X_Y_AXIS_LABEL in VARCHAR2,
  X_Z_AXIS_LABEL in VARCHAR2,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_LAST_UPDATE_DATE in DATE
);
procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER,
  X_INTEGRATOR_CODE in VARCHAR2,
  X_SEQUENCE_NUM in NUMBER
);
procedure ADD_LANGUAGE;

procedure TRANSLATE_ROW(
  x_integrator_asn        in VARCHAR2,
  x_integrator_code       in VARCHAR2,
  x_sequence_num          in VARCHAR2,
  x_chart_title           in VARCHAR2,
  x_x_axis_label          in VARCHAR2,
  x_y_axis_label          in VARCHAR2,
  x_z_axis_label          in VARCHAR2,
  x_owner                 in VARCHAR2,
  x_last_update_date      in VARCHAR2,
  x_custom_mode           in VARCHAR2
);
procedure LOAD_ROW(
  x_integrator_asn              in VARCHAR2,
  x_integrator_code             in VARCHAR2,
  x_sequence_num                in VARCHAR2,
  x_object_version_number       in VARCHAR2,
  x_layout_asn                  in VARCHAR2,
  x_layout_code                 in VARCHAR2,
  x_graph_dimension_code        in VARCHAR2,
  x_graph_type_code             in VARCHAR2,
  x_auto_graph_flag             in VARCHAR2,
  x_chart_title                 in VARCHAR2,
  x_x_axis_label                in VARCHAR2,
  x_y_axis_label                in VARCHAR2,
  x_z_axis_label                in VARCHAR2,
  x_last_update_date            in VARCHAR2,
  x_owner                       in VARCHAR2,
  x_custom_mode                 in VARCHAR2
);


end BNE_GRAPHS_PKG;

 

/
