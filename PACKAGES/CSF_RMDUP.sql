--------------------------------------------------------
--  DDL for Package CSF_RMDUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSF_RMDUP" AUTHID CURRENT_USER as
/*$Header: csfrmdps.pls 120.0 2005/05/24 18:36:38 appldev noship $*/

procedure clean_adm_bounds;
procedure clean_hydros;
procedure clean_inst_style_shts;
procedure clean_land_uses;
procedure clean_layer_metadata;
procedure clean_layer_style_shts;
procedure clean_names;
procedure clean_pois;
procedure clean_poi_names;
procedure clean_rail_segs;
procedure clean_rdseg_names;
procedure clean_road_segments;
procedure clean_theme_metadata;

end csf_rmdup;

 

/
