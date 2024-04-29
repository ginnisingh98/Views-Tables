--------------------------------------------------------
--  DDL for Package IGW_ORGANIZATIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_ORGANIZATIONS_PVT" AUTHID CURRENT_USER AS
--$Header: igwvorgs.pls 115.1 2002/11/14 18:47:19 vmedikon noship $

   ---------------------------------------------------------------------------

   PROCEDURE Create_Organization
   (
      p_init_msg_list     IN VARCHAR2   := Fnd_Api.G_False,
      p_validate_only     IN VARCHAR2   := Fnd_Api.G_False,
      p_commit            IN VARCHAR2   := Fnd_Api.G_False,
      x_party_id          OUT NOCOPY NUMBER,
      p_organization_name IN VARCHAR2,
      p_address1          IN VARCHAR2,
      p_address2          IN VARCHAR2,
      p_address3          IN VARCHAR2,
      p_city              IN VARCHAR2,
      p_state             IN VARCHAR2,
      p_postal_code       IN VARCHAR2,
      p_county            IN VARCHAR2,
      p_country_name      IN VARCHAR2,
      p_active_flag       IN VARCHAR2,
      x_return_status     OUT NOCOPY VARCHAR2,
      x_msg_count         OUT NOCOPY NUMBER,
      x_msg_data          OUT NOCOPY VARCHAR2
   );

   ---------------------------------------------------------------------------

   PROCEDURE Update_Organization
   (
      p_init_msg_list     IN VARCHAR2   := Fnd_Api.G_False,
      p_validate_only     IN VARCHAR2   := Fnd_Api.G_False,
      p_commit            IN VARCHAR2   := Fnd_Api.G_False,
      p_party_id          IN NUMBER,
      p_party_version     IN NUMBER,
      p_location_id       IN NUMBER,
      p_location_version  IN NUMBER,
      p_organization_name IN VARCHAR2,
      p_address1          IN VARCHAR2,
      p_address2          IN VARCHAR2,
      p_address3          IN VARCHAR2,
      p_city              IN VARCHAR2,
      p_state             IN VARCHAR2,
      p_postal_code       IN VARCHAR2,
      p_county            IN VARCHAR2,
      p_country_name      IN VARCHAR2,
      p_active_flag       IN VARCHAR2,
      x_return_status     OUT NOCOPY VARCHAR2,
      x_msg_count         OUT NOCOPY NUMBER,
      x_msg_data          OUT NOCOPY VARCHAR2
   );

   ---------------------------------------------------------------------------

END Igw_Organizations_Pvt;

 

/
