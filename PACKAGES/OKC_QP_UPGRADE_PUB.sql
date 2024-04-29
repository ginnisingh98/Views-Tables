--------------------------------------------------------
--  DDL for Package OKC_QP_UPGRADE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_QP_UPGRADE_PUB" AUTHID CURRENT_USER AS
/* $Header: OKCPQPUS.pls 120.0 2005/05/25 22:32:43 appldev noship $ */

PROCEDURE upgrade_contracts
(
 errbuf                   OUT NOCOPY  VARCHAR2,
 retcode                  OUT NOCOPY  VARCHAR2,
 p_dflt_price_list_id     IN   NUMBER,
 p_category_code          IN   okc_subclasses_b.code%TYPE DEFAULT NULL,
 p_enable_qp_profile      IN   VARCHAR2  DEFAULT 'N',
 p_rpt_upgrade_status     IN   VARCHAR2  DEFAULT 'N'
);

PROCEDURE ins_summary_rec;

PROCEDURE ins_category_rec
(
 p_category_code  IN   okc_subclasses_b.code%TYPE
);

PROCEDURE start_category_upgrade
(
 p_category_code          IN   okc_subclasses_b.code%TYPE
);

PROCEDURE ins_contract_rec
(
 p_category_code            IN   okc_subclasses_b.code%TYPE,
 p_chr_id                   IN   okc_k_headers_b.id%TYPE ,
 p_contract_number          IN   okc_k_headers_b.contract_number%TYPE,
 p_contract_number_modifier IN   okc_k_headers_b.contract_number_modifier%TYPE
);

PROCEDURE call_qp_upgrade
(
 p_category_code          IN   okc_subclasses_b.code%TYPE DEFAULT NULL
);

PROCEDURE upd_category_rec
(
 p_category_code  IN   okc_subclasses_b.code%TYPE,
 p_status         IN   varchar2  DEFAULT 'N'
);

PROCEDURE upd_summary_rec;

PROCEDURE process_report;

PROCEDURE upgrade_status_rpt;

FUNCTION check_qp_profile RETURN VARCHAR2;

FUNCTION compute_estimated_amt
(
 p_chr_id    IN okc_k_headers_b.id%TYPE
) RETURN NUMBER;

PROCEDURE create_manual_adjustment
(
 p_chr_id    IN okc_k_headers_b.id%TYPE
);

FUNCTION check_modifier RETURN VARCHAR2;


END OKC_QP_UPGRADE_PUB; -- Package Specification OKC_QP_UPGRADE_PUB

 

/
