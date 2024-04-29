--------------------------------------------------------
--  DDL for Package IGS_RU_GEN_002
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_RU_GEN_002" AUTHID CURRENT_USER AS
/* $Header: IGSRU02S.pls 115.4 2002/11/29 03:39:19 nsidana ship $ */
Function Rulp_Ins_Parser(
  p_group IN NUMBER ,
  p_return_type IN VARCHAR2 ,
  p_rule_description IN VARCHAR2 ,
  p_rule_processed IN OUT NOCOPY VARCHAR2 ,
  p_rule_unprocessed IN OUT NOCOPY VARCHAR2 ,
  p_generate_rule IN BOOLEAN ,
  p_rule_number IN OUT NOCOPY NUMBER ,
  p_LOV_number IN OUT NOCOPY NUMBER )
RETURN BOOLEAN;


END IGS_RU_GEN_002;

 

/
