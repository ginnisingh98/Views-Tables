--------------------------------------------------------
--  DDL for Package ASO_NOTES_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_NOTES_INT" AUTHID CURRENT_USER AS
/* $Header: asoinots.pls 120.1 2005/06/29 12:34:06 appldev ship $ */

-- Start of Comments
-- Package name     : ASO_NOTES_INT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Copy_Notes
(
    p_api_version          IN  NUMBER                     ,
    p_init_msg_list        IN  VARCHAR2 := FND_API.G_TRUE ,
    p_commit               IN  VARCHAR2 := FND_API.G_FALSE,
    p_old_object_id        IN  NUMBER                     ,
    p_new_object_id        IN  NUMBER                     ,
    p_old_object_type_code IN  VARCHAR2                   ,
    p_new_object_type_code IN  VARCHAR2                   ,
    x_return_status        OUT NOCOPY /* file.sql.39 change */   VARCHAR2                   ,
    x_msg_count            OUT NOCOPY /* file.sql.39 change */   NUMBER                     ,
    x_msg_data             OUT NOCOPY /* file.sql.39 change */   VARCHAR2
);


PROCEDURE Copy_Opp_Notes_To_Qte
(
    p_api_version          IN  NUMBER                     ,
    p_init_msg_list        IN  VARCHAR2 := FND_API.G_TRUE ,
    p_commit               IN  VARCHAR2 := FND_API.G_FALSE,
    p_old_object_id        IN  NUMBER                     ,
    p_new_object_id        IN  NUMBER                     ,
    p_old_object_type_code IN  VARCHAR2                   ,
    p_new_object_type_code IN  VARCHAR2                   ,
    x_return_status        OUT NOCOPY /* file.sql.39 change */   VARCHAR2                   ,
    x_msg_count            OUT NOCOPY /* file.sql.39 change */   NUMBER                     ,
    x_msg_data             OUT NOCOPY /* file.sql.39 change */   VARCHAR2
);

PROCEDURE Copy_Notes_copy_quote
(
    p_api_version          IN  NUMBER                     ,
    p_init_msg_list        IN  VARCHAR2 := FND_API.G_TRUE ,
    p_commit               IN  VARCHAR2 := FND_API.G_FALSE,
    p_old_object_id        IN  NUMBER                     ,
    p_new_object_id        IN  NUMBER                     ,
    p_old_object_type_code IN  VARCHAR2                   ,
    p_new_object_type_code IN  VARCHAR2                   ,
    x_return_status        OUT NOCOPY /* file.sql.39 change */   VARCHAR2                   ,
    x_msg_count            OUT NOCOPY /* file.sql.39 change */   NUMBER                     ,
    x_msg_data             OUT NOCOPY /* file.sql.39 change */   VARCHAR2
);

END ASO_NOTES_INT;

 

/
