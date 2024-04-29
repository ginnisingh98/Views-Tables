--------------------------------------------------------
--  DDL for Package JTF_TASK_UTL_EXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASK_UTL_EXT" AUTHID CURRENT_USER AS
/* $Header: jtfptkxs.pls 120.3 2006/09/29 22:24:05 twan ship $ */
/*#
 * This is an ext. package contains commonly used task utilities.
 *
 * @rep:scope private
 * @rep:product CAC
 * @rep:lifecycle active
 * @rep:displayname Jtf Task Dependency
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CAC_CAL_TASK
 */


/**
 * This method is for date adjustment if there is time offset and time offset uom
 *
 * @param p_original_date       the date to be adjusted
 * @param p_adjustment_time     the time offset to be used for adjustment
 * @param p_adjustment_time_uom the time offset uom to be used for adjustment
 * @return adjusted date
 *
 * @rep:scope private
 * @rep:product JTF
 * @rep:lifecycle active
 * @rep:displayname Validate Task Dependency
 * @rep:compatibility S
 */
    function adjust_date(p_original_date in date,
                         p_adjustment_time in number,
                         p_adjustment_time_uom in varchar2)
    return date;

    pragma restrict_references (adjust_date, WNDS);

/**
 * Returns implicit booking start date. This function is used only for migration of implicit bookings and is not created to be used by any other way. It is called by scrpit: <code>cacbkgmg.sql</code>.
 *
 * @param p_calendar_start_date the calendar start date.
 * @param p_calendar_end_date the calendar end date.
 * @param p_actual_start_date the actual start date (source: the assignment).
 * @param p_actual_end_date the actual end date (source: the assignment).
 * @param p_actaul_travel_duration the actual travel duration.
 * @param p_actaul_travel_duration_uom the actual travel duration UOM.
 * @param p_planned_effort the planned effort UOM.
 * @param p_planned_effort_uom the planned effort UOM.
 * @param p_actual_effort the actual effort UOM.
 * @param p_actual_effort_uom the actual effort UOM.
 * @return booking start date
 *
 * @rep:scope private
 * @rep:product JTF
 * @rep:lifecycle active
 * @rep:displayname Get Booking Start Date
 * @rep:compatibility S
 */
 FUNCTION get_bsd
    (
      p_calendar_start_date        IN	DATE,
      p_calendar_end_date          IN	DATE,
      p_actual_start_date          IN	DATE,
      p_actual_end_date            IN	DATE,
      p_actual_travel_duration     IN NUMBER,
      p_actual_travel_duration_uom IN VARCHAR2,
      p_planned_effort             IN NUMBER,
      p_planned_effort_uom         IN VARCHAR2,
      p_actual_effort              IN NUMBER,
      p_actual_effort_uom          IN VARCHAR2
    ) RETURN DATE;

    pragma restrict_references (get_bsd, WNDS);

/**
 * Returns implicit booking end date. This function is used only for migration of implicit bookings and is not created to be used by any other way. It is called by scrpit: <code>cacbkgmg.sql</code>.
 *
 * @param p_calendar_start_date the calendar start date.
 * @param p_calendar_end_date the calendar end date.
 * @param p_actual_start_date the actual start date (source: the assignment).
 * @param p_actual_end_date the actual end date (source: the assignment).
 * @param p_actaul_travel_duration the actual travel duration.
 * @param p_actaul_travel_duration_uom the actual travel duration UOM.
 * @param p_planned_effort the planned effort UOM.
 * @param p_planned_effort_uom the planned effort UOM.
 * @param p_actual_effort the actual effort UOM.
 * @param p_actual_effort_uom the actual effort UOM.
 * @return booking start date
 *
 * @rep:scope private
 * @rep:product JTF
 * @rep:lifecycle active
 * @rep:displayname Get Booking End Date
 * @rep:compatibility S
 */
 FUNCTION get_bed
    (
      p_calendar_start_date        IN	DATE,
      p_calendar_end_date          IN	DATE,
      p_actual_start_date          IN	DATE,
      p_actual_end_date            IN	DATE,
      p_actual_travel_duration     IN NUMBER,
      p_actual_travel_duration_uom IN VARCHAR2,
      p_planned_effort             IN NUMBER,
      p_planned_effort_uom         IN VARCHAR2,
      p_actual_effort              IN NUMBER,
      p_actual_effort_uom          IN VARCHAR2
    ) RETURN DATE;

    pragma restrict_references (get_bed, WNDS);

    ------------------------------------------------------
    -- For enhancement 2666995
    ------------------------------------------------------
    FUNCTION get_open_flag (p_task_status_id IN NUMBER)
    RETURN VARCHAR2;

    ------------------------------------------------------
    -- For enhancement 2683868
    ------------------------------------------------------
   PROCEDURE set_calendar_dates (
     p_show_on_calendar in varchar2 default null,
     p_date_selected in varchar2 default null,
     p_planned_start_date in date default null,
     p_planned_end_date in date default null,
     p_scheduled_start_date in date default null,
     p_scheduled_end_date in date default null,
     p_actual_start_date in date default null,
     p_actual_end_date in date default null,
     x_show_on_calendar in out NOCOPY varchar2, -- Fixed from OUT to IN OUT
     x_date_selected in out NOCOPY varchar2, -- Fixed from OUT to IN OUT
     x_calendar_start_date out NOCOPY date,
     x_calendar_end_date out NOCOPY date,
     x_return_status out NOCOPY varchar2,
     p_task_status_id IN NUMBER, -- Enhancement 2683868: new parameter
     p_creation_date IN DATE     -- Enhancement 2683868: new parameter
   );

    PROCEDURE set_start_n_due_date (
        p_task_status_id        IN NUMBER,
        p_planned_start_date    IN DATE,
        p_planned_end_date      IN DATE,
        p_scheduled_start_date  IN DATE,
        p_scheduled_end_date    IN DATE,
        p_actual_start_date     IN DATE,
        p_actual_end_date       IN DATE,
        p_creation_date         IN DATE,
        x_calendar_start_date   OUT NOCOPY DATE,
        x_calendar_end_date     OUT NOCOPY DATE,
        x_return_status         OUT NOCOPY VARCHAR2
    );
    ------------------------------------------------------

    ------------------------------------------------------
    -- For enhancement 2734020
    ------------------------------------------------------
    FUNCTION get_last_number(p_sequence_name IN VARCHAR2)
    RETURN NUMBER;

    -- For Bug 2786689 (CYCLIC TASK) ..
    PROCEDURE validate_cyclic_task (
        p_task_id              IN              NUMBER,
        p_parent_task_id       IN              NUMBER,
        x_return_status        OUT NOCOPY      VARCHAR2
    );

    ------------------------------------------------------
    -- For bug 2891531
    ------------------------------------------------------
    PROCEDURE update_object_code (
         p_task_id           IN NUMBER
        ,p_old_object_code   IN VARCHAR2
        ,p_new_object_code   IN VARCHAR2
        ,p_old_object_id     IN NUMBER
        ,p_new_object_id     IN NUMBER
        ,p_new_object_name   IN VARCHAR2
        ,x_return_status     OUT NOCOPY VARCHAR2
        ,x_msg_count         OUT NOCOPY NUMBER
        ,x_msg_data          OUT NOCOPY VARCHAR2
    );

    ------------------------------------------------------
    -- For bug 2896532
    ------------------------------------------------------
    FUNCTION get_object_details (p_object_code IN VARCHAR2
                                ,p_object_id   IN NUMBER)
    RETURN VARCHAR2;

    --Bug 2786689
	FUNCTION get_task_name (p_task_id IN NUMBER)
    RETURN VARCHAR2;

/*
   Added for Bug # 3360228
   extended from jtf_task_utl.check_duplicate_reference.
   this validation function should be called for reference update only.
*/
   FUNCTION check_dup_reference_for_update(
               p_task_reference_id jtf_task_references_b.task_reference_id%type,
               p_task_id jtf_tasks_b.task_id%type,
               p_object_id hz_relationships.object_id%type,
               p_object_type_code jtf_task_references_b.object_type_code%type)
   return boolean;



END jtf_task_utl_ext;

 

/
