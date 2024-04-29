--------------------------------------------------------
--  DDL for Package IEU_WORK_PANEL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEU_WORK_PANEL_PUB" AUTHID CURRENT_USER AS
/* $Header: IEUDELS.pls 120.0 2005/06/02 15:47:42 appldev noship $ */

--    Start of Comments
-- ===============================================================
--   API Name
--           DeleteAction
--   Type
--           Public
--   Pre-Req
--
--   Parameters
--
--  IN
--
--  x_action_key     IN   VARCHAR2(32)    Required
--
--   End of Comments
-- ===============================================================

PROCEDURE DeleteAction (x_return_status  OUT NOCOPY VARCHAR2,
                              x_msg_count OUT NOCOPY  NUMBER,
                              x_msg_data  OUT NOCOPY  VARCHAR2,
                              r_action_key IN ieu_uwq_maction_defs_b.maction_def_key%type);


--    Start of Comments
-- ===============================================================
--   API Name
--           DeleteCloneAction
--   Type
--           Public
--   Pre-Req
--
--   Parameters
--
--  IN
--
--  r_Lang    IN  ieu_wp_act_param_sets_tl.language%type Required,
--  r_Action_LABEL IN ieu_wp_act_param_sets_tl.ACTION_PARAM_SET_LABEL%type   Required
--   End of Comments
-- ===============================================================

PROCEDURE DeleteCloneAction (x_return_status  OUT NOCOPY VARCHAR2,
                              x_msg_count OUT NOCOPY  NUMBER,
                              x_msg_data  OUT NOCOPY  VARCHAR2,
                              r_Lang    IN  ieu_wp_act_param_sets_tl.language%type,
                              r_Action_LABEL IN ieu_wp_act_param_sets_tl.ACTION_PARAM_SET_LABEL%type,
                              r_node_id IN ieu_uwq_sel_enumerators.sel_enum_id%type);
-- ===============================================================
--    Start of Comments
-- ===============================================================
--   API Name
--           DeleteActionParam
--   Type
--           Public
--   Pre-Req
--
--   Parameters
--
--  IN
--
--  r_PARAM_NAME     IN   ieu_wp_param_defs_b.param_name%type    Required
--  r_ACTION_KEY     IN   ieu_uwq_maction_defs-b.maction_def_key%type --- Requried
--   End of Comments
-- ===============================================================

PROCEDURE DeleteActionParam(x_return_status  OUT NOCOPY VARCHAR2,
                             x_msg_count OUT NOCOPY  NUMBER,
                             x_msg_data  OUT NOCOPY  VARCHAR2,
                            r_PARAM_NAME IN ieu_wp_param_defs_b.param_name%type,
                            r_ACTION_KEY IN ieu_uwq_maction_defs_b.maction_def_key%type);

END IEU_WORK_PANEL_PUB;

 

/
