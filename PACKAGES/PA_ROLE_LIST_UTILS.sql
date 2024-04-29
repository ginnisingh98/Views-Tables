--------------------------------------------------------
--  DDL for Package PA_ROLE_LIST_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_ROLE_LIST_UTILS" AUTHID CURRENT_USER AS
 /* $Header: PARLSTUS.pls 120.1 2005/08/19 16:55:50 mwasowic noship $ */

--Public procedure to check role list name and id
PROCEDURE check_role_list_name_or_id(
  p_role_list_id IN NUMBER,
  p_role_list_name IN VARCHAR2,
  p_check_id_flag IN VARCHAR2,
  x_role_list_id OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_return_status OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_error_message_code OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895
END PA_ROLE_LIST_UTILS;
 

/
