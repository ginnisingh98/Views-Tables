--------------------------------------------------------
--  DDL for Package PAY_PYR_RKI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PYR_RKI" AUTHID CURRENT_USER as
/* $Header: pypyrrhi.pkh 120.0 2005/05/29 08:11:24 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< after_insert >-----------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE after_insert
  (p_effective_date               IN DATE
  ,p_rate_id                      IN NUMBER
  ,p_business_group_id            IN NUMBER
  ,p_parent_spine_id              IN NUMBER
  ,p_name                         IN VARCHAR2
  ,p_rate_type                    IN VARCHAR2
  ,p_rate_uom                     IN VARCHAR2
  ,p_comments                     IN VARCHAR2
  ,p_request_id                   IN NUMBER
  ,p_program_application_id       IN NUMBER
  ,p_program_id                   IN NUMBER
  ,p_program_update_date          IN DATE
  ,p_attribute_category           IN VARCHAR2
  ,p_attribute1                   IN VARCHAR2
  ,p_attribute2                   IN VARCHAR2
  ,p_attribute3                   IN VARCHAR2
  ,p_attribute4                   IN VARCHAR2
  ,p_attribute5                   IN VARCHAR2
  ,p_attribute6                   IN VARCHAR2
  ,p_attribute7                   IN VARCHAR2
  ,p_attribute8                   IN VARCHAR2
  ,p_attribute9                   IN VARCHAR2
  ,p_attribute10                  IN VARCHAR2
  ,p_attribute11                  IN VARCHAR2
  ,p_attribute12                  IN VARCHAR2
  ,p_attribute13                  IN VARCHAR2
  ,p_attribute14                  IN VARCHAR2
  ,p_attribute15                  IN VARCHAR2
  ,p_attribute16                  IN VARCHAR2
  ,p_attribute17                  IN VARCHAR2
  ,p_attribute18                  IN VARCHAR2
  ,p_attribute19                  IN VARCHAR2
  ,p_attribute20                  IN VARCHAR2
  ,p_rate_basis                   IN VARCHAR2
  ,p_asg_rate_type                IN VARCHAR2
  ,p_object_version_NUMBER        IN NUMBER
  );
END pay_pyr_rki;

 

/
