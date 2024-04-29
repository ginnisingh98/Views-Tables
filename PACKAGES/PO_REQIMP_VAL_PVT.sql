--------------------------------------------------------
--  DDL for Package PO_REQIMP_VAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_REQIMP_VAL_PVT" AUTHID CURRENT_USER AS
/* $Header: POXVRIVS.pls 120.1 2005/10/03 15:28:18 vinokris noship $ */

-- Constants used for the p_interface_table_code parameter
-- in val_pjm_proj_references
G_PO_REQUISITIONS_INTERFACE CONSTANT VARCHAR2(1) := 'R';
G_PO_REQ_DIST_INTERFACE	    CONSTANT VARCHAR2(1) := 'D';

/**
* Private Procedure: val_pjm_proj_references
* Requires: none
* Modifies: PO_INTERFACE_ERRORS, concurrent program log
* Parameters:
*  p_interface_table_code - the interface table to be validated;
*    if G_PO_REQUISITIONS_INTERFACE, use PO_REQUISITIONS_INTERFACE
*    if G_PO_REQ_DIST_INTERFACE, use PO_REQ_DIST_INTERFACE
* Effects: For all records with the given request ID in the specified
*  interface table, calls the PJM validation API to validate
*  project and task information. Writes any validation errors to
*  PO_INTERFACE_ERRORS and any validation warnings to the concurrent
*  program log.
* Returns:
*  x_return_status -
*    FND_API.G_RET_STS_UNEXP_ERROR if an unexpected error occurs
*    FND_API.G_RET_STS_SUCCESS otherwise
*/
PROCEDURE val_pjm_proj_references (
    p_api_version IN NUMBER,
    x_return_status OUT NOCOPY VARCHAR2,
    p_interface_table_code IN VARCHAR2,
    p_request_id IN NUMBER,
    p_user_id IN NUMBER,
    p_login_id IN NUMBER,
    p_prog_application_id IN NUMBER,
    p_program_id IN NUMBER
);

END PO_REQIMP_VAL_PVT;

 

/
