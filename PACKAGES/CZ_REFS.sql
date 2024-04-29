--------------------------------------------------------
--  DDL for Package CZ_REFS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_REFS" AUTHID CURRENT_USER AS
/*	$Header: czrefs.pls 120.0.12010000.3 2010/04/28 20:26:01 lamrute ship $ */

OPTIONAL_EXPL_TYPE  CONSTANT INTEGER:=1;
MANDATORY_EXPL_TYPE CONSTANT INTEGER:=2;
CONNECTOR_EXPL_TYPE CONSTANT INTEGER:=3;
MINMAX_EXPL_TYPE    CONSTANT INTEGER:=4;

NOT_MIN_MAX_RULE  CONSTANT INTEGER:=0;
MIN_RULE          CONSTANT INTEGER:=1;
MAX_RULE          CONSTANT INTEGER:=2;

NULL_VALUE     CONSTANT INTEGER:=-1;
NO_FLAG        CONSTANT VARCHAR2(1):='0';
YES_FLAG       CONSTANT VARCHAR2(1):='1';

ERROR_CODE          PLS_INTEGER:=0;

PROCEDURE IsNonVirtual
(p_ps_node_id      IN  INTEGER,
 p_model_id        IN  INTEGER,
 p_out_flag        OUT NOCOPY INTEGER);

PROCEDURE check_Node
(p_ps_node_id       IN  INTEGER,
 p_model_id         IN  INTEGER,
 p_maximum          IN  INTEGER,
 p_minimum          IN  INTEGER,
 p_reference_id     IN  INTEGER,
 p_out_err          OUT NOCOPY INTEGER,
 p_out_virtual_flag OUT NOCOPY INTEGER,
 p_consequent_flag  IN  VARCHAR2 , -- DEFAULT '0',
 p_expr_node_id     IN  INTEGER  DEFAULT NULL,
 p_ps_type          IN  INTEGER  DEFAULT NULL,
 p_expr_subtype     IN  INTEGER  DEFAULT NULL,
 p_skip_upd_nod_dep IN  VARCHAR2 DEFAULT NO_FLAG);

PROCEDURE delete_Node
(p_ps_node_id    IN  INTEGER,
 p_ps_node_type  IN  INTEGER,
 p_out_err       OUT NOCOPY INTEGER,
 p_del_logically IN  VARCHAR2 -- DEFAULT '1'
);

PROCEDURE move_Node
(p_from_ps_node_id IN  INTEGER,
 p_to_ps_node_id   IN  INTEGER,
 p_project_id      IN  INTEGER,
 p_out_err         OUT NOCOPY INTEGER);

PROCEDURE CHECK_REF_REQUEST
(p_refroot_model_id    IN  INTEGER,
 p_ref_parent_node_id  IN  INTEGER,
 p_ref_target_model_id IN  INTEGER,
 p_out_status_code     OUT NOCOPY INTEGER);

PROCEDURE get_Node_Up
(p_ps_node_id     IN     INTEGER,
 p_project_id     IN     INTEGER,
 p_out_ps_node_id IN OUT NOCOPY INTEGER,
 p_out_expl_id    IN OUT NOCOPY INTEGER,
 p_out_level      IN OUT NOCOPY INTEGER);

PROCEDURE get_Node_Down
(p_ps_node_id     IN     INTEGER,
 p_project_id     IN     INTEGER,
 p_out_ps_node_id IN OUT NOCOPY INTEGER,
 p_out_expl_id    IN OUT NOCOPY INTEGER,
 p_out_level      IN OUT NOCOPY INTEGER);

PROCEDURE add_Reference
(p_ps_node_id           IN  INTEGER,
 p_to_model_id          IN  INTEGER,
 p_containing_model_id  IN  INTEGER,
 p_virtual_flag         IN  VARCHAR2,
 p_out_err              OUT NOCOPY INTEGER,
 p_ps_type              IN  INTEGER DEFAULT NULL,
 p_expl_node_type       IN  INTEGER -- DEFAULT MANDATORY_EXPL_TYPE
);

PROCEDURE change_structure(p_model_id IN INTEGER);

PROCEDURE SolutionBasedModelcheck
(p_model_id     IN  INTEGER,
 p_instanciable OUT NOCOPY INTEGER);

PROCEDURE set_Trackable_Children_Flag(p_model_id IN NUMBER);

PROCEDURE update_child_nodes(p_model_id IN NUMBER);

PROCEDURE update_node_depth(p_model_id IN INTEGER DEFAULT NULL);

-- Bugfix 9446997
PROCEDURE reset_model_array ;

PROCEDURE populate_COMPONENT_ID(p_model_id IN NUMBER);

PROCEDURE validate_Inst_Flag
(
 p_ps_node_id        IN  NUMBER,
 p_instantiable_flag IN  NUMBER,
 x_validation_flag   OUT NOCOPY VARCHAR2,
 x_run_id            OUT NOCOPY NUMBER
);

-- PROCEDURE check_Inst_Rule
--                               Called when a rule is about to be enabled. It checks the instantiable_flag of the node
--                               on the RHS and the selected system property MinInstances/MaxInstances
--
--      IN
--            p_rule_id
--      OUT
--            x_inst_flag        : current instantiable_flag of the node on the RHS of the rule, values
--                                 OPTIONAL_EXPL_TYPE, MANDATORY_EXPL_TYPE, CONNECTOR_EXPL_TYPE, MINMAX_EXPL_TYPE
--            x_sys_prop         : system property contributed/consumed:  MIN_RULE, MAX_RULE, NOT_MINMAX_RULE
--            x_validation_flag  : cannot be enabled  = NO_FLAG, can be enabled = YES_FLAG

PROCEDURE check_Inst_Rule
(
 p_rule_id          IN  NUMBER,
 x_inst_flag        OUT NOCOPY NUMBER,
 x_sys_prop         OUT NOCOPY NUMBER,
 x_validation_flag  OUT NOCOPY VARCHAR2
);

--
-- vsingava bug7831246 02nd Mar '09
-- procedure which populates the set of explosions p_ps_node_id of p_model_id
-- to all model referencing it, up the entire model heirarchy. Usually called when a node
-- in structure is copied

PROCEDURE populate_parent_expl_tree
(
 p_ps_node_id          IN  NUMBER, --ps_node_id of the new (root) node that
                                   --has been created during copy operation with in struture
 p_model_id        IN NUMBER       -- model_id of the model within which structure copy is being done
);
END;

/
