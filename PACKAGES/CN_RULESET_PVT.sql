--------------------------------------------------------
--  DDL for Package CN_RULESET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_RULESET_PVT" AUTHID CURRENT_USER AS
--$Header: cnvrsets.pls 120.2 2005/10/10 01:05:09 rramakri noship $
TYPE ruleset_rec_type IS RECORD
  (ruleset_id            cn_rulesets_all_b.ruleset_id%TYPE,
   ruleset_name          cn_rulesets_all_tl.name%TYPE,
   module_type           cn_rulesets_all_b.module_type%TYPE,
   end_date              cn_rulesets_all_b.end_date%TYPE,
   start_date            cn_rulesets_all_b.start_date%TYPE,
   sync_flag             VARCHAR2(02),
   object_version_number NUMBER,
   status                cn_rulesets_all_b.ruleset_status%TYPE,
   org_id number
   );

-- NOTE : Due to a bug in FORMS 6.0.4, the record type cannot be initialized
--        with the defaults (fnd_api.g_miss_num etc. ) if this API is invoked
--        from forms. Hence this version does not initialize the variables

-- Start of comments
--	API name 	: Create_Rule
--	Type		: Private
--	Function	: This Private API can be used to create a ruleset.
--
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version        IN NUMBER	 Required
--				p_init_msg_list	     IN VARCHAR2 Optional
--					Default = FND_API.G_FALSE
--				p_commit	     IN VARCHAR2 Optional
--					Default = FND_API.G_FALSE
--				p_validation_level   IN NUMBER	Optional
--					Default = FND_API.G_VALID_LEVEL_FULL
--				p_ruleset_rec_type      IN
--						  CN_RuleSet_PVT.ruleset_rec_type
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

PROCEDURE create_ruleset
( p_api_version           	IN	NUMBER,
  p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
  p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
  p_validation_level		IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
  x_return_status	 OUT NOCOPY VARCHAR2,
  x_msg_count		 OUT NOCOPY NUMBER,
  x_msg_data		 OUT NOCOPY VARCHAR2,
  x_loading_status              OUT NOCOPY     VARCHAR2,
  x_ruleset_id		 OUT NOCOPY     NUMBER,
  p_ruleset_rec			IN      CN_RuleSet_PVT.ruleset_rec_type
);


-- Start of comments
--	API name 	: Update_Ruleset
--	Type		: Public
--	Function	: This Public API can be used to update a rule,
--			  a ruleset or rule attributes in Oracle Sales
--			  Compensation.
--	Pre-reqs	: None.
--	Parameters	:
--	IN		:	p_api_version        IN NUMBER	 Required
--				p_init_msg_list	     IN VARCHAR2 Optional
--					Default = FND_API.G_FALSE
--				p_commit	     IN VARCHAR2 Optional
--					Default = FND_API.G_FALSE
--				p_validation_level   IN NUMBER	Optional
--					Default = FND_API.G_VALID_LEVEL_FULL
--				p_ruleset_rec_type      IN
--						  CN_RuleSet_PVT.ruleset_rec_type
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


PROCEDURE Update_Ruleset
( p_api_version           	IN	NUMBER,
  p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
  p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
  p_validation_level		IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
  x_return_status	 OUT NOCOPY VARCHAR2,
  x_msg_count		 OUT NOCOPY NUMBER,
  x_msg_data		 OUT NOCOPY VARCHAR2,
  x_loading_status              OUT NOCOPY     VARCHAR2,
  p_old_ruleset_rec		IN OUT NOCOPY  CN_RuleSet_PVT.ruleset_rec_type,
  p_ruleset_rec		        IN OUT NOCOPY  CN_RuleSet_PVT.ruleset_rec_type
);

-- Start of comments
--	API name 	: Delete_Ruleset
--	Type		: Public
--	Function	: This Public API can be used to delete a rule or
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
--				p_ruleset_rec_type      IN
--						  CN_RuleSet_PVT.ruleset_rec_type
--                              p_rule_attr_rec_tbl_type IN
--					CN_RuleSet_PVT.rule_attr_rec_tbl_type
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
/*
PROCEDURE Delete_Ruleset
( p_api_version           	IN	NUMBER,
  p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
  p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
  p_validation_level		IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
  x_return_status	 OUT NOCOPY VARCHAR2,
  x_msg_count		 OUT NOCOPY NUMBER,
  x_msg_data		 OUT NOCOPY VARCHAR2,
  x_loading_status              OUT NOCOPY     VARCHAR2,
  p_ruleset_id    		IN	cn_rulesets.ruleset_id%TYPE
						:= CN_API.G_MISS_ID
);
*/

FUNCTION Check_Sync_Allowed (
    p_name  In VARCHAR2,
    p_ruleset_id  NUMBER,
    p_org_id Number,
    p_loading_status IN VARCHAR2,
    x_loading_status OUT NOCOPY VARCHAR2 )RETURN VARCHAR2 ;


END CN_RuleSet_PVT;

 

/
