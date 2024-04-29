--------------------------------------------------------
--  DDL for Package IEU_WP_ACTION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEU_WP_ACTION_PVT" AUTHID CURRENT_USER AS
/* $Header: IEUACFS.pls 120.0 2005/06/02 15:47:33 appldev noship $ */

-- ===============================================================
-- Start of Comments
-- Package name
--          IEU_WP_ACTION_PVT
-- Purpose
--    To provide easy to use apis for UQW Work Panel.
-- History
--    8-May-2002     dolee   Created.
-- NOTE
--
-- End of Comments
-- ===============================================================
-- ===============================================================
--    Start of Comments
-- ===============================================================
--   API Name
--           create_Action_map
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--  IN
--
--  rec_obj     IN   SYSTEM.IEU_WP_Action_maps_OBJ    Required
--
--  OUT
--  x_return_status    OUT  VARCHAR2
--  x_msg_count        OUT  NUMBER
--  x_msg_data         OUT  VARCHAR2
--
--   End of Comments
-- ===============================================================

PROCEDURE create_action_map
                               ( x_return_status  OUT NOCOPY VARCHAR2,
                                 x_msg_count OUT NOCOPY  NUMBER,
                                 x_msg_data  OUT NOCOPY VARCHAR2,
                                 rec_obj IN SYSTEM.IEU_WP_ACTION_MAPS_OBJ);
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

PROCEDURE Update_MAction ( x_return_status  OUT NOCOPY VARCHAR2,
                           x_msg_count OUT NOCOPY  NUMBER,
                           x_msg_data  OUT NOCOPY  VARCHAR2,
                           r_MACTION_DEF_ID IN NUMBER,
                           r_action_user_label IN VARCHAR2,
                           r_action_description IN VARCHAR2,
                           r_param_set_id IN NUMBER);








-- ===============================================================
--    Start of Comments
-- ===============================================================
--   API Name
--           UpdtateParamProps
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--  OUT
--  x_return_status    OUT  VARCHAR2
--  x_msg_count        OUT  NUMBER
--  x_msg_data         OUT  VARCHAR2
--
--   End of Comments
-- ===============================================================

PROCEDURE UpdateParamProps(    x_return_status  OUT NOCOPY VARCHAR2,
                                 x_msg_count OUT  NOCOPY NUMBER,
                                 x_msg_data  OUT  NOCOPY VARCHAR2,
                                 r_applId IN NUMBER);



-- ===============================================================
--    Start of Comments
-- ===============================================================
--   API Name
--           UPDATE_Action_map
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--  IN
--
--  rec_obj     IN   SYSTEM.IEU_WP_Action_maps_OBJ    Required
--
--  OUT
--  x_return_status    OUT  VARCHAR2
--  x_msg_count        OUT  NUMBER
--  x_msg_data         OUT  VARCHAR2
--
--   End of Comments
-- ===============================================================

PROCEDURE UPDATE_Action_map (    x_return_status  OUT NOCOPY VARCHAR2,
                                 x_msg_count OUT  NOCOPY NUMBER,
                                 x_msg_data  OUT  NOCOPY VARCHAR2,
                                 rec_obj IN SYSTEM.IEU_WP_ACTION_MAPS_OBJ);
PROCEDURE DELETE_Actions (x_return_status  OUT NOCOPY VARCHAR2,
                             x_msg_count OUT  NOCOPY NUMBER,
                             x_msg_data  OUT  NOCOPY VARCHAR2,
                             r_param_set_id IN ieu_wp_act_param_sets_b.action_param_set_id%type
                             );
-- ===============================================================
--    Start of Comments
-- ===============================================================
--   API Name
--           DELETE_Action_map
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--  IN
--
--  x_action_map_id     IN   NUMBER    Required
--
--   End of Comments
-- ===============================================================

PROCEDURE DELETE_Action_map (x_return_status  OUT NOCOPY VARCHAR2,
                             x_msg_count OUT  NOCOPY NUMBER,
                             x_msg_data  OUT  NOCOPY VARCHAR2,
                             r_action_map_id IN NUMBER);

PROCEDURE UPDATE_action_map_sequence (x_return_status  OUT NOCOPY VARCHAR2,
                                      x_msg_count OUT  NOCOPY NUMBER,
                                      x_msg_data  OUT  NOCOPY VARCHAR2,
                                      r_action_param_set_id IN IEU_WP_ACTION_MAPS.action_param_set_id%type,
                                      r_MACTION_DEF_TYPE_FLAG IN IEU_UWQ_MACTION_DEFS_B.MACTION_DEF_TYPE_FLAG %type,
                                      r_application_id IN IEU_WP_ACTION_MAPS.application_id%type,
                                      r_sel_enum_id IN IEU_UWQ_SEL_ENUMERATORS.sel_enum_id%type,
                                      r_action_map_sequence IN IEU_WP_ACTION_MAPS.action_map_sequence%type,
                                       r_not_valid_flag IN IEU_WP_ACTION_MAPS.not_valid_flag%type
);

-- ===============================================================
--    Start of Comments
-- ===============================================================
--   API Name
--           CreateFromAction
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--  IN
--
--  r_wp_action_key VARCHAR2
--
--  OUT
--  x_return_status    OUT  VARCHAR2
--  x_msg_count        OUT  NUMBER
--  x_msg_data         OUT  VARCHAR2
--
--   End of Comments
-- ===============================================================


PROCEDURE CreateFromAction( x_return_status  OUT NOCOPY VARCHAR2,
                            x_msg_count OUT  NOCOPY NUMBER,
                            x_msg_data  OUT  NOCOPY VARCHAR2,
                            r_wp_action_key IN VARCHAR2,
                            r_language  IN VARCHAR2,
                            r_label  IN VARCHAR2,
                            r_desc   IN VARCHAR2,
                            r_param_set_id IN NUMBER,
                            r_enumId IN VARCHAR2);



-- ===============================================================
--    Start of Comments
-- ===============================================================
--   API Name
--           CreateFromAction2
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--  IN
--
--  r_wp_action_key VARCHAR2
--  r_dev_data_flag IN VARCHAR2
--
--  OUT
--  x_return_status    OUT  VARCHAR2
--  x_msg_count        OUT  NUMBER
--  x_msg_data         OUT  VARCHAR2
--
--   End of Comments
-- ===============================================================



PROCEDURE CreateFromAction2( x_return_status  OUT NOCOPY VARCHAR2,
                            x_msg_count OUT  NOCOPY NUMBER,
                            x_msg_data  OUT  NOCOPY VARCHAR2,
                            r_wp_action_key IN VARCHAR2,
                            r_language  IN VARCHAR2,
                            r_label  IN VARCHAR2,
                            r_desc   IN VARCHAR2,
                            r_param_set_id IN NUMBER,
                            r_enumId IN VARCHAR2,
                            r_dev_data_flag IN VARCHAR2);




PROCEDURE CreateFromQFilter( x_return_status  OUT NOCOPY VARCHAR2,
                            x_msg_count OUT NOCOPY  NUMBER,
                            x_msg_data  OUT NOCOPY  VARCHAR2,
                            r_wp_action_key IN VARCHAR2,
                            r_language  IN VARCHAR2,
                            r_label  IN VARCHAR2,
                            r_desc   IN VARCHAR2,
                            r_param_set_id IN NUMBER,
                            r_enumId IN VARCHAR2,
                            r_dev_data_flag IN VARCHAR2);




PROCEDURE ReOrdering( x_return_status  OUT NOCOPY VARCHAR2,
                      x_msg_count OUT NOCOPY  NUMBER,
                      x_msg_data  OUT NOCOPY  VARCHAR2,
                      r_enumId   IN NUMBER,
                      r_applId   IN NUMBER,
                      r_panel    IN VARCHAR2);



END IEU_WP_ACTION_PVT;
 

/
