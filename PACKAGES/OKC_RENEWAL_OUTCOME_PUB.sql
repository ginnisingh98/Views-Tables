--------------------------------------------------------
--  DDL for Package OKC_RENEWAL_OUTCOME_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_RENEWAL_OUTCOME_PUB" AUTHID CURRENT_USER AS
/* $Header: OKCPORWS.pls 120.0 2005/05/25 23:12:23 appldev noship $*/

PROCEDURE Renewal_Outcome( p_api_version          IN NUMBER   DEFAULT 1.0
                    ,p_init_msg_list              IN VARCHAR2 DEFAULT OKC_API.G_FALSE
                    ,x_return_status              OUT NOCOPY VARCHAR2
                    ,x_msg_count                  OUT NOCOPY NUMBER
                    ,x_msg_data                   OUT NOCOPY VARCHAR2
                    -- ,x_contract_id                OUT NOCOPY NUMBER
                    ,p_contract_id                IN NUMBER
                    ,p_contract_number            IN VARCHAR2  DEFAULT OKC_API.G_MISS_CHAR
                    ,p_contract_version           IN VARCHAR2  DEFAULT OKC_API.G_MISS_CHAR
                    ,p_contract_modifier          IN VARCHAR2  DEFAULT OKC_API.G_MISS_CHAR
                    ,p_object_version_number      IN NUMBER    DEFAULT OKC_API.G_MISS_NUM
                    ,p_new_contract_number        IN VARCHAR2  DEFAULT OKC_API.G_MISS_CHAR
                    ,p_new_contract_modifier      IN VARCHAR2  DEFAULT OKC_API.G_MISS_CHAR
                    ,p_start_date                 IN DATE      DEFAULT OKC_API.G_MISS_DATE
                    ,p_end_date                   IN DATE      DEFAULT OKC_API.G_MISS_DATE
                    ,p_orig_start_date            IN DATE      DEFAULT OKC_API.G_MISS_DATE
                    ,p_orig_end_date              IN DATE      DEFAULT OKC_API.G_MISS_DATE
                    ,p_uom_code                   IN VARCHAR2  DEFAULT OKC_API.G_MISS_CHAR
                    ,p_duration                   IN NUMBER    DEFAULT OKC_API.G_MISS_NUM
                    ,p_context                    IN VARCHAR2  DEFAULT OKC_API.G_MISS_CHAR
                    ,p_perpetual_flag             IN VARCHAR2  DEFAULT OKC_API.G_MISS_CHAR
                    ,p_do_commit                  IN VARCHAR2  DEFAULT OKC_API.G_MISS_CHAR);

END OKC_RENEWAL_OUTCOME_PUB;

 

/
