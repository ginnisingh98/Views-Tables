--------------------------------------------------------
--  DDL for Package CS_QKMENU_DML_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_QKMENU_DML_PKG" AUTHID CURRENT_USER as
/* $Header: csqkmens.pls 115.3 2002/12/17 05:09:43 bhroy ship $ */
-- 12-17-2002	bhroy 	added WHENEVER OSERROR EXIT FAILURE ROLLBACK


  PROCEDURE SAVE_FOLDER_INTO_DB(l_user_id         IN  NUMBER,
						  l_description     IN  VARCHAR2,
						  l_folder_name     IN  VARCHAR2, /*save as name*/
						  l_default_flag    IN  VARCHAR2);


  PROCEDURE insert_holder(l_user_folder_id        NUMBER,
                          l_function_filter_id    NUMBER,
                          l_user_id               NUMBER,
                          l_filter_value          VARCHAR2,
                          l_filter_value_id       NUMBER := null
                          );


  PROCEDURE update_holder(l_user_folder_id        NUMBER,
                          l_function_filter_id    NUMBER,
                          l_user_id               NUMBER,
                          l_filter_value          VARCHAR2,
                          l_filter_value_id       NUMBER := null
                          );

  PROCEDURE insert_empty_folder(l_user_id     NUMBER,
                                l_folder_name VARCHAR2);


  PROCEDURE new_folder(l_user_id      NUMBER,
                       folder_name    VARCHAR2,
                       description    VARCHAR2);

  PROCEDURE update_default_flag(l_user_id      NUMBER,
                                l_folder_name  VARCHAR2,
                                l_default_flag VARCHAR2);


END CS_QKMENU_DML_PKG;


 

/
