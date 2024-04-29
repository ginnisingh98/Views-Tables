--------------------------------------------------------
--  DDL for Package OKC_ADOPTIONS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_ADOPTIONS_GRP" AUTHID CURRENT_USER AS
/* $Header: OKCGADPS.pls 120.0 2005/05/25 22:31:36 appldev noship $ */

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE check_adoption_details(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    x_earlier_local_version_id     OUT NOCOPY VARCHAR2,
    p_global_article_version_id IN NUMBER,
    p_adoption_type             IN VARCHAR2,
    p_local_org_id              IN NUMBER
  );

  PROCEDURE delete_local_adoption_details(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_only_local_version          IN VARCHAR2,
    p_local_article_version_id    IN NUMBER,
    p_local_org_id                 IN NUMBER
  );

  PROCEDURE create_local_adoption_details(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    x_adoption_type                OUT NOCOPY VARCHAR2,

    p_article_status               IN VARCHAR2,
    p_earlier_local_version_id     IN NUMBER,
    p_local_article_version_id       IN NUMBER,
    p_global_article_version_id    IN NUMBER,
    p_local_org_id                 IN NUMBER
  );

  PROCEDURE AUTO_ADOPT_ARTICLES
    (
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_relationship_yn              IN VARCHAR2 := 'N',
    p_adoption_yn                  IN VARCHAR2 := 'N',
    p_fetchsize                    IN NUMBER,
    p_global_article_id            IN NUMBER,
    p_global_article_version_id    IN NUMBER
    ) ;

-- The following procedure is a concurrent job that will be run if a new org is added and hence there is a
-- need to create autoadoption rows for the currently active global article versions

  PROCEDURE AUTO_ADOPT_NEWORG
           (errbuf           OUT NOCOPY VARCHAR2,
            retcode          OUT NOCOPY VARCHAR2,
            p_org_id      IN NUMBER    ,
            p_fetchsize      IN NUMBER
           ) ;


END OKC_ADOPTIONS_GRP;

 

/
