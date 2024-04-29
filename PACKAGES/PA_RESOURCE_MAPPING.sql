--------------------------------------------------------
--  DDL for Package PA_RESOURCE_MAPPING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_RESOURCE_MAPPING" AUTHID CURRENT_USER AS
/* $Header: PARSMAPS.pls 120.1 2005/09/08 05:26:54 appldev noship $ */


/* This variable will tell if the map_resource_list is called from actuals or not */
g_called_process varchar2(20) := 'PLAN';
  /*--------------------------------------------------------------
     This API assumes that the temporary table pa_res_list_map_tmp
     has been populated with planning transactions that need to be
	 mapped to a planning resource
  --------------------------------------------------------------*/
  PROCEDURE map_resource_list (
    p_resource_list_id IN NUMBER,
     p_project_id   IN NUMBER, --bug#3576766
	x_return_status  OUT NOCOPY VARCHAR2,
	x_msg_count      OUT NOCOPY NUMBER,
	x_msg_data       OUT NOCOPY VARCHAR2
  ) ;

  /*---------------------------------------------------------
     Returns the format precedence for every resource class
  ---------------------------------------------------------*/
  PROCEDURE get_format_precedence (
      p_resource_class_id   IN NUMBER,
      p_res_format_id       IN NUMBER,
      x_format_precedence   OUT NOCOPY /* file.sql.39 change */ NUMBER,
      x_return_status       OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
      x_msg_code            OUT NOCOPY /* file.sql.39 change */ VARCHAR2 );

END; --end package pa_resource_mapping

 

/
