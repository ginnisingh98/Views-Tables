--------------------------------------------------------
--  DDL for Package HXT_OTC_RETRIEVAL_INTERFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXT_OTC_RETRIEVAL_INTERFACE" AUTHID CURRENT_USER AS
/* $Header: hxtotcri.pkh 120.1.12010000.3 2009/11/03 07:57:32 asrajago ship $ */
   TYPE t_field_name IS TABLE OF VARCHAR2 (80)
      INDEX BY BINARY_INTEGER;

   TYPE t_value IS TABLE OF VARCHAR2 (150)
      INDEX BY BINARY_INTEGER;

   TYPE t_segment IS TABLE OF VARCHAR2 (60)
      INDEX BY BINARY_INTEGER;



   -- Bug 8888777
   -- Added new data type for storing Input Values.

   TYPE IV_record IS RECORD
   (
    attribute1	VARCHAR2(400),
    attribute2	VARCHAR2(400),
    attribute3	VARCHAR2(400),
    attribute4	VARCHAR2(400),
    attribute5	VARCHAR2(400),
    attribute6	VARCHAR2(400),
    attribute7	VARCHAR2(400),
    attribute8	VARCHAR2(400),
    attribute9	VARCHAR2(400),
    attribute10	VARCHAR2(400),
    attribute11	VARCHAR2(400),
    attribute12	VARCHAR2(400),
    attribute13	VARCHAR2(400),
    attribute14	VARCHAR2(400),
    attribute15	VARCHAR2(400));


   TYPE IV_TABLE IS TABLE OF IV_RECORD INDEX BY BINARY_INTEGER;

   g_iv_table  IV_TABLE;


-- Bug 7415291
-- New data types for handling the re-explosion of timecard.
--------------------------------------------------------------------------------
   -- A record type to handle earning policy id
   -- and the start and end dates effective on the assignment.
   TYPE earn_pol_rec IS RECORD
   ( earn_pol_id     NUMBER,
     start_date      DATE,
     end_date        DATE );

   -- Create a table of the above type.  Each person would have
   -- one or more record as above, so this table is used to maintain it.

   TYPE earn_pol_tab IS TABLE OF earn_pol_rec;

   -- Create a record of this above table type.

   TYPE assg_earn_pol_rec IS RECORD
   (
      ep_list     earn_pol_tab
   );

   -- Create an associative array of the above type.
   -- Each element in the array would have a record, whose only member is
   -- a plsql table of record type earn_pol_rec.  Meaning each
   -- assignment will have its own plsql table of earning policies.

   TYPE earn_pol_assoc_array IS TABLE OF assg_earn_pol_rec INDEX BY VARCHAR2(15);

   -- Create a list of this associative array to be maintained globally.

   g_earn_pol_list  earn_pol_assoc_array;


  -- Create a table of NUMBERs to store the elements.
  TYPE element_tab IS TABLE OF NUMBER;

  -- Create a record whose member is the plsql table of numbers.
  TYPE eg_elements IS RECORD
  (
    element_list  element_tab
  );

  -- Create an associative array of this record as above.

  TYPE ep_eg_list IS TABLE OF eg_elements INDEX BY VARCHAR2(15);

  -- Create an object of the above array. Each element in the array would have
  -- a number type plsql table.  Meaning each earning policy id will have its
  -- own list of elements in the earning group.

  g_earn_group_list ep_eg_list ;

--------------------------------------------------------------------------------


   g_full_name   VARCHAR2 (240);

   FUNCTION get_employee_number (
      p_person_id        IN   NUMBER,
      p_effective_date   IN   DATE
   )
      RETURN VARCHAR2;

   PROCEDURE get_assignment_id (
      p_person_id        IN              NUMBER,
      p_payroll_id       OUT NOCOPY      NUMBER,
      p_bg_id            OUT NOCOPY      NUMBER,
      p_assignment_id    OUT NOCOPY      NUMBER,
      p_effective_date   IN              DATE
   );

   -- Bug 8888777
   -- Added new paramete p_bb_id

   PROCEDURE parse_attributes (
      p_category        IN OUT NOCOPY   t_field_name,
      p_field_name      IN OUT NOCOPY   t_field_name,
      p_value           IN OUT NOCOPY   t_value,
      p_context         IN OUT NOCOPY   t_field_name,
      p_date_worked     OUT NOCOPY      DATE,
      p_type            IN              VARCHAR2,
      p_measure         IN              NUMBER,
      p_start_time      IN              DATE,
      p_stop_time       IN              DATE,
      p_assignment_id   IN              NUMBER,
      p_hours           OUT NOCOPY      NUMBER,
      p_hours_type      OUT NOCOPY      VARCHAR2,
      p_segment         OUT NOCOPY      t_segment,
      p_project         OUT NOCOPY      VARCHAR2,
      p_task            OUT NOCOPY      VARCHAR2,
      p_STATE_NAME      OUT NOCOPY      VARCHAR2,
      p_COUNTY_NAME     OUT NOCOPY      VARCHAR2,
      p_CITY_NAME       OUT NOCOPY      VARCHAR2,
      p_ZIP_CODE        OUT NOCOPY      VARCHAR2,
      p_bb_id           IN              NUMBER   DEFAULT 0
   );

   -- Bug 8888777
   -- Added new paramete p_bb_id

   PROCEDURE parse_attributes (
      p_category        IN OUT NOCOPY   t_field_name,
      p_field_name      IN OUT NOCOPY   t_field_name,
      p_value           IN OUT NOCOPY   t_value,
      p_context         IN OUT NOCOPY   t_field_name,
      p_date_worked     OUT NOCOPY      DATE,
      p_type            IN              VARCHAR2,
      p_measure         IN              NUMBER,
      p_start_time      IN              DATE,
      p_stop_time       IN              DATE,
      p_assignment_id   IN              NUMBER,
      p_hours           OUT NOCOPY      NUMBER,
      p_hours_type      OUT NOCOPY      VARCHAR2,
      p_segment         OUT NOCOPY      t_segment,
      p_amount          OUT NOCOPY      NUMBER,
      p_hourly_rate     OUT NOCOPY      NUMBER,
      p_rate_multiple   OUT NOCOPY      NUMBER,
      p_project         OUT NOCOPY      VARCHAR2,
      p_task            OUT NOCOPY      VARCHAR2,
      p_STATE_NAME      OUT NOCOPY      VARCHAR2,
      p_COUNTY_NAME     OUT NOCOPY      VARCHAR2,
      p_CITY_NAME       OUT NOCOPY      VARCHAR2,
      p_ZIP_CODE        OUT NOCOPY      VARCHAR2,
      p_bb_id           IN              NUMBER   DEFAULT 0
   );

   PROCEDURE find_existing_timecard (
      p_payroll_id            IN              NUMBER,
      p_date_worked           IN              DATE,
      p_person_id             IN              NUMBER,
      p_old_ovn               IN              NUMBER DEFAULT NULL,
      p_bb_id                 IN              NUMBER DEFAULT NULL,
      p_time_summary_id       OUT NOCOPY      NUMBER,
      p_time_sum_start_date   OUT NOCOPY      DATE,
      p_time_sum_end_date     OUT NOCOPY      DATE,
      p_tim_id                OUT NOCOPY      NUMBER
   );

   PROCEDURE transfer_to_otm (
      p_bg_id                        IN              NUMBER,
      p_incremental                  IN              VARCHAR2 DEFAULT 'Y',
      p_start_date                   IN              VARCHAR2,
      p_end_date                     IN              VARCHAR2,
      p_where_clause                 IN              VARCHAR2,
      p_transfer_to_bee              IN              VARCHAR2 DEFAULT 'N',
      p_retrieval_transaction_code   IN              VARCHAR2,
      p_batch_ref                    IN              VARCHAR2,
      p_no_otm                       IN OUT NOCOPY   VARCHAR2,
      p_unique_params                IN              VARCHAR2,
      p_since_date                   IN              VARCHAR2
   );


   -- Bug 7415291
   -- New function to check if timecard needs re-explosion
   -- in case the change is only a delete.

   FUNCTION chk_need_re_explosion (
      p_assignment_id                IN              NUMBER,
      p_date_worked                  IN              DATE,
      p_element_type_id              IN              NUMBER )
    RETURN BOOLEAN ;


END hxt_otc_retrieval_interface;

/
