--------------------------------------------------------
--  DDL for Package HR_CANVAS_PROPERTIES_BSI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CANVAS_PROPERTIES_BSI" AUTHID CURRENT_USER as
/* $Header: hrcnpbsi.pkh 115.3 2003/09/24 01:59:18 bsubrama noship $ */
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_canvas_property >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: This business support process inserts a new canvas property
--              in the HR Schema.
--
-- Prerequisites:
--
--
-- In Parameters:
--     Name                           Reqd Type     Description
--     p_form_canvas_id                  N number
--     p_template_canvas_id              N number
--     p_height                          N number
--     p_width                           N number
--     p_x_position                      N number
--     p_y_position                      N number
--     p_information_category            N varchar2
--     p_information1                    N varchar2
--     p_information2                    N varchar2
--     p_information3                    N varchar2
--     p_information4                    N varchar2
--     p_information5                    N varchar2
--     p_information6                    N varchar2
--     p_information7                    N varchar2
--     p_information8                    N varchar2
--     p_information9                    N varchar2
--     p_information10                   N varchar2
--     p_information11                   N varchar2
--     p_information12                   N varchar2
--     p_information13                   N varchar2
--     p_information14                   N varchar2
--     p_information15                   N varchar2
--     p_information16                   N varchar2
--     p_information17                   N varchar2
--     p_information18                   N varchar2
--     p_information19                   N varchar2
--     p_information20                   N varchar2
--     p_information21                   N varchar2
--     p_information22                   N varchar2
--     p_information23                   N varchar2
--     p_information24                   N varchar2
--     p_information25                   N varchar2
--     p_information26                   N varchar2
--     p_information27                   N varchar2
--     p_information28                   N varchar2
--     p_information29                   N varchar2
--     p_information30                   N varchar2
--
--
-- Post Success:
--
--
--     Name                           Type     Description
--     p_canvas_property_id           number
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure create_canvas_property
  (p_validate                        in     boolean  default false
  ,p_effective_date                  in     date
  ,p_form_canvas_id                  in number default null
  ,p_template_canvas_id              in number default null
  ,p_height                          in number default null
  ,p_visible                         in number default null
  ,p_width                           in number default null
  ,p_x_position                      in number default null
  ,p_y_position                      in number default null
  ,p_information_category            in varchar2 default null
  ,p_information1                    in varchar2 default null
  ,p_information2                    in varchar2 default null
  ,p_information3                    in varchar2 default null
  ,p_information4                    in varchar2 default null
  ,p_information5                    in varchar2 default null
  ,p_information6                    in varchar2 default null
  ,p_information7                    in varchar2 default null
  ,p_information8                    in varchar2 default null
  ,p_information9                    in varchar2 default null
  ,p_information10                   in varchar2 default null
  ,p_information11                   in varchar2 default null
  ,p_information12                   in varchar2 default null
  ,p_information13                   in varchar2 default null
  ,p_information14                   in varchar2 default null
  ,p_information15                   in varchar2 default null
  ,p_information16                   in varchar2 default null
  ,p_information17                   in varchar2 default null
  ,p_information18                   in varchar2 default null
  ,p_information19                   in varchar2 default null
  ,p_information20                   in varchar2 default null
  ,p_information21                   in varchar2 default null
  ,p_information22                   in varchar2 default null
  ,p_information23                   in varchar2 default null
  ,p_information24                   in varchar2 default null
  ,p_information25                   in varchar2 default null
  ,p_information26                   in varchar2 default null
  ,p_information27                   in varchar2 default null
  ,p_information28                   in varchar2 default null
  ,p_information29                   in varchar2 default null
  ,p_information30                   in varchar2 default null
  ,p_canvas_property_id                out nocopy number
  ,p_object_version_number             out nocopy number
  );
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_canvas_property >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: This business support process updates a canvas property
--              in the HR Schema.
--
-- Prerequisites:
--
--
-- In Parameters:
--     Name                           Reqd Type     Description
--     p_canvas_property_id              N number
--     p_form_canvas_id                  N number
--     p_template_canvas_id              N number
--     p_height                          N number
--     p_width                           N number
--     p_x_position                      N number
--     p_y_position                      N number
--     p_information_category            N varchar2
--     p_information1                    N varchar2
--     p_information2                    N varchar2
--     p_information3                    N varchar2
--     p_information4                    N varchar2
--     p_information5                    N varchar2
--     p_information6                    N varchar2
--     p_information7                    N varchar2
--     p_information8                    N varchar2
--     p_information9                    N varchar2
--     p_information10                   N varchar2
--     p_information11                   N varchar2
--     p_information12                   N varchar2
--     p_information13                   N varchar2
--     p_information14                   N varchar2
--     p_information15                   N varchar2
--     p_information16                   N varchar2
--     p_information17                   N varchar2
--     p_information18                   N varchar2
--     p_information19                   N varchar2
--     p_information20                   N varchar2
--     p_information21                   N varchar2
--     p_information22                   N varchar2
--     p_information23                   N varchar2
--     p_information24                   N varchar2
--     p_information25                   N varchar2
--     p_information26                   N varchar2
--     p_information27                   N varchar2
--     p_information28                   N varchar2
--     p_information29                   N varchar2
--     p_information30                   N varchar2
--
--
-- Post Success:
--
--
--   Name                           Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure update_canvas_property
  (p_validate                        in     boolean  default false
  ,p_effective_date                  in     date
  ,p_canvas_property_id              in number default null
  ,p_object_version_number           in out nocopy number
  ,p_form_canvas_id                  in number default null
  ,p_template_canvas_id              in number default null
  ,p_height                          in number default hr_api.g_number
  ,p_visible                         in number default hr_api.g_number
  ,p_width                           in number default hr_api.g_number
  ,p_x_position                      in number default hr_api.g_number
  ,p_y_position                      in number default hr_api.g_number
  ,p_information_category            in varchar2 default hr_api.g_varchar2
  ,p_information1                    in varchar2 default hr_api.g_varchar2
  ,p_information2                    in varchar2 default hr_api.g_varchar2
  ,p_information3                    in varchar2 default hr_api.g_varchar2
  ,p_information4                    in varchar2 default hr_api.g_varchar2
  ,p_information5                    in varchar2 default hr_api.g_varchar2
  ,p_information6                    in varchar2 default hr_api.g_varchar2
  ,p_information7                    in varchar2 default hr_api.g_varchar2
  ,p_information8                    in varchar2 default hr_api.g_varchar2
  ,p_information9                    in varchar2 default hr_api.g_varchar2
  ,p_information10                   in varchar2 default hr_api.g_varchar2
  ,p_information11                   in varchar2 default hr_api.g_varchar2
  ,p_information12                   in varchar2 default hr_api.g_varchar2
  ,p_information13                   in varchar2 default hr_api.g_varchar2
  ,p_information14                   in varchar2 default hr_api.g_varchar2
  ,p_information15                   in varchar2 default hr_api.g_varchar2
  ,p_information16                   in varchar2 default hr_api.g_varchar2
  ,p_information17                   in varchar2 default hr_api.g_varchar2
  ,p_information18                   in varchar2 default hr_api.g_varchar2
  ,p_information19                   in varchar2 default hr_api.g_varchar2
  ,p_information20                   in varchar2 default hr_api.g_varchar2
  ,p_information21                   in varchar2 default hr_api.g_varchar2
  ,p_information22                   in varchar2 default hr_api.g_varchar2
  ,p_information23                   in varchar2 default hr_api.g_varchar2
  ,p_information24                   in varchar2 default hr_api.g_varchar2
  ,p_information25                   in varchar2 default hr_api.g_varchar2
  ,p_information26                   in varchar2 default hr_api.g_varchar2
  ,p_information27                   in varchar2 default hr_api.g_varchar2
  ,p_information28                   in varchar2 default hr_api.g_varchar2
  ,p_information29                   in varchar2 default hr_api.g_varchar2
  ,p_information30                   in varchar2 default hr_api.g_varchar2
  );
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_canvas_property >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: This business support process deletes a canvas property
--              from the HR Schema.
--
-- Prerequisites:
--
--
-- In Parameters:
--     Name                           Reqd Type     Description
--     p_canvas_property_id              N number
--     p_form_canvas_id                  N number
--     p_template_canvas_id              N number
--
--
-- Post Success:
--
--
--   Name                           Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure delete_canvas_property
  (p_validate                      in     boolean  default false
  ,p_canvas_property_id              in number default null
  ,p_object_version_number           in number
  ,p_form_canvas_id                  in number default null
  ,p_template_canvas_id              in number default null
  );
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< copy_canvas_property >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: This business support process copies properties from a form
--              canvas to a template canvas. Any property may not be copied
--              by specifying the value required in the parameter list.
--
-- Prerequisites:
--
--
-- In Parameters:
--     Name                           Reqd Type     Description
--     p_form_canvas_id                  Y number
--     p_template_canvas_id              Y number
--     p_height                          N number
--     p_width                           N number
--     p_x_position                      N number
--     p_y_position                      N number
--     p_information_category            N varchar2
--     p_information1                    N varchar2
--     p_information2                    N varchar2
--     p_information3                    N varchar2
--     p_information4                    N varchar2
--     p_information5                    N varchar2
--     p_information6                    N varchar2
--     p_information7                    N varchar2
--     p_information8                    N varchar2
--     p_information9                    N varchar2
--     p_information10                   N varchar2
--     p_information11                   N varchar2
--     p_information12                   N varchar2
--     p_information13                   N varchar2
--     p_information14                   N varchar2
--     p_information15                   N varchar2
--     p_information16                   N varchar2
--     p_information17                   N varchar2
--     p_information18                   N varchar2
--     p_information19                   N varchar2
--     p_information20                   N varchar2
--     p_information21                   N varchar2
--     p_information22                   N varchar2
--     p_information23                   N varchar2
--     p_information24                   N varchar2
--     p_information25                   N varchar2
--     p_information26                   N varchar2
--     p_information27                   N varchar2
--     p_information28                   N varchar2
--     p_information29                   N varchar2
--     p_information30                   N varchar2
--
--
-- Post Success:
--
--
--     Name                           Type     Description
--     p_canvas_property_id           number
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure copy_canvas_property
  (p_validate                        in     boolean  default false
  ,p_effective_date                  in     date
  ,p_form_canvas_id                  in number
  ,p_template_canvas_id              in number
  ,p_height                          in number default hr_api.g_number
  ,p_visible                         in number default hr_api.g_number
  ,p_width                           in number default hr_api.g_number
  ,p_x_position                      in number default hr_api.g_number
  ,p_y_position                      in number default hr_api.g_number
  ,p_information_category            in varchar2 default hr_api.g_varchar2
  ,p_information1                    in varchar2 default hr_api.g_varchar2
  ,p_information2                    in varchar2 default hr_api.g_varchar2
  ,p_information3                    in varchar2 default hr_api.g_varchar2
  ,p_information4                    in varchar2 default hr_api.g_varchar2
  ,p_information5                    in varchar2 default hr_api.g_varchar2
  ,p_information6                    in varchar2 default hr_api.g_varchar2
  ,p_information7                    in varchar2 default hr_api.g_varchar2
  ,p_information8                    in varchar2 default hr_api.g_varchar2
  ,p_information9                    in varchar2 default hr_api.g_varchar2
  ,p_information10                   in varchar2 default hr_api.g_varchar2
  ,p_information11                   in varchar2 default hr_api.g_varchar2
  ,p_information12                   in varchar2 default hr_api.g_varchar2
  ,p_information13                   in varchar2 default hr_api.g_varchar2
  ,p_information14                   in varchar2 default hr_api.g_varchar2
  ,p_information15                   in varchar2 default hr_api.g_varchar2
  ,p_information16                   in varchar2 default hr_api.g_varchar2
  ,p_information17                   in varchar2 default hr_api.g_varchar2
  ,p_information18                   in varchar2 default hr_api.g_varchar2
  ,p_information19                   in varchar2 default hr_api.g_varchar2
  ,p_information20                   in varchar2 default hr_api.g_varchar2
  ,p_information21                   in varchar2 default hr_api.g_varchar2
  ,p_information22                   in varchar2 default hr_api.g_varchar2
  ,p_information23                   in varchar2 default hr_api.g_varchar2
  ,p_information24                   in varchar2 default hr_api.g_varchar2
  ,p_information25                   in varchar2 default hr_api.g_varchar2
  ,p_information26                   in varchar2 default hr_api.g_varchar2
  ,p_information27                   in varchar2 default hr_api.g_varchar2
  ,p_information28                   in varchar2 default hr_api.g_varchar2
  ,p_information29                   in varchar2 default hr_api.g_varchar2
  ,p_information30                   in varchar2 default hr_api.g_varchar2
  ,p_canvas_property_id                out nocopy number
  ,p_object_version_number             out nocopy number
  );
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< copy_canvas_property - overload>--------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: This business support process copies properties from a
--              template canvas to another template canvas. Any property may
--              not be copied by specifying the value required in the
--              parameter list.
--
-- Prerequisites:
--
--
-- In Parameters:
--     Name                           Reqd Type     Description
--     p_template_canvas_id_from         Y number
--     p_template_canvas_id_to           Y number
--     p_height                          N number
--     p_width                           N number
--     p_x_position                      N number
--     p_y_position                      N number
--     p_information_category            N varchar2
--     p_information1                    N varchar2
--     p_information2                    N varchar2
--     p_information3                    N varchar2
--     p_information4                    N varchar2
--     p_information5                    N varchar2
--     p_information6                    N varchar2
--     p_information7                    N varchar2
--     p_information8                    N varchar2
--     p_information9                    N varchar2
--     p_information10                   N varchar2
--     p_information11                   N varchar2
--     p_information12                   N varchar2
--     p_information13                   N varchar2
--     p_information14                   N varchar2
--     p_information15                   N varchar2
--     p_information16                   N varchar2
--     p_information17                   N varchar2
--     p_information18                   N varchar2
--     p_information19                   N varchar2
--     p_information20                   N varchar2
--     p_information21                   N varchar2
--     p_information22                   N varchar2
--     p_information23                   N varchar2
--     p_information24                   N varchar2
--     p_information25                   N varchar2
--     p_information26                   N varchar2
--     p_information27                   N varchar2
--     p_information28                   N varchar2
--     p_information29                   N varchar2
--     p_information30                   N varchar2
--
-- Post Success:
--
--     Name                           Type     Description
--     p_canvas_property_id           number
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure copy_canvas_property
  (p_validate                        in     boolean  default false
  ,p_effective_date                  in     date
  ,p_template_canvas_id_from         in number
  ,p_template_canvas_id_to           in number
  ,p_height                          in number default hr_api.g_number
  ,p_visible                         in number default hr_api.g_number
  ,p_width                           in number default hr_api.g_number
  ,p_x_position                      in number default hr_api.g_number
  ,p_y_position                      in number default hr_api.g_number
  ,p_information_category            in varchar2 default hr_api.g_varchar2
  ,p_information1                    in varchar2 default hr_api.g_varchar2
  ,p_information2                    in varchar2 default hr_api.g_varchar2
  ,p_information3                    in varchar2 default hr_api.g_varchar2
  ,p_information4                    in varchar2 default hr_api.g_varchar2
  ,p_information5                    in varchar2 default hr_api.g_varchar2
  ,p_information6                    in varchar2 default hr_api.g_varchar2
  ,p_information7                    in varchar2 default hr_api.g_varchar2
  ,p_information8                    in varchar2 default hr_api.g_varchar2
  ,p_information9                    in varchar2 default hr_api.g_varchar2
  ,p_information10                   in varchar2 default hr_api.g_varchar2
  ,p_information11                   in varchar2 default hr_api.g_varchar2
  ,p_information12                   in varchar2 default hr_api.g_varchar2
  ,p_information13                   in varchar2 default hr_api.g_varchar2
  ,p_information14                   in varchar2 default hr_api.g_varchar2
  ,p_information15                   in varchar2 default hr_api.g_varchar2
  ,p_information16                   in varchar2 default hr_api.g_varchar2
  ,p_information17                   in varchar2 default hr_api.g_varchar2
  ,p_information18                   in varchar2 default hr_api.g_varchar2
  ,p_information19                   in varchar2 default hr_api.g_varchar2
  ,p_information20                   in varchar2 default hr_api.g_varchar2
  ,p_information21                   in varchar2 default hr_api.g_varchar2
  ,p_information22                   in varchar2 default hr_api.g_varchar2
  ,p_information23                   in varchar2 default hr_api.g_varchar2
  ,p_information24                   in varchar2 default hr_api.g_varchar2
  ,p_information25                   in varchar2 default hr_api.g_varchar2
  ,p_information26                   in varchar2 default hr_api.g_varchar2
  ,p_information27                   in varchar2 default hr_api.g_varchar2
  ,p_information28                   in varchar2 default hr_api.g_varchar2
  ,p_information29                   in varchar2 default hr_api.g_varchar2
  ,p_information30                   in varchar2 default hr_api.g_varchar2
  ,p_canvas_property_id                out nocopy number
  ,p_object_version_number             out nocopy number
  );
--
end hr_canvas_properties_bsi;

 

/
