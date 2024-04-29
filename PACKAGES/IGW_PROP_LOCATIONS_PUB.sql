--------------------------------------------------------
--  DDL for Package IGW_PROP_LOCATIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_PROP_LOCATIONS_PUB" AUTHID CURRENT_USER AS
--$Header: igwpplcs.pls 120.2 2006/10/10 17:30:15 vmedikon ship $

   PROCEDURE Create_Performing_Site
   (
      p_validate_only       IN VARCHAR2   := Fnd_Api.G_False,
      p_commit              IN VARCHAR2   := Fnd_Api.G_False,
      p_proposal_number     IN VARCHAR2,
      p_geographic_location IN VARCHAR2,
      p_performing_org_name IN VARCHAR2,
      x_return_status       OUT NOCOPY VARCHAR2,
      x_msg_count           OUT NOCOPY NUMBER,
      x_msg_data            OUT NOCOPY VARCHAR2
   );


   ---------------------------------------------------------------------------

END Igw_Prop_Locations_Pub;

 

/
