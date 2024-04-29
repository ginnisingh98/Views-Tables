--------------------------------------------------------
--  DDL for Package IGW_PROP_ABSTRACTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_PROP_ABSTRACTS_PVT" AUTHID CURRENT_USER AS
--$Header: igwvabss.pls 115.3 2002/11/14 18:50:39 vmedikon ship $

   ---------------------------------------------------------------------------

   PROCEDURE Populate_Prop_Abstracts( p_proposal_id IN NUMBER );

   ---------------------------------------------------------------------------

   PROCEDURE Update_Prop_Abstract
   (
      p_init_msg_list         IN VARCHAR2   := Fnd_Api.G_False,
      p_validate_only         IN VARCHAR2   := Fnd_Api.G_False,
      p_commit                IN VARCHAR2   := Fnd_Api.G_False,
      p_rowid                 IN VARCHAR2,
      p_proposal_id           IN NUMBER,
      p_proposal_number       IN VARCHAR2,
      p_abstract_type         IN VARCHAR2,
      p_abstract_type_code    IN VARCHAR2,
      p_abstract_type_desc    IN VARCHAR2,
      p_abstract              IN VARCHAR2,
      p_attribute_category    IN VARCHAR2,
      p_attribute1            IN VARCHAR2,
      p_attribute2            IN VARCHAR2,
      p_attribute3            IN VARCHAR2,
      p_attribute4            IN VARCHAR2,
      p_attribute5            IN VARCHAR2,
      p_attribute6            IN VARCHAR2,
      p_attribute7            IN VARCHAR2,
      p_attribute8            IN VARCHAR2,
      p_attribute9            IN VARCHAR2,
      p_attribute10           IN VARCHAR2,
      p_attribute11           IN VARCHAR2,
      p_attribute12           IN VARCHAR2,
      p_attribute13           IN VARCHAR2,
      p_attribute14           IN VARCHAR2,
      p_attribute15           IN VARCHAR2,
      p_record_version_number IN NUMBER,
      x_return_status         OUT NOCOPY VARCHAR2,
      x_msg_count             OUT NOCOPY NUMBER,
      x_msg_data              OUT NOCOPY VARCHAR2
   );

   ---------------------------------------------------------------------------

END Igw_Prop_Abstracts_Pvt;

 

/
