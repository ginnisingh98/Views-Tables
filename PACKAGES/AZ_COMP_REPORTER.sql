--------------------------------------------------------
--  DDL for Package AZ_COMP_REPORTER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AZ_COMP_REPORTER" AUTHID CURRENT_USER AS
/* $Header: azcompreporters.pls 120.4 2006/05/29 07:16:50 gagupta noship $ */

  -- Author  : GAGUPTA
  -- Created : 5/27/2005 2:22:06 PM
  -- Purpose : comparison reporter pl/sql procedure

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
    PROCEDURE compare(p_request_id IN NUMBER, p_source IN VARCHAR2, p_diff_schema_url IN VARCHAR2, p_exclude_details IN VARCHAR2);
END AZ_COMP_REPORTER;

 

/
