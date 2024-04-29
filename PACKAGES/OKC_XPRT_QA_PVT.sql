--------------------------------------------------------
--  DDL for Package OKC_XPRT_QA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_XPRT_QA_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCVXRULQAS.pls 120.0.12000000.2 2007/04/24 05:50:11 jkodiyan ship $ */

TYPE RuleIdList IS TABLE OF okc_xprt_rule_hdrs_all.rule_id%TYPE INDEX BY BINARY_INTEGER;

---------------------------------------------------
--  Procedure:
---------------------------------------------------
PROCEDURE qa_rules
(
 p_qa_mode		    IN  VARCHAR2,
 p_ruleid_tbl           IN  RuleIdList,
 x_sequence_id		    OUT NOCOPY NUMBER,
 x_qa_status	         OUT NOCOPY VARCHAR2,
 x_return_status        OUT NOCOPY VARCHAR2,
 x_msg_count            OUT NOCOPY NUMBER,
 x_msg_data             OUT NOCOPY VARCHAR2
);

PROCEDURE sync_rules
(
 p_sync_mode            IN  VARCHAR2,
 p_org_id               IN  NUMBER,
 p_ruleid_tbl           IN  RuleIdList,
 x_request_id  	    OUT NOCOPY NUMBER,
 x_return_status        OUT NOCOPY VARCHAR2,
 x_msg_count            OUT NOCOPY NUMBER,
 x_msg_data             OUT NOCOPY VARCHAR2
);

END OKC_XPRT_QA_PVT ;

 

/
