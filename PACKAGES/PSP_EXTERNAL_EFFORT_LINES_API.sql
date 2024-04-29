--------------------------------------------------------
--  DDL for Package PSP_EXTERNAL_EFFORT_LINES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_EXTERNAL_EFFORT_LINES_API" AUTHID CURRENT_USER AS
/* $Header: PSPEEAIS.pls 120.3 2006/07/06 13:25:21 tbalacha noship $ */

-- ----------------------------------------------------------------------------
-- |------------------------< insert_external_effort_line >------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
-- Creates an External Effort Report line
--
-- Prerequisites:
-- None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes boolean   Identifier for validation of effort report line
--   p_batch_name                   Yes varchar2  Identifier the Batch name for the effort which is to be created
--   p_distribution_date            Yes date      Date identifier on which the employee effort is distributed
--   p_person_id                    Yes number    Identifier for person id
--   p_assignment_id                Yes number    Identifier for Assignment id
--   p_currency_code                Yes varchar2  Currency Identifier for the effort report line
--   p_distribution_amount          Yes number    Amount column fo the effort report line
--   p_business_group_id            Yes number    Business group identifier
--   p_set_of_books_id              Yes number    Gl set of books identifier
--   p_gl_code_combination_id       Yes number    Identifier for GL code combination
--   p_project_id                   Yes number    Identifier for Projects
--   p_task_id                      Yes number    Identifier for Project Task
--   p_award_id                     Yes number    Identifier for award
--   p_expenditure_organization_id  Yes number    Identifier for Exp Org
--   p_expenditure_type             Yes varchar2  identifier for Expenditure type
--   p_attribute_category           Yes varchar2  Additional Information category
--   p_attribute1                   Yes varchar2  Identifier for Extra information column
--   p_attribute2                   Yes varchar2  Identifier for Extra information column
--   p_attribute3                   Yes varchar2  Identifier for Extra information column
--   p_attribute4                   Yes varchar2  Identifier for Extra information column
--   p_attribute5                   Yes varchar2  Identifier for Extra information column
--   p_attribute6                   Yes varchar2  Identifier for Extra information column
--   p_attribute7                   Yes varchar2  Identifier for Extra information column
--   p_attribute8                   Yes varchar2  Identifier for Extra information column
--   p_attribute9                   Yes varchar2  Identifier for Extra information column
--   p_attribute10                  Yes varchar2  Identifier for Extra information column
--   p_attribute11                  Yes varchar2  Identifier for Extra information column
--   p_attribute12                  Yes varchar2  Identifier for Extra information column
--   p_attribute13                  Yes varchar2  Identifier for Extra information column
--   p_attribute14                  Yes varchar2  Identifier for Extra information column
--   p_attribute15                  Yes varchar2  Identifier for Extra information column
--
-- Post Success:
-- External Effort Report approval line is created
--
-- Post Failure:
-- External Effort Report approval line is not created and an error is raised
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure insert_external_effort_line
( p_validate                     in             boolean  default false
, p_batch_name                   in             varchar2
, p_distribution_date            in             date
, p_person_id                    in             number
, p_assignment_id                in             number
, p_currency_code                in             varchar2
, p_distribution_amount          in             number
, p_business_group_id            in             number
, p_set_of_books_id              in             number
, p_gl_code_combination_id       in             number   default null
, p_project_id                   in             number   default null
, p_task_id                      in             number   default null
, p_award_id                     in             number   default null
, p_expenditure_organization_id  in             number   default null
, p_expenditure_type             in             varchar2 default null
, p_attribute_category           in             varchar2 default null
, p_attribute1                   in             varchar2 default null
, p_attribute2                   in             varchar2 default null
, p_attribute3                   in             varchar2 default null
, p_attribute4                   in             varchar2 default null
, p_attribute5                   in             varchar2 default null
, p_attribute6                   in             varchar2 default null
, p_attribute7                   in             varchar2 default null
, p_attribute8                   in             varchar2 default null
, p_attribute9                   in             varchar2 default null
, p_attribute10                  in             varchar2 default null
, p_attribute11                  in             varchar2 default null
, p_attribute12                  in             varchar2 default null
, p_attribute13                  in             varchar2 default null
, p_attribute14                  in             varchar2 default null
, p_attribute15                  in             varchar2 default null
, p_object_version_number        in out nocopy  number
, p_external_effort_line_id         out nocopy  number
, p_return_status                   out	nocopy  boolean
);
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_external_effort_line >----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
-- Updates an External Effort Report line
--
-- Prerequisites:
-- None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     yes boolean   Identifier  for validation of effort report line
--   p_external_effort_line_id      yes number    Identifier for external effort lines which needs to be updated
--   p_batch_name                   Yes varchar2  Identifier the Batch name for the effort which is to be created
--   p_distribution_date            Yes date      Date identifier on which the employee effort is distributed
--   p_person_id                    Yes number    Identifier for person id
--   p_assignment_id                Yes number    Identifier for Assignment id
--   p_currency_code                Yes varchar2  Currency Identifier for the effort report line
--   p_distribution_amount          Yes number    Amount column fo the effort report line
--   p_business_group_id            Yes number    Business group identifier
--   p_set_of_books_id              Yes number    Gl set of books identifier
--   p_gl_code_combination_id       Yes number    Identifier for GL code combination
--   p_project_id                   Yes number    Identifier for Projects
--   p_task_id                      Yes number    Identifier for Project Task
--   p_award_id                     Yes number    Identifier for award
--   p_expenditure_organization_id  Yes number    Identifier for Exp Org
--   p_expenditure_type             Yes varchar2  identifier for Expenditure type
--   p_attribute_category           Yes varchar2  Additional Information category
--   p_attribute1                   Yes varchar2  Identifier for Extra information column
--   p_attribute2                   Yes varchar2  Identifier for Extra information column
--   p_attribute3                   Yes varchar2  Identifier for Extra information column
--   p_attribute4                   Yes varchar2  Identifier for Extra information column
--   p_attribute5                   Yes varchar2  Identifier for Extra information column
--   p_attribute6                   Yes varchar2  Identifier for Extra information column
--   p_attribute7                   Yes varchar2  Identifier for Extra information column
--   p_attribute8                   Yes varchar2  Identifier for Extra information column
--   p_attribute9                   Yes varchar2  Identifier for Extra information column
--   p_attribute10                  Yes varchar2  Identifier for Extra information column
--   p_attribute11                  Yes varchar2  Identifier for Extra information column
--   p_attribute12                  Yes varchar2  Identifier for Extra information column
--   p_attribute13                  Yes varchar2  Identifier for Extra information column
--   p_attribute14                  Yes varchar2  Identifier for Extra information column
--   p_attribute15                  Yes varchar2  Identifier for Extra information column
--
-- Post Success:
-- External Effort Report approval line is updated
--
-- Post Failure:
-- External Effort Report approval line is not updated and an error is raised
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure update_external_effort_line
( p_validate                     in             boolean  default false
, p_external_effort_line_id      in             number
, p_batch_name                   in             varchar2 default hr_api.g_varchar2
, p_distribution_date            in             date     default hr_api.g_date
, p_person_id                    in             number   default hr_api.g_number
, p_assignment_id                in             number   default hr_api.g_number
, p_currency_code                in             varchar2 default hr_api.g_varchar2
, p_distribution_amount          in             number   default hr_api.g_number
, p_business_group_id            in             number   default hr_api.g_number
, p_set_of_books_id              in             number   default hr_api.g_number
, p_gl_code_combination_id       in             number   default hr_api.g_number
, p_project_id                   in             number   default hr_api.g_number
, p_task_id                      in             number   default hr_api.g_number
, p_award_id                     in             number   default hr_api.g_number
, p_expenditure_organization_id  in             number   default hr_api.g_number
, p_expenditure_type             in             varchar2 default hr_api.g_varchar2
, p_attribute_category           in             varchar2 default hr_api.g_varchar2
, p_attribute1                   in             varchar2 default hr_api.g_varchar2
, p_attribute2                   in             varchar2 default hr_api.g_varchar2
, p_attribute3                   in             varchar2 default hr_api.g_varchar2
, p_attribute4                   in             varchar2 default hr_api.g_varchar2
, p_attribute5                   in             varchar2 default hr_api.g_varchar2
, p_attribute6                   in             varchar2 default hr_api.g_varchar2
, p_attribute7                   in             varchar2 default hr_api.g_varchar2
, p_attribute8                   in             varchar2 default hr_api.g_varchar2
, p_attribute9                   in             varchar2 default hr_api.g_varchar2
, p_attribute10                  in             varchar2 default hr_api.g_varchar2
, p_attribute11                  in             varchar2 default hr_api.g_varchar2
, p_attribute12                  in             varchar2 default hr_api.g_varchar2
, p_attribute13                  in             varchar2 default hr_api.g_varchar2
, p_attribute14                  in             varchar2 default hr_api.g_varchar2
, p_attribute15                  in             varchar2 default hr_api.g_varchar2
, p_object_version_number        in out nocopy  number
, p_return_status                   out	nocopy  boolean
);

--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_external_effort_line >----------------------|
-- ----------------------------------------------------------------------------
--
--
-- {Start Of Comments}
--
-- Description:
-- Delete an External Effort Report line
--
-- Prerequisites:
-- None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     Yes boolean   Identifier for validation of effort report
--   p_external_effort_line_id      Yes number    External effort line identifier which needs to get deletd
--   p_object_version_number        Yes number    The object version number which establish concurrency.
--
-- Post Success:
-- External Effort Report approval line is deleted
--
-- Post Failure:
-- External Effort Report approval line is not deleted and an error is raised
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}

procedure delete_external_effort_line
( p_validate                     in             boolean  default false
, p_external_effort_line_id      in             number
, p_object_version_number        in out nocopy  number
) ;

/*
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_external_effort_line_batch >----------------------|
-- ----------------------------------------------------------------------------
--

-- procedure delete_external_effort_line_batch
-- ( p_validate                     in             boolean  default false
-- , p_batch_name                   in             varchar2
-- , p_person_id                    in             number   default hr_api.g_number
-- , p_assignment_id                in             number   default hr_api.g_number
-- , p_return_status                   out	nocopy  boolean
-- );
*/
end psp_external_effort_lines_api;

/
