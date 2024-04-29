--------------------------------------------------------
--  DDL for Package CN_RULESET_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_RULESET_PUB" AUTHID CURRENT_USER AS
--$Header: cnprsets.pls 120.1 2005/08/25 23:38:16 rramakri noship $
TYPE ruleset_rec_type IS RECORD
  (ruleset_name        cn_rulesets.name%TYPE,
   module_type         cn_lookups.meaning%TYPE,
   end_date            cn_rulesets.end_date%TYPE,
   start_date          cn_rulesets.start_date%TYPE,
   org_id              cn_rulesets.org_id%TYPE
   );

-- NOTE : Due to a bug in FORMS 6.0.4, the record type cannot be initialized
--        with the defaults (fnd_api.g_miss_num etc. ) if this API is invoked
--        from forms. Hence this version does not initialize the variables

-- Start of comments
--	API name 	: Create_Ruleset
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
--						  CN_RuleSet_PUB.ruleset_rec_type
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
  p_ruleset_rec			IN      CN_RuleSet_PUB.ruleset_rec_type
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
--						  CN_RuleSet_PUB.ruleset_rec_type
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
  p_old_ruleset_rec		IN OUT NOCOPY  CN_RuleSet_PUB.ruleset_rec_type,
  p_ruleset_rec		        IN OUT NOCOPY  CN_RuleSet_PUB.ruleset_rec_type
);

END CN_RuleSet_PUB;
 

/
