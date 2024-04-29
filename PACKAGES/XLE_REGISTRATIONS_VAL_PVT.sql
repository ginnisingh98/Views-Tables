--------------------------------------------------------
--  DDL for Package XLE_REGISTRATIONS_VAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLE_REGISTRATIONS_VAL_PVT" AUTHID CURRENT_USER AS
/* $Header: xleregvs.pls 120.0.12010000.2 2008/08/28 06:48:53 makansal ship $ */

/*-----------------------------------------------------------
This procedure is called from the Creae LE page, Create
Registration for LE page and from Create Registration for
Establishment page.

This procedure validates the Registration Number as per the
validation rules known for a few of the countries.
viz - Argentina, Brazil, Colombia, Chile, Spain,
      Italy, Portugal
------------------------------------------------------------*/
PROCEDURE Validate_Reg_Number(
  p_jurisdiction_id       IN     NUMBER,
  p_registration_id       IN     NUMBER,
  p_registration_number   IN     VARCHAR2,
  p_entity_type           IN     VARCHAR2,
  p_init_msg_list         IN     VARCHAR2,
  x_return_status         IN OUT NOCOPY VARCHAR2,
  x_msg_count             IN OUT NOCOPY NUMBER   ,
  x_msg_data              IN OUT NOCOPY VARCHAR2);

-- Perform Spanish registration number validation
-- as per algorithm
PROCEDURE do_es_regnum_validations(
  p_legislative_cat_code      IN VARCHAR2,
  p_required_flag             IN VARCHAR2,
  p_registration_code         IN VARCHAR2,
  p_registration_number       IN VARCHAR2,
  x_return_status             IN OUT NOCOPY VARCHAR2 ,
  x_msg_data                  IN OUT NOCOPY VARCHAR2 ,
  x_msg_count                 IN OUT NOCOPY NUMBER );


-- Perform Portugeese registration number validation
-- as per algorithm
PROCEDURE do_pt_regnum_validations(
  p_legislative_cat_code      IN VARCHAR2,
  p_required_flag             IN VARCHAR2,
  p_registration_code         IN VARCHAR2,
  p_registration_number       IN VARCHAR2,
  x_return_status             IN OUT NOCOPY VARCHAR2 ,
  x_msg_data                  IN OUT NOCOPY VARCHAR2 ,
  x_msg_count                 IN OUT NOCOPY NUMBER );

-- Perform validation for 11 digit Italian registration
-- number.
procedure PO_VALIDATE_VAT_IT(
  VAT_VALUE			IN  VARCHAR2,
  Xi_UNIQUE_FLAG 		IN VARCHAR2,
  RET_VAR      			OUT NOCOPY VARCHAR2,
  RET_MESSAGE  			OUT NOCOPY VARCHAR2);


-- Perform Italian registration number validation
-- as per algorithm
PROCEDURE do_it_regnum_validations(
  p_legislative_cat_code      IN VARCHAR2,
  p_required_flag             IN VARCHAR2,
  p_registration_code         IN VARCHAR2,
  p_registration_number       IN VARCHAR2,
  x_return_status             IN OUT NOCOPY VARCHAR2 ,
  x_msg_data                  IN OUT NOCOPY VARCHAR2 ,
  x_msg_count                 IN OUT NOCOPY NUMBER );

-- Perform Argentine registration number validation
-- as per algorithm
PROCEDURE do_ar_regnum_validations(
  p_legislative_cat_code      IN VARCHAR2,
  p_required_flag             IN VARCHAR2,
  p_registration_code         IN VARCHAR2,
  p_registration_number       IN VARCHAR2,
  x_return_status             IN OUT NOCOPY VARCHAR2 ,
  x_msg_data                  IN OUT NOCOPY VARCHAR2 ,
  x_msg_count                 IN OUT NOCOPY NUMBER );

-- Perform Chilean registration number validation
-- as per algorithm
PROCEDURE do_cl_regnum_validations(
  p_legislative_cat_code      IN VARCHAR2,
  p_required_flag             IN VARCHAR2,
  p_registration_code         IN VARCHAR2,
  p_registration_number       IN VARCHAR2,
  x_return_status             IN OUT NOCOPY VARCHAR2 ,
  x_msg_data                  IN OUT NOCOPY VARCHAR2 ,
  x_msg_count                 IN OUT NOCOPY NUMBER );


-- Perform Colombian registration number validation
-- as per algorithm
PROCEDURE do_co_regnum_validations(
  p_legislative_cat_code      IN VARCHAR2,
  p_required_flag             IN VARCHAR2,
  p_registration_code         IN VARCHAR2,
  p_registration_number       IN VARCHAR2,
  x_return_status             IN OUT NOCOPY VARCHAR2 ,
  x_msg_data                  IN OUT NOCOPY VARCHAR2 ,
  x_msg_count                 IN OUT NOCOPY NUMBER );

-- Perform Brazilian registration number validation
-- as per algorithm
PROCEDURE do_br_regnum_validations(
  p_legislative_cat_code      IN VARCHAR2,
  p_required_flag             IN VARCHAR2,
  p_registration_code         IN VARCHAR2,
  p_registration_number       IN VARCHAR2,
  x_return_status             IN OUT NOCOPY VARCHAR2 ,
  x_msg_data                  IN OUT NOCOPY VARCHAR2 ,
  x_msg_count                 IN OUT NOCOPY NUMBER );

END XLE_REGISTRATIONS_VAL_PVT;



/
