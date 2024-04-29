--------------------------------------------------------
--  DDL for Package IGS_ST_VAL_GSE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_ST_VAL_GSE" AUTHID CURRENT_USER AS
  /* $Header: IGSST09S.pls 115.5 2002/11/29 04:12:21 nsidana ship $ */
 --
  -- Validate the government snapshot.
  FUNCTION stap_val_govt_snpsht(
  p_submission_yr IN NUMBER ,
  p_submission_number IN NUMBER ,
  p_transaction_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY  VARCHAR2)
RETURN BOOLEAN;

END IGS_ST_VAL_GSE;

 

/
