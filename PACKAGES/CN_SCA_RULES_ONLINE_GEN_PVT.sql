--------------------------------------------------------
--  DDL for Package CN_SCA_RULES_ONLINE_GEN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_SCA_RULES_ONLINE_GEN_PVT" AUTHID CURRENT_USER AS
-- $Header: cnvscags.pls 120.1 2005/09/07 17:59:02 rchenna noship $

G_PKG_NAME                  CONSTANT VARCHAR2(30) := 'CN_SCA_RULES_ONLINE_GEN_PVT';

PROCEDURE gen_sca_rules_onln_dyn
    ( p_api_version           IN  NUMBER,
      p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level      IN  VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
      p_org_id	              IN  NUMBER,
      x_return_status         OUT NOCOPY VARCHAR2,
      x_msg_count             OUT NOCOPY NUMBER,
      x_msg_data              OUT NOCOPY VARCHAR2,
      x_transaction_source    IN  cn_sca_rule_attributes.transaction_source%TYPE
      );


PROCEDURE get_winning_rule (         spec_code        IN OUT NOCOPY cn_utils.code_type,
                            body_code        IN OUT NOCOPY cn_utils.code_type ,
                            x_transaction_source   IN   cn_sca_rule_attributes.transaction_source%TYPE) ;

FUNCTION create_sca_rules_online_dyn
   (x_transaction_source   IN   cn_sca_rule_attributes.transaction_source%TYPE) RETURN BOOLEAN ;
END cn_sca_rules_online_gen_pvt;
 

/
