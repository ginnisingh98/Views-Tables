--------------------------------------------------------
--  DDL for Package IEU_WORKPANEL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEU_WORKPANEL_PVT" AUTHID CURRENT_USER AS
/* $Header: IEUVWPS.pls 115.24 2003/08/24 21:44:55 appldev ship $ */

-- ===============================================================
-- Start of Comments
-- Package name
--          IEU_WorkPanel_PVT
-- Purpose
--    To provide easy to use apis for UQW Work Panel.
-- History
--    08-May-2002     gpagadal    Created.
-- NOTE
--
-- End of Comments
-- ===============================================================

-- ===============================================================
--    Start of Comments
-- ===============================================================
--   API Name
--           Validate_Action
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--  IN
--
--  rec_obj     IN   SYSTEM.IEU_WP_MACT_OBJ    Required
--  is_create   IN   VARCHAR2   Required
--
--
--  OUT
--  x_return_status    OUT  VARCHAR2
--  x_msg_count        OUT  NUMBER
--  x_msg_data         OUT  VARCHAR2
--
--   End of Comments
-- ===============================================================


PROCEDURE Validate_Action (    x_return_status  OUT NOCOPY VARCHAR2,
                        x_msg_count OUT  NOCOPY NUMBER,
                        x_msg_data  OUT  NOCOPY VARCHAR2,
                        rec_obj IN SYSTEM.IEU_WP_MACT_OBJ, is_create IN VARCHAR2,
                        p_maction_def_type_flag IN VARCHAR2,
                        p_param_set_id IN NUMBER);


-- ===============================================================
--    Start of Comments
-- ===============================================================
--   API Name
--           Create_MAction
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--  IN
--
--  rec_obj     IN   SYSTEM.IEU_WP_MACT_OBJ    Required
--
--  OUT
--  x_return_status    OUT  VARCHAR2
--  x_msg_count        OUT  NUMBER
--  x_msg_data         OUT  VARCHAR2
--
--   End of Comments
-- ===============================================================


PROCEDURE Create_MAction (   x_return_status  OUT NOCOPY VARCHAR2,
                             x_msg_count OUT NOCOPY NUMBER,
                             x_msg_data  OUT  NOCOPY VARCHAR2,
                             rec_obj IN SYSTEM.IEU_WP_MACT_OBJ,
                             p_maction_def_type_flag IN VARCHAR2);

PROCEDURE Create_MAction2 (   x_return_status  OUT NOCOPY VARCHAR2,
                             x_msg_count OUT  NOCOPY NUMBER,
                             x_msg_data  OUT NOCOPY  VARCHAR2,
                             rec_obj IN SYSTEM.IEU_WP_MACT_OBJ,
                             p_maction_def_type_flag IN VARCHAR2,
                             p_datasource IN VARCHAR2);



-- ===============================================================
--    Start of Comments
-- ===============================================================
--   API Name
--           Update_MAction
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--  IN
--
--  rec_obj     IN   SYSTEM.IEU_WP_MACT_OBJ    Required
--
--  OUT
--  x_return_status    OUT  VARCHAR2
--  x_msg_count        OUT  NUMBER
--  x_msg_data         OUT  VARCHAR2
--
--   End of Comments
-- ===============================================================

PROCEDURE Update_MAction (   x_return_status  OUT NOCOPY VARCHAR2,
                             x_msg_count OUT NOCOPY NUMBER,
                             x_msg_data  OUT NOCOPY VARCHAR2,
                             rec_obj IN SYSTEM.IEU_WP_MACT_OBJ,
                             p_param_set_id IN NUMBER,
                             p_maction_def_type_flag IN VARCHAR2);



-- ===============================================================
--    Start of Comments
-- ===============================================================
--   API Name
--           Delete_MAction
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--  IN
--
--  x_media_type_id     IN   NUMBER    Required
--
--   End of Comments
-- ===============================================================

PROCEDURE Delete_MAction (x_action_def_id IN NUMBER);


-- ===============================================================
--    Start of Comments
-- ===============================================================
--   API Name
--           Validate_Parameter
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--  IN
--
--  rec_obj     IN   SYSTEM.IEU_WP_ACT_PARAM_OBJ    Required
--
--  OUT
--  x_return_status    OUT  VARCHAR2
--  x_msg_count        OUT  NUMBER
--  x_msg_data         OUT  VARCHAR2
--
--   End of Comments
-- ===============================================================

PROCEDURE Validate_Parameter( x_return_status  OUT NOCOPY VARCHAR2,
                            x_msg_count OUT NOCOPY NUMBER,
                            x_msg_data  OUT  NOCOPY VARCHAR2,
                            rec_obj IN SYSTEM.IEU_WP_ACT_PARAM_OBJ,
                            is_create IN VARCHAR2);


-- ===============================================================
--    Start of Comments
-- ===============================================================
--   API Name
--           Create_Param_Defs
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--  IN
--
--  rec_obj     IN   SYSTEM.IEU_WP_ACT_PARAM_OBJ    Required
--
--  OUT
--  x_return_status    OUT  VARCHAR2
--  x_msg_count        OUT  NUMBER
--  x_msg_data         OUT  VARCHAR2
--
--   End of Comments
-- ===============================================================


PROCEDURE Create_Param_Defs (   x_return_status  OUT NOCOPY VARCHAR2,
                             x_msg_count OUT  NOCOPY NUMBER,
                             x_msg_data  OUT NOCOPY VARCHAR2,
                             rec_obj IN SYSTEM.IEU_WP_ACT_PARAM_OBJ,
                             p_param_id OUT NOCOPY NUMBER);




-- ===============================================================
--    Start of Comments
-- ===============================================================
--   API Name
--           Update_Param_Defs
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--  IN
--
--  rec_obj     IN   SYSTEM.IEU_WP_ACT_PARAM_OBJ    Required
--
--  OUT
--  x_return_status    OUT  VARCHAR2
--  x_msg_count        OUT  NUMBER
--  x_msg_data         OUT  VARCHAR2
--
--   End of Comments
-- ===============================================================


PROCEDURE Update_Param_Defs (   x_return_status  OUT NOCOPY VARCHAR2,
                             x_msg_count OUT NOCOPY NUMBER,
                             x_msg_data  OUT  NOCOPY VARCHAR2,
                             rec_obj IN SYSTEM.IEU_WP_ACT_PARAM_OBJ);


-- ===============================================================
--    Start of Comments
-- ===============================================================
--   API Name
--           Create_Param_Props
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--  IN
--   p_param_id IN NUMBER
--   p_property_id IN NUMBER
--   p_property_value IN VARCHAR2
--   p_action_param_set_id IN NUMBER
--
--  rec_obj     IN   SYSTEM.IEU_WP_ACT_PARAM_OBJ    Required
--
--  OUT
--  x_return_status    OUT  VARCHAR2
--  x_msg_count        OUT  NUMBER
--  x_msg_data         OUT  VARCHAR2
--
--   End of Comments
-- ===============================================================


PROCEDURE Create_Param_Props (   x_return_status  OUT NOCOPY VARCHAR2,
                             x_msg_count OUT  NOCOPY NUMBER,
                             x_msg_data  OUT NOCOPY VARCHAR2,
                             p_param_id IN NUMBER,
                             p_property_id IN NUMBER,
                             p_property_value IN VARCHAR2,
                             p_action_param_set_id IN NUMBER);



-- ===============================================================
--    Start of Comments
-- ===============================================================
--   API Name
--           Update_Param_Props
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--  IN
--   p_param_id IN NUMBER
--   p_property_id IN NUMBER
--   p_property_value IN VARCHAR2
--   p_action_param_set_id IN NUMBER
--
--  rec_obj     IN   SYSTEM.IEU_WP_ACT_PARAM_OBJ    Required
--
--  OUT
--  x_return_status    OUT  VARCHAR2
--  x_msg_count        OUT  NUMBER
--  x_msg_data         OUT  VARCHAR2
--
--   End of Comments
-- ===============================================================


PROCEDURE Update_Param_Props (   x_return_status  OUT NOCOPY VARCHAR2,
                             x_msg_count OUT NOCOPY  NUMBER,
                             x_msg_data  OUT NOCOPY VARCHAR2,
                             p_param_id IN NUMBER,
                             p_property_id IN NUMBER,
                             p_property_value IN VARCHAR2,
                             p_action_param_set_id IN NUMBER);



PROCEDURE Update_Column_Props (   x_return_status  OUT NOCOPY VARCHAR2,
                             x_msg_count OUT NOCOPY NUMBER,
                             x_msg_data  OUT NOCOPY VARCHAR2,
                             p_param_id IN NUMBER,
                             p_property_id IN NUMBER,
                             p_property_value IN VARCHAR2,
                             p_action_param_set_id IN NUMBER);






-- ===============================================================
--    Start of Comments
-- ===============================================================
--   API Name
--           Delete_Parameter
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--  IN
--
--  x_media_type_id     IN   NUMBER    Required
--
--   End of Comments
-- ===============================================================

PROCEDURE Delete_Parameter (x_param_id IN NUMBER, x_param_set_id IN NUMBER);


PROCEDURE Create_From_Action(    x_return_status  OUT NOCOPY VARCHAR2,
                                 x_msg_count OUT NOCOPY  NUMBER,
                                 x_msg_data  OUT NOCOPY VARCHAR2,
                                -- r_wp_action_key IN VARCHAR2,
                                -- r_language  IN VARCHAR2,
                                -- r_label  IN VARCHAR2,
                                -- r_desc   IN VARCHAR2,
                                rec_obj IN SYSTEM.IEU_WP_MACT_OBJ,
                                  p_param_set_id IN IEU_WP_ACT_PARAM_SETS_B.ACTION_PARAM_SET_ID%type,
                                   p_maction_def_type_flag IN VARCHAR2);


PROCEDURE Map_Action(    x_return_status  OUT NOCOPY VARCHAR2,
                         x_msg_count OUT NOCOPY NUMBER,
                         x_msg_data  OUT NOCOPY VARCHAR2,
                         p_enum_id  IN NUMBER,
                         p_application IN NUMBER,
                         p_param_set_id IN IEU_WP_ACT_PARAM_SETS_B.ACTION_PARAM_SET_ID%type,
                         p_maction_def_type_flag IN VARCHAR2
                    );


PROCEDURE Validate_Action_Label( x_return_status  OUT NOCOPY VARCHAR2,
                            x_msg_count OUT NOCOPY NUMBER,
                            x_msg_data  OUT  NOCOPY VARCHAR2,
                            p_label IN VARCHAR2,
                            p_maction_def_type_flag IN VARCHAR2,
                            p_enum_id IN NUMBER);

PROCEDURE Delete_Action_From_Node (
                            x_return_status  OUT NOCOPY VARCHAR2,
                            x_msg_count OUT NOCOPY NUMBER,
                            x_msg_data  OUT NOCOPY VARCHAR2,
                            x_param_set_id IN NUMBER,
                            x_node_id IN NUMBER
                            );



PROCEDURE Update_Data_Type ( x_return_status  OUT NOCOPY VARCHAR2,
                             x_msg_count OUT NOCOPY NUMBER,
                             x_msg_data  OUT NOCOPY VARCHAR2,
                             p_wp_action_def_id IN NUMBER,
                             p_param_id IN NUMBER);

PROCEDURE Update_Multi_Select_Flag ( x_return_status  OUT NOCOPY VARCHAR2,
                             x_msg_count OUT  NOCOPY NUMBER,
                             x_msg_data  OUT NOCOPY VARCHAR2,
                             p_wp_action_def_id IN NUMBER);



PROCEDURE Param_ReOrdering(x_return_status  OUT NOCOPY VARCHAR2,
                           x_msg_count OUT NOCOPY  NUMBER,
                           x_msg_data  OUT NOCOPY VARCHAR2,
                           p_wp_action_def_id IN NUMBER,
                           p_action_param_set_id IN NUMBER);



PROCEDURE Create_From_Filter( x_return_status  OUT NOCOPY VARCHAR2,
                              x_msg_count OUT NOCOPY NUMBER,
                              x_msg_data  OUT NOCOPY VARCHAR2,
                              rec_obj IN SYSTEM.IEU_WP_MACT_OBJ,
                              p_param_set_id IN IEU_WP_ACT_PARAM_SETS_B.ACTION_PARAM_SET_ID%type,
                              p_maction_def_type_flag IN VARCHAR2);




END IEU_WorkPanel_PVT;


 

/
