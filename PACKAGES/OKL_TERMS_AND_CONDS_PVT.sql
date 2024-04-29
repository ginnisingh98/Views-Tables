--------------------------------------------------------
--  DDL for Package OKL_TERMS_AND_CONDS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_TERMS_AND_CONDS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRSZTS.pls 115.3 2003/03/14 00:34:27 ashariff noship $ */
  /* *************************************** */
TYPE trm_rec_type IS RECORD (
    id                          NUMBER:= 0,
    group_title                 VARCHAR2(240),
    description                 VARCHAR2(240),
    rule_group                  VARCHAR2(100),
    rule_sequence               VARCHAR2(240),
    title_style                 VARCHAR2(40),
    pagetitle                   VARCHAR2(40),
    region                      VARCHAR2(40),
    currency                    VARCHAR2(3),
    disabled                    VARCHAR2(3),
    jsp                         VARCHAR2(100)
    );


    TYPE trm_tbl_type IS TABLE OF trm_rec_type     INDEX BY BINARY_INTEGER;

PROCEDURE get_terms_conditions(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_type                         IN  VARCHAR2,
    x_trm_tbl                      OUT NOCOPY trm_tbl_type);

    /* *************************************** */
END OKL_TERMS_AND_CONDS_PVT;

 

/
