--------------------------------------------------------
--  DDL for Package Body OKL_RULE_EXTRACT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_RULE_EXTRACT_PUB" AS
/* $Header: OKLPREXB.pls 115.13 2003/10/14 18:32:22 ashariff noship $ */
--start of comments
--API Name     : Get_Subclass_Rgs
--Description  :API to fetch all the rule groups attached to a subclass
--end of comments
PROCEDURE Get_subclass_Rgs (p_api_version     IN  NUMBER,
                            p_init_msg_list   IN  VARCHAR2,
                            x_return_status   OUT NOCOPY VARCHAR2,
                            x_msg_count       OUT NOCOPY NUMBER,
                            x_msg_data        OUT NOCOPY VARCHAR2,
                            p_chr_id          IN Varchar2,
                            x_sc_rg_tbl       OUT NOCOPY sc_rg_tbl_type) is
l_api_name          CONSTANT VARCHAR2(30) := 'GET_SUBCLASS_RGS';
l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
Begin
    l_return_status := OKL_API.START_ACTIVITY( substr(l_api_name,1,26),
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
     x_return_status := l_return_status;
     OKL_RULE_EXTRACT_PVT.Get_subclass_Rgs (p_api_version     => p_api_version,
                                            p_init_msg_list   => p_init_msg_list,
                                            x_return_status   => x_return_status,
                                            x_msg_count       => x_msg_count,
                                            x_msg_data        => x_msg_data,
                                            p_chr_id          => p_chr_id,
                                            x_sc_rg_tbl       => x_sc_rg_tbl);
     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;
       --Call End Activity
        OKL_API.END_ACTIVITY(x_msg_count    => x_msg_count,
                 x_msg_data     => x_msg_data);
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
END Get_Subclass_Rgs;
--start of comments
--API Name     : Get_Rg_Rules
--Description  : API to fetch all the rules attached to a rule group
--end of comments
PROCEDURE Get_Rg_Rules (p_api_version     IN  NUMBER,
                        p_init_msg_list   IN  VARCHAR2,
                        x_return_status   OUT NOCOPY VARCHAR2,
                        x_msg_count       OUT NOCOPY NUMBER,
                        x_msg_data        OUT NOCOPY VARCHAR2,
                        p_rgd_code        IN  Varchar2,
                        x_rg_rules_tbl    OUT NOCOPY rg_rules_tbl_type) Is
l_api_name          CONSTANT VARCHAR2(30) := 'GET_RG_RULES';
l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
BEGIN
     l_return_status := OKL_API.START_ACTIVITY( substr(l_api_name,1,26),
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
    x_return_status := l_return_status;
    OKL_RULE_EXTRACT_PVT.Get_Rg_Rules (p_api_version    => p_api_version,
                                   p_init_msg_list  => p_init_msg_list,
                                   x_return_status  => x_return_status,
                                   x_msg_count      => x_msg_count,
                                   x_msg_data       => x_msg_data,
                                   p_rgd_code       => p_rgd_code,
                                   x_rg_rules_tbl   => x_rg_rules_tbl);
     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;
       --Call End Activity
        OKL_API.END_ACTIVITY(x_msg_count    => x_msg_count,
                 x_msg_data     => x_msg_data);
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
END GET_RG_RULES;
--start of comments
--API Name     : Get_Rule_Def
--Description  : API to fetch rule definition - metadata for each rule segment
--end of comments
PROCEDURE Get_Rule_Def (p_api_version       IN  NUMBER,
                        p_init_msg_list     IN  VARCHAR2,
                        x_return_status     OUT NOCOPY VARCHAR2,
                        x_msg_count         OUT NOCOPY NUMBER,
                        x_msg_data          OUT NOCOPY VARCHAR2,
                        p_rgd_code          IN  VARCHAR2,
                        p_rgs_code          IN  VARCHAR2,
                        p_buy_or_sell       IN  VARCHAR2,
                        x_rule_segment_tbl  OUT NOCOPY rule_segment_tbl_type) IS
l_api_name          CONSTANT VARCHAR2(30) := 'GET_RULE_DEF';
l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
BEGIN
     l_return_status := OKL_API.START_ACTIVITY( substr(l_api_name,1,26),
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
    x_return_status := l_return_status;
    OKL_RULE_EXTRACT_PVT.Get_Rule_Def (p_api_version       => p_api_version,
                                       p_init_msg_list     => p_init_msg_list,
                                       x_return_status     => x_return_status,
                                       x_msg_count         => x_msg_count,
                                       x_msg_data          => x_msg_data,
                                       p_rgd_code          => p_rgd_code,
                                       p_rgs_code          => p_rgs_code,
                                       p_buy_or_sell       => p_buy_or_sell,
                                       x_rule_segment_tbl  => x_rule_segment_tbl);
     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;
       --Call End Activity
        OKL_API.END_ACTIVITY(x_msg_count    => x_msg_count,
                 x_msg_data     => x_msg_data);
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
END GET_RULE_DEF;

-- bug 3029276
--start of comments
--API Name     : Get_Rules_Metadata
--Description  : API to fetch rule definition - metadata for each rule segment
--               and retrieve ids and names for each segment.
--end of comments
PROCEDURE Get_Rules_Metadata (p_api_version       IN  NUMBER,
                              p_init_msg_list     IN  VARCHAR2,
                              x_return_status     OUT NOCOPY VARCHAR2,
                              x_msg_count         OUT NOCOPY NUMBER,
                              x_msg_data          OUT NOCOPY VARCHAR2,
                              p_rgd_code          IN  VARCHAR2,
                              p_rgs_code          IN  VARCHAR2,
                              p_buy_or_sell       IN  VARCHAR2,
                              p_contract_id       IN  OKC_K_HEADERS_B.ID%TYPE,
                              p_line_id           IN  OKC_K_LINES_B.ID%TYPE,
                              p_party_id          IN  OKC_K_PARTY_ROLES_B.ID%TYPE,
                              p_template_table    IN  VARCHAR2,
                              p_rule_id_column    IN  VARCHAR2,
                              p_entity_column     IN  VARCHAR2,
                              x_rule_segment_tbl  OUT NOCOPY rule_segment_tbl_type2) IS

l_api_name          CONSTANT VARCHAR2(30) := 'GET_RULE_DEF';
l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
BEGIN
     l_return_status := OKL_API.START_ACTIVITY( substr(l_api_name,1,26),
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
    x_return_status := l_return_status;
    OKL_RULE_EXTRACT_PVT.Get_Rules_Metadata (
                         p_api_version       => p_api_version,
                         p_init_msg_list     => p_init_msg_list,
                         x_return_status     => x_return_status,
                         x_msg_count         => x_msg_count,
                         x_msg_data          => x_msg_data,
                         p_rgd_code          => p_rgd_code,
                         p_rgs_code          => p_rgs_code,
                         p_buy_or_sell       => p_buy_or_sell,
                         p_contract_id       => p_contract_id,
                         p_line_id           => p_line_id,
                         p_party_id          => p_party_id,
                         p_template_table    => p_template_table,
                         p_rule_id_column    => p_rule_id_column,
                         p_entity_column     => p_entity_column,
                         x_rule_segment_tbl  => x_rule_segment_tbl);
     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;
       --Call End Activity
        OKL_API.END_ACTIVITY(x_msg_count    => x_msg_count,
                 x_msg_data     => x_msg_data);
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
END Get_Rules_Metadata;

End OKL_RULE_EXTRACT_PUB;

/
