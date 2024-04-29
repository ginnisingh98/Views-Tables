--------------------------------------------------------
--  DDL for Package CSF_TASK_ASSIGNMENTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSF_TASK_ASSIGNMENTS_PUB" AUTHID CURRENT_USER AS
/* $Header: CSFPTASS.pls 120.9.12010000.2 2009/12/02 12:41:22 ramchint ship $ */

  /**
   * Creates a New Task Assignment for the given Task with the given attributes.
   *
   * If there exists any Cancelled Task Assignment for the Task with the given
   * Resource Information, then that Task Assignment is reused rather than creating a
   * new Task Assignment afresh.
   * <br>
   * If the Trip ID corresponding to the Task Assignment is passed as FND_API.G_MISS_NUM
   * then the user doesnt want to link the Assignment to any Trip. So the Trip ID will
   * be saved as NULL corresponding to the Task Assignment.
   * If Trip ID is passed as NULL or not passed at all, then the API will try to find a
   * Trip corresponding to the Assignment. Since we are dependent on Trips Model, any
   * Assignment created for a Field Service Task should be linked to a Trip (based on
   * Actual Date / Scheduled Dates). If there exists no Trip or there exists multiple trips,
   * then the API will error out. If Assignment shouldnt be linked to any Trip, then
   * Trip ID should be passed as FND_API.G_MISS_NUM.
   * <br>
   * Except for Task ID, Resouce ID, Resource Type Code all other parameters are optional.
   */
  PROCEDURE create_task_assignment (
    p_api_version                  IN          NUMBER
  , p_init_msg_list                IN          VARCHAR2 DEFAULT NULL
  , p_commit                       IN          VARCHAR2 DEFAULT NULL
  , p_validation_level             IN          NUMBER   DEFAULT NULL
  , x_return_status                OUT NOCOPY  VARCHAR2
  , x_msg_count                    OUT NOCOPY  NUMBER
  , x_msg_data                     OUT NOCOPY  VARCHAR2
  , p_task_assignment_id           IN          NUMBER   DEFAULT NULL
  , p_task_id                      IN          NUMBER
  , p_task_name                    IN          VARCHAR2 DEFAULT NULL
  , p_task_number                  IN          VARCHAR2 DEFAULT NULL
  , p_resource_type_code           IN          VARCHAR2
  , p_resource_id                  IN          NUMBER
  , p_resource_name                IN          VARCHAR2 DEFAULT NULL
  , p_actual_effort                IN          NUMBER   DEFAULT NULL
  , p_actual_effort_uom            IN          VARCHAR2 DEFAULT NULL
  , p_schedule_flag                IN          VARCHAR2 DEFAULT NULL
  , p_alarm_type_code              IN          VARCHAR2 DEFAULT NULL
  , p_alarm_contact                IN          VARCHAR2 DEFAULT NULL
  , p_sched_travel_distance        IN          NUMBER   DEFAULT NULL
  , p_sched_travel_duration        IN          NUMBER   DEFAULT NULL
  , p_sched_travel_duration_uom    IN          VARCHAR2 DEFAULT NULL
  , p_actual_travel_distance       IN          NUMBER   DEFAULT NULL
  , p_actual_travel_duration       IN          NUMBER   DEFAULT NULL
  , p_actual_travel_duration_uom   IN          VARCHAR2 DEFAULT NULL
  , p_actual_start_date            IN          DATE     DEFAULT NULL
  , p_actual_end_date              IN          DATE     DEFAULT NULL
  , p_palm_flag                    IN          VARCHAR2 DEFAULT NULL
  , p_wince_flag                   IN          VARCHAR2 DEFAULT NULL
  , p_laptop_flag                  IN          VARCHAR2 DEFAULT NULL
  , p_device1_flag                 IN          VARCHAR2 DEFAULT NULL
  , p_device2_flag                 IN          VARCHAR2 DEFAULT NULL
  , p_device3_flag                 IN          VARCHAR2 DEFAULT NULL
  , p_resource_territory_id        IN          NUMBER   DEFAULT NULL
  , p_assignment_status_id         IN          NUMBER   DEFAULT NULL
  , p_shift_construct_id           IN          NUMBER   DEFAULT NULL
  , p_object_capacity_id           IN          NUMBER   DEFAULT NULL
  , p_update_task                  IN          VARCHAR2 DEFAULT NULL
  , x_task_assignment_id           OUT NOCOPY  NUMBER
  , x_ta_object_version_number     OUT NOCOPY  NUMBER
  , x_task_object_version_number   OUT NOCOPY  NUMBER
  , x_task_status_id               OUT NOCOPY  NUMBER
  );

  /**
   * Update an existing Task Assignment with new Task Attributes
   *
   * Given the Task Assignment ID and Task Object Version Number, it calls
   * JTF Task Assignment API to update the Task Assignment with the new Attributes.
   * It is actually a two step process
   *    1. Updating the Task Assignment with the new Task Attributes except Status
   *    2. Updating the Task Assignment with the new Task Status (if not FND_API.G_MISS_NUM)
   *       by calling UPDATE_ASSIGNMENT_STATUS.
   * <br>
   * Because of the two step process, the returned Task Assignment Object
   * Version Number might be incremented by 2 when user might have expected an
   * increment of only 1.
   * <br>
   * Except Task Assignment ID and Object Version Number parameters, all are optional.
   * <br>
   * Note that for parameters starting from P_TASK_NUMBER till P_ABORT_WORKFLOW, the
   * function CSF_UTIL_PVT.G_MISS_*** is called so that Forms / Libraries calling
   * the API currently will not be affected by the error "PL/SQL ERROR 512: Implementation
   * Restriction". Note that CHR(0) can be hardcoded rather than the performance
   * intensive CSF_UTIL_PVT.GET_MISS_CHAR... but it is resulting in the error
   * "PL/SQL ERROR 707: unsupported construct or internal error [2601]" when
   * the parameter's default is CHR(0). Its working for other MISS values..except
   * for MISS_CHAR.
   */
  PROCEDURE update_task_assignment (
    p_api_version                  IN              NUMBER
  , p_init_msg_list                IN              VARCHAR2 DEFAULT NULL
  , p_commit                       IN              VARCHAR2 DEFAULT NULL
  , p_validation_level             IN              NUMBER   DEFAULT NULL
  , x_return_status                OUT    NOCOPY   VARCHAR2
  , x_msg_count                    OUT    NOCOPY   NUMBER
  , x_msg_data                     OUT    NOCOPY   VARCHAR2
  , p_task_assignment_id           IN              NUMBER
  , p_object_version_number        IN OUT NOCOPY   NUMBER
  , p_task_id                      IN              NUMBER   DEFAULT fnd_api.g_miss_num
  , p_resource_type_code           IN              VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_resource_id                  IN              NUMBER   DEFAULT fnd_api.g_miss_num
  , p_resource_territory_id        IN              NUMBER   DEFAULT fnd_api.g_miss_num
  , p_assignment_status_id         IN              NUMBER   DEFAULT fnd_api.g_miss_num
  , p_actual_start_date            IN              DATE     DEFAULT fnd_api.g_miss_date
  , p_actual_end_date              IN              DATE     DEFAULT fnd_api.g_miss_date
  , p_sched_travel_distance        IN              NUMBER   DEFAULT fnd_api.g_miss_num
  , p_sched_travel_duration        IN              NUMBER   DEFAULT fnd_api.g_miss_num
  , p_sched_travel_duration_uom    IN              VARCHAR2 DEFAULT fnd_api.g_miss_char
  , p_shift_construct_id           IN              NUMBER   DEFAULT fnd_api.g_miss_num
  , p_object_capacity_id           IN              NUMBER   DEFAULT fnd_api.g_miss_num
  , p_update_task                  IN              VARCHAR2 DEFAULT NULL
  , p_task_number                  IN              VARCHAR2 DEFAULT csf_util_pvt.get_miss_char
  , p_task_name                    IN              VARCHAR2 DEFAULT csf_util_pvt.get_miss_char
  , p_resource_name                IN              VARCHAR2 DEFAULT csf_util_pvt.get_miss_char
  , p_actual_effort                IN              NUMBER   DEFAULT csf_util_pvt.get_miss_num
  , p_actual_effort_uom            IN              VARCHAR2 DEFAULT csf_util_pvt.get_miss_char
  , p_actual_travel_distance       IN              NUMBER   DEFAULT csf_util_pvt.get_miss_num
  , p_actual_travel_duration       IN              NUMBER   DEFAULT csf_util_pvt.get_miss_num
  , p_actual_travel_duration_uom   IN              VARCHAR2 DEFAULT csf_util_pvt.get_miss_char
  , p_attribute1                   IN              VARCHAR2 DEFAULT csf_util_pvt.get_miss_char
  , p_attribute2                   IN              VARCHAR2 DEFAULT csf_util_pvt.get_miss_char
  , p_attribute3                   IN              VARCHAR2 DEFAULT csf_util_pvt.get_miss_char
  , p_attribute4                   IN              VARCHAR2 DEFAULT csf_util_pvt.get_miss_char
  , p_attribute5                   IN              VARCHAR2 DEFAULT csf_util_pvt.get_miss_char
  , p_attribute6                   IN              VARCHAR2 DEFAULT csf_util_pvt.get_miss_char
  , p_attribute7                   IN              VARCHAR2 DEFAULT csf_util_pvt.get_miss_char
  , p_attribute8                   IN              VARCHAR2 DEFAULT csf_util_pvt.get_miss_char
  , p_attribute9                   IN              VARCHAR2 DEFAULT csf_util_pvt.get_miss_char
  , p_attribute10                  IN              VARCHAR2 DEFAULT csf_util_pvt.get_miss_char
  , p_attribute11                  IN              VARCHAR2 DEFAULT csf_util_pvt.get_miss_char
  , p_attribute12                  IN              VARCHAR2 DEFAULT csf_util_pvt.get_miss_char
  , p_attribute13                  IN              VARCHAR2 DEFAULT csf_util_pvt.get_miss_char
  , p_attribute14                  IN              VARCHAR2 DEFAULT csf_util_pvt.get_miss_char
  , p_attribute15                  IN              VARCHAR2 DEFAULT csf_util_pvt.get_miss_char
  , p_attribute_category           IN              VARCHAR2 DEFAULT csf_util_pvt.get_miss_char
  , p_show_on_calendar             IN              VARCHAR2 DEFAULT csf_util_pvt.get_miss_char
  , p_category_id                  IN              NUMBER   DEFAULT csf_util_pvt.get_miss_num
  , p_schedule_flag                IN              VARCHAR2 DEFAULT csf_util_pvt.get_miss_char
  , p_alarm_type_code              IN              VARCHAR2 DEFAULT csf_util_pvt.get_miss_char
  , p_alarm_contact                IN              VARCHAR2 DEFAULT csf_util_pvt.get_miss_char
  , p_palm_flag                    IN              VARCHAR2 DEFAULT csf_util_pvt.get_miss_char
  , p_wince_flag                   IN              VARCHAR2 DEFAULT csf_util_pvt.get_miss_char
  , p_laptop_flag                  IN              VARCHAR2 DEFAULT csf_util_pvt.get_miss_char
  , p_device1_flag                 IN              VARCHAR2 DEFAULT csf_util_pvt.get_miss_char
  , p_device2_flag                 IN              VARCHAR2 DEFAULT csf_util_pvt.get_miss_char
  , p_device3_flag                 IN              VARCHAR2 DEFAULT csf_util_pvt.get_miss_char
  , p_enable_workflow              IN              VARCHAR2 DEFAULT csf_util_pvt.get_miss_char
  , p_abort_workflow               IN              VARCHAR2 DEFAULT csf_util_pvt.get_miss_char
  , x_task_object_version_number   OUT    NOCOPY   NUMBER
  , x_task_status_id               OUT    NOCOPY   NUMBER
  );

  /**
   * Update the Status of the Task Assignment with the given Status and propagate to the
   * Task also if required.
   * <br>
   * Task Assignment is updated with the new Status if the Transition from the current
   * status to the new status is allowed as determined by
   * CSF_TASKS_PUB.VALIDATE_STATE_TRANSITION. Transition validation is done only
   * when Validation Level is passed as FULL.
   * <br>
   * In addition to updating the Task Assignment Status, the following operations are also
   * done
   *   1. If the Task corresponding to the given Task Assignment has no other
   *      Open / Active Task Assignments other than the given one, then the Assignment
   *      Status is propagated to the Task also. If there exists any other Active
   *      Assignment, then the Task is not updated.
   *      The parameters P_TASK_OBJECT_VERSION_NUMBER and X_TASK_STATUS_ID reflect
   *      the Object Version Number and Task Status ID of the Task in Database
   *      irrespective of the fact whether the update has taken place or not. <br>
   *
   *   2. If the Assignment goes to Cancelled (as per the new status), then if any
   *      Spares Order is linked to the Assignment, they are cleaned up by calling
   *      CLEAN_MATERIAL_TRANSACTION of Spares. <br>
   *
   *   3. If the Assignment goes to Assigned (as per the new status), and the
   *      old status is not Assigned, then Orders are created and linked to the
   *      Task Assignment. <br>
   *
   *   4. If the Assignnment goes to Working (as per the new status), then it means
   *      that the Resource is working on the Task and so his location should be updated
   *      to reflect the location of the Task. This is required by Map Functionality.
   *      THIS IS WRONG AND SHOULD BE REMOVED. MAP SHOULD BE USING HZ_LOCATIONS TABLE. <br>
   *
   * @param  p_api_version                  API Version (1.0)
   * @param  p_init_msg_list                Initialize Message List
   * @param  p_commit                       Commit the Work
   * @param  p_validation_level             Validate the given Parameters
   * @param  x_return_status                Return Status of the Procedure.
   * @param  x_msg_count                    Number of Messages in the Stack.
   * @param  x_msg_data                     Stack of Error Messages.
   * @param  p_task_assignment_id           Task Assignment ID of the Assignment to be updated
   * @param  p_assignment_status_id         New Status ID for the Assignment
   * @param  p_old_assignment_status_id     Old Status ID for the Assignment
   * @param  p_show_on_calendar             <Dont Know>
   * @param  p_object_version_number        Current Task Version and also container for new one.
   * @param  x_task_object_version_number   Task Object Version Number (either old or new)
   * @param  x_task_status_id               Task Status ID (either old or new)
   */
  PROCEDURE update_assignment_status (
    p_api_version                  IN            NUMBER
  , p_init_msg_list                IN            VARCHAR2 DEFAULT NULL
  , p_commit                       IN            VARCHAR2 DEFAULT NULL
  , p_validation_level             IN            NUMBER   DEFAULT NULL
  , x_return_status                OUT    NOCOPY VARCHAR2
  , x_msg_count                    OUT    NOCOPY NUMBER
  , x_msg_data                     OUT    NOCOPY VARCHAR2
  , p_task_assignment_id           IN            NUMBER
  , p_object_version_number        IN OUT NOCOPY NUMBER
  , p_assignment_status_id         IN            NUMBER
  , p_update_task                  IN            VARCHAR2 DEFAULT NULL
  , p_show_on_calendar             IN            VARCHAR2 DEFAULT 'Y'
  , x_task_object_version_number   OUT    NOCOPY NUMBER
  , x_task_status_id               OUT    NOCOPY NUMBER
  );

  PROCEDURE cross_task_validation (x_return_status out nocopy varchar2);

END;

/
