--------------------------------------------------------
--  DDL for Package PA_RBS_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_RBS_UTILS" AUTHID CURRENT_USER AS
/* $Header: PARRBSUS.pls 120.2 2005/09/28 18:09:54 ramurthy noship $*/

   -- Standard who
   g_last_updated_by         NUMBER(15) := FND_GLOBAL.USER_ID;
   g_last_update_date        DATE       := SYSDATE;
   g_creation_date           DATE       := SYSDATE;
   g_created_by              NUMBER(15) := FND_GLOBAL.USER_ID;
   g_last_update_login       NUMBER(15) := FND_GLOBAL.LOGIN_ID;
/********************************************************
 * Function : get_max_rbs_frozen_version
 * Description : Get the latest frozen version of an RBS.
 ********************************************************/
FUNCTION get_max_rbs_frozen_version(p_rbs_header_id IN NUMBER) return NUMBER;

/*****************************************************
 * Function : Get_element_Name
 * Description : This Function is used to return the
 *               Element_Name for a given
 *               resource_source_id and resource_type_code
 *               passed in.
 *               Further details are specified in the Body.
 ***************************************************/
Function Get_element_Name
   (p_resource_source_id IN Number,
    p_resource_type_code   IN Varchar2)
RETURN Varchar2;

/********************************************************
 * Procedure : Insert_elements
 * Description : This Procedure is used to insert into
 *               the pa_rbs_element_names_b table
 *               This API is called passing the call_flag
 *               of 'A' or 'B'.
 *               Details are specified in the Body.
 ******************************************************/
Procedure Insert_elements(p_resource_type_id    IN NUMBER,
                          x_return_status      OUT NOCOPY Varchar2);
/******************************************************
 * Procedure : Insert_non_tl_names
 * Description : This API is used to insert into the
 *               pa_rbs_element_names_tl table.
 *               For those res_type_codes for which there
 *               is no Multi lang support.
 *               Details are specified in the Body.
 ***************************************************/
PROCEDURE Insert_non_tl_names
           (p_resource_type_id   IN Number,
            p_resource_type_code IN Varchar2,
            x_return_status      OUT NOCOPY Varchar2);

/******************************************************
 * Procedure : Insert_tl_names
 * Description : This API is used to insert into the
 *               pa_rbs_element_names_tl table.
 *               For those res_type_codes for which there
 *               are corr TL tables
 *               Details are specified in the Body.
 ***************************************************/
PROCEDURE Insert_tl_names
        (p_resource_type_id   IN Number,
         p_resource_type_code IN Varchar2,
         x_return_status      OUT NOCOPY Varchar2);
/*******************************************************
 * Procedure : Populate_RBS_Element_Name
 * Description : Used to populate the pa_rbs_element_names_b
 *               and pa_rbs_element_names_tl tables
 *               and return back the element_name_id.
 *               Further details in the Body.
 ******************************************************/
PROCEDURE Populate_RBS_Element_Name
          ( p_resource_source_id  IN Number Default Null,
           p_resource_type_id    IN Number Default Null,
           x_rbs_element_name_id OUT NOCOPY Number,
           x_return_status       OUT NOCOPY Varchar2);

/* ----------------------------------------------------------------
    Wrapper API for handling RBS version changes. This API is called
    by the RBS summarization program. This API includes calls to all
    API's that handle RBS version changes in other PA modules. This
	API is called in the beginning of PJI concurrent program that
	handles RBS version changes
    ----------------------------------------------------------------*/
PROCEDURE PROCESS_RBS_CHANGES (
  p_rbs_header_id      IN NUMBER,
  p_new_rbs_version_id IN NUMBER,
  p_old_rbs_version_id IN NUMBER,
  x_return_status      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_data           OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

/* ----------------------------------------------------------------
 * API for upgrading a resource list to an RBS. This API is called
 * by the resource list upgrade concurrent program.
 ----------------------------------------------------------------*/
PROCEDURE UPGRADE_LIST_TO_RBS (
  p_resource_list_id   IN NUMBER,
  x_return_status      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_data           OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895


/*==============================================================================
This api is used to Refresh Resource names
=============================================================================*/

-- Procedure            : Refresh_Resource_Names
-- Type                 : Public Procedure
-- Purpose              : This API will be used to refresh Resource names associated with RBS.
--                      : This API will be called from :
--                      : 1.Concurrent program: Refresh RBS Element Names

-- Parameters           : None
--

PROCEDURE Refresh_Resource_Names(errbuf OUT NOCOPY VARCHAR2,
                                retcode OUT NOCOPY VARCHAR2);

/*****************************************************
 * Function    : Get_Concatenated_Name
 * Description : This Function is used to return the
 *               Concatenated Name given a rbs_element_id.
 *               Further details are specified in the Body.
 ***************************************************/
Function Get_Concatenated_name
   (p_rbs_element_id IN Number)
RETURN Varchar2;

/*******************************************************************
 * Procedure : Delete_proj_specific_RBS
 * Desc      : This API is used to delete the project specific RBS assignment
 *             once the project is deleted.
 ********************************************************************/
 PROCEDURE Delete_Proj_Specific_RBS(
   p_project_id         IN         NUMBER,
   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER);

Procedure Add_language;

END PA_RBS_UTILS;

 

/
