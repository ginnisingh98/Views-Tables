--------------------------------------------------------
--  DDL for Package IGW_PROP_ABSTRACTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_PROP_ABSTRACTS_PUB" AUTHID CURRENT_USER AS
--$Header: igwpabss.pls 115.0 2002/12/19 22:43:41 ashkumar noship $

   ---------------------------------------------------------------------------

   PROCEDURE Create_Prop_Abstract
   (
      p_validate_only         IN VARCHAR2   := Fnd_Api.G_False,
      p_commit                IN VARCHAR2   := Fnd_Api.G_False,
      p_proposal_number       IN VARCHAR2,
      p_abstract_type_desc    IN VARCHAR2,
      p_abstract              IN VARCHAR2,
      x_return_status         OUT NOCOPY VARCHAR2,
      x_msg_count             OUT NOCOPY NUMBER,
      x_msg_data              OUT NOCOPY VARCHAR2
   );

   ---------------------------------------------------------------------------

END Igw_Prop_Abstracts_Pub;

 

/
