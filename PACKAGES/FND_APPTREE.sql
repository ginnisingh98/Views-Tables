--------------------------------------------------------
--  DDL for Package FND_APPTREE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_APPTREE" AUTHID CURRENT_USER AS
/* $Header: AFTREES.pls 120.2 2005/10/24 06:08:36 mzasowsk ship $ */


TYPE node_rec_type IS record (state number
                             ,depth number
                             ,label varchar2(80)
                             ,icon  varchar2(30)
                             ,value varchar2(3900)
                             ,type  varchar2(30));

TYPE node_tbl_type IS TABLE OF node_rec_type
  INDEX BY BINARY_INTEGER;

PROCEDURE get_folder_properties (l_folder_id        number,
                                 l_obj_name         OUT NOCOPY /* file.sql.39 change */ varchar2,
                                 l_node_label       OUT NOCOPY /* file.sql.39 change */ varchar2,
                                 l_folder_type      OUT NOCOPY /* file.sql.39 change */ varchar2,
                                 l_value            OUT NOCOPY /* file.sql.39 change */ varchar2,
                                 l_sequence         OUT NOCOPY /* file.sql.39 change */ number,
                                 l_parent_folder_id OUT NOCOPY /* file.sql.39 change */ number,
                                 l_user_id          OUT NOCOPY /* file.sql.39 change */ number,
                                 l_public_flag      OUT NOCOPY /* file.sql.39 change */ varchar2);

FUNCTION insert_folder(l_obj_name         VARCHAR2,
                       l_node_label       VARCHAR2,
                       l_folder_type      VARCHAR2,
                       l_value            VARCHAR2,
                       l_parent_folder_id NUMBER,
                       l_public_flag      VARCHAR2,
                       l_language         VARCHAR2,
                       l_user_id          NUMBER,
                       after_folder_id    NUMBER default null) RETURN NUMBER;

PROCEDURE update_folder (l_folder_id        number,
                         l_user_id          number,
                         l_obj_name         varchar2 default 'APPTREE_NULL',
                         l_node_label       VARCHAR2 default 'APPTREE_NULL',
                         l_folder_type      VARCHAR2 default 'APPTREE_NULL',
                         l_value            VARCHAR2 default 'APPTREE_NULL',
                         l_sequence         NUMBER   default -99,
                         l_parent_folder_id NUMBER   default -99,
                         l_public_flag      VARCHAR2 default 'APPTREE_NULL',
                         l_language         VARCHAR2 default 'APPTREE_NULL');

FUNCTION unique_name(requested_folder_name varchar2,
                     l_parent_folder_id    number,
                     l_obj_name            varchar2,
                     l_user_id             number) return varchar2;

PROCEDURE delete_folder(l_folder_id number);

FUNCTION move_folder( l_folder_id        number
                     ,l_parent_folder_id number
                     ,after_folder_id    number
                     ,l_user_id          number
                     ,l_obj_name          varchar) return number ;


END fnd_apptree;
 

/
