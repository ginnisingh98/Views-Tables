--------------------------------------------------------
--  DDL for Package IGS_RU_GEN_006
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_RU_GEN_006" AUTHID CURRENT_USER AS
/* $Header: IGSRU12S.pls 115.1 2002/11/29 03:41:24 nsidana noship $ */

FUNCTION Rulp_Val_Desc_Rgi(
  p_description_number IN NUMBER ,
  p_description_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (Rulp_Val_Desc_Rgi, WNDS)   ;

PROCEDURE Rulp_Ins_Make_Rule(
  p_description_number IN NUMBER DEFAULT NULL,
  p_return_type  VARCHAR2 DEFAULT NULL,
  p_rule_description  VARCHAR2 DEFAULT NULL,
  p_turing_function  VARCHAR2 DEFAULT NULL,
  p_rule_text  VARCHAR2 DEFAULT NULL,
  p_message_rule_text  VARCHAR2 DEFAULT NULL,
  p_description_text  VARCHAR2 ,
  p_group IN NUMBER DEFAULT 1,
  p_select_group IN NUMBER DEFAULT 1);

FUNCTION Rulp_Get_Rule(
  p_rule_number IN NUMBER )
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (Rulp_Get_Rule, WNDS);

PROCEDURE Set_Token(token varchar2);

FUNCTION Jbsp_Get_Dt_Picture(
  p_char_dt IN VARCHAR2 ,
  p_dt_picture OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

END IGS_RU_GEN_006;

 

/
