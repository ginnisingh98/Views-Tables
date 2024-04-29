--------------------------------------------------------
--  DDL for Package BIS_RKPI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_RKPI" AUTHID CURRENT_USER AS
/*$Header: BISRKPIS.pls 120.0 2005/06/01 15:48:26 appldev noship $*/

-- params: p_ak_region_code - ak region code
-- get Dimension Level Short Name List
-- surround each short name with ','
-- note that the first and the last positions are also ','
-- for example the output could be ",SHORT_NAME1,,SHORT_NAME2,,SHORTNAME3,"
FUNCTION GET_PMF_DIM_L_SN(
	p_ak_region_code IN VARCHAR2,
  p_filter_time_dl IN VARCHAR2 := 'T'
) RETURN VARCHAR2;

-- params: p_dim_level_list - shortname list, output of GET_PMF_DIM_L_SN,
--        p_lang - user language
-- convert the shortnames in p_dim_level_list
-- to the corresponding names in the user's language
-- and reformat it by removing the ','
-- the output would look like "name1, name 2, name3"
FUNCTION GET_PMF_DIM_L_COMB(
	p_dim_level_list IN VARCHAR2,
	p_lang IN VARCHAR2
) RETURN VARCHAR2;

-- params: p_dim_level_list - shortname list, output of GET_PMF_DIM_L_SN
--         p_common_params - shortname list to be removed from p_dim_level_list,
--                           (output of GET_PMF_DIM_L_SN)
-- remove the shortnames in p_common_params from p_dim_level_list
FUNCTION REMOVE_COMMON_PARAMS(
	p_dim_level_list IN VARCHAR2,
	p_common_params IN VARCHAR2
) RETURN VARCHAR2;

END BIS_RKPI;

 

/
