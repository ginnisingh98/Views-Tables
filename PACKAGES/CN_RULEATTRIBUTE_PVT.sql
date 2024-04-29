--------------------------------------------------------
--  DDL for Package CN_RULEATTRIBUTE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_RULEATTRIBUTE_PVT" AUTHID CURRENT_USER AS
--$Header: cnvratrs.pls 120.2 2005/07/04 05:24:30 appldev ship $

TYPE RuleAttribute_rec_type IS RECORD
   (ruleset_id              cn_attribute_rules.ruleset_id%TYPE,
    rule_id                 cn_attribute_rules.rule_id%TYPE,
    attribute_rule_id       cn_attribute_rules.attribute_rule_id%TYPE,
    org_id                  cn_attribute_rules.org_id%TYPE,
    object_name             cn_objects.name%TYPE,
    not_flag                cn_attribute_rules.not_flag%TYPE,
    value_1                 cn_attribute_rules.column_value%TYPE,
    value_2                 cn_attribute_rules.high_value%TYPE,
    data_flag               varchar2(1),
    object_version_number   cn_attribute_rules.object_version_number%TYPE);

-- Start of comments
--        API name        : Create_RuleAttribute
--        Type            : Private
--        Function        : This Public API can be used to create a rule attribute
--        Pre-reqs        : None.
--        Parameters      :
--        IN              :       p_api_version        IN NUMBER         Required
--                                p_init_msg_list             IN VARCHAR2 Optional
--                                        Default = FND_API.G_FALSE
--                                p_commit             IN VARCHAR2 Optional
--                                        Default = FND_API.G_FALSE
--                                p_validation_level   IN NUMBER        Optional
--                                        Default = FND_API.G_VALID_LEVEL_FULL
--                                p_RuleAttribute_rec IN
--                                        CN_RuleAttribute_PVT.RuleAttribute_rec_type
--
--        OUT                :        x_return_status             OUT VARCHAR2(1)
--                                x_msg_count             OUT NUMBER
--                                x_msg_data             OUT VARCHAR2(2000)
--
--        Version        : Current version        1.0
--                                25-Mar-99  Renu Chintalapati
--                          previous version        y.y
--                                Changed....
--                          Initial version         1.0
--                                25-Mar-99   Renu Chintalapati
--
--        Notes                : Note text
--
-- End of comments

PROCEDURE Create_RuleAttribute
( p_api_version            IN      NUMBER,
  p_init_msg_list          IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit                 IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level       IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status          OUT NOCOPY     VARCHAR2,
  x_msg_count              OUT NOCOPY     NUMBER,
  x_msg_data               OUT NOCOPY     VARCHAR2,
  x_loading_status         OUT NOCOPY     VARCHAR2,
  p_RuleAttribute_rec      IN OUT NOCOPY  CN_RuleAttribute_PVT.RuleAttribute_rec_type
);

-- Start of comments
--        API name         : Update_RuleAttribute
--        Type                : Private
--        Function        : This private API can be used to update a rule attribute
--        Pre-reqs        : None.
--        Parameters        :
--        IN                :        p_api_version        IN NUMBER         Required
--                                p_init_msg_list             IN VARCHAR2 Optional
--                                        Default = FND_API.G_FALSE
--                                p_commit             IN VARCHAR2 Optional
--                                        Default = FND_API.G_FALSE
--                                p_validation_level   IN NUMBER        Optional
--                                        Default = FND_API.G_VALID_LEVEL_FULL
--                              p_RuleAttribute_rec IN
--                                        CN_RuleAttribute_PVT.RuleAttribute_rec_type
--
--        OUT                :        x_return_status             OUT VARCHAR2(1)
--                                x_msg_count             OUT NUMBER
--                                x_msg_data             OUT VARCHAR2(2000)
--
--        Version        : Current version        1.0
--                                25-Mar-99  Renu Chintalapati
--                          previous version        y.y
--                                Changed....
--                          Initial version         1.0
--                                25-Mar-99   Renu Chintalapati
--
--        Notes                : Note text
--
-- End of comments

FUNCTION get_valuset_query (l_valueset_id NUMBER) RETURN VARCHAR2;

FUNCTION get_operator(l_attribute_rule_id NUMBER,l_org_id NUMBER) return varchar2;

FUNCTION get_rendered(l_attribute_rule_id NUMBER,l_org_id NUMBER) return number;



PROCEDURE Update_RuleAttribute
( p_api_version             IN     NUMBER,
  p_init_msg_list           IN     VARCHAR2 := FND_API.G_FALSE,
  p_commit                  IN     VARCHAR2 := FND_API.G_FALSE,
  p_validation_level        IN     NUMBER         := FND_API.G_VALID_LEVEL_FULL,
  x_return_status           OUT NOCOPY    VARCHAR2,
  x_msg_count               OUT NOCOPY    NUMBER,
  x_msg_data                OUT NOCOPY    VARCHAR2,
  x_loading_status          OUT NOCOPY    VARCHAR2,
  p_old_RuleAttribute_rec   IN OUT NOCOPY CN_RuleAttribute_PVT.RuleAttribute_rec_type,
  p_RuleAttribute_rec       IN OUT NOCOPY CN_RuleAttribute_PVT.RuleAttribute_rec_type
);

-- Start of comments
--        API name         : Delete_RuleAttribute
--        Type                : Private
--        Function        : This Private API can be used to delete a rule attribute
--        Pre-reqs        : None.
--        Parameters        :
--        IN                :        p_api_version        IN NUMBER         Required
--                                p_init_msg_list             IN VARCHAR2 Optional
--                                        Default = FND_API.G_FALSE
--                                p_commit             IN VARCHAR2 Optional
--                                        Default = FND_API.G_FALSE
--                                p_validation_level   IN NUMBER        Optional
--                                        Default = FND_API.G_VALID_LEVEL_FULL
--                              p_attribute_rule_id IN
--                                        cn_attribute_rule.attribute_rule_id%type
--
--        OUT                :        x_return_status             OUT VARCHAR2(1)
--                                x_msg_count             OUT NUMBER
--                                x_msg_data             OUT VARCHAR2(2000)
--
--        Version        : Current version        1.0
--                                25-Mar-99  Renu Chintalapati
--                          previous version        y.y
--                                Changed....
--                          Initial version         1.0
--                                25-Mar-99   Renu Chintalapati
--
--        Notes                : Note text
--
-- End of comments

PROCEDURE Delete_RuleAttribute
( p_api_version          IN  NUMBER,
  p_init_msg_list        IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit               IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level     IN  NUMBER         := FND_API.G_VALID_LEVEL_FULL,
  x_return_status        OUT NOCOPY VARCHAR2,
  x_msg_count            OUT NOCOPY NUMBER,
  x_msg_data             OUT NOCOPY VARCHAR2,
  x_loading_status       OUT NOCOPY VARCHAR2,
  p_ruleset_id           IN  cn_attribute_rules.ruleset_id%TYPE,
  p_rule_id              IN  cn_attribute_rules.rule_id%TYPE,
  p_attribute_rule_id    IN  cn_attribute_rules.attribute_rule_id%TYPE,
  p_object_version_number IN cn_attribute_rules.object_version_number%TYPE
);

PROCEDURE  Check_Attr_types
         (p_value_1           IN  VARCHAR2 := NULL,
          p_value_2           IN  VARCHAR2 := NULL,
          p_column_id         IN  NUMBER,
          p_rule_id           IN  NUMBER   := NULL,
          p_ruleset_id        IN  NUMBER   := NULL,
          p_org_id            IN  NUMBER,
          p_data_flag	      IN  VARCHAR2,
          p_loading_status    IN  VARCHAR2,
          x_loading_status    OUT NOCOPY VARCHAR2)  ;


 --=======================================================================
  -- Procedure Name:    Get_attr_valueset
  -- Purpose
 --=======================================================================
  PROCEDURE get_attr_valueset
                (p_column_id    IN  NUMBER,
                 p_column_name  IN  VARCHAR2,
		 p_org_id       IN NUMBER,
                 x_select       OUT NOCOPY VARCHAR2,
                 x_from         OUT NOCOPY VARCHAR2,
                 x_where        OUT NOCOPY VARCHAR2) ;


END CN_RuleAttribute_PVT;

 

/
