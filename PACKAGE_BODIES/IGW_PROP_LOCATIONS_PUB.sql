--------------------------------------------------------
--  DDL for Package Body IGW_PROP_LOCATIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_PROP_LOCATIONS_PUB" AS
--$Header: igwpplcb.pls 120.2 2006/03/08 20:17:04 dsadhukh ship $

   ---------------------------------------------------------------------------

   G_PKG_NAME  VARCHAR2(30) := 'IGW_PROP_LOCATIONS_PUB';

   ---------------------------------------------------------------------------

   PROCEDURE Create_Performing_Site
   (
      p_validate_only       IN VARCHAR2,
      p_commit              IN VARCHAR2,
      p_proposal_number     IN VARCHAR2,
      p_geographic_location IN VARCHAR2,
      p_performing_org_name IN VARCHAR2,
      x_return_status       OUT NOCOPY VARCHAR2,
      x_msg_count           OUT NOCOPY NUMBER,
      x_msg_data            OUT NOCOPY VARCHAR2
   ) IS


   BEGIN
     null;
   END Create_Performing_Site;

   ---------------------------------------------------------------------------

END Igw_Prop_Locations_Pub;

/
