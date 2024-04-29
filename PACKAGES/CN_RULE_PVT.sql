--------------------------------------------------------
--  DDL for Package CN_RULE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_RULE_PVT" AUTHID CURRENT_USER AS
--$Header: cnvrules.pls 120.3 2006/03/07 04:57:59 hanaraya ship $

 TYPE rule_rec_type IS RECORD
  (ruleset_id          cn_rulesets_all_b.ruleset_id%TYPE,
   rule_id             cn_rules_all_b.rule_id%TYPE,
   rule_name           VARCHAR2(80),
   parent_rule_id      cn_rules_all_b.rule_id%TYPE,
   revenue_class_id    cn_revenue_classes.revenue_class_id%TYPE,
   expense_ccid        cn_rules_all_b.expense_ccid%TYPE,
   liability_ccid      cn_rules_all_b.liability_ccid%TYPE,
   sequence_number     cn_rules_hierarchy.sequence_number%TYPE,
   org_id              cn_rules_all_b.org_id%TYPE,
   object_version_no   cn_rules_all_b.OBJECT_VERSION_NUMBER%TYPE
   );

 TYPE rule_out_rec_type IS RECORD
  (ruleset_id          cn_rulesets_all_b.ruleset_id%TYPE,
   ruleset_name        cn_rulesets_all_tl.name%TYPE,
   rule_id             cn_rules_all_b.rule_id%TYPE,
   rule_name           cn_rules_all_tl.name%TYPE,
   expense_desc        Varchar2(2000),
   liability_desc      Varchar2(2000),
   revenue_class_name  cn_revenue_classes.name%TYPE,
   parent_rule_id       cn_rules_all_b.rule_id%TYPE,
   revenue_class_id    cn_revenue_classes.revenue_class_id%TYPE,
   expense_ccid        cn_rules_all_b.expense_ccid%TYPE,
   liability_ccid      cn_rules_all_b.liability_ccid%TYPE,
   sequence_number     cn_rules_hierarchy.sequence_number%TYPE,
   org_id              cn_rules_all_b.org_id%TYPE,
   object_version_no   cn_rules_all_b.OBJECT_VERSION_NUMBER%TYPE
   );

TYPE rule_tbl_type IS TABLE OF rule_out_rec_type
  INDEX BY BINARY_INTEGER;

--=============================================================================
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
--						  CN_Rule_PVT.rule_rec_type
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
--=============================================================================
PROCEDURE Create_Rule
( p_api_version           	IN	NUMBER,
  p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
  p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
  p_validation_level		IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
  x_return_status	 OUT NOCOPY VARCHAR2,
  x_msg_count		 OUT NOCOPY NUMBER,
  x_msg_data		 OUT NOCOPY VARCHAR2,
  x_loading_status              OUT NOCOPY     VARCHAR2,
  p_rule_rec			IN OUT NOCOPY 	CN_Rule_PVT.rule_rec_type,
  x_rule_id		 OUT NOCOPY     NUMBER
);
--=============================================================================
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
--						  CN_Rule_PVT.rule_rec_type
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
--=============================================================================

PROCEDURE Update_Rule
( p_api_version           	IN	NUMBER,
  p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
  p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
  p_validation_level		IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
  x_return_status	 OUT NOCOPY VARCHAR2,
  x_msg_count		 OUT NOCOPY NUMBER,
  x_msg_data		 OUT NOCOPY VARCHAR2,
  x_loading_status              OUT NOCOPY     VARCHAR2,
  p_old_rule_rec		IN   CN_Rule_PVT.rule_rec_type,
  p_rule_rec		        IN OUT NOCOPY   CN_Rule_PVT.rule_rec_type
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
--						  CN_Rule_PVT.rule_rec_type
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
--=============================================================================
PROCEDURE Delete_Rule
( p_api_version           	IN	NUMBER,
  p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
  p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
  p_validation_level		IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
  x_return_status	 OUT NOCOPY VARCHAR2,
  x_msg_count		 OUT NOCOPY NUMBER,
  x_msg_data		 OUT NOCOPY VARCHAR2,
  x_loading_status              OUT NOCOPY     VARCHAR2,
  p_rule_id			IN	cn_rules_all_b.rule_id%TYPE,
  p_ruleset_id                  IN      cn_rules_all_b.ruleset_id%TYPE,
  p_org_id                      IN      cn_rules_all_b.org_id%TYPE
);

--============================================================================
-- Start of Comments
--
-- API name    : Get_Rules
-- Type        : Private.
-- Pre-reqs    : None.
-- Usage  : To get a Rules
-- Desc   : Procedure to get Rules
-- Parameters  :
-- IN          :  p_api_version       IN NUMBER      Require
--                p_init_msg_list     IN VARCHAR2    Optional
--                              Default = FND_API.G_FALSE
--                p_commit           IN VARCHAR2    Optional
--                              Default = FND_API.G_FALSE
--                p_validation_level  IN NUMBER      Optional
--                  Default = FND_API.G_VALID_LEVEL_FULL
-- OUT         :  x_return_status     OUT          VARCHAR2(1)
--                x_msg_count        OUT           NUMBER
--                x_msg_data         OUT           VARCHAR2(2000)
-- IN          :  p_ruleset_name, p_ruleset_name
-- OUT         :  x_loading_status    OUT
--                 Detailed Error Message
-- Version     : Current version   1.0
--          Initial version   1.0
--
-- End of comments
--============================================================================
    PROCEDURE  Get_rules
   ( p_api_version           IN   NUMBER,
     p_init_msg_list         IN   VARCHAR2,
     p_commit                IN   VARCHAR2,
     p_validation_level      IN   NUMBER,
     x_return_status         OUT NOCOPY  VARCHAR2,
     x_msg_count             OUT NOCOPY  NUMBER,
     x_msg_data              OUT NOCOPY  VARCHAR2,
     p_ruleset_name          IN   cn_rulesets_all_tl.name%TYPE,
     p_start_record          IN   NUMBER,
     p_increment_count       IN   NUMBER,
     p_order_by              IN   VARCHAR2,
     x_rule_tbl 	     OUT NOCOPY  rule_tbl_type,
     x_total_records         OUT NOCOPY  NUMBER,
     x_status                OUT NOCOPY  VARCHAR2,
     x_loading_status        OUT NOCOPY  VARCHAR2,
     p_org_id                IN   cn_rulesets_all_tl.org_id%TYPE
     );

    -- Function which returns the expression corresponding to a rule
  FUNCTION get_rule_exp (
    p_rule_id  NUMBER ) RETURN VARCHAR2;


END CN_Rule_PVT;

 

/
