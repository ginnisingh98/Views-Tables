--------------------------------------------------------
--  DDL for Package ASO_TASK_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_TASK_INT" AUTHID CURRENT_USER AS
/* $Header: asoitsks.pls 120.2 2005/08/08 10:57:26 appldev ship $ */

-- Start of Comments
-- Package name     : ASO_TASK_INT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Copy_Tasks
(
    p_api_version          IN  NUMBER,
    p_init_msg_list        IN  VARCHAR2 := FND_API.G_TRUE,
    p_commit               IN  VARCHAR2 := FND_API.G_FALSE,
    p_old_object_id        IN  NUMBER,
    p_new_object_id        IN  NUMBER,
    p_old_object_type_code IN  VARCHAR2,
    p_new_object_type_code IN  VARCHAR2,
    p_new_object_name      IN  VARCHAR2,
    p_quote_version_flag   IN VARCHAR2 := FND_API.G_FALSE,
    x_return_status        OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    x_msg_count            OUT NOCOPY /* file.sql.39 change */   NUMBER,
    x_msg_data             OUT NOCOPY /* file.sql.39 change */   VARCHAR2
);

PROCEDURE Copy_Opp_Tasks_To_Qte
(
    p_api_version          IN  NUMBER,
    p_init_msg_list        IN  VARCHAR2 := FND_API.G_TRUE,
    p_commit               IN  VARCHAR2 := FND_API.G_FALSE,
    p_old_object_id        IN  NUMBER,
    p_new_object_id        IN  NUMBER,
    p_old_object_type_code IN  VARCHAR2,
    p_new_object_type_code IN  VARCHAR2,
    p_new_object_name      IN  VARCHAR2,
    x_return_status        OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    x_msg_count            OUT NOCOPY /* file.sql.39 change */   NUMBER,
    x_msg_data             OUT NOCOPY /* file.sql.39 change */   VARCHAR2
);

END ASO_TASK_INT;

 

/
