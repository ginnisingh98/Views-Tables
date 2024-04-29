--------------------------------------------------------
--  DDL for Package RCV_PROJECT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RCV_PROJECT_PVT" AUTHID CURRENT_USER AS
/* $Header: RCVVPRJS.pls 115.1 2004/02/10 06:17:02 usethura noship $ */

g_pkg_name CONSTANT VARCHAR2(30) := 'RCV_Project_PVT';

-- Global constants to hold the values of project number and task numbers
g_transaction_id	NUMBER;
g_project_number	VARCHAR2(25);
g_task_number		VARCHAR2(25);

PROCEDURE set_project_task_numbers
   (p_api_version           IN   NUMBER,
    p_init_msg_list         IN   VARCHAR2,
    p_transaction_id	    IN   NUMBER
   );

END RCV_Project_PVT;

 

/
