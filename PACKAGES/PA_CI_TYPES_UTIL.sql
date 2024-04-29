--------------------------------------------------------
--  DDL for Package PA_CI_TYPES_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CI_TYPES_UTIL" AUTHID CURRENT_USER AS
/* $Header: PACITYUS.pls 120.1 2005/08/19 16:19:23 mwasowic noship $ */

FUNCTION check_ci_type_name_exists(
  p_name VARCHAR2,
  p_short_name VARCHAR2,
  p_ci_type_id NUMBER default NULL
) RETURN BOOLEAN;

PROCEDURE check_ci_type_name_or_id(
  p_name IN VARCHAR2,
  p_ci_type_id IN NUMBER,
  p_check_id_flag IN VARCHAR2 := pa_startup.G_check_id_flag,
  x_ci_type_id OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_return_status OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_error_message_code OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

END pa_ci_types_util;
 

/
