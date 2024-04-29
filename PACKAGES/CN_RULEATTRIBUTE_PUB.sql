--------------------------------------------------------
--  DDL for Package CN_RULEATTRIBUTE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_RULEATTRIBUTE_PUB" AUTHID CURRENT_USER AS
--$Header: cnpratrs.pls 120.1 2005/08/25 23:38:05 rramakri noship $

TYPE RuleAttribute_rec_type IS RECORD
  (ruleset_name               cn_rulesets.name%TYPE,
   start_date                 cn_rulesets.start_date%TYPE,
   end_date                   cn_rulesets.end_date%TYPE,
   rule_name                  cn_rules.name%TYPE,
   object_name                cn_objects.name%TYPE,
   not_flag                   cn_attribute_rules.not_flag%TYPE,
   value_1                    cn_attribute_rules.column_value%TYPE,
   value_2                    cn_attribute_rules.high_value%TYPE,
   data_flag                  VARCHAR2(1),
   org_id                     cn_rules.org_id%TYPE
   );

-- Start of comments
--	API name 	: Create_RuleAttribute
--	Type		: Public
--	Function	: This Public API can be used to create a rule attribute
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version        IN NUMBER	 Required
--				p_init_msg_list	     IN VARCHAR2 Optional
--					Default = FND_API.G_FALSE
--				p_commit	     IN VARCHAR2 Optional
--					Default = FND_API.G_FALSE
--				p_validation_level   IN NUMBER	Optional
--					Default = FND_API.G_VALID_LEVEL_FULL
--                              p_RuleAttribute_rec IN
--					CN_RuleAttribute_PUB.RuleAttribute_rec_type
--
--	OUT		:	x_return_status	     OUT VARCHAR2(1)
--				x_msg_count	     OUT NUMBER
--				x_msg_data	     OUT VARCHAR2(2000)
--
--	Version	: Current version	1.0
--				25-Mar-99  Renu Chintalapati
--			  previous version	y.y
--				Changed....
--			  Initial version 	1.0
--				25-Mar-99   Renu Chintalapati
--
--	Notes		: Note text
--
-- End of comments

PROCEDURE Create_RuleAttribute
( p_api_version           	IN	NUMBER,
  p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
  p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
  p_validation_level		IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
  x_return_status	 OUT NOCOPY VARCHAR2,
  x_msg_count		 OUT NOCOPY NUMBER,
  x_msg_data		 OUT NOCOPY VARCHAR2,
  x_loading_status              OUT NOCOPY     VARCHAR2,
  p_RuleAttribute_rec       	IN     CN_RuleAttribute_PUB.RuleAttribute_rec_type
);

-- Start of comments
--	API name 	: Update_RuleAttribute
--	Type		: Public
--	Function	: This public API can be used to update a rule attribute
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version        IN NUMBER	 Required
--				p_init_msg_list	     IN VARCHAR2 Optional
--					Default = FND_API.G_FALSE
--				p_commit	     IN VARCHAR2 Optional
--					Default = FND_API.G_FALSE
--				p_validation_level   IN NUMBER	Optional
--					Default = FND_API.G_VALID_LEVEL_FULL
--                              p_RuleAttribute_rec IN
--					CN_RuleAttribute_PUB.RuleAttribute_rec_type
--
--	OUT		:	x_return_status	     OUT VARCHAR2(1)
--				x_msg_count	     OUT NUMBER
--				x_msg_data	     OUT VARCHAR2(2000)
--
--	Version	: Current version	1.0
--				25-Mar-99  Renu Chintalapati
--			  previous version	y.y
--				Changed....
--			  Initial version 	1.0
--				25-Mar-99   Renu Chintalapati
--
--	Notes		: Note text
--
-- End of comments


PROCEDURE Update_RuleAttribute
( p_api_version           	IN	NUMBER,
  p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
  p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
  p_validation_level		IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
  x_return_status	 OUT NOCOPY VARCHAR2,
  x_msg_count		 OUT NOCOPY NUMBER,
  x_msg_data		 OUT NOCOPY VARCHAR2,
  x_loading_status              OUT NOCOPY     VARCHAR2,
  p_old_RuleAttribute_rec   	IN      CN_RuleAttribute_PUB.RuleAttribute_rec_type,
  p_RuleAttribute_rec       	IN      CN_RuleAttribute_PUB.RuleAttribute_rec_type
);

-- Start of comments
--	API name 	: Delete_RuleAttribute
--	Type		: Public
--	Function	: This Public API can be used to delete a rule attribute
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version        IN NUMBER	 Required
--				p_init_msg_list	     IN VARCHAR2 Optional
--					Default = FND_API.G_FALSE
--				p_commit	     IN VARCHAR2 Optional
--					Default = FND_API.G_FALSE
--				p_validation_level   IN NUMBER	Optional
--					Default = FND_API.G_VALID_LEVEL_FULL
--                              p_attribute_rule_id IN
--					cn_attribute_rule.attribute_rule_id%type
--
--	OUT		:	x_return_status	     OUT VARCHAR2(1)
--				x_msg_count	     OUT NUMBER
--				x_msg_data	     OUT VARCHAR2(2000)
--
--	Version	: Current version	1.0
--				25-Mar-99  Renu Chintalapati
--			  previous version	y.y
--				Changed....
--			  Initial version 	1.0
--				25-Mar-99   Renu Chintalapati
--
--	Notes		: Note text
--
-- End of comments

PROCEDURE Delete_RuleAttribute
( p_api_version           	IN	NUMBER,
  p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
  p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
  p_validation_level		IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
  x_return_status	 OUT NOCOPY VARCHAR2,
  x_msg_count		 OUT NOCOPY NUMBER,
  x_msg_data		 OUT NOCOPY VARCHAR2,
  x_loading_status              OUT NOCOPY     VARCHAR2,
  p_ruleattribute_rec   	IN	CN_RuleAttribute_PUB.ruleattribute_rec_type);

END CN_RuleAttribute_PUB;
 

/
