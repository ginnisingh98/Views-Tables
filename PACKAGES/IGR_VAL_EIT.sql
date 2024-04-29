--------------------------------------------------------
--  DDL for Package IGR_VAL_EIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGR_VAL_EIT" AUTHID CURRENT_USER AS
/* $Header: IGSRT11S.pls 120.0 2005/06/01 16:29:05 appldev noship $ */
  -- Validate the Enquiry Information Type closed indicator.
  FUNCTION admp_val_eit_closed(
  p_enquiry_information_type IN VARCHAR2 ,
  p_message_name    OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN;

END IGR_VAL_EIT;

 

/
