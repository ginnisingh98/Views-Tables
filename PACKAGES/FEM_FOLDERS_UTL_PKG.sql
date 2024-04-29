--------------------------------------------------------
--  DDL for Package FEM_FOLDERS_UTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_FOLDERS_UTL_PKG" AUTHID CURRENT_USER AS
/* $Header: fem_folders_utl.pls 120.2 2005/07/26 14:08:04 appldev ship $ */

PROCEDURE get_personal_folder (p_user_id IN NUMBER,
                               p_folder_id OUT NOCOPY NUMBER);

PROCEDURE assign_user_to_folder (p_api_version      IN  NUMBER,
                                 p_commit           IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
                                 p_user_id          IN  NUMBER DEFAULT FND_GLOBAL.USER_ID,
                                 p_folder_id        IN  NUMBER,
                                 p_write_flag       IN  VARCHAR2 DEFAULT 'N',
                                 x_msg_count        OUT NOCOPY NUMBER,
                                 x_msg_data         OUT NOCOPY VARCHAR2,
                                 x_return_status    OUT NOCOPY VARCHAR2);
END fem_folders_utl_pkg;

 

/
