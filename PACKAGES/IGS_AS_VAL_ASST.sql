--------------------------------------------------------
--  DDL for Package IGS_AS_VAL_ASST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_VAL_ASST" AUTHID CURRENT_USER AS
/* $Header: IGSAS14S.pls 115.3 2002/11/28 22:43:00 nsidana ship $ */
  --
  -- Validate assessor type dflt ind set at least and only once.
  FUNCTION assp_val_asst_dflt(
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

END IGS_AS_VAL_ASST;

 

/
