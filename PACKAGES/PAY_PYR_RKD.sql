--------------------------------------------------------
--  DDL for Package PAY_PYR_RKD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PYR_RKD" AUTHID CURRENT_USER as
/* $Header: pypyrrhi.pkh 120.0 2005/05/29 08:11:24 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_delete >------------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE after_delete
  (p_rate_id                      IN NUMBER
  ,p_business_group_id_o          IN NUMBER
  ,p_parent_spine_id_o            IN NUMBER
  ,p_name_o                       IN VARCHAR2
  ,p_rate_type_o                  IN VARCHAR2
  ,p_rate_uom_o                   IN VARCHAR2
  ,p_comments_o                   IN VARCHAR2
  ,p_request_id_o                 IN NUMBER
  ,p_program_application_id_o     IN NUMBER
  ,p_program_id_o                 IN NUMBER
  ,p_program_update_date_o        IN DATE
  ,p_attribute_category_o         IN VARCHAR2
  ,p_attribute1_o                 IN VARCHAR2
  ,p_attribute2_o                 IN VARCHAR2
  ,p_attribute3_o                 IN VARCHAR2
  ,p_attribute4_o                 IN VARCHAR2
  ,p_attribute5_o                 IN VARCHAR2
  ,p_attribute6_o                 IN VARCHAR2
  ,p_attribute7_o                 IN VARCHAR2
  ,p_attribute8_o                 IN VARCHAR2
  ,p_attribute9_o                 IN VARCHAR2
  ,p_attribute10_o                IN VARCHAR2
  ,p_attribute11_o                IN VARCHAR2
  ,p_attribute12_o                IN VARCHAR2
  ,p_attribute13_o                IN VARCHAR2
  ,p_attribute14_o                IN VARCHAR2
  ,p_attribute15_o                IN VARCHAR2
  ,p_attribute16_o                IN VARCHAR2
  ,p_attribute17_o                IN VARCHAR2
  ,p_attribute18_o                IN VARCHAR2
  ,p_attribute19_o                IN VARCHAR2
  ,p_attribute20_o                IN VARCHAR2
  ,p_rate_basis_o                 IN VARCHAR2
  ,p_asg_rate_type_o              IN VARCHAR2
  ,p_object_version_NUMBER_o      IN NUMBER
  );
--
END pay_pyr_rkd;

 

/
