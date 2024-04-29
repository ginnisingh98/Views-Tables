--------------------------------------------------------
--  DDL for Package Body OKC_XPRT_RULE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_XPRT_RULE_PUB" 
/* $Header: OKCPXIRB.pls 120.0.12010000.2 2011/03/10 18:06:38 harchand noship $ */
AS


PROCEDURE create_rule(P_RULE_TBL IN OUT NOCOPY  okc_xprt_rule_pvt.RULE_TBL_TYPE
                     ,p_commit   IN VARCHAR2 := FND_API.G_FALSE )
IS
BEGIN
      -- Call 2 Private API.
      okc_xprt_rule_pvt.create_rule( P_RULE_TBL => P_RULE_TBL
                                    ,p_commit   => p_commit
                                   );
EXCEPTION
 WHEN OTHERS THEN
   RAISE;
END create_rule;

PROCEDURE update_rule(P_RULE_TBL IN OUT NOCOPY okc_xprt_rule_pvt.RULE_TBL_TYPE
                      ,p_commit   IN VARCHAR2 := FND_API.G_FALSE )
IS
BEGIN
  -- Call 2 Private API.
     okc_xprt_rule_pvt.update_rule( P_RULE_TBL => P_RULE_TBL
                                    ,p_commit  => p_commit
                                  );

EXCEPTION
 WHEN OTHERS THEN
   RAISE;
END update_rule;

PROCEDURE delete_rule_child_entities(P_RULE_CHILD_ENTITIES_TBL IN OUT NOCOPY okc_xprt_rule_pvt.rule_child_entities_tbl_type
                                     ,p_commit   IN VARCHAR2 := FND_API.G_FALSE)
IS

BEGIN

     -- Call 2 Private API.
     okc_xprt_rule_pvt.delete_rule_child_entities( P_RULE_CHILD_ENTITIES_TBL => P_RULE_CHILD_ENTITIES_TBL
                                                  ,p_commit  => p_commit
                                                  );


EXCEPTION
 WHEN OTHERS THEN
   RAISE;
END delete_rule_child_entities;


END okc_xprt_rule_pub;

/
