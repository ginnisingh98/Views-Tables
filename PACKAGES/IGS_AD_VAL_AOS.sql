--------------------------------------------------------
--  DDL for Package IGS_AD_VAL_AOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_VAL_AOS" AUTHID CURRENT_USER AS
/* $Header: IGSAD36S.pls 115.5 2002/11/28 21:30:59 nsidana ship $ */

  -- Validate against the system admission outcome status closed indicator.
  /*****  Bug No :   1956374
          Task   :   Duplicated Procedures and functions
          PROCEDURE  admp_val_saos_clsd  is removed
                      *****/

  -- Validate the admission outcome status system default idicator.
  FUNCTION admp_val_aos_dflt(
  p_adm_outcome_status IN VARCHAR2 ,
  p_s_adm_outcome_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY  VARCHAR2)
RETURN BOOLEAN;

END IGS_AD_VAL_AOS;

 

/
