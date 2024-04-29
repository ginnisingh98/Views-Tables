--------------------------------------------------------
--  DDL for Package OKS_KTO_INSREL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_KTO_INSREL_PUB" AUTHID CURRENT_USER AS
/* $Header: OKSPOIRS.pls 120.0 2005/05/25 17:37:06 appldev noship $ */



-------------------------------------------------------------------------------

-- Procedure:       create_instance_rel
-- Version:         1.0
-- Purpose:         Create instance relationships between subsciption item.
--                  instance and instance created by OM for the same item .
-- In Parameters:   p_contract_id   Contract for which to create order
--
-------------------------------------------------------------------------------

PROCEDURE create_instance_rel(ERRBUF              OUT NOCOPY VARCHAR2
			     ,RETCODE             OUT NOCOPY NUMBER
                              ,p_contract_id     IN  okc_k_headers_b.ID%TYPE
                             );


PROCEDURE create_instance_rel(p_api_version     IN  NUMBER   DEFAULT NULL
                             ,p_init_msg_list   IN  VARCHAR2 DEFAULT NULL
                             ,p_commit          IN  VARCHAR2 DEFAULT NULL
                             ,x_return_status   OUT NOCOPY VARCHAR2
                             ,x_msg_count       OUT NOCOPY NUMBER
                             ,x_msg_data        OUT NOCOPY VARCHAR2
                              ,p_contract_id     IN  okc_k_headers_b.ID%TYPE
                             );


END OKS_KTO_INSREL_PUB;

 

/
