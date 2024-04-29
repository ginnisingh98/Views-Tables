--------------------------------------------------------
--  DDL for Package Body IRC_ISC_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_ISC_INS" as
/* $Header: iriscrhi.pkb 120.0 2005/07/26 15:11:17 mbocutt noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  irc_isc_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value and pre_insert procedures.
--
g_search_criteria_id_i  number   default null;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_search_criteria_id  in  number) is
--
  l_proc       varchar2(72) := g_package||'set_base_key_value';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  irc_isc_ins.g_search_criteria_id_i := p_search_criteria_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End set_base_key_value;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml insert logic. The processing of
--   this procedure are as follows:
--   1) Initialise the object_version_number to 1 if the object_version_number
--      is defined as an attribute for this entity.
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To insert the row into the schema.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the ins
--   procedure and must have all mandatory attributes set (except the
--   object_version_number which is initialised within this procedure).
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be inserted into the schema.
--
-- Post Failure:
--   On the insert dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_dml
  (p_rec in out nocopy irc_isc_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
  l_description  clob;
  l_geometry mdsys.sdo_geometry :=null;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  irc_isc_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: irc_search_criteria
  --
  if p_rec.longitude is not null and p_rec.latitude is not null then
    l_geometry:=mdsys.sdo_geometry(2001,8307
          ,mdsys.sdo_point_type(p_rec.longitude,p_rec.latitude,null),null,null);
  end if;
  --
  insert into irc_search_criteria
      (search_criteria_id
      ,object_id
      ,object_type
      ,search_name
      ,search_type
      ,location
      ,distance_to_location
      ,geocode_location
      ,geocode_country
      ,derived_location
      ,location_id
      ,geometry
      ,employee
      ,contractor
      ,employment_category
      ,keywords
      ,travel_percentage
      ,min_salary
      ,max_salary
      ,salary_currency
      ,salary_period
      ,match_competence
      ,match_qualification
      ,job_title
      ,department
      ,professional_area
      ,work_at_home
      ,min_qual_level
      ,max_qual_level
      ,use_for_matching
      ,description
      ,attribute_category
      ,attribute1
      ,attribute2
      ,attribute3
      ,attribute4
      ,attribute5
      ,attribute6
      ,attribute7
      ,attribute8
      ,attribute9
      ,attribute10
      ,attribute11
      ,attribute12
      ,attribute13
      ,attribute14
      ,attribute15
      ,attribute16
      ,attribute17
      ,attribute18
      ,attribute19
      ,attribute20
      ,attribute21
      ,attribute22
      ,attribute23
      ,attribute24
      ,attribute25
      ,attribute26
      ,attribute27
      ,attribute28
      ,attribute29
      ,attribute30
      ,isc_information_category
      ,isc_information1
      ,isc_information2
      ,isc_information3
      ,isc_information4
      ,isc_information5
      ,isc_information6
      ,isc_information7
      ,isc_information8
      ,isc_information9
      ,isc_information10
      ,isc_information11
      ,isc_information12
      ,isc_information13
      ,isc_information14
      ,isc_information15
      ,isc_information16
      ,isc_information17
      ,isc_information18
      ,isc_information19
      ,isc_information20
      ,isc_information21
      ,isc_information22
      ,isc_information23
      ,isc_information24
      ,isc_information25
      ,isc_information26
      ,isc_information27
      ,isc_information28
      ,isc_information29
      ,isc_information30
      ,object_version_number
      ,date_posted
      )
  Values
    (p_rec.search_criteria_id
    ,p_rec.object_id
    ,p_rec.object_type
    ,p_rec.search_name
    ,p_rec.search_type
    ,p_rec.location
    ,p_rec.distance_to_location
    ,p_rec.geocode_location
    ,p_rec.geocode_country
    ,p_rec.derived_location
    ,p_rec.location_id
    ,l_geometry
    ,p_rec.employee
    ,p_rec.contractor
    ,p_rec.employment_category
    ,p_rec.keywords
    ,p_rec.travel_percentage
    ,p_rec.min_salary
    ,p_rec.max_salary
    ,p_rec.salary_currency
    ,p_rec.salary_period
    ,p_rec.match_competence
    ,p_rec.match_qualification
    ,p_rec.job_title
    ,p_rec.department
    ,p_rec.professional_area
    ,p_rec.work_at_home
    ,p_rec.min_qual_level
    ,p_rec.max_qual_level
    ,p_rec.use_for_matching
    ,empty_clob()
    ,p_rec.attribute_category
    ,p_rec.attribute1
    ,p_rec.attribute2
    ,p_rec.attribute3
    ,p_rec.attribute4
    ,p_rec.attribute5
    ,p_rec.attribute6
    ,p_rec.attribute7
    ,p_rec.attribute8
    ,p_rec.attribute9
    ,p_rec.attribute10
    ,p_rec.attribute11
    ,p_rec.attribute12
    ,p_rec.attribute13
    ,p_rec.attribute14
    ,p_rec.attribute15
    ,p_rec.attribute16
    ,p_rec.attribute17
    ,p_rec.attribute18
    ,p_rec.attribute19
    ,p_rec.attribute20
    ,p_rec.attribute21
    ,p_rec.attribute22
    ,p_rec.attribute23
    ,p_rec.attribute24
    ,p_rec.attribute25
    ,p_rec.attribute26
    ,p_rec.attribute27
    ,p_rec.attribute28
    ,p_rec.attribute29
    ,p_rec.attribute30
    ,p_rec.isc_information_category
    ,p_rec.isc_information1
    ,p_rec.isc_information2
    ,p_rec.isc_information3
    ,p_rec.isc_information4
    ,p_rec.isc_information5
    ,p_rec.isc_information6
    ,p_rec.isc_information7
    ,p_rec.isc_information8
    ,p_rec.isc_information9
    ,p_rec.isc_information10
    ,p_rec.isc_information11
    ,p_rec.isc_information12
    ,p_rec.isc_information13
    ,p_rec.isc_information14
    ,p_rec.isc_information15
    ,p_rec.isc_information16
    ,p_rec.isc_information17
    ,p_rec.isc_information18
    ,p_rec.isc_information19
    ,p_rec.isc_information20
    ,p_rec.isc_information21
    ,p_rec.isc_information22
    ,p_rec.isc_information23
    ,p_rec.isc_information24
    ,p_rec.isc_information25
    ,p_rec.isc_information26
    ,p_rec.isc_information27
    ,p_rec.isc_information28
    ,p_rec.isc_information29
    ,p_rec.isc_information30
    ,p_rec.object_version_number
    ,p_rec.date_posted
    )
    returning description into l_description;
  --
    if (p_rec.description is not null) then
      hr_utility.set_location(l_proc, 10);
      dbms_lob.write(l_description
                    ,length(p_rec.description)
                    ,1
                    ,p_rec.description);
    end if;

  irc_isc_shd.g_api_dml := false;  -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
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
End insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_insert >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the insert dml. Presently, if the entity has a corresponding primary
--   key which is maintained by an associating sequence, the primary key for
--   the entity will be populated with the next sequence value in
--   preparation for the insert dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the ins procedure.
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
--   Any pre-processing required before the insert dml is issued should be
--   coded within this procedure. As stated above, a good example is the
--   generation of a primary key number via a corresponding sequence.
--   It is important to note that any 3rd party maintenance should be reviewed
--   before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_insert
  (p_rec  in out nocopy irc_isc_shd.g_rec_type
  ) is
--
  Cursor C_Sel1 is select irc_search_criteria_s.nextval from sys.dual;
--
  Cursor C_Sel2 is
    Select null
      from irc_search_criteria
     where search_criteria_id =
             irc_isc_ins.g_search_criteria_id_i;
--
  l_proc   varchar2(72) := g_package||'pre_insert';
  l_exists varchar2(1);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (irc_isc_ins.g_search_criteria_id_i is not null) Then
    --
    -- Verify registered primary key values not already in use
    --
    Open C_Sel2;
    Fetch C_Sel2 into l_exists;
    If C_Sel2%found Then
       Close C_Sel2;
       --
       -- The primary key values are already in use.
       --
       fnd_message.set_name('PER','PER_289391_KEY_ALREADY_USED');
       fnd_message.set_token('TABLE_NAME','irc_search_criteria');
       fnd_message.raise_error;
    End If;
    Close C_Sel2;
    --
    -- Use registered key values and clear globals
    --
    p_rec.search_criteria_id :=
      irc_isc_ins.g_search_criteria_id_i;
    irc_isc_ins.g_search_criteria_id_i := null;
  Else
    --
    -- No registerd key values, so select the next sequence number
    --
    --
    -- Select the next sequence number
    --
    Open C_Sel1;
    Fetch C_Sel1 Into p_rec.search_criteria_id;
    Close C_Sel1;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_insert;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_insert >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after
--   the insert dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the ins procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any post-processing required after the insert dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_insert
  (p_effective_date               in date
  ,p_rec                          in irc_isc_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    irc_isc_rki.after_insert
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
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'IRC_SEARCH_CRITERIA'
        ,p_hook_type   => 'AI');
      --
  end;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_effective_date               in date
  ,p_rec                          in out nocopy irc_isc_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  irc_isc_bus.insert_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-insert operation
  --
  irc_isc_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  irc_isc_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  irc_isc_ins.post_insert
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_effective_date               in     date
  ,p_object_id                      in     number
  ,p_object_type                    in     varchar2
  ,p_search_name                    in     varchar2 default null
  ,p_search_type                    in     varchar2 default null
  ,p_location                       in     varchar2 default null
  ,p_distance_to_location           in     varchar2 default null
  ,p_geocode_location               in     varchar2 default null
  ,p_geocode_country                in     varchar2 default null
  ,p_derived_location               in     varchar2 default null
  ,p_location_id                    in     number   default null
  ,p_longitude                      in     number   default null
  ,p_latitude                       in     number   default null
  ,p_employee                       in     varchar2 default null
  ,p_contractor                     in     varchar2 default null
  ,p_employment_category            in     varchar2 default null
  ,p_keywords                       in     varchar2 default null
  ,p_travel_percentage              in     number   default null
  ,p_min_salary                     in     number   default null
  ,p_max_salary                     in     number   default null
  ,p_salary_currency                in     varchar2 default null
  ,p_salary_period                  in     varchar2 default null
  ,p_match_competence               in     varchar2 default null
  ,p_match_qualification            in     varchar2 default null
  ,p_job_title                      in     varchar2 default null
  ,p_department                     in     varchar2 default null
  ,p_professional_area              in     varchar2 default null
  ,p_work_at_home                   in     varchar2 default null
  ,p_min_qual_level                 in     number   default null
  ,p_max_qual_level                 in     number   default null
  ,p_use_for_matching               in     varchar2 default null
  ,p_description                    in     varchar2 default null
  ,p_attribute_category             in     varchar2 default null
  ,p_attribute1                     in     varchar2 default null
  ,p_attribute2                     in     varchar2 default null
  ,p_attribute3                     in     varchar2 default null
  ,p_attribute4                     in     varchar2 default null
  ,p_attribute5                     in     varchar2 default null
  ,p_attribute6                     in     varchar2 default null
  ,p_attribute7                     in     varchar2 default null
  ,p_attribute8                     in     varchar2 default null
  ,p_attribute9                     in     varchar2 default null
  ,p_attribute10                    in     varchar2 default null
  ,p_attribute11                    in     varchar2 default null
  ,p_attribute12                    in     varchar2 default null
  ,p_attribute13                    in     varchar2 default null
  ,p_attribute14                    in     varchar2 default null
  ,p_attribute15                    in     varchar2 default null
  ,p_attribute16                    in     varchar2 default null
  ,p_attribute17                    in     varchar2 default null
  ,p_attribute18                    in     varchar2 default null
  ,p_attribute19                    in     varchar2 default null
  ,p_attribute20                    in     varchar2 default null
  ,p_attribute21                    in     varchar2 default null
  ,p_attribute22                    in     varchar2 default null
  ,p_attribute23                    in     varchar2 default null
  ,p_attribute24                    in     varchar2 default null
  ,p_attribute25                    in     varchar2 default null
  ,p_attribute26                    in     varchar2 default null
  ,p_attribute27                    in     varchar2 default null
  ,p_attribute28                    in     varchar2 default null
  ,p_attribute29                    in     varchar2 default null
  ,p_attribute30                    in     varchar2 default null
  ,p_isc_information_category       in     varchar2 default null
  ,p_isc_information1               in     varchar2 default null
  ,p_isc_information2               in     varchar2 default null
  ,p_isc_information3               in     varchar2 default null
  ,p_isc_information4               in     varchar2 default null
  ,p_isc_information5               in     varchar2 default null
  ,p_isc_information6               in     varchar2 default null
  ,p_isc_information7               in     varchar2 default null
  ,p_isc_information8               in     varchar2 default null
  ,p_isc_information9               in     varchar2 default null
  ,p_isc_information10              in     varchar2 default null
  ,p_isc_information11              in     varchar2 default null
  ,p_isc_information12              in     varchar2 default null
  ,p_isc_information13              in     varchar2 default null
  ,p_isc_information14              in     varchar2 default null
  ,p_isc_information15              in     varchar2 default null
  ,p_isc_information16              in     varchar2 default null
  ,p_isc_information17              in     varchar2 default null
  ,p_isc_information18              in     varchar2 default null
  ,p_isc_information19              in     varchar2 default null
  ,p_isc_information20              in     varchar2 default null
  ,p_isc_information21              in     varchar2 default null
  ,p_isc_information22              in     varchar2 default null
  ,p_isc_information23              in     varchar2 default null
  ,p_isc_information24              in     varchar2 default null
  ,p_isc_information25              in     varchar2 default null
  ,p_isc_information26              in     varchar2 default null
  ,p_isc_information27              in     varchar2 default null
  ,p_isc_information28              in     varchar2 default null
  ,p_isc_information29              in     varchar2 default null
  ,p_isc_information30              in     varchar2 default null
  ,p_date_posted                    in     varchar2 default null
  ,p_search_criteria_id                out nocopy number
  ,p_object_version_number             out nocopy number
  ) is
--
  l_rec   irc_isc_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  irc_isc_shd.convert_args
    (null
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
    ,null
    ,p_date_posted
    );
  --
  -- Having converted the arguments into the irc_isc_rec
  -- plsql record structure we call the corresponding record business process.
  --
  irc_isc_ins.ins
     (p_effective_date
     ,l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_search_criteria_id := l_rec.search_criteria_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end irc_isc_ins;

/
