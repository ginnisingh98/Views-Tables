--------------------------------------------------------
--  DDL for Package PO_HXC_INTERFACE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_HXC_INTERFACE_PVT" AUTHID CURRENT_USER AS
/* $Header: POXVIHXS.pls 120.2 2007/12/24 16:09:42 cvardia ship $*/

-- Constants used when calling the OTL APIs:
g_bld_blk_info_type_PO    CONSTANT VARCHAR2(20) := 'PURCHASING';
g_bld_blk_info_type_PA    CONSTANT VARCHAR2(20) := 'PROJECTS';
g_scope_DETAIL            CONSTANT VARCHAR2(20) := 'DETAIL';
g_retrieval_process_NONE  CONSTANT VARCHAR2(20) := 'None';
g_field_AMOUNT            CONSTANT VARCHAR2(20) := 'PO Billable Amount';
g_field_PO_HEADER_ID      CONSTANT VARCHAR2(20) := 'PO Header Id';
g_field_PO_LINE_ID        CONSTANT VARCHAR2(20) := 'PO Line Id';
g_field_TASK_ID           CONSTANT VARCHAR2(20) := 'Task_Id';
g_field_PROJECT_ID        CONSTANT VARCHAR2(20) := 'Project_Id';
g_status_SUBMITTED        CONSTANT VARCHAR2(20) := 'SUBMITTED';

-- Functions to return the constants, for use from PLDs:
FUNCTION field_po_header_id RETURN VARCHAR2;
FUNCTION field_po_line_id RETURN VARCHAR2;

-- See the package body for a detailed description of this function.
FUNCTION check_timecard_exists (
                 p_person_id   IN   NUMBER,
                 po_line_id    IN   NUMBER)
RETURN VARCHAR2;


-- See the package body for a detailed description of this procedure.
PROCEDURE get_timecard_amount (
  p_api_version             IN NUMBER,
  x_return_status           OUT NOCOPY VARCHAR2,
  p_po_line_id              IN PO_LINES_ALL.po_line_id%TYPE,
  x_amount                  OUT NOCOPY NUMBER
);

-- See the package body for a detailed description of this procedure.
PROCEDURE check_timecard_exists (
  p_api_version             IN NUMBER,
  x_return_status           OUT NOCOPY VARCHAR2,
  p_field_name              IN VARCHAR2,
  p_field_value             IN VARCHAR2,
  p_end_date                IN PO_LINES_ALL.expiration_date%TYPE,
  x_timecard_exists         OUT NOCOPY BOOLEAN
);

PROCEDURE get_pa_timecard_amount (
  p_api_version             IN NUMBER,
  x_return_status           OUT NOCOPY VARCHAR2,
  p_po_line_id              IN PO_LINES_ALL.po_line_id%TYPE,
  p_project_id              IN PO_DISTRIBUTIONS_ALL.project_id%TYPE ,
  p_task_id                 IN PO_DISTRIBUTIONS_ALL.task_id%TYPE,
  x_amount                  OUT NOCOPY NUMBER);

END PO_HXC_INTERFACE_PVT;

/
