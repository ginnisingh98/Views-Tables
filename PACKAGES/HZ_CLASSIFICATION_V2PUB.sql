--------------------------------------------------------
--  DDL for Package HZ_CLASSIFICATION_V2PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_CLASSIFICATION_V2PUB" AUTHID CURRENT_USER AS
/*$Header: ARH2CLSS.pls 120.12 2006/08/17 10:15:51 idali noship $ */
/*#
 * This package contains the public APIs for class categories, class code
 * relationships, class code assignments, and class category uses.
 * @rep:scope public
 * @rep:product HZ
 * @rep:displayname Classification
 * @rep:category BUSINESS_ENTITY HZ_CLASSIFICATION
 * @rep:lifecycle active
 * @rep:doccd 120hztig.pdf Classification API Use, Oracle Trading Community Architecture Technical Implementation Guide
 */

--------------------------------------
-- declaration of record type
--------------------------------------

TYPE class_category_rec_type IS RECORD (
    class_category                          VARCHAR2(30),
    allow_multi_parent_flag                 VARCHAR2(1),
    allow_multi_assign_flag                 VARCHAR2(1),
    allow_leaf_node_only_flag               VARCHAR2(1),
    created_by_module                       VARCHAR2(150),
    application_id                          NUMBER,
    delimiter                               VARCHAR2(1)
);

TYPE class_code_relation_rec_type IS RECORD (
    class_category                          VARCHAR2(30),
    class_code                              VARCHAR2(30),
    sub_class_code                          VARCHAR2(30),
    start_date_active                       DATE,
    end_date_active                         DATE,
    created_by_module                       VARCHAR2(150),
    application_id                          NUMBER
);

TYPE code_assignment_rec_type IS RECORD (
    code_assignment_id                      NUMBER,
    owner_table_name                        VARCHAR2(30),
    owner_table_id                          NUMBER,
    owner_table_key_1                       VARCHAR2(255),
    owner_table_key_2                       VARCHAR2(255),
    owner_table_key_3                       VARCHAR2(255),
    owner_table_key_4                       VARCHAR2(255),
    owner_table_key_5                       VARCHAR2(255),
    class_category                          VARCHAR2(30),
    class_code                              VARCHAR2(30),
    primary_flag                            VARCHAR2(1),
    content_source_type                     VARCHAR2(30) := HZ_PARTY_V2PUB.G_MISS_CONTENT_SOURCE_TYPE,
    start_date_active                       DATE,
    end_date_active                         DATE,
    status                                  VARCHAR2(1),
    created_by_module                       VARCHAR2(150),
    rank                                    NUMBER,
    application_id                          NUMBER,
    -- SSM SST Integration and Extension
    actual_content_source                   VARCHAR2(30)
);

TYPE class_category_use_rec_type IS RECORD (
    class_category                          VARCHAR2(30),
    owner_table                             VARCHAR2(240),
    column_name                             VARCHAR2(240),
    additional_where_clause                 VARCHAR2(4000),
    created_by_module                       VARCHAR2(150),
    application_id                          NUMBER
);

TYPE class_code_rec_type IS RECORD (
    type                         VARCHAR2(30),
    code                         VARCHAR2(30),
    meaning                      VARCHAR2(80),
    description                  VARCHAR2(240),
    start_date_active            DATE,
    end_date_active              DATE,
    enabled_flag                 VARCHAR2(1),
    attribute_category           VARCHAR2(30),
    attribute1                   VARCHAR2(150),
    attribute2                   VARCHAR2(150),
    attribute3                   VARCHAR2(150),
    attribute4                   VARCHAR2(150),
    attribute5                   VARCHAR2(150),
    attribute6                   VARCHAR2(150),
    attribute7                   VARCHAR2(150),
    attribute8                   VARCHAR2(150),
    attribute9                   VARCHAR2(150),
    attribute10                  VARCHAR2(150),
    attribute11                  VARCHAR2(150),
    attribute12                  VARCHAR2(150),
    attribute13                  VARCHAR2(150),
    attribute14                  VARCHAR2(150),
    attribute15                  VARCHAR2(150)
);

--------------------------------------
-- declaration of public procedures and functions
--------------------------------------

/**
 * PROCEDURE create_class_category
 *
 * DESCRIPTION
 *     Creates class category.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_class_category_rec           Class category record.
 *   IN/OUT:
 *   OUT:
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Indrajit Sen        o Created.
 *
 */

/*#
 * Use this routine to create a class category. With this API you can create a record in the
 * HZ_CLASS_CATEGORIES table. A class category provides a method of classifying parties and
 * party sites. For example, the NAICS_1997 (1997 North American Industry Classification
 * System) is a class category. A class category corresponds to an AR lookup type and the
 * related class codes are lookup codes of the lookup type. You must create a valid lookup
 * type before you can use that lookup type to create a class category.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Class Category
 * @rep:businessevent oracle.apps.ar.hz.ClassCategory.create
 * @rep:doccd 120hztig.pdf Classification API Use, Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE create_class_category(
    p_init_msg_list           IN      VARCHAR2 := FND_API.G_FALSE,
    p_class_category_rec      IN      CLASS_CATEGORY_REC_TYPE,
    x_return_status           OUT NOCOPY     VARCHAR2,
    x_msg_count               OUT NOCOPY     NUMBER,
    x_msg_data                OUT NOCOPY     VARCHAR2
);

/**
 * PROCEDURE update_class_category
 *
 * DESCRIPTION
 *     Updates class category.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_class_category_rec           Class category record.
 *   IN/OUT:
 *     p_object_version_number        Used for locking the being updated record.
 *   OUT:
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Indrajit Sen        o Created.
 *
 */

/*#
 * Use this routine to update a class category. The API updates records in the
 * HZ_CLASS_CATEGORIES table.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Class Category
 * @rep:businessevent oracle.apps.ar.hz.ClassCategory.update
 * @rep:doccd 120hztig.pdf Classification API Use, Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE update_class_category(
    p_init_msg_list           IN      VARCHAR2 := FND_API.G_FALSE,
    p_class_category_rec      IN      CLASS_CATEGORY_REC_TYPE,
    p_object_version_number   IN OUT NOCOPY  NUMBER,
    x_return_status           OUT NOCOPY     VARCHAR2,
    x_msg_count               OUT NOCOPY     NUMBER,
    x_msg_data                OUT NOCOPY     VARCHAR2
);

/**
 * PROCEDURE get_class_category_rec
 *
 * DESCRIPTION
 *     Gets class category record.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_class_category               Class category name.
 *   IN/OUT:
 *   OUT:
 *     x_class_category_rec           Returned class category record.
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Indrajit Sen        o Created.
 *
 */

PROCEDURE get_class_category_rec (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_class_category                        IN     VARCHAR2,
    x_class_category_rec                    OUT    NOCOPY CLASS_CATEGORY_REC_TYPE,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
);

/**
 * PROCEDURE create_class_code_relation
 *
 * DESCRIPTION
 *     Creates class code relationship.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_class_code_relation_rec      Class code relation record.
 *   IN/OUT:
 *   OUT:
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Indrajit Sen        o Created.
 *
 */

/*#
 * Use this routine to create a class code relation. The API creates a record in the
 * HZ_CLASS_CODE_RELATIONS table. The class codes are related to a class category.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Class Code Relation
 * @rep:businessevent oracle.apps.ar.hz.ClassCodeRelation.create
 * @rep:doccd 120hztig.pdf Classification API Use, Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE create_class_code_relation(
    p_init_msg_list           IN      VARCHAR2 := FND_API.G_FALSE,
    p_class_code_relation_rec IN      CLASS_CODE_RELATION_REC_TYPE,
    x_return_status           OUT NOCOPY     VARCHAR2,
    x_msg_count               OUT NOCOPY     NUMBER,
    x_msg_data                OUT NOCOPY     VARCHAR2
);

/**
 * PROCEDURE update_class_code_relation
 *
 * DESCRIPTION
 *     Updates class code relation.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_class_code_relation_rec      Class code relation record.
 *   IN/OUT:
 *     p_object_version_number        Used for locking the being updated record.
 *   OUT:
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Indrajit Sen        o Created.
 *
 */

/*#
 * Use this routine to update a class code relation. The API updates records in the
 * HZ_CLASS_CODE_RELATIONS table.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Class Code Relation
 * @rep:businessevent oracle.apps.ar.hz.ClassCodeRelation.update
 * @rep:doccd 120hztig.pdf Classification API Use, Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE update_class_code_relation(
    p_init_msg_list           IN      VARCHAR2:= FND_API.G_FALSE,
    p_class_code_relation_rec IN      CLASS_CODE_RELATION_REC_TYPE,
    p_object_version_number   IN OUT NOCOPY  NUMBER,
    x_return_status           OUT NOCOPY     VARCHAR2,
    x_msg_count               OUT NOCOPY     NUMBER,
    x_msg_data                OUT NOCOPY     VARCHAR2
);

/**
 * PROCEDURE get_class_code_relation_rec
 *
 * DESCRIPTION
 *     Gets class code relation record.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_class_category               Class category name.
 *     p_class_code                   Class code.
 *     p_sub_class_code               Sub class code.
 *     p_start_date_active            Start date active.
 *   IN/OUT:
 *   OUT:
 *     x_class_code_relation_rec      Returned class code relation record.
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Indrajit Sen        o Created.
 *
 */

PROCEDURE get_class_code_relation_rec(
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_class_category                        IN     VARCHAR2,
    p_class_code                            IN     VARCHAR2,
    p_sub_class_code                        IN     VARCHAR2,
    p_start_date_active                     IN     DATE,
    x_class_code_relation_rec               OUT    NOCOPY CLASS_CODE_RELATION_REC_TYPE,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
);

/**
 * PROCEDURE create_code_assignment
 *
 * DESCRIPTION
 *     Creates code assignment.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_code_assignement_rec         Code assignment record.
 *   IN/OUT:
 *   OUT:
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *     x_code_assignment_id           Code assignment ID.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Indrajit Sen        o Created.
 *
 */

/*#
 * Use this routine to create a code assignment. The API creates records in the
 * HZ_CODE_ASSIGNMENTS table. The assignment of a class code links an instance of the class
 * code to an instance of the classified table. The HZ_CODE_ASSIGNMENTS table is an
 * intersection table that links the classification codes in the AR_LOOKUPS view to the
 * instances of the parties or other entities stored in the table identified in the
 * OWNER_TABLE_NAME column. The OWNER_TABLE_ID column holds the value of the ID column in the
 * classified table.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Code Assignment
 * @rep:businessevent oracle.apps.ar.hz.CodeAssignment.create
 * @rep:doccd 120hztig.pdf Classification API Use, Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE create_code_assignment(
    p_init_msg_list             IN      VARCHAR2 := FND_API.G_FALSE,
    p_code_assignment_rec       IN      CODE_ASSIGNMENT_REC_TYPE,
    x_return_status             OUT NOCOPY     VARCHAR2,
    x_msg_count                 OUT NOCOPY     NUMBER,
    x_msg_data                  OUT NOCOPY     VARCHAR2,
    x_code_assignment_id        OUT NOCOPY     NUMBER
);

/**
 * PROCEDURE update_code_assignment
 *
 * DESCRIPTION
 *     Updates code assignment.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_code_assignment_rec          Code assignment record.
 *   IN/OUT:
 *     p_object_version_number        Used for locking the being updated record.
 *   OUT:
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Indrajit Sen        o Created.
 *
 */

/*#
 * Use this routine to update a Code Assignment. The API updates records in the
 * HZ_CODE_ASSIGNMENTS table.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Code Assignment
 * @rep:businessevent oracle.apps.ar.hz.CodeAssignment.update
 * @rep:doccd 120hztig.pdf Classification API Use, Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE update_code_assignment(
    p_init_msg_list             IN      VARCHAR2 := FND_API.G_FALSE,
    p_code_assignment_rec       IN      CODE_ASSIGNMENT_REC_TYPE,
    p_object_version_number     IN OUT NOCOPY  NUMBER,
    x_return_status             OUT NOCOPY     VARCHAR2,
    x_msg_count                 OUT NOCOPY     NUMBER,
    x_msg_data                  OUT NOCOPY     VARCHAR2
);

/**
 * PROCEDURE set_primary_code_assignment
 *
 * DESCRIPTION
 *     Sets primary code assignment.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_owner_table_name             Owner table name.
 *     p_owner_table_id               Owner table ID.
 *     p_class_category               Class category.
 *     p_class_code                   Class code.
 *     p_content_source_type          Contact source type.
 *   IN/OUT:
 *   OUT:
 *     x_code_assignment_id           Code assignment ID.
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Indrajit Sen        o Created.
 *
 */

procedure set_primary_code_assignment(
    p_init_msg_list             IN      VARCHAR2 := FND_API.G_FALSE,
    p_owner_table_name          IN      VARCHAR2,
    p_owner_table_id            IN      NUMBER,
    p_class_category            IN      VARCHAR2,
    p_class_code                IN      VARCHAR2,
    p_content_source_type       IN      VARCHAR2,
    p_created_by_module         IN      VARCHAR2, /* Bug 3856348 */
    x_code_assignment_id       OUT NOCOPY      NUMBER,
    x_return_status            OUT NOCOPY      VARCHAR2,
    x_msg_count                OUT NOCOPY      NUMBER,
    x_msg_data                 OUT NOCOPY      VARCHAR2
);

/**
 * PROCEDURE get_code_assignment_rec
 *
 * DESCRIPTION
 *     Gets code assignment record.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_code_assignment_id           Code assignment ID.
 *   IN/OUT:
 *   OUT:
 *     x_code_assignment_rec          Returned code assignment record.
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Indrajit Sen        o Created.
 *
 */

PROCEDURE get_code_assignment_rec(
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_code_assignment_id                    IN     NUMBER,
    x_code_assignment_rec                   OUT    NOCOPY CODE_ASSIGNMENT_REC_TYPE,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
);

/**
 * PROCEDURE create_class_category_use
 *
 * DESCRIPTION
 *     Creates class category use.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_class_category_use_rec       Class category use record.
 *   IN/OUT:
 *   OUT:
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Indrajit Sen        o Created.
 *
 */

/*#
 * Use this routine to create a class category Use. The API creates a record
 * in the HZ_CLASS_CATEGORY_USES table. The classification model is an open structure. The
 * HZ_CLASS_CATEGORY_USES table indicates which tables or subsets of tables use which
 * classifications. The HZ_CLASS_CATEGORY_USES table stores information about the tables which
 * use a particular class category. The ADDITIONAL_WHERE_CLAUSE is the filter for the subsets
 * of tables. For example, you can use the SIC 1987 class category to classify parties
 * that have the party type Organization. The COLUMN_NAME column stores the value of the
 * OWNER_TABLE column in the classified table that is used as the ID column for the class code
 * assignment.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Class Category Use
 * @rep:businessevent oracle.apps.ar.hz.ClassCategoryUse.create
 * @rep:doccd 120hztig.pdf Classification API Use, Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE create_class_category_use (
    p_init_msg_list           IN      VARCHAR2 := FND_API.G_FALSE,
    p_class_category_use_rec  IN      CLASS_CATEGORY_USE_REC_TYPE,
    x_return_status           OUT NOCOPY     VARCHAR2,
    x_msg_count               OUT NOCOPY     NUMBER,
    x_msg_data                OUT NOCOPY     VARCHAR2
);

/**
 * PROCEDURE update_class_category_use
 *
 * DESCRIPTION
 *     Updates class category use.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_class_category_use_rec       Class category use record.
 *   IN/OUT:
 *     p_object_version_number        Used for locking the being updated record.
 *   OUT:
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Indrajit Sen        o Created.
 *
 */

/*#
 * Use this routine to update a Class Category Use. The API updates records in the
 * HZ_CLASS_CATEGORY_USES table.
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Class Category Use
 * @rep:businessevent oracle.apps.ar.hz.ClassCategoryUse.update
 * @rep:doccd 120hztig.pdf Classification API Use, Oracle Trading Community Architecture Technical Implementation Guide
 */
PROCEDURE update_class_category_use (
    p_init_msg_list          IN      VARCHAR2:=FND_API.G_FALSE,
    p_class_category_use_rec IN      CLASS_CATEGORY_USE_REC_TYPE,
    p_object_version_number  IN OUT NOCOPY  NUMBER,
    x_return_status          OUT NOCOPY     VARCHAR2,
    x_msg_count              OUT NOCOPY     NUMBER,
    x_msg_data               OUT NOCOPY     VARCHAR2
);

/**
 * PROCEDURE get_class_category_use_rec
 *
 * DESCRIPTION
 *     Gets class category use record.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_class_category               Class category name.
 *     p_owner_table                  Owner table name.
 *   IN/OUT:
 *   OUT:
 *     x_class_category_use_rec       Returned class category use record.
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   07-23-2001    Indrajit Sen        o Created.
 *
 */

PROCEDURE get_class_category_use_rec(
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_class_category                        IN     VARCHAR2,
    p_owner_table                           IN     VARCHAR2,
    x_class_category_use_rec                OUT    NOCOPY CLASS_CATEGORY_USE_REC_TYPE,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
);


/**
 * FUNCTION is_valid_category
 *
 * DESCRIPTION
 *     ERS No: 2074686.  The function checks if a given id can be assigned to a class_category and
 *     owner_table.  It returns 'T' if party_id can be assigned or 'F' else.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_owner_table                  Owner table name.
 *     p_class_category               Name of class category
 *     p_id                           id (party_id or a party_relationship_id)
 *   IN/OUT:
 *   OUT:
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   02-14-2002    Anupam Bordia        o Created.
 *   02-18-2002    Anupam Bordia        o Altered signature to remove OUT NOCOPY parameters so that the
 *                                        function can be used within a SQL.
 *   02-03-2003    Sreedhar Mohan       o Rewritten the function as part of new HZ.K changes.
 *
 */

/*#
 * Use this function to determine if an ID can be assigned to a class_category and
 * owner_table. The function returns T if an ID can be assigned to the given
 * class_category. Otherwise, the function returns F.
 * @return True if class category is valid
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Is Class Category Valid
 * @rep:doccd 120hztig.pdf Classification API Use, Oracle Trading Community Architecture Technical Implementation Guide
 */
FUNCTION IS_VALID_CATEGORY(
   p_owner_table      VARCHAR2,
   p_class_category   VARCHAR2,
   p_id               NUMBER   := FND_API.G_MISS_NUM,
   p_key_1            VARCHAR2 := FND_API.G_MISS_CHAR,
   p_key_2            VARCHAR2 := FND_API.G_MISS_CHAR,
   p_key_3            VARCHAR2 := FND_API.G_MISS_CHAR,
   p_key_4            VARCHAR2 := FND_API.G_MISS_CHAR,
   p_key_5            VARCHAR2 := FND_API.G_MISS_CHAR
 ) RETURN VARCHAR2;


/**
 * PROCEDURE create_class_code
 *
 * DESCRIPTION
 *     This is a wrapper on top of FND_LOOKUP_VALUES_PKG.insert_row. It also
 * updates frozen flag and validate class code meaning.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_class_code_rec               Lookup value related columns
 *   IN/OUT:
 *   OUT:
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   05-28-2002    Amy Wu       o Created.
 *
 */

PROCEDURE create_class_code(
    p_init_msg_list           IN      VARCHAR2 := FND_API.G_FALSE,
    p_class_code_rec          IN      CLASS_CODE_REC_TYPE,
    x_return_status           OUT NOCOPY     VARCHAR2,
    x_msg_count               OUT NOCOPY     NUMBER,
    x_msg_data                OUT NOCOPY     VARCHAR2
);



/**
 * PROCEDURE update_class_code
 *
 * DESCRIPTION
 *     This is a wrapper on top of FND_LOOKUP_VALUES_PKG.update_row. It also
 * updates frozen flag and validate class code meaning.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_class_code_rec               Lookup value related columns
 *   IN/OUT:
 *     p_object_version_number        Used for locking the being updated record.
 *   OUT:
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   05-28-2002    Amy Wu       o Created.
 *
 */

PROCEDURE update_class_code(
    p_init_msg_list           IN      VARCHAR2:= FND_API.G_FALSE,
    p_class_code_rec	      IN      CLASS_CODE_REC_TYPE,
    p_object_version_number   IN OUT NOCOPY  NUMBER,
    x_return_status           OUT NOCOPY     VARCHAR2,
    x_msg_count               OUT NOCOPY     NUMBER,
    x_msg_data                OUT NOCOPY     VARCHAR2
);


  PROCEDURE v2_copy_class_category (
    p_class_category              IN     VARCHAR2,
    p_copy_class_category         IN     VARCHAR2,
    x_return_status               IN OUT NOCOPY VARCHAR2
);

END HZ_CLASSIFICATION_V2PUB;

 

/
