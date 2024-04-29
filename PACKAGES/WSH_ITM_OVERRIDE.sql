--------------------------------------------------------
--  DDL for Package WSH_ITM_OVERRIDE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_ITM_OVERRIDE" AUTHID CURRENT_USER as
/* $Header: WSHITOVS.pls 120.0.12010000.1 2008/07/29 06:13:55 appldev ship $ */
  --
  -- Package: WSH_ITM_OVERRIDE
  --
  -- Purpose: To Override the errors encountered during the Adapter Processing.
  --
  --
  -- PRIVATE FUNCTIONS
  --

  --
  -- Name
  --
  --   ITM_Launch_Override
  --
  -- Purpose
  --   This procedure selects all the eligible records from the tables
  --   WSH_ITM_REQUEST_CONTROL, WSH_ITM_RESPONSE_HEADERS
  --   and WSH_ITM_RESPONSE_LINES  for Override.
  --
  --   For every record, it first updates the process_flag in the table
  --   WSH_ITM_REQUEST_CONTROL to 3, meaning OVERRIDE and calls Application
  --   specific custom procedure.
  --
  --   Arguments
  --   ERRBUF                   Required by Concurrent Processing.
  --   RETCODE                  Required by Concurrent Processing.
  --   P_APPLICATION_ID         Application ID
  --   P_OVERRIDE_TYPE          Denotes SYSTEM/DATA/UNPROCESSED
  --   P_ERROR_TYPE             Values for Error Type
  --   P_ERROR_CODE             Values for Error Code.
  --   P_PREFERENCE_ID          Reference Number for Integrating Application
  --                            Ex: Order Number for OM.
  --   P_REFERENCE_LINE_ID      Reference Line for Integrating Application
  --                            Ex : Order Line Number for OM.
  --   P_VENDOR_ID              Value for Vendor ID.
  --   P_PARTY_TYPE             Value for Party Type
  --   P_PARTY_ID               Value for Party ID
  --
  --   Returns [ for functions ]
  --
  -- Notes
  --

PROCEDURE ITM_Launch_Override
(
    errbuf                     OUT NOCOPY   VARCHAR2  ,
    retcode                    OUT NOCOPY   NUMBER    ,
    p_application_id           IN   NUMBER    ,
    p_override_type            IN   VARCHAR2  DEFAULT NULL,
    p_reference_id             IN   NUMBER    DEFAULT NULL,
    p_dummy                     IN   NUMBER   DEFAULT  NULL,
    p_reference_line_id        IN   NUMBER    DEFAULT NULL,
    p_error_type               IN   VARCHAR2  DEFAULT NULL,
    p_error_code               IN   VARCHAR2  DEFAULT NULL,
    p_vendor_id                IN   NUMBER    DEFAULT NULL,
    p_party_type               IN   VARCHAR2  DEFAULT NULL,
    p_party_id               IN     number    DEFAULT NULL
);


PROCEDURE Call_Custom_API
(
  p_request_control_id   IN   NUMBER   DEFAULT NULL,
  p_request_set_id       IN   NUMBER   DEFAULT NULL,
  p_appl_id              IN   NUMBER,
  x_return_status        OUT NOCOPY   VARCHAR2
);

END WSH_ITM_OVERRIDE;

/
