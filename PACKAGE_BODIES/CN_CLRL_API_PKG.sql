--------------------------------------------------------
--  DDL for Package Body CN_CLRL_API_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_CLRL_API_PKG" AS
-- $Header: cncrapib.pls 115.4 99/07/16 07:05:48 porting ship $


-------------------------------------------------------------------------------
-- Function Name  : Default_Row                                              --
-- Purpose        : Generate a primary key value uing the sequence           --
-- Parameters     :                                                          --
-- IN             :                                                          --
-- OUT            : x_api_id     IN       NUMBER           Required          --
-- History                                                                   --
--   26-AUG-98  Ram Kalyanasundaram      Created
-------------------------------------------------------------------------------
PROCEDURE Default_Row(x_api_id       OUT        NUMBER)
  IS
BEGIN
   SELECT cn_clrl_api_s.NEXTVAL
     INTO x_api_id
     FROM dual;
END Default_Row;

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
		     p_return_status         IN   VARCHAR2)
  IS
BEGIN
   INSERT INTO cn_clrl_api
     (clrl_api_id,
      ruleset_name, parent_rule_name,
      rule_name, revenue_class_name,
      attribute_rule_name, not_flag, value_1,
      value_2, data_flag, loading_status, object_name,
      message_text, return_status)
     VALUES(p_api_id, p_ruleset_name, p_parent_rule_name,
	    p_rule_name, p_revenue_class_name,
	    p_attribute_rule_name, p_not_flag, p_value_1,
	    p_value_2, p_data_flag, p_loading_status, p_object_name,
	    p_message_text, p_return_status);

END Insert_Row;

-------------------------------------------------------------------------------
-- Function Name  : Delete_Row                                               --
-- Purpose        : Delete a row if the given primary key exists             --
-- Parameters     :                                                          --
-- IN             : p_api_id     IN       NUMBER           Required          --
-- OUT            :                                                          --
-- History                                                                   --
--   26-AUG-98  Ram Kalyanasundaram      Created
-------------------------------------------------------------------------------
PROCEDURE Delete_Row(p_api_id       IN        NUMBER)
  IS
BEGIN
   DELETE FROM cn_clrl_api
     WHERE clrl_api_id = p_api_id;
END Delete_Row;

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
		     p_return_status  IN        VARCHAR2)
  IS
BEGIN
   UPDATE cn_clrl_api
     SET loading_status = p_loading_status,
         message_text = p_message_text,
         return_status = p_return_status
     WHERE clrl_api_id = p_api_id;
END Update_Row;

END cn_clrl_api_pkg;


/
