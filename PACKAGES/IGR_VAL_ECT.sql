--------------------------------------------------------
--  DDL for Package IGR_VAL_ECT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGR_VAL_ECT" AUTHID CURRENT_USER AS
/* $Header: IGSRT10S.pls 120.0 2005/06/01 22:17:09 appldev noship $ */
  -- Validate the Enquiry Characteristic Type closed indicator.
  FUNCTION admp_val_ect_closed(
  p_enquiry_characteristic_type IN VARCHAR2 ,
  p_message_name    OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN;
END IGR_VAL_ECT;

 

/
