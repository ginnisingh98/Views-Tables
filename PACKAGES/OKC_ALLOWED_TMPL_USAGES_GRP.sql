--------------------------------------------------------
--  DDL for Package OKC_ALLOWED_TMPL_USAGES_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_ALLOWED_TMPL_USAGES_GRP" AUTHID CURRENT_USER AS
/* $Header: OKCGALDTMPLUSGS.pls 120.0 2005/05/25 22:50:02 appldev noship $ */

  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE Create_Allowed_Tmpl_Usages(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_template_id            IN NUMBER,
    p_document_type          IN VARCHAR2,
    p_default_yn             IN VARCHAR2,
    p_allowed_tmpl_usages_id IN NUMBER   := NULL,

    p_attribute_category     IN VARCHAR2 := NULL,
    p_attribute1             IN VARCHAR2 := NULL,
    p_attribute2             IN VARCHAR2 := NULL,
    p_attribute3             IN VARCHAR2 := NULL,
    p_attribute4             IN VARCHAR2 := NULL,
    p_attribute5             IN VARCHAR2 := NULL,
    p_attribute6             IN VARCHAR2 := NULL,
    p_attribute7             IN VARCHAR2 := NULL,
    p_attribute8             IN VARCHAR2 := NULL,
    p_attribute9             IN VARCHAR2 := NULL,
    p_attribute10            IN VARCHAR2 := NULL,
    p_attribute11            IN VARCHAR2 := NULL,
    p_attribute12            IN VARCHAR2 := NULL,
    p_attribute13            IN VARCHAR2 := NULL,
    p_attribute14            IN VARCHAR2 := NULL,
    p_attribute15            IN VARCHAR2 := NULL,

    x_allowed_tmpl_usages_id OUT NOCOPY NUMBER

    );

  PROCEDURE Lock_Allowed_Tmpl_Usages(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_allowed_tmpl_usages_id IN NUMBER,

    p_object_version_number  IN NUMBER

    );

  PROCEDURE Update_Allowed_Tmpl_Usages(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_template_id            IN NUMBER,
    p_document_type          IN VARCHAR2,
    p_default_yn             IN VARCHAR2,
    p_allowed_tmpl_usages_id IN NUMBER,

    p_attribute_category     IN VARCHAR2 := NULL,
    p_attribute1             IN VARCHAR2 := NULL,
    p_attribute2             IN VARCHAR2 := NULL,
    p_attribute3             IN VARCHAR2 := NULL,
    p_attribute4             IN VARCHAR2 := NULL,
    p_attribute5             IN VARCHAR2 := NULL,
    p_attribute6             IN VARCHAR2 := NULL,
    p_attribute7             IN VARCHAR2 := NULL,
    p_attribute8             IN VARCHAR2 := NULL,
    p_attribute9             IN VARCHAR2 := NULL,
    p_attribute10            IN VARCHAR2 := NULL,
    p_attribute11            IN VARCHAR2 := NULL,
    p_attribute12            IN VARCHAR2 := NULL,
    p_attribute13            IN VARCHAR2 := NULL,
    p_attribute14            IN VARCHAR2 := NULL,
    p_attribute15            IN VARCHAR2 := NULL,

    p_object_version_number  IN NUMBER
    );

  PROCEDURE Delete_Allowed_Tmpl_Usages(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_commit                       IN VARCHAR2 := FND_API.G_FALSE,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_allowed_tmpl_usages_id IN NUMBER,

    p_object_version_number  IN NUMBER
    );

  PROCEDURE Validate_Allowed_Tmpl_Usages(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    p_validation_level	           IN NUMBER := FND_API.G_VALID_LEVEL_FULL,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_template_id            IN NUMBER,
    p_document_type          IN VARCHAR2,
    p_default_yn             IN VARCHAR2,
    p_allowed_tmpl_usages_id IN NUMBER,

    p_attribute_category     IN VARCHAR2 := NULL,
    p_attribute1             IN VARCHAR2 := NULL,
    p_attribute2             IN VARCHAR2 := NULL,
    p_attribute3             IN VARCHAR2 := NULL,
    p_attribute4             IN VARCHAR2 := NULL,
    p_attribute5             IN VARCHAR2 := NULL,
    p_attribute6             IN VARCHAR2 := NULL,
    p_attribute7             IN VARCHAR2 := NULL,
    p_attribute8             IN VARCHAR2 := NULL,
    p_attribute9             IN VARCHAR2 := NULL,
    p_attribute10            IN VARCHAR2 := NULL,
    p_attribute11            IN VARCHAR2 := NULL,
    p_attribute12            IN VARCHAR2 := NULL,
    p_attribute13            IN VARCHAR2 := NULL,
    p_attribute14            IN VARCHAR2 := NULL,
    p_attribute15            IN VARCHAR2 := NULL,

    p_object_version_number  IN NUMBER
    );

END OKC_ALLOWED_TMPL_USAGES_GRP;

 

/
