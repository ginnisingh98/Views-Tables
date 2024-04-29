--------------------------------------------------------
--  DDL for Package QA_CUSTOMER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_CUSTOMER" AUTHID CURRENT_USER AS
/* $Header: qarcs.pls 120.0 2005/05/24 19:18:45 appldev noship $ */
--
  PROCEDURE merge(
      req_id IN NUMBER,
      set_number IN NUMBER,
      process_mode IN VARCHAR2);
--
END qa_customer;

 

/
