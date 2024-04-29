--------------------------------------------------------
--  DDL for Package Body PQP_GB_PENSION_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_GB_PENSION_FUNCTIONS" 
--  /* $Header: pqpgbpef.pkb 120.3.12010000.2 2008/09/23 08:36:22 namgoyal ship $ */
AS

--
   -- Global Variables
   g_tab_pension_types_info   t_pension_types;
   g_tab_element_types_info   t_element_types;


-- ----------------------------------------------------------------------------
-- |--------------------------------< debug >---------------------------------|
-- ----------------------------------------------------------------------------

   PROCEDURE DEBUG (p_trace_message IN VARCHAR2, p_trace_location IN NUMBER)
   IS

--
   BEGIN
      --

      pqp_utilities.DEBUG (
         p_trace_message               => p_trace_message
        ,p_trace_location              => p_trace_location
      );
   --
   END DEBUG;


--
-- ----------------------------------------------------------------------------
-- |--------------------------------< debug >---------------------------------|
-- ----------------------------------------------------------------------------

   PROCEDURE DEBUG (p_trace_number IN NUMBER)
   IS

--
   BEGIN
      --
      DEBUG (fnd_number.number_to_canonical (p_trace_number));
   --

   END DEBUG;


--
-- ----------------------------------------------------------------------------
-- |--------------------------------< debug >---------------------------------|
-- ----------------------------------------------------------------------------

   PROCEDURE DEBUG (p_trace_date IN DATE)
   IS

--
   BEGIN
      --
      DEBUG (fnd_date.date_to_canonical (p_trace_date));
   --

   END DEBUG;


-- This procedure is used for debug purposes
-- debug_enter checks the debug flag and sets the trace on/off
--
-- ----------------------------------------------------------------------------
-- |----------------------------< debug_enter >-------------------------------|
-- ----------------------------------------------------------------------------

   PROCEDURE debug_enter (p_proc_name IN VARCHAR2, p_trace_on IN VARCHAR2)
   IS
   BEGIN
      --
      pqp_utilities.debug_enter (
         p_proc_name                   => p_proc_name
        ,p_trace_on                    => p_trace_on
      );
   --
   END debug_enter;


-- This procedure is used for debug purposes
--
-- ----------------------------------------------------------------------------
-- |----------------------------< debug_exit >--------------------------------|
-- ----------------------------------------------------------------------------

   PROCEDURE debug_exit (p_proc_name IN VARCHAR2, p_trace_off IN VARCHAR2)
   IS
   BEGIN
      --
      pqp_utilities.debug_exit (
         p_proc_name                   => p_proc_name
        ,p_trace_off                   => p_trace_off
      );
   --
   END debug_exit;


-- This procedure is used for debug purposes
--
-- ----------------------------------------------------------------------------
-- |----------------------------< debug_others >--------------------------------|
-- ----------------------------------------------------------------------------

   PROCEDURE debug_others (p_proc_name IN VARCHAR2, p_proc_step IN NUMBER)
   IS
   BEGIN
      --
      pqp_utilities.debug_others (
         p_proc_name                   => p_proc_name
        ,p_proc_step                   => p_proc_step
      );
   --
   END debug_others;


-- This function populates element entry id's in a collection
-- and returns it


-- This procedure is used to identify whether an employee is a member
-- of any other pension scheme for a given pension category
--
--
-- ----------------------------------------------------------------------------
-- |----------------------------< get_element_types_info >--------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_element_types_info (
      p_assignment_id     IN   NUMBER
     ,p_element_type_id   IN   NUMBER
     ,p_effective_date    IN   DATE
   )
      RETURN t_number
   IS
      --
      l_proc_name           VARCHAR2 (80)
                                  :=    g_proc_name
                                     || 'get_element_types_info';
      l_ele_entry_id        NUMBER;
      l_ele_type_id         NUMBER;
      l_tab_ele_type_info   t_number;
      l_proc_step           NUMBER;

--
   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step                := 10;
         DEBUG (   'Entering: '
                || l_proc_name, l_proc_step);
      END IF;

      -- Get the element link id for this assignment
      IF g_debug
      THEN
         DEBUG (   'Assignment ID: '
                || TO_CHAR (p_assignment_id));
         DEBUG (   'Element Type ID: '
                || TO_CHAR (p_element_type_id));
      END IF;

      OPEN csr_get_ele_entry_info (
         p_assignment_id
        ,p_element_type_id
        ,p_effective_date
      );

      LOOP
         FETCH csr_get_ele_entry_info INTO l_ele_entry_id;
         EXIT WHEN csr_get_ele_entry_info%NOTFOUND;

         IF g_debug
         THEN
            DEBUG (   'Element Link ID: '
                   || TO_CHAR (l_ele_entry_id));
         END IF;

         -- Get the element type id for this link id
         IF g_debug
         THEN
            l_proc_step                := 20;
            DEBUG (l_proc_name, l_proc_step);
         END IF;

         OPEN csr_get_ele_type_id (l_ele_entry_id, p_effective_date);
         FETCH csr_get_ele_type_id INTO l_ele_type_id;

         IF g_debug
         THEN
            DEBUG (   'Element Type ID: '
                   || TO_CHAR (l_ele_type_id));
         END IF;

         -- No need to check for row existence, as this is done
         -- in the first cursor
         l_tab_ele_type_info (l_ele_type_id) := l_ele_type_id;
         CLOSE csr_get_ele_type_id;
      END LOOP; -- End loop of ele entry ...

      CLOSE csr_get_ele_entry_info;

      IF g_debug
      THEN
         l_proc_step                := 30;
         DEBUG (   'Leaving: '
                || l_proc_name, l_proc_step);
      END IF;

      RETURN l_tab_ele_type_info;
   --
   END;


-- ----------------------------------------------------------------------------
-- |----------------------------< get_ele_type_from_link >--------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_ele_type_from_link (
      p_element_link_id   IN   NUMBER
     ,p_effective_date    IN   DATE
   )
      RETURN NUMBER
   IS
      --
      l_proc_name         VARCHAR2 (80)
                                  :=    g_proc_name
                                     || 'get_ele_type_from_link';
      l_proc_step         NUMBER;
      l_element_type_id   NUMBER;
   --
   BEGIN
      --
      IF g_debug
      THEN
         DEBUG (   'Entering: '
                || l_proc_name, l_proc_step);
      END IF;

      --
      OPEN csr_get_ele_type_id (p_element_link_id, p_effective_date);
      FETCH csr_get_ele_type_id INTO l_element_type_id;
      CLOSE csr_get_ele_type_id;

      IF g_debug
      THEN
         DEBUG (   'Element Type ID: '
                || TO_CHAR (l_element_type_id));
         l_proc_step                := 20;
         DEBUG (   'Leaving: '
                || l_proc_name, l_proc_step);
      END IF;

      --
      RETURN l_element_type_id;
   --
   END get_ele_type_from_link;

   --

-- ----------------------------------------------------------------------------
-- |----------------------------< get_ele_link_info >-------------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_ele_link_info (
      p_element_type_id     IN   NUMBER
     ,p_business_group_id   IN   NUMBER
     ,p_effective_date      IN   DATE
   )
      RETURN NUMBER
   IS
      --
      l_proc_name         VARCHAR2 (80)
                                       :=    g_proc_name
                                          || 'get_ele_link_info';
      l_proc_step         NUMBER;
      l_element_link_id   NUMBER;
   --
   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step                := 10;
         DEBUG (   'Entering: '
                || l_proc_name, l_proc_step);
      END IF;

      --
      OPEN csr_get_ele_link_id (
         p_element_type_id
        ,p_business_group_id
        ,p_effective_date
      );
      FETCH csr_get_ele_link_id INTO l_element_link_id;
      CLOSE csr_get_ele_link_id;

      IF g_debug
      THEN
         DEBUG (   'Element link ID: '
                || TO_CHAR (l_element_link_id));
         l_proc_step                := 20;
         DEBUG (   'Leaving: '
                || l_proc_name, l_proc_step);
      END IF;

      --
      RETURN l_element_link_id;
   --
   END get_ele_link_info;


-- ----------------------------------------------------------------------------
-- |----------------------------< get_element_name >--------------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_element_name (
      p_element_type_id   IN   NUMBER
     ,p_effective_date    IN   DATE
   )
      RETURN NUMBER
   IS
      --
      l_proc_name      VARCHAR2 (80)          :=    g_proc_name
                                                 || 'get_element_name';
      l_proc_step      NUMBER;
      l_element_name   pay_element_types_f.element_name%TYPE;
   --
   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step                := 10;
         DEBUG (   'Entering: '
                || l_proc_name, l_proc_step);
      END IF;

      --
      OPEN csr_get_ele_name (p_element_type_id, p_effective_date);
      FETCH csr_get_ele_name INTO l_element_name;
      CLOSE csr_get_ele_name;

      IF g_debug
      THEN
         DEBUG (   'Element Name: '
                || l_element_name);
         l_proc_step                := 20;
         DEBUG (   'Leaving: '
                || l_proc_name, l_proc_step);
      END IF;

      --
      RETURN l_element_name;
   --
   END get_element_name;


-- ----------------------------------------------------------------------------
-- |----------------------------< chk_multiple_membership >-------------------|
-- ----------------------------------------------------------------------------

   FUNCTION chk_multiple_membership (
      p_assignment_id      IN              NUMBER
     , -- Context
      p_element_type_id    IN              NUMBER
     , -- Context
      p_effective_date     IN              DATE
     , -- Context
      p_pension_category   IN              VARCHAR2
     ,p_yes_no             OUT NOCOPY      VARCHAR2
     ,p_error_msg          OUT NOCOPY      VARCHAR2
   )
      RETURN NUMBER
   IS
      --
      l_proc_name          VARCHAR2 (80)
                                 :=    g_proc_name
                                    || 'chk_multiple_membership';
      l_proc_step          NUMBER;
      l_ele_link_id        NUMBER;
      l_ele_type_id        NUMBER;
      l_exists             VARCHAR2 (1);
      l_yes_no             VARCHAR2 (1);
      l_error_msg          VARCHAR2 (1000);
      l_return             NUMBER                        := 0;
      l_pension_category   hr_lookups.lookup_code%TYPE;

    --For bug 7334468: Version 115.8
      CURSOR csr_get_sch_cate_type(c_element_type_id NUMBER)
      IS
        SELECT eei_information4, --Scheme Category
               eei_information8  --Scheme Type(COSR/COMP)
        FROM pay_element_type_extra_info
        WHERE element_type_id = c_element_type_id
        AND information_type = 'PQP_GB_PENSION_SCHEME_INFO';

        l_curr_ele_cate      VARCHAR2 (10);
        l_curr_ele_type      VARCHAR2 (10);
        l_prev_ele_cate      VARCHAR2 (10);
        l_prev_ele_type      VARCHAR2 (10);

--
   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step                := 10;
         DEBUG (   'Entering: '
                || l_proc_name, l_proc_step);
      END IF;

      l_yes_no                   := 'N';

      -- Ignore the check for 'Free Standing AVC'
      IF (p_pension_category = 'Free Standing AVC') then
         return 0;
      END IF;

      -- Get the element link id for this assignment

      IF g_debug
      THEN
         DEBUG (   'Assignment ID: '
                || TO_CHAR (p_assignment_id));
         DEBUG (   'Element Type ID: '
                || TO_CHAR (p_element_type_id));
      END IF;

      -- Get the pension category lookup code from the lookup type

      l_pension_category         :=
            pqp_utilities.get_lookup_code (
               p_lookup_type                 => 'PQP_PENSION_CATEGORY'
              ,p_lookup_meaning              => p_pension_category
              ,p_message                     => l_error_msg
            );

      IF g_debug
      THEN
         DEBUG (   'Error Message: '
                || l_error_msg);
         DEBUG (   'Pension Category Code: '
                || l_pension_category);
      END IF;

      IF l_error_msg IS NOT NULL
      THEN
         -- Error Occurred
         l_return                   := -1;
         p_error_msg                := l_error_msg;
         RETURN l_return;
      END IF; -- End if of error msg check ...

   --For bug 7334468: Version 115.8
   --Fetch current pension scheme details
     OPEN csr_get_sch_cate_type (p_element_type_id);
     FETCH csr_get_sch_cate_type INTO l_curr_ele_cate,l_curr_ele_type;
     CLOSE csr_get_sch_cate_type;

     DEBUG ('Element Type ID: '|| TO_CHAR (p_element_type_id));
     DEBUG ('l_curr_ele_cate: '||l_curr_ele_cate);
     DEBUG ('l_curr_ele_type: '||l_curr_ele_type);

      OPEN csr_get_ele_entry_info (
         p_assignment_id
        ,p_element_type_id
        ,p_effective_date
      );

      LOOP
         FETCH csr_get_ele_entry_info INTO l_ele_link_id;
         EXIT WHEN csr_get_ele_entry_info%NOTFOUND;

         IF g_debug
         THEN
            DEBUG (   'Element Link ID: '
                   || TO_CHAR (l_ele_link_id));
         END IF;

         IF g_debug
         THEN
            l_proc_step                := 20;
            DEBUG (l_proc_name, l_proc_step);
         END IF;

         -- Get the element type id for this link id
         l_ele_type_id              :=
               get_ele_type_from_link (
                  p_element_link_id             => l_ele_link_id
                 ,p_effective_date              => p_effective_date
               );

         -- Check whether the element type is of the same pension
         -- category
         IF g_debug
         THEN
            DEBUG (   'Element Type ID: '
                   || TO_CHAR (l_ele_type_id));
            DEBUG (   'YES or NO: '
                   || l_yes_no);
            DEBUG (   'Pension Category: '
                   || p_pension_category);
            l_proc_step                := 30;
            DEBUG (l_proc_name, l_proc_step);
         END IF;


         IF g_debug
         THEN
            l_proc_step                := 40;
            DEBUG (l_proc_name, l_proc_step);
         END IF;

         OPEN csr_chk_is_this_pens_ele (
            l_ele_type_id
           ,p_effective_date
           ,l_pension_category
         );
         FETCH csr_chk_is_this_pens_ele INTO l_exists;

         IF csr_chk_is_this_pens_ele%FOUND
         THEN

	   --For bug 7334468: Version 115.8
             IF l_curr_ele_cate = 'OCP'
             THEN
                  DEBUG ('Current element is OCP');

                --Fetch other pension scheme details
                  OPEN csr_get_sch_cate_type (l_ele_type_id);
                  FETCH csr_get_sch_cate_type INTO l_prev_ele_cate,l_prev_ele_type;
                  CLOSE csr_get_sch_cate_type;

	          DEBUG ( 'Element Type ID: ' || l_ele_type_id);
                  DEBUG ('l_prev_ele_cate: '||l_prev_ele_cate);
                  DEBUG ('l_prev_ele_type: '||l_prev_ele_type);

                  IF nvl(l_curr_ele_type,'BLANK') <> nvl(l_prev_ele_type,'BLANK')
                  THEN
                        DEBUG ('OCP elements are of different type');
                        CLOSE csr_chk_is_this_pens_ele;
                        l_yes_no   := 'Y';
                        EXIT;
                  END IF;
             ELSE
                 DEBUG ('Current element is not OCP');

                 CLOSE csr_chk_is_this_pens_ele;
              -- Employee is a member of another pension scheme
              --
                 l_yes_no                   := 'Y';
                 EXIT;
             END IF; --End if pension element is OCP

	 END IF; -- End if of pens element found check ...

         CLOSE csr_chk_is_this_pens_ele;
      END LOOP; -- End loop of element entry ...

      CLOSE csr_get_ele_entry_info;

      IF g_debug
      THEN
         DEBUG (   'YES or NO: '
                || l_yes_no);
         l_proc_step                := 50;
         DEBUG (   'Leaving: '
                || l_proc_name, l_proc_step);
      END IF;

      p_yes_no                   := l_yes_no;
      --

      RETURN l_return;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_yes_no                   := NULL;
         p_error_msg                := SQLERRM;

         IF SQLCODE <> hr_utility.hr_error_number
         THEN
            debug_others (l_proc_name, l_proc_step);

            IF g_debug
            THEN
               DEBUG (   'Leaving: '
                      || l_proc_name, -999);
            END IF;

            fnd_message.raise_error;
         ELSE
            RAISE;
         END IF;
   --
   END chk_multiple_membership;

   --

-- ----------------------------------------------------------------------------
-- |----------------------------< get_pension_type_info >---------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_pension_type_info (
      p_business_group_id    IN              NUMBER
     ,p_effective_date       IN              DATE
     ,p_pension_type_id      IN              NUMBER
     ,p_pens_type_info_rec   OUT NOCOPY      r_pension_types
     ,p_error_msg            OUT NOCOPY      VARCHAR2
   )
      RETURN NUMBER
   IS
      --

      l_proc_name            VARCHAR2 (80)
                                   :=    g_proc_name
                                      || 'get_pension_type_info';
      l_proc_step            NUMBER;
      l_pens_type_info_rec   csr_get_pens_type_info%ROWTYPE;
   --
   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step                := 10;
         DEBUG (   'Entering: '
                || l_proc_name, l_proc_step);
      END IF;

      -- Get the pension type information
      OPEN csr_get_pens_type_info (
         p_pension_type_id
        ,p_business_group_id
        ,p_effective_date
      );
      FETCH csr_get_pens_type_info INTO l_pens_type_info_rec;

      IF csr_get_pens_type_info%NOTFOUND
      THEN
         CLOSE csr_get_pens_type_info;
         fnd_message.set_name ('PQP', 'PQP_230934_PEN_TYPE_ID_INVALID');
         p_error_msg                := fnd_message.get;

         IF g_debug
         THEN
            l_proc_step                := 20;
            DEBUG (   'Leaving: '
                   || l_proc_name, l_proc_step);
         END IF;

         RETURN -1;
      END IF; -- End if of pension type info not found check ...

      CLOSE csr_get_pens_type_info;
      p_pens_type_info_rec.minimum_age := l_pens_type_info_rec.minimum_age;
      p_pens_type_info_rec.maximum_age := l_pens_type_info_rec.maximum_age;
      p_pens_type_info_rec.pension_type_id :=
                                          l_pens_type_info_rec.pension_type_id;
      p_pens_type_info_rec.pension_type_name :=
                                        l_pens_type_info_rec.pension_type_name;
      p_pens_type_info_rec.pension_category :=
                                         l_pens_type_info_rec.pension_category;
      p_pens_type_info_rec.effective_start_date :=
                                     l_pens_type_info_rec.effective_start_date;
      p_pens_type_info_rec.effective_end_date :=
                                       l_pens_type_info_rec.effective_end_date;

      IF g_debug
      THEN
         l_proc_step                := 30;
         DEBUG (   'Leaving: '
                || l_proc_name, l_proc_step);
      END IF;

      RETURN 0;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         p_error_msg                := SQLERRM;

         IF SQLCODE <> hr_utility.hr_error_number
         THEN
            debug_others (l_proc_name, l_proc_step);

            IF g_debug
            THEN
               DEBUG (   'Leaving: '
                      || l_proc_name, -999);
            END IF;

            fnd_message.raise_error;
         ELSE
            RAISE;
         END IF;
   END get_pension_type_info;

   --

-- ----------------------------------------------------------------------------
-- |----------------------------< get_ele_pens_type_info >--------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_ele_pens_type_info (
      p_business_group_id   IN              NUMBER
     ,p_effective_date      IN              DATE
     ,p_element_type_id     IN              NUMBER
     ,p_minimum_age         OUT NOCOPY      NUMBER
     ,p_maximum_age         OUT NOCOPY      NUMBER
     ,p_error_msg           OUT NOCOPY      VARCHAR2
   )
      RETURN NUMBER
   IS
      --

      l_proc_name                VARCHAR2 (80)
                                  :=    g_proc_name
                                     || 'get_ele_pens_type_info';
      l_proc_step                NUMBER;
      l_pens_type_info_rec       r_pension_types;
      l_return                   NUMBER;
      l_truncated_yes_no         VARCHAR2 (1);
      l_pension_type_id          NUMBER;
      l_tab_pension_types_info   t_pension_types;
   --
   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step                := 10;
         DEBUG (   'Entering: '
                || l_proc_name, l_proc_step);
      END IF;

      -- Get the pension type id from the EEIT for this
      -- element type id
      l_return                   :=
            pqp_utilities.pqp_get_extra_element_info (
               p_element_type_id             => p_element_type_id
              ,p_information_type            => 'PQP_GB_PENSION_SCHEME_INFO'
              ,p_segment_name                => 'Pension Type'
              ,p_value                       => l_pension_type_id
              ,p_truncated_yes_no            => l_truncated_yes_no
              ,p_error_msg                   => p_error_msg
            );

      IF g_debug
      THEN
         DEBUG (   'Pension Type ID: '
                || TO_CHAR (l_pension_type_id));
      END IF;

      IF l_return = -1
      THEN
         -- An error has occurred return the error message
         IF g_debug
         THEN
            l_proc_step                := 20;
            DEBUG (   'Leaving: '
                   || l_proc_name, l_proc_step);
         END IF;

         RETURN -1;
      END IF; -- End if of error occurred check ...

      IF g_debug
      THEN
         l_proc_step                := 30;
         DEBUG (l_proc_name, l_proc_step);
      END IF;

      -- Get it from cache if its already there

      l_tab_pension_types_info   := g_tab_pension_types_info;

      IF    NOT l_tab_pension_types_info.EXISTS (l_pension_type_id)
         OR -- Check the effectiveness as this is DT table
           (    l_tab_pension_types_info.EXISTS (l_pension_type_id)
            AND NOT (p_effective_date
                        BETWEEN l_tab_pension_types_info (l_pension_type_id).effective_start_date
                            AND l_tab_pension_types_info (l_pension_type_id).effective_end_date
                    )
           )
      THEN
         -- Call other function to get the pension type information
         l_return                   :=
               get_pension_type_info (
                  p_business_group_id           => p_business_group_id
                 ,p_effective_date              => p_effective_date
                 ,p_pension_type_id             => l_pension_type_id
                 ,p_pens_type_info_rec          => l_pens_type_info_rec
                 ,p_error_msg                   => p_error_msg
               );

         IF l_return = -1
         THEN
            IF g_debug
            THEN
               l_proc_step                := 40;
               DEBUG (   'Leaving: '
                      || l_proc_name, l_proc_step);
            END IF;

            RETURN -1;
         END IF; -- End if of error occurred check ...

         -- Store it in cache
         l_tab_pension_types_info (l_pension_type_id).pension_type_id :=
                                          l_pens_type_info_rec.pension_type_id;
         l_tab_pension_types_info (l_pension_type_id).pension_type_name :=
                                        l_pens_type_info_rec.pension_type_name;
         l_tab_pension_types_info (l_pension_type_id).pension_category :=
                                         l_pens_type_info_rec.pension_category;
         l_tab_pension_types_info (l_pension_type_id).effective_start_date :=
                                     l_pens_type_info_rec.effective_start_date;
         l_tab_pension_types_info (l_pension_type_id).effective_end_date :=
                                       l_pens_type_info_rec.effective_end_date;
         l_tab_pension_types_info (l_pension_type_id).minimum_age :=
                                              l_pens_type_info_rec.minimum_age;
         l_tab_pension_types_info (l_pension_type_id).maximum_age :=
                                              l_pens_type_info_rec.maximum_age;
         -- Store it in global collection now
         g_tab_pension_types_info   := l_tab_pension_types_info;
      ELSE -- in cache
         l_pens_type_info_rec       :=
                                 l_tab_pension_types_info (l_pension_type_id);
      END IF; -- End if of pension type info in cache check ...

      p_minimum_age              := l_pens_type_info_rec.minimum_age;
      p_maximum_age              := l_pens_type_info_rec.maximum_age;

      IF g_debug
      THEN
         DEBUG (
               'Minimum Age: '
            || TO_CHAR (l_pens_type_info_rec.minimum_age)
         );
         DEBUG (
               'Maximum Age: '
            || TO_CHAR (l_pens_type_info_rec.maximum_age)
         );
         l_proc_step                := 50;
         DEBUG (   'Leaving: '
                || l_proc_name, l_proc_step);
      END IF;

      RETURN 0;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         p_error_msg                := SQLERRM;
         p_minimum_age              := NULL;
         p_maximum_age              := NULL;

         IF SQLCODE <> hr_utility.hr_error_number
         THEN
            debug_others (l_proc_name, l_proc_step);

            IF g_debug
            THEN
               DEBUG (   'Leaving: '
                      || l_proc_name, -999);
            END IF;

            fnd_message.raise_error;
         ELSE
            RAISE;
         END IF;
   END get_ele_pens_type_info;

   --

--
--==============================================================================
--|---------------------------< get_input_value_id >---------------------------|
--==============================================================================
   FUNCTION get_input_value_id (
      p_input_value_name   IN   VARCHAR2
     ,p_element_type_id    IN   NUMBER
     ,p_effective_date     IN   DATE
   )
      RETURN NUMBER
   IS
      --
      -- Cursor to retrieve the input value information
      CURSOR csr_get_ipv_info (c_element_type_id NUMBER)
      IS
         SELECT input_value_id
           FROM pay_input_values_f
          WHERE NAME = p_input_value_name
            AND element_type_id = c_element_type_id
            AND p_effective_date BETWEEN effective_start_date
                                     AND effective_end_date;

      l_proc_name        VARCHAR2 (80)
                                      :=    g_proc_name
                                         || 'get_input_value_id';
      l_input_value_id   NUMBER;
      l_proc_step        NUMBER;
   --
   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step                := 10;
         DEBUG (   'Entering: '
                || l_proc_name, l_proc_step);
      END IF;

      --
      OPEN csr_get_ipv_info (p_element_type_id);
      FETCH csr_get_ipv_info INTO l_input_value_id;

      IF csr_get_ipv_info%NOTFOUND
      THEN
         CLOSE csr_get_ipv_info;
         fnd_message.set_name ('PQP', 'PQP_230935_INPUT_VAL_NOTFOUND');
         fnd_message.set_token ('INPUT_VALUE', p_input_value_name);
         fnd_message.raise_error;
      END IF; -- End if of csr row not found check ...

      CLOSE csr_get_ipv_info;

      IF g_debug
      THEN
         DEBUG (   'Input Value ID: '
                || TO_CHAR (l_input_value_id));
         l_proc_step                := 20;
         DEBUG (   'Leaving: '
                || l_proc_name, l_proc_step);
      END IF;

      --
      RETURN l_input_value_id;
   END get_input_value_id;

   --

-- This function returns the element entry value for a given element entry id
-- and input value id
--
-- ----------------------------------------------------------------------------
-- |-------------------------< get_ele_entry_value >--------------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_ele_entry_value (
      p_element_entry_id       IN   NUMBER
     ,p_input_value_id         IN   NUMBER
     ,p_effective_start_date   IN   DATE
     ,p_effective_end_date     IN   DATE
   )
      RETURN VARCHAR2
   IS

--

      -- Cursor to get element entry value information

      CURSOR csr_get_ele_entry_value
      IS
         SELECT screen_entry_value
           FROM pay_element_entry_values_f
          WHERE element_entry_id = p_element_entry_id
            AND input_value_id = p_input_value_id
            AND effective_start_date = p_effective_start_date
            AND effective_end_date = p_effective_end_date;

      l_proc_name         VARCHAR2 (72)
                                     :=    g_proc_name
                                        || 'get_ele_entry_value';
      l_ele_entry_value   pay_element_entry_values_f.screen_entry_value%TYPE;
      l_proc_step         NUMBER;

--
   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step                := 10;
         DEBUG (   'Entering: '
                || l_proc_name, l_proc_step);
      END IF;

      OPEN csr_get_ele_entry_value;
      FETCH csr_get_ele_entry_value INTO l_ele_entry_value;
      CLOSE csr_get_ele_entry_value;

      IF g_debug
      THEN
         DEBUG (   'Element Entry ID: '
                || TO_CHAR (p_element_entry_id));
         DEBUG (   'Input Value ID: '
                || TO_CHAR (p_input_value_id));
         DEBUG (   'Entry Value: '
                || l_ele_entry_value);
         l_proc_step                := 20;
         DEBUG (   'Leaving: '
                || l_proc_name, l_proc_step);
      END IF;

      RETURN l_ele_entry_value;
   END get_ele_entry_value;


-- ----------------------------------------------------------------------------
-- |----------------------------< get_ele_opt_out_info >----------------------|
-- ----------------------------------------------------------------------------
   FUNCTION get_ele_opt_out_info (
      p_element_type_id        IN   NUMBER
     ,p_element_entry_id       IN   NUMBER
     ,p_effective_start_date   IN   DATE
     ,p_effective_end_date     IN   DATE
     ,p_effective_date         IN   DATE
   )
      RETURN BOOLEAN
   IS
      --

      l_proc_name        VARCHAR2 (80)
                                    :=    g_proc_name
                                       || 'get_ele_opt_out_info';
      l_proc_step        NUMBER;
      l_exists           VARCHAR2 (1);
      l_return           BOOLEAN;
      l_value            VARCHAR2 (100);
      l_opt_out_date     DATE;
      l_input_value_id   NUMBER;
   --
   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step                := 10;
         DEBUG (   'Entering: '
                || l_proc_name, l_proc_step);
      END IF;

      l_return                   := FALSE;
      --
      -- Get the input value id for opt out date
      --
      l_input_value_id           :=
            get_input_value_id (
               p_input_value_name            => 'Opt Out Date'
              ,p_element_type_id             => p_element_type_id
              ,p_effective_date              => p_effective_date
            );

      IF g_debug
      THEN
         l_proc_step                := 20;
         DEBUG (l_proc_name, l_proc_step);
      END IF;

      -- Get the screen entry value

      l_value                    :=
            get_ele_entry_value (
               p_element_entry_id            => p_element_entry_id
              ,p_input_value_id              => l_input_value_id
              ,p_effective_start_date        => p_effective_start_date
              ,p_effective_end_date          => p_effective_end_date
            );

      IF l_value IS NOT NULL
      THEN
         l_opt_out_date             := fnd_date.canonical_to_date (l_value);

         IF l_opt_out_date <= p_effective_date
         THEN
            -- Opted out
            l_return                   := TRUE;
         END IF; -- End if of opt out date < effective date check ...
      END IF; -- End if of value specified check ...

      IF g_debug
      THEN
         l_proc_step                := 30;
         DEBUG (   'Leaving: '
                || l_proc_name, l_proc_step);
      END IF;

      RETURN l_return;
   --
   END get_ele_opt_out_info;

   --

-- ----------------------------------------------------------------------------
-- |----------------------------< chk_ele_entry_exists >----------------------|
-- ----------------------------------------------------------------------------
   FUNCTION chk_ele_entry_exists (
      p_assignment_id          IN              NUMBER
     ,p_business_group_id      IN              NUMBER
     ,p_effective_date         IN              DATE
     ,p_element_type_id        IN              NUMBER
     ,p_opt_out_dt_chk         IN              BOOLEAN
     ,p_yes_no                 OUT NOCOPY      VARCHAR2
     ,p_effective_start_date   OUT NOCOPY      DATE
     ,p_effective_end_date     OUT NOCOPY      DATE
     ,p_error_msg              OUT NOCOPY      VARCHAR2
   )
      RETURN NUMBER
   IS
      --

      l_proc_name         VARCHAR2 (80)
                                    :=    g_proc_name
                                       || 'chk_ele_entry_exists';
      l_proc_step         NUMBER;
      l_ele_entry_info    csr_chk_ele_entry_exists%ROWTYPE;
      l_yes_no            VARCHAR2 (1);
      l_element_link_id   NUMBER;
      l_opt_out           BOOLEAN;
   --
   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step                := 10;
         DEBUG (   'Entering: '
                || l_proc_name, l_proc_step);
      END IF;

      --
      l_yes_no                   := 'N';
      -- Comment out the following line of code as a fix
      -- for Bug 3637584
      -- Get the element link id for this element
--      l_element_link_id          :=
--             get_ele_link_info (
--                p_element_type_id             => p_element_type_id
--               ,p_business_group_id           => p_business_group_id
--               ,p_effective_date              => p_effective_date
--             );
--
--       -- Only check for entry if a link exists
--       IF l_element_link_id IS NOT NULL
--       THEN
--          IF g_debug
--          THEN
--             l_proc_step                := 20;
--             DEBUG (l_proc_name, l_proc_step);
--          END IF;

	 -- Added new params for bug fix 3637584
         -- Check whether the element entry exists for this assignment
         OPEN csr_chk_ele_entry_exists (
            p_assignment_id
           ,p_element_type_id
           ,p_business_group_id
           ,p_effective_date
         );
         FETCH csr_chk_ele_entry_exists INTO l_ele_entry_info;

         IF csr_chk_ele_entry_exists%FOUND
         THEN
            l_yes_no                   := 'Y';
            p_effective_start_date     :=
                                        l_ele_entry_info.effective_start_date;
            p_effective_end_date       := l_ele_entry_info.effective_end_date;

            -- Do opt out date check if specified
            IF p_opt_out_dt_chk
            THEN
               l_opt_out                  := FALSE;
               l_opt_out                  :=
                     get_ele_opt_out_info (
                        p_element_type_id             => p_element_type_id
                       ,p_element_entry_id            => l_ele_entry_info.element_entry_id
                       ,p_effective_start_date        => l_ele_entry_info.effective_start_date
                       ,p_effective_end_date          => l_ele_entry_info.effective_end_date
                       ,p_effective_date              => p_effective_date
                     );

               IF l_opt_out
               THEN
                  -- yes opted out
                  l_yes_no                   := 'O';
               END IF; -- End if of opt out is yes check ...
            END IF; -- End if of opt out dt check ...
         END IF; -- End if of ele entry exists ...

         CLOSE csr_chk_ele_entry_exists;
--      END IF; -- End if of ele link id is not null check ...

      IF g_debug
      THEN
         DEBUG (   'Yes or NO: '
                || l_yes_no);
         l_proc_step                := 30;
         DEBUG (   'Leaving: '
                || l_proc_name, l_proc_step);
      END IF;

      p_yes_no                   := l_yes_no;
      RETURN 0;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         p_yes_no                   := NULL;
         p_effective_start_date     := NULL;
         p_effective_end_date       := NULL;
         p_error_msg                := SQLERRM;

         IF SQLCODE <> hr_utility.hr_error_number
         THEN
            debug_others (l_proc_name, l_proc_step);

            IF g_debug
            THEN
               DEBUG (   'Leaving: '
                      || l_proc_name, -999);
            END IF;

            fnd_message.raise_error;
         ELSE
            RAISE;
         END IF;
   END chk_ele_entry_exists;


--

-- ----------------------------------------------------------------------------
-- |----------------------------< chk_element_entry_exists >------------------|
-- ----------------------------------------------------------------------------
   FUNCTION chk_element_entry_exists (
      p_assignment_id       IN              NUMBER
     ,p_business_group_id   IN              NUMBER
     ,p_effective_date      IN              DATE
     ,p_element_type_id     IN              NUMBER
     ,p_yes_no              OUT NOCOPY      VARCHAR2
     ,p_error_msg           OUT NOCOPY      VARCHAR2
   )
      RETURN NUMBER
   IS
      --

      CURSOR csr_pen_sch_exist
      IS
      SELECT employee_deduction_method
        FROM pqp_gb_pension_schemes_v
       WHERE element_type_id = p_element_type_id;

      l_proc_name                VARCHAR2 (80)
                                :=    g_proc_name
                                   || 'chk_element_entry_exists';
      l_proc_step                NUMBER;
      l_yes_no                   VARCHAR2 (1);
      l_element_type_id          NUMBER;
      l_effective_start_date     DATE;
      l_effective_end_date       DATE;
      l_tab_element_types_info   t_element_types;
      l_emp_deduction_mthd       pay_element_type_extra_info.eei_information1%TYPE;
   --
   BEGIN
      --
      IF g_debug
      THEN
         l_proc_step                := 10;
         DEBUG (   'Entering: '
                || l_proc_name, l_proc_step);
      END IF;

      --
      -- Check whether information exists in cache
      --

      l_tab_element_types_info   := g_tab_element_types_info;

      IF      l_tab_element_types_info.EXISTS (p_element_type_id)
          AND -- check the effectiveness and assignment details
             (p_effective_date
                 BETWEEN NVL (
                            l_tab_element_types_info (p_element_type_id).effective_start_date
                           ,p_effective_date
                         )
                     AND NVL (
                            l_tab_element_types_info (p_element_type_id).effective_end_date
                           ,p_effective_date
                         )
             )
          AND l_tab_element_types_info (p_element_type_id).assignment_id =
                                                               p_assignment_id
      THEN
         l_yes_no                   :=
                      l_tab_element_types_info (p_element_type_id).yes_no_opt;
      ELSE -- Information not in cache
         --
         -- Call function to check whether element entry exists
         --

         IF chk_ele_entry_exists (
               p_assignment_id               => p_assignment_id
              ,p_business_group_id           => p_business_group_id
              ,p_effective_date              => p_effective_date
              ,p_element_type_id             => p_element_type_id
              ,p_opt_out_dt_chk              => FALSE
              ,p_yes_no                      => l_yes_no
              ,p_effective_start_date        => l_effective_start_date
              ,p_effective_end_date          => l_effective_end_date
              ,p_error_msg                   => p_error_msg
            ) <> 0
         THEN
            IF g_debug
            THEN
               DEBUG (   'Yes or NO: '
                      || l_yes_no);
               l_proc_step                := 15;
               DEBUG (   'Leaving: '
                      || l_proc_name, l_proc_step);
            END IF;

            RETURN -1;
         END IF; -- End if of function in error check ...

         IF g_debug
         THEN
            l_proc_step                := 20;
            DEBUG (l_proc_name, l_proc_step);
         END IF;

         IF l_yes_no = 'N'
         THEN
            -- Check whether this scheme supports both deduction methods
            l_emp_deduction_mthd := NULL;
            OPEN csr_pen_sch_exist;
            FETCH csr_pen_sch_exist INTO l_emp_deduction_mthd;
            CLOSE csr_pen_sch_exist;
            IF g_debug
            THEN
              l_proc_step := 25;
              DEBUG (l_proc_name, l_proc_step);
              DEBUG ('l_emp_deduction_mthd: '||l_emp_deduction_mthd);
            END IF;
            IF l_emp_deduction_mthd = 'PEFR'  THEN
              -- Check whether there is any other base element
              -- for this pension scheme name
              OPEN csr_get_sch_oth_ele_id (
                 p_element_type_id
                ,p_business_group_id
              );
              FETCH csr_get_sch_oth_ele_id INTO l_element_type_id;

              IF csr_get_sch_oth_ele_id%FOUND
              THEN
                 IF g_debug
                 THEN
                    l_proc_step                := 30;
                    DEBUG (l_proc_name, l_proc_step);
                 END IF;

                 l_yes_no                   := NULL;

                 IF chk_ele_entry_exists (
                       p_assignment_id               => p_assignment_id
                      ,p_business_group_id           => p_business_group_id
                      ,p_effective_date              => p_effective_date
                      ,p_element_type_id             => l_element_type_id
                      ,p_opt_out_dt_chk              => TRUE
                      ,p_yes_no                      => l_yes_no
                      ,p_effective_start_date        => l_effective_start_date
                      ,p_effective_end_date          => l_effective_end_date
                      ,p_error_msg                   => p_error_msg
                    ) <> 0
                 THEN
                    IF g_debug
                    THEN
                       DEBUG (   'Yes or NO: '
                              || l_yes_no);
                       l_proc_step                := 40;
                       DEBUG (   'Leaving: '
                              || l_proc_name, l_proc_step);
                    END IF;

                    CLOSE csr_get_sch_oth_ele_id;
                    RETURN -1;
                 END IF; -- End if of function in error check ...
              END IF; -- End if of row found check ...

              CLOSE csr_get_sch_oth_ele_id;
            END IF; -- End if of pen scheme exists ...
         END IF; -- yes no is N check ...

         -- Update the cache
         l_tab_element_types_info (p_element_type_id).element_type_id :=
                                                             p_element_type_id;
         l_tab_element_types_info (p_element_type_id).assignment_id :=
                                                               p_assignment_id;
         l_tab_element_types_info (p_element_type_id).effective_start_date :=
                                                        l_effective_start_date;
         l_tab_element_types_info (p_element_type_id).effective_end_date :=
                                                          l_effective_end_date;
         l_tab_element_types_info (p_element_type_id).yes_no_opt := l_yes_no;
         -- Store it in global collection
         g_tab_element_types_info   := l_tab_element_types_info;
      END IF; -- End if of check whether information is in cache...

      IF g_debug
      THEN
         DEBUG (   'Yes or NO: '
                || l_yes_no);
         l_proc_step                := 50;
         DEBUG (   'Leaving: '
                || l_proc_name, l_proc_step);
      END IF;

      p_yes_no                   := l_yes_no;
      RETURN 0;
   --
   EXCEPTION
      WHEN OTHERS
      THEN
         p_yes_no                   := NULL;
         p_error_msg                := SQLERRM;

         IF SQLCODE <> hr_utility.hr_error_number
         THEN
            debug_others (l_proc_name, l_proc_step);

            IF g_debug
            THEN
               DEBUG (   'Leaving: '
                      || l_proc_name, -999);
            END IF;

            fnd_message.raise_error;
         ELSE
            RAISE;
         END IF;
   END chk_element_entry_exists;
--

--
END pqp_gb_pension_functions;

/
