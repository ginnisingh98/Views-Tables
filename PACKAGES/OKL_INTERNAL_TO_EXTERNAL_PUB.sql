--------------------------------------------------------
--  DDL for Package OKL_INTERNAL_TO_EXTERNAL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_INTERNAL_TO_EXTERNAL_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPIEXS.pls 120.2 2006/05/19 21:20:16 fmiao noship $ */

 ------------------------------------------------------------------------------
 -- Global Variables
 G_PKG_NAME             CONSTANT VARCHAR2(200) := 'OKL_INTERNAL_TO_EXTERNAL_PUB';
 G_APP_NAME             CONSTANT VARCHAR2(3)   :=  Okc_Api.G_APP_NAME;
 G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
 G_SQLERRM_TOKEN        CONSTANT VARCHAR2(200) := 'SQLERRM';
 G_SQLCODE_TOKEN        CONSTANT VARCHAR2(200) := 'SQLCODE';
 ------------------------------------------------------------------------------
  --Global Exception
 ------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;
 ------------------------------------------------------------------------------

   PROCEDURE internal_to_external(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
		--fmiao 5209209
    p_contract_number  			   IN VARCHAR2 DEFAULT NULL,
    p_assigned_process 			   IN VARCHAR2 DEFAULT NULL
		--fmiao 5209209 end
   );
  PROCEDURE internal_to_external
  ( errbuf                         OUT NOCOPY VARCHAR2
  , retcode                        OUT NOCOPY NUMBER
		--fmiao 5209209
  , p_contract_number  			   IN VARCHAR2
  , p_assigned_process 			   IN VARCHAR2
		--fmiao 5209209 end
  );


END Okl_Internal_To_External_Pub;

/
