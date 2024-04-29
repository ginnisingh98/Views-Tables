--------------------------------------------------------
--  DDL for Package IGS_CA_GEN_002
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_CA_GEN_002" AUTHID CURRENT_USER AS
/* $Header: IGSCA02S.pls 115.4 2002/11/20 13:12:51 gmuralid ship $ */
FUNCTION calp_clc_daio_cnstrt(
  p_dt_alias IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_alias_val IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN DATE;
PRAGMA RESTRICT_REFERENCES(calp_clc_daio_cnstrt,WNDS,WNPS);
--
FUNCTION calp_clc_dao_cnstrt(
  p_dt_alias IN VARCHAR2 ,
  p_alias_val IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN DATE;
PRAGMA RESTRICT_REFERENCES(calp_clc_dao_cnstrt,WNDS);
--
FUNCTION CALP_CLC_DT_FROM_DA(
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_dt_alias IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN DATE;
PRAGMA RESTRICT_REFERENCES(CALP_CLC_DT_FROM_DA,WNDS);
--
FUNCTION CALP_CLC_DT_FROM_DAI(
  p_ci_sequence_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_dt_alias IN VARCHAR2 ,
  p_dai_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN DATE;
PRAGMA RESTRICT_REFERENCES(calp_clc_dt_from_dai,WNDS,WNPS);
--
FUNCTION CALP_CLC_WK_OF_MONTH(
  p_indate IN DATE )
RETURN INTEGER;
PRAGMA RESTRICT_REFERENCES(calp_clc_wk_of_month,WNDS,WNPS);
--
FUNCTION CALS_CLC_DT_FROM_DAI(
  p_ci_sequence_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_dt_alias IN VARCHAR2 ,
  p_dai_sequence_number IN NUMBER )
RETURN DATE ;
PRAGMA RESTRICT_REFERENCES(CALS_CLC_DT_FROM_DAI,WNDS,WNPS);
--
FUNCTION calp_val_ci_cat(
  p_cal_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(calp_val_ci_cat,WNDS);

--
END IGS_CA_GEN_002;

 

/
