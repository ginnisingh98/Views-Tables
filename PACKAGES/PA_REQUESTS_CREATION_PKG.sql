--------------------------------------------------------
--  DDL for Package PA_REQUESTS_CREATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_REQUESTS_CREATION_PKG" AUTHID CURRENT_USER as
/* $Header: PAYRPK1S.pls 120.1 2005/08/19 17:24:13 mwasowic noship $ */
--
-- Procedure     : insert_row
-- Purpose       : Create Row in PA_REQ_CREATE_TEMP.
--
--
PROCEDURE insert_row
      ( p_request_name                    IN PA_REQ_CREATE_TEMP.request_name%TYPE,
	      p_request_number                  IN PA_REQ_CREATE_TEMP.request_number%TYPE,
        p_request_type                    IN PA_REQ_CREATE_TEMP.request_type%TYPE,
        p_request_status_name             IN PA_REQ_CREATE_TEMP.request_status_name%TYPE,
        p_request_customer                IN PA_REQ_CREATE_TEMP.request_customer%TYPE,
        p_country			                    IN PA_REQ_CREATE_TEMP.country%TYPE,
        p_state	                          IN PA_REQ_CREATE_TEMP.state%TYPE,
        p_city				                    IN PA_REQ_CREATE_TEMP.city%TYPE,
        p_value                           IN PA_REQ_CREATE_TEMP.value%TYPE,
        p_currency_code                   IN PA_REQ_CREATE_TEMP.currency_code%TYPE,
        p_expected_proj_approval_date     IN PA_REQ_CREATE_TEMP.expected_project_approval_date%TYPE,
        p_source_reference                IN PA_REQ_CREATE_TEMP.source_reference%TYPE,
        x_return_status                   OUT  NOCOPY VARCHAR2                          , --File.Sql.39 bug 4440895
        x_msg_count                       OUT  NOCOPY NUMBER                            , --File.Sql.39 bug 4440895
        x_msg_data                        OUT  NOCOPY VARCHAR2 );  --File.Sql.39 bug 4440895



END PA_REQUESTS_CREATION_PKG;

 

/
