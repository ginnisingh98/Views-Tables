--------------------------------------------------------
--  DDL for Package AMS_LIST_OPTIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_LIST_OPTIONS_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvlops.pls 120.1 2005/08/11 09:41 bmuthukr noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_List_Options_Pvt
-- Purpose
--  Created to move all the code related to optional processes
--  like random list generation, suppression, max size restriction
--  control group generation from the list generation engine code.
-- History
--   Created bmuthukr 19-Jul-2005.
-- NOTE
--
-- End of Comments
-- ===============================================================
TYPE G_MSG_TBL_TYPE IS TABLE OF VARCHAR2(1000) INDEX BY BINARY_INTEGER;
PROCEDURE CG_Gen_Process(errbuf             OUT NOCOPY VARCHAR2,
                         retcode            OUT NOCOPY VARCHAR2,
			 p_list_header_id   IN NUMBER
                         );
PROCEDURE Control_Group_Generation(
                  p_list_header_id  IN  NUMBER,
  	          p_log_level       IN  varchar2 DEFAULT NULL,
	          p_msg_tbl         OUT NOCOPY AMS_LIST_OPTIONS_PVT.G_MSG_TBL_TYPE,
		  x_ctrl_grp_status OUT NOCOPY VARCHAR2,
		  x_return_status   OUT NOCOPY VARCHAR2,
                  x_msg_count       OUT NOCOPY NUMBER,
                  x_msg_data        OUT NOCOPY VARCHAR2) ;

PROCEDURE Control_Group_Generation(
                  p_list_header_id  IN  NUMBER,
  	          p_log_level       IN  varchar2 DEFAULT NULL,
		  x_ctrl_grp_status OUT NOCOPY VARCHAR2,
		  x_return_status   OUT NOCOPY VARCHAR2,
                  x_msg_count       OUT NOCOPY NUMBER,
                  x_msg_data        OUT NOCOPY VARCHAR2) ;

procedure apply_size_reduction
             (p_list_header_id     IN  number,
	      p_log_level          IN  varchar2 DEFAULT NULL,
              p_msg_tbl            OUT NOCOPY AMS_LIST_OPTIONS_PVT.G_MSG_TBL_TYPE,
              x_return_status      OUT NOCOPY VARCHAR2,
              x_msg_count          OUT NOCOPY NUMBER,
              x_msg_data           OUT NOCOPY VARCHAR2);

procedure apply_size_reduction
             (p_list_header_id     IN  number,
	      p_log_level          IN  varchar2 DEFAULT NULL,
              x_return_status      OUT NOCOPY VARCHAR2,
              x_msg_count          OUT NOCOPY NUMBER,
              x_msg_data           OUT NOCOPY VARCHAR2);

END AMS_List_Options_Pvt;
 

/
