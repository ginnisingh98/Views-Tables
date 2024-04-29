--------------------------------------------------------
--  DDL for Package Body IRC_ISC_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_ISC_UPD" as
/* $Header: iriscrhi.pkb 120.0 2005/07/26 15:11:17 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  irc_isc_upd.';  -- Global package name
g_description boolean;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml update logic. The processing of
--   this procedure is:
--   1) Increment the object_version_number by 1 if the object_version_number
--      is defined as an attribute for this entity.
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To update the specified row in the schema using the primary key in
--      the predicates.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the upd
--   procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be updated in the schema.
--
-- Post Failure:
--   On the update dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   The update 'set' attribute list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_dml
  (p_rec in out nocopy irc_isc_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_dml';
  l_description  clob;
  l_geometry mdsys.sdo_geometry:=null;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Increment the object version
  p_rec.object_version_number := p_rec.object_version_number + 1;
  --
  if p_rec.longitude is not null and p_rec.latitude is not null then
     l_geometry:=mdsys.sdo_geometry(2001,8307
          ,mdsys.sdo_point_type(p_rec.longitude,p_rec.latitude,null),null,null);
  end if;
  --
  irc_isc_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the irc_search_criteria Row
  --
  update irc_search_criteria
    set
     search_criteria_id              = p_rec.search_criteria_id
    ,object_id                       = p_rec.object_id
    ,object_type                     = p_rec.object_type
    ,search_name                     = p_rec.search_name
    ,search_type                     = p_rec.search_type
    ,location                        = p_rec.location
    ,distance_to_location            = p_rec.distance_to_location
    ,geocode_location                = p_rec.geocode_location
    ,geocode_country                 = p_rec.geocode_country
    ,derived_location                = p_rec.derived_location
    ,location_id                     = p_rec.location_id
    ,geometry                        = l_geometry
    ,employee                        = p_rec.employee
    ,contractor                      = p_rec.contractor
    ,employment_category             = p_rec.employment_category
    ,keywords                        = p_rec.keywords
    ,travel_percentage               = p_rec.travel_percentage
    ,min_salary                      = p_rec.min_salary
    ,max_salary                      = p_rec.max_salary
    ,salary_currency                 = p_rec.salary_currency
    ,salary_period                   = p_rec.salary_period
    ,match_competence                = p_rec.match_competence
    ,match_qualification             = p_rec.match_qualification
    ,job_title                       = p_rec.job_title
    ,department                      = p_rec.department
    ,professional_area               = p_rec.professional_area
    ,work_at_home                    = p_rec.work_at_home
    ,min_qual_level                  = p_rec.min_qual_level
    ,max_qual_level                  = p_rec.max_qual_level
    ,use_for_matching                = p_rec.use_for_matching
    ,attribute_category              = p_rec.attribute_category
    ,attribute1                      = p_rec.attribute1
    ,attribute2                      = p_rec.attribute2
    ,attribute3                      = p_rec.attribute3
    ,attribute4                      = p_rec.attribute4
    ,attribute5                      = p_rec.attribute5
    ,attribute6                      = p_rec.attribute6
    ,attribute7                      = p_rec.attribute7
    ,attribute8                      = p_rec.attribute8
    ,attribute9                      = p_rec.attribute9
    ,attribute10                     = p_rec.attribute10
    ,attribute11                     = p_rec.attribute11
    ,attribute12                     = p_rec.attribute12
    ,attribute13                     = p_rec.attribute13
    ,attribute14                     = p_rec.attribute14
    ,attribute15                     = p_rec.attribute15
    ,attribute16                     = p_rec.attribute16
    ,attribute17                     = p_rec.attribute17
    ,attribute18                     = p_rec.attribute18
    ,attribute19                     = p_rec.attribute19
    ,attribute20                     = p_rec.attribute20
    ,attribute21                     = p_rec.attribute21
    ,attribute22                     = p_rec.attribute22
    ,attribute23                     = p_rec.attribute23
    ,attribute24                     = p_rec.attribute24
    ,attribute25                     = p_rec.attribute25
    ,attribute26                     = p_rec.attribute26
    ,attribute27                     = p_rec.attribute27
    ,attribute28                     = p_rec.attribute28
    ,attribute29                     = p_rec.attribute29
    ,attribute30                     = p_rec.attribute30
    ,isc_information_category        = p_rec.isc_information_category
    ,isc_information1                = p_rec.isc_information1
    ,isc_information2                = p_rec.isc_information2
    ,isc_information3                = p_rec.isc_information3
    ,isc_information4                = p_rec.isc_information4
    ,isc_information5                = p_rec.isc_information5
    ,isc_information6                = p_rec.isc_information6
    ,isc_information7                = p_rec.isc_information7
    ,isc_information8                = p_rec.isc_information8
    ,isc_information9                = p_rec.isc_information9
    ,isc_information10               = p_rec.isc_information10
    ,isc_information11               = p_rec.isc_information11
    ,isc_information12               = p_rec.isc_information12
    ,isc_information13               = p_rec.isc_information13
    ,isc_information14               = p_rec.isc_information14
    ,isc_information15               = p_rec.isc_information15
    ,isc_information16               = p_rec.isc_information16
    ,isc_information17               = p_rec.isc_information17
    ,isc_information18               = p_rec.isc_information18
    ,isc_information19               = p_rec.isc_information19
    ,isc_information20               = p_rec.isc_information20
    ,isc_information21               = p_rec.isc_information21
    ,isc_information22               = p_rec.isc_information22
    ,isc_information23               = p_rec.isc_information23
    ,isc_information24               = p_rec.isc_information24
    ,isc_information25               = p_rec.isc_information25
    ,isc_information26               = p_rec.isc_information26
    ,isc_information27               = p_rec.isc_information27
    ,isc_information28               = p_rec.isc_information28
    ,isc_information29               = p_rec.isc_information29
    ,isc_information30               = p_rec.isc_information30
    ,object_version_number           = p_rec.object_version_number
    ,date_posted                     = p_rec.date_posted
    where search_criteria_id = p_rec.search_criteria_id
    returning description into l_description;
  --
    if (g_description
       and dbms_lob.getlength(l_description)<=32767
       and dbms_lob.instr(l_description,p_rec.description)<>1)
    then
      hr_utility.set_location(l_proc, 10);
      dbms_lob.trim(l_description,0);
      dbms_lob.write(l_description
                    ,length(p_rec.description)
                    ,1
                    ,p_rec.description);
    end if;
  --
  irc_isc_shd.g_api_dml := false;  -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    irc_isc_shd.g_api_dml := false;  -- Unset the api dml status
    --
    irc_isc_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    irc_isc_shd.g_api_dml := false;  -- Unset the api dml status
    --
    irc_isc_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    irc_isc_shd.g_api_dml := false;  -- Unset the api dml status
    --
    irc_isc_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
   irc_isc_shd.g_api_dml := false;  -- Unset the api dml status
    --
    Raise;
End update_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_update >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the update dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the upd procedure.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception wil be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any pre-processing required before the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_update
  (p_rec in irc_isc_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'pre_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_update >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after
--   the update dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the upd procedure.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any post-processing required after the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_update
  (p_effective_date               in date
  ,p_rec                          in irc_isc_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    irc_isc_rku.after_update
      (p_effective_date              => p_effective_date
      ,p_search_criteria_id
      => p_rec.search_criteria_id
      ,p_object_id
      => p_rec.object_id
      ,p_object_type
      => p_rec.object_type
      ,p_search_name
      => p_rec.search_name
      ,p_search_type
      => p_rec.search_type
      ,p_location
      => p_rec.location
      ,p_distance_to_location
      => p_rec.distance_to_location
      ,p_geocode_location
      =>p_rec.geocode_location
      ,p_geocode_country
      =>p_rec.geocode_country
      ,p_derived_location
      =>p_rec.derived_location
      ,p_location_id
      =>p_rec.location_id
      ,p_longitude
      =>p_rec.longitude
      ,p_latitude
      =>p_rec.latitude
      ,p_employee
      => p_rec.employee
      ,p_contractor
      => p_rec.contractor
      ,p_employment_category
      => p_rec.employment_category
      ,p_keywords
      => p_rec.keywords
      ,p_travel_percentage
      => p_rec.travel_percentage
      ,p_min_salary
      => p_rec.min_salary
      ,p_max_salary
      => p_rec.max_salary
      ,p_salary_currency
      => p_rec.salary_currency
      ,p_salary_period
      => p_rec.salary_period
      ,p_match_competence
      => p_rec.match_competence
      ,p_match_qualification
      => p_rec.match_qualification
      ,p_job_title
      => p_rec.job_title
      ,p_department
      => p_rec.department
      ,p_professional_area
      => p_rec.professional_area
      ,p_work_at_home
      => p_rec.work_at_home
      ,p_min_qual_level
      => p_rec.min_qual_level
      ,p_max_qual_level
      => p_rec.max_qual_level
      ,p_use_for_matching
      => p_rec.use_for_matching
      ,p_description
      => p_rec.description
      ,p_attribute_category
      => p_rec.attribute_category
      ,p_attribute1
      => p_rec.attribute1
      ,p_attribute2
      => p_rec.attribute2
      ,p_attribute3
      => p_rec.attribute3
      ,p_attribute4
      => p_rec.attribute4
      ,p_attribute5
      => p_rec.attribute5
      ,p_attribute6
      => p_rec.attribute6
      ,p_attribute7
      => p_rec.attribute7
      ,p_attribute8
      => p_rec.attribute8
      ,p_attribute9
      => p_rec.attribute9
      ,p_attribute10
      => p_rec.attribute10
      ,p_attribute11
      => p_rec.attribute11
      ,p_attribute12
      => p_rec.attribute12
      ,p_attribute13
      => p_rec.attribute13
      ,p_attribute14
      => p_rec.attribute14
      ,p_attribute15
      => p_rec.attribute15
      ,p_attribute16
      => p_rec.attribute16
      ,p_attribute17
      => p_rec.attribute17
      ,p_attribute18
      => p_rec.attribute18
      ,p_attribute19
      => p_rec.attribute19
      ,p_attribute20
      => p_rec.attribute20
      ,p_attribute21
      => p_rec.attribute21
      ,p_attribute22
      => p_rec.attribute22
      ,p_attribute23
      => p_rec.attribute23
      ,p_attribute24
      => p_rec.attribute24
      ,p_attribute25
      => p_rec.attribute25
      ,p_attribute26
      => p_rec.attribute26
      ,p_attribute27
      => p_rec.attribute27
      ,p_attribute28
      => p_rec.attribute28
      ,p_attribute29
      => p_rec.attribute29
      ,p_attribute30
      => p_rec.attribute30
      ,p_isc_information_category
      => p_rec.isc_information_category
      ,p_isc_information1
      => p_rec.isc_information1
      ,p_isc_information2
      => p_rec.isc_information2
      ,p_isc_information3
      => p_rec.isc_information3
      ,p_isc_information4
      => p_rec.isc_information4
      ,p_isc_information5
      => p_rec.isc_information5
      ,p_isc_information6
      => p_rec.isc_information6
      ,p_isc_information7
      => p_rec.isc_information7
      ,p_isc_information8
      => p_rec.isc_information8
      ,p_isc_information9
      => p_rec.isc_information9
      ,p_isc_information10
      => p_rec.isc_information10
      ,p_isc_information11
      => p_rec.isc_information11
      ,p_isc_information12
      => p_rec.isc_information12
      ,p_isc_information13
      => p_rec.isc_information13
      ,p_isc_information14
      => p_rec.isc_information14
      ,p_isc_information15
      => p_rec.isc_information15
      ,p_isc_information16
      => p_rec.isc_information16
      ,p_isc_information17
      => p_rec.isc_information17
      ,p_isc_information18
      => p_rec.isc_information18
      ,p_isc_information19
      => p_rec.isc_information19
      ,p_isc_information20
      => p_rec.isc_information20
      ,p_isc_information21
      => p_rec.isc_information21
      ,p_isc_information22
      => p_rec.isc_information22
      ,p_isc_information23
      => p_rec.isc_information23
      ,p_isc_information24
      => p_rec.isc_information24
      ,p_isc_information25
      => p_rec.isc_information25
      ,p_isc_information26
      => p_rec.isc_information26
      ,p_isc_information27
      => p_rec.isc_information27
      ,p_isc_information28
      => p_rec.isc_information28
      ,p_isc_information29
      => p_rec.isc_information29
      ,p_isc_information30
      => p_rec.isc_information30
      ,p_object_version_number
      => p_rec.object_version_number
      ,p_date_posted
      => p_rec.date_posted
      ,p_object_id_o
      => irc_isc_shd.g_old_rec.object_id
      ,p_object_type_o
      => irc_isc_shd.g_old_rec.object_type
      ,p_search_name_o
      => irc_isc_shd.g_old_rec.search_name
      ,p_search_type_o
      => irc_isc_shd.g_old_rec.search_type
      ,p_location_o
      => irc_isc_shd.g_old_rec.location
      ,p_distance_to_location_o
      => irc_isc_shd.g_old_rec.distance_to_location
      ,p_geocode_location_o
      =>irc_isc_shd.g_old_rec.geocode_location
      ,p_geocode_country_o
      =>irc_isc_shd.g_old_rec.geocode_country
      ,p_derived_location_o
      =>irc_isc_shd.g_old_rec.derived_location
      ,p_location_id_o
      =>irc_isc_shd.g_old_rec.location_id
      ,p_longitude_o
      =>irc_isc_shd.g_old_rec.longitude
      ,p_latitude_o
      =>irc_isc_shd.g_old_rec.latitude
      ,p_employee_o
      => irc_isc_shd.g_old_rec.employee
      ,p_contractor_o
      => irc_isc_shd.g_old_rec.contractor
      ,p_employment_category_o
      => irc_isc_shd.g_old_rec.employment_category
      ,p_keywords_o
      => irc_isc_shd.g_old_rec.keywords
      ,p_travel_percentage_o
      => irc_isc_shd.g_old_rec.travel_percentage
      ,p_min_salary_o
      => irc_isc_shd.g_old_rec.min_salary
      ,p_max_salary_o
      => irc_isc_shd.g_old_rec.max_salary
      ,p_salary_currency_o
      => irc_isc_shd.g_old_rec.salary_currency
      ,p_salary_period_o
      => irc_isc_shd.g_old_rec.salary_period
      ,p_match_competence_o
      => irc_isc_shd.g_old_rec.match_competence
      ,p_match_qualification_o
      => irc_isc_shd.g_old_rec.match_qualification
      ,p_job_title_o
      => irc_isc_shd.g_old_rec.job_title
      ,p_department_o
      => irc_isc_shd.g_old_rec.department
      ,p_professional_area_o
      => irc_isc_shd.g_old_rec.professional_area
      ,p_work_at_home_o
      => irc_isc_shd.g_old_rec.work_at_home
      ,p_min_qual_level_o
      => irc_isc_shd.g_old_rec.min_qual_level
      ,p_max_qual_level_o
      => irc_isc_shd.g_old_rec.max_qual_level
      ,p_use_for_matching_o
      => irc_isc_shd.g_old_rec.use_for_matching
      ,p_description_o
      => irc_isc_shd.g_old_rec.description
      ,p_attribute_category_o
      => irc_isc_shd.g_old_rec.attribute_category
      ,p_attribute1_o
      => irc_isc_shd.g_old_rec.attribute1
      ,p_attribute2_o
      => irc_isc_shd.g_old_rec.attribute2
      ,p_attribute3_o
      => irc_isc_shd.g_old_rec.attribute3
      ,p_attribute4_o
      => irc_isc_shd.g_old_rec.attribute4
      ,p_attribute5_o
      => irc_isc_shd.g_old_rec.attribute5
      ,p_attribute6_o
      => irc_isc_shd.g_old_rec.attribute6
      ,p_attribute7_o
      => irc_isc_shd.g_old_rec.attribute7
      ,p_attribute8_o
      => irc_isc_shd.g_old_rec.attribute8
      ,p_attribute9_o
      => irc_isc_shd.g_old_rec.attribute9
      ,p_attribute10_o
      => irc_isc_shd.g_old_rec.attribute10
      ,p_attribute11_o
      => irc_isc_shd.g_old_rec.attribute11
      ,p_attribute12_o
      => irc_isc_shd.g_old_rec.attribute12
      ,p_attribute13_o
      => irc_isc_shd.g_old_rec.attribute13
      ,p_attribute14_o
      => irc_isc_shd.g_old_rec.attribute14
      ,p_attribute15_o
      => irc_isc_shd.g_old_rec.attribute15
      ,p_attribute16_o
      => irc_isc_shd.g_old_rec.attribute16
      ,p_attribute17_o
      => irc_isc_shd.g_old_rec.attribute17
      ,p_attribute18_o
      => irc_isc_shd.g_old_rec.attribute18
      ,p_attribute19_o
      => irc_isc_shd.g_old_rec.attribute19
      ,p_attribute20_o
      => irc_isc_shd.g_old_rec.attribute20
      ,p_attribute21_o
      => irc_isc_shd.g_old_rec.attribute21
      ,p_attribute22_o
      => irc_isc_shd.g_old_rec.attribute22
      ,p_attribute23_o
      => irc_isc_shd.g_old_rec.attribute23
      ,p_attribute24_o
      => irc_isc_shd.g_old_rec.attribute24
      ,p_attribute25_o
      => irc_isc_shd.g_old_rec.attribute25
      ,p_attribute26_o
      => irc_isc_shd.g_old_rec.attribute26
      ,p_attribute27_o
      => irc_isc_shd.g_old_rec.attribute27
      ,p_attribute28_o
      => irc_isc_shd.g_old_rec.attribute28
      ,p_attribute29_o
      => irc_isc_shd.g_old_rec.attribute29
      ,p_attribute30_o
      => irc_isc_shd.g_old_rec.attribute30
      ,p_isc_information_category_o
      => irc_isc_shd.g_old_rec.isc_information_category
      ,p_isc_information1_o
      => irc_isc_shd.g_old_rec.isc_information1
      ,p_isc_information2_o
      => irc_isc_shd.g_old_rec.isc_information2
      ,p_isc_information3_o
      => irc_isc_shd.g_old_rec.isc_information3
      ,p_isc_information4_o
      => irc_isc_shd.g_old_rec.isc_information4
      ,p_isc_information5_o
      => irc_isc_shd.g_old_rec.isc_information5
      ,p_isc_information6_o
      => irc_isc_shd.g_old_rec.isc_information6
      ,p_isc_information7_o
      => irc_isc_shd.g_old_rec.isc_information7
      ,p_isc_information8_o
      => irc_isc_shd.g_old_rec.isc_information8
      ,p_isc_information9_o
      => irc_isc_shd.g_old_rec.isc_information9
      ,p_isc_information10_o
      => irc_isc_shd.g_old_rec.isc_information10
      ,p_isc_information11_o
      => irc_isc_shd.g_old_rec.isc_information11
      ,p_isc_information12_o
      => irc_isc_shd.g_old_rec.isc_information12
      ,p_isc_information13_o
      => irc_isc_shd.g_old_rec.isc_information13
      ,p_isc_information14_o
      => irc_isc_shd.g_old_rec.isc_information14
      ,p_isc_information15_o
      => irc_isc_shd.g_old_rec.isc_information15
      ,p_isc_information16_o
      => irc_isc_shd.g_old_rec.isc_information16
      ,p_isc_information17_o
      => irc_isc_shd.g_old_rec.isc_information17
      ,p_isc_information18_o
      => irc_isc_shd.g_old_rec.isc_information18
      ,p_isc_information19_o
      => irc_isc_shd.g_old_rec.isc_information19
      ,p_isc_information20_o
      => irc_isc_shd.g_old_rec.isc_information20
      ,p_isc_information21_o
      => irc_isc_shd.g_old_rec.isc_information21
      ,p_isc_information22_o
      => irc_isc_shd.g_old_rec.isc_information22
      ,p_isc_information23_o
      => irc_isc_shd.g_old_rec.isc_information23
      ,p_isc_information24_o
      => irc_isc_shd.g_old_rec.isc_information24
      ,p_isc_information25_o
      => irc_isc_shd.g_old_rec.isc_information25
      ,p_isc_information26_o
      => irc_isc_shd.g_old_rec.isc_information26
      ,p_isc_information27_o
      => irc_isc_shd.g_old_rec.isc_information27
      ,p_isc_information28_o
      => irc_isc_shd.g_old_rec.isc_information28
      ,p_isc_information29_o
      => irc_isc_shd.g_old_rec.isc_information29
      ,p_isc_information30_o
      => irc_isc_shd.g_old_rec.isc_information30
      ,p_object_version_number_o
      => irc_isc_shd.g_old_rec.object_version_number
      ,p_date_posted_o
      => irc_isc_shd.g_old_rec.date_posted
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'IRC_SEARCH_CRITERIA'
        ,p_hook_type   => 'AU');
      --
  end;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_defs >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The Convert_Defs procedure has one very important function:
--   It must return the record structure for the row with all system defaulted
--   values converted into its corresponding parameter value for update. When
--   we attempt to update a row through the Upd process , certain
--   parameters can be defaulted which enables flexibility in the calling of
--   the upd process (e.g. only attributes which need to be updated need to be
--   specified). For the upd process to determine which attributes
--   have NOT been specified we need to check if the parameter has a reserved
--   system default value. Therefore, for all parameters which have a
--   corresponding reserved system default mechanism specified we need to
--   check if a system default is being used. If a system default is being
--   used then we convert the defaulted value into its corresponding attribute
--   value held in the g_old_rec data structure.
--
-- Prerequisites:
--   This private function can only be called from the upd process.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   The record structure will be returned with all system defaulted parameter
--   values converted into its current row attribute value.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this procedure will be a PL/SQL value error due to
--   conversion of datatypes or data lengths.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure convert_defs
  (p_rec in out nocopy irc_isc_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.object_id = hr_api.g_number) then
    p_rec.object_id :=
    irc_isc_shd.g_old_rec.object_id;
  End If;
  If (p_rec.object_type = hr_api.g_varchar2) then
    p_rec.object_type :=
    irc_isc_shd.g_old_rec.object_type;
  End If;
  If (p_rec.search_name = hr_api.g_varchar2) then
    p_rec.search_name :=
    irc_isc_shd.g_old_rec.search_name;
  End If;
  If (p_rec.search_type = hr_api.g_varchar2) then
    p_rec.search_type :=
    irc_isc_shd.g_old_rec.search_type;
  End If;
  If (p_rec.location = hr_api.g_varchar2) then
    p_rec.location :=
    irc_isc_shd.g_old_rec.location;
  End If;
  If (p_rec.distance_to_location = hr_api.g_varchar2) then
    p_rec.distance_to_location :=
    irc_isc_shd.g_old_rec.distance_to_location;
  End If;
  If (p_rec.geocode_location = hr_api.g_varchar2) then
    p_rec.geocode_location :=
    irc_isc_shd.g_old_rec.geocode_location;
  End If;
  If (p_rec.geocode_country = hr_api.g_varchar2) then
    p_rec.geocode_country :=
    irc_isc_shd.g_old_rec.geocode_country;
  End If;
  If (p_rec.derived_location = hr_api.g_varchar2) then
    p_rec.derived_location :=
    irc_isc_shd.g_old_rec.derived_location;
  End If;
  If (p_rec.location_id = hr_api.g_number) then
    p_rec.location_id :=
    irc_isc_shd.g_old_rec.location_id;
  End If;
  If (p_rec.longitude = hr_api.g_number) then
    p_rec.longitude :=
    irc_isc_shd.g_old_rec.longitude;
  End If;
  If (p_rec.latitude = hr_api.g_number) then
    p_rec.latitude :=
    irc_isc_shd.g_old_rec.latitude;
  End If;
  If (p_rec.employee = hr_api.g_varchar2) then
    p_rec.employee :=
    irc_isc_shd.g_old_rec.employee;
  End If;
  If (p_rec.contractor = hr_api.g_varchar2) then
    p_rec.contractor :=
    irc_isc_shd.g_old_rec.contractor;
  End If;
  If (p_rec.employment_category = hr_api.g_varchar2) then
    p_rec.employment_category :=
    irc_isc_shd.g_old_rec.employment_category;
  End If;
  If (p_rec.keywords = hr_api.g_varchar2) then
    p_rec.keywords :=
    irc_isc_shd.g_old_rec.keywords;
  End If;
  If (p_rec.travel_percentage = hr_api.g_number) then
    p_rec.travel_percentage :=
    irc_isc_shd.g_old_rec.travel_percentage;
  End If;
  If (p_rec.min_salary = hr_api.g_number) then
    p_rec.min_salary :=
    irc_isc_shd.g_old_rec.min_salary;
  End If;
  If (p_rec.max_salary = hr_api.g_number) then
    p_rec.max_salary :=
    irc_isc_shd.g_old_rec.max_salary;
  End If;
  If (p_rec.salary_currency = hr_api.g_varchar2) then
    p_rec.salary_currency :=
    irc_isc_shd.g_old_rec.salary_currency;
  End If;
  If (p_rec.salary_period = hr_api.g_varchar2) then
    p_rec.salary_period :=
    irc_isc_shd.g_old_rec.salary_period;
  End If;
  If (p_rec.match_competence = hr_api.g_varchar2) then
    p_rec.match_competence :=
    irc_isc_shd.g_old_rec.match_competence;
  End If;
  If (p_rec.match_qualification = hr_api.g_varchar2) then
    p_rec.match_qualification :=
    irc_isc_shd.g_old_rec.match_qualification;
  End If;
  If (p_rec.job_title = hr_api.g_varchar2) then
    p_rec.job_title :=
    irc_isc_shd.g_old_rec.job_title;
  End If;
  If (p_rec.department = hr_api.g_varchar2) then
    p_rec.department :=
    irc_isc_shd.g_old_rec.department;
  End If;
  If (p_rec.professional_area = hr_api.g_varchar2) then
    p_rec.professional_area :=
    irc_isc_shd.g_old_rec.professional_area;
  End If;
  If (p_rec.work_at_home = hr_api.g_varchar2) then
    p_rec.work_at_home :=
    irc_isc_shd.g_old_rec.work_at_home;
  End If;
  If (p_rec.min_qual_level = hr_api.g_number) then
    p_rec.min_qual_level :=
    irc_isc_shd.g_old_rec.min_qual_level;
  End If;
  If (p_rec.max_qual_level = hr_api.g_number) then
    p_rec.max_qual_level :=
    irc_isc_shd.g_old_rec.max_qual_level;
  End If;
  If (p_rec.use_for_matching = hr_api.g_varchar2) then
    p_rec.use_for_matching :=
    irc_isc_shd.g_old_rec.use_for_matching;
  End If;
  If (p_rec.description = hr_api.g_varchar2) then
    p_rec.description :=
    irc_isc_shd.g_old_rec.description;
    g_description:=false;
  Else
    g_description:=true;
  End If;
  If (p_rec.attribute_category = hr_api.g_varchar2) then
    p_rec.attribute_category :=
    irc_isc_shd.g_old_rec.attribute_category;
  End If;
  If (p_rec.attribute1 = hr_api.g_varchar2) then
    p_rec.attribute1 :=
    irc_isc_shd.g_old_rec.attribute1;
  End If;
  If (p_rec.attribute2 = hr_api.g_varchar2) then
    p_rec.attribute2 :=
    irc_isc_shd.g_old_rec.attribute2;
  End If;
  If (p_rec.attribute3 = hr_api.g_varchar2) then
    p_rec.attribute3 :=
    irc_isc_shd.g_old_rec.attribute3;
  End If;
  If (p_rec.attribute4 = hr_api.g_varchar2) then
    p_rec.attribute4 :=
    irc_isc_shd.g_old_rec.attribute4;
  End If;
  If (p_rec.attribute5 = hr_api.g_varchar2) then
    p_rec.attribute5 :=
    irc_isc_shd.g_old_rec.attribute5;
  End If;
  If (p_rec.attribute6 = hr_api.g_varchar2) then
    p_rec.attribute6 :=
    irc_isc_shd.g_old_rec.attribute6;
  End If;
  If (p_rec.attribute7 = hr_api.g_varchar2) then
    p_rec.attribute7 :=
    irc_isc_shd.g_old_rec.attribute7;
  End If;
  If (p_rec.attribute8 = hr_api.g_varchar2) then
    p_rec.attribute8 :=
    irc_isc_shd.g_old_rec.attribute8;
  End If;
  If (p_rec.attribute9 = hr_api.g_varchar2) then
    p_rec.attribute9 :=
    irc_isc_shd.g_old_rec.attribute9;
  End If;
  If (p_rec.attribute10 = hr_api.g_varchar2) then
    p_rec.attribute10 :=
    irc_isc_shd.g_old_rec.attribute10;
  End If;
  If (p_rec.attribute11 = hr_api.g_varchar2) then
    p_rec.attribute11 :=
    irc_isc_shd.g_old_rec.attribute11;
  End If;
  If (p_rec.attribute12 = hr_api.g_varchar2) then
    p_rec.attribute12 :=
    irc_isc_shd.g_old_rec.attribute12;
  End If;
  If (p_rec.attribute13 = hr_api.g_varchar2) then
    p_rec.attribute13 :=
    irc_isc_shd.g_old_rec.attribute13;
  End If;
  If (p_rec.attribute14 = hr_api.g_varchar2) then
    p_rec.attribute14 :=
    irc_isc_shd.g_old_rec.attribute14;
  End If;
  If (p_rec.attribute15 = hr_api.g_varchar2) then
    p_rec.attribute15 :=
    irc_isc_shd.g_old_rec.attribute15;
  End If;
  If (p_rec.attribute16 = hr_api.g_varchar2) then
    p_rec.attribute16 :=
    irc_isc_shd.g_old_rec.attribute16;
  End If;
  If (p_rec.attribute17 = hr_api.g_varchar2) then
    p_rec.attribute17 :=
    irc_isc_shd.g_old_rec.attribute17;
  End If;
  If (p_rec.attribute18 = hr_api.g_varchar2) then
    p_rec.attribute18 :=
    irc_isc_shd.g_old_rec.attribute18;
  End If;
  If (p_rec.attribute19 = hr_api.g_varchar2) then
    p_rec.attribute19 :=
    irc_isc_shd.g_old_rec.attribute19;
  End If;
  If (p_rec.attribute20 = hr_api.g_varchar2) then
    p_rec.attribute20 :=
    irc_isc_shd.g_old_rec.attribute20;
  End If;
  If (p_rec.attribute21 = hr_api.g_varchar2) then
    p_rec.attribute21 :=
    irc_isc_shd.g_old_rec.attribute21;
  End If;
  If (p_rec.attribute22 = hr_api.g_varchar2) then
    p_rec.attribute22 :=
    irc_isc_shd.g_old_rec.attribute22;
  End If;
  If (p_rec.attribute23 = hr_api.g_varchar2) then
    p_rec.attribute23 :=
    irc_isc_shd.g_old_rec.attribute23;
  End If;
  If (p_rec.attribute24 = hr_api.g_varchar2) then
    p_rec.attribute24 :=
    irc_isc_shd.g_old_rec.attribute24;
  End If;
  If (p_rec.attribute25 = hr_api.g_varchar2) then
    p_rec.attribute25 :=
    irc_isc_shd.g_old_rec.attribute25;
  End If;
  If (p_rec.attribute26 = hr_api.g_varchar2) then
    p_rec.attribute26 :=
    irc_isc_shd.g_old_rec.attribute26;
  End If;
  If (p_rec.attribute27 = hr_api.g_varchar2) then
    p_rec.attribute27 :=
    irc_isc_shd.g_old_rec.attribute27;
  End If;
  If (p_rec.attribute28 = hr_api.g_varchar2) then
    p_rec.attribute28 :=
    irc_isc_shd.g_old_rec.attribute28;
  End If;
  If (p_rec.attribute29 = hr_api.g_varchar2) then
    p_rec.attribute29 :=
    irc_isc_shd.g_old_rec.attribute29;
  End If;
  If (p_rec.attribute30 = hr_api.g_varchar2) then
    p_rec.attribute30 :=
    irc_isc_shd.g_old_rec.attribute30;
  End If;
  If (p_rec.isc_information_category = hr_api.g_varchar2) then
    p_rec.isc_information_category :=
    irc_isc_shd.g_old_rec.isc_information_category;
  End If;
  If (p_rec.isc_information1 = hr_api.g_varchar2) then
    p_rec.isc_information1 :=
    irc_isc_shd.g_old_rec.isc_information1;
  End If;
  If (p_rec.isc_information2 = hr_api.g_varchar2) then
    p_rec.isc_information2 :=
    irc_isc_shd.g_old_rec.isc_information2;
  End If;
  If (p_rec.isc_information3 = hr_api.g_varchar2) then
    p_rec.isc_information3 :=
    irc_isc_shd.g_old_rec.isc_information3;
  End If;
  If (p_rec.isc_information4 = hr_api.g_varchar2) then
    p_rec.isc_information4 :=
    irc_isc_shd.g_old_rec.isc_information4;
  End If;
  If (p_rec.isc_information5 = hr_api.g_varchar2) then
    p_rec.isc_information5 :=
    irc_isc_shd.g_old_rec.isc_information5;
  End If;
  If (p_rec.isc_information6 = hr_api.g_varchar2) then
    p_rec.isc_information6 :=
    irc_isc_shd.g_old_rec.isc_information6;
  End If;
  If (p_rec.isc_information7 = hr_api.g_varchar2) then
    p_rec.isc_information7 :=
    irc_isc_shd.g_old_rec.isc_information7;
  End If;
  If (p_rec.isc_information8 = hr_api.g_varchar2) then
    p_rec.isc_information8 :=
    irc_isc_shd.g_old_rec.isc_information8;
  End If;
  If (p_rec.isc_information9 = hr_api.g_varchar2) then
    p_rec.isc_information9 :=
    irc_isc_shd.g_old_rec.isc_information9;
  End If;
  If (p_rec.isc_information10 = hr_api.g_varchar2) then
    p_rec.isc_information10 :=
    irc_isc_shd.g_old_rec.isc_information10;
  End If;
  If (p_rec.isc_information11 = hr_api.g_varchar2) then
    p_rec.isc_information11 :=
    irc_isc_shd.g_old_rec.isc_information11;
  End If;
  If (p_rec.isc_information12 = hr_api.g_varchar2) then
    p_rec.isc_information12 :=
    irc_isc_shd.g_old_rec.isc_information12;
  End If;
  If (p_rec.isc_information13 = hr_api.g_varchar2) then
    p_rec.isc_information13 :=
    irc_isc_shd.g_old_rec.isc_information13;
  End If;
  If (p_rec.isc_information14 = hr_api.g_varchar2) then
    p_rec.isc_information14 :=
    irc_isc_shd.g_old_rec.isc_information14;
  End If;
  If (p_rec.isc_information15 = hr_api.g_varchar2) then
    p_rec.isc_information15 :=
    irc_isc_shd.g_old_rec.isc_information15;
  End If;
  If (p_rec.isc_information16 = hr_api.g_varchar2) then
    p_rec.isc_information16 :=
    irc_isc_shd.g_old_rec.isc_information16;
  End If;
  If (p_rec.isc_information17 = hr_api.g_varchar2) then
    p_rec.isc_information17 :=
    irc_isc_shd.g_old_rec.isc_information17;
  End If;
  If (p_rec.isc_information18 = hr_api.g_varchar2) then
    p_rec.isc_information18 :=
    irc_isc_shd.g_old_rec.isc_information18;
  End If;
  If (p_rec.isc_information19 = hr_api.g_varchar2) then
    p_rec.isc_information19 :=
    irc_isc_shd.g_old_rec.isc_information19;
  End If;
  If (p_rec.isc_information20 = hr_api.g_varchar2) then
    p_rec.isc_information20 :=
    irc_isc_shd.g_old_rec.isc_information20;
  End If;
  If (p_rec.isc_information21 = hr_api.g_varchar2) then
    p_rec.isc_information21 :=
    irc_isc_shd.g_old_rec.isc_information21;
  End If;
  If (p_rec.isc_information22 = hr_api.g_varchar2) then
    p_rec.isc_information22 :=
    irc_isc_shd.g_old_rec.isc_information22;
  End If;
  If (p_rec.isc_information23 = hr_api.g_varchar2) then
    p_rec.isc_information23 :=
    irc_isc_shd.g_old_rec.isc_information23;
  End If;
  If (p_rec.isc_information24 = hr_api.g_varchar2) then
    p_rec.isc_information24 :=
    irc_isc_shd.g_old_rec.isc_information24;
  End If;
  If (p_rec.isc_information25 = hr_api.g_varchar2) then
    p_rec.isc_information25 :=
    irc_isc_shd.g_old_rec.isc_information25;
  End If;
  If (p_rec.isc_information26 = hr_api.g_varchar2) then
    p_rec.isc_information26 :=
    irc_isc_shd.g_old_rec.isc_information26;
  End If;
  If (p_rec.isc_information27 = hr_api.g_varchar2) then
    p_rec.isc_information27 :=
    irc_isc_shd.g_old_rec.isc_information27;
  End If;
  If (p_rec.isc_information28 = hr_api.g_varchar2) then
    p_rec.isc_information28 :=
    irc_isc_shd.g_old_rec.isc_information28;
  End If;
  If (p_rec.isc_information29 = hr_api.g_varchar2) then
    p_rec.isc_information29 :=
    irc_isc_shd.g_old_rec.isc_information29;
  End If;
  If (p_rec.isc_information30 = hr_api.g_varchar2) then
    p_rec.isc_information30 :=
    irc_isc_shd.g_old_rec.isc_information30;
  End If;
  If (p_rec.date_posted = hr_api.g_varchar2) then
    p_rec.date_posted :=
    irc_isc_shd.g_old_rec.date_posted;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in date
  ,p_rec                          in out nocopy irc_isc_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  irc_isc_shd.lck
    (p_rec.search_criteria_id
    ,p_rec.object_version_number
    );
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  convert_defs(p_rec);
  irc_isc_bus.update_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  irc_isc_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  irc_isc_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  irc_isc_upd.post_update
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in     date
  ,p_search_criteria_id           in     number
  ,p_object_version_number        in out nocopy number
  ,p_object_id                    in     number    default hr_api.g_number
  ,p_object_type                  in     varchar2  default hr_api.g_varchar2
  ,p_search_name                  in     varchar2  default hr_api.g_varchar2
  ,p_search_type                  in     varchar2  default hr_api.g_varchar2
  ,p_location                     in     varchar2  default hr_api.g_varchar2
  ,p_distance_to_location         in     varchar2  default hr_api.g_varchar2
  ,p_geocode_location             in     varchar2  default hr_api.g_varchar2
  ,p_geocode_country              in     varchar2  default hr_api.g_varchar2
  ,p_derived_location             in     varchar2  default hr_api.g_varchar2
  ,p_location_id                  in     number    default hr_api.g_number
  ,p_longitude                    in     number    default hr_api.g_number
  ,p_latitude                     in     number    default hr_api.g_number
  ,p_employee                     in     varchar2  default hr_api.g_varchar2
  ,p_contractor                   in     varchar2  default hr_api.g_varchar2
  ,p_employment_category          in     varchar2  default hr_api.g_varchar2
  ,p_keywords                     in     varchar2  default hr_api.g_varchar2
  ,p_travel_percentage            in     number    default hr_api.g_number
  ,p_min_salary                   in     number    default hr_api.g_number
  ,p_max_salary                   in     number    default hr_api.g_number
  ,p_salary_currency              in     varchar2  default hr_api.g_varchar2
  ,p_salary_period                in     varchar2  default hr_api.g_varchar2
  ,p_match_competence             in     varchar2  default hr_api.g_varchar2
  ,p_match_qualification          in     varchar2  default hr_api.g_varchar2
  ,p_job_title                    in     varchar2  default hr_api.g_varchar2
  ,p_department                   in     varchar2  default hr_api.g_varchar2
  ,p_professional_area            in     varchar2  default hr_api.g_varchar2
  ,p_work_at_home                 in     varchar2  default hr_api.g_varchar2
  ,p_min_qual_level               in     number    default hr_api.g_number
  ,p_max_qual_level               in     number    default hr_api.g_number
  ,p_use_for_matching             in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute_category           in     varchar2  default hr_api.g_varchar2
  ,p_attribute1                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute11                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute12                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute13                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute14                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute15                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute16                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute17                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute18                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute19                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute20                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute21                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute22                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute23                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute24                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute25                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute26                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute27                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute28                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute29                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute30                  in     varchar2  default hr_api.g_varchar2
  ,p_isc_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_isc_information1             in     varchar2  default hr_api.g_varchar2
  ,p_isc_information2             in     varchar2  default hr_api.g_varchar2
  ,p_isc_information3             in     varchar2  default hr_api.g_varchar2
  ,p_isc_information4             in     varchar2  default hr_api.g_varchar2
  ,p_isc_information5             in     varchar2  default hr_api.g_varchar2
  ,p_isc_information6             in     varchar2  default hr_api.g_varchar2
  ,p_isc_information7             in     varchar2  default hr_api.g_varchar2
  ,p_isc_information8             in     varchar2  default hr_api.g_varchar2
  ,p_isc_information9             in     varchar2  default hr_api.g_varchar2
  ,p_isc_information10            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information11            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information12            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information13            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information14            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information15            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information16            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information17            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information18            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information19            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information20            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information21            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information22            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information23            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information24            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information25            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information26            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information27            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information28            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information29            in     varchar2  default hr_api.g_varchar2
  ,p_isc_information30            in     varchar2  default hr_api.g_varchar2
  ,p_date_posted                  in     varchar2  default hr_api.g_varchar2
  ) is
--
  l_rec   irc_isc_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  irc_isc_shd.convert_args
  (p_search_criteria_id
  ,p_object_id
  ,p_object_type
  ,p_search_name
  ,p_search_type
  ,p_location
  ,p_distance_to_location
  ,p_geocode_location
  ,p_geocode_country
  ,p_derived_location
  ,p_location_id
  ,p_longitude
  ,p_latitude
  ,p_employee
  ,p_contractor
  ,p_employment_category
  ,p_keywords
  ,p_travel_percentage
  ,p_min_salary
  ,p_max_salary
  ,p_salary_currency
  ,p_salary_period
  ,p_match_competence
  ,p_match_qualification
  ,p_job_title
  ,p_department
  ,p_professional_area
  ,p_work_at_home
  ,p_min_qual_level
  ,p_max_qual_level
  ,p_use_for_matching
  ,p_description
  ,p_attribute_category
  ,p_attribute1
  ,p_attribute2
  ,p_attribute3
  ,p_attribute4
  ,p_attribute5
  ,p_attribute6
  ,p_attribute7
  ,p_attribute8
  ,p_attribute9
  ,p_attribute10
  ,p_attribute11
  ,p_attribute12
  ,p_attribute13
  ,p_attribute14
  ,p_attribute15
  ,p_attribute16
  ,p_attribute17
  ,p_attribute18
  ,p_attribute19
  ,p_attribute20
  ,p_attribute21
  ,p_attribute22
  ,p_attribute23
  ,p_attribute24
  ,p_attribute25
  ,p_attribute26
  ,p_attribute27
  ,p_attribute28
  ,p_attribute29
  ,p_attribute30
  ,p_isc_information_category
  ,p_isc_information1
  ,p_isc_information2
  ,p_isc_information3
  ,p_isc_information4
  ,p_isc_information5
  ,p_isc_information6
  ,p_isc_information7
  ,p_isc_information8
  ,p_isc_information9
  ,p_isc_information10
  ,p_isc_information11
  ,p_isc_information12
  ,p_isc_information13
  ,p_isc_information14
  ,p_isc_information15
  ,p_isc_information16
  ,p_isc_information17
  ,p_isc_information18
  ,p_isc_information19
  ,p_isc_information20
  ,p_isc_information21
  ,p_isc_information22
  ,p_isc_information23
  ,p_isc_information24
  ,p_isc_information25
  ,p_isc_information26
  ,p_isc_information27
  ,p_isc_information28
  ,p_isc_information29
  ,p_isc_information30
  ,p_object_version_number
  ,p_date_posted
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  irc_isc_upd.upd
     (p_effective_date
     ,l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end irc_isc_upd;

/
