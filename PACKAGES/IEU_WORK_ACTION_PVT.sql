--------------------------------------------------------
--  DDL for Package IEU_WORK_ACTION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEU_WORK_ACTION_PVT" AUTHID CURRENT_USER AS
/* $Header: IEUWACS.pls 115.8 2004/03/26 18:29:43 dolee noship $ */

-- ===============================================================
PROCEDURE Node_Mapping(    x_return_status  OUT NOCOPY VARCHAR2,
                         x_msg_count OUT NOCOPY  NUMBER,
                         x_msg_data  OUT NOCOPY  VARCHAR2,
                         p_enum_id IN NUMBER,
                         p_mapping_application IN  NUMBER,
                         p_param_set_id IN IEU_WP_ACT_PARAM_SETS_B.ACTION_PARAM_SET_ID%type,
			          p_maction_def_type_flag IN VARCHAR2,
                         p_act_application IN  NUMBER
                    ) ;
		    --===================================================================
-- NAME
--   CREATE_action_map
--
-- PURPOSE
--    Private api to create action map
--
-- NOTES
--    1. UWQ Admin will use this procedure to create action map
--
--
-- HISTORY
--   8-may-2002     dolee   Created

--===================================================================


PROCEDURE CREATE_action_map (x_return_status  OUT NOCOPY VARCHAR2,
                             x_msg_count OUT  NOCOPY NUMBER,
                             x_msg_data  OUT  NOCOPY VARCHAR2,
                             rec_obj IN SYSTEM.IEU_WP_ACTION_MAPS_OBJ
);
PROCEDURE Create_Work_Action (x_return_status  OUT NOCOPY VARCHAR2,
                             x_msg_count OUT  NOCOPY NUMBER,
                             x_msg_data  OUT  NOCOPY VARCHAR2,
                             rec_obj IN SYSTEM.IEU_WP_MACT_OBJ,
                             p_maction_def_type_flag IN VARCHAR2);
 PROCEDURE CreateFromAction(    x_return_status  OUT NOCOPY VARCHAR2,
                                 x_msg_count OUT  NOCOPY NUMBER,
                                 x_msg_data  OUT  NOCOPY VARCHAR2,
                                 --r_wp_action_key IN VARCHAR2,
				 r_maction_def_id IN NUMBER,
                                 r_language  IN VARCHAR2,
                                 r_label  IN VARCHAR2,
                                 r_desc   IN VARCHAR2,
                                  r_param_set_id IN NUMBER);
PROCEDURE Validate_Action_Label( x_return_status  OUT NOCOPY VARCHAR2,
                        x_msg_count OUT  NOCOPY NUMBER,
                        x_msg_data  OUT  NOCOPY VARCHAR2,
                        p_label IN VARCHAR2,
                        p_param_set_id IN NUMBER
                       );
PROCEDURE Delete_Action_From_Node (
  x_return_status  OUT NOCOPY VARCHAR2,
  x_msg_count OUT  NOCOPY NUMBER,
  x_msg_data  OUT NOCOPY  VARCHAR2,
  x_param_set_id IN NUMBER,
  x_node_id IN NUMBER,
  x_maction_id IN NUMBER,
  x_maction_def_flag IN VARCHAR2
    );
END IEU_Work_ACTION_PVT;


 

/
