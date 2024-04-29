--------------------------------------------------------
--  DDL for Package IGR_AD_VAL_ES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGR_AD_VAL_ES" AUTHID CURRENT_USER AS
/* $Header: IGSRT16S.pls 120.0 2005/06/01 20:52:23 appldev noship $ */
  --
  -- Validate if the system enquiry status is closed.
  FUNCTION admp_val_ses_closed(
  p_s_enquiry_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY  VARCHAR2)
RETURN BOOLEAN;

END IGR_AD_VAL_ES;

 

/
