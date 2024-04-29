--------------------------------------------------------
--  DDL for Package JTF_RS_RESOURCE_VALUES_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_RESOURCE_VALUES_VUHK" AUTHID CURRENT_USER AS
  /* $Header: jtfrsics.pls 120.0 2005/05/11 08:20:13 appldev ship $ */

  /*****************************************************************************************
   This is the Vertical Industry User Hook API.
   The Internal Groups can add customization procedures here for Pre and Post Processing.
   ******************************************************************************************/

  /* Vertical Industry Procedure for pre processing in case of create resource values */

  PROCEDURE  create_rs_resource_values_pre (
     p_resource_id             IN      NUMBER,
     p_resource_param_id       IN      NUMBER,
     p_value                   IN      VARCHAR2,
     p_value_type              IN      VARCHAR2,
     X_Return_Status           OUT NOCOPY     VARCHAR2,
     X_Msg_Count               OUT NOCOPY     NUMBER,
     X_Msg_Data                OUT NOCOPY     VARCHAR2
  );

  /* Vertical Industry Procedure for post processing in case of create resource values */

  PROCEDURE  create_rs_resource_values_post (
     p_resource_id             IN      NUMBER,
     p_resource_param_id       IN      NUMBER,
     p_value                   IN      VARCHAR2,
     p_value_type              IN      VARCHAR2,
     X_Return_Status           OUT NOCOPY     VARCHAR2,
     X_Msg_Count               OUT NOCOPY     NUMBER,
     X_Msg_Data                OUT NOCOPY     VARCHAR2,
     P_resource_param_value_id IN      NUMBER
  );

 /* Vertical Industry Procedure for pre processing in case of update resource values */

  PROCEDURE  update_rs_resource_values_pre (
     p_resource_param_value_id IN      NUMBER,
     p_value                   IN      VARCHAR2,
     X_Return_Status           OUT NOCOPY     VARCHAR2,
     X_Msg_Count               OUT NOCOPY     NUMBER,
     X_Msg_Data                OUT NOCOPY     VARCHAR2
  );

 /* Vertical Industry Procedure for post processing in case of update resource values */

  PROCEDURE  update_rs_resource_values_post (
     p_resource_param_value_id IN      NUMBER,
     p_value                   IN      VARCHAR2,
     X_Return_Status           OUT NOCOPY     VARCHAR2,
     X_Msg_Count               OUT NOCOPY     NUMBER,
     X_Msg_Data                OUT NOCOPY     VARCHAR2
  );

 /* Vertical Industry Procedure for pre processing in case of delete resource values */

  PROCEDURE  delete_rs_resource_values_pre (
     p_resource_param_value_id IN      NUMBER,
     X_Return_Status           OUT NOCOPY     VARCHAR2,
     X_Msg_Count               OUT NOCOPY     NUMBER,
     X_Msg_Data                OUT NOCOPY    VARCHAR2
  );

 /* Vertical Industry Procedure for post processing in case of delete resource values */

  PROCEDURE  delete_rs_resource_values_post (
     p_resource_param_value_id IN      NUMBER,
     X_Return_Status           OUT NOCOPY     VARCHAR2,
     X_Msg_Count               OUT NOCOPY     NUMBER,
     X_Msg_Data                OUT NOCOPY     VARCHAR2
  );

 /* Vertical Industry Procedure for pre processing in case of delete all resource values */

  PROCEDURE  delete_all_rs_values_pre (
     p_resource_id		IN      NUMBER,
     X_Return_Status           	OUT NOCOPY    VARCHAR2,
     X_Msg_Count               	OUT NOCOPY    NUMBER,
     X_Msg_Data                	OUT NOCOPY    VARCHAR2
  );

 /* Vertical Industry Procedure for post processing in case of delete all resource values */

  PROCEDURE  delete_all_rs_values_post (
     p_resource_id 		IN      NUMBER,
     X_Return_Status           	OUT NOCOPY    VARCHAR2,
     X_Msg_Count               	OUT NOCOPY    NUMBER,
     X_Msg_Data                	OUT NOCOPY    VARCHAR2
  );

END jtf_rs_resource_values_vuhk;

 

/
