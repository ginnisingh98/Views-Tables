--------------------------------------------------------
--  DDL for Package IGW_PROP_SPECIAL_REVIEWS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_PROP_SPECIAL_REVIEWS_PUB" AUTHID CURRENT_USER AS
--$Header: igwprevs.pls 115.0 2002/12/19 22:44:27 ashkumar noship $

   ---------------------------------------------------------------------------

   PROCEDURE Create_Prop_Special_Review
   (
      p_validate_only            IN VARCHAR2   := Fnd_Api.G_False,
      p_commit                   IN VARCHAR2   := Fnd_Api.G_False,
      p_proposal_number          IN VARCHAR2,
      p_special_review_desc      IN VARCHAR2,
      p_special_review_type_desc IN VARCHAR2,
      p_application_date         IN DATE,
      p_approval_type_desc       IN VARCHAR2,
      p_protocol_number          IN VARCHAR2,
      p_approval_date            IN DATE,
      p_comments                 IN VARCHAR2,
      x_return_status            OUT NOCOPY VARCHAR2,
      x_msg_count                OUT NOCOPY NUMBER,
      x_msg_data                 OUT NOCOPY VARCHAR2
   );

   ---------------------------------------------------------------------------

END Igw_Prop_Special_Reviews_Pub;

 

/
