--------------------------------------------------------
--  DDL for Package PA_PRODUCT_INSTALL_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PRODUCT_INSTALL_UTILS" AUTHID CURRENT_USER AS
/* $Header: PAPIUTLS.pls 120.1 2005/08/19 16:40:45 mwasowic noship $ */

 Function check_object_licensed ( p_object_type  IN  VARCHAR2,
                                 p_object_code  IN VARCHAR2)
   RETURN VARCHAR2;

  Procedure validate_object(
   p_object_type    IN  VARCHAR2,
   p_object_code    IN  VARCHAR2,
   x_ret_code       out NOCOPY varchar2, --File.Sql.39 bug 4440895
   x_return_status  out NOCOPY varchar2, --File.Sql.39 bug 4440895
   x_msg_count      out NOCOPY number, --File.Sql.39 bug 4440895
   x_msg_data       out NOCOPY varchar2); --File.Sql.39 bug 4440895

  Procedure check_function_licensed
  (
   p_function_name   IN  VARCHAR2,
   x_ret_code       out NOCOPY varchar2, --File.Sql.39 bug 4440895
   x_return_status  out NOCOPY varchar2, --File.Sql.39 bug 4440895
   x_msg_count      out NOCOPY number, --File.Sql.39 bug 4440895
   x_msg_data       out NOCOPY varchar2)   ; --File.Sql.39 bug 4440895

  /************************************************************************
   This function detremines the whether it is licensed to use a function or Not
   Name of the Function : check_function_licensed
   IN PARAMETERS  p_function_name - Name of the function
   RETURN VALUE   - Y - Eligible to use
                    N- Not  Eligible to use
    *************************************************************************/
   Function check_function_licensed ( p_function_name  IN  VARCHAR2)
   RETURN VARCHAR2;

  Procedure check_region_licensed
  (
   p_region_code    IN  VARCHAR2,
   x_ret_code       out NOCOPY varchar2, --File.Sql.39 bug 4440895
   x_return_status  out NOCOPY varchar2, --File.Sql.39 bug 4440895
   x_msg_count      out NOCOPY number, --File.Sql.39 bug 4440895
   x_msg_data       out NOCOPY varchar2)   ; --File.Sql.39 bug 4440895

  /************************************************************************
   This function detremines the whether it is licensed to use a AK region or Not
   Name of the Function : check_region_licensed
   IN PARAMETERS  p_function_name - Name of the function
   RETURN VALUE   - Y - Eligible to use
                    N- Not  Eligible to use
    *************************************************************************/

   Function check_region_licensed ( p_region_code  IN  VARCHAR2)
   RETURN VARCHAR2;

END PA_product_install_Utils;
 

/
