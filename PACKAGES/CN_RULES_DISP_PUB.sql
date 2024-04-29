--------------------------------------------------------
--  DDL for Package CN_RULES_DISP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_RULES_DISP_PUB" AUTHID CURRENT_USER AS
-- $Header: cnpruls.pls 115.4 2003/05/26 12:10:57 pramadas ship $

      TYPE rls_dsp_rec_type IS RECORD
	( rule_name           VARCHAR2(80) ,
          rule_level          NUMBER(15),
          rule_revenue_class  VARCHAR2(80),
          rule_expression  VARCHAR2(2000)  );

      TYPE rls_dsp_tbl_type IS TABLE OF rls_dsp_rec_type
	INDEX BY BINARY_INTEGER;


  -- API name 	: Get_rules
  -- Type	: Public.
  -- Pre-reqs	:
  -- Usage	:
  --+
  -- Desc 	:
  --
  --
  --+
  -- Parameters	:
  --  OUT	:  x_rules_display_tbl   rls_dsp_tbl_type :Output table
  --  OUT	:  x_rules_count NUMBER : Size of the table
  --  IN        : p_ruleset_id   NUMBER : Currently not used
  --  IN        : p_parent_id   NUMBER  :  The rule_id of the parent
  --
  --+
  -- Version	: Current version	1.0
  --		  Initial version 	1.0
  --+
  -- Notes	:
  --+
  -- End of comments

  PROCEDURE get_rules
    (
     p_api_version           IN  NUMBER,
     p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
     p_validation_level      IN  VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,

     x_return_status         OUT NOCOPY VARCHAR2,
     x_msg_count             OUT NOCOPY NUMBER,
     x_msg_data              OUT NOCOPY VARCHAR2,
     x_loading_status         OUT NOCOPY VARCHAR2,

     p_ruleset_id            IN NUMBER ,
     p_parent_id             IN NUMBER ,
     p_date                  IN DATE,
     p_start_record          IN  NUMBER := 1,
     p_increment_count       IN  NUMBER,

     x_rules_display_tbl     OUT NOCOPY  rls_dsp_tbl_type,
     x_rules_count           OUT NOCOPY NUMBER
    );

END cn_rules_disp_pub ;


 

/
