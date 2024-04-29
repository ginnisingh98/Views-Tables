--------------------------------------------------------
--  DDL for Package OKC_XPRT_TMPL_RULE_ASSNS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_XPRT_TMPL_RULE_ASSNS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCVXRULASSNS.pls 120.0 2005/05/26 09:51:54 appldev noship $ */

PROCEDURE copy_template_rule_assns
(
 p_api_version           IN NUMBER,
 p_init_msg_list	     IN VARCHAR2,
 p_commit	               IN VARCHAR2,
 p_source_template_id    IN NUMBER,
 p_target_template_id    IN NUMBER,
 x_return_status	     OUT NOCOPY VARCHAR2,
 x_msg_data	          OUT NOCOPY VARCHAR2,
 x_msg_count	          OUT NOCOPY NUMBER
);

PROCEDURE delete_template_rule_assns
(
 p_api_version           IN NUMBER,
 p_init_msg_list	     IN VARCHAR2,
 p_commit	               IN VARCHAR2,
 p_template_id           IN NUMBER,
 x_return_status	     OUT NOCOPY VARCHAR2,
 x_msg_data	          OUT NOCOPY VARCHAR2,
 x_msg_count	          OUT NOCOPY NUMBER
) ;

PROCEDURE merge_template_rule_assns
(
 p_api_version           IN NUMBER,
 p_init_msg_list	     IN VARCHAR2,
 p_commit	               IN VARCHAR2,
 p_template_id           IN NUMBER,
 p_parent_template_id    IN NUMBER,
 x_return_status	     OUT NOCOPY VARCHAR2,
 x_msg_data	          OUT NOCOPY VARCHAR2,
 x_msg_count	          OUT NOCOPY NUMBER
);




END OKC_XPRT_TMPL_RULE_ASSNS_PVT;

 

/
