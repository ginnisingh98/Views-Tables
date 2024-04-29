--------------------------------------------------------
--  DDL for Package QA_SPECS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_SPECS_PUB" AUTHID CURRENT_USER AS
/* $Header: qltpspcb.pls 120.1.12010000.2 2008/09/24 11:27:21 pdube ship $ */
/*#
 * This package is the public interface for Quality Specifications setup.
 * It allows for the creation of new specifications. A new specification
 * can be created as a copy of an existing specification, or with addition
 * of individual specification elements. This package also supports deleting an
 * existing specification.
 * @rep:scope public
 * @rep:product QA
 * @rep:displayname Specifications Definition
 * @rep:lifecycle active
 * @rep:category BUSINESS_ENTITY QA_SPEC
 */
--
-- Seeded Specification Assignment Types
--

    g_spec_type_item     CONSTANT NUMBER := 1;
    g_spec_type_supplier CONSTANT NUMBER := 2;
    g_spec_type_customer CONSTANT NUMBER := 3;

--
-- API name        : create_specification
-- Type            : Public
-- Pre-reqs        : None
--
-- API to create a new Specification in Oracle Quality.
-- Version 1.0
--
-- This API creates a header of a Specification.  After calling
-- this procedure, the user should call add_spec_element consecutively
-- to add as many specification elements as needed.  Afterwards, call
-- complete_spec_processing to finish the specification creation.
--
-- Commit is never performed.
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
--  p_spec_name                                             VARCHAR2(30)
--     Specification name.  Mixed case allowed.
--
--  p_organization_code                                     VARCHAR2
--     Organization code.
--
--  p_effective_from                                        DATE
--     Effective From date.  Default is SYSDATE.
--
--  p_effective_to                                          DATE
--     Effective To date.  Default is SYSDATE.
--
--  p_assignment_type                                       NUMBER
--     Each specification has an assignment type.  This
--     indicates the association of a specification to
--     either an item, a customer or a supplier.  The
--     following values are allowed:
--
--     1 = Item Spec     (qa_specs_pub.g_spec_type_item)
--     2 = Supplier Spec (qa_specs_pub.g_spec_type_supplier)
--     3 = Customer Spec (qa_specs_pub.g_spec_type_customer)
--
--     Default is qa_specs_pub.g_spec_type_item.
--
--  p_category_set_name                                     VARCHAR2
--     A specification can also be associated with a
--     category and category set.  This specifies the
--     category set.  This should be NULL if p_item_name
--     is specified.
--     Default is NULL.
--
--  p_category_name                                         VARCHAR2
--     A specification can also be associated with a
--     category and category set.  This specifies the
--     category.  This should be NULL if p_item_name
--     is specified.
--     Default is NULL.
--
--  p_item_name                                             VARCHAR2
--     The item name associated with this specification.
--     This should be NULL if p_category_set_name and
--     p_category_name are specified.
--     Default is NULL.
--
--  p_item_revision                                         VARCHAR2
--     The item revision associated with this specification.
--     This should be NULL if p_category_set_name and
--     p_category_name are specified.
--     Default is NULL.
--
--  p_supplier_name                                         VARCHAR2
--     The supplier associated with this specification.
--     Default is NULL.
--
--  p_customer_name                                         VARCHAR2
--     The customer associated with this specification.
--     Default is NULL.
--
--  p_sub_type_element                                      VARCHAR2
--     A specification can be tagged by a collection
--     element and value pair.  This indicates the
--     element name.
--     Default is NULL.
--
--  p_sub_type_element_value                                VARCHAR2
--     A specification can be tagged by a collection
--     element and value pair.  This indicates the
--     element value.
--     Default is NULL.
--
--  x_spec_id                                               OUT NUMBER
--     The specification ID created.
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
 * Creates a header of a specification.
 * After calling this procedure, the user should call add_spec_element consecutively
 * to add as many specification elements as needed.  Afterwards, call
 * complete_spec_processing to finish the specification creation.
 * @param p_api_version Should be 1.0
 * @param p_init_msg_list Indicates whether to re-initialize the message list
 * @param p_validation_level Indicates validation level
 * @param p_user_name The user's name, as defined in fnd_user table
 * @param p_spec_name Specification Name
 * @param p_organization_code Organization code
 * @param p_reference_spec Referenced Specification Name
 * @param p_effective_from Effective From Date
 * @param p_effective_to Effective To Date
 * @param p_assignment_type specify Item or Supplier or Customer specification
 * @param p_category_set_name Category Set Name
 * @param p_category_name Category Name
 * @param p_item_name Item Name
 * @param p_item_revision Item Revision
 * @param p_supplier_name Supplier associated with this specification
 * @param p_customer_name Customer associated with this specification
 * @param p_sub_type_element Collection Element Name, optional
 * @param p_sub_type_element_value Collection Element Value, optional
 * @param x_spec_id Specification ID that gets created automatically
 * @param x_msg_count Count of messages in message stack
 * @param x_msg_data Messages returned
 * @param x_return_status API Return Status
 * @rep:displayname Create Specification
 */
PROCEDURE create_specification(
    p_api_version               IN  NUMBER,
    p_init_msg_list             IN  VARCHAR2  := fnd_api.g_false,
    p_validation_level          IN  NUMBER    := fnd_api.g_valid_level_full,
    p_user_name                 IN  VARCHAR2  := NULL,
    p_spec_name                 IN  VARCHAR2,
    p_organization_code         IN  VARCHAR2,
    p_reference_spec            IN  VARCHAR2  := NULL,
    p_effective_from            IN  DATE      := SYSDATE,
    p_effective_to              IN  DATE      := NULL,
    p_assignment_type           IN  NUMBER    := qa_specs_pub.g_spec_type_item,
    p_category_set_name         IN  VARCHAR2  := NULL,
    p_category_name             IN  VARCHAR2  := NULL,
    p_item_name                 IN  VARCHAR2  := NULL,
    p_item_revision             IN  VARCHAR2  := NULL,
    p_supplier_name             IN  VARCHAR2  := NULL,
    p_customer_name             IN  VARCHAR2  := NULL,
    p_sub_type_element          IN  VARCHAR2  := NULL,
    p_sub_type_element_value    IN  VARCHAR2  := NULL,
    x_spec_id                   OUT NOCOPY NUMBER,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2,
    x_return_status             OUT NOCOPY VARCHAR2,
    -- Bug 7430441.FP for Bug 6877858.
    -- Added the attribute parameters in order to populate the DFF
    -- fields too into the qa_specs table
    -- pdube Wed Sep 24 03:17:03 PDT 2008
    p_attribute_category        IN VARCHAR2 := NULL,
    p_attribute1                IN VARCHAR2 := NULL,
    p_attribute2                IN VARCHAR2 := NULL,
    p_attribute3                IN VARCHAR2 := NULL,
    p_attribute4                IN VARCHAR2 := NULL,
    p_attribute5                IN VARCHAR2 := NULL,
    p_attribute6                IN VARCHAR2 := NULL,
    p_attribute7                IN VARCHAR2 := NULL,
    p_attribute8                IN VARCHAR2 := NULL,
    p_attribute9                IN VARCHAR2 := NULL,
    p_attribute10               IN VARCHAR2 := NULL,
    p_attribute11               IN VARCHAR2 := NULL,
    p_attribute12               IN VARCHAR2 := NULL,
    p_attribute13               IN VARCHAR2 := NULL,
    p_attribute14               IN VARCHAR2 := NULL,
    p_attribute15               IN VARCHAR2 := NULL );


--
-- API name        : add_spec_element
-- Type            : Public
-- Pre-reqs        : create_specification
--
-- API to add a specification element to a Specification.
-- Version 1.0
--
-- This API adds a specification element to an existing Specification
-- (most often created by a call to create_specification).  The user
-- may call this function consecutively to add as many specification
-- elements as needed.  Afterwards, call complete_spec_processing to
-- finish the specification creation.
--
-- Commit is never performed.
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
--  p_spec_name                                             VARCHAR2
--     Specification name.  Mixed case allowed.
--
--  p_organization_code                                     VARCHAR2
--     Organization code.
--
--  p_element_name                                          VARCHAR2
--     Name of the new specification element.  Must be
--     an existing collection element.
--
--  p_uom_code                                              VARCHAR2
--     The UOM code chosen for this spec element
--     Default is NULL.
--
--  p_enabled_flag                                          VARCHAR2
--     Indicates whether this element is enabled.
--     Values: fnd_api.g_true or fnd_api.g_false.
--     Default is fnd_api.g_true.
--
--  p_target_value                                          VARCHAR2
--     Target value.
--     Default is NULL.
--
--  p_upper_spec_limit                                      VARCHAR2
--     Upper Specification Limit.
--     Default is NULL.
--
--  p_lower_spec_limit                                      VARCHAR2
--     Lower Specification Limit.
--     Default is NULL.
--
--  p_upper_reasonable_limit                                VARCHAR2
--     Upper Reasonable Limit.
--     Default is NULL.
--
--  p_lower_reasonable_limit                                VARCHAR2
--     Lower Reasonable Limit.
--     Default is NULL.
--
--  p_upper_user_defined_limit                              VARCHAR2
--     Upper User-defined Limit.
--     Default is NULL.
--
--  p_lower_user_defined_limit                              VARCHAR2
--     Lower User-defined Limit.
--     Default is NULL.
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
 * Add specification element to an existing specification
 * @param p_api_version Should be 1.0
 * @param p_init_msg_list Indicates whether to re-initialize the message list
 * @param p_validation_level Indicates validation level
 * @param p_user_name The user's name, as defined in fnd_user table
 * @param p_spec_name Specification Name
 * @param p_organization_code Organization code
 * @param p_element_name Name of specification element
 * @param p_uom_code Unit of Measure code for this element
 * @param p_enabled_flag indicate whether this spec element is enabled
 * @param p_target_value Target Value
 * @param p_upper_spec_limit Upper Specification Limit
 * @param p_lower_spec_limit Lower Specification Limit
 * @param p_upper_reasonable_limit Upper Reasonable Limit
 * @param p_lower_reasonable_limit Lower Reasonable Limit
 * @param p_upper_user_defined_limit Upper User-defined Limit
 * @param p_lower_user_defined_limit Lower User-defined Limit
 * @param x_msg_count Count of messages in message stack
 * @param x_msg_data Messages returned
 * @param x_return_status API Return Status
 * @rep:displayname Add specification element
 */
PROCEDURE add_spec_element(
    p_api_version               IN      NUMBER,
    p_init_msg_list             IN      VARCHAR2 := fnd_api.g_false,
    p_validation_level          IN      NUMBER   := fnd_api.g_valid_level_full,
    p_user_name                 IN      VARCHAR2 := NULL,
    p_spec_name                 IN      VARCHAR2,
    p_organization_code         IN      VARCHAR2,
    p_element_name              IN      VARCHAR2,
    p_uom_code                  IN      VARCHAR2 := NULL,
    p_enabled_flag              IN      VARCHAR2 := fnd_api.g_true,
    p_target_value              IN      VARCHAR2 := NULL,
    p_upper_spec_limit          IN      VARCHAR2 := NULL,
    p_lower_spec_limit          IN      VARCHAR2 := NULL,
    p_upper_reasonable_limit    IN      VARCHAR2 := NULL,
    p_lower_reasonable_limit    IN      VARCHAR2 := NULL,
    p_upper_user_defined_limit  IN      VARCHAR2 := NULL,
    p_lower_user_defined_limit  IN      VARCHAR2 := NULL,
    x_msg_count                 OUT     NOCOPY NUMBER,
    x_msg_data                  OUT     NOCOPY VARCHAR2,
    x_return_status             OUT     NOCOPY VARCHAR2,
    -- 7430441.FP for Bug 7046198
    -- Added the attribute parameters in order to populate the DFF
    -- fields too into the qa_spec_chars table
    -- pdube Wed Sep 24 03:17:03 PDT 2008
    p_attribute_category        IN VARCHAR2 := NULL,
    p_attribute1                IN VARCHAR2 := NULL,
    p_attribute2                IN VARCHAR2 := NULL,
    p_attribute3                IN VARCHAR2 := NULL,
    p_attribute4                IN VARCHAR2 := NULL,
    p_attribute5                IN VARCHAR2 := NULL,
    p_attribute6                IN VARCHAR2 := NULL,
    p_attribute7                IN VARCHAR2 := NULL,
    p_attribute8                IN VARCHAR2 := NULL,
    p_attribute9                IN VARCHAR2 := NULL,
    p_attribute10               IN VARCHAR2 := NULL,
    p_attribute11               IN VARCHAR2 := NULL,
    p_attribute12               IN VARCHAR2 := NULL,
    p_attribute13               IN VARCHAR2 := NULL,
    p_attribute14               IN VARCHAR2 := NULL,
    p_attribute15               IN VARCHAR2 := NULL );


--
-- API name        : complete_spec_processing
-- Type            : Public
-- Pre-reqs        : create_specification, add_spec_elements
--
-- API to complete the Specification creation.
-- Version 1.0
--
-- This API completes the definition of a specification.
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
--  p_user_name                                             VARCHAR2(100)
--     The user's name, as defined in fnd_user table.
--     This is used to record audit info in the WHO columns.
--     If the user accepts the default, then the API will
--     use fnd_global.user_id.
--
--  p_spec_name                                             VARCHAR2
--     Specification name.  Mixed case allowed.
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
 * Complete definition of a new specification
 * @param p_api_version Should be 1.0
 * @param p_init_msg_list Indicates whether to re-initialize the message list
 * @param p_user_name The user's name, as defined in fnd_user table
 * @param p_spec_name Specification name
 * @param p_organization_code Organization code
 * @param p_commit Indicate if database commit should be performed
 * @param x_msg_count Count of messages in message stack
 * @param x_msg_data Messages returned
 * @param x_return_status API Return Status
 * @rep:displayname Complete specification processing
 */
PROCEDURE complete_spec_processing(
    p_api_version               IN      NUMBER,
    p_init_msg_list             IN      VARCHAR2 := fnd_api.g_false,
    p_user_name                 IN      VARCHAR2 := NULL,
    p_spec_name                 IN      VARCHAR2,
    p_organization_code         IN      VARCHAR2,
    p_commit                    IN      VARCHAR2 := fnd_api.g_false,
    x_msg_count                 OUT     NOCOPY NUMBER,
    x_msg_data                  OUT     NOCOPY VARCHAR2,
    x_return_status             OUT     NOCOPY VARCHAR2);


--
-- API name        : delete_specification
-- Type            : Public
-- Pre-reqs        : None.
--
-- API to delete a Specification.
-- Version 1.0
--
-- This API deletes a specification.  All spec elements will be
-- deleted in cascade fashion.
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
--  p_user_name                                             VARCHAR2(100)
--     The user's name, as defined in fnd_user table.
--     This is used to record audit info in the WHO columns.
--     If the user accepts the default, then the API will
--     use fnd_global.user_id.
--
--  p_spec_name                                             VARCHAR2
--     Specification name.  Mixed case allowed.
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
 * Delete an existing specification
 * @param p_api_version Should be 1.0
 * @param p_init_msg_list Indicates whether to re-initialize the message list
 * @param p_user_name The user's name, as defined in fnd_user table
 * @param p_spec_name Specification name
 * @param p_organization_code Organization code
 * @param p_commit Indicate if database commit should be performed
 * @param x_msg_count Count of messages in message stack
 * @param x_msg_data Messages returned
 * @param x_return_status API Return Status
 * @rep:displayname Delete Specification
 */
PROCEDURE delete_specification(
    p_api_version               IN      NUMBER,
    p_init_msg_list             IN      VARCHAR2 := fnd_api.g_false,
    p_user_name                 IN      VARCHAR2 := NULL,
    p_spec_name                 IN      VARCHAR2,
    p_organization_code         IN      VARCHAR2,
    p_commit                    IN      VARCHAR2 := fnd_api.g_false,
    x_msg_count                 OUT     NOCOPY NUMBER,
    x_msg_data                  OUT     NOCOPY VARCHAR2,
    x_return_status             OUT     NOCOPY VARCHAR2);


--
-- API name        : delete_spec_element
-- Type            : Public
-- Pre-reqs        : None.
--
-- API to delete a specification element.
-- Version 1.0
--
-- This API deletes a specification element from an existing
-- Specification.
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
--  p_user_name                                             VARCHAR2(100)
--     The user's name, as defined in fnd_user table.
--     This is used to record audit info in the WHO columns.
--     If the user accepts the default, then the API will
--     use fnd_global.user_id.
--
--  p_spec_name                                             VARCHAR2
--     Specification name.  Mixed case allowed.
--
--  p_organization_code                                     VARCHAR2
--     Organization code.
--
--  p_element_name                                          VARCHAR2
--     The specification element name to be deleted.
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
 * Delete an element from a specification
 * @param p_api_version Should be 1.0
 * @param p_init_msg_list Indicates whether to re-initialize the message list
 * @param p_user_name The user's name, as defined in fnd_user table
 * @param p_spec_name Specification name
 * @param p_element_name Name of specification element to be deleted
 * @param p_organization_code Organization code
 * @param p_commit Indicate if database commit should be performed
 * @param x_msg_count Count of messages in message stack
 * @param x_msg_data Messages returned
 * @param x_return_status API Return Status
 * @rep:displayname Delete specification element
 */
PROCEDURE delete_spec_element(
    p_api_version               IN      NUMBER,
    p_init_msg_list             IN      VARCHAR2 := fnd_api.g_false,
    p_user_name                 IN      VARCHAR2 := NULL,
    p_spec_name                 IN      VARCHAR2,
    p_organization_code         IN      VARCHAR2,
    p_element_name              IN      VARCHAR2,
    p_commit                    IN      VARCHAR2 := fnd_api.g_false,
    x_msg_count                 OUT     NOCOPY NUMBER,
    x_msg_data                  OUT     NOCOPY VARCHAR2,
    x_return_status             OUT     NOCOPY VARCHAR2);


--
-- API name        : copy_specification
-- Type            : Public
-- Pre-reqs        : None.
--
-- API to copy a specification.
-- Version 1.0
--
-- This API duplicates a specification, together with its elements.
-- The user specifies an existing specification name of an organization
-- and a new specification name, a new item/revision combination and
-- a new (or same) organization.  A new specification will be created
-- for that item.
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
--  p_user_name                                             VARCHAR2(100)
--     The user's name, as defined in fnd_user table.
--     This is used to record audit info in the WHO columns.
--     If the user accepts the default, then the API will
--     use fnd_global.user_id.
--
--  p_spec_name                                             VARCHAR2
--     Original Specification name.
--
--  p_organization_code                                     VARCHAR2
--     Organization code.
--
--  p_to_spec_name                                          VARCHAR2
--     Target Specification name.
--
--  p_to_organization_code                                  VARCHAR2
--     Target Organization code.
--
--  p_to_item_name                                          VARCHAR2
--     The new item to be associated with the new
--     specification.
--
--  p_to_item_revision                                      VARCHAR2
--     The new item revision.  Null allowed.
--     Default is NULL.
--
--  p_commit                                                VARCHAR2
--     Indicates whether the API shall perform a
--     database commit.  Specify fnd_api.g_true or
--     fnd_api.g_false.
--     Default is fnd_api.g_false.
--
--  x_spec_id                                               OUT NUMBER
--     Specification ID of the created specification.
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
 * Create a new specification by copying definition of an existing specification
 * @param p_api_version Should be 1.0
 * @param p_init_msg_list Indicates whether to re-initialize the message list
 * @param p_user_name The user's name, as defined in fnd_user table
 * @param p_spec_name Specification name
 * @param p_organization_code Organization code
 * @param p_to_spec_name Destination specification name
 * @param p_to_organization_code Destination organization code
 * @param p_to_item_name New item to be associated with specification
 * @param p_to_item_revision New item revision to be associated with specification
 * @param p_commit Indicate if database commit should be performed
 * @param x_spec_id New Specification ID that gets created automatically
 * @param x_msg_count Count of messages in message stack
 * @param x_msg_data Messages returned
 * @param x_return_status API Return Status
 * @rep:displayname Copy Specification
 */
PROCEDURE copy_specification(
    p_api_version               IN      NUMBER,
    p_init_msg_list             IN      VARCHAR2 := fnd_api.g_false,
    p_user_name                 IN      VARCHAR2 := NULL,
    p_spec_name                 IN      VARCHAR2,
    p_organization_code         IN      VARCHAR2,
    p_to_spec_name              IN      VARCHAR2,
    p_to_organization_code      IN      VARCHAR2,
    p_to_item_name              IN      VARCHAR2,
    p_to_item_revision          IN      VARCHAR2 := NULL,
    p_commit                    IN      VARCHAR2 := fnd_api.g_false,
    x_spec_id                   OUT     NOCOPY NUMBER,
    x_msg_count                 OUT     NOCOPY NUMBER,
    x_msg_data                  OUT     NOCOPY VARCHAR2,
    x_return_status             OUT     NOCOPY VARCHAR2);

END qa_specs_pub;

/
