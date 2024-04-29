--------------------------------------------------------
--  DDL for Package Body IGW_PROP_LOCATIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_PROP_LOCATIONS_PVT" AS
--$Header: igwvplcb.pls 120.4 2006/02/22 23:24:42 dsadhukh ship $


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
 , x_msg_data                     OUT NOCOPY VARCHAR2)  is


BEGIN
  null;


END; --CREATE PERFORMING SITE

-------------------------------------------------------------------------------

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
 , x_msg_data                     OUT NOCOPY VARCHAR2)  is

BEGIN
 null;

END; --UPDATE PERFORMING SITE

----------------------------------------------------------------------------------------

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
 , x_msg_data                     OUT NOCOPY VARCHAR2) IS

BEGIN
 null;

END; --DELETE PERFORMING SITE

END IGW_PROP_LOCATIONS_PVT;

/
