--------------------------------------------------------
--  DDL for Package XLE_ASSOCIATIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLE_ASSOCIATIONS_PUB" AUTHID CURRENT_USER AS
/* $Header: xleassms.pls 120.1 2005/05/03 12:37:08 ttran ship $ */

PROCEDURE Create_Association(

  --   *****  Standard API parameters *****
  p_init_msg_list             IN  VARCHAR2 := FND_API.G_TRUE,
  p_commit                    IN  VARCHAR2 := FND_API.G_FALSE,
  x_return_status             OUT NOCOPY VARCHAR2,
  x_msg_count                 OUT NOCOPY NUMBER,
  x_msg_data                  OUT NOCOPY VARCHAR2,


  --   *****  Legal Association information parameters *****
  p_context                   IN  VARCHAR2,
  p_subject_type              IN  VARCHAR2,
  p_subject_id                IN  NUMBER,
  p_object_type               IN  VARCHAR2,
  p_object_id                 IN  NUMBER,
  p_effective_from            IN  DATE,
  p_assoc_information_context IN  VARCHAR2 := NULL,
  p_assoc_information1        IN  VARCHAR2 := NULL,
  p_assoc_information2        IN  VARCHAR2 := NULL,
  p_assoc_information3        IN  VARCHAR2 := NULL,
  p_assoc_information4        IN  VARCHAR2 := NULL,
  p_assoc_information5        IN  VARCHAR2 := NULL,
  p_assoc_information6        IN  VARCHAR2 := NULL,
  p_assoc_information7        IN  VARCHAR2 := NULL,
  p_assoc_information8        IN  VARCHAR2 := NULL,
  p_assoc_information9        IN  VARCHAR2 := NULL,
  p_assoc_information10       IN  VARCHAR2 := NULL,
  p_assoc_information11       IN  VARCHAR2 := NULL,
  p_assoc_information12       IN  VARCHAR2 := NULL,
  p_assoc_information13       IN  VARCHAR2 := NULL,
  p_assoc_information14       IN  VARCHAR2 := NULL,
  p_assoc_information15       IN  VARCHAR2 := NULL,
  p_assoc_information16       IN  VARCHAR2 := NULL,
  p_assoc_information17       IN  VARCHAR2 := NULL,
  p_assoc_information18       IN  VARCHAR2 := NULL,
  p_assoc_information19       IN  VARCHAR2 := NULL,
  p_assoc_information20       IN  VARCHAR2 := NULL,
  x_association_ID            OUT NOCOPY NUMBER);


PROCEDURE Update_Association(

  --   *****  Standard API parameters *****
  p_init_msg_list             IN  VARCHAR2 := FND_API.G_TRUE,
  p_commit                    IN  VARCHAR2 := FND_API.G_FALSE,
  x_return_status             OUT NOCOPY VARCHAR2,
  x_msg_count                 OUT NOCOPY NUMBER,
  x_msg_data                  OUT NOCOPY VARCHAR2,

  --   *****  Legal Association information parameters *****
  p_association_id            IN  NUMBER   := NULL,
  p_context                   IN  VARCHAR2 := NULL,
  p_subject_type              IN  VARCHAR2 := NULL,
  p_subject_id                IN  NUMBER   := NULL,
  p_object_type               IN  VARCHAR2 := NULL,
  p_object_id                 IN  NUMBER   := NULL,
  p_effective_from            IN  DATE     := NULL,
  p_effective_to              IN  DATE     := NULL,
  p_assoc_information_context IN VARCHAR2  := NULL,
  p_assoc_information1        IN VARCHAR2  := NULL,
  p_assoc_information2        IN VARCHAR2  := NULL,
  p_assoc_information3        IN VARCHAR2  := NULL,
  p_assoc_information4        IN VARCHAR2  := NULL,
  p_assoc_information5        IN VARCHAR2  := NULL,
  p_assoc_information6        IN VARCHAR2  := NULL,
  p_assoc_information7        IN VARCHAR2  := NULL,
  p_assoc_information8        IN VARCHAR2  := NULL,
  p_assoc_information9        IN VARCHAR2  := NULL,
  p_assoc_information10       IN VARCHAR2  := NULL,
  p_assoc_information11       IN VARCHAR2  := NULL,
  p_assoc_information12       IN VARCHAR2  := NULL,
  p_assoc_information13       IN VARCHAR2  := NULL,
  p_assoc_information14       IN VARCHAR2  := NULL,
  p_assoc_information15       IN VARCHAR2  := NULL,
  p_assoc_information16       IN VARCHAR2  := NULL,
  p_assoc_information17       IN VARCHAR2  := NULL,
  p_assoc_information18       IN VARCHAR2  := NULL,
  p_assoc_information19       IN VARCHAR2  := NULL,
  p_assoc_information20       IN VARCHAR2  := NULL,
  p_object_version_number     IN OUT NOCOPY NUMBER);


END XLE_ASSOCIATIONS_PUB;


 

/
