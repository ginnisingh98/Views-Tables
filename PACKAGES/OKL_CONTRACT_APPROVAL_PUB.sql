--------------------------------------------------------
--  DDL for Package OKL_CONTRACT_APPROVAL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CONTRACT_APPROVAL_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPCAVS.pls 115.5 2002/03/21 18:03:30 pkm ship       $ */

PROCEDURE start_process(p_api_version IN NUMBER,
                          p_init_msg_list IN VARCHAR2,
                          x_return_status OUT NOCOPY VARCHAR2,
                          x_msg_count OUT NOCOPY NUMBER,
                          x_msg_data OUT NOCOPY VARCHAR2,
                          p_contract_id IN NUMBER,
                          p_status IN VARCHAR2,
                          p_do_commit IN VARCHAR2);
PROCEDURE stop_process(p_api_version IN NUMBER,
                       p_init_msg_list IN VARCHAR2,
                       x_return_status OUT NOCOPY VARCHAR2,
                       x_msg_count OUT NOCOPY NUMBER,
                       x_msg_data OUT NOCOPY VARCHAR2,
                       p_contract_id IN NUMBER,
                       p_do_commit IN VARCHAR2);
PROCEDURE populate_active_process(p_api_version IN NUMBER,
                          p_init_msg_list IN VARCHAR2,
                          x_return_status OUT NOCOPY VARCHAR2,
                          x_msg_count OUT NOCOPY NUMBER,
                          x_msg_data OUT NOCOPY VARCHAR2,
                          p_contract_number IN VARCHAR2,
                          p_contract_number_modifier IN VARCHAR2,
                          x_wf_name OUT NOCOPY VARCHAR2,
                          x_wf_process_name OUT NOCOPY VARCHAR2,
                          x_package_name OUT NOCOPY VARCHAR2,
                          x_procedure_name OUT NOCOPY VARCHAR2,
                          x_usage OUT NOCOPY VARCHAR2,
                          x_activeyn OUT NOCOPY VARCHAR2);
FUNCTION monitor_process(p_api_version IN NUMBER,
                          p_init_msg_list IN VARCHAR2,
                          x_return_status OUT NOCOPY VARCHAR2,
                          x_msg_count OUT NOCOPY NUMBER,
                          x_msg_data OUT NOCOPY VARCHAR2,
                          p_contract_id IN NUMBER,
                          p_pdf_id IN NUMBER) RETURN VARCHAR2;
END; -- Package Specification OKL_CONTRACT_APPROVAL_PUB

 

/
