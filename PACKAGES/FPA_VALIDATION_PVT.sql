--------------------------------------------------------
--  DDL for Package FPA_VALIDATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FPA_VALIDATION_PVT" AUTHID CURRENT_USER as
/* $Header: FPAVVALS.pls 120.5 2006/03/20 19:11:32 appldev noship $ */
G_API_NAME         CONSTANT VARCHAR2(80) := 'FPA_VALIDATION_PVT';

SUBTYPE FPA_VALIDATION_LINES_REC IS FPA_VALIDATION_LINES%ROWTYPE;
TYPE PROJECT_ID_TBL_TYPE is TABLE of varchar2(4000) index by binary_integer;

G_ERROR         CONSTANT VARCHAR2(1)     := 'E';
G_WARNING       CONSTANT VARCHAR2(1)     := 'W';
G_INFORMATION   CONSTANT VARCHAR2(1)     := 'I';

G_NO_RESOURCE_REC    CONSTANT INTEGER         := 0;
G_RESOURCE_LOCKED    CONSTANT INTEGER         := 1;
G_RESOURCE_BUSY      CONSTANT INTEGER         := 2;

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


PROCEDURE Validate
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

FUNCTION Add_Validation
(
    p_validation           IN VARCHAR2,
    p_severity_code        IN VARCHAR2,
    p_object_id            IN NUMBER,
    p_object_type          IN VARCHAR2
) RETURN BOOLEAN;

PROCEDURE Create_Validation_Line
(
    p_api_version          IN              NUMBER,
    p_init_msg_list        IN              VARCHAR2,
    p_validation_set       IN              VARCHAR2,
    p_validation_lines_rec IN              FPA_VALIDATION_LINES_REC,
    x_validation_id        OUT NOCOPY      NUMBER,
    x_return_status        OUT NOCOPY      VARCHAR2,
    x_msg_count            OUT NOCOPY      NUMBER,
    x_msg_data             OUT NOCOPY      VARCHAR2
    );


PROCEDURE Initialize;

PROCEDURE Close_Validations;

FUNCTION Count_Validations RETURN NUMBER;

FUNCTION Check_Error_Level
(
    p_object_id   IN NUMBER,
    p_object_type IN VARCHAR2,
    p_error_level IN VARCHAR2) RETURN BOOLEAN;

FUNCTION Validation RETURN BOOLEAN;

END FPA_VALIDATION_PVT;

 

/
