--------------------------------------------------------
--  DDL for Package IGR_VAL_EPI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGR_VAL_EPI" AUTHID CURRENT_USER AS
/* $Header: IGSRT12S.pls 120.0 2005/06/03 15:52:31 appldev noship $ */
  -- To validate the available mailing date of the enquiry package item.
  FUNCTION admp_val_epi_av_dt(
  p_available_ind IN VARCHAR2 DEFAULT 'N',
  p_available_dt IN DATE ,
  p_message_name    OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN;

  -- Validate the Enquiry Package Item closed indicator.
  FUNCTION admp_val_epi_active(
  p_enquiry_package_item IN VARCHAR2 ,
  p_closed_ind  VARCHAR2 DEFAULT 'N',
  p_message_name    OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN;

  -- Validate the Enquiry Package Item closed indicator.
  FUNCTION admp_val_epi_closed(
  p_package_item IN VARCHAR2 ,
  p_message_name    OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN;

END IGR_VAL_EPI;

 

/
