--------------------------------------------------------
--  DDL for Package FND_APPFLDR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_APPFLDR" AUTHID CURRENT_USER AS
/* $Header: AFFLDRS.pls 120.1 2005/07/02 04:06:50 appldev ship $ */


FUNCTION insert_fnd_folders (l_object          VARCHAR2,
                             l_name            VARCHAR2,
                             l_language        VARCHAR2,
                             l_window_width    NUMBER,
                             l_public_flag     VARCHAR2,
                             l_autoquery_flag  VARCHAR2,
                             l_created_by      NUMBER,
                             l_last_updated_by NUMBER,
                             l_where_clause    VARCHAR2 default null,
                             l_order_by        VARCHAR2 default null) RETURN NUMBER;


PROCEDURE insert_fnd_folder_columns (l_folder_id        NUMBER,
				     l_display_mode     VARCHAR2,
                                     l_item_name        VARCHAR2,
                                     l_sequence         NUMBER,
                                     l_created_by       NUMBER,
                                     l_last_updated_by  NUMBER,
                                     l_item_width       NUMBER,
                                     l_item_prompt      VARCHAR2,
                                     l_x_position       NUMBER,
                                     l_y_position       NUMBER);


PROCEDURE insert_fnd_default_folders (l_object          VARCHAR2,
                                      l_user_id         NUMBER,
                                      l_folder_id       NUMBER,
                                      l_created_by      NUMBER,
                                      l_last_updated_by NUMBER);


PROCEDURE update_fnd_folders (l_folder_id               NUMBER,
                              l_name		        VARCHAR2,
                              l_window_width            NUMBER,
                              l_public_flag             VARCHAR2,
                              l_autoquery_flag          VARCHAR2,
                              l_created_by              NUMBER,
                              l_last_updated_by         NUMBER,
                              l_where_clause            VARCHAR2,
                              l_order_by                VARCHAR2);


PROCEDURE delete_fnd_default_folders (l_object   VARCHAR2,
                                      l_user_id  NUMBER,
                                      l_language VARCHAR2);


PROCEDURE delete_fnd_default_folders (l_folder_id NUMBER);


PROCEDURE delete_fnd_folder_columns (l_folder_id NUMBER);


PROCEDURE delete_fnd_folders (l_folder_id NUMBER);


END fnd_appfldr;
 

/
