--------------------------------------------------------
--  DDL for Package OKL_RGRP_RULES_PROCESS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_RGRP_RULES_PROCESS_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPRGRS.pls 115.11 2002/11/30 08:39:44 spillaip noship $ */
  subtype rgr_rec_type is OKL_RGRP_RULES_PROCESS_PVT.rgr_rec_type;
  subtype rgr_tbl_type is OKL_RGRP_RULES_PROCESS_PVT.rgr_tbl_type;
subtype rgr_out_rec_type is OKL_RGRP_RULES_PROCESS_PVT.rgr_out_rec_type;
  subtype rgr_out_tbl_type is OKL_RGRP_RULES_PROCESS_PVT.rgr_out_tbl_type;
  /* *************************************** */
  PROCEDURE process_rule_group_rules(
      p_api_version                  IN NUMBER,
      p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
      x_return_status                OUT NOCOPY VARCHAR2,
      x_msg_count                    OUT NOCOPY NUMBER,
      x_msg_data                     OUT NOCOPY VARCHAR2,
      p_chr_id              	     IN  NUMBER,
      p_line_id                      IN  NUMBER,
      p_cpl_id                       IN  NUMBER,
      p_rrd_id                       IN  NUMBER,
      p_rgr_tbl                      IN  rgr_tbl_type);
PROCEDURE process_template_rules(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_id          	           IN  NUMBER,
    p_rgr_tbl                      IN  rgr_tbl_type,
    x_rgr_tbl			   OUT NOCOPY rgr_out_tbl_type);
  FUNCTION get_header_rule_group_id(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_chr_id                       IN  NUMBER,
    p_rgd_code                     IN  VARCHAR2)
    RETURN OKC_RULE_GROUPS_B.ID%TYPE;
  /* *************************************** */
END OKL_RGRP_RULES_PROCESS_PUB;

 

/
