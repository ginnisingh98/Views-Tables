--------------------------------------------------------
--  DDL for Package PA_MAPPING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_MAPPING_PVT" AUTHID CURRENT_USER as
/* $Header: PAYMPVTS.pls 120.1 2005/08/19 17:23:32 mwasowic noship $ */

--
-- Procedure     : Save_value_maps
-- Purpose       : Save value map records to PA_VALUE_MAPS.
--
--
PROCEDURE save_value_maps
(       p_value_map_def_id                 IN NUMBER                               ,
	      p_record_version_number            IN NUMBER                               ,
        p_source_value_arr                 IN system.pa_varchar2_240_tbl_type      ,
				p_dest_value_arr                   IN system.pa_varchar2_240_tbl_type      ,
				p_source_value_pk1_arr             IN system.pa_varchar2_240_tbl_type      ,
				p_source_value_pk2_arr             IN system.pa_varchar2_240_tbl_type      ,
				p_source_value_pk3_arr             IN system.pa_varchar2_240_tbl_type      ,
				p_source_value_pk4_arr             IN system.pa_varchar2_240_tbl_type      ,
				p_source_value_pk5_arr             IN system.pa_varchar2_240_tbl_type      ,
				p_dest_value_pk1_arr               IN system.pa_varchar2_240_tbl_type      ,
				p_dest_value_pk2_arr               IN system.pa_varchar2_240_tbl_type      ,
				p_dest_value_pk3_arr               IN system.pa_varchar2_240_tbl_type      ,
				p_dest_value_pk4_arr               IN system.pa_varchar2_240_tbl_type      ,
				p_dest_value_pk5_arr               IN system.pa_varchar2_240_tbl_type      ,
        p_probability_list_id              IN NUMBER := NULL                       ,
        x_return_status              OUT  NOCOPY VARCHAR2                          , --File.Sql.39 bug 4440895
        x_msg_count                  OUT  NOCOPY NUMBER                            , --File.Sql.39 bug 4440895
        x_msg_data                   OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895


--
-- Procedure     : Get_dest_values
-- Purpose       : Get the corresponding destination values given an array of source
--                 values and a value map definition.
--
--
PROCEDURE get_dest_values
(       p_value_map_def_type           IN VARCHAR2     ,
        p_def_subtype                  IN VARCHAR2     ,
        p_source_value                 IN VARCHAR2     ,
				p_source_value_pk1             IN VARCHAR2     ,
				p_source_value_pk2             IN VARCHAR2     ,
				p_source_value_pk3             IN VARCHAR2     ,
				p_source_value_pk4             IN VARCHAR2     ,
				p_source_value_pk5             IN VARCHAR2     ,
        p_probability_list_id          IN NUMBER  := NULL,
				x_dest_value                   OUT NOCOPY VARCHAR2      , --File.Sql.39 bug 4440895
        x_dest_value_pk1               OUT NOCOPY VARCHAR2      , --File.Sql.39 bug 4440895
				x_dest_value_pk2               OUT NOCOPY VARCHAR2      , --File.Sql.39 bug 4440895
				x_dest_value_pk3               OUT NOCOPY VARCHAR2      , --File.Sql.39 bug 4440895
				x_dest_value_pk4               OUT NOCOPY VARCHAR2      , --File.Sql.39 bug 4440895
				x_dest_value_pk5               OUT NOCOPY VARCHAR2      , --File.Sql.39 bug 4440895
        x_return_status              OUT  NOCOPY VARCHAR2                          , --File.Sql.39 bug 4440895
        x_msg_count                  OUT  NOCOPY NUMBER                            , --File.Sql.39 bug 4440895
        x_msg_data                   OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895


PROCEDURE debug(p_msg IN VARCHAR2);

END PA_MAPPING_PVT;

 

/
