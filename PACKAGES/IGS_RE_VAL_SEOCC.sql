--------------------------------------------------------
--  DDL for Package IGS_RE_VAL_SEOCC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_RE_VAL_SEOCC" AUTHID CURRENT_USER AS
/* $Header: IGSRE14S.pls 115.3 2002/11/29 03:30:08 nsidana ship $ */
 --
  -- Validate whether IGS_RE_GV_SEO_CLS_CD exists for another record
  FUNCTION resp_val_scc_gscc(
  p_govt_seo_class_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  -- Validate if Government Socio-Economic Classification Code is closed.
  FUNCTION resp_val_gscc_closed(
  p_govt_seo_class_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

END IGS_RE_VAL_SEOCC;

 

/
