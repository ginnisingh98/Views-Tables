--------------------------------------------------------
--  DDL for Package PA_FP_GEN_AMT_WRP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FP_GEN_AMT_WRP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAFPGAWS.pls 120.0 2005/05/30 13:50:02 appldev noship $ */

    PROCEDURE GEN_AMT_WRP(
		errbuff OUT NOCOPY VARCHAR2,
              	retcode OUT NOCOPY VARCHAR2,
                p_organization_id	IN NUMBER,
     		p_project_type_id  	IN NUMBER,
		p_proj_manager_id 	IN NUMBER,
                p_from_project_no 	IN VARCHAR2,
                p_to_project_no  	IN VARCHAR2,
                p_plan_type_id 		IN NUMBER );

   /*
   PROCEDURE Get_Project_Num_Range (
                 p_proj_num_from        IN      VARCHAR2,
                 p_proj_num_to          IN      VARCHAR2,
                 p_proj_num_from_out    OUT     VARCHAR2,
                 p_proj_num_to_out      OUT     VARCHAR2 );
    */
END PA_FP_GEN_AMT_WRP_PKG;

 

/
