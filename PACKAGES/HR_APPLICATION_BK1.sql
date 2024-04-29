--------------------------------------------------------
--  DDL for Package HR_APPLICATION_BK1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_APPLICATION_BK1" AUTHID CURRENT_USER as
/* $Header: peaplapi.pkh 120.1 2005/10/02 02:09:51 aroussel $ */
--
-- ---------------------------------------------------------------------------
-- |---------------------< update_apl_details_b >----------------------------|
-- ---------------------------------------------------------------------------
--
procedure update_apl_details_b
  (p_application_id               in      number
  ,p_object_version_number        in      number
  ,p_effective_date               in      date
  ,p_comments                     in      varchar2
  ,p_current_employer             in      varchar2
  ,p_projected_hire_date          in      date
  ,p_termination_reason           in      varchar2
  ,p_appl_attribute_category      in      varchar2
  ,p_appl_attribute1              in      varchar2
  ,p_appl_attribute2              in      varchar2
  ,p_appl_attribute3              in      varchar2
  ,p_appl_attribute4              in      varchar2
  ,p_appl_attribute5              in      varchar2
  ,p_appl_attribute6              in      varchar2
  ,p_appl_attribute7              in      varchar2
  ,p_appl_attribute8              in      varchar2
  ,p_appl_attribute9              in      varchar2
  ,p_appl_attribute10             in      varchar2
  ,p_appl_attribute11             in      varchar2
  ,p_appl_attribute12             in      varchar2
  ,p_appl_attribute13             in      varchar2
  ,p_appl_attribute14             in      varchar2
  ,p_appl_attribute15             in      varchar2
  ,p_appl_attribute16             in      varchar2
  ,p_appl_attribute17             in      varchar2
  ,p_appl_attribute18             in      varchar2
  ,p_appl_attribute19             in      varchar2
  ,p_appl_attribute20             in      varchar2
  );
--
-- ---------------------------------------------------------------------------
-- |---------------------< update_apl_details_a >----------------------------|
-- ---------------------------------------------------------------------------
--
procedure update_apl_details_a
  (p_application_id               in      number
  ,p_object_version_number        in      number
  ,p_effective_date               in      date
  ,p_comments                     in      varchar2
  ,p_current_employer             in      varchar2
  ,p_projected_hire_date          in      date
  ,p_termination_reason           in      varchar2
  ,p_appl_attribute_category      in      varchar2
  ,p_appl_attribute1              in      varchar2
  ,p_appl_attribute2              in      varchar2
  ,p_appl_attribute3              in      varchar2
  ,p_appl_attribute4              in      varchar2
  ,p_appl_attribute5              in      varchar2
  ,p_appl_attribute6              in      varchar2
  ,p_appl_attribute7              in      varchar2
  ,p_appl_attribute8              in      varchar2
  ,p_appl_attribute9              in      varchar2
  ,p_appl_attribute10             in      varchar2
  ,p_appl_attribute11             in      varchar2
  ,p_appl_attribute12             in      varchar2
  ,p_appl_attribute13             in      varchar2
  ,p_appl_attribute14             in      varchar2
  ,p_appl_attribute15             in      varchar2
  ,p_appl_attribute16             in      varchar2
  ,p_appl_attribute17             in      varchar2
  ,p_appl_attribute18             in      varchar2
  ,p_appl_attribute19             in      varchar2
  ,p_appl_attribute20             in      varchar2
  );
end hr_application_bk1;

 

/
