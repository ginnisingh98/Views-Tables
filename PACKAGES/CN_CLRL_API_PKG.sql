--------------------------------------------------------
--  DDL for Package CN_CLRL_API_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_CLRL_API_PKG" AUTHID CURRENT_USER AS
-- $Header: cncrapis.pls 115.3 99/07/16 07:05:52 porting ship $


-------------------------------------------------------------------------------
-- Function Name  : Default_Row                                              --
-- Purpose        : Generate a primary key value uing the sequence           --
-- Parameters     :                                                          --
-- IN             :                                                          --
-- OUT            : x_api_id     IN       NUMBER           Required          --
-- History                                                                   --
--   26-AUG-98  Ram Kalyanasundaram      Created
-------------------------------------------------------------------------------
PROCEDURE Default_Row(x_api_id       OUT        NUMBER);

-------------------------------------------------------------------------------
-- Function Name  : Insert_Row                                               --
-- Purpose        : Insert a row into the table                              --
-- Parameters     :                                                          --
-- IN             : p_api_id                IN   NUMBER    Required          --
--                  p_ruleset_name          IN   VARCHAR2  Required          --
--                  p_parent_rule_name      IN   VARCHAR2  Required          --
--                  p_rule_name             IN   VARCHAR2  Required          --
--                  p_revenue_class_name    IN   VARCHAR2  Required          --
--                  p_attribute_rule_name   IN   VARCHAR2  Required          --
--                  p_not_flag              IN   VARCHAR2  Required          --
--                  p_value_1               IN   VARCHAR2  Required          --
--                  p_value_2               IN   VARCHAR2  Required          --
--                  p_data_flag             IN   VARCHAR2  Required          --
--                  p_loading_status        IN   VARCHAR2  Required          --
--                  p_object_name           IN   VARCHAR2  Required          --
--                  p_message_text          IN   VARCHAR2  Required          --
--                  p_return_status         IN   VARCHAR2  Required          --
-- OUT            :                                                          --
-- History                                                                   --
--   26-AUG-98  Ram Kalyanasundaram      Created
-------------------------------------------------------------------------------
PROCEDURE Insert_Row(p_api_id                IN   NUMBER,
		     p_ruleset_name          IN   VARCHAR2,
		     p_parent_rule_name      IN   VARCHAR2,
		     p_rule_name             IN   VARCHAR2,
		     p_revenue_class_name    IN   VARCHAR2,
		     p_attribute_rule_name   IN   VARCHAR2,
		     p_not_flag              IN   VARCHAR2,
		     p_value_1               IN   VARCHAR2,
		     p_value_2               IN   VARCHAR2,
		     p_data_flag             IN   VARCHAR2,
		     p_loading_status        IN   VARCHAR2,
		     p_object_name           IN   VARCHAR2,
		     p_message_text          IN   VARCHAR2,
		     p_return_status         IN   VARCHAR2);

-------------------------------------------------------------------------------
-- Function Name  : Delete_Row                                               --
-- Purpose        : Delete a row if the given primary key exists             --
-- Parameters     :                                                          --
-- IN             : p_api_id     IN       NUMBER           Required          --
-- OUT            :                                                          --
-- History                                                                   --
--   26-AUG-98  Ram Kalyanasundaram      Created
-------------------------------------------------------------------------------
PROCEDURE Delete_Row(p_api_id       IN        NUMBER);

-------------------------------------------------------------------------------
-- Function Name  : Update_Row                                               --
-- Purpose        : Update a row if the given primary key exists             --
-- Parameters     :                                                          --
-- IN             : p_api_id            IN   NUMBER        Required          --
--                  p_loading_status    IN   VARCHAR2      Required          --
--                  p_message_text          IN   VARCHAR2  Required          --
--                  p_return_status         IN   VARCHAR2  Required          --
-- OUT            :                                                          --
-- History                                                                   --
--   26-AUG-98  Ram Kalyanasundaram      Created
-------------------------------------------------------------------------------
PROCEDURE Update_Row(p_api_id         IN        NUMBER,
		     p_loading_status IN        VARCHAR2,
		     p_message_text   IN        VARCHAR2,
		     p_return_status  IN        VARCHAR2);

END cn_clrl_api_pkg;


 

/
