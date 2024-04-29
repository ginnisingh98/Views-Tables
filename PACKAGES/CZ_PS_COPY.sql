--------------------------------------------------------
--  DDL for Package CZ_PS_COPY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_PS_COPY" AUTHID CURRENT_USER AS
/*	$Header: czpscps.pls 120.0.12010000.2 2010/05/18 20:33:13 smanna ship $		*/

TYPE SeqRecord     IS RECORD(id INTEGER,name VARCHAR2(50));
TYPE SequenceArray IS TABLE OF SeqRecord INDEX BY BINARY_INTEGER;
TYPE FlowId        IS TABLE OF INTEGER INDEX BY BINARY_INTEGER;
TYPE FlowId_idx_vc2    IS TABLE OF INTEGER INDEX BY VARCHAR2(15);--BINARY_INTEGER;

INCREMENT          INTEGER:=20;
NEW_PROJECT_ID     INTEGER:=0;
OLD_PROJECT_ID     INTEGER;
GLOBAL_RUN_ID      INTEGER;
NULL_              CONSTANT INTEGER:=-1;
NO_FLAG            CONSTANT VARCHAR2(1):='0';
YES_FLAG           CONSTANT VARCHAR2(1):='1';
REFRENCE_NODE_TYPE CONSTANT INTEGER:=263;

FlowId_PS_NODE         FlowId;
FlowId_INTL_TEXT       FlowId;
FlowId_EXPRESSION      FlowId;
FlowId_EXPRESSION_NODE FlowId_idx_vc2;
FlowId_FILTER_SET      FlowId;
FlowId_RULE            FlowId;
FlowId_SUB_CON_SET     FlowId;
FlowId_POPULATOR       FlowId;
FlowId_GRID_DEF        FlowId;
FlowId_GRID_COL        FlowId;
FlowId_GRID_CELL       FlowId;
FlowId_UI_DEF          FlowId;
FlowId_UI_NODE         FlowId;
FlowId_FUNC_COMP_SPEC  FlowId;
FlowId_RULE_FOLDER     FlowId;
FlowId_MODEL_REF_EXPL  FlowId;

Sequences          SequenceArray;

PROCEDURE Project_Copy
(p_old_id      IN  INTEGER,
 p_new_id      IN  OUT NOCOPY  INTEGER,
 p_Copy_Rules  IN  VARCHAR2 , -- DEFAULT '1',
 p_Copy_UI     IN  VARCHAR2 , -- DEFAULT '1',
 p_name        IN  VARCHAR2 DEFAULT NULL,
 p_folder_id   IN  INTEGER  DEFAULT NULL
);

PROCEDURE Copy_PS_NODE_subtree
(p_project_id     IN     INTEGER,
 p_parent_id      IN     INTEGER,
 p_new_project_id IN     INTEGER,
 p_out_new_root   IN OUT NOCOPY INTEGER,
 p_new_parent_id  IN     INTEGER DEFAULT NULL);

PROCEDURE Copy_RULES_subschema
(p_rule_id             IN   INTEGER,
 p_out_new_rule_id     OUT NOCOPY  INTEGER,
 p_FUNC_COMP_Flag      IN   VARCHAR2 , -- DEFAULT '0',
 p_rule_folder_id      IN   INTEGER  DEFAULT NULL,
 p_Rules_Seq_Flag      IN   VARCHAR2   -- DEFAULT '0'
);

PROCEDURE COPY_FUNC_COMPANION
(p_func_comp_id         IN      INTEGER,
 p_project_id           IN      INTEGER,
 p_new_rule_folder_id   IN      INTEGER  DEFAULT NULL,
 p_out_new_func_comp_id IN OUT NOCOPY  INTEGER );

PROCEDURE copy_RULE_SEQ
(p_rule_seq_id     IN INTEGER,
 p_new_rule_seq_id IN OUT NOCOPY INTEGER);

PROCEDURE Test
(p_id        IN INTEGER,
 p_Rules     IN VARCHAR2 , -- DEFAULT '1',
 p_UI        IN VARCHAR2 , -- DEFAULT '1',
 p_folder_id IN INTEGER    -- DEFAULT -1
);

END cz_ps_copy;

/
