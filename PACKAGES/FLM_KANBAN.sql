--------------------------------------------------------
--  DDL for Package FLM_KANBAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FLM_KANBAN" AUTHID CURRENT_USER AS
/* $Header: FLMKBNWS.pls 115.8 2003/05/29 16:55:51 nrajpal ship $  */

-- Constants
G_Source_Type_InterOrg		CONSTANT	NUMBER := 1;
G_Source_Type_Supplier		CONSTANT	NUMBER := 2;
G_Source_Type_IntraOrg		CONSTANT	NUMBER := 3;
G_Source_Type_Production	CONSTANT	NUMBER := 4;

TYPE point_record IS RECORD (
    item_id 	INTEGER,
    locator_id	INTEGER
  );

TYPE ret_sch_t IS TABLE OF point_record index by binary_integer;

TYPE t_sres IS TABLE OF VARCHAR2(32767) INDEX BY BINARY_INTEGER;

TYPE assembly_t IS TABLE OF number index by binary_integer;


PROCEDURE retrieve_schedules (i_locator_option NUMBER,
			      i_template_sub VARCHAR2,
			      i_default_locator_id NUMBER DEFAULT NULL,
			      i_org_id NUMBER,
			      i_line_id NUMBER,
			      i_standard_operation_id NUMBER,
			      i_operation_type NUMBER,
                              i_assembly IN assembly_t,
                              i_item_attributes IN VARCHAR2,
                              i_item_from IN VARCHAR2,
                              i_item_to IN VARCHAR2,
                              i_backflush_sub IN VARCHAR2,
                              i_cat_from IN VARCHAR2,
                              i_cat_to IN VARCHAR2,
                              i_category_set_id IN NUMBER,
                              i_category_structure_id IN NUMBER,
                              o_result OUT NOCOPY ret_sch_t,
                              o_error_num OUT NOCOPY NUMBER,
			      o_error_msg OUT NOCOPY VARCHAR2);

PROCEDURE demand_pegging_tree (i_pull_sequence_id IN NUMBER,
                              o_result OUT NOCOPY t_sres,
                              o_numdays OUT NOCOPY NUMBER,
                              o_error_num OUT NOCOPY NUMBER,
			      o_error_msg OUT NOCOPY VARCHAR2);

PROCEDURE demand_graph (i_pull_sequence_id IN NUMBER,
                              o_result OUT NOCOPY t_sres,
                              o_error_num OUT NOCOPY NUMBER,
			      o_error_msg OUT NOCOPY VARCHAR2);

-- This determines whether a Planning and Production Pull Sequence has a same Point of Supply
FUNCTION Plan_Prod_Same_Pos   (p_plan_pull_seq_id NUMBER,
			       p_prod_pull_seq_id NUMBER) return BOOLEAN;

END flm_kanban;

 

/
