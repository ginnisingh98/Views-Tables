--------------------------------------------------------
--  DDL for Package HZ_TRANSFORMATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_TRANSFORMATIONS_PKG" AUTHID CURRENT_USER as
/*$Header: ARHDTFTS.pls 120.0 2005/08/19 15:54:39 rchanamo noship $ */

PROCEDURE Insert_Row (
    x_transformation_id                          IN  OUT NOCOPY NUMBER,
    x_transformation_name                        IN VARCHAR2,
    x_description                                IN VARCHAR2,
    x_procedure_name				 IN VARCHAR2,
    x_object_version_number			 IN  NUMBER
);

procedure Update_Row (
    x_transformation_id                          IN NUMBER,
    x_transformation_name                        IN VARCHAR2,
    x_description                                IN VARCHAR2,
    x_procedure_name				 IN VARCHAR2,
    x_object_version_number			 IN OUT NOCOPY NUMBER
);

procedure Delete_Row (
  x_transformation_id in NUMBER
);

procedure Lock_Row (
  x_transformation_id in NUMBER,
  x_object_version_number in  NUMBER
);

procedure Add_Language ;

procedure Load_Row (
    x_transformation_id                          IN OUT NOCOPY NUMBER,
    x_transformation_name                        IN VARCHAR2,
    x_description                                IN VARCHAR2,
    x_procedure_name				 IN VARCHAR2,
    x_object_version_number			 IN NUMBER,
    x_last_updated_by				 IN number,
    x_last_update_login				 IN number,
    x_last_update_date				 IN date,
    x_owner                                      IN VARCHAR2,
    x_custom_mode                                IN VARCHAR2
);

procedure Translate_Row (
  x_transformation_id in NUMBER,
  x_transformation_name in VARCHAR2,
  x_description in VARCHAR2,
  x_owner in VARCHAR2);



END HZ_TRANSFORMATIONS_PKG ;

 

/
