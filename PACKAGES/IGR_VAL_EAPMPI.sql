--------------------------------------------------------
--  DDL for Package IGR_VAL_EAPMPI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGR_VAL_EAPMPI" AUTHID CURRENT_USER AS
/* $Header: IGSRT09S.pls 120.0 2005/06/02 03:54:45 appldev noship $ */
  -- To validate the indicated mailing date of an enquiry item.
  FUNCTION admp_val_eapmpi_dt(
  p_person_id IN NUMBER ,
  p_enquiry_appl_number IN NUMBER ,
  p_mailed_dt IN DATE ,
  p_message_name    OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN;

END IGR_VAL_EAPMPI;

 

/
