--------------------------------------------------------
--  DDL for Package IBE_MSITE_INFORMATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_MSITE_INFORMATION_PKG" AUTHID CURRENT_USER AS
/* $Header: IBETMINS.pls 115.2 2002/12/13 13:02:03 schak ship $ */

  -- HISTORY
  --   12/13/02           SCHAK          Modified for NOCOPY (Bug # 2691704) Changes.
  -- *********************************************************************************

PROCEDURE insert_row
  (
   p_msite_information_id               IN NUMBER,
   p_object_version_number              IN NUMBER,
   p_msite_id                           IN NUMBER,
   p_msite_information_context          IN VARCHAR2,
   p_msite_information1                 IN VARCHAR2,
   p_msite_information2                 IN VARCHAR2,
   p_msite_information3                 IN VARCHAR2,
   p_msite_information4                 IN VARCHAR2,
   p_msite_information5                 IN VARCHAR2,
   p_msite_information6                 IN VARCHAR2,
   p_msite_information7                 IN VARCHAR2,
   p_msite_information8                 IN VARCHAR2,
   p_msite_information9                 IN VARCHAR2,
   p_msite_information10                IN VARCHAR2,
   p_msite_information11                IN VARCHAR2,
   p_msite_information12                IN VARCHAR2,
   p_msite_information13                IN VARCHAR2,
   p_msite_information14                IN VARCHAR2,
   p_msite_information15                IN VARCHAR2,
   p_msite_information16                IN VARCHAR2,
   p_msite_information17                IN VARCHAR2,
   p_msite_information18                IN VARCHAR2,
   p_msite_information19                IN VARCHAR2,
   p_msite_information20                IN VARCHAR2,
   p_attribute_category                 IN VARCHAR2,
   p_attribute1                         IN VARCHAR2,
   p_attribute2                         IN VARCHAR2,
   p_attribute3                         IN VARCHAR2,
   p_attribute4                         IN VARCHAR2,
   p_attribute5                         IN VARCHAR2,
   p_attribute6                         IN VARCHAR2,
   p_attribute7                         IN VARCHAR2,
   p_attribute8                         IN VARCHAR2,
   p_attribute9                         IN VARCHAR2,
   p_attribute10                        IN VARCHAR2,
   p_attribute11                        IN VARCHAR2,
   p_attribute12                        IN VARCHAR2,
   p_attribute13                        IN VARCHAR2,
   p_attribute14                        IN VARCHAR2,
   p_attribute15                        IN VARCHAR2,
   p_creation_date                      IN DATE,
   p_created_by                         IN NUMBER,
   p_last_update_date                   IN DATE,
   p_last_updated_by                    IN NUMBER,
   p_last_update_login                  IN NUMBER,
   x_rowid                              OUT NOCOPY VARCHAR2,
   x_msite_information_id               OUT NOCOPY NUMBER
  );

PROCEDURE update_row
  (
   p_msite_information_id               IN NUMBER,
   p_object_version_number              IN NUMBER   := FND_API.G_MISS_NUM,
   p_msite_information1                 IN VARCHAR2,
   p_msite_information2                 IN VARCHAR2,
   p_msite_information3                 IN VARCHAR2,
   p_msite_information4                 IN VARCHAR2,
   p_msite_information5                 IN VARCHAR2,
   p_msite_information6                 IN VARCHAR2,
   p_msite_information7                 IN VARCHAR2,
   p_msite_information8                 IN VARCHAR2,
   p_msite_information9                 IN VARCHAR2,
   p_msite_information10                IN VARCHAR2,
   p_msite_information11                IN VARCHAR2,
   p_msite_information12                IN VARCHAR2,
   p_msite_information13                IN VARCHAR2,
   p_msite_information14                IN VARCHAR2,
   p_msite_information15                IN VARCHAR2,
   p_msite_information16                IN VARCHAR2,
   p_msite_information17                IN VARCHAR2,
   p_msite_information18                IN VARCHAR2,
   p_msite_information19                IN VARCHAR2,
   p_msite_information20                IN VARCHAR2,
   p_attribute_category                 IN VARCHAR2,
   p_attribute1                         IN VARCHAR2,
   p_attribute2                         IN VARCHAR2,
   p_attribute3                         IN VARCHAR2,
   p_attribute4                         IN VARCHAR2,
   p_attribute5                         IN VARCHAR2,
   p_attribute6                         IN VARCHAR2,
   p_attribute7                         IN VARCHAR2,
   p_attribute8                         IN VARCHAR2,
   p_attribute9                         IN VARCHAR2,
   p_attribute10                        IN VARCHAR2,
   p_attribute11                        IN VARCHAR2,
   p_attribute12                        IN VARCHAR2,
   p_attribute13                        IN VARCHAR2,
   p_attribute14                        IN VARCHAR2,
   p_attribute15                        IN VARCHAR2,
   p_last_update_date                   IN DATE,
   p_last_updated_by                    IN NUMBER,
   p_last_update_login                  IN NUMBER
  );

PROCEDURE delete_row
  (
   p_msite_information_id IN NUMBER
  );

END Ibe_Msite_Information_Pkg;

 

/
