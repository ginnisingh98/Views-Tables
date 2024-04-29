--------------------------------------------------------
--  DDL for Package FEM_ASSEMBLER_PREDICATE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_ASSEMBLER_PREDICATE_API" AUTHID CURRENT_USER AS
--$Header: FEMASPRDS.pls 120.0 2005/06/06 20:01:38 appldev noship $

procedure GENERATE_ASSEMBLER_PREDICATE(
   x_predicate_string OUT NOCOPY LONG,
   x_return_status OUT NOCOPY VARCHAR2,
   x_msg_count OUT NOCOPY NUMBER,
   x_msg_data OUT NOCOPY VARCHAR2,
   p_condition_obj_id IN NUMBER,
   p_rule_effective_date IN VARCHAR2,
   p_DS_IO_Def_ID IN NUMBER,
   p_Output_Period_ID IN NUMBER,
   p_Request_ID IN NUMBER,
   p_Object_ID IN VARCHAR2,
   p_Ledger_ID IN NUMBER,
   p_by_dimension_column IN VARCHAR2,
   p_by_dimension_id IN NUMBER,
   p_by_dimension_value IN VARCHAR2,
   p_fact_table_name IN VARCHAR2,
   p_table_alias IN VARCHAR2,
   p_Ledger_Flag IN VARCHAR2 := 'N',
   p_api_version IN NUMBER := 1.0,
   p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE,
   p_commit IN VARCHAR2 := FND_API.G_FALSE,
   p_encoded IN VARCHAR2 := FND_API.G_TRUE);

END FEM_ASSEMBLER_PREDICATE_API;

 

/
