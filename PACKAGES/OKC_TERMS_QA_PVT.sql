--------------------------------------------------------
--  DDL for Package OKC_TERMS_QA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_TERMS_QA_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCVDQAS.pls 120.3.12000000.1 2007/01/17 11:32:33 appldev ship $ */

SUBTYPE qa_result_tbl_type IS OKC_TERMS_QA_GRP.qa_result_tbl_type;

	G_NORMAL_QA             CONSTANT VARCHAR2(30) :=  OKC_TERMS_QA_GRP.G_NORMAL_QA;
	G_AMEND_QA              CONSTANT VARCHAR2(30) :=  OKC_TERMS_QA_GRP.G_AMEND_QA;

	/*
    11.5.10+ : Modified to accept addtional in parameter p_validation_level
    */
	PROCEDURE qa_doc     (
		p_qa_mode			IN  VARCHAR2 := G_NORMAL_QA,
		p_doc_type			IN  VARCHAR2,
		p_doc_id			IN  NUMBER,
		x_return_status		OUT NOCOPY VARCHAR2,
		x_msg_count			OUT NOCOPY NUMBER,
		x_msg_data			OUT NOCOPY VARCHAR2,
		x_sequence_id		OUT NOCOPY NUMBER,
		x_qa_result_tbl		OUT NOCOPY qa_result_tbl_type,
		x_qa_return_status	OUT NOCOPY VARCHAR2,
		p_validation_level	IN VARCHAR2 DEFAULT 'A',
		p_run_expert_flag   IN VARCHAR2 DEFAULT 'Y');   -- Bug 5186245

	PROCEDURE log_qa_messages (
		x_return_status    OUT NOCOPY VARCHAR2,
		p_qa_result_tbl    IN qa_result_tbl_type,
		x_sequence_id      OUT NOCOPY NUMBER);

	PROCEDURE get_qa_code_detail(
		p_qa_code			IN   VARCHAR2,
		x_perform_qa		OUT  NOCOPY VARCHAR2,
		x_qa_name			OUT  NOCOPY VARCHAR2,
		x_severity_flag		OUT  NOCOPY VARCHAR2,
		x_return_status		OUT  NOCOPY VARCHAR2);


    PROCEDURE check_lock_contract(
            p_qa_mode          IN  VARCHAR2,
		  p_doc_type         IN  VARCHAR2,
		  p_doc_id           IN  NUMBER,
            x_qa_result_tbl    IN OUT NOCOPY qa_result_tbl_type,
		  x_qa_return_status IN OUT NOCOPY VARCHAR2,
		  x_return_status    OUT NOCOPY  VARCHAR2);

    PROCEDURE check_contract_admin (
            p_qa_mode          IN  VARCHAR2,
		  p_doc_type         IN  VARCHAR2,
		  p_doc_id           IN  NUMBER,
            x_qa_result_tbl    IN OUT NOCOPY qa_result_tbl_type,
		  x_qa_return_status IN OUT NOCOPY VARCHAR2,
		  x_return_status    OUT NOCOPY  VARCHAR2);

END OKC_TERMS_QA_PVT;

 

/
