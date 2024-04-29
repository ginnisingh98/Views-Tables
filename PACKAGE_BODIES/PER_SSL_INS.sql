--------------------------------------------------------
--  DDL for Package Body PER_SSL_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_SSL_INS" as
/* $Header: pesslrhi.pkb 120.0.12010000.2 2008/09/09 11:18:51 pchowdav ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_ssl_ins.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This Procedure controls the actual dml insert logic. The processing of
--   this Procedure are as follows:
--   1) Initialise the object_version_number to 1 If the object_version_number
--      is defined as an attribute for this entity.
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To insert the row into the schema.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private Procedure which must be called from the ins
--   Procedure and must have all mandatory attributes set (except the
--   object_version_number which is initialised within this Procedure).
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specIfied row will be inserted into the schema.
--
-- Post Failure:
--   On the insert dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a check, unique or parent integrity constraint violation is raised the
--   constraint_error Procedure will be called.
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
Procedure insert_dml(p_rec            in out nocopy per_ssl_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_utility.set_location('SS id '||to_char(p_rec.salary_survey_id), 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  --
  -- Insert the row into: per_salary_survey_lines
  --
  insert into per_salary_survey_lines
  (	salary_survey_line_id,
	object_version_number,
	salary_survey_id,
	survey_job_name_code,
	survey_region_code,
	survey_seniority_code,
	company_size_code,
	industry_code,
        survey_age_code,
	start_date,
	end_date,
        currency_code,
	differential,
	minimum_pay,
	mean_pay,
	maximum_pay,
	graduate_pay,
	starting_pay,
	percentage_change,
	job_first_quartile,
	job_median_quartile,
	job_third_quartile,
	job_fourth_quartile,
	minimum_total_compensation,
	mean_total_compensation,
	maximum_total_compensation,
	compnstn_first_quartile,
	compnstn_median_quartile,
	compnstn_third_quartile,
	compnstn_fourth_quartile,
/*Added for Enhancement 4021737 */
        tenth_percentile,
        twenty_fifth_percentile,
        fiftieth_percentile,
        seventy_fifth_percentile,
        ninetieth_percentile,
        minimum_bonus,
        mean_bonus,
        maximum_bonus,
        minimum_salary_increase,
        mean_salary_increase,
        maximum_salary_increase,
        min_variable_compensation,
        mean_variable_compensation,
        max_variable_compensation,
        minimum_stock,
        mean_stock,
        maximum_stock,
        stock_display_type,
/*End Enhancement 4021737 */
	attribute_category,
	attribute1,
	attribute2,
	attribute3,
	attribute4,
	attribute5,
	attribute6,
	attribute7,
	attribute8,
	attribute9,
	attribute10,
	attribute11,
	attribute12,
	attribute13,
	attribute14,
	attribute15,
	attribute16,
	attribute17,
	attribute18,
	attribute19,
	attribute20,
/*Added for Enhancement 4021737 */
        attribute21,
        attribute22,
        attribute23,
        attribute24,
        attribute25,
        attribute26,
        attribute27,
        attribute28,
        attribute29,
        attribute30
/*End Enhancement 4021737 */
  )
  Values
  (	p_rec.salary_survey_line_id,
	p_rec.object_version_number,
	p_rec.salary_survey_id,
	p_rec.survey_job_name_code,
	p_rec.survey_region_code,
	p_rec.survey_seniority_code,
	p_rec.company_size_code,
	p_rec.industry_code,
        p_rec.survey_age_code,
	p_rec.start_date,
	p_rec.end_date,
        p_rec.currency_code,
	p_rec.differential,
	p_rec.minimum_pay,
	p_rec.mean_pay,
	p_rec.maximum_pay,
	p_rec.graduate_pay,
	p_rec.starting_pay,
	p_rec.percentage_change,
	p_rec.job_first_quartile,
	p_rec.job_median_quartile,
	p_rec.job_third_quartile,
	p_rec.job_fourth_quartile,
	p_rec.minimum_total_compensation,
	p_rec.mean_total_compensation,
	p_rec.maximum_total_compensation,
	p_rec.compnstn_first_quartile,
	p_rec.compnstn_median_quartile,
	p_rec.compnstn_third_quartile,
	p_rec.compnstn_fourth_quartile,
/*Added for Enhancement 4021737 */
        p_rec.tenth_percentile,
        p_rec.twenty_fifth_percentile,
        p_rec.fiftieth_percentile,
        p_rec.seventy_fifth_percentile,
        p_rec.ninetieth_percentile,
        p_rec.minimum_bonus,
        p_rec.mean_bonus,
        p_rec.maximum_bonus,
        p_rec.minimum_salary_increase,
        p_rec.mean_salary_increase,
        p_rec.maximum_salary_increase,
        p_rec.min_variable_compensation,
        p_rec.mean_variable_compensation,
        p_rec.max_variable_compensation,
        p_rec.minimum_stock,
        p_rec.mean_stock,
        p_rec.maximum_stock,
        p_rec.stock_display_type,
/*End Enhancement 4021737 */
	p_rec.attribute_category,
	p_rec.attribute1,
	p_rec.attribute2,
	p_rec.attribute3,
	p_rec.attribute4,
	p_rec.attribute5,
	p_rec.attribute6,
	p_rec.attribute7,
	p_rec.attribute8,
	p_rec.attribute9,
	p_rec.attribute10,
	p_rec.attribute11,
	p_rec.attribute12,
	p_rec.attribute13,
	p_rec.attribute14,
	p_rec.attribute15,
	p_rec.attribute16,
	p_rec.attribute17,
	p_rec.attribute18,
	p_rec.attribute19,
	p_rec.attribute20,
/*Added for Enhancement 4021737 */
        p_rec.attribute21,
        p_rec.attribute22,
        p_rec.attribute23,
        p_rec.attribute24,
        p_rec.attribute25,
        p_rec.attribute26,
        p_rec.attribute27,
        p_rec.attribute28,
        p_rec.attribute29,
        p_rec.attribute30
/*End Enhancement 4021737 */
  );
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    hr_utility.set_location('check integrity constraint',11);
    per_ssl_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    hr_utility.set_location('parent integrity constraint',11);
    per_ssl_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    hr_utility.set_location('unique integrity constraint ',11);
    hr_utility.set_location(SQLERRM,12);
    per_ssl_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    Raise;
End insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_insert >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private Procedure contains any processing which is required before
--   the insert dml. Presently, If the entity has a corresponding primary
--   key which is maintained by an associating sequence, the primary key for
--   the entity will be populated with the next sequence value in
--   preparation for the insert dml.
--
-- Prerequisites:
--   This is an internal Procedure which is called from the ins Procedure.
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
--   Any pre-processing required before the insert dml is issued should be
--   coded within this Procedure. As stated above, a good example is the
--   generation of a primary key number via a corresponding sequence.
--   It is important to note that any 3rd party maintenance should be reviewed
--   before placing in this Procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_insert(p_rec  in out nocopy per_ssl_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select per_salary_survey_lines_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.salary_survey_line_id;
  Close C_Sel1;
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
--   This private Procedure contains any processing which is required after the
--   insert dml.
--
-- Prerequisites:
--   This is an internal Procedure which is called from the ins Procedure.
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
--   coded within this Procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this Procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_insert(p_rec in per_ssl_shd.g_rec_type,
                      p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  begin
    per_ssl_rki.after_insert
      (p_salary_survey_line_id
         => p_rec.salary_survey_line_id,
       p_object_version_number
         => p_rec.object_version_number,
       p_salary_survey_id
         => p_rec.salary_survey_id,
       p_survey_job_name_code
         => p_rec.survey_job_name_code,
       p_survey_region_code
         => p_rec.survey_region_code,
       p_survey_seniority_code
         => p_rec.survey_seniority_code,
       p_company_size_code
         => p_rec.company_size_code,
       p_industry_code
         => p_rec.industry_code,
       p_survey_age_code
         => p_rec.survey_age_code,
       p_start_date
         => p_rec.start_date,
       p_end_date
         => p_rec.end_date,
       p_currency_code
         => p_rec.currency_code,
       p_differential
          => p_rec.differential,
       p_minimum_pay
          => p_rec.minimum_pay,
       p_mean_pay
          => p_rec.mean_pay,
       p_maximum_pay
          => p_rec.maximum_pay,
       p_graduate_pay
          => p_rec.graduate_pay,
       p_starting_pay
          => p_rec.starting_pay,
       p_percentage_change
          => p_rec.percentage_change,
       p_job_first_quartile
          => p_rec.job_first_quartile,
       p_job_median_quartile
          => p_rec.job_median_quartile,
       p_job_third_quartile
          => p_rec.job_third_quartile,
       p_job_fourth_quartile
          => p_rec.job_fourth_quartile,
       p_minimum_total_compensation
          => p_rec.minimum_total_compensation,
       p_mean_total_compensation
          => p_rec.mean_total_compensation,
       p_maximum_total_compensation
          => p_rec.maximum_total_compensation,
       p_compnstn_first_quartile
          => p_rec.compnstn_first_quartile,
       p_compnstn_median_quartile
           => p_rec.compnstn_median_quartile,
       p_compnstn_third_quartile
           => p_rec.compnstn_third_quartile,
       p_compnstn_fourth_quartile
           => p_rec.compnstn_fourth_quartile,
/*Added for Enhancement 4021737 */
        p_tenth_percentile
          => p_rec.tenth_percentile,
        p_twenty_fifth_percentile
          => p_rec.twenty_fifth_percentile,
        p_fiftieth_percentile
          => p_rec.fiftieth_percentile,
        p_seventy_fifth_percentile
          => p_rec.seventy_fifth_percentile,
        p_ninetieth_percentile
          => p_rec.ninetieth_percentile,
        p_minimum_bonus
          => p_rec.minimum_bonus,
        p_mean_bonus
          => p_rec.mean_bonus,
        p_maximum_bonus
          => p_rec.maximum_bonus,
        p_minimum_salary_increase
          => p_rec.minimum_salary_increase,
        p_mean_salary_increase
          => p_rec.mean_salary_increase,
        p_maximum_salary_increase
          => p_rec.maximum_salary_increase,
        p_min_variable_compensation
          => p_rec.min_variable_compensation,
        p_mean_variable_compensation
          => p_rec.mean_variable_compensation,
        p_max_variable_compensation
          => p_rec.max_variable_compensation,
        p_minimum_stock
          => p_rec.minimum_stock,
        p_mean_stock
          => p_rec.mean_stock,
        p_maximum_stock
          => p_rec.maximum_stock,
        p_stock_display_type
          => p_rec.stock_display_type,
/*End Enhancement 4021737 */
       p_effective_date
           => p_effective_date,
       p_attribute_category
           => p_rec.attribute_category,
       p_attribute1
           => p_rec.attribute1,
       p_attribute2
           => p_rec.attribute2,
       p_attribute3
           => p_rec.attribute3,
       p_attribute4
           => p_rec.attribute4,
       p_attribute5
           => p_rec.attribute5,
       p_attribute6
           => p_rec.attribute6,
       p_attribute7
           => p_rec.attribute7,
       p_attribute8
           => p_rec.attribute8,
       p_attribute9
           => p_rec.attribute9,
       p_attribute10
           => p_rec.attribute10,
       p_attribute11
           => p_rec.attribute11,
       p_attribute12
           => p_rec.attribute12,
       p_attribute13
           => p_rec.attribute13,
       p_attribute14
           => p_rec.attribute14,
       p_attribute15
           => p_rec.attribute15,
       p_attribute16
           => p_rec.attribute16,
       p_attribute17
           => p_rec.attribute17,
       p_attribute18
           => p_rec.attribute18,
       p_attribute19
           => p_rec.attribute19,
       p_attribute20
           => p_rec.attribute20,
/*Added for Enhancement 4021737 */
       p_attribute21
           => p_rec.attribute21,
       p_attribute22
           => p_rec.attribute22,
       p_attribute23
           => p_rec.attribute23,
       p_attribute24
           => p_rec.attribute24,
       p_attribute25
           => p_rec.attribute25,
       p_attribute26
           => p_rec.attribute26,
       p_attribute27
           => p_rec.attribute27,
       p_attribute28
           => p_rec.attribute28,
       p_attribute29
           => p_rec.attribute29,
       p_attribute30
           => p_rec.attribute30
/*End Enhancement 4021737 */

      );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_SALARY_SURVEY_LINES'
        ,p_hook_type   => 'AI'
        );
  end;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_rec            in out nocopy per_ssl_shd.g_rec_type,
  p_effective_date in date
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  per_ssl_bus.insert_validate(p_rec, p_effective_date);
  --
  -- Call the supporting pre-insert operation
  --
  pre_insert(p_rec);
  --
  -- Insert the row
  --
  insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  post_insert(p_rec,p_effective_date);
End ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_salary_survey_line_id       out nocopy number,
  p_object_version_number        out nocopy number,
  p_salary_survey_id             in number,
  p_survey_job_name_code         in varchar2,
  p_survey_region_code           in varchar2         default null,
  p_survey_seniority_code        in varchar2         default null,
  p_company_size_code            in varchar2         default null,
  p_industry_code                in varchar2         default null,
  p_survey_age_code              in varchar2         default null,
  p_start_date                   in date,
  p_end_date                     in date             default null,
  p_currency_code                in varchar2,
  p_differential                 in number           default null,
  p_minimum_pay                  in number           default null,
  p_mean_pay                     in number           default null,
  p_maximum_pay                  in number           default null,
  p_graduate_pay                 in number           default null,
  p_starting_pay                 in number           default null,
  p_percentage_change            in number           default null,
  p_job_first_quartile           in number           default null,
  p_job_median_quartile          in number           default null,
  p_job_third_quartile           in number           default null,
  p_job_fourth_quartile          in number           default null,
  p_minimum_total_compensation   in number           default null,
  p_mean_total_compensation      in number           default null,
  p_maximum_total_compensation   in number           default null,
  p_compnstn_first_quartile      in number           default null,
  p_compnstn_median_quartile     in number           default null,
  p_compnstn_third_quartile      in number           default null,
  p_compnstn_fourth_quartile     in number           default null,
/*Added for Enhancement 4021737 */
  p_tenth_percentile             in number           default null,
  p_twenty_fifth_percentile      in number           default null,
  p_fiftieth_percentile          in number           default null,
  p_seventy_fifth_percentile     in number           default null,
  p_ninetieth_percentile         in number           default null,
  p_minimum_bonus                in number           default null,
  p_mean_bonus                   in number           default null,
  p_maximum_bonus                in number           default null,
  p_minimum_salary_increase      in number           default null,
  p_mean_salary_increase         in number           default null,
  p_maximum_salary_increase      in number           default null,
  p_min_variable_compensation    in number           default null,
  p_mean_variable_compensation   in number           default null,
  p_max_variable_compensation    in number           default null,
  p_minimum_stock                in number           default null,
  p_mean_stock                   in number           default null,
  p_maximum_stock                in number           default null,
  p_stock_display_type           in varchar2         default null,
/*End Enhancement 4021737 */
  p_attribute_category           in varchar2         default null,
  p_attribute1                   in varchar2         default null,
  p_attribute2                   in varchar2         default null,
  p_attribute3                   in varchar2         default null,
  p_attribute4                   in varchar2         default null,
  p_attribute5                   in varchar2         default null,
  p_attribute6                   in varchar2         default null,
  p_attribute7                   in varchar2         default null,
  p_attribute8                   in varchar2         default null,
  p_attribute9                   in varchar2         default null,
  p_attribute10                  in varchar2         default null,
  p_attribute11                  in varchar2         default null,
  p_attribute12                  in varchar2         default null,
  p_attribute13                  in varchar2         default null,
  p_attribute14                  in varchar2         default null,
  p_attribute15                  in varchar2         default null,
  p_attribute16                  in varchar2         default null,
  p_attribute17                  in varchar2         default null,
  p_attribute18                  in varchar2         default null,
  p_attribute19                  in varchar2         default null,
  p_attribute20                  in varchar2         default null,
/*Added for Enhancement 4021737 */
  p_attribute21                  in varchar2         default null,
  p_attribute22                  in varchar2         default null,
  p_attribute23                  in varchar2         default null,
  p_attribute24                  in varchar2         default null,
  p_attribute25                  in varchar2         default null,
  p_attribute26                  in varchar2         default null,
  p_attribute27                  in varchar2         default null,
  p_attribute28                  in varchar2         default null,
  p_attribute29                  in varchar2         default null,
  p_attribute30                  in varchar2         default null,
/*End Enhancement 4021737 */
  p_effective_date               in date             default null
  ) is
--
  l_rec	  per_ssl_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  per_ssl_shd.convert_args
  (
  null,
  null,
  p_salary_survey_id,
  p_survey_job_name_code,
  p_survey_region_code,
  p_survey_seniority_code,
  p_company_size_code,
  p_industry_code,
  p_survey_age_code,
  p_start_date,
  p_end_date,
  p_currency_code,
  p_differential,
  p_minimum_pay,
  p_mean_pay,
  p_maximum_pay,
  p_graduate_pay,
  p_starting_pay,
  p_percentage_change,
  p_job_first_quartile,
  p_job_median_quartile,
  p_job_third_quartile,
  p_job_fourth_quartile,
  p_minimum_total_compensation,
  p_mean_total_compensation,
  p_maximum_total_compensation,
  p_compnstn_first_quartile,
  p_compnstn_median_quartile,
  p_compnstn_third_quartile,
  p_compnstn_fourth_quartile,
/*Added for Enhancement 4021737 */
  p_tenth_percentile,
  p_twenty_fifth_percentile,
  p_fiftieth_percentile,
  p_seventy_fifth_percentile,
  p_ninetieth_percentile,
  p_minimum_bonus,
  p_mean_bonus,
  p_maximum_bonus,
  p_minimum_salary_increase,
  p_mean_salary_increase,
  p_maximum_salary_increase,
  p_min_variable_compensation,
  p_mean_variable_compensation,
  p_max_variable_compensation,
  p_minimum_stock,
  p_mean_stock,
  p_maximum_stock,
  p_stock_display_type,
/*End Enhancement 4021737 */
  p_attribute_category,
  p_attribute1,
  p_attribute2,
  p_attribute3,
  p_attribute4,
  p_attribute5,
  p_attribute6,
  p_attribute7,
  p_attribute8,
  p_attribute9,
  p_attribute10,
  p_attribute11,
  p_attribute12,
  p_attribute13,
  p_attribute14,
  p_attribute15,
  p_attribute16,
  p_attribute17,
  p_attribute18,
  p_attribute19,
  p_attribute20,
/*Added for Enhancement 4021737 */
  p_attribute21,
  p_attribute22,
  p_attribute23,
  p_attribute24,
  p_attribute25,
  p_attribute26,
  p_attribute27,
  p_attribute28,
  p_attribute29,
  p_attribute30
/*End Enhancement 4021737 */
  );
  --
  -- Having converted the arguments into the per_ssl_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(l_rec, p_effective_date);
  --
  -- As the primary key argument(s)
  -- are specIfied as an OUT's we must set these values.
  --
  p_salary_survey_line_id := l_rec.salary_survey_line_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
End per_ssl_ins;

/
