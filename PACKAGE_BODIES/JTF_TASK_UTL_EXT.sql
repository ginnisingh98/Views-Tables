--------------------------------------------------------
--  DDL for Package Body JTF_TASK_UTL_EXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TASK_UTL_EXT" AS
/* $Header: jtfptkxb.pls 120.2 2005/12/21 07:04:41 sbarat ship $ */

    G_CD    VARCHAR2(30) := 'CREATION_DATE';
    G_SS    VARCHAR2(30) := 'SCHEDULED_START';
    G_SE    VARCHAR2(30) := 'SCHEDULED_END';
    G_PS    VARCHAR2(30) := 'PLANNED_START';
    G_PE    VARCHAR2(30) := 'PLANNED_END';
    G_AS    VARCHAR2(30) := 'ACTUAL_START';
    G_AE    VARCHAR2(30) := 'ACTUAL_END';


    FUNCTION adjust_date(p_original_date in date, p_adjustment_time in number, p_adjustment_time_uom in varchar2)
    return DATE
    is
      l_adjustment_time  number;
      l_base_uom_code varchar2(30);
    begin

    -- Return the original date if there is no adjustment time or if there is no adjustment time UOM specified.
    if  (p_adjustment_time is null or p_adjustment_time = 0 or p_adjustment_time_uom is null or p_original_date is null)
    then
      return p_original_date;
    end if;

    -- Get default inventory code, which is always hours
    select uom_code into l_base_uom_code from mtl_units_of_measure
    where base_uom_flag = 'Y' and uom_class = fnd_profile.value('JTF_TIME_UOM_CLASS');
    -- Get the adjustment time

    if  (p_adjustment_time_uom = l_base_uom_code)
    then
       l_adjustment_time  := p_adjustment_time;
    else
       l_adjustment_time  :=  inv_convert.inv_um_convert( item_id   => null,
                                                          precision => 2,
                                                          from_quantity => p_adjustment_time,
                                                          from_unit => p_adjustment_time_uom,
                                                          to_unit   => l_base_uom_code,
                                                          from_name => null,
                                                          to_name   => null);
    end if;

      -- return the converted adjusted date
      return p_original_date + l_adjustment_time/24;
    end;


    -- Get the booking start date
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
    ) RETURN DATE
    IS
      l_start_date DATE;
    BEGIN
        -- Populate the booking dates by using actual dates from the assignment
        IF (p_actual_start_date IS NULL) OR
           (p_actual_start_date > p_actual_end_date) OR
           (p_actual_end_date IS NULL AND
            NVL(p_actual_effort, NVL(p_planned_effort, -1)) < 0)
        THEN
            -- Populate the booking dates by using calendar dates from the task
            IF (p_calendar_start_date IS NULL) OR
               (p_calendar_start_date > p_calendar_end_date) OR
               (p_calendar_end_date IS NULL AND NVL(p_planned_effort, -1) < 0)
            THEN
               RETURN NULL;
            END IF;
            l_start_date := p_calendar_start_date;
        ELSE
            l_start_date := p_actual_start_date;
        END IF;

        IF NVL(p_actual_travel_duration, 0) > 0
        THEN
            l_start_date := jtf_task_utl_ext.adjust_date(
                            p_actual_start_date,
                            p_actual_travel_duration * (-1),
                            p_actual_travel_duration_uom);
        END IF;

        RETURN l_start_date;
    END get_bsd;


    -- Get the booking end date
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
    ) RETURN DATE
    IS
      l_end_date DATE;
    BEGIN
        -- Populate the booking date by using actual dates from the assignment
        IF (p_actual_start_date IS NULL) OR
           (p_actual_start_date > p_actual_end_date) OR
           (p_actual_end_date IS NULL AND
            NVL(p_actual_effort, NVL(p_planned_effort, -1)) < 0)
        THEN
            -- Populate the booking dates by using calendar dates from the task
            IF (p_calendar_start_date IS NULL) OR
               (p_calendar_start_date > p_calendar_end_date) OR
               (p_calendar_end_date IS NULL AND NVL(p_planned_effort, -1) < 0)
            THEN
                l_end_date := NULL;
            ELSIF (p_calendar_start_date <= p_calendar_end_date)
            THEN
                l_end_date := p_calendar_end_date;
            ELSE
                l_end_date := jtf_task_utl_ext.adjust_date
                              (p_calendar_start_date,
                               p_planned_effort,
                               p_planned_effort_uom
                              );
            END IF;
        ELSE
            IF  p_actual_start_date <= p_actual_end_date
            THEN
                l_end_date   := p_actual_end_date;
            ELSIF p_actual_effort >= 0
            THEN
                l_end_date := jtf_task_utl_ext.adjust_date
                              (p_actual_start_date,
                               p_actual_effort,
                               p_actual_effort_uom
                              );
            ELSE
                l_end_date := jtf_task_utl_ext.adjust_date
                              (p_actual_start_date,
                               p_planned_effort,
                               p_planned_effort_uom
                              );
            END IF;
        END IF;

        RETURN l_end_date;

    END get_bed;



    ------------------------------------------------------
    -- For enhancement 2666995
    FUNCTION get_open_flag (p_task_status_id IN NUMBER)
    RETURN VARCHAR2
    IS
        CURSOR c_status IS
        SELECT NVL(completed_flag,'N') completed_flag,
               NVL(cancelled_flag,'N') cancelled_flag,
               NVL(rejected_flag,'N') rejected_flag,
               NVL(closed_flag,'N') closed_flag
          FROM jtf_task_statuses_b
         WHERE task_status_id = p_task_status_id;

        rec_status c_status%ROWTYPE;
        l_open_flag VARCHAR2(1) := jtf_task_utl.g_yes;
    BEGIN
        OPEN c_status;
        FETCH c_status INTO rec_status;

        IF c_status%NOTFOUND
        THEN
            CLOSE c_status;
            fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_STATUS_ID');
            fnd_message.set_token ('P_TASK_STATUS_ID', p_task_status_id);
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;
        CLOSE c_status;

        IF rec_status.completed_flag = jtf_task_utl.g_yes OR
           rec_status.cancelled_flag = jtf_task_utl.g_yes OR
           rec_status.rejected_flag  = jtf_task_utl.g_yes OR
           rec_status.closed_flag    = jtf_task_utl.g_yes
        THEN
            l_open_flag := jtf_task_utl.g_no;
        END IF;

        RETURN l_open_flag;
    END get_open_flag;
    ------------------------------------------------------

    ------------------------------------------------------
    -- For enhancement 2683868

   -- Moved from jtf_task_utl
   PROCEDURE set_calendar_dates (
     p_show_on_calendar in varchar2,
     p_date_selected in varchar2,
     p_planned_start_date in date,
     p_planned_end_date in date,
     p_scheduled_start_date in date,
     p_scheduled_end_date in date,
     p_actual_start_date in date,
     p_actual_end_date in date,
     x_show_on_calendar IN OUT NOCOPY varchar2,-- Fixed from OUT to IN OUT
     x_date_selected IN OUT NOCOPY varchar2,-- Fixed from OUT to IN OUT
     x_calendar_start_date OUT NOCOPY date,
     x_calendar_end_date OUT NOCOPY date,
     x_return_status OUT NOCOPY varchar2,
     p_task_status_id IN NUMBER, -- Enhancement 2683868: new parameter
     p_creation_date IN DATE     -- Enhancement 2683868: new parameter
   )
   is

   -- Fix for bug 2932012
   --cursor c_date_selected is
   --select decode(fnd_profile.value('JTF_TASK_DEFAULT_DATE_SELECTED'),
   --      'PLANNED', 'P',
   --      'SCHEDULED', 'S',
   --      'ACTUAL', 'A',
   --      'S')
   --  from dual;

   l_date_selected  varchar2(1);
   l_cal_start_date date;
   l_cal_end_date   date;
   l_show_2day      varchar2(1);
   l_date_profile   varchar2(30) := fnd_profile.value('JTF_TASK_DEFAULT_DATE_SELECTED');

   begin
      x_return_status := fnd_api.g_ret_sts_success;

   -- get the default date_selected value from the profile
   -- if not set, assume 'S'

      ------------------------------------------------
      -- Fixed bug 2629463:
      --  Only when date_selected is not passed,
      --  then get the value from the profile.
      ------------------------------------------------
      IF p_date_selected IS NULL OR
         p_date_selected = fnd_api.g_miss_char
      THEN
          -- Fix for bug 2932012
		  --open c_date_selected;
          --fetch c_date_selected into l_date_selected;
          --if c_date_selected%NOTFOUND then
          --   close c_date_selected;
          --   raise fnd_api.g_exc_unexpected_error;
          --end if;
          --close c_date_selected;
           IF (l_date_profile = 'PLANNED')
           THEN
   	          l_date_selected := 'P';
		   ELSIF(l_date_profile = 'SCHEDULED')
		   THEN
		      l_date_selected := 'S';
		   ELSIF(l_date_profile = 'ACTUAL')
		   THEN
		      l_date_selected := 'A';
		   ELSE
		      l_date_selected := 'S';
		   END IF;

      ELSE
          l_date_selected := p_date_selected;
      END IF;
      ------------------------------------------------

   -- set up the dates to be used, according to the date selected

      if l_date_selected = 'P' then
     l_cal_start_date := p_planned_start_date;
     l_cal_end_date := p_planned_end_date;
      elsif
     l_date_selected = 'S' then
     l_cal_start_date := p_scheduled_start_date;
     l_cal_end_date := p_scheduled_end_date;
      elsif
     l_date_selected = 'A' then
     l_cal_start_date := p_actual_start_date;
     l_cal_end_date := p_actual_end_date;
      ----------------------------------------
      -- Enhancement 2683868
      elsif l_date_selected = 'D'
      then
         set_start_n_due_date (
            p_task_status_id        => p_task_status_id,
            p_planned_start_date    => p_planned_start_date,
            p_planned_end_date      => p_planned_end_date,
            p_scheduled_start_date  => p_scheduled_start_date,
            p_scheduled_end_date    => p_scheduled_end_date,
            p_actual_start_date     => p_actual_start_date,
            p_actual_end_date       => p_actual_end_date,
            p_creation_date         => p_creation_date,
            x_calendar_start_date   => l_cal_start_date,
            x_calendar_end_date     => l_cal_end_date,
            x_return_status         => x_return_status);

         IF NOT (x_return_status = fnd_api.g_ret_sts_success)
         THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      ----------------------------------------
      end if;

   -- set the default return values

      x_show_on_calendar := 'Y';
      x_date_selected := l_date_selected; -- For fix bug 2467890: always store date_selected
      x_calendar_start_date := l_cal_start_date; -- For fix bug 2629463: Determine the calendar dates
      x_calendar_end_date := l_cal_end_date; -- For fix bug 2629463: Determine the calendar dates

      --------------------------------------------------------------------------------
      -- For Fix bug 2467890, 2629463:
      -- At this stage, decide show_on_calendar flag only
      -- Hence removed the assignment statement for date_selected AND calendar dates
      --------------------------------------------------------------------------------
      if (p_show_on_calendar is null or p_show_on_calendar = fnd_api.g_miss_char)
      then
         if l_cal_start_date is not null and
            l_cal_end_date is not null
         then
             if (p_date_selected is null or p_date_selected = fnd_api.g_miss_char)
             then
                 x_show_on_calendar := 'Y';
             else
                 x_show_on_calendar := p_show_on_calendar;
             end if;
         ------------------------------------------------------
         -- For fix bug 2467890, 2926463
         elsif l_cal_start_date is null and
               l_cal_end_date is null
         then
             x_show_on_calendar := 'N';
             --------------------------------------------------------------------------------
             -- Before the fix of the bug 2629463,
             -- During creation of task, this api defaulted date_selected as NULL.
             -- And if the profile value is changed, the changed profile value was affecting
             -- the decision for calendar start date and end date during update of the task.
             -- To follow the same functionality, store date_selected as NULL if calendar dates
             -- have not been decided on before.
             --------------------------------------------------------------------------------
             -- Bug 2962576: If the p_date_selected is 'D',
             -- then always store 'D' for date_selected
             IF x_date_selected <> 'D' THEN
                 x_date_selected := NULL;
             END IF;
         ------------------------------------------------------
         end if;
      else
         x_show_on_calendar := p_show_on_calendar;
      end if;

   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;

      WHEN OTHERS
      THEN
         fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
         fnd_msg_pub.add;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
   end;

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
    )
    IS
        CURSOR c_status IS
        SELECT start_date_type
             , end_date_type
          FROM jtf_task_statuses_b
         WHERE task_status_id = p_task_status_id;

        rec_status c_status%ROWTYPE;

       -- Added by SBARAT on 21/12/2005 for bug# 4616119
       l_date_profile   varchar2(30) := fnd_profile.value('JTF_TASK_DEFAULT_DATE_SELECTED');

    BEGIN
        x_return_status := fnd_api.g_ret_sts_success;

        ---------------------------------------------------
        -- Get status information
        OPEN c_status;
        FETCH c_status INTO rec_status;

        IF c_status%NOTFOUND
        THEN
            CLOSE c_status;
            fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_STATUS_ID');
            fnd_message.set_token ('P_TASK_STATUS_ID', p_task_status_id);
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;
        CLOSE c_status;

        IF rec_status.start_date_type IS NULL OR
           rec_status.end_date_type   IS NULL
        THEN
    /************** Start of addition by SBARAT on 21/12/2005 for bug# 4616119 **************/
            IF l_date_profile IS NOT NULL
            THEN
                IF (l_date_profile = 'PLANNED')
                THEN
                    x_calendar_start_date := p_planned_start_date;
                    x_calendar_end_date   := p_planned_end_date;
                ELSIF(l_date_profile = 'SCHEDULED')
                THEN
                    x_calendar_start_date := p_scheduled_start_date;
                    x_calendar_end_date   := p_scheduled_end_date;
                ELSIF(l_date_profile = 'ACTUAL')
                THEN
                    x_calendar_start_date := p_actual_start_date;
                    x_calendar_end_date   := p_actual_end_date;
                ELSE
                    x_calendar_start_date := NULL;
                    x_calendar_end_date   := NULL;
                END IF;
            ELSE
                x_calendar_start_date := p_scheduled_start_date;
                x_calendar_end_date   := p_scheduled_end_date;
            END IF;
    /************** End of addition by SBARAT on 21/12/2005 for bug# 4616119 **************/
            RETURN;
        END IF;

        ---------------------------------------------
        -- Determine calendar start date
        IF rec_status.start_date_type = G_CD -- Creation Date
        THEN
            x_calendar_start_date := p_creation_date;

        ELSIF rec_status.start_date_type = G_PS -- Planned Start Date
        THEN
            IF p_planned_start_date IS NULL
            THEN
                -- If date type is deriven by planned start date and its value is null
                -- then throw an error "The planned start date must be provided."
                fnd_message.set_name ('JTF', 'JTF_TASK_NULL_PLANNED_ST_DATE');
                fnd_msg_pub.add;
                x_return_status := fnd_api.g_ret_sts_unexp_error;
            END IF;

            x_calendar_start_date := p_planned_start_date;

        ELSIF rec_status.start_date_type = G_SS -- Scheduled Start Date
        THEN
            IF p_scheduled_start_date IS NULL
            THEN
                -- If date type is deriven by schedule start date and its value is null,
                -- then throw an error "The scheduled start date must be provided."
                fnd_message.set_name ('JTF', 'JTF_TASK_NULL_SCHEDULE_ST_DATE');
                fnd_msg_pub.add;
                x_return_status := fnd_api.g_ret_sts_unexp_error;
            END IF;

            x_calendar_start_date := p_scheduled_start_date;

        ELSIF rec_status.start_date_type = G_AS -- Actual Start Date
        THEN
            IF p_actual_start_date IS NULL
            THEN
                -- If date type is deriven by actual start date and its value is null
                -- then throw an error "The actual start date must be provided."
                fnd_message.set_name ('JTF', 'JTF_TASK_NULL_ACTUAL_ST_DATE');
                fnd_msg_pub.add;
                x_return_status := fnd_api.g_ret_sts_unexp_error;
            END IF;

            x_calendar_start_date := p_actual_start_date;
        END IF;

        ---------------------------------------------
        -- Determine calendar end date
        IF rec_status.end_date_type = G_CD -- Creation Date
        THEN
            x_calendar_end_date := p_creation_date;

        ELSIF rec_status.end_date_type = G_PE -- Planned End Date
        THEN
            IF p_planned_end_date IS NULL
            THEN
                -- If date type is deriven by planned end date and its value is null
                -- then throw an error "The planned end date must be provided."
                fnd_message.set_name ('JTF', 'JTF_TASK_NULL_PLANNED_EN_DATE');
                fnd_msg_pub.add;
                x_return_status := fnd_api.g_ret_sts_unexp_error;
            END IF;

            x_calendar_end_date := p_planned_end_date;

        ELSIF rec_status.end_date_type = G_SE -- Scheduled End Date
        THEN
            IF p_scheduled_end_date IS NULL
            THEN
                -- If date type is deriven by schedule end date and its value is null,
                -- then throw an error "The scheduled end date must be provided."
                fnd_message.set_name ('JTF', 'JTF_TASK_NULL_SCHEDULE_EN_DATE');
                fnd_msg_pub.add;
                x_return_status := fnd_api.g_ret_sts_unexp_error;
            END IF;

            x_calendar_end_date := p_scheduled_end_date;

        ELSIF rec_status.end_date_type = G_AE -- Actual End Date
        THEN
            IF p_actual_end_date IS NULL
            THEN
                -- If date type is deriven by actual end date and its value is null
                -- then throw an error "The actual end date must be provided."
                fnd_message.set_name ('JTF', 'JTF_TASK_NULL_ACTUAL_EN_DATE');
                fnd_msg_pub.add;
                x_return_status := fnd_api.g_ret_sts_unexp_error;
            END IF;

            x_calendar_end_date := p_actual_end_date;
        END IF;

        IF x_return_status = fnd_api.g_ret_sts_unexp_error
        THEN
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

    EXCEPTION
        WHEN fnd_api.g_exc_unexpected_error THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;

        WHEN OTHERS THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
            fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
            fnd_msg_pub.add;
    END set_start_n_due_date;

    ------------------------------------------------------
    -- For enhancement 2734020
    ------------------------------------------------------
    FUNCTION get_last_number(p_sequence_name IN VARCHAR2)
    RETURN NUMBER
    IS
      l_return_status BOOLEAN;
      l_status        VARCHAR2(1);
      l_oracle_schema VARCHAR2(30);
      l_industry      VARCHAR2(1);

      CURSOR c_seq IS
        SELECT last_number
          FROM all_sequences
         WHERE sequence_name = p_sequence_name
           AND sequence_owner = l_oracle_schema;

      rec_seq c_seq%ROWTYPE;
    BEGIN
      l_return_status := FND_INSTALLATION.GET_APP_INFO(
         application_short_name => 'JTF',
         status                 => l_status,
         industry               => l_industry,
         oracle_schema          => l_oracle_schema);

      if (NOT l_return_status) or (l_oracle_schema IS NULL)
      then
        -- defaulted to the JTF
        l_oracle_schema := 'JTF';
      end if;

      OPEN c_seq;
      FETCH c_seq INTO rec_seq;

      IF c_seq%NOTFOUND
      THEN
            CLOSE c_seq;
            fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_SEQ');
            fnd_message.set_token ('P_SEQ', p_sequence_name);
            fnd_msg_pub.add;
            raise fnd_api.g_exc_unexpected_error;
        END IF;
        CLOSE c_seq;

        RETURN rec_seq.last_number;
    END get_last_number;

-----------
------------- For Bug 2786689 (CYCLIC TASK) ..
-----------
PROCEDURE validate_cyclic_task (
   p_task_id              IN              NUMBER,
   p_parent_task_id       IN              NUMBER,
   x_return_status        OUT NOCOPY      VARCHAR2
)
IS
   CURSOR c_cyclic_task
   IS
     SELECT  task_id , parent_task_id , level
     FROM jtf_tasks_b
     START WITH  task_id = p_task_id
     CONNECT BY PRIOR task_id = parent_task_id ;

   cyclic_task_rec   c_cyclic_task%ROWTYPE;
BEGIN
   x_return_status := fnd_api.g_ret_sts_success;

   IF (p_parent_task_id IS NOT NULL)
   THEN
      FOR cyclic_task_rec IN c_cyclic_task
      LOOP
         IF (p_parent_task_id = cyclic_task_rec.task_id)
         THEN
             x_return_status := fnd_api.g_ret_sts_unexp_error;
             fnd_message.set_name ('JTF', 'JTF_TASK_CYCLIC_TASKS');
             fnd_message.set_token ('P_TASK_NAME', jtf_task_utl_ext.get_task_name(p_task_id));
             fnd_message.set_token ('P_PARENT_TASK_NAME', jtf_task_utl_ext.get_task_name(p_parent_task_id));
             fnd_msg_pub.add;
         END IF;
      END LOOP;

   END IF;
END;

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
    )
    IS
        CURSOR c_ref (b_task_id jtf_tasks_b.task_id%type,
                      b_source_id hz_parties.party_id%type) IS
        SELECT task_reference_id, object_version_number
          FROM jtf_task_references_b
         WHERE task_id = b_task_id
           AND object_id = b_source_id;

        l_task_ref_id        NUMBER;
        l_obj_version_number NUMBER;
    BEGIN
        x_return_status := fnd_api.g_ret_sts_success;

        IF p_old_object_code NOT IN ('TASK', 'APPOINTMENT')
        THEN
            IF (NVL(p_new_object_id, 0) <> fnd_api.g_miss_num AND
                NVL(p_new_object_id, 0) <> NVL(p_old_object_id, 0))
            THEN
                -----------------------------
                -- Delete the old reference
                -----------------------------
                IF p_old_object_code IN ('PARTY')
                THEN
                    -- delete the old one
                    jtf_task_utl.delete_party_reference(
                        p_reference_from => 'TASK',
                        p_task_id        => p_task_id,
                        p_party_id       => p_old_object_id,
                        x_msg_count      => x_msg_count,
                        x_msg_data       => x_msg_data,
                        x_return_status  => x_return_status
                    );
                    IF NOT (x_return_status = fnd_api.g_ret_sts_success)
                    THEN
                        RAISE fnd_api.g_exc_unexpected_error;
                    END IF;
                ELSE  -- other than party Relation, Person, Organization 2102281
                    OPEN c_ref (p_task_id, p_old_object_id);
                    FETCH c_ref INTO l_task_ref_id, l_obj_version_number;
                    CLOSE c_ref;

                    jtf_task_utl.g_show_error_for_dup_reference := FALSE;

                    jtf_task_references_pub.delete_references (
                        p_api_version           => 1.0,
                        p_init_msg_list         => fnd_api.g_false,
                        p_commit                => fnd_api.g_false,
                        p_object_version_number => l_obj_version_number,
                        p_task_reference_id     => l_task_ref_id,
                        x_return_status         => x_return_status,
                        x_msg_count             => x_msg_count,
                        x_msg_data              => x_msg_data
                    );

                    IF NOT (x_return_status = fnd_api.g_ret_sts_success)
                    THEN
                        RAISE fnd_api.g_exc_unexpected_error;
                    END IF;
                END IF;
            END IF;
        END IF;

        IF p_new_object_code NOT IN ('TASK', 'APPOINTMENT')
        THEN
            --------------------------
            -- Create a new reference
            --------------------------
            IF (NVL(p_new_object_id, 0) <> fnd_api.g_miss_num AND
                NVL(p_new_object_id, 0) <> NVL(p_old_object_id, 0))
            THEN
                IF p_new_object_code IN ('PARTY')
                THEN
                   -- create a new one
                   jtf_task_utl.create_party_reference(
                       p_reference_from => 'TASK',
                       p_task_id        => p_task_id,
                       p_party_id       => p_new_object_id,
                       x_msg_count      => x_msg_count,
                       x_msg_data       => x_msg_data,
                       x_return_status  => x_return_status
                   );

                   IF NOT (x_return_status = fnd_api.g_ret_sts_success)
                   THEN
                      RAISE fnd_api.g_exc_unexpected_error;
                   END IF;
                ELSE  -- other than party Relation, Person, Organization 2102281
                    jtf_task_utl.g_show_error_for_dup_reference := False;

                    jtf_task_references_pvt.create_references (
                        p_api_version       => 1.0,
                        p_init_msg_list     => fnd_api.g_false,
                        p_commit            => fnd_api.g_false,
                        p_task_id           => p_task_id,
                        p_object_type_code  => p_new_object_code,
                        p_object_name       => p_new_object_name,
                        p_object_id         => p_new_object_id,
                        x_return_status     => x_return_status,
                        x_msg_count         => x_msg_count,
                        x_msg_data          => x_msg_data,
                        x_task_reference_id => l_task_ref_id
                    );

                    IF NOT (x_return_status = fnd_api.g_ret_sts_success)
                    THEN
                       RAISE fnd_api.g_exc_unexpected_error;
                    END IF;
                END IF;
            END IF;
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
    END update_object_code;

    -- For Fix Bug 2896532
    FUNCTION get_object_details (p_object_code IN VARCHAR2
                                ,p_object_id   IN NUMBER)
    RETURN VARCHAR2
    IS
        CURSOR c_object IS
        SELECT select_id, select_details, from_table, where_clause
          FROM jtf_objects_b
         WHERE object_code = p_object_code;

        l_id_column      jtf_objects_b.select_id%TYPE;
        l_detail_column  jtf_objects_b.select_details%TYPE;
        l_from_clause    jtf_objects_b.from_table%TYPE;
        l_where_clause   jtf_objects_b.where_clause%TYPE;

        l_object_details VARCHAR2(2000);
        sql_stmt         VARCHAR2(2000);
   BEGIN
        OPEN c_object;
        FETCH c_object
         INTO l_id_column
            , l_detail_column
            , l_from_clause
            , l_where_clause;

        IF c_object%NOTFOUND
        THEN
            CLOSE c_object;
            fnd_message.set_name ('JTF', 'JTF_TASK_INVALID_OBJECT_CODE');
            fnd_message.set_token ('P_OBJECT_CODE', p_object_code);
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;
        CLOSE c_object;

        IF l_detail_column IS NOT NULL
        THEN
           -- SELECT DECODE (l_where_clause, NULL, '  ', l_where_clause || ' AND ')
           --   INTO l_where_clause
           --   FROM dual;

            -- Fix for bug 2932012
			IF (l_where_clause IS NULL)
			THEN
			   l_where_clause := '  ';
			ELSE
			   l_where_clause := l_where_clause || ' AND ';
			END IF;

            sql_stmt := ' SELECT ' || l_detail_column ||
                          ' FROM ' || l_from_clause   ||
                        '  WHERE ' || l_where_clause  ||
                        l_id_column ||' = :object_id ';

            EXECUTE IMMEDIATE sql_stmt
               INTO l_object_details
              USING p_object_id;
        END IF;

        RETURN l_object_details;

   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error THEN
          RETURN NULL;

      WHEN NO_DATA_FOUND THEN
          RETURN NULL;

      WHEN OTHERS THEN
          RETURN NULL;

    END get_object_details;

--Bug 2786689
   FUNCTION get_task_name (p_task_id IN NUMBER)
      RETURN VARCHAR2
   AS
      l_task_name   jtf_tasks_vl.task_name%TYPE;
   BEGIN
      IF p_task_id IS NULL
      THEN
     RETURN NULL;
      ELSE
     SELECT task_name
       INTO l_task_name
       FROM jtf_tasks_vl
      WHERE task_id = p_task_id;
      END IF;

      RETURN l_task_name;
   EXCEPTION
      WHEN OTHERS
      THEN
     RETURN NULL;
   END get_task_name;

/*
   Function added for bug #3360228 - extended from
   jtf_task_utl.check_duplicate_reference.
*/
   FUNCTION check_dup_reference_for_update (
             p_task_reference_id jtf_task_references_b.task_reference_id%type,
             p_task_id jtf_tasks_b.task_id%type,
             p_object_id hz_relationships.object_id%type,
             p_object_type_code jtf_task_references_b.object_type_code%type)
     return boolean
   is

   x_count NUMBER := 0;
   x_return_value boolean := true;

   begin

     /*
       If a reference is existing with the same task_refernce_id,
       it shouldn't be treated as a duplicate when validating for
       update. Added task_reference_id to the whereclause for
       eliminate itself.
      */

     select count(object_id)
     INTO x_count
       FROM JTF_TASK_REFERENCES_b
       WHERE task_reference_id  <> p_task_reference_id
       AND task_id = p_task_id
       AND object_id = p_object_id
       AND object_type_code = p_object_type_code
       AND rownum = 1;

     if x_count > 0 then
       x_return_value := false;
     else
       x_return_value := true;
     end if;

     return x_return_value;

   end check_dup_reference_for_update;

END jtf_task_utl_ext;

/
