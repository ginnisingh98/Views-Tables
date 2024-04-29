--------------------------------------------------------
--  DDL for Package Body OKC_COPY_CONTRACT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_COPY_CONTRACT_PUB" AS
/*$Header: OKCPCPYB.pls 120.2.12010000.2 2008/10/24 08:01:05 ssreekum ship $*/
	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  G_API_VERSION          CONSTANT NUMBER := 1;
  G_SCOPE		 CONSTANT varchar2(4) := '_PUB';
  G_INIT_MSG_LIST        CONSTANT VARCHAR2(10) := OKC_API.G_FALSE;


 FUNCTION is_copy_allowed(p_chr_id IN NUMBER,p_sts_code IN VARCHAR2 ) RETURN BOOLEAN IS
 BEGIN
   RETURN(OKC_COPY_CONTRACT_PVT.is_copy_allowed(p_chr_id,p_sts_code));
 END is_copy_allowed;

 FUNCTION is_subcontract_allowed(p_chr_id IN NUMBER,p_sts_code IN VARCHAR2) RETURN BOOLEAN IS
 BEGIN
   RETURN(OKC_COPY_CONTRACT_PVT.is_subcontract_allowed(p_chr_id,p_sts_code));
 END is_subcontract_allowed;

 FUNCTION update_target_contract(p_chr_id IN NUMBER) RETURN BOOLEAN IS
 BEGIN
   RETURN(OKC_COPY_CONTRACT_PVT.update_target_contract(p_chr_id));
 END update_target_contract;

 PROCEDURE derive_line_style(p_old_lse_id     IN  NUMBER,
                              p_old_jtot_code  IN  VARCHAR2,
                              p_new_subclass   IN  VARCHAR2,
                              p_new_parent_lse IN  NUMBER,
                              x_new_lse_count  OUT NOCOPY NUMBER,
                              x_new_lse_ids    OUT NOCOPY VARCHAR2) IS
 BEGIN
  OKC_COPY_CONTRACT_PVT.derive_line_style(
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
    p_to_chr_id	          	   IN NUMBER,
    p_contract_number		        IN VARCHAR2,
    p_contract_number_modifier     IN VARCHAR2,
    p_to_template_yn			   IN VARCHAR2 ,
    p_copy_reference			   IN VARCHAR2 ,
    p_copy_line_party_yn              IN VARCHAR2,
    p_scs_code                     IN VARCHAR2,
    p_intent                       IN VARCHAR2,
    p_prospect                     IN VARCHAR2,
    p_components_tbl			   IN api_components_tbl,
    p_lines_tbl				   IN api_lines_tbl,
    x_chr_id                       OUT NOCOPY NUMBER,
    p_concurrent_request           IN VARCHAR2 DEFAULT 'N',
    p_include_cancelled_lines      IN VARCHAR2 DEFAULT 'Y',
    p_include_terminated_lines      IN VARCHAR2 DEFAULT 'Y') IS
--Bug 2950549 - Added the parameter p_concurrent_request

    l_api_name     CONSTANT VARCHAR2(30) := 'COPY_COMPONENTS';
    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(substr(l_api_name,1,26),
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              G_API_VERSION,
                                              p_api_version,
                                              G_SCOPE,
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    OKC_COPY_CONTRACT_PVT.copy_components(
	   p_api_version		=> p_api_version,
           p_init_msg_list		=> g_init_msg_list,
           x_return_status 		=> x_return_status,
           x_msg_count     		=> x_msg_count,
           x_msg_data      		=> x_msg_data,
           p_from_chr_id			=> p_from_chr_id,
           p_to_chr_id			=> p_to_chr_id,
           p_contract_number		=> p_contract_number,
           p_contract_number_modifier	=> p_contract_number_modifier,
		 p_to_template_yn        => p_to_template_yn,
		 p_copy_reference        => p_copy_reference,
           p_copy_line_party_yn    => p_copy_line_party_yn,
           p_scs_code              => p_scs_code,
           p_intent                => p_intent,
           p_prospect              => p_prospect,
		 p_components_tbl       => p_components_tbl,
		 p_lines_tbl             => p_lines_tbl,
         x_chr_id			=> x_chr_id,
		 p_concurrent_request => p_concurrent_request,
	   p_include_cancelled_lines  => p_include_cancelled_lines,
	   p_include_terminated_lines => p_include_terminated_lines);
    -- added p_concurrent request parameter for Bug 2950549

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
	-- Resetting the global transaction id.
	okc_cvm_pvt.g_trans_id := 'XXX';
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
	-- Resetting the global transaction id.
	okc_cvm_pvt.g_trans_id := 'XXX';
     WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_commit        			IN VARCHAR2 ,
    p_chr_id                       IN NUMBER,
    p_contract_number		     IN VARCHAR2,
    p_contract_number_modifier     IN VARCHAR2,
    p_to_template_yn		     IN VARCHAR2 ,
    p_renew_ref_yn                 IN VARCHAR2,
    p_copy_from_history_yn         IN VARCHAR2 ,
    p_from_version_number          IN NUMBER  ,
    p_copy_latest_articles         IN VARCHAR2 ,
    p_calling_mode                 IN VARCHAR2 ,
    x_chr_id                       OUT NOCOPY NUMBER) IS

    l_api_name           CONSTANT VARCHAR2(30) := 'COPY_CONTRACT';
    l_return_status      VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

    l_return_status := OKC_API.START_ACTIVITY(substr(l_api_name,1,26),
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              G_API_VERSION,
                                              p_api_version,
                                              G_SCOPE,
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    OKC_COPY_CONTRACT_PVT.copy_contract(
	   p_api_version		=> p_api_version,
           p_init_msg_list		=> g_init_msg_list,
           x_return_status 		=> x_return_status,
           x_msg_count     		=> x_msg_count,
           x_msg_data      		=> x_msg_data,
           p_commit			     => p_commit,
           p_chr_id			     => p_chr_id,
           p_contract_number		=> p_contract_number,
           p_contract_number_modifier	=> p_contract_number_modifier,
	      p_to_template_yn             => p_to_template_yn,
           p_renew_ref_yn               => p_renew_ref_yn,
           p_copy_lines_yn              => 'Y',
	      p_copy_from_history_yn       => p_copy_from_history_yn,
	      p_from_version_number        => p_from_version_number,
		 p_copy_latest_articles       => p_copy_latest_articles,
		 p_calling_mode           => p_calling_mode,
           x_chr_id			          => x_chr_id);


    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    IF p_commit = 'T' THEN
      commit;
    END IF;

    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
     WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        G_SCOPE);

  END copy_contract;

  PROCEDURE copy_contract(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_commit        			IN VARCHAR2 ,
    p_chr_id                       IN NUMBER,
    p_contract_number		     IN VARCHAR2,
    p_contract_number_modifier     IN VARCHAR2,
    p_to_template_yn			IN VARCHAR2 ,
    p_renew_ref_yn                 IN VARCHAR2,
    p_copy_lines_yn                IN VARCHAR2,
    p_override_org		          IN VARCHAR2 ,
    p_copy_from_history_yn         IN VARCHAR2 ,
    p_from_version_number          IN NUMBER ,
    p_copy_latest_articles         IN VARCHAR2 ,
    p_calling_mode                 IN VARCHAR2 ,
    x_chr_id                       OUT NOCOPY NUMBER) IS

    l_api_name     CONSTANT VARCHAR2(30) := 'COPY_CONTRACT';
    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(substr(l_api_name,1,26),
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              G_API_VERSION,
                                              p_api_version,
                                              G_SCOPE,
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    OKC_COPY_CONTRACT_PVT.copy_contract(
	   p_api_version		=> p_api_version,
           p_init_msg_list		=> g_init_msg_list,
           x_return_status 		=> x_return_status,
           x_msg_count     		=> x_msg_count,
           x_msg_data      		=> x_msg_data,
           p_commit			=> p_commit,
           p_chr_id			=> p_chr_id,
           p_contract_number		=> p_contract_number,
           p_contract_number_modifier	=> p_contract_number_modifier,
    	   p_to_template_yn             => p_to_template_yn,
           p_renew_ref_yn               => p_renew_ref_yn,
           p_copy_lines_yn              => p_copy_lines_yn,
           p_override_org               => p_override_org,
           p_copy_from_history_yn       => p_copy_from_history_yn,
           p_from_version_number        => p_from_version_number,
 	   p_copy_latest_articles       => p_copy_latest_articles,
           p_calling_mode               => p_calling_mode,
           x_chr_id			=> x_chr_id);

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    IF p_commit = 'T' THEN
      commit;
    END IF;

    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
     WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        G_SCOPE);

  END copy_contract;


  -- Added additional parameter p_change_status to check if the
  -- line status need to be retaned.

  PROCEDURE copy_contract_lines(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_from_cle_id                  IN NUMBER,
    p_to_cle_id                    IN NUMBER ,
    p_to_chr_id                    IN NUMBER ,
    p_to_template_yn			   IN VARCHAR2 ,
    p_copy_reference               IN VARCHAR2,
    p_copy_line_party_yn           IN VARCHAR2,
    p_renew_ref_yn                 IN VARCHAR2,
    x_cle_id		           OUT NOCOPY NUMBER,
    p_change_status		          IN VARCHAR2)

    IS

  BEGIN

  --- LLC Added an additional flag parameter, p_change_status, to decide
  --- whether to allow change of status of sublines of the topline
  ---  during update service

    OKC_COPY_CONTRACT_PVT.copy_contract_lines(
	   p_api_version	=> p_api_version,
           p_init_msg_list	=> p_init_msg_list,
           x_return_status 	=> x_return_status,
           x_msg_count     	=> x_msg_count,
           x_msg_data      	=> x_msg_data,
           p_from_cle_id	=> p_from_cle_id,
	      p_to_chr_id 		=> p_to_chr_id,
	      p_to_cle_id 		=> p_to_cle_id,
		 p_to_template_yn        => p_to_template_yn,
           p_copy_reference      => p_copy_reference,
           p_copy_line_party_yn  => p_copy_line_party_yn,
           p_renew_ref_yn          => p_renew_ref_yn,
           x_cle_id		=> x_cle_id,
	      p_change_status      => p_change_status);

  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END copy_contract_lines;

  PROCEDURE copy_rules(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rgp_id                  	   IN NUMBER,
    p_cle_id                       IN NUMBER ,
    p_chr_id                       IN NUMBER ,
    p_to_template_yn			IN VARCHAR2,
    x_rgp_id		           OUT NOCOPY NUMBER) IS

    l_api_name     CONSTANT VARCHAR2(30) := 'COPY_RULES';
    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(substr(l_api_name,1,26),
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              G_API_VERSION,
                                              p_api_version,
                                              G_SCOPE,
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    OKC_COPY_CONTRACT_PVT.copy_rules(
           p_api_version		=> p_api_version,
           p_init_msg_list		=> g_init_msg_list,
           x_return_status 	=> x_return_status,
           x_msg_count     	=> x_msg_count,
           x_msg_data      	=> x_msg_data,
           p_rgp_id			=> p_rgp_id,
           p_cle_id			=> p_cle_id,
           p_chr_id			=> p_chr_id,
   	   p_to_template_yn      => p_to_template_yn,
           x_rgp_id			=> x_rgp_id);

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
     WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        G_SCOPE);

  END copy_rules;

  PROCEDURE copy_party_roles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cpl_id                  	   IN NUMBER,
    p_cle_id                       IN NUMBER ,
    p_chr_id                       IN NUMBER ,
    P_rle_code                     IN VARCHAR2,
    x_cpl_id	            	   OUT NOCOPY NUMBER) IS
    l_api_name     		   CONSTANT VARCHAR2(30) := 'COPY_PARTY_ROLES';
    l_return_status         	   VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(substr(l_api_name,1,26),
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              G_API_VERSION,
                                              p_api_version,
                                              G_SCOPE,
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    OKC_COPY_CONTRACT_PVT.copy_party_roles(
    		p_api_version           => p_api_version,
    		p_init_msg_list         => g_init_msg_list,
    		x_return_status         => x_return_status,
    		x_msg_count             => x_msg_count,
    		x_msg_data              => x_msg_data,
    		p_cpl_id                => p_cpl_id,
    		p_cle_id                => p_cle_id,
    		p_chr_id                => p_chr_id,
    		p_rle_code              => p_rle_code,
    		x_cpl_id		=> x_cpl_id);


    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
     WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        G_SCOPE);

  END copy_party_roles;

  PROCEDURE copy_articles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cat_id                  	IN NUMBER,
    p_cle_id                       IN NUMBER ,
    p_chr_id                       IN NUMBER ,
    p_sav_sav_release		     IN VARCHAR2 ,
    x_cat_id		           	OUT NOCOPY NUMBER) IS


    l_api_name     			CONSTANT VARCHAR2(30) := 'COPY_ARTICLES';
    l_return_status           VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(substr(l_api_name,1,26),
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              G_API_VERSION,
                                              p_api_version,
                                              G_SCOPE,
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    OKC_COPY_CONTRACT_PVT.copy_articles(
          p_api_version		=> p_api_version,
          p_init_msg_list	=> g_init_msg_list,
          x_return_status 	=> x_return_status,
          x_msg_count     	=> x_msg_count,
          x_msg_data      	=> x_msg_data,
          p_cat_id              => p_cat_id,
    	  p_cle_id              => p_cle_id,
    	  p_chr_id              => p_chr_id,
    	  p_sav_sav_release     => p_sav_sav_release,
    	  x_cat_id		=> x_cat_id);

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
     WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        G_SCOPE);

  END copy_articles;

  PROCEDURE copy_latest_articles(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cat_id                  	IN NUMBER,
    p_cle_id                       IN NUMBER ,
    p_chr_id                       IN NUMBER ,
    x_cat_id		           	OUT NOCOPY NUMBER) IS


    l_api_name     		   CONSTANT VARCHAR2(30) := 'COPY_LATEST_ARTICLES';
    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(substr(l_api_name,1,26),
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              G_API_VERSION,
                                              p_api_version,
                                              G_SCOPE,
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    OKC_COPY_CONTRACT_PVT.copy_latest_articles(
          p_api_version		=> p_api_version,
          p_init_msg_list	=> g_init_msg_list,
          x_return_status 	=> x_return_status,
          x_msg_count     	=> x_msg_count,
          x_msg_data      	=> x_msg_data,
          p_cat_id            => p_cat_id,
    	     p_cle_id            => p_cle_id,
    	     p_chr_id            => p_chr_id,
    	     x_cat_id			=> x_cat_id);

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
     WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        G_SCOPE);

  END copy_latest_articles;

-- Bug 2950549 - Added this procedure Copy_concurrent
   PROCEDURE copy_concurrent(errbuf out NOCOPY VARCHAR2,
					    retcode out NOCOPY NUMBER,
					    p_id in NUMBER,
                     	    p_from_chr_id IN NUMBER,
					    p_to_chr_id IN NUMBER,
				         p_contract_number IN VARCHAR2,
				         p_contract_number_modifier IN VARCHAR2,
				         p_to_template_yn IN VARCHAR2,
				         p_copy_reference IN VARCHAR2,
				         p_copy_line_party_yn IN VARCHAR2,
				         p_scs_code IN VARCHAR2,
				         p_intent   IN VARCHAR2,
				         p_prospect IN VARCHAR2,
                             p_copy_entire_k_yn IN VARCHAR2, /* hkamdar R12 copy project*/
			     p_include_cancelled_lines IN VARCHAR2,
			     p_include_terminated_lines IN VARCHAR2) IS
 BEGIN
OKC_COPY_CONTRACT_PVT.copy_concurrent(errbuf, retcode, p_id, p_from_chr_id,
p_to_chr_id,p_contract_number, p_contract_number_modifier,p_to_template_yn,
p_copy_reference,p_copy_line_party_yn,p_scs_code,p_intent,p_prospect,p_copy_entire_k_yn,p_include_cancelled_lines => p_include_cancelled_lines,p_include_terminated_lines => p_include_terminated_lines);-- hkamdar R12 copy project

 END copy_concurrent;
-- Bug 2950549 - End of the procedure

-- IKON ER 3819893

 PROCEDURE UPDATE_TEMPLATE_CONTRACT (p_api_version   IN NUMBER,
                                     p_init_msg_list IN VARCHAR2,
                                     p_chr_id        IN NUMBER,
                                     p_start_date    IN DATE,
                                     p_end_date      IN DATE,
                                     x_msg_count     OUT  NOCOPY  NUMBER,
                                     x_msg_data      OUT   NOCOPY VARCHAR2,
                                     x_return_status OUT   NOCOPY VARCHAR2) IS

    l_api_name     CONSTANT VARCHAR2(30) := 'UPDATE_TEMPLATE_CONTRACT';
    l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
  --  errorout_ad ('INSIDE ####');
    l_return_status := OKC_API.START_ACTIVITY(substr(l_api_name,1,26),
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              G_API_VERSION,
                                              p_api_version,
                                              G_SCOPE,
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    OKC_COPY_CONTRACT_PVT.UPDATE_TEMPLATE_CONTRACT(p_api_version   => p_api_version,
				                   p_chr_id        => p_chr_id,
				                   p_start_date    => p_start_date,
				                   p_end_date      => p_end_date,
				                   x_msg_count     => x_msg_count,
				                   x_msg_data      => x_msg_data,
                                                   x_return_status => x_return_status);

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
     WHEN OKC_API.G_EXCEPTION_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
     WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        G_SCOPE);
     WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
       x_return_status := OKC_API.HANDLE_EXCEPTIONS
       (substr(l_api_name,1,26),
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        G_SCOPE);

  END  UPDATE_TEMPLATE_CONTRACT;

END OKC_COPY_CONTRACT_PUB;

/
