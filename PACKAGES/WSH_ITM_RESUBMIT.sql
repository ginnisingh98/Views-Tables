--------------------------------------------------------
--  DDL for Package WSH_ITM_RESUBMIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_ITM_RESUBMIT" AUTHID CURRENT_USER as
/* $Header: WSHITRSS.pls 115.8 2003/11/05 07:29:50 shravisa ship $ */
  --
  -- Package: WSH_ITM_RESUBMIT
  --
  -- Purpose: To Override the errors encountered during the Adapter Processing.
  --
  --
  -- PRIVATE FUNCTIONS
  --

  --
  -- Name
  --   Resubmit_Requests
  -- Purpose
  --   This procedure selects all the eligible records from the tables
  --   WSH_ITM_REQUEST_CONTROL, WSH_ITM_RESPONSE_HEADERS
  --   and WSH_ITM_RESPONSE_LINES  for Resubmit.
  --   For every record, it first updates the process_flag in the table
  --   WSH_ITM_REQUEST_CONTROL to 0, meaning RESUBMIT and calls  the
  --   Application specific API to update the workflow.
  --
  -- Arguments
  -- ERRBUF                   Required by Concurrent Processing.
  -- RETCODE                  Required by Concurrent Processing.
  -- P_APPLICATION_ID         Application ID
  -- P_RESUBMIT_TYPE          Denotes SYSTEM/DATA
  -- P_ERROR_TYPE             Values for Error Type
  -- P_ERROR_CODE             Values for Error Code.
  -- P_PREFERENCE_ID          Reference Number for Integrating Application
  --                          Ex: Order Number for OM.
  -- P_REFERENCE_LINE_ID      Reference Line for Integrating Application
  --                          Ex : Order Line Number for OM.
  -- P_VENDOR_ID              Value for Vendor ID.
  -- P_PARTY_TYPE             Value for Party Type
  -- P_PARTY_ID               Value for Party ID
  --
  -- Returns [ for functions ]
  --
  -- Notes
  --

PROCEDURE ITM_Resubmit_Requests
(
    errbuf                     OUT NOCOPY   VARCHAR2,
    retcode                    OUT NOCOPY   NUMBER,
    p_application_id           IN   NUMBER,
    p_resubmit_type            IN   VARCHAR2 DEFAULT NULL,
    p_dummy                    IN   NUMBER   DEFAULT NULL,
    p_reference_id             IN   NUMBER   DEFAULT NULL,
    p_error_type               IN   VARCHAR2 DEFAULT NULL,
    p_error_code               IN   VARCHAR2 DEFAULT NULL,
    p_vendor_id                IN   NUMBER   DEFAULT NULL,
    p_reference_line_id        IN   NUMBER   DEFAULT NULL,
    p_party_type               IN   VARCHAR2 DEFAULT NULL,
    p_party_id                 IN   NUMBER   DEFAULT NULL
);

END WSH_ITM_RESUBMIT;

 

/
