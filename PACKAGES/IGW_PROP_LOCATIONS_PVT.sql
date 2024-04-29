--------------------------------------------------------
--  DDL for Package IGW_PROP_LOCATIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_PROP_LOCATIONS_PVT" AUTHID CURRENT_USER AS
--$Header: igwvplcs.pls 120.3 2005/10/30 05:53:43 appldev ship $

PROCEDURE CREATE_PERFORMING_SITE
(p_init_msg_list                  IN VARCHAR2   := FND_API.G_TRUE
 , p_commit                       IN VARCHAR2   := FND_API.G_FALSE
 , p_validate_only                IN VARCHAR2   := FND_API.G_TRUE
 , p_proposal_id                  IN NUMBER
 , p_proposal_number              IN VARCHAR2
 , p_geographic_location          IN VARCHAR2
 , p_performing_org_id            IN NUMBER
 , p_party_id                     IN NUMBER
 , p_performing_org_name          IN VARCHAR2
 , x_rowid                        OUT NOCOPY ROWID
 , x_return_status                OUT NOCOPY VARCHAR2
 , x_msg_count                    OUT NOCOPY NUMBER
 , x_msg_data                     OUT NOCOPY VARCHAR2) ;


PROCEDURE UPDATE_PERFORMING_SITE
(p_init_msg_list                  IN VARCHAR2   := FND_API.G_TRUE
 , p_commit                       IN VARCHAR2   := FND_API.G_FALSE
 , p_validate_only                IN VARCHAR2   := FND_API.G_TRUE
 , p_proposal_id                  IN NUMBER
 , p_proposal_number              IN VARCHAR2
 , p_performing_org_id            IN NUMBER
 , p_party_id                     IN NUMBER
 , p_performing_org_name          IN VARCHAR2
 , p_record_version_number        IN NUMBER
 , p_rowid                        IN ROWID
 , x_return_status                OUT NOCOPY VARCHAR2
 , x_msg_count                    OUT NOCOPY NUMBER
 , x_msg_data                     OUT NOCOPY VARCHAR2);


PROCEDURE DELETE_PERFORMING_SITE
(p_init_msg_list                  IN VARCHAR2     := FND_API.G_TRUE
 , p_commit                       IN VARCHAR2   := FND_API.G_FALSE
 , p_validate_only                IN VARCHAR2   := FND_API.G_TRUE
 , p_proposal_id                  IN NUMBER
 , p_proposal_number              IN VARCHAR2
 , p_performing_org_id            IN NUMBER
 , p_party_id                     IN NUMBER
 , p_performing_org_name          IN VARCHAR2
 , p_record_version_number        IN NUMBER
 , p_rowid                        IN ROWID
 , x_return_status                OUT NOCOPY VARCHAR2
 , x_msg_count                    OUT NOCOPY NUMBER
 , x_msg_data                     OUT NOCOPY VARCHAR2);

END IGW_PROP_LOCATIONS_PVT;

 

/
