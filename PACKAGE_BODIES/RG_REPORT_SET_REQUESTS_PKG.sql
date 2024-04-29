--------------------------------------------------------
--  DDL for Package Body RG_REPORT_SET_REQUESTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RG_REPORT_SET_REQUESTS_PKG" AS
/* $Header: rgirsrqb.pls 120.1.12010000.2 2008/11/10 10:46:33 kmotepal ship $ */


  --
  -- PRIVATE FUNCTIONS
  --

  FUNCTION get_unique_id RETURN NUMBER IS
    next_id     NUMBER;
  BEGIN
    select RG_REPORT_SET_REQUESTS_S.NEXTVAL
    into next_id
    from dual;

    return (next_id);
  END get_unique_id;


  --
  -- PUBLIC FUNCTIONS
  --

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
                x_report_set_request_id     IN OUT NOCOPY NUMBER,
                x_report_set_id             NUMBER,
                x_last_update_date          DATE,
                x_last_updated_by           NUMBER,
                x_last_update_login         NUMBER,
                x_creation_date             DATE,
                x_created_by                NUMBER,
                x_period_name               VARCHAR2,
                x_accounting_date           DATE,
                x_unit_of_measure_id        VARCHAR2) IS
    CURSOR C IS
      SELECT rowid
      FROM   RG_REPORT_SET_REQUESTS
      WHERE  report_set_request_id = x_report_set_request_id;
    rowid    VARCHAR2(30);
  BEGIN
    x_report_set_request_id := rg_report_set_requests_pkg.get_unique_id;

    INSERT INTO RG_REPORT_SET_REQUESTS
      ( REPORT_SET_REQUEST_ID,
	REPORT_SET_ID,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN,
        CREATION_DATE,
        CREATED_BY,
	PERIOD_NAME,
	ACCOUNTING_DATE,
	UNIT_OF_MEASURE_ID)
    VALUES
      ( x_report_set_request_id,
	x_report_set_id,
	x_last_update_date,
	x_last_updated_by,
	x_last_update_login,
        x_creation_date,
        x_created_by,
	x_period_name,
	x_accounting_date,
	x_unit_of_measure_id);

    OPEN C;
    FETCH C INTO rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      RAISE NO_DATA_FOUND;
    end if;
    CLOSE C;

  END insert_report_set_request;

  --
  -- NAME
  --   insert_report_set_req_detail
  --
  -- DESCRIPTION
  --   Insert a row into rg_report_set_req_details.
  --
  -- PARAMETERS
  --   Listed below
  --

  PROCEDURE insert_report_set_req_detail(x_report_set_request_id   NUMBER,
                                         x_sequence                NUMBER,
                                         x_report_id               NUMBER,
                                         x_concurrent_request_id   NUMBER) IS
    CURSOR C IS
      SELECT rowid
      FROM   RG_REPORT_SET_REQ_DETAILS
      WHERE  report_set_request_id = x_report_set_request_id
      AND    sequence = x_sequence;
    rowid    VARCHAR2(30);
  BEGIN

    INSERT INTO RG_REPORT_SET_REQ_DETAILS
      ( REPORT_SET_REQUEST_ID,
	SEQUENCE,
	REPORT_ID,
	CONCURRENT_REQUEST_ID,
        REPORT_SEQUENCE)
    VALUES
      ( x_report_set_request_id,
	x_sequence,
	x_report_id,
	x_concurrent_request_id,
        -1);

    OPEN C;
    FETCH C INTO rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      RAISE NO_DATA_FOUND;
    end if;
    CLOSE C;

  END insert_report_set_req_detail;

END rg_report_set_requests_pkg;

/
