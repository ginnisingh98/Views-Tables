--------------------------------------------------------
--  DDL for Package PA_REQUESTS_CREATION_WARN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_REQUESTS_CREATION_WARN_PKG" AUTHID CURRENT_USER as
/* $Header: PAYRPK4S.pls 120.1 2005/08/19 17:24:41 mwasowic noship $ */
--
-- Procedure     : insert_row
-- Purpose       : Create Row in PA_REQ_CREATE_WARN_TEMP.
--
--
PROCEDURE insert_row
      ( p_request_name                    IN PA_REQ_CREATE_WARN_TEMP.request_name%TYPE,
	      p_warning			                    IN PA_REQ_CREATE_WARN_TEMP.warning%TYPE,
        x_return_status                   OUT  NOCOPY VARCHAR2                          , --File.Sql.39 bug 4440895
        x_msg_count                       OUT  NOCOPY NUMBER                            , --File.Sql.39 bug 4440895
        x_msg_data                        OUT  NOCOPY VARCHAR2 );  --File.Sql.39 bug 4440895



END PA_REQUESTS_CREATION_WARN_PKG;

 

/
