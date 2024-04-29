--------------------------------------------------------
--  DDL for Package IEU_WORK_SOURCE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEU_WORK_SOURCE_PVT" AUTHID CURRENT_USER AS
/* $Header: IEUWSAS.pls 115.3 2003/10/29 21:33:39 dolee noship $ */

-- ===============================================================
-- Start of Comments
-- Package name
--          IEU_WP_ACTION_PVT
-- Purpose
--    To provide easy to use apis for UQW Work Panel.
-- History
--    8-May-2002     dolee   Created.
 -- NOTE

PROCEDURE loadWorkSource(x_return_status  OUT NOCOPY VARCHAR2,
                             x_msg_count OUT NOCOPY NUMBER,
                             x_msg_data  OUT NOCOPY VARCHAR2,
                            p_ws_id  IN varchar2,
                             p_ws_type IN VARCHAR2,
                             p_ws_name IN  VARCHAR2,
                             p_ws_code   IN VARCHAR2,
                             p_ws_desc   IN  VARCHAR2,
                             p_ws_parent_id   IN   number,
                             p_ws_child_id     IN  number,
                             p_ws_dis_from   IN    VARCHAR2,
                             p_ws_dis_to     IN    VARCHAR2,
                             p_ws_dis_func  IN VARCHAR2,
                             p_ws_object_code  IN  VARCHAR2,
                             p_ws_application_id IN varchar2,
                             p_ws_not_valid_flag IN VARCHAR2,
                             p_ws_dis_parent_flag IN VARCHAR2,
                             p_ws_profile_id     IN varchar2,
                             p_ws_profile IN varchar2,
                             p_sqlValidation IN varchar2,
					    p_ws_task_rule_func IN varchar2,
                              r_mode  IN VARCHAR2
                       );

PROCEDURE validateObj (x_return_status  OUT NOCOPY VARCHAR2,
                       x_msg_count OUT NOCOPY NUMBER,
                       x_msg_data  OUT NOCOPY VARCHAR2,
                       p_ws_name  IN varchar2,
                       p_ws_code IN varchar2,
                       p_ws_parent_id IN varchar2,
                       p_ws_child_id IN varchar2,

                       r_mode  IN VARCHAR2
                       );


END IEU_work_source_PVT;

 

/
