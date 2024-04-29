--------------------------------------------------------
--  DDL for Package AZ_R12_UPD_DET_LOG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AZ_R12_UPD_DET_LOG" AUTHID CURRENT_USER AS
/* $Header: azr12detlog.pls 120.4 2008/05/16 06:56:05 gnamasiv noship $ */

  -- Author  : LMATHUR
  -- Created : 12/2/2007 2:22:06 PM
  -- Purpose : Update the status for the detailed logging records

application_exception EXCEPTION;
  PRAGMA exception_init(application_exception, -20001);

  -- Public type declarations
   TYPE TYP_ASSOC_ARR IS TABLE OF VARCHAR2(32767) INDEX BY VARCHAR2(4000);
   TYPE TYP_NEST_TAB_VARCHAR IS TABLE OF VARCHAR2(32767);
   TYPE TYP_NEST_TAB_NUMBER IS TABLE OF NUMBER;

  -- Public constant declarations
--  <ConstantName> constant <Datatype> := <Value>;

  -- Public variable declarations
--  <VariableName> <Datatype>;

  -- Public function and procedure declarations
--  function <FunctionName>(<Parameter> <Datatype>) return <Datatype>;
    PROCEDURE update_status(p_request_id IN NUMBER, p_source IN VARCHAR2);
    PROCEDURE update_det_log_counts( p_request_id IN NUMBER,  p_source     IN VARCHAR2, p_update_xsl OUT NOCOPY varchar2);
END AZ_R12_UPD_DET_LOG;

/
