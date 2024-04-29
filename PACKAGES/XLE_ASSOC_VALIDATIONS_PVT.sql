--------------------------------------------------------
--  DDL for Package XLE_ASSOC_VALIDATIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLE_ASSOC_VALIDATIONS_PVT" AUTHID CURRENT_USER AS
/* $Header: xleassvs.pls 120.2 2005/07/27 09:17:12 ttran ship $ */

PROCEDURE Validate_Mandatory (
  p_param_name 	          IN     VARCHAR2,
  p_param_value	          IN     VARCHAR2);

PROCEDURE Validate_Context (
  p_context	          IN     VARCHAR2);

PROCEDURE Validate_Object (
  p_object_type           IN     VARCHAR2,
  p_object_id 	          IN     NUMBER  ,
  p_param1_name	          IN     VARCHAR2,
  p_param2_name	          IN     VARCHAR2,
  x_OBJECT_type_id        OUT NOCOPY   NUMBER  );

PROCEDURE Validate_Association_Id (
    p_association_id      IN     NUMBER,
    p_association_type_id OUT NOCOPY   NUMBER,
    p_subject_id          OUT NOCOPY   NUMBER,
    p_object_id           OUT NOCOPY   NUMBER);

PROCEDURE Default_Association_Type (
  p_context               IN     VARCHAR2,
  p_subject_type          IN     NUMBER  ,
  p_object_type           IN     NUMBER  ,
  x_association_type_id   OUT NOCOPY   NUMBER  );

PROCEDURE Default_Association_Type (
  p_context               IN     VARCHAR2,
  p_subject_type          IN     VARCHAR2,
  p_object_type           IN     VARCHAR2,
  x_association_type_id   OUT NOCOPY   NUMBER  );

PROCEDURE Validate_Cardinality (
  p_association_type_id   IN     NUMBER  ,
  p_subject_type          IN     VARCHAR2,
  p_subject_id            IN     NUMBER  ,
  p_object_type           IN     VARCHAR2,
  p_object_id             IN     NUMBER  );

PROCEDURE Get_Effective_From_Date (
  p_association_id        IN     NUMBER  ,
  p_effective_from        OUT NOCOPY   DATE    );

FUNCTION  Is_date_overlap (
  start_date1 	          IN     DATE    ,
  end_date1	          IN     DATE    ,
  start_date2	          IN     DATE    ,
  end_date2	          IN     DATE    )
RETURN BOOLEAN;

PROCEDURE Validate_Effective_Dates (
  p_association_type_id   IN     NUMBER  ,
  p_effective_from	  IN	 DATE    ,
  p_effective_to          IN     DATE := NULL);

PROCEDURE Validate_Overlap_Dates (
  p_association_id        IN     NUMBER := NULL,
  p_association_type_id   IN     NUMBER,
  p_subject_id            IN     NUMBER  ,
  p_object_id             IN     NUMBER  ,
  p_effective_from	  IN	 DATE    ,
  p_effective_to          IN     DATE  := NULL);

PROCEDURE Get_Parent_Id (
  p_object_type           IN     VARCHAR2,
  p_object_id             IN     NUMBER  ,
  x_object_parent_id      OUT NOCOPY   NUMBER  );

PROCEDURE Validate_Parameter_Combination (
  p_context               IN     VARCHAR2,
  p_subject_type          IN     VARCHAR2,
  p_subject_id 		  IN     NUMBER  ,
  p_object_type           IN     VARCHAR2,
  p_object_id             IN     NUMBER  ,
  x_association_type_id   OUT NOCOPY   NUMBER  );

PROCEDURE Get_Association_Id   (
  p_subject_id	          IN     NUMBER,
  p_object_id             IN     NUMBER,
  p_association_type_id   IN     NUMBER,
  x_association_id        OUT NOCOPY   NUMBER);

PROCEDURE Validate_Intercompany   (
  p_subject_id	           IN     NUMBER,
  p_object_id             IN     NUMBER);

PROCEDURE Validate_Create_Association (
  p_context               IN     VARCHAR2,
  p_subject_type          IN     VARCHAR2,
  p_subject_id 		  IN     NUMBER  ,
  p_object_type           IN     VARCHAR2,
  p_object_id             IN     NUMBER  ,
  p_effective_from        IN     DATE    ,
  p_assoc_information_context IN VARCHAR2,
  p_assoc_information1    IN     VARCHAR2,
  p_assoc_information2    IN     VARCHAR2,
  p_assoc_information3    IN     VARCHAR2,
  p_assoc_information4    IN     VARCHAR2,
  p_assoc_information5    IN     VARCHAR2,
  p_assoc_information6    IN     VARCHAR2,
  p_assoc_information7    IN     VARCHAR2,
  p_assoc_information8    IN     VARCHAR2,
  p_assoc_information9    IN     VARCHAR2,
  p_assoc_information10   IN     VARCHAR2,
  p_assoc_information11   IN     VARCHAR2,
  p_assoc_information12   IN     VARCHAR2,
  p_assoc_information13   IN     VARCHAR2,
  p_assoc_information14   IN     VARCHAR2,
  p_assoc_information15   IN     VARCHAR2,
  p_assoc_information16   IN     VARCHAR2,
  p_assoc_information17   IN     VARCHAR2,
  p_assoc_information18   IN     VARCHAR2,
  p_assoc_information19   IN     VARCHAR2,
  p_assoc_information20   IN     VARCHAR2,
  x_association_type_id   OUT NOCOPY   NUMBER  ,
  x_subject_parent_id     OUT NOCOPY   NUMBER  );

PROCEDURE Validate_Update_Association (
  p_association_id        IN OUT NOCOPY NUMBER,
  p_context               IN     VARCHAR2,
  p_subject_type          IN     VARCHAR2,
  p_subject_id 		  IN     NUMBER  ,
  p_object_type           IN     VARCHAR2,
  p_object_id             IN     NUMBER  ,
  p_effective_from        IN     DATE    ,
  p_effective_to          IN     DATE    ,
  p_assoc_information_context IN VARCHAR2,
  p_assoc_information1    IN     VARCHAR2,
  p_assoc_information2    IN     VARCHAR2,
  p_assoc_information3    IN     VARCHAR2,
  p_assoc_information4    IN     VARCHAR2,
  p_assoc_information5    IN     VARCHAR2,
  p_assoc_information6    IN     VARCHAR2,
  p_assoc_information7    IN     VARCHAR2,
  p_assoc_information8    IN     VARCHAR2,
  p_assoc_information9    IN     VARCHAR2,
  p_assoc_information10   IN     VARCHAR2,
  p_assoc_information11   IN     VARCHAR2,
  p_assoc_information12   IN     VARCHAR2,
  p_assoc_information13   IN     VARCHAR2,
  p_assoc_information14   IN     VARCHAR2,
  p_assoc_information15   IN     VARCHAR2,
  p_assoc_information16   IN     VARCHAR2,
  p_assoc_information17   IN     VARCHAR2,
  p_assoc_information18   IN     VARCHAR2,
  p_assoc_information19   IN     VARCHAR2,
  p_assoc_information20   IN     VARCHAR2);

END XLE_ASSOC_VALIDATIONS_PVT;


 

/
