--------------------------------------------------------
--  DDL for Package CN_RULE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_RULE_PUB" AUTHID CURRENT_USER AS
--$Header: cnprules.pls 120.2 2005/08/25 23:37:34 rramakri noship $
TYPE rule_rec_type IS RECORD
  (ruleset_name        cn_rulesets.name%TYPE,
   start_date          cn_rulesets.start_date%TYPE,
   end_date            cn_rulesets.end_date%TYPE,
   rule_name           cn_rules.name%TYPE,
   parent_rule_name    cn_rules.name%TYPE,
   revenue_class_name  cn_revenue_classes.name%TYPE,
   expense_ccid        cn_rules.expense_ccid%TYPE,
   liability_ccid      cn_rules.liability_ccid%TYPE,
   org_id              cn_rules.org_id%TYPE
   );

-- Start of comments
--	API name 	: Create_Rule
--	Type		: Private
--	Function	: This Private API can be used to create a rule
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version        IN NUMBER	 Required
--				p_init_msg_list	     IN VARCHAR2 Optional
--					Default = FND_API.G_FALSE
--				p_commit	     IN VARCHAR2 Optional
--					Default = FND_API.G_FALSE
--				p_validation_level   IN NUMBER	Optional
--					Default = FND_API.G_VALID_LEVEL_FULL
--				p_rule_rec_type      IN
--						  CN_Rule_PUB.rule_rec_type
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

PROCEDURE Create_Rule
( p_api_version           	IN	NUMBER,
  p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
  p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
  p_validation_level		IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
  x_return_status	 OUT NOCOPY VARCHAR2,
  x_msg_count		 OUT NOCOPY NUMBER,
  x_msg_data		 OUT NOCOPY VARCHAR2,
  x_loading_status              OUT NOCOPY     VARCHAR2,
  p_rule_rec			IN OUT NOCOPY  CN_Rule_PUB.rule_rec_type
);

-- Start of comments
--	API name 	: Update_Rule
--	Type		: Private
--	Function	: This Public API can be used to update a rule
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version        IN NUMBER	 Required
--				p_init_msg_list	     IN VARCHAR2 Optional
--					Default = FND_API.G_FALSE
--				p_commit	     IN VARCHAR2 Optional
--					Default = FND_API.G_FALSE
--				p_validation_level   IN NUMBER	Optional
--					Default = FND_API.G_VALID_LEVEL_FULL
--				p_rule_rec_type      IN
--						  CN_Rule_PUB.rule_rec_type
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


PROCEDURE Update_Rule
( p_api_version           	IN	NUMBER,
  p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
  p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
  p_validation_level		IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
  x_return_status	 OUT NOCOPY VARCHAR2,
  x_msg_count		 OUT NOCOPY NUMBER,
  x_msg_data		 OUT NOCOPY VARCHAR2,
  x_loading_status              OUT NOCOPY     VARCHAR2,
  p_old_rule_rec		IN OUT NOCOPY  CN_Rule_PUB.rule_rec_type,
  p_rule_rec		        IN OUT NOCOPY  CN_Rule_PUB.rule_rec_type
);

-- Start of comments
--	API name 	: Delete_Rule
--	Type		: Private
--	Function	: This Public API can be used to delete a rule and
--			  it's attributes from Oracle Sales Compensation.
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version        IN NUMBER	 Required
--				p_init_msg_list	     IN VARCHAR2 Optional
--					Default = FND_API.G_FALSE
--				p_commit	     IN VARCHAR2 Optional
--					Default = FND_API.G_FALSE
--				p_validation_level   IN NUMBER	Optional
--					Default = FND_API.G_VALID_LEVEL_FULL
--				p_rule_rec_type      IN
--						  CN_Rule_PUB.rule_rec_type
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

PROCEDURE Delete_Rule
  ( p_api_version           	IN	NUMBER,
    p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
    p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
    p_validation_level		IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
    x_return_status	 OUT NOCOPY VARCHAR2,
    x_msg_count		 OUT NOCOPY NUMBER,
    x_msg_data		 OUT NOCOPY VARCHAR2,
    x_loading_status            OUT NOCOPY     VARCHAR2,
    p_rule_name			IN	cn_rules.name%TYPE,
    p_ruleset_name              IN      cn_rulesets.name%TYPE,
    p_ruleset_start_date        IN      cn_rulesets.start_date%TYPE,
    p_ruleset_end_date          IN      cn_rulesets.end_date%TYPE
    ) ;

---------------------------+
--
-- This is called from RuleLOV.java to display the entire hierarchy for the given rule
--
---------------------------+
function getRuleHierStr
    (p_rule_id NUMBER,
     p_ruleset_id NUMBER)
   RETURN VARCHAR2;

END CN_Rule_PUB;
 

/
