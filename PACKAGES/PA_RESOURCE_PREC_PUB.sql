--------------------------------------------------------
--  DDL for Package PA_RESOURCE_PREC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_RESOURCE_PREC_PUB" AUTHID CURRENT_USER AS
/* $Header: PARSPRES.pls 120.0 2005/05/29 22:36:12 appldev noship $ */

    TYPE plan_res_formats IS TABLE OF pa_plan_res_format;

    --Initialize the format collections for all 4 resource classes
    g_people_formats plan_res_formats;

    g_equipment_formats plan_res_formats;

    g_material_formats plan_res_formats;

    g_fin_element_formats plan_res_formats;

  PROCEDURE format_precedence_init ;

END; --end package PA_RESOURCE_PREC_PUB

 

/
