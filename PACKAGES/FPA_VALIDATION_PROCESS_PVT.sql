--------------------------------------------------------
--  DDL for Package FPA_VALIDATION_PROCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FPA_VALIDATION_PROCESS_PVT" AUTHID CURRENT_USER as
/* $Header: FPAVVLPS.pls 120.5 2006/03/20 19:29:34 appldev noship $ */
G_API_NAME         CONSTANT VARCHAR2(80) := 'FPA_VALIDATION_PROCESS_PVT';

SUBTYPE PROJECT_ID_TBL_TYPE is FPA_VALIDATION_PVT.PROJECT_ID_TBL_TYPE;

/* ***********************************************************************
Desc:
parameters:
return:
***************************************************************************/

PROCEDURE Validate
(
    p_api_version           IN              NUMBER,
    p_init_msg_list         IN              VARCHAR2,
    p_validation_set        IN              VARCHAR2,
    p_header_object_id      IN              NUMBER,
    p_header_object_type    IN              VARCHAR2,
    p_line_projects_tbl     IN              PROJECT_ID_TBL_TYPE,
    x_return_status         OUT NOCOPY      VARCHAR2,
    x_msg_count             OUT NOCOPY      NUMBER,
    x_msg_data              OUT NOCOPY      VARCHAR2
);

PROCEDURE Budget_Version_Validations
(
    p_api_version           IN              NUMBER,
    p_init_msg_list         IN              VARCHAR2,
    p_validation_set        IN              VARCHAR2,
    p_header_object_id      IN              NUMBER,
    p_header_object_type    IN              VARCHAR2,
    x_return_status         OUT NOCOPY      VARCHAR2,
    x_msg_count             OUT NOCOPY      NUMBER,
    x_msg_data              OUT NOCOPY      VARCHAR2
);

PROCEDURE Budget_Version_Validations
(
    p_api_version           IN              NUMBER,
    p_init_msg_list         IN              VARCHAR2,
    p_validation_set        IN              VARCHAR2,
    p_header_object_id      IN              NUMBER,
    p_header_object_type    IN              VARCHAR2,
    p_line_projects_tbl     IN              PROJECT_ID_TBL_TYPE,
    p_type                  IN              VARCHAR2,
    x_return_status         OUT NOCOPY      VARCHAR2,
    x_msg_count             OUT NOCOPY      NUMBER,
    x_msg_data              OUT NOCOPY      VARCHAR2
);

FUNCTION Object_Name
(
   p_object_id      IN  NUMBER,
   p_object_type    IN  VARCHAR2
   ) RETURN VARCHAR2;


END FPA_VALIDATION_PROCESS_PVT;

 

/
