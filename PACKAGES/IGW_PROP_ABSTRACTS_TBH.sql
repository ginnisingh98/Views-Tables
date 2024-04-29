--------------------------------------------------------
--  DDL for Package IGW_PROP_ABSTRACTS_TBH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_PROP_ABSTRACTS_TBH" AUTHID CURRENT_USER AS
/* $Header: igwtabss.pls 115.4 2002/11/14 18:51:06 vmedikon ship $ */

   ---------------------------------------------------------------------------

   PROCEDURE Insert_Row
   (
      x_rowid              OUT NOCOPY VARCHAR2,
      p_proposal_id        IN NUMBER,
      p_abstract_type      IN VARCHAR2,
      p_abstract_type_code IN VARCHAR2,
      p_abstract           IN VARCHAR2,
      p_attribute_category IN VARCHAR2,
      p_attribute1         IN VARCHAR2,
      p_attribute2         IN VARCHAR2,
      p_attribute3         IN VARCHAR2,
      p_attribute4         IN VARCHAR2,
      p_attribute5         IN VARCHAR2,
      p_attribute6         IN VARCHAR2,
      p_attribute7         IN VARCHAR2,
      p_attribute8         IN VARCHAR2,
      p_attribute9         IN VARCHAR2,
      p_attribute10        IN VARCHAR2,
      p_attribute11        IN VARCHAR2,
      p_attribute12        IN VARCHAR2,
      p_attribute13        IN VARCHAR2,
      p_attribute14        IN VARCHAR2,
      p_attribute15        IN VARCHAR2,
      x_return_status      OUT NOCOPY VARCHAR2,
      p_mode               IN VARCHAR2 default 'R'
   );

   ---------------------------------------------------------------------------

   PROCEDURE Update_Row
   (
      p_rowid                 IN VARCHAR2,
      p_proposal_id           IN NUMBER,
      p_abstract_type         IN VARCHAR2,
      p_abstract_type_code    IN VARCHAR2,
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
      p_mode                  IN VARCHAR2 default 'R'
   );

   ---------------------------------------------------------------------------

END Igw_Prop_Abstracts_Tbh;

 

/
