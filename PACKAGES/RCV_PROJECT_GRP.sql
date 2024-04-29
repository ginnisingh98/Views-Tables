--------------------------------------------------------
--  DDL for Package RCV_PROJECT_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_PROJECT_GRP" AUTHID CURRENT_USER AS
/* $Header: RCVGPRJS.pls 115.1 2004/02/10 06:18:27 usethura noship $ */

g_pkg_name CONSTANT VARCHAR2(30) := 'RCV_Project_GRP';


FUNCTION get_project_number
   (p_api_version           IN   NUMBER,
    p_init_msg_list         IN   VARCHAR2,
    p_transaction_id	    IN   NUMBER
   ) RETURN VARCHAR2;

FUNCTION get_task_number
   (p_api_version           IN   NUMBER,
    p_init_msg_list         IN   VARCHAR2,
    p_transaction_id	    IN   NUMBER
   ) RETURN VARCHAR2;

END RCV_Project_GRP;

 

/
