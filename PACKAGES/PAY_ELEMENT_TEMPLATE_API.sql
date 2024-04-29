--------------------------------------------------------
--  DDL for Package PAY_ELEMENT_TEMPLATE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ELEMENT_TEMPLATE_API" AUTHID CURRENT_USER as
/* $Header: pyetmapi.pkh 115.6 2003/10/17 08:10:58 arashid ship $ */
-- ----------------------------------------------------------------------------
-- |------------------------< create_user_structure >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API creates a user-specific copy of a template. The template created
--   by this API may be used for the generation of core schema objects. A
--   template is a collection of rows from many tables, identified by a row
--   in PAY_ELEMENT_TEMPLATES.
--
--   The generated template differs from the source template in some or all of
--   the following:
--   - the generated template is business group-specific whereas the source
--     template is legislation code-specific.
--   - the generated template may contain overrides for source template values
--     e.g. base processing priority, flexfield values.
--   - certain configuration flexfield (p_configuration_information1 .. 30)
--     values may cause the exclusion of parts of the source template from
--     the generated template, or may override defaults for element input
--     values within the generated template.
--   - the base name is used as a prefix for object names and for placeholder
--     substitution within the generated template.
--
-- Prerequisites:
--   The source template (p_source_template_id) must exist and be of template
--   type 'T'. The business group (p_business_group_id) must be valid for the
--   legislation of the source template.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  If true, the database remains
--                                                unchanged. If false then the
--                                                the template is created.
--   p_effective_date               Yes  date     Effective date (used for
--                                                business rule validation).
--   p_business_group_id            Yes  number   Business group of the created
--                                                created template.
--   p_source_template_id           Yes  number   Template from which the
--                                                created template is copied.
--   p_base_name                    Yes  varchar2 User-supplied name for object
--                                                naming and substitution into
--                                                placeholders.
--   p_base_processing_priority     No   number   Override for base processing
--                                                priority.
--   p_preference_info_category     No   varchar2 Preference flexfield.
--   p_preference_information1      No   varchar2 Preference flexfield.
--   p_preference_information2      No   varchar2 Preference flexfield.
--   p_preference_information3      No   varchar2 Preference flexfield.
--   p_preference_information4      No   varchar2 Preference flexfield.
--   p_preference_information5      No   varchar2 Preference flexfield.
--   p_preference_information6      No   varchar2 Preference flexfield.
--   p_preference_information7      No   varchar2 Preference flexfield.
--   p_preference_information8      No   varchar2 Preference flexfield.
--   p_preference_information9      No   varchar2 Preference flexfield.
--   p_preference_information10     No   varchar2 Preference flexfield.
--   p_preference_information11     No   varchar2 Preference flexfield.
--   p_preference_information12     No   varchar2 Preference flexfield.
--   p_preference_information13     No   varchar2 Preference flexfield.
--   p_preference_information14     No   varchar2 Preference flexfield.
--   p_preference_information15     No   varchar2 Preference flexfield.
--   p_preference_information16     No   varchar2 Preference flexfield.
--   p_preference_information17     No   varchar2 Preference flexfield.
--   p_preference_information18     No   varchar2 Preference flexfield.
--   p_preference_information19     No   varchar2 Preference flexfield.
--   p_preference_information20     No   varchar2 Preference flexfield.
--   p_preference_information21     No   varchar2 Preference flexfield.
--   p_preference_information22     No   varchar2 Preference flexfield.
--   p_preference_information23     No   varchar2 Preference flexfield.
--   p_preference_information24     No   varchar2 Preference flexfield.
--   p_preference_information25     No   varchar2 Preference flexfield.
--   p_preference_information26     No   varchar2 Preference flexfield.
--   p_preference_information27     No   varchar2 Preference flexfield.
--   p_preference_information28     No   varchar2 Preference flexfield.
--   p_preference_information29     No   varchar2 Preference flexfield.
--   p_preference_information30     No   varchar2 Preference flexfield.
--   p_configuration_info_category  No   varchar2 Configuration flexfield.
--   p_configuration_information1   No   varchar2 Configuration flexfield.
--   p_configuration_information2   No   varchar2 Configuration flexfield.
--   p_configuration_information3   No   varchar2 Configuration flexfield.
--   p_configuration_information4   No   varchar2 Configuration flexfield.
--   p_configuration_information5   No   varchar2 Configuration flexfield.
--   p_configuration_information6   No   varchar2 Configuration flexfield.
--   p_configuration_information7   No   varchar2 Configuration flexfield.
--   p_configuration_information8   No   varchar2 Configuration flexfield.
--   p_configuration_information9   No   varchar2 Configuration flexfield.
--   p_configuration_information10  No   varchar2 Configuration flexfield.
--   p_configuration_information11  No   varchar2 Configuration flexfield.
--   p_configuration_information12  No   varchar2 Configuration flexfield.
--   p_configuration_information13  No   varchar2 Configuration flexfield.
--   p_configuration_information14  No   varchar2 Configuration flexfield.
--   p_configuration_information15  No   varchar2 Configuration flexfield.
--   p_configuration_information16  No   varchar2 Configuration flexfield.
--   p_configuration_information17  No   varchar2 Configuration flexfield.
--   p_configuration_information18  No   varchar2 Configuration flexfield.
--   p_configuration_information19  No   varchar2 Configuration flexfield.
--   p_configuration_information20  No   varchar2 Configuration flexfield.
--   p_configuration_information21  No   varchar2 Configuration flexfield.
--   p_configuration_information22  No   varchar2 Configuration flexfield.
--   p_configuration_information23  No   varchar2 Configuration flexfield.
--   p_configuration_information24  No   varchar2 Configuration flexfield.
--   p_configuration_information25  No   varchar2 Configuration flexfield.
--   p_configuration_information26  No   varchar2 Configuration flexfield.
--   p_configuration_information27  No   varchar2 Configuration flexfield.
--   p_configuration_information28  No   varchar2 Configuration flexfield.
--   p_configuration_information29  No   varchar2 Configuration flexfield.
--   p_configuration_information30  No   varchar2 Configuration flexfield.
--   p_prefix_reporting_name        No   varchar2 Prefix reporting name
--                                                with base_name (Y or N).
--   p_allow_base_name_reuse        No   boolean  Allow base name to be
--                                                shared across user
--                                                structures within a
--                                                business group.
--
-- Post Success:
--   If p_validate is false, a new template is created. Otherwise no new
--   core schema objects are created.
--
--   Name                           Type     Description
--   p_template_id                  number   If p_validate is false, this
--                                           identifies the template created.
--                                           If p_validate is true, this is
--                                           set to null.
--   p_object_version_number        number   If p_validate is false, this is
--                                           set to the version number of the
--                                           PAY_ELEMENT_TEMPLATES row whose
--                                           template_id is returned in
--                                           p_template_id. If p_validate is
--                                           true, this is set to null.
--
-- Post Failure:
--   Any work done is rolled back and an exception is raised.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_user_structure
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_business_group_id             in     number
  ,p_source_template_id            in     number
  ,p_base_name                     in     varchar2
  ,p_base_processing_priority      in     number   default null
  ,p_preference_info_category      in     varchar2 default null
  ,p_preference_information1       in     varchar2 default null
  ,p_preference_information2       in     varchar2 default null
  ,p_preference_information3       in     varchar2 default null
  ,p_preference_information4       in     varchar2 default null
  ,p_preference_information5       in     varchar2 default null
  ,p_preference_information6       in     varchar2 default null
  ,p_preference_information7       in     varchar2 default null
  ,p_preference_information8       in     varchar2 default null
  ,p_preference_information9       in     varchar2 default null
  ,p_preference_information10      in     varchar2 default null
  ,p_preference_information11      in     varchar2 default null
  ,p_preference_information12      in     varchar2 default null
  ,p_preference_information13      in     varchar2 default null
  ,p_preference_information14      in     varchar2 default null
  ,p_preference_information15      in     varchar2 default null
  ,p_preference_information16      in     varchar2 default null
  ,p_preference_information17      in     varchar2 default null
  ,p_preference_information18      in     varchar2 default null
  ,p_preference_information19      in     varchar2 default null
  ,p_preference_information20      in     varchar2 default null
  ,p_preference_information21      in     varchar2 default null
  ,p_preference_information22      in     varchar2 default null
  ,p_preference_information23      in     varchar2 default null
  ,p_preference_information24      in     varchar2 default null
  ,p_preference_information25      in     varchar2 default null
  ,p_preference_information26      in     varchar2 default null
  ,p_preference_information27      in     varchar2 default null
  ,p_preference_information28      in     varchar2 default null
  ,p_preference_information29      in     varchar2 default null
  ,p_preference_information30      in     varchar2 default null
  ,p_configuration_info_category   in     varchar2 default null
  ,p_configuration_information1    in     varchar2 default null
  ,p_configuration_information2    in     varchar2 default null
  ,p_configuration_information3    in     varchar2 default null
  ,p_configuration_information4    in     varchar2 default null
  ,p_configuration_information5    in     varchar2 default null
  ,p_configuration_information6    in     varchar2 default null
  ,p_configuration_information7    in     varchar2 default null
  ,p_configuration_information8    in     varchar2 default null
  ,p_configuration_information9    in     varchar2 default null
  ,p_configuration_information10   in     varchar2 default null
  ,p_configuration_information11   in     varchar2 default null
  ,p_configuration_information12   in     varchar2 default null
  ,p_configuration_information13   in     varchar2 default null
  ,p_configuration_information14   in     varchar2 default null
  ,p_configuration_information15   in     varchar2 default null
  ,p_configuration_information16   in     varchar2 default null
  ,p_configuration_information17   in     varchar2 default null
  ,p_configuration_information18   in     varchar2 default null
  ,p_configuration_information19   in     varchar2 default null
  ,p_configuration_information20   in     varchar2 default null
  ,p_configuration_information21   in     varchar2 default null
  ,p_configuration_information22   in     varchar2 default null
  ,p_configuration_information23   in     varchar2 default null
  ,p_configuration_information24   in     varchar2 default null
  ,p_configuration_information25   in     varchar2 default null
  ,p_configuration_information26   in     varchar2 default null
  ,p_configuration_information27   in     varchar2 default null
  ,p_configuration_information28   in     varchar2 default null
  ,p_configuration_information29   in     varchar2 default null
  ,p_configuration_information30   in     varchar2 default null
  ,p_prefix_reporting_name         in     varchar2 default 'N'
  ,p_allow_base_name_reuse         in     boolean  default false
  ,p_template_id                      out nocopy number
  ,p_object_version_number            out nocopy number
  );
-- ----------------------------------------------------------------------------
-- |---------------------------< generate_part1 >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API takes a template and creates the core schema objects that that
--   template specifies (subject to the restriction that the objects can
--   be created before formula compilation). The caller may further restrict
--   the objects created by setting the p_hr_only flag to true.
--
-- Prerequisites:
--   The template (p_template_id) must exist and be of template type 'U'.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  If true, the database remains
--                                                unchanged. If false then the
--                                                core schema objects will be
--                                                created.
--   p_effective_date               Yes  date     Effective start date for the
--                                                generated objects.
--   p_hr_only                      Yes  boolean  If true, only HR objects are
--                                                generated.
--                                                If false, HR and PAYROLL
--                                                objects are generated.
--   p_hr_to_payroll                Yes  boolean  If true, it is assumed that
--                                                HR objects exist for this
--                                                template and PAYROLL objects
--                                                are created.
--   p_template_id                  Yes  number   Identifies the template from
--                                                which the core schema objects
--                                                will be generated.
--
-- Post Success:
--   If p_validate is false, the core schema objects are created, and rows
--   are created in PAY_TEMPLATE_CORE_OBJECTS to refer to the new core schema
--   objects. If p_validate is true, any work done is rolled back.
--
-- Post Failure:
--   Any work done is rolled back and an exception is raised.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure generate_part1
  (p_validate                      in     boolean default false
  ,p_effective_date                in     date
  ,p_hr_only                       in     boolean default false
  ,p_hr_to_payroll                 in     boolean default false
  ,p_template_id                   in     number
  );
-- ----------------------------------------------------------------------------
-- |---------------------------< generate_part2 >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API takes a template and creates the core schema objects that that
--   template specifies (subject to the restriction that these objects depend
--   on the PAYROLL formulas, specified by the template, having been compiled).
--
-- Prerequisites:
--   The template (referred to by p_template_id) must exist, generate_part1
--   was called successfully with this template (to create HR and PAYROLL
--   objects), and any formulas specified by this template have been compiled.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  If true, the database remains
--                                                unchanged. If false then the
--                                                core schema objects will be
--                                                created.
--   p_effective_date               Yes  date     Effective start date for the
--                                                generated objects.
--   p_template_id                  Yes  number   Identifies the template from
--                                                which the core schema objects
--                                                will be generated.
--
-- Post Success:
--   If p_validate is false, the core schema objects are created, and rows
--   are created in PAY_TEMPLATE_CORE_OBJECTS to refer to the new core schema
--   objects. If p_validate is true, any work done is rolled back.
--
-- Post Failure:
--   Any work done is rolled back and an exception is raised.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure generate_part2
  (p_validate                      in     boolean default false
  ,p_effective_date                in     date
  ,p_template_id                   in     number
  );
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_template >----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API deletes a template. This API does not delete any core schema
--   objects created from the template. It's main purpose is to delete
--   templates from which other templates are generated (template type 'T').
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  If true, the database remains
--                                                unchanged. If false then the
--                                                template will be deleted.
--   p_template_id                  Yes  boolean  Identifies the template to
--                                                be deleted.
--
-- Post Success:
--   If p_validate is false, the template will be deleted. Otherwise, there is
--   no change to the template.
--
-- Post Failure:
--   Any deletes are rolled back and an exception is raised.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_template
  (p_validate                      in     boolean default false
  ,p_template_id                   in     number
  );
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_user_structure >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API deletes a template and all shadow schema objects associated with
--   it. This API also (zap) deletes any core schema objects created from the
--   template.
--
-- Prerequisites:
--   The template must exist and be of template type 'U'.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes  boolean  If true, the database remains
--                                                unchanged. If false then the
--                                                template and any core schema
--                                                objects created from it will
--                                                be deleted.
--   p_drop_formula_packages        Yes  boolean  If true, any formula
--                                                packages created from the
--                                                template are dropped.
--                                                If false, the formula
--                                                packages are not dropped.
--   p_template_id                  Yes  number   Identifies the template to
--                                                be deleted.
-- Post Success:
--   If p_validate is false, then the template is deleted and any associated
--   core schema objects are (zap) deleted. Otherwise, there are no changes
--   to the database.
--
--   Name                           Type     Description
--
-- Post Failure:
--   Any (non-package) deletes are rolled back and an exception is raised.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_user_structure
  (p_validate                      in     boolean default false
  ,p_drop_formula_packages         in     boolean
  ,p_template_id                   in     number
  );
end pay_element_template_api;

 

/
