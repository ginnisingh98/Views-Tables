--------------------------------------------------------
--  DDL for Package QA_PLANS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_PLANS_PUB" AUTHID CURRENT_USER AS
/* $Header: qltpplnb.pls 120.3.12010000.2 2010/04/30 10:15:18 ntungare ship $ */
/*#
 * This package is the public interface for Quality Collection Plans setup.
 * It allows for the creation of new collection plans. A new collection plan
 * can be created as a copy of an existing collection plan, or with addition
 * of individual collection elements. This package also supports deleting an
 * existing collection plan.
 * @rep:scope public
 * @rep:product QA
 * @rep:displayname Collection Plan Setup
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY QA_PLAN
 */

--
-- Global constants
--

--
-- Seeded Plan Type Codes
--
    g_plan_type_wip_inspection CONSTANT NUMBER := 1;
    g_plan_type_rcv_inspection CONSTANT NUMBER := 2;
    g_plan_type_fgi_inspection CONSTANT NUMBER := 3;
    g_plan_type_field_returns  CONSTANT NUMBER := 4;

--
-- Seeded Specification Assignment Types
--

    g_spec_type_item     CONSTANT NUMBER := 1;
    g_spec_type_supplier CONSTANT NUMBER := 2;
    g_spec_type_customer CONSTANT NUMBER := 3;
    g_spec_type_none     CONSTANT NUMBER := 4;

--
-- Frequently a plan element attribute can inherit the default
-- value defined for the element.  If we also allow the user to
-- override this default, then we have to face the problem of
-- ambiguity.  An example is, when the user specify NULL as
-- the plan element "Default Value", does he mean to inherit
-- the value from the element level?  or does he mean override
-- whatever value was at the element level, but use NULL as the
-- value?  So, we define a constant to mean inherit.
--
    g_inherit  CONSTANT VARCHAR2(1) := chr(0);

--
-- API name        : create_collection_plan
-- Type            : Public
-- Pre-reqs        : None
--
-- API to create a new Collection Plan in Oracle Quality.
-- Version 1.0
--
-- This API creates a header of a Collection Plan.  After calling
-- this procedure, the user should call add_plan_element consecutively
-- to add as many collection elements as needed.  Afterwards, call
-- complete_plan_processing to finish the plan creation.
--
-- Database commit is never performed.
--
-- Parameters:
--
--  p_api_version                                           NUMBER
--     Should be 1.0
--
--  p_init_msg_list                                         VARCHAR2
--     Standard api parameter.  Indicates whether to
--     re-initialize the message list.
--     Default is fnd_api.g_false.
--
--  p_validation_level                                      NUMBER
--     Standard api parameter.  Indicates validation level.
--     Use the default fnd_api.g_valid_level_full.
--
--  p_user_name                                             VARCHAR2(100)
--     The user's name, as defined in fnd_user table.
--     This is used to record audit info in the WHO columns.
--     If the user accepts the default, then the API will
--     use fnd_global.user_id.
--
--  p_plan_name                                             VARCHAR2(30)
--     Plan name.  Automatically converted to upper case.
--
--  p_organization_code                                     VARCHAR2
--     Organization code.
--
--  p_plan_type                                             VARCHAR2
--     Collection plan type as set up in the Setup
--     Collection Plan Type form. This is the descriptive name
--     instead of the plan type code.
--
--     These are the seeded plan type code and description.
--
--     1 = WIP Inspection        (qa_plans_pub.g_plan_type_wip_inspection)
--     2 = Receiving Inspection  (qa_plans_pub.g_plan_type_rcv_inspection)
--     3 = FGI Inspection        (qa_plans_pub.g_plan_type_fgi_inspection)
--     4 = Field Returns         (qa_plans_pub.g_plan_type_field_returns)
--
--  p_description                                           VARCHAR2(150)
--     Description of the plan.
--     Default is NULL.
--
--  p_effective_from                                        DATE
--     Start date.  Specify NULL if no start date limit.
--     Default is sysdate.
--
--  p_effective_to                                          DATE
--     End date.  Specify NULL if no end date limit.
--     Default is NULL.
--
--  p_spec_assignment_type                                  NUMBER
--     A plan can be associated with a specification type:
--
--     1 = Item Specification     (qa_plans_pub.g_spec_type_item)
--     2 = Supplier Specification (qa_plans_pub.g_spec_type_supplier)
--     3 = Customer Specification (qa_plans_pub.g_spec_type_customer)
--     4 = No Specification       (qa_plans_pub.g_spec_type_none)
--
--     Default is qa_plans_pub.g_spec_type_none.
--
--  x_plan_id                                               OUT NUMBER
--     The plan ID created.
--
--  x_msg_count                                             OUT NUMBER
--     Standard api parameter.  Indicates no. of messages
--     put into the message stack.
--
--  x_msg_data                                              OUT VARCHAR2
--     Standard api parameter.  Messages returned.
--
--  x_return_status                                         OUT VARCHAR2
--     Standard api return status parameter.
--     Values: fnd_api.g_ret_sts_success,
--             fnd_api.g_ret_sts_error,
--             fnd_api.g_ret_sts_unexp_error.
--
/*#
 * Creates a header of a Collection Plan.
 * After calling this procedure, the user should call add_plan_element consecutively
 * to add as many collection elements as needed.  Afterwards, call
 * complete_plan_processing to finish the plan creation.
 * @param p_api_version Should be 1.0
 * @param p_init_msg_list Indicates whether to re-initialize the message list
 * @param p_validation_level Indicates validation level
 * @param p_user_name The user's name, as defined in fnd_user table
 * @param p_plan_name Plan name, Automatically converted to upper case
 * @param p_organization_code Organization code
 * @param p_plan_type Collection plan type
 * @param p_description Plan Description
 * @param p_effective_from Plan Effective From Date
 * @param p_effective_to Plan Effective To Date
 * @param p_spec_assignment_type Specification Type
 * @param x_plan_id Plan ID that gets created
 * @param x_msg_count Count of messages in message stack
 * @param x_msg_data Messages returned
 * @param x_return_status API Return Status
 * @param p_attribute_category DFF attribute category
 * @param p_attribute1 DFF attribute 1
 * @param p_attribute2 DFF attribute 2
 * @param p_attribute3 DFF attribute 3
 * @param p_attribute4 DFF attribute 4
 * @param p_attribute5 DFF attribute 5
 * @param p_attribute6 DFF attribute 6
 * @param p_attribute7 DFF attribute 7
 * @param p_attribute8 DFF attribute 8
 * @param p_attribute9 DFF attribute 9
 * @param p_attribute10 DFF attribute 10
 * @param p_attribute11 DFF attribute 11
 * @param p_attribute12 DFF attribute 12
 * @param p_attribute13 DFF attribute 13
 * @param p_attribute14 DFF attribute 14
 * @param p_attribute15 DFF attribute 15
 * @rep:displayname Create a Collection Plan
 */
PROCEDURE create_collection_plan(
    p_api_version               IN  NUMBER,
    p_init_msg_list             IN  VARCHAR2  := fnd_api.g_false,
    p_validation_level          IN  NUMBER    := fnd_api.g_valid_level_full,
    p_user_name                 IN  VARCHAR2  := NULL,
    p_plan_name                 IN  VARCHAR2,
    p_organization_code         IN  VARCHAR2,
    p_plan_type       		IN  VARCHAR2,
    p_description               IN  VARCHAR2  := NULL,
    p_effective_from            IN  DATE      := sysdate,
    p_effective_to              IN  DATE      := NULL,
    p_spec_assignment_type      IN  NUMBER    := qa_plans_pub.g_spec_type_none,
    p_multirow_flag             IN  NUMBER    := 2,
    x_plan_id                   OUT NOCOPY NUMBER,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2,
    x_return_status             OUT NOCOPY VARCHAR2,
    p_attribute_category        IN VARCHAR2   := NULL,
    p_attribute1                IN VARCHAR2   := NULL,
    p_attribute2                IN VARCHAR2   := NULL,
    p_attribute3                IN VARCHAR2   := NULL,
    p_attribute4                IN VARCHAR2   := NULL,
    p_attribute5                IN VARCHAR2   := NULL,
    p_attribute6                IN VARCHAR2   := NULL,
    p_attribute7                IN VARCHAR2   := NULL,
    p_attribute8                IN VARCHAR2   := NULL,
    p_attribute9                IN VARCHAR2   := NULL,
    p_attribute10               IN VARCHAR2   := NULL,
    p_attribute11               IN VARCHAR2   := NULL,
    p_attribute12               IN VARCHAR2   := NULL,
    p_attribute13               IN VARCHAR2   := NULL,
    p_attribute14               IN VARCHAR2   := NULL,
    p_attribute15               IN VARCHAR2   := NULL);


--
-- API name        : add_plan_element
-- Type            : Public
-- Pre-reqs        : None
--
-- API to add a new element to an existing collection plan.
-- Version 1.0
--
-- This API adds a new element to an existing collection plan, most
-- probably, but not necessarily, created by create_collection_plan.
-- The user may call add_plan_element consecutively to add as many
-- collection elements as needed.  Afterwards, call
-- complete_plan_processing to finish the plan creation.
--
-- Database commit is never performed.
--
-- Parameters:
--
--  p_api_version                                           NUMBER
--     Should be 1.0
--
--  p_init_msg_list                                         VARCHAR2
--     Standard api parameter.  Indicates whether to
--     re-initialize the message list.
--     Default is fnd_api.g_false.
--
--  p_validation_level                                      NUMBER
--     Standard api parameter.  Indicates validation level.
--     Use the default fnd_api.g_valid_level_full.
--
--  p_user_name                                             VARCHAR2(100)
--     The user's name, as defined in fnd_user table.
--     This is used to record audit info in the WHO columns.
--     If the user accepts the default, then the API will
--     use fnd_global.user_id.
--
--  p_plan_name                                             VARCHAR2(30)
--     Plan name.  Automatically converted to upper case.
--
--  p_organization_code                                     VARCHAR2
--     Organization code.
--
--  p_element_name                                          VARCHAR2(30)
--     Name of the collection element to be added.
--     Mixed case.
--
--  p_prompt_sequence                                       NUMBER
--     The integer prompt sequence.
--     Default is NULL, which will auto-assign as the
--     last element.
--
--  p_prompt                                                VARCHAR2(30)
--     The prompt to appear as column heading.
--     Default is g_inherit, which will use the element's
--     prompt.
--
--  p_default_value                                         VARCHAR2(150)
--     Default value of the element.
--     Default is g_inherit, which will use the element's
--     default value.
--
--  p_enabled_flag                                          VARCHAR2
--     Enabled flag.
--     Valid values are fnd_api.g_true or fnd_api.g_false.
--     Default is fnd_api.g_true.
--
--  p_mandatory_flag                                        VARCHAR2
--     Mandatory flag.
--     Valid values are fnd_api.g_true or fnd_api.g_false
--     and g_inherit.
--     Default is g_inherit which will inherit the value
--     set up for the collection element.
--
--  p_displayed_flag                                        VARCHAR2
--     Display flag.  Specify whether this element will
--     be displayed during transaction entry form.
--     Valid values are fnd_api.g_true or fnd_api.g_false.
--     Default is fnd_api.g_true.
--
--  p_result_column_name                                    VARCHAR2
--     This parameter is intended for use by experienced
--     users who are familiar with the underlying QA data
--     model.  This parameter suggests a database column
--     in qa_results table for use as storage.  Most users
--     should simply accept the default value of NULL and
--     let the API selects a correct database column.
--
--  x_msg_count                                             OUT NUMBER
--     Standard api parameter.  Indicates no. of messages
--     put into the message stack.
--
--  x_msg_data                                              OUT VARCHAR2
--     Standard api parameter.  Messages returned.
--
--  x_return_status                                         OUT VARCHAR2
--     Standard api return status parameter.
--     Values: fnd_api.g_ret_sts_success,
--             fnd_api.g_ret_sts_error,
--             fnd_api.g_ret_sts_unexp_error.
--
--  Bug 3709284. Added three new flags for Read Only Plan elements
--  description given below.
-- saugupta Mon, 21 Jun 2004 02:22:47 -0700 PDT
--
-- p_read_only_flag
--     Read Only Flag. Specify whether this element will be
--     displayed as non editable and non updateable.
--     Valid values are fnd_api.g_true or fnd_api.g_false.
--     Default is NULL.
--
-- p_ss_poplist_flag
--     Display as poplist on Workbench. Displays the element
--     values as a poplist instead of default LOV for faster
--     working of wrokbench application.
--     Valid values are fnd_api.g_true or fnd_api.g_false.
--     Default is NULL.
--
-- p_information_flag
--    Information flag. Dispalys a information icon for the
--    element in workbench application.
--     Valid values are fnd_api.g_true or fnd_api.g_false.
--     Default is NULL.
--
-- saugupta Thu Aug 28 08:59:59 PDT 2003
--
/*#
 * Add a new element to an existing collection plan
 * @param p_api_version Should be 1.0
 * @param p_init_msg_list Indicates whether to re-initialize the message list
 * @param p_validation_level Indicates validation level
 * @param p_user_name The user's name, as defined in fnd_user table
 * @param p_plan_name Plan name, Automatically converted to upper case
 * @param p_organization_code Organization code
 * @param p_element_name Name of collection element to be added
 * @param p_prompt_sequence Integer display sequence
 * @param p_prompt Prompt to appear as column heading
 * @param p_default_value Default value of the element
 * @param p_enabled_flag Enabled Flag
 * @param p_mandatory_flag Mandatory Flag
 * @param p_displayed_flag Displayed Flag
 * @param p_read_only_flag specifies whether this element is non updateable
 * @param p_ss_poplist_flag displays element as poplist on Workbench
 * @param p_information_flag displays element in Information column
 * @param p_result_column_name Leave the default value of NULL as it is
 * @param p_device_flag specifies whether there is a device attached to the element
 * @param p_device_name is the device name as defined in Device Setup Page
 * @param p_sensor_alias is the sensor alias as defined in Device Setup Page
 * @param p_override_flag specifies whether the device enabled element is updatable
 * @param x_msg_count Count of messages in message stack
 * @param x_msg_data Messages returned
 * @param x_return_status API Return Status
 * @param p_attribute_category DFF attribute category
 * @param p_attribute1 DFF attribute 1
 * @param p_attribute2 DFF attribute 2
 * @param p_attribute3 DFF attribute 3
 * @param p_attribute4 DFF attribute 4
 * @param p_attribute5 DFF attribute 5
 * @param p_attribute6 DFF attribute 6
 * @param p_attribute7 DFF attribute 7
 * @param p_attribute8 DFF attribute 8
 * @param p_attribute9 DFF attribute 9
 * @param p_attribute10 DFF attribute 10
 * @param p_attribute11 DFF attribute 11
 * @param p_attribute12 DFF attribute 12
 * @param p_attribute13 DFF attribute 13
 * @param p_attribute14 DFF attribute 14
 * @param p_attribute15 DFF attribute 15
 * @rep:displayname Add collection element to a plan
 */
PROCEDURE add_plan_element(
    p_api_version               IN  NUMBER,
    p_init_msg_list             IN  VARCHAR2    := fnd_api.g_false,
    p_validation_level          IN  NUMBER      := fnd_api.g_valid_level_full,
    p_user_name                 IN  VARCHAR2    := NULL,
    p_plan_name                 IN  VARCHAR2,
    p_organization_code         IN  VARCHAR2,
    p_element_name              IN  VARCHAR2,
    p_prompt_sequence           IN  NUMBER      := NULL,
    p_prompt                    IN  VARCHAR2    := g_inherit,
    p_default_value             IN  VARCHAR2    := g_inherit,
    p_enabled_flag              IN  VARCHAR2    := fnd_api.g_true,
    p_mandatory_flag            IN  VARCHAR2    := g_inherit,
    p_displayed_flag            IN  VARCHAR2    := fnd_api.g_true,
    p_read_only_flag            IN  VARCHAR2    := NULL,
    p_ss_poplist_flag           IN  VARCHAR2    := NULL,
    p_information_flag          IN  VARCHAR2    := NULL,
    p_result_column_name        IN  VARCHAR2    := NULL,
    -- 12.1 Device Integration Project
    -- bhsankar Mon Nov 12 05:51:37 PST 2007
    p_device_flag               IN  VARCHAR2    := NULL,
    p_device_name               IN  VARCHAR2    := NULL,
    p_sensor_alias              IN  VARCHAR2    := NULL,
    p_override_flag             IN  VARCHAR2    := NULL,
    -- 12.1 Device Integration Project End.
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2,
    x_return_status             OUT NOCOPY VARCHAR2,
    p_attribute_category        IN VARCHAR2    := NULL,
    p_attribute1                IN VARCHAR2    := NULL,
    p_attribute2                IN VARCHAR2    := NULL,
    p_attribute3                IN VARCHAR2    := NULL,
    p_attribute4                IN VARCHAR2    := NULL,
    p_attribute5                IN VARCHAR2    := NULL,
    p_attribute6                IN VARCHAR2    := NULL,
    p_attribute7                IN VARCHAR2    := NULL,
    p_attribute8                IN VARCHAR2    := NULL,
    p_attribute9                IN VARCHAR2    := NULL,
    p_attribute10               IN VARCHAR2    := NULL,
    p_attribute11               IN VARCHAR2    := NULL,
    p_attribute12               IN VARCHAR2    := NULL,
    p_attribute13               IN VARCHAR2    := NULL,
    p_attribute14               IN VARCHAR2    := NULL,
    p_attribute15               IN VARCHAR2    := NULL);


--
-- API name        : complete_plan_processing
-- Type            : Public
-- Pre-reqs        : None
--
-- API to complete the plan processing.
-- Version 1.0
--
-- This API signals a completion of a collection plan definition.
-- This API is used generally after calling create_collection_plan
-- and a series of add_plan_element calls.
--
-- Parameters:
--
--  p_api_version                                           NUMBER
--     Should be 1.0
--
--  p_init_msg_list                                         VARCHAR2
--     Standard api parameter.  Indicates whether to
--     re-initialize the message list.
--     Default is fnd_api.g_false.
--
--  p_validation_level                                      NUMBER
--     Standard api parameter.  Indicates validation level.
--     Use the default fnd_api.g_valid_level_full.
--
--  p_user_name                                             VARCHAR2(100)
--     The user's name, as defined in fnd_user table.
--     This is used to record audit info in the WHO columns.
--     If the user accepts the default, then the API will
--     use fnd_global.user_id.
--
--  p_plan_name                                             VARCHAR2(30)
--     Plan name.  Automatically converted to upper case.
--
--  p_organization_code                                     VARCHAR2
--     Organization code.
--
--  p_commit                                                VARCHAR2
--     Indicates whether the API shall perform a
--     database commit.  Specify fnd_api.g_true or
--     fnd_api.g_false.
--     Default is fnd_api.g_false.
--
--     It is recommended a commit is performed (even
--     though the standard requires us to use g_false
--     as the default value.)  The dynamic plan views
--     generator can be executed only if the user commits.
--     Alternatively, you may launch the view generator
--     manually in the Setup Collection Plans form.
--
--  x_msg_count                                             OUT NUMBER
--     Standard api parameter.  Indicates no. of messages
--     put into the message stack.
--
--  x_msg_data                                              OUT VARCHAR2
--     Standard api parameter.  Messages returned.
--
--  x_return_status                                         OUT VARCHAR2
--     Standard api return status parameter.
--     Values: fnd_api.g_ret_sts_success,
--             fnd_api.g_ret_sts_error,
--             fnd_api.g_ret_sts_unexp_error.
--
/*#
 * Complete processing of collection plan definition
 * @param p_api_version Should be 1.0
 * @param p_init_msg_list Indicates whether to re-initialize the message list
 * @param p_validation_level Indicates validation level
 * @param p_user_name The user's name, as defined in fnd_user table
 * @param p_plan_name Plan name, Automatically converted to upper case
 * @param p_organization_code Organization code
 * @param p_commit Indicate if database commit should be performed
 * @param x_msg_count Count of messages in message stack
 * @param x_msg_data Messages returned
 * @param x_return_status API Return Status
 * @rep:displayname Complete the definition of collection plan
 */
PROCEDURE complete_plan_processing(
    p_api_version               IN  NUMBER,
    p_init_msg_list             IN  VARCHAR2    := fnd_api.g_false,
    p_validation_level          IN  NUMBER      := fnd_api.g_valid_level_full,
    p_user_name                 IN  VARCHAR2    := NULL,
    p_plan_name                 IN  VARCHAR2,
    p_organization_code         IN  VARCHAR2,
    p_commit                    IN  VARCHAR2    := fnd_api.g_false,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2,
    x_return_status             OUT NOCOPY VARCHAR2);


--
-- API name        : delete_collection_plan
-- Type            : Public
-- Pre-reqs        : None
--
-- API to delete an existing collection plan.
-- Version 1.0
--
-- This API deletes an existing collection plan and all its elements.
-- The user is prevented from deleting a plan if Quality results
-- have been collected.
--
-- Parameters:
--
--  p_api_version                                           NUMBER
--     Should be 1.0
--
--  p_init_msg_list                                         VARCHAR2
--     Standard api parameter.  Indicates whether to
--     re-initialize the message list.
--     Default is fnd_api.g_false.
--
--  p_validation_level                                      NUMBER
--     Standard api parameter.  Indicates validation level.
--     Use the default fnd_api.g_valid_level_full.
--
--  p_user_name                                             VARCHAR2(100)
--     The user's name, as defined in fnd_user table.
--     This is used to record audit info in the WHO columns.
--     If the user accepts the default, then the API will
--     use fnd_global.user_id.
--
--  p_plan_name                                             VARCHAR2(30)
--     Plan name.  Automatically converted to upper case.
--
--  p_organization_code                                     VARCHAR2
--     Organization code.
--
--  p_commit                                                VARCHAR2
--     Indicates whether the API shall perform a
--     database commit.  Specify fnd_api.g_true or
--     fnd_api.g_false.
--     Default is fnd_api.g_false.
--
--  x_msg_count                                             OUT NUMBER
--     Standard api parameter.  Indicates no. of messages
--     put into the message stack.
--
--  x_msg_data                                              OUT VARCHAR2
--     Standard api parameter.  Messages returned.
--
--  x_return_status                                         OUT VARCHAR2
--     Standard api return status parameter.
--     Values: fnd_api.g_ret_sts_success,
--             fnd_api.g_ret_sts_error,
--             fnd_api.g_ret_sts_unexp_error.
--
/*#
 * Delete an existing collection plan
 * @param p_api_version Should be 1.0
 * @param p_init_msg_list Indicates whether to re-initialize the message list
 * @param p_validation_level Indicates validation level
 * @param p_user_name The user's name, as defined in fnd_user table
 * @param p_plan_name Plan name, Automatically converted to upper case
 * @param p_organization_code Organization code
 * @param p_commit Indicate if database commit should be performed
 * @param x_msg_count Count of messages in message stack
 * @param x_msg_data Messages returned
 * @param x_return_status API Return Status
 * @rep:displayname Delete an existing collection plan
 */
PROCEDURE delete_collection_plan(
    p_api_version               IN  NUMBER,
    p_init_msg_list             IN  VARCHAR2    := fnd_api.g_false,
    p_validation_level          IN  NUMBER      := fnd_api.g_valid_level_full,
    p_user_name                 IN  VARCHAR2    := NULL,
    p_plan_name                 IN  VARCHAR2,
    p_organization_code         IN  VARCHAR2,
    p_commit                    IN  VARCHAR2    := fnd_api.g_false,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2,
    x_return_status             OUT NOCOPY VARCHAR2);


--
-- API name        : delete_plan_element
-- Type            : Public
-- Pre-reqs        : None
--
-- API to delete an element from an existing collection plan.
-- Version 1.0
--
-- This API deletes an element from a collection plan.  The user
-- is prevented to do this if Quality result has been collected
-- for that element.
--
-- Parameters:
--
--  p_api_version                                           NUMBER
--     Should be 1.0
--
--  p_init_msg_list                                         VARCHAR2
--     Standard api parameter.  Indicates whether to
--     re-initialize the message list.
--     Default is fnd_api.g_false.
--
--  p_validation_level                                      NUMBER
--     Standard api parameter.  Indicates validation level.
--     Use the default fnd_api.g_valid_level_full.
--
--  p_user_name                                             VARCHAR2(100)
--     The user's name, as defined in fnd_user table.
--     This is used to record audit info in the WHO columns.
--     If the user accepts the default, then the API will
--     use fnd_global.user_id.
--
--  p_plan_name                                             VARCHAR2(30)
--     Plan name.  Automatically converted to upper case.
--
--  p_organization_code                                     VARCHAR2
--     Organization code.
--
--  p_element_name                                          VARCHAR2(30)
--     The element to be deleted.  Mixed case.
--
--  p_commit                                                VARCHAR2
--     Indicates whether the API shall perform a
--     database commit.  Specify fnd_api.g_true or
--     fnd_api.g_false.
--     Default is fnd_api.g_false.
--
--  x_msg_count                                             OUT NUMBER
--     Standard api parameter.  Indicates no. of messages
--     put into the message stack.
--
--  x_msg_data                                              OUT VARCHAR2
--     Standard api parameter.  Messages returned.
--
--  x_return_status                                         OUT VARCHAR2
--     Standard api return status parameter.
--     Values: fnd_api.g_ret_sts_success,
--             fnd_api.g_ret_sts_error,
--             fnd_api.g_ret_sts_unexp_error.
--
/*#
 * Delete an element from a collection plan
 * @param p_api_version Should be 1.0
 * @param p_init_msg_list Indicates whether to re-initialize the message list
 * @param p_validation_level Indicates validation level
 * @param p_user_name The user's name, as defined in fnd_user table
 * @param p_plan_name Plan name, Automatically converted to upper case
 * @param p_element_name Name of collection element to be deleted from plan
 * @param p_organization_code Organization code
 * @param p_commit Indicate if database commit should be performed
 * @param x_msg_count Count of messages in message stack
 * @param x_msg_data Messages returned
 * @param x_return_status API Return Status
 * @rep:displayname Delete an element from a collection plan
 */
PROCEDURE delete_plan_element(
    p_api_version               IN  NUMBER,
    p_init_msg_list             IN  VARCHAR2    := fnd_api.g_false,
    p_validation_level          IN  NUMBER      := fnd_api.g_valid_level_full,
    p_user_name                 IN  VARCHAR2    := NULL,
    p_plan_name                 IN  VARCHAR2,
    p_organization_code         IN  VARCHAR2,
    p_element_name              IN  VARCHAR2,
    p_commit                    IN  VARCHAR2    := fnd_api.g_false,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2,
    x_return_status             OUT NOCOPY VARCHAR2);


--
-- API name        : copy_collection_plan
-- Type            : Public
-- Pre-reqs        : None
--
-- API to copy a collection plan.
-- Version 1.0
--
-- This API creates a new collection plan by copying the
-- definition of an existing collection plan or updates
-- an existing collection plan with additional elements
-- copied from a source plan.  Should there be conflict
-- in the latter case, the new elements from the source
-- plan will not overwrite the existing elements.  Afterwards,
-- call complete_plan_processing to finish the plan creation.
--
-- Database commit is never performed.
--
--
-- Parameters:
--
--  p_api_version                                           NUMBER
--     Should be 1.0
--
--  p_init_msg_list                                         VARCHAR2
--     Standard api parameter.  Indicates whether to
--     re-initialize the message list.
--     Default is fnd_api.g_false.
--
--  p_validation_level                                      NUMBER
--     Standard api parameter.  Indicates validation level.
--     Use the default fnd_api.g_valid_level_full.
--
--  p_user_name                                             VARCHAR2(100)
--     The user's name, as defined in fnd_user table.
--     This is used to record audit info in the WHO columns.
--     If the user accepts the default, then the API will
--     use fnd_global.user_id.
--
--  p_plan_name                                             VARCHAR2(30)
--     The source plan name.  Automatically converted
--     to upper case.
--
--  p_organization_code                                     VARCHAR2
--     Organization code.  Can be NULL for template plans.
--     Default is NULL.
--
--  p_to_plan_name                                          VARCHAR2(30)
--     The destination plan name.  Automatically converted
--     to upper case.
--
--  p_to_organization_code                                  VARCHAR2
--     The destination Organization code.
--
--  p_copy_actions_flag                                     VARCHAR2
--     Specifies whether to copy all actions associated
--     with each plan element.
--     Valid values are fnd_api.g_true or fnd_api.g_false.
--     Default is fnd_api.g_true.
--
--  p_copy_values_flag                                      VARCHAR2
--     Specifies whether to copy all lookup values
--     associated with each plan element.
--     Valid values are fnd_api.g_true or fnd_api.g_false.
--     Default is fnd_api.g_true.
--
--  p_copy_transactions_flag                                VARCHAR2
--     Specifies whether to copy all transactions and
--     collection triggers associated with each plan element.
--     Valid values are fnd_api.g_true or fnd_api.g_false.
--     Default is fnd_api.g_true.
--
--  p_commit                                                VARCHAR2
--     Indicates whether the API shall perform a
--     database commit.  Specify fnd_api.g_true or
--     fnd_api.g_false.
--     Default is fnd_api.g_false.
--
--  x_msg_count                                             OUT NUMBER
--     Standard api parameter.  Indicates no. of messages
--     put into the message stack.
--
--  x_msg_data                                              OUT VARCHAR2
--     Standard api parameter.  Messages returned.
--
--  x_return_status                                         OUT VARCHAR2
--     Standard api return status parameter.
--     Values: fnd_api.g_ret_sts_success,
--             fnd_api.g_ret_sts_error,
--             fnd_api.g_ret_sts_unexp_error.
--
/*#
 * Create a new collection plan by copying definition of an existing collection plan
 * @param p_api_version Should be 1.0
 * @param p_init_msg_list Indicates whether to re-initialize the message list
 * @param p_validation_level Indicates validation level
 * @param p_user_name The user's name, as defined in fnd_user table
 * @param p_plan_name Plan name, Automatically converted to upper case
 * @param p_organization_code Organization code
 * @param p_to_plan_name Destination plan name
 * @param p_to_organization_code Destination organization code
 * @param p_copy_actions_flag specifies whether to copy all plan element actions
 * @param p_copy_values_flag specifies whether to copy all plan element lookup values
 * @param p_copy_transactions_flag  specifies whether to copy all plan transactions
 * @param p_commit Indicate if database commit should be performed
 * @param x_to_plan_id New Plan ID that gets created automatically
 * @param x_msg_count Count of messages in message stack
 * @param x_msg_data Messages returned
 * @param x_return_status API Return Status
 * @rep:displayname Copy Collection Plan
 */
PROCEDURE copy_collection_plan(
    p_api_version               IN  NUMBER,
    p_init_msg_list             IN  VARCHAR2    := fnd_api.g_false,
    p_validation_level          IN  NUMBER      := fnd_api.g_valid_level_full,
    p_user_name                 IN  VARCHAR2    := NULL,
    p_plan_name                 IN  VARCHAR2,
    p_organization_code         IN  VARCHAR2,
    p_to_plan_name              IN  VARCHAR2,
    p_to_organization_code      IN  VARCHAR2,
    p_copy_actions_flag         IN  VARCHAR2    := fnd_api.g_true,
    p_copy_values_flag          IN  VARCHAR2    := fnd_api.g_true,
    p_copy_transactions_flag    IN  VARCHAR2    := fnd_api.g_true,
    p_commit                    IN  VARCHAR2    := fnd_api.g_false,
    x_to_plan_id                OUT NOCOPY NUMBER,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2,
    x_return_status             OUT NOCOPY VARCHAR2);


FUNCTION get_plan_type (p_lookup_code IN VARCHAR2) RETURN VARCHAR2;

-- Function to get the Plan View name
FUNCTION get_plan_view_name(p_name VARCHAR2) RETURN VARCHAR2;

-- Function to get the Import view name
FUNCTION get_import_view_name(p_name VARCHAR2) RETURN VARCHAR2;

END qa_plans_pub;




/
