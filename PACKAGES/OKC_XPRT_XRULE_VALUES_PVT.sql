--------------------------------------------------------
--  DDL for Package OKC_XPRT_XRULE_VALUES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_XPRT_XRULE_VALUES_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCVXXRULVS.pls 120.4 2007/02/20 04:03:31 arsundar ship $ */


TYPE var_value_rec_type IS RECORD (
  variable_code            VARCHAR2(30),
  variable_value_id        VARCHAR2(2500)
);

TYPE category_rec_type IS RECORD (
  category_name VARCHAR2(2000)
);

TYPE item_rec_type IS RECORD (
  name VARCHAR2(2000)
);

TYPE constant_rec_type IS RECORD (
  constant_id              VARCHAR2(30),
  value                    VARCHAR2(50)
);

TYPE sys_var_value_tbl_type IS TABLE OF var_value_rec_type INDEX BY BINARY_INTEGER;
TYPE category_tbl_type IS TABLE OF category_rec_type INDEX BY BINARY_INTEGER;
TYPE item_tbl_type IS TABLE OF item_rec_type INDEX BY BINARY_INTEGER;
TYPE constant_tbl_type IS TABLE OF constant_rec_type INDEX BY BINARY_INTEGER;

--Added for 12
TYPE line_sys_var_value_rec_type IS RECORD (
  line_NUMBER 	    VARCHAR2(250),
  variable_code     VARCHAR2(30),
  variable_value    VARCHAR2(2500),
  item_id           NUMBER,
  org_id            NUMBER
);

TYPE line_sys_var_value_tbl_type IS TABLE OF line_sys_var_value_rec_type INDEX BY BINARY_INTEGER;

TYPE udf_var_value_tbl_type IS TABLE OF var_value_rec_type INDEX BY BINARY_INTEGER;

TYPE var_value_tbl_type IS TABLE OF var_value_rec_type INDEX BY BINARY_INTEGER;

---------------------------------------------------
--  Procedure:
---------------------------------------------------

PROCEDURE get_system_variables (
    p_api_version        IN  NUMBER,
    p_init_msg_list      IN  VARCHAR2 :=  FND_API.G_FALSE,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_data           OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER,
    p_doc_type           IN  VARCHAR2,
    p_doc_id             IN  NUMBER,
    p_only_doc_variables IN  VARCHAR2 := FND_API.G_TRUE,
    x_sys_var_value_tbl  OUT NOCOPY var_value_tbl_type
);

PROCEDURE get_constant_values (
    p_api_version        IN  NUMBER,
    p_init_msg_list      IN  VARCHAR2 :=  FND_API.G_FALSE,
    p_intent             IN  VARCHAR2,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_data           OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER,
    x_constant_tbl       OUT NOCOPY constant_tbl_type
);

--Added for 12
PROCEDURE get_line_system_variables (
    p_api_version        		IN  NUMBER,
    p_init_msg_list      		IN  VARCHAR2 :=  FND_API.G_FALSE,
    p_doc_type           		IN  VARCHAR2,
    p_doc_id             		IN  NUMBER,
    p_org_id             		IN  NUMBER,
    x_return_status      		OUT NOCOPY VARCHAR2,
    x_msg_data           		OUT NOCOPY VARCHAR2,
    x_msg_count          		OUT NOCOPY NUMBER,
    x_line_sys_var_value_tbl            OUT NOCOPY line_sys_var_value_tbl_type,
    x_line_count         		OUT NOCOPY NUMBER,
    x_line_variables_count              OUT NOCOPY NUMBER
);

PROCEDURE get_user_defined_variables (
    p_api_version        IN  NUMBER,
    p_init_msg_list      IN  VARCHAR2 :=  FND_API.G_FALSE,
    p_doc_type           IN  VARCHAR2,
    p_doc_id             IN  NUMBER,
    p_org_id             IN  NUMBER,
    p_intent             IN  VARCHAR2,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_data           OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER,
    x_udf_var_value_tbl  OUT NOCOPY udf_var_value_tbl_type
);

PROCEDURE get_document_values (
    p_api_version        	  IN  NUMBER,
    p_init_msg_list      	  IN  VARCHAR2 :=  FND_API.G_FALSE,
    p_doc_type           	  IN  VARCHAR2,
    p_doc_id             	  IN  NUMBER,
    x_return_status      	  OUT NOCOPY VARCHAR2,
    x_msg_data           	  OUT NOCOPY VARCHAR2,
    x_msg_count          	  OUT NOCOPY NUMBER,
    x_hdr_var_value_tbl           OUT NOCOPY var_value_tbl_type,
    x_line_sysvar_value_tbl   	  OUT NOCOPY line_sys_var_value_tbl_type,
    x_line_count		  OUT NOCOPY NUMBER,
    x_line_variables_count        OUT NOCOPY NUMBER,
    x_intent			  OUT NOCOPY VARCHAR2,
    x_org_id		          OUT NOCOPY NUMBER
);

 FUNCTION check_line_level_rule_exists (
    p_doc_type           		IN  VARCHAR2,
    p_doc_id             		IN  NUMBER,
    p_org_id                            IN  NUMBER
) RETURN VARCHAR2;

-- Added for 12.0+

PROCEDURE get_udv_with_procedures (
    p_api_version        IN  NUMBER,
    p_init_msg_list      IN  VARCHAR2 :=  FND_API.G_FALSE,
    p_doc_type           IN  VARCHAR2,
    p_doc_id             IN  NUMBER,
    p_org_id             IN  NUMBER,
    p_intent             IN  VARCHAR2,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_data           OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER,
    x_udf_var_value_tbl  OUT NOCOPY udf_var_value_tbl_type
);

END OKC_XPRT_XRULE_VALUES_PVT;

/
