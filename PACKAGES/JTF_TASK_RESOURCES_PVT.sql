--------------------------------------------------------
--  DDL for Package JTF_TASK_RESOURCES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASK_RESOURCES_PVT" AUTHID CURRENT_USER AS
/* $Header: jtfvtkrs.pls 115.21 2002/12/05 00:08:12 cjang ship $ */

---------------------------------------------------------------------------
--Define Global Variables
---------------------------------------------------------------------------
G_PKG_NAME	CONSTANT	VARCHAR2(30):='JTF_TASK_RESOURCES_PVT' ;
G_USER		CONSTANT	VARCHAR2(30):=FND_GLOBAL.USER_ID;
G_FALSE		CONSTANT	VARCHAR2(30):=FND_API.G_FALSE;
G_TRUE		CONSTANT	VARCHAR2(30):=FND_API.G_TRUE;
---------------------------------------------------------------------------

--Define Record Variables

TYPE  TASK_RSRC_REQ_REC is RECORD
( RESOURCE_REQ_ID                	      NUMBER		    ,
 TASK_TYPE_ID                             NUMBER		    ,
 TASK_TYPE_NAME				              VARCHAR2(30)		,
 TASK_ID                                  NUMBER		    ,
 TASK_NAME				                  VARCHAR(80)		,
 TASK_NUMBER				              VARCHAR2(30)		,
 TASK_TEMPLATE_ID                         NUMBER		    ,
 TASK_TEMPLATE_NAME			              VARCHAR2(80)		,
 RESOURCE_TYPE_CODE             	      VARCHAR2(10)		,
 REQUIRED_UNITS                  	      NUMBER		    ,
 ENABLED_FLAG                             VARCHAR2(1)		);



 --Function to validate resource type code

 Function validate_resource_type_code
(p_resource_type_code in varchar2 ) return boolean ;

	PROCEDURE validate_task_template (
        x_return_status           	OUT NOCOPY   VARCHAR2              ,
        p_task_template_id        	IN    NUMBER 	DEFAULT NULL,
        p_task_name			        IN	  VARCHAR2 	DEFAULT NULL,
        x_task_template_id          OUT NOCOPY   NUMBER                ,
        x_task_name              	OUT NOCOPY   VARCHAR2
                                                               );

 	PROCEDURE validate_task_type (
        x_return_status           	OUT NOCOPY   VARCHAR2              ,
        p_task_type_id        		IN    NUMBER  	DEFAULT NULL,
        p_name				        IN	  VARCHAR2 	DEFAULT NULL,
        x_task_type_id             	OUT NOCOPY   NUMBER                ,
        x_task_name			        OUT NOCOPY	  VARCHAR2
                                                                );


--Procedure to validate Enabled Flag

 	PROCEDURE VALIDATE_ENABLED_FLAG
 	(L_API_NAME 			        IN	  VARCHAR2,
 	P_FLAG				            IN	  VARCHAR2,
 	P_FLAG_NAME			            IN	  VARCHAR2);


    PROCEDURE dump_long_line
    (txt                            IN    VARCHAR2,
    v_str                           IN    VARCHAR2) ;




--Procedure to Create Task Resource Requirements

	PROCEDURE CREATE_TASK_RSRC_REQ
	(P_API_VERSION			        IN	NUMBER					            ,
	P_INIT_MSG_LIST			        IN	VARCHAR2  DEFAULT FND_API.G_FALSE	,
	P_COMMIT			            IN	VARCHAR2  DEFAULT FND_API.G_FALSE	,
	P_TASK_ID			            IN	NUMBER	  DEFAULT NULL			    ,
	P_TASK_NAME			            IN	VARCHAR2  DEFAULT NULL			    ,
	P_TASK_NUMBER			        IN	VARCHAR2  DEFAULT NULL			    ,
	P_TASK_TYPE_ID			        IN	NUMBER 	  DEFAULT NULL			    ,
	P_TASK_TYPE_NAME		        IN	VARCHAR2  DEFAULT NULL			    ,
	P_TASK_TEMPLATE_ID		        IN	NUMBER	  DEFAULT NULL			    ,
	P_TASK_TEMPLATE_NAME		    IN	VARCHAR2  DEFAULT NULL			    ,
	P_RESOURCE_TYPE_CODE		    IN	VARCHAR2				            ,
	P_REQUIRED_UNITS		        IN	NUMBER 	 				            ,
	P_ENABLED_FLAG			        IN	VARCHAR2 DEFAULT jtf_task_utl.g_no	,
	X_RETURN_STATUS			        OUT NOCOPY	VARCHAR2				            ,
	X_MSG_COUNT			            OUT NOCOPY	NUMBER 					            ,
	X_MSG_DATA			            OUT NOCOPY	VARCHAR2				            ,
	X_RESOURCE_REQ_ID		        OUT NOCOPY	NUMBER					          ,
        p_attribute1              IN       VARCHAR2 DEFAULT null ,
        p_attribute2              IN       VARCHAR2 DEFAULT null ,
        p_attribute3              IN       VARCHAR2 DEFAULT null ,
        p_attribute4              IN       VARCHAR2 DEFAULT null ,
        p_attribute5              IN       VARCHAR2 DEFAULT null ,
        p_attribute6              IN       VARCHAR2 DEFAULT null ,
        p_attribute7              IN       VARCHAR2 DEFAULT null ,
        p_attribute8              IN       VARCHAR2 DEFAULT null ,
        p_attribute9              IN       VARCHAR2 DEFAULT null ,
        p_attribute10             IN       VARCHAR2 DEFAULT null ,
        p_attribute11             IN       VARCHAR2 DEFAULT null ,
        p_attribute12             IN       VARCHAR2 DEFAULT null ,
        p_attribute13             IN       VARCHAR2 DEFAULT null ,
        p_attribute14             IN       VARCHAR2 DEFAULT null ,
        p_attribute15             IN       VARCHAR2 DEFAULT null ,
        p_attribute_category      IN       VARCHAR2 DEFAULT null
       ) ;




--Procedure to Update the Task Resource Requirements


	PROCEDURE  UPDATE_TASK_RSCR_REQ
	(P_API_VERSION			         IN	 NUMBER					            ,
	P_OBJECT_VERSION_NUMBER		     IN  OUT NOCOPY	NUMBER 	 				    ,
	P_INIT_MSG_LIST			         IN	 VARCHAR2 DEFAULT FND_API.G_FALSE	,
	P_COMMIT			             IN	 VARCHAR2 DEFAULT FND_API.G_FALSE	,
	P_RESOURCE_REQ_ID		         IN	 NUMBER 					        ,
	P_TASK_ID			             IN	 NUMBER   DEFAULT NULL			    ,
	P_TASK_NAME			             IN	 VARCHAR2 DEFAULT NULL			    ,
	P_TASK_NUMBER			         IN	 VARCHAR2 DEFAULT NULL			    ,
	P_TASK_TYPE_ID			         IN	 NUMBER   DEFAULT NULL			    ,
	P_TASK_TYPE_NAME		         IN	 VARCHAR2 				            ,
	P_TASK_TEMPLATE_ID		         IN	 NUMBER   DEFAULT NULL			    ,
	P_TASK_TEMPLATE_NAME		     IN	 VARCHAR2				            ,
	P_RESOURCE_TYPE_CODE		     IN	 VARCHAR2				            ,
	P_REQUIRED_UNITS		         IN	 NUMBER 	 				        ,
	P_ENABLED_FLAG			         IN	 VARCHAR2 DEFAULT jtf_task_utl.g_no	,
	X_RETURN_STATUS			         OUT NOCOPY VARCHAR2				            ,
	X_MSG_COUNT			             OUT NOCOPY NUMBER 					        ,
	X_MSG_DATA			             OUT NOCOPY VARCHAR2				           ,
        p_attribute1              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute2              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute3              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute4              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute5              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute6              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute7              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute8              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute9              IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute10             IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute11             IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute12             IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute13             IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute14             IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute15             IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char,
        p_attribute_category      IN       VARCHAR2 DEFAULT jtf_task_utl.g_miss_char

       );



--Procedure to Delete the Task Resource Requirements



	PROCEDURE DELETE_TASK_RSRC_REQ
	(P_API_VERSION			         IN	  NUMBER					        ,
	P_OBJECT_VERSION_NUMBER		     IN	  NUMBER   				            ,
	P_INIT_MSG_LIST			         IN	  VARCHAR2 DEFAULT FND_API.G_FALSE	,
	P_COMMIT			             IN	  VARCHAR2 DEFAULT FND_API.G_FALSE	,
	P_RESOURCE_REQ_ID		         IN	  NUMBER 					        ,
	X_RETURN_STATUS			         OUT NOCOPY  VARCHAR2				            ,
	X_MSG_COUNT			             OUT NOCOPY  NUMBER 					        ,
	X_MSG_DATA			             OUT NOCOPY  VARCHAR2 				            );


--Procedure to get the Task Resource Req



	 PROCEDURE   GET_TASK_RSRC_REQ
	(
	P_API_VERSION			         IN	  NUMBER	 			           ,
	P_INIT_MSG_LIST			         IN	  VARCHAR2 	DEFAULT G_FALSE	       ,
	P_COMMIT			             IN	  VARCHAR2	DEFAULT G_FALSE	       ,
	P_RESOURCE_REQ_ID		         IN	  NUMBER 				           ,
	P_RESOURCE_REQ_NAME		         IN	  VARCHAR2	DEFAULT NULL	       ,
	P_TASK_ID			             IN	  NUMBER 	DEFAULT NULL	       ,
	P_TASK_NAME			             IN	  VARCHAR2	DEFAULT NULL	       ,
	P_TASK_TYPE_ID			         IN	  NUMBER 	DEFAULT NULL	       ,
	P_TASK_TYPE_NAME		         IN	  VARCHAR2	DEFAULT NULL	       ,
	P_TASK_TEMPLATE_ID		         IN	  NUMBER	DEFAULT NULL	       ,
	P_TASK_TEMPLATE_NAME		     IN	  VARCHAR2	DEFAULT NULL	       ,
	P_SORT_DATA                	     IN   JTF_TASK_RESOURCES_PUB.SORT_DATA ,
	P_QUERY_OR_NEXT_CODE       	     IN   VARCHAR2  DEFAULT  'Q'	       ,
	P_START_POINTER            	     IN   NUMBER				           ,
	P_REC_WANTED               	     IN   NUMBER				           ,
	P_SHOW_ALL                 	     IN   VARCHAR2  DEFAULT  'Y'	       ,
	P_RESOURCE_TYPE_CODE		     IN	  VARCHAR2			               ,
	P_REQUIRED_UNITS		         IN	  NUMBER 				           ,
	P_ENABLED_FLAG			         IN	  VARCHAR2	DEFAULT jtf_task_utl.g_no ,
	X_RETURN_STATUS			         OUT NOCOPY  VARCHAR2			               ,
	X_MSG_COUNT			             OUT NOCOPY  NUMBER				           ,
	X_MSG_DATA			             OUT NOCOPY  VARCHAR2 			               ,
	X_TASK_RSC_REQ_REC		         OUT NOCOPY  JTF_TASK_RESOURCES_PUB.TASK_RSC_REQ_TBL,
	X_TOTAL_RETRIEVED          	     OUT NOCOPY  NUMBER				           ,
	X_TOTAL_RETURNED           	     OUT NOCOPY  NUMBER 				            );




END  ;

 

/
