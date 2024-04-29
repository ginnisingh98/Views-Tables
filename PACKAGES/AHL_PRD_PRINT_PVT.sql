--------------------------------------------------------
--  DDL for Package AHL_PRD_PRINT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_PRD_PRINT_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVPPRS.pls 120.1 2006/06/22 14:50:51 bachandr noship $ */

TYPE WORKORDER_TBL_TYPE IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

------------------------------------------------------------------------------------------------
-- Procedure to generate XML data for workorder(s).
------------------------------------------------------------------------------------------------
-- Start of Comments
-- Procedure name              :
-- Type                        : Private
-- Pre-reqs                    :
-- Function                    : Gen_Wo_Xml
-- Parameters                  :
--
-- Standard IN  Parameters :
--      p_api_version               NUMBER   Required
--      p_init_msg_list             VARCHAR2 Default  FND_API.G_FALSE
--      p_commit                    VARCHAR2 Default  FND_API.G_FALSE
--      p_validation_level          NUMBER   Default  FND_API.G_VALID_LEVEL_FULL
--      p_default                   VARCHAR2 Default  FND_API.G_TRUE
--      p_module_type               VARCHAR2 Default  NULL
--
-- Standard OUT Parameters :
--      x_return_status             VARCHAR2 Required
--      x_msg_count                 NUMBER   Required
--      x_msg_data                  VARCHAR2 Required
--
-- IN parameters:
--  	p_workorder_id     	    NUMBER   Required
--	p_visit_id 	     	    NUMBER   Required
--
-- IN OUT parameters:
--      None
--
-- OUT parameters:
--      x_xml_data		    CLOB
--
-- Version :
--      Current version        1.0
--
-- Return Parameter type
-- 	CLOB
-- End of Comments

PROCEDURE Gen_Wo_Xml(
	 p_api_version               IN         	NUMBER		:=1.0,
	 p_init_msg_list             IN         	VARCHAR2	:=FND_API.G_FALSE,
	 p_commit                    IN         	VARCHAR2	:=FND_API.G_FALSE,
	 p_validation_level          IN 		NUMBER		:=FND_API.G_VALID_LEVEL_FULL,
	 p_default                   IN         	VARCHAR2	:=FND_API.G_FALSE,
	 p_module_type               IN         	VARCHAR2	:=NULL,
	 x_return_status             OUT NOCOPY         VARCHAR2,
	 x_msg_count                 OUT NOCOPY         NUMBER,
	 x_msg_data                  OUT NOCOPY         VARCHAR2,
	 p_workorders_tbl    	     IN 		WORKORDER_TBL_TYPE,
	 p_employee_id		     IN			NUMBER,
	 p_user_role		     IN			VARCHAR2,-- required for resource transactions
	 p_material_req_flag	     IN			VARCHAR2 := 'N',--not required any more
	 x_xml_data		     OUT NOCOPY		CLOB,
	 p_concurrent_flag           IN            	VARCHAR2  := 'N'-- pass as N non concurrent programs
	);

------------------------------------------------------------------------------------------------
-- Procedure to generate XML data for Workcard concurrent program
------------------------------------------------------------------------------------------------
-- Start of Comments
-- Procedure name              :
-- Type                        : Private
-- Pre-reqs                    :
-- Function                    : Gen_Workcard_Xml
-- Parameters                  :
--
-- Standard IN  Parameters :
--      p_api_version               NUMBER   Required
--
-- Standard OUT Parameters :
--    errbuf                  OUT NOCOPY  VARCHAR2,
--    retcode                 OUT NOCOPY  NUMBER,
--
-- IN parameters:
--    p_visit_id	    IN 		NUMBER   Required
--    p_stage_id	    IN		NUMBER   Required
--    p_wo_no_from	    IN		VARCHAR2 Required
--    p_wo_no_to	    IN		VARCHAR2 Required
--    p_sch_start_from	    IN		VARCHAR2 Required
--    p_sch_start_to	    IN		VARCHAR2 Required
--    p_employee_id	    IN		NUMBER   Required
--
-- IN OUT parameters:
--      None
--
-- OUT parameters:
--      None.
--
-- Version :
--      Current version        1.0
--
-- Return Parameter
-- 	CLOB
-- End of Comments

PROCEDURE Gen_Workcard_Xml(
    errbuf                  OUT NOCOPY  VARCHAR2,
    retcode                 OUT NOCOPY  NUMBER,
    p_api_version           IN          NUMBER,
    p_visit_id		    IN 		NUMBER,
    p_stage_id		    IN		NUMBER,
    p_wo_no_from	    IN		VARCHAR2,
    p_wo_no_to		    IN		VARCHAR2,
    p_sch_start_from	    IN		VARCHAR2,
    p_sch_start_to	    IN		VARCHAR2,
    p_employee_id	    IN		NUMBER
);

FUNCTION get_tz_offset
RETURN VARCHAR2;

END AHL_PRD_PRINT_PVT;

 

/
