--------------------------------------------------------
--  DDL for Package Body OKL_COPY_CONTRACT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_COPY_CONTRACT_PUB" AS
/* $Header: OKLPCOPB.pls 120.3 2005/10/14 19:35:40 apaul noship $ */

  G_API_VERSION         CONSTANT NUMBER := 1;
  G_SCOPE				CONSTANT varchar2(4) := '_PUB';
  G_INIT_MSG_LIST       CONSTANT VARCHAR2(10) := OKL_API.G_FALSE;


 FUNCTION is_copy_allowed(p_chr_id IN NUMBER,p_sts_code IN VARCHAR2 DEFAULT NULL) RETURN BOOLEAN IS
 BEGIN
   RETURN(OKL_COPY_CONTRACT_PVT.is_copy_allowed(p_chr_id,p_sts_code));
 END is_copy_allowed;

 FUNCTION is_subcontract_allowed(p_chr_id IN NUMBER,p_sts_code IN VARCHAR2) RETURN BOOLEAN IS
 BEGIN
   RETURN(OKL_COPY_CONTRACT_PVT.is_subcontract_allowed(p_chr_id,p_sts_code));
 END is_subcontract_allowed;

 FUNCTION update_target_contract(p_chr_id IN NUMBER) RETURN BOOLEAN IS
 BEGIN
   RETURN(OKL_COPY_CONTRACT_PVT.update_target_contract(p_chr_id));
 END update_target_contract;

 PROCEDURE derive_line_style(p_old_lse_id     IN  NUMBER,
                              p_old_jtot_code  IN  VARCHAR2,
                              p_new_subclass   IN  VARCHAR2,
                              p_new_parent_lse IN  NUMBER,
                              x_new_lse_count  OUT NOCOPY NUMBER,
                              x_new_lse_ids    OUT NOCOPY VARCHAR2) IS
 BEGIN
  OKL_COPY_CONTRACT_PVT.derive_line_style(
               p_old_lse_id      => p_old_lse_id,
               p_old_jtot_code   => p_old_jtot_code,
               p_new_subclass    => p_new_subclass,
               p_new_parent_lse  => p_new_parent_lse,
               x_new_lse_count   => x_new_lse_count,
               x_new_lse_ids     => x_new_lse_ids);
 END derive_line_style;

 PROCEDURE copy_components(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_from_chr_id                  IN NUMBER,
    p_to_chr_id	          	       IN NUMBER,
    p_contract_number		       IN VARCHAR2,
    p_contract_number_modifier     IN VARCHAR2,
    p_to_template_yn			   IN VARCHAR2 DEFAULT 'N',
    p_copy_reference			   IN VARCHAR2 DEFAULT 'COPY',
    p_copy_line_party_yn           IN VARCHAR2,
    p_scs_code                     IN VARCHAR2,
    p_intent                       IN VARCHAR2,
    p_prospect                     IN VARCHAR2,
    p_components_tbl			   IN api_components_tbl,
    p_lines_tbl				       IN api_lines_tbl,
    x_chr_id                       OUT NOCOPY NUMBER) IS

    l_api_name     CONSTANT VARCHAR2(30) := 'OKL_COPY_COMPONENTS';
    l_return_status         VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(substr(l_api_name,1,26),
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              G_API_VERSION,
                                              p_api_version,
                                              G_SCOPE,
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Customer pre-processing Section
     --Vertical Industry pre-processing Section
     --Business Logic
     OKL_COPY_CONTRACT_PVT.copy_components(
	       p_api_version		        => p_api_version,
           p_init_msg_list		        => g_init_msg_list,
           x_return_status 		        => x_return_status,
           x_msg_count     		        => x_msg_count,
           x_msg_data      		        => x_msg_data,
           p_from_chr_id			    => p_from_chr_id,
           p_to_chr_id			        => p_to_chr_id,
           p_contract_number		    => p_contract_number,
           p_contract_number_modifier	=> p_contract_number_modifier,
		   p_to_template_yn             => p_to_template_yn,
		   p_copy_reference             => p_copy_reference,
           p_copy_line_party_yn         => p_copy_line_party_yn,
           p_scs_code                   => p_scs_code,
           p_intent                     => p_intent,
           p_prospect                   => p_prospect,
		   p_components_tbl             => p_components_tbl,
		   p_lines_tbl                  => p_lines_tbl,
           x_chr_id			            => x_chr_id);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Vertical post-processing Section

  --Customer post-processing Section

  OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
     WHEN OKL_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        --bug# 2518454
        --'OKC_API.G_RET_STS_ERROR',
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
	-- Resetting the global transaction id.
	okc_cvm_pvt.g_trans_id := 'XXX';
     WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        --bug# 2518454
        --'OKC_API.G_RET_STS_ERROR',
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
	-- Resetting the global transaction id.
	okc_cvm_pvt.g_trans_id := 'XXX';
     WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
	-- Resetting the global transaction id.
	okc_cvm_pvt.g_trans_id := 'XXX';

END copy_components;

PROCEDURE copy_contract(
            p_api_version                  	IN NUMBER,
    		p_init_msg_list                	IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    		x_return_status                	OUT NOCOPY  VARCHAR2,
    		x_msg_count                    	OUT NOCOPY  NUMBER,
    		x_msg_data                     	OUT NOCOPY  VARCHAR2,
    		p_commit             	       	IN VARCHAR2 DEFAULT 'F',
    		p_chr_id                       	IN NUMBER,
    		p_contract_number	        	IN VARCHAR2,
    		p_contract_number_modifier      IN VARCHAR2,
    		p_to_template_yn		        IN VARCHAR2 DEFAULT 'N',
    		p_renew_ref_yn                 	IN VARCHAR2,
    		p_override_org                 	IN VARCHAR2 DEFAULT 'N',
    		x_chr_id                       	OUT NOCOPY  NUMBER) IS

    l_api_name     CONSTANT VARCHAR2(30) := 'OKL_COPY_CONTRACT';
    l_return_status         VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(substr(l_api_name,1,26),
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              G_API_VERSION,
                                              p_api_version,
                                              G_SCOPE,
                                              x_return_status);
    --dbms_output.put_line('In Public :'||l_api_name||G_SCOPE);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Customer pre-processing Section

    --Vertical pre-processing Section
    --Business Logic
    OKL_COPY_CONTRACT_PVT.copy_contract(
	  	   p_api_version					=> p_api_version,
           p_init_msg_list				=> g_init_msg_list,
           x_return_status 				=> x_return_status,
           x_msg_count     				=> x_msg_count,
           x_msg_data      				=> x_msg_data,
           p_commit						=> p_commit,
           p_chr_id						=> p_chr_id,
           p_contract_number		    => p_contract_number,
           p_contract_number_modifier	=> p_contract_number_modifier,
		   p_to_template_yn             => p_to_template_yn,
           p_renew_ref_yn               => p_renew_ref_yn,
           p_copy_lines_yn              => 'Y',
           x_chr_id			            => x_chr_id);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;



    IF p_commit = OKL_API.G_TRUE THEN
      commit;
    END IF;

    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
     WHEN OKL_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        --bug# 2518454
        --'OKC_API.G_RET_STS_ERROR',
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
     WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
     WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        G_SCOPE);

  END copy_contract;



 PROCEDURE copy_lease_contract(
            p_api_version              IN  NUMBER,
            p_init_msg_list            IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status            OUT NOCOPY VARCHAR2,
            x_msg_count                OUT NOCOPY NUMBER,
            x_msg_data                 OUT NOCOPY VARCHAR2,
            p_commit                   IN  VARCHAR2 DEFAULT 'F',
            p_chr_id                   IN  NUMBER,
            p_contract_number	       IN  VARCHAR2,
            p_contract_number_modifier IN  VARCHAR2,
            p_to_template_yn	       IN  VARCHAR2 DEFAULT 'N',
            p_renew_ref_yn             IN  VARCHAR2,
            p_override_org	       IN  VARCHAR2 DEFAULT 'N',
            p_trans_type               IN  VARCHAR2,
            x_chr_id                   OUT NOCOPY NUMBER) IS

    l_api_name     CONSTANT VARCHAR2(30) := 'OKL_COPY_LEASE_CONTRACT';
    l_return_status         VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(substr(l_api_name,1,26),
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              G_API_VERSION,
                                              p_api_version,
                                              G_SCOPE,
                                              x_return_status);
    --dbms_output.put_line('In Public :'||l_api_name||G_SCOPE);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Customer pre-processing Section

    --Vertical pre-processing Section
    --Business Logic
    OKL_COPY_CONTRACT_PVT.copy_lease_contract(
                               p_api_version		       => p_api_version,
                               p_init_msg_list		       => g_init_msg_list,
                               x_return_status 		       => x_return_status,
                               x_msg_count     		       => x_msg_count,
                               x_msg_data      		       => x_msg_data,
                               p_commit			           => p_commit,
                               p_chr_id			           => p_chr_id,
                               p_contract_number	       => p_contract_number,
                               p_contract_number_modifier  => p_contract_number_modifier,
                               p_to_template_yn            => p_to_template_yn,
                               p_renew_ref_yn              => p_renew_ref_yn,
                               p_copy_lines_yn             => 'Y',
                               p_override_org	           => p_override_org,
                               p_trans_type                => p_trans_type,
                               x_chr_id			           => x_chr_id);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;



    IF p_commit = OKL_API.G_TRUE THEN
      commit;
    END IF;

    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
     WHEN OKL_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        --bug# 2518454
        --'OKC_API.G_RET_STS_ERROR',
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
     WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
     WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        G_SCOPE);

  END copy_lease_contract;

 PROCEDURE copy_lease_contract(
            p_api_version              IN  NUMBER,
            p_init_msg_list            IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status            OUT NOCOPY VARCHAR2,
            x_msg_count                OUT NOCOPY NUMBER,
            x_msg_data                 OUT NOCOPY VARCHAR2,
            p_commit                   IN  VARCHAR2 DEFAULT 'F',
            p_chr_id                   IN  NUMBER,
            p_contract_number	       IN  VARCHAR2,
            p_contract_number_modifier IN  VARCHAR2,
            p_to_template_yn	       IN  VARCHAR2 DEFAULT 'N',
            p_renew_ref_yn             IN  VARCHAR2,
            p_copy_lines_yn            IN  VARCHAR2,
            p_override_org	           IN  VARCHAR2 DEFAULT 'N',
            p_trans_type               IN  VARCHAR2,
            x_chr_id                   OUT NOCOPY NUMBER) IS

    l_api_name     CONSTANT VARCHAR2(30) := 'OKL_COPY_LEASE_CONTRACT';
    l_return_status         VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(substr(l_api_name,1,26),
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              G_API_VERSION,
                                              p_api_version,
                                              G_SCOPE,
                                              x_return_status);
    --dbms_output.put_line('In Public :'||l_api_name||G_SCOPE);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Customer pre-processing Section

    --Vertical pre-processing Section
    --Business Logic
    OKL_COPY_CONTRACT_PVT.copy_lease_contract(
                               p_api_version		       => p_api_version,
                               p_init_msg_list		       => g_init_msg_list,
                               x_return_status 		       => x_return_status,
                               x_msg_count     		       => x_msg_count,
                               x_msg_data      		       => x_msg_data,
                               p_commit			           => p_commit,
                               p_chr_id			           => p_chr_id,
                               p_contract_number	       => p_contract_number,
                               p_contract_number_modifier  => p_contract_number_modifier,
                               p_to_template_yn            => p_to_template_yn,
                               p_renew_ref_yn              => p_renew_ref_yn,
                               p_copy_lines_yn             => p_copy_lines_yn,
                               p_override_org	           => p_override_org,
                               p_trans_type                => p_trans_type,
                               x_chr_id			           => x_chr_id);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;



    IF p_commit = OKL_API.G_TRUE THEN
      commit;
    END IF;

    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
     WHEN OKL_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        --bug# 2518454
        --'OKC_API.G_RET_STS_ERROR',
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
     WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
     WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        G_SCOPE);

  END copy_lease_contract;


 PROCEDURE copy_lease_contract_new(
            p_api_version              IN  NUMBER,
            p_init_msg_list            IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status            OUT NOCOPY VARCHAR2,
            x_msg_count                OUT NOCOPY NUMBER,
            x_msg_data                 OUT NOCOPY VARCHAR2,
            p_commit                   IN  VARCHAR2 DEFAULT 'F',
            p_chr_id                   IN  NUMBER,
            p_contract_number	       IN  VARCHAR2,
            p_contract_number_modifier IN  VARCHAR2,
            p_to_template_yn	       IN  VARCHAR2 DEFAULT 'N',
            p_renew_ref_yn             IN  VARCHAR2,
            p_override_org	       IN  VARCHAR2 DEFAULT 'N',
            p_trans_type               IN  VARCHAR2,
            x_chr_id                   OUT NOCOPY NUMBER,
            p_rbk_date                 IN  DATE DEFAULT NULL) IS

    l_api_name     CONSTANT VARCHAR2(30) := 'OKL_COPY_LEASE_CONTRACT';
    l_return_status         VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(substr(l_api_name,1,26),
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              G_API_VERSION,
                                              p_api_version,
                                              G_SCOPE,
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Customer pre-processing Section

    --Vertical pre-processing Section
    --Business Logic
    OKL_COPY_CONTRACT_PVT.copy_lease_contract_new(
                               p_api_version		       => p_api_version,
                               p_init_msg_list		       => g_init_msg_list,
                               x_return_status 		       => x_return_status,
                               x_msg_count     		       => x_msg_count,
                               x_msg_data      		       => x_msg_data,
                               p_commit			           => p_commit,
                               p_chr_id			           => p_chr_id,
                               p_contract_number	       => p_contract_number,
                               p_contract_number_modifier  => p_contract_number_modifier,
                               p_to_template_yn            => p_to_template_yn,
                               p_renew_ref_yn              => p_renew_ref_yn,
                               p_copy_lines_yn             => 'Y',
                               p_override_org	           => p_override_org,
                               p_trans_type                => p_trans_type,
                               x_chr_id			           => x_chr_id,
                               p_rbk_date                  => p_rbk_date);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;



    IF p_commit = OKL_API.G_TRUE THEN
      commit;
    END IF;

    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
     WHEN OKL_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        --bug# 2518454
        --'OKC_API.G_RET_STS_ERROR',
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
     WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
     WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        G_SCOPE);

  END copy_lease_contract_new;

 PROCEDURE copy_lease_contract_new(
            p_api_version              IN  NUMBER,
            p_init_msg_list            IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status            OUT NOCOPY VARCHAR2,
            x_msg_count                OUT NOCOPY NUMBER,
            x_msg_data                 OUT NOCOPY VARCHAR2,
            p_commit                   IN  VARCHAR2 DEFAULT 'F',
            p_chr_id                   IN  NUMBER,
            p_contract_number	       IN  VARCHAR2,
            p_contract_number_modifier IN  VARCHAR2,
            p_to_template_yn	       IN  VARCHAR2 DEFAULT 'N',
            p_renew_ref_yn             IN  VARCHAR2,
            p_copy_lines_yn            IN  VARCHAR2,
            p_override_org	           IN  VARCHAR2 DEFAULT 'N',
            p_trans_type               IN  VARCHAR2,
            x_chr_id                   OUT NOCOPY NUMBER) IS

    l_api_name     CONSTANT VARCHAR2(30) := 'OKL_COPY_LEASE_CONTRACT';
    l_return_status         VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(substr(l_api_name,1,26),
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              G_API_VERSION,
                                              p_api_version,
                                              G_SCOPE,
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Customer pre-processing Section

    --Vertical pre-processing Section
    --Business Logic
    OKL_COPY_CONTRACT_PVT.copy_lease_contract_new(
                               p_api_version		       => p_api_version,
                               p_init_msg_list		       => g_init_msg_list,
                               x_return_status 		       => x_return_status,
                               x_msg_count     		       => x_msg_count,
                               x_msg_data      		       => x_msg_data,
                               p_commit			           => p_commit,
                               p_chr_id			           => p_chr_id,
                               p_contract_number	       => p_contract_number,
                               p_contract_number_modifier  => p_contract_number_modifier,
                               p_to_template_yn            => p_to_template_yn,
                               p_renew_ref_yn              => p_renew_ref_yn,
                               p_copy_lines_yn             => p_copy_lines_yn,
                               p_override_org	           => p_override_org,
                               p_trans_type                => p_trans_type,
                               x_chr_id			           => x_chr_id);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;



    IF p_commit = OKL_API.G_TRUE THEN
      commit;
    END IF;

    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
     WHEN OKL_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        --bug# 2518454
        --'OKC_API.G_RET_STS_ERROR',
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
     WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
     WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        G_SCOPE);

  END copy_lease_contract_new;

  PROCEDURE copy_contract(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_commit        			   IN VARCHAR2 DEFAULT 'F',
    p_chr_id                       IN NUMBER,
    p_contract_number		   IN VARCHAR2,
    p_contract_number_modifier     IN VARCHAR2,
    p_to_template_yn			   IN VARCHAR2 DEFAULT 'N',
    p_renew_ref_yn                 IN VARCHAR2,
    p_copy_lines_yn                IN VARCHAR2,
    p_override_org		           IN VARCHAR2 DEFAULT 'N',
    x_chr_id                       OUT NOCOPY NUMBER) IS

    l_api_name     CONSTANT VARCHAR2(30) := 'OKL_COPY_CONTRACT';
    l_return_status         VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(substr(l_api_name,1,26),
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              G_API_VERSION,
                                              p_api_version,
                                              G_SCOPE,
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Customer pre-processing Section
    --Vertical pre_processing section

    --Business Logic
    OKL_COPY_CONTRACT_PVT.copy_contract(
	   	   p_api_version				=> p_api_version,
           p_init_msg_list				=> g_init_msg_list,
           x_return_status 				=> x_return_status,
           x_msg_count     				=> x_msg_count,
           x_msg_data      				=> x_msg_data,
           p_commit						=> p_commit,
           p_chr_id						=> p_chr_id,
           p_contract_number			=> p_contract_number,
           p_contract_number_modifier	=> p_contract_number_modifier,
		   p_to_template_yn        		=> p_to_template_yn,
           p_renew_ref_yn          		=> p_renew_ref_yn,
           p_copy_lines_yn      		=> p_copy_lines_yn,
           x_chr_id						=> x_chr_id);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Vertical post_processing section

     --User post_processing section

    IF p_commit = 'T' THEN
      commit;
    END IF;

    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
     WHEN OKL_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        --bug# 2518454
        --'OKC_API.G_RET_STS_ERROR',
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
     WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
     WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        G_SCOPE);

  END copy_contract;

  PROCEDURE copy_contract_lines(
    	p_api_version                  IN NUMBER,
    	p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    	x_return_status                OUT NOCOPY VARCHAR2,
    	x_msg_count                    OUT NOCOPY NUMBER,
    	x_msg_data                     OUT NOCOPY VARCHAR2,
    	p_from_cle_id                  IN NUMBER,
    	p_to_cle_id                    IN NUMBER,
    	p_to_chr_id                    IN NUMBER,
    	p_to_template_yn	           IN VARCHAR2,
    	p_copy_reference	           IN VARCHAR2,
    	p_copy_line_party_yn           IN VARCHAR2,
    	p_renew_ref_yn                 IN VARCHAR2,
    	x_cle_id		               OUT NOCOPY NUMBER) is

     l_api_name     CONSTANT VARCHAR2(30) := 'OKL_COPY_CONTRACT_LINES';
    l_return_status         VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
  l_return_status := OKL_API.START_ACTIVITY(substr(l_api_name,1,26),
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              G_API_VERSION,
                                              p_api_version,
                                              G_SCOPE,
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Custom pre_processing section

    --Vertical Industry pre_processing section

    OKL_COPY_CONTRACT_PVT.copy_contract_lines(
	   p_api_version		 => p_api_version,
       p_init_msg_list	     => p_init_msg_list,
       x_return_status 	     => x_return_status,
       x_msg_count     	     => x_msg_count,
       x_msg_data      	     => x_msg_data,
       p_from_cle_id		 => p_from_cle_id,
	   p_to_cle_id 		     => p_to_cle_id,
	   p_to_chr_id 		     => p_to_chr_id,
	   p_to_template_yn      => p_to_template_yn,
       p_copy_reference      => p_copy_reference,
       p_copy_line_party_yn  => p_copy_line_party_yn,
       p_renew_ref_yn        => p_renew_ref_yn,
       x_cle_id			 => x_cle_id);

       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
       --Vertical Industry post_processing section
     --Custom post_processing section

    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
     WHEN OKL_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
     WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
     WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
  END copy_contract_lines;

  PROCEDURE copy_rules(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgp_id                  	   IN NUMBER,
    p_cle_id                       IN NUMBER DEFAULT OKL_API.G_MISS_NUM,
    p_chr_id                       IN NUMBER DEFAULT OKL_API.G_MISS_NUM,
    p_to_template_yn			   IN VARCHAR2,
    x_rgp_id		           OUT NOCOPY NUMBER) IS

    l_api_name     CONSTANT VARCHAR2(30) := 'OKL_COPY_RULES';
    l_return_status         VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(substr(l_api_name,1,26),
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              G_API_VERSION,
                                              p_api_version,
                                              G_SCOPE,
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

     --Custom pre_processing section

     --Vertical Industry pre_processing section

    OKL_COPY_CONTRACT_PVT.copy_rules(
           p_api_version		=> p_api_version,
           p_init_msg_list		=> g_init_msg_list,
           x_return_status 	    => x_return_status,
           x_msg_count     	    => x_msg_count,
           x_msg_data      	    => x_msg_data,
           p_rgp_id			    => p_rgp_id,
           p_cle_id			    => p_cle_id,
           p_chr_id			    => p_chr_id,
           p_to_template_yn     => p_to_template_yn,
           x_rgp_id			    => x_rgp_id);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

     --Vertical Industry post_processing section

     --Custom post_processing section

    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
     WHEN OKL_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
     WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
     WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        G_SCOPE);

  END copy_rules;

  PROCEDURE copy_party_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cpl_id                  	   IN NUMBER,
    p_cle_id                       IN NUMBER DEFAULT OKL_API.G_MISS_NUM,
    p_chr_id                       IN NUMBER DEFAULT OKL_API.G_MISS_NUM,
    P_rle_code                     IN VARCHAR2,
    x_cpl_id		           	   OUT NOCOPY NUMBER) IS

    l_api_name     				CONSTANT VARCHAR2(30) := 'OKL_COPY_PARTY_ROLES';
    l_return_status         		VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(substr(l_api_name,1,26),
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              G_API_VERSION,
                                              p_api_version,
                                              G_SCOPE,
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

     --Custom pre processing section

     --Vertical Industry pre processing section

    OKL_COPY_CONTRACT_PVT.copy_party_roles(
    		p_api_version           => p_api_version,
    		p_init_msg_list         => g_init_msg_list,
    		x_return_status         => x_return_status,
    		x_msg_count             => x_msg_count,
    		x_msg_data              => x_msg_data,
    		p_cpl_id                => p_cpl_id,
    		p_cle_id                => p_cle_id,
    		p_chr_id                => p_chr_id,
    		p_rle_code              => p_rle_code,
    		x_cpl_id		         => x_cpl_id);


    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

     --Vertical Industry post processing section

    --Custom post processing section

    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
     WHEN OKL_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
     WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
     WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        G_SCOPE);

  END copy_party_roles;

  PROCEDURE copy_articles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cat_id                  	   IN NUMBER,
    p_cle_id                       IN NUMBER DEFAULT OKL_API.G_MISS_NUM,
    p_chr_id                       IN NUMBER DEFAULT OKL_API.G_MISS_NUM,
    p_sav_sav_release		       IN VARCHAR2 DEFAULT NULL,
    x_cat_id		           	   OUT NOCOPY NUMBER) IS


    l_api_name     			CONSTANT VARCHAR2(30) := 'OKL_COPY_ARTICLES';
    l_return_status           VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(substr(l_api_name,1,26),
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              G_API_VERSION,
                                              p_api_version,
                                              G_SCOPE,
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Custom pre processing section

    --Vertical pre processing section

    OKL_COPY_CONTRACT_PVT.copy_articles(
          p_api_version		  => p_api_version,
          p_init_msg_list	  => g_init_msg_list,
          x_return_status 	  => x_return_status,
          x_msg_count     	  => x_msg_count,
          x_msg_data      	  => x_msg_data,
          p_cat_id            => p_cat_id,
          p_cle_id            => p_cle_id,
          p_chr_id            => p_chr_id,
          p_sav_sav_release   => p_sav_sav_release,
          x_cat_id			  => x_cat_id);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Vertical post processing section

     --Custom post processing section

    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
     WHEN OKL_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
     WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
     WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        G_SCOPE);

  END copy_articles;

  PROCEDURE copy_latest_articles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cat_id                  	   IN NUMBER,
    p_cle_id                       IN NUMBER DEFAULT OKL_API.G_MISS_NUM,
    p_chr_id                       IN NUMBER DEFAULT OKL_API.G_MISS_NUM,
    x_cat_id		           	   OUT NOCOPY NUMBER) IS


    l_api_name     		   CONSTANT VARCHAR2(30) := 'OKL_COPY_LATEST_ARTICLES';
    l_return_status         VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(substr(l_api_name,1,26),
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              G_API_VERSION,
                                              p_api_version,
                                              G_SCOPE,
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Custom pre processing section

    --Vertical Industry pre processing section

    OKL_COPY_CONTRACT_PVT.copy_latest_articles(
          p_api_version		=> p_api_version,
          p_init_msg_list	=> g_init_msg_list,
          x_return_status 	=> x_return_status,
          x_msg_count     	=> x_msg_count,
          x_msg_data      	=> x_msg_data,
          p_cat_id          => p_cat_id,
          p_cle_id          => p_cle_id,
          p_chr_id          => p_chr_id,
          x_cat_id			=> x_cat_id);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

     --Vertical Industry post processing section

     --Custom post processing section

    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
     WHEN OKL_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
     WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
     WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
       x_return_status := OKL_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        G_SCOPE);

  END copy_latest_articles;

END okl_copy_contract_pub;

/
