--------------------------------------------------------
--  DDL for Package CSF_TASK_DEPENDENCY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSF_TASK_DEPENDENCY_PUB" AUTHID CURRENT_USER as
/* $Header: CSFPTKDS.pls 120.0 2005/05/24 17:32:06 appldev noship $ */

-- Start of Comments

-- Package name     : CSF_TASK_DEPENDENCY_PUB
-- Purpose          : This package is related to the task dependency
-- History          : Created by sseshaiy on 26-aug-2004
-- NOTE             : This package do the operations on jtf_task_depends table

-- End of Comments

/**
 * Create task dependency always set the Validate flag as 'N' and validate flag is not exposed
 * @param p_api_version the standard API version number
 * @param p_init_msg_list the standard API flag allows API callers to request
 * that the API does the initialization of the message list on their behalf.
 * By default, the message list will not be initialized.
 * @param p_commit the standard API flag is used by API callers to ask
 * the API to commit on their behalf after performing its function
 * By default, the commit will not be performed.
 * @param p_validation_level the standard API validation level
 * @param p_task_id the task id for dependency creation
 * @param p_dependent_on_task_id the master task id for dependency creation
 * @param p_dependency_type_code the dependency type code of the dependency
 * @param x_dependency_id the dependency id being created
 * @param x_return_status returns the result of all the operations performed
 * by the API and must have one of the following values:
 *   <LI><Code>FND_API.G_RET_STS_SUCCESS</Code>
 *   <LI><Code>FND_API.G_RET_STS_ERROR</Code>
 *   <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code>
 * @param x_msg_data returns the message in an encoded format if
 * <code>x_msg_count</code> returns number one.
 * @param x_msg_count returns the number of messages in the API message list
 * @param p_attribute1 attribute1 for flexfield
 * @param p_attribute2 attribute2 for flexfield
 * @param p_attribute3 attribute3 for flexfield
 * @param p_attribute4 attribute4 for flexfield
 * @param p_attribute5 attribute5 for flexfield
 * @param p_attribute6 attribute6 for flexfield
 * @param p_attribute7 attribute7 for flexfield
 * @param p_attribute8 attribute8 for flexfield
 * @param p_attribute9 attribute9 for flexfield
 * @param p_attribute10 attribute10 for flexfield
 * @param p_attribute11 attribute11 for flexfield
 * @param p_attribute12 attribute12 for flexfield
 * @param p_attribute13 attribute13 for flexfield
 * @param p_attribute14 attribute14 for flexfield
 * @param p_attribute15 attribute15 for flexfield
 * @param p_attribute_category attribute category
 */

    PROCEDURE CREATE_TASK_DEPENDENCY_NV (
        p_api_version                IN           NUMBER,
        p_init_msg_list              IN           VARCHAR2  DEFAULT NULL,
        p_commit                     IN           VARCHAR2  DEFAULT NULL,
        p_validation_level           IN           VARCHAR2  DEFAULT NULL,
        p_task_id                    IN           NUMBER,
        p_dependent_on_task_id       IN           NUMBER,
        p_dependency_type_code       IN           VARCHAR2,
        x_dependency_id              OUT NOCOPY   NUMBER,
        x_return_status              OUT NOCOPY   VARCHAR2,
        x_msg_count                  OUT NOCOPY   NUMBER,
        x_msg_data                   OUT NOCOPY   VARCHAR2,
        p_attribute1                 IN           VARCHAR2 DEFAULT NULL ,
        p_attribute2                 IN           VARCHAR2 DEFAULT NULL ,
        p_attribute3                 IN           VARCHAR2 DEFAULT NULL ,
        p_attribute4                 IN           VARCHAR2 DEFAULT NULL ,
        p_attribute5                 IN           VARCHAR2 DEFAULT NULL ,
        p_attribute6                 IN           VARCHAR2 DEFAULT NULL ,
        p_attribute7                 IN           VARCHAR2 DEFAULT NULL ,
        p_attribute8                 IN           VARCHAR2 DEFAULT NULL ,
        p_attribute9                 IN           VARCHAR2 DEFAULT NULL ,
        p_attribute10                IN           VARCHAR2 DEFAULT NULL ,
        p_attribute11                IN           VARCHAR2 DEFAULT NULL ,
        p_attribute12                IN           VARCHAR2 DEFAULT NULL ,
        p_attribute13                IN           VARCHAR2 DEFAULT NULL ,
        p_attribute14                IN           VARCHAR2 DEFAULT NULL ,
        p_attribute15                IN           VARCHAR2 DEFAULT NULL ,
        p_attribute_category         IN           VARCHAR2 DEFAULT NULL
    );

/**
 * Task dependency row locking API.
 *
 * @param p_api_version the standard API version number
 * @param p_init_msg_list the standard API flag allows API callers to request
 * that the API does the initialization of the message list on their behalf.
 * By default, the message list will not be initialized.
 * @param p_commit the standard API flag is used by API callers to ask
 * the API to commit on their behalf after performing its function
 * By default, the commit will not be performed.
 * @param p_object_version_number the object version number for lock
 * @param x_dependency_id the dependency id being locked
 * @param x_return_status returns the result of all the operations performed
 * by the API and must have one of the following values:
 *   <LI><Code>FND_API.G_RET_STS_SUCCESS</Code>
 *   <LI><Code>FND_API.G_RET_STS_ERROR</Code>
 *   <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code>
 * @param x_msg_data returns the message in an encoded format if
 * <code>x_msg_count</code> returns number one.
 * @param x_msg_count returns the number of messages in the API message list
 */

   PROCEDURE  LOCK_TASK_DEPENDENCY (
      p_api_version             IN            NUMBER,
      p_init_msg_list           IN            VARCHAR2 DEFAULT NULL,
      p_commit                  IN            VARCHAR2 DEFAULT NULL,
      p_dependency_id           IN            NUMBER,
      p_object_version_number   IN            NUMBER ,
      x_return_status           OUT NOCOPY    VARCHAR2,
      x_msg_data                OUT NOCOPY    VARCHAR2,
      x_msg_count               OUT NOCOPY    NUMBER
   );


/**
 * Task dependency update API.
 *
 * @param p_api_version the standard API version number
 * @param p_init_msg_list the standard API flag allows API callers to request
 * that the API does the initialization of the message list on their behalf.
 * By default, the message list will not be initialized.
 * @param p_commit the standard API flag is used by API callers to ask
 * the API to commit on their behalf after performing its function
 * By default, the commit will not be performed.
 * @param p_object_version_number the object version number for dependency update
 * @param p_dependency_id the dependency id for dependency update
 * @param p_task_id the sub task id for dependency update
 * @param p_dependent_on_task_id the master task id for dependency update
 * @param p_dependent_on_task_number the master task number for dependency update
 * @param p_dependency_type_code the dependency type code of the dependency
 * @param p_adjustment_time the time offset to be applied to re-calculate the master tasks scheduled start date or end date
 * @param p_adjustment_time_uom  the unit of measure of the time offset to be applied for date re-calculation
 * @param p_validated_flag the validated flag
 * @param x_return_status returns the result of all the operations performed
 * by the API and must have one of the following values:
 *   <LI><Code>FND_API.G_RET_STS_SUCCESS</Code>
 *   <LI><Code>FND_API.G_RET_STS_ERROR</Code>
 *   <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code>
 * @param x_msg_count returns the number of messages in the API message list
 * <code>x_msg_count</code> returns number one.
 * @param x_msg_data returns the message in an encoded format if
 * @param p_attribute1 attribute1 for flexfield
 * @param p_attribute2 attribute2 for flexfield
 * @param p_attribute3 attribute3 for flexfield
 * @param p_attribute4 attribute4 for flexfield
 * @param p_attribute5 attribute5 for flexfield
 * @param p_attribute6 attribute6 for flexfield
 * @param p_attribute7 attribute7 for flexfield
 * @param p_attribute8 attribute8 for flexfield
 * @param p_attribute9 attribute9 for flexfield
 * @param p_attribute10 attribute10 for flexfield
 * @param p_attribute11 attribute11 for flexfield
 * @param p_attribute12 attribute12 for flexfield
 * @param p_attribute13 attribute13 for flexfield
 * @param p_attribute14 attribute14 for flexfield
 * @param p_attribute15 attribute15 for flexfield
 * @param p_attribute_category attribute category
 */

    PROCEDURE UPDATE_TASK_DEPENDENCY (
        p_api_version                IN                 NUMBER,
        p_init_msg_list              IN                 VARCHAR2 DEFAULT NULL,
        p_commit                     IN                 VARCHAR2 DEFAULT NULL,
        p_object_version_number      IN  OUT NOCOPY     NUMBER,
        p_dependency_id              IN                 NUMBER,
        p_task_id                    IN                 NUMBER   DEFAULT NULL,
        p_dependent_on_task_id       IN                 NUMBER   DEFAULT NULL,
        p_dependency_type_code       IN                 VARCHAR2 DEFAULT NULL,
        x_return_status              OUT     NOCOPY     VARCHAR2,
        x_msg_count                  OUT     NOCOPY     NUMBER,
        x_msg_data                   OUT     NOCOPY     VARCHAR2,
        p_attribute1                 IN                 VARCHAR2 DEFAULT NULL,
        p_attribute2                 IN                 VARCHAR2 DEFAULT NULL,
        p_attribute3                 IN                 VARCHAR2 DEFAULT NULL,
        p_attribute4                 IN                 VARCHAR2 DEFAULT NULL,
        p_attribute5                 IN                 VARCHAR2 DEFAULT NULL,
        p_attribute6                 IN                 VARCHAR2 DEFAULT NULL,
        p_attribute7                 IN                 VARCHAR2 DEFAULT NULL,
        p_attribute8                 IN                 VARCHAR2 DEFAULT NULL,
        p_attribute9                 IN                 VARCHAR2 DEFAULT NULL,
        p_attribute10                IN                 VARCHAR2 DEFAULT NULL,
        p_attribute11                IN                 VARCHAR2 DEFAULT NULL,
        p_attribute12                IN                 VARCHAR2 DEFAULT NULL,
        p_attribute13                IN                 VARCHAR2 DEFAULT NULL,
        p_attribute14                IN                 VARCHAR2 DEFAULT NULL,
        p_attribute15                IN                 VARCHAR2 DEFAULT NULL,
        p_attribute_category         IN                 VARCHAR2 DEFAULT NULL
    );

/**
 * Task dependency delete API.
 *
 * @param p_api_version the standard API version number
 * @param p_init_msg_list the standard API flag allows API callers to request
 * that the API does the initialization of the message list on their behalf.
 * By default, the message list will not be initialized.
 * @param p_commit the standard API flag is used by API callers to ask
 * the API to commit on their behalf after performing its function
 * By default, the commit will not be performed.
 * @param p_object_version_number the object version number for delete
 * @param p_dependency_id the dependency id being deleted
 * @param x_return_status returns the result of all the operations performed
 * by the API and must have one of the following values:
 *   <LI><Code>FND_API.G_RET_STS_SUCCESS</Code>
 *   <LI><Code>FND_API.G_RET_STS_ERROR</Code>
 *   <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code>
 * @param x_msg_count returns the number of messages in the API message list
 * @param x_msg_data returns the message in an encoded format if
 * <code>x_msg_count</code> returns number one.
 */
    PROCEDURE DELETE_TASK_DEPENDENCY (
        p_api_version             IN              NUMBER,
        p_init_msg_list           IN              VARCHAR2 DEFAULT NULL,
        p_commit                  IN              VARCHAR2 DEFAULT NULL,
        p_object_version_number   IN              NUMBER ,
        p_dependency_id           IN              NUMBER,
        x_return_status           OUT NOCOPY      VARCHAR2,
        x_msg_count               OUT NOCOPY      NUMBER,
        x_msg_data                OUT NOCOPY      VARCHAR2
    );

 -- For the given task id, all the dependencies are deleted.
    PROCEDURE CLEAR_TASK_DEPENDENCIES (
          p_api_version             IN              NUMBER
        , p_init_msg_list           IN              VARCHAR2 DEFAULT NULL
        , p_commit                  IN              VARCHAR2 DEFAULT NULL
        , p_task_id                 IN              NUMBER
        , x_return_status           OUT NOCOPY      VARCHAR2
        , x_msg_count               OUT NOCOPY      NUMBER
        , x_msg_data                OUT NOCOPY      VARCHAR2
    );

END CSF_TASK_DEPENDENCY_PUB;


 

/
