--------------------------------------------------------
--  DDL for Package IGS_RU_GEN_003
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_RU_GEN_003" AUTHID CURRENT_USER AS
/* $Header: IGSRU03S.pls 120.1 2005/07/11 22:49:21 appldev ship $ */

Function Rulp_Clc_Student_Fee(
  p_rule_number IN NUMBER ,
  p_charge_elements IN NUMBER ,
  p_charge_rate IN NUMBER )
RETURN NUMBER;


Function Rulp_Del_Rlov(
  p_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

Procedure Rulp_Del_Rule(
  p_rule_number IN NUMBER );

Function Rulp_Del_Ur_Rule(
  p_unit_cd IN VARCHAR2 ,
  p_s_rule_call_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

Function Rulp_Get_Ret_Type(
  p_rud_sequence_number  NUMBER )
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (Rulp_Get_Ret_Type, WNDS);

Function Rulp_Get_Rgi(
  p_description_number  NUMBER ,
  p_description_type  VARCHAR2 )
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (Rulp_Get_Rgi, WNDS);

Function Rulp_Get_Rule(
  p_rule_number IN NUMBER )
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (Rulp_Get_Rule, WNDS);

Function Rulp_Ins_Copy_Rule(
  p_rule_call_cd  VARCHAR2 ,
  p_rule_number IN NUMBER )
RETURN NUMBER;

FUNCTION rulp_clc_student_scope(
             p_rule_number     IN   NUMBER,
             p_unit_loc_cd     IN   VARCHAR2,
             p_prg_type_level  IN   VARCHAR2,
             p_org_code        IN   VARCHAR2,
             p_unit_mode       IN   VARCHAR2,
             p_unit_class      IN   VARCHAR2,
             p_message         OUT NOCOPY VARCHAR2 ) RETURN BOOLEAN;


END IGS_RU_GEN_003;

 

/
