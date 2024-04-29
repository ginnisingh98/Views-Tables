--------------------------------------------------------
--  DDL for Package PV_RULE_EVALUATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_RULE_EVALUATION_PUB" AUTHID CURRENT_USER as
/* $Header: pvxpprgs.pls 115.2 2003/12/13 00:19:59 pklin ship $*/

g_pkg_name                  CONSTANT VARCHAR2(30) := 'PV_RULE_EVALUATION_PUB';

PROCEDURE partner_evaluation_outcome(
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2  := FND_API.g_false,
   p_commit                     IN  VARCHAR2  := FND_API.g_false,
   p_validation_level           IN  NUMBER    := FND_API.g_valid_level_full,
   p_partner_id                 IN  NUMBER,
   p_rule_id_tbl                IN  JTF_NUMBER_TABLE,
   x_attr_id_tbl                OUT NOCOPY JTF_NUMBER_TABLE,
   x_attr_evaluation_result_tbl OUT NOCOPY JTF_VARCHAR2_TABLE_100,
   x_partner_attr_value_tbl     OUT NOCOPY JTF_VARCHAR2_TABLE_4000,
   x_evaluation_criteria_tbl    OUT NOCOPY JTF_VARCHAR2_TABLE_4000,
   x_rule_pass_flag             OUT NOCOPY VARCHAR2,
   x_delimiter			OUT NOCOPY VARCHAR2,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2
);


PROCEDURE quick_partner_eval_outcome(
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2  := FND_API.g_false,
   p_commit                     IN  VARCHAR2  := FND_API.g_false,
   p_validation_level           IN  NUMBER    := FND_API.g_valid_level_full,
   p_partner_id                 IN  NUMBER,
   p_rule_id_tbl                IN  JTF_NUMBER_TABLE,
   x_rule_pass_flag             OUT NOCOPY VARCHAR2,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2
);

END PV_RULE_EVALUATION_PUB;

 

/
