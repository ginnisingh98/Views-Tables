--------------------------------------------------------
--  DDL for Package OKC_XPRT_CZ_INT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_XPRT_CZ_INT_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCVXCZINTS.pls 120.0 2005/05/25 19:22:17 appldev noship $ */

---------------------------------------------------
-- GLOBAL VARIABLES
---------------------------------------------------
  G_RP_ROOT_FOLDER_ID             CONSTANT PLS_INTEGER :=  CZ_CONTRACTS_API_GRP.RP_ROOT_FOLDER;
  G_CAPTION_RULE_DESC             CONSTANT PLS_INTEGER :=  CZ_CONTRACTS_API_GRP.G_CAPTION_RULE_DESC;
  G_CAPTION_RULE_NAME             CONSTANT PLS_INTEGER :=  CZ_CONTRACTS_API_GRP.G_CAPTION_RULE_NAME;
  G_CZ_EPOCH_BEGIN                CONSTANT DATE := CZ_CONTRACTS_API_GRP.G_CZ_EPOCH_BEGIN;
  G_CZ_EPOCH_END                  CONSTANT DATE := CZ_CONTRACTS_API_GRP.G_CZ_EPOCH_END;

---------------------------------------------------
  G_XPRT_MAIN_FOLDER_ID           CONSTANT PLS_INTEGER :=  700;
  G_TEMPLATE_FOLDER_ID            CONSTANT PLS_INTEGER :=  701;
  G_CLAUSE_FOLDER_ID              CONSTANT PLS_INTEGER :=  702;
  G_VARIABLE_FOLDER_ID            CONSTANT PLS_INTEGER :=  703;

---------------------------------------------------
--  OKC Seeded Master UI template in CZ_UI_DEFS
---------------------------------------------------
  G_MASTER_UI_TMPLATE_ID          CONSTANT PLS_INTEGER :=  700;

---------------------------------------------------
--  CZ Return Statuses
---------------------------------------------------
  G_CZ_STATUS_SUCCESS             CONSTANT NUMBER :=CZ_CONTRACTS_API_GRP.G_STATUS_SUCCESS;
  G_CZ_STATUS_ERROR               CONSTANT NUMBER :=CZ_CONTRACTS_API_GRP.G_STATUS_ERROR;
  G_CZ_STATUS_WARNING             CONSTANT NUMBER :=CZ_CONTRACTS_API_GRP.G_STATUS_WARNING;

---------------------------------------------------
--  Procedure:
---------------------------------------------------
PROCEDURE import_generic
(
 p_api_version      IN  NUMBER,
 p_run_id           IN  NUMBER,
 p_rp_folder_id     IN  NUMBER,
 x_run_id           OUT NOCOPY NUMBER,
 x_return_status    OUT NOCOPY VARCHAR2,
 x_msg_data	    OUT	NOCOPY VARCHAR2,
 x_msg_count	    OUT	NOCOPY NUMBER
) ;

PROCEDURE create_rp_folder
(
 p_api_version      IN  NUMBER,
 p_encl_folder_id   IN NUMBER,
 p_new_folder_name  IN VARCHAR2,
 p_folder_desc      IN VARCHAR2,
 p_folder_notes     IN VARCHAR2,
 x_new_folder_id    OUT NOCOPY NUMBER,
 x_return_status    OUT NOCOPY VARCHAR2,
 x_msg_data	    OUT	NOCOPY VARCHAR2,
 x_msg_count	    OUT	NOCOPY NUMBER
) ;

PROCEDURE delete_ui_def
(
 p_api_version      IN  NUMBER,
 p_ui_def_id        IN  NUMBER,
 x_return_status    OUT NOCOPY VARCHAR2,
 x_msg_data	     OUT	NOCOPY VARCHAR2,
 x_msg_count	     OUT	NOCOPY NUMBER
) ;

PROCEDURE create_jrad_ui
(
 p_api_version        IN  NUMBER,
 p_devl_project_id    IN  NUMBER,
 p_show_all_nodes     IN  VARCHAR2,
 p_master_template_id IN  NUMBER,
 p_create_empty_ui    IN  VARCHAR2,
 x_ui_def_id          OUT NOCOPY NUMBER,
 x_return_status      OUT NOCOPY VARCHAR2,
 x_msg_data	       OUT NOCOPY VARCHAR2,
 x_msg_count	       OUT NOCOPY NUMBER
);

PROCEDURE generate_logic
(
 p_api_version      IN NUMBER,
 p_init_msg_lst     IN VARCHAR2,
 p_devl_project_id  IN NUMBER,
 x_run_id           OUT NOCOPY NUMBER,
 x_return_status    OUT NOCOPY VARCHAR2,
 x_msg_data	     OUT NOCOPY VARCHAR2,
 x_msg_count	     OUT NOCOPY NUMBER
) ;

PROCEDURE delete_publication
(
 p_api_version      IN NUMBER,
 p_init_msg_lst     IN VARCHAR2,
 p_publication_id   IN NUMBER,
 x_return_status    OUT NOCOPY VARCHAR2,
 x_msg_data	        OUT	NOCOPY VARCHAR2,
 x_msg_count	    OUT	NOCOPY NUMBER
) ;

PROCEDURE create_publication_request
(
 p_api_version      IN NUMBER,
 p_init_msg_lst     IN VARCHAR2,
 p_devl_project_id  IN NUMBER,
 p_ui_def_id        IN NUMBER,
 p_publication_mode IN VARCHAR2,
 x_publication_id   OUT NOCOPY NUMBER,
 x_return_status    OUT NOCOPY VARCHAR2,
 x_msg_data	     OUT	NOCOPY VARCHAR2,
 x_msg_count	     OUT	NOCOPY NUMBER
) ;

PROCEDURE copy_configuration
(
 p_api_version                  IN NUMBER,
 p_init_msg_list                IN VARCHAR2,
 p_config_header_id             IN NUMBER,
 p_config_rev_nbr               IN NUMBER,
 p_new_config_flag              IN VARCHAR2,
 x_new_config_header_id         OUT NOCOPY NUMBER,
 x_new_config_rev_nbr           OUT NOCOPY NUMBER,
 x_return_status                OUT NOCOPY VARCHAR2,
 x_msg_count                    OUT NOCOPY NUMBER,
 x_msg_data                     OUT NOCOPY VARCHAR2
);

PROCEDURE delete_configuration
(
 p_api_version                  IN NUMBER,
 p_init_msg_list                IN VARCHAR2 ,
 p_config_header_id             IN NUMBER,
 p_config_rev_nbr               IN NUMBER,
 x_return_status                OUT NOCOPY VARCHAR2,
 x_msg_count                    OUT NOCOPY NUMBER,
 x_msg_data                     OUT NOCOPY VARCHAR2
);

PROCEDURE batch_validate
(
 p_api_version                  IN NUMBER,
 p_init_msg_list                IN VARCHAR2,
 p_cz_xml_init_msg              IN VARCHAR2,
 x_cz_xml_terminate_msg         OUT NOCOPY LONG, -- CZ_CF_API.CFG_OUTPUT_PIECES,
 x_return_status                OUT NOCOPY VARCHAR2,
 x_msg_count                    OUT NOCOPY NUMBER,
 x_msg_data                     OUT NOCOPY VARCHAR2
);

PROCEDURE edit_publication
(
 p_api_version      IN NUMBER,
 p_init_msg_lst     IN VARCHAR2,
 p_publication_id   IN NUMBER,
 p_publication_mode IN VARCHAR2,
 x_return_status    OUT NOCOPY VARCHAR2,
 x_msg_data	    OUT	NOCOPY VARCHAR2,
 x_msg_count	    OUT	NOCOPY NUMBER
) ;

PROCEDURE publish_model
(
 p_api_version      IN NUMBER,
 p_init_msg_lst     IN VARCHAR2,
 p_publication_id   IN NUMBER,
 x_run_id           OUT NOCOPY NUMBER,
 x_return_status    OUT NOCOPY VARCHAR2,
 x_msg_data	    OUT	NOCOPY VARCHAR2,
 x_msg_count	    OUT	NOCOPY NUMBER
) ;

PROCEDURE publication_for_product
(
 p_api_version                  IN NUMBER,
 p_init_msg_lst                 IN VARCHAR2,
 p_product_key                  IN VARCHAR2,
 p_usage_name                   IN VARCHAR2,
 p_publication_mode             IN VARCHAR2,
 p_effective_date               IN DATE,
 x_publication_id               OUT NOCOPY NUMBER,
 x_return_status                OUT NOCOPY VARCHAR2,
 x_msg_count                    OUT NOCOPY NUMBER,
 x_msg_data                     OUT NOCOPY VARCHAR2
) ;

END OKC_XPRT_CZ_INT_PVT ;

 

/
