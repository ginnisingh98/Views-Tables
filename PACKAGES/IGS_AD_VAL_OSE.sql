--------------------------------------------------------
--  DDL for Package IGS_AD_VAL_OSE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_VAL_OSE" AUTHID CURRENT_USER AS
/* $Header: IGSAD64S.pls 115.3 2002/11/28 21:38:26 nsidana ship $ */

  --
  -- Validate the Overseas Scndry Education Qualification closed indicator.
  FUNCTION ADMP_VAL_OSEQ_CLOSED(
  p_os_scndry_edu_qualification IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate the Overseas Scndry Education Qualification Country Code.
  FUNCTION ADMP_VAL_OSE_QCNTRY(
  p_os_scndry_edu_qualification IN VARCHAR2 ,
  p_country_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
END IGS_AD_VAL_OSE;

 

/
