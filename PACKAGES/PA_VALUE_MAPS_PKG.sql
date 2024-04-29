--------------------------------------------------------
--  DDL for Package PA_VALUE_MAPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_VALUE_MAPS_PKG" AUTHID CURRENT_USER as
/* $Header: PAYMPKGS.pls 120.1 2005/08/19 17:23:23 mwasowic noship $ */

--
-- Procedure     : Insert_rows
-- Purpose       : Create Rows in PA_VALUE_MAPS.
--
--
PROCEDURE insert_rows
      ( p_value_map_def_id                 IN NUMBER                               ,
        p_source_value_arr                 IN PA_PLSQL_DATATYPES.Char240TabTyp      ,
				p_dest_value_arr                   IN PA_PLSQL_DATATYPES.Char240TabTyp      ,
				p_source_value_pk1_arr             IN PA_PLSQL_DATATYPES.Char240TabTyp      ,
				p_source_value_pk2_arr             IN PA_PLSQL_DATATYPES.Char240TabTyp      ,
				p_source_value_pk3_arr             IN PA_PLSQL_DATATYPES.Char240TabTyp      ,
				p_source_value_pk4_arr             IN PA_PLSQL_DATATYPES.Char240TabTyp      ,
				p_source_value_pk5_arr             IN PA_PLSQL_DATATYPES.Char240TabTyp      ,
				p_dest_value_pk1_arr               IN PA_PLSQL_DATATYPES.Char240TabTyp      ,
				p_dest_value_pk2_arr               IN PA_PLSQL_DATATYPES.Char240TabTyp      ,
				p_dest_value_pk3_arr               IN PA_PLSQL_DATATYPES.Char240TabTyp      ,
				p_dest_value_pk4_arr               IN PA_PLSQL_DATATYPES.Char240TabTyp      ,
				p_dest_value_pk5_arr               IN PA_PLSQL_DATATYPES.Char240TabTyp      ,
        x_return_status              OUT  NOCOPY VARCHAR2                          , --File.Sql.39 bug 4440895
        x_msg_count                  OUT  NOCOPY NUMBER                            , --File.Sql.39 bug 4440895
        x_msg_data                   OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895


--
-- Procedure            : delete_rows
-- Purpose              : Delete rows in pa_value_maps.
--
--
PROCEDURE delete_rows
	    ( p_value_map_def_id                 IN NUMBER                        ,
        p_value_map_def_type               IN VARCHAR2                      ,
        p_probability_list_id              IN NUMBER := NULL                ,
        x_return_status              OUT  NOCOPY VARCHAR2                          , --File.Sql.39 bug 4440895
        x_msg_count                  OUT  NOCOPY NUMBER                            , --File.Sql.39 bug 4440895
        x_msg_data                   OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895


END PA_VALUE_MAPS_PKG;

 

/
