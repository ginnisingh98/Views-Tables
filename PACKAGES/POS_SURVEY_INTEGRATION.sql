--------------------------------------------------------
--  DDL for Package POS_SURVEY_INTEGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_SURVEY_INTEGRATION" AUTHID CURRENT_USER AS
/* $Header: POSSURIS.pls 120.1 2005/12/07 18:26:03 abtrived noship $ */


PROCEDURE save_transaction
  (p_flow_key IN VARCHAR2,
  p_supplier_reg_id IN NUMBER,
  p_vendor_id IN NUMBER,
  p_survey_transaction_id IN NUMBER,
  p_respondent_table_name IN VARCHAR2,
  p_respondent_id IN NUMBER,
  x_status OUT NOCOPY VARCHAR2,
  x_msg  OUT NOCOPY VARCHAR2,
  p_map_id IN NUMBER default null
  );

END pos_survey_integration;

 

/
