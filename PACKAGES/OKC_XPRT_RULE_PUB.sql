--------------------------------------------------------
--  DDL for Package OKC_XPRT_RULE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_XPRT_RULE_PUB" 
/* $Header: OKCPXIRS.pls 120.0.12010000.2 2011/03/10 18:07:12 harchand noship $ */
AUTHID CURRENT_USER AS


PROCEDURE create_rule(P_RULE_TBL IN OUT NOCOPY  okc_xprt_rule_pvt.RULE_TBL_TYPE
                     ,p_commit   IN VARCHAR2 := FND_API.G_FALSE );

PROCEDURE update_rule(P_RULE_TBL IN OUT NOCOPY okc_xprt_rule_pvt.RULE_TBL_TYPE
                      ,p_commit   IN VARCHAR2 := FND_API.G_FALSE );

PROCEDURE delete_rule_child_entities(P_RULE_CHILD_ENTITIES_TBL IN OUT NOCOPY okc_xprt_rule_pvt.rule_child_entities_tbl_type
                                     ,p_commit   IN VARCHAR2 := FND_API.G_FALSE);

END okc_xprt_rule_pub;

/
