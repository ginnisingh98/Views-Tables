--------------------------------------------------------
--  DDL for Package JTF_RS_RESOURCE_VALUES_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_RESOURCE_VALUES_CUHK" AUTHID CURRENT_USER AS
  /* $Header: jtfrsccs.pls 120.0 2005/05/11 08:19:36 appldev ship $ */

  /*****************************************************************************************
   This is the Customer User Hook API.
   The Customers can add customization procedures here for Pre and Post Processing.
   ******************************************************************************************/

  /* Customer Procedure for pre processing in case of create resource values */

  PROCEDURE  create_rs_resource_values_pre (
     p_resource_id             IN      NUMBER,
     p_resource_param_id       IN      NUMBER,
     p_value                   IN      VARCHAR2,
     p_value_type              IN      VARCHAR2,
     X_Return_Status           OUT NOCOPY     VARCHAR2,
     X_Msg_Count               OUT NOCOPY     NUMBER,
     X_Msg_Data                OUT NOCOPY    VARCHAR2
  );

  /* Customer Procedure for post processing in case of create resource values */

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

 /* Customer Procedure for pre processing in case of update resource values */

  PROCEDURE  update_rs_resource_values_pre (
     p_resource_param_value_id IN      NUMBER,
     p_value                   IN      VARCHAR2,
     X_Return_Status           OUT NOCOPY     VARCHAR2,
     X_Msg_Count               OUT NOCOPY     NUMBER,
     X_Msg_Data                OUT NOCOPY    VARCHAR2
  );

 /* Customer Procedure for post processing in case of update resource values */

  PROCEDURE  update_rs_resource_values_post (
     p_resource_param_value_id IN      NUMBER,
     p_value                   IN      VARCHAR2,
     X_Return_Status           OUT NOCOPY     VARCHAR2,
     X_Msg_Count               OUT NOCOPY     NUMBER,
     X_Msg_Data                OUT NOCOPY    VARCHAR2
  );

 /* Customer Procedure for pre processing in case of delete resource values */

  PROCEDURE  delete_rs_resource_values_pre (
     p_resource_param_value_id IN      NUMBER,
     X_Return_Status           OUT NOCOPY     VARCHAR2,
     X_Msg_Count               OUT NOCOPY     NUMBER,
     X_Msg_Data                OUT NOCOPY    VARCHAR2
  );

 /* Customer Procedure for post processing in case of delete resource values */

  PROCEDURE  delete_rs_resource_values_post (
     p_resource_param_value_id IN      NUMBER,
     X_Return_Status           OUT NOCOPY     VARCHAR2,
     X_Msg_Count               OUT NOCOPY     NUMBER,
     X_Msg_Data                OUT NOCOPY    VARCHAR2
  );

 /* Customer Procedure for pre processing in case of delete all resource values */

  PROCEDURE  delete_all_rs_values_pre (
     p_resource_id 		IN      NUMBER,
     X_Return_Status           	OUT NOCOPY    VARCHAR2,
     X_Msg_Count               	OUT NOCOPY    NUMBER,
     X_Msg_Data                	OUT NOCOPY    VARCHAR2
  );

 /* Customer Procedure for post processing in case of delete all resource values */

  PROCEDURE  delete_all_rs_values_post (
     p_resource_id 		IN      NUMBER,
     X_Return_Status           	OUT NOCOPY    VARCHAR2,
     X_Msg_Count               	OUT NOCOPY    NUMBER,
     X_Msg_Data                	OUT NOCOPY    VARCHAR2
  );

  /* Customer/Vertical Industry Function before Message Generation */

  FUNCTION ok_to_generate_msg (
     P_RESOURCE_PARAM_VALUE_ID	IN   JTF_RS_RESOURCE_VALUES.RESOURCE_PARAM_VALUE_ID%TYPE,
     X_RETURN_STATUS        	OUT NOCOPY VARCHAR2
  )RETURN BOOLEAN;

END jtf_rs_resource_values_cuhk;

 

/
