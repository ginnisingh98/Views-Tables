--------------------------------------------------------
--  DDL for Package BIS_RSG_PUB_API_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_RSG_PUB_API_PKG" AUTHID CURRENT_USER AS
/* $Header: BISRSGPS.pls 120.1 2005/09/16 06:22:40 amitgupt noship $ */
   version               CONSTANT VARCHAR (80)
            := '$Header: BISRSGPS.pls 120.1 2005/09/16 06:22:40 amitgupt noship $';

PROCEDURE Create_Dependency (
 P_OBJECT_TYPE		in VARCHAR2,
 P_OBJECT_OWNER		in VARCHAR2,
 P_OBJECT_NAME		in VARCHAR2,
 P_ENABLED_FLAG		in VARCHAR2,
 P_DEPEND_OBJECT_TYPE	in VARCHAR2,
 P_DEPEND_OBJECT_OWNER	in VARCHAR2,
 P_DEPEND_OBJECT_NAME	in VARCHAR2,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_msg_data             OUT NOCOPY  VARCHAR2
);

PROCEDURE Update_Dependency (
 P_OBJECT_TYPE		in VARCHAR2,
 P_OBJECT_NAME		in VARCHAR2,
 P_ENABLED_FLAG		in VARCHAR2,
 P_DEPEND_OBJECT_TYPE	in VARCHAR2,
 P_DEPEND_OBJECT_NAME	in VARCHAR2,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_msg_data             OUT NOCOPY  VARCHAR2
) ;

PROCEDURE Delete_Dependency (
 P_OBJECT_TYPE		in VARCHAR2,
 P_OBJECT_NAME		in VARCHAR2,
 P_DEPEND_OBJECT_TYPE	in VARCHAR2,
 P_DEPEND_OBJECT_NAME	in VARCHAR2,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_msg_data             OUT NOCOPY  VARCHAR2
) ;

--added for bug 4606455
PROCEDURE Delete_Dependency (
 P_ROWID                            IN ROWID,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_msg_data             OUT NOCOPY  VARCHAR2
) ;

PROCEDURE Delete_Page_Dependencies (
 P_OBJECT_NAME		in VARCHAR2,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_msg_data             OUT NOCOPY  VARCHAR2
);

PROCEDURE Update_Property(
 P_OBJECT_TYPE 		in VARCHAR2,
 P_OBJECT_NAME		in VARCHAR2,
 P_DIMENSION_FLAG       in VARCHAR2,
 P_CUSTOM_API           in VARCHAR2,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_msg_data             OUT NOCOPY  VARCHAR2
) ;

PROCEDURE Update_Property_Dim_Flag(
 P_OBJECT_TYPE 		in VARCHAR2,
 P_OBJECT_NAME		in VARCHAR2,
 P_DIMENSION_FLAG       in VARCHAR2,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_msg_data             OUT NOCOPY  VARCHAR2
) ;

PROCEDURE Update_Property_Custom_API(
 P_OBJECT_TYPE 		in VARCHAR2,
 P_OBJECT_NAME		in VARCHAR2,
 P_CUSTOM_API           in VARCHAR2,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_msg_data             OUT NOCOPY  VARCHAR2
) ;


PROCEDURE Create_Linkage (
 P_OBJECT_TYPE		in VARCHAR2,
 P_OBJECT_OWNER		in VARCHAR2,
 P_OBJECT_NAME		in VARCHAR2,
 P_ENABLED_FLAG		in VARCHAR2,
 P_CONC_PROG_NAME	in VARCHAR2,
 P_APPL_SHORT_NAME	in VARCHAR2,
 P_REFRESH_MODE	        in VARCHAR2,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_msg_data             OUT NOCOPY  VARCHAR2
);

PROCEDURE Update_Linkage (
 P_OBJECT_TYPE		in VARCHAR2,
 P_OBJECT_NAME		in VARCHAR2,
 P_ENABLED_FLAG		in VARCHAR2,
 P_CONC_PROG_NAME	in VARCHAR2,
 P_APPL_SHORT_NAME	in VARCHAR2,
 p_refresh_mode         IN VARCHAR2,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_msg_data             OUT NOCOPY  VARCHAR2
) ;

PROCEDURE Update_Linkage_Enabled_Flag (
 P_OBJECT_TYPE		in VARCHAR2,
 P_OBJECT_NAME		in VARCHAR2,
 P_ENABLED_FLAG		in VARCHAR2,
 P_CONC_PROG_NAME	in VARCHAR2,
 P_APPL_SHORT_NAME	in VARCHAR2,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_msg_data             OUT NOCOPY  VARCHAR2
) ;

PROCEDURE Update_Linkage_Refresh_Mode (
 P_OBJECT_TYPE		in VARCHAR2,
 P_OBJECT_NAME		in VARCHAR2,
 P_CONC_PROG_NAME	in VARCHAR2,
 P_APPL_SHORT_NAME	in VARCHAR2,
 p_refresh_mode         IN VARCHAR2,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_msg_data             OUT NOCOPY  VARCHAR2
) ;

PROCEDURE Delete_Linkage (
 P_OBJECT_TYPE		in VARCHAR2,
 P_OBJECT_NAME		in VARCHAR2,
 P_CONC_PROG_NAME	in VARCHAR2,
 P_APPL_SHORT_NAME	in VARCHAR2,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_msg_data             OUT NOCOPY  VARCHAR2
) ;

--added for bug 4606455
PROCEDURE Delete_Linkage (
 P_ROWID                            IN ROWID,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_msg_data             OUT NOCOPY  VARCHAR2
) ;

PROCEDURE Delete_Obj_Linkages (
 P_OBJECT_TYPE		in VARCHAR2,
 P_OBJECT_NAME		in VARCHAR2,
 x_return_status        OUT NOCOPY  VARCHAR2,
 x_msg_data             OUT NOCOPY  VARCHAR2
) ;


FUNCTION get_page_name_by_func (
 p_func_name   IN VARCHAR2) RETURN VARCHAR2;

-- for testing
PROCEDURE delete_property (
 P_OBJECT_TYPE		in VARCHAR2,
 P_OBJECT_NAME		in VARCHAR2
);

--begin: added for enhancement bug 3686273

TYPE t_BIA_RSG_Obj_Rec IS RECORD (object_name	VARCHAR2(240),
				  user_object_name VARCHAR2(240),
				  object_owner VARCHAR2(50));

TYPE t_BIA_RSG_Obj_Table IS TABLE OF t_BIA_RSG_Obj_Rec INDEX BY BINARY_INTEGER;

-- retrieve all the ancestor objects for a given dependent object, considering both
-- enabled and disabled dependencies, so as to fix bug 3867557
FUNCTION GetParentObjects(P_DEP_OBJ_NAME 		IN	VARCHAR2,
			  P_DEP_OBJ_TYPE		IN	VARCHAR2,
			  P_OBJ_TYPE			IN	VARCHAR2,
			  X_RETURN_STATUS		OUT	NOCOPY	VARCHAR2,
			  X_MSG_DATA			OUT	NOCOPY	VARCHAR2
			  ) RETURN t_BIA_RSG_Obj_Table;


-- end: enhancement bug 3686273

-- begin: enhancement bug 3999642
procedure enable_index_mgmt(p_mv_name in varchar2, p_mv_schema in varchar2) ;

procedure disable_index_mgmt(p_mv_name in varchar2, p_mv_schema in varchar2) ;
-- end: enhancement bug 3999642

END bis_rsg_pub_api_pkg;

 

/
