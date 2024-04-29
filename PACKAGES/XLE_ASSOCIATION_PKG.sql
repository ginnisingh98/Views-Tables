--------------------------------------------------------
--  DDL for Package XLE_ASSOCIATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLE_ASSOCIATION_PKG" AUTHID CURRENT_USER AS
/* $Header: xleassts.pls 120.1 2005/05/03 12:36:46 ttran ship $ */

PROCEDURE Insert_Row(
  x_association_id		IN OUT NOCOPY NUMBER,
  p_association_type_id 	IN NUMBER   DEFAULT NULL,
  p_subject_id			IN NUMBER   DEFAULT NULL,
  p_subject_parent_id		IN NUMBER   DEFAULT NULL,
  p_object_id			IN NUMBER   DEFAULT NULL,
  p_effective_from		IN DATE     DEFAULT NULL,
  p_effective_to		IN DATE     DEFAULT NULL,
  p_assoc_information_context   IN VARCHAR2 DEFAULT NULL,
  p_assoc_information1          IN VARCHAR2 DEFAULT NULL,
  p_assoc_information2          IN VARCHAR2 DEFAULT NULL,
  p_assoc_information3          IN VARCHAR2 DEFAULT NULL,
  p_assoc_information4          IN VARCHAR2 DEFAULT NULL,
  p_assoc_information5          IN VARCHAR2 DEFAULT NULL,
  p_assoc_information6          IN VARCHAR2 DEFAULT NULL,
  p_assoc_information7          IN VARCHAR2 DEFAULT NULL,
  p_assoc_information8          IN VARCHAR2 DEFAULT NULL,
  p_assoc_information9          IN VARCHAR2 DEFAULT NULL,
  p_assoc_information10         IN VARCHAR2 DEFAULT NULL,
  p_assoc_information11         IN VARCHAR2 DEFAULT NULL,
  p_assoc_information12         IN VARCHAR2 DEFAULT NULL,
  p_assoc_information13         IN VARCHAR2 DEFAULT NULL,
  p_assoc_information14         IN VARCHAR2 DEFAULT NULL,
  p_assoc_information15         IN VARCHAR2 DEFAULT NULL,
  p_assoc_information16         IN VARCHAR2 DEFAULT NULL,
  p_assoc_information17         IN VARCHAR2 DEFAULT NULL,
  p_assoc_information18         IN VARCHAR2 DEFAULT NULL,
  p_assoc_information19         IN VARCHAR2 DEFAULT NULL,
  p_assoc_information20         IN VARCHAR2 DEFAULT NULL,
  p_object_version_number	IN NUMBER   DEFAULT NULL,
  p_last_update_date  		IN DATE     DEFAULT NULL,
  p_last_updated_by 	  	IN NUMBER   DEFAULT NULL,
  p_creation_date 		IN DATE     DEFAULT NULL,
  p_created_by 			IN NUMBER   DEFAULT NULL,
  p_last_update_login 		IN NUMBER   DEFAULT NULL
);

PROCEDURE Update_Row(
  p_association_id		IN NUMBER,
  p_association_type_id 	IN NUMBER   DEFAULT NULL,
  p_subject_id			IN NUMBER   DEFAULT NULL,
  p_subject_parent_id		IN NUMBER   DEFAULT NULL,
  p_object_id			IN NUMBER   DEFAULT NULL,
  p_effective_from		IN DATE     DEFAULT NULL,
  p_effective_to		IN DATE     DEFAULT NULL,
  p_assoc_information_context   IN VARCHAR2 DEFAULT NULL,
  p_assoc_information1          IN VARCHAR2 DEFAULT NULL,
  p_assoc_information2          IN VARCHAR2 DEFAULT NULL,
  p_assoc_information3          IN VARCHAR2 DEFAULT NULL,
  p_assoc_information4          IN VARCHAR2 DEFAULT NULL,
  p_assoc_information5          IN VARCHAR2 DEFAULT NULL,
  p_assoc_information6          IN VARCHAR2 DEFAULT NULL,
  p_assoc_information7          IN VARCHAR2 DEFAULT NULL,
  p_assoc_information8          IN VARCHAR2 DEFAULT NULL,
  p_assoc_information9          IN VARCHAR2 DEFAULT NULL,
  p_assoc_information10         IN VARCHAR2 DEFAULT NULL,
  p_assoc_information11         IN VARCHAR2 DEFAULT NULL,
  p_assoc_information12         IN VARCHAR2 DEFAULT NULL,
  p_assoc_information13         IN VARCHAR2 DEFAULT NULL,
  p_assoc_information14         IN VARCHAR2 DEFAULT NULL,
  p_assoc_information15         IN VARCHAR2 DEFAULT NULL,
  p_assoc_information16         IN VARCHAR2 DEFAULT NULL,
  p_assoc_information17         IN VARCHAR2 DEFAULT NULL,
  p_assoc_information18         IN VARCHAR2 DEFAULT NULL,
  p_assoc_information19         IN VARCHAR2 DEFAULT NULL,
  p_assoc_information20         IN VARCHAR2 DEFAULT NULL,
  p_object_version_number	IN NUMBER   DEFAULT NULL,
  p_last_update_date 		IN DATE     DEFAULT NULL,
  p_last_updated_by 		IN NUMBER   DEFAULT NULL,
  p_last_update_login 		IN NUMBER   DEFAULT NULL
);


PROCEDURE Delete_Row(
  p_association_id              IN NUMBER
);

PROCEDURE Lock_Row(
  p_association_id		IN NUMBER,
  p_object_version_number	IN NUMBER
);


END XLE_Association_PKG;


 

/
