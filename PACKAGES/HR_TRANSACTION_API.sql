--------------------------------------------------------
--  DDL for Package HR_TRANSACTION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_TRANSACTION_API" AUTHID CURRENT_USER as
/* $Header: petrnapi.pkh 120.4.12000000.2 2007/05/04 18:39:47 srajakum ship $ */


--Global Variables
   g_update_flag varchar2(10) ; --ns

-- ----------------------------------------------------------------------------
-- |----------------------< get_transaction_step_info >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This API retrieves the transaction step information. If the transaction step does not exist
--   null is returned, else a corresponding value for the transaction step is returned.
--
-- Prerequisites:
--  None.
--
-- In Parameters:
--   Name                Reqd   Type         Description
--   p_item_type       yes    varchar2     Identifies the item type.
--   p_item_key        yes    varchar2     Identifies the item key.
--   p_activity_id      yes    number      Identifies the activity id.
--
-- Post Success:
--   The transaction step information is successfully retrieved.
--   Name                                     Type     Description
--    p_transaction_step_id        number  Identifies the transaction step.
--    p_object_version_number  number  Identifies the corresponding object version number.
--
-- Post Failure:
--  None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure get_transaction_step_info
  (p_item_type             in     varchar2
  ,p_item_key              in     varchar2
  ,p_activity_id           in     number
  ,p_transaction_step_id      out nocopy number
  ,p_object_version_number    out nocopy number);
-- --------------------------------------------------------------------
-- ------------------<< get_transaction_step_info >>-------------------
-- --------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API retrieves the transaction step data, where there may be more than
--    one transaction steps existing.
--
-- Prerequisites:
--  None
--
-- In Parameters:
--   Name             Reqd Type     Description
--   p_item_type   yes    varchar2     Identifies the item type.
--   p_item_key    yes    varchar2     Identifies the item key.
--   p_activity_id  yes    number      Identifies the activity id.
--
-- Post Success:
--   The transaction step information is successfully retrieved.
--   Name                                     Type     							Description
--    p_transaction_step_id       hr_util_web.g_varchar2_tab_type	Identifies the transactions steps
--    p_object_version_number hr_util_web.g_varchar2_tab_type	Identifies the corresponding object version numbers.
--    p_rows					number							Identifies the number of transaction steps returned.
--
-- Post Failure:
--  None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure get_transaction_step_info
  (p_item_type            in varchar2
  ,p_item_key             in varchar2
  ,p_activity_id  in number
  ,p_transaction_step_id  out nocopy  hr_util_web.g_varchar2_tab_type
  ,p_object_version_number out nocopy hr_util_web.g_varchar2_tab_type
  ,p_rows out nocopy number);
-- --------------------------------------------------------------------
-- ------------------<< get_transaction_step_info >>-------------------
-- --------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This API retrieves the transaction step data, where there may be more than
--    one transaction steps existing.
--
-- Prerequisites:
--  None
--
-- In Parameters:
--   Name             Reqd Type     Description
--   p_item_type   yes    varchar2     Identifies the item type.
--   p_item_key    yes    varchar2     Identifies the item key.
--
-- Post Success:
--   The transaction step information is successfully retrieved.
--   Name                                     Type     		                                      Description
--    p_transaction_step_id       hr_util_web.g_varchar2_tab_type   Identifies the transactions steps
--    p_object_version_number hr_util_web.g_varchar2_tab_type  Identifies the corresponding object version numbers.
--    p_rows                                   number                                                 Identifies the number of transaction steps returned.
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure get_transaction_step_info
  (p_item_type            in varchar2
  ,p_item_key             in varchar2
  ,p_transaction_step_id  out nocopy  hr_util_web.g_varchar2_tab_type
  ,p_object_version_number out nocopy hr_util_web.g_varchar2_tab_type
  ,p_rows out nocopy number);
-- ----------------------------------------------------------------------------
-- |----------------------< get_transaction_step_info >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API retrieves the transaction step information when transaction step id is provided.
--
-- Prerequisites:
--  The transaction step must exist.
--
-- In Parameters:
--   Name                             Reqd Type     Description
--    p_transaction_step_id   yes  number  Identifies the transaction step.
--
-- Post Success:
--   The transaction step information is successfully retrieved.
--   Name            Type         Description
--   p_item_type   varchar2 Identifies the item type.
--   p_item_key    varchar2 Identifies the item key.
--   p_activity_id  number    Identifies the activity id.
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure get_transaction_step_info
  (p_transaction_step_id   in     number
  ,p_item_type                out nocopy varchar2
  ,p_item_key                 out nocopy varchar2
  ,p_activity_id              out nocopy number);
-- --------------------------------------------------------------------
-- ------------------<< get_transaction_step_info >>-------------------
-- --------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API retrieves the transaction step data, where there may be more than
--    one transaction steps existing. The input activity id may be null.
--
-- Prerequisites:
--  None
--
-- In Parameters:
--   Name             Reqd Type     Description
--   p_item_type   yes    varchar2     Identifies the item type.
--   p_item_key    yes    varchar2     Identifies the item key.
--   p_activity_id    no     number      Identifies the activity id.
--
-- Post Success:
--   The transaction step information is successfully retrieved.
--   Name                                     Type     							 Description
--    p_transaction_step_id       hr_util_web.g_varchar2_tab_type  Identifies the transactions steps
--    p_api_name out nocopy     hr_util_web.g_varchar2_tab_type Identifies the corresponding API for the transaction steps.
--    p_rows                                     number                                              Identifies the number of transaction steps returned.
--
-- Post Failure:
--  None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure get_transaction_step_info
  (p_item_type            in varchar2
  ,p_item_key             in varchar2
  ,p_activity_id          in number default null
  ,p_transaction_step_id  out nocopy  hr_util_web.g_varchar2_tab_type
  ,p_api_name out nocopy hr_util_web.g_varchar2_tab_type
  ,p_rows out nocopy number);
-- ----------------------------------------------------------------------------
-- |-----------------------< transaction_step_exist >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This function returns true if a transaction step exists corresponding to the input parameters.
--
-- Prerequisites:
--  None
--
-- In Parameters:
--   Name                 Reqd  Type           Description
--   p_item_type       yes    varchar2     Identifies the item type.
--   p_item_key        yes    varchar2     Identifies the item key.
--   p_activity_id      yes    number      Identifies the activity id.
--
-- Post Success:
-- The function returns a true if the transaction step exists else returns a false.
--
-- Post Failure:
--  None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
function transaction_step_exist
  (p_item_type   in varchar2
  ,p_item_key    in varchar2
  ,p_activity_id in number) return boolean;
-- ----------------------------------------------------------------------------
-- |---------------------------< create_transaction >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This API creates a new transaction.
--
-- Prerequisites:
--  None
--
-- In Parameters:
--   Name                            Reqd Type        Description
--   p_validate                      no     boolean  If true, then validation alone will be performed and
--                                                                        the database will remain unchanged. If false and all
--		                                                           validation checks pass, then the database will be modified.
--   p_creator_person_id     yes   number  Identifies the person creating the transaction.
--   p_transaction_privilege yes   varchar2 Identifies the transaction privilege.
--
-- Post Success:
--  A transaction is created.
--   Name                           Type     Description
--    p_transaction_id         number Identifies the new transaction created.
--
-- Post Failure:
--  The transaction is not created and an error is raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure create_transaction
  (p_validate                     in      boolean   default false
  ,p_creator_person_id            in      number
  ,p_transaction_privilege        in      varchar2
  ,p_transaction_id                  out nocopy  number);
-- ----------------------------------------------------------------------------
-- |-----------------------< create_trans_step >-------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API creates a transaction step.
--
-- Prerequisites:
--   None
--
-- In Parameters:
--   Name                           Reqd  Type          Description
--   p_validate                    no     boolean    If true, then validation alone will be performed and
--                                                                         the database will remain unchanged. If false and all
--									    validation checks pass, then the database will be modified.
--   p_creator_person_id    yes  number      Identifies the person creating the transaction.
--   p_transaction_id           yes  number      Identifies the base transaction.
--   p_api_name                  yes  varchar2      Identifies the API name.
--   p_api_display_name    no   varchar2    Identifies the API display name.
--   p_item_type                  no   varchar2      Identifies the Item Type.
--   p_item_key                    no    varchar2     Identifies the Item Key.
--   p_activity_id                  no    number        Identifies the Activity Id.
--   p_processing_order    no    number     Identifies the processing order.
--
-- Post Success:
--   A transaction step is created.
--   Name                                     Type     Description
--    p_transaction_step_id        number  Identifies the transaction step.
--    p_object_version_number  number  Identifies the corresponding object version number.
--
-- Post Failure:
--  Transaction step is not created and an error is raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure create_trans_step
  (p_validate                     in      boolean  default false
  ,p_creator_person_id            in      number
  ,p_transaction_id               in      number
  ,p_api_name                     in      varchar2
  ,p_api_display_name             in      varchar2 default null
  ,p_item_type                    in      varchar2 default null
  ,p_item_key                     in      varchar2 default null
  ,p_activity_id                  in      number   default null
  ,p_processing_order             in      number   default null
  ,p_transaction_step_id             out nocopy  number
  ,p_object_version_number           out nocopy  number);
-- ----------------------------------------------------------------------------
-- |-----------------------< create_transaction_step >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API creates a transaction step.
--
-- Prerequisites:
--  None
--
-- In Parameters:
--   Name                           Reqd  Type          Description
--   p_validate                     no     boolean    If true, then validation alone will be performed and
--                                                                         the database will remain unchanged. If false and all
--									    validation checks pass, then the database will be modified.
--   p_creator_person_id    yes  number      Identifies the person creating the transaction.
--   p_transaction_id           yes  number      Identifies the base transaction.
--   p_api_name                  yes  varchar2      Identifies the API name.
--   p_api_display_name   no   varchar2    Identifies the API display name.
--   p_item_type                  no  varchar2      Identifies the Item Type.
--   p_item_key                    no    varchar2     Identifies the Item Key.
--   p_activity_id                 no    number        Identifies the Activity Id.
--
-- Post Success:
--   A transaction step is created.
--   Name                                     Type     Description
--    p_transaction_step_id        number  Identifies the transaction step.
--    p_object_version_number  number  Identifies the corresponding object version number.
--
-- Post Failure:
--  None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure create_transaction_step
  (p_validate                     in      boolean  default false
  ,p_creator_person_id            in      number
  ,p_transaction_id               in      number
  ,p_api_name                     in      varchar2
  ,p_api_display_name             in      varchar2 default null
  ,p_item_type                    in      varchar2 default null
  ,p_item_key                     in      varchar2 default null
  ,p_activity_id                  in      number   default null
  ,p_transaction_step_id             out nocopy  number
  ,p_object_version_number           out nocopy  number);
-- ----------------------------------------------------------------------------
-- |-----------------------< update_transaction_step >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--    This API updates a transaction step.
--
-- Prerequisites:
--  None
--
-- In Parameters:
--   Name                           Reqd  Type            Description
--   p_validate                    no     boolean        If true, then validation alone will be performed and
--                                                                          the database will remain unchanged. If false and all
--									     validation checks pass, then the database will be modified.
--   p_transaction_step_id  yes  number      Identifies the transaction step.
--   p_update_person_id    yes  number       Identifies the person updating the transaction.
--
-- Post Success:
--   The API returns the updated object version number.
--
--   Name                                  Type     Description
--   p_object_version_number  number Identifies the new object version no.
--
-- Post Failure:
-- Transaction step is not updated and an error is raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure update_transaction_step
  (p_validate                     in      boolean  default false
  ,p_transaction_step_id          in      number
  ,p_update_person_id             in      number
  ,p_object_version_number        in out nocopy  number);
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_transaction_step >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This API deletes the transaction step.
--
-- Prerequisites:
--  None
--
-- In Parameters:
--   Name                           Reqd  Type          Description
--   p_validate                     no     boolean    If true, then validation alone will be performed and
--									   the database will remain unchanged. If false and all
--									     validation checks pass, then the database will be modified.
--   p_transaction_step_id  yes  number      Identifies the transaction step.
--   p_update_person_id    yes  number       Identifies the person updating the transaction.
--   p_object_version_number    yes  number   Identifies the object version number.
--
-- Post Success:
--   The transaction step is deleted.
--
-- Post Failure:
-- The transaction step is not deleted and an error is raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure delete_transaction_step
  (p_validate                     in      boolean default false
  ,p_transaction_step_id          in      number
  ,p_person_id                    in      number
  ,p_object_version_number        in      number);
-- ----------------------------------------------------------------------------
-- |---------------------------< set_varchar2_value >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API saves a varchar2 value for a transaction step.
--
-- Prerequisites:
--  None
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_validate                     no    boolean  If true, then validation alone will be performed and
--                                                                      the database will remain unchanged. If false and all
--									 validation checks pass, then the database will be modified.
--   p_transaction_step_id  yes   number   Identifies the transaction step.
--   p_person_id                  yes   number   Identifies the person acting on the transaction.
--   p_name                         yes   varchar2 Identifies the varchar2 field.
--   p_value                         no    varchar2 Identifies the value to be saved for the field.
--   p_original_value            no    varchar2 Identifies the original value of the field.
--
--
-- Post Success:
--  The value is saved for a transaction step.
--
-- Post Failure:
--
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure set_varchar2_value
  (p_validate                   in     boolean  default false
  ,p_transaction_step_id        in     number
  ,p_person_id                  in     number
  ,p_name                       in     varchar2
  ,p_value                      in     varchar2 default null
  ,p_original_value             in     varchar2 default null ); --ns
-- ----------------------------------------------------------------------------
-- |---------------------------< set_number_value >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--    This API saves a number type value for a transaction step.
--
-- Prerequisites:
--  None
--
-- In Parameters:
--   Name                           Reqd Type         Description
--   p_validate                     no   boolean    If true, then validation alone will be performed and
--                                                                       the database will remain unchanged. If false and all
--									   validation checks pass, then the database will be modified.
--   p_transaction_step_id  yes  number    Identifies the transaction step.
--   p_person_id                  yes  number    Identifies the person acting on the transaction.
--   p_name                         yes  varchar2  Identifies the number field.
--   p_value                         no   number    Identifies the value to be saved for the field.
--   p_original_value            no   number    Identifies the original value of the field.
--
-- Post Success:
--    The value is saved for a transaction step.
--
-- Post Failure:
--   None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure set_number_value
  (p_validate                   in     boolean  default false
  ,p_transaction_step_id        in     number
  ,p_person_id                  in     number
  ,p_name                       in     varchar2
  ,p_value                      in     number   default null
  ,p_original_value             in     number   default null ); --ns
-- ----------------------------------------------------------------------------
-- |-----------------------------< set_date_value >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--    This API saves a date type value for a transaction step.
--
-- Prerequisites:
--  None
--
-- In Parameters:
--   Name                           Reqd Type         Description
--   p_validate                    no      boolean    If true, then validation alone will be performed and
--                                                                       the database will remain unchanged. If false and all
--									  validation checks pass, then the database will be modified.
--   p_transaction_step_id  yes  number   Identifies the transaction step.
--   p_person_id                  yes  number    Identifies the person acting on the transaction.
--   p_name                         yes    varchar2    Identifies the number type field.
--   p_value                          no     date            Identifies the value to be saved for the field.
--   p_original_value           no    date         Identifies the original value of the field.
--
--
-- Post Success:
--  The value is saved for a transaction step.
--
-- Post Failure:
--   None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure set_date_value
  (p_validate                   in     boolean  default false
  ,p_transaction_step_id        in     number
  ,p_person_id                  in     number
  ,p_name                       in     varchar2
  ,p_value                      in     date     default null
  ,p_original_value             in     date     default null );  --ns
-- ----------------------------------------------------------------------------
-- |--------------------------< set_boolean_value >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API saves a boolean type value for a transaction step.
--
-- Prerequisites:
--  None
--
-- In Parameters:
--   Name                           Reqd Type         Description
--   p_validate                     no   boolean    If true, then validation alone will be performed and
--                                                                       the database will remain unchanged. If false and all
--		                                                          validation checks pass, then the database will be modified.
--   p_transaction_step_id  yes  number   Identifies the transaction step.
--   p_person_id                  yes  number    Identifies the person acting on the transaction.
--   p_name                         yes  varchar2    Identifies the boolean type field.
--   p_value                          no    boolean     Identifies the value to be saved for the field.
--   p_original_value          no    boolean     Identifies the original value of the field.
--
-- Post Success:
--   The value is saved for the transaction step.
--
-- Post Failure:
--   None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure set_boolean_value
  (p_validate                   in     boolean  default false
  ,p_transaction_step_id        in     number
  ,p_person_id                  in     number
  ,p_name                       in     varchar2
  ,p_value                      in     boolean  default null
  ,p_original_value             in     boolean  default null ); --ns
-- ----------------------------------------------------------------------------
-- |------------------------------< get_value >-------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This API returns a value for a  particular parameter depending on its Type for the transaction step.
--
-- Prerequisites:
--  The transaction step should exist.
--
-- In Parameters:
--   Name                                Reqd  Type          Description
--   p_transaction_step_id   yes      number    Identifies the transaction step.
--   p_name                             yes      varchar2   Identifies the parameter name.
--
--
-- Post Success:
--
--   Name                           Type           Description
--   p_varchar2_value       varchar2   Identifies the parameter varchar2 type value.
--   p_number_value        number    Identifies the parameter number type value.
--   p_date_value               date          Identifies the parameter date type value.
--
-- Post Failure:
-- None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure get_value
  (p_transaction_step_id       in      number
  ,p_name                      in      varchar2
  ,p_datatype                      out nocopy varchar2
  ,p_varchar2_value                out nocopy varchar2
  ,p_number_value                  out nocopy number
  ,p_date_value                    out nocopy date);
-- ----------------------------------------------------------------------------
-- |---------------------------< get_varchar2_value >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This function returns a varchar2 type value for a particular parameter for the transaction step.
--
-- Prerequisites:
--  The transaction step should exist.
--
-- In Parameters:
--   Name                                Reqd  Type          Description
--   p_transaction_step_id   yes      number    Identifies the transaction step.
--   p_name                             yes      varchar2   Identifies the parameter name.
--
--
-- Post Success:
--   A varchar2 type value is returned.
--
-- Post Failure:
-- None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
function get_varchar2_value
  (p_transaction_step_id       in      number
  ,p_name                      in      varchar2) return varchar2;
-- ----------------------------------------------------------------------------
-- |-----------------------------< get_number_value >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This function returns a number value for a  particular parameter for the transaction step.
--
-- Prerequisites:
--  The transaction step should exist.
--
-- In Parameters:
--   Name                                Reqd  Type          Description
--   p_transaction_step_id   yes      number    Identifies the transaction step.
--   p_name                             yes      varchar2   Identifies the parameter name.
--
--
-- Post Success:
--   A number type value is returned.
--
-- Post Failure:
-- None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
function get_number_value
  (p_transaction_step_id       in      number
  ,p_name                      in      varchar2) return number;
-- ----------------------------------------------------------------------------
-- |-------------------------------< get_date_value >-------------------------|
-- ----------------------------------------------------------------------------
--- {Start Of Comments}
--
-- Description:
--  This function returns a date value for a  particular parameter for the transaction step.
--
-- Prerequisites:
--  The transaction step should exist.
--
-- In Parameters:
--   Name                                Reqd  Type          Description
--   p_transaction_step_id   yes      number    Identifies the transaction step.
--   p_name                             yes      varchar2   Identifies the parameter name.
--
--
-- Post Success:
--   A date value is returned.
--
-- Post Failure:
-- None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
function get_date_value
  (p_transaction_step_id       in      number
  ,p_name                      in      varchar2) return date;
--
-- 11/12/1997 Change Begins
-- ----------------------------------------------------------------------------
-- |-------------------------< get_date2char_value >--------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--  This function returns a date value in a preferred format.
--
-- Prerequisites:
--  The transaction step should exist.
--
-- In Parameters:
--   Name                                Reqd  Type          Description
--   p_transaction_step_id   yes      number    Identifies the transaction step.
--   p_name                             yes      varchar2   Identifies the parameter name.
--   p_date_format                  yes      varchar2   Identifies the date format.
--
-- Post Success:
--   A date in the prefered format is returned.
--
-- Post Failure:
-- None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
function get_date2char_value
  (p_transaction_step_id       in      number
  ,p_name                      in      varchar2
  ,p_date_format               in      varchar2) return varchar2;
--
-- 11/12/1997 Change Ends
--
-- ----------------------------------------------------------------------------
-- |----------------------------< get_boolean_value >-------------------------|
-- ----------------------------------------------------------------------------
--- {Start Of Comments}
--
-- Description:
--  This function returns a boolean value for a  particular parameter for the transaction step.
--
-- Prerequisites:
--  The transaction step should exist.
--
-- In Parameters:
--   Name                                Reqd  Type          Description
--   p_transaction_step_id   yes      number    Identifies the transaction step.
--   p_name                             yes      varchar2   Identifies the parameter name.
--
--
-- Post Success:
--   A boolean value is returned.
--
-- Post Failure:
-- None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
function get_boolean_value
  (p_transaction_step_id       in      number
  ,p_name                      in      varchar2) return boolean;
-- ----------------------------------------------------------------------------
-- |------------------------------< get_original_value >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API returns the original value for a parameter.
--
-- Prerequisites:
--  None
--
-- In Parameters:
--   Name                               Reqd  Type        Description
--   p_transaction_step_id  yes      number  Identifies the transaction step.
--   p_name                            yes      varchar2 Identifies the parameter.
--
--
-- Post Success:
--  An original value is returned.
--   Name                                    Type         Description
--  p_datatype                             varchar2  Identifies the datatype.
--  p_original_varchar2_value varchar2  Identifies a varchar2 type value.
--  p_original_number_value  number    Identifies a number type value.
--  p_original_date_value         date          Identifies a date type value.
--
-- Post Failure:
--  None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure get_original_value
  (p_transaction_step_id       in      number
  ,p_name                      in      varchar2
  ,p_datatype                      out nocopy varchar2
  ,p_original_varchar2_value       out nocopy varchar2
  ,p_original_number_value         out nocopy number
  ,p_original_date_value           out nocopy date);
-- ----------------------------------------------------------------------------
-- |---------------------------< get_original_varchar2_value >----------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function returns the original varchar2 type value for a parameter.
--
-- Prerequisites:
--  The transaction step should exist.
--
-- In Parameters:
--   Name                               Reqd  Type        Description
--   p_transaction_step_id  yes      number  Identifies the transaction step.
--   p_name                            yes      varchar2 Identifies the parameter.
--
--
-- Post Success:
--  An original varchar2 type value is returned.
--
-- Post Failure:
--  None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
function get_original_varchar2_value
  (p_transaction_step_id       in      number
  ,p_name                      in      varchar2) return varchar2;
-- ----------------------------------------------------------------------------
-- |--------------------< get_original_number_value >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function returns the number type value for a parameter.
--
-- Prerequisites:
--  The transaction step should exist.
--
-- In Parameters:
--   Name                               Reqd  Type        Description
--   p_transaction_step_id  yes      number  Identifies the transaction step.
--   p_name                            yes      varchar2 Identifies the parameter.
--
--
-- Post Success:
--  An original number type value is returned.
--
-- Post Failure:
--  None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
function get_original_number_value
  (p_transaction_step_id       in      number
  ,p_name                      in      varchar2) return number;
-- ----------------------------------------------------------------------------
-- |----------------------< get_original_date_value >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function returns the original date type value for a parameter.
--
-- Prerequisites:
--  The transaction step should exist.
--
-- In Parameters:
--   Name                               Reqd  Type        Description
--   p_transaction_step_id  yes      number  Identifies the transaction step.
--   p_name                            yes      varchar2 Identifies the parameter.
--
-- Post Success:
--  An original date type value is returned.
--
-- Post Failure:
--  None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
function get_original_date_value
  (p_transaction_step_id       in      number
  ,p_name                      in      varchar2) return date;
-- ----------------------------------------------------------------------------
-- |-------------------< get_original_boolean_value >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function returns the original boolean type value for a parameter.
--
-- Prerequisites:
--  The transaction step should exist.
--
-- In Parameters:
--   Name                               Reqd  Type        Description
--   p_transaction_step_id  yes      number  Identifies the transaction step.
--   p_name                            yes      varchar2 Identifies the parameter.
--
-- Post Success:
--  An original boolen type value is returned.
--
-- Post Failure:
--  None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
function get_original_boolean_value
  (p_transaction_step_id       in      number
  ,p_name                      in      varchar2) return boolean;
-- ----------------------------------------------------------------------------
-- |----------------------------< rollback_transaction >----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API reverts back the transaction.
--
-- Prerequisites:
--  The transaction must exist.
--
-- In Parameters:
--   Name                           Reqd Type      Description
--   p_transaction_id        yes    number  Identifies the transaction.
--   p_validate                    no     boolean  If true, then validation alone will be performed and
--                                                                     the database will remain unchanged. If false and all
--		                                                        validation checks pass, then the database will be modified.
--
-- Post Success:
--   The transaction is deleted.
--
-- Post Failure:
-- An exception is raised and the transaction is not rolled back.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure rollback_transaction
  (p_transaction_id in number
  ,p_validate       in boolean default false);
--
------------------------------------------------------------------------
----------------------- Get_Last_Process_Order--------------------------
------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function retrieves the last process order delimited by '%' from the process order string.
--
-- Prerequisites:
--  None
-- In Parameters:
--   Name                              Reqd  Type          Description
--   p_process_order_str    yes     varchar2   Identifies the process order string.
--
-- Post Success:
--  The Last Process order is retrieved.
--
-- Post Failure:
-- None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
function Get_Last_Process_Order
  (p_process_order_str in varchar2)
return varchar2;
--
------------------------------------------------------------------------
----------------------- Set_Process_Order_String------------------------
------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API constructs a string to concatenate activity id and a corresponding process order.
--
-- Prerequisites:
--  None
--
-- In Parameters:
--   Name                 Reqd Type			  Description
--   p_item_type      yes     Varchar2(8)       Identifies the item type.
--   p_item_key        yes    Varchar2(240)   Identifies teh item key.
--   p_actid                yes    Number              Identifies the activity id.
--
-- Post Success:
--   A corrsponding string is set. in wf attribute for PROCESS_ORDER_STRING.
--
-- Post Failure:
-- An error is raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure Set_Process_Order_String
  (p_item_type               in wf_items.item_type%type
  ,p_item_key                in wf_items.item_key%type
  ,p_actid                   in wf_activity_attr_values.process_activity_id%type
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------< Get_Process_Order >---------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This function gets the process order from the string stored in wf
--    attribute PROCESS_ORDER_STRING for the passed in activity id.
--
-- Prerequisites:
--  The activity id should exist.
--
-- In Parameters:
--   Name                 Reqd    Type                  Description
--   p_item_type      yes      Varchar2(8)       Identifies the item type.
--   p_item_key       yes       Varchar2(240)  Identifies teh item key.
--   p_actid               yes       Number             Identifies the activity id.
--
-- Post Success:
--   The process order is retrieved.
--
-- Post Failure:
-- An exception is raised.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
function Get_Process_Order
  (p_item_type               in wf_items.item_type%type
  ,p_item_key                in wf_items.item_key%type
  ,p_actid                   in wf_activity_attr_values.process_activity_id%type
)
  return varchar2;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_transaction >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--    This API creates a transaction.
--
-- Prerequisites:
--  None
-- In Parameters:
--   Name                               Reqd    Type        Description
--   p_validate                          no      boolean    If true, then validation alone will be performed and
--                                                                             the database will remain unchanged. If false and all
--		                                                                 validation checks pass, then the database will be modified.
--   p_creator_person_id     yes     number
--   p_transaction_privilege yes     varchar2
--   p_product_code               no       varchar2
--   p_url                                    no      varchar2
--   p_status                              no     varchar2
--   p_section_display_name  no   varchar2
--   p_function_id                     yes    number
--   p_transaction_ref_table    no    varchar2
--   p_transaction_ref_id          no    number
--   p_transaction_type             no    varchar2
--   p_assignment_id               no     number
--   p_api_addtnl_info               no     varchar2
--   p_selected_person_id       no    number
--   p_item_type                          no   varchar2
--   p_item_key                           no   varchar2
--   p_transaction_effective_date no   date
--   p_process_name               no    varchar2
--   p_plan_id                              no   number
--   p_rptg_grp_id                       no   number
--   p_effective_date_option     no   varchar2
--
--
-- Post Success:
--  A  transaction is created and saved successfully.
--   Name                           Type         Description
--   p_transaction_id         number   Identifies the new transaction created.
--
-- Post Failure:
-- An exception is raised and a transaction is not created.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure create_transaction
  (p_validate                     in      boolean   default false
  ,p_creator_person_id            in      number
  ,p_transaction_privilege        in      varchar2
  ,p_product_code                   in varchar2 default null
  ,p_url                          in varchar2 default null
  ,p_status                       in varchar2 default null
  ,p_section_display_name          in varchar2 default null
  ,p_function_id                  in number
  ,p_transaction_ref_table        in varchar2 default null
  ,p_transaction_ref_id           in number default null
  ,p_transaction_type             in varchar2 default null
  ,p_assignment_id                in number default null
  ,p_api_addtnl_info              in varchar2 default null
  ,p_selected_person_id           in number default null
  ,p_item_type                    in varchar2 default null
  ,p_item_key                     in varchar2 default null
  ,p_transaction_effective_date       in date default null
  ,p_process_name                 in varchar2 default null
  ,p_plan_id                      in number default null
  ,p_rptg_grp_id                  in number default null
  ,p_effective_date_option        in varchar2 default null
  ,p_transaction_id               out nocopy  number) ;
  --
  -- p_plan_id, p_rptg_grp_id, p_effective_date_option added by sanej

--ns start
-- New procedure to accept transaction state as a parameter
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_transaction >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API updates a transaction with the transaction state and/or date_option.
--
-- Prerequisites:
--  None
--
-- In Parameters:
--   Name					Reqd    Type        Description
--   p_validate				no        boolean  If true, then validation alone will be performed and
--									               the database will remain unchanged. If false and all
--											validation checks pass, then the database will be modified.
--   p_transaction_id			yes      number   Identifies the transaction to be updated.
--   p_status					no        varchar2  Identifies the status.
--   p_transaction_state		no        varchar2  Identifies teh transaction status.
--   p_transaction_effective_date no	     date          Identifies the transaction effective date.
--   p_effective_date_option        no	    varchar2   Identifies the effective date option.
--   p_item_key                              no       varchar2   Identifies the Item Key.
--
-- Post Success:
-- The transaction is successfully updated.
--
-- Post Failure:
--  None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
procedure update_transaction
  (p_validate                     in      boolean   default false
  ,p_transaction_id               in      number
  ,p_status                       in      varchar2  default hr_api.g_varchar2
  ,p_transaction_state            in      varchar2  default hr_api.g_varchar2
  ,p_transaction_effective_date   in      date      default hr_api.g_date
  ,p_effective_date_option        in      varchar2  default hr_api.g_varchar2
  ,p_item_key                     in      varchar2  default hr_api.g_varchar2
) ;
--ns end
--
-- ----------------------------------------------------------------------------
-- |---------------------------< finalize_transaction >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This API  finalizes a transaction by calling a desired API before a deletion or rollback.
--
-- Prerequisites:
-- In Parameters:
--   Name                           Reqd      Type           Description
--   p_transaction_id         Yes      Number      Identifies the transaction.
--   p_event                          Yes      Varchar2    Identifies the event.
--
-- Post Success:
--
--   Name                              Type                Description
--   P_RETURN_STATUS   VARCHAR2  Identifies the return status.of the API call
--
-- Post Failure:
-- None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
Procedure finalize_transaction (
     P_TRANSACTION_ID             in NUMBER
    ,P_EVENT                      in VARCHAR2
    ,P_RETURN_STATUS              out nocopy VARCHAR2
  );

end hr_transaction_api;

 

/
