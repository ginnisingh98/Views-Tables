--------------------------------------------------------
--  DDL for Package RG_REPORT_SET_REQUESTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RG_REPORT_SET_REQUESTS_PKG" AUTHID CURRENT_USER AS
/* $Header: rgirsrqs.pls 120.2.12010000.1 2008/07/28 07:49:23 appldev ship $ */

  --
  -- NAME
  --   insert_report_set_request
  --
  -- DESCRIPTION
  --   Insert a report set request into rg_report_set_requests.
  --
  -- PARAMETERS
  --   Listed below
  --

  PROCEDURE insert_report_set_request (
                x_report_set_request_id  IN OUT NOCOPY NUMBER,
                x_report_set_id                 NUMBER,
                x_last_update_date              DATE,
                x_last_updated_by               NUMBER,
                x_last_update_login             NUMBER,
                x_creation_date                 DATE,
                x_created_by                    NUMBER,
                x_period_name                   VARCHAR2 DEFAULT NULL,
                x_accounting_date               DATE     DEFAULT NULL,
                x_unit_of_measure_id            VARCHAR2 DEFAULT NULL);

  --
  -- NAME
  --   insert_report_set_req_detail
  --
  -- DESCRIPTION
  --   Insert a row into rg_report_set_req_details. Should be called once
  --   for each report in the report set.
  --
  -- PARAMETERS
  --   Listed below
  --

  PROCEDURE insert_report_set_req_detail(x_report_set_request_id   NUMBER,
                                         x_sequence                NUMBER,
                                         x_report_id               NUMBER,
                                         x_concurrent_request_id   NUMBER);

END rg_report_set_requests_pkg;

/
