--------------------------------------------------------
--  DDL for Package IEU_DIAGNOSTICS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEU_DIAGNOSTICS_PVT" AUTHID CURRENT_USER AS
/* $Header: IEUVDFS.pls 115.11 2004/04/23 15:11:12 dolee ship $ */

-- ===============================================================
-- Start of Comments
-- Package name
--          IEU_Diagnostics_PVT
-- Purpose
--    To provide easy to use apis for UQW Diagnostic Framework.
-- History
--    14-Mar-2002     gpagadal    Created.
-- NOTE
--
-- End of Comments
-- ===============================================================

-- ===============================================================
--    Start of Comments
-- ===============================================================
--   API Name
--           Is_ResourceId_Exist
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--  IN
--
--  p_user_name    IN   VARCHAR2    Required
--
--
--  OUT
--  x_return_status    OUT  VARCHAR2
--  x_msg_count        OUT  NUMBER
--  x_msg_data         OUT  VARCHAR2
--
--   End of Comments
-- ===============================================================

PROCEDURE Is_ResourceId_Exist (x_return_status  OUT NOCOPY VARCHAR2,
                                   x_msg_count OUT NOCOPY NUMBER,
                                   x_msg_data  OUT NOCOPY VARCHAR2,
                                   p_user_name IN VARCHAR2
                                   );




-- ===============================================================
--    Start of Comments
-- ===============================================================
--   API Name
--           Check_User_Resp
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--  IN
--
--  p_user_name    IN   VARCHAR2    Required
--  p_responsibility   IN VARCHAR2  Required
--
--
--  OUT
--  x_return_status    OUT  VARCHAR2
--  x_msg_count        OUT  NUMBER
--  x_msg_data         OUT  VARCHAR2
--  x_user_id          OUT  NUMBER
--  x_resp_id          OUT  NUMBER
--  x_appl_id     OUT  NUMBER
--
--   End of Comments
-- ===============================================================


PROCEDURE Check_User_Resp (x_return_status  OUT NOCOPY VARCHAR2,
                           x_msg_count OUT  NOCOPY NUMBER,
                           x_msg_data  OUT NOCOPY VARCHAR2,
                           p_user_name IN VARCHAR2,
                           p_responsibility   IN VARCHAR2,
                           x_user_id          OUT NOCOPY NUMBER,
                           x_resp_id          OUT NOCOPY NUMBER,
                           x_appl_id     OUT NOCOPY NUMBER
                          );

PROCEDURE Check_Object_Resp (x_return_status  OUT NOCOPY VARCHAR2,
                           x_msg_count OUT  NOCOPY NUMBER,
                           x_msg_data  OUT NOCOPY VARCHAR2,
                           p_object_code IN VARCHAR2,
                           p_responsibility   IN VARCHAR2,
                           x_resp_id          OUT NOCOPY NUMBER
                          );

-- ===============================================================
--    Start of Comments
-- ===============================================================
--   API Name
--           Determine_Media_Enabled
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--  IN
--
--  p_user_name    IN   VARCHAR2    Required
--  p_responsibility   IN VARCHAR2  Required
--
--
--  OUT
--  x_return_status    OUT  VARCHAR2
--  x_media_types      OUT  IEU_DIAG_STRING_NST
--  x_msg_count        OUT  NUMBER
--  x_msg_data         OUT  VARCHAR2
--
--   End of Comments
-- ===============================================================


PROCEDURE Determine_Media_Enabled (x_return_status  OUT NOCOPY VARCHAR2,
                                   x_msg_count OUT NOCOPY NUMBER,
                                   x_msg_data  OUT NOCOPY VARCHAR2,
                                   p_user_name IN VARCHAR2,
                                   p_responsibility   IN VARCHAR2,
                                   x_media_types OUT NOCOPY IEU_DIAG_STRING_NST);



-- ===============================================================
--    Start of Comments
-- ===============================================================
--   API Name
--           Determine_Valid_Server
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--  IN
--
--  p_user_name    IN   VARCHAR2    Required
--  p_responsibility   IN VARCHAR2  Required
--
--
--  OUT
--  x_return_status    OUT  VARCHAR2
--  x_server_group     OUT  VARCHAR2
--  x_msg_count        OUT  NUMBER
--  x_msg_data         OUT  VARCHAR2
--
--   End of Comments
-- ===============================================================


 PROCEDURE Determine_Valid_Server ( x_return_status  OUT NOCOPY VARCHAR2,
                                    x_msg_count OUT NOCOPY NUMBER,
                                    x_msg_data  OUT NOCOPY VARCHAR2,
                                    p_user_name IN VARCHAR2,
                                    p_responsibility   IN VARCHAR2,
                                    x_server_group OUT NOCOPY VARCHAR2,
                                    x_medias OUT NOCOPY IEU_DIAG_STRING_NST);


-- ===============================================================
--    Start of Comments
-- ===============================================================
--   API Name
--           Get_Valid_Nodes
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--  IN
--
--  p_user_name    IN   VARCHAR2    Required
--  p_responsibility   IN VARCHAR2  Required
--
--
--  OUT
--  x_return_status    OUT  VARCHAR2
--  x_valid_nodes      OUT  IEU_DIAG_VNODE_NST
--  x_msg_count        OUT  NUMBER
--  x_msg_data         OUT  VARCHAR2
--
--   End of Comments
-- ===============================================================


 PROCEDURE Get_Valid_Nodes (    x_return_status  OUT NOCOPY VARCHAR2,
                                x_msg_count OUT NOCOPY NUMBER,
                                x_msg_data  OUT NOCOPY VARCHAR2,
                                p_user_name IN VARCHAR2,
                                p_responsibility   IN VARCHAR2,
                                x_valid_nodes OUT NOCOPY IEU_DIAG_VNODE_NST);

-- ===============================================================
--    Start of Comments
-- ===============================================================
--   API Name
--           Check_Profile_Options
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--  IN
--
--  p_user_name    IN   VARCHAR2    Required
--  p_responsibility   IN VARCHAR2  Required
--
--
--  OUT
--  x_return_status    OUT  VARCHAR2
--  x_msg_count        OUT  NUMBER
--  x_msg_data         OUT  VARCHAR2
--
--   End of Comments
-- ===============================================================


 PROCEDURE Check_Profile_Options(   x_return_status  OUT NOCOPY VARCHAR2,
                                    x_msg_count OUT NOCOPY NUMBER,
                                    x_msg_data  OUT NOCOPY VARCHAR2,
                                    p_user_name IN VARCHAR2,
                                    p_responsibility   IN VARCHAR2,
                                    x_invalid_profile_options OUT NOCOPY IEU_DIAG_VNODE_NST);


-- ===============================================================
--    Start of Comments
-- ===============================================================
--   API Name
--           Check_Node_Enumeration
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--  IN
--
--  p_user_name    IN   VARCHAR2    Required
--  p_responsibility   IN VARCHAR2  Required
--
--
--  OUT
--  x_return_status    OUT  VARCHAR2
--  x_server_group     OUT  VARCHAR2
--  x_msg_count        OUT  NUMBER
--  x_msg_data         OUT  VARCHAR2
--  x_dupli_proc       OUT  IEU_DIAG_ENUM_NST
--  x_invalid_pkg      OUT  IEU_DIAG_ENUM_NST
--  x_invalid_proc     OUT  IEU_DIAG_ENUM_NST
--  x_enum_time        OUT  IEU_DIAG_ENUM_TIME_NST
--   End of Comments
-- ===============================================================

 PROCEDURE Check_Node_Enumeration ( x_return_status  OUT NOCOPY VARCHAR2,
                                    x_msg_count OUT  NOCOPY NUMBER,
                                    x_msg_data  OUT  NOCOPY VARCHAR2,
                                    p_user_name IN VARCHAR2,
                                    p_responsibility   IN VARCHAR2,
                                    x_dupli_proc OUT NOCOPY IEU_DIAG_ENUM_NST,
                                    x_invalid_pkg OUT NOCOPY IEU_DIAG_ENUM_NST,
                                    x_invalid_proc OUT NOCOPY IEU_DIAG_ENUM_ERR_NST,
                                    x_enum_time  OUT NOCOPY IEU_DIAG_ENUM_TIME_NST,
                                    x_user_ver_time OUT NOCOPY NUMBER,
                                    x_etime_grand_total OUT NOCOPY NUMBER);



-- ===============================================================
--    Start of Comments
-- ===============================================================
--   API Name
--           Get_Valid_RT_Nodes
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--  IN
--
--  p_user_name    IN   VARCHAR2    Required
--  p_responsibility   IN VARCHAR2  Required
--
--
--  OUT
--  x_return_status    OUT  VARCHAR2
--  x_valid_nodes      OUT  IEU_DIAG_VNODE_NST
--  x_msg_count        OUT  NUMBER
--  x_msg_data         OUT  VARCHAR2
--
--   End of Comments
-- ===============================================================


 PROCEDURE Get_Valid_RT_Nodes (     x_return_status  OUT NOCOPY VARCHAR2,
                                    x_msg_count OUT  NOCOPY NUMBER,
                                    x_msg_data  OUT  NOCOPY VARCHAR2,
                                    p_user_name IN VARCHAR2,
                                    p_responsibility   IN VARCHAR2,
                                    x_valid_nodes OUT NOCOPY IEU_DIAG_NODE_NST);

-- ===============================================================
--    Start of Comments
-- ===============================================================
--   API Name
--           Check_Refresh_Node_Counts
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--  IN
--
--  p_user_name    IN   VARCHAR2    Required
--  p_responsibility   IN VARCHAR2  Required
--
--
--  OUT
--  x_invalid_pkg      OUT  IEU_DIAG_REFRESH_NST
--  x_invalid_rproc    OUT  IEU_DIAG_REFRESH_ERR_NST
--  x_msg_count        OUT  NUMBER
--  x_msg_data         OUT  VARCHAR2
--  x_refresh_time     OUT  IEU_DIAG_REFRENUM_TIME_NST
--   End of Comments
-- ===============================================================


 PROCEDURE Check_Refresh_Node_Counts ( x_return_status  OUT NOCOPY VARCHAR2,
                                    x_msg_count OUT NOCOPY NUMBER,
                                    x_msg_data  OUT NOCOPY VARCHAR2,
                                    p_user_name IN VARCHAR2,
                                    p_responsibility   IN VARCHAR2,
                                    x_invalid_pkg OUT NOCOPY IEU_DIAG_REFRESH_NST,
                                    x_invalid_rproc OUT NOCOPY IEU_DIAG_REFRESH_ERR_NST,
                                    x_refresh_time  OUT NOCOPY IEU_DIAG_REFRENUM_TIME_NST,
                                    x_user_ver_time OUT NOCOPY NUMBER,
                                    x_etime_total OUT NOCOPY NUMBER,
                                    x_rtime_total OUT NOCOPY NUMBER);



PROCEDURE Refresh_Node(p_node_id in number,
                       p_node_pid in number,
                       p_sel_enum_id in number,
                       p_where_clause in varchar2,
                       p_res_cat_enum_flag in varchar2,
                       p_refresh_view_name in varchar2,
                       p_refresh_view_sum_col in varchar2,
                       p_sel_rt_node_id in number,
                       p_count in number,
                       p_resource_id in number,
                       p_view_name in varchar2,
                       p_node_label in varchar2,
                       x_invalid_rproc OUT NOCOPY IEU_DIAG_REFRESH_ERR_NST
                       );


-- ===============================================================
--    Start of Comments
-- ===============================================================
--   API Name
--           Check_View
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--  IN
--
--  p_user_name    IN   VARCHAR2    Required
--  p_responsibility   IN VARCHAR2  Required
--
--
--  OUT
--  x_return_status    OUT  VARCHAR2
--  x_invalid_views      OUT  IEU_DIAG_STRING_NST
--  x_msg_count        OUT  NUMBER
--  x_msg_data         OUT  VARCHAR2

--
--   End of Comments
-- ===============================================================

 PROCEDURE Check_View ( x_return_status  OUT NOCOPY VARCHAR2,
                        x_msg_count OUT NOCOPY NUMBER,
                        x_msg_data  OUT  NOCOPY VARCHAR2,
                        p_user_name IN VARCHAR2,
                        p_responsibility   IN VARCHAR2,
                        x_invalid_views OUT NOCOPY IEU_DIAG_STRING_NST);


--===================================================================
-- NAME
--    CHECK_TASK_LAUNCHING
--
-- PURPOSE
--    Private api to determine if the enabled tasks can be launched.
--
-- NOTES
--    1. UWQ Login Diagnostics will use this procedure.
--
--
-- HISTORY
--   10-April-2002     DOLEE   Created

--===================================================================

PROCEDURE CHECK_TASK_LAUNCHING(x_return_status  OUT NOCOPY VARCHAR2,
                               x_msg_count OUT NOCOPY NUMBER,
                               x_msg_data  OUT NOCOPY VARCHAR2,
						 p_object_code  IN VARCHAR2,
                               p_responsibility   IN VARCHAR2,
						 p_task_source IN VARCHAR2,
                               x_problem_tasks OUT NOCOPY IEU_DIAG_STRING_NST,
						 x_log OUT NOCOPY IEU_DIAG_STRING_NST
                              );
PROCEDURE CHECK_OBJECT_FUNCTION(x_return_status  OUT NOCOPY VARCHAR2,
						  x_msg_count OUT NOCOPY NUMBER,
      					  x_msg_data  OUT NOCOPY VARCHAR2,
						  p_object_code  IN VARCHAR2,
						  p_task_source IN VARCHAR2,
						  x_problem_tasks IN OUT NOCOPY IEU_DIAG_STRING_NST,
						  x_log IN OUT NOCOPY IEU_DIAG_STRING_NST
					   );

END IEU_Diagnostics_PVT;


 

/
