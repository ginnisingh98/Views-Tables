--------------------------------------------------------
--  DDL for Package PO_GMS_INTEGRATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_GMS_INTEGRATION_PVT" AUTHID CURRENT_USER AS
/* $Header: POXVGMSS.pls 120.1 2005/08/31 16:24:37 jmellen noship $ */

c_DML_OPERATION_INSERT CONSTANT VARCHAR2(10) := 'INSERT';
c_DML_OPERATION_DELETE CONSTANT VARCHAR2(10) := 'DELETE';
c_DML_OPERATION_UPDATE CONSTANT VARCHAR2(10) := 'UPDATE';

-------------------------------------------------------------------------------
--Start of Comments
--Name: maintain_adl (ADL stands for Award Distribution Lines in Grants)
--Pre-reqs:
--  None.
--Modifies:
--  GMS_AWARD_DISTRIBUTIONS
--Locks:
--  None.
--Function:
--  When PO/Req distribution lines are created from CopyDoc, Autocreate,
--  PO Release Process, or Change PO, we need to call Grants API to generate
--  new award distribution lines if the parent distribution record
--  references an award.
--Parameters:
--IN:
--p_api_version
--  Specifies the GMS API version.
--p_caller
--  Specifies who the caller is.
--  Possible values for p_caller are:
--  AUTOCREATE, CHANGEPO, COPYDOC, CREATE_RELEASE
--OUT:
--x_return_status
--  Represents the result returned by the GMS API and
--  will have one of the following values:
--     G_RET_STS_SUCCESS    = 'S'
--     G_RET_STS_ERROR      = 'E'
--     G_RET_STS_UNEXP_ERROR= 'U'
--x_msg_count
--  Holds the number of messages in the GMS API message list.
--x_msg_data
--  Holds the error messages returned by the GMS API.
--IN OUT
--x_po_gms_interface_obj
--  Is of type gms_po_interface_type.
--  gms_po_interface_type is a SQL object having the following table
--  elements:
--      distribution_id   Holds distribution id's
--      distribution_num  Holds distribution numbers
--      project_id        Holds project id's
--      task_id           Holds task id's
--      award_set_id_in   Holds award set id references
--      award_set_id_out  Holds new award distribution line references
--                        as returned by GMS API's.
--Testing:
--  None
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE maintain_adl (
    p_api_version            IN             NUMBER,
    x_return_status          OUT NOCOPY     VARCHAR2,
    x_msg_count              OUT NOCOPY     NUMBER,
    x_msg_data               OUT NOCOPY     VARCHAR2,
    p_caller                 IN             VARCHAR2,
    x_po_gms_interface_obj   IN OUT NOCOPY  gms_po_interface_type
);

FUNCTION get_gms_enabled_flag(
  p_org_id IN NUMBER
) RETURN VARCHAR2;

FUNCTION is_gms_enabled
RETURN BOOLEAN;

PROCEDURE validate_award_data(
  p_dist_id_tbl                 IN PO_TBL_NUMBER
, p_project_id_tbl              IN PO_TBL_NUMBER
, p_task_id_tbl                 IN PO_TBL_NUMBER
, p_award_number_tbl            IN PO_TBL_VARCHAR2000
, p_expenditure_type_tbl        IN PO_TBL_VARCHAR30
, p_expenditure_item_date_tbl   IN PO_TBL_DATE
, x_failure_dist_id_tbl         OUT NOCOPY PO_TBL_NUMBER
, x_failure_message_tbl         OUT NOCOPY PO_TBL_VARCHAR4000
);

PROCEDURE get_award_id(
  p_award_number_tbl IN PO_TBL_VARCHAR2000
, x_award_id_tbl     OUT NOCOPY PO_TBL_NUMBER
);

PROCEDURE maintain_po_adl(
  p_dml_operation       IN VARCHAR2
, p_dist_id             IN NUMBER
, p_award_number        IN VARCHAR2
, p_project_id          IN NUMBER
, p_task_id             IN NUMBER
, x_award_set_id        OUT NOCOPY NUMBER
);

FUNCTION get_number_from_award_set_id(
  p_award_set_id IN NUMBER
) RETURN VARCHAR2;

PROCEDURE is_award_required_for_project(
  p_project_id          IN NUMBER
, x_award_required_flag OUT NOCOPY VARCHAR2
);

END PO_GMS_INTEGRATION_PVT;

 

/
