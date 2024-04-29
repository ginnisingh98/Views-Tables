--------------------------------------------------------
--  DDL for Package HXC_TIMECARD_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TIMECARD_UTILITIES" AUTHID CURRENT_USER AS
/* $Header: hxctcutil.pkh 120.4 2007/11/29 07:09:46 anuthi noship $ */
   TYPE time_period IS RECORD (
      start_date          DATE,
      end_date            DATE,
      exist_flag          VARCHAR2 (5),
      p_set_more_period   VARCHAR2 (1)
   );

   TYPE periods IS TABLE OF time_period
      INDEX BY BINARY_INTEGER;

/*=========================================================================
 * This procedure is overloaded by the new procedure. We keep it here to
 * support our existing middle tier code. Any new code should NOT call this
 * procedure.
 *========================================================================*/
   PROCEDURE get_time_periods (
      p_resource_id              IN              VARCHAR2,
      p_resource_type            IN              VARCHAR2,
      p_rec_period_start_date    IN              VARCHAR2,
      p_period_type              IN              VARCHAR2,
      p_duration_in_days         IN              VARCHAR2,
      p_current_date             IN              VARCHAR2,
      p_num_past_entries         IN              VARCHAR2,
      p_num_future_entries       IN              VARCHAR2,
      p_num_past_days            IN              VARCHAR2,
      p_num_future_days          IN              VARCHAR2,
      p_hire_date                IN              VARCHAR2,
      p_show_existing_timecard   IN              VARCHAR2,
      p_first_empty_period       IN              VARCHAR2,
      p_periods                  OUT NOCOPY      VARCHAR2
   );

   PROCEDURE get_current_period (
      p_rec_period_start_date   IN              VARCHAR2,
      p_period_type             IN              VARCHAR2,
      p_duration_in_days        IN              VARCHAR2,
      p_current_date            IN              VARCHAR2,
      p_period                  OUT NOCOPY      VARCHAR2
   );

/*=========================================================================
 * this new procedure evaluates period related preferences on the server
 * side. It should be the one to be called by the middle tier from now on.
 * However we keep the old one to be compatible with existing middle tier
 * code.
 *========================================================================*/
   PROCEDURE get_time_periods (
      p_resource_id              IN              VARCHAR2,
      p_resource_type            IN              VARCHAR2,
      p_current_date             IN              VARCHAR2,
      p_show_existing_timecard   IN              VARCHAR2,
      p_first_empty_period       IN              VARCHAR2,
      p_periods                  OUT NOCOPY      VARCHAR2
   );

   FUNCTION get_pto_balance (
      p_resource_id     IN   VARCHAR2,
      p_assignment_id   IN   VARCHAR2,
      p_start_time      IN   VARCHAR2,
      p_plan_code       IN   VARCHAR2
   )
      RETURN VARCHAR2;

/*=========================================================================
 * this new procedure evaluates period related preferences on the server
 * side. It should be the one to be called by the middle tier from now on.
 * However we keep the old one to be compatible with existing middle tier
 * code. This interface is returning a pl/sql table.
 *========================================================================*/
   PROCEDURE get_period_list (
      p_resource_id              IN              NUMBER,
      p_resource_type            IN              VARCHAR2,
      p_current_date             IN              DATE,
      p_show_existing_timecard   IN              VARCHAR2,
      p_periods                  OUT NOCOPY      VARCHAR2
   );

   FUNCTION get_assignment_periods (
      p_resource_id   IN   hxc_time_building_blocks.resource_id%TYPE
   )
      RETURN periods;

   PROCEDURE process_assignments (
      p_period               IN              time_period,
      p_assignment_periods   IN              periods,
      p_return_periods       IN OUT NOCOPY   periods
   );

   PROCEDURE find_current_period (
      p_rec_period_start_date   IN              DATE,
      p_period_type             IN              VARCHAR2,
      p_duration_in_days        IN              NUMBER,
      p_current_date            IN              DATE,
      p_period_start            OUT NOCOPY      DATE,
      p_period_end              OUT NOCOPY      DATE
   );

   PROCEDURE cla_summary_alias_translation (
      p_timecard_id   IN              NUMBER,
      p_resource_id   IN              NUMBER,
      p_attributes    IN OUT NOCOPY   hxc_attribute_table_type,
      p_blocks        IN OUT NOCOPY   hxc_block_table_type,
      p_messages      IN OUT NOCOPY   hxc_message_table_type
   );

   PROCEDURE init_globals (
      p_resource_id   IN   hxc_time_building_blocks.resource_id%TYPE
   );

   FUNCTION get_periods (
      p_resource_id              IN   NUMBER,
      p_resource_type            IN   VARCHAR2,
      p_current_date             IN   DATE,
      p_show_existing_timecard   IN   VARCHAR2
   )
      RETURN periods;
END hxc_timecard_utilities;

/
