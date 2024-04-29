--------------------------------------------------------
--  DDL for Package PA_COPY_CHANGE_DOC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_COPY_CHANGE_DOC_PVT" AUTHID CURRENT_USER AS
--$Header: PACICCDS.pls 120.2.12010000.1 2009/06/08 22:13:26 cklee noship $

G_PKG_NAME CONSTANT VARCHAR2(200)     := 'OKL_VP_COPY_CONTRACT_PVT' ;
G_APP_NAME CONSTANT VARCHAR2(3)       :=  OKL_API.G_APP_NAME;

/*
G_REQUIRED_VALUE                 CONSTANT VARCHAR2(200) := OKL_API.G_REQUIRED_VALUE;
G_INVALID_VALUE                  CONSTANT VARCHAR2(200) := OKL_API.G_INVALID_VALUE;
G_SQLERRM_TOKEN                  CONSTANT VARCHAR2(200) := 'OKL_SQLERRM';
G_SQLCODE_TOKEN                  CONSTANT VARCHAR2(200) := 'OKL_SQLCODE';
G_UNEXPECTED_ERROR               CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_UNEXPECTED_ERROR';
G_UPPERCASE_REQUIRED             CONSTANT VARCHAR2(200) := 'OKL_UPPER_CASE_REQUIRED';
G_COL_NAME_TOKEN                 CONSTANT VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
*/
G_EXCEPTION_HALT_VALIDATION       EXCEPTION;

procedure copy_change_doc(
        p_init_msg_list        IN     VARCHAR2 := fnd_api.g_true
        ,p_commit               IN     VARCHAR2 := FND_API.g_false
        ,p_validate_only        IN     VARCHAR2 := FND_API.g_true

        ,p_ci_id                IN     NUMBER
        ,p_ci_number            IN     VARCHAR2
        ,p_version_comments     IN     VARCHAR2
        ,x_ci_id                OUT    NOCOPY NUMBER
        ,x_version_number       OUT    NOCOPY NUMBER

        ,x_return_status        OUT    NOCOPY VARCHAR2
        ,x_msg_count            OUT    NOCOPY NUMBER
        ,x_msg_data             OUT    NOCOPY VARCHAR2
);

procedure copy_change_doc(
        p_init_msg_list        IN     VARCHAR2 := fnd_api.g_true
        ,p_commit               IN     VARCHAR2 := FND_API.g_false
        ,p_validate_only        IN     VARCHAR2 := FND_API.g_true

        ,p_ci_id                IN     NUMBER
        ,p_src_ci_id                IN     NUMBER
        ,x_ci_id                OUT    NOCOPY NUMBER
        ,x_version_number       OUT    NOCOPY NUMBER

        ,x_return_status        OUT    NOCOPY VARCHAR2
        ,x_msg_count            OUT    NOCOPY NUMBER
        ,x_msg_data             OUT    NOCOPY VARCHAR2
);
procedure update_comments(
        p_init_msg_list        IN     VARCHAR2 := fnd_api.g_true
        ,p_commit               IN     VARCHAR2 := FND_API.g_false
        ,p_validate_only        IN     VARCHAR2 := FND_API.g_true

        ,p_ci_id                IN     NUMBER
        ,p_version_comments     IN    VARCHAR2

        ,x_return_status        OUT    NOCOPY VARCHAR2
        ,x_msg_count            OUT    NOCOPY NUMBER
        ,x_msg_data             OUT    NOCOPY VARCHAR2
);
END  PA_COPY_CHANGE_DOC_PVT;

/
