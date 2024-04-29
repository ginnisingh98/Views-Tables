--------------------------------------------------------
--  DDL for Package HR_RATE_API_BK5
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_RATE_API_BK5" AUTHID CURRENT_USER AS
/* $Header: pypyrapi.pkh 120.1 2005/10/02 02:34:02 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_assignment_rate_b >----------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE update_assignment_rate_b
  (p_rate_id                       IN     NUMBER
  ,p_object_version_number         IN     NUMBER
  ,p_effective_date                IN     DATE
  ,p_name                          IN     VARCHAR2
  ,p_rate_basis                    IN     VARCHAR2
  ,p_asg_rate_type                 IN     VARCHAR2
  ,p_attribute_category            IN     VARCHAR2
  ,p_attribute1                    IN     VARCHAR2
  ,p_attribute2                    IN     VARCHAR2
  ,p_attribute3                    IN     VARCHAR2
  ,p_attribute4                    IN     VARCHAR2
  ,p_attribute5                    IN     VARCHAR2
  ,p_attribute6                    IN     VARCHAR2
  ,p_attribute7                    IN     VARCHAR2
  ,p_attribute8                    IN     VARCHAR2
  ,p_attribute9                    IN     VARCHAR2
  ,p_attribute10                   IN     VARCHAR2
  ,p_attribute11                   IN     VARCHAR2
  ,p_attribute12                   IN     VARCHAR2
  ,p_attribute13                   IN     VARCHAR2
  ,p_attribute14                   IN     VARCHAR2
  ,p_attribute15                   IN     VARCHAR2
  ,p_attribute16                   IN     VARCHAR2
  ,p_attribute17                   IN     VARCHAR2
  ,p_attribute18                   IN     VARCHAR2
  ,p_attribute19                   IN     VARCHAR2
  ,p_attribute20                   IN     VARCHAR2 );
--
-- ----------------------------------------------------------------------------
-- |----------------------< update_assignment_rate_a >------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE update_assignment_rate_a
  (p_rate_id                       IN     NUMBER
  ,p_object_version_number         IN     NUMBER
  ,p_effective_date                IN     DATE
  ,p_name                          IN     VARCHAR2
  ,p_rate_basis                    IN     VARCHAR2
  ,p_asg_rate_type                 IN     VARCHAR2
  ,p_attribute_category            IN     VARCHAR2
  ,p_attribute1                    IN     VARCHAR2
  ,p_attribute2                    IN     VARCHAR2
  ,p_attribute3                    IN     VARCHAR2
  ,p_attribute4                    IN     VARCHAR2
  ,p_attribute5                    IN     VARCHAR2
  ,p_attribute6                    IN     VARCHAR2
  ,p_attribute7                    IN     VARCHAR2
  ,p_attribute8                    IN     VARCHAR2
  ,p_attribute9                    IN     VARCHAR2
  ,p_attribute10                   IN     VARCHAR2
  ,p_attribute11                   IN     VARCHAR2
  ,p_attribute12                   IN     VARCHAR2
  ,p_attribute13                   IN     VARCHAR2
  ,p_attribute14                   IN     VARCHAR2
  ,p_attribute15                   IN     VARCHAR2
  ,p_attribute16                   IN     VARCHAR2
  ,p_attribute17                   IN     VARCHAR2
  ,p_attribute18                   IN     VARCHAR2
  ,p_attribute19                   IN     VARCHAR2
  ,p_attribute20                   IN     VARCHAR2 );
--
END hr_rate_api_bk5;

 

/
