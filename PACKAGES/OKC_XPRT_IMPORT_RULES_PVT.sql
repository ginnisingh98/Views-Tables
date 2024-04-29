--------------------------------------------------------
--  DDL for Package OKC_XPRT_IMPORT_RULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_XPRT_IMPORT_RULES_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCVXRULS.pls 120.1 2005/07/01 08:45:07 arsundar noship $ */

PROCEDURE build_and_insert_rule
(
 p_rule_id                  IN VARCHAR2,
 p_template_id              IN NUMBER,
 p_run_id                   IN NUMBER,
 p_mode                     IN VARCHAR2,
 x_return_status            OUT NOCOPY VARCHAR2,
 x_msg_data                 OUT NOCOPY VARCHAR2,
 x_msg_count                OUT NOCOPY NUMBER
);

PROCEDURE build_statement_rule
(
 p_rule_id                  IN NUMBER,
 p_template_id              IN NUMBER,
 x_stmt_rule                OUT NOCOPY CLOB,
 x_return_status            OUT NOCOPY VARCHAR2,
 x_msg_data                 OUT NOCOPY VARCHAR2,
 x_msg_count                OUT NOCOPY NUMBER
) ;

PROCEDURE import_rules_publish
(
 x_run_id                  OUT NOCOPY NUMBER,
 x_return_status           OUT NOCOPY VARCHAR2,
 x_msg_data                OUT NOCOPY VARCHAR2,
 x_msg_count               OUT NOCOPY NUMBER
);

PROCEDURE import_rules_disable
(
 x_run_id                  OUT NOCOPY NUMBER,
 x_return_status           OUT NOCOPY VARCHAR2,
 x_msg_data                OUT NOCOPY VARCHAR2,
 x_msg_count               OUT NOCOPY NUMBER
);

PROCEDURE import_rule_temp_approval
(
 p_template_id             IN NUMBER,
 x_run_id                  OUT NOCOPY NUMBER,
 x_return_status           OUT NOCOPY VARCHAR2,
 x_msg_data                OUT NOCOPY VARCHAR2,
 x_msg_count               OUT NOCOPY NUMBER
);

-- Changed for R12
FUNCTION check_extension_rule
(
 p_intent       	IN	VARCHAR2,
 p_org_id	        IN      NUMBER
) RETURN VARCHAR2;

PROCEDURE attach_extension_rule
(
 p_api_version          IN	NUMBER,
 p_init_msg_list	    IN	VARCHAR2,
 p_run_id   	        IN	NUMBER,
 x_return_status	    OUT	NOCOPY VARCHAR2,
 x_msg_data	            OUT	NOCOPY VARCHAR2,
 x_msg_count	        OUT	NOCOPY NUMBER
) ;

PROCEDURE attach_extension_rule_tmpl
(
 p_api_version          IN	NUMBER,
 p_init_msg_list	    IN	VARCHAR2,
 p_run_id   	        IN	NUMBER,
 p_template_id       IN	NUMBER,
 x_return_status	    OUT	NOCOPY VARCHAR2,
 x_msg_data	            OUT	NOCOPY VARCHAR2,
 x_msg_count	        OUT	NOCOPY NUMBER
);


END OKC_XPRT_IMPORT_RULES_PVT;

 

/
