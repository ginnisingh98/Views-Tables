--------------------------------------------------------
--  DDL for Package PER_SUC_RKU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_SUC_RKU" AUTHID CURRENT_USER AS
/* $Header: pesucrhi.pkh 120.1.12010000.3 2010/02/13 19:33:43 schowdhu ship $ */
--
-- ----------------------------------------------------------------------------
-- |----------------------------< after_update >------------------------------|
-- ----------------------------------------------------------------------------
--
   PROCEDURE after_update (
      p_succession_plan_id          IN   NUMBER,
      p_person_id                   IN   NUMBER,
      p_position_id                 IN   NUMBER,
      p_business_group_id           IN   NUMBER,
      p_start_date                  IN   DATE,
      p_time_scale                  IN   VARCHAR2,
      p_end_date                    IN   DATE,
      p_available_for_promotion     IN   VARCHAR2,
      p_manager_comments            IN   VARCHAR2,
      p_object_version_number       IN   NUMBER,
      p_attribute_category          IN   VARCHAR2,
      p_attribute1                  IN   VARCHAR2,
      p_attribute2                  IN   VARCHAR2,
      p_attribute3                  IN   VARCHAR2,
      p_attribute4                  IN   VARCHAR2,
      p_attribute5                  IN   VARCHAR2,
      p_attribute6                  IN   VARCHAR2,
      p_attribute7                  IN   VARCHAR2,
      p_attribute8                  IN   VARCHAR2,
      p_attribute9                  IN   VARCHAR2,
      p_attribute10                 IN   VARCHAR2,
      p_attribute11                 IN   VARCHAR2,
      p_attribute12                 IN   VARCHAR2,
      p_attribute13                 IN   VARCHAR2,
      p_attribute14                 IN   VARCHAR2,
      p_attribute15                 IN   VARCHAR2,
      p_attribute16                 IN   VARCHAR2,
      p_attribute17                 IN   VARCHAR2,
      p_attribute18                 IN   VARCHAR2,
      p_attribute19                 IN   VARCHAR2,
      p_attribute20                 IN   VARCHAR2,
      p_effective_date              IN   DATE,
      p_job_id                      IN   NUMBER,
      p_successee_person_id         IN   NUMBER,
      p_person_rank                 IN   NUMBER,
      p_performance                 IN   VARCHAR2,
      p_plan_status                 IN   VARCHAR2,
      p_readiness_percentage        IN   NUMBER,
      p_person_id_o                 IN   NUMBER,
      p_position_id_o               IN   NUMBER,
      p_business_group_id_o         IN   NUMBER,
      p_start_date_o                IN   DATE,
      p_time_scale_o                IN   VARCHAR2,
      p_end_date_o                  IN   DATE,
      p_available_for_promotion_o   IN   VARCHAR2,
      p_manager_comments_o          IN   VARCHAR2,
      p_object_version_number_o     IN   NUMBER,
      p_attribute_category_o        IN   VARCHAR2,
      p_attribute1_o                IN   VARCHAR2,
      p_attribute2_o                IN   VARCHAR2,
      p_attribute3_o                IN   VARCHAR2,
      p_attribute4_o                IN   VARCHAR2,
      p_attribute5_o                IN   VARCHAR2,
      p_attribute6_o                IN   VARCHAR2,
      p_attribute7_o                IN   VARCHAR2,
      p_attribute8_o                IN   VARCHAR2,
      p_attribute9_o                IN   VARCHAR2,
      p_attribute10_o               IN   VARCHAR2,
      p_attribute11_o               IN   VARCHAR2,
      p_attribute12_o               IN   VARCHAR2,
      p_attribute13_o               IN   VARCHAR2,
      p_attribute14_o               IN   VARCHAR2,
      p_attribute15_o               IN   VARCHAR2,
      p_attribute16_o               IN   VARCHAR2,
      p_attribute17_o               IN   VARCHAR2,
      p_attribute18_o               IN   VARCHAR2,
      p_attribute19_o               IN   VARCHAR2,
      p_attribute20_o               IN   VARCHAR2,
      p_job_id_o                    IN   NUMBER,
      p_successee_person_id_o       IN   NUMBER,
      p_person_rank_o               IN   NUMBER,
      p_performance_o               IN   VARCHAR2,
      p_plan_status_o               IN   VARCHAR2,
      p_readiness_percentage_o      IN   NUMBER
   );
--
END per_suc_rku;

/
