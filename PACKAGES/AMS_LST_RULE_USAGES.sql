--------------------------------------------------------
--  DDL for Package AMS_LST_RULE_USAGES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_LST_RULE_USAGES" AUTHID CURRENT_USER AS
/* $Header: amsvlmps.pls 115.4 2002/11/22 08:55:44 jieli ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'ams_list_rule_usages';

PROCEDURE create_list_rule_usages(
   p_api_version           IN  NUMBER,
   p_init_msg_list         IN  VARCHAR2  := FND_API.g_false,
   p_commit                IN  VARCHAR2  := FND_API.g_false,
   p_validation_level      IN  NUMBER    := FND_API.g_valid_level_full,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2,
   p_list_header_id        in  NUMBER,
   p_list_rule_id          in  NUMBER,
   x_list_rule_usage_id    OUT NOCOPY number  );

END ams_lst_rule_usages ;

 

/
