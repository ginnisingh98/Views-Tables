--------------------------------------------------------
--  DDL for Package BIS_TARGET_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_TARGET_UTIL" AUTHID CURRENT_USER AS
/* $Header: BISUTRGS.pls 115.12 99/07/17 16:11:40 porting shi $ */

--  Global constant holding the package name

G_PKG_NAME          CONSTANT VARCHAR2(30) := 'BIS_TARGET_UTIL';

--  Global variables holding cached record.

--  Functions/ Procedures
Procedure Create_Ind_Level_View
   (p_ind_level_name IN Varchar2
   ,p_msg_init       IN Varchar2 default FND_API.G_TRUE
   ,x_return_status  OUT Varchar2
   ,x_msg_count      OUT Number
   ,x_msg_data       OUT Varchar2);
Procedure Create_Indicator_views
   (p_indicator_name IN Varchar2
   ,p_msg_init       IN Varchar2 default FND_API.G_TRUE
   ,x_return_status  OUT Varchar2
   ,x_msg_count      OUT Number
   ,x_msg_data       OUT Varchar2);
Procedure Create_BIS_views
   (p_msg_init       IN Varchar2 default FND_API.G_TRUE
   ,x_return_status  OUT Varchar2
   ,x_msg_count      OUT Number
   ,x_msg_data       OUT Varchar2);

Procedure Drop_Ind_Level_view
   (p_target_level_id IN  Number
   ,x_return_status   OUT Varchar2
   ,x_msg_count       OUT Number
   ,x_msg_data        OUT Varchar2);

Procedure Get_Dimension_Display_Value
   (
--p_dim_type	      IN Varchar2
   p_dim_level_id    IN number
   ,p_dim_level_value_id    IN Varchar2
--   ,p_dim_resp_id     IN number default null
   ,x_dim_level_value_name  OUT Varchar2
   ,x_return_status   OUT Varchar2
   ,x_msg_count       OUT Number
   ,x_msg_data        OUT Varchar2);

Procedure Validate_Resp_Org
   (p_dim_level_id     	IN number
   ,p_responsibility_id IN number
   ,p_organization_id 	IN number
   ,p_user_id		IN number
   ,x_return_status   OUT Varchar2
   ,x_msg_count       OUT Number
   ,x_msg_data        OUT Varchar2);

END BIS_TARGET_UTIL;

 

/
